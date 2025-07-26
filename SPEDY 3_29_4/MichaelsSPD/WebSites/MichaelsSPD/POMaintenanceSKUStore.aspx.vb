
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

Partial Class POMaintenanceSKUStore
	Inherits MichaelsBasePage

	'GENERAL
	Const cPCLSKUID As String = "POMAINTSKUSTORE_POCLSKUID"
	Const cSKUStoreList As String = "POMAINTPOSKUSTORE_SKUStores"

	'SORTING
	Const cSORTINGCURSORTCOL As String = "POMAINTSKUSTORE_CURSORTCOL"
	Const cSORTINGCURSORTDIR As String = "POMAINTSKUSTORE_CURSORTDIR"

	Private _sku As String
	Private _purchaseOrderID As Long?
	Private _revisionNumber As Double?
	Private _poRecord As Models.POMaintenanceRecord
	Protected _isSKULocked As Boolean = False
	Protected _isQtyLocked As Boolean = False
	Private _isValidating As Boolean = False
    Private _isRevision As Boolean = False
	Private _userHasAccess As Boolean = False

	Protected Property poSKUStores() As ArrayList
		Get
			Return Session(cSKUStoreList)
		End Get
		Set(ByVal value As ArrayList)
			Session(cSKUStoreList) = value
		End Set
	End Property

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

		'Check Session
		SecurityCheckRedirect()

		'Clear Messages Displayed To User
		ShowMsg("")

		'Get data from Request
		_purchaseOrderID = Helper.SmartValues(Request("POID"), "long", False)
		_sku = Helper.SmartValues(Request("SKU"), "string", False)
		_revisionNumber = Helper.SmartValue(Request("Revision"), "CDbl", 0)
		If _purchaseOrderID Is Nothing Or _sku Is Nothing Then
			'There was a problem getting the values passed in to the Request string 
			Response.Redirect("default.aspx")
		End If

		'Check User Access to PO
		_userHasAccess = Data.POMaintenanceData.ValidateUserForPO(_purchaseOrderID, Session("UserID"))

		'Retrieve the poRecord based on POID and Revision
		If (_isRevision) Then
			_poRecord = Data.POMaintenanceData.GetRevisionRecord(_purchaseOrderID, _revisionNumber)
		Else
			_poRecord = Data.POMaintenanceData.GetRecord(_purchaseOrderID)
		End If

		'Retrieve the PORecord for the WorkflowID and to dertmine if the record is being validated by Asynchronous Webservice calls
		If _poRecord.IsValidating Then
			_isValidating = True
		End If

		' Compare specified revision to the Current Reivision Number to see if this is a Revision
		Dim currentRevisionNumber = Data.POMaintenanceData.GetCurrentRevision(_purchaseOrderID)
		If (_revisionNumber <> currentRevisionNumber) Then
			_isRevision = True
        End If

        'Check To Make Sure This Item Was Not Added By RMS (If so, this page should be read-only)
        If _userHasAccess AndAlso Not _isRevision Then
            _userHasAccess = Not Data.POMaintenanceSKUData.AddedByRMS(_purchaseOrderID, _sku)
        End If

		If Not IsPostBack Then
			InitializeControls()
			PopulateControls()
        End If

        'Lock Fields based on page state and current Workflow
        ImplementFieldLocking()

	End Sub

	Private Sub AddStore(ByVal number As Integer)
		Dim newStore As New Models.POMaintenanceSKUStoreRecord

		'Make sure the Store is not already inside the Store List
		Dim isAlreadyAdded = False
		For Each rec As Models.POMaintenanceSKUStoreRecord In poSKUStores
			If (number = rec.StoreNumber) Then
				isAlreadyAdded = True
				Exit For
			End If
		Next

		'Add store to the StoreList if the store is not already in the list
		If Not (isAlreadyAdded) Then
			newStore.IsSelected = False
            newStore.IsValid = Nothing
			newStore.StoreNumber = number
            newStore.OrderedQty = 0
            newStore.CancelledQty = 0
			poSKUStores.Add(newStore)
		End If
	End Sub

	Private Function CreateSortedDataTable() As DataTable
		Dim dt As New DataTable
		dt.Columns.Add("ID", GetType(Long))
		dt.Columns.Add("POMaintenanceID", GetType(Long))
		dt.Columns.Add("POLocationID", GetType(Integer))
		dt.Columns.Add("MichaelsSKU", GetType(String))
		dt.Columns.Add("StoreName", GetType(String))
		dt.Columns.Add("StoreNumber", GetType(Integer))
        dt.Columns.Add("OrderedQty", GetType(Integer))
        dt.Columns.Add("CancelledQty", GetType(Integer))
        dt.Columns.Add("ReceivedQty", GetType(Integer))
		dt.Columns.Add("Zone", GetType(String))
		dt.Columns.Add("IsSelected", GetType(Boolean))
		dt.Columns.Add("IsRemoveable", GetType(Boolean))
        dt.Columns.Add("IsValid", GetType(Boolean))
        dt.Columns.Add("IsValidText", GetType(String))
        dt.Columns.Add("LandedCost", GetType(Decimal))
        dt.Columns.Add("OrderRetail", GetType(Decimal))
        dt.Columns.Add("IsWarning", GetType(Boolean))

		For Each store As Models.POMaintenanceSKUStoreRecord In poSKUStores
            dt.Rows.Add(store.ID, store.POMaintenanceID, store.POLocationID, store.MichaelsSKU, store.StoreName, store.StoreNumber, store.OrderedQty, store.CancelledQty, store.ReceivedQty, store.Zone, DataHelper.SmartValue(store.IsSelected, "CBool", False), DataHelper.SmartValue(store.IsRemoveable, "CBool", False), store.IsValid, DataHelper.SmartValue(store.IsValid, "CBool", ""), store.LandedCost, store.OrderRetail, store.IsWarning)
		Next

        'Filter to show Stores with a Warning or Error
        If (StoreFilter.SelectedValue <> "") Then
            Select Case StoreFilter.SelectedValue
                Case "WARNING"
                    'Show only stores with a Warning
                    dt.DefaultView.RowFilter = "IsWarning = true"
                Case "ERROR"
                    'Show only invalid (Error) stores
                    dt.DefaultView.RowFilter = "IsValid= false"
            End Select
        End If

		dt.DefaultView.Sort = Session(cSORTINGCURSORTCOL) & " " & Session(cSORTINGCURSORTDIR)

		Return dt
	End Function

    Protected Function GetCheckBoxUrl(ByVal isValid As Object, ByVal isWarning As Object) As String
        Dim returnValue As String = "images/valid_null_small.gif"

        If isValid IsNot Nothing AndAlso isValid IsNot DBNull.Value Then
            If DataHelper.SmartValue(isValid, "CBool", False) = False Then
                returnValue = "images/valid_no_small.gif"
            Else
                If DataHelper.SmartValue(isWarning, "CBool", False) = True Then
                    returnValue = "images/warning_small.gif"
                Else
                    returnValue = "images/valid_yes_small.gif"
                End If
            End If
        Else
            returnValue = "images/valid_null_small.gif"
        End If

        Return returnValue
    End Function

	Private Sub ImplementFieldLocking()
		If _isValidating Or _isRevision Then
			BtnAddStore.Enabled = False
			BtnRemove.Enabled = False
			BtnRemove.Visible = False
			BtnImport.Visible = False
			btnUpdate.Visible = False
			btnUpdateClose.Visible = False
			SKUStoreGrid.Columns(0).Visible = False
			_isQtyLocked = True
			_isSKULocked = True

		Else

			'Get FieldLocking list to determine what should be locked for the rest of the form
			Dim fl As New NovaLibra.Coral.Data.Michaels.FieldLockingData
			Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = fl.GetFieldLockedControls(Session("UserID"), Michaels.MetadataTable.POMaintenance, _poRecord.WorkflowStageID, True)

			For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
				If (col.Permission <> "E") Then
					'Check to see if any Controls were specified for the Field Locked Column
					Select Case (col.ColumnName)
						Case "Ordered_Qty"
							_isQtyLocked = True
						Case "Michaels_SKU"
							_isSKULocked = True
					End Select
				End If
            Next

            'RULE: Direct orders should NOT be able to Add/Remove SKUs, OR Edit Quantities
            If (_poRecord.BatchType = "D") Then
                _isQtyLocked = True
                _isSKULocked = True
            End If

            'Display buttons if the user has access to the PO 
            If _userHasAccess Then
                btnUpdate.Visible = True
                btnUpdateClose.Visible = True
                BtnAddStore.Enabled = Not _isSKULocked
                BtnRemove.Enabled = Not _isSKULocked
                BtnImport.Visible = False 'BtnImport.Visible = Not _isSKULocked 'OT: DO NOT SHOW UNTIL FUNCTIONALITY HAS BEEN IMPLEMENTED
                SKUStoreGrid.Columns(0).Visible = Not _isSKULocked
            Else
                BtnAddStore.Enabled = False
                BtnRemove.Enabled = False
                BtnImport.Visible = False
                btnUpdate.Visible = False
                btnUpdateClose.Visible = False
                SKUStoreGrid.Columns(0).Visible = False
            End If

        End If
    End Sub

	Private Sub InitializeControls()
		'Setup the validation summary
		ValidationHelper.SetupValidationSummary(validationDisplay)

		'Set Defaults
		If Session(cSORTINGCURSORTCOL) Is Nothing Then Session(cSORTINGCURSORTCOL) = "StoreNumber"
		If Session(cSORTINGCURSORTDIR) Is Nothing Then Session(cSORTINGCURSORTDIR) = "ASC"

	End Sub

	Private Sub PerformValidation()

		Dim vr As New Models.ValidationRecord()

		'Create a SkUStore Record that only holds PO_Maintenance_ID and SKU
		Dim skuStoreHolder As New Models.POMaintenanceSKUStoreRecord
		skuStoreHolder.POMaintenanceID = _purchaseOrderID
		skuStoreHolder.MichaelsSKU = _sku

		'Use SKUStore info to validate ALL Stores on this SKU
		vr = ValidationHelper.ValidateData(skuStoreHolder, _poRecord.WorkflowStageID, NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.POMaintenanceSKUStore)

		'Get ValidationMessages saved in Database
		Dim validationErrors As DataTable = Data.POMaintenanceData.GetValidationMessagesGetForStores(_poRecord.ID, _sku)
		For Each row As DataRow In validationErrors.Rows
            vr.Add("", "<a href='#' onclick=""javascript:SearchByStore('" & row("Store_Number").ToString & "'); return false;"" > " & row("Message").ToString & "</a>", Models.ValidationRecord.GetValidationRuleSeverityType(row("Severity_Type")))
        Next

        'RULE: Display Errors first, then display Warnings in ValidationSummary.
        Dim vrFinal As New Models.ValidationRecord
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

        'Add ValidatinRecord to Validation Summary so they appear on the page
        ValidationHelper.AddValidationSummaryErrors(validationDisplay, vrFinal)
	End Sub

	Private Sub PopulateControls()

		'Get Item Information, and use it to populate page controls
		Dim item As Models.ItemMasterRecord = Data.ItemMasterData.GetBySKU(_sku)
		lblSKUNumber.Text = item.Item
		lblSKUDescription.Text = item.ItemDescription
		lblVPN.Text = item.VendorStyleNum

		'Do not Perform Validation if the page is being validated (via Webservices) or is an old Revision
		If Not _isValidating And Not _isRevision Then
			PerformValidation()
		End If

		PopulateStoreGrid()
	End Sub

	Private Sub PopulateStoreGrid()
		'Get the Crurently enabled SKU Stores
        'If (_isRevision) Then
        '	poSKUStores = Data.POMaintenanceSKUStoreData.GetRevisionBySku(_purchaseOrderID, _sku, _revisionNumber)
        'Else
        '	poSKUStores = Data.POMaintenanceSKUStoreData.GetBySKU(_purchaseOrderID, _sku)
        'End If
        poSKUStores = Data.POMaintenanceSKUStoreData.GetBySKU(_purchaseOrderID, _sku, Session(cUSERID))


		'Rebind Grid after store is added
		RefreshGrid()
	End Sub

	Private Sub RefreshStoresFromGridView()

		Dim storeList As New ArrayList

		'Loop Through Store Grid
		For i As Integer = 0 To SKUStoreGrid.Rows.Count - 1
			Dim row As GridViewRow = SKUStoreGrid.Rows(i)
			Dim id As Long? = DataHelper.SmartValuesDBNull(SKUStoreGrid.DataKeys(i).Value, False)
			Dim storeNumber As String = CType(row.FindControl("lblStoreNumber"), Label).Text
			Dim storeName As String = CType(row.FindControl("lblStoreName"), Label).Text
			Dim zone As String = CType(row.FindControl("lblZone"), Label).Text
			Dim poLocation As String = CType(row.FindControl("lblPOLocationID"), Label).Text
            Dim quantity As String = CType(row.FindControl("Qty"), NovaLibra.Controls.NLTextBox).Text
            Dim cancelledQty As String = CType(row.FindControl("CancelledQty"), NovaLibra.Controls.NLTextBox).Text
			Dim isRemovable As Boolean = CType(row.FindControl("IsRemoved"), NovaLibra.Controls.NLCheckBox).Visible
			Dim isSelected As Boolean = CType(row.FindControl("IsRemoved"), NovaLibra.Controls.NLCheckBox).Checked
            Dim isValid As Boolean? = DataHelper.SmartValue(CType(row.FindControl("lblIsValid"), Label).Text, "CBool", Nothing)
            Dim landedCost As Decimal? = CType(DataHelper.SmartValues(CType(row.FindControl("lblLandedCost"), Label).Text, "decimal", False, 0), Decimal)
            Dim orderRetail As Decimal? = CType(DataHelper.SmartValues(CType(row.FindControl("lblOrderRetail"), Label).Text, "decimal", False, 0), Decimal)

			If IsNumeric(quantity) Then
				'Create Store object from grid info
				Dim store As New Models.POMaintenanceSKUStoreRecord
				store.POMaintenanceID = _purchaseOrderID
				store.MichaelsSKU = _sku
				store.StoreName = storeName
				store.Zone = zone
				store.StoreNumber = DataHelper.SmartValues(storeNumber, "Integer", False)
                store.OrderedQty = DataHelper.SmartValues(quantity, "Integer", False, 0)
                store.CancelledQty = DataHelper.SmartValues(cancelledQty, "Integer", False, 0)
				store.POLocationID = DataHelper.SmartValues(poLocation, "Integer", False)
				store.IsRemoveable = isRemovable
                store.IsSelected = isSelected
                store.IsValid = isValid
                store.LandedCost = landedCost
                store.OrderRetail = orderRetail

				store.ID = id

				'Add store to the list of stores
				storeList.Add(store)
			End If
		Next

		'Refresh Stores in session with what is in the grid
		poSKUStores = storeList

		'Rebind Grid after store is added
		RefreshGrid()

	End Sub

	Private Sub RefreshGrid()

		'Create a DataTable for the storeList.  This is used in sorting.
		Dim dt As DataTable = CreateSortedDataTable()
		
		SKUStoreGrid.DataSource = dt
		SKUStoreGrid.DataBind()
	End Sub

	Private Sub RemoveStore(ByVal number As Integer, ByVal id As Integer?)

		'Remove the Store from the Session's StoreList
        Dim index As Integer?
        Dim storeNumber As Integer
		For Each store As Models.POMaintenanceSKUStoreRecord In poSKUStores
            If (store.StoreNumber = number) Then
                storeNumber = store.StoreNumber
                index = poSKUStores.IndexOf(store)
                Exit For
            End If
		Next
		poSKUStores.RemoveAt(index)

        'REMOVE Store From CACHE
        Data.POMaintenanceSKUStoreData.DeleteCache(_purchaseOrderID, _sku, storeNumber, Session(cUSERID))
	End Sub

	Private Sub SaveStores()
		'Only Save if user has access to the PO
		If _userHasAccess Then
			'Loop Through Store Grid
			For i As Integer = 0 To SKUStoreGrid.Rows.Count - 1
				Dim row As GridViewRow = SKUStoreGrid.Rows(i)
				Dim id As Long? = DataHelper.SmartValuesDBNull(SKUStoreGrid.DataKeys(i).Value, False)
				Dim storeNumber As String = CType(row.FindControl("lblStoreNumber"), Label).Text
				Dim storeName As String = CType(row.FindControl("lblStoreName"), Label).Text
				Dim poLocation As String = CType(row.FindControl("lblPOLocationID"), Label).Text
                Dim quantity As String = CType(row.FindControl("Qty"), NovaLibra.Controls.NLTextBox).Text
                Dim cancelledQty As String = CType(row.FindControl("CancelledQty"), NovaLibra.Controls.NLTextBox).Text
                Dim isValid As Boolean? = DataHelper.SmartValue(CType(row.FindControl("lblIsValid"), Label).Text, "CBool", Nothing)
                Dim landedCost As Decimal? = CType(DataHelper.SmartValues(CType(row.FindControl("lblLandedCost"), Label).Text, "decimal", False, 0), Decimal)
                Dim orderRetail As Decimal? = CType(DataHelper.SmartValues(CType(row.FindControl("lblOrderRetail"), Label).Text, "decimal", False, 0), Decimal)

				If IsNumeric(quantity) Then
					'Create Store object from grid info
					Dim store As New Models.POMaintenanceSKUStoreRecord
					store.POMaintenanceID = _purchaseOrderID
					store.MichaelsSKU = _sku
					store.StoreName = storeName
					store.StoreNumber = DataHelper.SmartValues(storeNumber, "Integer", False)
                    store.OrderedQty = DataHelper.SmartValues(quantity, "Integer", False, 0)
                    store.CancelledQty = DataHelper.SmartValues(cancelledQty, "Integer", False, 0)
                    store.POLocationID = DataHelper.SmartValues(poLocation, "Integer", False)
                    store.LandedCost = landedCost
                    store.OrderRetail = orderRetail
                    store.IsValid = isValid
					store.ID = id

					'Save Store
                    Data.POMaintenanceSKUStoreData.SaveCacheRecord(store, Session(cUSERID))
				End If
            Next

            'TEST: DO when saving cache on parent page
            'Update SKU Totals
            'Data.POMaintenanceSKUStoreData.UpdateSKUCacheTotals(_purchaseOrderID, _sku, Session(cUSERID))

		End If

	End Sub

	Private Sub SetSorting(ByVal sortExpression As String)
		'Find the appropriate sort direction
		If Session(cSORTINGCURSORTCOL).ToString() = sortExpression Then

			If Session(cSORTINGCURSORTDIR) = "ASC" Then
				Session(cSORTINGCURSORTDIR) = "DESC"
			Else
				Session(cSORTINGCURSORTDIR) = "ASC"
			End If
		Else
			Session(cSORTINGCURSORTCOL) = sortExpression
			Session(cSORTINGCURSORTDIR) = "ASC"
		End If
	End Sub

	Private Sub ShowMsg(ByVal strMsg As String, Optional ByVal type As String = "E")
		Dim curMsg As String
		'If strMsg.Length = 0 Then
		'    lblMessage.Text = "&nbsp;" ' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
		'Else
		'    curMsg = lblMessage.Text
		'    If curMsg = "&nbsp;" OrElse curMsg.Length = 0 Then       ' Only set the message if there is not one in there already
		'        lblMessage.Text = strMsg
		'        If type = "E" Then
		'            lblMessage.CssClass = "redText"
		'        Else
		'            lblMessage.CssClass = "greenText"
		'        End If
		'    Else
		'        lblMessage.Text += "<br />" & strMsg
		'        lblMessage.CssClass = "redText"
		'    End If
		'End If
	End Sub

	Protected Sub BtnAddStore_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnAddStore.Click
        Try
            'Check to make sure the StoreNumber is Numeric
            Dim number As Integer = DataHelper.SmartValues(StoreNumber.Text, "CInt", False, 0)
            If (number > 0) Then
                'Add Store to the DataSet and GridView
                AddStore(number)
                'Clear out the StoreNumber textbox
                StoreNumber.Text = ""

                PerformValidation()

                'Refresh the Grid with the new Dataset
                RefreshGrid()
            End If
        Catch ex As Exception
            ShowMsg(ex.Message)
        End Try
	End Sub

    Protected Sub BtnFilterStore_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnFilterStore.Click
        Try
            PerformValidation()

            RefreshGrid()
        Catch ex As Exception
            ShowMsg("Error:" & ex.Message)
        End Try
    End Sub

	Protected Sub BtnImport_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnImport.Click
        PerformValidation()
    End Sub

	Protected Sub BtnRemove_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnRemove.Click
        Try
            'Loop Through Checkboxes and remove any checked stores
            For i As Integer = 0 To SKUStoreGrid.Rows.Count - 1
                Dim row As GridViewRow = SKUStoreGrid.Rows(i)
                Dim isChecked As Boolean = CType(row.FindControl("IsRemoved"), CheckBox).Checked

                If (isChecked) Then
                    Dim id As Integer? = DataHelper.SmartValue(SKUStoreGrid.DataKeys(i).Value, "CInt", Nothing)
                    Dim storeNumber As String = CType(row.FindControl("lblStoreNumber"), Label).Text
                    RemoveStore(CInt(storeNumber), id)
                End If
            Next

            PerformValidation()

            RefreshGrid()
        Catch ex As Exception
            ShowMsg("Error: " & ex.Message)
        End Try
	End Sub

	Protected Sub BtnSortByStoreNo_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnSortByStoreNo.Click
		'Set Session Sort Variables
		SetSorting("StoreNumber")

		'Lock Fields and Reload GridView
		ImplementFieldLocking()

		'To propertly handle Cancel button, use gridview to refresh session if Quantity is editable
		If Not _isQtyLocked Then
			RefreshStoresFromGridView()
		Else
			'Repopulate GridView from database
			PopulateStoreGrid()
		End If

	End Sub

	Protected Sub BtnSortByStoreName_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnSortByStoreName.Click
		'Set Session Sort Variables
		SetSorting("StoreName")

		'Lock Fields and Reload GridView
		ImplementFieldLocking()

		'To propertly handle Cancel button, use gridview to refresh session if Quantity is editable
		If Not _isQtyLocked Then
			RefreshStoresFromGridView()
		Else
			'Repopulate GridView from database
			PopulateStoreGrid()
		End If

    End Sub

    'Disabling
    'Protected Sub BtnSortByValidity_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnSortByValidity.Click
    '    'Set Session Sort Variables
    '    SetSorting("IsValid")

    '    'Lock Fields and Reload GridView
    '    ImplementFieldLocking()

    '    'To propertly handle Cancel button, use gridview to refresh session if Quantity is editable
    '    If Not _isQtyLocked Then
    '        RefreshStoresFromGridView()
    '    Else
    '        'Repopulate GridView from database
    '        PopulateStoreGrid()
    '    End If
    'End Sub

	Protected Sub BtnSortByZone_Click(ByVal sender As Object, ByVal e As EventArgs) Handles BtnSortByZone.Click
		'Set Session Sort Variables
		SetSorting("Zone")

		'Lock Fields and Reload GridView
		ImplementFieldLocking()

		'To propertly handle Cancel button, use gridview to refresh session if Quantity is editable
		If Not _isQtyLocked Then
			RefreshStoresFromGridView()
		Else
			'Repopulate GridView from database
			PopulateStoreGrid()
		End If

	End Sub

	Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnUpdate.Click
        Try
            SaveStores()
            PerformValidation()

            ImplementFieldLocking()

            'Repopulate GridView from database
            PopulateStoreGrid()

            hidRefreshParent.Value = "1"
        Catch ex As Exception
            ShowMsg("Error: " & ex.Message)
        End Try
	End Sub

	Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnUpdateClose.Click
		'Save the Store info
		SaveStores()
		PerformValidation()
        ImplementFieldLocking()

        'Refresh parent, and close window
        hidRefreshParent.Value = "1"
        hidCloseWindow.Value = "1"
	End Sub

	Protected Sub SKUStoreGrid_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles SKUStoreGrid.Sorting

	End Sub

	Protected Sub SKUStoreGrid_Sorted(ByVal sender As Object, ByVal e As System.EventArgs) Handles SKUStoreGrid.Sorted

	End Sub
End Class
