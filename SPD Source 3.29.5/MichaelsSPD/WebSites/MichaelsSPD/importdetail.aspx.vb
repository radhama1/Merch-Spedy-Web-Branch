Imports System.Configuration
Imports System.Data
Imports System.Data.SqlClient
Imports System.IO
Imports System.Runtime.Serialization.Formatters.Binary
Imports System.Runtime.Serialization
Imports WebConstants

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.SystemFrameworks
Imports data = NovaLibra.Coral.Data.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports BatchRec = NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord
Imports System.Collections.Generic
Imports ItemHelper

Partial Class importdetail
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler


#Region "Attributes and Properties"

    Private _callbackArg As String = ""

    Public Const CALLBACK_SEP As String = "{{|}}"

    Private UserID As Integer = 0
    Private BatchID As Long = 0
    Private ImportDetailID As Long = 0
    Private ParentID As Long = 0
    Private WorkFlowStageID As Integer = 0
    Private StageType As Models.WorkflowStageType = Models.WorkflowStageType.General
    Private _isRegitem As Boolean = False
    'Private _canAddToBatch As Boolean = False
    Private _isCFPMCCalc As Boolean = True
    Private _readOnlyForm As Boolean = False

    Public Property ReadOnlyForm() As Boolean
        Get
            Return _readOnlyForm
        End Get
        Set(ByVal value As Boolean)
            _readOnlyForm = value
        End Set
    End Property


    Public ReadOnly Property ItemID() As String
        Get
            If ImportDetailID > 0 Then
                Return ImportDetailID.ToString()
            Else
                Return String.Empty
            End If
        End Get
    End Property

    Public ReadOnly Property ItemParentID() As Long
        Get
            Return ParentID
        End Get
    End Property

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

    Public Property IsRegularBatchItem() As Boolean
        Get
            Return _isRegitem
        End Get
        Set(ByVal value As Boolean)
            _isRegitem = value
        End Set
    End Property

    Public Property IsPack() As Boolean
        Get
            Dim o As Object = Me.ViewState("IsPack")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState("IsPack") = value
        End Set
    End Property

    Public Property MultipleItems() As Boolean
        Get
            Dim o As Object = Me.ViewState("MultipleItems")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState("MultipleItems") = value
        End Set
    End Property

    Public Property CanAddToBatch() As Boolean
        Get
            Dim o As Object = Me.ViewState("CanAddToBatch")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState("CanAddToBatch") = value
        End Set
    End Property

    Public ReadOnly Property RecordType() As Integer
        Get
            Return WebConstants.RECTYPE_IMPORT_ITEM
        End Get
    End Property

#End Region

#Region "Page Events"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Me.IsCallback Then

            SecurityCheckRedirect()

            ' check to make sure the URL is OK Session_BatchID should match Parm hid
            'Dim s As String, h As String
            's = CType(Session(cHEADERID), String)
            'h = CType(Request("hid"), String)
            'If s <> h Then
            '    Session("cHEADERID") = Nothing
            '    Response.Redirect("default.aspx")
            'End If

            ' make sure __doPostBack is generated
            ClientScript.GetPostBackEventReference(Me, String.Empty)

            ' callback
            Dim cbReference As String
            cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", "ReceiveServerData", "context")
            Dim callbackScript As String = ""
            callbackScript &= "function CallServer(arg, context)" & _
                "{" & cbReference & "; }"
            Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), _
                "CallServer", callbackScript, True)

            PopulateGlobalVariables()

            If IsPostBack AndAlso Request.Params("__EVENTTARGET") <> "" AndAlso Request.Params("__EVENTTARGET") = "btnDuplicate" Then
                DuplicateItem()
            End If
            If IsPostBack AndAlso Request.Params("__EVENTTARGET") <> "" AndAlso Request.Params("__EVENTTARGET") = "btnAddToBatch" Then
                AddToBatch()
            End If
            If IsPostBack AndAlso Request.Params("__EVENTTARGET") <> "" AndAlso Request.Params("__EVENTTARGET") = "btnSplit" Then
                SplitItem()
            End If
            If Not IsPostBack Then
                If StageType = Models.WorkflowStageType.DBC AndAlso UserCanEdit Then
                    ShowRMSFields = True
                Else
                    ShowRMSFields = False
                End If
            End If

            If Not Page.IsPostBack Then

                VendorNumberEdit.Visible = True
                VendorNumberLabel.Visible = False
                VendorNumberEdit.Attributes.Add("onchange", "lookupVendor("""", this);")

                Initialize()
            Else
                ' --------
                ' POSTBACK
                ' --------
                If AddedNewSKUs.Value = "1" Then
                    InitChildDropDown()     ' If a SKU was added, then refresh the child dropdown
                End If

                If taxWizardComplete.Value = "1" Then
                    taxWizard.ImageUrl = "images/checkbox_true.gif"
                Else
                    taxWizard.ImageUrl = "images/checkbox_false.gif"
                End If


                If Request.Params("__EVENTTARGET") <> "btnUpdate" AndAlso Request.Params("__EVENTTARGET") <> "btnUpdateClose" _
                    AndAlso Request.Params("__EVENTTARGET") <> "VendorAgent" _
                    AndAlso Request.Params("__EVENTTARGET") <> "Agent" Then

                    ' Activiate Validation
                    InitializeValidation()

                End If
            End If

            CheckForStartupScripts()

            ' Init Validation Display
            InitValidation(Me.V_Summary.ID)

        Else

            ' Callback
            If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
                Response.End()
            End If


        End If 'Not Me.IsCallback

    End Sub

#End Region

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
            Case "CALC_OceanFreight"
                ' ocean freight
                If str.Length < 4 Then
                    Return "CALC_OceanFreight" & CALLBACK_SEP & "0"
                End If
                Return "CALC_OceanFreight" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateOceanFrieght(str(1), str(2), str(3))
            Case "CALC_EstLandedCost"
                ' estimated landed cost
                If str.Length < 3 Then
                    Return "CALC_EstLandedCost" & CALLBACK_SEP & "0"
                End If
                Dim calc As String = CalculationHelper.CalculateEstLandedCostAndStore(str(2))
                Return "CALC_EstLandedCost" & CALLBACK_SEP & CType(IIf(calc <> String.Empty, "1", "0"), String) & CALLBACK_SEP & str(1) & CALLBACK_SEP & calc
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
                        Dim objRecord As Models.PricePointRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupAlaskRetailFromBaseRetail(baseRetail)
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
                ' alaska retail value
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
                Dim objCountry As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(country)
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
                Dim bRet As Boolean = objFile.DeleteRecord(Models.ItemTypeString.ITEM_TYPE_IMPORT, thisItemID, fileID)
                objFile = Nothing
                ' audit
                Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                Dim audit As New Models.AuditRecord()
                audit.SetupAudit(Models.MetadataTable.Import_Items, thisItemID, Models.AuditRecordType.Update, CInt(Session("UserID")))
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
                    Dim objRecord As Models.ItemMasterRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupItemMaster(item)
                    If Not objRecord Is Nothing AndAlso (objRecord.ItemDescription <> String.Empty Or objRecord.BaseRetail <> Decimal.MinValue) Then
                        resultItemDesc = objRecord.ItemDescription
                        If objRecord.BaseRetail <> Decimal.MinValue Then
                            resultBaseRetail = DataHelper.SmartValues(objRecord.BaseRetail, "formatnumber", True, String.Empty, 2)
                        End If
                    End If
                    objRecord = Nothing
                End If
                Return "LikeItemSKU" & CALLBACK_SEP & "1" & CALLBACK_SEP & item & CALLBACK_SEP & resultItemDesc & CALLBACK_SEP & resultBaseRetail
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
                If ValidationHelper.IsValidImportVendor(vendor) Then
                    retValue = String.Format("100{0}1{0}{1}{0}{2}{0}{3}", CALLBACK_SEP, vendorToLookup, vnum, vendor.VendorName)
                End If
            End If
            vendor = Nothing
            objMichaelsVendor = Nothing
        End If

        Return retValue
    End Function

#End Region

#Region "Scripts"

    Private Sub CheckForStartupScripts()

        Dim startupScriptKey As String = "__import_form_"
        If Not Me.Page.ClientScript.IsStartupScriptRegistered(startupScriptKey) Then
            CreateStartupScripts(startupScriptKey)
        End If

        CreateStartupScriptForCalc("agent")

    End Sub

    Private Sub CreateStartupScripts(ByVal startupScriptKey As String)

        Dim sb As New StringBuilder("")
        sb.Length = 0
        sb.Append("" & vbCrLf)
        sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)

        sb.Append("initPage();" & vbCrLf)
        If Not _isCFPMCCalc Then
            sb.Append("setIsCubicFeetPerMasterCartonCalculated(false);" & vbCrLf)
        End If

        sb.Append("//-->" & vbCrLf)
        sb.Append("</script>" & vbCrLf)
        Me.ClientScript.RegisterStartupScript(Me.GetType(), startupScriptKey, sb.ToString())
    End Sub

    Private Sub CreateStartupScriptForCalc(ByVal fromField As String)

        If Not Me.Page.ClientScript.IsStartupScriptRegistered("__import_form_calc") Then
            Dim sb As New StringBuilder("")
            sb.Length = 0
            sb.Append("" & vbCrLf)
            sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
            sb.Append("<!--" & vbCrLf)

            sb.Append("calculateEstLandedCost('" & fromField & "');" & vbCrLf)

            sb.Append("//-->" & vbCrLf)
            sb.Append("</script>" & vbCrLf)
            Me.ClientScript.RegisterStartupScript(Me.GetType(), "__import_form_calc", sb.ToString())
        End If

    End Sub

#End Region

    Private Sub PopulateGlobalVariables()

        'Populate User ID
        UserID = CInt(Session("UserID"))

        Dim batch As Integer = 0

        If Not Request("HID") Is Nothing AndAlso IsNumeric(Request("HID")) Then

            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
            Dim itemDetail As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord = objMichaels.GetRecord(CInt(Request("HID")))
            objMichaels = Nothing
            If Not itemDetail Is Nothing And itemDetail.ID > 0 Then

                'Populate Item Detail ID
                ImportDetailID = itemDetail.ID
                batch = itemDetail.Batch_ID

                'Populate the Parent ID
                ParentID = itemDetail.ParentID

                'Regular Batch Item
                IsRegularBatchItem = itemDetail.RegularBatchItem

                Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
                Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(itemDetail.Batch_ID)
                objMichaelsBatch = Nothing

                If batchDetail.ID > 0 Then

                    'Set the global workflow id
                    WorkFlowStageID = batchDetail.WorkflowStageID
                    hdnWorkflowStageID.Value = batchDetail.WorkflowStageID

                    'set the global workflow stage type
                    StageType = batchDetail.WorkflowStageType

                    'Set batch ID
                    BatchID = batchDetail.ID

                End If

            End If
        End If

        If ImportDetailID <= 0 Then
            IsNew = True
            ' VALIDATE USER
            ValidateUser(0)
        Else
            ' VALIDATE USER
            ValidateUser(batch, StageType)
            If NoUserAccess Then Response.Redirect("default.aspx")
        End If
    End Sub

    Private Sub Initialize()

        ' load list values
        Dim lvgs As ListValueGroups = FormHelper.LoadListValues("YESNO,ITEMTYPE,ITEMTYPEATTRIB,SKUGROUP,ADDCHANGE,PACKITEMIND,HYBRIDTYPE,HYBRIDSOURCEDC,PREPRICEDUDA,TAXUDA,HAZCONTAINERTYPE,HAZMSDSUOM,RMS_PBL,AGENTTYPE,STOCKSTRAT,STOCKSTRATBASIC,STOCKSTRATSEASONAL,STOCKSTRATALL")

        'FormHelper.LoadListFromListValues(stockCategory, lvgs.GetListValueGroup("STOCKCAT"), True)
        'FormHelper.LoadListFromListValues(canadaStockCategory, lvgs.GetListValueGroup("STOCKCAT"), True)
        FormHelper.LoadListFromListValues(ItemType, lvgs.GetListValueGroup("ITEMTYPE"), True)
        FormHelper.LoadListFromListValues(ItemTypeAttribute, lvgs.GetListValueGroup("ITEMTYPEATTRIB"), True)
        'FormHelper.LoadListFromListValues(allowStoreOrder, lvgs.GetListValueGroup("YESNO"), True)
        'FormHelper.LoadListFromListValues(inventoryControl, lvgs.GetListValueGroup("INVCONTROL"), True)
        'FormHelper.LoadListFromListValues(freightTerms, lvgs.GetListValueGroup("FREIGHTTERMS"), True)
        'FormHelper.LoadListFromListValues(autoReplenish, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(SKUGroup, lvgs.GetListValueGroup("SKUGROUP"), True)

        'FormHelper.LoadListFromListValues(addChange, lvgs.GetListValueGroup("ADDCHANGE"), True)
        FormHelper.LoadListFromListValues(PackItemIndicator, lvgs.GetListValueGroup("PACKITEMIND"), True)
        'FormHelper.LoadListFromListValues(HybridType, lvgs.GetListValueGroup("HYBRIDTYPE"), True)
        'FormHelper.LoadListFromListValues(SourcingDC, lvgs.GetListValueGroup("HYBRIDSOURCEDC"), True)
        FormHelper.LoadListFromListValues(PrePriced, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(PrePricedUDA, lvgs.GetListValueGroup("PREPRICEDUDA"), True)
        FormHelper.LoadListFromListValues(TaxUDA, lvgs.GetListValueGroup("TAXUDA"), True, "", "", 20)
        'FormHelper.LoadListFromListValues(hazardous, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(HazMatMFGFlammable, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(HazMatContainerType, lvgs.GetListValueGroup("HAZCONTAINERTYPE"), True)
        FormHelper.LoadListFromListValues(HazMatMSDSUOM, lvgs.GetListValueGroup("HAZMSDSUOM"), True)
        FormHelper.LoadListFromListValues(PrivateBrandLabel, lvgs.GetListValueGroup("RMS_PBL"), True)
        FormHelper.LoadListFromListValues(discountable, lvgs.GetListValueGroup("YESNO"), False)     ' Defualt to Y

        FormHelper.LoadListFromListValues(AgentType, lvgs.GetListValueGroup("AGENTTYPE"), False)

        ' RMS
        FormHelper.LoadListFromListValues(RMSSellable, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(RMSOrderable, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(RMSInventory, lvgs.GetListValueGroup("YESNO"), True)

        '****STOCKING STRATEGY DDL MUST BE LOADED In POPULATEFORM BECAUSE IT IS DEPENDANT ON ITEMTYPEATTRIBUTE

        'Init Controls
        InitControls()

        'InitStockStratHelper
        InitStockStratHelper()

        'Read values from DB
        PopulateForm(lvgs)

        lvgs.ClearAll()
        lvgs = Nothing

        'Enable Appropriate Fields
        SetupFields()

        'Activiate Validation
        InitializeValidation()

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

    Private Sub PopulateForm(ByRef lvgs As ListValueGroups)

        Dim tempStrArray As String()
        Dim delimiter(1) As String
        delimiter(0) = WebConstants.MULTILINE_DELIM
        Dim decValue As Decimal
        Dim strValue As String

        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
        Dim itemDetail As New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord()

        Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
        'NAK: Per Ken, if this is a New Batch then default field locking to Vendor stage.
        itemFL = objMichaels.GetFieldLocking(AppHelper.GetUserID(), AppHelper.GetVendorID(), IIf(WorkFlowStageID = 0, 1, WorkFlowStageID))

        ' Vendor Check
        itemDetail = objMichaels.GetRecord(ImportDetailID)

        If StageType = NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStageType.Completed Then
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATALL"), True)
        ElseIf itemDetail.ItemTypeAttribute = "S" Then
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATSEASONAL"), True)
        ElseIf itemDetail.ItemTypeAttribute <> "S" And itemDetail.ItemTypeAttribute <> "" Then
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATBASIC"), True)
        Else
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRAT"), True)
        End If


        If Not itemDetail Is Nothing And itemDetail.ID > 0 Then
            VendorCheckRedirect(DataHelper.SmartValues(itemDetail.VendorNumber, "integer", False))

            ' Check to see if this is an existing Item being added to a pack.  If so, set readonly
            If itemDetail.ValidExistingSKU Then
                ReadOnlyForm = True
                btnDuplicate.Visible = False
            End If

            'Set Dropdown values
            If VendorAgent.Items.Contains(VendorAgent.Items.FindByValue(itemDetail.Vendor)) Then VendorAgent.SelectedValue = itemDetail.Vendor
            If Agent.Items.Contains(Agent.Items.FindByValue(itemDetail.Agent)) Then Agent.SelectedValue = itemDetail.Agent
            If AgentType.Items.Contains(AgentType.Items.FindByValue(itemDetail.AgentType)) Then AgentType.SelectedValue = itemDetail.AgentType
            If SKUGroup.Items.Contains(SKUGroup.Items.FindByValue(itemDetail.SKUGroup)) Then SKUGroup.SelectedValue = itemDetail.SKUGroup
            If ItemType.Items.Contains(ItemType.Items.FindByValue(itemDetail.ItemType)) Then ItemType.SelectedValue = itemDetail.ItemType
            If PackItemIndicator.Items.Contains(PackItemIndicator.Items.FindByValue(itemDetail.PackItemIndicator)) Then PackItemIndicator.SelectedValue = itemDetail.PackItemIndicator
            If ItemTypeAttribute.Items.Contains(ItemTypeAttribute.Items.FindByValue(itemDetail.ItemTypeAttribute)) Then ItemTypeAttribute.SelectedValue = itemDetail.ItemTypeAttribute
            If AllowStoreOrder.Items.Contains(AllowStoreOrder.Items.FindByValue(itemDetail.AllowStoreOrder)) Then AllowStoreOrder.SelectedValue = itemDetail.AllowStoreOrder
            If InventoryControl.Items.Contains(InventoryControl.Items.FindByValue(itemDetail.InventoryControl)) Then InventoryControl.SelectedValue = itemDetail.InventoryControl
            If AutoReplenish.Items.Contains(AutoReplenish.Items.FindByValue(itemDetail.AutoReplenish)) Then AutoReplenish.SelectedValue = itemDetail.AutoReplenish
            If PrePriced.Items.Contains(PrePriced.Items.FindByValue(itemDetail.PrePriced)) Then PrePriced.SelectedValue = itemDetail.PrePriced
            If StockingStrategyCode.Items.Contains(StockingStrategyCode.Items.FindByValue(itemDetail.StockingStrategyCode)) Then StockingStrategyCode.SelectedValue = itemDetail.StockingStrategyCode


            discountable.SelectedValue = itemDetail.Discountable

            ' tax wizard
            taxWizard.BorderWidth = 0
            If itemDetail.TaxWizard Then
                taxWizard.ImageUrl = "images/checkbox_true.gif"
                taxWizardComplete.Value = "1"
            Else
                taxWizard.ImageUrl = "images/checkbox_false.gif"
                taxWizardComplete.Value = "0"
            End If

            TaxUDA.SelectedValue = itemDetail.TaxUDA
            If TaxUDA.SelectedIndex > 0 Then
                'TaxUDALabel.Text = TaxUDA.SelectedItem.Text
                TaxUDAValue.Value = TaxUDA.SelectedValue
            End If


            If PrePricedUDA.Items.Contains(PrePricedUDA.Items.FindByValue(itemDetail.PrePricedUDA)) Then PrePricedUDA.SelectedValue = itemDetail.PrePricedUDA
            'If HybridType.Items.Contains(HybridType.Items.FindByValue(itemDetail.HybridType)) Then HybridType.SelectedValue = itemDetail.HybridType
            'If SourcingDC.Items.Contains(SourcingDC.Items.FindByValue(itemDetail.SourcingDC)) Then SourcingDC.SelectedValue = itemDetail.SourcingDC
            If QuoteSheetStatus.Items.Contains(QuoteSheetStatus.Items.FindByValue(itemDetail.QuoteSheetStatus)) Then QuoteSheetStatus.SelectedValue = itemDetail.QuoteSheetStatus
            If ItemTask.Items.Contains(ItemTask.Items.FindByValue(itemDetail.ItemTask)) Then ItemTask.SelectedValue = itemDetail.ItemTask
            If Season.Items.Contains(Season.Items.FindByValue(itemDetail.Season)) Then Season.SelectedValue = itemDetail.Season

            ' GenerateMichaelsUPC
            GenerateMichaelsUPC.SelectedValue = itemDetail.GenerateMichaelsUPC

            'PMO200141 GTIN14 Enhancements changes
            GenerateMichaelsGTIN14.SelectedValue = itemDetail.GenerateMichaelsGTIN

            If VendorRank.Items.Contains(VendorRank.Items.FindByValue(itemDetail.VendorRank)) Then VendorRank.SelectedValue = itemDetail.VendorRank
            If PaymentTerms.Items.Contains(PaymentTerms.Items.FindByValue(itemDetail.PaymentTerms)) Then PaymentTerms.SelectedValue = itemDetail.PaymentTerms
            If Days.Items.Contains(Days.Items.FindByValue(itemDetail.Days)) Then Days.SelectedValue = itemDetail.Days
            If CoinBattery.Items.Contains(CoinBattery.Items.FindByValue(itemDetail.CoinBattery)) Then CoinBattery.SelectedValue = itemDetail.CoinBattery
            If TSSA.Items.Contains(TSSA.Items.FindByValue(itemDetail.TSSA)) Then TSSA.SelectedValue = itemDetail.TSSA
            If CSA.Items.Contains(CSA.Items.FindByValue(itemDetail.CSA)) Then CSA.SelectedValue = itemDetail.CSA
            If UL.Items.Contains(UL.Items.FindByValue(itemDetail.UL)) Then UL.SelectedValue = itemDetail.UL
            If LicenceAgreement.Items.Contains(LicenceAgreement.Items.FindByValue(itemDetail.LicenceAgreement)) Then LicenceAgreement.SelectedValue = itemDetail.LicenceAgreement
            If FumigationCertificate.Items.Contains(FumigationCertificate.Items.FindByValue(itemDetail.FumigationCertificate)) Then FumigationCertificate.SelectedValue = itemDetail.FumigationCertificate
            If PhytoTemporaryShipment.Items.Contains(PhytoTemporaryShipment.Items.FindByValue(itemDetail.PhytoTemporaryShipment)) Then PhytoTemporaryShipment.SelectedValue = itemDetail.PhytoTemporaryShipment
            If KILNDriedCertificate.Items.Contains(KILNDriedCertificate.Items.FindByValue(itemDetail.KILNDriedCertificate)) Then KILNDriedCertificate.SelectedValue = itemDetail.KILNDriedCertificate
            If ChinaComInspecNumAndCCIBStickers.Items.Contains(ChinaComInspecNumAndCCIBStickers.Items.FindByValue(itemDetail.ChinaComInspecNumAndCCIBStickers)) Then ChinaComInspecNumAndCCIBStickers.SelectedValue = itemDetail.ChinaComInspecNumAndCCIBStickers
            If OriginalVisa.Items.Contains(OriginalVisa.Items.FindByValue(itemDetail.OriginalVisa)) Then OriginalVisa.SelectedValue = itemDetail.OriginalVisa
            If TextileDeclarationMidCode.Items.Contains(TextileDeclarationMidCode.Items.FindByValue(itemDetail.TextileDeclarationMidCode)) Then TextileDeclarationMidCode.SelectedValue = itemDetail.TextileDeclarationMidCode
            If QuotaChargeStatement.Items.Contains(QuotaChargeStatement.Items.FindByValue(itemDetail.QuotaChargeStatement)) Then QuotaChargeStatement.SelectedValue = itemDetail.QuotaChargeStatement
            If MSDS.Items.Contains(MSDS.Items.FindByValue(itemDetail.MSDS)) Then MSDS.SelectedValue = itemDetail.MSDS
            If TSCA.Items.Contains(TSCA.Items.FindByValue(itemDetail.TSCA)) Then TSCA.SelectedValue = itemDetail.TSCA
            If DropBallTestCert.Items.Contains(DropBallTestCert.Items.FindByValue(itemDetail.DropBallTestCert)) Then DropBallTestCert.SelectedValue = itemDetail.DropBallTestCert
            If ManMedicalDeviceListing.Items.Contains(ManMedicalDeviceListing.Items.FindByValue(itemDetail.ManMedicalDeviceListing)) Then ManMedicalDeviceListing.SelectedValue = itemDetail.ManMedicalDeviceListing
            If ManFDARegistration.Items.Contains(ManFDARegistration.Items.FindByValue(itemDetail.ManFDARegistration)) Then ManFDARegistration.SelectedValue = itemDetail.ManFDARegistration
            If CopyRightIndemnification.Items.Contains(CopyRightIndemnification.Items.FindByValue(itemDetail.CopyRightIndemnification)) Then CopyRightIndemnification.SelectedValue = itemDetail.CopyRightIndemnification
            If FishWildLifeCert.Items.Contains(FishWildLifeCert.Items.FindByValue(itemDetail.FishWildLifeCert)) Then FishWildLifeCert.SelectedValue = itemDetail.FishWildLifeCert
            If Proposition65LabelReq.Items.Contains(Proposition65LabelReq.Items.FindByValue(itemDetail.Proposition65LabelReq)) Then Proposition65LabelReq.SelectedValue = itemDetail.Proposition65LabelReq
            If CCCR.Items.Contains(CCCR.Items.FindByValue(itemDetail.CCCR)) Then CCCR.SelectedValue = itemDetail.CCCR
            If FormaldehydeCompliant.Items.Contains(FormaldehydeCompliant.Items.FindByValue(itemDetail.FormaldehydeCompliant)) Then FormaldehydeCompliant.SelectedValue = itemDetail.FormaldehydeCompliant
            If HazMatYes.Items.Contains(HazMatYes.Items.FindByValue(itemDetail.HazMatYes)) Then HazMatYes.SelectedValue = itemDetail.HazMatYes
            If HazMatNo.Items.Contains(HazMatNo.Items.FindByValue(itemDetail.HazMatNo)) Then HazMatNo.SelectedValue = itemDetail.HazMatNo
            If HazMatMFGFlammable.Items.Contains(HazMatMFGFlammable.Items.FindByValue(itemDetail.HazMatMFGFlammable)) Then HazMatMFGFlammable.SelectedValue = itemDetail.HazMatMFGFlammable
            If HazMatContainerType.Items.Contains(HazMatContainerType.Items.FindByValue(itemDetail.HazMatContainerType)) Then HazMatContainerType.SelectedValue = itemDetail.HazMatContainerType
            If HazMatMSDSUOM.Items.Contains(HazMatMSDSUOM.Items.FindByValue(itemDetail.HazMatMSDSUOM)) Then HazMatMSDSUOM.SelectedValue = itemDetail.HazMatMSDSUOM


            If itemDetail.MinimumOrderQuantity <> Integer.MinValue Then MinimumOrderQuantity.Text = DataHelper.SmartValues(itemDetail.MinimumOrderQuantity, "cint")
            If ProductIdentifiesAsCosmetic.Items.Contains(ProductIdentifiesAsCosmetic.Items.FindByValue(itemDetail.ProductIdentifiesAsCosmetic)) Then ProductIdentifiesAsCosmetic.SelectedValue = itemDetail.ProductIdentifiesAsCosmetic


            Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
            Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(itemDetail.Batch_ID)
            objMichaelsBatch = Nothing

            'StageID = batchDetail.WorkflowStageID

            'Update the header banner at the top of the page
            If itemDetail.Batch_ID > 0 Then
                batch.Text = " &nbsp;|&nbsp; Log ID: " & itemDetail.Batch_ID.ToString()
            End If
            If batchDetail.VendorName <> "" Then
                batchVendorName.Text = " &nbsp;|&nbsp; " & "Vendor: " & batchDetail.VendorName
            End If
            If batchDetail.WorkflowStageName <> "" Then
                stageName.Text = " &nbsp;|&nbsp; " & "Stage: " & batchDetail.WorkflowStageName
            End If
            If itemDetail.DateLastModified <> Date.MinValue Then
                lastUpdated.Text = " &nbsp;|&nbsp; " & "Last Updated: " & itemDetail.DateLastModified.ToString("M/d/yyyy")
                If itemDetail.UpdatedUserName <> "" Then
                    lastUpdated.Text += " by " & itemDetail.UpdatedUserName
                End If
            End If

            'Set multiple line textboxes
            tempStrArray = itemDetail.DetailInvoiceCustomsDesc.Split(delimiter, System.StringSplitOptions.None)
            For x As Integer = 0 To UBound(tempStrArray)
                Select Case x
                    Case 0
                        DetailInvoiceCustomsDesc1.Text = tempStrArray(x)
                    Case 1
                        DetailInvoiceCustomsDesc2.Text = tempStrArray(x)
                    Case 2
                        DetailInvoiceCustomsDesc3.Text = tempStrArray(x)
                    Case 3
                        DetailInvoiceCustomsDesc4.Text = tempStrArray(x)
                    Case 4
                        DetailInvoiceCustomsDesc5.Text = tempStrArray(x)
                    Case 5
                        DetailInvoiceCustomsDesc6.Text = tempStrArray(x)
                End Select
            Next

            tempStrArray = itemDetail.ComponentMaterialBreakdown.Split(delimiter, System.StringSplitOptions.None)
            For x As Integer = 0 To UBound(tempStrArray)
                Select Case x
                    Case 0
                        ComponentMaterialBreakdown1.Text = tempStrArray(x)
                    Case 1
                        ComponentMaterialBreakdown2.Text = tempStrArray(x)
                    Case 2
                        ComponentMaterialBreakdown3.Text = tempStrArray(x)
                    Case 3
                        ComponentMaterialBreakdown4.Text = tempStrArray(x)
                    Case 4
                        ComponentMaterialBreakdown5.Text = tempStrArray(x)
                End Select
            Next

            tempStrArray = itemDetail.ComponentConstructionMethod.Split(delimiter, System.StringSplitOptions.None)
            For x As Integer = 0 To UBound(tempStrArray)
                Select Case x
                    Case 0
                        ComponentConstructionMethod1.Text = tempStrArray(x)
                    Case 1
                        ComponentConstructionMethod2.Text = tempStrArray(x)
                    Case 2
                        ComponentConstructionMethod3.Text = tempStrArray(x)
                    Case 3
                        ComponentConstructionMethod4.Text = tempStrArray(x)
                End Select
            Next

            tempStrArray = itemDetail.PurchaseOrderIssuedTo.Split(delimiter, System.StringSplitOptions.None)
            For x As Integer = 0 To UBound(tempStrArray)
                Select Case x
                    Case 0
                        PurchaseOrderIssuedTo1.Text = tempStrArray(x)
                    Case 1
                        PurchaseOrderIssuedTo2.Text = tempStrArray(x)
                    Case 2
                        PurchaseOrderIssuedTo3.Text = tempStrArray(x)
                End Select
            Next

            'Set Textboxes
            If itemDetail.DateSubmitted <> Date.MinValue Then DateSubmitted.Text = String.Format(Format("{0:d}"), itemDetail.DateSubmitted)
            If itemDetail.EnteredDate <> Date.MinValue Then EnteredDate.Text = String.Format(Format("{0:d}"), itemDetail.EnteredDate)
            'If itemDetail.ConversionDate <> Date.MinValue Then ConversionDateEdit.Text = String.Format(Format("{0:d}"), itemDetail.ConversionDate)
            'ConversionDate.Value = ConversionDateEdit.Text
            Buyer.Text = itemDetail.Buyer
            'Added QuoteReferenceNumber 2/8/11 JC
            QuoteReferenceNumber.Text = itemDetail.QuoteReferenceNumber
            Fax.Text = itemDetail.Fax
            EnteredBy.Text = itemDetail.EnteredBy
            Email.Text = itemDetail.Email
            Dept.Text = itemDetail.Dept
            Me.Class.Text = itemDetail.Class
            SubClass.Text = itemDetail.SubClass
            PrimaryUPC.Text = FormatUPCValue(itemDetail.PrimaryUPC)
            MichaelsSKU.Text = FormatSKUValue(itemDetail.MichaelsSKU)

            'PMO200141 GTIN14 Enhancements changes Start
            InnerGTIN.Text = FormatUPCValue(itemDetail.InnerGTIN)
            CaseGTIN.Text = FormatUPCValue(itemDetail.CaseGTIN)

            ' additional UPCs
            Dim UPC As String, UPCValues As String = String.Empty
            If Not itemDetail.AdditionalUPCRecord Is Nothing AndAlso itemDetail.AdditionalUPCRecord.AdditionalUPCs.Count > 0 Then
                Dim UPCString As String = String.Empty
                For i As Integer = 0 To itemDetail.AdditionalUPCRecord.AdditionalUPCs.Count - 1
                    If UPCString <> String.Empty Then UPCString += "<br />"
                    UPC = itemDetail.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString().Replace("""", "&quot;")
                    If UPCValues <> String.Empty Then UPCValues += ","
                    UPCValues += UPC
                    UPCString += "<input type=""text"" id=""additionalUPC" & (i + 1) & """ maxlength=""20"" value=""" & UPC & """ onchange=""additionalUPCChanged('" & (i + 1) & "');"" /><sup>" & (i + 1) & "</sup>"
                Next
                additionalUPCs.Text = UPCString
                additionalUPCCount.Value = itemDetail.AdditionalUPCRecord.AdditionalUPCs.Count.ToString()
                additionalUPCValues.Value = UPCValues
            End If
            PackSKU.Text = itemDetail.PackSKU

            PlanogramName.Text = itemDetail.PlanogramName

            ' vendor number and vendor name
            VendorNumber.Value = itemDetail.VendorNumber

            If itemDetail.VendorNumber <> String.Empty And IsNumeric(itemDetail.VendorNumber) AndAlso itemDetail.VendorName.Trim() <> String.Empty AndAlso ValidationHelper.IsValidImportVendor(DataHelper.SmartValues(itemDetail.VendorNumber, "integer", False)) Then
                VendorNumberEdit.Visible = False
                VendorNumberLabel.Visible = True
                VendorNumberLabel.Text = itemDetail.VendorNumber
            Else
                VendorNumberEdit.Visible = True
                VendorNumberLabel.Visible = False
                VendorNumberEdit.Text = itemDetail.VendorNumber
            End If
            VendorName.Value = itemDetail.VendorName
            VendorNameLabel.Text = itemDetail.VendorName

            Description.Text = itemDetail.Description

            PrivateBrandLabel.SelectedValue = itemDetail.PrivateBrandLabel
            hdnPrivateBrand.Value = PrivateBrandLabel.SelectedValue

            VendorAddress1.Text = itemDetail.VendorAddress1
            VendorAddress2.Text = itemDetail.VendorAddress2
            VendorAddress3.Text = itemDetail.VendorAddress3
            VendorAddress4.Text = itemDetail.VendorAddress4
            VendorMinOrderAmount.Text = IIf(itemDetail.VendorMinOrderAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.VendorMinOrderAmount, "decimal", True, String.Empty, 2), itemDetail.VendorMinOrderAmount)
            VendorContactName.Text = itemDetail.VendorContactName
            VendorContactPhone.Text = itemDetail.VendorContactPhone
            VendorContactEmail.Text = itemDetail.VendorContactEmail
            VendorContactFax.Text = itemDetail.VendorContactFax
            ManufactureName.Text = itemDetail.ManufactureName
            ManufactureAddress1.Text = itemDetail.ManufactureAddress1
            ManufactureAddress2.Text = itemDetail.ManufactureAddress2
            ManufactureContact.Text = itemDetail.ManufactureContact
            ManufacturePhone.Text = itemDetail.ManufacturePhone
            ManufactureEmail.Text = itemDetail.ManufactureEmail
            ManufactureFax.Text = itemDetail.ManufactureFax
            AgentContact.Text = itemDetail.AgentContact

            AgentPhone.Text = itemDetail.AgentPhone

            AgentEmail.Text = itemDetail.AgentEmail

            AgentFax.Text = itemDetail.AgentFax

            VendorStyleNumber.Text = itemDetail.VendorStyleNumber
            HarmonizedCodeNumber.Text = itemDetail.HarmonizedCodeNumber
            CanadaHarmonizedCodeNumber.Text = itemDetail.CanadaHarmonizedCodeNumber
            IndividualItemPackaging.Text = itemDetail.IndividualItemPackaging
            If (MultipleItems And Not IsRegularBatchItem) And (itemDetail.PackItemIndicator.Trim() = "C" Or itemDetail.QtyInPack > 0 Or itemDetail.ValidExistingSKU) Then
                If itemDetail.QtyInPack <> Integer.MinValue Then QtyInPack.Text = itemDetail.QtyInPack
            Else
                QtyInPackRow.Style.Add("display", "none")
            End If
            EachInsideMasterCaseBox.Text = itemDetail.EachInsideMasterCaseBox
            EachInsideInnerPack.Text = itemDetail.EachInsideInnerPack

            EachHeight.Text = IIf(itemDetail.EachHeight <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.EachHeight, "formatnumber4"), "")
            EachWidth.Text = IIf(itemDetail.EachWidth <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.EachWidth, "formatnumber4"), "")
            EachLength.Text = IIf(itemDetail.EachLength <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.EachLength, "formatnumber4"), "")
            EachWeight.Text = IIf(itemDetail.EachWeight <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.EachWeight, "formatnumber4"), "")
            ' cubic feet per each carton
            If itemDetail.CubicFeetEach.ToString.Trim.Length > 0 AndAlso DataHelper.SmartValues(itemDetail.CubicFeetEach, "decimal", True) <> Decimal.MinValue Then
                CubicFeetPerEachEdit.Text = DataHelper.SmartValues(itemDetail.CubicFeetEach, "formatnumber4")
                CubicFeetPerEach.Value = DataHelper.SmartValues(itemDetail.CubicFeetEach, "formatnumber4")
            Else
                CubicFeetPerEachEdit.Text = IIf(itemDetail.CubicFeetEach <> Decimal.MinValue, itemDetail.CubicFeetEach, "")
                CubicFeetPerEach.Value = IIf(itemDetail.CubicFeetEach <> Decimal.MinValue, itemDetail.CubicFeetEach, "")
            End If

            'EachPieceNetWeightLbsPerOunce.Text = itemDetail.EachPieceNetWeightLbsPerOunce
            ReshippableInnerCartonWeight.Text = IIf(itemDetail.ReshippableInnerCartonWeight <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.ReshippableInnerCartonWeight, "formatnumber4"), "")

            ReshippableInnerCartonLength.Text = itemDetail.ReshippableInnerCartonLength
            ReshippableInnerCartonWidth.Text = itemDetail.ReshippableInnerCartonWidth
            ReshippableInnerCartonHeight.Text = itemDetail.ReshippableInnerCartonHeight
            MasterCartonDimensionsLength.Text = itemDetail.MasterCartonDimensionsLength
            MasterCartonDimensionsWidth.Text = itemDetail.MasterCartonDimensionsWidth
            MasterCartonDimensionsHeight.Text = itemDetail.MasterCartonDimensionsHeight
            ' cubic feet per master carton
            If itemDetail.CubicFeetPerMasterCarton.Trim.Length > 0 AndAlso DataHelper.SmartValues(itemDetail.CubicFeetPerMasterCarton, "decimal", True) <> Decimal.MinValue Then
                CubicFeetPerMasterCartonEdit.Text = DataHelper.SmartValues(itemDetail.CubicFeetPerMasterCarton, "formatnumber4")
                CubicFeetPerMasterCarton.Value = DataHelper.SmartValues(itemDetail.CubicFeetPerMasterCarton, "formatnumber4")
            Else
                CubicFeetPerMasterCartonEdit.Text = itemDetail.CubicFeetPerMasterCarton
                CubicFeetPerMasterCarton.Value = itemDetail.CubicFeetPerMasterCarton
            End If

            If Decimal.TryParse(itemDetail.WeightMasterCarton, Nothing) Then
                WeightMasterCarton.Text = IIf(itemDetail.WeightMasterCarton <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.WeightMasterCarton, "formatnumber4"), "")
            Else
                WeightMasterCarton.Text = ""
            End If

            ' cubic feet per inner carton
            If itemDetail.CubicFeetPerInnerCarton.Trim.Length > 0 AndAlso DataHelper.SmartValues(itemDetail.CubicFeetPerInnerCarton, "decimal", True) <> Decimal.MinValue Then
                CubicFeetPerInnerCartonEdit.Text = DataHelper.SmartValues(itemDetail.CubicFeetPerInnerCarton, "formatnumber4")
                CubicFeetPerInnerCarton.Value = DataHelper.SmartValues(itemDetail.CubicFeetPerInnerCarton, "formatnumber4")
            Else
                CubicFeetPerInnerCartonEdit.Text = itemDetail.CubicFeetPerInnerCarton
                CubicFeetPerInnerCarton.Value = itemDetail.CubicFeetPerInnerCarton
            End If
            DisplayerCost.Text = IIf(itemDetail.DisplayerCost <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.DisplayerCost, "decimal", True, String.Empty, 4), String.Empty)
            ProductCost.Text = IIf(itemDetail.ProductCost <> Decimal.MinValue, DataHelper.SmartValues(itemDetail.ProductCost, "decimal", True, String.Empty, 4), String.Empty)
            FOBShippingPointEdit.Text = IIf(itemDetail.FOBShippingPoint.Trim.Length > 0, DataHelper.SmartValues(itemDetail.FOBShippingPoint, "decimal", True, String.Empty, 4), itemDetail.FOBShippingPoint)
            FOBShippingPoint.Value = FOBShippingPointEdit.Text

            'DutyPercent.Text = IIf(itemDetail.DutyPercent.Trim.Length > 0, DataHelper.SmartValues(itemDetail.DutyPercent, "decimal", True, String.Empty, 2), itemDetail.DutyPercent)
            strValue = itemDetail.DutyPercent
            If strValue.Trim().Length > 0 Then
                decValue = DataHelper.SmartValues(itemDetail.DutyPercent, "decimal", True)
                If decValue <> Decimal.MinValue Then
                    decValue = decValue * 100
                    strValue = DataHelper.SmartValues(decValue, "formatnumber", False)
                End If
            End If
            DutyPercent.Text = strValue

            DutyAmountEdit.Text = IIf(itemDetail.DutyAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.DutyAmount, "decimal", True, String.Empty, 4), itemDetail.DutyAmount)
            DutyAmount.Value = DutyAmountEdit.Text


            strValue = itemDetail.SuppTariffPercent
            If strValue.Trim().Length > 0 Then
                decValue = DataHelper.SmartValues(itemDetail.SuppTariffPercent, "decimal", True)
                If decValue <> Decimal.MinValue Then
                    decValue = decValue * 100
                    strValue = DataHelper.SmartValues(decValue, "formatnumber", False)
                End If
            End If
            SuppTariffPercent.Text = strValue

            SuppTariffAmountEdit.Text = IIf(itemDetail.SuppTariffAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.SuppTariffAmount, "decimal", True, String.Empty, 4), itemDetail.SuppTariffAmount)
            SuppTariffAmount.Value = SuppTariffAmountEdit.Text


            AdditionalDutyComment.Text = itemDetail.AdditionalDutyComment
            AdditionalDutyAmount.Text = IIf(itemDetail.AdditionalDutyAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.AdditionalDutyAmount, "decimal", True, String.Empty, 4), itemDetail.AdditionalDutyAmount)
            OceanFreightAmount.Text = IIf(itemDetail.OceanFreightAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.OceanFreightAmount, "decimal", True, String.Empty, 4), itemDetail.OceanFreightAmount)
            OceanFreightComputedAmountEdit.Text = IIf(itemDetail.OceanFreightComputedAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.OceanFreightComputedAmount, "decimal", True, String.Empty, 4), itemDetail.OceanFreightComputedAmount)
            OceanFreightComputedAmount.Value = OceanFreightComputedAmountEdit.Text

            'AgentCommissionPercent.Text = IIf(itemDetail.AgentCommissionPercent.Trim.Length > 0, DataHelper.SmartValues(itemDetail.AgentCommissionPercent, "decimal", True, String.Empty, 2), itemDetail.AgentCommissionPercent)
            strValue = itemDetail.AgentCommissionPercent
            If strValue.Trim().Length > 0 Then
                decValue = DataHelper.SmartValues(itemDetail.AgentCommissionPercent, "decimal", True)
                If decValue <> Decimal.MinValue Then
                    decValue = decValue * 100
                    strValue = DataHelper.SmartValues(decValue, "formatnumber", False)
                End If
            End If
            AgentCommissionPercent.Text = strValue

            strValue = itemDetail.RecAgentCommissionPercent
            If strValue.Trim().Length > 0 Then
                decValue = DataHelper.SmartValues(itemDetail.RecAgentCommissionPercent, "decimal", True)
                If decValue <> Decimal.MinValue Then
                    decValue = decValue * 100
                    strValue = DataHelper.SmartValues(decValue, "formatnumber", False)
                End If
            End If
            RecAgentCommissionPercent.Text = strValue

            strValue = itemDetail.AgentCommissionAmount.Trim()
            If DataHelper.SmartValues(strValue, "decimal", True) <> Decimal.MinValue Then
                AgentCommissionAmountEdit.Text = IIf(itemDetail.AgentCommissionAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.AgentCommissionAmount, "decimal", True, String.Empty, 4), itemDetail.AgentCommissionAmount)
            Else
                AgentCommissionAmountEdit.Text = String.Empty
            End If
            AgentCommissionAmount.Value = AgentCommissionAmountEdit.Text

            'OtherImportCostsPercentEdit.Text = IIf(itemDetail.OtherImportCostsPercent.Trim.Length > 0, DataHelper.SmartValues(itemDetail.OtherImportCostsPercent, "decimal", True, String.Empty, 0), itemDetail.OtherImportCostsPercent)
            strValue = itemDetail.OtherImportCostsPercent
            If strValue.Trim().Length > 0 Then
                decValue = DataHelper.SmartValues(itemDetail.OtherImportCostsPercent, "decimal", True)
                If decValue <> Decimal.MinValue Then
                    decValue = decValue * 100
                    If decValue = 0 Or decValue = 2 Then
                        strValue = DataHelper.SmartValues(decValue, "decimal", False, 0, 0)
                    Else
                        strValue = DataHelper.SmartValues(decValue, "formatnumber", False)
                    End If

                End If
            End If
            OtherImportCostsPercentEdit.Text = strValue
            OtherImportCostsPercent.Value = OtherImportCostsPercentEdit.Text

            OtherImportCostsAmountEdit.Text = IIf(itemDetail.OtherImportCostsAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.OtherImportCostsAmount, "decimal", True, String.Empty, 4), itemDetail.OtherImportCostsAmount)
            OtherImportCostsAmount.Value = OtherImportCostsAmountEdit.Text
            'PackagingCostAmount.Text = IIf(itemDetail.PackagingCostAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.PackagingCostAmount, "decimal", True, String.Empty, 4), itemDetail.PackagingCostAmount)
            PackagingCostAmount.Value = String.Empty
            TotalImportBurdenEdit.Text = IIf(itemDetail.TotalImportBurden.Trim.Length > 0, DataHelper.SmartValues(itemDetail.TotalImportBurden, "decimal", True, String.Empty, 4), itemDetail.TotalImportBurden)
            TotalImportBurden.Value = TotalImportBurdenEdit.Text
            WarehouseLandedCostEdit.Text = IIf(itemDetail.WarehouseLandedCost.Trim.Length > 0, DataHelper.SmartValues(itemDetail.WarehouseLandedCost, "decimal", True, String.Empty, 4), itemDetail.WarehouseLandedCost)
            WarehouseLandedCost.Value = WarehouseLandedCostEdit.Text
            ShippingPoint.Text = itemDetail.ShippingPoint
            CountryOfOrigin.Value = itemDetail.CountryOfOrigin
            CountryOfOriginName.Text = itemDetail.CountryOfOriginName
            VendorComments.Text = itemDetail.VendorComments
            StockCategory.Text = itemDetail.StockCategory
            FreightTerms.Text = itemDetail.FreightTerms
            TaxValueUDA.Text = itemDetail.TaxValueUDA
            TaxValueUDAValue.Value = itemDetail.TaxValueUDA
            'LeadTime.Text = itemDetail.LeadTime
            StoreSuppZoneGRP.Text = itemDetail.StoreSuppZoneGRP
            WhseSuppZoneGRP.Text = itemDetail.WhseSuppZoneGRP
            POGMaxQty.Text = itemDetail.POGMaxQty
            POGSetupPerStore.Text = itemDetail.POGSetupPerStore
            ProjSalesPerStorePerMonth.Text = itemDetail.ProjSalesPerStorePerMonth
            FirstCostEdit.Text = IIf(itemDetail.FOBShippingPoint.Trim.Length > 0, DataHelper.SmartValues(itemDetail.FOBShippingPoint, "decimal", True, String.Empty, 4), itemDetail.FOBShippingPoint)
            FirstCost.Value = FirstCostEdit.Text
            StoreTotalImportBurdenEdit.Text = IIf(itemDetail.TotalImportBurden.Trim.Length > 0, DataHelper.SmartValues(itemDetail.TotalImportBurden, "decimal", True, String.Empty, 4), itemDetail.TotalImportBurden)
            StoreTotalImportBurden.Value = StoreTotalImportBurdenEdit.Text
            OutboundFreightEdit.Text = IIf(itemDetail.OutboundFreight.Trim.Length > 0, DataHelper.SmartValues(itemDetail.OutboundFreight, "decimal", True, String.Empty, 4), itemDetail.OutboundFreight)
            OutboundFreight.Value = OutboundFreightEdit.Text
            NinePercentWhseChargeEdit.Text = IIf(itemDetail.NinePercentWhseCharge.Trim.Length > 0, DataHelper.SmartValues(itemDetail.NinePercentWhseCharge, "decimal", True, String.Empty, 4), itemDetail.NinePercentWhseCharge)
            NinePercentWhseCharge.Value = NinePercentWhseChargeEdit.Text
            TotalWhseLandedCostEdit.Text = IIf(itemDetail.WarehouseLandedCost.Trim.Length > 0, DataHelper.SmartValues(itemDetail.WarehouseLandedCost, "decimal", True, String.Empty, 4), itemDetail.WarehouseLandedCost)
            TotalWhseLandedCost.Value = TotalWhseLandedCostEdit.Text
            TotalStoreLandedCostEdit.Text = IIf(itemDetail.TotalStoreLandedCost.Trim.Length > 0, DataHelper.SmartValues(itemDetail.TotalStoreLandedCost, "decimal", True, String.Empty, 4), itemDetail.TotalStoreLandedCost)
            TotalStoreLandedCost.Value = TotalStoreLandedCostEdit.Text
            RDBase.Text = IIf(itemDetail.RDBase.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RDBase, "decimal", True, String.Empty, 2), itemDetail.RDBase)
            RDCentralEdit.Text = IIf(itemDetail.RDCentral.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RDCentral, "decimal", True, String.Empty, 2), itemDetail.RDCentral)
            RDCentral.Value = RDCentralEdit.Text
            RDTestEdit.Text = IIf(itemDetail.RDTest.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RDTest, "decimal", True, String.Empty, 2), itemDetail.RDTest)
            RDTest.Value = RDTestEdit.Text
            RDAlaska.Text = IIf(itemDetail.RDAlaska.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RDAlaska, "decimal", True, String.Empty, 2), itemDetail.RDAlaska)
            RDCanada.Text = IIf(itemDetail.RDCanada.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RDCanada, "decimal", True, String.Empty, 2), itemDetail.RDCanada)
            RD0Thru9Edit.Text = IIf(itemDetail.RD0Thru9.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RD0Thru9, "decimal", True, String.Empty, 2), itemDetail.RD0Thru9)
            RD0Thru9.Value = RD0Thru9Edit.Text
            RDCaliforniaEdit.Text = IIf(itemDetail.RDCalifornia.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RDCalifornia, "decimal", True, String.Empty, 2), itemDetail.RDCalifornia)
            RDCalifornia.Value = RDCaliforniaEdit.Text
            RDVillageCraftEdit.Text = IIf(itemDetail.RDVillageCraft.Trim.Length > 0, DataHelper.SmartValues(itemDetail.RDVillageCraft, "decimal", True, String.Empty, 2), itemDetail.RDVillageCraft)
            RDVillageCraft.Value = RDVillageCraftEdit.Text

            If itemDetail.Retail9 <> Decimal.MinValue Then Retail9Edit.Text = DataHelper.SmartValues(itemDetail.Retail9, "formatnumber")
            Retail9.Value = Retail9Edit.Text
            If itemDetail.Retail10 <> Decimal.MinValue Then Retail10Edit.Text = DataHelper.SmartValues(itemDetail.Retail10, "formatnumber")
            Retail10.Value = Retail10Edit.Text
            If itemDetail.Retail11 <> Decimal.MinValue Then Retail11Edit.Text = DataHelper.SmartValues(itemDetail.Retail11, "formatnumber")
            Retail11.Value = Retail11Edit.Text
            If itemDetail.Retail12 <> Decimal.MinValue Then Retail12Edit.Text = DataHelper.SmartValues(itemDetail.Retail12, "formatnumber")
            Retail12.Value = Retail12Edit.Text
            If itemDetail.Retail13 <> Decimal.MinValue Then Retail13Edit.Text = DataHelper.SmartValues(itemDetail.Retail13, "formatnumber")
            Retail13.Value = Retail13Edit.Text

            'Set Quebec Retail
            If itemDetail.RDQuebec <> Decimal.MinValue Then
                RDQuebecEdit.Text = DataHelper.SmartValues(itemDetail.RDQuebec, "formatnumber")
            End If
            RDQuebec.Value = RDQuebecEdit.Text

            'Set Puerto Rico Retail
            If itemDetail.RDPuertoRico <> Decimal.MinValue Then
                RDPuertoRicoEdit.Text = DataHelper.SmartValues(itemDetail.RDPuertoRico, "formatnumber")
            End If
            RDPuertoRico.Value = RDPuertoRicoEdit.Text

            HazMatMFGCountry.Text = itemDetail.HazMatMFGCountry
            HazMatMFGName.Text = itemDetail.HazMatMFGName
            HazMatMFGCity.Text = itemDetail.HazMatMFGCity
            HazMatMFGState.Text = itemDetail.HazMatMFGState
            HazMatContainerSize.Text = itemDetail.HazMatContainerSize
            HazMatMFGPhone.Text = itemDetail.HazMatMFGPhone

            ' RMS
            RMSSellable.SelectedValue = itemDetail.RMSSellable
            RMSOrderable.SelectedValue = itemDetail.RMSOrderable
            RMSInventory.SelectedValue = itemDetail.RMSInventory

            ' New Item Approval
            If itemDetail.StoreTotal <> Integer.MinValue Then storeTotal.Text = itemDetail.StoreTotal.ToString()
            If IsDate(itemDetail.POGStartDate) AndAlso itemDetail.POGStartDate <> Date.MinValue Then POGStartDate.Text = itemDetail.POGStartDate.ToString("M/d/yyyy")
            If IsDate(itemDetail.POGCompDate) AndAlso itemDetail.POGCompDate <> Date.MinValue Then POGCompDate.Text = itemDetail.POGCompDate.ToString("M/d/yyyy")
            likeItemSKU.Text = itemDetail.LikeItemSKU
            likeItemDescriptionEdit.Text = itemDetail.LikeItemDescription
            likeItemDescription.Value = itemDetail.LikeItemDescription
            If itemDetail.LikeItemRetail <> Decimal.MinValue Then
                likeItemRetailEdit.Text = DataHelper.SmartValues(itemDetail.LikeItemRetail, "decimal", True, String.Empty, 2)
                likeItemRetail.Value = likeItemRetailEdit.Text
            End If

            'LP SPEDY Order 12
            Select Case itemDetail.CalculateOptions
                Case Integer.MinValue, 0
                    CalculateOptions.SelectedValue = 0
                Case 1
                    CalculateOptions.SelectedValue = 1
                Case 2
                    CalculateOptions.SelectedValue = 2
                Case Else
                    CalculateOptions.SelectedValue = 0
            End Select
            'me.
            'lp  review formatting!
            If itemDetail.LikeItemStoreCount <> Decimal.MinValue Then Me.likeItemStoreCount.Text = DataHelper.SmartValues(itemDetail.LikeItemStoreCount, "formatnumber")
            'If itemDetail.LikeItemRegularUnits <> Decimal.MinValue Then likeItemRegularUnits.Text = DataHelper.SmartValues(itemDetail.LikeItemRegularUnits, "formatnumber0")
            strValue = String.Empty
            'lp enable Like Item Regular Unit  saving, % no longer required
            decValue = itemDetail.LikeItemRegularUnit
            If decValue <> Decimal.MinValue Then
                'decValue = decValue * 100
                strValue = DataHelper.SmartValues(decValue, "Decimal", False, String.Empty, 0) 'round decimal to integer per cust request
            End If
            likeItemRegularUnit.Text = strValue
            'If itemDetail.LIkeItemSales <> Decimal.MinValue Then likeItemSales.Text = DataHelper.SmartValues(itemDetail.LIkeItemSales, "integer")
            If itemDetail.LikeItemUnitStoreMonth <> Decimal.MinValue Then
                calculatedLikeItemUnitStoreMonthEdit.Text = DataHelper.SmartValues(itemDetail.LikeItemUnitStoreMonth, "decimal", True, String.Empty, 2)
                calculatedLikeItemUnitStoreMonth.Value = DataHelper.SmartValues(itemDetail.LikeItemUnitStoreMonth, "decimal", True, String.Empty, 2)
            End If

            ' lp SPEDY 12 Like Item Total Retail = AnnualRegRetailSales
            If itemDetail.AnnualRegularUnitForecast <> Decimal.MinValue Then
                AnnualRegularUnitForecast.Text = DataHelper.SmartValues(itemDetail.AnnualRegularUnitForecast, "Decimal", True, String.Empty, 0) 'replaces decimal
                calculatedAnnualRegularUnitForecast.Value = DataHelper.SmartValues(itemDetail.AnnualRegularUnitForecast, "Decimal", True, String.Empty, 0) 'replaces decimal 'DataHelper.SmartValues(itemDetail.AnnualRegularUnitForecast, "decimal")
            End If
            If itemDetail.AnnualRegRetailSales <> Decimal.MinValue Then
                AnnualRegRetailSales.Value = DataHelper.SmartValues(itemDetail.AnnualRegRetailSales, "formatnumber", True, String.Empty, 2)
                AnnualRegRetailSalesEdit.Text = AnnualRegRetailSales.Value
            End If
            'AnnualRegRetailSales.Value = AnnualRegRetailSalesEdit.Text
            'lp 02-24-2009
            If itemDetail.Facings <> Decimal.MinValue Then facings.Text = DataHelper.SmartValues(itemDetail.Facings, "integer")
            If itemDetail.POGMinQty <> Decimal.MinValue Then POGMinQty.Text = DataHelper.SmartValues(itemDetail.POGMinQty, "integer")

            ' FILES
            Dim dateNow As Date = Now()
            If itemDetail.ImageID > 0 Then
                ImageID.Value = itemDetail.ImageID.ToString()
            Else
                ImageID.Value = String.Empty
            End If
            If itemDetail.MSDSID > 0 Then
                MSDSID.Value = itemDetail.MSDSID.ToString()
            Else
                MSDSID.Value = String.Empty
            End If

            ' Set Image
            ' FJL - Jan 2010 Allow clicks only if ID exists
            If itemDetail.ImageID > 0 Then
                I_Image.Attributes.Add("onclick", "showImage();")
                I_Image.Style.Add("cursor", "hand")
                I_Image.Visible = True
                I_Image.ImageUrl = "getimage.aspx?id=" & itemDetail.ImageID
                I_Image.Width = New System.Web.UI.WebControls.Unit(250)
                B_UpdateImage.Value = "Update"
            Else
                I_Image.Visible = True
                I_Image.ImageUrl = "images/app_icons/icon_jpg_small.gif"
                I_Image_Label.InnerText = "(click upload button to add Item Image)"
                B_DeleteImage.Disabled = True
            End If
            B_UpdateImage.Attributes.Add("onclick", String.Format("openUploadItemFile('{0}', '{1}', '{2}', '1');", "I", ImportDetailID, Models.ItemFileTypeHelper.GetFileTypeString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image)))
            B_DeleteImage.Attributes.Add("onclick", "return deleteImage(" & itemDetail.ID & ");")

            ' Set MSDS Sheet
            If itemDetail.MSDSID > 0 Then
                I_MSDS.Attributes.Add("onclick", "showMSDS('" & Server.UrlEncode(String.Format("importitem_{0}_{1}.pdf", itemDetail.Batch_ID, dateNow.ToString("yyyyMMdd"))) & "');")
                I_MSDS.Style.Add("cursor", "hand")
                I_MSDS.Visible = True
                I_MSDS.ImageUrl = "images/app_icons/icon_pdf_large.gif?id=" & itemDetail.MSDSID
                B_UpdateMSDS.Value = "Update"
            Else
                I_MSDS.Visible = True
                I_MSDS.ImageUrl = "images/app_icons/icon_pdf_small_off.gif"
                I_MSDS_Label.InnerText = "(click upload button to add MSDS Sheet)"
                B_DeleteMSDS.Disabled = True
            End If
            B_UpdateMSDS.Attributes.Add("onclick", String.Format("openUploadItemFile('{0}', '{1}', '{2}', '1');", "I", ImportDetailID, Models.ItemFileTypeHelper.GetFileTypeString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS)))
            B_DeleteMSDS.Attributes.Add("onclick", "return deleteMSDS(" & itemDetail.ID & ");")

            If itemDetail.Dept.Trim() <> String.Empty And _
                itemDetail.VendorNumber.Trim() <> String.Empty And _
                itemDetail.ID > 0 And _
                StageType = Models.WorkflowStageType.Vendor Then

                CanAddToBatch = True
            Else
                CanAddToBatch = False
            End If
        End If

        'GET and SET Language Information
        If itemDetail.ID > 0 Then

            PLIEnglish.SelectedValue = itemDetail.PLIEnglish
            PLIFrench.SelectedValue = itemDetail.PLIFrench
            PLISpanish.SelectedValue = itemDetail.PLISpanish

            TIEnglish.SelectedValue = itemDetail.TIEnglish
            TIFrench.SelectedValue = itemDetail.TIFrench
            TISpanish.SelectedValue = itemDetail.TISpanish

            EnglishLongDescription.Text = itemDetail.EnglishLongDescription
            EnglishShortDescription.Text = itemDetail.EnglishShortDescription
            FrenchShortDescription.Text = itemDetail.FrenchShortDescription
            FrenchLongDescription.Text = itemDetail.FrenchLongDescription
            SpanishShortDescription.Text = itemDetail.SpanishShortDescription
            SpanishLongDescription.Text = itemDetail.SpanishLongDescription
            CustomsDescription.Text = itemDetail.CustomsDescription

            ExemptEndDateFrench.Text = itemDetail.ExemptEndDateFrench

            'Per client requirements, Default English Descriptions for Pack items
            If Not String.IsNullOrEmpty(itemDetail.PackItemIndicator) Then
                If itemDetail.PackItemIndicator <> "C" Then
                    Dim englishDesc As String = "unknown pack type: " & itemDetail.PackItemIndicator
                    If itemDetail.PackItemIndicator.StartsWith("DP") Then
                        englishDesc = "Display Pack"
                    ElseIf itemDetail.PackItemIndicator.StartsWith("SB") Then
                        englishDesc = "Sellable Bundle"
                    ElseIf itemDetail.PackItemIndicator.StartsWith("D") Then
                        englishDesc = "Displayer"
                    End If
                    EnglishShortDescription.Text = englishDesc
                    EnglishLongDescription.Text = englishDesc
                End If
            End If
        Else
            'Default English - Translation Indicator to YES for New items
            TIEnglish.SelectedValue = "Y"
        End If

        ' Turn off Private Brand Copy and set default value if New record
        If itemDetail.ID <= 0 Then
            pblApplyAll.Visible = False
            PrivateBrandLabel.SelectedValue = WebConstants.LIST_VALUE_DEFAULT_PRIVATE_BRAND_LABEL
            hdnPrivateBrand.Value = PrivateBrandLabel.SelectedValue
            ' ------------------------------------------------------------------------------------------------------------------------------------
            ' FOR NEW RECORDS:
            ' Make vendor number fixed and read-only if the user is vendor and is creating an import or domestic new item batch from scratch
            ' ------------------------------------------------------------------------------------------------------------------------------------
            Dim vendorIDValue As Integer = AppHelper.GetVendorID()
            If vendorIDValue > 0 Then VendorNumber.Value = AppHelper.GetVendorID().ToString()
            Dim vendorNameValue As String = FormHelper.LookupImportVendor(vendorIDValue)
            If vendorIDValue > 0 AndAlso vendorNameValue.Trim() <> String.Empty Then ' AndAlso ValidationHelper.IsValidImportVendor(vendorIDValue) Then
                VendorNumberEdit.Visible = False
                VendorNumberLabel.Visible = True
                VendorNumberLabel.Text = vendorIDValue.ToString()
            Else
                VendorNumberEdit.Visible = True
                VendorNumberLabel.Visible = False
                If vendorIDValue > 0 Then VendorNumberEdit.Text = vendorIDValue.ToString()
            End If
            VendorName.Value = vendorNameValue
            VendorNameLabel.Text = vendorNameValue
            ' ------------------------------------------------------------------------------------------------------------------------------------
        End If

        If Not UserCanEdit Then
            ShowAddToBatch(False)
            Me.btnDuplicate.Visible = False
            'lp SPEDY order 12 Feb 2009
            Me.btnSplit.Visible = False
            'end change
            Me.btnUpdate.Visible = False
            Me.btnUpdateClose.Visible = False
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

        'Override English CFG field locking values for Display or Display Pack items.
        If itemDetail.ID > 0 Then
            If itemDetail.PackItemIndicator.StartsWith("D") Or itemDetail.PackItemIndicator.StartsWith("SB") Then
                EnglishLongDescription.RenderReadOnly = True
                EnglishShortDescription.RenderReadOnly = True
            End If
        End If

        ' custom fields
        If ReadOnlyForm Then Me.custFields.RenderReadOnly = True
        Me.custFields.RecordType = Me.RecordType
        Me.custFields.RecordID = DataHelper.SmartValues(Me.ItemID, "long", False)
        Me.custFields.DisplayTemplate = "<tr><td class=""formLabel"" style=""text-align: right; white-space:nowrap;"">##NAME##:</td><td class=""formField"">##VALUE##</td></tr>"
        Me.custFields.Columns = 40
        Me.custFields.LoadCustomFields(True)

        itemFL = Nothing
        ' FJL
        If IsPack AndAlso Not IsNew AndAlso UserCanEdit Then
            lnkAddExisting.Visible = True
            lnkAddExisting.Attributes.Add("onclick", "AddSKUtoBatch('" & BatchID.ToString & "')")
            lnkAddExistingSep.Visible = True
        Else
            lnkAddExisting.Visible = False
            lnkAddExistingSep.Visible = False
        End If

    End Sub

    Private Sub SetFormReadOnly()
        Dim mdColumns As Hashtable
        Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
        Dim mdTable As NovaLibra.Coral.SystemFrameworks.MetadataTable

        mdTable = md.GetTableByID(Models.MetadataTable.Import_Items)
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
        For Each col As Models.MetadataColumn In itemFL.Columns
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
        Dim sp As String = "&nbsp;"
        colName = Trim(colName)

        Select Case UCase(permission)
            Case "N"            ' -------  Hide Data for Column 
                Select Case colName
                    Case "Additional_UPC"
                        Me.AdditionalUPCFL.Attributes.Add("style", "display:none")
                        Me.additionalUPCParent.Attributes.Add("style", "display:none")

                    Case "Vendor"
                        Me.VendorAgentFL.Attributes.Add("style", "display:none")
                        Me.VendorAgent.Visible = False
                        Me.AgentType.Visible = False

                    Case "PrimaryUPC"
                        Me.PrimaryUPCFL.Attributes.Add("style", "display:none")
                        Me.PrimaryUPC.Visible = False
                        Me.GenerateMichaelsUPCLabel.Visible = False
                        Me.GenerateMichaelsUPC.Visible = False

                    Case "DetailInvoiceCustomsDesc"
                        Me.DetailInvoiceCustomsDescFL.Attributes.Add("style", "display:none")
                        Me.DetailInvoiceCustomsDesc1.Visible = False
                        Me.DetailInvoiceCustomsDesc2.Visible = False
                        Me.DetailInvoiceCustomsDesc3.Visible = False
                        Me.DetailInvoiceCustomsDesc4.Visible = False
                        Me.DetailInvoiceCustomsDesc5.Visible = False
                        Me.DetailInvoiceCustomsDesc6.Visible = False

                    Case "ComponentMaterialBreakdown"
                        Me.ComponentMaterialBreakdownFL.Attributes.Add("style", "display:none")
                        Me.ComponentMaterialBreakdown1.Visible = False
                        Me.ComponentMaterialBreakdown2.Visible = False
                        Me.ComponentMaterialBreakdown3.Visible = False
                        Me.ComponentMaterialBreakdown4.Visible = False
                        Me.ComponentMaterialBreakdown5.Visible = False

                    Case "ComponentConstructionMethod"
                        Me.ComponentConstructionMethodFL.Attributes.Add("style", "display:none")
                        Me.ComponentConstructionMethod1.Visible = False
                        Me.ComponentConstructionMethod2.Visible = False
                        Me.ComponentConstructionMethod3.Visible = False
                        Me.ComponentConstructionMethod4.Visible = False

                    Case "ReshippableInnerCartonLength", "ReshippableInnerCartonWidth", "ReshippableInnerCartonHeight"
                        Me.ReshippableInnerCartonFLParent.Attributes.Add("style", "display:none")
                        Me.ReshippableInnerCartonParent.Attributes.Add("style", "display:none")

                    Case "MasterCartonDimensionsLength", "MasterCartonDimensionsWidth", "MasterCartonDimensionsHeight"
                        Me.MasterCartonDimensionsFLParent.Attributes.Add("style", "display:none")
                        Me.MasterCartonDimensionsParent.Attributes.Add("style", "display:none")

                    Case "AdditionalDutyComment"
                        Me.AdditionalDutyFL.Visible = False
                        Me.AdditionalDutyComment.Visible = False

                    Case "AdditionalDutyAmount"
                        Me.AdditionalDutyFL.Visible = False
                        Me.AdditionalDutyAmount.Visible = False

                    Case "PurchaseOrderIssuedTo"
                        Me.PurchaseOrderIssuedToFL.Attributes.Add("style", "display:none")
                        Me.PurchaseOrderIssuedTo1.Visible = False
                        Me.PurchaseOrderIssuedTo2.Visible = False
                        Me.PurchaseOrderIssuedTo3.Visible = False

                    Case "CountryOfOrigin", "CountryOfOriginName"
                        Me.CountryOfOriginFL.InnerHtml = sp
                        Me.CountryOfOriginParent.Visible = False

                    Case "Tax_Wizard"
                        Me.taxWizardFL.Attributes.Add("style", "display:none")
                        Me.taxWizardParent.Attributes.Add("style", "display:none")

                    Case "FOBShippingPoint"     '???
                        Me.FirstCostFL.Attributes.Add("style", "display:none")
                        Me.FirstCostParent.Visible = False
                        Me.FOBShippingPointFL.Attributes.Add("style", "display:none")
                        Me.FOBShippingPointParent.Attributes.Add("style", "display:none")

                    Case "WarehouseLandedCost"
                        Me.WarehouseLandedCostFL.Attributes.Add("style", "display:none")
                        Me.WarehouseLandedCostParent.Attributes.Add("style", "display:none")
                        Me.TotalWhseLandedCostFL.Attributes.Add("style", "display:none")
                        Me.TotalWhseLandedCostParent.Attributes.Add("style", "display:none")

                    Case "Calculate_Options"
                        CalculateOptionsFL.Attributes.Add("style", "display:none")
                        CalculateOptions.Visible = False
                        CalculateOptions.Attributes.Add("style", "display:none")

                    Case "TotalImportBurden"
                        Me.StoreTotalImportBurdenFL.Attributes.Add("style", "display:none")
                        Me.StoreTotalImportBurdenParent.Attributes.Add("style", "display:none")
                        Me.TotalImportBurdenFL.Attributes.Add("style", "display:none")
                        Me.TotalImportBurdenParent.Attributes.Add("style", "display:none")

                    Case "HazMatNo", "HazMatYes", "HazMatYesNo"
                        HazMatParent.Visible = False
                        P_HazMat.Visible = False

                    Case "Annual_Regular_Unit_Forecast"     ' RegUnitForecast >> AnnualRegularUnitForecast 
                        AnnualRegularUnitForecastFL.Attributes.Add("style", "display:none")
                        AnnualRegularUnitForecastParent.Attributes.Add("style", "display:none")

                    Case "Like_Item_Unit_Store_Month", "LikeItemUnitStoreMonth"      ' UnitsStoreMonth >> LikeItemUnitStoreMonth
                        calculatedLikeItemUnitStoreMonthFL.Attributes.Add("style", "display:none")
                        calculatedLikeItemUnitStoreMonthParent.Attributes.Add("style", "display:none")

                    Case "Annual_Reg_Retail_Sales"
                        AnnualRegRetailSalesFL.Attributes.Add("style", "display:none")
                        AnnualRegRetailSalesParent.Attributes.Add("style", "display:none")

                    Case "MSDS_ID"
                        Image_IDFL.Attributes.Add("style", "display:none")

                    Case "Image_ID", "Image_ID"
                        MSDS_IDFL.Attributes.Add("style", "display:none")

                    Case Else   ' Find control by name and hide it
                        MyBase.Lockfield(colName, permission)

                End Select ' Column

            Case "V"            ' -------  View only of Column data
                Select Case colName
                    Case "Additional_UPC"
                        Me.additionalUPCs.Text = Me.additionalUPCValues.Value.Replace(",", "<br />") & "&nbsp;"
                        Me.additionalUPCLink.Visible = False
                    Case "Vendor"
                        Me.VendorAgent.RenderReadOnly = True
                        Me.Agent.RenderReadOnly = True
                    Case "DetailInvoiceCustomsDesc"
                        Me.DetailInvoiceCustomsDesc1.RenderReadOnly = True
                        Me.DetailInvoiceCustomsDesc2.RenderReadOnly = True
                        Me.DetailInvoiceCustomsDesc3.RenderReadOnly = True
                        Me.DetailInvoiceCustomsDesc4.RenderReadOnly = True
                        Me.DetailInvoiceCustomsDesc5.RenderReadOnly = True
                        Me.DetailInvoiceCustomsDesc6.RenderReadOnly = True
                    Case "ComponentMaterialBreakdown"
                        Me.ComponentMaterialBreakdown1.RenderReadOnly = True
                        Me.ComponentMaterialBreakdown2.RenderReadOnly = True
                        Me.ComponentMaterialBreakdown3.RenderReadOnly = True
                        Me.ComponentMaterialBreakdown4.RenderReadOnly = True
                        Me.ComponentMaterialBreakdown5.RenderReadOnly = True
                    Case "ComponentConstructionMethod"
                        Me.ComponentConstructionMethod1.RenderReadOnly = True
                        Me.ComponentConstructionMethod2.RenderReadOnly = True
                        Me.ComponentConstructionMethod3.RenderReadOnly = True
                        Me.ComponentConstructionMethod4.RenderReadOnly = True
                    Case "PurchaseOrderIssuedTo"
                        Me.PurchaseOrderIssuedToFL.Attributes.Add("style", "display:none")
                        Me.PurchaseOrderIssuedTo1.Visible = False
                        Me.PurchaseOrderIssuedTo2.Visible = False
                        Me.PurchaseOrderIssuedTo3.Visible = False
                    Case "CountryOfOrigin", "CountryOfOriginName"
                        Me.CountryOfOriginName.RenderReadOnly = True
                    Case "Tax_Wizard"
                        If taxWizardComplete.Value = "1" Then
                            taxWizard.ImageUrl = "images/checkbox_true_disabled.gif"
                        Else
                            taxWizard.ImageUrl = "images/checkbox_false_disabled.gif"
                        End If
                        taxWizardLink.Attributes.Remove("onclick")
                        taxWizardLink.Attributes.Add("onclick", "return false;")
                        taxWizardSALink.Visible = False

                    Case "FOBShippingPoint"
                        FirstCostEdit.RenderReadOnly = True
                        FOBShippingPointEdit.RenderReadOnly = True

                    Case "TotalImportBurden"
                        StoreTotalImportBurdenEdit.RenderReadOnly = True
                        TotalImportBurdenEdit.RenderReadOnly = True

                    Case "WarehouseLandedCost"
                        TotalWhseLandedCostEdit.RenderReadOnly = True
                        WarehouseLandedCostEdit.RenderReadOnly = True

                    Case "Calculate_Options"
                        CalculateOptions.RenderReadOnly = True

                    Case "HazMatNo", "HazMatYes", "HazMatYesNo"
                        HazMatYes.RenderReadOnly = True
                        HazMatNo.RenderReadOnly = True

                    Case "Annual_Regular_Unit_Forecast", "AnnualRegularUnitForecast"
                        AnnualRegularUnitForecast.RenderReadOnly = True

                    Case "MSDS_ID"
                        Me.B_UpdateMSDS.Disabled = True
                        Me.B_DeleteMSDS.Disabled = True

                    Case "Image_ID", "Image_ID"
                        Me.B_UpdateImage.Disabled = True
                        Me.B_DeleteImage.Disabled = True

                    Case "Private_Brand_Label"
                        PrivateBrandLabel.RenderReadOnly = True
                        pblApplyAll.Visible = False

                    Case "Like_Item_Unit_Store_Month", "LikeItemUnitStoreMonth"
                        calculatedLikeItemUnitStoreMonthEdit.RenderReadOnly = True

                    Case Else   ' Find By ID for View
                        MyBase.Lockfield(colName, permission)

                End Select

            Case Else   'edit

        End Select ' Permission
    End Sub

    Private Sub PostBackSetupFields()

        If Agent.SelectedValue = "YES" Then
            'if the AgentCommissionPercent and RecAgentCommissionPercent match then don't show recommended value
            If RecAgentCommissionPercent.Text = AgentCommissionPercent.Text Then
                Me.RecagentCommissionRow.Attributes("class") = "hideElement"
            End If
        End If

    End Sub

    Private Sub SetupFields()

        'Show appropriate panels depending on selected value
        If HazMatYes.SelectedValue = "X" Then
            HazMatNo.SelectedValue = ""
            P_HazMat.Visible = True
        Else
            HazMatNo.SelectedValue = "X"
        End If

        If Agent.SelectedValue = "YES" Then
            L_Contact.Text = "Contact:"
            tMan1.Visible = True
            tMan2.Visible = True
            tMan3.Visible = True
            tAgent1.Visible = True
            tAgent2.Visible = True
            tAgent3.Visible = True
            tAgent4.Visible = True
            'P_Manufacture.Visible = True
            'P_Agent.Visible = True
            'GenerateMichaelsUPC.Visible = True
            Me.agentCommissionRow.Attributes("class") = ""
            Me.RecagentCommissionRow.Attributes("class") = ""

            'if the AgentCommissionPercent and RecAgentCommissionPercent match then don't show recommended value
            If RecAgentCommissionPercent.Text = AgentCommissionPercent.Text Then
                Me.RecagentCommissionRow.Attributes("class") = "hideElement"
            End If
        Else
            AgentType.Visible = False
            L_Contact.Text = "US Contact Name:"
            'GenerateMichaelsUPC.Visible = False
            Me.agentCommissionRow.Attributes("class") = "hideElement"
            Me.RecagentCommissionRow.Attributes("class") = "hideElement"
        End If

        If PrivateBrandLabel.SelectedValue = "" Or PrivateBrandLabel.SelectedValue = "12" Then  'no private brand
            GenerateMichaelsUPC.Visible = False
            GenerateMichaelsGTIN14.Visible = False 'PMO200141 GTIN14 Enhancements changes
        Else
            GenerateMichaelsUPC.Visible = True
            GenerateMichaelsGTIN14.Visible = True   'PMO200141 GTIN14 Enhancements changes
        End If

        If StageType = Models.WorkflowStageType.DBC Then
            StoreSuppZoneGRP.ReadOnly = False
            WhseSuppZoneGRP.ReadOnly = False
        End If

        StockCategory.Text = "W"
        FreightTerms.Text = "PREPAID"
        If IsNew Then
            Me.StoreSuppZoneGRP.Text = "1"
            Me.WhseSuppZoneGRP.Text = "1"
            linkExcel.Visible = False
            Dim dateNow As Date = Now()
            Me.DateSubmitted.Text = dateNow.ToString("M/d/yyyy")
            Me.OtherImportCostsPercent.Value = "2"
            Me.OtherImportCostsPercentEdit.Text = "2"
        End If

        'NAK 12/4/2012:  Per Michaels, these fields should be editable to DBC/QA
        If StageType <> Models.WorkflowStageType.Tax And StageType <> Models.WorkflowStageType.DBC Then
            ' FJL 
            TaxUDA.RenderReadOnly = True
            TaxValueUDA.RenderReadOnly = True
            '    Me.TaxUDA.Style.Add("visibility", "hidden")
            '    Me.TaxUDA.Style.Add("display", "none")
            '    Me.TaxValueUDA.Style.Add("visibility", "hidden")
            '    Me.TaxValueUDA.Style.Add("display", "none")
            'Else
            '    Me.TaxUDALabel.Visible = False
            '    Me.TaxValueUDALabel.Visible = False
        End If

        If IsNew Then
            Me.btnDuplicate.Visible = False
            'LP SPEDY Order 12 change
            Me.btnSplit.Visible = False
            'LP
            childItemsDetail.Visible = False
        End If

        ShowAddToBatch(False)

    End Sub

    Private Sub InitChildDropDown()
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
        Dim pid As Long
        Dim childList As ArrayList = Nothing
        Dim objChild As Models.ImportItemChildRecord
        Dim i As Integer
        Dim QRN As String
        IsPack = data.ImportItemDetail.IsPack(Me.BatchID)

        If ParentID > 0 OrElse ImportDetailID > 0 Then
            If ParentID > 0 Then pid = ParentID Else pid = ImportDetailID
            childList = objMichaels.GetChildItems(pid, False)
            QRN = objMichaels.GetRecord(pid).QuoteReferenceNumber.ToString()
            objMichaels = Nothing
            childItems.Items.Clear()    ' Always clear since this could be a post back from a new SKU added

            If childList.Count > 0 Then
                childItemsDetail.Visible = True
                'IsPack = True
                MultipleItems = True

                If IsRegularBatchItem Then
                    lblPackItemList.Text = "Items: "
                    childItems.Items.Add(New ListItem("Item 1 (" & QRN & ")", pid.ToString()))
                    For i = 0 To childList.Count - 1
                        objChild = CType(childList(i), Models.ImportItemChildRecord)
                        Dim objChildRecord As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
                        QRN = objChildRecord.GetRecord(objChild.ID).QuoteReferenceNumber.ToString

                        childItems.Items.Add(New ListItem("Item " & i + 2 & " (" & QRN & ")", objChild.ID.ToString()))
                    Next
                Else
                    lblPackItemList.Text = "Child / Pack Items: "
                    'childItems.Items.Add(New ListItem("Import Quote Sheet (" & BatchID.ToString() & ")", pid.ToString()))
                    childItems.Items.Add(New ListItem("Parent (" & QRN & ")", pid.ToString()))
                    For i = 0 To childList.Count - 1
                        objChild = CType(childList(i), Models.ImportItemChildRecord)
                        Dim objChildRecord As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
                        QRN = objChildRecord.GetRecord(objChild.ID).QuoteReferenceNumber.ToString

                        childItems.Items.Add(New ListItem("Child " & i + 1 & " (" & QRN & ")", objChild.ID.ToString()))
                        'childItems.Items.Add(New ListItem("Child " & i + 1, objChild.ID.ToString()))
                    Next
                End If

                childItems.SelectedValue = ImportDetailID.ToString()
                'LP SPEDY Change order 12
                If childItems.SelectedIndex > 0 AndAlso StageType = Models.WorkflowStageType.Vendor Then
                    'only show remove button for Vendor/CAA stage per Michelle Feb 2009
                    Me.btnSplit.Visible = True
                Else
                    Me.btnSplit.Visible = False
                End If
                'LP    do it twice, something is broken
                'childItems.SelectedValue = ImportDetailID.ToString()
                childItems.Attributes.Add("onchange", "childItemsChanged(this);")
            Else
                ' no child items
                Me.CalculateOptions.Enabled = True 'LP Spedy 12
                Me.storeTotal.Enabled = True
                Me.POGStartDate.Enabled = True
                Me.POGCompDate.Enabled = True
                childItemsDetail.Visible = False
                'IsPack = False
                MultipleItems = False
                'LP SPEDY Change order 12
                Me.btnSplit.Visible = False
                'LP
            End If
        Else
            'IsPack = False
            MultipleItems = False
        End If

        If Not childList Is Nothing Then
            Do While childList.Count > 0
                childList.RemoveAt(0)
            Loop
            childList = Nothing
        End If

    End Sub

    Private Sub InitControls()
        ' init controls
        ' -------------

        ' linkExcel
        If ItemID <> String.Empty Then
            If ParentID <= 0 Then
                linkExcel.NavigateUrl = "importexport.aspx?hid=" & ItemID()
            Else
                linkExcel.NavigateUrl = "importexport.aspx?hid=" & ParentID.ToString()
            End If
        Else
            linkExcel.Visible = False
        End If

        pblApplyAll.Attributes.Add("onclick", "VerifyUpdatePBLforBatch();")

        PackItemIndicator.Attributes.Add("onchange", "PackItemIndicatorChanged();")

        EachHeight.Attributes.Add("onchange", "eachCaseChanged();")
        EachWidth.Attributes.Add("onchange", "eachCaseChanged();")
        EachLength.Attributes.Add("onchange", "eachCaseChanged();")

        ' cubic feet per inner carton
        ReshippableInnerCartonHeight.Attributes.Add("onchange", "innerCaseChanged();")
        ReshippableInnerCartonWidth.Attributes.Add("onchange", "innerCaseChanged();")
        ReshippableInnerCartonLength.Attributes.Add("onchange", "innerCaseChanged();")
        'Dim icpc As String = CalculationHelper.CalculateItemCasePackCube(ReshippableInnerCartonWidth.Text, _
        '    ReshippableInnerCartonHeight.Text, _
        '    ReshippableInnerCartonLength.Text, _
        '    "")
        'If icpc <> CubicFeetPerInnerCarton.Value Then
        '    CubicFeetPerInnerCartonEdit.Text = icpc
        '    CubicFeetPerInnerCarton.Value = icpc
        'End If

        ' cubic feet per master carton
        MasterCartonDimensionsHeight.Attributes.Add("onchange", "calculateEstLandedCost('mcheight');")
        MasterCartonDimensionsWidth.Attributes.Add("onchange", "calculateEstLandedCost('mcwidth');")
        MasterCartonDimensionsLength.Attributes.Add("onchange", "calculateEstLandedCost('mclength');")
        'Dim mcpc As String = CalculationHelper.CalculateItemCasePackCube(MasterCartonDimensionsWidth.Text, _
        '    MasterCartonDimensionsHeight.Text, _
        '    MasterCartonDimensionsLength.Text, _
        '    "")
        'If mcpc <> CubicFeetPerMasterCarton.Value Then
        '    CubicFeetPerMasterCartonEdit.Text = mcpc
        '    CubicFeetPerMasterCarton.Value = mcpc
        '    CreateStartupScriptForCalc(String.Empty)
        'End If

        ' ocean freight
        'Me.EachInsideMasterCaseBox.Attributes.Add("onchange", "calculateOceanFreight();")
        'Me.OceanFreightAmount.Attributes.Add("onchange", "calculateOceanFreight();")

        ' estimated landed cost and store
        Me.DisplayerCost.Attributes.Add("onchange", "calculateEstLandedCost('dispcost');")
        Me.ProductCost.Attributes.Add("onchange", "calculateEstLandedCost('prodcost');")
        'Me.FOBShippingPoint.Attributes.Add("onchange", "calculateEstLandedCost('fob');")
        Me.DutyPercent.Attributes.Add("onchange", "calculateEstLandedCost('dutyper');")
        Me.AdditionalDutyAmount.Attributes.Add("onchange", "calculateEstLandedCost('addduty');")

        Me.SuppTariffPercent.Attributes.Add("onchange", "calculateEstLandedCost('supptariffper');")

        Me.EachInsideMasterCaseBox.Attributes.Add("onchange", "calculateEstLandedCost('eachesmc');")
        ' mclength completed above
        ' mcwidth completed above
        ' mcheight completed above
        Me.OceanFreightAmount.Attributes.Add("onchange", "calculateEstLandedCost('oceanfre');")
        Me.AgentCommissionPercent.Attributes.Add("onchange", "calculateEstLandedCost('agentcommper');")
        ' otherimportper never changes !!
        'If Me.OtherImportCostsPercent.Value <> "2" Then
        '    Me.OtherImportCostsPercent.Value = "2"
        '    Me.OtherImportCostsPercentEdit.Text = "2"
        '    CreateStartupScriptForCalc(String.Empty)
        'End If
        'Me.PackagingCostAmount.Attributes.Add("onchange", "calculateEstLandedCost('packcost');")

        'Me.LeadTime.Attributes.Add("onchange", "leadTimeChanged();")

        Me.PrePriced.Attributes.Add("onchange", "baseRetailChanged('prepriced');")
        Me.RDBase.Attributes.Add("onchange", "baseRetailChanged('baseretail');")
        Me.RDAlaska.Attributes.Add("onchange", "alaskaRetailChanged();")
        Me.RDCanada.Attributes.Add("onchange", "canadaRetailChanged();")

        ' Tax
        ' Special case for Tax wizard. FL might have it read only (it already has an attribute)
        If taxWizardLink.Attributes.Item("onclick") Is Nothing Then
            Me.taxWizardLink.Attributes.Add("onclick", "openTaxWizard('" & ItemID & "'); return false;")
        End If
        Me.taxWizardSALink.Attributes.Add("onclick", "openTaxWizardSA('" & ItemID & "', '" & BatchID & "'); return false;")
        Me.TaxUDA.Attributes.Add("onchange", "taxUDAChanged();")
        Me.TaxValueUDA.Attributes.Add("onchange", "taxValueUDAChanged();")

        ' Country of Origin
        'Me.CountryOfOriginName.Attributes.Add("onchange", "countryOfOriginChanged();")

        ' New Item Approval
        Me.likeItemSKU.Attributes.Add("onchange", "likeItemSKUChanged();")

        'lp SPEDY 12 total retail = * of Like ItemRetail and like item sales, SPEDY change order 12
        'Me.likeItemSKU.Attributes.Add("onblur", "CalculateTotalRetal();")
        'Me.likeItemRetailEdit.Attributes.Add("onchange", "CalculateTotalRetail();")
        'Me.likeItemSales.Attributes.Add("onblur", "CalculateTotalRetail();")
        'lp
        Me.storeTotal.Attributes.Add("onchange", "StoreTotalChanged();")
        'Me.AnnualRegularUnitForecast.Attributes.Add("onchange", "CalculateUnitStoreMonth();")
        Me.AnnualRegularUnitForecast.Attributes.Add("onblur", "CalculateUnitStoreMonth();")

        Me.AnnualRegularUnitForecast.Attributes.Add("disabled", "disabled")
        Me.calculatedLikeItemUnitStoreMonthEdit.Attributes.Add("disabled", "disabled")

        Me.CalculateOptions.Attributes.Add("onchange", "CalculateOptionsChanged();")
        'Me.calculatedLikeItemUnitStoreMonthEdit.Attributes.Add("onchange", "CalculateRegularForecast();")
        Me.calculatedLikeItemUnitStoreMonthEdit.Attributes.Add("onblur", "CalculateRegularForecast();")
        Me.RDBase.Attributes.Add("onblur", "CalculateTotalRetail();")

        Me.POGMaxQty.Attributes.Add("onkeydown", "return SetInteger(event);")
        Me.POGSetupPerStore.Attributes.Add("onkeydown", "return SetInteger(event);")
        Me.POGMinQty.Attributes.Add("onkeydown", "return SetInteger(event);")
        Me.AnnualRegularUnitForecast.Attributes.Add("onkeydown", "return SetInteger(event);")
        Me.likeItemRegularUnit.Attributes.Add("onkeydown", "return SetInteger(event);")
        Me.facings.Attributes.Add("onkeydown", "return SetInteger(event);")

        'lp change order 14
        Me.RDCaliforniaEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDCalifornia');")
        Me.RDCentralEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDCentral');")
        Me.RDTestEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDTest');")
        Me.RDVillageCraftEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDVillageCraft');")
        Me.RD0Thru9Edit.Attributes.Add("onchange", "SetHiddenFieldValue('RD0Thru9');")
        Me.Retail9Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail9');")
        Me.Retail10Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail10');")
        Me.Retail11Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail11');")
        Me.Retail12Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail12');")
        Me.Retail13Edit.Attributes.Add("onchange", "SetHiddenFieldValue('Retail13');")
        Me.RDQuebecEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDQuebec');")
        Me.RDPuertoRicoEdit.Attributes.Add("onchange", "SetHiddenFieldValue('RDPuertoRico');")
        Me.RDCanada.Attributes.Add("onchange", "calculateIMUPercent('RDCanada');")

        ' init the duplicate item controls
        ' --------------------------------
        InitChildDropDown()

        ' Set the dirty js
        ' --------------------------------
        'Me.PlanogramName.Attributes.Add("onKeyPress", "setIsDirty(1);")
        AddIsDirty(Page)

        ' init the Add to Batch controls
        ' ------------------------------
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
        Dim addList As ArrayList = Nothing
        If ImportDetailID > 0 Then
            addToBatchID.Value = ImportDetailID.ToString()
            addList = objMichaels.GetAddToBatchRecords(ImportDetailID)
            For Each ar As Models.ImportItemAddToBatchRecord In addList
                addToBatchList.Items.Add(New ListItem(("Batch: " & ar.BatchID.ToString() & " (" & ar.ItemCount & " items)"), ar.BatchID.ToString()))
            Next
            If addList.Count > 0 Then
                addToBatchList.Items.Insert(0, New ListItem("-- Select --", ""))
            End If
        End If
        If Not addList Is Nothing Then
            addList.Clear()
            addList = Nothing
        End If

        If MultipleItems And ParentID > 0 Then
            Me.CalculateOptions.Enabled = False 'lp Spedy 12
            Me.storeTotal.Enabled = False
            Me.POGStartDate.Enabled = False
            Me.POGCompDate.Enabled = False
            CubicFeetPerMasterCartonEdit.ReadOnly = False
            CubicFeetPerMasterCartonEdit.CssClass = ""
            CubicFeetPerMasterCartonEdit.Attributes.Add("onchange", "cubicFeetPerMasterCartonChanged();")
            _isCFPMCCalc = False
        Else
            Me.CalculateOptions.Enabled = True 'lp Spedy Change Order 12
            Me.storeTotal.Enabled = True
            Me.POGStartDate.Enabled = True
            Me.POGCompDate.Enabled = True
        End If

        objMichaels = Nothing

    End Sub

    Private Sub AddIsDirty(ByVal oCtrl As Control)
        For Each ctrl As Control In oCtrl.Controls
            'NAK: 8/25/2011 Ignore TaxUDA changes and PrivateBrandLabel changes.  These should not flag the Item as Dirty.
            If Not (ctrl.ID = "TaxUDA") And Not (ctrl.ID = "PrivateBrandLabel") And Not (ctrl.ID = "SubClass") And Not (ctrl.ID = "Buyer") And Not (ctrl.ID = "Class") And Not (ctrl.ID = "TIEnglish") And Not (ctrl.ID = "TIFrench") And Not (ctrl.ID = "TISpanish") Then
                If TypeOf ctrl Is TextBox Then
                    Dim tb As TextBox = CType(ctrl, TextBox)
                    tb.Attributes.Add("onKeyPress", "setIsDirty(1, '" & ctrl.ID & "');")
                ElseIf TypeOf ctrl Is DropDownList And ctrl.ID <> "PackItemIndicator" And ctrl.ID <> "CalculateOptions" And ctrl.ID <> "childItems" And ctrl.ID <> "PrePriced" Then
                    Dim ddl As DropDownList = CType(ctrl, DropDownList)
                    ddl.Attributes.Add("onChange", "setIsDirty(1, '" & ctrl.ID & "');")
                End If
            End If

            If ctrl.HasControls Then
                AddIsDirty(ctrl)
            End If
        Next
    End Sub

    Private Sub InitializeValidation()

        'Setup the validation summary
        ValidationHelper.SetupValidationSummary(V_Summary)

        Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
        Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(BatchID)


        'Save Validation State
        If batchDetail.ID > 0 Then

            'Data Type Validation
            Page.Validate()

            'Perform Logical Validation
            PerformStageValidation(UserCanEdit, True)

        End If

        objMichaelsBatch = Nothing

    End Sub


    Private Function SaveForm(ByVal isValid As Boolean) As Long
        Return SaveForm(isValid, False)
    End Function

    Private Function SaveForm(ByVal isValid As Boolean, ByVal setRegularItem As Boolean) As Long

        Dim resetParent As Boolean = False

        Dim itemDetail As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord

        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()

        'Load existing record
        If ImportDetailID > 0 Then
            itemDetail = objMichaels.GetRecord(ImportDetailID)
            itemDetail.SetupAudit(NovaLibra.Coral.SystemFrameworks.Michaels.MetadataTable.Import_Items, itemDetail.ID, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, UserID)
        Else
            itemDetail = New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
            itemDetail.SetupAudit(NovaLibra.Coral.SystemFrameworks.Michaels.MetadataTable.Import_Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Insert, UserID)
        End If

        'Before loading form values, determine if the item's Pack Item Indicator is being reset from non-parent to parent
        If Not itemDetail.IsPackParent And (PackItemIndicator.SelectedValue.StartsWith("D") Or PackItemIndicator.SelectedValue.StartsWith("SB")) Then
            setRegularItem = False
            resetParent = True
        End If
        'Before loading form values, determine if the item's Pack Item Indicator is being reset from Parent to non-parent
        If itemDetail.IsPackParent And Not (PackItemIndicator.SelectedValue.StartsWith("D") Or PackItemIndicator.SelectedValue.StartsWith("SB")) Then
            setRegularItem = True
            resetParent = True
        End If

        'Load form values into record
        itemDetail.TrackChanges()
        LoadFormValuesIntoRecWFormat(itemDetail)

        ' IF HAZMAT_NO = "X" THEN CLEAR THE HAZMAT FIELDS
        If itemDetail.HazMatNo = "X" Or itemDetail.HazMatYes = String.Empty Then
            itemDetail.HazMatMFGName = String.Empty
            itemDetail.HazMatMFGCity = String.Empty
            itemDetail.HazMatMFGState = String.Empty
            itemDetail.HazMatMFGPhone = String.Empty
            itemDetail.HazMatMFGCountry = String.Empty
            itemDetail.HazMatMFGFlammable = String.Empty
            itemDetail.HazMatContainerType = String.Empty
            itemDetail.HazMatContainerSize = String.Empty
            itemDetail.HazMatMSDSUOM = String.Empty
        End If

        ' regular item ???
        If setRegularItem Then
            itemDetail.RegularBatchItem = True
        End If

        ' FJL Mar 2010 - Check to see if Private Label info should be saved in all records in batch
        Dim itemID As Long = 0
        If hdnPBLApplyAll.Value = "1" Then  '  Only Update Private Brand Label for all records in batch
            objMichaels.ApplyPBLToAll(itemDetail, UserID)
            PerformStageValidation(True, True)
        Else
            'Make sure the item is set as the Parent, and that the batch is not Regular
            If itemDetail.IsPackParent Then
                itemDetail.ParentID = 0
                itemDetail.RegularBatchItem = False
            End If

            If itemDetail.ID > 0 Then
                itemID = objMichaels.SaveRecord(DataHelper.SmartValues(Me.dirtyFlag.Value, "boolean"), itemDetail, UserID)
            Else
                itemID = objMichaels.SaveRecord(itemDetail, UserID, True, "Created", String.Empty, DataHelper.SmartValues(Me.dirtyFlag.Value, "boolean"))
            End If

            'Per client requirements, Default English Descriptions for Pack items
            If Not String.IsNullOrEmpty(itemDetail.PackItemIndicator) Then
                If itemDetail.PackItemIndicator <> "C" Then
                    Dim englishDesc As String = "unknown pack type: " & itemDetail.PackItemIndicator
                    If itemDetail.PackItemIndicator.StartsWith("DP") Then
                        englishDesc = "Display Pack"
                    ElseIf itemDetail.PackItemIndicator.StartsWith("SB") Then
                        englishDesc = "Sellable Bundle"
                    ElseIf itemDetail.PackItemIndicator.StartsWith("D") Then
                        englishDesc = "Displayer"
                    End If
                    EnglishShortDescription.Text = englishDesc
                    EnglishLongDescription.Text = englishDesc
                End If
            End If

            'NAK 4/10/2013:  Per Michaels new requirements, default TI to 'Y' for English and French.
            If (itemDetail.TIEnglish = "") Then
                itemDetail.TIEnglish = "Y"
            End If
            If (itemDetail.TIFrench = "") Then
                itemDetail.TIFrench = "Y"
            End If

            'NAK:  Per client requirements, default TI Spanish field to NO if not set (TI Spanish should always be No, unless this is a new Record)
            If String.IsNullOrEmpty(TISpanish.SelectedValue) Then
                TISpanish.SelectedValue = "N"
            End If

            'Save Language Information
            data.ImportItemDetail.SaveImportItemLanguage(itemID, 1, PLIEnglish.SelectedValue, TIEnglish.SelectedValue, EnglishShortDescription.Text, Left(EnglishLongDescription.Text, 100), UserID)
            data.ImportItemDetail.SaveImportItemLanguage(itemID, 2, PLIFrench.SelectedValue, TIFrench.SelectedValue, FrenchShortDescription.Text, FrenchLongDescription.Text, UserID)
            data.ImportItemDetail.SaveImportItemLanguage(itemID, 3, PLISpanish.SelectedValue, TISpanish.SelectedValue, SpanishShortDescription.Text, SpanishLongDescription.Text, UserID)

            If PLIEnglish_Dirty.Value = 1 Then
                data.ImportItemDetail.SaveEditedLanguage(itemID, 1)
            End If
            If PLIFrench_Dirty.Value = 1 Then
                data.ImportItemDetail.SaveEditedLanguage(itemID, 2)
            End If
            If PLISpanish_Dirty.Value = 1 Then
                data.ImportItemDetail.SaveEditedLanguage(itemID, 3)
            End If

            'Loop through batch items, and make changes based on parent settings
            Dim objMichaels2 As New NovaLibra.Coral.Data.Michaels.ImportItemDetail()
            Dim batchItems As Models.ImportItemList = objMichaels2.GetItemList(BatchID)
            For i As Integer = 0 To batchItems.ListRecords.Count - 1
                'Re-Get Item record, because the GetItemList does not get all item fields.  (TODO: Fix this someday...)
                Dim batchItem As Models.ImportItemRecord = objMichaels.GetRecord(CType(batchItems.ListRecords(i), Models.ImportItemRecord).ID)
                If batchItem.ID <> itemDetail.ID And String.IsNullOrEmpty(batchItem.MichaelsSKU) Then

                    If resetParent Then
                        If setRegularItem Then
                            batchItem.RegularBatchItem = True
                        Else
                            'Save Child Item with new Parent/Pack settings
                            batchItem.ParentID = itemDetail.ID
                            batchItem.RegularBatchItem = False
                        End If

                        objMichaels.SaveRecord(DataHelper.SmartValues(Me.dirtyFlag.Value, "boolean"), batchItem, UserID)
                    End If
                End If
            Next

            If Not itemDetail.ValidExistingSKU Then Me.custFields.SaveCustomFields(itemID)

            If Not itemDetail.ValidExistingSKU Then
                ' check
                ' ------------------------------------------------------------------
                ' CHECK FOR VALID EXISTING SKU
                Dim sku As String, vendornumber As Long
                Dim itemMaintItem As Models.ItemMaintItemDetailFormRecord
                sku = itemDetail.MichaelsSKU
                vendornumber = DataHelper.SmartValues(itemDetail.VendorNumber, "long", False)
                If sku <> String.Empty AndAlso vendornumber > 0 Then
                    itemMaintItem = data.MaintItemMasterData.GetItemMaintItemDetailRecord(vendornumber, sku, vendornumber)
                    If itemMaintItem IsNot Nothing AndAlso (itemMaintItem.SKU <> String.Empty And itemMaintItem.VendorNumber > 0) Then
                        ' MERGE
                        ItemHelper.MergeItemMaintRecordIntoImportItem(itemDetail, itemMaintItem)
                        itemDetail.ValidExistingSKU = True
                        itemMaintItem = Nothing
                    End If
                End If

                ' Save this item ??
                ' ---------------
                If itemDetail.ValidExistingSKU Then
                    itemID = objMichaels.SaveRecord(itemDetail, UserID, True, "Merged", "Item was merged with Item Master.")
                    ' Save XRef to this image for existing SKU (if exists)...
                    Dim objMichaelsIFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()
                    If itemDetail.ImageID > 0 Then
                        objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_IMPORT, itemID, itemDetail.ImageID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image, UserID)
                        ' audit
                        Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                        Dim audit As New Models.AuditRecord()
                        audit.SetupAudit(Models.MetadataTable.Items_Files, itemID, Models.AuditRecordType.Insert, UserID)
                        audit.AddAuditField("File_ID", itemDetail.ImageID)
                        objFA.SaveAuditRecord(audit)
                        objFA = Nothing
                        audit = Nothing
                    End If

                    ' Save XRef to MSDS sheet for existing SKU (if exists)...
                    If itemDetail.MSDSID > 0 Then
                        objMichaelsIFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_IMPORT, itemID, itemDetail.MSDSID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS, UserID)
                        ' audit
                        Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                        Dim audit As New Models.AuditRecord()
                        audit.SetupAudit(Models.MetadataTable.Items_Files, itemID, Models.AuditRecordType.Insert, UserID)
                        audit.AddAuditField("File_ID", itemDetail.MSDSID)
                        objFA.SaveAuditRecord(audit)
                        objFA = Nothing
                        audit = Nothing
                    End If
                    objMichaelsIFile = Nothing
                End If
                ' ------------------------------------------------------------------
                ' end check
            End If

            If Not itemDetail.IsPackParent() And (itemDetail.CostFieldsChanged Or itemDetail.MasterWeightChanged) Then
                ItemHelper.CheckAndCalculateImportDPBatchParent(itemDetail.Batch_ID, itemDetail.CostFieldsChanged, itemDetail.MasterWeightChanged)
            End If

        End If

        objMichaels = Nothing

        Return itemID

    End Function

    Public Function PerformStageValidation() As Boolean
        Return PerformStageValidation(False, False)
    End Function

    Public Function PerformStageValidation(ByVal saveValidation As Boolean) As Boolean
        Return PerformStageValidation(saveValidation, False)
    End Function

    Public Function PerformStageValidation(ByVal saveValidation As Boolean, ByVal batchValidation As Boolean) As Boolean

        Dim vrBatch As NovaLibra.Coral.SystemFrameworks.Michaels.ValidationRecord = Nothing
        Dim vr As NovaLibra.Coral.SystemFrameworks.Michaels.ValidationRecord
        Dim vrPI As NovaLibra.Coral.SystemFrameworks.Michaels.ValidationRecord
        Dim itemDetail As New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord()

        'If ImportDetailID > 0 Then
        '    Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
        '    itemDetail = objMichaels.GetRecord(ImportDetailID)
        '    objMichaels = Nothing
        'Else
        '    itemDetail = New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
        'End If

        If ImportDetailID > 0 Then
            itemDetail.ID = ImportDetailID
            itemDetail.ParentID = ParentID
            itemDetail.RegularBatchItem = IsRegularBatchItem
        End If

        'Load form values into the item detail record
        LoadFormValuesIntoRec(itemDetail)

        'Validate the record object
        If taxWizardComplete.Value = "1" Then
            itemDetail.TaxWizard = True
        Else
            itemDetail.TaxWizard = False
        End If

        If ValidationHelper.SkipBatchValidation(Me.StageType) Then
            If batchValidation Then vrBatch = New Models.ValidationRecord(BatchID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.Batch)
        Else
            If batchValidation Then vrBatch = ValidationHelper.ValidateBatch(BatchID, NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import)
        End If

        If ValidationHelper.SkipValidation(Me.StageType) Then
            vr = New Models.ValidationRecord(itemDetail.ID, Models.ItemRecordType.ImportItem)
            vrPI = New Models.ValidationRecord(itemDetail.ID, Models.ItemRecordType.ImportItem)
        Else
            vr = ValidationHelper.ValidateImportItem(itemDetail, WorkFlowStageID, Me.StageType)
            vrPI = ValidationHelper.ValidateImportItemPack(itemDetail)
        End If

        Dim bret As Boolean
        Dim batchValid As Boolean
        If batchValidation AndAlso vrBatch IsNot Nothing Then
            batchValid = vrBatch.IsValid
        Else
            batchValid = True
        End If


        'Populate summary with any errors
        If vr.HasAnyError() OrElse (vrBatch IsNot Nothing AndAlso vrBatch.HasAnyError()) Then
            V_Summary.Controls.Clear()
            ValidationHelper.SetupValidationSummary(V_Summary)
            If batchValidation AndAlso vrBatch IsNot Nothing AndAlso (vrBatch.HasAnyError()) Then ValidationHelper.AddValidationSummaryErrors(V_Summary, vrBatch)
            If vr.HasAnyError() Then ValidationHelper.AddValidationSummaryErrors(V_Summary, vr)
        End If

        If Not (batchValid And vr.IsValid) Then
            If ImportDetailID > 0 Then
                validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(Models.ItemValidFlag.NotValid, True)
            End If

            bret = False
        Else
            If ImportDetailID > 0 Then
                validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(Models.ItemValidFlag.Valid, True)
            End If

            bret = True
        End If

        If vrPI.Count > 0 Then
            ValidationHelper.AddValidationSummaryErrors(V_Summary, vrPI)
        End If

        'moved here by lp
        If saveValidation And UserCanEdit Then

            Dim userID As Integer = Session("UserID")
            If (batchValidation AndAlso vrBatch IsNot Nothing) Then NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vr, userID)

        End If

        ' check for add to batch
        If CanAddToBatch AndAlso UserCanEdit Then
            If (Not MultipleItems) Or (MultipleItems And IsRegularBatchItem) Then
                If vr.Count() = 0 OrElse (Not vr.FieldErrorExists("SameDept") And Not vr.FieldErrorExists("SameVendor")) Then
                    ShowAddToBatch(True)
                End If
            End If
        End If

        If vrBatch IsNot Nothing Then vrBatch = Nothing
        vr = Nothing

        Return bret
    End Function

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        Try
            If Page.IsValid() Then

                If UserCanEdit Then

                    Dim isNew As Boolean = Not (ImportDetailID > 0)

                    Dim itemID As Long = SaveForm(False)
                    If itemID > 0 Then
                        If isNew Then
                            Session("_BatchID") = itemID.ToString()
                        End If

                        PerformStageValidation(True, True)

                        If hdnPBLApplyAll.Value <> "1" Then
                            Response.Redirect("importdetail.aspx?hid=" & itemID)
                        End If

                    End If
                    hdnPBLApplyAll.Value = ""   ' reset PBL Flag
                End If

                PostBackSetupFields()

            End If
        Catch ex As Exception
            Logger.LogError(ex)

        End Try
    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click

        If Page.IsValid() Then

            If UserCanEdit Then

                Dim itemID As Long = SaveForm(False)

                If itemID > 0 Then

                    PerformStageValidation(True, True)

                    ' Go to home page
                    Response.Redirect("default.aspx")
                End If
            End If
        End If

    End Sub

    Protected Sub DuplicateItem()

        'If Page.IsValid() Then

        Dim isValid As Boolean = PerformStageValidation(True, False)

        Dim regular As Boolean = False
        If MultipleItems Then
            Dim itemid As Long = SaveForm(isValid)
        Else
            regular = dupItemRegular.Checked
            Dim itemID As Long = SaveForm(isValid, regular)
        End If

        If ItemID > 0 Then
            ' Duplicate the item
            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
            Dim objRecord As Models.ImportItemRecord
            Dim i As Integer
            Dim howMany As Integer = DataHelper.SmartValues(dupItemHowMany.Value, "integer", False)
            Dim saveItemID As Long, saveParentID As Long
            If howMany > 0 AndAlso howMany <= 99 Then
                objRecord = objMichaels.GetRecord(ItemID)
                If Not objRecord Is Nothing Then
                    saveItemID = objRecord.ID
                    saveParentID = objRecord.ParentID
                    regular = objRecord.RegularBatchItem
                    For i = 1 To howMany
                        objRecord.ID = saveItemID
                        objRecord.ParentID = saveParentID
                        objRecord.IsValid = NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Unknown
                        If regular Then
                            objRecord.RegularBatchItem = True
                            objRecord.PackItemIndicator = String.Empty
                            objRecord.ItemType = "R"
                        End If
                        objMichaels.DuplicateRecord(objRecord, UserID)
                    Next
                End If
            End If
            objRecord = Nothing
            objMichaels = Nothing
            ' Reload the page
            Response.Redirect("importdetail.aspx?hid=" & ItemID)
        End If

        'End If
    End Sub

    Protected Sub AddToBatch()

        'If Page.IsValid() Then

        Dim isValid As Boolean = PerformStageValidation(True, False)

        Dim fromBatchID As Long = DataHelper.SmartValues(addToBatchList.SelectedValue, "long", False)

        Dim itemid As Long = SaveForm(isValid)

        Dim bSuccess As Boolean = False

        If itemid > 0 And fromBatchID > 0 Then
            ' Duplicate the item
            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
            bSuccess = objMichaels.AddToBatch(itemid, fromBatchID, UserID)
            objMichaels = Nothing
            ' Reload the page
            Response.Redirect("importdetail.aspx?hid=" & itemid)
        End If

        'End If
    End Sub
    Protected Sub SplitItem()
        ' the code below removes current item from batch, creates new batch and attaches current item to it
        'LP SPEDY Order 12 Feb 2009
        Dim bSuccess As Boolean = False
        Dim isValid As Boolean = PerformStageValidation(True, False)
        Dim newBatchID As Long = 0
        Dim parentItemId As Long
        Dim itemid As Long = SaveForm(isValid)
        'Dim itemparent As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord = Nothing
        Dim objRecord As New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord() '
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
        'NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord() 'Models.ImportItemRecord
        'Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
        Dim currentItem As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
        Dim newBatchrec As New NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord
        Dim objBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch
        Dim CurrentBatchRecord As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord


        If itemid > 0 Then
            'create new batch record
            Form.Disabled = True 'privent happy clicking while saving
            currentItem = objMichaels.GetRecord(itemid)
            CurrentBatchRecord = objBatch.GetRecord(currentItem.Batch_ID)
            'newitemHeader = CloneObject(objRecord)
            newBatchrec.BatchTypeID = CurrentBatchRecord.BatchTypeID
            newBatchrec.ID = 0
            newBatchrec.VendorName = CurrentBatchRecord.VendorName
            newBatchrec.VendorNumber = CurrentBatchRecord.VendorNumber
            newBatchrec.WorkflowStageID = CurrentBatchRecord.WorkflowStageID
            newBatchrec.FinelineDeptID = CurrentBatchRecord.FinelineDeptID
            newBatchrec.IsValid = CurrentBatchRecord.IsValid
            newBatchID = objBatch.SaveRecord(newBatchrec, UserID)
            'move current item to the newly created batch
            currentItem.Batch_ID = newBatchID
            parentItemId = currentItem.ParentID
            currentItem.ParentID = 0
            'Set isDirty to TRUE
            itemid = objMichaels.SaveRecord(True, currentItem, UserID)
            objMichaels = Nothing
            objBatch = Nothing
            objRecord = Nothing
            currentItem = Nothing
            newBatchrec = Nothing
            'reload form with the parent item
            'MsgBox("The current Item was moved to the new batch # " & newBatchID, MsgBoxStyle.DefaultButton1, "Move Item")
            Form.Disabled = False
            Page.ClientScript.RegisterClientScriptBlock(GetType(Page), "Validate", "alert('The current Item was moved to the new batch # " & newBatchID & "'); document.location='importdetail.aspx?hid=" & parentItemId.ToString & "';", True)
            'Response.Write("<script> alert('test');</script>")
            'Response.Write("<Script language='javascript'>alert('The current Item was moved to the new batch # " & newBatchID & "');</script>")
            'Response.Redirect("importdetail.aspx?hid=" & parentItemId.ToString)
        End If
    End Sub
    Protected Sub childItems_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles childItems.SelectedIndexChanged
        Dim goID As Long = DataHelper.SmartValues(childItems.SelectedValue, "long", False)

        'Dim itemID As Long

        'If UserCanEdit Then
        '    itemID = SaveForm(True)
        'End If

        'If itemID > 0 OrElse Not UserCanEdit Then

        If goID > 0 Then
            'Session("cHEADERID") = goID
            Response.Redirect("importdetail.aspx?hid=" & goID)
        End If

        'End If


    End Sub

    Private Sub LoadFormValuesIntoRec(ByRef itemDetail As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord)

        Dim decValue As Decimal
        Dim strValue As String

        itemDetail.Vendor = VendorAgent.SelectedValue
        itemDetail.Agent = Agent.SelectedValue
        itemDetail.AgentType = AgentType.SelectedValue
        itemDetail.SKUGroup = SKUGroup.SelectedValue
        itemDetail.ItemType = ItemType.SelectedValue
        itemDetail.PackItemIndicator = PackItemIndicator.SelectedValue
        itemDetail.ItemTypeAttribute = ItemTypeAttribute.SelectedValue
        itemDetail.AllowStoreOrder = AllowStoreOrder.SelectedValue
        itemDetail.InventoryControl = InventoryControl.SelectedValue
        itemDetail.Discountable = discountable.SelectedValue
        itemDetail.AutoReplenish = AutoReplenish.SelectedValue
        itemDetail.PrePriced = PrePriced.SelectedValue
        'itemDetail.TaxUDA = TaxUDA.SelectedValue
        itemDetail.TaxUDA = TaxUDAValue.Value
        itemDetail.PrePricedUDA = PrePricedUDA.SelectedValue
        'itemDetail.HybridType = HybridType.SelectedValue
        'itemDetail.SourcingDC = SourcingDC.SelectedValue
        itemDetail.StockingStrategyCode = StockingStrategyCode.SelectedValue
        itemDetail.QuoteSheetStatus = QuoteSheetStatus.SelectedValue
        itemDetail.ItemTask = ItemTask.SelectedValue
        itemDetail.Season = Season.SelectedValue

        ' GenerateMichaelsUPC
        itemDetail.GenerateMichaelsUPC = GenerateMichaelsUPC.SelectedValue
        'PMO200141 GTIN14 Enhancements changes
        itemDetail.GenerateMichaelsGTIN = GenerateMichaelsGTIN14.SelectedValue

        itemDetail.VendorRank = VendorRank.SelectedValue

        'removed 2020-09-11
        'itemDetail.PaymentTerms = PaymentTerms.SelectedValue
        'itemDetail.Days = Days.SelectedValue
        itemDetail.PaymentTerms = ""
        itemDetail.Days = ""

        itemDetail.CoinBattery = CoinBattery.SelectedValue
        itemDetail.TSSA = TSSA.SelectedValue
        itemDetail.CSA = CSA.SelectedValue
        itemDetail.UL = UL.SelectedValue
        itemDetail.LicenceAgreement = LicenceAgreement.SelectedValue
        itemDetail.FumigationCertificate = FumigationCertificate.SelectedValue
        itemDetail.PhytoTemporaryShipment = PhytoTemporaryShipment.SelectedValue
        itemDetail.KILNDriedCertificate = KILNDriedCertificate.SelectedValue
        itemDetail.ChinaComInspecNumAndCCIBStickers = ChinaComInspecNumAndCCIBStickers.SelectedValue
        itemDetail.OriginalVisa = OriginalVisa.SelectedValue
        itemDetail.TextileDeclarationMidCode = TextileDeclarationMidCode.SelectedValue
        itemDetail.QuotaChargeStatement = QuotaChargeStatement.SelectedValue
        itemDetail.MSDS = MSDS.SelectedValue
        itemDetail.TSCA = TSCA.SelectedValue
        itemDetail.DropBallTestCert = DropBallTestCert.SelectedValue
        itemDetail.ManMedicalDeviceListing = ManMedicalDeviceListing.SelectedValue
        itemDetail.ManFDARegistration = ManFDARegistration.SelectedValue
        itemDetail.CopyRightIndemnification = CopyRightIndemnification.SelectedValue
        itemDetail.FishWildLifeCert = FishWildLifeCert.SelectedValue
        itemDetail.Proposition65LabelReq = Proposition65LabelReq.SelectedValue
        itemDetail.CCCR = CCCR.SelectedValue
        itemDetail.FormaldehydeCompliant = FormaldehydeCompliant.SelectedValue
        itemDetail.HazMatYes = HazMatYes.SelectedValue
        itemDetail.HazMatNo = HazMatNo.SelectedValue
        itemDetail.HazMatMFGFlammable = HazMatMFGFlammable.SelectedValue
        itemDetail.HazMatContainerType = HazMatContainerType.SelectedValue
        itemDetail.HazMatMSDSUOM = HazMatMSDSUOM.SelectedValue

        itemDetail.MinimumOrderQuantity = DataHelper.SmartValues(MinimumOrderQuantity.Text.Trim(), "integer", True)
        itemDetail.ProductIdentifiesAsCosmetic = ProductIdentifiesAsCosmetic.SelectedValue

        itemDetail.DetailInvoiceCustomsDesc = DetailInvoiceCustomsDesc1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc3.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc4.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc5.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc6.Text.Trim()
        itemDetail.ComponentMaterialBreakdown = ComponentMaterialBreakdown1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown3.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown4.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown5.Text.Trim()
        itemDetail.ComponentConstructionMethod = ComponentConstructionMethod1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentConstructionMethod += ComponentConstructionMethod2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentConstructionMethod += ComponentConstructionMethod3.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentConstructionMethod += ComponentConstructionMethod4.Text.Trim()
        itemDetail.PurchaseOrderIssuedTo = PurchaseOrderIssuedTo1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.PurchaseOrderIssuedTo += PurchaseOrderIssuedTo2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.PurchaseOrderIssuedTo += PurchaseOrderIssuedTo3.Text.Trim()

        'Set to max value if invalid so that validation will know to check for invalid dates << WHAT !?  DOESN'T WORK??
        itemDetail.DateSubmitted = DataHelper.SmartValues(DateSubmitted.Text.Trim(), "date", True) ', Date.MaxValue)
        itemDetail.EnteredDate = DataHelper.SmartValues(EnteredDate.Text.Trim(), "date", True) ', Date.MaxValue)
        'itemDetail.ConversionDate = DataHelper.SmartValues(ConversionDate.Value.Trim(), "date") ', True, Date.MaxValue)

        itemDetail.Buyer = Buyer.Text.Trim()
        itemDetail.Fax = Fax.Text.Trim()
        itemDetail.EnteredBy = EnteredBy.Text.Trim()
        itemDetail.Email = Email.Text.Trim()
        itemDetail.Dept = Dept.Text.Trim()
        itemDetail.Class = Me.Class.Text.Trim()
        itemDetail.SubClass = SubClass.Text.Trim()
        itemDetail.PrimaryUPC = PrimaryUPC.Text.Trim()
        itemDetail.MichaelsSKU = MichaelsSKU.Text.Trim()
        'Added QuoteReferenceNumber 2/24/2011
        itemDetail.QuoteReferenceNumber = QuoteReferenceNumber.Text.Trim

        'PMO200141 GTIN14 Enhancements changes
        itemDetail.InnerGTIN = InnerGTIN.Text.Trim()
        itemDetail.CaseGTIN = CaseGTIN.Text.Trim()

        If itemDetail.AdditionalUPCRecord Is Nothing Then itemDetail.AdditionalUPCRecord = New Models.ItemAdditionalUPCRecord(0, itemDetail.ID)
        ' additional upcs
        Dim upcvalues1 As String = String.Empty, upcvalues2 As String = String.Empty
        Dim i As Integer
        ' upcvalues1
        'For i = 0 To itemDetail.AdditionalUPCRecord.AdditionalUPCs.Count - 1
        '    If upcvalues1 <> String.Empty Then upcvalues1 += ","
        '    upcvalues1 += itemDetail.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString()
        'Next

        ' save upc values
        itemDetail.AdditionalUPCRecord.AdditionalUPCs.Clear()
        Dim arr() As String = Split(additionalUPCValues.Value, ",")
        For i = 0 To arr.Length - 1
            If arr(i).Trim() <> String.Empty Then
                itemDetail.AdditionalUPCRecord.AddAdditionalUPC(FormatUPCValue(arr(i).Trim()))
            End If
        Next

        '' upcvalues2
        'For i = 0 To itemDetail.AdditionalUPCRecord.AdditionalUPCs.Count - 1
        '    If upcvalues2 <> String.Empty Then upcvalues2 += ","
        '    upcvalues2 += itemDetail.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString()
        'Next
        '' compare 
        'If itemDetail.SaveAudit AndAlso upcvalues1 <> upcvalues2 Then
        '    itemDetail.AddAuditField("Additional_UPC", upcvalues2)
        'End If



        'itemDetail.AdditionalUPC1 = AdditionalUPC1.Text.Trim()
        'itemDetail.AdditionalUPC2 = AdditionalUPC2.Text.Trim()
        'itemDetail.AdditionalUPC3 = AdditionalUPC3.Text.Trim()
        'itemDetail.AdditionalUPC4 = AdditionalUPC4.Text.Trim()
        'itemDetail.AdditionalUPC5 = AdditionalUPC5.Text.Trim()
        'itemDetail.AdditionalUPC6 = AdditionalUPC6.Text.Trim()
        'itemDetail.AdditionalUPC7 = AdditionalUPC7.Text.Trim()
        'itemDetail.AdditionalUPC8 = AdditionalUPC8.Text.Trim()

        itemDetail.PrimaryUPC = FormatUPCValue(PrimaryUPC.Text)
        itemDetail.MichaelsSKU = FormatSKUValue(MichaelsSKU.Text)

        'PMO200141 GTIN14 Enhancements changes
        itemDetail.InnerGTIN = FormatUPCValue(InnerGTIN.Text)
        itemDetail.CaseGTIN = FormatUPCValue(CaseGTIN.Text)

        'itemDetail.AdditionalUPC1 = FormatUPCValue(AdditionalUPC1.Text)
        'itemDetail.AdditionalUPC2 = FormatUPCValue(AdditionalUPC2.Text)
        'itemDetail.AdditionalUPC3 = FormatUPCValue(AdditionalUPC3.Text)
        'itemDetail.AdditionalUPC4 = FormatUPCValue(AdditionalUPC4.Text)
        'itemDetail.AdditionalUPC5 = FormatUPCValue(AdditionalUPC5.Text)
        'itemDetail.AdditionalUPC6 = FormatUPCValue(AdditionalUPC6.Text)
        'itemDetail.AdditionalUPC7 = FormatUPCValue(AdditionalUPC7.Text)
        'itemDetail.AdditionalUPC8 = FormatUPCValue(AdditionalUPC8.Text)

        ' itemDetail.PackSKU = PackSKU.Text.Trim()
        itemDetail.PlanogramName = DataHelper.SmartValues(PlanogramName.Text.Trim(), "stringrsu", True)
        itemDetail.VendorNumber = VendorNumber.Value
        itemDetail.Description = DataHelper.SmartValues(Description.Text.Trim(), "stringrsu", True)
        itemDetail.PrivateBrandLabel = PrivateBrandLabel.SelectedValue
        itemDetail.VendorName = VendorName.Value
        itemDetail.VendorAddress1 = VendorAddress1.Text.Trim()
        itemDetail.VendorAddress2 = VendorAddress2.Text.Trim()
        itemDetail.VendorAddress3 = VendorAddress3.Text.Trim()
        itemDetail.VendorAddress4 = VendorAddress4.Text.Trim()
        itemDetail.VendorMinOrderAmount = VendorMinOrderAmount.Text.Trim()
        itemDetail.VendorContactName = VendorContactName.Text.Trim()
        itemDetail.VendorContactPhone = VendorContactPhone.Text.Trim()
        itemDetail.VendorContactEmail = VendorContactEmail.Text.Trim()
        itemDetail.VendorContactFax = VendorContactFax.Text.Trim()
        itemDetail.ManufactureName = ManufactureName.Text.Trim()
        itemDetail.ManufactureAddress1 = ManufactureAddress1.Text.Trim()
        itemDetail.ManufactureAddress2 = ManufactureAddress2.Text.Trim()
        itemDetail.ManufactureContact = ManufactureContact.Text.Trim()
        itemDetail.ManufacturePhone = ManufacturePhone.Text.Trim()
        itemDetail.ManufactureEmail = ManufactureEmail.Text.Trim()
        itemDetail.ManufactureFax = ManufactureFax.Text.Trim()
        itemDetail.AgentContact = AgentContact.Text.Trim()
        itemDetail.AgentPhone = AgentPhone.Text.Trim()
        itemDetail.AgentEmail = AgentEmail.Text.Trim()
        itemDetail.AgentFax = AgentFax.Text.Trim()
        itemDetail.VendorStyleNumber = DataHelper.SmartValues(VendorStyleNumber.Text.Trim(), "stringrsu", True)
        itemDetail.HarmonizedCodeNumber = HarmonizedCodeNumber.Text.Trim()
        itemDetail.CanadaHarmonizedCodeNumber = CanadaHarmonizedCodeNumber.Text.Trim()
        itemDetail.IndividualItemPackaging = IndividualItemPackaging.Text.Trim()
        itemDetail.QtyInPack = DataHelper.SmartValues(QtyInPack.Text.Trim(), "integer", True)
        itemDetail.EachInsideMasterCaseBox = EachInsideMasterCaseBox.Text.Trim()
        itemDetail.EachInsideInnerPack = EachInsideInnerPack.Text.Trim()


        itemDetail.EachHeight = RoundDimesionsDecimal(DataHelper.SmartValues(EachHeight.Text.Trim(), "decimal", True), 4)
        itemDetail.EachLength = RoundDimesionsDecimal(DataHelper.SmartValues(EachLength.Text.Trim(), "decimal", True), 4)
        itemDetail.EachWeight = RoundDimesionsDecimal(DataHelper.SmartValues(EachWeight.Text.Trim(), "decimal", True), 4)
        itemDetail.EachWidth = RoundDimesionsDecimal(DataHelper.SmartValues(EachWidth.Text.Trim(), "decimal", True), 4)
        'itemDetail.CubicFeetEach = DataHelper.SmartValues(CubicFeetPerEach.Value.Trim(), "decimal", True)


        Dim strEachPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
            itemDetail.EachWidth, _
            itemDetail.EachHeight, _
            itemDetail.EachLength, _
            itemDetail.EachWidth)

        itemDetail.CubicFeetEach = DataHelper.SmartValues(strEachPackCube, "decimal", True)

        'itemDetail.EachPieceNetWeightLbsPerOunce = EachPieceNetWeightLbsPerOunce.Text.Trim()
        itemDetail.ReshippableInnerCartonWeight = RoundDimesionsDecimal(DataHelper.SmartValues(ReshippableInnerCartonWeight.Text.Trim(), "decimal", True), 4)

        itemDetail.ReshippableInnerCartonLength = RoundDimesionsString(ReshippableInnerCartonLength.Text.Trim())
        itemDetail.ReshippableInnerCartonWidth = RoundDimesionsString(ReshippableInnerCartonWidth.Text.Trim())
        itemDetail.ReshippableInnerCartonHeight = RoundDimesionsString(ReshippableInnerCartonHeight.Text.Trim())
        itemDetail.MasterCartonDimensionsLength = RoundDimesionsString(MasterCartonDimensionsLength.Text.Trim())
        itemDetail.MasterCartonDimensionsWidth = RoundDimesionsString(MasterCartonDimensionsWidth.Text.Trim())
        itemDetail.MasterCartonDimensionsHeight = RoundDimesionsString(MasterCartonDimensionsHeight.Text.Trim())
        itemDetail.CubicFeetPerMasterCarton = CubicFeetPerMasterCarton.Value.Trim()
        itemDetail.WeightMasterCarton = RoundDimesionsDecimal(DataHelper.SmartValues(WeightMasterCarton.Text.Trim(), "decimal", True), 4)
        'itemDetail.CubicFeetPerInnerCarton = CubicFeetPerInnerCarton.Value.Trim()

        Dim strInnerPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
            itemDetail.ReshippableInnerCartonWidth, _
            itemDetail.ReshippableInnerCartonHeight, _
            itemDetail.ReshippableInnerCartonLength, _
            itemDetail.ReshippableInnerCartonWeight)

        itemDetail.CubicFeetPerInnerCarton = DataHelper.SmartValues(strInnerPackCube, "decimal", True)


        itemDetail.DisplayerCost = DataHelper.SmartValues(DisplayerCost.Text.Trim(), "decimal", True)
        itemDetail.ProductCost = DataHelper.SmartValues(ProductCost.Text.Trim(), "decimal", True)
        itemDetail.FOBShippingPoint = FOBShippingPoint.Value.Trim()

        strValue = DutyPercent.Text.Trim()
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.DutyPercent = strValue
        itemDetail.DutyAmount = DutyAmount.Value.Trim()

        itemDetail.AdditionalDutyComment = AdditionalDutyComment.Text.Trim()
        itemDetail.AdditionalDutyAmount = AdditionalDutyAmount.Text.Trim()

        strValue = SuppTariffPercent.Text.Trim()
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.SuppTariffPercent = strValue
        itemDetail.SuppTariffAmount = SuppTariffAmount.Value.Trim()

        itemDetail.OceanFreightAmount = OceanFreightAmount.Text.Trim()
        itemDetail.OceanFreightComputedAmount = OceanFreightComputedAmount.Value.Trim()
        'itemDetail.AgentCommissionPercent = AgentCommissionPercent.Text.Trim()
        strValue = AgentCommissionPercent.Text.Trim()
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.AgentCommissionPercent = strValue

        strValue = RecAgentCommissionPercent.Text.Trim()
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.RecAgentCommissionPercent = strValue

        itemDetail.AgentCommissionAmount = AgentCommissionAmount.Value.Trim()
        'itemDetail.OtherImportCostsPercent = OtherImportCostsPercent.Value.Trim()
        strValue = OtherImportCostsPercent.Value.Trim()
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.OtherImportCostsPercent = strValue

        itemDetail.OtherImportCostsAmount = OtherImportCostsAmount.Value.Trim()
        'itemDetail.PackagingCostAmount = PackagingCostAmount.Text.Trim()
        itemDetail.PackagingCostAmount = String.Empty
        itemDetail.TotalImportBurden = TotalImportBurden.Value.Trim()
        itemDetail.WarehouseLandedCost = Me.WarehouseLandedCost.Value.Trim()
        itemDetail.ShippingPoint = DataHelper.SmartValues(ShippingPoint.Text.Trim(), "stringrsu", True)
        itemDetail.CountryOfOrigin = CountryOfOrigin.Value.Trim()
        itemDetail.CountryOfOriginName = CountryOfOriginName.Text.Trim()
        itemDetail.VendorComments = DataHelper.SmartValues(VendorComments.Text.Trim(), "stringrs", True)
        itemDetail.StockCategory = StockCategory.Text.Trim()
        itemDetail.FreightTerms = FreightTerms.Text.Trim()
        itemDetail.TaxValueUDA = DataHelper.SmartValues(TaxValueUDAValue.Value, "integer", True)
        'itemDetail.LeadTime = LeadTime.Text.Trim()
        itemDetail.StoreSuppZoneGRP = StoreSuppZoneGRP.Text.Trim()
        itemDetail.WhseSuppZoneGRP = WhseSuppZoneGRP.Text.Trim()
        itemDetail.POGMaxQty = POGMaxQty.Text.Trim()
        itemDetail.POGSetupPerStore = POGSetupPerStore.Text.Trim()
        itemDetail.ProjSalesPerStorePerMonth = ProjSalesPerStorePerMonth.Text.Trim()
        itemDetail.OutboundFreight = OutboundFreight.Value.Trim()
        itemDetail.NinePercentWhseCharge = NinePercentWhseCharge.Value.Trim()
        itemDetail.TotalStoreLandedCost = TotalStoreLandedCost.Value.Trim()
        itemDetail.RDBase = RDBase.Text.Trim()
        itemDetail.RDCentral = RDCentral.Value.Trim()
        itemDetail.RDTest = RDTest.Value.Trim()
        itemDetail.RDAlaska = RDAlaska.Text.Trim()
        itemDetail.RDCanada = RDCanada.Text.Trim()
        itemDetail.RD0Thru9 = RD0Thru9.Value.Trim()
        itemDetail.RDCalifornia = RDCalifornia.Value.Trim()
        itemDetail.RDVillageCraft = RDVillageCraft.Value.Trim()

        itemDetail.Retail9 = DataHelper.SmartValues(Replace(Replace(Me.Retail9.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail10 = DataHelper.SmartValues(Replace(Replace(Me.Retail10.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail11 = DataHelper.SmartValues(Replace(Replace(Me.Retail11.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail12 = DataHelper.SmartValues(Replace(Replace(Me.Retail12.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail13 = DataHelper.SmartValues(Replace(Replace(Me.Retail13.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.RDQuebec = DataHelper.SmartValues(Replace(Replace(Me.RDQuebec.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        'If IsNumeric(itemDetail.RDCanada) Then
        '    itemDetail.RDQuebec = itemDetail.RDCanada
        'End If
        itemDetail.RDPuertoRico = DataHelper.SmartValues(Replace(Replace(Me.RDPuertoRico.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)

        itemDetail.HazMatMFGCountry = HazMatMFGCountry.Text.Trim()
        itemDetail.HazMatMFGName = HazMatMFGName.Text.Trim()
        itemDetail.HazMatMFGCity = HazMatMFGCity.Text.Trim()
        itemDetail.HazMatMFGState = HazMatMFGState.Text.Trim()
        itemDetail.HazMatContainerSize = HazMatContainerSize.Text.Trim()
        itemDetail.HazMatMFGPhone = HazMatMFGPhone.Text.Trim()

        ' FILES
        If ImageID.Value <> "" And IsNumeric(ImageID.Value) Then
            itemDetail.SetImageFileID(DataHelper.SmartValues(ImageID.Value, "long", True))
        End If
        If MSDSID.Value <> "" And IsNumeric(MSDSID.Value) Then
            itemDetail.SetMSDSFileID(DataHelper.SmartValues(MSDSID.Value, "long", True))
        End If

        ' RMS
        If ShowRMSFields Then
            itemDetail.RMSSellable = RMSSellable.SelectedValue
            itemDetail.RMSOrderable = RMSOrderable.SelectedValue
            itemDetail.RMSInventory = RMSInventory.SelectedValue
        End If

        ' New Item Approval
        itemDetail.StoreTotal = DataHelper.SmartValues(Me.storeTotal.Text, "integer", True)
        itemDetail.POGStartDate = DataHelper.SmartValues(Me.POGStartDate.Text, "date", True)
        itemDetail.POGCompDate = DataHelper.SmartValues(Me.POGCompDate.Text, "date", True)
        itemDetail.LikeItemSKU = DataHelper.SmartValues(Me.likeItemSKU.Text, "string", True)
        itemDetail.LikeItemDescription = DataHelper.SmartValues(Me.likeItemDescription.Value, "string", True)
        itemDetail.LikeItemRetail = DataHelper.SmartValues(Me.likeItemRetail.Value, "decimal", True)
        'itemDetail.LikeItemRegularUnit = DataHelper.SmartValues(Me.likeItemRegularUnits.Text, "decimal", True)
        strValue = likeItemRegularUnit.Text.Trim().Replace(",", "").Replace("%", "")
        decValue = Decimal.MinValue
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            'If decValue <> Decimal.MinValue Then
            'decValue = decValue / 100
            'End If
        End If
        itemDetail.LikeItemRegularUnit = decValue
        'itemDetail.LIkeItemSales = DataHelper.SmartValues(Me.likeItemSales.Text, "decimal", True)
        itemDetail.AnnualRegRetailSales = DataHelper.SmartValues(Me.AnnualRegRetailSales.Value, "decimal", True)
        itemDetail.Facings = DataHelper.SmartValues(Me.facings.Text.Trim(), "decimal", True)
        itemDetail.POGMinQty = DataHelper.SmartValues(Me.POGMinQty.Text.Trim(), "decimal", True)
        itemDetail.LikeItemStoreCount = DataHelper.SmartValues(Trim(Me.likeItemStoreCount.Text), "decimal", True)
        itemDetail.CalculateOptions = CInt(Me.CalculateOptions.SelectedValue)
        If Not AnnualRegularUnitForecast.ReadOnly Then
            itemDetail.AnnualRegularUnitForecast = DataHelper.SmartValues(Me.AnnualRegularUnitForecast.Text.Trim(), "decimal", True)
        Else
            itemDetail.AnnualRegularUnitForecast = DataHelper.SmartValues(Me.calculatedAnnualRegularUnitForecast.Value.Trim(), "decimal", True) ''DataHelper.SmartValues(Me.calculatedAnnualRegularUnitForecast.Value, "integer", True)
        End If
        If Not calculatedLikeItemUnitStoreMonthEdit.ReadOnly Then
            itemDetail.LikeItemUnitStoreMonth = DataHelper.SmartValues(Me.calculatedLikeItemUnitStoreMonthEdit.Text, "decimal", True)
        Else
            itemDetail.LikeItemUnitStoreMonth = DataHelper.SmartValues(Me.calculatedLikeItemUnitStoreMonth.Value, "decimal", True)
        End If

        'Load Multi-language fields into Item
        itemDetail.CustomsDescription = CustomsDescription.Text.Trim
        itemDetail.EnglishLongDescription = EnglishLongDescription.Text
        itemDetail.EnglishShortDescription = EnglishShortDescription.Text
        itemDetail.FrenchLongDescription = FrenchLongDescription.Text
        itemDetail.FrenchShortDescription = FrenchShortDescription.Text
        itemDetail.SpanishLongDescription = SpanishLongDescription.Text
        itemDetail.SpanishShortDescription = SpanishShortDescription.Text
        itemDetail.PLIEnglish = PLIEnglish.SelectedValue
        itemDetail.PLIFrench = PLIFrench.SelectedValue
        itemDetail.PLISpanish = PLISpanish.SelectedValue
        itemDetail.TIEnglish = TIEnglish.SelectedValue
        itemDetail.TIFrench = TIFrench.SelectedValue
        itemDetail.TISpanish = TISpanish.SelectedValue

    End Sub

    Private Sub LoadFormValuesIntoRecWFormat(ByRef itemDetail As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord)

        Dim decValue As Decimal
        Dim strValue As String

        itemDetail.Vendor = DataHelper.SmartValues(VendorAgent.SelectedValue, "string", True)
        itemDetail.Agent = DataHelper.SmartValues(Agent.SelectedValue, "string", True)
        itemDetail.AgentType = DataHelper.SmartValues(AgentType.SelectedValue, "string", True)
        itemDetail.SKUGroup = DataHelper.SmartValues(SKUGroup.SelectedValue, "string", True)
        itemDetail.ItemType = DataHelper.SmartValues(ItemType.SelectedValue, "string", True)
        itemDetail.PackItemIndicator = DataHelper.SmartValues(PackItemIndicator.SelectedValue, "string", True)
        itemDetail.ItemTypeAttribute = DataHelper.SmartValues(ItemTypeAttribute.SelectedValue, "string", True)
        itemDetail.AllowStoreOrder = DataHelper.SmartValues(AllowStoreOrder.SelectedValue, "string", True)
        itemDetail.InventoryControl = DataHelper.SmartValues(InventoryControl.SelectedValue, "string", True)
        itemDetail.Discountable = DataHelper.SmartValues(discountable.SelectedValue, "string", True)
        itemDetail.AutoReplenish = DataHelper.SmartValues(AutoReplenish.SelectedValue, "string", True)
        itemDetail.PrePriced = DataHelper.SmartValues(PrePriced.SelectedValue, "string", True)
        'itemDetail.TaxUDA = DataHelper.SmartValues(TaxUDA.SelectedValue, "string", True)
        itemDetail.TaxUDA = DataHelper.SmartValues(TaxUDAValue.Value, "string", True)
        itemDetail.PrePricedUDA = DataHelper.SmartValues(PrePricedUDA.SelectedValue, "string", True)
        'itemDetail.HybridType = DataHelper.SmartValues(HybridType.SelectedValue, "string", True)
        'itemDetail.SourcingDC = DataHelper.SmartValues(SourcingDC.SelectedValue, "string", True)
        itemDetail.StockingStrategyCode = DataHelper.SmartValues(StockingStrategyCode.SelectedValue, "string", True)
        itemDetail.QuoteSheetStatus = DataHelper.SmartValues(QuoteSheetStatus.SelectedValue, "string", True)
        itemDetail.ItemTask = DataHelper.SmartValues(ItemTask.SelectedValue, "string", True)
        itemDetail.Season = DataHelper.SmartValues(Season.SelectedValue, "string", True)

        ' GenerateMichaelsUPC
        itemDetail.GenerateMichaelsUPC = DataHelper.SmartValues(GenerateMichaelsUPC.SelectedValue, "string", True)

        itemDetail.VendorRank = DataHelper.SmartValues(VendorRank.SelectedValue, "string", True)
        'removed 2020-09-11
        'itemDetail.PaymentTerms = DataHelper.SmartValues(PaymentTerms.SelectedValue, "string", True)
        'itemDetail.Days = DataHelper.SmartValues(Days.SelectedValue, "string", True)
        itemDetail.PaymentTerms = ""
        itemDetail.Days = ""

        itemDetail.CoinBattery = DataHelper.SmartValues(CoinBattery.SelectedValue, "string", True)
        itemDetail.TSSA = DataHelper.SmartValues(TSSA.SelectedValue, "string", True)
        itemDetail.CSA = DataHelper.SmartValues(CSA.SelectedValue, "string", True)
        itemDetail.UL = DataHelper.SmartValues(UL.SelectedValue, "string", True)
        itemDetail.LicenceAgreement = DataHelper.SmartValues(LicenceAgreement.SelectedValue, "string", True)
        itemDetail.FumigationCertificate = DataHelper.SmartValues(FumigationCertificate.SelectedValue, "string", True)
        itemDetail.PhytoTemporaryShipment = DataHelper.SmartValues(PhytoTemporaryShipment.SelectedValue, "string", True)

        itemDetail.KILNDriedCertificate = DataHelper.SmartValues(KILNDriedCertificate.SelectedValue, "string", True)
        itemDetail.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(ChinaComInspecNumAndCCIBStickers.SelectedValue, "string", True)
        itemDetail.OriginalVisa = DataHelper.SmartValues(OriginalVisa.SelectedValue, "string", True)
        itemDetail.TextileDeclarationMidCode = DataHelper.SmartValues(TextileDeclarationMidCode.SelectedValue, "string", True)
        itemDetail.QuotaChargeStatement = DataHelper.SmartValues(QuotaChargeStatement.SelectedValue, "string", True)
        itemDetail.MSDS = DataHelper.SmartValues(MSDS.SelectedValue, "string", True)
        itemDetail.TSCA = DataHelper.SmartValues(TSCA.SelectedValue, "string", True)
        itemDetail.DropBallTestCert = DataHelper.SmartValues(DropBallTestCert.SelectedValue, "string", True)
        itemDetail.ManMedicalDeviceListing = DataHelper.SmartValues(ManMedicalDeviceListing.SelectedValue, "string", True)
        itemDetail.ManFDARegistration = DataHelper.SmartValues(ManFDARegistration.SelectedValue, "string", True)
        itemDetail.CopyRightIndemnification = DataHelper.SmartValues(CopyRightIndemnification.SelectedValue, "string", True)
        itemDetail.FishWildLifeCert = DataHelper.SmartValues(FishWildLifeCert.SelectedValue, "string", True)
        itemDetail.Proposition65LabelReq = DataHelper.SmartValues(Proposition65LabelReq.SelectedValue, "string", True)
        itemDetail.CCCR = DataHelper.SmartValues(CCCR.SelectedValue, "string", True)
        itemDetail.FormaldehydeCompliant = DataHelper.SmartValues(FormaldehydeCompliant.SelectedValue, "string", True)
        itemDetail.HazMatYes = DataHelper.SmartValues(HazMatYes.SelectedValue, "string", True)
        itemDetail.HazMatNo = DataHelper.SmartValues(HazMatNo.SelectedValue, "string", True)
        itemDetail.HazMatMFGFlammable = DataHelper.SmartValues(HazMatMFGFlammable.SelectedValue, "string", True)
        itemDetail.HazMatContainerType = DataHelper.SmartValues(HazMatContainerType.SelectedValue, "string", True)
        itemDetail.HazMatMSDSUOM = DataHelper.SmartValues(HazMatMSDSUOM.SelectedValue, "string", True)

        itemDetail.MinimumOrderQuantity = DataHelper.SmartValues(MinimumOrderQuantity.Text.Trim(), "integer", True)
        itemDetail.ProductIdentifiesAsCosmetic = ProductIdentifiesAsCosmetic.SelectedValue

        itemDetail.DetailInvoiceCustomsDesc = DetailInvoiceCustomsDesc1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc3.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc4.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc5.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.DetailInvoiceCustomsDesc += DetailInvoiceCustomsDesc6.Text.Trim()
        itemDetail.ComponentMaterialBreakdown = ComponentMaterialBreakdown1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown3.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown4.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentMaterialBreakdown += ComponentMaterialBreakdown5.Text.Trim()
        itemDetail.ComponentConstructionMethod = ComponentConstructionMethod1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentConstructionMethod += ComponentConstructionMethod2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentConstructionMethod += ComponentConstructionMethod3.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.ComponentConstructionMethod += ComponentConstructionMethod4.Text.Trim()
        itemDetail.PurchaseOrderIssuedTo = PurchaseOrderIssuedTo1.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.PurchaseOrderIssuedTo += PurchaseOrderIssuedTo2.Text.Trim() & WebConstants.MULTILINE_DELIM
        itemDetail.PurchaseOrderIssuedTo += PurchaseOrderIssuedTo3.Text.Trim()

        itemDetail.DateSubmitted = DataHelper.SmartValues(DateSubmitted.Text.Trim(), "date", True, Date.MinValue)
        itemDetail.Buyer = DataHelper.SmartValues(Buyer.Text.Trim(), "string", True)
        itemDetail.Fax = DataHelper.SmartValues(Fax.Text.Trim(), "string", True)
        itemDetail.EnteredBy = DataHelper.SmartValues(EnteredBy.Text.Trim(), "string", True)
        itemDetail.Email = DataHelper.SmartValues(Email.Text.Trim(), "string", True)
        itemDetail.EnteredDate = DataHelper.SmartValues(EnteredDate.Text.Trim(), "date", True, Date.MinValue)
        itemDetail.Dept = DataHelper.SmartValues(Dept.Text.Trim(), "string", True)
        itemDetail.Class = DataHelper.SmartValues(Me.Class.Text.Trim(), "string", True)
        itemDetail.SubClass = DataHelper.SmartValues(SubClass.Text.Trim(), "string", True)

        itemDetail.PrimaryUPC = PrimaryUPC.Text.Trim()
        itemDetail.MichaelsSKU = MichaelsSKU.Text.Trim()

        'PMO200141 GTIN14 Enhancements changes
        itemDetail.InnerGTIN = InnerGTIN.Text.Trim()
        itemDetail.CaseGTIN = CaseGTIN.Text.Trim()
        itemDetail.GenerateMichaelsGTIN = DataHelper.SmartValues(GenerateMichaelsGTIN14.SelectedValue, "string", True)

        If itemDetail.AdditionalUPCRecord Is Nothing Then itemDetail.AdditionalUPCRecord = New Models.ItemAdditionalUPCRecord(0, itemDetail.ID)

        ' additional upcs
        Dim upcvalues1 As String = String.Empty, upcvalues2 As String = String.Empty
        Dim i As Integer
        ' upcvalues1
        For i = 0 To itemDetail.AdditionalUPCRecord.AdditionalUPCs.Count - 1
            If upcvalues1 <> String.Empty Then upcvalues1 += ","
            upcvalues1 += itemDetail.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString()
        Next

        ' save upc values
        itemDetail.AdditionalUPCRecord.AdditionalUPCs.Clear()
        Dim arr() As String = Split(additionalUPCValues.Value, ",")
        For i = 0 To arr.Length - 1
            If arr(i).Trim() <> String.Empty Then
                itemDetail.AdditionalUPCRecord.AddAdditionalUPC(FormatUPCValue(arr(i).Trim()))
            End If
        Next

        ' upcvalues2
        For i = 0 To itemDetail.AdditionalUPCRecord.AdditionalUPCs.Count - 1
            If upcvalues2 <> String.Empty Then upcvalues2 += ","
            upcvalues2 += itemDetail.AdditionalUPCRecord.AdditionalUPCs.Item(i).ToString()
        Next
        ' compare 
        If itemDetail.SaveAudit AndAlso upcvalues1 <> upcvalues2 Then
            itemDetail.AddAuditField("Additional_UPC", upcvalues2)
        End If

        itemDetail.PrimaryUPC = FormatUPCValue(PrimaryUPC.Text)
        itemDetail.MichaelsSKU = FormatSKUValue(MichaelsSKU.Text)

        'PMO200141 GTIN14 Enhancements changes
        itemDetail.InnerGTIN = FormatUPCValue(InnerGTIN.Text)
        itemDetail.CaseGTIN = FormatUPCValue(CaseGTIN.Text)

        itemDetail.PlanogramName = DataHelper.SmartValues(PlanogramName.Text.Trim(), "stringrsu", True)
        itemDetail.VendorNumber = VendorNumber.Value
        itemDetail.Description = DataHelper.SmartValues(Description.Text.Trim(), "stringrsu", True)
        itemDetail.PrivateBrandLabel = PrivateBrandLabel.SelectedValue
        itemDetail.VendorName = VendorName.Value
        itemDetail.VendorAddress1 = VendorAddress1.Text.Trim()
        itemDetail.VendorAddress2 = VendorAddress2.Text.Trim()
        itemDetail.VendorAddress3 = VendorAddress3.Text.Trim()
        itemDetail.VendorAddress4 = VendorAddress4.Text.Trim()
        itemDetail.VendorMinOrderAmount = DataHelper.SmartValues(Replace(Replace(VendorMinOrderAmount.Text, ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.VendorContactName = VendorContactName.Text.Trim()
        itemDetail.VendorContactPhone = VendorContactPhone.Text.Trim()
        itemDetail.VendorContactEmail = VendorContactEmail.Text.Trim()
        itemDetail.VendorContactFax = VendorContactFax.Text.Trim()
        itemDetail.ManufactureName = ManufactureName.Text.Trim()
        itemDetail.ManufactureAddress1 = ManufactureAddress1.Text.Trim()
        itemDetail.ManufactureAddress2 = ManufactureAddress2.Text.Trim()
        itemDetail.ManufactureContact = ManufactureContact.Text.Trim()
        itemDetail.ManufacturePhone = ManufacturePhone.Text.Trim()
        itemDetail.ManufactureEmail = ManufactureEmail.Text.Trim()
        itemDetail.ManufactureFax = ManufactureFax.Text.Trim()
        itemDetail.AgentContact = AgentContact.Text.Trim()
        itemDetail.AgentPhone = AgentPhone.Text.Trim()
        itemDetail.AgentEmail = AgentEmail.Text.Trim()
        itemDetail.AgentFax = AgentFax.Text.Trim()
        itemDetail.VendorStyleNumber = DataHelper.SmartValues(VendorStyleNumber.Text.Trim(), "stringrsu", True)
        itemDetail.CanadaHarmonizedCodeNumber = CanadaHarmonizedCodeNumber.Text.Trim()
        itemDetail.HarmonizedCodeNumber = HarmonizedCodeNumber.Text.Trim()
        itemDetail.IndividualItemPackaging = IndividualItemPackaging.Text.Trim()
        itemDetail.QtyInPack = DataHelper.SmartValues(QtyInPack.Text.Trim(), "integer", True)
        itemDetail.EachInsideMasterCaseBox = EachInsideMasterCaseBox.Text.Trim()
        itemDetail.EachInsideInnerPack = EachInsideInnerPack.Text.Trim()

        itemDetail.EachHeight = RoundDimesionsDecimal(DataHelper.SmartValues(EachHeight.Text.Trim(), "decimal", True), 4)
        itemDetail.EachLength = RoundDimesionsDecimal(DataHelper.SmartValues(EachLength.Text.Trim(), "decimal", True), 4)
        itemDetail.EachWeight = RoundDimesionsDecimal(DataHelper.SmartValues(EachWeight.Text.Trim(), "decimal", True), 4)
        itemDetail.EachWidth = RoundDimesionsDecimal(DataHelper.SmartValues(EachWidth.Text.Trim(), "decimal", True), 4)
        'itemDetail.CubicFeetEach = DataHelper.SmartValues(CubicFeetPerEach.Value.Trim(), "decimal", True)

        Dim strEachPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
            itemDetail.EachWidth, _
            itemDetail.EachHeight, _
            itemDetail.EachLength, _
            itemDetail.EachWidth)

        itemDetail.CubicFeetEach = DataHelper.SmartValues(strEachPackCube, "decimal", True)

        'itemDetail.EachPieceNetWeightLbsPerOunce = EachPieceNetWeightLbsPerOunce.Text.Trim()
        itemDetail.ReshippableInnerCartonWeight = RoundDimesionsDecimal(DataHelper.SmartValues(ReshippableInnerCartonWeight.Text.Trim(), "decimal", True), 4)

        itemDetail.ReshippableInnerCartonLength = RoundDimesionsString(ReshippableInnerCartonLength.Text.Trim())
        itemDetail.ReshippableInnerCartonWidth = RoundDimesionsString(ReshippableInnerCartonWidth.Text.Trim())
        itemDetail.ReshippableInnerCartonHeight = RoundDimesionsString(ReshippableInnerCartonHeight.Text.Trim())
        itemDetail.MasterCartonDimensionsLength = RoundDimesionsString(MasterCartonDimensionsLength.Text.Trim())
        itemDetail.MasterCartonDimensionsWidth = RoundDimesionsString(MasterCartonDimensionsWidth.Text.Trim())
        itemDetail.MasterCartonDimensionsHeight = RoundDimesionsString(MasterCartonDimensionsHeight.Text.Trim())
        itemDetail.CubicFeetPerMasterCarton = DataHelper.SmartValues(Replace(Replace(CubicFeetPerMasterCarton.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 3)
        itemDetail.WeightMasterCarton = RoundDimesionsDecimal(DataHelper.SmartValues(WeightMasterCarton.Text.Trim(), "decimal", True), 4)
        'itemDetail.CubicFeetPerInnerCarton = DataHelper.SmartValues(Replace(Replace(CubicFeetPerInnerCarton.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 3)

        Dim strInnerPackCube As String = CalculationHelper.CalculateItemCasePackCube( _
            itemDetail.ReshippableInnerCartonWidth, _
            itemDetail.ReshippableInnerCartonHeight, _
            itemDetail.ReshippableInnerCartonLength, _
            itemDetail.ReshippableInnerCartonWeight)

        itemDetail.CubicFeetPerInnerCarton = DataHelper.SmartValues(strInnerPackCube, "decimal", True)

        itemDetail.DisplayerCost = DataHelper.SmartValues(Replace(Replace(DisplayerCost.Text.Trim(), ",", ""), "$", ""), "decimal", True)
        itemDetail.ProductCost = DataHelper.SmartValues(Replace(Replace(ProductCost.Text.Trim(), ",", ""), "$", ""), "decimal", True)
        itemDetail.FOBShippingPoint = DataHelper.SmartValues(Replace(Replace(FOBShippingPoint.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)

        itemDetail.DutyPercent = DataHelper.SmartValues(Replace(Replace(DutyPercent.Text.Trim(), ",", ""), "%", ""), "decimal", True, String.Empty, 2)
        strValue = DutyPercent.Text.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.DutyPercent = strValue
        itemDetail.DutyAmount = DataHelper.SmartValues(Replace(Replace(DutyAmount.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)

        itemDetail.AdditionalDutyComment = AdditionalDutyComment.Text.Trim()
        itemDetail.AdditionalDutyAmount = DataHelper.SmartValues(Replace(Replace(AdditionalDutyAmount.Text.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)

        itemDetail.SuppTariffPercent = DataHelper.SmartValues(Replace(Replace(SuppTariffPercent.Text.Trim(), ",", ""), "%", ""), "decimal", True, String.Empty, 2)
        strValue = SuppTariffPercent.Text.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.SuppTariffPercent = strValue
        itemDetail.SuppTariffAmount = DataHelper.SmartValues(Replace(Replace(SuppTariffAmount.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)

        itemDetail.OceanFreightAmount = DataHelper.SmartValues(Replace(Replace(OceanFreightAmount.Text.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        itemDetail.OceanFreightComputedAmount = DataHelper.SmartValues(Replace(Replace(OceanFreightComputedAmount.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        'itemDetail.AgentCommissionPercent = DataHelper.SmartValues(Replace(Replace(AgentCommissionPercent.Text.Trim(), ",", ""), "%", ""), "decimal", True, String.Empty, 2)
        strValue = AgentCommissionPercent.Text.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.AgentCommissionPercent = strValue

        strValue = RecAgentCommissionPercent.Text.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.RecAgentCommissionPercent = strValue

        itemDetail.AgentCommissionAmount = DataHelper.SmartValues(Replace(Replace(AgentCommissionAmount.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        'itemDetail.OtherImportCostsPercent = DataHelper.SmartValues(Replace(Replace(OtherImportCostsPercent.Value.Trim(), ",", ""), "%", ""), "decimal", True, String.Empty, 0)
        strValue = OtherImportCostsPercent.Value.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        itemDetail.OtherImportCostsPercent = strValue

        itemDetail.OtherImportCostsAmount = DataHelper.SmartValues(Replace(Replace(OtherImportCostsAmount.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        'itemDetail.PackagingCostAmount = DataHelper.SmartValues(Replace(Replace(PackagingCostAmount.Text.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        itemDetail.PackagingCostAmount = String.Empty
        itemDetail.TotalImportBurden = DataHelper.SmartValues(Replace(Replace(TotalImportBurden.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        itemDetail.WarehouseLandedCost = DataHelper.SmartValues(Replace(Replace(WarehouseLandedCost.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        itemDetail.ShippingPoint = DataHelper.SmartValues(ShippingPoint.Text.Trim(), "stringrsu", True)
        itemDetail.CountryOfOrigin = CountryOfOrigin.Value.Trim()
        itemDetail.CountryOfOriginName = CountryOfOriginName.Text.Trim()
        itemDetail.VendorComments = DataHelper.SmartValues(VendorComments.Text.Trim(), "stringrs", True)
        itemDetail.StockCategory = StockCategory.Text.Trim()
        itemDetail.FreightTerms = FreightTerms.Text.Trim()
        itemDetail.TaxValueUDA = DataHelper.SmartValues(TaxValueUDAValue.Value, "integer", False, String.Empty)
        'itemDetail.LeadTime = LeadTime.Text.Trim()
        'itemDetail.ConversionDate = DataHelper.SmartValues(ConversionDate.Value, "date", True, Date.MinValue)
        itemDetail.StoreSuppZoneGRP = StoreSuppZoneGRP.Text.Trim()
        itemDetail.WhseSuppZoneGRP = WhseSuppZoneGRP.Text.Trim()
        itemDetail.POGMaxQty = POGMaxQty.Text.Trim()
        itemDetail.POGSetupPerStore = POGSetupPerStore.Text.Trim()
        itemDetail.ProjSalesPerStorePerMonth = ProjSalesPerStorePerMonth.Text.Trim()
        itemDetail.OutboundFreight = DataHelper.SmartValues(Replace(Replace(OutboundFreight.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        itemDetail.NinePercentWhseCharge = DataHelper.SmartValues(Replace(Replace(NinePercentWhseCharge.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        itemDetail.TotalStoreLandedCost = DataHelper.SmartValues(Replace(Replace(TotalStoreLandedCost.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 4)
        itemDetail.RDBase = DataHelper.SmartValues(Replace(Replace(RDBase.Text.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.RDCentral = DataHelper.SmartValues(Replace(Replace(RDCentral.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.RDTest = DataHelper.SmartValues(Replace(Replace(RDTest.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.RDAlaska = DataHelper.SmartValues(Replace(Replace(RDAlaska.Text.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.RDCanada = DataHelper.SmartValues(Replace(Replace(RDCanada.Text.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.RD0Thru9 = DataHelper.SmartValues(Replace(Replace(RD0Thru9.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.RDCalifornia = DataHelper.SmartValues(Replace(Replace(RDCalifornia.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.RDVillageCraft = DataHelper.SmartValues(Replace(Replace(RDVillageCraft.Value.Trim(), ",", ""), "$", ""), "decimal", True, String.Empty, 2)
        itemDetail.Retail9 = DataHelper.SmartValues(Replace(Replace(Me.Retail9.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail10 = DataHelper.SmartValues(Replace(Replace(Me.Retail10.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail11 = DataHelper.SmartValues(Replace(Replace(Me.Retail11.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail12 = DataHelper.SmartValues(Replace(Replace(Me.Retail12.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.Retail13 = DataHelper.SmartValues(Replace(Replace(Me.Retail13.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.RDQuebec = DataHelper.SmartValues(Replace(Replace(Me.RDQuebec.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)
        itemDetail.RDPuertoRico = DataHelper.SmartValues(Replace(Replace(Me.RDPuertoRico.Value.Trim(), ",", ""), "$", ""), "decimal", True, Decimal.MinValue, 2)

        itemDetail.HazMatMFGCountry = HazMatMFGCountry.Text.Trim()
        itemDetail.HazMatMFGName = HazMatMFGName.Text.Trim()
        itemDetail.HazMatMFGCity = HazMatMFGCity.Text.Trim()
        itemDetail.HazMatMFGState = HazMatMFGState.Text.Trim()
        itemDetail.HazMatContainerSize = HazMatContainerSize.Text.Trim()
        itemDetail.HazMatMFGPhone = HazMatMFGPhone.Text.Trim()

        ' FILES
        If ImageID.Value <> "" And IsNumeric(ImageID.Value) Then
            itemDetail.SetImageFileID(DataHelper.SmartValues(ImageID.Value, "long", True))
        End If
        If MSDSID.Value <> "" And IsNumeric(MSDSID.Value) Then
            itemDetail.SetMSDSFileID(DataHelper.SmartValues(MSDSID.Value, "long", True))
        End If

        ' RMS
        If ShowRMSFields Then
            itemDetail.RMSSellable = DataHelper.SmartValues(RMSSellable.SelectedValue, "string", True)
            itemDetail.RMSOrderable = DataHelper.SmartValues(RMSOrderable.SelectedValue, "string", True)
            itemDetail.RMSInventory = DataHelper.SmartValues(RMSInventory.SelectedValue, "string", True)
        End If

        ' New Item Approval
        itemDetail.CalculateOptions = CInt(Me.CalculateOptions.SelectedValue)
        itemDetail.StoreTotal = DataHelper.SmartValues(Me.storeTotal.Text, "integer", True)
        itemDetail.POGStartDate = DataHelper.SmartValues(Me.POGStartDate.Text, "date", True)
        itemDetail.POGCompDate = DataHelper.SmartValues(Me.POGCompDate.Text, "date", True)
        itemDetail.LikeItemSKU = DataHelper.SmartValues(Me.likeItemSKU.Text, "string", True)
        itemDetail.LikeItemDescription = DataHelper.SmartValues(Me.likeItemDescription.Value, "string", True)
        itemDetail.LikeItemRetail = DataHelper.SmartValues(Me.likeItemRetail.Value, "decimal", True, Decimal.MinValue, 4)

        strValue = likeItemRegularUnit.Text.Trim().Replace(",", "").Replace("%", "")
        decValue = Decimal.MinValue
        If strValue.Length > 0 AndAlso IsNumeric(strValue) Then
            'yes, round decimal to integer
            decValue = DataHelper.SmartValues(strValue, "decimal", True, Decimal.MinValue, 0) 'replaced decimal to integer per customer request LP
            itemDetail.LikeItemRegularUnit = decValue 'CLng(strValue) 'DataHelper.SmartValues(strValue, "integer", True)
        End If
        'lp SPEDY Order 12 customer wants to see the whole number as forecast!
        Select Case itemDetail.CalculateOptions
            Case 1 ' provide Unit forecast, it is a data entry field
                If Len(Trim(AnnualRegularUnitForecast.Text)) > 0 AndAlso IsNumeric(Trim(AnnualRegularUnitForecast.Text)) Then
                    itemDetail.AnnualRegularUnitForecast = DataHelper.SmartValues(Me.AnnualRegularUnitForecast.Text.Trim(), "decimal", True, Decimal.MinValue, 0)
                Else
                    itemDetail.AnnualRegularUnitForecast = 0
                End If
                itemDetail.LikeItemUnitStoreMonth = DataHelper.SmartValues(Me.calculatedLikeItemUnitStoreMonth.Value, "decimal", True)
            Case 2 'provide unit/store/month
                itemDetail.AnnualRegularUnitForecast = DataHelper.SmartValues(Me.calculatedAnnualRegularUnitForecast.Value.Trim(), "decimal", True, Decimal.MinValue, 0) ''DataHelper.SmartValues(Me.calculatedAnnualRegularUnitForecast.Value, "integer", True)
                If Len(Trim(calculatedLikeItemUnitStoreMonthEdit.Text)) > 0 AndAlso IsNumeric(Trim(calculatedLikeItemUnitStoreMonthEdit.Text)) Then
                    itemDetail.LikeItemUnitStoreMonth = DataHelper.SmartValues(Me.calculatedLikeItemUnitStoreMonthEdit.Text, "decimal", True, Decimal.MinValue, 2)
                Else
                    itemDetail.LikeItemUnitStoreMonth = 0
                End If
            Case 0
                itemDetail.AnnualRegularUnitForecast = DataHelper.SmartValues(Me.calculatedAnnualRegularUnitForecast.Value.Trim(), "decimal", True, Decimal.MinValue, 0)
                itemDetail.LikeItemUnitStoreMonth = DataHelper.SmartValues(Me.calculatedLikeItemUnitStoreMonth.Value, "decimal", True)
        End Select

        itemDetail.AnnualRegRetailSales = DataHelper.SmartValues(Me.AnnualRegRetailSales.Value, "decimal", True, Decimal.MinValue, 2)
        itemDetail.Facings = DataHelper.SmartValues(Trim(Me.facings.Text), "decimal", True)
        itemDetail.POGMinQty = DataHelper.SmartValues(Trim(Me.POGMinQty.Text), "decimal", True)
        itemDetail.LikeItemStoreCount = DataHelper.SmartValues(Trim(Me.likeItemStoreCount.Text), "decimal", True)
        itemDetail.QuoteReferenceNumber = DataHelper.SmartValues(Trim(Me.QuoteReferenceNumber.Text), "string", True)
        itemDetail.CustomsDescription = CustomsDescription.Text


        'Load Multi-language fields into Item
        itemDetail.CustomsDescription = CustomsDescription.Text.Trim
        itemDetail.EnglishLongDescription = Left(EnglishLongDescription.Text, 100)
        itemDetail.EnglishShortDescription = EnglishShortDescription.Text
        itemDetail.FrenchLongDescription = FrenchLongDescription.Text
        itemDetail.FrenchShortDescription = FrenchShortDescription.Text
        itemDetail.SpanishLongDescription = SpanishLongDescription.Text
        itemDetail.SpanishShortDescription = SpanishShortDescription.Text
        itemDetail.PLIEnglish = PLIEnglish.SelectedValue
        itemDetail.PLIFrench = PLIFrench.SelectedValue
        itemDetail.PLISpanish = PLISpanish.SelectedValue
        itemDetail.TIEnglish = TIEnglish.SelectedValue
        itemDetail.TIFrench = TIFrench.SelectedValue
        itemDetail.TISpanish = "N"  'Per Micheals:  Hardcode this to N since it is disabled for now.

    End Sub

    Private Function FractionToDecimal(ByVal frac As String, ByVal defValue As Decimal) As String

        Dim decimalVal As Decimal = defValue
        Dim upper As Decimal = 0
        Dim lower As Decimal = 0
        Dim remain As Decimal = 0

        Try

            If frac.IndexOf("/") <> -1 Then

                If frac.IndexOf(" ") <> -1 Then
                    remain = CType(frac.Substring(0, frac.IndexOf(" ")), Decimal)
                    frac = frac.Substring(frac.IndexOf(" "))
                End If

                upper = CType(frac.Substring(0, frac.IndexOf("/")), Decimal)
                lower = CType(frac.Substring(frac.IndexOf("/") + 1), Decimal)
                decimalVal = remain + (upper / lower)

            End If

        Catch ex As Exception
            decimalVal = defValue
        End Try

        Return decimalVal

    End Function

    Private Function GetDecimalValue(ByVal str As String, ByVal def As Decimal) As Decimal

        Dim retValue As Decimal = def

        Try

            If str.Trim.Length > 0 Then

                If str.Contains("/") Then
                    retValue = FractionToDecimal(str, def)
                Else

                    Dim res As Decimal
                    If Decimal.TryParse(str, res) Then
                        retValue = res
                    End If

                End If

            End If

        Catch ex As Exception

        End Try

        Return retValue

    End Function

    Private Sub ShowAddToBatch(ByVal bShow As Boolean)
        btnAddToBatch.Visible = bShow
        btnAddToBatchSep.Visible = bShow
    End Sub

#Region "Agent Dropdown Changes"

    Protected Sub Agent_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles Agent.SelectedIndexChanged

        If Agent.SelectedValue = "" Then
            VendorAgent.SelectedValue = "YES"
            L_Contact.Text = "US Contact Name:"
            'tMan1.Visible = False
            'tMan2.Visible = False
            'tMan3.Visible = False
            'tAgent1.Visible = False
            'tAgent2.Visible = False
            'tAgent3.Visible = False
            'tAgent4.Visible = False
            'P_Manufacture.Visible = False
            'P_Agent.Visible = False
            AgentType.SelectedValue = ""
            AgentType.Visible = False
            GenerateMichaelsUPC.Visible = False
            GenerateMichaelsUPC.SelectedIndex = 0
            Me.agentCommissionRow.Attributes("class") = "hideElement"
            Me.RecagentCommissionRow.Attributes("class") = "hideElement"
        Else
            VendorAgent.SelectedValue = ""
            L_Contact.Text = "Contact:"
            tMan1.Visible = True
            tMan2.Visible = True
            tMan3.Visible = True
            tAgent1.Visible = True
            tAgent2.Visible = True
            tAgent3.Visible = True
            tAgent4.Visible = True

            'P_Manufacture.Visible = True
            'P_Agent.Visible = True
            AgentType.Visible = True
            GenerateMichaelsUPC.Visible = True
            Me.agentCommissionRow.Attributes("class") = ""
            Me.RecagentCommissionRow.Attributes("class") = ""
        End If
        CreateStartupScriptForCalc("agent")

        PerformStageValidation(False, True)

        PostBackSetupFields()

    End Sub

    Protected Sub VendorAgent_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles VendorAgent.SelectedIndexChanged

        If VendorAgent.SelectedValue = "" Then
            Agent.SelectedValue = "YES"
            L_Contact.Text = "Contact:"
            tMan1.Visible = True
            tMan2.Visible = True
            tMan3.Visible = True
            tAgent1.Visible = True
            tAgent2.Visible = True
            tAgent3.Visible = True
            tAgent4.Visible = True

            'P_Manufacture.Visible = True
            'P_Agent.Visible = True
            AgentType.Visible = True
            GenerateMichaelsUPC.Visible = True
            Me.agentCommissionRow.Attributes("class") = ""
            Me.RecagentCommissionRow.Attributes("class") = ""
        Else
            Agent.SelectedValue = ""
            L_Contact.Text = "US Contact Name:"
            'tMan1.Visible = False
            'tMan2.Visible = False
            'tMan3.Visible = False
            'tAgent1.Visible = False
            'tAgent2.Visible = False
            'tAgent3.Visible = False
            'tAgent4.Visible = False

            'P_Manufacture.Visible = False
            'P_Agent.Visible = False
            AgentType.SelectedValue = ""
            AgentType.Visible = False
            GenerateMichaelsUPC.Visible = False
            GenerateMichaelsUPC.SelectedIndex = 0
            Me.agentCommissionRow.Attributes("class") = "hideElement"
            Me.RecagentCommissionRow.Attributes("class") = "hideElement"
        End If

        PerformStageValidation(False, True)

        PostBackSetupFields()

    End Sub

    Protected Function FormatUPCValue(ByVal value As String) As String
        If value.Trim() <> String.Empty AndAlso IsNumeric(value.Trim()) Then
            Return value.Trim().PadLeft(14, "0")
        Else
            Return value
        End If
    End Function

    Protected Function FormatSKUValue(ByVal value As String) As String
        If value.Trim() <> String.Empty AndAlso IsNumeric(value.Trim()) Then
            Return value.Trim().PadLeft(8, "0")
        Else
            Return value
        End If
    End Function

#End Region

#Region "Hazmat Dropdown Changes"

    Protected Sub HazMatNo_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles HazMatNo.SelectedIndexChanged

        If HazMatNo.SelectedValue = "" Then
            P_HazMat.Visible = True
            HazMatYes.SelectedValue = "X"
        Else
            P_HazMat.Visible = False
            HazMatYes.SelectedValue = ""
        End If

        PerformStageValidation(False, True)

    End Sub

    Protected Sub HazMatYes_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles HazMatYes.SelectedIndexChanged

        If HazMatYes.SelectedValue = "" Then
            HazMatNo.SelectedValue = "X"
            P_HazMat.Visible = False
        Else
            P_HazMat.Visible = True
            HazMatNo.SelectedValue = ""
        End If

        PerformStageValidation(False, True)

    End Sub

#End Region

#Region "Private Brand Dropdown Changes"

    Protected Sub PrivateBrand_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles PrivateBrandLabel.SelectedIndexChanged

        If PrivateBrandLabel.SelectedValue = "" Or PrivateBrandLabel.SelectedValue = "12" Then
            GenerateMichaelsUPC.Visible = False
            GenerateMichaelsUPC.SelectedIndex = 0

            GenerateMichaelsGTIN14.Visible = False  'PMO200141 GTIN14 Enhancements changes Start
        Else
            GenerateMichaelsUPC.Visible = True
            GenerateMichaelsGTIN14.Visible = True  'PMO200141 GTIN14 Enhancements changes Start

            'If hdnPrivateBrand.Value = "" Or hdnPrivateBrand.Value = "12" Then   'automatically check "generate UPC" if going from not private label to private label
            '    GenerateMichaelsUPC.SelectedIndex = 1
            '    GenerateMichaelsGTIN14.SelectedIndex = 1 'PMO200141 GTIN14 Enhancements changes Start
            'End If
        End If

        hdnPrivateBrand.Value = PrivateBrandLabel.SelectedValue

    End Sub

#End Region

    Protected Sub ItemTypeAttribute_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ItemTypeAttribute.SelectedIndexChanged

        Dim lvgs As ListValueGroups = FormHelper.LoadListValues("STOCKSTRAT,STOCKSTRATBASIC,STOCKSTRATSEASONAL,STOCKSTRATALL")


        If StageType = NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStageType.Completed Then
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATALL"), True)
        ElseIf ItemTypeAttribute.SelectedValue = "S" Then
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATSEASONAL"), True)
        ElseIf ItemTypeAttribute.SelectedValue <> "S" And ItemTypeAttribute.SelectedValue <> "" Then
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATBASIC"), True)
        Else
            FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRAT"), True)
        End If


        lvgs.ClearAll()
        lvgs = Nothing

    End Sub
End Class
