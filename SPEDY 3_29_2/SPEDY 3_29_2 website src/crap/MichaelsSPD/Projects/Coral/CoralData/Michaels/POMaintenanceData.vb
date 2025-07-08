Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

    Public Class POMaintenanceData

        Public Shared Sub SaveRecord(ByRef objRec As POMaintenanceRecord, ByVal UserID As String, Optional ByVal HydrateRecord As Hydrate = POMaintenanceData.Hydrate.None)
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

        Public Shared Sub UpdateCache(ByVal objRecord As POMaintenanceRecord, ByVal userID As Integer)
            Dim sql As String = "PO_Maintenance_CACHE_Update"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = objRecord.ID
                reader.Command.Parameters.Add("@Is_Detail_Valid", SqlDbType.Bit).Value = objRecord.IsDetailValid
                reader.Command.Parameters.Add("@Not_Before", SqlDbType.DateTime).Value = objRecord.NotBefore
                reader.Command.Parameters.Add("@Not_After", SqlDbType.DateTime).Value = objRecord.NotAfter
                reader.Command.Parameters.Add("@Estimated_In_Stock_Date", SqlDbType.DateTime).Value = objRecord.EstimatedInStockDate
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Command.ExecuteNonQuery()

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

        End Sub

        Public Shared Sub UpdateRecordBySystem(ByRef objRec As POMaintenanceRecord, Optional ByVal HydrateRecord As Hydrate = POMaintenanceData.Hydrate.None)

            Try

                Dim recordID As Integer = _UpdateRecordBySystem(objRec)

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

        Private Shared Function _SaveRecord(ByVal objRecord As POMaintenanceRecord, ByVal UserID As String) As Long

            Dim recordID As Integer = -1
            Dim sql As String = "PO_Maintenance_InsertUpdate"
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

                cmd.Parameters.Add("@PO_Number", SqlDbType.BigInt).Value = objRecord.PONumber
                cmd.Parameters.Add("@Batch_Number", SqlDbType.VarChar).Value = objRecord.BatchNumber
                cmd.Parameters.Add("@PO_Construct_ID", SqlDbType.TinyInt).Value = objRecord.POConstructID
                cmd.Parameters.Add("@Batch_Type", SqlDbType.Char).Value = objRecord.BatchType
                cmd.Parameters.Add("@PO_Status_ID", SqlDbType.TinyInt).Value = objRecord.POStatusID
                cmd.Parameters.Add("@Workflow_Stage_ID", SqlDbType.Int).Value = objRecord.WorkflowStageID
                cmd.Parameters.Add("@Vendor_Name", SqlDbType.VarChar).Value = objRecord.VendorName
                cmd.Parameters.Add("@Vendor_Number", SqlDbType.BigInt).Value = objRecord.VendorNumber
                cmd.Parameters.Add("@Basic_Seasonal", SqlDbType.Char).Value = objRecord.BasicSeasonal
                cmd.Parameters.Add("@Workflow_Department_ID", SqlDbType.Int).Value = objRecord.WorkflowDepartmentID
                cmd.Parameters.Add("@PO_Department_ID", SqlDbType.Int).Value = objRecord.PODepartmentID
                cmd.Parameters.Add("@PO_Class", SqlDbType.Int).Value = objRecord.POClass
                cmd.Parameters.Add("@PO_Subclass", SqlDbType.Int).Value = objRecord.POSubclass
                cmd.Parameters.Add("@Approver_User_ID", SqlDbType.Int).Value = objRecord.ApproverUserID
                cmd.Parameters.Add("@Initiator_Role_ID", SqlDbType.Int).Value = objRecord.InitiatorRoleID
                cmd.Parameters.Add("@PO_Allocation_Event_ID", SqlDbType.Int).Value = objRecord.POAllocationEventID
                cmd.Parameters.Add("@PO_Seasonal_Symbol_ID", SqlDbType.Int).Value = objRecord.POSeasonalSymbolID
                cmd.Parameters.Add("@Event_Year", SqlDbType.Int).Value = objRecord.EventYear
                cmd.Parameters.Add("@Ship_Point_Description", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.ShipPointDescription, True)
                cmd.Parameters.Add("@Ship_Point_Code", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.ShipPointCode, True)
                cmd.Parameters.Add("@POG_Number", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.POGNumber, True)
                cmd.Parameters.Add("@POG_Start_Date", SqlDbType.DateTime).Value = DataHelper.SmartValuesDBNull(objRecord.POGStartDate, True)
                cmd.Parameters.Add("@POG_End_Date", SqlDbType.DateTime).Value = DataHelper.SmartValuesDBNull(objRecord.POGEndDate, True)
                cmd.Parameters.Add("@PO_Special_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.POSpecialID, "CInt", True)
                cmd.Parameters.Add("@Payment_Terms_ID", SqlDbType.Int).Value = objRecord.PaymentTermsID
                cmd.Parameters.Add("@Freight_Terms_ID", SqlDbType.Int).Value = objRecord.FreightTermsID
                cmd.Parameters.Add("@Internal_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.InternalComment, True)
                cmd.Parameters.Add("@External_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.ExternalComment, True)
                cmd.Parameters.Add("@Generated_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.Generatedcomment, True)
                cmd.Parameters.Add("@Is_Header_Valid", SqlDbType.Bit).Value = objRecord.IsHeaderValid
                cmd.Parameters.Add("@Is_Detail_Valid", SqlDbType.Bit).Value = objRecord.IsDetailValid
                cmd.Parameters.Add("@Is_Alloc_Dirty", SqlDbType.Bit).Value = objRecord.IsAllocDirty
                cmd.Parameters.Add("@Enabled", SqlDbType.Bit).Value = objRecord.Enabled
                cmd.Parameters.Add("@PO_Location_ID", SqlDbType.Int).Value = objRecord.POLocationID
                cmd.Parameters.Add("@External_Reference_ID", SqlDbType.VarChar).Value = objRecord.ExternalReferenceID
                cmd.Parameters.Add("@Written_Date", SqlDbType.DateTime).Value = objRecord.WrittenDate
                cmd.Parameters.Add("@Not_Before", SqlDbType.DateTime).Value = objRecord.NotBefore
                cmd.Parameters.Add("@Not_After", SqlDbType.DateTime).Value = objRecord.NotAfter
                cmd.Parameters.Add("@Estimated_In_Stock_Date", SqlDbType.DateTime).Value = objRecord.EstimatedInStockDate
                cmd.Parameters.Add("@User_ID", SqlDbType.NVarChar).Value = UserID
                cmd.Parameters.Add("@Season_Code", SqlDbType.Char).Value = objRecord.SeasonCode

                cmd.CommandText = sql
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

        Private Shared Function _UpdateRecordBySystem(ByVal objRecord As POMaintenanceRecord) As Long

            Dim recordID As Integer = -1
            Dim sql As String = "PO_Maintenance_Update_By_System"
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

                cmd.Parameters.Add("@PO_Number", SqlDbType.BigInt).Value = objRecord.PONumber
                cmd.Parameters.Add("@Batch_Number", SqlDbType.VarChar).Value = objRecord.BatchNumber
                cmd.Parameters.Add("@PO_Construct_ID", SqlDbType.TinyInt).Value = objRecord.POConstructID
                cmd.Parameters.Add("@Batch_Type", SqlDbType.Char).Value = objRecord.BatchType
                cmd.Parameters.Add("@PO_Status_ID", SqlDbType.TinyInt).Value = objRecord.POStatusID
                cmd.Parameters.Add("@Workflow_Stage_ID", SqlDbType.Int).Value = objRecord.WorkflowStageID
                cmd.Parameters.Add("@Vendor_Name", SqlDbType.VarChar).Value = objRecord.VendorName
                cmd.Parameters.Add("@Vendor_Number", SqlDbType.BigInt).Value = objRecord.VendorNumber
                cmd.Parameters.Add("@Basic_Seasonal", SqlDbType.Char).Value = objRecord.BasicSeasonal
                cmd.Parameters.Add("@Workflow_Department_ID", SqlDbType.Int).Value = objRecord.WorkflowDepartmentID
                cmd.Parameters.Add("@PO_Department_ID", SqlDbType.Int).Value = objRecord.PODepartmentID
                cmd.Parameters.Add("@PO_Class", SqlDbType.Int).Value = objRecord.POClass
                cmd.Parameters.Add("@PO_Subclass", SqlDbType.Int).Value = objRecord.POSubclass
                cmd.Parameters.Add("@Approver_User_ID", SqlDbType.Int).Value = objRecord.ApproverUserID
                cmd.Parameters.Add("@Initiator_Role_ID", SqlDbType.Int).Value = objRecord.InitiatorRoleID
                cmd.Parameters.Add("@PO_Allocation_Event_ID", SqlDbType.Int).Value = objRecord.POAllocationEventID
                cmd.Parameters.Add("@PO_Seasonal_Symbol_ID", SqlDbType.Int).Value = objRecord.POSeasonalSymbolID
                cmd.Parameters.Add("@Event_Year", SqlDbType.Int).Value = objRecord.EventYear
                cmd.Parameters.Add("@Ship_Point_Description", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.ShipPointDescription, True)
                cmd.Parameters.Add("@Ship_Point_Code", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.ShipPointCode, True)
                cmd.Parameters.Add("@POG_Number", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.POGNumber, True)
                cmd.Parameters.Add("@POG_Start_Date", SqlDbType.DateTime).Value = DataHelper.SmartValuesDBNull(objRecord.POGStartDate, True)
                cmd.Parameters.Add("@POG_End_Date", SqlDbType.DateTime).Value = DataHelper.SmartValuesDBNull(objRecord.POGEndDate, True)
                cmd.Parameters.Add("@PO_Special_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.POSpecialID, "CInt", True)
                cmd.Parameters.Add("@Payment_Terms_ID", SqlDbType.Int).Value = objRecord.PaymentTermsID
                cmd.Parameters.Add("@Freight_Terms_ID", SqlDbType.Int).Value = objRecord.FreightTermsID
                cmd.Parameters.Add("@Internal_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.InternalComment, True)
                cmd.Parameters.Add("@External_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.ExternalComment, True)
                cmd.Parameters.Add("@Generated_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.Generatedcomment, True)
                cmd.Parameters.Add("@Is_Header_Valid", SqlDbType.Bit).Value = objRecord.IsHeaderValid
                cmd.Parameters.Add("@Is_Detail_Valid", SqlDbType.Bit).Value = objRecord.IsDetailValid
                cmd.Parameters.Add("@Is_Validating", SqlDbType.Bit).Value = objRecord.IsValidating
                cmd.Parameters.Add("@Validating_Job_ID", SqlDbType.BigInt).Value = objRecord.ValidatingJobID
                cmd.Parameters.Add("@Enabled", SqlDbType.Bit).Value = objRecord.Enabled
                cmd.Parameters.Add("@PO_Location_ID", SqlDbType.Int).Value = objRecord.POLocationID
                cmd.Parameters.Add("@External_Reference_ID", SqlDbType.VarChar).Value = objRecord.ExternalReferenceID
                cmd.Parameters.Add("@Written_Date", SqlDbType.DateTime).Value = objRecord.WrittenDate
                cmd.Parameters.Add("@Not_Before", SqlDbType.DateTime).Value = objRecord.NotBefore
                cmd.Parameters.Add("@Not_After", SqlDbType.DateTime).Value = objRecord.NotAfter
                cmd.Parameters.Add("@Estimated_In_Stock_Date", SqlDbType.DateTime).Value = objRecord.EstimatedInStockDate
                cmd.Parameters.Add("@Season_Code", SqlDbType.Char).Value = objRecord.SeasonCode

                cmd.CommandText = sql
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

        Public Shared Function GetCACHERecord(ByVal ID As Long, ByVal UserID As Integer) As POMaintenanceCacheRecord

            Dim objRecord As New POMaintenanceCacheRecord()
            Dim sql As String = "PO_Maintenance_CACHE_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = ID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.ActiveUserID = DataHelper.SmartValuesDBNull(.Item("Active_User_ID"))
                        objRecord.WorkflowDepartmentID = DataHelper.SmartValuesDBNull(.Item("Workflow_Department_ID"))
                        objRecord.PODepartmentID = DataHelper.SmartValuesDBNull(.Item("PO_Department_ID"))
                        objRecord.POClass = DataHelper.SmartValuesDBNull(.Item("PO_Class"))
                        objRecord.POSubclass = DataHelper.SmartValuesDBNull(.Item("PO_Subclass"))
                        objRecord.IsDetailValid = DataHelper.SmartValuesDBNull(.Item("Is_Detail_Valid"))
                        objRecord.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        objRecord.ExternalReferenceID = DataHelper.SmartValuesDBNull(.Item("External_Reference_ID"))
                        objRecord.WrittenDate = DataHelper.SmartValuesDBNull(.Item("Written_Date"))
                        objRecord.NotBefore = DataHelper.SmartValuesDBNull(.Item("Not_Before"))
                        objRecord.NotAfter = DataHelper.SmartValuesDBNull(.Item("Not_After"))
                        objRecord.EstimatedInStockDate = DataHelper.SmartValuesDBNull(.Item("Estimated_In_Stock_Date"))
                        objRecord.POClass = DataHelper.SmartValuesDBNull(.Item("PO_Class"))
                        objRecord.POSubclass = DataHelper.SmartValuesDBNull(.Item("PO_Subclass"))
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

        Public Shared Function GetRecord(ByVal ID As Long) As POMaintenanceRecord

            Dim objRecord As New POMaintenanceRecord()
            Dim sql As String = "PO_Maintenance_Get_By_ID"
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
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.PONumber = DataHelper.SmartValuesDBNull(.Item("PO_Number"))
                        objRecord.BatchNumber = DataHelper.SmartValuesDBNull(.Item("Batch_Number"))
                        objRecord.POConstructID = DataHelper.SmartValuesDBNull(.Item("PO_Construct_ID"))
                        objRecord.BatchType = DataHelper.SmartValuesDBNull(.Item("Batch_Type"))
                        objRecord.POStatusID = DataHelper.SmartValuesDBNull(.Item("PO_Status_ID"))
                        objRecord.WorkflowStageID = DataHelper.SmartValuesDBNull(.Item("Workflow_Stage_ID"))
                        objRecord.VendorName = DataHelper.SmartValuesDBNull(.Item("Vendor_Name"))
                        objRecord.VendorNumber = DataHelper.SmartValuesDBNull(.Item("Vendor_Number"))
                        objRecord.BasicSeasonal = DataHelper.SmartValuesDBNull(.Item("Basic_Seasonal"))
                        objRecord.WorkflowDepartmentID = DataHelper.SmartValuesDBNull(.Item("Workflow_Department_ID"))
                        objRecord.PODepartmentID = DataHelper.SmartValuesDBNull(.Item("PO_Department_ID"))
                        objRecord.POClass = DataHelper.SmartValuesDBNull(.Item("PO_Class"))
                        objRecord.POSubclass = DataHelper.SmartValuesDBNull(.Item("PO_Subclass"))
                        objRecord.ApproverUserID = DataHelper.SmartValuesDBNull(.Item("Approver_User_ID"))
                        objRecord.InitiatorRoleID = DataHelper.SmartValuesDBNull(.Item("Initiator_Role_ID"))
                        objRecord.POAllocationEventID = DataHelper.SmartValuesDBNull(.Item("PO_Allocation_Event_ID"))
                        objRecord.POSeasonalSymbolID = DataHelper.SmartValuesDBNull(.Item("PO_Seasonal_Symbol_ID"))
                        objRecord.EventYear = DataHelper.SmartValuesDBNull(.Item("Event_Year"))
                        objRecord.ShipPointDescription = DataHelper.SmartValuesDBNull(.Item("Ship_Point_Description"))
                        objRecord.ShipPointCode = DataHelper.SmartValuesDBNull(.Item("Ship_Point_Code"))
                        objRecord.POGNumber = DataHelper.SmartValuesDBNull(.Item("POG_Number"))
                        objRecord.POGStartDate = DataHelper.SmartValuesDBNull(.Item("POG_Start_Date"))
                        objRecord.POGEndDate = DataHelper.SmartValuesDBNull(.Item("POG_End_Date"))
                        objRecord.POSpecialID = DataHelper.SmartValuesDBNull(.Item("PO_Special_ID"))
                        objRecord.PaymentTermsID = DataHelper.SmartValuesDBNull(.Item("Payment_Terms_ID"))
                        objRecord.FreightTermsID = DataHelper.SmartValuesDBNull(.Item("Freight_Terms_ID"))
                        objRecord.InternalComment = DataHelper.SmartValuesDBNull(.Item("Internal_Comment"))
                        objRecord.ExternalComment = DataHelper.SmartValuesDBNull(.Item("External_Comment"))
                        objRecord.Generatedcomment = DataHelper.SmartValuesDBNull(.Item("Generated_Comment"))
                        objRecord.IsAllocDirty = DataHelper.SmartValuesDBNull(.Item("Is_Alloc_Dirty"))
                        objRecord.IsPlannerDirty = DataHelper.SmartValuesDBNull(.Item("Is_Planner_Dirty"))
                        objRecord.IsDateWarning = DataHelper.SmartValuesDBNull(.Item("Is_Date_Warning"))
                        objRecord.IsHeaderValid = DataHelper.SmartValuesDBNull(.Item("Is_Header_Valid"))
                        objRecord.IsDetailValid = DataHelper.SmartValuesDBNull(.Item("Is_Detail_Valid"))
                        objRecord.IsValidating = DataHelper.SmartValuesDBNull(.Item("Is_Validating"))
                        objRecord.IsUnrevisable = DataHelper.SmartValues(.Item("Is_Unrevisable"), "Boolean", False, False)
                        objRecord.ValidatingJobID = DataHelper.SmartValuesDBNull(.Item("Validating_Job_ID"))
                        objRecord.Enabled = DataHelper.SmartValuesDBNull(.Item("Enabled"))
                        objRecord.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        objRecord.ExternalReferenceID = DataHelper.SmartValuesDBNull(.Item("External_Reference_ID"))
                        objRecord.WrittenDate = DataHelper.SmartValuesDBNull(.Item("Written_Date"))
                        objRecord.NotBefore = DataHelper.SmartValuesDBNull(.Item("Not_Before"))
                        objRecord.NotAfter = DataHelper.SmartValuesDBNull(.Item("Not_After"))
                        objRecord.EstimatedInStockDate = DataHelper.SmartValuesDBNull(.Item("Estimated_In_Stock_Date"))
                        objRecord.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        objRecord.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        objRecord.CreatedUserName = DataHelper.SmartValuesDBNull(.Item("Created_User_Name"))
                        objRecord.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        objRecord.ModifiedUserName = DataHelper.SmartValuesDBNull(.Item("Modified_User_Name"))
                        objRecord.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        objRecord.SeasonCode = DataHelper.SmartValuesDBNull(.Item("Season_Code"))
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

        Public Shared Function GetRevisionRecord(ByVal poMaintenanceID As Long?, ByVal revisionNumber As Double) As POMaintenanceRecord
            Dim objRecord As New POMaintenanceRecord()
            Dim sql As String = "PO_History_Maintenance_Get_Revision"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                'Separate out Major and Minor Revision numbers
                Dim splitRevisionNumbers As String() = revisionNumber.ToString("0.0").Split(".")
                Dim majorRevisionNumber As String = splitRevisionNumbers(0)
                Dim minorRevisionNumber As String = splitRevisionNumbers(1)

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.Command.Parameters.Add("@Major_Revision_Number", SqlDbType.Int).Value = majorRevisionNumber
                reader.Command.Parameters.Add("@Minor_Revision_Number", SqlDbType.Int).Value = minorRevisionNumber
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.PONumber = DataHelper.SmartValuesDBNull(.Item("PO_Number"))
                        objRecord.BatchNumber = DataHelper.SmartValuesDBNull(.Item("Batch_Number"))
                        objRecord.POConstructID = DataHelper.SmartValuesDBNull(.Item("PO_Construct_ID"))
                        objRecord.BatchType = DataHelper.SmartValuesDBNull(.Item("Batch_Type"))
                        objRecord.POStatusID = DataHelper.SmartValuesDBNull(.Item("PO_Status_ID"))
                        objRecord.WorkflowStageID = DataHelper.SmartValuesDBNull(.Item("Workflow_Stage_ID"))
                        objRecord.VendorName = DataHelper.SmartValuesDBNull(.Item("Vendor_Name"))
                        objRecord.VendorNumber = DataHelper.SmartValuesDBNull(.Item("Vendor_Number"))
                        objRecord.BasicSeasonal = DataHelper.SmartValuesDBNull(.Item("Basic_Seasonal"))
                        objRecord.WorkflowDepartmentID = DataHelper.SmartValuesDBNull(.Item("Workflow_Department_ID"))
                        objRecord.PODepartmentID = DataHelper.SmartValuesDBNull(.Item("PO_Department_ID"))
                        objRecord.POClass = DataHelper.SmartValuesDBNull(.Item("PO_Class"))
                        objRecord.POSubclass = DataHelper.SmartValuesDBNull(.Item("PO_Subclass"))
                        objRecord.ApproverUserID = DataHelper.SmartValuesDBNull(.Item("Approver_User_ID"))
                        objRecord.InitiatorRoleID = DataHelper.SmartValuesDBNull(.Item("Initiator_Role_ID"))
                        objRecord.POAllocationEventID = DataHelper.SmartValuesDBNull(.Item("PO_Allocation_Event_ID"))
                        objRecord.POSeasonalSymbolID = DataHelper.SmartValuesDBNull(.Item("PO_Seasonal_Symbol_ID"))
                        objRecord.EventYear = DataHelper.SmartValuesDBNull(.Item("Event_Year"))
                        objRecord.ShipPointDescription = DataHelper.SmartValuesDBNull(.Item("Ship_Point_Description"))
                        objRecord.ShipPointCode = DataHelper.SmartValuesDBNull(.Item("Ship_Point_Code"))
                        objRecord.POGNumber = DataHelper.SmartValuesDBNull(.Item("POG_Number"))
                        objRecord.POGStartDate = DataHelper.SmartValuesDBNull(.Item("POG_Start_Date"))
                        objRecord.POGEndDate = DataHelper.SmartValuesDBNull(.Item("POG_End_Date"))
                        objRecord.POSpecialID = DataHelper.SmartValuesDBNull(.Item("PO_Special_ID"))
                        objRecord.PaymentTermsID = DataHelper.SmartValuesDBNull(.Item("Payment_Terms_ID"))
                        objRecord.FreightTermsID = DataHelper.SmartValuesDBNull(.Item("Freight_Terms_ID"))
                        objRecord.InternalComment = DataHelper.SmartValuesDBNull(.Item("Internal_Comment"))
                        objRecord.ExternalComment = DataHelper.SmartValuesDBNull(.Item("External_Comment"))
                        objRecord.GeneratedComment = DataHelper.SmartValuesDBNull(.Item("Generated_Comment"))
                        objRecord.IsHeaderValid = DataHelper.SmartValuesDBNull(.Item("Is_Header_Valid"))
                        objRecord.IsDetailValid = DataHelper.SmartValuesDBNull(.Item("Is_Detail_Valid"))
                        objRecord.IsUnrevisable = True ' Historical Revisions are never Revisable
                        objRecord.Enabled = DataHelper.SmartValuesDBNull(.Item("Enabled"))
                        objRecord.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        objRecord.ExternalReferenceID = DataHelper.SmartValuesDBNull(.Item("External_Reference_ID"))
                        objRecord.WrittenDate = DataHelper.SmartValuesDBNull(.Item("Written_Date"))
                        objRecord.NotBefore = DataHelper.SmartValuesDBNull(.Item("Not_Before"))
                        objRecord.NotAfter = DataHelper.SmartValuesDBNull(.Item("Not_After"))
                        objRecord.EstimatedInStockDate = DataHelper.SmartValuesDBNull(.Item("Estimated_In_Stock_Date"))
                        objRecord.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        objRecord.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        objRecord.CreatedUserName = DataHelper.SmartValuesDBNull(.Item("Created_User_Name"))
                        objRecord.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        objRecord.ModifiedUserName = DataHelper.SmartValuesDBNull(.Item("Modified_User_Name"))
                        objRecord.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        objRecord.SeasonCode = DataHelper.SmartValuesDBNull(.Item("Season_Code"))

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

        Public Shared Sub CreateDetailCache(ByVal poMaintenanceID As Long?, ByVal userID As Integer)
            Dim sql As String = "PO_Maintenance_Details_Create_Cache"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                reader.Command.CommandTimeout = 4500
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Command.ExecuteNonQuery()

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
        End Sub

        Public Shared Sub CreateRevisionDetailCache(ByVal poMaintenanceID As Long?, ByVal userID As Integer, ByVal revisionNumber As Double)
            Dim sql As String = "PO_History_Maintenance_Details_Create_Cache"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                'Separate out Major and Minor Revision numbers
                Dim splitRevisionNumbers As String() = revisionNumber.ToString("0.0").Split(".")
                Dim majorRevisionNumber As String = splitRevisionNumbers(0)
                Dim minorRevisionNumber As String = splitRevisionNumbers(1)

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
                reader.Command.Parameters.Add("@Major_Revision_Number", SqlDbType.Int).Value = majorRevisionNumber
                reader.Command.Parameters.Add("@Minor_Revision_Number", SqlDbType.Int).Value = minorRevisionNumber

                reader.Command.CommandTimeout = 4500
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Command.ExecuteNonQuery()

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
        End Sub

        Public Shared Sub CreateRevision(ByVal poMaintenanceID As Long?)
            Dim sql As String = "PO_Maintenance_Create_Revision"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID

                cmd.CommandText = sql
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

        Public Shared Sub DeleteValidationMessages(ByVal poMaintenanceID As Long?, ByVal sku As String)
            Dim sql As String = "PO_Maintenance_Validation_Message_Delete_By_POID_SKU"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku

                cmd.CommandText = sql
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

        Public Shared Function DetectChange(ByVal poMaintenanceID As Long?) As Boolean
            Dim isChanged As Boolean = False

            Dim sql As String = "PO_Maintenance_Detect_Change"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        isChanged = DataHelper.SmartValuesDBNull(.Item(0), True)
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

            Return isChanged
        End Function

        Public Shared Function IsEventSeasonal(ByVal EventID As Integer) As Boolean?

            Dim seasonalFlag As Boolean?

            Dim sql As String = "PO_Allocation_Event_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = EventID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        seasonalFlag = IIf(DataHelper.SmartValuesDBNull(.Item("WH_Type")).ToString = "S", True, False)

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

            Return seasonalFlag

        End Function

        Public Shared Function GetCurrentRevision(ByVal poMaintenanceID As Long?) As Double
            Dim revisionNumber As Double = 0.0

            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                reader.CommandText = "Select CAST(dbo.udf_PO_Maintenance_GetCurrentMajorRevisionNumber(" & poMaintenanceID.ToString & ") as varchar(10)) + '.' + Cast(dbo.udf_PO_Maintenance_GetCurrentMinorRevisionNumber(" & poMaintenanceID.ToString & ") as varchar(10))"
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    revisionNumber = DataHelper.SmartValue(reader.Item(0), "CDbl", 0.0)
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

            Return revisionNumber
        End Function

        Public Shared Function GetDeletedWorkflowStageID() As Integer
            Dim workflowStageID As Integer = 0

            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                reader.CommandText = "select dbo.udf_PO_Maintenance_GetDeletedWorkflowStage()"
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    workflowStageID = DataHelper.SmartValue(reader.Item(0), "CInt", 0)
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

            Return workflowStageID
        End Function

        Public Shared Function GetFreightTermByID(ByVal ID As Integer) As String
            Dim freightTerm As String = ""

            Dim sql As String = "PO_Freight_Terms_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = ID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        freightTerm = DataHelper.SmartValuesDBNull(.Item("Name"))

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

            Return freightTerm

        End Function

        Public Shared Function GetDisApprovalStages(ByVal poID As Long) As List(Of WorkflowStage)

            Dim stages As List(Of WorkflowStage) = New List(Of WorkflowStage)

            Dim sql As String = "PO_Maintenance_Workflow_History_GetStages_By_POID"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_ID", SqlDbType.BigInt).Value = poID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        Dim objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage
                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "integer", False)
                        objRecord.StageName = DataHelper.SmartValues(.Item("Stage_Name"), "string", False)
                        stages.Add(objRecord)
                    End With
                Loop

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

            Return stages
        End Function

        Public Shared Function GetWorkflowHistoryByPOID(ByVal poID As Long) As DataTable

            Dim sql As String = "PO_Maintenance_Workflow_History_Get_By_POID"
            Dim command As DBCommand
            Dim param As SqlParameter
            Dim table As DataTable
            Dim adapter As SqlDataAdapter
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "PO_ID"
                param.Value = poID
                command.Parameters.Add(param)
                param = Nothing

                adapter = New SqlDataAdapter(command.CommandObject)
                table = New DataTable
                adapter.Fill(table)
                Return table
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

        End Function

        Public Shared Function GetInitiatorRoleByUserID(ByVal UserID As Integer) As Integer
            Dim initiatorRoleID As Integer = 0

            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                reader.CommandText = "select dbo.udf_PO_Maintenance_GetInitialRoleID(@User_ID)"
                reader.CommandType = CommandType.Text
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                reader.Open()
                If reader.Read() Then
                    initiatorRoleID = DataHelper.SmartValue(reader.Item(0), "CInt", 0)
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

            Return initiatorRoleID
        End Function

        Public Shared Function GetInitialWorkflowStageID(ByVal initiatorRoleID As Long) As Integer
            Dim workflowStageID As Integer = 0

            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                reader.CommandText = "select dbo.udf_PO_Maintenance_GetInitialWorkflowStageID(@Initiator_Role_ID)"
                reader.CommandType = CommandType.Text
                cmd.Parameters.Add("@Initiator_Role_ID", SqlDbType.Int).Value = initiatorRoleID
                reader.Open()
                If reader.Read() Then
                    workflowStageID = DataHelper.SmartValue(reader.Item(0), "CInt", 0)
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

            Return workflowStageID
        End Function

        Public Shared Function GetIsPOProcessing(ByVal poMaintenanceID As Long) As Boolean
            Dim isPOProcessing As Boolean = False

            Dim sql As String = "PO_Maintenance_PROCESSING_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        isPOProcessing = DataHelper.SmartValues(.Item("Is_Processing"), "Boolean", True)
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

            Return isPOProcessing
        End Function

        Public Shared Function GetSKUAndStoreValidity(ByVal poMaintenanceID As Long?) As Boolean?

            Dim isSKuStoreValid As Boolean?

            Dim sql As String = "PO_Maintenance_Get_SKUs_Stores_Valid"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        isSKuStoreValid = DataHelper.SmartValues(.Item("Is_SKUs_Stores_Valid"), "Boolean", True)
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

            Return isSKuStoreValid
        End Function

        Public Shared Function GetValidationMessagesByPOID(ByVal poMaintenanceID As Long?) As DataTable

            Dim validationMessages As New DataTable

            Dim sql As String = "PO_Maintenance_Validation_Message_Get_By_POID"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID

                adapter = New SqlDataAdapter(command.CommandObject)
                adapter.Fill(validationMessages)
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return validationMessages
        End Function

        Public Shared Function GetSummarizedValidationMessagesByPOID(ByVal poMaintenanceID As Long?) As DataTable

            Dim validationMessages As New DataTable

            Dim sql As String = "PO_Maintenance_Validation_Summarized_Messages_Get_By_POID"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID

                adapter = New SqlDataAdapter(command.CommandObject)
                adapter.Fill(validationMessages)
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return validationMessages
        End Function

        Public Shared Function ValidationMessagesCountByPOID(ByVal poMaintenanceID As Long?, Optional ByVal severityType As Integer = -999) As Integer

            Dim validationMessages As Integer = 0

            Dim sql As String = "PO_Maintenance_Validation_Messages_Count_Get_By_POID"
            Dim command As DBCommand

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                command.Parameters.Add("@Severity_Type", SqlDbType.Int).Value = severityType

                validationMessages = DataHelper.SmartValue(command.CommandObject.ExecuteScalar(), "CInt", 0)

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return validationMessages

        End Function

        Public Shared Function GetValidationMessagesGetForStores(ByVal poMaintenanceID As Long?, ByVal sku As String) As DataTable

            Dim validationMessages As New DataTable

            Dim sql As String = "PO_Maintenance_Validation_Message_Get_For_Stores"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                command.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku

                adapter = New SqlDataAdapter(command.CommandObject)
                adapter.Fill(validationMessages)
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return validationMessages
        End Function

        Public Shared Sub MergeCache(ByVal poMaintenanceID As Long, ByVal userID As Integer)
            Dim sql As String = "PO_Maintenance_Details_Merge_Cache"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                cmd.CommandTimeout = 4500
                cmd.CommandText = sql
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

        Public Shared Function PublishPOMessage(ByVal poMaintenanceID As Long?) As Boolean

            Dim returnValue As Boolean = False

            Dim poRec As POMaintenanceRecord = GetRecord(poMaintenanceID)

            If poRec.BatchType = "W" Then
                returnValue = PublishPOMessageWarehouse(poMaintenanceID)
            ElseIf poRec.BatchType = "D" Then
                returnValue = PublishPOMessageDirect(poMaintenanceID)
            End If

            Return returnValue

        End Function

        Public Shared Function PublishPOMessageWarehouse(ByVal poMaintenanceID As Long?) As Boolean

            '**********************************************************************
            ' OT: The following had to be used as SQL Server was taking forever (hours)
            ' to simply concatenate the results into an xml string for very large POs.
            ' The selects would return back in 0 seconds but when concatenating, there
            ' would lie the problem.
            '**********************************************************************
            Dim returnValue As Boolean = False

            Dim message As New System.Text.StringBuilder()
            Dim SQLStr As String
            Dim cmd As SqlClient.SqlCommand
            Dim reader As SqlClient.SqlDataReader

            Using conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString)

                Try

                    conn.Open()

                    Dim ProcessTimeStamp As String
                    Dim SomethingChanged As Boolean = False
                    Dim CurMajorRevisionNumber As Integer
                    Dim CurMinorRevisionNumber As Integer

                    '**********************************************************************
                    ' Get Initial Data And MikData Header
                    '**********************************************************************
                    SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Step_1"

                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")

                    reader = cmd.ExecuteReader()

                    If reader.HasRows Then

                        reader.Read()
                        ProcessTimeStamp = DataHelper.SmartValue(reader.Item("ProcessTimeStamp"), "CStr", "")
                        SomethingChanged = DataHelper.SmartValue(reader.Item("SomethingChanged"), "CBool", True)
                        CurMajorRevisionNumber = DataHelper.SmartValue(reader.Item("CurMajorRevisionNumber"), "CInt", 0)
                        CurMinorRevisionNumber = DataHelper.SmartValue(reader.Item("CurMinorRevisionNumber"), "CInt", 0)
                        message.Append(DataHelper.SmartValue(reader.Item("MessageStr"), "CStr", ""))

                    End If
                    reader.Close()

                    '**********************************************************************
                    ' Build MikData Details SKU/LOC Level
                    '**********************************************************************

                    SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Step_2"

                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                    cmd.Parameters.Add("@CurMajorRevisionNumber", SqlDbType.Int).Value = DataHelper.SmartValueDB(CurMajorRevisionNumber, "CInt")
                    cmd.Parameters.Add("@CurMinorRevisionNumber", SqlDbType.Int).Value = DataHelper.SmartValueDB(CurMinorRevisionNumber, "CInt")

                    reader = cmd.ExecuteReader()

                    message.Append("<order_details>")
                    If reader.HasRows Then

                        SomethingChanged = True

                        message.Append("&lt;details&gt;")

                        Do While reader.Read()
                            message.Append(DataHelper.SmartValue(reader.Item("SKU_LOC"), "CStr", ""))
                        Loop

                        message.Append("&lt;/details&gt;")

                    End If
                    reader.Close()
                    message.Append("</order_details>")

                    '***********************************
                    ' Close MikData (Begins In Header)
                    '***********************************
                    message.Append("</mikData>")

                    '**********************************************************************
                    ' Close Message Wrapper And Store In DB
                    '**********************************************************************
                    message.Append("</mikMessage>")

                    If SomethingChanged Then

                        SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Step_3"

                        cmd = New SqlClient.SqlCommand(SQLStr, conn)
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.CommandTimeout = 1800

                        cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                        cmd.Parameters.Add("@Message", SqlDbType.VarChar).Value = message.ToString()

                        cmd.ExecuteNonQuery()

                        'This can be used to export to a file since management studio limits
                        'the amount of data that can be retrieved in the grid/text/file format
                        'Dim FILE_NAME As String = "C:\Users\oscar.treto\Desktop\File.txt"

                        'If System.IO.File.Exists(FILE_NAME) = True Then
                        '    Dim objWriter As New System.IO.StreamWriter(FILE_NAME)
                        '    objWriter.Write(message.ToString())
                        '    objWriter.Close()
                        'End If

                        returnValue = True

                    End If

                Catch ex As Exception

                    Logger.LogError(ex)
                    Throw ex

                Finally

                    If Not conn Is Nothing AndAlso conn.State = ConnectionState.Open Then
                        conn.Close()
                    End If

                End Try

            End Using

            message = Nothing

            Return returnValue

        End Function

        Public Shared Function PublishPOMessageDirect(ByVal poMaintenanceID As Long?) As Boolean

            '**********************************************************************
            ' OT: The following had to be used as SQL Server was taking forever (hours)
            ' to simply concatenate the results into an xml string for very large POs.
            ' The selects would return back in 0 seconds but when concatenating, there
            ' would lie the problem.
            '**********************************************************************
            Dim returnValue As Boolean = False

            Dim SQLStr As String
            Dim cmd As SqlClient.SqlCommand
            Dim reader As SqlClient.SqlDataReader
            Dim recordCount As Integer = 0

            Using conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString)

                Try

                    conn.Open()

                    Dim somethingChangedInHeader As Boolean = False
                    Dim curMajorRevisionNumber As Integer = 0
                    Dim curMinorRevisionNumber As Integer = 0

                    '*********************************
                    ' Get Most Current Revision #s
                    '*********************************
                    SQLStr = "Select dbo.udf_PO_Maintenance_GetCurrentMajorRevisionNumber(@PO_Maintenance_ID) As Cur_Major_Revision_Number, dbo.udf_PO_Maintenance_GetCurrentMinorRevisionNumber(@PO_Maintenance_ID) As Cur_Minor_Revision_Number"

                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.Text
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")

                    reader = cmd.ExecuteReader()

                    If reader.HasRows Then

                        Do While reader.Read()
                            curMajorRevisionNumber = DataHelper.SmartValue(reader.Item("Cur_Major_Revision_Number"), "CInt", 0)
                            curMinorRevisionNumber = DataHelper.SmartValue(reader.Item("Cur_Minor_Revision_Number"), "CInt", 0)
                        Loop

                    End If
                    reader.Close()


                    '*********************************
                    ' Get SKUs To Publish
                    '*********************************
                    Dim SKUs As New ArrayList()

                    SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Direct_Get_SKUs"

                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                    cmd.Parameters.Add("@Cur_Major_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMajorRevisionNumber, "CInt")
                    cmd.Parameters.Add("@Cur_Minor_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMinorRevisionNumber, "CInt")

                    reader = cmd.ExecuteReader()

                    If reader.HasRows Then

                        Do While reader.Read()
                            SKUs.Add(DataHelper.SmartValue(reader.Item("Michaels_SKU"), "CStr", ""))
                        Loop

                    End If
                    reader.Close()

                    '**************************************************************************************
                    ' Update PO_Maintenance record with Try number and Confirmation Count
                    '**************************************************************************************
                    recordCount = IIf(SKUs.Count = 0, 1, SKUs.Count)
                    SQLStr = "PO_Maintenance_Update_Confirmation_Info"
                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                    cmd.Parameters.Add("@Outstanding_Confirmations", SqlDbType.Int).Value = DataHelper.SmartValueDB(recordCount, "CInt")
                    cmd.ExecuteNonQuery()

                    '********************************************************
                    ' Process Confirmation Messages based on SKU count
                    '********************************************************
                    If SKUs.Count = 0 Then

                        '**********************************************************************
                        ' Send Header Only Without SKU Info
                        '**********************************************************************

                        Dim message As New Text.StringBuilder()

                        '**********************************************************************
                        ' Build Message Data And MikData Header
                        '**********************************************************************
                        SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Direct_Get_MikData_Header"

                        cmd = New SqlClient.SqlCommand(SQLStr, conn)
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.CommandTimeout = 1800

                        cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                        cmd.Parameters.Add("@Cur_Major_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMajorRevisionNumber, "CInt")
                        cmd.Parameters.Add("@Cur_Minor_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMinorRevisionNumber, "CInt")

                        reader = cmd.ExecuteReader()

                        If reader.HasRows Then

                            reader.Read()

                            somethingChangedInHeader = DataHelper.SmartValue(reader.Item("SomethingChanged"), "CBool", False)
                            message.Append(DataHelper.SmartValue(reader.Item("MessageStr"), "CStr", ""))

                        End If
                        reader.Close()

                        message.Append("</mikData>")
                        message.Append("</mikMessage>")

                        'Something To Send
                        If somethingChangedInHeader Then

                            '****************************************
                            ' Store In DB
                            '****************************************
                            SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Direct_Save_In_Queue"

                            cmd = New SqlClient.SqlCommand(SQLStr, conn)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.CommandTimeout = 1800

                            cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                            cmd.Parameters.Add("@Message", SqlDbType.VarChar).Value = message.ToString()

                            cmd.ExecuteNonQuery()

                            'This can be used to export to a file since management studio limits
                            'the amount of data that can be retrieved in the grid/text/file format
                            'System.IO.File.WriteAllText("C:\Users\oscar.treto\Desktop\Debugging\" & poMaintenanceID & ".txt", message.ToString())

                        End If

                    Else


                        '**********************************************************************
                        ' Send A Message For Each SKU In This Location
                        '**********************************************************************
                        For Each CurrentSKU As String In SKUs

                            'Create The Message For This External Ref/Item
                            Dim message As New Text.StringBuilder()
                            Dim mikMessageHeader As String = ""
                            Dim mikDataHeader As String = ""

                            '**********************************************************************
                            ' Get Message Header And MikData Header
                            '**********************************************************************
                            SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Direct_Get_MikData_Header"

                            cmd = New SqlClient.SqlCommand(SQLStr, conn)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.CommandTimeout = 1800

                            cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                            cmd.Parameters.Add("@Cur_Major_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMajorRevisionNumber, "CInt")
                            cmd.Parameters.Add("@Cur_Minor_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMinorRevisionNumber, "CInt")

                            reader = cmd.ExecuteReader()

                            If reader.HasRows Then

                                reader.Read()
                                mikMessageHeader = DataHelper.SmartValue(reader.Item("MessageStr"), "CStr", "")

                            End If
                            reader.Close()

                            'Append Record Count To The Header
                            mikDataHeader += "<record_count>" & recordCount.ToString & "</record_count>"

                            message.Append(mikMessageHeader)
                            message.Append(mikDataHeader)

                            '***********************************
                            ' Build Details (Stores)
                            '***********************************

                            SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Direct_Get_SKU_LOC"

                            cmd = New SqlClient.SqlCommand(SQLStr, conn)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.CommandTimeout = 1800

                            cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                            cmd.Parameters.Add("@Cur_Major_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMajorRevisionNumber, "CInt")
                            cmd.Parameters.Add("@Cur_Minor_Revision_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curMinorRevisionNumber, "CInt")
                            cmd.Parameters.Add("@SKU", SqlDbType.VarChar).Value = DataHelper.SmartValueDB(CurrentSKU, "CStr")

                            reader = cmd.ExecuteReader()

                            message.Append("<order_details>")

                            If reader.HasRows Then
                                message.Append("&lt;details&gt;")

                                Do While reader.Read()
                                    message.Append(DataHelper.SmartValue(reader.Item("SKU_LOC"), "CStr", ""))
                                Loop

                                message.Append("&lt;/details&gt;")
                            End If

                            reader.Close()
                            message.Append("</order_details>")

                            '****************************************
                            ' Close MikData/Message Wrapper
                            '****************************************
                            message.Append("</mikData>")
                            message.Append("</mikMessage>")

                            '****************************************
                            ' Store In DB
                            '****************************************
                            SQLStr = "PO_Maintenance_Publish_Purchase_Order_Message_Direct_Save_In_Queue"

                            cmd = New SqlClient.SqlCommand(SQLStr, conn)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.CommandTimeout = 1800

                            cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poMaintenanceID, "CLng")
                            cmd.Parameters.Add("@Message", SqlDbType.VarChar).Value = message.ToString()

                            cmd.ExecuteNonQuery()

                            'This can be used to export to a file since management studio limits
                            'the amount of data that can be retrieved in the grid/text/file format
                            'System.IO.File.WriteAllText("C:\Users\oscar.treto\Desktop\Debugging\" & CurrentSKU & ".txt", message.ToString())

                            'NAK 7/13/2011: Per Lopa, we can now decrease this timed sleep from 1 second to 1 tenth of a second.
                            Threading.Thread.Sleep(100)
                        Next

                    End If

                    returnValue = True


                Catch ex As Exception

                    Logger.LogError(ex)
                    Throw ex

                Finally

                    If Not conn Is Nothing AndAlso conn.State = ConnectionState.Open Then
                        conn.Close()
                    End If

                End Try

            End Using

            Return returnValue

        End Function

        Public Shared Sub Rollback(ByVal poID As Long)

            Dim sql As String = "PO_Maintenance_Rollback_Revision"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.VarChar).Value = poID
                cmd.CommandTimeout = 1800
                cmd.CommandText = sql
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

        Public Shared Sub SaveHistoryStageDuration(ByVal poCreationID As Long, ByVal action As String, ByVal previousStage As Integer, ByVal currentStage As Integer, ByVal approvingUserID As Integer)
            Dim sql As String = "PO_History_Stage_Durations_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_ID", SqlDbType.BigInt).Value = poCreationID
                cmd.Parameters.Add("@PO_Type", SqlDbType.Int).Value = 2 'Indicates a PO_Maintenance record
                cmd.Parameters.Add("@Previous_Stage", SqlDbType.Int).Value = previousStage
                cmd.Parameters.Add("@Current_Stage", SqlDbType.Int).Value = currentStage
                cmd.Parameters.Add("@Action", SqlDbType.VarChar).Value = action
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = approvingUserID

                cmd.CommandText = sql
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

        Public Shared Sub SaveValidationMessages(ByVal messagesTable As DataTable)

            Dim sqlBulkCopy As SqlBulkCopy = New SqlBulkCopy(Utilities.ApplicationConnectionStrings.AppConnectionString)
            Try
                sqlBulkCopy.DestinationTableName = "PO_Maintenance_Validation_Messages"
                sqlBulkCopy.WriteToServer(messagesTable)

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                sqlBulkCopy.Close()
            End Try
        End Sub

        Public Shared Sub SaveWorkflowHistory(ByVal poRecord As POMaintenanceRecord, ByVal action As String, ByVal userID As Integer, Optional ByVal notes As String = "")

            Dim sql As String = "PO_Maintenance_Workflow_History_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_ID", SqlDbType.VarChar).Value = poRecord.ID
                cmd.Parameters.Add("@Workflow_Stage_ID", SqlDbType.TinyInt).Value = poRecord.WorkflowStageID
                cmd.Parameters.Add("@Action", SqlDbType.Char).Value = action
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
                cmd.Parameters.Add("@Notes", SqlDbType.VarChar).Value = notes

                cmd.CommandText = sql
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

        Public Shared Sub UpdatePOProcessing(ByVal poMaintenanceID As Long?, ByVal isProcessing As Boolean)

            Dim sql As String = "PO_Maintenance_PROCESSING_InsertUpdate"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.Command.Parameters.Add("@Is_Processing", SqlDbType.BigInt).Value = isProcessing
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Command.ExecuteNonQuery()

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
        End Sub

        Public Shared Function ValidateUserForPO(ByVal poID As Long, ByVal userID As Integer) As Boolean
            Dim userAccess As Boolean = False
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.Int).Value = poID
                reader.Command.Parameters.Add("@UserID", SqlDbType.Int).Value = userID
                reader.CommandText = "PO_Maintenance_ValidateUser"
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        If DataHelper.SmartValues(.Item("CanEdit"), "integer", False) <> 0 Then
                            userAccess = True
                        End If
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

            Return userAccess
        End Function

        Public Shared Function ValidateWorkflowAccess(ByVal workflowStageID As Integer, ByVal workflowDepartmentID As Integer?, ByVal userID As Integer) As Boolean
            Dim userAccess As Boolean = False
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Workflow_Stage_ID", SqlDbType.Int).Value = workflowStageID
                reader.Command.Parameters.Add("@Workflow_Department_ID", SqlDbType.Int).Value = workflowDepartmentID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
                reader.CommandText = "PO_Maintenance_ValidateWorkflowAccess"
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        If DataHelper.SmartValues(.Item("CanEdit"), "integer", False) <> 0 Then
                            userAccess = True
                        End If
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

            Return userAccess
        End Function

        'Alex's Code 
        Public Shared Function GetWorkFlowDept(ByVal poID As Integer) As String
            Dim sql As String = "[PO_Get_Maint_Work_Flow_Department]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = poID
                command.Parameters.Add(param)
                param = Nothing
                Return command.CommandObject.ExecuteScalar
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try
        End Function

        Public Shared Function GetPurchaseOrderDepartmentByPO(ByVal poID As Integer) As String
            Dim sql As String = "[PO_Get_Purchase_Order_Maintenance_PODepartment]"
            Dim command As DBCommand
            Dim param As SqlParameter
            Dim department As String = String.Empty
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = poID
                command.Parameters.Add(param)
                param = Nothing

                department = command.CommandObject.ExecuteScalar
                command.Connection.Close()
                command.Dispose()
                Return department
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function GetPurchaseOrderCacheTotals(ByVal poID As Integer, ByVal userID As Integer) As DataTable
            Dim sql As String = "[PO_Get_Purchase_Order_Maint_CACHE_Totals]"
            Dim command As DBCommand
            Dim table As DataTable
            Dim adapter As SqlDataAdapter
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                adapter = New SqlDataAdapter(command.CommandObject)
                table = New DataTable
                adapter.Fill(table)
                Return table
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function
        Public Shared Function GetPurchaseOrderTotals(ByVal poID As Integer) As DataTable
            Dim sql As String = "[PO_Get_Purchase_Order_Maint_Totals]"
            Dim command As DBCommand
            Dim table As DataTable
            Dim adapter As SqlDataAdapter
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID

                adapter = New SqlDataAdapter(command.CommandObject)
                table = New DataTable
                adapter.Fill(table)
                Return table
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function
        Public Shared Function GetPurchaseOrderRevisionTotals(ByVal poID As Integer, ByVal revisionNumber As String) As DataTable
            Dim sql As String = "[PO_Get_Purchase_Order_Maint_Totals_Hist]"
            Dim command As DBCommand
            Dim param As SqlParameter
            Dim table As DataTable
            Dim adapter As SqlDataAdapter
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = poID
                command.Parameters.Add(param)
                param = Nothing

                Dim revision() As String = revisionNumber.Split(".")
                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "MajorRevision"
                param.Value = revision(0)
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "MinorRevision"
                param.Value = revision(1)
                command.Parameters.Add(param)
                param = Nothing

                adapter = New SqlDataAdapter(command.CommandObject)
                table = New DataTable
                adapter.Fill(table)
                Return table
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function GetPurchaseOrderUPCsForSKU(ByVal poID As Integer, ByVal sku As String, ByVal userID As Integer) As DataTable
            Dim sql As String = "[PO_Get_Purchase_Order_Maint_UPCs_FOR_SKU]"
            Dim command As DBCommand
            Dim table As DataTable
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = sku
                command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                adapter = New SqlDataAdapter(command.CommandObject)
                table = New DataTable
                adapter.Fill(table)
                Return table
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Sub SaveWorkFlowDepartment(ByVal poID As Integer, ByVal departmentID As Integer)
            Dim sql As String = "[PO_Save_Current_Work_Flow_Department]"
            Dim command As DBCommand
            Dim param As SqlParameter
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = poID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "DeptID"
                param.Value = departmentID
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Sub

        Public Shared Function UpdateUPC(ByVal POID As Integer, ByVal SKU As String, ByVal UPC As String) As Boolean
            Dim sql As String = "[PO_Maint_Update_Selected_UPC_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 20
                param.ParameterName = "UPC"
                param.Value = UPC
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateOrderedQTY(ByVal POID As Integer, ByVal SKU As String, ByVal qty As Integer)
            Dim sql As String = "[PO_Maint_Update_Ordered_Qty_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "Qty"
                param.Value = qty
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateLocationQTY(ByVal POID As Integer, ByVal SKU As String, ByVal qty As Integer)
            Dim sql As String = "[PO_Maint_Update_Location_Qty_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "Qty"
                param.Value = qty
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateCancelledQTY(ByVal POID As Integer, ByVal SKU As String, ByVal qty As Integer)
            Dim sql As String = "[PO_Maint_Update_Cancelled_Qty_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "Qty"
                param.Value = qty
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateCancelCode(ByVal POID As Integer, ByVal SKU As String, ByVal code As String)
            Dim sql As String = "[PO_Maint_Update_Cancel_Code_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 1
                param.ParameterName = "CancelCode"
                param.Value = code
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateReceivedQTY(ByVal POID As Integer, ByVal SKU As String, ByVal qty As Integer)
            Dim sql As String = "[PO_Maint_Update_Received_Qty_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "Qty"
                param.Value = qty
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateUnitCost(ByVal POID As Integer, ByVal SKU As String, ByVal unitCost As Double)
            Dim sql As String = "[PO_Maint_Update_Unit_Cost_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Money
                param.Size = 8
                param.ParameterName = "UnitCost"
                param.Value = unitCost
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateInnerPack(ByVal POID As Integer, ByVal SKU As String, ByVal innerPack As Integer)
            Dim sql As String = "[PO_Maint_Update_Inner_Pack_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "InnerPack"
                param.Value = innerPack
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Function UpdateMasterPack(ByVal POID As Integer, ByVal SKU As String, ByVal masterPack As Integer)
            Dim sql As String = "[PO_Maint_Update_Master_Pack_For_PO_By_SKU]"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = POID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "SKU"
                param.Value = SKU
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "MasterPack"
                param.Value = masterPack
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Sub DeleteCheckedSku(ByVal poID As Integer, ByVal michaelsSKU As String)
            Dim sql As String = "PO_Maint_Delete_Michaels_SKU_For_PO"
            Dim command As DBCommand
            Dim param As SqlParameter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "POID"
                param.Value = poID
                command.Parameters.Add(param)
                param = Nothing

                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.NVarChar
                param.Size = 10
                param.ParameterName = "MichaelsSKU"
                param.Value = michaelsSKU
                command.Parameters.Add(param)
                param = Nothing

                command.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Sub

        Public Shared Function HasAtLeastOneSKU(ByVal poID As Integer) As Boolean?

            Dim returnValue As Boolean = False

            Dim sql As String = "[PO_Maintenance_Has_At_Least_One_SKU]"

            Dim command As DBCommand
            Dim param As SqlParameter

            Try

                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure


                param = command.CommandObject.CreateParameter
                param.Direction = ParameterDirection.Input
                param.SqlDbType = SqlDbType.Int
                param.Size = 4
                param.ParameterName = "ID"
                param.Value = poID
                command.Parameters.Add(param)
                param = Nothing

                returnValue = Convert.ToBoolean(command.CommandObject.ExecuteScalar())

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return returnValue

        End Function

        Public Shared Function CacheHasAtLeastOneSKU(ByVal poID As Integer, ByVal userID As Integer) As Boolean?

            Dim returnValue As Boolean = False

            Dim sql As String = "PO_Maintenance_Cache_Has_At_Least_One_SKU"

            Dim command As DBCommand

            Try

                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poID
                command.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = userID

                returnValue = Convert.ToBoolean(command.CommandObject.ExecuteScalar())

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return returnValue

        End Function

        Public Shared Function SaveSKUDefault(ByVal poID As Integer, ByVal michaelsSKU As String, ByVal field As String, ByVal userID As Integer) As Boolean?

            Dim returnValue As Boolean = False

            Dim sql As String = "[PO_Maintenance_Reset_SKU_Default_Value]"

            Dim command As DBCommand

            Try

                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = michaelsSKU
                command.Parameters.Add("@FieldName", SqlDbType.NVarChar).Value = field
                command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                command.ExecuteNonQuery()
                Return True
            Catch ex As Exception
                Logger.LogError(ex)
                Return False
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Function

        Public Shared Sub UpdatePODepartmentID(ByVal POMaintenanceID As Integer)

            Dim sql As String = "PO_Maintenance_Update_PO_Department_ID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = POMaintenanceID

                cmd.CommandText = sql
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

	End Class
End Namespace