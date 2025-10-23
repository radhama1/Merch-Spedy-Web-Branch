Namespace Michaels

    Public Class ItemMaintUploadChangeRecord

        Private _skuID As Integer = 0
        Private _michaelsSKU As String = String.Empty
        Private _vendorNbr As String = String.Empty
        Private _dept As String = String.Empty
        Private _upc As String = String.Empty
        Private _innerGTIN As String = String.Empty
        Private _caseGTIN As String = String.Empty
        Private _vpn As String = String.Empty
        Private _skuDesc As String = String.Empty
        Private _eachesMasterCase As String = String.Empty
        Private _eachesInnerPack As String = String.Empty
        Private _allowStoreOrder As String = String.Empty
        Private _inventoryControl As String = String.Empty
        Private _autoReplenish As String = String.Empty
        Private _prePriced As String = String.Empty
        Private _prePricedUDA As String = String.Empty
        Private _cost As String = String.Empty
        Private _eachPackHeight As String = String.Empty
        Private _eachPackWidth As String = String.Empty
        Private _eachPackLength As String = String.Empty
        Private _eachPackWeight As String = String.Empty
        Private _innerPackHeight As String = String.Empty
        Private _innerPackWidth As String = String.Empty
        Private _innerPackLength As String = String.Empty
        Private _innerPackWeight As String = String.Empty
        Private _masterCaseHeight As String = String.Empty
        Private _masterCaseWidth As String = String.Empty
        Private _masterCaseLength As String = String.Empty
        Private _masterCaseWeight As String = String.Empty
        Private _countryOfOrigin As String = String.Empty
        Private _taxUDA As String = String.Empty
        Private _taxValueUDA As String = String.Empty
        Private _discountable As String = String.Empty
        Private _importBurden As String = String.Empty
        Private _shippingPoint As String = String.Empty
        Private _planogramName As String = String.Empty
        Private _privateBrandLabel As String = String.Empty

        Private _pliEnglish As String = String.Empty
        Private _pliFrench As String = String.Empty
        Private _pliSpanish As String = String.Empty
        Private _tiEnglish As String = String.Empty
        Private _tiFrench As String = String.Empty
        Private _tiSpanish As String = String.Empty
        Private _customsDescription As String = String.Empty
        Private _englishLongDescription As String = String.Empty
        Private _englishShortDescription As String = String.Empty
        Private _exemptEndDateFrench As String = String.Empty

        Private _harmonizedCodeNumber As String = String.Empty
        Private _canadaHarmonizedCodeNumber As String = String.Empty
        Private _detailInvoiceCustomsDesc As String = String.Empty
        Private _componentMaterialBreakdown As String = String.Empty

        Private _vendorName As String = String.Empty

        Private _itemDesc As String = String.Empty
        Private _componentConstructionMethod As String = String.Empty

        Private _CoinBattery As String = String.Empty
        Private _TSSA As String = String.Empty
        Private _CSA As String = String.Empty
        Private _UL As String = String.Empty
        Private _LicenceAgreement As String = String.Empty
        Private _FumigationCertificate As String = String.Empty
        Private _KILNDriedCertificate As String = String.Empty
        Private _chinaComInspecNumAndCCIBStickers As String = String.Empty
        Private _originalVisa As String = String.Empty
        Private _textileDeclarationMidCode As String = String.Empty
        Private _quotaChargeStatement As String = String.Empty
        Private _MSDS As String = String.Empty
        Private _TSCA As String = String.Empty
        Private _dropBallTestCert As String = String.Empty
        Private _manMedicalDeviceListing As String = String.Empty
        Private _manFDARegistration As String = String.Empty
        Private _copyRightIndemnification As String = String.Empty
        Private _fishWildLifeCert As String = String.Empty
        Private _proposition65LabelReq As String = String.Empty
        Private _CCCR As String = String.Empty
        Private _formaldehydeCompliant As String = String.Empty
        Private _dutyPercent As String = String.Empty
        Private _additionalDutyComment As String = String.Empty
        Private _additionalDutyAmount As String = String.Empty
        Private _agentCommissionPercent As String = String.Empty
        Private _suppTariffPercent As String = String.Empty
        Private _oceanFreightAmount As String = String.Empty

        Private _hazardous As String = String.Empty
        Private _hazardousFlammable As String = String.Empty
        Private _hazardousContainerType As String = String.Empty
        Private _hazardousContainerSize As String = String.Empty
        Private _hazardousMSDSUOM As String = String.Empty
        Private _hazardousManufacturerName As String = String.Empty
        Private _hazardousManufacturerCity As String = String.Empty
        Private _hazardousManufacturerState As String = String.Empty
        Private _hazardousManufacturerPhone As String = String.Empty
        Private _hazardousManufacturerCountry As String = String.Empty

        Private _stockingStrategyCode As String = String.Empty

        Private _itemCost As String = String.Empty
        Private _productCost As String = String.Empty
        Private _PhytoTemporaryShipment As String = String.Empty

        Public Property SkuID() As Integer
            Get
                Return _skuID
            End Get
            Set(value As Integer)
                _skuID = value
            End Set
        End Property

        Public Property MichaelsSKU() As String
            Get
                Return _michaelsSKU
            End Get
            Set(ByVal value As String)
                _michaelsSKU = value
            End Set
        End Property

        Public Property VendorNbr() As String
            Get
                Return _vendorNbr
            End Get
            Set(ByVal value As String)
                _vendorNbr = value
            End Set
        End Property

        Public Property VendorName() As String
            Get
                Return _vendorName
            End Get
            Set(ByVal value As String)
                _vendorName = value
            End Set
        End Property

        Public Property Dept() As String
            Get
                Return _dept
            End Get
            Set(ByVal value As String)
                _dept = value
            End Set
        End Property

        Public Property UPC() As String
            Get
                Return _upc
            End Get
            Set(ByVal value As String)
                _upc = value
            End Set
        End Property

        Public Property InnerGTIN() As String
            Get
                Return _innerGTIN
            End Get
            Set(ByVal value As String)
                _innerGTIN = value
            End Set
        End Property

        Public Property CaseGTIN() As String
            Get
                Return _caseGTIN
            End Get
            Set(ByVal value As String)
                _caseGTIN = value
            End Set
        End Property

        Public Property VPN() As String
            Get
                Return _vpn
            End Get
            Set(ByVal value As String)
                _vpn = value
            End Set
        End Property

        Public Property SKUDescription() As String
            Get
                Return _skuDesc
            End Get
            Set(ByVal value As String)
                _skuDesc = value
            End Set
        End Property

        Public Property EachesMasterCase() As String
            Get
                Return _eachesMasterCase
            End Get
            Set(ByVal value As String)
                _eachesMasterCase = value
            End Set
        End Property

        Public Property EachesInnerPack() As String
            Get
                Return _eachesInnerPack
            End Get
            Set(ByVal value As String)
                _eachesInnerPack = value
            End Set
        End Property

        Public Property AllowStoreOrder() As String
            Get
                Return _allowStoreOrder
            End Get
            Set(ByVal value As String)
                _allowStoreOrder = value
            End Set
        End Property

        Public Property InventoryControl() As String
            Get
                Return _inventoryControl
            End Get
            Set(ByVal value As String)
                _inventoryControl = value
            End Set
        End Property

        Public Property AutoReplenish() As String
            Get
                Return _autoReplenish
            End Get
            Set(ByVal value As String)
                _autoReplenish = value
            End Set
        End Property

        Public Property PrePriced() As String
            Get
                Return _prePriced
            End Get
            Set(ByVal value As String)
                _prePriced = value
            End Set
        End Property

        Public Property PrePricedUDA() As String
            Get
                Return _prePricedUDA
            End Get
            Set(ByVal value As String)
                _prePricedUDA = value
            End Set
        End Property

        Public Property Cost() As String
            Get
                Return _cost
            End Get
            Set(ByVal value As String)
                _cost = value
            End Set
        End Property

        Public Property EachPackHeight() As String
            Get
                Return _eachPackHeight
            End Get
            Set(ByVal value As String)
                _eachPackHeight = value
            End Set
        End Property

        Public Property EachPackWidth() As String
            Get
                Return _eachPackWidth
            End Get
            Set(ByVal value As String)
                _eachPackWidth = value
            End Set
        End Property

        Public Property EachPackLength() As String
            Get
                Return _eachPackLength
            End Get
            Set(ByVal value As String)
                _eachPackLength = value
            End Set
        End Property

        Public Property EachPackWeight() As String
            Get
                Return _eachPackWeight
            End Get
            Set(ByVal value As String)
                _eachPackWeight = value
            End Set
        End Property

        Public Property InnerPackHeight() As String
            Get
                Return _innerPackHeight
            End Get
            Set(ByVal value As String)
                _innerPackHeight = value
            End Set
        End Property

        Public Property InnerPackWidth() As String
            Get
                Return _innerPackWidth
            End Get
            Set(ByVal value As String)
                _innerPackWidth = value
            End Set
        End Property

        Public Property InnerPackLength() As String
            Get
                Return _innerPackLength
            End Get
            Set(ByVal value As String)
                _innerPackLength = value
            End Set
        End Property

        Public Property InnerPackWeight() As String
            Get
                Return _innerPackWeight
            End Get
            Set(ByVal value As String)
                _innerPackWeight = value
            End Set
        End Property

        Public Property MasterCaseHeight() As String
            Get
                Return _masterCaseHeight
            End Get
            Set(ByVal value As String)
                _masterCaseHeight = value
            End Set
        End Property

        Public Property MasterCaseWidth() As String
            Get
                Return _masterCaseWidth
            End Get
            Set(ByVal value As String)
                _masterCaseWidth = value
            End Set
        End Property

        Public Property MasterCaseLength() As String
            Get
                Return _masterCaseLength
            End Get
            Set(ByVal value As String)
                _masterCaseLength = value
            End Set
        End Property

        Public Property MasterCaseWeight() As String
            Get
                Return _masterCaseWeight
            End Get
            Set(ByVal value As String)
                _masterCaseWeight = value
            End Set
        End Property

        Public Property CountryOfOrigin() As String
            Get
                Return _countryOfOrigin
            End Get
            Set(ByVal value As String)
                _countryOfOrigin = value
            End Set
        End Property

        Public Property TaxUDA() As String
            Get
                Return _taxUDA
            End Get
            Set(ByVal value As String)
                _taxUDA = value
            End Set
        End Property

        Public Property TaxValueUDA() As String
            Get
                Return _TaxValueUDA
            End Get
            Set(ByVal value As String)
                _TaxValueUDA = value
            End Set
        End Property

        Public Property Discountable() As String
            Get
                Return _discountable
            End Get
            Set(ByVal value As String)
                _discountable = value
            End Set
        End Property

        Public Property ImportBurden() As String
            Get
                Return _importBurden
            End Get
            Set(ByVal value As String)
                _importBurden = value
            End Set
        End Property

        Public Property ShippingPoint() As String
            Get
                Return _shippingPoint
            End Get
            Set(ByVal value As String)
                _shippingPoint = value
            End Set
        End Property

        Public Property PlanogramName() As String
            Get
                Return _planogramName
            End Get
            Set(ByVal value As String)
                _planogramName = value
            End Set
        End Property

        Public Property PrivateBrandLabel() As String
            Get
                Return _privateBrandLabel
            End Get
            Set(ByVal value As String)
                _privateBrandLabel = value
            End Set
        End Property

        Public Property PLIEnglish() As String
            Get
                Return _pliEnglish
            End Get
            Set(ByVal value As String)
                _pliEnglish = value
            End Set
        End Property

        Public Property PLIFrench() As String
            Get
                Return _pliFrench
            End Get
            Set(ByVal value As String)
                _pliFrench = value
            End Set
        End Property
        Public Property PLISpanish() As String
            Get
                Return _pliSpanish
            End Get
            Set(ByVal value As String)
                _pliSpanish = value
            End Set
        End Property

        Public Property TIEnglish() As String
            Get
                Return _tiEnglish
            End Get
            Set(ByVal value As String)
                _tiEnglish = value
            End Set
        End Property

        Public Property TIFrench() As String
            Get
                Return _tiFrench
            End Get
            Set(ByVal value As String)
                _tiFrench = value
            End Set
        End Property

        Public Property TISpanish() As String
            Get
                Return _tiSpanish
            End Get
            Set(ByVal value As String)
                _tiSpanish = value
            End Set
        End Property

        Public Property CustomsDescription() As String
            Get
                Return _customsDescription
            End Get
            Set(ByVal value As String)
                _customsDescription = value
            End Set
        End Property

        Public Property EnglishLongDescription() As String
            Get
                Return _englishLongDescription
            End Get
            Set(ByVal value As String)
                _englishLongDescription = value
            End Set
        End Property

        Public Property EnglishShortDescription() As String
            Get
                Return _englishShortDescription
            End Get
            Set(ByVal value As String)
                _englishShortDescription = value
            End Set
        End Property

        Public Property HarmonizedCodeNumber() As String
            Get
                Return _harmonizedCodeNumber
            End Get
            Set(ByVal value As String)
                _harmonizedCodeNumber = value
            End Set
        End Property

        Public Property CanadaHarmonizedCodeNumber() As String
            Get
                Return _canadaHarmonizedCodeNumber
            End Get
            Set(ByVal value As String)
                _canadaHarmonizedCodeNumber = value
            End Set
        End Property

        Public Property DetailInvoiceCustomsDesc() As String
            Get
                Return _detailInvoiceCustomsDesc
            End Get
            Set(ByVal value As String)
                _detailInvoiceCustomsDesc = value
            End Set
        End Property

        Public Property ComponentMaterialBreakdown() As String
            Get
                Return _componentMaterialBreakdown
            End Get
            Set(ByVal value As String)
                _componentMaterialBreakdown = value
            End Set
        End Property

        Public Property ExemptEndDateFrench() As String
            Get
                Return _exemptEndDateFrench
            End Get
            Set(value As String)
                _exemptEndDateFrench = value
            End Set
        End Property

        Public Property ItemDesc() As String
            Get
                Return _itemDesc
            End Get
            Set(value As String)
                _itemDesc = value
            End Set
        End Property

        Public Property ComponentConstructionMethod() As String
            Get
                Return _componentConstructionMethod
            End Get
            Set(value As String)
                _componentConstructionMethod = value
            End Set
        End Property

        Public Property CoinBattery() As String
            Get
                Return _CoinBattery
            End Get
            Set(ByVal value As String)
                _CoinBattery = value
            End Set
        End Property
        Public Property TSSA() As String
            Get
                Return _TSSA
            End Get
            Set(ByVal value As String)
                _TSSA = value
            End Set
        End Property
        Public Property CSA() As String
            Get
                Return _CSA
            End Get
            Set(ByVal value As String)
                _CSA = value
            End Set
        End Property
        Public Property UL() As String
            Get
                Return _UL
            End Get
            Set(ByVal value As String)
                _UL = value
            End Set
        End Property
        Public Property LicenceAgreement() As String
            Get
                Return _LicenceAgreement
            End Get
            Set(ByVal value As String)
                _LicenceAgreement = value
            End Set
        End Property
        Public Property FumigationCertificate() As String
            Get
                Return _FumigationCertificate
            End Get
            Set(ByVal value As String)
                _FumigationCertificate = value
            End Set
        End Property
        Public Property KILNDriedCertificate() As String
            Get
                Return _KILNDriedCertificate
            End Get
            Set(ByVal value As String)
                _KILNDriedCertificate = value
            End Set
        End Property
        Public Property ChinaComInspecNumAndCCIBStickers() As String
            Get
                Return _chinaComInspecNumAndCCIBStickers
            End Get
            Set(ByVal value As String)
                _chinaComInspecNumAndCCIBStickers = value
            End Set
        End Property
        Public Property OriginalVisa() As String
            Get
                Return _originalVisa
            End Get
            Set(ByVal value As String)
                _originalVisa = value
            End Set
        End Property
        Public Property TextileDeclarationMidCode() As String
            Get
                Return _textileDeclarationMidCode
            End Get
            Set(ByVal value As String)
                _textileDeclarationMidCode = value
            End Set
        End Property
        Public Property QuotaChargeStatement() As String
            Get
                Return _quotaChargeStatement
            End Get
            Set(ByVal value As String)
                _quotaChargeStatement = value
            End Set
        End Property
        Public Property MSDS() As String
            Get
                Return _MSDS
            End Get
            Set(ByVal value As String)
                _MSDS = value
            End Set
        End Property
        Public Property TSCA() As String
            Get
                Return _TSCA
            End Get
            Set(ByVal value As String)
                _TSCA = value
            End Set
        End Property
        Public Property DropBallTestCert() As String
            Get
                Return _dropBallTestCert
            End Get
            Set(ByVal value As String)
                _dropBallTestCert = value
            End Set
        End Property
        Public Property ManMedicalDeviceListing() As String
            Get
                Return _manMedicalDeviceListing
            End Get
            Set(ByVal value As String)
                _manMedicalDeviceListing = value
            End Set
        End Property
        Public Property ManFDARegistration() As String
            Get
                Return _manFDARegistration
            End Get
            Set(ByVal value As String)
                _manFDARegistration = value
            End Set
        End Property
        Public Property CopyRightIndemnification() As String
            Get
                Return _copyRightIndemnification
            End Get
            Set(ByVal value As String)
                _copyRightIndemnification = value
            End Set
        End Property
        Public Property FishWildLifeCert() As String
            Get
                Return _fishWildLifeCert
            End Get
            Set(ByVal value As String)
                _fishWildLifeCert = value
            End Set
        End Property
        Public Property Proposition65LabelReq() As String
            Get
                Return _proposition65LabelReq
            End Get
            Set(ByVal value As String)
                _proposition65LabelReq = value
            End Set
        End Property
        Public Property CCCR() As String
            Get
                Return _CCCR
            End Get
            Set(ByVal value As String)
                _CCCR = value
            End Set
        End Property
        Public Property FormaldehydeCompliant() As String
            Get
                Return _formaldehydeCompliant
            End Get
            Set(ByVal value As String)
                _formaldehydeCompliant = value
            End Set
        End Property
        Public Property DutyPercent() As String
            Get
                Return _dutyPercent
            End Get
            Set(ByVal value As String)
                _dutyPercent = value
            End Set
        End Property
        Public Property AdditionalDutyComment() As String
            Get
                Return _additionalDutyComment
            End Get
            Set(ByVal value As String)
                _additionalDutyComment = value
            End Set
        End Property
        Public Property AdditionalDutyAmount() As String
            Get
                Return _additionalDutyAmount
            End Get
            Set(value As String)
                _additionalDutyAmount = value
            End Set
        End Property

        Public Property SuppTariffPercent() As String
            Get
                Return _suppTariffPercent
            End Get
            Set(ByVal value As String)
                _suppTariffPercent = value
            End Set
        End Property

        Public Property AgentCommissionPercent() As String
            Get
                Return _agentCommissionPercent
            End Get
            Set(ByVal value As String)
                _agentCommissionPercent = value
            End Set
        End Property
        Public Property OceanFreightAmount() As String
            Get
                Return _oceanFreightAmount
            End Get
            Set(ByVal value As String)
                _oceanFreightAmount = value
            End Set
        End Property
        Public Property Hazardous() As String
            Get
                Return _hazardous
            End Get
            Set(ByVal value As String)
                _hazardous = value
            End Set
        End Property
        Public Property HazardousFlammable() As String
            Get
                Return _hazardousFlammable
            End Get
            Set(ByVal value As String)
                _hazardousFlammable = value
            End Set
        End Property
        Public Property HazardousContainerType() As String
            Get
                Return _hazardousContainerType
            End Get
            Set(ByVal value As String)
                _hazardousContainerType = value
            End Set
        End Property
        Public Property HazardousContainerSize() As String
            Get
                Return _hazardousContainerSize
            End Get
            Set(ByVal value As String)
                _hazardousContainerSize = value
            End Set
        End Property
        Public Property HazardousMSDSUOM() As String
            Get
                Return _hazardousMSDSUOM
            End Get
            Set(ByVal value As String)
                _hazardousMSDSUOM = value
            End Set
        End Property
        Public Property HazardousManufacturerName() As String
            Get
                Return _hazardousManufacturerName
            End Get
            Set(ByVal value As String)
                _hazardousManufacturerName = value
            End Set
        End Property
        Public Property HazardousManufacturerCity() As String
            Get
                Return _hazardousManufacturerCity
            End Get
            Set(ByVal value As String)
                _hazardousManufacturerCity = value
            End Set
        End Property
        Public Property HazardousManufacturerState() As String
            Get
                Return _hazardousManufacturerState
            End Get
            Set(ByVal value As String)
                _hazardousManufacturerState = value
            End Set
        End Property

        Public Property HazardousManufacturerPhone() As String
            Get
                Return _hazardousManufacturerPhone
            End Get
            Set(ByVal value As String)
                _hazardousManufacturerPhone = value
            End Set
        End Property

        Public Property HazardousManufacturerCountry() As String
            Get
                Return _hazardousManufacturerCountry
            End Get
            Set(ByVal value As String)
                _hazardousManufacturerCountry = value
            End Set
        End Property

        Public Property StockingStrategyCode() As String
            Get
                Return _stockingStrategyCode
            End Get
            Set(ByVal value As String)
                _stockingStrategyCode = value
            End Set
        End Property

        Public Property ItemCost() As String
            Get
                Return _itemCost
            End Get
            Set(ByVal value As String)
                _itemCost = value
            End Set
        End Property

        Public Property ProductCost() As String
            Get
                Return _productCost
            End Get
            Set(ByVal value As String)
                _productCost = value
            End Set
        End Property

        Public Property PhytoTemporaryShipment() As String
            Get
                Return _PhytoTemporaryShipment
            End Get
            Set(ByVal value As String)
                _PhytoTemporaryShipment = value
            End Set
        End Property
    End Class
End Namespace

