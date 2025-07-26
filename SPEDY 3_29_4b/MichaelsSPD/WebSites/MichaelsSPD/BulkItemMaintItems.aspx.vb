Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.Data.SqlClient
Imports System.Diagnostics
Imports System.Text
Imports System.Xml
Imports System.Xml.XPath

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports WebConstants
Imports ItemHelper

Partial Class BulkItemMaintItems
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler

#Region "Attributes and Properties"

    'Validation Counts
    Private itemUCount As Integer = 0
    Private itemNVCount As Integer = 0
    Private itemVCount As Integer = 0
    Private iucnt1 As Integer = 0, iucnt2 As Integer = 0
    Private invcnt1 As Integer = 0, invcnt2 As Integer = 0
    Private ivcnt1 As Integer = 0, ivcnt2 As Integer = 0
    Private userID As Long = 0
    Private gridItemList As Models.ItemMaintItemDetailRecordList = Nothing

    Private _callbackArg As String = ""
    Public Const CALLBACK_SEP As String = "{{|}}"

    Private _objData As New DataSet

    Public Function GetBatchID() As String
        Return hid.Value
    End Function

    Private _colCount As Integer = 10

    Public ReadOnly Property ColumnReader() As DataSet
        Get
            Return _objData
        End Get
    End Property

    Public Property ColumnCount() As Integer
        Get
            Return _colCount
        End Get
        Set(ByVal value As Integer)
            _colCount = value
        End Set
    End Property

    Private _userColumns As XmlDocument = Nothing
    Private _userColumnsXML As String = ""

    Public Function ColumnEnabledByUser(ByVal columnID As Integer, ByVal defaultDisplay As Boolean) As Boolean
        Dim retValue As Boolean = True
        If _userColumnsXML <> "" AndAlso _userColumnsXML <> "<UserEnabledColumns />" Then
            If Not _userColumns Is Nothing AndAlso Not _userColumns.SelectNodes("//EnabledColumn[@ColumnID = """ & columnID & """]").Count > 0 Then
                retValue = False
            End If
        Else
            retValue = defaultDisplay
        End If
        Return retValue
    End Function

    Public ReadOnly Property RecordType() As Integer
        Get
            Return WebConstants.RECTYPE_ITEM_MAINTENANCE
        End Get
    End Property

    Private _customFields As NovaLibra.Coral.SystemFrameworks.CustomFields = Nothing
    Public Property CustomFields() As NovaLibra.Coral.SystemFrameworks.CustomFields
        Get
            Return _customFields
        End Get
        Set(ByVal value As NovaLibra.Coral.SystemFrameworks.CustomFields)
            _customFields = value
        End Set
    End Property

    Private _itemViewURL As String = String.Empty
    Public Property ItemViewURL() As String
        Get
            Return _itemViewURL
        End Get
        Set(ByVal value As String)
            _itemViewURL = value
        End Set
    End Property

    Dim _batchID As Long = Long.MinValue
    Public Property BatchID() As Long
        Get
            Return _batchID
        End Get
        Set(ByVal value As Long)
            _batchID = value
        End Set
    End Property

    Private Property DefaultEnabledColumns() As String
        Get
            Dim o As Object = Session("BIMDefaultEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("BIMDefaultEnabledColumns") = value
        End Set
    End Property

    Private Property UserEnabledColumns() As String
        Get
            Dim o As Object = Session("BIMUserEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("BIMUserEnabledColumns") = value
        End Set
    End Property

    Private Property UserStartupFilter() As Integer
        Get
            Dim o As Object = Session("BIMUserStartupFilter")
            If Not o Is Nothing And IsNumeric(o) Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session("BIMUserStartupFilter") = value
        End Set
    End Property

    Private Property CustomFieldStartID() As Integer
        Get
            Dim o As Object = Session("BIMCustomFieldStartID")
            If Not o Is Nothing And IsNumeric(o) Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session("BIMCustomFieldStartID") = value
        End Set
    End Property

    Private Property CustomFieldRef() As String
        Get
            Dim o As Object = Session("BIMCustomFieldRef")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("BIMCustomFieldRef") = value
        End Set
    End Property

    Dim _costChanges As Boolean
    Public Property CostChanges() As Boolean
        Get
            Return _costChanges
        End Get
        Set(ByVal value As Boolean)
            _costChanges = value
        End Set
    End Property

#End Region

#Region "Page Events"

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the page
        'Me.Page.Response.Buffer = True
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        userID = DataHelper.SmartValues(Session("UserID"), "long")

        ' Load the Batch
        If Request("id") <> "" AndAlso IsNumeric(Request("id")) Then
            hid.Value = Request("id")
            BatchID = Request("id")
        Else
            Response.Redirect("default.aspx")
        End If

        If Not Me.IsCallback Then
            SecurityCheckRedirect()

            InitializeCallbacks()

            Dim objData As New Data.BatchData ' NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
            Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(BatchID)

            If IsPostBack Then
                If Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "settings" Then
                    SaveSettings()
                End If
            Else
                ' SETUP DEFAULT SORT
                SetDefaultSort()
            End If

            InitializeBatchDetails(batchDetail)

            'Get item changes for the batch
            Dim changes As Models.IMTableChanges = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(batchDetail.ID)

            'Detect Cost Changes
            CostChanges = CostChangeExists(changes)
            ' if the effective date is enabled and is in the past ( <= today ) or blank, set it to tomorrow 
            ' (unless the batch is completed or deleted, in which case it should be disabled, but the previous value should remain).
            If CostChanges And Not ValidationHelper.SkipValidation(batchDetail.WorkflowStageType) Then
                If DataHelper.SmartValues(batchDetail.EffectiveDate, "date", False) <= DataHelper.SmartValues(Now(), "date", True) Then
                    Dim newDate As Date = DateAdd(DateInterval.Day, 1, Now())
                    batchDetail.EffectiveDate = newDate
                    txtEffectiveDate.Text = DataHelper.SmartValues(batchDetail.EffectiveDate, "formatdate", False)
                    Me.SaveEffectiveDate(batchDetail.ID, newDate)
                End If
            End If

            'Initialize Item Grid
            InitializeItemGrid(batchDetail, changes)

            'Validate Batch
            ValidateBatch(batchDetail, changes)

            InitializeSettings(batchDetail)

            ' Init Validation Display
            InitValidation(Me.validationDisplay.ID)

        Else
            ' CALLBACK
            If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) Then
                Response.Clear()
                Response.End()
            End If
        End If
    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        If Not _objData Is Nothing Then
            _objData = Nothing
        End If
        _userColumns = Nothing
    End Sub

#End Region

    Protected Function CostChangeExists(ByRef changes As Models.IMTableChanges) As Boolean
        Dim ret As Boolean = False
        Dim rowChanges As Models.IMRowChanges
        For i As Integer = 0 To changes.RowChanges.Count - 1
            rowChanges = changes.RowChanges.Item(i)
            ret = CostChangeExists(rowChanges)
            If ret = True Then
                Exit For
            End If
        Next
        Return ret
    End Function

    Protected Function CostChangeExists(ByRef rowChanges As Models.IMRowChanges) As Boolean
        Dim ret As Boolean = False
        Dim n As Integer
        Dim cellChange As Models.IMCellChangeRecord
        For n = 0 To rowChanges.RowRecords.Count - 1
            cellChange = rowChanges.RowRecords.Item(n)
            If cellChange.FieldName = "FOBShippingPoint" Or cellChange.FieldName = "ProductCost" Or cellChange.FieldName = "ItemCost" Then
                ret = True
                Exit For
            End If
        Next
        Return ret
    End Function


    Private Function GetBatch(ByVal batchID As Long) As Models.BatchRecord
        Dim objRecord As Models.BatchRecord = New Models.BatchRecord
        Dim objData As New Data.BatchData
        objRecord = objData.GetBatchRecord(batchID)
        Return objRecord
    End Function

    Private Function GetColIDFromGridItemArray(ByRef giarr As List(Of GridItem), ByVal colName As String) As Long
        Dim colID As Long = 0
        For Each gi As GridItem In giarr
            'lp fix, column has been renamed
            If colName = "InitialSetQtyPerStore" Then
                colName = "POGSetupPerStore"
            End If

            If gi.FieldName = colName Then
                colID = gi.ID
                Exit For
            End If
        Next
        Return colID
    End Function

    Protected Function GetGridSortAndFilterXML() As String

        Dim XMLStr As String = "<Root>"
        Dim strFilter As String = String.Empty
        Dim strSearch As String = String.Empty
        ' sort
        If ItemGrid.CurrentAdvancedSort <> String.Empty Then
            XMLStr += ItemGrid.CurrentAdvancedSort
        Else
            XMLStr += "<Sort><Parameter SortID=""1"" intColOrdinal=""" & ItemGrid.CurrentSortColumn & """ intDirection=""" & ItemGrid.CurrentSortDirection & """ /></Sort>"
        End If
        ' filter
        If ItemGrid.SearchText <> String.Empty Then
            strSearch = "<Parameter FilterID=""-100"" Conjunction="""" ColName=""FULLTEXT"" ColOrdinal=""-100"" VerbText="""" VerbID="""">![CDATA[" & ItemGrid.SearchText & "]]</Parameter>"
        End If
        strFilter = ItemGrid.CurrentAdvancedFilter
        If strSearch <> String.Empty Then
            Dim ipos As Integer = strFilter.IndexOf("<Filter>")
            If strFilter = "" OrElse strFilter = "<Filter></Filter>" OrElse strFilter = "<Filter/>" OrElse strFilter = "<Filter />" OrElse ipos < 0 Then
                strFilter = "<Filter>" & strSearch & "</Filter>"
            Else
                strFilter = strFilter.Substring(ipos, Len("<Filter>")) & strSearch & strFilter.Substring(ipos + Len("<Filter>"))
            End If
        End If
        XMLStr += strFilter
        ' close
        XMLStr = "<?xml version=""1.0"" encoding=""utf-8"" ?>" & XMLStr & "</Root>"
        ' return 
        Return XMLStr

    End Function

    Protected Function GetDefaultGridSortAndFilterXML() As String

        Dim XMLStr As String = "<Root>"
        ' sort
        XMLStr += "<Sort><Parameter SortID=""1"" intColOrdinal=""" & ItemGrid.CurrentSortColumn & """ intDirection=""" & ItemGrid.CurrentSortDirection & """ /></Sort>"
        ' filter
        XMLStr += "<Filter/>"
        ' close
        XMLStr = "<?xml version=""1.0"" encoding=""utf-8"" ?>" & XMLStr & "</Root>"
        ' return 
        Return XMLStr

    End Function

    Private Sub InitializeBatchDetails(ByRef batchDetail As Models.BatchRecord)

        If Not batchDetail Is Nothing Then

            ' VALIDATE USER
            ValidateUser(batchDetail.ID, batchDetail.WorkflowStageType)
            If NoUserAccess Then Response.Redirect("default.aspx")

            ' Vendor Check
            VendorCheckRedirect(batchDetail.VendorNumber)

            ' Effective Date
            txtEffectiveDate.Text = DataHelper.SmartValues(batchDetail.EffectiveDate, "formatdate", False)

            'Initialize Batch Header information
            lblMaintType.Text = "Bulk Item Maintenance"
            If batchDetail.ID > 0 Then
                batch.Text = batchDetail.ID.ToString()
            End If
            If batchDetail.WorkflowStageName <> "" Then
                stageName.Text = batchDetail.WorkflowStageName
            End If
            If batchDetail.DateLastModified <> Date.MinValue Then
                lastUpdated.Text = batchDetail.DateLastModified.ToString("M/d/yyyy")
                If batchDetail.UpdatedUserName <> "" Then
                    lastUpdated.Text += " by " & batchDetail.UpdatedUserName
                End If
            End If
            lastUpdatedMe.Value = Now().ToString("M/d/yyyy") & " by " & AppHelper.GetUser()

            'Initialize Page Information
            linkExportBatchMaintFormat.NavigateUrl = "BulkItemMaintBatchExport.aspx?bid=" & batchDetail.ID

            ' Initialize Batch Export
            Session("_XLS_BATCH_EXPORT_RETURN_") = "BulkItemMaintItems.aspx?id=" & batchDetail.ID ' set return address for xls batch export
            linkExportBatchMaintFormat.Visible = True

            ' get the validation counts
            Dim batchCounts As Models.BatchValidCounts = Data.MaintItemMasterData.GetBatchValidCounts(batchDetail.ID)
            itemUCount = batchCounts.ItemUnknownCount
            itemNVCount = batchCounts.ItemNotValidCount
            itemVCount = batchCounts.ItemValidCount
        Else
            Response.Redirect("default.aspx")
        End If ' Not itemHeader Is Nothing

    End Sub

    Private Sub InitializeCallbacks()

        ' callback
        Dim cbReference As String
        cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", "ReceiveServerData", "context")
        Dim callbackScript As String = "function CallServer(arg, context)" & "{" & cbReference & "; }"
        Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "CallServer", callbackScript, True)

    End Sub

    Private Sub InitializeItemGrid(ByVal batchDetail As Models.BatchRecord, ByVal changes As Models.IMTableChanges)

        ' Initialize column xml
        _userColumns = New XmlDocument()
        _userColumnsXML = UserEnabledColumns
        If _userColumnsXML = "" Then
            _userColumnsXML = DBRecords.LoadUserEnabledColumns(Session("UserID"), ItemGrid.GridID)
            UserEnabledColumns = _userColumnsXML
        End If
        _userColumns.LoadXml(_userColumnsXML)

        ' Setup grid
        ItemGrid.HighlightRow = True
        ItemGrid.ShowSearch = True
        ItemGrid.AutoResizeGrid = True
        ItemGrid.ShowAdvancedSort = True
        ItemGrid.ShowAdvancedFilter = True

        'Add Items for through Search page disabled (as per clients request)
        ItemGrid.ItemAddText = ""
        ItemGrid.ItemAddURL = ""

        ItemGrid.ItemDeleteURL = "BulkItemMaintDetailDelete.aspx?t=d&bid=" & batchDetail.ID
        ItemGrid.ItemEditURL = ""   'No Detail page (as per clients request)
        ItemGrid.ItemViewURL = ""   'No Detail page (as per clients request)

        ItemGrid.ShowContentMenu = True
        ItemGrid.AllowAjaxEdit = True
        ItemGrid.DefaultPageSize = 15
        ItemGrid.FieldNameUnderscore = True
        ItemGrid.PagingCookie = True
        ItemGrid.AllowSetAll = True
        'TODO:  Do we support cost change??
        ItemGrid.CustomLink = "IMCostChange.aspx?r=1"
        ItemGrid.CustomLinkWidth = "910"
        ItemGrid.CustomLinkHeight = "600"

        ' CHANGE CONTROLS
        ItemGrid.ShowChanges = True
        ItemGrid.ChangesIsLockedColumn = "IsLockedForChange"

        ' check S E C U R I T Y 
        If UserCanEdit Then
            ItemGrid.CustomLinkText = "Edit Future Cost Changes"
        Else
            ItemGrid.CustomLinkText = "View Future Cost Changes"
            ItemGrid.ItemViewURL = ""
            ItemGrid.ItemAddURL = ""
            ItemGrid.ItemEditURL = ""
            ItemGrid.ItemDeleteURL = ""
            ItemGrid.AllowAjaxEdit = False
        End If

        ItemGrid.ImagePath = "images/grid/"

        ItemGrid.AddSpecialValue("SKU", String.Empty, "{{VALUE}}", "all")
        
        Dim objGridItem As GridItem = GetColumnDisplayDetails(ItemGrid.GridID)

        Dim twgi As GridItem = ItemGrid.GetGridItem("TaxUDA")
        If twgi IsNot Nothing Then twgi.AllowAjaxEdit = True
        twgi = ItemGrid.GetGridItem("TaxValueUDA")
        If twgi IsNot Nothing Then twgi.AllowAjaxEdit = True
        twgi = ItemGrid.GetGridItem("AllowStoreOrder")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True
        twgi = ItemGrid.GetGridItem("InventoryControl")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True
        twgi = ItemGrid.GetGridItem("Discountable")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True
        twgi = ItemGrid.GetGridItem("AutoReplenish")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True
        twgi = ItemGrid.GetGridItem("PrePriced")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True
        twgi = ItemGrid.GetGridItem("Hazardous")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True
        twgi = ItemGrid.GetGridItem("HazardousFlammable")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True
        twgi = ItemGrid.GetGridItem("PrivateBrandLabel")
        If twgi IsNot Nothing Then twgi.NoBlankListValue = True

        ' ******************************
        ' get data
        ' ******************************
        ' set the record count (which causes the SetupPaging to fire and thus setup the grid)
        Dim strXML As String = GetGridSortAndFilterXML()
        ItemGrid.RecordCount = Data.MaintItemMasterData.GetBulkItemListCount(BatchID, strXML, userID)

        ' get data
        Dim firstRow As Integer = DataHelper.SmartValues(ItemGrid.CurrentPage, "integer", False)
        If firstRow <= 0 Then firstRow = 1
        Dim pageSize As Integer = ItemGrid.CurrentPageSize

        ' get Item list for current page
        gridItemList = Data.MaintItemMasterData.GetBulkItemList(BatchID, firstRow, pageSize, strXML, userID)

        'Bind Grid
        ItemGrid.DataSource = gridItemList.ListRecords
        ItemGrid.ChangesDataSource = changes
        ItemGrid.DataBind()

    End Sub

    Private Sub InitializeSettings(ByVal batchDetail As Models.BatchRecord)

        ' column xml
        _userColumns = New XmlDocument()
        _userColumnsXML = UserEnabledColumns
        If _userColumnsXML = "" Then
            _userColumnsXML = DBRecords.LoadUserEnabledColumns(Session("UserID"), ItemGrid.GridID)
            UserEnabledColumns = _userColumnsXML
        End If
        _userColumns.LoadXml(_userColumnsXML)

        Dim objReader As DBReader = Nothing
        Dim SQLStr As String
        Dim filterID As Integer
        Dim selectedID As Integer = 0
        Dim cnt As Integer
        Try
            ' field count
            SQLStr = "SELECT COUNT(*) AS RecordCount FROM ColumnDisplayName WHERE ISNULL(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & " AND Display = 1 AND Is_Custom = 0 AND Allow_Filter = 1 "
            objReader = DataUtilities.GetDBReader(SQLStr)
            If objReader.HasRows And objReader.Read() Then
                cnt = objReader("RecordCount")
                cnt = cnt / 3
                ColumnCount = cnt
            End If
            objReader.Close()
            objReader.Dispose()
            objReader = Nothing

            ' fields
            SQLStr = "SELECT * FROM ColumnDisplayName WHERE ISNULL(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & " AND Display = 1 AND Is_Custom = 0 AND Allow_Filter = 1" & _
                " ORDER BY Column_Ordinal, [ID]"
            _objData.Tables.Add(DataUtilities.FillTable(SQLStr))

            ' saved filters
            SQLStr = "SELECT ID, Filter_Name, Show_At_Startup FROM SavedFilter WHERE User_ID = '0" & Session("UserID") & "' AND Grid_ID = " & ItemGrid.GridID.ToString() & " ORDER BY Filter_Name"
            objReader = DataUtilities.GetDBReader(SQLStr)
            SelectStartupFilter.Items.Clear()
            SelectStartupFilter.Items.Add(New ListItem("", "0"))
            If objReader.HasRows Then
                Do While objReader.Read()
                    filterID = DataHelper.SmartValues(objReader("ID"), "Integer")
                    SelectStartupFilter.Items.Add(New ListItem(DataHelper.SmartValues(objReader("Filter_Name"), "String"), filterID.ToString()))
                    If (DataHelper.SmartValues(objReader("Show_At_Startup"), "Boolean") = True) Then
                        selectedID = filterID
                    End If
                Loop
            End If
            SelectStartupFilter.SelectedValue = selectedID.ToString()
            objReader.Close()
            objReader.Dispose()
            objReader = Nothing
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
            Throw (ex)
        Finally
            If Not objReader Is Nothing Then
                objReader.Close()
                objReader.Dispose()
                objReader = Nothing
            End If
        End Try

    End Sub

    Public Function RenderValidationControltoHTML(ByRef vrRecord As Models.ValidationRecord, ByVal itemRec As Models.ItemMaintItemDetailFormRecord) As String
        Dim controlString As String = String.Empty
        ' create validation summary control and set it up
        Dim showSummary As Boolean = False
        Dim valDisplay As New NovaLibra.Controls.NLValidationSummary()
        valDisplay.Page = Me.Page
        valDisplay.ID = "validationDisplay"
        valDisplay.ShowSummary = True : valDisplay.ShowMessageBox = False
        valDisplay.CssClass = "validationDisplay"
        valDisplay.EnableClientScript = False
        ' setup control messages
        ValidationHelper.SetupValidationSummary(valDisplay)
        If vrRecord IsNot Nothing AndAlso (vrRecord.HasAnyError()) Then
            showSummary = True
            ValidationHelper.AddValidationSummaryErrors(valDisplay, vrRecord, "SKU " & itemRec.SKU & " (" & itemRec.VendorNumber & ") ")
        End If

        ' render the control
        If showSummary Then
            controlString = FormHelper.RenderControl(valDisplay)
        End If
        ' clean up
        valDisplay = Nothing
        ' return control string
        Return controlString
    End Function

    Protected Sub SetDefaultSort()
        ItemGrid.CurrentAdvancedSort = String.Empty
        ItemGrid.CurrentSortColumn = 1
        ItemGrid.CurrentSortDirection = 0
    End Sub

    Private Sub ShowMsg(ByVal msg As String)

    End Sub

    Protected Sub SaveSettings()
        ' save settings
        Dim SQLStr As String = ""
        Dim conn As DBConnection = ApplicationHelper.GetAppConnection()
        conn.Open()
        Dim cmd As DBCommand = New DBCommand(conn, "", CommandType.Text)
        Dim columns As String = "", str As String = ""
        ' save user enabled columns
        'cmd.CommandText = "delete from UserEnabledColumns where [User_ID] = @userID and ColumnDisplayName_ID IN (select Column_Ordinal from ColumnDisplayName where ISNULL(Workflow_ID, 1) = @gridID)"
        cmd.CommandText = "delete from UserEnabledColumns where [User_ID] = @userID and ColumnDisplayName_ID IN (select ID from ColumnDisplayName where ISNULL(Workflow_ID, 1) = @gridID)"
        cmd.Parameters.Add("@userID", SqlDbType.Int).Value = Session("UserID")
        cmd.Parameters.Add("@gridID", SqlDbType.Int).Value = ItemGrid.GridID
        cmd.ExecuteNonQuery()
        If Request.Form("chk_EnabledCols").Length > 0 Then

            Dim arr As String() = Request.Form("chk_EnabledCols").Split(",")
            For i As Integer = LBound(arr) To UBound(arr)
                If IsNumeric(arr(i)) Then
                    If columns <> "" Then
                        columns += ", "
                    End If
                    columns += Integer.Parse(arr(i).Trim()).ToString()
                End If
            Next
            'If columns <> "" Then
            '    str = "0"
            'Else
            '    str = "0, " & columns
            'End If
            'cmd.CommandText = "insert into UserEnabledColumns ([User_ID], ColumnDisplayName_ID) " & _
            '    " select @userID, [Column_Ordinal] from ColumnDisplayName " & _
            '    " where [Column_Ordinal] in (" & str & ") and Is_Custom = 0 and ISNULL(Workflow_ID, 1) = @gridID"
            If columns = "" Then
                str = "0"
            Else
                str = "0, " & columns
            End If
            cmd.CommandText = "insert into UserEnabledColumns ([User_ID], ColumnDisplayName_ID) " &
                " select @userID, ID from ColumnDisplayName " &
                " where ID in (" & str & ") and Is_Custom = 0 and ISNULL(Workflow_ID, 1) = @gridID"
            cmd.ExecuteNonQuery()
        End If
        _userColumnsXML = DBRecords.LoadUserEnabledColumns(columns)
        UserEnabledColumns = _userColumnsXML
        ' save startup filter
        cmd.CommandText = "update SavedFilter set Show_At_Startup = 0 where [User_ID] = @userID AND Grid_ID = @gridID"
        'cmd.Parameters.Add("@userID", SqlDbType.Int).Value = Session("UserID")
        cmd.ExecuteNonQuery()
        If SelectStartupFilter.SelectedValue <> "0" And IsNumeric(SelectStartupFilter.SelectedValue) Then
            cmd.CommandText = "update SavedFilter set Show_At_Startup = 1 where [User_ID] = @userID and [id] = @id and Grid_ID = @gridID"
            'cmd.Parameters.Clear()
            'cmd.Parameters.Add("@userID", SqlDbType.Int).Value = Session("UserID")
            cmd.Parameters.Add("@id", SqlDbType.Int).Value = DataHelper.SmartValues(SelectStartupFilter.SelectedValue, "Integer")
            cmd.ExecuteNonQuery()
            UserStartupFilter = DataHelper.SmartValues(SelectStartupFilter.SelectedValue, "Integer")
        Else
            UserStartupFilter = 0
        End If

        cmd.Dispose()
        cmd = Nothing
        conn.Close()
        conn.Dispose()
        conn = Nothing

        ' redirect
        'Response.Redirect("detailsettingsclose.aspx")
        'Response.Redirect("detailitems.aspx?hid=" & hid.Value)
    End Sub

    Private Sub ValidateBatch(ByVal batchDetail As Models.BatchRecord, ByVal changes As Models.IMTableChanges)
        Dim validFlag As Integer = 0
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

        Try
            Dim bHasErrors As Boolean = False
            Dim bHasWarnings As Boolean = False
            Dim vrBatch As Models.ValidationRecord
            Dim valRecords As ArrayList = Nothing
            Dim strXML As String = GetDefaultGridSortAndFilterXML()

            If Not ValidationHelper.SkipBatchValidation(batchDetail.WorkflowStageType) Then
                'Validate Batch
                vrBatch = ValidationHelper.ValidateBulkItemMaintBatch(batchDetail, (Not UserCanEdit))
                ' save validation (if user can edit)
                If UserCanEdit Then
                    NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
                End If

                bHasErrors = vrBatch.HasAnyError()
                bHasWarnings = vrBatch.ErrorExists(ValidationRuleSeverityType.TypeWarning)

                'Write out Batch Errors
                If vrBatch.HasAnyError() Then ValidationHelper.AddValidationSummaryErrors(validationDisplay, vrBatch)

                'Validate All Items
                Dim gridItemList As Models.ItemMaintItemDetailRecordList = Data.MaintItemMasterData.GetBulkItemList(batchDetail.ID, 0, 0, strXML, userID)
                valRecords = ValidationHelper.ValidateBulkItemMaintItemList(gridItemList.ListRecords, changes, batchDetail.WorkflowStageID, batchDetail.WorkflowStageType)
                ' save validation (if user can edit)
                If UserCanEdit Then
                    NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecords, userID)
                End If

                For Each vr As Models.ValidationRecord In valRecords
                    If vr.ErrorExists(ValidationRuleSeverityType.TypeError) Then bHasErrors = True
                    If vr.ErrorExists(ValidationRuleSeverityType.TypeWarning) Then bHasWarnings = True
                    Dim gridItem As Models.ItemMaintItemDetailFormRecord = gridItemList.ItemByID(vr.RecordID)
                    'Write out Item errors
                    If vr.HasAnyError() Then ValidationHelper.AddValidationSummaryErrors(validationDisplay, vr, "SKU " & gridItem.SKU & " (" & gridItem.VendorNumber & ") ")
                Next

                'Setup the Validation summary if there are Warnings or Errors
                If bHasErrors Or bHasWarnings Then
                    ValidationHelper.SetupValidationSummary(validationDisplay)
                End If

                'Display Invalid icon if there are any errors.
                If bHasErrors Then
                    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid, True)
                Else
                    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid, True)
                End If

                CheckForStartupScripts(valRecords)
            End If

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            validFlag = -1
        Catch ex As Exception
            Logger.LogError(ex)
            validFlag = -1
        End Try

    End Sub

#Region "Database Calls"
    Private Function GetColumnDisplayDetails(ByVal workflowID As Integer) As GridItem
        Dim objGridItem As New GridItem

        Dim reader As DBReader = Nothing
        Dim sql As String = "select c.ID" & _
            ", isnull(c.Column_Name, '') as Column_Name" & _
            ", c.Column_Type " & _
            ", c.Column_Ordinal" & _
            ", c.Column_Generic_Type" & _
            ", isnull(c.Column_Format, 'string') as Column_Format" & _
            ", isnull(c.Column_Format_String, '') as Column_Format_String" & _
            ", c.Fixed_Column" & _
            ", c.Allow_Sort" & _
            ", c.Allow_Filter" & _
            ", c.Allow_AjaxEdit" & _
            ", c.Default_UserDisplay" & _
            ", c.Display_Name " & _
            ", c.Max_Length " & _
            ", isnull(mc.Treat_Empty_As_Zero, 0) as [TEAZ]" & _
            " from ColumnDisplayName c" & _
            "   left outer join SPD_Metadata_Column mc on mc.Metadata_Table_ID = 11 and mc.Column_Name = c.Column_Name" & _
            " where c.[Display] = 1 and ISNULL(c.Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & _
            " order by c.Column_Ordinal"
        Try
            reader = New DBReader(ApplicationHelper.GetAppConnection())
            reader.CommandText = sql
            reader.CommandType = CommandType.Text
            reader.Open()
            Do While reader.Read()
                If ColumnEnabledByUser(reader("ID"), DataHelper.SmartValues(reader("Default_UserDisplay"), "Boolean")) Then
                    objGridItem = ItemGrid.AddGridItemWithType(reader("Column_Ordinal"), reader("Display_Name"), reader("Column_Name").ToString().Replace("_", ""), reader("Column_Generic_Type"), reader("Column_Format"), reader("Column_Type"))
                    objGridItem.FieldFormatString = reader("Column_Format_String")
                    objGridItem.FixedColumn = DataHelper.SmartValues(reader("Fixed_Column"), "Boolean")
                    objGridItem.SortColumn = DataHelper.SmartValues(reader("Allow_Sort"), "Boolean")
                    objGridItem.FilterColumn = DataHelper.SmartValues(reader("Allow_Filter"), "Boolean")
                    objGridItem.AllowAjaxEdit = DataHelper.SmartValues(reader("Allow_AjaxEdit"), "Boolean")
                    objGridItem.MaxLength = DataHelper.SmartValues(reader("Max_Length"), "integer", False)
                    objGridItem.TreatEmptyAsZero = DataHelper.SmartValues(reader("TEAZ"), "boolean", False)
                End If
            Loop

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
            Throw ex
        Finally
            If Not reader Is Nothing Then
                reader.Dispose()
            End If
        End Try

        Return objGridItem
    End Function

    Private Function GetGridColumnByID(ByVal workflowID As Integer, ByVal columnID As Integer) As GridItem
        Dim gridColumn As New GridItem
        Dim reader As DBReader = Nothing
        Dim cmd As DBCommand = Nothing
        Dim conn As DBConnection = Nothing
        Dim colReader As DBReader = Nothing
        Try

            conn = ApplicationHelper.GetAppConnection()
            Dim sql As String = "select Column_Name, Column_Generic_Type from ColumnDisplayName where Workflow_ID = " & ItemGrid.GridID & " and Column_Ordinal = @colID"

            cmd = New DBCommand(conn, sql, CommandType.Text)
            cmd.Parameters.Add("@colID", SqlDbType.Int).Value = DataHelper.SmartValues(columnID, "Integer")
            reader = New DBReader(cmd)
            reader.Open()
            Do While reader.Read()
                gridColumn.FieldName = DataHelper.SmartValues(reader("Column_Name"), "CStr", False)
                gridColumn.FieldType = DataHelper.SmartValues(reader("Column_Generic_Type"), "CStr", False)
            Loop


        Catch sqlex As SqlException
            Logger.LogError(sqlex)
        Catch ex As Exception
            Logger.LogError(ex)
        Finally
            If Not colReader Is Nothing Then
                colReader.Dispose()
                colReader = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
        End Try

        Return gridColumn
    End Function

    Private Function GetGridColumns(ByVal workflowID As Integer) As List(Of GridItem)
        Dim giarr As New List(Of GridItem)
        Dim colReader As DBReader = Nothing
        Dim conn As DBConnection = Nothing

        Try

            conn = ApplicationHelper.GetAppConnection()

            Dim colSQL As String = "select ID" & _
                ", isnull(Column_Name, '') as Column_Name" & _
                ", Column_Ordinal" & _
                ", Default_UserDisplay" & _
                " from ColumnDisplayName" & _
                " where [Display] = 1 and isnull(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & _
                " order by Column_Ordinal"
            colReader = New DBReader(conn, colSQL, CommandType.Text)
            colReader.Open()

            Do While colReader.Read()
                giarr.Add(New GridItem(colReader("Column_Ordinal"), String.Empty, colReader("Column_Name").ToString().Replace("_", String.Empty), String.Empty))
            Loop
            colReader.Dispose()
            colReader = Nothing

            ' clean up
            conn.Dispose()
            conn = Nothing

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
        Catch ex As Exception
            Logger.LogError(ex)
        Finally
            If Not colReader Is Nothing Then
                colReader.Dispose()
                colReader = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
        End Try

        Return giarr
    End Function
#End Region

#Region "Scripts"
    Private Sub CheckForStartupScripts(ByRef valRecords As ArrayList)
        Dim startupScriptKey As String = "__item_list_"
        If Not Me.Page.ClientScript.IsStartupScriptRegistered(startupScriptKey) Then
            CreateStartupScripts(startupScriptKey, valRecords)
        End If
    End Sub

    Private Sub CreateStartupScripts(ByVal startupScriptKey As String, ByRef valrecords As ArrayList)

        Dim sb As New StringBuilder("")

        sb.Length = 0
        sb.Append("" & vbCrLf)
        sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)

        sb.Append("var displayValid = '<br />" & ValidationHelper.GetValidationDisplayString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid, True) & "';" & vbCrLf)
        sb.Append("var displayNotValid = '<br />" & ValidationHelper.GetValidationDisplayString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid, True) & "';" & vbCrLf)

        For Each vr As Models.ValidationRecord In valrecords
            sb.Append(String.Format(("setValIcon('{0}', {1});" & vbCrLf), vr.RecordID, CType(IIf(vr.IsValid, "displayValid", "displayNotValid"), String)))
        Next

        sb.Append(vbCrLf & "itemViewURL = '" & ItemViewURL & "';" & vbCrLf)

        If Not CostChanges Then
            sb.Append(vbCrLf & "enableEffectiveDate(false);" & vbCrLf)
        End If

        sb.Append("//-->" & vbCrLf)
        sb.Append("</script>" & vbCrLf)

        CreateValidationErrorsScript(valrecords, sb)

        Me.ClientScript.RegisterStartupScript(Me.GetType(), startupScriptKey, sb.ToString())
    End Sub

    Private Sub CreateValidationErrorsScript(ByRef valrecords As ArrayList, ByRef sb As StringBuilder)
        Dim sbFieldsErr As New StringBuilder("")
        Dim sbFieldsWarn As New StringBuilder("")
        Dim id As Long

        sb.Append("<script language=""javascript"" type=""text/javascript"" defer=""true"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)
        sb.Append("function showValidationErrors() {" & vbCrLf)

        For Each vr As Models.ValidationRecord In valrecords
            If vr.HasAnyError() Then
                For Each ve As Models.ValidationError In vr.ValidationErrors
                    id = GetColIDFromName(ve.Field.Replace("_", ""))
                    If id > 0 Then
                        If ve.ErrorSeverity = ValidationRuleSeverityType.TypeError Then
                            If sbFieldsErr.ToString() <> "" Then
                                sbFieldsErr.Append(",")
                            End If
                            sbFieldsErr.Append("'gc_" & vr.RecordID & "_" & id & "'")
                        ElseIf ve.ErrorSeverity = ValidationRuleSeverityType.TypeWarning Then
                            If sbFieldsWarn.ToString() <> "" Then
                                sbFieldsWarn.Append(",")
                            End If
                            sbFieldsWarn.Append("'gc_" & vr.RecordID & "_" & id & "'")
                        End If
                    End If
                Next
            End If
        Next
        If sbFieldsErr.ToString() <> "" Then
            sb.Append(String.Format(("setCellClass('gCVE', {0});" & vbCrLf), sbFieldsErr.ToString()))
        End If
        If sbFieldsWarn.ToString() <> "" Then
            sb.Append(String.Format(("setCellClass('gCVW', {0});" & vbCrLf), sbFieldsWarn.ToString()))
        End If

        sb.Append("}" & vbCrLf)

        sb.Append("var t = setTimeout('showValidationErrors()', 170);" & vbCrLf)

        sb.Append("//-->" & vbCrLf)
        sb.Append("</script>" & vbCrLf)
    End Sub

    Private Function GetColIDFromName(ByVal colName As String) As Long
        Dim colID As Long = 0
        For Each gi As GridItem In ItemGrid.GridItems
            'lp fix, column has been renamed Dec 2009
            If colName = "InitialSetQtyPerStore" Then
                colName = "POGSetupPerStore"
            End If
            If gi.FieldName = colName Then
                colID = gi.ID
                Exit For
            End If
        Next
        Return colID
    End Function
#End Region

#Region "Callbacks"

    Public Function GetCallbackResult() As String Implements System.Web.UI.ICallbackEventHandler.GetCallbackResult
        Dim str As String() = Split(_callbackArg, CALLBACK_SEP)
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        If str.Length <= 0 Then
            Return ""
        End If
        Select Case str(0)
            Case "100"
                ' save ajax edit
                If str.Length < 5 Then
                    Return ""
                End If
                Return CallbackSaveAjaxEdit(str(1), str(2), str(3), str(4))
            Case "200"
                ' save ajax edit for column
                If str.Length < 5 Then
                    Return ""
                End If
                Return CallbackSaveAjaxEditSetAll(str(1), str(2), str(3), str(4))
            Case "300"
                'Nothing needed here
            Case "EFFECTIVEDATE"
                If str.Length < 3 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Dim bid As Long = DataHelper.SmartValues(str(1), "long", False)
                Dim effDate As Date = DataHelper.SmartValues(str(2), "date", True)
                Dim bRet As Boolean = Me.SaveEffectiveDate(bid, effDate)
                If bRet Then
                    Return str(0) & CALLBACK_SEP & "1"
                Else
                    Return str(0) & CALLBACK_SEP & "0"
                End If
        End Select
        Return ""
    End Function

    Public Sub RaiseCallbackEvent(ByVal eventArgument As String) Implements System.Web.UI.ICallbackEventHandler.RaiseCallbackEvent
        _callbackArg = eventArgument
    End Sub

    Public Function SaveEffectiveDate(ByVal bid As Long, ByVal effectiveDate As Date) As Boolean
        Dim userID As Integer = DataHelper.SmartValues(Session("UserID"), "integer")
        Dim success As Boolean = Data.BatchData.SaveBatchEffectiveDate(bid, effectiveDate, userID)
        Return success
    End Function

    Public Function CallbackSaveAjaxEdit(ByVal columnID As String, ByVal columnName As String, ByVal rowID As String, ByVal dataText As String) As String
        Dim retValue As String = String.Empty
        Dim retValue2 As String = CALLBACK_SEP & " " & CALLBACK_SEP & " " & CALLBACK_SEP & " "
        Dim retValue3 As String = String.Empty
        Dim retValue4 As String = CALLBACK_SEP & " " & CALLBACK_SEP & " "
        Dim retvalue5 As String = CALLBACK_SEP & " "
        Dim SQLStr As String = String.Empty

        Dim strValue As String
        Dim itemID As Long = DataHelper.SmartValues(rowID, "long")
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

        Dim colID As Integer = DataHelper.SmartValues(columnID, "integer", False)
        Dim startID As Integer = Me.CustomFieldStartID
        Dim isCustomField As Boolean = False
        If colID >= startID AndAlso startID > 0 Then isCustomField = True

        Dim itemRec As Models.ItemMaintItemDetailFormRecord = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(itemID, AppHelper.GetVendorID())
        Dim saveRowChanges As New Models.IMRowChanges(itemID)
        Dim rowChanges As Models.IMRowChanges

        Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
        Debug.Assert(md IsNot Nothing)
        Dim table As NovaLibra.Coral.SystemFrameworks.MetadataTable = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        Debug.Assert(table IsNot Nothing)

        If itemRec Is Nothing Then
            retValue = "100" & CALLBACK_SEP & "0"
            Return retValue
        End If

        Dim objData As New Data.BatchData
        Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(itemRec.BatchID)
        objData = Nothing

        Try

            If isCustomField Then
                Dim saved As Boolean = False
                Dim fieldID As Integer = DataHelper.SmartValues(columnName, "integer", False)
                Dim custFields As NovaLibra.Coral.SystemFrameworks.CustomFields = NovaLibra.Coral.BusinessFacade.SystemCustomFields.GetCustomFields(Me.RecordType, itemID, True)
                custFields.AddValue(itemID, fieldID, dataText)
                saved = NovaLibra.Coral.BusinessFacade.SystemCustomFields.SaveCustomFieldValues(custFields)
                If saved Then
                    retValue = "100" & CALLBACK_SEP & "1" & retValue2 & retValue3
                Else
                    retValue = "100" & CALLBACK_SEP & "0"
                End If
            Else

                Dim colName As String, strType As String
                Dim gi As GridItem = GetGridColumnByID(ItemGrid.GridID, columnID)
                Dim saveValue As Object, originalValue As Object

                If Not String.IsNullOrEmpty(gi.FieldName) Then
                    colName = gi.FieldName
                    strType = gi.FieldType

                    ' special field functions (before save)
                    If colName = "PrimaryUPC" Then
                        If IsNumeric(dataText) AndAlso DataHelper.SmartValues(dataText, "long", False) > 0 Then
                            dataText = dataText.Trim()
                            Do While dataText.Length < 14
                                dataText = "0" & dataText
                            Loop
                            retValue2 = CALLBACK_SEP & "VendorUPC" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "VendorStyleNum" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            retValue2 = CALLBACK_SEP & "VendorStyleNum" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "PlanogramName" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            retValue2 = CALLBACK_SEP & "PlanogramName" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "ItemDesc" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            retValue2 = CALLBACK_SEP & "ItemDesc" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "ShippingPoint" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            retValue2 = CALLBACK_SEP & "ShippingPoint" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf (colName = "DutyPercent" Or colName = "AgentCommissionPercent" Or colName = "OtherImportCostsPercent" Or colName = "SuppTariffPercent") Then
                        If IsNumeric(dataText.Replace("%", "")) Then
                            saveValue = DataHelper.SmartValues(dataText.Replace("%", "").Trim(), "decimal", True)
                            If saveValue <> Decimal.MinValue Then
                                saveValue = saveValue / 100
                                dataText = saveValue.ToString()
                            End If
                        End If
                    ElseIf (colName = "EnglishLongDescription" Or colName = "EnglishShortDescription") Then
                        If itemRec.PackItemIndicator.StartsWith("DP") Then
                            dataText = "Display Pack"
                        ElseIf itemRec.PackItemIndicator.StartsWith("SB") Then
                            dataText = "Sellable Bundle"
                        ElseIf itemRec.PackItemIndicator.StartsWith("D") Then
                            dataText = "Displayer"
                        End If
                        retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & dataText
                    ElseIf colName = "EachCaseHeight" Or colName = "EachCaseWidth" Or colName = "EachCaseLength" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "InnerCaseHeight" Or colName = "InnerCaseWidth" Or colName = "InnerCaseLength" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "MasterCaseHeight" Or colName = "MasterCaseWidth" Or colName = "MasterCaseLength" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "EachCaseWeight" Or colName = "InnerCaseWeight" Or colName = "MasterCaseWeight" Then
                        dataText = RoundDimesionsString(dataText.Trim(), 4)
                    End If

                    ' end special field functions (before save)
                    ' ------------------------------------------------------------------------------------------------------------------


                    Dim skipSave As Boolean = False
                    saveValue = DataHelper.SmartValues(dataText, strType, True)
                    originalValue = DataHelper.SmartValues(FormHelper.GetObjectValue(itemRec, colName), strType, True)

                    'NAK 5/15/2013:  Per Michaels, if the original value is Y, do not let the user change it
                    If (colName = "TIFrench" Or colName = "TISpanish") And originalValue.ToString = "Y" Then
                        saveValue = "Y"
                        ' refresh the grid...
                        retvalue5 = CALLBACK_SEP & "1"
                    End If

                    ' save the change and clear
                    Dim loadFlashValue As String = String.Empty
                    If colName = WebConstants.cNEWPRIMARY OrElse colName = WebConstants.cNEWPRIMARYCODE Then '"CountryOfOriginName"
                        skipSave = True
                        'ElseIf batchDetail.IsPack() Then
                        '    If itemRec.IsPackParent() AndAlso colName = "QtyInPack" Then
                        '        skipSave = True
                        '        retValue2 = CALLBACK_SEP & "QtyInPack" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP
                        '        loadFlashValue = "QtyInPack"
                        '    End If
                    End If

                    If Not skipSave Then
                        ' add the change record
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(originalValue, colName, strType, saveValue))

                        ' save the change
                        Data.MaintItemMasterData.SaveItemMaintChanges(saveRowChanges, userID)
                        saveRowChanges.ClearChanges()
                    End If

                    ' load all the changes
                    rowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(itemID)

                    If loadFlashValue <> String.Empty Then
                        If loadFlashValue = "QtyInPack" Then
                            retValue2 = retValue2 & DataHelper.SmartValuesAsString(FormHelper.GetValueWithChanges(itemRec.QtyInPack, rowChanges, "QtyInPack", strType), strType)
                        End If
                    End If

                    ' special field functions (after save)
                    If colName = "PLIEnglish" Then
                        If String.IsNullOrEmpty(itemRec.TIEnglish) Then
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.TIEnglish, "TIEnglish", "string", dataText))
                        End If
                        retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & dataText
                    ElseIf colName = "PLIFrench" Then
                        If String.IsNullOrEmpty(itemRec.TIFrench) Then
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.TIFrench, "TIFrench", "string", dataText))
                        End If
                        retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & dataText
                    ElseIf colName = "EachCaseHeight" Or colName = "EachCaseWidth" Or colName = "EachCaseLength" Or colName = "EachCaseWeight" Then
                        ' check to see if Each case pack cube needs to be calced

                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty

                        he = FormHelper.GetValueWithChanges(itemRec.EachCaseHeight, rowChanges, "EachCaseHeight", "decimal")
                        wi = FormHelper.GetValueWithChanges(itemRec.EachCaseWidth, rowChanges, "EachCaseWidth", "decimal")
                        le = FormHelper.GetValueWithChanges(itemRec.EachCaseLength, rowChanges, "EachCaseLength", "decimal")
                        we = FormHelper.GetValueWithChanges(itemRec.EachCaseWeight, rowChanges, "EachCaseWeight", "decimal")

                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If

                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.EachCaseCube, "EachCaseCube", "decimal", cresult))

                        retValue2 = CALLBACK_SEP & "EachCaseCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                    ElseIf colName = "InnerCaseHeight" Or colName = "InnerCaseWidth" Or colName = "InnerCaseLength" Or colName = "InnerCaseWeight" Then
                        ' check to see if inner case pack cube needs to be calced

                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty

                        he = FormHelper.GetValueWithChanges(itemRec.InnerCaseHeight, rowChanges, "InnerCaseHeight", "decimal")
                        wi = FormHelper.GetValueWithChanges(itemRec.InnerCaseWidth, rowChanges, "InnerCaseWidth", "decimal")
                        le = FormHelper.GetValueWithChanges(itemRec.InnerCaseLength, rowChanges, "InnerCaseLength", "decimal")
                        we = FormHelper.GetValueWithChanges(itemRec.InnerCaseWeight, rowChanges, "InnerCaseWeight", "decimal")

                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If

                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.InnerCaseCube, "InnerCaseCube", "decimal", cresult))

                        retValue2 = CALLBACK_SEP & "InnerCaseCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult

                    ElseIf itemRec.VendorType = Models.ItemType.Domestic AndAlso (colName = "MasterCaseHeight" Or colName = "MasterCaseWidth" Or colName = "MasterCaseLength" Or colName = "MasterCaseWeight") Then
                        ' check to see if master case pack cube needs to be calced

                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty

                        he = FormHelper.GetValueWithChanges(itemRec.MasterCaseHeight, rowChanges, "MasterCaseHeight", "decimal")
                        wi = FormHelper.GetValueWithChanges(itemRec.MasterCaseWidth, rowChanges, "MasterCaseWidth", "decimal")
                        le = FormHelper.GetValueWithChanges(itemRec.MasterCaseLength, rowChanges, "MasterCaseLength", "decimal")
                        we = FormHelper.GetValueWithChanges(itemRec.MasterCaseWeight, rowChanges, "MasterCaseWeight", "decimal")

                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If

                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.MasterCaseCube, "MasterCaseCube", "decimal", cresult))

                        retValue2 = CALLBACK_SEP & "MasterCaseCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult

                    ElseIf itemRec.VendorType = Models.ItemType.Import AndAlso colName = "MasterCaseWeight" Then
                        retValue2 = CALLBACK_SEP & "MasterCaseWeight" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & dataText

                    ElseIf itemRec.VendorType = Models.ItemType.Import AndAlso _
                        (colName = "MasterCaseHeight" Or _
                         colName = "MasterCaseWidth" Or _
                         colName = "MasterCaseLength" Or _
                         colName = "VendorOrAgent" Or _
                         colName = "DisplayerCost" Or _
                         colName = "ProductCost" Or _
                         colName = "FOBShippingPoint" Or _
                         colName = "DutyPercent" Or _
                         colName = "AdditionalDutyAmount" Or _
                         colName = "SuppTariffPercent" Or _
                         colName = "EachesMasterCase" Or _
                         colName = "OceanFreightAmount" Or _
                         colName = "OceanFreightComputedAmount" Or _
                         colName = "AgentCommissionPercent" Or _
                         colName = "OtherImportCostsPercent" Or _
                         colName = "PackagingCostAmount") Then

                        Dim returnXML As String = String.Empty
                        Dim xmlout As New XmlDocument

                        ' load xml
                        ' --------

                        xmlout.LoadXml(CalculationHelper.GetCalculateCostReturnXML())

                        ' set values
                        ' ----------
                        ' input vars
                        Dim agent As String = FormHelper.GetValueWithChanges(itemRec.VendorOrAgent, rowChanges, "VendorOrAgent", "string")
                        If agent.Length > 0 AndAlso (agent = "A" Or agent.StartsWith("A")) Then
                            agent = "A"
                        Else
                            agent = String.Empty
                        End If
                        Dim dispcost As Decimal = FormHelper.GetValueWithChanges(itemRec.DisplayerCost, rowChanges, "DisplayerCost", "decimal")
                        Dim prodcost As Decimal = FormHelper.GetValueWithChanges(itemRec.ProductCost, rowChanges, "ProductCost", "decimal")
                        Dim fob As Decimal = FormHelper.GetValueWithChanges(itemRec.FOBShippingPoint, rowChanges, "FOBShippingPoint", "decimal")
                        Dim dutyper As Decimal = FormHelper.GetValueWithChanges(itemRec.DutyPercent, rowChanges, "DutyPercent", "decimal")
                        If dutyper <> Decimal.MinValue Then dutyper = dutyper * 100
                        Dim addduty As Decimal = FormHelper.GetValueWithChanges(itemRec.AdditionalDutyAmount, rowChanges, "AdditionalDutyAmount", "decimal")

                        Dim supptariffper As Decimal = FormHelper.GetValueWithChanges(itemRec.SuppTariffPercent, rowChanges, "SuppTariffPercent", "decimal")
                        If supptariffper <> Decimal.MinValue Then supptariffper = supptariffper * 100

                        Dim eachesmc As Decimal = FormHelper.GetValueWithChanges(itemRec.EachesMasterCase, rowChanges, "EachesMasterCase", "decimal")
                        Dim mclength As Decimal = RoundDimesionsDecimal(FormHelper.GetValueWithChanges(itemRec.MasterCaseLength, rowChanges, "MasterCaseLength", "decimal"))
                        Dim mcwidth As Decimal = RoundDimesionsDecimal(FormHelper.GetValueWithChanges(itemRec.MasterCaseWidth, rowChanges, "MasterCaseWidth", "decimal"))
                        Dim mcheight As Decimal = RoundDimesionsDecimal(FormHelper.GetValueWithChanges(itemRec.MasterCaseHeight, rowChanges, "MasterCaseHeight", "decimal"))

                        Dim oceanfre As Decimal = FormHelper.GetValueWithChanges(itemRec.OceanFreightAmount, rowChanges, "OceanFreightAmount", "decimal")
                        Dim oceanamt As Decimal = FormHelper.GetValueWithChanges(itemRec.OceanFreightComputedAmount, rowChanges, "OceanFreightComputedAmount", "decimal")
                        Dim agentcommper As Decimal = FormHelper.GetValueWithChanges(itemRec.AgentCommissionPercent, rowChanges, "AgentCommissionPercent", "decimal")
                        If agentcommper <> Decimal.MinValue Then agentcommper = agentcommper * 100
                        Dim otherimportper As Decimal = FormHelper.GetValueWithChanges(itemRec.OtherImportCostsPercent, rowChanges, "OtherImportCostsPercent", "decimal")
                        If otherimportper <> Decimal.MinValue Then otherimportper = otherimportper * 100
                        Dim packcost As Decimal = Decimal.MinValue
                        ' calculated vars
                        fob = CalculationHelper.CalcImportFOB(dispcost, prodcost)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.FOBShippingPoint, "FOBShippingPoint", "decimal", fob))

                        Dim cubicftpermc As Decimal = CalculationHelper.CalcImportCubicFeetPerMasterCarton(mclength, mcwidth, mcheight)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.MasterCaseCube, "MasterCaseCube", "decimal", cubicftpermc))

                        Dim duty As Decimal = CalculationHelper.CalcImportDuty(fob, dutyper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.DutyAmount, "DutyAmount", "decimal", duty))

                        Dim supptariff As Decimal = CalculationHelper.CalcSuppTariff(fob, supptariffper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.SuppTariffAmount, "SuppTariffAmount", "decimal", supptariff))

                        Dim ocean As Decimal = CalculationHelper.CalcImportOceanFrieght(eachesmc, cubicftpermc, oceanfre)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.OceanFreightComputedAmount, "OceanFreightComputedAmount", "decimal", ocean))

                        Dim agentcomm As Decimal = CalculationHelper.CalcImportAgentComm(agent, fob, agentcommper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.AgentCommissionAmount, "AgentCommissionAmount", "decimal", agentcomm))

                        Dim otherimport As Decimal = CalculationHelper.CalcOtherImportCost(fob, otherimportper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.OtherImportCostsAmount, "OtherImportCostsAmount", "decimal", otherimport))

                        Dim totalimport As Decimal = CalculationHelper.CalcImportTotalImport(agent, fob, duty, addduty, ocean, agentcomm, otherimport, packcost, supptariff)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.ImportBurden, "ImportBurden", "decimal", totalimport))

                        Dim totalcost As Decimal = CalculationHelper.CalcImportTotalCost(fob, totalimport)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.WarehouseLandedCost, "WarehouseLandedCost", "decimal", totalcost))

                        Dim outfreight As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.OutboundFreight, "OutboundFreight", "decimal", outfreight))

                        Dim ninewhse As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost, outfreight)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.NinePercentWhseCharge, "NinePercentWhseCharge", "decimal", ninewhse))

                        Dim totalstore As Decimal = CalculationHelper.CalcImportTotalStore(totalcost, outfreight, ninewhse)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.TotalStoreLandedCost, "TotalStoreLandedCost", "decimal", totalstore))


                        ' store results
                        ' ------------
                        CalculationHelper.SetXMLValue(xmlout, "agent", agent)
                        If dispcost <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "dispcost", DataHelper.SmartValues(dispcost, "formatnumber4", False))
                        If prodcost <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "prodcost", DataHelper.SmartValues(prodcost, "formatnumber4", False))
                        If fob <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "fob", DataHelper.SmartValues(fob, "formatnumber4", False))
                        If dutyper <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "dutyper", DataHelper.SmartValues((dutyper / 100), "percent", False))
                        If addduty <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "addduty", DataHelper.SmartValues(addduty, "formatnumber4", False))
                        If supptariffper <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "supptariffper", DataHelper.SmartValues((supptariffper / 100), "percent", False))
                        If eachesmc <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "eachesmc", DataHelper.SmartValues(eachesmc, "integer", False))
                        If mclength <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "mclength", DataHelper.SmartValues(mclength, "formatnumber4", False))
                        If mcwidth <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "mcwidth", DataHelper.SmartValues(mcwidth, "formatnumber4", False))
                        If mcheight <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "mcheight", DataHelper.SmartValues(mcheight, "formatnumber4", False))
                        If cubicftpermc <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "cubicftpermc", DataHelper.SmartValues(cubicftpermc, "formatnumber3", False))
                        If oceanfre <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "oceanfre", DataHelper.SmartValues(oceanfre, "formatnumber4", False))
                        If oceanamt <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "oceanamt", DataHelper.SmartValues(oceanamt, "formatnumber4", False))
                        If agentcommper <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "agentcommper", DataHelper.SmartValues((agentcommper / 100), "percent", False))
                        If otherimportper <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "otherimportper", DataHelper.SmartValues((otherimportper / 100), "percent", False))
                        If packcost <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "packcost", DataHelper.SmartValues(packcost, "formatnumber4", False))
                        If duty <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "duty", DataHelper.SmartValues(duty, "formatnumber4", False))
                        If supptariff <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "supptariff", DataHelper.SmartValues(supptariff, "formatnumber4", False))
                        If ocean <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "ocean", DataHelper.SmartValues(ocean, "formatnumber4", False))
                        If agentcomm <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "agentcomm", DataHelper.SmartValues(agentcomm, "formatnumber4", False))
                        If otherimport <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "otherimport", DataHelper.SmartValues(otherimport, "formatnumber4", False))
                        If totalimport <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "totalimport", DataHelper.SmartValues(totalimport, "formatnumber4", False))
                        If totalcost <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "totalcost", DataHelper.SmartValues(totalcost, "formatnumber4", False))
                        If outfreight <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "outfreight", DataHelper.SmartValues(outfreight, "formatnumber4", False))
                        If ninewhse <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "ninewhse", DataHelper.SmartValues(ninewhse, "formatnumber4", False))
                        If totalstore <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "totalstore", DataHelper.SmartValues(totalstore, "formatnumber4", False))

                        ' set return value
                        ' ----------------
                        returnXML = xmlout.OuterXml
                        xmlout = Nothing

                        ' return
                        retValue2 = CALLBACK_SEP & "CALC_EstLandedCost" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & returnXML


                    ElseIf colName = "Hazardous" Then
                        ' hazardous

                        Dim cresult As String = String.Empty

                        Dim haz As String = dataText
                        If haz <> "Y" Then
                            'Hazardous_Flammable
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousFlammable, "HazardousFlammable", "varchar", "N"))
                            'Hazardous_Container_Type
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousContainerType, "HazardousContainerType", "varchar", String.Empty))
                            'Hazardous_Container_Size
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousContainerSize, "HazardousContainerSize", "decimal", String.Empty))
                            'Hazardous_MSDS_UOM
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousMSDSUOM, "HazardousMSDSUOM", "varchar", String.Empty))
                            'Hazardous_Manufacturer_Name
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerName, "HazardousManufacturerName", "varchar", String.Empty))
                            'Hazardous_Manufacturer_City
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerCity, "HazardousManufacturerCity", "varchar", String.Empty))
                            'Hazardous_Manufacturer_State
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerState, "HazardousManufacturerState", "varchar", String.Empty))
                            'Hazardous_Manufacturer_Phone
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerPhone, "HazardousManufacturerPhone", "varchar", String.Empty))
                            'Hazardous_Manufacturer_Country
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerCountry, "HazardousManufacturerCountry", "varchar", String.Empty))

                            retValue2 = CALLBACK_SEP & "Hazardous" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & String.Empty
                        End If


                    ElseIf colName = WebConstants.cNEWPRIMARY Then ' "CountryOfOriginName"
                        ' converstion date

                        'Dim countryName As String = FormHelper.GetValueWithChanges(itemRec.CountryOfOriginName, rowChanges, WebConstants.cNEWPRIMARY, "string")
                        Dim countryName As String = saveValue.ToString()
                        Dim countryCode As String = String.Empty
                        Dim cresult As String = String.Empty

                        ' resolve the name to code/name (if possible)
                        Dim country As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(countryName)
                        If Not country Is Nothing AndAlso country.CountryCode <> String.Empty AndAlso country.CountryName <> String.Empty Then
                            countryName = country.CountryName
                            countryCode = country.CountryCode
                            cresult = countryName
                        Else
                            'countryName = countryName
                            countryCode = String.Empty
                            cresult = countryName
                        End If

                        saveRowChanges.Remove(WebConstants.cNEWPRIMARYCODE)
                        saveRowChanges.Remove(WebConstants.cNEWPRIMARY)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.CountryOfOrigin, WebConstants.cNEWPRIMARYCODE, "string", countryCode))
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.CountryOfOriginName, WebConstants.cNEWPRIMARY, "string", countryName))

                        ' make any necessary changes to the additional coo list
                        Dim cooName As String = String.Empty
                        Dim cooCode As String = String.Empty
                        Dim addCOOCode As String = String.Empty
                        Dim addCOOName As String = String.Empty
                        Dim arrAddCOOCodes() As String
                        Dim arrAddCOONames() As String
                        Dim saveAddCOO As New List(Of Models.CountryRecord)
                        Dim n As Integer, found As Boolean
                        Dim coo As Models.CountryRecord
                        ' get the current primary country of origin value changes if they exist
                        If rowChanges.ChangeExists(WebConstants.cNEWPRIMARY) AndAlso rowChanges.ChangeExists(WebConstants.cNEWPRIMARYCODE) Then
                            cooCode = rowChanges.GetCellChange(WebConstants.cNEWPRIMARYCODE).FieldValue
                            cooName = rowChanges.GetCellChange(WebConstants.cNEWPRIMARY).FieldValue
                        End If
                        ' get the addition coo changes
                        If rowChanges.ChangeExists(WebConstants.cADDCOONAME) Then
                            addCOOName = rowChanges.GetCellChange(WebConstants.cADDCOONAME).FieldValue
                            arrAddCOONames = addCOOName.Split(WebConstants.cPIPE)
                            For n = 0 To arrAddCOONames.Length - 1
                                coo = New Models.CountryRecord()
                                coo.CountryName = arrAddCOONames(n)
                                saveAddCOO.Add(coo)
                            Next
                        End If
                        If rowChanges.ChangeExists(WebConstants.cADDCOO) Then
                            addCOOCode = rowChanges.GetCellChange(WebConstants.cADDCOO).FieldValue
                            arrAddCOOCodes = addCOOCode.Split(WebConstants.cPIPE)
                            For n = 0 To arrAddCOOCodes.Length - 1
                                If n < saveAddCOO.Count Then
                                    saveAddCOO.Item(n).CountryCode = arrAddCOOCodes(n)
                                End If
                            Next
                        End If
                        ' delete from addition list old primary coo if exists (if needed)
                        If cooName <> String.Empty AndAlso saveAddCOO.Count > 0 Then
                            For n = saveAddCOO.Count - 1 To 0 Step -1
                                If saveAddCOO.Item(n).CountryName = cooName Then
                                    saveAddCOO.RemoveAt(n)
                                End If
                            Next
                        End If
                        If cooCode <> String.Empty AndAlso saveAddCOO.Count > 0 Then
                            For n = saveAddCOO.Count - 1 To 0 Step -1
                                If saveAddCOO.Item(n).CountryCode = cooCode Then
                                    saveAddCOO.RemoveAt(n)
                                End If
                            Next
                        End If
                        ' add to additional list new primary coo (if needed)
                        If countryName <> String.Empty AndAlso itemRec.AdditionCOOExistsByName(countryName) = False AndAlso itemRec.CountryOfOriginName <> countryName Then
                            found = False
                            For n = 0 To saveAddCOO.Count - 1
                                If saveAddCOO.Item(n).CountryName = countryName Then
                                    found = True
                                    Exit For
                                End If
                            Next
                            If Not found Then
                                coo = New Models.CountryRecord
                                coo.CountryCode = countryCode
                                coo.CountryName = countryName
                                saveAddCOO.Add(coo)
                            End If
                        End If
                        ' save list(s) to save change rec collection
                        Dim saveCode As String = String.Empty
                        Dim saveName As String = String.Empty
                        If saveAddCOO.Count > 0 Then
                            For n = 0 To saveAddCOO.Count - 1
                                If n > 0 Then saveCode = saveCode & WebConstants.cPIPE
                                saveCode = saveCode & saveAddCOO.Item(n).CountryCode
                                If n > 0 Then saveName = saveName & WebConstants.cPIPE
                                saveName = saveName & saveAddCOO.Item(n).CountryName
                            Next
                        End If
                        If rowChanges.ChangeExists(WebConstants.cADDCOO) OrElse saveCode <> String.Empty Then
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(String.Empty, WebConstants.cADDCOO, "string", saveCode))
                        End If
                        If rowChanges.ChangeExists(WebConstants.cADDCOONAME) OrElse saveName <> String.Empty Then
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(String.Empty, WebConstants.cADDCOONAME, "string", saveName))
                        End If

                        ' clean up
                        saveAddCOO.Clear()
                        saveAddCOO = Nothing

                        retValue2 = CALLBACK_SEP & WebConstants.cNEWPRIMARY & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult


                    ElseIf itemRec.VendorType = Models.ItemType.Domestic AndAlso _
                        (colName = "DisplayerCost" OrElse colName = "PackItemIndicator" OrElse colName = "ItemCost") Then

                        ' check to see if total cost values need to be calced
                        Dim returnToken As String = String.Empty
                        Dim it As String = String.Empty
                        Dim auc As Decimal = Decimal.MinValue
                        Dim pii As String = String.Empty
                        Dim icost As Decimal = Decimal.MinValue
                        Dim ticost As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty

                        it = FormHelper.GetValueWithChanges(itemRec.ItemType, rowChanges, "ItemType", "string")
                        auc = FormHelper.GetValueWithChanges(itemRec.DisplayerCost, rowChanges, "DisplayerCost", "decimal")
                        pii = FormHelper.GetValueWithChanges(itemRec.PackItemIndicator, rowChanges, "PackItemIndicator", "string")
                        icost = FormHelper.GetValueWithChanges(itemRec.ItemCost, rowChanges, "ItemCost", "decimal")

                        returnToken = "ItemCosts"
                        ticost = CalculationHelper.CalculateIMTotalCost(it, auc, pii, icost)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.FOBShippingPoint, "FOBShippingPoint", "decimal", ticost))
                        cresult = IIf(auc = Decimal.MinValue, String.Empty, DataHelper.SmartValues(auc, "formatnumber4", True)) & _
                            "__" & IIf(icost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(icost, "formatnumber4", True)) & _
                            "__" & IIf(ticost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(ticost, "formatnumber4", True))

                        retValue2 = CALLBACK_SEP & returnToken & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult

                    End If
                    ' end special field functions (after save)
                    ' ------------------------------------------------------------------------------------------

                    ' save the changes
                    Data.MaintItemMasterData.SaveItemMaintChanges(saveRowChanges, userID)

                    ' merge the row changes (so we don't have to do another DB hit) prior to validation.
                    rowChanges.MergeChangeRecords(saveRowChanges, True)


                    ' Effective Date check

                    If colName = "ProductCost" Or colName = "ItemCost" Then
                        If Data.MaintItemMasterData.GetHasCostChangesByBatchID(batchDetail.ID) Then
                            If Not ValidationHelper.SkipValidation(batchDetail.WorkflowStageType) Then
                                If DataHelper.SmartValues(batchDetail.EffectiveDate, "date", False) <= DataHelper.SmartValues(Now(), "date", True) Then
                                    Dim newDate As Date = DateAdd(DateInterval.Day, 1, Now())
                                    batchDetail.EffectiveDate = newDate
                                    Me.SaveEffectiveDate(batchDetail.ID, newDate)
                                End If
                                retValue4 = CALLBACK_SEP & "1" & CALLBACK_SEP & DataHelper.SmartValues(batchDetail.EffectiveDate, "formatdate", False)
                            End If
                        Else
                            retValue4 = CALLBACK_SEP & "0" & CALLBACK_SEP & " "
                        End If
                    End If

                    ' check to see if need to calculate parent cost of a pack batch
                    'If colName = "QtyInPack" Or colName = "ProductCost" Or colName = "ItemCost" Then
                    '    If Not itemRec.IsPackParent() Then
                    '        If ItemMaintHelper.CalculateDPBatchParent(batchDetail.ID, True, False) Then
                    '            ' refresh the grid...
                    '            retvalue5 = CALLBACK_SEP & "1"
                    '        End If
                    '    End If
                    'End If

                    ' check to see if need to calculate parent master weight of a pack batch
                    'If colName = "MasterCaseWeight" Then
                    '    If Not itemRec.IsPackParent() Then
                    '        If ItemMaintHelper.CalculateDPBatchParent(batchDetail.ID, False, True) Then
                    '            ' refresh the grid...
                    '            retvalue5 = CALLBACK_SEP & "1"
                    '        End If
                    '    End If
                    'End If

                    If colName.ToUpper = "PLIENGLISH" Or colName.ToUpper = "PLIFRENCH" Or colName.ToUpper = "PLISPANISH" Then
                        ' refresh the grid...
                        retvalue5 = CALLBACK_SEP & "1"
                    End If

                    'Validate Batch and Item
                    Dim vrBatch As Models.ValidationRecord
                    Dim vr As Models.ValidationRecord

                    If ValidationHelper.SkipBatchValidation(batchDetail.WorkflowStageType) Then
                        vrBatch = New Models.ValidationRecord(batchDetail.ID, Models.ItemRecordType.Batch)
                    Else
                        vrBatch = ValidationHelper.ValidateBulkItemMaintBatch(batchDetail, (Not UserCanEdit))
                        ' save validation 
                        NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
                    End If

                    If ValidationHelper.SkipValidation(batchDetail.WorkflowStageType) Then
                        vr = New Models.ValidationRecord(itemRec.ID, Models.ItemRecordType.ItemMaintItem)
                    Else
                        vr = ValidationHelper.ValidateBulkItemMaintItem(itemRec, rowChanges, batchDetail.WorkflowStageID, batchDetail.WorkflowStageType, (Not UserCanEdit))
                        ' save validation 
                        NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vr, userID)
                    End If

                    Dim giarr As List(Of GridItem) = GetGridColumns(ItemGrid.GridID)
                    Dim sbFields As New StringBuilder("")
                    Dim id As Long

                    For Each ve As Models.ValidationError In vr.ValidationErrors
                        id = GetColIDFromGridItemArray(giarr, ve.Field.Replace("_", ""))
                        If id > 0 Then
                            If sbFields.ToString() <> "" Then
                                sbFields.Append(",")
                            End If
                            sbFields.Append("'gc_" & vr.RecordID & "_" & id & "'")
                            sbFields.Append("," & IIf(ve.ErrorSeverity = ValidationRuleSeverityType.TypeError, "'1'", "'2'"))
                        End If
                    Next

                    Dim isBatchValid As Boolean = False

                    retValue3 = CALLBACK_SEP & itemID & CALLBACK_SEP & sbFields.ToString() & CALLBACK_SEP & CType(IIf(vr.IsValid, "displayValid", "displayNotValid"), String)
                    retValue3 = retValue3 & CALLBACK_SEP & IIf(isBatchValid, "1", "0")
                    retValue3 = retValue3 & CALLBACK_SEP & itemRec.ID & "~~" & RenderValidationControltoHTML(vr, itemRec)

                    ' return
                    retValue = "100" & CALLBACK_SEP & "1" & retValue2 & retValue3 & retValue4 & retvalue5
                End If

                'itemDetail.SaveAuditRecord(audit)

            End If ' end if not custom fields

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            retValue = "100" & CALLBACK_SEP & "0"
        Catch ex As Exception
            Logger.LogError(ex)
            retValue = "100" & CALLBACK_SEP & "0"
        End Try

        Return retValue
    End Function

    Public Function CallbackSaveAjaxEditSetAll(ByVal columnID As String, ByVal columnName As String, ByVal itemHeaderID As String, ByVal dataText As String) As String
        Dim retValue As String = String.Empty
        Dim retValue2 As String = String.Empty
        Dim SQLStr As String = String.Empty
        Dim strValue As String

        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        Me.BatchID = DataHelper.SmartValues(itemHeaderID, "long", False)

        Dim itemDetail As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim itemsaudit As New Models.AuditRecord(Models.MetadataTable.Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)
        Dim audit As New Models.AuditRecord(Models.MetadataTable.Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)

        Dim colID As Integer = DataHelper.SmartValues(columnID, "integer", False)
        Dim startID As Integer = Me.CustomFieldStartID
        Dim isCustomField As Boolean = False
        If colID >= startID AndAlso startID > 0 Then isCustomField = True

        Dim itemRec As Models.ItemMaintItemDetailFormRecord
        Dim itemRecList As Models.ItemMaintItemDetailRecordList = Data.MaintItemMasterData.GetBulkItemList(BatchID, 1, Integer.MaxValue, "", userID)
        Dim i As Integer
        Dim saveTableChanges As New Models.IMTableChanges()
        Dim saveRowChanges As Models.IMRowChanges
        Dim tableChanges As Models.IMTableChanges
        Dim rowChanges As Models.IMRowChanges

        Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
        Debug.Assert(md IsNot Nothing)
        Dim table As NovaLibra.Coral.SystemFrameworks.MetadataTable = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        Debug.Assert(table IsNot Nothing)

        Dim objData As New Data.BatchData
        Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(Me.BatchID)
        objData = Nothing

        If BatchID <= 0 Then
            retValue = "200" & CALLBACK_SEP & "0"
            Return retValue
        End If

        Try
            Dim colName As String, strType As String
            Dim saveValue As Object, originalValue As Object
            Dim gi As GridItem = GetGridColumnByID(ItemGrid.GridID, columnID)
            If Not String.IsNullOrEmpty(gi.FieldName) Then

                colName = gi.FieldName
                strType = gi.FieldType

                ' special field functions (before save)
                If colName = "PrimaryUPC" Then
                    If IsNumeric(dataText) AndAlso DataHelper.SmartValues(dataText, "long", False) > 0 Then
                        dataText = dataText.Trim()
                        Do While dataText.Length < 14
                            dataText = "0" & dataText
                        Loop
                    End If
                ElseIf colName = "VendorStyleNum" Then
                    strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                    If strValue <> dataText Then
                        dataText = strValue
                    End If
                ElseIf colName = "PlanogramName" Then
                    strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                    If strValue <> dataText Then
                        dataText = strValue
                    End If
                ElseIf colName = "ItemDesc" Then
                    strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                    If strValue <> dataText Then
                        dataText = strValue
                    End If
                ElseIf colName = "ShippingPoint" Then
                    strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                    If strValue <> dataText Then
                        dataText = strValue
                    End If
                ElseIf (colName = "DutyPercent" Or colName = "AgentCommissionPercent" Or colName = "OtherImportCostsPercent" Or colName = "SuppTariffPercent") Then
                    If IsNumeric(dataText) Then
                        saveValue = DataHelper.SmartValues(dataText.Trim(), "decimal", True)
                        If saveValue <> Decimal.MinValue Then
                            saveValue = saveValue / 100
                            dataText = saveValue.ToString()
                        End If
                    End If
                ElseIf colName = "EachCaseHeight" Or colName = "EachCaseWidth" Or colName = "EachCaseLength" Then
                    dataText = RoundDimesionsString(dataText.Trim())
                ElseIf colName = "InnerCaseHeight" Or colName = "InnerCaseWidth" Or colName = "InnerCaseLength" Then
                    dataText = RoundDimesionsString(dataText.Trim())
                ElseIf colName = "MasterCaseHeight" Or colName = "MasterCaseWidth" Or colName = "MasterCaseLength" Then
                    dataText = RoundDimesionsString(dataText.Trim())
                ElseIf colName = "EachCaseWeight" Or colName = "InnerCaseWeight" Or colName = "MasterCaseWeight" Then
                    dataText = RoundDimesionsString(dataText.Trim(), 4)
                End If
                ' end special field functions (before save)


                saveValue = DataHelper.SmartValues(dataText, strType, True)

                Dim skipSave As Boolean = False
                Dim skipSaveRec As Boolean
                If colName = WebConstants.cNEWPRIMARY OrElse colName = WebConstants.cNEWPRIMARYCODE Then '"CountryOfOriginName"
                    skipSave = True
                End If

                If Not skipSave Then
                    For i = 0 To itemRecList.RecordCount - 1
                        itemRec = itemRecList.Item(i)

                        skipSaveRec = False
                        'If batchDetail.IsPack() Then
                        '    If (itemRec.IsPackParent() AndAlso colName = "QtyInPack") Or _
                        '        (Not itemRec.IsPackParent() AndAlso itemRec.VendorType = Models.ItemType.Domestic AndAlso colName = "DisplayerCost") Then
                        '        skipSaveRec = True
                        '    End If
                        'End If

                        'Override English Long/Short description based on Pack Item Indicator
                        If colName = "EnglishLongDescription" Or colName = "EnglishShortDescription" Then
                            If itemRec.PackItemIndicator.StartsWith("DP") Then
                                saveValue = "Display Pack"
                            ElseIf itemRec.PackItemIndicator.StartsWith("SB") Then
                                saveValue = "Sellable Bundle"
                            ElseIf itemRec.PackItemIndicator.StartsWith("D") Then
                                saveValue = "Displayer"
                            Else
                                saveValue = dataText
                            End If
                        End If

                        'NAK 5/15/2013:  Per Michaels, if the original value is Y, do not let the user change it
                        If (colName = "TIFrench" And itemRec.TIFrench = "Y") Or (colName = "TISpanish" And itemRec.TISpanish = "Y") Then
                            skipSaveRec = True
                        Else
                            skipSaveRec = False
                        End If

                        If Not skipSaveRec Then
                            saveRowChanges = New Models.IMRowChanges(itemRec.ID)
                            originalValue = DataHelper.SmartValues(FormHelper.GetObjectValue(itemRec, colName), strType, True)
                            'cellChange = New Models.IMCellChangeRecord(colName, DataHelper.SmartValuesAsString(saveValue, strType), (IIf(saveValue = originalValue, False, True)))
                            'saveRowChanges.Add(cellChange)
                            saveRowChanges.Add(FormHelper.CreateChangeRecord(originalValue, colName, strType, saveValue))
                            saveTableChanges.Add(saveRowChanges)
                        End If
                    Next

                    ' save the changes and then clear
                    Data.MaintItemMasterData.SaveItemMaintChanges(saveTableChanges, userID)
                    saveTableChanges.ClearChanges(True)
                End If

                ' load all the changes
                tableChanges = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(BatchID)


                ' special field functions (after save)
                If colName = "PLIEnglish" Then
                    For i = 0 To itemRecList.RecordCount - 1
                        itemRec = itemRecList.Item(i)
                        rowChanges = tableChanges.GetRow(itemRec.ID, True)
                        If String.IsNullOrEmpty(FormHelper.GetValueWithChanges(itemRec.TIEnglish, rowChanges, "TIEnglish", "string")) Then
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.TIEnglish, "TIEnglish", "string", dataText))
                        End If
                    Next
                ElseIf colName = "PLIFrench" Then
                    For i = 0 To itemRecList.RecordCount - 1
                        itemRec = itemRecList.Item(i)
                        rowChanges = tableChanges.GetRow(itemRec.ID, True)
                        If String.IsNullOrEmpty(FormHelper.GetValueWithChanges(itemRec.TIFrench, rowChanges, "TIFrench", "string")) Then
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.TIFrench, "TIFrench", "string", dataText))
                        End If
                    Next
                ElseIf colName = "EachCaseHeight" Or colName = "EachCaseWidth" Or colName = "EachCaseLength" Or colName = "EachCaseWeight" Then

                    ' check to see if Each case pack cube needs to be calced
                    Dim he As Decimal = Decimal.MinValue
                    Dim wi As Decimal = Decimal.MinValue
                    Dim le As Decimal = Decimal.MinValue
                    Dim we As Decimal = Decimal.MinValue
                    Dim cresult As String = String.Empty

                    For i = 0 To itemRecList.RecordCount - 1
                        itemRec = itemRecList.Item(i)
                        rowChanges = tableChanges.GetRow(itemRec.ID, True)
                        he = FormHelper.GetValueWithChanges(itemRec.EachCaseHeight, rowChanges, "EachCaseHeight", "decimal")
                        wi = FormHelper.GetValueWithChanges(itemRec.EachCaseWidth, rowChanges, "EachCaseWidth", "decimal")
                        le = FormHelper.GetValueWithChanges(itemRec.EachCaseLength, rowChanges, "EachCaseLength", "decimal")
                        we = FormHelper.GetValueWithChanges(itemRec.EachCaseWeight, rowChanges, "EachCaseWeight", "decimal")
                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If

                        saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.EachCaseCube, "EachCaseCube", "decimal", cresult))
                    Next

                ElseIf colName = "InnerCaseHeight" Or colName = "InnerCaseWidth" Or colName = "InnerCaseLength" Or colName = "InnerCaseWeight" Then

                    ' check to see if inner case pack cube needs to be calced
                    Dim he As Decimal = Decimal.MinValue
                    Dim wi As Decimal = Decimal.MinValue
                    Dim le As Decimal = Decimal.MinValue
                    Dim we As Decimal = Decimal.MinValue
                    Dim cresult As String = String.Empty

                    For i = 0 To itemRecList.RecordCount - 1
                        itemRec = itemRecList.Item(i)
                        rowChanges = tableChanges.GetRow(itemRec.ID, True)
                        he = FormHelper.GetValueWithChanges(itemRec.InnerCaseHeight, rowChanges, "InnerCaseHeight", "decimal")
                        wi = FormHelper.GetValueWithChanges(itemRec.InnerCaseWidth, rowChanges, "InnerCaseWidth", "decimal")
                        le = FormHelper.GetValueWithChanges(itemRec.InnerCaseLength, rowChanges, "InnerCaseLength", "decimal")
                        we = FormHelper.GetValueWithChanges(itemRec.InnerCaseWeight, rowChanges, "InnerCaseWeight", "decimal")
                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If

                        saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.InnerCaseCube, "InnerCaseCube", "decimal", cresult))
                    Next

                ElseIf (colName = "MasterCaseHeight" Or colName = "MasterCaseWidth" Or colName = "MasterCaseLength" Or colName = "MasterCaseWeight") Or _
                    (colName = "DisplayerCost" OrElse colName = "PackItemIndicator" OrElse colName = "ItemCost") Or _
                    (colName = "MasterCaseHeight" Or _
                     colName = "MasterCaseWidth" Or _
                     colName = "MasterCaseLength" Or _
                     colName = "VendorOrAgent" Or _
                     colName = "DisplayerCost" Or _
                     colName = "ProductCost" Or _
                     colName = "FOBShippingPoint" Or _
                     colName = "DutyPercent" Or _
                     colName = "AdditionalDutyAmount" Or _
                     colName = "SuppTariffPercent" Or _
                     colName = "EachesMasterCase" Or _
                     colName = "OceanFreightAmount" Or _
                     colName = "OceanFreightComputedAmount" Or _
                     colName = "AgentCommissionPercent" Or _
                     colName = "OtherImportCostsPercent" Or _
                     colName = "PackagingCostAmount") Then

                    ' check to see if master case pack cube needs to be calced
                    Dim he As Decimal = Decimal.MinValue
                    Dim wi As Decimal = Decimal.MinValue
                    Dim le As Decimal = Decimal.MinValue
                    Dim we As Decimal = Decimal.MinValue
                    Dim cresult As String = String.Empty

                    Dim it As String = String.Empty
                    Dim auc As Decimal = Decimal.MinValue
                    Dim pii As String = String.Empty
                    Dim icost As Decimal = Decimal.MinValue
                    Dim ticost As Decimal = Decimal.MinValue

                    For i = 0 To itemRecList.RecordCount - 1
                        itemRec = itemRecList.Item(i)
                        rowChanges = tableChanges.GetRow(itemRec.ID, True)

                        If itemRec.VendorType = Models.ItemType.Domestic Then

                            If colName = "MasterCaseHeight" Or colName = "MasterCaseWidth" Or colName = "MasterCaseLength" Or colName = "MasterCaseWeight" Then

                                he = FormHelper.GetValueWithChanges(itemRec.MasterCaseHeight, rowChanges, "MasterCaseHeight", "decimal")
                                wi = FormHelper.GetValueWithChanges(itemRec.MasterCaseWidth, rowChanges, "MasterCaseWidth", "decimal")
                                le = FormHelper.GetValueWithChanges(itemRec.MasterCaseLength, rowChanges, "MasterCaseLength", "decimal")
                                we = FormHelper.GetValueWithChanges(itemRec.MasterCaseWeight, rowChanges, "MasterCaseWeight", "decimal")

                                If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                                    cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                                Else
                                    cresult = String.Empty
                                End If

                                saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.MasterCaseCube, "MasterCaseCube", "decimal", cresult))

                            ElseIf (colName = "DisplayerCost" OrElse colName = "PackItemIndicator" OrElse colName = "ItemCost") Then

                                it = FormHelper.GetValueWithChanges(itemRec.ItemType, rowChanges, "ItemType", "string")
                                auc = FormHelper.GetValueWithChanges(itemRec.DisplayerCost, rowChanges, "DisplayerCost", "decimal")
                                pii = FormHelper.GetValueWithChanges(itemRec.PackItemIndicator, rowChanges, "PackItemIndicator", "string")
                                icost = FormHelper.GetValueWithChanges(itemRec.ItemCost, rowChanges, "ItemCost", "decimal")

                                ticost = CalculationHelper.CalculateIMTotalCost(it, auc, pii, icost)
                                saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.FOBShippingPoint, "FOBShippingPoint", "decimal", ticost))

                            End If

                        ElseIf itemRec.VendorType = Models.ItemType.Import Then

                            ' set values
                            ' ----------
                            ' input vars
                            Dim agent As String = FormHelper.GetValueWithChanges(itemRec.VendorOrAgent, rowChanges, "VendorOrAgent", "string")
                            If agent.Length > 0 AndAlso (agent = "A" Or agent.StartsWith("A")) Then
                                agent = "A"
                            Else
                                agent = String.Empty
                            End If
                            Dim dispcost As Decimal = FormHelper.GetValueWithChanges(itemRec.DisplayerCost, rowChanges, "DisplayerCost", "decimal")
                            Dim prodcost As Decimal = FormHelper.GetValueWithChanges(itemRec.ProductCost, rowChanges, "ProductCost", "decimal")
                            Dim fob As Decimal = FormHelper.GetValueWithChanges(itemRec.FOBShippingPoint, rowChanges, "FOBShippingPoint", "decimal")
                            Dim dutyper As Decimal = FormHelper.GetValueWithChanges(itemRec.DutyPercent, rowChanges, "DutyPercent", "decimal")
                            If dutyper <> Decimal.MinValue Then dutyper = dutyper * 100

                            Dim supptariffper As Decimal = FormHelper.GetValueWithChanges(itemRec.SuppTariffPercent, rowChanges, "SuppTariffPercent", "decimal")
                            If supptariffper <> Decimal.MinValue Then supptariffper = supptariffper * 100

                            Dim addduty As Decimal = FormHelper.GetValueWithChanges(itemRec.AdditionalDutyAmount, rowChanges, "AdditionalDutyAmount", "decimal")
                            Dim eachesmc As Decimal = FormHelper.GetValueWithChanges(itemRec.EachesMasterCase, rowChanges, "EachesMasterCase", "decimal")
                            Dim mclength As Decimal = FormHelper.GetValueWithChanges(itemRec.MasterCaseLength, rowChanges, "MasterCaseLength", "decimal")
                            Dim mcwidth As Decimal = FormHelper.GetValueWithChanges(itemRec.MasterCaseWidth, rowChanges, "MasterCaseWidth", "decimal")
                            Dim mcheight As Decimal = FormHelper.GetValueWithChanges(itemRec.MasterCaseHeight, rowChanges, "MasterCaseHeight", "decimal")
                            Dim oceanfre As Decimal = FormHelper.GetValueWithChanges(itemRec.OceanFreightAmount, rowChanges, "OceanFreightAmount", "decimal")
                            Dim oceanamt As Decimal = FormHelper.GetValueWithChanges(itemRec.OceanFreightComputedAmount, rowChanges, "OceanFreightComputedAmount", "decimal")
                            Dim agentcommper As Decimal = FormHelper.GetValueWithChanges(itemRec.AgentCommissionPercent, rowChanges, "AgentCommissionPercent", "decimal")
                            If agentcommper <> Decimal.MinValue Then agentcommper = agentcommper * 100
                            Dim otherimportper As Decimal = FormHelper.GetValueWithChanges(itemRec.OtherImportCostsPercent, rowChanges, "OtherImportCostsPercent", "decimal")
                            If otherimportper <> Decimal.MinValue Then otherimportper = otherimportper * 100
                            Dim packcost As Decimal = Decimal.MinValue
                            ' calculated vars
                            fob = CalculationHelper.CalcImportFOB(dispcost, prodcost)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.FOBShippingPoint, "FOBShippingPoint", "decimal", fob))

                            Dim cubicftpermc As Decimal = CalculationHelper.CalcImportCubicFeetPerMasterCarton(mclength, mcwidth, mcheight)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.MasterCaseCube, "MasterCaseCube", "decimal", cubicftpermc))

                            Dim duty As Decimal = CalculationHelper.CalcImportDuty(fob, dutyper)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.DutyAmount, "DutyAmount", "decimal", duty))

                            Dim supptariff As Decimal = CalculationHelper.CalcSuppTariff(fob, supptariffper)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.SuppTariffAmount, "SuppTariffAmount", "decimal", supptariff))

                            Dim ocean As Decimal = CalculationHelper.CalcImportOceanFrieght(eachesmc, cubicftpermc, oceanfre)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.OceanFreightComputedAmount, "OceanFreightComputedAmount", "decimal", ocean))

                            Dim agentcomm As Decimal = CalculationHelper.CalcImportAgentComm(agent, fob, agentcommper)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.AgentCommissionAmount, "AgentCommissionAmount", "decimal", agentcomm))

                            Dim otherimport As Decimal = CalculationHelper.CalcOtherImportCost(fob, otherimportper)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.OtherImportCostsAmount, "OtherImportCostsAmount", "decimal", otherimport))

                            Dim totalimport As Decimal = CalculationHelper.CalcImportTotalImport(agent, fob, duty, addduty, ocean, agentcomm, otherimport, packcost, supptariff)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.ImportBurden, "ImportBurden", "decimal", totalimport))

                            Dim totalcost As Decimal = CalculationHelper.CalcImportTotalCost(fob, totalimport)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.WarehouseLandedCost, "WarehouseLandedCost", "decimal", totalcost))

                            Dim outfreight As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.OutboundFreight, "OutboundFreight", "decimal", outfreight))

                            Dim ninewhse As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost, outfreight)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.NinePercentWhseCharge, "NinePercentWhseCharge", "decimal", ninewhse))

                            Dim totalstore As Decimal = CalculationHelper.CalcImportTotalStore(totalcost, outfreight, ninewhse)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.TotalStoreLandedCost, "TotalStoreLandedCost", "decimal", totalstore))

                        End If
                    Next

                ElseIf colName = "Hazardous" Then
                    ' hazardous
                    Dim cresult As String = String.Empty

                    Dim haz As String = dataText
                    If haz <> "Y" Then
                        For i = 0 To itemRecList.RecordCount - 1
                            itemRec = itemRecList.Item(i)

                            'Hazardous_Flammable
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousFlammable, "HazardousFlammable", "varchar", "N"))
                            'Hazardous_Container_Type
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousContainerType, "HazardousContainerType", "varchar", String.Empty))
                            'Hazardous_Container_Size
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousContainerSize, "HazardousContainerSize", "decimal", String.Empty))
                            'Hazardous_MSDS_UOM
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousMSDSUOM, "HazardousMSDSUOM", "varchar", String.Empty))
                            'Hazardous_Manufacturer_Name
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerName, "HazardousManufacturerName", "varchar", String.Empty))
                            'Hazardous_Manufacturer_City
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerCity, "HazardousManufacturerCity", "varchar", String.Empty))
                            'Hazardous_Manufacturer_State
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerState, "HazardousManufacturerState", "varchar", String.Empty))
                            'Hazardous_Manufacturer_Phone
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerPhone, "HazardousManufacturerPhone", "varchar", String.Empty))
                            'Hazardous_Manufacturer_Country
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.HazardousManufacturerCountry, "HazardousManufacturerCountry", "varchar", String.Empty))
                        Next
                    End If

                ElseIf colName = WebConstants.cNEWPRIMARY Then
                    ' country of origin name

                    Dim countryName As String = saveValue
                    Dim countryCode As String = String.Empty
                    Dim cresult As String = String.Empty

                    Dim country As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(countryName)
                    If Not country Is Nothing AndAlso country.CountryCode <> String.Empty AndAlso country.CountryName <> String.Empty Then
                        countryName = country.CountryName
                        countryCode = country.CountryCode
                        cresult = countryName
                    Else
                        'countryName = countryName
                        countryCode = String.Empty
                        cresult = countryName
                    End If


                    For i = 0 To itemRecList.RecordCount - 1
                        itemRec = itemRecList.Item(i)
                        saveTableChanges.GetRow(itemRec.ID, True).Remove("CountryOfOrigin")
                        saveTableChanges.GetRow(itemRec.ID, True).Remove("CountryOfOriginName")
                        saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.CountryOfOrigin, "CountryOfOrigin", "varchar", countryCode))
                        saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.CountryOfOriginName, "CountryOfOriginName", "varchar", countryName))

                        ' make any necessary changes to the additional coo list
                        Dim cooName As String = String.Empty
                        Dim cooCode As String = String.Empty
                        Dim addCOOCode As String = String.Empty
                        Dim addCOOName As String = String.Empty
                        Dim arrAddCOOCodes() As String
                        Dim arrAddCOONames() As String
                        Dim saveAddCOO As New List(Of Models.CountryRecord)
                        Dim n As Integer, found As Boolean
                        Dim coo As Models.CountryRecord
                        ' get the current primary country of origin value changes if they exist
                        If tableChanges.GetRow(itemRec.ID, True).ChangeExists(WebConstants.cNEWPRIMARY) AndAlso tableChanges.GetRow(itemRec.ID, True).ChangeExists(WebConstants.cNEWPRIMARYCODE) Then
                            cooCode = tableChanges.GetRow(itemRec.ID, True).GetCellChange(WebConstants.cNEWPRIMARYCODE).FieldValue
                            cooName = tableChanges.GetRow(itemRec.ID, True).GetCellChange(WebConstants.cNEWPRIMARY).FieldValue
                        End If
                        ' get the addition coo changes

                        If tableChanges.GetRow(itemRec.ID, True).ChangeExists(WebConstants.cADDCOONAME) Then
                            addCOOName = tableChanges.GetRow(itemRec.ID, True).GetCellChange(WebConstants.cADDCOONAME).FieldValue
                            arrAddCOONames = addCOOName.Split(WebConstants.cPIPE)
                            For n = 0 To arrAddCOONames.Length - 1
                                coo = New Models.CountryRecord()
                                coo.CountryName = arrAddCOONames(n)
                                saveAddCOO.Add(coo)
                            Next
                        End If
                        If tableChanges.GetRow(itemRec.ID, True).ChangeExists(WebConstants.cADDCOO) Then
                            addCOOCode = tableChanges.GetRow(itemRec.ID, True).GetCellChange(WebConstants.cADDCOO).FieldValue
                            arrAddCOOCodes = addCOOCode.Split(WebConstants.cPIPE)
                            For n = 0 To arrAddCOOCodes.Length - 1
                                If n < saveAddCOO.Count Then
                                    saveAddCOO.Item(n).CountryCode = arrAddCOOCodes(n)
                                End If
                            Next
                        End If
                        ' delete from addition list old primary coo if exists (if needed)
                        If cooName <> String.Empty AndAlso saveAddCOO.Count > 0 Then
                            For n = saveAddCOO.Count - 1 To 0 Step -1
                                If saveAddCOO.Item(n).CountryName = cooName Then
                                    saveAddCOO.RemoveAt(n)
                                End If
                            Next
                        End If
                        If cooCode <> String.Empty AndAlso saveAddCOO.Count > 0 Then
                            For n = saveAddCOO.Count - 1 To 0 Step -1
                                If saveAddCOO.Item(n).CountryCode = cooCode Then
                                    saveAddCOO.RemoveAt(n)
                                End If
                            Next
                        End If
                        ' add to additional list new primary coo (if needed)
                        If countryName <> String.Empty AndAlso itemRec.AdditionCOOExistsByName(countryName) = False AndAlso itemRec.CountryOfOriginName <> countryName Then
                            found = False
                            For n = 0 To saveAddCOO.Count - 1
                                If saveAddCOO.Item(n).CountryName = countryName Then
                                    found = True
                                    Exit For
                                End If
                            Next
                            If Not found Then
                                coo = New Models.CountryRecord()
                                coo.CountryCode = countryCode
                                coo.CountryName = countryName
                                saveAddCOO.Add(coo)
                            End If
                        End If
                        ' save list(s) to save change rec collection
                        Dim saveCode As String = String.Empty
                        Dim savename As String = String.Empty
                        If saveAddCOO.Count > 0 Then
                            For n = 0 To saveAddCOO.Count - 1
                                If n > 0 Then saveCode = saveCode & WebConstants.cPIPE
                                saveCode = saveCode & saveAddCOO.Item(n).CountryCode
                                If n > 0 Then savename = savename & WebConstants.cPIPE
                                savename = savename & saveAddCOO.Item(n).CountryName
                            Next
                        End If
                        If tableChanges.GetRow(itemRec.ID, True).ChangeExists(WebConstants.cADDCOO) OrElse saveCode <> String.Empty Then
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(String.Empty, WebConstants.cADDCOO, "string", saveCode))
                        End If
                        If tableChanges.GetRow(itemRec.ID, True).ChangeExists(WebConstants.cADDCOONAME) OrElse savename <> String.Empty Then
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(String.Empty, WebConstants.cADDCOONAME, "string", savename))
                        End If

                        ' clean up
                        saveAddCOO.Clear()
                        saveAddCOO = Nothing

                    Next

                End If
                ' end special field functions (after save)
                ' ------------------------------------------------------------------------------------------

                ' save the changes
                Data.MaintItemMasterData.SaveItemMaintChanges(saveTableChanges, userID)

                ' check to see if need to calculate parent cost of a pack batch
                If colName = "QtyInPack" Or colName = "ProductCost" Or colName = "ItemCost" Then
                    ItemMaintHelper.CalculateDPBatchParent(Me.BatchID, True, False)
                End If

                ' check to see if need to calculate parent cost of a pack batch
                If colName = "MasterCaseWeight" Then
                    ItemMaintHelper.CalculateDPBatchParent(Me.BatchID, False, True)
                End If

                ' clean up
                saveRowChanges = Nothing
                rowChanges = Nothing
                saveTableChanges = Nothing
                tableChanges = Nothing

                retValue = "200" & CALLBACK_SEP & "1" & retValue2
            End If

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            retValue = "200" & CALLBACK_SEP & "0"
        Catch ex As Exception
            Logger.LogError(ex)
            retValue = "200" & CALLBACK_SEP & "0"
        End Try

        Return retValue
    End Function

#End Region
End Class
