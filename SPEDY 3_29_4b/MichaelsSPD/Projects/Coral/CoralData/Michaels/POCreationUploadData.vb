Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

    Public Class POCreationUploadData

        Public Shared Sub SaveRecord(ByRef objRec As POCreationUploadRecord, ByVal UserID As Integer, Optional ByVal HydrateRecord As Hydrate = Hydrate.None)
            Try
                Dim recordID As Integer = _SaveRecord(objRec, UserID)

                If HydrateRecord <> Hydrate.None Then
                    Select Case HydrateRecord
                        Case Hydrate.All
                            objRec = GetRecord(recordID)
                        Case Hydrate.ID
                            objRec.ID = recordID
                    End Select
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try

        End Sub

        Private Shared Function _SaveRecord(ByVal objRecord As POCreationUploadRecord, ByVal UserID As Integer) As Long

            Dim recordID As Integer = -1
            Dim sql As String = "PO_Creation_Upload_InsertUpdate"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = objRecord.ID
                cmd.Parameters.Add(objParam)

                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = objRecord.POCreationID
                cmd.Parameters.Add("@File_Name", SqlDbType.VarChar).Value = objRecord.FileName
                cmd.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = objRecord.IsValid
                cmd.Parameters.Add("@Detail_Type_ID", SqlDbType.TinyInt).Value = objRecord.DetailTypeID
                cmd.Parameters.Add("@Applied_To_PO", SqlDbType.Bit).Value = objRecord.AppliedToPO
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID

                cmd.CommandText = sql
                cmd.CommandTimeout = 1800
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

                recordID = cmd.Parameters("@ID").Value

            Catch ex As Exception
                Logger.LogError(ex)
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

            Return recordID

        End Function

        Public Shared Function GetRecord(ByVal ID As Long) As POCreationUploadRecord

            Dim objRecord As New POCreationUploadRecord()
            Dim sql As String = "PO_Creation_Upload_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = ID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.POCreationID = DataHelper.SmartValuesDBNull(.Item("PO_Creation_ID"))
                        objRecord.FileName = DataHelper.SmartValuesDBNull(.Item("File_Name"))
                        objRecord.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        objRecord.DetailTypeID = DataHelper.SmartValuesDBNull(.Item("Detail_Type_ID"))
                        objRecord.AppliedToPO = DataHelper.SmartValuesDBNull(.Item("Applied_To_PO"))
                        objRecord.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        objRecord.CreatedUserName = DataHelper.SmartValuesDBNull(.Item("Created_User_Name"))
                        objRecord.CreatedUserID = DataHelper.SmartValue(DataHelper.SmartValuesDBNull(.Item("Created_User_ID")), "CInt")

                    End With

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return objRecord

        End Function

        Public Enum Hydrate As Short
            None = 0
            ID = 1
            All = 2
        End Enum

        Public Shared Sub SaveUploadFile(ByVal pPOCreationUploadID As Long, ByVal pDataStr As String, ByVal pUserID As Integer)

            Dim sql As String = "PO_Creation_Upload_Insert_By_Str"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                cmd.Parameters.Add("@Data_Str", SqlDbType.VarChar).Value = pDataStr
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = pUserID

                cmd.CommandText = sql
                cmd.CommandTimeout = 1800
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 1800
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
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

        End Sub

        Public Shared Function UploadHasDuplicateSkus(ByVal pPOCreationUploadID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Duplicate_SKUs"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasDupRecords As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasDupRecords = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            errRec.ErrorText = "Duplicate SKU " & DataHelper.SmartValuesDBNull(.Item("SKU")) & " at rows " & DataHelper.SmartValuesDBNull(.Item("Row_Num_Str"))

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasDupRecords

        End Function

        Public Shared Function UploadHasDuplicateSkuLocation(ByVal pPOCreationUploadID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Duplicate_SKU_Location"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasDupRecords As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasDupRecords = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            errRec.ErrorText = "Duplicate SKU/Location " & DataHelper.SmartValuesDBNull(.Item("SKU")) & "/" & DataHelper.SmartValuesDBNull(.Item("Location_Number")) & " at rows " & DataHelper.SmartValuesDBNull(.Item("Row_Num_Str"))

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasDupRecords

        End Function

        Public Shared Function UploadHasInvalidSkus(ByVal pPOCreationUploadID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Invalid_SKUs"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasInvalidSkus As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasInvalidSkus = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            If DataHelper.SmartValue(.Item("Exists_In_System"), "CBool", False) = False Then
                                errRec.ErrorText = "Invalid SKU " & DataHelper.SmartValuesDBNull(.Item("SKU")) & " at row " & DataHelper.SmartValuesDBNull(.Item("Row_Number"))
                            Else
                                errRec.ErrorText = "SKU " & DataHelper.SmartValuesDBNull(.Item("SKU")) & " does not belong to Vendor " & DataHelper.SmartValue(.Item("Vendor_Number"), "CStr", "") & " - " & DataHelper.SmartValue(.Item("Vendor_Name"), "CStr", "") & " at row " & DataHelper.SmartValuesDBNull(.Item("Row_Number"))
                            End If

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasInvalidSkus

        End Function

        Public Shared Function UploadHasInvalidItemDepts(ByVal pPOCreationUploadID As Integer, ByVal pUserID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Invalid_Item_Depts"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasInvalidLocations As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = pUserID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasInvalidLocations = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            errRec.ErrorText = "Not allowed to add item " & DataHelper.SmartValue(.Item("SKU"), "CStr", "") & " with department " & DataHelper.SmartValue(.Item("Dept"), "CStr", "") & " - " & DataHelper.SmartValue(.Item("Dept_Name"), "CStr", "") & " at row " & DataHelper.SmartValue(.Item("Row_Number"), "CStr", "")

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasInvalidLocations

        End Function

        Public Shared Function UploadHasInvalidLocations(ByVal pPOCreationUploadID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Invalid_Locations"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasInvalidLocations As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasInvalidLocations = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            errRec.ErrorText = "Invalid Location Number " & DataHelper.SmartValuesDBNull(.Item("Location_Number")) & " at row " & DataHelper.SmartValuesDBNull(.Item("Row_Number"))

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasInvalidLocations

        End Function

        Public Shared Function UploadHasCostDiffBySku(ByVal pPOCreationUploadID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Cost_Diff_By_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasDiffs As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasDiffs = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            errRec.ErrorText = "Different Cost for item " & DataHelper.SmartValuesDBNull(.Item("SKU")) & " located at rows " & DataHelper.SmartValuesDBNull(.Item("Row_Num_Str"))

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasDiffs

        End Function

        Public Shared Function UploadHasInnerPackDiffBySku(ByVal pPOCreationUploadID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Inner_Pack_Diff_By_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasDiffs As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasDiffs = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            errRec.ErrorText = "Different IP for item " & DataHelper.SmartValuesDBNull(.Item("SKU")) & " located at rows " & DataHelper.SmartValuesDBNull(.Item("Row_Num_Str"))

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasDiffs

        End Function

        Public Shared Function UploadHasMasterPackDiffBySku(ByVal pPOCreationUploadID As Integer, Optional ByRef vr As ValidationRecord = Nothing) As Boolean

            Dim sql As String = "PO_Creation_Upload_Get_Master_Pack_Diff_By_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim hasDiffs As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                hasDiffs = reader.HasRows

                If Not vr Is Nothing Then

                    While reader.Read()

                        Dim errRec As New ValidationError()

                        With reader

                            errRec.ErrorText = "Different MC for item " & DataHelper.SmartValuesDBNull(.Item("SKU")) & " located at rows " & DataHelper.SmartValuesDBNull(.Item("Row_Num_Str"))

                            vr.Add(errRec)

                        End With

                    End While

                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return hasDiffs

        End Function

        Public Shared Sub UploadUpdateEmptyValues(ByVal pPOCreationUploadID As Integer)

            Dim sql As String = "PO_Creation_Upload_Update_Empty_Values"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                cmd.CommandText = sql
                cmd.CommandTimeout = 1800
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
                Logger.LogError(ex)
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

        End Sub

        Public Shared Function StoreCacheDataAlreadyExists(ByVal pUserID As Integer, ByVal pPOCreationID As Integer) As Boolean

            Dim sql As String = "Select Top 1 ID From PO_Creation_Location_SKU_Store_CACHE Where Active_User_ID = " & pUserID & " And PO_Creation_ID = " & pPOCreationID
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim retValue As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()

                If reader.HasRows AndAlso reader.Read() Then
                    retValue = True
                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return retValue

        End Function

        Public Shared Function SKUCacheDataAlreadyExists(ByVal pUserID As Integer, ByVal pPOCreationID As Integer) As Boolean

            Dim sql As String = "Select Top 1 c.ID " & _
                                "From PO_Creation c " & _
                                "Inner Join PO_Creation_Location cl On cl.PO_Creation_ID = c.ID " & _
                                "Inner Join PO_Creation_Location_SKU_Cache cls On cls.PO_Creation_Location_ID = cl.ID And cls.Active_User_ID = " & pUserID & " " & _
                                "Where c.ID = " & pPOCreationID
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim retValue As Boolean = False

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()

                If reader.HasRows AndAlso reader.Read() Then
                    retValue = True
                End If

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return retValue

        End Function

        Public Shared Function UploadGetDataInFileNotOnPO(ByVal pPOCreationUploadID As Integer) As ArrayList

            Dim sql As String = "PO_Creation_Upload_Get_Data_In_File_Not_On_PO"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim list As New ArrayList
            Dim colDelim As String = "[COLDELIM]"

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()

                    With reader

                        list.Add(DataHelper.SmartValue(.Item("New_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Qty"), "CStr", "") & colDelim & Math.Round(DataHelper.SmartValue(.Item("New_Cost"), "CDbl", 0), 2) & colDelim & DataHelper.SmartValue(.Item("New_Inner_Pack"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Master_Pack"), "CStr", ""))

                    End With

                End While


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return list

        End Function

        Public Shared Function UploadGetDataInFileAndInPO(ByVal pPOCreationUploadID As Integer) As ArrayList

            Dim sql As String = "PO_Creation_Upload_Get_Data_In_PO_And_In_File"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim list As New ArrayList
            Dim colDelim As String = "[COLDELIM]"

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()

                    With reader

                        list.Add(DataHelper.SmartValue(.Item("Old_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Qty"), "CStr", "") & colDelim & Math.Round(DataHelper.SmartValue(.Item("Old_Cost"), "CDbl", 0), 2) & colDelim & DataHelper.SmartValue(.Item("Old_Inner_Pack"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Master_Pack"), "CStr", "") & _
                                 colDelim & _
                                 DataHelper.SmartValue(.Item("New_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Qty"), "CStr", "") & colDelim & Math.Round(DataHelper.SmartValue(.Item("New_Cost"), "CDbl", 0), 2) & colDelim & DataHelper.SmartValue(.Item("New_Inner_Pack"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Master_Pack"), "CStr", ""))

                    End With

                End While


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return list

        End Function

        Public Shared Function UploadGetDataInPONotInFile(ByVal pPOCreationUploadID As Integer) As ArrayList

            Dim sql As String = "PO_Creation_Upload_Get_Data_In_PO_Not_On_File"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim list As New ArrayList
            Dim colDelim As String = "[COLDELIM]"

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()

                    With reader

                        list.Add(DataHelper.SmartValue(.Item("Old_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Qty"), "CStr", "") & colDelim & Math.Round(DataHelper.SmartValue(.Item("Old_Cost"), "CDbl", 0), 2) & colDelim & DataHelper.SmartValue(.Item("Old_Inner_Pack"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Master_Pack"), "CStr", ""))

                    End With

                End While


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return list

        End Function

        Public Shared Sub UploadProcessChangesOnly(ByVal pPOCreationUploadID As Long)

            Dim sql As String = "PO_Creation_Upload_Process_Changes_Only"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                cmd.CommandText = sql
                cmd.CommandTimeout = 1800
                cmd.CommandType = CommandType.StoredProcedure

                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
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

        End Sub

        Public Shared Sub UploadReplaceExistingData(ByVal pPOCreationUploadID As Long)

            Dim sql As String = "PO_Creation_Upload_Replace_Existing_Data"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                cmd.CommandText = sql
                cmd.CommandTimeout = 1800
                cmd.CommandType = CommandType.StoredProcedure

                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
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

        End Sub

        Public Shared Function UploadGetDataInMMSFileNotOnPO(ByVal pPOCreationUploadID As Integer) As ArrayList

            Dim sql As String = "PO_Creation_Upload_Get_Data_In_File_Not_On_PO"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim list As New ArrayList
            Dim colDelim As String = "[COLDELIM]"

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()

                    With reader

                        list.Add(DataHelper.SmartValue(.Item("New_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Qty"), "CStr", ""))

                    End With

                End While


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return list

        End Function

        Public Shared Function UploadGetDataInMMSFileAndInPO(ByVal pPOCreationUploadID As Integer) As ArrayList

            Dim sql As String = "PO_Creation_Upload_Get_Data_In_PO_And_In_File"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim list As New ArrayList
            Dim colDelim As String = "[COLDELIM]"

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()

                    With reader

                        list.Add(DataHelper.SmartValue(.Item("Old_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Qty"), "CStr", "") & _
                                 colDelim & _
                                 DataHelper.SmartValue(.Item("New_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("New_Qty"), "CStr", ""))

                    End With

                End While


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return list

        End Function

        Public Shared Function UploadGetDataInPONotInMMSFile(ByVal pPOCreationUploadID As Integer) As ArrayList

            Dim sql As String = "PO_Creation_Upload_Get_Data_In_PO_Not_On_File"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim list As New ArrayList
            Dim colDelim As String = "[COLDELIM]"

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()

                    With reader

                        list.Add(DataHelper.SmartValue(.Item("Old_SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Location_Number"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Old_Qty"), "CStr", ""))

                    End With

                End While


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return list

        End Function

        Public Shared Function UploadGetNewSKULevelData(ByVal pPOCreationUploadID As Integer) As ArrayList

            Dim sql As String = "PO_Creation_Upload_Get_SKU_Level_Data_To_Be_Added"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim list As New ArrayList
            Dim colDelim As String = "[COLDELIM]"

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = pPOCreationUploadID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 1800
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()

                    With reader

                        list.Add(DataHelper.SmartValue(.Item("SKU"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("UPC"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Ordered_Qty"), "CStr", "") & colDelim & Math.Round(DataHelper.SmartValue(.Item("Unit_Cost"), "CDbl", 0), 2) & colDelim & DataHelper.SmartValue(.Item("Inner_Pack"), "CStr", "") & colDelim & DataHelper.SmartValue(.Item("Master_Pack"), "CStr", ""))


                    End With

                End While


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return list

        End Function

    End Class
End Namespace