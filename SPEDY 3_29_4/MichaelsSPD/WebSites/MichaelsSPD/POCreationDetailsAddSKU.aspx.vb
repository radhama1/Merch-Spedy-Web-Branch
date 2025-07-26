
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Helper = NovaLibra.Common.Utilities.DataHelper
Imports Data = NovaLibra.Coral.Data.Michaels
Imports PagingFiltering = NovaLibra.Common.Utilities.PaginationXML

Imports NovaLibra.Common.Utilities
Imports System.Collections.Generic
Imports WebConstants

Partial Public Class _POCreationDetailsAddSKU
    Inherits MichaelsBasePage

#Region "Properties and Constants"

    'GENERAL
    Const cPOCREATIONID As String = "POCREATIONADDSKU_POID"

    'PAGING
    Const cPAGINGSKUPERPAGE As String = "POCREATIONADDSKU_SKUPERPAGE"
    Const cPAGINGCURPAGE As String = "POCREATIONADDSKU_CURPAGE"
    Const cPAGINGTOTALPAGES As String = "POCREATIONADDSKU_TOTALPAGES"
    Const cPAGINGSTARTROW As String = "POCREATIONADDSKU_STARTROW"
    Const cPAGINGTOTALROWS As String = "POCREATIONADDSKU_TOTALROWS"

    'SORTING
    Const cSORTINGCURSORTCOL As String = "POCREATIONADDSKU_CURSORTCOL"
    Const cSORTINGCURSORTDIR As String = "POCREATIONADDSKU_CURSORTDIR"

    'SEARCH
    Const cPOCURXMLSEARCHFILTER As String = "POCREATIONADDSKU_CURXMLSEARCHFILTERSTRING"

#End Region

    Dim poCreationRec As Models.POCreationRecord
    Dim poCreationCacheRec As Models.POCreationCacheRecord

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Check Session
        SecurityCheckRedirect()

        'Clear Messages Displayed To User
        ShowMsg("")

        'Load PO Creation Record
        If Not IsPostBack Then
            Session(cPOCREATIONID) = Helper.SmartValue(Request("POID"), "CLng", 0)
        End If

        LoadPOCreationInfo()

        If Not poCreationRec.ID.HasValue Then

            ShowMsg("PO Info invalid for search.")
            btnSearch.Visible = False

        Else

            If Not IsPostBack Then

                'Initialize Controls
                InitializeControls()

                'Populate Controls
                PopulateControls()

                'Paging
                UpdatePagingInformation()

                'Sorting
                UpdateSortingInformation()

            End If

        End If

    End Sub

    Private Sub LoadPOCreationInfo()

        poCreationRec = Data.POCreationData.GetRecord(Session(cPOCREATIONID))
        poCreationCacheRec = Data.POCreationCacheData.GetRecord(Session("UserID"), Session(cPOCREATIONID))

    End Sub

    Private Sub InitializeControls()

        'Is This A Window
        If Helper.SmartValue(LCase(Request("w")), "CStr", "y") = "y" Then
            btnClose.Visible = True
            pageheader.Style.Add("display", "none")
            hidWindowed.Value = "1"
        Else
            pageheader.Style.Add("display", "inline")
            btnClose.Visible = False
            hidWindowed.Value = "0"
        End If

        btnAddRecs.Style.Add("display", "none")
        srchClass.Items.Insert(0, New ListItem("Select Department", "-1"))
        srchSubClass.Items.Insert(0, New ListItem("Select Class", "-1"))
        srchDept.Attributes.Add("onchange", "GetClass();")
        srchClass.Attributes.Add("onchange", "GetSubClass();")
        srchUPC.Attributes.Add("onchange", "validateUPC();")
        btnSearch.Attributes.Add("onmouseover", "buttonHiLight(1);")
        btnSearch.Attributes.Add("onmouseout", "buttonHiLight(0);")
        btnReset.Attributes.Add("onmouseover", "buttonHiLight(1);")
        btnReset.Attributes.Add("onmouseout", "buttonHiLight(0);")
        srchVendor.Enabled = False
        srchVendor.CssClass = "calculatedField textBoxPad"

        Session.Contents.Remove(cPOCURXMLSEARCHFILTER)

    End Sub

    Private Sub PopulateControls()

        hidClass.Value = ""
        hidSubClass.Value = ""
        hidLockClass.Value = ""

        lblBatchNumber.Text = poCreationRec.BatchNumber

        If poCreationRec.VendorNumber > 0 Then

            srchVendor.Text = poCreationRec.VendorNumber
            vendorName.Text = poCreationRec.VendorName

            Dim deptNumber As Integer = poCreationCacheRec.PODepartmentID.GetValueOrDefault(0)
            Dim seasonalBasic As String = Helper.SmartValue(poCreationRec.BasicSeasonal, "CStr", "")

            Dim enableITA As Boolean = False
            ' seasonalBasic = "" OrElse poCreationRec.POSpecialID.GetValueOrDefault(0) = Models.POCreationRecord.POSpecial.Test
            If ((seasonalBasic = "B" Or seasonalBasic = "")) Then
                enableITA = True
            End If

            LoadDropdowns(deptNumber, poCreationRec.BatchType, seasonalBasic, deptNumber = 0, True, enableITA)

        Else

            ShowMsg("PO Vendor Info invalid for search.")
            btnSearch.Visible = False

        End If

    End Sub

    Private Sub LoadDropdowns(Optional ByVal deptNo As Integer = 0, Optional ByVal StockCat As String = "", Optional ByVal ItemTypeAttr As String = "", Optional ByVal enableDept As Boolean = True, Optional ByVal enableStockCat As Boolean = True, Optional ByVal enableITA As Boolean = True)

        Dim departments As List(Of Models.DepartmentRecord)
        Dim objData As New Data.DepartmentData
        departments = objData.GetDepartmentsByUserID(Session("UserID"))
        srchDept.DataSource = departments
        srchDept.DataTextField = "DeptDesc"
        srchDept.DataValueField = "Dept"
        srchDept.DataBind()
        srchDept.Items.Insert(0, New ListItem("*  Any Department  *", "0"))
        srchDept.SelectedValue = IIf(deptNo >= 0, deptNo, 0)

        'If deptNo > 0 AndAlso Not enableDept Then
        'srchDept.Enabled = False
        'srchDept.CssClass = "calculatedField"
        'Else
        srchDept.Enabled = True
        srchDept.CssClass = ""
        'End If

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

        'RULE: - basic orders can have any item type except seasonal. Seasonal orders can have basic or seasonal only.
        If ItemTypeAttr = "S" Then
            Dim lvgsSeasonal As New ListValueGroups
            lvgsSeasonal.AddListValue("ITEMTYPEATTRIB", "S", "SEASONAL")
            FormHelper.LoadListFromListValues(srchItemTypeAttr, lvgsSeasonal.GetListValueGroup("ITEMTYPEATTRIB"), True, "* Any Item Type Attr *")
        Else
            lvgs.Remove("ITEMTYPEATTRIB", "S")
            FormHelper.LoadListFromListValues(srchItemTypeAttr, lvgs.GetListValueGroup("ITEMTYPEATTRIB"), True, "* Any Item Type Attr *")
        End If
        srchItemTypeAttr.SelectedValue = ItemTypeAttr
        srchItemTypeAttr.Enabled = True
        srchItemTypeAttr.CssClass = ""

        srchStatus.Items.Add(New ListItem("* Any Status *", ""))
        srchStatus.Items.Add(New ListItem("A", "A"))
        srchStatus.Items.Add(New ListItem("C", "C"))

        'srchItemTypeAttr.SelectedValue = ItemTypeAttr
        'If ItemTypeAttr <> "" AndAlso Not enableITA Then
        '    srchItemTypeAttr.Enabled = False
        '    srchItemTypeAttr.CssClass = "calculatedField"
        'Else
        '    srchItemTypeAttr.Enabled = True
        '    srchItemTypeAttr.CssClass = ""
        'End If

    End Sub

    Private Sub ClearPagingInformation()
        Session(cPAGINGCURPAGE) = 1
        Session(cPAGINGTOTALPAGES) = 0
        Session(cPAGINGSTARTROW) = 1
    End Sub

    Private Sub UpdatePagingInformation()

        'Set Defaults
        If Session(cPAGINGSKUPERPAGE) Is Nothing Then Session(cPAGINGSKUPERPAGE) = BATCH_PAGE_SIZE
        If Session(cPAGINGCURPAGE) Is Nothing Then Session(cPAGINGCURPAGE) = 1
        If Session(cPAGINGTOTALPAGES) Is Nothing Then Session(cPAGINGTOTALPAGES) = 0
        If Session(cPAGINGSTARTROW) Is Nothing Then Session(cPAGINGSTARTROW) = 1
        If Session(cPAGINGTOTALROWS) Is Nothing Then Session(cPAGINGTOTALROWS) = 0

        If Helper.SmartValue(Session(cPAGINGTOTALROWS), "CInt", 0) > 0 Then

            If Helper.SmartValue(Session(cPAGINGSTARTROW), "CInt", 0) > Helper.SmartValue(Session(cPAGINGTOTALROWS), "CInt", 0) Then
                Session(cPAGINGSTARTROW) = 1
            End If

            Session(cPAGINGTOTALPAGES) = Fix(Helper.SmartValue(Session(cPAGINGTOTALROWS), "CInt", 0) / Helper.SmartValue(Session(cPAGINGSKUPERPAGE), "CInt", 0))
            If (Helper.SmartValue(Session(cPAGINGTOTALROWS), "CInt", 0) Mod Helper.SmartValue(Session(cPAGINGSKUPERPAGE), "CInt", 0)) <> 0 Then
                Session(cPAGINGTOTALPAGES) = Helper.SmartValue(Session(cPAGINGTOTALPAGES), "CInt", 0) + 1
            End If

            If Helper.SmartValue(Session(cPAGINGCURPAGE), "CInt", 0) <= 0 OrElse Helper.SmartValue(Session(cPAGINGCURPAGE), "CInt", 0) > Helper.SmartValue(Session(cPAGINGTOTALPAGES), "CInt", 0) Then
                Session(cPAGINGCURPAGE) = 1
            End If

        Else
            ClearPagingInformation()
        End If

    End Sub

    Private Sub UpdateSortingInformation()

        'Set Defaults
        If Session(cSORTINGCURSORTCOL) Is Nothing Then Session(cSORTINGCURSORTCOL) = 0
        If Session(cSORTINGCURSORTDIR) Is Nothing Then Session(cSORTINGCURSORTDIR) = PagingFiltering.SortDirection.Asc

    End Sub

    Protected Sub gvSearch_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvSearch.RowCreated
        If (e.Row.RowType = DataControlRowType.Header) Then
            AddSortGlyph(gvSearch, e.Row, Session(cSORTINGCURSORTCOL), PagingFiltering.GetSortDirectionString(Session(cSORTINGCURSORTDIR)))
        End If
    End Sub

    Protected Sub gvSearch_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvSearch.RowCommand

        Select Case e.CommandName

            Case "Sort"

                'Same Column (Change Direction)
                If Session(cSORTINGCURSORTCOL).ToString() = e.CommandArgument.ToString() Then

                    If Session(cSORTINGCURSORTDIR) = PagingFiltering.SortDirection.Asc Then
                        Session(cSORTINGCURSORTDIR) = PagingFiltering.SortDirection.Desc
                    Else
                        Session(cSORTINGCURSORTDIR) = PagingFiltering.SortDirection.Asc
                    End If

                Else
                    Session(cSORTINGCURSORTCOL) = e.CommandArgument.ToString()
                    Session(cSORTINGCURSORTDIR) = PagingFiltering.SortDirection.Asc
                End If

                'Go To First Item
                Session(cPAGINGCURPAGE) = 1
                Session(cPAGINGSTARTROW) = 1

                PopulateGridView()

            Case "Page"

                Select Case e.CommandArgument.ToString
                    Case "First"
                        Session(cPAGINGCURPAGE) = 1
                        Session(cPAGINGSTARTROW) = 1
                    Case "Prev"
                        If Session(cPAGINGCURPAGE) > 1 Then
                            Session(cPAGINGCURPAGE) -= 1
                            Session(cPAGINGSTARTROW) = Session(cPAGINGSTARTROW) - Session(cPAGINGSKUPERPAGE)
                        End If
                    Case "Next"
                        If Session(cPAGINGCURPAGE) < Session(cPAGINGTOTALPAGES) Then
                            Session(cPAGINGCURPAGE) += 1
                            Session(cPAGINGSTARTROW) = Session(cPAGINGSTARTROW) + Session(cPAGINGSKUPERPAGE)
                        End If
                    Case "Last"
                        Session(cPAGINGCURPAGE) = Session(cPAGINGTOTALPAGES)
                        Session(cPAGINGSTARTROW) = ((Session(cPAGINGTOTALPAGES) - 1) * Session(cPAGINGSKUPERPAGE)) + 1
                End Select

                PopulateGridView()

            Case "PageGo"

                Dim newPageNum As Integer = GoToPage()

                If newPageNum > 0 AndAlso newPageNum <= Session(cPAGINGTOTALPAGES) Then

                    Session(cPAGINGCURPAGE) = newPageNum
                    Session(cPAGINGSTARTROW) = ((Session(cPAGINGCURPAGE) - 1) * Session(cPAGINGSKUPERPAGE)) + 1

                    PopulateGridView()
                Else
                    ShowMsg("Invalid Page Number entered.")
                End If

            Case "PageReset"

                Dim newItemsPerPage As Integer = ItemsPerPage()

                If newItemsPerPage >= 5 AndAlso newItemsPerPage <= 50 Then

                    Session(cPAGINGCURPAGE) = 1
                    Session(cPAGINGSTARTROW) = 1
                    Session(cPAGINGSKUPERPAGE) = newItemsPerPage

                    PopulateGridView()
                Else
                    ShowMsg("Items / Page must be between 5 and 50")
                End If

        End Select

    End Sub

    Private Sub gvSearch_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvSearch.RowDataBound

        Select Case e.Row.RowType

            Case DataControlRowType.Pager

                Dim ctrlPaging As Object

                ctrlPaging = e.Row.FindControl("PagingInformation")
                ctrlPaging.text = String.Format("Page {0} of {1}", Session(cPAGINGCURPAGE), Session(cPAGINGTOTALPAGES))

                ctrlPaging = e.Row.FindControl("lblItemsFound")
                ctrlPaging.text = Session(cPAGINGTOTALROWS).ToString() & " " & ctrlPaging.text

                ctrlPaging = e.Row.FindControl("txtgotopage")
                If Helper.SmartValue(Session(cPAGINGCURPAGE), "CInt", 0) < Helper.SmartValue(Session(cPAGINGTOTALPAGES), "CInt", 0) Then
                    ctrlPaging.text = Helper.SmartValue(Session(cPAGINGCURPAGE), "CInt", 0) + 1
                Else
                    ctrlPaging.text = "1"
                End If

                ctrlPaging = e.Row.FindControl("txtItemPerPage")
                ctrlPaging.text = Helper.SmartValue(Session(cPAGINGSKUPERPAGE), "CInt")

        End Select

    End Sub

    Public Function GoToPage() As Long

        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvSearch.BottomPagerRow
            ctrl = pagerRow.Cells(0).FindControl("txtgotopage")
            If Trim(ctrl.text) <> String.Empty And IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
            End If
        Catch e As Exception
            i = 0
        Finally
        End Try

        Return i

    End Function

    Public Function ItemsPerPage() As Long

        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvSearch.BottomPagerRow
            ctrl = pagerRow.Cells(0).FindControl("txtItemPerPage")
            If Trim(ctrl.text) <> String.Empty And IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
            End If
        Catch e As Exception
            i = 0
        Finally
        End Try

        Return i

    End Function

    Private Sub PopulateGridView(Optional ByVal generateNewSearch As Boolean = False)

        Dim cmd As SqlCommand
        Dim dt As DataTable
		Dim s As POService

        Try
            Dim sql As String = "PO_Creation_Add_SKU_Search"
            Dim dbUtil As New DBUtil(ConnectionString)

            cmd = New SqlCommand()

            Dim xml As New PaginationXML()

            '************************
            'Add Filters
            '************************

            If generateNewSearch OrElse Helper.SmartValue(Session(cPOCURXMLSEARCHFILTER), "CStr", "") = "" Then

                'Vendor
                xml.AddFilterCriteria(0, poCreationRec.VendorNumber)

                'Department
                If srchDept.SelectedValue > 0 Then
                    xml.AddFilterCriteria(1, srchDept.SelectedValue)
                End If

                'Stock Category
                If srchStockCat.SelectedValue <> "" Then
                    xml.AddFilterCriteria(2, srchStockCat.SelectedValue)
                End If

                'Item Type Attribute
                If srchItemTypeAttr.SelectedValue <> "" Then
                    xml.AddFilterCriteria(3, srchItemTypeAttr.SelectedValue)
                End If

                'SKU
                If srchSKU.Text.Trim.Length > 0 Then
                    xml.AddFilterCriteria(4, srchSKU.Text.Trim)
                End If

                'VPN
                If srchVPN.Text.Trim.Length > 0 Then
                    xml.AddFilterCriteria(5, srchVPN.Text.Trim)
                End If

                Dim UPC As String = srchUPC.Text.Trim
                If UPC.Trim.Length > 1 AndAlso UPC.Length < 14 Then
                    UPC = UPC.PadLeft(14, "0")
                End If

                If UPC.Length > 0 Then
                    'UPC
                    xml.AddFilterCriteria(6, poCreationRec.VendorNumber)
                Else
                    'UPC Primary Indicator
                    xml.AddFilterCriteria(11, "1")
                End If

                'Class Num
                Dim ClassNo As String = Helper.SmartValue(Request("srchClass"), "CInt", 0)
                If ClassNo > 0 Then
                    xml.AddFilterCriteria(7, ClassNo)
                End If

                'SubClass Num
                Dim SubClass As String = Helper.SmartValue(Request("srchSubClass"), "CInt", 0)
                If SubClass > 0 Then
                    xml.AddFilterCriteria(8, SubClass)
                End If

                'Item Description
                If srchItemDesc.Text.Trim.Length > 0 Then
                    xml.AddFilterCriteria(9, srchItemDesc.Text.Trim)
                End If

                'SKU Status
                If srchStatus.SelectedValue <> "" Then
                    xml.AddFilterCriteria(12, srchStatus.SelectedValue)
                End If

                Session(cPOCURXMLSEARCHFILTER) = xml.GetFilterInnerXMLStr()

                hidClass.Value = ClassNo
                hidSubClass.Value = SubClass

            Else

                xml.SetFilterInnerXMLStr(Session(cPOCURXMLSEARCHFILTER))

            End If

            '************************
            'Add Sorting
            '************************
            xml.AddSortCriteria(Session(cSORTINGCURSORTCOL), Session(cSORTINGCURSORTDIR))


            cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.VarChar).Value = xml.GetPaginationXML().Replace("'", "''")
            cmd.Parameters.Add("@maxRows", SqlDbType.Int).Value = Helper.SmartValue(Session(cPAGINGSKUPERPAGE), "CInt", -1)
            cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = Helper.SmartValue(Session(cPAGINGSTARTROW), "CInt", 1)
            cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = Helper.SmartValue(Session(cPOCREATIONID), "CLng", 0)
            cmd.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = Helper.SmartValue(Session("UserID"), "CLng", 0)

            cmd.CommandText = sql
            cmd.CommandTimeout = 1800
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Connection = dbUtil.GetSqlConnection()

            dt = dbUtil.GetDataTable(cmd)

            'Update Paging
            If dt.Rows.Count > 0 Then
                Session(cPAGINGTOTALROWS) = Helper.SmartValue(dt.Rows(0)("totRecords"), "CStr", 0)
                Session(cPAGINGSTARTROW) = Helper.SmartValue(dt.Rows(0)("RowNumber"), "CStr", 0)

                btnAddRecs.Style.Add("display", "inline")

            Else
                Session(cPAGINGTOTALROWS) = 0
                btnAddRecs.Style.Add("display", "none")
            End If

            UpdatePagingInformation()

            gvSearch.PageSize = Session(cPAGINGSKUPERPAGE)
            gvSearch.DataSource = dt
            gvSearch.DataBind()

            If gvSearch.Rows.Count > 0 Then
                gvSearch.BottomPagerRow.Visible = True
            End If

        Catch ex As Exception
            Throw ex
        Finally
            If Not cmd Is Nothing Then
                If Not cmd.Connection Is Nothing AndAlso cmd.Connection.State <> ConnectionState.Closed Then
                    cmd.Dispose()
                End If
                cmd = Nothing
            End If
        End Try

    End Sub

    Protected Function GetCheckedStatus(ByVal pPOContainsSKU As Boolean) As String
        Return LCase(pPOContainsSKU.ToString)
    End Function

    Protected Function GetEnabledStatus(ByVal pPOContainsSKU As Boolean) As String
        Return LCase((Not pPOContainsSKU).ToString)
    End Function

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

        ClearPagingInformation()

        PopulateGridView(True)

    End Sub

    Protected Sub btnAddRecs_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddRecs.Click

        If poCreationRec.ID.GetValueOrDefault(0) > 0 AndAlso poCreationRec.VendorNumber.GetValueOrDefault(0) > 0 Then

            Dim itemExistsForPO As Boolean = Data.POCreationData.CacheHasAtLeastOneSKU(poCreationRec.ID, Session("UserID"))

            Dim chkBox As CheckBox
            Dim curSKU As String
            Dim curUPC As String
            Dim curDeptNo As String
            Dim skusAdded As Boolean = False

            'Loop Through Checkboxes
            For Each row As GridViewRow In gvSearch.Rows
                chkBox = row.FindControl("chkAddRec")

                'New Item Checked
                If chkBox IsNot Nothing AndAlso chkBox.Checked = True AndAlso chkBox.Enabled = True Then

                    'Get Check Box Values
                    curSKU = CType(row.FindControl("hdnSKU"), HiddenField).Value
                    curUPC = CType(row.FindControl("hdnUPC"), HiddenField).Value
                    curDeptNo = Helper.SmartValue(CType(row.FindControl("hdnDeptNo"), HiddenField).Value, "CLng", 0)

                    'If no item exists for this PO, set it's Workflow_Department_ID equal to the first item's Department
                    If Not itemExistsForPO AndAlso curDeptNo > 0 Then

                        Data.POCreationCacheData.UpdateWorkflowDepartmentID(poCreationRec.ID, Session("UserID"), curDeptNo)

                        itemExistsForPO = True

                    End If

					'Save
					Dim skuRecord As New Models.POCreationLocationSKURecord
					skuRecord.MichaelsSKU = curSKU
					skuRecord.UPC = curUPC
					Data.POCreationLocationSKUData.AddSKU(poCreationRec.ID, skuRecord, Session("UserID"))

                    skusAdded = True
                End If

            Next

            'Add Text to notify user of added skus
            If (skusAdded) Then
                ShowMsg("Selected SKUs have been added to the Purchase Order")
            End If

            'Update PO Department ID
            Data.POCreationCacheData.UpdatePODepartmentID(poCreationRec.ID, Session("UserID"))

            'Refresh GridView
            PopulateGridView(True)

            'Refresh Parent Window
            RefreshParentPage()

        End If

    End Sub

    Protected Sub RefreshParentPage()
        If hidWindowed.Value = "1" Then
            hidRefreshParent.Value = "1"
        End If
    End Sub

    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnClose.Click
		Response.Redirect("closeform.aspx?r=0")	' Parent refreshes 
    End Sub

    Protected Sub gvSearch_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvSearch.PageIndexChanged

    End Sub

    Protected Sub gvSearch_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvSearch.PageIndexChanging

    End Sub

    Protected Sub gvSearch_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gvSearch.Sorting

    End Sub

    Protected Sub gvSearch_Sorted(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvSearch.Sorted

    End Sub

End Class

