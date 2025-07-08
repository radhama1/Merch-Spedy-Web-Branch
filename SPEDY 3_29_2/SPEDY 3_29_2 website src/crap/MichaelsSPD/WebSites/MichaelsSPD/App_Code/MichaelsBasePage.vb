Imports System
Imports System.Web
Imports System.Data
Imports System.Data.SqlClient
Imports System.Collections.Generic
Imports Microsoft.VisualBasic
Imports System.Diagnostics

Imports WebConstants
Imports NovaLibra.Common.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels

Public Class MichaelsBasePage
    Inherits System.Web.UI.Page

    Private _access As Models.BatchAccess = Models.BatchAccess.None
    Private _connectionString As String = ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString
    Private _appErrorMessage As String
    Private _isNew As Boolean = False

    Public ReadOnly Property UserAccess() As Models.BatchAccess
        Get
            Return _access
        End Get
    End Property

    Public ReadOnly Property UserCanView() As Boolean
        Get
            If (UserAccess And Models.BatchAccess.View) Then
                Return True
            Else
                Return False
            End If
        End Get
    End Property

    Public ReadOnly Property UserCanEdit() As Boolean
        Get
            If (UserAccess And Models.BatchAccess.Edit) Then
                Return True
            Else
                Return False
            End If
        End Get
    End Property

    Public ReadOnly Property UserCanDelete() As Boolean
        Get
            If (UserAccess And Models.BatchAccess.Delete) Then
                Return True
            Else
                Return False
            End If
        End Get
    End Property

    Public ReadOnly Property NoUserAccess() As Boolean
        Get
            If (UserAccess = Models.BatchAccess.None) Then
                Return True
            Else
                Return False
            End If
        End Get
    End Property

    Public Sub SetUserCannotEdit()
        If Me.UserCanEdit Then
            _access = (_access Xor Models.BatchAccess.Edit)
        End If
    End Sub

    Public Sub CheckEditByStageType(ByVal stageType As Models.WorkflowStageType)
        If stageType = Models.WorkflowStageType.WaitingForSKU Or stageType = Models.WorkflowStageType.Completed Then
            SetUserCannotEdit()
        End If
    End Sub

    Public Property IsNew() As Boolean
        Get
            Return _isNew
        End Get
        Set(ByVal value As Boolean)
            _isNew = value
        End Set
    End Property

    Public ReadOnly Property ConnectionString() As String
        Get
            Return _connectionString
        End Get
    End Property

    Public Function UpdateBatch(ByRef batchRecord As Models.BatchRecord, ByVal userID As Integer) As Long
        Dim objData As New Data.BatchData
        Dim batchID As Long
        batchID = objData.SaveBatchRecord(batchRecord, userID)
        objData = Nothing
        Return batchID
    End Function

    Public Function CreateBatch(ByVal WorkflowType As Integer, ByVal DeptNo As Integer, ByVal VendorNo As Integer, ByVal VendorName As String, _
        ByVal UserID As Integer, Optional ByVal StockCat As String = "", Optional ByVal ItemTypeAttr As String = "", Optional ByVal packType As String = "", _
        Optional ByVal packSKU As String = "", Optional ByVal BatchName As String = "", Optional ByVal quoteReferenceNumber As String = "", Optional ByVal batchType As Models.BatchType = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Unspecified) As Long

        Dim objData As New Data.BatchData
        Dim batchID As Long

        If batchType = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Unspecified Then
            If ValidationHelper.IsValidDomesticVendor(VendorNo) Then
                batchType = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic
            ElseIf ValidationHelper.IsValidImportVendor(VendorNo) Then
                batchType = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import
            Else
                Return -99
            End If
        End If
        
        ' Determine if this is a special batch going to a specific workflow stage 
        Dim workflowStageID As Integer = Integer.MinValue
        If WorkflowType = WebConstants.WorkflowType.ItemMaint Then
            If IsAdminDBCQA() Then
                'If the uploader is a DBCQA user, then promote batch to DBC/QA
                workflowStageID = objData.GetStageID(WorkflowType, Models.WorkflowStageType.DBC)
            ElseIf isTaxMgr Then
                workflowStageID = objData.GetStageID(WorkflowType, Models.WorkflowStageType.Tax)
            ElseIf isImportMgr Then
                'IF the uploader is an Import Manager user then promote batch to Import WF Stage
                workflowStageID = objData.GetStageID(2, Models.WorkflowStageType.Import)
            ElseIf Not String.IsNullOrEmpty(quoteReferenceNumber) Then
                'Move Batch to CAA/CMA Workflow Step as a System Activity, if this batch contains an item with a QuoteReference 
                workflowStageID = 25
            End If
        End If


        'Set WorkflowStage for Batch to Trilingual Maintenance Workflow
        If WorkflowType = WebConstants.WorkflowType.TrilingualMaint Or WorkflowType = WebConstants.WorkflowType.BulkItemMaint Then
            workflowStageID = objData.GetStageID(WorkflowType, Models.WorkflowStageType.DBC)
        End If

        'Set WorkflowStage for Batch to EXT Maintenance Workflow
        If WorkflowType = WebConstants.WorkflowType.EXTMaint Then
            workflowStageID = objData.GetStageID(WorkflowType, Models.WorkflowStageType.Initial)
        End If

        Dim isMSSBatch As Boolean = False
        If Not String.IsNullOrEmpty(quoteReferenceNumber) Then
            isMSSBatch = True
        End If

        batchID = objData.CreateBatch(WorkflowType, batchType, DeptNo, VendorNo, VendorName, UserID, StockCat, ItemTypeAttr, packType, packSKU, BatchName, workflowStageID, isMSSBatch)

        objData = Nothing
        Return batchID
    End Function

    Public Function ValidateUser(ByVal batchID As Integer) As Models.BatchAccess
        Dim userID As Integer = DataHelper.SmartValues(Session("UserID"), "integer", False)
        Dim vendorID As Integer = IIf(Session("vendorId") Is Nothing, 0, CType(Session("vendorId"), Integer))
        If batchID = 0 AndAlso IsNew Then
            ' new record - edit mode is okay
            _access = Models.BatchAccess.Edit Or Models.BatchAccess.View
        Else
            _access = BatchesData.ValidateUser(batchID, userID, vendorID)
        End If
        Return _access
    End Function

    Public Function ValidateUser(ByVal batchID As Integer, ByVal stageType As Models.WorkflowStageType) As Models.BatchAccess
        ValidateUser(batchID)
        Me.CheckEditByStageType(stageType)
        Return _access
    End Function

    Public Property AppErrorMessage() As String
        Get
            Return _appErrorMessage
        End Get
        Set(ByVal value As String)
            _appErrorMessage = value
        End Set
    End Property

    ' Checks to see if AppErrorMessage has a string in it.  If it does it returns true and formats the passes back the formated string. Else it returns false
    Public Function CheckandShowException(ByRef messageText As String) As Boolean
        Dim retValue As Boolean = False
        If AppErrorMessage.Length > 0 Then
            Dim message As String
            Dim src As String = Left(AppErrorMessage, InStr(AppErrorMessage, " ") - 1)
            Dim msg As String = Mid(AppErrorMessage, InStr(AppErrorMessage, " ") + 1)
            message = "Unexpected SPEDY problem has occured in the routine: " & src & " - "
            message = message & msg & " Please report this issue to the System Administrator."
            messageText = message
            AppErrorMessage = String.Empty  ' Reset the message after its referenced
            retValue = True
        End If
        Return retValue
    End Function

    Public Function GetSPEDyStages(ByVal workflowId As Integer) As List(Of Models.WorkflowStage)
        ' return a list of workflow stages records
        Dim workFlowStages As List(Of Models.WorkflowStage) = New List(Of Models.WorkflowStage)
        Dim record As Models.WorkflowStage
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        Dim reader As SqlDataReader
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "sp_SPD2_Workflow_Stages_List"
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "workflow_Id"
            param.DbType = DbType.Int32
            param.Value = workflowId
            Command.Parameters.Add(param)

            Command.Connection.Open()
            reader = Command.ExecuteReader
            While reader.Read
                record = New Models.WorkflowStage
                record.ID = reader("ID")
                record.StageName = reader("stage_name")
                workFlowStages.Add(record)
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
            AppErrorMessage = "GetSPEDyStages " & ex.Message
            Throw
        Finally
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
            reader = Nothing
        End Try
        Return workFlowStages
    End Function

    Public Function IsAdmin() As Boolean
        Return LookupGroups(WebConstants.SecurityGroups.SysAdmins)
    End Function

    Public Function IsAdminDBCQA() As Boolean
        Dim retValue As Boolean
        If Session(cADMINDBCQA) IsNot Nothing Then
            retValue = CBool(Session(cADMINDBCQA))
        Else
            retValue = LookupGroups(WebConstants.SecurityGroups.DBCQA)  'GetAdminDBCQA()
            Session(cADMINDBCQA) = retValue
        End If
        Return retValue
    End Function

    Public ReadOnly Property isImportMgr() As Boolean
        Get
            Dim retValue As Boolean
            If Session(cIMPORTMGR) IsNot Nothing Then
                retValue = CBool(Session(cIMPORTMGR))
            Else
                retValue = LookupGroups(WebConstants.SecurityGroups.ImportMgr)
                Session(cIMPORTMGR) = retValue
            End If
            Return retValue
        End Get
    End Property

    Public ReadOnly Property isTaxMgr() As Boolean
        Get
            Dim retValue As Boolean
            If Session(cTAXMGR) IsNot Nothing Then
                retValue = CBool(Session(cTAXMGR))
            Else
                retValue = LookupGroups(WebConstants.SecurityGroups.TaxMgr)
                Session(cTAXMGR) = retValue
            End If
            Return retValue
        End Get
    End Property

    Public ReadOnly Property isVendorRelations() As Boolean
        Get
            Dim retValue As Boolean
            If Session(cVENDORRELATION) IsNot Nothing Then
                retValue = CBool(Session(cVENDORRELATION))
            Else
                retValue = LookupGroups(WebConstants.SecurityGroups.VendorRelation)
                Session(cVENDORRELATION) = retValue
            End If
            Return retValue
        End Get
    End Property

    Public ReadOnly Property BelongsToGroup(ByVal groupID As Integer) As Boolean
        Get
            Return LookupGroups(groupID)
        End Get
    End Property

    Public Function LookupGroups(ByVal targetGroupID As Integer, Optional ByVal userID As Integer = Integer.MinValue) As Boolean

        Dim sql As String = "usp_SPD_Security_GetGroups"
        Dim reader As SqlDataReader
        Dim GroupID As Integer, Result As Boolean = False

        'If no userID is specified, use the one from the Session
        If userID = Integer.MinValue Then
            userID = Convert.ToInt32(Session(cUSERID))
        End If

        Dim connection As SqlConnection
        Dim Command As SqlCommand
        'Dim param As SqlParameter
        connection = New SqlConnection
        connection.ConnectionString = ConnectionString

        Command = New SqlCommand
        Command.Connection = connection
        Command.CommandType = CommandType.StoredProcedure
        Command.CommandText = sql
        Command.Parameters.Add("@UserID", SqlDbType.Int).Value = userID
        Try
            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                GroupID = DataHelper.DBSmartValues(reader("GROUPID"), "integer", True)
                If targetGroupID = SecurityGroups.DBCQA Then    ' Sysadmins or dbc count here
                    If GroupID = WebConstants.SecurityGroups.SysAdmins OrElse GroupID = WebConstants.SecurityGroups.DBCQA Then
                        Result = True
                        Exit While
                    End If
                Else
                    If GroupID = targetGroupID Then
                        Result = True
                        Exit While
                    End If
                End If
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
            AppErrorMessage = "LookupGroups " & ex.Message
            Throw
        Finally
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
            reader = Nothing
        End Try
        Return Result
    End Function

    Public Function GetStageType(ByVal stageid As Integer) As Integer
        'returns stage type, LP Jan 2010
        Dim intStageType As Integer = 0
        Dim reader As SqlDataReader
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        'Command = New SqlCommand
        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "WorkflowStageId"
            param.DbType = DbType.Int32
            param.Value = stageid
            Command.Parameters.Add(param)
            Command.CommandText = "sp_SPD2_Approval_GetStageTypeId"
            Command.CommandTimeout = 600
            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                intStageType = reader("Stage_Type_ID")
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
            AppErrorMessage = "GetStageType " & ex.Message
            Throw
        Finally
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
            reader = Nothing
        End Try

        Return intStageType
    End Function

    Public Overridable Sub Lockfield(ByVal colName As String, ByVal permission As Char)
        ' Lock or hide standard fields. Used on Import and Detail form pages
        Select Case permission
            Case "N"    ' Don't show this field
                Dim ctrlID As String = String.Empty
                Dim control As Control = Me.FindControl(colName)

                If control Is Nothing Then      ' Try by stripping out the _ from the col name
                    colName = Replace(colName, "_", "")
                    control = Me.FindControl(colName)
                    If control Is Nothing Then
                        Exit Select  ' Could not find it
                    End If
                End If
                ctrlID = control.ID

                ' First Hide any td FL assoc with control   ex controlNameFL
                Dim htmlTD As HtmlTableCell = Me.FindControl(ctrlID + "FL")
                If Not (htmlTD Is Nothing) Then
                    htmlTD.Attributes.Add("style", "display:none")
                End If

                ' Hide any td Parent assoc with control OR the control if no parent. ex controlNameParent
                htmlTD = Me.FindControl(ctrlID + "Parent")
                If Not (htmlTD Is Nothing) Then
                    htmlTD.Attributes.Add("style", "display:none")
                Else
                    If Not (TypeOf control Is System.Web.UI.WebControls.HiddenField) Then
                        control.Visible = False
                    End If
                End If

                ' Edit controls
                control = Me.FindControl(ctrlID + "Edit")
                If control IsNot Nothing Then
                    control.Visible = False ' hide the edit control
                End If

                ' Check for GM spans to hide
                Dim htmlSpan As HtmlControl = Me.FindControl(ctrlID + "GM")
                If Not (htmlSpan Is Nothing) Then
                    htmlSpan.Attributes.Add("style", "display:none")
                End If

            Case "V"    ' View only on this column
                Dim ctrlID As String = String.Empty
                Dim control As Control = Me.FindControl(colName)
                If control Is Nothing Then      ' Try by stripping out the _ from the col name
                    colName = Replace(colName, "_", "")
                    control = Me.FindControl(colName)
                End If
                If control Is Nothing Then
                    Exit Select  ' Could not find it
                End If
                ctrlID = control.ID
                If Not (TypeOf control Is HiddenField) Then
                    Try
                        If (TypeOf control Is TextBox) Then
                            If CType(control, TextBox).ReadOnly = False Then
                                CType(control, NovaLibra.Controls.INLChangeControl).RenderReadOnly = True
                            End If
                        Else
                            CType(control, NovaLibra.Controls.INLChangeControl).RenderReadOnly = True
                        End If
                    Catch
                    End Try
                End If

                ' See if there is an Edit field for this control and render it read only as well
                control = Me.FindControl(ctrlID & "Edit")
                If Not (control Is Nothing) Then
                    Try
                        If (TypeOf control Is TextBox) Then
                            If CType(control, TextBox).ReadOnly = False Then
                                CType(control, NovaLibra.Controls.INLChangeControl).RenderReadOnly = True
                            End If
                        Else
                            CType(control, NovaLibra.Controls.INLChangeControl).RenderReadOnly = True
                        End If
                    Catch
                    End Try
                End If
        End Select
    End Sub


    ' Security Check
    Public Function SecurityCheck() As Boolean
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Return False
        Else
            Return True
        End If
    End Function

    Public Sub SecurityCheckRedirect()
        If Not SecurityCheck() Then
            Response.Redirect("login.aspx")
        End If
    End Sub

    Public Sub SecurityCheckCallback()
        If Not SecurityCheck() Then
            Response.End()
        End If
    End Sub

    Protected Function SecurityCheckHasAccess(ByVal pScopeConst As String, ByVal pPrivilegeConst As String, ByVal pUserID As Integer, Optional ByVal pObjectID As Integer = -1) As Boolean

        Return NovaLibra.Coral.Data.Security.Security.HasAccess(pScopeConst, pPrivilegeConst, pUserID, pObjectID)

    End Function

    Protected Function GetUserAccessLevel() As Int16

        Dim ret As Int16 = 0

        Dim scopeID As Integer = 1001

        Dim conn As New SqlConnection(ConnectionString)
        Dim sSQL As String = "usp_Approval_UserScopeAccess"
        Dim cmd As New SqlCommand(sSQL, conn)
        cmd.CommandType = CommandType.StoredProcedure
        Dim reader As SqlDataReader

        Try
            Dim pU As SqlParameter = cmd.CreateParameter
            pU.Direction = ParameterDirection.Input
            pU.DbType = DbType.Int32
            pU.ParameterName = "userID"
            pU.Value = Session("UserID")
            cmd.Parameters.Add(pU)

            Dim pS As SqlParameter = cmd.CreateParameter
            pS.Direction = ParameterDirection.Input
            pS.DbType = DbType.Int32
            pS.ParameterName = "scopeID"
            pS.Value = scopeID
            cmd.Parameters.Add(pS)

            cmd.Connection.Open()
            reader = cmd.ExecuteReader()
            While reader.Read
                Select Case reader("Constant").ToString()
                    Case "SPD.ACCESS" 'new item
                        ret = ret Or NEWITEM
                    Case "SPD.ACCESS.IM"
                        ret = ret Or ITEMMAINT
                    Case "SPD.ACCESS.PONEW"
                        ret = ret Or PONEW
                    Case "SPD.ACCESS.POMAINT"
                        ret = ret Or POMAINT
                    Case "SPD.ACCESS.TRILINGUALMAINT"
                        ret = ret Or TRILINGUALMAINT
                    Case "SPD.ACCESS.BULKITEMMAINT"
                        ret = ret Or BULKITEMMAINT
                End Select
            End While
            reader.Close()
            cmd.Connection.Close()

        Catch ex As Exception
            If conn.State = ConnectionState.Open Then conn.Close()
            AppErrorMessage = "GetUserAccessLevel " & ex.Message
            Throw
        Finally
            cmd.Dispose()
            conn.Dispose()
            cmd = Nothing
            conn = Nothing
            reader = Nothing
        End Try

        Return ret

    End Function

    ' Vendor Check
    Public Function VendorCheck(ByVal vendorNum1 As Integer) As Boolean
        Return VendorCheck(vendorNum1, 0)
    End Function

    Public Function VendorCheck(ByVal vendorNum1 As Integer, ByVal vendorNum2 As Integer) As Boolean
        Dim valid As Boolean = True
		Dim vid As Integer = AppHelper.GetVendorID()
        If vid > 0 Then
            If vendorNum1 > 0 Then
                If vid <> vendorNum1 Then valid = False
            Else
                If vendorNum2 > 0 Then
                    If vid <> vendorNum2 Then valid = False
                End If
            End If
        End If
        Return valid
    End Function

    Public Sub VendorCheckRedirect(ByVal vendorNum1 As Integer)
        VendorCheckRedirect(vendorNum1, 0)
    End Sub

    Public Sub VendorCheckRedirect(ByVal vendorNum1 As Integer, ByVal vendorNum2 As Integer)
        If Not VendorCheck(vendorNum1, vendorNum2) Then
            Response.Redirect("default.aspx")
        End If
    End Sub

    Protected Sub AddSortGlyph(ByVal grid As GridView, ByVal item As GridViewRow)
        ' -----------------------------------
        ' FJL Dec 2009
        ' Used to add a sort glyph icon on a griview control.  Called by the gridview RowCreated event
        ' -----------------------------------
        Dim glyph As New Image, i As Integer, colExpr As String
        If grid.SortDirection = SortDirection.Ascending Then    ' System.Web.UI.WebControls.SortDirection.Ascending Then
            glyph.ImageUrl = "~\images\sort_asc.gif"
        Else
            glyph.ImageUrl = "~\images\sort_desc.gif"
        End If

        If grid.SortExpression <> "" Then
            For i = 0 To grid.Columns.Count - 1
                colExpr = grid.Columns(i).SortExpression
                If colExpr <> "" AndAlso colExpr = grid.SortExpression Then
                    item.Cells(i).Controls.Add(glyph)
                    Exit For
                End If
            Next
        End If
    End Sub

    Protected Sub AddSortGlyph(ByVal grid As GridView, ByVal item As GridViewRow, ByVal sortExpression As String, ByVal sortDir As String)
        ' -----------------------------------
        ' FJL Jan 2010
        ' This version to handle sort based on passed in expression and direction (when grid bound to ObjectDataSource with a LIST object
        ' Used to add a sort glyph icon on a griview control.  Called by the gridview RowCreated event
        ' -----------------------------------
        Dim glyph As New Image, i As Integer, colExpr As String
        If sortDir IsNot Nothing AndAlso sortDir.StartsWith("A") Then
            glyph.ImageUrl = "~\images\sort_asc.gif"
        Else
            glyph.ImageUrl = "~\images\sort_desc.gif"

        End If

        If sortExpression <> "" Then
            For i = 0 To grid.Columns.Count - 1
                colExpr = grid.Columns(i).SortExpression
                If colExpr <> "" AndAlso colExpr = sortExpression Then
                    item.Cells(i).Controls.Add(glyph)
                    Exit For
                End If
            Next
        End If
    End Sub

    Protected Sub InitValidation(ByVal controlID As String)
        Dim scriptKey As String = "__val_" & controlID
        If Not Me.Page.ClientScript.IsStartupScriptRegistered(scriptKey) Then
            Dim sb As New StringBuilder("")
            sb.Length = 0
            sb.Append("" & vbCrLf)
            sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
            sb.Append("<!--" & vbCrLf)

            sb.Append("initValidationErrors('" & controlID & "');" & vbCrLf)

            sb.Append("//-->" & vbCrLf)
            sb.Append("</script>" & vbCrLf)
            Me.ClientScript.RegisterStartupScript(Me.GetType(), scriptKey, sb.ToString())
            sb = Nothing
        End If
    End Sub

    Public Sub WriteTime(ByVal label As String)
        'Response.Write("<!-- TIME: " & Now().ToString("G") & " - " & label & " " & "-->" & vbCrLf)
        Dim sb As New StringBuilder("")
        sb.Length = 0
        sb.Append("" & vbCrLf)
        sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)

        sb.Append(String.Format("WriteTime('{0}', '{1}');", label.Replace("'", "''"), Now().ToString("G")) & vbCrLf)

        sb.Append("//-->" & vbCrLf)
        sb.Append("</script>" & vbCrLf)
        Me.ClientScript.RegisterStartupScript(Me.GetType(), "_TEST_" & label, sb.ToString())
        sb = Nothing
    End Sub

	'Email Methods
	Protected Function SendEmail(ByVal batchRecord As Models.BatchRecord, ByVal intNextStageId As Integer, ByVal DeptId As Integer, ByVal approvaltype As String, ByVal vendor_name As String, ByVal notes As String) As String
		'this procedure sends e-mail to users who have rights to approve, based on departments and workflow group
		'get a full list of people responsible for this batch
		Dim vcTo As String = String.Empty, vcSender, vcFrom As String, vcCC As String, vcBCC As String, vcSMTPServer As String = String.Empty, spedyURL As String = String.Empty
		Dim e_mailsubject As String, e_mailbody As String, bAutoGenerateTextBody As Integer = 1, bAuthenticate As Byte = 0
		Dim retMessage As String = String.Empty

		Dim toEmailAddresses As String = String.Empty, ccEmailAddresses As String = String.Empty, bccEmailAddresses As String = String.Empty, env As String

		Try
			'GET "TO" Email Addresses
            vcTo = GetEmailToAddresses(intNextStageId, DeptId, "SPD.ACCESS", "SPD.ACCESS.IM")

			'Get addresses from Web Config for DEV, BETA, PROD, and VENDOR backup
			env = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("Environment"), "stringu", False)
			Select Case env
				Case "DEV"
					toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVToEmails"), "string", False)
					ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVccEmails"), "string", False)
					bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVbccEmails"), "string", False)
					vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSmtpServer"), "string", False)
					spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSpedyURL"), "string", False)
				Case "BETA"
					toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAToEmails"), "string", False)
					ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAccEmails"), "string", False)
					bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAbccEmails"), "string", False)
					vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASmtpServer"), "string", False)
					spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASpedyURL"), "string", False)
				Case "PROD"
					toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODToEmails"), "string", False)
					ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODccEmails"), "string", False)
					bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODbccEmails"), "string", False)
					vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSmtpServer"), "string", False)
					spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSpedyURL"), "string", False)
				Case "VENDOR"
					toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORToEmails"), "string", False)
					ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORccEmails"), "string", False)
					bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORbccEmails"), "string", False)
					vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORSmtpServer"), "string", False)
					spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("VENDORSpedyURL"), "string", False)
				Case Else
					toEmailAddresses = String.Empty
					ccEmailAddresses = String.Empty
					bccEmailAddresses = String.Empty
					vcSMTPServer = String.Empty
					spedyURL = String.Empty
					retMessage = "Invalid email Config in Web.Config. Contact Support."
					Return retMessage
			End Select

			' Used to dump the email addresses for Beta and Dev enviroments email
			Dim emailQueryResults As String = vcTo

			' User email addresses from SQL query only if PROD and query returns records
			If (env <> "PROD" And env <> "VENDOR") OrElse vcTo.Length = 0 Then
				vcTo = toEmailAddresses
			End If

			vcCC = ccEmailAddresses
			vcBCC = bccEmailAddresses

			'Construct Email Message
			If approvaltype = DISAPPROVE Then
				e_mailsubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved items for " & vendor_name & " Log ID# " & batchRecord.ID

				e_mailbody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved items for " & vendor_name & " Log ID# " & _
				 batchRecord.ID & " for the following reason:<BR><BR> " & notes & "<BR><BR>" & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & _
				 " can be contacted at " & Session(cEMAIL) & "<BR><BR>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review ASAP."
			Else
				e_mailsubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved items for " & vendor_name & " Log ID# " & batchRecord.ID

				e_mailbody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved items for " & vendor_name & " Log ID# " & _
				 batchRecord.ID & ".<BR><BR> " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " can be contacted at " & _
				  Session(cEMAIL) & "<BR><BR>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review ASAP."
			End If

			' Get Email From info from Web.config
			vcSender = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("FromEmailAddress"), "string", False)
			If vcSender.Length = 0 Then vcSender = "DATAFLOW@michaels.com"

			vcFrom = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("FromEmailName"), "string", False)
			If vcFrom.Length = 0 Then vcFrom = "Michaels DataFlow" '    "'" &  Session(cEMAIL) & "'"

			'DEV information
			If env = "DEV" OrElse env = "BETA" Then
				e_mailsubject = "SPEDY System Test Message, Please Disregard! " & e_mailsubject
				e_mailbody = e_mailbody & " <br /><br />TO Email Addresses returned by query:<br /><code>" & Server.HtmlEncode(emailQueryResults) & "</code>"
			End If

			If vcSMTPServer.Length = 0 Then		' JIC its not in the Web.Config file
				If Request.ServerVariables("HTTP_HOST") = "michaels.novalibra.com" Or _
				 Request.ServerVariables("HTTP_HOST") = "spedy.novalibra.com" Or _
				 InStr(Request.ServerVariables("HTTP_HOST"), "localhost:") <> 0 Then
					vcSMTPServer = "192.168.1.9"
				Else
					vcSMTPServer = "mail.michaels.com"
				End If
			End If


			SQPLSMPTSendEmail(vcSender, vcFrom, vcTo, vcCC, vcBCC, e_mailsubject, e_mailbody, bAutoGenerateTextBody, vcSMTPServer, bAuthenticate)


		Catch ex As Exception
            'need a way to log exception
            retMessage = "Error in Send Message1: " & ex.Message
            ' ProcessException(ex, "SendMail")
        End Try

		Return retMessage
	End Function

    Protected Function SendEmail(ByVal poRecord As Models.POCreationRecord, ByVal intNextStageId As Integer, ByVal approvaltype As String, ByVal notes As String) As String

        Dim retMessage As String = String.Empty
        Dim emailSubject As String = String.Empty
        Dim emailBody As String = String.Empty
        Dim spedyURL As String = "|*SPEDYURL*|" 'Replace this with actual value when getting values from the Web.Config

        Try
            'Construct Email Message
            Select Case approvaltype
                Case "DISAPPROVE"
                    emailSubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved PO Creation Batch#: " & poRecord.BatchNumber
                    emailBody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved PO Creation Batch#: " & poRecord.BatchNumber & _
                     "<BR/>Vendor: (" & poRecord.VendorNumber & ") " & poRecord.VendorName & " <BR/>Department ID: " & DataHelper.SmartValue(poRecord.WorkflowDepartmentID, "CInt", 0) & _
                    "<BR/>for the following reasons: <BR/><BR/>" & notes & "<BR/><BR/>" & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & _
                    " can be contacted at " & Session(cEMAIL) & "<BR/><BR/>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review ASAP."
                Case "APPROVE"
                    emailSubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved PO Creation Batch#: " & poRecord.BatchNumber
                    emailBody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved PO Creation Batch#: " & poRecord.BatchNumber & _
                     "<BR/>Vendor: (" & poRecord.VendorNumber & ") " & poRecord.VendorName & " <BR/>Department ID: " & DataHelper.SmartValue(poRecord.WorkflowDepartmentID, "CInt", 0) & _
                    "<BR/><BR/>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review."
                Case "REMOVE"
                    Return retMessage = "do nothing atm"
                Case "RESTORE"
                    Return retMessage = "do nothing atm"
                Case Else
                    retMessage = "Invalid Action performed. Contact Support"
                    Return retMessage
            End Select

            retMessage = GetValuesAndSendEmail(intNextStageId, DataHelper.SmartValue(poRecord.WorkflowDepartmentID, "CInt", 0), emailSubject, emailBody)
        Catch ex As Exception
            retMessage = "Error in Send Message2: " & ex.Message
        End Try

        Return retMessage
    End Function

    Protected Function SendEmail(ByVal poRecord As Models.POMaintenanceRecord, ByVal intNextStageId As Integer, ByVal approvaltype As String, ByVal notes As String) As String

        Dim retMessage As String = String.Empty
        Dim emailSubject As String = String.Empty
        Dim emailBody As String = String.Empty
        Dim spedyURL As String = "|*SPEDYURL*|" 'Replace this with actual value when getting values from the Web.Config

        Try
            'Construct Email Message
            Select Case approvaltype
                Case "DISAPPROVE"
                    emailSubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved PO#: " & poRecord.PONumber & " for PO Maintenance Batch#: " & poRecord.BatchNumber
                    emailBody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has disapproved  PO#: " & poRecord.PONumber & " for PO Maintenance Batch#: " & poRecord.BatchNumber & _
                    "<BR/>Vendor: (" & poRecord.VendorNumber & ") " & poRecord.VendorName & " <BR/>Department ID: " & DataHelper.SmartValue(poRecord.WorkflowDepartmentID, "CInt", 0) & _
                    "<BR/>for the following reasons: <BR/><BR/>" & notes & "<BR/><BR/>" & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & _
                    " can be contacted at " & Session(cEMAIL) & "<BR/><BR/>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review ASAP."
                Case "APPROVE"
                    emailSubject = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved  PO#: " & poRecord.PONumber & " for PO Maintenance Batch#: " & poRecord.BatchNumber
                    emailBody = "SPEDY user " & Session(cFIRSTNAME) & " " & Session(cLASTNAME) & " has approved  PO#: " & poRecord.PONumber & "for PO Maintenance Batch#: " & poRecord.BatchNumber & _
                    "<BR/>Vendor: (" & poRecord.VendorNumber & ") " & poRecord.VendorName & " <BR/>Department ID: " & DataHelper.SmartValue(poRecord.WorkflowDepartmentID, "CInt", 0) & _
                    "<BR/><BR/>Please <a href='" & spedyURL & "'>log on to SPEDY</a> and review."
                Case "REMOVE"
                    Return retMessage = "do nothing atm"
                Case "RESTORE"
                    Return retMessage = "do nothing atm"
                Case Else
                    retMessage = "Invalid Action performed. Contact Support"
                    Return retMessage
            End Select

            retMessage = GetValuesAndSendEmail(intNextStageId, DataHelper.SmartValue(poRecord.WorkflowDepartmentID, "CInt", 0), emailSubject, emailBody)
        Catch ex As Exception
            retMessage = "Error in Send Message3: " & ex.Message
        End Try

        Return retMessage

    End Function

    Protected Function GetValuesAndSendEmail(ByVal intNextStageId As Integer, ByVal DeptId As Integer, ByVal emailSubject As String, ByVal emailBody As String) As String
        'this procedure sends e-mail to users who have rights to approve, based on departments and workflow group
        Dim vcTo As String = String.Empty, vcSender, vcFrom As String, vcCC As String, vcBCC As String, vcSMTPServer As String = String.Empty, spedyURL As String = String.Empty
        Dim bAutoGenerateTextBody As Integer = 1, bAuthenticate As Byte = 0
        Dim retMessage As String = String.Empty
        Dim toEmailAddresses As String = String.Empty, ccEmailAddresses As String = String.Empty, bccEmailAddresses As String = String.Empty, env As String

        Try
            'GET "TO" Email Addresses
            vcTo = GetEmailToAddresses(intNextStageId, DeptId, "SPD.ACCESS.PONEW", "SPD.ACCESS.POMAINT")

            'Get addresses from Web Config for DEV, BETA, PROD, and VENDOR backup
            env = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("Environment"), "stringu", False)
            Select Case env
                Case "DEV"
                    toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVToEmails"), "string", False)
                    ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVccEmails"), "string", False)
                    bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVbccEmails"), "string", False)
                    vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSmtpServer"), "string", False)
                    spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("DEVSpedyURL"), "string", False)
                Case "BETA"
                    toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAToEmails"), "string", False)
                    ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAccEmails"), "string", False)
                    bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETAbccEmails"), "string", False)
                    vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASmtpServer"), "string", False)
                    spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("BETASpedyURL"), "string", False)
                Case "PROD"
                    toEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODToEmails"), "string", False)
                    ccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODccEmails"), "string", False)
                    bccEmailAddresses = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODbccEmails"), "string", False)
                    vcSMTPServer = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSmtpServer"), "string", False)
                    spedyURL = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("PRODSpedyURL"), "string", False)
                Case Else
                    toEmailAddresses = String.Empty
                    ccEmailAddresses = String.Empty
                    bccEmailAddresses = String.Empty
                    vcSMTPServer = String.Empty
                    spedyURL = String.Empty
                    retMessage = "Invalid email Config in Web.Config. Contact Support."
                    Return retMessage
            End Select

            'Replace SPEDY URL placeholder with value from Web.config file
            emailBody = emailBody.Replace("|*SPEDYURL*|", spedyURL)

            ' Used to dump the email addresses for Beta and Dev enviroments email
            Dim emailQueryResults As String = vcTo

            ' User email addresses from SQL query only if PROD and query returns records
            If (env <> "PROD" And env <> "VENDOR") OrElse vcTo.Length = 0 Then
                vcTo = toEmailAddresses
            End If

            vcCC = ccEmailAddresses
            vcBCC = bccEmailAddresses

            ' Get Email From info from Web.config
            vcSender = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("FromEmailAddress"), "string", False)
            If vcSender.Length = 0 Then vcSender = "DATAFLOW@michaels.com"

            vcFrom = DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings("FromEmailName"), "string", False)
            If vcFrom.Length = 0 Then vcFrom = "Michaels DataFlow" '    "'" &  Session(cEMAIL) & "'"

            'DEV information
            If env = "DEV" OrElse env = "BETA" Then
                emailSubject = "SPEDY System Test Message, Please Disregard! " & emailSubject
                emailBody = emailBody & " <br /><br />TO Email Addresses returned by query:<br /><code>" & Server.HtmlEncode(emailQueryResults) & "</code>"
            End If

            If vcSMTPServer.Length = 0 Then     ' JIC its not in the Web.Config file
                If Request.ServerVariables("HTTP_HOST") = "michaels.novalibra.com" Or _
                 Request.ServerVariables("HTTP_HOST") = "spedy.novalibra.com" Or _
                 InStr(Request.ServerVariables("HTTP_HOST"), "localhost:") <> 0 Then
                    vcSMTPServer = "192.168.1.9"
                Else
                    vcSMTPServer = "mail.michaels.com"
                End If
            End If

            SQPLSMPTSendEmail(vcSender, vcFrom, vcTo, vcCC, vcBCC, emailSubject, emailBody, bAutoGenerateTextBody, vcSMTPServer, bAuthenticate)

        Catch ex As Exception
            retMessage = "Error in Send Message4: " & ex.Message
        End Try

        Return retMessage
    End Function

    Private Function GetEmailToAddresses(ByVal workflowStageID As Integer, ByVal departmentID As Integer, ByVal permissionConstantNew As String, ByVal permissionConstantMaint As String) As String
        'GET "TO" Email Addresses based off of WorkflowStage and Department
        Dim toEmailAddresses As String = String.Empty
        Dim reader As SqlDataReader
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            Command.Parameters.Add("@WorkflowStageID", SqlDbType.Int).Value = workflowStageID
            Command.Parameters.Add("@DeptID", SqlDbType.Int).Value = departmentID
            Command.Parameters.Add("@Permission_Constant_New", SqlDbType.VarChar).Value = permissionConstantNew
            Command.Parameters.Add("@Permission_Constant_Maint", SqlDbType.VarChar).Value = permissionConstantMaint

            Command.CommandText = "sp_SPD2_Approval_GetEmailList"
            Command.Connection.Open()
            reader = Command.ExecuteReader()
            While reader.Read
                toEmailAddresses = toEmailAddresses & " " & reader("first_name").ToString & " " & reader("last_name").ToString & " <" & reader("email_address").ToString & ">;"
            End While
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()

            Throw ex
        Finally
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
            reader = Nothing
        End Try

        Return toEmailAddresses
    End Function

    Private Sub SQPLSMPTSendEmail(ByVal senderEmail As String, ByVal fromEmail As String, ByVal toEmails As String, ByVal ccEmails As String, ByVal bccEmails As String, ByVal emailSubject As String, ByVal emailBody As String, ByVal autoGenerateTextBody As Boolean, ByVal smtpServer As String, ByVal authenticate As Boolean)
        'SEND EMAIL
        Dim toEmailAddresses As String = String.Empty
        Dim reader As SqlDataReader
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure

            Command.Parameters.Add("@vcSender", SqlDbType.VarChar).Value = senderEmail
            Command.Parameters.Add("@vcFrom", SqlDbType.VarChar).Value = fromEmail
            Command.Parameters.Add("@vcTo", SqlDbType.VarChar).Value = toEmails
            Command.Parameters.Add("@vcCC", SqlDbType.VarChar).Value = ccEmails
            Command.Parameters.Add("@vcBCC", SqlDbType.VarChar).Value = bccEmails
            Command.Parameters.Add("@vcSubject", SqlDbType.VarChar).Value = emailSubject
            Command.Parameters.Add("@vcHTMLBody", SqlDbType.VarChar).Value = emailBody
            Command.Parameters.Add("@bAutoGenerateTextBody", SqlDbType.Bit).Value = autoGenerateTextBody
            Command.Parameters.Add("@vcSMTPServer", SqlDbType.VarChar).Value = smtpServer
            Command.Parameters.Add("@bAuthenticate", SqlDbType.Bit).Value = authenticate

            Command.Connection.Open()
            Command.CommandText = "sp_SQLSMTPMail"
            Command.ExecuteScalar()
            Command.Connection.Close()

        Catch ex As Exception
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
            Throw ex
        Finally
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
            reader = Nothing
        End Try
    End Sub
End Class

