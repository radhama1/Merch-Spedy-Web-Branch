
Namespace Michaels

    Public Class BatchFutureCost

        Private _ID As Integer
        Private _SKU As String
        Private _futureCostExists As Boolean
        Private _futureCostCancelled As Boolean

        Public Sub New()
            _ID = 0
            _SKU = String.Empty
            _futureCostExists = False
            _futureCostCancelled = False
        End Sub

        Public Sub New(ByVal id As Integer, ByVal sku As String, ByVal futureCostExists As Boolean, ByVal futureCostCancelled As Boolean)
            _ID = id
            _SKU = sku
            _futureCostExists = futureCostExists
            _futureCostCancelled = futureCostCancelled
        End Sub

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
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

        Public Property FutureCostExists() As Boolean
            Get
                Return _futureCostExists
            End Get
            Set(ByVal value As Boolean)
                _futureCostExists = value
            End Set
        End Property

        Public Property FutureCostCancelled() As Boolean
            Get
                Return _futureCostCancelled
            End Get
            Set(ByVal value As Boolean)
                _futureCostCancelled = value
            End Set
        End Property

    End Class

End Namespace

