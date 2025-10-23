Imports WebConstants
Imports System.Data
Imports NovaLibra.Common.Utilities.DataHelper
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Coral.Data.Michaels
Imports System.Collections.Generic
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Common

Partial Class POCreationDetails
	Inherits MichaelsBasePage

	'PO Information
    Protected _poRec As POCreationRecord
    Protected _poCacheRec As poCreationCacheRecord
    Private _purchaseOrderID As Integer = 0

    'Field Locking on dynamic fields
	Private _isNotBeforeLocked As Boolean = False
	Private _isNotAfterLocked As Boolean = False
	Private _isInStockLocked As Boolean = False
	Protected _isSKULocked As Boolean = False
	Protected _isUPCLocked As Boolean = False
	Private _isLocationQtyLocked As Boolean = False
    Protected _isOrderedQtyLocked As Boolean = False
	Protected _isUnitCostLocked As Boolean = False
	Protected _isIPLocked As Boolean = False
	Protected _isMasterPackLocked As Boolean = False
	Private _isWorkflowDeptLocked As Boolean = False
	Protected _isFormLocked As Boolean = False
	Private _userHasAccess As Boolean = False

	'Validation variables
	Private _isValidating As Boolean = False
    Private _isDetailValid As Boolean = True
    Private _isCacheReload As Boolean = True

	'SORTING
	Const cSORTCOL As String = "POCREATEDETAIL_CURSORTCOL"
    Const cSORTDIR As String = "POCREATEDETAIL_CURSORTDIR"

    'TIMER
    Const cTIMERLOCK As String = "POCREATEDETAIL_TIMERLOCK"

	Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Init

        Try
            'Check Session
            SecurityCheckRedirect()

            If Not Request.QueryString("POID") Is Nothing Then
                _purchaseOrderID = SmartValue(Request.QueryString("POID"), "CLng", 0)
            End If

            If Not Request.QueryString("RELOAD") Is Nothing Then
                _isCacheReload = IIf(SmartValue(Request.QueryString("RELOAD"), "String", "Y") = "Y", True, False)
            End If

            'Check Permission
            If Not SecurityCheckHasAccess("SPD", "SPD.ACCESS.PONEW", Session("UserID")) Then
                Response.Redirect("default.aspx")
            End If
            'Check User Access to PO
            _userHasAccess = POCreationData.ValidateUserForPO(_purchaseOrderID, Session("UserID"))

            'Initialize variables used for GridView sorting
            If Session(cSORTCOL) Is Nothing Then
                Session(cSORTCOL) = "Michaels SKU"
            End If
            If Session(cSORTDIR) Is Nothing Then
                Session(cSORTDIR) = "ASC"
            End If

            'Clear error messages
            ShowMsg("")

            'Load PO Creation Data
            _poRec = POCreationData.GetRecord(_purchaseOrderID)

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
                        'CREATE Cache of SKUs and Stores (this stores data until SAVE is called, making the Cancel button meaningful)
                        POCreationData.CreateDetailCache(_purchaseOrderID, Session(cUSERID))
                        Exit While
                    Catch ex As SqlClient.SqlException
                        ShowMsg("SQL ERROR: " & ex.Message)
                        retryCount += 1
                    Catch ex As Exception
                        Throw ex
                    End Try
                End While
            End If

            'Load PO Creation Cache Data
            _poCacheRec = POCreationCacheData.GetRecord(Session(cUSERID), _purchaseOrderID)

            'Validation must occur before Writing anything to screen (SKU Grid/AllocationDates).  
            'This is because validation may return results that have to then be written to the screen.
            ValidateDetail()

            'Initialize GridView
            InitializeSKUGridView()

        Catch ex As Exception
            ShowMsg("Error: " & ex.Message)
        End Try
	End Sub

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try

            If Not IsPostBack Then
                'Show MMS File Link
                If _poRec.BatchType = "D" Then
                    MMSFileDiv.Visible = True
                End If

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

        Catch ex As Exception
            ShowMsg("Error: " & ex.Message)
        End Try
    End Sub

    Private Sub LoadWorkflowDepts()

        'Retrieve WF Information baesd off of User
        Dim dd As New DepartmentData()
        Dim workflowDepartments As List(Of DepartmentRecord) = dd.GetDepartmentsByUserID(Session(cUSERID))
        Dim selectedWFDepartment As Integer = DataHelper.SmartValue(_poCacheRec.WorkflowDepartmentID, "CInt", -99)

        'Populate First Workflow Department Selection
        WorkFlowDept.Items.Insert(0, New ListItem("Select...", "-99"))

        'Populate the rest of Workflow Department
        Dim containsWF As Boolean = False
        For Each objRecord As DepartmentRecord In workflowDepartments
            WorkFlowDept.Items.Add(New ListItem(objRecord.Dept & " - " & objRecord.DeptName, objRecord.Dept))
            If (selectedWFDepartment = objRecord.Dept) Then
                WorkFlowDept.SelectedValue = selectedWFDepartment.ToString()
                containsWF = True
            End If
        Next

        'If the selected WF is not part of the dropdown, add it, and set it as selected (will only happen when user does not have access)
        If Not containsWF And selectedWFDepartment > 0 Then
            Dim selectedWFDeptName As String = dd.GetDepartmentRecord(selectedWFDepartment).DeptName
            WorkFlowDept.Items.Add(New ListItem(selectedWFDepartment & " - " & selectedWFDeptName, selectedWFDepartment))
            WorkFlowDept.SelectedValue = selectedWFDepartment.ToString()
            WorkFlowDept.Enabled = False
        End If

    End Sub

    Private Sub InitializeControls()
        LoadWorkflowDepts()
        PODept.Text = POCreationCacheData.GetPODepartmentName(Session("UserID"), _purchaseOrderID)
        POClass.Text = DataHelper.SmartValue(_poCacheRec.POClass, "CInt", "")
        POSubclass.Text = DataHelper.SmartValue(_poCacheRec.POSubclass, "CInt", "")
        lblBatchOrderNumber.Text = _poRec.BatchNumber

    End Sub

#Region "Allocation Methods"
    Private Sub GetPurchaseOrderAllocations()
        Dim table As DataTable
        table = POCreationData.GetPurchaseOrderAllocations(_purchaseOrderID, Session(cUSERID))

        WriteAllocationsHeader(table)
        WriteAllocationsData(table)

    End Sub
    Private Sub WriteAllocationsHeader(ByVal table As DataTable)
        Dim tr As New HtmlTableRow
        Dim td As HtmlTableCell
        td = New HtmlTableCell

        If (Not _isValidating And Not _isNotBeforeLocked) Then
            'Add Button used to clear dates
            Dim btnClearDates As New Button
            btnClearDates.Text = "Clear All Dates"
            btnClearDates.CssClass = "formButton"
            btnClearDates.Attributes.Add("style", "float:right")
            btnClearDates.Attributes.Add("OnClick", "javascript: ClearDates();return false;")
            td.Controls.Add(btnClearDates)
        End If

        td.Attributes.Add("colspan", "2")
        td.Attributes.Add("class", "formLabel subHeading")
        td.Attributes.Add("style", "text-align:right;")
        tr.Controls.Add(td)
        td = Nothing

        For Each col As DataColumn In table.Columns
            Select Case col.Caption
                Case "DisplayOrder", "UNPValueTypes"
                    Continue For
                Case Else
                    td = New HtmlTableCell
                    td.Attributes.Add("class", "formLabel subHeading")
                    td.Attributes.Add("style", "width: 120px; text-align: center;")
                    td.InnerText = col.Caption
                    tr.Controls.Add(td)
                    td = Nothing
            End Select
        Next
        tblAllocationsTotals.Controls.Add(tr)
    End Sub
    Private Sub WriteAllocationsData(ByVal table As DataTable)
        Dim tr As HtmlTableRow
        Dim td As HtmlTableCell

        For Each row As DataRow In table.Rows

            tr = New HtmlTableRow
            Dim dateCaption As String = String.Empty
            Dim makeCopyButton As Boolean = False


            For i As Integer = 0 To table.Columns.Count - 1
                Dim col As DataColumn = table.Columns(i)
                Select Case col.Caption
                    Case "DisplayOrder"
                        Continue For
                    Case "UNPValueTypes"
                        td = New HtmlTableCell
                        td.Attributes.Add("colspan", "2")
                        td.Attributes.Add("class", "formLabel")
                        td.Attributes.Add("style", "text-align: right;")
                        td.InnerText = row(col.Caption).ToString + ":"
                        tr.Controls.Add(td)
                        td = Nothing
                        dateCaption = row(col.Caption).ToString
                    Case Else
                        td = New HtmlTableCell
                        Dim cellID As String
                        Dim idSuffix As String
                        cellID = "cl" + row(1).ToString.Replace(" ", "")

                        idSuffix = POLocationData.GetLocationIDByName(col.Caption)

                        cellID += idSuffix
                        td.ID = cellID
                        td.Attributes.Add("class", "")
                        td.Attributes.Add("style", "width: 120px; text-align: center;")

                        Dim txtCtrl As New TextBox

                        txtCtrl.ID = "txt|" + row(1).ToString.Replace(" ", "") + "|" + idSuffix
                        If row(col).ToString <> String.Empty Then
                            txtCtrl.Text = String.Format("{0:M/d/yyyy}", Convert.ToDateTime(row(col)))
                        End If
                        txtCtrl.MaxLength = 10
                        Dim allowEdit As Boolean
                        Select Case dateCaption
                            Case "Not Before"
                                allowEdit = Not _isNotAfterLocked
                            Case "Not After"
                                allowEdit = Not _isNotBeforeLocked
                            Case "Estimated In Stock Date"
                                allowEdit = Not _isInStockLocked
                        End Select
                        Dim controlStyle As String
                        Dim calendarScript As String = String.Empty
                        If allowEdit Then
                            controlStyle = "width: 60px; "
                            If dateCaption <> "Written Date" Then
                                calendarScript = "<script type='text/javascript'>WriteCalendar('" + txtCtrl.ID + "');</script>"
                            Else
                                controlStyle += " background-color: #dedede; border: 0px;"
                                txtCtrl.ReadOnly = True
                            End If
                            txtCtrl.Attributes.Add("style", controlStyle)
                            txtCtrl.Attributes.Add("onpropertychange", "javascript:setPageAsDirty()")
                            txtCtrl.Attributes.Add("onKeyDown", "javascript:TabEnter(event);")
                        Else
                            controlStyle = "width: 60px; "
                            controlStyle += " background-color: #dedede; border: 0px;"
                            txtCtrl.ReadOnly = True
                            txtCtrl.Attributes.Add("style", controlStyle)
                        End If
                        td.Controls.Add(txtCtrl)
                        If calendarScript <> String.Empty Then
                            Dim span As New HtmlGenericControl
                            span.Attributes.Add("style", "position: relative; left: 3px; top: -1px;")
                            span.InnerHtml = calendarScript
                            td.Controls.Add(span)
                        End If

                        'CREATE Copy Button
                        If i = 2 And table.Columns.Count > 3 And dateCaption <> "Written Date" And Not _isValidating And Not _isNotBeforeLocked Then
                            Dim btnCopy As New ImageButton
                            btnCopy.CssClass = "formButton"
                            btnCopy.Width = 13
                            btnCopy.Height = 13
                            btnCopy.ImageUrl = "./images/btn_vcr_bot.gif"
                            btnCopy.Attributes.Add("style", "margin-top: 3px; margin-left: 10px; padding: 0px;")
                            btnCopy.Attributes.Add("onClick", "javascript: CopyDates(" & table.Rows.IndexOf(row) + 1 & "); return false;")
                            btnCopy.Attributes.Add("onKeyDown", "javascript:TabEnter(event);")
                            td.Controls.Add(btnCopy)
                        End If

                        tr.Controls.Add(td)
                        td = Nothing
                End Select
            Next
            tblAllocationsTotals.Controls.Add(tr)
        Next
    End Sub
#End Region

#Region "Totals Grid Methods"
    Private Sub GetPurchaseOrderTotals()
        Dim table As DataTable
        table = POCreationData.GetPurchaseOrderCacheTotals(_purchaseOrderID, Session(cUSERID))

        WriteTotalsHeader(table)
        WriteTotalsData(table)

    End Sub
    Private Sub WriteTotalsHeader(ByVal table As DataTable)
        Dim tr As New HtmlTableRow
        Dim td As HtmlTableCell
        td = New HtmlTableCell
        td.Attributes.Add("class", "formLabel subHeading")
        td.Attributes.Add("style", "text-align:right;")

        tr.Controls.Add(td)
        td = Nothing

        'WRITE Total Header
        td = New HtmlTableCell
        td.Attributes.Add("class", "formLabel subHeading")
        td.Attributes.Add("style", "text-align: right; padding-right: 30px;")
        td.InnerText = "Total"
        tr.Controls.Add(td)
        td = Nothing

        For Each row As DataRow In table.Rows
            td = New HtmlTableCell
            td.Attributes.Add("class", "formLabel subHeading")
            td.Attributes.Add("style", "text-align: center;")
            td.InnerText = row(1)
            tr.Controls.Add(td)
            td = Nothing
        Next

        tblAllocationsTotals.Controls.Add(tr)
    End Sub
    Private Sub WriteTotalsData(ByVal table As DataTable)
        Dim tr As HtmlTableRow
        Dim td As HtmlTableCell
        Dim total As Decimal = 0.0

        For i As Integer = 2 To table.Columns.Count - 1
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
                Dim locationName As String = row(1).ToString()
                Dim cellID As String = "cl" & locationName.Replace(" ", "") & i
                td.Attributes.Add("class", "")
                td.Attributes.Add("style", "width: 120px; text-align: center;")

                Dim txtCtrl As New TextBox
                txtCtrl.ID = "txt" + locationName.ToString.Replace(" ", "") & i
                txtCtrl.Text = String.Format("{0:C}", DataHelper.SmartValue(row(i), "CDbl", 0.0))
                txtCtrl.MaxLength = 12
                txtCtrl.Attributes.Add("style", "width: 120px; background-color: #dedede; border: 0px; text-align: center;")
                txtCtrl.ReadOnly = True
                td.Controls.Add(txtCtrl)
                tr.Controls.Add(td)
                td = Nothing

                total = total + DataHelper.SmartValue(row(i), "CDbl", 0)
            Next
            'Add Total Column
            td = New HtmlTableCell
            td.ID = "cltotal" & i
            td.Attributes.Add("class", "")
            td.Attributes.Add("style", "width: 120px; text-align: center;")

            Dim totalTxtCtrl As New TextBox
            totalTxtCtrl.ID = "txttotal" & i
            totalTxtCtrl.Text = String.Format("{0:C}", total)
            totalTxtCtrl.MaxLength = 10
            totalTxtCtrl.Attributes.Add("style", "width: 120px; background-color: #dedede; border: 0px; text-align: right;")
            totalTxtCtrl.ReadOnly = True
            td.Controls.Add(totalTxtCtrl)
            tr.Controls.AddAt(1, td)
            tblAllocationsTotals.Controls.Add(tr)

            total = 0.0
            td = Nothing
            tr = Nothing
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

        Dim dt As DataTable = POCreationData.GetPurchaseOrderUPCsForSKU(_purchaseOrderID, sku, Session(cUSERID))

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

            ''Create Order Qty column using Calculated_Order_Total_Qty
            'Dim orderQty As New TemplateField
            'orderQty.ItemTemplate = New MyGridViewTemplate(DataControlRowType.DataRow, "Calculated_Order_Total_Qty", "Order Qty", _isOrderedQtyLocked)
            'orderQty.HeaderText = "Total Order <br/>Qty"
            'orderQty.SortExpression = "Calculated_Order_Total_Qty"
            'orderQty.HeaderStyle.CssClass = "gvnumbers"
            'orderQty.ItemStyle.CssClass = "gvnumbers"
            'orderQty.ItemStyle.Width = Unit.Percentage(5)
            'gvSKUs.Columns.Insert(8, orderQty)

        Else
            'Create SKU Column as a link
            Dim skuCol As New HyperLinkField
            skuCol.DataTextField = "Michaels SKU"
            skuCol.HeaderText = "SKU"
            skuCol.NavigateUrl = "#"
            skuCol.SortExpression = "Michaels SKU"
            skuCol.ItemStyle.Width = Unit.Percentage(5)
            gvSKUs.Columns.Insert(2, skuCol)

            ''Create Order Qty column
            'Dim orderQty As New TemplateField
            'orderQty.ItemTemplate = New MyGridViewTemplate(DataControlRowType.DataRow, "Ordered_Qty", "Order Qty", _isOrderedQtyLocked)
            'orderQty.HeaderText = "Total Order <br/>Qty"
            'orderQty.SortExpression = "Ordered_Qty"
            'orderQty.HeaderStyle.CssClass = "gvnumbers"
            'orderQty.ItemStyle.CssClass = "gvnumbers"
            'orderQty.ItemStyle.Width = Unit.Percentage(5)
            'gvSKUs.Columns.Insert(8, orderQty)

            ''Create Calculated Total Qty column
            'Dim calcTotalQty As New TemplateField
            'calcTotalQty.ItemTemplate = New MyGridViewTemplate(DataControlRowType.DataRow, "Calculated_Order_Total_Qty", "Calculated Total Qty", True)
            'calcTotalQty.HeaderText = "Calculated <br/>Total"
            'calcTotalQty.SortExpression = "Calculated_Order_Total_Qty"
            'calcTotalQty.HeaderStyle.CssClass = "gvnumbers"
            'calcTotalQty.ItemStyle.CssClass = "gvnumbers"
            'calcTotalQty.ItemStyle.Width = Unit.Percentage(5)
            'gvSKUs.Columns.Insert(9, calcTotalQty)
        End If

        'Create Location Columns
        Dim insertIndex As Integer = 10 'IIf(_poRec.BatchType = "W", 9, 10)
        Dim locationPrefix As String = IIf(_poRec.BatchType = "W", "DC ", "")
        Dim locationList As List(Of POCreationLocationRecord) = POCreationData.GetLocationsCacheByPOID(_purchaseOrderID, Session(cUSERID))
        For Each location As POCreationLocationRecord In locationList
            Dim locationQty As New TemplateField
            locationQty.ItemTemplate = New MyGridViewTemplate(DataControlRowType.DataRow, "Location " & location.LocationConstant & " Qty", "Location " & location.LocationConstant & " Qty", _isLocationQtyLocked)
            locationQty.HeaderText = locationPrefix & location.LocationConstant & "<br/> Qty"
            locationQty.SortExpression = "Location " & location.LocationConstant & " Qty"
            locationQty.HeaderStyle.CssClass = "gvnumbers"
            locationQty.ItemStyle.CssClass = "gvnumbers"
            locationQty.ItemStyle.HorizontalAlign = HorizontalAlign.Right
            locationQty.ItemStyle.Width = Unit.Percentage(5)
            gvSKUs.Columns.Insert(insertIndex, locationQty)
            insertIndex += 1
        Next

    End Sub

    Private Sub InitializeSKUGridView()
        InitializeGridViewColumns()
        RefreshGridView()
    End Sub

    Private Sub RefreshGridView()
        Dim skuTable As DataTable = POCreationLocationSKUData.GetSKUTableByPOID(_purchaseOrderID, Session(cUSERID))
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

    Protected Sub POHeaderLink_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles POHeaderLink.Click
        Try

            'If the PO is not in the middle of Validation, then Save and Revalidate the Detail
            If Not _isValidating Then
                SaveForm()

                ValidateDetail()
                UpdateValidity()
            End If

            Response.Redirect("POCreationHeader.aspx?POID=" & _poRec.ID.GetValueOrDefault)

        Catch ex As Exception
            ShowMsg("Error: " & ex.Message)
        End Try
    End Sub

    Protected Sub SaveCache()
        If (hdnDoNotSaveWorkflowDepartment.Value.ToString() = "1") Then
            'DO NOT Save Workflow Department (set in pop-up screen instead)
            hdnDoNotSaveWorkflowDepartment.Value = ""
        Else
            'Save Workflow using UI
            _poCacheRec.WorkflowDepartmentID = SmartValue(WorkFlowDept.SelectedValue, "CInt")
            POCreationCacheData.UpdateRecord(_poCacheRec)
        End If


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
            POCreationCacheData.UpdateAllocPlannerFlags(_purchaseOrderID, Session(cUSERID))
            'MERGE CACHE data with LIVE data
            POCreationData.MergeCache(_purchaseOrderID, Session(cUSERID))
            'Reload PORecord to sync with CACHE
            _poRec = POCreationData.GetRecord(_purchaseOrderID)
        End If
    End Sub

    Private Sub SaveLocationCache()
        If tblAllocationsTotals.Rows.Count < 3 Then
            Return
        End If

        Dim locationList As New Dictionary(Of String, POCreationLocationRecord)

        For i As Integer = 1 To 4
            For Each cell As HtmlTableCell In tblAllocationsTotals.Rows(i).Cells
                If TypeOf (cell.Controls(0)) Is LiteralControl Then
                    Continue For
                End If
                Dim textControl As TextBox
                textControl = DirectCast(cell.Controls(0), TextBox)
                Dim parseName() As String = textControl.ID.Split("|")
                Dim locationID = parseName(2)

                'If the Date is a valid Date, or is Blank, then add it to the save list
                If IsDate(textControl.Text) Or textControl.Text = "" Then

                    'Check to ensure location is in list.  If not, create one and add it.
                    If Not locationList.ContainsKey(parseName(2)) Then
                        Dim location As New POCreationLocationRecord
                        location.POCreationID = _purchaseOrderID
                        location.POLocationID = parseName(2)
                        locationList.Add(parseName(2), location)
                    End If

                    'Check what field is being saved
                    Select Case parseName(1)
                        Case "WrittenDate"
                            locationList(locationID).WrittenDate = DataHelper.SmartValue(textControl.Text, "CDate", Nothing)
                        Case "NotBefore"
                            locationList(locationID).NotBefore = DataHelper.SmartValue(textControl.Text, "CDate", Nothing)
                        Case "NotAfter"
                            locationList(locationID).NotAfter = DataHelper.SmartValue(textControl.Text, "CDate", Nothing)
                        Case "EstimatedInStockDate"
                            locationList(locationID).EstimatedInStockDate = DataHelper.SmartValue(textControl.Text, "CDAte", Nothing)
                    End Select
                End If
            Next
        Next

        'Save the locations' Allocation Dates
        For Each kp As KeyValuePair(Of String, POCreationLocationRecord) In locationList
            POCreationData.UpdateLocationCache(kp.Value, Session(cUSERID))
        Next
    End Sub

    Private Sub SaveSKUCache()

        Dim locations As List(Of POCreationLocationRecord) = POCreationData.GetLocationsCacheByPOID(_purchaseOrderID, Session(cUSERID))

        For i As Integer = 0 To gvSKUs.Rows.Count - 1
            'SAVE SKU DataRows
            Dim skuRow As GridViewRow = gvSKUs.Rows(i)
            If skuRow.RowType = DataControlRowType.DataRow Then
                Dim skuRecord As New POCreationLocationSKURecord
                skuRecord.MichaelsSKU = CType(skuRow.FindControl("lblSKU"), Label).Text
                skuRecord.UPC = CType(skuRow.FindControl("ddlUPC"), DropDownList).SelectedValue
                skuRecord.UnitCost = CType(DataHelper.SmartValue(CType(skuRow.FindControl("txtUnitCost"), TextBox).Text, "CDbl", 0.0), Decimal)
                skuRecord.InnerPack = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtIP"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.MasterPack = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtMC"), TextBox).Text, "CInt", False, 0), Integer)

                skuRecord.OrderedQty = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtOrderQty"), TextBox).Text, "CInt", False, 0), Integer)
                skuRecord.CalculatedOrderTotalQty = CType(DataHelper.SmartValues(CType(skuRow.FindControl("txtCalculatedQty"), TextBox).Text, "CInt", False, 0), Integer)

                'SAVE Each SKU/Location combination in the SKU CACHE
                Dim locationQtyIndex As Integer = 10 'IIf(_poRec.BatchType = "W", 9, 10)
                For Each locationRecord In locations
                    Dim poLocationID = locationRecord.POLocationID
                    skuRecord.LocationTotalQty = CType(DataHelper.SmartValues(CType(skuRow.Cells(locationQtyIndex).Controls(0), TextBox).Text, "CInt", False, 0), Integer)
                    POCreationLocationSKUData.UpdateCache(_purchaseOrderID, poLocationID, skuRecord, Session(cUSERID))
                    locationQtyIndex += 1
                Next
            End If
        Next

        POCreationLocationSKUData.UpdateSKUCacheTotalsByPOID(_purchaseOrderID, Session(cUSERID))

    End Sub

    'Private Sub SaveWorkFlowDepartment()
    '    _poRec.WorkflowDepartmentID = Convert.ToInt32(WorkFlowDept.SelectedValue)
    '    POCreationData.SaveWorkFlowDepartment(_poRec.ID.GetValueOrDefault, Convert.ToInt32(WorkFlowDept.SelectedValue))
    'End Sub

    Private Sub btnRemoveCheckedSKUs_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnRemoveCheckedSKUs.Click
        
        'Save Cached information
        SaveCache()

        'Remove checked SKUs
        For i As Integer = 0 To gvSKUs.Rows.Count - 1
            Dim row As GridViewRow = gvSKUs.Rows(i)
            If row.Cells(0).Controls.Count > 0 Then
                Dim removeChkBox As CheckBox = CType(row.Cells(0).Controls(1), CheckBox)
                If removeChkBox.Checked Then
                    Dim sku As String = CType(row.FindControl("lblSKU"), Label).Text
                    POCreationLocationSKUData.DeleteSku(_purchaseOrderID, sku)
                End If
            End If
        Next

        'Update PO Department ID
        POCreationCacheData.UpdatePODepartmentID(_poRec.ID, Session("UserID"))

        'Refresh Cache Record
        _poCacheRec = POCreationCacheData.GetRecord(Session("UserID"), _poRec.ID)

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
            Dim row As GridViewRow = gvSKUs.Rows(i)
            If row.Cells(0).Controls.Count > 0 Then
                Dim chkBox As CheckBox = CType(row.Cells(0).Controls(1), CheckBox)
                If chkBox.Checked Then
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
            ShowMsg(ex.Message)
        End Try

    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click
        SaveForm()

        'Perform Date Validation, and update page validity (in case new dates are specified that are valid)
        ValidateDetail()
        UpdateValidity()

        Response.Redirect("default.aspx")
    End Sub

    Protected Sub btnValidateSKUs_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnValidateSKUs.Click
        Try
            'SAVE on each postback
            SaveForm()

            'CHECK Store Count
            Dim storeCount As Integer = POCreationSKUStoreData.GetByPOID(_poRec.ID).Count
            'CHECK Location Count
            Dim locationQtyCount As Integer = 0
            Dim skuRecords As List(Of POCreationLocationSKURecord) = POCreationLocationSKUData.GetSKUsByPOID(_poRec.ID)
            For Each sku In skuRecords
                locationQtyCount = locationQtyCount + sku.LocationTotalQty
            Next

            'Validation only the Items if Store Count = 0 OR LocationQty Count = 0
            If (storeCount = 0 And _poRec.BatchType = "D") Or (_poRec.BatchType = "W" And locationQtyCount = 0) Then
                ValidateItemsWithWS()
                UpdateValidity()
            Else
                'Submit PO to the Asynchronous Validation Webservice 
                POServiceWrapper.SubmitSKUValidation(_poRec)
            End If

            'Refresh Page
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

        'Refresh Page to revalidate 
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
                _poRec = POCreationData.GetRecord(_purchaseOrderID)

                'Retrieve WS Results
                Dim jobStatus As String = POServiceWrapper.GetSKUValidation(_poRec)

                If (_poRec.IsValidating) Then
                    ShowMsg("This PO is in Queue to be validated.  Please wait, and results will return shortly.")

                    'TODO: This is only here for troubleshooting.  Remove before going live
                    'ShowMsg(" Job Status: " & jobStatus)
                    ValidationTimer.Enabled = True
                Else
                    'Make sure PO is set as NOT Processing
                    POCreationData.UpdatePOProcessing(_poRec.ID, False)

                    'The po is finished validating.  Reload page.
                    ValidationTimer.Enabled = False

                    'Refresh CACHE, revalidate the PO, and Save CACHE to capture all validity changes
                    POCreationData.CreateDetailCache(_purchaseOrderID, Session(cUSERID))
                    _isValidating = False
                    ValidateDetail()
                    POCreationData.MergeCache(_purchaseOrderID, Session(cUSERID))

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
        Dim validationMessages As DataTable

        'Add Saved Warnings to the Validation Summary
        If _poRec.BatchType = "D" Then
            validationMessages = POCreationData.GetSummarizedValidationMessagesByPOID(_poRec.ID)
        Else
            validationMessages = POCreationData.GetValidationMessagesByPOID(_poRec.ID)
        End If

        For Each row As DataRow In validationMessages.Rows
            'If (DataHelper.SmartValues(row("Store_Number"), "cstr", False, "") = "") Then
            vr.Add("", "<a href='#' onclick=""javascript:SearchBySKU('" & row("Michaels_SKU") & "'); return false;"" > SKU " & row("Michaels_SKU") & ":" & row("Message") & "</a>", ValidationRecord.GetValidationRuleSeverityType(row("Severity_Type")))
            'End If
        Next

        'Update _isDetail valid to take into account saved Webservice Validation errors
        _isDetailValid = _isDetailValid And vr.IsValid

        Return vr

    End Function

    Private Function GetValidationMessagesCount(Optional ByVal severity As NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType = -999) As Integer

        Return POCreationData.ValidationMessagesCountByPOID(_poRec.ID, severity)

    End Function

    Private Sub ImplementFieldLocking()
        If _isValidating Then
            _isFormLocked = True
            _isNotBeforeLocked = True
            _isNotAfterLocked = True
            _isInStockLocked = True
            _isSKULocked = True
            _isUPCLocked = True
            _isUnitCostLocked = True
            _isIPLocked = True
            _isMasterPackLocked = True
            _isOrderedQtyLocked = True
            _isLocationQtyLocked = True
            btnUpdate.Enabled = False
            btnUpdateClose.Enabled = False
            WorkFlowDept.Enabled = False
            btnRemoveCheckedSKUs.Enabled = False
            btnUpdateCheckedSKUs.Enabled = False
            btnTotalSyncCheckedSKUs.Enabled = False

            'Disable "Submit" button
            btnValidateSKUs.Visible = False

        Else

            Dim fl As New NovaLibra.Coral.Data.Michaels.FieldLockingData
            Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = fl.GetFieldLockedControls(AppHelper.GetUserID(), MetadataTable.POCreation, _poRec.WorkflowStageID, True)

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
                        Case "Workflow_Department_ID"
                            _isWorkflowDeptLocked = True
                            WorkFlowDept.Enabled = False
                    End Select
                End If
            Next

            'RULE: Direct orders cannot edit "Location Qty"
            If _poRec.BatchType = "D" Then
                _isLocationQtyLocked = True
            End If

            'RULE: Submit Validation is only enabled on Initial and Pack Approval (Allocation, Final Approval) stage types
            Dim wfStageType As Integer = GetStageType(_poRec.WorkflowStageID)
            If wfStageType = WorkflowStageType.Initial Or wfStageType = WorkflowStageType.PackApproval Then
                btnValidateSKUs.Visible = True
            Else
                btnValidateSKUs.Visible = False
            End If

            If _userHasAccess Then
                btnUpdate.Enabled = True
                btnUpdateClose.Enabled = True
                btnValidateSKUs.Enabled = True
                btnRemoveCheckedSKUs.Enabled = Not _isSKULocked
                btnUpdateCheckedSKUs.Enabled = Not _isSKULocked
                btnTotalSyncCheckedSKUs.Enabled = Not _isSKULocked
            Else
                _isSKULocked = True
                btnUpdate.Enabled = False
                btnUpdateClose.Enabled = False
                btnValidateSKUs.Enabled = False
                btnRemoveCheckedSKUs.Enabled = False
                btnUpdateCheckedSKUs.Enabled = False
                btnTotalSyncCheckedSKUs.Enabled = False
            End If
        End If

    End Sub

    Private Sub UpdateValidity()

        If (Not _isValidating) And _userHasAccess Then
            'Get a Validaiton flag indicating if all the Child SKUs and Stores are valid
            Dim isSKUsStoresValid As Boolean? = POCreationData.GetSKUAndStoreValidity(_poRec.ID)
            'Determine Detail validity based off of Child Validity and _Is_Detail_Valid flag
            _poRec.IsDetailValid = _isDetailValid And isSKUsStoresValid
            POCreationData.UpdateRecordBySystem(_poRec, POCreationData.Hydrate.All)
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
            'Try to retrieve the Validation Response
            GetWSValidationResponse()
        Else
            Dim errorCount As Integer = 0
            Dim warningCount As Integer = 0

            Dim vr As New ValidationRecord()

            'Perform Header, Date, Sku, and Store Validation
            vr.Merge(ValidateHeaderValues())
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

            'Perform WebService Validation first, in case dates are returned and saved as part of the Webservice call
            Try
                'Validate PO_Creation_Location Records (Allocation Dates)
                vr = POServiceWrapper.ValidateDates(_poRec)

            Catch ex As Exception
                ShowMsg("There was a problem validating the Allocation Dates.  Please contact support.  Error: " & ex.Message)
            End Try

            'Validate PO_Creation_Location Records (Allocation Dates)
            vr.Merge(ValidationHelper.ValidateData(_poRec, _poRec.WorkflowStageID, NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.POCreationLocation))

            _isDetailValid = _isDetailValid And vr.IsValid
        End If

        Return vr
    End Function

    Private Function ValidateHeaderValues() As ValidationRecord
        Dim vr As New ValidationRecord

        If Not ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
            'Validate PO_Creation Record (Workflow Department)
            vr = ValidationHelper.ValidateData(_poRec, _poRec.WorkflowStageID, NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.POCreationDetail)

            _isDetailValid = _isDetailValid And vr.IsValid
        End If

        Return vr
    End Function

    Private Sub ValidateItemsWithWS()
        Try

            If Not ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
                'Validate SKUs using WebService
                POServiceWrapper.ValidateItems(_poRec)

                'Refresh CACHE, revalidate the PO, and Save CACHE to capture all validity changes
                POCreationData.CreateDetailCache(_purchaseOrderID, Session(cUSERID))
                _isValidating = False
                ValidateDetail()
                POCreationData.MergeCache(_purchaseOrderID, Session(cUSERID))

            End If

        Catch ex As Exception
            ShowMsg("There was a problem validating the SKUs.  Please contact support.  Error: " & ex.Message)
        End Try
    End Sub

    Private Function ValidateSKUs() As ValidationRecord
        Dim vr As New ValidationRecord

        If Not ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
            'Validate PO_Creation_Location Records (Allocation Dates)
            vr = ValidationHelper.ValidateData(_poRec, _poRec.WorkflowStageID, NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.POCreationSKU)

            _isDetailValid = _isDetailValid And vr.IsValid
        End If

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
            '	e.Row.Style.Add("height", "60px")
            '	e.Row.Style.Add("vertical-align", "bottom")
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
                skuLink.Attributes.Add("onclick", "javascript:ShowPOCreationDetailsSKUStore(" + _purchaseOrderID.ToString + ", '" + skuLink.Text + "'); return false;")
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

