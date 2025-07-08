Imports System.Data
Imports NovaLibra.Common.Utilities.DataHelper
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Coral.Data.Michaels
Imports System.Collections.Generic
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Common

Partial Class POMaintHeader
    Inherits MichaelsBasePage

	Private _purchaseOrderID As Integer = 0
	Private _poRec As POMaintenanceRecord
	Private _vendorRec As VendorRecord
	Private _isDetailValid As Boolean = True
	Private _isHeaderValid As Boolean = True
	Private _revisionNumber As Double = 0.0
	Private _isRevision As Boolean = False
	Private _isValidating As Boolean = False
	Private _userHasAccess As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Check Session
        SecurityCheckRedirect()

		'Get PO ID
		If Request.QueryString("POID") IsNot Nothing Then
			POID.Value = SmartValue(Request.QueryString("POID"), "CLng", 0)
		End If
		_purchaseOrderID = POID.Value

        'Check Permission
        If Not SecurityCheckHasAccess("SPD", "SPD.ACCESS.POMAINT", Session("UserID")) Then
            Response.Redirect("default.aspx")
		End If
		'Check User Access to PO
        _userHasAccess = POMaintenanceData.ValidateUserForPO(_purchaseOrderID, Session("UserID"))

		'Get Revision if one is specified.  Compare it to the Current Reivision Number to see if this is a Revision
		If Not Request.QueryString("Revision") Is Nothing Then
			_revisionNumber = DataHelper.SmartValue(Request.QueryString("Revision"), "CDbl", 0)
			Dim currentRevisionNumber = POMaintenanceData.GetCurrentRevision(_purchaseOrderID)
			If (_revisionNumber <> currentRevisionNumber) Then
				_isRevision = True
			End If
		End If

		'Get Data, and verify PO Exists
		If (_isRevision) Then
			_poRec = POMaintenanceData.GetRevisionRecord(_purchaseOrderID, _revisionNumber)
		Else
			_poRec = POMaintenanceData.GetRecord(_purchaseOrderID)
		End If

		If Not _poRec.ID.HasValue Then
			Response.Redirect("Default.aspx")
		End If
		_vendorRec = (New VendorData).GetVendorRecord(_poRec.VendorNumber)

		If Not Page.IsPostBack Then
			InitializePage()
			PopulatePage()

			'Do not perform validation for revision records
			If Not (_isRevision) And Not (_isValidating) Then
				'Validate the Header, Locations, and Detail
				ValidatePOHeader()
			End If

			UpdateValidity()

			'Lock form on Revisions, or Implement Form locking if current revision
			ImplementFieldLocking()
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

        LoadRevisions()

        'RULE: Event Year should contain blank, this year, and next year
        EventYear.Items.Add("")
		EventYear.Items.Add(DateTime.Now.Year)
		EventYear.Items.Add(DateTime.Now.Year + 1)

		'RULE: IF Vendor is Import, display Ship Point Import drop down.
		'       ELSE Display Ship Point Domestic Textbox
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
		ElseIf _poRec.BatchType = "D" Then
			StoreZoneTR.Visible = True
			LoadLocationByType(Nothing, StoreZone)
		End If

		'Load Payment Terms and Special Flags
		LoadPaymentTerms()
		LoadFreightTerms()
		LoadPOSpecial()

	End Sub

    Private Sub LoadAllocationEvents()

        'Add Blank at the beginning of the AllocationEvent Dropdown
        AllocationEvent.Items.Add(New ListItem("", ""))

        Dim SQLStr As String = "PO_Allocation_Event_Get_All"

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
                        AllocationEvent.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("ALLOC_EVENT_ID")) & "-" & DataHelper.SmartValuesDBNull(reader.Item("ALLOC_DESC")), reader.Item("ID")))
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

        'Add Blank at the top of the SeasonalSymbol DropDown
        SeasonalSymbol.Items.Add(New ListItem("", ""))

        Dim SQLStr As String = "PO_Seasonal_Symbol_Get_All"

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

        'Add Blank at the top of the ShipPointImport Dropdown, and make sure it is Visible
        ShipPointImport.Items.Add(New ListItem("", ""))
        ShipPointImport.Visible = True

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
                cmd.Parameters.Add("@Maint_POID", SqlDbType.BigInt).Value = _purchaseOrderID
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

    End Sub

    Private Sub LoadPaymentTerms()

        'Add Blank at the top of the PaymentTerms Dropdown
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

        'Add a 'None' option at the top of the POSpecial DropDown
        POSpecial.Items.Add(New ListItem("None", 0))

        Dim SQLStr As String = "PO_Special_Get_By_Batch_Type"

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

	End Sub

    Private Sub PopulatePage()
        Try
            If Not _poRec.POLocationID.HasValue Then
                PODetailTab.Visible = False
            Else
                PODetailTab.Visible = True
            End If

            '************************************************************************
            ' Load Purchase Order Info
            '************************************************************************

            PurchaseOrderNo.Text = _poRec.PONumber
            BatchOrderNo.Text = _poRec.BatchNumber
            StatusName.Text = POMaintenanceRecord.GetStatusName(_poRec.POStatusID)
            WarehouseDirect.Text = POMaintenanceRecord.POBatchType.GetPOBatchTypeName(_poRec.BatchType)

            BasicSeasonal.SelectedValue = _poRec.BasicSeasonal

            'Load Allocation Events Based On Basic Seasonal Selected Value
            LoadAllocationEvents()

            If _poRec.VendorNumber.HasValue Then
                VendorNumber.Text = _poRec.VendorNumber.GetValueOrDefault
            End If
            VendorName.Text = _poRec.VendorName

            If _poRec.PODepartmentID.HasValue Then
                DepartmentName.Text = _poRec.PODepartmentID.ToString & " - " & New DepartmentData().GetDepartmentRecord(_poRec.PODepartmentID).DeptName
            End If

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

            If _poRec.POLocationID.HasValue Then
                If _poRec.BatchType = "W" Then
                    If BasicWarehouse.Items.FindByValue(_poRec.POLocationID) IsNot Nothing Then
                        BasicWarehouse.Items.FindByValue(_poRec.POLocationID).Selected = True
                    ElseIf SeasonalWarehouse.Items.FindByValue(_poRec.POLocationID) IsNot Nothing Then
                        SeasonalWarehouse.Items.FindByValue(_poRec.POLocationID).Selected = True
                    End If
                Else
                    If StoreZone.Items.FindByValue(_poRec.POLocationID) IsNot Nothing Then
                        StoreZone.Items.FindByValue(_poRec.POLocationID).Selected = True
                    End If
                End If
            End If

			'Set these values based off of Vendor data 
			EDIPO.Checked = _vendorRec.EDIFlag
			OrderCurrency.Text = _vendorRec.CurrencyCode

            'Populate POFlag Dropdown box with values from database
            If _poRec.POSpecialID.HasValue Then
                POSpecial.SelectedValue = SmartValue(_poRec.POSpecialID, "CInt", "").ToString()
            End If

            'Populate Ship Point controls based off of Vendor Type (Import vs. Domestic)
			If _vendorRec.VendorType = ValidationHelper.VALIDATION_VENDOR_IMPORT_TYPES Then
				If ShipPointImport.Items.FindByValue(SmartValue(_poRec.ShipPointCode, "CStr", "")) IsNot Nothing Then
					ShipPointImport.Items.FindByValue(SmartValue(_poRec.ShipPointCode, "CStr", "")).Selected = True
				End If
				'Check Import Orders when VendorType is Import
				ImportOrder.Checked = True
			Else
				ShipPointDomestic.Text = SmartValue(_poRec.ShipPointDescription, "CStr", "")
				ImportOrder.Checked = False
			End If

            'Populate Payment and Freight Terms
            If _poRec.PaymentTermsID.HasValue Then
                PaymentTerms.SelectedValue = _poRec.PaymentTermsID
            End If
            If _poRec.FreightTermsID.HasValue Then
				FreightTerms.SelectedValue = _poRec.FreightTermsID.Value
            End If

            'Populate Comment Fields
            InternalComment.Text = _poRec.InternalComment
            ExternalComment.Text = _poRec.ExternalComment
			GeneratedComment.Text = _poRec.GeneratedComment

        Catch ex As Exception

            Logger.LogError(ex)
            Throw ex

        End Try
    End Sub

    Private Sub PopulatePOFromUI()

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

        _poRec.PaymentTermsID = SmartValue(PaymentTerms.SelectedValue, "CInt", Nothing)
        _poRec.InternalComment = InternalComment.Text
        _poRec.ExternalComment = ExternalComment.Text
        _poRec.GeneratedComment = GeneratedComment.Text
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

    Private Sub ValidateFreightTerms()

        'TODO: Should Freight Term warning appear since the user can not edit the Freight Term field??
        'RULE:  If the user selects a Vendor Freight Type that is different from the actual Vendor Freight Type, display a warning to notify user.
        Dim vendorFreight = _vendorRec.FreightTerms
        'If FreightTerms.SelectedItem.Text <> vendorFreight AndAlso vendorFreight.Length > 0 Then
        '    warningFreightTerms.Visible = True
        '    warningFreightTerms.Text = "Vendor's Freight Terms: " + vendorFreight
        'Else
        '    warningFreightTerms.Visible = False
        'End If
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

    Protected Sub PaymentTerms_Changed(ByVal sender As Object, ByVal e As EventArgs) Handles PaymentTerms.SelectedIndexChanged
		ValidatePaymentTerms()
	End Sub

    Protected Sub PODetail_Click(ByVal sender As Object, ByVal e As EventArgs) Handles PODetailLink.Click
		'Do not Save or perform Validation if the record is being Validated (via Webservices) or is an old Revision
		If Not (_isRevision) And Not _isValidating Then
			SaveForm()

			'Validate the Header
			ValidatePOHeader()
			UpdateValidity()
		End If

		'Direct user to "PO Detail" tab
		Response.Redirect("POMaintDetails.aspx?POID=" + _purchaseOrderID.ToString + "&Revision=" + ddlRevisions.SelectedValue)
    End Sub

	Protected Sub Revision_IndexChanged(ByVal sender As Object, ByVal e As EventArgs) Handles ddlRevisions.SelectedIndexChanged
		'Reload page with specified Revision
		Response.Redirect("POMaintHeader.aspx?POID=" + _purchaseOrderID.ToString + "&Revision=" + ddlRevisions.SelectedValue)
	End Sub

	Protected Sub EditRevision_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnEditRevision.Click

        Dim previousWorkflowStage As Integer = _poRec.WorkflowStageID

        _poRec.WorkflowStageID = POMaintenanceData.GetInitialWorkflowStageID(_poRec.InitiatorRoleID)
        _poRec.POStatusID = POMaintenanceRecord.Status.Revised
		POMaintenanceData.UpdateRecordBySystem(_poRec, POMaintenanceData.Hydrate.None)

        'Save record for PO Creation in History Stage Durations table
        POMaintenanceData.SaveHistoryStageDuration(_poRec.ID, "REVISION", previousWorkflowStage, _poRec.WorkflowStageID, Session("UserID"))

        Response.Redirect("POMaintHeader.aspx?POID=" & _purchaseOrderID)
	End Sub

    Protected Sub Save_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Save.Click
        'Override dirty flag to force save
        hdnPageIsDirty.Value = "1"
        SaveForm()

        'Validate the Header and update validity
        ValidatePOHeader()
        UpdateValidity()

    End Sub

	Protected Sub SaveAndClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles SaveAndClose.Click
        'Override dirty flag to force save
        hdnPageIsDirty.Value = "1"
		SaveForm()

        'Validate the Header and update validity
		ValidatePOHeader()
		UpdateValidity()

		Response.Redirect("default.aspx")
	End Sub

	Private Sub SaveForm()

		'Only save if user has access to the PO
        If _userHasAccess And hdnPageIsDirty.Value = "1" Then
            'Must Be An Existing Batch
            If Not _poRec.ID.HasValue Then
                Response.Redirect("Default.aspx")
            End If

            '************************************************************************
            ' Save Purchase Order Info
            '************************************************************************
            'RULE: IF The Allocation Event changes, Event Year changes, or Ship Point (CODE) changes from non-blank to a value then NBD/NAD Dates need to be cleared and re-validated
            Dim shipPointCode As String = DataHelper.SmartValue(_poRec.ShipPointCode, "CStr", "")
            If (DataHelper.SmartValue(_poRec.POAllocationEventID, "CStr", "").ToString <> AllocationEvent.SelectedValue) _
                Or (shipPointCode <> "" AndAlso shipPointCode <> ShipPointImport.SelectedValue) _
                Or DataHelper.SmartValue(_poRec.EventYear, "CSTr", "") <> EventYear.SelectedValue Then

                'Clear all dates, and invalidate Detail
                _poRec.NotBefore = Nothing
                _poRec.NotAfter = Nothing
                _poRec.EstimatedInStockDate = Nothing
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

            POMaintenanceData.SaveRecord(_poRec, Session("UserID"), POMaintenanceData.Hydrate.All)

            'Reset hidden page dirty value after save
            hdnPageIsDirty.Value = "0"
        End If

	End Sub

	Private Sub ImplementFieldLocking()
		'IF Revision <> CurrentRevision, Then LOCK Everything
		If (_isRevision Or _isValidating) Then
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

			'Hide Buttons
			Save.Visible = False
			SaveAndClose.Visible = False
			btnEditRevision.Visible = False
		Else

			'Set Readonly flag for fields that are locked
			Dim fl As New NovaLibra.Coral.Data.Michaels.FieldLockingData
			Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = fl.GetFieldLockedControls(Session("UserID"), MetadataTable.POMaintenance, _poRec.WorkflowStageID, True)

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
					If col.ColumnName <> "" Then Lockfield(col.ColumnName, col.Permission)
                    If col.ColumnName = "SeasonalSymbol" Then Lockfield("SeasonCode", col.Permission)
                End If
            Next

            'Display Save Buttons if user has Access to the PO
            If _userHasAccess Then
                Save.Visible = True
                SaveAndClose.Visible = True
            Else
                Save.Visible = False
                SaveAndClose.Visible = False
            End If

            'RULE: If this is an AST order, then always lock the locations and the BasicSeasonal dropdown
            'NAK 6/21/2011:  Per Michaels Request, Event Year should be editable for AST orders
            'If _poRec.POConstructID = 2 Then
            ' EventYear.RenderReadOnly = True
            'End If

            'RULE: Display Edit button if PO is in a "Completed" workflow stage, and User is the same department as the PO and has the same role as the original originator, and the PO is revisable
            Dim initWFStageID As Integer = POMaintenanceData.GetInitialWorkflowStageID(_poRec.InitiatorRoleID)
            If (GetStageType(_poRec.WorkflowStageID) = WorkflowStageType.Completed) And _
            POMaintenanceData.ValidateWorkflowAccess(initWFStageID, _poRec.WorkflowDepartmentID, Session("UserID")) And _
            Not (_poRec.IsUnrevisable) Then
                btnEditRevision.Visible = True
            End If


        End If
	End Sub

	Private Sub UpdateValidity()
		'Do Not update validity in database if this is a Revision or if the record is being Validated
        If (Not _isRevision) And (Not _isValidating) And _userHasAccess Then
            'Update the PO Record in the Database to preserve the "IsHeaderValid" and "IsDetailValid" settings
            _poRec.IsHeaderValid = _isHeaderValid
            POMaintenanceData.UpdateRecordBySystem(_poRec, POCreationData.Hydrate.All)
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

            'not sure if these rules should be here or not 2022-06-23
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

    Protected Sub BasicSeasonal_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles BasicSeasonal.SelectedIndexChanged

        LoadAllocationEvents()

        If _poRec.POAllocationEventID.HasValue AndAlso AllocationEvent.Items.FindByValue(_poRec.POAllocationEventID.GetValueOrDefault) IsNot Nothing Then
            AllocationEvent.Items.FindByValue(_poRec.POAllocationEventID.GetValueOrDefault).Selected = True
        End If

        PopulatePOFromUI()

        ValidatePOHeader()
        UpdateValidity()

    End Sub

End Class


