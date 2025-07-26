
Namespace Michaels

    Public Class ItemUPCValidationError
        Private _sequence As Integer
        Private _upc As String
        Private _upcExists As Boolean
        Private _dupBatch As Boolean
        Private _dupWorkflow As Boolean

        Public Sub New()
            _sequence = 0
            _upc = String.Empty
            _upcExists = False
            _dupBatch = False
            _dupWorkflow = False
        End Sub

        Public Sub New(ByVal sequence As Integer, ByVal upc As String, ByVal upcExists As Boolean, ByVal dupBatch As Boolean, ByVal dupWorkflow As Boolean)
            _sequence = sequence
            _upc = upc
            _upcExists = upcExists
            _dupBatch = dupBatch
            _dupWorkflow = dupWorkflow
        End Sub

        Public Property Sequence() As Integer
            Get
                Return _sequence
            End Get
            Set(ByVal value As Integer)
                _sequence = value
            End Set
        End Property

        Public Property UPC() As String
            Get
                Return _upc
            End Get
            Set(ByVal value As String)
                _upc = value
            End Set
        End Property

        Public Property UPCExists() As Boolean
            Get
                Return _upcExists
            End Get
            Set(ByVal value As Boolean)
                _upcExists = value
            End Set
        End Property

        Public Property DupBatch() As Boolean
            Get
                Return _dupBatch
            End Get
            Set(ByVal value As Boolean)
                _dupBatch = value
            End Set
        End Property

        Public Property DupWorkflow() As Boolean
            Get
                Return _dupWorkflow
            End Get
            Set(ByVal value As Boolean)
                _dupWorkflow = value
            End Set
        End Property

    End Class

End Namespace

