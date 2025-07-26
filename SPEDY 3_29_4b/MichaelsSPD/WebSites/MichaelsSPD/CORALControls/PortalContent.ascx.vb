Imports CORALPresentation
Imports CORALPresentation.CORALUtility
Imports System.Data
Imports System.Text

Public Class PortalContent
    Inherits System.Web.UI.UserControl

    Public RootID As Integer
    Public Scope As String
    Public ShowChildren As Boolean
    Public maxNumSubLinks As Integer
    Public ShowEllipses As Boolean
    Public ContainerDivClass As String
    Public ListTitleClass As String
    Public ListBodyClass As String
    Public ListType As String
    Public ListLinksClass As String
    Public ListLinkDelimiter As String
    'Protected WithEvents Portal As System.Web.UI.WebControls.PlaceHolder

    Private dsElements As New DataSet


    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        GetElements()
        DisplayPortalList()
    End Sub

    Private Sub GetElements()
        Dim myCORALData As New CORALData
        'if the scope is local get element data for the current topic only, if it's global then get 
        'all of the child element data
        Select Case Scope
            Case "local"
                dsElements = myCORALData.GetContentByElementID(RootID, CInt(Session("Promotion_State_ID")))
            Case "global"
                dsElements = myCORALData.GetContentByParentElementID(RootID, CInt(Session("Promotion_State_ID")))
        End Select
    End Sub

    Private Sub DisplayPortalList()
        Dim dt As New DataTable
        Dim row As DataRow
        Dim intElementID As Integer
        Dim strElementTitle As String
        Dim bolHasChildren As Boolean

        dt = dsElements.Tables(0)
        For Each row In dt.Rows
            intElementID = CInt(FixNull(row("Element_ID"), GetType(Integer)))
            strElementTitle = CStr(FixNull(row("Element_ShortTitle"), GetType(String)))
            bolHasChildren = CBool(FixNull(row("boolHasChildren"), GetType(Boolean)))

            If (Scope = "local" And bolHasChildren = True) Or Scope <> "local" Then
                Dim MainPanel As New Panel
                Dim TitlePanel As New Panel
                Dim ListPanel As New Panel

                MainPanel.CssClass = ContainerDivClass
                TitlePanel.CssClass = ListTitleClass
                ListPanel.CssClass = ListBodyClass

                Dim TitleLink As New HyperLink
                TitleLink.CssClass = ListTitleClass
                TitleLink.NavigateUrl = "content.asp?tid=" & intElementID.ToString
                TitleLink.Text = strElementTitle
                TitlePanel.Controls.Add(TitleLink)

                Dim myLiteralHTML As New Literal
                myLiteralHTML.Text = DisplaySubItems(intElementID)
                ListPanel.Controls.Add(myLiteralHTML)

                MainPanel.Controls.Add(TitlePanel)
                MainPanel.Controls.Add(ListPanel)
                Portal.Controls.Add(MainPanel)
            End If
        Next
    End Sub

    Private Function DisplaySubItems(ByVal intRootID As Integer) As String
        Dim dsSubElements As New DataSet
        Dim myCORALData As New CORALData
        Dim dt As New DataTable
        Dim row As DataRow
        Dim counter As Integer
        Dim strList As New StringBuilder
        Dim intChildElementID As Integer
        Dim strChildElementTitle As String
        Dim bolHasChildren As Boolean

        'Get all child elements for the Parent Element ID
        dsSubElements = myCORALData.GetContentByParentElementID(intRootID, CInt(Session("Promotion_State_ID")))
        dt = dsSubElements.Tables(0)
        counter = 1
        For Each row In dt.Rows
            If counter > maxNumSubLinks And maxNumSubLinks <> -1 Then
                If ShowEllipses = True Then
                    Select Case ListType
                        Case "bullet", "list"
                            strList.Append("<BR>")
                            strList.Append("<a href='content.aspx?tid=")
                            strList.Append(intRootID.ToString)
                            strList.Append("' Class='")
                            strList.Append(ListLinksClass)
                            strList.Append("'>")
                            strList.Append("More...")
                            strList.Append("</a>")
                        Case "array"
                            If strList.Length > 0 Then strList.Append(ListLinkDelimiter)
                            strList.Append("<BR>")
                            strList.Append("<a href='content.aspx?tid=")
                            strList.Append(intRootID.ToString)
                            strList.Append("' Class='")
                            strList.Append(ListLinksClass)
                            strList.Append("'>")
                            strList.Append("More...")
                            strList.Append("</a>")
                        Case Else
                            strList.Append("<a href='content.aspx?tid=")
                            strList.Append(intRootID.ToString)
                            strList.Append("' Class='")
                            strList.Append(ListLinksClass)
                            strList.Append("'>")
                            strList.Append("...")
                            strList.Append("</a>")
                    End Select
                End If
                Exit For
            End If

            intChildElementID = CInt(FixNull(row("Element_ID"), GetType(Integer)))
            strChildElementTitle = CStr(FixNull(row("Element_ShortTitle"), GetType(String)))
            bolHasChildren = CBool(FixNull(row("boolHasChildren"), GetType(Boolean)))

            Select Case ListType
                Case "bullet"
                    strList.Append("<li>")
                    strList.Append("<a href='content.aspx?tid=")
                    strList.Append(intChildElementID.ToString)
                    strList.Append("' class='")
                    strList.Append(ListLinksClass)
                    strList.Append("'>")
                    strList.Append(strChildElementTitle)
                    strList.Append("</a>")
                Case "list"
                    strList.Append("<li>")
                    strList.Append("<a href='content.aspx?tid=")
                    strList.Append(intChildElementID.ToString)
                    strList.Append("' class='")
                    strList.Append(ListLinksClass)
                    strList.Append("'>")
                    strList.Append(strChildElementTitle)
                    strList.Append("</a>")
                Case "array"
                    If strList.Length > 0 Then strList.Append(ListLinkDelimiter)
                    strList.Append("<li>")
                    strList.Append("<a href='content.aspx?tid=")
                    strList.Append(intChildElementID.ToString)
                    strList.Append("' class='")
                    strList.Append(ListLinksClass)
                    strList.Append("'>")
                    strList.Append(strChildElementTitle)
                    strList.Append("</a>")
                Case Else
                    If strList.Length > 0 Then strList.Append(",")
                    strList.Append("<li>")
                    strList.Append("<a href='content.aspx?tid=")
                    strList.Append(intChildElementID.ToString)
                    strList.Append("' class='")
                    strList.Append(ListLinksClass)
                    strList.Append("'>")
                    strList.Append(strChildElementTitle)
                    strList.Append("</a>")
            End Select
            counter = counter + 1
        Next
        Return strList.ToString
    End Function
End Class
