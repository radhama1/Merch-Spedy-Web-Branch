Imports System
Imports System.Diagnostics
Imports System.Data
Imports System.Collections.generic
Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports WebConstants


Partial Class IMCostChange
    Inherits MichaelsBasePage

#Region "Properties"
    Private _validFlag As ItemValidFlag = ItemValidFlag.Unknown
    Private _validWasUnknown As Boolean = False

    'Private _refreshGrid As Boolean = False
    Private _closeForm As Boolean = False
    Private _headerVendorNumber As Long
    Private _headerLastChangedBy As String
    Private _headerLastChangedOn As String
    Private _workflowStageID As Integer = 0
    Private _userID As Long = 0
    Private _vendorID As Long = 0
    Private _headerItemID As Integer

    ' Load up the Metadata for Save
    Private md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
    Private mdTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
    Private mdColumn As NovaLibra.Coral.SystemFrameworks.MetadataColumn

    Private _IMChanges As List(Of IMChangeRecord) = Nothing

    Public Property BatchID() As Integer
        Get
            Return ViewState("BatchID")
        End Get
        Set(ByVal value As Integer)
            ViewState("BatchID") = value
        End Set
    End Property

    Public Property HeaderItemID() As Integer
        Get
            Dim o As Object = Me.ViewState("ItemID")
            If Not o Is Nothing Then
                Return CType(o, Integer)
            Else
                Return -1
            End If
            ' Return ViewState("ItemID")
        End Get
        Set(ByVal value As Integer)
            ViewState("ItemID") = value
        End Set
    End Property

    Private Property WorkflowStageID() As Integer
        Get
            Return _workflowStageID
        End Get
        Set(ByVal value As Integer)
            _workflowStageID = value
        End Set
    End Property

    Private Property VendorID() As Long
        Get
            Return _vendorID
        End Get
        Set(ByVal value As Long)
            _vendorID = value
        End Set
    End Property

    Private Property UserID() As Long
        Get
            Return _userID
        End Get
        Set(ByVal value As Long)
            _userID = value
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
            _headerLastChangedOn = value
        End Set
    End Property

    Public Property CloseForm() As Boolean
        Get
            Return _closeForm
        End Get
        Set(ByVal value As Boolean)
            _closeForm = value
        End Set
    End Property

    Public ReadOnly Property ItemID() As String
        Get
            Return recordID.Value
        End Get
    End Property

    Public Property RefreshGrid() As Boolean
        Get
            Return ViewState("refreshGrid")
        End Get
        Set(ByVal value As Boolean)
            ViewState("refreshGrid") = value
        End Set
    End Property

    Public Property AllowRefresh() As Boolean
        Get
            Return ViewState("AllowRefresh")
        End Get
        Set(ByVal value As Boolean)
            ViewState("AllowRefresh") = value
        End Set
    End Property

    Public Property IMChanges() As List(Of IMChangeRecord)
        Get
            Return _IMChanges
        End Get
        Set(ByVal value As List(Of IMChangeRecord))
            _IMChanges = value
        End Set
    End Property

#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not SecurityCheck() Then
            CloseTheForm()
        End If

        UserID = AppHelper.GetUserID()
        VendorID = AppHelper.GetVendorID

        If Not IsPostBack Then      ' INITAL PAGE LOAD
            Dim strTemp As String = Request("id")   ' Use request Object first (from Item Grid call)
            Dim itemID As Integer = 0
            ' For testing
            'strTemp = "408"
            If strTemp.Length > 0 And IsNumeric(strTemp) Then
                itemID = CType(strTemp, Integer)
            Else
                CloseTheForm()
            End If
            If Request("s") = "1" Then
                msg.InnerHtml = "Updates Saved"
                RefreshGrid = True
            Else
                RefreshGrid = False
                msg.InnerHtml = ""
            End If

            If Request("r") = "1" Then
                AllowRefresh = True
            Else
                AllowRefresh = False
            End If

            'If RefreshGrid AndAlso AllowRefresh Then
            '    hidRefreshParent.Value = "1"
            'Else
            '    hidRefreshParent.Value = "0"
            'End If

            PopulateGlobalVariables(itemID)
            PopulateGrid(itemID)

        Else

        End If


        ' VALIDATE USER
        ValidateUser(BatchID)
        If NoUserAccess Then CloseTheForm()
        If Not UserCanEdit Then
            btnUpdate.Enabled = False
            btnUpdateClose.Enabled = False
            LockField("btnCostChangeAction", "V")
        End If
    End Sub

    Public Function GetInfo(ByVal itemID As Integer, ByVal COO As String, ByVal effectiveDate As String, ByVal type As String) As String
        Dim ChangeRec As Models.IMChangeRecord
        ChangeRec = FormHelper.FindIMChangeRecord(IMChanges, itemID, cFUTURECOSTSTATUS, COO, "", effectiveDate, 0)
        If ChangeRec.ItemID > 0 Then
            If type = "S" Then Return "Canceled"
            ' else B
            Return "Restore"
        End If
        If type = "S" Then Return "Active"
        ' else B
        Return "Cancel"
    End Function

    Private Sub CloseTheForm()
        Response.Redirect(String.Format("closeform.aspx?rl={0}", IIf(RefreshGrid AndAlso AllowRefresh, "1", "0")))
    End Sub

    Private Sub ProcessException(ByVal e As Exception, ByVal strSourceName As String)
        Dim strmessage As String
        strmessage = "Unexpected SPEDY problem has occured in the routine: " & strSourceName & " - "
        strmessage = strmessage & e.Message & ". Please report this issue to the System Administrator."
        ShowMsg1(strmessage)
    End Sub

    Private Sub ShowMsg1(ByVal strMsg As String)
        Dim curMsg As String
        If strMsg.Length = 0 Then
            lblMessage.Text = "&nbsp;" ' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
        Else
            curMsg = lblMessage.Text
            If curMsg = "&nbsp;" Then       ' Only set the message if there is not one in there already
                lblMessage.Text = strMsg
            Else
                lblMessage.Text += "<br />" & strMsg
            End If
        End If
    End Sub

    Private Sub PopulateGlobalVariables(ByVal itemID As Integer)

        Dim ItemHeader As Models.ItemMaintItem

        HeaderItemID = itemID
        ItemHeader = Data.MaintItemMasterData.GetItemMaintHeaderRec(HeaderItemID)

        If ItemHeader IsNot Nothing AndAlso ItemHeader.ID > 0 Then

            HeaderItemID = ItemHeader.ID
            HeaderLastChangedBy = ItemHeader.LastUpdateUserName
            HeaderLastChangedOn = ItemHeader.LastUpdateDate
            BatchID = ItemHeader.BatchID

            Dim objMichaelsBatch As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
            Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaelsBatch.GetRecord(ItemHeader.BatchID)
            objMichaelsBatch = Nothing

            If batchDetail.ID > 0 Then
                WorkflowStageID = batchDetail.WorkflowStageID
            End If
        End If

    End Sub

    Private Sub PopulateGrid(ByVal itemID As Integer)

        Dim CostRecs As List(Of Models.ItemMaintItemCostRecord)
        Dim HeaderRec As New Models.ItemMaintItemCostRecord
        Dim batchdetail As Models.BatchRecord

        Try
            CostRecs = BatchesData.GetFutureCosts(itemID, HeaderRec)

            If HeaderRec.ID > 0 Then
                Dim objData As New Data.BatchData()
                batchdetail = objData.GetBatchRecord(HeaderRec.BatchID)
                objData = Nothing
                If HeaderRec.BatchID > 0 Then
                    batch.Text = " &nbsp;|&nbsp; Log ID: " & HeaderRec.BatchID.ToString()
                End If
                If batchdetail.VendorName <> "" Then
                    batchVendorName.Text = " &nbsp;|&nbsp; " & "Vendor: " & batchdetail.VendorName
                End If
                If batchdetail.WorkflowStageName <> "" Then
                    stageName.Text = " &nbsp;|&nbsp; " & "Stage: " & batchdetail.WorkflowStageName
                End If
                If HeaderLastChangedOn <> "" Then
                    lastUpdated.Text = " &nbsp;|&nbsp; " & "Last Updated: " & HeaderLastChangedOn   '.ToString("M/d/yyyy")
                    If HeaderLastChangedBy <> "" Then
                        lastUpdated.Text += " by " & HeaderLastChangedBy
                    End If
                End If
                SKU.Text = HeaderRec.SKU
                VendorNumber.Text = HeaderRec.VendorNumber
                VendorName.Text = HeaderRec.VendorName
                PrimaryUPC.Text = HeaderRec.PrimaryUPC
                ItemDesc.Text = HeaderRec.ItemDesc
                VendorStyleNum.Text = HeaderRec.VendorStyleNum
                IMChanges = Data.MaintItemMasterData.GetIMChangeRecordsByItemID(itemID)
                ' Apply changes to Cost Records when the grid populates
            End If

            gvCostChanges.DataSource = CostRecs
            gvCostChanges.DataBind()

            If CostRecs.Count = 0 Then
                btnUpdate.Enabled = False
                btnUpdateClose.Enabled = False
            Else
                ' Implement Field Locking
                Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
                Dim objMichaels As New Data.MaintItemMasterData
                itemFL = objMichaels.GetFieldLocking(AppHelper.GetUserID(), Models.MetadataTable.vwItemMaintCostChanges, AppHelper.GetVendorID(), WorkflowStageID, True)
                ImplementFieldLocking(itemFL)
            End If

        Catch ex As Exception
            ProcessException(ex, "PopulateGrid")
        End Try
    End Sub

    Private Sub ImplementFieldLocking(ByRef itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking)
        For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
            LockField(col.ColumnName, col.Permission)
        Next
    End Sub

    Public Overrides Sub LockField(ByVal colName As String, ByVal permission As Char)
        Select UCase(permission)
            Case "N", "V"            ' Disable control
                Select Case colName
                    Case "btnCostChangeAction"  ' Hide all btnAction buttons
                        Dim ctlButton As Button
                        For Each row As GridViewRow In gvCostChanges.Rows
                            If row.RowType = DataControlRowType.DataRow Then
                                ctlButton = row.Cells(3).FindControl("btnAction")
                                If ctlButton IsNot Nothing Then
                                    ctlButton.Enabled = False
                                End If
                            End If
                        Next
                End Select
        End Select
    End Sub

    Private Function SaveChanges() As Integer
        Dim changeRec As Models.IMChangeRecord = New Models.IMChangeRecord
        Dim origChangeRec As Models.IMChangeRecord = New Models.IMChangeRecord
        Dim CostRecs As List(Of Models.ItemMaintItemCostRecord)
        Dim hdnField As HiddenField
        Dim curStatus As String = String.Empty
        Dim strOrig As String = String.Empty
        Dim ChangeExists As Boolean
        Dim HeaderRec As New Models.ItemMaintItemCostRecord

        ' Get original Records
        CostRecs = BatchesData.GetFutureCosts(HeaderItemID, HeaderRec)
        ' get exist Change Records
        IMChanges = Data.MaintItemMasterData.GetIMChangeRecordsByItemID(HeaderItemID)

        changeRec.ItemID = HeaderItemID
        changeRec.FieldName = cFUTURECOSTSTATUS
        changeRec.Counter = 0
        changeRec.UPC = ""
        changeRec.ChangedByID = UserID
        Try
            For Each row As GridViewRow In gvCostChanges.Rows
                If row.RowType = DataControlRowType.DataRow Then
                    hdnField = row.Cells(4).FindControl("hdnStatus")
                    curStatus = hdnField.Value
                    hdnField = row.Cells(4).FindControl("hdnPriCOO")
                    changeRec.CountryOfOrigin = hdnField.Value
                    hdnField = row.Cells(4).FindControl("hdnEffectiveDate")
                    changeRec.EffectiveDate = hdnField.Value
                    origChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, cFUTURECOSTSTATUS, changeRec.CountryOfOrigin, "", changeRec.EffectiveDate, 0)
                    If origChangeRec.ItemID > 0 Then
                        changeRec.FieldValue = origChangeRec.FieldValue
                        ChangeExists = True
                    Else
                        changeRec.FieldValue = ""
                        ChangeExists = False
                    End If
                    strOrig = "Active"
                    FormHelper.CheckandSave(curStatus, strOrig, changeRec, ChangeExists)
                End If
            Next
        Catch ex As Exception
            ProcessException(ex, "SaveChanges")
        End Try
        Return HeaderItemID

        'TODO - VALIDATION NEEDS TO BE DONE FIRST? ALSO NEED TO LOOK UP ANY ADDITIONAL COUNTRY CODES

    End Function

    Protected Sub gvCostChanges_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvCostChanges.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim ctrlButton As Object
            Dim intRowIndex As Integer = e.Row.RowIndex + 1
            ctrlButton = e.Row.FindControl("btnAction")
            ctrlButton.Attributes.Add("onclick", "CheckStatus(" & intRowIndex & "); return false;")
        End If
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        If UserCanEdit Then
            Dim saveID As Integer = SaveChanges() '  SaveFormData()
            If saveID > 0 Then
                Response.Redirect("IMCostChange.aspx?id=" & saveID.ToString & "&s=1")
            End If
            msg.InnerHtml = "Save Failed"
            RefreshGrid = False
        End If

    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click
        If UserCanEdit Then
            Dim saveID As Integer = SaveChanges() '  SaveFormData()
            If saveID > 0 Then
                RefreshGrid = True
                CloseTheForm()
            End If
            msg.InnerHtml = "Save Failed"
        End If
    End Sub
End Class
