Imports System
Imports System.Diagnostics
Imports System.Data
Imports Microsoft.VisualBasic
Imports System.Collections.Generic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports WebConstants
Imports ItemHelper

Partial Class IMDomesticForm
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler

    Private _validFlag As ItemValidFlag = ItemValidFlag.Unknown
    Private _validWasUnknown As Boolean = False

    Private _callbackArg As String = ""

    ' FJL Jan 2010
    Private WorkflowStageID As Integer = 0
    Private StageType As Integer = 0
    Private UserID As Integer = 0
    Private _isPack As Boolean = False
    Public Property IsPack() As Boolean
        Get
            Return _isPack
        End Get
        Set(ByVal value As Boolean)
            _isPack = value
        End Set
    End Property
    Private _startupScripts As String = String.Empty
    Public Sub AddStartupScript(ByVal script As String)
        If _startupScripts <> String.Empty Then _startupScripts = _startupScripts & vbCrLf
        _startupScripts = _startupScripts & script
    End Sub

    Public Const CALLBACK_SEP As String = "{{|}}"

#Region "Properties"
    Private _refreshGrid As Boolean = False
    Private _closeForm As Boolean = False
    Private _headerItemID As Integer
    Private _headerSKU As String
    Private _headerVendorNumber As Long
    Private _headerLastChangedBy As String
    Private _headerLastChangedOn As String
    Private _IMChanges As List(Of Models.IMChangeRecord) = Nothing
    Private _rowChanges As Models.IMRowChanges = Nothing
    Private _itemDetail As Models.ItemMaintItemDetailFormRecord = Nothing
    Private _batchID As Long = 0
    Private _readOnly As Boolean = False
    Private _viewMode As Boolean = False
    Private _itemMasterView As Boolean = False

    Public Property ItemMasterView() As Boolean
        Get
            Return _itemMasterView
        End Get
        Set(ByVal value As Boolean)
            _itemMasterView = value
        End Set
    End Property

    Public Property ViewMode() As Boolean
        Get
            Return _viewMode
        End Get
        Set(ByVal value As Boolean)
            _viewMode = value
        End Set
    End Property

    Public Property CloseForm() As Boolean
        Get
            Return _closeForm
        End Get
        Set(ByVal value As Boolean)
            _closeForm = value
        End Set
    End Property


    Public Property ReadOnlyForm() As Boolean
        Get
            Return _readOnly
        End Get
        Set(ByVal value As Boolean)
            _readOnly = value
        End Set
    End Property

    Private Property ItemDetail() As Models.ItemMaintItemDetailFormRecord
        Get
            Return _itemDetail
        End Get
        Set(ByVal value As Models.ItemMaintItemDetailFormRecord)
            _itemDetail = value
        End Set
    End Property

    Private Property IMChanges() As List(Of Models.IMChangeRecord)
        Get
            Return _IMChanges
        End Get
        Set(ByVal value As List(Of Models.IMChangeRecord))
            _IMChanges = value
        End Set
    End Property
    Private Property RowChanges() As Models.IMRowChanges
        Get
            Return _rowChanges
        End Get
        Set(ByVal value As Models.IMRowChanges)
            _rowChanges = value
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

    Public ReadOnly Property RecordType() As Integer
        Get
            Return WebConstants.RECTYPE_DOMESTIC_ITEM
        End Get
    End Property
    Private Property HeaderItemID() As Integer
        Get
            Return _headerItemID
        End Get
        Set(ByVal value As Integer)
            _headerItemID = value
        End Set
    End Property

    Private Property HeaderSKU() As String
        Get
            Return _headerSKU
        End Get
        Set(ByVal value As String)
            _headerSKU = value
        End Set
    End Property

    Private Property HeaderVendorNumber() As Long
        Get
            Return _headerVendorNumber
        End Get
        Set(ByVal value As Long)
            _headerVendorNumber = value
        End Set
    End Property

    Private Property HeaderLastChangedBy() As String
        Get
            Return _headerLastChangedBy
        End Get
        Set(ByVal value As String)
            _headerLastChangedBy = value
        End Set
    End Property

    Private Property HeaderLastChangedOn() As String
        Get
            Return _headerLastChangedOn
        End Get
        Set(ByVal value As String)
            _headerLastChangedOn = IIf(IsDate(value), FormatDateTime(value, DateFormat.ShortDate), value)
        End Set
    End Property

    Private Property BatchID() As Long
        Get
            Return _batchID
        End Get
        Set(ByVal value As Long)
            _batchID = value
        End Set
    End Property
#End Region

    ' Load up the Metadata for Save
    Private md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
    Private mdTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
    Private mdColumn As NovaLibra.Coral.SystemFrameworks.MetadataColumn

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsCallback Then
            ' check security
            If Not SecurityCheck() Then
                CloseTheForm()
            End If

            'Session variable cIMITEMID should contain an item id as a backup
            Dim strTemp As String
            strTemp = Request("r")
            If strTemp = "1" Then RefreshGrid = True
            strTemp = Request("id")   ' Use request Object first (from Item Grid call)

            Dim s As String = "", v As Long = 0
            If strTemp = "" Then
                strTemp = Session(cIMITEMID)
            ElseIf strTemp = "x" Then
                ReadOnlyForm = True
                s = Request("sku")
                v = DataHelper.SmartValues(Request("vendor"), "long")
                If Len(s) > 0 AndAlso v > 0 Then ItemMasterView = True
            End If

            ' For testing
            ' strTemp = "174"

            If strTemp.Length = 0 OrElse (strTemp <> "x" And IsNumeric(strTemp) = False) Then
                CloseTheForm()
            End If

            PopulateGlobalVariables(strTemp, s, v)
            InitializeControls()

            If Not Page.IsPostBack Then
                PopulateForm()
            End If
            CheckForStartupScripts()

            ' Init Validation Display
            InitValidation(Me.validationDisplay.ID)
        End If
    End Sub

    Private Sub PopulateGlobalVariables(ByVal strTemp As String, Optional ByVal sku As String = "", Optional ByVal VendorNum As Long = 0)

        'Populate User ID
        UserID = CInt(Session(cUSERID))

        Dim batch As Integer = 0
        Dim ItemHeader As Models.ItemMaintItem

        If IsNumeric(strTemp) AndAlso Not ReadOnlyForm Then   ' Editiable record
            HeaderItemID = CInt(strTemp)
            ItemHeader = Data.MaintItemMasterData.GetItemMaintHeaderRec(HeaderItemID)
        Else
            Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim itemHeaderList As List(Of Models.ItemMaintItem) = Data.MaintItemMasterData.FindHeaderID(sku, VendorNum, Session(cVENDORID))
            For Each header As Models.ItemMaintItem In itemHeaderList
                Dim editBatch As Models.BatchRecord = batchDB.GetBatchRecord(header.BatchID)
                If editBatch.BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic Or editBatch.BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import Then
                    ItemHeader = header
                    Exit For
                End If
            Next
            ViewMode = True
        End If

        If ItemHeader IsNot Nothing Then
            batch = ItemHeader.BatchID
            BatchID = batch
            HeaderItemID = ItemHeader.ID
            HeaderSKU = ItemHeader.SKU
            HeaderVendorNumber = ItemHeader.VendorNumber
            HeaderLastChangedBy = ItemHeader.LastUpdateUserName
            HeaderLastChangedOn = ItemHeader.LastUpdateDate

            Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
            Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(ItemHeader.BatchID)
            objMichaelsBatch = Nothing

            If batchDetail.ID > 0 Then
                'Set the global workflow id
                WorkflowStageID = batchDetail.WorkflowStageID
                'set the global workflow stage type
                StageType = batchDetail.WorkflowStageType
                ' set the IsPack property
                Me.IsPack = batchDetail.IsPack
            End If
        Else    ' save for Item load if no itemid is found
            HeaderSKU = sku
            HeaderVendorNumber = VendorNum
        End If

        ' VALIDATE USER
        ValidateUser(batch, StageType)
        If Not UserCanEdit Then ReadOnlyForm = True

        If NoUserAccess Then CloseTheForm()

    End Sub

    Private Sub InitializeControls()
        ' callback
        Dim cbReference As String
        cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", _
            "ReceiveServerData", "context")
        Dim callbackScript As String = ""
        callbackScript &= "function CallServer(arg, context)" & _
            "{" & cbReference & "; }"
        Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), _
            "CallServer", callbackScript, True)

        ' init controls

        DisplayerCost.Attributes.Add("onchange", "costChanged();")
        ItemCost.Attributes.Add("onchange", "costChanged();")

        eachCaseHeight.Attributes.Add("onchange", "eachCaseChanged();")
        eachCaseWidth.Attributes.Add("onchange", "eachCaseChanged();")
        eachCaseLength.Attributes.Add("onchange", "eachCaseChanged();")
        eachCaseWeight.Attributes.Add("onchange", "eachCaseChanged();")

        innerCaseHeight.Attributes.Add("onchange", "innerCaseChanged();")
        innerCaseWidth.Attributes.Add("onchange", "innerCaseChanged();")
        innerCaseLength.Attributes.Add("onchange", "innerCaseChanged();")
        innerCaseWeight.Attributes.Add("onchange", "innerCaseChanged();")

        masterCaseHeight.Attributes.Add("onchange", "masterCaseChanged();")
        masterCaseWidth.Attributes.Add("onchange", "masterCaseChanged();")
        masterCaseLength.Attributes.Add("onchange", "masterCaseChanged();")
        masterCaseWeight.Attributes.Add("onchange", "masterCaseChanged();")

        'hybridLeadTime.Attributes.Add("onchange", "leadTimeChanged();")

        prePriced.Attributes.Add("onchange", "baseRetailChanged('prepriced');")
        'baseRetail.Attributes.Add("onchange", "baseRetailChanged('baseretail');")
        'alaskaRetail.Attributes.Add("onchange", "alaskaRetailChanged();")
        'canadaRetail.Attributes.Add("onchange", "canadaRetailChanged();")

        'vendorUPC.Attributes.Add("onchange", "vendorUPCChanged();")

        'taxWizardLink.Attributes.Add("onclick", "openTaxWizard('" & id & "'); return false;")
        taxUDA.Attributes.Add("onchange", "taxUDAChanged();")
        taxValueUDA.Attributes.Add("onchange", "taxValueUDAChanged();")

        Hazardous.Attributes.Add("onchange", "hazardousChanged();")

        ' Country of Origin
        ' Me.CountryOfOriginName.Attributes.Add("onchange", "CountryOfOriginChanged();")
    End Sub

    Private Sub PopulateForm()

        Dim itemDetail As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailFormRecord
        Dim batchDetail As Models.BatchRecord = Nothing
        Dim i As Integer

        ' Load Change Records into Property
        IMChanges = Data.MaintItemMasterData.GetIMChangeRecordsByItemID(HeaderItemID)
        RowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(HeaderItemID)

        Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
        Dim objMichaels As New Data.MaintItemMasterData
        itemFL = objMichaels.GetFieldLocking(AppHelper.GetUserID(), Models.MetadataTable.vwItemMaintItemDetail, AppHelper.GetVendorID(), WorkflowStageID, True)

        ' Used by CheckandSet to verify field is not a minvalue
        mdTable = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)

        If HeaderItemID > 0 Then    ' Normal if not in Read Only Mode or if In RO Mode and reviewing an item in a batch with matching SKU / Vendor
            itemDetail = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(HeaderItemID, AppHelper.GetVendorID())
        Else
            itemDetail = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(AppHelper.GetVendorID(), HeaderSKU, HeaderVendorNumber)
        End If

        If Not itemDetail Is Nothing AndAlso itemDetail.ID > 0 Then
            Dim objData As New Data.BatchData()
            batchDetail = objData.GetBatchRecord(itemDetail.BatchID)
            objData = Nothing
            If itemDetail.BatchID > 0 Then
                batch.Text = " &nbsp;|&nbsp; Log ID: " & itemDetail.BatchID.ToString()
                Select Case batchdetail.PackType.ToUpper
                    Case "R", ""
                        batch.Text += " - Regular"
                    Case "DP"
                        batch.Text += " - Displayer Pack"
                    Case "SB"
                        batch.Text += " - Sellable Bundle"
                    Case "D"
                        batch.Text += " - Displayer"
                End Select
            End If
            If batchdetail.VendorName <> "" Then
                batchVendorName.Text = " &nbsp;|&nbsp; " & "Vendor: " & batchdetail.VendorName
            End If
            If batchdetail.WorkflowStageName <> "" Then
                stageName.Text = " &nbsp;|&nbsp; " & "Stage: " & batchdetail.WorkflowStageName
            End If
            If HeaderLastChangedOn <> "" Then
                lastUpdated.Text = " &nbsp;|&nbsp; " & "Last Updated: " & HeaderLastChangedOn   '.ToString("M/d/yyyy")
                If HeaderLastChangedBy <> "" Then
                    lastUpdated.Text += " by " & HeaderLastChangedBy
                End If
            End If
        End If

        If Not itemDetail Is Nothing Then
            ' load list values
            Dim lvgs As ListValueGroups = FormHelper.LoadListValues("YESNO,PACKITEMIND,HYBRIDTYPE,HYBRIDSOURCEDC,PREPRICEDUDA,TAXUDA,HAZCONTAINERTYPE,HAZMSDSUOM,RMS_PBL,INVCONTROL,SKUGROUP,FREIGHTTERMS,ITEMTYPEATTRIB,STOCKSTRATALL")
            FormHelper.LoadListFromListValues(SKUGroup, lvgs.GetListValueGroup("SKUGROUP"), True)
            FormHelper.LoadListFromListValues(itemTypeAttribute, lvgs.GetListValueGroup("ITEMTYPEATTRIB"), True)
            FormHelper.LoadListFromListValues(HazardousContainerType, lvgs.GetListValueGroup("HAZCONTAINERTYPE"), True)
            FormHelper.LoadListFromListValues(prePricedUDA, lvgs.GetListValueGroup("PREPRICEDUDA"), True)
            FormHelper.LoadListFromListValues(HazardousMSDSUOM, lvgs.GetListValueGroup("HAZMSDSUOM"), True)
            FormHelper.LoadListFromListValues(PackItemIndicator, lvgs.GetListValueGroup("PACKITEMIND"), True)
            'FormHelper.LoadListFromListValues(hybridType, lvgs.GetListValueGroup("HYBRIDTYPE"), True)
            'FormHelper.LoadListFromListValues(hybridSourceDC, lvgs.GetListValueGroup("HYBRIDSOURCEDC"), True)
            FormHelper.LoadListFromListValues(prePriced, lvgs.GetListValueGroup("YESNO"), False)                            ' -- prePriced must be Y/N
            FormHelper.LoadListFromListValues(taxUDA, lvgs.GetListValueGroup("TAXUDA"), True, cREQPICK, "", 20)             ' -- Indicate Selection required
            FormHelper.LoadListFromListValues(Hazardous, lvgs.GetListValueGroup("YESNO"), False)                            ' -- Hazardous must be Y/N
            FormHelper.LoadListFromListValues(HazardousFlammable, lvgs.GetListValueGroup("YESNO"), False)                   ' -- HazardousFlammable must be Y/N
            FormHelper.LoadListFromListValues(PrivateBrandLabel, lvgs.GetListValueGroup("RMS_PBL"), True, cREQPICK, "", 20) ' -- Indicate Selection required
            FormHelper.LoadListFromListValues(AutoReplenish, lvgs.GetListValueGroup("YESNO"), False)                        ' -- AutoReplenish must be Y/N
            FormHelper.LoadListFromListValues(AllowStoreOrder, lvgs.GetListValueGroup("YESNO"), False)                      ' -- AllowStoreOrder must be Y/N
            FormHelper.LoadListFromListValues(InventoryControl, lvgs.GetListValueGroup("INVCONTROL"), False)                ' -- InventoryControl must be Y/N
            FormHelper.LoadListFromListValues(Discountable, lvgs.GetListValueGroup("YESNO"), False)                         ' -- Discountable must be Y/N
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATALL"), True)

            'InitStockStratHelper
            InitStockStratHelper()


            hid.Value = itemDetail.ID   ' for save
            If Not VendorCheck(DataHelper.SmartValues(itemDetail.VendorNumber, "integer", False)) Then
                CloseTheForm()
            End If

            If ReadOnlyForm Then
                Page.Title = "View Item"
                lblHeading.Text = "View Item"
                lblSubHeading.Text = ""
            Else
                Page.Title = "Edit Item"
                lblHeading.Text = "Edit Item"
                lblSubHeading.Text = "Using the fields below, edit this item entry."
            End If

            VendorNumber.Text = itemDetail.VendorNumber
            VendorName.Text = itemDetail.VendorName
            departmentNum.Text = itemDetail.DepartmentNum
            stockCategory.Text = itemDetail.StockCategory
            itemTypeAttribute.SelectedValue = itemDetail.ItemTypeAttribute
            SKUGroup.SelectedValue = itemDetail.SKUGroup

            'Add Quote Reference Number
            QuoteReferenceNumber.Text = CheckandSetControl(itemDetail.QuoteReferenceNumber, itemDetail.ID, QuoteReferenceNumber.ID)

            If ConfigurationManager.AppSettings("HideDomesticQRN") = True Then
                Me.QuoteReferenceNumber.Visible = False
                Me.quotereferenceNumFL.Visible = False
            End If

            AllowStoreOrder.SelectedValue = CheckandSetControl(itemDetail.AllowStoreOrder.ToUpper, itemDetail.ID, AllowStoreOrder.ID)
            AutoReplenish.SelectedValue = CheckandSetControl(itemDetail.AutoReplenish.ToUpper, itemDetail.ID, AutoReplenish.ID)
            InventoryControl.SelectedValue = CheckandSetControl(itemDetail.InventoryControl.ToUpper, itemDetail.ID, InventoryControl.ID)
            Discountable.SelectedValue = CheckandSetControl(itemDetail.Discountable.ToUpper, itemDetail.ID, Discountable.ID)

            PackItemIndicator.SelectedValue = itemDetail.PackItemIndicator.ToUpper
            michaelsSKU.Text = itemDetail.SKU
            vendorUPC.Text = itemDetail.PrimaryUPC

            ' additional UPCs
            Dim UPC As String, UPCValues As String = String.Empty
            If Not itemDetail.AdditionalUPCRecs Is Nothing AndAlso itemDetail.AdditionalUPCRecs.Count > 0 Then
                Dim UPCString As String = String.Empty
                For i = 0 To itemDetail.AdditionalUPCRecs.Count - 1
                    ' Not used when UPCs are Read Only:  If UPCString <> String.Empty Then UPCString += "<br />"
                    UPC = itemDetail.AdditionalUPCRecs.Item(i).UPC.Replace("""", "&quot;")
                    If UPCValues <> String.Empty Then UPCValues += ","
                    UPCValues += UPC    ' onchange=""additionalUPCChanged('" & (i + 1) & "');""
                    ' Not used when UPCs are Read Only:  UPCString += "<input type=""text"" id=""additionalUPC" & (i + 1) & """ readonly=""true"" maxlength=""20"" value=""" & UPC & """  /><sup>" & (i + 1) & "</sup>"
                    UPCString += "<div style='width:40px; color:navy' >" & UPC & "&nbsp;&nbsp;<sup>" & (i + 1) & "</sup></div>"
                Next
                additionalUPCs.Text = UPCString
                additionalUPCCount.Value = itemDetail.AdditionalUPCRecs.Count.ToString()
                additionalUPCValues.Value = UPCValues

            End If

            'PMO200141 GTIN14 Enhancements changes
            InnerGTIN.Text = itemDetail.InnerGTIN
            CaseGTIN.Text = itemDetail.CaseGTIN

            ' Additional COOs 
            ' ************************************************************************************************
            Dim addCOORec As Models.ItemMasterVendorCountryRecord
            Dim controlCounter As Integer = 1
            Dim COOName As String = cADDCOONAME   ' Base name for all controls

            Dim newPrimary As String = cNEWPRIMARY
            Dim ChangeRec As Models.IMChangeRecord  ', ChangeRec2 As Models.IMChangeRecord
            ChangeRec = FormHelper.FindIMChangeRecord(IMChanges, itemDetail.ID, newPrimary, , , , 0)
            Dim newPrimaryName As String = ChangeRec.FieldValue

            ' Create set of controls for any existing Additional COOs
            Dim priMsg As String = "Set as Primary:&nbsp;&nbsp;&nbsp;"

            For Each addCOORec In itemDetail.AdditionalCOORecs
                Dim r As New TableRow(), c As New TableCell, c2 As New TableCell
                Dim nlTextbox As NovaLibra.Controls.NLTextBox, nlCheckbox As NovaLibra.Controls.NLCheckBox

                nlCheckbox = AddCheckbox(newPrimary, controlCounter.ToString)
                If controlCounter = 1 Then
                    c.Controls.Add(New LiteralControl(priMsg))
                End If
                nlCheckbox.Checked = (newPrimaryName = addCOORec.CountryOfOriginName)
                c.Controls.Add(nlCheckbox)
                c.Style.Add("text-align", "right")
                c.Style.Add("padding-right", "2px")
                r.Cells.Add(c)

                c2.ColumnSpan = 2
                nlTextbox = AddChangeControlTB(COOName, controlCounter.ToString, controlCounter, c2)
                r.Cells.Add(c2)
                additionalCOOTbl.Rows.Add(r)

                ' nlCheckbox = FindControl(newPrimary + controlCounter.ToString)
                'nlCheckbox.Checked = (newPrimaryName = addCOORec.CountryOfOriginName)

                ' nlTextbox = FindControl(COOName + controlCounter.ToString)
                nlTextbox.Attributes.Add("onchange", "checkNewPrimary(" + controlCounter.ToString + ");")
                nlTextbox.Text = addCOORec.CountryOfOriginName
                nlTextbox.OriginalValue = nlTextbox.Text
                nlTextbox.RenderReadOnly = True
                controlCounter += 1
            Next

            ' Create set of controls for any Change Rec Additional COOs
            Dim counter As Integer = itemDetail.AdditionalCOORecs.Count + 1
            'ChangeRec = FormHelper.FindIMChangeRecord(IMChanges, itemDetail.ID, cADDCOONAME, , , , counter)
            ChangeRec = FormHelper.FindIMChangeRecord(IMChanges, itemDetail.ID, cADDCOONAME, , , , 0)
            'ChangeRec2 = FormHelper.FindIMChangeRecord(IMChanges, itemDetail.ID, cADDCOO, , , , 0)

            If ChangeRec.ItemID > 0 Then
                Dim strTemp As String = ChangeRec.FieldValue
                Dim aCOONames() As String = strTemp.Split(cPIPE)    ' all new COOs stored in one pipe separate change rec
                'strTemp = ChangeRec2.FieldValue
                'Dim aCOOCodes() As String = strTemp.Split(cPIPE)

                Dim recsFnd As Integer = aCOONames.Length
                For x As Integer = 0 To recsFnd - 1
                    Dim r As New TableRow(), c As New TableCell, c2 As New TableCell
                    Dim nlTextbox As NovaLibra.Controls.NLTextBox, nlCheckbox As NovaLibra.Controls.NLCheckBox
                    nlCheckbox = AddCheckbox(newPrimary, (counter + x).ToString)
                    nlTextbox = AddChangeControlTB(COOName, (counter + x).ToString, counter + x, c2)

                    If counter + x = 1 Then
                        c.Controls.Add(New LiteralControl(priMsg))
                    End If
                    c.Controls.Add(nlCheckbox)
                    c.Style.Add("text-align", "right")
                    c.Style.Add("padding-right", "2px")
                    r.Cells.Add(c)

                    c2.ColumnSpan = 2
                    r.Cells.Add(c2)
                    additionalCOOTbl.Rows.Add(r)
                    nlCheckbox.Checked = (newPrimaryName = aCOONames(x))
                    nlTextbox.Text = aCOONames(x)

                    '' Warning! Convaluted logic follows!
                    'If aCOONames(x) = " " Then   ' Means a bad name was saved.  Get the name from the Code array
                    '    nlTextbox.Text = aCOOCodes(x)
                    'Else
                    '    nlTextbox.Text = aCOONames(x)
                    'End If

                    nlTextbox.OriginalValue = ""
                    nlTextbox.Attributes.Add("onchange", "checkNewPrimary(" + (counter + x).ToString + ");")
                    If ReadOnlyForm Then
                        nlTextbox.RenderReadOnly = True
                    End If
                Next
                controlCounter = counter + recsFnd
            End If

            ' Create an empty Country of Origin Control if form is not readonly
            If Not ReadOnlyForm Then
                Dim COOString As String = String.Empty
                Dim r As New TableRow(), c As New TableCell, c32 As New TableCell

                If controlCounter = 1 Then
                    c.Controls.Add(New LiteralControl(priMsg))
                End If

                Dim nlCheckbox As NovaLibra.Controls.NLCheckBox, nlTextbox As NovaLibra.Controls.NLTextBox
                nlCheckbox = AddCheckbox(newPrimary, controlCounter.ToString)
                nlTextbox = AddChangeControlTB(COOName, controlCounter.ToString, controlCounter, c32)
                nlTextbox.Attributes.Add("onchange", "checkNewPrimary(" + controlCounter.ToString + ");")

                c.Controls.Add(nlCheckbox)
                c.Style.Add("text-align", "right")
                c.Style.Add("padding-right", "2px")

                'COOString = "<input type=""text"" id=""" & COOName & controlCounter.ToString & """ name=""" & COOName & controlCounter.ToString & """ onchange=""javascript:checkNewPrimary(" + controlCounter.ToString + ");"" maxlength=""50"" value="""" /><sup>" & controlCounter.ToString & "</sup>"
                'c32.Controls.Add(New LiteralControl(COOString))
                'c32.Style.Add("padding-left", "2px")
                c32.ColumnSpan = 2

                r.Cells.Add(c)
                r.Cells.Add(c32)
                r.ID = cEMPTYCOUNTRY
                additionalCOOTbl.Rows.Add(r)

                Dim r1 As New TableRow(), c11 As New TableCell, c12 As New TableCell
                COOString = "<a href=""#"" ID=""additionalCOOLink"" title=""Click to Add a New Country"" onclick=""addAdditionalCOO(); return false"">[+]</a>"
                c12.Controls.Add(New LiteralControl(COOString))
                c12.Style.Add("text-align", "right")
                c12.ColumnSpan = 2
                r1.ID = cADDACOUNTRY
                r1.Cells.Add(c11)
                r1.Cells.Add(c12)
                additionalCOOTbl.Rows.Add(r1)
            End If
            additionalCOOCount.Value = controlCounter.ToString
            additionalCOOStart.Value = 1                        ' used by javascript to force autocompleter on
            additionalCOOEnd.Value = controlCounter.ToString    ' this field hold the max count of addtional COOs that exist when the page is saved
            ' ************************ END ADD COO ***************************************************

            classNum.Text = itemDetail.ClassNum.ToString()
            subClassNum.Text = itemDetail.SubClassNum.ToString()
            VendorStyleNum.Text = CheckandSetControl(itemDetail.VendorStyleNum, itemDetail.ID, VendorStyleNum.ID)
            ItemDesc.Text = CheckandSetControl(itemDetail.ItemDesc, itemDetail.ID, ItemDesc.ID)
            PrivateBrandLabel.SelectedValue = CheckandSetControl(itemDetail.PrivateBrandLabel, itemDetail.ID, PrivateBrandLabel.ID)
            'hybridType.SelectedValue = itemDetail.HybridType
            'hybridSourceDC.SelectedValue = itemDetail.HybridSourceDC
            'If itemDetail.HybridLeadTime <> Integer.MinValue Then hybridLeadTime.Text = itemDetail.HybridLeadTime
            'If itemDetail.HybridConversionDate <> Date.MinValue Then hybridConversionDateEdit.Text = itemDetail.HybridConversionDate.ToString("M/d/yyyy")
            'hybridConversionDate.Value = hybridConversionDateEdit.Text
            StockingStrategyCode.SelectedValue = CheckandSetControl(itemDetail.StockingStrategyCode, itemDetail.ID, StockingStrategyCode.ID)

            'PMO200141 GTIN14 Enhancements changes
            If PrivateBrandLabel.SelectedValue <> 12 Then
                InnerGTIN.RenderReadOnly = True
                CaseGTIN.RenderReadOnly = True
            Else
                InnerGTIN.RenderReadOnly = False
                CaseGTIN.RenderReadOnly = False
            End If

            InnerGTIN.Text = CheckandSetControl(itemDetail.InnerGTIN, itemDetail.ID, InnerGTIN.ID)
            CaseGTIN.Text = CheckandSetControl(itemDetail.CaseGTIN, itemDetail.ID, CaseGTIN.ID)

            If Me.IsPack Then
                qtyInPack.Text = CheckandSetControl(itemDetail.QtyInPack, itemDetail.ID, qtyInPack.ID)
            Else
                qtyInPackRow.Visible = False
            End If
            eachesMasterCase.Text = CheckandSetControl(itemDetail.EachesMasterCase, itemDetail.ID, eachesMasterCase.ID)
            eachesInnerPack.Text = CheckandSetControl(itemDetail.EachesInnerPack, itemDetail.ID, eachesInnerPack.ID)
            prePriced.SelectedValue = CheckandSetControl(itemDetail.PrePriced, itemDetail.ID, prePriced.ID)
            prePricedUDA.SelectedValue = CheckandSetControl(itemDetail.PrePricedUDA, itemDetail.ID, prePricedUDA.ID)

            Dim str As String = itemDetail.PackItemIndicator
            Dim cr As Models.IMChangeRecord = FormHelper.FindIMChangeRecord(IMChanges, itemDetail.ID, "PackItemIndicator")
            If cr IsNot Nothing AndAlso cr.ItemID > 0 Then str = DataHelper.SmartValues(cr.FieldValue, "string", False)
            If str.Length > 2 Then str = str.Substring(0, 2)
            str = str.ToUpper().Replace("-", "")
            If Me.IsPack AndAlso (str = "D" Or str = "DP" Or str = "SB") Then
                DisplayerCost.Text = CheckandSetControl(itemDetail.DisplayerCost, itemDetail.ID, DisplayerCost.ID, "formatnumber4")
            Else
                DisplayerCostRow.Visible = False
            End If
            ItemCost.Text = CheckandSetControl(itemDetail.ItemCost, itemDetail.ID, ItemCost.ID, "formatnumber4")
            FOBShippingPointEdit.Text = CheckandSetControl(itemDetail.FOBShippingPoint, itemDetail.ID, FOBShippingPoint.ID, FOBShippingPointEdit.ID, "", "", "", 0, "formatnumber4")
            FOBShippingPoint.Value = FOBShippingPointEdit.Text

            ' Retails are Read Only. No Check and set required
            If itemDetail.Base1Retail <> Decimal.MinValue Then base1Retail.Text = DataHelper.SmartValues(itemDetail.Base1Retail, "formatnumber")
            If itemDetail.Base2Retail <> Decimal.MinValue Then Base2RetailEdit.Text = DataHelper.SmartValues(itemDetail.Base2Retail, "formatnumber")
            Base2Retail.Value = Base2RetailEdit.Text
            If itemDetail.TestRetail <> Decimal.MinValue Then testRetailEdit.Text = DataHelper.SmartValues(itemDetail.TestRetail, "formatnumber")
            testRetail.Value = testRetailEdit.Text
            If itemDetail.AlaskaRetail <> Decimal.MinValue Then alaskaRetail.Text = DataHelper.SmartValues(itemDetail.AlaskaRetail, "formatnumber")
            If itemDetail.CanadaRetail <> Decimal.MinValue Then canadaRetail.Text = DataHelper.SmartValues(itemDetail.CanadaRetail, "formatnumber")
            If itemDetail.High2Retail <> Decimal.MinValue Then High2RetailEdit.Text = DataHelper.SmartValues(itemDetail.High2Retail, "formatnumber")
            High2Retail.Value = High2RetailEdit.Text
            If itemDetail.High3Retail <> Decimal.MinValue Then High3RetailEdit.Text = DataHelper.SmartValues(itemDetail.High3Retail, "formatnumber")
            High3Retail.Value = High3RetailEdit.Text
            If itemDetail.SmallMarketRetail <> Decimal.MinValue Then SmallMarketRetailEdit.Text = DataHelper.SmartValues(itemDetail.SmallMarketRetail, "formatnumber")
            SmallMarketRetail.Value = SmallMarketRetailEdit.Text
            If itemDetail.High1Retail <> Decimal.MinValue Then High1RetailEdit.Text = DataHelper.SmartValues(itemDetail.High1Retail, "formatnumber")
            High1Retail.Value = High1RetailEdit.Text
            If itemDetail.Base3Retail <> Decimal.MinValue Then Base3RetailEdit.Text = DataHelper.SmartValues(itemDetail.Base3Retail, "formatnumber")
            Base3Retail.Value = Base3RetailEdit.Text
            If itemDetail.Low1Retail <> Decimal.MinValue Then Low1RetailEdit.Text = DataHelper.SmartValues(itemDetail.Low1Retail, "formatnumber")
            Low1Retail.Value = Low1RetailEdit.Text
            If itemDetail.Low2Retail <> Decimal.MinValue Then Low2RetailEdit.Text = DataHelper.SmartValues(itemDetail.Low2Retail, "formatnumber")
            Low2Retail.Value = Low2RetailEdit.Text
            If itemDetail.ManhattanRetail <> Decimal.MinValue Then ManhattanRetailEdit.Text = DataHelper.SmartValues(itemDetail.ManhattanRetail, "formatnumber")
            ManhattanRetail.Value = ManhattanRetailEdit.Text
            If itemDetail.QuebecRetail <> Decimal.MinValue Then QuebecRetailEdit.Text = DataHelper.SmartValues(itemDetail.QuebecRetail, "formatnumber")
            QuebecRetail.Value = QuebecRetailEdit.Text
            If itemDetail.PuertoRicoRetail <> Decimal.MinValue Then PuertoRicoRetailEdit.Text = DataHelper.SmartValues(itemDetail.PuertoRicoRetail, "formatnumber")
            PuertoRicoRetail.Value = PuertoRicoRetailEdit.Text

            If itemDetail.Base1Clearance <> Decimal.MinValue AndAlso itemDetail.Base1Clearance <> itemDetail.Base1Retail Then base1Clearance.Text = DataHelper.SmartValues(itemDetail.Base1Clearance, "formatnumber")
            If itemDetail.Base2Clearance <> Decimal.MinValue AndAlso itemDetail.Base2Clearance <> itemDetail.Base2Retail Then Base2ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Base2Clearance, "formatnumber")
            Base2Clearance.Value = Base2ClearanceEdit.Text
            If itemDetail.TestClearance <> Decimal.MinValue AndAlso itemDetail.TestClearance <> itemDetail.TestRetail Then testClearanceEdit.Text = DataHelper.SmartValues(itemDetail.TestClearance, "formatnumber")
            testClearance.Value = testClearanceEdit.Text
            If itemDetail.AlaskaClearance <> Decimal.MinValue AndAlso itemDetail.AlaskaClearance <> itemDetail.AlaskaRetail Then alaskaClearance.Text = DataHelper.SmartValues(itemDetail.AlaskaClearance, "formatnumber")
            If itemDetail.CanadaClearance <> Decimal.MinValue AndAlso itemDetail.CanadaClearance <> itemDetail.CanadaRetail Then canadaClearance.Text = DataHelper.SmartValues(itemDetail.CanadaClearance, "formatnumber")
            If itemDetail.High2Clearance <> Decimal.MinValue AndAlso itemDetail.High2Clearance <> itemDetail.High2Retail Then High2ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.High2Clearance, "formatnumber")
            High2Clearance.Value = High2ClearanceEdit.Text
            If itemDetail.High3Clearance <> Decimal.MinValue AndAlso itemDetail.High3Clearance <> itemDetail.High3Retail Then High3ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.High3Clearance, "formatnumber")
            High3Clearance.Value = High3ClearanceEdit.Text
            If itemDetail.SmallMarketClearance <> Decimal.MinValue AndAlso itemDetail.SmallMarketClearance <> itemDetail.SmallMarketRetail Then SmallMarketClearanceEdit.Text = DataHelper.SmartValues(itemDetail.SmallMarketClearance, "formatnumber")
            SmallMarketClearance.Value = SmallMarketClearanceEdit.Text
            If itemDetail.High1Clearance <> Decimal.MinValue AndAlso itemDetail.High1Clearance <> itemDetail.High1Retail Then High1ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.High1Clearance, "formatnumber")
            High1Clearance.Value = High1ClearanceEdit.Text
            If itemDetail.Base3Clearance <> Decimal.MinValue AndAlso itemDetail.Base3Clearance <> itemDetail.Base3Retail Then Base3ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Base3Clearance, "formatnumber")
            Base3Clearance.Value = Base3ClearanceEdit.Text
            If itemDetail.Low1Clearance <> Decimal.MinValue AndAlso itemDetail.Low1Clearance <> itemDetail.Low1Retail Then Low1ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Low1Clearance, "formatnumber")
            Low1Clearance.Value = Low1ClearanceEdit.Text
            If itemDetail.Low2Clearance <> Decimal.MinValue AndAlso itemDetail.Low2Clearance <> itemDetail.Low2Retail Then Low2ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Low2Clearance, "formatnumber")
            Low2Clearance.Value = Low2ClearanceEdit.Text
            If itemDetail.ManhattanClearance <> Decimal.MinValue AndAlso itemDetail.ManhattanClearance <> itemDetail.ManhattanRetail Then ManhattanClearanceEdit.Text = DataHelper.SmartValues(itemDetail.ManhattanClearance, "formatnumber")
            ManhattanClearance.Value = ManhattanClearanceEdit.Text
            If itemDetail.QuebecClearance <> Decimal.MinValue AndAlso itemDetail.QuebecClearance <> itemDetail.QuebecRetail Then QuebecClearanceEdit.Text = DataHelper.SmartValues(itemDetail.QuebecClearance, "formatnumber")
            QuebecClearance.Value = QuebecClearanceEdit.Text
            If itemDetail.PuertoRicoClearance <> Decimal.MinValue AndAlso itemDetail.PuertoRicoClearance <> itemDetail.PuertoRicoRetail Then PuertoRicoClearanceEdit.Text = DataHelper.SmartValues(itemDetail.PuertoRicoClearance, "formatnumber")
            PuertoRicoClearance.Value = PuertoRicoClearanceEdit.Text

            eachCaseHeight.Text = CheckandSetControl(itemDetail.EachCaseHeight, itemDetail.ID, eachCaseHeight.ID, "formatnumber4")
            eachCaseWidth.Text = CheckandSetControl(itemDetail.EachCaseWidth, itemDetail.ID, eachCaseWidth.ID, "formatnumber4")
            eachCaseLength.Text = CheckandSetControl(itemDetail.EachCaseLength, itemDetail.ID, eachCaseLength.ID, "formatnumber4")
            eachCaseWeight.Text = CheckandSetControl(itemDetail.EachCaseWeight, itemDetail.ID, eachCaseWeight.ID, "formatnumber4")
            eachCaseCubeEdit.Text = CheckandSetControl(itemDetail.EachCaseCube, itemDetail.ID, eachCaseCube.ID, eachCaseCubeEdit.ID, "", "", "", 0, "formatnumber4")
            eachCaseCube.Value = eachCaseCubeEdit.Text

            innerCaseHeight.Text = CheckandSetControl(itemDetail.InnerCaseHeight, itemDetail.ID, innerCaseHeight.ID, "formatnumber4")
            innerCaseWidth.Text = CheckandSetControl(itemDetail.InnerCaseWidth, itemDetail.ID, innerCaseWidth.ID, "formatnumber4")
            innerCaseLength.Text = CheckandSetControl(itemDetail.InnerCaseLength, itemDetail.ID, innerCaseLength.ID, "formatnumber4")
            innerCaseWeight.Text = CheckandSetControl(itemDetail.InnerCaseWeight, itemDetail.ID, innerCaseWeight.ID, "formatnumber4")
            InnerCaseCubeEdit.Text = CheckandSetControl(itemDetail.InnerCaseCube, itemDetail.ID, InnerCaseCube.ID, InnerCaseCubeEdit.ID, "", "", "", 0, "formatnumber4")
            InnerCaseCube.Value = InnerCaseCubeEdit.Text

            masterCaseHeight.Text = CheckandSetControl(itemDetail.MasterCaseHeight, itemDetail.ID, masterCaseHeight.ID, "formatnumber4")
            masterCaseWidth.Text = CheckandSetControl(itemDetail.MasterCaseWidth, itemDetail.ID, masterCaseWidth.ID, "formatnumber4")
            masterCaseLength.Text = CheckandSetControl(itemDetail.MasterCaseLength, itemDetail.ID, masterCaseLength.ID, "formatnumber4")
            masterCaseWeight.Text = CheckandSetControl(itemDetail.MasterCaseWeight, itemDetail.ID, masterCaseWeight.ID, "formatnumber4")
            MasterCaseCubeEdit.Text = CheckandSetControl(itemDetail.MasterCaseCube, itemDetail.ID, MasterCaseCube.ID, MasterCaseCubeEdit.ID, "", "", "", 0, "formatnumber4")
            MasterCaseCube.Value = MasterCaseCubeEdit.Text

          
            CountryOfOrigin.Value = itemDetail.CountryOfOrigin
            CountryOfOriginName.Text = CheckandSetControl(itemDetail.CountryOfOriginName, itemDetail.ID, CountryOfOriginName.ID)

            'NAK 12/4/2012:  Per Michaels, these fields should be editable to DBC/QA
            If StageType <> Models.WorkflowStageType.Tax And StageType <> Models.WorkflowStageType.DBC Then
                taxUDA.ChangeControl = False
                taxUDA.RenderReadOnly = True
                taxValueUDA.ChangeControl = False
                taxValueUDA.RenderReadOnly = True
            End If

            taxUDA.SelectedValue = CheckandSetControl(itemDetail.TaxUDA, itemDetail.ID, taxUDA.ID)
            taxValueUDA.Text = CheckandSetControl(itemDetail.TaxValueUDA, itemDetail.ID, taxValueUDA.ID)


            Hazardous.SelectedValue = CheckandSetControl(itemDetail.Hazardous.ToUpper, itemDetail.ID, Hazardous.ID)
            HazardousFlammable.SelectedValue = CheckandSetControl(itemDetail.HazardousFlammable.ToUpper, itemDetail.ID, HazardousFlammable.ID)
            HazardousContainerType.SelectedValue = CheckandSetControl(itemDetail.HazardousContainerType.ToUpper, itemDetail.ID, HazardousContainerType.ID)
            'If itemDetail.HazardousContainerSize <> Decimal.MinValue Then hazardousContainerSize.Text = FormatNumber(itemDetail.HazardousContainerSize, -1, 0, 0, -1)
            HazardousContainerSize.Text = CheckandSetControl(itemDetail.HazardousContainerSize, itemDetail.ID, HazardousContainerSize.ID)
            HazardousMSDSUOM.SelectedValue = CheckandSetControl(itemDetail.HazardousMSDSUOM.ToUpper, itemDetail.ID, HazardousMSDSUOM.ID)
            HazardousManufacturerName.Text = CheckandSetControl(itemDetail.HazardousManufacturerName, itemDetail.ID, HazardousManufacturerName.ID)
            HazardousManufacturerCity.Text = CheckandSetControl(itemDetail.HazardousManufacturerCity, itemDetail.ID, HazardousManufacturerCity.ID)
            HazardousManufacturerState.Text = CheckandSetControl(itemDetail.HazardousManufacturerState, itemDetail.ID, HazardousManufacturerState.ID)
            HazardousManufacturerPhone.Text = CheckandSetControl(itemDetail.HazardousManufacturerPhone, itemDetail.ID, HazardousManufacturerPhone.ID)
            HazardousManufacturerCountry.Text = CheckandSetControl(itemDetail.HazardousManufacturerCountry, itemDetail.ID, HazardousManufacturerCountry.ID)

            'SET Language Information
            If Not String.IsNullOrEmpty(itemDetail.SKU) Then

                PLIEnglish.SelectedValue = CheckandSetControl(itemDetail.PLIEnglish, itemDetail.ID, PLIEnglish.ID)
                TIEnglish.SelectedValue = CheckandSetControl(itemDetail.TIEnglish, itemDetail.ID, TIEnglish.ID)
                PLIFrench.SelectedValue = CheckandSetControl(itemDetail.PLIFrench, itemDetail.ID, PLIFrench.ID)
                TIFrench.SelectedValue = CheckandSetControl(itemDetail.TIFrench, itemDetail.ID, TIFrench.ID)
                FrenchShortDescription.Text = CheckandSetControl(itemDetail.FrenchShortDescription, itemDetail.ID, FrenchShortDescription.ID)
                FrenchLongDescription.Text = CheckandSetControl(itemDetail.FrenchLongDescription, itemDetail.ID, FrenchLongDescription.ID)
                PLISpanish.SelectedValue = CheckandSetControl(itemDetail.PLISpanish, itemDetail.ID, PLISpanish.ID)
                TISpanish.SelectedValue = "N" 'TI Spanish not implemented.  Always set to No.
                SpanishShortDescription.Text = CheckandSetControl(itemDetail.SpanishShortDescription, itemDetail.ID, SpanishShortDescription.ID)
                SpanishLongDescription.Text = CheckandSetControl(itemDetail.SpanishLongDescription, itemDetail.ID, SpanishLongDescription.ID)
                CustomsDescription.Text = CheckandSetControl(itemDetail.CustomsDescription, itemDetail.ID, CustomsDescription.ID)
                ExemptEndDateFrench.Text = CheckandSetControl(itemDetail.ExemptEndDateFrench, itemDetail.ID, ExemptEndDateFrench.ID)

                'NAK 5/15/2013:  Per Michaels, if the TIFrench or TISpanish field is set to YES, do not let users change it.
                If itemDetail.TIFrench = "Y" Then
                    TIFrench.RenderReadOnly = True
                End If
                If itemDetail.TISpanish = "Y" Then
                    TISpanish.RenderReadOnly = True
                End If

                EnglishShortDescription.Text = CheckandSetControl(itemDetail.EnglishShortDescription, itemDetail.ID, EnglishShortDescription.ID)
                EnglishLongDescription.Text = CheckandSetControl(itemDetail.EnglishLongDescription, itemDetail.ID, EnglishLongDescription.ID)
            Else
                'TODO: If we need to default any language fields, put that here.
            End If

            'Set CRC Information
            HarmonizedCodeNumber.Text = CheckandSetControl(itemDetail.HarmonizedCodeNumber, itemDetail.ID, HarmonizedCodeNumber.ID)
            CanadaHarmonizedCodeNumber.Text = CheckandSetControl(itemDetail.CanadaHarmonizedCodeNumber, itemDetail.ID, CanadaHarmonizedCodeNumber.ID)
            DetailInvoiceCustomsDesc0.Text = CheckandSetControl(itemDetail.DetailInvoiceCustomsDesc0, itemDetail.ID, DetailInvoiceCustomsDesc0.ID)
            ComponentMaterialBreakdown0.Text = CheckandSetControl(itemDetail.ComponentMaterialBreakdown0, itemDetail.ID, ComponentMaterialBreakdown0.ID)

            'phyto
            FumigationCertificate.SelectedValue = CheckandSetControl(itemDetail.FumigationCertificate, itemDetail.ID, FumigationCertificate.ID)
            PhytoTemporaryShipment.SelectedValue = CheckandSetControl(itemDetail.PhytoTemporaryShipment, itemDetail.ID, PhytoTemporaryShipment.ID)


            ' validation
            If itemDetail.IsValid = ItemValidFlag.Unknown Then
                _validWasUnknown = True
            End If


            Dim vrBatch As ValidationRecord = Nothing
            Dim valRecord As ValidationRecord

            If ItemMasterView OrElse (batchDetail IsNot Nothing AndAlso ValidationHelper.SkipBatchValidation(batchDetail.WorkflowStageType)) Then
                If Not ItemMasterView Then
                    vrBatch = New ValidationRecord(itemDetail.BatchID, ItemRecordType.Batch)
                End If
            Else
                vrBatch = ValidationHelper.ValidateItemMaintBatch(itemDetail.BatchID, ReadOnlyForm)
                vrBatch.RemoveErrorsByField("FutureCostExists")
            End If

            If ItemMasterView OrElse (batchDetail IsNot Nothing AndAlso ValidationHelper.SkipValidation(batchDetail.WorkflowStageType)) Then
                valRecord = ValidationHelper.ValidateItemMaintItemForFutureCostsOnly(itemDetail, RowChanges, ReadOnlyForm)
            Else
                valRecord = ValidationHelper.ValidateItemMaintItem(itemDetail, RowChanges, batchDetail, ReadOnlyForm)
            End If

            'If vrBatch.IsValid AndAlso valRecord.IsValid Then
            If valRecord.IsValid Then
                _validFlag = ItemValidFlag.Valid
            Else
                _validFlag = ItemValidFlag.NotValid
            End If

            ' validation
            If vrBatch IsNot Nothing Then ValidationHelper.LoadValidationSummary(validationDisplay, vrBatch, False)
            ValidationHelper.LoadValidationSummary(validationDisplay, valRecord, False)
            ' clean up
            vrBatch = Nothing
            valRecord = Nothing
            'End If


            ' FILES
            Dim imgFile As Long = FormHelper.GetValueWithChanges(itemDetail.ImageID, RowChanges, "ImageID", "long")
            Dim msdsFile As Long = FormHelper.GetValueWithChanges(itemDetail.MSDSID, RowChanges, "MSDSID", "long")
            Dim imgChanged As Boolean = IIf(DataHelper.SmartValues(itemDetail.ImageID, "long", True) = DataHelper.SmartValues(imgFile, "long", True), False, True)
            Dim msdsChanged As Boolean = IIf(DataHelper.SmartValues(itemDetail.MSDSID, "long", True) = DataHelper.SmartValues(msdsFile, "long", True), False, True)

            Dim dateNow As Date = Now()

            If imgFile > 0 Then
                ImageID.Value = imgFile.ToString()
            Else
                ImageID.Value = String.Empty
            End If
            If itemDetail.ImageID > 0 Then
                ImageID_ORIG.Value = itemDetail.ImageID.ToString()
            Else
                ImageID_ORIG.Value = String.Empty
            End If

            If msdsFile > 0 Then
                MSDSID.Value = msdsFile.ToString()
            Else
                MSDSID.Value = String.Empty
            End If
            If itemDetail.MSDSID > 0 Then
                MSDSID_ORIG.Value = itemDetail.MSDSID.ToString()
            Else
                MSDSID_ORIG.Value = String.Empty
            End If

            ' Set Image
            I_Image.Attributes.Add("onclick", "showImage();")
            I_Image.Style.Add("cursor", "hand")
            If imgFile > 0 Then
                I_Image.Visible = True
                I_Image.ImageUrl = "images/app_icons/icon_jpg_small_on.gif?id=" & imgFile
                B_UpdateImage.Value = "Update"
            Else
                I_Image.Visible = True
                I_Image.ImageUrl = "images/app_icons/icon_jpg_small.gif"
                'I_Image_Label.InnerText = "(upload)"
                B_DeleteImage.Disabled = True
            End If

            If Not ReadOnlyForm Then
                B_UpdateImage.Attributes.Add("onclick", String.Format("openUploadItemMaintFile('{0}', '{1}', '{2}', '1');", "X", itemDetail.ID, ItemFileTypeHelper.GetFileTypeString(Models.ItemFileType.Image)))
                B_DeleteImage.Attributes.Add("onclick", "return deleteImage(" & itemDetail.ID & ");")
            Else
                B_UpdateImage.Disabled = True
                B_DeleteImage.Disabled = True
            End If
            ' CHANGES (ImageID)
            I_Image_ORIG.Attributes.Add("onclick", "showImage(true);")

            If itemDetail.ImageID > 0 Then
                I_Image_ORIG.ImageUrl = "images/app_icons/icon_jpg_small_on.gif?id=" & itemDetail.ImageID
            Else
                I_Image_ORIG.ImageUrl = "images/app_icons/icon_jpg_small.gif"
            End If
            If imgChanged Then
                Me.AddStartupScript("showNLCWrapper('ImageID');")
            End If
            nlcCCRevert_ImageID.Attributes("onclick") = "undoImage('" & itemDetail.ID & "');"

            ' Set MSDS Sheet
            I_MSDS.Attributes.Add("onclick", "showMSDS('" & Server.UrlEncode(String.Format("item_{0}_{1}.pdf", itemDetail.BatchID, dateNow.ToString("yyyyMMdd"))) & "');")
            I_MSDS.Style.Add("cursor", "hand")
            If msdsFile > 0 Then
                I_MSDS.Visible = True
                I_MSDS.ImageUrl = "images/app_icons/icon_pdf_small.gif?id=" & msdsFile
                B_UpdateMSDS.Value = "Update"
            Else
                I_MSDS.Visible = True
                I_MSDS.ImageUrl = "images/app_icons/icon_pdf_small_off.gif"
                'I_MSDS_Label.InnerText = "(upload)"
                B_DeleteMSDS.Disabled = True
            End If

            If Not ReadOnlyForm Then
                B_UpdateMSDS.Attributes.Add("onclick", String.Format("openUploadItemMaintFile('{0}', '{1}', '{2}', '1');", "X", itemDetail.ID, ItemFileTypeHelper.GetFileTypeString(Models.ItemFileType.MSDS)))
                B_DeleteMSDS.Attributes.Add("onclick", "return deleteMSDS(" & itemDetail.ID & ");")
            Else
                B_UpdateMSDS.Disabled = True
                B_DeleteMSDS.Disabled = True
            End If
            ' CHANGES (MSDSID)
            I_MSDS_ORIG.Attributes.Add("onclick", "showMSDS('" & Server.UrlEncode(String.Format("item_{0}_{1}.pdf", itemDetail.BatchID, dateNow.ToString("yyyyMMdd"))) & "', true);")

            If itemDetail.MSDSID > 0 Then
                I_MSDS_ORIG.ImageUrl = "images/app_icons/icon_pdf_small.gif?id=" & itemDetail.MSDSID
            Else
                I_MSDS_ORIG.ImageUrl = "images/app_icons/icon_pdf_small_off.gif"
            End If
            If msdsChanged Then
                Me.AddStartupScript("showNLCWrapper('MSDSID');")
            End If
            nlcCCRevert_MSDSID.Attributes("onclick") = "undoMSDS('" & itemDetail.ID & "');"

            If ReadOnlyForm Then
                btnUpdate.Enabled = False
                btnUpdateClose.Enabled = False
                btnCancel.Value = "Close"
                btnStockStratHelper.Disabled = True
            End If

        End If ' itemDetail.ID > 0
        itemDetail = Nothing

        If Hazardous.SelectedValue <> "Y" Then
            Me.HazardousFlammableRow.Style.Add("display", "none")
            Me.HazardousContainerTypeRow.Style.Add("display", "none")
            Me.HazardousContainerSizeRow.Style.Add("display", "none")
            Me.HazardousMSDSUOMRow.Style.Add("display", "none")
            Me.HazardousManufacturerNameRow.Style.Add("display", "none")
            Me.HazardousManufacturerCityRow.Style.Add("display", "none")
            Me.HazardousManufacturerStateRow.Style.Add("display", "none")
            Me.HazardousManufacturerPhoneRow.Style.Add("display", "none")
            Me.HazardousManufacturerCountryRow.Style.Add("display", "none")
        End If

        If Not UserCanEdit Then
            'btnUpdate.Visible = False
            btnUpdate.Enabled = False
            'btnUpdateClose.Visible = False
            btnUpdateClose.Enabled = False
            btnCancel.Value = "Close"
        End If

        'NAK 12/4/2012:  Per Michaels, these fields should be editable to DBC/QA
        If StageType <> Models.WorkflowStageType.Tax And StageType <> Models.WorkflowStageType.DBC Or ReadOnlyForm Then
            taxUDA.RenderReadOnly = True
            taxValueUDA.RenderReadOnly = True
        End If

        If ReadOnlyForm Then
            SetFormReadOnly()
        End If

        ImplementFieldLocking(itemFL)
        FormHelper.SetupControlsFromMetadata(Me, md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail))

        ' clean up 
        itemFL = Nothing

        objMichaels = Nothing
        ' call back
        ' check security
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) Then
            Response.End()
        End If

    End Sub

    Private Sub InitStockStratHelper()

        Dim oSS As New NovaLibra.Coral.Data.Michaels.StockingStrategy
        Dim whs As New Dictionary(Of Int64, Int64)
        whs = oSS.GetWarehousesForStockingStrategy(Today)

        Dim li As ListItem

        For Each kvp As KeyValuePair(Of Int64, Int64) In whs
            li = New ListItem
            Dim wh As Int64 = kvp.Key
            Dim whDest As Int64 = kvp.Value
            li.Value = wh
            If whDest > 0 Then
                li.Enabled = False
                li.Text = Right(wh, 2) & " (replaced by " & Right(whDest, 2) & ")"
            Else
                li.Text = Right(wh, 2)
            End If
            chkLstWarehouses.Items.Add(li)
        Next

    End Sub


    Protected Sub btnShowStockStrats_Click(sender As Object, e As EventArgs) Handles btnShowStockStrats.Click
        Try
            Dim ITA As String
            If ItemTypeAttribute.SelectedValue Is Nothing Then
                ITA = ""
            Else
                ITA = ItemTypeAttribute.SelectedValue
            End If

            Dim oSS As New NovaLibra.Coral.Data.Michaels.StockingStrategy

            Dim strWarehouses As String = ""
            For Each li As ListItem In chkLstWarehouses.Items
                If li.Selected Then
                    strWarehouses += li.Value & ","
                End If
            Next
            strWarehouses = strWarehouses.TrimEnd(",")

            Dim dicStockStrats As New Dictionary(Of String, String)
            dicStockStrats = oSS.GetStockingStrategiesByWarehouses(ITA, strWarehouses, StageType)
            LstBoxStockingStrategies.DataSource = dicStockStrats
            LstBoxStockingStrategies.DataTextField = "Value"
            LstBoxStockingStrategies.DataValueField = "Key"
            LstBoxStockingStrategies.DataBind()

            If strWarehouses.Length = 0 Then
                lblStockStratMsg.Text = "No warehouses selected."
            Else
                If dicStockStrats.Count = 0 Then
                    lblStockStratMsg.Text = "No Strategies found for selected warehouses."
                Else
                    lblStockStratMsg.Text = ""
                End If
            End If
        Catch ex As Exception
            lblStockStratMsg.Text = "An Error has occured."
            Logger.LogError(ex)
        End Try
    End Sub

    Private Sub CloseTheForm()
        Response.Redirect(String.Format("closeform.aspx?rl={0}", IIf(RefreshGrid, "1", "0")))
    End Sub


    ' Simple call. Ctl.ID = Change Recs Field_Name, and extra key fields are defaulted
    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal ItemID As Integer, ByVal ctlID As String, _
            Optional ByVal formatStr As String = "", Optional ByVal Percision As Integer = 2, Optional ByVal Check As Boolean = True) As Object

        Return CheckandSetControl(IMValue, ItemID, ctlID, ctlID, "", "", "", 0, formatStr, Percision, Check)

    End Function

    ' Moderate call. Ctl.ID = Change Recs Field_Name, but extra key fields are needed to reference data
    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal ItemID As Integer, ByVal ctlID As String, _
        ByVal COO As String, ByVal UPC As String, ByVal EffectiveDate As String, ByVal Counter As Integer, _
        Optional ByVal formatStr As String = "", Optional ByVal Percision As Integer = 2, Optional ByVal Check As Boolean = True) As Object

        Return CheckandSetControl(IMValue, ItemID, ctlID, ctlID, COO, UPC, EffectiveDate, Counter, formatStr, Percision, Check)

    End Function

    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal ItemID As Integer, ByVal ChangeField As String, ByVal ctlID As String, _
     ByVal COO As String, ByVal UPC As String, ByVal EffectiveDate As String, ByVal Counter As Integer, _
     Optional ByVal formatStr As String = "", Optional ByVal Percision As Integer = 2, Optional ByVal Check As Boolean = True) As Object

        Dim ctlCC As NovaLibra.Controls.INLChangeControl  ' interface to a Nova Libra Change control 
        Dim retValue As String
        Dim changeRec As Models.IMChangeRecord
        Dim baseType As String = ""
        Dim IMValueAsStr As String
        Dim useNull As Boolean
        If LCase(Left(formatStr, 6)) = "format" Then
            useNull = True
        Else
            useNull = False
        End If

        ' Find a matching Change Record
        changeRec = FormHelper.FindIMChangeRecord(IMChanges, ItemID, ChangeField, COO, UPC, EffectiveDate, Counter)

        mdColumn = mdTable.GetColumnByName(ChangeField)     ' Find the fieldname to use for this save
        If mdColumn IsNot Nothing Then
            baseType = mdColumn.GenericType
        Else
            If Check Then   ' Metadata should be defined 
                Throw New ArgumentException("Field " & ctlID & " not found in MetaData During  Load.")
                retValue = Nothing    ' Need to save but could not find field name in metadatacolum. trouble
                Return retValue
            Else
                baseType = "string"     ' for Addtional COOs
            End If
        End If

        IMValueAsStr = DataHelper.SmartValuesAsString(IMValue, baseType)

        ' Check is false that means its a new control only (Additional UPCs and COOs that only exist in the ChangeRec)
        If Check Then
            If changeRec.ItemID > 0 Then     ' match found. 
                retValue = changeRec.FieldValue.ToString.Trim()
            Else    ' Change Rec not found. return passed in value
                retValue = IMValueAsStr     'IMValue.ToString.Trim()
            End If
        Else
            retValue = IMValueAsStr     'IMValue.ToString.Trim()
        End If

        ' Set the properties of the Change control if found
        Try
            ctlCC = FindControl(ctlID)
        Catch
            ctlCC = Nothing
        End Try
        If Not ctlCC Is Nothing Then
            If Check Then
                If formatStr.Length > 0 Then
                    ctlCC.OriginalValue = DataHelper.SmartValues(IMValueAsStr, formatStr, useNull, String.Empty, Percision)
                Else
                    ctlCC.OriginalValue = IMValueAsStr      ' set the original value to the Item Master record
                End If
            Else
                ctlCC.OriginalValue = ""            ' set the original value as empty since it does not exist in Item Master Record
            End If

        End If

        If formatStr.Length > 0 Then retValue = DataHelper.SmartValues(retValue, formatStr, useNull, String.Empty, Percision)
        Return retValue
    End Function

    'Private Function AddCheckbox(ByVal CtlName As String, ByVal index As String, ByVal phID As String) As NovaLibra.Controls.NLCheckBox
    Private Function AddCheckbox(ByVal CtlName As String, ByVal index As String) As NovaLibra.Controls.NLCheckBox

        Dim nlCheckbox As NovaLibra.Controls.NLCheckBox = New NovaLibra.Controls.NLCheckBox
        If ReadOnlyForm Then
            nlCheckbox.RenderReadOnly = True
        End If
        nlCheckbox.ChangeControl = False
        nlCheckbox.Attributes.Add("onclick", "checkNewPrimary();")
        nlCheckbox.ID = CtlName & index
        Return nlCheckbox
    End Function

    Private Function AddChangeControlTB(ByVal CtlName As String, ByVal index As String, ByVal ctlCtr As Integer, ByRef cell As TableCell) As NovaLibra.Controls.NLTextBox
        'Private Function AddChangeControlTB(ByVal CtlName As String, ByVal index As String, ByVal ctlCtr As Integer) As NovaLibra.Controls.NLTextBox

        Dim nlTextbox As NovaLibra.Controls.NLTextBox = New NovaLibra.Controls.NLTextBox
        Dim sup As New HtmlGenericControl("div")
        Dim sup1 As New HtmlGenericControl("span")

        If ReadOnlyForm Then
            sup1.InnerHtml = "&nbsp;&nbsp;<sup>" & ctlCtr.ToString & "</sup>"
        Else
            sup.InnerHtml = "<sup>" & ctlCtr.ToString & "</sup>"
        End If
        If Not ReadOnlyForm Then
            nlTextbox.ChangeControl = True
        Else
            nlTextbox.ChangeControl = False
            nlTextbox.RenderReadOnly = True
        End If

        nlTextbox.MaxLength = 50
        'nlTextbox.Width = 175
        nlTextbox.ID = CtlName & index
        cell.Controls.Add(nlTextbox)
        If ReadOnlyForm Then
            cell.Controls.Add(sup1)
        Else
            cell.Controls.Add(sup)
        End If

        Dim div1 As New HtmlGenericControl("div")
        div1.Attributes.Add("style", "clear:both;")     'force next control to be below this one
        div1.InnerHtml = "<img src=""images/spacer.gif"" width=""1"" height=""2"" alt="""" />"
        cell.Controls.Add(div1)
        Return nlTextbox
    End Function

    ' Check and Save: Check a control Based on ItemRecord and existing Change Record and Save accordingly. Also Save change in Itemdetail record for validation
    Private Function CheckandSave(ByVal ctlName As String, ByRef changeRec As Models.IMChangeRecord, ByRef itemDetail As Models.ItemMaintItemDetailFormRecord, _
            ByVal newValue As String, Optional ByVal baseType As String = "") As Boolean

        Dim result As Boolean = False
        mdColumn = mdTable.GetColumnByName(ctlName)     ' Find the fieldname to use for this save

        If mdColumn IsNot Nothing Then
            result = FormHelper.CheckandSave(ctlName, changeRec, itemDetail, newValue, mdColumn, IMChanges, UserID, baseType)
        Else
            Throw New ArgumentException("Field " & ctlName & " not found in MetaData During Domestic Save.")
            result = False    ' Need to save but could not find field name in metadatacolum. trouble
        End If
        Return result
    End Function

    Private Sub SetFormReadOnly()
        Dim mdColumns As Hashtable
        mdColumns = mdTable.GetColums     ' Find the fieldname to use for this save

        For Each col As NovaLibra.Coral.SystemFrameworks.MetadataColumn In mdColumns.Values
            If col.MaintEditable Then
                LockField(col.ColumnName, "V")
            End If
        Next
    End Sub

    Private Sub ImplementFieldLocking(ByRef itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking)
        Dim bIsAdmin = IsAdminDBCQA()
        For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
            Select Case col.ColumnName
                Case "SpanishLongDescription", "SpanishShortDescription", "FrenchLongDescription", "FrenchShortDescription", "FrenchItemDescription", "EnglishLongDescription", "EnglishShortDescription",
                     "TIEnglish", "TIFrench", "TISpanish"
                    LockField(col.ColumnName, col.Permission)
                Case Else
                    If Not bIsAdmin Then
                        LockField(col.ColumnName, col.Permission)
                    End If
            End Select
        Next

        If EnglishShortDescription.Visible = False And
            EnglishLongDescription.Visible = False And
            FrenchShortDescription.Visible = False And
            FrenchLongDescription.Visible = False And
            SpanishLongDescription.Visible = False And
            SpanishShortDescription.Visible = False Then

            CFDs.Visible = False

        End If

        If TIEnglish.Visible = False And
            TIFrench.Visible = False And
            TISpanish.Visible = False Then

            TIs.Visible = False

        End If
    End Sub

    Public Overrides Sub LockField(ByVal colName As String, ByVal permission As Char)
        Select Case UCase(permission)
            Case "N"            ' Hide Control
                Select Case colName
                    Case "AdditionalUPC"
                        Me.additionalUPCFL.Attributes.Add("style", "display:none")
                        Me.additionalUPCParent.Attributes.Add("style", "display:none")

                    Case "AddCountryOfOrigin"
                        '    Me.additionalCOOFL.InnerHtml = "&nbsp;"
                        '    Me.additionalCOOParent.Visible = False
                        additionalCOOTbl.Visible = False
                        'Case "CountryOfOrigin", "CountryOfOriginName"
                        Me.CountryOfOriginFL.InnerHtml = "&nbsp;"
                        Me.CountryOfOriginParent.Visible = False
                    Case "MSDSID"
                        Me.MSDSIDFL.Attributes.Add("style", "display:none")
                        Me.MSDSIDParent.Attributes.Add("style", "display:none")
                    Case "ImageID"
                        Me.ImageIDFL.Attributes.Add("style", "display:none")
                        Me.ImageIDParent.Attributes.Add("style", "display:none")

                    Case Else   ' dynamic control of fields
                        MyBase.Lockfield(colName, permission)

                End Select

            Case "V"
                Select Case colName
                    Case "AddCountryOfOrigin"
                        Dim cnt As Integer = additionalCOOEnd.Value
                        For i As Integer = 1 To cnt
                            Dim ctl As Control
                            ctl = FindControl(cNEWPRIMARY + CStr(i))
                            If ctl IsNot Nothing Then
                                CType(ctl, NovaLibra.Controls.INLChangeControl).RenderReadOnly = True
                            End If
                            ctl = FindControl(cADDCOONAME + CStr(i))
                            If ctl IsNot Nothing Then
                                CType(ctl, NovaLibra.Controls.INLChangeControl).RenderReadOnly = True
                            End If

                            Dim tblRow As TableRow
                            tblRow = FindControl(cEMPTYCOUNTRY)
                            If tblRow IsNot Nothing Then
                                tblRow.Visible = False
                            End If

                            tblRow = FindControl(cADDACOUNTRY)
                            If tblRow IsNot Nothing Then
                                tblRow.Visible = False
                            End If
                        Next

                    Case "CountryOfOrigin", "CountryOfOriginName"
                        Me.CountryOfOriginName.RenderReadOnly = True
                    Case cADDCOO
                        Dim i As Integer = 1, strTemp As String
                        Dim nlTextbox As NovaLibra.Controls.NLTextBox = Nothing
                        Do While True
                            strTemp = cADDCOONAME & i.ToString
                            nlTextbox = FindControl(strTemp)
                            If nlTextbox IsNot Nothing Then
                                nlTextbox.RenderReadOnly = True
                            Else
                                Exit Do
                            End If
                            i += 1
                        Loop

                    Case "TaxUDA"
                        'taxUDALabel.Attributes.Add("style", "display:none")
                        taxUDA.RenderReadOnly = True

                    Case "MSDSID"
                        Me.B_UpdateMSDS.Disabled = True
                        Me.B_DeleteMSDS.Disabled = True
                    Case "ImageID"
                        Me.B_UpdateImage.Disabled = True
                        Me.B_DeleteImage.Disabled = True
                    Case "PrivateBrandLabel"
                        PrivateBrandLabel.RenderReadOnly = True

                    Case Else   ' dynamic control of fields 
                        MyBase.Lockfield(colName, permission)

                End Select

            Case Else   ' Edit: Do nothing

        End Select

    End Sub

#Region "Scripts"
    Private Sub CheckForStartupScripts()
        Dim startupScriptKey As String = "__detail_form_"
        If Not Me.Page.ClientScript.IsStartupScriptRegistered(startupScriptKey) Then
            CreateStartupScripts(startupScriptKey)
        End If
    End Sub

    Private Sub CreateStartupScripts(ByVal startupScriptKey As String)

        Dim sb As New StringBuilder("")
        sb.Length = 0
        sb.Append("" & vbCrLf)
        sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)

        If Request("r") = "1" Then
            sb.Append("refreshItemGrid();" & vbCrLf)
        End If
        If _startupScripts <> String.Empty Then
            sb.Append(_startupScripts & vbCrLf)
        End If

        sb.Append("//-->" & vbCrLf)
        sb.Append("</script>" & vbCrLf)
        Me.ClientScript.RegisterStartupScript(Me.GetType(), startupScriptKey, sb.ToString())
    End Sub
#End Region

    Private Function FormatFormNumber(ByVal inputValue As Decimal) As String
        If inputValue <> Decimal.MinValue Then
            Return DataHelper.SmartValues(inputValue, "FormatNumber")
        Else
            Return String.Empty
        End If
    End Function

    Private Function FormatFormDate(ByVal inputValue As Date) As String
        If inputValue <> Date.MinValue Then
            Return inputValue.ToShortDateString()
        Else
            Return String.Empty
        End If
    End Function

#Region "Callbacks"


    Public Function GetCallbackResult() As String Implements System.Web.UI.ICallbackEventHandler.GetCallbackResult
        Dim str As String() = Split(_callbackArg, CALLBACK_SEP)
        If str.Length <= 0 Then
            Return ""
        End If
        Select Case str(0)
            Case "ECPC"
                ' each case pack cube
                If str.Length < 5 Then
                    Return "ECPC" & CALLBACK_SEP & "0"
                End If
                Return "ECPC" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateItemCasePackCube(str(1), str(2), str(3), str(4))
            Case "ICPC"
                ' inner case pack cube
                If str.Length < 5 Then
                    Return "ICPC" & CALLBACK_SEP & "0"
                End If
                Return "ICPC" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateItemCasePackCube(str(1), str(2), str(3), str(4))
            Case "MCPC"
                ' master case pack cube
                If str.Length < 5 Then
                    Return "MCPC" & CALLBACK_SEP & "0"
                End If
                Return "MCPC" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateItemCasePackCube(str(1), str(2), str(3), str(4))
            Case "ConversionDate"
                ' conversion date
                If str.Length < 2 Then
                    Return "ConversionDate" & CALLBACK_SEP & "0"
                End If
                Dim leadTime As Integer = DataHelper.SmartValues(str(1), "integer", True)
                Return "ConversionDate" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateConversionDate(leadTime)
            Case "Retail"
                ' retail values
                If str.Length < 5 Then
                    Return "Retail" & CALLBACK_SEP & "0"
                End If
                Dim prePriced As String = DataHelper.SmartValues(str(2), "string", False)
                Dim baseRetail As Decimal = DataHelper.SmartValues(str(3).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim alaskaRetail As Decimal = DataHelper.SmartValues(str(4).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim resultBase As String = String.Empty
                Dim resultAlaska As String = String.Empty
                If baseRetail <> Decimal.MinValue Then
                    resultBase = DataHelper.SmartValues(baseRetail, "formatnumber", False, String.Empty, 2)
                    If prePriced = "Y" Then
                        resultAlaska = resultBase
                    Else
                        ' price point lookup
                        Dim objRecord As PricePointRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupAlaskRetailFromBaseRetail(baseRetail)
                        If Not objRecord Is Nothing AndAlso objRecord.DiffRetail <> Decimal.MinValue Then
                            resultAlaska = DataHelper.SmartValues(objRecord.DiffRetail, "formatnumber", False, String.Empty, 2)
                        Else
                            If alaskaRetail <> Decimal.MinValue Then
                                resultAlaska = DataHelper.SmartValues(alaskaRetail, "formatnumber", False, String.Empty, 2)
                            End If
                        End If
                    End If
                End If
                Return "Retail" & CALLBACK_SEP & "1" & CALLBACK_SEP & str(1) & CALLBACK_SEP & resultBase & CALLBACK_SEP & resultAlaska
            Case "RetailAlaska"
                ' canada retail value
                If str.Length < 2 Then
                    Return "RetailAlaska" & CALLBACK_SEP & "0"
                End If
                Dim baseAlaska As Decimal = DataHelper.SmartValues(str(1).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim resultAlaska As String = String.Empty
                If baseAlaska <> Decimal.MinValue Then
                    resultAlaska = DataHelper.SmartValues(baseAlaska, "formatnumber", False, String.Empty, 2)
                End If
                Return "RetailAlaska" & CALLBACK_SEP & "1" & CALLBACK_SEP & resultAlaska
            Case "RetailCanada"
                ' canada retail value
                If str.Length < 2 Then
                    Return "RetailCanada" & CALLBACK_SEP & "0"
                End If
                Dim baseCanada As Decimal = DataHelper.SmartValues(str(1).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim resultCanada As String = String.Empty
                If baseCanada <> Decimal.MinValue Then
                    resultCanada = DataHelper.SmartValues(baseCanada, "formatnumber", False, String.Empty, 2)
                End If
                Return "RetailCanada" & CALLBACK_SEP & "1" & CALLBACK_SEP & resultCanada
            Case "CountryOfOrigin"
                ' Country Of Origin value
                If str.Length < 2 Then
                    Return "CountryOfOrigin" & CALLBACK_SEP & "0"
                End If
                Dim country As String = str(1)
                Dim retString As String
                Dim objCountry As CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(country)
                If Not objCountry Is Nothing AndAlso objCountry.CountryName <> String.Empty AndAlso objCountry.CountryCode <> String.Empty Then
                    retString = "CountryOfOrigin" & CALLBACK_SEP & "1" & CALLBACK_SEP & objCountry.CountryName & CALLBACK_SEP & objCountry.CountryCode
                Else
                    retString = "CountryOfOrigin" & CALLBACK_SEP & "1" & CALLBACK_SEP & "" & CALLBACK_SEP & ""
                End If
                objCountry = Nothing
                Return retString
            Case "DELETEIMAGE", "DELETEMSDS"
                If str.Length < 3 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Dim thisItemID As Long = DataHelper.SmartValues(str(1), "long", True)
                Dim fileID As Long = DataHelper.SmartValues(str(2), "long", True)
                If thisItemID = Long.MinValue Or thisItemID < 0 Or fileID = Long.MinValue Or fileID < 0 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Dim itemRec As Models.ItemMaintItemDetailFormRecord = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(thisItemID, AppHelper.GetVendorID())
                Dim rowChanges = New Models.IMRowChanges(thisItemID)
                If str(0) = "DELETEMSDS" Then
                    rowChanges.Add(FormHelper.CreateChangeRecord(itemRec.MSDSID, "MSDSID", "bigint", String.Empty))
                Else
                    rowChanges.Add(FormHelper.CreateChangeRecord(itemRec.ImageID, "ImageID", "bigint", String.Empty))
                End If
                Dim bRet As Boolean = Data.MaintItemMasterData.SaveItemMaintChanges(rowChanges, UserID)
                rowChanges = Nothing
                itemRec = Nothing
                ' audit
                ''Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                ''Dim audit As New Models.AuditRecord()
                ''audit.SetupAudit(Models.MetadataTable.Items, thisItemID, Models.AuditRecordType.Update, CInt(Session("UserID")))
                ''If str(0) = "DELETEMSDS" Then
                ''    audit.AddAuditField("MSDS_ID", String.Empty)
                ''Else
                ''    audit.AddAuditField("Image_ID", String.Empty)
                ''End If
                ''objFA.SaveAuditRecord(audit)
                ''objFA = Nothing
                ''audit = Nothing
                ' end audit
                If bRet Then
                    Return str(0) & CALLBACK_SEP & "1" & CALLBACK_SEP & thisItemID & CALLBACK_SEP & fileID
                Else
                    Return str(0) & CALLBACK_SEP & "0"
                End If
            Case "LikeItemSKU"
                ' retail values
                If str.Length < 2 Then
                    Return "LikeItemSKU" & CALLBACK_SEP & "0"
                End If
                Dim item As String = DataHelper.SmartValues(str(1), "string", False)
                Dim resultItemDesc As String = String.Empty
                Dim resultBaseRetail As String = String.Empty
                If item <> String.Empty Then
                    Dim objRecord As ItemMasterRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupItemMaster(item)
                    If Not objRecord Is Nothing AndAlso (objRecord.ItemDescription <> String.Empty Or objRecord.BaseRetail <> Decimal.MinValue) Then
                        resultItemDesc = objRecord.ItemDescription
                        If objRecord.BaseRetail <> Decimal.MinValue Then
                            resultBaseRetail = DataHelper.SmartValues(objRecord.BaseRetail, "formatnumber", True, String.Empty, 2)
                        End If
                    End If
                    objRecord = Nothing
                End If
                Return "LikeItemSKU" & CALLBACK_SEP & "1" & CALLBACK_SEP & item & CALLBACK_SEP & resultItemDesc & CALLBACK_SEP & resultBaseRetail
            Case "UNDOIMAGE", "UNDOMSDS"
                If str.Length < 3 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Dim thisItemID As Long = DataHelper.SmartValues(str(1), "long", True)
                Dim fileID As Long = DataHelper.SmartValues(str(2), "long", True)
                If thisItemID = Long.MinValue Or thisItemID < 0 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Dim itemRec As Models.ItemMaintItemDetailFormRecord = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(thisItemID, AppHelper.GetVendorID())
                Dim rowChanges = New Models.IMRowChanges(thisItemID)
                If str(0) = "UNDOMSDS" Then
                    rowChanges.Add(FormHelper.CreateChangeRecord(itemRec.MSDSID, "MSDSID", "bigint", itemRec.MSDSID))
                Else
                    rowChanges.Add(FormHelper.CreateChangeRecord(itemRec.ImageID, "ImageID", "bigint", itemRec.ImageID))
                End If
                Dim bRet As Boolean = Data.MaintItemMasterData.SaveItemMaintChanges(rowChanges, UserID)
                rowChanges = Nothing
                itemRec = Nothing
                If bRet Then
                    Return str(0) & CALLBACK_SEP & "1" & CALLBACK_SEP & thisItemID & CALLBACK_SEP & fileID
                Else
                    Return str(0) & CALLBACK_SEP & "0"
                End If
            Case "TotalCost"
                ' retail values
                If str.Length < 3 Then
                    Return "TotalCost" & CALLBACK_SEP & "0"
                End If
                Dim dc As Decimal = DataHelper.SmartValues(str(1).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim ic As Decimal = DataHelper.SmartValues(str(2).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim fob As Decimal = Decimal.MinValue
                If ic <> Decimal.MinValue Then
                    If dc <> Decimal.MinValue Then
                        fob = ic + dc
                    Else
                        fob = ic
                    End If
                End If
                Return "TotalCost" & CALLBACK_SEP & "1" & CALLBACK_SEP & IIf(dc = Decimal.MinValue, String.Empty, DataHelper.SmartValues(dc, "formatnumber4", False)) & CALLBACK_SEP & IIf(ic = Decimal.MinValue, String.Empty, DataHelper.SmartValues(ic, "formatnumber4", False)) & CALLBACK_SEP & IIf(fob = Decimal.MinValue, String.Empty, DataHelper.SmartValues(fob, "formatnumber4", False))
        End Select
        Return ""
    End Function

    Public Sub RaiseCallbackEvent(ByVal eventArgument As String) Implements System.Web.UI.ICallbackEventHandler.RaiseCallbackEvent
        _callbackArg = eventArgument
    End Sub

#End Region

    Public Function GetCurrentUser() As CurrentUser
        Dim objUser As CurrentUser
        If Not Session(WebConstants.SESSION_CURRENT_USER) Is Nothing Then
            objUser = CType(Session(WebConstants.SESSION_CURRENT_USER), CurrentUser)
        Else
            objUser = New CurrentUser()
        End If
        Return objUser
    End Function

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        If UserCanEdit Then
            Dim saveID As Integer = SaveChanges() '  SaveFormData()
            If saveID > 0 Then
                Response.Redirect("IMDomesticForm.aspx?id=" & saveID.ToString & "&r=1")
            End If
        End If

    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click
        If UserCanEdit Then
            Dim saveID As Long = SaveChanges() '  SaveFormData()
            If saveID > 0 Then
                Session(cBATCHID) = BatchID
                RefreshGrid = True
                CloseTheForm()
            End If
        End If

    End Sub

    Function SaveChanges() As Integer

        Dim changeRec As Models.IMChangeRecord = New Models.IMChangeRecord
        Dim itemRec As Models.ItemMaintItemDetailFormRecord
        Dim updatePackCost As Boolean = False
        Dim updatePackWeight As Boolean = False

        Dim userID As Integer = Session("UserID")
        Dim changeFlag As String = ""   ', ctlFlag As String

        ' Load Item Record to set up for validation and For Original Values for both change and Calc controls
        itemRec = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(hid.Value, AppHelper.GetVendorID)
        HeaderItemID = hid.Value

        ' batch
        Dim objData As New Data.BatchData()
        Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(itemRec.BatchID)
        objData = Nothing

        ' Load Change Records into Property for Current changes
        IMChanges = Data.MaintItemMasterData.GetIMChangeRecordsByItemID(HeaderItemID)


        ' Set up ChangeRec for Item Master Common field changes
        changeRec.ItemID = hid.Value
        changeRec.UPC = ""
        changeRec.CountryOfOrigin = ""
        changeRec.EffectiveDate = ""
        changeRec.Counter = 0

        'TODO - VALIDATION NEEDS TO BE DONE FIRST? ALSO NEED TO LOOK UP ANY ADDITIONAL COUNTRY CODES

        mdTable = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)

        ' save

        'RO item.ClassNum = DataHelper.SmartValues(classNum.Text, "integer", True)
        'RO item.SubClassNum = DataHelper.SmartValues(subClassNum.Text, "integer", True)
        CheckandSave(AllowStoreOrder.ID, changeRec, itemRec, AllowStoreOrder.SelectedValue)
        CheckandSave(InventoryControl.ID, changeRec, itemRec, InventoryControl.SelectedValue)
        CheckandSave(Discountable.ID, changeRec, itemRec, Discountable.SelectedValue)
        CheckandSave(AutoReplenish.ID, changeRec, itemRec, AutoReplenish.SelectedValue)

        CheckandSave(VendorStyleNum.ID, changeRec, itemRec, VendorStyleNum.Text.ToUpper)
        CheckandSave(ItemDesc.ID, changeRec, itemRec, ItemDesc.Text.ToUpper)
        CheckandSave(PrivateBrandLabel.ID, changeRec, itemRec, PrivateBrandLabel.SelectedValue)
        'RO CheckandSave(hybridType.ID, changeRec, itemRec, hybridType.SelectedValue)
        'RO CheckandSave(hybridSourceDC.ID, changeRec, itemRec, hybridSourceDC.SelectedValue)
        CheckandSave(StockingStrategyCode.ID, changeRec, itemRec, StockingStrategyCode.SelectedValue)
        Dim str As String = itemRec.PackItemIndicator
        Dim cr As Models.IMChangeRecord = FormHelper.FindIMChangeRecord(IMChanges, itemRec.ID, "PackItemIndicator")
        If cr IsNot Nothing AndAlso cr.ItemID > 0 Then str = DataHelper.SmartValues(cr.FieldValue, "string", False)
        If str.Length > 2 Then str = str.Substring(0, 2)
        str = str.ToUpper().Replace("-", "")
        Dim isPackParent As Boolean = False
        If (str = "D" Or str = "DP" Or str = "SB") Then isPackParent = True
        If Me.IsPack Then
            If CheckandSave(qtyInPack.ID, changeRec, itemRec, qtyInPack.Text) Then
                If Not isPackParent Then
                    updatePackCost = True
                End If
            End If
        End If

        CheckandSave(eachesMasterCase.ID, changeRec, itemRec, eachesMasterCase.Text)
        CheckandSave(eachesInnerPack.ID, changeRec, itemRec, eachesInnerPack.Text)
        CheckandSave(prePriced.ID, changeRec, itemRec, prePriced.SelectedValue)
        CheckandSave(prePricedUDA.ID, changeRec, itemRec, prePricedUDA.SelectedValue)

        'PMO200141 GTIN14 Enhancements changes
        CheckandSave(InnerGTIN.ID, changeRec, itemRec, InnerGTIN.Text)
        CheckandSave(CaseGTIN.ID, changeRec, itemRec, CaseGTIN.Text)

        If Me.IsPack AndAlso _
            CheckandSave(DisplayerCost.ID, changeRec, itemRec, DisplayerCost.Text.Replace("$", "").Replace(",", "")) Then
            If Not isPackParent Then updatePackCost = True
        End If
        If CheckandSave(ItemCost.ID, changeRec, itemRec, ItemCost.Text.Replace("$", "").Replace(",", "")) Then
            ' if Change record was saved AND the batch is a Pack AND the Item is a Child THEN set flag to update Pack cost to TRUE
            If Me.IsPack AndAlso Not isPackParent Then
                updatePackCost = True
            End If
        End If
        CheckandSave(FOBShippingPoint.ID, changeRec, itemRec, FOBShippingPoint.Value)

        CheckandSave(eachCaseHeight.ID, changeRec, itemRec, RoundDimesionsString(eachCaseHeight.Text))
        CheckandSave(eachCaseWidth.ID, changeRec, itemRec, RoundDimesionsString(eachCaseWidth.Text))
        CheckandSave(eachCaseLength.ID, changeRec, itemRec, RoundDimesionsString(eachCaseLength.Text))
        CheckandSave(eachCaseWeight.ID, changeRec, itemRec, RoundDimesionsString(eachCaseWeight.Text, 4))
        'CheckandSave(eachCaseCube.ID, changeRec, itemRec, eachCaseCube.Value)


        Dim strEachPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
            RoundDimesionsString(eachCaseWidth.Text.Trim()), _
            RoundDimesionsString(eachCaseHeight.Text.Trim()), _
            RoundDimesionsString(eachCaseLength.Text.Trim()), _
            RoundDimesionsString(eachCaseWeight.Text.Trim(), 4))

        CheckandSave(eachCaseCube.ID, changeRec, itemRec, strEachPackCube)

        CheckandSave(innerCaseHeight.ID, changeRec, itemRec, RoundDimesionsString(innerCaseHeight.Text))
        CheckandSave(innerCaseWidth.ID, changeRec, itemRec, RoundDimesionsString(innerCaseWidth.Text))
        CheckandSave(innerCaseLength.ID, changeRec, itemRec, RoundDimesionsString(innerCaseLength.Text))
        CheckandSave(innerCaseWeight.ID, changeRec, itemRec, RoundDimesionsString(innerCaseWeight.Text, 4))
        'CheckandSave(InnerCaseCube.ID, changeRec, itemRec, InnerCaseCube.Value)

        Dim strInnerPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
            RoundDimesionsString(innerCaseWidth.Text.Trim()), _
            RoundDimesionsString(innerCaseHeight.Text.Trim()), _
            RoundDimesionsString(innerCaseLength.Text.Trim()), _
            RoundDimesionsString(innerCaseWeight.Text.Trim(), 4))

        CheckandSave(InnerCaseCube.ID, changeRec, itemRec, strInnerPackCube)

        CheckandSave(masterCaseHeight.ID, changeRec, itemRec, RoundDimesionsString(masterCaseHeight.Text))
        CheckandSave(masterCaseWidth.ID, changeRec, itemRec, RoundDimesionsString(masterCaseWidth.Text))
        CheckandSave(masterCaseLength.ID, changeRec, itemRec, RoundDimesionsString(masterCaseLength.Text))
        If CheckandSave(masterCaseWeight.ID, changeRec, itemRec, RoundDimesionsString(masterCaseWeight.Text, 4)) Then
            If Me.IsPack AndAlso Not isPackParent Then
                updatePackWeight = True
            End If
        End If
        CheckandSave(MasterCaseCube.ID, changeRec, itemRec, MasterCaseCube.Value)

        ' These are handled in Additional COO
        'CheckandSave(CountryOfOrigin.ID, changeRec, itemRec, CountryOfOrigin.Value)
        'CheckandSave(CountryOfOriginName.ID, changeRec, itemRec, CountryOfOriginName.Text)

        CheckandSave(taxUDA.ID, changeRec, itemRec, taxUDA.SelectedValue)
        'item.TaxUDA = taxUDAValue.Value
        CheckandSave(taxValueUDA.ID, changeRec, itemRec, taxValueUDA.Text)
        'item.TaxValueUDA = taxValueUDAValue.Value, "integer", True)

        CheckandSave(Hazardous.ID, changeRec, itemRec, Hazardous.SelectedValue)

        If UCase(Hazardous.SelectedValue) = "Y" Then
            CheckandSave(HazardousFlammable.ID, changeRec, itemRec, HazardousFlammable.SelectedValue)
            CheckandSave(HazardousContainerType.ID, changeRec, itemRec, HazardousContainerType.SelectedValue)
            CheckandSave(HazardousContainerSize.ID, changeRec, itemRec, HazardousContainerSize.Text)
            CheckandSave(HazardousMSDSUOM.ID, changeRec, itemRec, HazardousMSDSUOM.SelectedValue)
            CheckandSave(HazardousManufacturerName.ID, changeRec, itemRec, HazardousManufacturerName.Text)
            CheckandSave(HazardousManufacturerCity.ID, changeRec, itemRec, HazardousManufacturerCity.Text)
            CheckandSave(HazardousManufacturerState.ID, changeRec, itemRec, HazardousManufacturerState.Text)
            CheckandSave(HazardousManufacturerPhone.ID, changeRec, itemRec, HazardousManufacturerPhone.Text)
            CheckandSave(HazardousManufacturerCountry.ID, changeRec, itemRec, HazardousManufacturerCountry.Text)
        Else
            CheckandSave(HazardousFlammable.ID, changeRec, itemRec, "N")
            CheckandSave(HazardousContainerType.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousContainerSize.ID, changeRec, itemRec, Decimal.MinValue)
            CheckandSave(HazardousMSDSUOM.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerName.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerCity.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerState.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerPhone.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerCountry.ID, changeRec, itemRec, String.Empty)
        End If

        'SAVE language values.
        CheckandSave(PLIEnglish.ID, changeRec, itemRec, PLIEnglish.SelectedValue)
        CheckandSave(PLIFrench.ID, changeRec, itemRec, PLIFrench.SelectedValue)
        CheckandSave(PLISpanish.ID, changeRec, itemRec, PLISpanish.SelectedValue)

        'Default TIEnglish to PLI
        If TIEnglish.SelectedValue = "" Then
            TIEnglish.SelectedValue = PLIEnglish.SelectedValue
        End If
        CheckandSave(TIEnglish.ID, changeRec, itemRec, TIEnglish.SelectedValue)
        'Default TIFrench to PLI
        If TIFrench.SelectedValue = "" Then
            TIFrench.SelectedValue = PLIFrench.SelectedValue
        End If
        CheckandSave(TIFrench.ID, changeRec, itemRec, TIFrench.SelectedValue)
        CheckandSave(TISpanish.ID, changeRec, itemRec, TISpanish.SelectedValue)

        'Per Michaels:  Default English Short/Long Description based on PackItemIndicator
        If itemRec.PackItemIndicator.StartsWith("DP") Then
            EnglishShortDescription.Text = "Display Pack"
            EnglishLongDescription.Text = "Display Pack"
        ElseIf itemRec.PackItemIndicator.StartsWith("SB") Then
            EnglishShortDescription.Text = "Sellable Bundle"
            EnglishLongDescription.Text = "Sellable Bundle"
        ElseIf itemRec.PackItemIndicator.StartsWith("D") Then
            EnglishShortDescription.Text = "Displayer"
            EnglishLongDescription.Text = "Displayer"
        End If

        CheckandSave(EnglishLongDescription.ID, changeRec, itemRec, Left(EnglishLongDescription.Text, 100))
        CheckandSave(EnglishShortDescription.ID, changeRec, itemRec, EnglishShortDescription.Text)
        CheckandSave(CustomsDescription.ID, changeRec, itemRec, CustomsDescription.Text)

        'Save CRC values
        CheckandSave(HarmonizedCodeNumber.ID, changeRec, itemRec, HarmonizedCodeNumber.Text)
        CheckandSave(CanadaHarmonizedCodeNumber.ID, changeRec, itemRec, CanadaHarmonizedCodeNumber.Text)
        CheckandSave(DetailInvoiceCustomsDesc0.ID, changeRec, itemRec, DetailInvoiceCustomsDesc0.Text)
        CheckandSave(ComponentMaterialBreakdown0.ID, changeRec, itemRec, ComponentMaterialBreakdown0.Text)

        CheckandSave(FumigationCertificate.ID, changeRec, itemRec, FumigationCertificate.SelectedValue)
        CheckandSave(PhytoTemporaryShipment.ID, changeRec, itemRec, PhytoTemporaryShipment.SelectedValue)


        ' ************************ ADDITIONAL COO SAVE BEGIN ************************
        ' SAVE Additional Countries of Origin
        ' Set up to save Additional COO Names
        ' Set up ChangeRec for Item Master Common field changes
        changeRec.ItemID = hid.Value
        changeRec.UPC = ""
        changeRec.EffectiveDate = ""
        changeRec.ChangedByID = userID

        Dim addCOOCount As Integer = additionalCOOCount.Value
        Dim IMaddCOOs As Integer = itemRec.AdditionalCOORecs.Count
        Dim objCountry As CountryRecord
        Dim controlFound As Boolean = True, ctl As String, ctlName As String
        Dim counter As Integer = 1
        Dim strNewPriName As String = String.Empty
        Dim strNewPriCode As String = String.Empty

        Dim sbAddCOOCode As StringBuilder = New StringBuilder
        Dim sbAddCOOName As StringBuilder = New StringBuilder
        Dim strTemp As String = String.Empty
        Dim strNewPri As String = String.Empty
        Dim ChangeExists As Boolean

        ' For Now Existing COOs are Read Only but scan for Primary Change
        For counter = 1 To addCOOCount      ' each control on the page
            'For counter = IMaddCOOs + 1 To addCOOCount      ' each control on the page
            ctlName = cADDCOONAME & counter.ToString
            ctl = Trim(Request.Form(ctlName))
            If ctl <> "" Then   ' is there a country Name?

                'Lookup code for country. If Found Save as normal fields.  Else save the bad country in the name and a space in the code
                objCountry = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(ctl)
                If Not objCountry Is Nothing AndAlso objCountry.CountryName <> String.Empty AndAlso objCountry.CountryCode <> String.Empty Then
                    ' If Control is past the existing ones then save these
                    If counter > IMaddCOOs Then
                        sbAddCOOName.Append(objCountry.CountryName & cPIPE)
                        sbAddCOOCode.Append(objCountry.CountryCode & cPIPE)
                    End If
                    ' since we have a valid country and lookup, check to see if its marked as new Primary
                    ctlName = cNEWPRIMARY & counter.ToString
                    ctl = Trim(Request.Form(ctlName))
                    If ctl.ToLower = "on" Then
                        strNewPriName = objCountry.CountryName
                        strNewPriCode = objCountry.CountryCode
                    End If
                Else    ' Bad country look up. special save
                    If counter > IMaddCOOs Then
                        sbAddCOOName.Append(ctl & cPIPE)
                        sbAddCOOCode.Append(" " & cPIPE)
                    End If
                End If
            End If
        Next

        ' Now see if we need to save any new AddCOOs
        Dim origChangeRec As Models.IMChangeRecord
        Dim strOrigNewPriName As String = itemRec.CountryOfOriginName
        Dim strOrigNewPriCode As String = itemRec.CountryOfOrigin
        Dim strOrig As String = String.Empty
        strOrig = ""

        ' Save COO Names
        origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cADDCOONAME, "", "", "", 0)
        If origChangeRec.ItemID > 0 Then
            changeRec.FieldValue = origChangeRec.FieldValue
            ChangeExists = True
        Else
            changeRec.FieldValue = ""
            ChangeExists = False
        End If
        strTemp = sbAddCOOName.ToString
        If strTemp.Length > 0 Then strTemp = Left(strTemp, strTemp.Length - 1) ' Get rid of trailing cPIPE
        changeRec.FieldName = cADDCOONAME
        changeRec.Counter = 0
        FormHelper.CheckandSave(strTemp, strOrig, changeRec, ChangeExists)

        ' Save COO Codes
        origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cADDCOO, "", "", "", 0)
        If origChangeRec.ItemID > 0 Then
            changeRec.FieldValue = origChangeRec.FieldValue
            ChangeExists = True
        Else
            changeRec.FieldValue = ""
            ChangeExists = False
        End If
        strTemp = sbAddCOOCode.ToString
        If strTemp.Length > 0 Then strTemp = Left(strTemp, strTemp.Length - 1) ' Get rid of trailing cPIPE
        changeRec.FieldName = cADDCOO
        changeRec.Counter = 0
        FormHelper.CheckandSave(strTemp, strOrig, changeRec, ChangeExists)

        ' Save New Primary indicators
        origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cNEWPRIMARY, "", "", "", 0)
        If origChangeRec.ItemID > 0 Then
            changeRec.FieldValue = origChangeRec.FieldValue
            ChangeExists = True
        Else
            changeRec.FieldValue = ""
            ChangeExists = False
        End If
        changeRec.FieldName = cNEWPRIMARY
        changeRec.Counter = 0
        FormHelper.CheckandSave(strNewPriName, strOrig, changeRec, ChangeExists)

        origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cNEWPRIMARYCODE, "", "", "", 0)
        If origChangeRec.ItemID > 0 Then
            changeRec.FieldValue = origChangeRec.FieldValue
            ChangeExists = True
        Else
            changeRec.FieldValue = ""
            ChangeExists = False
        End If
        changeRec.FieldName = cNEWPRIMARYCODE
        changeRec.Counter = 0
        FormHelper.CheckandSave(strNewPriCode, strOrig, changeRec, ChangeExists)
        ' ************************ ADDITIONAL COO SAVE END ************************

        ' Now See if we need to Update Pack Cost
        If updatePackCost Or updatePackWeight Then
            ItemMaintHelper.CalculateDPBatchParent(BatchID, updatePackCost, updatePackWeight)
        End If

        '' validation
        Dim vrBatch As ValidationRecord
        Dim valRecord As ValidationRecord

        If Not ValidationHelper.SkipBatchValidation(batchDetail.WorkflowStageType) Then
            vrBatch = ValidationHelper.ValidateItemMaintBatch(batchDetail, ReadOnlyForm)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
        End If

        If Not ValidationHelper.SkipValidation(batchDetail.WorkflowStageType) Then
            RowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(HeaderItemID)
            valRecord = ValidationHelper.ValidateItemMaintItem(itemRec, RowChanges, batchDetail, ReadOnlyForm)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecord, userID)
        End If
        vrBatch = Nothing
        valRecord = Nothing

        Return HeaderItemID

    End Function

#Region "Private Brand Label changes"
    Protected Sub PrivateBrand_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles PrivateBrandLabel.SelectedIndexChanged

        If PrivateBrandLabel.SelectedValue = "" Or PrivateBrandLabel.SelectedValue = "12" Then
            InnerGTIN.RenderReadOnly = False
            CaseGTIN.RenderReadOnly = False
        Else
            InnerGTIN.RenderReadOnly = True
            CaseGTIN.RenderReadOnly = True
        End If
    End Sub
#End Region

End Class
