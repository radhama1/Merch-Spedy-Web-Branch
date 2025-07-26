
Namespace Michaels

    Public Class ItemMasterVendorRecord
        ' Inherits AuditRecord

        Private _michaelsSKU As String = String.Empty
        Private _vendorNumber As Integer = Integer.MinValue
        Private _primaryIndicator As Boolean = False
        Private _vendorStyleNum As String = String.Empty

        Private _UPCRecords As List(Of ItemMasterVendorUPCRecord) = New List(Of ItemMasterVendorUPCRecord)
        Private _CountryRecords As List(Of ItemMasterVendorCountryRecord) = New List(Of ItemMasterVendorCountryRecord)


        'Private _primaryUPC As String = String.Empty
        'Private _primaryCountryOfOrigin As String = String.Empty
        'Private _primaryCountryOfOriginName As String = String.Empty
        'Private _packItemIndicator As String = String.Empty
        'Private _classNum As Integer = Integer.MinValue
        'Private _subClassNum As Integer = Integer.MinValue
        'Private _itemDesc As String = String.Empty
        'Private _hybridType As String = String.Empty
        'Private _hybridSourceDC As String = String.Empty
        'Private _hybridLeadTime As Integer = Integer.MinValue
        'Private _hybridConversionDate As Date = Date.MinValue
        'Private _eachesMasterCase As Integer = Integer.MinValue
        'Private _eachesInnerPack As Integer = Integer.MinValue
        'Private _prePriced As String = String.Empty
        'Private _prePricedUDA As String = String.Empty
        'Private _USCost As Decimal = Decimal.MinValue
        'Private _canadaCost As Decimal = Decimal.MinValue
        'Private _freightTerms As String = String.Empty

        'Private _base1Retail As Decimal = Decimal.MinValue
        'Private _base2Retail As Decimal = Decimal.MinValue
        'Private _base3Retail As Decimal = Decimal.MinValue
        'Private _testRetail As Decimal = Decimal.MinValue
        'Private _alaskaRetail As Decimal = Decimal.MinValue
        'Private _canadaRetail As Decimal = Decimal.MinValue
        'Private _high1Retail As Decimal = Decimal.MinValue
        'Private _high2Retail As Decimal = Decimal.MinValue
        'Private _high3Retail As Decimal = Decimal.MinValue
        'Private _smallMarketRetail As Decimal = Decimal.MinValue
        'Private _low1Retail As Decimal = Decimal.MinValue
        'Private _low2Retail As Decimal = Decimal.MinValue
        'Private _manhattanRetail As Decimal = Decimal.MinValue

        ' From Item Master Header on New Item Record
        'Private _USstockCategory As String = String.Empty
        'Private _canadaStockCategory As String = String.Empty
        'Private _itemType As String = String.Empty
        'Private _itemTypeAttribute As String = String.Empty
        'Private _allowStoreOrder As String
        'Private _inventoryControl As String
        'Private _autoReplenish As String
        'Private _storeSupplierZoneGroup As String = String.Empty
        'Private _wHSSupplierZoneGroup As String = String.Empty
        'Private _storeTotal As Integer = Integer.MinValue
        'Private _POGStartDate As Date = Date.MinValue
        'Private _POGCompDate As Date = Date.MinValue
        'Private _comments As String = String.Empty
        'Private _worksheetDesc As String = String.Empty

        'Private _projectedUnitSales As Decimal = Decimal.MinValue   ' ???

        'Private _innerCaseHeight As Decimal = Decimal.MinValue
        'Private _innerCaseWidth As Decimal = Decimal.MinValue
        'Private _innerCaseLength As Decimal = Decimal.MinValue
        'Private _innerCaseWeight As Decimal = Decimal.MinValue
        'Private _innerCasePackCube As Decimal = Decimal.MinValue
        'Private _masterCaseHeight As Decimal = Decimal.MinValue
        'Private _masterCaseWidth As Decimal = Decimal.MinValue
        'Private _masterCaseLength As Decimal = Decimal.MinValue
        'Private _masterCaseWeight As Decimal = Decimal.MinValue
        'Private _masterCasePackCube As Decimal = Decimal.MinValue

        'Private _taxWizard As Boolean = False
        'Private _taxUDA As String = String.Empty
        'Private _taxValueUDA As Integer = Integer.MinValue

        'Private _hazardous As String = String.Empty
        'Private _hazardousFlammable As String = String.Empty
        'Private _hazardousContainerType As String = String.Empty
        'Private _hazardousContainerSize As Decimal = Decimal.MinValue
        'Private _hazardousMSDSUOM As String = String.Empty
        'Private _hazardousManufacturerName As String = String.Empty
        'Private _hazardousManufacturerCity As String = String.Empty
        'Private _hazardousManufacturerState As String = String.Empty
        'Private _hazardousManufacturerPhone As String = String.Empty
        'Private _hazardousManufacturerCountry As String = String.Empty

        'Private _productImageFileID As Long = Long.MinValue
        'Private _mSDSFileID As Long = Long.MinValue
        'Private _dateCreated As Date = Date.MinValue
        'Private _createdUserID As Integer = Integer.MinValue
        'Private _dateLastModified As Date = Date.MinValue
        'Private _updateUserID As Integer = Integer.MinValue
        'Private _isValid As ItemValidFlag = ItemValidFlag.Unknown

        Public Property MichaelsSKU() As String
            Get
                Return _michaelsSKU
            End Get
            Set(ByVal value As String)
                _michaelsSKU = value
            End Set
        End Property

        Public Property VendorNumber() As Integer
            Get
                Return _vendorNumber
            End Get
            Set(ByVal value As Integer)
                _vendorNumber = value
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

        Public Property isPrimary() As Boolean
            Get
                Return _primaryIndicator
            End Get
            Set(ByVal value As Boolean)
                _primaryIndicator = value
            End Set
        End Property

        Public Sub AddUPCRecord(ByVal UPCRecord As ItemMasterVendorUPCRecord)
            _UPCRecords.Add(UPCRecord)
        End Sub

        Public Property GetSetUPCRecords() As List(Of ItemMasterVendorUPCRecord)
            Get
                Return _UPCRecords
            End Get
            Set(ByVal value As List(Of ItemMasterVendorUPCRecord))
                If Not _UPCRecords Is Nothing Then
                    _UPCRecords.Clear()
                    _UPCRecords = Nothing
                End If
                _UPCRecords = value
            End Set
        End Property

        Public ReadOnly Property UPCRecordsCount() As Integer
            Get
                If Not _UPCRecords Is Nothing Then
                    Return _UPCRecords.Count
                Else
                    Return 0
                End If
            End Get
        End Property

        Public Sub AddACountryRecord(ByVal CountryRecord As ItemMasterVendorCountryRecord)
            _CountryRecords.Add(CountryRecord)
        End Sub

        Public Property GetSetCountryRecords() As List(Of ItemMasterVendorCountryRecord)
            Get
                Return _CountryRecords
            End Get
            Set(ByVal value As List(Of ItemMasterVendorCountryRecord))
                If Not _CountryRecords Is Nothing Then
                    _CountryRecords.Clear()
                    _CountryRecords = Nothing
                End If
                _CountryRecords = value
            End Set
        End Property

        Public ReadOnly Property CountryRecordsCount() As Integer
            Get
                If Not _UPCRecords Is Nothing Then
                    Return _UPCRecords.Count
                Else
                    Return 0
                End If
            End Get
        End Property


        'Private _batchID As Long = Long.MinValue
        'Private _batchStageID As Long
        'Private _batchStageName As String
        'Private _createdUser As String
        'Private _updateUser As String

        'Public Property PrimaryUPC() As String
        '    Get
        '        Return _primaryUPC
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _primaryUPC Then Me.AddAuditField("Primary_UPC", value)
        '        _primaryUPC = value
        '    End Set
        'End Property
        'Public Property PrimaryVendor() As Boolean
        '    Get
        '        Return _primaryVendor
        '    End Get
        '    Set(ByVal value As Boolean)
        '        If Me.SaveAudit AndAlso value <> _primaryVendor Then Me.AddAuditField("Primary_Vendor", value)
        '        _primaryVendor = value
        '    End Set
        'End Property

        'Public Property PackItemIndicator() As String
        '    Get
        '        Return _packItemIndicator
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _packItemIndicator Then Me.AddAuditField("Pack_Item_Indicator", value)
        '        _packItemIndicator = value
        '    End Set
        'End Property

        'Public Property ClassNum() As Integer
        '    Get
        '        Return _classNum
        '    End Get
        '    Set(ByVal value As Integer)
        '        If Me.SaveAudit AndAlso value <> _classNum Then Me.AddAuditField("Class_Num", value)
        '        _classNum = value
        '    End Set
        'End Property
        'Public Property SubClassNum() As Integer
        '    Get
        '        Return _subClassNum
        '    End Get
        '    Set(ByVal value As Integer)
        '        If Me.SaveAudit AndAlso value <> _subClassNum Then Me.AddAuditField("Sub_Class_Num", value)
        '        _subClassNum = value
        '    End Set
        'End Property
        'Public Property ItemDesc() As String
        '    Get
        '        Return _itemDesc
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _itemDesc Then Me.AddAuditField("Item_Desc", value)
        '        _itemDesc = value
        '    End Set
        'End Property

        'Public Property Comments() As String
        '    Get
        '        Return _comments
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _comments Then Me.AddAuditField("Comments", value)
        '        _comments = value
        '    End Set
        'End Property

        'Public Property WorksheetDesc() As String
        '    Get
        '        Return _worksheetDesc
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _worksheetDesc Then Me.AddAuditField("Worksheet_Desc", value)
        '        _worksheetDesc = value
        '    End Set
        'End Property

        'Public Property FreightTerms() As String
        '    Get
        '        Return _freightTerms
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _freightTerms Then Me.AddAuditField("Freight_Terms", value)
        '        _freightTerms = value
        '    End Set
        'End Property

        ''Public Property HybridSourceDC() As String
        ''    Get
        ''        Return _hybridSourceDC
        ''    End Get
        ''    Set(ByVal value As String)
        ''        If Me.SaveAudit AndAlso value <> _hybridSourceDC Then Me.AddAuditField("Hybrid_Source_DC", value)
        ''        _hybridSourceDC = value
        ''    End Set
        ''End Property
        ''Public Property HybridLeadTime() As Integer
        ''    Get
        ''        Return _hybridLeadTime
        ''    End Get
        ''    Set(ByVal value As Integer)
        ''        If Me.SaveAudit AndAlso value <> _hybridLeadTime Then Me.AddAuditField("Hybrid_Lead_Time", value)
        ''        _hybridLeadTime = value
        ''    End Set
        ''End Property
        ''Public Property HybridConversionDate() As Date
        ''    Get
        ''        Return _hybridConversionDate
        ''    End Get
        ''    Set(ByVal value As Date)
        ''        If Me.SaveAudit AndAlso value <> _hybridConversionDate Then Me.AddAuditField("Hybrid_Conversion_Date", value)
        ''        _hybridConversionDate = value
        ''    End Set
        ''End Property
        'Public Property EachesMasterCase() As Integer
        '    Get
        '        Return _eachesMasterCase
        '    End Get
        '    Set(ByVal value As Integer)
        '        If Me.SaveAudit AndAlso value <> _eachesMasterCase Then Me.AddAuditField("Eaches_Master_Case", value)
        '        _eachesMasterCase = value
        '    End Set
        'End Property
        'Public Property EachesInnerPack() As Integer
        '    Get
        '        Return _eachesInnerPack
        '    End Get
        '    Set(ByVal value As Integer)
        '        If Me.SaveAudit AndAlso value <> _eachesInnerPack Then Me.AddAuditField("Eaches_Inner_Pack", value)
        '        _eachesInnerPack = value
        '    End Set
        'End Property
        'Public Property PrePriced() As String
        '    Get
        '        Return _prePriced
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _prePriced Then Me.AddAuditField("Pre_Priced", value)
        '        _prePriced = value
        '    End Set
        'End Property
        ''Public Property PrePricedUDA() As String
        ''    Get
        ''        Return _prePricedUDA
        ''    End Get
        ''    Set(ByVal value As String)
        ''        If Me.SaveAudit AndAlso value <> _prePricedUDA Then Me.AddAuditField("Pre_Priced_UDA", value)
        ''        _prePricedUDA = value
        ''    End Set
        ''End Property
        'Public Property USCost() As Decimal
        '    Get
        '        Return _USCost
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _USCost Then Me.AddAuditField("US_Cost", value)
        '        _USCost = value
        '    End Set
        'End Property
        'Public Property CanadaCost() As Decimal
        '    Get
        '        Return _canadaCost
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _canadaCost Then Me.AddAuditField("Canada_Cost", value)
        '        _canadaCost = value
        '    End Set
        'End Property
        ''Public Property Base1Retail() As Decimal
        ''    Get
        ''        Return _base1Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _base1Retail Then Me.AddAuditField("Base_Retail", value)
        ''        _base1Retail = value
        ''    End Set
        ''End Property

        ''Public Property Base2Retail() As Decimal
        ''    Get
        ''        Return _base2Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _base2Retail Then Me.AddAuditField("[Base2_Retail]", value)
        ''        _base2Retail = value
        ''    End Set
        ''End Property

        ''Public Property TestRetail() As Decimal
        ''    Get
        ''        Return _testRetail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _testRetail Then Me.AddAuditField("Test_Retail", value)
        ''        _testRetail = value
        ''    End Set
        ''End Property

        ''Public Property AlaskaRetail() As Decimal
        ''    Get
        ''        Return _alaskaRetail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _alaskaRetail Then Me.AddAuditField("Alaska_Retail", value)
        ''        _alaskaRetail = value
        ''    End Set
        ''End Property

        ''Public Property CanadaRetail() As Decimal
        ''    Get
        ''        Return _canadaRetail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _canadaRetail Then Me.AddAuditField("Canada_Retail", value)
        ''        _canadaRetail = value
        ''    End Set
        ''End Property

        ''Public Property High2Retail() As Decimal
        ''    Get
        ''        Return _high2Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _high2Retail Then Me.AddAuditField("High2_Retail", value)
        ''        _high2Retail = value
        ''    End Set
        ''End Property

        ''Public Property High3Retail() As Decimal
        ''    Get
        ''        Return _high3Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _high3Retail Then Me.AddAuditField("High3_Retail", value)
        ''        _high3Retail = value
        ''    End Set
        ''End Property

        ''Public Property SmallMarketRetail() As Decimal
        ''    Get
        ''        Return _smallMarketRetail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        If Me.SaveAudit AndAlso value <> _smallMarketRetail Then Me.AddAuditField("Small_Market_Retail", value)
        ''        _smallMarketRetail = value
        ''    End Set
        ''End Property

        'Public Property InnerCaseHeight() As Decimal
        '    Get
        '        Return _innerCaseHeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _innerCaseHeight Then Me.AddAuditField("Inner_Case_Height", value)
        '        _innerCaseHeight = value
        '    End Set
        'End Property
        'Public Property InnerCaseWidth() As Decimal
        '    Get
        '        Return _innerCaseWidth
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _innerCaseWidth Then Me.AddAuditField("Inner_Case_Width", value)
        '        _innerCaseWidth = value
        '    End Set
        'End Property
        'Public Property InnerCaseLength() As Decimal
        '    Get
        '        Return _innerCaseLength
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _innerCaseLength Then Me.AddAuditField("Inner_Case_Length", value)
        '        _innerCaseLength = value
        '    End Set
        'End Property
        'Public Property InnerCaseWeight() As Decimal
        '    Get
        '        Return _innerCaseWeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _innerCaseWeight Then Me.AddAuditField("Inner_Case_Weight", value)
        '        _innerCaseWeight = value
        '    End Set
        'End Property
        'Public Property InnerCasePackCube() As Decimal
        '    Get
        '        Return _innerCasePackCube
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _innerCasePackCube Then Me.AddAuditField("Inner_Case_Pack_Cube", value)
        '        _innerCasePackCube = value
        '    End Set
        'End Property
        'Public Property MasterCaseHeight() As Decimal
        '    Get
        '        Return _masterCaseHeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _masterCaseHeight Then Me.AddAuditField("Master_Case_Height", value)
        '        _masterCaseHeight = value
        '    End Set
        'End Property
        'Public Property MasterCaseWidth() As Decimal
        '    Get
        '        Return _masterCaseWidth
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _masterCaseWidth Then Me.AddAuditField("Master_Case_Width", value)
        '        _masterCaseWidth = value
        '    End Set
        'End Property
        'Public Property MasterCaseLength() As Decimal
        '    Get
        '        Return _masterCaseLength
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _masterCaseLength Then Me.AddAuditField("Master_Case_Length", value)
        '        _masterCaseLength = value
        '    End Set
        'End Property
        'Public Property MasterCaseWeight() As Decimal
        '    Get
        '        Return _masterCaseWeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _masterCaseWeight Then Me.AddAuditField("Master_Case_Weight", value)
        '        _masterCaseWeight = value
        '    End Set
        'End Property
        'Public Property MasterCasePackCube() As Decimal
        '    Get
        '        Return _masterCasePackCube
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _masterCasePackCube Then Me.AddAuditField("Master_Case_Pack_Cube", value)
        '        _masterCasePackCube = value
        '    End Set
        'End Property

        'Public Property PrimaryCountryofOrigin() As String
        '    Get
        '        Return _primaryCountryOfOrigin
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _primaryCountryOfOrigin Then Me.AddAuditField("Primary_Country_of_Origin", value)
        '        _primaryCountryOfOrigin = value
        '    End Set
        'End Property
        'Public Property PrimaryCountryOfOriginName() As String
        '    Get
        '        Return _primaryCountryOfOriginName
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _primaryCountryOfOriginName Then Me.AddAuditField("Primary_Country_of_Origin_Name", value)
        '        _primaryCountryOfOriginName = value
        '    End Set
        'End Property
        ''Public Property TaxUDA() As String
        ''    Get
        ''        Return _taxUDA
        ''    End Get
        ''    Set(ByVal value As String)
        ''        If Me.SaveAudit AndAlso value <> _taxUDA Then Me.AddAuditField("Tax_UDA", value)
        ''        _taxUDA = value
        ''    End Set
        ''End Property
        ''Public Property TaxValueUDA() As Integer
        ''    Get
        ''        Return _taxValueUDA
        ''    End Get
        ''    Set(ByVal value As Integer)
        ''        If Me.SaveAudit AndAlso value <> _taxValueUDA Then Me.AddAuditField("Tax_Value_UDA", value)
        ''        _taxValueUDA = value
        ''    End Set
        ''End Property

        'Public Property Hazardous() As String
        '    Get
        '        Return _hazardous
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardous Then Me.AddAuditField("Hazardous", value)
        '        _hazardous = value
        '    End Set
        'End Property
        'Public Property HazardousFlammable() As String
        '    Get
        '        Return _hazardousFlammable
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousFlammable Then Me.AddAuditField("Hazardous_Flammable", value)
        '        _hazardousFlammable = value
        '    End Set
        'End Property
        'Public Property HazardousContainerType() As String
        '    Get
        '        Return _hazardousContainerType
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousContainerType Then Me.AddAuditField("Hazardous_Container_Type", value)
        '        _hazardousContainerType = value
        '    End Set
        'End Property
        'Public Property HazardousContainerSize() As Decimal
        '    Get
        '        Return _hazardousContainerSize
        '    End Get
        '    Set(ByVal value As Decimal)
        '        If Me.SaveAudit AndAlso value <> _hazardousContainerSize Then Me.AddAuditField("Hazardous_Container_Size", value)
        '        _hazardousContainerSize = value
        '    End Set
        'End Property
        'Public Property HazardousMSDSUOM() As String
        '    Get
        '        Return _hazardousMSDSUOM
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousMSDSUOM Then Me.AddAuditField("Hazardous_MSDS_UOM", value)
        '        _hazardousMSDSUOM = value
        '    End Set
        'End Property
        'Public Property HazardousManufacturerName() As String
        '    Get
        '        Return _hazardousManufacturerName
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousManufacturerName Then Me.AddAuditField("Hazardous_Manufacturer_Name", value)
        '        _hazardousManufacturerName = value
        '    End Set
        'End Property
        'Public Property HazardousManufacturerCity() As String
        '    Get
        '        Return _hazardousManufacturerCity
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousManufacturerCity Then Me.AddAuditField("Hazardous_Manufacturer_City", value)
        '        _hazardousManufacturerCity = value
        '    End Set
        'End Property
        'Public Property HazardousManufacturerState() As String
        '    Get
        '        Return _hazardousManufacturerState
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousManufacturerState Then Me.AddAuditField("Hazardous_Manufacturer_State", value)
        '        _hazardousManufacturerState = value
        '    End Set
        'End Property
        'Public Property HazardousManufacturerPhone() As String
        '    Get
        '        Return _hazardousManufacturerPhone
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousManufacturerPhone Then Me.AddAuditField("Hazardous_Manufacturer_Phone", value)
        '        _hazardousManufacturerPhone = value
        '    End Set
        'End Property

        'Public Property HazardousManufacturerCountry() As String
        '    Get
        '        Return _hazardousManufacturerCountry
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _hazardousManufacturerCountry Then Me.AddAuditField("Hazardous_Manufacturer_Country", value)
        '        _hazardousManufacturerCountry = value
        '    End Set
        'End Property

        'Public Property ItemTypeAttribute() As String
        '    Get
        '        Return _itemTypeAttribute
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _itemTypeAttribute Then Me.AddAuditField("Item_Type_Attribute", value)
        '        _itemTypeAttribute = value
        '    End Set
        'End Property

        'Public ReadOnly Property ProductImageFileID() As Long
        '    Get
        '        Return _productImageFileID
        '    End Get
        '    'Set(ByVal value As Long)
        '    '    _productImageFileID = value
        '    'End Set
        'End Property

        'Public Property IsValid() As ItemValidFlag
        '    Get
        '        Return _isValid
        '    End Get
        '    Set(ByVal value As ItemValidFlag)
        '        If Me.SaveAudit AndAlso value <> _isValid Then Me.AddAuditField("Is_Valid", value)
        '        _isValid = value
        '    End Set
        'End Property

        'Public ReadOnly Property MSDSFileID() As Long
        '    Get
        '        Return _mSDSFileID
        '    End Get
        'End Property

        'Public ReadOnly Property DateCreated() As Date
        '    Get
        '        Return _dateCreated
        '    End Get
        'End Property

        'Public ReadOnly Property CreatedUserID() As Integer
        '    Get
        '        Return _createdUserID
        '    End Get
        'End Property

        'Public ReadOnly Property DateLastModified() As Date
        '    Get
        '        Return _dateLastModified
        '    End Get
        'End Property

        'Public ReadOnly Property UpdateUserID() As Integer
        '    Get
        '        Return _updateUserID
        '    End Get
        'End Property

        'Public ReadOnly Property CreatedUser() As String
        '    Get
        '        Return _createdUser
        '    End Get
        'End Property
        'Public ReadOnly Property UpdateUser() As String
        '    Get
        '        Return _updateUser
        '    End Get
        'End Property

        ''Public Property StoreTotal() As Integer
        ''    Get
        ''        Return _storeTotal
        ''    End Get
        ''    Set(ByVal value As Integer)
        ''        _storeTotal = value
        ''    End Set
        ''End Property


        'Public Sub SetReadOnlyData(ByVal dateCreated As Date, _
        '    ByVal createdUserID As Integer, _
        '    ByVal dateLastModified As Date, _
        '    ByVal updateUserID As Integer, _
        '    ByVal createdUser As String, _
        '    ByVal updateUser As String, _
        '    ByVal imageID As Long, _
        '    ByVal msdsID As Long)

        '    _dateCreated = dateCreated
        '    _createdUserID = createdUserID
        '    _dateLastModified = dateLastModified
        '    _updateUserID = updateUserID
        '    _createdUser = createdUser
        '    _updateUser = updateUser
        '    _productImageFileID = imageID
        '    _mSDSFileID = msdsID
        'End Sub

        ''Protected Friend Sub SetTaxWizard(ByVal taxWizard As Boolean)
        ''    _taxWizard = taxWizard
        ''End Sub

        ''Public Property BatchID() As Long
        ''    Get
        ''        Return _batchID
        ''    End Get
        ''    Set(ByVal value As Long)
        ''        _batchID = value
        ''    End Set
        ''End Property

        ''Public Property BatchStageID() As Long
        ''    Get
        ''        Return _batchStageID
        ''    End Get
        ''    Set(ByVal value As Long)
        ''        _batchStageID = value
        ''    End Set
        ''End Property

        ''Public Property BatchStageName() As String
        ''    Get
        ''        Return _batchStageName
        ''    End Get
        ''    Set(ByVal value As String)
        ''        _batchStageName = value
        ''    End Set
        ''End Property

        ''Public Property High1Retail() As Decimal
        ''    Get
        ''        Return _high1Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        _high1Retail = value
        ''    End Set
        ''End Property

        ''Public Property Base3Retail() As Decimal
        ''    Get
        ''        Return _base3Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        _base3Retail = value
        ''    End Set
        ''End Property
        ''Public Property Low1Retail() As Decimal
        ''    Get
        ''        Return _low1Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        _low1Retail = value
        ''    End Set
        ''End Property

        ''Public Property Low2Retail() As Decimal
        ''    Get
        ''        Return _low2Retail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        _low2Retail = value
        ''    End Set
        ''End Property

        ''Public Property ManhattanRetail() As Decimal
        ''    Get
        ''        Return _manhattanRetail
        ''    End Get
        ''    Set(ByVal value As Decimal)
        ''        _manhattanRetail = value
        ''    End Set
        ''End Property

        ''Public Property PrivateBrandLabel() As String
        ''    Get
        ''        Return _privateBrandLabel
        ''    End Get
        ''    Set(ByVal value As String)
        ''        If Me.SaveAudit AndAlso value <> _privateBrandLabel Then Me.AddAuditField("Private_Brand_Label", value)
        ''        _privateBrandLabel = value
        ''    End Set
        ''End Property

        ''Protected Friend Sub SetReadOnlyBatchData(ByVal batchID As Long, ByVal batchStageID As Long, ByVal batchStageName As String)
        ''    _batchID = batchID
        ''    _batchStageID = batchStageID
        ''    _batchStageName = batchStageName
        ''End Sub

        Public Sub New()

        End Sub
    End Class

End Namespace

