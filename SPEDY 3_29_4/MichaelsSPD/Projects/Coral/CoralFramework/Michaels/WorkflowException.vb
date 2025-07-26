Namespace Michaels

    Public Class WorkflowException

        Public ExcpetionID As Long
        Public ExceptionOrder As Integer
        Public TargetStageID As Integer
        Public ConditionID As Integer
        Public ConditionOrder As Integer
        Public ConditionConjunction As String

        Public Sub New()

        End Sub

        Public Sub New(ByVal excID As Long, ByVal excOrder As Integer, ByVal stageID As Integer, ByVal condID As Integer, ByVal order As Integer, ByVal conjunction As String)
            ExcpetionID = excID
            ExceptionOrder = excOrder
            TargetStageID = stageID
            ConditionID = condID
            ConditionOrder = order
            ConditionConjunction = conjunction
        End Sub
    End Class

End Namespace
