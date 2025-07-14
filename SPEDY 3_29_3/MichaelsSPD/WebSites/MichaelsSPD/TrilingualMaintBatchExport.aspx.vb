Imports System
Imports System.Data
Imports System.IO
Imports SpreadsheetGear

Imports WebConstants
Imports NovaLibra.Coral.SystemFrameworks
Imports NovaLibra.Common.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class TrilingualMaintBatchExport
    Inherits MichaelsBasePage


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Dim batchID As Long = DataHelper.SmartValues(Request("bid"), "CInt", False, 0)
        If batchID <= 0 Then
            Response.Redirect("detail.aspx")
        End If

        Dim returnAddress As String = GetReturnAddress()

        lblFeedback.Visible = False
        lnkReturn.NavigateUrl = returnAddress
        lnkReturn.Visible = False

        If Not IsPostBack Then
            BuildExportFile(batchID)
        End If

    End Sub

    Private Function GetReturnAddress() As String
        Dim ret As String = "default.aspx"
        Dim sRet As String = Session("_XLS_BATCH_EXPORT_RETURN_") & ""
        If sRet.Length > 0 Then
            ret = sRet
        End If
        Return ret
    End Function

    Private Sub BuildExportFile(ByVal batchID As Long)
        Try

            Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batch As Models.BatchRecord = batchDB.GetBatchRecord(batchID)
            Dim batchType As Integer = batch.BatchTypeID

            Dim wb As SpreadsheetGear.IWorkbook = Nothing
            Select Case batchType
                Case Models.BatchType.TrilingualTranslations
                    wb = BuildTranslationExportFile(batch)
                Case Models.BatchType.TrilingualExemptions
                    wb = BuildExemptionExportFile(batch)
            End Select

            If Not wb Is Nothing Then
                ' success! export the workbook
                Dim dateNow As Date = Now()
                Dim fName As String = "TrilingualMaintExport_" & batchID.ToString() & "_" & dateNow.ToString("yyyyMMdd") & ".xls"
                Dim memFile As New MemoryStream()
                wb.SaveToStream(memFile, FileFormat.Excel8)
                memFile.WriteTo(Response.OutputStream)
                memFile = Nothing
                Response.ContentType = "application/vnd.ms-excel"
                Response.AddHeader("content-disposition", ("attachment;filename=" & fName))
                HttpContext.Current.ApplicationInstance.CompleteRequest()
            Else
                ' the query failed to retrieve any data
                lblFeedback.Text = "This batch could not be formatted."
                lblFeedback.Visible = True
                lnkReturn.Text = "Click here to go back."
                lnkReturn.Visible = True
            End If
        Catch ex As Exception
            Dim s As String = ex.Message
        End Try
    End Sub

    Private Function BuildExemptionExportFile(ByVal batch As Models.BatchRecord) As IWorkbook
        Dim wb As SpreadsheetGear.IWorkbook = SpreadsheetGear.Factory.GetWorkbook()
        Dim ws As SpreadsheetGear.IWorksheet = wb.Worksheets("Sheet1")

        'Build the list of Column Headers
        ws.Cells(0, 0).Value = "SKU"
        ws.Cells(0, 1).Value = "Vendor Number"
        ws.Cells(0, 2).Value = "Package Language Indicator English (OLD)"
        ws.Cells(0, 3).Value = "Package Language Indicator English (NEW)"
        ws.Cells(0, 4).Value = "Package Language Indicator French (OLD)"
        ws.Cells(0, 5).Value = "Package Language Indicator French (NEW)"
        ws.Cells(0, 6).Value = "Package Language Indicator Spanish (OLD)"
        ws.Cells(0, 7).Value = "Package Language Indicator Spanish (NEW)"
        ws.Cells(0, 8).Value = "Exempt End Date (OLD)"
        ws.Cells(0, 9).Value = "Exempt End Date (NEW)"

        'Get Lists of batch items and their changes
        Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
        Dim dtChanges As DataTable = batchDB.GetItemMaintBatchExport(batch.ID)
        Dim dtItems As DataTable = batchDB.GetItemMaintBatchItemList(batch.ID)
        Dim masterDtl As Models.ItemMaintItemDetailFormRecord

        If (Not dtChanges Is Nothing) And (Not dtItems Is Nothing) Then

            ' build the list of items
            Dim currentRowNum As Integer = 1
            For i As Integer = 0 To dtItems.Rows.Count - 1
                Dim thisIMIID As String = dtItems.Rows(i)("item_maint_items_id").ToString.Trim
                Dim thisSKU As String = dtItems.Rows(i)("Michaels_SKU").ToString.Trim
                Dim thisSKUID As String = dtItems.Rows(i)("SKU_ID").ToString.Trim

                'Get Item Information
                masterDtl = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(thisIMIID, 0)

                'Write out SKU and Vendor Number
                ws.Cells(currentRowNum, 0).Value = thisSKU
                ws.Cells(currentRowNum, 1).Value = masterDtl.VendorNumber

                'Write out Original Values
                ws.Cells(currentRowNum, 2).Value = FormatYesNo(masterDtl.PLIEnglish.Trim)
                ws.Cells(currentRowNum, 4).Value = FormatYesNo(masterDtl.PLIFrench.Trim)
                ws.Cells(currentRowNum, 6).Value = FormatYesNo(masterDtl.PLISpanish.Trim)
                ws.Cells(currentRowNum, 8).Value = masterDtl.ExemptEndDateFrench

                'Get and write out change values
                Dim dtItemChanges As DataTable = batchDB.GetItemMaintBatchChangeList(thisIMIID)
                If Not dtItemChanges Is Nothing Then
                    For j As Integer = 0 To dtItemChanges.Rows.Count - 1
                        Dim thisFieldName As String = dtItemChanges.Rows(j)("field_name").ToString.Trim
                        Dim thisFieldValue As String = dtItemChanges.Rows(j)("field_value").ToString.Trim

                        Select Case thisFieldName.ToUpper
                            Case "PLIENGLISH"
                                ws.Cells(currentRowNum, 3).Value = FormatYesNo(thisFieldValue)
                            Case "PLIFRENCH"
                                ws.Cells(currentRowNum, 5).Value = FormatYesNo(thisFieldValue)
                            Case "PLISPANISH"
                                ws.Cells(currentRowNum, 7).Value = FormatYesNo(thisFieldValue)
                            Case "EXEMPTENDDATEFRENCH"
                                ws.Cells(currentRowNum, 9).Value = thisFieldValue
                        End Select
                    Next
                End If

                currentRowNum = currentRowNum + 1
            Next
        End If

        Return wb
    End Function

    Private Function BuildTranslationExportFile(ByVal batch As Models.BatchRecord) As IWorkbook
        Dim wb As SpreadsheetGear.IWorkbook = SpreadsheetGear.Factory.GetWorkbook()
        Dim ws As SpreadsheetGear.IWorksheet = wb.Worksheets("Sheet1")

        'Build the list of Column Headers
        ws.Cells(0, 0).Value = "SKU"
        ws.Cells(0, 1).Value = "SKU Description (OLD)"
        ws.Cells(0, 2).Value = "SKU Description (NEW)"
        ws.Cells(0, 3).Value = "Translation Indicator - French (OLD)"
        ws.Cells(0, 4).Value = "Translation Indicator - French (NEW)"
        ws.Cells(0, 5).Value = "English Short Description (OLD)"
        ws.Cells(0, 6).Value = "English Short Description (NEW)"
        ws.Cells(0, 7).Value = "English Long Description (OLD)"
        ws.Cells(0, 8).Value = "English Long Description (NEW)"

        'Get Lists of batch items and their changes
        Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
        Dim dtChanges As DataTable = batchDB.GetItemMaintBatchExport(batch.ID)
        Dim dtItems As DataTable = batchDB.GetItemMaintBatchItemList(batch.ID)
        Dim masterDtl As Models.ItemMaintItemDetailFormRecord

        If (Not dtChanges Is Nothing) And (Not dtItems Is Nothing) Then

            ' build the list of items
            Dim currentRowNum As Integer = 1
            For i As Integer = 0 To dtItems.Rows.Count - 1
                Dim thisIMIID As String = dtItems.Rows(i)("item_maint_items_id").ToString.Trim
                Dim thisSKU As String = dtItems.Rows(i)("Michaels_SKU").ToString.Trim
                Dim thisSKUID As String = dtItems.Rows(i)("SKU_ID").ToString.Trim

                'Get Item Information
                masterDtl = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(thisIMIID, 0)

                'Write out SKU
                ws.Cells(currentRowNum, 0).Value = thisSKU

                'Write out Original Values
                ws.Cells(currentRowNum, 1).Value = masterDtl.ItemDesc.Trim
                ws.Cells(currentRowNum, 3).Value = FormatYesNo(masterDtl.TIFrench.Trim)
                ws.Cells(currentRowNum, 5).Value = masterDtl.EnglishShortDescription.Trim
                ws.Cells(currentRowNum, 7).Value = masterDtl.EnglishLongDescription.Trim

                'Get and write out change values
                Dim dtItemChanges As DataTable = batchDB.GetItemMaintBatchChangeList(thisIMIID)
                If Not dtItemChanges Is Nothing Then
                    For j As Integer = 0 To dtItemChanges.Rows.Count - 1
                        Dim thisFieldName As String = dtItemChanges.Rows(j)("field_name").ToString.Trim
                        Dim thisFieldValue As String = dtItemChanges.Rows(j)("field_value").ToString.Trim

                        Select Case thisFieldName.ToUpper
                            Case "ITEMDESC"
                                ws.Cells(currentRowNum, 2).Value = thisFieldValue
                            Case "TIFRENCH"
                                ws.Cells(currentRowNum, 4).Value = FormatYesNo(thisFieldValue)
                            Case "ENGLISHSHORTDESCRIPTION"
                                ws.Cells(currentRowNum, 6).Value = thisFieldValue
                            Case "ENGLISHLONGDESCRIPTION"
                                ws.Cells(currentRowNum, 8).Value = thisFieldValue
                        End Select
                    Next
                End If

                currentRowNum = currentRowNum + 1
            Next
        End If

        Return wb
    End Function

    Private Function FormatYesNo(ByVal value As String) As String
        Select Case value.ToUpper
            Case "Y"
                Return "YES"
            Case "N"
                Return "NO"
            Case Else
                Return ""
        End Select
    End Function
End Class
