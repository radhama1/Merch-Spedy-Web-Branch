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

Partial Class ReportListAJAX
    Inherits MichaelsBasePage

    Const SESSIONEXPIRED As String = "Session Expired. Please Login again."

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' AJAX Only Page.  Client sends a function call with the parm "f" and additional parms as necessary for the function called
        ' Each function must check security and pass back appropriate HTML if session has expired.
        Dim task As String = LCase(Request("f"))

        Select Case task

            Case "stage"
                ' Return Coded list of Options for Class based on DeptNo
                ' string format: value  |$|  selected (0 or 1)   |$|  Description   |%| - rec separator on all except last
                If Session(cUSERID) Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
                    Response.Clear()
                    Response.Write("|$|0|$|" & SESSIONEXPIRED)
                    Response.End()
                End If

                Dim workflowID As Integer = CInt(Request("w"))
                Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
                Dim stageList As ArrayList = objMichaelsBatch.GetStageList(workflowID)

                Dim sOptions As New StringBuilder
                sOptions.Append("|$|1|$|-- All Active --")
                For Each stage As Models.WorkflowStage In stageList
                    sOptions.Append("|%|" & stage.ID.ToString & "|$|0|$|" & stage.StageName)
                Next

                Do While stageList.Count > 0
                    stageList.RemoveAt(0)
                Loop
                stageList = Nothing
                Response.Write(sOptions.ToString)

            Case Else
                Response.Write("Invalid Function call")

        End Select

        Response.End()
    End Sub
End Class
