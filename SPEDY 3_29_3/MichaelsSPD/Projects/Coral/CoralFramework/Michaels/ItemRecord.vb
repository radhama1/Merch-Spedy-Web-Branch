
Namespace Michaels

    Public Class ItemRecord
        Inherits AuditRecord

        Private _ID As Long = 0
        Private _itemHeaderID As Long = Long.MinValue
        Private _addChange As String = String.Empty
        Private _packItemIndicator As String = String.Empty
        Private _michaelsSKU As String = String.Empty
        Private _vendorUPC As String = String.Empty
        Private _classNum As Integer = Integer.MinValue
        Private _subClassNum As Integer = Integer.MinValue
        Private _vendorStyleNum As String = String.Empty
        Private _itemDesc As String = String.Empty
        Private _hybridType As String = String.Empty
        Private _hybridSourceDC As String = String.Empty
        Private _hybridLeadTime As Integer = Integer.MinValue
        Private _hybridConversionDate As Date = Date.MinValue
        Private _eachesMasterCase As Integer = Integer.MinValue
        Private _eachesInnerPack As Integer = Integer.MinValue
        Private _prePriced As String = String.Empty
        Private _prePricedUDA As String = String.Empty
        Private _USCost As Decimal = Decimal.MinValue
        Private _canadaCost As Decimal = Decimal.MinValue
        Private _baseRetail As Decimal = Decimal.MinValue
        Private _centralRetail As Decimal = Decimal.MinValue
        Private _testRetail As Decimal = Decimal.MinValue
        Private _alaskaRetail As Decimal = Decimal.MinValue
        Private _canadaRetail As Decimal = Decimal.MinValue
        Private _zeroNineRetail As Decimal = Decimal.MinValue
        Private _californiaRetail As Decimal = Decimal.MinValue
        Private _villageCraftRetail As Decimal = Decimal.MinValue
        Private _POGSetupPerStore As Decimal = Decimal.MinValue
        Private _POGMaxQty As Decimal = Decimal.MinValue
        Private _projectedUnitSales As Decimal = Decimal.MinValue
        Private _eachCaseHeight As Decimal = Decimal.MinValue
        Private _eachCaseWidth As Decimal = Decimal.MinValue
        Private _eachCaseLength As Decimal = Decimal.MinValue
        Private _eachCaseWeight As Decimal = Decimal.MinValue
        Private _eachCasePackCube As Decimal = Decimal.MinValue
        Private _innerCaseHeight As Decimal = Decimal.MinValue
        Private _innerCaseWidth As Decimal = Decimal.MinValue
        Private _innerCaseLength As Decimal = Decimal.MinValue
        Private _innerCaseWeight As Decimal = Decimal.MinValue
        Private _innerCasePackCube As Decimal = Decimal.MinValue
        Private _masterCaseHeight As Decimal = Decimal.MinValue
        Private _masterCaseWidth As Decimal = Decimal.MinValue
        Private _masterCaseLength As Decimal = Decimal.MinValue
        Private _masterCaseWeight As Decimal = Decimal.MinValue
        Private _masterCasePackCube As Decimal = Decimal.MinValue
        Private _countryOfOrigin As String = String.Empty
        Private _countryOfOriginName As String = String.Empty
        Private _taxUDA As String = String.Empty
        Private _taxValueUDA As Integer = Integer.MinValue
        Private _hazardous As String = String.Empty
        Private _hazardousFlammable As String = String.Empty
        Private _hazardousContainerType As String = String.Empty
        Private _hazardousContainerSize As Decimal = Decimal.MinValue
        Private _hazardousMSDSUOM As String = String.Empty
        Private _hazardousManufacturerName As String = String.Empty
        Private _hazardousManufacturerCity As String = String.Empty
        Private _hazardousManufacturerState As String = String.Empty
        Private _hazardousManufacturerPhone As String = String.Empty
        Private _hazardousManufacturerCountry As String = String.Empty
        Private _dateCreated As Date = Date.MinValue
        Private _createdUserID As Integer = Integer.MinValue
        Private _dateLastModified As Date = Date.MinValue
        Private _updateUserID As Integer = Integer.MinValue
        Private _isValid As ItemValidFlag = ItemValidFlag.Unknown

        'PMO200141 GTIN14 Enhancements changes
        Private _vendorInnerGTIN As String = String.Empty
        Private _vendorCaseGTIN As String = String.Empty

        Private _ImageID As Long = Long.MinValue
        Private _MSDSID As Long = Long.MinValue

        Private _createdUser As String
        Private _updateUser As String

        Private _taxWizard As Boolean = False
        'LP
        Private _headerCalculateOptions As Integer = 0
        Private _likeItemStoreCount As Decimal = Decimal.MinValue
        'LP
        Private _headerStoreTotal As Integer = Integer.MinValue
        Private _likeItemSKU As String = String.Empty
        Private _likeItemDescription As String = String.Empty
        Private _likeItemRetail As Decimal = Decimal.MinValue
        Private _likeItemRegularUnits As Decimal = Decimal.MinValue
        Private _likeItemSales As Decimal = Decimal.MinValue
        Private _facings As Decimal = Decimal.MinValue
        Private _POGMinQty As Decimal = Decimal.MinValue

        Private _likeItemUnitStoreMonth As Decimal = Decimal.MinValue
        Private _annualRegularUnitForecast As Decimal = Decimal.MinValue
        Private _annualRegRetailSales As Decimal = Decimal.MinValue

        Private _additionalUPCRecord As ItemAdditionalUPCRecord = Nothing

        Private _batchID As Long = Long.MinValue
        Private _batchStageID As Long
        Private _batchStageName As String
        Private _batchStageType As Michaels.WorkflowStageType
        'LP change order 14 aug 17 2009
        Private _retail9 As Decimal = Decimal.MinValue
        Private _retail10 As Decimal = Decimal.MinValue
        Private _retail11 As Decimal = Decimal.MinValue
        Private _retail12 As Decimal = Decimal.MinValue
        Private _retail13 As Decimal = Decimal.MinValue
        Private _RDQuebec As Decimal = Decimal.MinValue
        Private _RDPuertoRico As Decimal = Decimal.MinValue

        Private _privateBrandLabel As String = String.Empty

        Private _qtyInPack As Integer = Integer.MinValue
        Private _totalUSCost As Decimal = Decimal.MinValue
        Private _totalCanadaCost As Decimal = Decimal.MinValue

        Private _validExistingSKU As Boolean = False
        Private _itemStatus As String = String.Empty
        Private _stockCategory As String = String.Empty
        Private _itemTypeAttribute As String = String.Empty
        Private _departmentNum As Integer = Integer.MinValue

        Private _quotereferencenumber As String

        'Multi-lingual fields
        Private _PLIEnglish As String
        Private _PLIFrench As String
        Private _PLISpanish As String
        Private _customsDescription As String = String.Empty
        Private _TIEnglish As String
        Private _TIFrench As String
        Private _TISpanish As String
        Private _englishShortDesc As String = String.Empty
        Private _englishLongDesc As String = String.Empty
        Private _frenchShortDesc As String = String.Empty
        Private _frenchLongDesc As String = String.Empty
        Private _spanishShortDesc As String = String.Empty
        Private _spanishLongDesc As String = String.Empty
        Private _exemptEndDateFrench As String = String.Empty

        'CRC Fields
        Private _harmonizedCodeNumber As String = String.Empty
        Private _canadaHarmonizedCodeNumber As String = String.Empty
        Private _detailInvoiceCustomsDesc As String = String.Empty
        Private _componentMaterialBreakdown As String = String.Empty

        Private _StockingStrategyCode As String = String.Empty

        'Phyto fields
        Private _PhytoSanitaryCertificate As String = String.Empty
        Private _PhytoTemporaryShipment As String = String.Empty

        Public Property ProjectedUnitSales() As Decimal
            Get
                Return _projectedUnitSales
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _projectedUnitSales Then Me.AddAuditField("Projected_Unit_Sales", value)
                _projectedUnitSales = value
            End Set
        End Property

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
                If Not _additionalUPCRecord Is Nothing Then
                    _additionalUPCRecord.ItemID = _ID
                End If
            End Set
        End Property

        Public Property ItemHeaderID() As Long
            Get
                Return _itemHeaderID
            End Get
            Set(ByVal value As Long)
                If Me.SaveAudit AndAlso value <> _itemHeaderID Then Me.AddAuditField("Item_Header_ID", value)
                _itemHeaderID = value
                If Not _additionalUPCRecord Is Nothing Then
                    _additionalUPCRecord.ItemHeaderID = _itemHeaderID
                End If
            End Set
        End Property
        Public Property AddChange() As String
            Get
                Return _addChange
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _addChange Then Me.AddAuditField("Add_Change", value)
                _addChange = value
            End Set
        End Property
        Public Property PackItemIndicator() As String
            Get
                Return _packItemIndicator
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _packItemIndicator Then Me.AddAuditField("Pack_Item_Indicator", value)
                _packItemIndicator = value
            End Set
        End Property
        Public Property MichaelsSKU() As String
            Get
                Return _michaelsSKU
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _michaelsSKU Then Me.AddAuditField("Michaels_SKU", value)
                _michaelsSKU = value
            End Set
        End Property
        Public Property VendorUPC() As String
            Get
                Return _vendorUPC
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _vendorUPC Then Me.AddAuditField("Vendor_UPC", value)
                _vendorUPC = value
            End Set
        End Property
        Public Property ClassNum() As Integer
            Get
                Return _classNum
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _classNum Then Me.AddAuditField("Class_Num", value)
                _classNum = value
            End Set
        End Property
        Public Property SubClassNum() As Integer
            Get
                Return _subClassNum
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _subClassNum Then Me.AddAuditField("Sub_Class_Num", value)
                _subClassNum = value
            End Set
        End Property
        Public Property VendorStyleNum() As String
            Get
                Return _vendorStyleNum
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _vendorStyleNum Then Me.AddAuditField("Vendor_Style_Num", value)
                _vendorStyleNum = value
            End Set
        End Property
        Public Property ItemDesc() As String
            Get
                Return _itemDesc
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemDesc Then Me.AddAuditField("Item_Desc", value)
                _itemDesc = value
            End Set
        End Property
        Public Property HybridType() As String
            Get
                Return _hybridType
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hybridType Then Me.AddAuditField("Hybrid_Type", value)
                _hybridType = value
            End Set
        End Property
        Public Property HybridSourceDC() As String
            Get
                Return _hybridSourceDC
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hybridSourceDC Then Me.AddAuditField("Hybrid_Source_DC", value)
                _hybridSourceDC = value
            End Set
        End Property
        Public Property HybridLeadTime() As Integer
            Get
                Return _hybridLeadTime
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _hybridLeadTime Then Me.AddAuditField("Hybrid_Lead_Time", value)
                _hybridLeadTime = value
            End Set
        End Property
        Public Property HybridConversionDate() As Date
            Get
                Return _hybridConversionDate
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _hybridConversionDate Then Me.AddAuditField("Hybrid_Conversion_Date", value)
                _hybridConversionDate = value
            End Set
        End Property
        Public Property EachesMasterCase() As Integer
            Get
                Return _eachesMasterCase
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _eachesMasterCase Then Me.AddAuditField("Eaches_Master_Case", value)
                _eachesMasterCase = value
            End Set
        End Property
        Public Property EachesInnerPack() As Integer
            Get
                Return _eachesInnerPack
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _eachesInnerPack Then Me.AddAuditField("Eaches_Inner_Pack", value)
                _eachesInnerPack = value
            End Set
        End Property
        Public Property PrePriced() As String
            Get
                Return _prePriced
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _prePriced Then Me.AddAuditField("Pre_Priced", value)
                _prePriced = value
            End Set
        End Property
        Public Property PrePricedUDA() As String
            Get
                Return _prePricedUDA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _prePricedUDA Then Me.AddAuditField("Pre_Priced_UDA", value)
                _prePricedUDA = value
            End Set
        End Property
        Public Property USCost() As Decimal
            Get
                Return _USCost
            End Get
            Set(ByVal value As Decimal)
                If _trackChanges AndAlso value <> _USCost Then _costFieldsChanged = True
                If Me.SaveAudit AndAlso value <> _USCost Then Me.AddAuditField("US_Cost", value)
                _USCost = value
            End Set
        End Property
        Public Property CanadaCost() As Decimal
            Get
                Return _canadaCost
            End Get
            Set(ByVal value As Decimal)
                If _trackChanges AndAlso value <> _canadaCost Then _costFieldsChanged = True
                If Me.SaveAudit AndAlso value <> _canadaCost Then Me.AddAuditField("Canada_Cost", value)
                _canadaCost = value
            End Set
        End Property
        Public Property BaseRetail() As Decimal
            Get
                Return _baseRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _baseRetail Then Me.AddAuditField("Base_Retail", value)
                _baseRetail = value
            End Set
        End Property
        Public Property CentralRetail() As Decimal
            Get
                Return _centralRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _centralRetail Then Me.AddAuditField("Central_Retail", value)
                _centralRetail = value
            End Set
        End Property
        Public Property TestRetail() As Decimal
            Get
                Return _testRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _testRetail Then Me.AddAuditField("Test_Retail", value)
                _testRetail = value
            End Set
        End Property
        Public Property AlaskaRetail() As Decimal
            Get
                Return _alaskaRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _alaskaRetail Then Me.AddAuditField("Alaska_Retail", value)
                _alaskaRetail = value
            End Set
        End Property
        Public Property CanadaRetail() As Decimal
            Get
                Return _canadaRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _canadaRetail Then Me.AddAuditField("Canada_Retail", value)
                _canadaRetail = value
            End Set
        End Property
        Public Property ZeroNineRetail() As Decimal
            Get
                Return _zeroNineRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _zeroNineRetail Then Me.AddAuditField("Zero_Nine_Retail", value)
                _zeroNineRetail = value
            End Set
        End Property
        Public Property CaliforniaRetail() As Decimal
            Get
                Return _californiaRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _californiaRetail Then Me.AddAuditField("California_Retail", value)
                _californiaRetail = value
            End Set
        End Property
        Public Property VillageCraftRetail() As Decimal
            Get
                Return _villageCraftRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _villageCraftRetail Then Me.AddAuditField("Village_Craft_Retail", value)
                _villageCraftRetail = value
            End Set
        End Property
        Public Property POGSetupPerStore() As Decimal
            Get
                Return _POGSetupPerStore
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _POGSetupPerStore Then Me.AddAuditField("POG_Setup_Per_Store", value)
                _POGSetupPerStore = value
            End Set
        End Property
        Public Property POGMaxQty() As Decimal
            Get
                Return _POGMaxQty
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _POGMaxQty Then Me.AddAuditField("POG_Max_Qty", value)
                _POGMaxQty = value
            End Set
        End Property

        Public Property EachCaseHeight() As Decimal
            Get
                Return _EachCaseHeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachCaseHeight Then Me.AddAuditField("Each_Case_Height", value)
                _EachCaseHeight = value
            End Set
        End Property
        Public Property EachCaseWidth() As Decimal
            Get
                Return _EachCaseWidth
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachCaseWidth Then Me.AddAuditField("Each_Case_Width", value)
                _EachCaseWidth = value
            End Set
        End Property
        Public Property EachCaseLength() As Decimal
            Get
                Return _EachCaseLength
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachCaseLength Then Me.AddAuditField("Each_Case_Length", value)
                _EachCaseLength = value
            End Set
        End Property
        Public Property EachCaseWeight() As Decimal
            Get
                Return _EachCaseWeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachCaseWeight Then Me.AddAuditField("Each_Case_Weight", value)
                _EachCaseWeight = value
            End Set
        End Property
        Public Property EachCasePackCube() As Decimal
            Get
                Return _EachCasePackCube
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachCasePackCube Then Me.AddAuditField("Each_Case_Pack_Cube", value)
                _EachCasePackCube = value
            End Set
        End Property

        Public Property InnerCaseHeight() As Decimal
            Get
                Return _innerCaseHeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _innerCaseHeight Then Me.AddAuditField("Inner_Case_Height", value)
                _innerCaseHeight = value
            End Set
        End Property
        Public Property InnerCaseWidth() As Decimal
            Get
                Return _innerCaseWidth
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _innerCaseWidth Then Me.AddAuditField("Inner_Case_Width", value)
                _innerCaseWidth = value
            End Set
        End Property
        Public Property InnerCaseLength() As Decimal
            Get
                Return _innerCaseLength
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _innerCaseLength Then Me.AddAuditField("Inner_Case_Length", value)
                _innerCaseLength = value
            End Set
        End Property
        Public Property InnerCaseWeight() As Decimal
            Get
                Return _innerCaseWeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _innerCaseWeight Then Me.AddAuditField("Inner_Case_Weight", value)
                _innerCaseWeight = value
            End Set
        End Property
        Public Property InnerCasePackCube() As Decimal
            Get
                Return _innerCasePackCube
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _innerCasePackCube Then Me.AddAuditField("Inner_Case_Pack_Cube", value)
                _innerCasePackCube = value
            End Set
        End Property
        Public Property MasterCaseHeight() As Decimal
            Get
                Return _masterCaseHeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _masterCaseHeight Then Me.AddAuditField("Master_Case_Height", value)
                _masterCaseHeight = value
            End Set
        End Property
        Public Property MasterCaseWidth() As Decimal
            Get
                Return _masterCaseWidth
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _masterCaseWidth Then Me.AddAuditField("Master_Case_Width", value)
                _masterCaseWidth = value
            End Set
        End Property
        Public Property MasterCaseLength() As Decimal
            Get
                Return _masterCaseLength
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _masterCaseLength Then Me.AddAuditField("Master_Case_Length", value)
                _masterCaseLength = value
            End Set
        End Property
        Public Property MasterCaseWeight() As Decimal
            Get
                Return _masterCaseWeight
            End Get
            Set(ByVal value As Decimal)
                If _trackChanges AndAlso value <> _masterCaseWeight Then _masterWeightChanged = True
                If Me.SaveAudit AndAlso value <> _masterCaseWeight Then Me.AddAuditField("Master_Case_Weight", value)
                _masterCaseWeight = value
            End Set
        End Property
        Public Property MasterCasePackCube() As Decimal
            Get
                Return _masterCasePackCube
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _masterCasePackCube Then Me.AddAuditField("Master_Case_Pack_Cube", value)
                _masterCasePackCube = value
            End Set
        End Property
        Public Property CountryOfOrigin() As String
            Get
                Return _countryOfOrigin
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _countryOfOrigin Then Me.AddAuditField("Country_Of_Origin", value)
                _countryOfOrigin = value
            End Set
        End Property
        Public Property CountryOfOriginName() As String
            Get
                Return _countryOfOriginName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _countryOfOriginName Then Me.AddAuditField("Country_Of_Origin_Name", value)
                _countryOfOriginName = value
            End Set
        End Property
        Public Property TaxUDA() As String
            Get
                Return _taxUDA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _taxUDA Then Me.AddAuditField("Tax_UDA", value)
                _taxUDA = value
            End Set
        End Property
        Public Property TaxValueUDA() As Integer
            Get
                Return _taxValueUDA
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _taxValueUDA Then Me.AddAuditField("Tax_Value_UDA", value)
                _taxValueUDA = value
            End Set
        End Property
        Public Property Hazardous() As String
            Get
                Return _hazardous
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardous Then Me.AddAuditField("Hazardous", value)
                _hazardous = value
            End Set
        End Property
        Public Property HazardousFlammable() As String
            Get
                Return _hazardousFlammable
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousFlammable Then Me.AddAuditField("Hazardous_Flammable", value)
                _hazardousFlammable = value
            End Set
        End Property
        Public Property HazardousContainerType() As String
            Get
                Return _hazardousContainerType
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousContainerType Then Me.AddAuditField("Hazardous_Container_Type", value)
                _hazardousContainerType = value
            End Set
        End Property
        Public Property HazardousContainerSize() As Decimal
            Get
                Return _hazardousContainerSize
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _hazardousContainerSize Then Me.AddAuditField("Hazardous_Container_Size", value)
                _hazardousContainerSize = value
            End Set
        End Property
        Public Property HazardousMSDSUOM() As String
            Get
                Return _hazardousMSDSUOM
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousMSDSUOM Then Me.AddAuditField("Hazardous_MSDS_UOM", value)
                _hazardousMSDSUOM = value
            End Set
        End Property
        Public Property HazardousManufacturerName() As String
            Get
                Return _hazardousManufacturerName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousManufacturerName Then Me.AddAuditField("Hazardous_Manufacturer_Name", value)
                _hazardousManufacturerName = value
            End Set
        End Property
        Public Property HazardousManufacturerCity() As String
            Get
                Return _hazardousManufacturerCity
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousManufacturerCity Then Me.AddAuditField("Hazardous_Manufacturer_City", value)
                _hazardousManufacturerCity = value
            End Set
        End Property
        Public Property HazardousManufacturerState() As String
            Get
                Return _hazardousManufacturerState
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousManufacturerState Then Me.AddAuditField("Hazardous_Manufacturer_State", value)
                _hazardousManufacturerState = value
            End Set
        End Property
        Public Property HazardousManufacturerPhone() As String
            Get
                Return _hazardousManufacturerPhone
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousManufacturerPhone Then Me.AddAuditField("Hazardous_Manufacturer_Phone", value)
                _hazardousManufacturerPhone = value
            End Set
        End Property
        Public Property HazardousManufacturerCountry() As String
            Get
                Return _hazardousManufacturerCountry
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _hazardousManufacturerCountry Then Me.AddAuditField("Hazardous_Manufacturer_Country", value)
                _hazardousManufacturerCountry = value
            End Set
        End Property
        Public Property IsValid() As ItemValidFlag
            Get
                Return _isValid
            End Get
            Set(ByVal value As ItemValidFlag)
                If Me.SaveAudit AndAlso value <> _isValid Then Me.AddAuditField("Is_Valid", value)
                _isValid = value
            End Set
        End Property

        Public ReadOnly Property ImageID() As Long
            Get
                Return _ImageID
            End Get
        End Property
        Public Sub SetImageID(ByVal imageID As Long)
            _ImageID = imageID
        End Sub
        Public ReadOnly Property MSDSID() As Long
            Get
                Return _MSDSID
            End Get
        End Property
        Public Sub SetMSDSID(ByVal msdsID As Long)
            _MSDSID = msdsID
        End Sub

        Public ReadOnly Property DateCreated() As Date
            Get
                Return _dateCreated
            End Get
        End Property
        Public ReadOnly Property CreatedUserID() As Integer
            Get
                Return _createdUserID
            End Get
        End Property
        Public ReadOnly Property DateLastModified() As Date
            Get
                Return _dateLastModified
            End Get
        End Property
        Public ReadOnly Property UpdateUserID() As Integer
            Get
                Return _updateUserID
            End Get
        End Property


        Public ReadOnly Property CreatedUser() As String
            Get
                Return _createdUser
            End Get
        End Property
        Public ReadOnly Property UpdateUser() As String
            Get
                Return _updateUser
            End Get
        End Property


        Public ReadOnly Property TaxWizard() As Boolean
            Get
                Return _taxWizard
            End Get
        End Property

        Public Property HeaderStoreTotal() As Integer
            Get
                Return _headerStoreTotal
            End Get
            Set(ByVal value As Integer)
                _headerStoreTotal = value
            End Set
        End Property
        Public Property LikeItemSKU() As String
            Get
                Return _likeItemSKU
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _likeItemSKU Then Me.AddAuditField("Like_Item_SKU", value)
                _likeItemSKU = value
            End Set
        End Property
        Public Property LikeItemDescription() As String
            Get
                Return _likeItemDescription
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _likeItemDescription Then Me.AddAuditField("Like_Item_Description", value)
                _likeItemDescription = value
            End Set
        End Property
        Public Property LikeItemRetail() As Decimal
            Get
                Return _likeItemRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemRetail Then Me.AddAuditField("Like_Item_Retail", value)
                _likeItemRetail = value
            End Set
        End Property
        Public Property LikeItemRegularUnit() As Decimal
            Get
                Return _likeItemRegularUnits
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemRegularUnits Then Me.AddAuditField("Like_Item_Regular_Unit", value)
                _likeItemRegularUnits = value
            End Set
        End Property
        Public Property LikeItemSales() As Decimal
            Get
                Return _likeItemSales
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemSales Then Me.AddAuditField("Like_Item_Sales", value)
                _likeItemSales = value
            End Set
        End Property
        Public Property LikeItemStoreCount() As Decimal
            Get
                Return _likeItemStoreCount
            End Get
            Set(ByVal value As Decimal)
                'If Me.SaveAudit AndAlso value <> _likeItemStoreCount Then Me.AddAuditField("LikeItemStoreCount", value)
                _likeItemStoreCount = value
            End Set
        End Property
        Public Property Facings() As Decimal
            Get
                Return _facings
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _facings Then Me.AddAuditField("Facings", value)
                _facings = value
            End Set
        End Property
        Public Property POGMinQty() As Decimal
            Get
                Return _POGMinQty
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _POGMinQty Then Me.AddAuditField("POG_Min_Qty", value)
                _POGMinQty = value
            End Set
        End Property

        Public Property LikeItemUnitStoreMonth() As Decimal
            Get
                Return _likeItemUnitStoreMonth
            End Get
            Set(ByVal value As Decimal)
                _likeItemUnitStoreMonth = value
            End Set
        End Property
        Public Property AnnualRegularUnitForecast() As Decimal
            Get
                Return _annualRegularUnitForecast
            End Get
            Set(ByVal value As Decimal)
                _annualRegularUnitForecast = value
            End Set
        End Property
        Public Property AnnualRegRetailSales() As Decimal
            Get
                Return _annualRegRetailSales
            End Get
            Set(ByVal value As Decimal)
                _annualRegRetailSales = value
            End Set
        End Property

        Public Property AdditionalUPCRecord() As ItemAdditionalUPCRecord
            Get
                If _additionalUPCRecord Is Nothing Then
                    _additionalUPCRecord = New ItemAdditionalUPCRecord(Me.ItemHeaderID, Me.ID)
                End If
                Return _additionalUPCRecord
            End Get
            Set(ByVal value As ItemAdditionalUPCRecord)
                If Not _additionalUPCRecord Is Nothing Then
                    _additionalUPCRecord.AdditionalUPCs.Clear()
                    _additionalUPCRecord = Nothing
                End If
                _additionalUPCRecord = value
                _additionalUPCRecord.ItemHeaderID = Me.ItemHeaderID
                _additionalUPCRecord.ItemID = Me.ID
            End Set
        End Property

        Public ReadOnly Property AdditionalUPCCount() As Integer
            Get
                If Not _additionalUPCRecord Is Nothing Then
                    Return _additionalUPCRecord.AdditionalUPCs.Count
                Else
                    Return 0
                End If
            End Get
        End Property

        Protected Friend Sub SetReadOnlyData(ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updateUser As String, _
            ByVal imageID As Long, _
            ByVal msdsID As Long)

            _dateCreated = dateCreated
            _createdUserID = createdUserID
            _dateLastModified = dateLastModified
            _updateUserID = updateUserID
            _createdUser = createdUser
            _updateUser = updateUser
            _ImageID = imageID
            _MSDSID = msdsID
        End Sub

        Protected Friend Sub SetTaxWizard(ByVal taxWizard As Boolean)
            _taxWizard = taxWizard
        End Sub

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property
        Public Property BatchStageID() As Long
            Get
                Return _batchStageID
            End Get
            Set(ByVal value As Long)
                _batchStageID = value
            End Set
        End Property
        Public Property BatchStageName() As String
            Get
                Return _batchStageName
            End Get
            Set(ByVal value As String)
                _batchStageName = value
            End Set
        End Property
        Public Property BatchStageType() As Michaels.WorkflowStageType
            Get
                Return _batchStageType
            End Get
            Set(ByVal value As Michaels.WorkflowStageType)
                _batchStageType = value
            End Set
        End Property
        Public Property CalculateOptions() As Integer
            Get
                Return _headerCalculateOptions
            End Get
            Set(ByVal value As Integer)
                'If Me.SaveAudit AndAlso value <> _headerCalculateOptions Then Me.AddAuditField("CalculateOptions", value)
                _headerCalculateOptions = value
            End Set
        End Property
        Public Property Retail9() As Decimal
            Get
                Return _retail9
            End Get
            Set(ByVal value As Decimal)
                _retail9 = value
            End Set
        End Property
        Public Property Retail10() As Decimal
            Get
                Return _retail10
            End Get
            Set(ByVal value As Decimal)
                _retail10 = value
            End Set
        End Property
        Public Property Retail11() As Decimal
            Get
                Return _retail11
            End Get
            Set(ByVal value As Decimal)
                _retail11 = value
            End Set
        End Property
        Public Property Retail12() As Decimal
            Get
                Return _retail12
            End Get
            Set(ByVal value As Decimal)
                _retail12 = value
            End Set
        End Property
        Public Property Retail13() As Decimal
            Get
                Return _retail13
            End Get
            Set(ByVal value As Decimal)
                _retail13 = value
            End Set
        End Property
        Public Property RDQuebec() As Decimal
            Get
                Return _RDQuebec
            End Get
            Set(ByVal value As Decimal)
                _RDQuebec = value
            End Set
        End Property
        Public Property RDPuertoRico() As Decimal
            Get
                Return _RDPuertoRico
            End Get
            Set(ByVal value As Decimal)
                _RDPuertoRico = value
            End Set
        End Property


        Public Property PrivateBrandLabel() As String
            Get
                Return _privateBrandLabel
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _privateBrandLabel Then Me.AddAuditField("Private_Brand_Label", value)
                _privateBrandLabel = value
            End Set
        End Property

        Public Property QtyInPack() As Integer
            Get
                Return _qtyInPack
            End Get
            Set(ByVal value As Integer)
                If _trackChanges AndAlso value <> _qtyInPack Then _costFieldsChanged = True
                If Me.SaveAudit AndAlso value <> _qtyInPack Then Me.AddAuditField("Qty_In_Pack", value)
                _qtyInPack = value
            End Set
        End Property

        Public Property TotalUSCost() As Decimal
            Get
                Return _totalUSCost
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _totalUSCost Then Me.AddAuditField("Total_US_Cost", value)
                _totalUSCost = value
            End Set
        End Property

        Public Property TotalCanadaCost() As Decimal
            Get
                Return _totalCanadaCost
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _totalCanadaCost Then Me.AddAuditField("Total_Canada_Cost", value)
                _totalCanadaCost = value
            End Set
        End Property

        Public Property ValidExistingSKU() As Boolean
            Get
                Return _validExistingSKU
            End Get
            Set(ByVal value As Boolean)
                If Me.SaveAudit AndAlso value <> _validExistingSKU Then Me.AddAuditField("Valid_Existing_SKU", value)
                _validExistingSKU = value
            End Set
        End Property

        Public Property ItemStatus() As String
            Get
                Return _itemStatus
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemStatus Then Me.AddAuditField("Item_Status", value)
                _itemStatus = value
            End Set
        End Property
        Public Property StockCategory() As String
            Get
                Return _stockCategory
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _stockCategory Then Me.AddAuditField("Stock_Category", value)
                _stockCategory = value
            End Set
        End Property
        Public Property ItemTypeAttribute() As String
            Get
                Return _itemTypeAttribute
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemTypeAttribute Then Me.AddAuditField("Item_Type_Attribute", value)
                _itemTypeAttribute = value
            End Set
        End Property
        Public Property DepartmentNum() As Integer
            Get
                Return _departmentNum
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _departmentNum Then Me.AddAuditField("Department_Num", value)
                _departmentNum = value
            End Set
        End Property

        Public Property QuoteReferenceNumber() As String
            Get
                Return _quotereferencenumber
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _quotereferencenumber Then Me.AddAuditField("QuoteReferenceNumber", value)
                _quotereferencenumber = value
            End Set
        End Property

        Public Property PLIEnglish() As String
            Get
                Return _PLIEnglish
            End Get
            Set(ByVal value As String)
                _PLIEnglish = value
            End Set
        End Property
        Public Property PLIFrench() As String
            Get
                Return _PLIFrench
            End Get
            Set(ByVal value As String)
                _PLIFrench = value
            End Set
        End Property
        Public Property PLISpanish() As String
            Get
                Return _PLISpanish
            End Get
            Set(ByVal value As String)
                _PLISpanish = value
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
        Public Property TIEnglish() As String
            Get
                Return _TIEnglish
            End Get
            Set(ByVal value As String)
                _TIEnglish = value
            End Set
        End Property
        Public Property TIFrench() As String
            Get
                Return _TIFrench
            End Get
            Set(ByVal value As String)
                _TIFrench = value
            End Set
        End Property
        Public Property TISpanish() As String
            Get
                Return _TISpanish
            End Get
            Set(ByVal value As String)
                _TISpanish = value
            End Set
        End Property
        Public Property EnglishShortDescription() As String
            Get
                Return _englishShortDesc
            End Get
            Set(ByVal value As String)
                _englishShortDesc = value
            End Set
        End Property
        Public Property EnglishLongDescription() As String
            Get
                Return _englishLongDesc
            End Get
            Set(ByVal value As String)
                _englishLongDesc = value
            End Set
        End Property
        Public Property FrenchShortDescription() As String
            Get
                Return _frenchShortDesc
            End Get
            Set(ByVal value As String)
                _frenchShortDesc = value
            End Set
        End Property
        Public Property FrenchLongDescription() As String
            Get
                Return _frenchLongDesc
            End Get
            Set(ByVal value As String)
                _frenchLongDesc = value
            End Set
        End Property
        Public Property SpanishShortDescription() As String
            Get
                Return _spanishShortDesc
            End Get
            Set(ByVal value As String)
                _spanishShortDesc = value
            End Set
        End Property
        Public Property SpanishLongDescription() As String
            Get
                Return _spanishLongDesc
            End Get
            Set(ByVal value As String)
                _spanishLongDesc = value
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

        Public Property StockingStrategyCode() As String
            Get
                Return _StockingStrategyCode
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _StockingStrategyCode Then Me.AddAuditField("Stocking_Strategy_Code", value)
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

        Protected Friend Sub SetReadOnlyBatchData(ByVal batchID As Long, ByVal batchStageID As Long, ByVal batchStageName As String, ByVal stageType As Integer)
            _batchID = batchID
            _batchStageID = batchStageID
            _batchStageName = batchStageName
            If Michaels.WorkflowStageType.IsDefined(GetType(Michaels.WorkflowStageType), stageType) Then
                _batchStageType = CType(stageType, Michaels.WorkflowStageType)
            Else
                _batchStageType = Michaels.WorkflowStageType.General
            End If
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

        Private _trackChanges As Boolean = False
        Public Sub TrackChanges()
            _trackChanges = True
        End Sub
        Private _costFieldsChanged As Boolean = False
        Public ReadOnly Property CostFieldsChanged() As Boolean
            Get
                Return _costFieldsChanged
            End Get
        End Property
        Private _masterWeightChanged As Boolean = False
        Public ReadOnly Property MasterWeightChanged() As Boolean
            Get
                Return _masterWeightChanged
            End Get
        End Property


        'PMO200141 GTIN14 Enhancements changes
        Public Property VendorInnerGTIN() As String
            Get
                Return _vendorInnerGTIN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _vendorInnerGTIN Then Me.AddAuditField("Vendor_InnerGTIN", value)
                _vendorInnerGTIN = value
            End Set
        End Property

        Public Property VendorCaseGTIN() As String
            Get
                Return _vendorCaseGTIN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _vendorCaseGTIN Then Me.AddAuditField("Vendor_CaseGTIN", value)
                _vendorCaseGTIN = value
            End Set
        End Property

        Public Property PhytoSanitaryCertificate() As String
            Get
                Return _PhytoSanitaryCertificate
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemTypeAttribute Then Me.AddAuditField("PhytoSanitaryCertificate", value)
                _PhytoSanitaryCertificate = value
            End Set
        End Property

        Public Property PhytoTemporaryShipment() As String
            Get
                Return _PhytoTemporaryShipment
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemTypeAttribute Then Me.AddAuditField("PhytoTemporaryShipment", value)
                _PhytoTemporaryShipment = value
            End Set
        End Property

    End Class

End Namespace

