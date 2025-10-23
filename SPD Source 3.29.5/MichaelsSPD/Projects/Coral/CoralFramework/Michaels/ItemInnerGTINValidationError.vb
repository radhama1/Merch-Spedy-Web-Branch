
Namespace Michaels

    Public Class ItemInnerGTINValidationError
        Private _sequence As Integer
        Private _innergtin As String
        Private _innergtinexists As String
        Private _innergtindupBatch As String
        Private _innergtindupWorkflow As String

        Public Sub New()
            _sequence = 0
            _innergtin = String.Empty
            _innergtinexists = False
            _innergtindupBatch = False
            _innergtindupWorkflow = False
        End Sub

        Public Sub New(ByVal sequence As Integer, ByVal innergtin As String, ByVal innergtinExists As Boolean, ByVal innergtindupBatch As Boolean, ByVal innergtindupWorkflow As Boolean)
            _sequence = sequence
            _innergtin = innergtin
            _innergtinexists = innergtinExists
            _innergtindupBatch = innergtindupBatch
            _innergtindupWorkflow = innergtindupWorkflow
        End Sub

        Public Property Sequence() As Integer
            Get
                Return _sequence
            End Get
            Set(ByVal value As Integer)
                _sequence = value
            End Set
        End Property

        Public Property InnerGTIN() As String
            Get
                Return _innergtin
            End Get
            Set(ByVal value As String)
                _innergtin = value
            End Set
        End Property

        Public Property InnerGTINExists() As Boolean
            Get
                Return _innergtinexists
            End Get
            Set(ByVal value As Boolean)
                _innergtinexists = value
            End Set
        End Property

        Public Property InnerGTINDupBatch() As Boolean
            Get
                Return _innergtindupBatch
            End Get
            Set(ByVal value As Boolean)
                _innergtindupBatch = value
            End Set
        End Property

        Public Property InnerGTINDupWorkflow() As Boolean
            Get
                Return _innergtindupWorkflow
            End Get
            Set(ByVal value As Boolean)
                _innergtindupWorkflow = value
            End Set
        End Property

    End Class

End Namespace