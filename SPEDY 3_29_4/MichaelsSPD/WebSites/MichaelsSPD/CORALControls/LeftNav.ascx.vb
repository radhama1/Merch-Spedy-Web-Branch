'*******************************************************************************
'Class: LeftNav
'Created by: Scott Page
'Created Date: 3/14/2005
'Modifed Date:
'Desc: LeftNav user control creates the left navigation bar on the page
'********************************************************************************

Imports CORALPresentation
Imports CORALPresentation.CORALUtility
Imports System.Data
Imports System.Data.SqlClient

Public Class LeftNav
    Inherits System.Web.UI.UserControl

    Public IconSelected As String 'The icon to display for selected menu items
    Public IconDefault As String 'The default icon to display for non selected menu items
    Public ClassSelected As String 'Default class to use for selected menu items
    Public ClassDefault As String 'Default class to use for unselected menu items
    Public RootID As Integer 'The ID of the root elements for the site, usually 0
    Public TopicID As Integer 'The topic ID of the topic the user is viewing - sets the navigation levels by this value
    Public RecurseChildren As Boolean 'Set to True if you want the navigation to recurse the children topics in the nav
    Public RecurseLevels As Integer 'Sets how many levels to recurse if Recurse Children is true
    Private dsRootElements As DataSet
    Private arFamilyList() As String
    'Protected WithEvents NavList As System.Web.UI.WebControls.Table


    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        GetFamilyList(TopicID) 'Get the list of related topics to the one we are viewing
        GetRootElements(RootID) 'get all of the root element info for the site
        CreateList() 'display our navigation list
    End Sub

    Private Sub GetFamilyList(ByVal intTopicID As Integer)

        'Get the string of related element ID's and split them by comma into an array
        arFamilyList = Split(CORALData.GetElementFamilyList(intTopicID, CInt(Session("Promotion_State_ID"))), ",")
    End Sub

    Private Sub GetRootElements(ByVal intRootID As Integer)

        'Get data set of child elements given our root ID
        dsRootElements = CORALData.GetContentByParentElementID(intRootID, CInt(Session("Promotion_State_ID")))
    End Sub

    Private Sub CreateList()
        Dim dtElements As New DataTable
        Dim ElementRow As DataRow
        Dim intElementID As Integer
        Dim strElementTitle As String
        Dim bolHasChildren As Boolean
        Dim strNavImage As String
        Dim strNavClass As String
        Dim intNestLevel As Integer

        intNestLevel = 0 'Counter variable used to determine how far down we are in the navigation structure

        dtElements = dsRootElements.Tables(0)
        For Each ElementRow In dtElements.Rows 'loop through all of the returned elements
            intElementID = CInt(ElementRow("Element_ID"))
            strElementTitle = CStr(ElementRow("Element_ShortTitle"))
            bolHasChildren = CBool(ElementRow("boolHasChildren"))


            'If the topic in our set we are currently looking at is the topic the user is viewing
            If TopicID = intElementID Then
                strNavImage = IconSelected 'use the selected icon and class type
                strNavClass = ClassSelected
            Else 'otherwise use the default icon and class type
                strNavImage = IconDefault
                strNavClass = ClassDefault
            End If
            'setup a new row for our table and both cells in that table row
            Dim myElementRow As New TableRow
            Dim myNavImageCell As New TableCell
            Dim myNavLinkCell As New TableCell

            myNavImageCell.VerticalAlign = VerticalAlign.Top 'set the cell to hold the nav icon to top alignment
            'If we are displaing nested content make sure to use the navigation Icon (bullet), otherwise it's 
            'top level so use a space
            If intNestLevel > 1 Then
                myNavImageCell.Text = "<img src='./images/" & strNavImage & "'>"
            Else
                myNavImageCell.Text = "<img src='./images/spacer.gif' width=1 height=1>"
            End If
            myElementRow.Cells.Add(myNavImageCell) 'add the navigation Icon cell to our table row
            'Setup the cell to hold our navigation link
            myNavLinkCell.Width = Unit.Percentage(100)
            myNavLinkCell.VerticalAlign = VerticalAlign.Top
            myNavLinkCell.CssClass = strNavClass
            'create a new hyperlink for our navigation
            Dim myNavLink As New HyperLink
            myNavLink.NavigateUrl = "../content.aspx?tid=" & intElementID.ToString 'set the URL to the content page
            myNavLink.Target = "_top"
            myNavLink.CssClass = strNavClass
            myNavLink.Text = strElementTitle

            myNavLinkCell.Controls.Add(myNavLink) 'add the hyperlink control to our navigation cell
            myElementRow.Cells.Add(myNavLinkCell) 'add the navigation cell to our table
            NavList.Rows.Add(myElementRow) 'add the new row to our table

            AddSpacerRow(NavList, 5) 'include a spacer row with a set height of 5 pixels

            'If the element that we are looking at is in the family for our current topic and we have recursive On
            'then we need to get the child elements and display those as well, provided that we haven't gone further than
            'the number of levels to recurse set by the RecurseLevels attribute
            If CORALUtility.FindStringInArray(intElementID.ToString, arFamilyList) > 0 And RecurseChildren = True _
            And bolHasChildren = True And intNestLevel < RecurseLevels Then
                intNestLevel = intNestLevel + 1 'Since we are going in a level increment our nesting counter
                Dim mySubTable As New Table 'create a new table to hold our sub nav
                mySubTable = GetSubNav(intElementID, intNestLevel) 'Get the sub table
                intNestLevel = intNestLevel - 1 'since we are back out of the sub and not nested decrease our nest level
                'Create a new row and cells to hold our sub navigation, and a new table for the sub navigation
                Dim mySubRow As New TableRow
                Dim mySubNavImageCell As New TableCell 'create both cells in our row
                Dim mySubNavCell As New TableCell

                mySubNavImageCell.Text = "<img src='./images/spacer.gif' width=1 height=1>" 'insert a spacer
                mySubNavImageCell.VerticalAlign = VerticalAlign.Top 'set the alignments
                mySubNavCell.VerticalAlign = VerticalAlign.Top
                mySubNavCell.Controls.Add(mySubTable) 'add the sub table to our navigation cell
                'Add the cells to our sub Row
                mySubRow.Cells.Add(mySubNavImageCell)
                mySubRow.Cells.Add(mySubNavCell)
                'Add the subrow to our table
                NavList.Rows.Add(mySubRow)

                AddSpacerRow(NavList, 6) 'add a spacer row after the sub navigation
            End If
        Next
    End Sub

    Private Function GetSubNav(ByVal intElementID As Integer, ByVal intNestLevel As Integer) As Table
        'Gets the navigation information for each of the root elements and transverses the navigation tree
        'Each level down for the topic that we are viewing, builds the child levels of the navigation
        Dim dsChildElements As New DataSet
        Dim dt As New DataTable
        Dim row As DataRow
        Dim intChildElementID As Integer
        Dim strChildElementTitle As String
        Dim bolHasChildren As Boolean
        Dim strNavImage As String
        Dim strNavClass As String

        'Get all the child elements of our parent
        dsChildElements = CORALData.GetContentByParentElementID(intElementID, CInt(Session("Promotion_State_ID")))
        dt = dsChildElements.Tables(0)

        Dim ChildTable As New Table 'Create a new table for the child listing and set up display properties
        ChildTable.Width = Unit.Percentage(100)
        ChildTable.CellPadding = 0
        ChildTable.CellSpacing = 0
        ChildTable.BorderWidth = Unit.Pixel(0)

        For Each row In dt.Rows 'loop through each child element
            intChildElementID = CInt(row("Element_ID")) 'Get the child element ID
            strChildElementTitle = CStr(row("Element_ShortTitle")) 'Get the child element title
            bolHasChildren = CBool(row("boolHasChildren")) 'See if the child has any children of its own

            Dim myElementRow As New TableRow 'Create a row object to represent the row
            Dim myNavImageCell As New TableCell 'Create a cell to hold the navigation image
            Dim myNavLinkCell As New TableCell 'Create a cell to hold the nav link
            Dim myNavLink As New HyperLink 'create a hyperlink for element

            If TopicID = intChildElementID Then 'If the topic the user chose is the current one we are dipslaying
                strNavImage = IconSelected 'set the icon image and the hyperlink class to the selected type
                strNavClass = ClassSelected
            Else
                strNavImage = IconDefault 'otherwise use the default types
                strNavClass = ClassDefault
            End If

            'Setup the cell that displays the navigation bullet
            myNavImageCell.Text = "<img src='./images/" & strNavImage & "'>"
            myElementRow.Cells.Add(myNavImageCell) 'Add the cell to the Row
            'Setup the cell that displays the navigation link
            myNavLinkCell.Width = Unit.Percentage(100)
            myNavLinkCell.VerticalAlign = VerticalAlign.Top
            myNavLinkCell.CssClass = strNavClass
            'Setup the Navigation Link
            myNavLink.NavigateUrl = "../content.aspx?tid=" & intChildElementID.ToString 'Set the hyperlink URL
            myNavLink.Target = "_top"
            myNavLink.CssClass = strNavClass
            myNavLink.Text = strChildElementTitle 'Sets the actual text of the hyperlink

            myNavLinkCell.Controls.Add(myNavLink) 'add the hyperlink control to it's cell
            myElementRow.Cells.Add(myNavLinkCell) 'Add the cell to the row
            ChildTable.Rows.Add(myElementRow) 'Add the row to the child table

            AddSpacerRow(ChildTable, 6)

            'If the current child element is one of our elements in the family listing, and we are recursing, 
            'and our current nest level is equal or less than our recurse level setting

            If CORALUtility.FindStringInArray(intChildElementID.ToString, arFamilyList) > 0 And RecurseChildren = True _
            And bolHasChildren = True And intNestLevel <= RecurseLevels Then
                intNestLevel = intNestLevel + 1 'we are going in another level so increment our counter
                Dim SubTable As New Table
                SubTable = GetSubNav(intChildElementID, intNestLevel) 'call this method again with the current child
                intNestLevel = intNestLevel - 1 'we are now back out a level so decrement the counter
                'Create a new table row to hold our child table
                Dim mySubRow As New TableRow
                Dim mySubNavImageCell As New TableCell 'create both cells in our row
                Dim mySubNavCell As New TableCell
                mySubNavImageCell.Text = "<img src='./images/spacer.gif' width=1 height=1>" 'insert a spacer
                mySubNavImageCell.VerticalAlign = VerticalAlign.Top 'set the alignments
                mySubNavCell.VerticalAlign = VerticalAlign.Top
                mySubNavCell.Controls.Add(SubTable) 'add the sub table to the second cell
                mySubRow.Cells.Add(mySubNavImageCell) 'Add the cells to the sub row
                mySubRow.Cells.Add(mySubNavCell)
                ChildTable.Rows.Add(mySubRow) 'add the sub row to our child table
            End If
        Next
        Return ChildTable 'return to the child table to the calling function
    End Function

    Private Sub AddSpacerRow(ByVal myTable As Table, ByVal intHeight As Integer)
        'Adds a row that spans both columns in the table and inserts a spacer gif
        Dim mySpaceRow As New TableRow
        Dim mySpaceCell As New TableCell

        mySpaceCell.ColumnSpan = 2
        mySpaceCell.Text = "<img src='./images/spacer.gif' width=1 height=" & intHeight.ToString & ">"
        mySpaceRow.Cells.Add(mySpaceCell)
        myTable.Rows.Add(mySpaceRow)
    End Sub
End Class
