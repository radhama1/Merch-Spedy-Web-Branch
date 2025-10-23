Imports System

Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class FieldLockingData
        Inherits FieldAuditingData
        'Inherits ItemBase

        Public Function GetFieldLocking(ByVal userID As Long, ByVal tableID As MetadataTable, ByVal VendorID As Integer, ByVal workFlowStageID As Integer, ByVal getChildren As Boolean) As FieldLocking
            Dim objFL As FieldLocking = New FieldLocking(userID, tableID)
            Dim objRecord As MetadataColumn
            Dim sql As String = "usp_SPD_FieldLocking_GetColumns"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                cmd.Parameters.Add("@tableID", SqlDbType.Int).Value = tableID
                cmd.Parameters.Add("@VendorID", SqlDbType.Int).Value = VendorID
                cmd.Parameters.Add("@WorkflowStageID", SqlDbType.Int).Value = workFlowStageID
                cmd.Parameters.Add("@GetChildren", SqlDbType.Int).Value = IIf(getChildren, 1, 0)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    objFL.TableName = DataHelper.SmartValues(reader.Item("Table_Name"), "string", True)
                End If
                If reader.NextResult() Then
                    Do While reader.Read()
                        objRecord = New MetadataColumn()
                        With reader
                            objRecord.ID = .Item("Column_ID")
                            objRecord.ColumnName = DataHelper.SmartValues(.Item("Column_Name"), "string", True)
                            objRecord.DisplayName = DataHelper.SmartValues(.Item("Display_Name"), "string", True)
                            objRecord.SortOrder = DataHelper.SmartValues(.Item("Sort_Order"), "string", False)
                            objRecord.Permission = .Item("Permission")
                        End With
                        objFL.Add(objRecord)
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
            Return objFL
        End Function

        Public Function GetFieldLockedControls(ByVal userID As Long, ByVal tableID As MetadataTable, ByVal workFlowStageID As Integer, ByVal getChildren As Boolean) As FieldLocking
            Dim objFL As FieldLocking = New FieldLocking(userID, tableID)
            Dim objRecord As New MetadataColumn
            Dim currentColumn As Integer = 0
            Dim sql As String = "usp_SPD_FieldLocking_GetControls"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                cmd.Parameters.Add("@tableID", SqlDbType.Int).Value = tableID
                cmd.Parameters.Add("@WorkflowStageID", SqlDbType.Int).Value = workFlowStageID
                cmd.Parameters.Add("@GetChildren", SqlDbType.Int).Value = IIf(getChildren, 1, 0)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    objFL.TableName = DataHelper.SmartValues(reader.Item("Table_Name"), "string", True)
                End If
                If reader.NextResult() Then
                    Do While reader.Read()
                        With reader
                            If currentColumn <> .Item("Column_ID") Then
                                'If this is not the first time through the loop, add the current MetaData Column to the FieldLock Collection
                                If (currentColumn > 0) Then objFL.Add(objRecord)

                                'Create a new MetaData Column
                                objRecord = New MetadataColumn
                                objRecord.ID = .Item("Column_ID")
                                objRecord.ColumnName = DataHelper.SmartValues(.Item("Column_Name"), "string", True)
                                objRecord.DisplayName = DataHelper.SmartValues(.Item("Display_Name"), "string", True)
                                objRecord.SortOrder = DataHelper.SmartValues(.Item("Sort_Order"), "string", False)
                                objRecord.Permission = .Item("Permission")
                                currentColumn = objRecord.ID

                            End If
                            'If there is a Control_Name, then add it to the current MetaData Column
                            If Not IsDBNull(.Item("Control_Name")) Then
                                objRecord.ControlNames.Add(.Item("Control_Name"))
                            End If
                        End With
                    Loop
                    'Add the Last MetaData Column to the FieldLock Collection
                    objFL.Add(objRecord)
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

            'Return the FieldLock data
            Return objFL

        End Function


    End Class

End Namespace


