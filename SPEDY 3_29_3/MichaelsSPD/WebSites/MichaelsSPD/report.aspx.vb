Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Common

Partial Class report
    Inherits System.Web.UI.Page
    Dim dt As DataTable = Nothing

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the page
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.EnableViewState = False
        lblErrorMessage.Text = ""

        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("login.aspx")
        End If
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long", False)

        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsReport()
        Dim reportID As Long = DataHelper.SmartValues(Request("id"), "long", False)
        Dim report As Models.SPEDYReport = objMichaels.GetReport(reportID)

        Dim vendorNum As Integer = AppHelper.GetVendorID()

        'Me.Page.Title = ConfigurationManager.AppSettings("ApplicationName")
        Me.Page.Title = "Item Data Management :: " & report.ReportName
        reportName.Text = report.ReportName

        Dim dateNow As Date = Now()
        runDate.Text = dateNow.ToString("M/d/yyyy")

        ' setup grid
        Dim objGridItem As GridItem

        ReportGrid.ExcelMode = True

        ' SETUP COLUMNS
        Dim vendorFilterNum As Integer = DataHelper.SmartValues(Request("vendorfilter"), "integer", False)
        Try
            dt = objMichaels.RunReport(report, Request("startdate"), Request("enddate"), Request("dept"), Request("stage"), vendorNum, vendorFilterNum, Request("itemstatus"), Request("sku"), Request("skugroup"), Request("stockcategory"), Request("itemtype"), Request("workflowid"), Request("approver"), Request("hours"), Request("mssorspedy"), Request("plifrench"), Request("poStockCategory"), Request("poStatus"), Request("poType"), Request("poStage"))
            If Not dt Is Nothing Then
                For i As Integer = 0 To dt.Columns.Count - 1
                    If dt.Columns(i).ColumnName <> "ID" Then
                        objGridItem = ReportGrid.AddGridItem(i + 1, dt.Columns(i).ColumnName.Replace("_", " "), dt.Columns(i).ColumnName, dt.Columns(i).DataType.ToString(), "string")
                    End If
                Next
            Else
                Response.Write("Report Error !")
            End If

            If Not dt Is Nothing Then
                totalRecords.Text = dt.Rows.Count.ToString()
                ReportGrid.DataSource = dt
                ReportGrid.DataBind()
            Else
                totalRecords.Text = "0"
            End If

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            lblErrorMessage.Text = "SPEDY was unable to properly display your report.  Please try having the report emailed to you.  If you believe this message was received in error, please contact support."
            'Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)

            lblErrorMessage.Text = "SPEDY was unable to properly display your report.  Please try having the report emailed to you.  If you believe this message was received in error, please contact support."
            'Throw ex
        Finally
            objMichaels = Nothing
        End Try
    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        If Not dt Is Nothing Then
            dt = Nothing
        End If
    End Sub

    Public Sub ReportGrid_Error(ByVal sender As Object, ByVal e As EventArgs) Handles ReportGrid.Error
        lblErrorMessage.Text = "SPEDY was unable to properly display your report.  Please try having the report emailed to you.  If you believe this message was received in error, please contact support."
        ReportGrid.Visible = False
    End Sub

End Class
