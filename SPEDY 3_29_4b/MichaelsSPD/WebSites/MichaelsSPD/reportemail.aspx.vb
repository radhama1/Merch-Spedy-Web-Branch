Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Common

Partial Class reportemail
    Inherits System.Web.UI.Page


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("login.aspx")
        End If
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long", False)

        Try

            Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsReport()
            Dim reportID As Long = DataHelper.SmartValues(Request("id"), "long", False)
            Dim report As Models.SPEDYReport = objMichaels.GetReport(reportID)

            Dim rq As New Models.ReportQueue
            rq.Enabled = True
            rq.EmailRecipients = Session("Email_Address")
            rq.IsReoccurring = False
            rq.ReportID = report.ID
            rq.ReportParameters = CreateParameters(report)

            NovaLibra.Coral.Data.Michaels.ReportQueueData.Save(rq)

            ltlOutput.Text = "<p>Your report will be emailed to " & rq.EmailRecipients & " when it has finished processing.  Thank you!</p>"

        Catch ex As Exception
            Logger.LogError(ex)
            ltlOutput.Text = "<p>There was a problem emailing your report.  Please contact the system administrator for assistance.</p> <p>" & ex.Message & "</p>"
        End Try

    End Sub

    Private Function CreateParameters(ByVal report As Models.SPEDYReport) As String
        Dim reportParameters As New StringBuilder("")

        If report.UsesStartDateParam Then
            reportParameters.Append("@startDate=" & IIf(String.IsNullOrEmpty(Request("startdate")), "null", Request("startdate")) & "|")
        End If
        If report.UsesEndDateParam Then
            reportParameters.Append("@endDate=" & IIf(String.IsNullOrEmpty(Request("enddate")), "null", Request("enddate")) & "|")
        End If
        If report.UsesDeptParam Then
            reportParameters.Append("@dept=" & IIf(String.IsNullOrEmpty(Request("dept")), "null", Request("dept")) & "|")
        End If
        If report.UsesWorkflowParam Then
            reportParameters.Append("@workflowID=" & IIf(String.IsNullOrEmpty(Request("workflowid")), "null", Request("workflowid")) & "|")
        End If
        If report.UsesStageParam Then
            reportParameters.Append("@stage=" & IIf(String.IsNullOrEmpty(Request("stage")), "null", Request("stage")) & "|")
        End If
        If report.UsesVendorParam Then
            reportParameters.Append("@vendor=" & IIf(AppHelper.GetVendorID() = 0, "null", AppHelper.GetVendorID()) & "|")
        End If
        If report.UsesVendorFilterParam Then
            reportParameters.Append("@vendorFilter=" & IIf(String.IsNullOrEmpty(Request("vendorfilter")), "null", Request("vendorfilter")) & "|")
        End If
        If report.UsesStatusParam Then
            reportParameters.Append("@itemStatus=" & IIf(String.IsNullOrEmpty(Request("itemstatus")), "null", Request("itemstatus")) & "|")
        End If
        If report.UsesSKUParam Then
            reportParameters.Append("@sku=" & IIf(String.IsNullOrEmpty(Request("sku")), "null", Request("sku")) & "|")
        End If
        If report.UsesSKUGroupParam Then
            reportParameters.Append("@itemGroup=" & IIf(String.IsNullOrEmpty(Request("skugroup")), "null", Request("skugroup")) & "|")
        End If
        If report.UsesStockCategoryParam Then
            reportParameters.Append("@stockCategory=" & IIf(String.IsNullOrEmpty(Request("stockcategory")), "null", Request("stockcategory")) & "|")
        End If
        If report.UsesItemTypeParam Then
            reportParameters.Append("@itemType=" & IIf(String.IsNullOrEmpty(Request("itemtype")), "null", Request("itemtype")) & "|")
        End If
        If report.UsesApproverParam Then
            reportParameters.Append("@approver=" & IIf(String.IsNullOrEmpty(Request("approver")), "null", Request("approver")) & "|")
        End If
        If report.UsesHoursParam Then
            reportParameters.Append("@hours=" & IIf(String.IsNullOrEmpty(Request("hours")), "null", Request("hours")) & "|")
        End If
        If report.UsesMSSOrSPEDYParam Then
            reportParameters.Append("@mssOrSpedy=" & IIf(String.IsNullOrEmpty(Request("mssorspedy")), "null", Request("mssorspedy")) & "|")
        End If
        If report.UsesPLIFrenchParam Then
            reportParameters.Append("@pliFrench=" & IIf(String.IsNullOrEmpty(Request("plifrench")), "null", Request("plifrench")) & "|")
        End If
        If report.UsesPOStockCategoryParam Then
            reportParameters.Append("@poStockCategory=" & IIf(String.IsNullOrEmpty(Request("poStockCategory")), "null", Request("poStockCategory")) & "|")
        End If
        If report.UsesPOStatusParam Then
            reportParameters.Append("@poStatus=" & IIf(String.IsNullOrEmpty(Request("poStatus")), "null", Request("poStatus")) & "|")
        End If
        If report.UsesPOTypeParam Then
            reportParameters.Append("@poType=" & IIf(String.IsNullOrEmpty(Request("poType")), "null", Request("poType")) & "|")
        End If
        If report.UsesPOStageParam Then
            reportParameters.Append("@poStage=" & IIf(String.IsNullOrEmpty(Request("poStage")), "null", Request("poStage")) & "|")
        End If


        'Remove trailing '|' character
        reportParameters.Length = reportParameters.Length - 1

        Return reportParameters.ToString
    End Function

End Class
