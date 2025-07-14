Imports System
Imports System.Collections
Imports System.Collections.Generic
Imports System.Data
Imports System.Data.SqlClient
Imports System.Diagnostics
Imports System.IO
Imports System.Reflection
Imports System.Text
Imports System.Web
Imports System.Web.Caching
Imports System.Web.UI.WebControls

Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Controls
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.SystemFrameworks
Imports Data = NovaLibra.Coral.Data.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Public Class ValidationHelper

#Region "Validation Constants"

    Public Const CUSTOM_FIELD_NAME As String = "-CUSTOM-"

    Public Const VALIDATION_HEADER_TEXT As String = "Validation Errors"

    Public Const VALIDATION_DISPLAY_UNKNOWN As String = "<img src=""images/valid_null.gif"" width=""22"" height=""22"" border=""0"" alt="""" />"
    Public Const VALIDATION_DISPLAY_NOTVALID As String = "<img src=""images/valid_no.gif"" width=""22"" height=""22"" border=""0"" alt="""" />"
    Public Const VALIDATION_DISPLAY_VALID As String = "<img src=""images/valid_yes.gif"" width=""22"" height=""22"" border=""0"" alt="""" />"

    Public Const VALIDATION_DISPLAY_UNKNOWN_SM As String = "<img src=""images/valid_null_small.gif"" width=""11"" height=""11"" border=""0"" alt="""" />"
    Public Const VALIDATION_DISPLAY_NOTVALID_SM As String = "<img src=""images/valid_no_small.gif"" width=""11"" height=""11"" border=""0"" alt="""" />"
    Public Const VALIDATION_DISPLAY_VALID_SM As String = "<img src=""images/valid_yes_small.gif"" width=""11"" height=""11"" border=""0"" alt="""" />"

    Public Const VALIDATION_IMAGE_UNKNOWN As String = "images/valid_null.gif"
    Public Const VALIDATION_IMAGE_NOTVALID As String = "images/valid_no.gif"
    Public Const VALIDATION_IMAGE_VALID As String = "images/valid_yes.gif"

    Public Const VALIDATION_IMAGE_UNKNOWN_SM As String = "images/valid_null_small.gif"
    Public Const VALIDATION_IMAGE_NOTVALID_SM As String = "images/valid_no_small.gif"
    Public Const VALIDATION_IMAGE_VALID_SM As String = "images/valid_yes_small.gif"

    ' if either of these change to more than one type >> MUST change item header validation
    Public Const VALIDATION_VENDOR_DOMESTIC_TYPES As String = "110"
    Public Const VALIDATION_VENDOR_IMPORT_TYPES As String = "300"

    ' UPC Validation
    Public Const VALIDATION_UPC_ERROR_LENGTH As String = "must be 14 digits."
    Public Const VALIDATION_UPC_ERROR_INVALID As String = "is not a valid UPC number."
    Public Const VALIDATION_UPC_ERROR_EXISTS As String = "already exists."
    Public Const VALIDATION_UPC_ERROR_DUPBATCH As String = "is a duplicate UPC in the batch."
    Public Const VALIDATION_UPC_ERROR_DUPWORKFLOW As String = "exists in another active batch in the new item workflow."

    ' GTIN14 Validation
    'PMO200141 GTIN14 Enhancements changes
    'Public Const VALIDATION_INNER_GTIN_ERROR_LENGTH As String = "must be 14 digits."
    'Public Const VALIDATION_INNER_GTIN_ERROR_INVALID As String = "is not a valid GTIN14 number."
    'Public Const VALIDATION_INNER_GTIN_ERROR_EXISTS As String = "already exists."
    'Public Const VALIDATION_CASE_GTIN_ERROR_LENGTH As String = "must be 14 digits."
    'Public Const VALIDATION_CASE_GTIN_ERROR_INVALID As String = "is not a valid GTIN14 number."
    'Public Const VALIDATION_CASE_GTIN_ERROR_EXISTS As String = "already exists."
    'Public Const VALIDATION_GTIN_ERROR_DUPBATCH As String = "is a duplicate UPC in the batch."
    'Public Const VALIDATION_GTIN_ERROR_DUPWORKFLOW As String = "exists in another active batch in the new item workflow."

    ' COO Validation 
    Public Const VALIDATION_COO_ERROR_INVALID As String = "is not a valid Country Of Origin."

#End Region

    Private Const CACHE_VAL_NIB As String = "VAL_NIB_"

    Public Shared Function GetValidationDoc(ByVal validationDocType As NovaLibra.Coral.SystemFrameworks.ValidationDocumentType) As NovaLibra.Coral.SystemFrameworks.ValidationDocument
        Dim doc As NovaLibra.Coral.SystemFrameworks.ValidationDocument = Nothing
        Dim obj As Object
        Dim cacheKey As String = CACHE_VAL_NIB & validationDocType.ToString()
        obj = HttpContext.Current.Cache.Get(cacheKey)
        If obj Is Nothing Then
            doc = NovaLibra.Coral.Data.Validation.GetValidationDocument(validationDocType)
            'HttpContext.Current.Cache.Insert(CACHE_VAL_NIB & validationDocType.ToString(), doc, Nothing, System.Web.Caching.Cache.NoAbsoluteExpiration, New TimeSpan(1, 0, 0))

            Dim SqlDep As SqlCacheDependency = Nothing
            Try
                SqlDep = New SqlCacheDependency(AppHelper.GetDatabaseName(), "Validation_Rules")
            Catch exDBDis As DatabaseNotEnabledForNotificationException
                Try
                    SqlCacheDependencyAdmin.EnableNotifications("AppConnection")
                Catch exPerm As UnauthorizedAccessException
                    Debug.Assert(False, "Caching failed miserably.")
                End Try
            Catch exTabDis As TableNotEnabledForNotificationException
                Try
                    SqlCacheDependencyAdmin.EnableTableForNotifications("AppConnection", "Validation_Rules")
                Catch exc As SqlException
                    Debug.Assert(False, "Caching failed miserably.")
                End Try
            Finally
                HttpContext.Current.Cache.Insert(cacheKey, doc, SqlDep)
            End Try

        Else
            doc = CType(obj, NovaLibra.Coral.SystemFrameworks.ValidationDocument)
        End If

        Return doc
    End Function

#Region "Validation Methods"

    Public Shared Function ValidateData(ByRef objectsToValidate As ArrayList) As ArrayList
        Dim valRecords As ArrayList = New ArrayList()
        For Each o As Object In objectsToValidate
            valRecords.Add(ValidateData(o))
        Next
        Return valRecords
    End Function

    Public Shared Function ValidateData(ByRef objToValidate As Object) As Models.ValidationRecord
        Dim valRecord As Models.ValidationRecord = Nothing

        If TypeOf objToValidate Is Models.ItemHeaderRecord Then
            ' Item Header Record
            valRecord = ValidateItemHeader(CType(objToValidate, Models.ItemHeaderRecord), Nothing)
        ElseIf TypeOf objToValidate Is Models.ItemRecord Then
            ' Item Record
            valRecord = ValidateItem(CType(objToValidate, Models.ItemRecord), Nothing, Nothing)
        ElseIf TypeOf objToValidate Is Models.ImportItemRecord Then
            ' Import Item Record
            valRecord = ValidateImportItem(CType(objToValidate, Models.ImportItemRecord))
        ElseIf TypeOf objToValidate Is Models.ItemMaintItemDetailFormRecord Then
            ' Item Maint Record
            'valRecord = ValidateItemMaintItem(CType(objToValidate, Models.ItemMaintItemDetailFormRecord))
        ElseIf TypeOf objToValidate Is Models.POCreationRecord Then
            'PO Creation Record
			valRecord = ValidatePOCreationHeader(CType(objToValidate, Models.POCreationRecord))
		ElseIf TypeOf objToValidate Is Models.POMaintenanceRecord Then
			'PO Maintenance Record
			valRecord = ValidatePOMaintenanceHeader(CType(objToValidate, Models.POMaintenanceRecord))
		Else
			valRecord = New Models.ValidationRecord()
        End If

        Return valRecord
	End Function

	Public Shared Function ValidateData(ByRef objToValidate As Object, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord
		Dim valRecord As Models.ValidationRecord = Nothing

		Select Case (valDocType)
			Case ValidationDocumentType.POCreationLocation
				valRecord = ValidatePOCreationLocation(CType(objToValidate, Models.POCreationRecord), workflowStageID, valDocType)
			Case ValidationDocumentType.POCreationDetail
				valRecord = ValidationPOCreationDetail(CType(objToValidate, Models.POCreationRecord), workflowStageID, valDocType)
			Case ValidationDocumentType.POCreationSKU
				valRecord = ValidatePOCreationSKU(CType(objToValidate, Models.POCreationRecord), workflowStageID, valDocType)
			Case ValidationDocumentType.POCreationSKUStore
				valRecord = ValidatePOCreationSKUStore(CType(objToValidate, Models.POCreationSKUStoreRecord), workflowStageID, valDocType)
			Case ValidationDocumentType.POMaintenanceLocation
				valRecord = ValidatePOMaintenanceLocation(CType(objToValidate, Models.POMaintenanceRecord), workflowStageID, valDocType)
			Case ValidationDocumentType.POMaintenanceSKU
				valRecord = ValidatePOMaintenanceSKU(CType(objToValidate, Models.POMaintenanceRecord), workflowStageID, valDocType)
			Case ValidationDocumentType.POMaintenanceSKUSTore
				valRecord = ValidatePOMaintenanceSKUStore(CType(objToValidate, Models.POMaintenanceSKUStoreRecord), workflowStageID, valDocType)
		End Select

		Return valRecord
	End Function

	Public Shared Function ValidateItemList(ByRef objectsToValidate As ArrayList, ByRef itemHeader As Models.ItemHeaderRecord) As ArrayList
		Return ValidateItemList(objectsToValidate, itemHeader, Nothing)
	End Function

	Public Shared Function ValidateItemList(ByRef objectsToValidate As ArrayList, ByRef itemHeader As Models.ItemHeaderRecord, ByRef request As System.Web.HttpRequest) As ArrayList
		Dim valRecords As ArrayList = New ArrayList()
		For Each o As Object In objectsToValidate
			If TypeOf o Is Models.ItemRecord Then

				' ***** do not validation if "Waiting for SKU" or "Completed" *****
				If ValidationHelper.SkipValidation(itemHeader.BatchStageType) Then
					valRecords.Add(New Models.ValidationRecord(CType(o, Models.ItemRecord).ID, Models.ItemRecordType.Item))
				Else
					valRecords.Add(ValidateItem(CType(o, Models.ItemRecord), itemHeader, request))
				End If

			End If
		Next
		Return valRecords
	End Function

	' ******************
	' * VALIDATE BATCH *
	' ******************

	Public Shared Function ValidateBatch(ByVal batchID As Long, ByVal batchType As Models.BatchType) As Models.ValidationRecord
		Dim valRecord As New Models.ValidationRecord(batchID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.Batch)
		ValidateBatch(batchID, batchType, valRecord)
		Return valRecord
	End Function

	Public Shared Sub ValidateBatch(ByVal batchID As Long, ByVal batchType As Models.BatchType, ByRef valRecord As Models.ValidationRecord)
		Dim batchLookup As Models.BatchValidationLookupRecord
		batchLookup = New Models.BatchValidationLookupRecord(batchID, batchType)

		NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.BatchValidationLookup(batchLookup)
		Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
		Dim importTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
		Dim headerTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
		Dim itemTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
		If batchLookup.BatchErrors <> Models.BatchValidationErrors.None Then
			md = MetadataHelper.GetMetadata()

			' --------------------------------------------
			' GO THROUGH THE ERRORS 
			' --------------------------------------------

			If batchLookup.BatchType = Models.BatchType.Import Then

				' --------------------------------------------
				' IMPORT
				' --------------------------------------------

				importTable = md.GetTableByID(Models.MetadataTable.Import_Items)

				'DDPMultipleParents = 1
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMultipleParents) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - Multiple parent items exist in this batch.  Only one parent item is allowed in a batch."))
				End If
				'DDPNoComponents = 2
				If batchLookup.HasError(Models.BatchValidationErrors.DDPNoComponents) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - A parent item exists in this batch, but there are no child items."))
				End If
				'DDPMissingParent = 4
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMissingParent) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - There is no parent item in this batch, but there are child items."))
				End If
				'DDPMissingTypes = 8
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMissingTypes) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("PackItemIndicator", GetColumnDisplayName(importTable, "PackItemIndicator"), "Batch Error - Some items in this batch do not contain a valid type ({0})."))
				End If
				'DDPComponentsNotActive = 16
				' ... currently, not enough data to implement this validation rule !
				'DDPPackCost1NotEqual = 32
				If batchLookup.HasError(Models.BatchValidationErrors.DDPPackCost1NotEqual) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("FOBShippingPoint", GetColumnDisplayName(importTable, "FOBShippingPoint"), "Batch Error - {0} for the parent item does not equal the sum of the children items."), ValidationRuleSeverityType.TypeWarning)
				End If
				'DDPPackCost2NotEqual = 64
				'  ... not needed for Import Batch
				'If batchLookup.HasError(Models.BatchValidationErrors.DDPPackCost2NotEqual) Then
				'End If
				'DDPSameSKUGroup = 128
				If batchLookup.HasError(Models.BatchValidationErrors.DDPSameSKUGroup) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("SKUGroup", GetColumnDisplayName(importTable, "SKUGroup"), "Batch Error - All items must have the same {0}."))
				End If
				'DPComponentsSameItemTypeAttribute = 256
				If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameItemTypeAttribute) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("ItemTypeAttribute", GetColumnDisplayName(importTable, "ItemTypeAttribute"), "Batch Error - Components must have the same {0}."))
				End If
				'DPComponentsSameStockCategory = 512
				If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameStockCategory) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("StockCategory", GetColumnDisplayName(importTable, "StockCategory"), "Batch Error - Components must have the same {0}."))
				End If
                'DPComponentsSameStockingStrategyCode = 1024
                If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameStockingStrategyCode) Then
                    valRecord.Add("BatchError", "BatchError", FormatErrorText("Stocking_Strategy_Code", GetColumnDisplayName(importTable, "Stocking_Strategy_Code"), "Batch Error - Components must have the same {0}."))
                End If

                'DPComponentsSameHybridInfo = 1024
                'If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameHybridInfo) Then
                '    'valRecord.Add("BatchError", "BatchError", _
                '    '"Batch Error - Components must have the same hybrid information(" & _
                '    'FormatErrorText("HybridType", GetColumnDisplayName(importTable, "HybridType")) & ", " & _
                '    'FormatErrorText("SourcingDC", GetColumnDisplayName(importTable, "SourcingDC")) & ").")

                '    valRecord.Add("BatchError", "BatchError", _
                '    "Batch Error - Components must have the same hybrid information(" & _
                '    FormatErrorText("HybridType", GetColumnDisplayName(importTable, "HybridType")) & ").")
                'End If

				'DPSamePrimaryVendor = 2048
				If batchLookup.HasError(Models.BatchValidationErrors.DPSamePrimaryVendor) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("Vendor", GetColumnDisplayName(importTable, "Vendor"), "Batch Error - All items must have the same {0}."))
				End If
				'DPComponentsSameHierarchy = 4096
				If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameHierarchy) Then
					valRecord.Add("BatchError", "BatchError", _
					"Batch Error - Components must have the same hierarchy(" & _
					FormatErrorText("Dept", GetColumnDisplayName(importTable, "Dept")) & ", " & _
					FormatErrorText("Class", GetColumnDisplayName(importTable, "Class")) & ", " & _
					FormatErrorText("SubClass", GetColumnDisplayName(importTable, "SubClass")) & ").")
				End If

				'DuplicateSKUs = 65536
				If batchLookup.HasError(Models.BatchValidationErrors.DuplicateSKU) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("MichaelsSKU", GetColumnDisplayName(importTable, "MichaelsSKU"), "Batch Error - {0} exists more than once in this batch."))
				End If

				'SKUGroupRules = 131072
				If batchLookup.HasError(Models.BatchValidationErrors.SKUGroupRules) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - This batch does not follow the SKU group rules for this Displayer SKU."))
				End If


			Else

				' --------------------------------------------
				' DOMESTIC
				' --------------------------------------------

				'headerTable = md.GetTableByID(NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.NewItemBatchDomesticItemHeader)
				'itemTable = md.GetTableByID(NovaLibra.Coral.SystemFrameworks.ValidationDocumentType.NewItemBatchDomesticItem)
				headerTable = md.GetTableByID(Models.MetadataTable.Item_Headers)
				itemTable = md.GetTableByID(Models.MetadataTable.Items)

				'DDPMultipleParents = 1
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMultipleParents) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - Multiple parent items exist in this batch.  Only one parent item is allowed in a batch."))
				End If
				'DDPNoComponents = 2
				If batchLookup.HasError(Models.BatchValidationErrors.DDPNoComponents) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - A parent item exists in this batch, but there are no child items."))
				End If
				'DDPMissingParent = 4
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMissingParent) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - There is no parent item in this batch, but there are child items."))
				End If
				'DDPMissingTypes = 8
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMissingTypes) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("Pack_Item_Indicator", GetColumnDisplayName(itemTable, "Pack_Item_Indicator"), "Batch Error - Some items in this batch do not contain a valid type ({0})."))
				End If
				'DDPComponentsNotActive = 16
				' ... currently, not enough data to implement this validation rule !
				'DDPPackCost1NotEqual = 32
				If batchLookup.HasError(Models.BatchValidationErrors.DDPPackCost1NotEqual) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("US_Cost", GetColumnDisplayName(itemTable, "US_Cost"), "Batch Error - {0} for the parent item does not equal the sum of the children items."), ValidationRuleSeverityType.TypeWarning)
				End If
				'DDPPackCost2NotEqual = 64
				If batchLookup.HasError(Models.BatchValidationErrors.DDPPackCost2NotEqual) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("Canada_Cost", GetColumnDisplayName(itemTable, "Canada_Cost"), "Batch Error - {0} for the parent item does not equal the sum of the children items."), ValidationRuleSeverityType.TypeWarning)
				End If
				'DDPSameSKUGroup = 128
				If batchLookup.HasError(Models.BatchValidationErrors.DDPSameSKUGroup) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("SKUGroup", GetColumnDisplayName(headerTable, "SKUGroup"), "Batch Error - All items must have the same {0}."))
				End If
				'DPComponentsSameItemTypeAttribute = 256
				' ... not needed for Domestic
				'If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameItemTypeAttribute) Then
				'End If
				'DPComponentsSameStockCategory = 512
				' ... not needed for Domestic
				'If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameStockCategory) Then
				'End If
                'DPComponentsSameStockingStrategyCode = 1024
                If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameStockingStrategyCode) Then
                    valRecord.Add("BatchError", "BatchError", FormatErrorText("Stocking_Strategy_Code", GetColumnDisplayName(headerTable, "Stocking_Strategy_Code"), "Batch Error - All items must have the same {0}."))
                End If

                'DPComponentsSameHybridInfo = 1024
                'If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameHybridInfo) Then
                '    'valRecord.Add("BatchError", "BatchError", _
                '    '"Batch Error - Components must have the same hybrid information(" & _
                '    'FormatErrorText("Hybrid_Type", GetColumnDisplayName(itemTable, "Hybrid_Type")) & ", " & _
                '    'FormatErrorText("Hybrid_Source_DC", GetColumnDisplayName(itemTable, "Hybrid_Source_DC")) & ").")
                '    valRecord.Add("BatchError", "BatchError", _
                '    "Batch Error - Components must have the same hybrid information(" & _
                '    FormatErrorText("Hybrid_Type", GetColumnDisplayName(itemTable, "Hybrid_Type")) & ").")
                'End If

				'DPSamePrimaryVendor = 2048
				' ... not needed for Domestic
				'If batchLookup.HasError(Models.BatchValidationErrors.DPSamePrimaryVendor) Then
				'End If
				'DPComponentsSameHierarchy = 4096
				If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameHierarchy) Then
					valRecord.Add("BatchError", "BatchError", _
					"Batch Error - Components must have the same hierarchy(" & _
					FormatErrorText("Class_Num", GetColumnDisplayName(itemTable, "Class_Num")) & ", " & _
					FormatErrorText("Sub_Class_Num", GetColumnDisplayName(itemTable, "Sub_Class_Num")) & ").")
				End If

				'DuplicateSKUs = 65536
				If batchLookup.HasError(Models.BatchValidationErrors.DuplicateSKU) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("Michaels_SKU", GetColumnDisplayName(itemTable, "Michaels_SKU"), "Batch Error - {0} exists more than once in this batch."))
				End If

				'SKUGroupRules = 131072
				If batchLookup.HasError(Models.BatchValidationErrors.SKUGroupRules) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - This batch does not follow the SKU group rules for this Displayer SKU."))
				End If

			End If
		End If
		batchLookup = Nothing
	End Sub

	' get column display name from metadata

	Public Shared Function GetColumnDisplayName(ByRef md As NovaLibra.Coral.SystemFrameworks.Metadata, ByVal tableName As String, ByVal columnName As String) As String
		Return GetColumnDisplayName(md.GetTableByName(tableName), columnName)
	End Function
	Public Shared Function GetColumnDisplayName(ByRef md As NovaLibra.Coral.SystemFrameworks.Metadata, ByVal tableID As Integer, ByVal columnName As String) As String
		Return GetColumnDisplayName(md.GetTableByID(tableID), columnName)
	End Function
	Public Shared Function GetColumnDisplayName(ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable, ByVal columnName As String) As String
		If Not table Is Nothing Then
			Dim column As NovaLibra.Coral.SystemFrameworks.MetadataColumn = table.GetColumnByName(columnName)
			If Not column Is Nothing Then
				Return column.DisplayName
			End If
		End If
		Return columnName
	End Function

	' ************************
	' * VALIDATE ITEM HEADER *
	' ************************

	Public Shared Function ValidateItemHeader(ByRef record As Models.ItemHeaderRecord, ByRef request As System.Web.HttpRequest) As Models.ValidationRecord
		Dim valRecord As New Models.ValidationRecord(record.ID)
		valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.ItemHeader

		' Item Header Validation
		' ----------------------
		Dim headerLookup As New Models.ItemHeaderValidationLookupRecord()
		headerLookup.Dept = record.DepartmentNum
		headerLookup.USVendorNum = record.USVendorNum
		headerLookup.USVendorType = ValidationHelper.VALIDATION_VENDOR_DOMESTIC_TYPES
		headerLookup.CanadianVendorNum = record.CanadianVendorNum
		headerLookup.CanadianVendorType = ValidationHelper.VALIDATION_VENDOR_DOMESTIC_TYPES

		Dim bRet As Boolean = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.ItemHeaderValidationLookup(headerLookup)

		If Not bRet Then
			valRecord.Add("<None>", CUSTOM_FIELD_NAME, "A System Error occurred when trying to validate the record !!!  Please contact the system administrator.")
		End If

		' Validate
		Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.NewItemBatchDomesticItemHeader)
		ValidateObject(record, request, headerLookup, valRecord, doc, record.BatchStageID)

		' Items
		If record.ItemCount <= 0 Then
			valRecord.Add(CUSTOM_FIELD_NAME, ValidationErrorHelper.VAL_ERROR_NO_ITEMS, ValidationRuleSeverityType.TypeError)
		End If

		headerLookup = Nothing

		Return valRecord
	End Function

	' *****************
	' * VALIDATE ITEM *
	' *****************

	Public Shared Function ValidateItem(ByRef record As Models.ItemRecord, ByRef parentObject As Object) As Models.ValidationRecord
		Return ValidateItem(record, parentObject, Nothing)
	End Function

	Public Shared Function ValidateItem(ByRef record As Models.ItemRecord, ByRef parentObject As Object, ByRef request As System.Web.HttpRequest) As Models.ValidationRecord
		Dim valRecord As New Models.ValidationRecord(record.ID)
		Dim itemHeader As Models.ItemHeaderRecord = Nothing
		Dim strValue As String = String.Empty, intValue As Integer = 0
		If Not parentObject Is Nothing AndAlso TypeOf parentObject Is Models.ItemHeaderRecord Then
			itemHeader = CType(parentObject, Models.ItemHeaderRecord)
		End If
		valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.Item

		If record.BatchStageType = Models.WorkflowStageType.Completed Then
			Return valRecord
		End If
		Dim itemLookup As New Models.ItemValidationLookupRecord()
		itemLookup.ID = record.ID
		If Not itemHeader Is Nothing Then
			itemLookup.Dept = itemHeader.DepartmentNum
		End If
		itemLookup.ClassNum = record.ClassNum
		itemLookup.SubClassNum = record.SubClassNum
		itemLookup.CountryOfOrigin = record.CountryOfOrigin
		itemLookup.CountryOfOriginName = record.CountryOfOriginName
		itemLookup.TaxUDA = record.TaxUDA
        itemLookup.TaxValueUDA = record.TaxValueUDA
        itemLookup.StockingStrategyCode = record.StockingStrategyCode
        itemLookup.ItemTypeAttribute = itemHeader.ItemTypeAttribute
        itemLookup.EachCaseWeight = record.EachCaseWeight
        itemLookup.InnerCaseWeight = record.InnerCaseWeight
        itemLookup.MasterCaseWeight = record.MasterCaseWeight
        itemLookup.EachesInnerPack = record.EachesInnerPack
        itemLookup.EachesMasterPack = record.EachesMasterCase

		Dim bRet As Boolean = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.ItemValidationLookup(itemLookup)

		If Not bRet Then
			valRecord.Add("<None>", CUSTOM_FIELD_NAME, "A System Error occurred when trying to validate the item record !!!  Please contact the system administrator.")
		End If

		' Validate
		Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.NewItemBatchDomesticItem)
		ValidateObject(record, request, itemLookup, valRecord, doc, record.BatchStageID, parentObject, "SPD_Item_Headers")

		Return valRecord
	End Function

	' ************************
	' * VALIDATE IMPORT ITEM *
	' ************************
	Public Shared Function ValidateImportItem(ByRef record As Models.ImportItemRecord, Optional ByVal CurrentStageID As Integer = 0, Optional ByVal CurrentStageTypeID As Models.WorkflowStageType = Models.WorkflowStageType.Unknown) As Models.ValidationRecord

		Dim valRecord As New Models.ValidationRecord(record.ID)
		valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.ImportItem
		'Dim objMichaelsIM As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemMaster()

		'Get the itemRecord current stage
		If (CurrentStageID <= 0 Or CurrentStageTypeID = Models.WorkflowStageType.Unknown) AndAlso record.Batch_ID > 0 Then
			Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch()
			Dim batchDetail As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = objMichaels.GetRecord(record.Batch_ID)
			CurrentStageID = batchDetail.WorkflowStageID
			CurrentStageTypeID = batchDetail.WorkflowStageType
			objMichaels = Nothing
		End If

		If CurrentStageTypeID = Models.WorkflowStageType.Completed Then
			Return valRecord
		End If

		Dim itemLookup As New Models.ImportItemValidationLookupRecord()
		If Not record Is Nothing Then
			itemLookup.ID = DataHelper.SmartValues(record.ID, "long", False)
            itemLookup.ParentID = DataHelper.SmartValues(record.ParentID, "long", False)
            itemLookup.PackItemIndicator = record.PackItemIndicator
            itemLookup.Dept = DataHelper.SmartValues(record.Dept, "integer", True)
            itemLookup.ClassNum = DataHelper.SmartValues(record.Class, "integer", True)
			itemLookup.SubClassNum = DataHelper.SmartValues(record.SubClass, "integer", True)
			itemLookup.CountryOfOrigin = record.CountryOfOrigin
			itemLookup.CountryOfOriginName = record.CountryOfOriginName
			itemLookup.TaxUDA = record.TaxUDA
			itemLookup.TaxValueUDA = DataHelper.SmartValues(record.TaxValueUDA, "integer", False)
			itemLookup.DeptString = record.Dept
            itemLookup.VendorNumberString = record.VendorNumber
            itemLookup.StockingStrategyCode = record.StockingStrategyCode
            itemLookup.ItemTypeAttribute = record.ItemTypeAttribute
            itemLookup.EachCaseWeight = record.EachWeight
            itemLookup.InnerCaseWeight = record.ReshippableInnerCartonWeight
            itemLookup.MasterCaseWeight = DataHelper.SmartValues(record.WeightMasterCarton, "decimal", True)
            itemLookup.EachesInnerPack = DataHelper.SmartValues(record.EachInsideInnerPack, "integer", True)
            itemLookup.EachesMasterPack = DataHelper.SmartValues(record.EachInsideMasterCaseBox, "integer", True)

            If record.PackItemIndicator = "C" Then
                Dim parentRecord As New Models.ImportItemRecord
                Dim objMichaels As New NovaLibra.Coral.Data.Michaels.ImportItemDetail()
                parentRecord = objMichaels.GetItemRecord(record.ParentID)
                itemLookup.BatchPackItemIndicator = parentRecord.PackItemIndicator
            End If

            Dim bRet As Boolean = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.ImportItemValidationLookup(itemLookup)

			If Not bRet Then
				valRecord.Add("<None>", CUSTOM_FIELD_NAME, "A System Error occurred when trying to validate the item record !!!  Please contact the system administrator.")
			End If
		End If

		' Validate
		Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.NewItemBatchImportItem)
		ValidateObject(record, Nothing, itemLookup, valRecord, doc, CurrentStageID)

		' Return 
		Return valRecord

	End Function

	Public Shared Function ValidateImportItemPack(ByRef record As Models.ImportItemRecord) As Models.ValidationRecord

		Dim valRecord As New Models.ValidationRecord(record.ID)
		valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.ImportItem

		Dim pid As Long
		Dim objMichaelsImport As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
		Dim childList As ArrayList = Nothing
		Dim objChild As Models.ImportItemChildRecord
		If record.ParentID > 0 OrElse record.ID > 0 Then
			If record.ParentID > 0 Then pid = record.ParentID Else pid = record.ID
			childList = objMichaelsImport.GetChildItems(pid, True)
		End If
		objMichaelsImport = Nothing

		'***************************************************************************
		' PACK ITEM VALIDATION
		' Validation of the parent/child items in the pack item
		'***************************************************************************

		If Not childList Is Nothing AndAlso childList.Count > 0 Then
			'parent
			objChild = CType(childList(0), Models.ImportItemChildRecord)
			If objChild.ID <> record.ID Then
				If objChild.IsValid <> NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid Then
					If objChild.RegularBatchItem Then
						valRecord.Add("PACKITEM-PARENT", CUSTOM_FIELD_NAME, "Batch Item: Regular Item 1 is not valid.", ValidationRuleSeverityType.TypeError)
					Else
						valRecord.Add("PACKITEM-PARENT", CUSTOM_FIELD_NAME, "Pack Item: Import Quote Sheet (parent) is not valid.", ValidationRuleSeverityType.TypeError)
					End If

				End If
			End If
			If childList.Count > 1 Then
				' child items
				For i As Integer = 1 To childList.Count - 1
					objChild = CType(childList(i), Models.ImportItemChildRecord)
					If objChild.ID <> record.ID Then
						If objChild.IsValid = NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid Then
							If objChild.RegularBatchItem Then
								valRecord.Add("PACKITEM-CHILD" & i, CUSTOM_FIELD_NAME, "Batch Item: Regular Item " & i + 1 & " is not valid.", ValidationRuleSeverityType.TypeError)
							Else
								valRecord.Add("PACKITEM-CHILD" & i, CUSTOM_FIELD_NAME, "Pack Item: Child " & i & " is not valid.", ValidationRuleSeverityType.TypeError)
							End If
						ElseIf objChild.IsValid = NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Unknown Then
							If objChild.RegularBatchItem Then
								valRecord.Add("PACKITEM-CHILD" & i, CUSTOM_FIELD_NAME, "Batch Item: Regular Item " & i + 1 & " has not been opened in order to be validated.", ValidationRuleSeverityType.TypeError)
							Else
								valRecord.Add("PACKITEM-CHILD" & i, CUSTOM_FIELD_NAME, "Pack Item: Child " & i & " has not been opened in order to be validated.", ValidationRuleSeverityType.TypeError)
							End If
						End If
					End If
				Next
			End If
		End If
		' clean up pack item validation
		If Not childList Is Nothing Then
			Do While childList.Count > 0
				childList.RemoveAt(0)
			Loop
			childList = Nothing
		End If

		' Return 
		Return valRecord
	End Function

	' *****************************
	' * VALIDATE ITEM MAINT BATCH *
	' *****************************

	Public Shared Function ValidateItemMaintBatch(ByVal batchID As Long, _
				 ByVal renderReadOnly As Boolean, _
				 Optional ByVal futureCostsOnly As Boolean = False) As Models.ValidationRecord
		Dim valRecord As New Models.ValidationRecord(batchID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.Batch)
		Dim objData As New Data.BatchData()
		Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(batchID)
		objData = Nothing
		ValidateItemMaintBatch(batchDetail, valRecord, renderReadOnly, futureCostsOnly)
		batchDetail = Nothing
		Return valRecord
	End Function

	Public Shared Function ValidateItemMaintBatch(ByVal batchDetail As Models.BatchRecord, _
				 ByVal renderReadOnly As Boolean, _
				 Optional ByVal futureCostsOnly As Boolean = False) As Models.ValidationRecord
		Dim valRecord As New Models.ValidationRecord(batchDetail.ID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.Batch)
		ValidateItemMaintBatch(batchDetail, valRecord, renderReadOnly, futureCostsOnly)
		Return valRecord
	End Function

	Public Shared Sub ValidateItemMaintBatch(ByVal batchID As Long, _
			   ByRef valRecord As Models.ValidationRecord, _
			   ByVal renderReadOnly As Boolean, _
			   Optional ByVal futureCostsOnly As Boolean = False)
		Dim objData As New Data.BatchData()
		Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(batchID)
		objData = Nothing
		ValidateItemMaintBatch(batchDetail, valRecord, renderReadOnly, futureCostsOnly)
		batchDetail = Nothing
	End Sub

	Public Shared Sub ValidateItemMaintBatch(ByVal batchDetail As Models.BatchRecord, _
			   ByRef valRecord As Models.ValidationRecord, _
			   ByVal renderReadOnly As Boolean, _
			   ByVal futureCostsOnly As Boolean)
		Dim batchLookup As Models.BatchValidationLookupRecord
		batchLookup = New Models.BatchValidationLookupRecord(batchDetail.ID)
		NovaLibra.Coral.BusinessFacade.Michaels.MichaelsValidation.ItemMaintBatchValidationLookup(batchLookup)
		Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
		'Dim importTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
		'Dim headerTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
		'Dim itemTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
		Dim table As NovaLibra.Coral.SystemFrameworks.MetadataTable

		If batchLookup.BatchErrors <> Models.BatchValidationErrors.None AndAlso Not futureCostsOnly Then

			' --------------------------------------------
			' GO THROUGH THE ERRORS 
			' --------------------------------------------

			' --------------------------------------------
			' ITEM MAINT ITEM
			' --------------------------------------------

			table = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)

			If batchDetail.IsPack() Then

				'DDPMultipleParents = 1
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMultipleParents) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - Multiple parent items exist in this batch.  Only one parent item is allowed in a batch."))
				End If
				'DDPNoComponents = 2
				If batchLookup.HasError(Models.BatchValidationErrors.DDPNoComponents) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - A parent item exists in this batch, but there are no child items."))
				End If
				'DDPMissingParent = 4
				If batchLookup.HasError(Models.BatchValidationErrors.DDPMissingParent) Then
					valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - There is no parent item in this batch, but there are child items."))
				End If
				'DDPMissingTypes = 8
				' *** removed the following validation rule for item maintenance as regular items are allowed in the batch
				'If batchLookup.HasError(Models.BatchValidationErrors.DDPMissingTypes) Then
				'    valRecord.Add("BatchError", "BatchError", FormatErrorText("PackItemIndicator", GetColumnDisplayName(table, "PackItemIndicator"), "Batch Error - Some items in this batch do not contain a valid type ({0})."))
				'End If
				'DDPComponentsNotActive = 16
				' ... currently, not enough data to implement this validation rule !
				'DDPPackCost1NotEqual = 32
				If batchLookup.HasError(Models.BatchValidationErrors.DDPPackCost1NotEqual) Then
					If batchDetail.IsDomesticBatch() Then
						valRecord.Add("BatchError", "BatchError", FormatErrorText("ItemCost", GetColumnDisplayName(table, "ItemCost"), "Batch Warning - {0} for the parent item does not equal the sum of the children items."), ValidationRuleSeverityType.TypeWarning)
					Else
						valRecord.Add("BatchError", "BatchError", FormatErrorText("ProductCost", GetColumnDisplayName(table, "ProductCost"), "Batch Warning - {0} for the parent item does not equal the sum of the children items."), ValidationRuleSeverityType.TypeWarning)
					End If
                End If

                'NAK - Per Michaels decision on 1/17/2012, remove weight warning validation.
                'DDPMasterCaseWeightNotEqual = 262144
                'If batchLookup.HasError(Models.BatchValidationErrors.DDPMasterCaseWeightNotEqual) Then
                '   valRecord.Add("BatchError", "BatchError", FormatErrorText("MasterCaseWeight", GetColumnDisplayName(table, "MasterCaseWeight"), "Batch Warning - {0} for the parent item does not equal the sum of the children items."), ValidationRuleSeverityType.TypeWarning)
                'End If

                'DDPPackCost2NotEqual = 64
                '  ... not needed for Import Batch
                'If batchLookup.HasError(Models.BatchValidationErrors.DDPPackCost2NotEqual) Then
                'End If
                'DDPSameSKUGroup = 128
                If batchLookup.HasError(Models.BatchValidationErrors.DDPSameSKUGroup) Then
                    valRecord.Add("BatchError", "BatchError", FormatErrorText("SKUGroup", GetColumnDisplayName(table, "SKUGroup"), "Batch Error - All items must have the same {0}."))
                End If
                'DPComponentsSameItemTypeAttribute = 256
                If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameItemTypeAttribute) Then
                    valRecord.Add("BatchError", "BatchError", FormatErrorText("ItemTypeAttribute", GetColumnDisplayName(table, "ItemTypeAttribute"), "Batch Error - Components must have the same {0}."))
                End If
                'DPComponentsSameStockCategory = 512
                If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameStockCategory) Then
                    valRecord.Add("BatchError", "BatchError", FormatErrorText("StockCategory", GetColumnDisplayName(table, "StockCategory"), "Batch Error - Components must have the same {0}."))
                End If
                'DPComponentsSameStockingStrategyCode = 1024
                If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameStockingStrategyCode) Then
                    valRecord.Add("BatchError", "BatchError", FormatErrorText("StockingStrategyCode", GetColumnDisplayName(table, "StockingStrategyCode"), "Batch Error - Components must have the same {0}."))
                End If

                'DPComponentsSameHybridInfo = 1024
                'If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameHybridInfo) Then
                '    'valRecord.Add("BatchError", "BatchError", _
                '    '"Batch Error - Components must have the same hybrid information(" & _
                '    'FormatErrorText("HybridType", GetColumnDisplayName(table, "HybridType")) & ", " & _
                '    'FormatErrorText("HybridSourceDC", GetColumnDisplayName(table, "HybridSourceDC")) & ").")

                '    valRecord.Add("BatchError", "BatchError", _
                '    "Batch Error - Components must have the same hybrid information(" & _
                '    FormatErrorText("HybridType", GetColumnDisplayName(table, "HybridType")) & ").")
                'End If

            End If

            'DPSamePrimaryVendor = 2048
            If batchLookup.HasError(Models.BatchValidationErrors.DPSamePrimaryVendor) Then
                valRecord.Add("BatchError", "BatchError", FormatErrorText("VendorNumber", GetColumnDisplayName(table, "VendorNumber"), "Batch Error - All items must have the same Primary {0}."))
            End If

            If batchDetail.IsPack() Then

                'DPComponentsSameHierarchy = 4096
                If batchLookup.HasError(Models.BatchValidationErrors.DPComponentsSameHierarchy) Then
                    valRecord.Add("BatchError", "BatchError", _
                    "Batch Error - Components must have the same hierarchy(" & _
                    FormatErrorText("DepartmentNum", GetColumnDisplayName(table, "DepartmentNum")) & ", " & _
                    FormatErrorText("ClassNum", GetColumnDisplayName(table, "ClassNum")) & ", " & _
                    FormatErrorText("SubClassNum", GetColumnDisplayName(table, "SubClassNum")) & ").")
                End If

            End If

            'NoItems = 8192
            If batchLookup.HasError(Models.BatchValidationErrors.NoItems) Then
                valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - No items exist in this batch.  There must be at least one item in the batch."))
            End If

            'NoChanges = 16384
            If batchLookup.HasError(Models.BatchValidationErrors.NoChanges) AndAlso Not batchLookup.HasError(Models.BatchValidationErrors.NoItems) Then
                valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - There are no changes for this D or DP batch. This batch needs to have at least one change. Please remove this batch if no changes are needed."))
            End If

            'DDPComponentQtyZero = 32768
            If batchLookup.HasError(Models.BatchValidationErrors.DDPComponentQtyZero) AndAlso Not batchLookup.HasError(Models.BatchValidationErrors.NoItems) Then
                valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - At least 1 component must have a Component Qty greater than zero for this D or DP batch."))
            End If

            If batchDetail.IsPack() Then
                'SKUGroupRules = 131072
                If batchLookup.HasError(Models.BatchValidationErrors.SKUGroupRules) Then
                    valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - This batch does not follow the SKU group rules for this Displayer SKU."))
                End If
            End If

        End If

        If batchLookup.FutureCostSKUs IsNot Nothing Then

            For Each c As Models.BatchFutureCost In batchLookup.FutureCostSKUs
                If c.FutureCostExists OrElse c.FutureCostCancelled Then
                    valRecord.Add("FutureCostExists", "FutureCostExists", FormatErrorText("", "", "{}Batch Warning - " & FormatFutureCostMessage(c.ID, c.SKU, c.FutureCostExists, c.FutureCostCancelled, renderReadOnly)), ValidationRuleSeverityType.TypeWarning)
                End If
            Next
        End If

        batchLookup = Nothing
	End Sub

	' ****************************
	' * VALIDATE ITEM MAINT ITEM *
	' ****************************

	Public Shared Function ValidateItemMaintItemList(ByRef objectsToValidate As ArrayList, ByRef tableChanges As Models.IMTableChanges, ByRef batchDetail As Models.BatchRecord) As ArrayList
		Return ValidateItemMaintItemList(objectsToValidate, tableChanges, batchDetail.WorkflowStageID, batchDetail.WorkflowStageType, batchDetail.IsPack())
	End Function

	Public Shared Function ValidateItemMaintItemList(ByRef objectsToValidate As ArrayList, ByRef tableChanges As Models.IMTableChanges, ByVal CurrentStageID As Integer, ByVal CurrentStageTypeID As Models.WorkflowStageType, ByVal isPack As Boolean) As ArrayList
		Dim valRecords As ArrayList = New ArrayList()
		Dim rec As Models.ItemMaintItemDetailFormRecord
        For Each o As Object In objectsToValidate
            If TypeOf o Is Models.ItemMaintItemDetailFormRecord Then
                rec = CType(o, Models.ItemMaintItemDetailFormRecord)
                'Redoing language loading, because item maintenance can't just load a record once. . .
                'Get language settings from SPD_Import_Item_Languages
                Dim languageDT As DataTable = Data.MaintItemMasterData.GetItemLanguages(rec.SKU, rec.VendorNumber)
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
                                rec.PLIEnglish = pli
                                rec.TIEnglish = ti
                                rec.EnglishShortDescription = descShort
                                rec.EnglishLongDescription = descLong
                            Case 2
                                rec.PLIFrench = pli
                                rec.TIFrench = ti
                                rec.FrenchShortDescription = descShort
                                rec.FrenchLongDescription = descLong
                                rec.ExemptEndDateFrench = exemptEndDate
                            Case 3
                                rec.PLISpanish = pli
                                rec.TISpanish = ti
                                rec.SpanishShortDescription = descShort
                                rec.SpanishLongDescription = descLong
                        End Select
                    Next
                End If

                ' ***** do not validation if "Waiting for SKU" or "Completed" *****
                If ValidationHelper.SkipValidation(CurrentStageTypeID) Then
                    'valRecords.Add(New Models.ValidationRecord(rec.ID, Models.ItemRecordType.ItemMaintItem))
                    valRecords.Add(ValidateItemMaintItemForFutureCostsOnly(rec, tableChanges.GetRow(rec.ID, True), False))
                Else
                    valRecords.Add(ValidateItemMaintItem(rec, tableChanges.GetRow(rec.ID, True), CurrentStageID, CurrentStageTypeID, isPack, False))
                End If

            End If
        Next
		Return valRecords
	End Function

	Public Shared Function ValidateItemMaintItem(ByRef record As Models.ItemMaintItemDetailFormRecord, _
				ByRef rowChanges As Models.IMRowChanges, _
				ByRef batchDetail As Models.BatchRecord, _
				ByVal renderReadOnly As Boolean) As Models.ValidationRecord
		Return ValidateItemMaintItem(record, rowChanges, batchDetail.WorkflowStageID, batchDetail.WorkflowStageType, batchDetail.IsPack(), renderReadOnly)
	End Function

	Public Shared Function ValidateItemMaintItem(ByRef record As Models.ItemMaintItemDetailFormRecord, _
				ByRef rowChanges As Models.IMRowChanges, _
				ByVal CurrentStageID As Integer, _
				ByVal CurrentStageTypeID As Models.WorkflowStageType, _
				ByVal isPack As Boolean, _
				ByVal renderReadOnly As Boolean) As Models.ValidationRecord
		Dim valRecord As New Models.ValidationRecord(record.ID)
		Dim strValue As String = String.Empty, intValue As Integer = 0
		Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
		valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.ItemMaintItem

		If ValidationHelper.SkipValidation(CurrentStageTypeID) Then
			Return valRecord
		End If

		Dim mergedRecord As Models.ItemMaintItemDetailFormRecord = record.Clone()

		' Flammerge (flatten / merge) record
		FormHelper.FlattenItemMaintRecord(mergedRecord, rowChanges, table)

		Dim itemLookup As New Models.ItemMaintItemValidationLookupRecord()
		itemLookup.ID = mergedRecord.ID
		itemLookup.Dept = mergedRecord.DepartmentNum
		itemLookup.ClassNum = mergedRecord.ClassNum
		itemLookup.SubClassNum = mergedRecord.SubClassNum
		itemLookup.CountryOfOrigin = mergedRecord.CountryOfOrigin
		itemLookup.CountryOfOriginName = mergedRecord.CountryOfOriginName
		itemLookup.TaxUDA = mergedRecord.TaxUDA
		If mergedRecord.TaxValueUDA >= Integer.MinValue And mergedRecord.TaxValueUDA <= Integer.MaxValue Then
			itemLookup.TaxValueUDA = mergedRecord.TaxValueUDA
		End If
		itemLookup.DeptString = mergedRecord.DepartmentNum.ToString()
        itemLookup.VendorNumberString = mergedRecord.VendorNumber.ToString()
        itemLookup.StockingStrategyCode = mergedRecord.StockingStrategyCode
        itemLookup.ItemTypeAttribute = mergedRecord.ItemTypeAttribute
        itemLookup.EachCaseWeight = mergedRecord.EachCaseWeight
        itemLookup.InnerCaseWeight = mergedRecord.InnerCaseWeight
        itemLookup.MasterCaseWeight = mergedRecord.MasterCaseWeight
        itemLookup.EachesInnerPack = mergedRecord.EachesInnerPack
        itemLookup.EachesMasterPack = mergedRecord.EachesMasterCase

        'itemLookup.InnerGTIN = mergedRecord.InnerGTIN
        'itemLookup.CaseGTIN = mergedRecord.CaseGTIN

        ' add countries (from record)
        Dim i As Integer
		If record.AdditionalCOORecCount > 0 Then
			For i = 0 To record.AdditionalCOORecCount - 1
				itemLookup.AddCountry(record.AdditionalCOORecs.Item(i).CountryOfOriginName, record.AdditionalCOORecs.Item(i).CountryOfOrigin)
			Next
		End If
		' add countries (from changes, if they exist)
		Dim cooName As String = String.Empty
		Dim cooCode As String = String.Empty
		Dim addCOOCode As String = String.Empty
		Dim addCOOName As String = String.Empty
		Dim arrAddCOOCodes() As String
		Dim arrAddCOONames() As String
		Dim saveAddCOO As New List(Of Models.CountryRecord)
		Dim n As Integer
		Dim coo As Models.CountryRecord
		If rowChanges.ChangeExists(WebConstants.cADDCOONAME) Then
			addCOOName = rowChanges.GetCellChange(WebConstants.cADDCOONAME).FieldValue
			arrAddCOONames = addCOOName.Split(WebConstants.cPIPE)
			For n = 0 To arrAddCOONames.Length - 1
				coo = New Models.CountryRecord()
				coo.CountryName = arrAddCOONames(n)
				saveAddCOO.Add(coo)
			Next
		End If
		If rowChanges.ChangeExists(WebConstants.cADDCOO) Then
			addCOOCode = rowChanges.GetCellChange(WebConstants.cADDCOO).FieldValue
			arrAddCOOCodes = addCOOCode.Split(WebConstants.cPIPE)
			For n = 0 To arrAddCOOCodes.Length - 1
				If n < saveAddCOO.Count Then
					saveAddCOO.Item(n).CountryCode = arrAddCOOCodes(n)
				End If
			Next
		End If
		For i = 0 To saveAddCOO.Count - 1
			itemLookup.AddCountry(saveAddCOO.Item(i))
        Next

		Dim bRet As Boolean = Data.ValidationData.ItemMaintItemValidationLookup(itemLookup)

		If Not bRet Then
			valRecord.Add("<None>", CUSTOM_FIELD_NAME, "A System Error occurred when trying to validate the item record !!!  Please contact the system administrator.")
		End If

        If rowChanges IsNot Nothing AndAlso Not isPack Then
            'Display error if there are no changes, or if there is one change, and it is the Quote Reference Number
            If rowChanges.RowRecords.Count <= 0 Or (rowChanges.RowRecords.Count = 1 And rowChanges.ChangeExists("QuoteReferenceNumber")) Then
                valRecord.Add("<None>", CUSTOM_FIELD_NAME, "There are no changes for this item. An item has to have at least one change. Please remove this item if no changes are needed.")
            End If
        End If

		' Validate
		Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.ItemMaintBatchItemMaintItem)
		ValidateObject(mergedRecord, Nothing, itemLookup, valRecord, doc, CurrentStageID, Nothing, String.Empty, record, rowChanges, renderReadOnly)

		mergedRecord = Nothing

		Return valRecord
	End Function

	Public Shared Function ValidateItemMaintItemForFutureCostsOnly(ByRef record As Models.ItemMaintItemDetailFormRecord, _
				ByRef rowChanges As Models.IMRowChanges, _
				ByVal renderReadOnly As Boolean) As Models.ValidationRecord
		Dim valRecord As New Models.ValidationRecord(record.ID)
		Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
		valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.ItemMaintItem
		Dim column As NovaLibra.Coral.SystemFrameworks.MetadataColumn

		' Validate
		' Existing Future Cost Change
		Dim futureCostCancelled As Boolean = False
		If (rowChanges IsNot Nothing AndAlso rowChanges.ChangeExists("FutureCostStatus")) Then futureCostCancelled = True
		If record.FutureCostExists OrElse futureCostCancelled Then
			column = table.GetColumnByName("FutureCostExists")
			valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, ("{}" & FormatFutureCostMessage(record.ID, record.SKU, record.FutureCostExists, futureCostCancelled, renderReadOnly))), ValidationRuleSeverityType.TypeWarning)
		End If

		Return valRecord
	End Function

    ' **********************************
    ' * VALIDATE BULK ITEM MAINT BATCH *
    ' **********************************

    Public Shared Function ValidateBulkItemMaintBatch(ByVal batchDetail As Models.BatchRecord, _
                 ByVal renderReadOnly As Boolean, _
                 Optional ByVal futureCostsOnly As Boolean = False) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(batchDetail.ID, NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.Batch)
        ValidateBulkItemMaintBatch(batchDetail, valRecord, renderReadOnly, futureCostsOnly)
        Return valRecord
    End Function

    Public Shared Sub ValidateBulkItemMaintBatch(ByVal batchDetail As Models.BatchRecord, ByRef valRecord As Models.ValidationRecord, ByVal renderReadOnly As Boolean, ByVal futureCostsOnly As Boolean)
        Dim batchLookup As Models.BatchValidationLookupRecord
        batchLookup = New Models.BatchValidationLookupRecord(batchDetail.ID)
        NovaLibra.Coral.Data.Michaels.ValidationData.BulkItemMaintBatchValidationLookup(batchLookup)
        Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
        Dim table As NovaLibra.Coral.SystemFrameworks.MetadataTable

        If batchLookup.BatchErrors <> Models.BatchValidationErrors.None AndAlso Not futureCostsOnly Then

            ' --------------------------------------------
            ' GO THROUGH THE ERRORS 
            ' --------------------------------------------

            table = md.GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)

            'NoItems = 1
            If batchLookup.HasError(Models.BatchValidationErrors.NoItems) Then
                valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - No items exist in this batch.  There must be at least one item in the batch."))
            End If

            'NoChanges = 2
            If batchLookup.HasError(Models.BatchValidationErrors.NoChanges) AndAlso Not batchLookup.HasError(Models.BatchValidationErrors.NoItems) Then
                valRecord.Add("BatchError", "BatchError", FormatErrorText("", "", "{}Batch Error - There are no changes for this batch. This batch needs to have at least one change. Please remove this batch if no changes are needed."))
            End If

        End If

        If batchLookup.FutureCostSKUs IsNot Nothing Then

            For Each c As Models.BatchFutureCost In batchLookup.FutureCostSKUs
                If c.FutureCostExists OrElse c.FutureCostCancelled Then
                    valRecord.Add("FutureCostExists", "FutureCostExists", FormatErrorText("", "", "{}Batch Warning - " & FormatFutureCostMessage(c.ID, c.SKU, c.FutureCostExists, c.FutureCostCancelled, renderReadOnly)), ValidationRuleSeverityType.TypeWarning)
                End If
            Next
        End If

        batchLookup = Nothing
    End Sub

    ' *********************************
    ' * VALIDATE BULK ITEM MAINT ITEM *
    ' *********************************
    Public Shared Function ValidateBulkItemMaintItemForFutureCostsOnly(ByRef record As Models.ItemMaintItemDetailFormRecord, _
                ByRef rowChanges As Models.IMRowChanges, _
                ByVal renderReadOnly As Boolean) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(record.ID)
        Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.ItemMaintItem
        Dim column As NovaLibra.Coral.SystemFrameworks.MetadataColumn

        ' Validate
        ' Existing Future Cost Change
        Dim futureCostCancelled As Boolean = False
        If (rowChanges IsNot Nothing AndAlso rowChanges.ChangeExists("FutureCostStatus")) Then futureCostCancelled = True
        If record.FutureCostExists OrElse futureCostCancelled Then
            column = table.GetColumnByName("FutureCostExists")
            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, ("{}" & FormatFutureCostMessage(record.ID, record.SKU, record.FutureCostExists, futureCostCancelled, renderReadOnly))), ValidationRuleSeverityType.TypeWarning)
        End If

        Return valRecord
    End Function

    Public Shared Function ValidateBulkItemMaintItemList(ByRef objectsToValidate As ArrayList, ByRef tableChanges As Models.IMTableChanges, ByVal CurrentStageID As Integer, ByVal CurrentStageTypeID As Models.WorkflowStageType) As ArrayList
        Dim valRecords As ArrayList = New ArrayList()
        Dim rec As Models.ItemMaintItemDetailFormRecord
        For Each o As Object In objectsToValidate
            If TypeOf o Is Models.ItemMaintItemDetailFormRecord Then
                rec = CType(o, Models.ItemMaintItemDetailFormRecord)
                'Redoing language loading, because item maintenance can't just load a record once. . .
                'Get language settings from SPD_Import_Item_Languages
                Dim languageDT As DataTable = Data.MaintItemMasterData.GetItemLanguages(rec.SKU, rec.VendorNumber)
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
                                rec.PLIEnglish = pli
                                rec.TIEnglish = ti
                                rec.EnglishShortDescription = descShort
                                rec.EnglishLongDescription = descLong
                            Case 2
                                rec.PLIFrench = pli
                                rec.TIFrench = ti
                                rec.FrenchShortDescription = descShort
                                rec.FrenchLongDescription = descLong
                                rec.ExemptEndDateFrench = exemptEndDate
                            Case 3
                                rec.PLISpanish = pli
                                rec.TISpanish = ti
                                rec.SpanishShortDescription = descShort
                                rec.SpanishLongDescription = descLong
                        End Select
                    Next
                End If

                ' ***** do not run validation if "Waiting for SKU" or "Completed" *****
                If ValidationHelper.SkipValidation(CurrentStageTypeID) Then
                    valRecords.Add(ValidateBulkItemMaintItemForFutureCostsOnly(rec, tableChanges.GetRow(rec.ID, True), False))
                Else
                    valRecords.Add(ValidateBulkItemMaintItem(rec, tableChanges.GetRow(rec.ID, True), CurrentStageID, CurrentStageTypeID, False))
                End If

            End If
        Next
        Return valRecords
    End Function

    Public Shared Function ValidateBulkItemMaintItem(ByRef record As Models.ItemMaintItemDetailFormRecord, ByRef rowChanges As Models.IMRowChanges, ByVal CurrentStageID As Integer, ByVal CurrentStageTypeID As Models.WorkflowStageType, ByVal renderReadOnly As Boolean) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(record.ID)
        Dim strValue As String = String.Empty, intValue As Integer = 0
        Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        valRecord.RecordType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecordType.ItemMaintItem

        If ValidationHelper.SkipValidation(CurrentStageTypeID) Then
            Return valRecord
        End If

        Dim mergedRecord As Models.ItemMaintItemDetailFormRecord = record.Clone()

        ' Flammerge (flatten / merge) record
        FormHelper.FlattenItemMaintRecord(mergedRecord, rowChanges, table)

        Dim itemLookup As New Models.ItemMaintItemValidationLookupRecord()
        itemLookup.ID = mergedRecord.ID
        itemLookup.Dept = mergedRecord.DepartmentNum
        itemLookup.ClassNum = mergedRecord.ClassNum
        itemLookup.SubClassNum = mergedRecord.SubClassNum
        itemLookup.CountryOfOrigin = mergedRecord.CountryOfOrigin
        itemLookup.CountryOfOriginName = mergedRecord.CountryOfOriginName
        itemLookup.TaxUDA = mergedRecord.TaxUDA
        If mergedRecord.TaxValueUDA >= Integer.MinValue And mergedRecord.TaxValueUDA <= Integer.MaxValue Then
            itemLookup.TaxValueUDA = mergedRecord.TaxValueUDA
        End If
        itemLookup.DeptString = mergedRecord.DepartmentNum.ToString()
        itemLookup.VendorNumberString = mergedRecord.VendorNumber.ToString()
        itemLookup.StockingStrategyCode = mergedRecord.StockingStrategyCode
        itemLookup.ItemTypeAttribute = mergedRecord.ItemTypeAttribute
        itemLookup.EachCaseWeight = mergedRecord.EachCaseWeight
        itemLookup.InnerCaseWeight = mergedRecord.InnerCaseWeight
        itemLookup.MasterCaseWeight = mergedRecord.MasterCaseWeight
        itemLookup.EachesInnerPack = mergedRecord.EachesInnerPack
        itemLookup.EachesMasterPack = mergedRecord.EachesMasterCase
        ' add countries (from record)
        Dim i As Integer
        If record.AdditionalCOORecCount > 0 Then
            For i = 0 To record.AdditionalCOORecCount - 1
                itemLookup.AddCountry(record.AdditionalCOORecs.Item(i).CountryOfOriginName, record.AdditionalCOORecs.Item(i).CountryOfOrigin)
            Next
        End If
        ' add countries (from changes, if they exist)
        Dim cooName As String = String.Empty
        Dim cooCode As String = String.Empty
        Dim addCOOCode As String = String.Empty
        Dim addCOOName As String = String.Empty
        Dim arrAddCOOCodes() As String
        Dim arrAddCOONames() As String
        Dim saveAddCOO As New List(Of Models.CountryRecord)
        Dim n As Integer
        Dim coo As Models.CountryRecord
        If rowChanges.ChangeExists(WebConstants.cADDCOONAME) Then
            addCOOName = rowChanges.GetCellChange(WebConstants.cADDCOONAME).FieldValue
            arrAddCOONames = addCOOName.Split(WebConstants.cPIPE)
            For n = 0 To arrAddCOONames.Length - 1
                coo = New Models.CountryRecord()
                coo.CountryName = arrAddCOONames(n)
                saveAddCOO.Add(coo)
            Next
        End If
        If rowChanges.ChangeExists(WebConstants.cADDCOO) Then
            addCOOCode = rowChanges.GetCellChange(WebConstants.cADDCOO).FieldValue
            arrAddCOOCodes = addCOOCode.Split(WebConstants.cPIPE)
            For n = 0 To arrAddCOOCodes.Length - 1
                If n < saveAddCOO.Count Then
                    saveAddCOO.Item(n).CountryCode = arrAddCOOCodes(n)
                End If
            Next
        End If
        For i = 0 To saveAddCOO.Count - 1
            itemLookup.AddCountry(saveAddCOO.Item(i))
        Next

        Dim bRet As Boolean = Data.ValidationData.ItemMaintItemValidationLookup(itemLookup)

        If Not bRet Then
            valRecord.Add("<None>", CUSTOM_FIELD_NAME, "A System Error occurred when trying to validate the item record !!!  Please contact the system administrator.")
        End If

        If rowChanges IsNot Nothing Then
            'Display error if there are no changes
            If rowChanges.RowRecords.Count <= 0 Then
                valRecord.Add("<None>", CUSTOM_FIELD_NAME, "There are no changes for Item " & mergedRecord.SKU & " with Vendor Number " & mergedRecord.VendorNumber & ". An item has to have at least one change. Please remove this item if no changes are needed.")
            End If
        End If

        ' Validate
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.BulkItemMaintItem)
        ValidateObject(mergedRecord, Nothing, itemLookup, valRecord, doc, CurrentStageID, Nothing, String.Empty, record, rowChanges, renderReadOnly)

        mergedRecord = Nothing

        Return valRecord
    End Function


    ' ****************************
    ' * VALIDATE TRILINGUAL MAINT ITEM *
    ' ****************************

    Public Shared Function ValidateTrilingualMaintItemList(ByRef objectsToValidate As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailRecordList, ByRef tableChanges As Models.IMTableChanges, ByVal CurrentStageID As Integer, ByVal CurrentStageTypeID As Integer) As ArrayList
        Dim valRecords As ArrayList = New ArrayList()
        Dim rec As Models.ItemMaintItemDetailRecord

        If objectsToValidate.ListRecords.Count <= 0 Then
            Dim valRecord As New Models.ValidationRecord()
            valRecord.Add("<None>", CUSTOM_FIELD_NAME, "No SKUs are associated with this Batch.  Please Delete it.")
            valRecords.Add(valRecord)
        Else
            For Each o As Object In objectsToValidate.ListRecords
                If TypeOf o Is Models.ItemMaintItemDetailRecord Then
                    rec = CType(o, Models.ItemMaintItemDetailRecord)

                    ' ***** do not validation if "Waiting for SKU" or "Completed" *****
                    If Not ValidationHelper.SkipValidation(CurrentStageTypeID) Then
                        valRecords.Add(ValidateTrilingualMaintItem(rec, tableChanges.GetRow(rec.ID, True), CurrentStageID, CurrentStageTypeID))
                    End If

                End If
            Next
        End If

        Return valRecords
    End Function

    Public Shared Function ValidateTrilingualMaintItem(ByRef record As Models.ItemMaintItemDetailRecord, ByRef rowChanges As Models.IMRowChanges, ByVal CurrentStageID As Integer, ByVal CurrentStageTypeID As Models.WorkflowStageType) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(record.ID)
        Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        'Only validation currently needed for Trilingual Maintenance batches.
        If rowChanges IsNot Nothing Then
            If rowChanges.RowRecords.Count <= 0 Then
                valRecord.Add("<None>", CUSTOM_FIELD_NAME, "There are no changes for SKU " & record.SKU & ". The item has to have at least one change.")
            End If
        End If

        Dim mergedRecord As New Models.ItemMaintItemDetailFormRecord
        record.CopyTo(mergedRecord)

        ' Flammerge (flatten / merge) record
        FormHelper.FlattenItemMaintRecord(mergedRecord, rowChanges, table)

        ' Determine Validation Document based on Batch Type
        Dim doc As ValidationDocument
        If mergedRecord.BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualTranslations Then
            doc = ValidationHelper.GetValidationDoc(ValidationDocumentType.TrilingualTrans)
        End If
        If mergedRecord.BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualExemptions Then
            doc = ValidationHelper.GetValidationDoc(ValidationDocumentType.TrilingualEXT)
        End If

        'Validate
        ValidateObject(mergedRecord, Nothing, Nothing, valRecord, doc, CurrentStageID, Nothing, String.Empty, record, rowChanges, False)

        mergedRecord = Nothing

        Return valRecord
    End Function

    '********************************************************************************************************************
    ' PURCHASE ORDER VALIDATION
    '********************************************************************************************************************

    Public Shared Function ValidatePOCreationHeader(ByVal objRecord As Models.POCreationRecord) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(objRecord.ID)

        'Validate the PO Header
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POCreationHeader)
        ValidateObject(objRecord, Nothing, Nothing, valRecord, doc, objRecord.WorkflowStageID)

        Return valRecord

    End Function

    Public Shared Function ValidationPOCreationDetail(ByVal objRecord As Models.POCreationRecord, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(objRecord.ID)

        'Validate the PO Header values on the Detail page (currently only used to validate Workflow Department)
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POCreationDetail)
        ValidateObject(objRecord, Nothing, Nothing, valRecord, doc, objRecord.WorkflowStageID)

        Return valRecord
    End Function

    Public Shared Function ValidatePOCreationLocation(ByVal objRecord As Models.POCreationRecord, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord

        Dim valRecord As New Models.ValidationRecord(objRecord.ID)
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POCreationLocation)

        Dim locationDates As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsCacheByPOID(objRecord.ID, AppHelper.GetUserID())
        For Each locationRec As Models.POCreationLocationRecord In locationDates
            'Validate the PO_Creation_Location Records
            Dim vr As New Models.ValidationRecord()
            ValidateObject(locationRec, Nothing, Nothing, vr, doc, workflowStageID)

            'Add Location Name to the Errors
            For i As Integer = 0 To vr.Count - 1
                vr.Item(i).ErrorText = locationRec.LocationName & ": " & vr.Item(i).ErrorText
            Next

            'Merge Errors
            valRecord.Merge(vr)
        Next

        'Return Validaiton Record of all the Errors
        Return valRecord

    End Function

    Public Shared Function ValidatePOCreationSKU(ByVal objRecord As Models.POCreationRecord, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord

        Dim valRecord As New Models.ValidationRecord()
        'Lists used during validtion
        Dim locations As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsByPOID(objRecord.ID)
        Dim locationLookup As New ArrayList

        'Create Location lists using the PO_Creation_Location data
        For Each locationRec As Models.POCreationLocationRecord In locations
            'Add Location to lookup
            locationLookup.Add(locationRec.POLocationID)
        Next

        '****************************'
        '	VALIDATE PO SKU          '
        '****************************'
        ' Perform SKU Validations
        '	1). SKUS must have "valid" data populated (SKU, SKU Location (Store or DC), Quantity).  Optional Fields include Unit Cost, Inner Pack, Master Pack
        '	2). All SKU Locations for a SKU must be in one of the PO's selected Locations
        '	3). "Basic" SKU items are NOT ALLOWED w/ Seasonal Symbols (on header)
        '	4). SKU Errors should "link" to SKU in table
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POCreationSKU)
        Dim skuList As List(Of Models.POCreationLocationSKURecord) = Data.POCreationLocationSKUData.GetSKUsCacheByPOID(objRecord.ID, AppHelper.GetUserID())
        If skuList.Count = 0 Then
            valRecord.Add("", "This Purchase Order does not have any SKUs.", ValidationRuleSeverityType.TypeError)
        Else

            For Each skuRec As Models.POCreationLocationSKURecord In skuList
                'Create a unique SKU validation record
                Dim skuValRecord As New Models.ValidationRecord()

                'Validate the SKU (pass in VendorNumber for lookup values.  Create Lookup object if more Lookups needed.
                ValidateObject(skuRec, Nothing, objRecord.VendorNumber, skuValRecord, doc, workflowStageID, objRecord, "PO_Creation")

                'rule removed in version 3.18
                'RULE: Basic Purchase Orders can have any Item Type except Seasonal
                'If (objRecord.BasicSeasonal = "B" AndAlso skuRec.ItemTypeAttribute = "S") Then
                ' skuValRecord.Add("", " is a Seasonal Item, which is not allowed on Basic Purchase Orders.")
                ' End If

                'RULE: Seasonal Purchase Orders can only have Basic or Seasonal Items
                If (objRecord.BasicSeasonal = "S" AndAlso (skuRec.ItemTypeAttribute <> "S")) Then
                    skuValRecord.Add("", " is a not a Seasonal Item. Only Seasonal Items are allowed on Seasonal Purchase Orders.")
                End If

                'Validate SKU Store
                Dim isStoresValid As Boolean = True
                Dim storeList As ArrayList = Data.POCreationSKUStoreData.GetCacheBySKU(objRecord.ID, skuRec.MichaelsSKU, AppHelper.GetUserID())
                Dim storeDoc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POCreationSKUStore)
                For Each storeRec As Models.POCreationSKUStoreRecord In storeList
                    'Create unique Store Validation Record
                    Dim storeValRecord As New Models.ValidationRecord()

                    'Validate the Store
                    ValidateObject(storeRec, Nothing, locationLookup, storeValRecord, storeDoc, workflowStageID)
                    isStoresValid = isStoresValid And storeValRecord.IsValid

                    If (Not storeValRecord.IsValid) Then
                        'ONLY update Store valid flag if there is a PO Location, and the validity is different.  
                        'This will cut down on uneeded updates.
                        If (storeRec.POLocationID > 0) And (storeRec.IsValid <> storeValRecord.IsValid) Then
                            storeRec.IsValid = storeValRecord.IsValid
                            Data.POCreationSKUStoreData.UpdateCache(storeRec, AppHelper.GetUserID())
                        End If
                    End If
                Next

                'If any of the stores are not valid, then add an error for the SKU
                If Not (isStoresValid) Then
                    skuValRecord.Add("", "One of the stores is invalid.  Check the SKU Store page for details")
                End If

                'Add SKU Link to Error
                For i As Integer = 0 To skuValRecord.Count - 1
                    skuValRecord.Item(i).ErrorText = "<a href='#' onclick=""javascript:SearchBySKU('" & skuRec.MichaelsSKU & "'); return false;"" > SKU " & skuRec.MichaelsSKU & ":" & skuValRecord.Item(i).ErrorText & "</a>"
                Next

                'Update validity for SKU if it is different
                Dim isSkuValid As Boolean = isStoresValid And skuValRecord.IsValid
                If (skuRec.IsValid Is Nothing Or skuRec.IsValid <> isSkuValid) Then
                    skuRec.IsValid = isSkuValid
                    Data.POCreationLocationSKUData.UpdateSKUsCacheByPOID(objRecord.ID, skuRec, AppHelper.GetUserID())
                End If

                'Merge SKU Validation Record with Detail Validation Record
                valRecord.Merge(skuValRecord)
            Next
        End If
        Return valRecord
    End Function

    Public Shared Function ValidatePOCreationSKUStore(ByVal objRecord As Models.POCreationSKUStoreRecord, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(objRecord.POCreationID)

        'Retrieve a list of the valid PO Location IDs
        Dim poLocations As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsCacheByPOID(objRecord.POCreationID, AppHelper.GetUserID())
        Dim locationLookup As New ArrayList
        For Each location As Models.POCreationLocationRecord In poLocations
            locationLookup.Add(location.POLocationID)
        Next

        'Retrieve a list of all Stores for this SKU
        Dim storeList As ArrayList = Data.POCreationSKUStoreData.GetCacheBySKU(objRecord.POCreationID, objRecord.MichaelsSKU, AppHelper.GetUserID())
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(valDocType)
        For Each store As Models.POCreationSKUStoreRecord In storeList
            'Create a Unique Validation Record for the Store
            Dim storeValRecord As New Models.ValidationRecord()
            'Validate the Store
            ValidateObject(store, Nothing, locationLookup, storeValRecord, doc, workflowStageID)

            'HACK: Only update the Store validity, if the store is currently valid.  
            'If the store is Invalid (due to failed Webservice validation), do not overwrite validity
            If store.IsValid Then
                'ONLY update Store valid flag if there is a PO Location, and the validity is different.  
                'This will cut down on uneeded updates.
                If (store.POLocationID > 0) And (store.IsValid <> storeValRecord.IsValid) Then
                    store.IsValid = storeValRecord.IsValid
                    Data.POCreationSKUStoreData.UpdateCache(store, AppHelper.GetUserID())
                End If
            End If

            'Add Link to Error
            For i As Integer = 0 To storeValRecord.Count - 1
                storeValRecord.Item(i).ErrorText = "<a href='#' onclick=""javascript:SearchByStore('" & store.StoreNumber & "'); return false;"" > " & storeValRecord.Item(i).ErrorText & "</a>"
            Next

            'Merge validation records
            valRecord.Merge(storeValRecord)
        Next

        'Return the Validation record that contains errors for all stores
        Return valRecord
    End Function

    Public Shared Function ValidatePOMaintenanceHeader(ByVal objRecord As Models.POMaintenanceRecord) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(objRecord.ID)

        'Validate the PO Header
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POMaintenanceHeader)
        ValidateObject(objRecord, Nothing, Nothing, valRecord, doc, objRecord.WorkflowStageID)

        Return valRecord

    End Function

    Public Shared Function ValidatePOMaintenanceLocation(ByVal objRecord As Models.POMaintenanceRecord, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(objRecord.ID)

        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POMaintenanceLocation)
        ValidateObject(objRecord, Nothing, Nothing, valRecord, doc, workflowStageID)

        'Return Validaiton Record of all the Errors
        Return valRecord
    End Function

    Public Shared Function ValidatePOMaintenanceSKU(ByVal objRecord As Models.POMaintenanceRecord, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord

        Dim valRecord As New Models.ValidationRecord()

        'Lists used during validtion
        Dim locationLookup As New ArrayList
        locationLookup.Add(objRecord.POLocationID)

        Dim skuList As List(Of Models.POMaintenanceSKURecord) = Data.POMaintenanceSKUData.GetSKUsCACHEByPOID(objRecord.ID, AppHelper.GetUserID())

        '****************************'
        '	VALIDATE PO SKU          '
        '****************************'
        ' Perform SKU Validations
        '	1). SKUS must have "valid" data populated (SKU, SKU Location (Store or DC), Quantity).  Optional Fields include Unit Cost, Inner Pack, Master Pack
        '	2). All SKU Locations for a SKU must be in one of the PO's selected Locations
        '	3). "Basic" SKU items are NOT ALLOWED w/ Seasonal Symbols (on header)
        '	4). SKU Errors should "link" to SKU in table
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POMaintenanceSKU)
        For Each skuRec As Models.POMaintenanceSKURecord In skuList

            Dim skuValRecord As New Models.ValidationRecord()

            'Validate the SKU (pass in VendorNumber for lookup values.  Create Lookup object if more Lookups needed.
            ValidateObject(skuRec, Nothing, objRecord.VendorNumber, skuValRecord, doc, workflowStageID, objRecord, "PO_Maintenance")

            'RULE: Basic Purchase Orders can have any Item Type except Seasonal
            'If (objRecord.BasicSeasonal = "B" AndAlso skuRec.ItemTypeAttribute = "S") Then
            'skuValRecord.Add("", " is a Seasonal Item, which is not allowed on Basic Purchase Orders")
            'End If

            'RULE: Seasonal Purchase Orders can only have Basic or Seasonal Items
            If (objRecord.BasicSeasonal = "S" AndAlso (skuRec.ItemTypeAttribute <> "S")) Then
                skuValRecord.Add("", " is a not a Seasonal Item. Only Seasonal Items are allowed on Seasonal Purchase Orders.")
            End If

            'RULE: Cancelled Quantity must be <= the Outstanding Quantity
            Dim outStandingQty As Integer = (DataHelper.SmartValues(skuRec.CalculatedOrderTotalQty, "CInt", False, 0) - DataHelper.SmartValues(skuRec.ReceivedQty, "CInt", False, 0))
            If (skuRec.CancelledQty > outStandingQty And outStandingQty >= 0) Then
                skuValRecord.Add("", " has a Cancelled Quantity that is > the outstanding quantity")
            End If

            'Validate SKU Store
            Dim isStoresValid As Boolean = True
            Dim storeList As ArrayList = Data.POMaintenanceSKUStoreData.GetValidatingStoresBySKU(objRecord.ID, skuRec.MichaelsSKU, AppHelper.GetUserID())
            Dim storeDoc As ValidationDocument = ValidationHelper.GetValidationDoc(ValidationDocumentType.POMaintenanceSKUStore)
            For Each storeRec As Models.POMaintenanceSKUStoreRecord In storeList
                'Create unique Store Validation Record
                Dim storeValRecord As New Models.ValidationRecord()
                'Validate the Store
                ValidateObject(storeRec, Nothing, locationLookup, storeValRecord, storeDoc, workflowStageID)

                isStoresValid = isStoresValid And storeValRecord.IsValid

                If (Not storeValRecord.IsValid) Then
                    'ONLY update Store valid flag if there is a PO Location, and the validity is different.  
                    'This will cut down on uneeded updates.
                    If (storeRec.POLocationID > 0) And (storeRec.IsValid <> storeValRecord.IsValid) Then
                        storeRec.IsValid = storeValRecord.IsValid
                        Data.POMaintenanceSKUStoreData.UpdateCacheRecord(storeRec, AppHelper.GetUserID())
                    End If
                End If

            Next

            'If any of the stores are not valid, then add an error for the SKU
            If Not (isStoresValid) Then
                skuValRecord.Add("", "One of the stores is invalid.  Check the SKU Store page for details")
            End If

            'Add SKU Link to Error
            For i As Integer = 0 To skuValRecord.Count - 1
                skuValRecord.Item(i).ErrorText = "<a href='#' onclick=""javascript:SearchBySKU('" & skuRec.MichaelsSKU & "'); return false;"" > SKU " & skuRec.MichaelsSKU & ":" & skuValRecord.Item(i).ErrorText & "</a>"
            Next

            'Update validity for SKU if it is different
            Dim isSkuValid As Boolean = isStoresValid And skuValRecord.IsValid
            If (skuRec.IsValid Is Nothing Or skuRec.IsValid <> isSkuValid) Then
                skuRec.IsValid = isSkuValid
                Data.POMaintenanceSKUData.UpdateCacheValidity(skuRec.POMaintenanceID, skuRec.MichaelsSKU, isSkuValid, skuRec.IsWSValid, AppHelper.GetUserID())
            End If

            'Merge SKU Validation Record with Detail Validation Record
            valRecord.Merge(skuValRecord)
        Next

        Return valRecord
    End Function

    Public Shared Function ValidatePOMaintenanceSKUStore(ByVal objRecord As Models.POMaintenanceSKUStoreRecord, ByVal workflowStageID As Integer, ByVal valDocType As Integer) As Models.ValidationRecord
        Dim valRecord As New Models.ValidationRecord(objRecord.POMaintenanceID)

        'Creation Valid Location Array for SKUs (needed to do validation similarly to POCreation)
        Dim locationLookup As New ArrayList
        locationLookup.Add(objRecord.POLocationID)

        'Retrieve a list of all Stores for this SKU
        Dim storeList As ArrayList = Data.POMaintenanceSKUStoreData.GetValidatingStoresBySKU(objRecord.POMaintenanceID, objRecord.MichaelsSKU, AppHelper.GetUserID())
        Dim doc As ValidationDocument = ValidationHelper.GetValidationDoc(valDocType)
        For Each store As Models.POMaintenanceSKUStoreRecord In storeList
            'Create a Unique Validation Record for the Store
            Dim storeValRecord As New Models.ValidationRecord()
            'Validate the Store
            ValidateObject(store, Nothing, locationLookup, storeValRecord, doc, workflowStageID)

            'HACK: Only update the Store validity, if the store is currently valid.  
            'If the store is Invalid (due to failed Webservice validation), do not overwrite validity
            If store.IsValid Then
                'ONLY update Store valid flag if there is a PO Location, and the validity is different.  
                'This will cut down on uneeded updates.
                If (store.POLocationID > 0) And (store.IsValid <> storeValRecord.IsValid) Then
                    store.IsValid = storeValRecord.IsValid
                    Data.POMaintenanceSKUStoreData.UpdateCacheRecord(store, AppHelper.GetUserID())
                End If
            End If

            'Add Link to Error
            For i As Integer = 0 To storeValRecord.Count - 1
                storeValRecord.Item(i).ErrorText = "<a href='#' onclick=""javascript:SearchByStore('" & store.StoreNumber & "'); return false;"" > Store " & store.StoreNumber & ": " & storeValRecord.Item(i).ErrorText & "</a>"
            Next

            'Merge validation records
            valRecord.Merge(storeValRecord)
        Next

        'Return the Validation record that contains errors for all stores
        Return valRecord
    End Function

#End Region

#Region "Validation Methods for Validation Objects"

    Public Shared Sub ValidateObject(ByRef record As Object, _
     ByRef request As System.Web.HttpRequest, _
     ByRef lookup As Object, _
     ByRef valRecord As Models.ValidationRecord, _
     ByRef doc As ValidationDocument, _
     ByVal stage As Integer)

        ValidateObject(record, request, lookup, valRecord, doc, stage, Nothing, String.Empty, Nothing, Nothing, False)
    End Sub

    Public Shared Sub ValidateObject(ByRef record As Object, _
     ByRef request As System.Web.HttpRequest, _
     ByRef lookup As Object, _
     ByRef valRecord As Models.ValidationRecord, _
     ByRef doc As ValidationDocument, _
     ByVal stage As Integer, _
     ByRef parentRecord As Object, _
     ByVal parentTableName As String)

        ValidateObject(record, request, lookup, valRecord, doc, stage, parentRecord, parentTableName, Nothing, Nothing, False)
    End Sub

    Public Shared Sub ValidateObject(ByRef record As Object, _
     ByRef request As System.Web.HttpRequest, _
     ByRef lookup As Object, _
     ByRef valRecord As Models.ValidationRecord, _
     ByRef doc As ValidationDocument, _
     ByVal stage As Integer, _
     ByRef originalRecord As Object, _
     ByRef rowChanges As Models.IMRowChanges)

        ValidateObject(record, request, lookup, valRecord, doc, stage, Nothing, String.Empty, originalRecord, rowChanges, False)
    End Sub

    Public Shared Sub ValidateObject(ByRef record As Object, _
     ByRef request As System.Web.HttpRequest, _
     ByRef lookup As Object, _
     ByRef valRecord As Models.ValidationRecord, _
     ByRef doc As ValidationDocument, _
     ByVal stage As Integer, _
     ByRef parentRecord As Object, _
     ByVal parentTableName As String, _
     ByRef originalRecord As Object, _
     ByRef rowChanges As Models.IMRowChanges)

        ValidateObject(record, request, lookup, valRecord, doc, stage, parentRecord, parentTableName, originalRecord, rowChanges, False)
    End Sub

    Public Shared Sub ValidateObject(ByRef record As Object, _
     ByRef request As System.Web.HttpRequest, _
     ByRef lookup As Object, _
     ByRef valRecord As Models.ValidationRecord, _
     ByRef doc As ValidationDocument, _
     ByVal stage As Integer, _
     ByRef parentRecord As Object, _
     ByVal parentTableName As String, _
     ByRef originalRecord As Object, _
     ByRef rowChanges As Models.IMRowChanges, _
     ByVal renderReadOnly As Boolean)

        ' init
        Dim i As Integer, j As Integer, n As Integer, x As Integer
        Dim errorFound As Boolean, conditionResult As Boolean
        Dim errorText As String
        Dim rule As ValidationRule
        Dim conditionSet As ValidationConditionSet
        Dim condition As ValidationCondition
        Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
        Dim table As NovaLibra.Coral.SystemFrameworks.MetadataTable
        Dim parentTable As NovaLibra.Coral.SystemFrameworks.MetadataTable = Nothing
        Dim column As NovaLibra.Coral.SystemFrameworks.MetadataColumn
        Dim endValidation As Boolean = False

        ' get table
        table = md.GetTableByID(doc.MetadataTableID)
        If parentTableName <> String.Empty Then
            parentTable = md.GetTableByName(parentTableName)
        End If

        If table Is Nothing Then
            valRecord.Add(CUSTOM_FIELD_NAME, "The record has no associated Metadata table for validation.", ValidationRuleSeverityType.TypeError)
        Else
            ' RULES
            For i = 0 To doc.RuleCount - 1
                If endValidation Then
                    Exit For
                End If
                rule = doc.Rule(i)
                column = table.GetColumnByID(rule.MetadataColumnID)

                If column Is Nothing Then
                    valRecord.Add(CUSTOM_FIELD_NAME, "The rule, " & rule.ValidationRule & ", has no associated Metadata column for validation.", ValidationRuleSeverityType.TypeError)
                Else
                    ' condition sets
                    If column.ColumnName.ToLower().Contains("each") Then
                        errorFound = False
                    End If
                    errorFound = False : conditionResult = False : x = 0
                    Do While (errorFound = False And x < rule.ConditionSetCount)
                        ' get condition set
                        conditionSet = rule.ConditionSet(x)

                        ' test for current stage
                        If conditionSet.StageExists(stage) Then

                            For j = 0 To conditionSet.ConditionCount - 1
                                condition = conditionSet.Condition(j)
                                If condition.ConditionType = ValidationConditionType.EndValidation Then
                                    If j = 0 OrElse conditionResult = True Then
                                        ' set endValidation
                                        endValidation = True
                                        ' set x to exit conditionset loop
                                        x = rule.ConditionSetCount
                                        ' no error should be shown
                                        conditionResult = False
                                        ' exit for loop for conditions
                                        Exit For
                                    End If
                                End If
                                Try
                                    If j = 0 Then
                                        conditionResult = EvaluateCondition(record, request, lookup, valRecord, table, rule, conditionSet, condition, parentRecord, parentTable, conditionResult, j, originalRecord, rowChanges, renderReadOnly)
                                    Else
                                        If conditionSet.Condition(j - 1).ConjunctionAND Then
                                            conditionResult = conditionResult And EvaluateCondition(record, request, lookup, valRecord, table, rule, conditionSet, condition, parentRecord, parentTable, conditionResult, j, originalRecord, rowChanges, renderReadOnly)
                                        Else
                                            conditionResult = conditionResult Or EvaluateCondition(record, request, lookup, valRecord, table, rule, conditionSet, condition, parentRecord, parentTable, conditionResult, j, originalRecord, rowChanges, renderReadOnly)
                                        End If
                                    End If
                                Catch ex As Exception
                                    valRecord.Add(CUSTOM_FIELD_NAME, "Error evaluating rule, " & rule.ValidationRule & ", Condition Set #" & (x + 1) & ", Condition #" & (j + 1) & ": " & ex.Message, ValidationRuleSeverityType.TypeError)
                                End Try
                            Next

                            ' condition set has error ??
                            ' ----------------------------------------
                            If conditionResult = True Then
                                errorFound = True
                                errorText = ""
                                ' display error for that condition set
                                Select Case conditionSet.RuleType
                                    Case ValidationRuleType.TypeRequiredField
                                        errorText = ValidationErrorHelper.GetErrorString(ErrorType.ErrorRequired, FormatErrorText(column))

                                    Case ValidationRuleType.TypeValidField
                                        errorText = ValidationErrorHelper.GetInvalidErrorString(FormatErrorText(column), column.Format)

                                    Case ValidationRuleType.TypeValidRange
                                        For n = 0 To conditionSet.ConditionCount - 1
                                            If conditionSet.Condition(n).ConditionType = ValidationConditionType.Range And conditionSet.Condition(n).Field1 = rule.MetadataColumnID Then
                                                errorText = ValidationErrorHelper.GetErrorString(ErrorType.ErrorRange, FormatErrorText(column), conditionSet.Condition(n).Value1, conditionSet.Condition(n).Value2)
                                                Exit For
                                            End If
                                        Next

                                    Case Else 'ValidationRuleType.TypeCustom
                                        errorText = FormatErrorText(column, conditionSet.ErrorText)
                                End Select
                                valRecord.Add(column.ColumnName, column.DisplayName, errorText, conditionSet.ErrorSeverity)
                            End If
                        End If

                        ' increment index and continue processing (if more condition sets)
                        x = x + 1
                    Loop
                End If
            Next
        End If

    End Sub

    Public Shared Function EvaluateCondition(ByRef record As Object, _
     ByRef request As System.Web.HttpRequest, _
     ByRef lookup As Object, _
     ByRef valRecord As Models.ValidationRecord, _
     ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByRef rule As ValidationRule, _
     ByRef conditionSet As ValidationConditionSet, _
     ByRef condition As ValidationCondition, _
     ByRef parentRecord As Object, _
     ByRef parentTable As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByVal currentConditionResult As Boolean, _
     ByVal currentConditionIndex As Integer) As Boolean

        Return EvaluateCondition(record, request, lookup, valRecord, table, rule, conditionSet, condition, parentRecord, parentTable, currentConditionResult, currentConditionIndex, Nothing, Nothing, False)
    End Function

    Public Shared Function EvaluateCondition(ByRef record As Object, _
     ByRef request As System.Web.HttpRequest, _
     ByRef lookup As Object, _
     ByRef valRecord As Models.ValidationRecord, _
     ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByRef rule As ValidationRule, _
     ByRef conditionSet As ValidationConditionSet, _
     ByRef condition As ValidationCondition, _
     ByRef parentRecord As Object, _
     ByRef parentTable As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByVal currentConditionResult As Boolean, _
     ByVal currentConditionIndex As Integer, _
     ByRef originalRecord As Object, _
     ByRef rowChanges As Models.IMRowChanges, _
     ByRef renderReadOnly As Boolean) As Boolean

        Dim result As Boolean = False

        Dim column As NovaLibra.Coral.SystemFrameworks.MetadataColumn
        Dim value1 As Object
        Dim value2 As Object

        Select Case condition.ConditionType

            Case ValidationConditionType.Alphabetic ' 1

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", False)
                result = Not ValidationHelper.IsAlpha(value1)

            Case ValidationConditionType.Alphanumeric ' 2

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", False)
                result = Not ValidationHelper.IsAlphaOrNumeric(value1)

            Case ValidationConditionType.DivisibleByFieldField ' 3

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "decimal", False)
                value2 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field2, parentRecord, parentTable), "decimal", False)

                If value2 = 0 Then
                    result = True
                Else
                    result = Not ValidationHelper.IsDivisibleBy(value1, value2)
                End If

            Case ValidationConditionType.DivisibleByFieldValue ' 4

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "decimal", False)
                value2 = DataHelper.SmartValues(condition.Value1, "decimal", False)

                If value2 = 0 Then
                    result = True
                Else
                    result = Not ValidationHelper.IsDivisibleBy(value1, value2)
                End If

            Case ValidationConditionType.Empty ' 5

                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable)
                'If InStr(condition.Field1, "GTIN") > 0 Then
                '    result = ValidationHelper.IsEmpty(value1)
                'Else
                result = ValidationHelper.IsEmpty(value1)
                'End If

            Case ValidationConditionType.NotEmpty ' 6

                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable)
                result = Not ValidationHelper.IsEmpty(value1)

            Case ValidationConditionType.GeneralFieldField ' 7

                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable, True)
                value2 = GetObjectValue(record, table, condition.Field2, parentRecord, parentTable, True)

                result = EvaluateOperation(value1, condition.ConditionOperator, value2)

            Case ValidationConditionType.GeneralFieldValue ' 8

                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable, True)
                value2 = condition.Value1

                result = EvaluateOperation(value1, condition.ConditionOperator, TypeMatch(value1, value2))

            Case ValidationConditionType.Length ' 9

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", True).ToString().Length()
                value2 = DataHelper.SmartValues(condition.Value1, "integer", False)

                result = EvaluateOperation(value1, condition.ConditionOperator, TypeMatch(value1, value2))


            Case ValidationConditionType.LookupBatchDepartments ' 10

                If TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).SameDeptValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).SameDeptValid
                Else
                    Throw New Exception("Validation lookup (Batch Departments) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupBatchVendors ' 11

                If TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).SameVendorValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).SameVendorValid
                Else
                    Throw New Exception("Validation lookup (Batch Vendors) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupUPCValidation ' 12

                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then

                    '---------------------------------
                    ' item UPC(s)
                    '---------------------------------
                    Dim upc As String
                    Dim item As Models.ItemRecord = CType(record, Models.ItemRecord)
                    Dim itemLookup As Models.ItemValidationLookupRecord = CType(lookup, Models.ItemValidationLookupRecord)

                    If currentConditionResult OrElse currentConditionIndex = 0 Then
                        If Not IsEmpty(item.VendorUPC) Then
                            If item.VendorUPC.Length <> 14 Then
                                column = table.GetColumnByName("VendorUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_LENGTH))
                            ElseIf Not ValidateUPC(item.VendorUPC) Then
                                column = table.GetColumnByName("VendorUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_INVALID))
                            ElseIf itemLookup.UPCExists(item.VendorUPC) Then
                                column = table.GetColumnByName("VendorUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_EXISTS))
                            ElseIf itemLookup.DupBatch(item.VendorUPC) Then
                                column = table.GetColumnByName("VendorUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_DUPBATCH))
                            ElseIf itemLookup.DupWorkflow(item.VendorUPC) Then
                                column = table.GetColumnByName("VendorUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_DUPWORKFLOW))
                            End If
                        End If

                        For i As Integer = 0 To item.AdditionalUPCRecord.AdditionalUPCs.Count - 1
                            upc = item.AdditionalUPCRecord.AdditionalUPCs.Item(i)
                            If Not IsEmpty(upc) Then
                                If upc.Length <> 14 Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_LENGTH), ValidationRuleSeverityType.TypeError)
                                ElseIf Not ValidateUPC(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_INVALID), ValidationRuleSeverityType.TypeError)
                                ElseIf itemLookup.UPCExists(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_EXISTS), ValidationRuleSeverityType.TypeError)
                                ElseIf itemLookup.DupBatch(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_DUPBATCH), ValidationRuleSeverityType.TypeError)
                                ElseIf itemLookup.DupWorkflow(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_DUPWORKFLOW), ValidationRuleSeverityType.TypeError)
                                End If
                            End If
                        Next
                    End If

                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then

                    '---------------------------------
                    ' import item UPC(s)
                    '---------------------------------
                    'Dim errorText As String
                    Dim importItem As Models.ImportItemRecord = CType(record, Models.ImportItemRecord)
                    Dim itemLookup As Models.ImportItemValidationLookupRecord = CType(lookup, Models.ImportItemValidationLookupRecord)
                    Dim upc As String

                    If currentConditionResult OrElse currentConditionIndex = 0 Then
                        If Not IsEmpty(importItem.PrimaryUPC) Then
                            If importItem.PrimaryUPC.Length <> 14 Then
                                column = table.GetColumnByName("PrimaryUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_LENGTH))
                            ElseIf (Not IsNumeric(importItem.PrimaryUPC)) Or Not ValidateUPC(importItem.PrimaryUPC) Then
                                column = table.GetColumnByName("PrimaryUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_INVALID))
                            ElseIf itemLookup.UPCExists(importItem.PrimaryUPC) Then
                                column = table.GetColumnByName("PrimaryUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_EXISTS))
                            ElseIf itemLookup.DupBatch(importItem.PrimaryUPC) Then
                                column = table.GetColumnByName("PrimaryUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_DUPBATCH))
                            ElseIf itemLookup.DupWorkflow(importItem.PrimaryUPC) Then
                                column = table.GetColumnByName("PrimaryUPC")
                                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_UPC_ERROR_DUPWORKFLOW))
                            End If
                        End If

                        For i As Integer = 0 To importItem.AdditionalUPCRecord.AdditionalUPCs.Count - 1
                            upc = importItem.AdditionalUPCRecord.AdditionalUPCs.Item(i)
                            If Not IsEmpty(upc) Then
                                If upc.Length <> 14 Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_LENGTH), ValidationRuleSeverityType.TypeError)
                                ElseIf Not ValidateUPC(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_INVALID), ValidationRuleSeverityType.TypeError)
                                ElseIf itemLookup.UPCExists(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_EXISTS), ValidationRuleSeverityType.TypeError)
                                ElseIf itemLookup.DupBatch(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_DUPBATCH), ValidationRuleSeverityType.TypeError)
                                ElseIf itemLookup.DupWorkflow(upc) Then
                                    valRecord.Add(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), FormatErrorText(("additionalUPC" & (i + 1)), ("Additional UPC " & (i + 1)), VALIDATION_UPC_ERROR_DUPWORKFLOW), ValidationRuleSeverityType.TypeError)
                                End If
                            End If
                        Next

                    End If

                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    ' TODO_IF: FINISH THIS IF UPC BECOMES EDITABLE IN THE FUTURE IN ITEM MAINT
                    result = False
                Else
                    Throw New Exception("Validation lookup (UPC Exists) is not valid for this type of object.")
                End If
                result = False

            Case ValidationConditionType.LookupValidClass ' 13

                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).ClassNumValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).ClassNumValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).ClassNumValid
                Else
                    Throw New Exception("Validation lookup (Valid Class) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupValidCountryOfOrigin ' 14

                Dim addCOOField As String = "AdditionalCOO"
                Dim addCOODisplay As String = "Additional Country of Origin "

                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then

                    result = Not CType(lookup, Models.ItemValidationLookupRecord).CountryOfOriginValid

                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then

                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).CountryOfOriginValid

                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then

                    'result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).CountryOfOriginValid

                    Dim itemLookup As Models.ItemMaintItemValidationLookupRecord = CType(lookup, Models.ItemMaintItemValidationLookupRecord)
                    Dim countryName As String = itemLookup.CountryOfOriginName
                    Dim i As Integer
                    If Not itemLookup.CountryOfOriginValid Then
                        valRecord.Add("CountryOfOriginName", "Primary Country Of Origin", FormatErrorText("CountryOfOriginName", "Primary Country Of Origin", VALIDATION_COO_ERROR_INVALID), ValidationRuleSeverityType.TypeError)
                    End If
                    For i = 0 To itemLookup.Countries.Count - 1
                        If itemLookup.Countries.Item(i).CountryCode = String.Empty AndAlso itemLookup.Countries.Item(i).CountryName <> countryName Then
                            valRecord.Add(addCOOField & (i + 1), addCOODisplay & (i + 1), FormatErrorText(addCOOField & (i + 1), addCOODisplay & (i + 1), VALIDATION_COO_ERROR_INVALID), ValidationRuleSeverityType.TypeError)
                        End If
                    Next
                    result = False

                Else
                    Throw New Exception("Validation lookup (Valid Country of Origin) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupValidDepartment ' 15

                If TypeOf record Is Models.ItemHeaderRecord AndAlso TypeOf lookup Is Models.ItemHeaderValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemHeaderValidationLookupRecord).DeptValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).DeptValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).DeptValid
                Else
                    Throw New Exception("Validation lookup (Valid Department) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupValidSubClass ' 16

                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).SubClassNumValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).SubClassNumValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).SubClassNumValid
                Else
                    Throw New Exception("Validation lookup (Valid Sub-Class) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupValidTaxValueUDA ' 

                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).TaxValueUDAValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).TaxValueUDAValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).TaxValueUDAValid
                Else
                    Throw New Exception("Validation lookup (Valid Tax Value UDA) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupValidVendorUS ' 18

                If TypeOf record Is Models.ItemHeaderRecord AndAlso TypeOf lookup Is Models.ItemHeaderValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemHeaderValidationLookupRecord).USVendorNumValid
                Else
                    Throw New Exception("Validation lookup (Valid Vendor # - US) is not valid for this type of object.")
                End If

            Case ValidationConditionType.LookupValidVendorCanadian ' 19

                If TypeOf record Is Models.ItemHeaderRecord AndAlso TypeOf lookup Is Models.ItemHeaderValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemHeaderValidationLookupRecord).CanadianVendorNumValid
                Else
                    Throw New Exception("Validation lookup (Valid Vendor # - Canadian) is not valid for this type of object.")
                End If

            Case ValidationConditionType.Range ' 20

                Dim d1 As Decimal, r1 As Decimal, r2 As Decimal
                d1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "decimal", True)
                r1 = DataHelper.SmartValues(condition.Value1, "decimal", True)
                r2 = DataHelper.SmartValues(condition.Value2, "decimal", True)

                If d1 <> Decimal.MinValue AndAlso r1 <> Decimal.MinValue AndAlso r2 <> Decimal.MinValue Then
                    Return (Not (d1 >= r1 And d1 <= r2))
                ElseIf d1 = Decimal.MinValue Then
                    Return True
                Else
                    Return False
                End If

            Case ValidationConditionType.RequiredField ' 21

                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable)
                result = ValidationHelper.IsEmpty(value1)  'NAK 5/22/2012 - Changed this line to fix boolean validation which would cause errors when False was selected.

            Case ValidationConditionType.ValidCharacters ' 22

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", True)
                value2 = DataHelper.SmartValues(condition.Value1, "string", True)

                result = Not (ValidationHelper.StringContainsOnly(value1, value2))

            Case ValidationConditionType.InvalidCharacters ' 23

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", True)
                value2 = DataHelper.SmartValues(condition.Value1, "string", True)

                result = Not (ValidationHelper.StringDoesNotContain(value1, value2))

            Case ValidationConditionType.ValidField ' 24

                Dim field As NovaLibra.Coral.SystemFrameworks.MetadataColumn
                Dim tab As MetadataTable = table
                Dim rec As Object = record

                field = GetColumn(table, condition.Field1)
                If field Is Nothing AndAlso (Not parentTable Is Nothing) Then
                    field = GetColumn(parentTable, condition.Field1)
                    tab = parentTable
                    rec = parentRecord
                End If

                If Not field Is Nothing Then
                    If Not request Is Nothing Then
                        result = Not ValidationHelper.IsValidFormValue(request, field.ColumnName.Replace("_", ""), field.Format)
                    Else
                        value1 = GetObjectValue(rec, field)
                        If field.GenericType = "string" AndAlso field.Format <> "string" Then
                            If value1.ToString().Trim() <> String.Empty AndAlso IsEmpty(value1) Then
                                result = True
                            Else
                                result = False
                            End If
                        Else
                            result = False
                        End If
                    End If
                Else
                    Throw New Exception("Field was not found.")
                    'result = False
                End If

            Case ValidationConditionType.ValidUPC ' 25

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", True)

                Return Not ValidationHelper.ValidateUPC(value1)

            Case ValidationConditionType.ValueIn ' 26

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", True)
                value2 = DataHelper.SmartValues(condition.Value1, "string", True)

                If value2.ToString().Trim() = String.Empty Then
                    Throw New Exception("No value entered.")
                Else
                    Return ValidationHelper.StringFoundInSearchStringArray(value1, value2)
                End If

            Case ValidationConditionType.ValueNotIn ' 27

                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", True)
                value2 = DataHelper.SmartValues(condition.Value1, "string", True)

                If value2.ToString().Trim() = String.Empty Then
                    Throw New Exception("No value entered.")
                Else
                    Return Not ValidationHelper.StringFoundInSearchStringArray(value1, value2)
                End If

            Case ValidationConditionType.LookupValidVendor ' 29

                If TypeOf record Is Models.ImportItemRecord Then
                    Dim importItem As Models.ImportItemRecord = CType(record, Models.ImportItemRecord)
                    result = Not ValidationHelper.IsValidImportVendor(DataHelper.SmartValues(importItem.VendorNumber, "integer", False))
                Else
                    Throw New Exception("Validation lookup (Valid Vendor #) is not valid for this type of object.")
                End If

            Case ValidationConditionType.EmptyAfterRemoving ' 30

                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable)
                value2 = DataHelper.SmartValues(condition.Value1, "string", True)

                result = ValidationHelper.IsEmpty(value1.ToString().Trim().Replace(value2, ""))

            Case ValidationConditionType.LookupBatchDDPValidation ' 31
                ' THIS TYPE IS MOVED OUT OF ITEM VALIDATION AND IS JUST HARD-CODED INTO THE PROJECT.
                result = False


            Case ValidationConditionType.ChangesGeneralOriginalFieldValue ' 32

                If originalRecord IsNot Nothing Then
                    value1 = GetObjectValue(originalRecord, table, condition.Field1, parentRecord, parentTable, True)
                Else
                    value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable, True)
                End If
                value2 = condition.Value1

                result = EvaluateOperation(value1, condition.ConditionOperator, TypeMatch(value1, value2))

            Case ValidationConditionType.ChangesGeneralChangedFieldValue ' 33

                Dim field As NovaLibra.Coral.SystemFrameworks.MetadataColumn
                result = False
                If rowChanges IsNot Nothing Then
                    field = GetField(table, condition.Field1, parentTable)
                    If field IsNot Nothing Then
                        If rowChanges.ChangeExists(field.ColumnName) Then
                            Dim cellChange As Models.IMCellChangeRecord = rowChanges.GetCellChange(field.ColumnName)

                            'value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable, True)
                            value1 = DataHelper.SmartValues(cellChange.FieldValue, field.GenericType, True)
                            If field.Format.ToLower.Contains("percent") Then
                                If Not IsEmpty(value1) Then
                                    value1 = value1 * 100
                                End If
                            End If
                            value2 = condition.Value1

                            result = EvaluateOperation(value1, condition.ConditionOperator, TypeMatch(value1, value2))
                        End If
                    End If
                End If

            Case ValidationConditionType.LookupPackItemValidation ' 34

                If TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then

                    ' -------------------------------------
                    ' IMPORT ITEM
                    ' -------------------------------------

                    Dim itemRec As Models.ImportItemRecord = CType(record, Models.ImportItemRecord)
                    Dim itemLookup As Models.ImportItemValidationLookupRecord = CType(lookup, Models.ImportItemValidationLookupRecord)

                    'None = 0
                    If itemLookup.ItemErrors <> Models.ItemValidationErrors.None Then

                        'ComponentsSameItemTypeAttribute = 1 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameItemTypeAttribute) Then
                            column = table.GetColumnByName("ItemTypeAttribute")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameStockCategory = 2 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameStockCategory) Then
                            column = table.GetColumnByName("StockCategory")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameStockingStrategyCode = 4 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameStockingStrategyCode) Then
                            column = table.GetColumnByName("Stocking_Strategy_Code")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHybridType = 4 ' DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHybridType) Then
                        '    column = table.GetColumnByName("HybridType")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        'End If

                        'ComponentsSameHybridSourcingDC = 8 ' DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHybridSourcingDC) Then
                        '    column = table.GetColumnByName("SourcingDC")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        'End If

                        'ComponentsSameHierarchyD = 16 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchyD) Then
                            column = table.GetColumnByName("Dept")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHierarchyC = 32 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchyC) Then
                            column = table.GetColumnByName("Class")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHierarchySC = 64 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchySC) Then
                            column = table.GetColumnByName("SubClass")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameVendor = 128 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameVendor) Then
                            column = table.GetColumnByName("VendorNumber")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same Primary {0} as the Display Pack."))
                        End If

                        'ComponentsWarehouseSeasonalW = 256 ' D
                        If itemLookup.HasError(Models.ItemValidationErrors.DisplayerWarehouseSeasonalW) Then
                            column = table.GetColumnByName("StockCategory")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be Warehouse for a Displayer."))
                        End If

                        'ComponentsWarehouseSeasonalS = 512 'D
                        If itemLookup.HasError(Models.ItemValidationErrors.DisplayerWarehouseSeasonalS) Then
                            column = table.GetColumnByName("ItemTypeAttribute")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be Seasonal for a Displayer."))
                        End If

                        'ComponentsMustBeActive = 1024 ' D/DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsMustBeActive) Then
                        '    column = table.GetColumnByName("ItemStatus")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be Active when component is associated with a Displayer / Display Pack."))
                        'End If

                        'ComponentsSameSkuGroup = 2048 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameSkuGroup) Then
                            column = table.GetColumnByName("SKUGroup")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsQtyInPack = 4096 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsQtyInPack) Then
                            column = table.GetColumnByName("Qty_In_Pack")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} is a required field when component is associated with a Displayer / Display Pack."))
                        End If

                        'DDPActive = 8192
                        If itemLookup.HasError(Models.ItemValidationErrors.DDPActive) Then
                            column = table.GetColumnByName("Item_Status")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{}This is a discontinued SKU.  You cannot add a discontinued SKU to a New Item batch."))
                        End If

                        'MultipleDDP = 16384
                        If itemLookup.HasError(Models.ItemValidationErrors.MultipleDDP) Then
                            column = table.GetColumnByName("PackItemIndicator")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "This is one of multiple parent items ({0}) that exist in this batch.  Only one parent item is allowed in a batch."))
                        End If

                        'DuplicateSKU = 32768
                        If itemLookup.HasError(Models.ItemValidationErrors.DuplicateSKU) Then
                            column = table.GetColumnByName("MichaelsSKU")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} exists more than once in this batch."))
                        End If

                        'Duplicate Component = 131072
                        If itemLookup.HasError(Models.ItemValidationErrors.DuplicateComponent) Then
                            column = table.GetColumnByName("MichaelsSKU")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "This item cannot be edited; it is part of an active Display Pack."))
                        End If

                        'ComponentsSamePLI = 262144 ' PLIs must match
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSamePLI) Then
                            valRecord.Add("Package Language Indicator", "Component must have same Package Language Indicator settings as the Display / Display Pack.", ValidationRuleSeverityType.TypeWarning)
                        End If

                        'ComponentsSameTI = 524288 ' TIs must match
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameTI) Then
                            valRecord.Add("Translation Indicator", "Component must have same Translation Indicator settings as the Display / Display Pack.", ValidationRuleSeverityType.TypeWarning)
                        End If

                    End If

                ElseIf TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then

                    ' -------------------------------------
                    ' DOMESTIC ITEM
                    ' -------------------------------------

                    Dim itemRec As Models.ItemRecord = CType(record, Models.ItemRecord)
                    Dim itemLookup As Models.ItemValidationLookupRecord = CType(lookup, Models.ItemValidationLookupRecord)

                    'None = 0
                    If itemLookup.ItemErrors <> Models.ItemValidationErrors.None Then

                        'ComponentsSameItemTypeAttribute = 1 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameItemTypeAttribute) Then
                            column = table.GetColumnByName("Item_Type_Attribute")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameStockCategory = 2 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameStockCategory) Then
                            column = table.GetColumnByName("Stock_Category")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameStockingStrategyCode = 4 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameStockingStrategyCode) Then
                            column = table.GetColumnByName("Stocking_Strategy_Code")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHybridType = 4 ' DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHybridType) Then
                        '    column = table.GetColumnByName("Hybrid_Type")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        'End If

                        'ComponentsSameHybridSourcingDC = 8 ' DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHybridSourcingDC) Then
                        '    column = table.GetColumnByName("Hybrid_Source_DC")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        'End If

                        'ComponentsSameHierarchyD = 16 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchyD) Then
                            column = table.GetColumnByName("Department_Num")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHierarchyC = 32 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchyC) Then
                            column = table.GetColumnByName("Class_Num")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHierarchySC = 64 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchySC) Then
                            column = table.GetColumnByName("Sub_Class_Num")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameVendor = 128 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameVendor) Then
                            column = parentTable.GetColumnByName("US_Vendor_Num")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsWarehouseSeasonalW = 256 ' D
                        If itemLookup.HasError(Models.ItemValidationErrors.DisplayerWarehouseSeasonalW) Then
                            column = table.GetColumnByName("Pack_Item_Indicator")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{}The Stock Category (Item Header) must be Warehouse when associated with a Displayer."))
                        End If

                        'ComponentsWarehouseSeasonalS = 512 'D
                        If itemLookup.HasError(Models.ItemValidationErrors.DisplayerWarehouseSeasonalS) Then
                            column = table.GetColumnByName("Pack_Item_Indicator")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{}The Item Type Attribute (Item Header) must be Seasonal when associated with a Displayer."))
                        End If

                        'ComponentsMustBeActive = 1024 ' D/DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsMustBeActive) Then
                        '    column = table.GetColumnByName("ItemStatus")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be Active when component is associated with a Displayer / Display Pack."))
                        'End If

                        'ComponentsSameSkuGroup = 2048 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameSkuGroup) Then
                            'column = table.GetColumnByName("SKUGroup")
                            valRecord.Add("SKUGroup", "SKU Group", FormatErrorText("SKUGroup", "SKU Group", "{}Component must have same SKU Group (Item Header) as the Display Pack."))
                        End If

                        'ComponentsQtyInPack = 4096 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsQtyInPack) Then
                            column = table.GetColumnByName("Qty_In_Pack")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} is a required field when component is associated with a Displayer / Display Pack."))
                        End If

                        'DDPActive = 8192
                        If itemLookup.HasError(Models.ItemValidationErrors.DDPActive) Then
                            column = table.GetColumnByName("Item_Status")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{}This is a discontinued SKU.  You cannot add a discontinued SKU to a New Item batch."))
                        End If

                        'MultipleDDP = 16384
                        If itemLookup.HasError(Models.ItemValidationErrors.MultipleDDP) Then
                            column = table.GetColumnByName("Pack_Item_Indicator")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "This is one of multiple parent items ({0}) that exist in this batch.  Only one parent item is allowed in a batch."))
                        End If

                        'DuplicateSKU = 32768
                        If itemLookup.HasError(Models.ItemValidationErrors.DuplicateSKU) Then
                            column = table.GetColumnByName("Michaels_SKU")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} exists more than once in this batch."))
                        End If

                        'Duplicate Component = 131072
                        If itemLookup.HasError(Models.ItemValidationErrors.DuplicateComponent) Then
                            column = table.GetColumnByName("Michaels_SKU")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, " This item cannot be edited; it is part of an active Display Pack."))
                        End If

                        'ComponentsSamePLI = 262144 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSamePLI) Then
                            valRecord.Add("Package Language Indicator", "Component must have same Package Language Indicator settings as the Display / Display Pack.", ValidationRuleSeverityType.TypeWarning)
                        End If

                        'ComponentsSameTI = 524288 ' TIs must match
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameTI) Then
                            valRecord.Add("Translation Indicator", "Component must have same Translation Indicator settings as the Display / Display Pack.", ValidationRuleSeverityType.TypeWarning)
                        End If

                    End If


                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord AndAlso TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then


                    ' -------------------------------------
                    ' ITEM MAINTENANCE ITEM
                    ' -------------------------------------

                    Dim itemRec As Models.ItemMaintItemDetailFormRecord = CType(record, Models.ItemMaintItemDetailFormRecord)
                    Dim itemLookup As Models.ItemMaintItemValidationLookupRecord = CType(lookup, Models.ItemMaintItemValidationLookupRecord)

                    'None = 0
                    If itemLookup.ItemErrors <> Models.ItemValidationErrors.None Then


                        'ComponentsSameItemTypeAttribute = 1 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameItemTypeAttribute) Then
                            column = table.GetColumnByName("ItemTypeAttribute")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameStockCategory = 2 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameStockCategory) Then
                            column = table.GetColumnByName("StockCategory")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameStockingStrategyCode = 4 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameStockingStrategyCode) Then
                            column = table.GetColumnByName("StockingStrategyCode")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHybridType = 4 ' DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHybridType) Then
                        '    column = table.GetColumnByName("HybridType")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        'End If

                        'ComponentsSameHybridSourcingDC = 8 ' DP
                        'If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHybridSourcingDC) Then
                        '    column = table.GetColumnByName("HybridSourceDC")
                        '    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        'End If

                        'ComponentsSameHierarchyD = 16 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchyD) Then
                            column = table.GetColumnByName("DepartmentNum")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHierarchyC = 32 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchyC) Then
                            column = table.GetColumnByName("ClassNum")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameHierarchySC = 64 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameHierarchySC) Then
                            column = table.GetColumnByName("SubClassNum")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsSameVendor = 128 ' DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameVendor) Then
                            column = table.GetColumnByName("VendorNumber")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same Primary {0} as the Display Pack."))
                        End If

                        'DisplayerWarehouseSeasonalW = 256 ' D
                        If itemLookup.HasError(Models.ItemValidationErrors.DisplayerWarehouseSeasonalW) Then
                            column = table.GetColumnByName("StockCategory")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be Warehouse for a Displayer."))
                        End If

                        'DisplayerWarehouseSeasonalS = 512 'D
                        If itemLookup.HasError(Models.ItemValidationErrors.DisplayerWarehouseSeasonalS) Then
                            column = table.GetColumnByName("ItemTypeAttribute")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be Seasonal for a Displayer."))
                        End If

                        'ComponentsMustBeActive = 1024 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsMustBeActive) Then
                            column = table.GetColumnByName("ItemStatus")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be Active when component is associated with a Displayer / Display Pack."))
                        End If

                        'ComponentsSameSkuGroup = 2048 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameSkuGroup) Then
                            column = table.GetColumnByName("SKUGroup")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "Component must have same {0} as the Display Pack."))
                        End If

                        'ComponentsQtyInPack = 4096 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsQtyInPack) Then
                            column = table.GetColumnByName("QtyInPack")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} is a required field when component is associated with a Displayer / Display Pack."))
                        End If

                        'DDPActive = 8192 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.DDPActive) Then
                            column = table.GetColumnByName("ItemStatus")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{}The D and DP sku cannot be discontinued."))
                        End If

                        'DDPComponentVendors = 65536 ' D/DP Component has to have same vendors as the parent
                        If itemLookup.HasError(Models.ItemValidationErrors.DDPComponentVendors) Then
                            column = table.GetColumnByName("VendorNumber")
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{}Component must be tied to every vendor that is tied to the parent.  " & IIf(itemLookup.MissingVendorCount > 1, "Missing vendors: ", "MIssing vendor: ") & itemLookup.GetMissingVendorsAsString()))
                        End If

                        'ComponentsSamePLI = 262144 ' D/DP
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSamePLI) Then
                            valRecord.Add("Package Language Indicator", "Component must have same Package Language Indicator settings as the Display / Display Pack.", ValidationRuleSeverityType.TypeWarning)
                        End If

                        'ComponentsSameTI = 524288 ' TIs must match
                        If itemLookup.HasError(Models.ItemValidationErrors.ComponentsSameTI) Then
                            valRecord.Add("Translation Indicator", "Component must have same Translation Indicator settings as the Display / Display Pack.", ValidationRuleSeverityType.TypeWarning)
                        End If

                    End If

                    ' Existing Future Cost Change
                    Dim futureCostCancelled As Boolean = False
                    If (rowChanges IsNot Nothing AndAlso rowChanges.ChangeExists("FutureCostStatus")) Then futureCostCancelled = True
                    If itemRec.FutureCostExists OrElse futureCostCancelled Then
                        column = table.GetColumnByName("FutureCostExists")
                        valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, ("{}" & FormatFutureCostMessage(itemRec.ID, itemRec.SKU, itemRec.FutureCostExists, futureCostCancelled, renderReadOnly))), ValidationRuleSeverityType.TypeWarning)
                    End If

                End If

            Case ValidationConditionType.LookupSeasonalAllocation ' 35
                'Check that the record is a Creation Record, and Lookup the Seasonality of the Allocation Event
                Dim poCreationRecord As Models.POCreationRecord = TryCast(record, Models.POCreationRecord)
                If (poCreationRecord IsNot Nothing) Then
                    Return Data.ValidationData.LookupSeasonalAllocation(DataHelper.SmartValues(poCreationRecord.POAllocationEventID, "Cint", False, 0))
                End If

                'Check that the record is a Maintenance Record, and Lookup the Seasonality of the Allocation Event
                Dim poMaintenanceRecord As Models.POMaintenanceRecord = TryCast(record, Models.POMaintenanceRecord)
                If (poMaintenanceRecord IsNot Nothing) Then
                    Return Data.ValidationData.LookupSeasonalAllocation(DataHelper.SmartValues(poMaintenanceRecord.POAllocationEventID, "Cint", False, 0))
                End If

                'Could not determine Seasonality, so return False
                Return False
            Case ValidationConditionType.LookupValidPODateRange '36
                Dim specifiedDate As Date? = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable, True)
                Dim field As MetadataColumn = GetColumn(table, condition.Field1)
                Dim writtenDate As Date? = GetObjectValue(record, "WrittenDate")
                Dim previousDateName As String = ""

                If (specifiedDate.HasValue) Then
                    Dim previousDate As Date? = Nothing
                    Select Case field.ColumnName
                        Case "Not_Before"
                            previousDate = GetObjectValue(record, "WrittenDate")
                            previousDateName = "Written Date"
                        Case "Not_After"
                            previousDate = GetObjectValue(record, "NotBefore")
                            previousDateName = "Not Before Date"
                        Case "Estimated_In_Stock_Date"
                            previousDate = GetObjectValue(record, "NotAfter")
                            previousDateName = "Not After Date"
                    End Select

                    'RULE: If Date < PreviousDate+1 or Date > (Written Date + 300 days), date is not valid
                    If (previousDate.HasValue) Then
                        If previousDate.Value.Date.AddDays(1) > specifiedDate Or writtenDate.Value.Date.AddDays(300) < specifiedDate Then
                            column = GetColumn(table, condition.Field1)
                            valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, "{0} must be > " & previousDateName & " and < " & writtenDate.Value.Date.AddDays(300)), ValidationRuleSeverityType.TypeError)
                        End If
                    End If
                End If

                Return False
            Case ValidationConditionType.LookupValidPOSkuStoreLoc '37
                Dim validLocations As ArrayList = CType(lookup, ArrayList)

                Dim poCreationSKuStore As Models.POCreationSKUStoreRecord = TryCast(record, Models.POCreationSKUStoreRecord)
                If (poCreationSKuStore IsNot Nothing) Then
                    'RULE: Only validate the location if one is specified
                    If (DataHelper.SmartValue(poCreationSKuStore.POLocationID, "CInt", 0) > 0) Then
                        If Not (validLocations.Contains(poCreationSKuStore.POLocationID)) Then
                            'Create Error
                            valRecord.Add("", poCreationSKuStore.StoreNumber & " belongs to a Zone that is not part of this Purchase Order", ValidationRuleSeverityType.TypeError)
                        End If
                    End If
                End If


                Dim poMaintenanceSKUStore As Models.POMaintenanceSKUStoreRecord = TryCast(record, Models.POMaintenanceSKUStoreRecord)
                If (poMaintenanceSKUStore IsNot Nothing) Then
                    If Not (validLocations.Contains(poMaintenanceSKUStore.POLocationID)) Then
                        'Create Error
                        valRecord.Add("", poMaintenanceSKUStore.StoreNumber & " belongs to a Zone that is not part of this Purchase Order", ValidationRuleSeverityType.TypeError)
                    End If
                End If

            Case ValidationConditionType.LookupIsDeleted '38
                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable, True)
                Dim field As MetadataColumn = GetColumn(table, condition.Field1)
                'Check to see if the field's value has been flagged as DELETED
                If value1 IsNot Nothing Then
                    Select Case field.ColumnName.Trim
                        Case "PO_Allocation_Event_ID"
                            result = Data.ValidationData.LookupAllocationIsDeleted(value1)
                        Case "Ship_Point_Code"
                            result = Data.ValidationData.LookupShipPointIsDeleted(value1)
                        Case "Payment_Terms_ID"
                            result = Data.ValidationData.LookupPaymentTermsIsDeleted(value1)
                        Case "Michaels_SKU"
                            Dim vendorNumber As Long = CType(lookup, Long)
                            Dim itemData As DataTable = Data.ValidationData.LookupSKURMSData(vendorNumber, value1.ToString)
                            If itemData.Rows.Count = 0 Then
                                Return True
                            End If
                        Case Else
                            'DO NOTHING
                    End Select
                End If
            Case ValidationConditionType.LookupSKUFieldMatchesItem  '39
                'Get Value of specified Field, and Vendor Number from lookup object
                value1 = GetObjectValue(record, table, condition.Field1, parentRecord, parentTable, True)
                Dim vendorNumber As Long = CType(lookup, Long)
                Dim sku As String = GetObjectValue(record, "MichaelsSKU")

                Dim itemData As DataTable = Data.ValidationData.LookupSKURMSData(vendorNumber, sku)
                If (itemData.Rows.Count > 0) Then
                    Dim field As MetadataColumn = GetColumn(table, condition.Field1)
                    Select Case (field.ColumnName)
                        Case "Inner_Pack"
                            If (value1.ToString() <> DataHelper.SmartValue(itemData.Rows(0)("Eaches_Inner_Pack"), "CStr", "")) Then
                                Return True
                            End If
                        Case "Master_Pack"
                            If (value1.ToString() <> DataHelper.SmartValue(itemData.Rows(0)("Eaches_Master_Case"), "CStr", "")) Then
                                Return True
                            End If
                        Case "Unit_Cost"
                            If (CType(value1, Double) <> DataHelper.SmartValue(itemData.Rows(0)("Unit_Cost"), "CDbl", Nothing)) Then
                                Return True
                            End If
                    End Select
                End If
            Case ValidationConditionType.LookupValidPOOrderedQty '40
                'Get identifying values from the recordset
                Dim orderedQty As Integer = GetObjectValue(record, "OrderedQty")
                Dim poMaintenanceID As Long? = GetObjectValue(record, "POMaintenanceID")
                Dim sku As String = GetObjectValue(record, "MichaelsSKU")

                'Get the current Revision record, and compare it's ordered quantity to the current ordered quantity
                If TypeOf record Is Models.POMaintenanceSKURecord Then
                    Dim revisionPO As Models.POMaintenanceSKURecord = Data.POMaintenanceSKUData.GetRecentRevisionRecord(poMaintenanceID, sku)
                    If (orderedQty < revisionPO.OrderedQty) Then
                        Return True
                    End If
                End If
                If TypeOf record Is Models.POMaintenanceSKUStoreRecord Then
                    Dim originalOrderedQty As Integer = GetObjectValue(record, "OriginalOrderedQty")
                    If (orderedQty < originalOrderedQty) Then
                        Return True
                    End If
                End If

            Case ValidationConditionType.LookupLocationOrderedSKUs '41
                'Get identifying values from the recordset
                Dim POCreationID As Integer = GetObjectValue(record, "POCreationID")
                Dim POLocationID As Integer = GetObjectValue(record, "ID")

                If Data.POCreationData.CacheHasAtLeastOneSKU(POCreationID, AppHelper.GetUserID) Then
                    If Not Data.POCreationData.LocationCacheHasAtLeastOneSKUOrdered(POCreationID, POLocationID, AppHelper.GetUserID()) Then
                        valRecord.Add("", " location must have at least one SKU with a quantity > 0", ValidationRuleSeverityType.TypeError)
                    End If
                End If
            Case ValidationConditionType.LookupTranslationDesc '42
                Dim itemRec As Models.ItemMaintItemDetailFormRecord = CType(record, Models.ItemMaintItemDetailFormRecord)
                Dim originalItemRec As Models.ItemMaintItemDetailFormRecord = CType(originalRecord, Models.ItemMaintItemDetailFormRecord)
                'NAK 8/7/2012: When the value is changed in one of these fields: "Sku description", "English Long Description", "English Short Description", user should be thrown a soft validation message to make the change consistent across all the fields.
                If (itemRec.ItemDesc <> originalItemRec.ItemDesc) Or (itemRec.EnglishLongDescription <> originalItemRec.EnglishLongDescription) Or (itemRec.EnglishShortDescription <> originalItemRec.EnglishShortDescription) Then
                    valRecord.Add("ItemDesc", "A change has been made to the Item's Description fields.  Please make sure the change is consistent in the Item Description, English Long Description, and English Short Description.  Change the Translation Indicator value if a translation is needed.", ValidationRuleSeverityType.TypeWarning)
                End If
            Case ValidationConditionType.IsDate '43
                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", False)
                If Not String.IsNullOrEmpty(value1) Then
                    result = Not DateTime.TryParseExact(value1, "M/d/yyyy", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, New DateTime)
                End If

            Case ValidationConditionType.IsFutureDate '44
                value1 = DataHelper.SmartValues(GetObjectValue(record, table, condition.Field1, parentRecord, parentTable), "string", False)
                If Not String.IsNullOrEmpty(value1) And IsDate(value1) Then
                    value2 = condition.Value1
                    Dim itemDate As Date = Convert.ToDateTime(value1)
                    Dim futureDate As Date = Convert.ToDateTime(DateTime.Now.Date)
                    futureDate = futureDate.AddDays(DataHelper.SmartValues(value2, "CInt", False, 0))
                    result = Not (itemDate > futureDate)
                End If
            Case ValidationConditionType.LookupBatchTypes '45
                'Get Item Record
                Dim itemRec As Models.ItemMaintItemDetailFormRecord = CType(record, Models.ItemMaintItemDetailFormRecord)
                Dim itemLookup As Models.ItemMaintItemValidationLookupRecord = CType(lookup, Models.ItemMaintItemValidationLookupRecord)

                'Get Batch information
                Dim batchDB As New NovaLibra.Coral.Data.Michaels.BatchData
                Dim batchList As List(Of Models.BatchRecord) = batchDB.GetBatchesBySKU(itemRec.SKU)
                For Each batch As Models.BatchRecord In batchList
                    If batch.BatchTypeID <> itemRec.BatchTypeID Then
                        'Determine what type of batch the SKU is also in.
                        Dim batchDescription As String
                        Select Case batch.BatchTypeID
                            Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualExemptions
                                batchDescription = "Trilingual PLI/Exemption"
                            Case NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.TrilingualTranslations
                                batchDescription = "Trilingual Translation"
                            Case Else
                                batchDescription = "Item Maintenance"
                        End Select

                        'Add Warning to validatino Record
                        column = table.GetColumnByName("SKU")
                        valRecord.Add(column.ColumnName, "SKU " & itemRec.SKU & " is also in " & batchDescription & " Batch " & batch.ID & ".", ValidationRuleSeverityType.TypeWarning)
                    End If
                Next
            Case ValidationConditionType.LookupVendorTypes '46
                Dim item As Models.ImportItemRecord = TryCast(record, Models.ImportItemRecord)
                If item IsNot Nothing Then
                    Dim vendorOrAgent As String = NovaLibra.Coral.Data.Michaels.VendorData.GetVendorType(item.VendorNumber)

                    If item.Vendor = "YES" And vendorOrAgent = "A" Then
                        valRecord.Add("Vendor", "This item marked as a Vendor Supplier, but the provided Supplier Number is an Agent.  Please change this item to use an Agent Supplier.", ValidationRuleSeverityType.TypeError)
                    End If
                    If item.Agent = "YES" And vendorOrAgent = "V" Then
                        valRecord.Add("Agent", "This item marked as an Agent Supplier, but the provided Supplier Number is a Vendor.  Please change this item to use a Vendor Supplier.", ValidationRuleSeverityType.TypeError)
                    End If
                End If
            Case ValidationConditionType.LookupStockingStrategyStatus '47
                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).StockingStrategyStatusValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).StockingStrategyStatusValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).StockingStrategyStatusValid
                Else
                    Throw New Exception("Validation lookup (Stocking Strategy Status Valid) is not valid for this type of object.")
                End If
            Case ValidationConditionType.LookupStockingStrategyType '48
                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).StockingStrategyTypeValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).StockingStrategyTypeValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).StockingStrategyTypeValid
                Else
                    Throw New Exception("Validation lookup (Stocking Strategy Type Valid) is not valid for this type of object.")
                End If
            Case ValidationConditionType.LookupInnerWeightEachesCompare '49
                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).InnerWeightEachesCompareValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).InnerWeightEachesCompareValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).InnerWeightEachesCompareValid
                Else
                    Throw New Exception("Validation lookup (Inner Weight Eaches Compare Valid) is not valid for this type of object.")
                End If
            Case ValidationConditionType.LookupMasterWeightEachesCompare '50
                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).MasterWeightEachesCompareValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).MasterWeightEachesCompareValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).MasterWeightEachesCompareValid
                Else
                    Throw New Exception("Validation lookup (Master Weight Eaches Compare Valid) is not valid for this type of object.")
                End If
            Case ValidationConditionType.LookupMasterWeightInnerEachesRatio '51
                If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemValidationLookupRecord).MasterWeightInnerEachesRatioValid
                ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ImportItemValidationLookupRecord).MasterWeightInnerEachesRatioValid
                ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                    result = Not CType(lookup, Models.ItemMaintItemValidationLookupRecord).MasterWeightInnerEachesRatioValid
                Else
                    Throw New Exception("Validation lookup (Master Weight Inner Eaches Ratio Valid) is not valid for this type of object.")
                End If

                'Case ValidationConditionType.LookupGTINValidation '52

                '    If TypeOf record Is Models.ItemRecord AndAlso TypeOf lookup Is Models.ItemValidationLookupRecord Then

                '        '---------------------------------
                '        ' new domestic item GTIN
                '        '---------------------------------
                '        Dim item As Models.ItemRecord = CType(record, Models.ItemRecord)
                '        Dim itemLookup As Models.ItemValidationLookupRecord = CType(lookup, Models.ItemValidationLookupRecord)

                '        If currentConditionResult OrElse currentConditionIndex = 0 Then
                '            If Not IsEmpty(item.VendorInnerGTIN) Then
                '                If item.VendorInnerGTIN.Length <> 14 Then
                '                    column = table.GetColumnByName("VendorInnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_LENGTH))
                '                ElseIf Not ValidateGTIN(item.VendorInnerGTIN) Then
                '                    column = table.GetColumnByName("VendorInnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_INVALID))
                '                ElseIf itemLookup.InnerGTINExists(item.VendorInnerGTIN) Then
                '                    column = table.GetColumnByName("VendorInnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_EXISTS))
                '                ElseIf itemLookup.DupBatch(item.VendorInnerGTIN) Then
                '                    column = table.GetColumnByName("VendorInnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPBATCH))
                '                ElseIf itemLookup.DupWorkflow(item.VendorInnerGTIN) Then
                '                    column = table.GetColumnByName("VendorInnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPWORKFLOW))
                '                End If
                '            End If

                '            If Not IsEmpty(item.VendorCaseGTIN) Then
                '                If item.VendorCaseGTIN.Length <> 14 Then
                '                    column = table.GetColumnByName("VendorCaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_LENGTH))
                '                ElseIf Not ValidateGTIN(item.VendorCaseGTIN) Then
                '                    column = table.GetColumnByName("VendorCaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_INVALID))
                '                ElseIf itemLookup.InnerGTINExists(item.VendorCaseGTIN) Then
                '                    column = table.GetColumnByName("VendorCaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_EXISTS))
                '                ElseIf itemLookup.DupBatch(item.VendorCaseGTIN) Then
                '                    column = table.GetColumnByName("VendorCaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPBATCH))
                '                ElseIf itemLookup.DupWorkflow(item.VendorCaseGTIN) Then
                '                    column = table.GetColumnByName("VendorCaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPWORKFLOW))
                '                End If
                '            End If

                '        End If

                '    ElseIf TypeOf record Is Models.ImportItemRecord AndAlso TypeOf lookup Is Models.ImportItemValidationLookupRecord Then

                '        '---------------------------------
                '        ' new import item GTIN
                '        '---------------------------------
                '        'Dim errorText As String
                '        Dim importItem As Models.ImportItemRecord = CType(record, Models.ImportItemRecord)
                '        Dim itemLookup As Models.ImportItemValidationLookupRecord = CType(lookup, Models.ImportItemValidationLookupRecord)

                '        If currentConditionResult OrElse currentConditionIndex = 0 Then
                '            If Not IsEmpty(importItem.InnerGTIN) Then
                '                If importItem.InnerGTIN.Length <> 14 Then
                '                    column = table.GetColumnByName("InnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_LENGTH))
                '                ElseIf (Not IsNumeric(importItem.InnerGTIN)) Or Not ValidateGTIN(importItem.InnerGTIN) Then
                '                    column = table.GetColumnByName("InnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_INVALID))
                '                ElseIf itemLookup.InnerGTINExists(importItem.InnerGTIN) Then
                '                    column = table.GetColumnByName("InnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_EXISTS))
                '                ElseIf itemLookup.InnerGTINDupBatch(importItem.InnerGTIN) Then
                '                    column = table.GetColumnByName("InnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPBATCH))
                '                ElseIf itemLookup.InnerGTINDupWorkflow(importItem.InnerGTIN) Then
                '                    column = table.GetColumnByName("InnerGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPWORKFLOW))
                '                End If
                '            End If

                '            If Not IsEmpty(importItem.CaseGTIN) Then
                '                If importItem.CaseGTIN.Length <> 14 Then
                '                    column = table.GetColumnByName("CaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_CASE_GTIN_ERROR_LENGTH))
                '                ElseIf (Not IsNumeric(importItem.CaseGTIN)) Or Not ValidateGTIN(importItem.CaseGTIN) Then
                '                    column = table.GetColumnByName("CaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_CASE_GTIN_ERROR_INVALID))
                '                ElseIf itemLookup.CaseGTINExists(importItem.CaseGTIN) Then
                '                    column = table.GetColumnByName("CaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_CASE_GTIN_ERROR_EXISTS))
                '                ElseIf itemLookup.CaseGTINDupBatch(importItem.CaseGTIN) Then
                '                    column = table.GetColumnByName("CaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPBATCH))
                '                ElseIf itemLookup.CaseGTINDupWorkflow(importItem.CaseGTIN) Then
                '                    column = table.GetColumnByName("CaseGTIN")
                '                    valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPWORKFLOW))
                '                End If
                '            End If
                '        End If

                '    ElseIf TypeOf record Is Models.ItemMaintItemDetailFormRecord And TypeOf lookup Is Models.ItemMaintItemValidationLookupRecord Then
                '        ' Item Maint GTIN
                '        If Not IsEmpty(lookup.InnerGTIN) Then
                '            If lookup.InnerGTIN.Length <> 14 Then
                '                column = table.GetColumnByName("InnerGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_LENGTH))
                '            ElseIf (Not IsNumeric(lookup.InnerGTIN)) Or Not ValidateGTIN(lookup.InnerGTIN) Then
                '                column = table.GetColumnByName("InnerGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_INVALID))
                '            ElseIf lookup.InnerGTINExists() Then
                '                column = table.GetColumnByName("InnerGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_INNER_GTIN_ERROR_EXISTS))
                '            ElseIf lookup.InnerGTINDupBatch() Then
                '                column = table.GetColumnByName("InnerGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPBATCH))
                '            ElseIf lookup.InnerGTINDupWorkflow() Then
                '                column = table.GetColumnByName("InnerGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPWORKFLOW))
                '            End If
                '        End If

                '        If Not IsEmpty(lookup.CaseGTIN) Then
                '            If lookup.CaseGTIN.Length <> 14 Then
                '                column = table.GetColumnByName("CaseGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_CASE_GTIN_ERROR_LENGTH))
                '            ElseIf (Not IsNumeric(lookup.CaseGTIN)) Or Not ValidateGTIN(lookup.CaseGTIN) Then
                '                column = table.GetColumnByName("CaseGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_CASE_GTIN_ERROR_INVALID))
                '            ElseIf lookup.CaseGTINExists() Then
                '                column = table.GetColumnByName("CaseGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_CASE_GTIN_ERROR_EXISTS))
                '            ElseIf lookup.CaseGTINDupBatch() Then
                '                column = table.GetColumnByName("CaseGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPBATCH))
                '            ElseIf lookup.CaseGTINDupWorkflow() Then
                '                column = table.GetColumnByName("CaseGTIN")
                '                valRecord.Add(column.ColumnName, column.DisplayName, FormatErrorText(column, VALIDATION_GTIN_ERROR_DUPWORKFLOW))
                '            End If
                '        End If
                '    Else
                '        Throw New Exception("Validation lookup (GTIN) is not valid for this type of object.")
                '    End If
                '    result = False
        End Select

        Return result
    End Function

    Private Shared Function FormatFutureCostMessage(ByVal ID As Integer, ByVal SKU As String, ByVal futureCostExists As Boolean, ByVal futureCostCancelled As Boolean, ByVal renderReadOnly As Boolean) As String
        Dim msg As String = String.Empty
        If futureCostExists OrElse futureCostCancelled Then
            If futureCostExists Then
                If futureCostCancelled Then
                    msg = "SKU " & SKU & " has pending approved cost changes and cancelled pending approved cost changes. " & FormatFutureCostMessageLink(ID, renderReadOnly)
                Else
                    msg = "SKU " & SKU & " has pending approved cost changes. " & FormatFutureCostMessageLink(ID, renderReadOnly)
                End If
            Else
                msg = "SKU " & SKU & " has cancelled pending approved cost changes. " & FormatFutureCostMessageLink(ID, renderReadOnly)
            End If
        End If
        Return msg
    End Function

    Private Shared Function FormatFutureCostMessageLink(ByVal id As Integer, ByVal renderReadOnly As Boolean) As String
        If renderReadOnly Then
            Return String.Format("<a onclick="" openItemCustomWindow({0}); return false;"" href=""#"">View Future Cost Changes</a>", id)
        Else
            Return String.Format("<a onclick="" openItemCustomWindow({0}); return false;"" href=""#"">Edit Future Cost Changes</a>", id)
        End If
    End Function

    Private Shared Function FormatErrorText(ByRef column As MetadataColumn, ByVal errorText As String) As String
        Return FormatErrorText(column.ColumnName, column.DisplayName, errorText)
    End Function

    Private Shared Function FormatErrorText(ByVal columnName As String, ByVal displayName As String, ByVal errorText As String) As String
        If errorText.Contains("{0}") Then
            Return String.Format(FixErrorText(errorText), FormatErrorText(columnName, displayName))
        ElseIf errorText.StartsWith("{}") Then
            Return FixErrorText(errorText.Replace("{}", ""))
        Else
            Return (FormatErrorText(columnName, displayName) & " " & FixErrorText(errorText))
        End If
    End Function

    Private Shared Function FormatErrorText(ByRef column As MetadataColumn) As String
        Return FormatErrorText(column.ColumnName, column.DisplayName)
    End Function

    Private Shared Function FormatErrorText(ByVal columnName As String, ByVal displayName As String) As String
        Return ("<span class="" errLink"" control=""" & columnName.Replace(" _", "") & """>" & displayName & "</span>")
    End Function

    Private Shared Function FixErrorText(ByVal errorText As String) As String
        errorText = errorText.Trim()
        If errorText.Substring(errorText.Length - 1, 1) <> "." Then errorText = errorText & "."
        Return errorText
    End Function

    Private Shared Function EvaluateOperation(ByRef value1 As Object, ByVal op As String, ByRef value2 As Object) As Boolean
        Dim result As Boolean = False
        Select Case op
            Case "<="
                result = (value1 <= value2)
            Case "<"
                result = (value1 <value2)
            Case "="
                result = (value1 = value2)
            Case "!="
                result = (value1 <> value2)
            Case ">"
                result = (value1 > value2)
            Case ">="
                result = (value1 >= value2)
            Case "CONTAINS"
                If value1 Is Nothing Then value1 = ""
                If value2 Is Nothing Then value2 = ""
                result = (value1.ToString().Contains(value2.ToString()))
            Case "!CONTAINS"
                If value1 Is Nothing Then value1 = ""
                If value2 Is Nothing Then value2 = ""
                result = Not (value1.ToString().Contains(value2.ToString()))
            Case "LIKE"
                If value1 Is Nothing Then value1 = ""
                If value2 Is Nothing Then value2 = ""
                Dim str As String = value2.ToString()
                Dim s As String = str.Substring(str.Length - 1, 1)
                If s = "*" Or s = "%" Then
                    result = (value1.ToString().IndexOf(str) = 0)
                Else
                    result = (value1.ToString().Contains(str))
                End If
        End Select
        Return result
    End Function

    Public Shared Function TypeMatch(ByRef value1 As Object, ByRef value2 As Object) As Object
        If TypeOf value1 Is String Then
            Return DataHelper.SmartValues(value2, "string", True)
        ElseIf TypeOf value1 Is Integer Then
            Return DataHelper.SmartValues(value2, "integer", True)
        ElseIf TypeOf value1 Is Long Then
            Return DataHelper.SmartValues(value2, "long", True)
        ElseIf TypeOf value1 Is Decimal Then
            Return DataHelper.SmartValues(value2, "decimal", True)
        ElseIf TypeOf value1 Is Date Then
            Return DataHelper.SmartValues(value2, "date", True)
        ElseIf TypeOf value1 Is Boolean Then
            If value2.ToString() = "1" OrElse value2.ToString() = "True" Then
                Return True
            ElseIf value2.ToString() = "0" OrElse value2.ToString() = "False" Then
                Return False
            End If
            Return DataHelper.SmartValues(value2, "boolean", True)
        ElseIf TypeOf value1 Is Byte Then
            Return DataHelper.SmartValues(value2, "integer", True)
        ElseIf TypeOf value1 Is Char Then
            Return DataHelper.SmartValues(value2, "string", True)
        ElseIf TypeOf value1 Is Single Then
            Return DataHelper.SmartValues(value2, "single", True)
        ElseIf TypeOf value1 Is Double Then
            Return DataHelper.SmartValues(value2, "double", True)
        Else
            Return value2
        End If
    End Function

    Private Shared Function GetColumn(ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByVal columnID As Integer) As NovaLibra.Coral.SystemFrameworks.MetadataColumn

        Dim column As NovaLibra.Coral.SystemFrameworks.MetadataColumn = table.GetColumnByID(columnID)
        'Dim i As Integer
        'If column Is Nothing Then
        '    For i = 0 To table.GetParentRelationships().Count - 1
        '        column = table.GetParentRelationships().Item(i).ParentTable.GetColumnByID(columnID)
        '        If Not column Is Nothing Then Exit For
        '    Next
        'End If
        'If column Is Nothing Then
        '    For i = 0 To table.GetChildRelationships().Count - 1
        '        column = table.GetChildRelationships().Item(i).ChildTable.GetColumnByID(columnID)
        '        If Not column Is Nothing Then Exit For
        '    Next
        'End If
        Return column
    End Function

#End Region

#Region "Validation Reflection Methods"

    Public Shared Function HasProperty(ByRef obj As Object, ByRef table As MetadataTable, ByVal columnID As Integer) As Boolean
        Dim column As MetadataColumn = table.GetColumnByID(columnID)
        If Not column Is Nothing Then Return HasProperty(obj, table.GetColumnByID(columnID)) Else Return False
    End Function

    Public Shared Function HasProperty(ByRef obj As Object, ByRef column As MetadataColumn) As Boolean
        Return HasProperty(obj, column.ColumnName)
    End Function

    Public Shared Function HasProperty(ByRef obj As Object, ByRef columnName As String) As Boolean
        Dim t As Type = obj.GetType()
        Dim propInfo As PropertyInfo = t.GetProperty(columnName)
        If propInfo Is Nothing Then
            Return False
        Else
            Return True
        End If
    End Function

    Public Shared Function GetField(ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByVal columnID As Integer, _
     ByRef parentTable As NovaLibra.Coral.SystemFrameworks.MetadataTable) As NovaLibra.Coral.SystemFrameworks.MetadataColumn

        Dim field As NovaLibra.Coral.SystemFrameworks.MetadataColumn

        field = GetColumn(table, columnID)
        If field Is Nothing AndAlso (Not parentTable Is Nothing) Then
            field = GetColumn(parentTable, columnID)
        End If

        Return field
    End Function


    Public Shared Function GetObjectValue(ByRef record As Object, _
     ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByVal columnID As Integer, _
     ByRef parentRecord As Object, _
     ByRef parentTable As NovaLibra.Coral.SystemFrameworks.MetadataTable) As Object

        Return GetObjectValue(record, table, columnID, parentRecord, parentTable, False)
    End Function
    Public Shared Function GetObjectValue(ByRef record As Object, _
     ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByVal columnID As Integer, _
     ByRef parentRecord As Object, _
     ByRef parentTable As NovaLibra.Coral.SystemFrameworks.MetadataTable, _
     ByVal convertType As Boolean) As Object

        Dim field As NovaLibra.Coral.SystemFrameworks.MetadataColumn
        Dim rec As Object = record

        Dim value As Object = Nothing

        field = GetColumn(table, columnID)
        If field Is Nothing AndAlso (Not parentTable Is Nothing) Then
            field = GetColumn(parentTable, columnID)
            If Not field Is Nothing Then rec = parentRecord
        End If
        If Not field Is Nothing AndAlso Not rec Is Nothing Then
            value = GetObjectValue(rec, field, convertType)
        Else
            Throw New Exception("Could not find the column for validation.")
        End If

        Return value
    End Function

    Public Shared Function GetObjectValue(ByRef obj As Object, ByRef table As MetadataTable, ByVal columnID As Integer) As Object
        Return GetObjectValue(obj, table, columnID, False)
    End Function
    Public Shared Function GetObjectValue(ByRef obj As Object, ByRef table As MetadataTable, ByVal columnID As Integer, ByVal convertType As Boolean) As Object
        Dim column As MetadataColumn = table.GetColumnByID(columnID)
        If Not column Is Nothing Then Return GetObjectValue(obj, column, convertType) Else Return Nothing
    End Function

    Public Shared Function GetObjectValue(ByRef obj As Object, ByRef column As MetadataColumn) As Object
        Return GetObjectValue(obj, column, False)
    End Function
    Public Shared Function GetObjectValue(ByRef obj As Object, ByRef column As MetadataColumn, ByVal convertType As Boolean) As Object
        Dim value As Object = Nothing
        If Not column Is Nothing Then
            If convertType AndAlso column.GenericType <> column.Format Then
                Dim strType As String = column.Format.ToLower()
                Select Case strType
                    Case "formatdate"
                        strType = "date"
                    Case "formatnumber0", "formatnumber", "formatnumber2", "formatnumber3", "formatnumber4", "formatcurrency", "formatcurrency4"
                        strType = "decimal"
                    Case "percent", "percentvalue"
                        strType = "decimal"
                End Select
                value = DataHelper.SmartValues(GetObjectValue(obj, column.ColumnName.Replace("_", "")), strType, True)
                If column.Format.ToLower.Contains("percent") Then
                    If Not IsEmpty(value) Then
                        value = value * 100
                    End If
                End If
            Else
                value = GetObjectValue(obj, column.ColumnName.Replace("_", ""))
            End If
        End If
        Return value
    End Function

    Public Shared Function GetObjectValue(ByRef obj As Object, ByVal propertyName As String) As Object
        Dim value As Object = Nothing
        If propertyName <> String.Empty Then
            ' get the class type
            Dim t As Type = obj.GetType()
            ' get the property info 
            Dim propInfo As PropertyInfo = t.GetProperty(propertyName)
            ' get the value
            If propInfo IsNot Nothing Then
                value = propInfo.GetValue(obj, Nothing)
            End If
        End If
        ' return the value
        Return value
    End Function

#End Region


    ' ********************************
    ' * VALIDATION DISPLAY FUNCTIONS *
    ' ********************************
#Region "Validation Display Functions"

    Public Shared Function GetValidationDisplayString(ByVal validFlag As Models.ItemValidFlag) As String
        Return GetValidationDisplayString(validFlag, False)
    End Function

    Public Shared Function GetValidationDisplayString(ByVal validFlag As Models.ItemValidFlag, ByVal small As Boolean) As String
        Select Case validFlag
            Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Unknown
                If small Then
                    Return VALIDATION_DISPLAY_UNKNOWN_SM
                Else
                    Return VALIDATION_DISPLAY_UNKNOWN
                End If
            Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid
                If small Then
                    Return VALIDATION_DISPLAY_NOTVALID_SM
                Else
                    Return VALIDATION_DISPLAY_NOTVALID
                End If
            Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid
                If small Then
                    Return VALIDATION_DISPLAY_VALID_SM
                Else
                    Return VALIDATION_DISPLAY_VALID
                End If
            Case Else
                Return String.Empty
        End Select
    End Function

    Public Shared Function GetValidationImageString(ByVal validFlag As Models.ItemValidFlag) As String
        Return GetValidationImageString(validFlag, False)
    End Function

    Public Shared Function GetValidationImageString(ByVal validFlag As Models.ItemValidFlag, ByVal small As Boolean) As String
        Select Case validFlag
            Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Unknown
                If small Then
                    Return VALIDATION_IMAGE_UNKNOWN_SM
                Else
                    Return VALIDATION_IMAGE_UNKNOWN
                End If
            Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.NotValid
                If small Then
                    Return VALIDATION_IMAGE_NOTVALID_SM
                Else
                    Return VALIDATION_IMAGE_NOTVALID
                End If
            Case NovaLibra.Coral.SystemFrameworks.Michaels.ItemValidFlag.Valid
                If small Then
                    Return VALIDATION_IMAGE_VALID_SM
                Else
                    Return VALIDATION_IMAGE_VALID
                End If
            Case Else
                Return String.Empty
        End Select
    End Function

    Private Shared Function WrapError(ByRef ve As Models.ValidationError, ByVal recordID As Long) As String
        Return WrapError(ve.ErrorSeverity, recordID)
    End Function

    Private Shared Function WrapError(ByVal errorSeverity As ValidationRuleSeverityType, ByVal recordID As Long) As String
        Dim css As String

        Select Case errorSeverity
            Case ValidationRuleSeverityType.TypeError
                css = "sevError"
            Case ValidationRuleSeverityType.TypeWarning
                css = "sevWarning"
            Case ValidationRuleSeverityType.TypeInformation
                css = "sevInfo"
            Case Else
                css = "sevError"
        End Select
        Return "<span class='" & css & "' title='" & recordID & "'>" & ValidationRuleSeverityDesc(errorSeverity) & ":&nbsp;</span>"

    End Function

    Private Shared Function ValidationRuleSeverityDesc(ByVal errorSeverity As ValidationRuleSeverityType) As String
        Dim ret As String
        Select Case errorSeverity
            Case ValidationRuleSeverityType.TypeError
                ret = "Error"
            Case ValidationRuleSeverityType.TypeInformation
                ret = "Info"
            Case ValidationRuleSeverityType.TypeWarning
                ret = "Warning"
            Case ValidationRuleSeverityType.typeUnknown
                ret = ("Unknown Error")
            Case Else
                ret = ""
        End Select
        Return ret
    End Function

    Public Shared Sub SetupValidationSummary(ByRef summary As NovaLibra.Controls.NLValidationSummary)
        summary.HeaderText = VALIDATION_HEADER_TEXT
        summary.Attributes.Item("style") = "color: #993300;"
    End Sub

    Public Shared Sub LoadValidationSummary(ByRef summary As NovaLibra.Controls.NLValidationSummary, ByRef valRecord As Models.ValidationRecord)
        LoadValidationSummary(summary, valRecord, False)
    End Sub

    Public Shared Sub LoadValidationSummary(ByRef summary As NovaLibra.Controls.NLValidationSummary, ByRef valRecord As Models.ValidationRecord, ByVal showCount As Boolean)
        SetupValidationSummary(summary)

        If showCount Then
            summary.HeaderText = summary.HeaderText & String.Format(" ({0})", valRecord.Count)
        End If

        AddValidationSummaryErrors(summary, valRecord)
    End Sub

    Public Shared Sub LoadValidationSummary(ByRef summary As NovaLibra.Controls.NLValidationSummary, ByRef message As String)
        summary.HeaderText = VALIDATION_HEADER_TEXT
        summary.Attributes.Item("style") = "color: #993300;"
        summary.AddMessage(message)
    End Sub

    Public Shared Sub AddValidationSummaryErrors(ByRef summary As NovaLibra.Controls.NLValidationSummary, ByRef valRecord As Models.ValidationRecord, Optional skuInfo As String = "")
        Dim TranslatedError As String
        If valRecord IsNot Nothing Then
            For Each ve As Models.ValidationError In valRecord.ValidationErrors
                TranslatedError = ReplaceZoneNames(ve.ErrorText)
                If String.IsNullOrEmpty(skuInfo) Then
                    summary.AddMessage(WrapError(ve, valRecord.RecordID) & TranslatedError)
                Else
                    summary.AddMessage(WrapError(ve, valRecord.RecordID) & skuInfo & "  " & TranslatedError)
                End If
            Next
        End If
    End Sub

    Public Shared Sub AddValidationSummaryErrorByText(ByRef summary As NovaLibra.Controls.NLValidationSummary, ByRef message As String)
        summary.AddMessage(message)
    End Sub

#End Region

    ' ********************
    ' * helper functions *
    ' ********************
#Region "Helper Functions"

    Public Shared Function ReplaceZoneNames(ByVal sInput As String) As String
        Dim sTemp As String = sInput
        sTemp = Replace(sTemp, "Alaska (4)</span> Alaska Retail", "High Cost (27)</span> High Cost Retail")
        sTemp = Replace(sTemp, "Quebec Retail</span> Quebec Retail", "Quebec (14)</span> Quebec Retail")
        sTemp = Replace(sTemp, "than Base 1.", "than Low Elas3 (29) Retail.")
        sTemp = Replace(sTemp, "than the Base 1 Retail.", "than Low Elas3 (29) Retail.")
        sTemp = Replace(sTemp, "equal to Base 1 Retail.", "equal to Low Elas3 (29) Retail.")
        Return sTemp
    End Function

    Public Shared Function SkipValidation(ByVal stageType As Models.WorkflowStageType) As Boolean
        If stageType = Models.WorkflowStageType.WaitingForSKU Or stageType = Models.WorkflowStageType.WaitingForPONumber Or _
         stageType = Models.WorkflowStageType.Completed Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function SkipBatchValidation(ByVal stageType As Models.WorkflowStageType) As Boolean
        If stageType = Models.WorkflowStageType.WaitingForSKU Or _
         stageType = Models.WorkflowStageType.Completed Or _
         stageType = Models.WorkflowStageType.Tax Then

            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function IsObj(ByRef obj As Object) As Boolean
        Return (Not obj Is Nothing)
    End Function

    Public Shared Function IsValidFormValue(ByRef request As System.Web.HttpRequest, ByVal formElement As String, ByVal fieldType As String) As Boolean
        Return IsValidFormValue(request, formElement, fieldType, True, String.Empty)
    End Function

    Public Shared Function IsValidFormValue(ByRef request As System.Web.HttpRequest, ByVal formElement As String, ByVal fieldType As String, ByVal isEmptyValid As Boolean) As Boolean
        Return IsValidFormValue(request, formElement, fieldType, isEmptyValid, String.Empty)
    End Function

    Public Shared Function IsValidFormValue(ByRef request As System.Web.HttpRequest, ByVal formElement As String, ByVal fieldType As String, ByVal isEmptyValid As Boolean, ByVal charsToRemove As String) As Boolean
        Dim retValue As Boolean = False
        Dim strValue As String = String.Empty
        ' test to see if a value exists in the form
        If IsObj(request) AndAlso (Not request.Form(formElement) Is Nothing) AndAlso request.Form(formElement) <> String.Empty Then
            strValue = request.Form(formElement)
            If charsToRemove <> String.Empty Then
                For i As Integer = 0 To charsToRemove.Length - 1
                    strValue = strValue.Replace(charsToRemove.Substring(i, 1), "")
                Next
            End If
            If Not IsEmpty(DataHelper.SmartValues(strValue, fieldType, True)) Then
                retValue = True
            End If
        Else
            ' no value in form (or no form).. is empty value valid?  or no?
            If isEmptyValid Then
                retValue = True
            End If
        End If
        Return retValue
    End Function

    Public Shared Function DateRangeValidator(ByVal dateStr As String, ByVal MinDate As String, ByVal MaxDate As String, ByVal MinDateInclusive As Boolean, ByVal MaxDateInclusive As Boolean) As Boolean

        Dim valid As Boolean = False

        If IsDate(dateStr) AndAlso IsDate(MinDate) AndAlso IsDate(MaxDate) Then

            If MinDateInclusive And MaxDateInclusive Then

                If Date.Compare(CDate(dateStr), CDate(MinDate)) >= 0 AndAlso Date.Compare(CDate(dateStr), CDate(MaxDate)) <= 0 Then valid= True

            ElseIf MinDateInclusive And Not MaxDateInclusive Then

                If Date.Compare(CDate(dateStr), CDate(MinDate)) >= 0 AndAlso Date.Compare(CDate(dateStr), CDate(MaxDate)) < 0 Then valid = True

            ElseIf Not MinDateInclusive And MaxDateInclusive Then

                If Date.Compare(CDate(dateStr), CDate(MinDate)) > 0 AndAlso Date.Compare(CDate(dateStr), CDate(MaxDate)) <= 0 Then valid = True

            ElseIf Not MinDateInclusive And Not MaxDateInclusive Then

                If Date.Compare(CDate(dateStr), CDate(MinDate)) > 0 AndAlso Date.Compare(CDate(dateStr), CDate(MaxDate)) < 0 Then valid = True

            End If

        End If

        Return valid

    End Function

    Public Shared Function ValidateUPC(ByVal upc As String) As Boolean

        If upc Is Nothing OrElse upc.Trim.Length = 0 OrElse Not IsNumeric(upc) Then
            Return False
        End If

        'Code lifted from original VMD and slighted modded to be .NET compliant
        Dim upcDigit(), intNumber, i As Integer
        Dim result As Boolean

        If CDbl(upc) = 0 Then
            Return True
        End If

        upc = Right(("00000000000000" & Trim(upc)), 14)

        ReDim upcDigit(13)
        For i = 0 To 13
            upcDigit(i) = CInt(Mid(upc, i + 1, 1))
        Next
        intNumber = (upcDigit(0) + upcDigit(2) + upcDigit(4) + upcDigit(6) + upcDigit(8) + upcDigit(10) + upcDigit(12)) * 3
        intNumber = intNumber + upcDigit(1) + upcDigit(3) + upcDigit(5) + upcDigit(7) + upcDigit(9) + upcDigit(11)
        If upcDigit(13) = 10 - CInt(Right(CStr(intNumber), 1)) Then
            result = True
        ElseIf upcDigit(13) = 0 And CInt(Right(CStr(intNumber), 1)) = 0 Then
            result = True
        Else
            result = False
        End If

        'System already contains 13 and 14 digit UPCs, so more analysis needed
        ''Michaels can't handle UPCs greater than 12 digits, so first 2 digits must be 0
        'If upcDigit(0) > 0 Or upcDigit(1) > 0 Then
        '    result = False
        'End If

        Return result

    End Function

    Public Shared Function ValidateGTIN(ByVal gtin As String) As Boolean

        If gtin Is Nothing OrElse gtin.Trim.Length = 0 OrElse Not IsNumeric(gtin) OrElse gtin = "00000000000000" Then
            Return False
        End If

        'Code lifted from original VMD and slighted modded to be .NET compliant
        Dim gtinDigit(), intNumber, i As Integer
        Dim result As Boolean

        If CDbl(gtin) = 0 Then
            Return True
        End If

        ReDim gtinDigit(13)
        For i = 0 To 13
            gtinDigit(i) = CInt(Mid(gtin, i + 1, 1))
        Next
        intNumber = (gtinDigit(0) + gtinDigit(2) + gtinDigit(4) + gtinDigit(6) + gtinDigit(8) + gtinDigit(10) + gtinDigit(12)) * 3
        intNumber = intNumber + gtinDigit(1) + gtinDigit(3) + gtinDigit(5) + gtinDigit(7) + gtinDigit(9) + gtinDigit(11)

        If gtinDigit(13) = 10 - CInt(Right(CStr(intNumber), 1)) Then
            result = True
        ElseIf gtinDigit(13) = 0 And CInt(Right(CStr(intNumber), 1)) = 0 Then
            result = True
        Else
            result = False
        End If

        Return result

    End Function


    Public Shared Function AreAllEmpty(ByVal ParamArray values() As Object) As Boolean
        For Each field As Object In values
            If Not IsEmpty(field) Then
                Return False
            End If
        Next
        Return True
    End Function

    Public Shared Function IsEmpty(ByVal ParamArray values() As Object) As Boolean
        For Each field As Object In values
            If IsEmpty(field) Then
                Return True
            End If
        Next
        Return False
    End Function

    Public Shared Function IsEmpty(ByVal field As Object) As Boolean
        If TypeOf field Is Integer Then
            Return (CType(field, Integer) = Integer.MinValue)
        ElseIf TypeOf field Is Long Then
            Return (CType(field, Long) = Long.MinValue)
        ElseIf TypeOf field Is Decimal Then
            Return (CType(field, Decimal) = Decimal.MinValue)
        ElseIf TypeOf field Is Date Then
            Return (CType(field, Date) = Date.MinValue)
        ElseIf TypeOf field Is Boolean Then
            Return (IsDBNull(field))
        ElseIf TypeOf field Is Byte Then
            Return (CType(field, Byte) = Byte.MinValue)
        ElseIf TypeOf field Is Char Then
            Return (CType(field, Char) = Char.MinValue)
        ElseIf TypeOf field Is Single Then
            Return (CType(field, Single) = Single.MinValue)
        ElseIf TypeOf field Is Double Then
            Return (CType(field, Double) = Double.MinValue)
        ElseIf TypeOf field Is String Then
            Return (field.ToString().Trim() = String.Empty)
        ElseIf field Is Nothing Then
            Return True
        Else
            Return (field.ToString().Trim() = String.Empty)
        End If
    End Function

    Public Shared Function IsError(ByVal field As Object) As Boolean
        If TypeOf field Is Integer Then
            Return (CType(field, Integer) = Integer.MaxValue)
        ElseIf TypeOf field Is Long Then
            Return (CType(field, Long) = Long.MaxValue)
        ElseIf TypeOf field Is Decimal Then
            Return (CType(field, Decimal) = Decimal.MaxValue)
        ElseIf TypeOf field Is Date Then
            Return (CType(field, Date) = Date.MaxValue)
        ElseIf TypeOf field Is Boolean Then
            Return (IsDBNull(field))
        ElseIf TypeOf field Is Byte Then
            Return (CType(field, Byte) = Byte.MaxValue)
        ElseIf TypeOf field Is Char Then
            Return (CType(field, Char) = Char.MaxValue)
        ElseIf TypeOf field Is Single Then
            Return (CType(field, Single) = Single.MaxValue)
        ElseIf TypeOf field Is Double Then
            Return (CType(field, Double) = Double.MaxValue)
        Else
            Return (field.ToString().Trim() = String.Empty)
        End If
    End Function

    Public Shared Function IsValidRange(ByVal field As Object, ByVal minValue As Object, ByVal maxValue As Object, ByVal inclusive As Boolean) As Boolean
        If IsEmpty(field) Then
            Return False
        Else
            If inclusive Then
                Return (field >= minValue And field <= maxValue)
            Else
                Return (field > minValue And field < maxValue)
            End If
        End If
    End Function

    Public Shared Function IsDateToday(ByVal field As Date) As Boolean
        Dim dateNow As Date = Now()
        If field.Month = dateNow.Month AndAlso field.Day = dateNow.Day AndAlso field.Year = dateNow.Year Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function IsValidDomesticVendor(ByVal vendorNumber As Integer) As Boolean
        Dim isValid As Boolean
        Dim objM As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
        Dim vendor As Models.VendorRecord = objM.GetVendorRecord(vendorNumber)
        objM = Nothing
        isValid = IsValidDomesticVendor(vendor)
        vendor = Nothing
        Return isValid
    End Function

    Public Shared Function IsValidImportVendor(ByVal vendorNumber As Integer) As Boolean
        Dim isValid As Boolean
        Dim objM As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
        Dim vendor As Models.VendorRecord = objM.GetVendorRecord(vendorNumber)
        objM = Nothing
        isValid = IsValidImportVendor(vendor)
        vendor = Nothing
        Return isValid
    End Function

    Public Shared Function IsValidDomesticVendor(ByRef vendorRecord As Models.VendorRecord) As Boolean
        Return IsValidVendor(vendorRecord, Models.BatchType.Domestic)
    End Function

    Public Shared Function IsValidImportVendor(ByRef vendorRecord As Models.VendorRecord) As Boolean
        Return IsValidVendor(vendorRecord, Models.BatchType.Import)
    End Function

    Public Shared Function IsValidVendor(ByRef vendorRecord As Models.VendorRecord, ByVal batchType As Models.BatchType) As Boolean
        If vendorRecord Is Nothing OrElse (Not vendorRecord Is Nothing AndAlso vendorRecord.ID <= 0) Then
            Return False
        End If
        If batchType = Models.BatchType.Import Then
            ' import
            If StringFoundInSearchStringArray(vendorRecord.VendorType.Trim(), VALIDATION_VENDOR_IMPORT_TYPES) Then
                Return True
            Else
                Return False
            End If
        Else
            ' domestic
            If StringFoundInSearchStringArray(vendorRecord.VendorType.Trim(), VALIDATION_VENDOR_DOMESTIC_TYPES) Then
                Return True
            Else
                Return False
            End If
        End If
    End Function

    ' PRIVATE METHODS

    Private Shared Function BuildVendorTypeList(ByVal batchType As Models.BatchType) As String
        Dim arr() As String
        If batchType = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import Then
            arr = Split(VALIDATION_VENDOR_IMPORT_TYPES, ",")
        Else
            arr = Split(VALIDATION_VENDOR_DOMESTIC_TYPES, ",")
        End If
        Dim ret As String = String.Empty
        For i As Integer = 0 To arr.Length - 1
            If ret <> String.Empty Then ret += ", "
            ret += "'" & arr(i).Trim() & "'"
        Next
        Return ret
    End Function

    Public Shared Function StringFoundInSearchStringArray(ByVal value As String, ByVal searchString As String) As Boolean
        Return StringFoundInSearchStringArray(value, searchString, ",")
    End Function
    Public Shared Function StringFoundInSearchStringArray(ByVal value As String, ByVal searchString As String, ByVal delimiter As String) As Boolean
        Dim arr() As String = Split(searchString, delimiter)
        Dim ret As Boolean = False
        For i As Integer = 0 To arr.Length - 1
            If arr(i).Trim() = value.Trim() Then
                ret = True
                Exit For
            End If
        Next
        Return ret
    End Function

    Public Shared Function IsAlphaOrNumeric(ByVal checkString As String) As Boolean
        Return IsAlphaOrNumeric(checkString, String.Empty)
    End Function

    Public Shared Function IsAlphaOrNumeric(ByVal checkString As String, ByVal validCharacters As String) As Boolean
        Dim isValid As Boolean = True
        Dim charArr As Char()
        If checkString.Length > 0 Then
            charArr = checkString.ToCharArray()
            For Each c As Char In charArr
                ' check if alpha or numeric
                If Not IsAlpha(c) And Not IsNumeric(c) Then
                    ' check for valid characters
                    If validCharacters.Length = 0 OrElse validCharacters.IndexOf(c) < 0 Then
                        isValid = False
                        Exit For
                    End If
                End If
            Next
        End If
        Return isValid
    End Function


    Public Shared Function IsNumeric(ByVal checkString As String) As Boolean
        Return IsNumeric(checkString, String.Empty)
    End Function

    Public Shared Function IsNumeric(ByVal checkString As String, ByVal validCharacters As String) As Boolean
        Dim isValid As Boolean = True
        Dim charArr As Char()
        If checkString.Length > 0 Then
            charArr = checkString.ToCharArray()
            For Each c As Char In charArr
                If Not IsNumeric(c) Then
                    ' check for valid characters
                    If validCharacters.Length = 0 OrElse validCharacters.IndexOf(c) < 0 Then
                        isValid = False
                        Exit For
                    End If
                End If
            Next
        End If
        Return isValid
    End Function

    Public Shared Function IsNumeric(ByVal c As Char) As Boolean
        Dim charVal As Int16 = Convert.ToInt16(c)
        If charVal < 48 Or charVal > 57 Then
            Return False
        Else
            Return True
        End If
    End Function

    Public Shared Function IsAlpha(ByVal checkString As String) As Boolean
        Return IsAlpha(checkString, String.Empty)
    End Function

    Public Shared Function IsAlpha(ByVal checkString As String, ByVal validCharacters As String) As Boolean
        Dim isValid As Boolean = True
        Dim charArr As Char()
        If checkString.Length > 0 Then
            charArr = checkString.ToCharArray()
            For Each c As Char In charArr
                If Not IsAlpha(c) Then
                    ' check for valid characters
                    If validCharacters.Length = 0 OrElse validCharacters.IndexOf(c) < 0 Then
                        isValid = False
                        Exit For
                    End If
                End If
            Next
        End If
        Return isValid
    End Function

    Public Shared Function IsAlpha(ByVal c As Char) As Boolean
        Dim charVal As Int16 = Convert.ToInt16(c)
        If charVal < 65 Or (charVal > 90 And charVal < 97) Or charVal > 122 Then
            Return False
        Else
            Return True
        End If
    End Function

    Private Shared Function StringContainsOnly(ByVal checkstring As String, ByVal validCharacters As String) As Boolean
        Dim isValid As Boolean = True
        Dim charArr As Char()
        If checkstring.Length > 0 Then
            charArr = checkstring.ToCharArray()
            For Each c As Char In charArr
                If validCharacters.IndexOf(c) < 0 Then
                    isValid = False
                    Exit For
                End If
            Next
        End If
        Return isValid
    End Function

    Private Shared Function StringDoesNotContain(ByVal checkstring As String, ByVal invalidCharacters As String) As Boolean
        Dim isValid As Boolean = True
        Dim charArr As Char()
        If checkstring.Length > 0 Then
            charArr = checkstring.ToCharArray()
            For Each c As Char In charArr
                If invalidCharacters.IndexOf(c) >= 0 Then
                    isValid = False
                    Exit For
                End If
            Next
        End If
        Return isValid
    End Function

    Private Shared Function IsDivisibleBy(ByVal numToDivide As Decimal, ByVal numToDivideBy As Decimal) As Boolean
        If numToDivideBy = 0 Then
            Return False
        Else
            If (numToDivide Mod numToDivideBy) = 0 Then
                Return True
            Else
                Return False
            End If
        End If
    End Function

#End Region


    Public Enum ValidationDisplay
        Unknown = 0
        UnknownSmall
        NotValid
        NotValidSmall
        Valid
        ValidSmall
    End Enum


End Class
