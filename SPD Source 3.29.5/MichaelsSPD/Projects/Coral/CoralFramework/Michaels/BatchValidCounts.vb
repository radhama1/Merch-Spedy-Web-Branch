

Namespace Michaels

    Public Class BatchValidCounts
        Private _batchID As Long = 0
        Private _itemValidCount As Integer = 0
        Private _itemNotValidCount As Integer = 0
        Private _itemUnknownCount As Integer = 0

        Public Sub New()

        End Sub

        Public Sub New(ByVal batchID As Long)
            _batchID = batchID
        End Sub

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property
        Public Property ItemValidCount() As Integer
            Get
                Return _itemValidCount
            End Get
            Set(ByVal value As Integer)
                _itemValidCount = value
            End Set
        End Property
        Public Property ItemNotValidCount() As Integer
            Get
                Return _itemNotValidCount
            End Get
            Set(ByVal value As Integer)
                _itemNotValidCount = value
            End Set
        End Property
        Public Property ItemUnknownCount() As Integer
            Get
                Return _itemUnknownCount
            End Get
            Set(ByVal value As Integer)
                _itemUnknownCount = value
            End Set
        End Property

    End Class

End Namespace

