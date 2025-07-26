
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels

Imports NovaLibra.Common.Utilities
Imports System.Collections.Generic
Imports WebConstants

Partial Public Class _IMAddRecords
    Inherits MichaelsBasePage

#Region "Properties and Constants"
    ' Local Session Constants for this page
    Const SORTEXPRESSION As String = "_ItemSearchSortExp"
    Const SORTDIRECTION As String = "_ItemSearchSortDir"
    Const PAGENUMBER As String = "_ItemSearchPageIndex"

    '---------------------------------------

    ' Get the connection string in one place
    Dim connectString As String
    ' String pipe
    Dim sP As String = "|"

    Dim _batchRec As New NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord
    Dim _itemRec As Models.ItemSearchRecord
    Dim _batchID As Long = 0
    Dim _vendorID As Long = 0
    Dim _refreshGrid As Boolean = False
    Dim _newBatch As Boolean = False
    Dim _class As Integer
    Dim _subClass As Integer

    Private Property ClassNo() As Integer
        Get
            Return _class
        End Get
        Set(ByVal value As Integer)
            _class = value
        End Set
    End Property

    Private Property SubClass() As Integer
        Get
            Return _subClass
        End Get
        Set(ByVal value As Integer)
            _subClass = value
        End Set
    End Property

    Private Property NewBatch() As Boolean
        Get
            Return _newBatch
        End Get
        Set(ByVal value As Boolean)
            _newBatch = value
        End Set
    End Property

    Private Property VendorID() As Long
        Get
            Return _vendorID
        End Get
        Set(ByVal value As Long)
            _vendorID = value
        End Set
    End Property
    Private Property ItemRec() As Models.ItemSearchRecord
        Get
            Return _itemRec
        End Get
        Set(ByVal value As Models.ItemSearchRecord)
            _itemRec = value
        End Set
    End Property

    Private Property BatchRec() As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord
        Get
            Return _batchRec
        End Get
        Set(ByVal value As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord)
            _batchRec = value
        End Set
    End Property
    Private Property BatchID() As Long
        Get
            Return ViewState("BatchID")
            'Return _batchID
        End Get
        Set(ByVal value As Long)
            '_batchID = value
            ViewState("BatchID") = value
        End Set
    End Property

    Public Property RefreshGrid() As Boolean
        Get
            Return _refreshGrid
        End Get
        Set(ByVal value As Boolean)
            _refreshGrid = value
        End Set
    End Property

    Public Property SearchType() As String
        Get
            Return ViewState("searchType")
        End Get
        Set(ByVal value As String)
            ViewState("searchType") = value
        End Set
    End Property
    Public Property Windowed() As Boolean
        Get
            Return ViewState("windowed")
        End Get
        Set(ByVal value As Boolean)
            ViewState("windowed") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' Clear out messages
        ShowMsg("")

        ' FOR TESTING
        ' Session(cUSERID) = 1473
        ' Session(cVENDORID) = 0

        ' Initialize global connect string variable and batchid
        connectString = ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString
        Dim b As Long = 0
        Dim s As String = "IM"

        If Not IsPostBack Then
            s = Request("bid")
            If IsNumeric(s) Then
                b = Convert.ToInt64(s)
            End If
            s = UCase(Request("btype"))
            If s Is Nothing OrElse s.Length = 0 Then s = "IM"

            BatchID = b
            SearchType = s

            ' Is this a window or regular page? Def is Windowed
            Dim temp As String = LCase(Request("w"))
            If temp = "n" Then
                Windowed = False
            Else
                Windowed = True
            End If

            If Windowed Then
                btnClose.Visible = True
                pageheader.Style.Add("display", "none")
                hidWindowed.Value = "1"
            Else
                pageheader.Style.Add("display", "inline")
                btnClose.Visible = False
                hidWindowed.Value = "0"
            End If

            If Session(cBATCHPERPAGE) Is Nothing Then Session(cBATCHPERPAGE) = BATCH_PAGE_SIZE
            gvSearch.PageSize = CInt(Session(cBATCHPERPAGE))

            Session(SORTDIRECTION) = Nothing
            Session(SORTEXPRESSION) = Nothing
            Session(PAGENUMBER) = Nothing

            btnAddRecsToBatch.Style.Add("display", "none")  'Enabled = false
        Else    ' Post Back

        End If

        'alway check that session is still valid
        If Not SecurityCheck() Then
            If Windowed = True Then
                Response.Redirect("closeform.aspx?r=0")
            Else
                Response.Redirect("login.aspx")
            End If
        End If

        If BatchID <= 0 Then
            BatchID = DataHelper.SmartValues(Session(cBATCHID), "long", False)
        Else
            Session(cBATCHID) = BatchID
        End If

        VendorID = Session(cVENDORID)

        LoadBatchInfo()

        If SearchType <> "IM" Then
            ' Do New Item Stuff here
            ' 1 Load Batch
            ' Get Pack info from batch 
            Dim msg As String = Data.BatchData.GetPackInfoFromNIBatch(BatchRec)
            If msg.Length = 0 AndAlso BatchRec.VendorNumber <= 0 Then
                msg = "Please select a Vendor for this Batch."
            End If
            If msg.Length <> 0 Then
                ShowMsg(String.Format("Error Occurred Getting Pack Info for Batch: {0}. " + msg, BatchID.ToString))
                btnAddRecsToBatch.Visible = False
                btnClose.Visible = True
                btnClose.Enabled = True
                btnSearch.Enabled = False
                btnReset.Enabled = False
                Exit Sub
            Else
                'Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch
                'objMichaels.SaveRecord(BatchRec, Session(cUSERID), "", "")
            End If

        End If

        If Not IsPostBack Then
            ' For testing
            'batchID = 45597
            'Session(cBATCHID) = batchID
            srchClass.Items.Insert(0, New ListItem("Select Department", "-1"))
            srchSubClass.Items.Insert(0, New ListItem("Select Class", "-1"))
            srchDept.Attributes.Add("onchange", "GetClass();")
            srchClass.Attributes.Add("onchange", "GetSubClass();")
            srchUPC.Attributes.Add("onchange", "validateUPC();")
            btnSearch.Attributes.Add("onmouseover", "buttonHiLight(1);")
            btnSearch.Attributes.Add("onmouseout", "buttonHiLight(0);")
            btnReset.Attributes.Add("onmouseover", "buttonHiLight(1);")
            btnReset.Attributes.Add("onmouseout", "buttonHiLight(0);")
            SetControls(VendorID)
        Else
            RefreshGrid = IIf(hidRefreshParent.Value = "1", True, False)
            ClassNo = IIf(hidClass.Value.Length > 0, hidClass.Value, -1)
            SubClass = IIf(hidSubClass.Value.Length > 0, hidSubClass.Value, -1)
        End If
    End Sub

    Private Sub LoadBatchInfo()
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch
        BatchRec = objMichaels.GetRecord(BatchID)
    End Sub

    Private Function GetItemRec(ByVal packSKU As String) As Models.ItemSearchRecord
        If packSKU.Length > 0 Then
            Dim itemRecs As List(Of Models.ItemSearchRecord)
            itemRecs = BatchesData.SearchSKURecs(0, BatchRec.VendorNumber, 0, 0, "", "", packSKU, "", "", "", "", Session(cUSERID), VendorID, "", "", 0, 0, String.Empty)
            If itemRecs.Count = 1 Then
                Return itemRecs(0)
            End If
        End If
        Dim dummyRec = New Models.ItemSearchRecord
        dummyRec.SKU = ""
        Return dummyRec
    End Function

    Private Sub SetControls(ByVal CurVendor As Long)
        hidClass.Value = ""
        hidSubClass.Value = ""
        hidLockClass.Value = ""
        hidLockStockIT.Value = ""
        hidBatchPackSKU.Value = ""

        If BatchID > 0 Then
            If BatchRec.ID > 0 Then

                srchVendor.Text = BatchRec.VendorNumber
                vendorName.Text = BatchRec.VendorName
                Select Case BatchRec.PackType
                    Case "R", ""   ' Regular Batch or undefined
                        LoadDropdowns(BatchRec.FinelineDeptID, BatchRec.StockCategory, BatchRec.ItemTypeAttribute, False, False, False)
                        srchVendor.Enabled = False
                        srchVendor.CssClass = "calculatedField textBoxPad"
                        btnAddRecsToBatch.Text = "Add Items to Batch"
                    Case "SB"    ' Sellable Bundle
                        LoadDropdowns(BatchRec.FinelineDeptID, BatchRec.StockCategory, BatchRec.ItemTypeAttribute)
                        btnAddRecsToBatch.Text = "Add Children to Batch"
                        hidBatchPackSKU.Value = BatchRec.PackSKU
                    Case "D"    ' Displayer 
                        LoadDropdowns(BatchRec.FinelineDeptID, BatchRec.StockCategory, BatchRec.ItemTypeAttribute)
                        btnAddRecsToBatch.Text = "Add Children to Batch"
                        hidBatchPackSKU.Value = BatchRec.PackSKU

                        'NAK - Search returns all SKUs associated with vendor (primary or not)
                        srchVendor.Enabled = False
                        srchVendor.CssClass = "calculatedField textBoxPad"
                    Case "DP"   ' Displayer Pack
                        ' Get the Item record for the PackSKU
                        ItemRec = GetItemRec(BatchRec.PackSKU)
                        If ItemRec.SKU <> BatchRec.PackSKU Then
                            ShowMsg("Unable to get Information for DP Pack SKU: " & BatchRec.PackSKU)
                        End If
                        hidClass.Value = ItemRec.ClassNum
                        hidSubClass.Value = ItemRec.SubClassNum
                        If SearchType = "IM" Then
                            hidLockClass.Value = "1"
                        End If
                        hidLockStockIT.Value = "1"
                        LoadDropdowns(BatchRec.FinelineDeptID, BatchRec.StockCategory, BatchRec.ItemTypeAttribute, False, False, False)
                        srchVendor.Enabled = False
                        srchVendor.CssClass = "calculatedField textBoxPad"
                        btnAddRecsToBatch.Text = "Add Children to Batch"
                        hidBatchPackSKU.Value = BatchRec.PackSKU
                End Select
            Else
                ShowMsg("Unable to Load Batch information for BatchID: " + CStr(BatchID))
            End If

        Else
            If SearchType = "IM" Then
                ' Set up to Search for Item Records for a new batch
                LoadDropdowns()
                btnAddRecsToBatch.Text = "Create Batch & Add Items"
                If CurVendor > 0 Then  ' Lock the vendor field so vendors cannot search for other vendors
                    Dim objData As New Data.BatchData()
                    vendorName.Text = objData.GetVendorName(VendorID)
                    objData = Nothing
                    srchVendor.Text = VendorID
                    srchVendor.Enabled = False
                    srchVendor.CssClass = "calculatedField textBoxPad"
                    objData = Nothing
                Else
                    srchVendor.Attributes.Add("onchange", "GetVendorDesc();")
                    srchVendor.Enabled = True
                    srchVendor.CssClass = "srchTextMed textBoxPad"
                    If srchVendor.Text.Length > 0 AndAlso IsNumeric(srchVendor.Text) Then
                        Dim objData As New Data.BatchData()
                        vendorName.Text = objData.GetVendorName(srchVendor.Text)
                        objData = Nothing
                    End If
                End If
            Else
                ShowMsg("Batch Info invalid for New Item Search.")
                btnSearch.Visible = False
            End If

        End If

        ' If the batch exists and not running in a Window, create a link
        If BatchID > 0 AndAlso hidWindowed.Value = "0" Then
            lblBatchID.Text = "<a href='IMDetailItems.aspx?hid=" & BatchID.ToString & "' title='Click to Edit this Batch' >" & BatchID.ToString & "</a>"
        Else
            lblBatchID.Text = IIf(BatchID > 0, BatchID.ToString, "New Batch")
        End If

        Dim strTemp As String = String.Empty
        If BatchID > 0 Then
            strTemp = IIf(SearchType = "IM", "Item Maint", "New Item") & "&nbsp;&nbsp;|&nbsp;&nbsp;"
            strTemp += IIf(BatchRec.BatchTypeID = 1, "Domestic", "Import") & "&nbsp;&nbsp;|&nbsp;&nbsp;"
            Select Case BatchRec.PackType
                Case "R"
                    strTemp += "Regular"
                Case "SB"
                    strTemp += "Sellable Bundle"
                Case "D"
                    strTemp += "Displayer"
                Case "DP"
                    strTemp += "Displayer Pack"
                Case ""
                    strTemp += "Pack Type TBD"
                Case Else
                    strTemp += "Unknown Pack Type"
            End Select
        Else
            strTemp = IIf(SearchType = "IM", "Item Maint", "New Item")
        End If
        lblBatchInfo.Text = strTemp
        'hidEmptyBatchCreated.Value = NewBatch

        'Hide/Show Create Options based on Security Privileges
        If Not SecurityCheckHasAccess("SPD.ADVANCED", "SPD.ADVANCED.CREATEIMBATCH", Session("UserID")) Then
            btnAddRecsToBatch.Visible = False
        End If

    End Sub

    Private Sub LoadDropdowns(Optional ByVal deptNo As Integer = 0, Optional ByVal StockCat As String = "", Optional ByVal ItemTypeAttr As String = "", _
                             Optional ByVal enableDept As Boolean = True, Optional ByVal enableStockCat As Boolean = True, Optional ByVal enableITA As Boolean = True)
        Dim departments As List(Of Models.DepartmentRecord)
        Dim objData As New Data.DepartmentData
        departments = objData.GetDepartments
        srchDept.DataSource = departments
        srchDept.DataTextField = "DeptDesc"
        srchDept.DataValueField = "Dept"
        srchDept.DataBind()
        srchDept.Items.Insert(0, New ListItem("*  Any Department  *", "0"))
        srchDept.SelectedValue = IIf(deptNo >= 0, deptNo, 0)

        If deptNo > 0 AndAlso Not enableDept Then
            srchDept.Enabled = False
            srchDept.CssClass = "calculatedField"
        Else
            srchDept.Enabled = True
            srchDept.CssClass = ""
        End If

        Dim lvgs As ListValueGroups = FormHelper.LoadListValues("ITEMTYPEATTRIB,STOCKCAT")

        FormHelper.LoadListFromListValues(srchStockCat, lvgs.GetListValueGroup("STOCKCAT"), True, "* Any Stock Category *")
        srchStockCat.SelectedValue = StockCat
        If StockCat <> "" AndAlso Not enableStockCat Then
            srchStockCat.Enabled = False
            srchStockCat.CssClass = "calculatedField"
        Else
            srchStockCat.Enabled = True
            srchStockCat.CssClass = ""
        End If

        FormHelper.LoadListFromListValues(srchItemTypeAttr, lvgs.GetListValueGroup("ITEMTYPEATTRIB"), True, "* Any Item Type Attr *")
        srchItemTypeAttr.SelectedValue = ItemTypeAttr
        If ItemTypeAttr <> "" AndAlso Not enableITA Then
            srchItemTypeAttr.Enabled = False
            srchItemTypeAttr.CssClass = "calculatedField"
        Else
            srchItemTypeAttr.Enabled = True
            srchItemTypeAttr.CssClass = ""
        End If
    End Sub

    ' Returns either True / False for Check box enabled state (when retEnabled is true) OR a Tooltip Message. 
    Protected Function GetCheckedTTEnabled(ByVal sku As String, ByVal indEditable As Boolean, ByVal packSKU As String, ByVal itemType As String, _
                        ByVal itemStatus As String, Optional ByVal retEnabled As Boolean = False) As String

        'Determine if the batch is already in an Item Maintenance Batch (when page is being used by Item Maintenance).
        Dim recordBatchID As Long = 0
        If SearchType = "IM" Then
            Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batchList As List(Of Models.BatchRecord) = batchDB.GetBatchesBySKU(sku)
            For Each batch As Models.BatchRecord In batchList
                If batch.BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic Or batch.BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import Then
                    recordBatchID = batch.ID
                    Exit For
                End If
            Next
        End If

        Dim isPack As Boolean = (itemType = "D" OrElse itemType = "DP" OrElse itemType = "SB")
        Dim isChild As Boolean = (itemType = "C")
        Dim isActive As Boolean = (itemStatus = "A")

        If recordBatchID > 0 AndAlso recordBatchID <> BatchID Then
            If retEnabled Then Return "false"
            Return "Item is part of Batch: " + recordBatchID.ToString
        End If

        If recordBatchID > 0 AndAlso recordBatchID = BatchID Then
            If retEnabled Then Return "false"
            Return "This Item is in the current batch"
        End If

        Select Case BatchID
            Case Is <= 0    ' New Batch
                If indEditable AndAlso isPack Then
                    If retEnabled Then Return "true"
                    Return "Select to Create Batch and Add this Pack item as well as all Active Component Items to the batch"
                End If

                If Not indEditable AndAlso isChild Then
                    If retEnabled Then Return "false"
                    Return "Please select DP SKU #: " & packSKU & " to maintain this item."
                End If

                If isChild And Not isActive Then
                    If retEnabled Then Return "true"
                    Return "Select to Create and Add this Inactive Component to a Regular Batch"
                End If

                If isChild AndAlso isActive AndAlso indEditable Then
                    If retEnabled Then Return "true"
                    Return "Select to Create and Add this Component to a Regular Batch"
                End If

                If indEditable AndAlso Not isPack AndAlso Not isChild Then  ' Regular item
                    If retEnabled Then Return "true"
                    Return "Select to Create and Add to Batch"
                End If

            Case Else   ' Existing Batch
                If isPack Then
                    If retEnabled Then Return "false"
                    Return "Only Regular / Component Items can be added to existing Batches"
                End If

                Select Case BatchRec.PackType
                    Case "DP"   ' Displayer Pack
                        If Not isActive Then
                            If retEnabled Then Return "true"
                            Return "While this Item can be added the Batch it must be Active before the batch can be approved."
                        End If

                        If Not indEditable Then
                            If BatchRec.PackSKU <> packSKU Then
                                If retEnabled Then Return "false"
                                Return "This item cannot be added to the batch as it is part of DP Item: " & packSKU
                            End If
                        Else
                            If retEnabled Then Return "true"
                            Return "Select to add this component to the Display Pack"
                        End If

                        If retEnabled Then Return "true"
                        Return "Select to add this item to the Display Pack"

                    Case "D", "SB"    ' Displayer
                        Dim packName As String = IIf(BatchRec.PackType = "SB", "Sellable Bundle", "Displayer")

                        If Not indEditable AndAlso isActive Then
                            If BatchRec.PackSKU <> packSKU Then
                                If retEnabled Then Return "true"
                                Return "Item can be added to this batch. It is also a component of DP Item: " & packSKU
                            Else
                                If retEnabled Then Return "true"
                                Return "Select to add this Item to this " & packName
                            End If
                        End If

                        If Not isActive Then
                            If retEnabled Then Return "true"
                            Return "While this Item can be added the Batch it must be Active before the batch can be approved."
                            '                            Return "Item cannot be added to this Displayer as it is not Active"
                        End If

                        If retEnabled Then Return "true"
                        Return "Select to add this item to the " & packName & " Batch"

                    Case Else   ' Regular Batch
                        If Not isActive Then
                            If retEnabled Then Return "true"
                            Return "Select to add this Discontinued item to the Batch"
                        End If

                        If Not indEditable Then
                            If retEnabled Then Return "false"
                            Return "Item cannot be edited in a Regular Batch as it is a component of DP Item: " & packSKU
                        End If

                        If retEnabled Then Return "true"
                        Return "Select to add this item to Batch"

                End Select

        End Select
        If retEnabled Then Return "false"
        Return "Unknown Item status"

    End Function

    Protected Function GetCheckedStatus(ByVal recBatchID As Long) As String
        If recBatchID = BatchID AndAlso BatchID > 0 Then
            Return "true"
        Else
            Return "false"
        End If
    End Function

    ' This event fires when a NORMAL Page event occurs ie. Page: First Next Prev Last
    Protected Sub gvSearch_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvSearch.PageIndexChanged
        Session(PAGENUMBER) = gvSearch.PageIndex
    End Sub

    ' This event fires when a NORMAL Page event occurs ie. Page First Next Prev Last
    Private Sub gvSearch_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvSearch.PageIndexChanging

    End Sub

    Public Sub SetBatchesPerPage()
        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvSearch.BottomPagerRow
            'If pagerRow Is Nothing Then gvNewBatches.DataBind()
            ctrl = pagerRow.Cells(0).FindControl("txtBatchPerPage")
            If Trim(ctrl.text) <> String.Empty AndAlso IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
                If i > 4 And i < 51 Then
                    If CInt(Session(cBATCHPERPAGE)) <> i Then
                        gvSearch.PageSize = i
                        Session(cBATCHPERPAGE) = i
                    End If
                Else
                    ctrl.text = CStr(Session(cBATCHPERPAGE))
                    ShowMsg("Batches / Page must be between 5 and 50")
                End If
            Else
                ctrl.text = CStr(Session(cBATCHPERPAGE))
                ShowMsg("Batches / Page must be between 5 and 50")
            End If
        Catch e As Exception
        Finally
        End Try
    End Sub

    Private Sub gvSearch_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvSearch.RowCommand
        Dim strCommand As String
        Dim i As Int32
        Try
            strCommand = e.CommandName
            ' Check if GoTo Page button was clicked
            If strCommand = "PageGo" Then
                i = GetPageNumber()
                If i > 0 AndAlso i <= gvSearch.PageCount Then
                    gvSearch.PageIndex = i - 1
                    ' Save the page in session here as the Normal Paging events do not fire
                    Session(PAGENUMBER) = gvSearch.PageIndex
                Else
                    ShowMsg("Invalid Page Number entered.")
                End If
            End If

            ' Check if Batches per page was clicked
            If strCommand = "PageReset" Then
                SetBatchesPerPage()
                gvSearch.PageIndex = 0
            End If

        Catch ex As Exception
            ShowMsg("Error Occurred while Sorting: " & ex.Message)
            i = 0
        Finally
        End Try
    End Sub

    Protected Sub gvSearch_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvSearch.RowCreated
        If (e.Row.RowType = DataControlRowType.Header) Then
            AddSortGlyph(gvSearch, e.Row, Me.objDSData.SelectParameters("sortCol").DefaultValue, _
                Me.objDSData.SelectParameters("sortDir").DefaultValue)
        End If
    End Sub

    Private Sub gvSearch_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvSearch.RowDataBound
        Dim chkbox As CheckBox, rowIndex As Integer, hidcontrol As HiddenField, sku As String, itemType As String, BatchpackSku As String
        If e.Row.RowType = DataControlRowType.DataRow Then
            chkbox = e.Row.FindControl("chkAddRec")
            hidcontrol = e.Row.FindControl("hdnSKUNo")
            sku = hidcontrol.Value
            hidcontrol = e.Row.FindControl("hdnItemType")
            itemType = hidcontrol.Value

            BatchpackSku = hidBatchPackSKU.Value

            If chkbox IsNot Nothing AndAlso hidcontrol IsNot Nothing AndAlso UCase(itemType = "C") Then
                rowIndex = e.Row.RowIndex + 1
                chkbox.Attributes.Add("OnClick", "javascript:CheckChildren('" & sku & "', '" & BatchpackSku & "');")
            End If
        End If

        If e.Row.RowType = DataControlRowType.Pager Then
            Dim ctrlPaging As Object
            ctrlPaging = e.Row.FindControl("PagingInformation")
            ctrlPaging.text = String.Format("Page {0} of {1}", gvSearch.PageIndex + 1, gvSearch.PageCount)
            ctrlPaging = e.Row.FindControl("lblRecsFound")
            ctrlPaging.text = CStr(BatchesData.SearchSKURecsCount) & " " & ctrlPaging.text
            ctrlPaging = e.Row.FindControl("txtgotopage")
            If gvSearch.PageIndex + 1 < gvSearch.PageCount Then
                ctrlPaging.text = CStr(gvSearch.PageIndex + 2)
            Else
                ctrlPaging.text = "1"
            End If
            ctrlPaging = e.Row.FindControl("txtBatchPerPage")
            ctrlPaging.text = CStr(Session(cBATCHPERPAGE))
        End If
    End Sub

    Public Sub SetPageNumber(ByVal intPage As Integer)
        Dim ctrl As New TextBox
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvSearch.BottomPagerRow
            'If pagerRow Is Nothing Then gvSearch.DataBind()
            ctrl = pagerRow.Cells(0).FindControl("txtgotopage")
            ctrl.Text = Convert.ToString(intPage)
        Catch e As Exception
        Finally
        End Try
    End Sub

    Public Function GetPageNumber() As Long
        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvSearch.BottomPagerRow
            ctrl = pagerRow.Cells(0).FindControl("txtgotopage")
            If Trim(ctrl.text) <> String.Empty AndAlso IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
                If i > 0 AndAlso i <= gvSearch.PageCount Then
                Else
                    ShowMsg("Please enter a valid Page Number")
                    i = 1
                End If
            Else
                ShowMsg("Please enter a valid Page Number")
                i = 1
            End If
        Catch e As Exception
            i = 1
        Finally
        End Try
        Return i
    End Function

    Private Sub PopulateSearchGrid(ByVal vendorNo As Integer, ByVal deptNo As Integer, ByVal classNo As Integer, ByVal subClassNo As Integer, ByVal VPN As String, _
           ByVal SKU As String, ByVal itemDesc As String, ByVal UPC As String, ByVal stockCat As String, ByVal ItemTypeAttr As String, ByVal PackType As String, _
             ByVal PackSKU As String, ByVal QuoteRefNum As String, Optional ByVal itemStatus As String = "", Optional ByVal useSession As Boolean = False, Optional ByVal UseSortSession As Boolean = True)

        Dim intPageIndex As Integer, vendorID As Integer, userID As Integer
        Dim sortCol As String, sortDir As Char

        intPageIndex = 0

        If useSession Then
            If Session(PAGENUMBER) IsNot Nothing Then intPageIndex = Session(PAGENUMBER)
        End If

        vendorID = IIf(Session(cVENDORID) Is Nothing, 0, CType(Session(cVENDORID), Integer))
        userID = CInt(Session(cUSERID))

        ' Was Grid sorted?
        If (useSession Or UseSortSession) AndAlso Session(SORTEXPRESSION) IsNot Nothing Then
            sortCol = Session(SORTEXPRESSION)
            sortDir = Session(SORTDIRECTION)
        Else    '  default to sort on ID
            sortCol = "SKU"      ' was ""
            sortDir = "A"
        End If

        ' Data is retrieved using an ObjectDataSource.  ObjectDataSource uses the class \app_Code\BatchesData.vb 
        ' to get data and store in List Control

        ' set the parms for the new search.  Object Data source gets paging from Gridview info so handle that differently
        ' Note: Parms need to be defined in ObjectDataSource in order to handle the SelectCountMethod correctly
        Try
            Me.objDSData.SelectParameters("deptNo").DefaultValue = deptNo
            Me.objDSData.SelectParameters("vendorNum").DefaultValue = vendorNo
            Me.objDSData.SelectParameters("classNo").DefaultValue = classNo
            Me.objDSData.SelectParameters("subClassNo").DefaultValue = subClassNo
            Me.objDSData.SelectParameters("VPN").DefaultValue = VPN
            Me.objDSData.SelectParameters("UPC").DefaultValue = UPC
            Me.objDSData.SelectParameters("SKU").DefaultValue = SKU
            Me.objDSData.SelectParameters("stockCat").DefaultValue = stockCat
            Me.objDSData.SelectParameters("ItemTypeAttr").DefaultValue = ItemTypeAttr
            Me.objDSData.SelectParameters("itemDesc").DefaultValue = itemDesc
            Me.objDSData.SelectParameters("itemStatus").DefaultValue = itemStatus
            Me.objDSData.SelectParameters("packSearch").DefaultValue = PackType
            Me.objDSData.SelectParameters("packSKU").DefaultValue = PackSKU

            Me.objDSData.SelectParameters("userID").DefaultValue = Session(cUSERID)
            Me.objDSData.SelectParameters("vendorID").DefaultValue = vendorID
            Me.objDSData.SelectParameters("sortCol").DefaultValue = sortCol
            Me.objDSData.SelectParameters("sortDir").DefaultValue = sortDir
            Me.objDSData.SelectParameters("quoteRefNum").DefaultValue = QuoteRefNum
            Me.gvSearch.PageIndex = intPageIndex

            gvSearch.DataSourceID = objDSData.ID
            gvSearch.DataBind()

        Catch ex As Exception
            ProcessException(ex, "PopulateSearchGrid")
            gvSearch.Visible = False
        Finally
        End Try

        ' Alway show pager row so the search box displays if any records returned
        If BatchesData.SearchSKURecsCount > 0 AndAlso gvSearch.Visible = True Then
            gvSearch.BottomPagerRow.Visible = True
            'pnlSave.Visible = True
            'btnAddRecsToBatch.Style.Add("display", "inline")  'Enabled = True
        Else
            'pnlSave.Visible = False
            'btnAddRecsToBatch.Style.Add("display", "none")  'Enabled = False
        End If

        ' Reset Sorting and Paging Session variables if this is a normal load of the grid
        If Not useSession Then
            Session(PAGENUMBER) = Nothing
        End If

        If Not useSession AndAlso Not UseSortSession Then
            Session(SORTEXPRESSION) = Nothing
            Session(SORTDIRECTION) = Nothing
        End If

    End Sub

    Private Sub ProcessException(ByVal e As Exception, ByVal strSourceName As String)
        Dim strmessage As String
        strmessage = "Unexpected SPEDY problem has occured in the routine: " & strSourceName & " - "
        If e.InnerException IsNot Nothing Then
            strmessage = strmessage & e.InnerException.Message & ". Please report this issue to the System Administrator."
        Else
            strmessage = strmessage & e.Message & ". Please report this issue to the System Administrator."
        End If
        ShowMsg(strmessage)
    End Sub

    Protected Sub gvSearch_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gvSearch.Sorting

        ' if object sort are not set or not = gr sort expression force Ascending order
        If Me.objDSData.SelectParameters("sortCol").DefaultValue = Nothing _
                Or Me.objDSData.SelectParameters("sortDir").DefaultValue = Nothing _
                Or Me.objDSData.SelectParameters("sortCol").DefaultValue <> e.SortExpression _
                Or Me.objDSData.SelectParameters("sortDir").DefaultValue <> "A" Then
            Me.objDSData.SelectParameters("sortDir").DefaultValue = "A"    ' Force Ascending Order

        ElseIf Me.objDSData.SelectParameters("sortDir").DefaultValue = "A" Then
            Me.objDSData.SelectParameters("sortDir").DefaultValue = "D"    ' Force Descending Order
        End If

        ' set column to sort on
        Me.objDSData.SelectParameters("sortCol").DefaultValue = e.SortExpression
        'Save sort in session
        Session(SORTEXPRESSION) = e.SortExpression
        Session(SORTDIRECTION) = Me.objDSData.SelectParameters("sortDir").DefaultValue

        ' Any sorting should force page back to page 1 (0) of Results
        ' Changing the page index should force the grid to refresh with new parms
        gvSearch.PageIndex = 0

        Session(PAGENUMBER) = 0 ' Sorting resets Page Index. Save it
        e.Cancel = True ' Cancel normal sort as its not supported with a LIST
    End Sub


    Private Sub ShowMsg(ByVal strMsg As String, Optional ByVal type As String = "E")
        Dim curMsg As String
        If strMsg.Length = 0 Then
            lblMessage.Text = "&nbsp;" ' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
        Else
            curMsg = lblMessage.Text
            If curMsg = "&nbsp;" OrElse curMsg.Length = 0 Then       ' Only set the message if there is not one in there already
                lblMessage.Text = strMsg
                If type = "E" Then
                    lblMessage.CssClass = "redText"
                Else
                    lblMessage.CssClass = "greenText"
                End If
            Else
                lblMessage.Text += "<br />" & strMsg
                lblMessage.CssClass = "redText"
            End If
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click
        SearchRecs()
    End Sub

    Sub SearchRecs()
        ' Verify there is at least one parm to search on
        Dim txtVendor As String = srchVendor.Text
        Dim deptNo As Integer = srchDept.SelectedValue

        If hidLockClass.Value = "1" Then
            ClassNo = hidClass.Value
            SubClass = hidSubClass.Value
        Else
            ClassNo = Request("srchClass")
            SubClass = Request("srchSubClass")
        End If
        hidClass.Value = ClassNo
        hidSubClass.Value = SubClass

        'NAK 6/3/2011:  Trimmed input to remove leading/trailing spaces.
        Dim UPC As String = Trim(srchUPC.Text)
        If UPC.Trim.Length > 1 AndAlso UPC.Length < 14 Then
            UPC = UPC.PadLeft(14, "0")
        End If
        Dim VPN As String = Trim(srchVPN.Text)
        Dim SKU As String = Trim(srchSKU.Text)
        Dim itemTypeAttr As String = Trim(srchItemTypeAttr.SelectedValue)
        Dim stockCat As String = Trim(srchStockCat.SelectedValue)
        Dim itemDesc As String = Trim(srchItemDesc.Text)
        Dim QRN As String = Trim(srchQRN.Text)

        If txtVendor.Length = 0 Then txtVendor = "0"
        If Not IsNumeric(txtVendor) Then
            ShowMsg("Invalid Vendor Number entered.")
            divResults.Visible = False
            btnAddRecsToBatch.Style.Add("display", "none")  'Enabled = False
            Exit Sub
        End If
        Dim vendorNo As Integer = CInt(txtVendor)

        If vendorNo > 0 OrElse deptNo > 0 OrElse UPC.Length > 0 OrElse VPN.Length > 0 OrElse itemDesc.Length > 0 OrElse SKU.Length > 0 _
            OrElse itemTypeAttr.Length > 0 OrElse stockCat.Length > 0 OrElse QRN.Length > 0 Then

            divResults.Visible = True
            ShowMsg("")
            If BatchRec.PackType = "DP" Then
                lblSearchType.Text = "Special Displayer Pack (DP) Search Rules In Use"
            ElseIf BatchRec.PackType = "SB" Then
                lblSearchType.Text = "Special Sellable Bundle Search Rules In Use"
            ElseIf BatchRec.PackType = "D" Then
                lblSearchType.Text = "Special Displayer Search Rules In Use"
            Else
                lblSearchType.Text = ""
            End If
            PopulateSearchGrid(vendorNo, deptNo, ClassNo, SubClass, VPN, SKU, itemDesc, UPC, stockCat, itemTypeAttr, BatchRec.PackType, BatchRec.PackSKU, QRN, , False, True)
            If BatchesData.SearchSKURecsCount > 0 Then
                btnAddRecsToBatch.Style.Add("display", "inline")  'Enabled = True
            Else
                btnAddRecsToBatch.Style.Add("display", "none")  'Enabled = False
            End If
            If srchVendor.Text.Length > 0 AndAlso IsNumeric(srchVendor.Text) Then
                Dim objData As New Data.BatchData()
                vendorName.Text = objData.GetVendorName(srchVendor.Text)
                objData = Nothing
            End If

        Else
            divResults.Visible = False
            ShowMsg("Please select at least one search option.")
            btnAddRecsToBatch.Style.Add("display", "none")  'Enabled = False
        End If

    End Sub

    Protected Sub btnAddRecsToBatch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddRecsToBatch.Click
        If SearchType = "IM" Then
            AddRecsToIMBatch()
        Else
            AddRecsToNIBatch()
        End If
    End Sub

    ' Add records to a New Item Batch
    Private Sub AddRecsToNIBatch()
        Dim grid As GridView = gvSearch, chkbox As CheckBox, hdnfield As HiddenField, isPack As Boolean = False, errorMsg As String = ""
        Dim itemsAdded As Integer = 0, itemsFound As Integer = 0, OK As Boolean
        Dim HeaderID As Long = -1
        HeaderID = Data.ItemDetail.GetItemHeaderForBatch(BatchRec.ID, BatchRec.BatchTypeID)
        If HeaderID <= 0 Then
            ShowMsg(" Unable to get Header Info to add new records.  Contact Support")
            Exit Sub
        End If

        For Each row As GridViewRow In grid.Rows
            If row.RowType = DataControlRowType.DataRow Then
                chkbox = row.FindControl("chkAddRec")
                If chkbox IsNot Nothing AndAlso chkbox.Checked = True AndAlso chkbox.Enabled = True Then    ' New Item checked
                    itemsFound += 1
                    hdnfield = row.FindControl("hdnIsPackParent")
                    isPack = CType(hdnfield.Value, Boolean)
                    If isPack Then
                        errorMsg = " Displayer Batch cannot have additional D/DP SKUs added to the batch"
                        Exit For
                    End If
                    hdnfield = row.FindControl("hdnSKUNo")
                    If BatchRec.BatchTypeID = 1 Then
                        Dim record = New Models.ItemRecord
                        record.MichaelsSKU = hdnfield.Value
                        record.ValidExistingSKU = True
                        record.ItemHeaderID = HeaderID
                        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                        Dim saveID As Long = objMichaels.SaveRecord(record, Session(cUSERID))
                        objMichaels = Nothing
                        If saveID > 0 Then
                            itemsAdded += 1
                            OK = Data.BatchData.UpdateNIFromIM(BatchID, saveID)
                            If Not OK Then
                                errorMsg = String.Format(" Item {0} added but could not be updated from Item Master", record.MichaelsSKU)
                                Exit For
                            End If
                        Else
                            errorMsg = String.Format("Unable to Save Domestic Item Record for item: {0}", record.MichaelsSKU)
                            Exit For
                        End If
                    Else
                        Dim record = New Models.ImportItemRecord
                        record.MichaelsSKU = hdnfield.Value
                        record.ValidExistingSKU = True
                        record.Batch_ID = BatchID
                        record.ParentID = HeaderID
                        record.DateSubmitted = Now.Date
                        record.VendorNumber = BatchRec.VendorNumber
                        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
                        Dim saveID As Long = objMichaels.SaveRecord(record, Session(cUSERID), True, "Created", String.Empty)
                        If saveID > 0 Then
                            OK = Data.BatchData.UpdateNIFromIM(BatchID, saveID)
                            If Not OK Then
                                errorMsg = String.Format(" Item {0} added but could not be updated from Item Master", record.MichaelsSKU)
                                Exit For
                            End If
                        Else
                            errorMsg = String.Format(" Unable to Save Import Item Record for item: {0}", record.MichaelsSKU)
                            Exit For
                        End If
                        itemsAdded += 1
                    End If
                End If
            End If
        Next

        If itemsAdded >= 0 Then
            SetControls(BatchRec.VendorNumber)     ' Since records have been saved to a batch, make sure the controls reflect that
            SearchRecs()               ' reload search with new parms
            If itemsFound = itemsAdded Then
                If errorMsg.Length > 0 Then
                    ShowMsg(String.Format("All Records added to Batch: {0}. ", BatchID) + errorMsg)
                Else
                    ShowMsg(String.Format("All Records added to Batch: {0}.", BatchID), "I")
                End If
            Else
                If errorMsg.Length > 0 Then
                    ShowMsg(String.Format("{0} New Items added to Batch: {1}. ", itemsAdded, BatchID) + errorMsg)
                Else
                    ShowMsg(String.Format("{0} New Items added to Batch: {1}.", itemsAdded, BatchID))
                End If
            End If
            RefreshList()
        End If

    End Sub

    Private Sub AddRecsToIMBatch()
        ' Scan for records to add to batch.
        ' If BatchID is 0 then we will need to create a new batch using info in the item
        ' Verify that all records checked match the same dept, vendor, stock cat and item type attr.
        Dim grid As GridView = gvSearch, chkbox As CheckBox, hdnfield As HiddenField
        Dim ItemRecs As List(Of Models.ItemMaintItem) = New List(Of Models.ItemMaintItem)
        Dim record As Models.ItemMaintItem
        Dim RecsSaved As Integer
        Dim objData As New Data.BatchData()
        Dim potentialPackType As String, potentialPackSKU As String, currentPackSKU As String

        ' Its a new batch if the Batch count = 0
        NewBatch = (objData.GetIMBatchCount(BatchID) = 0)

        Dim curDept As Integer = 0, curVendor As Integer = 0, curStock As String = String.Empty, curItemTypeAttr As String = String.Empty
        Dim recsOK As Boolean = True, DDPRule As Boolean = True
        Dim DDPCount As Integer = 0, PackType As String
        Dim depSKUCount As Integer = 0, isPack As Boolean = False
        Dim errorMsg As String = String.Empty

        ' Get Batch infor for existing Batch
        If BatchID > 0 Then
            If BatchRec.ID > 0 Then
                PackType = UCase(BatchRec.PackType)
                If PackType = "" Then PackType = "R"
            Else
                ShowMsg("Unable to get Batch info for Batch: " & CStr(BatchID))
                Exit Sub
            End If
        Else
            PackType = "R"  ' default
        End If
        potentialPackType = PackType
        potentialPackSKU = ""

        For Each row As GridViewRow In grid.Rows
            If row.RowType = DataControlRowType.DataRow Then
                chkbox = row.FindControl("chkAddRec")
                If chkbox IsNot Nothing AndAlso chkbox.Checked = True AndAlso chkbox.Enabled = True Then    ' New Item checked

                    ' If new Batch then make sure all the records have same deptNo, VendorNumber, StockCat and ItemTypeAttr
                    ' Not needed on existing batch as search is limited to this set of recs
                    If BatchID = 0 OrElse NewBatch Then ' Perform a search of checks when the batch has not been created or its new
                        hdnfield = row.FindControl("hdnDeptNo")
                        If curDept = 0 Then
                            curDept = hdnfield.Value
                        ElseIf curDept <> hdnfield.Value Then   ' More than 1 dept found in set. Cause save to fail
                            recsOK = False
                            Exit For
                        End If

                        hdnfield = row.FindControl("hdnVendor")
                        If curVendor = 0 Then
                            curVendor = hdnfield.Value
                        ElseIf curVendor <> hdnfield.Value Then ' More than 1 vendor in set. Cause save to fail
                            recsOK = False
                            Exit For
                        End If

                        hdnfield = row.FindControl("hdnStockCat")
                        If curStock = String.Empty Then
                            curStock = hdnfield.Value
                        ElseIf curStock <> hdnfield.Value Then  ' More than 1 Sotck Cat in set. Cause save to fail
                            recsOK = False
                            Exit For
                        End If

                        hdnfield = row.FindControl("hdnItemTypeAttr")
                        If curItemTypeAttr = String.Empty Then
                            curItemTypeAttr = hdnfield.Value
                        ElseIf curItemTypeAttr <> hdnfield.Value Then  ' More than 1 Item Type Attr in set. Cause save to fail
                            recsOK = False
                            Exit For
                        End If

                        hdnfield = row.FindControl("hdnIsPackParent")
                        isPack = CType(hdnfield.Value, Boolean)
                        If isPack Then
                            hdnfield = row.FindControl("hdnItemType")
                            PackType = hdnfield.Value
                            DDPCount += 1
                            If DDPCount > 1 Then     ' More than one D/DP record selected. Cause Save to fail
                                DDPRule = False
                                Exit For
                            End If
                            potentialPackType = PackType    ' either D or DP
                            hdnfield = row.FindControl("hdnSKUNo")
                            potentialPackSKU = hdnfield.Value
                        End If

                        ' Rules for Records selected associated with a D/DP Batch
                    ElseIf BatchRec.IsPack() Then
                        'hdnfield = row.FindControl("hdnItemStatus")
                        'If UCase(hdnfield.Value) <> "A" Then
                        '    errorMsg = "Inactive Records cannot be added to a Displayer Batch"
                        '    Exit For
                        'End If
                        hdnfield = row.FindControl("hdnIsPackParent")
                        isPack = CType(hdnfield.Value, Boolean)
                        If isPack Then
                            errorMsg = "Displayer Batch cannot have additional D/DP SKUs added to the batch"
                            Exit For
                        End If
                    End If

                    record = New Models.ItemMaintItem
                    record.BatchID = BatchID
                    hdnfield = row.FindControl("hdnSKUNo")
                    record.SKU = hdnfield.Value
                    hdnfield = row.FindControl("hdnSKUID")
                    record.SKUID = hdnfield.Value
                    hdnfield = row.FindControl("hdnVendor")
                    record.VendorNumber = hdnfield.Value
                    hdnfield = row.FindControl("hdnIndEditable")
                    record.IsIndEditable = CType(hdnfield.Value, Boolean)

                    hdnfield = row.FindControl("hdnPackSKU")
                    currentPackSKU = hdnfield.Value
                    If Not record.IsIndEditable AndAlso currentPackSKU <> BatchRec.PackSKU Then
                        depSKUCount += 1
                    End If

                    record.CreatedUserID = Session(cUSERID)
                    record.Enabled = 1
                    record.IsValid = -1
                    ItemRecs.Add(record)
                End If
            End If
        Next

        If BatchID > 0 AndAlso DDPCount > 0 AndAlso Not NewBatch Then
            ItemRecs.Clear()
            ShowMsg("D/DP Items cannot be added to an existing Batch.")
        End If

        If BatchID > 0 AndAlso DDPCount = 0 AndAlso Not NewBatch AndAlso ItemRecs.Count > 0 AndAlso BatchRec.PackType = "DP" AndAlso depSKUCount > 0 Then
            ShowMsg("DP Component SKUs cannot be added to another DisplayerPack.")
            Exit Sub
        End If

        If Not recsOK Then
            ItemRecs.Clear()
            ShowMsg("All Items in the Batch need to have the same Department Number, Vendor Number, Stock Category, and Item Type Attribute.")
            Exit Sub
        End If

        If Not DDPRule OrElse (DDPCount = 1 And ItemRecs.Count > 1) Then
            ItemRecs.Clear()
            ShowMsg("When adding a Displayer or Displayer Pack Item, only one record can be selected and it must be the D/DP SKU record.")
            Exit Sub
        End If

        If depSKUCount > 0 And PackType = "R" Then
            ItemRecs.Clear()
            ShowMsg("Displayer Pack Only SKUS were selected. To Edit these records, edit the Displayer Pack SKU.")
            Exit Sub
        End If

        If errorMsg.Length > 0 Then
            ItemRecs.Clear()
            ShowMsg(errorMsg)
            Exit Sub
        End If

        If gvSearch.Rows.Count > 0 And ItemRecs.Count = 0 Then
            ShowMsg("Please select at least one item to add to the batch.")
            Exit Sub
        End If

        ' If Batch not created or is Empty then Create / update batch info
        If (BatchID = 0 OrElse NewBatch) And ItemRecs.Count > 0 Then
            BatchRec.PackType = potentialPackType
            BatchRec.PackSKU = potentialPackSKU
            If BatchRec.PackType = "" Then BatchRec.PackType = "R"
            If BatchID = 0 Then
                If BatchRec.PackType <> "R" Then    ' Make sure all children are avail before creating batch
                    Dim packMsg As String
                    packMsg = Data.MaintItemMasterData.PackChildrenAvailable(potentialPackSKU, potentialPackType, curVendor)
                    If packMsg.Length > 0 Then
                        ShowMsg("Unable to Create Batch. " + packMsg)
                        Exit Sub
                    End If
                End If
                Dim vendorName As String = objData.GetVendorName(curVendor)
                objData = Nothing
                BatchRec.WorkflowID = WorkflowType.ItemMaint
                BatchRec.FinelineDeptID = curDept
                BatchRec.VendorNumber = curVendor
                BatchRec.VendorName = vendorName
                BatchRec.StockCategory = curStock
                BatchRec.ItemTypeAttribute = curItemTypeAttr
                BatchID = CreateBatch(WorkflowType.ItemMaint, curDept, curVendor, vendorName, Session(cUSERID), curStock, curItemTypeAttr, BatchRec.PackType, BatchRec.PackSKU)

                If BatchID <= 0 Then
                    If BatchID = -99 Then
                        ShowMsg("Unable to Create Batch. Vendor does not have a valid Vendor Type (Domestic / Import).")
                    Else
                        ShowMsg("Unable to Create Batch. Code Returned: " & BatchID)
                    End If
                    Exit Sub
                End If

                Session(cBATCHID) = BatchID
                LoadBatchInfo()     ' Update Batch info
            Else
                BatchID = UpdateBatch(BatchRec, Session(cUSERID))
                If BatchID < 0 Then
                    ShowMsg("Unable to Update Batch record for Batch: " & BatchRec.ID.ToString)
                    Exit Sub
                End If
                'hidEmptyBatchCreated.Value = "false"
            End If

            ' Now set Records' batchID
            Dim count As Integer = ItemRecs.Count - 1
            For i As Integer = 0 To count
                ItemRecs(i).BatchID = BatchID
            Next

            If PackType <> "R" Then     ' Add this D/DP rec and all children to batch
                Dim procResult As String
                procResult = Data.MaintItemMasterData.AddChildrenToIMBatch(ItemRecs, PackType, BatchRec.VendorNumber)   ' call routine to add item to batch and then add Children
                Dim aProcResult = procResult.Split("|")
                SetControls(curVendor)     ' Since records have been saved to a batch, make sure the controls reflect that
                SearchRecs()               ' reload search with new parms
                Try
                    Select Case aProcResult(0)
                        Case "-1"
                            ShowMsg("Error during creation of Pack Item Batch. Invalid number of Pack Items selected for Save")
                        Case "-2"
                            ShowMsg(String.Format("Error during creation of Pack Item Batch. Child Item: {0} is a member of Batch: {1}", aProcResult(1), aProcResult(2)))
                        Case "-3"
                            ShowMsg(String.Format("Error during creation of Pack Item Batch. Not all Child SKU records saved. Children Found: {0} - Children Saved: {1}", aProcResult(1), aProcResult(2)))
                        Case "-4"
                            ShowMsg("Error during creation of Pack Item Batch. Could not add Pack Record to Batch")
                        Case "1"
                            ShowMsg("Pack Item Batch Saved: Total Records added to Batch: " & aProcResult(1), "I")
                        Case Else
                            ShowMsg("Unknown Error occurred during Pack Item Save. Error Code: " & procResult)
                    End Select
                Catch ex As Exception
                End Try

            Else ' Save list of regular items in batch
                RecsSaved = Data.MaintItemMasterData.SaveItemMaintHeaderRecs(ItemRecs)
                If RecsSaved >= 0 Then
                    SetControls(curVendor)     ' Since records have been saved to a batch, make sure the controls reflect that
                    SearchRecs()               ' reload search with new parms
                    If ItemRecs.Count = RecsSaved Then
                        ShowMsg(String.Format("All Records added to Batch: {0}", BatchID), "I")
                    Else
                        ShowMsg(String.Format("{0} New Items added to Batch: {1}", RecsSaved, BatchID))
                    End If
                Else
                    ShowMsg("Error occurred while saving items to batch")
                End If
            End If
            'If BatchRec.IsPack() Then ItemMaintHelper.CalculateDPBatchParent(BatchRec.ID, True, True)
            RefreshList()

            ' ===========================================
        Else    ' Batch already Exists
            If BatchRec.ID > 0 Then
                PackType = (UCase(BatchRec.PackType))
            Else
                ShowMsg("Error occurred getting Batch info. Save Canceled.")
                ItemRecs.Clear()
                Exit Sub
            End If

            ' make sure existing bathes that are not Pack are regular
            If BatchRec.PackType = "" Then
                BatchRec.PackType = "R"
                BatchID = UpdateBatch(BatchRec, Session(cUSERID))
                If BatchID < 0 Then
                    ShowMsg("Unable to Update Batch record for Batch: " & BatchRec.ID.ToString)
                    Exit Sub
                End If
            End If

            RecsSaved = Data.MaintItemMasterData.SaveItemMaintHeaderRecs(ItemRecs)
            If RecsSaved >= 0 Then
                SetControls(curVendor)     ' Since records have been saved to a batch, make sure the controls reflect that
                SearchRecs()               ' reload search with new parms
                If ItemRecs.Count = RecsSaved Then
                    ShowMsg(String.Format("All Records added to Batch: {0}", BatchID), "I")
                Else
                    ShowMsg(String.Format("{0} New Items added to Batch: {1}", RecsSaved, BatchID))
                End If
                If BatchRec.IsPack() Then ItemMaintHelper.CalculateDPBatchParent(BatchRec.ID, True, True)
                RefreshList()
            Else
                ShowMsg("Error occurred while saving items to batch")
            End If
        End If

    End Sub

    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClose.Click
        'Response.Redirect(String.Format("closeform.aspx?r={0}", IIf(RefreshGrid, "1", "0")))
        Response.Redirect("closeform.aspx?r=0") ' Parent refreshes 
    End Sub

    ' Set flag to tell parent to refresh on page close
    Public Sub RefreshList()
        hidRefreshParent.Value = 1
    End Sub


    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        Dim i As Int16 = 1
    End Sub
End Class

