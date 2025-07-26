
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports NovaLibra.Common.Utilities
Imports System.Collections.Generic
Imports WebConstants

Partial Public Class _ItemMaint

    Inherits MichaelsBasePage

    ' Local Session Constants for this page
    Const cFINDSTAGEID As String = "_defFindMaintValue"  '_defFindNewValue
    Const cFINDBATCHSTR As String = "_defBatchMaintSearch"
    Const cSORTEXPRESSION As String = "_defMaintBatchSortExp"
    Const cSORTDIRECTION As String = "_defMaintBatchSortDir"
    Const cPAGENUMBER As String = "_defgvMaintPageIndex"


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' alway check that session is still valid
        SecurityCheckRedirect()

        Session(CURRENTTAB) = ITEMMAINT

        ' Clear out messages
        ShowMsg1("")

        If Not IsPostBack Then
            If Session(cBATCHPERPAGE) Is Nothing Then Session(cBATCHPERPAGE) = BATCH_PAGE_SIZE
            gvBatches.PageSize = CInt(Session(cBATCHPERPAGE))

            ' Populate the Show Stages Dropdown lists
            ' PopulateItemMaintShow()
            PopulateFindShows()
            InitControls()

            ' Do the inital Grid Loads based on UserID
            PopulateBatchesGrid(0, , Convert.ToInt32(Session(cUSERID)), True)   ' Use Session to Load Grid if avail
        Else
            ' Postback code goes here
        End If
    End Sub

    Private Sub InitControls()
        'lnkNewMaint.Attributes.Add("onclick", "getMaintType()")
        hdnPipe.Value = cPIPE
        Dim lvgs As ListValueGroups = FormHelper.LoadListValues("ITEMTYPEATTRIB,STOCKCAT")

        FormHelper.LoadListFromListValues(ddListNI2, lvgs.GetListValueGroup("STOCKCAT"), True, "* Selection Required *")
        FormHelper.LoadListFromListValues(ddListNI3, lvgs.GetListValueGroup("ITEMTYPEATTRIB"), True, "* Selection Required *")
        ddListNI2.Attributes.Add("onchange", "CheckControls();")
        ddListNI3.Attributes.Add("onchange", "CheckControls();")

        'Hide/Show Create Options based on Security Privileges
        If Not SecurityCheckHasAccess("SPD.ADVANCED", "SPD.ADVANCED.CREATEIMBATCH", Session("UserID")) Then
            divUploadOption.Visible = False
        End If

    End Sub

    'Private Sub PopulateMaintTypes()
    '    ddSelIMType.Items.Add(New ListItem("Basic", "1"))
    '    ddSelIMType.Items.Add(New ListItem("Cost", "2"))
    '    ddSelIMType.Items.Add(New ListItem("Pack Item", "3"))

    'End Sub

    'Private Sub PopulateItemMaintShow()
    '    Dim workflowRecs As List(Of Models.Workflow)
    '    Dim objdata As New Data.BatchData
    '    workflowRecs = objdata.GetItemMaitenanceWorkflows()
    '    '    ddSelIMType.DataSource = workflowRecs
    '    '    ddSelIMType.DataTextField = "WorkflowShortName"
    '    '    ddSelIMType.DataValueField = "ID"
    '    '    ddSelIMType.DataBind()
    '    '    ddSelIMType.Items.Insert(0, New ListItem("All", "0"))
    'End Sub

    ' Populate Stage Dropdowns
    Private Sub PopulateFindShows()
        Dim workFlowStages As List(Of Models.WorkflowStage)
        Dim intWorkflowid As Integer
        intWorkflowid = WorkflowType.ItemMaint

        Try
            workFlowStages = GetSPEDyStages(intWorkflowid)
            ddFindShow.DataSource = workFlowStages
            ddFindShow.DataTextField = "StageName"
            ddFindShow.DataValueField = "ID"
            ddFindShow.DataBind()
            ddFindShow.Items.Insert(0, New ListItem("My Items", "0"))
            ddFindShow.Items.Insert(1, New ListItem("All Stages", "-1")) ' special case!

            Try
                If IsAdminDBCQA() Then
                    ddFindShow.Items.Insert(2, New ListItem("Deleted Items", "-3")) ' another special case!
                End If
            Catch
                Dim msg As String = String.Empty
                If CheckandShowException(msg) Then
                    ShowMsg1(msg)
                Else
                    Throw
                End If
            End Try

            ddFindShow.Items.Insert(2, New ListItem("All Stages > 48 Hours", "-2")) ' special case
            If Session(cFINDSTAGEID) IsNot Nothing Then
                ddFindShow.SelectedValue = Convert.ToInt32(Session(cFINDSTAGEID))
            End If
            workFlowStages.Clear()
            workFlowStages = Nothing
        Catch ex As Exception
            Dim msg As String = String.Empty
            If CheckandShowException(msg) Then
                ShowMsg1(msg)
            Else
                Throw
            End If
        End Try

    End Sub

    ' Called by Gridvews
    Protected Function GetCheckBoxUrl(ByVal Value As Object) As String
        Select Case CType(Value, String)
            Case "yes"
                Return "images/Valid_yes.gif"
            Case "no"
                Return "images/Valid_no.gif"
            Case Else
                Return "images/Valid_null.gif"
        End Select
    End Function

    Protected Function GetEditURL(ByVal BatchType As String, ByVal ID As Object) As String  ', ByVal WorkFlowStageID As String, ByVal Dept_ID As String
        Dim URL As String
        Select Case UCase(BatchType)
            Case "IMPORT"
                URL = "IMDetailItems.aspx"
            Case "DOMESTIC"
                URL = "IMDetailItems.aspx"
            Case Else
                Return ""
        End Select

        Return URL + cPIPE + CType(ID, String)

    End Function

    Protected Sub gvBatches_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvBatches.DataBound
        If gvBatches.Rows.Count > 0 Then gvBatches.BottomPagerRow.Visible = True ' always show pager row
    End Sub

    ' This event fires when a NORMAL Page event occurs ie. Page: First Next Prev Last
    Protected Sub gvBatches_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvBatches.PageIndexChanged
        Session(cPAGENUMBER) = gvBatches.PageIndex
    End Sub

    ' This event fires when a NORMAL Page event occurs ie. Page First Next Prev Last
    Private Sub gvBatches_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvBatches.PageIndexChanging

    End Sub

    Private Sub gvBatches_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvBatches.RowCommand

        Dim pagerRow As GridViewRow, row As GridViewRow, strCommand As String, strAction As String, intActionValue As Integer
        Dim ctrl As New Object, i As Int32, ddAction As DropDownList, objHeaderID As Object
        Try
            strCommand = e.CommandName
            ' Check if GoTo Page button was clicked
            If strCommand = "PageGo" Then
                i = GetPageNumber()
                If i > 0 AndAlso i <= gvBatches.PageCount Then
                    gvBatches.PageIndex = i - 1
                    ' Save the page in session here as the Normal Paging events do not fire
                    Session(cPAGENUMBER) = gvBatches.PageIndex
                Else
                    ShowMsg1("Invalid Page Number entered.")
                End If
            End If

            ' Check if Batches per page was clicked
            If strCommand = "PageReset" Then
                SetBatchesPerPage()
                gvBatches.PageIndex = 0
            End If

            ' Check if Find Batch Containing Button was clicked
            If strCommand = "PageFind" Then
                pagerRow = gvBatches.BottomPagerRow
                ctrl = pagerRow.Cells(0).FindControl("txtBatch")
                'If Trim(ctrl.text) <> String.Empty Then
                Session(cFINDBATCHSTR) = Trim(ctrl.text)
                PopulateBatchesGrid(Convert.ToInt32(ddFindShow.SelectedValue), Trim(ctrl.text))
                'End If
            End If

            ' Check if an Action Button was clicked
            If strCommand = "Action" Then
                'Dim objboundfieldBatchId As Object
                Dim strTemp As String
                Dim intBatchId As Long, intHeaderid As Integer
                i = Convert.ToInt32(e.CommandArgument)
                row = gvBatches.Rows(i)
                ddAction = row.FindControl("DDAction")
                strAction = ddAction.SelectedItem.ToString
                intActionValue = ddAction.SelectedValue
                'and now -process approve/disapprove/remove
                If intActionValue > 0 Then
                    strTemp = gvBatches.DataKeys(i).Value
                    intBatchId = Convert.ToInt32(strTemp)
                    objHeaderID = row.FindControl("BatchID")       ' row.FindControl("HeaderId")
                    strTemp = objHeaderID.value.ToString
                    intHeaderid = Convert.ToInt32(strTemp)

                    'Verify the GridView is synced with Database.  Do not process if it is different
                    Dim gvStageID As Integer = DataHelper.SmartValue(CType(row.FindControl("StageID"), HiddenField).Value, "CInt", 0)
                    Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch
                    Dim wfStageID As Integer = objMichaels.GetRecord(intBatchId).WorkflowStageID
                    If (gvStageID = wfStageID) Then
                        ProcessActionButton(intActionValue, intBatchId, intHeaderid)
                    Else
                        ShowBatches()
                    End If

                End If
            End If
        Catch ex As Exception
            i = 0
        Finally
        End Try
    End Sub

    Protected Sub gvBatches_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvBatches.RowCreated
        If (e.Row.RowType = DataControlRowType.Header) Then
            AddSortGlyph(gvBatches, e.Row, Me.objDSBatches.SelectParameters("sortCol").DefaultValue, _
                Me.objDSBatches.SelectParameters("sortDir").DefaultValue)
        End If
    End Sub

    Private Sub gvBatches_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvBatches.RowDataBound
        Dim ctrlBtn, ctrlPaging As Object, objItemMaintRec As Models.IMBatchRecord
        Dim strTemp As String, boundfieldBatchId As Long, intStage_Type As Integer, intStageSeq As Integer, introwind As Integer, bEnabled As Boolean
        Dim ctrlddAction As DropDownList
        If e.Row.RowType = DataControlRowType.DataRow Then
            ctrlddAction = e.Row.FindControl("DDAction")
            'strTemp = e.Row.Cells("ID").Text
            objItemMaintRec = CType(e.Row.DataItem, Models.IMBatchRecord)
            strTemp = objItemMaintRec.ID
            boundfieldBatchId = Convert.ToInt32(strTemp)

            strTemp = objItemMaintRec.Stage_Type_id
            'based on the batch id, the action items in the drop down will be different
            intStage_Type = Convert.ToInt32(strTemp)
            strTemp = objItemMaintRec.Stage_Sequence
            intStageSeq = Convert.ToInt32(strTemp)
            bEnabled = objItemMaintRec.Enabled
            ctrlBtn = e.Row.FindControl("btnGol")
            ctrlBtn.CommandArgument = e.Row.RowIndex.ToString()
            introwind = e.Row.RowIndex + 1
            ctrlBtn.Attributes.Add("OnClick", "javascript: return RemoveDisappr_ActionButtonClick(" & introwind & ");")

            If intStage_Type = Models.WorkflowStageType.Completed Then
                ctrlBtn.visible = False
                ctrlddAction.Visible = False
            Else
                PopulateActionDD(ctrlddAction, boundfieldBatchId, intStage_Type, intStageSeq, objItemMaintRec.CreatedBy, bEnabled)
                If ctrlddAction.Items.Count = 0 Then
                    ctrlBtn.visible = False
                    ctrlddAction.Visible = False
                End If
            End If

            ctrlBtn.CommandArgument = e.Row.RowIndex.ToString()

        ElseIf e.Row.RowType = DataControlRowType.Pager Then
            ctrlPaging = e.Row.FindControl("PagingInformation")
            ctrlPaging.text = String.Format("Page {0} of {1}", gvBatches.PageIndex + 1, gvBatches.PageCount)
            ctrlPaging = e.Row.FindControl("lblBatchesFound")
            ctrlPaging.text = CStr(BatchesData.GetIMBatchCount()) & " " & ctrlPaging.text
            ctrlPaging = e.Row.FindControl("txtgotopage")
            If gvBatches.PageIndex + 1 < gvBatches.PageCount Then
                ctrlPaging.text = CStr(gvBatches.PageIndex + 2)
            Else
                ctrlPaging.text = "1"
            End If
            ctrlPaging = e.Row.FindControl("txtBatchPerPage")
            ctrlPaging.text = CStr(Session(cBATCHPERPAGE))

            Dim filter As String = Session(cFINDBATCHSTR)
            If filter Is Nothing Then filter = ""
            ctrlPaging = e.Row.FindControl("lblFiltered")
            If filter.Length > 0 Then
                ctrlPaging.text = "Results Filtered"
            Else
                ctrlPaging.text = ""
            End If

        End If

        If e.Row.RowType = DataControlRowType.Pager Then
            Dim txtBtach As TextBox = e.Row.FindControl("txtBatch")
            Dim btnFind As Button = e.Row.FindControl("btnFind")
            txtBtach.Attributes.Add("onkeypress", "return clickButton(event,'" & btnFind.ClientID & "');")
        End If
    End Sub

    Public Sub SetBatchesPerPage()
        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvBatches.BottomPagerRow
            'If pagerRow Is Nothing Then gvBatches.DataBind()
            ctrl = pagerRow.Cells(0).FindControl("txtBatchPerPage")
            If Trim(ctrl.text) <> String.Empty AndAlso IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
                If i > 4 And i < 51 Then
                    If CInt(Session(cBATCHPERPAGE)) <> i Then
                        gvBatches.PageSize = i
                        Session(cBATCHPERPAGE) = i
                    End If
                Else
                    ctrl.text = CStr(Session(cBATCHPERPAGE))
                    ShowMsg1("Batches / Page must be between 5 and 50")
                End If
            Else
                ctrl.text = CStr(Session(cBATCHPERPAGE))
                ShowMsg1("Batches / Page must be between 5 and 50")
            End If
        Catch e As Exception
        Finally
        End Try
    End Sub

    Public Function GetPageNumber() As Long
        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvBatches.BottomPagerRow
            'If pagerRow Is Nothing Then gvBatches.DataBind()
            ctrl = pagerRow.Cells(0).FindControl("txtgotopage")
            If Trim(ctrl.text) <> String.Empty And IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
            End If
        Catch e As Exception
            i = 0
        Finally
        End Try
        Return i
    End Function

    Private Sub PopulateBatchesGrid(ByVal StageId As Integer, Optional ByVal BatchSearch As String = "", Optional ByVal userID As Int32 = -1, _
         Optional ByVal UseSession As Boolean = False, Optional ByVal UseSortSession As Boolean = True)

        Dim intStageID As Integer, strBatchSearch As String, intPageIndex As Integer, vendorID As Integer
        Dim sortCol As String, sortDir As Char

        intStageID = StageId
        strBatchSearch = BatchSearch
        intPageIndex = 0

        If UseSession Then
            If Session(cFINDSTAGEID) IsNot Nothing Then intStageID = CInt(Session(cFINDSTAGEID))
            If Session(cFINDBATCHSTR) IsNot Nothing Then strBatchSearch = Session(cFINDBATCHSTR).ToString
            If Session(cPAGENUMBER) IsNot Nothing Then intPageIndex = Session(cPAGENUMBER)
        Else
            Session(cFINDBATCHSTR) = BatchSearch     ' Save what was passed in for subsequent searches (or reset it)
        End If

        vendorID = IIf(Session("vendorId") Is Nothing, 0, CType(Session("vendorId"), Integer))

        ' Was Grid sorted?
        If (UseSession Or UseSortSession) AndAlso Session(cSORTEXPRESSION) IsNot Nothing Then
            sortCol = Session(cSORTEXPRESSION)
            sortDir = Session(cSORTDIRECTION)
        Else    '  default to sort on ID
            sortCol = "ID"      ' was ""
            sortDir = "A"
        End If

        ' Data is retrieved using an ObjectDataSource.  ObjectDataSource uses the class \app_Code\BatchesData.vb 
        ' to get data and store in List Control

        ' set the parms for the new search.  Object Data source gets paging from Gridview info so handle that differently
        ' Note: Parms need to be defined in ObjectDataSource in order to handle the SelectCountMethod correctly
        Try
            Me.gvBatches.PageIndex = intPageIndex
            Me.objDSBatches.SelectParameters("StageId").DefaultValue = intStageID
            Me.objDSBatches.SelectParameters("StageTypeId").DefaultValue = GetStageType(intStageID)
            Me.objDSBatches.SelectParameters("batchSearch").DefaultValue = strBatchSearch
            Me.objDSBatches.SelectParameters("wfID").DefaultValue = 2       ' Maybe from a drop down if more than one workflow type for IM
            Me.objDSBatches.SelectParameters("userID").DefaultValue = Session("UserID")
            Me.objDSBatches.SelectParameters("vendorID").DefaultValue = vendorID
            Me.objDSBatches.SelectParameters("sortCol").DefaultValue = sortCol
            Me.objDSBatches.SelectParameters("sortDir").DefaultValue = sortDir

        Catch ex As Exception
            ProcessException(ex, "PopulateBatchesGrid")
        Finally
        End Try

        gvBatches.DataSourceID = objDSBatches.ID
        gvBatches.DataBind()

        ' Alway show pager row so the search box displays if any records returned
        ' Moved to the Grid Data bound event
        'If BatchesData.GetNewBatchCount > 0 Then
        '    gvBatches.BottomPagerRow.Visible = True
        'End If

        ' Reset Sorting and Paging Session variables if this is a normal load of the grid
        If Not UseSession Then
            Session(cPAGENUMBER) = Nothing
        End If

        If Not UseSession AndAlso Not UseSortSession Then
            Session(cSORTEXPRESSION) = Nothing
            Session(cSORTDIRECTION) = Nothing
        End If

    End Sub

    Private Sub ShowBatches()
        If Convert.ToInt32(ddFindShow.SelectedValue) = 0 Then
            PopulateBatchesGrid(0, , Convert.ToInt32(Session(cUSERID)))
        Else
            PopulateBatchesGrid(Convert.ToInt32(ddFindShow.SelectedValue))
        End If
    End Sub

    Private Sub btnFindShow_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFindShow.Click
        Session(cFINDSTAGEID) = Me.ddFindShow.SelectedValue
        ShowBatches()
    End Sub

    Private Sub ddFindShow_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddFindShow.SelectedIndexChanged
        ' Save for restore when page reloads
        Session(cFINDSTAGEID) = ddFindShow.SelectedValue   ' Save for restore when page reloads
        ShowBatches()
    End Sub

    ' Handle Link Buttons on top of Grid
    Protected Sub lnkRedir_Command(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.CommandEventArgs)

        Select Case e.CommandName.ToUpper
            Case "NEWMAINT"

                Dim strTemp As String = hdnDDListValue.Value
                Dim URL As String
                Dim aValues = strTemp.Split(cPIPE)
                Dim deptNo As Integer, stockCat As String, itemTypeAttr As String

                If aValues.Length = 3 Then
                    deptNo = CInt(aValues(0))
                    stockCat = aValues(1)
                    itemTypeAttr = aValues(2)
                Else
                    ShowMsg1("Error on Page. Invalid number of Items returned to create batch")
                    Exit Sub
                End If

                strTemp = hdnNotes.Value
                aValues = strTemp.Split(cPIPE)  ' split it to get the vendor No and vendor name

                Dim vendorNo As Integer = CInt(aValues(0))

                ' lookup up vendor name to ensure its correct
                Dim objData As New Data.BatchData()
                Dim vendorName As String = objData.GetVendorName(vendorNo)
                objData = Nothing

                ' Dim vendorName As String = aValues(1)

                Dim batchID As Long = CreateBatch(WorkflowType.ItemMaint, deptNo, vendorNo, vendorName, Session(cUSERID), stockCat, itemTypeAttr)
                If batchID <= 0 Then
                    ShowMsg1("Unable to Create Batch. Code Returned: " & batchID)
                Else
                    Session(cBATCHID) = batchID
                    URL = "IMAddRecords.aspx?w=n"
                    ' Send to Item Search Page to add Records
                    Response.Redirect(URL)
                End If

            Case "SEARCHITEMS"

                Dim batchID As Long = 0, URL As String
                Session(cBATCHID) = Nothing
                Session(cBATCHID) = batchID
                URL = "IMAddRecords.aspx?w=n"       ' Tell page its not modal
                Response.Redirect(URL)

            Case "NEWEDIT"

                Dim sParm() As String, URL As String
                ' should be 2 parms
                sParm = Split(e.CommandArgument.ToString, cPIPE)
                Try
                    URL = sParm(0) + "?hid=" + sParm(1)
                    Session(cBATCHID) = DataHelper.SmartValues(sParm(1), "long", False)
                    Response.Redirect(URL)
                Catch ex As Exception
                    ShowMsg1("Error calling Detail Page. Contact Support")
                End Try

        End Select

        ' Make sure all fields are cleared out
        hdnDDListValue.Value = ""
        hdnNotes.Value = ""

    End Sub

    Protected Sub gvBatches_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gvBatches.Sorting
        ' FJL Jan 2010
        ' Need to force sorting via our call to the Fetch Data routine

        ' if object sort are not set or not = gr sort expression force Ascending order
        If Me.objDSBatches.SelectParameters("sortCol").DefaultValue = Nothing _
                Or Me.objDSBatches.SelectParameters("sortDir").DefaultValue = Nothing _
                Or Me.objDSBatches.SelectParameters("sortCol").DefaultValue <> e.SortExpression _
                Or Me.objDSBatches.SelectParameters("sortDir").DefaultValue <> "A" Then
            Me.objDSBatches.SelectParameters("sortDir").DefaultValue = "A"    ' Force Ascending Order

        ElseIf Me.objDSBatches.SelectParameters("sortDir").DefaultValue = "A" Then
            Me.objDSBatches.SelectParameters("sortDir").DefaultValue = "D"    ' Force Descending Order
        End If

        ' set column to sort on
        Me.objDSBatches.SelectParameters("sortCol").DefaultValue = e.SortExpression
        'Save sort in session
        Session(cSORTEXPRESSION) = e.SortExpression
        Session(cSORTDIRECTION) = Me.objDSBatches.SelectParameters("sortDir").DefaultValue

        ' Any sorting should force page back to page 1 (0) of Results
        ' Changing the page index should force the grid to refresh with new parms
        gvBatches.PageIndex = 0

        Session(cPAGENUMBER) = 0 ' Sorting resets Page Index. Save it
        e.Cancel = True ' Cancel normal sort as its not supported with a LIST
    End Sub

    Private Sub PopulateActionDD(ByVal ddaction As DropDownList, ByVal BatchId As Long, ByVal stageTypeID As Integer, _
        ByVal stageSeq As Integer, ByVal CreatedBy As Long, Optional ByVal stageEnabled As Boolean = True)
        '***********this sub will take a grid action column drop down as input parameter and populate it based on the passed log id
        '**************************************************************************************
        ' FJL Feb 2010 Make sure user can do what we are giving them
        ' FJL Apr 2010 add logic to allow disapprove at Waitingforsku stage
        ' FJL Oct 2010 add logic to only allow remove for DBCs and Created user

        ValidateUser(BatchId)
        If UserCanEdit Then
            'If ((ValidateUser(BatchId) And NovaLibra.Coral.SystemFrameworks.Michaels.BatchAccess.Edit) = _
            '        NovaLibra.Coral.SystemFrameworks.Michaels.BatchAccess.Edit) Then
            If stageTypeID <> Models.WorkflowStageType.Completed AndAlso stageEnabled Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))

                If stageTypeID <> Models.WorkflowStageType.WaitingForSKU Then
                    ddaction.Items.Add(New ListItem("Approve", "1"))
                End If

                If stageTypeID <> Models.WorkflowStageType.Vendor AndAlso stageTypeID <> Models.WorkflowStageType.WaitingForSKU Then
                    ddaction.Items.Add(New ListItem("Disapprove", "2"))
                End If

                If stageTypeID <> Models.WorkflowStageType.WaitingForSKU _
                    AndAlso (CreatedBy = Session(cUSERID) OrElse IsAdminDBCQA() OrElse stageTypeID = Models.WorkflowStageType.Vendor) Then
                    ddaction.Items.Add(New ListItem("Remove", "3"))
                End If

                If stageTypeID = Models.WorkflowStageType.WaitingForSKU Then
                    ddaction.Items.Add(New ListItem("ReSubmit", "5"))   ' Allow User to Resubmit a batch to MQ
                End If

            ElseIf Not stageEnabled Then    ' No restore option yet
                'ddaction.Items.Add(New ListItem("Select action ", "0"))
                'ddaction.Items.Add(New ListItem("Restore", "4"))
            End If
        End If
    End Sub

    Private Sub ShowMsg1(ByVal strMsg As String, Optional ByVal type As String = "E")
        Dim curMsg As String
        If strMsg.Length = 0 Then
            lblNewItemMessage.Text = "&nbsp;" ' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
        Else
            curMsg = lblNewItemMessage.Text
            If curMsg = "&nbsp;" OrElse curMsg.Length = 0 Then       ' Only set the message if there is not one in there already
                lblNewItemMessage.Text = strMsg
                If type = "E" Then
                    lblNewItemMessage.CssClass = "redText"
                Else
                    lblNewItemMessage.CssClass = "greenText"
                End If
            Else
                lblNewItemMessage.Text += "<br />" & strMsg
                lblNewItemMessage.CssClass = "redText"
            End If
        End If
    End Sub

    'Private Sub ShowMsg1(ByVal strMsg As String)
    '    Dim curMsg As String
    '    If strMsg.Length = 0 Then
    '        lblNewItemMessage.Text = "&nbsp;" ' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
    '    Else
    '        curMsg = lblNewItemMessage.Text
    '        If curMsg = "&nbsp;" Then       ' Only set the message if there is not one in there already
    '            lblNewItemMessage.Text = strMsg
    '        Else
    '            lblNewItemMessage.Text += "<br />" & strMsg
    '        End If
    '    End If
    'End Sub

    Private Function isNormalStage(ByVal stageType As Integer) As Boolean
        Dim retValue As Boolean = False
        If stageType = Models.WorkflowStageType.General OrElse stageType = Models.WorkflowStageType.Vendor OrElse stageType = Models.WorkflowStageType.Tax Then
            retValue = True
        End If
        Return retValue
    End Function

    Private Sub ProcessActionButton(ByVal intAction As Integer, ByVal intBatchId As Long, ByVal intHeaderId As Long)
        'this function basically replaces Item_Actions.aspx for SPEDY2
        'validate user credentials
        'test Session("UserRole") = ""
        'validate tha batch is valid based on the batch id
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch
        Dim objBatchRecord As New NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord
        Dim isValid As Integer, intUserId As Integer, intWorkstageId As Integer, intStageType As Integer
        Dim cstype As Type = Me.GetType()

        intUserId = Session(cUSERID)
        objBatchRecord = objMichaels.GetRecord(intBatchId)
        intWorkstageId = objBatchRecord.WorkflowStageID
        intStageType = objBatchRecord.WorkflowStageType

        Select Case intAction
            Case 1 ' APPROVE
                isValid = objMichaels.GetRecord(intBatchId).IsValid

                ' DBCQA / Sys Admins can approve batches even if they are invalid as long as its a normal stage type
                If isValid < 0 AndAlso (Not IsAdminDBCQA() OrElse Not isNormalStage(intStageType)) Then
                    ShowMsg1("Please open this Log Item to ensure it Passes Validation before approving.")
                    objMichaels = Nothing
                ElseIf isValid = 0 AndAlso (Not IsAdminDBCQA() OrElse Not isNormalStage(intStageType)) Then
                    ShowMsg1("This Log Item has Validation errors. Please correct before approving.")
                    objMichaels = Nothing
                Else
                    ApproveItem(intBatchId, intWorkstageId, intUserId, objBatchRecord, intHeaderId, APPROVE)
                End If

            Case 2 ' DisApprove
                ' March 2010 FJL Use Batch History to disapprove rather than Exception logic  per Ken H
                ' Batch History retrieved using AJAX from LookupDisApproveStages.aspx during the time User enters reason for disapproval
                ' OLD --- ApproveItem(intBatchId, intWorkstageId, intUserId, objBatchRecord, intHeaderId, DISAPPROVE)

                Dim toStage As Integer = DataHelper.DBSmartValues(Me.hdnDDListValue.Value, "integer", False)
                Dim disApproveNotes = Me.hdnNotes.Value
                DisApproveBatch(intBatchId, toStage, intUserId, disApproveNotes, objBatchRecord)

            Case 3 'REMOVE
                Dim bDeleted As Boolean = Data.MaintItemMasterData.DeleteItemMaintBatchData(objBatchRecord.ID, intUserId)
                If Not bDeleted Then
                    ShowMsg1("Error occurred when removing Items from Batch: " + objBatchRecord.ID.ToString)
                End If
                objBatchRecord.Enabled = 0
                objBatchRecord.IsValid = -1
                objMichaels.SaveRecord(objBatchRecord, intUserId, "Remove", "")

            Case 4 ' UNDELETE (restore)
                ' RestoreBatch(intBatchId)  ' Not needed
                objBatchRecord.Enabled = 1
                objBatchRecord.IsValid = -1
                objMichaels.SaveRecord(objBatchRecord, intUserId, "Restore", "")

            Case 5 ' Resubmit message
                PublishMSMQMessage(intBatchId, AppHelper.GetUserID)
                ShowMsg1("Batch Changes have been Re-submitted to RMS.", "I")
            Case Else ' do nothing
        End Select

        ' Once the action is done, make sure the hdnnotes and DisApproval Stage ID fields are cleared out for the next record
        ' This is a global action because the hdnNotes can also be used for the Remove Action (which currently is not logged)
        Me.hdnNotes.Value = String.Empty
        Me.hdnDDListValue.Value = String.Empty

        ' refresh the grid based on current settings
        ShowBatches()

    End Sub

    Private Sub DisApproveBatch(ByVal intBatchID As Integer, ByVal intNextStage As Integer, ByVal intUserID As Integer, ByVal strNotes As String, _
        ByVal ObjBatchRec As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord)

        ' Verify that the Stage to send the batch to is specified.  If not then get the default for the current Stage
        If intNextStage <= 0 Then
            Dim StagesDict As Dictionary(Of Integer, Models.WorkflowStage)
            Dim objData As NovaLibra.Coral.Data.Michaels.BatchData = New NovaLibra.Coral.Data.Michaels.BatchData
            StagesDict = objData.GetStageListDict(ObjBatchRec.WorkflowStageID)
            If StagesDict.Count > 0 Then
                Dim curStage As Models.WorkflowStage = StagesDict(ObjBatchRec.WorkflowStageID)
                intNextStage = curStage.PreviousStage
                StagesDict.Clear()
            Else
                ShowMsg1("Can not determine Stage to send Batch to. Contact Support")
            End If
        End If

        ProcessApprovalTransaction(intBatchID, intNextStage, intUserID, DISAPPROVE, strNotes)
		Dim msgResult As String = MyBase.SendEmail(ObjBatchRec, intNextStage, ObjBatchRec.FinelineDeptID, DISAPPROVE, ObjBatchRec.VendorName, strNotes)
        If msgResult.Length > 0 Then
            ShowMsg1(msgResult)
        End If

    End Sub

    Private Sub ApproveItem(ByVal intBatchId As Integer, ByVal intWorkstageId As Integer, ByVal intUserId As Integer, _
        ByVal ObjBatchRec As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord, ByVal intHeaderId As Long, ByVal strApprType As String)

        '**********************LP approval Jan 2010********************************
        'get next default stage, check for exceptions
        'compare batch attributes with the exception condition attributes
        'process batch approval
        '************************************************************************
        ' FJL March 2010 - Change disapproval logic to be based on Batch History.  This routine only used for Approval logic

        Dim reader As SqlDataReader, intDefaultNextStageID As Integer, intNextStageId As Integer
        Dim intExceptId(100) As Integer, intExcepOrder(100) As Integer, intCondID(100), intTargetStageID(100) As Integer, strConjunction(100) As String
        Dim intExceptionCount, j, indexOfFoundCondition, intExcId As Integer
        Dim bExceptionCondMet As Boolean = False, bCondMet(100) As Boolean, strexcMet(100) As String, strsql As String
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        If strApprType = APPROVE Then
            strsql = "sp_SPD2_Approval_GetStageInfo"
        Else
            strsql = "sp_SPD2_Disapproval_GetStageInfo"     ' Should never be used now that we are doing disapproval via Batch History
        End If

        ' connection = New SqlConnection
        'connection.ConnectionString = ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString
        Try
            'Command = New SqlCommand
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = strsql
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "WorkflowStageId"
            param.DbType = DbType.Int32
            param.Value = intWorkstageId
            Command.Parameters.Add(param)

            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                intDefaultNextStageID = reader("Default_NextStage_ID")
            End While

            ' set Next stage as default 
            intNextStageId = intDefaultNextStageID

            'stored procedure returns 2 recordsets Read the exception list
            reader.NextResult()
            intExceptionCount = -1
            While reader.Read
                intExceptionCount += 1
                'now process exceptions here
                intExceptId(intExceptionCount) = reader("Exception_ID")
                intExcepOrder(intExceptionCount) = reader("Exception_order")
                intTargetStageID(intExceptionCount) = reader("Target_Stage_ID")
                intCondID(intExceptionCount) = reader("Condition_id")
                strConjunction(intExceptionCount) = IIf(IsDBNull(reader("Conjunction")), "", reader("Conjunction"))
            End While
            reader.Close()
            Command.Connection.Close()

            ' FJL Mar 2010  update logic to ensure all conditions checked appropriately
            Dim firstone As Boolean
            ' Were conditions read?
            If intExceptionCount >= 0 Then
                j = 0
                Do While j <= intExceptionCount
                    intExcId = intExceptId(j)
                    firstone = True     ' firstone keep strack of the need to use any conjunction verb defined in the set

                    Do While intExcId = intExceptId(j) ' loop through all conditions per given exception
                        bCondMet(j) = False
                        Select Case intCondID(j)
                            Case DOMESTICITEM
                                If ObjBatchRec.BatchTypeID = BATCHTYPEDOMESTIC Then bCondMet(j) = True
                            Case IMPORTITEM
                                If ObjBatchRec.BatchTypeID = BATCHTYPEIMPORT Then bCondMet(j) = True
                            Case SEASONALATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, "S") Then bCondMet(j) = True
                            Case BASICATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, "B") Then bCondMet(j) = True
                            Case FIXTUREATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, "F") Then bCondMet(j) = True
                            Case GIVEAWAYATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, "G") Then bCondMet(j) = True
                            Case SUPPLIERSATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, "P") Then bCondMet(j) = True
                            Case TESTATRRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, "T") Then bCondMet(j) = True
                            Case QUICKCODEATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, "Q") Then bCondMet(j) = True
                            Case PRICINGCHECK
                                If PricingValidationCheck(ObjBatchRec, intHeaderId) Then bCondMet(j) = True
                            Case DEPARTMENTS
                                If DepartmentsExcFound(ObjBatchRec.ID, intExcId, intCondID(j)) Then bCondMet(j) = True
                            Case MODIFIEDFIELDS
                                If ModifiedFieldsExceptionFound(ObjBatchRec.ID, intExcId, intCondID(j)) Then bCondMet(j) = True
                            Case PACKITEMDISPLAYPACK
                                ' match on any packitemtype that starts with DP
                                If ConditionDisplayPackfound(ObjBatchRec.ID, "DP", False) Then bCondMet(j) = True
                            Case PACKITEMDISPLAYER
                                If ConditionDisplayPackfound(ObjBatchRec.ID, "D", False) Or ConditionDisplayPackfound(ObjBatchRec.ID, "SB", False) Then bCondMet(j) = True
                            Case STOCKCATEGORYWAREHOUSE
                                If ConditionStockFound(ObjBatchRec.ID, "W") Then bCondMet(j) = True
                            Case STOCKCATEGORYDIRECT
                                If ConditionStockFound(ObjBatchRec.ID, "D") Then bCondMet(j) = True
                            Case ITEMTYPEREGULARITEM
                                If ConditionItemTypeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "R") Then bCondMet(j) = True
                            Case ITEMTYPETYPECOMPLEXPACK
                                If ConditionItemTypeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "C") Then bCondMet(j) = True
                            Case ITEMTYPESIMPLEPACK
                                If ConditionItemTypeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "S") Then bCondMet(j) = True
                            Case HEAVYPACK
                                If ConditionHeavyPackWeight(ObjBatchRec.ID) Then bCondMet(j) = True
                            Case PACKITEMD_PDQ
                                If ConditionDisplayPackfound(ObjBatchRec.ID, "D-PDQ", True) Then bCondMet(j) = True
                            Case PACKITEMD_PIAB
                                If ConditionDisplayPackfound(ObjBatchRec.ID, "D-PIAB", True) Then bCondMet(j) = True
                            Case PACKITEMDP_PDQ
                                If ConditionDisplayPackfound(ObjBatchRec.ID, "DP-PDQ", True) Then bCondMet(j) = True
                            Case PACKITEMDP_PIAB
                                If ConditionDisplayPackfound(ObjBatchRec.ID, "DP-PIAB", True) Then bCondMet(j) = True
                            Case PACKITEMDP_NEITHER
                                ' match only packitem type = "DP" (i.e. not DP-PDQ, not DP-PIAB)
                                If ConditionDisplayPackfound(ObjBatchRec.ID, "DP", True) Then bCondMet(j) = True
                            Case NONSEASONALATTRIBUTE
                                ' returns true if any items are not seasonal (S)
                                If ConditionNotAttributeFound(ObjBatchRec.ID, "S") Then bCondMet(j) = True
                            Case COMPONENTCHANGES
                                ' returns true if any components have been added, removed, or edited component qty (QtyInPack)
                                If ConditionComponentChanges(ObjBatchRec.ID) Then bCondMet(j) = True
                            Case SOURCINGBATCH
                                If ConditionSourcingBatchFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case WORKFLOWCONTAINSREJECT
                                If ConditionActionFound(ObjBatchRec.ID, "disapprove") Then bCondMet(j) = True
                            Case BATCHUPDATEDINSPEDY
                                If ConditionBatchUpdateFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case NOTSOURCINGBATCH
                                If Not ConditionSourcingBatchFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case WORKFLOWHASNOREJECT
                                If Not ConditionActionFound(ObjBatchRec.ID, "disapprove") Then bCondMet(j) = True
                            Case BATCHNOTUPDATEDINSPEDY
                                'This WF is not supported in Item Maintenance.
                                'If Not ConditionBatchUpdateFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case PLISNOTALLYES
                                If ConditionPLIsNotAllYes(ObjBatchRec, intHeaderId) Then bCondMet(j) = True
                            Case CREATEDBYIMPORTMGR
                                'If the user that created the bach is an Import Manager, then 
                                If LookupGroups(WebConstants.SecurityGroups.ImportMgr, ObjBatchRec.CreatedUser) Then bCondMet(j) = True
                            Case SPEDYMODIFIEDFIELDS
                                If SpedyModifiedFieldsExceptionFound(ObjBatchRec.ID, intExcId, intCondID(j)) Then bCondMet(j) = True
                            Case NONQUICKCODEATTRIBUTE
                                ' returns true if any items are not Quickcode (Q)
                                If ConditionNotAttributeFound(ObjBatchRec.ID, "Q") Then bCondMet(j) = True
                            Case ALLSEASONALATTRIBUTE
                                ' returns true if all items are seasonal (S)
                                If Not ConditionNotAttributeFound(ObjBatchRec.ID, "S") Then bCondMet(j) = True
                        End Select

                        If firstone Then
                            bExceptionCondMet = bCondMet(j)
                            firstone = False
                        Else
                            If UCase(strConjunction(j - 1)) = "AND" Then
                                bExceptionCondMet = bExceptionCondMet And bCondMet(j)
                            Else
                                bExceptionCondMet = bExceptionCondMet Or bCondMet(j)
                            End If
                        End If

                        If bExceptionCondMet Then indexOfFoundCondition = j
                        j += 1
                    Loop    ' scan of like exception records

                    'if exception conditions met, ignore the rest of exceptions!
                    If bExceptionCondMet Then
                        intNextStageId = intTargetStageID(indexOfFoundCondition)
                        Exit Do
                    End If
                Loop    ' End of scan execption records
            End If

            Dim notes As String = Me.hdnNotes.Value
            ProcessApprovalTransaction(intBatchId, intNextStageId, intUserId, strApprType, notes)
            Me.hdnNotes.Value = String.Empty

            'now, if stage type is "waiting for SKU, send rms message
            Dim procOK As Boolean = True
            If GetStageType(intNextStageId) = Models.WorkflowStageType.WaitingForSKU Then
                procOK = PublishMSMQMessage(intBatchId, AppHelper.GetUserID)
            End If

            If procOK Then
				Dim msgResult As String = MyBase.SendEmail(ObjBatchRec, intNextStageId, ObjBatchRec.FinelineDeptID, strApprType, ObjBatchRec.VendorName, notes)
                If msgResult.Length > 0 Then
                    ShowMsg1(msgResult)
                End If
            Else    ' Send the batch back to the Stage it was at due to error
                ProcessApprovalTransaction(intBatchId, intWorkstageId, intUserId, DISAPPROVE, "Error Occurred in Batch Completion Process")
            End If

        Catch ex As Exception
            ProcessException(ex, "ApproveItem")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

    End Sub

    Private Function PricingValidationCheck(ByVal objBathcrec As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord, ByVal intHeaderId As Long) As Boolean

        ' Specific to Item Master Record format with change records applied
        ' FJL Oct 2010
        Dim isPriceCheckfailed As Boolean = False, i As Integer

        ' Get the records in the batch
        Dim objRecords As New List(Of Models.ItemMaintItemDetailRecord)
        objRecords = Data.MaintItemMasterData.GetItemMaintItemsByBatchID(objBathcrec.ID)

        ' Get the changes records for the batch
        Dim changes As Models.IMTableChanges = Nothing
        changes = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(objBathcrec.ID)

        Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        Dim record As Models.ItemMaintItemDetailRecord
        Dim rowChanges As Models.IMRowChanges

        i = 0
        While i <= objRecords.Count And Not isPriceCheckfailed
            record = objRecords(i)
            ' get the change records for this Item record
            rowChanges = changes.GetRow(record.ID)

            ' Merge the changes into the item record
            FormHelper.FlattenItemMaintRecord(record, rowChanges, table)
            If Not isPriceCheckfailed AndAlso record IsNot Nothing Then
                If record.Base2Retail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.TestRetail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.High2Retail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.High3Retail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.SmallMarketRetail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.High1Retail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.Base3Retail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.Low1Retail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.Low2Retail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                ElseIf record.ManhattanRetail <> record.Base1Retail Then
                    isPriceCheckfailed = True

                    'MWM: Removed 2019-08-27 they no longer want to compare this
                    'ElseIf record.CanadaRetail <> 0 Then  'NAK 6/11/2012: Not sure if this is right, or if it should only validate when SKUGroup has Canada
                    '    If record.QuebecRetail <> record.CanadaRetail Then
                    '        isPriceCheckfailed = True
                    '    End If
                ElseIf record.PuertoRicoRetail <> record.Base1Retail Then
                    isPriceCheckfailed = True
                End If

                'MWM: Removed 2019-08-27 they no longer want to look at pricing grid for canada pricing
                'If record.SKUGroup.IndexOf("CANADA") > 0 Then
                '    If Not CheckPricingGrid(record.CanadaRetail, record.Base1Retail) Then isPriceCheckfailed = True
                'End If


            End If

            If rowChanges IsNot Nothing Then
                rowChanges.Dispose()
            End If

            record = Nothing
            i += 1
        End While

        objRecords.Clear()
        objRecords = Nothing
        changes.Dispose()
        changes = Nothing
        table = Nothing

        Return isPriceCheckfailed
    End Function

    Private Function CheckPricingGrid(ByVal canadianprice As Decimal, ByVal base As Decimal) As Boolean
        'this function validates canadian price and base price4 against pricing grid table
        'LP Jan 11 2009

        ' returns false if validation pricing grid table(SPD_Price_Point) does not have a row containing passing values
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Dim sql As String = "SP_SPD2_PriceGrid_Row"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Try
            'Command = New SqlCommand
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "CanadaRetail"
            param.DbType = DbType.String
            param.Value = canadianprice
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BaseRetail"
            param.DbType = DbType.String
            param.Value = base
            Command.Parameters.Add(param)

            Command.CommandText = sql
            Command.Connection.Open()
            reader = Command.ExecuteReader()

            While reader.Read
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "CheckPricingGrid")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function


    Function ModifiedFieldsExceptionFound(ByVal nBatchRecID As Long, ByVal nExceptionID As Integer, ByVal nConditionID As Integer) As Boolean

        Dim ret As Boolean = False

        Dim conn As New SqlConnection
        conn.ConnectionString = ConnectionString

        Dim cmd As New SqlCommand("SP_SPD2_Batch_Exception_Fields", conn)
        cmd.CommandType = CommandType.StoredProcedure

        Try
            Dim p As SqlParameter = cmd.CreateParameter
            p.ParameterName = "BatchID"
            p.SqlDbType = SqlDbType.BigInt
            p.Value = nBatchRecID
            cmd.Parameters.Add(p)

            p = cmd.CreateParameter
            p.ParameterName = "Exception_ID"
            p.SqlDbType = SqlDbType.Int
            p.Value = nExceptionID
            cmd.Parameters.Add(p)

            p = cmd.CreateParameter
            p.ParameterName = "Condition_Order"
            p.SqlDbType = SqlDbType.Int
            p.Value = nConditionID
            cmd.Parameters.Add(p)

            cmd.Connection.Open()
            Dim reader As SqlDataReader = cmd.ExecuteReader
            If reader.Read Then
                ret = True
            End If
            reader.Close()
            cmd.Connection.Close()

        Catch ex As Exception
            ProcessException(ex, "ModifiedFieldsExceptionFound")
            If cmd.Connection.State = ConnectionState.Open Then cmd.Connection.Close()
        Finally
            cmd.Dispose()
            conn.Dispose()
        End Try

        Return ret

    End Function

    Function SpedyModifiedFieldsExceptionFound(ByVal nBatchRecID As Long, ByVal nExceptionID As Integer, ByVal nConditionID As Integer) As Boolean

        Dim ret As Boolean = False

        Dim conn As New SqlConnection
        conn.ConnectionString = ConnectionString

        Dim cmd As New SqlCommand("SP_SPD2_Batch_Exception_Fields_InSPEDY", conn)
        cmd.CommandType = CommandType.StoredProcedure

        Try
            Dim p As SqlParameter = cmd.CreateParameter
            p.ParameterName = "BatchID"
            p.SqlDbType = SqlDbType.BigInt
            p.Value = nBatchRecID
            cmd.Parameters.Add(p)

            p = cmd.CreateParameter
            p.ParameterName = "Exception_ID"
            p.SqlDbType = SqlDbType.Int
            p.Value = nExceptionID
            cmd.Parameters.Add(p)

            p = cmd.CreateParameter
            p.ParameterName = "Condition_Order"
            p.SqlDbType = SqlDbType.Int
            p.Value = nConditionID
            cmd.Parameters.Add(p)

            cmd.Connection.Open()
            Dim reader As SqlDataReader = cmd.ExecuteReader
            If reader.Read Then
                ret = True
            End If
            reader.Close()
            cmd.Connection.Close()

        Catch ex As Exception
            ProcessException(ex, "ModifiedFieldsExceptionFound")
            If cmd.Connection.State = ConnectionState.Open Then cmd.Connection.Close()
        Finally
            cmd.Dispose()
            conn.Dispose()
        End Try

        Return ret

    End Function

    Function DepartmentsExcFound(ByVal ObjBatchRecId As Long, ByVal intExcId As Integer, ByVal intCondID As Integer) As Boolean
        'LP Jan 13 2009
        'This function calls stored procedure which returns rows
        'if Batch department is actually matching an exception department list
        Dim sql As String = "SP_SPD2_Batch_Exception_Depts"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchID"
            param.DbType = DbType.Int32
            param.Value = ObjBatchRecId
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "ExcID"
            param.DbType = DbType.Int32
            param.Value = intExcId
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "ExcCondID"
            param.DbType = DbType.Int32
            param.Value = intCondID
            Command.Parameters.Add(param)
            Command.CommandText = sql
            Command.Connection.Open()
            reader = Command.ExecuteReader()

            While reader.Read
                'Batch belongs to department which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            'need a way to log exception
            ProcessException(ex, "DepartmentsExcFound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    Private Function ConditionComponentChanges(ByVal intBatchID As Long) As Boolean

        Dim ret As Boolean = False

        ' this proc will return non-zero values if any items have been added, removed, or had updated component qty
        ' within a D or DP batch
        Dim sSQL As String = "sp_spd2_Batch_Exception_Component_Changes"
        Dim reader As SqlDataReader
        Dim conn As New SqlConnection(ConnectionString)
        Dim cmd As New SqlCommand(sSQL, conn)
        Dim param As SqlParameter

        cmd.CommandType = CommandType.StoredProcedure

        Try
            param = cmd.CreateParameter
            param.Direction = ParameterDirection.Input
            param.ParameterName = "batchID"
            param.DbType = DbType.Int64
            param.Value = intBatchID
            cmd.Parameters.Add(param)

            cmd.Connection.Open()
            reader = cmd.ExecuteReader
            While reader.Read
                Dim addLen As Integer = reader("AddLen")
                Dim remLen As Integer = reader("RemovedLen")
                Dim changeCtr As Integer = reader("ChangeCount")
                If addLen > 0 Or remLen > 0 Or changeCtr > 0 Then
                    ret = True
                End If
            End While
            reader.Close()
            cmd.Connection.Close()

        Catch ex As Exception
            ProcessException(ex, "ConditionComponentChanges")
            If cmd.Connection.State = ConnectionState.Open Then cmd.Connection.Close()
        Finally
            cmd.Dispose()
            conn.Dispose()
            cmd = Nothing
            conn = Nothing
            reader = Nothing
        End Try

        Return ret

    End Function

    Private Function ConditionNotAttributeFound(ByVal intBatchID As Long, ByVal itemattrib As String) As Boolean

        Dim ret As Boolean = False

        ' this proc returns rows that do not match the input item-type-attribute
        Dim sSQL As String = "SP_SPD2_Batch_Exception_Not_Attributes_ItemMaint"
        Dim reader As SqlDataReader
        Dim conn As New SqlConnection
        Dim cmd As New SqlCommand
        Dim param As SqlParameter
        conn.ConnectionString = ConnectionString

        Try
            cmd.Connection = conn
            cmd.CommandType = CommandType.StoredProcedure

            param = cmd.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            cmd.Parameters.Add(param)

            param = Nothing
            param = cmd.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "Attribute"
            param.DbType = DbType.String
            param.Value = itemattrib
            cmd.Parameters.Add(param)

            cmd.CommandText = sSQL
            cmd.Connection.Open()

            reader = cmd.ExecuteReader
            While reader.Read
                ret = True
            End While
            reader.Close()
            cmd.Connection.Close()

        Catch ex As Exception
            ProcessException(ex, "ConditionAttributeNotFound")
            If cmd.Connection.State = ConnectionState.Open Then cmd.Connection.Close()
        Finally
            cmd.Dispose()
            conn.Dispose()
            cmd = Nothing
            conn = Nothing
            reader = Nothing
        End Try

        Return ret

    End Function

    Private Function ConditionPLIsNotAllYes(ByVal objBathcrec As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord, ByVal intHeaderId As Long) As Boolean

        ' Specific to Item Master Record format with change records applied
        Dim isAllPLIsYes As Boolean = True
        Dim i As Integer = 0

        ' Get the records in the batch
        Dim objRecords As New List(Of Models.ItemMaintItemDetailRecord)
        objRecords = Data.MaintItemMasterData.GetItemMaintItemsByBatchID(objBathcrec.ID)

        ' Get the changes records for the batch
        Dim changes As Models.IMTableChanges = Nothing
        changes = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(objBathcrec.ID)

        Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        Dim record As Models.ItemMaintItemDetailRecord
        Dim rowChanges As Models.IMRowChanges

        While i < objRecords.Count And isAllPLIsYes
            record = objRecords(i)

            'Get language settings from SPD_Item_Master_Languages
            Dim languageDT As DataTable = Data.MaintItemMasterData.GetItemLanguages(record.SKU, record.VendorNumber)
            If languageDT.Rows.Count > 0 Then
                'For Each language row, set the front end controls
                For Each language As DataRow In languageDT.Rows
                    Dim languageTypeID As Integer = DataHelper.SmartValues(language("Language_Type_ID"), "CInt", False)
                    Dim pli As String = DataHelper.SmartValues(language("Package_Language_Indicator"), "CStr", False)
                    Dim ti As String = DataHelper.SmartValues(language("Translation_Indicator"), "CStr", False)
                    Dim descShort As String = DataHelper.SmartValues(language("Description_Short"), "CStr", False)
                    Dim descLong As String = DataHelper.SmartValues(language("Description_Long"), "CStr", False)
                    Dim exemptEndDate As String = DataHelper.SmartValues(language("Exempt_End_Date"), "CStr", False)
                    Select Case languageTypeID
                        Case 1
                            record.PLIEnglish = pli
                            record.TIEnglish = ti
                            record.EnglishShortDescription = descShort
                            record.EnglishLongDescription = descLong
                        Case 2
                            record.PLIFrench = pli
                            record.TIFrench = ti
                            record.FrenchShortDescription = descShort
                            record.FrenchLongDescription = descLong
                            record.ExemptEndDateFrench = exemptEndDate
                        Case 3
                            record.PLISpanish = pli
                            record.TISpanish = ti
                            record.SpanishShortDescription = descShort
                            record.SpanishLongDescription = descLong
                    End Select
                Next
            End If

            ' get the change records for this Item record
            rowChanges = changes.GetRow(record.ID)

            ' Merge the changes into the item record
            FormHelper.FlattenItemMaintRecord(record, rowChanges, table)

            'Check to make sure all the PLIs are set to "YES"
            If record.PLIEnglish <> "Y" Or record.PLIFrench <> "Y" Or record.PLISpanish <> "Y" Then
                isAllPLIsYes = False

                If rowChanges IsNot Nothing Then
                    rowChanges.Dispose()
                End If

                record = Nothing
                Exit While
            End If

            'Clear Row Changes, if they exist.
            If rowChanges IsNot Nothing Then
                rowChanges.Dispose()
            End If

            record = Nothing
            i += 1
        End While

        objRecords.Clear()
        objRecords = Nothing
        changes.Dispose()
        changes = Nothing
        table = Nothing

        Return (Not isAllPLIsYes)
    End Function

    Private Function ConditionAttributeFound(ByVal intBatchID As Long, ByVal itemattrib As String) As Boolean
        'this function will check passed batch for presence of the exception condition itemattributes
        Dim sql As String = "sp_SPD2_Batch_Exception_Attributes_ItemMaint"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "Attribute"
            param.DbType = DbType.String
            param.Value = itemattrib
            Command.Parameters.Add(param)

            Command.CommandText = sql
            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                'Batch has attribute which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionAttributeFound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    Private Function ConditionHeavyPackWeight(ByVal intBatchID As Long) As Boolean

        Dim sql As String = "sp_spd2_Batch_Exception_HeavyPack_ItemMaint"
        Dim reader As SqlDataReader
        Dim retvalue As Boolean = False
        Dim conn As New SqlConnection(ConnectionString)
        Dim cmd As New SqlCommand(sql, conn)
        cmd.CommandType = CommandType.StoredProcedure

        Try
            Dim pBatchID As SqlParameter = cmd.CreateParameter
            pBatchID.Direction = ParameterDirection.Input
            pBatchID.ParameterName = "batchID"
            pBatchID.DbType = DbType.Int32
            pBatchID.Value = intBatchID
            cmd.Parameters.Add(pBatchID)

            cmd.Connection.Open()
            reader = cmd.ExecuteReader
            While reader.Read
                retvalue = True
            End While
            reader.Close()
            cmd.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionHeavyPackWeight")
            If cmd.Connection.State = ConnectionState.Open Then cmd.Connection.Close()
        Finally
            cmd.Dispose()
            conn.Dispose()
            cmd = Nothing
            conn = Nothing
            reader = Nothing
        End Try

        Return retvalue

    End Function

    Private Function ConditionStockFound(ByVal intBatchID As Long, ByVal itemcateg As String) As Boolean
        'this function will check passed batch for presence of the exception condition stockcategories
        Dim sql As String = "SP_SPD2_Batch_Exception_StockCategories_ItemMaint"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "Category"
            param.DbType = DbType.String
            param.Value = itemcateg
            Command.Parameters.Add(param)
            Command.CommandText = sql
            Command.Connection.Open()

            reader = Command.ExecuteReader()
            While reader.Read
                'Batch has attribute which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionStockFound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    Private Function ConditionItemTypeFound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer, ByVal itemtype As String) As Boolean
        'this function will check passed batch for presence of the exception condition Item Type
        Dim sql As String = "SP_SPD2_Batch_Exception_ItemTypes_ItemMaint"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            Command.Parameters.Add(param)

            'param = Nothing
            'param = Command.CreateParameter()
            'param.Direction = ParameterDirection.Input
            'param.ParameterName = "BatchType"
            'param.DbType = DbType.Int32
            'param.Value = intBatchTypeID
            'Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "Itemtype"
            param.DbType = DbType.String
            param.Value = itemtype
            Command.Parameters.Add(param)
            Command.CommandText = sql
            Command.Connection.Open()

            reader = Command.ExecuteReader()
            While reader.Read
                'Batch has attribute which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionItemTypeFound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    Private Function ConditionDisplayPackfound(ByVal intBatchID As Long, ByVal packitemvalue As String, ByVal bExact As Boolean) As Boolean
        'ByVal intBatchTypeID As Integer,
        'how do we process, for domestic batches if one child has this indicator, the whole batch is qualified for exception, for import - use parent
        'LP jan 14 2010
        Dim sql As String = "SP_SPD2_Batch_Exception_PackItemIndicator_ItemMaint"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "Indicator"
            param.DbType = DbType.String
            param.Value = packitemvalue
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter
            param.Direction = ParameterDirection.Input
            param.ParameterName = "exact"
            param.DbType = DbType.Boolean
            param.Value = bExact
            Command.Parameters.Add(param)

            Command.CommandText = sql
            Command.Connection.Open()

            reader = Command.ExecuteReader()
            While reader.Read
                'Batch has attribute which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionDisplayPackfound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    Private Function ConditionActionFound(ByVal intBatchID As Long, ByVal batchAction As String) As Boolean
        'this function will check passed batch for presence of the exception condition itemattributes
        Dim sql As String = "SP_SPD2_Batch_Exception_Action"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "batchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "Action"
            param.DbType = DbType.String
            param.Value = batchAction
            Command.Parameters.Add(param)

            Command.CommandText = sql
            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                'Batch has attribute which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionActionFound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    Private Function ConditionBatchUpdateFound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer) As Boolean
        'this function will check passed batch for presence of the exception condition itemattributes
        Dim sql As String = "SP_SPD2_Batch_Exception_BatchUpdate"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "batchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = intBatchTypeID
            Command.Parameters.Add(param)

            Command.CommandText = sql
            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                'Batch has attribute which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionBatchUpdateFound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    Private Function ConditionSourcingBatchFound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer) As Boolean
        'this function will check passed batch for presence of the exception condition itemattributes
        Dim sql As String = "SP_SPD2_Batch_Exception_SourcingBatch_ItemMaint"
        Dim reader As SqlDataReader, retvalue As Boolean = False
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "batchID"
            param.DbType = DbType.Int32
            param.Value = intBatchID
            Command.Parameters.Add(param)

            Command.CommandText = sql
            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                'Batch has attribute which is part of exception
                retvalue = True
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ConditionSourcingBatchFound")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If
        End Try

        Return retvalue
    End Function

    'Private Sub SendEmail(ByVal batch_id As Long, ByVal intNextStageId As Integer, ByVal DeptId As Integer, ByVal approvaltype As String, ByVal vendor_name As String, ByVal notes As String)
    '    'this procedure sends e-mail to users who have rights to approve, based on departments adn workflow group
    '    'get a full list of people responsible for this batch
    '    'saved variables names of the original code of Item_action.aspx
    '    Dim sql As String, current_owner_email As String, current_owner As String, vcTo As String
    '    Dim vcSender, vcFrom As String, vcCC As String, vcBCC As String, vcSMTPServer As String = String.Empty, spedyURL As String = String.Empty
    '    Dim e_mailsubject As String, e_mailbody As String, bAutoGenerateTextBody As Integer = 1, bAuthenticate As Byte = 0

    '    Dim reader As SqlDataReader
    '    Dim connection As SqlConnection = New SqlConnection
    '    Dim Command As SqlCommand = New SqlCommand
    '    Dim param As SqlParameter
    '    connection.ConnectionString = ConnectionString

    '    sql = "sp_SPD2_Approval_GetEmailList"
    '    Try
    '        Command.Connection = connection
    '        Command.CommandType = CommandType.StoredProcedure

    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "WorkflowStageId"
    '        param.DbType = DbType.Int32
    '        param.Value = intNextStageId
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "DeptID"
    '        param.DbType = DbType.Int32
    '        param.Value = DeptId
    '        Command.Parameters.Add(param)

    '        vcTo = String.Empty
    '        Command.CommandText = sql
    '        Command.Connection.Open()
    '        reader = Command.ExecuteReader()
    '        While reader.Read
    '            current_owner_email = reader("email_address").ToString
    '            current_owner = reader("first_name").ToString & " " & reader("last_name").ToString
    '            vcTo = vcTo & " " & current_owner & " <" & current_owner_email & ">;"
    '        End While
    '        reader.Close()
    '        Command.Connection.Close()

    '        ' FJL Feb 2010 - Get addresses from Web Config for DEV, BETA, PROD, and VENDOR backup
    '        Dim toEmailAddresses As String = String.Empty, ccEmailAddresses As String = String.Empty, env As String
    '        env = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("Environment"), "stringu", False)

    '        Select Case env
    '            Case "DEV"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSpedyURL"), "string", False)
    '            Case "BETA"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASpedyURL"), "string", False)
    '            Case "PROD"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSpedyURL"), "string", False)
    '            Case "VENDOR"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORSmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORSpedyURL"), "string", False)
    '            Case Else
    '                toEmailAddresses = String.Empty
    '                ccEmailAddresses = String.Empty
    '                vcSMTPServer = String.Empty
    '                spedyURL = String.Empty
    '                ShowMsg1("Invalid email Config in Web.Config. Contact Support")
    '                Exit Sub
    '        End Select

    '        ' Used to dump the email addresses for Beta and Dev enviroments email
    '        Dim emailQueryResults As String = vcTo

    '        ' User email addresses from SQL query only if PROD and query returns records
    '        If (env <> "PROD" And env <> "VENDOR") OrElse vcTo.Length = 0 Then
    '            vcTo = toEmailAddresses
    '        End If

    '        vcCC = ccEmailAddresses

    '        'need to add Notes to e-mail! 
    '        If approvaltype = DISAPPROVE Then
    '            e_mailsubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved items for " & vendor_name & " Log ID# " & batch_id

    '            e_mailbody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved items for " & vendor_name & " Log ID# " & _
    '                batch_id & " for the following reason:<BR><BR> " & notes & "<BR><BR>" & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & _
    '                " can be contacted at " & Session(cEMAIL) & "<BR><BR>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review ASAP."
    '        Else
    '            e_mailsubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved items for " & vendor_name & " Log ID# " & batch_id

    '            e_mailbody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved items for " & vendor_name & " Log ID# " & _
    '                batch_id & ".<BR><BR> " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " can be contacted at " & _
    '                 Session(cEMAIL) & "<BR><BR>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review ASAP."
    '        End If

    '        ' Get Email From info from Web.config
    '        vcSender = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("FromEmailAddress"), "string", False)
    '        If vcSender.Length = 0 Then vcSender = "DATAFLOW@michaels.com"

    '        vcFrom = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("FromEmailName"), "string", False)
    '        If vcFrom.Length = 0 Then vcFrom = "Michaels DataFlow" '    "'" &  Session(cEMAIL) & "'"

    '        vcBCC = ""

    '        If env = "DEV" OrElse env = "BETA" Then
    '            e_mailsubject = "SPEDY System Test Message, Please Disregard! " & e_mailsubject
    '            e_mailbody = e_mailbody & " <br /><br />TO Email Addresses returned by query:<br /><code>" & Server.HtmlEncode(emailQueryResults) & "</code>"
    '        End If

    '        If vcSMTPServer.Length = 0 Then     ' JIC its not in the Web.Config file
    '            If Request.ServerVariables("HTTP_HOST") = "michaels.novalibra.com" Or _
    '                Request.ServerVariables("HTTP_HOST") = "spedy.novalibra.com" Or _
    '                InStr(Request.ServerVariables("HTTP_HOST"), "localhost:") <> 0 Then
    '                vcSMTPServer = "192.168.1.9"
    '            Else
    '                vcSMTPServer = "mail.michaels.com"
    '            End If
    '        End If

    '        sql = "sp_SQLSMTPMail"
    '        Command.Parameters.Clear()
    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcSender"
    '        param.DbType = DbType.String
    '        param.Value = vcSender
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcFrom"
    '        param.DbType = DbType.String
    '        param.Value = vcFrom
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcTo"
    '        param.DbType = DbType.String
    '        param.Value = vcTo
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcCC"
    '        param.DbType = DbType.String
    '        param.Value = vcCC
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcBCC"
    '        param.DbType = DbType.String
    '        param.Value = vcBCC
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcSubject"
    '        param.DbType = DbType.String
    '        param.Value = e_mailsubject
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcHTMLBody"
    '        param.DbType = DbType.String
    '        param.Value = e_mailbody
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "bAutoGenerateTextBody"
    '        param.DbType = DbType.Byte
    '        param.Value = bAutoGenerateTextBody
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "vcSMTPServer"
    '        param.DbType = DbType.String
    '        param.Value = vcSMTPServer
    '        Command.Parameters.Add(param)

    '        param = Nothing
    '        param = Command.CreateParameter()
    '        param.Direction = ParameterDirection.Input
    '        param.ParameterName = "bAuthenticate"
    '        param.DbType = DbType.Byte
    '        param.Value = bAuthenticate
    '        Command.Parameters.Add(param)

    '        Command.Connection.Open()
    '        Command.CommandText = sql
    '        Command.ExecuteScalar()
    '        Command.Connection.Close()
    '    Catch ex As Exception
    '        'need a way to log exception
    '        ProcessException(ex, "SendMail")
    '        If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
    '    Finally
    '        Command.Dispose()
    '        connection.Dispose()
    '        Command = Nothing
    '        connection = Nothing
    '        reader = Nothing
    '    End Try
    'End Sub

    Private Function PublishMSMQMessage(ByVal batchId As Long, ByVal userID As Long) As Boolean
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        Dim procOK As Boolean = True
        connection.ConnectionString = ConnectionString

        Try
            'Command = New SqlCommand
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "usp_SPD_ItemMaint_PublishMQMessageByBatchID"

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "@BatchID"
            param.DbType = DbType.Int32
            param.Value = batchId
            Command.Parameters.Add(param)

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "@UserID"
            param.DbType = DbType.Int64
            param.Value = userID
            Command.Parameters.Add(param)

            Command.Connection.Open()
            Command.ExecuteScalar()
            Command.Connection.Close()
        Catch ex As Exception
            procOK = False
            ProcessException(ex, "PublishMSMQMessage")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
        End Try
        Return procOK

    End Function

    Private Sub ProcessApprovalTransaction(ByVal intBatchId As Long, ByVal nextStageId As Integer, ByVal intUserId As Integer, ByVal ApprType As String, Optional ByVal strNotes As String = "")
        Dim iret As Integer
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "sp_SPD2_Approve_Batch"
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "WorkflowStageId"
            param.DbType = DbType.Int32
            param.Value = nextStageId
            Command.Parameters.Add(param)
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchId"
            param.DbType = DbType.Int32
            param.Value = intBatchId
            Command.Parameters.Add(param)
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "UserId"
            param.DbType = DbType.Int32
            param.Value = intUserId
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "ApprType"
            param.DbType = DbType.String
            param.Value = ApprType
            Command.Parameters.Add(param)

            If strNotes <> String.Empty Then
                param = Nothing
                param = Command.CreateParameter()
                param.Direction = ParameterDirection.Input
                param.ParameterName = "Notes"
                param.DbType = DbType.String
                param.Value = strNotes
                Command.Parameters.Add(param)
            End If

            Command.Connection.Open()
            iret = Command.ExecuteScalar
            Command.Connection.Close()
        Catch ex As Exception
            ProcessException(ex, "ProcessApprovalTransaction")
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
        End Try
    End Sub

    Private Sub ProcessException(ByVal e As Exception, ByVal strSourceName As String)
        Dim strmessage As String
        strmessage = "Unexpected SPEDY problem has occured in the routine: " & strSourceName & " - "
        strmessage = strmessage & e.Message & ". Please report this issue to the System Administrator."
        ShowMsg1(strmessage)
    End Sub

    'Protected Sub ddSelIMType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddSelIMType.SelectedIndexChanged
    '    PopulateFindShows()
    'End Sub
End Class

