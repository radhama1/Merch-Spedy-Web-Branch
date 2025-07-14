
Namespace Michaels
    Public Class PaymentTerm
        Public ID As Integer
        Public Terms As String = ""
        Public TermDescription As String = ""

        Public Sub New()

        End Sub

        Public Sub New(ByVal ptID As Integer, ByVal paymentTerm As String, ByVal description As String)
            ID = ptID
            Terms = paymentTerm
            TermDescription = description
        End Sub

    End Class
End Namespace