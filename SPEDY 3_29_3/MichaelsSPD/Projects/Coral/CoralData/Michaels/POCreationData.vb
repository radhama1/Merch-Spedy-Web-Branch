Imports System
Imports System.Web
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

    Public Class POCreationData

        Public Shared Sub SaveRecord(ByRef objRec As POCreationRecord, ByVal UserID As String, Optional ByVal HydrateRecord As Hydrate = POCreationData.Hydrate.None)
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

        Public Shared Sub UpdateRecordBySystem(ByRef objRec As POCreationRecord, Optional ByVal HydrateRecord As Hydrate = POCreationData.Hydrate.None)

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

        Private Shared Function _SaveRecord(ByVal objRecord As POCreationRecord, ByVal UserID As String) As Long

            Dim recordID As Integer = -1
            Dim sql As String = "PO_Creation_InsertUpdate"
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
				cmd.Parameters.Add("@PO_Special_ID", SqlDbType.Int).Value = objRecord.POSpecialID
                cmd.Parameters.Add("@Payment_Terms_ID", SqlDbType.Int).Value = objRecord.PaymentTermsID
                cmd.Parameters.Add("@Freight_Terms_ID", SqlDbType.Int).Value = objRecord.FreightTermsID
                cmd.Parameters.Add("@Internal_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.InternalComment, True)
                cmd.Parameters.Add("@External_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.ExternalComment, True)
                cmd.Parameters.Add("@Generated_Comment", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.Generatedcomment, True)
                cmd.Parameters.Add("@Is_Header_Valid", SqlDbType.Bit).Value = objRecord.IsHeaderValid
                cmd.Parameters.Add("@Is_Detail_Valid", SqlDbType.Bit).Value = objRecord.IsDetailValid
                cmd.Parameters.Add("@Is_Alloc_Dirty", SqlDbType.Bit).Value = objRecord.IsAllocDirty
                cmd.Parameters.Add("@Enabled", SqlDbType.Bit).Value = objRecord.Enabled
                cmd.Parameters.Add("@User_ID", SqlDbType.NVarChar).Value = UserID
                cmd.Parameters.Add("@Allow_Seasonal_Items_Basic_DC", SqlDbType.Bit).Value = objRecord.AllowSeasonalItemsBasicDC
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

        Private Shared Function _UpdateRecordBySystem(ByVal objRecord As POCreationRecord) As Long

            Dim recordID As Integer = -1
            Dim sql As String = "PO_Creation_Update_By_System"
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
				cmd.Parameters.Add("@PO_Special_ID", SqlDbType.Int).Value = objRecord.POSpecialID
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
                cmd.Parameters.Add("@Allow_Seasonal_Items_Basic_DC", SqlDbType.Bit).Value = objRecord.AllowSeasonalItemsBasicDC
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

        Public Shared Function GetRecord(ByVal ID As Long) As POCreationRecord

            Dim objRecord As New POCreationRecord()
            Dim sql As String = "PO_Creation_Get_By_ID"
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
                        objRecord.IsAllocDirty = DataHelper.SmartValuesDBNull(.Item("Is_Alloc_Dirty"))
                        objRecord.IsPlannerDirty = DataHelper.SmartValuesDBNull(.Item("Is_Planner_Dirty"))
                        objRecord.IsDateWarning = DataHelper.SmartValuesDBNull(.Item("Is_Date_Warning"))
                        objRecord.IsHeaderValid = DataHelper.SmartValuesDBNull(.Item("Is_Header_Valid"))
						objRecord.IsDetailValid = DataHelper.SmartValuesDBNull(.Item("Is_Detail_Valid"))
						objRecord.IsValidating = DataHelper.SmartValuesDBNull(.Item("Is_Validating"))
						objRecord.ValidatingJobID = DataHelper.SmartValuesDBNull(.Item("Validating_Job_ID"))
                        objRecord.Enabled = DataHelper.SmartValuesDBNull(.Item("Enabled"))
                        objRecord.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        objRecord.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        objRecord.CreatedUserName = DataHelper.SmartValuesDBNull(.Item("Created_User_Name"))
                        objRecord.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        objRecord.ModifiedUserName = DataHelper.SmartValuesDBNull(.Item("Modified_User_Name"))
                        objRecord.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        objRecord.AllowSeasonalItemsBasicDC = DataHelper.SmartValuesDBNull(.Item("Allow_Seasonal_Items_Basic_DC"))
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

		Public Shared Function AddLocation(ByVal POCreationID As Integer, ByVal POLocationID As Integer, ByVal ExternalReferenceID As String, ByVal UserID As Integer) As Integer
			Dim isNew As Integer = 0
			Dim sql As String = "PO_Creation_Location_Insert"
			Dim cmd As DBCommand = Nothing
			Dim conn As DBConnection = Nothing
			Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
				cmd = New DBCommand(conn)
				cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
				cmd.Parameters.Add("@PO_Location_ID", SqlDbType.Int).Value = POLocationID
				cmd.Parameters.Add("@External_Reference_ID", SqlDbType.VarChar).Value = ExternalReferenceID
				cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
				cmd.Parameters.Add("@IsNew", SqlDbType.Int)
				cmd.Parameters("@IsNew").Direction = ParameterDirection.Output
				cmd.CommandText = sql
				cmd.CommandType = CommandType.StoredProcedure

				cmd.CommandText = sql
				cmd.CommandType = CommandType.StoredProcedure
				cmd.ExecuteNonQuery()

				isNew = DataHelper.SmartValue(cmd.Parameters("@IsNew").Value, "integer", 0)

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

			Return isNew
		End Function

		Public Shared Function DeleteLocation(ByVal POCreationID As Integer, ByVal POLocationID As Integer) As Integer
			Dim isDeleted As Integer = 0
			Dim sql As String = "PO_Creation_Location_Delete_By_POID_And_LID"
			Dim cmd As DBCommand = Nothing
			Dim conn As DBConnection = Nothing
			Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
				cmd = New DBCommand(conn)
				cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
				cmd.Parameters.Add("@PO_Location_ID", SqlDbType.Int).Value = POLocationID
				cmd.Parameters.Add("@IsDeleted", SqlDbType.Int)
				cmd.Parameters("@IsDeleted").Direction = ParameterDirection.Output

				cmd.CommandText = sql
				cmd.CommandType = CommandType.StoredProcedure
				cmd.ExecuteNonQuery()

				isDeleted = DataHelper.SmartValue(cmd.Parameters("@IsDeleted").Value, "integer", 0)
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

			Return isDeleted
		End Function

		Public Shared Function GetLocationsByPOID(ByVal poID As Long, Optional ByVal locationType As Integer = 0) As List(Of POCreationLocationRecord)
			Dim locations As New List(Of POCreationLocationRecord)

            Dim sql As String = "PO_Creation_Location_Get_By_PO_ID"
			Dim reader As DBReader = Nothing
			Dim conn As DBConnection = Nothing

			Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
				reader = New DBReader(conn)
				reader.Command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poID
				reader.Command.Parameters.Add("@Location_Type", SqlDbType.TinyInt).Value = locationType
				reader.CommandText = sql
				reader.CommandType = CommandType.StoredProcedure
				reader.Open()
				While reader.Read()
					With reader
						Dim pcl As New POCreationLocationRecord
						pcl.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
						pcl.POCreationID = DataHelper.SmartValues(.Item("PO_Creation_ID"), "long", True)
						pcl.POLocationID = DataHelper.SmartValues(.Item("PO_Location_ID"), "CInt", True)
						pcl.ExternalReferenceID = DataHelper.SmartValues(.Item("External_Reference_ID"), "Cint", True)
                        pcl.WrittenDate = DataHelper.SmartValue(.Item("Written_Date"), "CDate", Nothing)
                        pcl.NotBefore = DataHelper.SmartValue(.Item("Not_Before"), "CDate", Nothing)
                        pcl.NotAfter = DataHelper.SmartValue(.Item("Not_After"), "CDate", Nothing)
                        pcl.EstimatedInStockDate = DataHelper.SmartValue(.Item("Estimated_In_Stock_Date"), "CDate", Nothing)
						pcl.DateCreated = DataHelper.SmartValues(.Item("Date_Created"), "Date", True)
						pcl.CreatedUserID = DataHelper.SmartValues(.Item("Created_User_ID"), "CInt", True)
						pcl.DateLastModified = DataHelper.SmartValues(.Item("Date_Last_Modified"), "Date", True)
						pcl.ModifiedUserID = DataHelper.SmartValues(.Item("Modified_User_ID"), "CInt", True)
						pcl.LocationName = DataHelper.SmartValues(.Item("Name"), "String", False)
						pcl.LocationConstant = DataHelper.SmartValues(.Item("Constant"), "String", False)

						locations.Add(pcl)
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

			Return locations

        End Function

        Public Shared Function GetLocationsCacheByPOID(ByVal poID As Long, ByVal userID As Integer) As List(Of POCreationLocationRecord)
            Dim locations As New List(Of POCreationLocationRecord)

            Dim sql As String = "PO_Creation_Location_CACHE_Get_By_PO_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        Dim pcl As New POCreationLocationRecord
                        pcl.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                        pcl.POCreationID = DataHelper.SmartValues(.Item("PO_Creation_ID"), "long", True)
                        pcl.POLocationID = DataHelper.SmartValues(.Item("PO_Location_ID"), "CInt", True)
                        pcl.ExternalReferenceID = DataHelper.SmartValues(.Item("External_Reference_ID"), "Cint", True)
                        pcl.WrittenDate = DataHelper.SmartValue(.Item("Written_Date"), "CDate", Nothing)
                        pcl.NotBefore = DataHelper.SmartValue(.Item("Not_Before"), "CDate", Nothing)
                        pcl.NotAfter = DataHelper.SmartValue(.Item("Not_After"), "CDate", Nothing)
                        pcl.EstimatedInStockDate = DataHelper.SmartValue(.Item("Estimated_In_Stock_Date"), "CDate", Nothing)
                        pcl.DateCreated = DataHelper.SmartValues(.Item("Date_Created"), "Date", True)
                        pcl.CreatedUserID = DataHelper.SmartValues(.Item("Created_User_ID"), "CInt", True)
                        pcl.DateLastModified = DataHelper.SmartValues(.Item("Date_Last_Modified"), "Date", True)
                        pcl.ModifiedUserID = DataHelper.SmartValues(.Item("Modified_User_ID"), "CInt", True)
                        pcl.LocationName = DataHelper.SmartValues(.Item("Name"), "String", False)
                        pcl.LocationConstant = DataHelper.SmartValues(.Item("Constant"), "String", False)

                        locations.Add(pcl)
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

            Return locations

        End Function

        Public Shared Sub UpdateLocation(ByVal objRec As POCreationLocationRecord, ByVal userID As Integer)
            Dim sql As String = "PO_Creation_Location_Update"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = objRec.POCreationID
                reader.Command.Parameters.Add("@PO_Location_ID", SqlDbType.VarChar).Value = objRec.POLocationID
                reader.Command.Parameters.Add("@Written_Date", SqlDbType.DateTime).Value = objRec.WrittenDate
                reader.Command.Parameters.Add("@Not_Before", SqlDbType.DateTime).Value = objRec.NotBefore
                reader.Command.Parameters.Add("@Not_After", SqlDbType.DateTime).Value = objRec.NotAfter
                reader.Command.Parameters.Add("@Estimated_In_Stock_Date", SqlDbType.DateTime).Value = objRec.EstimatedInStockDate
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

        Public Shared Sub UpdateLocationCache(ByVal objRec As POCreationLocationRecord, ByVal userID As Integer)
            Dim sql As String = "PO_Creation_Location_CACHE_Update"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = objRec.POCreationID
                reader.Command.Parameters.Add("@PO_Location_ID", SqlDbType.VarChar).Value = objRec.POLocationID
                reader.Command.Parameters.Add("@Written_Date", SqlDbType.DateTime).Value = objRec.WrittenDate
                reader.Command.Parameters.Add("@Not_Before", SqlDbType.DateTime).Value = objRec.NotBefore
                reader.Command.Parameters.Add("@Not_After", SqlDbType.DateTime).Value = objRec.NotAfter
                reader.Command.Parameters.Add("@Estimated_In_Stock_Date", SqlDbType.DateTime).Value = objRec.EstimatedInStockDate
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

        Public Shared Sub CreateDetailCache(ByVal poCreationID As Long?, ByVal userID As Integer)
            Dim sql As String = "PO_Creation_Details_Create_Cache"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
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

		Public Shared Sub DeleteValidationMessages(ByVal poCreationID As Long?, ByVal sku As String)
			Dim sql As String = "PO_Creation_Validation_Message_Delete_By_POID_SKU"
			Dim cmd As DBCommand = Nothing
			Dim conn As DBConnection = Nothing

			Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
				cmd = New DBCommand(conn)

				cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poCreationID
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

		Public Shared Function GetDeletedWorkflowStageID() As Integer
			Dim workflowStageID As Integer = 0

			Dim reader As DBReader = Nothing
			Dim cmd As DBCommand
			Dim conn As DBConnection = Nothing

			Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
				reader = New DBReader(conn)
				cmd = reader.Command
				reader.CommandText = "select dbo.udf_PO_Creation_GetDeletedWorkflowStage()"
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

		Public Shared Function GetDisApprovalStages(ByVal poID As Long) As List(Of WorkflowStage)

			Dim stages As List(Of WorkflowStage) = New List(Of WorkflowStage)

			Dim sql As String = "PO_Creation_Workflow_History_GetStages_By_POID"
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

		Public Shared Function GetHistoryByPOID(ByVal poID As Long) As DataTable

			Dim sql As String = "PO_Creation_Workflow_History_Get_By_POID"
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

		Public Shared Function GetHistoryByBatchNumber(ByVal batchNumber As String) As DataTable
			Dim sql As String = "PO_Creation_Workflow_History_Get_By_Batch_Number"
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
                param.SqlDbType = SqlDbType.VarChar
                param.ParameterName = "Batch_Number"
                param.Value = batchNumber
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
                reader.CommandText = "select dbo.udf_PO_Creation_GetInitialRoleID(@User_ID)"
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
                reader.CommandText = "select dbo.udf_PO_Creation_GetInitialWorkflowStageID(@Initiator_Role_ID)"
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

        Public Shared Function GetIsPOProcessing(ByVal poCreationID As Long) As Boolean
            Dim isPOProcessing As Boolean = False

            Dim sql As String = "PO_Creation_PROCESSING_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poCreationID
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

        Public Shared Function GetSKUAndStoreValidity(ByVal poCreationID As Long?) As Boolean?

            Dim isSKuStoreValid As Boolean?

            Dim sql As String = "PO_Creation_Get_SKUs_Stores_Valid"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poCreationID
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

        Public Shared Function GetValidationMessagesGetForStores(ByVal poCreationID As Long?, ByVal sku As String) As DataTable

            Dim validationMessages As New DataTable

            Dim sql As String = "PO_Creation_Validation_Message_Get_For_Stores"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poCreationID
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

        Public Shared Function GetValidationMessagesByPOID(ByVal poCreationID As Long?) As DataTable

            Dim validationMessages As New DataTable

            Dim sql As String = "PO_Creation_Validation_Message_Get_By_POID"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poCreationID

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

        Public Shared Function GetSummarizedValidationMessagesByPOID(ByVal poCreationID As Long?) As DataTable

            Dim validationMessages As New DataTable

            Dim sql As String = "PO_Creation_Validation_Summarized_Messages_Get_By_POID"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poCreationID

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

        Public Shared Function ValidationMessagesCountByPOID(ByVal poCreationID As Long?, Optional ByVal severityType As Integer = -999) As Integer

            Dim validationMessages As Integer = 0

            Dim sql As String = "PO_Creation_Validation_Messages_Count_Get_By_POID"
            Dim command As DBCommand

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poCreationID
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

        Public Shared Function HasAtLeastOneSKU(ByVal POCreationID As Integer) As Boolean?

            Dim returnValue As Boolean = False

            Dim sql As String = "PO_Creation_Has_At_Least_One_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = POCreationID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        returnValue = DataHelper.SmartValuesDBNull(.Item("HasSKU"))

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

            Return returnValue

        End Function

        Public Shared Function CacheHasAtLeastOneSKU(ByVal POCreationID As Integer, ByVal UserID As Integer) As Boolean?

            Dim returnValue As Boolean = False

            Dim sql As String = "PO_Creation_Cache_Has_At_Least_One_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = POCreationID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        returnValue = DataHelper.SmartValuesDBNull(.Item("HasSKU"))

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

            Return returnValue

        End Function

        Public Shared Sub MergeCache(ByVal poCreationID As Long, ByVal userID As Integer)
            Dim sql As String = "PO_Creation_Details_Merge_Cache"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
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

        Public Shared Function PublishPOMessage(ByVal poCreationID As Long?) As Boolean

            Dim returnValue As Boolean = False

            Dim poRec As POCreationRecord = GetRecord(poCreationID)

            If poRec.BatchType = "W" Then
                returnValue = PublishPOMessageWarehouse(poCreationID)
            ElseIf poRec.BatchType = "D" Then
                returnValue = PublishPOMessageDirect(poCreationID)
            End If

            Return returnValue

        End Function

        Public Shared Function PublishPOMessageWarehouse(ByVal poCreationID As Long?) As Boolean

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

                    Dim ProcessTimeStamp As String = ""
                    Dim Locations As New ArrayList()

                    '**********************************************************************
                    ' Get Initial Data
                    '**********************************************************************
                    SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Step_1"

                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")

                    reader = cmd.ExecuteReader()

                    If reader.HasRows Then

                        reader.Read()
                        ProcessTimeStamp = DataHelper.SmartValue(reader.Item("ProcessTimeStamp"), "CStr", "")
                        message.Append(DataHelper.SmartValue(reader.Item("MessageStr"), "CStr", ""))

                    End If
                    reader.Close()

                    '**********************************************************************
                    ' Get Location(s) To Publish
                    '**********************************************************************
                    SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Step_2"

                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")

                    reader = cmd.ExecuteReader()

                    If reader.HasRows Then

                        Do While reader.Read()
                            Locations.Add(DataHelper.SmartValue(reader.Item("PO_Creation_Location_ID"), "CInt", 0))
                        Loop

                    End If
                    reader.Close()

                    If Locations.Count > 0 Then

                        '**********************************************************************
                        ' Build MikData (Loop Through Each Location)
                        '**********************************************************************
                        For Each CurrentLocationID As Integer In Locations

                            '***********************************
                            ' Build Header
                            '***********************************
                            SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Step_3"

                            cmd = New SqlClient.SqlCommand(SQLStr, conn)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.CommandTimeout = 1800

                            cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")
                            cmd.Parameters.Add("@PO_Creation_Location_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(CurrentLocationID, "CLng")
                            cmd.Parameters.Add("@Process_Time_Stamp", SqlDbType.VarChar).Value = DataHelper.SmartValueDB(ProcessTimeStamp, "CStr")

                            message.Append(DataHelper.SmartValue(cmd.ExecuteScalar(), "CStr", ""))

                            '***********************************
                            ' Build Details
                            '***********************************

                            SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Step_4"

                            cmd = New SqlClient.SqlCommand(SQLStr, conn)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.CommandTimeout = 1800

                            cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")
                            cmd.Parameters.Add("@PO_Creation_Location_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(CurrentLocationID, "CLng")

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

                            '***********************************
                            ' Close MikData (Begins In Header)
                            '***********************************
                            message.Append("</mikData>")

                        Next

                        '**********************************************************************
                        ' Close Message Wrapper And Store In DB
                        '**********************************************************************
                        message.Append("</mikMessage>")

                        SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Step_5"

                        cmd = New SqlClient.SqlCommand(SQLStr, conn)
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.CommandTimeout = 1800

                        cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")
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

        Public Shared Function PublishPOMessageDirect(ByVal poCreationID As Long?) As Boolean

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

            Using conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString)

                Try

                    conn.Open()

                    Dim mikMessageHeader As String = ""
                    Dim mikDataHeader As String = ""
                    Dim ProcessTimeStamp As String = ""
                    Dim Locations As New ArrayList()

                    '**********************************************************************
                    ' Get Location(s) To Publish
                    '**********************************************************************
                    SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Direct_Get_Locations"

                    cmd = New SqlClient.SqlCommand(SQLStr, conn)
                    cmd.CommandType = CommandType.StoredProcedure
                    cmd.CommandTimeout = 1800

                    cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")

                    reader = cmd.ExecuteReader()

                    If reader.HasRows Then

                        Do While reader.Read()
                            Locations.Add(DataHelper.SmartValue(reader.Item("PO_Creation_Location_ID"), "CInt", 0))
                        Loop

                    End If
                    reader.Close()

                    If Locations.Count > 0 Then

                        '**********************************************************************
                        ' Build MikData (Loop Through Each Location - External Ref ID)
                        '**********************************************************************
                        For Each CurrentLocationID As Integer In Locations

                            '***************************************
                            ' Get SKUs To Publish For This Location
                            '***************************************
                            Dim SKUs As New ArrayList()

                            SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Direct_Get_SKUs"

                            cmd = New SqlClient.SqlCommand(SQLStr, conn)
                            cmd.CommandType = CommandType.StoredProcedure
                            cmd.CommandTimeout = 1800

                            cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")
                            cmd.Parameters.Add("@PO_Creation_Location_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(CurrentLocationID, "CLng")

                            reader = cmd.ExecuteReader()

                            If reader.HasRows Then

                                Do While reader.Read()
                                    SKUs.Add(DataHelper.SmartValue(reader.Item("Michaels_SKU"), "CStr", ""))
                                Loop

                            End If
                            reader.Close()

                            '**********************************************************************
                            ' Loop Through Each SKU In This Location
                            '**********************************************************************
                            For Each CurrentSKU As String In SKUs

                                'Create The Message For This External Ref/Item
                                Dim message As New Text.StringBuilder()

                                '**********************************************************************
                                ' Get Message Header
                                '**********************************************************************
                                SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Direct_Get_Message_Header"

                                cmd = New SqlClient.SqlCommand(SQLStr, conn)
                                cmd.CommandType = CommandType.StoredProcedure
                                cmd.CommandTimeout = 1800

                                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")

                                reader = cmd.ExecuteReader()

                                If reader.HasRows Then

                                    reader.Read()
                                    ProcessTimeStamp = DataHelper.SmartValue(reader.Item("ProcessTimeStamp"), "CStr", "")
                                    mikMessageHeader = DataHelper.SmartValue(reader.Item("MessageStr"), "CStr", "")

                                End If
                                reader.Close()

                                '***********************************
                                ' Build MikData Header
                                '***********************************
                                SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Direct_Get_MikData_Header"

                                cmd = New SqlClient.SqlCommand(SQLStr, conn)
                                cmd.CommandType = CommandType.StoredProcedure
                                cmd.CommandTimeout = 1800

                                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")
                                cmd.Parameters.Add("@PO_Creation_Location_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(CurrentLocationID, "CLng")
                                cmd.Parameters.Add("@Process_Time_Stamp", SqlDbType.VarChar).Value = DataHelper.SmartValueDB(ProcessTimeStamp, "CStr")

                                mikDataHeader = DataHelper.SmartValue(cmd.ExecuteScalar(), "CStr", "")

                                'Append Record Count To The Header
                                mikDataHeader += "<record_count>" & SKUs.Count & "</record_count>"

                                message.Append(mikMessageHeader)
                                message.Append(mikDataHeader)

                                '***********************************
                                ' Build Details (Stores)
                                '***********************************

                                SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Direct_Get_SKU_LOC"

                                cmd = New SqlClient.SqlCommand(SQLStr, conn)
                                cmd.CommandType = CommandType.StoredProcedure
                                cmd.CommandTimeout = 1800

                                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")
                                cmd.Parameters.Add("@PO_Creation_Location_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(CurrentLocationID, "CLng")
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
                                SQLStr = "PO_Creation_Publish_Purchase_Order_Message_Direct_Save_In_Queue"

                                cmd = New SqlClient.SqlCommand(SQLStr, conn)
                                cmd.CommandType = CommandType.StoredProcedure
                                cmd.CommandTimeout = 1800

                                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(poCreationID, "CLng")
                                cmd.Parameters.Add("@Message", SqlDbType.VarChar).Value = message.ToString()

                                cmd.ExecuteNonQuery()

                                'This can be used to export to a file since management studio limits
                                'the amount of data that can be retrieved in the grid/text/file format
                                'System.IO.File.WriteAllText("C:\Users\oscar.treto\Desktop\Debugging\" & CurrentLocationID & "_" & CurrentSKU & ".txt", message.ToString())

                                'NAK 7/13/2011: Per Lopa, we can now decrease this timed sleep from 1 second to 1 tenth of a second.
                                Threading.Thread.Sleep(100)
                            Next

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

        Public Shared Sub SaveHistoryStageDuration(ByVal poCreationID As Long, ByVal action As String, ByVal previousStage As Integer, ByVal currentStage As Integer, ByVal approvingUserID As Integer)
            Dim sql As String = "PO_History_Stage_Durations_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_ID", SqlDbType.BigInt).Value = poCreationID
                cmd.Parameters.Add("@PO_Type", SqlDbType.Int).Value = 1 'Indicates a PO_Creation record
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
                sqlBulkCopy.DestinationTableName = "PO_Creation_Validation_Messages"
                sqlBulkCopy.WriteToServer(messagesTable)

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                sqlBulkCopy.Close()
            End Try
        End Sub

        Public Shared Sub SaveWorkflowHistory(ByVal poRecord As POCreationRecord, ByVal action As String, ByVal userID As Integer, Optional ByVal notes As String = "")

            Dim sql As String = "PO_Creation_Workflow_History_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_ID", SqlDbType.VarChar).Value = poRecord.ID
                cmd.Parameters.Add("@Batch_Number", SqlDbType.VarChar).Value = poRecord.BatchNumber
                cmd.Parameters.Add("@Workflow_Stage_ID", SqlDbType.Int).Value = poRecord.WorkflowStageID
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

        Public Shared Sub UpdatePOProcessing(ByVal poCreationID As Long?, ByVal isProcessing As Boolean)

            Dim sql As String = "PO_Creation_PROCESSING_InsertUpdate"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = poCreationID
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

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.Int).Value = poID
                reader.Command.Parameters.Add("@UserID", SqlDbType.Int).Value = userID
                reader.CommandText = "PO_Creation_ValidateUser"
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

        Public Shared Function ValidateUserForPORestore(ByVal poID As Long, ByVal userID As Integer) As Boolean
            Dim userAccess As Boolean = False
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.Int).Value = poID
                reader.Command.Parameters.Add("@UserID", SqlDbType.Int).Value = userID
                reader.CommandText = "PO_Creation_ValidateRestoreUser"
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
        Public Shared Function GetWorkFlowDepts() As DataTable
            Dim sql As String = "PO_Get_Work_Flow_Depts"
            Dim command As DBCommand
            Dim table As DataTable
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

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

        Public Shared Function GetPurchaseOrderDepartmentByPO(ByVal poID As Integer) As String
            Dim sql As String = "[PO_Get_Purchase_Order_PODepartment]"
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

                department = If(command.CommandObject.ExecuteScalar, String.Empty)
                Return department
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

        Public Shared Function GetPurchaseOrderAllocations(ByVal poID As Long?, ByVal userID As Integer) As DataTable
            Dim sql As String = "[PO_Get_Purchase_Order_Allocations]"
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

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return table
        End Function

        Public Shared Function GetPurchaseOrderTotals(ByVal poID As Integer) As DataTable
            Dim sql As String = "PO_Get_Purchase_Order_Totals"
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

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return table
        End Function

        Public Shared Function GetPurchaseOrderCacheTotals(ByVal poID As Integer, ByVal userID As Integer) As DataTable
            Dim sql As String = "PO_Get_Purchase_Order_CACHE_Totals"
            Dim command As DBCommand
            Dim table As DataTable
            Dim adapter As SqlDataAdapter
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                command.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = userID

                adapter = New SqlDataAdapter(command.CommandObject)
                table = New DataTable
                adapter.Fill(table)

                adapter.Dispose()

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return table
        End Function

        Public Shared Function GetPurchaseOrderUPCsForSKU(ByVal poID As Integer, ByVal sku As String, ByVal userID As Integer) As DataTable
            Dim sql As String = "[PO_Get_Purchase_Order_UPCs_FOR_SKU]"
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

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return table
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
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try
        End Sub

        Public Shared Function UpdateUPC(ByVal POID As Integer, ByVal SKU As String, ByVal UPC As String) As Boolean
            Dim sql As String = "[PO_Update_Selected_UPC_For_PO_By_SKU]"
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
        Public Shared Function UpdateLocationQty(ByVal POID As Integer, ByVal SKU As String, ByVal location As String, ByVal qty As Integer) As Boolean
            Dim sql As String = "[PO_Update_SKU_Location_Qty_For_POID_By_Location]"
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
                param.ParameterName = "Location"
                param.Value = location
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
        Public Shared Function UpdateOrderedQty(ByVal POID As Integer, ByVal SKU As String, ByVal qty As Integer) As Boolean
            Dim sql As String = "[PO_Update_SKU_Ordered_Qty_For_POID_By_Location]"
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
        Public Shared Function UpdateUnitCost(ByVal POID As Integer, ByVal SKU As String, ByVal unitCost As Double) As Boolean
            Dim sql As String = "[PO_Update_SKU_Unit_Cost_For_POID]"
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
        Public Shared Function UpdateInnerPack(ByVal POID As Integer, ByVal SKU As String, ByVal innerPack As Integer) As Boolean
            Dim sql As String = "[PO_Update_SKU_Inner_Pack_For_POID]"
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
        Public Shared Function UpdateMasterPack(ByVal POID As Integer, ByVal SKU As String, ByVal masterPack As Integer) As Boolean
            Dim sql As String = "[PO_Update_SKU_Master_Pack_For_POID]"
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
        Public Shared Function SaveSKUDefault(ByVal poID As Integer, ByVal michaelsSKU As String, ByVal field As String, ByVal userID As Integer) As Boolean?

            Dim returnValue As Boolean = False

            Dim sql As String = "[PO_Creation_Reset_SKU_Default_Value]"

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

        Public Shared Function LocationCacheHasAtLeastOneSKUOrdered(ByVal POCreationID As Integer, ByVal POCreationLocationID As Integer, ByVal UserID As Integer) As Boolean

            Dim returnValue As Boolean = False

            Dim sql As String = "PO_Creation_Location_Cache_Has_At_Least_One_SKU_Ordered"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
                reader.Command.Parameters.Add("@PO_Creation_Location_ID", SqlDbType.BigInt).Value = POCreationLocationID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        returnValue = DataHelper.SmartValuesDBNull(.Item("HasSKU"))

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

            Return returnValue

        End Function

    End Class
End Namespace