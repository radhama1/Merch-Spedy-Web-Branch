Imports System

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports Data = NovaLibra.Coral.Data.Michaels
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class IMDetailDelete
    Inherits MichaelsBasePage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim batchID As Long = DataHelper.SmartValues(Request("bid"), "long", False)
        Dim itemID As Integer = DataHelper.SmartValues(Request("id"), "integer", False)
        
        If batchID <= 0 Then
            Response.Redirect("default.aspx")
        Else
            ValidateUser(batchID)
            If Not UserCanDelete Then
                Response.Redirect("default.aspx")
            End If
            If itemID <= 0 Then
                Response.Redirect("IMDetailItems.aspx?hid=" & batchID)
            Else
                Dim userID As Integer = AppHelper.GetUserID()
                Dim objData As New Data.BatchData()
                Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(batchID)
                objData = Nothing
                ' delete
                Dim bDeleted As Boolean = Data.MaintItemMasterData.DeleteItemMaintRecord(batchID, itemID, userID)
                ' recalc
                If batchDetail.IsPack() Then
                    ItemMaintHelper.CalculateDPBatchParent(batchDetail.ID, True, True)
                End If
                ' redirect
                batchDetail = Nothing
                Response.Redirect("IMDetailItems.aspx?hid=" & batchID)
            End If
        End If
    End Sub

End Class
