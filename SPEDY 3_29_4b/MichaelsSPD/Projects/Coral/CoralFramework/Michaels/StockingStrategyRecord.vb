
Namespace Michaels
    Public Class StockingStrategyRecord

        Private _strategyCode As String = String.Empty
        Private _strategyDesc As String = String.Empty
        Private _strategyType As String = String.Empty
        Private _warehouse As Int64 = 0
        Private _startDate As DateTime = System.DateTime.MinValue
        Private _endDate As DateTime = System.DateTime.MinValue
        Private _strategyStatus As String = String.Empty

        Public Property StrategyCode() As String
            Get
                Return _strategyCode
            End Get
            Set(ByVal value As String)
                _strategyCode = value
            End Set
        End Property

        Public Property StrategyDesc() As String
            Get
                Return _strategyDesc
            End Get
            Set(ByVal value As String)
                _strategyDesc = value
            End Set
        End Property

        Public Property StrategyType() As String
            Get
                Return _strategyType
            End Get
            Set(ByVal value As String)
                _strategyType = value
            End Set
        End Property

        Public Property Warehouse() As Int64
            Get
                Return _warehouse
            End Get
            Set(ByVal value As Int64)
                _warehouse = value
            End Set
        End Property

        Public Property StartDate() As DateTime
            Get
                Return _startDate
            End Get
            Set(ByVal value As DateTime)
                _startDate = value
            End Set
        End Property

        Public Property EndDate() As DateTime
            Get
                Return _endDate
            End Get
            Set(ByVal value As DateTime)
                _endDate = value
            End Set
        End Property

        Public Property StrategyStatus() As String
            Get
                Return _strategyStatus
            End Get
            Set(ByVal value As String)
                _strategyStatus = value
            End Set
        End Property

    End Class
End Namespace

