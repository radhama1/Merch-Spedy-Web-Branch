
Namespace Michaels

    Public Class ItemMasterRecord

        Private _item As String = String.Empty
        Private _itemID As Integer = 0
        Private _itemDescription As String = String.Empty
        Private _baseRetail As Decimal = Decimal.MinValue
        Private _vendorStyleNum As String = String.Empty
        Private _vendorNumber As Long = 0

        Public Property Item() As String
            Get
                Return _item
            End Get
            Set(ByVal value As String)
                _item = value
            End Set
        End Property
        Public Property ItemID() As Integer
            Get
                Return _itemID
            End Get
            Set(value As Integer)
                _itemID = value
            End Set
        End Property
        Public Property ItemDescription() As String
            Get
                Return _itemDescription
            End Get
            Set(ByVal value As String)
                _itemDescription = value
            End Set
        End Property
        Public Property BaseRetail() As Decimal
            Get
                Return _baseRetail
            End Get
            Set(ByVal value As Decimal)
                _baseRetail = value
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
        Public Property VendorNumber() As Long
            Get
                Return _vendorNumber
            End Get
            Set(value As Long)
                _vendorNumber = value
            End Set
        End Property
    End Class

End Namespace

