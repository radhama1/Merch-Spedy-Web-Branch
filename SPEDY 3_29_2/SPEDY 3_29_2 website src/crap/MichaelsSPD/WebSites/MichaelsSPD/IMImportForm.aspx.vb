Imports System.Configuration
Imports System.Data
Imports System.Data.SqlClient

Imports System.IO
Imports System.Runtime.Serialization.Formatters.Binary
Imports System.Runtime.Serialization
Imports System.Collections.Generic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports BatchRec = NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord
Imports Data = NovaLibra.Coral.Data.Michaels
Imports WebConstants
Imports ItemHelper

Partial Class IMImportForm
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler

#Region "Attributes and Properties"

    Private _callbackArg As String = ""

    Public Const CALLBACK_SEP As String = "{{|}}"

    Private UserID As Integer = 0
    Private _batchID As Long = 0
    Private ImportDetailID As Long = 0
    Private ParentID As Long = 0
    Private WorkFlowStageID As Integer = 0
    Private StageType As Models.WorkflowStageType = Models.WorkflowStageType.General

    Private _isRegitem As Boolean = False
    'Private _canAddToBatch As Boolean = False
    Private _isCFPMCCalc As Boolean = True
    Private _headerItemID As Integer
    Private _headerSKU As String
    Private _headerVendorNumber As Long
    Private _headerLastChangedBy As String
    Private _headerLastChangedOn As String
    Private _IMChanges As List(Of Models.IMChangeRecord) = Nothing
    Private _rowChanges As Models.IMRowChanges = Nothing
    Private _itemDetail As Models.ItemMaintItemDetailFormRecord = Nothing
    Private _readOnly As Boolean = False
    Private _refreshGrid As Boolean = False
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

    Public Property RefreshGrid() As Boolean
        Get
            Return _refreshGrid
        End Get
        Set(ByVal value As Boolean)
            _refreshGrid = value
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

    Private _startupScripts As String = String.Empty
    Public Sub AddStartupScript(ByVal script As String)
        If _startupScripts <> String.Empty Then _startupScripts = _startupScripts & vbCrLf
        _startupScripts = _startupScripts & script
    End Sub

    ' Load up the Metadata for Save
    Private md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
    Private mdTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
    Private mdColumn As NovaLibra.Coral.SystemFrameworks.MetadataColumn

#End Region

#Region "Page Events"

    ' Item Maint Import record form.  Note that this form recalcs fields (via javascript) with the page loads.  The parent Grid does not recalc these fields.
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Me.IsCallback Then

            If Not SecurityCheck() Then
                CloseForm()
            End If

            'Session variable cIMITEMID should contain an Item ID (Edit) or a SKU/VEndorNumber (pipe delimited) (for read only view of a record)
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

            If strTemp.Length = 0 OrElse (strTemp <> "x" And IsNumeric(strTemp) = False) Then
                CloseForm()
            End If

            ' make sure __doPostBack is generated
            ClientScript.GetPostBackEventReference(Me, String.Empty)

            ' callback
            Dim cbReference As String
            cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", "ReceiveServerData", "context")

            Dim callbackScript As String = ""
            callbackScript &= "function CallServer(arg, context)" & "{" & cbReference & "; }"

            Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "CallServer", callbackScript, True)

            'PopulateGlobalVariables(strTemp)
            PopulateGlobalVariables(strTemp, s, v)

            If Not IsPostBack Then
                If StageType = Models.WorkflowStageType.DBC AndAlso UserCanEdit Then
                    ShowRMSFields = True
                Else
                    ShowRMSFields = False
                End If
            End If

            If Not Page.IsPostBack Then

                Initialize()
            Else
                ' --------
                ' POSTBACK
                ' --------
                If Request.Params("__EVENTTARGET") <> "btnUpdate" AndAlso
                    Request.Params("__EVENTTARGET") <> "btnUpdateClose" AndAlso
                    Request.Params("__EVENTTARGET") <> "btnCancel" Then

                    'Activiate Validation
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
                Dim resultBase As String = String.Empty
                Dim resultAlaska As String = String.Empty
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
                End If
                Return "Retail" & CALLBACK_SEP & "1" & CALLBACK_SEP & str(1) & CALLBACK_SEP & resultBase & CALLBACK_SEP & resultAlaska
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
        If _startupScripts <> String.Empty Then
            sb.Append(_startupScripts & vbCrLf)
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

    '    Private Sub PopulateGlobalVariables(ByVal strTemp As String)
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
            'HeaderLastChangedOn = IIf(IsDate(ItemHeader.LastUpdateDate), FormatDateTime(ItemHeader.LastUpdateDate, DateFormat.ShortDate), ItemHeader.LastUpdateDate)

            Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
            Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(ItemHeader.BatchID)
            objMichaelsBatch = Nothing

            If batchDetail.ID > 0 Then
                'Set the global workflow id
                Me.WorkFlowStageID = batchDetail.WorkflowStageID
                'set the global workflow stage type
                Me.StageType = batchDetail.WorkflowStageType
                ' set the IsPack
                Me.IsPack = batchDetail.IsPack
            End If
        Else    ' save for Item load if no itemid is found
            HeaderSKU = sku
            HeaderVendorNumber = VendorNum
        End If

        ' VALIDATE USER
        ValidateUser(batch, StageType)
        If Not UserCanEdit Then ReadOnlyForm = True

        If NoUserAccess Then CloseForm()

    End Sub

    Private Sub Initialize()

        ' load list values
        Dim lvgs As ListValueGroups = FormHelper.LoadListValues("VENDORAGENT,YESNO,ITEMTYPE,ITEMTYPEATTRIB,SKUGROUP,PACKITEMIND,HYBRIDTYPE,HYBRIDSOURCEDC,PREPRICEDUDA,TAXUDA,HAZCONTAINERTYPE,HAZMSDSUOM,RMS_PBL,INVCONTROL,STOCKSTRATALL")

        FormHelper.LoadListFromListValues(ItemTypeAttribute, lvgs.GetListValueGroup("ITEMTYPEATTRIB"), True)
        FormHelper.LoadListFromListValues(SKUGroup, lvgs.GetListValueGroup("SKUGROUP"), True)

        FormHelper.LoadListFromListValues(PackItemIndicator, lvgs.GetListValueGroup("PACKITEMIND"), True)
        'FormHelper.LoadListFromListValues(HybridType, lvgs.GetListValueGroup("HYBRIDTYPE"), True)
        'FormHelper.LoadListFromListValues(HybridSourceDC, lvgs.GetListValueGroup("HYBRIDSOURCEDC"), True)
        FormHelper.LoadListFromListValues(PrePricedUDA, lvgs.GetListValueGroup("PREPRICEDUDA"), True)
        FormHelper.LoadListFromListValues(HazardousContainerType, lvgs.GetListValueGroup("HAZCONTAINERTYPE"), True)
        FormHelper.LoadListFromListValues(HazardousMSDSUOM, lvgs.GetListValueGroup("HAZMSDSUOM"), True)
        'FormHelper.LoadListFromListValues(VendorOrAgent, lvgs.GetListValueGroup("VENDORAGENT"), True)

        VendorOrAgent.Items.Add(New ListItem("Merch Burden", "A"))
        VendorOrAgent.Items.Add(New ListItem("Vendor", "V"))

        ' Required
        FormHelper.LoadListFromListValues(PrePriced, lvgs.GetListValueGroup("YESNO"), False)                            ' -- prePriced must be Y/N
        FormHelper.LoadListFromListValues(TaxUDA, lvgs.GetListValueGroup("TAXUDA"), True, cREQPICK, "", 20)             ' -- Indicate Selection required
        FormHelper.LoadListFromListValues(Hazardous, lvgs.GetListValueGroup("YESNO"), False)                            ' -- Hazardous must be Y/N
        FormHelper.LoadListFromListValues(HazardousFlammable, lvgs.GetListValueGroup("YESNO"), False)                   ' -- HazardousFlammable must be Y/N
        FormHelper.LoadListFromListValues(PrivateBrandLabel, lvgs.GetListValueGroup("RMS_PBL"), True, cREQPICK, "", 20) ' -- Indicate Selection required
        FormHelper.LoadListFromListValues(AutoReplenish, lvgs.GetListValueGroup("YESNO"), False)                        ' -- AutoReplenish must be Y/N
        FormHelper.LoadListFromListValues(AllowStoreOrder, lvgs.GetListValueGroup("YESNO"), False)                      ' -- AllowStoreOrder must be Y/N
        FormHelper.LoadListFromListValues(InventoryControl, lvgs.GetListValueGroup("INVCONTROL"), False)                ' -- InventoryControl must be Y/N
        FormHelper.LoadListFromListValues(Discountable, lvgs.GetListValueGroup("YESNO"), False)                         ' -- Discountable must be Y/N

        ' RMS
        FormHelper.LoadListFromListValues(RMSSellable, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(RMSOrderable, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(RMSInventory, lvgs.GetListValueGroup("YESNO"), True)
        FormHelper.LoadListFromListValues(StockingStrategyCode, lvgs.GetListValueGroup("STOCKSTRATALL"), True)

        'InitStockStratHelper
        InitStockStratHelper()


        lvgs.ClearAll()
        lvgs = Nothing

        'Read values from DB
        PopulateForm()

        'Enable Appropriate Fields
        SetupFields()

        'Init Controls
        InitControls()

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

    ' Simple call. Ctl.ID = Change Recs Field_Name, and extra key fields are defaulted
    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal ItemID As Integer, ByVal ctlID As String,
            Optional ByVal formatStr As String = "", Optional ByVal Percision As Integer = 2, Optional ByVal Check As Boolean = True) As Object

        mdColumn = mdTable.GetColumnByName(ctlID)     ' Find the fieldname to use for this save
        Return CheckandSetControl(IMValue, ItemID, ctlID, ctlID, "", "", "", 0, formatStr, Percision, Check)

    End Function

    ' Moderate call. Ctl.ID = Change Recs Field_Name, but extra key fields are needed to save data
    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal ItemID As Integer, ByVal ctlID As String,
        ByVal COO As String, ByVal UPC As String, ByVal EffectiveDate As String, ByVal Counter As Integer,
        Optional ByVal formatStr As String = "", Optional ByVal Percision As Integer = 2, Optional ByVal Check As Boolean = True) As Object

        mdColumn = mdTable.GetColumnByName(ctlID)     ' Find the fieldname to use for this save
        Return CheckandSetControl(IMValue, ItemID, ctlID, ctlID, COO, UPC, EffectiveDate, Counter, formatStr, Percision, Check)

    End Function


    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal ItemID As Integer, ByVal ChangeField As String, ByVal ctlID As String,
        ByVal COO As String, ByVal UPC As String, ByVal EffectiveDate As String, ByVal Counter As Integer,
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
                ' baseType = "string"     ' for Addtional COOs
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

    Private Function AddCheckbox(ByVal CtlName As String, ByVal index As String) As NovaLibra.Controls.NLCheckBox

        Dim nlCheckbox As NovaLibra.Controls.NLCheckBox = New NovaLibra.Controls.NLCheckBox

        If ReadOnlyForm Then
            nlCheckbox.RenderReadOnly = True
        End If
        nlCheckbox.ChangeControl = False
        nlCheckbox.Attributes.Add("onclick", "javascript:checkNewPrimary()")
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
        nlTextbox.Width = 175
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

    Private Sub PopulateForm()

        Dim delimiter(1) As String, i As Integer
        delimiter(0) = WebConstants.MULTILINE_DELIM

        ' Load Item Record
        Dim itemDetail As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailFormRecord

        ' Used by CheckandSet to verify field is not a minvalue
        mdTable = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)

        ' Load Change Records into Property
        IMChanges = Data.MaintItemMasterData.GetIMChangeRecordsByItemID(HeaderItemID)
        RowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(HeaderItemID)

        Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
        Dim objMichaels As New Data.MaintItemMasterData
        itemFL = objMichaels.GetFieldLocking(AppHelper.GetUserID(), Models.MetadataTable.vwItemMaintItemDetail, AppHelper.GetVendorID(), WorkFlowStageID, True)

        If HeaderItemID > 0 Then    ' Normal if not in Read Only Mode or if In RO Mode and reviewing an item in a batch with matching SKU / Vendor
            itemDetail = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(HeaderItemID, AppHelper.GetVendorID())
        Else
            itemDetail = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(AppHelper.GetVendorID(), HeaderSKU, HeaderVendorNumber)
        End If

        If ((Not itemDetail Is Nothing AndAlso Not ReadOnlyForm AndAlso itemDetail.ID > 0) Or ((Not itemDetail Is Nothing AndAlso ReadOnlyForm))) Then
            hid.Value = itemDetail.ID   ' for save
            If Not VendorCheck(DataHelper.SmartValues(itemDetail.VendorNumber, "integer", False)) Then
                CloseForm()
            End If

            VendorOrAgent.SelectedValue = itemDetail.VendorOrAgent 'CheckandSetControl(itemDetail.VendorOrAgent, itemDetail.ID, VendorOrAgent.ID)
            AgentType.Text = CheckandSetControl(itemDetail.AgentType, itemDetail.ID, AgentType.ID)
            SKUGroup.SelectedValue = itemDetail.SKUGroup
            'RO SKUGroup.SelectedValue = CheckandSetControl(itemDetail.SKUGroup, itemDetail.ID, SKUGroup.ID)
            AllowStoreOrder.SelectedValue = CheckandSetControl(itemDetail.AllowStoreOrder.ToUpper, itemDetail.ID, AllowStoreOrder.ID)
            PackItemIndicator.SelectedValue = CheckandSetControl(itemDetail.PackItemIndicator.ToUpper, itemDetail.ID, PackItemIndicator.ID)
            ItemTypeAttribute.SelectedValue = itemDetail.ItemTypeAttribute
            InventoryControl.SelectedValue = CheckandSetControl(itemDetail.InventoryControl.ToUpper, itemDetail.ID, InventoryControl.ID)
            Discountable.SelectedValue = CheckandSetControl(itemDetail.Discountable.ToUpper, itemDetail.ID, Discountable.ID)
            AutoReplenish.SelectedValue = CheckandSetControl(itemDetail.AutoReplenish.ToUpper, itemDetail.ID, AutoReplenish.ID)
            PrePriced.SelectedValue = CheckandSetControl(itemDetail.PrePriced, itemDetail.ID, PrePriced.ID)

            TaxUDA.SelectedValue = CheckandSetControl(itemDetail.TaxUDA, itemDetail.ID, TaxUDA.ID)
            TaxValueUDA.Text = CheckandSetControl(itemDetail.TaxValueUDA, itemDetail.ID, TaxValueUDA.ID)

            PrePricedUDA.SelectedValue = CheckandSetControl(itemDetail.PrePricedUDA.ToUpper, itemDetail.ID, PrePricedUDA.ID)
            'HybridType.SelectedValue = CheckandSetControl(itemDetail.HybridType, itemDetail.ID, HybridType.ID)
            'HybridSourceDC.SelectedValue = CheckandSetControl(itemDetail.HybridSourceDC, itemDetail.ID, HybridSourceDC.ID)
            StockingStrategyCode.SelectedValue = CheckandSetControl(itemDetail.StockingStrategyCode, itemDetail.ID, StockingStrategyCode.ID)
            Season.SelectedValue = CheckandSetControl(itemDetail.Season, itemDetail.ID, Season.ID)
            If itemDetail.PrimaryVendor Then
                PrimaryVendor.SelectedValue = "PRIMARY"
            Else
                PrimaryVendor.SelectedValue = "SECONDARY"
            End If

            CoinBattery.SelectedValue = CheckandSetControl(itemDetail.CoinBattery, itemDetail.ID, CoinBattery.ID)
            TSSA.SelectedValue = CheckandSetControl(itemDetail.TSSA, itemDetail.ID, TSSA.ID)
            CSA.SelectedValue = CheckandSetControl(itemDetail.CSA, itemDetail.ID, CSA.ID)
            UL.SelectedValue = CheckandSetControl(itemDetail.UL, itemDetail.ID, UL.ID)
            LicenceAgreement.SelectedValue = CheckandSetControl(itemDetail.LicenceAgreement, itemDetail.ID, LicenceAgreement.ID)
            FumigationCertificate.SelectedValue = CheckandSetControl(itemDetail.FumigationCertificate, itemDetail.ID, FumigationCertificate.ID)
            PhytoTemporaryShipment.SelectedValue = CheckandSetControl(itemDetail.PhytoTemporaryShipment, itemDetail.ID, PhytoTemporaryShipment.ID)
            KILNDriedCertificate.SelectedValue = CheckandSetControl(itemDetail.KILNDriedCertificate, itemDetail.ID, KILNDriedCertificate.ID)
            ChinaComInspecNumAndCCIBStickers.SelectedValue = CheckandSetControl(itemDetail.ChinaComInspecNumAndCCIBStickers, itemDetail.ID, ChinaComInspecNumAndCCIBStickers.ID)
            OriginalVisa.SelectedValue = CheckandSetControl(itemDetail.OriginalVisa, itemDetail.ID, OriginalVisa.ID)
            TextileDeclarationMidCode.SelectedValue = CheckandSetControl(itemDetail.TextileDeclarationMidCode, itemDetail.ID, TextileDeclarationMidCode.ID)
            QuotaChargeStatement.SelectedValue = CheckandSetControl(itemDetail.QuotaChargeStatement, itemDetail.ID, QuotaChargeStatement.ID)
            MSDS.SelectedValue = CheckandSetControl(itemDetail.MSDS, itemDetail.ID, MSDS.ID)
            TSCA.SelectedValue = CheckandSetControl(itemDetail.TSCA, itemDetail.ID, TSCA.ID)
            DropBallTestCert.SelectedValue = CheckandSetControl(itemDetail.DropBallTestCert, itemDetail.ID, DropBallTestCert.ID)
            ManMedicalDeviceListing.SelectedValue = CheckandSetControl(itemDetail.ManMedicalDeviceListing, itemDetail.ID, ManMedicalDeviceListing.ID)
            ManFDARegistration.SelectedValue = CheckandSetControl(itemDetail.ManFDARegistration, itemDetail.ID, ManFDARegistration.ID)
            CopyRightIndemnification.SelectedValue = CheckandSetControl(itemDetail.CopyRightIndemnification, itemDetail.ID, CopyRightIndemnification.ID)
            FishWildLifeCert.SelectedValue = CheckandSetControl(itemDetail.FishWildLifeCert, itemDetail.ID, FishWildLifeCert.ID)
            Proposition65LabelReq.SelectedValue = CheckandSetControl(itemDetail.Proposition65LabelReq, itemDetail.ID, Proposition65LabelReq.ID)
            CCCR.SelectedValue = CheckandSetControl(itemDetail.CCCR, itemDetail.ID, CCCR.ID)
            FormaldehydeCompliant.SelectedValue = CheckandSetControl(itemDetail.FormaldehydeCompliant, itemDetail.ID, FormaldehydeCompliant.ID)
            Hazardous.SelectedValue = CheckandSetControl(itemDetail.Hazardous.ToUpper, itemDetail.ID, Hazardous.ID)
            HazardousFlammable.SelectedValue = CheckandSetControl(itemDetail.HazardousFlammable.ToUpper, itemDetail.ID, HazardousFlammable.ID)
            HazardousContainerType.SelectedValue = CheckandSetControl(itemDetail.HazardousContainerType.ToUpper, itemDetail.ID, HazardousContainerType.ID)
            HazardousMSDSUOM.SelectedValue = CheckandSetControl(itemDetail.HazardousMSDSUOM, itemDetail.ID, HazardousMSDSUOM.ID)


            MinimumOrderQuantity.Text = CheckandSetControl(itemDetail.MinimumOrderQuantity, itemDetail.ID, MinimumOrderQuantity.ID)

            VendorMinOrderAmount.Text = CheckandSetControl(itemDetail.VendorMinOrderAmount, itemDetail.ID, VendorMinOrderAmount.ID, "formatnumber")


            ProductIdentifiesAsCosmetic.SelectedValue = CheckandSetControl(itemDetail.ProductIdentifiesAsCosmetic, itemDetail.ID, ProductIdentifiesAsCosmetic.ID)


            'PMO200141 GTIN14 Enhancements changes
            InnerGTIN.Text = CheckandSetControl(itemDetail.InnerGTIN, itemDetail.ID, InnerGTIN.ID)
            CaseGTIN.Text = CheckandSetControl(itemDetail.CaseGTIN, itemDetail.ID, CaseGTIN.ID)

            Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
            Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(itemDetail.BatchID)
            objMichaelsBatch = Nothing

            'Update the header banner at the top of the page
            If itemDetail.BatchID > 0 Then
                batch.Text = " &nbsp;|&nbsp; Log ID: " & itemDetail.BatchID.ToString()
                Select Case batchDetail.PackType.ToUpper
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
            If batchDetail.VendorName <> "" Then
                batchVendorName.Text = " &nbsp;|&nbsp; " & "Vendor: " & batchDetail.VendorName
            End If
            If batchDetail.WorkflowStageName <> "" Then
                stageName.Text = " &nbsp;|&nbsp; " & "Stage: " & batchDetail.WorkflowStageName
            End If
            If HeaderLastChangedOn <> "" Then
                lastUpdated.Text = " &nbsp;|&nbsp; " & "Last Updated: " & HeaderLastChangedOn   '.ToString("M/d/yyyy")
                If HeaderLastChangedBy <> "" Then
                    lastUpdated.Text += " by " & HeaderLastChangedBy
                End If
            End If

            'Set multiple line textboxes
            DetailInvoiceCustomsDesc0.Text = CheckandSetControl(itemDetail.DetailInvoiceCustomsDesc0, itemDetail.ID, DetailInvoiceCustomsDesc0.ID)
            DetailInvoiceCustomsDesc1.Text = CheckandSetControl(itemDetail.DetailInvoiceCustomsDesc1, itemDetail.ID, DetailInvoiceCustomsDesc1.ID)
            DetailInvoiceCustomsDesc2.Text = CheckandSetControl(itemDetail.DetailInvoiceCustomsDesc2, itemDetail.ID, DetailInvoiceCustomsDesc2.ID)
            DetailInvoiceCustomsDesc3.Text = CheckandSetControl(itemDetail.DetailInvoiceCustomsDesc3, itemDetail.ID, DetailInvoiceCustomsDesc3.ID)
            DetailInvoiceCustomsDesc4.Text = CheckandSetControl(itemDetail.DetailInvoiceCustomsDesc4, itemDetail.ID, DetailInvoiceCustomsDesc4.ID)
            DetailInvoiceCustomsDesc5.Text = CheckandSetControl(itemDetail.DetailInvoiceCustomsDesc5, itemDetail.ID, DetailInvoiceCustomsDesc5.ID)
            ComponentMaterialBreakdown0.Text = CheckandSetControl(itemDetail.ComponentMaterialBreakdown0, itemDetail.ID, ComponentMaterialBreakdown0.ID)
            ComponentMaterialBreakdown1.Text = CheckandSetControl(itemDetail.ComponentMaterialBreakdown1, itemDetail.ID, ComponentMaterialBreakdown1.ID)
            ComponentMaterialBreakdown2.Text = CheckandSetControl(itemDetail.ComponentMaterialBreakdown2, itemDetail.ID, ComponentMaterialBreakdown2.ID)
            ComponentMaterialBreakdown3.Text = CheckandSetControl(itemDetail.ComponentMaterialBreakdown3, itemDetail.ID, ComponentMaterialBreakdown3.ID)
            ComponentMaterialBreakdown4.Text = CheckandSetControl(itemDetail.ComponentMaterialBreakdown4, itemDetail.ID, ComponentMaterialBreakdown4.ID)
            ComponentConstructionMethod0.Text = CheckandSetControl(itemDetail.ComponentConstructionMethod0, itemDetail.ID, ComponentConstructionMethod0.ID)
            ComponentConstructionMethod1.Text = CheckandSetControl(itemDetail.ComponentConstructionMethod1, itemDetail.ID, ComponentConstructionMethod1.ID)
            ComponentConstructionMethod2.Text = CheckandSetControl(itemDetail.ComponentConstructionMethod2, itemDetail.ID, ComponentConstructionMethod2.ID)
            ComponentConstructionMethod3.Text = CheckandSetControl(itemDetail.ComponentConstructionMethod3, itemDetail.ID, ComponentConstructionMethod3.ID)

            'Dept.Text = CheckandSetControl(itemDetail.DepartmentNum, itemDetail.ID, Dept.ID)
            Dept.Text = itemDetail.DepartmentNum
            'Me.Class.Text = CheckandSetControl(itemDetail.ClassNum, itemDetail.ID, Me.ID)
            Me.Class.Text = itemDetail.ClassNum

            'SubClass.Text = CheckandSetControl(itemDetail.SubClassNum, itemDetail.ID, SubClass.ID)
            SubClass.Text = itemDetail.SubClassNum

            PrimaryUPC.Text = FormatUPCValue(itemDetail.PrimaryUPC)     ' R/O field so format OK
            MichaelsSKU.Text = FormatSKUValue(itemDetail.SKU)           ' R/O field so format OK

            'Add Quote Reference Number
            QuoteReferenceNumber.Text = CheckandSetControl(itemDetail.QuoteReferenceNumber, itemDetail.ID, QuoteReferenceNumber.ID)

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

            PlanogramName.Text = CheckandSetControl(itemDetail.PlanogramName, itemDetail.ID, PlanogramName.ID, "stringrsu")
            'PlanogramName.Text = itemDetail.PlanogramName

            ' vendor number and vendor name
            VendorNumber.Text = itemDetail.VendorNumber

            VendorName.Text = itemDetail.VendorName
            'VendorNameLabel.Text = itemDetail.VendorName

            ItemDesc.Text = CheckandSetControl(itemDetail.ItemDesc, itemDetail.ID, ItemDesc.ID, "stringrsu")
            PrivateBrandLabel.SelectedValue = CheckandSetControl(itemDetail.PrivateBrandLabel, itemDetail.ID, PrivateBrandLabel.ID)

            'PMO200141 GTIN14 Enhancements changes
            If PrivateBrandLabel.SelectedValue <> "12" Then
                InnerGTIN.RenderReadOnly = True
                CaseGTIN.RenderReadOnly = True
            End If

            InnerGTIN.Text = CheckandSetControl(itemDetail.InnerGTIN, itemDetail.ID, InnerGTIN.ID)
            CaseGTIN.Text = CheckandSetControl(itemDetail.CaseGTIN, itemDetail.ID, CaseGTIN.ID)

            VendorAddress1.Text = CheckandSetControl(itemDetail.VendorAddress1, itemDetail.ID, VendorAddress1.ID)
            VendorAddress2.Text = CheckandSetControl(itemDetail.VendorAddress2, itemDetail.ID, VendorAddress2.ID)
            VendorAddress3.Text = CheckandSetControl(itemDetail.VendorAddress3, itemDetail.ID, VendorAddress3.ID)
            VendorAddress4.Text = CheckandSetControl(itemDetail.VendorAddress4, itemDetail.ID, VendorAddress4.ID)
            VendorContactName.Text = CheckandSetControl(itemDetail.VendorContactName, itemDetail.ID, VendorContactName.ID)
            VendorContactPhone.Text = CheckandSetControl(itemDetail.VendorContactPhone, itemDetail.ID, VendorContactPhone.ID)
            VendorContactEmail.Text = CheckandSetControl(itemDetail.VendorContactEmail, itemDetail.ID, VendorContactEmail.ID)
            VendorContactFax.Text = CheckandSetControl(itemDetail.VendorContactFax, itemDetail.ID, VendorContactFax.ID)
            ManufactureName.Text = CheckandSetControl(itemDetail.ManufactureName, itemDetail.ID, ManufactureName.ID)
            ManufactureAddress1.Text = CheckandSetControl(itemDetail.ManufactureAddress1, itemDetail.ID, ManufactureAddress1.ID)
            ManufactureAddress2.Text = CheckandSetControl(itemDetail.ManufactureAddress2, itemDetail.ID, ManufactureAddress2.ID)
            ManufactureContact.Text = CheckandSetControl(itemDetail.ManufactureContact, itemDetail.ID, ManufactureContact.ID)
            ManufacturePhone.Text = CheckandSetControl(itemDetail.ManufacturePhone, itemDetail.ID, ManufacturePhone.ID)
            ManufactureEmail.Text = CheckandSetControl(itemDetail.ManufactureEmail, itemDetail.ID, ManufactureEmail.ID)
            ManufactureFax.Text = CheckandSetControl(itemDetail.ManufactureFax, itemDetail.ID, ManufactureFax.ID)
            AgentContact.Text = CheckandSetControl(itemDetail.AgentContact, itemDetail.ID, AgentContact.ID)
            AgentPhone.Text = CheckandSetControl(itemDetail.AgentPhone, itemDetail.ID, AgentPhone.ID)
            AgentEmail.Text = CheckandSetControl(itemDetail.AgentEmail, itemDetail.ID, AgentEmail.ID)
            AgentFax.Text = CheckandSetControl(itemDetail.AgentFax, itemDetail.ID, AgentFax.ID)
            VendorStyleNum.Text = CheckandSetControl(itemDetail.VendorStyleNum, itemDetail.ID, VendorStyleNum.ID, "stringrsu")
            HarmonizedCodeNumber.Text = CheckandSetControl(itemDetail.HarmonizedCodeNumber, itemDetail.ID, HarmonizedCodeNumber.ID)
            CanadaHarmonizedCodeNumber.Text = CheckandSetControl(itemDetail.CanadaHarmonizedCodeNumber, itemDetail.ID, CanadaHarmonizedCodeNumber.ID)
            IndividualItemPackaging.Text = CheckandSetControl(itemDetail.IndividualItemPackaging, itemDetail.ID, IndividualItemPackaging.ID)
            If Me.IsPack Then
                QtyInPack.Text = CheckandSetControl(itemDetail.QtyInPack, itemDetail.ID, QtyInPack.ID)
            Else
                QtyInPackRow.Visible = False
            End If
            EachesMasterCase.Text = CheckandSetControl(itemDetail.EachesMasterCase, itemDetail.ID, EachesMasterCase.ID)
            EachesInnerPack.Text = CheckandSetControl(itemDetail.EachesInnerPack, itemDetail.ID, EachesInnerPack.ID)

            EachCaseWeight.Text = CheckandSetControl(itemDetail.EachCaseWeight, itemDetail.ID, EachCaseWeight.ID, "formatnumber4")
            EachCaseLength.Text = CheckandSetControl(itemDetail.EachCaseLength, itemDetail.ID, EachCaseLength.ID, "formatnumber4")
            EachCaseWidth.Text = CheckandSetControl(itemDetail.EachCaseWidth, itemDetail.ID, EachCaseWidth.ID, "formatnumber4")
            EachCaseHeight.Text = CheckandSetControl(itemDetail.EachCaseHeight, itemDetail.ID, EachCaseHeight.ID, "formatnumber4")

            ' cubic feet per each carton
            EachCaseCubeEdit.Text = CheckandSetControl(itemDetail.EachCaseCube, itemDetail.ID, EachCaseCube.ID, EachCaseCubeEdit.ID, "", "", "", 0, "formatnumber4")
            EachCaseCube.Value = EachCaseCubeEdit.Text

            InnerCaseWeight.Text = CheckandSetControl(itemDetail.InnerCaseWeight, itemDetail.ID, InnerCaseWeight.ID, "formatnumber4")
            InnerCaseLength.Text = CheckandSetControl(itemDetail.InnerCaseLength, itemDetail.ID, InnerCaseLength.ID, "formatnumber4")
            InnerCaseWidth.Text = CheckandSetControl(itemDetail.InnerCaseWidth, itemDetail.ID, InnerCaseWidth.ID, "formatnumber4")
            InnerCaseHeight.Text = CheckandSetControl(itemDetail.InnerCaseHeight, itemDetail.ID, InnerCaseHeight.ID, "formatnumber4")
            MasterCaseLength.Text = CheckandSetControl(itemDetail.MasterCaseLength, itemDetail.ID, MasterCaseLength.ID, "formatnumber4")
            MasterCaseWidth.Text = CheckandSetControl(itemDetail.MasterCaseWidth, itemDetail.ID, MasterCaseWidth.ID, "formatnumber4")
            MasterCaseHeight.Text = CheckandSetControl(itemDetail.MasterCaseHeight, itemDetail.ID, MasterCaseHeight.ID, "formatnumber4")

            ' cubic feet per master carton
            MasterCaseCubeEdit.Text = CheckandSetControl(itemDetail.MasterCaseCube, itemDetail.ID, MasterCaseCube.ID, MasterCaseCubeEdit.ID, "", "", "", 0, "formatnumber4")
            MasterCaseCube.Value = MasterCaseCubeEdit.Text

            MasterCaseWeight.Text = CheckandSetControl(itemDetail.MasterCaseWeight, itemDetail.ID, MasterCaseWeight.ID, "formatnumber4")

            ' cubic feet per inner carton
            InnerCaseCubeEdit.Text = CheckandSetControl(itemDetail.InnerCaseCube, itemDetail.ID, InnerCaseCube.ID, InnerCaseCubeEdit.ID, "", "", "", 0, "formatnumber4")
            InnerCaseCube.Value = InnerCaseCubeEdit.Text

            DisplayerCost.Text = CheckandSetControl(itemDetail.DisplayerCost, itemDetail.ID, DisplayerCost.ID, "formatnumber4")
            ProductCost.Text = CheckandSetControl(itemDetail.ProductCost, itemDetail.ID, ProductCost.ID, "formatnumber4")

            FOBShippingPointEdit.Text = CheckandSetControl(itemDetail.FOBShippingPoint, itemDetail.ID, FOBShippingPoint.ID, FOBShippingPointEdit.ID, "", "", "", 0, "formatnumber4")
            FOBShippingPoint.Value = FOBShippingPointEdit.Text

            DutyPercent.Text = CheckandSetControl(itemDetail.DutyPercent, itemDetail.ID, DutyPercent.ID, "percentvalue")

            DutyAmountEdit.Text = CheckandSetControl(itemDetail.DutyAmount, itemDetail.ID, DutyAmount.ID, DutyAmountEdit.ID, "", "", "", 0, "formatnumber4")
            DutyAmount.Value = DutyAmountEdit.Text

            AdditionalDutyComment.Text = CheckandSetControl(itemDetail.AdditionalDutyComment, itemDetail.ID, AdditionalDutyComment.ID)
            AdditionalDutyAmount.Text = CheckandSetControl(itemDetail.AdditionalDutyAmount, itemDetail.ID, AdditionalDutyAmount.ID, "formatnumber4")

            SuppTariffPercent.Text = CheckandSetControl(itemDetail.SuppTariffPercent, itemDetail.ID, SuppTariffPercent.ID, "percentvalue")

            SuppTariffAmountEdit.Text = CheckandSetControl(itemDetail.SuppTariffAmount, itemDetail.ID, SuppTariffAmount.ID, SuppTariffAmountEdit.ID, "", "", "", 0, "formatnumber4")
            SuppTariffAmount.Value = SuppTariffAmountEdit.Text

            OceanFreightAmount.Text = CheckandSetControl(itemDetail.OceanFreightAmount, itemDetail.ID, OceanFreightAmount.ID, "formatnumber4")

            OceanFreightComputedAmountEdit.Text = CheckandSetControl(itemDetail.OceanFreightComputedAmount, itemDetail.ID, OceanFreightComputedAmount.ID, OceanFreightComputedAmountEdit.ID, "", "", "", 0, "formatnumber4")
            OceanFreightComputedAmount.Value = OceanFreightComputedAmountEdit.Text

            AgentCommissionPercent.Text = CheckandSetControl(itemDetail.AgentCommissionPercent, itemDetail.ID, AgentCommissionPercent.ID, "percentvalue")

            AgentCommissionAmountEdit.Text = CheckandSetControl(itemDetail.AgentCommissionAmount, itemDetail.ID, AgentCommissionAmount.ID, AgentCommissionAmountEdit.ID, "", "", "", 0, "formatnumber4")
            AgentCommissionAmount.Value = AgentCommissionAmountEdit.Text

            OtherImportCostsPercentEdit.Text = CheckandSetControl(itemDetail.OtherImportCostsPercent, itemDetail.ID, OtherImportCostsPercent.ID, OtherImportCostsPercentEdit.ID, "", "", "", 0, "percentvalue")
            OtherImportCostsPercent.Value = OtherImportCostsPercentEdit.Text

            OtherImportCostsAmountEdit.Text = CheckandSetControl(itemDetail.OtherImportCostsAmount, itemDetail.ID, OtherImportCostsAmount.ID, OtherImportCostsAmountEdit.ID, "", "", "", 0, "formatnumber4")
            OtherImportCostsAmount.Value = OtherImportCostsAmountEdit.Text

            'PackagingCostAmount.Text = IIf(itemDetail.PackagingCostAmount.Trim.Length > 0, DataHelper.SmartValues(itemDetail.PackagingCostAmount, "decimal", True, String.Empty, 4), itemDetail.PackagingCostAmount)

            PackagingCostAmount.Value = String.Empty

            ImportBurdenEdit.Text = CheckandSetControl(itemDetail.ImportBurden, itemDetail.ID, ImportBurden.ID, ImportBurdenEdit.ID, "", "", "", 0, "formatnumber4")
            ImportBurden.Value = ImportBurdenEdit.Text

            WarehouseLandedCostEdit.Text = CheckandSetControl(itemDetail.WarehouseLandedCost, itemDetail.ID, WarehouseLandedCost.ID, WarehouseLandedCostEdit.ID, "", "", "", 0, "formatnumber4")
            WarehouseLandedCost.Value = WarehouseLandedCostEdit.Text

            ShippingPoint.Text = CheckandSetControl(itemDetail.ShippingPoint, itemDetail.ID, ShippingPoint.ID)
            CountryOfOrigin.Value = CheckandSetControl(itemDetail.CountryOfOrigin, itemDetail.ID, CountryOfOrigin.ID)
            CountryOfOriginName.Text = CheckandSetControl(itemDetail.CountryOfOriginName, itemDetail.ID, CountryOfOriginName.ID)


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
                nlCheckbox.Checked = (newPrimaryName = addCOORec.CountryOfOriginName)

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

                'c32.Style.Add("padding-left", "2px")
                c32.ColumnSpan = 2

                r.Cells.Add(c)
                r.Cells.Add(c32)
                r.ID = cEMPTYCOUNTRY
                additionalCOOTbl.Rows.Add(r)

                Dim r1 As New TableRow(), c11 As New TableCell, c12 As New TableCell
                COOString = "<a href=""#"" ID=""additionalCOOLink"" title=""Click to Add a New Country"" onclick=""addAdditionalCOO();return false;"">[+]</a>"
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

            VendorComments.Text = CheckandSetControl(itemDetail.VendorComments, itemDetail.ID, VendorComments.ID)
            StockCategory.Text = CheckandSetControl(itemDetail.StockCategory, itemDetail.ID, StockCategory.ID)
            FreightTerms.Text = CheckandSetControl(itemDetail.FreightTerms, itemDetail.ID, FreightTerms.ID)

            StoreSupplierZoneGroup.Text = CheckandSetControl(itemDetail.StoreSupplierZoneGroup, itemDetail.ID, StoreSupplierZoneGroup.ID)
            WHSSupplierZoneGroup.Text = CheckandSetControl(itemDetail.WHSSupplierZoneGroup, itemDetail.ID, WHSSupplierZoneGroup.ID)

            ' Dup field not saved in Change records. Load it though from FOBShippingPoint
            FirstCostEdit.Text = CheckandSetControl(itemDetail.FOBShippingPoint, itemDetail.ID, FOBShippingPoint.ID, FirstCostEdit.ID, "", "", "", 0, "formatnumber4")
            FirstCost.Value = FirstCostEdit.Text

            ' Dup field not saved in Change records. Load it from ImportBurden 
            StoreTotalImportBurdenEdit.Text = CheckandSetControl(itemDetail.ImportBurden, itemDetail.ID, ImportBurden.ID, StoreTotalImportBurdenEdit.ID, "", "", "", 0, "formatnumber4")
            StoreTotalImportBurden.Value = StoreTotalImportBurdenEdit.Text

            OutboundFreightEdit.Text = CheckandSetControl(itemDetail.OutboundFreight, itemDetail.ID, OutboundFreight.ID, OutboundFreightEdit.ID, "", "", "", 0, "formatnumber4")
            OutboundFreight.Value = OutboundFreightEdit.Text

            NinePercentWhseChargeEdit.Text = CheckandSetControl(itemDetail.NinePercentWhseCharge, itemDetail.ID, NinePercentWhseCharge.ID, NinePercentWhseChargeEdit.ID, "", "", "", 0, "formatnumber4")
            NinePercentWhseCharge.Value = NinePercentWhseChargeEdit.Text

            ' Dup field not saved in change control
            TotalWhseLandedCostEdit.Text = CheckandSetControl(itemDetail.WarehouseLandedCost, itemDetail.ID, WarehouseLandedCost.ID, TotalWhseLandedCostEdit.ID, "", "", "", 0, "formatnumber4")
            TotalWhseLandedCost.Value = TotalWhseLandedCostEdit.Text

            TotalStoreLandedCostEdit.Text = CheckandSetControl(itemDetail.TotalStoreLandedCost, itemDetail.ID, TotalStoreLandedCost.ID, TotalStoreLandedCostEdit.ID, "", "", "", 0, "formatnumber4")
            TotalStoreLandedCost.Value = TotalStoreLandedCostEdit.Text

            If itemDetail.Base1Retail <> Decimal.MinValue Then
                Base1Retail.Text = DataHelper.SmartValues(itemDetail.Base1Retail, "formatnumber", True, String.Empty)
            End If

            If itemDetail.Base2Retail <> Decimal.MinValue Then
                Base2RetailEdit.Text = DataHelper.SmartValues(itemDetail.Base2Retail, "formatnumber", True, String.Empty)
                Base2Retail.Value = Base2RetailEdit.Text
            End If

            If itemDetail.TestRetail <> Decimal.MinValue Then
                TestRetailEdit.Text = DataHelper.SmartValues(itemDetail.TestRetail, "formatnumber", True, String.Empty)
                TestRetail.Value = TestRetailEdit.Text
            End If

            If itemDetail.AlaskaRetail <> Decimal.MinValue Then
                AlaskaRetail.Text = DataHelper.SmartValues(itemDetail.AlaskaRetail, "formatnumber", True, String.Empty)
            End If

            If itemDetail.CanadaRetail <> Decimal.MinValue Then
                CanadaRetail.Text = DataHelper.SmartValues(itemDetail.CanadaRetail, "formatnumber", True, String.Empty)
            End If

            If itemDetail.High2Retail <> Decimal.MinValue Then
                High2RetailEdit.Text = DataHelper.SmartValues(itemDetail.High2Retail, "formatnumber", True, String.Empty)
                High2Retail.Value = High2RetailEdit.Text
            End If

            If itemDetail.High3Retail <> Decimal.MinValue Then
                High3RetailEdit.Text = DataHelper.SmartValues(itemDetail.High3Retail, "formatnumber", True, String.Empty, 2)
                High3Retail.Value = High3RetailEdit.Text
            End If

            If itemDetail.SmallMarketRetail <> Decimal.MinValue Then
                SmallMarketRetailEdit.Text = DataHelper.SmartValues(itemDetail.SmallMarketRetail, "formatnumber", True, String.Empty, 2)
                SmallMarketRetail.Value = SmallMarketRetailEdit.Text
            End If

            If itemDetail.High1Retail <> Decimal.MinValue Then
                High1RetailEdit.Text = DataHelper.SmartValues(itemDetail.High1Retail, "formatnumber")
                High1Retail.Value = High1RetailEdit.Text
            End If

            If itemDetail.Base3Retail <> Decimal.MinValue Then
                Base3RetailEdit.Text = DataHelper.SmartValues(itemDetail.Base3Retail, "formatnumber")
                Base3Retail.Value = Base3RetailEdit.Text
            End If

            If itemDetail.Low1Retail <> Decimal.MinValue Then
                Low1RetailEdit.Text = DataHelper.SmartValues(itemDetail.Low1Retail, "formatnumber")
                Low1Retail.Value = Base3RetailEdit.Text
            End If

            If itemDetail.Low2Retail <> Decimal.MinValue Then
                Low2RetailEdit.Text = DataHelper.SmartValues(itemDetail.Low2Retail, "formatnumber")
                Low2Retail.Value = Low2RetailEdit.Text
            End If

            If itemDetail.ManhattanRetail <> Decimal.MinValue Then
                ManhattanRetailEdit.Text = DataHelper.SmartValues(itemDetail.ManhattanRetail, "formatnumber")
                ManhattanRetail.Value = ManhattanRetailEdit.Text
            End If

            If itemDetail.QuebecRetail <> Decimal.MinValue Then
                QuebecRetailEdit.Text = DataHelper.SmartValues(itemDetail.QuebecRetail, "formatnumber")
                QuebecRetail.Value = QuebecRetailEdit.Text
            End If

            If itemDetail.PuertoRicoRetail <> Decimal.MinValue Then
                PuertoRicoRetailEdit.Text = DataHelper.SmartValues(itemDetail.PuertoRicoRetail, "formatnumber")
                PuertoRicoRetail.Value = PuertoRicoRetailEdit.Text
            End If

            ' Clearance Prices
            If itemDetail.Base1Clearance <> Decimal.MinValue AndAlso itemDetail.Base1Clearance <> itemDetail.Base1Retail Then
                Base1Clearance.Text = DataHelper.SmartValues(itemDetail.Base1Clearance, "formatnumber", True, String.Empty)
            End If

            If itemDetail.Base2Clearance <> Decimal.MinValue AndAlso itemDetail.Base2Clearance <> itemDetail.Base2Retail Then
                Base2ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Base2Clearance, "formatnumber", True, String.Empty)
                Base2Clearance.Value = Base2ClearanceEdit.Text
            End If

            If itemDetail.TestClearance <> Decimal.MinValue AndAlso itemDetail.TestClearance <> itemDetail.TestRetail Then
                TestClearanceEdit.Text = DataHelper.SmartValues(itemDetail.TestClearance, "formatnumber", True, String.Empty)
                TestClearance.Value = TestClearanceEdit.Text
            End If

            If itemDetail.AlaskaClearance <> Decimal.MinValue AndAlso itemDetail.AlaskaClearance <> itemDetail.AlaskaRetail Then
                AlaskaClearance.Text = DataHelper.SmartValues(itemDetail.AlaskaClearance, "formatnumber", True, String.Empty)
            End If

            If itemDetail.CanadaClearance <> Decimal.MinValue AndAlso itemDetail.CanadaClearance <> itemDetail.CanadaRetail Then
                CanadaClearance.Text = DataHelper.SmartValues(itemDetail.CanadaClearance, "formatnumber", True, String.Empty)
            End If

            If itemDetail.High2Clearance <> Decimal.MinValue AndAlso itemDetail.High2Clearance <> itemDetail.High2Retail Then
                High2ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.High2Clearance, "formatnumber", True, String.Empty)
                High2Clearance.Value = High2ClearanceEdit.Text
            End If

            If itemDetail.High3Clearance <> Decimal.MinValue AndAlso itemDetail.High3Clearance <> itemDetail.High3Retail Then
                High3ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.High3Clearance, "formatnumber", True, String.Empty, 2)
                High3Clearance.Value = High3ClearanceEdit.Text
            End If

            If itemDetail.SmallMarketClearance <> Decimal.MinValue AndAlso itemDetail.SmallMarketClearance <> itemDetail.SmallMarketRetail Then
                SmallMarketClearanceEdit.Text = DataHelper.SmartValues(itemDetail.SmallMarketClearance, "formatnumber", True, String.Empty, 2)
                SmallMarketClearance.Value = SmallMarketClearanceEdit.Text
            End If

            If itemDetail.High1Clearance <> Decimal.MinValue AndAlso itemDetail.High1Clearance <> itemDetail.High1Retail Then
                High1ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.High1Clearance, "formatnumber")
                High1Clearance.Value = High1ClearanceEdit.Text
            End If

            If itemDetail.Base3Clearance <> Decimal.MinValue AndAlso itemDetail.Base3Clearance <> itemDetail.Base3Retail Then
                Base3ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Base3Clearance, "formatnumber")
                Base3Clearance.Value = Base3ClearanceEdit.Text
            End If

            If itemDetail.Low1Clearance <> Decimal.MinValue AndAlso itemDetail.Low1Clearance <> itemDetail.Low1Retail Then
                Low1ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Low1Clearance, "formatnumber")
                Low1Clearance.Value = Base3ClearanceEdit.Text
            End If

            If itemDetail.Low2Clearance <> Decimal.MinValue AndAlso itemDetail.Low2Clearance <> itemDetail.Low2Retail Then
                Low2ClearanceEdit.Text = DataHelper.SmartValues(itemDetail.Low2Clearance, "formatnumber")
                Low2Clearance.Value = Low2ClearanceEdit.Text
            End If

            If itemDetail.ManhattanClearance <> Decimal.MinValue AndAlso itemDetail.ManhattanClearance <> itemDetail.ManhattanRetail Then
                ManhattanClearanceEdit.Text = DataHelper.SmartValues(itemDetail.ManhattanClearance, "formatnumber")
                ManhattanClearance.Value = ManhattanClearanceEdit.Text
            End If

            If itemDetail.QuebecClearance <> Decimal.MinValue AndAlso itemDetail.QuebecClearance <> itemDetail.QuebecRetail Then
                QuebecClearanceEdit.Text = DataHelper.SmartValues(itemDetail.QuebecClearance, "formatnumber")
                QuebecClearance.Value = QuebecClearanceEdit.Text
            End If

            If itemDetail.PuertoRicoClearance <> Decimal.MinValue AndAlso itemDetail.PuertoRicoClearance <> itemDetail.PuertoRicoRetail Then
                PuertoRicoClearanceEdit.Text = DataHelper.SmartValues(itemDetail.PuertoRicoClearance, "formatnumber")
                PuertoRicoClearance.Value = PuertoRicoClearanceEdit.Text
            End If
            '===================================================================

            HazardousManufacturerCountry.Text = CheckandSetControl(itemDetail.HazardousManufacturerCountry, itemDetail.ID, HazardousManufacturerCountry.ID)
            HazardousManufacturerName.Text = CheckandSetControl(itemDetail.HazardousManufacturerName, itemDetail.ID, HazardousManufacturerName.ID)
            HazardousManufacturerCity.Text = CheckandSetControl(itemDetail.HazardousManufacturerCity, itemDetail.ID, HazardousManufacturerCity.ID)
            HazardousManufacturerState.Text = CheckandSetControl(itemDetail.HazardousManufacturerState, itemDetail.ID, HazardousManufacturerState.ID)
            HazardousContainerSize.Text = CheckandSetControl(itemDetail.HazardousContainerSize, itemDetail.ID, HazardousContainerSize.ID)
            HazardousManufacturerPhone.Text = CheckandSetControl(itemDetail.HazardousManufacturerPhone, itemDetail.ID, HazardousManufacturerPhone.ID)

            ' RMS
            RMSSellable.SelectedValue = CheckandSetControl(itemDetail.RMSSellable, itemDetail.ID, RMSSellable.ID)
            RMSOrderable.SelectedValue = CheckandSetControl(itemDetail.RMSOrderable, itemDetail.ID, RMSOrderable.ID)
            RMSInventory.SelectedValue = CheckandSetControl(itemDetail.RMSInventory, itemDetail.ID, RMSInventory.ID)

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

            I_Image.Attributes.Add("onclick", "showImage();")
            If imgFile > 0 Then
                I_Image.Style.Add("cursor", "hand")
                I_Image.Visible = True
                I_Image.ImageUrl = "getimage.aspx?id=" & imgFile
                I_Image.Width = New System.Web.UI.WebControls.Unit(232)
                B_UpdateImage.Value = "Update"
            Else
                I_Image.Visible = True
                I_Image.ImageUrl = "images/app_icons/icon_jpg_small.gif"
                I_Image_Label.InnerText = "(click upload button to add Item Image)"
                B_DeleteImage.Disabled = True
            End If

            If Not ReadOnlyForm Then
                B_UpdateImage.Attributes.Add("onclick", String.Format("openUploadItemMaintFile('{0}', '{1}', '{2}', '1');", "X", itemDetail.ID, Models.ItemFileTypeHelper.GetFileTypeString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image)))
                B_DeleteImage.Attributes.Add("onclick", "return deleteImage(" & itemDetail.ID & ");")
            Else
                B_UpdateImage.Disabled = True
                B_DeleteImage.Disabled = True
            End If
            ' CHANGES (ImageID)
            If itemDetail.ImageID > 0 Then
                I_Image_ORIG.Attributes.Add("onclick", "showImage(true);")
                I_Image_ORIG.Style.Add("cursor", "hand")
                I_Image_ORIG.Visible = True
                I_Image_ORIG.ImageUrl = "getimage.aspx?id=" & itemDetail.ImageID
                I_Image_ORIG.Width = New System.Web.UI.WebControls.Unit(232)
            Else
                I_Image_ORIG.ImageUrl = "images/app_icons/icon_jpg_small.gif"
                I_Image_ORIG.Width = New System.Web.UI.WebControls.Unit(16)
            End If
            If imgChanged Then
                Me.AddStartupScript("showNLCWrapper('ImageID');")
            End If
            nlcCCRevert_ImageID.Attributes("onclick") = "undoImage('" & itemDetail.ID & "');"

            I_MSDS.Attributes.Add("onclick", "showMSDS('" & Server.UrlEncode(String.Format("importitem_{0}_{1}.pdf", itemDetail.BatchID, dateNow.ToString("yyyyMMdd"))) & "');")
            If msdsFile > 0 Then
                I_MSDS.Style.Add("cursor", "hand")
                I_MSDS.Visible = True
                I_MSDS.ImageUrl = "images/app_icons/icon_pdf_large.gif?id=" & msdsFile
                B_UpdateMSDS.Value = "Update"
            Else
                I_MSDS.Visible = True
                I_MSDS.ImageUrl = "images/app_icons/icon_pdf_small_off.gif"
                I_MSDS_Label.InnerText = "(click upload button to add MSDS Sheet)"
                B_DeleteMSDS.Disabled = True
            End If

            If Not ReadOnlyForm Then
                B_UpdateMSDS.Attributes.Add("onclick", String.Format("openUploadItemMaintFile('{0}', '{1}', '{2}', '1');", "X", itemDetail.ID, Models.ItemFileTypeHelper.GetFileTypeString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS)))
                B_DeleteMSDS.Attributes.Add("onclick", "return deleteMSDS(" & itemDetail.ID & ");")
            Else
                B_UpdateMSDS.Disabled = True
                B_DeleteMSDS.Disabled = True
            End If
            ' CHANGES (MSDSID)
            If itemDetail.MSDSID > 0 Then
                I_MSDS_ORIG.Attributes.Add("onclick", "showMSDS('" & Server.UrlEncode(String.Format("importitem_{0}_{1}.pdf", itemDetail.BatchID, dateNow.ToString("yyyyMMdd"))) & "', true);")
                I_MSDS_ORIG.Style.Add("cursor", "hand")
                I_MSDS_ORIG.Visible = True
                I_MSDS_ORIG.Width = New System.Web.UI.WebControls.Unit(32)
                I_MSDS_ORIG.Height = New System.Web.UI.WebControls.Unit(32)
                I_MSDS_ORIG.ImageUrl = "images/app_icons/icon_pdf_large.gif?id=" & itemDetail.MSDSID
            Else
                I_MSDS_ORIG.ImageUrl = "images/app_icons/icon_pdf_small_off.gif"
                I_MSDS_ORIG.Width = New System.Web.UI.WebControls.Unit(16)
                I_MSDS_ORIG.Height = New System.Web.UI.WebControls.Unit(16)
            End If
            If msdsChanged Then
                Me.AddStartupScript("showNLCWrapper('MSDSID');")
            End If
            nlcCCRevert_MSDSID.Attributes("onclick") = "undoMSDS('" & itemDetail.ID & "');"

            If ReadOnlyForm Then
                btnUpdate.Enabled = False
                btnUpdateClose.Enabled = False
                btnCancel.Text = "Close"
                btnStockStratHelper.Disabled = True
            End If
        End If

        'GET and SET Language Information
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

            'NAK 5/15/2013:  Per Michaels, if the TIFrench or TISpanish field is set to YES, do not let users change it.
            If itemDetail.TIFrench = "Y" Then
                TIFrench.RenderReadOnly = True
            End If
            If itemDetail.TISpanish = "Y" Then
                TISpanish.RenderReadOnly = True
            End If

            ExemptEndDateFrench.Text = CheckandSetControl(itemDetail.ExemptEndDateFrench, itemDetail.ID, ExemptEndDateFrench.ID)

            EnglishShortDescription.Text = CheckandSetControl(itemDetail.EnglishShortDescription, itemDetail.ID, EnglishShortDescription.ID)
            EnglishLongDescription.Text = CheckandSetControl(itemDetail.EnglishLongDescription, itemDetail.ID, EnglishLongDescription.ID)

        Else
            'TODO: If we need to default any language fields, put that here.
        End If

        If Not UserCanEdit Then
            Me.btnUpdate.Visible = False
            Me.btnUpdateClose.Visible = False
            B_UpdateImage.Visible = False
            B_DeleteImage.Visible = False
            B_UpdateMSDS.Visible = False
            B_DeleteMSDS.Visible = False
            btnCancel.Text = "Close"
        End If

        If ReadOnlyForm Then
            SetFormReadOnly()
        End If

        ImplementFieldLocking(itemFL)
        FormHelper.SetupControlsFromMetadata(Me, md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail))

        itemFL = Nothing

    End Sub

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
        'NAK 11/28/2012:  Per Michaels, DBC/QA will no longer have carte blanche field access.  
        'If Not IsAdmin() Then
        '    For Each col As Models.MetadataColumn In itemFL.Columns
        '        LockField(col.ColumnName, col.Permission)
        '    Next
        'End If

        Dim bIsAdmin = IsAdmin()
        For Each col As Models.MetadataColumn In itemFL.Columns
            Select Case col.ColumnName
                Case "SpanishLongDescription", "SpanishShortDescription", "FrenchLongDescription", "FrenchShortDescription", "FrenchItemDescription", "EnglishLongDescription", "EnglishShortDescription",
                     "TIEnglish", "TIFrench", "TISpanish", "CoinBattery"
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
        Dim sp As String = "&nbsp;"
        colName = Trim(colName)

        Select Case UCase(permission)
            Case "N"            ' -------  Hide Data for Column 
                Select Case colName

                    Case "AddCountryOfOrigin"
                        additionalCOOTbl.Attributes.Add("style", "display:none")

                    Case "Additional_UPC"
                        Me.AdditionalUPCFL.Attributes.Add("style", "display:none")
                        Me.additionalUPCParent.Attributes.Add("style", "display:none")

                    Case "Vendor"
                        Me.VendorOrAgentFL.Attributes.Add("style", "display:none")
                        Me.VendorOrAgent.Visible = False
                        Me.AgentType.Visible = False

                    Case "PrimaryUPC"
                        Me.PrimaryUPCFL.Attributes.Add("style", "display:none")
                        Me.PrimaryUPC.Visible = False

                    Case "DetailInvoiceCustomsDesc"
                        Me.DetailInvoiceCustomsDescFL.Attributes.Add("style", "display:none")
                        Me.DetailInvoiceCustomsDesc1.Visible = False
                        Me.DetailInvoiceCustomsDesc2.Visible = False
                        Me.DetailInvoiceCustomsDesc3.Visible = False
                        Me.DetailInvoiceCustomsDesc4.Visible = False
                        Me.DetailInvoiceCustomsDesc5.Visible = False
                        Me.DetailInvoiceCustomsDesc0.Visible = False

                    Case "ComponentMaterialBreakdown"
                        Me.ComponentMaterialBreakdownFL.Attributes.Add("style", "display:none")
                        Me.ComponentMaterialBreakdown1.Visible = False
                        Me.ComponentMaterialBreakdown2.Visible = False
                        Me.ComponentMaterialBreakdown3.Visible = False
                        Me.ComponentMaterialBreakdown4.Visible = False
                        Me.ComponentMaterialBreakdown0.Visible = False

                    Case "ComponentConstructionMethod"
                        Me.ComponentConstructionMethodFL.Attributes.Add("style", "display:none")
                        Me.ComponentConstructionMethod1.Visible = False
                        Me.ComponentConstructionMethod2.Visible = False
                        Me.ComponentConstructionMethod3.Visible = False
                        Me.ComponentConstructionMethod0.Visible = False

                    Case "ReshippableInnerCartonLength", "ReshippableInnerCartonWidth", "ReshippableInnerCartonHeight"
                        Me.InnerCaseFLParent.Attributes.Add("style", "display:none")
                        Me.InnerCaseParent.Attributes.Add("style", "display:none")

                    Case "MasterCartonDimensionsLength", "MasterCartonDimensionsWidth", "MasterCartonDimensionsHeight"
                        Me.MasterCaseFLParent.Attributes.Add("style", "display:none")
                        Me.MasterCaseParent.Attributes.Add("style", "display:none")

                    Case "AdditionalDutyComment"
                        Me.AdditionalDutyFL.Visible = False
                        Me.AdditionalDutyComment.Visible = False

                    Case "AdditionalDutyAmount"
                        Me.AdditionalDutyFL.Visible = False
                        Me.AdditionalDutyAmount.Visible = False

                    Case "CountryOfOrigin", "CountryOfOriginName"
                        Me.CountryOfOriginFL.InnerHtml = sp
                        Me.CountryOfOriginParent.Visible = False

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

                    Case "ImportBurden"
                        Me.StoreTotalImportBurdenFL.Attributes.Add("style", "display:none")
                        Me.StoreTotalImportBurdenParent.Attributes.Add("style", "display:none")
                        Me.ImportBurdenFL.Attributes.Add("style", "display:none")
                        Me.ImportBurdenParent.Attributes.Add("style", "display:none")

                    Case "HazMatNo", "HazMatYes", "HazMatYesNo", "Hazardous"
                        Hazardous.Visible = False
                        P_HazMat.Visible = False

                    Case "MSDSID"
                        Image_IDFL.Attributes.Add("style", "display:none")

                    Case "ImageID"
                        MSDS_IDFL.Attributes.Add("style", "display:none")

                    Case Else   ' Find control by name and hide it
                        MyBase.Lockfield(colName, permission)

                End Select ' Column

            Case "V"            ' -------  View only of Column data
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

                    Case "FOBShippingPoint"
                        FirstCostEdit.ReadOnly = True
                        FOBShippingPointEdit.ReadOnly = True

                    Case "ImportBurden"
                        StoreTotalImportBurdenEdit.ReadOnly = True
                        ImportBurdenEdit.ReadOnly = True

                    Case "WarehouseLandedCost"
                        TotalWhseLandedCostEdit.ReadOnly = True
                        WarehouseLandedCostEdit.ReadOnly = True

                        'Case "HazMatNo", "HazMatYes", "HazMatYesNo", "Hazardous"
                        '    Hazardous.RenderReadOnly = True

                    Case "MSDSID"
                        Me.B_UpdateMSDS.Disabled = True
                        Me.B_DeleteMSDS.Disabled = True

                    Case "ImageID"
                        Me.B_UpdateImage.Disabled = True
                        Me.B_DeleteImage.Disabled = True

                        'Case "Private_Brand_Label"
                        '    PrivateBrandLabel.RenderReadOnly = True

                    Case Else   ' Find By ID for View
                        MyBase.Lockfield(colName, permission)

                End Select

            Case Else   'edit

        End Select ' Permission
    End Sub

    Private Sub SetupFields()

        'Show appropriate panels depending on selected value
        If Hazardous.SelectedValue = "Y" Then
            'HazMatNo.SelectedValue = ""
            P_HazMat.Visible = True
        Else
            'HazMatNo.SelectedValue = "X"
        End If

        'If Agent.SelectedValue = "YES" Then
        If VendorOrAgent.SelectedValue = "A" Then
            L_Contact.Text = "Contact:"
            'P_Manufacture.Visible = True
            trM1.Visible = True
            trM2.Visible = True
            trM3.Visible = True
            'P_Agent.Visible = True
            trA1.Visible = True
            trA2.Visible = True
            trA3.Visible = True
            trA4.Visible = True

            'GenerateMichaelsUPC.Visible = True
            Me.agentCommissionRow.Attributes("class") = ""
        Else
            AgentType.Visible = False
            L_Contact.Text = "US Contact Name:"
            'GenerateMichaelsUPC.Visible = False
            Me.agentCommissionRow.Attributes("class") = "hideElement"
        End If

        'If StageType = Models.WorkflowStageType.DBC Then
        '    StoreSupplierZoneGroup.ReadOnly = False
        '    WHSSupplierZoneGroup.ReadOnly = False
        'End If

        'NAK 12/4/2012:  Per Michaels, these fields should be editable to DBC/QA
        If StageType <> Models.WorkflowStageType.Tax And StageType <> Models.WorkflowStageType.DBC Then
            TaxUDA.RenderReadOnly = True
            TaxValueUDA.RenderReadOnly = True
        End If

    End Sub

    Private Sub InitControls()
        ' init controls
        ' -------------

        linkExcel.Visible = False

        ' cubic feet per Each carton
        EachCaseHeight.Attributes.Add("onchange", "eachCaseChanged();")
        EachCaseWidth.Attributes.Add("onchange", "eachCaseChanged();")
        EachCaseLength.Attributes.Add("onchange", "eachCaseChanged();")

        'cubic feet per inner carton
        InnerCaseHeight.Attributes.Add("onchange", "innerCaseChanged();")
        InnerCaseWidth.Attributes.Add("onchange", "innerCaseChanged();")
        InnerCaseLength.Attributes.Add("onchange", "innerCaseChanged();")

        ' cubic feet per master carton
        MasterCaseLength.Attributes.Add("onchange", "calculateEstLandedCost('mcheight');")
        MasterCaseWidth.Attributes.Add("onchange", "calculateEstLandedCost('mcwidth');")
        MasterCaseHeight.Attributes.Add("onchange", "calculateEstLandedCost('mclength');")

        btnUpdateClose.Attributes.Add("onclick", "calcfixfocus();")

        ' estimated landed cost and store
        Me.DisplayerCost.Attributes.Add("onchange", "calculateEstLandedCost('dispcost');")
        Me.ProductCost.Attributes.Add("onchange", "calculateEstLandedCost('prodcost');")
        'Me.FOBShippingPoint.Attributes.Add("onchange", "calculateEstLandedCost('fob');")
        Me.DutyPercent.Attributes.Add("onchange", "calculateEstLandedCost('dutyper');")
        Me.AdditionalDutyAmount.Attributes.Add("onchange", "calculateEstLandedCost('addduty');")
        Me.SuppTariffPercent.Attributes.Add("onchange", "calculateEstLandedCost('supptariffper');")
        Me.EachesMasterCase.Attributes.Add("onchange", "calculateEstLandedCost('eachesmc');")
        ' mclength completed above
        ' mcwidth completed above
        ' mcheight completed above
        Me.OceanFreightAmount.Attributes.Add("onchange", "calculateEstLandedCost('oceanfre');")
        Me.AgentCommissionPercent.Attributes.Add("onchange", "calculateEstLandedCost('agentcommper');")

        Me.PrePriced.Attributes.Add("onchange", "baseRetailChanged('prepriced');")
        Me.TaxUDA.Attributes.Add("onchange", "taxUDAChanged();")
        Me.TaxValueUDA.Attributes.Add("onchange", "taxValueUDAChanged();")

        ' Country of Origin
        Me.CountryOfOriginName.Attributes.Add("onchange", "countryOfOriginChanged();")

    End Sub


    Private Sub InitializeValidation()
        'Setup the validation summary
        ValidationHelper.SetupValidationSummary(V_Summary)

        'Save Validation State

        'Data Type Validation
        Page.Validate()

        'Perform Logical Validation
        PerformStageValidation(UserCanEdit, True)

    End Sub

    Public Function PerformStageValidation() As Boolean
        Return PerformStageValidation(False, False)
    End Function

    Public Function PerformStageValidation(ByVal saveValidation As Boolean) As Boolean
        Return PerformStageValidation(saveValidation, False)
    End Function

    Public Function PerformStageValidation(ByVal saveValidation As Boolean, ByVal batchValidation As Boolean) As Boolean

        Dim vrBatch As NovaLibra.Coral.SystemFrameworks.Michaels.ValidationRecord = Nothing
        Dim vr As NovaLibra.Coral.SystemFrameworks.Michaels.ValidationRecord
        Dim rowChanges As Models.IMRowChanges
        Dim itemRec As Models.ItemMaintItemDetailFormRecord

        Dim userID As Integer = Session("UserID")

        If Not (BatchID > 0) Then
            batchValidation = False
        End If

        If HeaderItemID > 0 Then    ' Normal if not in Read Only Mode or if In RO Mode and reviewing an item in a batch with matching SKU / Vendor
            itemRec = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(HeaderItemID, AppHelper.GetVendorID())
        Else
            itemRec = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(AppHelper.GetVendorID(), HeaderSKU, HeaderVendorNumber)
        End If

        ' Load Change Records into Property for Current changes
        rowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(HeaderItemID)

        If ItemMasterView OrElse (BatchID > 0 AndAlso ValidationHelper.SkipBatchValidation(Me.StageType)) Then
            If Not ItemMasterView AndAlso batchValidation Then
                vrBatch = New Models.ValidationRecord(BatchID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.Batch)
            End If
        Else
            If batchValidation Then
                vrBatch = ValidationHelper.ValidateItemMaintBatch(BatchID, ReadOnlyForm)
                vrBatch.RemoveErrorsByField("FutureCostExists")
            End If
        End If

        If ItemMasterView OrElse (BatchID > 0 AndAlso ValidationHelper.SkipValidation(Me.StageType)) Then
            vr = ValidationHelper.ValidateItemMaintItemForFutureCostsOnly(itemRec, rowChanges, ReadOnlyForm)
        Else
            vr = ValidationHelper.ValidateItemMaintItem(itemRec, rowChanges, Me.WorkFlowStageID, Me.StageType, Me.IsPack, ReadOnlyForm)
        End If

        Dim bret As Boolean
        Dim batchValid As Boolean
        If batchValidation AndAlso vrBatch IsNot Nothing Then
            batchValid = vrBatch.HasAnyError()
        Else
            batchValid = True
        End If
        If (Not batchValid Or vr.HasAnyError()) Then

            'Populate summary with any errors
            ValidationHelper.SetupValidationSummary(V_Summary)
            If batchValidation AndAlso vrBatch IsNot Nothing AndAlso vrBatch.HasAnyError() Then ValidationHelper.AddValidationSummaryErrors(V_Summary, vrBatch)
            If vr.HasAnyError() Then ValidationHelper.AddValidationSummaryErrors(V_Summary, vr)

            If ImportDetailID > 0 Then
                If vr.ErrorExists() Then
                    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(Models.ItemValidFlag.NotValid, True)
                Else
                    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(Models.ItemValidFlag.Valid, True)
                End If

            End If

            bret = False
        Else
            If ImportDetailID > 0 Then
                validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(Models.ItemValidFlag.Valid, True)
            End If

            bret = True
        End If


        If saveValidation And UserCanEdit And Not ItemMasterView Then

            If (batchValidation AndAlso vrBatch IsNot Nothing) Then NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vr, userID)

        End If


        If vrBatch IsNot Nothing Then vrBatch = Nothing
        vr = Nothing

        Return bret
    End Function

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click

        If Page.IsValid() Then

            If UserCanEdit Then
                Dim id As Integer = SaveChanges()
                PerformStageValidation(True, True)
                Response.Redirect("IMImportForm.aspx?id=" & id.ToString & "&r=1")  '&hid=" & DataHelper.SmartValues(hid.Value, "long", False) & "&id=" & saveID)
            End If
        End If

    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click

        If Page.IsValid() Then
            If UserCanEdit Then
                Dim id As Integer = SaveChanges()

                PerformStageValidation(True, True)
                Session(cBATCHID) = BatchID
                Response.Redirect("closeform.aspx?rl=1")

            End If
        End If

    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        CloseForm()
    End Sub

    Private Function CheckandSave(ByVal ctlName As String, ByRef changeRec As Models.IMChangeRecord, ByRef itemDetail As Models.ItemMaintItemDetailFormRecord,
            ByVal newValue As String, Optional ByVal baseType As String = "") As Boolean

        ' Rturns TRUE if ANY Change Record updated (reverted or updated or Inserted)
        '       FALSE if No change record saved

        Dim result As Boolean = False
        mdColumn = mdTable.GetColumnByName(ctlName)     ' Find the fieldname to use for this save
        If mdColumn IsNot Nothing Then
            result = FormHelper.CheckandSave(ctlName, changeRec, itemDetail, newValue, mdColumn, IMChanges, UserID, baseType)
        Else
            Throw New ArgumentException("Field " & ctlName & " not found in MetaData During Import Save.")
            result = False    ' Need to save but could not find field name in metadatacolum. trouble
        End If
        Return result
    End Function

    Private Function SaveChanges() As Integer

        Dim decValue As Decimal
        Dim strValue As String
        Dim changeRec As Models.IMChangeRecord = New Models.IMChangeRecord
        Dim itemRec As Models.ItemMaintItemDetailFormRecord
        Dim updatePackCost As Boolean = False
        Dim updatePackWeight As Boolean = False

        Dim id As Long = 0
        Dim userID As Integer = Session(cUSERID)
        Dim changeFlag As String = ""   ', ctlFlag As String

        ' Load Item Record to set up for validation and For Original Values for both change and Calc controls
        itemRec = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(hid.Value, AppHelper.GetVendorID)

        ' Load Change Records into Property for Current changes
        IMChanges = Data.MaintItemMasterData.GetIMChangeRecordsByItemID(HeaderItemID)

        ' Set up ChangeRec for Item Master Common field changes
        changeRec.ItemID = hid.Value
        changeRec.UPC = ""
        changeRec.CountryOfOrigin = ""
        changeRec.EffectiveDate = ""
        changeRec.Counter = 0

        mdTable = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        ' Start Save
        CheckandSave(AllowStoreOrder.ID, changeRec, itemRec, AllowStoreOrder.SelectedValue)
        CheckandSave(InventoryControl.ID, changeRec, itemRec, InventoryControl.SelectedValue)
        CheckandSave(Discountable.ID, changeRec, itemRec, Discountable.SelectedValue)
        CheckandSave(AutoReplenish.ID, changeRec, itemRec, AutoReplenish.SelectedValue)
        CheckandSave(PrePriced.ID, changeRec, itemRec, PrePriced.SelectedValue)
        CheckandSave(TaxUDA.ID, changeRec, itemRec, TaxUDA.SelectedValue)
        CheckandSave(PrePricedUDA.ID, changeRec, itemRec, PrePricedUDA.SelectedValue)
        CheckandSave(Season.ID, changeRec, itemRec, Season.SelectedValue)

        CheckandSave(StockingStrategyCode.ID, changeRec, itemRec, StockingStrategyCode.SelectedValue)

        'PMO200141 GTIN14 Enhancements changes
        CheckandSave(InnerGTIN.ID, changeRec, itemRec, InnerGTIN.Text)
        CheckandSave(CaseGTIN.ID, changeRec, itemRec, CaseGTIN.Text)

        'RO If needed fix for boolean CheckandSave(xxx.ID, changeRec, itemDetail, PrimaryVendor.SelectedValue)
        CheckandSave(CoinBattery.ID, changeRec, itemRec, CoinBattery.SelectedValue)
        CheckandSave(TSSA.ID, changeRec, itemRec, TSSA.SelectedValue)
        CheckandSave(CSA.ID, changeRec, itemRec, CSA.SelectedValue)
        CheckandSave(UL.ID, changeRec, itemRec, UL.SelectedValue)
        CheckandSave(LicenceAgreement.ID, changeRec, itemRec, LicenceAgreement.SelectedValue)
        CheckandSave(FumigationCertificate.ID, changeRec, itemRec, FumigationCertificate.SelectedValue)
        CheckandSave(PhytoTemporaryShipment.ID, changeRec, itemRec, PhytoTemporaryShipment.SelectedValue)
        CheckandSave(KILNDriedCertificate.ID, changeRec, itemRec, KILNDriedCertificate.SelectedValue)
        CheckandSave(ChinaComInspecNumAndCCIBStickers.ID, changeRec, itemRec, ChinaComInspecNumAndCCIBStickers.SelectedValue)
        CheckandSave(OriginalVisa.ID, changeRec, itemRec, OriginalVisa.SelectedValue)
        CheckandSave(TextileDeclarationMidCode.ID, changeRec, itemRec, TextileDeclarationMidCode.SelectedValue)
        CheckandSave(QuotaChargeStatement.ID, changeRec, itemRec, QuotaChargeStatement.SelectedValue)
        CheckandSave(MSDS.ID, changeRec, itemRec, MSDS.SelectedValue)
        CheckandSave(TSCA.ID, changeRec, itemRec, TSCA.SelectedValue)
        CheckandSave(DropBallTestCert.ID, changeRec, itemRec, DropBallTestCert.SelectedValue)
        CheckandSave(ManMedicalDeviceListing.ID, changeRec, itemRec, ManMedicalDeviceListing.SelectedValue)
        CheckandSave(ManFDARegistration.ID, changeRec, itemRec, ManFDARegistration.SelectedValue)
        CheckandSave(CopyRightIndemnification.ID, changeRec, itemRec, CopyRightIndemnification.SelectedValue)
        CheckandSave(FishWildLifeCert.ID, changeRec, itemRec, FishWildLifeCert.SelectedValue)
        CheckandSave(Proposition65LabelReq.ID, changeRec, itemRec, Proposition65LabelReq.SelectedValue)
        CheckandSave(CCCR.ID, changeRec, itemRec, CCCR.SelectedValue)
        CheckandSave(FormaldehydeCompliant.ID, changeRec, itemRec, FormaldehydeCompliant.SelectedValue)


        CheckandSave(MinimumOrderQuantity.ID, changeRec, itemRec, MinimumOrderQuantity.Text.Trim())
        CheckandSave(VendorMinOrderAmount.ID, changeRec, itemRec, RoundDimesionsString(VendorMinOrderAmount.Text.Trim(), 2))
        CheckandSave(ProductIdentifiesAsCosmetic.ID, changeRec, itemRec, ProductIdentifiesAsCosmetic.SelectedValue)


        CheckandSave(Hazardous.ID, changeRec, itemRec, Hazardous.SelectedValue)
        If UCase(Hazardous.SelectedValue) = "Y" Then
            CheckandSave(HazardousFlammable.ID, changeRec, itemRec, HazardousFlammable.SelectedValue)
            CheckandSave(HazardousContainerType.ID, changeRec, itemRec, HazardousContainerType.SelectedValue)
            CheckandSave(HazardousMSDSUOM.ID, changeRec, itemRec, HazardousMSDSUOM.SelectedValue)
            CheckandSave(HazardousManufacturerCountry.ID, changeRec, itemRec, HazardousManufacturerCountry.Text.Trim())
            CheckandSave(HazardousManufacturerName.ID, changeRec, itemRec, HazardousManufacturerName.Text.Trim())
            CheckandSave(HazardousManufacturerCity.ID, changeRec, itemRec, HazardousManufacturerCity.Text.Trim())
            CheckandSave(HazardousManufacturerState.ID, changeRec, itemRec, HazardousManufacturerState.Text.Trim())
            CheckandSave(HazardousContainerSize.ID, changeRec, itemRec, HazardousContainerSize.Text.Trim())
            CheckandSave(HazardousManufacturerPhone.ID, changeRec, itemRec, HazardousManufacturerPhone.Text.Trim())
        Else
            CheckandSave(HazardousFlammable.ID, changeRec, itemRec, "N")
            CheckandSave(HazardousContainerType.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousMSDSUOM.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerCountry.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerName.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerCity.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousManufacturerState.ID, changeRec, itemRec, String.Empty)
            CheckandSave(HazardousContainerSize.ID, changeRec, itemRec, Decimal.MinValue)
            CheckandSave(HazardousManufacturerPhone.ID, changeRec, itemRec, String.Empty)
        End If

        CheckandSave(DetailInvoiceCustomsDesc0.ID, changeRec, itemRec, DetailInvoiceCustomsDesc0.Text.Trim())
        CheckandSave(DetailInvoiceCustomsDesc1.ID, changeRec, itemRec, DetailInvoiceCustomsDesc1.Text.Trim())
        CheckandSave(DetailInvoiceCustomsDesc2.ID, changeRec, itemRec, DetailInvoiceCustomsDesc2.Text.Trim())
        CheckandSave(DetailInvoiceCustomsDesc3.ID, changeRec, itemRec, DetailInvoiceCustomsDesc3.Text.Trim())
        CheckandSave(DetailInvoiceCustomsDesc4.ID, changeRec, itemRec, DetailInvoiceCustomsDesc4.Text.Trim())
        CheckandSave(DetailInvoiceCustomsDesc5.ID, changeRec, itemRec, DetailInvoiceCustomsDesc5.Text.Trim())
        CheckandSave(ComponentMaterialBreakdown0.ID, changeRec, itemRec, ComponentMaterialBreakdown0.Text.Trim())
        CheckandSave(ComponentMaterialBreakdown1.ID, changeRec, itemRec, ComponentMaterialBreakdown1.Text.Trim())
        CheckandSave(ComponentMaterialBreakdown2.ID, changeRec, itemRec, ComponentMaterialBreakdown2.Text.Trim())
        CheckandSave(ComponentMaterialBreakdown3.ID, changeRec, itemRec, ComponentMaterialBreakdown3.Text.Trim())
        CheckandSave(ComponentMaterialBreakdown4.ID, changeRec, itemRec, ComponentMaterialBreakdown4.Text.Trim())
        CheckandSave(ComponentConstructionMethod0.ID, changeRec, itemRec, ComponentConstructionMethod0.Text.Trim())
        CheckandSave(ComponentConstructionMethod1.ID, changeRec, itemRec, ComponentConstructionMethod1.Text.Trim())
        CheckandSave(ComponentConstructionMethod2.ID, changeRec, itemRec, ComponentConstructionMethod2.Text.Trim())
        CheckandSave(ComponentConstructionMethod3.ID, changeRec, itemRec, ComponentConstructionMethod3.Text.Trim())

        CheckandSave(PlanogramName.ID, changeRec, itemRec, PlanogramName.Text.ToUpper.Trim())
        CheckandSave(ItemDesc.ID, changeRec, itemRec, ItemDesc.Text.ToUpper.Trim())     ' upper case
        CheckandSave(PrivateBrandLabel.ID, changeRec, itemRec, PrivateBrandLabel.SelectedValue)
        CheckandSave(VendorAddress1.ID, changeRec, itemRec, VendorAddress1.Text.Trim())
        CheckandSave(VendorAddress2.ID, changeRec, itemRec, VendorAddress2.Text.Trim())
        CheckandSave(VendorAddress3.ID, changeRec, itemRec, VendorAddress3.Text.Trim())
        CheckandSave(VendorAddress4.ID, changeRec, itemRec, VendorAddress4.Text.Trim())
        CheckandSave(VendorContactName.ID, changeRec, itemRec, VendorContactName.Text.Trim())
        CheckandSave(VendorContactPhone.ID, changeRec, itemRec, VendorContactPhone.Text.Trim())
        CheckandSave(VendorContactEmail.ID, changeRec, itemRec, VendorContactEmail.Text.Trim())
        CheckandSave(VendorContactFax.ID, changeRec, itemRec, VendorContactFax.Text.Trim())
        CheckandSave(ManufactureName.ID, changeRec, itemRec, ManufactureName.Text.Trim())
        CheckandSave(ManufactureAddress1.ID, changeRec, itemRec, ManufactureAddress1.Text.Trim())
        CheckandSave(ManufactureAddress2.ID, changeRec, itemRec, ManufactureAddress2.Text.Trim())
        CheckandSave(ManufactureContact.ID, changeRec, itemRec, ManufactureContact.Text.Trim())
        CheckandSave(ManufacturePhone.ID, changeRec, itemRec, ManufacturePhone.Text.Trim())
        CheckandSave(ManufactureEmail.ID, changeRec, itemRec, ManufactureEmail.Text.Trim())
        CheckandSave(ManufactureFax.ID, changeRec, itemRec, ManufactureFax.Text.Trim())
        CheckandSave(AgentContact.ID, changeRec, itemRec, AgentContact.Text.Trim())
        CheckandSave(AgentPhone.ID, changeRec, itemRec, AgentPhone.Text.Trim())
        CheckandSave(AgentEmail.ID, changeRec, itemRec, AgentEmail.Text.Trim())
        CheckandSave(AgentFax.ID, changeRec, itemRec, AgentFax.Text.Trim())
        CheckandSave(VendorStyleNum.ID, changeRec, itemRec, VendorStyleNum.Text.ToUpper.Trim()) ' uppercase 
        CheckandSave(HarmonizedCodeNumber.ID, changeRec, itemRec, HarmonizedCodeNumber.Text.Trim())
        CheckandSave(CanadaHarmonizedCodeNumber.ID, changeRec, itemRec, CanadaHarmonizedCodeNumber.Text.Trim())
        CheckandSave(IndividualItemPackaging.ID, changeRec, itemRec, Left(IndividualItemPackaging.Text.Trim(), 100))

        If Me.IsPack Then   ' only save QtyInPack if the Batch isPack
            If CheckandSave(QtyInPack.ID, changeRec, itemRec, QtyInPack.Text.Trim()) Then
                ' if Change record was saved AND the batch is a Pack AND the Item is a Child THEN set flag to update Pack cost to TRUE
                If itemRec.ItemType.ToUpper <> "D" And itemRec.ItemType.ToUpper <> "DP" And itemRec.ItemType.ToUpper <> "SB" Then
                    updatePackCost = True
                End If
            End If
        End If
        CheckandSave(EachesMasterCase.ID, changeRec, itemRec, EachesMasterCase.Text.Trim())
        CheckandSave(EachesInnerPack.ID, changeRec, itemRec, EachesInnerPack.Text.Trim())

        CheckandSave(EachCaseWeight.ID, changeRec, itemRec, RoundDimesionsString(EachCaseWeight.Text.Trim(), 4))
        CheckandSave(EachCaseLength.ID, changeRec, itemRec, RoundDimesionsString(EachCaseLength.Text.Trim()))
        CheckandSave(EachCaseWidth.ID, changeRec, itemRec, RoundDimesionsString(EachCaseWidth.Text.Trim()))
        CheckandSave(EachCaseHeight.ID, changeRec, itemRec, RoundDimesionsString(EachCaseHeight.Text.Trim()))

        'CheckandSave(EachCaseCube.ID, changeRec, itemRec, Replace(Replace(EachCaseCube.Value.Trim(), ",", ""), "$", ""))

        Dim strEachPackCube As String = CalculationHelper.CalculateItemCasePackCube(
            RoundDimesionsString(EachCaseWidth.Text.Trim()),
            RoundDimesionsString(EachCaseHeight.Text.Trim()),
            RoundDimesionsString(EachCaseLength.Text.Trim()),
            RoundDimesionsString(EachCaseWeight.Text.Trim(), 4))

        CheckandSave(EachCaseCube.ID, changeRec, itemRec, strEachPackCube)

        CheckandSave(InnerCaseWeight.ID, changeRec, itemRec, RoundDimesionsString(InnerCaseWeight.Text.Trim(), 4))
        CheckandSave(InnerCaseLength.ID, changeRec, itemRec, RoundDimesionsString(InnerCaseLength.Text.Trim()))
        CheckandSave(InnerCaseWidth.ID, changeRec, itemRec, RoundDimesionsString(InnerCaseWidth.Text.Trim()))
        CheckandSave(InnerCaseHeight.ID, changeRec, itemRec, RoundDimesionsString(InnerCaseHeight.Text.Trim()))
        CheckandSave(MasterCaseLength.ID, changeRec, itemRec, RoundDimesionsString(MasterCaseLength.Text.Trim()))
        CheckandSave(MasterCaseWidth.ID, changeRec, itemRec, RoundDimesionsString(MasterCaseWidth.Text.Trim()))
        CheckandSave(MasterCaseHeight.ID, changeRec, itemRec, RoundDimesionsString(MasterCaseHeight.Text.Trim()))
        CheckandSave(MasterCaseCube.ID, changeRec, itemRec, Replace(Replace(MasterCaseCube.Value.Trim(), ",", ""), "$", ""))

        If CheckandSave(MasterCaseWeight.ID, changeRec, itemRec, RoundDimesionsString(MasterCaseWeight.Text.Trim(), 4)) Then
            If Me.IsPack AndAlso itemRec.ItemType.ToUpper <> "D" And itemRec.ItemType.ToUpper <> "DP" And itemRec.ItemType.ToUpper <> "SB" Then
                updatePackWeight = True
            End If
        End If

        'CheckandSave(InnerCaseCube.ID, changeRec, itemRec, Replace(Replace(InnerCaseCube.Value.Trim(), ",", ""), "$", ""))
        Dim strInnerPackCube As String = CalculationHelper.CalculateItemCasePackCube(
        RoundDimesionsString(InnerCaseWidth.Text.Trim()),
        RoundDimesionsString(InnerCaseHeight.Text.Trim()),
        RoundDimesionsString(InnerCaseLength.Text.Trim()),
        RoundDimesionsString(InnerCaseWeight.Text.Trim(), 4))

        CheckandSave(InnerCaseCube.ID, changeRec, itemRec, strInnerPackCube)


        CheckandSave(DisplayerCost.ID, changeRec, itemRec, Replace(Replace(DisplayerCost.Text.Trim(), ",", ""), "$", ""))
        If CheckandSave(ProductCost.ID, changeRec, itemRec, Replace(Replace(ProductCost.Text.Trim(), ",", ""), "$", "")) Then
            ' if Change record was saved AND the batch is a Pack AND the Item is a Child THEN set flag to update Pack cost to TRUE
            If Me.IsPack AndAlso itemRec.ItemType.ToUpper <> "D" And itemRec.ItemType.ToUpper <> "DP" And itemRec.ItemType.ToUpper <> "SB" Then
                updatePackCost = True
            End If
        End If

        CheckandSave(FOBShippingPoint.ID, changeRec, itemRec, Replace(Replace(FOBShippingPoint.Value.Trim(), ",", ""), "$", ""))

        strValue = DutyPercent.Text.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal")
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        CheckandSave(DutyPercent.ID, changeRec, itemRec, strValue)

        CheckandSave(DutyAmount.ID, changeRec, itemRec, Replace(Replace(DutyAmount.Value.Trim(), ",", ""), "$", ""))

        CheckandSave(AdditionalDutyComment.ID, changeRec, itemRec, AdditionalDutyComment.Text.Trim())
        CheckandSave(AdditionalDutyAmount.ID, changeRec, itemRec, Replace(Replace(AdditionalDutyAmount.Text.Trim(), ",", ""), "$", ""))

        strValue = SuppTariffPercent.Text.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal")
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        CheckandSave(SuppTariffPercent.ID, changeRec, itemRec, strValue)

        CheckandSave(SuppTariffAmount.ID, changeRec, itemRec, Replace(Replace(SuppTariffAmount.Value.Trim(), ",", ""), "$", ""))

        CheckandSave(OceanFreightAmount.ID, changeRec, itemRec, Replace(Replace(OceanFreightAmount.Text.Trim(), ",", ""), "$", ""))
        CheckandSave(OceanFreightComputedAmount.ID, changeRec, itemRec, Replace(Replace(OceanFreightComputedAmount.Value.Trim(), ",", ""), "$", ""))

        If VendorOrAgent.SelectedValue <> "V" Then
            strValue = AgentCommissionPercent.Text.Trim().Replace(",", "").Replace("%", "")
            If strValue.Length > 0 Then
                decValue = DataHelper.SmartValues(strValue, "decimal", True)
                If decValue <> Decimal.MinValue Then
                    decValue = decValue / 100
                    strValue = decValue.ToString()
                End If
            End If
            CheckandSave(AgentCommissionPercent.ID, changeRec, itemRec, strValue)
            CheckandSave(AgentCommissionAmount.ID, changeRec, itemRec, Replace(Replace(AgentCommissionAmount.Value.Trim(), ",", ""), "$", ""))
        Else
            ' need to set agent fields to something
            CheckandSave(AgentCommissionPercent.ID, changeRec, itemRec, "0.00")
            CheckandSave(AgentCommissionAmount.ID, changeRec, itemRec, "0.00")
        End If

        strValue = OtherImportCostsPercent.Value.Trim().Replace(",", "").Replace("%", "")
        If strValue.Length > 0 Then
            decValue = DataHelper.SmartValues(strValue, "decimal", True)
            If decValue <> Decimal.MinValue Then
                decValue = decValue / 100
                strValue = decValue.ToString()
            End If
        End If
        CheckandSave(OtherImportCostsPercent.ID, changeRec, itemRec, strValue)

        CheckandSave(OtherImportCostsAmount.ID, changeRec, itemRec, Replace(Replace(OtherImportCostsAmount.Value.Trim(), ",", ""), "$", ""))

        CheckandSave(ImportBurden.ID, changeRec, itemRec, Replace(Replace(ImportBurden.Value.Trim(), ",", ""), "$", ""))
        CheckandSave(WarehouseLandedCost.ID, changeRec, itemRec, Replace(Replace(WarehouseLandedCost.Value.Trim(), ",", ""), "$", ""))
        CheckandSave(ShippingPoint.ID, changeRec, itemRec, ShippingPoint.Text.ToUpper.Trim())
        ' These are handled in Additional COO
        CheckandSave(VendorComments.ID, changeRec, itemRec, VendorComments.Text.Trim())
        CheckandSave(StockCategory.ID, changeRec, itemRec, StockCategory.Text.Trim())
        'RO CheckandSave(FreightTerms.ID, changeRec, itemRec, FreightTerms.Text.Trim())

        CheckandSave(TaxValueUDA.ID, changeRec, itemRec, TaxValueUDA.Text)
        ' Dup Field Not sure if need to be saved    CheckandSave(xxx.ID, changeRec, itemDetail, TaxValueUDAValue.Value.Trim())
        'RO CheckandSave(StoreSupplierZoneGroup.ID, changeRec, itemDetail, StoreSupplierZoneGroup.Text.Trim())
        'RO CheckandSave(WHSSupplierZoneGroup.ID, changeRec, itemDetail, WHSSupplierZoneGroup.Text.Trim())
        CheckandSave(OutboundFreight.ID, changeRec, itemRec, Replace(Replace(OutboundFreight.Value.Trim(), ",", ""), "$", ""))
        CheckandSave(NinePercentWhseCharge.ID, changeRec, itemRec, Replace(Replace(NinePercentWhseCharge.Value.Trim(), ",", ""), "$", ""))
        CheckandSave(TotalStoreLandedCost.ID, changeRec, itemRec, Replace(Replace(TotalStoreLandedCost.Value.Trim(), ",", ""), "$", ""))

        'SAVE language values
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

        ' RMS
        If ShowRMSFields Then
            CheckandSave(RMSSellable.ID, changeRec, itemRec, RMSSellable.SelectedValue)
            CheckandSave(RMSOrderable.ID, changeRec, itemRec, RMSOrderable.SelectedValue)
            CheckandSave(RMSInventory.ID, changeRec, itemRec, RMSInventory.SelectedValue)
        End If

        ' SAVE Additional Countries of Origin
        ' Set up to save Additional COO Names
        ' Set up ChangeRec for for save
        changeRec.ItemID = hid.Value
        changeRec.UPC = ""
        changeRec.EffectiveDate = ""
        changeRec.ChangedByID = userID

        ' Delete any existing change records for Addtional COOs
        ' Data.MaintItemMasterData.DeleteMatchingChangeRecords(hid.Value, cADDCOONAME)
        ' Data.MaintItemMasterData.DeleteMatchingChangeRecords(hid.Value, cADDCOO)

        Dim addCOOCount As Integer = additionalCOOCount.Value
        Dim IMaddCOOs As Integer = itemRec.AdditionalCOORecs.Count
        Dim objCountry As Models.CountryRecord
        Dim controlFound As Boolean = True, ctl As String, ctlName As String
        Dim counter As Integer = 1
        Dim strNewPriName As String = String.Empty
        Dim strNewPriCode As String = String.Empty

        Dim sbAddCOOCode As StringBuilder = New StringBuilder
        Dim sbAddCOOName As StringBuilder = New StringBuilder
        Dim strTemp As String = String.Empty
        Dim ChangeExists As Boolean

        ' NOTE All COOs are saved as a pipe delimited string.  Counter is now 0 sinces its all in one field
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
                Else  ' Bad country look up. special save
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
        'origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cADDCOONAME, "", "", "", IMaddCOOs + 1)
        origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cADDCOONAME, "", "", "", 0)  ' All additional COOs at 0
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
        changeRec.Counter = 0   'IMaddCOOs + 1
        FormHelper.CheckandSave(strTemp, strOrig, changeRec, ChangeExists)

        ' Save COO Codes
        'origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cADDCOO, "", "", "", IMaddCOOs + 1)
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
        changeRec.Counter = 0   ' IMaddCOOs + 1
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

        ' Now See if we need to Update Pack Cost
        If updatePackCost Or updatePackWeight Then
            ItemMaintHelper.CalculateDPBatchParent(BatchID, updatePackCost, updatePackWeight)
        End If

        ' Save Record in Property for Form validation
        ItemDetail = itemRec

        Return ItemDetail.ID

    End Function

    Private Sub CloseForm()
        Response.Redirect("closeform.aspx?r=0")
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

#Region "Agent Dropdown Changes"
    Protected Sub VendorOrAgent_SelectedIndeoxChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles VendorOrAgent.SelectedIndexChanged
        If VendorOrAgent.SelectedValue = "V" OrElse VendorOrAgent.SelectedValue = "" Then
            L_Contact.Text = "US Contact Name:"
            'P_Manufacture.Visible = False
            'P_Agent.Visible = False
            'trM1.Visible = False
            'trM2.Visible = False
            'trM3.Visible = False
            'P_Agent.Visible = True
            'trA1.Visible = False
            'trA2.Visible = False
            'trA3.Visible = False
            'trA4.Visible = False
            'AgentType.SelectedValue = ""
            AgentType.Text = ""
            AgentType.Visible = False
            Me.agentCommissionRow.Attributes("class") = "hideElement"
        Else
            L_Contact.Text = "Contact:"
            trM1.Visible = True
            trM2.Visible = True
            trM3.Visible = True
            'P_Agent.Visible = True
            trA1.Visible = True
            trA2.Visible = True
            trA3.Visible = True
            trA4.Visible = True            'P_Manufacture.Visible = True
            'P_Agent.Visible = True
            AgentType.Visible = True
            Me.agentCommissionRow.Attributes("class") = ""
        End If
        CreateStartupScriptForCalc("agent")
        PerformStageValidation(False, True)

    End Sub


    'Protected Sub Agent_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles Agent.SelectedIndexChanged

    '    If Agent.SelectedValue = "" Then
    '        VendorAgent.SelectedValue = "YES"
    '        L_Contact.Text = "US Contact Name:"
    '        P_Manufacture.Visible = False
    '        P_Agent.Visible = False
    '        AgentType.SelectedValue = ""
    '        AgentType.Visible = False
    '        GenerateMichaelsUPC.Visible = False
    '        GenerateMichaelsUPC.SelectedIndex = 0
    '        Me.agentCommissionRow.Attributes("class") = "hideElement"
    '    Else
    '        VendorAgent.SelectedValue = ""
    '        L_Contact.Text = "Contact:"
    '        P_Manufacture.Visible = True
    '        P_Agent.Visible = True
    '        AgentType.Visible = True
    '        GenerateMichaelsUPC.Visible = True
    '        Me.agentCommissionRow.Attributes("class") = ""
    '    End If
    '    CreateStartupScriptForCalc("agent")

    '    PerformStageValidation(False, True)

    'End Sub

    'Protected Sub VendorAgent_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles VendorAgent.SelectedIndexChanged

    '    If VendorAgent.SelectedValue = "" Then
    '        Agent.SelectedValue = "YES"
    '        L_Contact.Text = "Contact:"
    '        P_Manufacture.Visible = True
    '        P_Agent.Visible = True
    '        AgentType.Visible = True
    '        GenerateMichaelsUPC.Visible = True
    '        Me.agentCommissionRow.Attributes("class") = ""
    '    Else
    '        Agent.SelectedValue = ""
    '        L_Contact.Text = "US Contact Name:"
    '        P_Manufacture.Visible = False
    '        P_Agent.Visible = False
    '        AgentType.SelectedValue = ""
    '        AgentType.Visible = False
    '        GenerateMichaelsUPC.Visible = False
    '        GenerateMichaelsUPC.SelectedIndex = 0
    '        Me.agentCommissionRow.Attributes("class") = "hideElement"
    '    End If

    '    PerformStageValidation(False, True)

    'End Sub

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

    Protected Sub Hazardous_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles Hazardous.SelectedIndexChanged

        If Hazardous.SelectedValue = "Y" Then
            P_HazMat.Visible = True
        Else
            P_HazMat.Visible = False
        End If

        PerformStageValidation(False, True)

    End Sub
    'Protected Sub HazMatNo_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles HazMatNo.SelectedIndexChanged

    '    If HazMatNo.SelectedValue = "" Then
    '        P_HazMat.Visible = True
    '        HazMatYes.SelectedValue = "X"
    '    Else
    '        P_HazMat.Visible = False
    '        HazMatYes.SelectedValue = ""
    '    End If

    '    PerformStageValidation(False, True)

    'End Sub

    'Protected Sub HazMatYes_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles HazMatYes.SelectedIndexChanged

    '    If HazMatYes.SelectedValue = "" Then
    '        HazMatNo.SelectedValue = "X"
    '        P_HazMat.Visible = False
    '    Else
    '        P_HazMat.Visible = True
    '        HazMatNo.SelectedValue = ""
    '    End If

    '    PerformStageValidation(False, True)

    'End Sub

#End Region

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
