
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Helper = NovaLibra.Common.Utilities.DataHelper
Imports PagingFiltering = NovaLibra.Common.Utilities.PaginationXML
Imports Data = NovaLibra.Coral.Data.Michaels
Imports NovaLibra.Common.Utilities
Imports System.Collections.Generic
Imports WebConstants

Partial Class BulkItemMaint
    Inherits MichaelsBasePage

    'PAGING
    Const cBIMBATCHPERPAGE As String = "BIMBATCHPERPAGE"
    Const cBIMBATCHCURPAGE As String = "BIMBATCHCURPAGE"
    Const cBIMBATCHTOTALPAGES As String = "BIMBATCHTOTALPAGES"
    Const cBIMBATCHSTARTROW As String = "BIMBATCHSTARTROW"
    Const cBIMBATCHTOTALROWS As String = "BIMBATCHTOTALROWS"

    'SORTING
    Const cBIMBATCHCURSORTCOL As String = "BIMBATCHCURSORTCOL"
    Const cBIMBATCHCURSORTDIR As String = "BIMBATCHCURSORTDIR"

    'FILTERING
    Const cBIMBATCHSHOWSTAGE As String = "BIMBATCHSHOWSTAGE"
    Const cBIMBATCHSEARCHFILTER As String = "BIMCREATIONSEARCHFILTER"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Check Session
        SecurityCheckRedirect()
        Session(CURRENTTAB) = WebConstants.BULKITEMMAINT

        ' Clear out messages
        ShowMsg("")

        If Not IsPostBack Then

            'Initialize Controls
            Initialize()

            'Search Controls
            'PopulateSearchControls()

            'Set Controls
            'SetSearchControlValuesForSession()

            'Update Search Display
            'UpdateFilterDisplay()

            'Paging
            UpdatePagingInformation()

            'Sorting
            UpdateSortingInformation()

            'Populate the Show Stages Dropdown lists
            PopulateFindShows()

            'Populate Grid View
            PopulateGridView()

        End If

        'Fix to GridView caching issues when the user clicks the Back button
        Response.Cache.SetCacheability(HttpCacheability.NoCache)

    End Sub

    Public Sub ApproveItem(ByVal batchID As Integer, ByVal workflowStageID As Integer, ByVal userID As Integer, ByVal batch As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord, ByVal action As String)

        '**********************LP approval Jan 2010********************************
        'get next default stage, check for exceptions
        'compare batch attributes with the exception condition attributes
        'process batch approval
        '************************************************************************

        Dim reader As SqlDataReader, intDefaultNextStageID As Integer, intNextStageId As Integer
        Dim intExceptId(100) As Integer, intExcepOrder(100) As Integer, intCondID(100), intTargetStageID(100) As Integer, strConjunction(100) As String
        Dim intExceptionCount, j, indexOfFoundCondition, intExcId As Integer
        Dim bExceptionCondMet As Boolean = False, bCondMet(100) As Boolean, strexcMet(100) As String
        Dim strsql As String = String.Empty
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        If action = APPROVE Then
            strsql = "sp_SPD2_Approval_GetStageInfo"
        Else
            'TODO: Evaluate if Disapprovals are needed (currently not)
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
            param.Value = workflowStageID
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
                            'TODO:  Currently there are no cases for this batch type
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
            ProcessApprovalTransaction(batchID, intNextStageId, userID, action, notes)
            Me.hdnNotes.Value = String.Empty

            'now, if stage type is "waiting for SKU, send rms message
            Dim procOK As Boolean = True
            If GetStageType(intNextStageId) = Models.WorkflowStageType.WaitingForSKU Then
                procOK = PublishMSMQMessage(batchID, AppHelper.GetUserID)
            End If

            If procOK Then
                Dim msgResult As String = MyBase.SendEmail(batch, intNextStageId, batch.FinelineDeptID, action, batch.VendorName, notes)
                If msgResult.Length > 0 Then
                    ShowMsg(msgResult)
                End If
            Else    ' Send the batch back to the Stage it was at due to error
                ProcessApprovalTransaction(batchID, workflowStageID, userID, DISAPPROVE, "Error Occurred in Batch Completion Process")
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

    Public Function BatchesPerPage() As Long

        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvNewBatches.BottomPagerRow
            ctrl = pagerRow.Cells(0).FindControl("txtBatchPerPage")
            If Trim(ctrl.text) <> String.Empty And IsNumeric(ctrl.text) Then
                i = Convert.ToInt32(ctrl.text)
            End If
        Catch e As Exception
            i = 0
        Finally
        End Try

        Return i

    End Function

    Protected Function GetCheckBoxUrl(ByVal Value As Object) As String

        Dim returnValue As String = "images/Valid_null.gif"

        Dim validity As Integer = Helper.SmartValues(Value, "CInt", False, -1)

        Select Case validity
            Case 0
                returnValue = "images/Valid_no.gif"
            Case 1
                returnValue = "images/Valid_yes.gif"
            Case Else
                returnValue = "images/Valid_null.gif"
        End Select

        Return returnValue

    End Function

    Public Function GoToPage() As Long

        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvNewBatches.BottomPagerRow
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

    Public Sub Initialize()
        'Hide/Show Create Options based on Security Privileges
        If Not SecurityCheckHasAccess("SPD.ADVANCED", "SPD.ADVANCED.CREATEBIMBATCH", Session("UserID")) Then
            lnkUpload.Visible = False
        End If

        'Clear Search Filter
        Session(cBIMBATCHSEARCHFILTER) = ""
    End Sub

    Public Sub PopulateActionDD(ByVal ddaction As DropDownList, ByVal batchID As Long, ByVal createdBy As Long, ByVal stageTypeID As Integer, ByVal stageId As Integer, ByVal stageEnabled As Boolean)

        ValidateUser(batchID)

        If UserCanEdit Then
            If stageTypeID <> Models.WorkflowStageType.Completed AndAlso stageTypeID <> Models.WorkflowStageType.WaitingForSKU AndAlso stageEnabled Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))

                If stageTypeID <> Models.WorkflowStageType.WaitingForSKU Then
                    ddaction.Items.Add(New ListItem("Approve", "1"))
                End If

                If stageTypeID <> Models.WorkflowStageType.WaitingForSKU _
                    AndAlso (createdBy = Session(cUSERID) OrElse IsAdminDBCQA() OrElse stageTypeID = Models.WorkflowStageType.Vendor) Then
                    ddaction.Items.Add(New ListItem("Remove", "3"))
                End If

            End If
        End If

    End Sub

    Private Sub PopulateFindShows()
        'Get Vendor Relations WorkflowStageID
        Dim objData As New Data.BatchData

        ddFindshowNew.Items.Add(New ListItem("DBC/QA", objData.GetStageID(WorkflowType.BulkItemMaint, Models.WorkflowStageType.DBC)))
        ddFindshowNew.Items.Add(New ListItem("Deleted Items", "-3"))
        ddFindshowNew.Items.Add(New ListItem("Waiting for Confirmation", "-4"))
        ddFindshowNew.Items.Add(New ListItem("Completed", "-5"))

        'Default the first Index as the Selected Index
        If Session(cBIMBATCHSHOWSTAGE) Is Nothing Then
            ddFindshowNew.SelectedIndex = 0
        Else
            If Not ddFindshowNew.Items.FindByValue(Session(cBIMBATCHSHOWSTAGE)) Is Nothing Then
                ddFindshowNew.SelectedValue = Session(cBIMBATCHSHOWSTAGE)
            Else
                ddFindshowNew.SelectedIndex = 0
            End If
        End If
        Session(cBIMBATCHSHOWSTAGE) = Me.ddFindshowNew.SelectedValue
    End Sub

    Private Sub PopulateGridView()

        Dim cmd As SqlCommand
        Dim dt As DataTable

        Try
            Dim sql As String = "usp_SPD_GetBIMBatches"
            Dim dbUtil As New DBUtil(ConnectionString)

            cmd = New SqlCommand()

            Dim xml As New PaginationXML()

            '************************
            'Add Search Filters
            '************************

            If Helper.SmartValue(Session(cBIMBATCHSEARCHFILTER), "CStr", "").Length > 0 Then
                xml.AddFilterCriteria(51, Helper.SmartValue(Session(cBIMBATCHSEARCHFILTER), "CStr", ""))
            End If

            'Add Workflow Status Filters
            If Not Session(cBIMBATCHSHOWSTAGE) Is Nothing Then
                Select Case (Session(cBIMBATCHSHOWSTAGE))
                    Case "-5"
                        xml.AddFilterCriteria(-4, Michaels.WorkflowStageType.Completed)
                    Case "-4"
                        xml.AddFilterCriteria(-4, Michaels.WorkflowStageType.WaitingForSKU)
                    Case "-3"
                        'Deleted Batches
                        xml.AddFilterCriteria(-3, "")
                    Case "-1"
                        'All Workflow Stages (Except Completed)
                        xml.AddFilterCriteria(-1, "")
                    Case Else
                        'Return Stages that match the selected Workflow Stage
                        xml.AddFilterCriteria(3, Session(cBIMBATCHSHOWSTAGE).ToString())
                End Select
            End If

            'Add Sorting
            xml.AddSortCriteria(Session(cBIMBATCHCURSORTCOL), Session(cBIMBATCHCURSORTDIR))

            cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.VarChar).Value = xml.GetPaginationXML().Replace("'", "''")
            cmd.Parameters.Add("@maxRows", SqlDbType.Int).Value = Helper.SmartValue(Session(cBIMBATCHPERPAGE), "CInt", -1)
            cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = Helper.SmartValue(Session(cBIMBATCHSTARTROW), "CInt", 1)

            cmd.CommandText = sql
            cmd.CommandTimeout = 1800
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Connection = dbUtil.GetSqlConnection()

            dt = dbUtil.GetDataTable(cmd)

            'Update Paging
            If dt.Rows.Count > 0 Then
                Session(cBIMBATCHTOTALROWS) = Helper.SmartValue(dt.Rows(0)("totRecords"), "CStr", 0)
                Session(cBIMBATCHSTARTROW) = Helper.SmartValue(dt.Rows(0)("RowNumber"), "CStr", 0)
            Else
                Session(cBIMBATCHTOTALROWS) = 0
            End If

            UpdatePagingInformation()

            gvNewBatches.PageSize = Session(cBIMBATCHPERPAGE)
            gvNewBatches.DataSource = dt
            gvNewBatches.DataBind()

            If gvNewBatches.Rows.Count > 0 Then
                gvNewBatches.BottomPagerRow.Visible = True
            End If

        Catch ex As Exception
            Throw ex
        Finally
            If Not cmd Is Nothing Then
                If Not cmd.Connection Is Nothing AndAlso cmd.Connection.State <> ConnectionState.Closed Then
                    cmd.Dispose()
                End If
                cmd = Nothing
            End If
        End Try
    End Sub

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
        ShowMsg(strmessage)
    End Sub

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
            Command.CommandText = "usp_SPD_BulkItemMaint_PublishMQMessageByBatchID"
            Command.CommandTimeout = 1800

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

    Private Sub ProcessAction(ByVal intAction As Integer, ByVal intBatchId As Long, ByVal intHeaderId As Long)
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

                If isValid = 0 Then
                    ShowMsg("This Log Item has Validation errors. Please correct before approving.")
                    objMichaels = Nothing
                Else
                    ApproveItem(intBatchId, intWorkstageId, intUserId, objBatchRecord, APPROVE)
                End If

            Case 2 ' DisApprove
                'TODO: Evaluate if needed.
                'Dim toStage As Integer = DataHelper.DBSmartValues(Me.hdnDisApproveStageID.Value, "integer", False)
                'Dim disApproveNotes = Me.hdnNotes.Value
                'DisApproveBatch(intBatchId, toStage, intUserId, disApproveNotes, objBatchRecord)

            Case 3 'REMOVE
                Dim bDeleted As Boolean = Data.MaintItemMasterData.DeleteItemMaintBatchData(objBatchRecord.ID, intUserId)
                If Not bDeleted Then
                    ShowMsg("Error occurred when removing Items from Batch: " + objBatchRecord.ID.ToString)
                End If
                objBatchRecord.Enabled = 0
                objBatchRecord.IsValid = -1
                objMichaels.SaveRecord(objBatchRecord, intUserId, "Remove", "")

            Case 4 ' UNDELETE (restore)

                objBatchRecord.Enabled = 1
                objBatchRecord.IsValid = -1
                objMichaels.SaveRecord(objBatchRecord, intUserId, "Restore", "")

            Case Else ' do nothing
        End Select

        ' Once the action is done, make sure the hdnnotes and DisApproval Stage ID fields are cleared out for the next record
        ' This is a global action because the hdnNotes can also be used for the Remove Action (which currently is not logged)
        Me.hdnNotes.Value = String.Empty
        Me.hdnDisApproveStageID.Value = String.Empty

        ' refresh the grid based on current settings
        PopulateGridView()
    End Sub

    Private Sub ShowMsg(ByVal strMsg As String)
        Dim curMsg As String
        If strMsg.Length = 0 Then
            lblNewItemMessage.Text = "&nbsp;"   ' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
        Else
            curMsg = lblNewItemMessage.Text
            If curMsg = "&nbsp;" Then           ' Only set the message if there is not one in there already
                lblNewItemMessage.Text = strMsg
            Else
                lblNewItemMessage.Text += "<br />" & strMsg
            End If
        End If
    End Sub

    Private Sub UpdatePagingInformation()

        'Set Defaults
        If Session(cBIMBATCHPERPAGE) Is Nothing Then Session(cBIMBATCHPERPAGE) = BATCH_PAGE_SIZE
        If Session(cBIMBATCHCURPAGE) Is Nothing Then Session(cBIMBATCHCURPAGE) = 1
        If Session(cBIMBATCHTOTALPAGES) Is Nothing Then Session(cBIMBATCHTOTALPAGES) = 0
        If Session(cBIMBATCHSTARTROW) Is Nothing Then Session(cBIMBATCHSTARTROW) = 1
        If Session(cBIMBATCHTOTALROWS) Is Nothing Then Session(cBIMBATCHTOTALROWS) = 0

        If Helper.SmartValue(Session(cBIMBATCHTOTALROWS), "CInt", 0) > 0 Then

            If Helper.SmartValue(Session(cBIMBATCHSTARTROW), "CInt", 0) > Helper.SmartValue(Session(cBIMBATCHTOTALROWS), "CInt", 0) Then
                Session(cBIMBATCHSTARTROW) = 1
            End If

            Session(cBIMBATCHTOTALPAGES) = Fix(Helper.SmartValue(Session(cBIMBATCHTOTALROWS), "CInt", 0) / Helper.SmartValue(Session(cBIMBATCHPERPAGE), "CInt", 0))
            If (Helper.SmartValue(Session(cBIMBATCHTOTALROWS), "CInt", 0) Mod Helper.SmartValue(Session(cBIMBATCHPERPAGE), "CInt", 0)) <> 0 Then
                Session(cBIMBATCHTOTALPAGES) = Helper.SmartValue(Session(cBIMBATCHTOTALPAGES), "CInt", 0) + 1
            End If

            If Helper.SmartValue(Session(cBIMBATCHCURPAGE), "CInt", 0) <= 0 OrElse Helper.SmartValue(Session(cBIMBATCHCURPAGE), "CInt", 0) > Helper.SmartValue(Session(cBIMBATCHTOTALPAGES), "CInt", 0) Then
                Session(cBIMBATCHCURPAGE) = 1
            End If

        Else
            Session(cBIMBATCHCURPAGE) = 1
            Session(cBIMBATCHTOTALPAGES) = 0
            Session(cBIMBATCHSTARTROW) = 1
        End If

    End Sub

    Private Sub UpdateSortingInformation()

        'Set Defaults
        If Session(cBIMBATCHCURSORTCOL) Is Nothing Then Session(cBIMBATCHCURSORTCOL) = 0
        If Session(cBIMBATCHCURSORTDIR) Is Nothing Then Session(cBIMBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc

    End Sub

    Protected Sub btnDDFFindNew_Click(sender As Object, e As EventArgs) Handles btnDDFFindNew.Click
        Try
            'Clear Search Filter
            Session(cBIMBATCHSEARCHFILTER) = ""

            Session(cBIMBATCHSHOWSTAGE) = ddFindshowNew.SelectedValue
            PopulateGridView()
        Catch ex As Exception
            ShowMsg("ERROR: " & ex.Message)
        End Try
    End Sub

    Protected Sub gvNewBatches_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvNewBatches.PageIndexChanged

    End Sub

    Protected Sub gvNewBatches_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvNewBatches.PageIndexChanging

    End Sub

    Protected Sub gvNewBatches_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gvNewBatches.Sorting

    End Sub

    Protected Sub gvNewBatches_Sorted(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvNewBatches.Sorted

    End Sub

    Protected Sub gvNewBatches_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvNewBatches.RowCreated
        If (e.Row.RowType = DataControlRowType.Header) Then
            AddSortGlyph(gvNewBatches, e.Row, Session(cBIMBATCHCURSORTCOL), PagingFiltering.GetSortDirectionString(Session(cBIMBATCHCURSORTDIR)))
        End If
    End Sub

    Protected Sub gvNewBatches_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvNewBatches.RowCommand
        'Clear Search Filter
        Session(cBIMBATCHSEARCHFILTER) = ""

        Select Case e.CommandName

            Case "Action"
                'Dim objboundfieldBatchId As Object
                Dim strTemp As String
                Dim intBatchId As Long, intHeaderid As Integer

                Dim row As GridViewRow = gvNewBatches.Rows(e.CommandArgument)
                Dim ddActions As DropDownList = row.FindControl("DDAction")
                Dim actionValue As Integer = CInt(ddActions.SelectedValue)

                'and now -process approve/disapprove/remove
                If ddActions.SelectedIndex > 0 Then
                    strTemp = gvNewBatches.DataKeys(e.CommandArgument).Value
                    intBatchId = Convert.ToInt32(strTemp)

                    'Verify the GridView is synced with Database.  Do not process if it is different
                    Dim gvStageID As Integer = DataHelper.SmartValue(CType(row.FindControl("StageID"), HiddenField).Value, "CInt", 0)
                    Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch
                    Dim wfStageID As Integer = objMichaels.GetRecord(intBatchId).WorkflowStageID
                    If (gvStageID = wfStageID) Then
                        ProcessAction(actionValue, intBatchId, intHeaderid)
                    Else
                        PopulateGridView()
                    End If
                End If

            Case "Sort"

                'Same Column (Change Direction)
                If Session(cBIMBATCHCURSORTCOL).ToString() = e.CommandArgument.ToString() Then

                    If Session(cBIMBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc Then
                        Session(cBIMBATCHCURSORTDIR) = PagingFiltering.SortDirection.Desc
                    Else
                        Session(cBIMBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc
                    End If

                Else
                    Session(cBIMBATCHCURSORTCOL) = e.CommandArgument.ToString()
                    Session(cBIMBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc
                End If

                'Go To First Item
                Session(cBIMBATCHCURPAGE) = 1
                Session(cBIMBATCHSTARTROW) = 1

                PopulateGridView()

            Case "Page"

                Select Case e.CommandArgument
                    Case "First"
                        Session(cBIMBATCHCURPAGE) = 1
                        Session(cBIMBATCHSTARTROW) = 1
                    Case "Prev"
                        If Session(cBIMBATCHCURPAGE) > 1 Then
                            Session(cBIMBATCHCURPAGE) -= 1
                            Session(cBIMBATCHSTARTROW) = Session(cBIMBATCHSTARTROW) - Session(cBIMBATCHPERPAGE)
                        End If
                    Case "Next"
                        If Session(cBIMBATCHCURPAGE) < Session(cBIMBATCHTOTALPAGES) Then
                            Session(cBIMBATCHCURPAGE) += 1
                            Session(cBIMBATCHSTARTROW) = Session(cBIMBATCHSTARTROW) + Session(cBIMBATCHPERPAGE)
                        End If
                    Case "Last"
                        Session(cBIMBATCHCURPAGE) = Session(cBIMBATCHTOTALPAGES)
                        Session(cBIMBATCHSTARTROW) = ((Session(cBIMBATCHTOTALPAGES) - 1) * Session(cBIMBATCHPERPAGE)) + 1
                End Select

                PopulateGridView()

            Case "PageGo"

                Dim newPageNum As Integer = GoToPage()

                If newPageNum > 0 AndAlso newPageNum <= Session(cBIMBATCHTOTALPAGES) Then

                    Session(cBIMBATCHCURPAGE) = newPageNum
                    Session(cBIMBATCHSTARTROW) = ((Session(cBIMBATCHCURPAGE) - 1) * Session(cBIMBATCHPERPAGE)) + 1

                    PopulateGridView()
                Else
                    ShowMsg("Invalid Page Number entered.")
                End If

            Case "PageReset"

                Dim newBatchesPerPage As Integer = BatchesPerPage()

                If newBatchesPerPage >= 5 AndAlso newBatchesPerPage <= 50 Then

                    Session(cBIMBATCHCURPAGE) = 1
                    Session(cBIMBATCHSTARTROW) = 1
                    Session(cBIMBATCHPERPAGE) = newBatchesPerPage

                    PopulateGridView()
                Else
                    ShowMsg("Batches / Page must be between 5 and 50")
                End If
            Case "PageFind"
                Dim pagerrow As GridViewRow = gvNewBatches.BottomPagerRow
                Dim ctrl As TextBox = pagerrow.Cells(0).FindControl("txtBatch")
                If ctrl IsNot Nothing Then
                    If Trim(ctrl.Text) <> String.Empty Then
                        Session(cBIMBATCHSEARCHFILTER) = ctrl.Text.Trim
                        PopulateGridView()
                    End If
                End If

        End Select

    End Sub

    Private Sub gvNewBatches_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvNewBatches.RowDataBound

        Select Case e.Row.RowType

            Case DataControlRowType.DataRow

                Dim ctrlDD As DropDownList = e.Row.FindControl("DDAction")
                Dim ctrlBtn As Button = e.Row.FindControl("DDActionGo")

                'Get the data that corresponds with the current Row
                Dim objNewItemRec = CType(e.Row.DataItem, DataRowView).Row

                Dim batchID As Long = Helper.SmartValue(objNewItemRec.Item("ID"), "CLng", 0)
                Dim createdByUserID As Integer = Helper.SmartValue(objNewItemRec.Item("Created_User"), "CInt", 0)
                Dim stageID As Integer = Helper.SmartValue(objNewItemRec.Item("Workflow_Stage_ID"), "CInt", 0)
                Dim stageTypeID As Integer = Helper.SmartValue(objNewItemRec.Item("Stage_Type_ID"), "CInt", 0)
                Dim isEnabled As Boolean = Helper.SmartValue(objNewItemRec.Item("Enabled"), "Boolean", False)

                PopulateActionDD(ctrlDD, batchID, createdByUserID, stageTypeID, stageID, isEnabled)

                If ctrlDD.Items.Count = 0 Then
                    ctrlBtn.Visible = False
                    ctrlDD.Visible = False
                End If
                ctrlBtn.CommandArgument = e.Row.RowIndex.ToString()
                'ctrlBtn.Attributes.Add("OnClick", "javascript: return RemoveDisappr_ActionButtonClick(" & (e.Row.RowIndex + 1).ToString & ");")

            Case DataControlRowType.Pager

                Dim ctrlPaging As Object

                ctrlPaging = e.Row.FindControl("PagingInformation")
                ctrlPaging.text = String.Format("Page {0} of {1}", Session(cBIMBATCHCURPAGE), Session(cBIMBATCHTOTALPAGES))

                ctrlPaging = e.Row.FindControl("lblBatchesFound")
                ctrlPaging.text = Session(cBIMBATCHTOTALROWS).ToString() & " " & ctrlPaging.text

                ctrlPaging = e.Row.FindControl("txtgotopage")
                If Helper.SmartValue(Session(cBIMBATCHCURPAGE), "CInt", 0) < Helper.SmartValue(Session(cBIMBATCHTOTALPAGES), "CInt", 0) Then
                    ctrlPaging.text = Helper.SmartValue(Session(cBIMBATCHCURPAGE), "CInt", 0) + 1
                Else
                    ctrlPaging.text = "1"
                End If

                ctrlPaging = e.Row.FindControl("txtBatchPerPage")
                ctrlPaging.text = Helper.SmartValue(Session(cBIMBATCHPERPAGE), "CInt")

        End Select

    End Sub


End Class
