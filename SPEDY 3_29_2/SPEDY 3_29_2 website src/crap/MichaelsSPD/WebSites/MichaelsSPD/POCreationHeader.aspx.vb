Imports System.Data
Imports NovaLibra.Common.Utilities.DataHelper
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Coral.Data.Michaels
Imports System.Collections.Generic
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Common

Partial Class POCreationHeader
    Inherits MichaelsBasePage

	Private _purchaseOrderID As Integer = 0
	Private _poRec As POCreationRecord
	Private _vendorRec As VendorRecord
	Private _isLocationSelected As Boolean = True
	Private _isHeaderValid As Boolean = True
	Private _isValidating As Boolean = False
    Private _userHasAccess As Boolean = False

    Protected _pogStartDateLocked As Boolean = False
    Protected _pogEndDateLocked As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Check Session
        SecurityCheckRedirect()

		'Get PO ID
		If Request.QueryString("POID") IsNot Nothing Then
			POID.Value = SmartValue(Request.QueryString("POID"), "CLng", 0)
		End If
		_purchaseOrderID = POID.Value

        'Check Permission
		If Not SecurityCheckHasAccess("SPD", "SPD.ACCESS.PONEW", Session("UserID")) Then
			Response.Redirect("default.aspx")
		End If
		'Check User Access to PO
		_userHasAccess = POCreationData.ValidateUserForPO(_purchaseOrderID, Session("UserID"))

        'Get Data
        _poRec = POCreationData.GetRecord(_purchaseOrderID)
        If Not _poRec.ID.HasValue Then
            Response.Redirect("Default.aspx")
        End If
        _vendorRec = (New VendorData).GetVendorRecord(_poRec.VendorNumber)

		'Dertmine if the record is being validated by Asynchronous Webservice callse
		If _poRec.IsValidating Then
			_isValidating = True
		End If

        If Not Page.IsPostBack Then
			'Get Initial Data, and populate page controls
			InitializePage()
			PopulatePage()

			'Validate the Header, Locations, and Detail
			If Not (_isValidating) Then
				ValidatePOHeader()
				ValidatePOLocations()
			End If

			UpdateValidity()
			ImplementFieldLocking()
		End If

		'KNOWN BUG IN CHECKBOXLIST (DOES NOT RETAIN ATTRIBUTES ON POSTBACK) SO ALWAYS DO THIS
		If BasicWarehouse.Items.Count > 0 Then
			BasicWarehouse.Items(0).Attributes.Add("onclick", "CBAllClick('" & BasicWarehouse.ClientID & "', " & BasicWarehouse.Items.Count - 1 & ");")
		End If
		If SeasonalWarehouse.Items.Count > 0 Then
			SeasonalWarehouse.Items(0).Attributes.Add("onclick", "CBAllClick('" & SeasonalWarehouse.ClientID & "', " & SeasonalWarehouse.Items.Count - 1 & ");")
		End If
		If StoreZone.Items.Count > 0 Then
			StoreZone.Items(0).Attributes.Add("onclick", "CBAllClick('" & StoreZone.ClientID & "', " & StoreZone.Items.Count - 1 & ");")
		End If

		'RULE: IF the PO chosen is Warehouse, then check the Basic/Seasonal selection to determine which checkboxlists to display
		If _poRec.BatchType = "W" Then
			'RULE:  If the PO is chosen to be Warehouse / Basic, then only the basic warehouses should be displayed for the user to select
			'RULE:  If the PO is chosen to be Warehouse / Seasonal, then all the warehouses, both basic and seasonal, should be displayed for the user to select
			If BasicSeasonal.SelectedValue = "B" Then
				SeasonalWarehouseTD.Style.Add("display", "none")
			Else
				SeasonalWarehouseTD.Style.Add("display", "block")
			End If

		End If

    End Sub

    Private Sub InitializePage()

        'Setup the validation summary
        ValidationHelper.SetupValidationSummary(ValidationSummary)

        BasicSeasonal.Items.Add(New ListItem("Basic", "B"))
        BasicSeasonal.Items.Add(New ListItem("Seasonal", "S"))

        'LoadAllocationEvents()
        LoadSeasonalSymbols()

        Dim lvgs As NovaLibra.Coral.SystemFrameworks.ListValueGroups = FormHelper.LoadListValues("SEASONCODE")

        'Load Batch Stock Category
        FormHelper.LoadListFromListValues(SeasonCode, lvgs.GetListValueGroup("SEASONCODE"), True, "")

        'RULE: Event Year should contain blank, this year, and next year
        EventYear.Items.Add("")
        EventYear.Items.Add(DateTime.Now.Year)
        EventYear.Items.Add(DateTime.Now.Year + 1)

		'RULE: IF Vendor is Import, display Ship Point Import drop down
        '      ELSE Display Ship Point Textbox
		If _vendorRec.VendorType = ValidationHelper.VALIDATION_VENDOR_IMPORT_TYPES Then
			LoadShipPointImport()
		Else
			ShipPointDomestic.Visible = True
			ShipPointImport.Visible = False
		End If

        'RULE: If Batch is Warehouse, then Initialize Basic and Seasonal Warehouse checkboxes.
        '      Else If Batch is Direct, then display the Store Zone checkboxes 
        If _poRec.BatchType = "W" Then
            BasicSeasonal.Attributes.Add("onchange", "BasicSeasonalChanged('" & BasicSeasonal.ClientID & "','" & BasicWarehouse.ClientID & "', '" & SeasonalWarehouse.ClientID & "');")
            WarehouseTR.Visible = True
            LoadLocationByType("B", BasicWarehouse)
            LoadLocationByType("S", SeasonalWarehouse)
            AllowSeasonalItemsBasicDC.Visible = True
        ElseIf _poRec.BatchType = "D" Then
            StoreZoneTR.Visible = True
            LoadLocationByType(Nothing, StoreZone)
            AllowSeasonalItemsBasicDC.Visible = False
        End If

        'Load data for other dropdown lists
        LoadPaymentTerms()
        LoadFreightTerms()
        LoadPOSpecial()

    End Sub

    Private Sub LoadAllocationEvents()

        Dim SQLStr As String = "PO_Allocation_Event_Get_All"

        'Removes All Previous Items
        AllocationEvent.Items.Clear()

        AllocationEvent.Items.Add(New ListItem("", ""))

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)

                'Filter List Depending On Business Rules
                If _poRec.BatchType = "W" AndAlso BasicSeasonal.SelectedValue = "B" Then
                    cmd.Parameters.Add("@WH_TYPE", SqlDbType.Char).Value = "P"
                    cmd.Parameters.Add("@EVENT_TYPE", SqlDbType.Char).Value = "W"
                ElseIf _poRec.BatchType = "W" AndAlso BasicSeasonal.SelectedValue = "S" Then
                    cmd.Parameters.Add("@EVENT_TYPE", SqlDbType.Char).Value = "W"
                ElseIf _poRec.BatchType = "D" AndAlso BasicSeasonal.SelectedValue = "B" Then
                    cmd.Parameters.Add("@WH_TYPE", SqlDbType.Char).Value = "P"
                    cmd.Parameters.Add("@EVENT_TYPE", SqlDbType.Char).Value = "D"
                ElseIf _poRec.BatchType = "D" AndAlso BasicSeasonal.SelectedValue = "S" Then
                    cmd.Parameters.Add("@WH_TYPE", SqlDbType.Char).Value = "S"
                    cmd.Parameters.Add("@EVENT_TYPE", SqlDbType.Char).Value = "D"
                End If

                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        AllocationEvent.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("ALLOC_EVENT_ID")) & " - " & DataHelper.SmartValuesDBNull(reader.Item("ALLOC_DESC")), reader.Item("ID")))

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

    End Sub

    Private Sub LoadSeasonalSymbols()

        Dim SQLStr As String = "PO_Seasonal_Symbol_Get_All"

        SeasonalSymbol.Items.Add(New ListItem("", ""))

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)
                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        SeasonalSymbol.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("Name")), reader.Item("ID")))

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

    End Sub

    Private Sub LoadShipPointImport()

        ShipPointImport.Visible = True

        ShipPointImport.Items.Add(New ListItem("", ""))

        Dim SQLStr As String = "PO_Ship_Point_Get_All"

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)
                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        ShipPointImport.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("OUTLOC_DESC")), reader.Item("OUTLOC_ID")))

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

    End Sub

    Private Sub LoadLocationByType(ByVal warehouseType As String, ByVal cbList As CheckBoxList)

        Dim SQLStr As String = "PO_Location_Get_By_Type"

        Dim bEnable As Boolean
        Dim sText As String, sDest As String, sCombo As String

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)
                cmd.Parameters.Add("@Warehouse_Type", SqlDbType.Char).Value = warehouseType
                cmd.Parameters.Add("@Create_POID", SqlDbType.BigInt).Value = _purchaseOrderID
                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        bEnable = True
                        sText = DataHelper.SmartValuesDBNull(reader.Item("Name"))
                        sDest = DataHelper.SmartValuesDBNull(reader.Item("Destination"))
                        sCombo = DataHelper.SmartValuesDBNull(reader.Item("CombinedFrom"))

                        If Len(sDest) > 0 Then
                            bEnable = False
                            sText = sText & " (replaced by " & sDest & ")"
                        End If

                        If Len(sCombo) > 0 Then
                            sText = sText & " (basic+seasonal)"
                        End If

                        Dim li As New ListItem(sText, reader.Item("ID"), bEnable)

                        cbList.Items.Add(li)

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

        'Add Check All Checkbox
        Dim CheckAll As New ListItem("ALL", "0")
        cbList.Items.Insert(0, CheckAll)

    End Sub

    Private Sub LoadPaymentTerms()
        PaymentTerms.Items.Add(New ListItem("", ""))

        Dim SQLStr As String = "PO_Payment_Terms_Get_All"

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)
                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        PaymentTerms.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("Terms")) & " - " & DataHelper.SmartValuesDBNull(reader.Item("Terms_Desc")), reader.Item("ID")))

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
    End Sub

    Private Sub LoadFreightTerms()
        FreightTerms.Items.Add(New ListItem("", ""))

        Dim SQLStr As String = "PO_Freight_Terms_Get_All"

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)
                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        FreightTerms.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("Name")), reader.Item("ID")))

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
    End Sub

    Private Sub LoadPOSpecial()
        Dim SQLStr As String = "PO_Special_Get_By_Batch_Type"

        POSpecial.Items.Add(New ListItem("None", 0))

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)
                cmd.Parameters.Add("@BatchType", SqlDbType.Char).Value = _poRec.BatchType
                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        POSpecial.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("Name")), reader.Item("ID")))

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
    End Sub

    Private Sub PopulatePage()

        Try

            'Display "PO Detail" tab if this is an existing PO record
            If Not _poRec.ID.HasValue Then
                PODetailTab.Visible = False
            Else
                PODetailTab.Visible = True
            End If

            '************************************************************************
            ' Load Batch Info
            '************************************************************************

            'Must Be An Existing Batch
            If _poRec Is Nothing Then
                Response.Redirect("Default.aspx")
            End If

            BatchOrderNo.Text = _poRec.BatchNumber
            WorkflowStageName.Text = IIf(_poRec.POStatusID = POCreationRecord.Status.Approved, "Approved", "Worksheet")
            WarehouseDirect.Text = POCreationRecord.POBatchType.GetPOBatchTypeName(_poRec.BatchType)

            BasicSeasonal.SelectedValue = _poRec.BasicSeasonal

            'Load Allocation Events Based On Basic Seasonal Selected Value
            LoadAllocationEvents()

            If _poRec.VendorNumber.HasValue Then
                VendorNumber.Text = _poRec.VendorNumber.GetValueOrDefault
            End If
            VendorName.Text = _poRec.VendorName

            If _poRec.DateLastModified.HasValue Then
                LastModified.Text = String.Format("Last Modified By: {0}&nbsp;&nbsp;&nbsp;&nbsp;On: {1}", SmartValue(_poRec.ModifiedUserName, "CStr", ""), String.Format("{0:MMM dd yyyy h:mm tt}", _poRec.DateLastModified))
            End If

            If _poRec.POAllocationEventID.HasValue AndAlso AllocationEvent.Items.FindByValue(_poRec.POAllocationEventID.GetValueOrDefault) IsNot Nothing Then
                AllocationEvent.Items.FindByValue(_poRec.POAllocationEventID.GetValueOrDefault).Selected = True
            End If

            If _poRec.POSeasonalSymbolID.HasValue AndAlso SeasonalSymbol.Items.FindByValue(_poRec.POSeasonalSymbolID) IsNot Nothing Then
                SeasonalSymbol.Items.FindByValue(_poRec.POSeasonalSymbolID.GetValueOrDefault).Selected = True
            End If

            SeasonCode.SelectedValue = _poRec.SeasonCode

            'Make sure EventYear dropdown contains the Selected Date
            If _poRec.EventYear.HasValue Then
                If EventYear.Items.FindByValue(_poRec.EventYear) Is Nothing Then
                    EventYear.Items.Insert(1, _poRec.EventYear)
                End If
                EventYear.SelectedValue = _poRec.EventYear.GetValueOrDefault
            End If

            'Populate POG Data
            POGNumber.Text = _poRec.POGNumber
            If (_poRec.POGStartDate.HasValue) Then
                POGStartDate.Text = _poRec.POGStartDate.Value.ToString("M/d/yyyy")
            End If
            If (_poRec.POGEndDate.HasValue) Then
                POGEndDate.Text = _poRec.POGEndDate.Value.ToString("M/d/yyyy")
            End If

            'Populate Warehouse/Store Zone checkboxlists
            If _poRec.ID.HasValue Then
                PopulateLocations(0)
            End If

            'Populate POFlag Dropdown box with values from database
            If _poRec.POSpecialID.HasValue Then
                POSpecial.Items.FindByValue(_poRec.POSpecialID.GetValueOrDefault).Selected = True
                'POSpecial.SelectedValue = SmartValue(_poRec.POSpecialID, "CInt", "").ToString()
            End If

            'Populate Ship Point controls based off of Vendor Type (Import vs. Domestic)
            If _vendorRec.VendorType = ValidationHelper.VALIDATION_VENDOR_IMPORT_TYPES Then
                If ShipPointImport.Items.FindByValue(SmartValue(_poRec.ShipPointCode, "CStr", "")) IsNot Nothing Then
                    ShipPointImport.Items.FindByValue(SmartValue(_poRec.ShipPointCode, "CStr", "")).Selected = True
                End If
                'Check Import Order for Import Vendors
                ImportOrder.Checked = True
            Else
                ShipPointDomestic.Text = SmartValue(_poRec.ShipPointDescription, "CStr", "")
                ImportOrder.Checked = False
            End If

            If _poRec.PODepartmentID.HasValue Then
                DepartmentName.Text = _poRec.PODepartmentID.ToString & " - " & New DepartmentData().GetDepartmentRecord(_poRec.PODepartmentID).DeptName
            End If

            If _poRec.AllowSeasonalItemsBasicDC.HasValue Then
                AllowSeasonalItemsBasicDC.Checked = _poRec.AllowSeasonalItemsBasicDC
            Else
                AllowSeasonalItemsBasicDC.Checked = False
            End If

            'Set these values based off of Vendor data 
            EDIPO.Checked = _vendorRec.EDIFlag
            OrderCurrency.Text = _vendorRec.CurrencyCode


            If _poRec.PaymentTermsID.HasValue Then
                PaymentTerms.SelectedValue = _poRec.PaymentTermsID
            End If
            If _poRec.FreightTermsID.HasValue Then
                FreightTerms.SelectedValue = _poRec.FreightTermsID
            End If

            InternalComment.Text = _poRec.InternalComment
            ExternalComment.Text = _poRec.ExternalComment
            GeneratedComment.Text = _poRec.GeneratedComment

        Catch ex As Exception

            Logger.LogError(ex)
            Throw ex

        End Try

    End Sub

    Private Sub PopulateLocations(ByVal locationType As Integer)

		Dim locations As List(Of POCreationLocationRecord) = POCreationData.GetLocationsByPOID(_poRec.ID, locationType)

		For Each record In locations
			If _poRec.BatchType = "W" Then
				If BasicWarehouse.Items.FindByValue(record.POLocationID) IsNot Nothing Then
					BasicWarehouse.Items.FindByValue(record.POLocationID).Selected = True
				ElseIf SeasonalWarehouse.Items.FindByValue(record.POLocationID) IsNot Nothing Then
					SeasonalWarehouse.Items.FindByValue(record.POLocationID).Selected = True
				End If
			Else
				If StoreZone.Items.FindByValue(record.POLocationID) IsNot Nothing Then
					StoreZone.Items.FindByValue(record.POLocationID).Selected = True
				End If
			End If
		Next
		
        'Determine if the ALL Checkbox needs to be selected
        PopulatLocationALL(BasicWarehouse)
        PopulatLocationALL(SeasonalWarehouse)
        PopulatLocationALL(StoreZone)

    End Sub

    Private Sub PopulatLocationALL(ByVal checkBoxList As CheckBoxList)
        'Determine if ALL Checkbox is checked
        Dim isAllChecked As Boolean = True

        'IF the checkboxlist has items, make sure they are all selected
        If checkBoxList.Items.Count > 0 Then
            For i As Integer = 1 To checkBoxList.Items.Count - 1
                If (Not checkBoxList.Items(i).Selected) Then
                    isAllChecked = False
                End If
            Next
            If (isAllChecked) Then
                'All items are selected, so set the first item (ALL) as selected
                checkBoxList.Items(0).Selected = True
            End If
        End If
    End Sub

    Private Sub PopulatePOFromUI()
        _poRec.BasicSeasonal = BasicSeasonal.SelectedValue
        _poRec.POAllocationEventID = SmartValue(AllocationEvent.SelectedValue, "CInt", Nothing)
        _poRec.POSeasonalSymbolID = SmartValue(SeasonalSymbol.SelectedValue, "CInt", Nothing)
        _poRec.SeasonCode = SeasonCode.SelectedValue

        _poRec.EventYear = SmartValue(EventYear.SelectedValue, "CInt", Nothing)

        If _vendorRec.VendorType = ValidationHelper.VALIDATION_VENDOR_IMPORT_TYPES Then
            _poRec.ShipPointDescription = ShipPointImport.SelectedItem.Text
            _poRec.ShipPointCode = ShipPointImport.SelectedValue
        Else
            _poRec.ShipPointDescription = ShipPointDomestic.Text
        End If

        _poRec.POGNumber = SmartValue(POGNumber.Text, "CStr", Nothing)
        _poRec.POGStartDate = SmartValue(POGStartDate.Text, "CDate", Nothing)
        _poRec.POGEndDate = SmartValue(POGEndDate.Text, "CDate", Nothing)

        _poRec.POSpecialID = SmartValue(POSpecial.SelectedValue, "CInt", Nothing)

        _poRec.PaymentTermsID = SmartValue(PaymentTerms.SelectedValue, "CInt", Nothing)
        _poRec.FreightTermsID = SmartValue(FreightTerms.SelectedValue, "CInt", Nothing)

        _poRec.InternalComment = InternalComment.Text
        _poRec.ExternalComment = ExternalComment.Text
        _poRec.GeneratedComment = GeneratedComment.Text
        _poRec.AllowSeasonalItemsBasicDC = AllowSeasonalItemsBasicDC.Checked
    End Sub

    Private Sub PopulateSeasonalText()
        GeneratedComment.Text = ""
        If SeasonalSymbol.SelectedIndex > 0 Then
            GeneratedComment.Text = "USE SEASONAL SYMBOL " & SeasonalSymbol.SelectedItem.Text ' & System.Environment.NewLine
        End If
        If SeasonCode.SelectedValue.Length > 0 Then
            If GeneratedComment.Text.Length > 0 Then
                GeneratedComment.Text += " - SEASON CODE " & SeasonCode.SelectedValue
            Else
                GeneratedComment.Text = "USE SEASON CODE " & SeasonCode.SelectedValue
            End If
        End If
    End Sub

    Protected Sub PODetail_Click(ByVal sender As Object, ByVal e As EventArgs) Handles PODetailLink.Click

        ValidatePOLocations()

        'RULE: A Location needs to be specified in order for the PO to Save
        If (_isLocationSelected) Then
            'Do not Save or perform Validation if the record is being Validated (via Webservices)
            If Not _isValidating Then
                'Save and Validate PO Header information, then direct user to "PO Detail" tab
                SaveForm()

                'Validate the Header and Locations
                ValidatePOHeader()
                UpdateValidity()

            End If

            Response.Redirect("POCreationDetails.aspx?POID=" & _poRec.ID.GetValueOrDefault)
        End If

    End Sub

    Protected Sub Save_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Save.Click

        ValidatePOLocations()

        'RULE: A Location needs to be specified in order for the PO to Save
        If (_isLocationSelected) Then
            'Override dirty flag to force save
            hdnPageIsDirty.Value = "1"
            SaveForm()

            'Validate the Header, Locations, and Update validity
            ValidatePOHeader()
            UpdateValidity()
        End If
    End Sub

    Protected Sub SaveAndClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles SaveAndClose.Click

        ValidatePOLocations()

        'RULE: A Location needs to be specified in order for the PO to Save
        If (_isLocationSelected) Then

            'Override dirty flag to force save
            hdnPageIsDirty.Value = "1"
            SaveForm()

            'Validate the Header, Locations, and Update validity
            ValidatePOHeader()
            UpdateValidity()

            Response.Redirect("default.aspx")
        End If
    End Sub

    Private Sub SaveForm()

		'Only save if user has access to the PO
        If _userHasAccess And hdnPageIsDirty.Value = "1" Then
            '************************************************************************
            ' Save Purchase Order Info
            '************************************************************************
            'RULE: IF The Allocation Event changes, Event Year changes, or Ship Point (CODE) changes from non-blank to a value then NBD/NAD Dates need to be cleared and re-validated
            Dim shipPointCode As String = DataHelper.SmartValue(_poRec.ShipPointCode, "CStr", "")
            If (DataHelper.SmartValue(_poRec.POAllocationEventID, "CStr", "").ToString <> AllocationEvent.SelectedValue) _
                Or (shipPointCode <> "" AndAlso shipPointCode <> ShipPointImport.SelectedValue) _
                Or DataHelper.SmartValue(_poRec.EventYear, "CSTr", "") <> EventYear.SelectedValue Then

                'Clear all dates, and invalidate Detail
                ClearLocationDates()
            End If

            'RULE: IF The Allocation Event, Ship Point (CODE), or Event Year changes, then PODetail needs to be re-validated
            If (DataHelper.SmartValue(_poRec.POAllocationEventID, "CStr", "").ToString <> AllocationEvent.SelectedValue) _
               Or (shipPointCode <> ShipPointImport.SelectedValue) _
               Or DataHelper.SmartValue(_poRec.EventYear, "CSTr", "") <> EventYear.SelectedValue Then
                'Set PODetail as invalid
                _poRec.IsDetailValid = False
            End If

            'If the Allocation date changes, update the PO Allocation dirty flag
            If (DataHelper.SmartValue(_poRec.POAllocationEventID, "CStr", "").ToString <> AllocationEvent.SelectedValue) Then
                _poRec.IsAllocDirty = True
            End If

            'Populate the SeasonalText in the General Comments field
            PopulateSeasonalText()

            PopulatePOFromUI()

            POCreationData.SaveRecord(_poRec, Session("UserID"), POCreationData.Hydrate.All)

            '************************************************************************
            ' Save Purchase Order Location Info
            '************************************************************************
            Dim isLocationChanged As Integer = 0
            If _poRec.BatchType = "W" Then
                'ADD, then DELETE Locations.  This will ensure that SKUs are not accidently deleted when a Location is removed.
                isLocationChanged += SaveLocations(BasicWarehouse)
                isLocationChanged += SaveLocations(SeasonalWarehouse)
                isLocationChanged += RemoveLocations(BasicWarehouse)
                isLocationChanged += RemoveLocations(SeasonalWarehouse)
            ElseIf _poRec.BatchType = "D" Then
                'ADD then DELETE locations
                isLocationChanged += SaveLocations(StoreZone)
                isLocationChanged += RemoveLocations(StoreZone)
            End If

            'Change Validity to unknown so user must visit detail page to revalidate
            If isLocationChanged > 0 Then
                _poRec.IsDetailValid = Nothing
                POCreationData.UpdateRecordBySystem(_poRec, POCreationData.Hydrate.All)
            End If

            'Reset hidden page dirty value after save
            hdnPageIsDirty.Value = "0"
        End If

    End Sub

    Private Function RemoveLocations(ByVal checkBoxList As CheckBoxList) As Integer
        Dim isLocationChanged As Integer = 0

        'RULE: Locations cannot be updated for AST orders
        If (_poRec.POConstructID <> 2) Then
            'Loop through and Delete locations.  
            For Each location As ListItem In checkBoxList.Items
                If location.Value <> "0" Then
                    If Not location.Selected Then
                        isLocationChanged += POCreationData.DeleteLocation(_poRec.ID, location.Value)
                    End If
                End If
            Next
        End If

        Return isLocationChanged
    End Function

    Private Function SaveLocations(ByVal checkBoxList As CheckBoxList) As Integer
        Dim isLocationChanged As Integer = 0

        'RULE: Locations cannot be updated for AST orders
        If (_poRec.POConstructID <> 2) Then
            'Loop through and  Add Locations
            For Each location As ListItem In checkBoxList.Items
                'Ignore Unchecked/CheckAll
                If location.Value <> "0" Then
                    If location.Selected Then
                        'NAK 7/25/2011:  Changing naming schema on External Reference ID due to RMS character limit of 15.
                        Dim locationConstruct As String = GetLocationConstruct(location.Text)
                        Select Case locationConstruct
                            Case "ALASKA"
                                locationConstruct = "A"
                            Case "CANADA"
                                locationConstruct = "C"
                            Case "US"
                                locationConstruct = "U"
                        End Select

                        isLocationChanged += POCreationData.AddLocation(_poRec.ID, location.Value, _poRec.BatchNumber & "-" & locationConstruct, Session("UserID"))
                    End If
                End If
            Next
        End If

        Return isLocationChanged
    End Function

    Private Sub UpdateValidity()

        'Do not update the validity if the record is in the process of being validated
        If (Not _isValidating) And _userHasAccess Then
            'Update the PO Record in the Database to preserve the "IsHeaderValid" and "IsDetailValid" settings
            _poRec.IsHeaderValid = _isHeaderValid
            POCreationData.UpdateRecordBySystem(_poRec, POCreationData.Hydrate.All)
        End If

        'Display Header Tab Validity Image
        If Not _poRec.IsHeaderValid.HasValue Then
            POHeaderImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Unknown, True)
        ElseIf _poRec.IsHeaderValid Then
            POHeaderImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Valid, True)
        Else
            POHeaderImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.NotValid, True)
        End If

        'Display Detail Tab Validity Image
        If Not _poRec.IsDetailValid.HasValue Then
            PODetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Unknown, True)
        ElseIf _poRec.IsDetailValid Then
            PODetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Valid, True)
        Else
            PODetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.NotValid, True)
        End If


    End Sub

    Private Sub ValidateFreightTerms()

        'RULE:  If the user selects a Vendor Freight Type that is different from the actual Vendor Freight Type, display a warning to notify user.
        If (_vendorRec.FreightTerms.Length > 0) Then
            Dim vendorFreightID As Integer = Convert.ToInt32(_vendorRec.FreightTerms)
            Dim vendorFreightTerm As String = ""

            'Get Vendor's selection using the dropdown as a lookup
            For Each item As ListItem In FreightTerms.Items
                If (item.Value = vendorFreightID.ToString) Then
                    vendorFreightTerm = item.Text
                End If
            Next

            'Compare Selected Freight Term to Vendor Freight Term
            If FreightTerms.SelectedItem.Text <> vendorFreightTerm AndAlso vendorFreightTerm.Length > 0 Then
                warningFreightTerms.Visible = True
                warningFreightTerms.Text = "Vendor's Freight Terms: " + vendorFreightTerm
            Else
                warningFreightTerms.Visible = False
            End If
        End If

    End Sub

    Private Sub ValidatePaymentTerms()

        'RULE:  If the user selects a Vendor Payment Type that is different from the actual Vendor Payment Type, display a warning to notify user.
        Dim selectedTerm As String = PaymentTermsData.GetByID(CInt(IIf(PaymentTerms.SelectedIndex > 0, PaymentTerms.SelectedValue, 0))).Terms
        Dim vendorPaymentTerm As String = _vendorRec.PaymentTerms

        If selectedTerm <> vendorPaymentTerm AndAlso vendorPaymentTerm.Length > 0 Then
            warningPaymentTerms.Visible = True
            warningPaymentTerms.Text = "Vendor's Payment Terms: " & _vendorRec.PaymentTerms & "-" & PaymentTermsData.GetByTerm(vendorPaymentTerm).TermDescription
        Else
            warningPaymentTerms.Visible = False
        End If
    End Sub

    Private Sub ValidatePOHeader()

        Dim vr As New ValidationRecord()
        Dim vrDetail As New ValidationRecord()

        If Not ValidationHelper.SkipValidation(GetStageType(_poRec.WorkflowStageID)) Then
            'Validate PO_Creation_Header 
            vr = ValidationHelper.ValidateData(_poRec)

            'RULE: If the selected vendor is Import, then the user must select a Ship Point from a predetermined list of values
            If _vendorRec.VendorType = ValidationHelper.VALIDATION_VENDOR_IMPORT_TYPES Then
                If ShipPointImport.SelectedValue = "" Then
                    vr.Add("ShipPointImport", "Ship Point must be selected", NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                End If
            End If

            'RULE: Error if the user selects a seasonal symbol on a Basic PO
            If BasicSeasonal.SelectedValue = "B" AndAlso Not SeasonalSymbol.SelectedValue = "" Then
                vr.Add("SeasonalSymbol", "Seasonal Symbol cannot be selected for a Basic PO", NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
            End If
            If BasicSeasonal.SelectedValue = "B" AndAlso Not SeasonCode.SelectedValue = "" Then
                vr.Add("SeasonalSymbol", "Season Code cannot be selected for a Basic PO", NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
            End If
        End If

        'Add Header Errors to Validation Summary so they appear on the page
        ValidationHelper.AddValidationSummaryErrors(ValidationSummary, vr)

        _isHeaderValid = _isHeaderValid And vr.IsValid

        'Compare PO Payment/Freight Terms to Vendor's, display warning if they do not match
        ValidateFreightTerms()
        ValidatePaymentTerms()
    End Sub

    Private Sub ValidatePOLocations()

        Dim vr As New ValidationRecord()

        'KEEP LOCATION VAILDATION IN PAGE, SINCE IT IS INTEGRAL TO PAGE DISPLAY/FUNCTIONALITY
        If _poRec.BatchType = "W" Then

            Dim basicWarehousesChosen As Integer = 0
            Dim cutoverWarehousesChosen As Integer = 0
            For Each warehouse As ListItem In BasicWarehouse.Items
                If warehouse.Value <> "0" Then
                    If InStr(warehouse.Text, "(basic") Then
                        cutoverWarehousesChosen += SmartValue(warehouse.Selected, "CBit", 0)
                    Else
                        basicWarehousesChosen += SmartValue(warehouse.Selected, "CBit", 0)
                    End If
                End If
            Next

            Dim seasonalWarehousesChosen As Integer = 0
            For Each warehouse As ListItem In SeasonalWarehouse.Items
                If warehouse.Value <> "0" Then
                    seasonalWarehousesChosen += SmartValue(warehouse.Selected, "CBit", 0)
                End If
            Next

            'RULE: User should not be allowed to select both basic and seasonal warehouses on the same PO header
            If basicWarehousesChosen > 0 AndAlso seasonalWarehousesChosen > 0 Then
                vr.Add("", "Cannot select both basic and seasonal warehouses on the same purchase order", NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
            End If

            'RULE: User must select at least one Location
            If basicWarehousesChosen = 0 AndAlso seasonalWarehousesChosen = 0 AndAlso cutoverWarehousesChosen = 0 Then
                vr.Add("", "At least one warehouse must be selected", NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                _isLocationSelected = False
            End If

        ElseIf _poRec.BatchType = "D" Then

            Dim storeZoneChosen As Integer = 0
            For Each item As ListItem In StoreZone.Items
                storeZoneChosen += SmartValue(item.Selected, "CBit", 0)
            Next

            'RULE: User must select at least one Location
            If storeZoneChosen = 0 Then
                vr.Add("StoreZone", "At least one zone must be selected", NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                _isLocationSelected = False
            End If

        End If

        'Add Errors to Validation Summary so they appear on the page
        ValidationHelper.AddValidationSummaryErrors(ValidationSummary, vr)

        _isHeaderValid = _isHeaderValid And vr.IsValid

    End Sub

    Private Sub ClearLocationDates()
        Dim locationList As List(Of POCreationLocationRecord) = POCreationData.GetLocationsByPOID(_purchaseOrderID)
        For Each location As POCreationLocationRecord In locationList
            location.NotBefore = Nothing
            location.NotAfter = Nothing
            location.EstimatedInStockDate = Nothing

            POCreationData.UpdateLocation(location, Session("UserID"))
        Next
    End Sub

    Private Function GetLocationConstruct(ByVal location As String) As String
        If (location.IndexOf("-") > 0) Then
            Return location.Substring(0, location.IndexOf("-")).Trim
        Else
            Return location
        End If

    End Function

    Private Sub ImplementFieldLocking()

        'If the record is validating, then lock the entire page and hide the Save buttons
        If _isValidating Then
            BasicSeasonal.RenderReadOnly = True
            AllocationEvent.RenderReadOnly = True
            SeasonalSymbol.RenderReadOnly = True
            SeasonCode.RenderReadOnly = True
            EventYear.RenderReadOnly = True
            ShipPointDomestic.RenderReadOnly = True
            ShipPointImport.RenderReadOnly = True
            POSpecial.RenderReadOnly = True
            PaymentTerms.RenderReadOnly = True
            FreightTerms.RenderReadOnly = True
            InternalComment.RenderReadOnly = True
            ExternalComment.RenderReadOnly = True
            GeneratedComment.RenderReadOnly = True
            BasicWarehouse.RenderReadOnly = True
            SeasonalWarehouse.RenderReadOnly = True
            StoreZone.RenderReadOnly = True
            AllowSeasonalItemsBasicDC.RenderReadOnly = True

            _pogStartDateLocked = True
            _pogEndDateLocked = True

            'Hide Save Buttons
            Save.Visible = False
            SaveAndClose.Visible = False
        Else
            Dim fl As New NovaLibra.Coral.Data.Michaels.FieldLockingData
            Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = fl.GetFieldLockedControls(Session("UserID"), MetadataTable.POCreation, _poRec.WorkflowStageID, True)

            For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
                'Check to see if any Controls were specified for the Field Locked Column
                If col.ControlNames.Count > 0 Then
                    'Loop through the list of controls, and lock those controls
                    For Each con As String In col.ControlNames
                        Lockfield(con, col.Permission)
                        If con = "SeasonalSymbol" Then Lockfield("SeasonCode", col.Permission)
                    Next
                Else
                    'No specific controls were specified, so use the column name to lock on
                    If col.ColumnName <> "" Then
                        Lockfield(col.ColumnName, col.Permission)
                        If col.ColumnName = "SeasonalSymbol" Then Lockfield("SeasonCode", col.Permission)
                    End If
                End If
            Next

            If POGStartDate.RenderReadOnly Then
                _pogStartDateLocked = True
            End If

            If POGEndDate.RenderReadOnly Then
                _pogEndDateLocked = True
            End If

            'Display Save Buttons if user has Access to the PO
            If _userHasAccess Then
                Save.Visible = True
                SaveAndClose.Visible = True
            Else
                Save.Visible = False
                SaveAndClose.Visible = False
            End If

            'RULE: If this is an AST order, then always lock the locations and the BasicSeasonal dropdown
            If _poRec.POConstructID = 2 Then
                BasicSeasonal.RenderReadOnly = True
                BasicWarehouse.RenderReadOnly = True
                SeasonalWarehouse.RenderReadOnly = True
                StoreZone.RenderReadOnly = True
                'NAK 6/21/2011:  Per Michaels Request, Event Year should be editable for AST orders
                'EventYear.RenderReadOnly = True
            End If
        End If

    End Sub

    Protected Sub BasicSeasonal_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles BasicSeasonal.SelectedIndexChanged

        LoadAllocationEvents()

        If _poRec.POAllocationEventID.HasValue AndAlso AllocationEvent.Items.FindByValue(_poRec.POAllocationEventID.GetValueOrDefault) IsNot Nothing Then
            AllocationEvent.Items.FindByValue(_poRec.POAllocationEventID.GetValueOrDefault).Selected = True
        End If

        'Populate _poRec with values from the UI
        PopulatePOFromUI()

        'Validate PO, and update validity status
        ValidatePOHeader()
        ValidatePOLocations()
        UpdateValidity()

    End Sub

End Class
