'*******************************************************************************
'Class: SiteMapControl
'Created by: Scott Page
'Created Date: 3/23/2005
'Modifed Date:
'Desc: Code for the SiteMapControl user control that displays information from the
'CORAL system based on the root ID provided.  Shows all Web Site elements branching
'out from the Root element ID and their nested children up to Max Levels.  In order
'for content to show up DisplayInNav must be True in the configuration for the
'web site element or it will not display here
'********************************************************************************

Imports CORALPresentation
Imports CORALPresentation.CORALUtility
Imports System.Data
Imports System.Data.SqlClient

Public Class SiteMapControl
    Inherits System.Web.UI.UserControl

    Public MaxLevels As Integer 'Maximum number of levels to show
    Public RootID As Integer 'Root ID of the starting element
    Public LinkClass As String 'Class that should be used on the hyperlinks
    Public LinkCellClass As String 'Class that should be used on the table cells holding the site map

    Private arEmptyCol As New ArrayList 'Holds list of ending set IDs



    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        If RootID = 0 Then 'If we are starting at the top of the site put a home link in automatically
            Dim HomeRow As New TableRow
            Dim HomeCell As New TableCell
            Dim HomeLink As New HyperLink

            AddSpacerRow(1, 10) 'Add a space row to the top of our table
            HomeLink.NavigateUrl = "Default.aspx" 'Set the navigation for the home hyperlink
            HomeLink.CssClass = LinkClass 'set the class for the hyperlink
            HomeLink.Text = "Home" 'Set the text for the hyperlink
            HomeCell.ColumnSpan = MaxLevels 'Make the top level cell the width of all our columns
            HomeCell.Controls.Add(HomeLink) 'add the hyperlink to the cell
            HomeCell.CssClass = LinkCellClass 'set the class for the cell
            HomeRow.Cells.Add(HomeCell) 'add the cell to our row
            SiteMapTable.Rows.Add(HomeRow) 'add the row to our table
        End If

        CreateList(RootID, 1) 'Display the List starting at the root ID, the nest level at the start is always 1
    End Sub

    Private Sub CreateList(ByVal intElementID As Integer, ByVal intNestLevel As Integer)
        'This is the main method in the site map creation and it is in charge of getting elements and looping through them.
        'For elements that have children (nested elements) the method calls it self to display the nested elements

        Dim dsElements As New DataSet
        Dim myCORALData As New CORALData
        Dim dt As New DataTable
        Dim row As DataRow
        Dim intChildElementID As Integer
        Dim strChildElementTitle As String
        Dim bolHasChildren As Boolean
        Dim bolDisplayInNav As Boolean
        Dim intCurrentRecord As Integer

        'Get a dataset of all child elements for the parent Element ID
        dsElements = myCORALData.GetContentByParentElementID(intElementID, CInt(Session("Promotion_State_ID")))

        intCurrentRecord = 1 'Set our current record counter to 1

        dt = dsElements.Tables(0)
        For Each row In dt.Rows 'For each of the children elements of our RootID element
            'Get data about the child element
            intChildElementID = CInt(FixNull(row("Element_ID"), GetType(Integer)))
            strChildElementTitle = CStr(FixNull(row("Element_ShortTitle"), GetType(String)))
            bolHasChildren = CBool(FixNull(row("boolHasChildren"), GetType(Boolean)))
            bolDisplayInNav = CBool(FixNull(row("DisplayInNav"), GetType(Boolean)))
            'If this element should be displayed in our navigation
            If bolDisplayInNav = True Then
                'Check to see if this record in our set is the last one in the loop
                If intCurrentRecord = dt.Rows.Count Then
                    arEmptyCol.Add(intNestLevel) 'if so add the current nest level to an array so we know this nest level has ended
                End If

                'Define a new row for our site map and call the method to get the row
                Dim SiteMapRow As New TableRow
                SiteMapRow = DrawRow(intChildElementID, strChildElementTitle, intNestLevel, dt.Rows.Count, intCurrentRecord)
                SiteMapTable.Rows.Add(SiteMapRow) 'Add our row to the site map table

                'If this element has child elements and we are not yet at our max nest level
                If bolHasChildren = True And intNestLevel < MaxLevels Then
                    intNestLevel = intNestLevel + 1 'increment the nest level 
                    CreateList(intChildElementID, intNestLevel) 'call this method again to display the children of the element
                    intNestLevel = intNestLevel - 1 'we are back from displaying the children so decrement the nest level
                End If
            End If
            'If we marked this record in the array because it was the end of this set of records, remove it from the array
            If intCurrentRecord = dt.Rows.Count Then
                arEmptyCol.Remove(intNestLevel)
            End If
            intCurrentRecord = intCurrentRecord + 1 'increment our current record counter
        Next 'go to the next child element
    End Sub

    Private Function DrawRow(ByVal intElementId As Integer, ByVal strElementTitle As String, _
    ByVal intNestLevel As Integer, ByVal intTotalElements As Integer, ByVal intCurrentRecord As Integer) As TableRow
        Dim myRow As New TableRow
        Dim SiteLink As New HyperLink
        Dim LinkCell As New TableCell

        Dim x As Integer

        For x = 1 To intNestLevel 'Loop once for each nest level so we can put in our line graphics
            Dim myCell As New TableCell
            Select Case x
                Case Is < intNestLevel 'If the counter is less than our current nest level we need to add a straight line or nothing
                    If arEmptyCol.Contains(x) Then 'If our array of ending elements contains our nest level we need to display nothing as we are at the end of a list
                        myCell.Text = " &nbsp;"
                    Else 'Otherwise we need to display a straight line to show the continuing line connected to the next major element below
                        myCell.Text = "<img src='./images/sitemap/v_bar_continue_notrelated.gif' border=0 width=20 height=20>"
                    End If
                Case Is = intNestLevel 'If our loop is the same as our nest level we need either a related (branch) graphic or an end branch graphic
                    If intCurrentRecord < intTotalElements Then 'If the current record we are displaying in the set is not equal to the number of elements in this set
                        'Display a related (branch) graphic as there will be another element below this one on the same level
                        myCell.Text = "<img src='./images/sitemap/v_bar_continue.gif' border=0 width=20 height=20>"
                    Else 'otherwise we are at the end of our set so we need an ending branch graphic
                        myCell.Text = "<img src='./images/sitemap/v_bar_end.gif' border=0 width=20 height=20>"
                    End If
            End Select
            myRow.Cells.Add(myCell) 'Add the cell created to our row and loop
        Next
        'setup the link, cell, and formats
        SiteLink.NavigateUrl = "content.aspx?tid=" & intElementId.ToString
        SiteLink.Text = strElementTitle
        SiteLink.CssClass = LinkClass
        LinkCell.ColumnSpan = MaxLevels - intNestLevel 'make our cell containing the link span the remaning table area
        LinkCell.CssClass = LinkCellClass
        LinkCell.Controls.Add(SiteLink) 'Add our link to the holding cell
        myRow.Cells.Add(LinkCell) 'Add the cell to the row

        Return myRow 'return the row
    End Function

    Private Sub AddSpacerRow(ByVal intWidth As Integer, ByVal intHeight As Integer)
        Dim myRow As New TableRow
        Dim myCell As New TableCell
        'Add a spacer row column spanning the width of our site map area with the user set width and height
        myCell.ColumnSpan = MaxLevels
        myCell.Text = "<img src='./images/spacer.gif' border=0 width=" & intWidth.ToString & " height=" & intHeight.ToString & ">"
        myRow.Cells.Add(myCell)
        SiteMapTable.Rows.Add(myRow)
    End Sub
End Class
