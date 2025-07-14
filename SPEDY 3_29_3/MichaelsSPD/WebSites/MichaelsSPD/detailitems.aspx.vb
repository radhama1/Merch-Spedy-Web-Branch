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
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports ItemHelper

Partial Class detailitems
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler

#Region "Attributes and Properties"

    Private _callbackArg As String = ""

    Public Const CALLBACK_SEP As String = "{{|}}"

    Private _objData As New DataSet

    Public Function GetItemHeaderID() As String
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
            Return WebConstants.RECTYPE_DOMESTIC_ITEM
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

#End Region

#Region "Page Events"

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the page
        'Response.Write("<!-- TIME: Init - " & Now().ToString() & "-->")
        'Me.Page.Response.Buffer = True
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'Response.Write("<!-- TIME: Load - " & Now().ToString() & "-->")
        Dim itemHeaderID As Long = 0
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

        If Not Me.IsCallback Then

            SecurityCheckRedirect()

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

            Dim itemHeader As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord = Nothing
            Dim itemUCount As Integer = 0
            Dim itemNVCount As Integer = 0
            Dim itemVCount As Integer = 0
            Dim iucnt1 As Integer = 0, iucnt2 As Integer = 0
            Dim invcnt1 As Integer = 0, invcnt2 As Integer = 0
            Dim ivcnt1 As Integer = 0, ivcnt2 As Integer = 0
            Dim isPack As Boolean = False

            If Not IsPostBack Then
                ' load record if update mode
                If Request("hid") <> "" AndAlso IsNumeric(Request("hid")) Then
                    hid.Value = Request("hid")
                End If ' Request("hid")
            Else
                If Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "settings" Then
                    SaveSettings()
                End If
            End If ' IsPostBack

            If hid.Value = "" Then
                Response.Redirect("detail.aspx")
            End If

            'TWSetAll
            If Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "TWSetAll" Then
                ValidateEntireItemList(hid.Value)
            End If

            itemHeaderID = DataHelper.SmartValues(hid.Value, "long", False)
            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()

            itemHeader = objMichaels.GetItemHeaderRecord(itemHeaderID)
            Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = Nothing

            If Not itemHeader Is Nothing Then

                Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
                batchDetail = objMichaelsBatch.GetRecord(itemHeader.BatchID)
                objMichaelsBatch = Nothing

                ' VALIDATE USER
                ValidateUser(itemHeader.BatchID, batchDetail.WorkflowStageType)
                If NoUserAccess Then Response.Redirect("default.aspx")

                ' Vendor Check
                VendorCheckRedirect(itemHeader.USVendorNum, itemHeader.CanadianVendorNum)

                hid.Value = itemHeader.ID.ToString()
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
                lastUpdatedMe.Value = " &nbsp;|&nbsp; " & "Last Updated: " & Now().ToString("M/d/yyyy") & " by " & AppHelper.GetUser()
                itemUCount = itemHeader.ItemUnknownCount
                itemNVCount = itemHeader.ItemNotValidCount
                itemVCount = itemHeader.ItemValidCount

                isPack = NovaLibra.Coral.Data.Michaels.ItemDetail.IsPack(itemHeader.ID)

                ' SETUP DEFAULT SORT
                If Not IsPostBack AndAlso ItemGrid.CurrentAdvancedSort = String.Empty AndAlso ItemGrid.CurrentSortColumn = 1 Then ' Session.Item("CurrSortCol") Is Nothing Then
                    If isPack Then
                        Me.SetDefaultPackSort()
                    End If
                End If
            Else
                Response.Redirect("default.aspx")
            End If ' Not itemHeader Is Nothing



            ' **********
            ' * detail *
            ' **********

            Dim gridItemList As Models.ItemList = Nothing
            Dim valRecords As ArrayList = Nothing
            Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
            Dim WorkflowStageID As Integer = 0

            If batchDetail.ID > 0 Then
                WorkflowStageID = batchDetail.WorkflowStageID
                hdnWorkflowStageID.Value = batchDetail.WorkflowStageID
            End If

            itemFL = objMichaels.GetItemFieldLocking(AppHelper.GetUserID(), AppHelper.GetVendorID, WorkflowStageID)

            ' *********************************************
            ' * CHECK FOR RECORDS WITH VALIDATION UNKNOWN *
            ' *********************************************
            Dim valUnknownCount As Integer = objMichaels.GetItemValidationUnknownCount(itemHeaderID)
            If valUnknownCount > 0 Then
                gridItemList = objMichaels.GetList(itemHeaderID, 0, 0, String.Empty, userID)
                ' get validation counts for current paged set >> changed to entire list
                valRecords = ValidationHelper.ValidateItemList(gridItemList.ListRecords, itemHeader)
                ' save validation (if user can edit)
                If UserCanEdit Then
                    itemUCount = 0
                    itemNVCount = 0
                    itemVCount = 0
                    For Each vr1 As Models.ValidationRecord In valRecords
                        If vr1.IsValid Then
                            itemVCount += 1
                        Else
                            itemNVCount += 1
                        End If
                    Next
                    NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecords, userID)
                End If
                ' clean up
                Do While valRecords.Count > 0
                    valRecords.RemoveAt(0)
                Loop
                valRecords = Nothing
                gridItemList = Nothing
            End If
            ' *********************************************
            ' * END CHECK *
            ' *********************************************


            ' column xml
            _userColumns = New XmlDocument()
            _userColumnsXML = UserEnabledColumns
            If _userColumnsXML = "" Then
                _userColumnsXML = DBRecords.LoadUserEnabledColumns(Session("UserID"), ItemGrid.GridID)
                UserEnabledColumns = _userColumnsXML
            End If
            _userColumns.LoadXml(_userColumnsXML)

            ' setup grid
            Dim objGridItem As GridItem
            Dim sql As String

            ItemGrid.HighlightRow = True
            ItemGrid.ShowSearch = True
            ItemGrid.AutoResizeGrid = True
            ItemGrid.ShowAdvancedSort = True
            ItemGrid.ShowAdvancedFilter = True
            ItemGrid.ItemAddURL = "detailform.aspx?hid=" & itemHeader.ID
            ItemGrid.ItemAddText = "Add New Item"
            ItemGrid.ItemEditURL = "detailform.aspx?hid=" & itemHeader.ID
            ItemGrid.ItemDeleteURL = "detaildelete.aspx?t=i&hid=" & itemHeader.ID
            ItemViewURL = "detailform.aspx?hid=" & itemHeader.ID
            If isPack Then
                ItemGrid.ItemCustomURL = "IMAddRecords.aspx?btype=NI&bid=" & batchDetail.ID.ToString()
                ItemGrid.ItemCustomText = "Add Existing Item(s)"
            End If
            ItemGrid.ShowContentMenu = True
            ItemGrid.AllowAjaxEdit = True
            ItemGrid.DefaultPageSize = 15
            ItemGrid.FieldNameUnderscore = True
            ItemGrid.PagingCookie = True
            ItemGrid.AllowSetAll = True

            ' check session "edit" variable
            If Not UserCanEdit Then
                ItemGrid.ItemViewURL = ItemGrid.ItemEditURL
                ItemGrid.ItemAddURL = ""
                ItemGrid.ItemEditURL = ""
                ItemGrid.ItemDeleteURL = ""
                ItemGrid.AllowAjaxEdit = False
                ItemGrid.ItemCustomURL = String.Empty
                ItemGrid.ItemCustomText = String.Empty
            End If

            ItemGrid.ImagePath = "images/grid/"

            ' SPECIAL ITEMS
            Dim theBatchID As String
            Dim dateNow As Date = Now()
            Dim fileName As String
            If UserCanEdit Then
                ' TaxWizard
                ItemGrid.AddSpecialValue("TaxWizard", String.Empty, "openTaxWizardSA('" & itemHeader.ID & "', '');", "{{HEADER_LINK}}")
                ItemGrid.AddSpecialValue("TaxWizard", True, "<a href=""#"" onclick=""openTaxWizard('{{ID}}'); return false;""><img id=""taxwiz{{ID}}"" src=""images/checkbox_true.gif"" border=""0"" alt="""" /></a>")
                ItemGrid.AddSpecialValue("TaxWizard", False, "<a href=""#"" onclick=""openTaxWizard('{{ID}}'); return false;""><img id=""taxwiz{{ID}}"" src=""images/checkbox_false.gif"" border=""0"" alt="""" /></a>")
                ' AdditionalUPCCount
                ItemGrid.AddSpecialValue("AdditionalUPCCount", String.Empty, _
                    "0 &nbsp;-&nbsp; " & _
                    "<a href=""#"" onclick=""openItemEditorWindow({{ID}});"">Edit</a>", _
                    "<0")
                ItemGrid.AddSpecialValue("AdditionalUPCCount", String.Empty, _
                    "{{VALUE}} &nbsp;-&nbsp; " & _
                    "<a href=""#"" onclick=""openItemEditorWindow({{ID}});"">Edit</a>", _
                    ">=0")
                ' ImageID
                ItemGrid.AddSpecialValue("ImageID", String.Empty, _
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value=""{{VALUE}}"" />" & _
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small_on.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "<input type=""button"" id=""B_UpdateImage{{ID}}"" value=""Update"" class=""formButton"" onclick=""openUploadItemFile('D', '{{ID}}', 'IMG', '1');"" />" & _
                    "<input type=""button"" id=""B_DeleteImage{{ID}}"" value=""Delete"" class=""formButton"" onclick=""return deleteImage({{ID}});"" />" & _
                    "&nbsp;", _
                    ">0")
                ItemGrid.AddSpecialValue("ImageID", String.Empty, _
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value="""" />" & _
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "<input type=""button"" id=""B_UpdateImage{{ID}}"" value=""Upload"" class=""formButton"" onclick=""openUploadItemFile('D', '{{ID}}', 'IMG', '1');"" />" & _
                    "<input type=""button"" id=""B_DeleteImage{{ID}}"" value=""Delete"" class=""formButton"" disabled=""disabled"" onclick=""return deleteImage({{ID}});"" />" & _
                    "&nbsp;", _
                    "<=0")
                ' MSDSID
                If Not itemHeader Is Nothing Then
                    theBatchID = "_" & itemHeader.BatchID.ToString()
                Else
                    theBatchID = String.Empty
                End If
                fileName = "item_" & theBatchID & "_" & dateNow.ToString("yyyyMMdd") & ".pdf"
                ItemGrid.AddSpecialValue("MSDSID", String.Empty, _
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value=""{{VALUE}}"" />" & _
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "<input type=""button"" id=""B_UpdateMSDS{{ID}}"" value=""Update"" class=""formButton"" onclick=""openUploadItemFile('D', '{{ID}}', 'MSDS', '1');"" />" & _
                    "<input type=""button"" id=""B_DeleteMSDS{{ID}}"" value=""Delete"" class=""formButton"" onclick=""return deleteMSDS({{ID}});"" />" & _
                    "&nbsp;", _
                    ">0")
                ItemGrid.AddSpecialValue("MSDSID", String.Empty, _
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value="""" />" & _
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small_off.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "<input type=""button"" id=""B_UpdateMSDS{{ID}}"" value=""Upload"" class=""formButton"" onclick=""openUploadItemFile('D', '{{ID}}', 'MSDS', '1');"" />" & _
                    "<input type=""button"" id=""B_DeleteMSDS{{ID}}"" value=""Delete"" class=""formButton"" disabled=""disabled"" onclick=""return deleteMSDS({{ID}});"" />" & _
                    "&nbsp;", _
                    "<=0")
            Else
                ' ****************
                ' *** READONLY ***
                ' ****************
                ' TaxWizard
                'ItemGrid.AddSpecialValue("TaxWizard", String.Empty, "openTaxWizardSA('" & itemHeader.ID & "', '');", "{{HEADER_LINK}}")
                ItemGrid.AddSpecialValue("TaxWizard", True, "<img id=""taxwiz{{ID}}"" src=""images/checkbox_true.gif"" border=""0"" alt="""" />")
                ItemGrid.AddSpecialValue("TaxWizard", False, "<img id=""taxwiz{{ID}}"" src=""images/checkbox_false.gif"" border=""0"" alt="""" />")
                ' AdditionalUPCCount
                ItemGrid.AddSpecialValue("AdditionalUPCCount", String.Empty, _
                    "0 &nbsp;-&nbsp; " & _
                    "<a href=""#"" onclick=""openItemViewerWindow({{ID}});"">View</a>", _
                    "<0")
                ItemGrid.AddSpecialValue("AdditionalUPCCount", String.Empty, _
                    "{{VALUE}} &nbsp;-&nbsp; " & _
                    "<a href=""#"" onclick=""openItemViewerWindow({{ID}});"">View</a>", _
                    ">=0")
                ' ImageID
                ItemGrid.AddSpecialValue("ImageID", String.Empty, _
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value=""{{VALUE}}"" />" & _
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small_on.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "", _
                    ">0")
                ItemGrid.AddSpecialValue("ImageID", String.Empty, _
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value="""" />" & _
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "", _
                    "<=0")
                ' MSDSID
                If Not itemHeader Is Nothing Then
                    theBatchID = "_" & itemHeader.BatchID.ToString()
                Else
                    theBatchID = String.Empty
                End If
                fileName = "item_" & theBatchID & "_" & dateNow.ToString("yyyyMMdd") & ".pdf"
                ItemGrid.AddSpecialValue("MSDSID", String.Empty, _
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value=""{{VALUE}}"" />" & _
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "", _
                    ">0")
                ItemGrid.AddSpecialValue("MSDSID", String.Empty, _
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value="""" />" & _
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small_off.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                    "", _
                    "<=0")
            End If


            ' SETUP COLUMNS
            ' *********************************
            Dim reader As DBReader = Nothing
            sql = "select ID" & _
                ", isnull(Column_Name, '') as Column_Name" & _
                ", Column_Ordinal" & _
                ", Column_Generic_Type" & _
                ", isnull(Column_Format, 'string') as Column_Format" & _
                ", isnull(Column_Format_String, '') as Column_Format_String" & _
                ", Fixed_Column" & _
                ", Allow_Sort" & _
                ", Allow_Filter" & _
                ", Allow_AjaxEdit" & _
                ", Default_UserDisplay" & _
                ", Display_Name " & _
                ", Max_Length " & _
                " from ColumnDisplayName" & _
                " where [Display] = 1 and isnull(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & _
                " ORDER BY Column_Ordinal, [ID]"
            Try
                reader = New DBReader(ApplicationHelper.GetAppConnection())
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                Do While reader.Read()
                    If ColumnEnabledByUser(reader("ID"), DataHelper.SmartValues(reader("Default_UserDisplay"), "Boolean")) Then
                        objGridItem = ItemGrid.AddGridItem(reader("Column_Ordinal"), reader("Display_Name"), reader("Column_Name").ToString().Replace("_", ""), reader("Column_Generic_Type"), reader("Column_Format"))
                        If reader("Column_Format_String") = "STOCKSTRAT" Then
                            If itemHeader.BatchStageType = NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStageType.Completed Then
                                objGridItem.FieldFormatString = "STOCKSTRATALL"
                            ElseIf itemHeader.ItemTypeAttribute = "S" Then
                                objGridItem.FieldFormatString = "STOCKSTRATSEASONAL" 'reader("Column_Format_String")
                            ElseIf itemHeader.ItemTypeAttribute <> "S" And itemHeader.ItemTypeAttribute <> "" Then
                                objGridItem.FieldFormatString = "STOCKSTRATBASIC"
                            Else
                                objGridItem.FieldFormatString = reader("Column_Format_String")
                            End If
                        Else
                            objGridItem.FieldFormatString = reader("Column_Format_String")
                        End If
                        'SPECIAL CASE FOR STOCKING STRATEGY

                        objGridItem.FixedColumn = DataHelper.SmartValues(reader("Fixed_Column"), "Boolean")
                        objGridItem.SortColumn = DataHelper.SmartValues(reader("Allow_Sort"), "Boolean")
                        objGridItem.FilterColumn = DataHelper.SmartValues(reader("Allow_Filter"), "Boolean")
                        objGridItem.AllowAjaxEdit = DataHelper.SmartValues(reader("Allow_AjaxEdit"), "Boolean")
                        objGridItem.MaxLength = DataHelper.SmartValues(reader("Max_Length"), "integer", False)
                    End If
                Loop
            Catch sqlex As SqlException
                'Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                'Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Close()
                    reader.Dispose()
                End If
            End Try


            Dim twgi As GridItem
            twgi = ItemGrid.GetGridItem("BaseRetail")
            If Not twgi Is Nothing Then
                twgi.SkipColumnOnEdit = "AlaskaRetail"
            End If
            twgi = ItemGrid.GetGridItem("TaxWizard")
            If Not twgi Is Nothing Then
                twgi.ColumnAlign = "center"
                twgi.ColumnVAlign = "middle"
            End If
            twgi = ItemGrid.GetGridItem("ImageID")
            If Not twgi Is Nothing Then
                twgi.ColumnAlign = "center"
                twgi.ColumnVAlign = "middle"
            End If
            twgi = ItemGrid.GetGridItem("MSDSID")
            If Not twgi Is Nothing Then
                twgi.ColumnAlign = "center"
                twgi.ColumnVAlign = "middle"
            End If
            'NAK 12/4/2012:  Per Michaels, these fields should be editable to DBC/QA
            If itemHeader.BatchStageType <> Models.WorkflowStageType.Tax And itemHeader.BatchStageType <> Models.WorkflowStageType.DBC Then
                twgi = ItemGrid.GetGridItem("TaxUDA")
                If Not twgi Is Nothing Then twgi.AllowAjaxEdit = False
                twgi = ItemGrid.GetGridItem("TaxValueUDA")
                If Not twgi Is Nothing Then twgi.AllowAjaxEdit = False
            End If
            'lp Spedy order 12- i have no choice but to hard code columns here, need to recalc all the formulas based on StoreTotal here and save record?
            twgi = ItemGrid.GetGridItem("LikeItemUnitStoreMonth")
            If Not twgi Is Nothing Then
                If itemHeader.CalculateOptions = 2 Then
                    twgi.AllowAjaxEdit = True
                Else
                    twgi.AllowAjaxEdit = False
                End If
            End If
            twgi = ItemGrid.GetGridItem("AnnualRegularUnitForecast")
            If Not twgi Is Nothing Then
                If itemHeader.CalculateOptions = 1 Then
                    twgi.AllowAjaxEdit = True
                Else
                    twgi.AllowAjaxEdit = False
                End If
            End If
            twgi = Nothing
            If Not isPack Then
                ItemGrid.RemoveGridItem("QtyInPack")
            End If

            twgi = ItemGrid.GetGridItem("StockingStrategyCode")
            If Not twgi Is Nothing Then
                If objMichaels.DisableStockingStratBasedOnStockCat(itemHeader.StockCategory, itemHeader.CanadaStockCategory) Then
                    twgi.AllowAjaxEdit = False
                End If
            End If
            twgi = Nothing


            ' ******************************
            ' get data
            ' ******************************
            ' set the record count (which causes the SetupPaging to fire and thus setup the grid)
            Dim strXML As String = GetGridSortAndFilterXML()
            ItemGrid.RecordCount = objMichaels.GetListCount(itemHeaderID, strXML, userID)

            ' get data
            Dim firstRow As Integer = DataHelper.SmartValues(ItemGrid.CurrentPage, "integer", False)
            If firstRow <= 0 Then firstRow = 1
            Dim pageSize As Integer = ItemGrid.CurrentPageSize

            ' get list
            gridItemList = objMichaels.GetList(itemHeaderID, firstRow, pageSize, strXML, userID)
            ' get custom fields
            Me.CustomFields = NovaLibra.Coral.BusinessFacade.SystemCustomFields.GetCustomFields(Me.RecordType, gridItemList.GetRecordIDs, True)
            ' ******************************
            ' end get data
            ' ******************************
            ' *********************************
            ' Setup custom field columns
            ' *********************************
            ItemGrid.CustomFields = Me.CustomFields
            Dim nextID As Integer = ItemGrid.ItemCollection.GetNextGridItemID()
            Me.CustomFieldStartID = nextID
            Dim fieldIDs As String = String.Empty
            For Each field As NovaLibra.Coral.SystemFrameworks.CustomField In Me.CustomFields.Fields
                ' add custom field to grid
                objGridItem = ItemGrid.AddGridItem(nextID, field.FieldName, field.ID.ToString(), field.GetGenericType(), field.GetFormat())
                objGridItem.FieldFormatString = "{{CUSTOM}}"
                objGridItem.FixedColumn = False
                objGridItem.SortColumn = False
                objGridItem.FilterColumn = False
                objGridItem.AllowAjaxEdit = True
                objGridItem.MaxLength = DataHelper.SmartValues(field.FieldLimit, "integer", False)
                ' associated custom field id with the grid id
                If fieldIDs <> String.Empty Then fieldIDs = fieldIDs & ","
                fieldIDs = fieldIDs & nextID.ToString() & "," & field.ID.ToString()
                ' increment the next id
                nextID += 1
            Next
            ' save the field references
            Me.CustomFieldRef = fieldIDs
            ' *********************************
            ' *********************************
            ' excel export
            ' *********************************
            If itemHeaderID > 0 Then
                linkExcel.Visible = True
                'linkExcel.Attributes.Add("onclick", "showExcel(); return false;")
                'lp change here- pas sorting xml to detailexport
                linkExcel.NavigateUrl = "detailexport.aspx?hid=" & GetItemHeaderID() & "&sort=" & Server.UrlEncode(GetGridSortAndFilterXML())
                'linkExcel.NavigateUrl = "detailexport.aspx?hid=" & GetItemHeaderID() & "&sort="
                sep1.Visible = True
            Else
                linkExcel.Visible = False
                sep1.Visible = False
            End If
            ' *********************************
            ' *********************************


            ' *********************************
            ' *********************************

            ' GRID CELL LOCKING
            For Each itemRow As Models.ItemRecord In gridItemList.ListRecords
                If itemRow.ValidExistingSKU Then
                    ' lock
                    For Each gi As GridItem In ItemGrid.GridItems
                        If gi.FieldName <> "QtyInPack" AndAlso gi.FieldName <> "Qty_In_Pack" Then
                            ItemGrid.LockCell(itemRow.ID, gi.ID)
                        End If
                        If gi.FieldName = "ImageID" Then
                            ItemGrid.AddScripts("lockImageCell(" & itemRow.ID & ", " & gi.ID & ");")
                        End If
                        If gi.FieldName = "MSDSID" Then
                            ItemGrid.AddScripts("lockMSDSCell(" & itemRow.ID & ", " & gi.ID & ");")
                        End If
                    Next
                    ItemGrid.AddScripts("" & vbCrLf)
                End If
            Next

            ' *********************************
            ' *********************************



            'FJL
            ' ******************************
            ' field locking
            ' ******************************
            For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns

                Select Case UCase(col.Permission)
                    Case "V"        ' View Column only

                        Select Case col.ColumnName
                            Case "Additional_UPC"
                                ' AdditionalUPCCount
                                ItemGrid.ClearSpecialValue("AdditionalUPCCount")
                                ItemGrid.AddSpecialValue("AdditionalUPCCount", String.Empty, _
                                    "0", _
                                    "<0")
                                ItemGrid.AddSpecialValue("AdditionalUPCCount", String.Empty, _
                                    "{{VALUE}}", _
                                    ">=0")

                            Case "Country_Of_Origin"
                                twgi = ItemGrid.GetGridItem("CountryOfOriginName")
                                If Not twgi Is Nothing Then
                                    twgi.AllowAjaxEdit = False
                                End If

                            Case "Tax_Wizard"
                                ' TaxWizard
                                ItemGrid.ClearSpecialValue("TaxWizard")
                                ItemGrid.AddSpecialValue("TaxWizard", True, "<a href=""#"" onclick=""return false;""><img id=""taxwiz{{ID}}"" src=""images/checkbox_true_disabled.gif"" border=""0"" alt="""" /></a>")
                                ItemGrid.AddSpecialValue("TaxWizard", False, "<a href=""#"" onclick=""return false;""><img id=""taxwiz{{ID}}"" src=""images/checkbox_false_disabled.gif"" border=""0"" alt="""" /></a>")
                                ' todo: finish this

                            Case "MSDS_ID"
                                ' MSDSID
                                ItemGrid.ClearSpecialValue("MSDSID")
                                If Not itemHeader Is Nothing Then
                                    theBatchID = "_" & itemHeader.BatchID.ToString()
                                Else
                                    theBatchID = String.Empty
                                End If
                                fileName = "item_" & theBatchID & "_" & dateNow.ToString("yyyyMMdd") & ".pdf"
                                ItemGrid.AddSpecialValue("MSDSID", String.Empty, _
                                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value=""{{VALUE}}"" />" & _
                                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                                    "&nbsp;", _
                                    ">0")
                                ItemGrid.AddSpecialValue("MSDSID", String.Empty, _
                                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value="""" />" & _
                                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small_off.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                                    "&nbsp;", _
                                    "<=0")

                            Case "Image_ID"
                                ' ImageID
                                ItemGrid.ClearSpecialValue("ImageID")
                                ItemGrid.AddSpecialValue("ImageID", String.Empty, _
                                    "<input type=""hidden"" id=""ImageID{{ID}}"" value=""{{VALUE}}"" />" & _
                                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small_on.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                                    "&nbsp;", _
                                    ">0")
                                ItemGrid.AddSpecialValue("ImageID", String.Empty, _
                                    "<input type=""hidden"" id=""ImageID{{ID}}"" value="""" />" & _
                                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" & _
                                    "&nbsp;", _
                                    "<=0")

                            Case "Annual_Regular_Unit_Forecast"
                                twgi = ItemGrid.GetGridItem("AnnualRegularUnitForecast")
                                If itemHeader.CalculateOptions = 1 Then
                                    twgi.AllowAjaxEdit = True
                                Else
                                    twgi.AllowAjaxEdit = False
                                End If

                            Case "Annual_Reg_Retail_Sales"
                                twgi = ItemGrid.GetGridItem("AnnualRegRetailSales")
                                If Not twgi Is Nothing Then
                                    twgi.AllowAjaxEdit = False
                                End If

                            Case "Like_Item_Unit_Store_Month"
                                twgi = ItemGrid.GetGridItem("LikeItemUnitStoreMonth")
                                If itemHeader.CalculateOptions = 2 Then
                                    twgi.AllowAjaxEdit = True
                                Else
                                    twgi.AllowAjaxEdit = False
                                End If

                            Case Else   ' Find Grid item by column name w/o special handling
                                twgi = ItemGrid.GetGridItem(col.ColumnName.Replace("_", ""))
                                If Not twgi Is Nothing Then
                                    twgi.AllowAjaxEdit = False
                                End If
                        End Select

                    Case "N"    ' Hide the column by removing the grid item from the collection
                        Select Case col.ColumnName
                            Case "Additional_UPC"
                                ItemGrid.RemoveGridItem("AdditionalUPCCount")
                            Case "Country_Of_Origin"
                                ItemGrid.RemoveGridItem("CountryOfOriginName")
                            Case "MSDS_ID"
                                ItemGrid.RemoveGridItem("MSDSID")
                            Case "Image_ID"
                                ItemGrid.RemoveGridItem("ImageID")
                            Case "Annual_Regular_Unit_Forecast"
                                ItemGrid.RemoveGridItem("AnnualRegularUnitForecast")
                            Case "Annual_Reg_Retail_Sales"
                                ItemGrid.RemoveGridItem("AnnualRegRetailSales")
                            Case "Like_Item_Unit_Store_Month"
                                ItemGrid.RemoveGridItem("LikeItemUnitStoreMonth")

                            Case Else   ' Remove the item from the Grid so it won't be rendered
                                ItemGrid.RemoveGridItem(col.ColumnName.Replace("_", ""))
                        End Select ' Col
                    Case Else   ' Edit permission

                End Select      ' Permission

            Next
            ' ******************************
            ' end field locking
            ' ******************************


            ' get validation counts for current paged set
            For Each item As Models.ItemRecord In gridItemList.ListRecords
                item.BatchStageID = itemHeader.BatchStageID
                Select Case item.IsValid
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Unknown
                        iucnt1 += 1
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid
                        invcnt1 += 1
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid
                        ivcnt1 += 1
                End Select
            Next

            ItemGrid.DataSource = gridItemList.ListRecords
            ItemGrid.DataBind()



            ' --------------------------------------------------------------------------
            ' validation
            ' --------------------------------------------------------------------------

            valRecords = ValidationHelper.ValidateItemList(gridItemList.ListRecords, itemHeader)

            ' get validation counts for current set (validated)
            For Each vr As Models.ValidationRecord In valRecords
                If vr.IsValid Then
                    ivcnt2 += 1
                Else
                    invcnt2 += 1
                End If
            Next

            ' save validation (if user can edit)
            If UserCanEdit Then
                NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecords, userID)
            End If


            ' update validation counts
            itemUCount = (itemUCount - iucnt1 + iucnt2)
            itemNVCount = (itemNVCount - invcnt1 + invcnt2)
            itemVCount = (itemVCount - ivcnt1 + ivcnt2)

            ' display validation
            Dim bHasBatchErrors As Boolean = False
            Dim bHasBatchWarnings As Boolean = False
            Dim bHasErrors As Boolean = False
            Dim bHasWarnings As Boolean = False
            For i As Integer = 0 To valRecords.Count - 1
                If Not bHasErrors AndAlso Not CType(valRecords(i), Models.ValidationRecord).IsValid Then
                    bHasErrors = True
                End If
                If Not bHasWarnings AndAlso CType(valRecords(i), Models.ValidationRecord).ErrorExists(ValidationRuleSeverityType.TypeWarning) Then
                    bHasWarnings = True
                End If
                If (bHasErrors AndAlso bHasWarnings) Then Exit For
            Next

            ' show validation errors in the grid
            Dim vrBatch As Models.ValidationRecord
            Dim vrec As Models.ValidationRecord

            If ValidationHelper.SkipBatchValidation(itemHeader.BatchStageType) Then
                vrBatch = New Models.ValidationRecord(itemHeader.BatchID, Models.ItemRecordType.Batch)
            Else
                vrBatch = ValidationHelper.ValidateBatch(itemHeader.BatchID, NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic)
                bHasBatchErrors = vrBatch.ErrorExists()
                bHasBatchWarnings = vrBatch.ErrorExists(ValidationRuleSeverityType.TypeWarning)
            End If

            If ValidationHelper.SkipValidation(itemHeader.BatchStageType) Then
                vrec = New Models.ValidationRecord(itemHeader.ID, Models.ItemRecordType.ItemHeader)
            Else
                vrec = ValidationHelper.ValidateData(itemHeader)
            End If

            ' save validation (if user can edit)
            If UserCanEdit Then
                NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrec, userID)
                NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
            End If

            If vrBatch.IsValid AndAlso vrec.IsValid Then
                itemHeaderImage.Src = ValidationHelper.GetValidationImageString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid, True)
            Else
                itemHeaderImage.Src = ValidationHelper.GetValidationImageString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid, True)
            End If
            If bHasBatchErrors Or bHasBatchWarnings Or bHasErrors Or bHasWarnings Then
                ValidationHelper.SetupValidationSummary(validationDisplay)
                If vrBatch.HasAnyError() Then
                    ValidationHelper.AddValidationSummaryErrors(validationDisplay, vrBatch)
                End If
                If bHasWarnings Then ValidationHelper.LoadValidationSummary(validationDisplay, "There are validation warnings in the item list.")
                If bHasErrors Then ValidationHelper.LoadValidationSummary(validationDisplay, "There are validation errors in the item list.")
            End If

            If bHasBatchErrors OrElse itemNVCount > 0 OrElse ((Not itemHeader Is Nothing) AndAlso itemHeader.ItemCount <= 0) Then
                itemDetailImage.Src = ValidationHelper.GetValidationImageString(Models.ItemValidFlag.NotValid, True)
            ElseIf itemUCount > 0 Then
                itemDetailImage.Src = ValidationHelper.GetValidationImageString(Models.ItemValidFlag.Unknown, True)
            Else
                itemDetailImage.Src = ValidationHelper.GetValidationImageString(Models.ItemValidFlag.Valid, True)
            End If
            If (Not itemHeader Is Nothing) AndAlso itemHeader.ItemCount <= 0 Then
                If Not vrBatch.HasAnyError() And Not bHasErrors And Not bHasWarnings Then
                    ValidationHelper.LoadValidationSummary(validationDisplay, ValidationErrorHelper.VAL_ERROR_NO_ITEMS)
                Else
                    validationDisplay.AddMessage(ValidationErrorHelper.VAL_ERROR_NO_ITEMS)
                End If
            End If
            CheckForStartupScripts(valRecords)

            ' clean up
            vrBatch = Nothing
            vrec = Nothing
            Do While valRecords.Count > 0
                valRecords.RemoveAt(0)
            Loop
            valRecords = Nothing


            ' ********************
            ' ***** SETTINGS *****
            ' ********************

            'If Not IsPostBack Then

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
                SQLStr = "SELECT COUNT(*) AS RecordCount FROM ColumnDisplayName WHERE ISNULL(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & " AND  Display = 1 AND Is_Custom = 0 AND Allow_Filter = 1"
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
                SQLStr = "SELECT * FROM ColumnDisplayName WHERE ISNULL(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & " AND Display = 1 AND Is_Custom = 0 AND Allow_Filter = 1 ORDER BY Column_Ordinal, [ID]"
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
            objMichaels = Nothing
            itemFL = Nothing
            'End If

            ' ************************
            ' ***** END SETTINGS *****
            ' ************************


            ' Init Validation Display
            InitValidation(Me.validationDisplay.ID)

        Else ' callback
            ' CALLBACK
            If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) Then
                Response.Clear()
                Response.End()
            End If
        End If
        'Response.Write("<!-- TIME: Load Complete - " & Now().ToString() & "-->")
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        'Response.Write("<!-- TIME: PreRender - " & Now().ToString() & "-->")
    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        If Not _objData Is Nothing Then
            _objData = Nothing
        End If
        _userColumns = Nothing
    End Sub

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
                ' validate entire list
                Return CallbackValidateGrid()
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
                Dim bRet As Boolean = objFile.DeleteRecord(Models.ItemTypeString.ITEM_TYPE_DOMESTIC, thisItemID, fileID)
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
                    Return str(0) & CALLBACK_SEP & "1" & CALLBACK_SEP & thisItemID & CALLBACK_SEP & fileID & GetItemValidation(thisItemID, userID)
                Else
                    Return str(0) & CALLBACK_SEP & "0"
                End If
            Case "UPDATEIMAGE", "UPDATEMSDS"
                If str.Length < 3 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Dim thisItemID As Long = DataHelper.SmartValues(str(1), "long", True)
                Dim fileID As Long = DataHelper.SmartValues(str(2), "long", True)
                If thisItemID = Long.MinValue Or thisItemID < 0 Or fileID = Long.MinValue Or fileID < 0 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Return str(0) & CALLBACK_SEP & "1" & CALLBACK_SEP & thisItemID & CALLBACK_SEP & fileID & GetItemValidation(thisItemID, userID)
        End Select
        Return ""
    End Function

    Public Sub RaiseCallbackEvent(ByVal eventArgument As String) Implements System.Web.UI.ICallbackEventHandler.RaiseCallbackEvent
        _callbackArg = eventArgument
    End Sub

    Public Function GetItemValidation(ByVal itemID As Long, ByVal userID As Long) As String
        Dim retValue As String = String.Empty

        Dim colReader As DBReader = Nothing
        Dim conn As DBConnection = Nothing
        Try
            conn = ApplicationHelper.GetAppConnection()

            ' validation
            Dim colSQL As String = "select ID" & _
                ", isnull(Column_Name, '') as Column_Name" & _
                ", Column_Ordinal" & _
                ", Default_UserDisplay" & _
                " from ColumnDisplayName" & _
                " where [Display] = 1 and isnull(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & _
                " order by Column_Ordinal"
            colReader = New DBReader(conn, colSQL, CommandType.Text)
            colReader.Open()
            'Dim objGridItem As GridItem
            Dim giarr As New ArrayList()
            Do While colReader.Read()
                'If ColumnEnabledByUser(colReader("ID"), DataHelper.SmartValues(colReader("Default_UserDisplay"), "Boolean")) Then
                giarr.Add(New GridItem(colReader("Column_Ordinal"), String.Empty, colReader("Column_Name").ToString().Replace("_", String.Empty), String.Empty))
                'End If
            Loop
            colReader.Dispose()
            colReader = Nothing
            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
            Dim item As Models.ItemRecord = objMichaels.GetRecord(itemID)
            Dim itemHeader As Models.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(item.ItemHeaderID)
            Dim sbFields As New StringBuilder("")
            Dim id As Long
            objMichaels = Nothing
            Dim vr As Models.ValidationRecord


            If ValidationHelper.SkipValidation(itemHeader.BatchStageType) Then
                vr = New Models.ValidationRecord(item.ID, Models.ItemRecordType.Item)
            Else
                vr = ValidationHelper.ValidateItem(item, itemHeader)
            End If



            ' save validation (if user can edit)
            'If UserCanEdit Then
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vr, userID)
            'End If
            If Not vr.IsValid Then
                For Each ve As Models.ValidationError In vr.ValidationErrors
                    id = GetColIDFromGridItemArray(giarr, ve.Field.Replace("_", ""))
                    If id > 0 Then
                        If sbFields.ToString() <> "" Then
                            sbFields.Append(",")
                        End If
                        sbFields.Append("'gc_" & vr.RecordID & "_" & id & "'")
                    End If
                Next
            End If
            retValue = CALLBACK_SEP & sbFields.ToString() & CALLBACK_SEP & CType(IIf(vr.IsValid, "displayValid", "displayNotValid"), String)
            Do While giarr.Count > 0
                giarr.RemoveAt(0)
            Loop
            giarr = Nothing

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
        Return retValue
    End Function

    Public Function CallbackSaveAjaxEdit(ByVal columnID As String, ByVal columnName As String, ByVal rowID As String, ByVal dataText As String) As String
        Dim retValue As String = String.Empty
        Dim retValue2 As String = CALLBACK_SEP & " " & CALLBACK_SEP & " " & CALLBACK_SEP & " "
        Dim retValue3 As String = CALLBACK_SEP & " " & CALLBACK_SEP & " " & CALLBACK_SEP & " " & CALLBACK_SEP & " " & CALLBACK_SEP & " "
        Dim retvalue4 As String = CALLBACK_SEP & " "
        Dim SQLStr As String = String.Empty
        Dim decValue As Decimal
        Dim strValue As String
        Dim reader As DBReader = Nothing
        Dim cmd As DBCommand = Nothing
        Dim conn As DBConnection = Nothing
        Dim colReader As DBReader = Nothing
        Dim itemID As Long = DataHelper.SmartValues(rowID, "long")
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

        Dim itemDetail As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim item As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord = itemDetail.GetRecord(itemID)
        Dim audit As New Models.AuditRecord(Models.MetadataTable.Items, itemID, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)
        Dim packInfo As Models.ItemPackInfo = NovaLibra.Coral.Data.Michaels.ItemDetail.GetPackInfo(itemID)

        Dim colID As Integer = DataHelper.SmartValues(columnID, "integer", False)
        Dim startID As Integer = Me.CustomFieldStartID
        Dim isCustomField As Boolean = False
        If colID >= startID AndAlso startID > 0 Then isCustomField = True

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
                Dim colName As String
                SQLStr = "select Column_Name, Column_Generic_Type from ColumnDisplayName where Workflow_ID = " & ItemGrid.GridID & " and Column_Ordinal = @colID"
                conn = ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                cmd.Parameters.Add("@colID", SqlDbType.Int).Value = DataHelper.SmartValues(columnID, "Integer")
                reader = New DBReader(cmd)
                reader.Open()
                If Not reader Is Nothing AndAlso reader.HasRows AndAlso reader.Read() Then
                    colName = reader("Column_Name")
                    'LP
                    If colName = "Calculated_Units_Store_Month" Then colName = "Like_Item_Unit_Store_Month"
                    If colName = "Calculated_Yearly_Forecast" Then colName = "Annual_Regular_Unit_Forecast"

                    'The NovaGrid is dumb.  It does not support a multi-table data schema.  So, need to specifically save values multilingual fields here.
                    SQLStr = ""
                    Select Case colName
                        Case "PLIEnglish"
                            item.PLIEnglish = dataText
                            'If String.IsNullOrEmpty(item.TIEnglish) Then
                            '    item.TIEnglish = dataText
                            'End If
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 1, item.PLIEnglish, item.TIEnglish, item.EnglishShortDescription, Left(item.EnglishLongDescription, 100), userID)
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(itemID, 1)
                            retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & dataText
                        Case "PLIFrench"
                            item.PLIFrench = dataText
                            'If String.IsNullOrEmpty(item.TIFrench) Then
                            ' item.TIFrench = dataText
                            'End If
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 2, item.PLIFrench, item.TIFrench, item.FrenchShortDescription, item.FrenchLongDescription, userID)
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(itemID, 2)
                            retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & dataText
                        Case "PLISpanish"
                            item.PLISpanish = dataText
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 3, item.PLISpanish, item.TISpanish, item.SpanishShortDescription, item.SpanishLongDescription, userID)
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(itemID, 3)
                            retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & dataText
                        Case "TIEnglish"
                            'If String.IsNullOrEmpty(dataText) Then
                            'dataText = item.PLIEnglish
                            'End If
                            item.TIEnglish = dataText
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 1, item.PLIEnglish, item.TIEnglish, item.EnglishShortDescription, Left(item.EnglishLongDescription, 100), userID)
                        Case "TIFrench"
                            'If String.IsNullOrEmpty(dataText) Then
                            'dataText = item.PLIFrench
                            'End If
                            item.TIFrench = dataText
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 2, item.PLIFrench, item.TIFrench, item.FrenchShortDescription, item.FrenchLongDescription, userID)
                        Case "TISpanish"
                            'Not currently supported
                        Case "EnglishShortDescription"
                            Dim englishDesc As String = dataText
                            If item.PackItemIndicator.StartsWith("DP") Then
                                englishDesc = "Display Pack"
                            ElseIf item.PackItemIndicator.StartsWith("SB") Then
                                englishDesc = "Sellable Bundle"
                            ElseIf item.PackItemIndicator.StartsWith("D") Then
                                englishDesc = "Displayer"
                            End If
                            item.EnglishShortDescription = englishDesc

                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 1, item.PLIEnglish, item.TIEnglish, item.EnglishShortDescription, Left(item.EnglishLongDescription, 100), userID)
                            retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & item.EnglishShortDescription
                        Case "FrenchShortDescription"
                            item.FrenchShortDescription = dataText
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 2, item.PLIFrench, item.TIFrench, item.FrenchShortDescription, item.FrenchLongDescription, userID)
                        Case "SpanishShortDescription"
                            item.SpanishShortDescription = dataText
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 3, item.PLISpanish, item.TISpanish, item.SpanishShortDescription, item.SpanishLongDescription, userID)
                        Case "EnglishLongDescription"
                            Dim englishDesc As String = dataText
                            If item.PackItemIndicator.StartsWith("DP") Then
                                englishDesc = "Display Pack"
                            ElseIf item.PackItemIndicator.StartsWith("SB") Then
                                englishDesc = "Sellable Bundle"
                            ElseIf item.PackItemIndicator.StartsWith("D") Then
                                englishDesc = "Displayer"
                            End If
                            item.EnglishLongDescription = englishDesc

                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 1, item.PLIEnglish, item.TIEnglish, item.EnglishShortDescription, Left(item.EnglishLongDescription, 100), userID)
                            retValue2 = CALLBACK_SEP & colName & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & item.EnglishLongDescription
                        Case "FrenchLongDescription"
                            item.FrenchLongDescription = dataText
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 2, item.PLIFrench, item.TIFrench, item.FrenchShortDescription, item.FrenchLongDescription, userID)
                        Case "SpanishLongDescription"
                            item.SpanishShortDescription = dataText
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(rowID, 3, item.PLISpanish, item.TISpanish, item.SpanishShortDescription, item.SpanishLongDescription, userID)
                            'NAK 1/4/2013:  Placeholder code for if Michaels changes their minds about how to deal with Quebec/Puerto Rico value defaulting.
                            'Case "RDQuebec"
                            '    If String.IsNullOrEmpty(dataText) Then
                            '        dataText = item.CanadaRetail
                            '    End If
                            '    SQLStr = "update [dbo].[SPD_Items] set " & colName & " = @value where [ID] = @rowID; "
                            'Case "RDPuertoRico"
                            '    If String.IsNullOrEmpty(dataText) Then
                            '        dataText = item.BaseRetail
                            '    End If
                            '    SQLStr = "update [dbo].[SPD_Items] set " & colName & " = @value where [ID] = @rowID; "
                        Case Else
                            SQLStr = "update [dbo].[SPD_Items] set " & colName & " = @value where [ID] = @rowID; "
                    End Select

                    SQLStr = SQLStr & " exec [sp_SPD_Item_SetModified] @rowID, 'D', @userID "

                    cmd = New DBCommand(ApplicationHelper.GetAppConnection(), SQLStr, CommandType.Text)
                    cmd.Parameters.Clear()
                    cmd.CommandText = SQLStr
                    cmd.CommandType = CommandType.Text
                    cmd.Parameters.Add("@rowID", SqlDbType.BigInt).Value = itemID
                    cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                    Dim saveValue As Object
                    Dim strType As String = reader("Column_Generic_Type")

                    ' special field functions (before save)
                    If colName = "Vendor_UPC" Then
                        If IsNumeric(dataText) AndAlso DataHelper.SmartValues(dataText, "long", False) > 0 Then
                            dataText = dataText.Trim()
                            Do While dataText.Length < 14
                                dataText = "0" & dataText
                            Loop
                            retValue2 = CALLBACK_SEP & "VendorUPC" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Like_Item_Regular_Unit" Then
                        If IsNumeric(dataText) AndAlso DataHelper.SmartValues(dataText, "decimal", False) > 0 Then
                            dataText = dataText.Trim()
                            decValue = DataHelper.SmartValues(dataText, "decimal", False) '/ 100
                            dataText = DataHelper.SmartValues(decValue, "formatnumber", True, String.Empty, 0)
                            'retValue2 = CALLBACK_SEP & "LikeItemRegularUnit" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & DataHelper.SmartValues(dataText, "percent", False)
                            retValue2 = CALLBACK_SEP & "LikeItemRegularUnit" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        Else
                            dataText = String.Empty
                            retValue2 = CALLBACK_SEP & "LikeItemRegularUnit" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Vendor_Style_Num" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            retValue2 = CALLBACK_SEP & "VendorStyleNum" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Item_Desc" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            retValue2 = CALLBACK_SEP & "ItemDesc" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Each_Case_Height" Or colName = "Each_Case_Width" Or colName = "Each_Case_Length" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "Inner_Case_Height" Or colName = "Inner_Case_Width" Or colName = "Inner_Case_Length" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "Master_Case_Height" Or colName = "Master_Case_Width" Or colName = "Master_Case_Length" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "Each_Case_Weight" Or colName = "Inner_Case_Weight" Or colName = "Master_Case_Weight" Then
                        dataText = RoundDimesionsString(dataText.Trim(), 4)
                    End If
                    ' end special field functions (before save)

                    Select Case strType.ToLower()
                        Case "date", "datetime"
                            saveValue = DataHelper.SmartValues(dataText, "date", True)
                            cmd.Parameters.Add("@value", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(saveValue, "date", True)
                        Case "integer"
                            saveValue = DataHelper.SmartValues(dataText, "integer", True)
                            cmd.Parameters.Add("@value", SqlDbType.Int).Value = DataHelper.DBSmartValues(saveValue, "integer", True)
                        Case "long"
                            saveValue = DataHelper.SmartValues(dataText, "long", True)
                            cmd.Parameters.Add("@value", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(saveValue, "long", True)
                        Case "decimal", "single", "double", "number"
                            saveValue = DataHelper.SmartValues(dataText, "decimal", True)
                            cmd.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(saveValue, "decimal", True)
                        Case Else
                            saveValue = DataHelper.SmartValues(dataText, "string", True)
                            cmd.Parameters.Add("@value", SqlDbType.VarChar, 255).Value = DataHelper.DBSmartValues(saveValue, "string", True)
                    End Select
                    reader.Close()
                    reader.Dispose()
                    reader = Nothing

                    If Not (packInfo.IsPack And packInfo.IsPackParent And colName.Replace("_", "") = "QtyInPack") Then
                        audit.AddAuditField(colName, saveValue)
                        cmd.ExecuteNonQuery()
                    End If

                    cmd.Dispose()

                    If colName = "PLIEnglish" Or colName = "PLIFrench" Or colName = "PLISpanish" Then
                        'NAK 5/6/2013:  Per Michaels, no longer update child based on parent
                        'If item.IsPackParent Then
                        '    Dim childItems As Models.ItemList = itemDetail.GetList(item.ItemHeaderID, 0, 0, String.Empty, userID)
                        '    For i As Integer = 0 To childItems.ListRecords.Count - 1
                        '        Dim childItem As Models.ItemRecord = childItems.ListRecords(i)
                        '        If String.IsNullOrEmpty(childItem.MichaelsSKU) Then
                        '            Select Case colName
                        '                Case "PLIEnglish"
                        '                    If childItem.PLIEnglish <> item.PLIEnglish Then
                        '                        'Default TI field if it is empty
                        '                        'If String.IsNullOrEmpty(childItem.TIEnglish) Then
                        '                        'childItem.TIEnglish = item.PLIEnglish
                        '                        'End If
                        '                        NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(childItem.ID, 1, item.PLIEnglish, childItem.TIEnglish, childItem.EnglishShortDescription, Left(childItem.EnglishLongDescription, 100), userID)
                        '                        NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(childItem.ID, 1)
                        '                    End If
                        '                Case "PLIFrench"
                        '                    If childItem.PLIFrench <> item.PLIFrench Then
                        '                        'Default TI field if it is empty
                        '                        'If String.IsNullOrEmpty(childItem.TIFrench) Then
                        '                        '   childItem.TIFrench = item.PLIFrench
                        '                        'End If
                        '                        NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(childItem.ID, 2, item.PLIFrench, childItem.TIFrench, childItem.FrenchShortDescription, childItem.FrenchLongDescription, userID)
                        '                        NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(childItem.ID, 2)
                        '                    End If
                        '                Case "PLISpanish"
                        '                    If childItem.PLISpanish <> item.PLISpanish Then
                        '                        NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(childItem.ID, 3, item.PLISpanish, childItem.TISpanish, childItem.SpanishShortDescription, childItem.SpanishLongDescription, userID)
                        '                        NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(childItem.ID, 3)
                        '                    End If
                        '            End Select
                        '        End If
                        '    Next
                        'End If

                    ElseIf colName = "Each_Case_Height" Or colName = "Each_Case_Width" Or colName = "Each_Case_Length" Or colName = "Each_Case_Weight" Then
                        ' check to see if each case pack cube needs to be calced
                        SQLStr = "select Each_Case_Height, Each_Case_Width, Each_Case_Length, Each_Case_Weight from [dbo].[SPD_Items] where [ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        If reader.Read() Then
                            he = DataHelper.SmartValues(reader("Each_Case_Height"), "decimal", True, Decimal.MinValue, 4)
                            wi = DataHelper.SmartValues(reader("Each_Case_Width"), "decimal", True, Decimal.MinValue, 4)
                            le = DataHelper.SmartValues(reader("Each_Case_Length"), "decimal", True, Decimal.MinValue, 4)
                            we = DataHelper.SmartValues(reader("Each_Case_Weight"), "decimal", True, Decimal.MinValue, 4)
                        End If
                        reader.Dispose()
                        reader = Nothing
                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If
                        cmd.Parameters.Clear()
                        cmd.CommandText = "update [dbo].[SPD_Items] set Each_Case_Pack_Cube = @value where [ID] = @rowID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        cmd.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(cresult, "decimal", True)
                        cmd.ExecuteNonQuery()
                        retValue2 = CALLBACK_SEP & "EachCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        audit.AddAuditField("Each_Case_Pack_Cube", cresult)
                        cmd.Dispose()

                    ElseIf colName = "Inner_Case_Height" Or colName = "Inner_Case_Width" Or colName = "Inner_Case_Length" Or colName = "Inner_Case_Weight" Then
                        ' check to see if inner case pack cube needs to be calced
                        SQLStr = "select Inner_Case_Height, Inner_Case_Width, Inner_Case_Length, Inner_Case_Weight from [dbo].[SPD_Items] where [ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        If reader.Read() Then
                            he = DataHelper.SmartValues(reader("Inner_Case_Height"), "decimal", True, Decimal.MinValue, 4)
                            wi = DataHelper.SmartValues(reader("Inner_Case_Width"), "decimal", True, Decimal.MinValue, 4)
                            le = DataHelper.SmartValues(reader("Inner_Case_Length"), "decimal", True, Decimal.MinValue, 4)
                            we = DataHelper.SmartValues(reader("Inner_Case_Weight"), "decimal", True, Decimal.MinValue, 4)
                        End If
                        reader.Dispose()
                        reader = Nothing
                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If
                        cmd.Parameters.Clear()
                        cmd.CommandText = "update [dbo].[SPD_Items] set Inner_Case_Pack_Cube = @value where [ID] = @rowID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        cmd.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(cresult, "decimal", True)
                        cmd.ExecuteNonQuery()
                        retValue2 = CALLBACK_SEP & "InnerCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        audit.AddAuditField("Inner_Case_Pack_Cube", cresult)
                        cmd.Dispose()

                    ElseIf colName = "Master_Case_Height" Or colName = "Master_Case_Width" Or colName = "Master_Case_Length" Or colName = "Master_Case_Weight" Then

                        ' check to see if master case pack cube needs to be calced
                        SQLStr = "select Master_Case_Height, Master_Case_Width, Master_Case_Length, Master_Case_Weight from [dbo].[SPD_Items] where [ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        If reader.Read() Then
                            he = DataHelper.SmartValues(reader("Master_Case_Height"), "decimal", True, Decimal.MinValue, 4)
                            wi = DataHelper.SmartValues(reader("Master_Case_Width"), "decimal", True, Decimal.MinValue, 4)
                            le = DataHelper.SmartValues(reader("Master_Case_Length"), "decimal", True, Decimal.MinValue, 4)
                            we = DataHelper.SmartValues(reader("Master_Case_Weight"), "decimal", True, Decimal.MinValue, 4)
                        End If
                        reader.Dispose()
                        reader = Nothing
                        If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                            cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                        Else
                            cresult = String.Empty
                        End If
                        cmd.Parameters.Clear()
                        cmd.CommandText = "update [dbo].[SPD_Items] set Master_Case_Pack_Cube = @value where [ID] = @rowID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        cmd.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(cresult, "decimal", True)
                        cmd.ExecuteNonQuery()
                        retValue2 = CALLBACK_SEP & "MasterCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        audit.AddAuditField("Master_Case_Pack_Cube", cresult)
                        cmd.Dispose()

                    ElseIf colName = "Hybrid_Lead_Time" Then

                        ' converstion date
                        SQLStr = "select Hybrid_Lead_Time from [dbo].[SPD_Items] where [ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim leadTime As Integer = Integer.MinValue
                        Dim cresult As String = String.Empty
                        If reader.Read() Then
                            leadTime = DataHelper.SmartValues(reader("Hybrid_Lead_Time"), "integer", True)
                        End If
                        reader.Dispose()
                        reader = Nothing
                        cresult = CalculationHelper.CalculateConversionDate(leadTime)
                        cmd.Parameters.Clear()
                        cmd.CommandText = "update [dbo].[SPD_Items] set Hybrid_Conversion_Date = @value where [ID] = @rowID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        cmd.Parameters.Add("@value", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(cresult, "date", True)
                        cmd.ExecuteNonQuery()
                        retValue2 = CALLBACK_SEP & "HybridConversionDate" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        audit.AddAuditField("Hybrid_Conversion_Date", cresult)
                        cmd.Dispose()

                    ElseIf colName = "Pre_Priced" Or colName = "Base_Retail" Then

                        ' retail
                        SQLStr = "select Pre_Priced, Base_Retail, Alaska_Retail,Village_Craft_Retail,California_Retail,Test_Retail,Zero_Nine_Retail,Central_Retail, Retail9,Retail10,Retail11,Retail12,Retail13, RDQuebec, RDPuertoRico, Canada_Retail from [dbo].[SPD_Items] where [ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim prePriced As String = String.Empty
                        Dim baseRetail As Decimal = Decimal.MinValue
                        Dim alaskaRetail As Decimal = Decimal.MinValue
                        Dim retail9 As Decimal = Decimal.MinValue, _
                            retail10 As Decimal = Decimal.MinValue, _
                            retail12 As Decimal = Decimal.MinValue, _
                            retail11 As Decimal = Decimal.MinValue, _
                            retail13 As Decimal = Decimal.MinValue
                        Dim CentralRetail As Decimal = Decimal.MinValue
                        Dim VcraftRetail As Decimal = Decimal.MinValue
                        Dim CalifRetail As Decimal = Decimal.MinValue
                        Dim ZeroNineRetail As Decimal = Decimal.MinValue
                        Dim TestRetail As Decimal = Decimal.MinValue
                        Dim QuebecRetail As Decimal = Decimal.MinValue
                        Dim PuertoRicoRetail As Decimal = Decimal.MinValue
                        Dim RDCanada As Decimal = Decimal.MinValue
                        Dim RDQuebec As Decimal = Decimal.MinValue
                        Dim batchWorkflowStageID As Long = item.BatchStageID

                        Dim cresult As String = String.Empty
                        Dim cresultAlaska As String = String.Empty
                        If reader.Read() Then
                            prePriced = DataHelper.SmartValues(reader("Pre_Priced"), "string", True)
                            baseRetail = DataHelper.SmartValues(reader("Base_Retail"), "decimal", True)
                            alaskaRetail = DataHelper.SmartValues(reader("Alaska_Retail"), "decimal", True)
                            retail9 = DataHelper.SmartValues(reader("Retail9"), "decimal", True)
                            retail10 = DataHelper.SmartValues(reader("Retail10"), "decimal", True)
                            retail11 = DataHelper.SmartValues(reader("Retail11"), "decimal", True)
                            retail12 = DataHelper.SmartValues(reader("Retail12"), "decimal", True)
                            retail13 = DataHelper.SmartValues(reader("Retail13"), "decimal", True)
                            VcraftRetail = DataHelper.SmartValues(reader("Village_Craft_Retail"), "decimal", True)
                            CalifRetail = DataHelper.SmartValues(reader("California_Retail"), "decimal", True)
                            TestRetail = DataHelper.SmartValues(reader("Test_Retail"), "decimal", True)
                            ZeroNineRetail = DataHelper.SmartValues(reader("Zero_Nine_Retail"), "decimal", True)
                            CentralRetail = DataHelper.SmartValues(reader("Central_Retail"), "decimal", True)
                            PuertoRicoRetail = DataHelper.SmartValues(reader("RDPuertoRico"), "decimal", True)
                            RDCanada = DataHelper.SmartValues(reader("Canada_Retail"), "decimal", True)
                            RDQuebec = DataHelper.SmartValues(reader("RDQuebec"), "decimal", True)
                        End If
                        reader.Dispose()
                        reader = Nothing
                        If baseRetail <> Decimal.MinValue Then
                            cresult = DataHelper.SmartValues(baseRetail, "formatcurrency", False, String.Empty, 2)
                            If retail9 = Decimal.MinValue Then retail9 = baseRetail
                            If retail10 = Decimal.MinValue Then retail10 = baseRetail
                            If retail11 = Decimal.MinValue Then retail11 = baseRetail
                            If retail12 = Decimal.MinValue Then retail12 = baseRetail
                            If retail13 = Decimal.MinValue Then retail13 = baseRetail
                            If VcraftRetail = Decimal.MinValue Then VcraftRetail = baseRetail
                            If CalifRetail = Decimal.MinValue Then CalifRetail = baseRetail
                            If TestRetail = Decimal.MinValue Then TestRetail = baseRetail
                            If ZeroNineRetail = Decimal.MinValue Then ZeroNineRetail = baseRetail
                            If CentralRetail = Decimal.MinValue Then CentralRetail = baseRetail
                            If PuertoRicoRetail = Decimal.MinValue Then PuertoRicoRetail = baseRetail
                            If prePriced = "Y" Then
                                alaskaRetail = baseRetail
                                cresultAlaska = cresult
                            Else
                                ' price point lookup
                                Dim objRecord As Models.PricePointRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupAlaskRetailFromBaseRetail(baseRetail)
                                If Not objRecord Is Nothing AndAlso objRecord.DiffRetail <> Decimal.MinValue Then
                                    alaskaRetail = objRecord.DiffRetail
                                    cresultAlaska = DataHelper.SmartValues(alaskaRetail, "formatcurrency", False, String.Empty, 2)
                                Else
                                    If alaskaRetail <> Decimal.MinValue Then
                                        cresultAlaska = DataHelper.SmartValues(alaskaRetail, "formatcurrency", False, String.Empty, 2)
                                    End If
                                End If
                            End If

                            'logic modified by KH 2019-07-15 to treat canadian fields like normal zone
                            If RDCanada = Decimal.MinValue Then RDCanada = baseRetail
                            If RDQuebec = Decimal.MinValue Then RDQuebec = baseRetail
                            'RDCanada = NovaLibra.Coral.Data.Michaels.ItemDetail.GetGridPrice(5, baseRetail)
                            'RDCanada = IIf(RDCanada <= 0, Decimal.MinValue, RDCanada)
                            'RDQuebec = RDCanada

                            'Else
                            '    RDCanada = baseRetail
                            '    RDQuebec = baseRetail
                        End If
                        Dim func As String = CType(IIf(prePriced = "Y", IIf(colName = "Pre_Priced", "BaseRetailAPP", "BaseRetailA"), IIf(colName = "Pre_Priced", "BaseRetailPP", "BaseRetail")), String)
                        cmd.Parameters.Clear()
                        'lp Change order 14 Aug 19 2009
                        cmd.CommandText = "update [dbo].[SPD_Items] set Central_Retail = @CentralRetail, " & _
                            "Test_Retail = @TestRetail, " & _
                            "Alaska_Retail = @value2, " & _
                            "Zero_Nine_Retail = @ZeroNineRetail, " & _
                            "California_Retail = @CalifRetail, " & _
                            "Village_Craft_Retail = @VcraftRetail, " & _
                            "Retail9 = @retail9, " & _
                            "Retail10 = @retail10, " & _
                            "Retail11 = @retail11, " & _
                            "Retail12 = @retail12, " & _
                            "Retail13 = @retail13, " & _
                            "RDPuertoRico = @puertoRicoRetail "

                        'Price Mgr
                        'logic modified to always include these columns. KH 2019-07-15
                        'If Not (batchWorkflowStageID = 5 AndAlso RDCanada <= 0) Then
                        cmd.CommandText = cmd.CommandText & " , " & _
                            "Canada_Retail = @RDCanada, " & _
                            "RDQuebec = @RDQuebec "
                        'End If

                        cmd.CommandText = cmd.CommandText & " where [ID] = @rowID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        cmd.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(baseRetail, "decimal", True)
                        cmd.Parameters.Add("@value2", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(alaskaRetail, "decimal", True)
                        cmd.Parameters.Add("@retail9", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail9, "decimal", True)
                        cmd.Parameters.Add("@retail10", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail10, "decimal", True)
                        cmd.Parameters.Add("@retail11", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail11, "decimal", True)
                        cmd.Parameters.Add("@retail12", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail12, "decimal", True)
                        cmd.Parameters.Add("@retail13", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail13, "decimal", True)
                        cmd.Parameters.Add("@VcraftRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(VcraftRetail, "decimal", True)
                        cmd.Parameters.Add("@ZeroNineRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(ZeroNineRetail, "decimal", True)
                        cmd.Parameters.Add("@TestRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(TestRetail, "decimal", True)
                        cmd.Parameters.Add("@CalifRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(CalifRetail, "decimal", True)
                        cmd.Parameters.Add("@CentralRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(CentralRetail, "decimal", True)
                        cmd.Parameters.Add("@puertoRicoRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(PuertoRicoRetail, "decimal", True)

                        'logic modified to always include these columns. KH 2019-07-15
                        'If Not (batchWorkflowStageID = 5 AndAlso RDCanada <= 0) Then
                        cmd.Parameters.Add("@RDCanada", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(RDCanada, "decimal", True)
                        cmd.Parameters.Add("@RDQuebec", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(RDQuebec, "decimal", True)
                        'End If

                        cmd.ExecuteNonQuery()

                        retValue2 = CALLBACK_SEP & func & CALLBACK_SEP & String.Format("gce_{0}_", rowID, columnID) & CALLBACK_SEP & cresult & "__" & cresultAlaska

                        'removed by KH 2019-07-15
                        'If colName = "Base_Retail" AndAlso Not (batchWorkflowStageID = 5 AndAlso RDCanada <= 0) Then
                        '    If RDCanada = Decimal.MinValue Then
                        '        retValue2 = retValue2 & "__BRCQ__"
                        '    Else
                        '        retValue2 = retValue2 & "__BRCQ__" & DataHelper.SmartValues(RDCanada, "formatcurrency", False, String.Empty, 2)
                        '    End If
                        'End If

                        audit.AddAuditField("Central_Retail", baseRetail)
                        audit.AddAuditField("Test_Retail", baseRetail)
                        audit.AddAuditField("Alaska_Retail", alaskaRetail)
                        audit.AddAuditField("Zero_Nine_Retail", baseRetail)
                        audit.AddAuditField("California_Retail", baseRetail)
                        audit.AddAuditField("Village_Craft_Retail", baseRetail)
                        audit.AddAuditField("Retail9", retail9)
                        audit.AddAuditField("Retail10", retail10)
                        audit.AddAuditField("Retail11", retail11)
                        audit.AddAuditField("Retail12", retail12)
                        audit.AddAuditField("Retail13", retail13)
                        audit.AddAuditField("RDPuertoRico", PuertoRicoRetail)

                        'logic modified to always include these columns. KH 2019-07-15
                        'If Not (batchWorkflowStageID = 5 AndAlso baseRetail <= 0) Then
                        audit.AddAuditField("Canada_Retail", RDCanada)
                        audit.AddAuditField("RDQuebec", RDQuebec)
                        'End If

                        cmd.Dispose()

                    ElseIf colName = "Alaska_Retail" Then

                        ' alaska retail
                        Dim baseAlaska As Decimal = Decimal.MinValue
                        Dim resultAlaska As String = String.Empty
                        'If baseAlaska <> Decimal.MinValue Then
                        '    resultAlaska = DataHelper.SmartValues(baseAlaska, "formatnumber", False, String.Empty, 2)
                        'End If

                        SQLStr = "select Alaska_Retail from [dbo].[SPD_Items] where [ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim cresult As String = String.Empty
                        If reader.Read() Then
                            baseAlaska = DataHelper.SmartValues(reader("Alaska_Retail"), "decimal", True)
                        End If
                        reader.Dispose()
                        reader = Nothing
                        If baseAlaska <> Decimal.MinValue Then
                            cresult = DataHelper.SmartValues(baseAlaska, "formatcurrency", False, String.Empty, 2)
                        End If
                        retValue2 = CALLBACK_SEP & "AlaskaRetail" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        'audit.AddAuditField("Alaska_Retail", cresult)
                        cmd.Dispose()
                        'ElseIf colName = "Retail9" Or colName = "Retail10" Or colName = "Retail11" Or colName = "Retail12" Or colName = "Retail13" Then
                        '    cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        '    cmd.Parameters.Clear()
                        '    'lp Change order 14 Aug 24 2009
                        '    cmd.CommandText = "update [dbo].[SPD_Items] set " & colName & " = @value where [ID] = @rowID"
                        '    cmd.CommandType = CommandType.Text
                        '    cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        '    cmd.Parameters.Add("@value", SqlDbType.Decimal).Value = saveValue
                        '    cmd.ExecuteNonQuery()
                        '    cmd.Dispose()

                        'canada_retail case removed. KH 2019-07-15

                        'ElseIf colName = "Canada_Retail" Then

                        '    ' canada retail
                        '    Dim baseCanada As Decimal = Decimal.MinValue
                        '    Dim quebecRetail As Decimal = Decimal.MinValue
                        '    Dim resultCanada As String = String.Empty

                        '    SQLStr = "select Canada_Retail, RDQuebec from [dbo].[SPD_Items] where [ID] = @rowID"
                        '    cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        '    cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        '    reader = New DBReader(cmd)
                        '    reader.Open()
                        '    Dim cresult As String = String.Empty
                        '    If reader.Read() Then
                        '        baseCanada = DataHelper.SmartValues(reader("Canada_Retail"), "decimal", True)
                        '        quebecRetail = DataHelper.SmartValues(reader("RDQuebec"), "decimal", True)
                        '    End If
                        '    reader.Dispose()
                        '    reader = Nothing

                        '    'Update QuebecRetail, so it defaults to Canada Retail if it is null.
                        '    If quebecRetail = Decimal.MinValue And baseCanada <> Decimal.MinValue Then
                        '        quebecRetail = baseCanada
                        '    End If
                        '    cmd.Parameters.Clear()
                        '    cmd.CommandText = "update [dbo].[SPD_Items] set RDQuebec = @QuebecRetail " & _
                        '        "where [ID] = @rowID"
                        '    cmd.CommandType = CommandType.Text
                        '    cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        '    cmd.Parameters.Add("@QuebecRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(quebecRetail, "decimal", True)
                        '    cmd.ExecuteNonQuery()
                        '    audit.AddAuditField("RDQuebec", quebecRetail)

                        '    If baseCanada <> Decimal.MinValue Then
                        '        cresult = DataHelper.SmartValues(baseCanada, "formatcurrency", False, String.Empty, 2)
                        '    End If
                        '    retValue2 = CALLBACK_SEP & "CanadaRetail" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        '    'audit.AddAuditField("Canada_Retail", cresult)
                        '    cmd.Dispose()

                    ElseIf colName = "Hazardous" Then

                        ' hazardous
                        'SQLStr = "select Hybrid_Lead_Time from [dbo].[SPD_Items] where [ID] = @rowID"

                        'cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        'reader = New DBReader(cmd)
                        'reader.Open()
                        'Dim leadTime As Integer = Integer.MinValue
                        Dim cresult As String = String.Empty
                        'If reader.Read() Then
                        '    leadTime = DataHelper.SmartValues(reader("Hybrid_Lead_Time"), "integer", True)
                        'End If
                        'reader.Dispose()
                        'reader = Nothing
                        Dim haz As String = dataText
                        If haz <> "Y" Then
                            SQLStr = String.Empty
                            cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                            cmd.Parameters.Clear()
                            cmd.CommandText = "update [dbo].[SPD_Items] set Hazardous_Flammable = null, Hazardous_Container_Type = null, Hazardous_Container_Size = null, Hazardous_MSDS_UOM = null, Hazardous_Manufacturer_Name = null, Hazardous_Manufacturer_City = null, Hazardous_Manufacturer_State = null, Hazardous_Manufacturer_Phone = null, Hazardous_Manufacturer_Country = null where [ID] = @rowID"
                            cmd.CommandType = CommandType.Text
                            cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                            cmd.ExecuteNonQuery()
                            retValue2 = CALLBACK_SEP & "Hazardous" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & String.Empty
                            audit.AddAuditField("Hazardous_Flammable", String.Empty)
                            audit.AddAuditField("Hazardous_Container_Type", String.Empty)
                            audit.AddAuditField("Hazardous_Container_Size", String.Empty)
                            audit.AddAuditField("Hazardous_MSDS_UOM", String.Empty)
                            audit.AddAuditField("Hazardous_Manufacturer_Name", String.Empty)
                            audit.AddAuditField("Hazardous_Manufacturer_City", String.Empty)
                            audit.AddAuditField("Hazardous_Manufacturer_State", String.Empty)
                            audit.AddAuditField("Hazardous_Manufacturer_Phone", String.Empty)
                            audit.AddAuditField("Hazardous_Manufacturer_Country", String.Empty)
                            cmd.Dispose()
                        End If

                    ElseIf colName = "Country_Of_Origin_Name" Then

                        ' converstion date
                        SQLStr = "select Country_Of_Origin_Name from [dbo].[SPD_Items] where [ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim countryName As String = String.Empty
                        Dim countryCode As String = String.Empty
                        Dim cresult As String = String.Empty
                        If reader.Read() Then
                            countryName = DataHelper.SmartValues(reader("Country_Of_Origin_Name"), "string", True)
                        End If
                        reader.Dispose()
                        reader = Nothing
                        Dim country As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(countryName)
                        If Not country Is Nothing AndAlso country.CountryCode <> String.Empty AndAlso country.CountryName <> String.Empty Then
                            countryName = country.CountryName
                            countryCode = country.CountryCode
                            cresult = countryName
                        End If
                        cmd.Parameters.Clear()
                        cmd.CommandText = "update [dbo].[SPD_Items] set Country_Of_Origin_Name = @countryName, Country_Of_Origin = @countryCode where [ID] = @rowID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        cmd.Parameters.Add("@countryName", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(countryName, "string", True)
                        cmd.Parameters.Add("@countryCode", SqlDbType.VarChar, 2).Value = DataHelper.DBSmartValues(countryCode, "string", True)
                        cmd.ExecuteNonQuery()
                        retValue2 = CALLBACK_SEP & "CountryOfOriginName" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        audit.RemoveAuditField("CountryOfOriginName")
                        audit.RemoveAuditField("CountryOfOrigin")
                        audit.RemoveAuditField("Country_Of_Origin_Name")
                        audit.RemoveAuditField("Country_Of_Origin")
                        audit.AddAuditField("Country_Of_Origin_Name", countryName)
                        audit.AddAuditField("Country_Of_Origin", countryCode)
                        cmd.Dispose()

                    ElseIf colName = "Like_Item_SKU" Then

                        ' like item sku
                        Dim itemSKU As String = dataText
                        Dim resultItemDesc As String = String.Empty
                        Dim baseRetail As Decimal = Decimal.MinValue
                        Dim resultBaseRetail As String = String.Empty
                        If itemSKU <> String.Empty Then
                            Dim objRecord As Models.ItemMasterRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupItemMaster(itemSKU)
                            If Not objRecord Is Nothing AndAlso (objRecord.ItemDescription <> String.Empty Or objRecord.BaseRetail <> Decimal.MinValue) Then
                                resultItemDesc = objRecord.ItemDescription
                                If objRecord.BaseRetail <> Decimal.MinValue Then
                                    baseRetail = objRecord.BaseRetail
                                    resultBaseRetail = DataHelper.SmartValues(objRecord.BaseRetail, "formatnumber", True, String.Empty, 2)
                                End If
                            End If
                            objRecord = Nothing
                        End If

                        SQLStr = String.Empty
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Clear()
                        cmd.CommandText = "update [dbo].[SPD_Items] set Like_Item_Description = @value, Like_Item_Retail = @value2 where [ID] = @rowID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        cmd.Parameters.Add("@value", SqlDbType.VarChar, 255).Value = resultItemDesc
                        cmd.Parameters.Add("@value2", SqlDbType.Money).Value = DataHelper.DBSmartValues(baseRetail, "decimal", True)
                        cmd.ExecuteNonQuery()
                        retValue2 = CALLBACK_SEP & "LikeItemSKU" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & resultItemDesc & "__" & resultBaseRetail
                        audit.AddAuditField("Like_Item_Description", resultItemDesc)
                        audit.AddAuditField("Like_Item_Retail", DataHelper.DBSmartValues(baseRetail, "decimal", True))
                        cmd.Dispose()

                    ElseIf colName = "Like_Item_Unit_Store_Month" Or colName = "Annual_Regular_Unit_Forecast" Then
                        Dim objMichaelsDet As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                        Dim item1 As Models.ItemRecord = objMichaelsDet.GetRecord(itemID)
                        Dim itemHeader1 As Models.ItemHeaderRecord = objMichaelsDet.GetItemHeaderRecord(item1.ItemHeaderID)
                        saveValue = DataHelper.SmartValues(saveValue, "decimal", True, Decimal.MinValue, 2)
                        Dim tempholder As Decimal
                        Dim val1 As String = String.Empty
                        Dim val2 As String = String.Empty

                        If colName = "Like_Item_Unit_Store_Month" Then
                            If itemHeader1.StoreTotal <> Integer.MinValue Then
                                item1.LikeItemUnitStoreMonth = saveValue
                                If saveValue <> Decimal.MinValue Then
                                    tempholder = itemHeader1.StoreTotal * item1.LikeItemUnitStoreMonth * 13
                                    item1.AnnualRegularUnitForecast = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 0)
                                    If item1.BaseRetail <> Decimal.MinValue Then
                                        tempholder = item1.BaseRetail * item1.AnnualRegularUnitForecast
                                        item1.AnnualRegRetailSales = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                                    Else
                                        item1.AnnualRegRetailSales = Decimal.MinValue
                                    End If
                                Else
                                    item1.AnnualRegularUnitForecast = saveValue
                                    item1.AnnualRegRetailSales = saveValue
                                End If

                                If item1.AnnualRegularUnitForecast <> Decimal.MinValue Then
                                    val1 = DataHelper.SmartValues(item1.AnnualRegularUnitForecast, "integer", False)
                                End If
                                If item1.AnnualRegRetailSales <> Decimal.MinValue Then
                                    val2 = DataHelper.SmartValues(item1.AnnualRegRetailSales, "formatnumber", False)
                                End If
                                retValue2 = CALLBACK_SEP & "LikeItemUnitStoreMonth" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & val1 & "__" & val2
                            End If
                        Else '"Annual_Regular_Unit_Forecast"

                            If saveValue <> Decimal.MinValue And itemHeader1.StoreTotal <> Integer.MinValue And itemHeader1.StoreTotal <> 0 Then

                                item1.AnnualRegularUnitForecast = DataHelper.SmartValues(saveValue, "decimal", True, Decimal.MinValue, 0)
                                tempholder = item1.AnnualRegularUnitForecast / itemHeader1.StoreTotal / 13
                                item1.LikeItemUnitStoreMonth = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                                If item1.BaseRetail <> Decimal.MinValue Then
                                    tempholder = item1.BaseRetail * item1.AnnualRegularUnitForecast
                                    item1.AnnualRegRetailSales = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                                Else
                                    item1.AnnualRegRetailSales = Decimal.MinValue
                                End If

                            Else
                                item1.AnnualRegularUnitForecast = DataHelper.SmartValues(saveValue, "decimal", True, Decimal.MinValue, 0)
                                item1.LikeItemUnitStoreMonth = 0
                                item1.AnnualRegRetailSales = 0
                            End If
                            If item1.LikeItemUnitStoreMonth <> Decimal.MinValue Then
                                val1 = DataHelper.SmartValues(item1.LikeItemUnitStoreMonth, "formatnumber", False)
                            End If
                            If item1.AnnualRegRetailSales <> Decimal.MinValue Then
                                val2 = DataHelper.SmartValues(item1.AnnualRegRetailSales, "formatnumber", False)
                            End If
                            retValue2 = CALLBACK_SEP & "AnnualRegularUnitForecast" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & val1 & "__" & val2
                        End If

                        tempholder = objMichaelsDet.SaveRecord(item1, userID)

                    ElseIf colName = "Pack_Item_Indicator" OrElse colName = "US_Cost" OrElse colName = "Canada_Cost" Then

                        ' check to see if total cost values need to be calced
                        SQLStr = "select i.Pack_Item_Indicator, i.US_Cost, i.Canada_Cost, ih.Item_Type, ih.Add_Unit_Cost from [dbo].[SPD_Items] i inner join [dbo].[SPD_Item_Headers] ih on i.[Item_Header_ID] = ih.[ID] where i.[ID] = @rowID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim returnToken As String = String.Empty
                        Dim it As String = String.Empty
                        Dim auc As Decimal = Decimal.MinValue
                        Dim pii As String = String.Empty
                        Dim uscost As Decimal = Decimal.MinValue
                        Dim ccost As Decimal = Decimal.MinValue
                        Dim tuscost As Decimal = Decimal.MinValue
                        Dim tccost As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        If reader.Read() Then
                            it = DataHelper.SmartValues(reader("Item_Type"), "string", True)
                            auc = DataHelper.SmartValues(reader("Add_Unit_Cost"), "decimal", True)
                            pii = DataHelper.SmartValues(reader("Pack_Item_Indicator"), "string", True)
                            uscost = DataHelper.SmartValues(reader("US_Cost"), "decimal", True)
                            ccost = DataHelper.SmartValues(reader("Canada_Cost"), "decimal", True)
                        End If
                        reader.Dispose()
                        reader = Nothing

                        cmd.Parameters.Clear()
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)

                        If colName = "US_Cost" Then
                            returnToken = "TotalUSCost"
                            tuscost = CalculationHelper.CalculateTotalCost(it, auc, pii, uscost)
                            cresult = IIf(uscost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(uscost, "formatcurrency4", True)) & _
                                "__" & _
                                IIf(tuscost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(tuscost, "formatcurrency4", True))
                            cmd.CommandText = "update [dbo].[SPD_Items] set Total_US_Cost = @value1 where [ID] = @rowID"
                            cmd.Parameters.Add("@value1", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tuscost, "decimal", True)
                            audit.AddAuditField("Total_US_Cost", cresult)
                        ElseIf colName = "Canada_Cost" Then
                            returnToken = "TotalCanadaCost"
                            tccost = CalculationHelper.CalculateTotalCost(it, auc, pii, ccost)
                            cresult = IIf(ccost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(ccost, "formatcurrency4", True)) & _
                                "__" & _
                                IIf(tccost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(tccost, "formatcurrency4", True))
                            cmd.CommandText = "update [dbo].[SPD_Items] set Total_Canada_Cost = @value2 where [ID] = @rowID"
                            cmd.Parameters.Add("@value2", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tccost, "decimal", True)
                            audit.AddAuditField("Total_Canada_Cost", cresult)
                        Else
                            returnToken = "TotalCosts"
                            tuscost = CalculationHelper.CalculateTotalCost(it, auc, pii, uscost)
                            tccost = CalculationHelper.CalculateTotalCost(it, auc, pii, ccost)
                            cresult = IIf(tuscost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(tuscost, "formatcurrency4", True)) & _
                                "__" & _
                                IIf(tccost = Decimal.MinValue, String.Empty, DataHelper.SmartValues(tccost, "formatcurrency4", True))
                            cmd.CommandText = "update [dbo].[SPD_Items] set Total_US_Cost = @value1, Total_Canada_Cost = @value2 where [ID] = @rowID"
                            cmd.Parameters.Add("@value1", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tuscost, "decimal", True)
                            cmd.Parameters.Add("@value2", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tccost, "decimal", True)
                            audit.AddAuditField("Total_US_Cost", DataHelper.SmartValuesAsString(tuscost, "decimal"))
                            audit.AddAuditField("Total_Canada_Cost", DataHelper.SmartValuesAsString(tccost, "decimal"))
                        End If

                        cmd.ExecuteNonQuery()
                        retValue2 = CALLBACK_SEP & returnToken & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        cmd.Dispose()

                    End If
                    ' end special field functions (after save)
                    ' ------------------------------------------------------------------------------------------

                    ' clean up
                    cmd = Nothing
                    'Re-GET record to get changes that were just saved.
                    item = itemDetail.GetRecord(itemID)
                    Dim itemHeader As Models.ItemHeaderRecord = itemDetail.GetItemHeaderRecord(item.ItemHeaderID)

                    ' check to see if need to calculate parent cost of a pack batch
                    Dim col As String = colName.Replace("_", "")
                    If col = "QtyInPack" Or col = "USCost" Or col = "CanadaCost" Then
                        If packInfo.IsPack AndAlso Not packInfo.IsPackParent Then
                            If ItemHelper.CalculateDomesticDPBatchParent(itemHeader, True, False) Then
                                ' refresh the grid...
                                retvalue4 = CALLBACK_SEP & "1"
                            End If
                        End If
                    End If
                    If col = "MasterCaseWeight" Then
                        If packInfo.IsPack AndAlso Not packInfo.IsPackParent Then
                            If ItemHelper.CalculateDomesticDPBatchParent(itemHeader, False, True) Then
                                ' refresh the grid...
                                retvalue4 = CALLBACK_SEP & "1"
                            End If
                        End If
                    End If
                    If col = "PackItemIndicator" Then
                        Dim val As String = saveValue.ToString()
                        If val.Length > 2 Then val = val.Substring(0, 2)
                        val = val.Replace("-", "")
                        If val = "D" Or val = "DP" Or val = "SB" Then
                            retvalue4 = CALLBACK_SEP & "1"
                        End If
                    End If
                    'Refresh the page if this is a TI French or TI English, as they may have had their values defaulted from PLI
                    If col = "TIFrench" Or col = "TIEnglish" Then
                        retvalue4 = CALLBACK_SEP & "1"
                    End If


                    ' validation
                    Dim colSQL As String = "select ID" & _
                        ", isnull(Column_Name, '') as Column_Name" & _
                        ", Column_Ordinal" & _
                        ", Default_UserDisplay" & _
                        " from ColumnDisplayName" & _
                        " where [Display] = 1 and isnull(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & _
                        " order by Column_Ordinal"
                    colReader = New DBReader(conn, colSQL, CommandType.Text)
                    colReader.Open()
                    'Dim objGridItem As GridItem
                    Dim giarr As New ArrayList()
                    Do While colReader.Read()
                        'If ColumnEnabledByUser(colReader("ID"), DataHelper.SmartValues(colReader("Default_UserDisplay"), "Boolean")) Then
                        giarr.Add(New GridItem(colReader("Column_Ordinal"), String.Empty, colReader("Column_Name").ToString().Replace("_", String.Empty), String.Empty))
                        'End If
                    Loop
                    colReader.Dispose()
                    colReader = Nothing

                    Dim sbFields As New StringBuilder("")
                    Dim id As Long

                    Dim vrBatch As Models.ValidationRecord
                    Dim vr As Models.ValidationRecord
                    Dim itemsErrorFlag As Integer = Me.ValidateGrid(itemHeader)
                    Dim hasErrors As Boolean = IIf(itemsErrorFlag = 1 Or itemsErrorFlag = 3, True, False)
                    Dim hasWarnings As Boolean = IIf(itemsErrorFlag = 2 Or itemsErrorFlag = 3, True, False)

                    If ValidationHelper.SkipBatchValidation(itemHeader.BatchStageType) Then
                        vrBatch = New Models.ValidationRecord(itemHeader.BatchID, Models.ItemRecordType.Batch)
                    Else
                        vrBatch = ValidationHelper.ValidateBatch(itemHeader.BatchID, Models.BatchType.Domestic)
                        ' save validation 
                        NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
                    End If

                    If ValidationHelper.SkipValidation(itemHeader.BatchStageType) Then
                        vr = New Models.ValidationRecord(item.ID, Models.ItemRecordType.Item)
                    Else
                        vr = ValidationHelper.ValidateItem(item, itemHeader)
                        ' save validation 
                        NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vr, userID)
                    End If

                    If vr.HasAnyError() Then
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
                    End If
                    retValue3 = CALLBACK_SEP & itemID & CALLBACK_SEP & sbFields.ToString() & CALLBACK_SEP & CType(IIf(vr.IsValid, "displayValid", "displayNotValid"), String)
                    retValue3 = retValue3 & CALLBACK_SEP & IIf(vrBatch.IsValid, "1", "0") & IIf(itemHeader.IsValid, "1", "0") & IIf(hasErrors, "0", "1")
                    retValue3 = retValue3 & CALLBACK_SEP & RenderValidationControltoHTML(vrBatch, hasErrors, hasWarnings)
                    Do While giarr.Count > 0
                        giarr.RemoveAt(0)
                    Loop
                    giarr = Nothing

                    ' clean up
                    conn.Dispose()
                    conn = Nothing

                    ' return
                    retValue = "100" & CALLBACK_SEP & "1" & retValue2 & retValue3 & retvalue4
                End If

                itemDetail.SaveAuditRecord(audit)

            End If ' end if not custom fields

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            retValue = "100" & CALLBACK_SEP & "0"
        Catch ex As Exception
            Logger.LogError(ex)
            retValue = "100" & CALLBACK_SEP & "0"
        Finally
            If Not reader Is Nothing Then
                reader.Dispose()
                reader = Nothing
            End If
            If Not cmd Is Nothing Then
                cmd.Dispose()
                cmd = Nothing
            End If
            If Not colReader Is Nothing Then
                colReader.Dispose()
                colReader = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
        End Try

        audit = Nothing
        itemDetail = Nothing

        Return retValue
    End Function

    Private Function GetColIDFromGridItemArray(ByRef giarr As ArrayList, ByVal colName As String) As Long
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

    Public Function CallbackSaveAjaxEditSetAll(ByVal columnID As String, ByVal columnName As String, ByVal itemHeaderID As String, ByVal dataText As String) As String
        Dim retValue As String = String.Empty
        Dim retValue2 As String = String.Empty
        Dim SQLStr As String = String.Empty
        Dim decValue As Decimal
        Dim strValue As String
        Dim reader As DBReader = Nothing
        Dim cmd As DBCommand = Nothing
        Dim cmd2 As DBCommand = Nothing
        Dim conn As DBConnection = Nothing
        Dim conn2 As DBConnection = Nothing
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

        Dim itemDetail As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim itemsaudit As New Models.AuditRecord(Models.MetadataTable.Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)
        Dim audit As New Models.AuditRecord(Models.MetadataTable.Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)

        Dim colID As Integer = DataHelper.SmartValues(columnID, "integer", False)
        Dim startID As Integer = Me.CustomFieldStartID
        Dim isCustomField As Boolean = False
        If colID >= startID AndAlso startID > 0 Then isCustomField = True

        Try
            If isCustomField Then
                Dim saved As Boolean = False
                Dim fieldID As Integer = DataHelper.SmartValues(columnName, "integer", False)
                Dim itemID As Long
                Dim custFields As NovaLibra.Coral.SystemFrameworks.CustomFields
                reader = New DBReader(ApplicationConnectionStrings.AppConnectionString)
                reader.CommandText = "select ID from SPD_Items where ISNULL(Valid_Existing_SKU, 0) = 0 and Item_Header_ID = " & itemHeaderID
                reader.CommandType = CommandType.Text
                reader.Open()
                Do While reader.Read()
                    itemID = DataHelper.SmartValues(reader("ID"), "long", False)
                    custFields = NovaLibra.Coral.BusinessFacade.SystemCustomFields.GetCustomFields(Me.RecordType, itemID, True)
                    custFields.AddValue(itemID, fieldID, dataText)
                    saved = NovaLibra.Coral.BusinessFacade.SystemCustomFields.SaveCustomFieldValues(custFields)
                Loop
                reader.Dispose()
                reader = Nothing
                If saved Then
                    retValue = "200" & CALLBACK_SEP & "1" & retValue2
                Else
                    retValue = "200" & CALLBACK_SEP & "0"
                End If
            Else

                Dim colName As String = String.Empty
                'SQLStr = "select Column_Name, Column_Generic_Type from ColumnDisplayName where [ID] = @colID"
                'lp fix
                SQLStr = "select Column_Name, Column_Generic_Type from ColumnDisplayName where Workflow_ID = " & ItemGrid.GridID & " and Column_Ordinal = @colID"
                conn = ApplicationHelper.GetAppConnection()
                conn2 = ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                cmd.Parameters.Add("@colID", SqlDbType.Int).Value = DataHelper.SmartValues(columnID, "Integer")
                reader = New DBReader(cmd)
                reader.Open()
                If Not reader Is Nothing AndAlso reader.HasRows AndAlso reader.Read() Then
                    colName = reader("Column_Name")
                    Dim where2 As String = String.Empty
                    If colName.Replace("_", "") = "QtyInPack" Then
                        where2 = " and (Pack_Item_Indicator = 'C' or isnull(Pack_Item_Indicator, '') = '')"
                    Else
                        where2 = " and ISNULL(Valid_Existing_SKU, 0) = 0"
                    End If

                    SQLStr = ""
                    'The NovaGrid is dumb.  It does not support a multi-table data schema.  So, need to specifically save values multilingual fields here.
                    Dim pageSize As Integer = itemDetail.GetListCount(itemHeaderID, GetDefaultGridSortAndFilterXML(), userID) + 1
                    Dim itemList As Models.ItemList = itemDetail.GetList(itemHeaderID, 1, pageSize, GetDefaultGridSortAndFilterXML(), userID)
                    Dim batchWorkflowStageID As Long = itemDetail.GetItemHeaderRecord(itemHeaderID).BatchStageID

                    For Each item As Models.ItemRecord In itemList.ListRecords

                        Select Case colName
                            Case "PLIEnglish"
                                item.PLIEnglish = dataText
                                'If String.IsNullOrEmpty(item.TIEnglish) Then
                                'item.TIEnglish = dataText
                                'End If
                                'Mark PLI English field as having been edited
                                NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(item.ID, 1)

                            Case "PLIFrench"
                                item.PLIFrench = dataText
                                'If String.IsNullOrEmpty(item.TIFrench) Then
                                'item.TIFrench = dataText
                                'End If
                                'Mark PLI French field as having been edited
                                NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(item.ID, 2)

                            Case "PLISpanish"
                                item.PLISpanish = dataText
                                'Mark PLI Spanish field as having been edited
                                NovaLibra.Coral.Data.Michaels.ItemDetail.SaveEditedLanguage(item.ID, 3)

                            Case "TIEnglish"
                                item.TIEnglish = dataText
                            Case "TIFrench"
                                item.TIFrench = dataText
                            Case "TISpanish"
                                'Not currently supported
                            Case "EnglishShortDescription"
                                If item.PackItemIndicator.StartsWith("DP") Then
                                    item.EnglishShortDescription = "Display Pack"
                                ElseIf item.PackItemIndicator.StartsWith("SB") Then
                                    item.EnglishShortDescription = "Sellable Bundle"
                                ElseIf item.PackItemIndicator.StartsWith("D") Then
                                    item.EnglishShortDescription = "Displayer"
                                Else
                                    item.EnglishShortDescription = dataText
                                End If
                            Case "FrenchShortDescription"
                                item.FrenchShortDescription = dataText
                            Case "SpanishShortDescription"
                                item.SpanishShortDescription = dataText
                            Case "EnglishLongDescription"
                                If item.PackItemIndicator.StartsWith("DP") Then
                                    item.EnglishLongDescription = "Display Pack"
                                ElseIf item.PackItemIndicator.StartsWith("SB") Then
                                    item.EnglishLongDescription = "Sellable Bundle"
                                ElseIf item.PackItemIndicator.StartsWith("D") Then
                                    item.EnglishLongDescription = "Displayer"
                                Else
                                    item.EnglishLongDescription = dataText
                                End If

                            Case "FrenchLongDescription"
                                item.FrenchLongDescription = dataText
                            Case "SpanishLongDescription"
                                item.SpanishShortDescription = dataText
                            Case Else
                                SQLStr = "update [dbo].[SPD_Items] set " & colName & " = @value where [Item_Header_ID] = @itemHeaderID" & where2 & "; "
                        End Select
                        'Only update the record if it is not a valid existing sku
                        If Not (item.ValidExistingSKU) Then
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(item.ID, 1, item.PLIEnglish, item.TIEnglish, item.EnglishShortDescription, Left(item.EnglishLongDescription, 100), userID)
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(item.ID, 2, item.PLIFrench, item.TIFrench, item.FrenchShortDescription, item.FrenchLongDescription, userID)
                            NovaLibra.Coral.Data.Michaels.ItemDetail.SaveItemLanguage(item.ID, 3, item.PLISpanish, item.TISpanish, item.SpanishShortDescription, item.SpanishLongDescription, userID)
                        End If
                    Next

                    SQLStr = SQLStr & "exec [sp_SPD_Item_SetModified] @itemHeaderID, 'D', @userID, 1"

                    cmd = New DBCommand(ApplicationHelper.GetAppConnection(), SQLStr, CommandType.Text)
                    cmd.Parameters.Clear()
                    cmd.CommandText = SQLStr
                    cmd.CommandType = CommandType.Text
                    cmd.Parameters.Add("@itemHeaderID", SqlDbType.Int).Value = DataHelper.SmartValues(itemHeaderID, "Long")
                    cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                    Dim saveValue As Object
                    Dim strType As String = reader("Column_Generic_Type")

                    ' special field functions (before save)
                    If colName = "Vendor_UPC" Then
                        If IsNumeric(dataText) AndAlso DataHelper.SmartValues(dataText, "long", False) > 0 Then
                            dataText = dataText.Trim()
                            Do While dataText.Length < 14
                                dataText = "0" & dataText
                            Loop
                            'retValue2 = CALLBACK_SEP & "VendorUPC" & CALLBACK_SEP & String.Format("gce_{0}_{1}", "{0}", columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Like_Item_Regular_Unit" Then
                        If IsNumeric(dataText) AndAlso DataHelper.SmartValues(dataText, "decimal", False) > 0 Then
                            dataText = dataText.Trim()
                            decValue = DataHelper.SmartValues(dataText, "decimal", False) '/ 100
                            dataText = DataHelper.SmartValues(decValue, "formatnumber", True, String.Empty, 4)
                            'retValue2 = CALLBACK_SEP & "LikeItemRegularUnits" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & DataHelper.SmartValues(dataText, "percent", False)
                        Else
                            dataText = String.Empty
                            'retValue2 = CALLBACK_SEP & "LikeItemRegularUnits" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Vendor_Style_Num" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            'retValue2 = CALLBACK_SEP & "VendorStyleNum" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Item_Desc" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            'retValue2 = CALLBACK_SEP & "ItemDesc" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "Each_Case_Height" Or colName = "Each_Case_Width" Or colName = "Each_Case_Length" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "Inner_Case_Height" Or colName = "Inner_Case_Width" Or colName = "Inner_Case_Length" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "Master_Case_Height" Or colName = "Master_Case_Width" Or colName = "Master_Case_Length" Then
                        dataText = RoundDimesionsString(dataText.Trim())
                    ElseIf colName = "Each_Case_Weight" Or colName = "Inner_Case_Weight" Or colName = "Master_Case_Weight" Then
                        dataText = RoundDimesionsString(dataText.Trim(), 4)
                    End If
                    ' end special field functions (before save)

                    Select Case strType.ToLower()
                        Case "date", "datetime"
                            saveValue = DataHelper.SmartValues(dataText, "date", True)
                            cmd.Parameters.Add("@value", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(saveValue, "date", True)
                        Case "integer"
                            saveValue = DataHelper.SmartValues(dataText, "integer", True)
                            cmd.Parameters.Add("@value", SqlDbType.Int).Value = DataHelper.DBSmartValues(saveValue, "integer", True)
                        Case "long"
                            saveValue = DataHelper.SmartValues(dataText, "long", True)
                            cmd.Parameters.Add("@value", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(saveValue, "long", True)
                        Case "decimal", "single", "double", "number"
                            saveValue = DataHelper.SmartValues(dataText, "decimal", True)
                            cmd.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(saveValue, "decimal", True)
                        Case Else
                            saveValue = DataHelper.SmartValues(dataText, "string", True)
                            cmd.Parameters.Add("@value", SqlDbType.VarChar, 255).Value = DataHelper.DBSmartValues(saveValue, "string", True)
                    End Select
                    itemsaudit.AddAuditField(colName, saveValue)
                    reader.Dispose()
                    reader = Nothing
                    cmd.ExecuteNonQuery()
                    cmd.Dispose()


                    ' special field functions (after save)
                    If colName = "Each_Case_Height" Or colName = "Each_Case_Width" Or colName = "Each_Case_Length" Or colName = "Each_Case_Weight" Then

                        ' check to see if Each case pack cube needs to be calced
                        SQLStr = "select ID, Each_Case_Height, Each_Case_Width, Each_Case_Length, Each_Case_Weight, Valid_Existing_SKU from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        cmd2 = New DBCommand(conn2)
                        Do While reader.Read()
                            If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then
                                he = DataHelper.SmartValues(reader("Each_Case_Height"), "decimal", True, Decimal.MinValue, 4)
                                wi = DataHelper.SmartValues(reader("Each_Case_Width"), "decimal", True, Decimal.MinValue, 4)
                                le = DataHelper.SmartValues(reader("Each_Case_Length"), "decimal", True, Decimal.MinValue, 4)
                                we = DataHelper.SmartValues(reader("Each_Case_Weight"), "decimal", True, Decimal.MinValue, 4)
                                If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                                    cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                                    cmd2.Parameters.Clear()
                                    cmd2.CommandText = "update [dbo].[SPD_Items] set Each_Case_Pack_Cube = @value where [ID] = @rowID"
                                    cmd2.CommandType = CommandType.Text
                                    cmd2.Parameters.Add("@rowID", SqlDbType.BigInt).Value = DataHelper.SmartValues(reader("ID"), "long", False)
                                    cmd2.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(cresult, "decimal", True)
                                    cmd2.ExecuteNonQuery()
                                    audit.ClearFields()
                                    audit.AuditRecordID = DataHelper.SmartValues(reader("ID"), "long", False)
                                    audit.AddAuditField("Each_Case_Pack_Cube", DataHelper.DBSmartValues(cresult, "decimal", True))
                                    itemDetail.SaveAuditRecord(audit, conn2)
                                    'retValue2 = CALLBACK_SEP & "EachCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                                End If
                            End If

                        Loop
                        'cmd2.Connection.Dispose()
                        cmd2.Dispose()
                        cmd2 = Nothing
                        reader.Dispose()
                        reader = Nothing
                        cmd.Dispose()

                        ' special field functions (after save)
                    ElseIf colName = "Inner_Case_Height" Or colName = "Inner_Case_Width" Or colName = "Inner_Case_Length" Or colName = "Inner_Case_Weight" Then

                        ' check to see if inner case pack cube needs to be calced
                        SQLStr = "select ID, Inner_Case_Height, Inner_Case_Width, Inner_Case_Length, Inner_Case_Weight, Valid_Existing_SKU from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        cmd2 = New DBCommand(conn2)
                        Do While reader.Read()
                            If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then
                                he = DataHelper.SmartValues(reader("Inner_Case_Height"), "decimal", True, Decimal.MinValue, 4)
                                wi = DataHelper.SmartValues(reader("Inner_Case_Width"), "decimal", True, Decimal.MinValue, 4)
                                le = DataHelper.SmartValues(reader("Inner_Case_Length"), "decimal", True, Decimal.MinValue, 4)
                                we = DataHelper.SmartValues(reader("Inner_Case_Weight"), "decimal", True, Decimal.MinValue, 4)
                                If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                                    cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                                    cmd2.Parameters.Clear()
                                    cmd2.CommandText = "update [dbo].[SPD_Items] set Inner_Case_Pack_Cube = @value where [ID] = @rowID"
                                    cmd2.CommandType = CommandType.Text
                                    cmd2.Parameters.Add("@rowID", SqlDbType.BigInt).Value = DataHelper.SmartValues(reader("ID"), "long", False)
                                    cmd2.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(cresult, "decimal", True)
                                    cmd2.ExecuteNonQuery()
                                    audit.ClearFields()
                                    audit.AuditRecordID = DataHelper.SmartValues(reader("ID"), "long", False)
                                    audit.AddAuditField("Inner_Case_Pack_Cube", DataHelper.DBSmartValues(cresult, "decimal", True))
                                    itemDetail.SaveAuditRecord(audit, conn2)
                                    'retValue2 = CALLBACK_SEP & "InnerCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                                End If
                            End If

                        Loop
                        'cmd2.Connection.Dispose()
                        cmd2.Dispose()
                        cmd2 = Nothing
                        reader.Dispose()
                        reader = Nothing
                        cmd.Dispose()

                    ElseIf colName = "Master_Case_Height" Or colName = "Master_Case_Width" Or colName = "Master_Case_Length" Or colName = "Master_Case_Weight" Then

                        ' check to see if master case pack cube needs to be calced
                        SQLStr = "select ID, Master_Case_Height, Master_Case_Width, Master_Case_Length, Master_Case_Weight, Valid_Existing_SKU from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "integer", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim he As Decimal = Decimal.MinValue
                        Dim wi As Decimal = Decimal.MinValue
                        Dim le As Decimal = Decimal.MinValue
                        Dim we As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        cmd2 = New DBCommand(ApplicationHelper.GetAppConnection())
                        Do While reader.Read()
                            If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then
                                he = DataHelper.SmartValues(reader("Master_Case_Height"), "decimal", True, Decimal.MinValue, 4)
                                wi = DataHelper.SmartValues(reader("Master_Case_Width"), "decimal", True, Decimal.MinValue, 4)
                                le = DataHelper.SmartValues(reader("Master_Case_Length"), "decimal", True, Decimal.MinValue, 4)
                                we = DataHelper.SmartValues(reader("Master_Case_Weight"), "decimal", True, Decimal.MinValue, 4)
                                If (he >= 0 AndAlso wi >= 0 AndAlso le >= 0) Then
                                    cresult = CalculationHelper.CalculateItemCasePackCube(wi.ToString(), he.ToString(), le.ToString(), we.ToString())
                                    cmd2.Parameters.Clear()
                                    cmd2.CommandText = "update [dbo].[SPD_Items] set Master_Case_Pack_Cube = @value where [ID] = @rowID"
                                    cmd2.CommandType = CommandType.Text
                                    cmd2.Parameters.Add("@rowID", SqlDbType.BigInt).Value = DataHelper.SmartValues(reader("ID"), "long", False)
                                    cmd2.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(cresult, "decimal", True)
                                    cmd2.ExecuteNonQuery()
                                    audit.ClearFields()
                                    audit.AuditRecordID = DataHelper.SmartValues(reader("ID"), "long", False)
                                    audit.AddAuditField("Master_Case_Pack_Cube", DataHelper.DBSmartValues(cresult, "decimal", True))
                                    itemDetail.SaveAuditRecord(audit, conn2)
                                    'retValue2 = CALLBACK_SEP & "MasterCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                                End If
                            End If

                        Loop
                        cmd2.Connection.Dispose()
                        cmd2.Dispose()
                        cmd2 = Nothing
                        reader.Dispose()
                        reader = Nothing
                        cmd.Dispose()

                    ElseIf colName = "Hybrid_Lead_Time" Then

                        ' converstion date
                        SQLStr = "select ID, Hybrid_Lead_Time, Valid_Existing_SKU from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim leadTime As Integer = Integer.MinValue
                        Dim cresult As String = String.Empty
                        cmd2 = New DBCommand(ApplicationHelper.GetAppConnection())
                        Do While reader.Read()
                            If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then
                                leadTime = DataHelper.SmartValues(reader("Hybrid_Lead_Time"), "integer", True)
                                cresult = CalculationHelper.CalculateConversionDate(leadTime)
                                cmd2.Parameters.Clear()
                                cmd2.CommandText = "update [dbo].[SPD_Items] set Hybrid_Conversion_Date = @value where [ID] = @rowID"
                                cmd2.CommandType = CommandType.Text
                                cmd2.Parameters.Add("@rowID", SqlDbType.BigInt).Value = DataHelper.SmartValues(reader("ID"), "long", False)
                                cmd2.Parameters.Add("@value", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(cresult, "date", True)
                                cmd2.ExecuteNonQuery()
                                audit.ClearFields()
                                audit.AuditRecordID = DataHelper.SmartValues(reader("ID"), "long", False)
                                audit.AddAuditField("Hybrid_Conversion_Date", DataHelper.DBSmartValues(cresult, "date", True))
                                itemDetail.SaveAuditRecord(audit, conn2)
                                'retValue2 = CALLBACK_SEP & "HybridConversionDate" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                            End If

                        Loop
                        cmd2.Connection.Dispose()
                        cmd2.Dispose()
                        cmd2 = Nothing
                        reader.Dispose()
                        reader = Nothing
                        cmd.Dispose()

                    ElseIf colName = "Pre_Priced" Or colName = "Base_Retail" Then

                        ' retail
                        SQLStr = "select ID, Pre_Priced, Base_Retail, Alaska_Retail,Village_Craft_Retail,California_Retail,Test_Retail,Zero_Nine_Retail,Central_Retail, Retail9,Retail10,Retail11,Retail12,Retail13,RDPuertoRico, RDQuebec, Canada_Retail, Valid_Existing_SKU from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        reader = New DBReader(cmd)
                        reader.Open()
                        Dim prePriced As String = String.Empty
                        Dim baseRetail As Decimal = Decimal.MinValue
                        Dim alaskaRetail As Decimal = Decimal.MinValue
                        Dim retail9 As Decimal = Decimal.MinValue, _
                            retail10 As Decimal = Decimal.MinValue, _
                            retail12 As Decimal = Decimal.MinValue, _
                            retail11 As Decimal = Decimal.MinValue, _
                            retail13 As Decimal = Decimal.MinValue
                        Dim CentralRetail As Decimal = Decimal.MinValue
                        Dim VcraftRetail As Decimal = Decimal.MinValue
                        Dim CalifRetail As Decimal = Decimal.MinValue
                        Dim PuertoRicoRetail As Decimal = Decimal.MinValue
                        Dim ZeroNineRetail As Decimal = Decimal.MinValue
                        Dim TestRetail As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty
                        Dim cresultAlaska As String = String.Empty
                        Dim RDCanada As Decimal = Decimal.MinValue
                        Dim RDQuebec As Decimal = Decimal.MinValue

                        'Dim func As String
                        cmd2 = New DBCommand(ApplicationHelper.GetAppConnection())
                        Do While reader.Read()
                            If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then
                                prePriced = DataHelper.SmartValues(reader("Pre_Priced"), "string", True)
                                baseRetail = DataHelper.SmartValues(reader("Base_Retail"), "decimal", True)
                                alaskaRetail = DataHelper.SmartValues(reader("Alaska_Retail"), "decimal", True)
                                retail9 = DataHelper.SmartValues(reader("Retail9"), "decimal", True)
                                retail10 = DataHelper.SmartValues(reader("Retail10"), "decimal", True)
                                retail11 = DataHelper.SmartValues(reader("Retail11"), "decimal", True)
                                retail12 = DataHelper.SmartValues(reader("Retail12"), "decimal", True)
                                retail13 = DataHelper.SmartValues(reader("Retail13"), "decimal", True)
                                VcraftRetail = DataHelper.SmartValues(reader("Village_Craft_Retail"), "decimal", True)
                                CalifRetail = DataHelper.SmartValues(reader("California_Retail"), "decimal", True)
                                TestRetail = DataHelper.SmartValues(reader("Test_Retail"), "decimal", True)
                                ZeroNineRetail = DataHelper.SmartValues(reader("Zero_Nine_Retail"), "decimal", True)
                                CentralRetail = DataHelper.SmartValues(reader("Central_Retail"), "decimal", True)
                                PuertoRicoRetail = DataHelper.SmartValues(reader("RDPuertoRico"), "decimal", True)
                                RDCanada = DataHelper.SmartValues(reader("Canada_Retail"), "decimal", True)
                                RDQuebec = DataHelper.SmartValues(reader("RDQuebec"), "decimal", True)

                                'cresult = DataHelper.SmartValues(baseRetail, "formatcurrency", False, String.Empty, 2)
                                If baseRetail <> Decimal.MinValue Then
                                    cresult = DataHelper.SmartValues(baseRetail, "formatcurrency", False, String.Empty, 2)
                                    If retail9 = Decimal.MinValue Then retail9 = baseRetail
                                    If retail10 = Decimal.MinValue Then retail10 = baseRetail
                                    If retail11 = Decimal.MinValue Then retail11 = baseRetail
                                    If retail12 = Decimal.MinValue Then retail12 = baseRetail
                                    If retail13 = Decimal.MinValue Then retail13 = baseRetail
                                    If VcraftRetail = Decimal.MinValue Then VcraftRetail = baseRetail
                                    If CalifRetail = Decimal.MinValue Then CalifRetail = baseRetail
                                    If TestRetail = Decimal.MinValue Then TestRetail = baseRetail
                                    If ZeroNineRetail = Decimal.MinValue Then ZeroNineRetail = baseRetail
                                    If CentralRetail = Decimal.MinValue Then CentralRetail = baseRetail
                                    If PuertoRicoRetail = Decimal.MinValue Then PuertoRicoRetail = baseRetail

                                    If prePriced = "Y" Then
                                        alaskaRetail = baseRetail
                                        cresultAlaska = cresult
                                    Else
                                        ' price point lookup
                                        Dim objRecord As Models.PricePointRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupAlaskRetailFromBaseRetail(baseRetail)
                                        If Not objRecord Is Nothing AndAlso objRecord.DiffRetail <> Decimal.MinValue Then
                                            alaskaRetail = objRecord.DiffRetail
                                            cresultAlaska = DataHelper.SmartValues(alaskaRetail, "formatcurrency", False, String.Empty, 2)
                                        Else
                                            If alaskaRetail <> Decimal.MinValue Then
                                                cresultAlaska = DataHelper.SmartValues(alaskaRetail, "formatcurrency", False, String.Empty, 2)
                                            End If
                                        End If
                                    End If

                                    'logic changed by KH 2019-07-15 to treat canada fields like other zones
                                    If RDCanada = Decimal.MinValue Then RDCanada = baseRetail
                                    If RDQuebec = Decimal.MinValue Then RDQuebec = baseRetail
                                    'RDCanada = NovaLibra.Coral.Data.Michaels.ItemDetail.GetGridPrice(5, baseRetail)
                                    'RDCanada = IIf(RDCanada <= 0, Decimal.MinValue, RDCanada)
                                    'RDQuebec = RDCanada

                                    'Else
                                    '    RDCanada = baseRetail
                                    '    RDQuebec = baseRetail
                                End If
                                'func = CType(IIf(prePriced = "Y", IIf(colName = "Pre_Priced", "BaseRetailAPP", "BaseRetailA"), IIf(colName = "Pre_Priced", "BaseRetailPP", "BaseRetail")), String)
                                cmd2.Parameters.Clear()
                                cmd2.CommandText = "update [dbo].[SPD_Items] set Central_Retail = @CentralRetail, " & _
                                "Test_Retail = @TestRetail, " & _
                                "Alaska_Retail = @value2, " & _
                                "Zero_Nine_Retail = @ZeroNineRetail, " & _
                                "California_Retail = @CalifRetail, " & _
                                "Village_Craft_Retail = @VcraftRetail, " & _
                                "Retail9 = @retail9, " & _
                                "Retail10 = @retail10, " & _
                                "Retail11 = @retail11, " & _
                                "Retail12 = @retail12, " & _
                                "Retail13 = @retail13, " & _
                                "RDPuertoRico = @PuertoRicoRetail "

                                'logic modified to always include these columns. KH 2019-07-15
                                'Price Mgr
                                'If Not (batchWorkflowStageID = 5 AndAlso RDCanada <= 0) Then
                                cmd2.CommandText = cmd2.CommandText & " , " & _
                                    "Canada_Retail = @RDCanada, " & _
                                    "RDQuebec = @RDQuebec "
                                'End If

                                cmd2.CommandText = cmd2.CommandText & "where [ID] = @rowID"
                                cmd2.CommandType = CommandType.Text
                                cmd2.Parameters.Add("@rowID", SqlDbType.BigInt).Value = DataHelper.SmartValues(reader("ID"), "long", False)
                                cmd2.Parameters.Add("@value", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(baseRetail, "decimal", True)
                                cmd2.Parameters.Add("@value2", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(alaskaRetail, "decimal", True)
                                cmd2.Parameters.Add("@retail9", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail9, "decimal", True)
                                cmd2.Parameters.Add("@retail10", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail10, "decimal", True)
                                cmd2.Parameters.Add("@retail11", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail11, "decimal", True)
                                cmd2.Parameters.Add("@retail12", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail12, "decimal", True)
                                cmd2.Parameters.Add("@retail13", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(retail13, "decimal", True)
                                cmd2.Parameters.Add("@VcraftRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(VcraftRetail, "decimal", True)
                                cmd2.Parameters.Add("@ZeroNineRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(ZeroNineRetail, "decimal", True)
                                cmd2.Parameters.Add("@TestRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(TestRetail, "decimal", True)
                                cmd2.Parameters.Add("@CalifRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(CalifRetail, "decimal", True)
                                cmd2.Parameters.Add("@CentralRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(CentralRetail, "decimal", True)
                                cmd2.Parameters.Add("@PuertoRicoRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(PuertoRicoRetail, "decimal", True)

                                'logic modified to always include these columns. KH 2019-07-15
                                'If Not (batchWorkflowStageID = 5 AndAlso RDCanada <= 0) Then
                                cmd2.Parameters.Add("@RDCanada", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(RDCanada, "decimal", True)
                                cmd2.Parameters.Add("@RDQuebec", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(RDQuebec, "decimal", True)
                                'End If

                                cmd2.ExecuteNonQuery()
                                audit.ClearFields()
                                audit.AuditRecordID = DataHelper.SmartValues(reader("ID"), "long", False)
                                audit.AddAuditField("Central_Retail", baseRetail)
                                audit.AddAuditField("Test_Retail", baseRetail)
                                audit.AddAuditField("Alaska_Retail", alaskaRetail)
                                audit.AddAuditField("Zero_Nine_Retail", baseRetail)
                                audit.AddAuditField("California_Retail", baseRetail)
                                audit.AddAuditField("Village_Craft_Retail", baseRetail)
                                audit.AddAuditField("Retail9", retail9)
                                audit.AddAuditField("Retail10", retail10)
                                audit.AddAuditField("Retail11", retail11)
                                audit.AddAuditField("Retail12", retail12)
                                audit.AddAuditField("Retail13", retail13)
                                audit.AddAuditField("RDPuertoRico", PuertoRicoRetail)

                                'logic modified to always include these columns. KH 2019-07-15
                                'If Not (batchWorkflowStageID = 5 AndAlso RDCanada <= 0) Then
                                audit.AddAuditField("Canada_Retail", RDCanada)
                                audit.AddAuditField("RDQuebec", RDQuebec)
                                'End If

                                itemDetail.SaveAuditRecord(audit, conn2)
                                'retValue2 = CALLBACK_SEP & func & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                            End If

                        Loop

                        cmd2.Connection.Dispose()
                        cmd2.Dispose()
                        cmd2 = Nothing
                        reader.Dispose()
                        reader = Nothing
                        cmd.Dispose()

                    ElseIf colName = "Alaska_Retail" Then

                        ' alaska retail
                        ' NO UPDATE NEEDED SINCE JUST FORMATTING WOULD BE RETURNED !!!
                        cmd.Dispose()

                        'KH entire case for canada retail removed 2019-07-15

                        'ElseIf colName = "Canada_Retail" Then

                        '    ' retail
                        '    SQLStr = "select ID, Canada_Retail, RDQuebec, Valid_Existing_SKU  from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                        '    cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        '    cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        '    reader = New DBReader(cmd)
                        '    reader.Open()
                        '    Dim prePriced As String = String.Empty
                        '    Dim canadaRetail As Decimal = Decimal.MinValue
                        '    Dim quebecRetail As Decimal = Decimal.MinValue

                        '    'Dim func As String
                        '    cmd2 = New DBCommand(ApplicationHelper.GetAppConnection())
                        '    Do While reader.Read()
                        '        If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then
                        '            canadaRetail = DataHelper.SmartValues(reader("Canada_Retail"), "decimal", True)
                        '            quebecRetail = DataHelper.SmartValues(reader("RDQuebec"), "decimal", True)

                        '            If canadaRetail <> Decimal.MinValue Then
                        '                If quebecRetail = Decimal.MinValue Then quebecRetail = canadaRetail
                        '            End If
                        '            cmd2.Parameters.Clear()
                        '            cmd2.CommandText = "update [dbo].[SPD_Items] set RDQuebec = @QuebecRetail " & _
                        '            "WHERE [ID] = @rowID"
                        '            cmd2.CommandType = CommandType.Text
                        '            cmd2.Parameters.Add("@rowID", SqlDbType.BigInt).Value = DataHelper.SmartValues(reader("ID"), "long", False)
                        '            cmd2.Parameters.Add("@QuebecRetail", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(quebecRetail, "decimal", True)
                        '            cmd2.ExecuteNonQuery()
                        '            audit.ClearFields()
                        '            audit.AuditRecordID = DataHelper.SmartValues(reader("ID"), "long", False)
                        '            audit.AddAuditField("RDQuebec", quebecRetail)
                        '            itemDetail.SaveAuditRecord(audit, conn2)
                        '        End If
                        '    Loop

                        '    cmd2.Connection.Dispose()
                        '    cmd2.Dispose()
                        '    cmd2 = Nothing
                        '    reader.Dispose()
                        '    reader = Nothing
                        '    cmd.Dispose()

                    ElseIf colName = "Hazardous" Then

                        ' hazardous
                        'SQLStr = "select Hybrid_Lead_Time from [dbo].[SPD_Items] where [ID] = @rowID"

                        'cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        'reader = New DBReader(cmd)
                        'reader.Open()
                        'Dim leadTime As Integer = Integer.MinValue
                        Dim cresult As String = String.Empty
                        'If reader.Read() Then
                        '    leadTime = DataHelper.SmartValues(reader("Hybrid_Lead_Time"), "integer", True)
                        'End If
                        'reader.Dispose()
                        'reader = Nothing
                        Dim haz As String = dataText
                        If haz <> "Y" Then
                            SQLStr = "select ID, Valid_Existing_SKU from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                            cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                            cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                            reader = New DBReader(cmd)
                            reader.Open()
                            cmd2 = New DBCommand(conn2)
                            Do While reader.Read()
                                If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then
                                    cmd2.Parameters.Clear()
                                    cmd2.CommandText = "update [dbo].[SPD_Items] set Hazardous_Flammable = null, Hazardous_Container_Type = null, Hazardous_Container_Size = null, Hazardous_MSDS_UOM = null, Hazardous_Manufacturer_Name = null, Hazardous_Manufacturer_City = null, Hazardous_Manufacturer_State = null, Hazardous_Manufacturer_Phone = null, Hazardous_Manufacturer_Country = null where [ID] = @rowID"
                                    cmd2.CommandType = CommandType.Text
                                    cmd2.Parameters.Add("@rowID", SqlDbType.BigInt).Value = DataHelper.SmartValues(reader("ID"), "long", False)
                                    cmd2.ExecuteNonQuery()
                                    'retValue2 = CALLBACK_SEP & "Hazardous" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & String.Empty
                                    audit.ClearFields()
                                    audit.AuditRecordID = DataHelper.SmartValues(reader("ID"), "long", False)
                                    audit.AddAuditField("Hazardous_Flammable", String.Empty)
                                    audit.AddAuditField("Hazardous_Container_Type", String.Empty)
                                    audit.AddAuditField("Hazardous_Container_Size", String.Empty)
                                    audit.AddAuditField("Hazardous_MSDS_UOM", String.Empty)
                                    audit.AddAuditField("Hazardous_Manufacturer_Name", String.Empty)
                                    audit.AddAuditField("Hazardous_Manufacturer_City", String.Empty)
                                    audit.AddAuditField("Hazardous_Manufacturer_State", String.Empty)
                                    audit.AddAuditField("Hazardous_Manufacturer_Phone", String.Empty)
                                    audit.AddAuditField("Hazardous_Manufacturer_Country", String.Empty)
                                    itemDetail.SaveAuditRecord(audit, conn2)
                                End If

                            Loop
                            cmd2.Connection.Dispose()
                            cmd2.Dispose()
                            cmd2 = Nothing
                            reader.Dispose()
                            reader = Nothing
                            cmd.Dispose()
                        End If

                    ElseIf colName = "Country_Of_Origin_Name" Then

                        ' converstion date
                        'SQLStr = "select Country_Of_Origin_Name from [dbo].[SPD_Items] where [ID] = @rowID"
                        'cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        'cmd.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)
                        'reader = New DBReader(cmd)
                        'reader.Open()
                        Dim countryName As String = String.Empty
                        Dim countryCode As String = String.Empty
                        Dim cresult As String = String.Empty
                        'If reader.Read() Then
                        'countryName = DataHelper.SmartValues(reader("Country_Of_Origin_Name"), "string", True)
                        countryName = saveValue

                        'End If
                        'reader.Dispose()
                        'reader = Nothing
                        Dim country As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(countryName)
                        If Not country Is Nothing AndAlso country.CountryCode <> String.Empty AndAlso country.CountryName <> String.Empty Then
                            countryName = country.CountryName
                            countryCode = country.CountryCode
                            cresult = countryName
                        End If
                        'cmd.Parameters.Clear()
                        SQLStr = "update [dbo].[SPD_Items] set Country_Of_Origin_Name = @countryName, Country_Of_Origin = @countryCode where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        cmd.Parameters.Add("@countryName", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(countryName, "string", True)
                        cmd.Parameters.Add("@countryCode", SqlDbType.VarChar, 2).Value = DataHelper.DBSmartValues(countryCode, "string", True)
                        cmd.ExecuteNonQuery()
                        'retValue2 = CALLBACK_SEP & "CountryOfOriginName" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                        itemsaudit.RemoveAuditField("CountryOfOriginName")
                        itemsaudit.RemoveAuditField("CountryOfOrigin")
                        itemsaudit.RemoveAuditField("Country_Of_Origin_Name")
                        itemsaudit.RemoveAuditField("Country_Of_Origin")
                        itemsaudit.AddAuditField("Country_Of_Origin_Name", countryName)
                        itemsaudit.AddAuditField("Country_Of_Origin", countryCode)
                        cmd.Dispose()

                    ElseIf colName = "Like_Item_SKU" Then

                        ' like item sku
                        Dim itemSKU As String = dataText
                        Dim resultItemDesc As String = String.Empty
                        Dim baseRetail As Decimal = Decimal.MinValue
                        Dim resultBaseRetail As String = String.Empty
                        If itemSKU <> String.Empty Then
                            Dim objRecord As Models.ItemMasterRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupItemMaster(itemSKU)
                            If Not objRecord Is Nothing AndAlso (objRecord.ItemDescription <> String.Empty Or objRecord.BaseRetail <> Decimal.MinValue) Then
                                resultItemDesc = objRecord.ItemDescription
                                If objRecord.BaseRetail <> Decimal.MinValue Then
                                    baseRetail = objRecord.BaseRetail
                                    resultBaseRetail = DataHelper.SmartValues(objRecord.BaseRetail, "formatnumber", True, String.Empty, 2)
                                End If
                            End If
                            objRecord = Nothing
                        End If

                        SQLStr = String.Empty
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Clear()
                        cmd.CommandText = "update [dbo].[SPD_Items] set Like_Item_Description = @value, Like_Item_Retail = @value2 where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID"
                        cmd.CommandType = CommandType.Text
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.Int).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        cmd.Parameters.Add("@value", SqlDbType.VarChar, 255).Value = resultItemDesc
                        cmd.Parameters.Add("@value2", SqlDbType.Money).Value = DataHelper.DBSmartValues(baseRetail, "decimal", True)
                        cmd.ExecuteNonQuery()
                        'retValue2 = CALLBACK_SEP & "LikeItemSKU" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & resultItemDesc & "__" & resultBaseRetail
                        itemsaudit.AddAuditField("Like_Item_Description", resultItemDesc)
                        itemsaudit.AddAuditField("Like_Item_Retail", DataHelper.DBSmartValues(baseRetail, "decimal", True))
                        cmd.Dispose()

                    ElseIf colName = "Like_Item_Unit_Store_Month" Or colName = "Annual_Regular_Unit_Forecast" Then
                        Dim objMichaelsDet As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                        'Dim item1 As Models.ItemRecord '= objMichaelsDet.GetRecord(itemID)
                        Dim itemHeader1 As Models.ItemHeaderRecord = objMichaelsDet.GetItemHeaderRecord(itemHeaderID)
                        saveValue = DataHelper.SmartValues(saveValue, "decimal", True, Decimal.MinValue, 2)
                        'Dim tempholder As Decimal

                        'SQLStr = "select ID from [dbo].[SPD_Items] where [Item_Header_ID] = @itemHeaderID"
                        'cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        'cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        'reader = New DBReader(cmd)
                        'reader.Open()
                        'Do While reader.Read()

                        'item1 = objMichaelsDet.GetRecord(reader("ID"))
                        'If item1 IsNot Nothing Then

                        SQLStr = String.Empty
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Clear()
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)

                        If colName = "Like_Item_Unit_Store_Month" Then
                            If itemHeader1.StoreTotal <> Integer.MinValue Then
                                'item1.LikeItemUnitStoreMonth = saveValue
                                cmd.Parameters.Add("@value1", SqlDbType.Decimal).Value = saveValue
                                If saveValue <> Decimal.MinValue Then
                                    'tempholder = itemHeader1.StoreTotal * item1.LikeItemUnitStoreMonth * 13
                                    'item1.AnnualRegularUnitForecast = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 0)
                                    'If item1.BaseRetail <> Decimal.MinValue Then
                                    '    tempholder = item1.BaseRetail * item1.AnnualRegularUnitForecast
                                    '    item1.AnnualRegRetailSales = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                                    'Else
                                    '    item1.AnnualRegRetailSales = Decimal.MinValue
                                    'End If
                                    SQLStr = "update [dbo].[SPD_Items] set Like_Item_Unit_Store_Month = @value1" & _
                                        ", Annual_Regular_Unit_Forecast = convert(decimal(18,6), convert(bigint, (@storeTotal * @value1 * 13)))" & _
                                        ", Annual_Reg_Retail_Sales = ( [Base_Retail] * convert(decimal(18,6), convert(bigint, (@storeTotal * @value1 * 13))) )" & _
                                        " where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID and [Base_Retail] is not null; "

                                    SQLStr = SQLStr & "update [dbo].[SPD_Items] set Like_Item_Unit_Store_Month = @value1" & _
                                        ", Annual_Regular_Unit_Forecast = convert(decimal(18,6), convert(bigint, (@storeTotal * @value1 * 13)))" & _
                                        ", Annual_Reg_Retail_Sales = null" & _
                                        " where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID and [Base_Retail] is null;"

                                    cmd.Parameters.Add("@storeTotal", SqlDbType.Int).Value = DataHelper.SmartValues(itemHeader1.StoreTotal, "integer", False)
                                Else
                                    'item1.AnnualRegularUnitForecast = saveValue
                                    'item1.AnnualRegRetailSales = saveValue
                                    SQLStr = "update [dbo].[SPD_Items] set Like_Item_Unit_Store_Month = @value1" & _
                                            ", Annual_Regular_Unit_Forecast = @value1" & _
                                            ", Annual_Reg_Retail_Sales = @value1" & _
                                            " where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID; "
                                End If
                            End If
                            'retValue2 = CALLBACK_SEP & "LikeItemUnitStoreMonth" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & item1.AnnualRegularUnitForecast & "__" & item1.AnnualRegRetailSales
                        Else '"Annual_Regular_Unit_Forecast"

                            cmd.Parameters.Add("@value1", SqlDbType.Decimal).Value = DataHelper.SmartValues(saveValue, "decimal", True, Decimal.MinValue, 0)
                            If saveValue <> Decimal.MinValue And itemHeader1.StoreTotal <> Integer.MinValue And itemHeader1.StoreTotal <> 0 Then

                                'item1.AnnualRegularUnitForecast = DataHelper.SmartValues(saveValue, "decimal", True, Decimal.MinValue, 0)
                                'tempholder = item1.AnnualRegularUnitForecast / itemHeader1.StoreTotal / 13
                                'item1.LikeItemUnitStoreMonth = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                                'If item1.BaseRetail <> Decimal.MinValue Then
                                '    tempholder = item1.BaseRetail * item1.AnnualRegularUnitForecast
                                '    item1.AnnualRegRetailSales = DataHelper.SmartValues(tempholder, "decimal", True, Decimal.MinValue, 2)
                                'Else
                                '    item1.AnnualRegRetailSales = Decimal.MinValue
                                'End If

                                SQLStr = "update [dbo].[SPD_Items] set Annual_Regular_Unit_Forecast = @value1" & _
                                    ", Like_Item_Unit_Store_Month = (@value1 / convert(decimal(18,6), @storeTotal) / 13.00)" & _
                                    ", Annual_Reg_Retail_Sales = ( [Base_Retail] * @value1 )" & _
                                    " where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID and [Base_Retail] is not null; "

                                SQLStr = SQLStr & "update [dbo].[SPD_Items] set Annual_Regular_Unit_Forecast = @value1" & _
                                    ", Like_Item_Unit_Store_Month = (@value1 / convert(decimal(18,6), @storeTotal) / 13.00)" & _
                                    ", Annual_Reg_Retail_Sales = null" & _
                                    " where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID and [Base_Retail] is null;"

                                cmd.Parameters.Add("@storeTotal", SqlDbType.Int).Value = DataHelper.SmartValues(itemHeader1.StoreTotal, "integer", False)

                            Else
                                'item1.AnnualRegularUnitForecast = DataHelper.SmartValues(saveValue, "decimal", True, Decimal.MinValue, 0)
                                'item1.LikeItemUnitStoreMonth = 0
                                'item1.AnnualRegRetailSales = 0

                                SQLStr = "update [dbo].[SPD_Items] set Annual_Regular_Unit_Forecast = @value1" & _
                                            ", Like_Item_Unit_Store_Month = 0.0" & _
                                            ", Annual_Reg_Retail_Sales = 0.0" & _
                                            " where ISNULL(Valid_Existing_SKU, 0) = 0 and [Item_Header_ID] = @itemHeaderID; "
                            End If
                            'retValue2 = CALLBACK_SEP & "AnnualRegularUnitForecast" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & item1.LikeItemUnitStoreMonth & "__" & item1.AnnualRegRetailSales
                        End If


                        cmd.CommandText = SQLStr
                        cmd.CommandType = CommandType.Text
                        cmd.ExecuteNonQuery()
                        cmd.Dispose()

                        'tempholder = objMichaelsDet.SaveRecord(item1, userID)

                        'End If


                        'Loop
                        'reader.Dispose()
                        'reader = Nothing
                        'cmd.Dispose()
                    ElseIf colName = "Pack_Item_Indicator" OrElse colName = "US_Cost" OrElse colName = "Canada_Cost" Then

                        ' check to see if total cost values need to be calced
                        SQLStr = "select i.[ID], i.Pack_Item_Indicator, i.US_Cost, i.Canada_Cost, i.Valid_Existing_SKU, ih.Item_Type, ih.Add_Unit_Cost from [dbo].[SPD_Items] i inner join [dbo].[SPD_Item_Headers] ih on i.[Item_Header_ID] = ih.[ID] where i.[Item_Header_ID] = @itemHeaderID"
                        cmd = New DBCommand(conn, SQLStr, CommandType.Text)
                        cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = DataHelper.SmartValues(itemHeaderID, "long", False)
                        reader = New DBReader(cmd)
                        reader.Open()

                        Dim rowID As Integer
                        Dim it As String = String.Empty
                        Dim auc As Decimal = Decimal.MinValue
                        Dim pii As String = String.Empty
                        Dim uscost As Decimal = Decimal.MinValue
                        Dim ccost As Decimal = Decimal.MinValue
                        Dim tuscost As Decimal = Decimal.MinValue
                        Dim tccost As Decimal = Decimal.MinValue
                        cmd2 = New DBCommand(conn2)
                        Do While reader.Read()
                            If Not DataHelper.SmartValues(reader("Valid_Existing_SKU"), "boolean", False) Then

                                rowID = DataHelper.SmartValues(reader("ID"), "integer", False)
                                it = DataHelper.SmartValues(reader("Item_Type"), "string", True)
                                auc = DataHelper.SmartValues(reader("Add_Unit_Cost"), "decimal", True)
                                pii = DataHelper.SmartValues(reader("Pack_Item_Indicator"), "string", True)
                                uscost = DataHelper.SmartValues(reader("US_Cost"), "decimal", True)
                                ccost = DataHelper.SmartValues(reader("Canada_Cost"), "decimal", True)

                                cmd2.Parameters.Clear()
                                cmd2.CommandType = CommandType.Text
                                cmd2.Parameters.Add("@rowID", SqlDbType.Int).Value = DataHelper.SmartValues(rowID, "integer", False)

                                audit.ClearFields()
                                audit.AuditRecordID = rowID

                                If colName = "US_Cost" Then
                                    tuscost = CalculationHelper.CalculateTotalCost(it, auc, pii, uscost)
                                    cmd2.CommandText = "update [dbo].[SPD_Items] set Total_US_Cost = @value1 where [ID] = @rowID"
                                    cmd2.Parameters.Add("@value1", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tuscost, "decimal", True)
                                    audit.AddAuditField("Total_US_Cost", DataHelper.SmartValuesAsString(tuscost, "decimal"))
                                ElseIf colName = "Canada_Cost" Then
                                    tccost = CalculationHelper.CalculateTotalCost(it, auc, pii, ccost)
                                    cmd2.CommandText = "update [dbo].[SPD_Items] set Total_Canada_Cost = @value2 where [ID] = @rowID"
                                    cmd2.Parameters.Add("@value2", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tccost, "decimal", True)
                                    audit.AddAuditField("Total_Canada_Cost", DataHelper.SmartValuesAsString(tccost, "decimal"))
                                Else
                                    tuscost = CalculationHelper.CalculateTotalCost(it, auc, pii, uscost)
                                    tccost = CalculationHelper.CalculateTotalCost(it, auc, pii, ccost)
                                    cmd2.CommandText = "update [dbo].[SPD_Items] set Total_US_Cost = @value1, Total_Canada_Cost = @value2 where [ID] = @rowID"
                                    cmd2.Parameters.Add("@value1", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tuscost, "decimal", True)
                                    cmd2.Parameters.Add("@value2", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(tccost, "decimal", True)
                                    audit.AddAuditField("Total_US_Cost", DataHelper.SmartValuesAsString(tuscost, "decimal"))
                                    audit.AddAuditField("Total_Canada_Cost", DataHelper.SmartValuesAsString(tccost, "decimal"))
                                End If

                                cmd2.ExecuteNonQuery()
                                itemDetail.SaveAuditRecord(audit, conn2)

                            End If

                        Loop
                        cmd2.Connection.Dispose()
                        cmd2.Dispose()
                        cmd2 = Nothing
                        reader.Dispose()
                        reader = Nothing

                    End If
                    ' end special field functions (after save)

                    ' clean up
                    cmd = Nothing
                    conn.Dispose()
                    conn = Nothing

                    retValue = "200" & CALLBACK_SEP & "1" & retValue2
                End If

                itemDetail.SaveAuditRecordForItemHeader(itemsaudit, itemHeaderID)

                ' check to see if need to calculate parent cost of a pack batch
                Dim col As String = colName.Replace("_", "")
                If col = "QtyInPack" Or colName = "USCost" Or colName = "CanadaCost" Then
                    Dim itemHeader As Models.ItemHeaderRecord = itemDetail.GetItemHeaderRecord(DataHelper.SmartValues(itemHeaderID, "long", False))
                    ItemHelper.CalculateDomesticDPBatchParent(itemHeader, True, False)
                    itemHeader = Nothing
                End If
                'Master_Case_Weight
                If col = "MasterCaseWeight" Then
                    Dim itemHeader As Models.ItemHeaderRecord = itemDetail.GetItemHeaderRecord(DataHelper.SmartValues(itemHeaderID, "long", False))
                    ItemHelper.CalculateDomesticDPBatchParent(itemHeader, False, True)
                    itemHeader = Nothing
                End If


                ' Validate all records
                ' ----------------------------------------------------------------------
                ValidateEntireItemList(itemHeaderID)
                ' ----------------------------------------------------------------------
            End If


        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            retValue = "200" & CALLBACK_SEP & "0"
        Catch ex As Exception
            Logger.LogError(ex)
            retValue = "200" & CALLBACK_SEP & "0"
        Finally
            If Not reader Is Nothing Then
                reader.Dispose()
                reader = Nothing
            End If
            If Not cmd Is Nothing Then
                cmd.Dispose()
                cmd = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
            If Not conn2 Is Nothing Then
                conn2.Dispose()
                conn2 = Nothing
            End If
        End Try

        itemDetail = Nothing
        itemsaudit = Nothing

        Return retValue
    End Function

    Private Function ValidateGrid(ByRef itemHeader As Models.ItemHeaderRecord) As Integer
        Dim validFlag As Integer = 0
        Dim hasError As Boolean = False
        Dim hasWarning As Boolean = False
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        Try
            'Dim itemHeader As Models.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(DataHelper.SmartValues(hid.Value, "long", False))
            If Not itemHeader Is Nothing Then
                Dim itemList As Models.ItemList = objMichaels.GetList(itemHeader.ID, 0, 0, String.Empty, userID)
                Dim vrs As ArrayList = ValidationHelper.ValidateItemList(itemList.ListRecords, itemHeader)
                validFlag = 0
                For Each vr As Models.ValidationRecord In vrs
                    If Not hasError AndAlso vr.ErrorExists(ValidationRuleSeverityType.TypeError) Then hasError = True
                    If Not hasWarning AndAlso vr.ErrorExists(ValidationRuleSeverityType.TypeWarning) Then hasWarning = True
                    If hasError AndAlso hasWarning Then Exit For
                Next
                If hasError Then validFlag += 1
                If hasWarning Then validFlag += 2
                Do While vrs.Count > 0
                    vrs.RemoveAt(0)
                Loop
                vrs = Nothing
                itemList.ClearList()
                itemList = Nothing
                'itemHeader = Nothing
            Else
                validFlag = -1
            End If
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            validFlag = -1
        Catch ex As Exception
            Logger.LogError(ex)
            validFlag = -1
        Finally
            objMichaels = Nothing
        End Try

        Return validFlag
    End Function

    Private Function CallbackValidateGrid() As String
        Dim retValue As String = String.Empty
        Dim success As String = "0"
        Dim validFlag As String = "0"
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        Try
            Dim itemHeader As Models.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(DataHelper.SmartValues(hid.Value, "long", False))
            If Not itemHeader Is Nothing Then
                Dim itemList As Models.ItemList = objMichaels.GetList(itemHeader.ID, 0, 0, String.Empty, userID)
                Dim vrs As ArrayList = ValidationHelper.ValidateItemList(itemList.ListRecords, itemHeader)
                validFlag = "1"
                For Each vr As Models.ValidationRecord In vrs
                    If Not vr.IsValid Then
                        validFlag = "0"
                        Exit For
                    End If
                Next
                Do While vrs.Count > 0
                    vrs.RemoveAt(0)
                Loop
                vrs = Nothing
                itemList.ClearList()
                itemList = Nothing
                itemHeader = Nothing
                success = "1"
            Else
                success = "0"
            End If

            retValue = "300" & CALLBACK_SEP & success & CALLBACK_SEP & validFlag
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            retValue = "300" & CALLBACK_SEP & "0"
        Catch ex As Exception
            Logger.LogError(ex)
            retValue = "300" & CALLBACK_SEP & "0"
        Finally
            objMichaels = Nothing
        End Try

        Return retValue
    End Function

#End Region

    Private Property DefaultEnabledColumns() As String
        Get
            Dim o As Object = Session("DefaultEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("DefaultEnabledColumns") = value
        End Set
    End Property

    Private Property UserEnabledColumns() As String
        Get
            Dim o As Object = Session("UserEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("UserEnabledColumns") = value
        End Set
    End Property

    Private Property UserStartupFilter() As Integer
        Get
            Dim o As Object = Session("UserStartupFilter")
            If Not o Is Nothing And IsNumeric(o) Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session("UserStartupFilter") = value
        End Set
    End Property

    Private Property CustomFieldStartID() As Integer
        Get
            Dim o As Object = Session("CustomFieldStartID")
            If Not o Is Nothing And IsNumeric(o) Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session("CustomFieldStartID") = value
        End Set
    End Property

    Private Property CustomFieldRef() As String
        Get
            Dim o As Object = Session("CustomFieldRef")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("CustomFieldRef") = value
        End Set
    End Property



    Protected Sub SaveSettings()
        ' save settings
        Dim SQLStr As String = ""
        Dim conn As DBConnection = Nothing
        Dim cmd As DBCommand = Nothing
        Try

            conn = ApplicationHelper.GetAppConnection()
            conn.Open()
            cmd = New DBCommand(conn, "", CommandType.Text)
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

        Catch ex As Exception
            If conn IsNot Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
            If cmd IsNot Nothing Then
                cmd.Dispose()
                cmd = Nothing
            End If
        End Try
        ' redirect
        'Response.Redirect("detailsettingsclose.aspx")
        'Response.Redirect("detailitems.aspx?hid=" & hid.Value)
    End Sub

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

    Protected Sub SetDefaultPackSort()
        ' init vars
        Dim sb As New StringBuilder("")
        ' setup xml
        sb.Append("<Sort>")
        sb.Append("<Parameter SortID=""1"" intColOrdinal=""5"" intDirection=""1"" />")
        sb.Append("<Parameter SortID=""2"" intColOrdinal=""1"" intDirection=""0"" />")
        sb.Append("</Sort>")
        ' set advanced sort
        ItemGrid.CurrentAdvancedSort = sb.ToString()
    End Sub

    Protected Sub ValidateEntireItemList(ByVal itemHeaderID As String)
        ' Validate all records
        ' ----------------------------------------------------------------------
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        Dim itemHeader As Models.ItemHeaderRecord = Nothing
        Dim headerID As Long = DataHelper.SmartValues(itemHeaderID, "Long")
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()

        Dim gridItemList As Models.ItemList = Nothing
        Dim vrBatch As Models.ValidationRecord = Nothing
        Dim valRecords As ArrayList = Nothing

        itemHeader = objMichaels.GetItemHeaderRecord(headerID)
        If Not itemHeader Is Nothing Then
            Dim strXML As String = GetDefaultGridSortAndFilterXML()
            Dim firstRow As Integer = 1
            Dim pageSize As Integer = objMichaels.GetListCount(headerID, strXML, userID) + 1
            gridItemList = objMichaels.GetList(headerID, firstRow, pageSize, strXML, userID)

            If ValidationHelper.SkipBatchValidation(itemHeader.BatchStageType) Then
                vrBatch = New Models.ValidationRecord(itemHeader.BatchID, Models.ItemRecordType.Batch)
            Else
                vrBatch = ValidationHelper.ValidateBatch(itemHeader.BatchID, NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic)
            End If

            valRecords = ValidationHelper.ValidateItemList(gridItemList.ListRecords, itemHeader)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecords, userID)
        End If
        ' clean up
        vrBatch = Nothing
        If Not valRecords Is Nothing Then
            Do While valRecords.Count > 0
                valRecords.RemoveAt(0)
            Loop
            valRecords = Nothing
        End If
        gridItemList = Nothing
        itemHeader = Nothing
        ' ----------------------------------------------------------------------
    End Sub

    Public Function RenderValidationControltoHTML(ByRef vrBatch As Models.ValidationRecord, ByVal hasErrors As Boolean, ByVal hasWarnings As Boolean) As String
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
        If vrBatch IsNot Nothing AndAlso (vrBatch.ErrorExists() OrElse vrBatch.ErrorExists(ValidationRuleSeverityType.TypeWarning)) Then
            showSummary = True
            ValidationHelper.AddValidationSummaryErrors(valDisplay, vrBatch)
        End If
        If hasWarnings Then showSummary = True : ValidationHelper.LoadValidationSummary(valDisplay, "There are validation warnings in the item list.")
        If hasErrors Then showSummary = True : ValidationHelper.LoadValidationSummary(valDisplay, "There are validation errors in the item list.")
        ' render the control
        If showSummary Then
            controlString = FormHelper.RenderControl(valDisplay)
        End If
        ' clean up
        valDisplay = Nothing
        ' return control string
        Return controlString
    End Function

End Class
