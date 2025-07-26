Imports System

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports Data = NovaLibra.Coral.Data.Michaels
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class detaildelete
    Inherits MichaelsBasePage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim batchID As Long
        Dim itemHeaderID As Long = DataHelper.SmartValues(Request("hid"), "long", False)
        Dim itemID As Long = DataHelper.SmartValues(Request("id"), "long", False)
        Dim type As String = DataHelper.SmartValues(Request("t"), "string", False)
        If itemHeaderID <= 0 Then
            Response.Redirect("default.aspx")
        Else
            Dim objM As New Data.ItemDetail()
            Dim itemHeader As Models.ItemHeaderRecord = objM.GetItemHeaderRecord(itemHeaderID)
            objM = Nothing
            If itemHeader Is Nothing Then
                Response.Redirect("default.aspx")
            End If
            batchID = itemHeader.BatchID
            ValidateUser(batchID)
            If Not UserCanDelete() Then
                Response.Redirect("default.aspx")
            End If
            If itemID <= 0 Then
                Response.Redirect("detail.aspx?hid=" & itemHeaderID)
            Else
                Dim userID As Integer = Session("UserID")
                Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                ' delete
                Dim bDeleted As Boolean = objMichaels.DeleteRecord(itemID, userID)
                ' recalc
                ItemHelper.CalculateDomesticDPBatchParent(itemHeader, True, True)
                ' redirect
                objMichaels = Nothing
                Response.Redirect("detailitems.aspx?hid=" & itemHeaderID)
            End If
        End If
    End Sub
End Class
