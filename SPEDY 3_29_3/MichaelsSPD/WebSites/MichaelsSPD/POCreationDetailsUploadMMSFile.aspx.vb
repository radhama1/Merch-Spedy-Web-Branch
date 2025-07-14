Imports System
Imports System.Configuration
Imports System.Data
Imports System.IO
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic

Imports SpreadsheetGear
Imports SpreadsheetGear.Data
Imports SpreadsheetGear.shapes

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports Data = NovaLibra.Coral.Data.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Helper = NovaLibra.Common.Utilities.DataHelper



Partial Class _POCreationDetailsUploadMMSFile
    Inherits MichaelsBasePage

    Private _purchaseOrderID As Integer = 0
    Private _refreshParent As Boolean = False

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

        Dim file As HttpPostedFile = Request.Files.Item("importFile")

        If Not file Is Nothing Then

            Try

                Dim strAL As ArrayList = ConvertStreamToStringArray(file.InputStream)

                UploadPOFile(file.FileName, strAL)

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

    Public Function ConvertStreamToStringArray(ByVal fStream As System.IO.Stream) As ArrayList

        Dim sArray As New ArrayList

        Using sr As New StreamReader(fStream)

            Dim line As String = sr.ReadLine()

            While Not line Is Nothing

                sArray.Add(line)
                line = sr.ReadLine()

            End While

        End Using

        Return sArray

    End Function

    Public Sub UploadPOFile(ByVal fileName As String, ByVal strArrayList As ArrayList)

        'Perform DataType Validation
        If ValidDataTypes(strArrayList) Then

            'New Upload
            Dim upload As New Models.POCreationUploadRecord()
            upload.FileName = fileName
            upload.POCreationID = PurchaseOrderID
            upload.CreatedUserID = Session("UserID")
            upload.DetailTypeID = Models.POCreationUploadRecord.DetailType.MMS

            'Save Upload
            Data.POCreationUploadData.SaveRecord(upload, Session("UserID"), NovaLibra.Coral.Data.Michaels.POCreationUploadData.Hydrate.All)

            'Update Upload ID
            UploadID = upload.ID

            'Save File Contents
            SaveContentsToDB(strArrayList)

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

    End Sub

    Public Function ValidDataTypes(ByVal fileData As ArrayList) As Boolean

        Dim isValid As Boolean = True

        Dim curLineNumber = 0
        Dim curSKU As String = ""
        Dim curLocation As String
        Dim curQty As String

        For Each line As String In fileData

            If Not line Is Nothing Then

                Dim lineContentsArray() As String = line.Replace("""", "").Split(Convert.ToChar(","))
                curLineNumber += 1

                Select Case lineContentsArray(0)

                    Case "S"
                        curSKU = Helper.SmartValue(lineContentsArray(1), "CStr", "").Trim()
                        If curSKU.Length = 0 Then
                            isValid = False
                            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Line Number: " & curLineNumber & " Error: SKU cannot be left blank")
                        End If

                    Case "A"

                        If curSKU.Length = 0 Then
                            isValid = False
                            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Line Number: " & curLineNumber & " Error: SKU has not been set for this line number")
                        End If

                        curLocation = Helper.SmartValue(lineContentsArray(1), "CStr", "").Trim()
                        If curLocation.Length = 0 Then
                            isValid = False
                            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Line Number: " & curLineNumber & " Error: Location cannot be left blank")
                        ElseIf Not IsNumeric(curLocation) Then
                            isValid = False
                            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Line Number: " & curLineNumber & " Error: Location is not a numeric value")
                        End If

                        curQty = Helper.SmartValue(lineContentsArray(2), "CStr", "").Trim()
                        If curQty.Length = 0 Then
                            isValid = False
                            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Line Number: " & curLineNumber & " Error: Qty cannot be left blank")
                        ElseIf Not IsNumeric(curQty) Then
                            isValid = False
                            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "Line Number: " & curLineNumber & " Error: Qty is not a numeric value")
                        End If

                End Select

            End If

        Next

        If curLineNumber = 0 Then
            isValid = False
            ValidationHelper.AddValidationSummaryErrorByText(errorSummary, "No data found in this file")
        End If

        If isValid = False Then
            ShowErrorSummary()
        End If

        Return isValid

    End Function

    Public Sub SaveContentsToDB(ByVal fileData As ArrayList)

        Dim curLineNumber As Integer = 0
        Dim curSKULineNumber As Integer = 0
        Dim curSKU As String = ""
        Dim curLocation As String
        Dim curQty As String

        'Construct Bulk Insert Table
        Dim uploadDataTable As DataTable = New DataTable
        uploadDataTable.Columns.Add("ID", GetType(Int64))
        uploadDataTable.Columns.Add("PO_Creation_Upload_ID", GetType(Int64))
        uploadDataTable.Columns.Add("Row_Number", GetType(Int32))
        uploadDataTable.Columns.Add("SKU", GetType(String))
        uploadDataTable.Columns.Add("Location_Number", GetType(String))
        uploadDataTable.Columns.Add("Qty", GetType(Int32))
        uploadDataTable.Columns.Add("Cost", GetType(Decimal))
        uploadDataTable.Columns.Add("Inner_Pack", GetType(Int32))
        uploadDataTable.Columns.Add("Master_Pack", GetType(Int32))
        uploadDataTable.Columns.Add("SKU_Row_Number", GetType(Int32))

        For Each line As String In fileData

            curLineNumber += 1
            If Not line Is Nothing Then

                Dim lineContentsArray() As String = line.Replace("""", "").Split(Convert.ToChar(","))

                Select Case lineContentsArray(0)

                    Case "S"
                        curSKULineNumber = curLineNumber
                        curSKU = Helper.SmartValue(lineContentsArray(1), "CStr", "").Trim()

                    Case "A"

                        curLocation = Helper.SmartValue(lineContentsArray(1), "CStr", "").Trim()
                        curQty = Helper.SmartValue(lineContentsArray(2), "CStr", "").Trim()

                        uploadDataTable.Rows.Add(Nothing, DataHelper.SmartValueDB(UploadID, "CLng"), DataHelper.SmartValueDB(curLineNumber, "CInt"), DataHelper.SmartValueDB(curSKU, "CStr"), DataHelper.SmartValueDB(curLocation, "CInt"), DataHelper.SmartValueDB(curQty, "CInt"), Nothing, Nothing, Nothing, DataHelper.SmartValueDB(curSKULineNumber, "CInt"))

                End Select

            End If
        Next

        'Bulk Copy the PO data into the upload table
        Dim sqlBulkCopy As SqlBulkCopy = New SqlBulkCopy(ConnectionString)
        Try
            sqlBulkCopy.BulkCopyTimeout = 1800
            sqlBulkCopy.DestinationTableName = "PO_Creation_Upload_PO_File"
            sqlBulkCopy.WriteToServer(uploadDataTable)

        Catch ex As Exception
            Logger.LogError(ex)
            Throw ex
        Finally
            sqlBulkCopy.Close()
        End Try

        uploadDataTable = Nothing

    End Sub

    Public Function ValidateBusinessRules(ByRef upload As Models.POCreationUploadRecord) As Boolean

        upload.IsValid = True

        'Check For Duplicate Items
        upload.IsValid = Not ValidationHasDuplicateSKULocation()

        'Valid Items For This Vendor
        If upload.IsValid Then
            upload.IsValid = Not ValidationHasInvalidSkus()
        End If

        'Valid Item Departments User Has Access To
        If upload.IsValid Then
            upload.IsValid = Not ValidationHasInvalidItemDepts()
        End If

        If upload.IsValid Then

            'Valid Locations
            upload.IsValid = Not ValidationHasInvalidLocations()

        End If

        'Save To DB
        Data.POCreationUploadData.SaveRecord(upload, Session("UserID"))

        Return upload.IsValid

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

    Public Function UploadRequiresUserInteraction() As Boolean

        Return Data.POCreationUploadData.StoreCacheDataAlreadyExists(Session("UserID"), PurchaseOrderID)

    End Function

    Public Sub UpdateEmptyValues()

        'Update Empty Values With Data From Filled Values For That SKU
        Data.POCreationUploadData.UploadUpdateEmptyValues(UploadID)

    End Sub

    Public Sub LoadChangesSummary()

        LoadChangesSummaryDataInFileNotOnPO()

        LoadChangesSummaryDataInBothFileAndPO()

        LoadChangesSummaryDataInPONotInFile()

        LoadChangesSummaryDataNewSKULevelData()

        'Make Visible
        ShowDiffSummary()

    End Sub

    Public Sub LoadChangesSummaryDataInFileNotOnPO()

        Dim sb As New StringBuilder()
        Dim list As ArrayList = Data.POCreationUploadData.UploadGetDataInMMSFileNotOnPO(UploadID)

        sb.AppendLine("<table id=""DiffNewDataTable"" cellpadding=""2"" cellspacing=""2"">")
        If list.Count = 0 Then
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"">Data In File That Is Not In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td>No Data</td></td>")
        Else
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""3"">Data In File That Is Not In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td>SKU</td><td>LOC</td><td>QTY</td></tr>")
            For Each item As String In list
                sb.AppendLine("<tr><td>" & Replace(item, "[COLDELIM]", "</td><td>") & "</td></tr>")
            Next

        End If

        sb.AppendLine("</table>")
        DiffNewData.InnerHtml = sb.ToString()

    End Sub

    Public Sub LoadChangesSummaryDataInBothFileAndPO()

        Dim sb As New StringBuilder()
        Dim list As ArrayList = Data.POCreationUploadData.UploadGetDataInMMSFileAndInPO(UploadID)

        sb.AppendLine("<table id=""DiffModifyDataTable"" cellpadding=""2"" cellspacing=""2"">")
        If list.Count = 0 Then
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"">Data In File That Is Also In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td>No Data</td></td>")
        Else
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""6"">Data In File That Is Also In Purchase Order<td><tr>")
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""3"">Purchase Order Data</td><td class=""formLabel subHeading navyTextBold"" colspan=""3"">File Data</td></tr>")
            sb.AppendLine("<tr><td>SKU</td><td>LOC</td><td>QTY</td><td>SKU</td><td>LOC</td><td>QTY</td></tr>")
            For Each item As String In list
                sb.AppendLine("<tr><td>" & Replace(item, "[COLDELIM]", "</td><td>") & "</td></tr>")
            Next

        End If

        sb.AppendLine("</table>")
        DiffModifyData.InnerHtml = sb.ToString()

    End Sub

    Public Sub LoadChangesSummaryDataInPONotInFile()

        Dim sb As New StringBuilder()
        Dim list As ArrayList = Data.POCreationUploadData.UploadGetDataInPONotInMMSFile(UploadID)

        sb.AppendLine("<table id=""DiffOldDataTable"" cellpadding=""2"" cellspacing=""2"">")
        If list.Count = 0 Then
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"">Data In Purchase Order That Is Not In File<td><tr>")
            sb.AppendLine("<tr><td>No Data</td></td>")
        Else
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""3"">Data In Purchase Order That Is Not In File<td><tr>")
            sb.AppendLine("<tr><td>SKU</td><td>LOC</td><td>QTY</td></tr>")
            For Each item As String In list
                sb.AppendLine("<tr><td>" & Replace(item, "[COLDELIM]", "</td><td>") & "</td></tr>")
            Next

        End If

        sb.AppendLine("</table>")
        DiffOldData.InnerHtml = sb.ToString()

    End Sub

    Public Sub LoadChangesSummaryDataNewSKULevelData()

        Dim sb As New StringBuilder()
        Dim list As ArrayList = Data.POCreationUploadData.UploadGetNewSKULevelData(UploadID)

        If list.Count > 0 Then

            sb.AppendLine("<table id=""DiffOldDataTable"" cellpadding=""2"" cellspacing=""2"">")
            sb.AppendLine("<tr><td class=""formLabel subHeading navyTextBold"" colspan=""6"">SKU level data to be added<td><tr>")
            sb.AppendLine("<tr><td>SKU</td><td>UPC</td><td>ORDERED QTY</td><td>COST</td><td>IP</td><td>MP</td></tr>")
            For Each item As String In list
                sb.AppendLine("<tr><td>" & Replace(item, "[COLDELIM]", "</td><td>") & "</td></tr>")
            Next
            sb.AppendLine("</table>")
            DiffSKULevelData.InnerHtml = sb.ToString()

            DiffSKULevelData.Visible = True

        End If

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


