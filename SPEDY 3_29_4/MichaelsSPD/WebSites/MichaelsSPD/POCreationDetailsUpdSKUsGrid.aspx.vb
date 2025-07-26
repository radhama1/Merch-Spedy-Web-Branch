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

Partial Class POCreationDetailsUpdSKUsGrid
	Inherits MichaelsBasePage
	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Select Case Request("Action")
			Case "SaveUPC"
				UpdateUPC(Request.QueryString("POID"), Request.QueryString("SKU"), Request.QueryString("UPC"))
			Case "SaveOrderedQTY"
				UpdateOrderedQTY(Request.Form("POID"), Request.Form("SKU"), Request.Form("Qty"))
			Case "SaveLocationQTY"
				UpdateLocationQTY(Request.Form("POID"), Request.Form("SKU"), Request.Form("Location"), Request.Form("Qty"))
			Case "SaveUnitCost"
				UpdateUnitCost(Request.Form("POID"), Request.Form("SKU"), Request.Form("UnitCost"))
			Case "SaveInnerPack"
				UpdateInnerPack(Request.Form("POID"), Request.Form("SKU"), Request.Form("InnerPack"))
			Case "SaveMasterPack"
				UpdateMasterCase(Request.Form("POID"), Request.Form("SKU"), Request.Form("MasterPack"))
			Case "SaveSKUDefault"
				SaveSKUDefault(Request.Form("POID"), Request.Form("SKU"), Request.Form("Field"))
		End Select
	End Sub
	Private Sub UpdateUPC(ByVal POID As Integer, ByVal SKU As String, ByVal UPC As String)
		If Data.POCreationData.UpdateUPC(POID, SKU, UPC) Then
			Response.Write("1")
		Else
			Response.Write("0")
		End If
	End Sub
	Private Sub UpdateLocationQTY(ByVal POID As Integer, ByVal SKU As String, ByVal location As String, ByVal qty As Integer)
		If Data.POCreationData.UpdateLocationQty(POID, SKU, location, qty) Then
			Response.Write("1")
		Else
			Response.Write("0")
		End If
	End Sub
	Private Sub UpdateOrderedQTY(ByVal POID As Integer, ByVal SKU As String, ByVal qty As Integer)
		If Data.POCreationData.UpdateOrderedQty(POID, SKU, qty) Then
			Response.Write("1")
		Else
			Response.Write("0")
		End If
	End Sub
	Private Sub UpdateUnitCost(ByVal POID As Integer, ByVal SKU As String, ByVal unitCost As Double)
		If Data.POCreationData.UpdateUnitCost(POID, SKU, unitCost) Then
			Response.Write("1")
		Else
			Response.Write("0")
		End If
	End Sub
	Private Sub UpdateInnerPack(ByVal POID As Integer, ByVal SKU As String, ByVal innerPack As Integer)
		If Data.POCreationData.UpdateInnerPack(POID, SKU, innerPack) Then
			Response.Write("1")
		Else
			Response.Write("0")
		End If
	End Sub
	Private Sub UpdateMasterCase(ByVal POID As Integer, ByVal SKU As String, ByVal masterPack As Integer)
		If Data.POCreationData.UpdateMasterPack(POID, SKU, masterPack) Then
			Response.Write("1")
		Else
			Response.Write("0")
		End If
	End Sub
	Private Sub SaveSKUDefault(ByVal poID As Integer, ByVal SKU As String, ByVal field As String)
        If Data.POCreationData.SaveSKUDefault(poID, SKU, field, Session("UserID")) Then
            Response.Write("1")
        Else
            Response.Write("0")
        End If
	End Sub
End Class
