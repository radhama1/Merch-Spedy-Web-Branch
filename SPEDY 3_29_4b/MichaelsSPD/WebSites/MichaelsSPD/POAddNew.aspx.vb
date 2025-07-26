
Imports System.Data
Imports System.Data.SqlClient
Imports Data = NovaLibra.Coral.Data.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Imports NovaLibra.Common.Utilities
Imports System.Collections.Generic
Imports WebConstants

Partial Public Class _POAddNew
    Inherits MichaelsBasePage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'alway check that session is still valid
        If Not SecurityCheck() Then
            Response.Redirect("login.aspx")
        End If

        If Not Page.IsPostBack Then
            Initialize()
		End If

    End Sub

    Private Sub Initialize()

        warehouseDirect.Items.Add(New ListItem("Warehouse", "W"))
        warehouseDirect.Items.Add(New ListItem("Direct", "D"))

        srchVendor.Attributes.Add("onchange", "GetVendorDesc();")

    End Sub

    Protected Sub btnGo_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnGo.Click


		Dim rec As New Models.POCreationRecord
		Dim vendor As Models.VendorRecord = (New Data.VendorData).GetVendorRecord(srchVendor.Text)
		If vendor.ID > 0 Then

			'Initialize the PO Record Properties
			rec.POConstructID = Models.POCreationRecord.Construct.Manual
			rec.VendorNumber = vendor.VendorNumber
			rec.VendorName = vendor.VendorName
			rec.BatchType = warehouseDirect.SelectedValue
			rec.POStatusID = 1	'New PO Creations are always in Worksheet status
			rec.Enabled = True
			rec.POStatusID = Models.POCreationRecord.Status.Worksheet
			rec.InitiatorRoleID = Data.POCreationData.GetInitiatorRoleByUserID(Session(cUSERID))
			rec.WorkflowStageID = Data.POCreationData.GetInitialWorkflowStageID(rec.InitiatorRoleID)

			'RULE: Use the Vendor's Payment and Freight Terms by default
			If vendor.PaymentTerms.Length > 0 Then
				rec.PaymentTermsID = Data.PaymentTermsData.GetByTerm(vendor.PaymentTerms).ID
			End If
			If vendor.FreightTerms.Length > 0 Then
				rec.FreightTermsID = vendor.FreightTerms
			End If

			'Save The PO Record in the PO_Creation table
			Data.POCreationData.SaveRecord(rec, Session(cUSERID), NovaLibra.Coral.Data.Michaels.POCreationData.Hydrate.All)

			'Save PO Creation event in Workflow History 
			Data.POCreationData.SaveWorkflowHistory(rec, "CREATED", Session(cUSERID), "")

            'Save initial record for PO Creation in History Stage Durations table
            Data.POCreationData.SaveHistoryStageDuration(rec.ID, "CREATED", 0, rec.WorkflowStageID, Session(cUSERID))

			Response.Redirect("POCreationHeader.aspx?POID=" & rec.ID, False)

			rec = Nothing
		Else
			vendorName.Text = "Invalid Vendor Number."
			vendorName.Style.Item("Color") = "Red"
		End If

	End Sub

End Class

