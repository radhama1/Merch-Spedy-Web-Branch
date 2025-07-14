Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Collections.Generic
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports WebConstants

Partial Class POAddNewAJAX
    Inherits MichaelsBasePage

    Const SESSIONEXPIRED As String = "Session Expired. Please Login again."

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' AJAX Only Page.  Client sends a function call with the parm "f" and additional parms as necessary for the function called
        ' Each function must check security and pass back appropriate HTML if session has expired.
        Dim task As String = LCase(Request("f"))

        Select Case task
            Case "vendorlookup"
                ' Return simple HTML of Vendor Name based on passed ID
                If Session(cUSERID) Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
                    Response.Clear()
                    Response.Write(SESSIONEXPIRED)
                    Response.End()
                End If
                Dim strTemp As String = Request("VendorID")
                If strTemp.Length > 0 AndAlso IsNumeric(strTemp) Then
                    Dim vendorID As Integer = CInt(strTemp)
                    Response.Clear()
                    Dim desc As String
                    Dim objData As New Data.BatchData()
                    desc = objData.GetVendorName(vendorID)
                    If desc.Length = 0 Then desc = "0"
                    Response.Write(desc)
                Else
                    Response.Write("0")
                End If

            Case "vendor"
                ' Return List of Vendor Numbers / Names based on partial vendor name
                If Session(cUSERID) Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
                    Response.Clear()
                    Response.Write("<ul><li>" & SESSIONEXPIRED & "</li></ul>")
                    Response.End()
                End If
                Dim vendorPart As String = Request("value")
                Response.Clear()
                Response.Write("<ul>")
                Dim vendors As List(Of Models.VendorRecord)
                Dim objData As New Data.BatchData()
                vendors = objData.GetVendors(vendorPart)
                For i As Integer = 0 To vendors.Count - 1
                    Response.Write("<li>" & vendors(i).VendorNumber.ToString & " - " & vendors(i).VendorName & "</li>")
                Next
                Response.Write("</ul>")
                vendors.Clear()
                vendors = Nothing

            Case "upc"
                ' Verify UPC is valid. 1 if true else 0
                Dim UPC As String = Request("UPCNo")
                If ValidationHelper.ValidateUPC(UPC) Then
                    Response.Write("1")
                Else
                    Response.Write("0")
                End If

            Case Else
                Response.Write("Invalid Function call")

        End Select

        Response.End()
    End Sub
End Class
