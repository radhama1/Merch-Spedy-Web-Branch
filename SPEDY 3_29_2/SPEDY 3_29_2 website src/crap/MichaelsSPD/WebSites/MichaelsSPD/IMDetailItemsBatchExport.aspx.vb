Imports System
Imports System.Data
Imports System.IO

Imports SpreadsheetGear

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports WebConstants
Imports NLData = NovaLibra.Coral.Data
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Coral.SystemFrameworks
Imports System.Collections.Generic

Partial Class IMDetailItemsBatchExport
    Inherits MichaelsBasePage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Session(cBATCHID) Is Nothing OrElse DataHelper.SmartValues(Session(cBATCHID), "long", False) <= 0 Then
            Response.Redirect("detail.aspx")
        End If
        Dim batchID As Long = DataHelper.SmartValues(Session(cBATCHID), "long", False)

        Dim returnAddress As String = GetReturnAddress()

        lblFeedback.Visible = False
        lnkReturn.NavigateUrl = returnAddress
        lnkReturn.Visible = False

        If Not IsPostBack Then
            BuildExportFile(batchID)
        End If

    End Sub

    Private Function GetReturnAddress() As String
        Dim ret As String = "default.aspx"
        Dim sRet As String = Session("_XLS_BATCH_EXPORT_RETURN_") & ""
        If sRet.Length > 0 Then
            ret = sRet
        End If
        Return ret
    End Function

    Private Sub BuildExportFile(ByVal batchID As Long)

        Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData

        Dim theBatchType As Integer

        Dim requestFormatType As String = Request("xlFmt") & ""

        Dim theBatch As Models.BatchRecord = batchDB.GetBatchRecord(batchID)
        theBatchType = theBatch.BatchTypeID

        ' if the format input was missing or bogus, use a default format depending on batch type
        If Not (requestFormatType = "1" Or requestFormatType = "2") Then
            requestFormatType = "1"
            If theBatchType = 2 Then
                requestFormatType = "2"
            End If
        End If

        Dim wb As SpreadsheetGear.IWorkbook = Nothing
        Select Case requestFormatType
            Case "1" 'item-maint format
                wb = BuildItemMaintExportFile(batchID)
            Case "2" 'import format
                wb = BuildImportExportFile(batchID)
        End Select

        If Not wb Is Nothing Then
            ' success! export the workbook
            Dim dateNow As Date = Now()
            Dim fName As String = "ItemMaintExport-" & batchID.ToString() & "-" & dateNow.ToString("yyyyMMdd") & ".xls"
            Dim memFile As New MemoryStream()
            wb.SaveToStream(memFile, FileFormat.XLS97)
            memFile.WriteTo(Response.OutputStream)
            memFile = Nothing
            Response.ContentType = "application/vnd.ms-excel"
            Response.AddHeader("content-disposition", ("attachment;filename=" & fName))
            Response.End()
        Else
            ' the query failed to retrieve any data
            lblFeedback.Text = "This batch could not be formatted."
            lblFeedback.Visible = True
            lnkReturn.Text = "Click here to go back."
            lnkReturn.Visible = True
        End If

    End Sub

    Private Function BuildImportExportFile(ByVal batchID As Integer) As SpreadsheetGear.IWorkbook

        Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
        Dim dtChanges As DataTable = batchDB.GetItemMaintBatchExport(batchID)
        Dim dtItems As DataTable = batchDB.GetItemMaintBatchItemList(batchID)
        Dim wb As SpreadsheetGear.IWorkbook = Nothing
        Dim userID As String = Session(WebConstants.cUSERID)
        Dim isMSS As Boolean = False
        Dim exportFile As String = ""

        Dim StockingStrats As New List(Of NovaLibra.Coral.SystemFrameworks.Michaels.StockingStrategyRecord)
        Dim oSS As New NovaLibra.Coral.Data.Michaels.StockingStrategy
        StockingStrats = oSS.GetStockingStrategies()

        If (Not dtItems Is Nothing) And (Not dtChanges Is Nothing) Then

            For i As Integer = 0 To dtChanges.Rows.Count - 1
                If dtChanges.Rows(i)("field_name") = "QuoteReferenceNumber" Then
                    If Not String.IsNullOrEmpty(dtChanges.Rows(i)("field_value")) Then
                        isMSS = True
                    End If
                End If
            Next

            If isMSS Then
                exportFile = System.Configuration.ConfigurationManager.AppSettings("IMPORT_ITEM_MSS_FORM_2")
            Else
                exportFile = System.Configuration.ConfigurationManager.AppSettings("IMPORT_ITEM_FORM_2")
            End If

            exportFile = exportFile.Replace(WebConstants.APP_PATH_REPLACE, (Server.MapPath("")))
            wb = SpreadsheetGear.Factory.GetWorkbook(exportFile)

            Dim ws As SpreadsheetGear.IWorksheet
            Dim copySheet As SpreadsheetGear.IWorksheet
            Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = Nothing
            Dim mMap As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping()

            Dim currentImageID As Long = 0
            For i As Integer = 0 To dtItems.Rows.Count - 1

                ' worksheet
                If i = 0 Then
                    ws = wb.Worksheets(WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET)
                    Dim mapVer As String = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, "B", 3), "string", False)
                    itemMap = mMap.GetMapping("IMPORTITEM", mapVer)

                    If itemMap Is Nothing OrElse itemMap.ID = 0 Then
                        'if the version number ends in 0 the mapVer will not have the trailing zero so we much try to find it by that
                        mapVer = mapVer + "0"
                        itemMap = mMap.GetMapping("IMPORTITEM", mapVer)
                    End If

                    ' make a copy
                    copySheet = ws.CopyAfter(ws)
                    copySheet.Name = "ws_copy"
                Else
                    ' but first, set the image in the current sheet
                    SetExcelItemImage(ws, itemMap, currentImageID)

                    ' move to the next sheet
                    currentImageID = 0
                    ws = wb.Worksheets("ws_copy")
                    Dim wsName As String = WebConstants.IMPORT_ITEM_CHILD_WORKSHEET
                    wsName = wsName.Replace("#", i.ToString())
                    ws.Name = wsName

                    ' make a copy
                    copySheet = ws.CopyAfter(ws)
                    copySheet.Name = "ws_copy"
                End If

                Dim thisIMIID As String = dtItems.Rows(i)("item_maint_items_id").ToString.Trim
                Dim thisSKU As String = dtItems.Rows(i)("Michaels_SKU").ToString.Trim
                Dim thisVendorNbr As String = dtItems.Rows(i)("Vendor_Number").ToString.Trim
                Dim thisDept As String = dtItems.Rows(i)("department_num").ToString.Trim

                Dim masterDtl As Models.ItemMaintItemDetailFormRecord = NLData.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(thisIMIID, thisVendorNbr)

                ExcelFileHelper.SetCellByMap(ws, itemMap, "MichaelsSKU", thisSKU)
                ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorNumber", thisVendorNbr)
                ExcelFileHelper.SetCellByMap(ws, itemMap, "Dept", thisDept)



                ' populate the item in the excel page from the item master record
                PopulateItemFromItemMaster(ws, itemMap, masterDtl, StockingStrats)
                currentImageID = masterDtl.ImageID

                ' now populate the changes
                For j As Integer = 0 To dtChanges.Rows.Count - 1
                    Dim thisChangeSKU As String = dtChanges.Rows(j)("Michaels_SKU").ToString.Trim
                    Dim thisFieldName As String = dtChanges.Rows(j)("field_name").ToString.Trim
                    Dim thisFieldValue As String = dtChanges.Rows(j)("field_value").ToString.Trim

                    If (thisFieldValue.Length > 0) And (thisChangeSKU = thisSKU) Then
                        If thisFieldName.ToUpper = "IMAGEID" Then
                            If IsNumeric(thisFieldValue) Then
                                Dim tempImageID As Long = CType(thisFieldValue, Long)
                                If tempImageID > 0 Then
                                    currentImageID = tempImageID
                                End If
                            End If
                        Else

                            'HACK for PLI/TI fields.  These fields are saved as Y/N, but should export as YES/NO.
                            If thisFieldName = "PLIEnglish" Or thisFieldName = "PLIFrench" Or thisFieldName = "PLISpanish" Or thisFieldName = "TIEnglish" Or thisFieldName = "TIFrench" Or thisFieldName = "TISpanish" Or thisFieldName = "PhytoTemporaryShipment" Then
                                If thisFieldValue.ToUpper = "Y" Then
                                    thisFieldValue = "YES"
                                End If
                                If thisFieldValue.ToUpper = "N" Then
                                    thisFieldValue = "NO"
                                End If
                            End If
                            'HACK for Private Brand Label 
                            If thisFieldName = "PrivateBrandLabel" Then
                                If Not String.IsNullOrEmpty(thisFieldValue) Then
                                    Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
                                    If pbllvgs IsNot Nothing Then
                                        For Each lv As ListValue In pbllvgs.ListValues
                                            If lv.Value = thisFieldValue Then
                                                thisFieldValue = lv.DisplayText
                                            End If
                                        Next
                                    End If
                                End If
                            End If

                            ExcelFileHelper.SetCellByMap(ws, itemMap, thisFieldName, thisFieldValue)
                        End If
                    End If
                Next
            Next

            ' set the image in the last sheet
            SetExcelItemImage(ws, itemMap, currentImageID)

            ' get rid of the copy
            If dtItems.Rows.Count > 0 Then
                wb.Worksheets("ws_copy").Delete()
            End If

            'Lock the Worksheet if there is a Quote Reference Number
            'wet - 7/16 - removed locking since we are now using regular importquote spreadsheet
            'If isMSS Then
            '    For Each sheet As SpreadsheetGear.IWorksheet In wb.Worksheets
            '        If Not sheet.Name = WebConstants.LIKE_ITEM_TAB_WORKSHEET Then
            '            If sheet.ProtectContents Then
            '                sheet.Unprotect(ConfigurationManager.AppSettings("SPREADSHEET_IMPORT_PASSWORD"))
            '            End If
            '            sheet.ProtectContents = False
            '            sheet.Cells.Locked = False
            '            sheet.Cells.Locked = True
            '            sheet.ProtectContents = True

            '            Dim mssPassword As String = System.Configuration.ConfigurationManager.AppSettings("MSS_QUOTESHEET_PASSWORD")
            '            sheet.Protect(mssPassword)
            '        End If
            '    Next
            'End If

            'wb.Worksheets(0).Select()

        End If

        Return wb

    End Function

    Private Sub SetExcelItemImage(ByVal ws As SpreadsheetGear.IWorksheet, ByVal itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping, ByVal imageID As Long)

        Dim mFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFile
        If imageID > 0 Then
            Dim imgFile As Models.FileRecord = mFile.GetRecord(imageID)
            If (Not imgFile Is Nothing) AndAlso (imgFile.ID > 0) Then
                Dim ms As New MemoryStream(imgFile.File_Data)
                Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(ms)
                ExcelFileHelper.SetImageByMap(ws, itemMap, "Image", img)
            End If
        End If

    End Sub

    Private Sub PopulateItemFromItemMaster(ByVal ws As SpreadsheetGear.IWorksheet, ByVal itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping, _
        ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal StockingStrats As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.StockingStrategyRecord))

        If masterDtl.VendorOrAgent = "A" Then
            ExcelFileHelper.SetCellByMap(ws, itemMap, "Agent", "YES")
        Else
            ExcelFileHelper.SetCellByMap(ws, itemMap, "Vendor", "YES")
        End If
        ExcelFileHelper.SetCellByMap(ws, itemMap, "StockCategory", masterDtl.StockCategory)
        ExcelFileHelper.SetCellByMap(ws, itemMap, "FreightTerms", masterDtl.FreightTerms)

        ExcelFileHelper.UnlockCellByMap(ws, itemMap, "AgentType2X", AppHelper.GetCurrentImportSpreadsheetPassword())
        ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentType2X", masterDtl.AgentType)

        If masterDtl.Buyer <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Buyer", masterDtl.Buyer)
        If masterDtl.BuyerFax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Fax", masterDtl.BuyerFax)
        If masterDtl.BuyerEmail <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Email", masterDtl.BuyerEmail)
        If masterDtl.SKUGroup <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SKUGroup", masterDtl.SKUGroup)

        If masterDtl.ClassNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Class", masterDtl.ClassNum)
        If masterDtl.SubClassNum <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SubClass", masterDtl.SubClassNum)
        If masterDtl.PrimaryUPC <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PrimaryUPC", masterDtl.PrimaryUPC)

        If masterDtl.InnerGTIN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "InnerGTIN", masterDtl.InnerGTIN)
        If masterDtl.CaseGTIN <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CaseGTIN", masterDtl.CaseGTIN)

        If masterDtl.PackSKU <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PackSKU", masterDtl.PackSKU)
        If masterDtl.PlanogramName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PlanogramName", masterDtl.PlanogramName)

        If masterDtl.ItemDesc <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Description", masterDtl.ItemDesc)
        If masterDtl.Season <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Season", masterDtl.Season)
        If masterDtl.PaymentTerms <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PaymentTerms", masterDtl.PaymentTerms)
        If masterDtl.Days <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Days", masterDtl.Days)
        If masterDtl.VendorMinOrderAmount <> String.Empty AndAlso IsNumeric(masterDtl.VendorMinOrderAmount) Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorMinOrderAmount", DataHelper.SmartValues(masterDtl.VendorMinOrderAmount, "decimal", True, String.Empty, 4))

        If masterDtl.PrimaryVendor Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorRank", IIf(masterDtl.PrimaryVendor, "PRIMARY", ""))
        If masterDtl.VendorName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorName", masterDtl.VendorName)
        If masterDtl.VendorAddress1 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress1", masterDtl.VendorAddress1)
        If masterDtl.VendorAddress2 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress2", masterDtl.VendorAddress2)
        If masterDtl.VendorAddress3 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress3", masterDtl.VendorAddress3)
        If masterDtl.VendorAddress4 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorAddress4", masterDtl.VendorAddress4)
        If masterDtl.VendorContactName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactName", masterDtl.VendorContactName)
        If masterDtl.VendorContactPhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactPhone", masterDtl.VendorContactPhone)
        If masterDtl.VendorContactEmail <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactEmail", masterDtl.VendorContactEmail)
        If masterDtl.VendorContactFax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorContactFax", masterDtl.VendorContactFax)

        If masterDtl.ManufactureName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureName", masterDtl.ManufactureName)
        If masterDtl.ManufactureAddress1 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureAddress1", masterDtl.ManufactureAddress1)
        If masterDtl.ManufactureAddress2 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureAddress2", masterDtl.ManufactureAddress2)
        If masterDtl.ManufactureContact <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureContact", masterDtl.ManufactureContact)
        If masterDtl.ManufacturePhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufacturePhone", masterDtl.ManufacturePhone)
        If masterDtl.ManufactureEmail <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureEmail", masterDtl.ManufactureEmail)
        If masterDtl.ManufactureFax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManufactureFax", masterDtl.ManufactureFax)
        If masterDtl.AgentContact <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentContact", masterDtl.AgentContact)
        If masterDtl.AgentPhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentPhone", masterDtl.AgentPhone)
        If masterDtl.AgentEmail <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentEmail", masterDtl.AgentEmail)
        If masterDtl.AgentFax <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentFax", masterDtl.AgentFax)

        If masterDtl.VendorStyleNum <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorStyleNumber", masterDtl.VendorStyleNum)
        If masterDtl.HarmonizedCodeNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HarmonizedCodeNumber", masterDtl.HarmonizedCodeNumber)
        If masterDtl.CanadaHarmonizedCodeNumber <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CanadaHarmonizedCodeNumber", masterDtl.CanadaHarmonizedCodeNumber)
        If masterDtl.DetailInvoiceCustomsDesc0 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc0", masterDtl.DetailInvoiceCustomsDesc0, WebConstants.MULTILINE_DELIM)
        If masterDtl.DetailInvoiceCustomsDesc1 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc1", masterDtl.DetailInvoiceCustomsDesc1, WebConstants.MULTILINE_DELIM)
        If masterDtl.DetailInvoiceCustomsDesc2 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc2", masterDtl.DetailInvoiceCustomsDesc2, WebConstants.MULTILINE_DELIM)
        If masterDtl.DetailInvoiceCustomsDesc3 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc3", masterDtl.DetailInvoiceCustomsDesc3, WebConstants.MULTILINE_DELIM)
        If masterDtl.DetailInvoiceCustomsDesc4 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc4", masterDtl.DetailInvoiceCustomsDesc4, WebConstants.MULTILINE_DELIM)
        If masterDtl.DetailInvoiceCustomsDesc5 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc5", masterDtl.DetailInvoiceCustomsDesc5, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentMaterialBreakdown0 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentMaterialBreakdown0", masterDtl.ComponentMaterialBreakdown0, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentMaterialBreakdown1 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentMaterialBreakdown1", masterDtl.ComponentMaterialBreakdown1, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentMaterialBreakdown2 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentMaterialBreakdown2", masterDtl.ComponentMaterialBreakdown2, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentMaterialBreakdown3 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentMaterialBreakdown3", masterDtl.ComponentMaterialBreakdown3, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentMaterialBreakdown4 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentMaterialBreakdown4", masterDtl.ComponentMaterialBreakdown4, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentConstructionMethod0 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentConstructionMethod0", masterDtl.ComponentConstructionMethod0, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentConstructionMethod1 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentConstructionMethod1", masterDtl.ComponentConstructionMethod1, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentConstructionMethod2 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentConstructionMethod2", masterDtl.ComponentConstructionMethod2, WebConstants.MULTILINE_DELIM)
        If masterDtl.ComponentConstructionMethod3 <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ComponentConstructionMethod3", masterDtl.ComponentConstructionMethod3, WebConstants.MULTILINE_DELIM)
        If masterDtl.IndividualItemPackaging <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "IndividualItemPackaging", masterDtl.IndividualItemPackaging)

        If masterDtl.EachesMasterCase <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EachInsideMasterCaseBox", CDbl(masterDtl.EachesMasterCase))
        If masterDtl.EachesInnerPack <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EachInsideInnerPack", CDbl(masterDtl.EachesInnerPack))

        If masterDtl.EachCaseLength <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachlength", DataHelper.SmartValues(masterDtl.EachCaseLength, "decimal", True, String.Empty, 4))
        If masterDtl.EachCaseWidth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachwidth", DataHelper.SmartValues(masterDtl.EachCaseWidth, "decimal", True, String.Empty, 4))
        If masterDtl.EachCaseHeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachheight", DataHelper.SmartValues(masterDtl.EachCaseHeight, "decimal", True, String.Empty, 4))
        If masterDtl.EachCaseWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "eachweight", DataHelper.SmartValues(masterDtl.EachCaseWeight, "decimal", True, String.Empty, 4))

        If masterDtl.InnerCaseLength <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ReshippableInnerCartonLength", DataHelper.SmartValues(masterDtl.InnerCaseLength, "decimal", True, String.Empty, 4))
        If masterDtl.InnerCaseWidth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ReshippableInnerCartonWidth", DataHelper.SmartValues(masterDtl.InnerCaseWidth, "decimal", True, String.Empty, 4))
        If masterDtl.InnerCaseHeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ReshippableInnerCartonHeight", DataHelper.SmartValues(masterDtl.InnerCaseHeight, "decimal", True, String.Empty, 4))
        If masterDtl.MasterCaseLength <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MasterCartonDimensionsLength", DataHelper.SmartValues(masterDtl.MasterCaseLength, "decimal", True, String.Empty, 4))
        If masterDtl.MasterCaseWidth <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MasterCartonDimensionsWidth", DataHelper.SmartValues(masterDtl.MasterCaseWidth, "decimal", True, String.Empty, 4))
        If masterDtl.MasterCaseHeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MasterCartonDimensionsHeight", DataHelper.SmartValues(masterDtl.MasterCaseHeight, "decimal", True, String.Empty, 4))
        If masterDtl.MasterCaseWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "WeightMasterCarton", DataHelper.SmartValues(masterDtl.MasterCaseWeight, "decimal", True, String.Empty, 4))
        ' we put the Inner Case Weight value from master dtl into the EachPieceNetWeight field. This is actually symmetrical with the spreadsheet-import process.
        If masterDtl.InnerCaseWeight <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "InnerCaseWeight", DataHelper.SmartValues(masterDtl.InnerCaseWeight, "decimal", True, String.Empty, 4))

        If masterDtl.QtyInPack <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Qty_In_Pack", masterDtl.QtyInPack)

        If masterDtl.DisplayerCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Displayer_Cost", DataHelper.SmartValues(masterDtl.DisplayerCost, "decimal", True, String.Empty, 4))
        If masterDtl.ProductCost <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Product_Cost", DataHelper.SmartValues(masterDtl.ProductCost, "decimal", True, String.Empty, 4))

        If masterDtl.FOBShippingPoint <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FOBShippingPoint", DataHelper.SmartValues(masterDtl.FOBShippingPoint, "decimal", True, String.Empty, 4))

        If masterDtl.DutyPercent <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DutyPercent", DataHelper.SmartValues(masterDtl.DutyPercent, "decimal", True, String.Empty, 4))
        If masterDtl.AdditionalDutyComment <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AdditionalDutyComment", masterDtl.AdditionalDutyComment)
        If masterDtl.AdditionalDutyAmount <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AdditionalDutyAmount", DataHelper.SmartValues(masterDtl.AdditionalDutyAmount, "decimal", True, String.Empty, 4))

        If masterDtl.SuppTariffPercent <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SuppTariffPercent", DataHelper.SmartValues(masterDtl.SuppTariffPercent, "decimal", True, String.Empty, 4))

        If masterDtl.OceanFreightAmount <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OceanFreightAmount", DataHelper.SmartValues(masterDtl.OceanFreightAmount, "decimal", True, String.Empty, 4))

        ExcelFileHelper.UnlockCellByMap(ws, itemMap, "AgentCommissionPercent", AppHelper.GetCurrentImportSpreadsheetPassword())
        If masterDtl.AgentCommissionPercent <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AgentCommissionPercent", DataHelper.SmartValues(masterDtl.AgentCommissionPercent, "decimal", True, String.Empty, 4))

        If masterDtl.OtherImportCostsPercent <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OtherImportCostsPercent", DataHelper.SmartValues(masterDtl.OtherImportCostsPercent, "decimal", True, String.Empty, 4))
        If masterDtl.PurchaseOrderIssuedTo <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PurchaseOrderIssuedTo", masterDtl.PurchaseOrderIssuedTo, WebConstants.MULTILINE_DELIM)
        If masterDtl.ShippingPoint <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ShippingPoint", masterDtl.ShippingPoint)
        If masterDtl.CountryOfOriginName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CountryOfOrigin", masterDtl.CountryOfOriginName)
        If masterDtl.VendorComments <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "VendorComments", masterDtl.VendorComments)

        If masterDtl.QuoteSheetItemType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ItemType", masterDtl.QuoteSheetItemType)
        If masterDtl.PackItemIndicator <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PackItemIndicator", masterDtl.PackItemIndicator)
        If masterDtl.ItemTypeAttribute <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ItemTypeAttribute", masterDtl.ItemTypeAttribute)
        If masterDtl.AllowStoreOrder <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AllowStoreOrder", masterDtl.AllowStoreOrder)
        If masterDtl.InventoryControl <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "InventoryControl", masterDtl.InventoryControl)
        If masterDtl.AutoReplenish <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "AutoReplenish", masterDtl.AutoReplenish)
        If masterDtl.PrePriced <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PrePriced", masterDtl.PrePriced)
        If masterDtl.TaxUDA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TaxUDA", masterDtl.TaxUDA)
        If masterDtl.PrePricedUDA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PrePricedUDA", masterDtl.PrePricedUDA)
        If masterDtl.TaxValueUDA <> Long.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TaxValueUDA", masterDtl.TaxValueUDA)
        'If masterDtl.HybridType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HybridType", masterDtl.HybridType)

        'If masterDtl.StockingStrategyCode <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Stocking_Strategy_Code", masterDtl.StockingStrategyCode)

        If masterDtl.StockingStrategyCode <> String.Empty Then
            For Each ss As NovaLibra.Coral.SystemFrameworks.Michaels.StockingStrategyRecord In StockingStrats
                If ss.StrategyCode = masterDtl.StockingStrategyCode Then
                    ExcelFileHelper.SetCellByMap(ws, itemMap, "Stocking_Strategy_Code", masterDtl.StockingStrategyCode & " - " & ss.StrategyDesc)
                    Exit For
                End If
            Next
        End If

        If masterDtl.Hazardous = "X" Then
            ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatYes", "X")
        Else
            ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatNo", "X")
        End If
        If masterDtl.HazardousManufacturerCountry <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGCountry", masterDtl.HazardousManufacturerCountry)
        If masterDtl.HazardousManufacturerName <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGName", masterDtl.HazardousManufacturerName)
        If masterDtl.HazardousFlammable <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGFlammable", masterDtl.HazardousFlammable)
        If masterDtl.HazardousManufacturerCity <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGCity", masterDtl.HazardousManufacturerCity)
        If masterDtl.HazardousContainerType <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatContainerType", masterDtl.HazardousContainerType)
        If masterDtl.HazardousManufacturerState <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGState", masterDtl.HazardousManufacturerState)
        If masterDtl.HazardousContainerSize <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatContainerSize", masterDtl.HazardousContainerSize)
        If masterDtl.HazardousManufacturerPhone <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMFGPhone", masterDtl.HazardousManufacturerPhone)
        If masterDtl.HazardousMSDSUOM <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "HazMatMSDSUOM", masterDtl.HazardousMSDSUOM)
        If masterDtl.CoinBattery <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CoinBattery", masterDtl.CoinBattery)
        'If masterDtl.TSSA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TSSA", masterDtl.TSSA)
        If masterDtl.CSA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CSA", masterDtl.CSA)
        If masterDtl.UL <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "UL", masterDtl.UL)
        If masterDtl.LicenceAgreement <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "LicenceAgreement", masterDtl.LicenceAgreement)
        If masterDtl.FumigationCertificate <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FumigationCertificate", masterDtl.FumigationCertificate)
        If masterDtl.PhytoTemporaryShipment <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "PhytoTemporaryShipment", masterDtl.PhytoTemporaryShipment)

        If masterDtl.KILNDriedCertificate <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "KILNDriedCertificate", masterDtl.KILNDriedCertificate)
        If masterDtl.ChinaComInspecNumAndCCIBStickers <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ChinaComInspecNumAndCCIBStickers", masterDtl.ChinaComInspecNumAndCCIBStickers)
        If masterDtl.OriginalVisa <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "OriginalVisa", masterDtl.OriginalVisa)
        If masterDtl.TextileDeclarationMidCode <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TextileDeclarationMidCode", masterDtl.TextileDeclarationMidCode)
        If masterDtl.QuotaChargeStatement <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "QuotaChargeStatement", masterDtl.QuotaChargeStatement)
        If masterDtl.MSDS <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MSDS", masterDtl.MSDS)
        If masterDtl.TSCA <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "TSCA", masterDtl.TSCA)
        If masterDtl.DropBallTestCert <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "DropBallTestCert", masterDtl.DropBallTestCert)
        If masterDtl.ManMedicalDeviceListing <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManMedicalDeviceListing", masterDtl.ManMedicalDeviceListing)
        If masterDtl.ManFDARegistration <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ManFDARegistration", masterDtl.ManFDARegistration)
        If masterDtl.CopyRightIndemnification <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CopyRightIndemnification", masterDtl.CopyRightIndemnification)
        If masterDtl.FishWildLifeCert <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FishWildLifeCert", masterDtl.FishWildLifeCert)
        If masterDtl.Proposition65LabelReq <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Proposition65LabelReq", masterDtl.Proposition65LabelReq)
        If masterDtl.CCCR <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CCCR", masterDtl.CCCR)
        If masterDtl.FormaldehydeCompliant <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FormaldehydeCompliant", masterDtl.FormaldehydeCompliant)

        'If masterDtl.MinimumOrderQuantity <> Integer.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "MinimumOrderQuantity", masterDtl.MinimumOrderQuantity)
        If masterDtl.ProductIdentifiesAsCosmetic <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "ProductIdentifiesAsCosmetic", masterDtl.ProductIdentifiesAsCosmetic)

        'Populate Retail fields
        If masterDtl.Base1Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDBase", masterDtl.Base1Retail)
        If masterDtl.Base2Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCentral", masterDtl.Base2Retail)
        If masterDtl.TestRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDTest", masterDtl.TestRetail)
        If masterDtl.AlaskaRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDAlaska", masterDtl.AlaskaRetail)
        If masterDtl.CanadaRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCanada", masterDtl.CanadaRetail)
        If masterDtl.High2Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RD0Thru9", masterDtl.High2Retail)
        If masterDtl.High3Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDCalifornia", masterDtl.High3Retail)
        If masterDtl.SmallMarketRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDVillageCraft", masterDtl.SmallMarketRetail)
        If masterDtl.High1Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail9", masterDtl.High1Retail)
        If masterDtl.Base3Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail10", masterDtl.Base3Retail)
        If masterDtl.Low1Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail11", masterDtl.Low1Retail)
        If masterDtl.Low2Retail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail12", masterDtl.Low2Retail)
        If masterDtl.ManhattanRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "Retail13", masterDtl.ManhattanRetail)
        If masterDtl.QuebecRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDQuebec", masterDtl.QuebecRetail)
        If masterDtl.PuertoRicoRetail <> Decimal.MinValue Then ExcelFileHelper.SetCellByMap(ws, itemMap, "RDPuertoRico", masterDtl.PuertoRicoRetail)

        ' copy additional upcs into the spreadsheet
        Dim upcCtr As Integer = 0
        Dim numStaticUPCLocs As Integer = 8
        Dim addUPCsMappingColumn As Models.ItemMappingColumn = itemMap.GetMappingColumn("AdditionalUPCs")
        Dim addUPCsXLCol As String = addUPCsMappingColumn.ExcelColumn
        Dim addUPCsXLBaseRow As Integer = addUPCsMappingColumn.ExcelRow
        For Each upcRec As Models.ItemMasterVendorUPCRecord In masterDtl.AdditionalUPCRecs
            Dim theUPC As String = upcRec.UPC & ""
            If theUPC.Length > 0 Then
                upcCtr += 1
                If upcCtr <= numStaticUPCLocs Then
                    Dim theUPCFieldName As String = "AdditionalUPC" & upcCtr.ToString
                    ExcelFileHelper.SetCellByMap(ws, itemMap, theUPCFieldName, theUPC)
                ElseIf upcCtr > numStaticUPCLocs Then
                    Dim addUPCsOffset As Integer = (upcCtr - numStaticUPCLocs) - 1
                    Dim addUPCsXLActualRow As Integer = addUPCsXLBaseRow + addUPCsOffset
                    ExcelFileHelper.SetCell(ws, addUPCsXLCol, addUPCsXLActualRow, theUPC)
                End If
            End If
        Next

        'Get language settings from SPD_Import_Item_Languages
        Dim languageDT As DataTable = NLData.Michaels.MaintItemMasterData.GetItemLanguages(masterDtl.SKU, masterDtl.VendorNumber)
        If languageDT.Rows.Count > 0 Then
            'For Each language row, set the front end controls
            For Each language As DataRow In languageDT.Rows
                Dim languageTypeID As Integer = DataHelper.SmartValues(language("Language_Type_ID"), "CInt", False)
                Dim pli As String = DataHelper.SmartValues(language("Package_Language_Indicator"), "CStr", False)
                Dim ti As String = DataHelper.SmartValues(language("Translation_Indicator"), "CStr", False)
                Dim descShort As String = DataHelper.SmartValues(language("Description_Short"), "CStr", False)
                Dim descLong As String = DataHelper.SmartValues(language("Description_Long"), "CStr", False)
                Dim exemptEndDateFrench As String = DataHelper.SmartValues(language("Exempt_End_Date"), "CStr", False)
                Select Case languageTypeID
                    Case 1
                        masterDtl.PLIEnglish = pli
                        masterDtl.TIEnglish = ti
                        masterDtl.EnglishShortDescription = descShort
                        masterDtl.EnglishLongDescription = descLong
                    Case 2
                        masterDtl.PLIFrench = pli
                        masterDtl.TIFrench = ti
                        masterDtl.FrenchShortDescription = descShort
                        masterDtl.FrenchLongDescription = descLong
                        masterDtl.ExemptEndDateFrench = exemptEndDateFrench
                    Case 3
                        masterDtl.PLISpanish = pli
                        masterDtl.TISpanish = ti
                        masterDtl.SpanishShortDescription = descShort
                        masterDtl.SpanishLongDescription = descLong
                End Select
            Next
        End If

        'Set Language info
        If masterDtl.CustomsDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "CustomsDescription", masterDtl.CustomsDescription)
        ExcelFileHelper.SetCellByMap(ws, itemMap, "PLIEnglish", IIf(masterDtl.PLIEnglish = "Y", "YES", "NO"))
        ExcelFileHelper.SetCellByMap(ws, itemMap, "PLIFrench", IIf(masterDtl.PLIFrench = "Y", "YES", "NO"))
        'ExcelFileHelper.SetCellByMap(ws, itemMap, "PLISpanish", IIf(masterDtl.PLISpanish = "Y", "YES", "NO"))
        'ExcelFileHelper.SetCellByMap(ws, itemMap, "TIEnglish", IIf(masterDtl.TIEnglish = "Y", "YES", "NO"))
        'ExcelFileHelper.SetCellByMap(ws, itemMap, "TIFrench", IIf(masterDtl.TIFrench = "Y", "YES", "NO"))
        'ExcelFileHelper.SetCellByMap(ws, itemMap, "TISpanish", IIf(masterDtl.TISpanish = "Y", "YES", "NO"))
        If masterDtl.EnglishLongDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnglishLongDescription", masterDtl.EnglishLongDescription)
        If masterDtl.EnglishShortDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "EnglishShortDescription", masterDtl.EnglishShortDescription)
        If masterDtl.FrenchLongDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FrenchLongDescription", masterDtl.FrenchLongDescription)
        If masterDtl.FrenchShortDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "FrenchShortDescription", masterDtl.FrenchShortDescription)
        If masterDtl.SpanishLongDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SpanishLongDescription", masterDtl.SpanishLongDescription)
        If masterDtl.SpanishShortDescription <> String.Empty Then ExcelFileHelper.SetCellByMap(ws, itemMap, "SpanishShortDescription", masterDtl.SpanishShortDescription)

        'Set Private Brand Label 
        If Not String.IsNullOrEmpty(masterDtl.PrivateBrandLabel) Then
            Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
            If pbllvgs IsNot Nothing Then
                For Each lv As ListValue In pbllvgs.ListValues
                    If lv.Value = masterDtl.PrivateBrandLabel Then
                        ExcelFileHelper.SetCellByMap(ws, itemMap, "PrivateBrandLabel", lv.DisplayText)
                    End If
                Next
            End If
        End If

        'Rename worksheet if this is not a child item (this is to fix a silly bug)
        If ws.Name.StartsWith("Child ") And masterDtl.ItemType <> "C" Then
            ws.Name = ws.Name.Replace("Child ", "R-")
        End If

    End Sub

    Private Function GetItemMaintColNumFromDBName(ByVal dbName As String) As Integer
        Dim ret As Integer = -1
        Select Case dbName.ToUpper
            Case "VENDORSTYLENUM"
                ret = 4
            Case "ITEMDESC"
                ret = 5
            Case "EACHESMASTERCASE"
                ret = 6
            Case "EACHESINNERPACK"
                ret = 7
            Case "ALLOWSTOREORDER"
                ret = 8
            Case "INVENTORYCONTROL"
                ret = 9
            Case "AUTOREPLENISH"
                ret = 10
            Case "PREPRICED"
                ret = 11
            Case "PREPRICEDUDA"
                ret = 12
            Case "ITEMCOST", "PRODUCTCOST"
                ret = 13
            Case "EACHCASEHEIGHT"
                ret = 14
            Case "EACHCASEWIDTH"
                ret = 15
            Case "EACHCASELENGTH"
                ret = 16
            Case "EACHCASEWEIGHT"
                ret = 17
            Case "INNERCASEHEIGHT"
                ret = 18
            Case "INNERCASEWIDTH"
                ret = 19
            Case "INNERCASELENGTH"
                ret = 20
            Case "INNERCASEWEIGHT"
                ret = 21
            Case "MASTERCASEHEIGHT"
                ret = 22
            Case "MASTERCASEWIDTH"
                ret = 23
            Case "MASTERCASELENGTH"
                ret = 24
            Case "MASTERCASEWEIGHT"
                ret = 25
            Case "ADDCOUNTRYOFORIGINNAME"
                ' this is the name part of the add country of origin change
                ret = 26
            Case "TAXUDA"
                ret = 27
            Case "TAXVALUEUDA"
                ret = 28
            Case "DISCOUNTABLE"
                ret = 29
            Case "IMPORTBURDEN"
                ret = 30
            Case "SHIPPINGPOINT"
                ret = 31
            Case "PLANOGRAMNAME"
                ret = 32
            Case "PRIVATEBRANDLABEL"
                ret = 33
            Case "PLIENGLISH"
                ret = 34
            Case "PLIFRENCH"
                ret = 35
            ''Case "PLISPANISH"
            '    ret = 36
            'Case "TIFRENCH"
            '    ret = 37
            'Case "TISPANISH"
            '    ret = 38
            Case "CUSTOMSDESCRIPTION"
                ret = 36
            Case "ENGLISHSHORTDESCRIPTION"
                ret = 37
            Case "ENGLISHLONGDESCRIPTION"
                ret = 38
            Case "HARMONIZEDCODENUMBER"
                ret = 39
            Case "CANADAHARMONIZEDCODENUMBER"
                ret = 40
            Case "DETAILINVOICECUSTOMSDESC0"
                ret = 41
            Case "COMPONENTMATERIALBREAKDOWN0"
                ret = 42
            'Case "SUPPTARIFFPERCENT"
            '    ret = 43
            Case "FUMIGATIONCERTIFICATE"
                ret = 43
            Case "PHYTOTEMPORARYSHIPMENT"
                ret = 44
        End Select

        Return ret
    End Function

    Private Function GetItemMaintXLHeaderFromColNum(ByVal colNum As Integer) As String
        Dim ret As String = String.Empty
        Select Case colNum
            Case 4
                ret = "VPN"
            Case 5
                ret = "SKU DESC"
            Case 6
                ret = "EACHES MASTER CASE"
            Case 7
                ret = "EACHES INNER PACK"
            Case 8
                ret = "ALLOW STORE ORDER"
            Case 9
                ret = "INVENTORY CONTROL"
            Case 10
                ret = "AUTO REPLENISH"
            Case 11
                ret = "PREPRICED"
            Case 12
                ret = "PREPRICED UDA"
            Case 13
                ret = "COST"
            Case 14
                ret = "EACH HEIGHT"
            Case 15
                ret = "EACH WIDTH"
            Case 16
                ret = "EACH LENGTH"
            Case 17
                ret = "EACH WEIGHT"
            Case 18
                ret = "INNER PACK HEIGHT"
            Case 19
                ret = "INNER PACK WIDTH"
            Case 20
                ret = "INNER PACK LENGTH"
            Case 21
                ret = "INNER PACK WEIGHT"
            Case 22
                ret = "MASTER CASE HEIGHT"
            Case 23
                ret = "MASTER CASE WIDTH"
            Case 24
                ret = "MASTER CASE LENGTH"
            Case 25
                ret = "MASTER CASE WEIGHT"
            Case 26
                ret = "COUNTRY OF ORIGIN"
            Case 27
                ret = "TAX UDA"
            Case 28
                ret = "TAX VALUE UDA"
            Case 29
                ret = "DISCOUNTABLE"
            Case 30
                ret = "IMPORT BURDEN"
            Case 31
                ret = "SHIPPING POINT"
            Case 32
                ret = "PLANOGRAM NAME"
            Case 33
                ret = "PRIVATE BRAND LABEL"
            Case 34
                ret = "PACKAGE LANGUAGE INDICATOR ENGLISH"
            Case 35
                ret = "PACKAGE LANGUAGE INDICATOR FRENCH"
            'Case 36
            '    ret = "PACKAGE LANGUAGE INDICATOR SPANISH"
            'Case 37
            '    ret = "TRANSLATION INDICATOR FRENCH"
            'Case 38
            '    ret = "TRANSLATION INDICATOR SPANISH"
            Case 36
                ret = "CUSTOMS DESCRIPTION"
            Case 37
                ret = "ENGLISH SHORT DESCRIPTION"
            Case 38
                ret = "ENGLISH LONG DESCRIPTION"
            Case 39
                ret = "HARMONIZED CODE NUMBER"
            Case 40
                ret = "CANADA HARMONIZED CODE NUMBER"
            Case 41
                ret = "DETAIL INVOICE CUSTOMS DESCRIPTION"
            Case 42
                ret = "COMPONENT MATERIAL BREAKDOWN BY %"
            'Case 43
            '    ret = "SUPPLEMENTARY TARIFF PERCENT"
            Case 43
                ret = "PHYTOSANITARY CERTIFICATE"
            Case 44
                ret = "PHYTO TEMPORARY SHIPMENT"
        End Select

        Return ret
    End Function

    Private Function GetMasterDtlValueFromColNum(ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal colNum As Integer) As String
        Dim ret As String = String.Empty
        Select Case colNum
            Case 4
                If Not DataHelper.IsEmpty(masterDtl.VendorStyleNum) Then
                    ret = masterDtl.VendorStyleNum.ToString
                End If
            Case 5
                If Not DataHelper.IsEmpty(masterDtl.ItemDesc) Then
                    ret = masterDtl.ItemDesc.ToString
                End If
            Case 6
                If Not DataHelper.IsEmpty(masterDtl.EachesMasterCase) Then
                    ret = masterDtl.EachesMasterCase.ToString
                End If
            Case 7
                If Not DataHelper.IsEmpty(masterDtl.EachesInnerPack) Then
                    ret = masterDtl.EachesInnerPack.ToString
                End If
            Case 8
                If Not DataHelper.IsEmpty(masterDtl.AllowStoreOrder) Then
                    ret = masterDtl.AllowStoreOrder.ToString
                End If
            Case 9
                If Not DataHelper.IsEmpty(masterDtl.InventoryControl) Then
                    ret = masterDtl.InventoryControl.ToString
                End If
            Case 10
                If Not DataHelper.IsEmpty(masterDtl.AutoReplenish) Then
                    ret = masterDtl.AutoReplenish.ToString
                End If
            Case 11
                If Not DataHelper.IsEmpty(masterDtl.PrePriced) Then
                    ret = masterDtl.PrePriced.ToString
                End If
            Case 12
                If Not DataHelper.IsEmpty(masterDtl.PrePricedUDA) Then
                    ret = masterDtl.PrePricedUDA.ToString
                End If
            Case 13
                If Not DataHelper.IsEmpty(masterDtl.ItemCost) Then
                    ret = masterDtl.ItemCost.ToString
                End If
            Case 14
                If Not DataHelper.IsEmpty(masterDtl.EachCaseHeight) Then
                    ret = masterDtl.EachCaseHeight.ToString
                End If
            Case 15
                If Not DataHelper.IsEmpty(masterDtl.EachCaseWidth) Then
                    ret = masterDtl.EachCaseWidth.ToString
                End If
            Case 16
                If Not DataHelper.IsEmpty(masterDtl.EachCaseLength) Then
                    ret = masterDtl.EachCaseLength.ToString
                End If
            Case 17
                If Not DataHelper.IsEmpty(masterDtl.EachCaseWeight) Then
                    ret = masterDtl.EachCaseWeight.ToString
                End If
            Case 18
                If Not DataHelper.IsEmpty(masterDtl.InnerCaseHeight) Then
                    ret = masterDtl.InnerCaseHeight.ToString
                End If
            Case 19
                If Not DataHelper.IsEmpty(masterDtl.InnerCaseWidth) Then
                    ret = masterDtl.InnerCaseWidth.ToString
                End If
            Case 20
                If Not DataHelper.IsEmpty(masterDtl.InnerCaseLength) Then
                    ret = masterDtl.InnerCaseLength.ToString
                End If
            Case 21
                If Not DataHelper.IsEmpty(masterDtl.InnerCaseWeight) Then
                    ret = masterDtl.InnerCaseWeight.ToString
                End If
            Case 22
                If Not DataHelper.IsEmpty(masterDtl.MasterCaseHeight) Then
                    ret = masterDtl.MasterCaseHeight.ToString
                End If
            Case 23
                If Not DataHelper.IsEmpty(masterDtl.MasterCaseWidth) Then
                    ret = masterDtl.MasterCaseWidth.ToString
                End If
            Case 24
                If Not DataHelper.IsEmpty(masterDtl.MasterCaseLength) Then
                    ret = masterDtl.MasterCaseLength.ToString
                End If
            Case 25
                If Not DataHelper.IsEmpty(masterDtl.MasterCaseWeight) Then
                    ret = masterDtl.MasterCaseWeight.ToString
                End If
            Case 26
                If Not DataHelper.IsEmpty(masterDtl.CountryOfOriginName) Then
                    ret = masterDtl.CountryOfOriginName.ToString
                End If
            Case 27
                If Not DataHelper.IsEmpty(masterDtl.TaxUDA) Then
                    ret = masterDtl.TaxUDA.ToString
                End If
            Case 28
                If Not DataHelper.IsEmpty(masterDtl.TaxValueUDA) Then
                    ret = masterDtl.TaxValueUDA.ToString
                End If
            Case 29
                If Not DataHelper.IsEmpty(masterDtl.Discountable) Then
                    ret = masterDtl.Discountable.ToString
                End If
            Case 30
                If Not DataHelper.IsEmpty(masterDtl.ImportBurden) Then
                    ret = masterDtl.ImportBurden.ToString
                End If
            Case 31
                If Not DataHelper.IsEmpty(masterDtl.ShippingPoint) Then
                    ret = masterDtl.ShippingPoint.ToString
                End If
            Case 32
                If Not DataHelper.IsEmpty(masterDtl.PlanogramName) Then
                    ret = masterDtl.PlanogramName.ToString
                End If
            Case 33
                If Not String.IsNullOrEmpty(masterDtl.PrivateBrandLabel) Then
                    ret = masterDtl.PrivateBrandLabel.ToString
                End If
            Case 34
                If Not String.IsNullOrEmpty(masterDtl.PLIEnglish) Then
                    ret = masterDtl.PLIEnglish.ToString
                End If
            Case 35
                If Not String.IsNullOrEmpty(masterDtl.PLIFrench) Then
                    ret = masterDtl.PLIFrench.ToString
                End If
            'Case 36
            '    If Not String.IsNullOrEmpty(masterDtl.PLISpanish) Then
            '        ret = masterDtl.PLISpanish.ToString
            '    End If
            'Case 37
            '    If Not String.IsNullOrEmpty(masterDtl.TIFrench) Then
            '        ret = masterDtl.TIFrench.ToString
            '    End If
            'Case 38
            '    If Not String.IsNullOrEmpty(masterDtl.TISpanish) Then
            '        ret = masterDtl.TISpanish.ToString
            '    End If
            Case 36
                If Not String.IsNullOrEmpty(masterDtl.CustomsDescription) Then
                    ret = masterDtl.CustomsDescription.ToString
                End If
            Case 37
                If Not String.IsNullOrEmpty(masterDtl.EnglishShortDescription) Then
                    ret = masterDtl.EnglishShortDescription.ToString
                End If
            Case 38
                If Not String.IsNullOrEmpty(masterDtl.EnglishLongDescription) Then
                    ret = masterDtl.EnglishLongDescription.ToString
                End If
            Case 39
                If Not String.IsNullOrEmpty(masterDtl.HarmonizedCodeNumber) Then
                    ret = masterDtl.HarmonizedCodeNumber.ToString
                End If
            Case 40
                If Not String.IsNullOrEmpty(masterDtl.CanadaHarmonizedCodeNumber) Then
                    ret = masterDtl.CanadaHarmonizedCodeNumber.ToString
                End If
            Case 41
                If Not String.IsNullOrEmpty(masterDtl.DetailInvoiceCustomsDesc0) Then
                    ret = masterDtl.DetailInvoiceCustomsDesc0.ToString
                End If
            Case 42
                If Not String.IsNullOrEmpty(masterDtl.ComponentMaterialBreakdown0) Then
                    ret = masterDtl.ComponentMaterialBreakdown0.ToString
                End If
            'Case 43
            '    If Not DataHelper.IsEmpty(masterDtl.SuppTariffPercent) Then
            '        ret = masterDtl.SuppTariffPercent.ToString
            '    End If
            Case 43
                If Not DataHelper.IsEmpty(masterDtl.FumigationCertificate) Then
                    ret = masterDtl.FumigationCertificate.ToString
                End If
            Case 44
                If Not DataHelper.IsEmpty(masterDtl.PhytoTemporaryShipment) Then
                    ret = masterDtl.PhytoTemporaryShipment.ToString
                End If
        End Select
        Return ret
    End Function

    Private Function BuildItemMaintExportFile(ByVal batchID As Integer) As SpreadsheetGear.IWorkbook

        Dim wb As SpreadsheetGear.IWorkbook = Nothing

        Dim exportFile As String = System.Configuration.ConfigurationManager.AppSettings("ITEM_MAINT_EXPORT_FORM")
        exportFile = exportFile.Replace(WebConstants.APP_PATH_REPLACE, (Server.MapPath("")))
        wb = SpreadsheetGear.Factory.GetWorkbook(exportFile)
        Dim ws As SpreadsheetGear.IWorksheet = wb.Sheets(0)

        Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
        Dim dtChanges As DataTable = batchDB.GetItemMaintBatchExport(batchID)
        Dim dtItems As DataTable = batchDB.GetItemMaintBatchItemList(batchID)

        If (Not dtChanges Is Nothing) And (Not dtItems Is Nothing) Then

            ' build the list of changed columns
            Dim colNumList As New System.Collections.Generic.List(Of Integer)
            Dim fastFormatColumns As Integer = 0
            For i As Integer = 0 To dtChanges.Rows.Count - 1
                Dim thisFieldName As String = dtChanges.Rows(i)("field_name").ToString.Trim
                Dim thisFieldColNum As Integer = GetItemMaintColNumFromDBName(thisFieldName)
                If thisFieldColNum <> -1 Then
                    If Not colNumList.Contains(thisFieldColNum) Then
                        colNumList.Add(thisFieldColNum)
                        ' keep count of how many "changed" columns are actually in the fast-file format
                        fastFormatColumns += 1
                    End If
                End If
            Next

            ' fill in the column headers in the output sheet
            If colNumList.Count > 0 Then
                colNumList.Sort()
                Dim currentColIndex As Integer = 3
                For i As Integer = 0 To colNumList.Count - 1
                    Dim thisFieldColNum As Integer = colNumList(i)
                    Dim thisColHeader As String = GetItemMaintXLHeaderFromColNum(thisFieldColNum)
                    ws.Cells(0, currentColIndex).Value = thisColHeader & " (OLD)"
                    ws.Cells(0, currentColIndex + 1).Value = thisColHeader & " (NEW)"
                    currentColIndex += 2
                Next
            End If

            ' build the list of items
            Dim currentRowNum As Integer = -1
            Dim masterDtl As Models.ItemMaintItemDetailFormRecord
            For i As Integer = 0 To dtItems.Rows.Count - 1
                Dim thisIMIID As String = dtItems.Rows(i)("item_maint_items_id").ToString.Trim
                Dim thisSKU As String = dtItems.Rows(i)("Michaels_SKU").ToString.Trim
                Dim thisSKUID As String = dtItems.Rows(i)("SKU_ID").ToString.Trim
                Dim thisVendorNbr As String = dtItems.Rows(i)("Vendor_Number").ToString.Trim
                Dim thisDept As String = dtItems.Rows(i)("department_num").ToString.Trim

                If currentRowNum = -1 Then
                    currentRowNum = 1
                Else
                    currentRowNum += 1
                End If
                ws.Cells(currentRowNum, 0).Value = thisSKU
                ws.Cells(currentRowNum, 1).Value = thisVendorNbr
                ws.Cells(currentRowNum, 2).Value = thisDept

                ' only grab the old and new values if at least 1 fast format column is present somewhere in the batch
                If fastFormatColumns > 0 Then
                    masterDtl = NLData.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(thisIMIID, thisVendorNbr)

                    Dim dtItemChanges As DataTable = batchDB.GetItemMaintBatchChangeList(thisIMIID)
                    If Not dtItemChanges Is Nothing Then
                        For j As Integer = 0 To dtItemChanges.Rows.Count - 1
                            Dim thisFieldName As String = dtItemChanges.Rows(j)("field_name").ToString.Trim
                            Dim thisFieldValue As String = dtItemChanges.Rows(j)("field_value").ToString.Trim
                            Dim thisFieldColNum As Integer = GetItemMaintColNumFromDBName(thisFieldName)
                            If thisFieldColNum <> -1 Then
                                Dim thisColIndex As Integer = colNumList.IndexOf(thisFieldColNum)
                                Dim thisXLColIndex As Integer = (thisColIndex * 2) + 3 '2 for each column, +3 to offset the first three columns
                                Dim thisMasterValue As String = GetMasterDtlValueFromColNum(masterDtl, thisFieldColNum)
                                Select Case thisFieldColNum
                                    Case 13
                                        ws.Cells(currentRowNum, thisXLColIndex).Value = thisMasterValue
                                        ws.Cells(currentRowNum, thisXLColIndex + 1).Value = thisFieldValue
                                        'cell formatting
                                        ws.Cells(currentRowNum, thisXLColIndex).NumberFormat = "0.0000"
                                        ws.Cells(currentRowNum, thisXLColIndex + 1).NumberFormat = "0.0000"
                                    Case 33
                                        'Set Private Brand Label 
                                        If Not String.IsNullOrEmpty(thisMasterValue) Or Not String.IsNullOrEmpty(thisFieldValue) Then
                                            Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
                                            If pbllvgs IsNot Nothing Then
                                                For Each lv As ListValue In pbllvgs.ListValues
                                                    If lv.Value = thisMasterValue Then
                                                        ws.Cells(currentRowNum, thisXLColIndex).Value = lv.DisplayText
                                                    End If
                                                    If lv.Value = thisFieldValue Then
                                                        ws.Cells(currentRowNum, thisXLColIndex + 1).Value = lv.DisplayText
                                                    End If
                                                Next
                                            End If
                                        End If
                                    Case 34, 35, 43, 44  'Case 34, 35, 36, 37, 38, 47, 48
                                        ws.Cells(currentRowNum, thisXLColIndex).Value = FormatYesNo(thisMasterValue)
                                        ws.Cells(currentRowNum, thisXLColIndex + 1).Value = FormatYesNo(thisFieldValue)
                                    Case Else
                                        ws.Cells(currentRowNum, thisXLColIndex).Value = thisMasterValue
                                        ws.Cells(currentRowNum, thisXLColIndex + 1).Value = thisFieldValue
                                End Select
                            End If
                        Next
                    End If

                End If

            Next

        End If

        Return wb

    End Function

    Private Function FormatYesNo(ByVal value As String) As String
        Select Case value.ToUpper
            Case "Y"
                Return "YES"
            Case "N"
                Return "NO"
            Case Else
                Return ""
        End Select
    End Function

End Class
