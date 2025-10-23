Imports WebConstants
Imports System.Collections.Generic
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Helper = NovaLibra.Common.Utilities.DataHelper
Imports Data = NovaLibra.Coral.Data.Michaels
Imports PagingFiltering = NovaLibra.Common.Utilities.PaginationXML
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities

Partial Public Class _POMaint
    Inherits MichaelsBasePage

    'PAGING
    Const cPOMAINTPERPAGE As String = "POMAINTPERPAGE"
    Const cPOMAINTCURPAGE As String = "POMAINTCURPAGE"
    Const cPOMAINTTOTALPAGES As String = "POMAINTTOTALPAGES"
    Const cPOMAINTSTARTROW As String = "POMAINTSTARTROW"
    Const cPOMAINTTOTALROWS As String = "POMAINTTOTALROWS"

    'SORTING
    Const cPOMAINTCURSORTCOL As String = "POMAINTCURSORTCOL"
    Const cPOMAINTCURSORTDIR As String = "POMAINTCURSORTDIR"

    'FILTERING
    Const cPOMAINTSHOWSTAGE As String = "POMAINTSHOWSTAGE"
    Const cPOMAINTSEARCHFILTER As String = "POMAINTSEARCHFILTER"


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Check Session
        SecurityCheckRedirect()
        Session(CURRENTTAB) = POMAINT

        ' Clear out messages
        ShowMsg("")

        If Not IsPostBack Then

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

    Private Sub InitializeSearchControls()

        'Enter Keypress Submits Search
        srchPONumber.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchBatchNumber.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchWrittenStartDate.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchWrittenEndDate.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchSKU.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchVendor.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchLocation.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchVPN.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchDept.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchPODept.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchAllocationEvent.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchUPC.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchStockCat.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchPOStatus.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchBasicSeasonal.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
        srchPOType.Attributes.Add("onkeypress", "return clickButton(event,'" + btnSearch.ClientID + "')")
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

        'Add/Remove Filter
        If Session(cPOMAINTSEARCHFILTER) IsNot Nothing Then
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

        'GET Departments
        Dim departments As List(Of Models.DepartmentRecord)
        Dim objData As New Data.DepartmentData
        departments = objData.GetDepartments

        srchDept.DataSource = departments
        srchDept.DataTextField = "DeptDesc"
        srchDept.DataValueField = "Dept"
        srchDept.DataBind()
        srchDept.Items.Insert(0, New ListItem("*  Any Department  *", "0"))
        srchDept.SelectedValue = IIf(deptNo >= 0, deptNo, 0)

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

        'Load Acllocation Events
        LoadAllocationEvents()

        'Load PO Status
        LoadPOStatus()

        'Load PO Type
        srchPOType.Items.Add(New ListItem("", ""))
        srchPOType.Items.Add(New ListItem("AST", "AST"))
        srchPOType.Items.Add(New ListItem("MAN", "MAN"))

        'Load Initiators
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

    Private Sub LoadPOStatus()

        'Removes All Previous Items
        srchPOStatus.Items.Clear()

        Dim SQLStr As String = "PO_Status_Get_All"
        srchPOStatus.Items.Add(New ListItem("", 0))

        Using conn As New SqlConnection(ConnectionString)

            Try

                Dim cmd As New SqlCommand(SQLStr, conn)

                cmd.CommandType = CommandType.StoredProcedure
                conn.Open()

                Using reader As SqlDataReader = cmd.ExecuteReader()

                    While reader.Read()

                        If DataHelper.SmartValue(reader.Item("Constant"), "CStr", "") <> "WORKSHEET" Then
                            srchPOStatus.Items.Add(New ListItem(DataHelper.SmartValue(reader.Item("Name"), "CStr", ""), reader.Item("ID")))
                        End If

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

	Public Sub PopulateActionDD(ByVal ddaction As DropDownList, ByVal poID As Long, ByVal createdBy As Long, ByVal stageTypeID As Integer, ByVal stageId As Integer, ByVal stageEnabled As Boolean)

		'Set Actions in Dropdown based on User, Groups, and Current Stage/Stage Type
        If Data.POMaintenanceData.ValidateUserForPO(poID, Session(cUSERID)) Then
            'Set Actions in Dropdown based on User, Groups, and Current Stage/Stage Type
            If stageTypeID <> Models.WorkflowStageType.Completed AndAlso stageTypeID <> Models.WorkflowStageType.WaitingForPONumber AndAlso stageEnabled Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))
                ddaction.Items.Add(New ListItem("Approve", "1"))

                'RULE: DO NOT Display Disapprove option if in Initial stage
                If stageTypeID <> Models.WorkflowStageType.Initial Then
                    ddaction.Items.Add(New ListItem("Disapprove", "2"))
                End If
                'RULE: Rollback should only be available during the Initiator stage (per Michaels request on 6/22/2011
                If stageTypeID = Models.WorkflowStageType.Initial Then
                    ddaction.Items.Add(New ListItem("Rollback", "3"))
                End If
            End If

            'RULE: If PO is waiting for PONumber, and the user is an Admin/DBC/QA, let them resubmit PO (this handles problems with original submission)
            If stageTypeID = Models.WorkflowStageType.WaitingForPONumber AndAlso stageEnabled AndAlso IsAdminDBCQA() Then
                ddaction.Items.Add(New ListItem("Select action ", "0"))
                ddaction.Items.Add(New ListItem("Resubmit", "4"))
            End If
        End If

	End Sub

    ' Populate Stage Dropdowns
    Private Sub PopulateFindShows()

        ddFindshowNew.DataSource = GetSPEDyStages(WorkflowType.POMaint)
        ddFindshowNew.DataTextField = "StageName"
        ddFindshowNew.DataValueField = "ID"
        ddFindshowNew.DataBind()
        ddFindshowNew.Items.Insert(0, New ListItem("My Items", "0"))
        ddFindshowNew.Items.Insert(1, New ListItem("All Stages", "-1")) ' special case!
        ddFindshowNew.Items.Add(New ListItem("Cancelled", "1"))    ' Approved stage with Cancelled PO Status
        ddFindshowNew.Items.Add(New ListItem("Closed", "2"))    ' Approved stage with Closed PO Status

		'Default the first Index as the Selected Index
        If Session(cPOMAINTSHOWSTAGE) Is Nothing Then
            ddFindshowNew.SelectedIndex = 0
        Else
            If Not ddFindshowNew.Items.FindByValue(Session(cPOMAINTSHOWSTAGE)) Is Nothing Then
                ddFindshowNew.SelectedValue = Session(cPOMAINTSHOWSTAGE)
            Else
                ddFindshowNew.SelectedIndex = 0
            End If
        End If
		Session(cPOMAINTSHOWSTAGE) = Me.ddFindshowNew.SelectedValue

    End Sub

    Private Sub SetSearchControlValuesForSession()

        'Load Values From Session
        If Session(cPOMAINTSEARCHFILTER) IsNot Nothing Then

            srchPONumber.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPONumber"), "CStr", "")
            srchBatchNumber.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchBatchNumber"), "CStr", "")
            srchVendor.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchVendor"), "CStr", "")
            srchDept.SelectedValue = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchDept"), "CStr", "")
            srchPODept.SelectedValue = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPODept"), "CStr", "")
            srchStockCat.SelectedValue = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchStockCat"), "CStr", "")
            srchWrittenStartDate.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchWrittenStartDate"), "CStr", "")
            srchWrittenEndDate.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchWrittenEndDate"), "CStr", "")
            srchLocation.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchLocation"), "CStr", "")
            srchAllocationEvent.SelectedValue = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchAllocationEvent"), "CStr", "")
            srchSKU.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchSKU"), "CStr", "")
            srchVPN.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchVPN"), "CStr", "")
            srchUPC.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchUPC"), "CStr", "")
            srchPOStatus.SelectedValue = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPOStatus"), "CStr", "")
            srchBasicSeasonal.Text = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchBasicSeasonal"), "CStr", "")
            srchPOType.SelectedValue = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPOType"), "CStr", "")
            srchInitiator.SelectedValue = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchInitiator"), "CStr", "")

        End If

    End Sub

    Private Sub SetSessionValuesFromSearchControls()

        'Clear Current Values
        ClearSessionValuesForSearchControls()

        'PO Number
        If srchPONumber.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchPONumber") = srchPONumber.Text.Trim
        End If

        'Batch Number
        If srchBatchNumber.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchBatchNumber") = srchBatchNumber.Text.Trim
        End If

        'Vendor
        If srchVendor.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchVendor") = srchVendor.Text.Trim
        End If

        'Department
        If srchDept.SelectedValue.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchDept") = srchDept.SelectedValue
        End If

        'Stock Category
        If srchStockCat.SelectedValue.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchStockCat") = srchStockCat.SelectedValue
        End If

        'SKU
        If srchSKU.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchSKU") = srchSKU.Text.Trim
        End If

        'VPN
        If srchVPN.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchVPN") = srchVPN.Text.Trim
        End If

        Dim UPC As String = srchUPC.Text.Trim
        If UPC.Length > 1 AndAlso UPC.Length < 14 Then
            UPC = UPC.Trim.PadLeft(14, "0")
        End If

        'UPC
        If UPC.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchUPC") = srchUPC.Text.Trim
        End If

        'Written Date Start Date
        If srchWrittenStartDate.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchWrittenStartDate") = srchWrittenStartDate.Text.Trim
        End If

        'Written Date End Date
        If srchWrittenEndDate.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchWrittenEndDate") = srchWrittenEndDate.Text.Trim
        End If

        'Location
        If srchLocation.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchLocation") = srchLocation.Text.Trim
        End If

        'Allocation Event
        If srchAllocationEvent.SelectedValue.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchAllocationEvent") = srchAllocationEvent.SelectedValue
        End If

        'PO Status
        If srchPOStatus.SelectedValue.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchPOStatus") = srchPOStatus.SelectedValue
        End If

        'Basic/Seasonal
        If srchBasicSeasonal.Text.Trim.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchBasicSeasonal") = srchBasicSeasonal.Text.Trim
        End If

        'PO Department
        If srchDept.SelectedValue.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchPODept") = srchPODept.SelectedValue
        End If

        'PO Type
        If srchDept.SelectedValue.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchPOType") = srchPOType.SelectedValue
        End If

        'Initiator Role
        If srchDept.SelectedValue.Length > 0 Then
            Session(cPOMAINTSEARCHFILTER & "_srchInitiator") = srchInitiator.SelectedValue
        End If

    End Sub

    Private Sub ClearSessionValuesForSearchControls()

        Session.Contents.Remove(cPOMAINTSEARCHFILTER)

        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchPONumber")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchBatchNumber")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchVendor")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchDept")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchPODept")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchStockCat")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchWrittenStartDate")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchWrittenEndDate")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchLocation")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchAllocationEvent")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchSKU")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchVPN")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchUPC")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchPOStatus")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchBasicSeasonal")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchPOType")
        Session.Contents.Remove(cPOMAINTSEARCHFILTER & "_srchInitiator")
    End Sub

    Private Sub PopulateGridView()

        Dim cmd As SqlCommand
        Dim dt As DataTable

        Try
            Dim sql As String = "PO_Maint_Search"
            Dim dbUtil As New DBUtil(ConnectionString)

            cmd = New SqlCommand()

            Dim xml As New PaginationXML()

            '************************
            'Add Search Filters
            '************************

            If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER), "CStr", "").Trim.Length = 0 AndAlso hidFilterApplied.Value = "1" Then

                'PO Number
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPONumber"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(50, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPONumber"), "CLng", 0))
                End If

                'Batch Number
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchBatchNumber"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(51, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchBatchNumber"), "CStr", ""))
                End If

                'Vendor
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchVendor"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(52, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchVendor"), "CLng", 0))
                End If

                'Department
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchDept"), "CInt", 0) > 0 Then
                    xml.AddFilterCriteria(53, Session(cPOMAINTSEARCHFILTER & "_srchDept"))
                End If

                'Stock Category
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchStockCat"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(54, Session(cPOMAINTSEARCHFILTER & "_srchStockCat"))
                End If

                'SKU
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchSKU"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(56, Session(cPOMAINTSEARCHFILTER & "_srchSKU"))
                End If

                'VPN
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchVPN"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(57, Session(cPOMAINTSEARCHFILTER & "_srchVPN"))
                End If

                Dim UPC As String = Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchUPC"), "CStr", "")
                If UPC.Length > 1 AndAlso UPC.Length < 14 Then
                    UPC = UPC.Trim.PadLeft(14, "0")
                End If

                'UPC
                If UPC.Length > 0 Then
                    xml.AddFilterCriteria(58, Session(cPOMAINTSEARCHFILTER & "_srchUPC"))
                End If

                'Written Date Start Date
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchWrittenStartDate"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(59, Session(cPOMAINTSEARCHFILTER & "_srchWrittenStartDate"))
                End If

                'Written Date End Date
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchWrittenEndDate"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(60, Session(cPOMAINTSEARCHFILTER & "_srchWrittenEndDate"))
                End If

                'Location
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchLocation"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(61, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchLocation"), "CLng", 0))
                End If

                'Allocation Event
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchAllocationEvent"), "CLng", 0) > 0 Then
                    xml.AddFilterCriteria(62, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchAllocationEvent"), "CLng", 0))
                End If

                'Basic/Seasonal
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchBasicSeasonal"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(63, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchBasicSeasonal"), "CStr", ""))
                End If

                'PO Status
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPOStatus"), "CInt", 0) > 0 Then
                    xml.AddFilterCriteria(64, Session(cPOMAINTSEARCHFILTER & "_srchPOStatus"))
                End If

                'PO Department
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPODept"), "CInt", 0) > 0 Then
                    xml.AddFilterCriteria(65, Session(cPOMAINTSEARCHFILTER & "_srchPODept"))
                End If

                'PO Type
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPOType"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(66, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchPOType"), "CStr", ""))
                End If

                'Initiator Role
                If Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchInitiator"), "CStr", "").Length > 0 Then
                    xml.AddFilterCriteria(67, Helper.SmartValue(Session(cPOMAINTSEARCHFILTER & "_srchInitiator"), "CStr", ""))
                End If

                'Save Filter In Session
                Session(cPOMAINTSEARCHFILTER) = xml.GetFilterInnerXMLStr()

            ElseIf Helper.SmartValue(Session(cPOMAINTSEARCHFILTER), "CStr", "").Trim.Length > 0 Then

                xml.SetFilterInnerXMLStr(Session(cPOMAINTSEARCHFILTER))

            End If

            'Add Workflow Status Filters
            If Not Session(cPOMAINTSHOWSTAGE) Is Nothing Then

                Select Case (Session(cPOMAINTSHOWSTAGE))
                    Case "-3"
                        xml.AddFilterCriteria(5, "")
                    Case "-1"
                        'Return ALL Stages
                        xml.AddFilterCriteria(-1, "")
                    Case "0"
                        'Set UserID to pull back All "My Items" - (Defined as Items created by me, or in a Workflow Stage that I can approve)
                        'OT: Minus Batches With Completed Workflow Stage Type
                        xml.AddFilterCriteria(4, Session(cUSERID).ToString())
                    Case "1"
                        'Return Approved POs that are in the Cancelled PO Status.
                        xml.AddFilterCriteria(1, "")
                    Case "2"
                        'Return Approved POs that are in the Closed PO Status.
                        xml.AddFilterCriteria(2, "")
                    Case Else
                        'Return Stages that match the selected Workflow Stage
                        xml.AddFilterCriteria(3, Session(cPOMAINTSHOWSTAGE).ToString())
                End Select

            End If

            'Add Sorting
            xml.AddSortCriteria(Session(cPOMAINTCURSORTCOL), Session(cPOMAINTCURSORTDIR))

            cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.VarChar).Value = xml.GetPaginationXML().Replace("'", "''")
            cmd.Parameters.Add("@maxRows", SqlDbType.Int).Value = Helper.SmartValue(Session(cPOMAINTPERPAGE), "CInt", -1)
            cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = Helper.SmartValue(Session(cPOMAINTSTARTROW), "CInt", 1)

            cmd.CommandText = sql
            cmd.CommandTimeout = 1800
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Connection = dbUtil.GetSqlConnection()

            dt = dbUtil.GetDataTable(cmd)

            'Update Paging
            If dt.Rows.Count > 0 Then
                Session(cPOMAINTTOTALROWS) = Helper.SmartValue(dt.Rows(0)("totRecords"), "CStr", 0)
                Session(cPOMAINTSTARTROW) = Helper.SmartValue(dt.Rows(0)("RowNumber"), "CStr", 0)
            Else
                Session(cPOMAINTTOTALROWS) = 0
            End If

            UpdatePagingInformation()

            gvMaint.PageSize = Session(cPOMAINTPERPAGE)
            gvMaint.DataSource = dt
            gvMaint.DataBind()

            If gvMaint.Rows.Count > 0 Then
                gvMaint.BottomPagerRow.Visible = True
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
		Session(cPOMAINTSHOWSTAGE) = Me.ddFindshowNew.SelectedValue
        Session.Remove(cPOMAINTSEARCHFILTER)
		PopulateGridView()
	End Sub

	Private Sub DDFindshowNew_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddFindshowNew.SelectedIndexChanged
		Session(cPOMAINTSHOWSTAGE) = Me.ddFindshowNew.SelectedValue
        Session.Remove(cPOMAINTSEARCHFILTER)
		PopulateGridView()
	End Sub

    Private Sub UpdatePagingInformation()

        'Set Defaults
        If Session(cPOMAINTPERPAGE) Is Nothing Then Session(cPOMAINTPERPAGE) = BATCH_PAGE_SIZE
        If Session(cPOMAINTCURPAGE) Is Nothing Then Session(cPOMAINTCURPAGE) = 1
        If Session(cPOMAINTTOTALPAGES) Is Nothing Then Session(cPOMAINTTOTALPAGES) = 0
        If Session(cPOMAINTSTARTROW) Is Nothing Then Session(cPOMAINTSTARTROW) = 1
        If Session(cPOMAINTTOTALROWS) Is Nothing Then Session(cPOMAINTTOTALROWS) = 0

        If Helper.SmartValue(Session(cPOMAINTTOTALROWS), "CInt") > 0 Then

            If Helper.SmartValue(Session(cPOMAINTSTARTROW), "CInt") > Helper.SmartValue(Session(cPOMAINTTOTALROWS), "CInt") Then
                Session(cPOMAINTSTARTROW) = 1
            End If

            Session(cPOMAINTTOTALPAGES) = Fix(Helper.SmartValue(Session(cPOMAINTTOTALROWS), "CInt") / Helper.SmartValue(Session(cPOMAINTPERPAGE), "CInt"))
            If (Helper.SmartValue(Session(cPOMAINTTOTALROWS), "CInt") Mod Helper.SmartValue(Session(cPOMAINTPERPAGE), "CInt")) <> 0 Then
                Session(cPOMAINTTOTALPAGES) = Helper.SmartValue(Session(cPOMAINTTOTALPAGES), "CInt") + 1
            End If

            If Helper.SmartValue(Session(cPOMAINTCURPAGE), "CInt") <= 0 OrElse Helper.SmartValue(Session(cPOMAINTCURPAGE), "CInt") > Helper.SmartValue(Session(cPOMAINTTOTALPAGES), "CInt") Then
                Session(cPOMAINTCURPAGE) = 1
            End If

        Else
            Session(cPOMAINTCURPAGE) = 1
            Session(cPOMAINTTOTALPAGES) = 0
            Session(cPOMAINTSTARTROW) = 1
        End If

    End Sub

    Protected Sub gvMaint_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvMaint.PageIndexChanged

    End Sub

    Protected Sub gvMaint_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvMaint.PageIndexChanging

    End Sub

    Private Sub UpdateSortingInformation()

        'Set Defaults
        If Session(cPOMAINTCURSORTCOL) Is Nothing Then Session(cPOMAINTCURSORTCOL) = 0
        If Session(cPOMAINTCURSORTDIR) Is Nothing Then Session(cPOMAINTCURSORTDIR) = PagingFiltering.SortDirection.Asc

    End Sub

    Protected Sub gvMaint_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gvMaint.Sorting

    End Sub

    Protected Sub gvMaint_Sorted(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvMaint.Sorted

    End Sub

    Protected Sub gvMaint_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvMaint.RowCreated
        If (e.Row.RowType = DataControlRowType.Header) Then
            AddSortGlyph(gvMaint, e.Row, Session(cPOMAINTCURSORTCOL), PagingFiltering.GetSortDirectionString(Session(cPOMAINTCURSORTDIR)))
        End If
    End Sub

    Protected Sub gvMaint_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvMaint.RowCommand

        Select Case e.CommandName

            Case "Action"
				'Get the row this action occurred in
				Dim row As GridViewRow = gvMaint.Rows(e.CommandArgument)
                Dim gvStageID As Integer = DataHelper.SmartValue(CType(row.FindControl("StageID"), HiddenField).Value, "CInt", 0)

				'Get the Action that occurred
				Dim ddActions As DropDownList = row.FindControl("DDAction")
				If ddActions.SelectedIndex > 0 Then
					Dim actionValue As Integer = CInt(ddActions.SelectedValue)
					Dim poID As Long = gvMaint.DataKeys(e.CommandArgument).Value

                    'Verify the GridView is synced with Database.  Do not process if it is different
                    Dim poRec As Models.POMaintenanceRecord = Data.POMaintenanceData.GetRecord(poID)
                    If (gvStageID = poRec.WorkflowStageID) Then
                        ProcessAction(poRec, actionValue)
                    Else
                        'Refresh Grid to make it in synch
                        PopulateGridView()
                    End If
				End If
            Case "Sort"

                'Same Column (Change Direction)
                If Session(cPOMAINTCURSORTCOL).ToString() = e.CommandArgument.ToString() Then

                    If Session(cPOMAINTCURSORTDIR) = PagingFiltering.SortDirection.Asc Then
                        Session(cPOMAINTCURSORTDIR) = PagingFiltering.SortDirection.Desc
                    Else
                        Session(cPOMAINTCURSORTDIR) = PagingFiltering.SortDirection.Asc
                    End If

                Else
                    Session(cPOMAINTCURSORTCOL) = e.CommandArgument.ToString()
                    Session(cPOMAINTCURSORTDIR) = PagingFiltering.SortDirection.Asc
                End If

                'Go To First Item
                Session(cPOMAINTCURPAGE) = 1
                Session(cPOMAINTSTARTROW) = 1

                PopulateGridView()

            Case "Page"

                Select Case e.CommandArgument
                    Case "First"
                        Session(cPOMAINTCURPAGE) = 1
                        Session(cPOMAINTSTARTROW) = 1
                    Case "Prev"
                        If Session(cPOMAINTCURPAGE) > 1 Then
                            Session(cPOMAINTCURPAGE) -= 1
                            Session(cPOMAINTSTARTROW) = Session(cPOMAINTSTARTROW) - Session(cPOMAINTPERPAGE)
                        End If
                    Case "Next"
                        If Session(cPOMAINTCURPAGE) < Session(cPOMAINTTOTALPAGES) Then
                            Session(cPOMAINTCURPAGE) += 1
                            Session(cPOMAINTSTARTROW) = Session(cPOMAINTSTARTROW) + Session(cPOMAINTPERPAGE)
                        End If
                    Case "Last"
                        Session(cPOMAINTCURPAGE) = Session(cPOMAINTTOTALPAGES)
                        Session(cPOMAINTSTARTROW) = ((Session(cPOMAINTTOTALPAGES) - 1) * Session(cPOMAINTPERPAGE)) + 1
                End Select

                PopulateGridView()

            Case "PageGo"

                Dim newPageNum As Integer = GoToPage()

                If newPageNum > 0 AndAlso newPageNum <= Session(cPOMAINTTOTALPAGES) Then

                    Session(cPOMAINTCURPAGE) = newPageNum
                    Session(cPOMAINTSTARTROW) = ((Session(cPOMAINTCURPAGE) - 1) * Session(cPOMAINTPERPAGE)) + 1

                    PopulateGridView()
                Else
                    ShowMsg("Invalid Page Number entered.")
                End If

            Case "PageReset"

                Dim newBatchesPerPage As Integer = BatchesPerPage()

                If newBatchesPerPage >= 5 AndAlso newBatchesPerPage <= 50 Then

                    Session(cPOMAINTCURPAGE) = 1
                    Session(cPOMAINTSTARTROW) = 1
                    Session(cPOMAINTPERPAGE) = newBatchesPerPage

                    PopulateGridView()
                Else
                    ShowMsg("Batches / Page must be between 5 and 50")
                End If

        End Select

    End Sub

    Private Sub gvMaint_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvMaint.RowDataBound

        Select Case e.Row.RowType

            Case DataControlRowType.DataRow

				Dim ctrlDD As DropDownList = e.Row.FindControl("DDAction")
				Dim ctrlBtn As Button = e.Row.FindControl("DDActionGo")

				'Get the data that corresponds with the current Row
				Dim objNewItemRec = CType(e.Row.DataItem, DataRowView).Row

                Dim poID As Long = Helper.SmartValue(objNewItemRec.Item("ID"), "CLng", 0)
                Dim createdByUserID As Integer = Helper.SmartValue(objNewItemRec.Item("Created_User_ID"), "CInt", 0)
                Dim stageID As Integer = Helper.SmartValue(objNewItemRec.Item("Workflow_Stage_ID"), "CInt", 0)
                Dim stageTypeID As Integer = Helper.SmartValue(objNewItemRec.Item("Stage_Type_ID"), "CInt", 0)
                Dim isEnabled As Boolean = Helper.SmartValue(objNewItemRec.Item("Enabled"), "Boolean", False)

				PopulateActionDD(ctrlDD, poID, createdByUserID, stageTypeID, stageID, isEnabled)

				If ctrlDD.Items.Count = 0 Then
					ctrlBtn.Visible = False
					ctrlDD.Visible = False
				End If
				ctrlBtn.CommandArgument = e.Row.RowIndex.ToString()
                ctrlBtn.Attributes.Add("OnClick", "return RemoveDisappr_ActionButtonClick(" & (e.Row.RowIndex + 1).ToString & ");")


            Case DataControlRowType.Pager

                Dim ctrlPaging As Object

                ctrlPaging = e.Row.FindControl("PagingInformation")
                ctrlPaging.text = String.Format("Page {0} of {1}", Session(cPOMAINTCURPAGE), Session(cPOMAINTTOTALPAGES))

                ctrlPaging = e.Row.FindControl("lblBatchesFound")
                ctrlPaging.text = Session(cPOMAINTTOTALROWS).ToString() & " " & ctrlPaging.text

                ctrlPaging = e.Row.FindControl("txtgotopage")
                If Helper.SmartValue(Session(cPOMAINTCURPAGE), "CInt") < Helper.SmartValue(Session(cPOMAINTTOTALPAGES), "CInt") Then
                    ctrlPaging.text = Helper.SmartValue(Session(cPOMAINTCURPAGE), "CInt") + 1
                Else
                    ctrlPaging.text = "1"
                End If

                ctrlPaging = e.Row.FindControl("txtBatchPerPage")
                ctrlPaging.text = Helper.SmartValue(Session(cPOMAINTPERPAGE), "CInt")

        End Select

    End Sub

    Public Function GoToPage() As Long

        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvMaint.BottomPagerRow
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

    Public Function BatchesPerPage() As Long

        Dim ctrl As New Object
        Dim i As Integer = 0
        Dim pagerRow As GridViewRow
        Try
            pagerRow = gvMaint.BottomPagerRow
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

        If Abbrev IsNot Nothing Then

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

	Private Sub ApproveRecord(ByVal poRecord As Models.POMaintenanceRecord)
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
							isConditionMet = EvaluateInitiators(CType(exceptionList.Item(i), Models.WorkflowException), DataHelper.SmartValue(poRecord.InitiatorRoleID, "Integer", 0))
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
							isConditionMet = EvaluateShipWindow(CType(exceptionList.Item(i), Models.WorkflowException), poRecord.NotBefore)
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
                            isConditionMet = (poRecord.POConstructID = Models.POMaintenanceRecord.Construct.AST)
                        Case POTYPEMAN
                            isConditionMet = (poRecord.POConstructID = Models.POMaintenanceRecord.Construct.Manual)
                        Case RSETEVENT
                            isConditionMet = Data.ValidationData.LookupAllocationCode(DataHelper.SmartValue(poRecord.POAllocationEventID, "CInt", 0)).StartsWith("RSET")
                        Case NONRSETEVENT
                            isConditionMet = Not Data.ValidationData.LookupAllocationCode(DataHelper.SmartValue(poRecord.POAllocationEventID, "CInt", 0)).StartsWith("RSET")
                        Case POCANCELLED
                            isConditionMet = EvaluatePOCancelled(poRecord.ID)
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
                    procOK = Data.POMaintenanceData.PublishPOMessage(poRecord.ID)
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

	Private Sub DisApproveRecord(ByVal disapprovalStageID As Integer, ByVal disapprovalNotes As String, ByVal poRecord As Models.POMaintenanceRecord)

		' Verify that the Stage to send the batch to is specified.  If not then get the default for the current Stage
		If disapprovalStageID <= 0 Then
			Dim initialStage As Integer = Data.POMaintenanceData.GetInitialWorkflowStageID(poRecord.InitiatorRoleID)
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

            'Invalidate the PO
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
			command.CommandText = "PO_Maintenance_SKU_Details_By_PO_ID"

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

            reader.Close()

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
			command.CommandText = "PO_Maintenance_SKU_Details_By_PO_ID"

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
				'IF A PaymentTerm was found, then it is a Letter of Credit Payment Term
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

    Public Function EvaluatePOCancelled(ByVal poID As Long?) As Boolean

        Dim isPOCancelled As Boolean = True

        'Retrieve SKUs on the PO
        Dim skus As List(Of Models.POMaintenanceSKURecord) = Data.POMaintenanceSKUData.GetSKUsByPOID(poID)
        For Each sku As Models.POMaintenanceSKURecord In skus
            'If the SKU Cancel Qty is not equal to the Order Qty, then this is not a full cancel
            If (sku.CancelledQty <> sku.OrderedQty) Then
                isPOCancelled = False
            End If
        Next

        'Return whether or not the PO is a full cancel
        Return isPOCancelled
    End Function

	Public Function EvaluateShipWindow(ByVal wfException As Models.WorkflowException, ByVal notBefore As Date?) As Boolean
		'Retrieve the configured Workflow Threshold
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

		If IsDate(notBefore) Then
			'RULE: Compare Today's Date to Shipwindow for PO_Maintenance
			Return (Date.Now > CType(notBefore, Date).AddDays(-shipWindow))
		Else
			Return False
		End If

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
		Dim dt As DataTable = Data.POMaintenanceData.GetPurchaseOrderTotals(poID)
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

    Private Sub ProcessAction(ByVal poRec As Models.POMaintenanceRecord, ByVal action As Integer)
        Try
            Select Case action
                Case 1 ' APPROVE
                    Dim isValid As Boolean = (Helper.SmartValue(poRec.IsHeaderValid, "Boolean", False) And Helper.SmartValue(poRec.IsDetailValid, "Boolean", False))

                    ' DBCQA / Sys Admins can approve batches even if they are invalid as long as its a normal stage type
                    If Not isValid AndAlso Not IsAdminDBCQA() Then
                        ShowMsg("This Purchase Order has Validation errors. Please correct before approving.")
                        poRec = Nothing
                    Else
                        'Only Approve the PO if there has been a change
                        Dim isChanged As Boolean = Data.POMaintenanceData.DetectChange(poRec.ID)
                        If isChanged Then
                            ApproveRecord(poRec)
                        Else
                            ShowMsg("This Purchase Order has not been changed.  Please make a change to the Purchase Order before approving.")
                        End If
                    End If

                Case 2 ' DisApprove
                    Dim toStage As Integer = DataHelper.DBSmartValues(Me.hdnDisApproveStageID.Value, "integer", False)
                    Dim disApproveNotes = Me.hdnNotes.Value
                    DisApproveRecord(toStage, disApproveNotes, poRec)

                Case 3 'ROLLBACK
                    'Save PO Workflow History with OLD WorkflowStageID
                    Data.POMaintenanceData.SaveWorkflowHistory(poRec, "ROLLBACK", Session(cUSERID), "")
                    Data.POMaintenanceData.Rollback(poRec.ID)
                Case 4 'Resubmit
                    'Save PO Workflow History
                    Data.POMaintenanceData.SaveWorkflowHistory(poRec, "RESUBMIT", Session(cUSERID), "")

                    'Resubmit PO, and Send an email if Resubmit was successful
                    Dim procOK As Boolean = Data.POMaintenanceData.PublishPOMessage(poRec.ID)

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
        Catch ex As Exception
            ProcessError(ex, "ProcessAction")
        End Try
    End Sub

	Private Sub ProcessWorkflowTransaction(ByVal poRecord As Models.POMaintenanceRecord, ByVal workflowStageID As Integer, ByVal action As String, ByVal notes As String)

		'Save PO Workflow History with OLD WorkflowStageID
		Data.POMaintenanceData.SaveWorkflowHistory(poRecord, action, Session(cUSERID), notes)

        'Save record for PO Creation in History Stage Durations table
        Data.POMaintenanceData.SaveHistoryStageDuration(poRecord.ID, action, poRecord.WorkflowStageID, workflowStageID, Session(cUSERID))

        'Set and Save PO Record with new WorkflowStageID
		poRecord.WorkflowStageID = workflowStageID
		'IF This is an approval, set the ApproverUserID on the PO Record
		If action = "APPROVE" Then poRecord.ApproverUserID = Session(cUSERID)

		'Update the Record in the database
		Data.POMaintenanceData.SaveRecord(poRecord, Session(cUSERID), HydrateRecord:=NovaLibra.Coral.Data.Michaels.POMaintenanceData.Hydrate.All)

	End Sub

	Private Sub ProcessError(ByVal ex As Exception, ByVal sourceName As String)
		Dim strmessage As String
		strmessage = "Unexpected SPEDY problem has occured in the routine: " & sourceName & " - "
		strmessage = strmessage & ex.Message & ". Please report this issue to the System Administrator."
		ShowMsg(strmessage)
	End Sub

    Private Sub InvalidatePORecord(ByVal poRecord As Models.POMaintenanceRecord, ByVal stageType As Models.WorkflowStageType)

        'Invalidate PO maintenance Record
        poRecord.IsDetailValid = Nothing
        poRecord.IsHeaderValid = Nothing
        Data.POMaintenanceData.UpdateRecordBySystem(poRecord, NovaLibra.Coral.Data.Michaels.POMaintenanceData.Hydrate.All)

        'RULE: Only update WS Validation flags if StageType is "Pack Approval"
        If (stageType = Models.WorkflowStageType.PackApproval) Then
            'Invalidate each SKU
            Dim skuList As List(Of Models.POMaintenanceSKURecord) = Data.POMaintenanceSKUData.GetSKUsByPOID(poRecord.ID)
            For Each sku As Models.POMaintenanceSKURecord In skuList
                Data.POMaintenanceSKUData.UpdateValidity(poRecord.ID, sku.MichaelsSKU, Nothing, Nothing)
            Next
        End If
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
            Session.Contents.Remove(cPOMAINTSEARCHFILTER)

            'Determine If A Filter Was Applied
            If srchPONumber.Text.Trim.Length > 0 _
                OrElse srchBatchNumber.Text.Trim.Length > 0 _
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
                OrElse srchPOStatus.SelectedValue > 0 _
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
                Session(cPOMAINTSTARTROW) = 0

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

        Response.Redirect("POMaint.aspx", False)

    End Sub

End Class

