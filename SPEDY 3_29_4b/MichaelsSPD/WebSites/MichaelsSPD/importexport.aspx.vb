Imports System
Imports System.Configuration
Imports System.Data
Imports System.Diagnostics
Imports System.Drawing
Imports System.IO
Imports Microsoft.VisualBasic

Imports C1.C1Excel

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Generic
Imports NovaLibra.Coral.Data

Partial Class importexport
    Inherits System.Web.UI.Page

    Protected Sub Page_Disposed(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Disposed

    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init

    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.EnableViewState = False
        Dim itemID As Long = 0
        Dim isRegularBatchItem As Boolean

        If Not Request("guid") Is Nothing AndAlso Request("guid") <> String.Empty Then
            Dim g As String = Request("guid")
            Dim SQLStr As String = String.Format("select [ID] from [dbo].[SPD_Import_Items] where Batch_ID = (select ID from [dbo].[SPD_Batch] where GUID = '{0}')", g)
            Dim reader As NLData.DBReader = NLData.DataUtilities.GetDBReader(SQLStr)
            If reader.Read() Then
                itemID = reader("ID")
            End If
            reader.Command.Connection.Dispose()
            reader.Dispose()
            reader = Nothing
        Else
            ' quick security check
            If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
                Response.Redirect("closeform.aspx")
            End If

            itemID = DataHelper.SmartValues(Request("hid"), "long", False)
        End If

        ' check hid
        If itemID <= 0 Then
            Response.Redirect("closeform.aspx")
        End If

        'Me.Page.Title = ConfigurationManager.AppSettings("ApplicationName")
        Dim dateNow As Date = Now()
        Dim batchID As Long = 0
        Dim fileName As String = String.Empty

        Dim StockingStrats As New List(Of NovaLibra.Coral.SystemFrameworks.Michaels.StockingStrategyRecord)
        Dim oSS As New NovaLibra.Coral.Data.Michaels.StockingStrategy
        StockingStrats = oSS.GetStockingStrategies()


        ' init
        Dim item As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
        'Dim itemID As Long
        Dim userID As Integer = DataHelper.SmartValues(Session("UserID"), "integer")
        Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = Nothing
        Dim itemMap2 As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = Nothing
        Dim wb As SpreadsheetGear.IWorkbook
        Dim ws As SpreadsheetGear.IWorksheet
        Dim ws2 As SpreadsheetGear.IWorksheet
        Dim wsSave As SpreadsheetGear.IWorksheet = Nothing
        Dim currRow2 As Integer
        Dim x As Integer
        Dim shape As SpreadsheetGear.Shapes.IShape
        Dim control As SpreadsheetGear.Shapes.IControlFormat
        Dim importPassword As String = ConfigurationManager.AppSettings("SPREADSHEET_IMPORT_PASSWORD")
        Dim mssPassword As String = System.Configuration.ConfigurationManager.AppSettings("MSS_QUOTESHEET_PASSWORD")

        ' save the imported file
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
        Dim objMichaelsFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFile
        Dim objMichaelsIFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()
        Dim objMichaelsMap As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping()

        Dim childList As ArrayList = Nothing
        Dim objChild As Models.ImportItemChildRecord = Nothing
        Dim pid As Long
        Dim wsCount As Integer = 1
        Dim wsName, ws2Name As String
        Dim isMSS As Boolean = False

        Try
            'LP
            'filecom.KeepFormulas = True

            'lp    
            item = objMichaels.GetRecord(itemID)

            If (Not item Is Nothing) AndAlso item.ID > 0 Then
                If (item.ParentID <= 0) Then
                    ' parent item
                    pid = item.ID
                Else
                    ' item is a child item => get the parent
                    pid = item.ParentID
                    itemID = pid
                    item = objMichaels.GetRecord(itemID)
                End If
                childList = objMichaels.GetChildItems(pid, False)
            End If

            'Set the ExportFile to use the regular or MSS specific template
            Dim exportFile As String
            If String.IsNullOrEmpty(item.QuoteReferenceNumber) Then
                exportFile = System.Configuration.ConfigurationManager.AppSettings("IMPORT_ITEM_FORM_2")
                exportFile = exportFile.Replace(WebConstants.APP_PATH_REPLACE, (Server.MapPath("")))
            Else
                isMSS = True
                exportFile = System.Configuration.ConfigurationManager.AppSettings("IMPORT_ITEM_MSS_FORM_2")
                exportFile = exportFile.Replace(WebConstants.APP_PATH_REPLACE, (Server.MapPath("")))
            End If

            If childList.Count > 0 Then
                wsCount += childList.Count
            End If


            If (Not item Is Nothing) AndAlso item.ID > 0 Then
                batchID = item.Batch_ID
                isRegularBatchItem = item.RegularBatchItem
                Try
                    'filecom.Load(exportFile)
                    wb = SpreadsheetGear.Factory.GetWorkbook(exportFile)


                    If Not wb Is Nothing AndAlso ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.Import) Then
                        ws2Name = WebConstants.LIKE_ITEM_TAB_WORKSHEET
                        ws2 = wb.Worksheets(WebConstants.LIKE_ITEM_TAB_WORKSHEET)
                        itemMap2 = objMichaelsMap.GetMapping("LIKEITEMAPPROVAL", "CURRENT") 'objMichaelsMap.GetMapping("NEWITEMAPPROVAL", "CURRENT")

                        Dim i As Integer
                        Dim maxNewItem As Integer = AppHelper.GetImportItemMaxNewItem()

                        For i = 0 To wsCount - 1

                            currRow2 = WebConstants.NEW_ITEM_TAB_START_ROW + i

                            If i = 0 Then
                                ws = wb.Worksheets(WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET)

                                If Not isMSS Then
                                    ws.Unprotect(importPassword)
                                End If

                                If wsCount > 1 AndAlso i < wsCount - 1 Then
                                    wsSave = CType(ws.CopyAfter(ws), SpreadsheetGear.IWorksheet)
                                End If

                                Dim mapVer As String = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, "B", 3), "string", False)
                                itemMap = objMichaelsMap.GetMapping("IMPORTITEM", mapVer)
                                If itemMap Is Nothing OrElse itemMap.ID = 0 Then
                                    'if the version number ends in 0 the mapVer will not have the trailing zero so we much try to find it by that
                                    mapVer = mapVer + "0"
                                    itemMap = objMichaelsMap.GetMapping("IMPORTITEM", mapVer)
                                End If
                            Else
                                wsName = WebConstants.IMPORT_ITEM_CHILD_WORKSHEET
                                wsName = wsName.Replace("#", i.ToString())

                                'If i < maxNewItem Then
                                '    ws = wb.Worksheets(wsName)
                                'Else
                                '    ws = wsSave.Clone()
                                '    ws = wb.Worksheets.Item(0).cl
                                '    ws.Name = wsName
                                'End If
                                ws = wsSave

                                If Not isMSS Then
                                    ws.Unprotect(importPassword)
                                End If

                                ws.Name = wsName
                                If wsCount > 1 AndAlso i < wsCount - 1 Then
                                    wsSave = CType(ws.CopyAfter(ws), SpreadsheetGear.IWorksheet)
                                End If

                                If isRegularBatchItem Then
                                    wsName = WebConstants.IMPORT_ITEM_REGULAR_WORKSHEET
                                    ws.Name = wsName.Replace("#", i + 1)
                                End If
                                item = objMichaels.GetRecord(CType(childList(i - 1), Models.ImportItemChildRecord).ID)
                            End If

                            If item Is Nothing Then
                                Debug.Assert(False)
                                Exit For
                            End If

                            'Unprotect the worksheet (for writing)
                            'ws.ProtectContents = False
                            'ws.Cells.Locked = False


                            ' Write values to excel
                            If item.DateSubmitted <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DateSubmitted", item.DateSubmitted)
                            'Do not populate Vendor field. There is logic in spreadsheet to populate based on whether agent is populated. If we overlay, we mess that up.
                            'ExcelFileHelper.SetCellByMap(ws, itemMap, "Vendor", item.Vendor)
                            ExcelFileHelper.SetCellByMap(ws, itemMap, "Agent", item.Agent)
                            If item.Buyer <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Buyer", item.Buyer)
                            If item.Fax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Fax", item.Fax)
                            If item.EnteredBy <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnteredBy", item.EnteredBy)
                            If item.SKUGroup <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SKUGroup", item.SKUGroup)
                            If item.Email <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Email", item.Email)
                            If item.EnteredDate <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnteredDate", item.EnteredDate)
                            If item.Dept <> String.Empty AndAlso IsNumeric(item.Dept) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Dept", item.Dept)
                            If item.Class <> String.Empty AndAlso IsNumeric(item.Class) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Class", item.Class)
                            If item.SubClass <> String.Empty AndAlso IsNumeric(item.SubClass) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SubClass", item.SubClass)
                            If item.PrimaryUPC <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PrimaryUPC", item.PrimaryUPC)
                            If item.MichaelsSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MichaelsSKU", item.MichaelsSKU)

                            ' GenerateMichaelsUPC
                            If item.GenerateMichaelsUPC <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "GenerateMichaelsUPC", item.GenerateMichaelsUPC)

                            'TODO FIX THIS FOR EXPORT
                            Dim tempUPC As String, strTemp As String, j As Integer
                            Dim maxExport As Integer = 8 ' Export upto 8 UPCs
                            Dim addUPCCount As Integer = item.AdditionalUPCRecord.AdditionalUPCs.Count

                            addUPCCount = IIf(addUPCCount > maxExport, maxExport, addUPCCount)
                            For j = 0 To addUPCCount - 1
                                tempUPC = item.AdditionalUPCRecord.AdditionalUPCs.Item(j).ToString
                                strTemp = "AdditionalUPC" & CStr(j + 1)
                                ExcelFileHelper.SetCellByMap(ws, itemMap, strTemp, tempUPC)
                            Next

                            'If item.InnerGTIN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "InnerGTIN", item.InnerGTIN)
                            'If item.CaseGTIN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CaseGTIN", item.CaseGTIN)
                            'If item.GenerateMichaelsGTIN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "GenerateMichaelsGTIN", item.GenerateMichaelsGTIN)

                            'If item.IsPackParent Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PackSKU", item.MichaelsSKU)
                            If item.PackSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PackSKU", item.PackSKU)
                            If item.PlanogramName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PlanogramName", item.PlanogramName)

                            ' vendor number and name
                            If item.VendorNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorNumber", item.VendorNumber)
                            If item.VendorName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorName", item.VendorName)

                            If item.VendorRank <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorRank", item.VendorRank)
                            If item.ItemTask <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ItemTask", item.ItemTask)
                            If item.Description <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Description", item.Description)
                            If item.QuoteSheetStatus <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "QuoteSheetStatus", item.QuoteSheetStatus)
                            If item.Season <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Season", item.Season)

                            If item.PaymentTerms <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PaymentTerms", item.PaymentTerms)
                            If item.Days <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Days", item.Days)
                            'If item.VendorMinOrderAmount <> String.Empty AndAlso IsNumeric(item.VendorMinOrderAmount) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorMinOrderAmount", DataHelper.SmartValues(item.VendorMinOrderAmount, "decimal", True, String.Empty, 4))

                            If item.VendorAddress1 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress1", item.VendorAddress1)
                            If item.VendorAddress2 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress2", item.VendorAddress2)
                            If item.VendorAddress3 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress3", item.VendorAddress3)
                            If item.VendorAddress4 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress4", item.VendorAddress4)
                            If item.VendorContactName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactName", item.VendorContactName)
                            If item.VendorContactPhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactPhone", item.VendorContactPhone)
                            If item.VendorContactEmail <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactEmail", item.VendorContactEmail)
                            If item.VendorContactFax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactFax", item.VendorContactFax)
                            If item.ManufactureName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureName", item.ManufactureName)
                            If item.ManufactureAddress1 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureAddress1", item.ManufactureAddress1)
                            If item.ManufactureAddress2 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureAddress2", item.ManufactureAddress2)
                            If item.ManufactureContact <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureContact", item.ManufactureContact)
                            If item.ManufacturePhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufacturePhone", item.ManufacturePhone)
                            If item.ManufactureEmail <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureEmail", item.ManufactureEmail)
                            If item.ManufactureFax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureFax", item.ManufactureFax)
                            If item.AgentContact <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentContact", item.AgentContact)
                            If item.AgentPhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentPhone", item.AgentPhone)
                            If item.AgentEmail <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentEmail", item.AgentEmail)
                            If item.AgentFax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentFax", item.AgentFax)
                            If item.VendorStyleNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorStyleNumber", item.VendorStyleNumber)
                            If item.CanadaHarmonizedCodeNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CanadaHarmonizedCodeNumber", item.CanadaHarmonizedCodeNumber)
                            If item.HarmonizedCodeNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HarmonizedCodeNumber", item.HarmonizedCodeNumber)
                            If item.DetailInvoiceCustomsDesc <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc", item.DetailInvoiceCustomsDesc, WebConstants.MULTILINE_DELIM)
                            If item.ComponentMaterialBreakdown <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentMaterialBreakdown", item.ComponentMaterialBreakdown, WebConstants.MULTILINE_DELIM)
                            If item.ComponentConstructionMethod <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentConstructionMethod", item.ComponentConstructionMethod, WebConstants.MULTILINE_DELIM)
                            If item.IndividualItemPackaging <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "IndividualItemPackaging", item.IndividualItemPackaging)

                            If item.QtyInPack <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Qty_In_Pack", item.QtyInPack)

                            If item.EachInsideMasterCaseBox <> String.Empty AndAlso IsNumeric(item.EachInsideMasterCaseBox) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EachInsideMasterCaseBox", CDbl(item.EachInsideMasterCaseBox))
                            If item.EachInsideInnerPack <> String.Empty AndAlso IsNumeric(item.EachInsideInnerPack) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EachInsideInnerPack", CDbl(item.EachInsideInnerPack))
                            'If item.EachPieceNetWeightLbsPerOunce <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EachPieceNetWeightLbsPerOunce", DataHelper.SmartValues(item.EachPieceNetWeightLbsPerOunce, "decimal", True, String.Empty, 4))

                            If item.ReshippableInnerCartonWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ReshippableInnerCartonWeight", DataHelper.SmartValues(item.ReshippableInnerCartonWeight, "decimal", True, String.Empty, 4))


                            If item.EachHeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachheight", DataHelper.SmartValues(item.EachHeight, "decimal", True, String.Empty, 4))
                            If item.EachWidth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachwidth", DataHelper.SmartValues(item.EachWidth, "decimal", True, String.Empty, 4))
                            If item.EachLength <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachlength", DataHelper.SmartValues(item.EachLength, "decimal", True, String.Empty, 4))
                            If item.EachWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachweight", DataHelper.SmartValues(item.EachWeight, "decimal", True, String.Empty, 4))
                            If wsCount > 1 And i > 0 Then
                                ExcelFileHelper.UnlockCellByMap(ws, itemMap, "cubicfeeteach", AppHelper.GetCurrentImportSpreadsheetPassword())
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "cubicfeeteach", DataHelper.SmartValues(item.CubicFeetEach, "decimal", True, String.Empty, 4))
                            End If

                            If item.ReshippableInnerCartonLength <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ReshippableInnerCartonLength", DataHelper.SmartValues(item.ReshippableInnerCartonLength, "decimal", True, String.Empty, 4))
                            If item.ReshippableInnerCartonWidth <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ReshippableInnerCartonWidth", DataHelper.SmartValues(item.ReshippableInnerCartonWidth, "decimal", True, String.Empty, 4))
                            If item.ReshippableInnerCartonHeight <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ReshippableInnerCartonHeight", DataHelper.SmartValues(item.ReshippableInnerCartonHeight, "decimal", True, String.Empty, 4))
                            If item.MasterCartonDimensionsLength <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MasterCartonDimensionsLength", DataHelper.SmartValues(item.MasterCartonDimensionsLength, "decimal", True, String.Empty, 4))
                            If item.MasterCartonDimensionsWidth <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MasterCartonDimensionsWidth", DataHelper.SmartValues(item.MasterCartonDimensionsWidth, "decimal", True, String.Empty, 4))
                            If item.MasterCartonDimensionsHeight <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MasterCartonDimensionsHeight", DataHelper.SmartValues(item.MasterCartonDimensionsHeight, "decimal", True, String.Empty, 4))
                            'LP do not populate, let the formula take over in Excel   <<   WRONG !!! 
                            'If item.CubicFeetPerMasterCarton <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CubicFeetPerMasterCarton", DataHelper.SmartValues(item.CubicFeetPerMasterCarton, "decimal", True, String.Empty, 3))
                            ' set the Cubic Feet Per Master Carton value if child item as it is now editable
                            If wsCount > 1 And i > 0 Then
                                ExcelFileHelper.UnlockCellByMap(ws, itemMap, "CubicFeetPerMasterCarton", AppHelper.GetCurrentImportSpreadsheetPassword())
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "CubicFeetPerMasterCarton", DataHelper.SmartValues(item.CubicFeetPerMasterCarton, "decimal", True, String.Empty, 4))
                            End If
                            If item.WeightMasterCarton <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "WeightMasterCarton", DataHelper.SmartValues(item.WeightMasterCarton, "decimal", True, String.Empty, 4))
                            'lp
                            'If item.CubicFeetPerInnerCarton <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CubicFeetPerInnerCarton", DataHelper.SmartValues(item.CubicFeetPerInnerCarton, "decimal", True, String.Empty, 4))
                            'LP SPEDY order 12 Feb 2009 
                            If item.DisplayerCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Displayer_Cost", DataHelper.SmartValues(item.DisplayerCost, "decimal", True, String.Empty, 4))
                            If item.ProductCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Product_Cost", DataHelper.SmartValues(item.ProductCost, "decimal", True, String.Empty, 4))
                            'end LP changes
                            'DO NOT POPULATE- FORMULAS IN Excell unless Displaey cost and product cost never been set
                            If item.FOBShippingPoint <> String.Empty And item.DisplayerCost = Decimal.MinValue And item.ProductCost = Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "FOBShippingPoint", DataHelper.SmartValues(item.FOBShippingPoint, "decimal", True, String.Empty, 4))
                                'ExcelFileHelper.SetCellByMap(ws, itemMap, "FirstCost", DataHelper.SmartValues(item.FOBShippingPoint, "decimal", True, String.Empty, 4))
                            End If
                            If item.DutyPercent <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DutyPercent", DataHelper.SmartValues(item.DutyPercent, "decimal", True, String.Empty, 4))
                            'If item.DutyAmount <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DutyAmount", DataHelper.SmartValues(item.DutyAmount, "decimal", True, String.Empty, 4))
                            If item.AdditionalDutyComment <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AdditionalDutyComment", item.AdditionalDutyComment)
                            If item.AdditionalDutyAmount <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AdditionalDutyAmount", DataHelper.SmartValues(item.AdditionalDutyAmount, "decimal", True, String.Empty, 4))

                            If item.SuppTariffPercent <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SuppTariffPercent", DataHelper.SmartValues(item.SuppTariffPercent, "decimal", True, String.Empty, 4))

                            If item.OceanFreightAmount <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OceanFreightAmount", DataHelper.SmartValues(item.OceanFreightAmount, "decimal", True, String.Empty, 4))
                            'LP formula in Excel j85
                            'If item.OceanFreightComputedAmount <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OceanFreightComputedAmount", DataHelper.SmartValues(item.OceanFreightComputedAmount, "decimal", True, String.Empty, 4))
                            If item.AgentCommissionPercent <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentCommissionPercent", DataHelper.SmartValues(item.AgentCommissionPercent, "decimal", True, String.Empty, 4))

                            'If item.AgentCommissionAmount <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentCommissionAmount", DataHelper.SmartValues(item.AgentCommissionAmount, "decimal", True, String.Empty, 4))
                            If item.OtherImportCostsPercent <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OtherImportCostsPercent", DataHelper.SmartValues(item.OtherImportCostsPercent, "decimal", True, String.Empty, 4))
                            'lp formulas in excel j90,j92,j94,s35,s37,s39,s41,s43
                            'If item.OtherImportCostsAmount <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OtherImportCostsAmount", DataHelper.SmartValues(item.OtherImportCostsAmount, "decimal", True, String.Empty, 4))
                            'If item.PackagingCostAmount <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PackagingCostAmount", DataHelper.SmartValues(item.PackagingCostAmount, "decimal", True, String.Empty, 4))
                            If item.TotalImportBurden <> String.Empty Then
                                '    ExcelFileHelper.SetCellByMap(ws, itemMap, "TotalImportBurden", DataHelper.SmartValues(item.TotalImportBurden, "decimal", True, String.Empty, 4))
                                '   ExcelFileHelper.SetCellByMap(ws, itemMap, "StoreTotalImportBurden", DataHelper.SmartValues(item.TotalImportBurden, "decimal", True, String.Empty, 4))
                            End If
                            If item.WarehouseLandedCost <> String.Empty Then
                                '  ExcelFileHelper.SetCellByMap(ws, itemMap, "WarehouseLandedCost", DataHelper.SmartValues(item.WarehouseLandedCost, "decimal", True, String.Empty, 4))
                                'lp formula in excel cell s37
                                'ExcelFileHelper.SetCellByMap(ws, itemMap, "TotalWhseLandedCost", DataHelper.SmartValues(item.WarehouseLandedCost, "decimal", True, String.Empty, 4))
                            End If
                            If item.PurchaseOrderIssuedTo <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PurchaseOrderIssuedTo", item.PurchaseOrderIssuedTo, WebConstants.MULTILINE_DELIM)
                            If item.ShippingPoint <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ShippingPoint", item.ShippingPoint)
                            If item.CountryOfOriginName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CountryOfOrigin", item.CountryOfOriginName)
                            If item.VendorComments <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorComments", item.VendorComments)

                            ExcelFileHelper.SetCellByMap(ws, itemMap, "StockCategory", item.StockCategory)
                            ExcelFileHelper.SetCellByMap(ws, itemMap, "FreightTerms", item.FreightTerms)
                            If item.ItemType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ItemType", item.ItemType)
                            If item.PackItemIndicator <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PackItemIndicator", item.PackItemIndicator)
                            If item.ItemTypeAttribute <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ItemTypeAttribute", item.ItemTypeAttribute)
                            If item.AllowStoreOrder <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AllowStoreOrder", item.AllowStoreOrder)
                            If item.InventoryControl <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "InventoryControl", item.InventoryControl)
                            If item.AutoReplenish <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AutoReplenish", item.AutoReplenish)
                            If item.PrePriced <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PrePriced", item.PrePriced)
                            If item.TaxUDA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TaxUDA", item.TaxUDA)
                            If item.PrePricedUDA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PrePricedUDA", item.PrePricedUDA)
                            If item.TaxValueUDA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TaxValueUDA", item.TaxValueUDA)
                            'If item.HybridType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HybridType", item.HybridType)
                            'If item.SourcingDC <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SourcingDC", item.SourcingDC)
                            'If item.LeadTime <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "LeadTime", item.LeadTime)
                            'If item.ConversionDate <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ConversionDate", DataHelper.SmartValues(item.ConversionDate, "date", True))

                            'If item.StockingStrategyCode <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Stocking_Strategy_Code", item.StockingStrategyCode)
                            If item.StockingStrategyCode <> String.Empty Then
                                For Each ss As NovaLibra.Coral.SystemFrameworks.Michaels.StockingStrategyRecord In StockingStrats
                                    If ss.StrategyCode = item.StockingStrategyCode Then
                                        ExcelFileHelper.SetCellByMap(ws, itemMap, "Stocking_Strategy_Code", item.StockingStrategyCode & " - " & ss.StrategyDesc)
                                        Exit For
                                    End If
                                Next

                            End If



                            ExcelFileHelper.SetCellByMap(ws, itemMap, "StoreSuppZoneGRP", item.StoreSuppZoneGRP)
                            ExcelFileHelper.SetCellByMap(ws, itemMap, "WhseSuppZoneGRP", item.WhseSuppZoneGRP)

                            'NAK 12/14/2011 - REMOVING this field, since it is old.
                            'If item.ProjSalesPerStorePerMonth <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ProjSalesPerStorePerMonth", item.ProjSalesPerStorePerMonth)
                            'lp formula in Excel S39
                            'If item.OutboundFreight <> String.Empty AndAlso IsNumeric(item.OutboundFreight) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OutboundFreight", CDbl(item.OutboundFreight))
                            'If item.NinePercentWhseCharge <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "NinePercentWhseCharge", CDbl(item.NinePercentWhseCharge))

                            'LP SPEDY Order 12 client requested to pass formula instead of value
                            'If item.TotalStoreLandedCost <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TotalStoreLandedCost", CDbl(item.TotalStoreLandedCost))
                            'ExcelFileHelper.SetCellByMap(ws, itemMap, "TotalStoreLandedCost", "=IF(S37="""","""",SUM(S37+S39+S41))")
                            'ExcelFileHelper.SetCellByMap(ws, itemMap, "TotalStoreLandedCost", "=SUM(S37+S39+S41)")
                            'LP do not populate S43 Total StoreLandedCost, let formula calulate it in excell
                            'LP overwrite formulas in Excel with empty strings per Michelle' request
                            If item.RDBase <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDBase", DataHelper.SmartValues(item.RDBase, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDBase", "")
                            End If
                            If item.RDCentral <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCentral", DataHelper.SmartValues(item.RDCentral, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCentral", "")
                            End If
                            If item.RDTest <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDTest", DataHelper.SmartValues(item.RDTest, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDTest", "")
                            End If
                            If item.RDAlaska <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDAlaska", DataHelper.SmartValues(item.RDAlaska, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDAlaska", "")
                            End If
                            If item.RDCanada <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCanada", DataHelper.SmartValues(item.RDCanada, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCanada", "")
                            End If
                            If item.RD0Thru9 <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RD0Thru9", DataHelper.SmartValues(item.RD0Thru9, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RD0Thru9", "")
                            End If
                            If item.RDCalifornia <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCalifornia", DataHelper.SmartValues(item.RDCalifornia, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCalifornia", "")
                            End If

                            If item.RDVillageCraft <> String.Empty Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDVillageCraft", DataHelper.SmartValues(item.RDVillageCraft, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDVillageCraft", "")
                            End If
                            'lp change order 14 Sept 2009
                            If item.Retail9 <> Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail9", DataHelper.SmartValues(item.Retail9, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail9", "")
                            End If
                            If item.Retail10 <> Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail10", DataHelper.SmartValues(item.Retail10, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail10", "")
                            End If
                            If item.Retail11 <> Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail11", DataHelper.SmartValues(item.Retail11, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail11", "")
                            End If
                            If item.Retail12 <> Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail12", DataHelper.SmartValues(item.Retail12, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail12", "")
                            End If
                            If item.Retail13 <> Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail13", DataHelper.SmartValues(item.Retail13, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail13", "")
                            End If
                            If item.RDQuebec <> Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDQuebec", DataHelper.SmartValues(item.RDQuebec, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDQuebec", "")
                            End If
                            If item.RDPuertoRico <> Decimal.MinValue Then
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDPuertoRico", DataHelper.SmartValues(item.RDPuertoRico, "decimal", True, String.Empty, 4))
                            Else
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "RDPuertoRico", "")
                            End If

                            ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatYes", item.HazMatYes)
                            ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatNo", item.HazMatNo)
                            If item.HazMatMFGCountry <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGCountry", item.HazMatMFGCountry)
                            If item.HazMatMFGName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGName", item.HazMatMFGName)
                            If item.HazMatMFGFlammable <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGFlammable", item.HazMatMFGFlammable)
                            If item.HazMatMFGCity <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGCity", item.HazMatMFGCity)
                            If item.HazMatContainerType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatContainerType", item.HazMatContainerType)
                            If item.HazMatMFGState <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGState", item.HazMatMFGState)
                            If item.HazMatContainerSize <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatContainerSize", item.HazMatContainerSize)
                            If item.HazMatMFGPhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGPhone", item.HazMatMFGPhone)
                            If item.HazMatMSDSUOM <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMSDSUOM", item.HazMatMSDSUOM)
                            If item.CoinBattery <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CoinBattery", item.CoinBattery)
                            'If item.TSSA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TSSA", item.TSSA)
                            If item.CSA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CSA", item.CSA)
                            If item.UL <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "UL", item.UL)
                            If item.LicenceAgreement <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "LicenceAgreement", item.LicenceAgreement)
                            If item.FumigationCertificate <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FumigationCertificate", item.FumigationCertificate)

                            Dim PTSYesNo As String = item.PhytoTemporaryShipment
                            If PTSYesNo = "Y" Then
                                PTSYesNo = "YES"
                            ElseIf PTSYesNo = "N" Then
                                PTSYesNo = "NO"
                            End If
                            If PTSYesNo <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PhytoTemporaryShipment", PTSYesNo)

                            If item.KILNDriedCertificate <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "KILNDriedCertificate", item.KILNDriedCertificate)
                            If item.ChinaComInspecNumAndCCIBStickers <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ChinaComInspecNumAndCCIBStickers", item.ChinaComInspecNumAndCCIBStickers)
                            If item.OriginalVisa <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OriginalVisa", item.OriginalVisa)
                            If item.TextileDeclarationMidCode <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TextileDeclarationMidCode", item.TextileDeclarationMidCode)
                            If item.QuotaChargeStatement <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "QuotaChargeStatement", item.QuotaChargeStatement)
                            If item.MSDS <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MSDS", item.MSDS)
                            If item.TSCA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TSCA", item.TSCA)
                            If item.DropBallTestCert <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DropBallTestCert", item.DropBallTestCert)
                            If item.ManMedicalDeviceListing <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManMedicalDeviceListing", item.ManMedicalDeviceListing)
                            If item.ManFDARegistration <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManFDARegistration", item.ManFDARegistration)
                            If item.CopyRightIndemnification <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CopyRightIndemnification", item.CopyRightIndemnification)
                            If item.FishWildLifeCert <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FishWildLifeCert", item.FishWildLifeCert)
                            If item.Proposition65LabelReq <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Proposition65LabelReq", item.Proposition65LabelReq)
                            If item.CCCR <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CCCR", item.CCCR)
                            If item.FormaldehydeCompliant <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FormaldehydeCompliant", item.FormaldehydeCompliant)
                            If item.QuoteReferenceNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "QuoteReferenceNumber", item.QuoteReferenceNumber)


                            'If item.MinimumOrderQuantity <> Integer.MinValue Then
                            '    ExcelFileHelper.SetCellByMap(ws, itemMap, "MinimumOrderQuantity", item.MinimumOrderQuantity)
                            'Else
                            '    ExcelFileHelper.SetCellByMap(ws, itemMap, "MinimumOrderQuantity", "")
                            'End If

                            Dim PTACYesNo As String = item.ProductIdentifiesAsCosmetic
                            If PTACYesNo = "Y" Then
                                PTACYesNo = "YES"
                            ElseIf PTACYesNo = "N" Then
                                PTACYesNo = "NO"
                            End If
                            If PTACYesNo <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ProductIdentifiesAsCosmetic", PTSYesNo)


                            If item.Agent <> String.Empty And item.AgentType <> String.Empty Then
                                ExcelFileHelper.UnlockCellByMap(ws, itemMap, "AgentType2X", AppHelper.GetCurrentImportSpreadsheetPassword())
                                ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentType2X", item.AgentType)
                            End If

                            'Get language settings from SPD_Import_Item_Languages
                            Dim languageDT As DataTable = NLData.Michaels.ImportItemDetail.GetImportItemLanguages(item.ID)
                            If languageDT.Rows.Count > 0 Then
                                'For Each language row, set the front end controls
                                For Each language As DataRow In languageDT.Rows
                                    Dim languageTypeID As Integer = DataHelper.SmartValues(language("Language_Type_ID"), "CInt", False)
                                    Dim pli As String = DataHelper.SmartValues(language("Package_Language_Indicator"), "CStr", False)
                                    Dim ti As String = DataHelper.SmartValues(language("Translation_Indicator"), "CStr", False)
                                    Dim descShort As String = DataHelper.SmartValues(language("Description_Short"), "CStr", False)
                                    Dim descLong As String = DataHelper.SmartValues(language("Description_Long"), "CStr", False)
                                    Dim exemptEndDate As String = DataHelper.SmartValues(language("Exempt_End_Date"), "CStr", False)
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
                                            item.ExemptEndDateFrench = exemptEndDate
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
                                            ExcelFileHelper.SetCellByMap(ws, itemMap, "PrivateBrandLabel", lv.DisplayText)
                                        End If
                                    Next
                                End If
                            End If

                            'Set Language info
                            If item.CustomsDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CustomsDescription", item.CustomsDescription)
                            ExcelFileHelper.SetCellByMap(ws, itemMap, "PLIEnglish", IIf(item.PLIEnglish = "Y", "YES", "NO"))
                            ExcelFileHelper.SetCellByMap(ws, itemMap, "PLIFrench", IIf(item.PLIFrench = "Y", "YES", "NO"))
                            ExcelFileHelper.SetCellByMap(ws, itemMap, "PLISpanish", IIf(item.PLISpanish = "Y", "YES", "NO"))
                            'ExcelFileHelper.SetCellByMap(ws, itemMap, "TIEnglish", IIf(item.TIEnglish = "Y", "YES", "NO"))
                            'ExcelFileHelper.SetCellByMap(ws, itemMap, "TIFrench", IIf(item.TIFrench = "Y", "YES", "NO"))
                            'ExcelFileHelper.SetCellByMap(ws, itemMap, "TISpanish", IIf(item.TISpanish = "Y", "YES", "NO"))
                            If item.EnglishLongDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnglishLongDescription", item.EnglishLongDescription)
                            If item.EnglishShortDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnglishShortDescription", item.EnglishShortDescription)

                            'NAK 9/10/2012 Per Michaels:  we are not currently importing or exporting the Short/Long descriptions for French and Spanish.
                            'If item.FrenchLongDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FrenchLongDescription", item.FrenchLongDescription)
                            'If item.FrenchShortDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FrenchShortDescription", item.FrenchShortDescription)
                            'If item.SpanishLongDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SpanishLongDescription", item.SpanishLongDescription)
                            'If item.SpanishShortDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SpanishShortDescription", item.SpanishShortDescription)

                            ' Image

                            'Dim fileID As Long = objMichaelsIFile.GetFileID(Models.ItemTypeString.ITEM_TYPE_IMPORT, item.ID, Models.ItemFileType.Image)
                            'NAK 1/22/2013: Existing SKUs do not get new records in the SPD_Items_Files table.  Insetad, use the ImageID from the item.  
                            Dim fileID As Long = item.ImageID
                            If fileID > 0 Then
                                Dim file As Models.FileRecord = objMichaelsFile.GetRecord(fileID)
                                If Not file Is Nothing And file.ID > 0 Then
                                    Dim ms As New MemoryStream(file.File_Data)
                                    Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(ms)
                                    'ExcelFileHelper.SetImageByMap(ws, itemMap, "Image", img)

                                    'Dim ps As New C1.C1Excel.XLPictureShape(img, New System.Drawing.Size(750 * 16, 750 * 16), Drawing.ContentAlignment.TopLeft, ImageScaling.Scale)
                                    ExcelFileHelper.SetImageByMap(ws, itemMap, "Image", img)
                                End If
                            End If

                            'MWM - 5/21/2018 no longer doing this
                            ''Rename sheet with quote ref num
                            'If Not item.QuoteReferenceNumber = String.Empty Then
                            '    Dim newWSName As String = ""
                            '    If item.PackItemIndicator = String.Empty Then
                            '        newWSName = item.QuoteReferenceNumber
                            '        'ElseIf item.PackItemIndicator = "D" Or item.PackItemIndicator = "DP" Or item.PackItemIndicator = "SB" Then
                            '        '    newWSName = item.PackItemIndicator + " - " + item.QuoteReferenceNumber
                            '    Else
                            '        newWSName = item.PackItemIndicator + " - " + item.QuoteReferenceNumber  '" " + i.ToString +
                            '    End If
                            '    ws.Name = newWSName
                            'End If   'QRN = ""

                            ' save child sheet?
                            'If i >= maxNewItem Then
                            '    filecom.Sheets.Insert(i, ws)
                            'End If

                            ' New Item Approval
                            If Not ws2 Is Nothing AndAlso i < maxNewItem Then
                                ' header info
                                If i = 0 Then
                                    If item.Batch_ID <> Long.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Log_ID", item.Batch_ID)
                                    'lp
                                    If item.VendorNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Vendor_Num", item.VendorNumber)
                                    If item.VendorName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Vendor_Name", item.VendorName)
                                    '
                                    If item.StoreTotal <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Store_Total", item.StoreTotal)
                                    If item.POGStartDate <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Start_Date", item.POGStartDate)
                                    If item.POGCompDate <> Date.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Comp_Date", item.POGCompDate)

                                    'LP only parent has it and i cannot safe it in AK3 field. :-(
                                    ' (DUH... protected/hidden field)
                                    'If item.CalculateOptions <> Integer.MinValue AndAlso CInt(item.CalculateOptions) > 0 Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Calculate_Options", CInt(item.CalculateOptions)) ', 4 'AK3
                                    If item.CalculateOptions > 0 Then
                                        For x = 0 To ws2.Shapes.Count - 1
                                            shape = ws2.Shapes.Item(x)
                                            If shape.ControlFormat IsNot Nothing Then
                                                control = shape.ControlFormat
                                                If shape.Name = "calculate_options" Or control.LinkedCell = "$AK$4" Then
                                                    If item.CalculateOptions = 1 Then
                                                        control.ListIndex = 1
                                                    ElseIf item.CalculateOptions = 2 Then
                                                        control.ListIndex = 2
                                                    End If
                                                End If
                                            End If
                                        Next
                                    End If
                                End If
                                ' detail info
                                If item.MichaelsSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "New_SKU", item.MichaelsSKU, currRow2)
                                If item.Description <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Description", item.Description, currRow2)
                                If item.RDBase <> String.Empty AndAlso IsNumeric(item.RDBase) Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "New_SKU_Retail", CDec(item.RDBase), currRow2)

                                'If item.RDCanada <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "New_SKU_Canada_Retail", item.RDCanada, currRow2)
                                'LP caluclated values should not go: ether Units/store/month or anual regular unit forecast
                                If item.CalculateOptions <> Integer.MinValue Then
                                    Select Case CInt(item.CalculateOptions)
                                        Case 0
                                            'do nothing? -no export Annual Regular Forecast and Unit/store Month
                                        Case 1
                                            If item.AnnualRegularUnitForecast <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Annual_Regular_Unit_Forecast", item.AnnualRegularUnitForecast, currRow2)
                                        Case 2
                                            If item.LikeItemUnitStoreMonth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Unit_Store_Month", item.LikeItemUnitStoreMonth, currRow2)
                                    End Select
                                End If
                                If item.LikeItemSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_SKU", item.LikeItemSKU, currRow2)
                                If item.LikeItemDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Description", item.LikeItemDescription, currRow2)
                                If item.LikeItemRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Retail", CDec(item.LikeItemRetail), currRow2)
                                If item.LikeItemRegularUnit <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Regular_Units", item.LikeItemRegularUnit, currRow2)
                                If item.LikeItemStoreCount <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Store_Count", CDec(item.LikeItemStoreCount), currRow2)

                                If item.Facings <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Facings", item.Facings, currRow2)
                                If item.POGMinQty <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Min_Qty", item.POGMinQty, currRow2)
                                If item.POGMaxQty <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "POG_Max_Qty", item.POGMaxQty, currRow2)
                                If item.POGSetupPerStore <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Initial_Set_Qty_Per_Store", item.POGSetupPerStore, currRow2)
                                If item.EachInsideInnerPack <> String.Empty Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Inner_Pack", item.EachInsideInnerPack, currRow2)

                                ' like item sales is absolite and no longer exports
                                'If item.LikeItemSales <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Like_Item_Sales", item.LikeItemSales, currRow2)
                                'lp
                                ' If item.AnnualRegRetailSales <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws2, itemMap2, "Annual_Reg_Retail_Sales", item.AnnualRegRetailSales, currRow2)
                                '
                            End If

                            ws.Protect(importPassword)
                        Next

                        'select the security sheet, make sure it's visible first
                        wb.Worksheets(WebConstants.IMPORT_ITEM_SECURITY_WORKSHEET).Visible = SpreadsheetGear.SheetVisibility.Visible
                        wb.Worksheets(WebConstants.IMPORT_ITEM_SECURITY_WORKSHEET).Select()

                        fileName = "ImportQuote-" & batchID.ToString() & "-" & dateNow.ToString("yyyyMMdd") & ".xls"
                        Response.BufferOutput = True

                        'xla.Save(filecom, Response, fileName, False)
                        Response.Clear()
                        Response.Buffer = True
                        'filecom.Save(Response.OutputStream)
                        Dim memfile As New System.IO.MemoryStream()
                        wb.SaveToStream(memfile, SpreadsheetGear.FileFormat.Excel8)
                        memfile.WriteTo(Response.OutputStream)
                        memfile = Nothing
                        Response.ContentType = "application/vnd.ms-excel"
                        Response.AddHeader("content-disposition", ("attachment;filename=" & fileName))
                        item = Nothing
                        wb = Nothing
                        objMichaels = Nothing
                        objMichaelsFile = Nothing
                        objMichaelsIFile = Nothing
                        objMichaelsMap = Nothing

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
                    Throw ex
                Finally
                    item = Nothing
                    wb = Nothing
                    itemMap = Nothing
                    objMichaels = Nothing
                    objMichaelsFile = Nothing
                    objMichaelsMap = Nothing
                End Try
            Else
                objMichaels = Nothing
                Throw New Exception("ERROR: Batch was not found!")
            End If
        Catch ex As Exception
            Throw New Exception("ERROR: There was an error exporting the QuoteSheet. " & ex.Message)
        End Try

        Response.End()
    End Sub
End Class
