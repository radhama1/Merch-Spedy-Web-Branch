
Namespace Michaels

    Public Class ItemMaintItemDetailRecord

        Dim _ID As Integer = 0
        Dim _batchID As Long = Long.MinValue
        Dim _enabled As Boolean = False
        Dim _isValid As ItemValidFlag = ItemValidFlag.Unknown
        Dim _SKU As String = String.Empty
        Dim _isLockedForChange As Boolean = False
        Dim _vendorNumber As Long = Long.MinValue
        Dim _batchTypeID As Integer = Integer.MinValue
        Dim _vendorType As Integer = Integer.MinValue
        Dim _primaryUPC As String = String.Empty
        Dim _vendorStyleNum As String = String.Empty
        Dim _additionalUPCs As Integer = Integer.MinValue
        Dim _itemDesc As String = String.Empty
        Dim _classNum As Integer = Integer.MinValue
        Dim _subClassNum As Integer = Integer.MinValue
        Dim _privateBrandLabel As String = String.Empty
        Dim _eachesMasterCase As Integer = Integer.MinValue
        Dim _eachesInnerPack As Integer = Integer.MinValue
        Dim _allowStoreOrder As String = String.Empty
        Dim _inventoryControl As String = String.Empty
        Dim _autoReplenish As String = String.Empty
        Dim _prePriced As String = String.Empty
        Dim _prePricedUDA As String = String.Empty
        Dim _itemCost As Decimal = Decimal.MinValue
        Dim _eachCaseHeight As Decimal = Decimal.MinValue
        Dim _eachCaseWidth As Decimal = Decimal.MinValue
        Dim _eachCaseLength As Decimal = Decimal.MinValue
        Dim _eachCaseCube As Decimal = Decimal.MinValue
        Dim _eachCaseWeight As Decimal = Decimal.MinValue
        Dim _eachCaseCubeUOM As String = String.Empty
        Dim _eachCaseWeightUOM As String = String.Empty
        Dim _innerCaseHeight As Decimal = Decimal.MinValue
        Dim _innerCaseWidth As Decimal = Decimal.MinValue
        Dim _innerCaseLength As Decimal = Decimal.MinValue
        Dim _innerCaseCube As Decimal = Decimal.MinValue
        Dim _innerCaseWeight As Decimal = Decimal.MinValue
        Dim _innerCaseCubeUOM As String = String.Empty
        Dim _innerCaseWeightUOM As String = String.Empty
        Dim _masterCaseHeight As Decimal = Decimal.MinValue
        Dim _masterCaseWidth As Decimal = Decimal.MinValue
        Dim _masterCaseLength As Decimal = Decimal.MinValue
        Dim _masterCaseWeight As Decimal = Decimal.MinValue
        Dim _masterCaseCube As Decimal = Decimal.MinValue
        Dim _masterCaseCubeUOM As String = String.Empty
        Dim _masterCaseWeightUOM As String = String.Empty
        Dim _countryOfOrigin As String = String.Empty
        Dim _countryOfOriginName As String = String.Empty
        Dim _taxUDA As String = String.Empty
        Dim _taxValueUDA As Long = Long.MinValue
        Dim _discountable As String = String.Empty
        Dim _importBurden As Decimal = Decimal.MinValue
        Dim _shippingPoint As String = String.Empty
        Dim _planogramName As String = String.Empty
        Dim _hazardous As String = String.Empty
        Dim _hazardousFlammable As String = String.Empty
        Dim _hazardousContainerType As String = String.Empty
        Dim _hazardousContainerSize As Decimal = Decimal.MinValue
        Dim _MSDSID As Long = Long.MinValue
        Dim _imageID As Long = Long.MinValue
        Dim _buyer As String = String.Empty
        Dim _buyerFax As String = String.Empty
        Dim _buyerEmail As String = String.Empty
        Dim _season As String = String.Empty
        Dim _SKUGroup As String = String.Empty
        Dim _packSKU As String = String.Empty
        Dim _stockCategory As String = String.Empty
        Dim _CoinBattery As String = String.Empty
        Dim _TSSA As String = String.Empty
        Dim _CSA As String = String.Empty
        Dim _UL As String = String.Empty
        Dim _licenceAgreement As String = String.Empty
        Dim _fumigationCertificate As String = String.Empty
        Dim _phytoTemporaryShipment As String = String.Empty
        Dim _KILNDriedCertificate As String = String.Empty
        Dim _chinaComInspecNumAndCCIBStickers As String = String.Empty
        Dim _originalVisa As String = String.Empty
        Dim _textileDeclarationMidCode As String = String.Empty
        Dim _quotaChargeStatement As String = String.Empty
        Dim _MSDS As String = String.Empty
        Dim _TSCA As String = String.Empty
        Dim _dropBallTestCert As String = String.Empty
        Dim _manMedicalDeviceListing As String = String.Empty
        Dim _manFDARegistration As String = String.Empty
        Dim _copyRightIndemnification As String = String.Empty
        Dim _fishWildLifeCert As String = String.Empty
        Dim _proposition65LabelReq As String = String.Empty
        Dim _CCCR As String = String.Empty
        Dim _formaldehydeCompliant As String = String.Empty
        Dim _RMSSellable As String = String.Empty
        Dim _RMSOrderable As String = String.Empty
        Dim _RMSInventory As String = String.Empty
        Dim _storeTotal As Integer = Integer.MinValue
        Dim _displayerCost As Decimal = Decimal.MinValue
        'Dim _productCost As Decimal = Decimal.MinValue
        Dim _addChange As String = String.Empty
        Dim _POGSetupPerStore As Decimal = Decimal.MinValue
        Dim _POGMaxQty As Decimal = Decimal.MinValue
        Dim _projectedUnitSales As Decimal = Decimal.MinValue
        Dim _vendorOrAgent As String = String.Empty
        Dim _agentType As String = String.Empty
        Dim _paymentTerms As String = String.Empty
        Dim _days As String = String.Empty
        Dim _vendorMinOrderAmount As String = String.Empty
        Dim _vendorName As String = String.Empty
        Dim _vendorAddress1 As String = String.Empty
        Dim _vendorAddress2 As String = String.Empty
        Dim _vendorAddress3 As String = String.Empty
        Dim _vendorAddress4 As String = String.Empty
        Dim _vendorContactName As String = String.Empty
        Dim _vendorContactPhone As String = String.Empty
        Dim _vendorContactEmail As String = String.Empty
        Dim _vendorContactFax As String = String.Empty
        Dim _manufactureName As String = String.Empty
        Dim _manufactureAddress1 As String = String.Empty
        Dim _manufactureAddress2 As String = String.Empty
        Dim _manufactureContact As String = String.Empty
        Dim _manufacturePhone As String = String.Empty
        Dim _manufactureEmail As String = String.Empty
        Dim _manufactureFax As String = String.Empty
        Dim _agentContact As String = String.Empty
        Dim _agentPhone As String = String.Empty
        Dim _agentEmail As String = String.Empty
        Dim _agentFax As String = String.Empty
        Dim _harmonizedCodeNumber As String = String.Empty
        Dim _canadaHarmonizedCodeNumber As String = String.Empty
        Dim _ExportHarmonizedCodeNumber As String = String.Empty
        Dim _StockingStrategyCode As String = String.Empty
        Dim _detailInvoiceCustomsDesc As String = String.Empty
        Dim _componentMaterialBreakdown As String = String.Empty
        Dim _componentConstructionMethod As String = String.Empty
        Dim _individualItemPackaging As String = String.Empty
        Dim _FOBShippingPoint As Decimal = Decimal.MinValue
        Dim _dutyPercent As Decimal = Decimal.MinValue
        Dim _dutyAmount As Decimal = Decimal.MinValue
        Dim _additionalDutyComment As String = String.Empty
        Dim _additionalDutyAmount As Decimal = Decimal.MinValue
        Dim _suppTariffPercent As Decimal = Decimal.MinValue
        Dim _suppTariffAmount As Decimal = Decimal.MinValue
        Dim _oceanFreightAmount As Decimal = Decimal.MinValue
        Dim _oceanFreightComputedAmount As Decimal = Decimal.MinValue
        Dim _agentCommissionPercent As Decimal = Decimal.MinValue
        Dim _agentCommissionAmount As Decimal = Decimal.MinValue
        Dim _otherImportCostsPercent As Decimal = Decimal.MinValue
        Dim _otherImportCostsAmount As Decimal = Decimal.MinValue
        Dim _packagingCostAmount As Decimal = Decimal.MinValue
        Dim _warehouseLandedCost As Decimal = Decimal.MinValue
        Dim _purchaseOrderIssuedTo As String = String.Empty
        Dim _vendorComments As String = String.Empty
        Dim _freightTerms As String = String.Empty
        Dim _outboundFreight As Decimal = Decimal.MinValue
        Dim _ninePercentWhseCharge As Decimal = Decimal.MinValue
        Dim _totalStoreLandedCost As Decimal = Decimal.MinValue
        Dim _updateUserID As Integer = Integer.MinValue
        Dim _dateLastModified As Date = Date.MinValue
        Dim _updateUserName As String = String.Empty
        Dim _storeSupplierZoneGroup As String = String.Empty
        Dim _WHSSupplierZoneGroup As String = String.Empty
        Dim _primaryVendor As Boolean = False
        Dim _packItemIndicator As String = String.Empty
        Dim _itemTypeAttribute As String = String.Empty
        Dim _hybridType As String = String.Empty
        Dim _HybridSourceDC As String = String.Empty
        Dim _hazardousMSDSUOM As String = String.Empty
        Dim _detailInvoiceCustomsDesc0 As String = String.Empty
        Dim _detailInvoiceCustomsDesc1 As String = String.Empty
        Dim _detailInvoiceCustomsDesc2 As String = String.Empty
        Dim _detailInvoiceCustomsDesc3 As String = String.Empty
        Dim _detailInvoiceCustomsDesc4 As String = String.Empty
        Dim _detailInvoiceCustomsDesc5 As String = String.Empty
        Dim _componentMaterialBreakdown0 As String = String.Empty
        Dim _componentMaterialBreakdown1 As String = String.Empty
        Dim _componentMaterialBreakdown2 As String = String.Empty
        Dim _componentMaterialBreakdown3 As String = String.Empty
        Dim _componentMaterialBreakdown4 As String = String.Empty
        Dim _componentConstructionMethod0 As String = String.Empty
        Dim _componentConstructionMethod1 As String = String.Empty
        Dim _componentConstructionMethod2 As String = String.Empty
        Dim _componentConstructionMethod3 As String = String.Empty
        Dim _departmentNum As Integer = Integer.MinValue
        Dim _base1Retail As Decimal = Decimal.MinValue
        Dim _base2Retail As Decimal = Decimal.MinValue
        Dim _base3Retail As Decimal = Decimal.MinValue
        Dim _testRetail As Decimal = Decimal.MinValue
        Dim _alaskaRetail As Decimal = Decimal.MinValue
        Dim _canadaRetail As Decimal = Decimal.MinValue
        Dim _high1Retail As Decimal = Decimal.MinValue
        Dim _high2Retail As Decimal = Decimal.MinValue
        Dim _high3Retail As Decimal = Decimal.MinValue
        Dim _smallMarketRetail As Decimal = Decimal.MinValue
        Dim _low1Retail As Decimal = Decimal.MinValue
        Dim _low2Retail As Decimal = Decimal.MinValue
        Dim _manhattanRetail As Decimal = Decimal.MinValue
        Dim _quebecRetail As Decimal = Decimal.MinValue
        Dim _puertoRicoRetail As Decimal = Decimal.MinValue
        Dim _hazardousManufacturerName As String = String.Empty
        Dim _hazardousManufacturerCity As String = String.Empty
        Dim _hazardousManufacturerState As String = String.Empty
        Dim _hazardousManufacturerPhone As String = String.Empty
        Dim _hazardousManufacturerCountry As String = String.Empty
        Dim _itemType As String = String.Empty
        Dim _qtyInPack As Integer = Integer.MinValue
        Dim _itemStatus As String = String.Empty
        Dim _base1Clearance As Decimal = Decimal.MinValue
        Dim _base2Clearance As Decimal = Decimal.MinValue
        Dim _base3Clearance As Decimal = Decimal.MinValue
        Dim _testClearance As Decimal = Decimal.MinValue
        Dim _alaskaClearance As Decimal = Decimal.MinValue
        Dim _canadaClearance As Decimal = Decimal.MinValue
        Dim _high1Clearance As Decimal = Decimal.MinValue
        Dim _high2Clearance As Decimal = Decimal.MinValue
        Dim _high3Clearance As Decimal = Decimal.MinValue
        Dim _smallMarketClearance As Decimal = Decimal.MinValue
        Dim _low1Clearance As Decimal = Decimal.MinValue
        Dim _low2Clearance As Decimal = Decimal.MinValue
        Dim _manhattanClearance As Decimal = Decimal.MinValue
        Dim _quebecClearance As Decimal = Decimal.MinValue
        Dim _puertoRicoClearance As Decimal = Decimal.MinValue
        Dim _futureCostExists As Boolean = False
        Dim _quoteSheetItemType As String = String.Empty
        Dim _quotereferencenumber As String

        'PMO200141 GTIN14 Enhancements changes
        Dim _innerGTIN As String = String.Empty
        Dim _caseGTIN As String = String.Empty

        'Multilingual Fields
        Dim _customsDescription As String
        Dim _pliEnglish As String
        Dim _pliFrench As String
        Dim _pliSpanish As String
        Dim _tiEnglish As String
        Dim _tiFrench As String
        Dim _tiSpanish As String
        Dim _englishShortDescription As String
        Dim _englishLongDescription As String
        Dim _frenchShortDescription As String
        Dim _frenchLongDescription As String
        Dim _spanishShortDescription As String
        Dim _spanishLongDescription As String
        Dim _exemptEndDateFrench As String

        Dim _MinimumOrderQuantity As Integer = Integer.MinValue
        Dim _ProductIdentifiesAsCosmetic As String = String.Empty

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
            End Set
        End Property

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property
        Public Property Enabled() As Boolean
            Get
                Return _enabled
            End Get
            Set(ByVal value As Boolean)
                _enabled = value
            End Set
        End Property
        Public Property IsValid() As ItemValidFlag
            Get
                Return _isValid
            End Get
            Set(ByVal value As ItemValidFlag)
                _isValid = value
            End Set
        End Property
        Public Property SKU() As String
            Get
                Return _SKU
            End Get
            Set(ByVal value As String)
                _SKU = value
            End Set
        End Property
        Public Property IsLockedForChange() As Boolean
            Get
                Return _isLockedForChange
            End Get
            Set(ByVal value As Boolean)
                _isLockedForChange = value
            End Set
        End Property
        Public Property VendorNumber() As Long
            Get
                Return _vendorNumber
            End Get
            Set(ByVal value As Long)
                _vendorNumber = value
            End Set
        End Property
        Public Property BatchTypeID() As Integer
            Get
                Return _batchTypeID
            End Get
            Set(ByVal value As Integer)
                _batchTypeID = value
            End Set
        End Property
        Public Property VendorType() As Integer
            Get
                Return _vendorType
            End Get
            Set(ByVal value As Integer)
                _vendorType = value
            End Set
        End Property
        Public Property PrimaryUPC() As String
            Get
                Return _primaryUPC
            End Get
            Set(ByVal value As String)
                _primaryUPC = value
            End Set
        End Property
        Public Property VendorStyleNum() As String
            Get
                Return _vendorStyleNum
            End Get
            Set(ByVal value As String)
                _vendorStyleNum = value
            End Set
        End Property
        Public Property AdditionalUPCs() As Integer
            Get
                Return _additionalUPCs
            End Get
            Set(ByVal value As Integer)
                _additionalUPCs = value
            End Set
        End Property
        Public Property ItemDesc() As String
            Get
                Return _itemDesc
            End Get
            Set(ByVal value As String)
                _itemDesc = value
            End Set
        End Property
        Public Property ClassNum() As Integer
            Get
                Return _classNum
            End Get
            Set(ByVal value As Integer)
                _classNum = value
            End Set
        End Property
        Public Property SubClassNum() As Integer
            Get
                Return _subClassNum
            End Get
            Set(ByVal value As Integer)
                _subClassNum = value
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
        Public Property EachesMasterCase() As Integer
            Get
                Return _eachesMasterCase
            End Get
            Set(ByVal value As Integer)
                _eachesMasterCase = value
            End Set
        End Property
        Public Property EachesInnerPack() As Integer
            Get
                Return _eachesInnerPack
            End Get
            Set(ByVal value As Integer)
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
        Public Property ItemCost() As Decimal
            Get
                Return _itemCost
            End Get
            Set(ByVal value As Decimal)
                _itemCost = value
            End Set
        End Property
        Public Property EachCaseHeight() As Decimal
            Get
                Return _EachCaseHeight
            End Get
            Set(ByVal value As Decimal)
                _EachCaseHeight = value
            End Set
        End Property
        Public Property EachCaseWidth() As Decimal
            Get
                Return _EachCaseWidth
            End Get
            Set(ByVal value As Decimal)
                _EachCaseWidth = value
            End Set
        End Property
        Public Property EachCaseLength() As Decimal
            Get
                Return _EachCaseLength
            End Get
            Set(ByVal value As Decimal)
                _EachCaseLength = value
            End Set
        End Property
        Public Property EachCaseCube() As Decimal
            Get
                Return _EachCaseCube
            End Get
            Set(ByVal value As Decimal)
                _EachCaseCube = value
            End Set
        End Property
        Public Property EachCaseWeight() As Decimal
            Get
                Return _EachCaseWeight
            End Get
            Set(ByVal value As Decimal)
                _EachCaseWeight = value
            End Set
        End Property
        Public Property EachCaseCubeUOM() As String
            Get
                Return _eachCaseCubeUOM
            End Get
            Set(ByVal value As String)
                _eachCaseCubeUOM = value
            End Set
        End Property
        Public Property EachCaseWeightUOM() As String
            Get
                Return _eachCaseWeightUOM
            End Get
            Set(ByVal value As String)
                _eachCaseWeightUOM = value
            End Set
        End Property

        Public Property InnerCaseHeight() As Decimal
            Get
                Return _innerCaseHeight
            End Get
            Set(ByVal value As Decimal)
                _innerCaseHeight = value
            End Set
        End Property
        Public Property InnerCaseWidth() As Decimal
            Get
                Return _innerCaseWidth
            End Get
            Set(ByVal value As Decimal)
                _innerCaseWidth = value
            End Set
        End Property
        Public Property InnerCaseLength() As Decimal
            Get
                Return _innerCaseLength
            End Get
            Set(ByVal value As Decimal)
                _innerCaseLength = value
            End Set
        End Property
        Public Property InnerCaseCube() As Decimal
            Get
                Return _innerCaseCube
            End Get
            Set(ByVal value As Decimal)
                _innerCaseCube = value
            End Set
        End Property
        Public Property InnerCaseWeight() As Decimal
            Get
                Return _innerCaseWeight
            End Get
            Set(ByVal value As Decimal)
                _innerCaseWeight = value
            End Set
        End Property
        Public Property InnerCaseCubeUOM() As String
            Get
                Return _innerCaseCubeUOM
            End Get
            Set(ByVal value As String)
                _innerCaseCubeUOM = value
            End Set
        End Property
        Public Property InnerCaseWeightUOM() As String
            Get
                Return _innerCaseWeightUOM
            End Get
            Set(ByVal value As String)
                _innerCaseWeightUOM = value
            End Set
        End Property
        Public Property MasterCaseHeight() As Decimal
            Get
                Return _masterCaseHeight
            End Get
            Set(ByVal value As Decimal)
                _masterCaseHeight = value
            End Set
        End Property
        Public Property MasterCaseWidth() As Decimal
            Get
                Return _masterCaseWidth
            End Get
            Set(ByVal value As Decimal)
                _masterCaseWidth = value
            End Set
        End Property
        Public Property MasterCaseLength() As Decimal
            Get
                Return _masterCaseLength
            End Get
            Set(ByVal value As Decimal)
                _masterCaseLength = value
            End Set
        End Property
        Public Property MasterCaseWeight() As Decimal
            Get
                Return _masterCaseWeight
            End Get
            Set(ByVal value As Decimal)
                _masterCaseWeight = value
            End Set
        End Property
        Public Property MasterCaseCube() As Decimal
            Get
                Return _masterCaseCube
            End Get
            Set(ByVal value As Decimal)
                _masterCaseCube = value
            End Set
        End Property
        Public Property MasterCaseCubeUOM() As String
            Get
                Return _masterCaseCubeUOM
            End Get
            Set(ByVal value As String)
                _masterCaseCubeUOM = value
            End Set
        End Property
        Public Property MasterCaseWeightUOM() As String
            Get
                Return _masterCaseWeightUOM
            End Get
            Set(ByVal value As String)
                _masterCaseWeightUOM = value
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
        Public Property CountryOfOriginName() As String
            Get
                Return _countryOfOriginName
            End Get
            Set(ByVal value As String)
                _countryOfOriginName = value
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
        Public Property TaxValueUDA() As Long
            Get
                Return _taxValueUDA
            End Get
            Set(ByVal value As Long)
                _taxValueUDA = value
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
        Public Property ImportBurden() As Decimal
            Get
                Return _importBurden
            End Get
            Set(ByVal value As Decimal)
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
        Public Property HazardousContainerSize() As Decimal
            Get
                Return _hazardousContainerSize
            End Get
            Set(ByVal value As Decimal)
                _hazardousContainerSize = value
            End Set
        End Property
        Public Property MSDSID() As Long
            Get
                Return _MSDSID
            End Get
            Set(ByVal value As Long)
                _MSDSID = value
            End Set
        End Property
        Public Property ImageID() As Long
            Get
                Return _imageID
            End Get
            Set(ByVal value As Long)
                _imageID = value
            End Set
        End Property
        Public Property Buyer() As String
            Get
                Return _buyer
            End Get
            Set(ByVal value As String)
                _buyer = value
            End Set
        End Property
        Public Property BuyerFax() As String
            Get
                Return _buyerFax
            End Get
            Set(ByVal value As String)
                _buyerFax = value
            End Set
        End Property
        Public Property BuyerEmail() As String
            Get
                Return _buyerEmail
            End Get
            Set(ByVal value As String)
                _buyerEmail = value
            End Set
        End Property
        Public Property Season() As String
            Get
                Return _season
            End Get
            Set(ByVal value As String)
                _season = value
            End Set
        End Property
        Public Property SKUGroup() As String
            Get
                Return _SKUGroup
            End Get
            Set(ByVal value As String)
                _SKUGroup = value
            End Set
        End Property
        Public Property PackSKU() As String
            Get
                Return _packSKU
            End Get
            Set(ByVal value As String)
                _packSKU = value
            End Set
        End Property
        Public Property StockCategory() As String
            Get
                Return _stockCategory
            End Get
            Set(ByVal value As String)
                _stockCategory = value
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
                Return _licenceAgreement
            End Get
            Set(ByVal value As String)
                _licenceAgreement = value
            End Set
        End Property
        Public Property FumigationCertificate() As String
            Get
                Return _fumigationCertificate
            End Get
            Set(ByVal value As String)
                _fumigationCertificate = value
            End Set
        End Property
        Public Property PhytoTemporaryShipment() As String
            Get
                Return _phytoTemporaryShipment
            End Get
            Set(ByVal value As String)
                _phytoTemporaryShipment = value
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
        Public Property RMSSellable() As String
            Get
                Return _RMSSellable
            End Get
            Set(ByVal value As String)
                _RMSSellable = value
            End Set
        End Property
        Public Property RMSOrderable() As String
            Get
                Return _RMSOrderable
            End Get
            Set(ByVal value As String)
                _RMSOrderable = value
            End Set
        End Property
        Public Property RMSInventory() As String
            Get
                Return _RMSInventory
            End Get
            Set(ByVal value As String)
                _RMSInventory = value
            End Set
        End Property
        Public Property StoreTotal() As Integer
            Get
                Return _storeTotal
            End Get
            Set(ByVal value As Integer)
                _storeTotal = value
            End Set
        End Property
        Public Property DisplayerCost() As Decimal
            Get
                Return _displayerCost
            End Get
            Set(ByVal value As Decimal)
                _displayerCost = value
            End Set
        End Property
        Public Property ProductCost() As Decimal
            Get
                Return _itemCost
            End Get
            Set(ByVal value As Decimal)
                _itemCost = value
            End Set
        End Property
        Public Property AddChange() As String
            Get
                Return _addChange
            End Get
            Set(ByVal value As String)
                _addChange = value
            End Set
        End Property
        Public Property POGSetupPerStore() As Decimal
            Get
                Return _POGSetupPerStore
            End Get
            Set(ByVal value As Decimal)
                _POGSetupPerStore = value
            End Set
        End Property
        Public Property POGMaxQty() As Decimal
            Get
                Return _POGMaxQty
            End Get
            Set(ByVal value As Decimal)
                _POGMaxQty = value
            End Set
        End Property
        Public Property ProjectedUnitSales() As Decimal
            Get
                Return _projectedUnitSales
            End Get
            Set(ByVal value As Decimal)
                _projectedUnitSales = value
            End Set
        End Property
        Public Property VendorOrAgent() As String
            Get
                Return _vendorOrAgent
            End Get
            Set(ByVal value As String)
                _vendorOrAgent = value
            End Set
        End Property
        Public Property AgentType() As String
            Get
                Return _agentType
            End Get
            Set(ByVal value As String)
                _agentType = value
            End Set
        End Property
        Public Property PaymentTerms() As String
            Get
                Return _paymentTerms
            End Get
            Set(ByVal value As String)
                _paymentTerms = value
            End Set
        End Property
        Public Property Days() As String
            Get
                Return _days
            End Get
            Set(ByVal value As String)
                _days = value
            End Set
        End Property
        Public Property VendorMinOrderAmount() As String
            Get
                Return _vendorMinOrderAmount
            End Get
            Set(ByVal value As String)
                _vendorMinOrderAmount = value
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
        Public Property VendorAddress1() As String
            Get
                Return _vendorAddress1
            End Get
            Set(ByVal value As String)
                _vendorAddress1 = value
            End Set
        End Property
        Public Property VendorAddress2() As String
            Get
                Return _vendorAddress2
            End Get
            Set(ByVal value As String)
                _vendorAddress2 = value
            End Set
        End Property
        Public Property VendorAddress3() As String
            Get
                Return _vendorAddress3
            End Get
            Set(ByVal value As String)
                _vendorAddress3 = value
            End Set
        End Property
        Public Property VendorAddress4() As String
            Get
                Return _vendorAddress4
            End Get
            Set(ByVal value As String)
                _vendorAddress4 = value
            End Set
        End Property
        Public Property VendorContactName() As String
            Get
                Return _vendorContactName
            End Get
            Set(ByVal value As String)
                _vendorContactName = value
            End Set
        End Property
        Public Property VendorContactPhone() As String
            Get
                Return _vendorContactPhone
            End Get
            Set(ByVal value As String)
                _vendorContactPhone = value
            End Set
        End Property
        Public Property VendorContactEmail() As String
            Get
                Return _vendorContactEmail
            End Get
            Set(ByVal value As String)
                _vendorContactEmail = value
            End Set
        End Property
        Public Property VendorContactFax() As String
            Get
                Return _vendorContactFax
            End Get
            Set(ByVal value As String)
                _vendorContactFax = value
            End Set
        End Property
        Public Property ManufactureName() As String
            Get
                Return _manufactureName
            End Get
            Set(ByVal value As String)
                _manufactureName = value
            End Set
        End Property
        Public Property ManufactureAddress1() As String
            Get
                Return _manufactureAddress1
            End Get
            Set(ByVal value As String)
                _manufactureAddress1 = value
            End Set
        End Property
        Public Property ManufactureAddress2() As String
            Get
                Return _manufactureAddress2
            End Get
            Set(ByVal value As String)
                _manufactureAddress2 = value
            End Set
        End Property
        Public Property ManufactureContact() As String
            Get
                Return _manufactureContact
            End Get
            Set(ByVal value As String)
                _manufactureContact = value
            End Set
        End Property
        Public Property ManufacturePhone() As String
            Get
                Return _manufacturePhone
            End Get
            Set(ByVal value As String)
                _manufacturePhone = value
            End Set
        End Property
        Public Property ManufactureEmail() As String
            Get
                Return _manufactureEmail
            End Get
            Set(ByVal value As String)
                _manufactureEmail = value
            End Set
        End Property
        Public Property ManufactureFax() As String
            Get
                Return _manufactureFax
            End Get
            Set(ByVal value As String)
                _manufactureFax = value
            End Set
        End Property
        Public Property AgentContact() As String
            Get
                Return _agentContact
            End Get
            Set(ByVal value As String)
                _agentContact = value
            End Set
        End Property
        Public Property AgentPhone() As String
            Get
                Return _agentPhone
            End Get
            Set(ByVal value As String)
                _agentPhone = value
            End Set
        End Property
        Public Property AgentEmail() As String
            Get
                Return _agentEmail
            End Get
            Set(ByVal value As String)
                _agentEmail = value
            End Set
        End Property
        Public Property AgentFax() As String
            Get
                Return _agentFax
            End Get
            Set(ByVal value As String)
                _agentFax = value
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
        Public Property ExportHarmonizedCodeNumber() As String
            Get
                Return _ExportHarmonizedCodeNumber
            End Get
            Set(ByVal value As String)
                _ExportHarmonizedCodeNumber = value
            End Set
        End Property

        Public Property StockingStrategyCode() As String
            Get
                Return _StockingStrategyCode
            End Get
            Set(ByVal value As String)
                _StockingStrategyCode = value
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
        Public Property ComponentConstructionMethod() As String
            Get
                Return _componentConstructionMethod
            End Get
            Set(ByVal value As String)
                _componentConstructionMethod = value
            End Set
        End Property
        Public Property IndividualItemPackaging() As String
            Get
                Return _individualItemPackaging
            End Get
            Set(ByVal value As String)
                _individualItemPackaging = value
            End Set
        End Property
        Public Property FOBShippingPoint() As Decimal
            Get
                Return _FOBShippingPoint
            End Get
            Set(ByVal value As Decimal)
                _FOBShippingPoint = value
            End Set
        End Property
        Public Property DutyPercent() As Decimal
            Get
                Return _dutyPercent
            End Get
            Set(ByVal value As Decimal)
                _dutyPercent = value
            End Set
        End Property
        Public Property DutyAmount() As Decimal
            Get
                Return _dutyAmount
            End Get
            Set(ByVal value As Decimal)
                _dutyAmount = value
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
        Public Property AdditionalDutyAmount() As Decimal
            Get
                Return _additionalDutyAmount
            End Get
            Set(ByVal value As Decimal)
                _additionalDutyAmount = value
            End Set
        End Property

        Public Property SuppTariffPercent() As Decimal
            Get
                Return _SuppTariffPercent
            End Get
            Set(ByVal value As Decimal)
                _SuppTariffPercent = value
            End Set
        End Property
        Public Property SuppTariffAmount() As Decimal
            Get
                Return _SuppTariffAmount
            End Get
            Set(ByVal value As Decimal)
                _SuppTariffAmount = value
            End Set
        End Property

        Public Property OceanFreightAmount() As Decimal
            Get
                Return _oceanFreightAmount
            End Get
            Set(ByVal value As Decimal)
                _oceanFreightAmount = value
            End Set
        End Property
        Public Property OceanFreightComputedAmount() As Decimal
            Get
                Return _oceanFreightComputedAmount
            End Get
            Set(ByVal value As Decimal)
                _oceanFreightComputedAmount = value
            End Set
        End Property
        Public Property AgentCommissionPercent() As Decimal
            Get
                Return _agentCommissionPercent
            End Get
            Set(ByVal value As Decimal)
                _agentCommissionPercent = value
            End Set
        End Property
        Public Property AgentCommissionAmount() As Decimal
            Get
                Return _agentCommissionAmount
            End Get
            Set(ByVal value As Decimal)
                _agentCommissionAmount = value
            End Set
        End Property
        Public Property OtherImportCostsPercent() As Decimal
            Get
                Return _otherImportCostsPercent
            End Get
            Set(ByVal value As Decimal)
                _otherImportCostsPercent = value
            End Set
        End Property
        Public Property OtherImportCostsAmount() As Decimal
            Get
                Return _otherImportCostsAmount
            End Get
            Set(ByVal value As Decimal)
                _otherImportCostsAmount = value
            End Set
        End Property
        Public Property PackagingCostAmount() As Decimal
            Get
                Return _packagingCostAmount
            End Get
            Set(ByVal value As Decimal)
                _packagingCostAmount = value
            End Set
        End Property
        Public Property WarehouseLandedCost() As Decimal
            Get
                Return _warehouseLandedCost
            End Get
            Set(ByVal value As Decimal)
                _warehouseLandedCost = value
            End Set
        End Property
        Public Property PurchaseOrderIssuedTo() As String
            Get
                Return _purchaseOrderIssuedTo
            End Get
            Set(ByVal value As String)
                _purchaseOrderIssuedTo = value
            End Set
        End Property
        Public Property VendorComments() As String
            Get
                Return _vendorComments
            End Get
            Set(ByVal value As String)
                _vendorComments = value
            End Set
        End Property
        Public Property FreightTerms() As String
            Get
                Return _freightTerms
            End Get
            Set(ByVal value As String)
                _freightTerms = value
            End Set
        End Property
        Public Property OutboundFreight() As Decimal
            Get
                Return _outboundFreight
            End Get
            Set(ByVal value As Decimal)
                _outboundFreight = value
            End Set
        End Property
        Public Property NinePercentWhseCharge() As Decimal
            Get
                Return _ninePercentWhseCharge
            End Get
            Set(ByVal value As Decimal)
                _ninePercentWhseCharge = value
            End Set
        End Property
        Public Property TotalStoreLandedCost() As Decimal
            Get
                Return _totalStoreLandedCost
            End Get
            Set(ByVal value As Decimal)
                _totalStoreLandedCost = value
            End Set
        End Property
        Public Property UpdateUserID() As Integer
            Get
                Return _updateUserID
            End Get
            Set(ByVal value As Integer)
                _updateUserID = value
            End Set
        End Property
        Public Property DateLastModified() As Date
            Get
                Return _dateLastModified
            End Get
            Set(ByVal value As Date)
                _dateLastModified = value
            End Set
        End Property
        Public Property UpdateUserName() As String
            Get
                Return _updateUserName
            End Get
            Set(ByVal value As String)
                _updateUserName = value
            End Set
        End Property
        Public Property StoreSupplierZoneGroup() As String
            Get
                Return _storeSupplierZoneGroup
            End Get
            Set(ByVal value As String)
                _storeSupplierZoneGroup = value
            End Set
        End Property
        Public Property WHSSupplierZoneGroup() As String
            Get
                Return _WHSSupplierZoneGroup
            End Get
            Set(ByVal value As String)
                _WHSSupplierZoneGroup = value
            End Set
        End Property
        Property PrimaryVendor() As Boolean
            Get
                Return _primaryVendor
            End Get
            Set(ByVal value As Boolean)
                _primaryVendor = value
            End Set
        End Property

        Public Property PackItemIndicator() As String
            Get
                Return _packItemIndicator
            End Get
            Set(ByVal value As String)
                _packItemIndicator = value
            End Set
        End Property

        Public Property ItemTypeAttribute() As String
            Get
                Return _itemTypeAttribute
            End Get
            Set(ByVal value As String)
                _itemTypeAttribute = value
            End Set
        End Property

        Public Property HybridType() As String
            Get
                Return _hybridType
            End Get
            Set(ByVal value As String)
                _hybridType = value
            End Set
        End Property

        Public Property HybridSourceDC() As String
            Get
                Return _HybridSourceDC
            End Get
            Set(ByVal value As String)
                _HybridSourceDC = value
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

        Public Property ComponentConstructionMethod0() As String
            Get
                Return _componentConstructionMethod0
            End Get
            Set(ByVal value As String)
                _componentConstructionMethod0 = value
            End Set
        End Property

        Public Property ComponentConstructionMethod1() As String
            Get
                Return _componentConstructionMethod1
            End Get
            Set(ByVal value As String)
                _componentConstructionMethod1 = value
            End Set
        End Property

        Public Property ComponentConstructionMethod2() As String
            Get
                Return _componentConstructionMethod2
            End Get
            Set(ByVal value As String)
                _componentConstructionMethod2 = value
            End Set
        End Property

        Public Property ComponentConstructionMethod3() As String
            Get
                Return _componentConstructionMethod3
            End Get
            Set(ByVal value As String)
                _componentConstructionMethod3 = value
            End Set
        End Property

        Public Property ComponentMaterialBreakdown0() As String
            Get
                Return _componentMaterialBreakdown0
            End Get
            Set(ByVal value As String)
                _componentMaterialBreakdown0 = value
            End Set
        End Property

        Public Property ComponentMaterialBreakdown1() As String
            Get
                Return _componentMaterialBreakdown1
            End Get
            Set(ByVal value As String)
                _componentMaterialBreakdown1 = value
            End Set
        End Property

        Public Property ComponentMaterialBreakdown2() As String
            Get
                Return _componentMaterialBreakdown2
            End Get
            Set(ByVal value As String)
                _componentMaterialBreakdown2 = value
            End Set
        End Property

        Public Property ComponentMaterialBreakdown3() As String
            Get
                Return _componentMaterialBreakdown3
            End Get
            Set(ByVal value As String)
                _componentMaterialBreakdown3 = value
            End Set
        End Property


        Public Property ComponentMaterialBreakdown4() As String
            Get
                Return _componentMaterialBreakdown4
            End Get
            Set(ByVal value As String)
                _componentMaterialBreakdown4 = value
            End Set
        End Property


        Public Property DetailInvoiceCustomsDesc0() As String
            Get
                Return _detailInvoiceCustomsDesc0
            End Get
            Set(ByVal value As String)
                _detailInvoiceCustomsDesc0 = value
            End Set
        End Property

        Public Property DetailInvoiceCustomsDesc1() As String
            Get
                Return _detailInvoiceCustomsDesc1
            End Get
            Set(ByVal value As String)
                _detailInvoiceCustomsDesc1 = value
            End Set
        End Property

        Public Property DetailInvoiceCustomsDesc2() As String
            Get
                Return _detailInvoiceCustomsDesc2
            End Get
            Set(ByVal value As String)
                _detailInvoiceCustomsDesc2 = value
            End Set
        End Property

        Public Property DetailInvoiceCustomsDesc3() As String
            Get
                Return _detailInvoiceCustomsDesc3
            End Get
            Set(ByVal value As String)
                _detailInvoiceCustomsDesc3 = value
            End Set
        End Property

        Public Property DetailInvoiceCustomsDesc4() As String
            Get
                Return _detailInvoiceCustomsDesc4
            End Get
            Set(ByVal value As String)
                _detailInvoiceCustomsDesc4 = value
            End Set
        End Property

        Public Property DetailInvoiceCustomsDesc5() As String
            Get
                Return _detailInvoiceCustomsDesc5
            End Get
            Set(ByVal value As String)
                _detailInvoiceCustomsDesc5 = value
            End Set
        End Property

        Public Property DepartmentNum() As Integer
            Get
                Return _departmentNum
            End Get
            Set(ByVal value As Integer)
                _departmentNum = value
            End Set
        End Property

        Public Property Base1Retail() As Decimal
            Get
                Return _base1Retail
            End Get
            Set(ByVal value As Decimal)
                _base1Retail = value
            End Set
        End Property

        Public Property Base2Retail() As Decimal
            Get
                Return _base2Retail
            End Get
            Set(ByVal value As Decimal)
                _base2Retail = value
            End Set
        End Property

        Public Property Base3Retail() As Decimal
            Get
                Return _base3Retail
            End Get
            Set(ByVal value As Decimal)
                _base3Retail = value
            End Set
        End Property

        Public Property TestRetail() As Decimal
            Get
                Return _testRetail
            End Get
            Set(ByVal value As Decimal)
                _testRetail = value
            End Set
        End Property

        Public Property AlaskaRetail() As Decimal
            Get
                Return _alaskaRetail
            End Get
            Set(ByVal value As Decimal)
                _alaskaRetail = value
            End Set
        End Property

        Public Property CanadaRetail() As Decimal
            Get
                Return _canadaRetail
            End Get
            Set(ByVal value As Decimal)
                _canadaRetail = value
            End Set
        End Property

        Public Property High1Retail() As Decimal
            Get
                Return _high1Retail
            End Get
            Set(ByVal value As Decimal)
                _high1Retail = value
            End Set
        End Property

        Public Property High2Retail() As Decimal
            Get
                Return _high2Retail
            End Get
            Set(ByVal value As Decimal)
                _high2Retail = value
            End Set
        End Property

        Public Property High3Retail() As Decimal
            Get
                Return _high3Retail
            End Get
            Set(ByVal value As Decimal)
                _high3Retail = value
            End Set
        End Property

        Public Property SmallMarketRetail() As Decimal
            Get
                Return _smallMarketRetail
            End Get
            Set(ByVal value As Decimal)
                _smallMarketRetail = value
            End Set
        End Property

        Public Property Low1Retail() As Decimal
            Get
                Return _low1Retail
            End Get
            Set(ByVal value As Decimal)
                _low1Retail = value
            End Set
        End Property

        Public Property Low2Retail() As Decimal
            Get
                Return _low2Retail
            End Get
            Set(ByVal value As Decimal)
                _low2Retail = value
            End Set
        End Property

        Public Property ManhattanRetail() As Decimal
            Get
                Return _manhattanRetail
            End Get
            Set(ByVal value As Decimal)
                _manhattanRetail = value
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

        Public Property ItemType() As String
            Get
                Return _itemType
            End Get
            Set(ByVal value As String)
                _itemType = value
            End Set
        End Property

        Public Property QtyInPack() As Integer
            Get
                Return _qtyInPack
            End Get
            Set(ByVal value As Integer)
                _qtyInPack = value
            End Set
        End Property

        Public Property ItemStatus() As String
            Get
                Return _itemStatus
            End Get
            Set(ByVal value As String)
                _itemStatus = value
            End Set
        End Property

        Public Property Base1Clearance() As Decimal
            Get
                Return _base1Clearance
            End Get
            Set(ByVal value As Decimal)
                _base1Clearance = value
            End Set
        End Property

        Public Property Base2Clearance() As Decimal
            Get
                Return _base2Clearance
            End Get
            Set(ByVal value As Decimal)
                _base2Clearance = value
            End Set
        End Property

        Public Property Base3Clearance() As Decimal
            Get
                Return _base3Clearance
            End Get
            Set(ByVal value As Decimal)
                _base3Clearance = value
            End Set
        End Property

        Public Property TestClearance() As Decimal
            Get
                Return _testClearance
            End Get
            Set(ByVal value As Decimal)
                _testClearance = value
            End Set
        End Property

        Public Property AlaskaClearance() As Decimal
            Get
                Return _alaskaClearance
            End Get
            Set(ByVal value As Decimal)
                _alaskaClearance = value
            End Set
        End Property

        Public Property CanadaClearance() As Decimal
            Get
                Return _canadaClearance
            End Get
            Set(ByVal value As Decimal)
                _canadaClearance = value
            End Set
        End Property

        Public Property High1Clearance() As Decimal
            Get
                Return _high1Clearance
            End Get
            Set(ByVal value As Decimal)
                _high1Clearance = value
            End Set
        End Property

        Public Property High2Clearance() As Decimal
            Get
                Return _high2Clearance
            End Get
            Set(ByVal value As Decimal)
                _high2Clearance = value
            End Set
        End Property

        Public Property High3Clearance() As Decimal
            Get
                Return _high3Clearance
            End Get
            Set(ByVal value As Decimal)
                _high3Clearance = value
            End Set
        End Property

        Public Property SmallMarketClearance() As Decimal
            Get
                Return _smallMarketClearance
            End Get
            Set(ByVal value As Decimal)
                _smallMarketClearance = value
            End Set
        End Property

        Public Property Low1Clearance() As Decimal
            Get
                Return _low1Clearance
            End Get
            Set(ByVal value As Decimal)
                _low1Clearance = value
            End Set
        End Property

        Public Property Low2Clearance() As Decimal
            Get
                Return _low2Clearance
            End Get
            Set(ByVal value As Decimal)
                _low2Clearance = value
            End Set
        End Property

        Public Property ManhattanClearance() As Decimal
            Get
                Return _manhattanClearance
            End Get
            Set(ByVal value As Decimal)
                _manhattanClearance = value
            End Set
        End Property

        Public Property FutureCostExists() As Boolean
            Get
                Return _futureCostExists
            End Get
            Set(ByVal value As Boolean)
                _futureCostExists = value
            End Set
        End Property

        Public Property QuoteSheetItemType() As String
            Get
                Return _quoteSheetItemType
            End Get
            Set(ByVal value As String)
                _quoteSheetItemType = value
            End Set
        End Property

        Public Property QuoteReferenceNumber() As String
            Get
                Return _quotereferencenumber
            End Get
            Set(ByVal value As String)
                _quotereferencenumber = value
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

        Public Property QuebecRetail() As Decimal
            Get
                Return _quebecRetail
            End Get
            Set(ByVal value As Decimal)
                _quebecRetail = value
            End Set
        End Property

        Public Property QuebecClearance() As Decimal
            Get
                Return _quebecClearance
            End Get
            Set(ByVal value As Decimal)
                _quebecClearance = value
            End Set
        End Property

        Public Property PuertoRicoRetail() As Decimal
            Get
                Return _puertoRicoRetail
            End Get
            Set(ByVal value As Decimal)
                _puertoRicoRetail = value
            End Set
        End Property

        Public Property PuertoRicoClearance() As Decimal
            Get
                Return _puertoRicoClearance
            End Get
            Set(ByVal value As Decimal)
                _puertoRicoClearance = value
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

        Public Property EnglishShortDescription() As String
            Get
                Return _englishShortDescription
            End Get
            Set(ByVal value As String)
                _englishShortDescription = value
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

        Public Property FrenchShortDescription() As String
            Get
                Return _frenchShortDescription
            End Get
            Set(ByVal value As String)
                _frenchShortDescription = value
            End Set
        End Property

        Public Property FrenchLongDescription() As String
            Get
                Return _frenchLongDescription
            End Get
            Set(ByVal value As String)
                _frenchLongDescription = value
            End Set
        End Property

        Public Property SpanishShortDescription() As String
            Get
                Return _spanishShortDescription
            End Get
            Set(ByVal value As String)
                _spanishShortDescription = value
            End Set
        End Property

        Public Property SpanishLongDescription() As String
            Get
                Return _spanishLongDescription
            End Get
            Set(ByVal value As String)
                _spanishLongDescription = value
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

        'PMO200141 GTIN14 Enhancements changes
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

        Public Property MinimumOrderQuantity() As Integer
            Get
                Return _MinimumOrderQuantity
            End Get
            Set(ByVal value As Integer)
                _MinimumOrderQuantity = value
            End Set
        End Property

        Public Property ProductIdentifiesAsCosmetic() As String
            Get
                Return _ProductIdentifiesAsCosmetic
            End Get
            Set(ByVal value As String)
                _ProductIdentifiesAsCosmetic = value
            End Set
        End Property

        Public Sub CopyTo(ByVal rec As ItemMaintItemDetailFormRecord)
            rec.ID = Me.ID
            rec.BatchID = Me.BatchID
            rec.Enabled = Me.Enabled
            rec.IsValid = Me.IsValid
            rec.SKU = Me.SKU
            rec.IsLockedForChange = Me.IsLockedForChange
            rec.VendorNumber = Me.VendorNumber
            rec.BatchTypeID = Me.BatchTypeID
            rec.VendorType = Me.VendorType
            rec.PrimaryUPC = Me.PrimaryUPC
            rec.VendorStyleNum = Me.VendorStyleNum
            rec.AdditionalUPCs = Me.AdditionalUPCs
            rec.ItemDesc = Me.ItemDesc
            rec.ClassNum = Me.ClassNum
            rec.SubClassNum = Me.SubClassNum
            rec.PrivateBrandLabel = Me.PrivateBrandLabel
            rec.EachesMasterCase = Me.EachesMasterCase
            rec.EachesInnerPack = Me.EachesInnerPack
            rec.AllowStoreOrder = Me.AllowStoreOrder
            rec.InventoryControl = Me.InventoryControl
            rec.AutoReplenish = Me.AutoReplenish
            rec.PrePriced = Me.PrePriced
            rec.PrePricedUDA = Me.PrePricedUDA
            rec.ItemCost = Me.ItemCost
            rec.EachCaseHeight = Me.EachCaseHeight
            rec.EachCaseWidth = Me.EachCaseWidth
            rec.EachCaseLength = Me.EachCaseLength
            rec.EachCaseCube = Me.EachCaseCube
            rec.EachCaseWeight = Me.EachCaseWeight
            rec.EachCaseCubeUOM = Me.EachCaseCubeUOM
            rec.EachCaseWeightUOM = Me.EachCaseWeightUOM
            rec.InnerCaseHeight = Me.InnerCaseHeight
            rec.InnerCaseWidth = Me.InnerCaseWidth
            rec.InnerCaseLength = Me.InnerCaseLength
            rec.InnerCaseCube = Me.InnerCaseCube
            rec.InnerCaseWeight = Me.InnerCaseWeight
            rec.InnerCaseCubeUOM = Me.InnerCaseCubeUOM
            rec.InnerCaseWeightUOM = Me.InnerCaseWeightUOM
            rec.MasterCaseHeight = Me.MasterCaseHeight
            rec.MasterCaseWidth = Me.MasterCaseWidth
            rec.MasterCaseLength = Me.MasterCaseLength
            rec.MasterCaseWeight = Me.MasterCaseWeight
            rec.MasterCaseCube = Me.MasterCaseCube
            rec.MasterCaseCubeUOM = Me.MasterCaseCubeUOM
            rec.MasterCaseWeightUOM = Me.MasterCaseWeightUOM
            rec.CountryOfOrigin = Me.CountryOfOrigin
            rec.CountryOfOriginName = Me.CountryOfOriginName
            rec.TaxUDA = Me.TaxUDA
            rec.TaxValueUDA = Me.TaxValueUDA
            rec.Discountable = Me.Discountable
            rec.ImportBurden = Me.ImportBurden
            rec.ShippingPoint = Me.ShippingPoint
            rec.PlanogramName = Me.PlanogramName
            rec.Hazardous = Me.Hazardous
            rec.HazardousFlammable = Me.HazardousFlammable
            rec.HazardousContainerType = Me.HazardousContainerType
            rec.HazardousContainerSize = Me.HazardousContainerSize
            rec.MSDSID = Me.MSDSID
            rec.ImageID = Me.ImageID
            rec.Buyer = Me.Buyer
            rec.BuyerFax = Me.BuyerFax
            rec.BuyerEmail = Me.BuyerEmail
            rec.Season = Me.Season
            rec.SKUGroup = Me.SKUGroup
            rec.PackSKU = Me.PackSKU
            rec.StockCategory = Me.StockCategory
            rec.CoinBattery = Me.CoinBattery
            'rec.TSSA = Me.TSSA
            rec.CSA = Me.CSA
            rec.UL = Me.UL
            rec.LicenceAgreement = Me.LicenceAgreement
            rec.FumigationCertificate = Me.FumigationCertificate
            rec.PhytoTemporaryShipment = Me.PhytoTemporaryShipment
            rec.KILNDriedCertificate = Me.KILNDriedCertificate
            rec.ChinaComInspecNumAndCCIBStickers = Me.ChinaComInspecNumAndCCIBStickers
            rec.OriginalVisa = Me.OriginalVisa
            rec.TextileDeclarationMidCode = Me.TextileDeclarationMidCode
            rec.QuotaChargeStatement = Me.QuotaChargeStatement
            rec.MSDS = Me.MSDS
            rec.TSCA = Me.TSCA
            rec.DropBallTestCert = Me.DropBallTestCert
            rec.ManMedicalDeviceListing = Me.ManMedicalDeviceListing
            rec.ManFDARegistration = Me.ManFDARegistration
            rec.CopyRightIndemnification = Me.CopyRightIndemnification
            rec.FishWildLifeCert = Me.FishWildLifeCert
            rec.Proposition65LabelReq = Me.Proposition65LabelReq
            rec.CCCR = Me.CCCR
            rec.FormaldehydeCompliant = Me.FormaldehydeCompliant
            rec.RMSSellable = Me.RMSSellable
            rec.RMSOrderable = Me.RMSOrderable
            rec.RMSInventory = Me.RMSInventory
            rec.StoreTotal = Me.StoreTotal
            rec.DisplayerCost = Me.DisplayerCost
            'rec.ProductCost = Me.ProductCost
            rec.AddChange = Me.AddChange
            rec.POGSetupPerStore = Me.POGSetupPerStore
            rec.POGMaxQty = Me.POGMaxQty
            rec.ProjectedUnitSales = Me.ProjectedUnitSales
            rec.VendorOrAgent = Me.VendorOrAgent
            rec.AgentType = Me.AgentType
            rec.PaymentTerms = Me.PaymentTerms
            rec.Days = Me.Days
            rec.VendorMinOrderAmount = Me.VendorMinOrderAmount
            rec.VendorName = Me.VendorName
            rec.VendorAddress1 = Me.VendorAddress1
            rec.VendorAddress2 = Me.VendorAddress2
            rec.VendorAddress3 = Me.VendorAddress3
            rec.VendorAddress4 = Me.VendorAddress4
            rec.VendorContactName = Me.VendorContactName
            rec.VendorContactPhone = Me.VendorContactPhone
            rec.VendorContactEmail = Me.VendorContactEmail
            rec.VendorContactFax = Me.VendorContactFax
            rec.ManufactureName = Me.ManufactureName
            rec.ManufactureAddress1 = Me.ManufactureAddress1
            rec.ManufactureAddress2 = Me.ManufactureAddress2
            rec.ManufactureContact = Me.ManufactureContact
            rec.ManufacturePhone = Me.ManufacturePhone
            rec.ManufactureEmail = Me.ManufactureEmail
            rec.ManufactureFax = Me.ManufactureFax
            rec.AgentContact = Me.AgentContact
            rec.AgentPhone = Me.AgentPhone
            rec.AgentEmail = Me.AgentEmail
            rec.AgentFax = Me.AgentFax
            rec.HarmonizedCodeNumber = Me.HarmonizedCodeNumber
            rec.ExportHarmonizedCodeNumber = Me.ExportHarmonizedCodeNumber
            rec.StockingStrategyCode = Me.StockingStrategyCode
            rec.DetailInvoiceCustomsDesc = Me.DetailInvoiceCustomsDesc
            rec.ComponentMaterialBreakdown = Me.ComponentMaterialBreakdown
            rec.ComponentConstructionMethod = Me.ComponentConstructionMethod
            rec.IndividualItemPackaging = Me.IndividualItemPackaging
            rec.FOBShippingPoint = Me.FOBShippingPoint
            rec.DutyPercent = Me.DutyPercent
            rec.DutyAmount = Me.DutyAmount
            rec.AdditionalDutyComment = Me.AdditionalDutyComment
            rec.AdditionalDutyAmount = Me.AdditionalDutyAmount
            rec.SuppTariffPercent = Me.SuppTariffPercent
            rec.SuppTariffAmount = Me.SuppTariffAmount
            rec.OceanFreightAmount = Me.OceanFreightAmount
            rec.OceanFreightComputedAmount = Me.OceanFreightComputedAmount
            rec.AgentCommissionPercent = Me.AgentCommissionPercent
            rec.AgentCommissionAmount = Me.AgentCommissionAmount
            rec.OtherImportCostsPercent = Me.OtherImportCostsPercent
            rec.OtherImportCostsAmount = Me.OtherImportCostsAmount
            rec.PackagingCostAmount = Me.PackagingCostAmount
            rec.WarehouseLandedCost = Me.WarehouseLandedCost
            rec.PurchaseOrderIssuedTo = Me.PurchaseOrderIssuedTo
            rec.VendorComments = Me.VendorComments
            rec.FreightTerms = Me.FreightTerms
            rec.OutboundFreight = Me.OutboundFreight
            rec.NinePercentWhseCharge = Me.NinePercentWhseCharge
            rec.TotalStoreLandedCost = Me.TotalStoreLandedCost
            rec.UpdateUserID = Me.UpdateUserID
            rec.DateLastModified = Me.DateLastModified
            rec.UpdateUserName = Me.UpdateUserName
            rec.StoreSupplierZoneGroup = Me.StoreSupplierZoneGroup
            rec.WHSSupplierZoneGroup = Me.WHSSupplierZoneGroup
            rec.PrimaryVendor = Me.PrimaryVendor
            rec.PackItemIndicator = Me.PackItemIndicator
            rec.ItemTypeAttribute = Me.ItemTypeAttribute
            rec.HybridType = Me.HybridType
            rec.HybridSourceDC = Me.HybridSourceDC
            rec.HazardousMSDSUOM = Me.HazardousMSDSUOM
            rec.DetailInvoiceCustomsDesc0 = Me.DetailInvoiceCustomsDesc0
            rec.DetailInvoiceCustomsDesc1 = Me.DetailInvoiceCustomsDesc1
            rec.DetailInvoiceCustomsDesc2 = Me.DetailInvoiceCustomsDesc2
            rec.DetailInvoiceCustomsDesc3 = Me.DetailInvoiceCustomsDesc3
            rec.DetailInvoiceCustomsDesc4 = Me.DetailInvoiceCustomsDesc4
            rec.DetailInvoiceCustomsDesc5 = Me.DetailInvoiceCustomsDesc5
            rec.ComponentMaterialBreakdown0 = Me.ComponentMaterialBreakdown0
            rec.ComponentMaterialBreakdown1 = Me.ComponentMaterialBreakdown1
            rec.ComponentMaterialBreakdown2 = Me.ComponentMaterialBreakdown2
            rec.ComponentMaterialBreakdown3 = Me.ComponentMaterialBreakdown3
            rec.ComponentMaterialBreakdown4 = Me.ComponentMaterialBreakdown4
            rec.ComponentConstructionMethod0 = Me.ComponentConstructionMethod0
            rec.ComponentConstructionMethod1 = Me.ComponentConstructionMethod1
            rec.ComponentConstructionMethod2 = Me.ComponentConstructionMethod2
            rec.ComponentConstructionMethod3 = Me.ComponentConstructionMethod3
            rec.DepartmentNum = Me.DepartmentNum
            rec.Base1Retail = Me.Base1Retail
            rec.Base2Retail = Me.Base2Retail
            rec.Base3Retail = Me.Base3Retail
            rec.TestRetail = Me.TestRetail
            rec.AlaskaRetail = Me.AlaskaRetail
            rec.CanadaRetail = Me.CanadaRetail
            rec.High1Retail = Me.High1Retail
            rec.High2Retail = Me.High2Retail
            rec.High3Retail = Me.High3Retail
            rec.SmallMarketRetail = Me.SmallMarketRetail
            rec.Low1Retail = Me.Low1Retail
            rec.Low2Retail = Me.Low2Retail
            rec.ManhattanRetail = Me.ManhattanRetail
            rec.QuebecRetail = Me.QuebecRetail
            rec.PuertoRicoRetail = Me.PuertoRicoRetail
            rec.HazardousManufacturerName = Me.HazardousManufacturerName
            rec.HazardousManufacturerCity = Me.HazardousManufacturerCity
            rec.HazardousManufacturerState = Me.HazardousManufacturerState
            rec.HazardousManufacturerPhone = Me.HazardousManufacturerPhone
            rec.HazardousManufacturerCountry = Me.HazardousManufacturerCountry
            rec.ItemType = Me.ItemType
            rec.QtyInPack = Me.QtyInPack
            rec.ItemStatus = Me.ItemStatus
            rec.Base1Clearance = Me.Base1Clearance
            rec.Base2Clearance = Me.Base2Clearance
            rec.Base3Clearance = Me.Base3Clearance
            rec.TestClearance = Me.TestClearance
            rec.AlaskaClearance = Me.AlaskaClearance
            rec.CanadaClearance = Me.CanadaClearance
            rec.High1Clearance = Me.High1Clearance
            rec.High2Clearance = Me.High2Clearance
            rec.High3Clearance = Me.High3Clearance
            rec.SmallMarketClearance = Me.SmallMarketClearance
            rec.Low1Clearance = Me.Low1Clearance
            rec.Low2Clearance = Me.Low2Clearance
            rec.ManhattanClearance = Me.ManhattanClearance
            rec.QuebecClearance = Me.QuebecClearance
            rec.PuertoRicoClearance = Me.PuertoRicoClearance
            rec.FutureCostExists = Me.FutureCostExists
            rec.QuoteSheetItemType = Me.QuoteSheetItemType
            rec.QuoteReferenceNumber = Me.QuoteReferenceNumber
            rec.CustomsDescription = Me.CustomsDescription

            rec.PLIEnglish = Me.PLIEnglish
            rec.PLIFrench = Me.PLIFrench
            rec.PLISpanish = Me.PLISpanish
            rec.TIEnglish = Me.TIEnglish
            rec.TIFrench = Me.TIFrench
            rec.TISpanish = Me.TISpanish
            rec.EnglishShortDescription = Me.EnglishShortDescription
            rec.EnglishLongDescription = Me.EnglishLongDescription
            rec.FrenchLongDescription = Me.FrenchLongDescription
            rec.FrenchShortDescription = Me.FrenchShortDescription
            rec.SpanishLongDescription = Me.SpanishLongDescription
            rec.SpanishShortDescription = Me.SpanishShortDescription
            rec.ExemptEndDateFrench = Me.ExemptEndDateFrench

            rec.StockingStrategyCode = Me.StockingStrategyCode

            'rec.InnerGTIN = Me.InnerGTIN
            'rec.CaseGTIN = Me.CaseGTIN

            rec.MinimumOrderQuantity = Me.MinimumOrderQuantity
            rec.ProductIdentifiesAsCosmetic = Me.ProductIdentifiesAsCosmetic

        End Sub

        Public Function IsPackParent() As Boolean
            Dim str As String = Me.PackItemIndicator
            If str.Length > 2 Then str = str.Substring(0, 2)
            str = str.ToUpper().Replace("-", "")
            If str = "D" Or str = "DP" Or str = "SB" Then
                Return True
            Else
                Return False
            End If
        End Function

    End Class

    Public Class ItemMaintItemDetailFormRecord  ' Used by Item Maint Forms
        Inherits ItemMaintItemDetailRecord

        Public Function Clone() As ItemMaintItemDetailFormRecord
            Dim rec As New ItemMaintItemDetailFormRecord()
            Dim i As Integer
            Me.CopyTo(rec)
            If Me.AdditionalUPCRecs IsNot Nothing Then
                For i = 0 To Me.AdditionalUPCRecs.Count - 1
                    rec.AddAdditionalUPC(Me.AdditionalUPCRecs.Item(i).Clone())
                Next
            End If
            If Me.AdditionalCOORecs IsNot Nothing Then
                For i = 0 To Me.AdditionalCOORecs.Count - 1
                    rec.AddAdditionalCOO(Me.AdditionalCOORecs.Item(i).Clone())
                Next
            End If
            ' return cloned record
            Return rec
        End Function

        Dim _additionalUPCRecs As List(Of ItemMasterVendorUPCRecord) = Nothing
        Dim _additionalCOORecs As List(Of ItemMasterVendorCountryRecord) = Nothing

        Public Property AdditionalUPCRecs() As List(Of ItemMasterVendorUPCRecord)
            Get
                Return _additionalUPCRecs
            End Get
            Set(ByVal value As List(Of ItemMasterVendorUPCRecord))
                If _additionalUPCRecs IsNot Nothing Then
                    _additionalUPCRecs.Clear()
                    _additionalUPCRecs = Nothing
                End If
                _additionalUPCRecs = value
            End Set
        End Property

        Public Sub AddAdditionalUPC(ByVal UPC As String)
            AddAdditionalUPC(New ItemMasterVendorUPCRecord(UPC))
        End Sub

        Public Sub AddAdditionalUPC(ByRef UPCRecord As ItemMasterVendorUPCRecord)
            InitAdditionalUPCRecs()
            AdditionalUPCRecs.Add(UPCRecord)
        End Sub

        Public Property AdditionalCOORecs() As List(Of ItemMasterVendorCountryRecord)
            Get
                Return _additionalCOORecs
            End Get
            Set(ByVal value As List(Of ItemMasterVendorCountryRecord))
                If _additionalCOORecs IsNot Nothing Then
                    _additionalCOORecs.Clear()
                    _additionalCOORecs = Nothing
                End If
                _additionalCOORecs = value
            End Set
        End Property

        Public ReadOnly Property AdditionalCOORecCount() As Integer
            Get
                If _additionalCOORecs IsNot Nothing Then
                    Return _additionalCOORecs.Count
                Else
                    Return 0
                End If
            End Get
        End Property

        Public Function AdditionCOOExists(ByVal countryCode As String) As Boolean
            Dim ret As Boolean = False
            If _additionalCOORecs IsNot Nothing Then
                For Each coo As ItemMasterVendorCountryRecord In _additionalCOORecs
                    If coo.CountryOfOrigin = countryCode Then
                        ret = True
                        Exit For
                    End If
                Next
            End If
            Return ret
        End Function

        Public Function AdditionCOOExistsByName(ByVal countryName As String) As Boolean
            Dim ret As Boolean = False
            If _additionalCOORecs IsNot Nothing Then
                For Each coo As ItemMasterVendorCountryRecord In _additionalCOORecs
                    If coo.CountryOfOriginName = countryName Then
                        ret = True
                        Exit For
                    End If
                Next
            End If
            Return ret
        End Function

        Public Sub AddAdditionalCOO(ByVal countryOfOrigin As String, ByVal countryOfOriginName As String)

            AddAdditionalCOO(New ItemMasterVendorCountryRecord(countryOfOrigin, countryOfOriginName))
        End Sub

        Public Sub AddAdditionalCOO(ByRef COORecord As ItemMasterVendorCountryRecord)
            InitAdditionalCOORecs()
            AdditionalCOORecs.Add(COORecord)
        End Sub

        Public Sub InitLists()
            InitAdditionalUPCRecs()
            InitAdditionalCOORecs()
        End Sub

        Private Sub InitAdditionalUPCRecs()
            If _additionalUPCRecs Is Nothing Then _additionalUPCRecs = New List(Of ItemMasterVendorUPCRecord)
        End Sub

        Private Sub InitAdditionalCOORecs()
            If _additionalCOORecs Is Nothing Then _additionalCOORecs = New List(Of ItemMasterVendorCountryRecord)
        End Sub

        Protected Overrides Sub Finalize()
            If _additionalUPCRecs IsNot Nothing Then
                _additionalUPCRecs.Clear()
                _additionalUPCRecs = Nothing
            End If
            If _additionalCOORecs IsNot Nothing Then
                _additionalCOORecs.Clear()
                _additionalCOORecs = Nothing
            End If
            MyBase.Finalize()
        End Sub

        Public Sub New()

        End Sub
    End Class


End Namespace

