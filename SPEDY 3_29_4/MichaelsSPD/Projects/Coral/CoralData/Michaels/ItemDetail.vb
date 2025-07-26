Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ItemDetail
        Inherits FieldLockingData

        ' ****************
        ' * ITEM HEADERS *
        ' ****************

        Public Shared Function GetItemHeaderForBatch(ByVal BatchID As Long, ByVal BatchType As Long) As Long
            Dim sql As String = "usp_SPD_Batch_GetHeaderRec"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim HeaderID As Long = -1
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)

                objParam = New System.Data.SqlClient.SqlParameter("@batchID", SqlDbType.BigInt)
                objParam.Value = BatchID
                reader.Command.Parameters.Add(objParam)

                objParam = New System.Data.SqlClient.SqlParameter("@batchType", SqlDbType.BigInt)
                objParam.Value = BatchType
                reader.Command.Parameters.Add(objParam)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        HeaderID = DataHelper.SmartValues(.Item("HeaderID"), "long", True)
                    End With
                Else
                    HeaderID = -1
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                HeaderID = -1
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
            Return HeaderID
        End Function

        Public Function GetItemHeaderRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord
            Dim objRecord As ItemHeaderRecord = New ItemHeaderRecord()
            Dim sql As String = "sp_SPD_ItemHeader_GetRecord"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = .Item("ID")
                        'objRecord.BatchID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                        objRecord.LogID = DataHelper.SmartValues(.Item("Log_ID"), "string", True)
                        objRecord.SubmittedBy = DataHelper.SmartValues(.Item("Submitted_By"), "string", True)
                        objRecord.DateSubmitted = DataHelper.SmartValues(.Item("Date_Submitted"), "date", True)
                        objRecord.SupplyChainAnalyst = DataHelper.SmartValues(.Item("Supply_Chain_Analyst"), "string", True)
                        objRecord.MgrSupplyChain = DataHelper.SmartValues(.Item("Mgr_Supply_Chain"), "string", True)
                        objRecord.DirSCVR = DataHelper.SmartValues(.Item("Dir_SCVR"), "string", True)
                        objRecord.RebuyYN = DataHelper.SmartValues(.Item("Rebuy_YN"), "string", True)
                        objRecord.ReplenishYN = DataHelper.SmartValues(.Item("Replenish_YN"), "string", True)
                        objRecord.StoreOrderYN = DataHelper.SmartValues(.Item("Store_Order_YN"), "string", True)
                        objRecord.DateInRetek = DataHelper.SmartValues(.Item("Date_In_Retek"), "date", True)
                        objRecord.EnterRetek = DataHelper.SmartValues(.Item("Enter_Retek"), "string", True)
                        objRecord.USVendorNum = DataHelper.SmartValues(.Item("US_Vendor_Num"), "integer", True)
                        objRecord.CanadianVendorNum = DataHelper.SmartValues(.Item("Canadian_Vendor_Num"), "integer", True)
                        objRecord.USVendorName = DataHelper.SmartValues(.Item("US_Vendor_Name"), "string", True)
                        objRecord.CanadianVendorName = DataHelper.SmartValues(.Item("Canadian_Vendor_Name"), "string", True)
                        objRecord.DepartmentNum = DataHelper.SmartValues(.Item("Department_Num"), "integer", True)
                        objRecord.BuyerApproval = DataHelper.SmartValues(.Item("Buyer_Approval"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("Stock_Category"), "string", True)
                        objRecord.CanadaStockCategory = DataHelper.SmartValues(.Item("Canada_Stock_Category"), "string", True)
                        objRecord.ItemType = DataHelper.SmartValues(.Item("Item_Type"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", True)
                        objRecord.AllowStoreOrder = DataHelper.SmartValues(.Item("Allow_Store_Order"), "string", True)
                        objRecord.PerpetualInventory = DataHelper.SmartValues(.Item("Perpetual_Inventory"), "string", True)
                        objRecord.InventoryControl = DataHelper.SmartValues(.Item("Inventory_Control"), "string", True)
                        objRecord.FreightTerms = DataHelper.SmartValues(.Item("Freight_Terms"), "string", True)
                        objRecord.AutoReplenish = DataHelper.SmartValues(.Item("Auto_Replenish"), "string", True)
                        objRecord.SKUGroup = DataHelper.SmartValues(.Item("SKU_Group"), "string", True)
                        objRecord.StoreSupplierZoneGroup = DataHelper.SmartValues(.Item("Store_Supplier_Zone_Group"), "string", True)
                        objRecord.WHSSupplierZoneGroup = DataHelper.SmartValues(.Item("WHS_Supplier_Zone_Group"), "string", True)
                        objRecord.Comments = DataHelper.SmartValues(.Item("Comments"), "string", True)
                        objRecord.WorksheetDesc = DataHelper.SmartValues(.Item("Worksheet_Desc"), "string", True)
                        objRecord.BatchFileID = DataHelper.SmartValues(.Item("Batch_File_ID"), "long", True)

                        Dim iv As Int16 = DataHelper.SmartValues(.Item("Is_Valid"), "smallint", True)
                        If iv = 1 Then
                            objRecord.IsValid = ItemValidFlag.Valid
                        ElseIf iv = 0 Then
                            objRecord.IsValid = ItemValidFlag.NotValid
                        Else
                            objRecord.IsValid = ItemValidFlag.Unknown
                        End If
                        objRecord.RMSSellable = DataHelper.SmartValues(.Item("RMS_Sellable"), "string", True)
                        objRecord.RMSOrderable = DataHelper.SmartValues(.Item("RMS_Orderable"), "string", True)
                        objRecord.RMSInventory = DataHelper.SmartValues(.Item("RMS_Inventory"), "string", True)

                        objRecord.StoreTotal = DataHelper.SmartValues(.Item("Store_Total"), "integer", True)
                        objRecord.POGStartDate = DataHelper.SmartValues(.Item("POG_Start_Date"), "date", True)
                        objRecord.POGCompDate = DataHelper.SmartValues(.Item("POG_Comp_Date"), "date", True)

                        objRecord.CalculateOptions = DataHelper.SmartValues(.Item("Calculate_Options"), "integer", True)
                        objRecord.Discountable = DataHelper.SmartValues(.Item("Discountable"), "string", True)
                        objRecord.AddUnitCost = DataHelper.SmartValues(.Item("Add_Unit_Cost"), "decimal", True)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemHeaderUserData(objRecord, _
                            DataHelper.SmartValues(.Item("Date_Created"), "date", True), _
                            DataHelper.SmartValues(.Item("Created_User_ID"), "integer", True), _
                            DataHelper.SmartValues(.Item("Date_Last_Modified"), "date", True), _
                            DataHelper.SmartValues(.Item("Update_User_ID"), "integer", True), _
                            DataHelper.SmartValues(.Item("Created_User"), "string", True), _
                            DataHelper.SmartValues(.Item("Update_User"), "string", True))
                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemHeaderBatchData(objRecord, _
                            DataHelper.SmartValues(.Item("Batch_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("Batch_Vendor_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("Stage_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Type_ID"), "integer", False))
                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemHeaderItemCounts(objRecord, _
                            DataHelper.SmartValues(.Item("Item_Unknown_Count"), "integer", False), _
                            DataHelper.SmartValues(.Item("Item_NotValid_Count"), "integer", False), _
                            DataHelper.SmartValues(.Item("Item_Valid_Count"), "integer", False))
                    End With
                Else
                    objRecord.ID = 0
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
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

        Public Function SaveItemHeaderRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord, ByVal userID As Integer, ByVal batchAction As String, ByVal batchNotes As String, ByVal sessionUserName As String, ByVal calculateParentTotals As Boolean) As Long
            Dim sql As String = "sp_SPD_ItemHeader_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim conn As DBConnection = Nothing
            Dim recordID As Long = 0
            Try
                If objRecord.ID <= 0 Then
                    objRecord.AuditType = AuditRecordType.Insert
                Else
                    objRecord.AuditType = AuditRecordType.Update
                End If
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = objRecord.ID
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@Batch_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.BatchID, "long", True)
                cmd.Parameters.Add("@Log_ID", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.LogID, "string", True)
                cmd.Parameters.Add("@Submitted_By", SqlDbType.VarChar, 100).Value = DataHelper.DBSmartValues(objRecord.SubmittedBy, "string", True)
                cmd.Parameters.Add("@Date_Submitted", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.DateSubmitted, "date", True)
                cmd.Parameters.Add("@Supply_Chain_Analyst", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.SupplyChainAnalyst, "string", True)
                cmd.Parameters.Add("@Mgr_Supply_Chain", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.MgrSupplyChain, "string", True)
                cmd.Parameters.Add("@Dir_SCVR", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.DirSCVR, "string", True)
                cmd.Parameters.Add("@Rebuy_YN", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.RebuyYN, "string", True)
                cmd.Parameters.Add("@Replenish_YN", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.ReplenishYN, "string", True)
                cmd.Parameters.Add("@Store_Order_YN", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.StoreOrderYN, "string", True)
                cmd.Parameters.Add("@Date_In_Retek", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.DateInRetek, "date", True)
                cmd.Parameters.Add("@Enter_Retek", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.EnterRetek, "string", True)
                cmd.Parameters.Add("@US_Vendor_Num", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.USVendorNum, "integer", True)
                cmd.Parameters.Add("@Canadian_Vendor_Num", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.CanadianVendorNum, "integer", True)
                cmd.Parameters.Add("@US_Vendor_Name", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.USVendorName, "string", True)
                cmd.Parameters.Add("@Canadian_Vendor_Name", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.CanadianVendorName, "string", True)
                cmd.Parameters.Add("@Department_Num", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.DepartmentNum, "integer", True)
                cmd.Parameters.Add("@Buyer_Approval", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.BuyerApproval, "string", True)
                cmd.Parameters.Add("@Stock_Category", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.StockCategory, "string", True)
                cmd.Parameters.Add("@Canada_Stock_Category", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.CanadaStockCategory, "string", True)
                cmd.Parameters.Add("@Item_Type", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.ItemType, "string", True)
                cmd.Parameters.Add("@Item_Type_Attribute", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.ItemTypeAttribute, "string", True)
                cmd.Parameters.Add("@Allow_Store_Order", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.AllowStoreOrder, "string", True)
                cmd.Parameters.Add("@Perpetual_Inventory", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.PerpetualInventory, "string", True)
                cmd.Parameters.Add("@Inventory_Control", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.InventoryControl, "string", True)
                cmd.Parameters.Add("@Discountable", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.Discountable, "string", True)
                cmd.Parameters.Add("@Freight_Terms", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.FreightTerms, "string", True)
                cmd.Parameters.Add("@Auto_Replenish", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.AutoReplenish, "string", True)
                cmd.Parameters.Add("@SKU_Group", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.SKUGroup, "string", True)
                cmd.Parameters.Add("@Store_Supplier_Zone_Group", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.StoreSupplierZoneGroup, "string", True)
                cmd.Parameters.Add("@WHS_Supplier_Zone_Group", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.WHSSupplierZoneGroup, "string", True)
                cmd.Parameters.Add("@Comments", SqlDbType.VarChar, -1).Value = DataHelper.DBSmartValues(objRecord.Comments, "string", True)
                cmd.Parameters.Add("@Worksheet_Desc", SqlDbType.VarChar, 4000).Value = DataHelper.DBSmartValues(objRecord.WorksheetDesc, "string", True)
                cmd.Parameters.Add("@Batch_File_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.BatchFileID, "long", True)
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)
                cmd.Parameters.Add("@Batch_Action", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(batchAction, "string", True)
                cmd.Parameters.Add("@Batch_Notes", SqlDbType.VarChar, -1).Value = DataHelper.DBSmartValues(batchNotes, "string", True)
                cmd.Parameters.Add("@Session_User_Name", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(sessionUserName, "string", True)
                cmd.Parameters.Add("@Is_Valid", SqlDbType.SmallInt).Value = objRecord.IsValid
                cmd.Parameters.Add("@RMS_Sellable", SqlDbType.VarChar, 1).Value = objRecord.RMSSellable
                cmd.Parameters.Add("@RMS_Orderable", SqlDbType.VarChar, 1).Value = objRecord.RMSOrderable
                cmd.Parameters.Add("@RMS_Inventory", SqlDbType.VarChar, 1).Value = objRecord.RMSInventory

                cmd.Parameters.Add("@Calculate_Options", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.CalculateOptions, "integer", True)

                cmd.Parameters.Add("@Store_Total", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.StoreTotal, "integer", True)
                cmd.Parameters.Add("@POG_Start_Date", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.POGStartDate, "date", True)
                cmd.Parameters.Add("@POG_Comp_Date", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.POGCompDate, "date", True)

                cmd.Parameters.Add("@Add_Unit_Cost", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.AddUnitCost, "decimal", True)

                cmd.Parameters.Add("@calculateParentTotals", SqlDbType.Bit).Value = calculateParentTotals

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                recordID = cmd.Parameters("@ID").Value

                ' save audit record
                If objRecord.SaveAudit Then
                    objRecord.AuditRecordID = recordID
                    Me.SaveAuditRecord(objRecord, conn)
                End If

            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
                recordID = 0
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

        Public Function DeleteItemHeaderRecord(ByVal id As Long, ByVal userID As Integer) As Boolean
            Dim sql As String = "sp_SPD_ItemHeader_DeleteRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                cmd.Parameters.Add(objParam)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

                Dim audit As New AuditRecord()
                audit.SetupAudit(MetadataTable.Item_Headers, id, AuditRecordType.Delete, userID)
                Me.SaveAuditRecord(audit, conn)
                audit = Nothing

            Catch ex As Exception
                Logger.LogError(ex)

                bSuccess = False
                'Throw ex
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
            Return bSuccess
        End Function



        ' *********
        ' * ITEMS *
        ' *********

        ' Apply Private Brand Label field to all items in batch

        Public Shared Function IsPack(ByVal itemHeaderID As Long) As Boolean
            Dim pack As Boolean = False
            Dim recCount As Integer = 0
            Dim sql As String = "select count(ID) as RecordCount from SPD_Items where Item_Header_ID = @itemHeaderID and COALESCE(RTRIM(REPLACE(LEFT([Pack_Item_Indicator],2), '-', '')), '') IN ('D','DP','SB')"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
                If recCount > 0 Then
                    pack = True
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
            Return pack
        End Function

        Public Shared Function IsPackByItem(ByVal itemID As Long) As Boolean
            Dim pack As Boolean = False
            Dim recCount As Integer = 0
            Dim sql As String = "select count(ID) as RecordCount from SPD_Items where Item_Header_ID = (select ISNULL(Item_Header_ID, 0) from SPD_Items where [ID] = @itemID) and COALESCE(RTRIM(REPLACE(LEFT([Pack_Item_Indicator],2), '-', '')), '') IN ('D','DP','SB')"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemID", SqlDbType.BigInt).Value = itemID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
                If recCount > 0 Then
                    pack = True
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
            Return pack
        End Function

        Public Shared Function GetPackInfo(ByVal itemID As Long) As ItemPackInfo
            Dim packInfo As ItemPackInfo
            packInfo.IsPack = False
            packInfo.IsPackWithDisplayer = False
            packInfo.IsPackWithDisplayPack = False
            packInfo.IsPackParent = False
            Dim recCount As Integer = 0
            Dim pii As String = String.Empty
            Dim sql As String = "select count(ID) as RecordCount from SPD_Items where Item_Header_ID = (select ISNULL(Item_Header_ID, 0) from SPD_Items where [ID] = @itemID) and COALESCE(RTRIM(REPLACE(LEFT([Pack_Item_Indicator],2), '-', '')), '') IN ('D','DP','SB'); "
            sql += "select count(ID) as RecordCount from SPD_Items where Item_Header_ID = (select ISNULL(Item_Header_ID, 0) from SPD_Items where [ID] = @itemID) and COALESCE(RTRIM(REPLACE(LEFT([Pack_Item_Indicator],2), '-', '')), '') IN ('D','SB'); "
            sql += "select count(ID) as RecordCount from SPD_Items where Item_Header_ID = (select ISNULL(Item_Header_ID, 0) from SPD_Items where [ID] = @itemID) and COALESCE(RTRIM(REPLACE(LEFT([Pack_Item_Indicator],2), '-', '')), '') = 'DP'; "
            sql += "select Pack_Item_Indicator from SPD_Items where [ID] = @itemID"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemID", SqlDbType.BigInt).Value = itemID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
                If recCount > 0 Then
                    packInfo.IsPack = True
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                    If recCount > 0 Then packInfo.IsPackWithDisplayer = True
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                    If recCount > 0 Then packInfo.IsPackWithDisplayPack = True
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    pii = DataHelper.SmartValues(reader.Item("Pack_Item_Indicator"), "string", True)
                    If pii.Length > 2 Then pii = pii.Substring(0, 2)
                    pii = pii.ToUpper().Replace("-", "")
                    If pii = "D" Or pii = "DP" Or pii = "SB" Then
                        packInfo.IsPackParent = True
                    End If
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
            Return packInfo
        End Function

        Public Function ApplyPBLToAll(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord, ByVal userID As Integer) As Boolean

            Dim sql As String = "usp_SPD_Item_ApplyPBLtoBatch"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bUpdated As Boolean = False

            Try
                'If objRecord.ID <= 0 Then
                '    objRecord.AuditType = AuditRecordType.Insert
                'Else
                '    objRecord.AuditType = AuditRecordType.Update
                'End If
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@RetValue", SqlDbType.Int)
                objParam.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(objParam)

                cmd.Parameters.Add("@ItemHeaderID", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ItemHeaderID, "long", True)
                cmd.Parameters.Add("@PrivateBrandLabel", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.PrivateBrandLabel, "string", True)
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                bUpdated = (cmd.Parameters("@RetValue").Value = 1)

                ' save audit record
                'If objRecord.SaveAudit Then
                '    objRecord.AuditRecordID = recordID
                '    Me.SaveAuditRecord(objRecord, conn)
                'End If

            Catch ex As Exception
                Logger.LogError(ex)
                'Throw ex
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
            Return bUpdated
        End Function


        Public Sub ClearStockingStrategy(ByVal ItemHeaderID As Int64, ByVal userID As Integer)

            Dim sql As String = "Update spd_items set Stocking_Strategy_Code = null, date_last_modified = getdate(), update_user_id = @UserID where item_header_id = @ItemHeaderID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            'Dim bUpdated As Boolean = False

            Try
                'If objRecord.ID <= 0 Then
                '    objRecord.AuditType = AuditRecordType.Insert
                'Else
                '    objRecord.AuditType = AuditRecordType.Update
                'End If
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                'objParam = New System.Data.SqlClient.SqlParameter("@RetValue", SqlDbType.Int)
                'objParam.Direction = ParameterDirection.ReturnValue
                'cmd.Parameters.Add(objParam)

                cmd.Parameters.Add("@ItemHeaderID", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(ItemHeaderID, "long", True)
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.Text
                cmd.ExecuteNonQuery()
                'bUpdated = (cmd.Parameters("@RetValue").Value = 1)

                ' save audit record
                'If objRecord.SaveAudit Then
                '    objRecord.AuditRecordID = recordID
                '    Me.SaveAuditRecord(objRecord, conn)
                'End If

            Catch ex As Exception
                Logger.LogError(ex)
                'Throw ex
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

        Public Function GetItemRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord
            Dim objRecord As ItemRecord = New ItemRecord()
            Dim sql As String = "sp_SPD_Item_GetRecord"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = .Item("ID")
                        objRecord.ItemHeaderID = DataHelper.SmartValues(.Item("Item_Header_ID"), "long", True)
                        objRecord.AddChange = DataHelper.SmartValues(.Item("Add_Change"), "string", True)
                        objRecord.PackItemIndicator = DataHelper.SmartValues(.Item("Pack_Item_Indicator"), "string", True)
                        objRecord.MichaelsSKU = DataHelper.SmartValues(.Item("Michaels_SKU"), "string", True)
                        objRecord.VendorUPC = DataHelper.SmartValues(.Item("Vendor_UPC"), "string", True)
                        objRecord.ClassNum = DataHelper.SmartValues(.Item("Class_Num"), "integer", True)
                        objRecord.SubClassNum = DataHelper.SmartValues(.Item("Sub_Class_Num"), "integer", True)
                        objRecord.VendorStyleNum = DataHelper.SmartValues(.Item("Vendor_Style_Num"), "string", True)
                        objRecord.ItemDesc = DataHelper.SmartValues(.Item("Item_Desc"), "string", True)
                        objRecord.HybridType = DataHelper.SmartValues(.Item("Hybrid_Type"), "string", True)
                        objRecord.HybridSourceDC = DataHelper.SmartValues(.Item("Hybrid_Source_DC"), "string", True)
                        objRecord.HybridLeadTime = DataHelper.SmartValues(.Item("Hybrid_Lead_Time"), "integer", True)
                        objRecord.HybridConversionDate = DataHelper.SmartValues(.Item("Hybrid_Conversion_Date"), "date", True)
                        objRecord.EachesMasterCase = DataHelper.SmartValues(.Item("Eaches_Master_Case"), "integer", True)
                        objRecord.EachesInnerPack = DataHelper.SmartValues(.Item("Eaches_Inner_Pack"), "integer", True)
                        objRecord.PrePriced = DataHelper.SmartValues(.Item("Pre_Priced"), "string", True)
                        objRecord.PrePricedUDA = DataHelper.SmartValues(.Item("Pre_Priced_UDA"), "string", True)
                        objRecord.USCost = DataHelper.SmartValues(.Item("US_Cost"), "decimal", True)
                        objRecord.CanadaCost = DataHelper.SmartValues(.Item("Canada_Cost"), "decimal", True)
                        objRecord.BaseRetail = DataHelper.SmartValues(.Item("Base_Retail"), "decimal", True)
                        objRecord.CentralRetail = DataHelper.SmartValues(.Item("Central_Retail"), "decimal", True)
                        objRecord.TestRetail = DataHelper.SmartValues(.Item("Test_Retail"), "decimal", True)
                        objRecord.AlaskaRetail = DataHelper.SmartValues(.Item("Alaska_Retail"), "decimal", True)
                        objRecord.CanadaRetail = DataHelper.SmartValues(.Item("Canada_Retail"), "decimal", True)
                        objRecord.ZeroNineRetail = DataHelper.SmartValues(.Item("Zero_Nine_Retail"), "decimal", True)
                        objRecord.CaliforniaRetail = DataHelper.SmartValues(.Item("California_Retail"), "decimal", True)
                        objRecord.VillageCraftRetail = DataHelper.SmartValues(.Item("Village_Craft_Retail"), "decimal", True)

                        objRecord.Retail9 = DataHelper.SmartValues(.Item("Retail9"), "decimal", True)
                        objRecord.Retail10 = DataHelper.SmartValues(.Item("Retail10"), "decimal", True)
                        objRecord.Retail11 = DataHelper.SmartValues(.Item("Retail11"), "decimal", True)
                        objRecord.Retail12 = DataHelper.SmartValues(.Item("Retail12"), "decimal", True)
                        objRecord.Retail13 = DataHelper.SmartValues(.Item("Retail13"), "decimal", True)
                        objRecord.RDQuebec = DataHelper.SmartValues(.Item("RDQuebec"), "decimal", True)
                        objRecord.RDPuertoRico = DataHelper.SmartValues(.Item("RDPuertoRico"), "decimal", True)
                        objRecord.POGSetupPerStore = DataHelper.SmartValues(.Item("POG_Setup_Per_Store"), "decimal", True)
                        objRecord.POGMaxQty = DataHelper.SmartValues(.Item("POG_Max_Qty"), "decimal", True)
                        'objRecord.ProjectedUnitSales = DataHelper.SmartValues(.Item("Projected_Unit_Sales"), "decimal", True)
                        objRecord.EachCaseHeight = DataHelper.SmartValues(.Item("Each_Case_Height"), "decimal", True)
                        objRecord.EachCaseWidth = DataHelper.SmartValues(.Item("Each_Case_Width"), "decimal", True)
                        objRecord.EachCaseLength = DataHelper.SmartValues(.Item("Each_Case_Length"), "decimal", True)
                        objRecord.EachCaseWeight = DataHelper.SmartValues(.Item("Each_Case_Weight"), "decimal", True)
                        objRecord.EachCasePackCube = DataHelper.SmartValues(.Item("Each_Case_Pack_Cube"), "decimal", True)
                        objRecord.InnerCaseHeight = DataHelper.SmartValues(.Item("Inner_Case_Height"), "decimal", True)
                        objRecord.InnerCaseWidth = DataHelper.SmartValues(.Item("Inner_Case_Width"), "decimal", True)
                        objRecord.InnerCaseLength = DataHelper.SmartValues(.Item("Inner_Case_Length"), "decimal", True)
                        objRecord.InnerCaseWeight = DataHelper.SmartValues(.Item("Inner_Case_Weight"), "decimal", True)
                        objRecord.InnerCasePackCube = DataHelper.SmartValues(.Item("Inner_Case_Pack_Cube"), "decimal", True)
                        objRecord.MasterCaseHeight = DataHelper.SmartValues(.Item("Master_Case_Height"), "decimal", True)
                        objRecord.MasterCaseWidth = DataHelper.SmartValues(.Item("Master_Case_Width"), "decimal", True)
                        objRecord.MasterCaseLength = DataHelper.SmartValues(.Item("Master_Case_Length"), "decimal", True)
                        objRecord.MasterCaseWeight = DataHelper.SmartValues(.Item("Master_Case_Weight"), "decimal", True)
                        objRecord.MasterCasePackCube = DataHelper.SmartValues(.Item("Master_Case_Pack_Cube"), "decimal", True)
                        objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("Country_Of_Origin"), "string", True)
                        objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("Country_Of_Origin_Name"), "string", True)
                        objRecord.TaxUDA = DataHelper.SmartValues(.Item("Tax_UDA"), "string", True)
                        objRecord.TaxValueUDA = DataHelper.SmartValues(.Item("Tax_Value_UDA"), "integer", True)
                        objRecord.Hazardous = DataHelper.SmartValues(.Item("Hazardous"), "string", True)
                        objRecord.HazardousFlammable = DataHelper.SmartValues(.Item("Hazardous_Flammable"), "string", True)
                        objRecord.HazardousContainerType = DataHelper.SmartValues(.Item("Hazardous_Container_Type"), "string", True)
                        objRecord.HazardousContainerSize = DataHelper.SmartValues(.Item("Hazardous_Container_Size"), "decimal", True)
                        objRecord.HazardousMSDSUOM = DataHelper.SmartValues(.Item("Hazardous_MSDS_UOM"), "string", True)
                        objRecord.HazardousManufacturerName = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_Name"), "string", True)
                        objRecord.HazardousManufacturerCity = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_City"), "string", True)
                        objRecord.HazardousManufacturerState = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_State"), "string", True)
                        objRecord.HazardousManufacturerPhone = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_Phone"), "string", True)
                        objRecord.HazardousManufacturerCountry = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_Country"), "string", True)
                        Dim iv As Int16 = DataHelper.SmartValues(.Item("Is_Valid"), "smallint", True)
                        If iv = 1 Then
                            objRecord.IsValid = ItemValidFlag.Valid
                        ElseIf iv = 0 Then
                            objRecord.IsValid = ItemValidFlag.NotValid
                        Else
                            objRecord.IsValid = ItemValidFlag.Unknown
                        End If

                        objRecord.LikeItemSKU = DataHelper.SmartValues(.Item("Like_Item_SKU"), "string", True)
                        objRecord.LikeItemDescription = DataHelper.SmartValues(.Item("Like_Item_Description"), "string", True)
                        objRecord.LikeItemRetail = DataHelper.SmartValues(.Item("Like_Item_Retail"), "decimal", True)
                        'lp fixes 02/18/2009
                        objRecord.LikeItemRegularUnit = DataHelper.SmartValues(.Item("Like_Item_Regular_Unit"), "decimal", True)
                        'objRecord.LikeItemSales = DataHelper.SmartValues(.Item("Like_Item_Sales"), "decimal", True)
                        objRecord.Facings = DataHelper.SmartValues(.Item("Facings"), "decimal", True)
                        '03132009
                        objRecord.LikeItemStoreCount = DataHelper.SmartValues(.Item("Like_Item_Store_Count"), "decimal", True)
                        objRecord.AnnualRegularUnitForecast = DataHelper.SmartValues(.Item("Annual_Regular_Unit_Forecast"), "decimal", True)
                        objRecord.AnnualRegRetailSales = DataHelper.SmartValues(.Item("Annual_Reg_Retail_Sales"), "decimal", True)
                        objRecord.LikeItemUnitStoreMonth = DataHelper.SmartValues(.Item("Like_Item_Unit_Store_Month"), "decimal", True)
                        'lp
                        objRecord.POGMinQty = DataHelper.SmartValues(.Item("POG_Min_Qty"), "decimal", True)

                        objRecord.HeaderStoreTotal = DataHelper.SmartValues(.Item("Store_Total"), "integer", True)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemUserData(objRecord, _
                            DataHelper.SmartValues(.Item("Date_Created"), "date", True), _
                            DataHelper.SmartValues(.Item("Created_User_ID"), "integer", True), _
                            DataHelper.SmartValues(.Item("Date_Last_Modified"), "date", True), _
                            DataHelper.SmartValues(.Item("Update_User_ID"), "integer", True), _
                            DataHelper.SmartValues(.Item("Created_User"), "string", True), _
                            DataHelper.SmartValues(.Item("Update_User"), "string", True), _
                            DataHelper.SmartValues(.Item("Image_File_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("MSDS_File_ID"), "long", True))

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemTaxWizard(objRecord, _
                            DataHelper.SmartValues(.Item("Tax_Wizard"), "boolean", False))

                        objRecord.AdditionalUPCRecord = AdditionalUPCsData.GetItemAdditionalUPCs(objRecord.ItemHeaderID, objRecord.ID)

                        'PMO200141 GTIN14 Enhancements changes
                        objRecord.VendorInnerGTIN = DataHelper.SmartValues(.Item("Vendor_Inner_GTIN"), "string", True)
                        objRecord.VendorCaseGTIN = DataHelper.SmartValues(.Item("Vendor_Case_GTIN"), "string", True)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemBatchData(objRecord, _
                            DataHelper.SmartValues(.Item("Batch_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("Stage_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("Stage_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Type_ID"), "integer", False))

                        objRecord.PrivateBrandLabel = DataHelper.SmartValues(.Item("Private_Brand_Label"), "string", True)

                        objRecord.QtyInPack = DataHelper.SmartValues(.Item("Qty_In_Pack"), "integer", True)
                        objRecord.TotalUSCost = DataHelper.SmartValues(.Item("Total_US_Cost"), "decimal", True)
                        objRecord.TotalCanadaCost = DataHelper.SmartValues(.Item("Total_Canada_Cost"), "decimal", True)

                        objRecord.ValidExistingSKU = DataHelper.SmartValues(.Item("Valid_Existing_SKU"), "boolean", True)
                        objRecord.ItemStatus = DataHelper.SmartValues(.Item("Item_Status"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("Stock_Category"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", True)
                        objRecord.DepartmentNum = DataHelper.SmartValues(.Item("Department_Num"), "integer", True)
                        objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", True)
                        objRecord.CustomsDescription = DataHelper.SmartValues(.Item("Customs_Description"), "string", True)

                        'New CRC Fields
                        objRecord.HarmonizedCodeNumber = DataHelper.SmartValues(.Item("Harmonized_Code_Number"), "string", True)
                        objRecord.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(.Item("Canada_Harmonized_Code_Number"), "string", True)
                        objRecord.DetailInvoiceCustomsDesc = DataHelper.SmartValues(.Item("Detail_Invoice_Customs_Desc"), "string", True)
                        objRecord.ComponentMaterialBreakdown = DataHelper.SmartValues(.Item("Component_Material_Breakdown"), "string", True)

                        objRecord.StockingStrategyCode = DataHelper.SmartValues(.Item("Stocking_Strategy_Code"), "string", True)
                        objRecord.PhytoSanitaryCertificate = DataHelper.SmartValues(.Item("PhytoSanitaryCertificate"), "string", True)
                        objRecord.PhytoTemporaryShipment = DataHelper.SmartValues(.Item("PhytoTemporaryShipment"), "string", True)

                    End With
                Else
                    objRecord.ID = 0
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
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

        Public Function SaveItemRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord, ByVal userID As Integer, Optional ByVal isDirty As Boolean = True) As Long
            Dim sql As String = "sp_SPD_Item_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim recordID As Long = 0
            Try
                If objRecord.ID <= 0 Then
                    objRecord.AuditType = AuditRecordType.Insert
                Else
                    objRecord.AuditType = AuditRecordType.Update
                End If
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = objRecord.ID
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@Item_Header_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.ItemHeaderID, "long", True)
                cmd.Parameters.Add("@Add_Change", SqlDbType.VarChar, 10).Value = DataHelper.DBSmartValues(objRecord.AddChange, "string", True)
                cmd.Parameters.Add("@Pack_Item_Indicator", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.PackItemIndicator, "string", True)
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar, 10).Value = DataHelper.DBSmartValues(objRecord.MichaelsSKU, "string", True)
                cmd.Parameters.Add("@Vendor_UPC", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.VendorUPC, "string", True)
                cmd.Parameters.Add("@Class_Num", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.ClassNum, "integer", True)
                cmd.Parameters.Add("@Sub_Class_Num", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.SubClassNum, "integer", True)
                cmd.Parameters.Add("@Vendor_Style_Num", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.VendorStyleNum, "string", True)
                cmd.Parameters.Add("@Item_Desc", SqlDbType.VarChar, 30).Value = DataHelper.DBSmartValues(objRecord.ItemDesc, "string", True)
                cmd.Parameters.Add("@Hybrid_Type", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.HybridType, "string", True)
                cmd.Parameters.Add("@Hybrid_Source_DC", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.HybridSourceDC, "string", True)
                cmd.Parameters.Add("@Hybrid_Lead_Time", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.HybridLeadTime, "integer", True)
                cmd.Parameters.Add("@Hybrid_Conversion_Date", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.HybridConversionDate, "date", True)
                cmd.Parameters.Add("@Eaches_Master_Case", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.EachesMasterCase, "integer", True)
                cmd.Parameters.Add("@Eaches_Inner_Pack", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.EachesInnerPack, "integer", True)
                cmd.Parameters.Add("@Pre_Priced", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.PrePriced, "string", True)
                cmd.Parameters.Add("@Pre_Priced_UDA", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.PrePricedUDA, "string", True)
                cmd.Parameters.Add("@US_Cost", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.USCost, "decimal", True)
                cmd.Parameters.Add("@Canada_Cost", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.CanadaCost, "decimal", True)
                cmd.Parameters.Add("@Base_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.BaseRetail, "decimal", True)
                cmd.Parameters.Add("@Central_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.CentralRetail, "decimal", True)
                cmd.Parameters.Add("@Test_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.TestRetail, "decimal", True)
                cmd.Parameters.Add("@Alaska_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.AlaskaRetail, "decimal", True)
                cmd.Parameters.Add("@Canada_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.CanadaRetail, "decimal", True)
                cmd.Parameters.Add("@Zero_Nine_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.ZeroNineRetail, "decimal", True)
                cmd.Parameters.Add("@California_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.CaliforniaRetail, "decimal", True)
                cmd.Parameters.Add("@Village_Craft_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.VillageCraftRetail, "decimal", True)
                cmd.Parameters.Add("@POG_Setup_Per_Store", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.POGSetupPerStore, "decimal", True)
                cmd.Parameters.Add("@POG_Max_Qty", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.POGMaxQty, "decimal", True)
                'cmd.Parameters.Add("@Projected_Unit_Sales", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.ProjectedUnitSales, "decimal", True)
                cmd.Parameters.Add("@Inner_Case_Height", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.InnerCaseHeight, "decimal", True)
                cmd.Parameters.Add("@Inner_Case_Width", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.InnerCaseWidth, "decimal", True)
                cmd.Parameters.Add("@Inner_Case_Length", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.InnerCaseLength, "decimal", True)
                cmd.Parameters.Add("@Inner_Case_Weight", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.InnerCaseWeight, "decimal", True)
                cmd.Parameters.Add("@Inner_Case_Pack_Cube", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.InnerCasePackCube, "decimal", True)
                cmd.Parameters.Add("@Master_Case_Height", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.MasterCaseHeight, "decimal", True)
                cmd.Parameters.Add("@Master_Case_Width", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.MasterCaseWidth, "decimal", True)
                cmd.Parameters.Add("@Master_Case_Length", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.MasterCaseLength, "decimal", True)
                cmd.Parameters.Add("@Master_Case_Weight", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.MasterCaseWeight, "decimal", True)
                cmd.Parameters.Add("@Master_Case_Pack_Cube", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.MasterCasePackCube, "decimal", True)
                cmd.Parameters.Add("@Country_Of_Origin", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.CountryOfOrigin, "string", True)
                cmd.Parameters.Add("@Country_Of_Origin_Name", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.CountryOfOriginName, "string", True)

                cmd.Parameters.Add("@Tax_UDA", SqlDbType.VarChar, 2).Value = DataHelper.DBSmartValues(objRecord.TaxUDA, "string", True)
                cmd.Parameters.Add("@Tax_Value_UDA", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.TaxValueUDA, "integer", True)
                cmd.Parameters.Add("@Hazardous", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.Hazardous, "string", True)
                cmd.Parameters.Add("@Hazardous_Flammable", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.HazardousFlammable, "string", True)
                cmd.Parameters.Add("@Hazardous_Container_Type", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.HazardousContainerType, "string", True)
                cmd.Parameters.Add("@Hazardous_Container_Size", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.HazardousContainerSize, "decimal", True)
                cmd.Parameters.Add("@Hazardous_MSDS_UOM", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.HazardousMSDSUOM, "string", True)
                cmd.Parameters.Add("@Hazardous_Manufacturer_Name", SqlDbType.VarChar, 100).Value = DataHelper.DBSmartValues(objRecord.HazardousManufacturerName, "string", True)
                cmd.Parameters.Add("@Hazardous_Manufacturer_City", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.HazardousManufacturerCity, "string", True)
                cmd.Parameters.Add("@Hazardous_Manufacturer_State", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.HazardousManufacturerState, "string", True)
                cmd.Parameters.Add("@Hazardous_Manufacturer_Phone", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.HazardousManufacturerPhone, "string", True)
                cmd.Parameters.Add("@Hazardous_Manufacturer_Country", SqlDbType.VarChar, 100).Value = DataHelper.DBSmartValues(objRecord.HazardousManufacturerCountry, "string", True)

                cmd.Parameters.Add("@Is_Valid", SqlDbType.SmallInt).Value = objRecord.IsValid
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)

                cmd.Parameters.Add("@Like_Item_SKU", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.LikeItemSKU, "string", True)
                cmd.Parameters.Add("@Like_Item_Description", SqlDbType.VarChar, 255).Value = DataHelper.DBSmartValues(objRecord.LikeItemDescription, "string", True)
                cmd.Parameters.Add("@Like_Item_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.LikeItemRetail, "decimal", True)
                'lp fix
                cmd.Parameters.Add("@Like_Item_Regular_Units", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemRegularUnit, "decimal", True)
                'LP 031309
                cmd.Parameters.Add("@Like_Item_Store_Count", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemStoreCount, "decimal", True)
                cmd.Parameters.Add("@Annual_Regular_Unit_Forecast", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.AnnualRegularUnitForecast, "decimal", True)
                cmd.Parameters.Add("@Annual_Reg_Retail_Sales", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.AnnualRegRetailSales, "decimal", True)
                cmd.Parameters.Add("@Like_Item_Unit_Store_Month", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemUnitStoreMonth, "decimal", True)
                ' like item sales is absolite, disable soon
                'cmd.Parameters.Add("@Like_Item_Sales", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemSales, "decimal", True)
                '
                cmd.Parameters.Add("@Facings", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Facings, "decimal", True)
                cmd.Parameters.Add("@POG_Min_Qty", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.POGMinQty, "decimal", True)
                'lp change order 14
                cmd.Parameters.Add("@Retail9", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail9, "decimal", True)
                cmd.Parameters.Add("@Retail10", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail10, "decimal", True)
                cmd.Parameters.Add("@Retail11", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail11, "decimal", True)
                cmd.Parameters.Add("@Retail12", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail12, "decimal", True)
                cmd.Parameters.Add("@Retail13", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail13, "decimal", True)
                cmd.Parameters.Add("@RDQuebec", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.RDQuebec, "decimal", True)
                cmd.Parameters.Add("@RDPuertoRico", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.RDPuertoRico, "decimal", True)
                cmd.Parameters.Add("@Private_Brand_Label", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.PrivateBrandLabel, "string", True)
                cmd.Parameters.Add("@Qty_In_Pack", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.QtyInPack, "integer", True)
                cmd.Parameters.Add("@Total_US_Cost", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.TotalUSCost, "decimal", True)
                cmd.Parameters.Add("@Total_Canada_Cost", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.TotalCanadaCost, "decimal", True)
                cmd.Parameters.Add("@Valid_Existing_SKU", SqlDbType.Bit).Value = DataHelper.DBSmartValues(objRecord.ValidExistingSKU, "boolean", True)
                cmd.Parameters.Add("@Item_Status", SqlDbType.VarChar, 10).Value = DataHelper.DBSmartValues(objRecord.ItemStatus, "string", True)
                cmd.Parameters.Add("@Stock_Category", SqlDbType.VarChar, 5).Value = DataHelper.DBSmartValues(objRecord.StockCategory, "string", True)
                cmd.Parameters.Add("@Item_Type_Attribute", SqlDbType.VarChar, 5).Value = DataHelper.DBSmartValues(objRecord.ItemTypeAttribute, "string", True)
                cmd.Parameters.Add("@Department_Num", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.DepartmentNum, "integer", True)
                cmd.Parameters.Add("@QuoteReferenceNumber", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.QuoteReferenceNumber, "string", True)
                cmd.Parameters.Add("@CustomsDescription", SqlDbType.VarChar, 1000).Value = DataHelper.DBSmartValues(objRecord.CustomsDescription, "string", True)
                cmd.Parameters.Add("@HarmonizedCodeNumber", SqlDbType.VarChar, 10).Value = DataHelper.DBSmartValues(objRecord.HarmonizedCodeNumber, "string", True)
                cmd.Parameters.Add("@CanadaHarmonizedCodeNumber", SqlDbType.VarChar, 10).Value = DataHelper.DBSmartValues(objRecord.CanadaHarmonizedCodeNumber, "string", True)
                cmd.Parameters.Add("@DetailInvoiceCustomsDesc", SqlDbType.VarChar, 35).Value = DataHelper.DBSmartValues(objRecord.DetailInvoiceCustomsDesc, "string", True)
                cmd.Parameters.Add("@ComponentMaterialBreakdown", SqlDbType.VarChar, 35).Value = DataHelper.DBSmartValues(objRecord.ComponentMaterialBreakdown, "string", True)
                cmd.Parameters.Add("@IsDirty", SqlDbType.Bit).Value = DataHelper.DBSmartValues(isDirty, "boolean", True)
                cmd.Parameters.Add("@StockingStrategyCode", SqlDbType.NVarChar, 5).Value = DataHelper.DBSmartValues(objRecord.StockingStrategyCode, "string", True)
                cmd.Parameters.Add("@Each_Case_Height", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachCaseHeight, "decimal", True)
                cmd.Parameters.Add("@Each_Case_Width", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachCaseWidth, "decimal", True)
                cmd.Parameters.Add("@Each_Case_Length", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachCaseLength, "decimal", True)
                cmd.Parameters.Add("@Each_Case_Weight", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachCaseWeight, "decimal", True)
                cmd.Parameters.Add("@Each_Case_Pack_Cube", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachCasePackCube, "decimal", True)
                'PMO200141 GTIN14 Enhancements changes
                cmd.Parameters.Add("@Vendor_Inner_GTIN", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.VendorInnerGTIN, "string", True)
                cmd.Parameters.Add("@Vendor_Case_GTIN", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.VendorCaseGTIN, "string", True)

                cmd.Parameters.Add("@PhytoSanitaryCertificate", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.PhytoSanitaryCertificate, "string", True)
                cmd.Parameters.Add("@PhytoTemporaryShipment", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.PhytoTemporaryShipment, "string", True)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                recordID = cmd.Parameters("@ID").Value

                Debug.Assert(objRecord.ID <= 0 OrElse (objRecord.ID > 0 And objRecord.ID = recordID))
                ' must set the record ID so that the addiational upc values have the proper ID when saving.
                objRecord.ID = recordID

                ' save additional upcs
                If Not objRecord.AdditionalUPCRecord Is Nothing Then
                    AdditionalUPCsData.SaveItemAdditionalUPCs(objRecord.AdditionalUPCRecord, userID, conn)
                End If

                ' save audit record
                If objRecord.SaveAudit Then
                    objRecord.AuditRecordID = recordID
                    Me.SaveAuditRecord(objRecord, conn)
                End If

            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
                recordID = 0
                'Throw ex
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

        Public Function DeleteItemRecord(ByVal id As Long, ByVal userID As Integer) As Boolean
            Dim sql As String = "sp_SPD_Item_DeleteRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                cmd.Parameters.Add(objParam)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

                Dim audit As New AuditRecord()
                audit.SetupAudit(MetadataTable.Items, id, AuditRecordType.Delete, userID)
                Me.SaveAuditRecord(audit, conn)
                audit = Nothing

            Catch ex As Exception
                Logger.LogError(ex)

                bSuccess = False
                'Throw ex
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
            Return bSuccess
        End Function

        Public Function GetItemValidationUnknownCount(ByVal itemHeaderID As Long) As Integer
            Dim recCount As Integer = 0
            Dim sql As String = "select count(ID) as RecordCount from SPD_Items where Item_Header_ID = @itemHeaderID and ISNULL(Is_Valid, -1) = -1"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
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
            Return recCount
        End Function

        Public Function GetItemListCount(ByVal itemHeaderID As Long, ByVal xmlSortCriteria As String, ByVal userID As Long) As Integer
            Dim listCount As Integer = 0
            Dim sql As String = "sp_SPD_Item_GetListCount"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
                cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.NVarChar, -1).Value = xmlSortCriteria
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    listCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
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
            Return listCount
        End Function

        Public Function GetItemList(ByVal itemHeaderID As Long, ByVal startRow As Integer, ByVal pageSize As Integer, ByVal xmlSortCriteria As String, ByVal userID As Long) As ItemList
            Dim objItemsList As ItemList = New ItemList()
            Dim objRecord As ItemRecord
            Dim sql As String = "sp_SPD_Item_GetList"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim conn2 As DBConnection = Nothing
            Dim iv As Int16
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn2 = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
                cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = startRow
                cmd.Parameters.Add("@pageSize", SqlDbType.Int).Value = pageSize
                cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.NVarChar, -1).Value = xmlSortCriteria
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    objItemsList.TotalRecords = DataHelper.SmartValues(reader.Item("totRecords"), "integer", False)
                Else
                    objItemsList.TotalRecords = 0
                End If
                Do While bRead
                    objRecord = New ItemRecord()
                    With reader
                        objRecord.ID = .Item("ID")
                        objRecord.ItemHeaderID = DataHelper.SmartValues(.Item("Item_Header_ID"), "long", True)
                        objRecord.AddChange = DataHelper.SmartValues(.Item("Add_Change"), "string", True)
                        objRecord.PackItemIndicator = DataHelper.SmartValues(.Item("Pack_Item_Indicator"), "string", True)
                        objRecord.MichaelsSKU = DataHelper.SmartValues(.Item("Michaels_SKU"), "string", True)
                        objRecord.VendorUPC = DataHelper.SmartValues(.Item("Vendor_UPC"), "string", True)
                        objRecord.ClassNum = DataHelper.SmartValues(.Item("Class_Num"), "integer", True)
                        objRecord.SubClassNum = DataHelper.SmartValues(.Item("Sub_Class_Num"), "integer", True)
                        objRecord.VendorStyleNum = DataHelper.SmartValues(.Item("Vendor_Style_Num"), "string", True)
                        objRecord.ItemDesc = DataHelper.SmartValues(.Item("Item_Desc"), "string", True)
                        objRecord.HybridType = DataHelper.SmartValues(.Item("Hybrid_Type"), "string", True)
                        objRecord.HybridSourceDC = DataHelper.SmartValues(.Item("Hybrid_Source_DC"), "string", True)
                        objRecord.HybridLeadTime = DataHelper.SmartValues(.Item("Hybrid_Lead_Time"), "integer", True)
                        objRecord.HybridConversionDate = DataHelper.SmartValues(.Item("Hybrid_Conversion_Date"), "date", True)
                        objRecord.EachesMasterCase = DataHelper.SmartValues(.Item("Eaches_Master_Case"), "integer", True)
                        objRecord.EachesInnerPack = DataHelper.SmartValues(.Item("Eaches_Inner_Pack"), "integer", True)
                        objRecord.PrePriced = DataHelper.SmartValues(.Item("Pre_Priced"), "string", True)
                        objRecord.PrePricedUDA = DataHelper.SmartValues(.Item("Pre_Priced_UDA"), "string", True)
                        objRecord.USCost = DataHelper.SmartValues(.Item("US_Cost"), "decimal", True)
                        objRecord.CanadaCost = DataHelper.SmartValues(.Item("Canada_Cost"), "decimal", True)
                        objRecord.BaseRetail = DataHelper.SmartValues(.Item("Base_Retail"), "decimal", True)
                        objRecord.CentralRetail = DataHelper.SmartValues(.Item("Central_Retail"), "decimal", True)
                        objRecord.TestRetail = DataHelper.SmartValues(.Item("Test_Retail"), "decimal", True)
                        objRecord.AlaskaRetail = DataHelper.SmartValues(.Item("Alaska_Retail"), "decimal", True)
                        objRecord.CanadaRetail = DataHelper.SmartValues(.Item("Canada_Retail"), "decimal", True)
                        objRecord.ZeroNineRetail = DataHelper.SmartValues(.Item("Zero_Nine_Retail"), "decimal", True)
                        objRecord.CaliforniaRetail = DataHelper.SmartValues(.Item("California_Retail"), "decimal", True)
                        objRecord.VillageCraftRetail = DataHelper.SmartValues(.Item("Village_Craft_Retail"), "decimal", True)
                        'lp change order 14
                        objRecord.Retail9 = DataHelper.SmartValues(.Item("Retail9"), "decimal", True)
                        objRecord.Retail10 = DataHelper.SmartValues(.Item("Retail10"), "decimal", True)
                        objRecord.Retail11 = DataHelper.SmartValues(.Item("Retail11"), "decimal", True)
                        objRecord.Retail12 = DataHelper.SmartValues(.Item("Retail12"), "decimal", True)
                        objRecord.Retail13 = DataHelper.SmartValues(.Item("Retail13"), "decimal", True)
                        objRecord.RDQuebec = DataHelper.SmartValues(.Item("RDQuebec"), "decimal", True)
                        objRecord.RDPuertoRico = DataHelper.SmartValues(.Item("RDPuertoRico"), "decimal", True)
                        '-------------change order 14
                        objRecord.POGSetupPerStore = DataHelper.SmartValues(.Item("POG_Setup_Per_Store"), "decimal", True)
                        objRecord.POGMaxQty = DataHelper.SmartValues(.Item("POG_Max_Qty"), "decimal", True)
                        'objRecord.ProjectedUnitSales = DataHelper.SmartValues(.Item("Projected_Unit_Sales"), "decimal", True)
                        objRecord.EachCaseHeight = DataHelper.SmartValues(.Item("Each_Case_Height"), "decimal", True)
                        objRecord.EachCaseWidth = DataHelper.SmartValues(.Item("Each_Case_Width"), "decimal", True)
                        objRecord.EachCaseLength = DataHelper.SmartValues(.Item("Each_Case_Length"), "decimal", True)
                        objRecord.EachCaseWeight = DataHelper.SmartValues(.Item("Each_Case_Weight"), "decimal", True)
                        objRecord.EachCasePackCube = DataHelper.SmartValues(.Item("Each_Case_Pack_Cube"), "decimal", True)
                        objRecord.InnerCaseHeight = DataHelper.SmartValues(.Item("Inner_Case_Height"), "decimal", True)
                        objRecord.InnerCaseWidth = DataHelper.SmartValues(.Item("Inner_Case_Width"), "decimal", True)
                        objRecord.InnerCaseLength = DataHelper.SmartValues(.Item("Inner_Case_Length"), "decimal", True)
                        objRecord.InnerCaseWeight = DataHelper.SmartValues(.Item("Inner_Case_Weight"), "decimal", True)
                        objRecord.InnerCasePackCube = DataHelper.SmartValues(.Item("Inner_Case_Pack_Cube"), "decimal", True)
                        objRecord.MasterCaseHeight = DataHelper.SmartValues(.Item("Master_Case_Height"), "decimal", True)
                        objRecord.MasterCaseWidth = DataHelper.SmartValues(.Item("Master_Case_Width"), "decimal", True)
                        objRecord.MasterCaseLength = DataHelper.SmartValues(.Item("Master_Case_Length"), "decimal", True)
                        objRecord.MasterCaseWeight = DataHelper.SmartValues(.Item("Master_Case_Weight"), "decimal", True)
                        objRecord.MasterCasePackCube = DataHelper.SmartValues(.Item("Master_Case_Pack_Cube"), "decimal", True)
                        objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("Country_Of_Origin"), "string", True)
                        objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("Country_Of_Origin_Name"), "string", True)
                        objRecord.TaxUDA = DataHelper.SmartValues(.Item("Tax_UDA"), "string", True)
                        objRecord.TaxValueUDA = DataHelper.SmartValues(.Item("Tax_Value_UDA"), "integer", True)
                        objRecord.Hazardous = DataHelper.SmartValues(.Item("Hazardous"), "string", True)
                        objRecord.HazardousFlammable = DataHelper.SmartValues(.Item("Hazardous_Flammable"), "string", True)
                        objRecord.HazardousContainerType = DataHelper.SmartValues(.Item("Hazardous_Container_Type"), "string", True)
                        objRecord.HazardousContainerSize = DataHelper.SmartValues(.Item("Hazardous_Container_Size"), "decimal", True)
                        objRecord.HazardousMSDSUOM = DataHelper.SmartValues(.Item("Hazardous_MSDS_UOM"), "string", True)
                        objRecord.HazardousManufacturerName = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_Name"), "string", True)
                        objRecord.HazardousManufacturerCity = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_City"), "string", True)
                        objRecord.HazardousManufacturerState = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_State"), "string", True)
                        objRecord.HazardousManufacturerPhone = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_Phone"), "string", True)
                        objRecord.HazardousManufacturerCountry = DataHelper.SmartValues(.Item("Hazardous_Manufacturer_Country"), "string", True)
                        iv = DataHelper.SmartValues(.Item("Is_Valid"), "smallint", True)
                        If iv = 1 Then
                            objRecord.IsValid = ItemValidFlag.Valid
                        ElseIf iv = 0 Then
                            objRecord.IsValid = ItemValidFlag.NotValid
                        Else
                            objRecord.IsValid = ItemValidFlag.Unknown
                        End If

                        objRecord.LikeItemSKU = DataHelper.SmartValues(.Item("Like_Item_SKU"), "string", True)
                        objRecord.LikeItemDescription = DataHelper.SmartValues(.Item("Like_Item_Description"), "string", True)
                        objRecord.LikeItemRetail = DataHelper.SmartValues(.Item("Like_Item_Retail"), "decimal", True)
                        objRecord.LikeItemRegularUnit = DataHelper.SmartValues(.Item("Like_Item_Regular_Unit"), "decimal", True)
                        'like item sales is no longer required fiels
                        'objRecord.LikeItemSales = DataHelper.SmartValues(.Item("Like_Item_Sales"), "decimal", True)
                        objRecord.Facings = DataHelper.SmartValues(.Item("Facings"), "decimal", True)
                        'LP 03 18 2009
                        objRecord.LikeItemStoreCount = DataHelper.SmartValues(.Item("Like_Item_Store_Count"), "decimal", True)
                        objRecord.AnnualRegularUnitForecast = DataHelper.SmartValues(.Item("Annual_Regular_Unit_Forecast"), "decimal", True)
                        objRecord.AnnualRegRetailSales = DataHelper.SmartValues(.Item("Annual_Reg_Retail_Sales"), "decimal", True)
                        objRecord.LikeItemUnitStoreMonth = DataHelper.SmartValues(.Item("Like_Item_Unit_Store_Month"), "decimal", True)
                        'LP
                        objRecord.POGMinQty = DataHelper.SmartValues(.Item("POG_Min_Qty"), "decimal", True)
                        objRecord.HeaderStoreTotal = DataHelper.SmartValues(.Item("Store_Total"), "integer", True)

                        'PMO200141 GTIN14 Enhancements changes
                        objRecord.VendorInnerGTIN = DataHelper.SmartValues(.Item("Vendor_Inner_GTIN"), "string", True)
                        objRecord.VendorCaseGTIN = DataHelper.SmartValues(.Item("Vendor_Case_GTIN"), "string", True)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemUserData(objRecord, _
                            DataHelper.SmartValues(.Item("Date_Created"), "date", True), _
                            DataHelper.SmartValues(.Item("Created_User_ID"), "integer", True), _
                            DataHelper.SmartValues(.Item("Date_Last_Modified"), "date", True), _
                            DataHelper.SmartValues(.Item("Update_User_ID"), "integer", True), _
                            DataHelper.SmartValues(.Item("Created_User"), "string", True), _
                            DataHelper.SmartValues(.Item("Update_User"), "string", True), _
                            DataHelper.SmartValues(.Item("Image_File_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("MSDS_File_ID"), "long", True))

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemTaxWizard(objRecord, _
                            DataHelper.SmartValues(.Item("Tax_Wizard"), "boolean", False))

                        objRecord.AdditionalUPCRecord = AdditionalUPCsData.GetItemAdditionalUPCs(objRecord.ItemHeaderID, objRecord.ID)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetItemBatchData(objRecord, _
                            DataHelper.SmartValues(.Item("Batch_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("Stage_ID"), "long", True), _
                            DataHelper.SmartValues(.Item("Stage_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Type_ID"), "integer", False))

                        objRecord.PrivateBrandLabel = DataHelper.SmartValues(.Item("Private_Brand_Label"), "string", True)

                        objRecord.QtyInPack = DataHelper.SmartValues(.Item("Qty_In_Pack"), "integer", True)
                        objRecord.TotalUSCost = DataHelper.SmartValues(.Item("Total_US_Cost"), "decimal", True)
                        objRecord.TotalCanadaCost = DataHelper.SmartValues(.Item("Total_Canada_Cost"), "decimal", True)

                        objRecord.ValidExistingSKU = DataHelper.SmartValues(.Item("Valid_Existing_SKU"), "boolean", True)
                        objRecord.ItemStatus = DataHelper.SmartValues(.Item("Item_Status"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("Stock_Category"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", True)
                        objRecord.DepartmentNum = DataHelper.SmartValues(.Item("Department_Num"), "integer", True)
                        objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", True)
                        objRecord.CustomsDescription = DataHelper.SmartValues(.Item("Customs_Description"), "string", True)

                        objRecord.PLIEnglish = DataHelper.SmartValues(.Item("PLI_English"), "string", True)
                        objRecord.PLIFrench = DataHelper.SmartValues(.Item("PLI_French"), "string", True)
                        objRecord.PLISpanish = DataHelper.SmartValues(.Item("PLI_Spanish"), "string", True)
                        objRecord.TIEnglish = DataHelper.SmartValues(.Item("TI_English"), "string", True)
                        objRecord.TIFrench = DataHelper.SmartValues(.Item("TI_French"), "string", True)
                        objRecord.TISpanish = DataHelper.SmartValues(.Item("TI_Spanish"), "string", True)
                        objRecord.EnglishLongDescription = DataHelper.SmartValues(.Item("English_Long_Description"), "string", True)
                        objRecord.EnglishShortDescription = DataHelper.SmartValues(.Item("English_Short_Description"), "string", True)
                        objRecord.FrenchLongDescription = DataHelper.SmartValues(.Item("French_Long_Description"), "string", True)
                        objRecord.FrenchShortDescription = DataHelper.SmartValues(.Item("French_Short_Description"), "string", True)
                        objRecord.SpanishLongDescription = DataHelper.SmartValues(.Item("Spanish_Long_Description"), "string", True)
                        objRecord.SpanishShortDescription = DataHelper.SmartValues(.Item("Spanish_Short_Description"), "string", True)
                        objRecord.ExemptEndDateFrench = DataHelper.SmartValues(.Item("Exempt_End_Date_French"), "string", True)

                        'New CRC Fields
                        objRecord.HarmonizedCodeNumber = DataHelper.SmartValues(.Item("Harmonized_Code_Number"), "string", True)
                        objRecord.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(.Item("Canada_Harmonized_Code_Number"), "string", True)
                        objRecord.DetailInvoiceCustomsDesc = DataHelper.SmartValues(.Item("Detail_Invoice_Customs_Desc"), "string", True)
                        objRecord.ComponentMaterialBreakdown = DataHelper.SmartValues(.Item("Component_Material_Breakdown"), "string", True)

                        objRecord.StockingStrategyCode = DataHelper.SmartValues(.Item("Stocking_Strategy_Code"), "string", True)

                        objRecord.PhytoSanitaryCertificate = DataHelper.SmartValues(.Item("PhytoSanitaryCertificate"), "string", True)
                        objRecord.PhytoTemporaryShipment = DataHelper.SmartValues(.Item("PhytoTemporaryShipment"), "string", True)


                    End With
                    objItemsList.ListRecords.Add(objRecord)
                    bRead = reader.Read()
                Loop
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
                    conn.Close()
                    conn.Dispose()
                    conn = Nothing
                End If
                If Not conn2 Is Nothing Then
                    conn2.Close()
                    conn2.Dispose()
                    conn2 = Nothing
                End If
            End Try
            Return objItemsList
        End Function

        ' ******************
        ' * ITEM LANGUAGES *
        ' ******************

        Public Shared Sub SaveEditedLanguage(ByVal itemID As Integer, ByVal languageTypeID As Integer)
            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Item_Languages_Edited", conn)
                        cmd.CommandType = CommandType.StoredProcedure

                        cmd.Parameters.AddWithValue("@ItemID", itemID)
                        cmd.Parameters.AddWithValue("@LanguageTypeID", languageTypeID)

                        cmd.ExecuteNonQuery()
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw
            End Try
        End Sub

        Public Shared Sub SaveItemLanguage(ByVal itemID As Integer, ByVal languageTypeID As Integer, ByVal pli As String, ByVal ti As String, ByVal descShort As String, ByVal descLong As String, ByVal userID As Integer)
            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Item_Languages_InsertUpdate", conn)
                        cmd.CommandType = CommandType.StoredProcedure

                        cmd.Parameters.AddWithValue("@ItemID", itemID)
                        cmd.Parameters.AddWithValue("@LanguageTypeID", languageTypeID)
                        cmd.Parameters.AddWithValue("@PackageLanguageIndicator", pli)
                        cmd.Parameters.AddWithValue("@TranslationIndicator", ti)
                        cmd.Parameters.AddWithValue("@DescriptionShort", descShort)
                        cmd.Parameters.AddWithValue("@DescriptionLong", descLong)
                        cmd.Parameters.AddWithValue("@UserID", userID)
                        
                        cmd.ExecuteNonQuery()
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw
            End Try

        End Sub

        Public Shared Function GetItemLanguages(ByVal ItemID As Integer) As DataTable
            Dim dt As New DataTable

            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Item_Languages_GetByItemID", conn)
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.Parameters.AddWithValue("@ItemID", ItemID)
                        cmd.CommandTimeout = 1800

                        Using da As New SqlDataAdapter(cmd)
                            da.Fill(dt)
                        End Using   'da
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw ex
            End Try

            Return dt
        End Function

        ' ******************
        ' * ADDITIONAL UPC *
        ' ******************

        'Public Function GetItemAdditionalUPCs(ByVal itemHeaderID As Long, ByVal itemID As Long) As ItemAdditionalUPCRecord
        '    Return GetItemAdditionalUPCs(itemHeaderID, itemID, Nothing)
        'End Function

        'Public Function GetItemAdditionalUPCs(ByVal itemHeaderID As Long, ByVal itemID As Long, ByRef dbconn As DBConnection) As ItemAdditionalUPCRecord
        '    Dim objRecord As New ItemAdditionalUPCRecord(itemHeaderID, itemID)
        '    Dim sql As String = "sp_SPD_Item_Additional_UPC_GetList"
        '    Dim reader As DBReader = Nothing
        '    Dim cmd As DBCommand
        '    Dim connCreated As Boolean = False
        '    Dim conn As DBConnection = Nothing
        '    Dim additionalUPC As String = String.Empty
        '    Try
        '        If Not dbconn Is Nothing Then
        '            conn = dbconn
        '        Else
        '            conn = Utilities.ApplicationHelper.GetAppConnection()
        '            connCreated = False
        '        End If
        '        reader = New DBReader(conn)
        '        cmd = reader.Command
        '        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
        '        cmd.Parameters.Add("@itemID", SqlDbType.BigInt).Value = itemID
        '        reader.CommandText = sql
        '        reader.CommandType = CommandType.StoredProcedure
        '        reader.Open()
        '        Do While reader.Read()
        '            With reader
        '                additionalUPC = DataHelper.SmartValues(.Item("Additional_UPC"), "string", True)
        '            End With
        '            objRecord.AddAdditionalUPC(additionalUPC)
        '        Loop
        '    Catch sqlex As SqlException
        '        Logger.LogError(sqlex)
        '        Throw sqlex
        '    Catch ex As Exception
        '        Logger.LogError(ex)
        '        Throw ex
        '    Finally
        '        cmd = Nothing
        '        If Not reader Is Nothing Then
        '            reader.Dispose()
        '            reader = Nothing
        '        End If
        '        If Not conn Is Nothing AndAlso connCreated Then
        '            conn.Dispose()
        '            conn = Nothing
        '        Else
        '            conn = Nothing
        '        End If
        '    End Try
        '    Return objRecord
        'End Function

        'Public Function SaveItemAdditionalUPCs(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord, ByVal userID As Integer) As Boolean
        '    Return SaveItemAdditionalUPCs(objRecord, userID, Nothing)
        'End Function
        'Public Function SaveItemAdditionalUPCs(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord, ByVal userID As Integer, ByRef dbconn As DBConnection) As Boolean
        '    Dim sql As String = "sp_SPD_Item_Additional_UPC_SaveRecord"
        '    Dim cmd As DBCommand = Nothing
        '    Dim objParam As System.Data.SqlClient.SqlParameter
        '    Dim connCreated As Boolean = False
        '    Dim conn As DBConnection = Nothing
        '    'Dim recordID As Long = 0
        '    Dim bSuccess As Boolean = True
        '    Try
        '        If Not dbconn Is Nothing Then
        '            conn = dbconn
        '        Else
        '            conn = Utilities.ApplicationHelper.GetAppConnection()
        '            connCreated = True
        '        End If

        '        cmd = New DBCommand(conn)
        '        cmd.CommandText = sql
        '        cmd.CommandType = CommandType.StoredProcedure
        '        objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
        '        objParam.Direction = ParameterDirection.InputOutput

        '        For i As Integer = 0 To objRecord.AdditionalUPCs.Count - 1
        '            cmd.Parameters.Clear()
        '            objParam.Value = 0
        '            cmd.Parameters.Add(objParam)
        '            cmd.Parameters.Add("@Item_Header_ID", SqlDbType.BigInt).Value = objRecord.ItemHeaderID
        '            cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = objRecord.ItemID
        '            cmd.Parameters.Add("@Sequence", SqlDbType.Int).Value = (i + 1)
        '            cmd.Parameters.Add("@Additional_UPC", SqlDbType.VarChar, 20).Value = objRecord.AdditionalUPCs.Item(i)
        '            cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
        '            cmd.ExecuteNonQuery()
        '            'recordID = cmd.Parameters("@ID").Value
        '        Next

        '        DeleteItemAdditionalUPCFromSequence(objRecord.ItemHeaderID, objRecord.ItemID, objRecord.AdditionalUPCs.Count + 1, conn)

        '    Catch ex As Exception
        '        Logger.LogError(ex)
        '        bSuccess = False
        '        Throw ex
        '    Finally
        '        If Not cmd Is Nothing Then
        '            cmd.Dispose()
        '            cmd = Nothing
        '        End If
        '        If Not conn Is Nothing AndAlso connCreated Then
        '            conn.Dispose()
        '            conn = Nothing
        '        Else
        '            conn = Nothing
        '        End If
        '    End Try
        '    Return bSuccess
        'End Function

        'Public Function DeleteItemAdditionalUPCFromSequence(ByVal itemHeaderID As Long, ByVal itemID As Long, ByVal startingSequence As Integer) As Boolean
        '    Return DeleteItemAdditionalUPCFromSequence(itemHeaderID, itemID, startingSequence, Nothing)
        'End Function
        'Public Function DeleteItemAdditionalUPCFromSequence(ByVal itemHeaderID As Long, ByVal itemID As Long, ByVal startingSequence As Integer, ByRef dbconn As DBConnection) As Boolean
        '    Dim sql As String = "sp_SPD_Item_Additional_UPC_DeleteFromSequence"
        '    Dim cmd As DBCommand = Nothing
        '    Dim connCreated As Boolean = False
        '    Dim conn As DBConnection = Nothing
        '    Dim bSuccess As Boolean = True
        '    Try
        '        If Not dbconn Is Nothing Then
        '            conn = dbconn
        '        Else
        '            conn = Utilities.ApplicationHelper.GetAppConnection()
        '            connCreated = True
        '        End If

        '        cmd = New DBCommand(conn)
        '        cmd.Parameters.Add("@Item_Header_ID", SqlDbType.BigInt).Value = itemHeaderID
        '        cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = itemID
        '        cmd.Parameters.Add("@Starting_Sequence", SqlDbType.Int).Value = startingSequence
        '        cmd.CommandText = sql
        '        cmd.CommandType = CommandType.StoredProcedure
        '        cmd.ExecuteNonQuery()
        '    Catch ex As Exception
        '        Logger.LogError(ex)

        '        bSuccess = False
        '        'Throw ex
        '    Finally
        '        If Not cmd Is Nothing Then
        '            cmd.Dispose()
        '            cmd = Nothing
        '        End If
        '        If Not conn Is Nothing AndAlso connCreated Then
        '            conn.Dispose()
        '            conn = Nothing
        '        Else
        '            conn = Nothing
        '        End If
        '    End Try
        '    Return bSuccess
        'End Function



        ' *****************
        ' * TAX QUESTIONS *
        ' *****************

        Public Function GetTaxWizardDataRecord(ByVal itemType As TaxWizardData.TaxWizardItemType, ByVal itemID As Long, ByVal userID As Long) As TaxWizardData
            Dim objTW As TaxWizardData = New TaxWizardData()
            Dim sql As String = "sp_SPD_TaxWizard_GetRecord"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@Item_Type", SqlDbType.VarChar, 1).Value = CType(IIf(itemType = TaxWizardData.TaxWizardItemType.Domestic, "D", "I"), String)
                cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = itemID
                cmd.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    objTW.ItemType = itemType
                    objTW.TaxUDAID = DataHelper.SmartValues(reader.Item("Tax_UDA_ID"), "long", False)
                    objTW.ItemID = DataHelper.SmartValues(reader.Item("Item_ID"), "long", False)
                    If reader.NextResult() Then
                        Do While reader.Read()
                            objTW.Add(DataHelper.SmartValues(reader.Item("Tax_Question_ID"), "long", False))
                        Loop
                    End If
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
            Return objTW
        End Function

        Public Function SaveTaxWizardDataRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData, ByVal userID As Long) As Boolean
            Dim sql As String = "sp_SPD_TaxWizard_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim ret As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@Item_Type", SqlDbType.VarChar, 1).Value = CType(IIf(objRecord.ItemType = TaxWizardData.TaxWizardItemType.Domestic, "D", "I"), String)
                cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.ItemID, "long", False)
                cmd.Parameters.Add("@Tax_UDA_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.TaxUDAID, "long", False)
                Dim taxQuestions As String = String.Empty
                For i As Integer = 0 To objRecord.TaxQuestions.Count - 1
                    If taxQuestions <> String.Empty Then
                        taxQuestions = taxQuestions & ","
                    End If
                    taxQuestions = taxQuestions & objRecord.Item(i).ToString()
                Next
                cmd.Parameters.Add("@Tax_Question_IDs", SqlDbType.VarChar, 8000).Value = DataHelper.DBSmartValues(taxQuestions, "string", False)
                cmd.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(userID, "long", False)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
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

        Public Function GetTaxUDANumber(ByVal taxUDAID As Long) As Integer
            Dim taxUDANumber As Integer = 0
            Dim sql As String = "select Tax_UDA_Number from [SPD_Tax_UDA] where [ID] = @ID"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = taxUDAID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    taxUDANumber = DataHelper.SmartValues(reader.Item("Tax_UDA_Number"), "integer", False)
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
            Return taxUDANumber
        End Function

        Public Function GetTaxQuestions(ByVal taxUDAID As Integer) As TaxQuestions
            Dim objItemsList As TaxQuestions = New TaxQuestions()
            Dim objRecord As TaxQuestionRecord
            Dim sql As String = "sp_SPD_Tax_Question_GetQuestions"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@taxID", SqlDbType.Int).Value = taxUDAID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                Do While bRead
                    objRecord = New TaxQuestionRecord()
                    With reader
                        objRecord.ID = .Item("ID")
                        objRecord.TaxUDAID = DataHelper.SmartValues(.Item("Tax_UDA_ID"), "integer", True)
                        objRecord.ParentTaxQuestionID = DataHelper.SmartValues(.Item("Parent_Tax_Question_ID"), "long", True)
                        objRecord.TaxQuestion = DataHelper.SmartValues(.Item("Tax_Question"), "string", True)
                        objRecord.SortOrder = DataHelper.SmartValues(.Item("SortOrder"), "string", True)
                        objRecord.ChildrenCount = DataHelper.SmartValues(.Item("numChildren"), "string", True)
                    End With
                    objItemsList.Questions.Add(objRecord)
                    bRead = reader.Read()
                Loop
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
            Return objItemsList
        End Function


        ' ******************
        ' * FIELD AUDITING *
        ' ******************

        Public Function SaveAuditRecordForItemHeader(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecord, ByVal itemHeaderID As Long) As Boolean
            Dim sql As String = "select [ID] from SPD_Items where Item_Header_ID = @itemHeaderID"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim conn2 As DBConnection = Nothing
            Dim bRet As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn2 = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                Do While reader.Read()
                    With reader
                        objRecord.AuditRecordID = .Item("ID")
                        SaveAuditRecord(objRecord, conn2)
                    End With
                Loop
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
                bRet = False
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
                bRet = False
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
                If Not conn2 Is Nothing Then
                    conn2.Dispose()
                    conn2 = Nothing
                End If
            End Try
            Return bRet
        End Function

        Public Shared Function GetGridPrice(ByVal Zone As Integer, ByVal BasePrice As Decimal) As Decimal

            Dim conn As DBConnection = Nothing
            Dim cmd As DBCommand = Nothing
            Dim reader As DBReader = Nothing
            Dim sql As String = "SP_SPD2_PriceGrid_ZonePrice"

            Dim retvalue As Decimal

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()

                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@Zone", SqlDbType.VarChar).Value = Zone
                cmd.Parameters.Add("@BaseRetail", SqlDbType.VarChar).Value = BasePrice
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read()
                    retvalue = DataHelper.SmartValues(reader.Item("Diff_Retail"), "decimal", False)
                Loop

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

            Return retvalue

        End Function

        'Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        '    If Not Me.disposed Then
        '        If disposing Then
        '            ' Insert code to free unmanaged resources.
        '        End If
        '        ' Insert code to free shared resources.
        '    End If
        '    MyBase.Dispose(disposing)
        'End Sub

        'Public Sub New()
        '    MyBase.New()
        'End Sub
    End Class
End Namespace


