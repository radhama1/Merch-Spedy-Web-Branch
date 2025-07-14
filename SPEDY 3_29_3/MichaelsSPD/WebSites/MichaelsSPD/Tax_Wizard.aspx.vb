Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Xml
Imports System.Web.UI.WebControls

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class _Tax_Wizard
    Inherits MichaelsBasePage

    Dim _Selected_Tax_UDA_ID As Long = 0
    Dim _closeScript As String = String.Empty

    Public Property CloseScript() As String
        Get
            Return _closeScript
        End Get
        Set(ByVal value As String)
            _closeScript = value
        End Set
    End Property

    Public Property Selected_Tax_UDA_ID() As Long
        Get
            Return _Selected_Tax_UDA_ID
        End Get
        Set(ByVal value As Long)
            _Selected_Tax_UDA_ID = value
        End Set
    End Property

    Public Property ItemType() As Models.TaxWizardData.TaxWizardItemType
        Get
            Dim o As Object = Me.ViewState.Item("ItemType")
            If Not o Is Nothing Then
                If CType(o, String) = "I" Then
                    Return Models.TaxWizardData.TaxWizardItemType.Import
                Else
                    Return Models.TaxWizardData.TaxWizardItemType.Domestic
                End If
            Else
                ItemType = Models.TaxWizardData.TaxWizardItemType.Domestic
            End If
        End Get
        Set(ByVal value As Models.TaxWizardData.TaxWizardItemType)
            If value = Models.TaxWizardData.TaxWizardItemType.Import Then
                Me.ViewState.Item("ItemType") = "I"
            Else
                Me.ViewState.Item("ItemType") = "D"
            End If
        End Set
    End Property

    Public Property CanEdit() As Boolean
        Get
            Dim o As Object = Me.ViewState.Item("CanEdit")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Item("CanEdit") = value
        End Set
    End Property

    Public Property CanView() As Boolean
        Get
            Dim o As Object = Me.ViewState.Item("CanView")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Item("CanView") = value
        End Set
    End Property

    Public Property SetAll() As Boolean
        Get
            Dim o As Object = Me.ViewState.Item("SetAll")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Item("SetAll") = value
        End Set
    End Property

    Public Property BatchID() As Long
        Get
            Dim o As Object = Me.ViewState.Item("BatchID")
            If Not o Is Nothing Then
                Return CType(o, Long)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Long)
            Me.ViewState.Item("BatchID") = value
        End Set
    End Property

    Public Property ItemHeaderID() As Long
        Get
            Dim o As Object = Me.ViewState.Item("ItemHeaderID")
            If Not o Is Nothing Then
                Return CType(o, Long)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Long)
            Me.ViewState.Item("ItemHeaderID") = value
        End Set
    End Property

    Public Property ItemID() As Long
        Get
            Dim o As Object = Me.ViewState.Item("ItemID")
            If Not o Is Nothing Then
                Return CType(o, Long)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Long)
            Me.ViewState.Item("ItemID") = value
        End Set
    End Property

    Public ReadOnly Property UserID() As Long
        Get
            Dim o As Object = Me.Session("UserID")
            If Not o Is Nothing Then
                Return DataHelper.SmartValues(o, "long", False)
            End If
        End Get
    End Property

    Protected Sub ddlTaxUDA_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlTaxUDA.PreRender
        If ddlTaxUDA.Items(0).Text <> "" Then
            ddlTaxUDA.Items.Insert(0, New ListItem("", 0))
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Me.ClientScript.GetPostBackEventReference(Me, String.Empty)

        Dim batch As Integer = 0

        If Not IsPostBack Then
            If (Request("id") <> "" And IsNumeric(Request("id"))) Then
                ItemID = DataHelper.SmartValues(Request("id"), "long", False)
            End If
            If Request("type") <> "" AndAlso Request("type") = "I" Then
                ItemType = Models.TaxWizardData.TaxWizardItemType.Import
            Else
                ItemType = Models.TaxWizardData.TaxWizardItemType.Domestic
            End If
            SetAll = False
            If Request("sa") <> "" AndAlso Request("sa") = "1" Then
                If ItemType = Models.TaxWizardData.TaxWizardItemType.Import Then
                    If Request("bid") <> "" AndAlso IsNumeric(Request("bid")) Then
                        BatchID = DataHelper.SmartValues(Request("bid"), "long", False)
                        SetAll = True
                    End If
                Else
                    If Request("hid") <> "" And IsNumeric(Request("hid")) Then
                        ItemHeaderID = DataHelper.SmartValues(Request("hid"), "long", False)
                        SetAll = True
                    End If
                End If
            End If

            ' ------------------------------
            ' VALIDATION CHECK
            Dim objM As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
            Dim objMI As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
            If ItemType = Models.TaxWizardData.TaxWizardItemType.Import Then
                ' import
                If ItemID > 0 Then
                    Dim item As Models.ImportItemRecord = objMI.GetRecord(ItemID)
                    If Not item Is Nothing Then
                        ValidateUser(item.Batch_ID)
                        item = Nothing
                    End If
                End If
            Else
                ' domestic
                If SetAll Then
                    Dim itemHeader As Models.ItemHeaderRecord = objM.GetItemHeaderRecord(ItemHeaderID)
                    If Not itemHeader Is Nothing Then
                        ValidateUser(itemHeader.BatchID)
                        itemHeader = Nothing
                    End If
                Else
                    Dim item As Models.ItemRecord = objM.GetRecord(ItemID)
                    If Not item Is Nothing Then
                        ValidateUser(item.BatchID)
                        item = Nothing
                    End If
                End If
            End If

            CanEdit = UserCanEdit
            CanView = UserCanView

            objM = Nothing
            objMI = Nothing
            ' END VALIDATION CHECK
            ' ------------------------------

            If SetAll Then
                btnCommit.Text = "Okay, Apply these Settings to entire Batch!"
                btnCommit.Attributes.Add("onclick", "return confirm('Are you sure you want to save these settings for the entire batch?')")
            End If

            ' load ddlTaxUDA
            Dim selectSQL As String = "SELECT * FROM SPD_Tax_UDA WHERE Enabled = 1 AND DATEDIFF(n, getdate(), COALESCE(Start_Date, getdate())) <= 0 AND DATEDIFF(n, getdate(), COALESCE(End_Date, getdate())) >= 0 ORDER BY SortOrder, Tax_UDA_Number, Tax_UDA_Description"
            ddlTaxUDA.DataTextField = "Tax_UDA_Description"
            ddlTaxUDA.DataValueField = "ID"
            Dim reader As New DBReader(ApplicationConnectionStrings.AppConnectionString)
            reader.CommandText = selectSQL
            reader.CommandType = CommandType.Text
            reader.Open()
            ddlTaxUDA.DataSource = reader.Reader
            ddlTaxUDA.DataBind()
            reader.Dispose()
            reader = Nothing

            ' load current values
            Dim objTW As NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData
            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
            objTW = objMichaels.GetTaxWizardData(ItemType, ItemID, UserID)
            objMichaels = Nothing
            If objTW.TaxUDAID > 0 Then
                ddlTaxUDA.SelectedValue = objTW.TaxUDAID
                Selected_Tax_UDA_ID = objTW.TaxUDAID

                LoadTree(objTW)
            End If

        Else
            If ddlTaxUDA.SelectedIndex > 0 Then
                Selected_Tax_UDA_ID = DataHelper.SmartValues(ddlTaxUDA.SelectedItem.Value, "long", False)
            End If
        End If

        If Not CanEdit Then
            btnCommit.Visible = False
        End If
        If Not CanView Then
            Response.Redirect("closeform.aspx")
        End If


    End Sub

    Protected Sub tvTaxQuestions_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles tvTaxQuestions.Load
        tvTaxQuestions.ShowLines = False
        tvTaxQuestions.NodeWrap = True
    End Sub

    Protected Sub ddlTaxUDA_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlTaxUDA.SelectedIndexChanged
        LoadTree(Nothing)
    End Sub

    Protected Sub btnCommit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCommit.Click

        If CanEdit Then
            Dim objTW As New NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData()
            'Dim sb As New StringBuilder("")
            objTW.ItemType = ItemType
            objTW.ItemID = ItemID
            objTW.TaxUDAID = Selected_Tax_UDA_ID

            ' tree nodes
            Dim i As Integer
            For i = 0 To tvTaxQuestions.Nodes.Count - 1
                If (tvTaxQuestions.Nodes(i).Checked And IsNumeric(tvTaxQuestions.Nodes(i).Value)) Then objTW.TaxQuestions.Add(DataHelper.SmartValues(tvTaxQuestions.Nodes(i).Value, "long", False))
                SaveChildNodes(tvTaxQuestions.Nodes(i), objTW)
            Next

            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()

            Dim taxUDANumber As Integer = 0
            If Selected_Tax_UDA_ID > 0 Then
                taxUDANumber = objMichaels.GetTaxUDANumber(Selected_Tax_UDA_ID)
            End If

            Dim completed As String = "false"
            If Selected_Tax_UDA_ID > 0 Then
                completed = "true"
            End If


            ' save the data
            If Not SetAll Then
                SaveData(ItemID, objMichaels, objTW, taxUDANumber)
                CloseScript = "refreshAndClose('" & ItemID & "', " & completed & ", " & taxUDANumber & ");"
                panelForm.Visible = False
                panelClose.Visible = True
            Else
                ' set all 
                SaveDataSetAll(objMichaels, objTW, taxUDANumber)
                'CloseScript = "reloadAndClose();"

                If ItemID > 0 Then
                    CloseScript = "refreshReloadAndClose('" & ItemID & "', " & completed & ", " & taxUDANumber & ");"
                Else
                    CloseScript = "reloadAndClose();"
                End If

                panelForm.Visible = False
                panelClose.Visible = True
            End If

            ' clean up
            objTW = Nothing
            objMichaels = Nothing
        End If



    End Sub

    Private Function SaveDataSetAll(ByVal objMichaels As NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail, ByVal objTW As NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData, ByVal taxUDANumber As Integer) As Boolean

        Dim saveItemID As Long

        If Me.ItemType = NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData.TaxWizardItemType.Import Then
            ' IMPORT
            ' ----------------------
            Dim reader As New DBReader(ApplicationConnectionStrings.AppConnectionString)
            reader.CommandText = "select ID from SPD_Import_Items where ISNULL(Valid_Existing_SKU, 0) = 0 and Batch_ID = " & Me.BatchID
            reader.CommandType = CommandType.Text
            reader.Open()
            Do While reader.Read()
                saveItemID = DataHelper.SmartValues(reader("ID"), "long", False)
                SaveData(saveItemID, objMichaels, objTW, taxUDANumber)
            Loop
            reader.Dispose()
            reader = Nothing
        Else
            ' DOMESTIC
            ' ----------------------
            Dim reader As New DBReader(ApplicationConnectionStrings.AppConnectionString)
            reader.CommandText = "select ID from SPD_Items where ISNULL(Valid_Existing_SKU, 0) = 0 and Item_Header_ID = " & Me.ItemHeaderID
            reader.CommandType = CommandType.Text
            reader.Open()
            Do While reader.Read()
                saveItemID = DataHelper.SmartValues(reader("ID"), "long", False)
                SaveData(saveItemID, objMichaels, objTW, taxUDANumber)
            Loop
            reader.Dispose()
            reader = Nothing
        End If

        ' return
        Return True
    End Function

    Private Function SaveData(ByVal saveItemID As Long, ByVal objMichaels As NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail, ByVal objTW As NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData, ByVal taxUDANumber As Integer) As Boolean
        'objTW.ItemType = ItemType
        objTW.ItemID = saveItemID
        'objTW.TaxUDAID = Selected_Tax_UDA_ID

        Dim bRet As Boolean = objMichaels.SaveTaxWizardData(objTW, UserID)

        Dim audit As New Models.AuditRecord()
        If objTW.ItemType = NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData.TaxWizardItemType.Import Then
            audit.SetupAudit(NovaLibra.Coral.SystemFrameworks.Michaels.MetadataTable.Import_Items, ItemID, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, UserID)
        Else
            audit.SetupAudit(NovaLibra.Coral.SystemFrameworks.Michaels.MetadataTable.Items, ItemID, NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecordType.Update, UserID)
        End If
        If Selected_Tax_UDA_ID > 0 Then
            audit.AddAuditField("Tax_Wizard", "1")
            audit.AddAuditField("Tax_UDA", taxUDANumber.ToString())
        Else
            audit.AddAuditField("Tax_Wizard", "0")
            audit.AddAuditField("Tax_UDA", String.Empty)
        End If
        objMichaels.SaveAuditRecord(audit)

        ' clean up
        audit = Nothing

        ' return 
        Return True
    End Function

    Private Sub SaveChildNodes(ByRef nodeParent As TreeNode, ByRef objTW As Models.TaxWizardData)
        Dim j As Integer
        For j = 0 To nodeParent.ChildNodes.Count - 1
            If (nodeParent.ChildNodes(j).Checked And IsNumeric(nodeParent.ChildNodes(j).Value)) Then objTW.TaxQuestions.Add(DataHelper.SmartValues(nodeParent.ChildNodes(j).Value, "long", False))
            SaveChildNodes(nodeParent.ChildNodes(j), objTW)
        Next
    End Sub

    Private Sub LoadTree(ByRef objTW As NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData)
        If tvTaxQuestions.Nodes.Count > 0 Then
            tvTaxQuestions.Nodes.Clear()
        End If

        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()

        Dim questions As Models.TaxQuestions = Nothing
        If Selected_Tax_UDA_ID > 0 Then
            questions = objMichaels.GetTaxQuestions(Selected_Tax_UDA_ID)
        End If
        objMichaels = Nothing

        Dim nodeParent As TreeNode
        Dim arr As ArrayList = Nothing

        If Not questions Is Nothing Then
            arr = questions.GetRootQuestions()
            For Each tq As Models.TaxQuestionRecord In arr
                nodeParent = New TreeNode()
                nodeParent.Text = tq.TaxQuestion
                nodeParent.Value = tq.ID
                If Not objTW Is Nothing Then nodeParent.Checked = objTW.QuestionExists(tq.ID)
                nodeParent.SelectAction = TreeNodeSelectAction.None
                tvTaxQuestions.Nodes.Add(nodeParent)
                AddChildNodes(nodeParent, tq, questions, objTW)
            Next
            If Not arr Is Nothing Then arr.Clear()
            arr = Nothing
        End If


    End Sub

    Public Sub AddChildNodes(ByRef nodeParent As TreeNode, ByRef taxQuestion As Models.TaxQuestionRecord, ByRef questions As Models.TaxQuestions, ByRef objTW As Models.TaxWizardData)
        Dim nodeChild As TreeNode
        Dim arr As ArrayList = Nothing
        If taxQuestion.HasChildren Then
            arr = questions.GetChildren(taxQuestion.ID)
            For Each tq As Models.TaxQuestionRecord In arr
                nodeChild = New TreeNode()
                nodeChild.Text = tq.TaxQuestion
                nodeChild.Value = tq.ID
                If Not objTW Is Nothing Then nodeChild.Checked = objTW.QuestionExists(tq.ID)
                nodeChild.SelectAction = TreeNodeSelectAction.None
                nodeParent.ChildNodes.Add(nodeChild)
                AddChildNodes(nodeChild, tq, questions, objTW)
            Next
        End If
        If Not arr Is Nothing Then arr.Clear()
        arr = Nothing
    End Sub


End Class
