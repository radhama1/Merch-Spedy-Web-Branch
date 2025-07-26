Namespace Michaels

    Public Class ItemMaintItemCostRecord
        Dim _ID As Integer = 0
        Dim _batchID As Long = Long.MinValue
        Dim _enabled As Boolean = False
        Dim _isValid As Integer = Integer.MinValue
        Dim _SKU As String = String.Empty
        Dim _vendorNumber As Long = Long.MinValue
        Dim _vendorName As String = String.Empty
        Dim _batchTypeID As Integer = Integer.MinValue
        Dim _vendorType As Integer = Integer.MinValue
        Dim _primaryUPC As String = String.Empty
        Dim _vendorStyleNum As String = String.Empty
        Dim _itemDesc As String = String.Empty
        Dim _countryOfOrigin As String = String.Empty
        Dim _countryOfOriginName As String = String.Empty
        Dim _effectiveDate As String = String.Empty
        Dim _futureCost As Decimal = Decimal.MinValue
        Dim _futureDisplayerCost As Decimal = Decimal.MinValue


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
        Public Property IsValid() As Integer
            Get
                Return _isValid
            End Get
            Set(ByVal value As Integer)
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
        Public Property VendorNumber() As Long
            Get
                Return _vendorNumber
            End Get
            Set(ByVal value As Long)
                _vendorNumber = value
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
        Public Property ItemDesc() As String
            Get
                Return _itemDesc
            End Get
            Set(ByVal value As String)
                _itemDesc = value
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
        Public Property EffectiveDate() As String
            Get
                Return _effectiveDate
            End Get
            Set(ByVal value As String)
                _effectiveDate = value
            End Set
        End Property

        Public Property FutureCost() As Decimal
            Get
                Return _futureCost
            End Get
            Set(ByVal value As Decimal)
                _futureCost = value
            End Set
        End Property

        Public Property FutureDisplayerCost() As Decimal
            Get
                Return _futureDisplayerCost
            End Get
            Set(ByVal value As Decimal)
                _futureDisplayerCost = value
            End Set
        End Property

    End Class
End Namespace

