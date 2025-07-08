Imports WebConstants
Imports System.Collections.Generic
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Helper = NovaLibra.Common.Utilities.DataHelper
Imports Data = NovaLibra.Coral.Data.Michaels
Imports PagingFiltering = NovaLibra.Common.Utilities.PaginationXML
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities

Partial Public Class _POCreation
    Inherits MichaelsBasePage

    'PAGING
    Const cPOBATCHPERPAGE As String = "POBATCHPERPAGE"
    Const cPOBATCHCURPAGE As String = "POBATCHCURPAGE"
    Const cPOBATCHTOTALPAGES As String = "POBATCHTOTALPAGES"
    Const cPOBATCHSTARTROW As String = "POBATCHSTARTROW"
    Const cPOBATCHTOTALROWS As String = "POBATCHTOTALROWS"

    'SORTING
    Const cPOBATCHCURSORTCOL As String = "POBATCHCURSORTCOL"
    Const cPOBATCHCURSORTDIR As String = "POBATCHCURSORTDIR"

    'FILTERING
    Const cPOBATCHSHOWSTAGE As String = "POBATCHSHOWSTAGE"
    Const cPOCREATIONSEARCHFILTER As String = "POCREATIONSEARCHFILTER"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Check Session
        SecurityCheckRedirect()
        Session(CURRENTTAB) = PONEW

        ' Clear out messages
        ShowMsg("")

        If Not IsPostBack Then

			'Permissions
            GetRolePermissions()

            'Search Controls
            InitializeSearchControls()

            'Search Controls
            PopulateSearchControls()

            'Set Controls
            SetSearchControlValuesForSession()

            'Update Search Display
            UpdateFilterDisplay()

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

	Private Sub GetRolePermissions()
		'Verify user belongs to one of the PO Initiating roles
		If (BelongsToGroup(WebConstants.SecurityGroups.CAACMA) Or BelongsToGroup(WebConstants.SecurityGroups.ContentManagers) Or BelongsToGroup(WebConstants.SecurityGroups.MerchAnalyst) Or BelongsToGroup(WebConstants.SecurityGroups.NewStoreGroup) Or BelongsToGroup(WebConstants.SecurityGroups.VendorCAA) Or IsAdminDBCQA()) Then
			lnkAddNew.Visible = True
		Else
			lnkAddNew.Visible = False
		End If
	End Sub

    Private Sub InitializeSearchControls()

        'Enter Keypress Submits Search
        srchBatchNumber.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchWrittenStartDate.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchWrittenEndDate.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchSKU.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchVendor.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchLocation.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchVPN.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchDept.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchAllocationEvent.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchUPC.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchStockCat.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchBasicSeasonal.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchPOType.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchPODept.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchInitiator.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        txtVendorLookup.Attributes.Add("onkeypress", "return clickButton(event,'btnSaveVendorLookup')")

        'srchClass.Items.Insert(0, New ListItem("Select Department", "-1"))
        'srchSubClass.Items.Insert(0, New ListItem("Select Class", "-1"))
        'srchDept.Attributes.Add("onchange", "GetClass();")
        'srchClass.Attributes.Add("onchange", "GetSubClass();")
        srchUPC.Attributes.Add("onchange", "validateUPC();")
        btnSearch.Attributes.Add("onmouseover", "buttonHiLight(1);")
        btnSearch.Attributes.Add("onmouseout", "buttonHiLight(0);")
        btnReset.Attributes.Add("onmouseover", "buttonHiLight(1);")
        btnReset.Attributes.Add("onmouseout", "buttonHiLight(0);")
        srchVendor.Enabled = True
        srchVendor.CssClass = "calculatedField textBoxPad"

        'Do not remove from session until they remove it
        'Session.Contents.Remove(cPOCREATIONSEARCHFILTER)

        'Add/Remove Filter
        If Session(cPOCREATIONSEARCHFILTER) IsNot Nothing Then
            hidFilterApplied.Value = "1"
        End If

    End Sub

    Private Sub PopulateSearchControls()

        hidClass.Value = ""
        hidSubClass.Value = ""
        hidLockClass.Value = ""

        LoadSearchDropdowns()

    End Sub

    Private Sub LoadSearchDropdowns(Optional ByVal deptNo As Integer = 0, Optional ByVal StockCat As String = "", Optional ByVal ItemTypeAttr As String = "", Optional ByVal enableDept As Boolean = True, Optional ByVal enableStockCat As Boolean = True, Optional ByVal enableITA As Boolean = True)

        'GET Department information
        Dim departments As List(Of Models.DepartmentRecord)
        Dim objData As New Data.DepartmentData
        departments = objData.GetDepartments

        'Load Workflow Departments
        srchDept.DataSource = departments
        srchDept.DataTextField = "DeptDesc"
        srchDept.DataValueField = "Dept"
        srchDept.DataBind()
        srchDept.Items.Insert(0, New ListItem("*  Any Department  *", "0"))
        srchDept.SelectedValue = IIf(deptNo >= 0, deptNo, 0)

        'Load PO Departments
        srchPODept.DataSource = departments
        srchPODept.DataTextField = "DeptDesc"
        srchPODept.DataValueField = "Dept"
        srchPODept.DataBind()
        srchPODept.Items.Insert(0, New ListItem("*  Any Department  *", "0"))
        srchPODept.SelectedValue = IIf(deptNo >= 0, deptNo, 0)

        If deptNo > 0 AndAlso Not enableDept Then
            srchDept.Enabled = False
            srchDept.CssClass = "calculatedField"
        Else
            srchDept.Enabled = True
            srchDept.CssClass = ""
        End If

        Dim lvgs As NovaLibra.Coral.SystemFrameworks.ListValueGroups = FormHelper.LoadListValues("ITEMTYPEATTRIB,STOCKCAT")

        'Load Batch Stock Category
        FormHelper.LoadListFromListValues(srchStockCat, lvgs.GetListValueGroup("STOCKCAT"), True, "* Any Stock Category *")
        srchStockCat.SelectedValue = StockCat
        If StockCat <> "" AndAlso Not enableStockCat Then
            srchStockCat.Enabled = False
            srchStockCat.CssClass = "calculatedField"
        Else
            srchStockCat.Enabled = True
            srchStockCat.CssClass = ""
        End If

        'Load Basic/Seasonal
        srchBasicSeasonal.Items.Add(New ListItem("", ""))
        srchBasicSeasonal.Items.Add(New ListItem("Basic", "B"))
        srchBasicSeasonal.Items.Add(New ListItem("Seasonal", "S"))

        'Load Allocation Events 
        LoadAllocationEvents()

        'Load PO Type
        srchPOType.Items.Add(New ListItem("", ""))
        srchPOType.Items.Add(New ListItem("AST", "AST"))
        srchPOType.Items.Add(New ListItem("ASX", "ASX"))
        srchPOType.Items.Add(New ListItem("MAN", "MAN"))

        srchInitiator.Items.Add(New ListItem("", ""))
        srchInitiator.Items.Add(New ListItem("CAA/CMA", "CAA/CMA"))
        srchInitiator.Items.Add(New ListItem("DBC/QA", "DBC/QA"))
        srchInitiator.Items.Add(New ListItem("Merch. Analyst", "Merch. Analyst"))
        srchInitiator.Items.Add(New ListItem("New Store Group", "New Store Group"))
        srchInitiator.Items.Add(New ListItem("Vendor/CAA", "Vendor/CAA"))
    End Sub

    Private Sub LoadAllocationEvents()

        'Removes All Previous Items
        srchAllocationEvent.Items.Clear()

        Dim SQLStr As String = "PO_Allocation_Event_Get_All"
        srchAllocationEvent.Items.Add(New ListItem("", 0))

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)

                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        srchAllocationEvent.Items.Add(New ListItem(DataHelper.SmartValuesDBNull(reader.Item("ALLOC_EVENT_ID")) & " - " & DataHelper.SmartValuesDBNull(reader.Item("ALLOC_DESC")), reader.Item("ID")))

                    End While

                    reader.Close()

                End Using

            Catch ex As Exception

                NovaLibra.Common.Logger.LogError(ex)
                Throw ex

            Finally

                If Not conn Is Nothing AndAlso conn.State = ConnectionState.Open Then
                    conn.Close()
                End If

            End Try

        End Using

    End Sub


    Public Sub PopulateActionDD(ByVal ddaction As DropDownList, ByVal poID As Long, ByVal poConstructID As Integer, ByVal createdBy As Long, ByVal stageTypeID As Integer, ByVal stageId As Integer, ByVal stageEnabled As Boolean)

        If Data.POCreationData.ValidateUserForPO(poID, Session(cUSERID)) Then
            'Set Actions in Dropdown based on User, Groups, and Current Stage/Stage Type
            If stageTypeID <> Models.WorkflowStageType.Completed AndAlso stageTypeID <> Models.WorkflowStageType.WaitingForPONumber AndAlso stageEnabled Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))
                ddaction.Items.Add(New ListItem("Approve", "1"))

                'RULE: DO NOT Display Disapprove option if in Initial stage
                If stageTypeID <> Models.WorkflowStageType.Initial Then
                    ddaction.Items.Add(New ListItem("Disapprove", "2"))
                End If

                If (createdBy = Session(cUSERID) OrElse IsAdminDBCQA() OrElse stageTypeID = Models.WorkflowStageType.Initial) Then
                    ddaction.Items.Add(New ListItem("Remove", "3"))
                End If
            End If

            'RULE: If PO is waiting for PONumber, and the user is an Admin/DBC/QA, let them resubmit PO (this handles problems with original submission)
            If stageTypeID = Models.WorkflowStageType.WaitingForPONumber AndAlso stageEnabled AndAlso IsAdminDBCQA() Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))
                ddaction.Items.Add(New ListItem("Resubmit", "5"))
            End If
        End If

        'If the current stage is disabled (PO is DELETED), check to see if the user can restore it
        If Not stageEnabled Then
            If Data.POCreationData.ValidateUserForPORestore(poID, Session(cUSERID)) Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))
                ddaction.Items.Add(New ListItem("Restore", "4"))
            End If
        End If

    End Sub

    Private Sub PopulateFindShows()

        Dim wfStages As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.WorkflowStage) = GetSPEDyStages(WorkflowType.NewPO)

        ddFindshowNew.DataSource = wfStages
        ddFindshowNew.DataTextField = "StageName"
        ddFindshowNew.DataValueField = "ID"
        ddFindshowNew.DataBind()
        ddFindshowNew.Items.Insert(0, New ListItem("My Items", "0"))
        ddFindshowNew.Items.Insert(1, New ListItem("All Stages", "-1")) ' special case!

        'Default the first Index as the Selected Index
        If Session(cPOBATCHSHOWSTAGE) Is Nothing Then
            ddFindshowNew.SelectedIndex = 0
        Else
            If Not ddFindshowNew.Items.FindByValue(Session(cPOBATCHSHOWSTAGE)) Is Nothing Then
                ddFindshowNew.SelectedValue = Session(cPOBATCHSHOWSTAGE)
            Else
                ddFindshowNew.SelectedIndex = 0
            End If
        End If
        Session(cPOBATCHSHOWSTAGE) = Me.ddFindshowNew.SelectedValue

    End Sub

    Private Sub SetSearchControlValuesForSession()

        'Load Values From Session
        If Session(cPOCREATIONSEARCHFILTER) IsNot Nothing Then

            srchBatchNumber.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchBatchNumber"), "CStr", "")
            srchVendor.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchVendor"), "CStr", "")
            srchDept.SelectedValue = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchDept"), "CStr", "")
            srchPODept.SelectedValue = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchPODept"), "CStr", "")
            srchStockCat.SelectedValue = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchStockCat"), "CStr", "")
            srchWrittenStartDate.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchWrittenStartDate"), "CStr", "")
            srchWrittenEndDate.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchWrittenEndDate"), "CStr", "")
            srchLocation.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchLocation"), "CStr", "")
            srchAllocationEvent.SelectedValue = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchAllocationEvent"), "CStr", "")
            srchSKU.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchSKU"), "CStr", "")
            srchVPN.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchVPN"), "CStr", "")
            srchUPC.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchUPC"), "CStr", "")
            srchBasicSeasonal.Text = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchBasicSeasonal"), "CStr", "")
            srchPOType.SelectedValue = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchPOType"), "CStr", "")
            srchInitiator.SelectedValue = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchInitiator"), "CStr", "")

        End If

    End Sub

    Private Sub SetSessionValuesFromSearchControls()

        'Clear Current Values
        ClearSessionValuesForSearchControls()

        'Batch Number
        If srchBatchNumber.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchBatchNumber") = srchBatchNumber.Text.Trim
        End If

        'Vendor
        If srchVendor.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchVendor") = srchVendor.Text.Trim
        End If

        'Workflow Department
        If srchDept.SelectedValue.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchDept") = srchDept.SelectedValue
        End If

        'PO Department
        If srchPODept.SelectedValue.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchPODept") = srchPODept.SelectedValue
        End If

        'Stock Category
        If srchStockCat.SelectedValue.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchStockCat") = srchStockCat.SelectedValue
        End If

        'SKU
        If srchSKU.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchSKU") = srchSKU.Text.Trim
        End If

        'VPN
        If srchVPN.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchVPN") = srchVPN.Text.Trim
        End If

        Dim UPC As String = srchUPC.Text.Trim
        If UPC.Length > 1 AndAlso UPC.Length < 14 Then
            UPC = UPC.Trim.PadLeft(14, "0")
        End If

        'UPC
        If UPC.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchUPC") = srchUPC.Text.Trim
        End If

        'Written Date Start Date
        If srchWrittenStartDate.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchWrittenStartDate") = srchWrittenStartDate.Text.Trim
        End If

        'Written Date End Date
        If srchWrittenEndDate.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchWrittenEndDate") = srchWrittenEndDate.Text.Trim
        End If

        'Location
        If srchLocation.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchLocation") = srchLocation.Text.Trim
        End If

        'Allocation Event
        If srchAllocationEvent.SelectedValue.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchAllocationEvent") = srchAllocationEvent.SelectedValue
        End If

        'Basic/Seasonal
        If srchBasicSeasonal.Text.Trim.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchBasicSeasonal") = srchBasicSeasonal.Text.Trim
        End If

        'PO Type
        If srchPOType.SelectedValue.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchPOType") = srchPOType.SelectedValue
        End If

        'Initiator Role
        If srchInitiator.SelectedValue.Length > 0 Then
            Session(cPOCREATIONSEARCHFILTER & "_srchInitiator") = srchInitiator.SelectedValue
        End If

    End Sub

    Private Sub ClearSessionValuesForSearchControls()

        Session.Contents.Remove(cPOCREATIONSEARCHFILTER)
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchBatchNumber")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchVendor")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchDept")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchPODept")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchStockCat")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchWrittenStartDate")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchWrittenEndDate")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchLocation")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchAllocationEvent")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchSKU")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchVPN")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchUPC")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchBasicSeasonal")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchPOType")
        Session.Contents.Remove(cPOCREATIONSEARCHFILTER & "_srchInitiator")
    End Sub

    Private Sub PopulateGridView()

        Dim cmd As SqlCommand
        Dim dt As DataTable

        Try
            Dim sql As String = "PO_Creation_Search"
            Dim dbUtil As New DBUtil(ConnectionString)

            cmd = New SqlCommand()

            Dim xml As New PaginationXML()

            '************************
            'Add Search Filters
            '************************

            If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER), "CStr", "").Trim.Length = 0 AndAlso hidFilterApplied.Value = "1" Then

                'Batch Number
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchBatchNumber"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(51, Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchBatchNumber"), "CStr", ""))
                End If

                'Vendor
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchVendor"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(52, Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchVendor"), "CLng", 0))
                End If

                'Department
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchDept"), "CInt", 0) > 0 Then
                    xml.AddFilterCriteria(53, Session(cPOCREATIONSEARCHFILTER & "_srchDept"))
                End If

                'Stock Category
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchStockCat"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(54, Session(cPOCREATIONSEARCHFILTER & "_srchStockCat"))
                End If

                'SKU
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchSKU"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(56, Session(cPOCREATIONSEARCHFILTER & "_srchSKU"))
                End If

                'VPN
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchVPN"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(57, Session(cPOCREATIONSEARCHFILTER & "_srchVPN"))
                End If

                Dim UPC As String = Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchUPC"), "CStr", "")
                If UPC.Length > 1 AndAlso UPC.Length < 14 Then
                    UPC = UPC.Trim.PadLeft(14, "0")
                End If

                'UPC
                If UPC.Length > 0 Then
                    xml.AddFilterCriteria(58, Session(cPOCREATIONSEARCHFILTER & "_srchUPC"))
                End If

                'Written Date Start Date
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchWrittenStartDate"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(59, Session(cPOCREATIONSEARCHFILTER & "_srchWrittenStartDate"))
                End If

                'Written Date End Date
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchWrittenEndDate"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(60, Session(cPOCREATIONSEARCHFILTER & "_srchWrittenEndDate"))
                End If

                'Location
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchLocation"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(61, Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchLocation"), "CLng", 0))
                End If

                'Allocation Event
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchAllocationEvent"), "CLng", 0) > 0 Then
                    xml.AddFilterCriteria(62, Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchAllocationEvent"), "CLng", 0))
                End If

                'Basic/Seasonal
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchBasicSeasonal"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(63, Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchBasicSeasonal"), "CStr", ""))
                End If

                'PO Department
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchPODept"), "CInt", 0) > 0 Then
                    xml.AddFilterCriteria(53, Session(cPOCREATIONSEARCHFILTER & "_srchPODept"))
                End If

                'PO Type
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchPOType"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(65, Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchPOType"), "CStr", ""))
                End If

                'Initiator
                If Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchInitiator"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(66, Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER & "_srchInitiator"), "CStr", ""))
                End If

                'Save Filter In Session
                Session(cPOCREATIONSEARCHFILTER) = xml.GetFilterInnerXMLStr()

            ElseIf Helper.SmartValue(Session(cPOCREATIONSEARCHFILTER), "CStr", "").Trim.Length > 0 Then

                xml.SetFilterInnerXMLStr(Session(cPOCREATIONSEARCHFILTER))

            End If

            'Add Workflow Status Filters
            If Not Session(cPOBATCHSHOWSTAGE) Is Nothing Then
                Select Case (Session(cPOBATCHSHOWSTAGE))
                    Case "-3"
                        xml.AddFilterCriteria(5, "")
                    Case "-1"
                        'Return ALL Stages
                        xml.AddFilterCriteria(-1, "")
                    Case "0"
                        'Set UserID to pull back All "My Items" - (Defined as Items created by me, or in a Workflow Stage that I can approve)
                        xml.AddFilterCriteria(4, Session(cUSERID).ToString())
                    Case Else
                        'Return Stages that match the selected Workflow Stage
                        xml.AddFilterCriteria(3, Session(cPOBATCHSHOWSTAGE).ToString())
                End Select
            End If

            'Add Sorting
            xml.AddSortCriteria(Session(cPOBATCHCURSORTCOL), Session(cPOBATCHCURSORTDIR))

            cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.VarChar).Value = xml.GetPaginationXML().Replace("'", "''")
            cmd.Parameters.Add("@maxRows", SqlDbType.Int).Value = Helper.SmartValue(Session(cPOBATCHPERPAGE), "CInt", -1)
            cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = Helper.SmartValue(Session(cPOBATCHSTARTROW), "CInt", 1)

            cmd.CommandText = sql
            cmd.CommandTimeout = 1800
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Connection = dbUtil.GetSqlConnection()

            dt = dbUtil.GetDataTable(cmd)

            'Update Paging
            If dt.Rows.Count > 0 Then
                Session(cPOBATCHTOTALROWS) = Helper.SmartValue(dt.Rows(0)("totRecords"), "CStr", 0)
                Session(cPOBATCHSTARTROW) = Helper.SmartValue(dt.Rows(0)("RowNumber"), "CStr", 0)
            Else
                Session(cPOBATCHTOTALROWS) = 0
            End If

            UpdatePagingInformation()

            gvNewBatches.PageSize = Session(cPOBATCHPERPAGE)
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

    Private Sub btnDDFFindNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnDDFFindNew.Click
        Session(cPOBATCHSHOWSTAGE) = Me.ddFindshowNew.SelectedValue
        Session.Remove(cPOCREATIONSEARCHFILTER)
        PopulateGridView()
    End Sub

    Private Sub DDFindshowNew_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddFindshowNew.SelectedIndexChanged
        Session(cPOBATCHSHOWSTAGE) = Me.ddFindshowNew.SelectedValue
        Session.Remove(cPOCREATIONSEARCHFILTER)
        PopulateGridView()
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
            AddSortGlyph(gvNewBatches, e.Row, Session(cPOBATCHCURSORTCOL), PagingFiltering.GetSortDirectionString(Session(cPOBATCHCURSORTDIR)))
        End If
    End Sub

    Protected Sub gvNewBatches_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvNewBatches.RowCommand

        Select Case e.CommandName

            Case "Action"
                'Get the row this action occurred in
                Dim row As GridViewRow = gvNewBatches.Rows(e.CommandArgument)
                Dim gvStageID As Integer = DataHelper.SmartValue(CType(row.FindControl("StageID"), HiddenField).Value, "CInt", 0)
                'Get the Action that occurred
                Dim ddActions As DropDownList = row.FindControl("DDAction")
                If ddActions.SelectedIndex > 0 Then
                    Dim actionValue As Integer = CInt(ddActions.SelectedValue)
                    Dim poID As Long = gvNewBatches.DataKeys(e.CommandArgument).Value

                    'Verify the GridView is synced with Database.  Do not process if it is different
                    Dim poRec As Models.POCreationRecord = Data.POCreationData.GetRecord(poID)
                    If (gvStageID = poRec.WorkflowStageID) Then
                        ProcessAction(poRec, actionValue)
                    Else
                        'Refresh Grid to make it in synch
                        PopulateGridView()
                    End If
                End If

            Case "Sort"

                    'Same Column (Change Direction)
                    If Session(cPOBATCHCURSORTCOL).ToString() = e.CommandArgument.ToString() Then

                        If Session(cPOBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc Then
                            Session(cPOBATCHCURSORTDIR) = PagingFiltering.SortDirection.Desc
                        Else
                            Session(cPOBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc
                        End If

                    Else
                        Session(cPOBATCHCURSORTCOL) = e.CommandArgument.ToString()
                        Session(cPOBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc
                    End If

                    'Go To First Item
                    Session(cPOBATCHCURPAGE) = 1
                    Session(cPOBATCHSTARTROW) = 1

                    PopulateGridView()

            Case "Page"

                    Select Case e.CommandArgument
                        Case "First"
                            Session(cPOBATCHCURPAGE) = 1
                            Session(cPOBATCHSTARTROW) = 1
                        Case "Prev"
                            If Session(cPOBATCHCURPAGE) > 1 Then
                                Session(cPOBATCHCURPAGE) -= 1
                                Session(cPOBATCHSTARTROW) = Session(cPOBATCHSTARTROW) - Session(cPOBATCHPERPAGE)
                            End If
                        Case "Next"
                            If Session(cPOBATCHCURPAGE) < Session(cPOBATCHTOTALPAGES) Then
                                Session(cPOBATCHCURPAGE) += 1
                                Session(cPOBATCHSTARTROW) = Session(cPOBATCHSTARTROW) + Session(cPOBATCHPERPAGE)
                            End If
                        Case "Last"
                            Session(cPOBATCHCURPAGE) = Session(cPOBATCHTOTALPAGES)
                            Session(cPOBATCHSTARTROW) = ((Session(cPOBATCHTOTALPAGES) - 1) * Session(cPOBATCHPERPAGE)) + 1
                    End Select

                    PopulateGridView()

            Case "PageGo"

                    Dim newPageNum As Integer = GoToPage()

                    If newPageNum > 0 AndAlso newPageNum <= Session(cPOBATCHTOTALPAGES) Then

                        Session(cPOBATCHCURPAGE) = newPageNum
                        Session(cPOBATCHSTARTROW) = ((Session(cPOBATCHCURPAGE) - 1) * Session(cPOBATCHPERPAGE)) + 1

                        PopulateGridView()
                    Else
                        ShowMsg("Invalid Page Number entered.")
                    End If

            Case "PageReset"

                    Dim newBatchesPerPage As Integer = BatchesPerPage()

                    If newBatchesPerPage >= 5 AndAlso newBatchesPerPage <= 50 Then

                        Session(cPOBATCHCURPAGE) = 1
                        Session(cPOBATCHSTARTROW) = 1
                        Session(cPOBATCHPERPAGE) = newBatchesPerPage

                        PopulateGridView()
                    Else
                        ShowMsg("Batches / Page must be between 5 and 50")
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

                Dim poID As Long = Helper.SmartValue(objNewItemRec.Item("ID"), "CLng", 0)
                Dim poConstructID As Integer = Helper.SmartValue(objNewItemRec.Item("PO_Construct_ID"), "CInt", 0)
                Dim createdByUserID As Integer = Helper.SmartValue(objNewItemRec.Item("Created_User_ID"), "CInt", 0)
                Dim stageID As Integer = Helper.SmartValue(objNewItemRec.Item("Workflow_Stage_ID"), "CInt", 0)
                Dim stageTypeID As Integer = Helper.SmartValue(objNewItemRec.Item("Stage_Type_ID"), "CInt", 0)
                Dim isEnabled As Boolean = Helper.SmartValue(objNewItemRec.Item("Enabled"), "Boolean", False)

                PopulateActionDD(ctrlDD, poID, poConstructID, createdByUserID, stageTypeID, stageID, isEnabled)

                If ctrlDD.Items.Count = 0 Then
                    ctrlBtn.Visible = False
                    ctrlDD.Visible = False
                End If
                ctrlBtn.CommandArgument = e.Row.RowIndex.ToString()
                ctrlBtn.Attributes.Add("OnClick", "return RemoveDisappr_ActionButtonClick(" & (e.Row.RowIndex + 1).ToString & ");")

            Case DataControlRowType.Pager

                Dim ctrlPaging As Object

                ctrlPaging = e.Row.FindControl("PagingInformation")
                ctrlPaging.text = String.Format("Page {0} of {1}", Session(cPOBATCHCURPAGE), Session(cPOBATCHTOTALPAGES))

                ctrlPaging = e.Row.FindControl("lblBatchesFound")
                ctrlPaging.text = Session(cPOBATCHTOTALROWS).ToString() & " " & ctrlPaging.text

                ctrlPaging = e.Row.FindControl("txtgotopage")
                If Helper.SmartValue(Session(cPOBATCHCURPAGE), "CInt", 0) < Helper.SmartValue(Session(cPOBATCHTOTALPAGES), "CInt", 0) Then
                    ctrlPaging.text = Helper.SmartValue(Session(cPOBATCHCURPAGE), "CInt", 0) + 1
                Else
                    ctrlPaging.text = "1"
                End If

                ctrlPaging = e.Row.FindControl("txtBatchPerPage")
                ctrlPaging.text = Helper.SmartValue(Session(cPOBATCHPERPAGE), "CInt")

        End Select

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

        If Value IsNot Nothing AndAlso Value IsNot DBNull.Value Then
            If Helper.SmartValue(Value, "CBool", False) = True Then
                returnValue = "images/Valid_yes.gif"
            Else
                returnValue = "images/Valid_no.gif"
            End If
        Else
			returnValue = "images/Valid_null.gif"
        End If

        Return returnValue

    End Function

    Protected Function GetBatchTypeName(ByVal Abbrev As Object) As String

        Dim returnValue As String = ""

        If Abbrev IsNot Nothing AndAlso Abbrev IsNot DBNull.Value Then

            Select Case UCase(Abbrev)
                Case "W"
                    returnValue = "Warehouse"
                Case "D"
                    returnValue = "Direct"
            End Select

        End If

        Return returnValue

    End Function

    Protected Function GetPOTypeName(ByVal Abbrev As Object) As String

        Dim returnValue As String = ""

        Select Case UCase(DataHelper.SmartValue(Abbrev, "CStr", ""))
            Case "B"
                returnValue = "Basic"
            Case "S"
                returnValue = "Seasonal"
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

    Private Sub UpdatePagingInformation()

        'Set Defaults
        If Session(cPOBATCHPERPAGE) Is Nothing Then Session(cPOBATCHPERPAGE) = BATCH_PAGE_SIZE
        If Session(cPOBATCHCURPAGE) Is Nothing Then Session(cPOBATCHCURPAGE) = 1
        If Session(cPOBATCHTOTALPAGES) Is Nothing Then Session(cPOBATCHTOTALPAGES) = 0
        If Session(cPOBATCHSTARTROW) Is Nothing Then Session(cPOBATCHSTARTROW) = 1
        If Session(cPOBATCHTOTALROWS) Is Nothing Then Session(cPOBATCHTOTALROWS) = 0

        If Helper.SmartValue(Session(cPOBATCHTOTALROWS), "CInt", 0) > 0 Then

            If Helper.SmartValue(Session(cPOBATCHSTARTROW), "CInt", 0) > Helper.SmartValue(Session(cPOBATCHTOTALROWS), "CInt", 0) Then
                Session(cPOBATCHSTARTROW) = 1
            End If

            Session(cPOBATCHTOTALPAGES) = Fix(Helper.SmartValue(Session(cPOBATCHTOTALROWS), "CInt", 0) / Helper.SmartValue(Session(cPOBATCHPERPAGE), "CInt", 0))
            If (Helper.SmartValue(Session(cPOBATCHTOTALROWS), "CInt", 0) Mod Helper.SmartValue(Session(cPOBATCHPERPAGE), "CInt", 0)) <> 0 Then
                Session(cPOBATCHTOTALPAGES) = Helper.SmartValue(Session(cPOBATCHTOTALPAGES), "CInt", 0) + 1
            End If

            If Helper.SmartValue(Session(cPOBATCHCURPAGE), "CInt", 0) <= 0 OrElse Helper.SmartValue(Session(cPOBATCHCURPAGE), "CInt", 0) > Helper.SmartValue(Session(cPOBATCHTOTALPAGES), "CInt", 0) Then
                Session(cPOBATCHCURPAGE) = 1
            End If

        Else
            Session(cPOBATCHCURPAGE) = 1
            Session(cPOBATCHTOTALPAGES) = 0
            Session(cPOBATCHSTARTROW) = 1
        End If

    End Sub

    Private Sub UpdateSortingInformation()

        'Set Defaults
        If Session(cPOBATCHCURSORTCOL) Is Nothing Then Session(cPOBATCHCURSORTCOL) = 0
        If Session(cPOBATCHCURSORTDIR) Is Nothing Then Session(cPOBATCHCURSORTDIR) = PagingFiltering.SortDirection.Asc

    End Sub

    Private Sub ApproveRecord(ByVal poRecord As Models.POCreationRecord)
        Dim connection As New SqlConnection(ConnectionString)
        Dim command As SqlCommand = New SqlCommand
        Dim nextWFStageID As Integer
        Dim exceptionList As New ArrayList

        Try
            command.Connection = connection
            command.CommandType = CommandType.StoredProcedure
            command.CommandText = "sp_SPD2_Approval_GetStageInfo"

            command.Parameters.Add("@WorkflowStageId", SqlDbType.Int).Value = poRecord.WorkflowStageID

            command.CommandTimeout = 600

            command.Connection.Open()
            Dim reader As SqlDataReader = command.ExecuteReader()
            While reader.Read
                nextWFStageID = reader("Default_NextStage_ID")
            End While

            'Capture the Exception list from the second datatable in the query
            reader.NextResult()
            While reader.Read
                exceptionList.Add(New Models.WorkflowException(reader("Exception_ID"), reader("Exception_Order"), reader("Target_Stage_ID"), reader("Condition_id"), reader("Condition_Order"), IIf(IsDBNull(reader("Conjunction")), "", reader("Conjunction").ToString)))
            End While
            reader.Close()
            command.Connection.Close()
        Catch ex As Exception
            ProcessError(ex, "ApproveRecord")
            If command.Connection.State = ConnectionState.Open Then command.Connection.Close()
        Finally
            command.Dispose()
            connection.Dispose()
            command = Nothing
            connection = Nothing
        End Try

		Try

			'If there are Exceptions, then process them to see if the Workflow meets the Exception Conditions for a different Workflow Stage
			If exceptionList.Count > 0 Then

				exceptionList.Add(New Models.WorkflowException(0, 0, 0, 0, 0, "")) 'HACK: Add empty row for proper processing of the exception list
				Dim firstone As Boolean = True			'Indicates the first row of an Exception, which keeps track of the need to use the Condition's Conjunction verb
				Dim currentExcId As Integer = 0			'ID of current Exception
				Dim isExceptionCondsMet As Boolean = False 'Indicates all Conditions for a given Exception are met
				Dim isConditionMet As Boolean = False	'Indicates current Condition is met
				Dim vendorRecord As Models.VendorRecord = (New Data.VendorData).GetVendorRecord(poRecord.VendorNumber)	'Vendor data which will be used during Evaluation process

				For i As Integer = 0 To exceptionList.Count - 1

					'If the Exception IDs do not match, this is a new Exception.  Befor processing it, check the ExceptionMet.
					If currentExcId <> CType(exceptionList.Item(i), Models.WorkflowException).ExcpetionID Then

						'If all the Exception's Conditions are Met, end processing and use the previous index's TargetStageID 
						If isExceptionCondsMet Then
							nextWFStageID = CType(exceptionList.Item(i - 1), Models.WorkflowException).TargetStageID
							Exit For
						End If

						'Prior Exception was not valid, so move on to the next Exception
						currentExcId = CType(exceptionList.Item(i), Models.WorkflowException).ExcpetionID
						firstone = True
					End If

					'Check the Condition for this Exception
					Select Case CType(exceptionList.Item(i), Models.WorkflowException).ConditionID
						Case INITIATORROLES
							'Initiator Dependent
                            isConditionMet = EvaluateInitiators(CType(exceptionList.Item(i), Models.WorkflowException), DataHelper.SmartValue(poRecord.InitiatorRoleID, "CInt", 0))
						Case AMOUNTGRT
							'AMOUNT Greater than Threshold
							isConditionMet = EvaluateThreshold(CType(exceptionList.Item(i), Models.WorkflowException), poRecord.ID, ">")
						Case AMOUNTLT
							'AMOUNT Less than Threshold
							isConditionMet = EvaluateThreshold(CType(exceptionList.Item(i), Models.WorkflowException), poRecord.ID, "<")
						Case BATCHDIRECT
							'Direct Order
							isConditionMet = IIf(poRecord.BatchType = "D", True, False)
						Case BATCHWAREHOUSE
							'WareHouse Order
							isConditionMet = IIf(poRecord.BatchType = "W", True, False)
						Case BASICORDER
							'Basic (SBA) Order
							isConditionMet = IIf(poRecord.BasicSeasonal = "B", True, False)
						Case SEASONALORDER
							'Seasonal Order
							isConditionMet = IIf(poRecord.BasicSeasonal = "S", True, False)
						Case CONTAINSWAREHOUSEITEM
							'At least one item is a warehouse item
							isConditionMet = EvaluateItemsForWarehouse(poRecord.ID)
						Case ALLDIRECTITEMS
							'All Items are Direct items
							isConditionMet = Not EvaluateItemsForWarehouse(poRecord.ID)
						Case PAYMENTTERMSMATCH
							isConditionMet = EvaluatePaymentTermMatch(DataHelper.SmartValue(poRecord.PaymentTermsID, "CInt", 0), vendorRecord.PaymentTerms)
						Case PAYMENTTERMSLOC
							isConditionMet = EvaluatePaymentTermIsLOC(DataHelper.SmartValue(poRecord.PaymentTermsID, "CInt", 0))
						Case PAYMENTTERMSNOTLOC
							isConditionMet = Not EvaluatePaymentTermIsLOC(DataHelper.SmartValue(poRecord.PaymentTermsID, "CInt", 0))
						Case VENDORTYPEDOMESTIC
							isConditionMet = (vendorRecord.VendorType = ValidationHelper.VALIDATION_VENDOR_DOMESTIC_TYPES)
						Case VENDORTYPEIMPORT
							isConditionMet = (vendorRecord.VendorType = ValidationHelper.VALIDATION_VENDOR_IMPORT_TYPES)
						Case SHIPWINDOWDAYS
							isConditionMet = EvaluateShipWindow(CType(exceptionList.Item(i), Models.WorkflowException), poRecord.ID)
						Case PACKMISMATCH
							isConditionMet = EvaluatePackMismatch(poRecord.ID)
						Case POSPECIALTEST
                            isConditionMet = IIf(DataHelper.SmartValue(poRecord.POSpecialID, "CInt", 0) = POSPECIAL_TEST, True, False)
                        Case ISALLOCDIRTY
                            isConditionMet = DataHelper.SmartValue(poRecord.IsAllocDirty, "CBool", False)
                        Case ISPLANNERDISRTY
                            isConditionMet = DataHelper.SmartValue(poRecord.IsPlannerDirty, "CBool", False)
                        Case ISDATEWARNING
                            isConditionMet = DataHelper.SmartValue(poRecord.IsDateWarning, "CBool", False)
                        Case POTYPEAST
                            isConditionMet = (poRecord.POConstructID = Models.POCreationRecord.Construct.AST)
                        Case POTYPEMAN
                            isConditionMet = (poRecord.POConstructID = Models.POCreationRecord.Construct.Manual)
                        Case RSETEVENT
                            isConditionMet = Data.ValidationData.LookupAllocationCode(DataHelper.SmartValue(poRecord.POAllocationEventID, "CInt", 0)).StartsWith("RSET")
                        Case NONRSETEVENT
                            isConditionMet = Not Data.ValidationData.LookupAllocationCode(DataHelper.SmartValue(poRecord.POAllocationEventID, "CInt", 0)).StartsWith("RSET")
                        Case Else
                            isConditionMet = False
                    End Select

					'If this is the first row of an Exception, set the ExceptionMet equal to the ConditionMet
					If firstone Then
						isExceptionCondsMet = isConditionMet
						firstone = False
					Else
						'If this is not the first row, set the ExceptionMet based on the ConditionMet and the prior rows ConditionConjunction
						If UCase(CType(exceptionList.Item(i - 1), Models.WorkflowException).ConditionConjunction) = "AND" Then
							isExceptionCondsMet = isExceptionCondsMet And isConditionMet
						Else
							isExceptionCondsMet = isExceptionCondsMet And isConditionMet
						End If
					End If
				Next

			End If

            'RULE: Only valid POs can be approved to Waiting for PO stagetype
            Dim isValid As Boolean = (Helper.SmartValue(poRecord.IsHeaderValid, "Boolean", False) And Helper.SmartValue(poRecord.IsDetailValid, "Boolean", False))
            If GetStageType(nextWFStageID) = Models.WorkflowStageType.WaitingForPONumber And Not isValid Then
                ShowMsg("This Purchase Order has Validation errors. Please correct before approving.")
            Else

                'Save Workflow
                ProcessWorkflowTransaction(poRecord, nextWFStageID, "APPROVE", "")
                hdnNotes.Value = String.Empty

                'Set valid flag to null in order to force user to re-validate the PO
                Dim stageTypeID As Models.WorkflowStageType = GetStageType(nextWFStageID)
                If (stageTypeID <> Models.WorkflowStageType.WaitingForPONumber) Then
                    InvalidatePORecord(poRecord, stageTypeID)
                End If

                'IF stage type is "waiting for PO", send rms message
                Dim procOK As Boolean = True
                If GetStageType(nextWFStageID) = Models.WorkflowStageType.WaitingForPONumber Then
                    procOK = Data.POCreationData.PublishPOMessage(poRecord.ID)
                End If

                'SEND Approval Email
                If procOK Then
                    Dim msgResult As String = MyBase.SendEmail(poRecord, nextWFStageID, "APPROVE", "")
                    If msgResult.Length > 0 Then
                        ShowMsg(msgResult)
                    End If
                End If
            End If
        Catch ex As Exception
            ProcessError(ex, "ApproveRecord")
        End Try

	End Sub

    Private Sub DisApproveRecord(ByVal disapprovalStageID As Integer, ByVal disapprovalNotes As String, ByVal poRecord As Models.POCreationRecord)

        ' Verify that the Stage to send the batch to is specified.  If not then get the default for the current Stage
        If disapprovalStageID <= 0 Then
            Dim initialStage As Integer = Data.POCreationData.GetInitialWorkflowStageID(poRecord.InitiatorRoleID)
            If (initialStage > 0) Then
                disapprovalStageID = initialStage
            End If
        End If

        'If the Disapproval Stage still does not have a value, Show Error Message
        If disapprovalStageID <= 0 Then
            ShowMsg("Can not determine Stage to send Batch to. Contact Support")
        Else
            'Save the PO Rejection
			ProcessWorkflowTransaction(poRecord, disapprovalStageID, "DISAPPROVE", disapprovalNotes)

            Dim stageTypeID As Models.WorkflowStageType = GetStageType(disapprovalStageID)
            If (stageTypeID <> Models.WorkflowStageType.WaitingForPONumber) Then
                InvalidatePORecord(poRecord, stageTypeID)
            End If

			'SEND Disapproval Email
            Dim msgResult As String = MyBase.SendEmail(poRecord, disapprovalStageID, "DISAPPROVE", disapprovalNotes)
			If msgResult.Length > 0 Then
				ShowMsg(msgResult)
			End If
		End If
        
    End Sub

    Private Function EvaluateInitiators(ByVal wfException As Models.WorkflowException, ByVal initiatorRoleID As Integer) As Boolean
        'Get The List of Initiator Roles for this Exception / Condition pair
        Dim initList As New ArrayList
        Dim connection As New SqlConnection(ConnectionString)
        Dim command As New SqlCommand
        Try
            command.Connection = connection
            command.CommandType = CommandType.StoredProcedure
            command.CommandText = "sp_SPD2_Workflow_SelectExcInitList"

            command.Parameters.Add("@Exception_ID", SqlDbType.BigInt).Value = wfException.ExcpetionID
            command.Parameters.Add("@Condition_Order", SqlDbType.Int).Value = wfException.ConditionOrder

            command.CommandTimeout = 600

            command.Connection.Open()

            Dim reader As SqlDataReader = command.ExecuteReader
            While reader.Read
                initList.Add(reader("Group_ID").ToString)
            End While

            reader.Close()

        Catch ex As Exception
            Throw ex
        Finally
            If Not command.Connection Is Nothing Then command.Connection.Close()
        End Try

        If initList.Contains(initiatorRoleID.ToString) Then
            Return True
        Else
            Return False
        End If

    End Function

	Private Function EvaluateItemsForWarehouse(ByVal poID As Long) As Boolean
		'Retrieve all the SKUs attached to the given PO, and look at their Stock_Category.  If the Category is ever "W" then return TRUE
		Dim isWarehouse As Boolean = False
		Dim connection As New SqlConnection(ConnectionString)
		Dim command As New SqlCommand
		Try
			command.Connection = connection
			command.CommandType = CommandType.StoredProcedure
			command.CommandText = "PO_Creation_Location_SKU_Details_By_PO_ID"

            command.Parameters.Add("@PO_ID", SqlDbType.BigInt).Value = poID

            command.CommandTimeout = 600

			command.Connection.Open()

			Dim reader As SqlDataReader = command.ExecuteReader
			While reader.Read
				Dim stock_Category As String = reader("Stock_Category")
				If (stock_Category = "W") Then
					'WAREHOUSE Item Found, so return true
					isWarehouse = True
					Exit While
				End If
			End While

		Catch ex As Exception
			Throw ex
		Finally
			If Not command.Connection Is Nothing Then command.Connection.Close()
		End Try

		Return isWarehouse
	End Function

	Private Function EvaluatePackMismatch(ByVal poID As Long) As Boolean
		'Retrieve all the SKUs attached to the given PO, and look at their Stock_Category.  If the Category is ever "W" then return TRUE
		Dim isMismatch As Boolean = False

		Dim connection As New SqlConnection(ConnectionString)
		Dim command As New SqlCommand
		Try
			command.Connection = connection
			command.CommandType = CommandType.StoredProcedure
			command.CommandText = "PO_Creation_Location_SKU_Details_By_PO_ID"

			command.Parameters.Add("@PO_ID", SqlDbType.BigInt).Value = poID

            command.CommandTimeout = 600

            command.Connection.Open()

			Dim reader As SqlDataReader = command.ExecuteReader
			While reader.Read
                Dim skuInnerPack As Integer = DataHelper.SmartValue(reader("Inner_Pack"), "CInt", 0)
                Dim skuMasterPack As Integer = DataHelper.SmartValue(reader("Master_Pack"), "CInt", 0)
                Dim vendorInnerPack As Integer = DataHelper.SmartValue(reader("Eaches_Inner_Pack"), "CInt", 0)
                Dim vendorMasterCase As Integer = DataHelper.SmartValue(reader("Eaches_Master_Case"), "CInt", 0)
				If (skuInnerPack <> vendorInnerPack) Or (skuMasterPack <> vendorMasterCase) Then
					isMismatch = True
					Exit While
				End If
			End While

            reader.Close()

		Catch ex As Exception
			Throw ex
		Finally
			If Not command.Connection Is Nothing Then command.Connection.Close()
		End Try

		Return isMismatch
	End Function

	Private Function EvaluatePaymentTermIsLOC(ByVal poPaymentTermID As Integer) As Boolean

		Dim isPaymentTerm As Boolean = False
		Dim connection As New SqlConnection(ConnectionString)
		Dim command As New SqlCommand
		Try
			command.Connection = connection
			command.CommandType = CommandType.StoredProcedure
			command.CommandText = "PO_Payment_Terms_Is_LoC"

            command.Parameters.Add("@ID", SqlDbType.Int).Value = poPaymentTermID

            command.CommandTimeout = 600

			command.Connection.Open()

			Dim reader As SqlDataReader = command.ExecuteReader
			While reader.Read
				'IF a PaymentTerm was found, then it is a Letter of Credit Payment Term
				isPaymentTerm = (Helper.SmartValue(reader("Terms"), "String", "").ToString.Length > 0)
			End While

            reader.Close()

		Catch ex As Exception
			Throw ex
		Finally
			If Not command.Connection Is Nothing Then command.Connection.Close()
		End Try

		Return isPaymentTerm
	End Function

	Private Function EvaluatePaymentTermMatch(ByVal poPaymentTermID As Integer, ByVal vendorPaymentTerms As String) As Boolean
		Dim termsMatch As Boolean = False

		If (vendorPaymentTerms IsNot Nothing) Then
			Dim vendorPaymentTermID = Data.PaymentTermsData.GetByTerm(vendorPaymentTerms).ID
			If (poPaymentTermID = vendorPaymentTermID) Then
				termsMatch = True
			End If
		End If

		Return termsMatch
	End Function

	Public Function EvaluateShipWindow(ByVal wfException As Models.WorkflowException, ByVal poID As Long) As Boolean
		'Retrieve the configured Workflow Ship Window
		Dim shipWindow As Integer = 0
		Dim connection As New SqlConnection(ConnectionString)
		Dim command As New SqlCommand
		Try
			command.Connection = connection
			command.CommandType = CommandType.StoredProcedure
			command.CommandText = "sp_SPD2_Workflow_SelectExcShipWindow"

			command.Parameters.Add("@Exception_ID", SqlDbType.BigInt).Value = wfException.ExcpetionID
            command.Parameters.Add("@Condition_Order", SqlDbType.Int).Value = wfException.ConditionOrder

            command.CommandTimeout = 600

			command.Connection.Open()

			Dim reader As SqlDataReader = command.ExecuteReader
			While reader.Read
				shipWindow = Helper.SmartValue(reader("Ship_Window"), "Integer", 0)
			End While

            reader.Close()

		Catch ex As Exception
			Throw ex
		Finally
			If Not command.Connection Is Nothing Then command.Connection.Close()
		End Try

		Dim isAfterShipWindow As Boolean = True
		Dim poCreationDetailList As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsByPOID(poID)
		For Each creationDetail As Models.POCreationLocationRecord In poCreationDetailList
            If creationDetail.NotBefore.HasValue Then
                'RULE: Compare Written Date to Shipwindow for PO_Creation
                isAfterShipWindow = (isAfterShipWindow And (creationDetail.WrittenDate > CType(creationDetail.NotBefore, Date).AddDays(-shipWindow)))
            Else
                isAfterShipWindow = isAfterShipWindow And False
            End If
        Next

		Return isAfterShipWindow
	End Function

	Private Function EvaluateThreshold(ByVal wfException As Models.WorkflowException, ByVal poID As Long, ByVal lt_grt As String) As Boolean

		'Retrieve the configured Workflow Threshold
		Dim thresholdAmount As Integer = 0
		Dim connection As New SqlConnection(ConnectionString)
		Dim command As New SqlCommand
		Try
			command.Connection = connection
			command.CommandType = CommandType.StoredProcedure
			command.CommandText = "sp_SPD2_Workflow_SelectExcThreshold"

			command.Parameters.Add("@Exception_ID", SqlDbType.BigInt).Value = wfException.ExcpetionID
            command.Parameters.Add("@Condition_Order", SqlDbType.Int).Value = wfException.ConditionOrder

            command.CommandTimeout = 600

			command.Connection.Open()

			Dim reader As SqlDataReader = command.ExecuteReader
			While reader.Read
				thresholdAmount = Helper.SmartValue(reader("Threshold_Amount"), "Integer", 0)
			End While

            reader.Close()

		Catch ex As Exception
			Throw ex
		Finally
			If Not command.Connection Is Nothing Then command.Connection.Close()
		End Try

		'Retrieve the PO Order Total
        Dim dt As DataTable = Data.POCreationData.GetPurchaseOrderTotals(poID)

        Dim total As Decimal = 0.0
        Dim isOverThreshold As Boolean = False
        If (dt.Rows.Count > 0) Then
            For Each row As DataRow In dt.Rows
                'Get the order total for each location
                total = DataHelper.SmartValues(row(2), "CDec", False, 0)
                If (total > thresholdAmount) Then
                    isOverThreshold = True
                End If
            Next

            Select Case (lt_grt).ToString
                Case ">"
                    'Will be True if at least one row is > threshold
                    Return isOverThreshold
                Case "<"
                    'Will be True only if all rows are < threshold
                    Return Not isOverThreshold
            End Select
        Else
            'IF there are 0 rows returned as PO Total, then use the following
            If (lt_grt) = "<" Then
                isOverThreshold = True
            Else
                isOverThreshold = False
            End If
        End If

        Return isOverThreshold
    End Function

    Private Sub ProcessAction(ByVal poRec As Models.POCreationRecord, ByVal action As Integer)

        Select Case action
            Case 1 ' APPROVE
                Dim isValid As Boolean = (Helper.SmartValue(poRec.IsHeaderValid, "Boolean", False) And Helper.SmartValue(poRec.IsDetailValid, "Boolean", False))

                ' DBCQA / Sys Admins can approve batches even if they are invalid as long as its a normal stage type
                If Not isValid AndAlso Not IsAdminDBCQA() Then
                    ShowMsg("This Purchase Order has Validation errors. Please correct before approving.")
                    poRec = Nothing
                Else
                    ApproveRecord(poRec)
                End If

            Case 2 ' DisApprove
                Dim toStage As Integer = DataHelper.DBSmartValues(Me.hdnDisApproveStageID.Value, "integer", False)
                Dim disApproveNotes = Me.hdnNotes.Value
                DisApproveRecord(toStage, disApproveNotes, poRec)

            Case 3 'REMOVE
                poRec.Enabled = 0
                ProcessWorkflowTransaction(poRec, Data.POCreationData.GetDeletedWorkflowStageID(), "REMOVE", "")

            Case 4 ' UNDELETE (restore)
                poRec.Enabled = 1
                ProcessWorkflowTransaction(poRec, Data.POCreationData.GetInitialWorkflowStageID(poRec.InitiatorRoleID), "RESTORE", "")
            Case 5 'RESUBMIT
                'Save PO Workflow History
                Data.POCreationData.SaveWorkflowHistory(poRec, "RESUBMIT", Session(cUSERID), "")

                'Resubmit PO, and Send an email if Resubmit was successful
                Dim procOK As Boolean = Data.POCreationData.PublishPOMessage(poRec.ID)

                'SEND Approval Email
                If procOK Then
                    Dim msgResult As String = MyBase.SendEmail(poRec, poRec.WorkflowStageID, "APPROVE", "")
                    If msgResult.Length > 0 Then
                        ShowMsg(msgResult)
                    End If
                End If

            Case Else ' do nothing
        End Select

        ' Once the action is done, make sure the hdnnotes and DisApproval Stage ID fields are cleared out for the next record
        ' This is a global action because the hdnNotes can also be used for the Remove Action (which currently is not logged)
        Me.hdnNotes.Value = String.Empty
        Me.hdnDisApproveStageID.Value = String.Empty

        ' refresh the grid based on current settings
        PopulateGridView()
    End Sub

	Private Sub ProcessWorkflowTransaction(ByVal poRecord As Models.POCreationRecord, ByVal workflowStageID As Integer, ByVal action As String, ByVal notes As String)

		'Save PO Workflow History with OLD WorkflowStageID
		Data.POCreationData.SaveWorkflowHistory(poRecord, action, Session(cUSERID), notes)

        'Save record for PO Creation in History Stage Durations table
        Data.POCreationData.SaveHistoryStageDuration(poRecord.ID, action, poRecord.WorkflowStageID, workflowStageID, Session(cUSERID))

		'Set and Save PO Record with new WorkflowStageID
        poRecord.WorkflowStageID = workflowStageID
        If action = "REMOVE" Then poRecord.Enabled = False
        If action = "RESTORE" Then poRecord.Enabled = True
		'IF This is an approval, set the ApproverUserID on the PO Record
		If action = "APPROVE" Then poRecord.ApproverUserID = Session(cUSERID)

		'Update the Record in the database
		Data.POCreationData.SaveRecord(poRecord, Session(cUSERID), HydrateRecord:=NovaLibra.Coral.Data.Michaels.POCreationData.Hydrate.All)

	End Sub

	Private Sub ProcessError(ByVal ex As Exception, ByVal sourceName As String)
		Dim strmessage As String
		strmessage = "Unexpected SPEDY problem has occured in the routine: " & sourceName & " - "
		strmessage = strmessage & ex.Message & ". Please report this issue to the System Administrator."
		ShowMsg(strmessage)
	End Sub

    Private Sub InvalidatePORecord(ByVal poRecord As Models.POCreationRecord, ByVal stageType As Models.WorkflowStageType)

        poRecord.IsDetailValid = Nothing
        poRecord.IsHeaderValid = Nothing
        Data.POCreationData.UpdateRecordBySystem(poRecord, NovaLibra.Coral.Data.Michaels.POCreationData.Hydrate.All)

        'RULE: Only update WS Validation flags if StageType is "Pack Approval"
        If (stageType = Models.WorkflowStageType.PackApproval) Then
            Dim connection As New SqlConnection(ConnectionString)
            Dim command As New SqlCommand
            Try
                command.Connection = connection
                command.CommandType = CommandType.StoredProcedure
                command.CommandText = "PO_Creation_Location_SKU_Update_Is_WS_Valid"

                command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = poRecord.ID
                command.Parameters.Add("@Is_WS_Valid", SqlDbType.Bit).Value = Nothing

                command.CommandTimeout = 600

                command.Connection.Open()

                command.ExecuteNonQuery()
            Catch ex As Exception
                Throw ex
            Finally
                If Not command.Connection Is Nothing Then command.Connection.Close()
            End Try
        End If

    End Sub

	Private Sub ShowMsg(ByVal strMsg As String)
		Dim curMsg As String
		If strMsg.Length = 0 Then
			lblNewItemMessage.Text = "&nbsp;"	' populate with a space to maintain content on page (and get rid of horiz scroll bar ta boot)
		Else
			curMsg = lblNewItemMessage.Text
			If curMsg = "&nbsp;" Then			' Only set the message if there is not one in there already
				lblNewItemMessage.Text = strMsg
			Else
				lblNewItemMessage.Text += "<br />" & strMsg
			End If
		End If
	End Sub

    Public Function ValidSearchFilters() As Boolean

        Dim retValue As Boolean = True

        'Written Date Start Date
        If srchWrittenStartDate.Text.Trim.Length > 0 Then

            If Not IsDate(srchWrittenStartDate.Text) Then
                ValidationHelper.AddValidationSummaryErrorByText(SearchValidationSummary, "<span class='sevError'>Error:&nbsp;</span>Written Date start date is not a valid date")
                retValue = False
            End If

        End If

        'Written Date End Date
        If srchWrittenEndDate.Text.Trim.Length > 0 Then

            If Not IsDate(srchWrittenStartDate.Text) Then
                ValidationHelper.AddValidationSummaryErrorByText(SearchValidationSummary, "<span class='sevError'>Error:&nbsp;</span>Written Date end date is not a valid date")
                retValue = False
            ElseIf srchWrittenStartDate.Text.Trim.Length > 0 AndAlso IsDate(srchWrittenStartDate.Text.Trim) AndAlso Helper.SmartValue(srchWrittenEndDate.Text.Trim, "CDate") < Helper.SmartValue(srchWrittenStartDate.Text.Trim, "CDate") Then
                ValidationHelper.AddValidationSummaryErrorByText(SearchValidationSummary, "<span class='sevError'>Error:&nbsp;</span>Written Date end date must be greater than or equal to the start date")
                retValue = False
            End If

        End If

        Return retValue

    End Function

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click

        If ValidSearchFilters() Then

            'Remove Any Previous Filters
            ClearSessionValuesForSearchControls()

            'Determine If A Filter Was Applied
            If srchBatchNumber.Text.Trim.Length > 0 _
                OrElse srchVendor.Text.Trim.Length > 0 _
                OrElse srchSKU.Text.Trim.Length > 0 _
                OrElse srchVPN.Text.Trim.Length > 0 _
                OrElse srchUPC.Text.Trim.Length > 0 _
                OrElse srchDept.SelectedValue > 0 _
                OrElse srchStockCat.SelectedValue.Trim.Length > 0 _
                OrElse srchWrittenStartDate.Text.Trim.Length > 0 _
                OrElse srchWrittenEndDate.Text.Trim.Length > 0 _
                OrElse srchAllocationEvent.SelectedValue > 0 _
                OrElse srchLocation.Text.Trim.Length > 0 _
                OrElse srchBasicSeasonal.Text.Trim.Length > 0 _
                OrElse srchPODept.SelectedValue > 0 _
                OrElse srchPOType.SelectedValue.Trim.Length > 0 _
                OrElse srchInitiator.SelectedValue.Trim.Length > 0 Then

                hidFilterApplied.Value = 1

            Else
                hidFilterApplied.Value = 0
            End If

            'Honor The Filter
            If hidFilterApplied.Value = 1 Then

                'Start From First Item
                Session(cPOBATCHSTARTROW) = 0

                'Load Filters Into Session
                SetSessionValuesFromSearchControls()

            End If

            'Re-Populate Gridview With Filters
            PopulateGridView()

            'Update Filter Display
            UpdateFilterDisplay()

        Else

            'Display Errors
            FilteredSearchContainer.Attributes.Add("style", "display: block;")

        End If


    End Sub

    Public Sub UpdateFilterDisplay()

        FilteredSearchContainer.Attributes.Clear()

        If hidFilterApplied.Value = 0 Then
            FilteredSearchContainer.Attributes.Add("style", "display: none;")
        Else
            FilteredSearchContainer.Attributes.Add("style", "display: block;")
        End If

    End Sub

    Protected Sub btnFiltered_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnFiltered.Click

        ClearSessionValuesForSearchControls()

        Response.Redirect("POCreation.aspx", False)

    End Sub

End Class

