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

Partial Class ItemMaintAJAX
    Inherits MichaelsBasePage

    Const SESSIONEXPIRED As String = "Session Expired. Please Login again."

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' AJAX Only Page.  Client sends a function call with the parm "f" and additional parms as necessary for the function called
        ' Each function must check security and pass back appropriate HTML if session has expired.
        Dim task As String = LCase(Request("f"))

        Select Case task

            Case "mainttype"    ' Get List of Valid Maint Types for User

                ' Return Coded list of Options for Class based on DeptNo
                ' string format: value  |$|  selected (0 or 1)   |$|  Description   |%| - rec separator on all except last
                If Session(cUSERID) Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
                    Response.Clear()
                    Response.Write("-2|$|0|$|" & SESSIONEXPIRED)
                    Response.End()
                End If

                Dim workflowRecs As List(Of Models.Workflow)
                Dim objdata As New Data.BatchData
                workflowRecs = objdata.GetItemMaitenanceWorkflows(, Session(cUSERID))
                Dim sOptions As New StringBuilder
                Dim recCount As Integer = workflowRecs.Count - 1

                If recCount <= 0 Then
                    sOptions.Append("-1|$|1|$|* Error: No Item Maint Records Found *")
                Else
                    sOptions.Append("-1|$|1|$|* Select Item Maintenance Type *")
                    For i As Integer = 0 To recCount
                        sOptions.Append("|%|" & workflowRecs(i).ID & "|$|0|$|" & workflowRecs(i).WorkflowShortName)
                    Next
                    workflowRecs.Clear()
                    workflowRecs = Nothing
                    Response.Write(sOptions.ToString)
                End If

            Case "deptlist"
                Dim departments As List(Of Models.DepartmentRecord)
                Dim objData As New Data.DepartmentData
                Dim sOptions As New StringBuilder
                departments = objData.GetDepartments
                Dim recCount As Integer = departments.Count - 1

                If recCount <= 0 Then
                    sOptions.Append("-1|$|1|$|* Error: No Department Records Found *")
                Else
                    sOptions.Append("-1|$|1|$|* Selection Required *")
                    For i As Integer = 0 To recCount
                        sOptions.Append("|%|" & departments(i).Dept & "|$|0|$|" & departments(i).DeptDesc)
                    Next
                    departments.Clear()
                    departments = Nothing
                    Response.Write(sOptions.ToString)
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


            Case Else
                Response.Write("Invalid Function call")

        End Select

        Response.End()
    End Sub
End Class
