Imports System
Imports System.Configuration
Imports System.Data
Imports System.IO
Imports Microsoft.VisualBasic

'Imports C1.C1Excel
'Imports SoftArtisans.OfficeWriter.ExcelWriter

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports System.Collections.Generic

Partial Class detailexport
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Logger.LogInfo("Domestic Export: Page Load")

        Page.EnableViewState = False
        Dim itemHeaderID As Long
        Dim xmlSortCriteria As String = String.Empty 'lp we need to sort by same paramterers as grid on the domestic detailitems screen
        If Not Request("sort") Is Nothing AndAlso Request("sort") <> String.Empty Then
            xmlSortCriteria = Server.UrlDecode(Request("sort"))
        End If
        If Not Request("guid") Is Nothing AndAlso Request("guid") <> String.Empty Then
            Dim g As String = Request("guid")
            Dim SQLStr As String = String.Format("select [ID] from [dbo].[SPD_Item_Headers] where Batch_ID = (select ID from [dbo].[SPD_Batch] where GUID = '{0}')", g)
            Dim reader As NLData.DBReader = Nothing
            Try
                reader = NLData.DataUtilities.GetDBReader(SQLStr)
                If reader.Read() Then
                    itemHeaderID = reader("ID")
                End If
                reader.Command.Connection.Dispose()
                reader.Dispose()
                reader = Nothing
            Catch ex As Exception
                Throw ex
            Finally
                If reader IsNot Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
            End Try

        Else
            ' quick security check
            If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
                Response.Redirect("closeform.aspx")
            End If

            itemHeaderID = DataHelper.SmartValues(Request("hid"), "long", False)
        End If

        Logger.LogInfo("Domestic Export: Item Header ID " & itemHeaderID)

        ' check hid
        If itemHeaderID <= 0 Then
            Response.Redirect("closeform.aspx")
        End If

        'Me.Page.Title = ConfigurationManager.AppSettings("ApplicationName")
        Dim dateNow As Date = Now()
        Dim batchID As Long = 0
        Dim fileName As String = String.Empty

        Dim StockingStrats As New List(Of NovaLibra.Coral.SystemFrameworks.Michaels.StockingStrategyRecord)
        Dim oSS As New NovaLibra.Coral.Data.Michaels.StockingStrategy
        StockingStrats = oSS.GetStockingStrategies()

        Dim exportFile As String = System.Configuration.ConfigurationManager.AppSettings("DOMESTIC_ITEM_FORM")
        exportFile = exportFile.Replace(WebConstants.APP_PATH_REPLACE, (Server.MapPath("")))

        Logger.LogInfo("Domestic Export: Retrieved Export File From " & exportFile)

        ' init
        Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord
        Dim item As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord
        Dim itemRows As Integer = 0, currRow As Integer, currRow2 As Integer, i As Integer
        'Dim itemID As Long
        Dim userID As Integer = DataHelper.SmartValues(Session("UserID"), "integer")
        Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping
        Dim itemMap2 As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping
        Dim wb As SpreadsheetGear.IWorkbook
        Dim ws As SpreadsheetGear.IWorksheet
        Dim ws2 As SpreadsheetGear.IWorksheet
        Dim x As Integer
        Dim shape As SpreadsheetGear.Shapes.IShape
        Dim control As SpreadsheetGear.Shapes.IControlFormat

        ' save the imported file
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        itemHeader = objMichaels.GetItemHeaderRecord(itemHeaderID)

        If (Not itemHeader Is Nothing) AndAlso itemHeader.ID > 0 Then
            batchID = itemHeader.BatchID
            Try
                wb = SpreadsheetGear.Factory.GetWorkbook(exportFile)

                If ExcelFileHelper.IsValidComponent(wb) Then

                    ws = wb.Worksheets(WebConstants.DOMESTIC_ITEM_IMPORT_WORKSHEET)
                    ws2 = wb.Worksheets(WebConstants.LIKE_ITEM_TAB_WORKSHEET)

                    ' write the header
                    Dim mapVer As String = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, "D", 1), "string", False)

                    Logger.LogInfo("Domestic Export: MapVer " & mapVer)

                    Dim objMichaels2 As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping()
                    itemMap = objMichaels2.GetMapping("DOMITEMHEADER", mapVer)
                    itemMap2 = objMichaels2.GetMapping("LIKEITEMAPPROVAL", "CURRENT") 'objMichaels2.GetMapping("NEWITEMAPPROVAL", "CURRENT")

                    objMichaels2 = Nothing

                    If itemHeader.LogID <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Log_ID", itemHeader.LogID)
                    If itemHeader.SubmittedBy <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Submitted_By", itemHeader.SubmittedBy)
                    If itemHeader.DateSubmitted <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Date_Submitted", itemHeader.DateSubmitted)
                    If itemHeader.DepartmentNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Department_Num", itemHeader.DepartmentNum)
                    If itemHeader.USVendorNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "US_Vendor_Num", itemHeader.USVendorNum)
                    If itemHeader.USVendorName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "US_Vendor_Name", itemHeader.USVendorName)
                    If itemHeader.CanadianVendorNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Canadian_Vendor_Num", itemHeader.CanadianVendorNum)
                    If itemHeader.CanadianVendorName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Canadian_Vendor_Name", itemHeader.CanadianVendorName)

                    If itemHeader.SupplyChainAnalyst <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Supply_Chain_Analyst", itemHeader.SupplyChainAnalyst)
                    If itemHeader.MgrSupplyChain <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Mgr_Supply_Chain", itemHeader.MgrSupplyChain)
                    If itemHeader.DirSCVR <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Dir_SCVR", itemHeader.DirSCVR)

                    If itemHeader.RebuyYN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Rebuy_YN", itemHeader.RebuyYN)
                    If itemHeader.ReplenishYN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Replenish_YN", itemHeader.ReplenishYN)
                    If itemHeader.StoreOrderYN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Store_Order_YN", itemHeader.StoreOrderYN)

                    If itemHeader.DateInRetek <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Date_In_Retek", itemHeader.DateInRetek)
                    If itemHeader.EnterRetek <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Enter_Retek", itemHeader.EnterRetek)
                    If itemHeader.BuyerApproval <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Buyer_Approval", itemHeader.BuyerApproval)

                    If itemHeader.StockCategory <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Stock_Category", itemHeader.StockCategory)
                    If itemHeader.CanadaStockCategory <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Canada_Stock_Category", itemHeader.CanadaStockCategory)
                    If itemHeader.ItemType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Item_Type", itemHeader.ItemType)
                    If itemHeader.ItemTypeAttribute <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Item_Type_Attribute", itemHeader.ItemTypeAttribute)
                    If itemHeader.AllowStoreOrder <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Allow_Store_Order", itemHeader.AllowStoreOrder)
                    If itemHeader.InventoryControl <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Inventory_Control", itemHeader.InventoryControl)
                    If itemHeader.FreightTerms <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Freight_Terms", itemHeader.FreightTerms)
                    If itemHeader.AutoReplenish <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Auto_Replenish", itemHeader.AutoReplenish)
                    If itemHeader.SKUGroup <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SKU_Group", itemHeader.SKUGroup)
                    If itemHeader.StoreSupplierZoneGroup <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Store_Supplier_Zone_Group", itemHeader.StoreSupplierZoneGroup)
                    If itemHeader.WHSSupplierZoneGroup <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "WHS_Supplier_Zone_Group", itemHeader.WHSSupplierZoneGroup)
                    If itemHeader.AddUnitCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Add_Unit_Cost", itemHeader.AddUnitCost)
                    If itemHeader.Comments <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Comments", itemHeader.Comments)
                    If itemHeader.WorksheetDesc <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Worksheet_Desc", itemHeader.WorksheetDesc)

                    ' >> New Item Approval
                    If Not ws2 Is Nothing Then
                        'lp
                        If itemHeader.USVendorNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Vendor_Num", itemHeader.USVendorNum)
                        If itemHeader.USVendorName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Vendor_Name", itemHeader.USVendorName)

                        'LP only parent has it and i cannot safe it in AK3 field. :-(
                        ' (DUH... protected/hidden field)
                        'If itemHeader.CalculateOptions <> Integer.MinValue AndAlso CInt(itemHeader.CalculateOptions) > 0 Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Calculate_Options", CInt(itemHeader.CalculateOptions)) ', 4 'AK3
                        If itemHeader.CalculateOptions > 0 Then
                            For x = 0 To ws2.Shapes.Count - 1
                                shape = ws2.Shapes.Item(x)
                                If shape.ControlFormat IsNot Nothing Then
                                    control = shape.ControlFormat
                                    If shape.Name = "calculate_options" Or control.LinkedCell = "$AK$4" Then
                                        If itemHeader.CalculateOptions = 1 Then
                                            control.ListIndex = 1
                                        ElseIf itemHeader.CalculateOptions = 2 Then
                                            control.ListIndex = 2
                                        End If
                                    End If
                                End If
                            Next
                        End If

                        If itemHeader.BatchID <> Long.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Log_ID", itemHeader.BatchID)
                        If itemHeader.StoreTotal <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Store_Total", itemHeader.StoreTotal)
                        If itemHeader.POGStartDate <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Start_Date", itemHeader.POGStartDate)
                        If itemHeader.POGCompDate <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Comp_Date", itemHeader.POGCompDate)
                    End If

                    ' read/save the line items

                    Dim items As NovaLibra.Coral.SystemFrameworks.Michaels.ItemList

                    Logger.LogInfo("Domestic Export: Domestic Header Written.  Begin Domestic Item")

                    If xmlSortCriteria = String.Empty Then
                        Dim isPack As Boolean = NovaLibra.Coral.Data.Michaels.ItemDetail.IsPack(itemHeader.ID)
                        If isPack = False Then
                            xmlSortCriteria = "<?xml version=""1.0"" encoding=""utf-8"" ?><Root><Sort><Parameter SortID=""1"" intColOrdinal=""1"" intDirection=""0"" /></Sort></Root>"
                        Else
                            Dim sb As New StringBuilder
                            sb.Append("<?xml version=""1.0"" encoding=""utf-8"" ?><Root>")
                            sb.Append("<Sort>")
                            sb.Append("<Parameter SortID=""1"" intColOrdinal=""5"" intDirection=""1"" />")
                            sb.Append("<Parameter SortID=""2"" intColOrdinal=""1"" intDirection=""0"" />")
                            sb.Append("</Sort>")
                            sb.Append("</Root>")
                            xmlSortCriteria = sb.ToString()
                        End If
                    End If
                    items = objMichaels.GetList(itemHeaderID, 0, 0, xmlSortCriteria, userID)
                    itemMap = Nothing
                    Dim objMichaels3 As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping()
                    itemMap = objMichaels3.GetMapping("DOMITEM", mapVer)
                    objMichaels3 = Nothing
                    'Do While ExcelFileHelper.IsValidItemRow(ws, itemRows + 1)
                    For i = 0 To items.RecordCount - 1
                        currRow = WebConstants.DOMESTIC_ITEM_START_ROW + i
                        currRow2 = WebConstants.NEW_ITEM_TAB_START_ROW + i
                        item = items.ListRecords.Item(i)
                        ' LP I NEED A WHOLE ITEM HERE, NOT WHAT JUST IN THE LIST
                        'item = objMichaels.GetRecord(item.ID) ' << KH I have no idea what Leon was raving about here
                        'item.ItemHeaderID = itemHeaderID
                        If item.AddChange <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Add_Change", item.AddChange, currRow)
                        If item.PackItemIndicator <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Pack_Item_Indicator", item.PackItemIndicator, currRow)
                        If item.MichaelsSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Michaels_SKU", item.MichaelsSKU, currRow)
                        If item.VendorUPC <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Vendor_UPC", item.VendorUPC, currRow)
                        If item.ClassNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Class_Num", item.ClassNum, currRow)
                        If item.SubClassNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Sub_Class_Num", item.SubClassNum, currRow)
                        If item.VendorStyleNum <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Vendor_Style_Num", item.VendorStyleNum, currRow)
                        If item.ItemDesc <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Item_Desc", item.ItemDesc, currRow)
                        'If item.HybridType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hybrid_Type", item.HybridType, currRow)
                        'If item.HybridSourceDC <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hybrid_Source_DC", item.HybridSourceDC, currRow)
                        'If item.HybridLeadTime <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hybrid_Lead_Time", item.HybridLeadTime, currRow)
                        'If item.HybridConversionDate <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hybrid_Conversion_Date", item.HybridConversionDate, currRow)

                        'If item.VendorInnerGTIN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Vendor_Inner_GTIN", item.VendorInnerGTIN)
                        'If item.VendorCaseGTIN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Vendor_Case_GTIN", item.VendorCaseGTIN)

                        'If item.StockingStrategyCode <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Stocking_Strategy_Code", item.StockingStrategyCode, currRow)
                        If item.StockingStrategyCode <> String.Empty Then
                            For Each ss As NovaLibra.Coral.SystemFrameworks.Michaels.StockingStrategyRecord In StockingStrats
                                If ss.StrategyCode = item.StockingStrategyCode Then
                                    ExcelFileHelper.SetCellByMap(ws, itemMap, "Stocking_Strategy_Code", item.StockingStrategyCode & " - " & ss.StrategyDesc, currRow)
                                    Exit For
                                End If
                            Next

                        End If

                        If item.QtyInPack <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Qty_In_Pack", item.QtyInPack, currRow)
                        If item.EachesMasterCase <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Eaches_Master_Case", item.EachesMasterCase, currRow)
                        If item.EachesInnerPack <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Eaches_Inner_Pack", item.EachesInnerPack, currRow)
                        If item.PrePriced <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Pre_Priced", item.PrePriced, currRow)
                        If item.PrePricedUDA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Pre_Priced_UDA", item.PrePricedUDA, currRow)
                        If item.USCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "US_Cost", item.USCost, currRow)
                        If item.TotalUSCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Total_US_Cost", item.TotalUSCost, currRow)
                        If item.CanadaCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Canada_Cost", item.CanadaCost, currRow)
                        If item.TotalCanadaCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Total_Canada_Cost", item.TotalCanadaCost, currRow)

                        If item.BaseRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Base_Retail", item.BaseRetail, currRow)
                        If item.CentralRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Central_Retail", item.CentralRetail, currRow)
                        If item.TestRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Test_Retail", item.TestRetail, currRow)
                        If item.AlaskaRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Alaska_Retail", item.AlaskaRetail, currRow)
                        If item.CanadaRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Canada_Retail", item.CanadaRetail, currRow)
                        If item.ZeroNineRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Zero_Nine_Retail", item.ZeroNineRetail, currRow)
                        If item.CaliforniaRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "California_Retail", item.CaliforniaRetail, currRow)
                        If item.VillageCraftRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Village_Craft_Retail", item.VillageCraftRetail, currRow)

                        'change order 14 LP Sept 2009
                        If item.Retail9 <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail9", item.Retail9, currRow)
                        If item.Retail10 <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail10", item.Retail10, currRow)
                        If item.Retail11 <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail11", item.Retail11, currRow)
                        If item.Retail12 <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail12", item.Retail12, currRow)
                        If item.Retail13 <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail13", item.Retail13, currRow)
                        If item.RDQuebec <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDQuebec", DataHelper.SmartValues(item.RDQuebec, "decimal", True, String.Empty, 4), currRow)
                        If item.RDPuertoRico <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDPuertoRico", DataHelper.SmartValues(item.RDPuertoRico, "decimal", True, String.Empty, 4), currRow)

                        'Those fileds to be populated only from Like Item, LP Sept 2009
                        'If item.POGSetupPerStore <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "POG_Setup_Per_Store", item.POGSetupPerStore, currRow)
                        'If item.POGMaxQty <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "POG_Max_Qty", item.POGMaxQty, currRow)
                        'If item.ProjectedUnitSales <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Projected_Unit_Sales", item.ProjectedUnitSales, currRow)

                        If item.EachCaseHeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Each_Case_Height", item.EachCaseHeight, currRow)
                        If item.EachCaseWidth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Each_Case_Width", item.EachCaseWidth, currRow)
                        If item.EachCaseLength <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Each_Case_Length", item.EachCaseLength, currRow)
                        If item.EachCaseWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Each_Case_Weight", item.EachCaseWeight, currRow)
                        If item.EachCasePackCube <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Each_Case_Pack_Cube", item.EachCasePackCube, currRow)

                        If item.InnerCaseHeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Inner_Case_Height", item.InnerCaseHeight, currRow)
                        If item.InnerCaseWidth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Inner_Case_Width", item.InnerCaseWidth, currRow)
                        If item.InnerCaseLength <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Inner_Case_Length", item.InnerCaseLength, currRow)
                        If item.InnerCaseWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Inner_Case_Weight", item.InnerCaseWeight, currRow)
                        If item.InnerCasePackCube <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Inner_Case_Pack_Cube", item.InnerCasePackCube, currRow)

                        If item.MasterCaseHeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Master_Case_Height", item.MasterCaseHeight, currRow)
                        If item.MasterCaseWidth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Master_Case_Width", item.MasterCaseWidth, currRow)
                        If item.MasterCaseLength <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Master_Case_Length", item.MasterCaseLength, currRow)
                        If item.MasterCaseWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Master_Case_Weight", item.MasterCaseWeight, currRow)
                        If item.MasterCasePackCube <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Master_Case_Pack_Cube", item.MasterCasePackCube, currRow)

                        If item.CountryOfOriginName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Country_Of_Origin", item.CountryOfOriginName, currRow)
                        If item.TaxUDA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Tax_UDA", item.TaxUDA, currRow)
                        If item.TaxValueUDA <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Tax_Value_UDA", item.TaxValueUDA, currRow)
                        If item.Hazardous <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous", item.Hazardous, currRow)
                        If item.HazardousFlammable <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Flammable", item.HazardousFlammable, currRow)
                        If item.HazardousContainerType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Container_Type", item.HazardousContainerType, currRow)
                        If item.HazardousContainerSize <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Container_Size", item.HazardousContainerSize, currRow)
                        If item.HazardousMSDSUOM <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_MSDS_UOM", item.HazardousMSDSUOM, currRow)
                        If item.HazardousManufacturerName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Manufacturer_Name", item.HazardousManufacturerName, currRow)
                        If item.HazardousManufacturerCity <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Manufacturer_City", item.HazardousManufacturerCity, currRow)
                        If item.HazardousManufacturerState <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Manufacturer_State", item.HazardousManufacturerState, currRow)
                        If item.HazardousManufacturerPhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Manufacturer_Phone", item.HazardousManufacturerPhone, currRow)
                        If item.HazardousManufacturerCountry <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Hazardous_Manufacturer_Country", item.HazardousManufacturerCountry, currRow)

                        Dim RSCYesNo As String = item.PhytoSanitaryCertificate
                        If RSCYesNo = "Y" Then
                            RSCYesNo = "YES"
                        ElseIf RSCYesNo = "N" Then
                            RSCYesNo = "NO"
                        End If

                        Dim PTSYesNo As String = item.PhytoTemporaryShipment
                        If PTSYesNo = "Y" Then
                            PTSYesNo = "YES"
                        ElseIf PTSYesNo = "N" Then
                            PTSYesNo = "NO"
                        End If

                        If RSCYesNo <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PhytoSanitaryCertificate", RSCYesNo, currRow)
                        If PTSYesNo <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PhytoTemporaryShipment", PTSYesNo, currRow)


                        'Get language settings from SPD_Import_Item_Languages
                        Dim languageDT As DataTable = NLData.Michaels.ItemDetail.GetItemLanguages(item.ID)
                        If languageDT.Rows.Count > 0 Then
                            'For Each language row, set the front end controls
                            For Each language As DataRow In languageDT.Rows
                                Dim languageTypeID As Integer = DataHelper.SmartValues(language("Language_Type_ID"), "CInt", False)
                                Dim pli As String = DataHelper.SmartValues(language("Package_Language_Indicator"), "CStr", False)
                                Dim ti As String = DataHelper.SmartValues(language("Translation_Indicator"), "CStr", False)
                                Dim descShort As String = DataHelper.SmartValues(language("Description_Short"), "CStr", False)
                                Dim descLong As String = DataHelper.SmartValues(language("Description_Long"), "CStr", False)
                                Dim exemptEndDateFrench As String = DataHelper.SmartValues(language("Exempt_End_Date"), "Cstr", False)
                                Select Case languageTypeID
                                    Case 1
                                        item.PLIEnglish = pli
                                        item.TIEnglish = ti
                                        item.EnglishShortDescription = descShort
                                        item.EnglishLongDescription = descLong
                                    Case 2
                                        item.PLIFrench = pli
                                        item.TIFrench = ti
                                        item.FrenchShortDescription = descShort
                                        item.FrenchLongDescription = descLong
                                        item.ExemptEndDateFrench = exemptEndDateFrench
                                    Case 3
                                        item.PLISpanish = pli
                                        item.TISpanish = ti
                                        item.SpanishShortDescription = descShort
                                        item.SpanishLongDescription = descLong
                                End Select
                            Next
                        End If

                        'Set Private Brand Label 
                        If Not String.IsNullOrEmpty(item.PrivateBrandLabel) Then
                            Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
                            If pbllvgs IsNot Nothing Then
                                For Each lv As ListValue In pbllvgs.ListValues
                                    If lv.Value = item.PrivateBrandLabel Then
                                        ExcelFileHelper.SetCellByMap(ws, itemMap, "PrivateBrandLabel", lv.DisplayText, currRow)
                                    End If
                                Next
                            End If
                        End If

                        'Set Language info
                        ExcelFileHelper.SetCellByMap(ws, itemMap, "PLIEnglish", IIf(item.PLIEnglish = "Y", "YES", "NO"), currRow)
                        ExcelFileHelper.SetCellByMap(ws, itemMap, "PLIFrench", IIf(item.PLIFrench = "Y", "YES", "NO"), currRow)
                        ExcelFileHelper.SetCellByMap(ws, itemMap, "PLISpanish", IIf(item.PLISpanish = "Y", "YES", "NO"), currRow)
                        ExcelFileHelper.SetCellByMap(ws, itemMap, "TIEnglish", IIf(item.TIEnglish = "Y", "YES", "NO"), currRow)
                        ExcelFileHelper.SetCellByMap(ws, itemMap, "TIFrench", IIf(item.TIFrench = "Y", "YES", "NO"), currRow)
                        ExcelFileHelper.SetCellByMap(ws, itemMap, "TISpanish", IIf(item.TISpanish = "Y", "YES", "NO"), currRow)
                        If item.EnglishLongDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnglishLongDescription", item.EnglishLongDescription, currRow)
                        If item.EnglishShortDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnglishShortDescription", item.EnglishShortDescription, currRow)

                        'Set CRC info
                        If item.HarmonizedCodeNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HarmonizedCodeNumber", item.HarmonizedCodeNumber, currRow)
                        If item.CanadaHarmonizedCodeNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Canada_Harmonized_Code_Number", item.CanadaHarmonizedCodeNumber, currRow)
                        If item.DetailInvoiceCustomsDesc <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc", item.DetailInvoiceCustomsDesc, currRow)
                        If item.ComponentMaterialBreakdown <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentMaterialBreakdown", item.ComponentMaterialBreakdown, currRow)

                        If Not ws2 Is Nothing Then

                            If item.MichaelsSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "New_SKU", item.MichaelsSKU, currRow2)
                            If item.ItemDesc <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Description", item.ItemDesc, currRow2)
                            If item.BaseRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "New_SKU_Retail", item.BaseRetail, currRow2) '
                            'If item.CanadaRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "New_SKU_Canada_Retail", item.CanadaRetail, currRow2)
                            If item.LikeItemSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_SKU", item.LikeItemSKU, currRow2)
                            If item.LikeItemDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Description", item.LikeItemDescription, currRow2)
                            If item.LikeItemRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Retail", item.LikeItemRetail, currRow2)


                            If itemHeader.CalculateOptions <> Integer.MinValue Then
                                Select Case CInt(itemHeader.CalculateOptions)
                                    Case 0
                                        'do nothing? -no export Annual Regular Forecast and Unit/store Month
                                    Case 1
                                        If item.AnnualRegularUnitForecast <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Annual_Regular_Unit_Forecast", item.AnnualRegularUnitForecast, currRow2)
                                    Case 2
                                        If item.LikeItemUnitStoreMonth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Unit_Store_Month", item.LikeItemUnitStoreMonth, currRow2)
                                End Select
                            End If
                            If item.LikeItemRegularUnit <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Regular_Units", item.LikeItemRegularUnit, currRow2)
                            If item.LikeItemStoreCount <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Store_Count", CDec(item.LikeItemStoreCount), currRow2)
                            'If item.LikeItemSales <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Sales", item.LikeItemSales, currRow2)
                            'If item.LikeItemUnitStoreMonth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Units_Store_Month", item.LikeItemUnitStoreMonth, currRow2)
                            'If item.AnnualRegularUnitForecast <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Yearly_Forecast", item.AnnualRegularUnitForecast, currRow2)
                            'If item.AnnualRegRetailSales <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Total_Retail", item.AnnualRegRetailSales, currRow2)
                            If item.Facings <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Facings", item.Facings, currRow2)
                            'lp fix POG_Min Quality is invalid, no field in the table yetneed POG_MAx_qty
                            If item.POGMinQty <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Min_Qty", item.POGMinQty, currRow2)
                            If item.POGMaxQty <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Max_Qty", item.POGMaxQty, currRow2)
                            If item.POGSetupPerStore <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Initial_Set_Qty_Per_Store", item.POGSetupPerStore, currRow2)
                            If item.EachesInnerPack <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Inner_Pack", item.EachesInnerPack, currRow2)
                        End If

                        itemRows += 1
                        'System.Threading.Thread.Sleep(10)
                    Next i

                    i = WebConstants.DOMESTIC_ITEM_START_ROW - 1 + itemRows
                    'ws.GetCell(i, 1).Value = "-SPEDY " + itemRows.ToString 'LP fix for a 100 rows issue Sept 2009
                    'System.Threading.Thread.SpinWait(1000)
                    'Response.ContentType = "application/vnd.ms-excel"
                    fileName = "ItemWorkBook-" & batchID.ToString() & "-" & dateNow.ToString("yyyyMMdd") & ".xls"




                    Logger.LogInfo("Domestic Export: File created.  Name - " & fileName)

                    Response.BufferOutput = True

                    Response.Clear()
                    'filecom.Save(Response.OutputStream)

                    Dim memfile As New System.IO.MemoryStream()
                    wb.SaveToStream(memfile, SpreadsheetGear.FileFormat.XLS97)

                    'filecom.Clear()
                    'filecom.Save(memfile)
                    'System.Threading.Thread.Sleep(1000)
                    'System.Threading.Thread.SpinWait(1000)
                    'memfile.WriteTimeout = "100000"
                    'Dim mybyl2 As Boolean = memfile.CanTimeout
                    memfile.WriteTo(Response.OutputStream)
                    'filecom.Save(Response.OutputStream)
                    'LP to prevent last row in excel been missin in action
                    'System.Threading.Thread.Sleep(1000)
                    'lp sept2009
                    memfile = Nothing

                    Response.ContentType = "application/vnd.ms-excel"
                    Response.AddHeader("content-disposition", ("attachment;filename=" & fileName))
                    itemHeader = Nothing
                    item = Nothing
                    wb = Nothing
                    objMichaels = Nothing

                    ' show status of upload
                    'fileImportPanel.Visible = False
                    'fileImportSuccess.Visible = True

                Else
                    ' ERROR: invalid component
                    'fileImportPanel.Visible = False
                    'fileImportError.Visible = True
                End If
            Catch ex As System.Exception
                ' TODO: handle the exception
                Logger.LogError(ex)
                Throw ex
            Finally
                itemHeader = Nothing
                item = Nothing
                wb = Nothing
                'xla = Nothing
                itemMap = Nothing
                objMichaels = Nothing
            End Try
            Response.End()
        Else
            objMichaels = Nothing
            Throw New Exception("ERROR: Batch was not found!")
        End If
    End Sub
End Class
