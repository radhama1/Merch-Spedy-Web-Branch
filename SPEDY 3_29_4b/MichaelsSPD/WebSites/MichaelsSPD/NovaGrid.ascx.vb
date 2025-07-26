Imports System
Imports System.Collections
Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Data
Imports System.Data.SqlClient
Imports System.Diagnostics
Imports System.Text
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Xml
Imports System.Xml.XPath

Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.SystemFrameworks

Partial Class NovaGrid
    Inherits System.Web.UI.UserControl

    Public Const GRID_DEFAULT_PAGE_SIZE As Integer = 25

    ' grid items = the collection of objects that define how the grid is going to be build (what columns, format, AJAX edit, etc.).
    Private _gridItems As GridItemCollection = New GridItemCollection()

    ' _gr is used for grid scripts that are generated based on the contents of the grid.
    Private _gr As String = String.Empty

    ' special values hold information for columns that will build custom cell values based on the value of the record property for that row/column.
    Private _specialValues As SpecialValueCollection = New SpecialValueCollection

    Private _checkedSortAndFilter As Boolean = False

    ' list value information that will be used for AJAX edits using custom drop downs.
    Private _lv As String = String.Empty
    Public Sub AddListValue(ByVal lv As String)
        If _lv <> String.Empty Then _lv = _lv & ","
        _lv = _lv & lv
    End Sub
    Private _lvno As String = String.Empty
    Public Sub AddLVNoBlank(ByVal id As Integer)
        _lvno = _lvno & String.Format("addLVNO({0});", id)
    End Sub

    ' Custom Fields
    Private _customFields As NovaLibra.Coral.SystemFrameworks.CustomFields = Nothing

#Region "Page Events"
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the grid control
        _sb = New StringBuilder("")
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            'Response.Write("<!-- TIME: Grid.Load - " & Now().ToString() & "-->")
            If Not Me.Page.IsCallback Then

                If Not Me.ExcelMode Then

                    ' make sure __doPostBack is generated
                    Me.Page.ClientScript.GetPostBackEventReference(Me, String.Empty)

                    ' check for sort and filter changes
                    CheckSortAndFilter()

                    ' set grid id
                    If GridID < 0 Then GridID = 0

                    ' init controls
                    InitGridControls()

                    ' advanced sort & filter
                    SetupAdvancedSortDisplay()
                    SetupAdvancedFilterDisplay()

                    ' ----------
                    ' build grid
                    ' ----------
                    Dim al1 As ArrayList = Nothing
                    Dim al2 As ArrayList = Nothing
                    Dim x As Integer
                    Dim list As IList
                    Dim item As Object

                    ' check
                    Debug.Assert(TypeOf Me.DataSource Is IList)

                    ' fixed grid
                    If GridHasFixedColumns() Then
                        al1 = New ArrayList()
                        al2 = New ArrayList()
                        _sb.Length = 0
                        list = CType(Me.DataSource, IList)
                        If list.Count > 0 Then
                            For x = 0 To list.Count - 1
                                item = list.Item(x)
                                If GridHasFixedColumns() Then
                                    al1.Add(item)
                                End If
                                al2.Add(item)
                                _sb.Append("addGR(" & DataBinder.Eval(item, RecordIDColumn) & ");")
                            Next
                        End If
                        _sb.Append(vbCrLf)
                        _gr = _sb.ToString()

                        FixedGridItemsArray = FixedGridItems

                        FixedGridDetailRowRepeater.DataSource = al1
                        FixedGridDetailRowRepeater.DataBind()

                    Else
                        al2 = New ArrayList
                        _sb.Length = 0
                        list = CType(Me.DataSource, IList)
                        If list.Count > 0 Then
                            For x = 0 To list.Count - 1
                                item = list.Item(x)
                                al2.Add(item)
                                _sb.Append("addGR(" & DataBinder.Eval(item, RecordIDColumn) & ");")
                            Next
                        End If
                        _sb.Append(vbCrLf)
                        _gr = _sb.ToString()
                    End If

                    ' scrollable grid
                    ScrollableGridItemsArray = ScrollableGridItems

                    GridDetailRowRepeater.DataSource = al2
                    GridDetailRowRepeater.DataBind()

                    ' grid scripts
                    CheckForGridStartupScripts()

                    ' clean up
                    If GridHasFixedColumns() Then
                        Do While al1.Count > 0
                            al1.RemoveAt(0)
                        Loop
                        Do While al2.Count > 0
                            al2.RemoveAt(0)
                        Loop
                    End If

                Else
                    ' EXCEL MODE
                    ExcelGridHeaderRepeater.DataSource = GridItems
                    ExcelGridHeaderRepeater.DataBind()
                    ExcelGridDetailRowRepeater.DataSource = Me.DataSource
                    ExcelGridDetailRowRepeater.DataBind()
                End If
            End If
            'Response.Write("<!-- TIME: Grid.Load Complete - " & Now().ToString() & "-->")
        Catch ex As Exception
            Me.OnError(Nothing)
            Logger.LogError(ex)
        End Try
    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        ' clear filter datatable
        _sb = Nothing
        If SavedFilters IsNot Nothing Then
            SavedFilters = Nothing
        End If
        _specialValues = Nothing
    End Sub

#End Region

    Private Sub InitGridControls()
        Dim str As String

        ' init paging/search controls
        If Not IsPostBack Then
            pageList.Attributes.Add("onchange", "javascript:movePage();")
            pageSize.Attributes.Add("onchange", "changePageSize('" & pageSize.ClientID & "');")
            btnClear.Attributes.Add("onclick", "clearSearch('" & txtSearch.ClientID & "');")
        End If

        ' init advanced sort
        If Not Me.ShowAdvancedSort Then
            btnSort.Visible = False
        Else
            If Not IsPostBack Then
                btnSort.Attributes.Add("onclick", "new Lightbox.base('gridAdvancedSort', { externalControl : 'btnCancel' });")
            End If
        End If

        ' init advanced filter
        If Not Me.ShowAdvancedFilter Then
            btnFilter.Visible = False
            btnFilterLabel.Visible = False
        Else
            If Not IsPostBack Then
                btnFilter.Attributes.Add("onclick", "new Lightbox.base('gridAdvancedFilter', { externalControl : 'btnCancelFilter' });")
            End If
            If Not Me.ShowAdvancedSort Then
                btnFilterLabel.Visible = False
            End If
        End If

        ' init excel export links
        If Not Me.ShowExcel Then
            btnExcel.Visible = False
            btnExcelLabel.Visible = False
        Else
            If Not IsPostBack Then
                str = Me.ExcelURL & "; return false;"
                'str += "?whereContains=" & Server.UrlEncode(txtSearch.Text)
                'str += "&gid=" & Server.UrlEncode(Me.ClientID)
                'btnExcel.Attributes.Add("onclick", "javascript:void(window.open('" & str & "',null,'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=400,HEIGHT=300')); return false;")
                btnExcel.Attributes.Add("onclick", str)
            End If
            If Not (Me.ShowAdvancedSort Or Me.ShowAdvancedFilter) Then
                btnExcelLabel.Visible = False
            End If
        End If

        ' init add button
        If Not (Me.ItemAddURL <> "" And UserCanAdd) Then
            btnAdd.Visible = False
            btnAddLabel.Visible = False
        Else
            If Me.ItemAddText <> String.Empty Then btnAdd.Text = Me.ItemAddText
            If Not IsPostBack Then
                Dim url As String = ItemAddURL & CType(IIf(ItemAddURL.IndexOf("?") >= 0, "&id=0", "?id=0"), String)
                btnAdd.Attributes.Add("onclick", "javascript:void(window.open('" & url & "',null,'scrollbars=1,location=0,menubar=0,titlebar=0,toolbar=0,width=1000,HEIGHT=750,resizable=1')); return false;")
            End If
            If Not (Me.ShowAdvancedSort Or Me.ShowAdvancedFilter Or Me.ShowExcel) Then
                btnAddLabel.Visible = False
            End If
        End If

        ' init custom link
        If Me.ItemCustomURL = String.Empty Or Me.ItemCustomText = String.Empty Then
            btnCustom.Visible = False
            btnCustomLabel.Visible = False
        Else
            If Not IsPostBack Then
                btnCustom.Text = Me.ItemCustomText
                Dim customurl As String = ItemCustomURL
                btnCustom.Attributes.Add("onclick", "javascript:void(window.open('" & customurl & "',null,'scrollbars=1,location=0,menubar=0,titlebar=0,toolbar=0,width=1000,HEIGHT=750,resizable=1')); return false;")
            End If
        End If
    End Sub

    Private Sub CheckSortAndFilter()
        If Not _checkedSortAndFilter Then

            _checkedSortAndFilter = True

            If IsPostBack And Not Me.Page.IsCallback Then
                If Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "sortlist" Then
                    ' regular sort
                    Dim str As String = Request.Params("__EVENTARGUMENT")
                    Dim arr As String() = Split(str, ",")
                    If arr.Length >= 2 Then
                        ' clear advanced sort
                        CurrentAdvancedSort = ""
                        ' set sort vars
                        If IsNumeric(arr(0)) Then
                            CurrentSortColumn = Integer.Parse(arr(0))
                        End If
                        If IsNumeric(arr(1)) Then
                            Dim iTmp As Integer = Integer.Parse(arr(1))
                            If iTmp = 0 Or iTmp = 1 Then
                                CurrentSortDirection = iTmp
                            Else
                                CurrentSortDirection = GetGridItem(CurrentSortColumn).DefaultSort
                            End If
                        End If
                    End If
                ElseIf Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "advancedsort" Then
                    ' advanced sort
                    Dim str As String = Request.Params("__EVENTARGUMENT")
                    If str = "1" Then
                        SaveAdvancedSort()
                    End If
                ElseIf Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "advancedfilter" Then
                    ' advanced filter
                    Dim str As String = Request.Params("__EVENTARGUMENT")
                    If str = "1" Then
                        SaveAdvancedFilter()
                    End If
                End If
            End If

        End If ' end if not _checkedSortAndFilter
    End Sub

    Public Sub SaveAdvancedSort()
        ' init vars
        Dim sb As New StringBuilder("")
        Dim seq As DropDownList
        Dim dir As DropDownList
        Dim numSortParamsWrittenSoFar As Integer = 0
        ' setup xml
        sb.Append("<Sort>")
        For i As Integer = 1 To 5
            seq = Me.FindControl("SortSequence" & i)
            dir = Me.FindControl("SortDirection" & i)
            If seq.SelectedValue <> "" And dir.SelectedValue <> "" Then
                numSortParamsWrittenSoFar = numSortParamsWrittenSoFar + 1
                sb.Append("<Parameter SortID=""" & numSortParamsWrittenSoFar & """ intColOrdinal=""" & seq.SelectedValue & """ intDirection=""" & dir.SelectedValue & """ />")
            End If
        Next
        sb.Append("</Sort>")
        ' set advanced sort
        If sb.ToString() = "<Sort></Sort>" Then
            CurrentAdvancedSort = "<Sort />"
        Else
            CurrentAdvancedSort = sb.ToString()
        End If
    End Sub

    Private Sub SetupAdvancedSortDisplay()
        Dim i As Integer
        Dim seq As DropDownList
        Dim dir As DropDownList
        Dim xml As New XmlDocument
        Dim bAdvanced As Boolean = False
        Dim thisSortID As Integer
        Dim thisSortColOrdinal As Integer
        Dim thisSortDirection As Integer
        Dim strXML As String
        If Me.ShowAdvancedSort Then
            strXML = CurrentAdvancedSort
            If strXML <> "" AndAlso strXML <> "<Sort />" AndAlso strXML <> "<Sort></Sort>" Then
                xml.LoadXml(CurrentAdvancedSort)
                bAdvanced = True
                UseAdvancedSort = True
            End If
            For i = 1 To 5
                seq = CType(Me.FindControl("SortSequence" & i), DropDownList)
                dir = CType(Me.FindControl("SortDirection" & i), DropDownList)
                seq.Items.Clear()
                dir.Items.Clear()
                ' setup sequence
                seq.Items.Add(New ListItem("", ""))
                For Each gi As GridItem In GridItems
                    seq.Items.Add(New ListItem(GetListItemText(gi.HeaderText), gi.ID.ToString))
                Next
                ' setup direction
                dir.Items.Add(New ListItem("", ""))
                dir.Items.Add(New ListItem("Ascending", "0"))
                dir.Items.Add(New ListItem("Descending", "1"))
                ' validation
                seq.Attributes("onchange") = "sortValidateSelection(" & i & ");"
                dir.Attributes("onchange") = "sortValidateSelection(" & i & ");"
                ' set initial values
                If bAdvanced Then
                    If xml.SelectNodes("//Parameter[@SortID = """ & i & """]").Count > 0 Then
                        For Each att As XmlAttribute In xml.SelectSingleNode("//Parameter[@SortID = """ & i & """]").Attributes
                            If att.Name = "SortID" Then thisSortID = DataHelper.SmartValues(att.Value, "Integer")
                            If att.Name = "intColOrdinal" Then thisSortColOrdinal = DataHelper.SmartValues(att.Value, "Integer")
                            If att.Name = "intDirection" Then thisSortDirection = DataHelper.SmartValues(att.Value, "Integer")
                        Next
                        If thisSortID = i And thisSortColOrdinal > 0 Then
                            If thisSortDirection <> 0 AndAlso thisSortDirection <> 1 Then
                                thisSortDirection = 0
                            End If
                            ' save to controls
                            Dim itemFound As ListItem = seq.Items.FindByValue(thisSortColOrdinal)
                            If (itemFound IsNot Nothing) Then
                                seq.SelectedValue = thisSortColOrdinal
                                dir.SelectedValue = thisSortDirection
                            End If
                            ' save to grid items
                            Dim gi As GridItem = GetGridItem(thisSortColOrdinal)
                            If Not gi Is Nothing Then
                                gi.AdvancedSortColOrdinal = thisSortID
                                gi.AdvancedSortDirection = thisSortDirection
                            End If
                        End If
                    End If
                End If
            Next
            xml = Nothing
        End If

    End Sub

    Public Sub SaveAdvancedFilter()
        Dim xmlSearch As String, numFilterParamsWrittenSoFar As Integer, i As Integer
        Dim Previous_Filter_Name As String
        Dim Previous_Filter_XML As String

        Dim columnName As String
        Dim filterValue As String
        Dim filterConjunction As String
        Dim filterVerb As String
        Dim filterVerbID As Integer
        Dim gi As GridItem

        Previous_Filter_Name = CurrentAdvancedFilterName
        Previous_Filter_XML = CurrentAdvancedFilter

        'Dim ActivityLog, ActivityType, ActivityReferenceType
        'ActivityLog = New cls_ActivityLog
        'ActivityType = New cls_ActivityType
        'ActivityLog.Activity_Type = ActivityType.Modify_ID
        'ActivityLog.Reference_ID = 0

        numFilterParamsWrittenSoFar = 0

        If Request.Form.Count > 0 Then

            If Request.Form("chkAction") = "0" Or Request.Form("chkAction") = "1" Then

                xmlSearch = "<Filter>"

                For i = 1 To 10
                    columnName = DataHelper.SmartValues(Request.Form(i & "_Filter_Column"), "string")
                    If columnName <> "" Then
                        filterVerb = Request.Form(i & "_Filter_Verb")
                        filterConjunction = Request.Form(i & "_Filter_Conjunction")
                        gi = GetGridItem(columnName)
                        If Not gi Is Nothing Then
                            Select Case gi.FieldType.ToLower()
                                Case "number", "decimal", "integer"
                                    filterValue = Request.Form(i & "_Filter_Value_Number")
                                    Select Case filterVerb
                                        Case "equals"
                                            filterVerbID = 1
                                        Case "does not equal"
                                            filterVerbID = 2
                                        Case "is greater than"
                                            filterVerbID = 3
                                        Case "is greater than or equal to"
                                            filterVerbID = 4
                                        Case "is less than"
                                            filterVerbID = 5
                                        Case "is less than or equal to"
                                            filterVerbID = 6
                                        Case "is in range"
                                            filterVerbID = 7
                                        Case "is not in range"
                                            filterVerbID = 8
                                        Case "is unknown"
                                            filterVerbID = 9
                                        Case Else
                                            filterVerbID = 9
                                    End Select
                                Case "date"
                                    filterValue = Request.Form(i & "_Filter_Value_Date")
                                    Select Case filterVerb
                                        Case "on"
                                            filterVerbID = 1
                                        Case "on or after"
                                            filterVerbID = 2
                                        Case "on or before"
                                            filterVerbID = 3
                                        Case Else
                                            filterVerbID = 3
                                    End Select
                                Case Else
                                    ' "string" or <unspecified> (DEFAULT)
                                    filterValue = Request.Form(i & "_Filter_Value_String")
                                    Select Case filterVerb
                                        Case "is exactly"
                                            filterVerbID = 1
                                        Case "contains"
                                            filterVerbID = 2
                                        Case "sounds like"
                                            filterVerbID = 3
                                        Case "is unknown"
                                            filterVerbID = 4
                                        Case Else
                                            filterVerbID = 4
                                    End Select
                            End Select
                            numFilterParamsWrittenSoFar += 1
                            AppendFilterParameter(xmlSearch, numFilterParamsWrittenSoFar, gi.ID, filterValue, filterConjunction, gi.FieldName, filterVerb, filterVerbID)
                        End If
                    End If
                Next

                xmlSearch = xmlSearch & "</Filter>"
                If xmlSearch = "<Filter></Filter>" Then
                    xmlSearch = "<Filter />"
                    CurrentAdvancedFilterName = ""
                End If

                'If Request.Form("chkAction") = "0" Then
                '    If xmlSearch = "<Filter />" Then
                '        ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " cleared the ad hoc filter from the tactical grid view."
                '    Else
                '        ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " applied an ad hoc filter to the tactical grid view."
                '    End If
                'ElseIf Request.Form("chkAction") = "1" Then
                '    ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " applied saved filter """ & GetFilterName(Request.Form("Select_EditSavedFilter")) & """ to the tactical grid view."
                'End If
                'ActivityLog.Save()

                CurrentAdvancedFilter = xmlSearch
                Session("searchString") = ""
                'ElseIf Request.Form("chkAction") = 2 Then
                '    ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " removed saved filter """ & GetFilterName(Request.Form("Select_EditSavedFilter")) & """."
                '    ActivityLog.Save()
            End If

            Select Case Request.Form("chkAction")

                Case "0"    'New
                    CurrentAdvancedFilterID = 0
                    CurrentAdvancedFilterName = ""
                    If Request.Form("chkSaveAs") = "1" Then
                        PersistNewFilterData()
                        If Request.Form("Select_SendTo") = "" Or DataHelper.CheckQueryID(Session("UserID"), 0) = DataHelper.CheckQueryID(Request.Form("Select_SendTo"), 0) Then
                            GetMostRecentFilterInformation()
                        End If
                    End If

                Case "1"    'Edit Selected
                    Me.CurrentAdvancedFilterID = Request.Form("Select_EditSavedFilter")
                    Me.CurrentAdvancedFilterName = GetFilterName(Request.Form("Select_EditSavedFilter"))
                    'EditFilterData(Request.Form("Select_EditSavedFilter"), Previous_Filter_XML)
                    LoadSavedFilter(Me.CurrentAdvancedFilterID)
                    If Request.Form("chkSaveAs") = "1" Then PersistNewFilterData()

                Case "2"    'Delete Selected
                    If Request.Form("Select_RemoveSavedFilter") = Me.CurrentAdvancedFilterID Then
                        Me.CurrentAdvancedFilterID = 0
                        Me.CurrentAdvancedFilterName = ""
                        Me.CurrentAdvancedFilter = ""
                    End If
                    DeleteFilterData(Request.Form("Select_RemoveSavedFilter"))
                    If Request.Form("chkSaveAs") = "1" Then PersistNewFilterData()

            End Select
        End If
    End Sub

    Private Sub SetupAdvancedFilterDisplay()
        ' saved filters
        Dim sql As String = "SELECT * FROM SavedFilter WHERE User_ID = @userID AND Grid_ID = @gridID ORDER BY Filter_Name"
        Dim objDT As DBDataTable
        Dim cmd As DBCommand
        Try
            objDT = New DBDataTable(ApplicationHelper.GetAppConnection(), sql, CommandType.Text)
            cmd = objDT.SelectCommand
            cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = DataHelper.SmartValues(Session("UserID"), "long", False)
            cmd.Parameters.Add("@gridID", SqlDbType.Int).Value = Me.GridID
            objDT.Open()
            SavedFilters = objDT
        Catch sqlex As SqlException
            'Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            'Logger.LogError(ex)
            Throw ex
        Finally

        End Try
    End Sub

    Private Function GetListItemText(ByVal headerText As String) As String
        Dim iPos As Integer, iPos2 As Integer
        iPos = headerText.IndexOf("<")
        If iPos >= 0 Then
            iPos2 = headerText.IndexOf(">", iPos)
        End If
        Do While iPos >= 0 And iPos2 > iPos
            If iPos > 0 Then
                headerText = headerText.Substring(0, iPos) & " " & headerText.Substring(iPos2 + 1)
            Else
                headerText = headerText.Substring(iPos2 + 1)
            End If
            iPos = headerText.IndexOf("<")
            If iPos >= 0 Then
                iPos2 = headerText.IndexOf(">", iPos)
            End If
        Loop
        Return headerText
    End Function


#Region "Scripts"

    Public Sub LockCell(ByVal rowID As Long, ByVal colID As Integer)
        AddScripts("addLC(" & rowID.ToString() & ", " & colID.ToString() & ");")
    End Sub

    Public Sub DisableDelete(ByVal itemID As Integer)
        AddScripts("AddRowPermissions(" & itemID.ToString() & ", '1', '0', '1');")
    End Sub

    Private _scripts As String = String.Empty
    Public Sub AddScripts(ByVal value As String)
        _scripts += value ' & vbCrLf
    End Sub

    Private Sub CheckForGridStartupScripts()
        Dim startupScriptKey As String = "__NovaGrid_" & Me.ClientID
        If Not Me.Page.ClientScript.IsStartupScriptRegistered(startupScriptKey) Then
            CreateGridStartupScripts(startupScriptKey)
        End If
    End Sub

    Private Sub CreateGridStartupScripts(ByVal startupScriptKey As String)
        Dim gi As GridItem
        _sb.Length = 0
        _sb.Append("" & vbCrLf)
        _sb.Append("<script language=""javascript"" src=""./novagrid/lockscroll_novagrid.js""></script>" & vbCrLf)
        _sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        _sb.Append("<!--" & vbCrLf)

        ' properties
        _sb.Append("gridClientID = '" & Me.ClientID & "';" & vbCrLf)
        _sb.Append("gridClientIDSep = '" & Me.ClientIDSeparator & "';" & vbCrLf)
        _sb.Append("gridPrefix = '" & Me.ClientID & Me.ClientIDSeparator & "';" & vbCrLf)
        If Me.AutoResizeGrid Then
            _sb.Append("resizeGridOnResize = true;" & vbCrLf)
        End If
        If Me.ShowGridLines Then
            _sb.Append("showGridLines = true;" & vbCrLf)
        End If
        If Me.ShowPaging Then
            _sb.Append("showGridPaging = true;" & vbCrLf)
        End If
        If Me.HighlightRow Then
            _sb.Append("showHighlightRow = true;" & vbCrLf)
        End If
        _sb.Append("gridFilterXML = '" & Me.CurrentAdvancedFilter.Replace("'", "''") & "';" & vbCrLf)
        _sb.Append("savedFilterObj = new SavedFilter(gridFilterXML);" & vbCrLf)
        _sb.Append("loadInterfaceFromSavedFilter(savedFilterObj);" & vbCrLf)

        _sb.Append(_gr)
        If Me.AllowAjaxEdit Then
            _sb.Append("gi[0]='';")
            For Each gi In GridItems
                _sb.Append("gi[" & gi.ID & "]='" & gi.FieldName.Replace("'", "\'") & "';")
                If gi.AllowAjaxEdit Then
                    _sb.Append("addGC(" & gi.ID & ");")
                End If
            Next
            _sb.Append(vbCrLf)
        End If

        ' sort
        _sb.Append("sortSequence[0] = '" & SortSequence1.ClientID & "';" & vbCrLf)
        _sb.Append("sortSequence[1] = '" & SortSequence2.ClientID & "';" & vbCrLf)
        _sb.Append("sortSequence[2] = '" & SortSequence3.ClientID & "';" & vbCrLf)
        _sb.Append("sortSequence[3] = '" & SortSequence4.ClientID & "';" & vbCrLf)
        _sb.Append("sortSequence[4] = '" & SortSequence5.ClientID & "';" & vbCrLf)
        _sb.Append("sortDirection[0] = '" & SortDirection1.ClientID & "';" & vbCrLf)
        _sb.Append("sortDirection[1] = '" & SortDirection2.ClientID & "';" & vbCrLf)
        _sb.Append("sortDirection[2] = '" & SortDirection3.ClientID & "';" & vbCrLf)
        _sb.Append("sortDirection[3] = '" & SortDirection4.ClientID & "';" & vbCrLf)
        _sb.Append("sortDirection[4] = '" & SortDirection5.ClientID & "';" & vbCrLf)

        ' item view/add/edit/delete
        _sb.Append("itemEditURL = '" & Me.ItemEditURL & "';" & vbCrLf)
        _sb.Append("itemViewURL = '" & Me.ItemViewURL & "';" & vbCrLf)
        _sb.Append("itemDeleteURL = '" & Me.ItemDeleteURL & "';" & vbCrLf)
        _sb.Append("itemAddURL = '" & Me.ItemAddURL & "';" & vbCrLf)
        _sb.Append("itemCustomURL = '" & Me.CustomLink & "';" & vbCrLf)
        _sb.Append("itemCustomWidth = '" & Me.CustomLinkWidth & "';" & vbCrLf)
        _sb.Append("itemCustomHeight = '" & Me.CustomLinkHeight & "';" & vbCrLf)

        ' display scripts
        If Me.GridHasFixedColumns() Then
            _sb.Append("resizeFixedGrid = true;" & vbCrLf)
            _sb.Append("initFixedGridDataLayout(" & CType(Me.FixedGridItemsArray.Item(0), GridItem).ID & ", " & GetMaxGridItemID(Me.FixedGridItemsArray) & ");" & vbCrLf)
        End If

        _sb.Append("resizeGrid();" & vbCrLf)
        Dim al As ArrayList = Me.ScrollableGridItemsArray
        If al.Count > 0 Then
            _sb.Append("gridSC = " & CType(al.Item(0), GridItem).ID & vbCrLf)
            _sb.Append("gridEC = " & CType(al.Item(al.Count - 1), GridItem).ID & vbCrLf)
            _sb.Append("initGridDataLayout(" & CType(al.Item(0), GridItem).ID & ", " & CType(al.Item(al.Count - 1), GridItem).ID & ");" & vbCrLf)
        End If
        _sb.Append("showGrid();" & vbCrLf)
        _sb.Append("initPlaceLayers();" & vbCrLf)
        _sb.Append("resizeGrid();" & vbCrLf)

        ' list values
        For Each gi In GridItems
            If gi.FieldFormat = "listvalue" AndAlso gi.FieldFormatString <> String.Empty Then
                AddListValue(gi.FieldFormatString)
            End If
            If gi.NoBlankListValue Then
                AddLVNoBlank(gi.ID)
            End If
        Next
        If _lv <> String.Empty Then
            Dim lvgs As ListValueGroups = FormHelper.LoadListValues(_lv)
            Dim lvg As ListValueGroup
            Dim index As Integer = 0
            For i As Integer = 0 To lvgs.RecordCount - 1
                lvg = lvgs.Item(i)
                '_sb.Append("gridLV[" & index & "]" & " = new Array('" & lvg.Name & "', '', '');" & vbCrLf)
                'index += 1
                For Each lv As ListValue In lvg.ListValues
                    _sb.Append("gridLV[" & index & "]" & " = new Array('" & lvg.Name & "', '" & lv.Value & "', '" & FormHelper.GetListValueDisplayText(lv.Value, lv.DisplayText, 30).Replace("'", "\'") & "');" & vbCrLf)
                    index += 1
                Next
            Next
        End If
        If _lvno <> String.Empty Then
            _sb.Append(_lvno & vbCrLf)
        End If

        If Me.ShowChanges Then
            _sb.Append("setShowChanges(true);" & vbCrLf)
        End If

        ' custom scripts
        If _scripts <> String.Empty Then
            _sb.Append(_scripts & vbCrLf)
        End If

        _sb.Append("//-->" & vbCrLf)
        _sb.Append("</script>" & vbCrLf)
        Me.Page.ClientScript.RegisterStartupScript(Me.GetType(), startupScriptKey, _sb.ToString())
    End Sub
#End Region


    Private Function GetMaxGridItemID(ByVal arrlist As ArrayList) As Integer
        Dim item As GridItem
        Dim returnID As Integer = 0
        For i As Integer = 0 To arrlist.Count - 1
            item = CType(arrlist.Item(i), GridItem)
            If item.ID > returnID Then
                returnID = item.ID
            End If
        Next
        Return returnID
    End Function

    Private Sub SetupPaging()
        Dim i As Integer
        ' set default row vars
        Dim firstRow As Integer = 1
        Dim lastrow As Integer = DefaultPageSize
        Dim cookieName As String = "itemspagesize"
        ' paging size
        Dim pagingSize As Integer
        If (IsNumeric(pageSize.Text) AndAlso pageSize.Text.Trim() <> "0") Then
            pagingSize = Integer.Parse(pageSize.Text)
        ElseIf PagingCookie AndAlso (Not Request.Cookies(cookieName) Is Nothing) Then
            pagingSize = DataHelper.SmartValues(Request.Cookies(cookieName).Value, "integer", False)
        Else
            pagingSize = DefaultPageSize
        End If
        If pagingSize <= 0 Then pagingSize = DefaultPageSize
        If PagingCookie Then
            If Response.Cookies.Item(cookieName) Is Nothing Then
                Response.Cookies.Add(New HttpCookie(cookieName, pagingSize.ToString()))
            Else
                Response.Cookies(cookieName).Value = pagingSize.ToString()
            End If
        End If

        ' pages
        Dim pages As Integer = RecordCount / pagingSize
        If (pages * pagingSize) < RecordCount Then
            pages = pages + 1
        End If
        PageCount = pages
        ' get current page (if set)
        If pageList.Items.Count > 0 Then
            If (Integer.Parse(pageList.SelectedValue) <= pages) Then
                CurrentPage = Integer.Parse(pageList.SelectedValue)
            Else
                CurrentPage = 1
            End If
        Else
            CurrentPage = 1
        End If
        ' attempt to move current page?? (only on postback with paging)
        If IsPostBack Then
            If Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "paging" Then
                Dim arg As String = Request.Params("__EVENTARGUMENT")
                Select Case arg
                    Case "move"
                        ' already captured this via pageList.SelectedValue, SO DO NOTHING !!
                    Case "first"
                        CurrentPage = 1
                    Case "prev"
                        If CurrentPage > 1 Then
                            CurrentPage -= 1
                        End If
                    Case "next"
                        If (CurrentPage + 1) <= pages Then
                            CurrentPage += 1
                        End If
                    Case "last"
                        CurrentPage = pages
                End Select
            End If
        End If
        If ((CurrentPage * pagingSize) - pagingSize + 1) < RecordCount Then
            firstRow = ((CurrentPage * pagingSize) - pagingSize + 1)
            lastrow = (CurrentPage * pagingSize)
        End If

        _firstRow = firstRow
        _lastRow = lastrow

        ' init paging controls
        pageList.Items.Clear()
        For i = 1 To pages
            pageList.Items.Add(New ListItem(i.ToString(), i))
        Next

        pageCountLabel.Text = pages.ToString()
        If pages <= 0 Then
            pageList.Items.Clear()
            pageList.Items.Add(New ListItem("0", "0"))
        Else
            If pageList.Items.Count > 0 AndAlso Not pageList.Items.FindByValue(CurrentPage.ToString()) Is Nothing Then
                pageList.SelectedValue = CurrentPage.ToString()
            End If
        End If
        pageSize.Text = pagingSize

    End Sub

    Public Sub SetExcelURL(ByVal url As String)
        Me.ExcelURL = url
    End Sub

#Region "Grid Styles"
    Private _gridClass As String = "gS"
    Private _gridClassRow As String = "gR"
    Private _gridClassAltRow As String = "gAR"
    Private _gridClassHeaderCol As String = "gHC"
    Private _gridClassHeaderColImg As String = "gHCI"
    Private _gridClassCol As String = "gC"
    Private _gridClassColCC As String = "gCC"

    Public Property GridClass() As String
        Get
            Return _gridClass
        End Get
        Set(ByVal value As String)
            _gridClass = value
        End Set
    End Property

    Public Property GridClassRow() As String
        Get
            Return _gridClassRow
        End Get
        Set(ByVal value As String)
            _gridClassRow = value
        End Set
    End Property

    Public Property GridClassAltRow() As Object
        Get
            Return _gridClassAltRow
        End Get
        Set(ByVal value As Object)
            _gridClassAltRow = value
        End Set
    End Property

    Public Property GridClassHeaderCol() As String
        Get
            Return _gridClassHeaderCol
        End Get
        Set(ByVal value As String)
            _gridClassHeaderCol = value
        End Set
    End Property

    Public Property GridClassHeaderColImg() As String
        Get
            Return _gridClassHeaderColImg
        End Get
        Set(ByVal value As String)
            _gridClassHeaderColImg = value
        End Set
    End Property

    Public Property GridClassCol() As String
        Get
            Return _gridClassCol
        End Get
        Set(ByVal value As String)
            _gridClassCol = value
        End Set
    End Property

    Public Property GridClassColChanges() As String
        Get
            Return _gridClassColCC
        End Get
        Set(ByVal value As String)
            _gridClassColCC = value
        End Set
    End Property

    Public Function GetHeaderImageClass(ByVal id As Object) As String
        Dim str As String = GridClassHeaderCol
        Dim item As GridItem = GetGridItem(CType(id, Integer))
        If Not item Is Nothing AndAlso item.SortColumn Then
            If GridClassHeaderColImg <> "" Then
                str += " " & GridClassHeaderColImg
            End If
        End If
        Return str
    End Function
#End Region

#Region "Grid Properties"

    ' DATASOURCE
    Private _dataSource As Object
    Public Property DataSource() As Object
        Get
            Return _dataSource
        End Get
        Set(ByVal value As Object)
            _dataSource = value
        End Set
    End Property

    ' FIELD NAME REMOVE
    Private _fieldNameUnderscore As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property FieldNameUnderscore() As Boolean
        Get
            Return _fieldNameUnderscore
        End Get
        Set(ByVal value As Boolean)
            _fieldNameUnderscore = value
        End Set
    End Property

    ' HIGHLIGHT ROW
    Private _highlightRow As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property HighlightRow() As Boolean
        Get
            Return _highlightRow
        End Get
        Set(ByVal value As Boolean)
            _highlightRow = value
        End Set
    End Property

    ' DEFAULT PAGE SIZE
    Private _defaultPageSize As Integer = GRID_DEFAULT_PAGE_SIZE
    <Bindable(True), Category("Grid"), DefaultValue(50)> _
    Public Property DefaultPageSize() As Integer
        Get
            Return _defaultPageSize
        End Get
        Set(ByVal value As Integer)
            _defaultPageSize = value
        End Set
    End Property

    ' SHOW SEARCH
    Private _showSearch As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property ShowSearch() As Boolean
        Get
            Return _showSearch
        End Get
        Set(ByVal value As Boolean)
            _showSearch = value
        End Set
    End Property

    <Bindable(False)> _
    Public Property SearchText() As String
        Get
            Return txtSearch.Text
        End Get
        Set(ByVal value As String)
            If value.Length > 50 Then
                txtSearch.Text = Mid(value, 1, 50)
            Else
                txtSearch.Text = value
            End If
        End Set
    End Property

    Private _showGridLines As Boolean = True
    <Bindable(True), Category("Grid"), DefaultValue(True)> _
    Public Property ShowGridLines() As Boolean
        Get
            Return _showGridLines
        End Get
        Set(ByVal value As Boolean)
            _showGridLines = value
        End Set
    End Property

    Private _autoResizeGrid As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property AutoResizeGrid() As Boolean
        Get
            Return _autoResizeGrid
        End Get
        Set(ByVal value As Boolean)
            _autoResizeGrid = value
        End Set
    End Property

    Private _showAdvancedSort As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property ShowAdvancedSort() As Boolean
        Get
            Return _showAdvancedSort
        End Get
        Set(ByVal value As Boolean)
            _showAdvancedSort = value
        End Set
    End Property

    Private _showAdvancedFilter As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property ShowAdvancedFilter() As Boolean
        Get
            Return _showAdvancedFilter
        End Get
        Set(ByVal value As Boolean)
            _showAdvancedFilter = value
        End Set
    End Property

    Private _showExcel As Boolean = False
    <Bindable(False)> _
    Public ReadOnly Property ShowExcel() As Boolean
        Get
            Return _showExcel
        End Get
    End Property

    Private _excelURL As String = String.Empty
    <Bindable(True), Category("Grid"), DefaultValue("")> _
    Public Property ExcelURL() As String
        Get
            Return _excelURL
        End Get
        Set(ByVal value As String)
            _excelURL = value
            If (Trim(_excelURL) <> String.Empty) Then
                _showExcel = True
            Else
                _showExcel = False
            End If
        End Set
    End Property

    ' SHOW EXCEL MODE (TABLE ONLY)
    Private _excelMode As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property ExcelMode() As Boolean
        Get
            Return _excelMode
        End Get
        Set(ByVal value As Boolean)
            _excelMode = value
        End Set
    End Property

    ' CONTEXT MENU
    Private _showContentMenu As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property ShowContentMenu() As Boolean
        Get
            Return _showContentMenu
        End Get
        Set(ByVal value As Boolean)
            _showContentMenu = value
        End Set
    End Property

    ' AJAX EDIT
    Private _allowAjaxEdit As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property AllowAjaxEdit() As Boolean
        Get
            Return _allowAjaxEdit
        End Get
        Set(ByVal value As Boolean)
            _allowAjaxEdit = value
        End Set
    End Property

    ' SET ALL FIELDS
    Private _allowSetAll As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property AllowSetAll() As Boolean
        Get
            Return _allowSetAll
        End Get
        Set(ByVal value As Boolean)
            _allowSetAll = value
        End Set
    End Property

    ' RECORD ID COLUMN
    Private _recordIDColumn As String = "ID"
    <Bindable(True), Category("Grid"), DefaultValue("ID")> _
    Public Property RecordIDColumn() As String
        Get
            Return _recordIDColumn
        End Get
        Set(ByVal value As String)
            _recordIDColumn = value
        End Set
    End Property

    ' IMAGE PATH
    Private _imagePath As String = "images/grid/"
    <Bindable(True), Category("Grid"), DefaultValue("images/grid/")> _
    Public Property ImagePath() As String
        Get
            Return _imagePath
        End Get
        Set(ByVal value As String)
            _imagePath = value
        End Set
    End Property

    ' SECURITY
    Private _userCanAdd As Boolean = False
    Private _userCanEdit As Boolean = False
    Private _userCanView As Boolean = False
    Public Property UserCanAdd() As Boolean
        Get
            Return _userCanAdd
        End Get
        Set(ByVal value As Boolean)
            _userCanAdd = value
        End Set
    End Property
    Public Property UserCanEdit() As Boolean
        Get
            Return _userCanEdit
        End Get
        Set(ByVal value As Boolean)
            _userCanEdit = value
        End Set
    End Property
    Public Property UserCanView() As Boolean
        Get
            Return _userCanView
        End Get
        Set(ByVal value As Boolean)
            _userCanView = value
        End Set
    End Property

    ' CUSTOM LINK
    Private _customLink As String = String.Empty
    Private _customLinkText As String = String.Empty
    Private _customLinkWidth As String = String.Empty
    Private _customLinkHeight As String = String.Empty
    Public Property CustomLink() As String
        Get
            Return _customLink
        End Get
        Set(ByVal value As String)
            _customLink = value
        End Set
    End Property
    Public Property CustomLinkText() As String
        Get
            Return _customLinkText
        End Get
        Set(ByVal value As String)
            _customLinkText = value
        End Set
    End Property
    Public Property CustomLinkWidth() As String
        Get
            Return _customLinkWidth
        End Get
        Set(ByVal value As String)
            _customLinkWidth = value
        End Set
    End Property
    Public Property CustomLinkHeight() As String
        Get
            Return _customLinkHeight
        End Get
        Set(ByVal value As String)
            _customLinkHeight = value
        End Set
    End Property

#End Region

#Region "Change Controls"

    ' DATASOURCE FOR CHANGE CONTROLS
    Private _changesDataSource As Object = Nothing
    Public Property ChangesDataSource() As Object
        Get
            Return _changesDataSource
        End Get
        Set(ByVal value As Object)
            _changesDataSource = value
        End Set
    End Property

    ' SHOW CHANGE CONTROLS
    Private _showChanges As Boolean = False
    <Bindable(True), Category("Grid"), DefaultValue(False)> _
    Public Property ShowChanges() As Boolean
        Get
            Return _showChanges
        End Get
        Set(ByVal value As Boolean)
            _showChanges = value
        End Set
    End Property

    ' CHANGES ID COLUMN
    'Private _changesIDColumn As String = "ID"
    '<Bindable(True), Category("Grid"), DefaultValue("ID")> _
    'Public Property ChangesIDColumn() As String
    '    Get
    '        Return _changesIDColumn
    '    End Get
    '    Set(ByVal value As String)
    '        _changesIDColumn = value
    '    End Set
    'End Property

    ' CHANGES IS LOCKED COLUMN
    Private _changesIsLockedColumn As String = "IsLocked"
    <Bindable(True), Category("Grid"), DefaultValue("IsLocked")> _
    Public Property ChangesIsLockedColumn() As String
        Get
            Return _changesIsLockedColumn
        End Get
        Set(ByVal value As String)
            _changesIsLockedColumn = value
        End Set
    End Property

    ' CHANGES FIELD CHANGES COLLECTION/LIST
    'Private _changesChangesListName As String = "Changes"
    '<Bindable(True), Category("Grid"), DefaultValue("Changes")> _
    'Public Property ChangesListName() As String
    '    Get
    '        Return _changesChangesListName
    '    End Get
    '    Set(ByVal value As String)
    '        _changesChangesListName = value
    '    End Set
    'End Property

    ' CHANGES FIELD NAME COLUMN
    'Private _changesFieldNameColumn As String = "FieldName"
    '<Bindable(True), Category("Grid"), DefaultValue("FieldName")> _
    'Public Property ChangesFieldNameColumn() As String
    '    Get
    '        Return _changesFieldNameColumn
    '    End Get
    '    Set(ByVal value As String)
    '        _changesFieldNameColumn = value
    '    End Set
    'End Property

    ' CHANGES FIELD VALUE COLUMN
    'Private _changesFieldValueColumn As String = "FieldValue"
    '<Bindable(True), Category("Grid"), DefaultValue("FieldValue")> _
    'Public Property ChangesFieldValueColumn() As String
    '    Get
    '        Return _changesFieldValueColumn
    '    End Get
    '    Set(ByVal value As String)
    '        _changesFieldValueColumn = value
    '    End Set
    'End Property

#End Region

#Region "Grid ID"
    Private _gridID As Integer = 0

    <Bindable(True), Category("Grid"), DefaultValue(0)> _
    Public Property GridID() As Integer
        Get
            Return _gridID
        End Get
        Set(ByVal value As Integer)
            _gridID = value
        End Set
    End Property
#End Region

#Region "Sorting"
    Public Property CurrentSortColumn() As Integer
        Get
            Dim o As Object = Session.Item(GridID & "CurrSortCol")
            If Not o Is Nothing Then
                Return CType(o, Integer)
            Else
                Return 1
            End If
        End Get
        Set(ByVal value As Integer)
            Session.Item(GridID & "CurrSortCol") = value
        End Set
    End Property

    Public Property CurrentSortDirection() As Integer
        Get
            Dim o As Object = Session.Item(GridID & "CurrSortDir")
            If Not o Is Nothing Then
                Dim i As Integer = CType(o, Integer)
                If i = 0 Or i = 1 Then
                    Return i
                Else
                    Return GetGridItem(CurrentSortColumn).DefaultSort
                End If
            End If
        End Get
        Set(ByVal value As Integer)
            Session.Item(GridID & "CurrSortDir") = value
        End Set
    End Property
#End Region

#Region "Advanced Sort"
    Public Property CurrentAdvancedSort() As String
        Get
            CheckSortAndFilter()
            Dim o As Object = Session.Item(GridID & "CurrAdvSort")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return String.Empty
            End If
        End Get
        Set(ByVal value As String)
            Session.Item(GridID & "CurrAdvSort") = value
        End Set
    End Property

    Private _useAdvancedSort As Boolean = False
    <Bindable(False)> _
    Public Property UseAdvancedSort() As Boolean
        Get
            Return _useAdvancedSort
        End Get
        Set(ByVal value As Boolean)
            _useAdvancedSort = value
        End Set
    End Property
#End Region

#Region "Advanced Filter Properties"
    <Bindable(False)> _
    Public Property CurrentAdvancedFilter() As String
        Get
            CheckSortAndFilter()
            Dim o As Object = Session.Item(GridID & "CurrAdvFilter")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return String.Empty
            End If
        End Get
        Set(ByVal value As String)
            Session.Item(GridID & "CurrAdvFilter") = value
        End Set
    End Property

    <Bindable(False)> _
    Public Property CurrentAdvancedFilterID() As Integer
        Get
            Dim o As Object = Session.Item(GridID & "CurrAdvFilterID")
            If Not o Is Nothing Then
                Return CType(o, Integer)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session.Item(GridID & "CurrAdvFilterID") = value
        End Set
    End Property

    <Bindable(False)> _
    Public Property CurrentAdvancedFilterName() As String
        Get
            Dim o As Object = Session.Item(GridID & "CurrAdvFilterName")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session.Item(GridID & "CurrAdvFilterName") = value
        End Set
    End Property

    <Bindable(False)> _
    Public Property SearchString() As String
        Get
            Dim o As Object = Session.Item(GridID & "searchString")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As String)
            Session.Item(GridID & "searchString") = value
        End Set
    End Property

    Private _useAdvancedFilter As Boolean = False
    <Bindable(False)> _
    Public Property UseAdvancedFilter() As Boolean
        Get
            Return _useAdvancedFilter
        End Get
        Set(ByVal value As Boolean)
            _useAdvancedFilter = value
        End Set
    End Property

    Private _objSavedFilters As DBDataTable = Nothing
    <Bindable(False)> _
    Public Property SavedFilters() As DBDataTable
        Get
            Return _objSavedFilters
        End Get
        Set(ByVal value As DBDataTable)
            If value Is Nothing Or _objSavedFilters IsNot value Then
                If Not _objSavedFilters Is Nothing Then
                    _objSavedFilters.Dispose()
                End If
            End If
            _objSavedFilters = value
        End Set
    End Property
#End Region

#Region "Advanced Filter Functions"

    Private Sub AppendFilterParameter(ByRef p_xmlStr As String, ByVal filterNum As Integer, ByVal p_colOrd As Integer, ByVal p_filterParam As String, ByVal p_conjuct As String, ByVal p_colname As String, ByVal p_verb As String, ByVal p_verbid As Integer)
        If Not IsDBNull(p_filterParam) Then
            p_xmlStr = p_xmlStr & "<Parameter FilterID=""" & filterNum & """ Conjunction=""" & p_conjuct & """ ColName=""" & p_colname & """ ColOrdinal=""" & p_colOrd & """ VerbText=""" & p_verb & """ VerbID=""" & p_verbid & """>" & p_filterParam & "</Parameter>"
        Else
            p_xmlStr = p_xmlStr & "<Parameter FilterID=""" & filterNum & """ Conjunction=""" & p_conjuct & """ ColName=""" & p_colname & """ ColOrdinal=""" & p_colOrd & """ VerbText=""" & p_verb & """ VerbID=""" & p_verbid & """ />"
        End If
    End Sub

    Private Sub PersistNewFilterData()

        Dim SQLStr As String ', utils
        Dim m_Filter_Name As String
        Dim m_Filter_XML As String
        Dim m_Grid_ID As String = Me.GridID.ToString()

        If Len(Trim(Request.Form("txtSaveAsName"))) > 0 Then
            m_Filter_Name = "'" & Replace(Request.Form("txtSaveAsName"), "'", "''") & "'"
        Else
            m_Filter_Name = "DEFAULT"
        End If

        If Len(Trim(CurrentAdvancedFilter)) > 0 Then
            m_Filter_XML = "'" & Replace(CurrentAdvancedFilter, "'", "''") & "'"
        Else
            m_Filter_XML = "DEFAULT"
        End If

        'utils = New cls_UtilityLibrary

        If Request.Form("Select_SendTo") <> "" Then
            SQLStr = "INSERT INTO SavedFilter (User_ID, Grid_ID, Filter_Name, Filter_XML) "
            SQLStr = SQLStr & " VALUES ('0" & Request.Form("Select_SendTo") & "', " & m_Grid_ID & ", " & m_Filter_Name & ", " & m_Filter_XML & ") "
        Else
            SQLStr = "INSERT INTO SavedFilter (User_ID, Grid_ID, Filter_Name, Filter_XML) "
            SQLStr = SQLStr & " VALUES ('0" & Session("UserID") & "', " & m_Grid_ID & ", " & m_Filter_Name & ", " & m_Filter_XML & ") "
        End If
        'utils.RunSQL(SQLStr)
        DataUtilities.RunSQL(SQLStr)

        'utils = Nothing

        'Dim ActivityLog, ActivityType, ActivityReferenceType
        'ActivityLog = New cls_ActivityLog
        'ActivityType = New cls_ActivityType

        'ActivityLog.Activity_Type = ActivityType.Create_ID
        'ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " created a new Filter called """ & m_Filter_Name & """."

        'ActivityLog.Reference_ID = 0
        'ActivityLog.Save()

        'ActivityLog = Nothing
        'ActivityType = Nothing
    End Sub

    Private Sub EditFilterData(ByVal p_Filter_ID As Integer, ByVal Previous_Filter_XML As String)
        Dim SQLStr As String ', utils
        'Dim m_Filter_Name As String
        Dim m_Filter_XML As String
        Dim m_Grid_ID As String = Me.GridID.ToString()

        If Len(Trim(CurrentAdvancedFilter)) > 0 Then
            m_Filter_XML = "'" & Replace(CurrentAdvancedFilter, "'", "''") & "'"
        Else
            m_Filter_XML = "DEFAULT"
        End If

        'If Trim(Previous_Filter_XML) <> Trim(CurrentAdvancedFilter) Then
        '    Dim ActivityLog, ActivityType, ActivityReferenceType
        '    ActivityLog = New cls_ActivityLog
        '    ActivityType = New cls_ActivityType

        '    ActivityLog.Activity_Type = ActivityType.Modify_ID
        '    ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " edited Filter """ & GetFilterName(p_Filter_ID) & """."

        '    ActivityLog.Reference_ID = p_Filter_ID
        '    ActivityLog.Save()

        '    ActivityLog = Nothing
        '    ActivityType = Nothing
        'End If

        'utils = New cls_UtilityLibrary

        SQLStr = "UPDATE SavedFilter "
        SQLStr = SQLStr & " SET Filter_XML=" & m_Filter_XML & " WHERE ID = '0" & p_Filter_ID & "' AND Grid_ID = " & m_Grid_ID
        'utils.RunSQL(SQLStr)
        DataUtilities.RunSQL(SQLStr)

        'utils = Nothing
    End Sub

    Private Sub DeleteFilterData(ByVal p_Filter_ID As Integer)

        'Dim ActivityLog, ActivityType, ActivityReferenceType
        'ActivityLog = New cls_ActivityLog
        'ActivityType = New cls_ActivityType

        'ActivityLog.Activity_Type = ActivityType.Delete_ID
        'ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " deleted Filter """ & GetFilterName(p_Filter_ID) & """."

        'ActivityLog.Reference_ID = p_Filter_ID
        'ActivityLog.Save()

        'ActivityLog = Nothing
        'ActivityType = Nothing

        Dim SQLStr As String ', utils
        Dim m_Grid_ID As String = Me.GridID.ToString()

        'utils = New cls_UtilityLibrary

        SQLStr = "DELETE FROM SavedFilter WHERE ID = '0" & p_Filter_ID & "' and Grid_ID = " & m_Grid_ID
        'utils.RunSQL(SQLStr)
        DataUtilities.RunSQL(SQLStr)

        'utils = Nothing
    End Sub

    Private Function GetFilterName(ByVal p_Filter_ID As Integer) As String

        Dim SQLStr As String ', utils, rs
        Dim reader As DBReader
        Dim m_Filter_Name As String
        Dim m_Grid_ID As String = Me.GridID.ToString()

        'utils = New cls_UtilityLibrary

        SQLStr = "SELECT Filter_Name FROM SavedFilter WITH (NOLOCK) WHERE ID = '0" & p_Filter_ID & "' and Grid_ID = " & m_Grid_ID
        'rs = utils.LoadRSFromDB(SQLStr)
        reader = DataUtilities.GetDBReader(SQLStr)

        If reader.Reader.HasRows() AndAlso reader.Read() Then
            m_Filter_Name = DataHelper.SmartValues(reader("Filter_Name"), "String")
        Else
            m_Filter_Name = ""
        End If

        reader.Dispose()
        reader = Nothing

        Return m_Filter_Name

    End Function

    Private Sub GetMostRecentFilterInformation()

        Dim SQLStr As String ', utils, rs
        Dim reader As DBReader
        Dim m_Filter_Name As String, m_Filter_ID As String
        Dim m_Grid_ID As String = Me.GridID.ToString()

        'utils = New cls_UtilityLibrary

        SQLStr = "SELECT TOP 1 ID, Filter_Name FROM SavedFilter WITH (NOLOCK) WHERE User_ID = '0" & Session("UserID") & "' and Grid_ID = " & m_Grid_ID & " ORDER BY ID DESC "
        'rs = utils.LoadRSFromDB(SQLStr)
        reader = DataUtilities.GetDBReader(SQLStr)

        If (Not reader Is Nothing) AndAlso reader.HasRows AndAlso reader.Read() Then
            m_Filter_Name = DataHelper.SmartValues(reader("Filter_Name"), "String")
            m_Filter_ID = DataHelper.SmartValues(reader("ID"), "Long")
        Else
            m_Filter_Name = ""
            m_Filter_ID = ""
        End If

        Me.CurrentAdvancedFilterID = m_Filter_ID
        Me.CurrentAdvancedFilterName = m_Filter_Name

        reader.Dispose()
        reader = Nothing
    End Sub

    Private Function LoadSavedFilter(ByVal filterID As Integer) As Boolean
        Dim SQLStr As String
        Dim reader As DBReader
        Dim retValue As Boolean = False
        Dim m_Grid_ID As String = Me.GridID.ToString()

        SQLStr = "select ID, Filter_Name, Filter_XML from SavedFilter WITH (NOLOCK) WHERE ID = " & filterID & " AND User_ID = '0" & Session("UserID") & "' and Grid_ID = " & m_Grid_ID
        reader = DataUtilities.GetDBReader(SQLStr)
        If (Not reader Is Nothing) AndAlso reader.HasRows AndAlso reader.Read() Then
            CurrentAdvancedFilterID = DataHelper.SmartValues(reader("ID"), "Integer")
            CurrentAdvancedFilterName = DataHelper.SmartValues(reader("Filter_Name"), "String")
            CurrentAdvancedFilter = DataHelper.SmartValues(reader("Filter_XML"), "String")
            retValue = True
        End If
        reader.Dispose()
        reader = Nothing
        Return retValue
    End Function

#End Region

#Region "Paging"
    Private _showPaging As Boolean = False
    Private _recordCount As Integer = 0
    Private _pageCount As Integer = 0
    Private _currentPage As Integer = 1
    Private _firstRow As Integer = 1
    Private _lastRow As Integer = GRID_DEFAULT_PAGE_SIZE
    Private _pagingCookie As Boolean = False

    Public Property RecordCount() As Integer
        Get
            Return _recordCount
        End Get
        Set(ByVal value As Integer)
            _recordCount = value
            SetupPaging()
            _showPaging = True
        End Set
    End Property

    Public Property PageCount() As Integer
        Get
            Return _pageCount
        End Get
        Set(ByVal value As Integer)
            _pageCount = value
        End Set
    End Property

    Public Property CurrentPageSize() As Integer
        Get
            Dim ret As Integer = DataHelper.SmartValues(Me.pageSize.Text, "integer", False)
            If ret <= 0 Then ret = DefaultPageSize
            Return ret
        End Get
        Set(ByVal value As Integer)
            Me.pageSize.Text = value.ToString()
        End Set
    End Property

    Public Property CurrentPage() As Integer
        Get
            Return _currentPage
        End Get
        Set(ByVal value As Integer)
            _currentPage = value
        End Set
    End Property

    Public ReadOnly Property PagingFirstRow() As Integer
        Get
            Return _firstRow
        End Get
    End Property

    Public ReadOnly Property PagingLastRow() As Integer
        Get
            Return _lastRow
        End Get
    End Property

    Public ReadOnly Property ShowPaging() As Boolean
        Get
            Return _showPaging
        End Get
    End Property

    Public Property PagingCookie() As Boolean
        Get
            Return _pagingCookie
        End Get
        Set(ByVal value As Boolean)
            _pagingCookie = value
        End Set
    End Property
#End Region

#Region "Item Maintenance"
    Private _itemAddText As String = String.Empty
    Private _itemAddURL As String = String.Empty
    Private _itemEditURL As String = String.Empty
    Private _itemViewURL As String = String.Empty
    Private _itemDeleteURL As String = String.Empty
    Private _itemCustomURL As String = String.Empty
    Private _itemCustomText As String = String.Empty

    Public Property ItemAddText() As String
        Get
            Return _itemAddText
        End Get
        Set(ByVal value As String)
            _itemAddText = value
        End Set
    End Property

    Public Property ItemAddURL() As String
        Get
            Return _itemAddURL
        End Get
        Set(ByVal value As String)
            _itemAddURL = value
            If (value <> "") Then
                Me.UserCanAdd = True
            Else
                Me.UserCanAdd = False
            End If
        End Set
    End Property

    Public Property ItemEditURL() As String
        Get
            Return _itemEditURL
        End Get
        Set(ByVal value As String)
            _itemEditURL = value
            If (value <> "") Then
                Me.UserCanEdit = True
            Else
                Me.UserCanEdit = False
            End If
        End Set
    End Property

    Public Property ItemViewURL() As String
        Get
            Return _itemViewURL
        End Get
        Set(ByVal value As String)
            _itemViewURL = value
            If (value <> "") Then
                Me.UserCanView = True
            Else
                Me.UserCanView = False
            End If
        End Set
    End Property

    Public Property ItemDeleteURL() As String
        Get
            Return _itemDeleteURL
        End Get
        Set(ByVal value As String)
            _itemDeleteURL = value
        End Set
    End Property

    Public Property ItemCustomURL() As String
        Get
            Return _itemCustomURL
        End Get
        Set(ByVal value As String)
            _itemCustomURL = value
        End Set
    End Property

    Public Property ItemCustomText() As String
        Get
            Return _itemCustomText
        End Get
        Set(ByVal value As String)
            _itemCustomText = value
        End Set
    End Property
#End Region

#Region "AddGridItem Functions"
    Public Function AddGridItem(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String) As GridItem
        Dim obj As New GridItem(id, headerText, fieldName, fieldType)
        _gridItems.Add(obj)
        Return obj
    End Function

    Public Function AddGridItem(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String) As GridItem
        Dim obj As New GridItem(id, headerText, fieldName, fieldType, fieldFormat)
        _gridItems.Add(obj)
        Return obj
    End Function

    Public Function AddGridItem(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal defaultSort As SortDirection) As GridItem
        Dim obj As New GridItem(id, headerText, fieldName, fieldType, fieldFormat, defaultSort)
        _gridItems.Add(obj)
        Return obj
    End Function

    Public Function AddGridItem(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal columnAlign As String) As GridItem
        Dim obj As New GridItem(id, headerText, fieldName, fieldType, fieldFormat, columnAlign)
        _gridItems.Add(obj)
        Return obj
    End Function

    Public Function AddGridItem(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal columnAlign As String, ByVal columnVAlign As String) As GridItem
        Dim obj As New GridItem(id, headerText, fieldName, fieldType, fieldFormat, columnAlign, columnVAlign)
        _gridItems.Add(obj)
        Return obj
    End Function

    Public Function AddGridItem(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal columnAlign As String, ByVal columnVAlign As String, ByVal defaultSort As SortDirection) As GridItem
        Dim obj As New GridItem(id, headerText, fieldName, fieldType, fieldFormat, columnAlign, defaultSort)
        _gridItems.Add(obj)
        Return obj
    End Function

    Public Function AddGridItemWithType(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal columnType As String) As GridItem
        Dim obj As New GridItem(id, headerText, fieldName, fieldType, fieldFormat)
        obj.ColumnType = columnType
        _gridItems.Add(obj)
        Return obj
    End Function
#End Region

#Region "Add / Remove Access Special Values"
    Public Sub AddSpecialValue(ByVal columnName As String, ByVal value As Object, ByVal displayText As String, ByVal compareType As String, ByVal onChangeOriginalValue As Boolean)
        _specialValues.Add(columnName, value.ToString(), displayText, compareType, onChangeOriginalValue)
    End Sub

    Public Sub AddSpecialValue(ByVal columnName As String, ByVal value As Object, ByVal displayText As String, ByVal compareType As String)
        _specialValues.Add(columnName, value.ToString(), displayText, compareType)
    End Sub

    Public Sub AddSpecialValue(ByVal columnName As String, ByVal value As Object, ByVal displayText As String)
        _specialValues.Add(columnName, value.ToString(), displayText)
    End Sub

    Public Sub ClearSpecialValue(ByVal columnName As String)
        _specialValues.ClearByName(columnName)
    End Sub

    Public Function GetSpecialValueDisplayText(ByVal columnName As String, ByVal value As Object) As String
        Return GetSpecialValueDisplayText(columnName, value, False)
    End Function
    Public Function GetSpecialValueDisplayText(ByVal columnName As String, ByVal value As Object, ByVal onChangeOriginalValue As Boolean) As String
        Return _specialValues.GetSpecialValueDisplayText(columnName, value.ToString(), onChangeOriginalValue)
    End Function

    Public Function GetSpecialValueHeaderLink(ByVal columnName As String) As String
        Return _specialValues.GetSpecialValueHeaderLink(columnName)
    End Function

    Public Function HasSpecialValueHeaderLink(ByVal columnName As String) As Boolean
        Return _specialValues.HasSpecialValueHeaderLink(columnName)
    End Function

    Public Function HasSpecialValueOnChange(ByVal column As String) As Boolean
        Return _specialValues.HasSpecialValueOnChange(column)
    End Function
#End Region

#Region "Public Grid Access Properties and Methods"

    Private _fgiArray As ArrayList = Nothing
    Private _giArray As ArrayList = Nothing
    Public Property FixedGridItemsArray() As ArrayList
        Get
            Return _fgiArray
        End Get
        Set(ByVal value As ArrayList)
            _fgiArray = value
        End Set
    End Property
    Public Property ScrollableGridItemsArray() As ArrayList
        Get
            Return _giArray
        End Get
        Set(ByVal value As ArrayList)
            _giArray = value
        End Set
    End Property

    Public Function GetNumberColumns() As Integer
        Return _gridItems.Count
    End Function

    Public ReadOnly Property ItemCollection() As GridItemCollection
        Get
            Return Me._gridItems
        End Get
    End Property

    Public Property GridItems() As ArrayList
        Get
            Return _gridItems.GridItems
        End Get
        Set(ByVal value As ArrayList)
            _gridItems.GridItems = value
        End Set
    End Property

    Public ReadOnly Property FixedGridItems() As ArrayList
        Get
            Return _gridItems.GetFixedGridItems()
        End Get
    End Property

    Public ReadOnly Property ScrollableGridItems() As ArrayList
        Get
            Return _gridItems.GetScrollableGridItems()
        End Get
    End Property

    Public Function GetGridItem(ByVal id As Integer) As GridItem
        Dim objGridItem As GridItem = Nothing
        Dim i As Integer
        For i = 0 To GridItems.Count - 1
            If CType(GridItems(i), GridItem).ID = id Then
                objGridItem = CType(GridItems(i), GridItem)
                Exit For
            End If
        Next i
        Return objGridItem
    End Function

    Public Function GetGridItem(ByVal fieldName As String) As GridItem
        Dim objGridItem As GridItem = Nothing
        Dim i As Integer
        If GridItems.Count > 0 Then
            For i = 0 To GridItems.Count - 1 Step 1
                If CType(GridItems(i), GridItem).FieldName = fieldName Then
                    objGridItem = CType(GridItems(i), GridItem)
                    Exit For
                End If
            Next i
        End If

        Return objGridItem
    End Function

    Public Function GridHasFixedColumns() As Boolean
        Dim hasFixedColumns As Boolean = False
        For i As Integer = 0 To _gridItems.Count - 1
            If CType(_gridItems(i), GridItem).FixedColumn Then
                hasFixedColumns = True
                Exit For
            End If
        Next
        Return hasFixedColumns
    End Function

    Public Sub SetDefaultSortColumn(ByVal id As Integer)
        Dim obj As GridItem = GetGridItem(id)
        If Not obj Is Nothing Then
            CurrentSortColumn = id
            CurrentSortDirection = obj.DefaultSort
        End If
    End Sub

    Public Sub SetDefaultSortColumn(ByVal id As Integer, ByVal defaultSort As SortDirection)
        Dim obj As GridItem = GetGridItem(id)
        If Not obj Is Nothing Then
            CurrentSortColumn = id
            CurrentSortDirection = defaultSort
        End If
    End Sub

    Public Sub SortAllColumns()
        Dim i As Integer
        For i = 0 To _gridItems.Count - 1
            CType(GridItems.Item(i), GridItem).SortColumn = True
        Next
    End Sub

    Public Sub FilterAllColumns()
        Dim i As Integer
        For i = 0 To _gridItems.Count - 1
            CType(GridItems.Item(i), GridItem).FilterColumn = True
        Next
    End Sub

    Public Function GridGetNextSortDirection(ByVal gi As GridItem) As String
        Dim sortDir As String = ""
        If gi.ID = CurrentSortColumn Then
            If CurrentSortDirection = SortDirection.SortAscending Then
                sortDir = "1" ' set to descending
            Else
                sortDir = "0" ' set to ascending
            End If
        Else
            If gi.DefaultSort = SortDirection.SortAscending Then
                sortDir = "0" ' set to ascending
            Else
                sortDir = "1" ' set to descending
            End If
        End If
        Return sortDir
    End Function

    Public Function GridGetNextSortDirectionText(ByVal objGridItem As GridItem) As String
        Dim sortDir As String = ""
        If objGridItem.ID = CurrentSortColumn Then
            If CurrentSortDirection = SortDirection.SortAscending Then
                sortDir = "Descending Order" ' set to descending
            Else
                sortDir = "Ascending Order" ' set to ascending
            End If
        Else
            If objGridItem.DefaultSort = SortDirection.SortAscending Then
                sortDir = "Ascending Order" ' set to ascending
            Else
                sortDir = "Descending Order" ' set to descending
            End If
        End If
        Return sortDir
    End Function

    Public Function GridGetHelpText(ByVal objGridItem As GridItem) As String
        Dim strHelp As String = ":: Click to sort by " & Replace(objGridItem.HeaderText, "<br />", " ") & " in " & GridGetNextSortDirectionText(objGridItem) & " ::"
        Return strHelp
    End Function

    Public Function GridGetHeaderText(ByVal gi As GridItem) As String
        If _gridItems.IsGridSortable And Not ExcelMode Then
            Return GetSortLink(gi, gi.HeaderText)
        Else
            Return gi.HeaderText
        End If
    End Function

    Public Function GridGetSortImage(ByVal gi As GridItem) As String
        Dim img As String = "&nbsp;"
        If _gridItems.IsGridSortable And ((CurrentSortColumn = gi.ID And Not Me.UseAdvancedSort) Or gi.AdvancedSortColOrdinal > 0) Then
            If gi.AdvancedSortColOrdinal > 0 Then
                If gi.AdvancedSortDirection = SortDirection.SortAscending Then
                    img = ImagePath & "sort_asc.gif"
                Else
                    img = ImagePath & "sort_desc.gif"
                End If
            Else
                If CurrentSortDirection = SortDirection.SortAscending Then
                    img = ImagePath & "sort_asc.gif"
                Else
                    img = ImagePath & "sort_desc.gif"
                End If
            End If

            img = "<img src=""" & img & """ height=""8"" width=""8"" border=""0"" hspace=""2"" vspace=""2"" alt=""" & GridGetHelpText(gi) & """>"
            If gi.AdvancedSortColOrdinal > 0 Then
                img += "<sup>" & gi.AdvancedSortColOrdinal & "&nbsp;</sup>"
            End If
            Return GetSortLink(gi, img)
        Else
            Return img
        End If
    End Function

    Public Function GetSortLink(ByVal gi As GridItem, ByVal displayText As String) As String
        Dim sb As New StringBuilder(String.Empty)
        Dim sortDir As String = GridGetNextSortDirection(gi)
        If gi.SortColumn Then
            sb.Append("<a href=""javascript:void(0); sortDetails('" & gi.ID & "','" & sortDir & "');""")
            'sb.Append(" onMouseOver=""window.status='" & GridGetHelpText(objGridItem) & "';return true;""")
            sb.Append(" title=""" & GridGetHelpText(gi) & """>")
            sb.Append(displayText)
            sb.Append("</a>")
        Else
            sb.Append(displayText)
        End If
        Return sb.ToString()
    End Function

    Private _sb As StringBuilder = Nothing

    Public Function GetGridHeaderCells() As String
        Return GetGridHeaderCells(False)
    End Function
    Public Function GetGridHeaderCells(ByVal fixedCols As Boolean) As String
        ' init
        Dim index As Integer
        ' clear the string builder
        _sb.Length = 0
        ' setup row of cells
        Dim al As ArrayList = IIf(fixedCols, FixedGridItemsArray, ScrollableGridItemsArray)
        Dim s As String = IIf(fixedCols, "fixedheader", "header")
        index = 0
        For Each gi As GridItem In al
            _sb.Append(vbCrLf & "<td nowrap id=""col_" & gi.ID & """ class=""gHC""")
            If gi.AllowAjaxEdit Then
                If HasSpecialValueHeaderLink(gi.FieldName) Then
                    _sb.Append(GetHeaderSpecialCellAction(gi))
                Else
                    _sb.Append(GetHeaderCellAction(gi))
                End If
            Else
                If gi.FieldFormat = "special" Then
                    _sb.Append(GetHeaderSpecialCellAction(gi))
                End If
            End If
            _sb.Append("><table border=""0"" cellpadding=""0"" cellspacing=""0"" width=""100%""><tr>")
            _sb.Append("<th nowrap width=""100%"" class=""gHCT"">" & GridGetHeaderText(gi) & "</th>")
            _sb.Append("<th nowrap class=""gHCI"">" & GridGetSortImage(gi) & "</th>")
            _sb.Append("</tr></table></td>" & vbCrLf)
            _sb.Append(GetHeaderSep(index, s) & vbCrLf)
            index += 1
        Next
        ' return string
        Return _sb.ToString()
    End Function

    Private _hCellAction As String
    Public Function GetHeaderCellAction(ByVal gi As GridItem) As String
        _hCellAction = ""
        If Me.AllowAjaxEdit AndAlso gi.AllowAjaxEdit AndAlso Me.AllowSetAll Then
            Select Case gi.FieldType.ToLower()
                Case "date", "datetime"
                    _hCellAction = "'sDPSA',''"
                Case "integer"
                    _hCellAction = "'eNCSA','1'"
                Case "number", "integer", "decimal"
                    _hCellAction = "'eNCSA','0'"
                Case Else
                    ' default ("string")
                    If gi.FieldFormat = "listvalue" AndAlso gi.FieldFormatString <> String.Empty Then
                        _hCellAction = "'eDDSA','" & gi.FieldFormatString & "'"
                    Else
                        _hCellAction = "'eCSA'," & gi.MaxLength & ""
                    End If

            End Select
            _hCellAction = String.Format("showSetAll(this, {0}, '{1}', {2});", gi.ID, gi.HeaderText.Replace("<br />", " ").Replace("<BR />", " ").Replace("'", "''"), _hCellAction)
        End If
        _hCellAction = " ondblclick=""" & _hCellAction & """"
        Return _hCellAction
    End Function
    Public Function GetHeaderSpecialCellAction(ByVal gi As GridItem) As String
        _hCellAction = String.Empty
        If gi.FieldFormat = "special" AndAlso Me.AllowSetAll Then
            _hCellAction = GetSpecialValueHeaderLink(gi.FieldName).Replace("<br />", " ").Replace("<BR />", " ")
        End If
        _hCellAction = " ondblclick=""" & _hCellAction & """"
        Return _hCellAction
    End Function

    Public Function GetGridCells(ByVal di As Object, ByVal sepTag As String) As String
        Return GetGridCells(di, sepTag, False)
    End Function
    Public Function GetGridCells(ByVal di As Object, ByVal sepTag As String, ByVal fixedCols As Boolean) As String
        ' init
        Dim index As Integer, recID As Integer
        ' clear the string builder
        _sb.Length = 0
        ' setup row of cells
        Dim al As ArrayList = IIf(fixedCols, FixedGridItemsArray, ScrollableGridItemsArray)
        index = 0
        Dim fieldVal As Object, fieldValChanges As Object = Nothing
        Dim changedValueObj As Object
        Dim changedValue As String = String.Empty
        Dim valueChanged As Boolean = False
        Dim val As CustomFieldValue
        Dim gClass As String = IIf(Me.ShowChanges, Me.GridClassColChanges, Me.GridClassCol)
        For Each gi As GridItem In al
            recID = DataBinder.Eval(di, RecordIDColumn)
            If gi.FieldFormatString <> "{{CUSTOM}}" Then
                fieldVal = DataBinder.Eval(di, gi.FieldName)
            Else
                val = Me.CustomFields.GetValue(recID, DataHelper.SmartValues(gi.FieldName, "integer", False))
                If Not val Is Nothing Then
                    fieldVal = val.FieldValue
                Else
                    fieldVal = String.Empty
                End If

            End If

            ' temp
            'If gi.FieldName.Contains("Eaches") OrElse gi.FieldName.Contains("Cost") Then
            '    Me.ShowChanges = Me.ShowChanges
            'End If
            ' end temp

            ' changed value
            If Me.ShowChanges Then
                changedValueObj = Me.GetChangedValue(recID, gi.FieldName, IIf(fieldVal IsNot Nothing, fieldVal.ToString(), String.Empty))
                If changedValueObj IsNot Nothing Then
                    changedValue = changedValueObj.ToString()
                    Dim formatString As String = gi.FieldFormat.ToLower().Trim()
                    If formatString = "listvalue" Or formatString = "special" Then
                        formatString = "string"
                    End If
                    If gi.TreatEmptyAsZero Then
                        If DataHelper.IsEmptyOrZero(fieldVal, gi.FieldType) AndAlso DataHelper.IsEmptyOrZero(changedValueObj, gi.FieldType) Then
                            valueChanged = False
                        Else

                            If DataHelper.SmartValuesAsString(fieldVal, formatString) <> DataHelper.SmartValuesAsString(changedValueObj, formatString) Then
                                valueChanged = True
                            Else
                                valueChanged = False
                            End If
                        End If
                    Else
                        If DataHelper.SmartValuesAsString(fieldVal, formatString) <> DataHelper.SmartValuesAsString(changedValueObj, formatString) Then
                            valueChanged = True
                        Else
                            valueChanged = False
                        End If
                    End If
                Else
                    changedValueObj = fieldVal
                    changedValue = String.Empty
                    valueChanged = False
                End If
            Else
                changedValueObj = fieldVal
            End If
            ' end changed value

            ' ------------------------------------------------------------------------------------------------------------------------------------
            ' cell
            ' ------------------------------------------------------------------------------------------------------------------------------------

            'Add Special logic for Bulk Item Maintenance Gridview
            Dim isBulkDomestic As Boolean = False
            Dim isBulkImport As Boolean = False
            Dim itemMaintRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailFormRecord = TryCast(di, NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailFormRecord)

            If (Me.GridID = WebConstants.WorkflowType.BulkItemMaint) And (itemMaintRecord IsNot Nothing) Then
                If itemMaintRecord.VendorType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemType.Domestic Then isBulkDomestic = True
                If itemMaintRecord.VendorType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemType.Import Then isBulkImport = True
            End If

            _sb.Append("<td id=""gc_" & recID & "_" & gi.ID & """ class=""" & gClass & """")
            If gi.ColumnAlign <> String.Empty Then _sb.Append(" align = """ & gi.ColumnAlign & """")
            If gi.AllowAjaxEdit Then
                'Add Special Logic for Bulk Item Maint grids
                If (Me.GridID = WebConstants.WorkflowType.BulkItemMaint) Then
                    Select Case gi.ColumnType
                        Case "D"
                            'Only Domestic Items can have editable Domestic Fields
                            If isBulkDomestic Then
                                _sb.Append(GetCellAction(gi, recID, changedValueObj))
                            End If
                        Case "I"
                            'Only Import Items can have editable Import Fields
                            If isBulkImport Then
                                _sb.Append(GetCellAction(gi, recID, changedValueObj))
                            End If
                        Case Else
                            'Field is editable by both Domestic and Import
                            _sb.Append(GetCellAction(gi, recID, changedValueObj))
                    End Select
                Else
                    _sb.Append(GetCellAction(gi, recID, changedValueObj))
                End If
            End If
            _sb.Append(">")

            ' change control start
            If Me.ShowChanges AndAlso IsValidChangesField(gi) Then

                If (Me.GridID = WebConstants.WorkflowType.BulkItemMaint) Then
                    'Only Render Change Control if Column Type matches Item Type (for the Bulk Item Maint grid)
                    If (gi.ColumnType = "D" And isBulkDomestic) Or (gi.ColumnType = "I" And isBulkImport) Or (gi.ColumnType = "X") Then
                        RenderChangesStart(_sb, ("gce_" & recID & "_" & gi.ID), valueChanged, gi)
                    End If
                Else
                    RenderChangesStart(_sb, ("gce_" & recID & "_" & gi.ID), valueChanged, gi)
                End If
            End If
            ' end changecontrol start

            ' value
            If (Me.GridID = WebConstants.WorkflowType.BulkItemMaint) Then
                'Only Output Value if Column Type matches Item Type (for the Bulk Item Maint grid)
                If (gi.ColumnType = "D" And isBulkDomestic) Or (gi.ColumnType = "I" And isBulkImport) Or (gi.ColumnType = "X") Then
                    _sb.Append("<span id=""gce_" & recID & "_" & gi.ID & """")
                    _sb.Append(">")
                    _sb.Append(GetCellText(gi, recID, changedValueObj))
                    _sb.Append("</span>")
                End If
            Else
                _sb.Append("<span id=""gce_" & recID & "_" & gi.ID & """")
                _sb.Append(">")
                _sb.Append(GetCellText(gi, recID, changedValueObj))
                _sb.Append("</span>")
            End If
            ' end value

            ' change control end 
            If Me.ShowChanges AndAlso IsValidChangesField(gi) Then
                If (Me.GridID = WebConstants.WorkflowType.BulkItemMaint) Then
                    'Only Render Change control if Column Type matches Item Type (for the Bulk Item Maint Grid)
                    If (gi.ColumnType = "D" And isBulkDomestic) Or (gi.ColumnType = "I" And isBulkImport) Or (gi.ColumnType = "X") Then
                        RenderChangesEnd(_sb, gi, ("gce_" & recID & "_" & gi.ID), GetCellText(gi, recID, fieldVal, True), valueChanged, Not (Me.AllowAjaxEdit))
                    End If
                Else
                    RenderChangesEnd(_sb, gi, ("gce_" & recID & "_" & gi.ID), GetCellText(gi, recID, fieldVal, True), valueChanged, Not (Me.AllowAjaxEdit))
                End If
            End If
            ' end change control end

            _sb.Append("</td>")
            ' ------------------------------------------------------------------------------------------------------------------------------------
            ' end cell
            ' ------------------------------------------------------------------------------------------------------------------------------------
            _sb.Append(GetHeaderSep(index, sepTag))
            index += 1
        Next
        ' return string
        Return _sb.ToString()
    End Function

    Protected Function IsValidChangesField(ByRef gi As GridItem) As Boolean
        ' REMOVE THE FOLLOWING IF (boolean or bit) ONCE CHECKBOXES ARE SUPPORTED CHANGES CONTROLS ON THE GRID.
        If gi.FieldType.ToLower() = "boolean" OrElse gi.FieldType.ToLower() = "bit" Then
            Return False
        ElseIf gi.FieldFormat = "special" Then
            Return HasSpecialValueOnChange(gi.FieldName)
        Else
            Return True
        End If
    End Function

    Protected Function GetChangedValue(ByVal recID As Integer, ByVal fieldName As String, ByVal originalValue As String) As Object
        Dim changedValue As Object = Nothing
        Try
            If Me.ChangesDataSource IsNot Nothing AndAlso _
                TypeOf Me.ChangesDataSource Is NovaLibra.Coral.SystemFrameworks.Michaels.IMTableChanges Then

                Dim list As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.IMRowChanges) = CType(Me.ChangesDataSource, NovaLibra.Coral.SystemFrameworks.Michaels.IMTableChanges).RowChanges, o As NovaLibra.Coral.SystemFrameworks.Michaels.IMRowChanges, changesList As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.IMCellChangeRecord) = Nothing, n As Integer

                For i As Integer = 0 To list.Count - 1
                    o = list.Item(i)
                    If o IsNot Nothing AndAlso recID = o.ID Then
                        changesList = o.RowRecords
                        If changesList IsNot Nothing Then
                            For n = 0 To changesList.Count - 1
                                If fieldName.Replace("_", "") = changesList.Item(n).FieldName.Replace("_", "") Then
                                    changedValue = changesList.Item(n).FieldValue
                                    Exit For
                                End If
                            Next
                        End If
                        Exit For
                    End If
                Next
            End If
        Catch ex As Exception
            Throw New Exception("Grid Control: Error getting the changed value.  The changes object was not an expected type.")
            changedValue = Nothing
        End Try
        Return changedValue
    End Function

    Protected Sub RenderChangesStart(ByRef _sb As StringBuilder, ByVal controlID As String, ByVal valueChanged As Boolean, ByRef gi As GridItem)
        _sb.Append("<div id=""nlcCCC_" & controlID & """ class=""" & IIf(valueChanged, "nlcCCC", "nlcCCC_hide") & """>")
        _sb.Append("<input type=""hidden"" id=""" & controlID & "_teaz"" value=""" & IIf(gi.TreatEmptyAsZero, "1", "0") & """ />")
        '_sb.Append(IIf(gi.TreatEmptyAsZero, "*", ""))
        _sb.Append("<table border=""0"" cellpadding=""0"" cellspacing=""0""><tr><td>")
    End Sub

    Protected Sub RenderChangesEnd(ByRef _sb As StringBuilder, ByRef gi As GridItem, ByVal controlID As String, ByVal originalValue As Object, ByVal valueChanged As Boolean, Optional ByVal renderReadOnly As Boolean = False)
        ' *********************************************************
        ' *** TAKEN FROM NLChangeControl.RenderEndChangeControl ***
        ' *********************************************************
        Dim strHideCSSClass As String = String.Empty
        If Not valueChanged Then
            strHideCSSClass = " nlcHide"
        End If
        Dim script As String = String.Empty

        ' init
        'Dim wc As WebControl = CType(Control, WebControl)
        Dim restore As String = String.Empty
        Dim origVal As String = String.Empty

        restore = "if(confirm('UNDO this change?')) "
        Select Case gi.FieldFormat.ToLower().Trim()
            Case "boolean", "bit"
                ' TODO: finish this if need to support checkboxes
                If Not renderReadOnly Then
                    restore = restore & String.Format("restoreNLCCBG('{0}',{1});", controlID, IIf(Boolean.Parse(originalValue), "true", "false"))
                End If
                origVal = IIf(Boolean.Parse(originalValue), "[x]", "[&nbsp;&nbsp;]")
            Case "listvalue"
                If Not renderReadOnly Then
                    restore = restore & String.Format("restoreNLCDDG('{0}','{1}');", controlID, originalValue.ToString())
                End If
                origVal = originalValue
            Case "special"
                If Not renderReadOnly Then
                    restore = restore & String.Format("restoreNLCSP('{0}','{1}');", controlID, gi.FieldName)
                End If
                origVal = originalValue
            Case "integer", "long", "number", "decimal", "formatnumber", "formatnumber2", "formatnumber3", "formatnumber4", "formatcurrency", "formatcurrency4", "money", "percent"
                If Not renderReadOnly Then
                    restore = restore & String.Format("restoreNLCNCG('{0}','{1}');", controlID, originalValue.ToString().Replace("'", "\'"))
                End If
                origVal = originalValue.ToString()
            Case Else ' string values
                If Not renderReadOnly Then
                    restore = restore & String.Format("restoreNLCTBG('{0}','{1}');", controlID, originalValue.ToString().Replace("'", "\'"))
                End If
                origVal = originalValue.ToString()
        End Select

        ' start change div
        _sb.Append("<div id=""nlcCCOrigC_" & controlID & """  class=""nlcCCOrigC" & strHideCSSClass & """ >")
        ' create original value
        Dim ctrl As System.Web.UI.WebControls.HiddenField = New System.Web.UI.WebControls.HiddenField()
        ctrl.ID = controlID & "_ORIG"
        If Not gi.IsSpecial() Then
            ctrl.Value = originalValue
        Else
            ctrl.Value = String.Empty
        End If

        _sb.Append(FormHelper.RenderControl(ctrl))

        _sb.Append("<span id=""" & controlID & "_ORIGS"" class=""nlcCCT"" style=""text-align: left;"">")
        If gi.FieldFormat.ToLower().Trim() = "boolean" Or gi.FieldFormat.ToLower().Trim() = "bit" Then
            ' Don't HtmlEncode this so the &nbsp; turn into spaces
            _sb.Append(origVal)
        Else
            '_sb.Append(Me.Page.Server.HtmlEncode(origVal))
            _sb.Append(origVal) ' origVal is already encoded
        End If
        _sb.Append("</span>")
        ' end change div
        _sb.Append("</div>")

        _sb.Append("</td><td valign=""bottom"">")

        ' create revert object if the control is not readonly
        If Not renderReadOnly AndAlso (gi.AllowAjaxEdit Or gi.IsSpecial()) Then
            _sb.Append("<div id=""nlcCCRevert_" & controlID & """ class=""nlcCCRevert" & strHideCSSClass & """ onclick=""" & restore & """></div>")
        Else
            _sb.Append("<div id=""nlcCCRevert_" & controlID & """></div>")
        End If

        _sb.Append("</td></tr></table>")

        ' end container div
        _sb.Append("</div>")
    End Sub

    Public Function GetCellText(ByVal gi As GridItem, ByVal id As Integer, ByVal value As Object) As String
        Return GetCellText(gi, id, value, False)
    End Function
    Public Function GetCellText(ByVal gi As GridItem, ByVal id As Integer, ByVal value As Object, ByVal onChangeOriginalValue As Boolean) As String
        If (gi.FieldFormat = "special") Then
            'Hack to handle Vendor Type field (which apparently can't use ListValues like everything else, due to explicit value being written out when cell is read only
            If gi.FieldName = "VendorType" Then
                If value = "1" Then Return "Domestic" Else Return "Import"
            Else
                Return GetSpecialValueDisplayText(gi.FieldName, value, onChangeOriginalValue).Replace("{{ID}}", id.ToString()).Replace("{{VALUE}}", value.ToString()).Replace("{{GIID}}", gi.ID.ToString())
            End If

        ElseIf (gi.FieldFormat = "listvalue") Then
            Return DataHelper.SmartValuesAsString(value, gi.FieldType)
        Else
            If TypeOf value Is Date AndAlso value = Date.MinValue Then
                Return ""
            ElseIf TypeOf value Is Decimal AndAlso value = Decimal.MinValue Then
                Return ""
            ElseIf TypeOf value Is Integer AndAlso value = Integer.MinValue Then
                Return ""
            ElseIf TypeOf value Is Long AndAlso value = Long.MinValue Then
                Return ""
            ElseIf TypeOf value Is Int64 AndAlso value = Int64.MinValue Then
                Return ""
            ElseIf TypeOf value Is Int32 AndAlso value = Int32.MinValue Then
                Return ""
            ElseIf TypeOf value Is Int16 AndAlso value = Int16.MinValue Then
                Return ""
            Else
                'Return Server.HtmlEncode(DataHelper.SmartValues(value, gi.FieldFormat, True).ToString())
                Return Server.HtmlEncode(DataHelper.SmartValuesAsString(value, gi.FieldFormat))
                'If Not Me.ExcelMode And strValue.ToString().Length > 100 Then
                '    Return strValue.ToString().Substring(0, 100) & "..."
                'End If
            End If
        End If
    End Function

    Private _cellAction As String
    Public Function GetCellAction(ByVal gi As GridItem, ByVal id As Integer, ByVal value As Object) As String
        _cellAction = ""

        If Me.AllowAjaxEdit And gi.AllowAjaxEdit Then
            Select Case gi.FieldType.ToLower()
                Case "date", "datetime"
                    Dim dt As Date = DataHelper.SmartValues(value, "date")
                    Dim ds As String
                    If dt <> Date.MinValue Then
                        ds = dt.ToString("M/d/yyyy")
                    Else
                        ds = String.Empty
                    End If
                    _cellAction = "sDP(this," & gi.ID & ",'" & id & "');"
                Case "integer", "long", "int", "bigint"
                    Dim maxlen As String = IIf(gi.MaxLength > 0, gi.MaxLength.ToString(), "20")
                    _cellAction = "eNC(this," & gi.ID & ",'" & id & "','1','" & maxlen & "');"
                Case "number", "decimal", "formatcurrency", "formatcurrency4", "formatnumber", "formatnumber2", "formatnumber3", "formatnumber4", "money"
                    Dim maxlen As String = IIf(gi.MaxLength > 0, gi.MaxLength.ToString(), "20")
                    _cellAction = "eNC(this," & gi.ID & ",'" & id & "','0','" & maxlen & "');"
                Case Else
                    ' default ("string")
                    If gi.FieldFormat = "listvalue" AndAlso gi.FieldFormatString <> String.Empty Then
                        _cellAction = "eDD(this," & gi.ID & ",'" & id & "','" & gi.FieldFormatString & "');"
                    Else
                        _cellAction = "eC(this," & gi.ID & ",'" & id & "'," & gi.MaxLength & ");"
                    End If

            End Select
        End If
        If gi.SkipColumnOnEdit <> String.Empty Then
            _cellAction = "gridSkipCol = '" & gi.SkipColumnOnEdit & "'; " & _cellAction
        End If
        _cellAction = " ondblclick=""" & _cellAction & """"
        Return _cellAction
    End Function

    Public Function GetRowAction(ByVal id As Integer) As String
        Dim strValue As String = ""
        If Me.ShowContentMenu Then
            strValue = " onmouseover=""HR(" & id & ");"" onmouseout=""HR(0);"" oncontextmenu=""HR(" & id & ");SelectRow(" & id & ");displayMenu(); return false;"""
        End If
        Return strValue
    End Function

    Public Function GetHeaderSep(ByVal itemIndex As Integer, ByVal strType As String) As String
        Dim strValue As String = "", str As String = String.Empty
        If Me.ShowGridLines Then
            Select Case strType
                Case "header"
                    str = "gHL"
                    strValue = "<td class=""" & str & """><img src=""" & ImagePath & "spacer.gif"" alt="""" /></td>"

                Case "data"
                    str = "gL"
                    strValue = "<td class=""" & str & """><img src=""" & ImagePath & "spacer.gif"" alt="""" /></td>"
                Case "fixeddataimg", "dataimg"
                    strValue = "<td><img src=""" & ImagePath & "spacer.gif"" alt="""" /></td>"
                Case "datahighlight"
                    strValue = "<td class=""" & GridClassRow & """><img src=""" & ImagePath & "spacer.gif"" alt="""" /></td>"
                Case "fixedheader"
                    If itemIndex = (FixedGridItemsArray.Count - 1) Then
                        str = "fgHLL"
                    Else
                        str = "fgHL"
                    End If
                    strValue = "<td class=""" & str & """><img src=""" & ImagePath & "spacer.gif"" alt="""" /></td>"
                Case "fixeddata"
                    If itemIndex = (FixedGridItemsArray.Count - 1) Then
                        str = "fgLL"
                    Else
                        str = "fgL"
                    End If
                    strValue = "<td class=""" & str & """><img src=""" & ImagePath & "spacer.gif"" alt="""" /></td>"
            End Select
        End If
        Return strValue
    End Function

    'Public Function FormatDatePickerParams(ByVal p_StringIn As String) As String
    '    'Dim isCompleted As Boolean
    '    Dim m As Integer, d As Integer, y As Integer
    '    Dim m_StringOut As String
    '    Dim tmpStr As String
    '    'isCompleted = False
    '    tmpStr = Replace(LCase(p_StringIn), "completed", "")

    '    'If InStr(p_StringIn, "Completed") Then
    '    '    isCompleted = True
    '    'End If
    '    If IsDate(tmpStr) Then
    '        m = Month(tmpStr)
    '        d = Day(tmpStr)
    '        y = Year(tmpStr)
    '    End If

    '    'm_StringOut = "'" & m & "','" & d & "','" & y & "','" & LCase(CStr(isCompleted)) & "'"
    '    m_StringOut = "'" & m & "','" & d & "','" & y & "'"
    '    Return m_StringOut
    'End Function

    Public Sub RemoveGridItem(ByVal fieldName As String)
        Me.ItemCollection.Remove(fieldName)
    End Sub

    Public Property CustomFields() As NovaLibra.Coral.SystemFrameworks.CustomFields
        Get
            Return _customFields
        End Get
        Set(ByVal value As NovaLibra.Coral.SystemFrameworks.CustomFields)
            _customFields = value
        End Set
    End Property

    Protected Sub RemoveCustomFieldsFromGrid()

    End Sub

    Protected Sub AddCustomFieldsToGrid()

    End Sub


#End Region

    Private Function GetAlphaChars(ByVal inputString As String) As String
        Return GetAlphaChars(inputString, String.Empty)
    End Function

    Private Function GetAlphaChars(ByVal inputString As String, ByVal otherValidCharacters As String) As String
        Dim returnString As String = String.Empty
        Dim charArr As Char()
        If inputString.Length > 0 Then
            charArr = inputString.ToCharArray()
            For Each c As Char In charArr
                If ValidationHelper.IsAlpha(c) Then
                    ' valid char
                    returnString += c
                Else
                    ' check for other valid characters
                    If otherValidCharacters.Length > 0 AndAlso otherValidCharacters.IndexOf(c) >= 0 Then
                        returnString += c
                    End If
                End If
            Next
        End If
        Return returnString
    End Function

    Private Function IsAlpha(ByVal c As Char) As Boolean
        Dim charVal As Int16 = Convert.ToInt16(c)
        If charVal < 65 Or (charVal > 90 And charVal < 97) Or charVal > 122 Then
            Return False
        Else
            Return True
        End If
    End Function


End Class

#Region "Enum SortDirection"
Public Enum SortDirection
    SortAscending = 0
    SortDescending = 1
End Enum
#End Region

#Region "Class GridItemCollection"
Public Class GridItemCollection
    Dim _gridItems As ArrayList

    Public Sub New()
        _gridItems = New ArrayList
    End Sub

    Public Function Add(ByVal value As Object) As Integer
        Return _gridItems.Add(value)
    End Function

    Public Sub Insert(ByVal index As Integer, ByVal value As Object)
        _gridItems.Insert(index, value)
    End Sub

    Public Property GridItems() As ArrayList
        Get
            Return _gridItems
        End Get
        Set(ByVal value As ArrayList)
            _gridItems = value
        End Set
    End Property

    Public ReadOnly Property IsGridSortable() As Boolean
        Get
            Dim sortable As Boolean = False
            For i As Integer = 0 To _gridItems.Count - 1
                If CType(_gridItems(i), GridItem).SortColumn Then
                    sortable = True
                    Exit For
                End If
            Next
            Return sortable
        End Get
    End Property

    Public ReadOnly Property Count() As Integer
        Get
            Return _gridItems.Count
        End Get
    End Property

    Default Public Property Item(ByVal index As Integer) As Object
        Get
            Return _gridItems.Item(index)
        End Get
        Set(ByVal value As Object)
            _gridItems.Item(index) = value
        End Set
    End Property

    Public Sub RemoveAt(ByVal index As Integer)
        If index > 0 AndAlso index <= _gridItems.Count - 1 Then
            _gridItems.RemoveAt(index)
        End If
    End Sub

    Public Sub Remove(ByVal fieldName As String)
        Dim gi As GridItem
        For i As Integer = 0 To _gridItems.Count - 1
            gi = _gridItems.Item(i)
            If gi.FieldName = fieldName Then
                _gridItems.RemoveAt(i)
                Exit For
            End If
        Next
    End Sub

    Public Function GetGridItems() As ArrayList
        Return _gridItems
    End Function

    Public Function GetFixedGridItems() As ArrayList
        Dim arrList As New ArrayList
        Dim i As Integer
        For i = 0 To _gridItems.Count - 1
            If CType(_gridItems(i), GridItem).FixedColumn Then
                arrList.Add(_gridItems(i))
            End If
        Next
        Return arrList
    End Function

    Public Function GetScrollableGridItems() As ArrayList
        Dim arrList As New ArrayList
        Dim i As Integer
        For i = 0 To _gridItems.Count - 1
            If Not CType(_gridItems(i), GridItem).FixedColumn Then
                arrList.Add(_gridItems(i))
            End If
        Next
        Return arrList
    End Function

    Public Function GetNextGridItemID() As Integer
        Dim i As Integer, nextID As Integer = 1
        Dim gi As GridItem
        For i = (_gridItems.Count - 1) To 0 Step -1
            gi = CType(_gridItems(i), GridItem)
            If gi.ID >= nextID Then nextID = gi.ID + 1
        Next
        Return nextID
    End Function

    Protected Overrides Sub Finalize()
        Do While _gridItems.Count > 0
            _gridItems.RemoveAt(0)
        Loop
        _gridItems = Nothing
        MyBase.Finalize()
    End Sub
End Class
#End Region

#Region "Class GridItem"
Public Class GridItem

    ' private fields

    ' field info
    Private _ID As Integer = 0
    Private _headerText As String = String.Empty
    Private _fieldName As String = String.Empty
    Private _fieldType As String = String.Empty
    ' format
    Private _fieldFormat As String = String.Empty
    ' custom format
    Private _customFormatString As Boolean = False
    Private _fieldFormatString As String = String.Empty
    ' column align
    Private _columnAlign As String = String.Empty
    Private _columnVAlign As String = String.Empty
    ' sorting
    Private _defaultSort As SortDirection = SortDirection.SortAscending
    Private _sortColumn As Boolean = False
    ' fixed columns
    Private _fixedColumn As Boolean = False
    ' sizing
    Private _columnWidth As String = String.Empty
    ' styles
    Private _columnClass As String = String.Empty

    Private _columnType As String = String.Empty

    ' advanced sort col ordinal
    Private _advancedSortColOrdinal As Integer = 0
    Private _advancedSortDirection As SortDirection = SortDirection.SortAscending

    ' filter
    Private _filterColumn As Boolean = False

    ' AJAX edit
    Private _allowAjaxEdit As Boolean = False

    ' Max length (for string type only)
    Private _maxLength As Integer = 0

    ' Disable column on edit (use this field to disable a column temporarily until the save function returns)
    Private _skipColOnEdit As String = String.Empty

    Private _noBlankListValue As Boolean = False

    Private _treatEmptyAsZero As Boolean = False


    ' constructors
    Public Sub New()

    End Sub

    Public Sub New(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String)
        _ID = id
        _headerText = headerText
        _fieldName = fieldName
        _fieldType = fieldType
    End Sub

    Public Sub New(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String)
        _ID = id
        _headerText = headerText
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldFormat = fieldFormat
    End Sub

    Public Sub New(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal defaultSort As SortDirection)
        _ID = id
        _headerText = headerText
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldFormat = fieldFormat
        _defaultSort = defaultSort
        _sortColumn = True
    End Sub

    Public Sub New(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal columnAlign As String)
        _ID = id
        _headerText = headerText
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldFormat = fieldFormat
        _columnAlign = columnAlign
    End Sub

    Public Sub New(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal columnAlign As String, ByVal columnVAlign As String)
        _ID = id
        _headerText = headerText
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldFormat = fieldFormat
        _columnAlign = columnAlign
        _columnVAlign = columnVAlign
    End Sub

    Public Sub New(ByVal id As Integer, ByVal headerText As String, ByVal fieldName As String, ByVal fieldType As String, ByVal fieldFormat As String, ByVal columnAlign As String, ByVal defaultSort As SortDirection)
        _ID = id
        _headerText = headerText
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldFormat = fieldFormat
        _columnAlign = columnAlign
        _defaultSort = defaultSort
        _sortColumn = True
    End Sub

    ' public properties
    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property

    Public Property HeaderText() As String
        Get
            Return _headerText
        End Get
        Set(ByVal value As String)
            _headerText = value
        End Set
    End Property

    Public Property DefaultSort() As SortDirection
        Get
            Return _defaultSort
        End Get
        Set(ByVal value As SortDirection)
            _defaultSort = value
        End Set
    End Property

    Public Property FieldName() As String
        Get
            Return _fieldName
        End Get
        Set(ByVal value As String)
            _fieldName = value
        End Set
    End Property

    Public Property FieldType() As String
        Get
            Return _fieldType
        End Get
        Set(ByVal value As String)
            _fieldType = value
        End Set
    End Property

    Public Property FieldFormat() As String
        Get
            Return _fieldFormat
        End Get
        Set(ByVal value As String)
            _fieldFormat = value
        End Set
    End Property

    Public Property FieldFormatString() As String
        Get
            Return _fieldFormatString
        End Get
        Set(ByVal value As String)
            _fieldFormatString = value
            If Trim(value) <> String.Empty Then
                _customFormatString = True
            Else
                _customFormatString = False
            End If
        End Set
    End Property

    Public Property ColumnAlign() As String
        Get
            Return _columnAlign
        End Get
        Set(ByVal value As String)
            _columnAlign = value
        End Set
    End Property

    Public Property ColumnVAlign() As String
        Get
            Return _columnVAlign
        End Get
        Set(ByVal value As String)
            _columnVAlign = value
        End Set
    End Property

    Public Property ColumnType() As String
        Get
            Return _columnType
        End Get
        Set(value As String)
            _columnType = value
        End Set
    End Property

    Public Property SortColumn() As Boolean
        Get
            Return _sortColumn
        End Get
        Set(ByVal value As Boolean)
            _sortColumn = value
        End Set
    End Property

    Public Property FixedColumn() As Boolean
        Get
            Return _fixedColumn
        End Get
        Set(ByVal value As Boolean)
            _fixedColumn = value
        End Set
    End Property

    Public Property ColumnWidth() As String
        Get
            Return _columnWidth
        End Get
        Set(ByVal value As String)
            _columnWidth = value
        End Set
    End Property

    Public Property ColumnClass() As String
        Get
            Return _columnClass
        End Get
        Set(ByVal value As String)
            _columnClass = value
        End Set
    End Property

    Public Property AdvancedSortColOrdinal() As Integer
        Get
            Return _advancedSortColOrdinal
        End Get
        Set(ByVal value As Integer)
            _advancedSortColOrdinal = value
        End Set
    End Property

    Public Property AdvancedSortDirection() As SortDirection
        Get
            Return _advancedSortDirection
        End Get
        Set(ByVal value As SortDirection)
            _advancedSortDirection = value
        End Set
    End Property

    Public Property FilterColumn() As Boolean
        Get
            Return _filterColumn
        End Get
        Set(ByVal value As Boolean)
            _filterColumn = value
        End Set
    End Property

    Public Property AllowAjaxEdit() As Boolean
        Get
            Return _allowAjaxEdit
        End Get
        Set(ByVal value As Boolean)
            _allowAjaxEdit = value
        End Set
    End Property

    Public Property MaxLength() As Integer
        Get
            Return _maxLength
        End Get
        Set(ByVal value As Integer)
            _maxLength = value
        End Set
    End Property

    Public Property SkipColumnOnEdit() As String
        Get
            Return _skipColOnEdit
        End Get
        Set(ByVal value As String)
            _skipColOnEdit = value
        End Set
    End Property

    Public Property NoBlankListValue() As Boolean
        Get
            Return _noBlankListValue
        End Get
        Set(ByVal value As Boolean)
            _noBlankListValue = value
        End Set
    End Property

    Public Property TreatEmptyAsZero() As Boolean
        Get
            Return _treatEmptyAsZero
        End Get
        Set(ByVal value As Boolean)
            _treatEmptyAsZero = value
        End Set
    End Property

    Public Function IsSpecial() As Boolean
        If FieldFormat.ToLower().Trim() = "special" Then
            Return True
        Else
            Return False
        End If
    End Function

End Class
#End Region


#Region "Special Values Classes"
Class SpecialValueCollection
    Dim _specialValues As ArrayList

    Public Sub New()
        _specialValues = New ArrayList
    End Sub

    Public Sub ClearByName(ByVal columnName As String)
        Dim i As Integer
        For i = _specialValues.Count - 1 To 0 Step -1
            If CType(_specialValues.Item(i), SpecialValue).ColumnName = columnName Then
                _specialValues.RemoveAt(i)
            End If
        Next
    End Sub

    Public Function Add(ByVal value As Object) As Integer
        Return _specialValues.Add(value)
    End Function

    Public Function Add(ByVal columnName As String, ByVal value As String, ByVal displayText As String, ByVal compareType As String, ByVal onChangeOriginalValue As Boolean) As Integer
        Return _specialValues.Add(New SpecialValue(columnName, value, displayText, compareType, onChangeOriginalValue))
    End Function

    Public Function Add(ByVal columnName As String, ByVal value As String, ByVal displayText As String, ByVal compareType As String) As Integer
        Return _specialValues.Add(New SpecialValue(columnName, value, displayText, compareType))
    End Function

    Public Function Add(ByVal columnName As String, ByVal value As String, ByVal displayText As String) As Integer
        Return _specialValues.Add(New SpecialValue(columnName, value, displayText))
    End Function

    Public Sub Insert(ByVal index As Integer, ByVal value As Object)
        _specialValues.Insert(index, value)
    End Sub

    Public Property SpecialValues() As ArrayList
        Get
            Return _specialValues
        End Get
        Set(ByVal value As ArrayList)
            _specialValues = value
        End Set
    End Property

    Public ReadOnly Property Count() As Integer
        Get
            Return _specialValues.Count
        End Get
    End Property

    Default Public Property Item(ByVal index As Integer) As Object
        Get
            Return _specialValues.Item(index)
        End Get
        Set(ByVal value As Object)
            _specialValues.Item(index) = value
        End Set
    End Property

    Public Function HasSpecialValueOnChange(ByVal column As String) As Boolean
        Dim ret As Boolean = False
        For Each sv As SpecialValue In _specialValues
            If sv.ColumnName = column AndAlso sv.OnChangeOriginalValue Then
                ret = True
                Exit For
            End If
        Next
        Return ret
    End Function

    Public Function GetSpecialValueDisplayText(ByVal column As String, ByVal value As String) As String
        Return GetSpecialValueDisplayText(column, value, False)
    End Function
    Public Function GetSpecialValueDisplayText(ByVal column As String, ByVal value As String, ByVal onChangeOriginalValue As Boolean) As String
        Dim ret As String = String.Empty
        Dim l As Long
        For Each sv As SpecialValue In _specialValues
            If sv.ColumnName = column AndAlso sv.CompareType <> "{{HEADER_LINK}}" AndAlso (onChangeOriginalValue = sv.OnChangeOriginalValue) Then
                Select Case sv.CompareType
                    Case "<0"
                        l = DataHelper.SmartValues(value, "long", True)
                        If l < 0 Then
                            ret = sv.DisplayText
                            Exit For
                        End If
                    Case "<=0"
                        l = DataHelper.SmartValues(value, "long", True)
                        If l <= 0 Then
                            ret = sv.DisplayText
                            Exit For
                        End If
                    Case "=0"
                        l = DataHelper.SmartValues(value, "long", True)
                        If l = 0 Then
                            ret = sv.DisplayText
                            Exit For
                        End If
                    Case ">0"
                        l = DataHelper.SmartValues(value, "long", True)
                        If l > 0 Then
                            ret = sv.DisplayText
                            Exit For
                        End If
                    Case ">=0"
                        l = DataHelper.SmartValues(value, "long", True)
                        If l >= 0 Then
                            ret = sv.DisplayText
                            Exit For
                        End If
                    Case "<>"
                        If sv.Value <> value Then
                            ret = sv.DisplayText
                            Exit For
                        End If
                    Case "any", "all"
                        ret = sv.DisplayText
                        Exit For
                    Case Else
                        If sv.Value = value Then
                            ret = sv.DisplayText
                            Exit For
                        End If
                End Select
            End If
        Next
        Return ret
    End Function

    Public Function GetSpecialValueHeaderLink(ByVal column As String) As String
        Dim ret As String = String.Empty
        For Each sv As SpecialValue In _specialValues
            If sv.ColumnName = column AndAlso sv.CompareType = "{{HEADER_LINK}}" Then
                ret = sv.DisplayText
                Exit For
            End If
        Next
        Return ret
    End Function

    Public Function HasSpecialValueHeaderLink(ByVal column As String) As Boolean
        Dim ret As Boolean = False
        For Each sv As SpecialValue In _specialValues
            If sv.ColumnName = column AndAlso sv.CompareType = "{{HEADER_LINK}}" Then
                ret = True
                Exit For
            End If
        Next
        Return ret
    End Function

    Public Sub RemoteAt(ByVal index As Integer)
        If index > 0 AndAlso index <= _specialValues.Count - 1 Then
            _specialValues.RemoveAt(index)
        End If
    End Sub

    Protected Overrides Sub Finalize()
        Do While _specialValues.Count > 0
            _specialValues.RemoveAt(0)
        Loop
        _specialValues = Nothing
        MyBase.Finalize()
    End Sub
End Class

Class SpecialValue
    Private _columnName As String
    Private _value As String
    Private _displayText As String
    Private _compareType As String
    Private _onChangeOriginalValue As Boolean

    Public Sub New(ByVal columnName As String, ByVal value As String, ByVal displayText As String, ByVal compareType As String, ByVal onChangeOriginalValue As Boolean)
        _columnName = columnName
        _value = value
        _displayText = displayText
        _compareType = compareType
        _onChangeOriginalValue = onChangeOriginalValue
    End Sub
    Public Sub New(ByVal columnName As String, ByVal value As String, ByVal displayText As String, ByVal compareType As String)
        _columnName = columnName
        _value = value
        _displayText = displayText
        _compareType = compareType
        _onChangeOriginalValue = False
    End Sub
    Public Sub New(ByVal columnName As String, ByVal value As String, ByVal displayText As String)
        _columnName = columnName
        _value = value
        _displayText = displayText
        _compareType = String.Empty
        _onChangeOriginalValue = False
    End Sub
    Public ReadOnly Property ColumnName() As String
        Get
            Return _columnName
        End Get
    End Property
    Public ReadOnly Property Value() As String
        Get
            Return _value
        End Get
    End Property
    Public ReadOnly Property DisplayText() As String
        Get
            Return _displayText
        End Get
    End Property
    Public ReadOnly Property CompareType() As String
        Get
            Return _compareType
        End Get
    End Property
    Public ReadOnly Property OnChangeOriginalValue() As Boolean
        Get
            Return _onChangeOriginalValue
        End Get
    End Property

End Class
#End Region
