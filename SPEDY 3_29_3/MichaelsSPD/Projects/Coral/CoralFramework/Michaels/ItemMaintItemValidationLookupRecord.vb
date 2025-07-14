
Namespace Michaels

    Public Class ItemMaintItemValidationLookupRecord

        Private _ID As Integer = 0

        Private _dept As Integer = 0
        Private _classNum As Integer = 0
        Private _subClassNum As Integer = 0
        Private _deptValid As Boolean = False
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

        ' valid dept and vendor 
        Private _deptString As String = String.Empty
        Private _vendorNumberString As String = String.Empty
        Private _sameDeptValid As Boolean = False
        Private _sameVendorValid As Boolean = False

        Private _ItemTypeAttribute As String = String.Empty
        Private _stockingStrategyCode As String = String.Empty
        Private _StockingStrategyStatusValid As Boolean = False
        Private _StockingStrategyTypeValid As Boolean = False

        'Pack weight
        Private _EachCaseWeight As Decimal = 0.0
        Private _InnerCaseWeight As Decimal = 0.0
        Private _MasterCaseWeight As Decimal = 0.0
        Private _EachesInnerPack As Integer = 0
        Private _EachesMasterPack As Integer = 0
        Private _InnerWeightEachesCompareValid As Boolean = False
        Private _MasterWeightEachesCompareValid As Boolean = False
        Private _MasterWeightInnerEachesRatioValid As Boolean = False

        'GTINs
        Private _InnerGTIN As String = String.Empty
        Private _InnerGTINExists As Boolean = False
        Private _InnerGTINDupBatch As Boolean = False
        Private _InnerGTINDupWorkflow As Boolean = False

        Private _CaseGTIN As String = String.Empty
        Private _CaseGTINExists As Boolean = False
        Private _CaseGTINDupBatch As Boolean = False
        Private _CaseGTINDupWorkflow As Boolean = False

        Private _itemErrors As Integer = 0

        Private _countries As List(Of CountryRecord)
        Private _missingVendors As List(Of Integer)

        Public Sub New()
            _countries = New List(Of CountryRecord)
            _missingVendors = New List(Of Integer)
        End Sub

        Public Sub New(ByVal dept As Integer, ByVal classNum As Integer, ByVal subClassNum As Integer)
            _dept = dept
            _classNum = classNum
            _subClassNum = subClassNum
            _countries = New List(Of CountryRecord)
            _missingVendors = New List(Of Integer)
        End Sub

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
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
        Public Property DeptValid() As Boolean
            Get
                Return _deptValid
            End Get
            Set(ByVal value As Boolean)
                _deptValid = value
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

        Public Property DeptString() As String
            Get
                Return _deptString
            End Get
            Set(ByVal value As String)
                _deptString = value
            End Set
        End Property
        Public Property VendorNumberString() As String
            Get
                Return _vendorNumberString
            End Get
            Set(ByVal value As String)
                _vendorNumberString = value
            End Set
        End Property

        Public Property SameDeptValid() As Boolean
            Get
                Return _sameDeptValid
            End Get
            Set(ByVal value As Boolean)
                _sameDeptValid = value
            End Set
        End Property
        Public Property SameVendorValid() As Boolean
            Get
                Return _sameVendorValid
            End Get
            Set(ByVal value As Boolean)
                _sameVendorValid = value
            End Set
        End Property

        Public Property ItemErrors() As Integer
            Get
                Return _itemErrors
            End Get
            Set(ByVal value As Integer)
                _itemErrors = value
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

        Public Property InnerGTIN() As String
            Get
                Return _InnerGTIN
            End Get
            Set(ByVal value As String)
                _InnerGTIN = value
            End Set
        End Property

        Public Property InnerGTINExists() As Boolean
            Get
                Return _InnerGTINExists
            End Get
            Set(ByVal value As Boolean)
                _InnerGTINExists = value
            End Set
        End Property

        Public Property InnerGTINDupBatch() As Boolean
            Get
                Return _InnerGTINDupBatch
            End Get
            Set(ByVal value As Boolean)
                _InnerGTINDupBatch = value
            End Set
        End Property

        Public Property InnerGTINDupWorkflow() As Boolean
            Get
                Return _InnerGTINDupWorkflow
            End Get
            Set(ByVal value As Boolean)
                _InnerGTINDupWorkflow = value
            End Set
        End Property

        'PMO200141 GTIN14 Enhancements changes 
        Public Property CaseGTIN() As String
            Get
                Return _CaseGTIN
            End Get
            Set(ByVal value As String)
                _CaseGTIN = value
            End Set
        End Property

        Public Property CaseGTINExists() As Boolean
            Get
                Return _CaseGTINExists
            End Get
            Set(ByVal value As Boolean)
                _CaseGTINExists = value
            End Set
        End Property

        Public Property CaseGTINDupBatch() As Boolean
            Get
                Return _CaseGTINDupBatch
            End Get
            Set(ByVal value As Boolean)
                _CaseGTINDupBatch = value
            End Set
        End Property

        Public Property CaseGTINDupWorkflow() As Boolean
            Get
                Return _CaseGTINDupWorkflow
            End Get
            Set(ByVal value As Boolean)
                _CaseGTINDupWorkflow = value
            End Set
        End Property

        Public Function HasError(ByVal itemError As ItemValidationErrors) As Boolean
            If ((Me.ItemErrors And itemError) = itemError) Then
                Return True
            Else
                Return False
            End If
        End Function

        Public ReadOnly Property Countries() As List(Of CountryRecord)
            Get
                Return _countries
            End Get
        End Property

        Public ReadOnly Property CountryCount() As Integer
            Get
                Return _countries.Count
            End Get
        End Property

        Public Function IsValidCountry(ByVal index As Integer) As Boolean
            If index >= 0 And index < _countries.Count Then
                If _countries.Item(index).CountryCode <> String.Empty Then
                    Return True
                Else
                    Return False
                End If
            Else
                Return False
            End If
        End Function

        Public Sub AddCountry(ByVal countryName As String, ByVal countryCode As String)
            Dim country As New CountryRecord(countryName, countryCode)
            Me.AddCountry(country)
        End Sub

        Public Sub AddCountry(ByVal country As CountryRecord)
            _countries.Add(country)
        End Sub

        Public ReadOnly Property MissingVendors() As List(Of Integer)
            Get
                Return _missingVendors
            End Get
        End Property

        Public ReadOnly Property MissingVendorCount() As Integer
            Get
                Return _missingVendors.Count
            End Get
        End Property

        Public Sub AddMissingVendor(ByVal vendor As Integer)
            _missingVendors.Add(vendor)
        End Sub

        Public Function GetMissingVendorsAsString() As String
            Dim str As String = String.Empty
            If _missingVendors.Count > 0 Then
                For i As Integer = 0 To _missingVendors.Count - 1
                    If str <> String.Empty Then str += ", "
                    str += _missingVendors.Item(i).ToString()
                Next
            End If
            Return str
        End Function

        Protected Overrides Sub Finalize()
            _countries.Clear()
            _countries = Nothing
            ' call Finalize on base
            MyBase.Finalize()
        End Sub
    End Class

End Namespace
