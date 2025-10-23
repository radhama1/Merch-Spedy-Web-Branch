Imports WebConstants
Imports System.Data
Imports NovaLibra.Common.Utilities.DataHelper
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Coral.Data.Michaels
Imports System.Collections.Generic
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Common

Partial Class POMaintDetails
    Inherits MichaelsBasePage

    'PO Information
    Private _poRec As POMaintenanceRecord
    Private _poCacheRec As POMaintenanceCacheRecord
    Private _purchaseOrderID As Integer = 0

    'Field Locking on dynamic fields
    Private _isNotBeforeLocked As Boolean = False
    Private _isNotAfterLocked As Boolean = False
    Private _isInStockLocked As Boolean = False
    Protected _isAddSKULocked As Boolean = False
    Protected _isSKULocked As Boolean = False
    Protected _isUPCLocked As Boolean = False
    Private _isLocationQtyLocked As Boolean = False
    Protected _isOrderedQtyLocked As Boolean = False
    Protected _isUnitCostLocked As Boolean = False
    Protected _isIPLocked As Boolean = False
    Protected _isMasterPackLocked As Boolean = False
    Protected _isCancelledQtyLocked As Boolean = False
    Protected _isCancelCodeLocked As Boolean = False
    Protected _isFormLocked As Boolean = False
    Private _isDetailValid As Boolean = True
    Private _userHasAccess As Boolean = False

    'Validation and Revision variables
    Private _isRevision As Boolean = False
    Private _isValidating As Boolean = False
    Private _revisionNumber As Double
    Private _pRevisionNumber As String
    Private _isCacheReload As Boolean = True

    'SORTING
    Const cSORTCOL As String = "POMAINTDETAIL_CURSORTCOL"
    Const cSORTDIR As String = "POMAINTDETAIL_CURSORTDIR"

    'TIMER
    Const cTIMERLOCK As String = "POMAINTDETAIL_TIMERLOCK"

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Init

        'Check Session
        SecurityCheckRedirect()

        If Not Request.QueryString("POID") Is Nothing Then
            _purchaseOrderID = SmartValue(Request.QueryString("POID"), "CLng", 0)
        End If

        If Not Request.QueryString("RELOAD") Is Nothing Then
            _isCacheReload = IIf(SmartValue(Request.QueryString("RELOAD"), "String", "Y") = "Y", True, False)
        End If

        'Check Permission
        If Not SecurityCheckHasAccess("SPD", "SPD.ACCESS.POMAINT", Session("UserID")) Then
            Response.Redirect("default.aspx")
        End If
        'Check User Access to PO
        _userHasAccess = POMaintenanceData.ValidateUserForPO(_purchaseOrderID, Session(cUSERID))

        'Initialize variables used for GridView sorting
        If Session(cSORTCOL) Is Nothing Then
            Session(cSORTCOL) = "Michaels SKU"
        End If
        If Session(cSORTDIR) Is Nothing Then
            Session(cSORTDIR) = "ASC"
        End If

        'Clear error messages
        ShowMsg("")

        'Determine if PO is an old Revision, and retrieve the appropriate PO record
        _revisionNumber = DataHelper.SmartValue(Request.QueryString("Revision"), "CDbl", 0)
        _pRevisionNumber = DataHelper.SmartValue(Request.QueryString("Revision"), "Cstr", 0)
        Dim currentRevisionNumber = POMaintenanceData.GetCurrentRevision(_purchaseOrderID)
        If (_revisionNumber <> currentRevisionNumber) Then
            _isRevision = True
            _poRec = POMaintenanceData.GetRevisionRecord(_purchaseOrderID, _revisionNumber)
        Else
            _poRec = POMaintenanceData.GetRecord(_purchaseOrderID)
        End If

        'Determine if PO is being validated, and enabled/disable the timer
        If (_poRec.IsValidating) Then
            _isValidating = True
            ValidationTimer.Enabled = True
        Else
            ValidationTimer.Enabled = False
        End If

        'Lock fields, and turn off unused buttons
        ImplementFieldLocking()

        'MUST happen before Validate, becuase ValidateDate uses Cached Date values
        If _isCacheReload Then
            'Create the CACHE in a loop, incase there is a DeadLock issue
            Dim retryCount As Integer = 0
            While retryCount < 5
                Try
                    If (_isRevision) Then
                        'CREATE RevisionCache of SKUs and Stores (this stores data until SAVE is called, making the Cancel button meaningful)
                        POMaintenanceData.CreateRevisionDetailCache(_purchaseOrderID, Session(cUSERID), _revisionNumber)
                    Else
                        'CREATE Cache of SKUs and Stores (this stores data until SAVE is called, making the Cancel button meaningful)
                        POMaintenanceData.CreateDetailCache(_purchaseOrderID, Session(cUSERID))
                    End If
                    Exit While
                Catch ex As SqlClient.SqlException
                    ShowMsg("SQL ERROR: " & ex.Message)
                    retryCount += 1
                Catch ex As Exception
                    Throw ex
                End Try
            End While
        End If

        'Validation must occur before Writing anything to screen (SKU Grid/AllocationDates).  
        'This is because validation may return results that have to then be written to the screen.
        ValidateDetail()

        'Initialize GridView
        InitializeSKUGridView()

        'Load PO Maintenance Cache Data (Perform after Validation, because Validation could update CACHE)
        _poCacheRec = POMaintenanceCacheData.GetRecord(Session(cUSERID), _purchaseOrderID)

    End Sub
    Protected Sub ScriptManager1_AsyncPostBackError(ByVal sender As Object, ByVal e As AsyncPostBackErrorEventArgs) Handles ScriptManager1.AsyncPostBackError
        ShowMsg(e.Exception.Message)
        ScriptManager1.AsyncPostBackErrorMessage = e.Exception.Message
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not IsPostBack Then
            'Hide the Validate button if the WorkflowStage is beyond Validation
            If ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
                btnValidateSKUs.Visible = False
            End If

            InitializeControls()

            'Initialize TimerLock
            Session(cTIMERLOCK) = False
        End If

        'Dynamically Generate Page controls
        GetPurchaseOrderAllocations()
        GetPurchaseOrderTotals()

        'These values are stored in session because of the following:  When a user changes a value the dirty flag is set and the user
        'is presented with a prompt that continuing will save the data.  If they continue, the page is posted to the server for saving
        'but then it is redirected back to itself in order to perform validation.  On the redirect, all hidden values are lost so
        'they are temporarily placed in session and retrieved on the final load
        If Not Session("hdnOpenPopup") Is Nothing Then
            hdnOpenPopup.Value = Session("hdnOpenPopup")
            Session.Contents.Remove("hdnOpenPopup")
        End If
        If Not Session("hdnQueryStrValue") Is Nothing Then
            hdnQueryStrValue.Value = Session("hdnQueryStrValue")
            Session.Contents.Remove("hdnQueryStrValue")
        End If

    End Sub

    Private Sub InitializeControls()
        'Load Workflow Department associated with PO
        lblWorkflowDepartment.Text = POMaintenanceCacheData.GetWorkflowDepartmentName(_poCacheRec.WorkflowDepartmentID)

        'Set PO Department Number and BatchNumber
        PODept.Text = POMaintenanceCacheData.GetPODepartmentName(Session("UserID"), _poRec.ID)
        POClass.Text = DataHelper.SmartValue(_poCacheRec.POClass, "CInt", "")
        POSubclass.Text = DataHelper.SmartValue(_poCacheRec.POSubclass, "CInt", "")
        lblBatchOrderNumber.Text = _poRec.BatchNumber
        lblPurchaseOrderNumber.Text = _poRec.PONumber

        LoadRevisions()
    End Sub

    Private Sub LoadRevisions()

        Dim SQLStr As String = "PO_History_Maintenance_Get_Revisions"
        Using conn As New SqlConnection(ConnectionString)

            Try
                Dim cmd As New SqlCommand(SQLStr, conn)
                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = _purchaseOrderID
                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()
                    While reader.Read()
                        ddlRevisions.Items.Add(reader.Item("RevisionNumber"))
                    End While

                    reader.Close()
                End Using
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not conn Is Nothing AndAlso conn.State = ConnectionState.Open Then
                    conn.Close()
                End If
            End Try
        End Using

        'Set the Revision to the specified Revision Number (if there is one)
        If (ddlRevisions.Items.Count > 0) Then
            If (_isRevision) Then
                ddlRevisions.SelectedValue = _revisionNumber.ToString("0.0")
            Else
                ddlRevisions.Items(0).Selected = True
            End If
        End If

        ddlRevisions.Attributes.Add("onchange", "javascript:RevisionChanged('" & _purchaseOrderID & "', this);")

    End Sub

#Region "Allocation Methods"
    Private Sub GetPurchaseOrderAllocations()
        WriteHeader(POLocationData.GetLocationNameByID(_poRec.POLocationID))

        WriteAllocationsData("Written Date", _poCacheRec.WrittenDate, True)
        WriteAllocationsData("Not Before", _poCacheRec.NotBefore, _isNotBeforeLocked)
        WriteAllocationsData("Not After", _poCacheRec.NotAfter, _isNotAfterLocked)
        WriteAllocationsData("Estimated In Stock Date", _poCacheRec.EstimatedInStockDate, _isInStockLocked)
    End Sub
    Private Sub WriteHeader(ByVal locationName As String)
        Dim tr As New HtmlTableRow
        Dim td As HtmlTableCell
        td = New HtmlTableCell
        td.Attributes.Add("colspan", "2")
        td.Attributes.Add("class", "formLabel subHeading")
        td.Attributes.Add("style", "width:375px; text-align:right;")

        tr.Controls.Add(td)

        td = New HtmlTableCell
        td.Attributes.Add("class", "formLabel subHeading")
        td.Attributes.Add("style", "width: 120px; text-align: center;")
        td.InnerText = POLocationData.GetLocationNameByID(_poRec.POLocationID)
        tr.Controls.Add(td)

        tblAllocationsTotals.Controls.Add(tr)
    End Sub
    Private Sub WriteAllocationsData(ByVal dateName As String, ByVal dateValue As Date?, ByVal isLocked As Boolean)
        Dim tr As New HtmlTableRow
        Dim td As New HtmlTableCell

        'Create row header
        tr = New HtmlTableRow
        td = New HtmlTableCell
        td.Attributes.Add("colspan", "2")
        td.Attributes.Add("class", "formLabel")
        td.Attributes.Add("style", "text-align: right;")
        td.InnerText = dateName & ":"
        tr.Controls.Add(td)
        'Create row data
        td = New HtmlTableCell
        td.Attributes.Add("colspan", "2")
        td.Attributes.Add("class", "formLabel")
        td.Attributes.Add("style", "text-align: center;")
        Dim dateString As String = ""
        If dateValue.HasValue Then
            dateString = dateValue.Value.ToString("M/d/yyyy")
        End If
        'Create Row as text if the field is locked, otherwise create as a textbox
        If isLocked Then
            td.InnerHtml = dateString
        Else
            Dim txt As New TextBox
            txt.ID = "txt" & dateName.Replace(" ", "")
            txt.Attributes.Add("style", "width: 60px; text-align: left;")
            txt.Attributes.Add("onpropertychange", "javascript:setPageAsDirty()")
            txt.Attributes.Add("onKeyDown", "javascript:TabEnter(event);")
            txt.Text = dateString
            td.Controls.Add(txt)

            Dim calendarScript As String = "<script type='text/javascript'>WriteCalendar('" + txt.ID + "');</script>"
            Dim span As New HtmlGenericControl
            span.Attributes.Add("style", "position: relative; left: 3px; top: -1px;")
            span.InnerHtml = calendarScript
            td.Controls.Add(span)

            txt = Nothing
            span = Nothing
        End If

        tr.Controls.Add(td)
        tblAllocationsTotals.Controls.Add(tr)

    End Sub
#End Region

#Region "Totals Grid Methods"
    Private Sub GetPurchaseOrderTotals()
        Dim table As DataTable
        If _isRevision Then
            table = POMaintenanceData.GetPurchaseOrderRevisionTotals(_poRec.ID, _pRevisionNumber)
        Else
            table = POMaintenanceData.GetPurchaseOrderCacheTotals(_poRec.ID, Session(cUSERID))
        End If

        WriteHeader(POLocationData.GetLocationNameByID(_poRec.POLocationID))
        WriteTotalsData(table)
    End Sub
    Private Sub WriteTotalsData(ByVal table As DataTable)
        Dim tr As HtmlTableRow
        Dim td As HtmlTableCell

        For i As Integer = 1 To table.Columns.Count - 1
            tr = New HtmlTableRow
            td = New HtmlTableCell
            'td.Attributes.Add("colspan", "2")
            td.Attributes.Add("class", "formLabel")
            td.Attributes.Add("style", "width:375px; text-align: right;")
            td.InnerText = table.Columns(i).ColumnName & ":"
            tr.Controls.Add(td)
            td = Nothing
            For Each row As DataRow In table.Rows
                td = New HtmlTableCell
                Dim locationName As String = row(0).ToString()
                Dim cellID As String = "cl" & locationName.Replace(" ", "") & i
                td.Attributes.Add("colspan", "2")
                td.Attributes.Add("class", "formLabel")
                td.Attributes.Add("style", "text-align: center;")

                Dim txtCtrl As New TextBox
                txtCtrl.ID = "txt" + locationName.ToString.Replace(" ", "") & i
                txtCtrl.Text = String.Format("{0:C}", DataHelper.SmartValue(row(i), "CDbl", 0.0))
                txtCtrl.MaxLength = 10
                txtCtrl.Attributes.Add("style", "width: 120px; background-color: #dedede; border: 0px; text-align:center;")
                txtCtrl.ReadOnly = True
                td.Controls.Add(txtCtrl)
                tr.Controls.Add(td)
                td = Nothing
            Next
            tblAllocationsTotals.Controls.Add(tr)
        Next
    End Sub
#End Region

    Protected Function GetCheckBoxUrl(ByVal Value As Object) As String

        Dim returnValue As String = "images/valid_null_small.gif"

        If Value IsNot Nothing AndAlso Value IsNot DBNull.Value Then
            If DataHelper.SmartValue(Value, "CBool", False) = True Then
                returnValue = "images/valid_yes_small.gif"
            Else
                returnValue = "images/valid_no_small.gif"
            End If
        Else
            returnValue = "images/valid_null_small.gif"
        End If

        Return returnValue

    End Function

    Protected Function GetSKUUPCs(ByVal sku As String, ByVal upc As String) As DataTable

        Dim dt As DataTable = POMaintenanceData.GetPurchaseOrderUPCsForSKU(_purchaseOrderID, sku, Session(cUSERID))

        If _isValidating = False Then

            For Each dr As DataRow In dt.Rows

                If DataHelper.SmartValue(dr("Is_Default_UPC"), "CBool", False) Then

                    'Add Warning If Default Is Not Selected
                    If DataHelper.SmartValue(upc, "CStr", "") <> DataHelper.SmartValue(dr("UPCVal"), "CStr", "") Then

                        Dim vr As New ValidationRecord()

                        vr.Add("", "<a href='#' onclick=""javascript:SearchBySKU('" & sku & "'); return false;"" > SKU " & sku & ":Primary UPC for this Vendor is not selected</a>", NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)

                        ValidationHelper.AddValidationSummaryErrors(validationDisplay, vr)

                        Exit For

                    End If

                End If

            Next

        End If

        Return dt

    End Function

    Private Sub InitializeGridViewColumns()

        'Only do this on initial page load
        If (_poRec.BatchType = "W") Then
            'Create SKU Column
            Dim skuCol As New BoundField
            skuCol.DataField = "Michaels SKU"
            skuCol.HeaderText = "SKU"
            skuCol.SortExpression = "Michaels SKU"
            skuCol.ItemStyle.Width = Unit.Percentage(5)
            gvSKUs.Columns.Insert(2, skuCol)

        Else
            'Create SKU Column as a link
            Dim skuCol As New HyperLinkField
            skuCol.DataTextField = "Michaels SKU"
            skuCol.HeaderText = "SKU"
            skuCol.NavigateUrl = "#"
            skuCol.SortExpression = "Michaels SKU"
            skuCol.ItemStyle.Width = Unit.Percentage(5)
            gvSKUs.Columns.Insert(2, skuCol)

        End If

        'Create Location Columns
        Dim insertIndex As Integer = 10 'IIf(_poRec.BatchType = "W", 9, 10)
        Dim locationPrefix As String = IIf(_poRec.BatchType = "W", "DC ", "")

        Dim locationQty As New TemplateField
        Dim locationConstant As String = POLocationData.GetLocationConstantByID(_poRec.POLocationID)
        locationQty.ItemTemplate = New MyGridViewTemplate(DataControlRowType.DataRow, "Location_Total_Qty", "Location_Total_Qty", _isLocationQtyLocked)
        locationQty.HeaderText = locationPrefix & locationConstant & "<br/> Qty"
        locationQty.SortExpression = "Location_Total_Qty"
        locationQty.HeaderStyle.CssClass = "gvnumbers"
        locationQty.ItemStyle.CssClass = "gvnumbers"
        locationQty.ItemStyle.HorizontalAlign = HorizontalAlign.Right
        locationQty.ItemStyle.Width = Unit.Percentage(5)
        gvSKUs.Columns.Insert(insertIndex, locationQty)

    End Sub

    Private Sub InitializeSKUGridView()

        'GET SKU Table from CACHE
        Dim skuTable As New DataTable
        skuTable = POMaintenanceSKUData.GetSKUTableByPOID(_poRec.ID, Session(cUSERID))

        'NAK 8/26/2011: If PO is partially received, do not allow the unit cost of the PO to be updated by user
        For Each row As DataRow In skuTable.Rows
            If (DataHelper.SmartValues(row("Received_Qty"), "CInt", False, 0) > 0) Then
                _isUnitCostLocked = True
            End If
        Next

        InitializeGridViewColumns()

        'Sort DataTable used in Grid
        skuTable.DefaultView.Sort = Session(cSORTCOL) & " " & Session(cSORTDIR)

        gvSKUs.DataSource = skuTable
        gvSKUs.DataBind()
    End Sub

    Private Sub SetGridViewSorting(ByVal sortExpression As String)
        'Find the appropriate sort direction
        If Session(cSORTCOL).ToString() = sortExpression Then

            If Session(cSORTDIR) = "ASC" Then
                Session(cSORTDIR) = "DESC"
            Else
                Session(cSORTDIR) = "ASC"
            End If
        Else
            Session(cSORTCOL) = sortExpression
            Session(cSORTDIR) = "ASC"
        End If
    End Sub

    Protected Sub btnEditRevision_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnEditRevision.Click
        Dim previousWorkflowStage As Integer = _poRec.WorkflowStageID

        _poRec.WorkflowStageID = POMaintenanceData.GetInitialWorkflowStageID(_poRec.InitiatorRoleID)
        _poRec.POStatusID = POMaintenanceRecord.Status.Revised
        POMaintenanceData.UpdateRecordBySystem(_poRec, POMaintenanceData.Hydrate.None)

        'Save record for PO Creation in History Stage Durations table
        POMaintenanceData.SaveHistoryStageDuration(_poRec.ID, "REVISION", previousWorkflowStage, _poRec.WorkflowStageID, Session("UserID"))

        Response.Redirect("POMaintDetails.aspx?POID=" & _purchaseOrderID & "&Revision=" & _revisionNumber.ToString("0.0"))
    End Sub

    'RULE:  Cannot remove SKUs on PO Maintenance
    'Private Sub btnRemoveCheckedSKUs_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRemoveCheckedSKUs.Click

    '    For Each row As GridViewRow In gvSKUs.Rows
    '        If row.Cells(0).Controls.Count > 0 Then
    '            Dim removeChkBox As CheckBox = CType(row.Cells(0).Controls(0), CheckBox)
    '            If removeChkBox.Checked Then
    '                Dim sku As String = CType(row.FindControl("lblSKU"), Label).Text
    '                POMaintenanceData.DeleteCheckedSku(_poRec.ID.GetValueOrDefault, sku)
    '            End If
    '        End If
    '    Next

    '    'Update PO Department ID
    '    POMaintenanceData.UpdateCachePODepartmentID(_poRec.ID, Session("UserID"))

    '    'Save Cached information
    '    SaveCache()

    '    'Refresh Page to revalidate 
    '    If Page.ClientQueryString.Contains("RELOAD") Then
    '        Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=Y", "RELOAD=N"))
    '    Else
    '        Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=N")
    '    End If
    'End Sub

    Protected Sub btnCancelChecked_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnCancelChecked.Click

        For i As Integer = 0 To gvSKUs.Rows.Count - 1
            'SAVE SKU DataRows
            Dim skuRow As GridViewRow = gvSKUs.Rows(i)
            If skuRow.RowType = DataControlRowType.DataRow Then
                Dim skuRecord As New POMaintenanceSKURecord
                Dim isChecked As Boolean = CType(skuRow.FindControl("IsChecked"), CheckBox).Checked
                skuRecord.MichaelsSKU = CType(skuRow.FindControl("lblSKU"), Label).Text
                skuRecord.UPC = CType(skuRow.FindControl("ddlUPC"), DropDownList).SelectedValue
                skuRecord.UnitCost = CType(CType(skuRow.FindControl("txtUnitCost"), TextBox).Text, Decimal)
                skuRecord.InnerPack = CType(CType(skuRow.FindControl("txtIP"), TextBox).Text, Integer)
                skuRecord.MasterPack = CType(CType(skuRow.FindControl("txtMC"), TextBox).Text, Integer)
                skuRecord.ReceivedQty = CType(CType(skuRow.FindControl("txtReceivedQty"), TextBox).Text, Integer)
                skuRecord.OrderedQty = CType(CType(skuRow.FindControl("txtOrderQty"), TextBox).Text, Integer)
                skuRecord.CalculatedOrderTotalQty = CType(CType(skuRow.FindControl("txtCalculatedQty"), TextBox).Text, Integer)
                skuRecord.LocationTotalQty = CType(CType(skuRow.Cells(10).Controls(0), TextBox).Text, Integer)

                'SET CancellledQty = OrderedQty - Received Qty if checked, otherwise SAVE specified Cancel Qty
                If (isChecked) Then
                    skuRecord.CancelledQty = IIf((skuRecord.CalculatedOrderTotalQty - skuRecord.ReceivedQty) > 0, (skuRecord.CalculatedOrderTotalQty - skuRecord.ReceivedQty), 0)
                Else
                    skuRecord.CancelledQty = CType(CType(skuRow.FindControl("txtCancelledQty"), TextBox).Text, Integer)
                End If

                'RULE: Default Cancel Code to V, if there is a Cancel Quantity and no cancel code is selected
                skuRecord.CancelCode = CType(skuRow.FindControl("ddlCancelCode"), DropDownList).SelectedItem.Text
                If (skuRecord.CancelledQty > 0 And skuRecord.CancelCode = "-") Then
                    skuRecord.CancelCode = "V"
                End If

                POMaintenanceSKUData.UpdateSKUCACHE(_purchaseOrderID, skuRecord, Session(cUSERID))

                'Update Stores
                If _poRec.BatchType = "D" And isChecked Then
                    POMaintenanceCacheData.UpdateSKUCacheCancelledQtyBySKU(_purchaseOrderID, skuRecord.MichaelsSKU, Session(cUSERID))
                End If

            End If
        Next

        'Recalculate Totals
        POMaintenanceSKUData.UpdateSKUCacheTotalsByPOID(_purchaseOrderID, Session(cUSERID))

        'Refresh Page to revalidate 
        If Page.ClientQueryString.Contains("RELOAD") Then
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=Y", "RELOAD=N"))
        Else
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=N")
        End If
    End Sub

    Protected Sub btnRestoreChecked_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnRestoreChecked.Click
        For i As Integer = 0 To gvSKUs.Rows.Count - 1
            'SAVE SKU DataRows
            Dim skuRow As GridViewRow = gvSKUs.Rows(i)
            If skuRow.RowType = DataControlRowType.DataRow Then
                Dim skuRecord As New POMaintenanceSKURecord
                Dim isChecked As Boolean = CType(skuRow.FindControl("IsChecked"), CheckBox).Checked
                skuRecord.MichaelsSKU = CType(skuRow.FindControl("lblSKU"), Label).Text
                skuRecord.UPC = CType(skuRow.FindControl("ddlUPC"), DropDownList).SelectedValue
                skuRecord.UnitCost = CType(CType(skuRow.FindControl("txtUnitCost"), TextBox).Text, Decimal)
                skuRecord.InnerPack = CType(CType(skuRow.FindControl("txtIP"), TextBox).Text, Integer)
                skuRecord.MasterPack = CType(CType(skuRow.FindControl("txtMC"), TextBox).Text, Integer)
                skuRecord.ReceivedQty = CType(CType(skuRow.FindControl("txtReceivedQty"), TextBox).Text, Integer)
                skuRecord.OrderedQty = CType(CType(skuRow.FindControl("txtOrderQty"), TextBox).Text, Integer)
                skuRecord.CalculatedOrderTotalQty = CType(CType(skuRow.FindControl("txtCalculatedQty"), TextBox).Text, Integer)
                skuRecord.LocationTotalQty = CType(CType(skuRow.Cells(10).Controls(0), TextBox).Text, Integer)

                'SET CancellledQty = 0 if checked, otherwise save specified CancelledQty
                If (isChecked) Then
                    skuRecord.CancelledQty = 0
                    skuRecord.CancelCode = Nothing
                Else
                    skuRecord.CancelledQty = CType(CType(skuRow.FindControl("txtCancelledQty"), TextBox).Text, Integer)
                    'RULE: Default Cancel Code to V, if there is a Cancel Quantity and no cancel code is selected
                    skuRecord.CancelCode = CType(skuRow.FindControl("ddlCancelCode"), DropDownList).SelectedItem.Text
                    If (skuRecord.CancelledQty > 0 And skuRecord.CancelCode = "-") Then
                        skuRecord.CancelCode = "V"
                    End If
                End If

                POMaintenanceSKUData.UpdateSKUCACHE(_purchaseOrderID, skuRecord, Session(cUSERID))

                'Update Stores
                If _poRec.BatchType = "D" And isChecked Then
                    POMaintenanceCacheData.UpdateSKUCacheRestoreCancelledQtyBySKU(_purchaseOrderID, skuRecord.MichaelsSKU, Session(cUSERID))
                End If

            End If
        Next

        'Recalculate Totals
        POMaintenanceSKUData.UpdateSKUCacheTotalsByPOID(_purchaseOrderID, Session(cUSERID))

        'Refresh Page to revalidate 
        If Page.ClientQueryString.Contains("RELOAD") Then
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=Y", "RELOAD=N"))
        Else
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=N")
        End If
    End Sub

    Private Sub btnTotalSyncCheckedSKUs_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnTotalSyncCheckedSKUs.Click
        'Sync Total Qty on checked SKUs
        For i As Integer = 0 To gvSKUs.Rows.Count - 1
            If gvSKUs.Rows(i).RowType = DataControlRowType.DataRow Then
                Dim isChecked As Boolean = CType(gvSKUs.Rows(i).FindControl("IsChecked"), CheckBox).Checked
                If isChecked Then
                    Dim calculatedOrderTotalQty As Integer = CType(DataHelper.SmartValues(CType(gvSKUs.Rows(i).FindControl("txtCalculatedQty"), TextBox).Text, "CInt", False, 0), Integer)
                    CType(gvSKUs.Rows(i).FindControl("txtOrderQty"), TextBox).Text = calculatedOrderTotalQty
                End If
            End If
        Next

        SaveCache()

        'Refresh Page to revalidate 
        If Page.ClientQueryString.Contains("RELOAD") Then
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=Y", "RELOAD=N"))
        Else
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=N")
        End If

    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        Try
            SaveForm()

            'Save In Session Temporarily as Redirect below will clear value
            If hdnOpenPopup.Value.Length > 0 Then
                Session("hdnOpenPopup") = hdnOpenPopup.Value
            End If
            If hdnQueryStrValue.Value.Length > 0 Then
                Session("hdnQueryStrValue") = hdnQueryStrValue.Value
            End If

            'Refresh Page to revalidate 
            If Page.ClientQueryString.Contains("RELOAD") Then
                Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=N", "RELOAD=Y"))
            Else
                Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=Y")
            End If
        Catch ex As Exception
            ShowMsg("Error: " & ex.Message)
        End Try
    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click
        SaveForm()

        'Perform Date Validation on Initial PageLoad and Save Button clicks
        ValidateDetail()
        UpdateValidity()

        Response.Redirect("Default.aspx")
    End Sub

    Protected Sub btnValidateSKUs_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnValidateSKUs.Click
        Try
            'SAVE on each postback
            SaveForm()

            'Perform Validation
            Dim storeCount As Integer = POMaintenanceSKUStoreData.GetByPOID(_poRec.ID).Count
            If (storeCount = 0 And _poRec.BatchType = "D") Then
                ValidateItemsWithWS()
                UpdateValidity()
            Else
                'Submit PO to the Asynchronous Validation Webservice 
                POServiceWrapper.SubmitSKUValidation(_poRec)
            End If

            'Refresh Page to revalidate 
            If Page.ClientQueryString.Contains("RELOAD") Then
                Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=N", "RELOAD=Y"))
            Else
                Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=Y")
            End If

        Catch ex As Exception
            ShowMsg("Error: " & ex.Message)
        End Try
    End Sub

    Protected Sub htnBtnSaveCache_Click(ByVal sender As Object, ByVal e As EventArgs) Handles hdnBtnSaveCache.Click

        SaveCache()

        'Save In Session Temporarily as Redirect below will clear value
        If hdnOpenPopup.Value.Length > 0 Then
            Session("hdnOpenPopup") = hdnOpenPopup.Value
        End If
        If hdnQueryStrValue.Value.Length > 0 Then
            Session("hdnQueryStrValue") = hdnQueryStrValue.Value
        End If

        'Refresh Page to revalidate new cache values, and reload gridview
        If Page.ClientQueryString.Contains("RELOAD") Then
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=Y", "RELOAD=N"))
        Else
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=N")
        End If
    End Sub

    Protected Sub ValidationTimer_Tick(ByVal sender As Object, ByVal e As EventArgs)
        'Set Timer enabled status = isValidating status
        If (_poRec.IsValidating) Then
            ValidationTimer.Enabled = True
        Else
            ValidationTimer.Enabled = False
        End If

    End Sub

    Private Sub GetWSValidationResponse()
        ValidationTimer.Enabled = False
        If Not Session(cTIMERLOCK) Then

            Session(cTIMERLOCK) = True

            Try
                'Retrieve PORecord in case it was updated (by backend validation processing) between Page_Load and now.
                _poRec = POMaintenanceData.GetRecord(_purchaseOrderID)

                'Retrieve WS Results
                Dim jobStatus As String = POServiceWrapper.GetSKUValidation(_poRec)

                If (_poRec.IsValidating) Then
                    ShowMsg("This PO is in Queue to be validated.  Please wait, and results will return shortly.")

                    'TODO: This is only here for troubleshooting.  Remove before going live
                    'ShowMsg(" Job Status: " & jobStatus)
                    ValidationTimer.Enabled = True
                Else
                    'Make sure PO is set as NOT Processing
                    POMaintenanceData.UpdatePOProcessing(_poRec.ID, False)

                    'The po is finished validating.  Reload page.
                    ValidationTimer.Enabled = False

                    'Refresh CACHE, revalidate the PO, and Save CACHE to capture all validity changes
                    POMaintenanceData.CreateDetailCache(_purchaseOrderID, Session(cUSERID))
                    _isValidating = False
                    ValidateDetail()
                    POMaintenanceData.MergeCache(_purchaseOrderID, Session(cUSERID))

                    'Refresh Page to revalidate 
                    If Page.ClientQueryString.Contains("RELOAD") Then
                        Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=N", "RELOAD=Y"))
                    Else
                        Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=Y")
                    End If
                End If

            Catch ex As Exception
                ShowMsg("Error: " & ex.Message)
            End Try

            Session(cTIMERLOCK) = False
        End If
    End Sub

    Private Function GetValidationMessages() As ValidationRecord

        Dim vr As New ValidationRecord()
        'Add Saved Warnings to the Validation Summary
        Dim validationMessages As DataTable
        If _poRec.BatchType = "D" Then
            validationMessages = POMaintenanceData.GetSummarizedValidationMessagesByPOID(_poRec.ID)
        Else
            validationMessages = POMaintenanceData.GetValidationMessagesByPOID(_poRec.ID)
        End If
        For Each row As DataRow In validationMessages.Rows
            vr.Add("", "<a href='#' onclick=""javascript:SearchBySKU('" & row("Michaels_SKU") & "'); return false;"" > SKU " & row("Michaels_SKU") & ":" & row("Message") & "</a>", ValidationRecord.GetValidationRuleSeverityType(row("Severity_Type")))
        Next

        'Update _isDetail valid to take into account saved Webservice Validation errors
        _isDetailValid = _isDetailValid And vr.IsValid

        Return vr
    End Function

    Private Function GetValidationMessagesCount(Optional ByVal severity As NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType = -999) As Integer

        Return POMaintenanceData.ValidationMessagesCountByPOID(_poRec.ID, severity)

    End Function

    Protected Sub SaveCache()
        SaveLocationCache()
        SaveSKUCache()
    End Sub

    Private Sub SaveForm()
        SaveCache()
        'Only save if user has access to the PO
        If _userHasAccess Then
            'Revalidate dates before saving.  This will ensure Is_Date_Warning gets properly recorded
            ValidateDates()
            'RULE:  Allocator wants to see the following changes: IP, MC, Qty, EventCode, SKU/Store Add/Delete
            'RULE:  Planner wants to see anything that impacts a financial change: SKU/STORE Add/Delete and Cost/Qty change
            POMaintenanceCacheData.UpdateAllocPlannerFlags(_purchaseOrderID, Session(cUSERID))
            'MERGE CACHE data with LIVE data
            POMaintenanceData.MergeCache(_poRec.ID, Session(cUSERID))
            'Refresh PO Record after save so record in memory is in sync with what is in the database
            _poRec = POMaintenanceData.GetRecord(_purchaseOrderID)
        End If
    End Sub

    Private Sub SaveLocationCache()
        If tblAllocationsTotals.Rows.Count = 2 Then
            Return
        End If
        For i As Integer = 1 To 4
            For Each cell As HtmlTableCell In tblAllocationsTotals.Rows(i).Cells
                If TypeOf (cell.Controls(0)) Is LiteralControl Then
                    Continue For
                End If
                Dim textControl As TextBox
                textControl = DirectCast(cell.Controls(0), TextBox)
                Dim dateField As String = textControl.ID.Substring(3)

                If IsDate(textControl.Text) Or textControl.Text = "" Then
                    'Set values in _poRec
                    Select Case dateField
                        Case "NotBefore"
                            _poRec.NotBefore = DataHelper.SmartValue(textControl.Text, "CDate", Nothing)
                        Case "NotAfter"
                            _poRec.NotAfter = DataHelper.SmartValue(textControl.Text, "CDate", Nothing)
                        Case "EstimatedInStockDate"
                            _poRec.EstimatedInStockDate = DataHelper.SmartValue(textControl.Text, "CDate", Nothing)
                    End Select
                End If
            Next
        Next

        'Update CACHE with new dates
        POMaintenanceData.UpdateCache(_poRec, Session(cUSERID))
    End Sub

    Private Sub SaveSKUCache()

        For i As Integer = 0 To gvSKUs.Rows.Count - 1
            'SAVE SKU DataRows
            Dim skuRow As GridViewRow = gvSKUs.Rows(i)
            If skuRow.RowType = DataControlRowType.DataRow Then
                Dim skuRecord As New POMaintenanceSKURecord
                skuRecord.MichaelsSKU = CType(skuRow.FindControl("lblSKU"), Label).Text
                skuRecord.UPC = CType(skuRow.FindControl("ddlUPC"), DropDownList).SelectedValue
                skuRecord.UnitCost = CType(DataHelper.SmartValue(CType(skuRow.FindControl("txtUnitCost"), TextBox).Text, "CDbl", 0.0), Decimal)
                skuRecord.InnerPack = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtIP"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.MasterPack = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtMC"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.CancelledQty = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtCancelledQty"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.ReceivedQty = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtReceivedQty"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.OrderedQty = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtOrderQty"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.CalculatedOrderTotalQty = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtCalculatedQty"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.LocationTotalQty = CType(DataHelper.SmartValues(CType(skuRow.Cells(10).Controls(0), TextBox).Text, "CInt", False, 0), Integer)

                'RULE: Default Cancel Code to V, if there is a Cancel Quantity and no cancel code is selected
                skuRecord.CancelCode = CType(skuRow.FindControl("ddlCancelCode"), DropDownList).SelectedItem.Text
                If (skuRecord.CancelledQty > 0 And skuRecord.CancelCode = "-") Then
                    skuRecord.CancelCode = "V"
                End If

                POMaintenanceSKUData.UpdateSKUCACHE(_purchaseOrderID, skuRecord, Session(cUSERID))

            End If
        Next

        POMaintenanceSKUData.UpdateSKUCacheTotalsByPOID(_purchaseOrderID, Session(cUSERID))
    End Sub

    Protected Sub POHeaderLink_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles POHeaderLink.Click
        If Not _isValidating And Not _isRevision Then
            SaveForm()

            ValidateDetail()
            UpdateValidity()
        End If

        Response.Redirect("POMaintHeader.aspx?POID=" + _poRec.ID.ToString() & "&Revision=" & _revisionNumber)
    End Sub

    Private Sub ImplementFieldLocking()

        If _isValidating Or _isRevision Then
            _isFormLocked = True
            _isNotBeforeLocked = True
            _isNotAfterLocked = True
            _isInStockLocked = True
            _isAddSKULocked = True
            _isSKULocked = True
            _isUPCLocked = True
            _isUnitCostLocked = True
            _isIPLocked = True
            _isMasterPackLocked = True
            _isLocationQtyLocked = True
            _isOrderedQtyLocked = True
            _isCancelledQtyLocked = True
            btnUpdate.Enabled = False
            btnUpdateClose.Enabled = False
            btnValidateSKUs.Enabled = False
            btnUpdateCheckedSKUs.Enabled = False
            btnCancelChecked.Enabled = False
            btnRestoreChecked.Enabled = False
            btnTotalSyncCheckedSKUs.Enabled = False

            'Disable "Submit" button
            btnValidateSKUs.Visible = False
        Else

            Dim fl As New NovaLibra.Coral.Data.Michaels.FieldLockingData
            Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = fl.GetFieldLockedControls(AppHelper.GetUserID(), MetadataTable.POMaintenance, _poRec.WorkflowStageID, True)

            For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
                If (col.Permission <> "E") Then
                    'Check to see if any Controls were specified for the Field Locked Column
                    Select Case (col.ColumnName)
                        Case "Not_Before"
                            _isNotBeforeLocked = True
                        Case "Not_After"
                            _isNotAfterLocked = True
                        Case "Estimated_In_Stock_Date"
                            _isInStockLocked = True
                        Case "Michaels_SKU"
                            _isSKULocked = True
                            _isAddSKULocked = True
                        Case "UPC"
                            _isUPCLocked = True
                        Case "Unit_Cost"
                            _isUnitCostLocked = True
                        Case "Inner_Pack"
                            _isIPLocked = True
                        Case "Master_Pack"
                            _isMasterPackLocked = True
                        Case "Location_Total_Qty"
                            _isLocationQtyLocked = True
                        Case "Ordered_Qty"
                            _isOrderedQtyLocked = True
                        Case "Cancelled_Qty"
                            _isCancelledQtyLocked = True
                        Case "Cancel_Code"
                            _isCancelCodeLocked = True
                    End Select
                End If
            Next

            'RULE: Direct orders cannot edit "Location Qty"
            'RULE: Direct orders cannot Add SKUs, or edit Quantities (Ordered or Cancelled).  They can still use the buttons to cancel though.
            If _poRec.BatchType = "D" Then
                _isLocationQtyLocked = True
                '_isSKULocked = True
                _isOrderedQtyLocked = True
                _isCancelledQtyLocked = True
                _isAddSKULocked = True
            End If

            'RULE: Submit Validation is only enabled on Initial and Pack Approval (Allocation, Final Approval) stage types
            Dim wfStageType As Integer = GetStageType(_poRec.WorkflowStageID)
            If wfStageType = WorkflowStageType.Initial Or wfStageType = WorkflowStageType.PackApproval Then
                btnValidateSKUs.Visible = True
            Else
                btnValidateSKUs.Visible = False
            End If

            'RULE: Display Edit button if PO is in a "Completed" workflow stage, and User is the same department as the PO and has the same role as the original originator, and the PO is revisable
            Dim initWFStageID As Integer = POMaintenanceData.GetInitialWorkflowStageID(_poRec.InitiatorRoleID)
            If wfStageType = WorkflowStageType.Completed And _
            POMaintenanceData.ValidateWorkflowAccess(initWFStageID, _poRec.WorkflowDepartmentID, Session("UserID")) And _
            Not (_poRec.IsUnrevisable) Then
                btnEditRevision.Visible = True
            End If

            If _userHasAccess Then
                btnUpdate.Enabled = True
                btnValidateSKUs.Enabled = True
                btnUpdateClose.Enabled = True
                btnUpdateCheckedSKUs.Enabled = Not _isSKULocked
                btnCancelChecked.Enabled = Not _isSKULocked
                btnRestoreChecked.Enabled = Not _isSKULocked
                btnTotalSyncCheckedSKUs.Enabled = Not _isSKULocked
            Else
                _isSKULocked = True
                btnUpdate.Enabled = False
                btnValidateSKUs.Enabled = False
                btnUpdateClose.Enabled = False
                btnUpdateCheckedSKUs.Enabled = False
                btnCancelChecked.Enabled = False
                btnRestoreChecked.Enabled = False
                btnTotalSyncCheckedSKUs.Enabled = False
            End If

        End If
    End Sub

    Private Sub UpdateValidity()

        If (Not _isValidating) And (Not _isRevision) And _userHasAccess Then
            'Get a Validaiton flag indicating if all the Child SKUs and Stores are valid
            Dim isSKUsStoresValid As Boolean? = POMaintenanceData.GetSKUAndStoreValidity(_poRec.ID)
            'Determine Detail validity based off of Child Validity and _Is_Detail_Valid flag
            _poRec.IsDetailValid = _isDetailValid And isSKUsStoresValid
            POMaintenanceData.UpdateRecordBySystem(_poRec, POMaintenanceData.Hydrate.All)
        End If

        'Header Tab
        If Not _poRec.IsHeaderValid.HasValue Then
            POHeaderImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Unknown, True)
        ElseIf _poRec.IsHeaderValid Then
            POHeaderImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Valid, True)
        Else
            POHeaderImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.NotValid, True)
        End If

        'Detail Tab
        If Not _poRec.IsDetailValid.HasValue Then
            PODetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Unknown, True)
        ElseIf _poRec.IsDetailValid Then
            PODetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Valid, True)
        Else
            PODetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.NotValid, True)
        End If
    End Sub

    Private Sub ValidateDetail()

        'Get the WS Response if the PO is currently validating. Otherwise, run validation.
        If _isValidating Then
            GetWSValidationResponse()
        ElseIf Not _isRevision Then

            Dim errorCount As Integer = 0
            Dim warningCount As Integer = 0

            Dim vr As New ValidationRecord()
            'Perform Date, Sku, and Store Validation
            vr.Merge(ValidateDates())
            vr.Merge(ValidateSKUs())

            'Get Counts
            For i As Integer = 0 To vr.Count - 1
                If (vr.Item(i).ErrorSeverity = NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError) Then
                    errorCount += 1
                ElseIf (vr.Item(i).ErrorSeverity = NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning) Then
                    warningCount += 1
                End If
            Next

            'Get saved validation messages
            vr.Merge(GetValidationMessages())

            'As some validation messges are summarized, we need to get the saved message counts from the db
            errorCount += GetValidationMessagesCount(NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
            warningCount += GetValidationMessagesCount(NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)

            'RULE: Display Errors first, then display Warnings in ValidationSummary.
            Dim vrFinal As New ValidationRecord
            'Add All Errors
            For i As Integer = 0 To vr.Count - 1
                If (vr.Item(i).ErrorSeverity = NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError) Then
                    vrFinal.Add(vr.Item(i))
                End If
            Next
            'Add All Warnings
            For i As Integer = 0 To vr.Count - 1
                If (vr.Item(i).ErrorSeverity = NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning) Then
                    vrFinal.Add(vr.Item(i))
                End If
            Next

            lblErrorCount.Text = "Errors: " & errorCount
            lblWarningCount.Text = "Warnings: " & warningCount

            'Display/Hide Counters
            If errorCount > 0 OrElse warningCount > 0 Then
                lblErrorCount.Visible = True
                lblWarningCount.Visible = True
            Else
                lblErrorCount.Visible = False
                lblWarningCount.Visible = False
            End If

            'Add ValidatinRecord to Validation Summary so they appear on the page
            ValidationHelper.AddValidationSummaryErrors(validationDisplay, vrFinal)
        End If

        'Update validity of detail page, and display validity images
        UpdateValidity()
    End Sub

    Private Function ValidateDates() As ValidationRecord

        Dim vr As New ValidationRecord

        If Not ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
            'Perform Webservice validation first, in case dates are returned and saved as part of the Webservice call
            Try
                'Validate PO_Maintenance_Location Records (Allocation Dates)
                vr = POServiceWrapper.ValidateDates(_poRec)

            Catch ex As Exception
                ShowMsg("There was a problem validating the Allocation Dates.  Please contact support.  Error: " & ex.Message)
            End Try

            'Validate PO_Maintenance_Location Records (Allocation Dates)
            vr.Merge(ValidationHelper.ValidateData(_poRec, _poRec.WorkflowStageID, NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.POMaintenanceLocation))

            _isDetailValid = _isDetailValid And vr.IsValid
        End If

        Return vr
    End Function

    Private Sub ValidateItemsWithWS()
        Dim vr As New ValidationRecord
        Try

            If Not ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
                'Validate SKUs using WebService
                POServiceWrapper.ValidateItems(_poRec)
            End If

            _isDetailValid = _isDetailValid And vr.IsValid

        Catch ex As Exception
            ShowMsg("There was a problem validating the SKUs.  Please contact support.  Error: " & ex.Message)
        End Try
    End Sub

    Private Function ValidateSKUs() As ValidationRecord
        Dim vr As New ValidationRecord

        If Not ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
            'Validate PO_Maintenance_Location Records (Allocation Dates)
            vr = ValidationHelper.ValidateData(_poRec, _poRec.WorkflowStageID, NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.POMaintenanceSKU)

        End If

        _isDetailValid = _isDetailValid And vr.IsValid

        Return vr
    End Function

    Private Sub ShowMsg(ByVal strMsg As String)
        'Clear out error messages
        If strMsg.Length = 0 Then
            lblErrorMsg.Text = ""
        End If

        lblErrorMsg.Text = lblErrorMsg.Text & Environment.NewLine & strMsg

    End Sub

    Protected Sub gvSKUs_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles gvSKUs.RowDataBound

        If (e.Row.RowType = DataControlRowType.Header) Then
            'Add Check/Uncheck all javascript to Header checkbox
            If (e.Row.Cells(0).Controls.Count > 2) Then
                Dim headerCheckBox As CheckBox = CType(e.Row.Cells(0).Controls(1), CheckBox)
                headerCheckBox.Attributes.Add("onClick", "javascript:CheckUncheckAll('" & headerCheckBox.ClientID & "');")
            End If
            For i As Integer = 0 To e.Row.Cells.Count - 1
                If (e.Row.Cells(i).Controls.Count > 0) Then
                    If TypeOf e.Row.Cells(i).Controls(0) Is LinkButton Then
                        Dim headerLink As LinkButton = CType(e.Row.Cells(i).Controls(0), LinkButton)
                        headerLink.Attributes.Add("onclick", "return SortSKUData('" & headerLink.ClientID & "');")
                    End If
                End If
            Next
        End If

        'Make the first row bigger to handle height of the fixed Header
        If (e.Row.RowType = DataControlRowType.DataRow) Then

            'If (e.Row.RowIndex = 0) Then
            '    e.Row.Style.Add("height", "60px")
            '    e.Row.Style.Add("vertical-align", "bottom")
            'End If

            'Add Attribute To Checkbox
            If e.Row.FindControl("IsChecked") IsNot Nothing Then
                Dim cb As NovaLibra.Controls.NLCheckBox = CType(e.Row.FindControl("IsChecked"), NovaLibra.Controls.NLCheckBox)
                cb.InputAttributes.Add("group", "SKUCheckbox")
                cb.InputAttributes.Add("sku", DataBinder.Eval(e.Row.DataItem, "Michaels SKU").ToString())
            End If

            'CREATE the SKU Link's "OnClick" attribute (Direct orders only)
            If (_poRec.BatchType = "D") Then
                Dim skuLink As HyperLink = CType(e.Row.Cells(2).Controls(0), HyperLink)
                skuLink.Attributes.Add("onclick", "javascript:ShowPOMaintenanceDetailsSKUStore(" & _purchaseOrderID.ToString & ", '" & skuLink.Text & "', '" & _revisionNumber.ToString("0.0") & "'); return false;")
            End If

            'Make SKUs Added By Receipt Message Read-only
            If Not e.Row.FindControl("lblAddedByRMS") Is Nothing Then
                If SmartValue(CType(e.Row.FindControl("lblAddedByRMS"), Label).Text, "CInt", 0) = 1 Then
                    CType(e.Row.FindControl("IsChecked"), NovaLibra.Controls.NLCheckBox).Visible = False
                    CType(e.Row.FindControl("ddlUPC"), NovaLibra.Controls.NLDropDownList).RenderReadOnly = True
                    CType(e.Row.FindControl("txtOrderQty"), NovaLibra.Controls.NLTextBox).RenderReadOnly = True
                    CType(e.Row.FindControl("txtCalculatedQty"), NovaLibra.Controls.NLTextBox).RenderReadOnly = True
                    CType(e.Row.Cells(10).Controls(0), NovaLibra.Controls.NLTextBox).RenderReadOnly = True
                    CType(e.Row.FindControl("txtCancelledQty"), NovaLibra.Controls.NLTextBox).RenderReadOnly = True
                    CType(e.Row.FindControl("ddlCancelCode"), NovaLibra.Controls.NLDropDownList).RenderReadOnly = True
                    CType(e.Row.FindControl("txtUnitCost"), NovaLibra.Controls.NLTextBox).RenderReadOnly = True
                    CType(e.Row.FindControl("txtIP"), NovaLibra.Controls.NLTextBox).RenderReadOnly = True
                    CType(e.Row.FindControl("txtMC"), NovaLibra.Controls.NLTextBox).RenderReadOnly = True
                End If
            End If

        End If
    End Sub

    Protected Sub gvSKUs_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gvSKUs.Sorting
        SaveCache()

        SetGridViewSorting(e.SortExpression)

        'Refresh Page to revalidate 
        If Page.ClientQueryString.Contains("RELOAD") Then
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString.Replace("RELOAD=Y", "RELOAD=N"))
        Else
            Response.Redirect(Page.AppRelativeVirtualPath & "?" & Page.ClientQueryString & "&RELOAD=N")
        End If
    End Sub

    ' Create a template class to represent a dynamic template column.
    Public Class MyGridViewTemplate
        Implements ITemplate

        Private templateType As DataControlRowType
        Private columnName As String
        Private dataField As String
        Private isDisabled As Boolean

        Sub New(ByVal type As DataControlRowType, ByVal dataFieldName As String, ByVal colname As String, ByVal disabled As Boolean)

            templateType = type
            columnName = colname
            dataField = dataFieldName
            isDisabled = disabled

        End Sub

        Sub InstantiateIn(ByVal container As System.Web.UI.Control) _
          Implements ITemplate.InstantiateIn

            ' Create the content for the different row types.
            Select Case templateType

                Case DataControlRowType.Header
                    ' Create the controls to put in the header
                    ' section and set their properties.
                    Dim lc As New Literal
                    lc.Text = "<B>" & columnName & "</B>"

                    ' Add the controls to the Controls collection
                    ' of the container.
                    container.Controls.Add(lc)

                Case DataControlRowType.DataRow
                    ' Create the controls to put in a data row
                    ' section and set their properties.
                    Dim txtBox As New NovaLibra.Controls.NLTextBox
                    txtBox.MaxLength = 10
                    txtBox.Width = 35
                    txtBox.RenderReadOnly = isDisabled
                    txtBox.Attributes.Add("onChange", "javascript:setPageAsDirty()")

                    ' To support data binding, register the event-handling methods
                    ' to perform the data binding. Each control needs its own event
                    ' handler.
                    AddHandler txtBox.DataBinding, AddressOf TxtBox_DataBinding

                    ' Add the controls to the Controls collection
                    ' of the container.
                    container.Controls.Add(txtBox)

                    ' Insert cases to create the content for the other 
                    ' row types, if desired.

                Case Else

                    ' Insert code to handle unexpected values. 

            End Select

        End Sub

        Private Sub TxtBox_DataBinding(ByVal sender As Object, ByVal e As EventArgs)

            ' Get the Label control to bind the value. The TextBox control
            ' is contained in the object that raised the DataBinding 
            ' event (the sender parameter).
            Dim t As TextBox = CType(sender, TextBox)

            ' Get the GridViewRow object that contains the TextBox control. 
            Dim row As GridViewRow = CType(t.NamingContainer, GridViewRow)

            ' Get the field value from the GridViewRow object and 
            ' assign it to the Text property of the TextBox control.
            t.Text = DataBinder.Eval(row.DataItem, dataField).ToString()

        End Sub

    End Class

End Class
