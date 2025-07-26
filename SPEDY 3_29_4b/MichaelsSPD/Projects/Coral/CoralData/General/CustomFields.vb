Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks

Public Class CustomFields

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDs As ArrayList) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Return GetCustomFields(recordType, recordIDs, False)
    End Function

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDs As ArrayList, ByVal gridFieldsOnly As Boolean) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Dim records As String = "0"
        Dim str As String = String.Join(",", recordIDs.ToArray())
        If str.Length > 0 Then
            records += ("," + str)
        End If
        Return GetCustomFields(recordType, records, gridFieldsOnly)
    End Function

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDString As String) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Return GetCustomFields(recordType, recordIDString, False)
    End Function

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDString As String, ByVal gridFieldsOnly As Boolean) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Dim objCFields As NovaLibra.Coral.SystemFrameworks.CustomFields = New NovaLibra.Coral.SystemFrameworks.CustomFields
        Dim field As CustomField = Nothing
        Dim value As CustomFieldValue = Nothing
        Dim fieldID As Integer
        Dim fieldType As Integer
        Dim sql As String = "sp_CustomFields_GetCustomFields"
        Dim reader As DBReader = Nothing
        Dim conn As DBConnection = Nothing
        Dim cmd As DBCommand
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection(False)
            conn.Open()
            reader = New DBReader(conn)
            cmd = reader.Command
            cmd.Parameters.Add("@recordType", SqlDbType.Int).Value = recordType
            cmd.Parameters.Add("@recordIDs", SqlDbType.VarChar, -1).Value = recordIDString
            cmd.Parameters.Add("@gridFieldsOnly", SqlDbType.Bit).Value = gridFieldsOnly
            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()
            Do While reader.Read()
                With reader
                    field = New CustomField
                    field.ID = DataHelper.SmartValues(.Item("ID"), "integer", True)
                    field.RecordType = DataHelper.SmartValues(.Item("Record_Type"), "integer", True)
                    field.FieldName = DataHelper.SmartValues(.Item("Field_Name"), "string", True)
                    fieldType = DataHelper.SmartValues(.Item("Field_Type"), "integer", False)
                    If CustomFieldType.IsDefined(GetType(CustomFieldType), fieldType) Then
                        field.FieldType = CType(fieldType, CustomFieldType)
                    Else
                        field.FieldType = CustomFieldType.TypeUnknown
                    End If
                    field.FieldLimit = DataHelper.SmartValues(.Item("Field_Limit"), "integer", True)
                    field.Grid = DataHelper.SmartValues(.Item("Grid"), "boolean", False)
                    objCFields.AddCustomField(field)
                End With
            Loop
            If reader.NextResult() Then
                Do While reader.Read()
                    With reader
                        fieldID = DataHelper.SmartValues(.Item("Field_ID"), "integer", True)
                        field = objCFields.GetCustomField(fieldID)
                        If Not field Is Nothing Then
                            value = New CustomFieldValue(field)
                            'value.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                            value.RecordID = DataHelper.SmartValues(.Item("Record_ID"), "long", True)
                            Select Case field.FieldType
                                Case CustomFieldType.TypeBoolean, CustomFieldType.TypeInteger, CustomFieldType.TypeLong
                                    value.FieldValue = DataHelper.SmartValues(.Item("Field_Value_Integer"), "long", True)
                                Case CustomFieldType.TypeDecimal, CustomFieldType.TypeMoney, CustomFieldType.TypePercent
                                    value.FieldValue = DataHelper.SmartValues(.Item("Field_Value_Decimal"), "decimal", True)
                                Case CustomFieldType.TypeDate, CustomFieldType.TypeDateTime, CustomFieldType.TypeTime
                                    value.FieldValue = DataHelper.SmartValues(.Item("Field_Value_DateTime"), "datetime", True)
                                Case Else
                                    value.FieldValue = DataHelper.SmartValues(.Item("Field_Value_String"), "string", True)
                            End Select
                            objCFields.AddValue(value)
                        End If
                    End With
                Loop
            End If
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
            Throw ex
        Finally
            cmd = Nothing
            If Not reader Is Nothing Then
                reader.Dispose()
                reader = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
        End Try
        Return objCFields
    End Function

    Public Shared Function SaveCustomFieldValues(ByRef objCFields As NovaLibra.Coral.SystemFrameworks.CustomFields) As Boolean
        Dim cmd As DBCommand = Nothing
        'Dim objParam As System.Data.SqlClient.SqlParameter
        Dim conn As DBConnection = Nothing
        Dim param As SqlParameter
        Dim recordID As Long = 0
        Dim ret As Boolean = False
        Dim value As CustomFieldValue
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection()
            cmd = New DBCommand(conn)
            cmd.CommandType = CommandType.StoredProcedure

            ' [sp_CustomFields_SaveValue]
            If objCFields.ValueCount > 0 Then
                cmd.CommandText = "sp_CustomFields_SaveValue"
                'objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                'objParam.Direction = ParameterDirection.InputOutput
                'objParam.Value = 0
                'cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@recordID", SqlDbType.BigInt)
                cmd.Parameters.Add("@fieldID", SqlDbType.Int)
                cmd.Parameters.Add("@fieldValueInteger", SqlDbType.BigInt)
                param = cmd.Parameters.Add("@fieldValueDecimal", SqlDbType.Decimal)
                param.Precision = 18
                param.Scale = 6
                cmd.Parameters.Add("@fieldValueDateTime", SqlDbType.DateTime)
                cmd.Parameters.Add("@fieldValueString", SqlDbType.Text)
                For Each de As DictionaryEntry In objCFields.Values
                    value = CType(de.Value, CustomFieldValue)
                    'cmd.Parameters("@ID").Value = DataHelper.DBSmartValues(value.ID, "long", True)
                    cmd.Parameters("@recordID").Value = DataHelper.DBSmartValues(value.RecordID, "long", False)
                    cmd.Parameters("@fieldID").Value = DataHelper.DBSmartValues(value.FieldID, "integer", False)
                    Select Case value.FieldType
                        Case CustomFieldType.TypeBoolean, CustomFieldType.TypeInteger, CustomFieldType.TypeLong
                            cmd.Parameters("@fieldValueInteger").Value = value.FieldValueIntegerDB
                            cmd.Parameters("@fieldValueDecimal").Value = DBNull.Value
                            cmd.Parameters("@fieldValueDateTime").Value = DBNull.Value
                            cmd.Parameters("@fieldValueString").Value = DBNull.Value
                        Case CustomFieldType.TypeDecimal, CustomFieldType.TypeMoney, CustomFieldType.TypePercent
                            cmd.Parameters("@fieldValueInteger").Value = DBNull.Value
                            cmd.Parameters("@fieldValueDecimal").Value = value.FieldValueDecimalDB
                            cmd.Parameters("@fieldValueDateTime").Value = DBNull.Value
                            cmd.Parameters("@fieldValueString").Value = DBNull.Value
                        Case CustomFieldType.TypeDate, CustomFieldType.TypeDateTime, CustomFieldType.TypeTime
                            cmd.Parameters("@fieldValueInteger").Value = DBNull.Value
                            cmd.Parameters("@fieldValueDecimal").Value = DBNull.Value
                            cmd.Parameters("@fieldValueDateTime").Value = value.FieldValueDateTimeDB
                            cmd.Parameters("@fieldValueString").Value = DBNull.Value
                        Case Else
                            cmd.Parameters("@fieldValueInteger").Value = DBNull.Value
                            cmd.Parameters("@fieldValueDecimal").Value = DBNull.Value
                            cmd.Parameters("@fieldValueDateTime").Value = DBNull.Value
                            cmd.Parameters("@fieldValueString").Value = value.FieldValueStringDB
                    End Select
                    cmd.ExecuteNonQuery()
                Next
            End If
            ret = True

        Catch ex As Exception
            Logger.LogError(ex)
            ret = False
            Throw ex
        Finally
            If Not cmd Is Nothing Then
                cmd.Dispose()
                cmd = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
        End Try
        Return ret
    End Function

End Class
