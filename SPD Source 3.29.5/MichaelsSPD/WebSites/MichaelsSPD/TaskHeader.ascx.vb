Imports System
Imports System.ComponentModel
Imports MichaelsBasePage
Imports WebConstants

Partial Class TaskHeader
    Inherits System.Web.UI.UserControl

    Private _refreshOnUpload As Boolean = False
    Private _sendToDefault As Boolean = False

    Public Property RefreshOnUpload() As Boolean
        Get
            Return _refreshOnUpload
        End Get
        Set(ByVal value As Boolean)
            _refreshOnUpload = value
        End Set
    End Property

    Public Property SendToDefault() As Boolean
        Get
            Return _sendToDefault
        End Get
        Set(ByVal value As Boolean)
            _sendToDefault = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' This control provides the application tabs that are visible on the Spedy Application.  Application are granted to the User via the Admin Tool User Security page

        ' Initialize What tabs can be seen
        If Session(TABSVISBLE) IsNot Nothing Then
            Dim whatTabs As Integer = Convert.ToInt16(Session(TABSVISBLE))
            If (whatTabs And NEWITEM) = 0 Then tabNewItem.Style.Add("display", "none")
            If (whatTabs And ITEMMAINT) = 0 Then tabItemMaint.Style.Add("display", "none")
            If (whatTabs And PONEW) = 0 Then tabPONew.Style.Add("display", "none")
            If (whatTabs And POMAINT) = 0 Then tabPOMaint.Style.Add("display", "none")
            If (whatTabs And TRILINGUALMAINT) = 0 Then tabTrilingualMaint.Style.Add("display", "none")
            If (whatTabs And BULKITEMMAINT) = 0 Then tabBulkItemMaint.Style.Add("display", "none")
        End If

        ' Initialize Active Tab
        If Session(CURRENTTAB) IsNot Nothing Then
            Select Case Session(CURRENTTAB)
                Case NEWITEM
                    tabNewItem.Attributes.Add("class", "current")
                Case ITEMMAINT
                    tabItemMaint.Attributes.Add("class", "current")
                Case PONEW
                    tabPONew.Attributes.Add("class", "current")
                Case POMAINT
                    tabPOMaint.Attributes.Add("class", "current")
                Case TRILINGUALMAINT
                    tabTrilingualMaint.Attributes.Add("class", "current")
                Case BULKITEMMAINT
                    tabBulkItemMaint.Attributes.Add("class", "current")
            End Select
        End If

    End Sub

    <Bindable(True), Category("Layout"), DefaultValue(False)> _
    Public Function GetUploadRefresh() As String
        If RefreshOnUpload Then
            Return "1"
        Else
            Return "0"
        End If
    End Function

    <Bindable(True), Category("Layout"), DefaultValue(False)> _
    Public Function GetUploadSendToDefault() As String
        If SendToDefault Then
            Return "1"
        Else
            Return "0"
        End If
    End Function

End Class
