Imports System.Data
Imports System.Data.SqlClient

Partial Class login
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsPostBack Then
            loginError.Text = "Invalid username and/or password.  Please login again."
            loginError.Attributes.Add("style", "color:#ff2222;font-weight:bold;")
        End If
    End Sub
End Class
