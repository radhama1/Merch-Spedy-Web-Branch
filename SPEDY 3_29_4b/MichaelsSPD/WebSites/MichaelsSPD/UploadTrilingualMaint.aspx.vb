Imports System
Imports System.Configuration
Imports System.Data
Imports System.Diagnostics
Imports System.IO
Imports Microsoft.VisualBasic
Imports System.Data.SqlClient
Imports SpreadsheetGear
Imports System.Collections.Generic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports Frameworks = NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports NLData = NovaLibra.Coral.Data

Partial Class UploadTrilingualMaint
    Inherits MichaelsBasePage

#Region " Data and Properties "

    Private _refreshParent As Boolean = False
    Private _sendToDefault As Boolean = False
    Private _useSessionVendor As Boolean = False
    Private _xlFileName As String = String.Empty

    Private _feedbackMsg As String = String.Empty
    Private _cancelBatch As Boolean = False

    'Column Header locations
    Private _skuColumn As Integer = 1
    Private _tiFrenchColumn As Integer = 0
    Private _englishShortDescColumn As Integer = 0
    Private _englishLongDescColumn As Integer = 0
    Private _supplierColumn As Integer = 0
    Private _pliFrenchColumn As Integer = 0
    Private _pliSpanishColumn As Integer = 0
    Private _exemptEndDateColumn As Integer = 0
    Private _skuDescriptionColumn As Integer = 0

    Private _validSKUList As List(Of SkuList)

    Private _table As Frameworks.MetadataTable = Nothing

    Public Property RefreshParent() As Boolean
        Get
            Return _refreshParent
        End Get
        Set(ByVal value As Boolean)
            _refreshParent = value
        End Set
    End Property

    Public Property SendToDefault() As Boolean
        Get
            Return _sendToDefault
        End Get
        Set(ByVal value As Boolean)
            _sendToDefault = value
        End Set
    End Property

    Public ReadOnly Property UploadQueryString() As String
        Get
            Return "?r=" & r.Value & "&sd=" & sd.Value
        End Get
    End Property

    Protected Property UseSessionVendor() As Boolean
        Get
            Return _useSessionVendor
        End Get
        Set(ByVal value As Boolean)
            _useSessionVendor = value
        End Set
    End Property


#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("closeform.aspx")
        End If

        If Not IsPostBack Then
            ' setup the page
            If Request("r") = "1" Then
                r.Value = "1"
            End If
            If Request("sd") = "1" Then
                sd.Value = "1"
            End If
            'Me.btnSubmit.Attributes.Add("onclick", "return onUploadSubmitted();")
            lblFeedback.Text = ""
        End If

        ' set refresh parent property
        If r.Value = "1" Then
            RefreshParent = True
        End If

        ' set send to default property
        If sd.Value = "1" Then
            SendToDefault = True
        End If

        ' check session vendor
        If Session("vendorId") <> "" Then
            UseSessionVendor = True
        End If

        _table = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)

    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click

        _cancelBatch = False
        ClearFeedback()

        ' save the imported file
        Dim theFile As HttpPostedFile = Request.Files.Item("importFile")
        If Not theFile Is Nothing Then
            Try
                If ExcelFileHelper.IsValidFileType(theFile.FileName) Then

                    ' extract the file name for the audit trail
                    Dim slashPos As Integer = theFile.FileName.LastIndexOf("\")
                    If slashPos > -1 Then
                        _xlFileName = theFile.FileName.Substring(slashPos + 1)
                    Else
                        _xlFileName = theFile.FileName
                    End If

                    ' set up the ws object
                    Dim wb As SpreadsheetGear.IWorkbook = SpreadsheetGear.Factory.GetWorkbookSet().Workbooks.OpenFromStream(theFile.InputStream)
                    Dim ws As IWorksheet = wb.Worksheets(0)
                    If ws Is Nothing Then
                        Throw New SPEDYUploadException("ERROR: Worksheet not found. <br/>Please contact the system administrator and verify that you are using the latest upload template.")
                    End If

                    ' validate
                    Session("UPLOAD_TRILINGUAL_MAINT_WB") = Nothing

                    'Determine batch type
                    Dim uploadtype As ExcelFileHelper.FileType = FindUploadType(ws)

                    Select Case uploadtype
                        Case ExcelFileHelper.FileType.TMExemption
                            UploadTMExemption(ws)
                        Case ExcelFileHelper.FileType.TMTranslation
                            'Only let DBC/QA users upload a Translation Batch.
                            If IsAdminDBCQA() Then
                                UploadTMTranslation(ws)
                            Else
                                Throw New SPEDYUploadException("ERROR: You do not have the necessary permissions to upload a Translation Batch.")
                            End If
                        Case Else
                            Throw New SPEDYUploadException("ERROR: Invalid File Format")
                    End Select

                    FlushFeedback()
                Else
                    ' ERROR: invalid file type
                    ClearFeedback("Please upload a valid Excel spreadsheet (*.xls)")
                    FlushFeedback()
                End If

            Catch uploadEx As SPEDYUploadException
                ClearFeedback(uploadEx.Message)
                FlushFeedback()

            Catch ex As Exception
                ' ERROR: invalid file type
                ClearFeedback(WebConstants.IMPORT_ERROR_UNKNOWN)
                FlushFeedback()

            End Try

            ' make buttons visible
            panelButtons.Visible = True

        End If

    End Sub

    Private Function FindUploadType(ByVal ws As SpreadsheetGear.IWorksheet) As ExcelFileHelper.FileType
        Dim columnHeader As String = DataHelper.SmartValues(ws.Cells(0, 0).Value, "string", True)
        If columnHeader.ToUpper <> "SKU" Then
            Throw New SPEDYUploadException("ERROR: The first column must be 'SKU'.  <br/>Please contact the system administrator and verify that you are using the latest upload template.")
        End If

        For i As Integer = 1 To 100
            columnHeader = DataHelper.SmartValues(ws.Cells(0, i).Value, "string", True, "")
            Select Case columnHeader.ToUpper
                Case "SKU DESCRIPTION"
                    _skuDescriptionColumn = i
                Case "VENDOR NBR"
                    _supplierColumn = i
                Case "TRANSLATION INDICATOR FRENCH"
                    _tiFrenchColumn = i
                Case "ENGLISH SHORT DESCRIPTION"
                    _englishShortDescColumn = i
                Case "ENGLISH LONG DESCRIPTION"
                    _englishLongDescColumn = i
                Case "PACKAGE LANGUAGE INDICATOR FRENCH"
                    _pliFrenchColumn = i
                Case "PACKAGE LANGUAGE INDICATOR SPANISH"
                    _pliSpanishColumn = i
                Case "EXEMPT END DATE"
                    _exemptEndDateColumn = i
                Case ""
                    Exit For
                Case Else
                    Throw New SPEDYUploadException("ERROR:  Column '" & columnHeader & "' is not a valid column. <br/>Please contact the system administrator and verify that you are using the latest upload template.")
            End Select
        Next

        If _supplierColumn <> 0 And _pliFrenchColumn <> 0 And _pliSpanishColumn <> 0 And _exemptEndDateColumn <> 0 Then
            Return ExcelFileHelper.FileType.TMExemption
        End If
        If _tiFrenchColumn <> 0 And _englishLongDescColumn <> 0 And _englishShortDescColumn <> 0 And _skuDescriptionColumn <> 0 Then
            Return ExcelFileHelper.FileType.TMTranslation
        End If

        Throw New SPEDYUploadException("ERROR: Appropriate upload columns not found. <br/>Please contact the system administrator and verify that you are using the latest upload template.")

    End Function

#Region "TMTranslation Format Routines"

    Private Sub CompareTMTranslationUploadFields(ByVal itemMaintHeaderID As Integer, ByVal item As Models.ItemMaintUploadChangeRecord, ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal userID As Integer)

        FieldComparison(item.SKUDescription, masterDtl.ItemDesc, itemMaintHeaderID, "ItemDesc", userID, True)
        'NAK 5/15/2013:  Per Michaels, only upload the TI French if it is not already set to YES
        If masterDtl.TIFrench <> "Y" Then
            FieldComparison(item.TIFrench, masterDtl.TIFrench, itemMaintHeaderID, "TIFrench", userID, True)
        End If

        'IF this is a pack item, override value (Per Michaels:  These values must be used for pack parent items)
        If masterDtl.PackItemIndicator.StartsWith("DP") Then
            item.EnglishShortDescription = "Display Pack"
            item.EnglishLongDescription = "Display Pack"
        ElseIf masterDtl.PackItemIndicator.StartsWith("SB") Then
            item.EnglishShortDescription = "Sellable Bundle"
            item.EnglishLongDescription = "Sellable Bundle"
        ElseIf masterDtl.PackItemIndicator.StartsWith("D") Then
            item.EnglishShortDescription = "Displayer"
            item.EnglishLongDescription = "Displayer"
        End If

        FieldComparison(item.EnglishShortDescription, masterDtl.EnglishShortDescription, itemMaintHeaderID, "EnglishShortDescription", userID, True)
        FieldComparison(item.EnglishLongDescription, masterDtl.EnglishLongDescription, itemMaintHeaderID, "EnglishLongDescription", userID, True)

    End Sub

    Private Function ReadTMTranslationFromWS(ByVal ws As IWorksheet) As List(Of Models.ItemMaintUploadChangeRecord)

        Dim itemList As New List(Of Models.ItemMaintUploadChangeRecord)
        Dim rowExists As Boolean = True
        Dim rowIndex As Integer = 1

        While rowExists

            'GET SKU
            Dim theItem As New Models.ItemMaintUploadChangeRecord
            theItem.MichaelsSKU = DataHelper.SmartValues(ws.Cells(rowIndex, 0).Value, "string", True)

            'IF SKU is not specified, exit loop
            If String.IsNullOrEmpty(theItem.MichaelsSKU) Then
                rowExists = False
                Exit While
            End If

            'Get other item values
            theItem.SKUDescription = Left(DataHelper.SmartValues(ws.Cells(rowIndex, _skuDescriptionColumn).Value, "string", True), 30).ToUpper
            theItem.EnglishShortDescription = Left(DataHelper.SmartValues(ws.Cells(rowIndex, _englishShortDescColumn).Value, "string", True), 17)
            theItem.EnglishLongDescription = Left(DataHelper.SmartValues(ws.Cells(rowIndex, _englishLongDescColumn).Value, "string", True), 100)
            theItem.TIFrench = ConvertToYesNo(DataHelper.SmartValues(ws.Cells(rowIndex, _tiFrenchColumn).Value, "String", True))
            'NAK 4/11/2013: Default TIFrench to YES per Michaels
            If theItem.TIFrench <> "N" Then
                theItem.TIFrench = "Y"
            End If


            itemList.Add(theItem)

            rowIndex = rowIndex + 1
        End While


        Return itemList

    End Function

    Private Sub UploadTMTranslation(ByVal ws As IWorksheet)
        Try
            Dim skuAdded As New List(Of String)
            Dim userID As String = Session(WebConstants.cUSERID)
            _validSKUList = New List(Of SkuList)

            'Load List of Items
            Dim itemList As List(Of Models.ItemMaintUploadChangeRecord) = ReadTMTranslationFromWS(ws)

            'Validate List of Items, and process them if they pass validation
            ValidateTMTranslation(itemList, userID)
            If _validSKUList.Count > 0 Then
                'CREATE Batch
                Dim batch As New NovaLibra.Coral.Data.Michaels.BatchData
                Dim batchID As Integer = MyBase.CreateBatch(WebConstants.WorkflowType.TrilingualMaint, 0, 0, "", userID, "", "", "", "", "", "", Models.BatchType.TrilingualTranslations)

                'Loop through item list.  Add each one to the batch, and then Compare the uploaded values to existing values to create change records.
                For Each item As Models.ItemMaintUploadChangeRecord In itemList
                    'Add Item to Batch if it is valid, and if it has not already been added to the batch (this can happen if there are duplicate SKUs in the worksheet)
                    If _validSKUList.Contains(New SkuList(item.MichaelsSKU, item.VendorNbr)) And Not (skuAdded.Contains(item.MichaelsSKU)) Then
                        Dim addItem As Models.ItemMaintItem = BuildBatchAddItem(batchID, userID, item.MichaelsSKU, item.SkuID, item.VendorNbr)
                        Dim itemHeaderID As Integer = NLData.Michaels.MaintItemMasterData.SaveItemMaintHeaderRec(addItem)

                        'Get Master Item
                        Dim masterDtl As Models.ItemMaintItemDetailFormRecord = NLData.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(itemHeaderID, 0, item.MichaelsSKU, 0)

                        'Compare Uploaded values to Existing Values to create Change records
                        CompareTMTranslationUploadFields(itemHeaderID, item, masterDtl, userID)

                        skuAdded.Add(item.MichaelsSKU)
                    End If
                Next

                FlushFeedback("Upload complete.")
            End If


        Catch ex As Exception
            Throw ex
        End Try

    End Sub

    Private Sub ValidateTMTranslation(ByVal itemList As List(Of Models.ItemMaintUploadChangeRecord), ByVal userID As Integer)
        Dim errorCount As Integer = 0

        If itemList.Count = 0 Then
            AddToErrorList("ValidateTMTranslation", "ERROR: Worksheet does not contain any SKUs.", "")
        End If

        For Each item As Models.ItemMaintUploadChangeRecord In itemList
            Dim isValid As Boolean = True
            'Validate SKU is not in another Trilingual Batch
            Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batchList As List(Of Models.BatchRecord) = batchDB.GetBatchesBySKU(item.MichaelsSKU)
            For Each batch As Models.BatchRecord In batchList
                Select Case batch.BatchTypeID
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualTranslations
                        AddToErrorList("ValidateTMTranslation", "SKU '" & item.MichaelsSKU & "' is already in Trilingual Translation batch " & batch.ID & ".", item.MichaelsSKU)
                        isValid = False
                        errorCount += 1
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualExemptions
                        AddToFeedback("WARNING: SKU '" & item.MichaelsSKU & "' is already in Trilingual PLI/Exemption batch " & batch.ID & ".")
                    Case Else
                        AddToFeedback("WARNING: SKU '" & item.MichaelsSKU & "' is already in Item Maintenance batch " & batch.ID & ".")
                End Select
            Next

            'Validate SKU exists in Item Maintenance
            Dim sku As Models.ItemMasterRecord = Data.ItemMasterData.GetBySKU(item.MichaelsSKU)
            If String.IsNullOrEmpty(sku.Item) Then
                AddToErrorList("ValidateTMTranslation", "Specified SKU (" & item.MichaelsSKU & ") does not exist in SPEDY", item.MichaelsSKU)
                isValid = False
                errorCount += 1
            Else
                item.VendorNbr = sku.VendorNumber
                item.SkuID = sku.ItemID
            End If

            'Make sure SKU was not already added 
            For Each s As SkuList In _validSKUList
                If s.SKU = item.MichaelsSKU Then
                    AddToErrorList("ValidateTMTranslation", "Duplicate found for SKU '" & item.MichaelsSKU & "'.", item.MichaelsSKU)
                    'Ony add an error count if it is currently valid
                    If isValid Then
                        errorCount += 1
                    End If
                    isValid = False

                    Exit For
                End If
            Next

            'If SKU is valid, add it to the list
            If isValid Then
                _validSKUList.Add(New SkuList(item.MichaelsSKU, item.VendorNbr))
            End If
        Next

        PostValidationFeedback(_validSKUList.Count, itemList.Count, errorCount)
    End Sub

#End Region

#Region "TMExemption Format Routines "

    Private Sub CompareTMExemptionUploadFields(ByVal itemMaintHeaderID As Integer, ByVal item As Models.ItemMaintUploadChangeRecord, ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal userID As Integer)

        FieldComparison(item.PLIEnglish, masterDtl.PLIEnglish, itemMaintHeaderID, "PLIEnglish", userID, True)
        FieldComparison(item.PLIFrench, masterDtl.PLIFrench, itemMaintHeaderID, "PLIFrench", userID, True)
        FieldComparison(item.PLISpanish, masterDtl.PLISpanish, itemMaintHeaderID, "PLISpanish", userID, True)
        FieldComparison(item.ExemptEndDateFrench, masterDtl.ExemptEndDateFrench, itemMaintHeaderID, "ExemptEndDateFrench", userID, True)

    End Sub

    Private Function ReadTMExemptionFromWS(ByVal ws As IWorksheet) As List(Of Models.ItemMaintUploadChangeRecord)

        Dim itemList As New List(Of Models.ItemMaintUploadChangeRecord)
        Dim rowExists As Boolean = True
        Dim rowIndex As Integer = 1

        While rowExists

            'GET SKU
            Dim theItem As New Models.ItemMaintUploadChangeRecord
            theItem.MichaelsSKU = DataHelper.SmartValues(ws.Cells(rowIndex, 0).Value, "string", True)

            'IF SKU is not specified, exit loop
            If String.IsNullOrEmpty(theItem.MichaelsSKU) Then
                rowExists = False
                Exit While
            End If

            'Get other item values
            theItem.VendorNbr = DataHelper.SmartValues(ws.Cells(rowIndex, _supplierColumn).Value, "string", True)
            'PLI Values can only be Y or N, so make sure to convert it to the valid values
            theItem.PLIEnglish = "Y"    'Default PLIEnglish to YES.  This will ensure it gets set in case it does not have a value for the uploaded SKU/Vendor
            theItem.PLIFrench = ConvertToYesNo(DataHelper.SmartValues(ws.Cells(rowIndex, _pliFrenchColumn).Value, "string", True))
            theItem.PLISpanish = ConvertToYesNo(DataHelper.SmartValues(ws.Cells(rowIndex, _pliSpanishColumn).Value, "string", True))
            theItem.ExemptEndDateFrench = DataHelper.SmartValues(Left(ws.Cells(rowIndex, _exemptEndDateColumn).Value, 10), "String", True)

            itemList.Add(theItem)

            rowIndex = rowIndex + 1
        End While

        Return itemList
    End Function

    Private Sub UploadTMExemption(ByVal ws As IWorksheet)
        Try
            Dim userID As String = Session(WebConstants.cUSERID)
            _validSKUList = New List(Of SkuList)

            'Load List of Items
            Dim itemList As List(Of Models.ItemMaintUploadChangeRecord) = ReadTMExemptionFromWS(ws)

            'Validate List of Items, and process them if they pass validation
            ValidateTMExemption(itemList, userID)

            If _validSKUList.Count > 0 Then
                'CREATE Batch
                Dim batch As New NovaLibra.Coral.Data.Michaels.BatchData
                Dim batchID As Integer = MyBase.CreateBatch(WebConstants.WorkflowType.EXTMaint, 0, 0, "", userID, "", "", "", "", "", "", Models.BatchType.TrilingualExemptions)

                'Loop through item list.  Add each one to the batch, and then Compare the uploaded values to existing values to create change records.
                For Each item As Models.ItemMaintUploadChangeRecord In itemList
                    'Add Item to Batch if it is valid
                    If _validSKUList.Contains(New SkuList(item.MichaelsSKU, item.VendorNbr)) Then
                        Dim addItem As Models.ItemMaintItem = BuildBatchAddItem(batchID, userID, item.MichaelsSKU, item.SkuID, item.VendorNbr)
                        Dim itemHeaderID As Integer = NLData.Michaels.MaintItemMasterData.SaveItemMaintHeaderRec(addItem)

                        'Get Master Item
                        Dim masterDtl As Models.ItemMaintItemDetailFormRecord = NLData.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(itemHeaderID, 0, item.MichaelsSKU, 0)

                        'Compare Uploaded values to Existing Values to create Change records
                        CompareTMExemptionUploadFields(itemHeaderID, item, masterDtl, userID)
                    End If
                Next

                FlushFeedback("Upload complete.")
            End If

        Catch ex As Exception
            Throw ex
        End Try
    End Sub

    Private Sub ValidateTMExemption(ByVal itemList As List(Of Models.ItemMaintUploadChangeRecord), ByVal userID As Integer)

        Dim errorCount As Integer = 0

        If itemList.Count = 0 Then
            AddToErrorList("ValidateTMExemption", "ERROR: Worksheet does not contain any SKUs.", "")
        End If

        For Each item As Models.ItemMaintUploadChangeRecord In itemList
            'Reset 
            Dim isValid As Boolean = True
            'Verify a Vendor Number was specified
            If String.IsNullOrEmpty(item.VendorNbr) Or item.VendorNbr = "0" Then
                AddToErrorList("ValidateTMExemption", "Vendor Number is required.  No Vendor Number was specified for SKU '" & item.MichaelsSKU & "'.", item.MichaelsSKU)
                isValid = False
                errorCount += 1
            End If

            'Validate SKU is not in another Trilingual Batch
            Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batchList As List(Of Models.BatchRecord) = batchDB.GetBatchesBySKU(item.MichaelsSKU)
            For Each batch As Models.BatchRecord In batchList
                Select Case batch.BatchTypeID
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualExemptions
                        AddToErrorList("ValidateTMTranslation", "SKU '" & item.MichaelsSKU & "' is already in Trilingual PLI/Exemption batch " & batch.ID & ".", item.MichaelsSKU)
                        errorCount += 1
                        isValid = False
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualTranslations
                        AddToFeedback("WARNING: SKU '" & item.MichaelsSKU & "' is already in Trilingual Translation batch " & batch.ID & ".")
                    Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.BulkItemMaintenance
                        AddToFeedback("WARNING: SKU '" & item.MichaelsSKU & "' is already in Bulk Item Maintenance batch " & batch.ID & ".")
                    Case Else
                        AddToFeedback("WARNING: SKU '" & item.MichaelsSKU & "' is already in Item Maintenance batch " & batch.ID & ".")
                End Select
            Next

            'Validate SKU exists in Item Maintenance
            Dim sku As Models.ItemMasterRecord = Data.ItemMasterData.GetBySKUVendor(item.MichaelsSKU, DataHelper.SmartValues(item.VendorNbr, "CInt", False))
            If String.IsNullOrEmpty(sku.Item) Then
                AddToErrorList("ValidateTMTranslation", "Specified SKU (" & item.MichaelsSKU & ") for Vendor (" & item.VendorNbr & ") does not exist in SPEDY", item.MichaelsSKU)
                errorCount += 1
                isValid = False
            Else
                item.SkuID = sku.ItemID
            End If

            'Make sure SKU was not already added 
            If _validSKUList.Contains(New SkuList(item.MichaelsSKU, item.VendorNbr)) Then
                AddToErrorList("ValidateTMExemption", "Duplicate found for SKU '" & item.MichaelsSKU & "'.", item.MichaelsSKU)
                'Ony add an error count if it is currently valid
                If isValid Then
                    errorCount += 1
                End If
                isValid = False
            End If

            'If the SKU is valid, add it to the list
            If isValid Then
                _validSKUList.Add(New SkuList(item.MichaelsSKU, item.VendorNbr))
            End If
        Next

        PostValidationFeedback(_validSKUList.Count, itemList.Count, errorCount)
    End Sub

#End Region


#Region " Feedback and Auditing "

    Private Sub ClearFeedback(Optional ByVal msg As String = "")
        _feedbackMsg = msg
    End Sub

    Private Sub AddToFeedback(ByVal msg As String)
        If _feedbackMsg.Length > 0 Then
            _feedbackMsg += "<BR>"
        End If
        _feedbackMsg += msg
    End Sub

    Private Sub FlushFeedback(Optional ByVal msg As String = "")
        If msg.Length > 0 Then
            AddToFeedback(msg)
        End If
        lblFeedback.Text = _feedbackMsg
    End Sub

    Private Sub AddToErrorList(ByVal routineName As String, _
                               ByVal msg As String, _
                               Optional ByVal michaelsSKU As String = "", _
                               Optional ByVal vendorNbr As String = "", _
                               Optional ByVal batchID As String = "")

        Dim userID As String = Session(WebConstants.cUSERID)

        ' display on the dialog box
        AddToFeedback(msg)

        ' record in the queue
        If michaelsSKU.Length > 0 Or vendorNbr.Length > 0 Or batchID.Length > 0 Then

            Dim excelAuditRec As New Models.ExcelAuditLog
            If batchID.Length > 0 Then
                excelAuditRec.BatchID = batchID
            End If
            If vendorNbr.Length > 0 Then
                excelAuditRec.VendorNumber = vendorNbr
            End If
            excelAuditRec.MichaelsSKU = michaelsSKU
            excelAuditRec.CreatedUserID = userID
            excelAuditRec.Message = "Upload Item Maint routine: " & routineName & "; Message: " & msg
            excelAuditRec.Direction = "I"
            excelAuditRec.XLFileName = _xlFileName

            Dim objData As New NovaLibra.Coral.Data.Michaels.FieldAuditingData
            objData.SaveExcelAuditLog(excelAuditRec)

        End If

    End Sub

#End Region

    Private Function BuildBatchAddItem(ByVal batchID As Long, ByVal userID As Integer, ByVal SKU As String, ByVal skuID As Integer, ByVal vendorNbr As String) As Models.ItemMaintItem

        Dim ret As New Models.ItemMaintItem

        ret.BatchID = batchID
        ret.CreatedUserID = userID
        ret.SKU = SKU
        ret.SKUID = skuID
        ret.VendorNumber = vendorNbr

        Return ret

    End Function

    Private Function ConvertToYesNo(ByVal value As String) As String
        Dim result As String = String.Empty
        Select Case value.ToUpper
            Case "Y", "YES"
                result = "Y"
            Case "N", "NO"
                result = "N"
            Case Else
                result = ""
        End Select

        Return result
    End Function

    Private Sub PostValidationFeedback(ByVal passCounter As Integer, ByVal itemCounter As Integer, ByVal errorCounter As Integer)

        AddToFeedback(itemCounter.ToString & " items were reviewed.")
        AddToFeedback(errorCounter.ToString & " items had validation errors.")
        AddToFeedback(passCounter.ToString & " items passed validation.")

        If passCounter = 0 Then
            Session("UPLOAD_ITEM_MAINT_WB") = Nothing
            FlushFeedback("No items from this file can be saved to a batch.")
        Else
            Dim countMsg As String = passCounter & " items processed."
            countMsg += "<BR>" & "Processing ends when an empty SKU is encountered."
            AddToFeedback(countMsg)
        End If

    End Sub

    ' this routine truncates the xl-value to the specified field length, then passes the result along to the regular FieldComparison sub
    Private Function FieldComparisonTrunc(ByVal xlValue As String, ByVal truncLen As Integer, ByVal imValue As String, ByVal itemMaintHeaderID As Long, ByVal fieldName As String, ByVal userID As Integer) As Boolean
        Return FieldComparisonTrunc(xlValue, truncLen, imValue, itemMaintHeaderID, fieldName, userID, False)
    End Function

    Private Function FieldComparisonTrunc(ByVal xlValue As String, ByVal truncLen As Integer, ByVal imValue As String, ByVal itemMaintHeaderID As Long, ByVal fieldName As String, ByVal userID As Integer, ByVal ignoreBlanks As Boolean) As Boolean
        Dim truncValue As String = xlValue
        If truncLen < xlValue.Length Then
            truncValue = xlValue.Substring(0, truncLen)
        End If
        Return FieldComparison(truncValue, imValue, itemMaintHeaderID, fieldName, userID, ignoreBlanks)
    End Function

    Private Function FieldComparison(ByVal xlValue As Object, ByVal imValue As Object, ByVal itemMaintHeaderID As Long, ByVal fieldName As String, ByVal userID As Integer) As Boolean
        Return FieldComparison(xlValue, imValue, itemMaintHeaderID, fieldName, userID, False)
    End Function

    Private Function FieldComparison(ByVal xlValue As Object, ByVal imValue As Object, ByVal itemMaintHeaderID As Long, ByVal fieldName As String, ByVal userID As Integer, ByVal ignoreBlanks As Boolean) As Boolean
        ' if there is a change present, return true, otherwise false
        Dim ret As Boolean = False
        Dim column As Frameworks.MetadataColumn = _table.GetColumnByName(fieldName)

        Debug.Assert(column IsNot Nothing, ("Cannot find metadata for this column: " & fieldName))

        '' if the spreadsheet is blank/empty, don't save it as a change

        If xlValue.ToString().Trim.Length > 0 OrElse (Not ignoreBlanks) Then

            Dim fieldType As String = IIf(column IsNot Nothing, column.GenericType, "string")
            Dim fieldFormat As String = IIf(column IsNot Nothing, column.ColumnFormat, "string")

            If DataHelper.SmartValues(xlValue, fieldType, True) <> DataHelper.SmartValues(imValue, fieldType, True) Then

                If (fieldType <> "decimal" And fieldType <> "numeric") OrElse DataHelper.SmartValues(xlValue, fieldFormat, True) <> DataHelper.SmartValues(imValue, fieldFormat, True) Then

                    ' create a change record
                    If (fieldType = "decimal" OrElse fieldType = "numeric") And fieldFormat <> "percent" Then
                        NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, fieldName, DataHelper.SmartValuesAsString(DataHelper.SmartValuesAsString(xlValue, fieldType), fieldFormat), True, userID, "", "", "", 0, False, True)
                    Else
                        NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, fieldName, DataHelper.SmartValuesAsString(xlValue, fieldType), True, userID, "", "", "", 0, False, True)
                    End If

                    ret = True
                End If

            End If

        End If

        Return ret
    End Function

End Class
