
Namespace Michaels

    Public Class ItemValidationLookupRecord
        Inherits ItemValidationLookupBase

        Private _ID As Long = 0

        Private _dept As Integer = 0
        Private _classNum As Integer = 0
        Private _subClassNum As Integer = 0
        Private _classNumValid As Boolean = False
        Private _subClassNumValid As Boolean = False

        ' check for Country of Origin
        Private _countryOfOrigin As String = String.Empty
        Private _countryOfOriginName As String = String.Empty
        Private _countryOfOriginValid As Boolean = False

        ' check for Tax Value UDA
        Private _taxUDA As String = String.Empty
        Private _taxValueUDA As Integer = Integer.MinValue
        Private _taxValueUDAValid As Boolean = False

        ' valid stocking strategy choices
        Private _ItemTypeAttribute As String = String.Empty
        Private _stockingStrategyCode As String = String.Empty
        Private _StockingStrategyStatusValid As Boolean = False
        Private _StockingStrategyTypeValid As Boolean = False

        'pack weight
        Private _EachCaseWeight As Decimal = 0.0
        Private _InnerCaseWeight As Decimal = 0.0
        Private _MasterCaseWeight As Decimal = 0.0
        Private _EachesInnerPack As Integer = 0
        Private _EachesMasterPack As Integer = 0
        Private _InnerWeightEachesCompareValid As Boolean = False
        Private _MasterWeightEachesCompareValid As Boolean = False
        Private _MasterWeightInnerEachesRatioValid As Boolean = False

        Public Sub New()

        End Sub

        Public Sub New(ByVal dept As Integer, ByVal classNum As Integer, ByVal subClassNum As Integer)
            _dept = dept
            _classNum = classNum
            _subClassNum = subClassNum
        End Sub

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property

        Public Property Dept() As Integer
            Get
                Return _dept
            End Get
            Set(ByVal value As Integer)
                _dept = value
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
        Public Property ClassNumValid() As Boolean
            Get
                Return _classNumValid
            End Get
            Set(ByVal value As Boolean)
                _classNumValid = value
            End Set
        End Property
        Public Property SubClassNumValid() As Boolean
            Get
                Return _subClassNumValid
            End Get
            Set(ByVal value As Boolean)
                _subClassNumValid = value
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
        Public Property CountryOfOriginValid() As Boolean
            Get
                Return _countryOfOriginValid
            End Get
            Set(ByVal value As Boolean)
                _countryOfOriginValid = value
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
        Public Property TaxValueUDA() As Integer
            Get
                Return _taxValueUDA
            End Get
            Set(ByVal value As Integer)
                _taxValueUDA = value
            End Set
        End Property
        Public Property TaxValueUDAValid() As Boolean
            Get
                Return _taxValueUDAValid
            End Get
            Set(ByVal value As Boolean)
                _taxValueUDAValid = value
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

        Public Property ItemTypeAttribute() As String
            Get
                Return _ItemTypeAttribute
            End Get
            Set(ByVal value As String)
                _ItemTypeAttribute = value
            End Set
        End Property

        Public Property StockingStrategyStatusValid() As Boolean
            Get
                Return _StockingStrategyStatusValid
            End Get
            Set(ByVal value As Boolean)
                _StockingStrategyStatusValid = value
            End Set
        End Property

        Public Property StockingStrategyTypeValid() As Boolean
            Get
                Return _StockingStrategyTypeValid
            End Get
            Set(ByVal value As Boolean)
                _StockingStrategyTypeValid = value
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

        Public Property InnerCaseWeight() As Decimal
            Get
                Return _InnerCaseWeight
            End Get
            Set(ByVal value As Decimal)
                _InnerCaseWeight = value
            End Set
        End Property

        Public Property MasterCaseWeight() As Decimal
            Get
                Return _MasterCaseWeight
            End Get
            Set(ByVal value As Decimal)
                _MasterCaseWeight = value
            End Set
        End Property

        Public Property EachesInnerPack() As Integer
            Get
                Return _EachesInnerPack
            End Get
            Set(ByVal value As Integer)
                _EachesInnerPack = value
            End Set
        End Property

        Public Property EachesMasterPack() As Integer
            Get
                Return _EachesMasterPack
            End Get
            Set(ByVal value As Integer)
                _EachesMasterPack = value
            End Set
        End Property

        Public Property InnerWeightEachesCompareValid() As Boolean
            Get
                Return _InnerWeightEachesCompareValid
            End Get
            Set(ByVal value As Boolean)
                _InnerWeightEachesCompareValid = value
            End Set
        End Property

        Public Property MasterWeightEachesCompareValid() As Boolean
            Get
                Return _MasterWeightEachesCompareValid
            End Get
            Set(ByVal value As Boolean)
                _MasterWeightEachesCompareValid = value
            End Set
        End Property

        Public Property MasterWeightInnerEachesRatioValid() As Boolean
            Get
                Return _MasterWeightInnerEachesRatioValid
            End Get
            Set(ByVal value As Boolean)
                _MasterWeightInnerEachesRatioValid = value
            End Set
        End Property

    End Class

End Namespace
