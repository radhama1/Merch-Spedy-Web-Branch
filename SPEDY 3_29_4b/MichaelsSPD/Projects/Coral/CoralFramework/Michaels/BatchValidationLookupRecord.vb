
Namespace Michaels

    Public Class BatchValidationLookupRecord
        Private _batchID As Long = 0
        Private _batchType As Michaels.BatchType
        Private _batchErrors As BatchValidationErrors = BatchValidationErrors.None

        Public Sub New()

        End Sub

        Public Sub New(ByVal batchID As Long)
            _batchID = batchID
        End Sub

        Public Sub New(ByVal batchID As Long, ByVal batchType As Michaels.BatchType)
            _batchID = batchID
            _batchType = batchType
        End Sub

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property

        Public Property BatchType() As Michaels.BatchType
            Get
                Return _batchType
            End Get
            Set(ByVal value As Michaels.BatchType)
                _batchType = value
            End Set
        End Property

        Public Property BatchErrors() As BatchValidationErrors
            Get
                Return _batchErrors
            End Get
            Set(ByVal value As BatchValidationErrors)
                _batchErrors = value
            End Set
        End Property

        Public Function HasError(ByVal batchError As BatchValidationErrors) As Boolean
            If ((Me.BatchErrors And batchError) = batchError) Then
                Return True
            Else
                Return False
            End If
        End Function

        ' --------------------------------------------
        ' FUTURE COSTS 
        ' --------------------------------------------

        Protected _futureCostSKUs As List(Of BatchFutureCost) = Nothing

        Public Sub AddFutureCostSKU(ByVal id As Integer, ByVal sku As String, ByVal futureCostExists As Boolean, ByVal futureCostCancelled As Boolean)
            AddFutureCostSKU(New BatchFutureCost(id, sku, futureCostExists, futureCostCancelled))
        End Sub

        Public Sub AddFutureCostSKU(ByRef futureCost As BatchFutureCost)
            If _futureCostSKUs Is Nothing Then _futureCostSKUs = New List(Of BatchFutureCost)
            _futureCostSKUs.Add(futureCost)
        End Sub

        Public ReadOnly Property FutureCostSKUs() As List(Of BatchFutureCost)
            Get
                Return _futureCostSKUs
            End Get
        End Property

    End Class

End Namespace


