Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Collections.Generic
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class LookupPODisApproveStages
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' Quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Clear()
            Response.Write("-2|$|0|$|Session Timed Out. Please Log in again.")
            Response.End()
        End If

        ' Get IDs from QueryString
		Dim poID As Long = CType(Request("POID"), Long)
		Dim poType As String = Request("POType").ToString

        ' Get previous stages for this PO Record.
        Dim revStages As List(Of Models.WorkflowStage)

		'Get DisapprovalStages for a PO_Maintenance or PO_Creation record
		If poType = "M" Then
			revStages = Michaels.POMaintenanceData.GetDisApprovalStages(poID)
		Else
			revStages = Michaels.POCreationData.GetDisApprovalStages(poID)
		End If


        ' IF previous stages were returned, assembly them into an output
        Dim stagesOutput As New StringBuilder("")
        If revStages.Count > 0 Then

            For i As Integer = 0 To revStages.Count - 1
                stagesOutput.Append(revStages(i).ID.ToString & "|$|0|$|" & revStages(i).StageName & "|%|")
            Next
        End If

        Response.Clear()
        Response.Write(stagesOutput)

    End Sub

End Class
