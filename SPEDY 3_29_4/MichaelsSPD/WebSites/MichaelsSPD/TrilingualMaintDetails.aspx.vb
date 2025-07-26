Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Text
Imports System.Xml
Imports System.Xml.XPath
Imports System.Collections.Generic
Imports System.Web.Services

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports PagingFiltering = NovaLibra.Common.Utilities.PaginationXML
Imports Infragistics.Web.UI.GridControls

Partial Class TrilingualMaintDetails
    Inherits MichaelsBasePage

    Private itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
    Private batchDetail As Models.BatchRecord

    'PAGING
    Const cTMITEMPERPAGE As String = "TMITEMPERPAGE"
    Const cTMITEMCURPAGE As String = "TMITEMCURPAGE"
    Const cTMITEMTOTALPAGES As String = "TMITEMTOTALPAGES"
    Const cTMITEMSTARTROW As String = "TMITEMSTARTROW"
    Const cTMITEMTOTALROWS As String = "TMITEMTOTALROWS"

    'SORTING
    Const cTMITEMCURSORTCOL As String = "TMITEMCURSORTCOL"
    Const cTMITEMCURSORTDIR As String = "TMITEMCURSORTDIR"

    'FILTERING
    Const cTMITEMSEARCHFILTER As String = "TMITEMSEARCHFILTER"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long")
        hdnUID.Value = userID
        SecurityCheckRedirect()

        If Request("id") <> "" AndAlso IsNumeric(Request("id")) Then
            hdnBatchID.Value = Request("id")
        End If

        Dim objData As New NovaLibra.Coral.Data.Michaels.BatchData
        batchDetail = objData.GetBatchRecord(hdnBatchID.Value)

        If Not Me.IsCallback Then
           
            ' Clear out messages
            ShowMsg("")

            If Not IsPostBack Then

                'Validate the Batch and Items
                ValidateBatch()

                'Initialize Page controls
                Initialize()

                'Paging
                UpdatePagingInformation()

                'Sorting
                UpdateSortingInformation()

                'Populate Grid View
                PopulateGridView()

                'Set Default sorting of the Gridview (must be called after databinding)
                gvItemList.Behaviors.Sorting.SortedColumns.Add(gvItemList.Columns("Michaels_SKU"), Infragistics.Web.UI.SortDirection.Ascending)

            End If

            'Fix to GridView caching issues when the user clicks the Back button
            Response.Cache.SetCacheability(HttpCacheability.NoCache)
        End If

    End Sub

    Public Sub CreateGridCell(ByVal itemID As Integer, ByVal itemChanges As List(Of Models.IMChangeRecord), ByVal fieldName As String, ByRef e As Infragistics.Web.UI.GridControls.RowEventArgs)
        'Get Change value for item 
        Dim changeRec As Models.IMChangeRecord = FormHelper.FindIMChangeRecord(itemChanges, itemID, fieldName, "", "", "", 0)

        'Get Grid Column Index
        Dim columnIndex As Integer = GetColumnIndex(fieldName)
        Dim rowIndex As Integer = e.Row.Index

        'Get Template Controls
        Dim changeDiv As Panel = TryCast(e.Row.Items(columnIndex).FindControl("change_div"), Panel)
        Dim originalCtrl As Label = TryCast(e.Row.Items(columnIndex).FindControl("orig_value"), Label)
        Dim changeCtrl As Label = TryCast(e.Row.Items(columnIndex).FindControl("chg_value"), Label)
        Dim undoBtn As Panel = TryCast(e.Row.Items(columnIndex).FindControl("edit_undo"), Panel)

        'Detect whether or not a change exists for this Field
        Dim isChanged As Boolean = False
        If changeRec.FieldValue <> originalCtrl.Text And (Not String.IsNullOrEmpty(changeRec.FieldName)) Then
            'Change Exists, setup change control
            originalCtrl.CssClass = "changeorig"
            changeDiv.CssClass = "changecell"
            changeCtrl.Text = changeRec.FieldValue
            isChanged = True
            undoBtn.Attributes.Add("style", "display:static")
            changeCtrl.Attributes.Add("style", "display:static")
        Else
            'No Change, setup original control
            undoBtn.Attributes.Add("style", "display:none")
            changeCtrl.Attributes.Add("style", "display:none")
            changeCtrl.Text = originalCtrl.Text
            changeDiv.CssClass = "changecell_hide"
        End If

        Select Case fieldName.ToUpper
            Case "PLIENGLISH", "PLIFRENCH", "PLISPANISH", "TIFRENCH"
                'Setup DropdownList for field editing
                Dim changeDDL As DropDownList = TryCast(e.Row.Items(columnIndex).FindControl("edit_value"), DropDownList)
                changeDDL.Attributes.Add("style", "display:none")
                changeDDL.SelectedValue = changeCtrl.Text
                changeDDL.Attributes.Add("onblur", "saveCell(" & itemID & ", " & rowIndex & "," & columnIndex & ")")

            Case Else
                'Setup Textbox for field editing
                Dim changeTxt As TextBox = TryCast(e.Row.Items(columnIndex).FindControl("edit_value"), TextBox)
                changeTxt.Attributes.Add("style", "display: none")
                changeTxt.Text = changeCtrl.Text
                changeTxt.Attributes.Add("onblur", "saveCell(" & itemID & ", " & rowIndex & "," & columnIndex & ")")

                'Add Max Length Attribute
                Select Case fieldName.ToUpper
                    Case "ENGLISHSHORTDESCRIPTION"
                        changeTxt.Attributes.Add("maxlength", "17")
                    Case "ENGLISHLONGDESCRIPTION"
                        changeTxt.Attributes.Add("maxlength", "100")
                    Case "EXEMPTENDDATEFRENCH"
                        changeTxt.Attributes.Add("maxlength", "10")
                    Case "ITEMDESC"
                        changeTxt.Attributes.Add("maxlength", "30")
                End Select
        End Select


        'Initialize FieldLocking info
        Dim flColumn As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn = itemFL.GetColumn(fieldName)
        If flColumn IsNot Nothing Then
            'NAK 5/15/2013"  Per Michaels, if TIFrench is YES, do not let user change the value
            If Not (fieldName.ToUpper = "TIFRENCH" And originalCtrl.Text = "Y") Then
                'Add Undo button and Edit javascript only if user has Edit permission
                If flColumn.Permission.ToString.ToUpper = "E" Then
                    changeDiv.Attributes.Add("ondblclick", "javascript:editGridCell(" & rowIndex & "," & columnIndex & ");")
                    undoBtn.Attributes.Add("onclick", "javascript:revertCell(" & itemID & ", " & rowIndex & ", " & columnIndex & ");")
                Else
                    undoBtn.Attributes.Add("style", "display:none")
                End If
            End If
        End If
    End Sub

    Protected Function GetColumnIndex(ByVal columnName As String) As Integer
        Dim columnIndex As Integer = 0
        'GET Column Index using the Column Name
        Select Case columnName.ToUpper
            Case "ITEMDESC"
                columnIndex = 7
            Case "PLIENGLISH"
                columnIndex = 14
            Case "PLIFRENCH"
                columnIndex = 15
            Case "PLISPANISH"
                columnIndex = 16
            Case "EXEMPTENDDATEFRENCH"
                columnIndex = 17
            Case "TIFRENCH"
                columnIndex = 18
            Case "ENGLISHSHORTDESCRIPTION"
                columnIndex = 19
            Case "ENGLISHLONGDESCRIPTION"
                columnIndex = 20
            Case "FRENCHSHORTDESCRIPTION"
                columnIndex = 21
            Case "FRENCHLONGDESCRIPTION"
                columnIndex = 22
            Case "SPANISHSHORTDESCRIPTION"
                columnIndex = 23
            Case "SPANISHLONGDESCRIPTION"
                columnIndex = 24
        End Select

        Return columnIndex
    End Function

    Protected Function GetCheckBoxUrl(ByVal Value As Object) As String

        Dim returnValue As String = "images/Valid_null.gif"

        If Value IsNot Nothing AndAlso Value IsNot DBNull.Value Then
            If DataHelper.SmartValue(Value, "CBool", False) = True Then
                returnValue = "images/Valid_yes.gif"
            Else
                returnValue = "images/Valid_no.gif"
            End If
        Else
            returnValue = "images/Valid_null.gif"
        End If

        Return returnValue

    End Function

    Protected Function GetUpdateAllFunction(ByVal columnName As String) As String
        Dim response As New StringBuilder("")
        If itemFL IsNot Nothing Then
            Dim flColumn As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn = itemFL.GetColumn(columnName)
            If flColumn IsNot Nothing Then
                If flColumn.Permission = "E" Then
                    response.Append("showSetAll(this," & GetColumnIndex(columnName) & ");")
                End If
            End If
        End If
        
        Return response.ToString
    End Function

    Private Sub Initialize()

        If batchDetail IsNot Nothing Then

            If batchDetail.DateLastModified <> Date.MinValue Then
                lastUpdated.Text = batchDetail.DateLastModified.ToString("M/d/yyyy")
                If batchDetail.UpdatedUserName <> "" Then
                    lastUpdated.Text += " by " & batchDetail.UpdatedUserName
                End If
            End If

            If batchDetail.WorkflowStageName <> "" Then
                stageName.Text = batchDetail.WorkflowStageName
            End If

            lblBatchType.Text = batchDetail.BatchTypeDesc
            hdnWorkflowStageID.Value = batchDetail.WorkflowStageID

            If batchDetail.IsValid Then
                validBatch.Src = "images/valid_yes_small.gif"
            Else
                validBatch.Src = "images/valid_no_small.gif"
            End If
        End If

        lblMaintType.Text = "Trilingual Maintenance"
        batch.Text = hdnBatchID.Value
        linkExcel.NavigateUrl = "TrilingualMaintBatchExport.aspx?bid=" & hdnBatchID.Value

        'Initialize Paging Values
        Session(cTMITEMPERPAGE) = WebConstants.BATCH_PAGE_SIZE
        Session(cTMITEMCURPAGE) = 1
        Session(cTMITEMTOTALPAGES) = 1
        Session(cTMITEMSTARTROW) = 1
        Session(cTMITEMTOTALROWS) = 0
        'Initialize Sorting Values
        Session(cTMITEMCURSORTCOL) = 0
        Session(cTMITEMCURSORTDIR) = PaginationXML.SortDirection.Asc

    End Sub

    Private Sub PopulateGridView()

        Dim cmd As SqlCommand
        Dim dt As DataTable

        Try
            'Get Field Locking information to use when constructing the table.
            Dim objMichaels As New NovaLibra.Coral.Data.Michaels.MaintItemMasterData
            itemFL = objMichaels.GetFieldLocking(AppHelper.GetUserID(), Models.MetadataTable.vwItemMaintItemDetail, AppHelper.GetVendorID(), hdnWorkflowStageID.Value, True)
            objMichaels = Nothing

            Dim sql As String = "usp_SPD_TrilingualMaint_GetList"
            Dim dbUtil As New DBUtil(ConnectionString)

            cmd = New SqlCommand()

            Dim xml As New PaginationXML()

            '************************
            'Add Search Filters
            '************************
            'Always add the Batch ID Filter Criteria
            xml.AddFilterCriteria(-1, hdnBatchID.Value)

            'Add Sorting
            Dim sortColumn As Integer = 0
            Select Case Session(cTMITEMCURSORTCOL).ToString.ToUpper
                Case "MICHAELS_SKU"
                    sortColumn = 0
                Case "VENDOR_NUMBER"
                    sortColumn = 1
                Case "VENDOR_NAME"
                    sortColumn = 2
                Case "ITEM_TYPE"
                    sortColumn = 3
                Case "VENDOR_STYLE_NUM"
                    sortColumn = 4
                Case "ITEM_DESC"
                    sortColumn = 5
                Case "ITEM_STATUS"
                    sortColumn = 6
                Case "DEPARTMENT_NUM"
                    sortColumn = 7
                Case "CLASS_NUM"
                    sortColumn = 8
                Case "SUB_CLASS_NUM"
                    sortColumn = 9
                Case "SKU_GROUP"
                    sortColumn = 10
                Case "PRIVATE_BRAND_LABEL"
                    sortColumn = 11
                Case "PLI_ENGLISH"
                    sortColumn = 12
                Case "PLI_FRENCH"
                    sortColumn = 13
                Case "PLI_SPANISH"
                    sortColumn = 14
                Case "TI_FRENCH"
                    sortColumn = 15
                Case "ENGLISH_SHORT_DESCRIPTION"
                    sortColumn = 16
                Case "ENGLISH_LONG_DESCRIPTION"
                    sortColumn = 17
                Case "FRENCH_SHORT_DESCRIPTION"
                    sortColumn = 18
                Case "FRENCH_LONG_DESCRIPTION"
                    sortColumn = 19
                Case "SPANISH_SHORT_DESCRIPTION"
                    sortColumn = 20
                Case "SPANISH_LONG_DESCRIPTION"
                    sortColumn = 21
                Case "EXEMPT_END_DATE_FRENCH"
                    sortColumn = 22
                Case "IS_VALID"
                    sortColumn = 23
            End Select

            xml.AddSortCriteria(sortColumn, Session(cTMITEMCURSORTDIR))

            cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.VarChar).Value = xml.GetPaginationXML().Replace("'", "''")
            cmd.Parameters.Add("@maxRows", SqlDbType.Int).Value = DataHelper.SmartValue(Session(cTMITEMPERPAGE), "CInt", -1)
            cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = DataHelper.SmartValue(Session(cTMITEMSTARTROW), "CInt", 1)

            cmd.CommandText = sql
            cmd.CommandTimeout = 1800
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Connection = dbUtil.GetSqlConnection()

            dt = dbUtil.GetDataTable(cmd)

            'Update Paging
            If dt.Rows.Count > 0 Then
                Session(cTMITEMTOTALROWS) = DataHelper.SmartValue(dt.Rows(0)("totRecords"), "CStr", 0)
                Session(cTMITEMSTARTROW) = DataHelper.SmartValue(dt.Rows(0)("RowNumber"), "CStr", 0)
            Else
                Session(cTMITEMTOTALROWS) = 0
            End If

            UpdatePagingInformation()

            gvItemList.DataSource = dt
            gvItemList.DataBind()

            UpdateColumnDisplay()

        Catch ex As Exception
            Logger.LogError(ex)
            ShowMsg("There was a problem displaying the details grid.  Please try refreshing the page, or going back to Home.")
            'Throw ex
        Finally
            If Not cmd Is Nothing Then
                If Not cmd.Connection Is Nothing AndAlso cmd.Connection.State <> ConnectionState.Closed Then
                    cmd.Dispose()
                End If
                cmd = Nothing
            End If
        End Try

    End Sub

    Private Sub ShowMsg(ByVal strMsg As String)
        Dim curMsg As String
        If strMsg.Length = 0 Then
            lblItemMessage.Text = "&nbsp;"   ' populate with a space to maintain content on page (and get rid of horiz scroll bar to boot)
        Else
            curMsg = lblItemMessage.Text
            If curMsg = "&nbsp;" Then           ' Only set the message if there is not one in there already
                lblItemMessage.Text = strMsg
            Else
                lblItemMessage.Text += "<br />" & strMsg
            End If
        End If
    End Sub

    Private Sub UpdateColumnDisplay()
        'Set Fixed Columns
        gvItemList.Behaviors.ColumnFixing.FixedColumns.Add(New FixedColumnInfo("Is_Valid", FixLocation.Left))
        gvItemList.Behaviors.ColumnFixing.FixedColumns.Add(New FixedColumnInfo("Michaels_SKU", FixLocation.Left))
        gvItemList.Behaviors.ColumnFixing.FixedColumns.Add(New FixedColumnInfo("Vendor_Number", FixLocation.Left))
        gvItemList.Behaviors.ColumnFixing.FixedColumns.Add(New FixedColumnInfo("Vendor_Name", FixLocation.Left))

        'Set Hidden Columns
        For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
            Dim columnIndex As Integer = GetColumnIndex(col.ColumnName)
            If columnIndex > 13 Then
                'TODO: Fix Column Mapping issue
                Dim columnName As String = ""
                Select Case col.ColumnName.ToUpper
                    Case "ITEMDESC"
                        columnName = "Item_Desc"
                    Case "PLIENGLISH"
                        columnName = "PLI_English"
                    Case "PLIFRENCH"
                        columnName = "PLI_French"
                    Case "PLISPANISH"
                        columnName = "PLI_Spanish"
                    Case "TIFRENCH"
                        columnName = "TI_French"
                    Case "ENGLISHSHORTDESCRIPTION"
                        columnName = "English_Short_Description"
                    Case "ENGLISHLONGDESCRIPTION"
                        columnName = "English_Long_Description"
                    Case "FRENCHSHORTDESCRIPTION"
                        columnName = "French_Short_Description"
                    Case "FRENCHLONGDESCRIPTION"
                        columnName = "French_Long_Description"
                    Case "SPANISHSHORTDESCRIPTION"
                        columnName = "Spanish_Short_Description"
                    Case "SPANISHLONGDESCRIPTION"
                        columnName = "Spanish_Long_Description"
                    Case "EXEMPTENDDATEFRENCH"
                        columnName = "Exempt_End_Date_French"
                End Select

                If col.Permission.ToString.ToUpper = "N" Then
                    gvItemList.Columns(columnName).Hidden = True
                Else
                    gvItemList.Columns(columnName).Hidden = False
                End If
            End If
        Next
    End Sub

    Private Sub UpdatePagingInformation()

        'Set Paging Defaults
        If Session(cTMITEMPERPAGE) Is Nothing Then Session(cTMITEMPERPAGE) = WebConstants.BATCH_PAGE_SIZE
        If Session(cTMITEMCURPAGE) Is Nothing Then Session(cTMITEMCURPAGE) = 1
        If Session(cTMITEMTOTALPAGES) Is Nothing Then Session(cTMITEMTOTALPAGES) = 1
        If Session(cTMITEMSTARTROW) Is Nothing Then Session(cTMITEMSTARTROW) = 1
        If Session(cTMITEMTOTALROWS) Is Nothing Then Session(cTMITEMTOTALROWS) = 0

        If DataHelper.SmartValue(Session(cTMITEMTOTALROWS), "CInt", 0) > 0 Then

            If DataHelper.SmartValue(Session(cTMITEMSTARTROW), "CInt", 0) > DataHelper.SmartValue(Session(cTMITEMTOTALROWS), "CInt", 0) Then
                Session(cTMITEMSTARTROW) = 1
            End If

            Session(cTMITEMTOTALPAGES) = Fix(DataHelper.SmartValue(Session(cTMITEMTOTALROWS), "CInt", 0) / DataHelper.SmartValue(Session(cTMITEMPERPAGE), "CInt", 0))
            If (DataHelper.SmartValue(Session(cTMITEMTOTALROWS), "CInt", 0) Mod DataHelper.SmartValue(Session(cTMITEMPERPAGE), "CInt", 0)) <> 0 Then
                Session(cTMITEMTOTALPAGES) = DataHelper.SmartValue(Session(cTMITEMTOTALPAGES), "CInt", 0) + 1
            End If

            If DataHelper.SmartValue(Session(cTMITEMCURPAGE), "CInt", 1) <= 0 OrElse DataHelper.SmartValue(Session(cTMITEMCURPAGE), "CInt", 1) > DataHelper.SmartValue(Session(cTMITEMTOTALPAGES), "CInt", 0) Then
                Session(cTMITEMCURPAGE) = 1
            End If

        Else
            Session(cTMITEMCURPAGE) = 1
            Session(cTMITEMTOTALPAGES) = 1
            Session(cTMITEMSTARTROW) = 1
        End If

    End Sub

    Private Sub UpdateSortingInformation()

        'Set Sorting Defaults
        If Session(cTMITEMCURSORTCOL) Is Nothing Then Session(cTMITEMCURSORTCOL) = 0
        If Session(cTMITEMCURSORTDIR) Is Nothing Then Session(cTMITEMCURSORTDIR) = PaginationXML.SortDirection.Asc

    End Sub

    Private Sub ValidateBatch()
        'Initialize Validation Display
        ValidationHelper.SetupValidationSummary(validationDisplay)
        'Get List of Items in the batch
        Dim itemList As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailRecordList = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemList(batchDetail.ID, 0, 0, String.Empty, DataHelper.SmartValues(Session("UserID"), "long"))
        'Get Change records for items in batch
        Dim changes As Models.IMTableChanges = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetIMChangeRecordsByBatchID(batchDetail.ID)
        'Perform Validation on entire batch (and all items)
        Dim valRecords As ArrayList = ValidationHelper.ValidateTrilingualMaintItemList(itemList, changes, batchDetail.WorkflowStageID, batchDetail.WorkflowStageType)

        'Look through validation records for Errors and/or Warnings
        Dim hasErrors As Boolean = False
        Dim hasWarnings As Boolean = False
        For i As Integer = 0 To valRecords.Count - 1
            Dim valRecord As Models.ValidationRecord = CType(valRecords(i), Models.ValidationRecord)
            'Update item and validation summary with item errors
            NovaLibra.Coral.Data.Michaels.ValidationData.SetIsValid(valRecord.RecordID, 5, valRecord.IsValid)
            ValidationHelper.AddValidationSummaryErrors(validationDisplay, valRecord)

            'Note if there is an error or warning
            If Not (valRecord.IsValid) Then
                hasErrors = True
            End If
            If valRecord.ErrorExists(ValidationRuleSeverityType.TypeWarning) Then
                hasWarnings = True
            End If
        Next

        'Update Batch Validity
        If hasErrors Then
            NovaLibra.Coral.Data.Michaels.ValidationData.SetIsValid(batchDetail.ID, 1, False)
            batchDetail.IsValid = False
        Else
            NovaLibra.Coral.Data.Michaels.ValidationData.SetIsValid(batchDetail.ID, 1, True)
            batchDetail.IsValid = True
        End If

    End Sub

#Region "Events"

    Protected Sub gvItemList_ColumnSorted(ByVal sender As Object, ByVal e As SortingEventArgs) Handles gvItemList.ColumnSorted
        Try

            Dim columnName As String = e.Column.Key

            'Same Column (Change Direction)
            If Session(cTMITEMCURSORTCOL).ToString() = columnName Then

                If Session(cTMITEMCURSORTDIR) = PagingFiltering.SortDirection.Asc Then
                    Session(cTMITEMCURSORTDIR) = PagingFiltering.SortDirection.Desc
                Else
                    Session(cTMITEMCURSORTDIR) = PagingFiltering.SortDirection.Asc
                End If

            Else
                Session(cTMITEMCURSORTCOL) = columnName
                Session(cTMITEMCURSORTDIR) = PagingFiltering.SortDirection.Asc
            End If

            'Go To First Item
            Session(cTMITEMCURPAGE) = 1
            Session(cTMITEMSTARTROW) = 1

            PopulateGridView()

        Catch ex As Exception
            Logger.LogError(ex)
        End Try
    End Sub

    Protected Sub gvItemList_InitializeRow(ByVal sender As Object, ByVal e As Infragistics.Web.UI.GridControls.RowEventArgs) Handles gvItemList.InitializeRow
        'Get Item ID from grid
        Dim itemID As Integer = DataHelper.SmartValues(e.Row.DataKey(0), "CInt", False, 0)

        'Get Item Changes
        Dim itemChanges As List(Of Models.IMChangeRecord) = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetIMChangeRecordsByItemID(itemID)

        CreateGridCell(itemID, itemChanges, "ItemDesc", e)
        CreateGridCell(itemID, itemChanges, "PLIEnglish", e)
        CreateGridCell(itemID, itemChanges, "PLIFrench", e)
        CreateGridCell(itemID, itemChanges, "PLISpanish", e)
        CreateGridCell(itemID, itemChanges, "TIFrench", e)
        CreateGridCell(itemID, itemChanges, "EnglishShortDescription", e)
        CreateGridCell(itemID, itemChanges, "EnglishLongDescription", e)
        CreateGridCell(itemID, itemChanges, "FrenchShortDescription", e)
        CreateGridCell(itemID, itemChanges, "FrenchLongDescription", e)
        CreateGridCell(itemID, itemChanges, "SpanishShortDescription", e)
        CreateGridCell(itemID, itemChanges, "SpanishLongDescription", e)
        CreateGridCell(itemID, itemChanges, "ExemptEndDateFrench", e)


        'Hide SKU Delete link if not editable.
        Dim btnDelete As LinkButton = TryCast(e.Row.Items(2).FindControl("btnDelete"), LinkButton)
        If btnDelete IsNot Nothing Then
            Dim flColumn As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn = itemFL.GetColumn("SKU")
            If flColumn IsNot Nothing Then
                If flColumn.Permission.ToString.ToUpper = "E" Then
                    btnDelete.Visible = True
                Else
                    btnDelete.Visible = False
                End If
            End If
        End If

    End Sub

    Protected Sub gvItemList_Rowcommand(ByVal sender As Object, ByVal e As Infragistics.Web.UI.GridControls.HandleCommandEventArgs) Handles gvItemList.ItemCommand
        Try

            Select Case e.CommandName
                Case "Page"

                    Select Case e.CommandArgument
                        Case "First"
                            Session(cTMITEMCURPAGE) = 1
                            Session(cTMITEMSTARTROW) = 1
                        Case "Prev"
                            If Session(cTMITEMCURPAGE) > 1 Then
                                Session(cTMITEMCURPAGE) -= 1
                                Session(cTMITEMSTARTROW) = Session(cTMITEMSTARTROW) - Session(cTMITEMPERPAGE)
                            End If
                        Case "Next"
                            If Session(cTMITEMCURPAGE) < Session(cTMITEMTOTALPAGES) Then
                                Session(cTMITEMCURPAGE) += 1
                                Session(cTMITEMSTARTROW) = Session(cTMITEMSTARTROW) + Session(cTMITEMPERPAGE)
                            End If
                        Case "Last"
                            Session(cTMITEMCURPAGE) = Session(cTMITEMTOTALPAGES)
                            Session(cTMITEMSTARTROW) = ((Session(cTMITEMTOTALPAGES) - 1) * Session(cTMITEMPERPAGE)) + 1
                    End Select

                    PopulateGridView()

                Case "PageReset"

                    Dim newBatchesPerPage As Integer = 10 'GetPagerInfo("txtBatchPerPage")

                    If newBatchesPerPage >= 5 AndAlso newBatchesPerPage <= 50 Then

                        Session(cTMITEMCURPAGE) = 1
                        Session(cTMITEMSTARTROW) = 1
                        Session(cTMITEMPERPAGE) = newBatchesPerPage

                        PopulateGridView()
                    Else
                        ShowMsg("Batches / Page must be between 5 and 50")
                    End If
            End Select

        Catch ex As Exception
            Logger.LogError(ex)
        End Try
    End Sub

    Protected Sub gvItemList_DataBound(ByVal sender As Object, ByVal e As EventArgs) Handles gvItemList.DataBound
        Dim pageList As DropDownList = TryCast(gvItemList.Behaviors.Paging.PagerTemplateContainerBottom.FindControl("ddlPageList"), DropDownList)

        If Not Me.IsPostBack Then

            Dim totalPages As Integer = DataHelper.SmartValues(Session(cTMITEMTOTALPAGES), "CInt", 1)

            'Add the number of pages to the pageList dropdown
            If pageList.Items.Count = 0 Then
                For i As Integer = 1 To totalPages
                    pageList.Items.Add(New ListItem(i, i))
                Next
            End If

            Dim ctrlPaging As Object
            ctrlPaging = gvItemList.Behaviors.Paging.PagerTemplateContainerBottom.FindControl("PagingInformation")
            ctrlPaging.text = String.Format("of {0}", Session(cTMITEMTOTALPAGES))

            ctrlPaging = gvItemList.Behaviors.Paging.PagerTemplateContainerBottom.FindControl("lblItemsFound")
            ctrlPaging.text = Session(cTMITEMTOTALROWS).ToString() & " Item(s) found "

        End If

        'Set PageList value to the current page
        pageList.SelectedValue = Session(cTMITEMCURPAGE)

    End Sub

    Protected Sub PageList_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)
        Try
            'Get the Selected Value of the Page List
            Dim pageList As DropDownList = TryCast(gvItemList.Behaviors.Paging.PagerTemplateContainerBottom.FindControl("ddlPageList"), DropDownList)
            Session(cTMITEMCURPAGE) = pageList.SelectedValue
            Session(cTMITEMSTARTROW) = ((Session(cTMITEMCURPAGE) - 1) * Session(cTMITEMPERPAGE)) + 1

            'Repopulate the GridView
            PopulateGridView()
        Catch ex As Exception
            Logger.LogError(ex)
        End Try
    End Sub

#End Region

#Region "Callbacks"

    <System.Web.Services.WebMethod> _
    Public Shared Function UpdateField(ByVal itemID As Integer, ByVal userID As Integer, ByVal rowID As Integer, ByVal fieldName As String, ByVal fieldValue As String) As AjaxUpdateResponse
        Dim response As New AjaxUpdateResponse()
        Try
            Dim audit As Models.AuditRecord
            Dim saveRowChanges As New Models.IMRowChanges(itemID)

            response.ItemID = itemID
            response.RowID = rowID
            response.FieldName = fieldName
            response.FieldValue = fieldValue

            'Get Original Item Values
            Dim itemRec As Models.ItemMaintItemDetailFormRecord = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(itemID, AppHelper.GetVendorID())
            If itemRec Is Nothing Then
                response.UpdateSuccess = False
                response.Message = "Error:  Item Not found (" & itemID & ")."
                Return response
            End If

            'Get Batch Details 
            Dim objData As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(itemRec.BatchID)
            objData = Nothing

            Select Case fieldName.ToUpper
                Case "ENGLISHLONGDESCRIPTION", "ENGLISHSHORTDESCRIPTION"
                    'IF this is a pack item, override value (Per Michaels:  These values must be used for pack parent items)
                    If itemRec.PackItemIndicator.StartsWith("DP") Then
                        fieldValue = "Display Pack"
                    ElseIf itemRec.PackItemIndicator.StartsWith("SB") Then
                        fieldValue = "Sellable Bundle"
                    ElseIf itemRec.PackItemIndicator.StartsWith("D") Then
                        fieldValue = "Displayer"
                    End If
                Case "ITEMDESC"
                    'NAK 4/17/2013: Per client, item description must be upper case
                    fieldValue = fieldValue.ToUpper
            End Select

            Dim originalValue As String = DataHelper.SmartValues(FormHelper.GetObjectValue(itemRec, fieldName), "String", True)

            ' add the change record
            saveRowChanges.Add(FormHelper.CreateChangeRecord(originalValue, fieldName, "String", fieldValue))

            ' save the change
            NovaLibra.Coral.Data.Michaels.MaintItemMasterData.SaveItemMaintChanges(saveRowChanges, userID)
            saveRowChanges.ClearChanges()

            'Get Change records for items in batch
            Dim changes As Models.IMRowChanges = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetIMChangeRecordsByID(itemRec.ID)
            'Perform Validation on entire batch (and all items)
            Dim valRecord As Models.ValidationRecord = ValidationHelper.ValidateTrilingualMaintItem(itemRec, changes, batchDetail.WorkflowStageID, batchDetail.WorkflowStageType)

            'Update item validity
            NovaLibra.Coral.Data.Michaels.ValidationData.SetIsValid(valRecord.RecordID, 5, valRecord.IsValid)

            'Update Batch Validity
            Dim validBatch As Boolean = False
            Dim invalidItemCount As Integer = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemInvalidCount(batchDetail.ID)
            If invalidItemCount = 0 Then
                validBatch = True
            End If
            NovaLibra.Coral.Data.Michaels.ValidationData.SetIsValid(batchDetail.ID, 1, validBatch)

            'Populate Response object
            response.UpdateSuccess = True
            response.ItemIsValid = valRecord.IsValid
            response.ItemID = itemID
            response.BatchIsValid = validBatch
            response.MichaelsSKU = itemRec.SKU
            'Add Errors
            For i As Integer = 0 To valRecord.ValidationErrors.Count - 1
                Dim valError As NovaLibra.Coral.SystemFrameworks.Michaels.ValidationError = valRecord.ValidationErrors(i)
                If (valError.ErrorSeverity = ValidationRuleSeverityType.TypeError) Then
                    response.Message = response.Message & "||" & "<span title=""" & itemRec.ID & """ class=""sevError"">Error:&nbsp;</span>" & valError.ErrorText
                End If
            Next
            'Indicate there are Warnings
            If valRecord.Count(ValidationRuleSeverityType.TypeWarning) > 0 Then
                response.HasWarning = True
            End If

            ' clean up
            saveRowChanges = Nothing
            itemRec = Nothing

            audit = Nothing
            'itemDetail = Nothing
            batchDetail = Nothing
        Catch ex As Exception
            Logger.LogError(ex)
            response.UpdateSuccess = False
            response.Message = ex.Message
        End Try

        Return response
    End Function

    <System.Web.Services.WebMethod> _
    Public Shared Function UpdateAll(ByVal userID As Integer, ByVal batchID As Integer, ByVal fieldName As String, ByVal fieldValue As String) As AjaxUpdateResponse
        Dim response As New AjaxUpdateResponse()
        Try
            'Get Batch Details 
            If batchID <= 0 Then
                response.UpdateSuccess = False
                response.Message = "ERROR: Unable to update items, no batch found!"
            End If
            Dim objData As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(batchID)
            objData = Nothing

            'Get list of items by BatchID
            Dim itemRecList As Models.ItemMaintItemDetailRecordList = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemList(batchID, 1, Integer.MaxValue, "", userID)

            'Save new value for all Items on the Batch
            Dim saveTableChanges As New Models.IMTableChanges()
            Dim saveRowChanges As Models.IMRowChanges
            For i As Integer = 0 To itemRecList.RecordCount - 1
                Dim itemRec As Models.ItemMaintItemDetailFormRecord = itemRecList.Item(i)

                Select Case fieldName.ToUpper
                    Case "ENGLISHLONGDESCRIPTION", "ENGLISHSHORTDESCRIPTION"
                        'IF this is a pack item, override value (Per Michaels:  These values must be used for pack parent items)
                        If itemRec.PackItemIndicator.StartsWith("DP") Then
                            fieldValue = "Display Pack"
                        ElseIf itemRec.PackItemIndicator.StartsWith("SB") Then
                            fieldValue = "Sellable Bundle"
                        ElseIf itemRec.PackItemIndicator.StartsWith("D") Then
                            fieldValue = "Displayer"
                        End If
                    Case "ITEMDESC"
                        'NAK 4/17/2013: Per client, item description must be upper case
                        fieldValue = fieldValue.ToUpper
                End Select

                'Find original value from item record
                Dim originalValue As String = DataHelper.SmartValues(FormHelper.GetObjectValue(itemRec, fieldName), "String", True)

                'NAK 5/15/2013:  Per Michaels, if the TI French value is YES, do not let the user change it.
                If fieldName.ToUpper = "TIFRENCH" And originalValue = "Y" Then
                    fieldValue = "Y"
                End If

                saveRowChanges = New Models.IMRowChanges(itemRec.ID)
                saveRowChanges.Add(FormHelper.CreateChangeRecord(originalValue, fieldName, "String", fieldValue))
                saveTableChanges.Add(saveRowChanges)
            Next

            ' save the changes and then clear
            NovaLibra.Coral.Data.Michaels.MaintItemMasterData.SaveItemMaintChanges(saveTableChanges, userID)
            saveTableChanges.ClearChanges(True)

            response.UpdateSuccess = True

        Catch ex As Exception
            Logger.LogError(ex)
            response.UpdateSuccess = False
            response.Message = ex.Message
        End Try

        Return response
    End Function

    <System.Web.Services.WebMethod> _
    Public Shared Function DeleteItem(ByVal itemID As Integer, ByVal userID As Integer) As AjaxUpdateResponse
        Dim response As New AjaxUpdateResponse()
        Try

            'Get Original Item Values
            Dim itemRec As Models.ItemMaintItemDetailFormRecord = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(itemID, AppHelper.GetVendorID())
            If itemRec Is Nothing Then
                response.UpdateSuccess = False
                response.Message = "Error:  Item Not found (" & itemID & ")."
                Return response
            End If

            Dim bDeleted As Boolean = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.DeleteItemMaintRecord(itemRec.BatchID, itemID, userID, 1)

            response.UpdateSuccess = True
        Catch ex As Exception
            Logger.LogError(ex)
            response.UpdateSuccess = False
            response.Message = ex.Message
        End Try
        Return response
    End Function

#End Region

End Class

<Serializable> _
Public Class AjaxUpdateResponse
    Private _itemID As Integer = 0
    Private _rowID As Integer = 0
    Private _cellID As Integer = 0
    Private _michaelsSKU As String = String.Empty
    Private _fieldName As String = String.Empty
    Private _fieldValue As String = String.Empty
    Private _message As String = String.Empty

    Private _hasWarnings As Boolean = False
    Private _updateSuccess As Boolean = False
    Private _itemIsValid As Boolean = False
    Private _batchIsValid As Boolean = False

    Public Property BatchIsValid() As Boolean
        Get
            Return _batchIsValid
        End Get
        Set(value As Boolean)
            _batchIsValid = value
        End Set
    End Property

    Public Property CellID() As String
        Get
            Return _cellID
        End Get
        Set(value As String)
            _cellID = value
        End Set
    End Property

    Public Property FieldName() As String
        Get
            Return _fieldName
        End Get
        Set(value As String)
            _fieldName = value
        End Set
    End Property

    Public Property FieldValue() As String
        Get
            Return _fieldValue
        End Get
        Set(value As String)
            _fieldValue = value
        End Set
    End Property

    Public Property HasWarning() As Boolean
        Get
            Return _hasWarnings
        End Get
        Set(value As Boolean)
            _hasWarnings = value
        End Set
    End Property

    Public Property ItemID() As Integer
        Get
            Return _itemID
        End Get
        Set(value As Integer)
            _itemID = value
        End Set
    End Property

    Public Property ItemIsValid() As Boolean
        Get
            Return _itemIsValid
        End Get
        Set(value As Boolean)
            _itemIsValid = value
        End Set
    End Property

    Public Property Message() As String
        Get
            Return _message
        End Get
        Set(value As String)
            _message = value
        End Set
    End Property

    Public Property MichaelsSKU() As String
        Get
            Return _michaelsSKU
        End Get
        Set(value As String)
            _michaelsSKU = value
        End Set
    End Property

    Public Property RowID() As Integer
        Get
            Return _rowID
        End Get
        Set(value As Integer)
            _rowID = value
        End Set
    End Property

    Public Property UpdateSuccess() As Boolean
        Get
            Return _updateSuccess
        End Get
        Set(value As Boolean)
            _updateSuccess = value
        End Set
    End Property

End Class