Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class lookupcountry
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Clear()
            Response.Write("<ul></ul>")
            Response.End()
        End If

        Dim countryPart As String = Request("value")

        Response.Clear()
        Response.Write("<ul>")
        Dim countries As ArrayList = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountries(countryPart)
        For i As Integer = 0 To countries.Count - 1
            Response.Write("<li>" & countries(i) & "</li>")
        Next
        Response.Write("</ul>")
        countries.Clear()
        countries = Nothing
        Response.End()
    End Sub
End Class
