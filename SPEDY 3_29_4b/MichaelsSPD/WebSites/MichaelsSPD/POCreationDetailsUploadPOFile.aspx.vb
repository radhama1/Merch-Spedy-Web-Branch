Imports System
Imports System.Configuration
Imports System.Data
Imports System.IO
Imports Microsoft.VisualBasic

Imports SpreadsheetGear
Imports SpreadsheetGear.Data
Imports SpreadsheetGear.Shapes

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports Data = NovaLibra.Coral.Data.Michaels
'Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Helper = NovaLibra.Common.Utilities.DataHelper

Partial Class _POCreationDetailsUploadPOFile
    Inherits MichaelsBasePage

    Private _purchaseOrderID As Integer = 0
    Private _refreshParent As Boolean = False
    Private _maxRowNumber As Integer = 0
    Private _maxColumnNumber As Integer = 0

    Public Property PurchaseOrderID() As Integer
        Get
            Return _purchaseOrderID
        End Get
        Set(ByVal value As Integer)
            _purchaseOrderID = value
        End Set
    End Property
    Public Property UploadID() As Integer
        Get
            Return UID.Value
        End Get
        Set(ByVal value As Integer)
            UID.Value = value
        End Set
    End Property
    Public Property RefreshParent() As Boolean
        Get
            Return _refreshParent
        End Get
        Set(ByVal value As Boolean)
            _refreshParent = value
        End Set
    End Property

    Public Property MaxRowNumber() As Integer
        Get
            Return _maxRowNumber
        End Get
        Set(ByVal value As Integer)
            _maxRowNumber = value
        End Set
    End Property

    Public Property MaxColumnNumber() As Integer
        Get
            Return _maxColumnNumber
        End Get
        Set(ByVal value As Integer)
            _maxColumnNumber = value
        End Set
    End Property

    Public ReadOnly Property UploadQueryString() As String
        Get
            Return "?POID=" & POID.Value & "&r=" & r.Value
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'Check Security
        If Not SecurityCheck() Then
            Response.Redirect("closeform.aspx")
        End If

        'Check Permission
        If Not SecurityCheckHasAccess("SPD", "SPD.ACCESS.PONEW", Session("UserID")) Then
            Response.Redirect("closeform.aspx")
        End If

        'Get POID
        If Request.QueryString("POID") IsNot Nothing Then
            POID.Value = Helper.SmartValue(Request.QueryString("POID"), "CLng", 0)
        End If
        PurchaseOrderID = POID.Value

        'Refresh Parent Page
        If Request.QueryString("r") IsNot Nothing Then
            r.Value = Helper.SmartValue(Request.QueryString("r"), "CInt", 0)
        End If
        RefreshParent = Helper.SmartValue(r.Value, "CBool", False)

    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click

        'Reset Upload ID
        UploadID = 0

        Dim wb As SpreadsheetGear.IWorkbook

        Dim file As HttpPostedFile = Request.Files.Item("importFile")

        If Not file Is Nothing Then

            Try

                'Validate File Type (.xls)
                If ExcelFileHelper.IsValidFileType(file.FileName) Then

                    'Get Stream
                    wb = SpreadsheetGear.Factory.GetWorkbookSet().Workbooks.OpenFromStream(file.InputStream)

                    'Check For Valid Template
                    If ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.POFile) Then
                        UploadPOFile(file.FileName, wb)
                    Else
                        'Error: Invalid Template
                        ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Invalid Template")
                        ShowErrorSummary()
                    End If

                Else
                    'Error: Invalid File Type
                    ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Please upload a valid Excel spreadsheet (*.xls)")
                    ShowErrorSummary()
                End If

                'Catch uploadEx As SPEDYUploadException
                '   ValidationHelper.AddValidationSummaryErrorByText(errorSummary, uploadEx.Message)
                '  ShowErrorSummary()

            Catch ex As Exception

                'ERROR: invalid file type
                ValidationHelper.AddValidationSummaryErrorByText(errorSummary, WebConstants.IMPORT_ERROR_UNKNOWN + ".   Error Returned: " + ex.Message)
                ShowErrorSummary()

            End Try

        Else
            'Error: File Is Nothing
            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "There was an error during file upload.")
            ShowErrorSummary()
        End If

    End Sub

    Public Sub UploadPOFile(ByVal fileName As String, ByVal wb As SpreadsheetGear.IWorkbook)

        'Set Maximum Column Number
        MaxColumnNumber = 6

        'Perform DataType Validation
        If ValidDataTypes(wb) Then

            Dim poCreationRec As Models.POCreationRecord = Data.POCreationData.GetRecord(PurchaseOrderID)

            'New Upload
            Dim upload As New Models.POCreationUploadRecord()
            upload.FileName = fileName
            upload.POCreationID = PurchaseOrderID
            upload.CreatedUserID = Session("UserID")

            'Determine File Type
            DetermineFileType(upload, wb)

            If upload.DetailTypeID = Models.POCreationUploadRecord.DetailType.PreAllocation AndAlso StoreDataAlreadyExists() Then

                'Cannot Upload A PreAllocation File After An Allocation File Has Been Uploaded And Applied
                ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "A Pre-Allocation file may not be used after location data has been entered online or uploaded")
                ShowErrorSummary()

            Else

                'Save Upload
                Data.POCreationUploadData.SaveRecord(upload, Session("UserID"), NovaLibra.Coral.Data.Michaels.POCreationUploadData.Hydrate.All)

                'Update Upload ID
                UploadID = upload.ID

                'Save File Contents
                SaveContentsToDB(wb)

                'Perform Business Rule Validation
                If ValidateBusinessRules(upload) Then

                    'Update Empty Values
                    UpdateEmptyValues()

                    If Not UploadRequiresUserInteraction() Then

                        'Apply Data To PO_Creation Tables
                        ApplyToPOCreation(1)

                        'Display Success To User
                        ShowSuccessSummary()

                        'Refresh Parent Page
                        RefreshParent = True

                    Else

                        'Present The User With Choices
                        LoadChangesSummary()

                    End If

                End If

            End If

        End If

    End Sub

    Public Function StoreDataAlreadyExists() As Boolean
        Return Data.POCreationUploadData.StoreCacheDataAlreadyExists(Session("UserID"), PurchaseOrderID)
    End Function

    Public Function ValidDataTypes(ByVal wb As SpreadsheetGear.IWorkbook) As Boolean

        Dim isValid As Boolean = True
        Dim ws As SpreadsheetGear.IWorksheet
        Dim range As SpreadsheetGear.IRange

        ws = wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET)
        If Not ws Is Nothing AndAlso Not ws.UsedRange Is Nothing Then

            range = ws.UsedRange

            'Loop Through Each Row To Determine What Is The Real Range
            '(Had an issue where a user highlighted past the range of data cells and treated the empty highlighted cells as part of range)

            'Loop Through Rows (Start At 1 Due To Header)
            For curRowIdx As Integer = 1 To range.RowCount - 1

                'Loop Through Columns
                For curColumnIdx As Integer = 0 To MaxColumnNumber - 1

                    'This Column Has Data So Treat It As A Data Row
                    If Helper.SmartValue(range(curRowIdx, curColumnIdx).Value, "CStr", "").Trim().Length > 0 Then
                        MaxRowNumber = curRowIdx
                        Exit For
                    End If

                Next

            Next

            'Loop Through Columns
            For curColumnIdx As Integer = 0 To MaxColumnNumber - 1

                'Loop Through Rows (Start At 1 Due To Header)
                For curRowIdx As Integer = 1 To MaxRowNumber

                    Dim curCellValue As String = Helper.SmartValue(range(curRowIdx, curColumnIdx).Value, "CStr", "").Trim()

                    Select Case curColumnIdx
                        Case WebConstants.POFileColumn.SKU
                            If curCellValue.Length = 0 Then
                                isValid = False
                                ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Row: " & curRowIdx + 1 & " Column: SKU Error: Cannot be left blank")
                            End If
                        Case WebConstants.POFileColumn.LOC
                            If curCellValue.Length > 0 Then
                                If Not IsNumeric(curCellValue) Then
                                    isValid = False
                                    ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Row: " & curRowIdx + 1 & " Column: LOC Error: Not a numeric value")
                                End If
                            End If
                        Case WebConstants.POFileColumn.QTY
                            If curCellValue.Length = 0 Then
                                isValid = False
                                ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Row: " & curRowIdx + 1 & " Column: QTY Error: Cannot be left blank")
                            ElseIf Not IsNumeric(curCellValue) Then
                                isValid = False
                                ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Row: " & curRowIdx + 1 & " Column: QTY Error: Not a numeric value")
                            End If
                        Case WebConstants.POFileColumn.COST
                            If curCellValue.Length > 0 Then
                                If Not IsNumeric(curCellValue) Then
                                    isValid = False
                                    ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Row: " & curRowIdx + 1 & " Column: COST Error: Not a valid value")
                                End If
                            End If
                        Case WebConstants.POFileColumn.IP
                            If curCellValue.Length > 0 Then
                                If Not IsNumeric(curCellValue) Then
                                    isValid = False
                                    ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Row: " & curRowIdx + 1 & " Column: IP Error: Not a valid value")
                                End If
                            End If
                        Case WebConstants.POFileColumn.MC
                            If curCellValue.Length > 0 Then
                                If Not IsNumeric(curCellValue) Then
                                    isValid = False
                                    ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Row: " & curRowIdx + 1 & " Column: MC Error: Not a valid value")
                                End If
                            End If
                    End Select

                Next

            Next

        End If

        If isValid = False Then
            fileImportPanel.Visible = True
            fileImportCustomError.Visible = True
        End If

        Return isValid

    End Function

    Public Sub DetermineFileType(ByRef upload As Models.POCreationUploadRecord, ByVal wb As SpreadsheetGear.IWorkbook)

        Dim ws As SpreadsheetGear.IWorksheet
        Dim range As SpreadsheetGear.IRange

        ws = wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET)
        If Not ws Is Nothing AndAlso Not ws.UsedRange Is Nothing Then

            range = ws.UsedRange

            'Default To PreAllocation File
            upload.DetailTypeID = Models.POCreationUploadRecord.DetailType.PreAllocation

            'Loop Through Rows (Start At 1 Due To Header)
            For curRowIdx As Integer = 1 To MaxRowNumber

                'Loop Through Columns
                For curColumnIdx As Integer = 0 To MaxColumnNumber - 1

                    'Determine Which Type Of File Based On Details
                    If curColumnIdx = WebConstants.POFileColumn.LOC Then
                        If Helper.SmartValue(range(curRowIdx, curColumnIdx).Value, "CStr", "").Trim().Length > 0 Then
                            upload.DetailTypeID = Models.POCreationUploadRecord.DetailType.Excel
                            curRowIdx = range.RowCount - 1
                            Exit For
                        End If
                    End If

                Next

            Next

        End If

    End Sub

    Public Sub SaveContentsToDB(ByVal wb As SpreadsheetGear.IWorkbook)

        Dim ws As SpreadsheetGear.IWorksheet
        Dim range As SpreadsheetGear.IRange

        ws = wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET)
        If Not ws Is Nothing AndAlso Not ws.UsedRange Is Nothing Then

            range = ws.UsedRange

            Dim SQLStr As String
            Dim cmd As SqlClient.SqlCommand

            Using conn As New SqlClient.SqlConnection(ConnectionString)

                Try

                    conn.Open()

                    'Loop Through Rows (Start At 1 Due To Header)
                    For curRowIdx As Integer = 1 To MaxRowNumber

                        SQLStr = "Insert Into PO_Creation_Upload_PO_File(PO_Creation_Upload_ID, Row_Number, SKU, Location_Number, Qty, Cost, Inner_Pack, Master_Pack)" & _
                                "Values(@PO_Creation_Upload_ID, @Row_Number, @SKU, @Location_Number, @Qty, @Cost, @Inner_Pack, @Master_Pack)"

                        cmd = New SqlClient.SqlCommand(SQLStr, conn)
                        cmd.CommandType = CommandType.Text

                        cmd.Parameters.Add("@PO_Creation_Upload_ID", SqlDbType.BigInt).Value = DataHelper.SmartValueDB(UploadID, "CLng")
                        cmd.Parameters.Add("@Row_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curRowIdx + 1, "CInt")

                        'Loop Through Columns
                        For curColumnIdx As Integer = 0 To MaxColumnNumber - 1

                            Dim curCellValue As String = DataHelper.SmartValue(range(curRowIdx, curColumnIdx).Value, "CStr", "").Trim()

                            Select Case curColumnIdx

                                Case 0 'SKU
                                    cmd.Parameters.Add("@SKU", SqlDbType.VarChar).Value = DataHelper.SmartValueDB(curCellValue, "CStr")

                                Case 1 'Location_Number
                                    cmd.Parameters.Add("@Location_Number", SqlDbType.Int).Value = DataHelper.SmartValueDB(curCellValue, "CInt")

                                Case 2 'Qty
                                    cmd.Parameters.Add("@Qty", SqlDbType.Int).Value = DataHelper.SmartValueDB(curCellValue, "CInt")

                                Case 3 'Cost
                                    cmd.Parameters.Add("@Cost", SqlDbType.Money).Value = DataHelper.SmartValueDB(curCellValue, "CDbl")

                                Case 4 'Inner Pack
                                    cmd.Parameters.Add("@Inner_Pack", SqlDbType.Int).Value = DataHelper.SmartValueDB(curCellValue, "CInt")

                                Case 5 'Master Pack
                                    cmd.Parameters.Add("@Master_Pack", SqlDbType.Int).Value = DataHelper.SmartValueDB(curCellValue, "CInt")

                            End Select

                        Next

                        'Save To DB
                        cmd.ExecuteNonQuery()

                    Next

                Catch ex As Exception

                    Logger.LogError(ex)
                    Throw ex

                Finally

                    If Not conn Is Nothing AndAlso conn.State = ConnectionState.Open Then
                        conn.Close()
                    End If

                End Try

            End Using

        End If

    End Sub

    Public Sub UpdateEmptyValues()

        'Update Empty Values With Data From Filled Values For That SKU
        Data.POCreationUploadData.UploadUpdateEmptyValues(UploadID)

    End Sub

    Public Function ValidateBusinessRules(ByRef upload As Models.POCreationUploadRecord) As Boolean

        upload.IsValid = True

        'Check For Duplicate Items
        Select Case upload.DetailTypeID
            Case Models.POCreationUploadRecord.DetailType.PreAllocation
                upload.IsValid = Not ValidationHasDuplicateSKUs()

            Case Models.POCreationUploadRecord.DetailType.Excel
                upload.IsValid = Not ValidationHasDuplicateSKULocation()
        End Select

        'Valid Items For This Vendor
        If upload.IsValid Then
            upload.IsValid = Not ValidationHasInvalidSkus()
        End If

        'Valid Item Departments User Has Access To
        If upload.IsValid Then
            upload.IsValid = Not ValidationHasInvalidItemDepts()
        End If

        If upload.IsValid AndAlso upload.DetailTypeID = Models.POCreationUploadRecord.DetailType.Excel Then

            'Valid Locations
            upload.IsValid = Not ValidationHasInvalidLocations()

            'Cost should be same for all item's locations
            If upload.IsValid Then
                upload.IsValid = Not ValidationHasCostDiffBySku()
            End If

            'IP should be same for all item's locations
            If upload.IsValid Then
                upload.IsValid = Not ValidationHasInnerPackDiffBySku()
            End If

            'MC should be same for all item's locations
            If upload.IsValid Then
                upload.IsValid = Not ValidationHasMasterPackDiffBySku()
            End If

        End If

        'Save To DB
        Data.POCreationUploadData.SaveRecord(upload, Session("UserID"))

        Return upload.IsValid

    End Function

    Public Function ValidationHasDuplicateSKUs() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasDuplicates As Boolean = Data.POCreationUploadData.UploadHasDuplicateSkus(UploadID, vRec)

        If hasDuplicates Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasDuplicates

    End Function

    Public Function ValidationHasDuplicateSKULocation() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasDuplicates As Boolean = Data.POCreationUploadData.UploadHasDuplicateSkuLocation(UploadID, vRec)

        If hasDuplicates Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasDuplicates

    End Function

    Public Function ValidationHasInvalidSkus() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasInvalidSkus As Boolean = Data.POCreationUploadData.UploadHasInvalidSkus(UploadID, vRec)

        If hasInvalidSkus Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasInvalidSkus

    End Function

    Public Function ValidationHasInvalidItemDepts() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasInvalidItemDepts As Boolean = Data.POCreationUploadData.UploadHasInvalidItemDepts(UploadID, Session("UserID"), vRec)

        If hasInvalidItemDepts Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasInvalidItemDepts

    End Function

    Public Function ValidationHasInvalidLocations() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasInvalidLocations As Boolean = Data.POCreationUploadData.UploadHasInvalidLocations(UploadID, vRec)

        If hasInvalidLocations Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasInvalidLocations

    End Function

    Public Function ValidationHasCostDiffBySku() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasDiffs As Boolean = Data.POCreationUploadData.UploadHasCostDiffBySku(UploadID, vRec)

        If hasDiffs Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasDiffs

    End Function

    Public Function ValidationHasInnerPackDiffBySku() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasDiffs As Boolean = Data.POCreationUploadData.UploadHasInnerPackDiffBySku(UploadID, vRec)

        If hasDiffs Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasDiffs

    End Function

    Public Function ValidationHasMasterPackDiffBySku() As Boolean

        Dim vRec As New Models.ValidationRecord

        Dim hasDiffs As Boolean = Data.POCreationUploadData.UploadHasMasterPackDiffBySku(UploadID, vRec)

        If hasDiffs Then
            ValidationHelper.AddValidationSummaryErrors(errorSummary, vRec)
            ShowErrorSummary()
        End If

        Return hasDiffs

    End Function

    Public Function UploadRequiresUserInteraction() As Boolean

        Return Data.POCreationUploadData.SKUCacheDataAlreadyExists(Session("UserID"), PurchaseOrderID)

    End Function

    Public Sub LoadChangesSummary()

        LoadChangesSummaryDataInFileNotOnPO()

        LoadChangesSummaryDataInBothFileAndPO()

        LoadChangesSummaryDataInPONotInFile()

        'Make Visible
        ShowDiffSummary()

    End Sub

    Public Sub LoadChangesSummaryDataInFileNotOnPO()

        Dim sb As New StringBuilder()
        Dim list As ArrayList = Data.POCreationUploadData.UploadGetDataInFileNotOnPO(UploadID)

        sb.AppendLine("<table id=""DiffNewDataTable"" cellpadding=""2"" cellspacing=""2"">")
        If list.Count = 0 Then
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"">Data In File That Is Not In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td>No Data</td></td>")
        Else
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""6"">Data In File That Is Not In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td>SKU</td><td>LOC</td><td>QTY</td><td>COST</td><td>IP</td><td>MC</td></tr>")
            For Each item As String In list
                sb.AppendLine("<tr><td>" & Replace(item, "[COLDELIM]", "</td><td>") & "</td></tr>")
            Next

        End If

        sb.AppendLine("</table>")
        DiffNewData.InnerHtml = sb.ToString()

    End Sub

    Public Sub LoadChangesSummaryDataInBothFileAndPO()

        Dim sb As New StringBuilder()
        Dim list As ArrayList = Data.POCreationUploadData.UploadGetDataInFileAndInPO(UploadID)

        sb.AppendLine("<table id=""DiffModifyDataTable"" cellpadding=""2"" cellspacing=""2"">")
        If list.Count = 0 Then
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"">Data In File That Is Also In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td>No Data</td></td>")
        Else
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""12"">Data In File That Is Also In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""6"">Purchase Order Data</td><td class=""formLabel subHeading navyTextBold"" colspan=""6"">File Data</td></tr>")
            sb.AppendLine("<tr><td>SKU</td><td>LOC</td><td>QTY</td><td>COST</td><td>IP</td><td>MC</td><td>SKU</td><td>LOC</td><td>QTY</td><td>COST</td><td>IP</td><td>MC</td></tr>")
            For Each item As String In list
                sb.AppendLine("<tr><td>" & Replace(item, "[COLDELIM]", "</td><td>") & "</td></tr>")
            Next

        End If

        sb.AppendLine("</table>")
        DiffModifyData.InnerHtml = sb.ToString()

    End Sub

    Public Sub LoadChangesSummaryDataInPONotInFile()

        Dim sb As New StringBuilder()
        Dim list As ArrayList = Data.POCreationUploadData.UploadGetDataInPONotInFile(UploadID)

        sb.AppendLine("<table id=""DiffOldDataTable"" cellpadding=""2"" cellspacing=""2"">")
        If list.Count = 0 Then
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"">Data In Purchase Order That Is Not In File<td><tr>")
            sb.AppendLine("<tr><td>No Data</td></td>")
        Else
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""6"">Data In Purchase Order That Is Not In File<td><tr>")
            sb.AppendLine("<tr><td>SKU</td><td>LOC</td><td>QTY</td><td>COST</td><td>IP</td><td>MC</td></tr>")
            For Each item As String In list
                sb.AppendLine("<tr><td>" & Replace(item, "[COLDELIM]", "</td><td>") & "</td></tr>")
            Next

        End If

        sb.AppendLine("</table>")
        DiffOldData.InnerHtml = sb.ToString()

    End Sub

    Public Sub ApplyToPOCreation(ByVal pChoice As Integer)

        If pChoice = 0 Then
            ProcessChanges()
        ElseIf pChoice = 1 Then
            ReplaceExistingData()
        End If

        'Save In DB
        Dim upload As Models.POCreationUploadRecord = Data.POCreationUploadData.GetRecord(UploadID)
        upload.AppliedToPO = True

        Data.POCreationUploadData.SaveRecord(upload, Session("UserID"))

        'Update Totals
        Data.POCreationLocationSKUData.UpdateSKUCacheTotalsByPOID(_purchaseOrderID, Session("UserID"))

    End Sub

    Public Sub ShowErrorSummary()
        fileImportPanel.Visible = False
        fileDifferences.Visible = False
        fileImportCustomError.Visible = True
    End Sub

    Public Sub ShowDiffSummary()
        fileImportPanel.Visible = False
        fileImportCustomError.Visible = False
        fileDifferences.Visible = True
    End Sub

    Public Sub ShowSuccessSummary()
        fileImportPanel.Visible = False
        fileDifferences.Visible = False
        fileImportSuccess.Visible = True
    End Sub

    Protected Sub ProcessDiffBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles ProcessDiffBtn.Click

        'Apply File Data To Purchase Order
        ApplyToPOCreation(DataHelper.SmartValue(DiffChoice.SelectedValue, "CInt", 0))

        'Show Completed Message To User
        ShowSuccessSummary()

        'Refresh Parent Page
        RefreshParent = True

    End Sub

    Public Sub ProcessChanges()

        Data.POCreationUploadData.UploadProcessChangesOnly(UploadID)

    End Sub

    Public Sub ReplaceExistingData()

        Data.POCreationUploadData.UploadReplaceExistingData(UploadID)

    End Sub

End Class


