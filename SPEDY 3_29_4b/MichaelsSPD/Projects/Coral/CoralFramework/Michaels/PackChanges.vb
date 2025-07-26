
Namespace Michaels

    Public Class PackChanges

        Private _batchID As Long = 0
        Private _SKUsAddedToPack As String = String.Empty
        Private _SKUsDeletedFromPack As String = String.Empty

        Public Sub New()

        End Sub

        Public Sub New(ByVal batchID As Long)
            _batchID = batchID
        End Sub

        Public Sub New(ByVal batchID As Long, ByVal SKUsAdded As String, ByVal SKUsDeleted As String)
            _batchID = batchID
            _SKUsAddedToPack = SKUsAdded
            _SKUsDeletedFromPack = SKUsDeleted
        End Sub

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property

        Public Property SKUsAddedToPack() As String
            Get
                Return _SKUsAddedToPack
            End Get
            Set(ByVal value As String)
                _SKUsAddedToPack = value
            End Set
        End Property

        Public Property SKUsDeletedFromPack() As String
            Get
                Return _SKUsDeletedFromPack
            End Get
            Set(ByVal value As String)
                _SKUsDeletedFromPack = value
            End Set
        End Property

        Public Function HasChanges() As Boolean
            If _SKUsAddedToPack.Trim() <> String.Empty OrElse _SKUsDeletedFromPack.Trim() <> String.Empty Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Function SKUsAdded() As Boolean
            If _SKUsAddedToPack.Trim() <> String.Empty Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Function SKUsDeleted() As Boolean
            If _SKUsDeletedFromPack.Trim() <> String.Empty Then
                Return True
            Else
                Return False
            End If
        End Function

    End Class


End Namespace
