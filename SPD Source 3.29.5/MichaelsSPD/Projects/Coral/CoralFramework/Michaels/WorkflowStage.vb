
Namespace Michaels

    Public Class WorkflowStage
        Private _ID As Integer
        Private _stageName As String
        Private _previousStage As Integer
        Private _nextStage As Integer

        Public Sub New()
            _ID = Integer.MinValue
            _stageName = String.Empty
        End Sub

        Public Sub New(ByVal id As Integer, ByVal stageName As String)
            _ID = id
            _stageName = stageName
        End Sub

        Public Sub New(ByVal id As Integer, ByVal stageName As String, ByVal previousStage As Integer, ByVal nextStage As Integer)
            _ID = id
            _stageName = stageName
            _previousStage = previousStage
            _nextStage = nextStage
        End Sub

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
            End Set
        End Property

        Public Property StageName() As String
            Get
                Return _stageName
            End Get
            Set(ByVal value As String)
                _stageName = value
            End Set
        End Property

        Public Property PreviousStage() As Integer
            Get
                Return _previousStage
            End Get
            Set(ByVal value As Integer)
                _previousStage = value
            End Set
        End Property

        Public Property NextStage() As Integer
            Get
                Return _nextStage
            End Get
            Set(ByVal value As Integer)
                _nextStage = value
            End Set
        End Property

    End Class

End Namespace

