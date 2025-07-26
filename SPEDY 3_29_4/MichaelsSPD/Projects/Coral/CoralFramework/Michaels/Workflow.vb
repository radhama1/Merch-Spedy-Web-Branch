
Namespace Michaels

    Public Class Workflow
        Private _ID As Integer = Integer.MinValue
        Private _workFlowName As String = String.Empty
        Private _workFlowDescription As String = String.Empty
        Private _WorkflowShortName As String = String.Empty

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
            End Set
        End Property

        Public Property WorkFlowName() As String
            Get
                Return _workFlowName
            End Get
            Set(ByVal value As String)
                _workFlowName = value
            End Set
        End Property

        Public Property WorkFlowDescription() As String
            Get
                Return _workFlowDescription
            End Get
            Set(ByVal value As String)
                _workFlowDescription = value
            End Set
        End Property

        Public Property WorkflowShortName() As String
            Get
                Return _WorkflowShortName
            End Get
            Set(ByVal value As String)
                _WorkflowShortName = value
            End Set
        End Property

        Public Enum Workflows
            NewItem = 1
            IMBasic = 2
            IMCost = 4
            IMVendor = 5
            IMDeact = 6
            IMReact = 8
            IMPO = 9
            IMPack = 13
        End Enum
    End Class

End Namespace

