Imports System
Imports System.ComponentModel
Imports System.Text
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls

Imports Microsoft.VisualBasic

Public Class NLControlHelper

    Public Shared Function RemoveDangerousText(ByVal inputString As String) As String
        Return inputString.Replace("<script", "").Replace("</script>", "")
    End Function

End Class
