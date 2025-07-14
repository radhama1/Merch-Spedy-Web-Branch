Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Collections.Generic
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels


Namespace Michaels

    Public Class BatchData

        Public Shared Function UpdateNIFromIM(ByVal BatchID As Long, ByVal ItemID As Long) As Boolean
            Dim sql As String = "usp_SPD_UpdateNewItemFromIM"
            Dim ret As Boolean = True
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim PackType As String = "", PackCount As Integer = 0, PackErrorMsg As String = "", recCount As Integer = 0
            Dim StockCat As String = "", ItemTypeAttr As String = ""
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@BatchID", SqlDbType.BigInt).Value = BatchID
                reader.Command.Parameters.Add("@ItemID", SqlDbType.BigInt).Value = ItemID
                reader.Command.Parameters.Add("@Force", SqlDbType.Int).Value = 1
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read Then
                    Dim cnt As Integer = reader.Item("UpdateCount")
                    If cnt = 0 Then ret = False
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
                ret = False
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
            Return ret
        End Function

        ' fill out the pack info for a New Item Batch
        Public Shared Function GetPackInfoFromNIBatch(ByRef batchRec As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord) As String
            Dim sql As String = "usp_SPD_Batch_GetNIPackInfo"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim PackType As String = "", PackCount As Integer = 0, PackErrorMsg As String = "", recCount As Integer = 0
            Dim StockCat As String = "", ItemTypeAttr As String = ""
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@BatchID", SqlDbType.BigInt).Value = batchRec.ID
                reader.Command.Parameters.Add("@BatchType", SqlDbType.Int).Value = batchRec.BatchTypeID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        recCount += 1
                        PackType = DataHelper.SmartValues(.Item("PackIndicator"), "string", True)
                        PackCount = DataHelper.SmartValues(.Item("NumRecs"), "integer", True)
                        StockCat = DataHelper.SmartValues(.Item("StockCategory"), "string", True)
                        ItemTypeAttr = DataHelper.SmartValues(.Item("ItemTypeAttr"), "string", True)

                        If PackCount <> 1 Then
                            PackErrorMsg = "Too Many records with Pack Type: " + PackType + " Found.  There should only be 1."
                            Exit Do
                        End If
                        If recCount > 1 Then
                            PackErrorMsg = "Too Many Pack Records exist in the batch. There should only be 1."
                            Exit Do
                        End If
                    End With
                Loop

                If recCount = 0 Then
                    PackErrorMsg = "No Pack Item Records found in Batch. Please correct and try again."
                End If

                If (StockCat = "" OrElse ItemTypeAttr = "") And UCase(PackType) = "DP" Then
                    PackErrorMsg = "With Display Packs (DP), the Pack Item must specify a Stock Category and Item Type Attribute.  Please correct and try again."
                End If

                If PackErrorMsg = "" Then
                    batchRec.PackType = PackType
                    batchRec.StockCategory = StockCat
                    batchRec.ItemTypeAttribute = ItemTypeAttr
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
            Return PackErrorMsg
        End Function

        Public Function GetIMBatchCount(ByVal batchID As Long) As Integer
            Dim sql As String = "usp_SPD_ItemMaint_GetBatchCount"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim recCount As Integer
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@BatchID", SqlDbType.BigInt)
                objParam.Value = batchID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        recCount = DataHelper.SmartValues(.Item("NumRecs"), "integer", True)
                    End With
                Else
                    recCount = 0
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                recCount = -1
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
            Return recCount
        End Function

        Public Function GetBatchRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord
            Dim objRecord As BatchRecord = New BatchRecord()
            Dim sql As String = "sp_SPD_Batch_GetRecord"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("Vendor_Name"), "string", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", True)
                        objRecord.BatchTypeID = DataHelper.SmartValues(.Item("Batch_Type_ID"), "integer", True)
                        objRecord.BatchTypeDesc = DataHelper.SmartValues(.Item("Batch_Type_Desc"), "string", True)
                        objRecord.WorkflowStageID = DataHelper.SmartValues(.Item("Workflow_Stage_ID"), "integer", True)
                        objRecord.FinelineDeptID = DataHelper.SmartValues(.Item("Fineline_Dept_ID"), "integer", True)
                        objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                        objRecord.IsValid = DataHelper.SmartValues(.Item("Is_Valid"), "integer", True)
                        objRecord.BatchValid = DataHelper.SmartValues(.Item("Batch_Valid"), "integer", True)
                        objRecord.WorkflowID = DataHelper.SmartValues(.Item("WorkFlow_ID"), "integer", True)
                        objRecord.EffectiveDate = DataHelper.SmartValues(.Item("Effective_Date"), "string", True)
                        objRecord.BatchName = DataHelper.SmartValues(.Item("Batch_Name"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("Stock_Category"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", True)
                        objRecord.PackType = DataHelper.SmartValues(.Item("Pack_Type"), "string", True)
                        objRecord.PackSKU = DataHelper.SmartValues(.Item("Pack_SKU"), "string", True)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetBatchData(objRecord, _
                            DataHelper.SmartValues(.Item("Date_Created"), "date", True), _
                            DataHelper.SmartValues(.Item("Created_User"), "integer", True), _
                            DataHelper.SmartValues(.Item("Date_Modified"), "date", True), _
                            DataHelper.SmartValues(.Item("Modified_User"), "integer", True), _
                            DataHelper.SmartValues(.Item("Created_User_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Modified_User_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Type_ID"), "integer", False))

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

        Public Function CreateBatch(ByVal WorkflowType As String, ByVal batchType As Integer, ByVal DeptNo As Integer, ByVal VendorNo As Integer, ByVal VendorName As String, _
                    ByVal UserID As Integer, Optional ByVal StockCat As String = "", Optional ByVal itemTypeAttr As String = "", Optional ByVal packType As String = "", _
                    Optional ByVal packSKU As String = "", Optional ByVal BatchName As String = "", Optional ByVal workflowStageID As Integer = Integer.MinValue, Optional ByVal MSSBatch As Boolean = False) As Long

            Dim objRecord As BatchRecord = New BatchRecord
            Dim batchID As Long
            ' Dim objData = New Data.Michaels.VendorData
            Try
                objRecord.WorkflowID = WorkflowType
                objRecord.FinelineDeptID = DeptNo
                objRecord.BatchTypeID = batchType
                objRecord.BatchName = BatchName
                objRecord.VendorName = VendorName
                objRecord.VendorNumber = VendorNo
                objRecord.StockCategory = StockCat
                objRecord.ItemTypeAttribute = itemTypeAttr
                objRecord.PackType = packType
                objRecord.PackSKU = packSKU
                objRecord.WorkflowStageID = workflowStageID

                batchID = SaveBatchRecord(objRecord, UserID, "Created", "", MSSBatch)

                objRecord = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                batchID = -2
            End Try
            Return batchID
        End Function

        Public Function SaveBatchRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord, _
                ByVal userID As Integer, Optional ByVal BatchAction As String = "", Optional ByVal BatchNotes As String = "", Optional ByVal MSSBatch As Boolean = False) As Long
            Dim sql As String = "sp_SPD_Batch_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim recordID As Long = 0
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn.Open()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = objRecord.ID
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@Vendor_Name", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorName, "string", True)
                cmd.Parameters.Add("@Vendor_Number", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.VendorNumber, "long", True)
                cmd.Parameters.Add("@Batch_Type_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.BatchTypeID, "integer", True)
                cmd.Parameters.Add("@Workflow_Stage_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.WorkflowStageID, "integer", True)
                cmd.Parameters.Add("@Fineline_Dept_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.FinelineDeptID, "integer", True)
                cmd.Parameters.Add("@Enabled", SqlDbType.Bit).Value = DataHelper.DBSmartValues(objRecord.Enabled, "boolean", True)
                cmd.Parameters.Add("@Is_Valid", SqlDbType.SmallInt).Value = DataHelper.DBSmartValues(objRecord.IsValid, "integer", True)
                cmd.Parameters.Add("@StockCategory", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.StockCategory, "string", True)
                cmd.Parameters.Add("@ItemTypeAttr", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ItemTypeAttribute, "string", True)
                cmd.Parameters.Add("@PackType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PackType, "string", True)
                cmd.Parameters.Add("@PackSKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PackSKU, "string", True)

                cmd.Parameters.Add("@Batch_Action", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(BatchAction, "string", True)
                cmd.Parameters.Add("@Batch_Notes", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(BatchNotes, "string", True)
                cmd.Parameters.Add("@MSSBatch", SqlDbType.Bit).Value = DataHelper.DBSmartValues(MSSBatch, "boolean", True)

                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)

                If objRecord.WorkflowID <> Integer.MinValue Then
                    cmd.Parameters.Add("@WorkflowID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.WorkflowID, "integer", True)
                End If
                If objRecord.BatchName <> String.Empty Then
                    cmd.Parameters.Add("@BatchName", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.BatchName, "string", True)
                End If

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                recordID = cmd.Parameters("@ID").Value
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

        Public Shared Function SaveBatchEffectiveDate(ByVal ID As Long, ByVal effectiveDate As Date, ByVal userID As Integer) As Boolean
            Dim sql As String = "update SPD_Batch set Effective_Date = @effectiveDate, date_modified = getdate(), modified_user = @userID where [ID] = @ID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim ret As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn.Open()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = ID
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@effectiveDate", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(effectiveDate, "date", True)
                cmd.Parameters.Add("@userID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.Text
                cmd.ExecuteNonQuery()
                ret = True
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        Public Function DeleteBatchRecord(ByVal id As Long) As Boolean
            Dim sql As String = "sp_SPD_Batch_DeleteRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn.Open()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                cmd.Parameters.Add(objParam)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
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

        Public Function GetItemMaitenanceWorkflows(Optional ByVal ID As Integer = 0, Optional ByVal UserID As Integer = 0) As List(Of Workflow)
            Dim RecList As List(Of Workflow) = New List(Of Workflow)
            Dim sql As String = String.Empty
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim objRecord As Workflow

            Try
                conn = NovaLibra.Coral.Data.Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                sql = "usp_SPD_Workflow_GetItemMaint"
                If ID > 0 Then cmd.Parameters.Add("@ID", SqlDbType.Int).Value = ID
                If UserID > 0 Then cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = UserID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    objRecord = New Workflow
                    With reader
                        objRecord.ID = .Item("Workflow_id")
                        objRecord.WorkFlowName = DataHelper.SmartValues(.Item("Workflow_Name"), "string", False)
                        objRecord.WorkFlowDescription = DataHelper.SmartValues(.Item("Workflow_Description"), "string", False)
                        objRecord.WorkflowShortName = DataHelper.SmartValues(.Item("Workflow_ShortName"), "string", False)
                    End With
                    RecList.Add(objRecord)
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
            Return RecList
        End Function

        Public Function GetBatchesBySKU(ByVal sku As String) As List(Of BatchRecord)
            Dim batchList As New List(Of BatchRecord)

            Dim sql As String = "usp_SPD_ItemMaint_GetBatchesBySKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@MichaelsSKU", SqlDbType.VarChar)
                objParam.Value = sku
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        Dim objRecord As BatchRecord = New BatchRecord()
                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("Vendor_Name"), "string", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", True)
                        objRecord.BatchTypeID = DataHelper.SmartValues(.Item("Batch_Type_ID"), "integer", True)
                        objRecord.BatchTypeDesc = DataHelper.SmartValues(.Item("Batch_Type_Desc"), "string", True)
                        objRecord.WorkflowStageID = DataHelper.SmartValues(.Item("Workflow_Stage_ID"), "integer", True)
                        objRecord.FinelineDeptID = DataHelper.SmartValues(.Item("Fineline_Dept_ID"), "integer", True)
                        objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                        objRecord.IsValid = DataHelper.SmartValues(.Item("Is_Valid"), "integer", True)
                        objRecord.BatchValid = DataHelper.SmartValues(.Item("Batch_Valid"), "integer", True)
                        objRecord.WorkflowID = DataHelper.SmartValues(.Item("WorkFlow_ID"), "integer", True)
                        objRecord.EffectiveDate = DataHelper.SmartValues(.Item("Effective_Date"), "string", True)
                        objRecord.BatchName = DataHelper.SmartValues(.Item("Batch_Name"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("Stock_Category"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", True)
                        objRecord.PackType = DataHelper.SmartValues(.Item("Pack_Type"), "string", True)
                        objRecord.PackSKU = DataHelper.SmartValues(.Item("Pack_SKU"), "string", True)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetBatchData(objRecord, _
                            DataHelper.SmartValues(.Item("Date_Created"), "date", True), _
                            DataHelper.SmartValues(.Item("Created_User"), "integer", True), _
                            DataHelper.SmartValues(.Item("Date_Modified"), "date", True), _
                            DataHelper.SmartValues(.Item("Modified_User"), "integer", True), _
                            DataHelper.SmartValues(.Item("Created_User_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Modified_User_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Type_ID"), "integer", False))

                        batchList.Add(objRecord)
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

            Return batchList
        End Function

        Public Function GetBatchesBySKUVendor(ByVal sku As String, ByVal vendorNumber As Integer) As List(Of BatchRecord)
            Dim batchList As New List(Of BatchRecord)

            Dim sql As String = "usp_SPD_ItemMaint_GetBatchesBySKUVendor"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@MichaelsSKU", SqlDbType.VarChar)
                objParam.Value = sku
                reader.Command.Parameters.Add(objParam)

                objParam = New System.Data.SqlClient.SqlParameter("@VendorNumber", SqlDbType.Int)
                objParam.Value = vendorNumber
                reader.Command.Parameters.Add(objParam)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        Dim objRecord As BatchRecord = New BatchRecord()
                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("Vendor_Name"), "string", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", True)
                        objRecord.BatchTypeID = DataHelper.SmartValues(.Item("Batch_Type_ID"), "integer", True)
                        objRecord.BatchTypeDesc = DataHelper.SmartValues(.Item("Batch_Type_Desc"), "string", True)
                        objRecord.WorkflowStageID = DataHelper.SmartValues(.Item("Workflow_Stage_ID"), "integer", True)
                        objRecord.FinelineDeptID = DataHelper.SmartValues(.Item("Fineline_Dept_ID"), "integer", True)
                        objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                        objRecord.IsValid = DataHelper.SmartValues(.Item("Is_Valid"), "integer", True)
                        objRecord.BatchValid = DataHelper.SmartValues(.Item("Batch_Valid"), "integer", True)
                        objRecord.WorkflowID = DataHelper.SmartValues(.Item("WorkFlow_ID"), "integer", True)
                        objRecord.EffectiveDate = DataHelper.SmartValues(.Item("Effective_Date"), "string", True)
                        objRecord.BatchName = DataHelper.SmartValues(.Item("Batch_Name"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("Stock_Category"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", True)
                        objRecord.PackType = DataHelper.SmartValues(.Item("Pack_Type"), "string", True)
                        objRecord.PackSKU = DataHelper.SmartValues(.Item("Pack_SKU"), "string", True)

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetBatchData(objRecord, _
                            DataHelper.SmartValues(.Item("Date_Created"), "date", True), _
                            DataHelper.SmartValues(.Item("Created_User"), "integer", True), _
                            DataHelper.SmartValues(.Item("Date_Modified"), "date", True), _
                            DataHelper.SmartValues(.Item("Modified_User"), "integer", True), _
                            DataHelper.SmartValues(.Item("Created_User_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Modified_User_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Name"), "string", True), _
                            DataHelper.SmartValues(.Item("Stage_Type_ID"), "integer", False))

                        batchList.Add(objRecord)
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

            Return batchList
        End Function


        Public Shared Sub UpdateMSSBatch(ByVal id As Integer, ByVal mssBatch As Boolean)
            Dim sql As String = "sp_SPD_Batch_UpdateMSSBatch"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn.Open()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(id, "integer", True)
                cmd.Parameters.Add("@mssBatch", SqlDbType.Bit).Value = DataHelper.DBSmartValues(mssBatch, "boolean", True)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

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

        ' ******************
        ' * WORKFLOW STAGE *
        ' ******************

        Public Function GetStageList(Optional ByVal ID As Integer = 0, Optional ByVal workflowID As Integer = 0) As ArrayList
            Dim objList As ArrayList = New ArrayList()
            Dim objRecord As WorkflowStage
            '            Dim sql As String = "select id, stage_name from SPD_Workflow_Stage order by sequence"
            Dim sql As String = "usp_SPD_WorkflowStage_GetData"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                'cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID

                If ID > 0 Then
                    Dim objParam As System.Data.SqlClient.SqlParameter = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.Int)
                    objParam.Value = ID
                    reader.Command.Parameters.Add(objParam)
                End If
                If workflowID > 0 Then
                    reader.Command.Parameters.Add("@Workflow", SqlDbType.Int).Value = DataHelper.DBSmartValues(workflowID, "integer", True)
                End If

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                Do While bRead
                    objRecord = New WorkflowStage()
                    With reader
                        objRecord.ID = .Item("id")
                        objRecord.StageName = DataHelper.SmartValues(.Item("stage_name"), "string", True)
                        objRecord.NextStage = DataHelper.SmartValues(.Item("Default_NextStage_ID"), "integer", True)
                        objRecord.PreviousStage = DataHelper.SmartValues(.Item("Default_PrevStage_ID"), "integer", True)
                    End With
                    objList.Add(objRecord)
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
            Return objList
        End Function

        Public Function GetStageListDict(Optional ByVal ID As Integer = 0) As Dictionary(Of Integer, WorkflowStage)

            ' FJL Mar 2010 use a dictionary to store the workflow stages to make it easy to find records by ID
            Dim objList As Dictionary(Of Integer, WorkflowStage) = New Dictionary(Of Integer, WorkflowStage)
            Dim objRecord As WorkflowStage
            '            Dim sql As String = "select id, stage_name from SPD_Workflow_Stage order by sequence"
            Dim sql As String = "usp_SPD_WorkflowStage_GetData"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                'cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID

                If ID > 0 Then
                    Dim objParam As System.Data.SqlClient.SqlParameter = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.Int)
                    objParam.Value = ID
                    reader.Command.Parameters.Add(objParam)
                End If
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                bRead = reader.Read()
                Do While bRead
                    objRecord = New WorkflowStage()
                    With reader
                        objRecord.ID = .Item("id")
                        objRecord.StageName = DataHelper.SmartValues(.Item("stage_name"), "string", True)
                        objRecord.NextStage = DataHelper.SmartValues(.Item("Default_NextStage_ID"), "integer", True)
                        objRecord.PreviousStage = DataHelper.SmartValues(.Item("Default_PrevStage_ID"), "integer", True)
                        objList.Add(.Item("id"), objRecord)
                    End With
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
            Return objList
        End Function

        ' *****************
        ' * FINELINE DEPT *
        ' *****************

        Public Function GetDeptList() As ArrayList
            Dim objList As ArrayList = New ArrayList()
            Dim objRecord As FinelineDept
            Dim sql As String = "select DEPT, DEPT_NAME from SPD_Fineline_Dept where [enabled] = 1 order by DEPT"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                'cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                bRead = reader.Read()
                Do While bRead
                    objRecord = New FinelineDept()
                    With reader
                        objRecord.Dept = .Item("DEPT")
                        objRecord.DeptName = DataHelper.SmartValues(.Item("DEPT_NAME"), "string", True)
                    End With
                    objList.Add(objRecord)
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
            Return objList
        End Function

        ' ***********************
        ' * PRICE POINT LOOKUPS *
        ' ***********************

        Public Function GetPricePointRecord(ByVal diffZoneID As Integer, ByVal baseRetail As Decimal) As NovaLibra.Coral.SystemFrameworks.Michaels.PricePointRecord
            Dim objRecord As PricePointRecord = Nothing
            Dim sql As String = "select BASE_ZONE_ID, DIFF_ZONE_ID, BASE_RETAIL, DIFF_RETAIL from [spd_price_point] where (@diffZoneID is not null and DIFF_ZONE_ID = @diffZoneID) and (@baseRetail is not null and BASE_RETAIL = @baseRetail) "
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@diffZoneID", SqlDbType.Int).Value = DataHelper.DBSmartValues(diffZoneID, "integer", True)
                reader.Command.Parameters.Add("@baseRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(baseRetail, "decimal", True)
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    objRecord = New PricePointRecord()
                    With reader
                        objRecord.BaseZoneID = DataHelper.SmartValues(.Item("BASE_ZONE_ID"), "integer", True)
                        objRecord.DiffZoneID = DataHelper.SmartValues(.Item("DIFF_ZONE_ID"), "integer", True)
                        objRecord.BaseRetail = DataHelper.SmartValues(.Item("BASE_RETAIL"), "decimal", True)
                        objRecord.DiffRetail = DataHelper.SmartValues(.Item("DIFF_RETAIL"), "decimal", True)
                    End With
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
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

        ' *******************
        ' * COUNTRY LOOKUPS *
        ' *******************

        Public Function GetCountryRecord(ByVal country As String) As NovaLibra.Coral.SystemFrameworks.Michaels.CountryRecord
            Dim objRecord As CountryRecord = Nothing
            ' (... COUNTRY_NAME like (@country + '%') or ...UPPER(
            Dim sql As String = "select COUNTRY_CODE, COUNTRY_NAME from [SPD_Country] where (@country is not null and (UPPER(@country) = UPPER(COUNTRY_NAME) or UPPER(@country) = UPPER(SHORT_NAME_10) or UPPER(@country) = UPPER(COUNTRY_CODE) or UPPER(@country) = UPPER(COUNTRY_CODE_3))) "
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@country", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(country, "string", True)
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    objRecord = New CountryRecord()
                    With reader
                        objRecord.CountryName = DataHelper.SmartValues(.Item("COUNTRY_NAME"), "string", True).ToString().Trim()
                        objRecord.CountryCode = DataHelper.SmartValues(.Item("COUNTRY_CODE"), "string", True).ToString().Trim()
                    End With
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
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

        Public Function GetCountries(ByVal countryPart As String) As ArrayList
            Dim objRecord As ArrayList = New ArrayList()
            Dim sql As String = "select COUNTRY_NAME from [SPD_Country] where (@country is not null and (COUNTRY_NAME like (@country + '%') or UPPER(@country) = UPPER(COUNTRY_NAME) or UPPER(@country) = UPPER(SHORT_NAME_10) or UPPER(@country) = UPPER(COUNTRY_CODE) or UPPER(@country) = UPPER(COUNTRY_CODE_3))) order by COUNTRY_NAME "
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@country", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(countryPart, "string", True)
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                Dim country As String
                Do While reader.Read()
                    With reader
                        country = DataHelper.SmartValues(.Item("COUNTRY_NAME"), "string", True)
                        objRecord.Add(country.Trim())
                    End With
                Loop
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
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

        Public Function GetVendorName(ByVal vendorID As Integer) As String
            Dim sql As String = "usp_SPD_Vendors_GetRecords"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim desc As String = String.Empty
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@vendorID", SqlDbType.Int).Value = vendorID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        desc = DataHelper.SmartValues(.Item("Vendor_Name"), "string", True)
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
            Return desc

        End Function

        Public Function GetVendors(ByVal vendorPart As String) As List(Of VendorRecord)
            Dim vendors As List(Of VendorRecord) = New List(Of VendorRecord)
            Dim record As VendorRecord
            Dim sql As String = "usp_SPD_Vendors_GetRecords"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@vendor", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(vendorPart, "string", True)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read()
                    With reader
                        record = New VendorRecord
                        record.VendorName = DataHelper.SmartValues(.Item("Vendor_Name"), "string", True)
                        record.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "integer", True)
                        vendors.Add(record)
                    End With
                Loop
            Catch ex As Exception
                Logger.LogError(ex)
                vendors = Nothing
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
            Return vendors
        End Function


        ' ***********************
        ' * ITEM MASTER LOOKUPS *
        ' ***********************

        Public Function GetItemMasterRecord(ByVal itemSKU As String) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMasterRecord
            Dim objRecord As ItemMasterRecord = Nothing
            Dim sql As String = "select Michaels_SKU, Item_Desc, Base1_Retail from SPD_Item_Master_SKU where Michaels_SKU = @item "
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@item", SqlDbType.VarChar, 255).Value = DataHelper.DBSmartValues(itemSKU, "string", True)
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    objRecord = New ItemMasterRecord()
                    With reader
                        objRecord.Item = DataHelper.SmartValues(.Item("Michaels_SKU"), "string", True)
                        objRecord.ItemDescription = DataHelper.SmartValues(.Item("Item_Desc"), "string", True)
                        objRecord.BaseRetail = DataHelper.SmartValues(.Item("Base1_Retail"), "decimal", True)
                    End With
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
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

        ' *******************************
        ' * BATCH USER VALIDATION STAGE *
        ' *******************************

        Public Shared Function ValidateUserForBatch(ByVal batchID As Integer, ByVal userID As Integer, ByVal vendorID As Integer) As NovaLibra.Coral.SystemFrameworks.Michaels.BatchAccess
            Dim userAccess As NovaLibra.Coral.SystemFrameworks.Michaels.BatchAccess = BatchAccess.None
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@batchID", SqlDbType.Int).Value = batchID
                reader.Command.Parameters.Add("@userID", SqlDbType.Int).Value = userID
                reader.Command.Parameters.Add("@vendorID", SqlDbType.Int).Value = vendorID

                reader.Command.CommandTimeout = 1800
                reader.CommandText = "usp_Approval_ValidateUser"
                reader.CommandType = CommandType.StoredProcedure

                reader.Open()
                If reader.Read() Then
                    With reader
                        If DataHelper.SmartValues(.Item("CanEdit"), "integer", False) <> 0 Then
                            userAccess = userAccess Or BatchAccess.Edit Or BatchAccess.Delete
                        End If
                        If DataHelper.SmartValues(.Item("CanView"), "integer", False) <> 0 Then
                            userAccess = userAccess Or BatchAccess.View
                        End If
                    End With
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                userAccess = BatchAccess.None
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

        Public Function GetItemMaintBatchExport(ByVal batchID As Long) As DataTable
            Dim ret As DataTable = Nothing
            Dim dt As DBDataTable = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                dt = New DBDataTable(conn)
                dt.SelectCommand.Parameters.Add("@batchID", SqlDbType.Int)
                dt.SelectCommand.Parameters("@batchID").Value = batchID
                dt.SelectCommandText = "usp_SPD_ItemMaint_GetItemMaintBatchExport_By_BatchID"
                dt.SelectCommandType = CommandType.StoredProcedure
                dt.Open()
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            ret = dt.DataTable
            Return ret
        End Function

        Public Function GetItemMaintBatchItemList(ByVal batchID As Long) As DataTable
            Dim ret As DataTable = Nothing
            Dim dt As DBDataTable = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                dt = New DBDataTable(conn)
                dt.SelectCommand.Parameters.Add("@batchID", SqlDbType.Int)
                dt.SelectCommand.Parameters("@batchID").Value = batchID
                dt.SelectCommandText = "usp_SPD_ItemMaint_GetItemMaintBatchItemList_By_BatchID"
                dt.SelectCommandType = CommandType.StoredProcedure
                dt.Open()
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            ret = dt.DataTable
            Return ret
        End Function

        Public Function GetItemMaintBatchChangeList(ByVal imiID As Long) As DataTable
            Dim ret As DataTable = Nothing
            Dim dt As DBDataTable = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                dt = New DBDataTable(conn)
                dt.SelectCommand.Parameters.Add("@imiID", SqlDbType.Int)
                dt.SelectCommand.Parameters("@imiID").Value = imiID
                dt.SelectCommandText = "usp_SPD_ItemMaint_GetItemMaintBatchChangeList_By_ItemID"
                dt.SelectCommandType = CommandType.StoredProcedure
                dt.Open()
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            ret = dt.DataTable
            Return ret
        End Function

        Public Function GetStageID(ByVal workflowID As Integer, ByVal stageType As Integer) As Integer
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Dim WorkflowStageID As Integer = -1
            'Dim param As SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@WorkflowID", SqlDbType.Int).Value = workflowID
                reader.Command.Parameters.Add("@TypeID", SqlDbType.Int).Value = stageType
                reader.CommandText = "usp_SPD_WorkflowStage_LookupStage"
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read Then
                    WorkflowStageID = DataHelper.DBSmartValues(reader("StageID"), "integer", True)
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
            Return WorkflowStageID
        End Function

    End Class


End Namespace


