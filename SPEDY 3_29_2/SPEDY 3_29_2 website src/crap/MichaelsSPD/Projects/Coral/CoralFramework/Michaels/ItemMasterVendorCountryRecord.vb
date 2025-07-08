
Namespace Michaels

    Public Class ItemMasterVendorCountryRecord
        'Private _primaryIndicator As Boolean = False
        Private _countryOfOrigin As String = String.Empty
        Private _countryOfOriginName As String = String.Empty
        Private _costRecords As List(Of ItemMasterVendorCountryCostRecord) = Nothing

        'Private _countryOfOriginName As String
        'Private _unitCost As Decimal = Decimal.MinValue
        'Private _eachesMasterCase As Integer = Integer.MinValue
        'Private _eachesInnerPack As Integer = Integer.MinValue
        'Private _innerCaseHeight As Decimal = Decimal.MinValue
        'Private _innerCaseWidth As Decimal = Decimal.MinValue
        'Private _innerCaseLength As Decimal = Decimal.MinValue
        'Private _innerCaseWeight As Decimal = Decimal.MinValue
        'Private _innerCaseCube As Decimal = Decimal.MinValue
        'Private _masterCaseHeight As Decimal = Decimal.MinValue
        'Private _masterCaseWidth As Decimal = Decimal.MinValue
        'Private _masterCaseLength As Decimal = Decimal.MinValue
        'Private _masterCaseWeight As Decimal = Decimal.MinValue
        'Private _masterCaseCube As Decimal = Decimal.MinValue
        'Private _importBurden As Decimal = Decimal.MinValue

        Public Sub New()

        End Sub

        Public Sub New(ByVal countryOfOrigin As String, ByVal countryOfOriginName As String)
            _countryOfOrigin = countryOfOrigin
            _countryOfOriginName = countryOfOriginName
        End Sub

        'Public Property CountryOfOriginName() As String
        '    Get
        '        Return _countryOfOriginName
        '    End Get
        '    Set(ByVal value As String)
        '        _countryOfOriginName = value
        '    End Set
        'End Property

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

        'Public Property IsPrimary() As Boolean
        '    Get
        '        Return _primaryIndicator
        '    End Get
        '    Set(ByVal value As Boolean)
        '        _primaryIndicator = value
        '    End Set
        'End Property

        'Public Property UnitCost() As Decimal
        '    Get
        '        Return _unitCost
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _unitCost = value
        '    End Set
        'End Property

        'Public Property EachesMasterCase() As Integer
        '    Get
        '        Return _eachesMasterCase
        '    End Get
        '    Set(ByVal value As Integer)
        '        _eachesMasterCase = value
        '    End Set
        'End Property

        'Public Property EachesInnerPack() As Integer
        '    Get
        '        Return _eachesInnerPack
        '    End Get
        '    Set(ByVal value As Integer)
        '        _eachesInnerPack = value
        '    End Set
        'End Property

        'Public Property InnerCaseHeight() As Decimal
        '    Get
        '        Return _innerCaseHeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _innerCaseHeight = value
        '    End Set
        'End Property

        'Public Property InnerCaseWidth() As Decimal
        '    Get
        '        Return _innerCaseWidth
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _innerCaseWidth = value
        '    End Set
        'End Property

        'Public Property InnerCaseLength() As Decimal
        '    Get
        '        Return _innerCaseLength
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _innerCaseLength = value
        '    End Set
        'End Property

        'Public Property InnerCaseWeight() As Decimal
        '    Get
        '        Return _innerCaseWeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _innerCaseWeight = value
        '    End Set
        'End Property

        'Public Property InnerCaseCube() As Decimal
        '    Get
        '        Return _innerCaseCube
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _innerCaseCube = value
        '    End Set
        'End Property

        'Public Property MasterCaseHeight() As Decimal
        '    Get
        '        Return _masterCaseHeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _masterCaseHeight = value
        '    End Set
        'End Property

        'Public Property MasterCaseWidth() As Decimal
        '    Get
        '        Return _masterCaseWidth
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _masterCaseWidth = value
        '    End Set
        'End Property

        'Public Property MasterCaseLength() As Decimal
        '    Get
        '        Return _masterCaseLength
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _masterCaseLength = value
        '    End Set
        'End Property

        'Public Property MasterCaseWeight() As Decimal
        '    Get
        '        Return _masterCaseWeight
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _masterCaseWeight = value
        '    End Set
        'End Property

        'Public Property MasterCaseCube() As Decimal
        '    Get
        '        Return _masterCaseCube
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _masterCaseCube = value
        '    End Set
        'End Property

        'Public Property ImportBurden() As Decimal
        '    Get
        '        Return _importBurden
        '    End Get
        '    Set(ByVal value As Decimal)
        '        _importBurden = value
        '    End Set
        'End Property

        Public Sub AddCostRecord(ByVal CostRecord As ItemMasterVendorCountryCostRecord)
            _costRecords.Add(CostRecord)
        End Sub

        Public Property GetSetCostRecords() As List(Of ItemMasterVendorCountryCostRecord)
            Get
                Return _costRecords
            End Get
            Set(ByVal value As List(Of ItemMasterVendorCountryCostRecord))
                If Not _costRecords Is Nothing Then
                    _costRecords.Clear()
                    _costRecords = Nothing
                End If
                _costRecords = value
            End Set
        End Property

        Public ReadOnly Property CostRecordsCount() As Integer
            Get
                If Not _costRecords Is Nothing Then
                    Return _costRecords.Count
                Else
                    Return 0
                End If
            End Get
        End Property

        Public Function Clone() As ItemMasterVendorCountryRecord
            Return New ItemMasterVendorCountryRecord(Me.CountryOfOrigin, Me.CountryOfOriginName)
        End Function

    End Class

    Public Class ItemMasterVendorCountryCostRecord
        Private _effectiveDate As String = String.Empty
        Private _cost As Decimal = Decimal.MinValue

        Public Property EffectiveDate() As String
            Get
                Return _effectiveDate
            End Get
            Set(ByVal value As String)
                _effectiveDate = value
            End Set
        End Property

        Public Property Cost() As Decimal
            Get
                Return _cost
            End Get
            Set(ByVal value As Decimal)
                _cost = value
            End Set
        End Property

    End Class


End Namespace
