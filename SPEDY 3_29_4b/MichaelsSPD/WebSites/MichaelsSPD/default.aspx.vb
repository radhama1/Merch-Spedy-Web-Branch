
Imports System.Data
Imports System.Data.SqlClient
Imports System.Collections.Generic
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels

Imports NovaLibra.Common.Utilities
Imports WebConstants

Partial Public Class _Default
    Inherits MichaelsBasePage

    Public ReadOnly Property VersionNo() As String
        Get
            Return APP_VERSION
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' alway check that session is still valid
        SecurityCheckRedirect()

        ' Get application Message and make sure SPEDY is ONLINE
        Dim MessageList As List(Of Models.ApplicationMessage) = Data.Application.GetApplicationMessages
        Dim AppMessage As New StringBuilder
        Dim OffLineMessage As String = String.Empty

        For Each Message As Models.ApplicationMessage In MessageList
            If Message.IsSpedyOnline = False Then
                OffLineMessage = Message.Message
                Exit For
            End If
            AppMessage.Append(IIf(AppMessage.Length > 0, "</br>", "") & Message.Message)
        Next
        MessageList.Clear()
        MessageList = Nothing

        If OffLineMessage.Length > 0 Then
            lblMessage.Text = OffLineMessage
        Else
            Session(cAPPMESSAGE) = AppMessage.ToString

            ' Check if Tab sessions exist. If so Goto the Active Tab, Else set them up and Goto to default 
            If Session(CURRENTTAB) Is Nothing Then
                Session(TABSVISBLE) = MyBase.GetUserAccessLevel
                If Session(TABSVISBLE) And NEWITEM Then
                    Session(CURRENTTAB) = NEWITEM
                ElseIf Session(TABSVISBLE) And ITEMMAINT Then
                    Session(CURRENTTAB) = ITEMMAINT
                ElseIf Session(TABSVISBLE) And PONEW Then
                    Session(CURRENTTAB) = PONEW
                ElseIf Session(TABSVISBLE) And POMAINT Then
                    Session(CURRENTTAB) = POMAINT
                ElseIf Session(TABSVISBLE) And WebConstants.TRILINGUALMAINT Then
                    Session(CURRENTTAB) = WebConstants.TRILINGUALMAINT
                ElseIf Session(TABSVISBLE) And BULKITEMMAINT Then
                    Session(CURRENTTAB) = BULKITEMMAINT
                End If
            End If

            Select Case Session(CURRENTTAB)
                Case NEWITEM : Response.Redirect(NEWITEM_PAGE)
                Case ITEMMAINT : Response.Redirect(ITEMMAINT_PAGE)
                Case PONEW : Response.Redirect(PONEW_PAGE)
                Case POMAINT : Response.Redirect(POMAINT_PAGE)
                Case WebConstants.TRILINGUALMAINT : Response.Redirect(TRILINGUALMAINT_PAGE)
                Case BULKITEMMAINT : Response.Redirect(BULKITEMMAINT_PAGE)
                Case Else   ' Show this page which displays an error and allows them to log off
            End Select
            lblMessage.Text = "Your list of SPEDY Applications has not been set up. Please contact your Support."

            ' Test only
            'Session("FromVendorConnect") = True

            If Session("FromVendorConnect") = True Then
                windowed.Value = "1"
                btnClose.Text = "Close Window"
                Session.Abandon()
            End If


        End If

    End Sub

    'Protected Sub lnkNewImport_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNewImport.Click

    'End Sub
End Class

