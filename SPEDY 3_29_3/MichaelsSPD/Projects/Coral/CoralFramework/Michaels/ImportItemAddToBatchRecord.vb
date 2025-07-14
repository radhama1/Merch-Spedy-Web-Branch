
Namespace Michaels

    Public Class ImportItemAddToBatchRecord
        Private _batchID As Long
        Private _itemCount As Integer

        Public Sub New()
            _batchID = Long.MinValue
            _itemCount = 0
        End Sub

        Public Sub New(ByVal batchID As Long, ByVal itemCount As Integer)
            _batchID = batchID
            _itemCount = itemCount
        End Sub

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property
        Public Property ItemCount() As Integer
            Get
                Return _itemCount
            End Get
            Set(ByVal value As Integer)
                _itemCount = value
            End Set
        End Property
    End Class

End Namespace

