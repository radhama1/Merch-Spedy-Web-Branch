
Namespace Michaels

    Public Class ItemAdditionalUPCRecord
        Private _itemHeaderID As Long
        Private _itemID As Long
        Private _additionalUPCs As ArrayList

        Public Sub New()
            _itemHeaderID = Long.MinValue
            _itemID = Long.MinValue
            _additionalUPCs = New ArrayList()
        End Sub

        Public Sub New(ByVal itemHeaderID As Long, ByVal itemID As Long)
            _itemHeaderID = itemHeaderID
            _itemID = itemID
            _additionalUPCs = New ArrayList()
        End Sub

        Public Sub New(ByVal itemHeaderID As Long, ByVal itemID As Long, ByRef additionalUPCs As ArrayList)
            _itemHeaderID = itemHeaderID
            _itemID = itemID
            _additionalUPCs = additionalUPCs
        End Sub

        Public Property ItemHeaderID() As Long
            Get
                Return _itemHeaderID
            End Get
            Set(ByVal value As Long)
                _itemHeaderID = value
            End Set
        End Property
        Public Property ItemID() As Long
            Get
                Return _itemID
            End Get
            Set(ByVal value As Long)
                _itemID = value
            End Set
        End Property
        Public Property AdditionalUPCs() As ArrayList
            Get
                Return _additionalUPCs
            End Get
            Set(ByVal value As ArrayList)
                _additionalUPCs = value
            End Set
        End Property

        Public Sub AddAdditionalUPC(ByVal additionalUPC As String)
            _additionalUPCs.Add(additionalUPC)
        End Sub

        Protected Overrides Sub Finalize()
            MyBase.Finalize()
            If Not _additionalUPCs Is Nothing Then
                _additionalUPCs.Clear()
                _additionalUPCs = Nothing
            End If
        End Sub
    End Class

End Namespace

