Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Text
Imports System.Xml
Imports System.Xml.XPath

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.SystemFrameworks
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports WebConstants

Partial Class detail
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler


#Region "Attributes and Properties"

    Private _callbackArg As String = ""

    Public Const CALLBACK_SEP As String = "{{|}}"
    ' FJL Jan 2010 for Item Locking
    Private WorkFlowStageID As Integer = 0

    Private _validFlag As ItemValidFlag = ItemValidFlag.Unknown
    Private _validWasUnknown As Boolean = False

    Private _batchID As Long = -1

    Public Function GetItemHeaderID() As String
        Return hid.Value
    End Function

    Public Property StageID() As Long
        Get
            Dim o As Object = ViewState.Item("StageID")
            If Not o Is Nothing Then
                Return CType(o, Long)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Long)
            ViewState.Item("StageID") = value
        End Set
    End Property

    Public Property IsPack() As Boolean
        Get
            Dim o As Object = ViewState.Item("IsPack")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            ViewState.Item("IsPack") = value
        End Set
    End Property

    Public Property StageType() As Models.WorkflowStageType
        Get
            Dim o As Object = ViewState.Item("StageType")
            If Not o Is Nothing Then
                Return CType(o, Models.WorkflowStageType)
            Else
                Return Models.WorkflowStageType.Unknown
            End If
        End Get
        Set(ByVal value As Models.WorkflowStageType)
            ViewState.Item("StageType") = value
        End Set
    End Property

    Public ReadOnly Property ItemHeaderID() As Long
        Get
            Return DataHelper.SmartValues(GetItemHeaderID, "long", False)
        End Get
    End Property

    Public Property ShowRMSFields() As Boolean
        Get
            Dim o As Object = ViewState.Item("ShowRMSFields")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            ViewState.Item("ShowRMSFields") = value
        End Set
    End Property



    Public ReadOnly Property RecordType() As Integer
        Get
            Return WebConstants.RECTYPE_DOMESTIC_ITEM_HEADER
        End Get
    End Property

#End Region

#Region "Page Events"

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the page
        'Me.Page.Response.Buffer = True
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim itemHeaderID As Long = 0

        If Not Me.IsCallback Then

            SecurityCheckRedirect()

            ' check to make sure the URL is OK
            If CType(Session(cHEADERID), String) <> CType(Request("hid"), String) Then
                Session(cHEADERID) = Nothing
                Response.Redirect("default.aspx")
            End If

            ' make sure __doPostBack is generated
            ClientScript.GetPostBackEventReference(Me, String.Empty)

            ' callback
            Dim cbReference As String
            cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", _
                "ReceiveServerData", "context")
            Dim callbackScript As String = ""
            callbackScript &= "function CallServer(arg, context)" & _
                "{" & cbReference & "; }"
            Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), _
                "CallServer", callbackScript, True)

            ' **********
            ' * header *
            ' **********

            If Not IsPostBack Then
                ' load list values
                Dim lvgs As ListValueGroups = FormHelper.LoadListValues("YESNO,STOCKCAT,ITEMTYPE,ITEMTYPEATTRIB,INVCONTROL,FREIGHTTERMS,SKUGROUP")
                'FormHelper.LoadListFromListValues(rebuyYN, lvgs.GetListValueGroup("YESNO"), True)
                'FormHelper.LoadListFromListValues(replenishYN, lvgs.GetListValueGroup("YESNO"), True)
                'FormHelper.LoadListFromListValues(storeOrderYN, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(stockCategory, lvgs.GetListValueGroup("STOCKCAT"), True)
                FormHelper.LoadListFromListValues(canadaStockCategory, lvgs.GetListValueGroup("STOCKCAT"), True)
                FormHelper.LoadListFromListValues(itemType, lvgs.GetListValueGroup("ITEMTYPE"), True)
                FormHelper.LoadListFromListValues(itemTypeAttribute, lvgs.GetListValueGroup("ITEMTYPEATTRIB"), True)
                FormHelper.LoadListFromListValues(allowStoreOrder, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(inventoryControl, lvgs.GetListValueGroup("INVCONTROL"), True)
                FormHelper.LoadListFromListValues(freightTerms, lvgs.GetListValueGroup("FREIGHTTERMS"), True)
                FormHelper.LoadListFromListValues(autoReplenish, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(SKUGroup, lvgs.GetListValueGroup("SKUGROUP"), True)
                ' RMS
                FormHelper.LoadListFromListValues(RMSSellable, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(RMSOrderable, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(RMSInventory, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(discountable, lvgs.GetListValueGroup("YESNO"), False) ' Default to Y
                lvgs.ClearAll()
                lvgs = Nothing

                USVendorNumEdit.Visible = True
                USVendorNumLabel.Visible = False
                CanadianVendorNumEdit.Visible = True
                CanadianVendorNumLabel.Visible = False
                USVendorNumEdit.Attributes.Add("onchange", "lookupVendor(""US"", this);")
                CanadianVendorNumEdit.Attributes.Add("onchange", "lookupVendor(""Canadian"", this);")
                itemType.Attributes.Add("onchange", "itemTypeChanged();")

                Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
                Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord

                ' load record if update mode
                If Request("hid") <> "" AndAlso IsNumeric(Request("hid")) Then
                    itemHeader = objMichaels.GetItemHeaderRecord(DataHelper.SmartValues(Request("hid"), "long"))

                    Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
                    Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(itemHeader.BatchID)
                    objMichaelsBatch = Nothing
                    WorkFlowStageID = batchDetail.WorkflowStageID
                    StageType = batchDetail.WorkflowStageType

                    If Not itemHeader Is Nothing Then

                        ' VALIDATE USER
                        _batchID = itemHeader.BatchID
                        ValidateUser(_batchID, batchDetail.WorkflowStageType)
                        If NoUserAccess Then Response.Redirect("default.aspx")

                        ' Vendor Check
                        VendorCheckRedirect(itemHeader.USVendorNum, itemHeader.CanadianVendorNum)

                        ' get IsPack value
                        Me.IsPack = NovaLibra.Coral.Data.Michaels.ItemDetail.IsPack(itemHeader.ID)

                        hid.Value = itemHeader.ID.ToString()
                        submittedBy.Text = itemHeader.SubmittedBy
                        If itemHeader.DateSubmitted <> Date.MinValue Then DateSubmitted.Text = itemHeader.DateSubmitted.ToString("M/d/yyyy")
                        If itemHeader.DepartmentNum <> Integer.MinValue Then departmentNum.Text = itemHeader.DepartmentNum

                        ' vendor number and vendor name
                        If itemHeader.USVendorNum <> Integer.MinValue And itemHeader.USVendorNum > 0 Then USVendorNum.Value = itemHeader.USVendorNum.ToString()
                        If itemHeader.USVendorNum <> Integer.MinValue And IsNumeric(itemHeader.USVendorNum) AndAlso itemHeader.USVendorName.Trim() <> String.Empty AndAlso ValidationHelper.IsValidDomesticVendor(itemHeader.USVendorNum) Then
                            USVendorNumEdit.Visible = False
                            USVendorNumLabel.Visible = True
                            USVendorNumLabel.Text = itemHeader.USVendorNum.ToString()
                        Else
                            USVendorNumEdit.Visible = True
                            USVendorNumLabel.Visible = False
                            If itemHeader.USVendorNum <> Integer.MinValue And itemHeader.USVendorNum > 0 Then USVendorNumEdit.Text = itemHeader.USVendorNum.ToString()
                        End If
                        USVendorName.Value = itemHeader.USVendorName
                        USVendorNameLabel.Text = itemHeader.USVendorName

                        If itemHeader.CanadianVendorNum <> Integer.MinValue And IsNumeric(itemHeader.CanadianVendorNum) Then CanadianVendorNum.Value = itemHeader.CanadianVendorNum.ToString()
                        If itemHeader.CanadianVendorNum <> Integer.MinValue And IsNumeric(itemHeader.CanadianVendorNum) And itemHeader.CanadianVendorName <> String.Empty AndAlso ValidationHelper.IsValidDomesticVendor(itemHeader.CanadianVendorNum) Then
                            CanadianVendorNumEdit.Visible = False
                            CanadianVendorNumLabel.Visible = True
                            CanadianVendorNumLabel.Text = itemHeader.CanadianVendorNum.ToString()
                        Else
                            CanadianVendorNumEdit.Visible = True
                            CanadianVendorNumLabel.Visible = False
                            If itemHeader.CanadianVendorNum <> Integer.MinValue And IsNumeric(itemHeader.CanadianVendorNum) Then CanadianVendorNumEdit.Text = itemHeader.CanadianVendorNum.ToString()
                        End If
                        CanadianVendorName.Value = itemHeader.CanadianVendorName
                        CanadianVendorNameLabel.Text = itemHeader.CanadianVendorName

                        'rebuyYN.SelectedValue = itemHeader.RebuyYN
                        'replenishYN.SelectedValue = itemHeader.ReplenishYN
                        'storeOrderYN.SelectedValue = itemHeader.StoreOrderYN
                        stockCategory.SelectedValue = itemHeader.StockCategory
                        discountable.SelectedValue = itemHeader.Discountable
                        canadaStockCategory.SelectedValue = itemHeader.CanadaStockCategory
                        itemType.SelectedValue = itemHeader.ItemType
                        itemTypeAttribute.SelectedValue = itemHeader.ItemTypeAttribute
                        allowStoreOrder.SelectedValue = itemHeader.AllowStoreOrder
                        inventoryControl.SelectedValue = itemHeader.InventoryControl
                        freightTerms.SelectedValue = itemHeader.FreightTerms
                        autoReplenish.SelectedValue = itemHeader.AutoReplenish
                        SKUGroup.SelectedValue = itemHeader.SKUGroup
                        storeSupplierZoneGroup.Text = itemHeader.StoreSupplierZoneGroup
                        WHSSupplierZoneGroup.Text = itemHeader.WHSSupplierZoneGroup
                        If itemType.SelectedValue <> "R" Then
                            If itemHeader.AddUnitCost <> Decimal.MinValue Then addUnitCost.Text = DataHelper.SmartValues(itemHeader.AddUnitCost, "formatnumber4", False)
                        Else
                            'Me.addUnitCostRow.Style.Add("visibility", "hidden")
                            Me.addUnitCostRow.Style.Add("display", "none")
                        End If

                        comments.Text = itemHeader.Comments
                        worksheetDesc.Text = itemHeader.WorksheetDesc
                        ' RMS
                        RMSSellable.SelectedValue = itemHeader.RMSSellable
                        RMSOrderable.SelectedValue = itemHeader.RMSOrderable
                        RMSInventory.SelectedValue = itemHeader.RMSInventory

                        ' New Item Approval
                        calculateOptions.SelectedValue = itemHeader.CalculateOptions

                        If itemHeader.StoreTotal <> Integer.MinValue Then storeTotal.Text = itemHeader.StoreTotal.ToString()
                        If itemHeader.POGStartDate <> Date.MinValue Then POGStartDate.Text = itemHeader.POGStartDate.ToString("M/d/yyyy")
                        If itemHeader.POGCompDate <> Date.MinValue Then POGCompDate.Text = itemHeader.POGCompDate.ToString("M/d/yyyy")

                        If itemHeader.BatchID > 0 Then
                            batch.Text = " &nbsp;|&nbsp; Log ID: " & itemHeader.BatchID.ToString()
                        End If
                        If itemHeader.BatchVendorName <> "" Then
                            batchVendorName.Text = " &nbsp;|&nbsp; " & "Vendor: " & itemHeader.BatchVendorName
                        End If
                        If itemHeader.BatchStageName <> "" Then
                            stageName.Text = " &nbsp;|&nbsp; " & "Stage: " & itemHeader.BatchStageName
                        End If
                        If itemHeader.DateLastModified <> Date.MinValue Then
                            lastUpdated.Text = " &nbsp;|&nbsp; " & "Last Updated: " & itemHeader.DateLastModified.ToString("M/d/yyyy")
                            If itemHeader.UpdateUser <> "" Then
                                lastUpdated.Text += " by " & itemHeader.UpdateUser
                            End If
                        End If
                        StageID = itemHeader.BatchStageID
                        StageType = itemHeader.BatchStageType

                        ' validation

                        If itemHeader.IsValid = ItemValidFlag.Unknown Then
                            _validWasUnknown = True
                        End If

                        Dim vrBatch As ValidationRecord
                        Dim valRecord As ValidationRecord

                        If ValidationHelper.SkipBatchValidation(StageType) Then
                            vrBatch = New ValidationRecord(itemHeader.BatchID, ItemRecordType.Batch)
                        Else
                            vrBatch = ValidationHelper.ValidateBatch(itemHeader.BatchID, BatchType.Domestic)
                        End If

                        If ValidationHelper.SkipValidation(StageType) Then
                            valRecord = New ValidationRecord(itemHeader.ID, ItemRecordType.ItemHeader)
                        Else
                            valRecord = ValidationHelper.ValidateData(itemHeader)
                        End If

                        If vrBatch.IsValid AndAlso valRecord.IsValid Then
                            _validFlag = ItemValidFlag.Valid
                        Else
                            _validFlag = ItemValidFlag.NotValid
                        End If

                        ' validation summary
                        ValidationHelper.SetupValidationSummary(validationDisplay)
                        If vrBatch.HasAnyError() Then ValidationHelper.AddValidationSummaryErrors(validationDisplay, vrBatch)
                        If valRecord.HasAnyError() Then ValidationHelper.AddValidationSummaryErrors(validationDisplay, valRecord)

                        ' save validation
                        If UserCanEdit Then

                            Dim userID As Integer = Session("UserID")
                            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
                            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecord, userID)

                        End If

                        If itemHeader.ItemUnknownCount > 0 Then
                            itemDetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Unknown, True)
                        ElseIf Not vrBatch.IsValid Then
                            itemDetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.NotValid, True)
                        ElseIf itemHeader.ItemNotValidCount > 0 Then
                            itemDetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.NotValid, True)
                        ElseIf itemHeader.ItemCount <= 0 Then
                            itemDetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.NotValid, True)
                        Else
                            itemDetailImage.Src = ValidationHelper.GetValidationImageString(ItemValidFlag.Valid, True)
                        End If

                        ' clean up
                        vrBatch = Nothing
                        valRecord = Nothing

                    End If ' Not itemHeader Is Nothing

                End If ' Request("hid")

                itemFL = objMichaels.GetHeaderFieldLocking(AppHelper.GetUserID(), AppHelper.GetVendorID, WorkFlowStageID)

                ImplementFieldLocking(itemFL)

                ' custom fields
                Me.custFields.RecordType = Me.RecordType
                Me.custFields.RecordID = Me.ItemHeaderID
                Me.custFields.DisplayTemplate = "<tr><td class=""formLabel"">##NAME##:</td><td class=""formField"">##VALUE##</td></tr>"
                Me.custFields.Columns = 40
                Me.custFields.LoadCustomFields(True)

                objMichaels = Nothing
                itemFL = Nothing

            End If ' IsPostBack

            If hid.Value = "" Then
                IsNew = True

                ' VALIDATE USER
                _batchID = 0
                ValidateUser(_batchID)

                batch.Text = " &nbsp;-&nbsp; Add New"
                StageID = 0
                StageType = Models.WorkflowStageType.Unknown
                linkExcel.Visible = False
                Dim dateNow As Date = Now()
                Me.DateSubmitted.Text = dateNow.ToString("M/d/yyyy")
                Me.storeSupplierZoneGroup.Text = "1"
                Me.WHSSupplierZoneGroup.Text = "1"

                ' ------------------------------------------------------------------------------------------------------------------------------------
                ' FOR NEW RECORDS:
                ' Make vendor number fixed and read-only if the user is vendor and is creating an import or domestic new item batch from scratch
                ' ------------------------------------------------------------------------------------------------------------------------------------
                If Not IsPostBack Then
                    Dim vendorIDValue As Integer = AppHelper.GetVendorID()
                    If vendorIDValue > 0 Then USVendorNum.Value = AppHelper.GetVendorID().ToString()
                    Dim vendorNameValue As String = FormHelper.LookupDomesticVendor(vendorIDValue)
                    If vendorIDValue > 0 AndAlso vendorNameValue.Trim() <> String.Empty Then 'AndAlso ValidationHelper.IsValidDomesticVendor(vendorIDValue) Then
                        USVendorNumEdit.Visible = False
                        USVendorNumLabel.Visible = True
                        USVendorNumLabel.Text = vendorIDValue.ToString()
                    Else
                        USVendorNumEdit.Visible = True
                        USVendorNumLabel.Visible = False
                        If vendorIDValue > 0 Then USVendorNumEdit.Text = vendorIDValue.ToString()
                    End If
                    USVendorName.Value = vendorNameValue
                    USVendorNameLabel.Text = vendorNameValue
                End If
                ' ------------------------------------------------------------------------------------------------------------------------------------
            Else
                If IsPostBack Then
                    If _batchID < 0 Then
                        Dim objM As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                        Dim objIH As Models.ItemHeaderRecord = objM.GetItemHeaderRecord(DataHelper.SmartValues(hid.Value, "integer", False))
                        If Not objIH Is Nothing Then _batchID = objIH.BatchID
                        objIH = Nothing
                        objM = Nothing
                    End If
                    ' VALIDATE USER
                    Dim objBatch As New NovaLibra.Coral.Data.Michaels.BatchData()
                    Dim batchdetail As Models.BatchRecord = objBatch.GetBatchRecord(_batchID)
                    objBatch = Nothing
                    If batchdetail IsNot Nothing Then
                        ValidateUser(_batchID, batchdetail.WorkflowStageType)
                    Else
                        ValidateUser(_batchID)
                    End If
                End If

                itemHeaderImage.Src = ValidationHelper.GetValidationImageString(_validFlag, True)

                linkExcel.NavigateUrl = "detailexport.aspx?hid=" & GetItemHeaderID()
            End If
            itemHeaderID = DataHelper.SmartValues(hid.Value, "long", False)

            If Not UserCanEdit And Not IsNew Then
                btnUpdate.Visible = False
                btnUpdate.Enabled = False
                btnUpdateClose.Visible = False
                btnUpdateClose.Enabled = False
            End If

            ' show/hide validation
            If StageType = Models.WorkflowStageType.Vendor Then
                USVendorNumRF.Visible = False
                USVendorNameRF.Visible = False
                CanadianVendorNumRF.Visible = False
                CanadianVendorNameRF.Visible = False
                departmentNumRF.Visible = False
                stockCategoryRF.Visible = False
                canadaStockCategoryRF.Visible = False
                itemTypeRF.Visible = False
                itemTypeAttributeRF.Visible = False
                allowStoreOrderRF.Visible = False
                inventoryControlRF.Visible = False
                freightTermsRF.Visible = False
                autoReplenishRF.Visible = False
                SKUGroupRF.Visible = False
                storeTotalRF.Visible = False
                POGStartDateRF.Visible = False
                POGCompDateRF.Visible = False
            Else
                If Me.itemTypeAttribute.SelectedValue <> "B" Then
                    storeTotalRF.Visible = False
                    POGStartDateRF.Visible = False
                    POGCompDateRF.Visible = False
                End If
            End If

            ' RMS ?
            If Not IsPostBack Then
                If StageType = Models.WorkflowStageType.DBC AndAlso UserCanEdit Then
                    ShowRMSFields = True
                Else
                    ShowRMSFields = False
                End If
            End If

            ' Init Validation Display
            InitValidation(Me.validationDisplay.ID)

        Else ' callback
            ' CALLBACK
            If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) Then
                Response.End()
            End If
        End If
    End Sub

#End Region

    Private Sub ImplementFieldLocking(ByRef itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking)

        For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
            LockField(col.ColumnName, col.Permission)
        Next
    End Sub

    Public Overrides Sub LockField(ByVal colName As String, ByVal permission As Char)

        Select Case UCase(permission)
            Case "N"            ' Hide Control
                Select Case colName

                    Case "US_Vendor_Name"
                        Me.USVendorNameLabel.Visible = False
                        Me.USVendorNameFL.InnerHtml = "&nbsp;"

                    Case "Canadian_Vendor_Name"
                        Me.CanadianVendorNameLabel.Visible = False
                        Me.CanadianVendorNameFL.InnerHtml = "&nbsp"

                    Case Else   ' Find control by Name
                        MyBase.Lockfield(colName, permission)

                End Select

            Case "V"            ' Render Readonly Control
                Select Case colName

                    Case "US_Vendor_Name"
                        ' Do nothing as its already read only
                    Case "Canadian_Vendor_Name"
                        ' Do nothing as its already read only

                    Case Else   ' Find control by Name
                        MyBase.Lockfield(colName, permission)

                End Select
            Case Else

        End Select
    End Sub

#Region "Callbacks"

    Public Function GetCallbackResult() As String Implements System.Web.UI.ICallbackEventHandler.GetCallbackResult
        Dim str As String() = Split(_callbackArg, CALLBACK_SEP)
        If str.Length <= 0 Then
            Return ""
        End If
        Select Case str(0)
            Case "100"
                ' vendor lookup
                If str.Length < 3 Then
                    Return ""
                End If
                Return CallbackLookupVendor(str(1), str(2))
        End Select
        Return ""
    End Function

    Public Sub RaiseCallbackEvent(ByVal eventArgument As String) Implements System.Web.UI.ICallbackEventHandler.RaiseCallbackEvent
        _callbackArg = eventArgument
    End Sub

    Public Function CallbackLookupVendor(ByVal vendorToLookup As String, ByVal vendorNum As String) As String
        Dim retValue As String = String.Empty
        retValue = String.Format("100{0}0{0}{1}{0}{2}{0}", CALLBACK_SEP, vendorToLookup, vendorNum)

        Dim vendor As NovaLibra.Coral.SystemFrameworks.Michaels.VendorRecord = Nothing
        Dim vnum As Integer = DataHelper.SmartValues(vendorNum, "integer", False)
        If vnum > 0 Then
            Dim objMichaelsVendor As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
            vendor = objMichaelsVendor.GetVendorRecord(vnum)
            If Not vendor Is Nothing AndAlso vendor.ID > 0 Then
                If ValidationHelper.IsValidDomesticVendor(vendor) Then
                    retValue = String.Format("100{0}1{0}{1}{0}{2}{0}{3}", CALLBACK_SEP, vendorToLookup, vnum, vendor.VendorName)
                End If
            End If
            vendor = Nothing
            objMichaelsVendor = Nothing
        End If

        Return retValue
    End Function

#End Region

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        Dim isNew As Boolean
        If IsNumeric(hid.Value) Then
            isNew = False
        Else
            isNew = True
        End If
        If UserCanEdit Then
            Dim itemHeaderID As Long = SaveFormData()
            If itemHeaderID > 0 Then
                If isNew Then
                    Session("_BatchID") = itemHeaderID.ToString()
                End If
                Response.Redirect("detail.aspx?hid=" & itemHeaderID)
            End If
        End If

    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click
        If UserCanEdit Then
            Dim itemHeaderID As Long = SaveFormData()
            If itemHeaderID > 0 Then
                Response.Redirect("default.aspx")
            End If
        End If
    End Sub

    Public Function SaveFormData() As Long
        Dim id As Long = 0
        Dim userID As Integer = Session("UserID")
        Dim isStoreTotalChanged As Boolean



        Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        If IsNumeric(hid.Value) Then
            id = DataHelper.SmartValues(hid.Value, "long", False)
            itemHeader = objMichaels.GetItemHeaderRecord(id)
            itemHeader.SetupAudit(Models.MetadataTable.Item_Headers, itemHeader.ID, AuditRecordType.Update, userID)
        Else
            itemHeader = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord()
            itemHeader.SetupAudit(Models.MetadataTable.Item_Headers, 0, AuditRecordType.Insert, userID)
        End If
        itemHeader.SubmittedBy = submittedBy.Text
        itemHeader.DateSubmitted = DataHelper.SmartValues(DateSubmitted.Text, "date", True)
        itemHeader.DepartmentNum = DataHelper.SmartValues(departmentNum.Text, "integer", True)
        itemHeader.USVendorNum = DataHelper.SmartValues(USVendorNum.Value, "integer", True)
        itemHeader.USVendorName = USVendorName.Value
        itemHeader.CanadianVendorNum = DataHelper.SmartValues(CanadianVendorNum.Value, "integer", True)
        itemHeader.CanadianVendorName = CanadianVendorName.Value
        'itemHeader.RebuyYN = rebuyYN.SelectedValue
        'itemHeader.ReplenishYN = replenishYN.SelectedValue
        'itemHeader.StoreOrderYN = storeOrderYN.SelectedValue

        itemHeader.StockCategory = stockCategory.SelectedValue
        itemHeader.Discountable = discountable.SelectedValue
        itemHeader.CanadaStockCategory = canadaStockCategory.SelectedValue

        If objMichaels.DisableStockingStratBasedOnStockCat(itemHeader.StockCategory, itemHeader.CanadaStockCategory) Then
            ClearStockingStrategy(itemHeader.ID, userID)
        End If

        itemHeader.ItemType = itemType.SelectedValue
        itemHeader.ItemTypeAttribute = itemTypeAttribute.SelectedValue
        itemHeader.AllowStoreOrder = allowStoreOrder.SelectedValue
        itemHeader.InventoryControl = inventoryControl.SelectedValue
        itemHeader.FreightTerms = freightTerms.SelectedValue
        itemHeader.AutoReplenish = autoReplenish.SelectedValue
        itemHeader.SKUGroup = SKUGroup.SelectedValue
        itemHeader.StoreSupplierZoneGroup = storeSupplierZoneGroup.Text
        itemHeader.WHSSupplierZoneGroup = WHSSupplierZoneGroup.Text
        If itemHeader.ItemType <> "R" Then
            ' add field value if item header record is a complex pack
            itemHeader.AddUnitCost = DataHelper.SmartValues(addUnitCost.Text, "money", True)
        Else
            ' null this out for "R"egular records
            itemHeader.AddUnitCost = Decimal.MinValue
        End If
        itemHeader.Comments = DataHelper.SmartValues(comments.Text, "stringrs", True)
        itemHeader.WorksheetDesc = worksheetDesc.Text

        If ShowRMSFields Then
            itemHeader.RMSSellable = RMSSellable.SelectedValue
            itemHeader.RMSOrderable = RMSOrderable.SelectedValue
            itemHeader.RMSInventory = RMSInventory.SelectedValue
        End If
        ' New Item Approval
        itemHeader.CalculateOptions = DataHelper.SmartValues(calculateOptions.SelectedValue, "integer", False)

        If itemHeader.StoreTotal <> DataHelper.SmartValues(storeTotal.Text, "integer", True) Then isStoreTotalChanged = True
        itemHeader.StoreTotal = DataHelper.SmartValues(storeTotal.Text, "integer", True)
        'lp if Storetotal changed, recalc Like Item formulas depending on it -new sub!
        If itemHeader.StoreTotal > 0 And isStoreTotalChanged Then
            If itemHeader.ID > 0 And (itemHeader.CalculateOptions <> 0 Or itemHeader.CalculateOptions <> Integer.MinValue) Then
                SaveRecalcItemData(itemHeader.StoreTotal, itemHeader.ID, itemHeader.CalculateOptions, userID)
            End If
        End If

        itemHeader.POGStartDate = DataHelper.SmartValues(POGStartDate.Text, "date", True)
        itemHeader.POGCompDate = DataHelper.SmartValues(POGCompDate.Text, "date", True)



        Dim itemHeaderID As Long
        If itemHeader.ID > 0 Then
            itemHeaderID = objMichaels.SaveItemHeaderRecord(itemHeader, userID, True)
            Dim vrBatch As Models.ValidationRecord
            Dim valRecord As ValidationRecord

            If ValidationHelper.SkipBatchValidation(StageType) Then
                vrBatch = New ValidationRecord(itemHeader.BatchID, ItemRecordType.Batch)
            Else
                vrBatch = ValidationHelper.ValidateBatch(itemHeader.BatchID, BatchType.Domestic)
            End If

            If ValidationHelper.SkipValidation(StageType) Then
                valRecord = New ValidationRecord(itemHeader.ID, ItemRecordType.ItemHeader)
            Else
                valRecord = ValidationHelper.ValidateItemHeader(itemHeader, Me.Request)
            End If
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecord, userID)
            vrBatch = Nothing
            valRecord = Nothing
        Else
            itemHeaderID = objMichaels.SaveItemHeaderRecord(itemHeader, userID, "Created", "", Session("UserName"))
        End If
        Me.custFields.SaveCustomFields(itemHeaderID)
        objMichaels = Nothing

        Return itemHeaderID

    End Function
    Private Sub ClearStockingStrategy(ByVal ItemheadId As Long, ByVal userId As Integer)
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        objMichaels.ClearStockingStrategy(ItemHeaderID, userId)
    End Sub

    Private Sub SaveRecalcItemData(ByVal storeTotal As Integer, ByVal ItemheadId As Long, ByVal calcOptions As Integer, ByVal userId As Integer)
        'LP new sub recalcualtes childern Like Item details if store total is changed
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim itemDetailRec As New NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord()
        Dim itemList As NovaLibra.Coral.SystemFrameworks.Michaels.ItemList = Nothing
        Dim tempholder As Decimal
        itemList = objMichaels.GetList(ItemheadId, 0, 0, String.Empty, userId)
        If itemList.RecordCount > 0 Then
            For Each itemDetailRec In itemList.ListRecords
                Select Case calcOptions
                    Case 1 'calculate unit store month
                        If itemDetailRec.AnnualRegularUnitForecast <> Decimal.MinValue Then
                            tempholder = itemDetailRec.AnnualRegularUnitForecast / storeTotal / 13
                            If tempholder > 0 Then itemDetailRec.LikeItemUnitStoreMonth = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                        End If
                    Case 2 'calculate annual forecast
                        If itemDetailRec.LikeItemUnitStoreMonth <> Decimal.MinValue Then
                            tempholder = storeTotal * itemDetailRec.LikeItemUnitStoreMonth * 13
                            itemDetailRec.AnnualRegularUnitForecast = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 0)
                            If itemDetailRec.BaseRetail <> Decimal.MinValue Then tempholder = itemDetailRec.BaseRetail * itemDetailRec.AnnualRegularUnitForecast
                            If tempholder > 0 Then itemDetailRec.AnnualRegRetailSales = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                        End If
                End Select

                objMichaels.SaveRecord(itemDetailRec, userId)
            Next
        End If
    End Sub

End Class
