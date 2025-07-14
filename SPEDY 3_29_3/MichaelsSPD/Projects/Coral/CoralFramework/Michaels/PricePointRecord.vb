
Namespace Michaels

    Public Class PricePointRecord
        Dim _baseZoneID As Integer = Integer.MinValue
        Dim _diffZoneID As Integer = Integer.MinValue
        Dim _baseRetail As Decimal = Decimal.MinValue
        Dim _diffRetail As Decimal = Decimal.MinValue

        Public Property BaseZoneID() As Integer
            Get
                Return _baseZoneID
            End Get
            Set(ByVal value As Integer)
                _baseZoneID = value
            End Set
        End Property
        Public Property DiffZoneID() As Integer
            Get
                Return _diffZoneID
            End Get
            Set(ByVal value As Integer)
                _diffZoneID = value
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
        Public Property DiffRetail() As Decimal
            Get
                Return _diffRetail
            End Get
            Set(ByVal value As Decimal)
                _diffRetail = value
            End Set
        End Property
    End Class

End Namespace

