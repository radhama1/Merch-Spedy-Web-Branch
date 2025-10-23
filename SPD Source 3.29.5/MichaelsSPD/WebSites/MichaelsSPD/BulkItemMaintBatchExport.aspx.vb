Imports System
Imports System.Data
Imports System.IO
Imports SpreadsheetGear

Imports WebConstants
Imports NovaLibra.Coral.SystemFrameworks
Imports NovaLibra.Common.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class BulkItemMaintBatchExport
    Inherits MichaelsBasePage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Dim batchID As Long = DataHelper.SmartValues(Request("bid"), "CInt", False, 0)
        If batchID <= 0 Then
            Response.Redirect("default.aspx")
        End If

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
        Try

            Dim wb As SpreadsheetGear.IWorkbook = Nothing
            wb = BuildBIMExportFile(batchID)

            
            If Not wb Is Nothing Then
                ' success! export the workbook
                Dim dateNow As Date = Now()
                Dim fName As String = "BulkItemMaint_" & batchID.ToString() & "_" & dateNow.ToString("yyyyMMdd") & ".xls"
                Dim memFile As New MemoryStream()
                wb.SaveToStream(memFile, FileFormat.Excel8)
                memFile.WriteTo(Response.OutputStream)
                memFile = Nothing
                Response.ContentType = "application/vnd.ms-excel"
                Response.AddHeader("content-disposition", ("attachment;filename=" & fName))
                HttpContext.Current.ApplicationInstance.CompleteRequest()
            Else
                ' the query failed to retrieve any data
                lblFeedback.Text = "This batch could not be formatted."
                lblFeedback.Visible = True
                lnkReturn.Text = "Click here to go back."
                lnkReturn.Visible = True
            End If
        Catch ex As Exception
            Dim s As String = ex.Message
        End Try
    End Sub

    Private Function BuildBIMExportFile(ByVal batchID As Long) As IWorkbook
        'Initialize Workbook and Worksheet
        Dim wb As SpreadsheetGear.IWorkbook = SpreadsheetGear.Factory.GetWorkbook()
        Dim ws As SpreadsheetGear.IWorksheet = wb.Worksheets("Sheet1")

        'Get Batch Information
        Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
        Dim batch As Models.BatchRecord = batchDB.GetBatchRecord(batchID)
        Dim batchType As Integer = batch.BatchTypeID

        'Get All Changes for the Batch
        Dim dtChanges As DataTable = batchDB.GetItemMaintBatchExport(batch.ID)
        'Get All Items on the Batch
        Dim dtItems As DataTable = batchDB.GetItemMaintBatchItemList(batch.ID)
        'Get All Column Display Names used by this Batch
        Dim columnDisplayNames As System.Collections.Generic.List(Of NovaLibra.Coral.SystemFrameworks.Michaels.ColumnDisplayName) = NovaLibra.Coral.Data.Michaels.ColumDisplayNameData.GeColumnDisplayNameByWorkflowID(WebConstants.WorkflowType.BulkItemMaint)

        'Populate Base Header Column Names
        ws.Cells(0, 0).Value = "SKU"
        ws.Cells(0, 1).Value = "Vendor Number"

        If (Not dtChanges Is Nothing) And (Not dtItems Is Nothing) Then
           
            ' fill in the column headers in the output sheet
            Dim currentColIndex As Integer = 2
            Dim columns As New System.Collections.Generic.Dictionary(Of String, Integer)
            For i As Integer = 0 To dtChanges.Rows.Count - 1
                Dim thisFieldName As String = dtChanges.Rows(i)("field_name").ToString.Trim
                If Not columns.ContainsKey(thisFieldName) Then
                    columns.Add(thisFieldName, currentColIndex)
                    'Find the Column Header Name
                    Dim colHeaderName As String = thisFieldName
                    Dim cdn As NovaLibra.Coral.SystemFrameworks.Michaels.ColumnDisplayName = columnDisplayNames.Find(Function(x) x.ColumnName = thisFieldName)
                    If cdn IsNot Nothing Then
                        colHeaderName = cdn.DisplayName.Replace("<br/>", " ").Replace("<br />", " ")
                    End If
                    ws.Cells(0, currentColIndex).Value = colHeaderName & " (OLD)"
                    ws.Cells(0, currentColIndex + 1).Value = colHeaderName & " (NEW)"
                    currentColIndex += 2
                End If
            Next

            ' build the list of items
            Dim currentRowNum As Integer = 1
            Dim masterDtl As Models.ItemMaintItemDetailFormRecord
            For i As Integer = 0 To dtItems.Rows.Count - 1
                Dim thisIMIID As String = dtItems.Rows(i)("item_maint_items_id").ToString.Trim
                Dim thisSKU As String = dtItems.Rows(i)("Michaels_SKU").ToString.Trim
                Dim thisSKUID As String = dtItems.Rows(i)("SKU_ID").ToString.Trim
                Dim thisVendorNbr As String = dtItems.Rows(i)("Vendor_Number").ToString.Trim

                ws.Cells(currentRowNum, 0).Value = thisSKU
                ws.Cells(currentRowNum, 1).Value = thisVendorNbr

                masterDtl = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(thisIMIID, thisVendorNbr)

                Dim dtItemChanges As DataTable = batchDB.GetItemMaintBatchChangeList(thisIMIID)
                If Not dtItemChanges Is Nothing Then
                    For j As Integer = 0 To dtItemChanges.Rows.Count - 1
                        Dim thisFieldName As String = dtItemChanges.Rows(j)("field_name").ToString.Trim
                        Dim thisFieldValue As String = dtItemChanges.Rows(j)("field_value").ToString.Trim

                        'If the modified field is in the list of header columns, then get the column index and populate the OLD and NEW values
                        If columns.ContainsKey(thisFieldName) Then
                            Dim thisFieldColNum As Integer = columns.Item(thisFieldName)
                            Dim currentCDN As NovaLibra.Coral.SystemFrameworks.Michaels.ColumnDisplayName = columnDisplayNames.Find(Function(x) x.ColumnName = thisFieldName)
                            Dim thisMasterValue As String = GetMasterDtlValueFromFieldName(masterDtl, thisFieldName)
                            If currentCDN IsNot Nothing Then
                                'Only output a value for the field if it matches the field for the item type
                                If ((currentCDN.ColumnType = "D" And masterDtl.VendorType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemType.Domestic) Or _
                                    (currentCDN.ColumnType = "I" And masterDtl.VendorType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemType.Import) Or _
                                    (currentCDN.ColumnType = "X")) Then

                                    If currentCDN.ColumnFormat = "formatnumber4" Then
                                        ws.Cells(currentRowNum, thisFieldColNum).Value = thisMasterValue
                                        ws.Cells(currentRowNum, thisFieldColNum + 1).Value = thisFieldValue
                                        'cell formatting
                                        ws.Cells(currentRowNum, thisFieldColNum).NumberFormat = "0.0000"
                                        ws.Cells(currentRowNum, thisFieldColNum + 1).NumberFormat = "0.0000"
                                    ElseIf thisFieldName = "PrivateBrandLabel" Then
                                        'Set Private Brand Label 
                                        If Not String.IsNullOrEmpty(thisMasterValue) Or Not String.IsNullOrEmpty(thisFieldValue) Then
                                            Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
                                            If pbllvgs IsNot Nothing Then
                                                For Each lv As ListValue In pbllvgs.ListValues
                                                    If lv.Value = thisMasterValue Then
                                                        ws.Cells(currentRowNum, thisFieldColNum).Value = lv.DisplayText
                                                    End If
                                                    If lv.Value = thisFieldValue Then
                                                        ws.Cells(currentRowNum, thisFieldColNum + 1).Value = lv.DisplayText
                                                    End If
                                                Next
                                            End If
                                        End If
                                    ElseIf currentCDN.ColumnFormatString = "YESNO" Then
                                        ws.Cells(currentRowNum, thisFieldColNum).Value = FormatYesNo(thisMasterValue)
                                        ws.Cells(currentRowNum, thisFieldColNum + 1).Value = FormatYesNo(thisFieldValue)
                                    Else
                                        ws.Cells(currentRowNum, thisFieldColNum).Value = thisMasterValue
                                        ws.Cells(currentRowNum, thisFieldColNum + 1).Value = thisFieldValue
                                    End If
                                End If
                            End If
                        End If
                    Next
                End If

                currentRowNum += 1
            Next
        End If

        Return wb
    End Function

    Private Function GetMasterDtlValueFromFieldName(ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal columnName As String) As String
        Dim ret As String = String.Empty

        Select Case columnName.ToUpper
            Case "VENDORSTYLENUM"
                ret = masterDtl.VendorStyleNum
            Case "ITEMDESC"
                ret = masterDtl.ItemDesc
            Case "PRIVATEBRANDLABEL"
                ret = masterDtl.PrivateBrandLabel
            Case "EACHESMASTERCASE"
                ret = masterDtl.EachesMasterCase
            Case "EACHESINNERPACK"
                ret = masterDtl.EachesInnerPack
            Case "ALLOWSTOREORDER"
                ret = masterDtl.AllowStoreOrder
            Case "INVENTORYCONTROL"
                ret = masterDtl.InventoryControl
            Case "DISCOUNTABLE"
                ret = masterDtl.Discountable
            Case "AUTOREPLENISH"
                ret = masterDtl.AutoReplenish
            Case "PREPRICED"
                ret = masterDtl.PrePriced
            Case "PREPRICEDUDA"
                ret = masterDtl.PrePricedUDA
            Case "ITEMCOST"
                ret = masterDtl.ItemCost
            Case "FOBSHIPPINGPOINT"
                ret = masterDtl.FOBShippingPoint
            Case "PRODUCTCOST"
                ret = masterDtl.ProductCost
            Case "INNERCASEHEIGHT"
                ret = masterDtl.InnerCaseHeight
            Case "INNERCASEWIDTH"
                ret = masterDtl.InnerCaseWidth
            Case "INNERCASELENGTH"
                ret = masterDtl.InnerCaseLength
            Case "INNERCASEWEIGHT"
                ret = masterDtl.InnerCaseWeight
            Case "MASTERCASEHEIGHT"
                ret = masterDtl.MasterCaseHeight
            Case "MASTERCASEWIDTH"
                ret = masterDtl.MasterCaseWidth
            Case "MASTERCASELENGTH"
                ret = masterDtl.MasterCaseLength
            Case "MASTERCASEWEIGHT"
                ret = masterDtl.MasterCaseWeight
            Case "COUNTRYOFORIGINNAME"
                ret = masterDtl.CountryOfOriginName
            Case "TAXUDA"
                ret = masterDtl.TaxUDA
            Case "TAXVALUEUDA"
                ret = masterDtl.TaxValueUDA
            Case "DUTYPERCENT"
                ret = masterDtl.DutyPercent
            Case "DUTYAMOUNT"
                ret = masterDtl.DutyAmount
            Case "ADDITIONALDUTYCOMMENT"
                ret = masterDtl.AdditionalDutyComment
            Case "ADDITIONALDUTYAMOUNT"
                ret = masterDtl.AdditionalDutyAmount
            Case "SUPPTARIFFPERCENT"
                ret = masterDtl.SuppTariffPercent
            Case "SUPPTARIFFAMOUNT"
                ret = masterDtl.SuppTariffAmount
            Case "OCEANFREIGHTAMOUNT"
                ret = masterDtl.OceanFreightAmount
            Case "OCEANFREIGHTCOMPUTEDAMOUNT"
                ret = masterDtl.OceanFreightComputedAmount
            Case "AGENTCOMMISSIONPERCENT"
                ret = masterDtl.AgentCommissionPercent
            Case "AGENTCOMMISSIONAMOUNT"
                ret = masterDtl.AgentCommissionAmount
            Case "OTHERIMPORTCOSTSPERCENT"
                ret = masterDtl.OtherImportCostsPercent
            Case "OTHERIMPORTCOSTSAMOUNT"
                ret = masterDtl.OtherImportCostsAmount
            Case "IMPORTBURDEN"
                ret = masterDtl.ImportBurden
            Case "WAREHOUSELANDEDCOST"
                ret = masterDtl.WarehouseLandedCost
            Case "OUTBOUNDFREIGHT"
                ret = masterDtl.OutboundFreight
            Case "NINEPERCENTWHSECHANGE"
                ret = masterDtl.NinePercentWhseCharge
            Case "TOTALSTORELANDEDCOST"
                ret = masterDtl.TotalStoreLandedCost
            Case "SHIPPINGPOINT"
                ret = masterDtl.ShippingPoint
            Case "PLANOGRAMNAME"
                ret = masterDtl.PlanogramName
            Case "HAZARDOUS"
                ret = masterDtl.Hazardous
            Case "HAZARDOUSFLAMMABLE"
                ret = masterDtl.HazardousFlammable
            Case "HAZARDOUSCONTAINERTYPE"
                ret = masterDtl.HazardousContainerType
            Case "HAZARDOUSCONTAINERSIZE"
                ret = masterDtl.HazardousContainerSize
            Case "HAZARDOUSMSDSUOM"
                ret = masterDtl.HazardousMSDSUOM
            Case "HAZARDOUSMANUFACTURERNAME"
                ret = masterDtl.HazardousManufacturerName
            Case "HAZARDOUSMANUFACTURERCITY"
                ret = masterDtl.HazardousManufacturerCity
            Case "HAZARDOUSMANUFACTURERSTATE"
                ret = masterDtl.HazardousManufacturerState
            Case "HAZARDOUSMANUFACTURERPHONE"
                ret = masterDtl.HazardousManufacturerPhone
            Case "HAZARDOUSMANUFACTURERCOUNTRY"
                ret = masterDtl.HazardousManufacturerCountry
            Case "PLIFRENCH"
                ret = masterDtl.PLIFrench
            Case "PLISPANISH"
                ret = masterDtl.PLISpanish
            Case "TIFRENCH"
                ret = masterDtl.TIFrench
            Case "TISPANISH"
                ret = masterDtl.TISpanish
            Case "CUSTOMSDESCRIPTION"
                ret = masterDtl.CustomsDescription
            Case "ENGLISHSHORTDESCRIPTION"
                ret = masterDtl.EnglishShortDescription
            Case "ENGLISHLONGDESCRIPTION"
                ret = masterDtl.EnglishLongDescription
            Case "HARMONIZEDCODENUMBER"
                ret = masterDtl.HarmonizedCodeNumber
            Case "COMPONENTMATERIALBREAKDOWN0"
                ret = masterDtl.ComponentMaterialBreakdown0
            Case "COMPONENTCONSTRUCTIONMETHOD"
                ret = masterDtl.ComponentConstructionMethod
            Case "CoinBattery"
                ret = masterDtl.CoinBattery
            'Case "TSSA"
            '    ret = masterDtl.TSSA
            Case "CSA"
                ret = masterDtl.CSA
            Case "UL"
                ret = masterDtl.UL
            Case "LICENCEAGREEMENT"
                ret = masterDtl.LicenceAgreement
            Case "FUMIGATIONCERTIFICATE"
                ret = masterDtl.FumigationCertificate
            Case "KILNDRIEDCERTIFICATE"
                ret = masterDtl.KILNDriedCertificate
            Case "CHINACOMINSPECNUMANDCCIBSTICKERS"
                ret = masterDtl.ChinaComInspecNumAndCCIBStickers
            Case "ORIGINALVISA"
                ret = masterDtl.OriginalVisa
            Case "TEXTILEDECLARATIONMIDCODE"
                ret = masterDtl.TextileDeclarationMidCode
            Case "QUOTACHARGESTATEMENT"
                ret = masterDtl.QuotaChargeStatement
            Case "MSDS"
                ret = masterDtl.MSDS
            Case "TSCA"
                ret = masterDtl.TSCA
            Case "DROPBALLTESTCERT"
                ret = masterDtl.DropBallTestCert
            Case "MANMEDICALDEVICELISTING"
                ret = masterDtl.ManMedicalDeviceListing
            Case "MANFDAREGISTRATION"
                ret = masterDtl.ManFDARegistration
            Case "COPYRIGHTIDEMNIFICATION"
                ret = masterDtl.CopyRightIndemnification
            Case "FISHWILDLIVECERT"
                ret = masterDtl.FishWildLifeCert
            Case "PROPOSITION65LABELREQ"
                ret = masterDtl.Proposition65LabelReq
            Case "CCCR"
                ret = masterDtl.CCCR
            Case "FORMALDEHYDECOMPLIANT"
                ret = masterDtl.FormaldehydeCompliant
            Case "EACHCASEHEIGHT"
                ret = masterDtl.EachCaseHeight
            Case "EACHCASEWIDTH"
                ret = masterDtl.EachCaseWidth
            Case "EACHCASELENGTH"
                ret = masterDtl.EachCaseLength
            Case "EACHCASEWEIGHT"
                ret = masterDtl.EachCaseWeight
            Case "CANADAHARMONIZEDCODENUMBER"
                ret = masterDtl.CanadaHarmonizedCodeNumber
            Case "STOCKINGSTRATEGYCODE"
                ret = masterDtl.StockingStrategyCode
        End Select

        If IsNumeric(ret) Then
            If ret = System.Decimal.MinValue Then
                ret = ""
            End If
        End If

        Return ret
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

