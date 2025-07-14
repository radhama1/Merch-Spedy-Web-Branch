Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks


Partial Class batchexport
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' checking for "guid"
        Dim g As String = Request("guid")
        Dim SQLStr As String = String.Format("select ID, Batch_Type_ID, Is_Valid from [dbo].[SPD_Batch] where GUID = '{0}'", g)
        Dim reader As NLData.DBReader = NLData.DataUtilities.GetDBReader(SQLStr)
        Dim iType As Integer = 0
        If reader.Read() Then
            iType = reader("Batch_Type_ID")
        End If
        reader.Command.Connection.Dispose()
        reader.Dispose()
        reader = Nothing
        If iType > 0 Then
            If iType = 2 Then
                Response.Redirect("importexport.aspx?guid=" & g)
            Else
                Response.Redirect("detailexport.aspx?guid=" & g)
            End If
        Else
            ' show error
        End If
    End Sub
End Class
