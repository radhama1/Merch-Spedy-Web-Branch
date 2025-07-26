Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports SpreadsheetGear

Partial Class reportexcel
    Inherits System.Web.UI.Page

    Dim dt As DataTable = Nothing

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the page
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.EnableViewState = False

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

        ' SETUP COLUMNS
        Dim vendorFilterNum As Integer = DataHelper.SmartValues(Request("vendorfilter"), "integer", False)
        Try

            dt = objMichaels.RunReport(report, Request("startdate"), Request("enddate"), Request("dept"), Request("stage"), vendorNum, vendorFilterNum, Request("itemstatus"), Request("sku"), Request("skugroup"), Request("stockcategory"), Request("itemtype"), Request("workflowid"), Request("approver"), Request("hours"), Request("mssorspedy"), Request("plifrench"), Request("poStockCategory"), Request("poStatus"), Request("poType"), Request("poStage"))
            If Not dt Is Nothing Then

                'Remove first column if it is called ID.
                If dt.Columns(0).ColumnName = "ID" Then
                    dt.Columns.Remove("ID")
                End If

                'Create Report file
                Dim templatefile As String = ConfigurationManager.AppSettings("EXCEL_Report_Template")
                templatefile = templatefile.Replace(WebConstants.APP_PATH_REPLACE, (Server.MapPath("")))
                Dim wb As IWorkbook = Factory.GetWorkbook(templatefile)
                CreateReportFile(wb, dt, report)

                'Write out file
                Dim workflowName As String = ""
                If report.UsesWorkflowParam Then
                    Select Case Request("workflowid")
                        Case "1"
                            workflowName = "New Item Induction"
                        Case "2"
                            workflowName = "Item Maintenance"
                    End Select
                End If

                Dim fileName As String = report.ReportName & "_" & workflowName & "_" & Now().ToString("yyMMdd") & ".xls"
                Response.BufferOutput = True
                Response.Clear()
                Response.Buffer = True

                Dim memfile As New System.IO.MemoryStream()
                wb.SaveToStream(memfile, SpreadsheetGear.FileFormat.Excel8)
                memfile.WriteTo(Response.OutputStream)
                memfile = Nothing
                Response.ContentType = "application/vnd.ms-excel"
                Response.AddHeader("content-disposition", ("attachment;filename=" & fileName))
                wb = Nothing

            Else
                Response.Write("Report Error!")
            End If

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            lblErrorMessage.Text = "SPEDY was unable to properly generate your report.  Please try having the report emailed to you.  If you believe this message was received in error, please contact support."
            'Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
            lblErrorMessage.Text = "SPEDY was unable to properly generate your report.  Please try having the report emailed to you.  If you believe this message was received in error, please contact support."
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

    Protected Overrides Sub Render(ByVal writer As System.Web.UI.HtmlTextWriter)
        'MyBase.Render(writer)
        Dim viewStateRegex As Regex = New Regex("(<input type=""hidden"" name=""__VIEWSTATE"" id=""__VIEWSTATE"" value=""[a-zA-Z0-9\+=\\/]+"" />)", RegexOptions.Multiline Or RegexOptions.Compiled)
        Dim stringWriter As New System.IO.StringWriter()
        Dim htmlWriter As New HtmlTextWriter(stringWriter)
        MyBase.Render(htmlWriter)
        Dim html As String = stringWriter.ToString()
        Dim viewStateMatch As Match = viewStateRegex.Match(html)
        If viewStateMatch.Captures.Count > 0 Then
            Dim viewStateString As String = viewStateMatch.Captures(0).Value
            html = html.Remove(viewStateMatch.Index, viewStateMatch.Length)
        End If
        writer.Write(html)
    End Sub

    Private Sub CreateReportFile(ByRef wb As SpreadsheetGear.IWorkbook, ByVal dt As DataTable, ByVal report As Models.SPEDYReport)
        Try
            'Rename header names to remove underscores
            For Each column As DataColumn In dt.Columns
                column.ColumnName = column.ColumnName.Replace("_", " ")
            Next

            'Write Data to the First Worksheet
            Dim ws As SpreadsheetGear.IWorksheet = wb.Sheets(0)
            ws.Cells("A1").CopyFromDataTable(dt, SpreadsheetGear.Data.SetDataFlags.AllText)

            'Format the Header 
            ws.Cells(0, 0, 0, dt.Columns.Count - 1).Style.IncludeBorder = True
            ws.Cells(0, 0, 0, dt.Columns.Count - 1).Interior.Color = SpreadsheetGear.Drawing.Color.FromArgb(0, 0, 0)
            ws.Cells(0, 0, 0, dt.Columns.Count - 1).Font.Color = SpreadsheetGear.Drawing.Color.FromArgb(255, 255, 255)

            'Add Gridlines
            ws.Cells(0, 0, dt.Rows.Count, dt.Columns.Count - 1).Borders.Color = SpreadsheetGear.Drawing.Color.FromArgb(0, 0, 0)
            ws.Cells(0, 0, dt.Rows.Count, dt.Columns.Count - 1).Borders.Weight = SpreadsheetGear.BorderWeight.Thin

            'Autofit the data
            ws.Cells(0, 0, dt.Rows.Count, dt.Columns.Count - 1).Columns.AutoFit()
            For col As Integer = 0 To ws.Cells(0, 0, dt.Rows.Count, dt.Columns.Count - 1).ColumnCount - 1
                Dim columnWidth = ws.Cells(0, col).ColumnWidth * 1.15
                If columnWidth > 255 Then columnWidth = 255
                ws.Cells(0, col).ColumnWidth = columnWidth
            Next

            'Write out Report Parameters
            ws = wb.Sheets(1)
            ws.Cells("B1").Value = report.ReportName
            Dim startRow As Integer = 4
            If report.UsesStartDateParam Then
                ws.Cells("A" & startRow).Value = "Start Date: "
                Dim startDate As String = DataHelper.SmartValues(Request("startdate"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(startDate), "Not Entered", startDate)
                startRow += 1
            End If
            If report.UsesEndDateParam Then
                ws.Cells("A" & startRow).Value = "End Date: "
                Dim endDate As String = DataHelper.SmartValues(Request("enddate"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(endDate), "Not Entered", endDate)
                startRow += 1
            End If
            If report.UsesDeptParam Then
                ws.Cells("A" & startRow).Value = "Department Number: "
                Dim dept As String = DataHelper.SmartValues(Request("dept"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(dept), "All Departments", dept)
                startRow += 1
            End If
            If report.UsesWorkflowParam Then
                ws.Cells("A" & startRow).Value = "Workflow: "
                ws.Cells("B" & startRow).Value = IIf(DataHelper.SmartValues(Request("workflowID"), "CStr", False) = "1", "New Item Induction", "Item Maintenance")
                startRow += 1
            End If
            If report.UsesStageParam Then
                'Get Stage Name from DB (which is horribly overcomplicated, because WTF not??)
                Dim stageName As String = "All Active"
                Dim stageID As Integer = DataHelper.SmartValues(Request("stage"), "CInt", False)
                If stageID > 0 Then
                    Dim stages As ArrayList = New NovaLibra.Coral.Data.Michaels.BatchData().GetStageList(stageID)
                    If stages IsNot Nothing Then
                        If stages.Count > 0 Then
                            Dim wfStage As Models.WorkflowStage = stages.Item(0)
                            stageName = wfStage.StageName
                        End If
                    End If
                End If

                ws.Cells("A" & startRow).Value = "Workflow Stage: "
                ws.Cells("B" & startRow).Value = stageName
                startRow += 1
            End If
            If report.UsesVendorFilterParam Then
                ws.Cells("A" & startRow).Value = "Vendor Number: "
                Dim vendorNum As String = DataHelper.SmartValues(Request("vendorfilter"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(vendorNum), "All Vendors", vendorNum)
                startRow += 1
            End If
            If report.UsesSKUParam Then
                ws.Cells("A" & startRow).Value = "SKU: "
                Dim sku As String = DataHelper.SmartValues(Request("sku"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(sku), "All SKUs", sku)
                startRow += 1
            End If
            If report.UsesSKUGroupParam Then
                ws.Cells("A" & startRow).Value = "SKU Group: "
                Dim skuGroup As String = DataHelper.SmartValues(Request("skugroup"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(skuGroup), "All SKU Groups", skuGroup)
                startRow += 1
            End If
            If report.UsesStockCategoryParam Then
                ws.Cells("A" & startRow).Value = "Stock Category: "
                Dim stockCategory As String = DataHelper.SmartValues(Request("stockcategory"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(stockCategory), "All Categories", stockCategory)
                startRow += 1
            End If
            If report.UsesStatusParam Then
                ws.Cells("A" & startRow).Value = "Item Status: "
                Dim itemStatus As String = DataHelper.SmartValues(Request("itemstatus"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(itemStatus), "All Statuses", itemStatus)
                startRow += 1
            End If
            If report.UsesItemTypeParam Then
                ws.Cells("A" & startRow).Value = "Item Type: "
                Dim itemType As String = "All Types"
                Select Case DataHelper.SmartValues(Request("itemtype"), "CStr", False)
                    Case "1"
                        itemType = "Domestic"
                    Case "2"
                        itemType = "Import"
                End Select

                ws.Cells("B" & startRow).Value = itemType
                startRow += 1
            End If
            If report.UsesApproverParam Then
                Dim approverID As Integer = DataHelper.SmartValues(Request("approver"), "CInt", False)
                ws.Cells("A" & startRow).Value = "Approver: "
                Dim approverName As String = "All Users"
                If approverID > 0 Then
                    Dim approver As NovaLibra.Coral.SystemFrameworks.Security.UserLogin = NovaLibra.Coral.Data.Security.Security.GetSecurityUserByID(approverID)
                    approverName = approver.LastName & " " & approver.FirstName
                End If
                ws.Cells("B" & startRow).Value = approverName
                startRow += 1
            End If
            If report.UsesHoursParam Then
                ws.Cells("A" & startRow).Value = "Hours Delayed: "
                Dim hours As String = DataHelper.SmartValues(Request("hours"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(hours), "Not Entered", hours)
                startRow += 1
            End If
            If report.UsesMSSOrSPEDYParam Then
                ws.Cells("A" & startRow).Value = "MSS or SPEDY: "
                Dim mssSpedy As String = DataHelper.SmartValues(Request("mssorspedy"), "CStr", False)
                ws.Cells("B" & startRow).Value = IIf(String.IsNullOrEmpty(mssSpedy), "All", mssSpedy)
                startRow += 1
            End If
            If report.UsesPLIFrenchParam Then
                Dim pliValue As String = DataHelper.SmartValues(Request("plifrench"), "CStr", False)
                If String.IsNullOrEmpty(pliValue) Then
                    pliValue = "All Values"
                End If

                ws.Cells("A" & startRow).Value = "PLI French: "
                ws.Cells("B" & startRow).Value = pliValue
                startRow += 1
            End If
            If report.UsesPOStageParam Then
                'Get Stage Name from DB (which is horribly overcomplicated, because WTF not??)
                Dim stageName As String = "All Active"
                Dim stageID As Integer = DataHelper.SmartValues(Request("poStage"), "CInt", False)
                If stageID > 0 Then
                    Dim stages As ArrayList = New NovaLibra.Coral.Data.Michaels.BatchData().GetStageList(stageID)
                    If stages IsNot Nothing Then
                        If stages.Count > 0 Then
                            Dim wfStage As Models.WorkflowStage = stages.Item(0)
                            stageName = wfStage.StageName
                        End If
                    End If
                End If

                ws.Cells("A" & startRow).Value = "Workflow Stage: "
                ws.Cells("B" & startRow).Value = stageName
                startRow += 1
            End If


        Catch ex As Exception
            Logger.LogError(ex)
            Throw ex
        End Try
    End Sub


End Class
