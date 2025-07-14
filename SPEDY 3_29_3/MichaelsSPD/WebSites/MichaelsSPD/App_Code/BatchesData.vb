Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports system.Collections.generic
Imports Microsoft.VisualBasic
imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities

' Data access layer for Grids in Default.aspx

Public Class BatchesData

    Const cNEWBATCHROWCOUNT As String = "NewbatchRowCount"
    Const cIMBATCHROWCOUNT As String = "IMBatchRowCount"
    Const cITEMSEARCHCOUNT As String = "ItemSearchCount"
    Const cITEMFUTURECOSTCOUNT As String = "ItemFutureCostCount"


    ' Return count of records in full result set (non paged count)
    ' Provide overrides for the Count Methods as Object Data source calls it with the select method parms

    Public Shared Function GetNewBatchCount(ByVal stageId As Integer, ByVal batchSearch As String, ByVal userID As Integer, ByVal vendorID As Integer, _
            ByVal sortCol As String, ByVal sortDir As String, ByVal maxRows As Integer, ByVal rowIndex As Integer) As Integer
        Return GetNewBatchCount()
    End Function

    Public Shared Function GetNewBatchCount() As Integer
        Dim count As Integer
        Try
            count = HttpContext.Current.Items(cNEWBATCHROWCOUNT)
        Catch
            count = 0
        End Try
        Return count
    End Function

    ' Get New Item Batch Records. Returns a List of NewItemBatchRecord. 
    'Also saves the count of records in full result set (used by grid for paging) in the Current.Items Collection
    ' This function is called by the ObjectDataSource during the Bind event

    Public Shared Function GetNewBatchData(ByVal stageId As Integer, ByVal BatchSearch As String, ByVal userID As Integer, ByVal vendorID As Integer, _
        ByVal sortCol As String, ByVal sortDir As String, ByVal maxRows As Integer, ByVal rowIndex As Integer _
        ) As List(Of NewItemBatchRecord)

        Dim batchRecords As List(Of NewItemBatchRecord) = New List(Of NewItemBatchRecord)
        Dim sql As String = String.Empty
        Dim reader As DBReader = Nothing
        Dim cmd As DBCommand
        Dim conn As DBConnection = Nothing
        Dim objRecord As NewItemBatchRecord
        Dim totalRows As Integer

        Try
            conn = NovaLibra.Coral.Data.Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn)
            cmd = reader.Command

            'Create a SqlParameter object to hold the ReturnValue parameter 
            Dim totalRowsParm As New SqlParameter("@totalRows", SqlDbType.Int)
            totalRowsParm.Direction = ParameterDirection.ReturnValue
            cmd.Parameters.Add(totalRowsParm)

            If stageId <> -1 And stageId <> -2 Then cmd.Parameters.Add("@StageId", SqlDbType.Int).Value = stageId
            If stageId = -2 Then cmd.Parameters.Add("@Less48hours", SqlDbType.Int).Value = 1
            If BatchSearch <> String.Empty Then cmd.Parameters.Add("@SearchParm", SqlDbType.VarChar).Value = BatchSearch
            If userID <> -1 Then cmd.Parameters.Add("@UserId", SqlDbType.BigInt).Value = userID

            'add vendor id to prevent other vendors seeng each other items
            If vendorID > 0 Then cmd.Parameters.Add("@VendorID", SqlDbType.BigInt).Value = vendorID

            ' Sorting and Paging info
            If sortCol <> String.Empty Then cmd.Parameters.Add("@SortCol", SqlDbType.VarChar).Value = sortCol
            If sortDir <> String.Empty Then cmd.Parameters.Add("@SortDir", SqlDbType.Char).Value = sortDir
            If rowIndex > -1 Then cmd.Parameters.Add("@RowIndex", SqlDbType.Int).Value = rowIndex
            If maxRows > 0 Then cmd.Parameters.Add("@MaxRows", SqlDbType.Int).Value = maxRows

            ' Feb 2010.  Query split into two sep queries so that Execution plan of My_items does not cause slow down in the Other Queries
            If stageId = 0 And userID > 0 Then      ' My Items Query
                sql = "usp_SPD_GetNewItemBatches_MyItems_PS"
            Else                                    ' Every other Query
                sql = "usp_SPD_GetNewItemBatches_AllOther_PS"
            End If

            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Command.CommandTimeout = 1800
            reader.Open()

            Do While reader.Read()
                objRecord = New NewItemBatchRecord
                With reader
                    objRecord.Vendor = DataHelper.SmartValues(.Item("Vendor"), "string", False)
                    objRecord.Batch_Type_Desc = DataHelper.SmartValues(.Item("Batch_Type_Desc"), "string", False)
                    objRecord.Header_ID = DataHelper.SmartValues(.Item("Header_ID"), "string", False)
                    objRecord.ID = DataHelper.SmartValues(.Item("ID"), "integer", False)
                    objRecord.Dept = DataHelper.SmartValues(.Item("Dept"), "string", False)
                    objRecord.DateCreated = DataHelper.SmartValues(.Item("DateCreated"), "string", False)
                    objRecord.DateModified = DataHelper.SmartValues(.Item("DateModified"), "string", False)
                    objRecord.Valid = DataHelper.SmartValues(.Item("Valid"), "string", False)
                    objRecord.Workflow_Stage = DataHelper.SmartValues(.Item("Workflow_Stage"), "string", False)
                    objRecord.Approval_Name = DataHelper.SmartValues(.Item("Approval_Name"), "string", False)
                    objRecord.Workflow_Stage_ID = DataHelper.SmartValues(.Item("Workflow_Stage_ID"), "string", False)
                    objRecord.Stage_Type_ID = DataHelper.SmartValues(.Item("Stage_Type_ID"), "string", False)
                    objRecord.Stage_Sequence = DataHelper.SmartValues(.Item("Stage_Sequence"), "string", False)
                    objRecord.Dept_ID = DataHelper.SmartValues(.Item("Dept_ID"), "string", False)
                    objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", False)
                    objRecord.Item_Count = DataHelper.SmartValues(.Item("Item_Count"), "integer", False)
                    objRecord.CreatedBy = DataHelper.SmartValues(.Item("Created_By"), "long", True)
                End With
                batchRecords.Add(objRecord)
            Loop

            conn.Close()

            ' now get the number of rows returned.  Need to do this after connection is closed (don't ask me why)
            Try
                totalRows = CType(totalRowsParm.Value, Integer)
            Catch
                totalRows = 0
            End Try
            ' Save the total number of records that would be returned in a non paged recordset
            HttpContext.Current.Items(cNEWBATCHROWCOUNT) = totalRows

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw
        Catch ex As Exception
            Logger.LogError(ex)
            Throw
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

        Return batchRecords
    End Function

    Public Shared Function GetIMBatchCount(ByVal stageId As Integer, ByVal stageTypeId As Integer, ByVal wfID As Integer, ByVal batchSearch As String, ByVal userID As Integer, _
            ByVal vendorID As Integer, ByVal sortCol As String, ByVal sortDir As String, ByVal maxRows As Integer, ByVal rowIndex As Integer) As Integer
        Return GetIMBatchCount()
    End Function

    Public Shared Function GetIMBatchCount() As Integer
        Dim count As Integer
        Try
            count = HttpContext.Current.Items(cIMBATCHROWCOUNT)
        Catch
            count = 0
        End Try
        Return count
    End Function

    ' Get New Item Batch Records. Returns a List of NewItemBatchRecord. 
    'Also saves the count of records in full result set (used by grid for paging) in the Current.Items Collection
    ' This function is called by the ObjectDataSource during the Bind event

    Public Shared Function GetIMBatchData(ByVal stageId As Integer, ByVal stageTypeId As Integer, ByVal wfID As Integer, ByVal BatchSearch As String, ByVal userID As Integer, _
        ByVal vendorID As Integer, ByVal sortCol As String, ByVal sortDir As String, ByVal maxRows As Integer, ByVal rowIndex As Integer _
        ) As List(Of IMBatchRecord)

        Dim batchRecords As List(Of IMBatchRecord) = New List(Of IMBatchRecord)
        Dim sql As String = String.Empty
        Dim reader As SqlDataReader = Nothing
        Dim cmd As SqlCommand
        Dim conn As SqlConnection = Nothing
        Dim objRecord As IMBatchRecord
        Dim totalRows As Integer

        Try
            cmd = New SqlCommand()
            conn = New SqlConnection(ApplicationConnectionStrings.AppConnectionString)
            cmd.Connection = conn

            'Create a SqlParameter object to hold the ReturnValue parameter 
            Dim totalRowsParm As New SqlParameter("@totalRows", SqlDbType.Int)
            totalRowsParm.Direction = ParameterDirection.ReturnValue
            cmd.Parameters.Add(totalRowsParm)

            If wfID > 0 Then cmd.Parameters.Add("@WorkflowID", SqlDbType.Int).Value = wfID
            If stageId <> -1 And stageId <> -2 Then cmd.Parameters.Add("@StageId", SqlDbType.Int).Value = stageId
            If stageId = -2 Then cmd.Parameters.Add("@Less48hours", SqlDbType.Int).Value = 1
            If BatchSearch <> String.Empty Then cmd.Parameters.Add("@SearchParm", SqlDbType.VarChar).Value = BatchSearch
            If userID <> -1 Then cmd.Parameters.Add("@UserId", SqlDbType.BigInt).Value = userID

            'add vendor id to prevent other vendors seeng each other items
            If vendorID > 0 Then cmd.Parameters.Add("@VendorID", SqlDbType.BigInt).Value = vendorID

            ' Sorting and Paging info
            If sortCol <> String.Empty Then cmd.Parameters.Add("@SortCol", SqlDbType.VarChar).Value = sortCol
            If sortDir <> String.Empty Then cmd.Parameters.Add("@SortDir", SqlDbType.Char).Value = sortDir
            If rowIndex > -1 Then cmd.Parameters.Add("@RowIndex", SqlDbType.Int).Value = rowIndex
            If maxRows > 0 Then cmd.Parameters.Add("@MaxRows", SqlDbType.Int).Value = maxRows

            ' Feb 2010.  Query split into two sep queries so that Execution plan of My_items does not cause slow down in the Other Queries
            If stageTypeID = WorkflowStageType.Completed Then
                sql = "usp_SPD_GetIMBatches_Completed_PS"
            Else
                If stageId = 0 And userID > 0 Then      ' My Items Query
                    sql = "usp_SPD_GetIMBatches_MyItems_PS"
                Else                                    ' Every other Query
                    sql = "usp_SPD_GetIMBatches_AllOther_PS"
                End If
            End If

            cmd.CommandText = sql
            cmd.CommandTimeout = 1800
            cmd.CommandType = CommandType.StoredProcedure

            cmd.Connection.Open()
            reader = cmd.ExecuteReader()

            Do While reader.Read()
                objRecord = New IMBatchRecord
                With reader
                    objRecord.Vendor = DataHelper.SmartValues(.Item("Vendor"), "string", False)
                    objRecord.Batch_Type_Desc = DataHelper.SmartValues(.Item("Batch_Type_Desc"), "string", False)
                    ' objRecord.Header_ID = DataHelper.SmartValues(.Item("Header_ID"), "string", False)
                    objRecord.ID = DataHelper.SmartValues(.Item("ID"), "integer", False)
                    objRecord.Dept = DataHelper.SmartValues(.Item("Dept"), "string", False)
                    objRecord.DateCreated = DataHelper.SmartValues(.Item("DateCreated"), "string", False)
                    objRecord.DateModified = DataHelper.SmartValues(.Item("DateModified"), "string", False)
                    objRecord.Valid = DataHelper.SmartValues(.Item("Valid"), "string", False)
                    objRecord.Workflow_Stage = DataHelper.SmartValues(.Item("Workflow_Stage"), "string", False)
                    objRecord.Approval_Name = DataHelper.SmartValues(.Item("Approval_Name"), "string", False)
                    objRecord.Workflow_Stage_ID = DataHelper.SmartValues(.Item("Workflow_Stage_ID"), "string", False)
                    objRecord.Stage_Type_ID = DataHelper.SmartValues(.Item("Stage_Type_ID"), "string", False)
                    objRecord.Stage_Sequence = DataHelper.SmartValues(.Item("Stage_Sequence"), "string", False)
                    objRecord.Dept_ID = DataHelper.SmartValues(.Item("Dept_ID"), "string", False)
                    objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", False)
                    objRecord.Item_Count = DataHelper.SmartValues(.Item("Item_Count"), "integer", False)
                    objRecord.Stock_Category = DataHelper.SmartValues(.Item("Stock_Category"), "string", False)
                    objRecord.Item_Type_Attribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", False)
                    objRecord.CreatedBy = DataHelper.SmartValues(.Item("Created_By"), "long", True)
                    objRecord.WorkflowID = wfID
                End With
                batchRecords.Add(objRecord)
            Loop
            reader.Close()
            cmd.Connection.Close()

            ' now get the number of rows returned.  Need to do this after connection is closed (don't ask me why)
            Try
                totalRows = CType(totalRowsParm.Value, Integer)
            Catch
                totalRows = 0
            End Try
            ' Save the total number of records that would be returned in a non paged recordset
            HttpContext.Current.Items(cIMBATCHROWCOUNT) = totalRows

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw
        Catch ex As Exception
            Logger.LogError(ex)
            Throw
        Finally
            If Not cmd Is Nothing Then
                cmd.Dispose()
                cmd = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Dispose()
                reader = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
        End Try

        Return batchRecords
    End Function

    Public Shared Function SearchSKURecsCount(ByVal deptNo As Integer, ByVal vendorNum As Integer, ByVal classNo As Integer, ByVal subClassNo As Integer, _
            ByVal VPN As String, ByVal UPC As String, ByVal SKU As String, ByVal stockCat As String, ByVal ItemTypeAttr As String, ByVal itemDesc As String, _
            ByVal itemStatus As String, ByVal packSearch As String, ByVal packSKU As String, ByVal userID As Integer, ByVal vendorID As Integer, _
            ByVal sortCol As String, ByVal sortDir As String, ByVal maxRows As Integer, ByVal rowIndex As Integer, ByVal quoteRefNum As String) As Integer
        Return SearchSKURecsCount()
    End Function

    Public Shared Function SearchSKURecsCount() As Integer
        Dim count As Integer
        Try
            count = HttpContext.Current.Items(cITEMSEARCHCOUNT)
        Catch
            count = 0
        End Try
        Return count
    End Function

    Public Shared Function SearchSKURecs(ByVal deptNo As Integer, ByVal vendorNum As Integer, ByVal classNo As Integer, ByVal subClassNo As Integer, _
             ByVal VPN As String, ByVal UPC As String, ByVal SKU As String, ByVal stockCat As String, ByVal ItemTypeAttr As String, ByVal itemDesc As String, _
             ByVal itemStatus As String, ByVal userID As Integer, ByVal vendorID As Integer, _
             ByVal sortCol As String, ByVal sortDir As String, ByVal maxRows As Integer, ByVal rowIndex As Integer, ByVal quoteRefNum As String) As List(Of ItemSearchRecord)

        Return SearchSKURecs(deptNo, vendorNum, classNo, subClassNo, VPN, UPC, SKU, stockCat, ItemTypeAttr, itemDesc, itemStatus, "", "", _
                             userID, vendorID, sortCol, sortDir, maxRows, rowIndex, quoteRefNum)

    End Function


    Public Shared Function SearchSKURecs(ByVal deptNo As Integer, ByVal vendorNum As Integer, ByVal classNo As Integer, ByVal subClassNo As Integer, _
            ByVal VPN As String, ByVal UPC As String, ByVal SKU As String, ByVal stockCat As String, ByVal ItemTypeAttr As String, ByVal itemDesc As String, _
            ByVal itemStatus As String, ByVal packSearch As String, ByVal packSKU As String, ByVal userID As Integer, ByVal vendorID As Integer, _
            ByVal sortCol As String, ByVal sortDir As String, ByVal maxRows As Integer, ByVal rowIndex As Integer, ByVal quoteRefNum As String) As List(Of ItemSearchRecord)

        Dim SearchRecs As List(Of ItemSearchRecord) = New List(Of ItemSearchRecord)
        Dim sql As String = String.Empty
        '        Dim reader As DBReader = Nothing
        '       Dim cmd As DBCommand
        '      Dim conn As DBConnection = Nothing
        Dim objRecord As ItemSearchRecord
        Dim totalRows As Integer

        Dim myConnectionString As String = ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString
        'Dim myConnection As SqlConnection = New SqlConnection
        Dim myCommand As SqlCommand = New SqlCommand
        Dim myReader As SqlDataReader
        Try
            sql = "usp_SPD_ItemMaster_SearchRecords"
            'myConnection.ConnectionString = myConnectionString
            'myCommand.Connection = myConnection
            myCommand.CommandType = CommandType.StoredProcedure
            myCommand.CommandText = sql
            myCommand.CommandTimeout = 600  ' Wait up to 10 minutes for this command to time out

            Dim totalRowsParm As New SqlParameter("@totalRows", SqlDbType.Int)
            totalRowsParm.Direction = ParameterDirection.ReturnValue
            myCommand.Parameters.Add(totalRowsParm)

            myCommand.Parameters.Add("@UserID", SqlDbType.Int).Value = userID
            myCommand.Parameters.Add("@VendorID", SqlDbType.Int).Value = vendorID

            If deptNo > 0 Then myCommand.Parameters.Add("@DeptNum", SqlDbType.Int).Value = deptNo
            If vendorNum > 0 Then myCommand.Parameters.Add("@VendorNumber", SqlDbType.Int).Value = vendorNum
            If classNo > 0 Then myCommand.Parameters.Add("@ClassNo", SqlDbType.Int).Value = classNo
            If subClassNo > 0 Then myCommand.Parameters.Add("@SubClassNo", SqlDbType.Int).Value = subClassNo
            If VPN <> String.Empty Then myCommand.Parameters.Add("@VPN", SqlDbType.VarChar).Value = VPN
            If UPC <> String.Empty Then myCommand.Parameters.Add("@UPC", SqlDbType.VarChar).Value = UPC
            If SKU <> String.Empty Then myCommand.Parameters.Add("@SKU", SqlDbType.VarChar).Value = SKU
            If stockCat <> String.Empty Then myCommand.Parameters.Add("@StockCat", SqlDbType.VarChar).Value = stockCat
            If ItemTypeAttr <> String.Empty Then myCommand.Parameters.Add("@ItemTypeAttr", SqlDbType.VarChar).Value = ItemTypeAttr
            If itemDesc <> String.Empty Then myCommand.Parameters.Add("@ItemDesc", SqlDbType.VarChar).Value = itemDesc
            If itemStatus <> String.Empty Then myCommand.Parameters.Add("@ItemStatus", SqlDbType.VarChar).Value = itemStatus
            If sortCol <> String.Empty Then myCommand.Parameters.Add("@SortCol", SqlDbType.VarChar).Value = sortCol
            If sortDir <> String.Empty Then myCommand.Parameters.Add("@SortDir", SqlDbType.VarChar).Value = sortDir
            If maxRows > 0 Then myCommand.Parameters.Add("@MaxRows", SqlDbType.Int).Value = maxRows
            If rowIndex > 0 Then myCommand.Parameters.Add("@RowIndex", SqlDbType.Int).Value = rowIndex
            If packSearch <> String.Empty Then myCommand.Parameters.Add("@PackSearch", SqlDbType.VarChar).Value = packSearch
            If packSKU <> String.Empty Then myCommand.Parameters.Add("@PackSKU", SqlDbType.VarChar).Value = packSKU
            If quoteRefNum <> String.Empty Then myCommand.Parameters.Add("@QuoteRefNum", SqlDbType.VarChar).Value = quoteRefNum

            Using myConnection As New SqlConnection
                myConnection.ConnectionString = myConnectionString
                myCommand.Connection = myConnection
                myConnection.Open()
                myReader = myCommand.ExecuteReader

                Do While myReader.Read()
                    objRecord = New ItemSearchRecord
                    With myReader
                        objRecord.ClassNum = DataHelper.SmartValues(.Item("Class_Num"), "integer", False)
                        objRecord.DeptName = DataHelper.SmartValues(.Item("Dept_Name"), "string", False)
                        objRecord.DeptNo = DataHelper.SmartValues(.Item("Dept_No"), "integer", False)
                        objRecord.ItemDesc = DataHelper.SmartValues(.Item("Item_Desc"), "string", False)
                        objRecord.SKU = DataHelper.SmartValues(.Item("SKU"), "string", False)
                        objRecord.SKUID = DataHelper.SmartValues(.Item("SKU_ID"), "integer", False)
                        objRecord.SubClassNum = DataHelper.SmartValues(.Item("Sub_Class_Num"), "integer", False)
                        objRecord.UPC = DataHelper.SmartValues(.Item("UPC"), "string", False)
                        objRecord.UPCPI = DataHelper.SmartValues(.Item("UPCPI"), "string", False)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("Vendor_Name"), "string", False)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "integer", False)
                        objRecord.VendorStyleNum = DataHelper.SmartValues(.Item("Vendor_Style_Num"), "string", False)
                        objRecord.VPI = DataHelper.SmartValues(.Item("VPI"), "string", False)
                        objRecord.BatchID = DataHelper.SmartValues(.Item("Batch_ID"), "long", False)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("Stock_Category"), "string", False)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("Item_Type_Attribute"), "string", False)
                        objRecord.ItemStatus = DataHelper.SmartValues(.Item("Item_Status"), "string", False)
                        objRecord.IsPackParent = DataHelper.SmartValues(.Item("Is_Pack_Parent"), "boolean", False)
                        objRecord.ItemType = DataHelper.SmartValues(.Item("Item_Type"), "string", False)
                        objRecord.PackSKU = DataHelper.SmartValues(.Item("Pack_SKU"), "string", False)
                        objRecord.IndEditable = DataHelper.SmartValues(.Item("Independent_Editable"), "boolean", False)
                        objRecord.VendorType = DataHelper.SmartValues(.Item("Vendor_Type"), "integer", False)
                        objRecord.HybridType = DataHelper.SmartValues(.Item("Hybrid_Type"), "string", False)
                        objRecord.HybridSourceDC = DataHelper.SmartValues(.Item("Hybrid_Source_DC"), "string", False)
                        objRecord.ConversionDate = DataHelper.SmartValuesDBNull(.Item("Hybrid_Conversion_Date"), True)
                        objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", False)
                    End With
                    SearchRecs.Add(objRecord)
                Loop
                myReader.Close()
            End Using

            Try
                totalRows = CType(totalRowsParm.Value, Integer)
            Catch
                totalRows = 0
            End Try
            ' Save the total number of records that would be returned in a non paged recordset
            HttpContext.Current.Items(cITEMSEARCHCOUNT) = totalRows

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw New Exception(sqlex.ToString)
        Catch ex As Exception
            Logger.LogError(ex)
            Throw New Exception(ex.ToString)
        Finally
            myCommand = Nothing
            If Not myReader Is Nothing Then
                If Not myReader.IsClosed Then
                    myReader.Close()
                End If
                myReader.Dispose()
                myReader = Nothing
            End If
        End Try

        Return SearchRecs
        
    End Function


    Public Shared Function GetFutureCosts(ByVal itemID As Integer, ByRef headerRec As ItemMaintItemCostRecord) As List(Of ItemMaintItemCostRecord)
        Dim FutureCostRecs As List(Of ItemMaintItemCostRecord) = New List(Of ItemMaintItemCostRecord)
        Dim sql As String = String.Empty
        Dim reader As DBReader = Nothing
        Dim cmd As DBCommand
        Dim conn As DBConnection = Nothing
        Dim objRecord As ItemMaintItemCostRecord
        'Dim totalRows As Integer

        Try
            conn = NovaLibra.Coral.Data.Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn)
            cmd = reader.Command
            sql = "usp_SPD_ItemMaint_GetFutureCostRecords"

            'Create a SqlParameter object to hold the ReturnValue parameter 
            Dim totalRowsParm As New SqlParameter("@totalRows", SqlDbType.Int)
            totalRowsParm.Direction = ParameterDirection.ReturnValue
            cmd.Parameters.Add(totalRowsParm)

            cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = itemID

            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()
            If reader.Read Then
                With reader
                    headerRec.ID = DataHelper.SmartValues(.Item("ID"), "integer", True)
                    headerRec.BatchID = DataHelper.SmartValues(.Item("BatchID"), "long", True)
                    headerRec.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                    headerRec.IsValid = DataHelper.SmartValues(.Item("IsValid"), "integer", True)
                    headerRec.SKU = DataHelper.SmartValues(.Item("SKU"), "string", True)
                    headerRec.VendorNumber = DataHelper.SmartValues(.Item("VendorNumber"), "long", True)
                    headerRec.VendorName = DataHelper.SmartValues(.Item("VendorName"), "string", True)
                    headerRec.BatchTypeID = DataHelper.SmartValues(.Item("BatchTypeID"), "integer", True)
                    headerRec.VendorType = DataHelper.SmartValues(.Item("VendorType"), "integer", True)
                    headerRec.PrimaryUPC = DataHelper.SmartValues(.Item("PrimaryUPC"), "string", True)
                    headerRec.VendorStyleNum = DataHelper.SmartValues(.Item("VendorStyleNum"), "string", True)
                    headerRec.ItemDesc = DataHelper.SmartValues(.Item("ItemDesc"), "string", True)
                    headerRec.CountryOfOrigin = DataHelper.SmartValues(.Item("CountryOfOrigin"), "string", True)
                    headerRec.CountryOfOriginName = DataHelper.SmartValues(.Item("CountryOfOriginName"), "string", True)
                End With
            End If

            reader.NextResult()
            Do While reader.Read()
                objRecord = New ItemMaintItemCostRecord
                With reader
                    objRecord.ID = DataHelper.SmartValues(.Item("ID"), "integer", False)
                    objRecord.BatchID = DataHelper.SmartValues(.Item("BatchID"), "long", False)
                    objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                    objRecord.IsValid = DataHelper.SmartValues(.Item("IsValid"), "integer", True)
                    objRecord.SKU = DataHelper.SmartValues(.Item("SKU"), "string", True)
                    objRecord.VendorNumber = DataHelper.SmartValues(.Item("VendorNumber"), "long", False)
                    objRecord.VendorName = DataHelper.SmartValues(.Item("VendorName"), "string", True)
                    objRecord.BatchTypeID = DataHelper.SmartValues(.Item("BatchTypeID"), "integer", False)
                    objRecord.VendorType = DataHelper.SmartValues(.Item("VendorType"), "integer", False)
                    objRecord.PrimaryUPC = DataHelper.SmartValues(.Item("PrimaryUPC"), "string", True)
                    objRecord.VendorStyleNum = DataHelper.SmartValues(.Item("VendorStyleNum"), "string", True)
                    objRecord.ItemDesc = DataHelper.SmartValues(.Item("ItemDesc"), "string", True)
                    objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("CountryOfOrigin"), "string", True)
                    objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("CountryOfOriginName"), "string", True)
                    objRecord.EffectiveDate = DataHelper.SmartValues(.Item("EffectiveDate"), "date", False)
                    objRecord.FutureCost = DataHelper.SmartValues(.Item("FutureCost"), "decimal", False)
                    objRecord.FutureDisplayerCost = DataHelper.SmartValues(.Item("FutureDisplayerCost"), "decimal", False)
                End With
                FutureCostRecs.Add(objRecord)
            Loop
            conn.Close()

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw
        Catch ex As Exception
            Logger.LogError(ex)
            Throw
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

        Return FutureCostRecs

    End Function

    Public Shared Function ValidateUser(ByVal batchID As Integer, ByVal userID As Integer, ByVal vendorID As Integer) As NovaLibra.Coral.SystemFrameworks.Michaels.BatchAccess

        Return NovaLibra.Coral.Data.Michaels.BatchData.ValidateUserForBatch(batchID, userID, vendorID)

    End Function

    Public Shared Function GetDisApprovalBatchStages(ByVal BatchID As Integer, ByVal dir As Char) As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage)

        Dim batchRecords As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage) = New List(Of NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage)
        Dim sql As String = String.Empty
        Dim reader As DBReader = Nothing
        Dim cmd As DBCommand
        Dim conn As DBConnection = Nothing
        Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage

        Try
            conn = NovaLibra.Coral.Data.Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn)
            cmd = reader.Command
            sql = "usp_SPD_Batch_GetHistoryForID"
            cmd.Parameters.Add("@BatchID", SqlDbType.VarChar).Value = BatchID
            cmd.Parameters.Add("@dir", SqlDbType.VarChar).Value = dir

            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()

            Do While reader.Read()
                objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage
                With reader
                    objRecord.ID = DataHelper.SmartValues(.Item("ID"), "integer", False)
                    objRecord.StageName = DataHelper.SmartValues(.Item("Stage_Name"), "string", False)
                End With
                batchRecords.Add(objRecord)
            Loop

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw
        Catch ex As Exception
            Logger.LogError(ex)
            Throw
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
            If batchRecords.Count = 0 Then
                'objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage
                'objRecord.ID = "-1" ' flag so it won't match
                'objRecord.StageName = "No Batch Stage History Found!"
                'batchRecords.Add(objRecord)
            End If
        End Try
        Return batchRecords

    End Function

End Class
