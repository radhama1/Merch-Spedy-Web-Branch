Imports System
Imports System.ComponentModel
Imports WebConstants


Partial Class pageheader
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

    Public ReadOnly Property VersionNo() As String
        Get
            Return APP_VERSION
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' Top Portion of pages that required the Menu bar
        ' FJL Nov 2009
        If Not IsPostBack Then
            ' Me.search.Attributes.Add("title", "Version 2.0")

            Dim message As String = Session(cAPPMESSAGE)
            If message IsNot Nothing AndAlso message.Length > 0 Then
                lblSPDAppMessage.Text = message
            End If

            If Session("First_Name") Is Nothing Then
                LabelW.Text = "Welcome! "
            Else
                LabelW.Text = " Welcome " + Session("First_Name").ToString + "! "
            End If
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
