Imports System
Imports System.Configuration
Imports System.Data
Imports System.IO
Imports Microsoft.VisualBasic
Imports System.Data.SqlClient

'Imports C1.C1Excel
Imports SpreadsheetGear
Imports SpreadsheetGear.Data
Imports SpreadsheetGear.Shapes

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports Data = NovaLibra.Coral.Data.Michaels
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports ItemHelper

Partial Class upload
    Inherits System.Web.UI.Page

    Private _refreshParent As Boolean = False
    Private _sendToDefault As Boolean = False
    Private _useSessionVendor As Boolean = False

    Public Property RefreshParent() As Boolean
        Get
            Return _refreshParent
        End Get
        Set(ByVal value As Boolean)
            _refreshParent = value
        End Set
    End Property

    Public Property SendToDefault() As Boolean
        Get
            Return _sendToDefault
        End Get
        Set(ByVal value As Boolean)
            _sendToDefault = value
        End Set
    End Property

    Public ReadOnly Property UploadQueryString() As String
        Get
            Return "?r=" & r.Value & "&sd=" & sd.Value
        End Get
    End Property

    Protected Property UseSessionVendor() As Boolean
        Get
            Return _useSessionVendor
        End Get
        Set(ByVal value As Boolean)
            _useSessionVendor = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("closeform.aspx")
        End If

        If Not IsPostBack Then
            ' setup the page
            If Request("r") = "1" Then
                r.Value = "1"
            End If
            If Request("sd") = "1" Then
                sd.Value = "1"
            End If
            'Me.btnSubmit.Attributes.Add("onclick", "return onUploadSubmitted();")
        End If

        ' set refresh parent property
        If r.Value = "1" Then
            RefreshParent = True
        End If

        ' set send to default property
        If sd.Value = "1" Then
            SendToDefault = True
        End If

        ' check session vendor
        If AppHelper.GetVendorID() > 0 Then
            UseSessionVendor = True
        End If
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click

        Dim wb As SpreadsheetGear.IWorkbook
        Dim bFoundOne As Boolean = False

        ' save the imported file
        Dim file As HttpPostedFile = Request.Files.Item("importFile")
        If Not file Is Nothing Then

            Try
                ' validate file type
                If ExcelFileHelper.IsValidFileType(file.FileName) Then

                    ' get the stream & load the component
                    wb = SpreadsheetGear.Factory.GetWorkbookSet().Workbooks.OpenFromStream(file.InputStream, AppHelper.GetCurrentDomesticSpreadsheetPassword())

                    ' validate
                    If ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.Domestic) Then
                        UploadDomesticFile(wb)
                        bFoundOne = True
                    End If
                    wb.Close()

                    If Not bFoundOne Then
                        wb = SpreadsheetGear.Factory.GetWorkbookSet().Workbooks.OpenFromStream(file.InputStream, AppHelper.GetCurrentImportSpreadsheetPassword())
                        If ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.Import) Then
                            UploadImportFile(wb)
                            bFoundOne = True
                        End If
                        wb.Close()
                    End If

                    If Not bFoundOne Then
                        ' ERROR: invalid component
                        fileImportPanel.Visible = False
                        fileImportError.Visible = True
                        importError.Text = "Could not process file"
                    End If

                Else
                    ' ERROR: invalid file type
                    fileImportPanel.Visible = False
                    importError.Text = "Please upload a valid Excel spreadsheet (*.xls)"
                    fileImportCustomError.Visible = True
                End If

            Catch uploadEx As SPEDYUploadException
                fileImportPanel.Visible = False
                importError.Text = uploadEx.Message
                fileImportCustomError.Visible = True

            Catch ex As Exception
                'ERROR: invalid file type
                fileImportPanel.Visible = False
                importError.Text = WebConstants.IMPORT_ERROR_UNKNOWN + ".   Error Returned: " + ex.Message
                fileImportCustomError.Visible = True

            End Try

        Else
            ' ERROR: file is nothing.
            fileImportPanel.Visible = True
            fileImportSuccess.Visible = False
            fileImportError.Visible = False
        End If

    End Sub

    Public Function UploadDomesticFile(ByVal wb As SpreadsheetGear.IWorkbook) As Boolean

        ' UPDATED 9/18/2008 ndf - Force UCASE on decription on Style # on import of both domestic and import items 

        Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord
        Dim item As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord
        Dim itemRows As Integer = 0, currRow As Integer
        Dim currRow2 As Integer = WebConstants.NEW_ITEM_TAB_START_ROW
        Dim itemHeaderID As Long = 0, itemID As Long
        Dim userID As Integer = DataHelper.SmartValues(Session("UserID"), "integer")
        Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping
        Dim itemMap2 As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping
        Dim itemMapI As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping
        Dim ws, ws2 As SpreadsheetGear.IWorksheet

        Dim lvgs As ListValueGroups = FormHelper.LoadListValues("PACKITEMIND")

        ws = wb.Worksheets.Item(WebConstants.DOMESTIC_ITEM_IMPORT_WORKSHEET)
        'LP SPEDY  change order 12
        ws2 = ExcelFileHelper.GetExcelWorksheet(wb, WebConstants.LIKE_ITEM_TAB_WORKSHEET)

        ' read/save the header
        itemHeader = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord()
        itemHeader.SetupAudit(NovaLibra.Coral.SystemFrameworks.Michaels.MetadataTable.Item_Headers, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Insert, userID)

        Dim mapVer As String = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, "D", 1), "string", False)

        Dim objMichaelsMap As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping()


        itemMap = objMichaelsMap.GetMapping("DOMITEMHEADER", mapVer)
        itemMap2 = objMichaelsMap.GetMapping("LIKEITEMAPPROVAL", "CURRENT")
        itemMapI = objMichaelsMap.GetMapping("DOMITEM", mapVer)
        If itemMap Is Nothing OrElse itemMap.Count <= 0 OrElse itemMapI Is Nothing OrElse itemMapI.Count <= 0 Then
            objMichaelsMap = Nothing
            Throw New SPEDYUploadException(WebConstants.IMPORT_ERROR_INVALID_VERSION)
        End If

        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim objMichaelsIFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()

        Dim vendor As Models.VendorRecord = Nothing, vnum As Integer
        Dim objMichaelsVendor As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
        Dim validBatch As Boolean = True
        Dim sku As String
        Dim vendorNumber As Long
        Dim packIndicator As String
        Dim batchPackIndicator As String = ""
        Dim itemMaintItem As Models.ItemMaintItemDetailFormRecord
        Dim invalidCount As Integer = 0
        Dim importDone As Boolean = False

        ' DETERMINE IF THERE IS A SKU/VENDOR COMBINATION THAT DOES NOT EXIST IN RMS (FAILING UPLOAD IF NECESSARY)

        If UseSessionVendor Then
            vendorNumber = AppHelper.GetVendorID()
        Else
            vendorNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "US_Vendor_Num"), "integer", True)
            If vendorNumber <= 0 Then
                vendorNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Canadian_Vendor_Num"), "integer", True)
            End If
        End If

        Do While Not importDone

            If Not ExcelFileHelper.IsValidItemRow(ws, itemRows + 1) Then
                invalidCount += 1
                If invalidCount >= 2 Then
                    importDone = True
                End If
            Else
                invalidCount = 0

                currRow = WebConstants.DOMESTIC_ITEM_START_ROW + itemRows

                ' get the sku
                sku = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMapI, "Michaels_SKU", "", currRow), "string", True)
                packIndicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMapI, "Pack_Item_Indicator", "", currRow), "string", True)
                If packIndicator = "SB" Then
                    batchPackIndicator = "SB"
                End If

                ' if sku is filled in, get the vendor # and check for valid Item Master record
                If sku <> String.Empty Then
                    If batchPackIndicator = "SB" And packIndicator = "C" Then
                        'for SB components, we're fine with any vendor, if we pass in 0, the load routine will get the primary vendor
                        itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(0, sku, 0)
                        vendorNumber = itemMaintItem.VendorNumber
                    Else
                        If vendorNumber > 0 Then
                            itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(vendorNumber, sku, vendorNumber)
                        Else
                            itemMaintItem = Nothing
                        End If
                    End If

                    ' check for valid item master record
                    If vendorNumber <= 0 OrElse itemMaintItem Is Nothing OrElse (itemMaintItem.SKU = String.Empty Or itemMaintItem.VendorNumber <= 0) Then
                        Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERR0R_INVALID_SKU_VENDOR, sku))
                        validBatch = False
                    End If

                    'NAK 4/30/2013:  Per Michaels, it is ok if SKU is already in an Item Maintenance Batch.
                    ' check if the sku is already in a batch
                    'Dim skuList As System.Collections.Generic.List(Of Models.ItemSearchRecord) = _
                    '    BatchesData.SearchSKURecs(0, vendorNumber, 0, 0, String.Empty, String.Empty, sku, _
                    '        String.Empty, String.Empty, String.Empty, String.Empty, userID, 0, String.Empty, String.Empty, 0, 0, String.Empty)
                    'If skuList.Count = 1 Then
                    '    Dim thisISR As Models.ItemSearchRecord = skuList(0)
                    '    If thisISR.BatchID > 0 Then
                    '        Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_SKU_BATCH, sku, thisISR.BatchID))
                    '        validBatch = False
                    '    End If
                    'End If

                    ' check if the sku is a pack parent
                    If itemMaintItem IsNot Nothing Then
                        If itemMaintItem.IsPackParent() Then
                            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_SKU_PACK_PARENT, sku))
                            validBatch = False
                        End If
                    End If

                End If

            End If

            ' next
            itemRows += 1

        Loop

        ' RESET stuff

        itemRows = 0
        currRow = 0
        invalidCount = 0
        importDone = False

        ' PROCESS THE UPLOAD

        itemHeader.LogID = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ThenLog_ID"), "string", True)
        itemHeader.SubmittedBy = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Submitted_By"), "string", True)
        'itemHeader.DateSubmitted = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws, itemMap, "Date_Submitted"), "date", True)
        itemHeader.DateSubmitted = DataHelper.SmartValues(Now().ToShortDateString(), "date", True)
        itemHeader.DepartmentNum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Department_Num"), "integer", True)

        ' vendor number and vendor name
        If UseSessionVendor Then

            'If the US Vendor number is specified in the worksheet, set the US Vendor using the Session information
            vnum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "US_Vendor_Num"), "integer", True)
            If vnum > 0 Then
                itemHeader.USVendorNum = AppHelper.GetVendorID()
                'itemHeader.USVendorName = DataHelper.SmartValues(Session("Organization"), "string", True)
                vendor = objMichaelsVendor.GetVendorRecord(itemHeader.USVendorNum)
                If Not vendor Is Nothing AndAlso ValidationHelper.IsValidDomesticVendor(vendor) Then
                    itemHeader.USVendorName = vendor.VendorName
                Else
                    itemHeader.USVendorName = String.Empty
                End If
            End If

            'If the Canadian Vendor Number is specified in the worksheet, set the Canandian Vendor using the Session Information
            vnum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Canadian_Vendor_Num"), "integer", True)
            If vnum > 0 Then
                vnum = AppHelper.GetVendorID()
            End If
        Else
            'Set the US Vendor information using the Vendor Number in the worksheet
            vnum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "US_Vendor_Num"), "integer", True)
            If vnum > 0 Then
                itemHeader.USVendorNum = vnum
                vendor = objMichaelsVendor.GetVendorRecord(vnum)
            Else
                vendor = New Models.VendorRecord()
            End If
            If Not vendor Is Nothing AndAlso ValidationHelper.IsValidDomesticVendor(vendor) Then
                itemHeader.USVendorName = vendor.VendorName
            End If
            vendor = Nothing

            'Set the Canadian Vendor Num using the Vendor Number in the worksheet
            vnum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Canadian_Vendor_Num"), "integer", True)
        End If

        If vnum > 0 Then
            itemHeader.CanadianVendorNum = vnum
            vendor = objMichaelsVendor.GetVendorRecord(vnum)
        Else
            vendor = New Models.VendorRecord()
        End If
        If Not vendor Is Nothing AndAlso ValidationHelper.IsValidDomesticVendor(vendor) Then
            itemHeader.CanadianVendorName = vendor.VendorName
        End If
        vendor = Nothing

        itemHeader.SupplyChainAnalyst = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Supply_Chain_Analyst"), "string", True)
        itemHeader.MgrSupplyChain = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Mgr_Supply_Chain"), "string", True)
        itemHeader.DirSCVR = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Dir_SCVR"), "string", True)

        itemHeader.RebuyYN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Rebuy_YN"), "string", True)
        itemHeader.ReplenishYN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Replenish_YN"), "string", True)
        itemHeader.StoreOrderYN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Store_Order_YN"), "string", True)

        itemHeader.DateInRetek = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws, itemMap, "Date_In_Retek"), "date", True)
        itemHeader.EnterRetek = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Enter_Retek"), "string", True)
        itemHeader.BuyerApproval = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Buyer_Approval"), "string", True)

        itemHeader.StockCategory = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Stock_Category"), "string", True)
        itemHeader.CanadaStockCategory = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Canada_Stock_Category"), "string", True)
        itemHeader.ItemType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Item_Type"), "string", True)
        itemHeader.ItemTypeAttribute = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Item_Type_Attribute"), "string", True)
        itemHeader.AllowStoreOrder = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Allow_Store_Order"), "string", True)
        itemHeader.InventoryControl = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Inventory_Control"), "string", True)
        itemHeader.FreightTerms = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Freight_Terms"), "string", True)
        itemHeader.AutoReplenish = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Auto_Replenish"), "string", True)
        itemHeader.SKUGroup = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SKU_Group"), "string", True)
        itemHeader.StoreSupplierZoneGroup = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Store_Supplier_Zone_Group"), "string", True)
        itemHeader.WHSSupplierZoneGroup = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "WHS_Supplier_Zone_Group"), "string", True)
        If mapVer.Trim() = AppHelper.GetCurrentDomesticSpreadsheetVersion() Or AppHelper.GetCurrentDomesticSpreadsheetVersion() <> "13.09 Version" Then
            itemHeader.AddUnitCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Add_Unit_Cost"), "decimal", True)
        End If
        itemHeader.Comments = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Comments"), "stringrs", True)
        itemHeader.WorksheetDesc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Worksheet_Desc"), "string", True)

        itemHeader.RMSSellable = WebConstants.IMPORT_RMS_DEFAULT_VALUE
        itemHeader.RMSOrderable = WebConstants.IMPORT_RMS_DEFAULT_VALUE
        itemHeader.RMSInventory = WebConstants.IMPORT_RMS_DEFAULT_VALUE
        'LP SPDE change order 12
        If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Store_Total"))) Then
            itemHeader.StoreTotal = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Store_Total"), "integer", True, Decimal.MinValue)
        End If
        itemHeader.POGStartDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws2, itemMap2, "POG_Start_Date"), "date", True)
        itemHeader.POGCompDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws2, itemMap2, "POG_Comp_Date"), "date", True)
        Dim icalc As Integer = 0
        If IsNumeric(Trim(ExcelFileHelper.GetCell(ws2, "AK", 3))) Then icalc = CInt(ExcelFileHelper.GetCell(ws2, "AK", 3))
        itemHeader.CalculateOptions = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Calculate_Options"), "integer", True, 0)
        If icalc <> 0 Then itemHeader.CalculateOptions = icalc
        If itemHeader.CalculateOptions > 2 OrElse itemHeader.CalculateOptions < 0 Then itemHeader.CalculateOptions = 0 'in case of values other then 0,1,2
        'LP save record
        itemHeaderID = objMichaels.SaveItemHeaderRecord(itemHeader, userID, "Uploaded", "", Session("UserName"))
        If itemHeaderID > 0 Then
            ' read/save the line items
            itemMap = Nothing

            itemMap = itemMapI

            Dim upc As String = String.Empty

            Do While Not importDone

                If Not ExcelFileHelper.IsValidItemRow(ws, itemRows + 1) Then
                    invalidCount += 1
                    If invalidCount >= 2 Then
                        importDone = True
                    End If
                Else
                    invalidCount = 0

                    currRow = WebConstants.DOMESTIC_ITEM_START_ROW + itemRows
                    currRow2 = WebConstants.NEW_ITEM_TAB_START_ROW + itemRows
                    item = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord()
                    item.SetupAudit(NovaLibra.Coral.SystemFrameworks.Michaels.MetadataTable.Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Insert, userID)

                    item.ItemHeaderID = itemHeaderID

                    ' Defaults
                    item.AddChange = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Add_Change", "", currRow), "string", True)
                    item.PackItemIndicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Pack_Item_Indicator", "", currRow), "string", True)
                    If Not IsValidListValue(lvgs, "PACKITEMIND", item.PackItemIndicator, True) Then
                        item.PackItemIndicator = String.Empty
                    ElseIf mapVer.Trim() <> AppHelper.GetCurrentDomesticSpreadsheetVersion() AndAlso (item.PackItemIndicator = "D" Or item.PackItemIndicator = "DP" Or item.PackItemIndicator = "SB") Then
                        item.PackItemIndicator = String.Empty
                    End If

                    item.MichaelsSKU = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Michaels_SKU", "", currRow), "string", True)
                    upc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Vendor_UPC", "", currRow), "string", True)
                    If upc.Trim() <> String.Empty Then
                        upc = FormatUPCValue(upc.Trim())
                    End If
                    item.VendorUPC = upc
                    item.ClassNum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Class_Num", "", currRow), "integer", True)
                    item.SubClassNum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Sub_Class_Num", "", currRow), "integer", True)
                    item.VendorStyleNum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Vendor_Style_Num", "", currRow), "stringrsu", True)
                    item.ItemDesc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Item_Desc", "", currRow), "stringrsu", True)
                    If item.ItemDesc.Length > 30 Then
                        item.ItemDesc = item.ItemDesc.Substring(0, 30)
                    End If
                    'item.HybridType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hybrid_Type", "", currRow), "string", True)
                    ''item.HybridSourceDC = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hybrid_Source_DC", "", currRow), "string", True)
                    'item.HybridLeadTime = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hybrid_Lead_Time", "", currRow), "integer", True)
                    'item.HybridConversionDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws, itemMap, "Hybrid_Conversion_Date", "", currRow), "date", True)
                    If objMichaels.DisableStockingStratBasedOnStockCat(itemHeader.StockCategory, itemHeader.CanadaStockCategory) = False Then
                        'item.StockingStrategyCode = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Stocking_Strategy_Code", "", currRow), "string", True)


                        Dim tempSSC As String = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Stocking_Strategy_Code", "", currRow), "string", True)
                        If tempSSC.Contains("-") Then
                            tempSSC = tempSSC.Substring(0, tempSSC.IndexOf("-")).TrimEnd
                            item.StockingStrategyCode = tempSSC
                        Else
                            item.StockingStrategyCode = tempSSC
                        End If

                    End If

                    'PMO200141 GTIN14 Enhancements changes
                    'item.VendorInnerGTIN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Vendor_Inner_GTIN", "", currRow), "string", True)
                    'item.VendorCaseGTIN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Vendor_Case_GTIN", "", currRow), "string", True)

                    'Removing old code that is silly anyways...
                    'If mapVer.Trim() = AppHelper.GetCurrentDomesticSpreadsheetVersion() Or AppHelper.GetCurrentDomesticSpreadsheetVersion() <> "13.09 Version" Then
                    item.QtyInPack = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Qty_In_Pack", "", currRow), "integer", True)
                    'End If

                    item.EachesMasterCase = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Eaches_Master_Case", "", currRow), "integer", True)
                    item.EachesInnerPack = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Eaches_Inner_Pack", "", currRow), "integer", True)
                    item.PrePriced = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Pre_Priced", "", currRow), "string", True)
                    item.PrePricedUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Pre_Priced_UDA", "", currRow), "string", True)
                    item.USCost = DataHelper.SmartValues(Replace(ExcelFileHelper.GetCellByMap(ws, itemMap, "US_Cost", "", currRow), "$", ""), "decimal", True)
                    item.CanadaCost = DataHelper.SmartValues(Replace(ExcelFileHelper.GetCellByMap(ws, itemMap, "Canada_Cost", "", currRow), "$", ""), "decimal", True)

                    ' ***************************************************************************************************************************
                    ' we have to adjust the code as the import component (spreadsheet gear) does not perform the excel function correctly
                    ' ***************************************************************************************************************************
                    'If mapVer.Trim() = AppHelper.GetCurrentDomesticSpreadsheetVersion() Or AppHelper.GetCurrentDomesticSpreadsheetVersion() <> "13.09 Version" Then
                    '    item.TotalUSCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Total_US_Cost", "", currRow), "decimal", True)
                    '    item.TotalCanadaCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Total_Canada_Cost", "", currRow), "decimal", True)
                    'End If

                    ' The Web.config contains the current version of the spreadsheet.  The hard coded version in the following line indicates the oldest version that supports the
                    '    code for calculating the total costs
                    If mapVer.Trim() = AppHelper.GetCurrentDomesticSpreadsheetVersion() Or AppHelper.GetCurrentDomesticSpreadsheetVersion() <> "13.09 Version" Then
                        ' CURRENT VERSION OF SPREADSHEET - Calculate the total costs
                        If item.USCost <> Decimal.MinValue Then
                            If (itemHeader.ItemType = "C" And item.PackItemIndicator <> "C" And itemHeader.AddUnitCost >= 0) Then
                                item.TotalUSCost = (item.USCost + itemHeader.AddUnitCost)
                            Else
                                item.TotalUSCost = item.USCost
                            End If
                        Else
                            item.TotalUSCost = item.USCost
                        End If
                        If item.CanadaCost <> Decimal.MinValue Then
                            If (itemHeader.ItemType = "C" And item.PackItemIndicator <> "C" And itemHeader.AddUnitCost >= 0) Then
                                item.TotalCanadaCost = (item.CanadaCost + itemHeader.AddUnitCost)
                            Else
                                item.TotalCanadaCost = item.CanadaCost
                            End If
                        Else
                            item.TotalCanadaCost = item.CanadaCost
                        End If
                    Else
                        ' OLD VERSION OF SPREADSHEET - Set the total costs equal to the costs
                        item.TotalUSCost = item.USCost
                        item.TotalCanadaCost = item.CanadaCost
                    End If

                    item.BaseRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Base_Retail", "", currRow), "decimal", True)
                    item.CentralRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Central_Retail", "", currRow), "decimal", True)
                    item.TestRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Test_Retail", "", currRow), "decimal", True)
                    item.AlaskaRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Alaska_Retail", "", currRow), "decimal", True)

                    'Canada logic below changed by KH 2019-07-15
                    item.CanadaRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Canada_Retail", "", currRow), "decimal", True)
                    'If item.BaseRetail <> Decimal.MinValue Then
                    '    item.CanadaRetail = NovaLibra.Coral.Data.Michaels.ItemDetail.GetGridPrice(5, item.BaseRetail)
                    'End If

                    item.ZeroNineRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Zero_Nine_Retail", "", currRow), "decimal", True)
                    item.CaliforniaRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "California_Retail", "", currRow), "decimal", True)
                    item.VillageCraftRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Village_Craft_Retail", "", currRow), "decimal", True)
                    'lp Change order 14- Sept 2009
                    item.Retail9 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail9", "", currRow), "decimal", True)
                    item.Retail10 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail10", "", currRow), "decimal", True)
                    item.Retail11 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail11", "", currRow), "decimal", True)
                    item.Retail12 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail12", "", currRow), "decimal", True)
                    item.Retail13 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail13", "", currRow), "decimal", True)
                    'item.RDQuebec = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDQuebec", "", currRow), "decimal", True)
                    'PER Michaels Requirements - Default Value to Canada value when RDQuebec is empty/null
                    'If item.RDQuebec = Decimal.MinValue Then
                    item.RDQuebec = item.CanadaRetail
                    'End If
                    item.RDPuertoRico = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDPuertoRico", "", currRow), "decimal", True)
                    'PER Michaels Requirements - Default value to Base1 Retail when RDPuertoRico is empty/null
                    If item.RDPuertoRico = Decimal.MinValue Then
                        item.RDPuertoRico = item.BaseRetail
                    End If

                    'now get get POGSetupPerStore, POGMaxQty from Like Item sheet*****************************
                    'item.POGSetupPerStore = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "POG_Setup_Per_Store", "", currRow), "decimal", True)
                    'item.POGMaxQty = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "POG_Max_Qty", "", currRow), "decimal", True)
                    '********************************************************************************************************************************************
                    'item.ProjectedUnitSales = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Projected_Unit_Sales", "", currRow), "decimal", True)


                    item.EachCaseHeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Each_Case_Height", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.EachCaseWidth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Each_Case_Width", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.EachCaseLength = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Each_Case_Length", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.EachCaseWeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Each_Case_Weight", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.EachCasePackCube = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Each_Case_Pack_Cube", "", currRow), "decimal", True, System.Decimal.MinValue, 4)

                    item.InnerCaseHeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Inner_Case_Height", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.InnerCaseWidth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Inner_Case_Width", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.InnerCaseLength = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Inner_Case_Length", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.InnerCaseWeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Inner_Case_Weight", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.InnerCasePackCube = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Inner_Case_Pack_Cube", "", currRow), "decimal", True, System.Decimal.MinValue, 4)

                    item.MasterCaseHeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Master_Case_Height", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.MasterCaseWidth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Master_Case_Width", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.MasterCaseLength = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Master_Case_Length", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.MasterCaseWeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Master_Case_Weight", "", currRow), "decimal", True, System.Decimal.MinValue, 4)
                    item.MasterCasePackCube = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Master_Case_Pack_Cube", "", currRow), "decimal", True, System.Decimal.MinValue, 4)

                    Dim countryName As String = String.Empty
                    Dim countryCode As String = String.Empty
                    countryName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Country_Of_Origin", "", currRow), "string", True)
                    Dim country As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(countryName)
                    If Not country Is Nothing AndAlso country.CountryName <> String.Empty AndAlso country.CountryCode <> String.Empty Then
                        countryName = country.CountryName
                        countryCode = country.CountryCode
                    End If
                    item.CountryOfOriginName = countryName
                    item.CountryOfOrigin = countryCode
                    country = Nothing

                    item.TaxUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Tax_UDA", "", currRow), "string", True)
                    item.TaxValueUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Tax_Value_UDA", "", currRow), "integer", True)
                    item.Hazardous = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous", "", currRow), "string", True)
                    item.HazardousFlammable = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Flammable", "", currRow), "string", True)
                    item.HazardousContainerType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Container_Type", "", currRow), "string", True)
                    item.HazardousContainerSize = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Container_Size", "", currRow), "decimal", True)
                    item.HazardousMSDSUOM = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_MSDS_UOM", "", currRow), "string", True)
                    item.HazardousManufacturerName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Manufacturer_Name", "", currRow), "string", True)
                    item.HazardousManufacturerCity = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Manufacturer_City", "", currRow), "string", True)
                    item.HazardousManufacturerState = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Manufacturer_State", "", currRow), "string", True)
                    item.HazardousManufacturerPhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Manufacturer_Phone", "", currRow), "string", True)
                    item.HazardousManufacturerCountry = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous_Manufacturer_Country", "", currRow), "string", True)

                    item.PhytoSanitaryCertificate = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PhytoSanitaryCertificate", "", currRow), "string", True)
                    If item.PhytoSanitaryCertificate.Trim.ToUpper = "YES" Then
                        item.PhytoSanitaryCertificate = "Y"
                    ElseIf item.PhytoSanitaryCertificate.Trim.ToUpper = "NO" Then
                        item.PhytoSanitaryCertificate = "N"
                    End If
                    item.PhytoTemporaryShipment = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PhytoTemporaryShipment", "", currRow), "string", True)
                    If item.PhytoTemporaryShipment.Trim.ToUpper = "YES" Then
                        item.PhytoTemporaryShipment = "Y"
                    ElseIf item.PhytoTemporaryShipment.Trim.ToUpper = "NO" Then
                        item.PhytoTemporaryShipment = "N"
                    End If

                    'move POG colums out of loop!
                    'itemHeader.POGStartDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws2, itemMap2, "POG_Start_Date"), "date", True)
                    'itemHeader.POGCompDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws2, itemMap2, "POG_Comp_Date"), "date", True)
                    'here where rows count is important
                    item.LikeItemSKU = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_SKU", , currRow2), "string", True, String.Empty)
                    item.LikeItemDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Description", , currRow2), "string", True, String.Empty)

                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Retail", , currRow2))) Then
                        item.LikeItemRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Retail", , currRow2), "decimal", True, Decimal.MinValue, 4)
                    End If
                    'per Michaels request, get sku description and price if description is missing
                    If item.LikeItemSKU.Trim() <> String.Empty And item.LikeItemDescription.Trim() = String.Empty Then
                        Dim strSku As String = DataHelper.SmartValues(item.LikeItemSKU.Trim(), "string", False)
                        Dim objRecord As Models.ItemMasterRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupItemMaster(strSku)
                        If Not objRecord Is Nothing AndAlso (objRecord.ItemDescription <> String.Empty Or objRecord.BaseRetail <> Decimal.MinValue) Then
                            item.LikeItemDescription = objRecord.ItemDescription
                            If objRecord.BaseRetail <> Decimal.MinValue Then
                                item.LikeItemRetail = DataHelper.SmartValues(objRecord.BaseRetail, "decimal", True, Decimal.MinValue, 2)
                            End If
                        End If
                        objRecord = Nothing
                    End If
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Regular_Units", , currRow2))) Then
                        item.LikeItemRegularUnit = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Regular_Units", , currRow2), "decimal", True, Decimal.MinValue)
                    End If
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Store_Count", , currRow2))) Then
                        item.LikeItemStoreCount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Store_Count", , currRow2), "decimal", True, Decimal.MinValue, 2)
                    End If
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Facings", , currRow2))) Then
                        item.Facings = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Facings", , currRow2), "decimal", True, Decimal.MinValue, 2)
                    End If
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "POG_Min_Qty", , currRow2))) Then
                        item.POGMinQty = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "POG_Min_Qty", , currRow2), "decimal", True, Decimal.MinValue, 0)
                    End If
                    item.LikeItemUnitStoreMonth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Unit_Store_Month", , currRow2), "decimal", True, Decimal.MinValue, 2)
                    item.AnnualRegularUnitForecast = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Annual_Regular_Unit_Forecast", , currRow2), "decimal", True, Decimal.MinValue, 2)
                    item.AnnualRegRetailSales = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Annual_Reg_Retail_Sales", , currRow2), "decimal", True, Decimal.MinValue, 2)

                    'lp change order 14- Sept 2009
                    item.POGMaxQty = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "POG_Max_Qty", "", currRow2), "decimal", True)
                    item.POGSetupPerStore = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Initial_Set_Qty_Per_Store", "", currRow2), "decimal", True)

                    'Get Multi-Lingual fields
                    Dim indicator As String = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLIEnglish", "", currRow), "CStr", False)
                    item.PLIEnglish = IIf(indicator.ToUpper = "YES", "Y", "N")
                    indicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLIFrench", "", currRow), "CStr", False)
                    item.PLIFrench = IIf(indicator.ToString.ToUpper = "YES", "Y", "N")
                    indicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLISpanish", "", currRow), "CStr", False)
                    item.PLISpanish = IIf(indicator.ToString.ToUpper = "YES", "Y", "N")
                    item.CustomsDescription = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CustomsDescription", "", currRow), "string", True), 255)
                    'NAK 4/17/2013:  Per client override value to "Y"
                    item.TIEnglish = "Y"

                    'NAK 4/10/2013:  Default TI English to "Y", unless it is specifically specified to be No.
                    'indicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TIEnglish", "", currRow), "CStr", False)
                    'If indicator.ToUpper = "N" Or indicator.ToUpper = "NO" Then
                    'item.TIEnglish = "N"
                    'Else
                    'item.TIEnglish = "Y"
                    'End If

                    'NAK: 8/8/20120: Defaulting TI Spanish to "N" per email from Srilatha that said Spanish TI is disabled for now.
                    item.TISpanish = "N" ' DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TISpanish", "", currRow), "boolean", True)

                    'NAK 4/17/2013:  Per Client, Override value to "Y"
                    item.TIFrench = "Y"
                    'NAK 4/10/2013:  Default TI French to "Y", unless it is specifically specified to be No.
                    'indicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TIFrench", "", currRow), "CStr", False)
                    'If indicator.ToUpper = "N" Or indicator.ToUpper = "NO" Then
                    'item.TIFrench = "N"
                    'Else
                    'item.TIFrench = "Y"
                    'End If

                    item.EnglishLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishLongDescription", "", currRow), "string", True)
                    item.EnglishShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishShortDescription", "", currRow), "string", True)

                    'Overwrite English Descriptions if PackItemIndicator is D or DP or SB
                    If Not String.IsNullOrEmpty(item.PackItemIndicator) Then
                        Dim englishDesc As String = ""
                        If item.PackItemIndicator.StartsWith("DP") Then
                            englishDesc = "Display Pack"
                        ElseIf item.PackItemIndicator.StartsWith("SB") Then
                            englishDesc = "Sellable Bundle"
                        ElseIf item.PackItemIndicator.StartsWith("D") Then
                            englishDesc = "Displayer"
                        End If
                        If englishDesc.Length > 0 Then
                            item.EnglishLongDescription = englishDesc
                            item.EnglishShortDescription = englishDesc
                        End If
                    End If

                    'NAK - Per client requirements, Non-English Description fields will not be imported.
                    'item.FrenchLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FrenchLongDescription", "", currRow), "string", True)
                    'item.FrenchShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FrenchShortDescription", "", currRow), "string", True)
                    'item.SpanishLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SpanishLongDescription", "", currRow), "string", True)
                    'item.SpanishShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SpanishShortDescription", "", currRow), "string", True)

                    'Get Private Brand Label (PBL) from the Spreadsheet, and compare it to the list of PBLs in the database.
                    Dim pbl As String = DataHelper.SmartValue(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrivateBrandLabel", "", currRow), "string", True)
                    Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
                    If pbllvgs IsNot Nothing Then
                        For Each lv As ListValue In pbllvgs.ListValues
                            If lv.DisplayText.ToUpper = pbl.ToUpper Then
                                item.PrivateBrandLabel = lv.Value
                            End If
                        Next
                    End If

                    'IF there is no Quote Reference Number AND the PBL field is blank, default it.
                    If String.IsNullOrEmpty(item.PrivateBrandLabel) Then
                        item.PrivateBrandLabel = WebConstants.LIST_VALUE_DEFAULT_PRIVATE_BRAND_LABEL
                    End If

                    'Get CRC Info
                    item.HarmonizedCodeNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HarmonizedCodeNumber", "", currRow), "string", True)
                    If Not String.IsNullOrEmpty(item.HarmonizedCodeNumber) Then
                        item.HarmonizedCodeNumber = Right("0000000000" & item.HarmonizedCodeNumber, 10)
                    End If
                    item.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Canada_Harmonized_Code_Number", "", currRow), "string", True)
                    If Not String.IsNullOrEmpty(item.CanadaHarmonizedCodeNumber) Then
                        item.CanadaHarmonizedCodeNumber = Right("0000000000" & item.CanadaHarmonizedCodeNumber, 10)
                    End If
                    item.DetailInvoiceCustomsDesc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc", "", currRow), "string", True)
                    item.ComponentMaterialBreakdown = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ComponentMaterialBreakdown", "", currRow), "string", True)


                    ' CHECK FOR VALID EXISTING SKU
                    sku = item.MichaelsSKU
                    'vendorNumber
                    If sku <> String.Empty AndAlso vendorNumber > 0 Then
                        'note the vendorNumber here is for the pack, we need to ignore that for components on SB packs
                        If item.PackItemIndicator = "C" And batchPackIndicator = "SB" Then
                            itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(0, sku, 0)
                        Else
                            itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(vendorNumber, sku, vendorNumber)
                        End If
                        If itemMaintItem IsNot Nothing AndAlso (itemMaintItem.SKU <> String.Empty And itemMaintItem.VendorNumber > 0) Then
                            ' MERGE
                            Dim tempPackItemIndicator As String = item.PackItemIndicator
                            ItemHelper.MergeItemMaintRecordIntoItem(itemHeader, item, itemMaintItem)
                            item.PackItemIndicator = tempPackItemIndicator
                            item.ValidExistingSKU = True
                            itemMaintItem = Nothing
                        Else
                            item.ValidExistingSKU = False
                        End If
                    Else
                        item.ValidExistingSKU = False
                    End If

                    ' Save
                    ' ------------------
                    item.SaveAudit = False

                    itemID = objMichaels.SaveRecord(item, userID)

                    'Save Language information
                    NLData.Michaels.ItemDetail.SaveItemLanguage(itemID, 1, item.PLIEnglish, item.TIEnglish, item.EnglishShortDescription, item.EnglishLongDescription, userID)
                    NLData.Michaels.ItemDetail.SaveItemLanguage(itemID, 2, item.PLIFrench, item.TIFrench, item.FrenchShortDescription, item.FrenchLongDescription, userID)
                    NLData.Michaels.ItemDetail.SaveItemLanguage(itemID, 3, item.PLISpanish, item.TISpanish, item.SpanishShortDescription, item.SpanishLongDescription, userID)

                    If itemID <= 0 Then
                        ' ERROR: item  not saved.
                        fileImportPanel.Visible = False
                        fileImportError.Visible = True
                        Exit Do
                    End If

                    ' Save XRef to this image
                    If item.ValidExistingSKU AndAlso item.ImageID > 0 Then
                        objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_DOMESTIC, itemID, item.ImageID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image, userID)

                        ' audit
                        Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                        Dim audit As New Models.AuditRecord()
                        audit.SetupAudit(Models.MetadataTable.Items_Files, itemID, Models.AuditRecordType.Insert, userID)
                        audit.AddAuditField("File_ID", item.ImageID)
                        objFA.SaveAuditRecord(audit)
                        objFA = Nothing
                        audit = Nothing

                    End If

                    ' Save XRef to MSDS sheet for existing SKU (if exists)...
                    If item.ValidExistingSKU AndAlso item.MSDSID > 0 Then
                        objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_DOMESTIC, itemID, item.MSDSID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS, userID)

                        ' audit
                        Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                        Dim audit As New Models.AuditRecord()
                        audit.SetupAudit(Models.MetadataTable.Items_Files, itemID, Models.AuditRecordType.Insert, userID)
                        audit.AddAuditField("File_ID", item.MSDSID)
                        objFA.SaveAuditRecord(audit)
                        objFA = Nothing
                        audit = Nothing
                    End If

                End If

                itemRows += 1
                'currRow2 += 1

            Loop
            ' show status of upload
            fileImportPanel.Visible = False
            fileImportSuccess.Visible = True
        Else
            ' ERROR: item header not saved.
            fileImportPanel.Visible = False
            fileImportError.Visible = True
        End If

        objMichaelsMap = Nothing
        objMichaelsVendor = Nothing
        objMichaels = Nothing
        objMichaelsIFile = Nothing

        lvgs = Nothing

        Return True

    End Function

    Public Function UploadImportFile(ByRef wb As SpreadsheetGear.IWorkbook) As Boolean

        Dim ws As SpreadsheetGear.IWorksheet
        Dim item As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord = Nothing
        Dim itemparent As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord = Nothing
        Dim itemID As Long = 0
        Dim userID As Integer = DataHelper.SmartValues(Session("UserID"), "integer")
        Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping

        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
        Dim objMichaelsIFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()
        'LP SPEDY order 12
        Dim itemMap2 As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = Nothing
        Dim ws2 As SpreadsheetGear.IWorksheet
        Dim currRow2 As Integer = WebConstants.NEW_ITEM_TAB_START_ROW
        Dim iCount As Integer = 0
        Dim wsName As String = String.Empty
        Dim imc As Models.ItemMappingColumn = Nothing

        'If the spreadsheet contains Regular Items in different batches, use this object to keep track of each batch.
        Dim vendorBatches As New System.Collections.Generic.Dictionary(Of Integer, Models.ImportItemRecord)
        'NAK 4/4/2011 HACK to WF to start batch in CAA/CMA if contains an item with a QuoteReferenceNumber
        Dim quoteBatches As New System.Collections.Generic.Dictionary(Of Integer, Boolean)

        Dim lvgs As ListValueGroups = FormHelper.LoadListValues("PACKITEMIND")

        Dim tabName As String = ""
        For itab As Integer = 0 To wb.Worksheets.Count - 1
            tabName = wb.Worksheets(itab).Name
            If ExcelFileHelper.IsValidTabName(tabName) Then
                ws = ExcelFileHelper.GetExcelWorksheet(wb, tabName)
                Exit For
            End If
        Next

        'ws = ExcelFileHelper.GetExcelWorksheet(wb, WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET)
        ws2 = ExcelFileHelper.GetExcelWorksheet(wb, WebConstants.LIKE_ITEM_TAB_WORKSHEET)

        'Get mapping Version
        Dim mapVer As String = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, "B", 3), "string", False)


        'Get item map
        Dim objMichaelsMap As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping()
        itemMap = objMichaelsMap.GetMapping("IMPORTITEM", mapVer)
        If itemMap Is Nothing OrElse itemMap.ID = 0 Then
            'if the version number ends in 0 the mapVer will not have the trailing zero so we much try to find it by that
            mapVer = mapVer + "0"
            itemMap = objMichaelsMap.GetMapping("IMPORTITEM", mapVer)
        End If

        itemMap2 = objMichaelsMap.GetMapping("LIKEITEMAPPROVAL", "CURRENT")
        objMichaelsMap = Nothing

        If itemMap Is Nothing OrElse itemMap.Count <= 0 Then
            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_VERSION, mapVer))
        End If

        Dim vendor As Models.VendorRecord = Nothing, vnum As Integer
        Dim objMichaelsVendor As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
        Dim validBatch As Boolean = True
        Dim sku As String
        Dim vendorNumber As Long
        Dim itemMaintItem As Models.ItemMaintItemDetailFormRecord
        Dim quoteRefNumber As String
        Dim packIndicator As String
        Dim batchPackIndicator As String = ""
        Dim itemTask As String
        Dim tempVendorNumber As Long = 0

        Dim i As Integer, tempUPC As String, strTemp As String

        Try

            ' DETERMINE IF THERE IS A SKU/VENDOR COMBINATION THAT DOES NOT EXIST IN RMS (FAILING UPLOAD IF NECESSARY)

            Do While (ws IsNot Nothing)
                ' get the sku and QuoteRefNum
                sku = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MichaelsSKU"), "string", True).ToString.Trim()
                quoteRefNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuoteReferenceNumber"), "string", True)
                packIndicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PackItemIndicator"), "string", True)
                If packIndicator = "SB" Then
                    batchPackIndicator = "SB"
                End If

                ' always use the vendor id from the spreadsheet if current row is a component on a SB item
                If UseSessionVendor And Not (batchPackIndicator = "SB" And packIndicator = "C") Then
                    vendorNumber = AppHelper.GetVendorID()
                Else
                    vendorNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorNumber"), "integer", True)
                End If

                'Make vendor Number a required field
                If vendorNumber < 0 Then
                    Throw New SPEDYUploadException(WebConstants.IMPORT_ERROR_INVALID_VENDOR_NUMBER)
                End If

                ' if sku is filled in, get the vendor # and check for valid Item Master record
                If sku <> String.Empty Then
                    If batchPackIndicator = "SB" And packIndicator = "C" Then
                        'for SB components, we're fine with any vendor, if we pass in 0, the load routine will get the primary vendor
                        itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(0, sku, 0)
                        vendorNumber = itemMaintItem.VendorNumber
                    Else
                        If vendorNumber > 0 Then
                            itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(vendorNumber, sku, vendorNumber)
                        Else
                            itemMaintItem = Nothing
                        End If
                    End If

                    ' check for valid item master record
                    If vendorNumber <= 0 OrElse itemMaintItem Is Nothing OrElse (itemMaintItem.SKU = String.Empty Or itemMaintItem.VendorNumber <= 0) Then
                        Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERR0R_INVALID_SKU_VENDOR, sku))
                        validBatch = False
                    End If

                    'NAK 4/30/2013:  Per Michaels, it is ok if SKU is already in an Item Maintenance Batch.
                    ' check if the sku is already in a batch
                    'Dim skuList As System.Collections.Generic.List(Of Models.ItemSearchRecord) = _
                    '    BatchesData.SearchSKURecs(0, vendorNumber, 0, 0, String.Empty, String.Empty, sku, _
                    '        String.Empty, String.Empty, String.Empty, String.Empty, userID, 0, String.Empty, String.Empty, 0, 0, quoteRefNumber)
                    'If skuList.Count = 1 Then
                    '    Dim thisISR As Models.ItemSearchRecord = skuList(0)
                    '    If thisISR.BatchID > 0 Then
                    '        Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_SKU_BATCH, sku, thisISR.BatchID))
                    '        validBatch = False
                    '    End If
                    'End If

                    ' check if the sku is a pack parent
                    If itemMaintItem IsNot Nothing Then
                        If itemMaintItem.IsPackParent() Then
                            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_SKU_PACK_PARENT, sku))
                            validBatch = False
                        End If
                    End If
                Else
                    'If there is no SKU specified, verify the quote reference number doesn't exist
                    If quoteRefNumber <> String.Empty Then

                        'NAK 11/7/2011: Only perform Quote Sheet Status validation if there is a QRN
                        ' verify the sheet status is not 'DRAFT'
                        Dim quoteSheetStatus As String = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuoteSheetStatus"), "string", True)
                        If quoteSheetStatus.ToUpper = "DRAFT" OrElse quoteSheetStatus = String.Empty Then
                            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_QUOTE_SHEET_STATUS, quoteSheetStatus))
                            validBatch = False
                        End If

                        Dim objMichaels2 As New NovaLibra.Coral.Data.Michaels.ImportItemDetail
                        Dim existItem As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
                        existItem = objMichaels2.GetItemRecordByQRN(quoteRefNumber)

                        If Not existItem Is Nothing AndAlso existItem.ID > 0 Then
                            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_QRN_BATCH, quoteRefNumber, existItem.Batch_ID))
                            validBatch = False
                        End If
                    End If
                End If

                'verify the task type - parent item and regular items cannot be of type EDIT
                packIndicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PackItemIndicator"), "string", True)
                itemTask = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ItemTask"), "string", True)
                If packIndicator = String.Empty Or packIndicator = "R" Or packIndicator.StartsWith("D") Or packIndicator.StartsWith("SB") Then
                    If itemTask.ToUpper.StartsWith("EDIT") Then
                        Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_TASK_TYPE, itemTask))
                        validBatch = False
                    End If


                    If sku <> String.Empty And itemTask.ToUpper.StartsWith("NEW") Then
                        Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_ITEMTASK_NEW_SKU, sku))
                        validBatch = False
                    End If
                End If

                'Add Vendor to the VendorBatch list if this is a regular item
                If packIndicator = String.Empty Or packIndicator = "R" Then
                    If Not vendorBatches.ContainsKey(vendorNumber) Then
                        vendorBatches.Add(vendorNumber, Nothing)
                    End If
                Else
                    'If not a regular item, compare to 1st vendor number
                    If tempVendorNumber = 0 Then
                        tempVendorNumber = vendorNumber
                        If Not vendorBatches.ContainsKey(vendorNumber) Then
                            vendorBatches.Add(vendorNumber, Nothing)
                        End If
                    Else
                        'skip this error for C items on an SB batch
                        If tempVendorNumber <> vendorNumber And batchPackIndicator <> "SB" And packIndicator <> "C" Then
                            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_VENDOR_PACK, tempVendorNumber, vendorNumber))
                            validBatch = False
                        End If
                    End If
                End If

                If itemTask.ToUpper.StartsWith("EDIT") And (sku = String.Empty Or sku Is Nothing) Then
                    Throw New SPEDYUploadException(WebConstants.IMPORT_ERROR_INVALID_ITEMTASK_EDIT_SKU)
                End If

                ' next
                iCount += 1
                'wsName = WebConstants.IMPORT_ITEM_CHILD_WORKSHEET
                'ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName.Replace("#", iCount))wb.Worksheets(5).Name

                Dim bFound As Boolean = False

                For itemp As Integer = ws.Index + 1 To wb.Worksheets.Count - 1
                    wsName = wb.Worksheets.Item(itemp).Name
                    If ExcelFileHelper.IsValidTabName(wsName) Then
                        ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName)
                        bFound = True
                        Exit For
                    End If
                Next

                If Not bFound Then
                    ws = Nothing
                End If

            Loop

            ' RESET stuff
            For itab As Integer = 0 To wb.Worksheets.Count - 1
                tabName = wb.Worksheets(itab).Name
                If ExcelFileHelper.IsValidTabName(tabName) Then
                    ws = ExcelFileHelper.GetExcelWorksheet(wb, tabName)
                    Exit For
                End If
            Next
            'ws = ExcelFileHelper.GetExcelWorksheet(wb, WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET)
            iCount = 0

            ' PROCESS THE UPLOAD

            If validBatch Then
                Do While (ws IsNot Nothing)
                    ' New Item
                    item = New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord()
                    item.SetupAudit(NovaLibra.Coral.SystemFrameworks.Michaels.MetadataTable.Import_Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Insert, userID)

                    ' Defaults
                    'NAK 9/14/2012: PER Srilatha at Michaels, we are no longer blanket defaulting the Private Brand Label if one is specified
                    'item.PrivateBrandLabel = WebConstants.LIST_VALUE_DEFAULT_PRIVATE_BRAND_LABEL

                    ' Read values from excel
                    item.DateSubmitted = DataHelper.SmartValues(Now().ToShortDateString(), "date", True)
                    item.Vendor = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Vendor"), "string", True)
                    item.Agent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Agent"), "string", True)
                    item.Buyer = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Buyer"), "string", True)
                    item.Fax = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Fax"), "string", True)
                    item.EnteredBy = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnteredBy"), "string", True)
                    item.SKUGroup = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SKUGroup"), "string", True)
                    item.Email = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Email"), "string", True)
                    item.EnteredDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws, itemMap, "EnteredDate"), "date", True)
                    item.Dept = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Dept"), "string", True)
                    item.Class = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Class"), "string", True)
                    item.SubClass = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SubClass"), "string", True)
                    tempUPC = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrimaryUPC"), "string", True)
                    If tempUPC.Length > 0 Then
                        item.PrimaryUPC = FormatUPCValue(tempUPC)
                    End If
                    item.MichaelsSKU = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MichaelsSKU"), "string", True)

                    ' GenerateMichaelsUPC
                    item.GenerateMichaelsUPC = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "GenerateMichaelsUPC"), "string", True)

                    'PMO200141 GTIN14 Enhancements changes
                    'item.InnerGTIN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InnerGTIN"), "String", True)
                    'item.CaseGTIN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CaseGTIN"), "String", True)
                    'item.GenerateMichaelsGTIN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "GenerateMichaelsGTIN"), "String", True)

                    ' Save Additional UPCs
                    item.AdditionalUPCRecord.AdditionalUPCs.Clear()
                    For i = 1 To 8
                        strTemp = "AdditionalUPC" & CStr(i)
                        tempUPC = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, strTemp), "string", True)
                        tempUPC = tempUPC.Trim()
                        If tempUPC.Length > 0 Then
                            item.AdditionalUPCRecord.AddAdditionalUPC(FormatUPCValue(tempUPC))
                        End If
                    Next
                    ' AdditionalUPCs
                    imc = itemMap.GetMappingColumn("AdditionalUPCs")
                    If imc IsNot Nothing Then
                        i = imc.ExcelRow
                        tempUPC = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, imc.ExcelColumn, i), "string", True)
                        tempUPC = tempUPC.Trim()
                        Do While tempUPC.Length > 0
                            item.AdditionalUPCRecord.AddAdditionalUPC(FormatUPCValue(tempUPC))
                            i = i + 1
                            tempUPC = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, imc.ExcelColumn, i), "string", True)
                            tempUPC = tempUPC.Trim()
                        Loop
                    End If


                    item.PackSKU = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PackSKU"), "string", True)
                    item.PlanogramName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PlanogramName"), "stringrsu", True)
                    If item.PlanogramName.Length > 50 Then
                        item.PlanogramName = item.PlanogramName.Substring(0, 50)
                    End If

                    ' vendor number and name
                    vendor = Nothing
                    If UseSessionVendor Then
                        item.VendorNumber = AppHelper.GetVendorID()
                        vendor = objMichaelsVendor.GetVendorRecord(DataHelper.SmartValues(item.VendorNumber, "integer", False))
                        If Not vendor Is Nothing AndAlso ValidationHelper.IsValidImportVendor(vendor) Then
                            item.VendorName = vendor.VendorName
                        Else
                            item.VendorName = String.Empty
                        End If
                    Else

                        vnum = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorNumber"), "integer", True)
                        If vnum > 0 Then
                            item.VendorNumber = vnum
                            vendor = objMichaelsVendor.GetVendorRecord(vnum)
                        End If

                        If Not vendor Is Nothing AndAlso ValidationHelper.IsValidImportVendor(vendor) Then
                            item.VendorName = vendor.VendorName
                        End If
                    End If

                    item.VendorRank = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorRank"), "string", True)
                    item.ItemTask = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ItemTask"), "string", True)
                    item.Description = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Description"), "stringrsu", True)
                    If item.Description.Length > 30 Then
                        item.Description = item.Description.Substring(0, 30)
                    End If
                    item.QuoteSheetStatus = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuoteSheetStatus"), "string", True)
                    item.Season = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Season"), "string", True)
                    item.PaymentTerms = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PaymentTerms"), "string", True)
                    item.Days = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Days"), "string", True)
                    item.VendorMinOrderAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorMinOrderAmount"), "decimal", True, String.Empty, 2)

                    item.VendorAddress1 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress1"), "string", True)
                    item.VendorAddress2 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress2"), "string", True)
                    item.VendorAddress3 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress3"), "string", True)
                    item.VendorAddress4 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress4"), "string", True)
                    item.VendorContactName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactName"), "string", True)
                    item.VendorContactPhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactPhone"), "string", True)
                    item.VendorContactEmail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactEmail"), "string", True)
                    item.VendorContactFax = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactFax"), "string", True)
                    item.ManufactureName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureName"), "string", True)
                    item.ManufactureAddress1 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureAddress1"), "string", True)
                    item.ManufactureAddress2 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureAddress2"), "string", True)
                    item.ManufactureContact = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureContact"), "string", True)
                    item.ManufacturePhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufacturePhone"), "string", True)
                    item.ManufactureEmail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureEmail"), "string", True)
                    item.ManufactureFax = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureFax"), "string", True)
                    item.AgentContact = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentContact"), "string", True)
                    item.AgentPhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentPhone"), "string", True)
                    item.AgentEmail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentEmail"), "string", True)
                    item.AgentFax = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentFax"), "string", True)
                    item.VendorStyleNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorStyleNumber"), "stringrsu", True)
                    item.HarmonizedCodeNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HarmonizedCodeNumber"), "string", True)
                    'Prepend 0s to Harmonized Code Number (so it is always 10 digits long
                    If Not String.IsNullOrEmpty(item.HarmonizedCodeNumber) Then
                        item.HarmonizedCodeNumber = Right("0000000000" & item.HarmonizedCodeNumber, 10)
                    End If

                    item.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CanadaHarmonizedCodeNumber"), "string", True)
                    'Prepend 0s to Canada Harmonized Code Number (so it is always 10 digits long
                    If Not String.IsNullOrEmpty(item.CanadaHarmonizedCodeNumber) Then
                        item.CanadaHarmonizedCodeNumber = Right("0000000000" & item.CanadaHarmonizedCodeNumber, 10)
                    End If

                    item.DetailInvoiceCustomsDesc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc", WebConstants.MULTILINE_DELIM), "string", True)
                    item.ComponentMaterialBreakdown = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ComponentMaterialBreakdown", WebConstants.MULTILINE_DELIM), "string", True)
                    item.ComponentConstructionMethod = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ComponentConstructionMethod", WebConstants.MULTILINE_DELIM), "string", True)
                    item.IndividualItemPackaging = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "IndividualItemPackaging"), "string", True)

                    item.QtyInPack = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Qty_In_Pack"), "integer", True)

                    item.EachInsideMasterCaseBox = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachInsideMasterCaseBox"), "string", True)
                    item.EachInsideInnerPack = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachInsideInnerPack"), "string", True)

                    'item.EachPieceNetWeightLbsPerOunce = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachPieceNetWeightLbsPerOunce"), "string", True)

                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonWeight"), "decimal", True, String.Empty, 4)) Then
                        item.ReshippableInnerCartonWeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonWeight"), "decimal", True, String.Empty, 4)
                    End If

                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachheight"), "decimal", True, String.Empty, 4)) Then
                        item.EachHeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachheight"), "decimal", True, String.Empty, 4)
                    End If
                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachwidth"), "decimal", True, String.Empty, 4)) Then
                        item.EachWidth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachwidth"), "decimal", True, String.Empty, 4)
                    End If
                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachlength"), "decimal", True, String.Empty, 4)) Then
                        item.EachLength = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachlength"), "decimal", True, String.Empty, 4)
                    End If
                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachweight"), "decimal", True, String.Empty, 4)) Then
                        item.EachWeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachweight"), "decimal", True, String.Empty, 4)
                    End If
                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "cubicfeeteach"), "decimal", True, String.Empty, 4)) Then
                        item.CubicFeetEach = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "cubicfeeteach"), "decimal", True, String.Empty, 4)
                    End If
                    item.ReshippableInnerCartonLength = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonLength"), "string", True, String.Empty, 4))
                    item.ReshippableInnerCartonWidth = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonWidth"), "string", True, String.Empty, 4))
                    item.ReshippableInnerCartonHeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonHeight"), "string", True, String.Empty, 4))
                    item.MasterCartonDimensionsLength = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCartonDimensionsLength"), "string", True, String.Empty, 4))
                    item.MasterCartonDimensionsWidth = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCartonDimensionsWidth"), "string", True, String.Empty, 4))
                    item.MasterCartonDimensionsHeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCartonDimensionsHeight"), "string", True, String.Empty, 4))

                    item.CubicFeetPerMasterCarton = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CubicFeetPerMasterCarton"), "decimal", True, String.Empty, 4)

                    item.WeightMasterCarton = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "WeightMasterCarton"), "string", True), 4)
                    item.CubicFeetPerInnerCarton = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CubicFeetPerInnerCarton"), "decimal", True, String.Empty, 4)

                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Displayer_Cost"), "decimal", True, String.Empty, 4)) Then
                        item.DisplayerCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Displayer_Cost"), "decimal", True, String.Empty, 4)
                    End If
                    If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Product_Cost"), "decimal", True, String.Empty, 4)) Then
                        item.ProductCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Product_Cost"), "decimal", True, String.Empty, 4)
                    End If

                    item.FOBShippingPoint = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FOBShippingPoint"), "decimal", True, String.Empty, 4)
                    item.DutyPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DutyPercent"), "decimal", True, String.Empty, 4)
                    item.DutyAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DutyAmount"), "decimal", True, String.Empty, 4)
                    item.AdditionalDutyComment = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AdditionalDutyComment"), "string", True)
                    item.AdditionalDutyAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AdditionalDutyAmount"), "decimal", True, String.Empty, 4)

                    item.SuppTariffPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SuppTariffPercent"), "decimal", True, String.Empty, 4)
                    item.SuppTariffAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SuppTariffAmount"), "decimal", True, String.Empty, 4)

                    item.OceanFreightAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OceanFreightAmount"), "decimal", True, String.Empty, 4)
                    item.OceanFreightComputedAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OceanFreightComputedAmount"), "decimal", True, String.Empty, 4)
                    item.AgentCommissionPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentCommissionPercent"), "decimal", True, String.Empty, 4)
                    item.AgentCommissionAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentCommissionAmount"), "decimal", False, String.Empty, 4)
                    item.OtherImportCostsPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OtherImportCostsPercent"), "decimal", True, String.Empty, 4)
                    If DataHelper.SmartValues(item.OtherImportCostsPercent, "decimal", False) <= 0 Then
                        item.OtherImportCostsPercent = "0.0200"
                    End If
                    item.OtherImportCostsAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OtherImportCostsAmount"), "decimal", True, String.Empty, 4)
                    'item.PackagingCostAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PackagingCostAmount"), "decimal", True, String.Empty, 4)
                    item.TotalImportBurden = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TotalImportBurden"), "decimal", True, String.Empty, 4)
                    item.WarehouseLandedCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "WarehouseLandedCost"), "decimal", True, String.Empty, 4)
                    item.PurchaseOrderIssuedTo = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PurchaseOrderIssuedTo", WebConstants.MULTILINE_DELIM), "string", True)
                    item.ShippingPoint = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ShippingPoint"), "string", True)

                    Dim countryName As String = String.Empty
                    Dim countryCode As String = String.Empty
                    countryName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CountryOfOrigin"), "string", True)
                    Dim country As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(countryName)
                    If Not country Is Nothing AndAlso country.CountryName <> String.Empty AndAlso country.CountryCode <> String.Empty Then
                        countryName = country.CountryName
                        countryCode = country.CountryCode
                    End If
                    item.CountryOfOriginName = countryName
                    item.CountryOfOrigin = countryCode
                    country = Nothing

                    item.VendorComments = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorComments"), "stringrs", True)
                    item.StockCategory = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "StockCategory"), "string", True)
                    item.FreightTerms = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FreightTerms"), "string", True)
                    item.ItemType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ItemType"), "string", True)
                    item.PackItemIndicator = Trim(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PackItemIndicator"), "string", True))
                    If Not IsValidListValue(lvgs, "PACKITEMIND", item.PackItemIndicator, True) Then
                        item.PackItemIndicator = String.Empty
                    End If

                    item.ItemTypeAttribute = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ItemTypeAttribute"), "string", True)
                    item.AllowStoreOrder = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AllowStoreOrder"), "string", True)
                    item.InventoryControl = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InventoryControl"), "string", True)
                    item.AutoReplenish = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AutoReplenish"), "string", True)
                    item.PrePriced = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrePriced"), "string", True)
                    item.TaxUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TaxUDA"), "string", True)
                    item.PrePricedUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrePricedUDA"), "string", True)
                    item.TaxValueUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TaxValueUDA"), "string", True)
                    'item.HybridType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HybridType"), "string", True)
                    'item.SourcingDC = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SourcingDC"), "string", True)
                    'item.LeadTime = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "LeadTime"), "string", True)
                    'item.ConversionDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws, itemMap, "ConversionDate"), "date", True)
                    Dim tempSSC As String = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Stocking_Strategy_Code"), "string", True)
                    If tempSSC.Contains("-") Then
                        tempSSC = tempSSC.Substring(0, tempSSC.IndexOf("-")).TrimEnd
                        item.StockingStrategyCode = tempSSC
                    Else
                        item.StockingStrategyCode = tempSSC
                    End If
                    'item.StockingStrategyCode = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Stocking_Strategy_Code"), "string", True)
                    item.StoreSuppZoneGRP = "1"
                    item.WhseSuppZoneGRP = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "WhseSuppZoneGRP"), "string", True)
                    '2 lines below are now absolite, read from Liket Item, LP Sept 2009    
                    'item.POGMaxQty = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "POGMaxQty"), "string", True)
                    'item.POGSetupPerStore = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "POGSetupPerStore"), "string", True)
                    'item.ProjSalesPerStorePerMonth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ProjSalesPerStorePerMonth"), "string", True)
                    item.OutboundFreight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OutboundFreight"), "string", True)
                    item.NinePercentWhseCharge = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "NinePercentWhseCharge"), "string", True)
                    item.TotalStoreLandedCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TotalStoreLandedCost"), "string", True)
                    item.RDBase = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDBase"), "decimal", True, 0, 2)
                    item.RDCentral = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDCentral"), "decimal", True, 0, 2)
                    item.RDTest = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDTest"), "decimal", True, 0, 2)
                    item.RDAlaska = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDAlaska"), "decimal", True, 0, 2)

                    'Canada logic below changed by KH 2019-07-15
                    item.RDCanada = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDCanada"), "decimal", True, 0, 2)
                    'item.RDCanada = NovaLibra.Coral.Data.Michaels.ItemDetail.GetGridPrice(5, item.RDBase)

                    item.RD0Thru9 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RD0Thru9"), "decimal", True, 0, 2)
                    item.RDCalifornia = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDCalifornia"), "decimal", True, 0, 2)
                    item.RDVillageCraft = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDVillageCraft"), "decimal", True, 0, 2)
                    'lp change order 14 Sept 3 2009
                    item.Retail9 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail9"), "decimal", True, 0, 2)
                    item.Retail10 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail10"), "decimal", True, 0, 2)
                    item.Retail11 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail11"), "decimal", True, 0, 2)
                    item.Retail12 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail12"), "decimal", True, 0, 2)
                    item.Retail13 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Retail13"), "decimal", True, 0, 2)

                    'item.RDQuebec = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDQuebec"), "decimal", True, 0, 2)
                    item.RDQuebec = item.RDCanada
                    'PER Michaels Requirements - Default Value to Canada value when RDQuebec is empty/null
                    If item.RDQuebec = 0 Then
                        item.RDQuebec = item.RDCanada
                    End If
                    item.RDPuertoRico = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "RDPuertoRico"), "decimal", True, 0, 2)
                    'PER Michaels Requirements - Default value to Base1 Retail when RDPuertoRico is empty/null
                    If item.RDPuertoRico = 0 Then
                        item.RDPuertoRico = item.RDBase
                    End If

                    'lp change order 14
                    item.HazMatYes = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatYes"), "string", True)
                    item.HazMatNo = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatNo"), "string", True)
                    item.HazMatMFGCountry = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatMFGCountry"), "string", True)
                    item.HazMatMFGName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatMFGName"), "string", True)
                    item.HazMatMFGFlammable = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatMFGFlammable"), "string", True)
                    item.HazMatMFGCity = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatMFGCity"), "string", True)
                    item.HazMatContainerType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatContainerType"), "string", True)
                    item.HazMatMFGState = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatMFGState"), "string", True)
                    item.HazMatContainerSize = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatContainerSize"), "string", True)
                    item.HazMatMFGPhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatMFGPhone"), "string", True)
                    item.HazMatMSDSUOM = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazMatMSDSUOM"), "string", True)

                    item.CoinBattery = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CoinBattery"), "string", True)
                    'item.TSSA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TSSA"), "string", True)
                    item.CSA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CSA"), "string", True)
                    item.UL = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "UL"), "string", True)
                    item.LicenceAgreement = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "LicenceAgreement"), "string", True)
                    item.FumigationCertificate = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FumigationCertificate"), "string", True)
                    item.PhytoTemporaryShipment = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PhytoTemporaryShipment"), "string", True)
                    If item.PhytoTemporaryShipment.Trim.ToUpper = "YES" Then
                        item.PhytoTemporaryShipment = "Y"
                    ElseIf item.PhytoTemporaryShipment.Trim.ToUpper = "NO" Then
                        item.PhytoTemporaryShipment = "N"
                    End If
                    item.KILNDriedCertificate = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "KILNDriedCertificate"), "string", True)
                    item.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ChinaComInspecNumAndCCIBStickers"), "string", True)
                    item.OriginalVisa = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OriginalVisa"), "string", True)
                    item.TextileDeclarationMidCode = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TextileDeclarationMidCode"), "string", True)
                    item.QuotaChargeStatement = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuotaChargeStatement"), "string", True)
                    item.MSDS = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MSDS"), "string", True)
                    item.TSCA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TSCA"), "string", True)
                    item.DropBallTestCert = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DropBallTestCert"), "string", True)
                    item.ManMedicalDeviceListing = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManMedicalDeviceListing"), "string", True)
                    item.ManFDARegistration = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManFDARegistration"), "string", True)
                    item.CopyRightIndemnification = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CopyRightIndemnification"), "string", True)
                    item.FishWildLifeCert = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FishWildLifeCert"), "string", True)
                    item.Proposition65LabelReq = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Proposition65LabelReq"), "string", True)
                    item.CCCR = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CCCR"), "string", True)
                    item.FormaldehydeCompliant = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FormaldehydeCompliant"), "string", True)

                    'item.MinimumOrderQuantity = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MinimumOrderQuantity"), "integer", True)
                    item.ProductIdentifiesAsCosmetic = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ProductIdentifiesAsCosmetic"), "string", True)


                    'Add Quote Reference Number
                    item.QuoteReferenceNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuoteReferenceNumber"), "string", True)

                    'Get Private Brand Label (PBL) from the Spreadsheet, and compare it to the list of PBLs in the database.
                    Dim pbl As String = DataHelper.SmartValue(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrivateBrandLabel"), "string", True)
                    Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
                    If pbllvgs IsNot Nothing Then
                        For Each lv As ListValue In pbllvgs.ListValues
                            If lv.DisplayText.ToUpper = pbl.ToUpper Then
                                item.PrivateBrandLabel = lv.Value
                            End If
                        Next
                    End If

                    'IF there is no Quote Reference Number AND the PBL field is blank, default it.
                    If String.IsNullOrEmpty(item.PrivateBrandLabel) And String.IsNullOrEmpty(item.QuoteReferenceNumber) Then
                        item.PrivateBrandLabel = WebConstants.LIST_VALUE_DEFAULT_PRIVATE_BRAND_LABEL
                    End If

                    'If item.Agent <> String.Empty Then
                    'item.AgentType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType1"), "string", True)
                    'If item.AgentType = String.Empty Then
                    'item.AgentType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType2"), "string", True)
                    'End If
                    'End If
                    'lp 05/20/2009 fix
                    'LP changes based on the change order 14 added requirement sEPT 2009, Support 2 version12.55 and 12.8
                    If item.Agent <> String.Empty Then
                        Dim AgentType1x As String = String.Empty, AgentType2x As String = String.Empty
                        AgentType1x = Trim$(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType1X"))
                        AgentType2x = Trim$(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType2X"), "string", True)) 'Trim$(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType2X")))
                        'If AgentType1x <> String.Empty And AgentType2x = String.Empty Then
                        '    item.AgentType = "LI & FUNG"
                        'ElseIf AgentType2x <> String.Empty And AgentType1x = String.Empty Then
                        '    item.AgentType = "TEST RITE"
                        'End If
                        'per Michaels request, only load one of those 3 agents, need to not hard code it!
                        If UCase(AgentType2x) = "X" And AgentType1x = String.Empty Then
                            ' version- 12.55 detected
                            item.AgentType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType2"), "string", True)
                        ElseIf UCase(AgentType1x) = "X" And AgentType2x = String.Empty Then
                            ' 12.55 detected
                            item.AgentType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType1"), "string", True)
                        Else
                            item.AgentType = AgentType2x
                        End If
                        If item.AgentType = "DGS" Then
                            'hardcode DGS to zero commission, even if the spreadsheet says otherwise
                            item.AgentCommissionPercent = "0.00"
                            item.AgentCommissionAmount = "0.0000"
                        End If
                    End If
                    ' RMS
                    item.RMSSellable = WebConstants.IMPORT_RMS_DEFAULT_VALUE
                    item.RMSOrderable = WebConstants.IMPORT_RMS_DEFAULT_VALUE
                    item.RMSInventory = WebConstants.IMPORT_RMS_DEFAULT_VALUE

                    'NAK 7/13/2011: Rewriting Parent/Child Code
                    '  IF this is a Regular Item, check the VendorBatches for a Parent
                    '  Otherwise, use whatever value is set for the Item Parent
                    If (item.PackItemIndicator = String.Empty Or item.PackItemIndicator = "R") Then
                        If (vendorBatches(vendorNumber) IsNot Nothing) Then
                            item.ParentID = vendorBatches(item.VendorNumber).ID
                            item.Batch_ID = vendorBatches(item.VendorNumber).Batch_ID
                        End If
                    Else
                        If iCount > 0 Then
                            item.ParentID = itemparent.ID
                            item.Batch_ID = itemparent.Batch_ID
                        End If
                    End If

                    'NAK: This is a guess.  Waiting to hear back from KEN to see if this is correct..
                    'If PackItemIndicator = 'R', OR is Empty THEN this is a Regular item.
                    If (item.PackItemIndicator = "R" Or item.PackItemIndicator = String.Empty) Then
                        item.RegularBatchItem = True
                    End If

                    'LP SPEDY Order 12 now load the Like Item Sheet here, before moving to the child item if any
                    'need isnumeric checks?
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Store_Total"))) Then
                        item.StoreTotal = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Store_Total"), "integer", True, Decimal.MinValue)
                    End If
                    Dim icalc As Integer = 0
                    'special handling case, we have to support legacy where calc options is stored in AK3
                    If IsNumeric(Trim(ExcelFileHelper.GetCell(ws2, "AK", 3))) Then icalc = CInt(ExcelFileHelper.GetCell(ws2, "AK", 3))
                    item.CalculateOptions = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Calculate_Options"), "integer", True, 0)
                    If icalc <> 0 Then item.CalculateOptions = icalc
                    If item.CalculateOptions > 2 OrElse item.CalculateOptions < 0 Then item.CalculateOptions = 0 'in case of values other then 0,1,2
                    item.POGStartDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws2, itemMap2, "POG_Start_Date"), "date", True)
                    item.POGCompDate = DataHelper.SmartValues(ExcelFileHelper.GetCellDateByMap(ws2, itemMap2, "POG_Comp_Date"), "date", True)
                    'here where rows count is important
                    item.LikeItemSKU = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_SKU", "", currRow2), "string", True, String.Empty)
                    item.LikeItemDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Description", "", currRow2), "string", True, String.Empty)
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Retail", "", currRow2))) Then
                        item.LikeItemRetail = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Retail", "", currRow2), "decimal", True, Decimal.MinValue, 4)
                    End If
                    'per michaels request, gest description when sku is provided but decription is missing
                    If item.LikeItemSKU.Trim() <> String.Empty And item.LikeItemDescription.Trim() = String.Empty Then
                        Dim strSku As String = DataHelper.SmartValues(item.LikeItemSKU.Trim(), "string", False)
                        Dim objRecord As Models.ItemMasterRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupItemMaster(strSku)
                        If Not objRecord Is Nothing AndAlso (objRecord.ItemDescription <> String.Empty Or objRecord.BaseRetail <> Decimal.MinValue) Then
                            item.LikeItemDescription = objRecord.ItemDescription
                            If objRecord.BaseRetail <> Decimal.MinValue Then
                                item.LikeItemRetail = DataHelper.SmartValues(objRecord.BaseRetail, "decimal", True, Decimal.MinValue, 2)
                            End If
                        End If
                        objRecord = Nothing
                    End If

                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Regular_Units", "", currRow2))) Then
                        item.LikeItemRegularUnit = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Regular_Units", "", currRow2), "decimal", True, Decimal.MinValue)
                    End If
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Store_Count", "", currRow2))) Then
                        item.LikeItemStoreCount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Store_Count", "", currRow2), "decimal", True, Decimal.MinValue, 2)
                    End If
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Facings", "", currRow2))) Then
                        item.Facings = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Facings", "", currRow2), "decimal", True, Decimal.MinValue, 2)
                    End If
                    If IsNumeric(Trim(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "POG_Min_Qty", "", currRow2))) Then
                        item.POGMinQty = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "POG_Min_Qty", "", currRow2), "decimal", True, Decimal.MinValue, 0)
                    End If
                    item.LikeItemUnitStoreMonth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Like_Item_Unit_Store_Month", "", currRow2), "decimal", True, Decimal.MinValue, 2)
                    item.AnnualRegularUnitForecast = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Annual_Regular_Unit_Forecast", "", currRow2), "decimal", True, Decimal.MinValue, 2)
                    item.AnnualRegRetailSales = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Annual_Reg_Retail_Sales", "", currRow2), "decimal", True, Decimal.MinValue, 2)

                    'lp Change Order 14, now only reads those filds from Like item
                    item.POGMaxQty = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "POG_Max_Qty", "", currRow2), "string", True)
                    item.POGSetupPerStore = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws2, itemMap2, "Initial_Set_Qty_Per_Store", "", currRow2), "string", True)

                    'Get Multi-Lingual fields
                    item.PLIEnglish = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLIEnglish"), "string", True).ToString.ToUpper = "YES", "Y", "N")
                    item.PLIFrench = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLIFrench"), "string", True).ToString.ToUpper = "YES", "Y", "N")
                    item.PLISpanish = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLISpanish"), "string", True).ToString.ToUpper = "YES", "Y", "N")
                    item.CustomsDescription = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CustomsDescription"), "string", True), 255)
                    'NAK 4/17/2013:  Per client, override value to "Y"
                    item.TIEnglish = "Y"
                    'NAK 4/10/2013:  Default TI English to "Y", unless it is specified as No.
                    'Dim indicator As String = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TIEnglish"), "string", True)
                    'If indicator.ToUpper = "N" Or indicator.ToUpper = "NO" Then
                    'item.TIEnglish = "N"
                    'Else
                    'item.TIEnglish = "Y"
                    'End If

                    'NAK 4/17/2013:  PEr client, override value to "Y"
                    item.TIFrench = "Y"
                    'NAK 4/10/2012:  Default TI French to "Y", unless it is specified as No.
                    'indicator = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TIFrench"), "string", True)
                    'If indicator.ToUpper = "N" Or indicator.ToUpper = "NO" Then
                    'item.TIFrench = "N"
                    'Else
                    'item.TIFrench = "Y"
                    'End If


                    'NAK: 8/8/20120: Defaulting TI Spanish to "N" per email from Srilatha that said Spanish TI is disabled for now.
                    item.TISpanish = "N" 'DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TISpanish"), "boolean", True)

                    item.EnglishLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishLongDescription"), "string", True)
                    item.EnglishShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishShortDescription"), "string", True)

                    'Overwrite English Descriptions if PackItemIndicator is D or DP
                    If Not String.IsNullOrEmpty(item.PackItemIndicator) Then
                        Dim englishDesc As String = ""
                        If item.PackItemIndicator.StartsWith("DP") Then
                            englishDesc = "Display Pack"
                        ElseIf item.PackItemIndicator.StartsWith("SB") Then
                            englishDesc = "Sellable Bundle"
                        ElseIf item.PackItemIndicator.StartsWith("D") Then
                            englishDesc = "Displayer"
                        End If
                        If englishDesc.Length > 0 Then
                            item.EnglishLongDescription = englishDesc
                            item.EnglishShortDescription = englishDesc
                        End If
                    End If

                    'NAK - Per client requirements, Non-English Description fields will not be imported.
                    'item.FrenchLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FrenchLongDescription", ""), "string", True)
                    'item.FrenchShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FrenchShortDescription"), "string", True)
                    'item.SpanishLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SpanishLongDescription"), "string", True)
                    'item.SpanishShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SpanishShortDescription"), "string", True)

                    'NAK 11/17/2011: Per Michaels, CalculateOptions based on AnnualRegularUnit or LikeItemUnitStoreMonth for MSS Quote Sheets
                    If item.QuoteReferenceNumber <> "" Then
                        If (item.AnnualRegularUnitForecast > 0) Then
                            item.CalculateOptions = 1   'provide the Annual Regular Unit Forecast
                            Dim tempHolder As Decimal = item.AnnualRegularUnitForecast / item.StoreTotal / 13
                            item.LikeItemUnitStoreMonth = Math.Round(tempHolder * Math.Pow(10, 2)) / Math.Pow(10, 2)
                        ElseIf (item.LikeItemUnitStoreMonth > 0) Then
                            item.CalculateOptions = 2   'provide the Unit/Store/Month
                            Dim tempHolder As Decimal = item.StoreTotal * item.LikeItemUnitStoreMonth * 13
                            item.AnnualRegularUnitForecast = Math.Round(tempHolder * Math.Pow(10, 0)) / Math.Pow(10, 0)
                        Else
                            item.CalculateOptions = 0   'not set
                        End If
                    End If

                    ' CHECK FOR VALID EXISTING SKU
                    sku = item.MichaelsSKU
                    quoteRefNumber = item.QuoteReferenceNumber
                    vendorNumber = DataHelper.SmartValues(item.VendorNumber, "long", False)
                    If sku <> String.Empty AndAlso vendorNumber > 0 Then
                        If item.PackItemIndicator = "C" And batchPackIndicator = "SB" Then
                            itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(0, sku, 0)
                        Else
                            itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(vendorNumber, sku, vendorNumber)
                        End If
                        If itemMaintItem IsNot Nothing AndAlso (itemMaintItem.SKU <> String.Empty And itemMaintItem.VendorNumber > 0) Then
                            ' MERGE
                            ItemHelper.MergeItemMaintRecordIntoImportItem(item, itemMaintItem)
                            item.ValidExistingSKU = True
                            itemMaintItem = Nothing
                        Else
                            item.ValidExistingSKU = False
                        End If
                    Else
                        item.ValidExistingSKU = False
                    End If

                    ' Save this item
                    ' ---------------
                    itemID = objMichaels.SaveRecord(item, userID, True, "Uploaded", String.Empty)
                    'Save Language information
                    NLData.Michaels.ImportItemDetail.SaveImportItemLanguage(itemID, 1, item.PLIEnglish, item.TIEnglish, item.EnglishShortDescription, Left(item.EnglishLongDescription, 100), userID)
                    NLData.Michaels.ImportItemDetail.SaveImportItemLanguage(itemID, 2, item.PLIFrench, item.TIFrench, item.FrenchShortDescription, item.FrenchLongDescription, userID)
                    NLData.Michaels.ImportItemDetail.SaveImportItemLanguage(itemID, 3, item.PLISpanish, item.TISpanish, item.SpanishShortDescription, item.SpanishLongDescription, userID)

                    If itemID > 0 Then

                        'NAK 7/13/2011 Rewriting the logic for setting parent
                        '  IF this is a Regular Item, and there is not already a Parent Item for the Batch, make this item the Parent
                        '   ELSE make the first item the parent
                        If (item.PackItemIndicator = String.Empty Or item.PackItemIndicator = "R") And vendorBatches.ContainsKey(vendorNumber) Then
                            If vendorBatches(vendorNumber) Is Nothing Then
                                vendorBatches(vendorNumber) = objMichaels.GetRecord(itemID)
                                If Not quoteBatches.ContainsKey(vendorBatches(vendorNumber).Batch_ID) Then
                                    quoteBatches.Add(vendorBatches(vendorNumber).Batch_ID, IIf(quoteRefNumber.Length > 0, True, False))
                                End If
                            End If
                        Else
                            If iCount = 0 Then
                                itemparent = objMichaels.GetRecord(itemID)
                                If Not quoteBatches.ContainsKey(itemparent.Batch_ID) Then
                                    quoteBatches.Add(itemparent.Batch_ID, IIf(quoteRefNumber.Length > 0, True, False))
                                End If
                            End If
                        End If

                        ' Get the image
                        Dim ImageID As Long = 0

                        If item.ValidExistingSKU Then
                            ImageID = item.ImageID
                        Else

                            'Logger.LogInfo("starting image load")
                            'Logger.LogInfo("starting image load")
                            Dim iImage As SpreadsheetGear.Shapes.IShape = ExcelFileHelper.GetImageByMap(ws, itemMap, "Image")

                            ' Save the image
                            If Not iImage Is Nothing Then
                                'Logger.LogInfo("iImage loaded")

                                Dim imgRec As New NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord
                                Dim ssImg As New SpreadsheetGear.Drawing.Image(iImage)

                                Dim sdi As System.Drawing.Image = ssImg.GetBitmap()

                                'Logger.LogInfo("sdi loaded")

                                'Dim sdi As System.Drawing.Image = iImage.PictureFormat.GetImage()


                                If Not sdi Is Nothing Then
                                    'Logger.LogInfo("pixel format: " & sdi.PixelFormat.ToString())
                                    If sdi.PixelFormat = 8207 Then
                                        'Logger.LogInfo("cmyk image warning")
                                        'Image is a CMYK image.  This is not allowed for an image upload.  Output error.
                                        lblImageError.Text = lblImageError.Text & "<p>Warning: Worksheet tab """ & ws.Name & """ contains a CMYK formatted image, which is not web safe and was not uploaded.  Please use an RGB formatted image.</p>"
                                    Else
                                        'Logger.LogInfo("trying to save")
                                        'Only save the image if GetImage returned one
                                        If sdi IsNot Nothing Then
                                            'Logger.LogInfo("file name: " & iImage.Name)
                                            'Logger.LogInfo("width: " & sdi.Width.ToString())
                                            'Logger.LogInfo("height: " & sdi.Height.ToString())
                                            imgRec.File_Name = iImage.Name
                                            imgRec.File_Data = ExcelFileHelper.imageToByteArray(sdi)
                                            imgRec.File_Size = imgRec.File_Data.Length
                                            'Logger.LogInfo("size: " & imgRec.File_Data.Length.ToString())
                                            imgRec.Image_Width_Pixels = sdi.Width
                                            imgRec.Image_Height_Pixels = sdi.Height

                                            Dim objMichaelsFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFile()
                                            'Logger.LogInfo("calling save")
                                            ImageID = objMichaelsFile.SaveRecord(imgRec, userID)
                                            'Logger.LogInfo("done with save")
                                            objMichaelsFile = Nothing

                                            sdi.Dispose()
                                        End If
                                    End If

                                    sdi = Nothing
                                Else
                                    'Logger.LogInfo("invalid image warning")

                                    lblImageError.Text = lblImageError.Text & "<p>Warning: Worksheet tab """ & ws.Name & """ contains an invalid image. The image maybe corrupt or un-readable and was not uploaded. Please supply a different image.</p>"
                                End If

                            End If
                        End If


                        ' Save XRef to this image
                        If ImageID > 0 Then
                            objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_IMPORT, itemID, ImageID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image, userID, False)

                            ' audit
                            Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                            Dim audit As New Models.AuditRecord()
                            audit.SetupAudit(Models.MetadataTable.Items_Files, itemID, Models.AuditRecordType.Insert, userID)
                            audit.AddAuditField("File_ID", ImageID)
                            objFA.SaveAuditRecord(audit)
                            objFA = Nothing
                            audit = Nothing

                        End If

                        ' Save XRef to MSDS sheet for existing SKU (if exists)...
                        If item.ValidExistingSKU AndAlso item.MSDSID > 0 Then
                            objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_IMPORT, itemID, item.MSDSID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS, userID)

                            ' audit
                            Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                            Dim audit As New Models.AuditRecord()
                            audit.SetupAudit(Models.MetadataTable.Items_Files, itemID, Models.AuditRecordType.Insert, userID)
                            audit.AddAuditField("File_ID", item.MSDSID)
                            objFA.SaveAuditRecord(audit)
                            objFA = Nothing
                            audit = Nothing
                        End If

                    Else
                        Throw New Exception("Save failed.")
                    End If
                    'lp
                    currRow2 += 1
                    'lp
                    iCount += 1
                    'wsName = WebConstants.IMPORT_ITEM_CHILD_WORKSHEET
                    'ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName.Replace("#", iCount))

                    Dim bFound As Boolean = False

                    For itemp As Integer = ws.Index + 1 To wb.Worksheets.Count - 1
                        wsName = wb.Worksheets.Item(itemp).Name
                        If ExcelFileHelper.IsValidTabName(wsName) Then
                            ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName)
                            bFound = True
                            Exit For
                        End If
                    Next

                    If Not bFound Then
                        ws = Nothing
                    End If

                Loop

                'NAK 4/4/2011: Move Batch to CAA/CMA Workflow Step as a System Activity, if this batch contains an item with a QuoteReference 
                For Each kp As System.Collections.Generic.KeyValuePair(Of Integer, Boolean) In quoteBatches
                    If (kp.Value) Then
                        ProcessApprovalTransaction(kp.Key, 2, userID, "Approve", "")
                    End If
                Next

                'NAK 6/17/2013: Update MSS_Batch flag if batch contains a Quote Reference Number
                For Each kp As System.Collections.Generic.KeyValuePair(Of Integer, Boolean) In quoteBatches
                    If (kp.Value) Then
                        NovaLibra.Coral.Data.Michaels.BatchData.UpdateMSSBatch(kp.Key, True)
                    End If
                Next

            End If ' If validBatch Then

        Catch ex As Exception
            Throw ex
        Finally
            objMichaels = Nothing
            objMichaelsIFile = Nothing
        End Try

        ' ERROR: item  not saved.
        If itemID <= 0 Then
            fileImportPanel.Visible = False
            fileImportError.Visible = True
        Else
            fileImportPanel.Visible = False
            fileImportSuccess.Visible = True
        End If

        objMichaelsVendor = Nothing
        vendor = Nothing

        itemMap = Nothing
        lvgs = Nothing

        Return True

    End Function

    Function IsValidListValue(ByRef lvgs As ListValueGroups, ByVal groupName As String, ByVal value As String, ByVal blankIsValid As Boolean) As Boolean
        Dim isValid As Boolean = False
        If value = String.Empty AndAlso blankIsValid Then
            isValid = True
        Else
            If Not lvgs Is Nothing Then
                Dim lvg As ListValueGroup = lvgs.GetListValueGroup(groupName)
                If Not lvg Is Nothing Then
                    isValid = lvg.ListValueExists(value)
                End If
            End If
        End If
        Return isValid
    End Function

    Protected Function FormatUPCValue(ByVal value As String) As String
        If value.Trim() <> String.Empty AndAlso IsNumeric(value.Trim()) Then
            Return value.Trim().PadLeft(14, "0")
        Else
            Return value
        End If
    End Function

    Private Sub ProcessApprovalTransaction(ByVal intBatchId As Long, ByVal nextStageId As Integer, ByVal intUserId As Integer, ByVal ApprType As String, Optional ByVal strNotes As String = "")
        Dim iret As Integer
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "sp_SPD2_Approve_Batch"
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "WorkflowStageId"
            param.DbType = DbType.Int32
            param.Value = nextStageId
            Command.Parameters.Add(param)
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchId"
            param.DbType = DbType.Int32
            param.Value = intBatchId
            Command.Parameters.Add(param)
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "UserId"
            param.DbType = DbType.Int32
            param.Value = intUserId
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "ApprType"
            param.DbType = DbType.String
            param.Value = ApprType
            Command.Parameters.Add(param)

            If strNotes <> String.Empty Then
                param = Nothing
                param = Command.CreateParameter()
                param.Direction = ParameterDirection.Input
                param.ParameterName = "Notes"
                param.DbType = DbType.String
                param.Value = strNotes
                Command.Parameters.Add(param)
            End If

            Command.Connection.Open()
            iret = Command.ExecuteScalar
            Command.Connection.Close()
        Catch ex As Exception
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
            Throw ex
        Finally
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
        End Try
    End Sub

End Class

