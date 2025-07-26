
Namespace Michaels

    Public Class ItemCaseGTINValidationError
        Private _sequence As Integer
        Private _casegtin As String
        Private _casegtinexists As String
        Private _casegtindupBatch As String
        Private _casegtindupWorkflow As String

        Public Sub New()
            _sequence = 0
            _casegtin = String.Empty
            _casegtinexists = False
            _casegtindupBatch = False
            _casegtindupWorkflow = False
        End Sub

        Public Sub New(ByVal sequence As Integer, ByVal innergtin As String, ByVal innergtinExists As Boolean, ByVal innergtindupBatch As Boolean, ByVal innergtindupWorkflow As Boolean)
            _sequence = sequence
            _casegtin = innergtin
            _casegtinexists = innergtinExists
            _casegtindupBatch = innergtindupBatch
            _casegtindupWorkflow = innergtindupWorkflow
        End Sub

        Public Property Sequence() As Integer
            Get
                Return _sequence
            End Get
            Set(ByVal value As Integer)
                _sequence = value
            End Set
        End Property

        Public Property CaseGTIN() As String
            Get
                Return _casegtin
            End Get
            Set(ByVal value As String)
                _casegtin = value
            End Set
        End Property

        Public Property CaseGTINExists() As Boolean
            Get
                Return _casegtinexists
            End Get
            Set(ByVal value As Boolean)
                _casegtinexists = value
            End Set
        End Property

        Public Property CaseGTINDupBatch() As Boolean
            Get
                Return _casegtindupBatch
            End Get
            Set(ByVal value As Boolean)
                _casegtindupBatch = value
            End Set
        End Property

        Public Property CaseGTINDupWorkflow() As Boolean
            Get
                Return _casegtindupWorkflow
            End Get
            Set(ByVal value As Boolean)
                _casegtindupWorkflow = value
            End Set
        End Property

    End Class

End Namespace