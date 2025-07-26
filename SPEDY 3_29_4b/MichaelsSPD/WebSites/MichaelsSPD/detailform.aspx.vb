Imports System
Imports System.Diagnostics
Imports System.Data
Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Generic
Imports ItemHelper

Partial Class detailform
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler

    Private _validFlag As ItemValidFlag = ItemValidFlag.Unknown
    Private _validWasUnknown As Boolean = False

    Private _refreshGrid As Boolean = False
    Private _closeForm As Boolean = False

    Private _callbackArg As String = ""

    ' FJL Jan 2010
    Private WorkflowStageID As Integer = 0

    Public Const CALLBACK_SEP As String = "{{|}}"
    Private _readOnlyForm As Boolean = False

    Public Property ReadOnlyForm() As Boolean
        Get
            Return _readOnlyForm
        End Get
        Set(ByVal value As Boolean)
            _readOnlyForm = value
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

    Public ReadOnly Property ItemID() As String
        Get
            Return recordID.Value
        End Get
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsCallback Then
            ' check security
            If Not SecurityCheck() Then
                Response.Redirect("closeform.aspx?r=1")
            End If

            'TODO: ADD THIS SECURITY
            'If Not UserManager.CanUserAddEdit() Then
            '    Response.Redirect("closeform.aspx")
            'End If

            Dim headerID As Long = 0
            Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()

            ' **********
            ' * header *
            ' **********

            Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord = Nothing

            If Not IsPostBack Then
                ' load record if update mode
                If Request("hid") <> "" AndAlso IsNumeric(Request("hid")) Then
                    hid.Value = Request("hid")
                End If ' Request("hid")

                If Request("r") = "1" Then
                    RefreshGrid = True
                End If
                'LP 
                If Request("close") = "1" Then
                    CloseForm = True
                End If
                'LP
            End If ' IsPostBack

            If hid.Value = "" Then
                Response.Redirect("closeform.aspx")
            End If
            headerID = DataHelper.SmartValues(hid.Value, "long", False)


            itemHeader = objMichaels.GetItemHeaderRecord(headerID)
            Dim isPack As Boolean = False

            If (Not itemHeader Is Nothing) AndAlso itemHeader.ID > 0 Then

                ' VALIDATE USER
                ValidateUser(itemHeader.BatchID, itemHeader.BatchStageType)
                If NoUserAccess Then Response.Redirect("closeform.aspx")

                ' Vendor Check
                If Not VendorCheck(itemHeader.USVendorNum, itemHeader.CanadianVendorNum) Then
                    Response.Redirect("closeform.aspx?r=1")
                End If

                isPack = NovaLibra.Coral.Data.Michaels.ItemDetail.IsPack(itemHeader.ID)

                hdnStageType.Value = itemHeader.BatchStageType
            Else
                Response.Redirect("closeform.aspx")
            End If ' Not itemHeader Is Nothing

            'NAK 12/4/2012:  Per Michaels, these fields should be editable to DBC/QA
            If itemHeader.BatchStageType <> Models.WorkflowStageType.Tax And itemHeader.BatchStageType <> Models.WorkflowStageType.DBC Then
                taxUDA.RenderReadOnly = True
                taxValueUDA.RenderReadOnly = True
            End If

            ' **********
            ' * detail *
            ' **********

            ' id
            Dim id As Integer
            If Not Page.IsPostBack Then
                id = DataHelper.SmartValues(Request("id"), "long")
            Else
                id = DataHelper.SmartValues(recordID.Value, "long")
            End If

            ' setup page


            ' init delete link
            DeleteLink.Visible = False
            DeleteLink.Attributes.Add("onclick", "return confirmDelete('Are you sure you want to Delete this Item?');")

            ' callback
            Dim cbReference As String
            cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", _
                "ReceiveServerData", "context")
            Dim callbackScript As String = ""
            callbackScript &= "function CallServer(arg, context)" & _
                "{" & cbReference & "; }"
            Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), _
                "CallServer", callbackScript, True)


            CheckForStartupScripts()

            ' init controls
            packItemIndicator.Attributes.Add("onchange", "packItemIndicatorChanged();")
            USCost.Attributes.Add("onchange", "USCostChanged();")
            canadaCost.Attributes.Add("onchange", "canadaCostChanged();")

            pblApplyAll.Attributes.Add("onclick", "VerifyUpdatePBLforBatch();")

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
            baseRetail.Attributes.Add("onchange", "baseRetailChanged('baseretail');")
            alaskaRetail.Attributes.Add("onchange", "alaskaRetailChanged();")
            canadaRetail.Attributes.Add("onchange", "canadaRetailChanged();")

            vendorUPC.Attributes.Add("onchange", "vendorUPCChanged();")

            taxWizardLink.Attributes.Add("onclick", "openTaxWizard('" & id & "'); return false;")
            taxUDA.Attributes.Add("onchange", "taxUDAChanged();")
            taxValueUDA.Attributes.Add("onchange", "taxValueUDAChanged();")

            hazardous.Attributes.Add("onchange", "hazardousChanged();")

            ' Country of Origin
            'Me.countryOfOriginName.Attributes.Add("onchange", "countryOfOriginChanged();")

            ' New LIKE Item Approval
            Me.likeItemSKU.Attributes.Add("onchange", "likeItemSKUChanged();")
            'LP 03 15 2009
            'Me.AnnualRegularUnitForecastEdit.Attributes.Add("onchange", "CalculateUnitStoreMonth();")
            Me.AnnualRegularUnitForecastEdit.Attributes.Add("onblur", "CalculateUnitStoreMonth();")
            'Me.LikeItemUnitStoreMonthEdit.Attributes.Add("onchange", "CalculateRegularForecast();")
            Me.LikeItemUnitStoreMonthEdit.Attributes.Add("onblur", "CalculateRegularForecast();")
            'the following fields only to allow integers to be typed in
            Me.POGMaxQty.Attributes.Add("onkeydown", "return SetInteger(event);")
            Me.POGSetupPerStore.Attributes.Add("onkeydown", "return SetInteger(event);")
            Me.POGMinQty.Attributes.Add("onkeydown", "return SetInteger(event);")
            Me.AnnualRegularUnitForecastEdit.Attributes.Add("onkeydown", "return SetInteger(event);")
            Me.LikeItemRegularUnit.Attributes.Add("onkeydown", "return SetInteger(event);")
            Me.facings.Attributes.Add("onkeydown", "return SetInteger(event);")
            Me.baseRetail.Attributes.Add("onblur", "CalculateTotalRetail();")
            'LP
            'Lp change order 14, i want to sync hidden fields with text box values- just in case i keep hidden fields
            Me.testRetailEdit.Attributes.Add("onchange", "SetHiddenFieldValue('testRetail');")
            Me.centralRetailEdit.Attributes.Add("onchange", "SetHiddenFieldValue('centralRetail');")
            Me.zeroNineRetailEdit.Attributes.Add("onchange", "SetHiddenFieldValue('zeroNineRetail');")
            Me.californiaRetailEdit.Attributes.Add("onchange", "SetHiddenFieldValue('californiaRetail');")
            Me.villageCraftRetailEdit.Attributes.Add("onchange", "SetHiddenFieldValue('villageCraftRetail');")
            Me.Retail9Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail9');")
            Me.Retail10Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail10');")
            Me.Retail11Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail11');")
            Me.Retail12Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail12');")
            Me.Retail13Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail13');")
            Me.RDQuebecEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDQuebec');")
            Me.RDPuertoRicoEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDPuertoRico');")

            'Set the dirty js
            'Me.baseRetail.Attributes.Add("onKeyPress", "setIsDirty(1);")
            AddIsDirty(Page)

            If Not Page.IsPostBack Then
                ' init

                Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
                Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(itemHeader.BatchID)
                objMichaelsBatch = Nothing

                If batchDetail.ID > 0 Then
                    'Set the global workflow id
                    WorkflowStageID = batchDetail.WorkflowStageID
                    hdnWorkflowStageID.Value = batchDetail.WorkflowStageID
                End If

                Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
                itemFL = objMichaels.GetItemFieldLocking(AppHelper.GetUserID(), AppHelper.GetVendorID, WorkflowStageID)

                ' load list values
                Dim lvgs As ListValueGroups = FormHelper.LoadListValues("YESNO,ADDCHANGE,PACKITEMIND,HYBRIDTYPE,HYBRIDSOURCEDC,PREPRICEDUDA,TAXUDA,HAZCONTAINERTYPE,HAZMSDSUOM,RMS_PBL,STOCKSTRAT,STOCKSTRATBASIC,STOCKSTRATSEASONAL,STOCKSTRATALL")
                FormHelper.LoadListFromListValues(addChange, lvgs.GetListValueGroup("ADDCHANGE"), True)
                FormHelper.LoadListFromListValues(packItemIndicator, lvgs.GetListValueGroup("PACKITEMIND"), True)
                'FormHelper.LoadListFromListValues(hybridType, lvgs.GetListValueGroup("HYBRIDTYPE"), True)
                'FormHelper.LoadListFromListValues(hybridSourceDC, lvgs.GetListValueGroup("HYBRIDSOURCEDC"), True)
                FormHelper.LoadListFromListValues(prePriced, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(prePricedUDA, lvgs.GetListValueGroup("PREPRICEDUDA"), True)
                FormHelper.LoadListFromListValues(taxUDA, lvgs.GetListValueGroup("TAXUDA"), True, "", "", 20)
                FormHelper.LoadListFromListValues(hazardous, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(hazardousFlammable, lvgs.GetListValueGroup("YESNO"), True)
                FormHelper.LoadListFromListValues(hazardousContainerType, lvgs.GetListValueGroup("HAZCONTAINERTYPE"), True)
                FormHelper.LoadListFromListValues(hazardousMSDSUOM, lvgs.GetListValueGroup("HAZMSDSUOM"), True)
                FormHelper.LoadListFromListValues(PrivateBrandLabel, lvgs.GetListValueGroup("RMS_PBL"), True)
                If itemHeader.BatchStageType = WorkflowStageType.Completed Then
                    FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATALL"), True)
                ElseIf itemHeader.ItemTypeAttribute = "S" Then
                    FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATSEASONAL"), True)
                ElseIf itemHeader.ItemTypeAttribute <> "S" And itemHeader.ItemTypeAttribute <> "" Then
                    FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATBASIC"), True)
                Else
                    FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRAT"), True)
                End If


                'InitStockStratHelper
                InitStockStratHelper()

                ' list items
                If itemHeader.StoreTotal <> Integer.MinValue Then storeTotal.Text = itemHeader.StoreTotal.ToString
                Select Case itemHeader.CalculateOptions
                    Case Integer.MinValue, 0
                        'no calculations
                        Me.AnnualRegularUnitForecastEdit.ReadOnly = True
                        Me.LikeItemUnitStoreMonthEdit.ReadOnly = True
                        Me.AnnualRegularUnitForecastEdit.Attributes.Remove("onblur")
                        Me.LikeItemUnitStoreMonthEdit.Attributes.Remove("onblur")
                        tb_CalcOptions.Text = Str(0)
                    Case 1
                        'provide forecast
                        Me.AnnualRegularUnitForecastEdit.ReadOnly = False
                        Me.AnnualRegularUnitForecastEdit.BackColor = Drawing.Color.White
                        Me.LikeItemUnitStoreMonthEdit.ReadOnly = True
                        Me.LikeItemUnitStoreMonthEdit.Attributes.Remove("onblur")
                        tb_CalcOptions.Text = Str(itemHeader.CalculateOptions)
                    Case 2
                        Me.AnnualRegularUnitForecastEdit.ReadOnly = True
                        Me.AnnualRegularUnitForecastEdit.Attributes.Remove("onblur")
                        Me.LikeItemUnitStoreMonthEdit.ReadOnly = False
                        Me.LikeItemUnitStoreMonthEdit.BackColor = Drawing.Color.White
                        tb_CalcOptions.Text = Str(itemHeader.CalculateOptions)
                End Select
                If id > 0 Then
                    Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord = objMichaels.GetRecord(id)
                    If objRecord.ID > 0 Then

                        ' Check to see if this is an existing Item being added to a pack.  If so, set readonly
                        If objRecord.ValidExistingSKU Then
                            ReadOnlyForm = True
                        End If

                        ' setup header
                        Page.Title = "Edit Item"
                        lblHeading.Text = "Edit Item"
                        lblSubHeading.Text = "Using the fields below, edit this item entry."

                        ' delete link
                        If UserCanEdit Then
                            DeleteLink.Visible = True
                        End If

                        ' setup form
                        recordID.Value = objRecord.ID.ToString()
                        itemHeaderID.Value = objRecord.ItemHeaderID
                        ItemTypeAttribute.Value = itemHeader.ItemTypeAttribute
                        addChange.SelectedValue = objRecord.AddChange
                        packItemIndicator.SelectedValue = objRecord.PackItemIndicator
                        michaelsSKU.Text = objRecord.MichaelsSKU
                        vendorUPC.Text = objRecord.VendorUPC
                        QuoteReferenceNumber.Text = objRecord.QuoteReferenceNumber
                        If ConfigurationManager.AppSettings("HideDomesticQRN") = True Then
                            Me.QuoteReferenceNumber.Visible = False
                            Me.QuoteRefNoFL.Visible = False
                        End If

                        ' additional UPCs
                        Dim UPC As String, UPCValues As String = String.Empty
                        If Not objRecord.AdditionalUPCRecord Is Nothing AndAlso objRecord.AdditionalUPCRecord.AdditionalUPCs.Count > 0 Then
                            Dim UPCString As String = String.Empty
                            For i As Integer = 0 To objRecord.AdditionalUPCRecord.AdditionalUPCs.Count - 1
                                If UPCString <> String.Empty Then UPCString += "<br />"
                                UPC = objRecord.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString().Replace("""", "&quot;")
                                If UPCValues <> String.Empty Then UPCValues += ","
                                UPCValues += UPC
                                UPCString += "<input type=""text"" id=""additionalUPC" & (i + 1) & """ maxlength=""20"" value=""" & UPC & """ onchange=""additionalUPCChanged('" & (i + 1) & "');"" /><sup>" & (i + 1) & "</sup>"
                            Next
                            additionalUPCs.Text = UPCString
                            additionalUPCCount.Value = objRecord.AdditionalUPCRecord.AdditionalUPCs.Count.ToString()
                            additionalUPCValues.Value = UPCValues
                        End If

                        'PMO200141 GTIN14 Enhancements changes
                        vendorInnerGTIN.Text = objRecord.VendorInnerGTIN
                        vendorCaseGTIN.Text = objRecord.VendorCaseGTIN

                        If objRecord.ClassNum <> Integer.MinValue Then classNum.Text = objRecord.ClassNum.ToString()
                        If objRecord.SubClassNum <> Integer.MinValue Then subClassNum.Text = objRecord.SubClassNum.ToString()
                        vendorStyleNum.Text = objRecord.VendorStyleNum
                        itemDesc.Text = objRecord.ItemDesc
                        PrivateBrandLabel.SelectedValue = objRecord.PrivateBrandLabel
                        'hybridType.SelectedValue = objRecord.HybridType
                        'hybridSourceDC.SelectedValue = objRecord.HybridSourceDC
                        'If objRecord.HybridLeadTime <> Integer.MinValue Then hybridLeadTime.Text = objRecord.HybridLeadTime
                        'If objRecord.HybridConversionDate <> Date.MinValue Then hybridConversionDateEdit.Text = objRecord.HybridConversionDate.ToString("M/d/yyyy")
                        'hybridConversionDate.Value = hybridConversionDateEdit.Text
                        If StockingStrategyCode.Items.Contains(StockingStrategyCode.Items.FindByValue(objRecord.StockingStrategyCode)) Then StockingStrategyCode.SelectedValue = objRecord.StockingStrategyCode

                        If isPack AndAlso (objRecord.PackItemIndicator = "C" Or objRecord.QtyInPack > 0 Or objRecord.ValidExistingSKU) Then
                            If objRecord.QtyInPack <> Integer.MinValue Then qtyInPack.Text = objRecord.QtyInPack
                        Else
                            qtyInPackRow.Style.Add("display", "none")
                        End If
                        If objRecord.EachesMasterCase <> Integer.MinValue Then eachesMasterCase.Text = objRecord.EachesMasterCase
                        If objRecord.EachesInnerPack <> Integer.MinValue Then eachesInnerPack.Text = objRecord.EachesInnerPack
                        prePriced.SelectedValue = objRecord.PrePriced
                        prePricedUDA.SelectedValue = objRecord.PrePricedUDA

                        If objRecord.USCost <> Decimal.MinValue Then USCost.Text = DataHelper.SmartValues(objRecord.USCost, "formatnumber4")
                        If objRecord.TotalUSCost <> Decimal.MinValue Then
                            totalUSCost.Value = DataHelper.SmartValues(objRecord.TotalUSCost, "formatnumber4")
                            totalUSCostEdit.Text = totalUSCost.Value
                        End If
                        If objRecord.CanadaCost <> Decimal.MinValue Then canadaCost.Text = DataHelper.SmartValues(objRecord.CanadaCost, "formatnumber4")
                        If objRecord.TotalCanadaCost <> Decimal.MinValue Then
                            totalCanadaCost.Value = DataHelper.SmartValues(objRecord.TotalCanadaCost, "formatnumber4")
                            totalCanadaCostEdit.Text = totalCanadaCost.Value
                        End If

                        If objRecord.BaseRetail <> Decimal.MinValue Then baseRetail.Text = DataHelper.SmartValues(objRecord.BaseRetail, "formatnumber")
                        If objRecord.CentralRetail <> Decimal.MinValue Then centralRetailEdit.Text = DataHelper.SmartValues(objRecord.CentralRetail, "formatnumber")
                        centralRetail.Value = centralRetailEdit.Text
                        If objRecord.TestRetail <> Decimal.MinValue Then testRetailEdit.Text = DataHelper.SmartValues(objRecord.TestRetail, "formatnumber")
                        testRetail.Value = testRetailEdit.Text
                        If objRecord.AlaskaRetail <> Decimal.MinValue Then alaskaRetail.Text = DataHelper.SmartValues(objRecord.AlaskaRetail, "formatnumber")
                        If objRecord.CanadaRetail <> Decimal.MinValue Then canadaRetail.Text = DataHelper.SmartValues(objRecord.CanadaRetail, "formatnumber")
                        If objRecord.ZeroNineRetail <> Decimal.MinValue Then zeroNineRetailEdit.Text = DataHelper.SmartValues(objRecord.ZeroNineRetail, "formatnumber")
                        zeroNineRetail.Value = zeroNineRetailEdit.Text
                        If objRecord.CaliforniaRetail <> Decimal.MinValue Then californiaRetailEdit.Text = DataHelper.SmartValues(objRecord.CaliforniaRetail, "formatnumber")
                        californiaRetail.Value = californiaRetailEdit.Text
                        If objRecord.VillageCraftRetail <> Decimal.MinValue Then villageCraftRetailEdit.Text = DataHelper.SmartValues(objRecord.VillageCraftRetail, "formatnumber")
                        villageCraftRetail.Value = villageCraftRetailEdit.Text
                        If objRecord.Retail9 <> Decimal.MinValue Then Retail9Edit.Text = DataHelper.SmartValues(objRecord.Retail9, "formatnumber")
                        Retail9.Value = Retail9Edit.Text
                        If objRecord.Retail10 <> Decimal.MinValue Then Retail10Edit.Text = DataHelper.SmartValues(objRecord.Retail10, "formatnumber")
                        Retail10.Value = Retail10Edit.Text
                        If objRecord.Retail11 <> Decimal.MinValue Then Retail11Edit.Text = DataHelper.SmartValues(objRecord.Retail11, "formatnumber")
                        Retail11.Value = Retail11Edit.Text
                        If objRecord.Retail12 <> Decimal.MinValue Then Retail12Edit.Text = DataHelper.SmartValues(objRecord.Retail12, "formatnumber")
                        Retail12.Value = Retail12Edit.Text
                        If objRecord.Retail13 <> Decimal.MinValue Then Retail13Edit.Text = DataHelper.SmartValues(objRecord.Retail13, "formatnumber")
                        Retail13.Value = Retail13Edit.Text

                        'Set Quebec Retail
                        If objRecord.RDQuebec <> Decimal.MinValue Then
                            RDQuebecEdit.Text = DataHelper.SmartValues(objRecord.RDQuebec, "formatnumber")
                        End If
                        RDQuebec.Value = RDQuebecEdit.Text
                        'Set Puerto Rico Retail
                        If objRecord.RDPuertoRico <> Decimal.MinValue Then
                            RDPuertoRicoEdit.Text = DataHelper.SmartValues(objRecord.RDPuertoRico, "formatnumber")
                        End If
                        RDPuertoRico.Value = RDPuertoRicoEdit.Text

                        If objRecord.POGSetupPerStore <> Decimal.MinValue Then POGSetupPerStore.Text = DataHelper.SmartValues(objRecord.POGSetupPerStore, "integer") '"formatnumber"
                        If objRecord.POGMaxQty <> Decimal.MinValue Then POGMaxQty.Text = DataHelper.SmartValues(objRecord.POGMaxQty, "integer") 'lp change to integer
                        'If objRecord.ProjectedUnitSales <> Decimal.MinValue Then projectedUnitSales.Text = DataHelper.SmartValues(objRecord.ProjectedUnitSales, "formatnumber")

                        If objRecord.EachCaseHeight <> Decimal.MinValue Then eachCaseHeight.Text = DataHelper.SmartValues(objRecord.EachCaseHeight, "formatnumber4")
                        If objRecord.EachCaseWidth <> Decimal.MinValue Then eachCaseWidth.Text = DataHelper.SmartValues(objRecord.EachCaseWidth, "formatnumber4")
                        If objRecord.EachCaseLength <> Decimal.MinValue Then eachCaseLength.Text = DataHelper.SmartValues(objRecord.EachCaseLength, "formatnumber4")
                        If objRecord.EachCaseWeight <> Decimal.MinValue Then eachCaseWeight.Text = DataHelper.SmartValues(objRecord.EachCaseWeight, "formatnumber4")
                        If objRecord.EachCasePackCube <> Decimal.MinValue Then
                            eachCasePackCube.Value = DataHelper.SmartValues(objRecord.EachCasePackCube, "formatnumber4")
                            eachCasePackCubeEdit.Text = DataHelper.SmartValues(objRecord.EachCasePackCube, "formatnumber4")
                        End If

                        If objRecord.InnerCaseHeight <> Decimal.MinValue Then innerCaseHeight.Text = DataHelper.SmartValues(objRecord.InnerCaseHeight, "formatnumber4")
                        If objRecord.InnerCaseWidth <> Decimal.MinValue Then innerCaseWidth.Text = DataHelper.SmartValues(objRecord.InnerCaseWidth, "formatnumber4")
                        If objRecord.InnerCaseLength <> Decimal.MinValue Then innerCaseLength.Text = DataHelper.SmartValues(objRecord.InnerCaseLength, "formatnumber4")
                        If objRecord.InnerCaseWeight <> Decimal.MinValue Then innerCaseWeight.Text = DataHelper.SmartValues(objRecord.InnerCaseWeight, "formatnumber4")
                        If objRecord.InnerCasePackCube <> Decimal.MinValue Then
                            innerCasePackCube.Value = DataHelper.SmartValues(objRecord.InnerCasePackCube, "formatnumber4")
                            innerCasePackCubeEdit.Text = DataHelper.SmartValues(objRecord.InnerCasePackCube, "formatnumber4")
                        End If

                        If objRecord.MasterCaseHeight <> Decimal.MinValue Then masterCaseHeight.Text = DataHelper.SmartValues(objRecord.MasterCaseHeight, "formatnumber4")
                        If objRecord.MasterCaseWidth <> Decimal.MinValue Then masterCaseWidth.Text = DataHelper.SmartValues(objRecord.MasterCaseWidth, "formatnumber4")
                        If objRecord.MasterCaseLength <> Decimal.MinValue Then masterCaseLength.Text = DataHelper.SmartValues(objRecord.MasterCaseLength, "formatnumber4")
                        If objRecord.MasterCaseWeight <> Decimal.MinValue Then masterCaseWeight.Text = DataHelper.SmartValues(objRecord.MasterCaseWeight, "formatnumber4")
                        If objRecord.MasterCasePackCube <> Decimal.MinValue Then
                            masterCasePackCube.Value = DataHelper.SmartValues(objRecord.MasterCasePackCube, "formatnumber4")
                            masterCasePackCubeEdit.Text = DataHelper.SmartValues(objRecord.MasterCasePackCube, "formatnumber4")
                        End If

                        countryOfOrigin.Value = objRecord.CountryOfOrigin
                        countryOfOriginName.Text = objRecord.CountryOfOriginName

                        ' tax wizard
                        taxWizard.BorderWidth = 0
                        If objRecord.TaxWizard Then
                            taxWizard.ImageUrl = "images/checkbox_true.gif"
                            taxWizardComplete.Value = "1"
                        Else
                            taxWizard.ImageUrl = "images/checkbox_false.gif"
                            taxWizardComplete.Value = "0"
                        End If

                        taxUDA.SelectedValue = objRecord.TaxUDA
                        If taxUDA.SelectedIndex > 0 Then
                            'taxUDALabel.Text = taxUDA.SelectedItem.Text
                            taxUDAValue.Value = taxUDA.SelectedValue
                        End If
                        If objRecord.TaxValueUDA <> Integer.MinValue Then
                            taxValueUDA.Text = objRecord.TaxValueUDA
                            'taxValueUDALabel.Text = taxValueUDA.Text
                            taxValueUDAValue.Value = taxValueUDA.Text
                        End If

                        hazardous.SelectedValue = objRecord.Hazardous
                        hazardousFlammable.SelectedValue = objRecord.HazardousFlammable
                        hazardousContainerType.SelectedValue = objRecord.HazardousContainerType
                        If objRecord.HazardousContainerSize <> Decimal.MinValue Then hazardousContainerSize.Text = FormatNumber(objRecord.HazardousContainerSize, -1, 0, 0, -1)
                        hazardousMSDSUOM.SelectedValue = objRecord.HazardousMSDSUOM
                        hazardousManufacturerName.Text = objRecord.HazardousManufacturerName
                        hazardousManufacturerCity.Text = objRecord.HazardousManufacturerCity
                        hazardousManufacturerState.Text = objRecord.HazardousManufacturerState
                        hazardousManufacturerPhone.Text = objRecord.HazardousManufacturerPhone
                        hazardousManufacturerCountry.Text = objRecord.HazardousManufacturerCountry

                        'Set Multilingual information
                        PLIEnglish.SelectedValue = objRecord.PLIEnglish
                        TIEnglish.SelectedValue = objRecord.TIEnglish
                        EnglishShortDescription.Text = objRecord.EnglishShortDescription
                        EnglishLongDescription.Text = objRecord.EnglishLongDescription

                        PLIFrench.SelectedValue = objRecord.PLIFrench
                        TIFrench.SelectedValue = objRecord.TIFrench
                        FrenchShortDescription.Text = objRecord.FrenchShortDescription
                        FrenchLongDescription.Text = objRecord.FrenchLongDescription

                        PLISpanish.SelectedValue = objRecord.PLISpanish
                        TISpanish.SelectedValue = "N"
                        SpanishShortDescription.Text = objRecord.SpanishShortDescription
                        SpanishLongDescription.Text = objRecord.SpanishLongDescription

                        ExemptEndDateFrench.Text = objRecord.ExemptEndDateFrench

                        'Set CRC Information
                        HarmonizedCodeNumber.Text = objRecord.HarmonizedCodeNumber
                        CanadaHarmonizedCodeNumber.Text = objRecord.CanadaHarmonizedCodeNumber
                        DetailInvoiceCustomsDesc.Text = objRecord.DetailInvoiceCustomsDesc
                        ComponentMaterialBreakdown.Text = objRecord.ComponentMaterialBreakdown

                        PhytoSanitaryCertificate.SelectedValue = objRecord.PhytoSanitaryCertificate
                        PhytoTemporaryShipment.SelectedValue = objRecord.PhytoTemporaryShipment

                        'Per client requirements, Default English Descriptions for Pack items
                        If Not String.IsNullOrEmpty(objRecord.PackItemIndicator) Then
                            Dim englishDesc As String = ""
                            If objRecord.PackItemIndicator.StartsWith("DP") Then
                                englishDesc = "Display Pack"
                            ElseIf objRecord.PackItemIndicator.StartsWith("SB") Then
                                englishDesc = "Sellable Bundle"
                            ElseIf objRecord.PackItemIndicator.StartsWith("D") Then
                                englishDesc = "Displayer"
                            End If
                            If englishDesc.Length > 0 Then
                                EnglishShortDescription.Text = englishDesc
                                EnglishLongDescription.Text = englishDesc
                            End If
                        End If

                        'Set default value on English - Translation Indicator (really only needed if Item exists, but no TI records in DB)
                        If String.IsNullOrEmpty(objRecord.TIEnglish) Then
                            TIEnglish.SelectedValue = "Y"
                        End If

                        CustomsDescription.Text = objRecord.CustomsDescription

                        ' New Item Approval
                        likeItemSKU.Text = objRecord.LikeItemSKU
                        likeItemDescriptionEdit.Text = objRecord.LikeItemDescription
                        likeItemDescription.Value = likeItemDescriptionEdit.Text
                        If objRecord.LikeItemRetail <> Decimal.MinValue Then
                            likeItemRetailEdit.Text = DataHelper.SmartValues(objRecord.LikeItemRetail, "formatnumber")
                            likeItemRetail.Value = likeItemRetailEdit.Text
                        End If
                        'If objRecord.LikeItemRegularUnit <> Decimal.MinValue Then LikeItemRegularUnit.Text = DataHelper.SmartValues(objRecord.LikeItemRegularUnit, "formatnumber0")
                        Dim strValue As String
                        Dim decValue As Decimal
                        strValue = String.Empty
                        'round Like items Regular Units to whole number
                        decValue = DataHelper.SmartValues(objRecord.LikeItemRegularUnit, "decimal", True, Decimal.MinValue, 0)
                        If decValue <> Decimal.MinValue Then
                            'decValue = decValue * 100
                            strValue = Str(decValue)
                        End If
                        LikeItemRegularUnit.Text = strValue.Trim()
                        'If objRecord.LikeItemSales <> Decimal.MinValue Then likeItemSales.Text = DataHelper.SmartValues(objRecord.LikeItemSales, "integer")
                        'need to change formatting here- to do LP 03 15 09
                        If objRecord.LikeItemUnitStoreMonth <> Decimal.MinValue Then LikeItemUnitStoreMonthEdit.Text = DataHelper.SmartValues(objRecord.LikeItemUnitStoreMonth, "decimal", True, Decimal.MinValue, 2)
                        LikeItemUnitStoreMonth.Value = LikeItemUnitStoreMonthEdit.Text
                        'format here
                        If objRecord.AnnualRegularUnitForecast <> Decimal.MinValue Then AnnualRegularUnitForecastEdit.Text = DataHelper.SmartValues(objRecord.AnnualRegularUnitForecast, "decimal", True, Decimal.MinValue, 0)
                        AnnualRegularUnitForecast.Value = AnnualRegularUnitForecastEdit.Text
                        If objRecord.AnnualRegRetailSales <> Decimal.MinValue Then AnnualRegRetailSalesEdit.Text = DataHelper.SmartValues(objRecord.AnnualRegRetailSales, "formatnumber", True, Decimal.MinValue, 2)
                        AnnualRegRetailSales.Value = AnnualRegRetailSalesEdit.Text
                        'lp new info below, must have for calcualtions
                        objRecord.CalculateOptions = itemHeader.CalculateOptions


                        If objRecord.Facings <> Decimal.MinValue Then facings.Text = DataHelper.SmartValues(objRecord.Facings, "integer")
                        If objRecord.POGMinQty <> Decimal.MinValue Then POGMinQty.Text = DataHelper.SmartValues(objRecord.POGMinQty, "integer")
                        'lp 031309
                        If objRecord.LikeItemStoreCount <> Decimal.MinValue Then Me.LikeItemStoreCount.Text = DataHelper.SmartValues(objRecord.LikeItemStoreCount, "formatnumber") '4 digits after decimal
                        ' validation

                        If objRecord.IsValid = ItemValidFlag.Unknown Then
                            _validWasUnknown = True
                        End If

                        ' Validation

                        Dim valRecord As ValidationRecord

                        If ValidationHelper.SkipValidation(itemHeader.BatchStageType) Then
                            valRecord = New ValidationRecord(objRecord.ID, ItemRecordType.Item)
                        Else
                            valRecord = ValidationHelper.ValidateItem(objRecord, itemHeader, Nothing)
                        End If

                        'If vrBatch.IsValid AndAlso valRecord.IsValid Then
                        If valRecord.IsValid Then
                            _validFlag = ItemValidFlag.Valid
                        Else
                            _validFlag = ItemValidFlag.NotValid
                        End If
                        ' validation
                        ValidationHelper.LoadValidationSummary(validationDisplay, valRecord, True)
                        ' clean up
                        'vrBatch = Nothing
                        valRecord = Nothing

                        ' FILES
                        Dim dateNow As Date = Now()
                        If objRecord.ImageID > 0 Then
                            ImageID.Value = objRecord.ImageID.ToString()
                        Else
                            ImageID.Value = String.Empty
                        End If
                        If objRecord.MSDSID > 0 Then
                            MSDSID.Value = objRecord.MSDSID.ToString()
                        Else
                            MSDSID.Value = String.Empty
                        End If


                        ' Set Image
                        I_Image.Attributes.Add("onclick", "showImage();")
                        I_Image.Style.Add("cursor", "hand")
                        If objRecord.ImageID > 0 Then
                            I_Image.Visible = True
                            I_Image.ImageUrl = "images/app_icons/icon_jpg_small_on.gif?id=" & objRecord.ImageID
                            B_UpdateImage.Value = "Update"
                        Else
                            I_Image.Visible = True
                            I_Image.ImageUrl = "images/app_icons/icon_jpg_small.gif"
                            'I_Image_Label.InnerText = "(upload)"
                            B_DeleteImage.Disabled = True
                        End If
                        B_UpdateImage.Attributes.Add("onclick", String.Format("openUploadItemFile('{0}', '{1}', '{2}', '1');", "D", objRecord.ID, ItemFileTypeHelper.GetFileTypeString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image)))
                        B_DeleteImage.Attributes.Add("onclick", "return deleteImage(" & objRecord.ID & ");")

                        ' Set MSDS Sheet
                        I_MSDS.Attributes.Add("onclick", "showMSDS('" & Server.UrlEncode(String.Format("item_{0}_{1}.pdf", objRecord.BatchID, dateNow.ToString("yyyyMMdd"))) & "');")
                        I_MSDS.Style.Add("cursor", "hand")
                        If objRecord.MSDSID > 0 Then
                            I_MSDS.Visible = True
                            I_MSDS.ImageUrl = "images/app_icons/icon_pdf_small.gif?id=" & objRecord.MSDSID
                            B_UpdateMSDS.Value = "Update"
                        Else
                            I_MSDS.Visible = True
                            I_MSDS.ImageUrl = "images/app_icons/icon_pdf_small_off.gif"
                            'I_MSDS_Label.InnerText = "(upload)"
                            B_DeleteMSDS.Disabled = True
                        End If
                        B_UpdateMSDS.Attributes.Add("onclick", String.Format("openUploadItemFile('{0}', '{1}', '{2}', '1');", "D", objRecord.ID, ItemFileTypeHelper.GetFileTypeString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS)))
                        B_DeleteMSDS.Attributes.Add("onclick", "return deleteMSDS(" & objRecord.ID & ");")

                    End If ' objRecord.ID > 0
                    objRecord = Nothing
                Else
                    'Set default value on English - Translation Indicator
                    TIEnglish.SelectedValue = "Y"

                    ' set default value on Private Brand and turn off copy link
                    pblApplyAll.Visible = False
                    PrivateBrandLabel.SelectedValue = WebConstants.LIST_VALUE_DEFAULT_PRIVATE_BRAND_LABEL
                End If ' id > 0

                If hid.Value <> "" And id > 0 Then
                    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(_validFlag, True)
                End If

                If hazardous.SelectedValue <> "Y" Then
                    Me.hazardousFlammableRow.Style.Add("display", "none")
                    Me.hazardousContainerTypeRow.Style.Add("display", "none")
                    Me.hazardousContainerSizeRow.Style.Add("display", "none")
                    Me.hazardousMSDSUOMRow.Style.Add("display", "none")
                    Me.hazardousManufacturerNameRow.Style.Add("display", "none")
                    Me.hazardousManufacturerCityRow.Style.Add("display", "none")
                    Me.hazardousManufacturerStateRow.Style.Add("display", "none")
                    Me.hazardousManufacturerPhoneRow.Style.Add("display", "none")
                    Me.hazardousManufacturerCountryRow.Style.Add("display", "none")
                End If

                If Not UserCanEdit Then
                    btnUpdate.Visible = False
                    btnUpdate.Enabled = False
                    btnUpdateClose.Visible = False
                    btnUpdateClose.Enabled = False
                    B_UpdateImage.Visible = False
                    B_DeleteImage.Visible = False
                    B_UpdateMSDS.Visible = False
                    B_DeleteMSDS.Visible = False
                    btnStockStratHelper.Disabled = True
                    btnStockStratHelper.Style("Display") = "None"
                End If

                If ReadOnlyForm Then
                    SetFormReadOnly()
                End If

                ImplementFieldLocking(itemFL)


                If objMichaels.DisableStockingStratBasedOnStockCat(itemHeader.StockCategory, itemHeader.CanadaStockCategory) Then
                    StockingStrategyCode.Enabled = False
                    btnStockStratHelper.Disabled = True
                    btnStockStratHelper.Style("Display") = "None"
                End If


                'Override English CFG field locking values for Display or Display Pack items.
                If id > 0 Then
                    If packItemIndicator.SelectedItem.Text.StartsWith("D") Or packItemIndicator.SelectedItem.Text.StartsWith("SB") Then
                        EnglishLongDescription.RenderReadOnly = True
                        EnglishShortDescription.RenderReadOnly = True
                    End If
                End If

                ' custom fields
                If ReadOnlyForm Then Me.custFields.RenderReadOnly = True
                Me.custFields.RecordType = Me.RecordType
                Me.custFields.RecordID = DataHelper.SmartValues(recordID.Value, "long", False)
                Me.custFields.DisplayTemplate = "<tr><td class=""formLabel"">##NAME##:</td><td class=""formField"">##VALUE##</td></tr>"
                Me.custFields.Columns = 30
                Me.custFields.LoadCustomFields(True)

                ' clean up 
                itemFL = Nothing
            End If

            objMichaels = Nothing

            ' Init Validation Display
            InitValidation(Me.validationDisplay.ID)

        Else
            ' call back
            ' check security
            If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) Then
                Response.End()
            End If
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
            ITA = ItemTypeAttribute.Value

            Dim oSS As New NovaLibra.Coral.Data.Michaels.StockingStrategy

            Dim strWarehouses As String = ""
            For Each li As ListItem In chkLstWarehouses.Items
                If li.Selected Then
                    strWarehouses += li.Value & ","
                End If
            Next
            strWarehouses = strWarehouses.TrimEnd(",")

            Dim StageType As Int32 = 0

            If IsNumeric(hdnStageType.Value) Then
                StageType = CInt(hdnStageType.Value)
            End If

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

    Private Sub AddIsDirty(ByVal oCtrl As Control)
        For Each ctrl As Control In oCtrl.Controls
            'NAK: 8/25/2011 Ignore TaxUDA changes and PrivateBrandLabel changes.  These should not flag the Item as Dirty.
            If Not (ctrl.ID = "taxUDA") And Not (ctrl.ID = "PrivateBrandLabel") And Not (ctrl.ID = "subClassNum") And Not (ctrl.ID = "classNum") Then
                If TypeOf ctrl Is TextBox Then
                    Dim tb As TextBox = CType(ctrl, TextBox)
                    tb.Attributes.Add("onKeyPress", "setIsDirty(1, '" & ctrl.ID & "');")
                ElseIf TypeOf ctrl Is DropDownList And ctrl.ID <> "packItemIndicator" And ctrl.ID <> "prePriced" And ctrl.ID <> "hazardous" Then
                    Dim ddl As DropDownList = CType(ctrl, DropDownList)
                    ddl.Attributes.Add("onChange", "setIsDirty(1, '" & ctrl.ID & "');")
                End If
            End If

            If ctrl.HasControls Then
                AddIsDirty(ctrl)
            End If
        Next
    End Sub

    Private Sub SetFormReadOnly()
        Dim mdColumns As Hashtable
        Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
        Dim mdTable As NovaLibra.Coral.SystemFrameworks.MetadataTable

        mdTable = md.GetTableByID(Models.MetadataTable.Items)

        mdColumns = mdTable.GetColums     ' Find the fieldname to use for this save

        For Each col As NovaLibra.Coral.SystemFrameworks.MetadataColumn In mdColumns.Values
            If col.MaintEditable Then
                LockField(col.ColumnName, "V")
            End If
        Next
        LockField("Additional_UPC", "V")
        LockField("RDQuebec", "V")
        LockField("RDPuertoRico", "V")

        btnStockStratHelper.Disabled = True
        btnStockStratHelper.Style("Display") = "None"

    End Sub

    Private Sub ImplementFieldLocking(ByRef itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking)
        For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
            LockField(col.ColumnName, col.Permission)
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
                    Case "Additional_UPC"
                        Me.additionalUPCFL.Attributes.Add("style", "display:none")
                        Me.additionalUPCParent.Attributes.Add("style", "display:none")
                    Case "Country_Of_Origin", "country_Of_Origin_Name"
                        Me.countryOfOriginFL.InnerHtml = "&nbsp;"
                        Me.countryOfOriginParent.Visible = False
                    Case "MSDS_ID"
                        Me.MSDSIDFL.Attributes.Add("style", "display:none")
                        Me.MSDSIDParent.Attributes.Add("style", "display:none")
                    Case "Image_ID"
                        Me.ImageIDFL.Attributes.Add("style", "display:none")
                        Me.ImageIDParent.Attributes.Add("style", "display:none")

                    Case Else   ' dynamic control of fields
                        MyBase.Lockfield(colName, permission)

                End Select

            Case "V"
                Select Case colName
                    Case "Additional_UPC"
                        Me.additionalUPCs.Text = Me.additionalUPCValues.Value.Replace(",", "<br />") & "&nbsp;"
                        Me.additionalUPCLink.Visible = False
                    Case "Country_Of_Origin", "country_Of_Origin_Name"
                        Me.countryOfOriginName.RenderReadOnly = True
                    Case "Tax_UDA"
                        taxUDA.RenderReadOnly = True
                    Case "Tax_Wizard"
                        If taxWizardComplete.Value = "1" Then
                            taxWizard.ImageUrl = "images/checkbox_true_disabled.gif"
                        Else
                            taxWizard.ImageUrl = "images/checkbox_false_disabled.gif"
                        End If
                        Me.taxWizardLink.Attributes("onclick") = "return false;"
                    Case "MSDS_ID"
                        Me.B_UpdateMSDS.Disabled = True
                        Me.B_DeleteMSDS.Disabled = True
                    Case "Image_ID"
                        Me.B_UpdateImage.Disabled = True
                        Me.B_DeleteImage.Disabled = True
                    Case "Private_Brand_Label"
                        PrivateBrandLabel.RenderReadOnly = True
                        pblApplyAll.Visible = False

                    Case Else   ' dynamic control of fields 
                        MyBase.Lockfield(colName, permission)

                End Select

            Case Else   ' Edit: Do nothing

        End Select

    End Sub

#Region "Scripts"
    Private Sub CheckForStartupScripts()
        Dim startupScriptKey As String = "__detail_form_"
        If Request("r") = "1" AndAlso Not Me.Page.ClientScript.IsStartupScriptRegistered(startupScriptKey) Then
            CreateStartupScripts(startupScriptKey)
        End If
    End Sub

    Private Sub CreateStartupScripts(ByVal startupScriptKey As String)

        Dim sb As New StringBuilder("")
        sb.Length = 0
        sb.Append("" & vbCrLf)
        sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)

        sb.Append("refreshItemGrid();" & vbCrLf)

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
                Dim canadaRetail As Decimal = DataHelper.SmartValues(str(4).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim resultBase As String = String.Empty
                Dim resultAlaska As String = String.Empty
                Dim resultCanada As String = String.Empty
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
                    'Canada logic below removed by KH 2019-07-15
                    'canadaRetail = NovaLibra.Coral.Data.Michaels.ItemDetail.GetGridPrice(5, baseRetail)
                    'If canadaRetail <> Decimal.MinValue Then
                    '    If canadaRetail > 0 Or Not hdnWorkflowStageID.Value = 5 Then    'don't overlay Canada prices with zero if Pricing Mgr Stage
                    '        resultCanada = DataHelper.SmartValues(canadaRetail, "formatnumber", False, String.Empty, 2)
                    '    End If
                    'End If
                End If
                Return "Retail" & CALLBACK_SEP & "1" & CALLBACK_SEP & str(1) & CALLBACK_SEP & resultBase & CALLBACK_SEP & resultAlaska & CALLBACK_SEP & resultCanada
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
                Dim objFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()
                Dim bRet As Boolean = objFile.DeleteRecord(ItemTypeString.ITEM_TYPE_DOMESTIC, thisItemID, fileID)
                objFile = Nothing
                ' audit
                Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                Dim audit As New Models.AuditRecord()
                audit.SetupAudit(Models.MetadataTable.Items, thisItemID, Models.AuditRecordType.Update, CInt(Session("UserID")))
                If str(0) = "DELETEMSDS" Then
                    audit.AddAuditField("MSDS_ID", String.Empty)
                Else
                    audit.AddAuditField("Image_ID", String.Empty)
                End If
                objFA.SaveAuditRecord(audit)
                objFA = Nothing
                audit = Nothing
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

            Case "PackItemIndicator", "USCost", "CanadaCost"
                Dim itemHeaderID As Long = DataHelper.SmartValues(hid.Value, "long", False)
                Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(itemHeaderID)
                objMichaels = Nothing
                Dim returnString As String
                If itemHeader IsNot Nothing AndAlso str.Length >= 4 Then
                    Dim pii As String = DataHelper.SmartValues(str(1), "string", True)
                    Dim uscost As Decimal = DataHelper.SmartValues(str(2).Replace("$", "").Replace(",", ""), "decimal", True)
                    Dim ccost As Decimal = DataHelper.SmartValues(str(3).Replace("$", "").Replace(",", ""), "decimal", True)
                    Dim tuscost As Decimal
                    Dim tccost As Decimal
                    If str(0) = "USCost" Then
                        tuscost = CalculationHelper.CalculateTotalCost(itemHeader.ItemType, itemHeader.AddUnitCost, pii, uscost)
                        returnString = "TotalUSCost" & CALLBACK_SEP & "1" & CALLBACK_SEP & _
                            IIf(uscost <> Decimal.MinValue, DataHelper.SmartValues(uscost, "formatnumber4", True), String.Empty) & CALLBACK_SEP & _
                            IIf(tuscost <> Decimal.MinValue, DataHelper.SmartValues(tuscost, "formatnumber4", True), String.Empty)
                    ElseIf str(0) = "CanadaCost" Then
                        tccost = CalculationHelper.CalculateTotalCost(itemHeader.ItemType, itemHeader.AddUnitCost, pii, ccost)
                        returnString = "TotalCanadaCost" & CALLBACK_SEP & "1" & CALLBACK_SEP & _
                            IIf(ccost <> Decimal.MinValue, DataHelper.SmartValues(ccost, "formatnumber4", True), String.Empty) & CALLBACK_SEP & _
                            IIf(tccost <> Decimal.MinValue, DataHelper.SmartValues(tccost, "formatnumber4", True), String.Empty)
                    Else
                        tuscost = CalculationHelper.CalculateTotalCost(itemHeader.ItemType, itemHeader.AddUnitCost, pii, uscost)
                        tccost = CalculationHelper.CalculateTotalCost(itemHeader.ItemType, itemHeader.AddUnitCost, pii, ccost)
                        returnString = "TotalCosts" & CALLBACK_SEP & "1" & CALLBACK_SEP & _
                            IIf(tuscost <> Decimal.MinValue, DataHelper.SmartValues(tuscost, "formatnumber4", True), String.Empty) & CALLBACK_SEP & _
                            IIf(tccost <> Decimal.MinValue, DataHelper.SmartValues(tccost, "formatnumber4", True), String.Empty)
                    End If
                    itemHeader = Nothing
                    Return returnString
                Else
                    Return "TotalCosts" & CALLBACK_SEP & "0"
                End If
        End Select
        Return ""
    End Function

    Public Sub RaiseCallbackEvent(ByVal eventArgument As String) Implements System.Web.UI.ICallbackEventHandler.RaiseCallbackEvent
        _callbackArg = eventArgument
    End Sub

#End Region

    Protected Sub DeleteLink_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles DeleteLink.Click

        If UserCanEdit Then
            ' delete this record
            Dim bSuccess As Boolean
            Dim userID As Integer = Session("UserID")
            Dim itemID As Long = DataHelper.SmartValues(recordID.Value, "long", False)
            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
            bSuccess = objMichaels.DeleteRecord(itemID, userID)
            objMichaels = Nothing
            If bSuccess Then
                Response.Redirect("closeform.aspx?r=1")
            Else
                lblSubHeading.Text = "<span class=""errorText"">ERROR: An error occurred while deleting the record!</span>"
            End If
        End If

    End Sub

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
            Dim saveID As Long = SaveFormData()
            If saveID > 0 Then
                Response.Redirect("detailform.aspx?r=1&hid=" & DataHelper.SmartValues(hid.Value, "long", False) & "&id=" & saveID)
            Else
                If saveID = -1 Then
                    hdnPBLApplyAll.Value = ""   ' reset Apply PBL Flag
                End If
            End If
        End If

    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click
        If UserCanEdit Then
            Dim saveID As Long = SaveFormData()
            If saveID > 0 Then
                Response.Redirect("detailform.aspx?r=1&close=1&hid=" & DataHelper.SmartValues(hid.Value, "long", False) & "&id=" & saveID)
            End If
        End If

    End Sub

    Private Function SaveFormData() As Long
        Dim id As Long = 0
        Dim userID As Integer = Session("UserID")
        Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord
        Dim item As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord
        Dim updatePackCost As Boolean = False

        ' test if add or update
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        If IsNumeric(recordID.Value) Then
            id = DataHelper.SmartValues(recordID.Value, "long", False)
            item = objMichaels.GetRecord(id)
            item.SetupAudit(Models.MetadataTable.Items, item.ID, AuditRecordType.Update, userID)
            Debug.Assert(item.ItemHeaderID = DataHelper.SmartValues(hid.Value, "long", False))
            Dim packInfo As Models.ItemPackInfo = NovaLibra.Coral.Data.Michaels.ItemDetail.GetPackInfo(item.ID)
            updatePackCost = packInfo.IsPack
        Else
            item = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord()
            item.SetupAudit(Models.MetadataTable.Items, 0, AuditRecordType.Insert, userID)
            item.ItemHeaderID = DataHelper.SmartValues(hid.Value, "long", False)
            updatePackCost = NovaLibra.Coral.Data.Michaels.ItemDetail.IsPack(item.ItemHeaderID)
        End If
        item.TrackChanges()
        ' load header
        itemHeader = objMichaels.GetItemHeaderRecord(item.ItemHeaderID)

        ' save
        item.AddChange = addChange.SelectedValue
        item.PackItemIndicator = packItemIndicator.SelectedValue
        item.MichaelsSKU = michaelsSKU.Text
        item.VendorUPC = vendorUPC.Text

        If item.AdditionalUPCRecord Is Nothing Then item.AdditionalUPCRecord = New ItemAdditionalUPCRecord(item.ItemHeaderID, item.ID)
        ' additional upcs
        Dim upcvalues1 As String = String.Empty, upcvalues2 As String = String.Empty
        Dim i As Integer
        ' upcvalues1
        For i = 0 To item.AdditionalUPCRecord.AdditionalUPCs.Count - 1
            If upcvalues1 <> String.Empty Then upcvalues1 += ","
            upcvalues1 += item.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString()
        Next

        ' save upc values
        item.AdditionalUPCRecord.AdditionalUPCs.Clear()
        Dim arr() As String = Split(additionalUPCValues.Value, ",")
        For i = 0 To arr.Length - 1
            If arr(i).Trim() <> String.Empty Then
                item.AdditionalUPCRecord.AddAdditionalUPC(arr(i).Trim())
            End If
        Next
        ' upcvalues2
        For i = 0 To item.AdditionalUPCRecord.AdditionalUPCs.Count - 1
            If upcvalues2 <> String.Empty Then upcvalues2 += ","
            upcvalues2 += item.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString()
        Next
        ' compare 
        If item.SaveAudit AndAlso upcvalues1 <> upcvalues2 Then
            item.AddAuditField("Additional_UPC", upcvalues2)
        End If

        'PMO200141 GTIN14 Enhancements changes
        item.VendorInnerGTIN = vendorInnerGTIN.Text
        item.VendorCaseGTIN = vendorCaseGTIN.Text

        item.ClassNum = DataHelper.SmartValues(classNum.Text, "integer", True)
        item.SubClassNum = DataHelper.SmartValues(subClassNum.Text, "integer", True)
        item.VendorStyleNum = DataHelper.SmartValues(vendorStyleNum.Text, "stringrsu", True)
        item.ItemDesc = DataHelper.SmartValues(itemDesc.Text, "stringrsu", True)
        item.PrivateBrandLabel = PrivateBrandLabel.SelectedValue
        'item.HybridType = hybridType.SelectedValue
        'item.HybridSourceDC = hybridSourceDC.SelectedValue
        'item.HybridLeadTime = DataHelper.SmartValues(hybridLeadTime.Text, "integer", True)
        'item.HybridConversionDate = DataHelper.SmartValues(hybridConversionDate.Value, "date", True)
        item.StockingStrategyCode = DataHelper.SmartValues(StockingStrategyCode.SelectedValue, "string", True)

        item.QtyInPack = DataHelper.SmartValues(qtyInPack.Text, "integer", True)

        item.EachesMasterCase = DataHelper.SmartValues(eachesMasterCase.Text, "integer", True)
        item.EachesInnerPack = DataHelper.SmartValues(eachesInnerPack.Text, "integer", True)
        item.PrePriced = prePriced.SelectedValue
        item.PrePricedUDA = prePricedUDA.SelectedValue

        item.USCost = DataHelper.SmartValues(USCost.Text.Replace("$", "").Replace(",", ""), "decimal", True)
        item.TotalUSCost = DataHelper.SmartValues(totalUSCost.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.CanadaCost = DataHelper.SmartValues(canadaCost.Text.Replace("$", "").Replace(",", ""), "decimal", True)
        item.TotalCanadaCost = DataHelper.SmartValues(totalCanadaCost.Value.Replace("$", "").Replace(",", ""), "decimal", True)

        item.BaseRetail = DataHelper.SmartValues(baseRetail.Text.Replace("$", "").Replace(",", ""), "decimal", True)
        item.CentralRetail = DataHelper.SmartValues(centralRetail.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.TestRetail = DataHelper.SmartValues(testRetail.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.AlaskaRetail = DataHelper.SmartValues(alaskaRetail.Text.Replace("$", "").Replace(",", ""), "decimal", True)
        item.CanadaRetail = DataHelper.SmartValues(canadaRetail.Text.Replace("$", "").Replace(",", ""), "decimal", True)
        item.ZeroNineRetail = DataHelper.SmartValues(zeroNineRetail.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.CaliforniaRetail = DataHelper.SmartValues(californiaRetail.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.VillageCraftRetail = DataHelper.SmartValues(villageCraftRetail.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.Retail9 = DataHelper.SmartValues(Me.Retail9.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.Retail10 = DataHelper.SmartValues(Me.Retail10.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.Retail11 = DataHelper.SmartValues(Me.Retail11.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.Retail12 = DataHelper.SmartValues(Me.Retail12.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.Retail13 = DataHelper.SmartValues(Me.Retail13.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.RDQuebec = DataHelper.SmartValues(Me.RDQuebec.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.RDPuertoRico = DataHelper.SmartValues(Me.RDPuertoRico.Value.Replace("$", "").Replace(",", ""), "decimal", True)
        item.POGSetupPerStore = DataHelper.SmartValues(POGSetupPerStore.Text, "decimal", True)
        item.POGMaxQty = DataHelper.SmartValues(POGMaxQty.Text, "decimal", True)
        'item.ProjectedUnitSales = DataHelper.SmartValues(projectedUnitSales.Text, "decimal", True)

        item.EachCaseHeight = RoundDimesionsDecimal(DataHelper.SmartValues(eachCaseHeight.Text, "decimal", True), 4)
        item.EachCaseWidth = RoundDimesionsDecimal(DataHelper.SmartValues(eachCaseWidth.Text, "decimal", True), 4)
        item.EachCaseLength = RoundDimesionsDecimal(DataHelper.SmartValues(eachCaseLength.Text, "decimal", True), 4)
        item.EachCaseWeight = RoundDimesionsDecimal(DataHelper.SmartValues(eachCaseWeight.Text, "decimal", True), 4)
        'item.EachCasePackCube = DataHelper.SmartValues(eachCasePackCube.Value, "decimal", True)

        Dim strEachPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
            item.EachCaseWidth, _
            item.EachCaseHeight, _
            item.EachCaseLength, _
            item.EachCaseWeight)

        item.EachCasePackCube = DataHelper.SmartValues(strEachPackCube, "decimal", True)

        item.InnerCaseHeight = RoundDimesionsDecimal(DataHelper.SmartValues(innerCaseHeight.Text, "decimal", True), 4)
        item.InnerCaseWidth = RoundDimesionsDecimal(DataHelper.SmartValues(innerCaseWidth.Text, "decimal", True), 4)
        item.InnerCaseLength = RoundDimesionsDecimal(DataHelper.SmartValues(innerCaseLength.Text, "decimal", True), 4)
        item.InnerCaseWeight = RoundDimesionsDecimal(DataHelper.SmartValues(innerCaseWeight.Text, "decimal", True), 4)
        'item.InnerCasePackCube = DataHelper.SmartValues(innerCasePackCube.Value, "decimal", True)

        Dim strInnerPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
        item.InnerCaseWidth, _
        item.InnerCaseHeight, _
        item.InnerCaseLength, _
        item.InnerCaseWeight)

        item.InnerCasePackCube = DataHelper.SmartValues(strInnerPackCube, "decimal", True)

        item.MasterCaseHeight = RoundDimesionsDecimal(DataHelper.SmartValues(masterCaseHeight.Text, "decimal", True), 4)
        item.MasterCaseWidth = RoundDimesionsDecimal(DataHelper.SmartValues(masterCaseWidth.Text, "decimal", True), 4)
        item.MasterCaseLength = RoundDimesionsDecimal(DataHelper.SmartValues(masterCaseLength.Text, "decimal", True), 4)
        item.MasterCaseWeight = RoundDimesionsDecimal(DataHelper.SmartValues(masterCaseWeight.Text, "decimal", True), 4)
        item.MasterCasePackCube = DataHelper.SmartValues(masterCasePackCube.Value, "decimal", True)

        item.CountryOfOrigin = countryOfOrigin.Value
        item.CountryOfOriginName = countryOfOriginName.Text

        'item.TaxUDA = taxUDA.SelectedValue
        item.TaxUDA = taxUDAValue.Value
        'item.TaxValueUDA = DataHelper.SmartValues(taxValueUDA.Text, "integer", True)
        item.TaxValueUDA = DataHelper.SmartValues(taxValueUDAValue.Value, "integer", True)

        item.Hazardous = hazardous.SelectedValue

        If item.Hazardous = "Y" Then
            item.HazardousFlammable = hazardousFlammable.SelectedValue
            item.HazardousContainerType = hazardousContainerType.SelectedValue
            item.HazardousContainerSize = DataHelper.SmartValues(hazardousContainerSize.Text, "decimal", True)
            item.HazardousMSDSUOM = hazardousMSDSUOM.SelectedValue
            item.HazardousManufacturerName = hazardousManufacturerName.Text
            item.HazardousManufacturerCity = hazardousManufacturerCity.Text
            item.HazardousManufacturerState = hazardousManufacturerState.Text
            item.HazardousManufacturerPhone = hazardousManufacturerPhone.Text
            item.HazardousManufacturerCountry = hazardousManufacturerCountry.Text
        Else
            item.HazardousFlammable = String.Empty
            item.HazardousContainerType = String.Empty
            item.HazardousContainerSize = Decimal.MinValue
            item.HazardousMSDSUOM = String.Empty
            item.HazardousManufacturerName = String.Empty
            item.HazardousManufacturerCity = String.Empty
            item.HazardousManufacturerState = String.Empty
            item.HazardousManufacturerPhone = String.Empty
            item.HazardousManufacturerCountry = String.Empty
        End If

        ' New Item Approval
        item.LikeItemSKU = DataHelper.SmartValues(Me.likeItemSKU.Text, "string", True)
        item.LikeItemDescription = DataHelper.SmartValues(Me.likeItemDescription.Value, "string", True)
        item.LikeItemRetail = DataHelper.SmartValues(Me.likeItemRetail.Value, "decimal", True, Decimal.MinValue, 2)

        'itemDetail.LikeItemRegularUnit = DataHelper.SmartValues(Me.LikeItemRegularUnit.Text, "decimal", True)
        Dim strValue As String
        Dim decValue As Decimal
        strValue = LikeItemRegularUnit.Text.Trim().Replace(",", "").Replace("%", "")
        decValue = Decimal.MinValue
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True, Decimal.MinValue, 0)
            If decValue <> Decimal.MinValue Then
                ' decValue = decValue / 100
            End If
        End If
        'lie items is integer per customer request
        item.LikeItemRegularUnit = decValue
        'LP 3 13 09 calc option is not stored in the database fot items,but used for validation
        item.CalculateOptions = CInt(Me.tb_CalcOptions.Text)
        item.LikeItemStoreCount = DataHelper.SmartValues(Me.LikeItemStoreCount.Text.Trim(), "decimal", True)
        'item.LikeItemSales = DataHelper.SmartValues(Me.likeItemSales.Text, "decimal", True)
        'Annual Regular Unit Forecast is now replacing Yearly Forecast LP new code!
        If AnnualRegularUnitForecastEdit.ReadOnly Then
            item.AnnualRegularUnitForecast = DataHelper.SmartValues(Me.AnnualRegularUnitForecast.Value, "decimal", True, Decimal.MinValue, 0)
        Else
            item.AnnualRegularUnitForecast = DataHelper.SmartValues(Me.AnnualRegularUnitForecastEdit.Text.Trim(), "decimal", True, Decimal.MinValue, 0)
        End If
        'Annual Reg Retail Slaes
        If Me.AnnualRegRetailSalesEdit.ReadOnly Then
            item.AnnualRegRetailSales = DataHelper.SmartValues(Me.AnnualRegRetailSales.Value, "decimal", True, Decimal.MinValue, 2)
        Else
            item.AnnualRegRetailSales = DataHelper.SmartValues(Me.AnnualRegRetailSalesEdit.Text.Trim(), "decimal", True, Decimal.MinValue, 2)
        End If
        'Avg Reg Units/Store/Month
        If Me.LikeItemUnitStoreMonthEdit.ReadOnly Then
            item.LikeItemUnitStoreMonth = DataHelper.SmartValues(Me.LikeItemUnitStoreMonth.Value, "decimal", True, Decimal.MinValue, 2)
        Else
            item.LikeItemUnitStoreMonth = DataHelper.SmartValues(Me.LikeItemUnitStoreMonthEdit.Text.Trim(), "decimal", True, Decimal.MinValue, 2)
        End If
        item.Facings = DataHelper.SmartValues(Me.facings.Text, "decimal", True)
        item.POGMinQty = DataHelper.SmartValues(Me.POGMinQty.Text, "decimal", True)
        item.QuoteReferenceNumber = DataHelper.SmartValues(Me.QuoteReferenceNumber.Text, "string", True)
        item.CustomsDescription = DataHelper.SmartValues(Me.CustomsDescription.Text, "string", True)

        'Per client requirements, Default English Descriptions for Pack items
        If Not String.IsNullOrEmpty(item.PackItemIndicator) Then
            Dim englishDesc As String = ""
            If item.PackItemIndicator.StartsWith("DP") Then
                englishDesc = "Display Pack"
            ElseIf item.PackItemIndicator.StartsWith("SB") Then
                englishDesc = "Sellable Bundle"
            ElseIf item.PackItemIndicator.StartsWith("D") Then
                englishDesc = "Displayer"
            End If
            If englishDesc.Length > 0 Then
                EnglishShortDescription.Text = englishDesc
                EnglishLongDescription.Text = englishDesc
            End If
        End If

        'NAK 4/10/2013:  Per Michaels new requirements, default TI to 'Y' for English and French.
        If (TIEnglish.SelectedValue = "") Then
            TIEnglish.SelectedValue = "Y"
        End If
        If (TIFrench.SelectedValue = "") Then
            TIFrench.SelectedValue = "Y"
        End If

        'NAK:  Per client requirements, default TI Spanish field to NO if not set (TI Spanish should always be No, unless this is a new Record)
        If String.IsNullOrEmpty(TISpanish.SelectedValue) Then
            TISpanish.SelectedValue = "N"
        End If

        'Set Multilingual fields
        item.PLIEnglish = PLIEnglish.SelectedValue
        item.PLIFrench = PLIFrench.SelectedValue
        item.PLISpanish = PLISpanish.SelectedValue
        item.TIEnglish = TIEnglish.SelectedValue
        item.TIFrench = TIFrench.SelectedValue
        item.TISpanish = TISpanish.SelectedValue
        item.EnglishLongDescription = EnglishLongDescription.Text
        item.EnglishShortDescription = EnglishShortDescription.Text
        item.FrenchLongDescription = FrenchLongDescription.Text
        item.FrenchShortDescription = FrenchShortDescription.Text
        item.SpanishLongDescription = SpanishLongDescription.Text
        item.SpanishShortDescription = SpanishShortDescription.Text

        'Set CRC fields
        item.HarmonizedCodeNumber = HarmonizedCodeNumber.Text
        item.CanadaHarmonizedCodeNumber = CanadaHarmonizedCodeNumber.Text
        item.DetailInvoiceCustomsDesc = DetailInvoiceCustomsDesc.Text
        item.ComponentMaterialBreakdown = ComponentMaterialBreakdown.Text

        item.PhytoSanitaryCertificate = PhytoSanitaryCertificate.SelectedValue
        item.PhytoTemporaryShipment = PhytoTemporaryShipment.SelectedValue

        ' FJL Mar 2010 
        ' - Check to see if Private Label info should be saved in all records in batch
        If hdnPBLApplyAll.Value = "1" Then ' Only Update Private Brand Label for all records in batch
            objMichaels.ApplyPBLToAll(item, userID)
            Return item.ID
        Else
            Dim saveID As Long = objMichaels.SaveRecord(item, userID, DataHelper.SmartValues(Me.dirtyFlag.Value, "boolean"))

            'Save Language Information
            Data.ItemDetail.SaveItemLanguage(saveID, 1, PLIEnglish.SelectedValue, TIEnglish.SelectedValue, EnglishShortDescription.Text, Left(EnglishLongDescription.Text, 100), userID)
            Data.ItemDetail.SaveItemLanguage(saveID, 2, PLIFrench.SelectedValue, TIFrench.SelectedValue, FrenchShortDescription.Text, FrenchLongDescription.Text, userID)
            Data.ItemDetail.SaveItemLanguage(saveID, 3, PLISpanish.SelectedValue, TISpanish.SelectedValue, SpanishShortDescription.Text, SpanishLongDescription.Text, userID)

            If PLIEnglish_Dirty.Value = 1 Then
                Data.ItemDetail.SaveEditedLanguage(saveID, 1)
            End If
            If PLIFrench_Dirty.Value = 1 Then
                Data.ItemDetail.SaveEditedLanguage(saveID, 2)
            End If
            If PLISpanish_Dirty.Value = 1 Then
                Data.ItemDetail.SaveEditedLanguage(saveID, 3)
            End If

            'NAK 5/6/2013:  Per Michaels, no longer update child based on parent
            ''NAK - 11/13/2012 Per Michaels: Update all child PLIs to parent PLI
            'If item.IsPackParent Then
            '    Dim childItems As Models.ItemList = objMichaels.GetList(item.ItemHeaderID, 0, 0, String.Empty, userID)
            '    For i = 0 To childItems.ListRecords.Count - 1
            '        Dim childItem As Models.ItemRecord = childItems.ListRecords(i)
            '        If String.IsNullOrEmpty(childItem.MichaelsSKU) Then
            '            If childItem.PLIEnglish <> item.PLIEnglish Then
            '                'Default TI field if it is empty
            '                If String.IsNullOrEmpty(childItem.TIEnglish) Then
            '                    childItem.TIEnglish = item.PLIEnglish
            '                End If
            '                Data.ItemDetail.SaveItemLanguage(childItem.ID, 1, item.PLIEnglish, childItem.TIEnglish, childItem.EnglishShortDescription, Left(childItem.EnglishLongDescription, 100), userID)
            '                Data.ItemDetail.SaveEditedLanguage(childItem.ID, 1)
            '            End If
            '            If childItem.PLIFrench <> item.PLIFrench Then
            '                'Default TI field if it is empty
            '                If String.IsNullOrEmpty(childItem.TIFrench) Then
            '                    childItem.TIFrench = item.PLIFrench
            '                End If
            '                Data.ItemDetail.SaveItemLanguage(childItem.ID, 2, item.PLIFrench, childItem.TIFrench, childItem.FrenchShortDescription, childItem.FrenchLongDescription, userID)
            '                Data.ItemDetail.SaveEditedLanguage(childItem.ID, 2)
            '            End If
            '            If childItem.PLISpanish <> item.PLISpanish Then
            '                Data.ItemDetail.SaveItemLanguage(childItem.ID, 3, item.PLISpanish, childItem.TISpanish, childItem.SpanishShortDescription, childItem.SpanishLongDescription, userID)
            '                Data.ItemDetail.SaveEditedLanguage(childItem.ID, 3)
            '            End If
            '        End If
            '    Next
            'End If

            If Not item.ValidExistingSKU Then Me.custFields.SaveCustomFields(saveID)

            If Not item.ValidExistingSKU Then
                ' check
                ' ------------------------------------------------------------------
                ' CHECK FOR VALID EXISTING SKU
                Dim sku As String, vendorNumber As Long
                Dim itemMaintItem As Models.ItemMaintItemDetailFormRecord
                sku = item.MichaelsSKU
                vendorNumber = DataHelper.SmartValues(itemHeader.USVendorNum, "integer", False)
                If vendorNumber > 0 AndAlso itemHeader.USVendorName = String.Empty Then vendorNumber = 0
                If vendorNumber <= 0 Then
                    vendorNumber = DataHelper.SmartValues(itemHeader.CanadianVendorNum, "integer", False)
                    If vendorNumber > 0 AndAlso itemHeader.CanadianVendorName = String.Empty Then vendorNumber = 0
                End If
                If sku <> String.Empty AndAlso vendorNumber > 0 Then
                    itemMaintItem = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(vendorNumber, sku, vendorNumber)
                    If itemMaintItem IsNot Nothing AndAlso (itemMaintItem.SKU <> String.Empty And itemMaintItem.VendorNumber > 0) Then
                        ' MERGE
                        ItemHelper.MergeItemMaintRecordIntoItem(itemHeader, item, itemMaintItem)
                        item.ValidExistingSKU = True
                        itemMaintItem = Nothing
                    End If
                End If

                ' Save this item ??
                ' ---------------
                If item.ValidExistingSKU Then
                    saveID = objMichaels.SaveRecord(item, userID)
                    ' Save XRef to this image for existing SKU (if exists)...
                    Dim objMichaelsIFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()
                    If item.ImageID > 0 Then
                        objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_DOMESTIC, ItemID, item.ImageID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image, userID)
                        ' audit
                        Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                        Dim audit As New Models.AuditRecord()
                        audit.SetupAudit(Models.MetadataTable.Items_Files, ItemID, Models.AuditRecordType.Insert, userID)
                        audit.AddAuditField("File_ID", item.ImageID)
                        objFA.SaveAuditRecord(audit)
                        objFA = Nothing
                        audit = Nothing
                    End If

                    ' Save XRef to MSDS sheet for existing SKU (if exists)...
                    If item.MSDSID > 0 Then
                        objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_DOMESTIC, ItemID, item.MSDSID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS, userID)
                        ' audit
                        Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                        Dim audit As New Models.AuditRecord()
                        audit.SetupAudit(Models.MetadataTable.Items_Files, ItemID, Models.AuditRecordType.Insert, userID)
                        audit.AddAuditField("File_ID", item.MSDSID)
                        objFA.SaveAuditRecord(audit)
                        objFA = Nothing
                        audit = Nothing
                    End If
                    objMichaelsIFile = Nothing
                End If
                ' ------------------------------------------------------------------
                ' end check
            End If

            ' validation
            Dim vrBatch As ValidationRecord
            Dim valRecord As ValidationRecord

            If ValidationHelper.SkipBatchValidation(itemHeader.BatchStageType) Then
                vrBatch = New ValidationRecord(itemHeader.BatchID, ItemRecordType.Batch)
            Else
                vrBatch = ValidationHelper.ValidateBatch(itemHeader.BatchID, BatchType.Domestic)
            End If

            If ValidationHelper.SkipValidation(itemHeader.BatchStageType) Then
                valRecord = New ValidationRecord(item.ID, ItemRecordType.Item)
            Else
                valRecord = ValidationHelper.ValidateItem(item, itemHeader, Request)
            End If
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecord, userID)


            If updatePackCost AndAlso Not item.IsPackParent AndAlso (item.CostFieldsChanged Or item.MasterWeightChanged) Then
                ItemHelper.CalculateDomesticDPBatchParent(itemHeader, item.CostFieldsChanged, item.MasterWeightChanged)
            End If

            objMichaels = Nothing
            Return saveID
        End If
    End Function
End Class
