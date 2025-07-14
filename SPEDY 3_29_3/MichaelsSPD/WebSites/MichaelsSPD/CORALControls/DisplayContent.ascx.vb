Imports CORALPresentation
Imports CORALPresentation.CORALUtility
Imports System.Text
Imports System.Data
Imports System.Data.SqlClient

'*******************************************************************************
'Class: DisplayContent
'Created by: Scott Page
'Created Date: 3/14/2005
'Modifed Date:
'Desc: The display content user control takes in a topic ID and User Id
'and retrieves the topic / content from the database and displays that information
'according to the topic type
'********************************************************************************

Public Class DisplayContent
    Inherits System.Web.UI.UserControl


    Public TopicID As Integer 'ID of the element we are getting
    Public UserID As Integer 'User ID of who is trying to get it (can be 0)
    Public GroupID As Integer 'Group ID of a group that is trying to get it (can be 0)
    Public Template As String 'Template name for a template page as opposed to the content.aspx page

    Protected intTopicType As Integer
    Protected strFileName As String
    Public strTopicName As String 'expose topic name so pages can set title bar of the page
    Public strTopicByLine As String
    Protected strTopicNavName As String
    Protected strTopicSummary As String
    Protected intFileID As Integer
    Protected dblFileSize As Double
    Protected strLinkURL As String
    Protected dteStartDate As Date
    Protected dteEndDate As Date
    Protected intParentID As Integer
    Protected bolDisplayInNav As Boolean
    Protected bolOpenInNewWindow As Boolean
    Protected strChildTopicSummary As String
    Protected intChildTopicSummaryMaxChars As Integer
    Protected bolEnabled As Boolean
    Protected bolAllowFileView As Boolean
    Protected bolAllowFileDownload As Boolean
    Protected bolAllowEmailToFriend As Boolean
    Protected bolAllowPrintableVersion As Boolean
    Protected bolAllowAddToFavorites As Boolean
    Public strDocumentKeywords As String
    Public strDocumentAbstract As String
    Public strCustomHTMLTitle As String
    Protected strFileType As String
    Protected strNavTrail As String

    'Protected WithEvents TopicName As System.Web.UI.WebControls.Label
    'Protected WithEvents TopicByline As System.Web.UI.WebControls.Label
    'Protected WithEvents ContentTable As System.Web.UI.WebControls.Table
    'Protected WithEvents FileIconLink As System.Web.UI.WebControls.HyperLink

    Private dsContent As DataSet

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        'Session("Promotion_State_ID") = 2
        If Not Template = Nothing Then
            GetContentByTemplate()
        Else
            GetContent()
        End If
        DisplayContent()
        strNavTrail = GetNavTrail(0) 'get the navtrail starting at the root
    End Sub

    Private Sub GetContentByTemplate()
        Dim myCORALContent As New CORALContent
        Dim intElementID As Integer

        intElementID = myCORALContent.GetElementIDByTemplate(Template, UserID, GroupID)
        TopicID = intElementID
        GetContent()
    End Sub

    Private Sub GetContent()
        Dim myCORALContent As New CORALContent

        dsContent = myCORALContent.GetContent(TopicID, UserID)
    End Sub

    Private Sub DisplayContent()
        Dim myCORALContent As New CORALContent
        Dim dt As New DataTable
        Dim row As DataRow

        dt = dsContent.Tables(0)
        For Each row In dt.Rows 'there will only be one row for now but we might support multiple content later
            intTopicType = CInt(CORALUtility.FixNull(row("Element_Type"), GetType(Integer)))
            strFileName = CStr(FixNull(row("Type1_FileName"), GetType(String)))
            strTopicName = CStr(FixNull(row("Element_FullTitle"), GetType(String)))
            strTopicByLine = CStr(FixNull(row("Element_FullTitle_SubTitle"), GetType(String)))
            strTopicNavName = CStr(FixNull(row("Element_ShortTitle"), GetType(String)))
            strTopicSummary = vbCrLf & CStr(FixNull(row("Element_Body"), GetType(String)))
            intFileID = CInt(FixNull(row("Type1_FileID"), GetType(Integer)))
            dblFileSize = CDbl(FixNull(row("Type1_FileSize"), GetType(Double)))
            strLinkURL = CStr(FixNull(row("Element_LinkURL"), GetType(String)))
            dteStartDate = CDate(FixNull(row("Start_Date"), GetType(Date)))
            dteEndDate = CDate(FixNull(row("End_Date"), GetType(Date)))
            intParentID = CInt(FixNull(row("Parent_Element_ID"), GetType(Integer)))
            bolDisplayInNav = CBool(FixNull(row("DisplayInNav"), GetType(Boolean)))
            bolOpenInNewWindow = CBool(FixNull(row("OnClick_OpenNewWin"), GetType(Boolean)))
            strChildTopicSummary = CStr(FixNull(row("ChildElements_Summary_IsDisplayed"), GetType(Boolean)))
            intChildTopicSummaryMaxChars = CInt(FixNull(row("ChildElements_Summary_MaxChars"), GetType(Integer)))
            bolEnabled = CBool(FixNull(row("Enabled"), GetType(Boolean)))
            bolAllowFileView = CBool(FixNull(row("Allow_FileView"), GetType(Boolean)))
            bolAllowFileDownload = CBool(FixNull(row("Allow_FileDownload"), GetType(Boolean)))
            bolAllowEmailToFriend = CBool(FixNull(row("Allow_EmailToFriend"), GetType(Boolean)))
            bolAllowPrintableVersion = CBool(FixNull(row("Allow_PrintableVersion"), GetType(Boolean)))
            bolAllowAddToFavorites = CBool(FixNull(row("Allow_AddToFavorites"), GetType(Boolean)))
            strDocumentKeywords = CStr(FixNull(row("Element_Keywords"), GetType(String)))
            strDocumentAbstract = CStr(FixNull(row("Element_Abstract"), GetType(String)))
            strFileType = myCORALContent.getFileType(strFileName)
            strCustomHTMLTitle = CStr(FixNull(row("Element_CustomHTMLTitle"), GetType(String)))

            'TopicName.Text = strTopicName
            'TopicByline.Text = strTopicByLine

            'If intTopicType = 3 Then
            '    FileIconLink.Visible = True
            '    FileIconLink.NavigateUrl = "..\GetFile.aspx?tid=" & TopicID
            '    FileIconLink.ImageUrl = CreateFileIconLink(intTopicType, strFileName)
            'End If
        Next

        If InStr(strTopicSummary, "[Flash]") > 0 Then
            strTopicSummary = Replace(strTopicSummary, vbCrLf, "")
            strTopicSummary = Replace(strTopicSummary, "[Flash]", "<script language=javascript>InsertFlashMovie('")
            strTopicSummary = Replace(strTopicSummary, "[EndFlash]", "');</script>")
        End If

    End Sub
    Private Function CreateFileIconLink(ByVal intTopicType As Integer, ByVal strFileName As String) As String
        Dim myContent As New CORALContent
        Dim strFileIconLink As New StringBuilder
        Dim strIconFileName As String = String.Empty

        Select Case intTopicType
            Case 2
                strIconFileName = "icon_nativedoc_small_on.gif"
            Case 3
                strIconFileName = myContent.getFileIcon(strFileName, 0, 1)
            Case 4
                strIconFileName = "icon_weblink_small_on.gif"
            Case 5
                strIconFileName = "icon_list_small_on.gif"
            Case 6
                strIconFileName = "icon_portal_small_on.gif"
        End Select

        strIconFileName = "../images/app_icons/" & strIconFileName

        Return strIconFileName
    End Function

    Private Function GetNavTrail(ByVal intCurrentTopicID As Integer) As String
        Dim arFamilyList As String()
        Dim dsElements As DataSet
        Dim dt As New DataTable
        Dim row As DataRow
        Dim intElementID As Integer
        Dim strElementTitle As String
        Dim strNavTrail As New StringBuilder

        'Get a list of the parent IDs of the topic ID fo the content we are displaying
        arFamilyList = Split(CORALData.GetElementFamilyList(TopicID, CInt(Session("Promotion_State_ID"))), ",")
        'Get all child elements for the topic passed into this method
        dsElements = CORALData.GetContentByParentElementID(intCurrentTopicID, CInt(Session("Promotion_State_ID")))
        dt = dsElements.Tables(0)
        For Each row In dt.Rows 'loop through each element
            intElementID = CInt(FixNull(row("Element_ID"), GetType(Integer))) 'get the element ID
            strElementTitle = CStr(FixNull(row("Element_ShortTitle"), GetType(String))) 'Get the short title
            If CORALUtility.FindStringInArray(intElementID.ToString, arFamilyList) > 0 Then 'If this is in our family list
                strNavTrail.Append("<a href='content.asp?tid=") 'Create a hyperlink in the string
                strNavTrail.Append(intElementID.ToString)
                strNavTrail.Append("' class='navTrail'>")
                strNavTrail.Append(strElementTitle)
                strNavTrail.Append("</a>")
                If TopicID <> intElementID Then 'If the topic isn't the same as the content there will be children
                    strNavTrail.Append("&nbsp;&gt;&nbsp;") 'append a greater than sign for a link separator
                    strNavTrail.Append(GetNavTrail(intElementID)) 'call this method again with the element ID
                End If
            End If
        Next
        Return strNavTrail.ToString
    End Function
End Class
