Imports Microsoft.VisualBasic

Public Class SkuList
    Implements IEquatable(Of SkuList)
    Public _sku As String
    Public _vendorNumber As String

    Public Property SKU As String
        Get
            Return _sku
        End Get
        Set(value As String)
            _sku = value
        End Set
    End Property

    Public Property VendorNumber As String
        Get
            Return _vendorNumber
        End Get
        Set(value As String)
            _vendorNumber = value
        End Set
    End Property

    Public Sub New(ByVal setSku As String, ByVal setVendorNumber As String)
        _sku = setSku
        _vendorNumber = setVendorNumber
    End Sub

    Public Overloads Function Equals(ByVal other As SkuList) As Boolean Implements IEquatable(Of SkuList).Equals
        If Me.SKU = other.SKU And Me.VendorNumber = other.VendorNumber Then
            Return True
        Else
            Return False
        End If
    End Function
End Class