Imports System
Imports System.Configuration
Imports System.Data
Imports System.Diagnostics
Imports System.IO
Imports Microsoft.VisualBasic
Imports System.Data.SqlClient
Imports SpreadsheetGear
Imports SpreadsheetGear.Data
Imports SpreadsheetGear.Shapes
Imports System.Collections.Generic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports Frameworks = NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports ItemHelper

Partial Class UploadItemMaint
    Inherits MichaelsBasePage

#Region " Data and Properties "

    Private _refreshParent As Boolean = False
    Private _sendToDefault As Boolean = False
    Private _useSessionVendor As Boolean = False
    Private _xlFileName As String = String.Empty

    Private _validationMasterVendor As String = String.Empty
    Private _validationMasterDept As String = String.Empty
    Private _feedbackMsg As String = String.Empty
    Private _cancelBatch As Boolean = False
    Private _validationSKUList As System.Collections.Generic.List(Of String)

    Private _TruncLenItemDesc As Integer = 30
    Private _TruncLenVendorStyleNumber As Integer = 20
    Private _TruncLenUPC As Integer = 14
    Private _TruncLenSKU As Integer = 8

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

    ' this is just to keep track of batches
    Private Class UploadItemMaintBatchTracker
        Public BatchID As Long
        Public VendorNbr As String
        Public Dept As String
        Public StockCat As String
        Public ItemTypeAttr As String

        Public Sub New(ByVal id As Long, ByVal vendorNbr As String, ByVal dept As String, ByVal stockCat As String, ByVal itemTypeAttr As String)
            Me.BatchID = id
            Me.VendorNbr = vendorNbr
            Me.Dept = dept
            Me.StockCat = stockCat
            Me.ItemTypeAttr = itemTypeAttr
        End Sub
    End Class

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

        Dim wb As SpreadsheetGear.IWorkbook
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

                    ' set up the wb object
                    wb = SpreadsheetGear.Factory.GetWorkbookSet().Workbooks.OpenFromStream(theFile.InputStream)

                    ' validate
                    Session("UPLOAD_ITEM_MAINT_WB") = Nothing
                    If ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.Import) Then
                        If ValidateImportWS(wb) Then
                            UploadImportFile(wb)
                            FlushFeedback("Upload complete.")
                        End If
                    ElseIf ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.ItemMaintenance) Then
                        UploadItemMaintFile(wb)
                        FlushFeedback("Upload complete.")
                    Else
                        ' ERROR: invalid component
                        AddToErrorList("Submit Button", "Invalid File Format")
                        FlushFeedback()
                    End If
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

    Protected Sub btnConfirm_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnConfirm.Click
        Dim wb As SpreadsheetGear.IWorkbook = Session("UPLOAD_ITEM_MAINT_WB")
        btnConfirm.Visible = False
        If Not wb Is Nothing Then
            Try
                ClearFeedback()
                If ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.Import) Then
                    UploadImportFile(wb)
                    ClearFeedback()
                    FlushFeedback("Upload complete.")
                ElseIf ExcelFileHelper.IsValidComponent(wb, ExcelFileHelper.FileType.ItemMaintenance) Then
                    UploadItemMaintFile(wb)
                    ClearFeedback()
                    FlushFeedback("Upload complete.")
                Else
                    ' ERROR: invalid component
                    AddToErrorList("Confirm Button", "Invalid File Format")
                    FlushFeedback()
                End If
            Catch ex As Exception
                ' Error
                ClearFeedback(ex.Message)
                FlushFeedback()
            End Try
        Else
            ClearFeedback("Could not locate the file in memory. The session may have expired. Please upload the file again.")
            FlushFeedback()
        End If
    End Sub

#Region " Import Format Routines "

    Private Function ValidateImportItem(ByVal theItem As Models.ImportItemRecord) As Boolean

        Dim ret As Boolean = True

        Dim userID As String = Session(WebConstants.cUSERID)
        Dim skuList As System.Collections.Generic.List(Of Models.ItemSearchRecord) = _
            BatchesData.SearchSKURecs(0, theItem.VendorNumber, 0, 0, String.Empty, String.Empty, theItem.MichaelsSKU, _
                String.Empty, String.Empty, String.Empty, String.Empty, userID, 0, String.Empty, String.Empty, 0, 0, String.Empty)
        If skuList.Count = 1 Then
            Dim thisISR As Models.ItemSearchRecord = skuList.Item(0)

            ret = CommonValidationRules(thisISR, "ValidateImportItem")

            ' compare vendor and dept; they have to match for all items in the upload
            If _validationMasterVendor.Length = 0 Then
                ' this is the first item; set the master values
                _validationMasterVendor = thisISR.VendorNumber
                _validationMasterDept = thisISR.DeptNo
            Else
                If _validationMasterVendor <> thisISR.VendorNumber Or _validationMasterDept <> thisISR.DeptNo Then
                    ret = False
                    AddToErrorList("ValidateImportItem", "SKU '" & thisISR.SKU & "' does not match the vendor and dept of the rest of the upload.", thisISR.SKU, thisISR.VendorNumber)
                End If
            End If

        Else
            ret = False
            AddToErrorList("ValidateImportItem", "SKU '" & theItem.MichaelsSKU & "' not found, or not associated with vendor '" & theItem.VendorNumber & "'.", theItem.MichaelsSKU, theItem.VendorNumber)
        End If

        'Don't allow import of "Draft" status
        If theItem.QuoteSheetStatus.ToUpper = "DRAFT" Then
            ret = False
            AddToErrorList("ValidateImportItem", "Invalid Quote Sheet Status (" & theItem.QuoteSheetStatus.ToString & ").", theItem.MichaelsSKU, theItem.VendorNumber)
        End If

        'Don't allow import of regular and pack items that have a task type of 'NEW'
        If theItem.ItemTask.ToUpper.StartsWith("NEW") Then
            ret = False
            AddToErrorList("ValidateImportItem", "Invalid task type for Maintenance Item (" & theItem.ItemTask.ToString & ").")
        End If

        Return ret

    End Function

    Private Function ValidateImportWS(ByVal wb As SpreadsheetGear.IWorkbook) As Boolean

        Dim ret As Boolean = True

        Dim wsName As String '= WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET
        Dim ws As SpreadsheetGear.IWorksheet '= ExcelFileHelper.GetExcelWorksheet(wb, wsName)

        Dim tabName As String = ""
        For itab As Integer = 0 To wb.Worksheets.Count - 1
            tabName = wb.Worksheets(itab).Name
            If ExcelFileHelper.IsValidTabName(tabName) Then
                ws = ExcelFileHelper.GetExcelWorksheet(wb, tabName)
                wsName = tabName
                Exit For
            End If
        Next
        'ws = ExcelFileHelper.GetExcelWorksheet(wb, WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET)
        'WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET

        Dim iCount As Integer = 0

        ' get item map
        Dim mapVer As String = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, "B", 3), "string", False)
        Dim michaelsMap As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping
        Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = michaelsMap.GetMapping("IMPORTITEM", mapVer)

        If itemMap Is Nothing OrElse itemMap.ID = 0 Then
            'if the version number ends in 0 the mapVer will not have the trailing zero so we much try to find it by that
            mapVer = mapVer + "0"
            itemMap = michaelsMap.GetMapping("IMPORTITEM", mapVer)
        End If

        If itemMap Is Nothing OrElse itemMap.Count <= 0 Then
            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_VERSION, mapVer))
        End If

        Dim errorCounter As Integer = 0
        Dim itemCounter As Integer = 0

        Do While Not ws Is Nothing
            Dim theItem As Models.ImportItemRecord = ReadImportItemFromWS(ws, itemMap)
            itemCounter += 1
            If Not theItem Is Nothing Then
                ' validate!
                If Not ValidateImportItem(theItem) Then
                    ret = False
                    errorCounter += 1
                End If
            Else
                ' if the item is nothing, that means the vendor number was blank or invalid
                ' (the error message was added inside the ReadImportItemFromWS function)
                ret = False
                errorCounter += 1
            End If
            iCount += 1

            Dim bFound As Boolean = False

            For itemp As Integer = ws.Index + 1 To wb.Worksheets.Count - 1
                wsName = wb.Worksheets.Item(itemp).Name
                If ExcelFileHelper.IsValidTabName(wsName) Then
                    ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName)
                    bFound = True
                    Exit For
                End If
            Next

            If Not bFound Then
                ws = Nothing
            End If

            'wsName = WebConstants.IMPORT_ITEM_CHILD_WORKSHEET
            'ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName.Replace("#", iCount))
        Loop

        PostValidationFeedback(ret, wb, itemCounter, errorCounter)

        Return ret

    End Function

    Private Sub UploadImportFile(ByVal wb As SpreadsheetGear.IWorkbook)

        Dim ws As SpreadsheetGear.IWorksheet
        Dim iCount As Integer = 0
        Dim wsName As String = ""
        Dim batchList As New System.Collections.Generic.List(Of UploadItemMaintBatchTracker)

        Dim masterVendorNbr As String = String.Empty
        Dim masterDept As String = String.Empty

        Dim tabName As String = ""
        For itab As Integer = 0 To wb.Worksheets.Count - 1
            tabName = wb.Worksheets(itab).Name
            If ExcelFileHelper.IsValidTabName(tabName) Then
                ws = ExcelFileHelper.GetExcelWorksheet(wb, tabName)
                Exit For
            End If
        Next
        'ws = ExcelFileHelper.GetExcelWorksheet(wb, WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET)
        wsName = tabName 'WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET

        ' get mapping version
        Dim mapVer As String = DataHelper.SmartValues(ExcelFileHelper.GetCell(ws, "B", 3), "string", False)

        ' get item map
        Dim michaelsMap As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMapping
        Dim itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = michaelsMap.GetMapping("IMPORTITEM", mapVer)

        If itemMap Is Nothing OrElse itemMap.ID = 0 Then
            'if the version number ends in 0 the mapVer will not have the trailing zero so we much try to find it by that
            mapVer = mapVer + "0"
            itemMap = michaelsMap.GetMapping("IMPORTITEM", mapVer)
        End If

        If itemMap Is Nothing OrElse itemMap.Count <= 0 Then
            Throw New SPEDYUploadException(String.Format(WebConstants.IMPORT_ERROR_INVALID_VERSION, mapVer))
        End If

        ' process the file
        Try
            Dim userID As String = Session(WebConstants.cUSERID)

            'Initialize Batch objects
            Dim batch As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batchID As Integer = 0
            Dim isMSS As Boolean = False

            Do While Not ws Is Nothing
                Dim theItem As Models.ImportItemRecord = ReadImportItemFromWS(ws, itemMap)

                If Not theItem Is Nothing Then

                    If Not String.IsNullOrEmpty(theItem.QuoteReferenceNumber) Then
                        isMSS = True
                    End If

                    ' validate. also retrieve.
                    Dim thisSKU As String = theItem.MichaelsSKU
                    Dim thisVendorNbr As String = theItem.VendorNumber

                    Dim bContinue As Boolean = True

                    'Get Master Item
                    Dim masterDtl As Models.ItemMaintItemDetailFormRecord = NLData.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(0, theItem.VendorNumber, theItem.MichaelsSKU, theItem.VendorNumber)

                    'Create Batch if it has not already been created
                    If batchID <= 0 Then
                        batchID = MyBase.CreateBatch(2, masterDtl.DepartmentNum, DataHelper.SmartValues(theItem.VendorNumber, "CInt", False), theItem.VendorName, userID, masterDtl.StockCategory, masterDtl.ItemTypeAttribute, "R", "", "", theItem.QuoteReferenceNumber)
                    End If

                    'Get SKU ID (Because of the screwy way Item Maintenance works, we need this next line to get the SKU ID from the Database.  MasterDtl's ID is always going to be 0...  stupid, eh?)
                    Dim sku As Models.ItemMasterRecord = Data.ItemMasterData.GetBySKU(theItem.MichaelsSKU)

                    ' add item to batch
                    Dim addItem As Models.ItemMaintItem = BuildBatchAddItem(batchID, userID, theItem.MichaelsSKU, sku.ItemID, theItem.VendorNumber)
                    Dim itemHeaderID As Long = NLData.Michaels.MaintItemMasterData.SaveItemMaintHeaderRec(addItem)

                    'Get language settings from SPD_Import_Item_Languages
                    Dim languageDT As DataTable = Data.MaintItemMasterData.GetItemLanguages(masterDtl.SKU, masterDtl.VendorNumber)
                    If languageDT.Rows.Count > 0 Then
                        'For Each language row, set the front end controls
                        For Each language As DataRow In languageDT.Rows
                            Dim languageTypeID As Integer = DataHelper.SmartValues(language("Language_Type_ID"), "CInt", False)
                            Dim pli As String = DataHelper.SmartValues(language("Package_Language_Indicator"), "CStr", False)
                            Dim ti As String = DataHelper.SmartValues(language("Translation_Indicator"), "CStr", False)
                            Dim descShort As String = DataHelper.SmartValues(language("Description_Short"), "CStr", False)
                            Dim descLong As String = DataHelper.SmartValues(language("Description_Long"), "CStr", False)
                            Dim exemptEndDate As String = DataHelper.SmartValues(language("Exempt_End_Date"), "CStr", False)
                            Select Case languageTypeID
                                Case 1
                                    masterDtl.PLIEnglish = pli
                                    masterDtl.TIEnglish = ti
                                    masterDtl.EnglishShortDescription = descShort
                                    masterDtl.EnglishLongDescription = descLong
                                Case 2
                                    masterDtl.PLIFrench = pli
                                    masterDtl.TIFrench = ti
                                    masterDtl.FrenchShortDescription = descShort
                                    masterDtl.FrenchLongDescription = descLong
                                    masterDtl.ExemptEndDateFrench = exemptEndDate
                                Case 3
                                    masterDtl.PLISpanish = pli
                                    masterDtl.TISpanish = ti
                                    masterDtl.SpanishShortDescription = descShort
                                    masterDtl.SpanishLongDescription = descLong
                            End Select
                        Next
                    End If

                    ' start in on comparisons
                    CompareImportItemFields(itemHeaderID, theItem, masterDtl, userID, itemMap)

                    ' Get image for this item
                    Dim ImageID As Long = 0
                    Dim iImage As SpreadsheetGear.Shapes.IShape = ExcelFileHelper.GetImageByMap(ws, itemMap, "Image")

                    ' Save the image
                    If Not iImage Is Nothing Then

                        Dim imgRec As New NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord

                        Dim ssImg As New SpreadsheetGear.Drawing.Image(iImage)
                        Dim sdi As System.Drawing.Image = ssImg.GetBitmap()

                        'Dim sdi As System.Drawing.Image = iImage.PictureFormat.GetImage()

                        If sdi Is Nothing Then
                            AddToErrorList("UploadImportFile", "Warning: Worksheet tab """ & ws.Name & """ contains an invalid image. The image maybe corrupt or un-readable and was not uploaded. Please supply a different image.", thisSKU, thisVendorNbr)
                        Else
                            If sdi.PixelFormat = 8207 Then
                                'Image is a CMYK image.  This is not allowed for an image upload.  Output error.
                                AddToErrorList("UploadImportFile", "Warning: Worksheet tab """ & ws.Name & """ contains a CMYK formatted image, which is not web safe and was not uploaded. Please use a RGB formatted image.", thisSKU, thisVendorNbr)
                            Else

                                imgRec.File_Name = iImage.Name
                                imgRec.File_Data = ExcelFileHelper.imageToByteArray(sdi)
                                imgRec.File_Size = imgRec.File_Data.Length
                                imgRec.Image_Width_Pixels = sdi.Width
                                imgRec.Image_Height_Pixels = sdi.Height

                                Dim objMichaelsFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFile()
                                ImageID = objMichaelsFile.SaveRecord(imgRec, userID)
                                objMichaelsFile = Nothing
                            End If

                            sdi.Dispose()
                            sdi = Nothing

                        End If


                        'Save a xref to the image
                        If ImageID > 0 Then
                            ' Add new image xref
                            NLData.Michaels.ItemMaintItemFileData.AddRecord("X", itemHeaderID, ImageID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.Image, userID)   '_itemType, _itemID, imageID, _fileType, userID)

                            ' Change Record
                            Dim rowChanges As New Models.IMRowChanges(itemHeaderID)
                            rowChanges.Add(FormHelper.CreateChangeRecord(masterDtl.ImageID, "ImageID", "bigint", ImageID))
                            NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(rowChanges, userID)
                        End If
                    End If
                End If

                If isMSS Then
                    Data.BatchData.UpdateMSSBatch(batchID, True)
                End If

                ' next page!
                iCount += 1
                Dim bFound As Boolean = False

                For itemp As Integer = ws.Index + 1 To wb.Worksheets.Count - 1
                    wsName = wb.Worksheets.Item(itemp).Name
                    If ExcelFileHelper.IsValidTabName(wsName) Then
                        ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName)
                        bFound = True
                        Exit For
                    End If
                Next

                If Not bFound Then
                    ws = Nothing
                End If

                'wsName = WebConstants.IMPORT_ITEM_CHILD_WORKSHEET
                'ws = ExcelFileHelper.GetExcelWorksheet(wb, wsName.Replace("#", iCount))
            Loop
        Catch ex As Exception
            Throw ex
        Finally
        End Try

    End Sub

    Private Sub CompareImportItemFields(ByVal itemMaintHeaderID As Long, ByVal theItem As Models.ImportItemRecord, ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal userID As Integer, ByVal itemMap As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping)
        Dim runCalc As Boolean = False
        Dim strValue As String

        'If the user is a DBC/QA, then import all the role specific fields too
        If MyBase.IsAdminDBCQA Then
            FieldComparison(theItem.TaxUDA, masterDtl.TaxUDA, itemMaintHeaderID, "TaxUDA", userID)
            FieldComparison(theItem.TaxValueUDA, masterDtl.TaxValueUDA, itemMaintHeaderID, "TaxValueUDA", userID)

            If itemMap.GetMappingColumn("CustomsDescription") IsNot Nothing Then
                FieldComparison(theItem.CustomsDescription, masterDtl.CustomsDescription, itemMaintHeaderID, "CustomsDescription", userID)
            End If

            FieldComparison(theItem.PhytoTemporaryShipment, masterDtl.PhytoTemporaryShipment, itemMaintHeaderID, "PhytoTemporaryShipment", userID)
        End If

        If MyBase.isTaxMgr Then
            ' only check these two fields if the user is a tax manager, and ignore all other fields
            FieldComparison(theItem.TaxUDA, masterDtl.TaxUDA, itemMaintHeaderID, "TaxUDA", userID)
            FieldComparison(theItem.TaxValueUDA, masterDtl.TaxValueUDA, itemMaintHeaderID, "TaxValueUDA", userID)
        ElseIf MyBase.isImportMgr Then
            'Only check import manager fields if the user is an import manager, and ignore all other fields
            If itemMap.GetMappingColumn("CustomsDescription") IsNot Nothing Then
                FieldComparison(theItem.CustomsDescription, masterDtl.CustomsDescription, itemMaintHeaderID, "CustomsDescription", userID)
            End If

            Dim strTemp() As String = Split(theItem.DetailInvoiceCustomsDesc, WebConstants.MULTILINE_DELIM)

            strValue = IIf(strTemp.Length >= 0, strTemp(0), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc0, itemMaintHeaderID, "DetailInvoiceCustomsDesc0", userID)
            strValue = IIf(strTemp.Length >= 1, strTemp(1), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc1, itemMaintHeaderID, "DetailInvoiceCustomsDesc1", userID)
            strValue = IIf(strTemp.Length >= 2, strTemp(2), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc2, itemMaintHeaderID, "DetailInvoiceCustomsDesc2", userID)
            strValue = IIf(strTemp.Length >= 3, strTemp(3), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc3, itemMaintHeaderID, "DetailInvoiceCustomsDesc3", userID)
            strValue = IIf(strTemp.Length >= 4, strTemp(4), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc4, itemMaintHeaderID, "DetailInvoiceCustomsDesc4", userID)
            strValue = IIf(strTemp.Length >= 5, strTemp(5), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc5, itemMaintHeaderID, "DetailInvoiceCustomsDesc5", userID)

            strTemp = Split(theItem.ComponentMaterialBreakdown, WebConstants.MULTILINE_DELIM)
            strValue = IIf(strTemp.Length >= 0, strTemp(0), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown0, itemMaintHeaderID, "ComponentMaterialBreakdown0", userID)
            strValue = IIf(strTemp.Length >= 1, strTemp(1), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown1, itemMaintHeaderID, "ComponentMaterialBreakdown1", userID)
            strValue = IIf(strTemp.Length >= 2, strTemp(2), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown2, itemMaintHeaderID, "ComponentMaterialBreakdown2", userID)
            strValue = IIf(strTemp.Length >= 3, strTemp(3), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown3, itemMaintHeaderID, "ComponentMaterialBreakdown3", userID)
            strValue = IIf(strTemp.Length >= 4, strTemp(4), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown4, itemMaintHeaderID, "ComponentMaterialBreakdown4", userID)

            strTemp = Split(theItem.ComponentConstructionMethod, WebConstants.MULTILINE_DELIM)
            strValue = IIf(strTemp.Length >= 0, strTemp(0), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod0, itemMaintHeaderID, "ComponentConstructionMethod0", userID)
            strValue = IIf(strTemp.Length >= 1, strTemp(1), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod1, itemMaintHeaderID, "ComponentConstructionMethod1", userID)
            strValue = IIf(strTemp.Length >= 2, strTemp(2), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod2, itemMaintHeaderID, "ComponentConstructionMethod2", userID)
            strValue = IIf(strTemp.Length >= 3, strTemp(3), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod3, itemMaintHeaderID, "ComponentConstructionMethod3", userID)

            FieldComparison(theItem.QuoteReferenceNumber, masterDtl.QuoteReferenceNumber, itemMaintHeaderID, "QuoteReferenceNumber", userID)

            FieldComparison(theItem.AdditionalDutyComment, masterDtl.AdditionalDutyComment, itemMaintHeaderID, "AdditionalDutyComment", userID)
            FieldComparison(theItem.HarmonizedCodeNumber, masterDtl.HarmonizedCodeNumber, itemMaintHeaderID, "HarmonizedCodeNumber", userID)

            runCalc = runCalc Or FieldComparison(theItem.DutyPercent, masterDtl.DutyPercent, itemMaintHeaderID, "DutyPercent", userID)
            runCalc = runCalc Or FieldComparison(theItem.AdditionalDutyAmount, masterDtl.AdditionalDutyAmount, itemMaintHeaderID, "AdditionalDutyAmount", userID)

            runCalc = runCalc Or FieldComparison(theItem.SuppTariffPercent, masterDtl.SuppTariffPercent, itemMaintHeaderID, "SuppTariffPercent", userID)

            FieldComparison(theItem.PhytoTemporaryShipment, masterDtl.PhytoTemporaryShipment, itemMaintHeaderID, "PhytoTemporaryShipment", userID)
        Else

            FieldComparisonTrunc(theItem.Description.ToUpper, _TruncLenItemDesc, masterDtl.ItemDesc, itemMaintHeaderID, "ItemDesc", userID)
            FieldComparisonTrunc(theItem.VendorStyleNumber.ToUpper, _TruncLenVendorStyleNumber, masterDtl.VendorStyleNum, itemMaintHeaderID, "VendorStyleNum", userID)
            FieldComparison(theItem.AllowStoreOrder, masterDtl.AllowStoreOrder, itemMaintHeaderID, "AllowStoreOrder", userID)

            FieldComparison(theItem.InventoryControl, masterDtl.InventoryControl, itemMaintHeaderID, "InventoryControl", userID)
            FieldComparison(theItem.AutoReplenish, masterDtl.AutoReplenish, itemMaintHeaderID, "AutoReplenish", userID)
            FieldComparison(theItem.PrePriced, masterDtl.PrePriced, itemMaintHeaderID, "PrePriced", userID)
            FieldComparison(theItem.PrePricedUDA, masterDtl.PrePricedUDA, itemMaintHeaderID, "PrePricedUDA", userID)
            FieldComparison(theItem.ShippingPoint.ToUpper, masterDtl.ShippingPoint.ToUpper, itemMaintHeaderID, "ShippingPoint", userID)
            'FieldComparison(theItem.MSDSID, masterDtl.MSDSID, itemmaintheaderid, "MSDSID", userID)
            'FieldComparison(theItem.ImageID, masterDtl.ImageID, itemmaintheaderid, "ImageID", userID)
            FieldComparison(theItem.Season, masterDtl.Season, itemMaintHeaderID, "Season", userID)

            FieldComparison(theItem.CoinBattery, masterDtl.CoinBattery, itemMaintHeaderID, "CoinBattery", userID)
            'FieldComparison(theItem.TSSA, masterDtl.TSSA, itemMaintHeaderID, "TSSA", userID)
            FieldComparison(theItem.CSA, masterDtl.CSA, itemMaintHeaderID, "CSA", userID)
            FieldComparison(theItem.UL, masterDtl.UL, itemMaintHeaderID, "UL", userID)
            FieldComparison(theItem.LicenceAgreement, masterDtl.LicenceAgreement, itemMaintHeaderID, "LicenceAgreement", userID)
            FieldComparison(theItem.FumigationCertificate, masterDtl.FumigationCertificate, itemMaintHeaderID, "FumigationCertificate", userID)
            FieldComparison(theItem.KILNDriedCertificate, masterDtl.KILNDriedCertificate, itemMaintHeaderID, "KILNDriedCertificate", userID)
            FieldComparison(theItem.ChinaComInspecNumAndCCIBStickers, masterDtl.ChinaComInspecNumAndCCIBStickers, itemMaintHeaderID, "ChinaComInspecNumAndCCIBStickers", userID)
            FieldComparison(theItem.OriginalVisa, masterDtl.OriginalVisa, itemMaintHeaderID, "OriginalVisa", userID)
            FieldComparison(theItem.TextileDeclarationMidCode, masterDtl.TextileDeclarationMidCode, itemMaintHeaderID, "TextileDeclarationMidCode", userID)
            FieldComparison(theItem.QuotaChargeStatement, masterDtl.QuotaChargeStatement, itemMaintHeaderID, "QuotaChargeStatement", userID)
            FieldComparison(theItem.MSDS, masterDtl.MSDS, itemMaintHeaderID, "MSDS", userID)
            FieldComparison(theItem.TSCA, masterDtl.TSCA, itemMaintHeaderID, "TSCA", userID)
            FieldComparison(theItem.DropBallTestCert, masterDtl.DropBallTestCert, itemMaintHeaderID, "DropBallTestCert", userID)
            FieldComparison(theItem.ManMedicalDeviceListing, masterDtl.ManMedicalDeviceListing, itemMaintHeaderID, "ManMedicalDeviceListing", userID)
            FieldComparison(theItem.ManFDARegistration, masterDtl.ManFDARegistration, itemMaintHeaderID, "ManFDARegistration", userID)
            FieldComparison(theItem.CopyRightIndemnification, masterDtl.CopyRightIndemnification, itemMaintHeaderID, "CopyRightIndemnification", userID)
            FieldComparison(theItem.FishWildLifeCert, masterDtl.FishWildLifeCert, itemMaintHeaderID, "FishWildLifeCert", userID)
            FieldComparison(theItem.Proposition65LabelReq, masterDtl.Proposition65LabelReq, itemMaintHeaderID, "Proposition65LabelReq", userID)
            FieldComparison(theItem.CCCR, masterDtl.CCCR, itemMaintHeaderID, "CCCR", userID)
            FieldComparison(theItem.FormaldehydeCompliant, masterDtl.FormaldehydeCompliant, itemMaintHeaderID, "FormaldehydeCompliant", userID)
            FieldComparison(theItem.QuoteReferenceNumber, masterDtl.QuoteReferenceNumber, itemMaintHeaderID, "QuoteReferenceNumber", userID)

            If theItem.DisplayerCost <> -1 Then
                runCalc = runCalc Or FieldComparison(theItem.DisplayerCost, masterDtl.DisplayerCost, itemMaintHeaderID, "DisplayerCost", userID)
            End If
            If theItem.ProductCost <> -1 Then
                runCalc = runCalc Or FieldComparison(theItem.ProductCost, masterDtl.ProductCost, itemMaintHeaderID, "ProductCost", userID)
            End If

            If theItem.Agent <> String.Empty Then
                runCalc = runCalc Or FieldComparison(theItem.AgentType, masterDtl.AgentType, itemMaintHeaderID, "AgentType", userID)
            End If

            FieldComparison(theItem.VendorAddress1, masterDtl.VendorAddress1, itemMaintHeaderID, "VendorAddress1", userID)
            FieldComparison(theItem.VendorAddress2, masterDtl.VendorAddress2, itemMaintHeaderID, "VendorAddress2", userID)
            FieldComparison(theItem.VendorAddress3, masterDtl.VendorAddress3, itemMaintHeaderID, "VendorAddress3", userID)
            FieldComparison(theItem.VendorAddress4, masterDtl.VendorAddress4, itemMaintHeaderID, "VendorAddress4", userID)
            FieldComparison(theItem.VendorContactName, masterDtl.VendorContactName, itemMaintHeaderID, "VendorContactName", userID)
            FieldComparison(theItem.VendorContactPhone, masterDtl.VendorContactPhone, itemMaintHeaderID, "VendorContactPhone", userID)
            FieldComparison(theItem.VendorContactEmail, masterDtl.VendorContactEmail, itemMaintHeaderID, "VendorContactEmail", userID)
            FieldComparison(theItem.VendorContactFax, masterDtl.VendorContactFax, itemMaintHeaderID, "VendorContactFax", userID)
            FieldComparison(theItem.ManufactureName, masterDtl.ManufactureName, itemMaintHeaderID, "ManufactureName", userID)
            FieldComparison(theItem.ManufactureAddress1, masterDtl.ManufactureAddress1, itemMaintHeaderID, "ManufactureAddress1", userID)
            FieldComparison(theItem.ManufactureAddress2, masterDtl.ManufactureAddress2, itemMaintHeaderID, "ManufactureAddress2", userID)
            FieldComparison(theItem.ManufactureContact, masterDtl.ManufactureContact, itemMaintHeaderID, "ManufactureContact", userID)
            FieldComparison(theItem.ManufacturePhone, masterDtl.ManufacturePhone, itemMaintHeaderID, "ManufacturePhone", userID)
            FieldComparison(theItem.ManufactureEmail, masterDtl.ManufactureEmail, itemMaintHeaderID, "ManufactureEmail", userID)
            FieldComparison(theItem.ManufactureFax, masterDtl.ManufactureFax, itemMaintHeaderID, "ManufactureFax", userID)
            FieldComparison(theItem.AgentContact, masterDtl.AgentContact, itemMaintHeaderID, "AgentContact", userID)
            FieldComparison(theItem.AgentPhone, masterDtl.AgentPhone, itemMaintHeaderID, "AgentPhone", userID)
            FieldComparison(theItem.AgentEmail, masterDtl.AgentEmail, itemMaintHeaderID, "AgentEmail", userID)
            FieldComparison(theItem.AgentFax, masterDtl.AgentFax, itemMaintHeaderID, "AgentFax", userID)
            FieldComparison(theItem.HarmonizedCodeNumber, masterDtl.HarmonizedCodeNumber, itemMaintHeaderID, "HarmonizedCodeNumber", userID)

            'FieldComparison(theItem.MinimumOrderQuantity, masterDtl.MinimumOrderQuantity, itemMaintHeaderID, "MinimumOrderQuantity", userID)
            'FieldComparison(theItem.VendorMinOrderAmount, masterDtl.VendorMinOrderAmount, itemMaintHeaderID, "VendorMinOrderAmount", userID)
            FieldComparison(theItem.ProductIdentifiesAsCosmetic, masterDtl.ProductIdentifiesAsCosmetic, itemMaintHeaderID, "ProductIdentifiesAsCosmetic", userID)

            If itemMap.GetMappingColumn("PrivateBrandLabel") IsNot Nothing Then
                FieldComparison(theItem.PrivateBrandLabel, masterDtl.PrivateBrandLabel, itemMaintHeaderID, "PrivateBrandLabel", userID)
            End If

            ' Get the individual fields for this delimited field

            'Compare multilingual fields
            If itemMap.GetMappingColumn("PLIEnglish") IsNot Nothing Then
                FieldComparison(theItem.PLIEnglish, masterDtl.PLIEnglish, itemMaintHeaderID, "PLIEnglish", userID)
            End If
            If itemMap.GetMappingColumn("PLIFrench") IsNot Nothing Then
                FieldComparison(theItem.PLIFrench, masterDtl.PLIFrench, itemMaintHeaderID, "PLIFrench", userID)
            End If
            'If itemMap.GetMappingColumn("PLISpanish") IsNot Nothing Then
            '    FieldComparison(theItem.PLISpanish, masterDtl.PLISpanish, itemMaintHeaderID, "PLISpanish", userID)
            'End If
            'If itemMap.GetMappingColumn("TIEnglish") IsNot Nothing Then
            '    FieldComparison(theItem.TIEnglish, masterDtl.TIEnglish, itemMaintHeaderID, "TIEnglish", userID)
            'End If
            'If itemMap.GetMappingColumn("TIFrench") IsNot Nothing Then
            '    'NAK 5/15/2013:  Per Michaels, only upload the TI French if it is not already set to YES
            '    If masterDtl.TIFrench <> "Y" Then
            '        FieldComparison(theItem.TIFrench, masterDtl.TIFrench, itemMaintHeaderID, "TIFrench", userID)
            '    End If
            'End If
            'If itemMap.GetMappingColumn("TISpanish") IsNot Nothing Then
            '    'NAK 5/15/2013:  Per Michaels, only upload the TI Spanish if it is not already set to YES
            '    If masterDtl.TISpanish <> "Y" Then
            '        FieldComparison(theItem.TISpanish, masterDtl.TISpanish, itemMaintHeaderID, "TISpanish", userID)
            '    End If
            'End If

            If itemMap.GetMappingColumn("EnglishShortDescription") IsNot Nothing Then
                FieldComparison(theItem.EnglishShortDescription, masterDtl.EnglishShortDescription, itemMaintHeaderID, "EnglishShortDescription", userID)
            End If
            If itemMap.GetMappingColumn("EnglishLongDescription") IsNot Nothing Then
                FieldComparison(theItem.EnglishLongDescription, masterDtl.EnglishLongDescription, itemMaintHeaderID, "EnglishLongDescription", userID)
            End If

            ' FieldComparison(theItem.DetailInvoiceCustomsDesc, masterDtl.DetailInvoiceCustomsDesc, itemMaintHeaderID, "DetailInvoiceCustomsDesc", userID)
            'Dim strInput As String = theItem.DetailInvoiceCustomsDesc
            'strInput = strInput.Replace(WebConstants.MULTILINE_DELIM, "]~[")
            Dim strTemp() As String = Split(theItem.DetailInvoiceCustomsDesc, WebConstants.MULTILINE_DELIM)

            strValue = IIf(strTemp.Length >= 0, strTemp(0), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc0, itemMaintHeaderID, "DetailInvoiceCustomsDesc0", userID)
            strValue = IIf(strTemp.Length >= 1, strTemp(1), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc1, itemMaintHeaderID, "DetailInvoiceCustomsDesc1", userID)
            strValue = IIf(strTemp.Length >= 2, strTemp(2), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc2, itemMaintHeaderID, "DetailInvoiceCustomsDesc2", userID)
            strValue = IIf(strTemp.Length >= 3, strTemp(3), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc3, itemMaintHeaderID, "DetailInvoiceCustomsDesc3", userID)
            strValue = IIf(strTemp.Length >= 4, strTemp(4), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc4, itemMaintHeaderID, "DetailInvoiceCustomsDesc4", userID)
            strValue = IIf(strTemp.Length >= 5, strTemp(5), "")
            FieldComparison(strValue, masterDtl.DetailInvoiceCustomsDesc5, itemMaintHeaderID, "DetailInvoiceCustomsDesc5", userID)

            'FieldComparison(theItem.ComponentMaterialBreakdown, masterDtl.ComponentMaterialBreakdown, itemMaintHeaderID, "ComponentMaterialBreakdown", userID)
            strTemp = Split(theItem.ComponentMaterialBreakdown, WebConstants.MULTILINE_DELIM)
            strValue = IIf(strTemp.Length >= 0, strTemp(0), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown0, itemMaintHeaderID, "ComponentMaterialBreakdown0", userID)
            strValue = IIf(strTemp.Length >= 1, strTemp(1), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown1, itemMaintHeaderID, "ComponentMaterialBreakdown1", userID)
            strValue = IIf(strTemp.Length >= 2, strTemp(2), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown2, itemMaintHeaderID, "ComponentMaterialBreakdown2", userID)
            strValue = IIf(strTemp.Length >= 3, strTemp(3), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown3, itemMaintHeaderID, "ComponentMaterialBreakdown3", userID)
            strValue = IIf(strTemp.Length >= 4, strTemp(4), "")
            FieldComparison(strValue, masterDtl.ComponentMaterialBreakdown4, itemMaintHeaderID, "ComponentMaterialBreakdown4", userID)

            ' FieldComparison(theItem.ComponentConstructionMethod, masterDtl.ComponentConstructionMethod, itemMaintHeaderID, "ComponentConstructionMethod", userID)
            strTemp = Split(theItem.ComponentConstructionMethod, WebConstants.MULTILINE_DELIM)
            strValue = IIf(strTemp.Length >= 0, strTemp(0), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod0, itemMaintHeaderID, "ComponentConstructionMethod0", userID)
            strValue = IIf(strTemp.Length >= 1, strTemp(1), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod1, itemMaintHeaderID, "ComponentConstructionMethod1", userID)
            strValue = IIf(strTemp.Length >= 2, strTemp(2), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod2, itemMaintHeaderID, "ComponentConstructionMethod2", userID)
            strValue = IIf(strTemp.Length >= 3, strTemp(3), "")
            FieldComparison(strValue, masterDtl.ComponentConstructionMethod3, itemMaintHeaderID, "ComponentConstructionMethod3", userID)

            runCalc = runCalc Or FieldComparison(theItem.FOBShippingPoint, masterDtl.FOBShippingPoint, itemMaintHeaderID, "FOBShippingPoint", userID)
            runCalc = runCalc Or FieldComparison(theItem.EachInsideInnerPack, masterDtl.EachesInnerPack, itemMaintHeaderID, "EachesInnerPack", userID)
            runCalc = runCalc Or FieldComparison(theItem.EachInsideMasterCaseBox, masterDtl.EachesMasterCase, itemMaintHeaderID, "EachesMasterCase", userID)

            ' FJL
            FieldComparison(theItem.IndividualItemPackaging, masterDtl.IndividualItemPackaging, itemMaintHeaderID, "IndividualItemPackaging", userID)

            runCalc = runCalc Or FieldComparison(theItem.EachLength, masterDtl.EachCaseLength, itemMaintHeaderID, "EachCaseLength", userID)
            runCalc = runCalc Or FieldComparison(theItem.EachWidth, masterDtl.EachCaseWidth, itemMaintHeaderID, "EachCaseWidth", userID)
            runCalc = runCalc Or FieldComparison(theItem.EachHeight, masterDtl.EachCaseHeight, itemMaintHeaderID, "EachCaseHeight", userID)
            FieldComparison(theItem.EachWeight, masterDtl.EachCaseWeight, itemMaintHeaderID, "EachCaseWeight", userID)

            runCalc = runCalc Or FieldComparison(theItem.ReshippableInnerCartonLength, masterDtl.InnerCaseLength, itemMaintHeaderID, "InnerCaseLength", userID)
            runCalc = runCalc Or FieldComparison(theItem.ReshippableInnerCartonWidth, masterDtl.InnerCaseWidth, itemMaintHeaderID, "InnerCaseWidth", userID)
            runCalc = runCalc Or FieldComparison(theItem.ReshippableInnerCartonHeight, masterDtl.InnerCaseHeight, itemMaintHeaderID, "InnerCaseHeight", userID)

            'FieldComparison(theItem.EachPieceNetWeightLbsPerOunce, masterDtl.InnerCaseWeight, itemMaintHeaderID, "InnerCaseWeight", userID)
            FieldComparison(theItem.ReshippableInnerCartonWeight, masterDtl.InnerCaseWeight, itemMaintHeaderID, "InnerCaseWeight", userID)

            runCalc = runCalc Or FieldComparison(theItem.CubicFeetPerInnerCarton, masterDtl.InnerCaseCube, itemMaintHeaderID, "InnerCaseCube", userID)

            runCalc = runCalc Or FieldComparison(theItem.MasterCartonDimensionsLength, masterDtl.MasterCaseLength, itemMaintHeaderID, "MasterCaseLength", userID)
            runCalc = runCalc Or FieldComparison(theItem.MasterCartonDimensionsWidth, masterDtl.MasterCaseWidth, itemMaintHeaderID, "MasterCaseWidth", userID)
            runCalc = runCalc Or FieldComparison(theItem.MasterCartonDimensionsHeight, masterDtl.MasterCaseHeight, itemMaintHeaderID, "MasterCaseHeight", userID)
            runCalc = runCalc Or FieldComparison(theItem.WeightMasterCarton, masterDtl.MasterCaseWeight, itemMaintHeaderID, "MasterCaseWeight", userID)
            runCalc = runCalc Or FieldComparison(theItem.CubicFeetPerMasterCarton, masterDtl.MasterCaseCube, itemMaintHeaderID, "MasterCaseCube", userID)

            runCalc = runCalc Or FieldComparison(theItem.DutyPercent, masterDtl.DutyPercent, itemMaintHeaderID, "DutyPercent", userID)
            runCalc = runCalc Or FieldComparison(theItem.DutyAmount, masterDtl.DutyAmount, itemMaintHeaderID, "DutyAmount", userID)
            FieldComparison(theItem.AdditionalDutyComment, masterDtl.AdditionalDutyComment, itemMaintHeaderID, "AdditionalDutyComment", userID)
            runCalc = runCalc Or FieldComparison(theItem.AdditionalDutyAmount, masterDtl.AdditionalDutyAmount, itemMaintHeaderID, "AdditionalDutyAmount", userID)

            runCalc = runCalc Or FieldComparison(theItem.SuppTariffPercent, masterDtl.SuppTariffPercent, itemMaintHeaderID, "SuppTariffPercent", userID)
            runCalc = runCalc Or FieldComparison(theItem.SuppTariffAmount, masterDtl.SuppTariffAmount, itemMaintHeaderID, "SuppTariffAmount", userID)

            runCalc = runCalc Or FieldComparison(theItem.OceanFreightAmount, masterDtl.OceanFreightAmount, itemMaintHeaderID, "OceanFreightAmount", userID)
            runCalc = runCalc Or FieldComparison(theItem.AgentCommissionPercent, masterDtl.AgentCommissionPercent, itemMaintHeaderID, "AgentCommissionPercent", userID)
            runCalc = runCalc Or FieldComparison(theItem.AgentCommissionAmount, masterDtl.AgentCommissionAmount, itemMaintHeaderID, "AgentCommissionAmount", userID)
            runCalc = runCalc Or FieldComparison(theItem.OtherImportCostsPercent, masterDtl.OtherImportCostsPercent, itemMaintHeaderID, "OtherImportCostsPercent", userID)
            runCalc = runCalc Or FieldComparison(theItem.OtherImportCostsAmount, masterDtl.OtherImportCostsAmount, itemMaintHeaderID, "OtherImportCostsAmount", userID)
            FieldComparison(theItem.VendorComments, masterDtl.VendorComments, itemMaintHeaderID, "VendorComments", userID)
            Dim tsLandedCost As Decimal = Utilities.DataHelper.SmartValues(theItem.TotalStoreLandedCost, "CDec", False)
            If Math.Round(tsLandedCost, 6) <> Math.Round(masterDtl.TotalStoreLandedCost, 6) Then
                runCalc = True
            End If
            ' runCalc = runCalc Or FieldComparison(Math.Round(tsLandedCost, 6), Math.Round(masterDtl.TotalStoreLandedCost, 6), itemMaintHeaderID, "TotalStoreLandedCost", userID)
            ' runCalc = runCalc Or FieldComparison(theItem.DetailInvoiceCustomsDesc, masterDtl.DetailInvoiceCustomsDesc, itemMaintHeaderID, "DetailInvoiceCustomsDesc", userID)

            ' country of origin
            'If theItem.CountryOfOrigin.Length > 0 And theItem.CountryOfOriginName.Length > 0 Then
            If theItem.CountryOfOriginName.Length > 0 Then
                CountryOfOriginComparison(theItem.CountryOfOriginName, masterDtl, itemMaintHeaderID)
            End If
        End If

        'If there was a change that cuases a recalculation, then run the recalc
        If runCalc Then ' Recalc fields to ensure correctness
            Dim vendorID As Integer = Session(WebConstants.cVENDORID)
            Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
            Dim record As Models.ItemMaintItemDetailFormRecord = masterDtl.Clone    ' Get a clone of the record for comparisions
            Dim rowChanges As Models.IMRowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(itemMaintHeaderID)

            ' Merge the cloned Item Master record with changes
            FormHelper.FlattenItemMaintRecord(record, rowChanges, table)

            ' Now calc the changes
            CalculationHelper.CalcIMUploadChanges(record)

            ' Now save any changes
            FieldComparison(record.EachCaseCube, masterDtl.EachCaseCube, itemMaintHeaderID, "EachCaseCube", userID)
            FieldComparison(record.InnerCaseCube, masterDtl.InnerCaseCube, itemMaintHeaderID, "InnerCaseCube", userID)
            FieldComparison(record.MasterCaseCube, masterDtl.MasterCaseCube, itemMaintHeaderID, "MasterCaseCube", userID)
            FieldComparison(record.FOBShippingPoint, masterDtl.FOBShippingPoint, itemMaintHeaderID, "FOBShippingPoint", userID)

            FieldComparison(record.DutyAmount, masterDtl.DutyAmount, itemMaintHeaderID, "DutyAmount", userID)

            FieldComparison(record.SuppTariffAmount, masterDtl.SuppTariffAmount, itemMaintHeaderID, "SuppTariffAmount", userID)

            FieldComparison(record.OceanFreightComputedAmount, masterDtl.OceanFreightComputedAmount, itemMaintHeaderID, "OceanFreightComputedAmount", userID)
            FieldComparison(record.AgentCommissionAmount, masterDtl.AgentCommissionAmount, itemMaintHeaderID, "AgentCommissionAmount", userID)
            FieldComparison(record.OtherImportCostsAmount, masterDtl.OtherImportCostsAmount, itemMaintHeaderID, "OtherImportCostsAmount", userID)
            FieldComparison(record.ImportBurden, masterDtl.ImportBurden, itemMaintHeaderID, "ImportBurden", userID)
            FieldComparison(record.WarehouseLandedCost, masterDtl.WarehouseLandedCost, itemMaintHeaderID, "WarehouseLandedCost", userID)
            FieldComparison(record.OutboundFreight, masterDtl.OutboundFreight, itemMaintHeaderID, "OutboundFreight", userID)
            FieldComparison(record.NinePercentWhseCharge, masterDtl.NinePercentWhseCharge, itemMaintHeaderID, "NinePercentWhseCharge", userID)
            FieldComparison(Math.Round(record.TotalStoreLandedCost, 6), Math.Round(masterDtl.TotalStoreLandedCost, 6), itemMaintHeaderID, "TotalStoreLandedCost", userID)
        End If

    End Sub

    Private Function ReadImportItemFromWS(ByVal ws As SpreadsheetGear.IWorksheet, ByVal itemMap As Models.ItemMapping) As Models.ImportItemRecord
        Dim theItem As New Models.ImportItemRecord
        Dim vendorDB As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()

        'NAK 11/27/2012:  PBL is now imported rather than defaulted.  
        ' defaults
        'theItem.PrivateBrandLabel = WebConstants.LIST_VALUE_DEFAULT_PRIVATE_BRAND_LABEL

        ' RMS
        theItem.RMSSellable = WebConstants.IMPORT_RMS_DEFAULT_VALUE
        theItem.RMSOrderable = WebConstants.IMPORT_RMS_DEFAULT_VALUE
        theItem.RMSInventory = WebConstants.IMPORT_RMS_DEFAULT_VALUE

        ' Read values from excel
        theItem.MichaelsSKU = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MichaelsSKU"), "string", True)
        theItem.QuoteReferenceNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuoteReferenceNumber"), "string", True)

        Dim vendorNbr As Integer = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorNumber"), "integer", True)
        Dim theVendor As Models.VendorRecord
        If vendorNbr > 0 Then
            theItem.VendorNumber = vendorNbr
            theVendor = vendorDB.GetVendorRecord(vendorNbr)
            If Not theVendor Is Nothing AndAlso ValidationHelper.IsValidImportVendor(vendorNbr) Then
                theItem.VendorName = theVendor.VendorName
            End If

            ' now read in values that might be changes
            If MyBase.isTaxMgr Or MyBase.IsAdminDBCQA Then
                theItem.TaxUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TaxUDA"), "string", True)
                theItem.TaxValueUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TaxValueUDA"), "string", True)
            End If

            ' don't validate the country of origin
            Dim countryName As String = String.Empty
            'Dim countryCode As String = String.Empty
            countryName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CountryOfOrigin"), "string", True)
            'Dim country As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(countryName)
            'If Not country Is Nothing AndAlso country.CountryName <> String.Empty AndAlso country.CountryCode <> String.Empty Then
            '   countryName = country.CountryName
            '   countryCode = country.CountryCode
            'End If
            theItem.CountryOfOriginName = countryName
            'theItem.CountryOfOrigin = countryCode
            theItem.CountryOfOrigin = ""
            'country = Nothing

            ' force uppercase on the description
            theItem.Description = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Description"), "string", True)
            theItem.Description = theItem.Description.ToUpper

            ' force uppercase on the VPN
            theItem.VendorStyleNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorStyleNumber"), "string", True)
            theItem.VendorStyleNumber = theItem.VendorStyleNumber.ToUpper

            theItem.AllowStoreOrder = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AllowStoreOrder"), "string", True)
            theItem.InventoryControl = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "InventoryControl"), "string", True)
            theItem.AutoReplenish = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AutoReplenish"), "string", True)
            theItem.PrePriced = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrePriced"), "string", True)
            theItem.PrePricedUDA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrePricedUDA"), "string", True)
            theItem.ShippingPoint = Trim(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ShippingPoint"), "string", True)).ToUpper
            'theItem.MSDSID = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MSDSID"), "long", True)
            'theItem.ImageID = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ImageID"), "long", True)
            theItem.Season = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Season"), "string", True)

            theItem.CoinBattery = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CoinBattery"), "string", True)
            'theItem.TSSA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TSSA"), "string", True)
            theItem.CSA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CSA"), "string", True)
            theItem.UL = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "UL"), "string", True)
            ' argh! this is not how you spell "license"
            theItem.LicenceAgreement = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "LicenceAgreement"), "string", True)
            theItem.QuotaChargeStatement = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "QuotaChargeStatement"), "string", True)
            theItem.FumigationCertificate = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FumigationCertificate"), "string", True)
            If theItem.FumigationCertificate.Trim.ToUpper = "YES" Then
                theItem.FumigationCertificate = "Y"
            ElseIf theItem.FumigationCertificate = "NO" Then
                theItem.FumigationCertificate = "N"
            End If

            theItem.PhytoTemporaryShipment = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PhytoTemporaryShipment"), "string", True)
            If theItem.PhytoTemporaryShipment.Trim.ToUpper = "YES" Then
                theItem.PhytoTemporaryShipment = "Y"
            ElseIf theItem.PhytoTemporaryShipment = "NO" Then
                theItem.PhytoTemporaryShipment = "N"
            End If

            theItem.KILNDriedCertificate = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "KILNDriedCertificate"), "string", True)
            theItem.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ChinaComInspecNumAndCCIBStickers"), "string", True)
            theItem.OriginalVisa = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OriginalVisa"), "string", True)
            theItem.TextileDeclarationMidCode = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TextileDeclarationMidCode"), "string", True)
            theItem.MSDS = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MSDS"), "string", True)
            theItem.TSCA = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TSCA"), "string", True)
            theItem.DropBallTestCert = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DropBallTestCert"), "string", True)
            theItem.ManMedicalDeviceListing = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManMedicalDeviceListing"), "string", True)
            theItem.ManFDARegistration = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManFDARegistration"), "string", True)
            theItem.CopyRightIndemnification = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CopyRightIndemnification"), "string", True)
            theItem.FishWildLifeCert = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FishWildLifeCert"), "string", True)
            theItem.Proposition65LabelReq = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Proposition65LabelReq"), "string", True)
            theItem.CCCR = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CCCR"), "string", True)
            theItem.FormaldehydeCompliant = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FormaldehydeCompliant"), "string", True)

            'theItem.MinimumOrderQuantity = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MinimumOrderQuantity"), "integer", True)
            'theItem.VendorMinOrderAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorMinOrderAmount"), "decimal", False, String.Empty, 2)

            theItem.ProductIdentifiesAsCosmetic = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ProductIdentifiesAsCosmetic"), "string", True)
            If theItem.ProductIdentifiesAsCosmetic.Trim.ToUpper = "YES" Then
                theItem.ProductIdentifiesAsCosmetic = "Y"
            ElseIf theItem.ProductIdentifiesAsCosmetic = "NO" Then
                theItem.ProductIdentifiesAsCosmetic = "N"
            End If


            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Displayer_Cost"), "decimal", True, String.Empty, 4)) Then
                theItem.DisplayerCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Displayer_Cost"), "decimal", False, String.Empty, 4)
            Else
                theItem.DisplayerCost = -1
            End If
            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Product_Cost"), "decimal", True, String.Empty, 4)) Then
                theItem.ProductCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Product_Cost"), "decimal", True, String.Empty, 4)
            Else
                theItem.ProductCost = -1
            End If

            'LP changes based on the change order 14 added requirement sEPT 2009, Support 2 version12.55 and 12.8
            theItem.Agent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "Agent"), "string", True)
            If theItem.Agent <> String.Empty Then
                Dim AgentType1x As String = String.Empty, AgentType2x As String = String.Empty
                AgentType1x = Trim$(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType1X"))
                AgentType2x = Trim$(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType2X"), "string", True)) 'Trim$(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType2X")))
                'per Michaels request, only load one of those 3 agents, need to not hard code it!
                If UCase(AgentType2x) = "X" And AgentType1x = String.Empty Then
                    ' version- 12.55 detected
                    theItem.AgentType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType2"), "string", True)
                ElseIf UCase(AgentType1x) = "X" And AgentType2x = String.Empty Then
                    ' 12.55 detected
                    theItem.AgentType = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentType1"), "string", True)
                Else
                    theItem.AgentType = AgentType2x
                End If
            End If

            theItem.VendorAddress1 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress1"), "string", True)
            theItem.VendorAddress2 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress2"), "string", True)
            theItem.VendorAddress3 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress3"), "string", True)
            theItem.VendorAddress4 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorAddress4"), "string", True)
            theItem.VendorContactName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactName"), "string", True)
            theItem.VendorContactPhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactPhone"), "string", True)
            theItem.VendorContactEmail = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactEmail"), "string", True), 100)
            theItem.VendorContactFax = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorContactFax"), "string", True)
            theItem.ManufactureName = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureName"), "string", True)
            theItem.ManufactureAddress1 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureAddress1"), "string", True)
            theItem.ManufactureAddress2 = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureAddress2"), "string", True)
            theItem.ManufactureContact = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureContact"), "string", True)
            theItem.ManufacturePhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufacturePhone"), "string", True)
            theItem.ManufactureEmail = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureEmail"), "string", True), 100)
            theItem.ManufactureFax = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ManufactureFax"), "string", True)
            theItem.AgentContact = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentContact"), "string", True)
            theItem.AgentPhone = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentPhone"), "string", True)
            theItem.AgentEmail = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentEmail"), "string", True), 100)
            theItem.AgentFax = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentFax"), "string", True)
            theItem.HarmonizedCodeNumber = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "HarmonizedCodeNumber"), "string", True)
            If Not String.IsNullOrEmpty(theItem.HarmonizedCodeNumber) Then
                theItem.HarmonizedCodeNumber = Right("0000000000" & theItem.HarmonizedCodeNumber, 10)
            End If
            theItem.DetailInvoiceCustomsDesc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc"), "string", True)
            theItem.ComponentMaterialBreakdown = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ComponentMaterialBreakdown", WebConstants.MULTILINE_DELIM), "string", True)
            theItem.ComponentConstructionMethod = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ComponentConstructionMethod", WebConstants.MULTILINE_DELIM), "string", True)
            theItem.EachInsideInnerPack = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachInsideInnerPack"), "string", True)
            theItem.EachInsideMasterCaseBox = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachInsideMasterCaseBox"), "string", True)
            theItem.FOBShippingPoint = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FOBShippingPoint"), "string", True)
            theItem.DutyPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DutyPercent"), "string", True)
            theItem.DutyAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DutyAmount"), "string", True)
            theItem.AdditionalDutyComment = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AdditionalDutyComment"), "string", True)
            theItem.AdditionalDutyAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AdditionalDutyAmount"), "string", True, String.Empty, 4)

            theItem.SuppTariffPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SuppTariffPercent"), "string", True)
            theItem.SuppTariffAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SuppTariffAmount"), "string", True)

            theItem.OceanFreightAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OceanFreightAmount"), "string", True)
            theItem.AgentCommissionPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentCommissionPercent"), "decimal", True, 0, 4)
            theItem.AgentCommissionAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "AgentCommissionAmount"), "decimal", True, 0, 4)
            theItem.OtherImportCostsPercent = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OtherImportCostsPercent"), "string", True)
            theItem.OtherImportCostsAmount = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "OtherImportCostsAmount"), "string", True)
            theItem.VendorComments = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "VendorComments"), "string", True)
            theItem.TotalStoreLandedCost = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TotalStoreLandedCost"), "string", True)
            theItem.DetailInvoiceCustomsDesc = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "DetailInvoiceCustomsDesc", WebConstants.MULTILINE_DELIM), "string", True)
            ' FJL Adds
            'theItem.EachPieceNetWeightLbsPerOunce = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EachPieceNetWeightLbsPerOunce"), "string", True)

            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonWeight"), "decimal", True, String.Empty, 4)) Then
                theItem.ReshippableInnerCartonWeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonWeight"), "decimal", True, 0, 4)
            End If


            theItem.IndividualItemPackaging = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "IndividualItemPackaging"), "string", True)


            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachheight"), "decimal", True, String.Empty, 4)) Then
                theItem.EachHeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachheight"), "decimal", True, String.Empty, 4)
            End If
            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachwidth"), "decimal", True, String.Empty, 4)) Then
                theItem.EachWidth = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachwidth"), "decimal", True, String.Empty, 4)
            End If
            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachlength"), "decimal", True, String.Empty, 4)) Then
                theItem.EachLength = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachlength"), "decimal", True, String.Empty, 4)
            End If
            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachweight"), "decimal", True, String.Empty, 4)) Then
                theItem.EachWeight = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "eachweight"), "decimal", True, String.Empty, 4)
            End If
            If IsNumeric(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "cubicfeeteach"), "decimal", True, String.Empty, 4)) Then
                theItem.CubicFeetEach = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "cubicfeeteach"), "decimal", True, String.Empty, 4)
            End If

            theItem.ReshippableInnerCartonLength = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonLength"), "string", True, String.Empty, 4))
            theItem.ReshippableInnerCartonWidth = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonWidth"), "string", True, String.Empty, 4))
            theItem.ReshippableInnerCartonHeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "ReshippableInnerCartonHeight"), "string", True, String.Empty, 4))
            theItem.CubicFeetPerInnerCarton = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CubicFeetPerInnerCarton"), "string", True, String.Empty, 4)
            theItem.MasterCartonDimensionsLength = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCartonDimensionsLength"), "string", True, String.Empty, 4))
            theItem.MasterCartonDimensionsWidth = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCartonDimensionsWidth"), "string", True, String.Empty, 4))
            theItem.MasterCartonDimensionsHeight = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "MasterCartonDimensionsHeight"), "string", True, String.Empty, 4))
            theItem.CubicFeetPerMasterCarton = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CubicFeetPerMasterCarton"), "string", True, String.Empty, 4)
            theItem.WeightMasterCarton = RoundDimesionsString(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "WeightMasterCarton"), "string", True, String.Empty, 4), 4)

            'Get Multi-Lingual fields
            theItem.PLIEnglish = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLIEnglish"), "string", True).ToString.ToUpper = "YES", "Y", "N")
            theItem.PLIFrench = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLIFrench"), "string", True).ToString.ToUpper = "YES", "Y", "N")
            'theItem.PLISpanish = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PLISpanish"), "string", True).ToString.ToUpper = "YES", "Y", "N")
            'theItem.TIEnglish = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TIEnglish"), "string", True).ToString.ToUpper = "YES", "Y", "N")

            'NAK  10/29/2012:  Per Michaels, only Import Manager can upload a Customs Description
            If MyBase.isImportMgr Or MyBase.IsAdminDBCQA Then
                theItem.CustomsDescription = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "CustomsDescription"), "string", True), 255)
            End If

            'theItem.TIFrench = IIf(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TIFrench"), "string", True).ToString.ToUpper = "YES", "Y", "N")

            'NAK: 8/8/20120: Disabling TI Spanish per email from Srilatha that said Spanish TI is disabled for now.
            'theItem.TISpanish = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "TISpanish"), "boolean", True)
            theItem.TISpanish = "N"

            'NAK 2/13/2014:  Truncate Descriptions (don't trust the worksheet)
            theItem.EnglishLongDescription = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishLongDescription"), "string", True), 100)
            theItem.EnglishShortDescription = Left(DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "EnglishShortDescription"), "string", True), 17)

            'Overwrite English Descriptions if PackItemIndicator is D or DP
            If Not String.IsNullOrEmpty(theItem.PackItemIndicator) Then
                Dim englishDesc As String = ""
                If theItem.PackItemIndicator.StartsWith("DP") Then
                    englishDesc = "Display Pack"
                ElseIf theItem.PackItemIndicator.StartsWith("SB") Then
                    englishDesc = "Sellable Bundle"
                ElseIf theItem.PackItemIndicator.StartsWith("D") Then
                    englishDesc = "Displayer"
                End If
                If englishDesc.Length > 0 Then
                    theItem.EnglishLongDescription = englishDesc
                    theItem.EnglishShortDescription = englishDesc
                End If
            End If

            'NAK - Per client requirements, Non-English Description fields will not be imported.
            'theItem.FrenchLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FrenchLongDescription", ""), "string", True)
            'theItem.FrenchShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "FrenchShortDescription"), "string", True)
            'theItem.SpanishLongDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SpanishLongDescription"), "string", True)
            'theItem.SpanishShortDescription = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "SpanishShortDescription"), "string", True)

            'Get Private Brand Label (PBL) from the Spreadsheet, and compare it to the list of PBLs in the database.
            Dim pbl As String = DataHelper.SmartValues(ExcelFileHelper.GetCellByMap(ws, itemMap, "PrivateBrandLabel"), "string", True)
            Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
            If pbllvgs IsNot Nothing Then
                For Each lv As ListValue In pbllvgs.ListValues
                    If lv.DisplayText.ToUpper = pbl.ToUpper Then
                        theItem.PrivateBrandLabel = lv.Value
                    End If
                Next
            End If

        Else
            'error, vendor number not supplied or not numeric
            AddToErrorList("ReadImportItemFromWS", "Vendor number required, but not supplied for SKU '" & theItem.MichaelsSKU & "'.", theItem.MichaelsSKU)
            theItem = Nothing
        End If

        Return theItem
    End Function

#End Region

#Region " Item Maintenance aka 'Fast' Format Routines "

    Private Function ValidateItemMaintItem(ByVal theItem As Models.ItemMaintUploadChangeRecord) As Boolean

        Dim ret As Boolean = True
        Dim userID As String = Session(WebConstants.cUSERID)

        If _validationSKUList.Contains(theItem.MichaelsSKU) Then
            ret = False
            AddToErrorList("ValidateItemMaintItem", "Duplicate found for SKU '" & theItem.MichaelsSKU & "'.", theItem.MichaelsSKU, theItem.VendorNbr)
        Else
            _validationSKUList.Add(theItem.MichaelsSKU)
        End If

        If ret = True Then
            If theItem.VendorNbr.Length = 0 Then
                ret = False
                AddToErrorList("ValidateItemMaintItem", "Vendor number required, but not supplied for SKU '" & theItem.MichaelsSKU & "'.", theItem.MichaelsSKU, theItem.VendorNbr)
            Else
                Dim skuList As System.Collections.Generic.List(Of Models.ItemSearchRecord) =
                    BatchesData.SearchSKURecs(0, theItem.VendorNbr, 0, 0, String.Empty, String.Empty, theItem.MichaelsSKU,
                        String.Empty, String.Empty, String.Empty, String.Empty, userID, 0, String.Empty, String.Empty, 0, 0, String.Empty)
                If skuList.Count = 1 Then
                    Dim thisISR As Models.ItemSearchRecord = skuList.Item(0)

                    ret = CommonValidationRules(thisISR, "ValidateItemMaintItem")

                    ret = ret And ItemMaintItemRules(theItem, thisISR.SKU, thisISR.VendorNumber)

                    ' compare vendor and dept; they have to match for all items in the upload
                    If _validationMasterVendor.Length = 0 Then
                        ' this is the first item; set the master values
                        _validationMasterVendor = thisISR.VendorNumber
                        _validationMasterDept = thisISR.DeptNo
                    Else
                        If _validationMasterVendor <> thisISR.VendorNumber Or _validationMasterDept <> thisISR.DeptNo Then
                            ret = False
                            AddToErrorList("ValidateItemMaintItem", "SKU '" & thisISR.SKU & "' does not match the vendor and dept of the rest of the worksheet.", thisISR.SKU, thisISR.VendorNumber)
                        End If
                    End If

                Else
                    ret = False
                    AddToErrorList("ValidateItemMaintItem", "SKU '" & theItem.MichaelsSKU & "' not found, or not associated with vendor '" & theItem.VendorNbr & "'.", theItem.MichaelsSKU, theItem.VendorNbr)
                End If
            End If
        End If

        Return ret

    End Function

    Private Function ItemMaintItemRules(ByVal theItem As Models.ItemMaintUploadChangeRecord, ByVal sku As String, ByVal vendorNbr As String) As Boolean

        Dim ret As Boolean = True

        ret = ret And ItemMaintIsBoolean(theItem.AllowStoreOrder, "Allow Store Order", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.InventoryControl, "Inventory Control", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.AutoReplenish, "Auto Replenish", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.PrePriced, "PrePriced", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.PrePricedUDA, "Prepriced UDA", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.Cost, "Cost", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachesMasterCase, "Eaches Master Case", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachesInnerPack, "Eaches Inner Pack", sku, vendorNbr)

        ret = ret And ItemMaintIsNumeric(theItem.EachPackHeight, "Each Pack Height", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachPackWidth, "Each Pack Width", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachPackLength, "Each Pack Length", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.EachPackWeight, "Each Pack Weight", sku, vendorNbr)

        ret = ret And ItemMaintIsNumeric(theItem.InnerPackHeight, "Inner Pack Height", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.InnerPackWidth, "Inner Pack Width", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.InnerPackLength, "Inner Pack Length", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.InnerPackWeight, "Inner Pack Weight", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseHeight, "Master Case Height", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseWidth, "Master Case Width", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseLength, "Master Case Length", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.MasterCaseWeight, "Master Case Weight", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.TaxUDA, "Tax UDA", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.TaxValueUDA, "Tax Value UDA", sku, vendorNbr)
        ret = ret And ItemMaintIsBoolean(theItem.Discountable, "Discountable", sku, vendorNbr)
        ret = ret And ItemMaintIsNumeric(theItem.ImportBurden, "Import Burden", sku, vendorNbr)

        Return ret

    End Function

    Private Function ItemMaintIsBoolean(ByVal fieldValue As String, ByVal fieldName As String, ByVal sku As String, ByVal vendorNbr As String) As Boolean
        Dim ret As Boolean = True
        If fieldValue.Length > 0 Then
            Dim testValue As String = fieldValue.ToUpper
            If Not (testValue = "Y" Or testValue = "N") Then
                ret = False
                AddToErrorList("ItemMaintIsBoolean", "SKU '" & sku & "' must have Y or N (or blank) in its " & fieldName & " column.", sku, vendorNbr)
            End If
        End If
        Return ret
    End Function

    Private Function ItemMaintIsNumeric(ByVal fieldValue As String, ByVal fieldName As String, ByVal sku As String, ByVal vendorNbr As String) As Boolean
        Dim ret As Boolean = True
        If fieldValue.Length > 0 Then
            If Not IsNumeric(fieldValue) Then
                ret = False
                AddToErrorList("ItemMaintIsNumeric", "SKU '" & sku & "' has the non-numeric value '" & fieldValue & "' in its " & fieldName & " column.", sku, vendorNbr)
            End If
        End If
        Return ret
    End Function

    Private Function ReadItemMaintItemFromWS(ByVal ws As SpreadsheetGear.IWorksheet, ByVal rowIndex As Integer) As Models.ItemMaintUploadChangeRecord

        Dim theItem As New Models.ItemMaintUploadChangeRecord
        Dim upc As String

        ' column    field
        ' A (0)     Michaels SKU
        ' B (1)     Vendor Nbr
        ' etc
        theItem.MichaelsSKU = DataHelper.SmartValues(ws.Cells(rowIndex, 0).Value, "string", True)
        theItem.VendorNbr = DataHelper.SmartValues(ws.Cells(rowIndex, 1).Value, "string", True)

        Dim vendorDB As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
        Dim theVendor As Models.VendorRecord = Nothing

        If theItem.VendorNbr.Length > 0 AndAlso IsNumeric(theItem.VendorNbr) Then
            theVendor = vendorDB.GetVendorRecord(theItem.VendorNbr)
        End If

        If Not theVendor Is Nothing Then
            theItem.VendorName = theVendor.VendorName
        End If

        theItem.Dept = DataHelper.SmartValues(ws.Cells(rowIndex, 2).Value, "string", True)


        'theItem.CaseGTIN = DataHelper.SmartValues(ws.Cells(rowIndex, 4).Value, "string", True)
        'theItem.InnerGTIN = DataHelper.SmartValues(ws.Cells(rowIndex, 5).Value, "string", True)

        theItem.VPN = DataHelper.SmartValues(ws.Cells(rowIndex, 3).Value, "string", True)

        theItem.SKUDescription = DataHelper.SmartValues(ws.Cells(rowIndex, 4).Value, "string", True)

        theItem.EachesMasterCase = DataHelper.SmartValues(ws.Cells(rowIndex, 5).Value, "string", True)
        theItem.EachesInnerPack = DataHelper.SmartValues(ws.Cells(rowIndex, 6).Value, "string", True)

        theItem.AllowStoreOrder = DataHelper.SmartValues(ws.Cells(rowIndex, 7).Value, "string", True)
        theItem.InventoryControl = DataHelper.SmartValues(ws.Cells(rowIndex, 8).Value, "string", True)
        theItem.AutoReplenish = DataHelper.SmartValues(ws.Cells(rowIndex, 9).Value, "string", True)

        theItem.PrePriced = DataHelper.SmartValues(ws.Cells(rowIndex, 10).Value, "string", True)
        theItem.PrePricedUDA = DataHelper.SmartValues(ws.Cells(rowIndex, 11).Value, "string", True)

        theItem.Cost = DataHelper.SmartValues(ws.Cells(rowIndex, 12).Value, "string", True)

        theItem.EachPackHeight = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 13).Value, "string", True))
        theItem.EachPackWidth = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 14).Value, "string", True))
        theItem.EachPackLength = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 15).Value, "string", True))
        theItem.EachPackWeight = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 16).Value, "string", True), 4)

        theItem.InnerPackHeight = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 17).Value, "string", True))
        theItem.InnerPackWidth = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 18).Value, "string", True))
        theItem.InnerPackLength = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 19).Value, "string", True))
        theItem.InnerPackWeight = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 20).Value, "string", True), 4)

        theItem.MasterCaseHeight = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 21).Value, "string", True))
        theItem.MasterCaseWidth = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 22).Value, "string", True))
        theItem.MasterCaseLength = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 23).Value, "string", True))
        theItem.MasterCaseWeight = RoundDimesionsString(DataHelper.SmartValues(ws.Cells(rowIndex, 24).Value, "string", True), 4)

        theItem.CountryOfOrigin = DataHelper.SmartValues(ws.Cells(rowIndex, 25).Value, "string", True)
        theItem.TaxUDA = DataHelper.SmartValues(ws.Cells(rowIndex, 26).Value, "string", True)
        theItem.TaxValueUDA = DataHelper.SmartValues(ws.Cells(rowIndex, 27).Value, "string", True)

        theItem.Discountable = DataHelper.SmartValues(ws.Cells(rowIndex, 28).Value, "string", True)
        theItem.ImportBurden = DataHelper.SmartValues(ws.Cells(rowIndex, 29).Value, "string", True)
        theItem.ShippingPoint = DataHelper.SmartValues(ws.Cells(rowIndex, 30).Value, "string", True)
        theItem.PlanogramName = DataHelper.SmartValues(ws.Cells(rowIndex, 31).Value, "string", True)

        'Get Private Brand Label (PBL) from the Spreadsheet, and compare it to the list of PBLs in the database.
        Dim pbl As String = DataHelper.SmartValues(ws.Cells(rowIndex, 32).Value, "String", True)
        Dim pbllvgs As ListValueGroup = FormHelper.LoadListValues("RMS_PBL").GetListValueGroup("RMS_PBL")
        If pbllvgs IsNot Nothing Then
            For Each lv As ListValue In pbllvgs.ListValues
                If lv.DisplayText.ToUpper = pbl.ToUpper Then
                    theItem.PrivateBrandLabel = lv.Value
                End If
            Next
        End If

        theItem.PLIEnglish = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 33).Value, "String", True), 1).ToUpper
        theItem.PLIFrench = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 34).Value, "String", True), 1).ToUpper
        'theItem.PLISpanish = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 34).Value, "String", True), 1).ToUpper

        'NAK 11/27/2012:  Per Michaels, I am removing TI English Import on FAST sheet
        'theItem.TIEnglish = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 33).Value, "String", True), 1).ToUpper
        theItem.TIEnglish = "Y"     'Hard coded, because of validation which requires it to be YES.  very dumb...
        'theItem.TIFrench = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 35).Value, "String", True), 1).ToUpper
        theItem.TIFrench = "Y"
        theItem.TISpanish = "N" 'Default to always be no for now (TI Spanish not supported currently)

        theItem.CustomsDescription = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 35).Value, "String", True), 255)
        theItem.EnglishShortDescription = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 36).Value, "String", True), 17)
        theItem.EnglishLongDescription = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 37).Value, "String", True), 100)

        theItem.HarmonizedCodeNumber = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 38).Value, "String", True), 10)
        If Not String.IsNullOrEmpty(theItem.HarmonizedCodeNumber) Then
            theItem.HarmonizedCodeNumber = Right("0000000000" & theItem.HarmonizedCodeNumber, 10)
        End If
        theItem.CanadaHarmonizedCodeNumber = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 39).Value, "String", True), 10)
        theItem.DetailInvoiceCustomsDesc = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 40).Value, "String", True), 1000)
        theItem.ComponentMaterialBreakdown = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 41).Value, "String", True), 1000)
        'theItem.SuppTariffPercent = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 42).Value, "String", True), 1000)


        theItem.FumigationCertificate = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 42).Value, "String", True), 3).ToUpper
        If theItem.FumigationCertificate.Trim.ToUpper = "YES" Then
            theItem.FumigationCertificate = "Y"
        ElseIf theItem.FumigationCertificate.Trim.ToUpper = "NO" Then
            theItem.FumigationCertificate = "N"
        End If
        theItem.PhytoTemporaryShipment = Left(DataHelper.SmartValues(ws.Cells(rowIndex, 43).Value, "String", True), 3).ToUpper
        If theItem.PhytoTemporaryShipment.Trim.ToUpper = "YES" Then
            theItem.PhytoTemporaryShipment = "Y"
        ElseIf theItem.PhytoTemporaryShipment.Trim.ToUpper = "NO" Then
            theItem.PhytoTemporaryShipment = "N"
        End If

        If ws.Cells(rowIndex, 44) IsNot Nothing Then
            If ws.Cells(rowIndex, 44).Value IsNot Nothing Then
                upc = DataHelper.SmartValues(ws.Cells(rowIndex, 44).Value, "string", True)
                If upc.Trim() <> String.Empty Then
                    upc = FormatUPCValue(upc.Trim())
                End If
                theItem.UPC = upc
            End If
        End If



        Return theItem

    End Function

    Private Sub UploadItemMaintFile(ByVal wb As SpreadsheetGear.IWorkbook)

        ' the worksheet to use is the first one in the workbook
        Dim ws As SpreadsheetGear.IWorksheet = wb.Worksheets(0)

        Try
            Dim userID As String = Session(WebConstants.cUSERID)

            'Initialize Batch objects
            Dim batch As New NovaLibra.Coral.Data.Michaels.BatchData
            Dim batchID As Integer = 0

            ' zero based row index; the first (0) row is the column headers
            Dim rowCounter As Integer = 1
            Dim lastRow As Boolean = False
            Dim masterVendorNbr As String = String.Empty
            Dim masterDept As String = String.Empty

            Dim ret As Boolean = True
            Dim itemCount As Integer = 0
            Dim errorCount As Integer = 0

            _validationSKUList = New System.Collections.Generic.List(Of String)
            Do While Not lastRow
                Dim theItem As Models.ItemMaintUploadChangeRecord = ReadItemMaintItemFromWS(ws, rowCounter)

                If Not theItem Is Nothing Then
                    Dim thisSKU As String = theItem.MichaelsSKU
                    If thisSKU.Length = 0 Then
                        lastRow = True
                    Else
                        itemCount += 1
                        'Perform the validation again, because of Partial Batch creation logic
                        If ValidateItemMaintItem(theItem) Then
                            Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData

                            'Get Master Item
                            Dim masterDtl As Models.ItemMaintItemDetailFormRecord = NLData.Michaels.MaintItemMasterData.GetItemMaintItemDetailRecord(0, 0, theItem.MichaelsSKU, theItem.VendorNbr)

                            'Get SKU ID (Becahse of the screwy way Item Maintenance works, we need this next line to get the SKU ID from the Database.  MasterDtl's ID is always going to be 0...  stupid, eh?)
                            Dim sku As Models.ItemMasterRecord = Data.ItemMasterData.GetBySKU(theItem.MichaelsSKU)

                            'Create Batch if it has not already been created
                            If batchID <= 0 Then
                                batchID = MyBase.CreateBatch(2, masterDtl.DepartmentNum, DataHelper.SmartValues(theItem.VendorNbr, "CInt", False), theItem.VendorName, userID, masterDtl.StockCategory, masterDtl.ItemTypeAttribute, "R", "", "")
                            End If

                            ' add item to batch
                            Dim addItem As Models.ItemMaintItem = BuildBatchAddItem(batchID, userID, theItem.MichaelsSKU, sku.ItemID, theItem.VendorNbr)
                            Dim itemHeaderID As Long = NLData.Michaels.MaintItemMasterData.SaveItemMaintHeaderRec(addItem)

                            ' look up the batch
                            Dim batchDetail As Models.BatchRecord = batchDB.GetBatchRecord(batchID)

                            ' get to comparing
                            CompareItemMaintUploadFields(itemHeaderID, theItem, masterDtl, batchDetail.BatchTypeID, userID)
                        Else
                            ret = False
                            errorCount += 1
                        End If
                    End If
                Else
                    lastRow = True
                End If

                rowCounter += 1
            Loop

            Dim countMsg As String = (rowCounter - 2).ToString & " items processed."
            countMsg += "<BR>" & "Processing ends when an empty SKU is encountered."
            AddToFeedback(countMsg)

            PostValidationFeedback(ret, wb, itemCount, errorCount)

        Catch ex As Exception
            Throw ex
        End Try

    End Sub

    Private Sub CompareItemMaintUploadFields(ByVal itemMaintHeaderID As Long, ByVal theItem As Models.ItemMaintUploadChangeRecord, ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal batchTypeID As Integer, ByVal userID As Integer)
        'If the user is a DBC/QA, then import all the role specific fields too
        If MyBase.IsAdminDBCQA Then
            FieldComparison(theItem.TaxUDA, masterDtl.TaxUDA, itemMaintHeaderID, "TaxUDA", userID, True)
            FieldComparison(theItem.TaxValueUDA, masterDtl.TaxValueUDA, itemMaintHeaderID, "TaxValueUDA", userID, True)

            FieldComparison(theItem.CustomsDescription, masterDtl.CustomsDescription, itemMaintHeaderID, "CustomsDescription", userID, True)
            FieldComparison(theItem.CanadaHarmonizedCodeNumber, masterDtl.CanadaHarmonizedCodeNumber, itemMaintHeaderID, "CanadaHarmonizedCodeNumber", userID, True)

            FieldComparison(theItem.FumigationCertificate, masterDtl.FumigationCertificate, itemMaintHeaderID, "FumigationCertificate", userID, True)

            FieldComparison(theItem.PhytoTemporaryShipment, masterDtl.PhytoTemporaryShipment, itemMaintHeaderID, "PhytoTemporaryShipment", userID, True)
        End If

        If MyBase.isTaxMgr Then
            ' if the user is a tax manager, check these two fields, and ignore the rest
            FieldComparison(theItem.TaxUDA, masterDtl.TaxUDA, itemMaintHeaderID, "TaxUDA", userID, True)
            FieldComparison(theItem.TaxValueUDA, masterDtl.TaxValueUDA, itemMaintHeaderID, "TaxValueUDA", userID, True)
        ElseIf MyBase.isImportMgr Then
            'Only the Import Manager can update these 2 fields
            FieldComparison(theItem.CustomsDescription, masterDtl.CustomsDescription, itemMaintHeaderID, "CustomsDescription", userID, True)
            FieldComparison(theItem.CanadaHarmonizedCodeNumber, masterDtl.CanadaHarmonizedCodeNumber, itemMaintHeaderID, "CanadaHarmonizedCodeNumber", userID, True)

            FieldComparison(theItem.HarmonizedCodeNumber, masterDtl.HarmonizedCodeNumber, itemMaintHeaderID, "HarmonizedCodeNumber", userID, True)
            FieldComparison(theItem.DetailInvoiceCustomsDesc, masterDtl.DetailInvoiceCustomsDesc0, itemMaintHeaderID, "DetailInvoiceCustomsDesc0", userID, True)
            FieldComparison(theItem.ComponentMaterialBreakdown, masterDtl.ComponentMaterialBreakdown0, itemMaintHeaderID, "ComponentMaterialBreakdown0", userID, True)

            FieldComparison(theItem.FumigationCertificate, masterDtl.FumigationCertificate, itemMaintHeaderID, "FumigationCertificate", userID, True)
            FieldComparison(theItem.PhytoTemporaryShipment, masterDtl.PhytoTemporaryShipment, itemMaintHeaderID, "PhytoTemporaryShipment", userID, True)

        Else

            Dim runCalc As Boolean = False
            ' NOTE: Fast Sheet has no Calc imports.  Thus all percents are treated as coming form the item master and are multiplied by 100 before the calc run.  This will need to be
            '   fixed if you start uploading change records for the percents.

            'FieldComparison(theItem.CaseGTIN, masterDtl.CaseGTIN, itemMaintHeaderID, "CaseGTIN", userID, True)
            'FieldComparison(theItem.InnerGTIN, masterDtl.InnerGTIN, itemMaintHeaderID, "InnerGTIN", userID, True)

            FieldComparisonTrunc(theItem.VPN.ToUpper, _TruncLenVendorStyleNumber, masterDtl.VendorStyleNum, itemMaintHeaderID, "VendorStyleNum", userID, True)
            FieldComparisonTrunc(theItem.SKUDescription.ToUpper, _TruncLenItemDesc, masterDtl.ItemDesc, itemMaintHeaderID, "ItemDesc", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.EachesMasterCase, masterDtl.EachesMasterCase, itemMaintHeaderID, "EachesMasterCase", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.EachesInnerPack, masterDtl.EachesInnerPack, itemMaintHeaderID, "EachesInnerPack", userID, True)
            FieldComparison(theItem.AllowStoreOrder, masterDtl.AllowStoreOrder, itemMaintHeaderID, "AllowStoreOrder", userID, True)
            FieldComparison(theItem.InventoryControl, masterDtl.InventoryControl, itemMaintHeaderID, "InventoryControl", userID, True)
            FieldComparison(theItem.AutoReplenish, masterDtl.AutoReplenish, itemMaintHeaderID, "AutoReplenish", userID, True)
            FieldComparison(theItem.PrePriced, masterDtl.PrePriced, itemMaintHeaderID, "PrePriced", userID, True)
            FieldComparison(theItem.PrePricedUDA, masterDtl.PrePricedUDA, itemMaintHeaderID, "PrePricedUDA", userID, True)

            FieldComparison(theItem.FumigationCertificate, masterDtl.FumigationCertificate, itemMaintHeaderID, "FumigationCertificate", userID, True)


            ' the item cost gets a DIFFERENT FIELD NAME depending on the batch type!
            If batchTypeID = 1 Then
                ' domestic
                runCalc = runCalc Or FieldComparison(theItem.Cost, masterDtl.ItemCost, itemMaintHeaderID, "ItemCost", userID, True)
            ElseIf batchTypeID = 2 Then
                ' import
                runCalc = runCalc Or FieldComparison(theItem.Cost, masterDtl.ProductCost, itemMaintHeaderID, "ProductCost", userID, True)
            End If

            ' each Case values
            runCalc = runCalc Or FieldComparison(theItem.EachPackHeight, masterDtl.EachCaseHeight, itemMaintHeaderID, "EachCaseHeight", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.EachPackWidth, masterDtl.EachCaseWidth, itemMaintHeaderID, "EachCaseWidth", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.EachPackLength, masterDtl.EachCaseLength, itemMaintHeaderID, "EachCaseLength", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.EachPackWeight, masterDtl.EachCaseWeight, itemMaintHeaderID, "EachCaseWeight", userID, True)

            ' Inner Case values
            runCalc = runCalc Or FieldComparison(theItem.InnerPackHeight, masterDtl.InnerCaseHeight, itemMaintHeaderID, "InnerCaseHeight", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.InnerPackWidth, masterDtl.InnerCaseWidth, itemMaintHeaderID, "InnerCaseWidth", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.InnerPackLength, masterDtl.InnerCaseLength, itemMaintHeaderID, "InnerCaseLength", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.InnerPackWeight, masterDtl.InnerCaseWeight, itemMaintHeaderID, "InnerCaseWeight", userID, True)

            ' Master Case values
            runCalc = runCalc Or FieldComparison(theItem.MasterCaseHeight, masterDtl.MasterCaseHeight, itemMaintHeaderID, "MasterCaseHeight", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.MasterCaseWidth, masterDtl.MasterCaseWidth, itemMaintHeaderID, "MasterCaseWidth", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.MasterCaseLength, masterDtl.MasterCaseLength, itemMaintHeaderID, "MasterCaseLength", userID, True)
            runCalc = runCalc Or FieldComparison(theItem.MasterCaseWeight, masterDtl.MasterCaseWeight, itemMaintHeaderID, "MasterCaseWeight", userID, True)

            FieldComparison(theItem.Discountable, masterDtl.Discountable, itemMaintHeaderID, "Discountable", userID, True)

            ' Don't save the Import Burdern cuz its a calc field
            'runCalc = runCalc Or FieldComparison(theItem.ImportBurden, masterDtl.ImportBurden, itemMaintHeaderID, "ImportBurden", userID, True)

            FieldComparison(theItem.ShippingPoint, masterDtl.ShippingPoint, itemMaintHeaderID, "ShippingPoint", userID, True)
            FieldComparison(theItem.PlanogramName, masterDtl.PlanogramName, itemMaintHeaderID, "PlanogramName", userID, True)

            ' country of origin
            CountryOfOriginComparison(theItem.CountryOfOrigin, masterDtl, itemMaintHeaderID)

            FieldComparison(theItem.PrivateBrandLabel, masterDtl.PrivateBrandLabel, itemMaintHeaderID, "PrivateBrandLabel", userID, True)

            'Multilingual Fields
            FieldComparison(theItem.PLIEnglish, masterDtl.PLIEnglish, itemMaintHeaderID, "PLIEnglish", userID, True)
            FieldComparison(theItem.PLIFrench, masterDtl.PLIFrench, itemMaintHeaderID, "PLIFrench", userID, True)
            'FieldComparison(theItem.PLISpanish, masterDtl.PLISpanish, itemMaintHeaderID, "PLISpanish", userID, True)
            'NAK 11/27/2012:  Per Michaels, I am removing TI English Import on FAST sheet
            'FieldComparison(theItem.TIEnglish, masterDtl.TIEnglish, itemMaintHeaderID, "TIEnglish", userID, True)

            ''NAK 5/15/2013:  Per Michaels, only upload the TI French if it is not already set to YES
            'If masterDtl.TIFrench <> "Y" Then
            '    FieldComparison(theItem.TIFrench, masterDtl.TIFrench, itemMaintHeaderID, "TIFrench", userID, True)
            'End If
            ''NAK 5/15/2013:  Per Michaels, only upload the TI Spanish if it is not already set to YES
            'If masterDtl.TISpanish <> "Y" Then
            '    FieldComparison(theItem.TISpanish, masterDtl.TISpanish, itemMaintHeaderID, "TISpanish", userID, True)
            'End If

            FieldComparison(theItem.EnglishShortDescription, masterDtl.EnglishShortDescription, itemMaintHeaderID, "EnglishShortDescription", userID, True)
            FieldComparison(theItem.EnglishLongDescription, masterDtl.EnglishLongDescription, itemMaintHeaderID, "EnglishLongDescription", userID, True)


            'CRC Fields
            FieldComparison(theItem.HarmonizedCodeNumber, masterDtl.HarmonizedCodeNumber, itemMaintHeaderID, "HarmonizedCodeNumber", userID, True)
            FieldComparison(theItem.DetailInvoiceCustomsDesc, masterDtl.DetailInvoiceCustomsDesc0, itemMaintHeaderID, "DetailInvoiceCustomsDesc0", userID, True)
            FieldComparison(theItem.ComponentMaterialBreakdown, masterDtl.ComponentMaterialBreakdown0, itemMaintHeaderID, "ComponentMaterialBreakdown0", userID, True)

            '' calculations
            If runCalc Then

                Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
                Dim record As Models.ItemMaintItemDetailFormRecord = masterDtl.Clone    ' Get a clone of the record for comparisions
                Dim rowChanges As Models.IMRowChanges = Data.MaintItemMasterData.GetIMChangeRecordsByID(itemMaintHeaderID)
                ' Merge the cloned Item Master record with changes
                FormHelper.FlattenItemMaintRecord(record, rowChanges, table)

                If batchTypeID = 1 Then ' DOMESTIC BATCH

                    ' calc the changes
                    CalculationHelper.CalcIMDomesticUploadChanges(record)

                    ' save any changes
                    FieldComparison(record.EachCaseCube, masterDtl.EachCaseCube, itemMaintHeaderID, "EachCaseCube", userID, True)
                    FieldComparison(record.InnerCaseCube, masterDtl.InnerCaseCube, itemMaintHeaderID, "InnerCaseCube", userID, True)
                    FieldComparison(record.MasterCaseCube, masterDtl.MasterCaseCube, itemMaintHeaderID, "MasterCaseCube", userID, True)
                    FieldComparison(record.FOBShippingPoint, masterDtl.FOBShippingPoint, itemMaintHeaderID, "FOBShippingPoint", userID, True)

                ElseIf batchTypeID = 2 Then ' IMPORT BATCH

                    Dim vendorID As Integer = Session(WebConstants.cVENDORID)

                    ' calc the changes
                    CalculationHelper.CalcIMUploadChanges(record)

                    ' save any changes
                    FieldComparison(record.InnerCaseCube, masterDtl.InnerCaseCube, itemMaintHeaderID, "InnerCaseCube", userID, True)
                    FieldComparison(record.MasterCaseCube, masterDtl.MasterCaseCube, itemMaintHeaderID, "MasterCaseCube", userID, True)
                    FieldComparison(record.FOBShippingPoint, masterDtl.FOBShippingPoint, itemMaintHeaderID, "FOBShippingPoint", userID, True)

                    FieldComparison(record.DutyAmount, masterDtl.DutyAmount, itemMaintHeaderID, "DutyAmount", userID, True)

                    FieldComparison(record.SuppTariffAmount, masterDtl.SuppTariffAmount, itemMaintHeaderID, "SuppTariffAmount", userID, True)

                    FieldComparison(record.OceanFreightComputedAmount, masterDtl.OceanFreightComputedAmount, itemMaintHeaderID, "OceanFreightComputedAmount", userID, True)
                    FieldComparison(record.AgentCommissionAmount, masterDtl.AgentCommissionAmount, itemMaintHeaderID, "AgentCommissionAmount", userID, True)
                    FieldComparison(record.OtherImportCostsAmount, masterDtl.OtherImportCostsAmount, itemMaintHeaderID, "OtherImportCostsAmount", userID, True)
                    FieldComparison(record.ImportBurden, masterDtl.ImportBurden, itemMaintHeaderID, "ImportBurden", userID, True)
                    FieldComparison(record.WarehouseLandedCost, masterDtl.WarehouseLandedCost, itemMaintHeaderID, "WarehouseLandedCost", userID, True)
                    FieldComparison(record.OutboundFreight, masterDtl.OutboundFreight, itemMaintHeaderID, "OutboundFreight", userID, True)
                    FieldComparison(record.NinePercentWhseCharge, masterDtl.NinePercentWhseCharge, itemMaintHeaderID, "NinePercentWhseCharge", userID, True)
                    FieldComparison(record.TotalStoreLandedCost, masterDtl.TotalStoreLandedCost, itemMaintHeaderID, "TotalStoreLandedCost", userID, True)

                End If
            End If
        End If

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

    Private Sub PostValidationFeedback(ByVal bOK As Boolean, ByVal wb As SpreadsheetGear.IWorkbook, ByVal itemCounter As Integer, ByVal errorCounter As Integer)

        AddToFeedback(itemCounter.ToString & " items were reviewed.")
        AddToFeedback(errorCounter.ToString & " items had validation errors.")
        Dim passCounter As Integer = itemCounter - errorCounter
        AddToFeedback(passCounter.ToString & " items passed validation.")

        If Not bOK Then
            If _cancelBatch Then
                ' cancel batch gets set by certain validation rules
                Session("UPLOAD_ITEM_MAINT_WB") = Nothing
                FlushFeedback("This spreadsheet contains one or more pack items, and cannot be saved to a batch.")
                btnConfirm.Visible = False
            Else
                If errorCounter < itemCounter Then
                    ' save in memory, in case the confirm button gets clicked
                    Session("UPLOAD_ITEM_MAINT_WB") = wb
                    ' prompt
                    FlushFeedback("Click the Create Partial Batch button to save the items that passed validation.")
                    btnConfirm.Visible = True
                Else
                    Session("UPLOAD_ITEM_MAINT_WB") = Nothing
                    FlushFeedback("No items from this file can be saved to a batch.")
                    btnConfirm.Visible = False
                End If
            End If
        End If

    End Sub

    Private Function CommonValidationRules(ByVal theISR As Models.ItemSearchRecord, ByVal debugRoutineName As String) As Boolean
        Dim ret As Boolean = True

        Dim vendorID As Integer = Session(WebConstants.cVENDORID)

        If vendorID > 0 Then
            ' match thisISR.VendorNumber to vendorID
            If theISR.VendorNumber <> vendorID Then
                ret = False
                AddToErrorList(debugRoutineName, "SKU '" & theISR.SKU & "' belongs to another vendor; you cannot upload this item to a batch.", theISR.SKU, theISR.VendorNumber)
            End If
        End If

        If theISR.ItemType = "D" Or theISR.ItemType = "DP" Or theISR.ItemType = "SB" Then
            ' if any item is of type D or DP, cancel the entire file
            ret = False
            _cancelBatch = True
            AddToErrorList(debugRoutineName, "SKU '" & theISR.SKU & "' is a Pack Item; this batch cannot be created via spreadsheet.", theISR.SKU, theISR.VendorNumber)
        ElseIf theISR.IsPackParent = True Then
            ' don't allow upload of parent pack items
            ret = False
            AddToErrorList(debugRoutineName, "SKU '" & theISR.SKU & "' is a Parent Pack Item and cannot be edited by uploading a spreadsheet.", theISR.SKU, theISR.VendorNumber)
        End If

        ' only allow independently editable items
        If theISR.IndEditable = False Then
            ret = False
            AddToErrorList(debugRoutineName, "SKU '" & theISR.SKU & "' cannot be edited; it is part of an active Display Pack.", theISR.SKU, theISR.VendorNumber)
        End If

        Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
        Dim batchList As List(Of Models.BatchRecord) = batchDB.GetBatchesBySKU(theISR.SKU)

        For Each batch As Models.BatchRecord In batchList
            Select Case batch.BatchTypeID
                Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualExemptions
                    AddToErrorList(debugRoutineName, "Warning: SKU '" & theISR.SKU & "' is already in Trilingual PLI/Exemption Batch " & batch.ID & ".", theISR.SKU, theISR.VendorNumber, theISR.BatchID)
                Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualTranslations
                    AddToErrorList(debugRoutineName, "Warning: SKU '" & theISR.SKU & "' is already in Trilingual Translation Batch " & batch.ID & ".", theISR.SKU, theISR.VendorNumber, theISR.BatchID)
                Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.BulkItemMaintenance
                    AddToErrorList(debugRoutineName, "Warning: SKU '" & theISR.SKU & "' is already in Bulk Item Maintenance Batch " & batch.ID & ".", theISR.SKU, theISR.VendorNumber, theISR.BatchID)
                Case Else
                    ret = False
                    AddToErrorList(debugRoutineName, "SKU '" & theISR.SKU & "' is already in Item Maintenance batch " & batch.ID & ".", theISR.SKU, theISR.VendorNumber, theISR.BatchID)
            End Select
        Next

        Return ret
    End Function

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

    Private Sub CountryOfOriginComparison(ByVal theCOOName As String, ByVal masterDtl As Models.ItemMaintItemDetailFormRecord, ByVal itemMaintHeaderID As Integer)

        ' country of origin
        ' this is not a direct comparison; this is determining whether to add the coo as an additional coo
        Dim userID As String = Session(WebConstants.cUSERID)

        If theCOOName <> "" Then
            ' compare to the primary coo name
            ' also to any secondary names
            ' if a match is not found, we'll add this one
            Dim cooAdd As Boolean = True
            If masterDtl.CountryOfOriginName.ToUpper = theCOOName.ToUpper Then
                cooAdd = False
            End If
            For Each coo2nd As Models.ItemMasterVendorCountryRecord In masterDtl.AdditionalCOORecs
                If coo2nd.CountryOfOriginName.ToUpper = theCOOName.ToUpper Then
                    cooAdd = False
                    Exit For
                End If
            Next
            ' done comparing, now add
            If cooAdd Then
                Dim theCountry As Models.CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(theCOOName)
                If Not theCountry Is Nothing AndAlso theCountry.CountryName <> String.Empty AndAlso theCountry.CountryCode <> String.Empty Then
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOO, theCountry.CountryCode, True, userID, "", "", "", 0, False, True)
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOONAME, theCountry.CountryName, True, userID, "", "", "", 0, False, True)
                Else
                    ' In this case, the user has typed in something, but it wasn't found in the database.
                    ' We're going to let them add the change records anyway, but with different values.
                    Dim blankCOOName As String = String.Empty
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOO, blankCOOName, True, userID)
                    NLData.Michaels.MaintItemMasterData.SaveItemMaintChanges(itemMaintHeaderID, WebConstants.cADDCOONAME, theCOOName.ToUpper, True, userID)
                End If
            End If
        End If

    End Sub

    Protected Function FormatUPCValue(ByVal value As String) As String
        If value.Trim() <> String.Empty AndAlso IsNumeric(value.Trim()) Then
            Return value.Trim().PadLeft(14, "0")
        Else
            Return value
        End If
    End Function

    Private Sub ProcessApprovalTransaction(ByVal intBatchId As Long, ByVal nextStageId As Integer, ByVal intUserId As Integer, ByVal ApprType As String, Optional ByVal strNotes As String = "")
        Dim iret As Integer
        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        connection.ConnectionString = ConnectionString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "sp_SPD2_Approve_Batch"
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "WorkflowStageId"
            param.DbType = DbType.Int32
            param.Value = nextStageId
            Command.Parameters.Add(param)
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "BatchId"
            param.DbType = DbType.Int32
            param.Value = intBatchId
            Command.Parameters.Add(param)
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "UserId"
            param.DbType = DbType.Int32
            param.Value = intUserId
            Command.Parameters.Add(param)

            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "ApprType"
            param.DbType = DbType.String
            param.Value = ApprType
            Command.Parameters.Add(param)

            If strNotes <> String.Empty Then
                param = Nothing
                param = Command.CreateParameter()
                param.Direction = ParameterDirection.Input
                param.ParameterName = "Notes"
                param.DbType = DbType.String
                param.Value = strNotes
                Command.Parameters.Add(param)
            End If

            Command.Connection.Open()
            iret = Command.ExecuteScalar
            Command.Connection.Close()
        Catch ex As Exception
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
            Throw ex
        Finally
            If Not Command Is Nothing Then
                Command.Dispose()
                Command = Nothing
            End If
            If Not connection Is Nothing Then
                connection.Dispose()
                connection = Nothing
            End If
        End Try
    End Sub

End Class
