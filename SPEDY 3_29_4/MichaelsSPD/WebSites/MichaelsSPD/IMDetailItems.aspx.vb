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

Partial Class IMDetailItems
    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler

#Region "Attributes and Properties"

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

        'Dim itemHeaderID As Long = 0
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

        If Not Me.IsCallback Then

            SecurityCheckRedirect()

            'NAK 8/5/2014:  Removing this, because I think it is unneeded?
            ' make sure __doPostBack is generated
            'ClientScript.GetPostBackEventReference(Me, String.Empty)

            ' callback
            Dim cbReference As String
            cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", "ReceiveServerData", "context")
            Dim callbackScript As String = "function CallServer(arg, context)" & "{" & cbReference & "; }"
            Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "CallServer", callbackScript, True)

            ' **********
            ' * batch *
            ' **********

            ' Load the Batch. If IM Cost Change then show Effective Date
            If Session(cBATCHID) Is Nothing OrElse DataHelper.SmartValues(Session(cBATCHID), "long", False) <= 0 Then
                Response.Redirect("default.aspx")
            End If
            BatchID = DataHelper.SmartValues(Session(cBATCHID), "integer", False)
            Dim objData As New Data.BatchData ' NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
            Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(BatchID)
            objData = Nothing

            Dim itemUCount As Integer = 0
            Dim itemNVCount As Integer = 0
            Dim itemVCount As Integer = 0
            Dim iucnt1 As Integer = 0, iucnt2 As Integer = 0
            Dim invcnt1 As Integer = 0, invcnt2 As Integer = 0
            Dim ivcnt1 As Integer = 0, ivcnt2 As Integer = 0

            If Not IsPostBack Then
                ' load record if update mode
                If BatchID > 0 Then
                    hid.Value = BatchID.ToString()
                End If ' Request("hid")
            Else
                If Request.Params("__EVENTTARGET") <> "" And Request.Params("__EVENTTARGET") = "settings" Then
                    SaveSettings()
                End If
            End If ' IsPostBack

            If Not batchDetail Is Nothing Then

                ' VALIDATE USER
                ValidateUser(batchDetail.ID, batchDetail.WorkflowStageType)
                If NoUserAccess Then Response.Redirect("default.aspx")

                ' Vendor Check
                VendorCheckRedirect(batchDetail.VendorNumber)

                hid.Value = batchDetail.ID.ToString()

                ' Effective Date
                txtEffectiveDate.Text = DataHelper.SmartValues(batchDetail.EffectiveDate, "formatdate", False)

                lblMaintType.Text = "Item Maintenance"
                If batchDetail.ID > 0 Then
                    batch.Text = batchDetail.ID.ToString()
                End If

                Select Case batchDetail.PackType.ToUpper
                    Case "R", ""
                        lblPackType.Text = "Regular"
                    Case "DP"
                        lblPackType.Text = "Displayer Pack"
                    Case "SB"
                        lblPackType.Text = "Sellable Bundle"
                    Case "D"
                        lblPackType.Text = "Displayer"
                End Select

                If batchDetail.FinelineDeptID > 0 Then
                    batchDept.Text = batchDetail.FinelineDeptID.ToString()
                End If
                If batchDetail.VendorName <> "" Then
                    batchVendorName.Text = batchDetail.VendorName
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
                ' get the validation counts
                Dim batchCounts As Models.BatchValidCounts = Data.MaintItemMasterData.GetBatchValidCounts(batchDetail.ID)
                itemUCount = batchCounts.ItemUnknownCount
                itemNVCount = batchCounts.ItemNotValidCount
                itemVCount = batchCounts.ItemValidCount

                ' SETUP DEFAULT SORT
                If Not IsPostBack Then
                    If ItemGrid.CurrentAdvancedSort = String.Empty AndAlso ItemGrid.CurrentSortColumn = 1 Then
                        If batchDetail.IsPack() Then
                            Me.SetDefaultPackSort()
                        End If
                    End If
                    If Not batchDetail.IsPack() AndAlso (ItemGrid.CurrentAdvancedSort.Contains("11") Or ItemGrid.CurrentSortColumn = 11) Then
                        Me.SetDefaultNonPackSort()
                    End If
                End If


                ' pack changes
                If batchDetail.IsPack() Then
                    Dim pchanges As Models.PackChanges = Data.MaintItemMasterData.GetPackChanges(batchDetail.ID)
                    If pchanges.HasChanges() Then
                        packChangesContainer.Visible = True
                        If pchanges.SKUsAdded() Then
                            Me.SKUsAdded.Visible = True
                            Me.SKUsAdded.Text = "<span class=""SKUsAddedLabel"">SKUs Added</span>: &nbsp;" & pchanges.SKUsAddedToPack
                        Else
                            Me.SKUsAdded.Visible = False
                        End If
                        If pchanges.SKUsDeleted() Then
                            Me.SKUsDeleted.Visible = True
                            Me.SKUsDeleted.Text = "<span class=""SKUsDeletedLabel"">SKUs Deleted</span>: &nbsp;" & pchanges.SKUsDeletedFromPack
                        Else
                            Me.SKUsDeleted.Visible = False
                        End If
                        If pchanges.SKUsDeleted() AndAlso pchanges.SKUsAdded() Then
                            Me.packChangesSep.Visible = True
                        Else
                            Me.packChangesSep.Visible = False
                        End If

                    Else
                        packChangesContainer.Visible = False
                    End If
                Else
                    packChangesContainer.Visible = False
                End If
            Else
                Response.Redirect("default.aspx")
            End If ' Not itemHeader Is Nothing



            ' **********
            ' * detail *
            ' **********

            Dim gridItemList As Models.ItemMaintItemDetailRecordList = Nothing
            Dim changes As Models.IMTableChanges = Nothing
            changes = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(batchDetail.ID)
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

            Dim objMichaels As New Data.MaintItemMasterData
            Dim valRecords As ArrayList = Nothing
            Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = objMichaels.GetFieldLocking(AppHelper.GetUserID(), Models.MetadataTable.vwItemMaintItemDetail, AppHelper.GetVendorID(), batchDetail.WorkflowStageID, True)
            objMichaels = Nothing

            ' *********************************************
            ' * CHECK FOR RECORDS WITH VALIDATION UNKNOWN *
            ' *********************************************
            'Dim valUnknownCount As Integer = objMichaels.GetItemValidationUnknownCount(itemHeaderID)
            Dim valUnknownCount As Integer = itemUCount
            If valUnknownCount > 0 Then
                'gridItemList = objMichaels.GetList(itemHeaderID, 0, 0, String.Empty, userID)
                gridItemList = Data.MaintItemMasterData.GetItemList(batchDetail.ID, 0, 0, String.Empty, userID)
                ' get validation counts for current paged set >> changed to the entire set !!
                valRecords = ValidationHelper.ValidateItemMaintItemList(gridItemList.ListRecords, changes, batchDetail)
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

            'ItemGrid.GridID = "2"
            ItemGrid.HighlightRow = True
            ItemGrid.ShowSearch = True
            ItemGrid.AutoResizeGrid = True
            ItemGrid.ShowAdvancedSort = True
            ItemGrid.ShowAdvancedFilter = True
            If batchDetail.IsPack() Then
                ItemGrid.ItemAddText = "Add Component Items"
            Else
                ItemGrid.ItemAddText = "Add Items"
            End If
            ItemGrid.ItemAddURL = "IMAddRecords.aspx?bid=" & batchDetail.ID
            If batchDetail.BatchTypeID = 1 Then
                ItemGrid.ItemEditURL = "IMDomesticForm.aspx?bid=" & batchDetail.ID
                ItemViewURL = "IMDomesticForm.aspx?bid=" & batchDetail.ID
                ItemGrid.ItemDeleteURL = "IMDetailDelete.aspx?t=d&bid=" & batchDetail.ID
            ElseIf batchDetail.BatchTypeID = 2 Then
                ItemGrid.ItemEditURL = "IMImportForm.aspx?bid=" & batchDetail.ID
                ItemViewURL = "IMImportForm.aspx?bid=" & batchDetail.ID
                ItemGrid.ItemDeleteURL = "IMDetailDelete.aspx?t=i&bid=" & batchDetail.ID
            End If
            ItemGrid.ShowContentMenu = True
            ItemGrid.AllowAjaxEdit = True
            ItemGrid.DefaultPageSize = 15
            ItemGrid.FieldNameUnderscore = True
            ItemGrid.PagingCookie = True
            ItemGrid.AllowSetAll = True
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
                ItemGrid.ItemViewURL = ItemGrid.ItemEditURL
                ItemGrid.ItemAddURL = ""
                ItemGrid.ItemEditURL = ""
                ItemGrid.ItemDeleteURL = ""
                ItemGrid.AllowAjaxEdit = False
            End If

            ItemGrid.ImagePath = "images/grid/"

            ' SPECIAL ITEMS
            Dim theBatchID As String
            Dim dateNow As Date = Now()
            Dim fileName As String
            If UserCanEdit Then
                If batchDetail.IsPack() Then
                    'ItemGrid.AddSpecialValue("QtyInPack", String.Empty, "", "{{HEADER_LINK}}")
                    ItemGrid.AddSpecialValue("ItemCost", String.Empty, "", "{{HEADER_LINK}}")
                    ItemGrid.AddSpecialValue("ProductCost", String.Empty, "", "{{HEADER_LINK}}")
                End If

                ItemGrid.AddSpecialValue("SKU", String.Empty,
                    "{{VALUE}}<br />" &
                    "<a href=""#"" onclick=""openItemEditorWindow({{ID}});"">Edit</a>",
                    "all")
                ' TaxWizard
                'ItemGrid.AddSpecialValue("TaxWizard", String.Empty, "openTaxWizardSA('" & batchDetail.ID & "', '');", "{{HEADER_LINK}}")
                'ItemGrid.AddSpecialValue("TaxWizard", True, "<a href=""#"" onclick=""openTaxWizard('{{ID}}'); return false;""><img id=""taxwiz{{ID}}"" src=""images/checkbox_true.gif"" border=""0"" alt="""" /></a>")
                'ItemGrid.AddSpecialValue("TaxWizard", False, "<a href=""#"" onclick=""openTaxWizard('{{ID}}'); return false;""><img id=""taxwiz{{ID}}"" src=""images/checkbox_false.gif"" border=""0"" alt="""" /></a>")
                ' AdditionalUPCs
                ItemGrid.AddSpecialValue("AdditionalUPCs", String.Empty,
                    "0 &nbsp;" &
                    "",
                    "<0")
                ItemGrid.AddSpecialValue("AdditionalUPCs", String.Empty,
                    "{{VALUE}} &nbsp;" &
                    "",
                    ">=0")

                ' ---------------------------------------------------------
                ' ImageID
                ' ---------------------------------------------------------
                ItemGrid.AddSpecialValue("ImageID", String.Empty,
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value=""{{VALUE}}"" />" &
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small_on.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "<input type=""button"" id=""B_UpdateImage{{ID}}"" value=""Update"" class=""formButton"" onclick=""openUploadItemMaintFile('X', '{{ID}}', 'IMG', '1');"" />" &
                    "<input type=""button"" id=""B_DeleteImage{{ID}}"" value=""Delete"" class=""formButton"" onclick=""return deleteImage({{ID}});"" />" &
                    "&nbsp;",
                    ">0")
                ItemGrid.AddSpecialValue("ImageID", String.Empty,
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value="""" />" &
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "<input type=""button"" id=""B_UpdateImage{{ID}}"" value=""Upload"" class=""formButton"" onclick=""openUploadItemMaintFile('X', '{{ID}}', 'IMG', '1');"" />" &
                    "<input type=""button"" id=""B_DeleteImage{{ID}}"" value=""Delete"" class=""formButton"" disabled=""disabled"" onclick=""return deleteImage({{ID}});"" />" &
                    "&nbsp;",
                    "<=0")
                ' ***** CHANGES *****
                ' ---------------------------------------------------------
                ' ---------------------------------------------------------
                ItemGrid.AddSpecialValue("ImageID", String.Empty,
                    "<input type=""hidden"" id=""ImageID{{ID}}_ORIG"" value=""{{VALUE}}"" />" &
                    "<img id=""I_Image{{ID}}_ORIG"" onclick=""showImage('{{ID}}', true);"" src=""images/app_icons/icon_jpg_small_on.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "&nbsp;",
                    ">0", True)
                ItemGrid.AddSpecialValue("ImageID", String.Empty,
                    "<input type=""hidden"" id=""ImageID{{ID}}_ORIG"" value="""" />" &
                    "<img id=""I_Image{{ID}}_ORIG"" onclick=""showImage('{{ID}}', true);"" src=""images/app_icons/icon_jpg_small.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "&nbsp;",
                    "<=0", True)

                ' ---------------------------------------------------------
                ' MSDSID
                ' ---------------------------------------------------------
                If Not batchDetail Is Nothing Then
                    theBatchID = "_" & batchDetail.ID.ToString()
                Else
                    theBatchID = String.Empty
                End If
                fileName = "item_" & theBatchID & "_" & dateNow.ToString("yyyyMMdd") & ".pdf"
                ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value=""{{VALUE}}"" />" &
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "<input type=""button"" id=""B_UpdateMSDS{{ID}}"" value=""Update"" class=""formButton"" onclick=""openUploadItemMaintFile('X', '{{ID}}', 'MSDS', '1');"" />" &
                    "<input type=""button"" id=""B_DeleteMSDS{{ID}}"" value=""Delete"" class=""formButton"" onclick=""return deleteMSDS({{ID}});"" />" &
                    "&nbsp;",
                    ">0")
                ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value="""" />" &
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small_off.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "<input type=""button"" id=""B_UpdateMSDS{{ID}}"" value=""Upload"" class=""formButton"" onclick=""openUploadItemMaintFile('X', '{{ID}}', 'MSDS', '1');"" />" &
                    "<input type=""button"" id=""B_DeleteMSDS{{ID}}"" value=""Delete"" class=""formButton"" disabled=""disabled"" onclick=""return deleteMSDS({{ID}});"" />" &
                    "&nbsp;",
                    "<=0")
                ' ***** CHANGES *****
                ' ---------------------------------------------------------
                ' ---------------------------------------------------------
                ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                    "<input type=""hidden"" id=""MSDSID{{ID}}_ORIG"" value=""{{VALUE}}"" />" &
                    "<img id=""I_MSDS{{ID}}_ORIG"" onclick=""showMSDS('{{ID}}', '" & fileName & "', true);"" src=""images/app_icons/icon_pdf_small.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "&nbsp;",
                    ">0", True)
                ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                    "<input type=""hidden"" id=""MSDSID{{ID}}_ORIG"" value="""" />" &
                    "<img id=""I_MSDS{{ID}}_ORIG"" onclick=""showMSDS('{{ID}}', '" & fileName & "', true);"" src=""images/app_icons/icon_pdf_small_off.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "&nbsp;",
                    "<=0", True)
            Else
                ' ****************
                ' *** READONLY ***
                ' ****************
                ItemGrid.AddSpecialValue("SKU", String.Empty,
                    "{{VALUE}}<br />" &
                    "<a href=""#"" onclick=""openItemViewerWindow({{ID}});"">View</a>",
                    "all")
                ' AdditionalUPCCount
                ItemGrid.AddSpecialValue("AdditionalUPCs", String.Empty,
                    "0 &nbsp;",
                    "<0")
                ItemGrid.AddSpecialValue("AdditionalUPCs", String.Empty,
                    "{{VALUE}} &nbsp; ",
                    ">=0")
                ' ImageID
                ItemGrid.AddSpecialValue("ImageID", String.Empty,
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value=""{{VALUE}}"" />" &
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small_on.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "",
                    ">0")
                ItemGrid.AddSpecialValue("ImageID", String.Empty,
                    "<input type=""hidden"" id=""ImageID{{ID}}"" value="""" />" &
                    "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "",
                    "<=0")
                ' MSDSID
                If Not batchDetail Is Nothing Then
                    theBatchID = "_" & batchDetail.ID.ToString()
                Else
                    theBatchID = String.Empty
                End If
                fileName = "item_" & theBatchID & "_" & dateNow.ToString("yyyyMMdd") & ".pdf"
                ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value=""{{VALUE}}"" />" &
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "",
                    ">0")
                ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                    "<input type=""hidden"" id=""MSDSID{{ID}}"" value="""" />" &
                    "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small_off.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                    "",
                    "<=0")
            End If


            ' SETUP COLUMNS
            ' *********************************
            Dim reader As DBReader = Nothing
            sql = "select c.ID" &
                ", isnull(c.Column_Name, '') as Column_Name" &
                ", c.Column_Ordinal" &
                ", c.Column_Generic_Type" &
                ", isnull(c.Column_Format, 'string') as Column_Format" &
                ", isnull(c.Column_Format_String, '') as Column_Format_String" &
                ", c.Fixed_Column" &
                ", c.Allow_Sort" &
                ", c.Allow_Filter" &
                ", c.Allow_AjaxEdit" &
                ", c.Default_UserDisplay" &
                ", c.Display_Name " &
                ", c.Max_Length " &
                ", isnull(mc.Treat_Empty_As_Zero, 0) as [TEAZ]" &
                " from ColumnDisplayName c" &
                "   left outer join SPD_Metadata_Column mc on mc.Metadata_Table_ID = 11 and mc.Column_Name = c.Column_Name" &
                " where c.[Display] = 1 and ISNULL(c.Workflow_ID, 1) = " & ItemGrid.GridID.ToString() &
                " and (c.Column_Type = 'X' or c.Column_Type = '" & IIf(batchDetail.BatchTypeID = 1, "D", "I") & "')" &
                " order by c.Column_Ordinal"
            Try
                reader = New DBReader(ApplicationHelper.GetAppConnection())
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                Do While reader.Read()
                    If ColumnEnabledByUser(reader("ID"), DataHelper.SmartValues(reader("Default_UserDisplay"), "Boolean")) Then
                        objGridItem = ItemGrid.AddGridItem(reader("Column_Ordinal"), reader("Display_Name"), reader("Column_Name").ToString().Replace("_", ""), reader("Column_Generic_Type"), reader("Column_Format"))
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


            Dim twgi As GridItem
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
            If batchDetail.WorkflowStageType <> Models.WorkflowStageType.Tax And batchDetail.WorkflowStageType <> Models.WorkflowStageType.DBC Then
                twgi = ItemGrid.GetGridItem("TaxUDA")
                If Not twgi Is Nothing Then twgi.AllowAjaxEdit = False
                twgi = ItemGrid.GetGridItem("TaxValueUDA")
                If Not twgi Is Nothing Then twgi.AllowAjaxEdit = False
            End If

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
            If Not batchDetail.IsPack() Then
                ItemGrid.RemoveGridItem("PackItemIndicator")
                ItemGrid.RemoveGridItem("QtyInPack")
                'twgi = ItemGrid.GetGridItem("DisplayerCost")
                'If twgi IsNot Nothing Then twgi.AllowAjaxEdit = False
                ItemGrid.RemoveGridItem("DisplayerCost")
            End If



            ' ******************************
            ' get data
            ' ******************************
            ' set the record count (which causes the SetupPaging to fire and thus setup the grid)
            Dim strXML As String = GetGridSortAndFilterXML()
            ItemGrid.RecordCount = Data.MaintItemMasterData.GetItemListCount(BatchID, strXML, userID)

            ' get data
            Dim firstRow As Integer = DataHelper.SmartValues(ItemGrid.CurrentPage, "integer", False)
            If firstRow <= 0 Then firstRow = 1
            Dim pageSize As Integer = ItemGrid.CurrentPageSize

            ' get list
            gridItemList = Data.MaintItemMasterData.GetItemList(BatchID, firstRow, pageSize, strXML, userID)

            ' lock the DisplayerCost (additional cost per item) for non-pack-parent rows
            Dim str As String
            For Each imitem As Models.ItemMaintItemDetailFormRecord In gridItemList.ListRecords
                If imitem.IsPackParent() Then
                    ItemGrid.DisableDelete(imitem.ID)
                End If
                If batchDetail.IsDomesticPack() Then
                    str = FormHelper.GetValueWithChanges(imitem.PackItemIndicator, changes.GetRow(imitem.ID, True), "PackItemIndicator", "string").ToString()
                    If str.Length > 2 Then str = str.Substring(0, 2)
                    str = str.ToUpper().Replace("-", "")
                    If Not (str = "D" Or str = "DP" Or str = "SB") Then
                        twgi = ItemGrid.GetGridItem("DisplayerCost")
                        If twgi IsNot Nothing Then ItemGrid.LockCell(imitem.ID, twgi.ID)
                    End If
                End If

                'Piggyback on for loop to visually change "A"gent to "MB" Merch Burden
                If imitem.VendorOrAgent.ToUpper = "A" Then
                    imitem.VendorOrAgent = "MB"
                End If
            Next

            twgi = Nothing

            ' get change records
            ' >> ALREADY GOT'EM
            'changes = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(BatchID)

            ' get custom fields
            '' ''Me.CustomFields = NovaLibra.Coral.BusinessFacade.SystemCustomFields.GetCustomFields(Me.RecordType, gridItemList.GetRecordIDs, True)
            ' ******************************
            ' end get data
            ' ******************************
            ' *********************************
            ' Setup custom field columns
            ' *********************************
            '' ''ItemGrid.CustomFields = Me.CustomFields
            '' ''Dim nextID As Integer = ItemGrid.ItemCollection.GetNextGridItemID()
            '' ''Me.CustomFieldStartID = nextID
            '' ''Dim fieldIDs As String = String.Empty
            '' ''For Each field As NovaLibra.Coral.SystemFrameworks.CustomField In Me.CustomFields.Fields
            '' ''    ' add custom field to grid
            '' ''    objGridItem = ItemGrid.AddGridItem(nextID, field.FieldName, field.ID.ToString(), field.GetGenericType(), field.GetFormat())
            '' ''    objGridItem.FieldFormatString = "{{CUSTOM}}"
            '' ''    objGridItem.FixedColumn = False
            '' ''    objGridItem.SortColumn = False
            '' ''    objGridItem.FilterColumn = False
            '' ''    objGridItem.AllowAjaxEdit = True
            '' ''    objGridItem.MaxLength = DataHelper.SmartValues(field.FieldLimit, "integer", False)
            '' ''    ' associated custom field id with the grid id
            '' ''    If fieldIDs <> String.Empty Then fieldIDs = fieldIDs & ","
            '' ''    fieldIDs = fieldIDs & nextID.ToString() & "," & field.ID.ToString()
            '' ''    ' increment the next id
            '' ''    nextID += 1
            '' ''Next
            ' '' '' save the field references
            '' ''Me.CustomFieldRef = fieldIDs
            ' *********************************
            ' *********************************
            ' excel export
            ' *********************************
            'If BatchID > 0 Then
            '    linkExcel.Visible = True
            '    linkExcel.NavigateUrl = "IMDetailExport.aspx?bid=" & GetBatchID() & "&sort=" & Server.UrlEncode(GetGridSortAndFilterXML())
            '    sep1.Visible = True
            'Else
            '    linkExcel.Visible = False
            '    sep1.Visible = False
            'End If
            linkExcel.Visible = False
            sep1.Visible = False


            ' excel batch output
            ' set return address for xls batch export
            Session("_XLS_BATCH_EXPORT_RETURN_") = "IMDetailItems.aspx"

            Select Case batchDetail.BatchTypeID
                Case 1 'domestic
                    linkExportBatchMaintFormat.Visible = True
                    linkExportBatchImportFormat.Visible = False
                Case 2 'import
                    linkExportBatchMaintFormat.Visible = True
                    linkExportBatchImportFormat.Visible = True
            End Select

            ' *********************************
            ' *********************************

            ' ******************************
            ' field locking
            ' ******************************
            If Not IsAdmin() Then

                For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns

                    Select Case UCase(col.Permission)
                        Case "V"        ' View Column only

                            Select Case col.ColumnName
                                'Case "SKU"
                                '    ItemGrid.ClearSpecialValue("SKU")
                                '    ItemGrid.AddSpecialValue("SKU", String.Empty, _
                                '        "{{VALUE}}<br />" & _
                                '        "<a href=""#"" onclick=""openItemViewWindow({{ID}});"">View</a>", _
                                '        "all")

                                Case "CountryOfOriginName"
                                    twgi = ItemGrid.GetGridItem("CountryOfOriginName")
                                    If Not twgi Is Nothing Then
                                        twgi.AllowAjaxEdit = False
                                    End If

                                Case "MSDSID"
                                    ItemGrid.ClearSpecialValue("MSDSID")
                                    If Not batchDetail Is Nothing Then
                                        theBatchID = "_" & batchDetail.ID.ToString()
                                    Else
                                        theBatchID = String.Empty
                                    End If
                                    fileName = "item_" & theBatchID & "_" & dateNow.ToString("yyyyMMdd") & ".pdf"
                                    ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                                        "<input type=""hidden"" id=""MSDSID{{ID}}"" value=""{{VALUE}}"" />" &
                                        "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                                        "",
                                        ">0")
                                    ItemGrid.AddSpecialValue("MSDSID", String.Empty,
                                        "<input type=""hidden"" id=""MSDSID{{ID}}"" value="""" />" &
                                        "<img id=""I_MSDS{{ID}}"" onclick=""showMSDS('{{ID}}', '" & fileName & "');"" src=""images/app_icons/icon_pdf_small_off.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                                        "",
                                        "<=0")

                                Case "ImageID"
                                    ' ImageID
                                    ItemGrid.ClearSpecialValue("ImageID")
                                    ItemGrid.AddSpecialValue("ImageID", String.Empty,
                                        "<input type=""hidden"" id=""ImageID{{ID}}"" value=""{{VALUE}}"" />" &
                                        "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small_on.gif?id={{VALUE}}"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                                        "",
                                        ">0")
                                    ItemGrid.AddSpecialValue("ImageID", String.Empty,
                                        "<input type=""hidden"" id=""ImageID{{ID}}"" value="""" />" &
                                        "<img id=""I_Image{{ID}}"" onclick=""showImage('{{ID}}');"" src=""images/app_icons/icon_jpg_small.gif"" style=""border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;"" />&nbsp;" &
                                        "",
                                        "<=0")

                                Case Else   ' Find Grid item by column name w/o special handling
                                    twgi = ItemGrid.GetGridItem(col.ColumnName.Replace("_", ""))
                                    If Not twgi Is Nothing Then
                                        twgi.AllowAjaxEdit = False
                                    End If
                            End Select

                        Case "N"    ' Hide the column by removing the grid item from the collection
                            Select Case col.ColumnName
                                Case "SKU"
                                    ItemGrid.RemoveGridItem("SKU")
                                Case "AdditionalUPCs"
                                    ItemGrid.RemoveGridItem("AdditionalUPCs")
                                Case "CountryOfOriginName"
                                    ItemGrid.RemoveGridItem("CountryOfOriginName")
                                Case "MSDSID"
                                    ItemGrid.RemoveGridItem("MSDSID")
                                Case "ImageID"
                                    ItemGrid.RemoveGridItem("ImageID")

                                Case Else   ' Remove the item from the Grid so it won't be rendered
                                    ItemGrid.RemoveGridItem(col.ColumnName.Replace("_", ""))
                            End Select ' Col
                        Case Else   ' Edit permission

                    End Select      ' Permission

                Next
            End If

            ' ******************************
            ' end field locking
            ' ******************************


            ' get validation counts for current paged set
            For Each item As Models.ItemMaintItemDetailFormRecord In gridItemList.ListRecords
                    'item.BatchStageID = itemHeader.BatchStageID
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
                ItemGrid.ChangesDataSource = changes
                ItemGrid.DataBind()


            ' --------------------------------------------------------------------------
            ' validation
            ' --------------------------------------------------------------------------

            valRecords = ValidationHelper.ValidateItemMaintItemList(gridItemList.ListRecords, changes, batchDetail)

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
                'Dim vrec As Models.ValidationRecord



                If ValidationHelper.SkipBatchValidation(batchDetail.WorkflowStageType) Then
                    vrBatch = ValidationHelper.ValidateItemMaintBatch(batchDetail, (Not UserCanEdit), True)
                    bHasBatchErrors = vrBatch.ErrorExists()
                    bHasBatchWarnings = vrBatch.ErrorExists(ValidationRuleSeverityType.TypeWarning)
                Else
                    vrBatch = ValidationHelper.ValidateItemMaintBatch(batchDetail, (Not UserCanEdit))
                    bHasBatchErrors = vrBatch.ErrorExists()
                    bHasBatchWarnings = vrBatch.ErrorExists(ValidationRuleSeverityType.TypeWarning)
                    If UserCanEdit Then
                        NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
                    End If
                End If

                If bHasBatchErrors Or bHasErrors Then
                    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid, True)
                Else
                    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid, True)
                End If
                If bHasBatchErrors Or bHasBatchWarnings Or bHasErrors Or bHasWarnings Then
                    ValidationHelper.SetupValidationSummary(validationDisplay)
                    If vrBatch.HasAnyError() Then
                        ValidationHelper.AddValidationSummaryErrors(validationDisplay, vrBatch)
                    End If
                    If bHasWarnings Then ValidationHelper.LoadValidationSummary(validationDisplay, "There are validation warnings in the item list.")
                    If bHasErrors Then ValidationHelper.LoadValidationSummary(validationDisplay, "There are validation errors in the item list.")
                End If
                CheckForStartupScripts(valRecords)

                ' clean up
                vrBatch = Nothing
                'vrec = Nothing
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
                    SQLStr = "SELECT COUNT(*) AS RecordCount FROM ColumnDisplayName WHERE ISNULL(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & " AND Display = 1 AND Is_Custom = 0 AND Allow_Filter = 1" &
                    " and (Column_Type = 'X' or Column_Type = '" & IIf(batchDetail.BatchTypeID = 1, "D", "I") & "')"
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
                    SQLStr = "SELECT * FROM ColumnDisplayName WHERE ISNULL(Workflow_ID, 1) = " & ItemGrid.GridID.ToString() & " AND Display = 1 AND Is_Custom = 0 AND Allow_Filter = 1" &
                    " and (Column_Type = 'X' or Column_Type = '" & IIf(batchDetail.BatchTypeID = 1, "D", "I") & "')" &
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
                'objMichaels = Nothing
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
                ' validate entire list
                Return CallbackValidateGrid()
            Case "DELETEIMAGE", "DELETEMSDS"
                If str.Length < 3 Then
                    Return str(0) & CALLBACK_SEP & "0"
                End If
                Dim thisItemID As Integer = DataHelper.SmartValues(str(1), "long", True)
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
                Dim bRet As Boolean = Data.MaintItemMasterData.SaveItemMaintChanges(rowChanges, userID)
                rowChanges = Nothing
                itemRec = Nothing
                'Dim objFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()
                'Dim bRet As Boolean = objFile.DeleteRecord(Models.ItemTypeString.ITEM_TYPE_DOMESTIC, thisItemID, fileID)
                'objFile = Nothing
                ' audit
                ''Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                ''Dim audit As New Models.AuditRecord()
                ''audit.SetupAudit(Models.MetadataTable.vwItemMaintItemDetail, thisItemID, Models.AuditRecordType.Update, CInt(Session("UserID")))
                ''If str(0) = "DELETEMSDS" Then
                ''    audit.AddAuditField("MSDSID", String.Empty)
                ''Else
                ''    audit.AddAuditField("ImageID", String.Empty)
                ''End If
                ''objFA.SaveAuditRecord(audit)
                ''objFA = Nothing
                ''audit = Nothing
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
            'Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
            'Dim item As Models.ItemRecord = objMichaels.GetRecord(itemID)
            'Dim itemHeader As Models.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(item.ItemHeaderID)
            Dim item As Models.ItemMaintItemDetailFormRecord = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(itemID, AppHelper.GetVendorID)
            Dim rowChanges As Models.IMRowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(itemID)
            Dim objData As New Data.BatchData()
            Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(item.BatchID)
            objData = Nothing
            Debug.Assert(item IsNot Nothing)
            Debug.Assert(batchDetail IsNot Nothing)

            Dim sbFields As New StringBuilder("")
            Dim id As Long
            'objMichaels = Nothing
            Dim vr As Models.ValidationRecord

            ' ***** do not validation if "Waiting for SKU" or "Completed" *****
            If ValidationHelper.SkipValidation(batchDetail.WorkflowStageType) Then
                vr = New Models.ValidationRecord(item.ID, Models.ItemRecordType.ItemMaintItem)
            Else
                vr = ValidationHelper.ValidateItemMaintItem(item, rowChanges, batchDetail, (Not UserCanEdit))
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
        Dim retValue3 As String = String.Empty
        Dim retValue4 As String = CALLBACK_SEP & " " & CALLBACK_SEP & " "
        Dim retvalue5 As String = CALLBACK_SEP & " "
        Dim SQLStr As String = String.Empty

        Dim strValue As String
        Dim reader As DBReader = Nothing
        Dim cmd As DBCommand = Nothing
        Dim conn As DBConnection = Nothing
        Dim colReader As DBReader = Nothing
        Dim itemID As Long = DataHelper.SmartValues(rowID, "long")
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")

        Dim audit As Models.AuditRecord

        Dim colID As Integer = DataHelper.SmartValues(columnID, "integer", False)
        Dim startID As Integer = Me.CustomFieldStartID
        Dim isCustomField As Boolean = False
        If colID >= startID AndAlso startID > 0 Then isCustomField = True

        Dim itemRec As Models.ItemMaintItemDetailFormRecord = Data.MaintItemMasterData.GetItemMaintItemDetailRecord(itemID, AppHelper.GetVendorID())
        Dim saveRowChanges As New Models.IMRowChanges(itemID)
        Dim cellChange As Models.IMCellChangeRecord
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
            'itemDetail = New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
            'audit = New Models.AuditRecord(Models.MetadataTable.Items, itemID, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)
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
                    Dim saveValue As Object, originalValue As Object
                    Dim strType As String = reader("Column_Generic_Type")
                    ' close reader
                    cmd.Dispose()
                    cmd = Nothing
                    reader.Dispose()
                    reader = Nothing
                    ' setup the cell change record
                    'cellChange = New Models.IMCellChangeRecord()
                    'cellChange.FieldName = colName

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
                    ElseIf batchDetail.IsPack() Then
                        If itemRec.IsPackParent() AndAlso colName = "QtyInPack" Then
                            skipSave = True
                            retValue2 = CALLBACK_SEP & "QtyInPack" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP
                            loadFlashValue = "QtyInPack"
                        End If
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
                        ' CalculateEstLandedCostAndStore

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
                        If mclength <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "mclength", RoundDimesionsString(DataHelper.SmartValues(mclength, "formatnumber4", False)))
                        If mcwidth <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "mcwidth", RoundDimesionsString(DataHelper.SmartValues(mcwidth, "formatnumber4", False)))
                        If mcheight <> Decimal.MinValue Then CalculationHelper.SetXMLValue(xmlout, "mcheight", RoundDimesionsString(DataHelper.SmartValues(mcheight, "formatnumber4", False)))
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
                    If colName = "QtyInPack" Or colName = "ProductCost" Or colName = "ItemCost" Then
                        If Not itemRec.IsPackParent() Then
                            If ItemMaintHelper.CalculateDPBatchParent(batchDetail.ID, True, False) Then
                                ' refresh the grid...
                                retvalue5 = CALLBACK_SEP & "1"
                            End If
                        End If
                    End If

                    ' check to see if need to calculate parent master weight of a pack batch
                    If colName = "MasterCaseWeight" Then
                        If Not itemRec.IsPackParent() Then
                            If ItemMaintHelper.CalculateDPBatchParent(batchDetail.ID, False, True) Then
                                ' refresh the grid...
                                retvalue5 = CALLBACK_SEP & "1"
                            End If
                        End If
                    End If

                    If colName.ToUpper = "PLIENGLISH" Or colName.ToUpper = "PLIFRENCH" Or colName.ToUpper = "PLISPANISH" Then
                        ' refresh the grid...
                        retvalue5 = CALLBACK_SEP & "1"
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
                    'Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
                    'Dim item As Models.ItemRecord = objMichaels.GetRecord(itemID)
                    'Dim itemHeader As Models.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(item.ItemHeaderID)
                    Dim sbFields As New StringBuilder("")
                    Dim id As Long
                    'objMichaels = Nothing
                    Dim vrBatch As Models.ValidationRecord
                    Dim vr As Models.ValidationRecord
                    Dim itemsErrorFlag As Integer = Me.ValidateGrid(batchDetail)
                    Dim hasErrors As Boolean = IIf(itemsErrorFlag = 1 Or itemsErrorFlag = 3, True, False)
                    Dim hasWarnings As Boolean = IIf(itemsErrorFlag = 2 Or itemsErrorFlag = 3, True, False)

                    If ValidationHelper.SkipBatchValidation(batchDetail.WorkflowStageType) Then
                        vrBatch = New Models.ValidationRecord(batchDetail.ID, Models.ItemRecordType.Batch)
                    Else
                        vrBatch = ValidationHelper.ValidateItemMaintBatch(batchDetail, (Not UserCanEdit))
                        ' save validation 
                        NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
                    End If

                    If ValidationHelper.SkipValidation(batchDetail.WorkflowStageType) Then
                        vr = New Models.ValidationRecord(itemRec.ID, Models.ItemRecordType.ItemMaintItem)
                    Else
                        vr = ValidationHelper.ValidateItemMaintItem(itemRec, rowChanges, batchDetail, (Not UserCanEdit))
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
                    retValue3 = retValue3 & CALLBACK_SEP & IIf((vrBatch.IsValid And Not hasErrors), "1", "0")
                    retValue3 = retValue3 & CALLBACK_SEP & RenderValidationControltoHTML(vrBatch, hasErrors, hasWarnings)
                    giarr = Nothing

                    ' clean up
                    saveRowChanges = Nothing
                    cellChange = Nothing
                    rowChanges = Nothing

                    itemRec = Nothing
                    conn.Dispose()
                    conn = Nothing

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
        'itemDetail = Nothing
        table = Nothing
        md = Nothing
        batchDetail = Nothing

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
        Me.BatchID = DataHelper.SmartValues(itemHeaderID, "long", False)

        Dim itemDetail As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim itemsaudit As New Models.AuditRecord(Models.MetadataTable.Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)
        Dim audit As New Models.AuditRecord(Models.MetadataTable.Items, 0, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, userID)

        Dim colID As Integer = DataHelper.SmartValues(columnID, "integer", False)
        Dim startID As Integer = Me.CustomFieldStartID
        Dim isCustomField As Boolean = False
        If colID >= startID AndAlso startID > 0 Then isCustomField = True

        Dim itemRec As Models.ItemMaintItemDetailFormRecord
        Dim itemRecList As Models.ItemMaintItemDetailRecordList = Data.MaintItemMasterData.GetItemList(BatchID, 1, Integer.MaxValue, "", userID)
        Dim i As Integer
        Dim saveTableChanges As New Models.IMTableChanges()
        Dim saveRowChanges As Models.IMRowChanges
        Dim cellChange As Models.IMCellChangeRecord
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
            If isCustomField Then
                '' ''Dim saved As Boolean = False
                '' ''Dim fieldID As Integer = DataHelper.SmartValues(columnName, "integer", False)
                '' ''Dim itemID As Long
                '' ''Dim custFields As NovaLibra.Coral.SystemFrameworks.CustomFields
                '' ''reader = New DBReader(ApplicationConnectionStrings.AppConnectionString)
                '' ''reader.CommandText = "select ID from SPD_Items where Item_Header_ID = " & itemHeaderID
                '' ''reader.CommandType = CommandType.Text
                '' ''reader.Open()
                '' ''Do While reader.Read()
                '' ''    itemID = DataHelper.SmartValues(reader("ID"), "long", False)
                '' ''    custFields = NovaLibra.Coral.BusinessFacade.SystemCustomFields.GetCustomFields(Me.RecordType, itemID, True)
                '' ''    custFields.AddValue(itemID, fieldID, dataText)
                '' ''    saved = NovaLibra.Coral.BusinessFacade.SystemCustomFields.SaveCustomFieldValues(custFields)
                '' ''Loop
                '' ''reader.Dispose()
                '' ''reader = Nothing
                '' ''If saved Then
                '' ''    retValue = "200" & CALLBACK_SEP & "1" & retValue2
                '' ''Else
                '' ''    retValue = "200" & CALLBACK_SEP & "0"
                '' ''End If
            Else
                Dim colName As String
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
                    Dim saveValue As Object, originalValue As Object
                    Dim strType As String = reader("Column_Generic_Type")

                    ' special field functions (before save)
                    If colName = "PrimaryUPC" Then
                        If IsNumeric(dataText) AndAlso DataHelper.SmartValues(dataText, "long", False) > 0 Then
                            dataText = dataText.Trim()
                            Do While dataText.Length < 14
                                dataText = "0" & dataText
                            Loop
                            'retValue2 = CALLBACK_SEP & "VendorUPC" & CALLBACK_SEP & String.Format("gce_{0}_{1}", "{0}", columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "VendorStyleNum" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            'retValue2 = CALLBACK_SEP & "VendorStyleNum" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "PlanogramName" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            'retValue2 = CALLBACK_SEP & "PlanogramName" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "ItemDesc" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            'retValue2 = CALLBACK_SEP & "ItemDesc" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
                        End If
                    ElseIf colName = "ShippingPoint" Then
                        strValue = DataHelper.SmartValues(dataText.Trim(), "stringrsu", True)
                        If strValue <> dataText Then
                            dataText = strValue
                            'retValue2 = CALLBACK_SEP & "ItemDesc" & CALLBACK_SEP & String.Format("gce_{0}_{1}", rowID, columnID) & CALLBACK_SEP & dataText
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

                    ' ------------------------------------------------------------------------------------------------------------------

                    saveValue = DataHelper.SmartValues(dataText, strType, True)

                    'audit.AddAuditField(colName, saveValue)

                    Dim skipSave As Boolean = False
                    Dim skipSaveRec As Boolean
                    If colName = WebConstants.cNEWPRIMARY OrElse colName = WebConstants.cNEWPRIMARYCODE Then '"CountryOfOriginName"
                        skipSave = True
                    End If

                    If Not skipSave Then
                        For i = 0 To itemRecList.RecordCount - 1
                            itemRec = itemRecList.Item(i)

                            skipSaveRec = False
                            If batchDetail.IsPack() Then
                                If (itemRec.IsPackParent() AndAlso colName = "QtyInPack") Or _
                                    (Not itemRec.IsPackParent() AndAlso itemRec.VendorType = Models.ItemType.Domestic AndAlso colName = "DisplayerCost") Then
                                    skipSaveRec = True
                                End If
                            End If

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

                    ' ------------------------------------------------------------------------------------------------------------------

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

                            'cellChange = New Models.IMCellChangeRecord("EachCaseCube")
                            'cellChange.FieldValue = cresult
                            'cellChange.HasChanged = IIf(DataHelper.SmartValues(itemRec.EachCaseCube, "decimal", True) = DataHelper.SmartValues(cresult, "decimal", True), False, True)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.EachCaseCube, "EachCaseCube", "decimal", cresult))

                            'retValue2 = CALLBACK_SEP & "EachCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
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

                            'cellChange = New Models.IMCellChangeRecord("InnerCaseCube")
                            'cellChange.FieldValue = cresult
                            'cellChange.HasChanged = IIf(DataHelper.SmartValues(itemRec.InnerCaseCube, "decimal", True) = DataHelper.SmartValues(cresult, "decimal", True), False, True)
                            saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.InnerCaseCube, "InnerCaseCube", "decimal", cresult))

                            'retValue2 = CALLBACK_SEP & "InnerCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
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

                        'Dim returnXML As String = String.Empty
                        'Dim xmlout As New XmlDocument

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

                                    'cellChange = New Models.IMCellChangeRecord("MasterCaseCube")
                                    'cellChange.FieldValue = cresult
                                    'cellChange.HasChanged = IIf(DataHelper.SmartValues(itemRec.MasterCaseCube, "decimal", True) = DataHelper.SmartValues(cresult, "decimal", True), False, True)
                                    saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.MasterCaseCube, "MasterCaseCube", "decimal", cresult))

                                    'retValue2 = CALLBACK_SEP & "MasterCasePackCube" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                                ElseIf (colName = "DisplayerCost" OrElse colName = "PackItemIndicator" OrElse colName = "ItemCost") Then

                                    it = FormHelper.GetValueWithChanges(itemRec.ItemType, rowChanges, "ItemType", "string")
                                    auc = FormHelper.GetValueWithChanges(itemRec.DisplayerCost, rowChanges, "DisplayerCost", "decimal")
                                    pii = FormHelper.GetValueWithChanges(itemRec.PackItemIndicator, rowChanges, "PackItemIndicator", "string")
                                    icost = FormHelper.GetValueWithChanges(itemRec.ItemCost, rowChanges, "ItemCost", "decimal")

                                    ticost = CalculationHelper.CalculateIMTotalCost(it, auc, pii, icost)
                                    saveTableChanges.GetRow(itemRec.ID, True).Add(FormHelper.CreateChangeRecord(itemRec.FOBShippingPoint, "FOBShippingPoint", "decimal", ticost))

                                    'retValue2 = CALLBACK_SEP & returnToken & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult
                                End If

                            ElseIf itemRec.VendorType = Models.ItemType.Import Then



                                ' load xml
                                ' --------

                                'xmlout.LoadXml(CalculationHelper.GetCalculateCostReturnXML())

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
                                'rowChanges = tableChanges.GetRow(itemRec.ID, True)

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
                                'retValue2 = CALLBACK_SEP & "Hazardous" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & String.Empty
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


                        'retValue2 = CALLBACK_SEP & "CountryOfOriginName" & CALLBACK_SEP & String.Format("gce_{0}_", rowID) & CALLBACK_SEP & cresult


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


                    ' merge the row changes for validation
                    'For i = 0 To itemRecList.RecordCount - 1
                    '    itemRec = itemRecList.Item(i)
                    '    tableChanges.GetRow(itemRec.ID, True).MergeChangeRecords(saveTableChanges.GetRow(itemRec.ID, True), True)
                    'Next

                    ' clean up
                    saveRowChanges = Nothing
                    rowChanges = Nothing
                    saveTableChanges = Nothing
                    tableChanges = Nothing

                    retValue = "200" & CALLBACK_SEP & "1" & retValue2
                End If

                'itemDetail.SaveAuditRecordForItemHeader(itemsaudit, itemHeaderID)


                ' Validate all records
                ' ----------------------------------------------------------------------
                ' CHANGE THIS TO ALTERNATIVELY ACCEPT THE TABLE CHANGES
                ValidateEntireItemList(Me.BatchID)
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

        'itemDetail = Nothing
        'itemsaudit = Nothing

        itemRec = Nothing
        itemRecList = Nothing
        table = Nothing
        md = Nothing

        Return retValue
    End Function

    Private Function ValidateGrid(ByRef batchDetail As Models.BatchRecord) As Integer
        Dim validFlag As Integer = 0
        Dim hasError As Boolean = False
        Dim hasWarning As Boolean = False
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        Try
            'Dim itemHeader As Models.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(DataHelper.SmartValues(hid.Value, "long", False))
            If Not batchDetail Is Nothing Then
                Dim gridItemList As Models.ItemMaintItemDetailRecordList = Data.MaintItemMasterData.GetItemList(batchDetail.ID, 0, 0, String.Empty, userID)
                Dim changes As Models.IMTableChanges = Nothing
                changes = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(batchDetail.ID)
                Dim vrs As ArrayList = ValidationHelper.ValidateItemMaintItemList(gridItemList.ListRecords, changes, batchDetail)
                validFlag = 0
                For Each vr As Models.ValidationRecord In vrs
                    If Not hasError AndAlso vr.ErrorExists(ValidationRuleSeverityType.TypeError) Then hasError = True
                    If Not hasWarning AndAlso vr.ErrorExists(ValidationRuleSeverityType.TypeWarning) Then hasWarning = True
                    If hasError AndAlso hasWarning Then Exit For
                Next
                If hasError Then validFlag += 1
                If hasWarning Then validFlag += 2

                vrs = Nothing
                gridItemList.ClearList()
                gridItemList = Nothing
            Else
                validFlag = -1
            End If
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            validFlag = -1
        Catch ex As Exception
            Logger.LogError(ex)
            validFlag = -1
        End Try

        Return validFlag
    End Function

    Private Function CallbackValidateGrid() As String
        Dim retValue As String = String.Empty
        Dim success As String = "0"
        Dim validFlag As String = "0"
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        Try
            ''Dim itemHeader As Models.ItemHeaderRecord = objMichaels.GetItemHeaderRecord(DataHelper.SmartValues(hid.Value, "long", False))
            ''If Not itemHeader Is Nothing Then
            ''    Dim itemList As Models.ItemList = objMichaels.GetList(itemHeader.ID, 0, 0, String.Empty, userID)
            ''    Dim vrs As ArrayList = ValidationHelper.ValidateItemList(itemList.ListRecords, itemHeader)
            ''    validFlag = "1"
            ''    For Each vr As Models.ValidationRecord In vrs
            ''        If Not vr.IsValid Then
            ''            validFlag = "0"
            ''            Exit For
            ''        End If
            ''    Next
            ''    Do While vrs.Count > 0
            ''        vrs.RemoveAt(0)
            ''    Loop
            ''    vrs = Nothing
            ''    itemList.ClearList()
            ''    itemList = Nothing
            ''    itemHeader = Nothing
            ''    success = "1"
            ''Else
            ''    success = "0"
            ''End If

            retValue = "300" & CALLBACK_SEP & success & CALLBACK_SEP & validFlag
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            retValue = "300" & CALLBACK_SEP & "0"
        Catch ex As Exception
            Logger.LogError(ex)
            retValue = "300" & CALLBACK_SEP & "0"
        End Try

        Return retValue
    End Function

#End Region

    Private Property DefaultEnabledColumns() As String
        Get
            Dim o As Object = Session("IMDefaultEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("IMDefaultEnabledColumns") = value
        End Set
    End Property

    Private Property UserEnabledColumns() As String
        Get
            Dim o As Object = Session("IMUserEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("IMUserEnabledColumns") = value
        End Set
    End Property

    Private Property UserStartupFilter() As Integer
        Get
            Dim o As Object = Session("IMUserStartupFilter")
            If Not o Is Nothing And IsNumeric(o) Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session("IMUserStartupFilter") = value
        End Set
    End Property

    Private Property CustomFieldStartID() As Integer
        Get
            Dim o As Object = Session("IMCustomFieldStartID")
            If Not o Is Nothing And IsNumeric(o) Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session("IMCustomFieldStartID") = value
        End Set
    End Property

    Private Property CustomFieldRef() As String
        Get
            Dim o As Object = Session("IMCustomFieldRef")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("IMCustomFieldRef") = value
        End Set
    End Property

    Private Sub ShowMsg(ByVal msg As String)

    End Sub

    Private Function GetBatch(ByVal batchID As Long) As Models.BatchRecord
        Dim objRecord As Models.BatchRecord = New Models.BatchRecord
        Dim objData As New Data.BatchData
        objRecord = objData.GetBatchRecord(batchID)
        Return objRecord
    End Function

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
            If columns = "" Then
                str = "0"
            Else
                str = "0, " & columns
            End If
            'cmd.CommandText = "insert into UserEnabledColumns ([User_ID], ColumnDisplayName_ID) " & _
            '    " select @userID, [Column_Ordinal] from ColumnDisplayName " & _
            '    " where [Column_Ordinal] in (" & str & ") and Is_Custom = 0 and ISNULL(Workflow_ID, 1) = @gridID"
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
        sb.Append("<Parameter SortID=""1"" intColOrdinal=""11"" intDirection=""1"" />")
        sb.Append("<Parameter SortID=""2"" intColOrdinal=""1"" intDirection=""0"" />")
        sb.Append("</Sort>")
        ' set advanced sort
        ItemGrid.CurrentAdvancedSort = sb.ToString()
    End Sub

    Protected Sub SetDefaultNonPackSort()
        '' init vars
        'Dim sb As New StringBuilder("")
        '' setup xml
        'sb.Append("<Sort>")
        'sb.Append("<Parameter SortID=""1"" intColOrdinal=""1"" intDirection=""0"" />")
        'sb.Append("</Sort>")
        ' set advanced sort
        ItemGrid.CurrentAdvancedSort = String.Empty
        ItemGrid.CurrentSortColumn = 1
        ItemGrid.CurrentSortDirection = 0
    End Sub

    Protected Sub ValidateEntireItemList(ByVal batchID As Long)
        ' Validate all records
        ' ----------------------------------------------------------------------
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        Dim objData As New Data.BatchData()
        Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(batchID)
        objData = Nothing
        'Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()

        Dim gridItemList As Models.ItemMaintItemDetailRecordList = Nothing
        Dim changes As Models.IMTableChanges
        Dim vrBatch As Models.ValidationRecord
        Dim valRecords As ArrayList = Nothing

        If Not batchDetail Is Nothing Then
            Dim strXML As String = GetDefaultGridSortAndFilterXML()
            Dim firstRow As Integer = 1
            Dim pageSize As Integer = Data.MaintItemMasterData.GetItemListCount(batchDetail.ID, strXML, userID) + 1
            gridItemList = Data.MaintItemMasterData.GetItemList(batchDetail.ID, 0, 0, strXML, userID)
            changes = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(batchDetail.ID)

            If ValidationHelper.SkipBatchValidation(batchDetail.WorkflowStageType) Then
                vrBatch = New Models.ValidationRecord(batchDetail.ID, Models.ItemRecordType.Batch)
            Else
                vrBatch = ValidationHelper.ValidateItemMaintBatch(batchDetail, (Not UserCanEdit))
            End If

            valRecords = ValidationHelper.ValidateItemMaintItemList(gridItemList.ListRecords, changes, batchDetail)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(vrBatch, userID)
            NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.SetIsValidFlags(valRecords, userID)

        End If
        ' clean up
        If Not valRecords Is Nothing Then
            valRecords = Nothing
        End If
        batchDetail = Nothing
        gridItemList = Nothing
        changes = Nothing
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
        If vrBatch IsNot Nothing AndAlso (vrBatch.HasAnyError()) Then
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


End Class

