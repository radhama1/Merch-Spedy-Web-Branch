Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Diagnostics
Imports System.IO
Imports System.Reflection
Imports System.Text
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Collections.Generic

Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels

Public Class ItemHelper

    ' ------------------------------------------------------------------------------------------------------
    ' Merge ItemMaintItemDetailFormRecord record information into ItemRecord / ImportItemRecord
    ' ------------------------------------------------------------------------------------------------------

    Public Shared Function MergeItemMaintRecordIntoItem(ByRef itemHeader As Models.ItemHeaderRecord, ByRef rec As Models.ItemRecord, ByRef itemMaintRec As Models.ItemMaintItemDetailFormRecord) As Boolean
        ' merge the data
        Dim isUS As Boolean = False
        Dim isCanada As Boolean = False
        If itemHeader.USVendorNum <= 0 AndAlso itemHeader.CanadianVendorNum > 0 Then
            isCanada = True
        Else
            isUS = True
        End If

        'rec = itemMaintRec.ID  ' integer 
        'rec = itemMaintRec.BatchID  ' long 
        'rec = itemMaintRec.Enabled  ' boolean 
        'rec = itemMaintRec.IsValid  ' integer 
        'rec = itemMaintRec.SKU  ' string 
        'rec = itemMaintRec.IsLockedForChange  ' integer 
        'rec = itemMaintRec.VendorNumber  ' long 
        'rec = itemMaintRec.BatchTypeID  ' integer 
        'rec = itemMaintRec.VendorType  ' integer 
        rec.VendorUPC = itemMaintRec.PrimaryUPC  ' string 
        rec.VendorStyleNum = itemMaintRec.VendorStyleNum  ' string 
        'rec = itemMaintRec.AdditionalUPCRecs  ' integer 
        If rec.AdditionalUPCRecord IsNot Nothing Then rec.AdditionalUPCRecord.AdditionalUPCs.Clear()
        If itemMaintRec.AdditionalUPCRecs IsNot Nothing Then
            For Each upc As Models.ItemMasterVendorUPCRecord In itemMaintRec.AdditionalUPCRecs
                rec.AdditionalUPCRecord.AddAdditionalUPC(upc.UPC)
            Next
        End If
        rec.ItemDesc = itemMaintRec.ItemDesc  ' string 
        rec.ClassNum = itemMaintRec.ClassNum  ' integer 
        rec.SubClassNum = itemMaintRec.SubClassNum  ' integer 
        rec.PrivateBrandLabel = itemMaintRec.PrivateBrandLabel  ' long 
        rec.EachesMasterCase = itemMaintRec.EachesMasterCase  ' integer 
        rec.EachesInnerPack = itemMaintRec.EachesInnerPack  ' integer 
        ' HEADER rec. = itemMaintRec.AllowStoreOrder  ' string 
        ' HEADER rec = itemMaintRec.InventoryControl  ' string 
        ' HEADER rec = itemMaintRec.AutoReplenish  ' string 
        rec.PrePriced = itemMaintRec.PrePriced  ' string 
        rec.PrePricedUDA = itemMaintRec.PrePricedUDA  ' long 
        'rec = itemMaintRec.ItemCost  ' decimal 
        If Not isUS Then
            rec.CanadaCost = itemMaintRec.ItemCost
        Else
            rec.USCost = itemMaintRec.ItemCost
        End If
        rec.EachCaseHeight = itemMaintRec.EachCaseHeight  ' decimal 
        rec.EachCaseWidth = itemMaintRec.EachCaseWidth  ' decimal 
        rec.EachCaseLength = itemMaintRec.EachCaseLength  ' decimal 
        rec.EachCasePackCube = itemMaintRec.EachCaseCube  ' decimal 
        rec.EachCaseWeight = itemMaintRec.EachCaseWeight  ' decimal 
        'rec = itemMaintRec.EachCaseCubeUOM  ' string 
        'rec = itemMaintRec.EachCaseWeightUOM  ' string 
        rec.InnerCaseHeight = itemMaintRec.InnerCaseHeight  ' decimal 
        rec.InnerCaseWidth = itemMaintRec.InnerCaseWidth  ' decimal 
        rec.InnerCaseLength = itemMaintRec.InnerCaseLength  ' decimal 
        rec.InnerCasePackCube = itemMaintRec.InnerCaseCube  ' decimal 
        rec.InnerCaseWeight = itemMaintRec.InnerCaseWeight  ' decimal 
        'rec = itemMaintRec.InnerCaseCubeUOM  ' string 
        'rec = itemMaintRec.InnerCaseWeightUOM  ' string 
        rec.MasterCaseHeight = itemMaintRec.MasterCaseHeight  ' decimal 
        rec.MasterCaseWidth = itemMaintRec.MasterCaseWidth  ' decimal 
        rec.MasterCaseLength = itemMaintRec.MasterCaseLength  ' decimal 
        rec.MasterCaseWeight = itemMaintRec.MasterCaseWeight  ' decimal 
        rec.MasterCasePackCube = itemMaintRec.MasterCaseCube  ' decimal 
        'rec = itemMaintRec.MasterCaseCubeUOM  ' string 
        'rec = itemMaintRec.MasterCaseWeightUOM  ' string 
        rec.CountryOfOrigin = itemMaintRec.CountryOfOrigin  ' string 
        rec.CountryOfOriginName = itemMaintRec.CountryOfOriginName  ' string 
        rec.TaxUDA = itemMaintRec.TaxUDA  ' long 
        rec.TaxValueUDA = DataHelper.SmartValues(DataHelper.DBSmartValues(itemMaintRec.TaxValueUDA, "long", True), "integer", True)  ' Convert Long MinValue to Int Minvalue 
        ' HEADER rec = itemMaintRec.Discountable  ' string 
        ' IMPORT rec = itemMaintRec.ImportBurden  ' decimal 
        ' IMPORT rec = itemMaintRec.ShippingPoint  ' string 
        ' IMPORT rec = itemMaintRec.PlanogramName  ' string 
        rec.Hazardous = itemMaintRec.Hazardous  ' string 
        rec.HazardousFlammable = itemMaintRec.HazardousFlammable  ' string 
        rec.HazardousContainerType = itemMaintRec.HazardousContainerType  ' string 
        rec.HazardousContainerSize = itemMaintRec.HazardousContainerSize  ' decimal 
        rec.SetMSDSID(itemMaintRec.MSDSID)  ' long 
        rec.SetImageID(itemMaintRec.ImageID)  ' long 
        ' IMPORT rec = itemMaintRec.Buyer  ' string 
        ' IMPORT rec = itemMaintRec.BuyerFax  ' string 
        ' IMPORT rec = itemMaintRec.BuyerEmail  ' string 
        ' IMPORT rec = itemMaintRec.Season  ' string 
        ' HEADER rec = itemMaintRec.SKUGroup  ' string 
        ' IMPORT rec = itemMaintRec.PackSKU  ' string 
        rec.StockCategory = itemMaintRec.StockCategory  ' string 
        ' IMPORT rec = itemMaintRec.TSSA  ' string 
        ' IMPORT rec = itemMaintRec.CSA  ' string 
        ' IMPORT rec = itemMaintRec.UL  ' string 
        ' IMPORT rec = itemMaintRec.LicenceAgreement  ' string 
        ' IMPORT rec = itemMaintRec.FumigationCertificate  ' string 
        ' IMPORT rec = itemMaintRec.KILNDriedCertificate  ' string 
        ' IMPORT rec = itemMaintRec.ChinaComInspecNumAndCCIBStickers  ' string 
        ' IMPORT rec = itemMaintRec.OriginalVisa  ' string 
        ' IMPORT rec = itemMaintRec.TextileDeclarationMidCode  ' string 
        ' IMPORT rec = itemMaintRec.QuotaChargeStatement  ' string 
        ' IMPORT rec = itemMaintRec.MSDS  ' string 
        ' IMPORT rec = itemMaintRec.TSCA  ' string 
        ' IMPORT rec = itemMaintRec.DropBallTestCert  ' string 
        ' IMPORT rec = itemMaintRec.ManMedicalDeviceListing  ' string 
        ' IMPORT rec = itemMaintRec.ManFDARegistration  ' string 
        ' IMPORT rec = itemMaintRec.CopyRightIndemnification  ' string 
        ' IMPORT rec = itemMaintRec.FishWildLifeCert  ' string 
        ' IMPORT rec = itemMaintRec.Proposition65LabelReq  ' string 
        ' IMPORT rec = itemMaintRec.CCCR  ' string 
        ' IMPORT rec = itemMaintRec.FormaldehydeCompliant  ' string 
        ' HEADER rec = itemMaintRec.RMSSellable  ' string 
        ' HEADER reFc = itemMaintRec.RMSOrderable  ' string 
        ' HEADER rec = itemMaintRec.RMSInventory  ' string 
        ' IMPORT rec = itemMaintRec.StoreTotal  ' integer 
        ' IMPORT rec = itemMaintRec.DisplayerCost  ' decimal 
        ' IMPORT rec = itemMaintRec.ProductCost  ' decimal 
        'rec = itemMaintRec.AddChange  ' string 
        rec.AddChange = "C"
        rec.POGSetupPerStore = itemMaintRec.POGSetupPerStore  ' decimal 
        rec.POGMaxQty = itemMaintRec.POGMaxQty  ' decimal 
        rec.ProjectedUnitSales = itemMaintRec.ProjectedUnitSales  ' decimal 
        ' IMPORT rec = itemMaintRec.VendorOrAgent  ' string 
        ' IMPORT rec = itemMaintRec.AgentType  ' string 
        ' IMPORT rec = itemMaintRec.PaymentTerms  ' string 
        ' IMPORT rec = itemMaintRec.Days  ' string 
        ' IMPORT rec = itemMaintRec.VendorMinOrderAmount  ' string 
        ' IMPORT rec = itemMaintRec.VendorName  ' string 
        ' IMPORT rec = itemMaintRec.VendorAddress1  ' string 
        ' IMPORT rec = itemMaintRec.VendorAddress2  ' string 
        ' IMPORT rec = itemMaintRec.VendorAddress3  ' string 
        ' IMPORT rec = itemMaintRec.VendorAddress4  ' string 
        ' IMPORT rec = itemMaintRec.VendorContactName  ' string 
        ' IMPORT rec = itemMaintRec.VendorContactPhone  ' string 
        ' IMPORT rec = itemMaintRec.VendorContactEmail  ' string 
        ' IMPORT rec = itemMaintRec.VendorContactFax  ' string 
        ' IMPORT rec = itemMaintRec.ManufactureName  ' string 
        ' IMPORT rec = itemMaintRec.ManufactureAddress1  ' string 
        ' IMPORT rec = itemMaintRec.ManufactureAddress2  ' string 
        ' IMPORT rec = itemMaintRec.ManufactureContact  ' string 
        ' IMPORT rec = itemMaintRec.ManufacturePhone  ' string 
        ' IMPORT rec = itemMaintRec.ManufactureEmail  ' string 
        ' IMPORT rec = itemMaintRec.ManufactureFax  ' string 
        ' IMPORT rec = itemMaintRec.AgentContact  ' string 
        ' IMPORT rec = itemMaintRec.AgentPhone  ' string 
        ' IMPORT rec = itemMaintRec.AgentEmail  ' string 
        ' IMPORT rec = itemMaintRec.AgentFax  ' string 
        ' IMPORT rec = itemMaintRec.HarmonizedCodeNumber  ' string 
        ' IMPORT rec = itemMaintRec.DetailInvoiceCustomsDesc  ' string 
        ' IMPORT rec = itemMaintRec.ComponentMaterialBreakdown  ' string 
        ' IMPORT rec = itemMaintRec.ComponentConstructionMethod  ' string 
        ' IMPORT rec = itemMaintRec.IndividualItemPackaging  ' string 
        If Not isUS Then
            rec.TotalCanadaCost = itemMaintRec.FOBShippingPoint  ' decimal 
        Else
            rec.TotalUSCost = itemMaintRec.FOBShippingPoint  ' decimal 
        End If

        ' IMPORT rec = itemMaintRec.DutyPercent  ' decimal 
        ' IMPORT rec = itemMaintRec.DutyAmount  ' decimal 
        ' IMPORT rec = itemMaintRec.AdditionalDutyComment  ' string 
        ' IMPORT rec = itemMaintRec.AdditionalDutyAmount  ' decimal 
        ' IMPORT rec = itemMaintRec.OceanFreightAmount  ' decimal 
        ' IMPORT rec = itemMaintRec.OceanFreightComputedAmount  ' decimal 
        ' IMPORT rec = itemMaintRec.AgentCommissionPercent  ' decimal 
        ' IMPORT rec = itemMaintRec.AgentCommissionAmount  ' decimal 
        ' IMPORT rec = itemMaintRec.OtherImportCostsPercent  ' decimal 
        ' IMPORT rec = itemMaintRec.OtherImportCostsAmount  ' decimal 
        ' IMPORT rec = itemMaintRec.PackagingCostAmount  ' decimal 
        ' IMPORT rec = itemMaintRec.WarehouseLandedCost  ' decimal 
        ' IMPORT rec = itemMaintRec.PurchaseOrderIssuedTo  ' string 
        ' IMPORT rec = itemMaintRec.VendorComments  ' string 
        ' IMPORT rec = itemMaintRec.FreightTerms  ' string 
        ' IMPORT rec = itemMaintRec.OutboundFreight  ' decimal 
        ' IMPORT rec = itemMaintRec.NinePercentWhseCharge  ' decimal 
        ' IMPORT rec = itemMaintRec.TotalStoreLandedCost  ' decimal 
        'rec = itemMaintRec.UpdateUserID  ' integer 
        'rec = itemMaintRec.DateLastModified  ' date 
        ' IMPORT rec = itemMaintRec.UpdateUserName  ' string 
        ' HEADER rec = itemMaintRec.StoreSupplierZoneGroup  ' string 
        ' HEADER rec = itemMaintRec.WHSSupplierZoneGroup  ' string 
        'rec = itemMaintRec.PrimaryVendor  ' boolean 

        rec.PackItemIndicator = itemMaintRec.PackItemIndicator  ' string 
        If rec.PackItemIndicator = "D" Then rec.PackItemIndicator = "D-PDQ"

        rec.ItemTypeAttribute = itemMaintRec.ItemTypeAttribute  ' string 
        rec.HybridType = itemMaintRec.HybridType  ' string 
        rec.HybridSourceDC = itemMaintRec.HybridSourceDC  ' string 
        rec.HazardousMSDSUOM = itemMaintRec.HazardousMSDSUOM  ' string 
        ' IMPORT rec = itemMaintRec.DetailInvoiceCustomsDesc0  ' string 
        ' IMPORT rec = itemMaintRec.DetailInvoiceCustomsDesc1  ' string 
        ' IMPORT rec = itemMaintRec.DetailInvoiceCustomsDesc2  ' string 
        ' IMPORT rec = itemMaintRec.DetailInvoiceCustomsDesc3  ' string 
        ' IMPORT rec = itemMaintRec.DetailInvoiceCustomsDesc4  ' string 
        ' IMPORT rec = itemMaintRec.DetailInvoiceCustomsDesc5  ' string 
        ' IMPORT rec = itemMaintRec.ComponentMaterialBreakdown0  ' string 
        ' IMPORT rec = itemMaintRec.ComponentMaterialBreakdown1  ' string 
        ' IMPORT rec = itemMaintRec.ComponentMaterialBreakdown2  ' string 
        ' IMPORT rec = itemMaintRec.ComponentMaterialBreakdown3  ' string 
        ' IMPORT rec = itemMaintRec.ComponentMaterialBreakdown4  ' string 
        ' IMPORT rec = itemMaintRec.ComponentConstructionMethod0  ' string 
        ' IMPORT rec = itemMaintRec.ComponentConstructionMethod1  ' string 
        ' IMPORT rec = itemMaintRec.ComponentConstructionMethod2  ' string 
        ' IMPORT rec = itemMaintRec.ComponentConstructionMethod3  ' string 
        rec.DepartmentNum = itemMaintRec.DepartmentNum  ' integer 
        rec.BaseRetail = itemMaintRec.Base1Retail  ' decimal 
        rec.CentralRetail = itemMaintRec.Base2Retail  ' decimal 
        rec.Retail10 = itemMaintRec.Base3Retail  ' decimal 
        rec.TestRetail = itemMaintRec.TestRetail  ' decimal 
        rec.AlaskaRetail = itemMaintRec.AlaskaRetail  ' decimal 
        rec.CanadaRetail = itemMaintRec.CanadaRetail  ' decimal 
        rec.Retail9 = itemMaintRec.High1Retail  ' decimal 
        rec.ZeroNineRetail = itemMaintRec.High2Retail  ' decimal 
        rec.CaliforniaRetail = itemMaintRec.High3Retail  ' decimal 
        rec.VillageCraftRetail = itemMaintRec.SmallMarketRetail  ' decimal 
        rec.Retail11 = itemMaintRec.Low1Retail  ' decimal 
        rec.Retail12 = itemMaintRec.Low2Retail  ' decimal 
        rec.Retail13 = itemMaintRec.ManhattanRetail  ' decimal 
        rec.RDQuebec = itemMaintRec.QuebecRetail
        rec.RDPuertoRico = itemMaintRec.PuertoRicoRetail
        rec.HazardousManufacturerName = itemMaintRec.HazardousManufacturerName  ' string 
        rec.HazardousManufacturerCity = itemMaintRec.HazardousManufacturerCity  ' string 
        rec.HazardousManufacturerState = itemMaintRec.HazardousManufacturerState  ' string 
        rec.HazardousManufacturerPhone = itemMaintRec.HazardousManufacturerPhone  ' string 
        rec.HazardousManufacturerCountry = itemMaintRec.HazardousManufacturerCountry  ' string 
        ' HEADER rec = itemMaintRec.ItemType  ' string 
        'rec.QtyInPack = itemMaintRec.QtyInPack  ' integer 
        rec.ItemStatus = itemMaintRec.ItemStatus  ' string 

        'Set Multilingual fields
        rec.PLIEnglish = itemMaintRec.PLIEnglish
        rec.PLIFrench = itemMaintRec.PLIFrench
        rec.PLISpanish = itemMaintRec.PLISpanish
        rec.TIEnglish = itemMaintRec.TIEnglish
        rec.TIFrench = itemMaintRec.TIFrench
        rec.TISpanish = itemMaintRec.TISpanish
        rec.EnglishShortDescription = itemMaintRec.EnglishShortDescription
        rec.EnglishLongDescription = itemMaintRec.EnglishLongDescription
        rec.FrenchLongDescription = itemMaintRec.FrenchLongDescription
        rec.FrenchShortDescription = itemMaintRec.FrenchShortDescription
        rec.SpanishShortDescription = itemMaintRec.SpanishShortDescription
        rec.SpanishLongDescription = itemMaintRec.SpanishLongDescription

        rec.EachCaseHeight = itemMaintRec.EachCaseHeight
        rec.EachCaseWidth = itemMaintRec.EachCaseWidth
        rec.EachCaseLength = itemMaintRec.EachCaseLength
        rec.EachCaseWeight = itemMaintRec.EachCaseWeight
        rec.EachCasePackCube = itemMaintRec.EachCaseCube
        rec.StockingStrategyCode = itemMaintRec.StockingStrategyCode

        ' return 
        Return True
    End Function

    Public Shared Function MergeItemMaintRecordIntoImportItem(ByRef rec As Models.ImportItemRecord, ByRef itemMaintRec As Models.ItemMaintItemDetailFormRecord) As Boolean
        ' merge the data
        'rec = itemMaintRec.ID  ' integer 
        'rec = itemMaintRec.BatchID  ' long 
        'rec = itemMaintRec.Enabled  ' boolean 
        'rec = itemMaintRec.IsValid  ' integer 
        rec.MichaelsSKU = itemMaintRec.SKU  ' string 
        'rec = itemMaintRec.IsLockedForChange  ' integer 
        rec.VendorNumber = itemMaintRec.VendorNumber  ' long 
        'rec = itemMaintRec.BatchTypeID  ' integer 
        'rec = itemMaintRec.VendorType  ' integer 
        rec.PrimaryUPC = itemMaintRec.PrimaryUPC  ' string 
        rec.VendorStyleNumber = itemMaintRec.VendorStyleNum  ' string 
        'rec = itemMaintRec.AdditionalUPCs  ' integer 
        If rec.AdditionalUPCRecord IsNot Nothing Then rec.AdditionalUPCRecord.AdditionalUPCs.Clear()
        If itemMaintRec.AdditionalUPCRecs IsNot Nothing Then
            For Each upc As Models.ItemMasterVendorUPCRecord In itemMaintRec.AdditionalUPCRecs
                rec.AdditionalUPCRecord.AddAdditionalUPC(upc.UPC)
            Next
        End If
        rec.Description = itemMaintRec.ItemDesc  ' string 
        rec.Class = DataHelper.SmartValuesAsString(itemMaintRec.ClassNum, "integer")  ' integer 
        rec.SubClass = DataHelper.SmartValuesAsString(itemMaintRec.SubClassNum, "integer")  ' integer 
        rec.PrivateBrandLabel = itemMaintRec.PrivateBrandLabel  ' long 
        rec.EachInsideMasterCaseBox = DataHelper.SmartValuesAsString(itemMaintRec.EachesMasterCase, "integer")  ' integer 
        rec.EachInsideInnerPack = DataHelper.SmartValuesAsString(itemMaintRec.EachesInnerPack, "integer")  ' integer 
        rec.AllowStoreOrder = itemMaintRec.AllowStoreOrder  ' string 
        rec.InventoryControl = itemMaintRec.InventoryControl  ' string 
        rec.AutoReplenish = itemMaintRec.AutoReplenish  ' string 
        rec.PrePriced = itemMaintRec.PrePriced  ' string 
        rec.PrePricedUDA = itemMaintRec.PrePricedUDA  ' long 
        rec.ProductCost = itemMaintRec.ItemCost  ' decimal 
        rec.ReshippableInnerCartonHeight = DataHelper.SmartValuesAsString(itemMaintRec.InnerCaseHeight, "decimal")  ' decimal 
        rec.ReshippableInnerCartonWidth = DataHelper.SmartValuesAsString(itemMaintRec.InnerCaseWidth, "decimal")  ' decimal 
        rec.ReshippableInnerCartonLength = DataHelper.SmartValuesAsString(itemMaintRec.InnerCaseLength, "decimal")  ' decimal 
        rec.CubicFeetPerInnerCarton = DataHelper.SmartValuesAsString(itemMaintRec.InnerCaseCube, "decimal")  ' decimal 
        'rec.EachPieceNetWeightLbsPerOunce = DataHelper.SmartValuesAsString(itemMaintRec.InnerCaseWeight, "decimal")  ' decimal 
        'rec = itemMaintRec.InnerCaseCubeUOM  ' string 
        'rec = itemMaintRec.InnerCaseWeightUOM  ' string 
        rec.MasterCartonDimensionsHeight = DataHelper.SmartValuesAsString(itemMaintRec.MasterCaseHeight, "decimal")  ' decimal 
        rec.MasterCartonDimensionsWidth = DataHelper.SmartValuesAsString(itemMaintRec.MasterCaseWidth, "decimal")  ' decimal 
        rec.MasterCartonDimensionsLength = DataHelper.SmartValuesAsString(itemMaintRec.MasterCaseLength, "decimal")  ' decimal 
        rec.WeightMasterCarton = DataHelper.SmartValuesAsString(itemMaintRec.MasterCaseWeight, "decimal")  ' decimal 
        rec.CubicFeetPerMasterCarton = DataHelper.SmartValuesAsString(itemMaintRec.MasterCaseCube, "decimal")  ' decimal 
        'rec = itemMaintRec.MasterCaseCubeUOM  ' string 
        'rec = itemMaintRec.MasterCaseWeightUOM  ' string 
        rec.CountryOfOrigin = itemMaintRec.CountryOfOrigin  ' string 
        rec.CountryOfOriginName = itemMaintRec.CountryOfOriginName  ' string 
        rec.TaxUDA = itemMaintRec.TaxUDA  ' long 
        rec.TaxValueUDA = DataHelper.SmartValuesAsString(itemMaintRec.TaxValueUDA, "long")  ' long 
        rec.Discountable = itemMaintRec.Discountable  ' string 
        rec.TotalImportBurden = DataHelper.SmartValuesAsString(itemMaintRec.ImportBurden, "decimal")  ' decimal 
        rec.ShippingPoint = itemMaintRec.ShippingPoint  ' string 
        rec.PlanogramName = itemMaintRec.PlanogramName  ' string 
        'rec = itemMaintRec.Hazardous  ' string 
        If itemMaintRec.Hazardous.Trim().ToUpper = "Y" Then
            rec.HazMatYes = "X"
            rec.HazMatNo = String.Empty
        Else
            rec.HazMatYes = String.Empty
            rec.HazMatNo = "X"
        End If
        rec.HazMatMFGFlammable = itemMaintRec.HazardousFlammable  ' string 
        rec.HazMatContainerType = itemMaintRec.HazardousContainerType  ' string 
        rec.HazMatContainerSize = DataHelper.SmartValuesAsString(itemMaintRec.HazardousContainerSize, "decimal")  ' decimal 
        rec.SetMSDSFileID(itemMaintRec.MSDSID)  ' long 
        rec.SetImageFileID(itemMaintRec.ImageID)  ' long 
        rec.Buyer = itemMaintRec.Buyer  ' string 
        rec.Fax = itemMaintRec.BuyerFax  ' string 
        rec.Email = itemMaintRec.BuyerEmail  ' string 
        rec.Season = itemMaintRec.Season  ' string 
        rec.SKUGroup = itemMaintRec.SKUGroup  ' string 
        rec.PackSKU = itemMaintRec.PackSKU  ' string 
        rec.StockCategory = itemMaintRec.StockCategory  ' string 
        rec.CoinBattery = itemMaintRec.CoinBattery
        'rec.TSSA = itemMaintRec.TSSA  ' string 
        rec.CSA = itemMaintRec.CSA  ' string 
        rec.UL = itemMaintRec.UL  ' string 
        rec.LicenceAgreement = itemMaintRec.LicenceAgreement  ' string 
        rec.FumigationCertificate = itemMaintRec.FumigationCertificate  ' string 
        rec.PhytoTemporaryShipment = itemMaintRec.PhytoTemporaryShipment  ' string
        rec.KILNDriedCertificate = itemMaintRec.KILNDriedCertificate  ' string 
        rec.ChinaComInspecNumAndCCIBStickers = itemMaintRec.ChinaComInspecNumAndCCIBStickers  ' string 
        rec.OriginalVisa = itemMaintRec.OriginalVisa  ' string 
        rec.TextileDeclarationMidCode = itemMaintRec.TextileDeclarationMidCode  ' string 
        rec.QuotaChargeStatement = itemMaintRec.QuotaChargeStatement  ' string 
        rec.MSDS = itemMaintRec.MSDS  ' string 
        rec.TSCA = itemMaintRec.TSCA  ' string 
        rec.DropBallTestCert = itemMaintRec.DropBallTestCert  ' string 
        rec.ManMedicalDeviceListing = itemMaintRec.ManMedicalDeviceListing  ' string 
        rec.ManFDARegistration = itemMaintRec.ManFDARegistration  ' string 
        rec.CopyRightIndemnification = itemMaintRec.CopyRightIndemnification  ' string 
        rec.FishWildLifeCert = itemMaintRec.FishWildLifeCert  ' string 
        rec.Proposition65LabelReq = itemMaintRec.Proposition65LabelReq  ' string 
        rec.CCCR = itemMaintRec.CCCR  ' string 
        rec.FormaldehydeCompliant = itemMaintRec.FormaldehydeCompliant  ' string 
        rec.RMSSellable = itemMaintRec.RMSSellable  ' string 
        rec.RMSOrderable = itemMaintRec.RMSOrderable  ' string 
        rec.RMSInventory = itemMaintRec.RMSInventory  ' string 
        rec.StoreTotal = itemMaintRec.StoreTotal  ' integer 
        rec.DisplayerCost = itemMaintRec.DisplayerCost  ' decimal 
        rec.ProductCost = itemMaintRec.ProductCost  ' decimal 
        'rec = itemMaintRec.AddChange  ' string 
        rec.ItemTask = "EDIT ITEM"
        rec.POGSetupPerStore = DataHelper.SmartValuesAsString(itemMaintRec.POGSetupPerStore, "decimal")  ' decimal 
        rec.POGMaxQty = DataHelper.SmartValuesAsString(itemMaintRec.POGMaxQty, "decimal")  ' decimal 
        rec.ProjSalesPerStorePerMonth = DataHelper.SmartValuesAsString(itemMaintRec.ProjectedUnitSales, "decimal")  ' decimal 
        'rec = itemMaintRec.VendorOrAgent  ' string 
        If itemMaintRec.VendorOrAgent.Trim().ToUpper() = "A" Then
            rec.Agent = "YES"
            rec.Vendor = String.Empty
        Else
            rec.Agent = String.Empty
            rec.Vendor = "YES"
        End If
        rec.AgentType = itemMaintRec.AgentType  ' string 
        rec.PaymentTerms = itemMaintRec.PaymentTerms  ' string 
        rec.Days = itemMaintRec.Days  ' string 
        rec.VendorMinOrderAmount = itemMaintRec.VendorMinOrderAmount  ' string 
        rec.VendorName = itemMaintRec.VendorName  ' string 
        rec.VendorAddress1 = itemMaintRec.VendorAddress1  ' string 
        rec.VendorAddress2 = itemMaintRec.VendorAddress2  ' string 
        rec.VendorAddress3 = itemMaintRec.VendorAddress3  ' string 
        rec.VendorAddress4 = itemMaintRec.VendorAddress4  ' string 
        rec.VendorContactName = itemMaintRec.VendorContactName  ' string 
        rec.VendorContactPhone = itemMaintRec.VendorContactPhone  ' string 
        rec.VendorContactEmail = itemMaintRec.VendorContactEmail  ' string 
        rec.VendorContactFax = itemMaintRec.VendorContactFax  ' string 
        rec.ManufactureName = itemMaintRec.ManufactureName  ' string 
        rec.ManufactureAddress1 = itemMaintRec.ManufactureAddress1  ' string 
        rec.ManufactureAddress2 = itemMaintRec.ManufactureAddress2  ' string 
        rec.ManufactureContact = itemMaintRec.ManufactureContact  ' string 
        rec.ManufacturePhone = itemMaintRec.ManufacturePhone  ' string 
        rec.ManufactureEmail = itemMaintRec.ManufactureEmail  ' string 
        rec.ManufactureFax = itemMaintRec.ManufactureFax  ' string 
        rec.AgentContact = itemMaintRec.AgentContact  ' string 
        rec.AgentPhone = itemMaintRec.AgentPhone  ' string 
        rec.AgentEmail = itemMaintRec.AgentEmail  ' string 
        rec.AgentFax = itemMaintRec.AgentFax  ' string 
        rec.HarmonizedCodeNumber = itemMaintRec.HarmonizedCodeNumber  ' string 
        rec.DetailInvoiceCustomsDesc = itemMaintRec.DetailInvoiceCustomsDesc  ' string 
        rec.ComponentMaterialBreakdown = itemMaintRec.ComponentMaterialBreakdown  ' string 
        rec.ComponentConstructionMethod = itemMaintRec.ComponentConstructionMethod  ' string 
        rec.IndividualItemPackaging = itemMaintRec.IndividualItemPackaging  ' string 
        rec.FOBShippingPoint = DataHelper.SmartValuesAsString(itemMaintRec.FOBShippingPoint, "decimal")  ' decimal 
        rec.DutyPercent = DataHelper.SmartValuesAsString(itemMaintRec.DutyPercent, "decimal")  ' decimal 
        rec.DutyAmount = DataHelper.SmartValuesAsString(itemMaintRec.DutyAmount, "decimal")  ' decimal 
        rec.AdditionalDutyComment = itemMaintRec.AdditionalDutyComment  ' string 
        rec.AdditionalDutyAmount = DataHelper.SmartValuesAsString(itemMaintRec.AdditionalDutyAmount, "decimal")  ' decimal 
        rec.SuppTariffPercent = DataHelper.SmartValuesAsString(itemMaintRec.SuppTariffPercent, "decimal")  ' decimal 
        rec.SuppTariffAmount = DataHelper.SmartValuesAsString(itemMaintRec.SuppTariffAmount, "decimal")  ' decimal 
        rec.OceanFreightAmount = DataHelper.SmartValuesAsString(itemMaintRec.OceanFreightAmount, "decimal")  ' decimal 
        rec.OceanFreightComputedAmount = DataHelper.SmartValuesAsString(itemMaintRec.OceanFreightComputedAmount, "decimal")  ' decimal 
        rec.AgentCommissionPercent = DataHelper.SmartValuesAsString(itemMaintRec.AgentCommissionPercent, "decimal")  ' decimal 
        rec.AgentCommissionAmount = DataHelper.SmartValuesAsString(itemMaintRec.AgentCommissionAmount, "decimal")  ' decimal 
        rec.OtherImportCostsPercent = DataHelper.SmartValuesAsString(itemMaintRec.OtherImportCostsPercent, "decimal")  ' decimal 
        rec.OtherImportCostsAmount = DataHelper.SmartValuesAsString(itemMaintRec.OtherImportCostsAmount, "decimal")  ' decimal 
        rec.PackagingCostAmount = DataHelper.SmartValuesAsString(itemMaintRec.PackagingCostAmount, "decimal")  ' decimal 
        rec.WarehouseLandedCost = DataHelper.SmartValuesAsString(itemMaintRec.WarehouseLandedCost, "decimal")  ' decimal 
        rec.PurchaseOrderIssuedTo = itemMaintRec.PurchaseOrderIssuedTo  ' string 
        rec.VendorComments = itemMaintRec.VendorComments  ' string 
        rec.FreightTerms = itemMaintRec.FreightTerms  ' string 
        rec.OutboundFreight = DataHelper.SmartValuesAsString(itemMaintRec.OutboundFreight, "decimal")  ' decimal 
        rec.NinePercentWhseCharge = DataHelper.SmartValuesAsString(itemMaintRec.NinePercentWhseCharge, "decimal")  ' decimal 
        rec.TotalStoreLandedCost = DataHelper.SmartValuesAsString(itemMaintRec.TotalStoreLandedCost, "decimal")  ' decimal 
        'rec = itemMaintRec.UpdateUserID  ' integer 
        'rec = itemMaintRec.DateLastModified  ' date 
        'rec = itemMaintRec.UpdateUserName  ' string 
        rec.StoreSuppZoneGRP = itemMaintRec.StoreSupplierZoneGroup  ' string 
        rec.WhseSuppZoneGRP = itemMaintRec.WHSSupplierZoneGroup  ' string 
        'rec = itemMaintRec.PrimaryVendor  ' boolean 

        rec.PackItemIndicator = itemMaintRec.PackItemIndicator  ' string 
        If rec.PackItemIndicator = "D" Then rec.PackItemIndicator = "D-PDQ"

        rec.ItemTypeAttribute = itemMaintRec.ItemTypeAttribute  ' string 
        rec.HybridType = itemMaintRec.HybridType  ' string 
        rec.SourcingDC = itemMaintRec.HybridSourceDC  ' string 
        rec.HazMatMSDSUOM = itemMaintRec.HazardousMSDSUOM  ' string 
        rec.DetailInvoiceCustomsDesc = itemMaintRec.DetailInvoiceCustomsDesc0 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.DetailInvoiceCustomsDesc1 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.DetailInvoiceCustomsDesc2 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.DetailInvoiceCustomsDesc3 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.DetailInvoiceCustomsDesc4 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.DetailInvoiceCustomsDesc5
        rec.ComponentMaterialBreakdown = itemMaintRec.ComponentMaterialBreakdown0 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.ComponentMaterialBreakdown1 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.ComponentMaterialBreakdown2 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.ComponentMaterialBreakdown3 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.ComponentMaterialBreakdown4
        rec.ComponentConstructionMethod = itemMaintRec.ComponentConstructionMethod0 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.ComponentConstructionMethod1 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.ComponentConstructionMethod2 & WebConstants.MULTILINE_DELIM & _
            itemMaintRec.ComponentConstructionMethod3
        rec.Dept = DataHelper.SmartValuesAsString(itemMaintRec.DepartmentNum, "integer")  ' integer 
        rec.RDBase = DataHelper.SmartValuesAsString(itemMaintRec.Base1Retail, "decimal")  ' decimal 
        rec.RDCentral = DataHelper.SmartValuesAsString(itemMaintRec.Base2Retail, "decimal")  ' decimal 
        rec.Retail10 = itemMaintRec.Base3Retail  ' decimal 
        rec.RDTest = DataHelper.SmartValuesAsString(itemMaintRec.TestRetail, "decimal")  ' decimal 
        rec.RDAlaska = DataHelper.SmartValuesAsString(itemMaintRec.AlaskaRetail, "decimal")  ' decimal 
        rec.RDCanada = DataHelper.SmartValuesAsString(itemMaintRec.CanadaRetail, "decimal")  ' decimal 
        rec.Retail9 = itemMaintRec.High1Retail  ' decimal 
        rec.RD0Thru9 = DataHelper.SmartValuesAsString(itemMaintRec.High2Retail, "decimal")  ' decimal 
        rec.RDCalifornia = DataHelper.SmartValuesAsString(itemMaintRec.High3Retail, "decimal")  ' decimal 
        rec.RDVillageCraft = DataHelper.SmartValuesAsString(itemMaintRec.SmallMarketRetail, "decimal")  ' decimal 
        rec.Retail11 = itemMaintRec.Low1Retail  ' decimal 
        rec.Retail12 = itemMaintRec.Low2Retail  ' decimal 
        rec.Retail13 = itemMaintRec.ManhattanRetail  ' decimal 
        rec.RDQuebec = itemMaintRec.QuebecRetail
        rec.RDPuertoRico = itemMaintRec.PuertoRicoRetail
        rec.HazMatMFGName = itemMaintRec.HazardousManufacturerName  ' string 
        rec.HazMatMFGCity = itemMaintRec.HazardousManufacturerCity  ' string 
        rec.HazMatMFGState = itemMaintRec.HazardousManufacturerState  ' string 
        rec.HazMatMFGPhone = itemMaintRec.HazardousManufacturerPhone  ' string 
        rec.HazMatMFGCountry = itemMaintRec.HazardousManufacturerCountry  ' string 
        rec.ItemType = itemMaintRec.ItemType  ' string 
        'rec = itemMaintRec.QtyInPack  ' integer 
        'rec = itemMaintRec.ItemStatus  ' string 
        rec.ItemStatus = itemMaintRec.ItemStatus

        rec.EachHeight = DataHelper.SmartValuesAsString(itemMaintRec.EachCaseHeight, "decimal")  ' decimal 
        rec.EachWidth = DataHelper.SmartValuesAsString(itemMaintRec.EachCaseWidth, "decimal")  ' decimal 
        rec.EachLength = DataHelper.SmartValuesAsString(itemMaintRec.EachCaseLength, "decimal")  ' decimal 
        rec.EachWeight = DataHelper.SmartValuesAsString(itemMaintRec.EachCaseWeight, "decimal")  ' decimal 
        rec.CubicFeetEach = DataHelper.SmartValuesAsString(itemMaintRec.EachCaseCube, "decimal")  ' decimal 

        rec.ReshippableInnerCartonWeight = DataHelper.SmartValuesAsString(itemMaintRec.InnerCaseWeight, "decimal")  ' decimal 

        rec.StockingStrategyCode = itemMaintRec.StockingStrategyCode
        rec.CanadaHarmonizedCodeNumber = itemMaintRec.CanadaHarmonizedCodeNumber

        'Set Multilingual fields
        Dim languageDT As DataTable = Data.MaintItemMasterData.GetItemLanguages(itemMaintRec.SKU, itemMaintRec.VendorNumber)
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
                        rec.PLIEnglish = pli
                        rec.TIEnglish = ti
                        rec.EnglishShortDescription = descShort
                        rec.EnglishLongDescription = descLong
                    Case 2
                        rec.PLIFrench = pli
                        rec.TIFrench = ti
                        rec.FrenchShortDescription = descShort
                        rec.FrenchLongDescription = descLong
                        rec.ExemptEndDateFrench = exemptEndDate
                    Case 3
                        rec.PLISpanish = pli
                        rec.TISpanish = ti
                        rec.SpanishShortDescription = descShort
                        rec.SpanishLongDescription = descLong
                End Select
            Next
        End If


        ' return 
        Return True
    End Function


    ' ------------------------------------------------------------------------------------------------------
    ' Item Cost Rollup
    ' ------------------------------------------------------------------------------------------------------

    Public Shared Function CalculateDomesticDPBatchParent(ByRef itemHeader As Models.ItemHeaderRecord, ByVal costChanged As Boolean, ByVal masterWeightChanged As Boolean) As Boolean
        Dim ret As Boolean = False
        Dim validPack As Boolean = True
        Dim userID As Long = DataHelper.SmartValues(HttpContext.Current.Session("UserID"), "long")
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim itemHeaderID As Long = IIf(itemHeader IsNot Nothing, itemHeader.ID, 0)

        Dim itemList As Models.ItemList = Nothing
        Dim itemRec As Models.ItemRecord = Nothing
        Dim packRec As Models.ItemRecord = Nothing
        Dim i As Integer
        Dim setUS As Boolean = False
        Dim setCanada As Boolean = False
        Dim totalUS As Decimal = 0
        Dim totalCanada As Decimal = 0
        Dim totalWeight As Decimal = 0
        Dim qtyInPack As Integer
        Dim USCost As Decimal
        Dim CanadaCost As Decimal
        Dim masterWeight As Decimal

        If itemHeader IsNot Nothing AndAlso Data.ItemDetail.IsPack(itemHeaderID) Then
            ' get the list
            Dim strXML As String = GetDefaultSortAndFilterXML()

            itemList = objMichaels.GetList(itemHeaderID, 0, 0, GetDefaultSortAndFilterXML(), userID)
            'go through the list and calculate cost and find the pack record
            For i = 0 To itemList.ListRecords.Count - 1
                itemRec = itemList.ListRecords.Item(i)
                If itemRec.IsPackParent() Then
                    If packRec IsNot Nothing Then
                        ret = False
                        validPack = False
                        Exit For
                    Else
                        packRec = itemRec
                    End If
                Else
                    ' add to total cost
                    qtyInPack = itemRec.QtyInPack
                    USCost = itemRec.USCost
                    CanadaCost = itemRec.CanadaCost

                    If qtyInPack >= 0 Then
                        If USCost >= 0 Then
                            totalUS += (qtyInPack * USCost)
                            setUS = True
                        End If
                        If CanadaCost >= 0 Then
                            totalCanada += (qtyInPack * CanadaCost)
                            setCanada = True
                        End If
                    End If

                    ' add to total weight 
                    masterWeight = itemRec.MasterCaseWeight
                    If masterWeight >= 0 Then
                        totalWeight += masterWeight
                    End If

                End If
            Next
            ' if valid pack then calculate parent rec
            If validPack AndAlso packRec IsNot Nothing Then
                itemRec = packRec

                If costChanged Then
                    ' set the new item cost
                    If setUS Then itemRec.USCost = totalUS
                    If setCanada Then itemRec.CanadaCost = totalCanada

                    If itemHeader.ItemType <> "R" And itemHeader.AddUnitCost >= 0 Then
                        totalUS += itemHeader.AddUnitCost
                        totalCanada += itemHeader.AddUnitCost
                    End If

                    ' set the new item total cost(s)
                    If setUS Then itemRec.TotalUSCost = totalUS
                    If setCanada Then itemRec.TotalCanadaCost = totalCanada
                End If

                'NAK - Per Michaels Decision on 1/17/2012, remove the weight rollup calculation for the pack item altogether
                'If masterWeightChanged Then
                '   itemRec.WeightMasterCarton = totalWeight
                'End If


                ' save the changes
                objMichaels.SaveRecord(itemRec, userID)

                ' set return value
                ret = True
            End If
            ' clean up
            itemRec = Nothing
            itemList = Nothing
        End If
        objMichaels = Nothing

        Return ret
    End Function

    Public Shared Function CheckAndCalculateImportDPBatchParent(ByVal batchID As Long, ByVal costChanged As Boolean, ByVal masterWeightChanged As Boolean) As Boolean
        Dim ret As Boolean = False
        Dim validPack As Boolean = True
        Dim userID As Long = DataHelper.SmartValues(HttpContext.Current.Session("UserID"), "long")

        Dim itemList As Models.ImportItemList = Nothing
        Dim itemRec As Models.ImportItemRecord = Nothing
        Dim packRec As Models.ImportItemRecord = Nothing
        Dim i As Integer
        Dim total As Decimal = 0
        Dim totalWeight As Decimal = 0
        Dim qtyInPack As Integer
        Dim itemCost As Decimal
        Dim masterWeight As Decimal
        Dim objMichaels As New NovaLibra.Coral.Data.Michaels.ImportItemDetail()

        If NovaLibra.Coral.Data.Michaels.ImportItemDetail.IsPack(batchID) Then
            ' get the list

            itemList = objMichaels.GetItemList(batchID)

            'go through the list and calculate cost and find the pack record
            For i = 0 To itemList.ListRecords.Count - 1
                itemRec = itemList.ListRecords.Item(i)

                If itemRec.IsPackParent() Then
                    If packRec IsNot Nothing Then
                        ret = False
                        validPack = False
                        Exit For
                    Else
                        packRec = itemRec
                    End If
                Else
                    ' add to total cost
                    qtyInPack = itemRec.QtyInPack
                    itemCost = itemRec.ProductCost

                    If qtyInPack >= 0 AndAlso itemCost >= 0 Then
                        total += (qtyInPack * itemCost)
                    End If

                    ' add to total weight
                    masterWeight = DataHelper.SmartValues(itemRec.WeightMasterCarton, "decimal", False)
                    If masterWeight >= 0 Then
                        totalWeight += masterWeight
                    End If
                End If
            Next
            ' if valid pack then calculate parent rec
            If validPack AndAlso packRec IsNot Nothing AndAlso Not packRec.ValidExistingSKU Then
                itemRec = objMichaels.GetItemRecord(packRec.ID)

                If costChanged Then
                    ' set the new item cost
                    itemRec.ProductCost = total
                    ' calc

                    ' set values
                    ' ----------
                    ' input vars

                    Dim agent As String = itemRec.Agent
                    Dim dispcost As Decimal = itemRec.DisplayerCost
                    Dim prodcost As Decimal = total
                    Dim fob As Decimal = DataHelper.SmartValues(itemRec.FOBShippingPoint, "decimal", True)
                    Dim dutyper As Decimal = DataHelper.SmartValues(itemRec.DutyPercent, "decimal", True)
                    If dutyper <> Decimal.MinValue Then dutyper = dutyper * 100
                    Dim addduty As Decimal = DataHelper.SmartValues(itemRec.AdditionalDutyAmount, "decimal", True)

                    Dim supptariffper As Decimal = DataHelper.SmartValues(itemRec.SuppTariffPercent, "decimal", True)
                    If supptariffper <> Decimal.MinValue Then supptariffper = supptariffper * 100

                    Dim eachesmc As Decimal = DataHelper.SmartValues(itemRec.EachInsideMasterCaseBox, "decimal", True)
                    Dim mclength As Decimal = DataHelper.SmartValues(itemRec.MasterCartonDimensionsLength, "decimal", True)
                    Dim mcwidth As Decimal = DataHelper.SmartValues(itemRec.MasterCartonDimensionsWidth, "decimal", True)
                    Dim mcheight As Decimal = DataHelper.SmartValues(itemRec.MasterCartonDimensionsHeight, "decimal", True)
                    Dim oceanfre As Decimal = DataHelper.SmartValues(itemRec.OceanFreightAmount, "decimal", True)
                    Dim oceanamt As Decimal = DataHelper.SmartValues(itemRec.OceanFreightComputedAmount, "decimal", True)
                    Dim agentcommper As Decimal = DataHelper.SmartValues(itemRec.AgentCommissionPercent, "decimal", True)
                    If agentcommper <> Decimal.MinValue Then agentcommper = agentcommper * 100
                    Dim otherimportper As Decimal = DataHelper.SmartValues(itemRec.OtherImportCostsPercent, "decimal", True)
                    If otherimportper <> Decimal.MinValue Then otherimportper = otherimportper * 100
                    Dim packcost As Decimal = Decimal.MinValue


                    ' calculated vars
                    fob = CalculationHelper.CalcImportFOB(dispcost, prodcost)
                    Dim cubicftpermc As Decimal = CalculationHelper.CalcImportCubicFeetPerMasterCarton(mclength, mcwidth, mcheight)
                    Dim duty As Decimal = CalculationHelper.CalcImportDuty(fob, dutyper)
                    Dim supptariff As Decimal = CalculationHelper.CalcSuppTariff(fob, supptariffper)
                    Dim ocean As Decimal = CalculationHelper.CalcImportOceanFrieght(eachesmc, cubicftpermc, oceanfre)
                    Dim agentcomm As Decimal = CalculationHelper.CalcImportAgentComm(agent, fob, agentcommper)
                    Dim otherimport As Decimal = CalculationHelper.CalcOtherImportCost(fob, otherimportper)
                    Dim totalimport As Decimal = CalculationHelper.CalcImportTotalImport(agent, fob, duty, addduty, ocean, agentcomm, otherimport, packcost, supptariff)
                    Dim totalcost As Decimal = CalculationHelper.CalcImportTotalCost(fob, totalimport)
                    Dim outfreight As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost)
                    Dim ninewhse As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost, outfreight)
                    Dim totalstore As Decimal = CalculationHelper.CalcImportTotalStore(totalcost, outfreight, ninewhse)

                    ' store results
                    ' ------------
                    itemRec.FOBShippingPoint = DataHelper.SmartValuesAsString(fob, "decimal")
                    itemRec.CubicFeetPerMasterCarton = DataHelper.SmartValuesAsString(cubicftpermc, "decimal")
                    itemRec.DutyAmount = DataHelper.SmartValuesAsString(duty, "decimal")
                    itemRec.SuppTariffAmount = DataHelper.SmartValuesAsString(supptariff, "decimal")
                    itemRec.OceanFreightComputedAmount = DataHelper.SmartValuesAsString(ocean, "decimal")
                    itemRec.AgentCommissionAmount = DataHelper.SmartValuesAsString(agentcomm, "decimal")
                    itemRec.OtherImportCostsAmount = DataHelper.SmartValuesAsString(otherimport, "decimal")
                    itemRec.TotalImportBurden = DataHelper.SmartValuesAsString(totalimport, "decimal")
                    itemRec.WarehouseLandedCost = DataHelper.SmartValuesAsString(totalcost, "decimal")
                    itemRec.OutboundFreight = DataHelper.SmartValuesAsString(outfreight, "decimal")
                    itemRec.NinePercentWhseCharge = DataHelper.SmartValuesAsString(ninewhse, "decimal")
                    itemRec.TotalStoreLandedCost = DataHelper.SmartValuesAsString(totalstore, "decimal")
                End If

                'NAK - Per Michaels Decision on 1/17/2012, remove the weight rollup calculation for the pack item altogether
                'If masterWeightChanged Then
                '   itemRec.WeightMasterCarton = totalWeight
                'End If

                ' save the changes
                objMichaels.SaveItemRecord(itemRec, userID, False, "", "", True)

                ' set return value
                ret = True
            End If



            ' clean up
            itemRec = Nothing
            itemList.ClearList()
            itemList = Nothing
        End If
        objMichaels = Nothing

        Return ret
    End Function


    Protected Shared Function GetDefaultSortAndFilterXML() As String

        Dim XMLStr As String = "<Root>"
        ' sort
        XMLStr += "<Sort><Parameter SortID=""1"" intColOrdinal=""0"" intDirection=""0"" /></Sort>"
        ' filter
        XMLStr += "<Filter/>"
        ' close
        XMLStr = "<?xml version=""1.0"" encoding=""utf-8"" ?>" & XMLStr & "</Root>"
        ' return 
        Return XMLStr

    End Function

    Public Shared Function RoundDimesionsDecimal(ByVal value As Decimal, Optional ByVal NumOfDigits As Integer = 4) As Decimal
        If value = Nothing Then
            Return value
        ElseIf value = System.Decimal.MinValue Then
            Return value
        Else
            'Return Math.Round(value, 2, MidpointRounding.AwayFromZero)
            Return Math.Round(value, NumOfDigits, MidpointRounding.AwayFromZero)
        End If
    End Function

    Public Shared Function RoundDimesionsString(ByVal value As String, Optional ByVal NumOfDigits As Integer = 4) As String
        Dim dVal As Decimal
        If Decimal.TryParse(value, dVal) Then
            If value = Nothing Then
                Return value
            ElseIf value = System.Decimal.MinValue Then
                Return value
            Else
                'Return Math.Round(dVal, 2, MidpointRounding.AwayFromZero)
                Return Math.Round(dVal, NumOfDigits, MidpointRounding.AwayFromZero)
            End If
        Else
            Return value
        End If
    End Function

End Class
