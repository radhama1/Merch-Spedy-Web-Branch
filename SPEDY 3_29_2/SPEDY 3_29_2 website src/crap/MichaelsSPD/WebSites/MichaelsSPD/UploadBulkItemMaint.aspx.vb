Imports System
Imports System.Configuration
Imports System.Data
Imports System.Diagnostics
Imports System.IO
Imports Microsoft.VisualBasic
Imports System.Data.SqlClient
Imports SpreadsheetGear
Imports System.Collections.Generic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports Frameworks = NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports ItemHelper

Partial Class UploadBulkItemMaint
    Inherits MichaelsBasePage


#Region " Data and Properties "

    Private _refreshParent As Boolean = False
    Private _sendToDefault As Boolean = False
    Private _useSessionVendor As Boolean = False
    Private _xlFileName As String = String.Empty

    Private _feedbackMsg As String = String.Empty
    Private _cancelBatch As Boolean = False

    Private _validSKUList As List(Of SkuList)
    Private _table As Frameworks.MetadataTable = Nothing

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

#End Region


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
            lblFeedback.Text = ""
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
        If Session("vendorId") <> "" Then
            UseSessionVendor = True
        End If

        _table = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)

    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click

        _cancelBatch = False
        ClearFeedback()

        ' save the imported file
        Dim theFile As HttpPostedFile = Request.Files.Item("importFile")
        If Not theFile Is Nothing Then
            Try
                If ExcelFileHelper.IsValidFileType(theFile.FileName) Then

                    ' extract the file name for the audit trail
                    Dim slashPos As Integer = theFile.FileName.LastIndexOf("\")
                    If slashPos > -1 Then
                        _xlFileName = theFile.FileName.Substring(slashPos + 1)
                    Else
                        _xlFileName = theFile.FileName
                    End If

                    ' set up the ws object
                    Dim wb As SpreadsheetGear.IWorkbook = SpreadsheetGear.Factory.GetWorkbookSet().Workbooks.OpenFromStream(theFile.InputStream)
                    Dim ws As IWorksheet = wb.Worksheets(0)
                    If ws Is Nothing Then
                        Throw New SPEDYUploadException("ERROR: Worksheet not found. <br/>Please contact the system administrator and verify that you are using the latest upload template.")
                    End If

                    UploadBIM(ws)

                    FlushFeedback()
                Else
                    ' ERROR: invalid file type
                    ClearFeedback("Please upload a valid Excel spreadsheet (*.xls)")
                    FlushFeedback()
                End If

            Catch uploadEx As SPEDYUploadException
                ClearFeedback(uploadEx.Message)
                FlushFeedback()

            Catch ex As Exception
                ' ERROR: invalid file type
                ClearFeedback(WebConstants.IMPORT_ERROR_UNKNOWN)
                FlushFeedback()

            End Try

            ' make buttons visible
            panelButtons.Visible = True
        End If
    End Sub


    Private Sub CompareBIMUploadFields(ByVal itemMaintHeaderID As Integer, ByVal item As Models.ItemMaintUploadChangeRecord, ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal userID As Integer)

        FieldComparison(Left(item.VPN.ToUpper, 20), masterDtl.VendorStyleNum, itemMaintHeaderID, "VendorStyleNum", userID, True)
        FieldComparison(Left(item.ItemDesc, 30), masterDtl.ItemDesc, itemMaintHeaderID, "ItemDesc", userID, True)
        FieldComparison(item.PrivateBrandLabel, masterDtl.PrivateBrandLabel, itemMaintHeaderID, "PrivateBrandLabel", userID, True)
        FieldComparison(Left(item.AllowStoreOrder, 50), masterDtl.AllowStoreOrder, itemMaintHeaderID, "AllowStoreOrder", userID, True)
        FieldComparison(Left(item.InventoryControl, 50), masterDtl.InventoryControl, itemMaintHeaderID, "InventoryControl", userID, True)
        FieldComparison(Left(item.Discountable, 1), masterDtl.Discountable, itemMaintHeaderID, "Discountable", userID, True)
        FieldComparison(Left(item.AutoReplenish, 50), masterDtl.AutoReplenish, itemMaintHeaderID, "AutoReplenish", userID, True)
        FieldComparison(Left(item.PrePriced, 1), masterDtl.PrePriced, itemMaintHeaderID, "PrePriced", userID, True)
        FieldComparison(item.PrePricedUDA, masterDtl.PrePricedUDA, itemMaintHeaderID, "PrePricedUDA", userID, True)
        FieldComparison(item.TaxUDA, masterDtl.TaxUDA, itemMaintHeaderID, "TaxUDA", userID, True)
        FieldComparison(item.TaxValueUDA, masterDtl.TaxValueUDA, itemMaintHeaderID, "TaxValueUDA", userID, True)
        FieldComparison(Left(item.PlanogramName, 100), masterDtl.PlanogramName, itemMaintHeaderID, "PlanogramName", userID, True)

        FieldComparison(Left(item.Hazardous, 1), masterDtl.Hazardous, itemMaintHeaderID, "Hazardous", userID, True)
        FieldComparison(Left(item.HazardousContainerType, 20), masterDtl.HazardousContainerType, itemMaintHeaderID, "HazardousContainerType", userID, True)
        FieldComparison(item.HazardousContainerSize, masterDtl.HazardousContainerSize, itemMaintHeaderID, "HazardousContainerSize", userID, True)
        FieldComparison(Left(item.HazardousFlammable, 1), masterDtl.HazardousFlammable, itemMaintHeaderID, "HazardousFlammable", userID, True)
        FieldComparison(Left(item.HazardousMSDSUOM, 20), masterDtl.HazardousMSDSUOM, itemMaintHeaderID, "HazardousMSDSUOM", userID, True)
        FieldComparison(Left(item.HazardousManufacturerName, 100), masterDtl.HazardousManufacturerName, itemMaintHeaderID, "HazardousManufacturerName", userID, True)
        FieldComparison(Left(item.HazardousManufacturerCity, 50), masterDtl.HazardousManufacturerCity, itemMaintHeaderID, "HazardousManufacturerCity", userID, True)
        FieldComparison(Left(item.HazardousManufacturerState, 50), masterDtl.HazardousManufacturerState, itemMaintHeaderID, "HazardousManufacturerState", userID, True)
        FieldComparison(Left(item.HazardousManufacturerPhone, 20), masterDtl.HazardousManufacturerPhone, itemMaintHeaderID, "HazardousManufacturerPhone", userID, True)
        FieldComparison(Left(item.HazardousManufacturerCountry, 100), masterDtl.HazardousManufacturerCountry, itemMaintHeaderID, "HazardousManufacturerCountry", userID, True)

        FieldComparison(Left(item.PLIFrench, 1), masterDtl.PLIFrench, itemMaintHeaderID, "PLIFrench", userID, True)
        FieldComparison(Left(item.PLISpanish, 1), masterDtl.PLISpanish, itemMaintHeaderID, "PLISpanish", userID, True)
        FieldComparison(Left(item.TIFrench, 1), masterDtl.TIFrench, itemMaintHeaderID, "TIFrench", userID, True)
        FieldComparison(Left(item.CustomsDescription, 255), masterDtl.CustomsDescription, itemMaintHeaderID, "CustomsDescription", userID, True)
        FieldComparison(Left(item.EnglishShortDescription, 20), masterDtl.EnglishShortDescription, itemMaintHeaderID, "EnglishShortDescription", userID, True)
        FieldComparison(Left(item.EnglishLongDescription, 150), masterDtl.EnglishLongDescription, itemMaintHeaderID, "EnglishLongDescription", userID, True)
        FieldComparison(Left(item.HarmonizedCodeNumber, 100), masterDtl.HarmonizedCodeNumber, itemMaintHeaderID, "HarmonizedCodeNumber", userID, True)
        FieldComparison(Left(item.CanadaHarmonizedCodeNumber, 100), masterDtl.CanadaHarmonizedCodeNumber, itemMaintHeaderID, "CanadaHarmonizedCodeNumber", userID, True)

        Dim runCalc As Boolean = False
        runCalc = runCalc Or FieldComparison(item.EachesMasterCase, masterDtl.EachesMasterCase, itemMaintHeaderID, "EachesMasterCase", userID, True)
        runCalc = runCalc Or FieldComparison(item.EachesInnerPack, masterDtl.EachesInnerPack, itemMaintHeaderID, "EachesInnerPack", userID, True)

        runCalc = runCalc Or FieldComparison(item.EachPackLength, masterDtl.EachCaseLength, itemMaintHeaderID, "EachCaseLength", userID, True)
        runCalc = runCalc Or FieldComparison(item.EachPackWidth, masterDtl.EachCaseWidth, itemMaintHeaderID, "EachCaseWidth", userID, True)
        runCalc = runCalc Or FieldComparison(item.EachPackHeight, masterDtl.EachCaseHeight, itemMaintHeaderID, "EachCaseHeight", userID, True)
        runCalc = runCalc Or FieldComparison(item.EachPackWeight, masterDtl.EachCaseWeight, itemMaintHeaderID, "EachCaseWeight", userID, True)

        runCalc = runCalc Or FieldComparison(item.InnerPackLength, masterDtl.InnerCaseLength, itemMaintHeaderID, "InnerCaseLength", userID, True)
        runCalc = runCalc Or FieldComparison(item.InnerPackWidth, masterDtl.InnerCaseWidth, itemMaintHeaderID, "InnerCaseWidth", userID, True)
        runCalc = runCalc Or FieldComparison(item.InnerPackHeight, masterDtl.InnerCaseHeight, itemMaintHeaderID, "InnerCaseHeight", userID, True)
        runCalc = runCalc Or FieldComparison(item.MasterCaseLength, masterDtl.MasterCaseLength, itemMaintHeaderID, "MasterCaseLength", userID, True)
        runCalc = runCalc Or FieldComparison(item.MasterCaseWidth, masterDtl.MasterCaseWidth, itemMaintHeaderID, "MasterCaseWidth", userID, True)
        runCalc = runCalc Or FieldComparison(item.MasterCaseHeight, masterDtl.MasterCaseHeight, itemMaintHeaderID, "MasterCaseHeight", userID, True)
        runCalc = runCalc Or FieldComparison(item.MasterCaseWeight, masterDtl.MasterCaseWeight, itemMaintHeaderID, "MasterCaseWeight", userID, True)

        If masterDtl.VendorType = Models.ItemType.Domestic Then
            'Domestic Only fields
            FieldComparison(item.InnerPackWeight, masterDtl.InnerCaseWeight, itemMaintHeaderID, "InnerCaseWeight", userID, True)

            runCalc = runCalc Or FieldComparison(item.ItemCost, masterDtl.ItemCost, itemMaintHeaderID, "ItemCost", userID, True)

            FieldComparison(item.ComponentMaterialBreakdown, masterDtl.ComponentMaterialBreakdown0, itemMaintHeaderID, "ComponentMaterialBreakdown0", userID, True)
            FieldComparison(item.ComponentConstructionMethod, masterDtl.ComponentConstructionMethod0, itemMaintHeaderID, "ComponentConstructionMethod0", userID, True)
        Else
            'Import Only fields
            FieldComparison(Left(item.AdditionalDutyComment, 100), masterDtl.AdditionalDutyComment, itemMaintHeaderID, "AdditionalDutyComment", userID, True)
            FieldComparison(Left(item.ShippingPoint.ToUpper, 100), masterDtl.ShippingPoint.ToUpper, itemMaintHeaderID, "ShippingPoint", userID, True)

            FieldComparison(Left(item.CoinBattery, 5), masterDtl.CoinBattery, itemMaintHeaderID, "CoinBattery", userID, True)
            'FieldComparison(Left(item.TSSA, 5), masterDtl.TSSA, itemMaintHeaderID, "TSSA", userID, True)
            FieldComparison(Left(item.CSA, 5), masterDtl.CSA, itemMaintHeaderID, "CSA", userID, True)
            FieldComparison(Left(item.UL, 5), masterDtl.UL, itemMaintHeaderID, "UL", userID, True)
            FieldComparison(Left(item.LicenceAgreement, 5), masterDtl.LicenceAgreement, itemMaintHeaderID, "LicenceAgreement", userID, True)
            FieldComparison(Left(item.FumigationCertificate, 5), masterDtl.FumigationCertificate, itemMaintHeaderID, "FumigationCertificate", userID, True)
            FieldComparison(Left(item.KILNDriedCertificate, 5), masterDtl.KILNDriedCertificate, itemMaintHeaderID, "KILNDriedCertificate", userID, True)
            FieldComparison(Left(item.ChinaComInspecNumAndCCIBStickers, 5), masterDtl.ChinaComInspecNumAndCCIBStickers, itemMaintHeaderID, "ChinaComInspecNumAndCCIBStickers", userID, True)
            FieldComparison(Left(item.OriginalVisa, 5), masterDtl.OriginalVisa, itemMaintHeaderID, "OriginalVisa", userID, True)
            FieldComparison(Left(item.TextileDeclarationMidCode, 5), masterDtl.TextileDeclarationMidCode, itemMaintHeaderID, "TextileDeclarationMidCode", userID, True)
            FieldComparison(Left(item.QuotaChargeStatement, 5), masterDtl.QuotaChargeStatement, itemMaintHeaderID, "QuotaChargeStatement", userID, True)
            FieldComparison(Left(item.MSDS, 5), masterDtl.MSDS, itemMaintHeaderID, "MSDS", userID, True)
            FieldComparison(Left(item.TSCA, 5), masterDtl.TSCA, itemMaintHeaderID, "TSCA", userID, True)
            FieldComparison(Left(item.DropBallTestCert, 5), masterDtl.DropBallTestCert, itemMaintHeaderID, "DropBallTestCert", userID, True)
            FieldComparison(Left(item.ManMedicalDeviceListing, 5), masterDtl.ManMedicalDeviceListing, itemMaintHeaderID, "ManMedicalDeviceListing", userID, True)
            FieldComparison(Left(item.ManFDARegistration, 5), masterDtl.ManFDARegistration, itemMaintHeaderID, "ManFDARegistration", userID, True)
            FieldComparison(Left(item.CopyRightIndemnification, 5), masterDtl.CopyRightIndemnification, itemMaintHeaderID, "CopyRightIndemnification", userID, True)
            FieldComparison(Left(item.FishWildLifeCert, 5), masterDtl.FishWildLifeCert, itemMaintHeaderID, "FishWildLifeCert", userID, True)
            FieldComparison(Left(item.Proposition65LabelReq, 5), masterDtl.Proposition65LabelReq, itemMaintHeaderID, "Proposition65LabelReq", userID, True)
            FieldComparison(Left(item.CCCR, 5), masterDtl.CCCR, itemMaintHeaderID, "CCCR", userID, True)
            FieldComparison(Left(item.FormaldehydeCompliant, 5), masterDtl.FormaldehydeCompliant, itemMaintHeaderID, "FormaldehydeCompliant", userID, True)

            runCalc = runCalc Or FieldComparison(item.ProductCost, masterDtl.ProductCost, itemMaintHeaderID, "ProductCost", userID, True)
            runCalc = runCalc Or FieldComparison(item.DutyPercent, masterDtl.DutyPercent, itemMaintHeaderID, "DutyPercent", userID, True)

            runCalc = runCalc Or FieldComparison(item.SuppTariffPercent, masterDtl.SuppTariffPercent, itemMaintHeaderID, "SuppTariffPercent", userID, True)

            runCalc = runCalc Or FieldComparison(item.OceanFreightAmount, masterDtl.OceanFreightAmount, itemMaintHeaderID, "OceanFreightAmount", userID, True)
            runCalc = runCalc Or FieldComparison(item.AgentCommissionPercent, masterDtl.AgentCommissionPercent, itemMaintHeaderID, "AgentCommissionPercent", userID, True)
            runCalc = runCalc Or FieldComparison(item.AdditionalDutyAmount, masterDtl.AdditionalDutyAmount, itemMaintHeaderID, "AdditionalDutyAmount", userID, True)
            
            Dim strTemp() As String = Split(item.ComponentMaterialBreakdown, WebConstants.MULTILINE_DELIM)
            FieldComparisonMultiLine(0, strTemp, masterDtl.ComponentMaterialBreakdown0, itemMaintHeaderID, "ComponentMaterialBreakdown0", userID)
            FieldComparisonMultiLine(1, strTemp, masterDtl.ComponentMaterialBreakdown1, itemMaintHeaderID, "ComponentMaterialBreakdown1", userID)
            FieldComparisonMultiLine(2, strTemp, masterDtl.ComponentMaterialBreakdown2, itemMaintHeaderID, "ComponentMaterialBreakdown2", userID)
            FieldComparisonMultiLine(3, strTemp, masterDtl.ComponentMaterialBreakdown3, itemMaintHeaderID, "ComponentMaterialBreakdown3", userID)
            FieldComparisonMultiLine(4, strTemp, masterDtl.ComponentMaterialBreakdown4, itemMaintHeaderID, "ComponentMaterialBreakdown4", userID)

            strTemp = Split(item.ComponentConstructionMethod, WebConstants.MULTILINE_DELIM)
            FieldComparisonMultiLine(0, strTemp, masterDtl.ComponentConstructionMethod0, itemMaintHeaderID, "ComponentConstructionMethod0", userID)
            FieldComparisonMultiLine(1, strTemp, masterDtl.ComponentConstructionMethod1, itemMaintHeaderID, "ComponentConstructionMethod1", userID)
            FieldComparisonMultiLine(2, strTemp, masterDtl.ComponentConstructionMethod2, itemMaintHeaderID, "ComponentConstructionMethod2", userID)
            FieldComparisonMultiLine(3, strTemp, masterDtl.ComponentConstructionMethod3, itemMaintHeaderID, "ComponentConstructionMethod3", userID)
        End If

        'Perform Comparision on Country of Origin Name
        If item.CountryOfOrigin.Length > 0 Then
            CountryOfOriginComparison(item.CountryOfOrigin, masterDtl, itemMaintHeaderID)
        End If

        ' Perform Calculations to see if Calculated fields changed
        If runCalc Then

            Dim table As Frameworks.MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
            Dim record As Models.ItemMaintItemDetailFormRecord = masterDtl.Clone    ' Get a clone of the record for comparisions
            Dim rowChanges As Models.IMRowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(itemMaintHeaderID)
            ' Merge the cloned Item Master record with changes
            FormHelper.FlattenItemMaintRecord(record, rowChanges, table)

            If masterDtl.VendorType = WebConstants.VENDORTYPEDOMESTIC Then  'DOMESTIC BATCH
                ' calc the changes
                CalculationHelper.CalcIMDomesticUploadChanges(record)

                ' save any changes
                FieldComparison(record.EachCaseCube, masterDtl.EachCaseCube, itemMaintHeaderID, "EachCaseCube", userID, True)
                FieldComparison(record.InnerCaseCube, masterDtl.InnerCaseCube, itemMaintHeaderID, "InnerCaseCube", userID, True)
                FieldComparison(record.MasterCaseCube, masterDtl.MasterCaseCube, itemMaintHeaderID, "MasterCaseCube", userID, True)
                FieldComparison(record.FOBShippingPoint, masterDtl.FOBShippingPoint, itemMaintHeaderID, "FOBShippingPoint", userID, True)

            Else    ' IMPORT BATCH
                Dim vendorID As Integer = Session(WebConstants.cVENDORID)

                ' calc the changes
                CalculationHelper.CalcIMUploadChanges(record)

                ' save any changes
                FieldComparison(record.EachCaseCube, masterDtl.EachCaseCube, itemMaintHeaderID, "EachCaseCube", userID, True)
                FieldComparison(record.InnerCaseCube, masterDtl.InnerCaseCube, itemMaintHeaderID, "InnerCaseCube", userID, True)
                FieldComparison(record.MasterCaseCube, masterDtl.MasterCaseCube, itemMaintHeaderID, "MasterCaseCube", userID, True)
                FieldComparison(record.FOBShippingPoint, masterDtl.FOBShippingPoint, itemMaintHeaderID, "FOBShippingPoint", userID, True)

                FieldComparison(0, masterDtl.DutyAmount, itemMaintHeaderID, "DutyAmount", userID, True)
                FieldComparison(0, masterDtl.SuppTariffAmount, itemMaintHeaderID, "SuppTariffAmount", userID, True)
                FieldComparison(0, masterDtl.OceanFreightComputedAmount, itemMaintHeaderID, "OceanFreightComputedAmount", userID, True)
                FieldComparison(0, masterDtl.AgentCommissionAmount, itemMaintHeaderID, "AgentCommissionAmount", userID, True)
                FieldComparison(0, masterDtl.OtherImportCostsAmount, itemMaintHeaderID, "OtherImportCostsAmount", userID, True)
                FieldComparison(0, masterDtl.ImportBurden, itemMaintHeaderID, "ImportBurden", userID, True)
                FieldComparison(record.FOBShippingPoint, masterDtl.WarehouseLandedCost, itemMaintHeaderID, "WarehouseLandedCost", userID, True)
                FieldComparison(0, masterDtl.OutboundFreight, itemMaintHeaderID, "OutboundFreight", userID, True)
                FieldComparison(0, masterDtl.NinePercentWhseCharge, itemMaintHeaderID, "NinePercentWhseCharge", userID, True)
                FieldComparison(record.FOBShippingPoint, masterDtl.TotalStoreLandedCost, itemMaintHeaderID, "TotalStoreLandedCost", userID, True)

                'FieldComparison(record.DutyAmount, masterDtl.DutyAmount, itemMaintHeaderID, "DutyAmount", userID, True)
                'FieldComparison(record.SuppTariffAmount, masterDtl.SuppTariffAmount, itemMaintHeaderID, "SuppTariffAmount", userID, True)
                'FieldComparison(record.OceanFreightComputedAmount, masterDtl.OceanFreightComputedAmount, itemMaintHeaderID, "OceanFreightComputedAmount", userID, True)
                'FieldComparison(record.AgentCommissionAmount, masterDtl.AgentCommissionAmount, itemMaintHeaderID, "AgentCommissionAmount", userID, True)
                'FieldComparison(record.OtherImportCostsAmount, masterDtl.OtherImportCostsAmount, itemMaintHeaderID, "OtherImportCostsAmount", userID, True)
                'FieldComparison(record.ImportBurden, masterDtl.ImportBurden, itemMaintHeaderID, "ImportBurden", userID, True)
                'FieldComparison(record.WarehouseLandedCost, masterDtl.WarehouseLandedCost, itemMaintHeaderID, "WarehouseLandedCost", userID, True)
                'FieldComparison(record.OutboundFreight, masterDtl.OutboundFreight, itemMaintHeaderID, "OutboundFreight", userID, True)
                'FieldComparison(record.NinePercentWhseCharge, masterDtl.NinePercentWhseCharge, itemMaintHeaderID, "NinePercentWhseCharge", userID, True)
                'FieldComparison(record.TotalStoreLandedCost, masterDtl.TotalStoreLandedCost, itemMaintHeaderID, "TotalStoreLandedCost", userID, True)
            End If
        End If

    End Sub

    Private Function ReadBIMFromWS(ByVal ws As IWorksheet) As List(Of Models.ItemMaintUploadChangeRecord)
        Dim itemList As New List(Of Models.ItemMaintUploadChangeRecord)
        Dim rowExists As Boolean = True
        Dim rowIndex As Integer = 2

        ' get item map
        Dim michaelsMap As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping
        Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = michaelsMap.GetMapping("BULKMAINT", "1.0")

        If itemMap Is Nothing OrElse itemMap.Count <= 0 Then
            Throw New SPEDYUploadException("Bulk Item Maintenance uploads are not currently supported.  Please contact the System Administrator.")
        End If

        While rowExists

            'GET SKU and Vendor
            Dim theItem As New Models.ItemMaintUploadChangeRecord
            theItem.MichaelsSKU = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MichaelsSKU", "", rowIndex), "string", True)

            'IF SKU is not specified, exit loop
            If String.IsNullOrEmpty(theItem.MichaelsSKU) Then
                rowExists = False
                Exit While
            End If

            'Get other item values
            theItem.VendorNbr = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorNumber", "", rowIndex), "string", True)
            theItem.VPN = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorStyleNum", "", rowIndex), "string", True)
            theItem.ItemDesc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ItemDesc", "", rowIndex), "string", True)
            theItem.PrivateBrandLabel = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrivateBrandLabel", "", rowIndex), "string", True)
            theItem.EachesMasterCase = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachesMasterCase", "", rowIndex), "string", True)
            theItem.EachesInnerPack = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachesInnerPack", "", rowIndex), "string", True)
            theItem.AllowStoreOrder = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AllowStoreOrder", "", rowIndex), "string", True)
            theItem.InventoryControl = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InventoryControl", "", rowIndex), "string", True)
            theItem.Discountable = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Discountable", "", rowIndex), "string", True)
            theItem.AutoReplenish = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AutoReplenish", "", rowIndex), "string", True)
            theItem.PrePriced = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrePriced", "", rowIndex), "string", True)
            theItem.PrePricedUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrePricedUDA", "", rowIndex), "string", True)
            theItem.ItemCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ItemCost", "", rowIndex), "string", True)
            theItem.ProductCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ProductCost", "", rowIndex), "string", True)

            theItem.EachPackHeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachCaseHeight", "", rowIndex), "string", True), 4)
            theItem.EachPackWidth = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachCaseWidth", "", rowIndex), "string", True), 4)
            theItem.EachPackLength = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachCaseLength", "", rowIndex), "string", True), 4)
            theItem.EachPackWeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachCaseWeight", "", rowIndex), "string", True), 4)

            theItem.InnerPackHeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InnerCaseHeight", "", rowIndex), "string", True), 4)
            theItem.InnerPackWidth = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InnerCaseWidth", "", rowIndex), "string", True), 4)
            theItem.InnerPackLength = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InnerCaseLength", "", rowIndex), "string", True), 4)
            theItem.InnerPackWeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InnerCaseWeight", "", rowIndex), "string", True), 4)
            theItem.MasterCaseHeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCaseHeight", "", rowIndex), "string", True), 4)
            theItem.MasterCaseWidth = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCaseWidth", "", rowIndex), "string", True), 4)
            theItem.MasterCaseLength = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCaseLength", "", rowIndex), "string", True), 4)
            theItem.MasterCaseWeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCaseWeight", "", rowIndex), "string", True), 4)
            theItem.CountryOfOrigin = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CountryOfOriginName", "", rowIndex), "string", True)
            theItem.TaxUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TaxUDA", "", rowIndex), "string", True)
            theItem.TaxValueUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TaxValueUDA", "", rowIndex), "string", True)
            theItem.DutyPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DutyPercent", "", rowIndex), "string", True)
            If IsNumeric(theItem.DutyPercent) And Not String.IsNullOrEmpty(theItem.DutyPercent) Then
                theItem.DutyPercent = DataHelper.SmartValues(theItem.DutyPercent, "CDec", False, 0) / 100   'Divide by 100, because this represents a percent to the user.
            End If
            theItem.AdditionalDutyComment = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AdditionalDutyComment", "", rowIndex), "string", True)
            theItem.AdditionalDutyAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AdditionalDutyAmount", "", rowIndex), "string", True, String.Empty, 4)

            theItem.SuppTariffPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SuppTariffPercent", "", rowIndex), "string", True)
            If IsNumeric(theItem.SuppTariffPercent) And Not String.IsNullOrEmpty(theItem.SuppTariffPercent) Then
                theItem.SuppTariffPercent = DataHelper.SmartValues(theItem.SuppTariffPercent, "CDec", False, 0) / 100   'Divide by 100, because this represents a percent to the user.
            End If

            theItem.OceanFreightAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OceanFreightAmount", "", rowIndex), "string", True)
            theItem.AgentCommissionPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentCommissionPercent", "", rowIndex), "string", True)
            If IsNumeric(theItem.AgentCommissionPercent) And Not String.IsNullOrEmpty(theItem.AgentCommissionPercent) Then
                theItem.AgentCommissionPercent = DataHelper.SmartValues(theItem.AgentCommissionPercent, "CDec", False, 0) / 100   'Divide by 100, because this represents a percent to the user.
            End If
            theItem.ShippingPoint = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ShippingPoint", "", rowIndex), "string", True)
            theItem.PlanogramName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PlanogramName", "", rowIndex), "string", True)
            theItem.Hazardous = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Hazardous", "", rowIndex), "string", True)
            theItem.HazardousFlammable = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousFlammable", "", rowIndex), "string", True)
            theItem.HazardousContainerType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousContainerType", "", rowIndex), "string", True)
            theItem.HazardousContainerSize = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousContainerSize", "", rowIndex), "string", True)
            theItem.HazardousMSDSUOM = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousMSDSUOM", "", rowIndex), "string", True)
            theItem.HazardousManufacturerName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousManufacturerName", "", rowIndex), "string", True)
            theItem.HazardousManufacturerCity = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousManufacturerCity", "", rowIndex), "string", True)
            theItem.HazardousManufacturerState = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousManufacturerState", "", rowIndex), "string", True)
            theItem.HazardousManufacturerPhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousManufacturerPhone", "", rowIndex), "string", True)
            theItem.HazardousManufacturerCountry = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HazardousManufacturerCountry", "", rowIndex), "string", True)
            theItem.PLIFrench = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLIFrench", "", rowIndex), "string", True)
            theItem.PLISpanish = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLISpanish", "", rowIndex), "string", True)
            theItem.TIFrench = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TIFrench", "", rowIndex), "string", True)
            theItem.CustomsDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CustomsDescription", "", rowIndex), "string", True)
            theItem.EnglishShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishShortDescription", "", rowIndex), "string", True)
            theItem.EnglishLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishLongDescription", "", rowIndex), "string", True)
            theItem.HarmonizedCodeNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HarmonizedCodeNumber", "", rowIndex), "string", True)
            If Not String.IsNullOrEmpty(theItem.HarmonizedCodeNumber) Then
                theItem.HarmonizedCodeNumber = Right("0000000000" & theItem.HarmonizedCodeNumber, 10)
            End If
            theItem.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CanadaHarmonizedCodeNumber", "", rowIndex), "string", True)
            If Not String.IsNullOrEmpty(theItem.CanadaHarmonizedCodeNumber) Then
                theItem.CanadaHarmonizedCodeNumber = Right("0000000000" & theItem.CanadaHarmonizedCodeNumber, 10)
            End If

            theItem.ComponentMaterialBreakdown = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ComponentMaterialBreakdown0", "", rowIndex), "string", True)
            theItem.ComponentConstructionMethod = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ComponentConstructionMethod", "", rowIndex), "string", True)

            theItem.CoinBattery = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CoinBattery", "", rowIndex), "string", True)
            'theItem.TSSA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TSSA", "", rowIndex), "string", True)
            theItem.CSA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CSA", "", rowIndex), "string", True)
            theItem.UL = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "UL", "", rowIndex), "string", True)
            theItem.LicenceAgreement = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "LicenceAgreement", "", rowIndex), "string", True)
            theItem.FumigationCertificate = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FumigationCertificate", "", rowIndex), "string", True)
            theItem.KILNDriedCertificate = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "KILNDriedCertificate", "", rowIndex), "string", True)
            theItem.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ChinaComInspecNumAndCCIBStickers", "", rowIndex), "string", True)
            theItem.OriginalVisa = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OriginalVisa", "", rowIndex), "string", True)
            theItem.TextileDeclarationMidCode = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TextileDeclarationMidCode", "", rowIndex), "string", True)
            theItem.QuotaChargeStatement = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuotaChargeStatement", "", rowIndex), "string", True)
            theItem.MSDS = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MSDS", "", rowIndex), "string", True)
            theItem.TSCA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TSCA", "", rowIndex), "string", True)
            theItem.DropBallTestCert = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DropBallTestCert", "", rowIndex), "string", True)
            theItem.ManMedicalDeviceListing = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManMedicalDeviceListing", "", rowIndex), "string", True)
            theItem.ManFDARegistration = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManFDARegistration", "", rowIndex), "string", True)
            theItem.CopyRightIndemnification = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CopyRightIndemnification", "", rowIndex), "string", True)
            theItem.FishWildLifeCert = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FishWildLifeCert", "", rowIndex), "string", True)
            theItem.Proposition65LabelReq = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Proposition65LabelReq", "", rowIndex), "string", True)
            theItem.CCCR = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CCCR", "", rowIndex), "string", True)
            theItem.FormaldehydeCompliant = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FormaldehydeCompliant", "", rowIndex), "string", True)

            itemList.Add(theItem)

            rowIndex = rowIndex + 1
        End While

        Return itemList
    End Function


    Private Sub UploadBIM(ByVal ws As IWorksheet)
        Try
            Dim skuAdded As New List(Of String)
            Dim userID As String = Session(WebConstants.cUSERID)
            _validSKUList = New List(Of SkuList)

            'Load List of Items
            Dim itemList As List(Of Models.ItemMaintUploadChangeRecord) = ReadBIMFromWS(ws)

            'Validate List of Items, and process them if they pass validation
            ValidateBulkItemWorksheet(itemList, userID)
            If _validSKUList.Count > 0 Then
                'CREATE Batch
                Dim batch As New NovaLibra.Coral.Data.Michaels.BatchData
                Dim batchID As Integer = MyBase.CreateBatch(WebConstants.WorkflowType.BulkItemMaint, 0, 0, "", userID, "", "", "", "", "", "", Models.BatchType.BulkItemMaintenance)

                'Loop through Valid item list.  Add each one to the batch, and then Compare the uploaded values to existing values to create change records.
                For Each validItem As SkuList In _validSKUList
                    Dim item As Models.ItemMaintUploadChangeRecord = itemList.Find(Function(x) x.MichaelsSKU = validItem.SKU And x.VendorNbr = validItem.VendorNumber)
                    If item IsNot Nothing Then

                        Dim addItem As Models.ItemMaintItem = BuildBatchAddItem(batchID, userID, item.MichaelsSKU, item.SkuID, item.VendorNbr)
                        Dim itemHeaderID As Integer = NLData.Michaels.MaintItemMasterData.SaveItemMaintHeaderRec(addItem)

                        'Get Master Item
                        Dim masterDtl As Models.ItemMaintItemDetailFormRecord = NLData.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(0, 0, item.MichaelsSKU, item.VendorNbr)

                        'Compare Uploaded values to Existing Values to create Change records
                        CompareBIMUploadFields(itemHeaderID, item, masterDtl, userID)

                        skuAdded.Add(item.MichaelsSKU)
                    End If
                Next

                FlushFeedback("Upload complete.")
            End If

        Catch ex As Exception
            Throw ex
        End Try

    End Sub

    Private Function ValidateBulkItemWorksheet(ByVal itemList As List(Of Models.ItemMaintUploadChangeRecord), ByVal userID As Integer) As Boolean
        Dim ret As Boolean = True
        Dim errorCount As Integer = 0

        If itemList.Count = 0 Then
            ret = False
            AddToErrorList("ValidateBulkItemWorksheet", "ERROR: Worksheet does not contain any SKUs.", "")
        End If

        For Each item As Models.ItemMaintUploadChangeRecord In itemList
            Dim isItemValid As Boolean = True
            If item.VendorNbr.Length = 0 Then
                isItemValid = False
                AddToErrorList("ValidateBulkItemWorksheet", "Vendor number required, but not supplied for SKU '" & item.MichaelsSKU & "'.", item.MichaelsSKU, item.VendorNbr)
            Else
                Dim skuList As System.Collections.Generic.List(Of Models.ItemSearchRecord) = BatchesData.SearchSKURecs(0, item.VendorNbr, 0, 0, String.Empty, String.Empty, item.MichaelsSKU, String.Empty, String.Empty, String.Empty, String.Empty, userID, 0, String.Empty, String.Empty, 0, 0, String.Empty)
                If skuList.Count = 1 Then
                    Dim thisISR As Models.ItemSearchRecord = skuList.Item(0)

                    'Check if this is an upload froma Vendor
                    Dim vendorID As Integer = Session(WebConstants.cVENDORID)
                    If vendorID > 0 Then
                        ' match thisISR.VendorNumber to vendorID
                        If thisISR.VendorNumber <> vendorID Then
                            isItemValid = False
                            AddToErrorList("ValidateBulkItemWorksheet", "SKU '" & thisISR.SKU & "' belongs to another vendor; you cannot upload this item to a batch.", thisISR.SKU, thisISR.VendorNumber)
                        End If
                    End If

                    '' only allow independently editable items
                    'If thisISR.IndEditable = False Then
                    '    isItemValid = False
                    '    AddToErrorList("ValidateBulkItemWorksheet", "SKU '" & thisISR.SKU & "' cannot be edited; it is part of an active Display Pack.", thisISR.SKU, thisISR.VendorNumber)
                    'End If

                    isItemValid = isItemValid And ItemMaintItemRules(item, thisISR.SKU, thisISR.VendorNumber)

                    'Check to see if the SKU is in another Batch
                    Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
                    Dim batchList As List(Of Models.BatchRecord) = batchDB.GetBatchesBySKUVendor(thisISR.SKU, thisISR.VendorNumber)
                    For Each batch As Models.BatchRecord In batchList
                        Select Case batch.BatchTypeID
                            Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualExemptions
                                AddToErrorList("ValidateBulkItemWorksheet", "Warning: SKU '" & thisISR.SKU & "' is already in Trilingual PLI/Exemption Batch " & batch.ID & ".", thisISR.SKU, thisISR.VendorNumber, thisISR.BatchID)
                            Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualTranslations
                                AddToErrorList("ValidateBulkItemWorksheet", "Warning: SKU '" & thisISR.SKU & "' is already in Trilingual Translation Batch " & batch.ID & ".", thisISR.SKU, thisISR.VendorNumber, thisISR.BatchID)
                            Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic, NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import
                                AddToErrorList("ValidateBulkItemWorksheet", "Warning: SKU '" & thisISR.SKU & "' is already in Item Maintenance batch " & batch.ID & ".", thisISR.SKU, thisISR.VendorNumber, thisISR.BatchID)
                            Case Else
                                isItemValid = False
                                AddToErrorList("ValidateBulkItemWorksheet", "SKU '" & thisISR.SKU & "' is already in Bulk Item Maintenance batch " & batch.ID & ".", thisISR.SKU, thisISR.VendorNumber, thisISR.BatchID)
                        End Select
                    Next

                    'Set SKUID for Item (so we have it for later)
                    item.SkuID = thisISR.SKUID
                Else
                    isItemValid = False
                    AddToErrorList("ValidateBulkItemWorksheet", "SKU '" & item.MichaelsSKU & "' not found, or not associated with vendor '" & item.VendorNbr & "'.", item.MichaelsSKU, item.VendorNbr)
                End If
            End If

            'Track upload and sku validity
            ret = ret And isItemValid
            If isItemValid Then
                'Check to see if the SKU is a duplicate
                'NAK 9/29/2014:  Michaels changed their mind, and don't want same SKU different Vendor to be allowed on the same Bulk Item Maint batch.  
                Dim validSKU As SkuList = _validSKUList.Find(Function(x) x.SKU = item.MichaelsSKU)
                If validSKU IsNot Nothing Then
                    'If _validSKUList.Contains(New SkuList(item.MichaelsSKU, item.VendorNbr)) Then
                    AddToErrorList("ValidateItemMaintItem", "Duplicate found for SKU '" & item.MichaelsSKU & "'.", item.MichaelsSKU, item.VendorNbr)
                    errorCount += 1
                Else
                    _validSKUList.Add(New SkuList(item.MichaelsSKU, item.VendorNbr))
                End If
            Else
                errorCount += 1
            End If
        Next

        PostValidationFeedback(_validSKUList.Count, itemList.Count, errorCount)

        Return ret
    End Function

    Private Function ItemMaintItemRules(ByVal theItem As Models.ItemMaintUploadChangeRecord, ByVal sku As String, ByVal vendorNbr As String) As Boolean

        Dim ret As Boolean = True

        ret = ret And ItemMaintIsNumeric(theItem.EachesMasterCase, "Eaches Master Case", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachesInnerPack, "Eaches Inner Pack", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.AllowStoreOrder, "Allow Store Order", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.InventoryControl, "Inventory Control", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.Discountable, "Discountable", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.AutoReplenish, "Auto Replenish", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.PrePriced, "PrePriced", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.PrePricedUDA, "Prepriced UDA", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.Cost, "Cost", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.ProductCost, "Cost", sku, vendorNbr)

        ret = ret And ItemMaintIsNumeric(theItem.EachPackHeight, "Each Pack Height", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachPackWidth, "Each Pack Width", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachPackLength, "Each Pack Length", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachPackWeight, "Each Pack Weight", sku, vendorNbr)

        ret = ret And ItemMaintIsNumeric(theItem.InnerPackHeight, "Inner Pack Height", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.InnerPackWidth, "Inner Pack Width", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.InnerPackLength, "Inner Pack Length", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.InnerPackWeight, "Inner Pack Weight", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseHeight, "Master Case Height", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseWidth, "Master Case Width", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseLength, "Master Case Length", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseWeight, "Master Case Weight", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.TaxUDA, "Tax UDA", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.TaxValueUDA, "Tax Value UDA", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.DutyPercent, "Duty Percent", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.AdditionalDutyAmount, "Additional Duty", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.SuppTariffPercent, "Supplementary Tariff Percent", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.OceanFreightAmount, "Ocean Freight Amount", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.AgentCommissionPercent, "Merch Burden Percent", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.Hazardous, "Hazardous", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.HazardousFlammable, "Hazardous Flammable", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.PLIFrench, "Package Language Indicator French", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.PLISpanish, "Package Language Indicator Spanish", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.TIFrench, "Translation Indicator French", sku, vendorNbr)

        ret = ret And ItemMaintIsBoolean(theItem.CoinBattery, "CoinBattery", sku, vendorNbr)
        'ret = ret And ItemMaintIsBoolean(theItem.TSSA, "TSSA", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.CSA, "CSA", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.UL, "UL", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.LicenceAgreement, "Licence Agreement", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.FumigationCertificate, "Fumigation Certificate", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.KILNDriedCertificate, "Kiln Dried Certificate", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.ChinaComInspecNumAndCCIBStickers, "China Commodity Inspection #", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.OriginalVisa, "Original Visa", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.TextileDeclarationMidCode, "Textile Declaration Mid Code", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.QuotaChargeStatement, "Quota Change Statement", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.MSDS, "MSDS", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.TSCA, "TSCA", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.DropBallTestCert, "Drop Ball Test Cert", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.ManMedicalDeviceListing, "Manufacturer Medical Device Listing #", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.ManFDARegistration, "Manufacturer FDA Registration", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.CopyRightIndemnification, "Copyright Idemnification", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.FishWildLifeCert, "Fish and Wildlife Cert", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.Proposition65LabelReq, "Proposition 65 Labeling Req", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.CCCR, "CCCR", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.FormaldehydeCompliant, "Formaldehyde Compliant", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.PrivateBrandLabel, "Private Brand Label", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.HazardousContainerType, "Hazardous Container Type", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.HazardousMSDSUOM, "Hazardous MSDS UOM", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.ImportBurden, "Import Burden", sku, vendorNbr)

        Return ret

    End Function

    Private Function ItemMaintIsBoolean(ByVal fieldValue As String, ByVal fieldName As String, ByVal sku As String, ByVal vendorNbr As String) As Boolean
        Dim ret As Boolean = True
        If fieldValue.Length > 0 Then
            Dim testValue As String = fieldValue.ToUpper
            If Not (testValue = "Y" Or testValue = "N") Then
                ret = False
                AddToErrorList("ItemMaintIsBoolean", "SKU '" & sku & "' must have Y or N (or blank) in its " & fieldName & " column.", sku, vendorNbr)
            End If
        End If
        Return ret
    End Function

    Private Function ItemMaintIsNumeric(ByVal fieldValue As String, ByVal fieldName As String, ByVal sku As String, ByVal vendorNbr As String) As Boolean
        Dim ret As Boolean = True
        If fieldValue.Length > 0 Then
            If Not IsNumeric(fieldValue) Then
                ret = False
                AddToErrorList("ItemMaintIsNumeric", "SKU '" & sku & "' has the non-numeric value '" & fieldValue & "' in its " & fieldName & " column.", sku, vendorNbr)
            End If
        End If
        Return ret
    End Function

#Region " Feedback and Auditing "

    Private Sub ClearFeedback(Optional ByVal msg As String = "")
        _feedbackMsg = msg
    End Sub

    Private Sub AddToFeedback(ByVal msg As String)
        If _feedbackMsg.Length > 0 Then
            _feedbackMsg += "<BR>"
        End If
        _feedbackMsg += msg
    End Sub

    Private Sub FlushFeedback(Optional ByVal msg As String = "")
        If msg.Length > 0 Then
            AddToFeedback(msg)
        End If
        lblFeedback.Text = _feedbackMsg
    End Sub

    Private Sub AddToErrorList(ByVal routineName As String, _
                               ByVal msg As String, _
                               Optional ByVal michaelsSKU As String = "", _
                               Optional ByVal vendorNbr As String = "", _
                               Optional ByVal batchID As String = "")

        Dim userID As String = Session(WebConstants.cUSERID)

        ' display on the dialog box
        AddToFeedback(msg)

        ' record in the queue
        If michaelsSKU.Length > 0 Or vendorNbr.Length > 0 Or batchID.Length > 0 Then

            Dim excelAuditRec As New Models.ExcelAuditLog
            If batchID.Length > 0 Then
                excelAuditRec.BatchID = batchID
            End If
            If vendorNbr.Length > 0 Then
                excelAuditRec.VendorNumber = vendorNbr
            End If
            excelAuditRec.MichaelsSKU = michaelsSKU
            excelAuditRec.CreatedUserID = userID
            excelAuditRec.Message = "Upload Bulk Item Maint routine: " & routineName & "; Message: " & msg
            excelAuditRec.Direction = "I"
            excelAuditRec.XLFileName = _xlFileName

            Dim objData As New NovaLibra.Coral.Data.Michaels.FieldAuditingData
            objData.SaveExcelAuditLog(excelAuditRec)

        End If

    End Sub

#End Region

    Private Function BuildBatchAddItem(ByVal batchID As Long, ByVal userID As Integer, ByVal SKU As String, ByVal skuID As Integer, ByVal vendorNbr As String) As Models.ItemMaintItem

        Dim ret As New Models.ItemMaintItem

        ret.BatchID = batchID
        ret.CreatedUserID = userID
        ret.SKU = SKU
        ret.SKUID = skuID
        ret.VendorNumber = vendorNbr

        Return ret

    End Function

    Private Sub CountryOfOriginComparison(ByVal theCOOName As String, ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal itemMaintHeaderID As Integer)

        ' country of origin
        ' this is not a direct comparison; this is determining whether to add the coo as an additional coo
        Dim userID As String = Session(WebConstants.cUSERID)

        If theCOOName <> "" Then
            ' compare to the primary coo name
            ' also to any secondary names
            ' if a match is not found, we'll add this one
            Dim cooAdd As Boolean = True
            If masterDtl.CountryOfOriginName.ToUpper = theCOOName.ToUpper Then
                cooAdd = False
            End If
            For Each coo2nd As Models.ItemMasterVendorCountryRecord In masterDtl.AdditionalCOORecs
                If coo2nd.CountryOfOriginName.ToUpper = theCOOName.ToUpper Then
                    cooAdd = False
                    Exit For
                End If
            Next
            ' done comparing, now add
            If cooAdd Then
                Dim theCountry As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(theCOOName)
                If Not theCountry Is Nothing AndAlso theCountry.CountryName <> String.Empty AndAlso theCountry.CountryCode <> String.Empty Then
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOO, theCountry.CountryCode, True, userID, "", "", "", 0, False, True)
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOONAME, theCountry.CountryName, True, userID, "", "", "", 0, False, True)

                    'Make the new Country of Origin Primary
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cNEWPRIMARYCODE, theCountry.CountryCode, True, userID, "", "", "", 0, False, True)
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cNEWPRIMARY, theCountry.CountryName, True, userID, "", "", "", 0, False, True)
                Else
                    ' In this case, the user has typed in something, but it wasn't found in the database.
                    ' We're going to let them add the change records anyway, but with different values.
                    Dim blankCOOName As String = String.Empty
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOO, blankCOOName, True, userID)
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOONAME, theCOOName.ToUpper, True, userID)
                End If
            End If
        End If

    End Sub

    Private Function ConvertToYesNo(ByVal value As String) As String
        Dim result As String = String.Empty
        Select Case value.ToUpper
            Case "Y", "YES"
                result = "Y"
            Case "N", "NO"
                result = "N"
            Case Else
                result = ""
        End Select

        Return result
    End Function

    Private Sub PostValidationFeedback(ByVal passCounter As Integer, ByVal itemCounter As Integer, ByVal errorCounter As Integer)

        AddToFeedback(itemCounter.ToString & " items were reviewed.")
        AddToFeedback(errorCounter.ToString & " items had validation errors.")
        AddToFeedback(passCounter.ToString & " items passed validation.")

        If passCounter = 0 Then
            Session("UPLOAD_ITEM_MAINT_WB") = Nothing
            FlushFeedback("No items from this file can be saved to a batch.")
        Else
            Dim countMsg As String = passCounter & " items processed."
            countMsg += "<BR>" & "Processing ends when an empty SKU is encountered."
            AddToFeedback(countMsg)
        End If

    End Sub


    Private Function FieldComparison(ByVal xlValue As Object, ByVal imValue As Object, ByVal itemMaintHeaderID As Long, ByVal fieldName As String, ByVal userID As Integer) As Boolean
        Return FieldComparison(xlValue, imValue, itemMaintHeaderID, fieldName, userID, False)
    End Function

    Private Function FieldComparison(ByVal xlValue As Object, ByVal imValue As Object, ByVal itemMaintHeaderID As Long, ByVal fieldName As String, ByVal userID As Integer, ByVal ignoreBlanks As Boolean) As Boolean
        ' if there is a change present, return true, otherwise false
        Dim ret As Boolean = False
        Dim column As Frameworks.MetadataColumn = _table.GetColumnByName(fieldName)

        Debug.Assert(column IsNot Nothing, ("Cannot find metadata for this column: " & fieldName))

        '' if the spreadsheet is blank/empty, don't save it as a change

        If xlValue.ToString().Trim.Length > 0 OrElse (Not ignoreBlanks) Then

            Dim fieldType As String = IIf(column IsNot Nothing, column.GenericType, "string")
            Dim fieldFormat As String = IIf(column IsNot Nothing, column.ColumnFormat, "string")

            If DataHelper.SmartValues(xlValue, fieldType, True) <> DataHelper.SmartValues(imValue, fieldType, True) Then

                If (fieldType <> "decimal" And fieldType <> "numeric") OrElse DataHelper.SmartValues(xlValue, fieldFormat, True) <> DataHelper.SmartValues(imValue, fieldFormat, True) Then

                    ' create a change record
                    If (fieldType = "decimal" OrElse fieldType = "numeric") And fieldFormat <> "percent" Then
                        NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, fieldName, DataHelper.SmartValuesAsString(DataHelper.SmartValuesAsString(xlValue, fieldType), fieldFormat), True, userID, "", "", "", 0, False, True)
                    Else
                        NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, fieldName, DataHelper.SmartValuesAsString(xlValue, fieldType), True, userID, "", "", "", 0, False, True)
                    End If

                    ret = True
                End If

            End If

        End If

        Return ret
    End Function

    Private Function FieldComparisonMultiLine(ByVal fieldIndex As Integer, ByVal stringArray As String(), ByVal imValue As Object, ByVal itemMaintHeaderID As Long, ByVal fieldName As String, ByVal userID As Integer) As Boolean
        Dim strValue As String = ""
        If stringArray.Length > fieldIndex Then
            strValue = stringArray(fieldIndex)
        End If

        Return FieldComparison(strValue, imValue, itemMaintHeaderID, fieldName, userID, True)
    End Function

End Class
