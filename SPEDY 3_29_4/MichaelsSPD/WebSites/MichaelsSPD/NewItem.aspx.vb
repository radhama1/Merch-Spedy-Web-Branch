
Imports System.Data
Imports System.Data.SqlClient
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Common.Utilities
Imports System.Collections.Generic
Imports WebConstants

Partial Public Class _NewItem
    Inherits MichaelsBasePage

    ' Local Session Constants for this page
    Const cFINDSTAGEID As String = "_defFindNewValue"  '_defFindNewValue
    ' Const cFINDBATCHID = "_defBatchNewID"
    Const cFINDBATCHSTR As String = "_defBatchSearch"
    Const cSORTEXPRESSION As String = "_defNewBatchSortExp"
    Const cSORTDIRECTION As String = "_defNewBatchSortDir"
    Const cPAGENUMBER As String = "_defgvNewPageIndex"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' alway check that session is still valid
        SecurityCheckRedirect()

        Session(CURRENTTAB) = NEWITEM

        ' Clear out messages
        ShowMsg1("")

        If Not IsPostBack Then

            Initialize()

            If Session(cBATCHPERPAGE) Is Nothing Then Session(cBATCHPERPAGE) = BATCH_PAGE_SIZE
            gvNewBatches.PageSize = CInt(Session(cBATCHPERPAGE))

            ' Populate the Show Stages Dropdown lists
            PopulateFindShows()

            ' Do the inital Grid Loads based on UserID
            PopulateNewBatchesgrid(0, , Convert.ToInt32(Session(cUSERID)), True)   ' Use Session to Load Grid if avail
        End If
    End Sub

    Private Sub Initialize()
        'Hide/Show Create Options based on Security Privileges
        If Not SecurityCheckHasAccess("SPD.ADVANCED", "SPD.ADVANCED.CREATENEWBATCH", Session("UserID")) Then
            divCreateOptions.Visible = False
        End If
    End Sub

    ' Populate Stage Dropdowns
    Private Sub PopulateFindShows()
        ' init
        'LP 12.18.09 requires workflow id to be passed for SPEDY2
        ' New Items
        ' for all stages
        Dim workFlowStages As List(Of Models.WorkflowStage)
        Dim intWorkflowid As Integer
        intWorkflowid = WorkflowType.NewItem

        Try
            workFlowStages = GetSPEDyStages(intWorkflowid)
            ddFindshowNew.DataSource = workFlowStages
            ddFindshowNew.DataTextField = "StageName"
            ddFindshowNew.DataValueField = "ID"
            ddFindshowNew.DataBind()
            ddFindshowNew.Items.Insert(0, New ListItem("My Items", "0"))
            ddFindshowNew.Items.Insert(1, New ListItem("All Stages", "-1")) ' special case!

            Try
                If IsAdminDBCQA() Then
                    ddFindshowNew.Items.Insert(2, New ListItem("Deleted Items", "-3")) ' another special case!
                End If
            Catch
                Dim msg As String = String.Empty
                If CheckandShowException(msg) Then
                    ShowMsg1(msg)
                Else
                    Throw
                End If
            End Try

            ddFindshowNew.Items.Insert(2, New ListItem("All Stages > 48 Hours", "-2")) ' special case
            If Session(cFINDSTAGEID) IsNot Nothing Then
                ddFindshowNew.SelectedValue = Convert.ToInt32(Session(cFINDSTAGEID))
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

    Protected Function GetEditURL(ByVal BatchType As String, ByVal ID As Object, ByVal WorkFlowStageID As String, ByVal Dept_ID As String) As String
        Dim URL As String
        Select Case UCase(BatchType)
            Case "IMPORT"
                URL = "importdetail.aspx"
            Case "DOMESTIC"
                URL = "detail.aspx"
            Case Else
                Return ""
        End Select

        Return URL + cPIPE + CType(ID, String)

    End Function

    Protected Sub gvNewBatches_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvNewBatches.DataBound
        If gvNewBatches.Rows.Count > 0 Then gvNewBatches.BottomPagerRow.Visible = True ' always show pager row
    End Sub

    ' This event fires when a NORMAL Page event occurs ie. Page: First Next Prev Last
    Protected Sub gvNewBatches_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvNewBatches.PageIndexChanged
        Session(cPAGENUMBER) = gvNewBatches.PageIndex
    End Sub

    ' This event fires when a NORMAL Page event occurs ie. Page First Next Prev Last
    Private Sub gvNewBatches_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvNewBatches.PageIndexChanging

    End Sub

    Private Sub gvNewBatches_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvNewBatches.RowCommand

        Dim pagerRow As GridViewRow, row As GridViewRow, strCommand As String, strAction As String, intActionValue As Integer
        Dim ctrl As New Object, i As Int32, ddAction As DropDownList, objHeaderID As Object
        Try
            strCommand = e.CommandName
            ' Check if GoTo Page button was clicked
            If strCommand = "PageGo" Then
                i = NewGetPageNumber()
                If i > 0 AndAlso i <= gvNewBatches.PageCount Then
                    gvNewBatches.PageIndex = i - 1
                    ' Save the page in session here as the Normal Paging events do not fire
                    Session(cPAGENUMBER) = gvNewBatches.PageIndex
                Else
                    ShowMsg1("Invalid Page Number entered.")
                End If
            End If

            ' Check if Batches per page was clicked
            If strCommand = "PageReset" Then
                NewSetBatchesPerPage()
                gvNewBatches.PageIndex = 0
            End If

            ' Check if Find Batch Containing Button was clicked
            If strCommand = "PageFind" Then
                pagerRow = gvNewBatches.BottomPagerRow
                ctrl = pagerRow.Cells(0).FindControl("txtBatch")
                'If Trim(ctrl.text) <> String.Empty Then
                Session(cFINDBATCHSTR) = Trim(ctrl.text)
                PopulateNewBatchesgrid(Convert.ToInt32(ddFindshowNew.SelectedValue), Trim(ctrl.text))
                'End If
            End If

            ' Check if an Action Button was clicked
            If strCommand = "Action" Then
                'Dim objboundfieldBatchId As Object
                Dim strTemp As String
                Dim intBatchId As Long, intHeaderid As Integer
                i = Convert.ToInt32(e.CommandArgument)
                row = gvNewBatches.Rows(i)
                ddAction = row.FindControl("DDAction")
                strAction = ddAction.SelectedItem.ToString
                intActionValue = ddAction.SelectedValue
                'and now -process approve/disapprove/remove
                If intActionValue > 0 Then
                    strTemp = gvNewBatches.DataKeys(i).Value
                    intBatchId = Convert.ToInt32(strTemp)
                    objHeaderID = row.FindControl("HeaderId")
                    strTemp = objHeaderID.value.ToString
                    intHeaderid = Convert.ToInt32(strTemp)

                    'Verify the GridView is synced with Database.  Do not process if it is different
                    Dim gvStageID As Integer = DataHelper.SmartValue(CType(row.FindControl("StageID"), HiddenField).Value, "CInt", 0)
                    Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch
                    Dim wfStageID As Integer = objMichaels.GetRecord(intBatchId).WorkflowStageID
                    If (gvStageID = wfStageID) Then
                        ProcessActionButton(intActionValue, intBatchId, intHeaderid)
                    Else
                        ShowNewUpdate()
                    End If

                End If
            End If
        Catch ex As Exception
            i = 0
        Finally
        End Try
    End Sub

    Protected Sub gvNewBatches_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvNewBatches.RowCreated
        If (e.Row.RowType = DataControlRowType.Header) Then
            AddSortGlyph(gvNewBatches, e.Row, Me.objNewData.SelectParameters("sortCol").DefaultValue, _
                Me.objNewData.SelectParameters("sortDir").DefaultValue)
        End If
    End Sub

    Private Sub gvNewBatches_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvNewBatches.RowDataBound
        Dim ctrlBtn, ctrlPaging As Object, objNewItemRec As Models.NewItemBatchRecord
        Dim strTemp As String, boundfieldBatchId As Long, intStage_Type As Integer, intStageSeq As Integer, introwind As Integer, bEnabled As Boolean
        Dim ctrlddAction As DropDownList
        If e.Row.RowType = DataControlRowType.DataRow Then
            ctrlddAction = e.Row.FindControl("DDAction")
            objNewItemRec = CType(e.Row.DataItem, Models.NewItemBatchRecord)
            strTemp = objNewItemRec.ID
            boundfieldBatchId = Convert.ToInt32(strTemp)

            strTemp = objNewItemRec.Stage_Type_ID
            'based on the batch id, the action items in the drop down will be different
            intStage_Type = Convert.ToInt32(strTemp)
            strTemp = objNewItemRec.Stage_Sequence
            intStageSeq = Convert.ToInt32(strTemp)
            bEnabled = objNewItemRec.Enabled
            ctrlBtn = e.Row.FindControl("btnGol")
            ctrlBtn.CommandArgument = e.Row.RowIndex.ToString()
            introwind = e.Row.RowIndex + 1
            ctrlBtn.Attributes.Add("OnClick", "return RemoveDisappr_ActionButtonClick(" & introwind & ");")

            If intStage_Type = Models.WorkflowStageType.Completed Then
                ctrlBtn.visible = False
                ctrlddAction.Visible = False
            Else
                PopulateActionDD(ctrlddAction, boundfieldBatchId, intStage_Type, intStageSeq, objNewItemRec.CreatedBy, bEnabled)
                If ctrlddAction.Items.Count = 0 Then
                    ctrlBtn.visible = False
                    ctrlddAction.Visible = False
                End If
            End If

            ctrlBtn.CommandArgument = e.Row.RowIndex.ToString()

        ElseIf e.Row.RowType = DataControlRowType.Pager Then
            ctrlPaging = e.Row.FindControl("PagingInformation")
            ctrlPaging.text = String.Format("Page {0} of {1}", gvNewBatches.PageIndex + 1, gvNewBatches.PageCount)
            ctrlPaging = e.Row.FindControl("lblBatchesFound")
            ctrlPaging.text = CStr(BatchesData.GetNewBatchCount()) & " " & ctrlPaging.text
            ctrlPaging = e.Row.FindControl("txtgotopage")
            If gvNewBatches.PageIndex + 1 < gvNewBatches.PageCount Then
                ctrlPaging.text = CStr(gvNewBatches.PageIndex + 2)
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

    Public Sub NewSetBatchesPerPage()
        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvNewBatches.BottomPagerRow
            'If pagerRow Is Nothing Then gvNewBatches.DataBind()
            ctrl = pagerRow.Cells(0).FindControl("txtBatchPerPage")
            If Trim(ctrl.text) <> String.Empty AndAlso IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
                If i > 4 And i < 51 Then
                    If CInt(Session(cBATCHPERPAGE)) <> i Then
                        gvNewBatches.PageSize = i
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

    Public Function NewGetPageNumber() As Long
        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvNewBatches.BottomPagerRow
            'If pagerRow Is Nothing Then gvNewBatches.DataBind()
            ctrl = pagerRow.Cells(0).FindControl("txtgotopage")
            If Trim(ctrl.text) <> String.Empty AndAlso IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
                If i > 0 AndAlso i <= gvNewBatches.PageCount Then
                Else
                    ShowMsg1("Please enter a valid Page Number")
                    i = 1
                End If
            Else
                ShowMsg1("Please enter a valid Page Number")
                i = 1
            End If
        Catch e As Exception
            i = 1
            '    If Trim(ctrl.text) <> String.Empty And IsNumeric(ctrl.text) Then
            '        i = Convert.ToInt32(ctrl.text)
            '    End If
            'Catch e As Exception
            '    i = 0
        Finally
        End Try
        Return i
    End Function

    Private Sub PopulateNewBatchesgrid(ByVal StageId As Integer, Optional ByVal BatchSearch As String = "", Optional ByVal userID As Int32 = -1, _
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
            Me.gvNewBatches.PageIndex = intPageIndex
            Me.objNewData.SelectParameters("StageId").DefaultValue = intStageID
            Me.objNewData.SelectParameters("batchSearch").DefaultValue = strBatchSearch
            Me.objNewData.SelectParameters("userID").DefaultValue = Session("UserID")
            Me.objNewData.SelectParameters("vendorID").DefaultValue = vendorID
            Me.objNewData.SelectParameters("sortCol").DefaultValue = sortCol
            Me.objNewData.SelectParameters("sortDir").DefaultValue = sortDir

        Catch ex As Exception
            ProcessException(ex, "PopulateNewItemBatches")
        Finally
        End Try


        gvNewBatches.DataSourceID = objNewData.ID
        gvNewBatches.DataBind()

        ' Alway show pager row so the search box displays if any records returned
        ' Moved to the Grid Data bound event
        'If BatchesData.GetNewBatchCount > 0 Then
        '    gvNewBatches.BottomPagerRow.Visible = True
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

    Private Sub ShowNewUpdate()
        If Convert.ToInt32(ddFindshowNew.SelectedValue) = 0 Then
            PopulateNewBatchesgrid(0, , Convert.ToInt32(Session(cUSERID)))
        Else
            PopulateNewBatchesgrid(Convert.ToInt32(ddFindshowNew.SelectedValue))
        End If
    End Sub

    Private Sub btnDDFFindNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnDDFFindNew.Click
        Session(cFINDSTAGEID) = Me.ddFindshowNew.SelectedValue
        ShowNewUpdate()
    End Sub

    Private Sub DDFindshowNew_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddFindshowNew.SelectedIndexChanged
        ' Save for restore when page reloads
        Session(cFINDSTAGEID) = ddFindshowNew.SelectedValue   ' Save for restore when page reloads
        ShowNewUpdate()
    End Sub

    ' Handle Link Buttons on top of Grid
    Protected Sub lnkRedir_Command(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.CommandEventArgs)
        ' Create a New Item Batch
        If e.CommandName = "newItem" Then
            Session(cBATCHID) = Nothing   ' Ensure Calling page to create new Batch
            Session(cHEADERID) = Nothing
            Response.Redirect(e.CommandArgument.ToString)
        End If

        ' Edit an existing New Item Batch
        If e.CommandName = "newEdit" Then
            Dim sParm() As String, URL As String
            ' should be 2 parms
            sParm = Split(e.CommandArgument.ToString, cPIPE)
            Try
                URL = sParm(0) + "?hid=" + sParm(1)
                'Session(cBATCHID) = sParm(1)
                Session(cHEADERID) = sParm(1)
                Response.Redirect(URL)
            Catch ex As Exception
                ShowMsg1("Error calling Detail Page." + sParm(0) + ". Contact Support")
            End Try
        End If
    End Sub

    Protected Sub gvNewBatches_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gvNewBatches.Sorting
        ' FJL Jan 2010
        ' Need to force sorting via our call to the Fetch Data routine

        ' if object sort are not set or not = gr sort expression force Ascending order
        If Me.objNewData.SelectParameters("sortCol").DefaultValue = Nothing _
                Or Me.objNewData.SelectParameters("sortDir").DefaultValue = Nothing _
                Or Me.objNewData.SelectParameters("sortCol").DefaultValue <> e.SortExpression _
                Or Me.objNewData.SelectParameters("sortDir").DefaultValue <> "A" Then
            Me.objNewData.SelectParameters("sortDir").DefaultValue = "A"    ' Force Ascending Order

        ElseIf Me.objNewData.SelectParameters("sortDir").DefaultValue = "A" Then
            Me.objNewData.SelectParameters("sortDir").DefaultValue = "D"    ' Force Descending Order
        End If

        ' set column to sort on
        Me.objNewData.SelectParameters("sortCol").DefaultValue = e.SortExpression
        'Save sort in session
        Session(cSORTEXPRESSION) = e.SortExpression
        Session(cSORTDIRECTION) = Me.objNewData.SelectParameters("sortDir").DefaultValue

        ' Any sorting should force page back to page 1 (0) of Results
        ' Changing the page index should force the grid to refresh with new parms
        gvNewBatches.PageIndex = 0

        Session(cPAGENUMBER) = 0 ' Sorting resets Page Index. Save it
        e.Cancel = True ' Cancel normal sort as its not supported with a LIST
    End Sub

    Private Sub PopulateActionDD(ByVal ddaction As DropDownList, ByVal BatchId As Long, ByVal stageTypeID As Integer, _
        ByVal stageSeq As Integer, ByVal CreatedBy As Long, Optional ByVal stageEnabled As Boolean = True)
        '***********this sub will take a grid action column drop down as input parameter and populate it based on the passed log id
        'if istage_type_id = 3- WaitForSKU or 4 -completed, do not populate drop down 
        'if stage sequence = 1 -first stage in the workflow, hide Disparove
        '**************************************************************************************
        ' FJL Feb 2010 Make sure user can do what we are giving them
        ' FJL Apr 2010 add logic to allow disapprove at Waitingforsku stage
        ' FJL Oct 2010 add logic to only allow remove for DBCs and Created user
        If ((ValidateUser(BatchId) And NovaLibra.Coral.SystemFrameworks.Michaels.BatchAccess.Edit) = _
                NovaLibra.Coral.SystemFrameworks.Michaels.BatchAccess.Edit) Then
            If stageTypeID <> Models.WorkflowStageType.Completed AndAlso stageEnabled Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))
                If stageTypeID <> Models.WorkflowStageType.WaitingForSKU Then
                    ddaction.Items.Add(New ListItem("Approve", "1"))
                End If
                If stageTypeID <> Models.WorkflowStageType.Vendor Then
                    ddaction.Items.Add(New ListItem("Disapprove", "2"))
                End If
                If stageTypeID <> Models.WorkflowStageType.WaitingForSKU _
                    AndAlso (CreatedBy = Session(cUSERID) OrElse IsAdminDBCQA() OrElse stageTypeID = Models.WorkflowStageType.Vendor) Then
                    ddaction.Items.Add(New ListItem("Remove", "3"))
                End If
            ElseIf Not stageEnabled Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))
                ddaction.Items.Add(New ListItem("Restore", "4"))
            End If
        End If
    End Sub

    Public Sub ShowMsg1(ByVal strMsg As String)
        Dim curMsg As String
        If strMsg.Length = 0 Then
            lblNewItemMessage.Text = "&nbsp;" ' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
        Else
            curMsg = lblNewItemMessage.Text
            If curMsg = "&nbsp;" Then       ' Only set the message if there is not one in there already
                lblNewItemMessage.Text = strMsg
            Else
                lblNewItemMessage.Text += "<br />" & strMsg
            End If
        End If
    End Sub

    Private Function isNormalStage(ByVal stageType As Integer) As Boolean
        Dim retValue As Boolean = False
        If stageType = Models.WorkflowStageType.General OrElse stageType = Models.WorkflowStageType.Vendor OrElse stageType = Models.WorkflowStageType.Tax Then
            retValue = True
        End If
        Return retValue
    End Function

    Private Sub ProcessActionButton(ByVal intAction As Integer, ByVal intBatchId As Long, ByVal intHeaderId As Long)
        'this function basically replaces Item_Actions.aspx for SPEDY2
        'LP Dec 24 2009, Happy 2010, Nova Libra!
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

                Dim toStage As Integer = DataHelper.DBSmartValues(Me.hdnDisApproveStageID.Value, "integer", False)
                Dim disApproveNotes = Me.hdnNotes.Value
                DisApproveBatch(intBatchId, toStage, intUserId, disApproveNotes, objBatchRecord)

            Case 3 'REMOVE
                objBatchRecord.Enabled = 0
                objBatchRecord.IsValid = -1
                objMichaels.SaveRecord(objBatchRecord, intUserId, "Remove", "")

            Case 4 ' UNDELETE (restore)
                'I hate this...  I am tired of putting band-aids on a broken leg.
                Dim duplicateQRNItem As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord = CheckForQRNDuplicates(objBatchRecord)
                If (duplicateQRNItem.ID > 0) Then
                    ShowMsg1("This batch cannot be restored.  The Quote Reference Number " & duplicateQRNItem.QuoteReferenceNumber & " already exists on batch " & duplicateQRNItem.Batch_ID & ".")
                Else
                    objBatchRecord.Enabled = 1
                    objBatchRecord.IsValid = -1
                    objMichaels.SaveRecord(objBatchRecord, intUserId, "Restore", "")
                End If


            Case Else ' do nothing
        End Select

        ' Once the action is done, make sure the hdnnotes and DisApproval Stage ID fields are cleared out for the next record
        ' This is a global action because the hdnNotes can also be used for the Remove Action (which currently is not logged)
        Me.hdnNotes.Value = String.Empty
        Me.hdnDisApproveStageID.Value = String.Empty

        ' refresh the grid based on current settings
        ShowNewUpdate()

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
        ' SendEmail(ObjBatchRec.ID, intNextStage, ObjBatchRec.FinelineDeptID, DISAPPROVE, ObjBatchRec.VendorName, strNotes)
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
        Catch ex As Exception
            ProcessException(ex, "ApproveItem - GetStageInfo")
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

        Try
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
                                If ConditionAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "S") Then bCondMet(j) = True
                            Case BASICATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "B") Then bCondMet(j) = True
                            Case FIXTUREATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "F") Then bCondMet(j) = True
                            Case GIVEAWAYATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "G") Then bCondMet(j) = True
                            Case SUPPLIERSATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "P") Then bCondMet(j) = True
                            Case TESTATRRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "T") Then bCondMet(j) = True
                            Case QUICKCODEATTRIBUTE
                                If ConditionAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "Q") Then bCondMet(j) = True
                            Case PRICINGCHECK
                                If PricingValidationCheck(ObjBatchRec, intHeaderId) Then bCondMet(j) = True
                            Case DEPARTMENTS
                                If DepartmentsExcFound(ObjBatchRec.ID, intExcId, intCondID(j)) Then bCondMet(j) = True
                            Case PACKITEMDISPLAYPACK
                                ' match any pack item indicator value that starts with DP
                                If ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "DP", False) Then bCondMet(j) = True
                            Case PACKITEMDISPLAYER
                                ' match D, D-PDQ, D-PIAB, SB
                                If ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "D", False) Or ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "SB", False) Then bCondMet(j) = True
                            Case STOCKCATEGORYWAREHOUSE
                                If ConditionStockFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "W") Then bCondMet(j) = True
                            Case STOCKCATEGORYDIRECT
                                If ConditionStockFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "D") Then bCondMet(j) = True
                            Case ITEMTYPEREGULARITEM
                                If ConditionItemTypeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "R") Then bCondMet(j) = True
                            Case ITEMTYPETYPECOMPLEXPACK
                                If ConditionItemTypeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "C") Then bCondMet(j) = True
                            Case ITEMTYPESIMPLEPACK
                                If ConditionItemTypeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "S") Then bCondMet(j) = True
                            Case HEAVYPACK
                                If ConditionHeavyPackWeight(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case PACKITEMD_PDQ
                                If ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "D-PDQ", True) Then bCondMet(j) = True
                            Case PACKITEMD_PIAB
                                If ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "D-PIAB", True) Then bCondMet(j) = True
                            Case PACKITEMDP_PDQ
                                If ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "DP-PDQ", True) Then bCondMet(j) = True
                            Case PACKITEMDP_PIAB
                                If ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "DP-PIAB", True) Then bCondMet(j) = True
                            Case PACKITEMDP_NEITHER
                                ' match only if pack item indicator = "DP" (i.e. not DP-PDQ, not DP-PIAB)
                                If ConditionDisplayPackfound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "DP", True) Then bCondMet(j) = True
                            Case NONSEASONALATTRIBUTE
                                ' returns true if any items are not seasonal (S)
                                If ConditionNotAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "S") Then bCondMet(j) = True
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
                                If Not ConditionBatchUpdateFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case PLISNOTALLYES
                                If ConditionNotPLIsAllYes(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case PLISEDITED
                                If ConditionPLIsEdited(ObjBatchRec.ID, ObjBatchRec.BatchTypeID) Then bCondMet(j) = True
                            Case NONQUICKCODEATTRIBUTE
                                ' returns true if any items are not Quick Code (Q)
                                If ConditionNotAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "Q") Then bCondMet(j) = True
                            Case ALLSEASONALATTRIBUTE
                                ' returns true if all items are seasonal (S)
                                If Not ConditionNotAttributeFound(ObjBatchRec.ID, ObjBatchRec.BatchTypeID, "S") Then bCondMet(j) = True
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
                procOK = PublishMSMQMessage(intBatchId)
            End If

            If procOK Then
                'SendEmail(ObjBatchRec.ID, intNextStageId, ObjBatchRec.FinelineDeptID, strApprType, ObjBatchRec.VendorName, notes)
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
        'LP Jan 2010
        'this function checks if pricing validation fails for the passed Batch record 
        'returns true if validation fails, false if validation passes

        Dim childList As ArrayList = Nothing
        Dim isPriceCheckfailed As Boolean = False, i As Integer

        ' Process Import Batch
        If objBathcrec.BatchTypeID = BATCHTYPEIMPORT Then
            Dim objMichaels As New NovaLibra.Coral.Data.Michaels.ImportItemDetail
            Dim objMichaelsDet As Models.ImportItemRecord
            Dim objChild As Models.ImportItemChildRecord

            childList = objMichaels.GetChildItems(intHeaderId, True)
            For i = 0 To childList.Count - 1
                objChild = CType(childList(i), Models.ImportItemChildRecord)
                objMichaelsDet = objMichaels.GetItemRecord(objChild.ID)
                Dim rdBase As Decimal = DataHelper.SmartValues(objMichaelsDet.RDBase, "CDec", False)
                Dim rdCanada As Decimal = DataHelper.SmartValues(objMichaelsDet.RDCanada, "CDec", False)
                If Not isPriceCheckfailed And Not (objMichaelsDet.RDBase = String.Empty) Then
                    If DataHelper.SmartValues(objMichaelsDet.RDCentral, "CDec", False, 0) <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf DataHelper.SmartValues(objMichaelsDet.RDTest, "CDec", False, 0) <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf DataHelper.SmartValues(objMichaelsDet.RD0Thru9, "CDec", False, 0) <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf DataHelper.SmartValues(objMichaelsDet.RDCalifornia, "CDec", False, 0) <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf DataHelper.SmartValues(objMichaelsDet.RDVillageCraft, "CDec", False, 0) <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf objMichaelsDet.Retail9 <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf objMichaelsDet.Retail10 <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf objMichaelsDet.Retail11 <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf objMichaelsDet.Retail12 <> rdBase Then
                        isPriceCheckfailed = True
                    ElseIf objMichaelsDet.Retail13 <> rdBase Then
                        isPriceCheckfailed = True
                        'MWM: Removed 2019-08-27 they no longer want to compare this
                        'ElseIf objMichaelsDet.RDQuebec <> rdCanada Then
                        '    isPriceCheckfailed = True
                    ElseIf objMichaelsDet.RDPuertoRico <> rdBase Then
                        isPriceCheckfailed = True
                    End If

                    'MWM: Removed 2019-08-27 they no longer want to look at pricing grid for canada pricing
                    'If objMichaelsDet.SKUGroup.IndexOf("CANADA") > 0 And Not Left(objMichaelsDet.PackItemIndicator, 1) = "D" Then
                    '    If Not CheckPricingGrid(rdCanada, rdBase) Then
                    '        isPriceCheckfailed = True
                    '    End If
                    'End If
                End If
            Next

        Else ' Process domestic Batch
            Dim objMichaels As New NovaLibra.Coral.Data.Michaels.ItemDetail
            Dim objDomesticRecord As Models.ItemRecord
            Dim objHeaderRec As Models.ItemHeaderRecord
            Dim childListD As Models.ItemList = objMichaels.GetItemList(intHeaderId, 0, 1000, "", Session(cUSERID))

            objHeaderRec = objMichaels.GetItemHeaderRecord(intHeaderId)
            Dim skugroup As String = objHeaderRec.SKUGroup
            For i = 0 To childListD.RecordCount - 1
                objDomesticRecord = childListD.Item(i)
                If Not isPriceCheckfailed And Not (objDomesticRecord.BaseRetail = Decimal.MinValue) Then
                    If objDomesticRecord.CentralRetail <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.TestRetail <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.ZeroNineRetail <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.CaliforniaRetail <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.VillageCraftRetail <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.Retail9 <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.Retail10 <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.Retail11 <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.Retail12 <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    ElseIf objDomesticRecord.Retail13 <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                        'MWM: Removed 2019-08-27 they no longer want to compare this
                        'ElseIf objDomesticRecord.RDQuebec <> objDomesticRecord.CanadaRetail Then
                        '    isPriceCheckfailed = True
                    ElseIf objDomesticRecord.RDPuertoRico <> objDomesticRecord.BaseRetail Then
                        isPriceCheckfailed = True
                    End If

                    'MWM: Removed 2019-08-27 they no longer want to look at pricing grid for canada pricing
                    'If skugroup.IndexOf("CANADA") > 0 And Not Left(objDomesticRecord.PackItemIndicator, 1) = "D" Then
                    '    If Not CheckPricingGrid(objDomesticRecord.CanadaRetail, objDomesticRecord.BaseRetail) Then isPriceCheckfailed = True
                    'End If
                End If
            Next
        End If
        Return isPriceCheckfailed
    End Function

    Private Function CheckForQRNDuplicates(ByVal objBatchRecord As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord) As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
        Dim duplicateQRNItem As New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
        If (objBatchRecord.BatchTypeID = BATCHTYPEIMPORT) Then

            Dim dataHelper As New NovaLibra.Coral.Data.Michaels.ImportItemDetail
            Dim itemList As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemList = dataHelper.GetItemList(objBatchRecord.ID)
            Dim quoteReferenceNumber As String = ""

            For Each item As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord In itemList.ListRecords
                If (item.QuoteReferenceNumber <> "") Then
                    duplicateQRNItem = dataHelper.GetItemRecordByQRN(item.QuoteReferenceNumber)
                End If
            Next
        End If

        Return duplicateQRNItem
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
            param.DbType = DbType.Currency
            param.Value = canadianprice
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BaseRetail"
            param.DbType = DbType.Currency
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

    Private Function ConditionNotAttributeFound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer, ByVal itemattrib As String) As Boolean

        Dim ret As Boolean = False

        ' this proc returns rows that do not match the input item-type-attribute
        Dim sSQL As String = "SP_SPD2_Batch_Exception_Not_Attributes"
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
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = intBatchTypeID
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

    Private Function ConditionPLIsEdited(ByVal batchID As Integer, ByVal batchTypeId As Integer) As Boolean
        Dim ret As Boolean = False

        ' this proc returns rows that do not match the input item-type-attribute
        Dim sSQL As String = "SP_SPD2_Batch_Exception_PLIsEdited"
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
            param.Value = batchID
            cmd.Parameters.Add(param)

            param = Nothing
            param = cmd.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = batchTypeId
            cmd.Parameters.Add(param)

            cmd.CommandText = sSQL
            cmd.Connection.Open()

            reader = cmd.ExecuteReader
            While reader.Read
                'Check the PLI Edit count.  If it is > 0, then some of the batch items have been edited, so Return True
                Dim pliEditCount As Integer = DataHelper.SmartValues(reader("PLIsEdited"), "CInt", False)
                If pliEditCount > 0 Then
                    ret = True
                End If
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

    Private Function ConditionNotPLIsAllYes(ByVal batchID As Integer, ByVal batchTypeID As Integer) As Boolean
        Dim ret As Boolean = False

        ' this proc returns rows that do not match the input item-type-attribute
        Dim sSQL As String = "SP_SPD2_Batch_Exception_Not_PLIsAllYes"
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
            param.Value = batchID
            cmd.Parameters.Add(param)

            param = Nothing
            param = cmd.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = batchTypeID
            cmd.Parameters.Add(param)

            cmd.CommandText = sSQL
            cmd.Connection.Open()

            reader = cmd.ExecuteReader
            While reader.Read
                'Check the PLI No count.  If it is > 0, then some of the batch items have a PLI set to No, so Return True
                Dim pliNoCount As Integer = DataHelper.SmartValues(reader("PLINoCount"), "CInt", False)
                If pliNoCount > 0 Then
                    ret = True
                End If
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

    Private Function ConditionAttributeFound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer, ByVal itemattrib As String) As Boolean
        'this function will check passed batch for presence of the exception condition itemattributes
        Dim sql As String = "SP_SPD2_Batch_Exception_Attributes"
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
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = intBatchTypeID
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

    Private Function ConditionStockFound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer, ByVal itemcateg As String) As Boolean
        'this function will check passed batch for presence of the exception condition stockcategories
        Dim sql As String = "SP_SPD2_Batch_Exception_StockCategories"
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
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = intBatchTypeID
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

    Private Function ConditionHeavyPackWeight(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer) As Boolean

        Dim sql As String = "sp_spd2_Batch_Exception_HeavyPack"
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

            Dim pType As SqlParameter = cmd.CreateParameter
            pType.Direction = ParameterDirection.Input
            pType.ParameterName = "batchType"
            pType.DbType = DbType.Int32
            pType.Value = intBatchTypeID
            cmd.Parameters.Add(pType)

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

    Private Function ConditionItemTypeFound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer, ByVal itemtype As String) As Boolean
        'this function will check passed batch for presence of the exception condition Item Type
        Dim sql As String = "SP_SPD2_Batch_Exception_ItemTypes"
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
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = intBatchTypeID
            Command.Parameters.Add(param)

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

    Private Function ConditionDisplayPackfound(ByVal intBatchID As Long, ByVal intBatchTypeID As Integer, ByVal packitemvalue As String, ByVal bExact As Boolean) As Boolean
        'how do we process, for domestic batches if one child has this indicator, the whole batch is qualified for exception, for import - use parent
        'LP jan 14 2010
        Dim sql As String = "SP_SPD2_Batch_Exception_PackItemIndicator"
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
            param.ParameterName = "BatchType"
            param.DbType = DbType.Int32
            param.Value = intBatchTypeID
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "Indicator"
            param.DbType = DbType.String
            param.Value = packitemvalue
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
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
        Dim sql As String = "SP_SPD2_Batch_Exception_SourcingBatch"
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
            param = Command.CreateParameter
            param.Direction = ParameterDirection.Input
            param.ParameterName = "batchType"
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

    '    Dim toEmailAddresses As String = String.Empty, ccEmailAddresses As String = String.Empty, bccEmailAddresses As String = String.Empty, env As String

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
    '        env = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("Environment"), "stringu", False)

    '        Select Case env
    '            Case "DEV"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVccEmails"), "string", False)
    '                bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVbccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSpedyURL"), "string", False)
    '            Case "BETA"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAccEmails"), "string", False)
    '                bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAbccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASpedyURL"), "string", False)
    '            Case "PROD"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODccEmails"), "string", False)
    '                bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODbccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSpedyURL"), "string", False)
    '            Case "VENDOR"
    '                toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORToEmails"), "string", False)
    '                ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORccEmails"), "string", False)
    '                bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORbccEmails"), "string", False)
    '                vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORSmtpServer"), "string", False)
    '                spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORSpedyURL"), "string", False)
    '            Case Else
    '                toEmailAddresses = String.Empty
    '                ccEmailAddresses = String.Empty
    '                bccEmailAddresses = String.Empty
    '                vcSMTPServer = String.Empty
    '                spedyURL = String.Empty
    '                ShowMsg1("Invalid email Config in Web.Config. Contact Support.")
    '                Exit Sub
    '        End Select

    '        ' Used to dump the email addresses for Beta and Dev enviroments email
    '        Dim emailQueryResults As String = vcTo

    '        ' User email addresses from SQL query only if PROD and query returns records
    '        If (env <> "PROD" And env <> "VENDOR") OrElse vcTo.Length = 0 Then
    '            vcTo = toEmailAddresses
    '        End If

    '        vcCC = ccEmailAddresses
    '        vcBCC = bccEmailAddresses

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

    Private Function PublishMSMQMessage(ByVal batchId As Long) As Boolean
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        Dim procOK As Boolean = True
        connection.ConnectionString = ConnectionString

        Try
            'Command = New SqlCommand
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "sp_SPD_Batch_PublishMQMessage_ByBatchID"

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "SPD_Batch_ID"
            param.DbType = DbType.Int32
            param.Value = batchId
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
            Command.CommandTimeout = 1800
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
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
        End Try
    End Sub

    Private Sub ProcessException(ByVal e As Exception, ByVal strSourceName As String)
        Dim strmessage As String
        strmessage = "Unexpected SPEDY problem has occured in the routine: " & strSourceName & " - "
        strmessage = strmessage & e.Message & ". Please report this issue to the System Administrator."
        ShowMsg1(strmessage)
    End Sub

End Class

