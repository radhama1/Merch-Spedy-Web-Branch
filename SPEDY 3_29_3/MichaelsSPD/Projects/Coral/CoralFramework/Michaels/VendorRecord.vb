
Namespace Michaels

    Public Class VendorRecord
        Private _ID As Long = 0
        Private _vendorNumber As Long = 0
        Private _vendorName As String = String.Empty
        Private _vendorType As String = String.Empty
        Private _paymentTerms As String = String.Empty
		Private _freightTerms As String = String.Empty
		Private _ediFlag As Boolean = False
		Private _currencyCode As String = String.Empty

        Public Sub New()

        End Sub

        Public Sub New(ByVal id As Long)
            _ID = id
        End Sub

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
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

        Public Property VendorType() As String
            Get
                Return _vendorType
            End Get
            Set(ByVal value As String)
                _vendorType = value
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

        Public Property FreightTerms() As String
            Get
                Return _freightTerms
            End Get
            Set(ByVal value As String)
                _freightTerms = value
            End Set
        End Property

		Public Property EDIFlag() As Boolean
			Get
				Return _ediFlag
			End Get
			Set(ByVal value As Boolean)
				_ediFlag = value
			End Set
		End Property

		Public Property CurrencyCode() As String
			Get
				Return _currencyCode
			End Get
			Set(ByVal value As String)
				_currencyCode = value
			End Set
		End Property

    End Class

End Namespace

