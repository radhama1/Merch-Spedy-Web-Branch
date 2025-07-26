Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Text
Imports System.Xml
Imports System.Xml.XPath
Imports System.Collections.Generic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels

Partial Class reportlist
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("login.aspx")
        End If
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long", False)
        hdnUserID.Value = userID

        ' make sure __doPostBack is generated
        ClientScript.GetPostBackEventReference(Me, String.Empty)

        ' get report list
        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsReport()
        Dim reports As Models.SPEDYReportList = objMichaels.GetList()

        ' display
        reportsRepeater.DataSource = reports.ReportList
        reportsRepeater.DataBind()

        ' setup the report options box
        SetupReportOptions()
        SetupApproverList()

        ' clean up
        objMichaels = Nothing
        reports.ClearList()
        reports = Nothing

    End Sub

    Protected Sub SetupApproverList()
        Try
            Dim users As DataTable = NovaLibra.Coral.Data.Security.Security.GetAllEnabled()
            reportApprover.Items.Add(New ListItem("-- All Users --", String.Empty))

            If users.Rows.Count > 0 Then
                For Each dr As DataRow In users.Rows
                    reportApprover.Items.Add(New ListItem(dr("Last_Name") & " " & dr("First_Name"), dr("ID")))
                Next
            End If

            reportApprover.SelectedValue = Session("UserID")

        Catch ex As Exception
            Logger.LogError(ex)
        End Try
    End Sub

    Protected Sub SetupReportOptions()
        reportWorkflow.Attributes.Add("onchange", "GetStages();")
        reportWorkflow.Items.Add(New ListItem("New Item Induction", "1"))
        reportWorkflow.Items.Add(New ListItem("Item Maintenance", "2"))

        Dim departments As List(Of Models.DepartmentRecord)
        Dim objData As New Data.DepartmentData
        departments = objData.GetDepartments

        reportDept.Items.Add(New ListItem("-- All --", String.Empty))
        For Each dept As Models.DepartmentRecord In departments
            reportDept.Items.Add(New ListItem(dept.DeptDesc, dept.Dept.ToString))
        Next
        departments.Clear()
    End Sub

    Public Function GetLinkClickEvent(ByRef reportObject As Object, ByVal viewOption As String) As String
        Dim retStr As String = String.Empty

        'Determine if the Vendor is saved in session (i.e. is logged in through Vendor Connect)
        Dim isVendorLoaded As Boolean = False
        Dim vendor As Integer = AppHelper.GetVendorID()
        If vendor > 0 Then
            isVendorLoaded = True
        End If
        Dim report As Models.SPEDYReport = CType(reportObject, Models.SPEDYReport)

        'If the report is not viewable, default viewoption to email
        If Not report.IsViewable Then
            viewOption = "email"
        End If

        retStr = "openReport(this, '" & Server.HtmlEncode(report.ID) & "', '" & Server.HtmlEncode(report.ReportConstant.Replace("'", "''")) & "', '" & viewOption & "', '" & Server.HtmlEncode(report.ReportName.Replace("'", "''")) & "', " & _
                    "'" & report.DateRangeLabel & "', " & _
                    report.UsesStartDateParam.ToString().ToLower() & ", " & _
                    report.UsesEndDateParam.ToString().ToLower() & ", " & _
                    report.UsesDeptParam.ToString().ToLower() & ", " & _
                    report.UsesWorkflowParam.ToString().ToLower() & ", " & _
                    report.UsesStageParam.ToString().ToLower() & ", " & _
                    report.UsesStatusParam.ToString().ToLower() & ", " & _
                    isVendorLoaded.ToString.ToLower() & ", " & _
                    report.UsesVendorFilterParam.ToString.ToLower & ", " & _
                    report.UsesSKUParam.ToString.ToLower & ", " & _
                    report.UsesSKUGroupParam.ToString.ToLower & ", " & _
                    report.UsesStockCategoryParam.ToString.ToLower & ", " & _
                    report.UsesItemTypeParam.ToString.ToLower & ", " & _
                    report.UsesApproverParam.ToString.ToLower & ", " & _
                    report.UsesHoursParam.ToString.ToLower & ", " & _
                    report.UsesMSSOrSPEDYParam.ToString.ToLower & ", " & _
                    report.UsesPLIFrenchParam.ToString.ToLower & ", " & _
                    report.UsesPOStockCategoryParam.ToString.ToLower & ", " & _
                    report.UsesPOStatusParam.ToString.ToLower & ", " & _
                    report.UsesPOTypeParam.ToString.ToLower & ", " & _
                    report.UsesPOStageParam.ToString.ToLower & "); return false;"
        Return retStr
    End Function
End Class
