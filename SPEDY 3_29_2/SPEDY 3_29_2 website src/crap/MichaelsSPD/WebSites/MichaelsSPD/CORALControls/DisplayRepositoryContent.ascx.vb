Imports CORALPresentation
Imports CORALPresentation.CORALUtility
Imports System.Text
Imports System.Data
Imports System.Data.SqlClient

'*******************************************************************************
'Class: DisplayRepositoryContent
'Created by: Scott Page
'Created Date: 4/14/2005
'Modifed Date:
'Desc: Displays Repository Content that has not yet been published to the web site
'using the web site tool. 
'********************************************************************************

Public Class DisplayRepositoryContent
    Inherits System.Web.UI.UserControl



    Public TopicID As Integer
    Public UserID As Integer
    Public LanguageID As Integer

    Protected intTopicType As Integer
    Protected strFileName As String
    Public strTopicName As String 'expose topic name so pages can set title bar of the page
    Public strTopicByLine As String
    Protected strTopicSummary As String
    Protected intFileID As Integer
    Protected dblFileSize As Double
    Protected strLinkURL As String
    Protected dteStartDate As Date
    Protected dteEndDate As Date
    Protected bolEnabled As Boolean
    Public strDocumentKeywords As String
    Public strDocumentAbstract As String


    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        GetContent()
    End Sub

    Private Sub GetContent()
        Dim myCORALContent As New CORALContent
        Dim dr As SqlDataReader

        dr = myCORALContent.GetRepositoryContent(TopicID, LanguageID)
        DisplayContent(dr)
    End Sub

    Private Sub DisplayContent(ByVal dr As SqlDataReader)

        If dr.Read Then
            intTopicType = CInt(FixNull(dr("Topic_Type"), GetType(Integer)))
            strFileName = CStr(FixNull(dr("Type1_FileName"), GetType(String)))
            strTopicName = CStr(FixNull(dr("Topic_Name"), GetType(String)))
            strTopicByLine = CStr(FixNull(dr("Topic_ByLine"), GetType(String)))
            strTopicSummary = CStr(FixNull(dr("Topic_Summary"), GetType(String)))
            intFileID = CInt(FixNull(dr("Type1_FileName"), GetType(Integer)))
            dblFileSize = CDbl(FixNull(dr("Type1_FileSize"), GetType(Double)))
            strLinkURL = CStr(FixNull(dr("Type2_LinkURL"), GetType(String)))
            dteStartDate = CDate(FixNull(dr("Start_Date"), GetType(Date)))
            dteEndDate = CDate(FixNull(dr("End_Date"), GetType(Date)))
            bolEnabled = CBool(FixNull(dr("Enabled"), GetType(Boolean)))
            strDocumentKeywords = CStr(FixNull(dr("Topic_Keywords"), GetType(String)))
            strDocumentAbstract = CStr(FixNull(dr("Topic_Abstract"), GetType(String)))
        End If
        dr.Close()

        'If intTopicType = 1 Then
        '    FileIconLink.Visible = True
        '    FileIconLink.NavigateUrl = "..\GetFile.aspx?tid=" & TopicID
        '    FileIconLink.ImageUrl = CreateFileIconLink(intTopicType, strFileName)
        'End If
    End Sub
    Private Function CreateFileIconLink(ByVal intTopicType As Integer, ByVal strFileName As String) As String
        Dim myContent As New CORALContent
        Dim strFileIconLink As New StringBuilder
        Dim strIconFileName As String = String.Empty

        Select Case intTopicType
            Case 0
                strIconFileName = "icon_nativedoc_small_on.gif"
            Case 1
                strIconFileName = myContent.getFileIcon(strFileName, 0, 1)
            Case 3
                strIconFileName = "icon_weblink_small_on.gif"
                'Case 5
                'strIconFileName = "icon_list_small_on.gif"
                'Case 6
                'strIconFileName = "icon_portal_small_on.gif"
        End Select

        strIconFileName = "../images/app_icons/" & strIconFileName

        Return strIconFileName
    End Function
End Class
