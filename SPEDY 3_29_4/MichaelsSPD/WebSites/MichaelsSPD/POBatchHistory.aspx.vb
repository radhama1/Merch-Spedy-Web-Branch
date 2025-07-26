Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Helper = NovaLibra.Common.Utilities.DataHelper
Imports Data = NovaLibra.Coral.Data.Michaels

Partial Class POBatchHistory
	Inherits MichaelsBasePage

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

		'Check Session
        SecurityCheckRedirect()

		Dim poID As Long = Helper.SmartValue(Request("poid"), "CLng", 0)
		Dim poType As String = Helper.SmartValue(Request("potype"), "str", "")

		If poID = 0 Then
			Response.Redirect("default.aspx")
		End If

		'Check to see if the PO is Maintenance or Creation
		If poType = "M" Then
			'Get the POMaintenance Record by POID
			Dim poRecord As Models.POMaintenanceRecord = Data.POMaintenanceData.GetRecord(poID)
			lblMaintenanceNumber.Text = poRecord.PONumber
			lblCreationNumber.Text = poRecord.BatchNumber

			'Get the Workflow History for the POMaintenance Record using the POID
			gvPOMaintenanceHistory.DataSource = Data.POMaintenanceData.GetWorkflowHistoryByPOID(poID)
			gvPOMaintenanceHistory.DataBind()

			'Get the old Workflow History for the POCreation Record using the BatchNumber
			gvPOCreationHistory.DataSource = Data.POCreationData.GetHistoryByBatchNumber(poRecord.BatchNumber)
			gvPOCreationHistory.DataBind()
		Else
			'Get the POCreation Record by POID
			Dim poRecord As Models.POCreationRecord = Data.POCreationData.GetRecord(poID)
			lblCreationNumber.Text = poRecord.BatchNumber

			'Get the Workflow History for the POCreation Record using the POID
			gvPOCreationHistory.DataSource = Data.POCreationData.GetHistoryByPOID(poID)
			gvPOCreationHistory.DataBind()

			'Hide the POMaintenance section (the record is not yet in Maintenance)
			gvPOMaintenanceHistory.DataSource = Nothing
			gvPOMaintenanceHistory.DataBind()
			MaintenanceDiv.Visible = False
			gvPOMaintenanceHistory.Visible = False
		End If

	End Sub

End Class
