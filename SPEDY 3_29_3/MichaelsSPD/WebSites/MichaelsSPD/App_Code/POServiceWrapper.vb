Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports System.Collections.Generic
Imports NovaLibra.Coral.Data
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels
Imports DataHelper = NovaLibra.Common.Utilities.DataHelper


Public Class POServiceWrapper

    Public Shared Function GetSKUValidation(ByRef poRecord As Models.POCreationRecord) As String

        Dim currentSKU As Models.POCreationLocationSKURecord
        Dim skuDict As New Dictionary(Of String, Models.POCreationLocationSKURecord)

        Dim isDetailValid As Boolean = True
        Dim storeList As New ArrayList
        Dim jobStatus As String = "E"
        Dim isProcessing As Boolean = False

        Try

            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "string", False) Then

                Dim validationResults As New getValidationResultArg0
                validationResults.referenceId = poRecord.BatchNumber
                validationResults.method = "GETRESULT"
                validationResults.type = "ITEMLOC"

                validationResults.jobObj = New jobObjType
                validationResults.jobObj.jobId = poRecord.ValidatingJobID

                Dim service As New POService
                Dim results As New getValidationResultResponseReturn
                results = service.getValidationResult(validationResults)

                If (results.jobObj IsNot Nothing) Then
                    'Check to see if the PO is being Processed already
                    isProcessing = Data.POCreationData.GetIsPOProcessing(poRecord.ID)
                    'Check to see if the PO Validation is Complete
                    If results.jobObj.jobStatus = "C" AndAlso (Not isProcessing) Then
                        jobStatus = results.jobObj.jobStatus

                        'Set PO as Processing
                        Data.POCreationData.UpdatePOProcessing(poRecord.ID, True)

                        'Construct Bulk Insert Table
                        Dim validationMessageTable As DataTable = New DataTable
                        validationMessageTable.Columns.Add("ID", GetType(Int64))
                        validationMessageTable.Columns.Add("PO_Creation_ID", GetType(Int64))
                        validationMessageTable.Columns.Add("Michaels_SKU", GetType(String))
                        validationMessageTable.Columns.Add("Store_Number", GetType(Int32))
                        validationMessageTable.Columns.Add("Message", GetType(String))
                        validationMessageTable.Columns.Add("Severity_Type", GetType(Int32))
                        validationMessageTable.Columns.Add("Date_Received", GetType(DateTime))

                        If (results.itemTab IsNot Nothing) Then
                            'Get the SKU Errors and Warnings
                            For j As Integer = 0 To results.itemTab.Length - 1

                                'Set Current SKU
                                currentSKU = New Models.POCreationLocationSKURecord
                                currentSKU.MichaelsSKU = results.itemTab(j).item
                                currentSKU.IsWSValid = True
                                If results.itemTab(j).upcTab IsNot Nothing Then
                                    currentSKU.DefaultUPC = results.itemTab(j).upcTab(0).upc.Trim()
                                End If

                                If (results.itemTab(j).errorTab IsNot Nothing) Then
                                    'Retrieve any SKU Errors on the itemTab
                                    For k As Integer = 0 To results.itemTab(j).errorTab.Length - 1
                                        validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError, DateTime.Now)
                                        'Data.POCreationData.SaveValidationMessage(poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                                        currentSKU.IsWSValid = False
                                        isDetailValid = False
                                    Next
                                End If

                                If (results.itemTab(j).warningTab IsNot Nothing) Then
                                    'Retrieve any SKU Warnings on the itemTab
                                    For k As Integer = 0 To results.itemTab(j).warningTab.Length - 1
                                        validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning, DateTime.Now)
                                        'Data.POCreationData.SaveValidationMessage(poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                    Next
                                End If

                                'Add This SKU To Our Sku List
                                skuDict.Add(currentSKU.MichaelsSKU, currentSKU)

                            Next
                        End If

                        If (results.itemLocTab IsNot Nothing) Then
                            'Get the SKU Store/Location Errors and Warnings
                            For n As Integer = 0 To results.itemLocTab.Length - 1
                                'Create Store Record
                                Dim store As New Models.POCreationSKUStoreRecord
                                store.POCreationID = poRecord.ID
                                store.MichaelsSKU = results.itemLocTab(n).item
                                store.StoreNumber = results.itemLocTab(n).location
                                store.OrderedQty = results.itemLocTab(n).quantity
                                store.StoreName = results.itemLocTab(n).locDesc
                                store.Zone = results.itemLocTab(n).countryId
                                store.POLocationID = GetLocationIDByConstant(results.itemLocTab(n).countryId)
                                store.IsValid = True    'Default store validity to True
                                store.LandedCost = results.itemLocTab(n).landedCost
                                store.OrderRetail = results.itemLocTab(n).unitRetail

                                'RULE: IF this is a Warehouse order, update the LandedCost/OrderRetail for the SKU/Location combo.  
                                'For Direct orders this information is saved with the Store
                                If (poRecord.BatchType = "W") Then
                                    Data.POCreationLocationSKUData.UpdateAllocTotals(poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, DataHelper.SmartValues(results.itemLocTab(n).landedCost, "decimal", False, 0), DataHelper.SmartValues(results.itemLocTab(n).unitRetail, "decimal", False, 0))
                                End If

                                If (results.itemLocTab(n).errorTab IsNot Nothing) Then
                                    'Retrieve any Location Errors on the itemLocTab
                                    For k As Integer = 0 To results.itemLocTab(n).errorTab.Length - 1
                                        validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError, DateTime.Now)
                                        'Data.POCreationData.SaveValidationMessage(poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                                        'IF this is a Direct order, set the store isValid flag to false.
                                        If (poRecord.BatchType = "D") Then
                                            store.IsValid = False
                                        End If
                                        'Update SKU As Invalid
                                        If skuDict.ContainsKey(results.itemLocTab(n).item) Then
                                            currentSKU = skuDict.Item(results.itemLocTab(n).item)
                                            currentSKU.IsWSValid = False
                                            skuDict.Item(results.itemLocTab(n).item) = currentSKU
                                        End If
                                        isDetailValid = False
                                    Next
                                End If

                                If (results.itemLocTab(n).warningTab IsNot Nothing) Then
                                    'Retrieve any Location Warnings on the itemLocTab
                                    For k As Integer = 0 To results.itemLocTab(n).warningTab.Length - 1
                                        validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning, DateTime.Now)
                                        'Data.POCreationData.SaveValidationMessage(poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                    Next
                                End If

                                'Add Stores
                                storeList.Add(store)
                            Next
                        End If

                        'Store Validation Messages
                        If (validationMessageTable.Rows.Count > 0) Then
                            Data.POCreationData.SaveValidationMessages(validationMessageTable)
                        End If

                        If (poRecord.BatchType = "D") Then
                            'Make sure batch table is clean
                            Data.POCreationSKUStoreData.DeleteBatchSKUs(poRecord.ID)
                            'Insert Stores into Batch Table
                            Data.POCreationSKUStoreData.BatchUpdateSKUStores(storeList)
                            'Merge Batch table with Live table
                            Data.POCreationSKUStoreData.MergeBatchSKUs(poRecord.ID)
                        End If

                        'Set the IsWSValid flag based on presence of SKU in invalidSKU list, and update the database
                        Dim skuList As List(Of Models.POCreationLocationSKURecord) = Data.POCreationLocationSKUData.GetSKUsByPOID(poRecord.ID)
                        For Each sku As Models.POCreationLocationSKURecord In skuList

                            If skuDict.ContainsKey(sku.MichaelsSKU) Then

                                'Set Values
                                sku.DefaultUPC = skuDict.Item(sku.MichaelsSKU).DefaultUPC
                                sku.IsWSValid = skuDict.Item(sku.MichaelsSKU).IsWSValid

                                'Update SKU
                                Data.POCreationLocationSKUData.UpdateSKUsByPOID(poRecord.ID, sku)

                                'Update Totals For This SKU
                                If poRecord.BatchType = "D" Then
                                    Data.POCreationSKUStoreData.UpdateSKUTotals(poRecord.ID, sku.MichaelsSKU)
                                    Data.POCreationSKUStoreData.UpdateSKUCacheTotals(poRecord.ID, sku.MichaelsSKU, AppHelper.GetUserID())
                                End If

                            End If

                        Next

                        'Update the PO Record in the database with the results
                        poRecord.IsDetailValid = isDetailValid
                        poRecord.IsValidating = False
                        poRecord.ValidatingJobID = Nothing
                        Data.POCreationData.UpdateRecordBySystem(poRecord, Michaels.POCreationData.Hydrate.All)

                        'Set PO as NOT Processing
                        Data.POCreationData.UpdatePOProcessing(poRecord.ID, False)
                    Else
                        'Get job status if there is one
                        If (results.jobObj.jobStatus IsNot Nothing) Then
                            jobStatus = results.jobObj.jobStatus
                        End If

                        If (results.jobObj.errorMesg IsNot Nothing) Then
                            Dim bex As New Exception("Error calling PO Val Server: " + results.jobObj.errorMesg)
                            NovaLibra.Common.Logger.LogError(bex)
                            Throw New Exception("There was a problem retrieving the validation results for this Purchase Order.  Please try again later.  If this problem persist, please contact support")
                        End If
                    End If
                End If
            Else
                jobStatus = "WebServices Disabled"
            End If

        Catch ex As Exception
            'Set PO as NOT Processing
            Data.POCreationData.UpdatePOProcessing(poRecord.ID, False)

            Throw ex
        End Try

        Return jobStatus
    End Function

    Public Shared Function GetSKUValidation(ByVal poRecord As Models.POMaintenanceRecord) As String

        Dim currentSKU As Models.POMaintenanceSKURecord
        Dim skuDict As New Dictionary(Of String, Models.POMaintenanceSKURecord)

        Dim isDetailValid As Boolean = True
        Dim storeList As New ArrayList
        Dim jobStatus As String = "E"
        Dim isProcessing As Boolean = False

        Try
            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "string", False) Then

                Dim validationResults As New getValidationResultArg0
                validationResults.referenceId = poRecord.PONumber   'USE PO Number for Maintenance, since the ReferenceId has to be unique
                validationResults.method = "GETRESULT"
                validationResults.type = "ITEMLOC"

                validationResults.jobObj = New jobObjType
                validationResults.jobObj.jobId = poRecord.ValidatingJobID

                Dim service As New POService
                Dim results As New getValidationResultResponseReturn
                results = service.getValidationResult(validationResults)

                If (results.jobObj IsNot Nothing) Then
                    'Check to see if the PO is being Processed already
                    isProcessing = Data.POMaintenanceData.GetIsPOProcessing(poRecord.ID)
                    'Check to see if the PO Validation is Complete
                    If results.jobObj.jobStatus = "C" AndAlso (Not isProcessing) Then
                        jobStatus = results.jobObj.jobStatus

                        'Set PO as Processing
                        Data.POMaintenanceData.UpdatePOProcessing(poRecord.ID, True)

                        'Construct Bulk Insert Table
                        Dim validationMessageTable As DataTable = New DataTable
                        validationMessageTable.Columns.Add("ID", GetType(Int64))
                        validationMessageTable.Columns.Add("PO_Maintenance_ID", GetType(Int64))
                        validationMessageTable.Columns.Add("Michaels_SKU", GetType(String))
                        validationMessageTable.Columns.Add("Store_Number", GetType(Int32))
                        validationMessageTable.Columns.Add("Message", GetType(String))
                        validationMessageTable.Columns.Add("Severity_Type", GetType(Int32))
                        validationMessageTable.Columns.Add("Date_Received", GetType(DateTime))

                        'Get the SKU Errors and Warnings
                        For j As Integer = 0 To results.itemTab.Length - 1

                            'Set Current SKU
                            currentSKU = New Models.POMaintenanceSKURecord
                            currentSKU.MichaelsSKU = results.itemTab(j).item
                            currentSKU.IsWSValid = True
                            If (results.itemTab(j).upcTab) IsNot Nothing Then
                                currentSKU.DefaultUPC = results.itemTab(j).upcTab(0).upc.Trim()
                            End If

                            If (results.itemTab(j).errorTab IsNot Nothing) Then
                                'Retrieve any SKU Errors on the itemTab
                                For k As Integer = 0 To results.itemTab(j).errorTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError, DateTime.Now)
                                    'Data.POMaintenanceData.SaveValidationMessage(poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                                    currentSKU.IsWSValid = False
                                    isDetailValid = False
                                Next
                            End If

                            If (results.itemTab(j).warningTab IsNot Nothing) Then
                                'Retrieve any SKU Warnings on the itemTab
                                For k As Integer = 0 To results.itemTab(j).warningTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning, DateTime.Now)
                                    'Data.POMaintenanceData.SaveValidationMessage(poRecord.ID, results.itemTab(j).item, Nothing, results.itemTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                Next
                            End If

                            'Add This SKU To Our Sku List
                            skuDict.Add(currentSKU.MichaelsSKU, currentSKU)

                        Next

                        'Get the SKU Store/Location Errors and Warnings
                        For n As Integer = 0 To results.itemLocTab.Length - 1
                            Dim store As New Models.POMaintenanceSKUStoreRecord
                            store.Zone = results.itemLocTab(n).countryId
                            store.POMaintenanceID = poRecord.ID
                            store.POLocationID = poRecord.POLocationID
                            store.StoreNumber = results.itemLocTab(n).location
                            store.StoreName = results.itemLocTab(n).locDesc
                            store.MichaelsSKU = results.itemLocTab(n).item
                            store.IsValid = True    'Default as True
                            store.LandedCost = results.itemLocTab(n).landedCost
                            store.OrderRetail = results.itemLocTab(n).unitRetail

                            'RULE: IF this is a Warehouse order, update the LandedCost/OrderRetail for the SKU/Location combo.  
                            'For Direct orders this information is saved with the Store
                            If (poRecord.BatchType = "W") Then
                                Data.POMaintenanceSKUData.UpdateAllocTotals(poRecord.ID, results.itemLocTab(n).item, DataHelper.SmartValues(results.itemLocTab(n).landedCost, "decimal", False, 0), DataHelper.SmartValues(results.itemLocTab(n).unitRetail, "decimal", False, 0))
                            End If

                            If (results.itemLocTab(n).errorTab IsNot Nothing) Then
                                'Retrieve any Location Errors on the itemLocTab
                                For k As Integer = 0 To results.itemLocTab(n).errorTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                                    'Data.POMaintenanceData.SaveValidationMessage(poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                                    'IF this is a Direct order, add the store that is invalid
                                    If (poRecord.BatchType = "D") Then
                                        store.IsValid = False
                                    End If
                                    'Update SKU As Invalid
                                    If skuDict.ContainsKey(results.itemLocTab(n).item) Then
                                        currentSKU = skuDict.Item(results.itemLocTab(n).item)
                                        currentSKU.IsWSValid = False
                                        skuDict.Item(results.itemLocTab(n).item) = currentSKU
                                    End If
                                    isDetailValid = False
                                Next
                            End If

                            If (results.itemLocTab(n).warningTab IsNot Nothing) Then
                                'Retrieve any Location Warnings on the itemLocTab
                                For k As Integer = 0 To results.itemLocTab(n).warningTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning, DateTime.Now)
                                    'Data.POMaintenanceData.SaveValidationMessage(poRecord.ID, results.itemLocTab(n).item, results.itemLocTab(n).location, results.itemLocTab(n).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                Next
                            End If

                            storeList.Add(store)
                        Next

                        If (validationMessageTable.Rows.Count > 0) Then
                            Data.POMaintenanceData.SaveValidationMessages(validationMessageTable)
                        End If

                        'Update the Store if this is a Direct order
                        If (poRecord.BatchType = "D") Then
                            'Make sure batch table is clean
                            Data.POMaintenanceSKUStoreData.DeleteBatchSKUs(poRecord.ID)
                            'Insert Stores into Batch Table
                            Data.POMaintenanceSKUStoreData.BatchUpdateSKUStores(storeList)
                            'Merge Batch table with Live table
                            Data.POMaintenanceSKUStoreData.MergeBatchSKUs(poRecord.ID)
                        End If

                        'Set the IsWSValid flag based on presence of SKU in invalidSKU list, and update the database
                        Dim skuList As List(Of Models.POMaintenanceSKURecord) = Data.POMaintenanceSKUData.GetSKUsByPOID(poRecord.ID)
                        For Each sku As Models.POMaintenanceSKURecord In skuList

                            If skuDict.ContainsKey(sku.MichaelsSKU) Then

                                'Update SKU Default UPC
                                '2011-11-09 added final 'and' clause to prevent empty UPC from trying to overwrite SPEDY, which fails anyway
                                If DataHelper.SmartValue(sku.DefaultUPC, "CStr", "") <> DataHelper.SmartValue(skuDict.Item(sku.MichaelsSKU).DefaultUPC, "CStr", "") And DataHelper.SmartValue(skuDict.Item(sku.MichaelsSKU).DefaultUPC, "CStr", "") <> "" Then
                                    Data.POMaintenanceSKUData.UpdateSKUDefaultUPC(sku.POMaintenanceID, sku.MichaelsSKU, skuDict.Item(sku.MichaelsSKU).DefaultUPC)
                                End If

                                'Update Validity
                                sku.IsWSValid = skuDict.Item(sku.MichaelsSKU).IsWSValid
                                Data.POMaintenanceSKUData.UpdateValidity(sku.POMaintenanceID, sku.MichaelsSKU, sku.IsValid, sku.IsWSValid)

                                'Update Totals For This SKU
                                If poRecord.BatchType = "D" Then
                                    Data.POMaintenanceSKUStoreData.UpdateSKUTotals(poRecord.ID, sku.MichaelsSKU)
                                End If

                            End If

                        Next

                        'Update the PO Record in the database with the results
                        poRecord.IsDetailValid = isDetailValid
                        poRecord.IsValidating = False
                        poRecord.ValidatingJobID = Nothing
                        Data.POMaintenanceData.UpdateRecordBySystem(poRecord, Michaels.POMaintenanceData.Hydrate.None)

                        'Set PO as NOT Processing
                        Data.POMaintenanceData.UpdatePOProcessing(poRecord.ID, False)
                    Else
                        'Get job status if there is one
                        If (results.jobObj.jobStatus IsNot Nothing) Then
                            jobStatus = results.jobObj.jobStatus
                        End If
                        If (results.jobObj.errorMesg IsNot Nothing) Then
                            Dim bex As New Exception("Error calling PO Val Server: " + results.jobObj.errorMesg)
                            NovaLibra.Common.Logger.LogError(bex)
                            Throw New Exception("There was a problem retrieving the validation results for this Purchase Order.  Please try again later.  If this problem persist, please contact support")
                        End If
                    End If
                End If
            Else
                jobStatus = "WebServices Disabled"
            End If

        Catch ex As Exception
            'Set PO as NOT Processing
            Data.POMaintenanceData.UpdatePOProcessing(poRecord.ID, False)

            Throw ex
        End Try

        Return jobStatus
    End Function

    Public Shared Sub SubmitSKUValidation(ByVal poRecord As Models.POCreationRecord)

        'Make sure there is at least one SKU and Date before submitting validation requests
        Dim hasASKU As Boolean = False

        Try
            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "string", False) Then

                'Create the ValidationItem
                Dim validationItem As New submitValidationArg0
                validationItem.referenceId = poRecord.BatchNumber
                validationItem.orderType = poRecord.BatchType
                validationItem.supplier = poRecord.VendorNumber
                validationItem.eventType = poRecord.BasicSeasonal
                validationItem.supplierSpecified = True
                validationItem.method = "SUBMIT"
                validationItem.type = "ITEMLOC"

                'CustomerOrder Flag setting
                If (poRecord.POSpecialID = WebConstants.POSPECIAL_CUSTOMERORDER) Then
                    validationItem.customerOrder = "Y"
                Else
                    validationItem.customerOrder = "N"
                End If

                validationItem.allowSeasonalItemsBasicDC = "N"

                If poRecord.AllowSeasonalItemsBasicDC.HasValue Then
                    If poRecord.AllowSeasonalItemsBasicDC Then
                        validationItem.allowSeasonalItemsBasicDC = "Y"
                    End If
                End If

                'Only populate the EventYear if there is one
                If (poRecord.EventYear.HasValue) Then
                    validationItem.year = poRecord.EventYear
                    validationItem.yearSpecified = True
                End If

                'Get the Allocation Event ID, if the PO Has an allocation event specified
                If poRecord.POAllocationEventID.HasValue Then
                    validationItem.allocEvent = GetAllocationEventID(poRecord.POAllocationEventID)
                Else
                    validationItem.allocEvent = ""
                End If

                If poRecord.ShipPointCode IsNot Nothing Then
                    validationItem.shipPoint = poRecord.ShipPointCode
                Else
                    validationItem.shipPoint = DataHelper.SmartValuesDBNull(poRecord.ShipPointDescription, True)
                End If

                '********************************
                '*     ADD Location Dates       *
                '********************************
                Dim locationDateList As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsCacheByPOID(poRecord.ID, AppHelper.GetUserID())
                validationItem.dateTab = New dateObjType(locationDateList.Count - 1) {} 'Yes, this is weird... just go with it
                For i As Integer = 0 To locationDateList.Count - 1
                    'Create new dateObjType
                    validationItem.dateTab(i) = New dateObjType
                    'If this is a Warehouse order, populate Location.  Else populate CountryId
                    If (poRecord.BatchType = "W") Then
                        validationItem.dateTab(i).location = locationDateList(i).LocationConstant
                        validationItem.dateTab(i).locationSpecified = True
                    Else
                        validationItem.dateTab(i).countryId = locationDateList(i).LocationConstant
                    End If

                    'Populate Date fields on validationItem
                    If (locationDateList(i).WrittenDate.HasValue) Then
                        validationItem.dateTab(i).writtenDate = GetDateWithFormat(locationDateList(i).WrittenDate)
                        validationItem.dateTab(i).writtenDateSpecified = True
                    End If


                    If (locationDateList(i).NotBefore.HasValue) Then
                        validationItem.dateTab(i).notBeforeDate = GetDateWithFormat(locationDateList(i).NotBefore)
                        validationItem.dateTab(i).notBeforeDateSpecified = True
                    End If
                    If (locationDateList(i).NotAfter.HasValue) Then
                        validationItem.dateTab(i).notAfterDate = GetDateWithFormat(locationDateList(i).NotAfter)
                        validationItem.dateTab(i).notAfterDateSpecified = True
                    End If
                    If (locationDateList(i).EstimatedInStockDate.HasValue) Then
                        validationItem.dateTab(i).inStockDate = GetDateWithFormat(locationDateList(i).EstimatedInStockDate)
                        validationItem.dateTab(i).inStockDateSpecified = True
                    End If
                Next


                '***************************
                '*     ADD SKUs            *
                '***************************
                Dim skuList As List(Of Models.POCreationLocationSKURecord) = Data.POCreationLocationSKUData.GetSKUsByPOID(poRecord.ID)
                validationItem.itemTab = New itemObjType(skuList.Count - 1) {}  'Yes, this is weird... just go with it
                For i As Integer = 0 To skuList.Count - 1
                    'Makes sure there is at least one SKU on the Validation request
                    hasASKU = True

                    validationItem.itemTab(i) = New itemObjType
                    validationItem.itemTab(i).item = skuList(i).MichaelsSKU
                    validationItem.itemTab(i).spedyUnitcost = skuList(i).UnitCost.ToString
                    validationItem.itemTab(i).spedyUnitcostSpecified = True
                    validationItem.itemTab(i).spedyInnerPackSize = skuList(i).InnerPack.ToString
                    validationItem.itemTab(i).spedyInnerPackSizeSpecified = True
                    validationItem.itemTab(i).spedySuppPackSize = skuList(i).MasterPack.ToString
                    validationItem.itemTab(i).spedySuppPackSizeSpecified = True

                    'Delete Validation Messages for this PO and SKU (New messages will be saved after validation is complete)
                    Data.POCreationData.DeleteValidationMessages(poRecord.ID, skuList(i).MichaelsSKU)
                Next

                '************************************
                '*     ADD SKU Locations            *
                '************************************
                Dim skuStoreList As New List(Of Models.POCreationSKUStoreRecord)
                'For Warehouse Orders, get List of Locations, and create "Store" list using warehouse LocationConstant
                If (poRecord.BatchType = "W") Then
                    Dim locationList As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsCacheByPOID(poRecord.ID, AppHelper.GetUserID())
                    For Each location As Models.POCreationLocationRecord In locationList
                        Dim skuLocationList As List(Of Models.POCreationLocationSKURecord) = Data.POCreationLocationSKUData.GetSKULocationsByPCLID(location.ID)
                        For Each sku As Models.POCreationLocationSKURecord In skuLocationList
                            Dim skuLocation As New Models.POCreationSKUStoreRecord
                            skuLocation.MichaelsSKU = sku.MichaelsSKU
                            skuLocation.OrderedQty = sku.LocationTotalQty
                            skuLocation.POLocationID = location.LocationConstant
                            skuLocation.StoreNumber = location.LocationConstant 'Use LocationConstant as StoreNumber for Warehouse orders
                            skuLocation.POCreationID = poRecord.ID

                            'Only add the SKU Location if the Location Qty > 0
                            If (sku.LocationTotalQty > 0) Then
                                skuStoreList.Add(skuLocation)
                            End If
                        Next
                    Next
                End If
                'For Direct Orders, get the Store List associated with the PO
                If (poRecord.BatchType = "D") Then
                    Dim storeList As ArrayList = Data.POCreationSKUStoreData.GetByPOID(poRecord.ID)
                    For Each store As Models.POCreationSKUStoreRecord In storeList
                        skuStoreList.Add(store)
                    Next
                End If
                'Add the SKUStores to the Validation item
                validationItem.itemLocTab = New itemLocObjType(skuStoreList.Count - 1) {}
                For i As Integer = 0 To skuStoreList.Count - 1
                    validationItem.itemLocTab(i) = New itemLocObjType
                    validationItem.itemLocTab(i).item = skuStoreList(i).MichaelsSKU
                    validationItem.itemLocTab(i).location = skuStoreList(i).StoreNumber
                    validationItem.itemLocTab(i).quantity = DataHelper.SmartValue(skuStoreList(i).OrderedQty, "CLng", 0)
                Next

                'Verify there is both a SKU and a Date before running validation. 
                If (hasASKU) Then

                    Dim service As New POService()
                    Dim results As submitValidationResponseReturn = service.submitValidation(validationItem)

                    If (results.jobObj IsNot Nothing) Then
                        If (results.jobObj.jobStatus = "Q") Then
                            poRecord.IsValidating = True
                            poRecord.ValidatingJobID = results.jobObj.jobId
                            poRecord.IsDetailValid = False
                            Data.POCreationData.UpdateRecordBySystem(poRecord, Michaels.POCreationData.Hydrate.None)
                        Else
                            Throw New Exception("There was a problem validating this Purchase Order.  Please try again later.  If this problem persist, please contact support.  Error: " & results.jobObj.errorMesg)
                        End If
                    End If
                End If

            End If
        Catch ex As Exception
            Throw
        End Try
    End Sub

    Public Shared Sub SubmitSKUValidation(ByVal poRecord As Models.POMaintenanceRecord)

        Dim hasASKU As Boolean = False

        Try
            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "string", False) Then

                'Get LocationConstant by LocationID
                Dim locationConstant As String = Data.POLocationData.GetLocationConstantByID(poRecord.POLocationID)

                'Create the ValidationItem
                Dim validationItem As New submitValidationArg0
                validationItem.referenceId = poRecord.PONumber  'USE PO Number for Maintenance since ReferenceID has to be unique
                validationItem.orderType = poRecord.BatchType
                validationItem.supplier = poRecord.VendorNumber
                validationItem.eventType = poRecord.BasicSeasonal
                validationItem.supplierSpecified = True
                validationItem.method = "SUBMIT"
                validationItem.type = "ITEMLOC"

                'CustomerOrder Flag setting
                If (poRecord.POSpecialID = WebConstants.POSPECIAL_CUSTOMERORDER) Then
                    validationItem.customerOrder = "Y"
                Else
                    validationItem.customerOrder = "N"
                End If

                'Only populate the EventYear if there is one
                If (poRecord.EventYear.HasValue) Then
                    validationItem.year = poRecord.EventYear
                    validationItem.yearSpecified = True
                End If

                'Get the Allocation Event ID, if the PO Has an allocation event specified
                If poRecord.POAllocationEventID.HasValue Then
                    validationItem.allocEvent = GetAllocationEventID(poRecord.POAllocationEventID)
                Else
                    validationItem.allocEvent = ""
                End If

                'Get the Ship Point Code if there is one, otherwise use the Ship Point description
                If poRecord.ShipPointCode IsNot Nothing Then
                    validationItem.shipPoint = poRecord.ShipPointCode
                Else
                    validationItem.shipPoint = DataHelper.SmartValuesDBNull(poRecord.ShipPointDescription, True)
                End If


                '********************************
                '*     ADD Location Dates       *
                '********************************
                validationItem.dateTab = New dateObjType(0) {}  'Yes, this is weird... just go with it
                'Create new dateObjType
                validationItem.dateTab(0) = New dateObjType
                'If this is a Warehouse order, populate Location.  Else populate CountryId
                If (poRecord.BatchType = "W") Then
                    validationItem.dateTab(0).location = locationConstant
                    validationItem.dateTab(0).locationSpecified = True
                Else
                    validationItem.dateTab(0).countryId = locationConstant
                End If

                'Populate Date fields on validationItem using dates from CACHE table
                Dim poCacheRecord As Models.POMaintenanceCacheRecord = Data.POMaintenanceData.GetCACHERecord(poRecord.ID, AppHelper.GetUserID())
                If (poCacheRecord.WrittenDate.HasValue) Then
                    validationItem.dateTab(0).writtenDate = GetDateWithFormat(poCacheRecord.WrittenDate)
                    validationItem.dateTab(0).writtenDateSpecified = True
                End If

                If (poCacheRecord.NotBefore.HasValue) Then
                    validationItem.dateTab(0).notBeforeDate = GetDateWithFormat(poCacheRecord.NotBefore)
                    validationItem.dateTab(0).notBeforeDateSpecified = True
                End If
                If (poCacheRecord.NotAfter.HasValue) Then
                    validationItem.dateTab(0).notAfterDate = GetDateWithFormat(poCacheRecord.NotAfter)
                    validationItem.dateTab(0).notAfterDateSpecified = True
                End If
                If (poCacheRecord.EstimatedInStockDate.HasValue) Then
                    validationItem.dateTab(0).inStockDate = GetDateWithFormat(poCacheRecord.EstimatedInStockDate)
                    validationItem.dateTab(0).inStockDateSpecified = True
                End If

                '***************************
                '*     ADD SKUs            *
                '***************************
                Dim skuList As List(Of Models.POMaintenanceSKURecord) = Data.POMaintenanceSKUData.GetSKUsByPOID(poRecord.ID)
                Dim skusToProcess As New List(Of Models.POMaintenanceSKURecord)

                'change 2018-11-08 to prevent empty records in itemTab
                'we're first going to count all the non-cancelled items and then create itemTab with that many elements
                Dim iNonCancelCount As Integer = 0

                For i As Integer = 0 To skuList.Count - 1
                    If skuList(i).CancelledQty < skuList(i).OrderedQty Then
                        iNonCancelCount += 1
                    End If
                Next

                Dim iItemCounter As Integer = 0
                validationItem.itemTab = New itemObjType(iNonCancelCount - 1) {}  'Yes, this is weird... just go with it
                For i As Integer = 0 To skuList.Count - 1

                    'Delete Validation Messages for this PO and SKU (New messages will be saved after validation is complete)
                    Data.POMaintenanceData.DeleteValidationMessages(poRecord.ID, skuList(i).MichaelsSKU)

                    'IF the sku has not been cancelled, then add it to the list of skus to process
                    If skuList(i).CancelledQty < skuList(i).OrderedQty Then
                        'Makes sure there is at least one SKU on the Validation request
                        hasASKU = True

                        validationItem.itemTab(iItemCounter) = New itemObjType
                        validationItem.itemTab(iItemCounter).item = skuList(i).MichaelsSKU
                        validationItem.itemTab(iItemCounter).spedyUnitcost = skuList(i).UnitCost.ToString
                        validationItem.itemTab(iItemCounter).spedyUnitcostSpecified = True
                        validationItem.itemTab(iItemCounter).spedyInnerPackSize = skuList(i).InnerPack.ToString
                        validationItem.itemTab(iItemCounter).spedyInnerPackSizeSpecified = True
                        validationItem.itemTab(iItemCounter).spedySuppPackSize = skuList(i).MasterPack.ToString
                        validationItem.itemTab(iItemCounter).spedySuppPackSizeSpecified = True
                        iItemCounter += 1

                        skusToProcess.Add(skuList(i))
                    Else
                        'The SKU has been cancelled, so mark the IsWSValid flag as True (since it will be skipping WS validation)
                        Data.POMaintenanceSKUData.UpdateValidity(skuList(i).POMaintenanceID, skuList(i).MichaelsSKU, skuList(i).IsValid, True)
                    End If
                Next

                '************************************
                '*     ADD SKU Locations            *
                '************************************
                'For Warehouse Orders, get List of Locations, and create "Store" list using warehouse LocationConstant
                Dim skuStoreList As New List(Of Models.POMaintenanceSKUStoreRecord)
                If (poRecord.BatchType = "W") Then
                    For Each sku As Models.POMaintenanceSKURecord In skusToProcess
                        Dim skuLocation As New Models.POMaintenanceSKUStoreRecord
                        skuLocation.MichaelsSKU = sku.MichaelsSKU
                        'NAK 11/10/2011: Per Lopa, we should be sending the outstanding qty rather than the location qty.
                        skuLocation.OrderedQty = sku.LocationTotalQty - sku.CancelledQty
                        skuLocation.POLocationID = locationConstant
                        skuLocation.StoreNumber = locationConstant  'Use LocationConstant as StoreNumber for Warehouse orders
                        skuLocation.POMaintenanceID = poRecord.ID

                        'Only add the SKU Location if the Location Qty > 0
                        If (sku.LocationTotalQty > 0) Then
                            skuStoreList.Add(skuLocation)
                        End If
                    Next
                End If
                'For Direct Orders, get the Store List associated with the PO
                If (poRecord.BatchType = "D") Then
                    Dim storeList As ArrayList = Data.POMaintenanceSKUStoreData.GetByPOID(poRecord.ID)
                    For Each store As Models.POMaintenanceSKUStoreRecord In storeList
                        'Only Add the Store if it is not cancelled
                        If (store.CancelledQty < store.OrderedQty) Then
                            skuStoreList.Add(store)
                        End If
                    Next
                End If
                'Add the SKUStores to the Validation item
                validationItem.itemLocTab = New itemLocObjType(skuStoreList.Count - 1) {}
                For i As Integer = 0 To skuStoreList.Count - 1
                    validationItem.itemLocTab(i) = New itemLocObjType
                    validationItem.itemLocTab(i).item = skuStoreList(i).MichaelsSKU
                    validationItem.itemLocTab(i).location = skuStoreList(i).StoreNumber
                    validationItem.itemLocTab(i).quantity = DataHelper.SmartValue(skuStoreList(i).OrderedQty, "CLng", 0)
                Next

                'Verify there is a SKU to validate
                If (hasASKU) Then

                    Dim service As New POService()
                    Dim results As submitValidationResponseReturn = service.submitValidation(validationItem)

                    If (results.jobObj IsNot Nothing) Then
                        If (results.jobObj.jobStatus = "Q") Then
                            poRecord.IsValidating = True
                            poRecord.ValidatingJobID = results.jobObj.jobId
                            poRecord.IsDetailValid = False
                            Data.POMaintenanceData.UpdateRecordBySystem(poRecord, Michaels.POMaintenanceData.Hydrate.All)
                        Else
                            Throw New Exception("There was a problem validating this Purchase Order.  Please try again later.  If this problem persist, please contact support.  Error: " & results.jobObj.errorMesg)
                        End If
                    End If
                End If

            End If
        Catch ex As Exception
            Throw
        End Try

    End Sub

    Public Shared Function ValidateDates(ByVal poRecord As Models.POCreationRecord) As Models.ValidationRecord

        Dim vr As New Models.ValidationRecord

        Try
            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "string", False) Then

                Dim locationDateList As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsCacheByPOID(poRecord.ID, AppHelper.GetUserID())
                'If there is a Date that is being either Validated or Populated, then perform the WS call
                If locationDateList.Count > 0 Then
                    'Create the ValidationItem
                    Dim validationItem As New validateDateArg0
                    validationItem.referenceId = poRecord.BatchNumber
                    validationItem.orderType = poRecord.BatchType
                    validationItem.supplier = poRecord.VendorNumber
                    validationItem.eventType = poRecord.BasicSeasonal
                    validationItem.supplierSpecified = True
                    validationItem.method = "VALIDATE"
                    validationItem.type = "DATE"

                    'Only populate the EventYear if there is one
                    If (poRecord.EventYear.HasValue) Then
                        validationItem.year = poRecord.EventYear
                        validationItem.yearSpecified = True
                    End If

                    'Get the Allocation Event ID, if the PO Has an allocation event specified
                    If poRecord.POAllocationEventID.HasValue Then
                        validationItem.allocEvent = GetAllocationEventID(poRecord.POAllocationEventID)
                    Else
                        validationItem.allocEvent = ""
                    End If

                    If poRecord.ShipPointCode IsNot Nothing Then
                        validationItem.shipPoint = poRecord.ShipPointCode
                    Else
                        validationItem.shipPoint = DataHelper.SmartValuesDBNull(poRecord.ShipPointDescription, True)
                    End If

                    validationItem.dateTab = New dateObjType(locationDateList.Count - 1) {} 'Yes, this is weird... just go with it
                    For i As Integer = 0 To locationDateList.Count - 1
                        'Create new dateObjType
                        validationItem.dateTab(i) = New dateObjType
                        'If this is a Warehouse order, populate Location.  Else populate CountryId
                        If (poRecord.BatchType = "W") Then
                            validationItem.dateTab(i).location = locationDateList(i).LocationConstant
                            validationItem.dateTab(i).locationSpecified = True
                        Else
                            validationItem.dateTab(i).countryId = locationDateList(i).LocationConstant
                        End If

                        'Populate Date fields on validationItem
                        If (locationDateList(i).WrittenDate.HasValue) Then
                            validationItem.dateTab(i).writtenDate = GetDateWithFormat(locationDateList(i).WrittenDate)
                            validationItem.dateTab(i).writtenDateSpecified = True
                        End If

                        If (locationDateList(i).NotBefore.HasValue) Then
                            validationItem.dateTab(i).notBeforeDate = GetDateWithFormat(locationDateList(i).NotBefore)
                            validationItem.dateTab(i).notBeforeDateSpecified = True
                        End If
                        If (locationDateList(i).NotAfter.HasValue) Then
                            validationItem.dateTab(i).notAfterDate = GetDateWithFormat(locationDateList(i).NotAfter)
                            validationItem.dateTab(i).notAfterDateSpecified = True
                        End If
                        If (locationDateList(i).EstimatedInStockDate.HasValue) Then
                            validationItem.dateTab(i).inStockDate = GetDateWithFormat(locationDateList(i).EstimatedInStockDate)
                            validationItem.dateTab(i).inStockDateSpecified = True
                        End If
                    Next

                    Dim service As New POService()
                    Dim response As New validateDateResponseReturn
                    response = service.validateDate(validationItem)

                    'Check to see if a validFlag is specified in the results
                    If response.valFlagSpecified Then
                        'Loop through the dateObj to figure out which one is invalid
                        Dim isDateWarning As Boolean = False
                        For j As Integer = 0 To response.dateTab.Length - 1
                            If (response.dateTab(j).errorTab IsNot Nothing) Then
                                'Loop through the Errors on this dateObj, and create Error entries for each one
                                For k As Integer = 0 To response.dateTab(j).errorTab.Length - 1
                                    vr.Add("", response.dateTab(j).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError)
                                Next
                            End If

                            'Loop through the Warnings on this dateObj, and create warning entries for each one.
                            'Additionally, update the IsDateWarning flag on the CACHE (which will be transferred to live data if saved)
                            If (response.dateTab(j).warningTab IsNot Nothing) Then
                                For k As Integer = 0 To response.dateTab(j).warningTab.Length - 1
                                    vr.Add("", response.dateTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                    isDateWarning = True
                                Next
                            End If

                            'Save dates returned from the Webservice call, but Loop through our list of locations to find the matching one
                            For Each poLoc As Models.POCreationLocationRecord In locationDateList
                                'Get the LocationID from either the Location or the Country field
                                Dim locationID As String = String.Empty
                                If (poLoc.LocationConstant = response.dateTab(j).location.ToString) Then
                                    locationID = response.dateTab(j).location
                                ElseIf (poLoc.LocationConstant = response.dateTab(j).countryId) Then
                                    locationID = Data.POLocationData.GetLocationIDByConstant(response.dateTab(j).countryId)
                                End If

                                'IF the location matches AND we have a locationID, then Save the dates (if we currently do not have dates)
                                Dim doSave As Boolean = False
                                If (locationID <> String.Empty) Then
                                    If (response.dateTab(j).notBeforeDateSpecified And (Not poLoc.NotBefore.HasValue)) Then
                                        poLoc.NotBefore = DataHelper.SmartValue(response.dateTab(j).notBeforeDate, "CDate", Nothing)
                                        doSave = True
                                    End If
                                    If (response.dateTab(j).notAfterDateSpecified And (Not poLoc.NotAfter.HasValue)) Then
                                        poLoc.NotAfter = DataHelper.SmartValue(response.dateTab(j).notAfterDate, "CDate", Nothing)
                                        doSave = True
                                    End If
                                    If (response.dateTab(j).inStockDateSpecified And (Not poLoc.EstimatedInStockDate.HasValue)) Then
                                        poLoc.EstimatedInStockDate = DataHelper.SmartValue(response.dateTab(j).inStockDate, "CDate", Nothing)
                                        doSave = True
                                    End If

                                    If doSave Then
                                        'RULE: Update CACHE and LIVE Tables with results from Webservice
                                        Data.POCreationData.UpdateLocationCache(poLoc, HttpContext.Current.Session("UserID"))
                                        Data.POCreationData.UpdateLocation(poLoc, HttpContext.Current.Session("UserID"))
                                    End If
                                End If
                            Next
                        Next
                        'Update DateWarning flag
                        Data.POCreationCacheData.UpdateIsDateWarning(poRecord.ID, AppHelper.GetUserID(), isDateWarning)
                    Else
                        Throw New Exception("Error From Michaels Webservice validateDate(): " & response.jobObj.errorMesg)
                    End If
                End If
            End If

        Catch ex As Exception
            Throw
        End Try

        Return vr
    End Function

    Public Shared Function ValidateDates(ByVal poRecord As Models.POMaintenanceRecord) As Models.ValidationRecord
        Dim vr As New Models.ValidationRecord

        Try
            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "string", False) Then

                'Get LocationConstant by locationID 
                Dim locationConstant As String = Data.POLocationData.GetLocationConstantByID(poRecord.POLocationID)

                'Create the ValidationItem
                Dim validationItem As New validateDateArg0
                validationItem.referenceId = poRecord.PONumber  'USE PO Number for Maintenance since ReferenceID has to be unique
                validationItem.orderType = poRecord.BatchType
                validationItem.supplier = poRecord.VendorNumber
                validationItem.eventType = poRecord.BasicSeasonal
                validationItem.supplierSpecified = True
                validationItem.method = "VALIDATE"
                validationItem.type = "DATE"

                'Only populate the EventYear if there is one
                If (poRecord.EventYear.HasValue) Then
                    validationItem.year = poRecord.EventYear
                    validationItem.yearSpecified = True
                End If

                'Get the Allocation Event ID, if the PO Has an allocation event specified
                If poRecord.POAllocationEventID.HasValue Then
                    validationItem.allocEvent = GetAllocationEventID(poRecord.POAllocationEventID)
                Else
                    validationItem.allocEvent = ""
                End If

                If poRecord.ShipPointCode IsNot Nothing Then
                    validationItem.shipPoint = poRecord.ShipPointCode
                Else
                    validationItem.shipPoint = DataHelper.SmartValuesDBNull(poRecord.ShipPointDescription, True)
                End If

                validationItem.dateTab = New dateObjType(0) {}  'Yes, this is weird... just go with it

                'Create new dateObjType
                validationItem.dateTab(0) = New dateObjType
                'If this is a Warehouse order, populate Location.  Else populate CountryId
                If (poRecord.BatchType = "W") Then
                    validationItem.dateTab(0).location = locationConstant
                    validationItem.dateTab(0).locationSpecified = True
                Else
                    validationItem.dateTab(0).countryId = locationConstant
                End If

                'Populate Date fields on validationItem using dates from CACHE table
                Dim poCacheRecord As Models.POMaintenanceCacheRecord = Data.POMaintenanceData.GetCACHERecord(poRecord.ID, AppHelper.GetUserID())
                If (poCacheRecord.WrittenDate.HasValue) Then
                    validationItem.dateTab(0).writtenDate = GetDateWithFormat(poCacheRecord.WrittenDate)
                    validationItem.dateTab(0).writtenDateSpecified = True
                End If
                If (poCacheRecord.NotBefore.HasValue) Then
                    validationItem.dateTab(0).notBeforeDate = GetDateWithFormat(poCacheRecord.NotBefore)
                    validationItem.dateTab(0).notBeforeDateSpecified = True
                End If
                If (poCacheRecord.NotAfter.HasValue) Then
                    validationItem.dateTab(0).notAfterDate = GetDateWithFormat(poCacheRecord.NotAfter)
                    validationItem.dateTab(0).notAfterDateSpecified = True
                End If
                If (poCacheRecord.EstimatedInStockDate.HasValue) Then
                    validationItem.dateTab(0).inStockDate = GetDateWithFormat(poCacheRecord.EstimatedInStockDate)
                    validationItem.dateTab(0).inStockDateSpecified = True
                End If

                Dim service As New POService()
                Dim response As New validateDateResponseReturn
                response = service.validateDate(validationItem)

                'Check to see if a validFlag is specified in the results
                If response.valFlagSpecified Then
                    'Loop through the dateObj to figure out which one is invalid
                    Dim isDateWarning As Boolean = False
                    For j As Integer = 0 To response.dateTab.Length - 1
                        If (response.dateTab(j).errorTab IsNot Nothing) Then
                            'Loop through the Errors on this dateObj, and create Error entries for each one
                            For k As Integer = 0 To response.dateTab(j).errorTab.Length - 1
                                vr.Add("", response.dateTab(j).errorTab(k))
                            Next
                        End If

                        'Loop through the Warnings on this dateObj, and create warning entries for each one.
                        'Additionally, update the IsDateWarning flag on the CACHE (which will be transferred to live data if saved)

                        If (response.dateTab(j).warningTab IsNot Nothing) Then
                            For k As Integer = 0 To response.dateTab(j).warningTab.Length - 1
                                vr.Add("", response.dateTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                isDateWarning = True
                            Next
                        End If

                        'SAVE PO Results if they are passed back.
                        If (response.dateTab(j).notBeforeDateSpecified And (Not poCacheRecord.NotBefore.HasValue)) Then
                            poRecord.NotBefore = DataHelper.SmartValue(response.dateTab(j).notBeforeDate, "CDate", Nothing)
                            poCacheRecord.NotBefore = poRecord.NotBefore
                        End If
                        If (response.dateTab(j).notAfterDateSpecified And (Not poCacheRecord.NotAfter.HasValue)) Then
                            poRecord.NotAfter = DataHelper.SmartValue(response.dateTab(j).notAfterDate, "CDate", Nothing)
                            poCacheRecord.NotAfter = poRecord.NotAfter
                        End If
                        If (response.dateTab(j).inStockDateSpecified And (Not poCacheRecord.EstimatedInStockDate.HasValue)) Then
                            poRecord.EstimatedInStockDate = DataHelper.SmartValue(response.dateTab(j).inStockDate, "CDate", Nothing)
                            poCacheRecord.EstimatedInStockDate = poRecord.EstimatedInStockDate
                        End If
                    Next

                    'Save Record and CACHE Record
                    Data.POMaintenanceData.SaveRecord(poRecord, HttpContext.Current.Session("UserID"))
                    Data.POMaintenanceCacheData.UpdateRecord(poCacheRecord, Michaels.POMaintenanceCacheData.Hydrate.None)

                    'Update DateWarning Flag
                    Data.POMaintenanceCacheData.UpdateIsDateWarning(poRecord.ID, AppHelper.GetUserID(), isDateWarning)
                Else
                    Throw New Exception("Error From Michaels Webservice validateDate(): " & response.jobObj.errorMesg)
                End If
            End If

        Catch ex As Exception
            Throw
        End Try

        Return vr
    End Function

    Public Shared Function ValidateItems(ByVal poRecord As Models.POCreationRecord) As Models.ValidationRecord
        Dim vr As New Models.ValidationRecord
        Dim hasASku As Boolean = False

        Try
            'Get the List of SKUs attached to this PO
            Dim skuList As List(Of Models.POCreationLocationSKURecord) = Data.POCreationLocationSKUData.GetSKUsByPOID(poRecord.ID)
            Dim invalidSKUs As New ArrayList

            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "CStr", False) Then
                Dim validationItem As New validateItemArg0
                validationItem.referenceId = poRecord.BatchNumber
                validationItem.orderType = poRecord.BatchType
                validationItem.supplier = poRecord.VendorNumber
                validationItem.eventType = poRecord.BasicSeasonal
                validationItem.supplierSpecified = True
                validationItem.method = "VALIDATE"
                validationItem.type = "ITEM"

                validationItem.itemTab = New itemObjType(skuList.Count - 1) {}  'Yes, this is weird... just go with it
                For i As Integer = 0 To skuList.Count - 1
                    'IF the SKU is not WS_Valid
                    'If Not (skuList(i).IsWSValid) Then
                    hasASku = True

                    validationItem.itemTab(i) = New itemObjType
                    validationItem.itemTab(i).item = skuList(i).MichaelsSKU
                    validationItem.itemTab(i).spedyUnitcost = skuList(i).UnitCost.ToString
                    validationItem.itemTab(i).spedyUnitcostSpecified = True
                    validationItem.itemTab(i).spedyInnerPackSize = skuList(i).InnerPack
                    validationItem.itemTab(i).spedyInnerPackSizeSpecified = True
                    validationItem.itemTab(i).spedySuppPackSize = skuList(i).MasterPack
                    validationItem.itemTab(i).spedySuppPackSizeSpecified = True

                    'Delete Validation Messages for this PO and SKU (New messages will be saved after validation is complete)
                    Data.POCreationData.DeleteValidationMessages(poRecord.ID, skuList(i).MichaelsSKU)
                    ' End If
                Next

                'Only call the WebService if there are SKUs for it
                If (hasASku) Then

                    Dim service As New POService()
                    Dim response As New validateItemResponseReturn
                    response = service.validateItem(validationItem)

                    If (response.valFlagSpecified) Then

                        'Construct table for validation messages
                        Dim validationMessageTable As DataTable = New DataTable
                        validationMessageTable.Columns.Add("ID", GetType(Int64))
                        validationMessageTable.Columns.Add("PO_Creation_ID", GetType(Int64))
                        validationMessageTable.Columns.Add("Michaels_SKU", GetType(String))
                        validationMessageTable.Columns.Add("Store_Number", GetType(Int32))
                        validationMessageTable.Columns.Add("Message", GetType(String))
                        validationMessageTable.Columns.Add("Severity_Type", GetType(Int32))
                        validationMessageTable.Columns.Add("Date_Received", GetType(DateTime))

                        'Loop through the itemObj to see if any are invalid
                        For j As Integer = 0 To response.itemTab.Length - 1
                            If (response.itemTab(j).errorTab IsNot Nothing) Then
                                'Loop through the Errors on this itemObj, and create Error entries for each one
                                For k As Integer = 0 To response.itemTab(j).errorTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, response.itemTab(j).item, Nothing, response.itemTab(j).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError, DateTime.Now)

                                    'Add This SKu To List Of Invalid SKUs
                                    If Not invalidSKUs.Contains(response.itemTab(j).item) Then
                                        invalidSKUs.Add(response.itemTab(j).item)
                                    End If

                                Next

                            End If
                            If (response.itemTab(j).warningTab IsNot Nothing) Then
                                'Loop through the Warnings on this itemObj, and save them for display on the page
                                For k As Integer = 0 To response.itemTab(j).warningTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, response.itemTab(j).item, Nothing, response.itemTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning, DateTime.Now)
                                Next
                            End If
                        Next

                        If (validationMessageTable.Rows.Count > 0) Then
                            Data.POCreationData.SaveValidationMessages(validationMessageTable)
                        End If
                    Else
                        Throw New Exception("Error From Michaels Webservice validateItem(): " & response.jobObj.errorMesg)
                    End If
                End If


            End If

            'Update SKU Validity
            For Each sku As Models.POCreationLocationSKURecord In skuList
                If (invalidSKUs.Contains(sku.MichaelsSKU)) Then
                    sku.IsWSValid = False
                    Data.POCreationLocationSKUData.UpdateSKUsByPOID(poRecord.ID, sku)
                Else
                    If (sku.IsWSValid Is Nothing) Or (sku.IsWSValid = False) Then
                        sku.IsWSValid = True
                        Data.POCreationLocationSKUData.UpdateSKUsByPOID(poRecord.ID, sku)
                    End If
                End If
            Next

        Catch ex As Exception
            Throw
        End Try

        Return vr
    End Function

    Public Shared Function ValidateItems(ByVal poRecord As Models.POMaintenanceRecord) As Models.ValidationRecord
        Dim vr As New Models.ValidationRecord
        Dim hasASku As Boolean = False

        Try
            'Get the List of SKUs attached to this PO
            Dim skuList As List(Of Models.POMaintenanceSKURecord) = Data.POMaintenanceSKUData.GetSKUsByPOID(poRecord.ID)
            Dim invalidSKUs As New ArrayList

            'Call the Michaels WebService Validation if the WebServices are Enabled in the web.config
            If DataHelper.SmartValue(System.Configuration.ConfigurationManager.AppSettings("IsPOWebServiceEnabled"), "CStr", False) Then
                Dim validationItem As New validateItemArg0
                validationItem.referenceId = poRecord.PONumber  'USE PO Number for Maintenance since ReferenceID has to be unique
                validationItem.orderType = poRecord.BatchType
                validationItem.supplier = poRecord.VendorNumber
                validationItem.eventType = poRecord.BasicSeasonal
                validationItem.supplierSpecified = True
                validationItem.method = "VALIDATE"
                validationItem.type = "ITEM"

                validationItem.itemTab = New itemObjType(skuList.Count - 1) {}  'Yes, this is weird... just go with it
                For i As Integer = 0 To skuList.Count - 1
                    'IF the SKU is not WS_Valid
                    'If Not (skuList(i).IsWSValid) Then
                    hasASku = True

                    validationItem.itemTab(i) = New itemObjType
                    validationItem.itemTab(i).item = skuList(i).MichaelsSKU
                    validationItem.itemTab(i).spedyUnitcost = skuList(i).UnitCost.ToString
                    validationItem.itemTab(i).spedyUnitcostSpecified = True
                    validationItem.itemTab(i).spedyInnerPackSize = skuList(i).InnerPack.ToString
                    validationItem.itemTab(i).spedyInnerPackSizeSpecified = True
                    validationItem.itemTab(i).spedySuppPackSize = skuList(i).MasterPack.ToString
                    validationItem.itemTab(i).spedySuppPackSizeSpecified = True

                    'Delete Validation Messages for this PO and SKU (New messages will be saved after validation is complete)
                    Data.POMaintenanceData.DeleteValidationMessages(poRecord.ID, skuList(i).MichaelsSKU)
                    'End If
                Next

                'Only call the WebService if there are SKUs for it
                If (hasASku) Then

                    Dim service As New POService()
                    Dim response As New validateItemResponseReturn
                    response = service.validateItem(validationItem)

                    If (response.valFlagSpecified) Then
                        'Construct table for validation messages
                        Dim validationMessageTable As DataTable = New DataTable
                        validationMessageTable.Columns.Add("ID", GetType(Int64))
                        validationMessageTable.Columns.Add("PO_Maintenance_ID", GetType(Int64))
                        validationMessageTable.Columns.Add("Michaels_SKU", GetType(String))
                        validationMessageTable.Columns.Add("Store_Number", GetType(Int32))
                        validationMessageTable.Columns.Add("Message", GetType(String))
                        validationMessageTable.Columns.Add("Severity_Type", GetType(Int32))
                        validationMessageTable.Columns.Add("Date_Received", GetType(DateTime))


                        'Loop through the itemObj to see if any are invalid
                        For j As Integer = 0 To response.itemTab.Length - 1
                            If (response.itemTab(j).errorTab IsNot Nothing) Then
                                'Loop through the Errors on this itemObj, and create Error entries for each one
                                For k As Integer = 0 To response.itemTab(j).errorTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, response.itemTab(j).item, Nothing, response.itemTab(j).errorTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeError, DateTime.Now)

                                    'Add This SKu To List Of Invalid SKUs
                                    If Not invalidSKUs.Contains(response.itemTab(j).item) Then
                                        invalidSKUs.Add(response.itemTab(j).item)
                                    End If

                                Next

                            End If
                            If (response.itemTab(j).warningTab IsNot Nothing) Then
                                'Loop through the Warnings on this itemObj, and save them for display on the page
                                For k As Integer = 0 To response.itemTab(j).warningTab.Length - 1
                                    validationMessageTable.Rows.Add(Nothing, poRecord.ID, response.itemTab(j).item, Nothing, response.itemTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                    'Data.POMaintenanceData.SaveValidationMessage(poRecord.ID, response.itemTab(j).item, Nothing, response.itemTab(j).warningTab(k), NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType.TypeWarning)
                                Next
                            End If
                        Next

                        If (validationMessageTable.Rows.Count > 0) Then
                            Data.POMaintenanceData.SaveValidationMessages(validationMessageTable)
                        End If
                    Else
                        Throw New Exception("Error From Michaels Webservice validateItem(): " & response.jobObj.errorMesg)
                    End If
                End If
            End If

            'Update SKU Validity
            For Each sku As Models.POMaintenanceSKURecord In skuList
                If (invalidSKUs.Contains(sku.MichaelsSKU)) Then
                    sku.IsWSValid = False
                    Data.POMaintenanceSKUData.UpdateValidity(sku.POMaintenanceID, sku.MichaelsSKU, sku.IsValid, sku.IsWSValid)
                Else
                    If (sku.IsWSValid Is Nothing) Or (sku.IsWSValid = False) Then
                        sku.IsWSValid = True
                        Data.POMaintenanceSKUData.UpdateValidity(sku.POMaintenanceID, sku.MichaelsSKU, sku.IsValid, sku.IsWSValid)
                    End If
                End If
            Next

        Catch ex As Exception
            Throw
        End Try

        Return vr
    End Function

    'Private Shared Function FilterLocations(ByVal poRecord As Models.POCreationRecord) As List(Of Models.POCreationLocationRecord)

    '	Dim locationList As New List(Of Models.POCreationLocationRecord)
    '	Dim allLocations As List(Of Models.POCreationLocationRecord) = Data.POCreationData.GetLocationsByPOID(poRecord.ID)

    '	For Each location As Models.POCreationLocationRecord In allLocations
    '		location.IsValidating = False
    '		'RULE:  Allocation Event is specified, PO Batch Type is Warehouse, and Event Year is specified so continue checks...
    '		If (poRecord.POAllocationEventID.HasValue And poRecord.BatchType = "W" And poRecord.EventYear.HasValue) Then
    '			'RULE: If Vendor is Import AND Ship Point Code is specified, OR if Vendor is Domestic
    '			If ((ValidationHelper.IsValidImportVendor(poRecord.VendorNumber) And DataHelper.SmartValue(poRecord.ShipPointCode, "CStr", "") <> String.Empty) Or ValidationHelper.IsValidDomesticVendor(poRecord.VendorNumber)) Then
    '				location.IsValidating = True
    '			End If
    '		End If

    '		'PO Batch Type is Direct, so run the checks below
    '		If (poRecord.BatchType = "D") Then
    '			'RULE: Allocation Event is populated, and Event Year is populated
    '			If (poRecord.POAllocationEventID.HasValue And poRecord.EventYear.HasValue) Then
    '				location.IsValidating = True
    '			End If
    '			'RULE: Estimated InStock Date is specified, AND Allocation Event is NOT specified
    '			If (location.EstimatedInStockDate > Date.MinValue And Not (poRecord.POAllocationEventID.HasValue)) Then
    '				location.IsValidating = True
    '			End If
    '		End If

    '		locationList.Add(location)
    '	Next

    '	Return locationList
    'End Function

    'Private Shared Function FilterLocations(ByRef poRecord As Models.POMaintenanceRecord) As Boolean

    '	'RULE:  Allocation Event is specified, PO Batch Type is Warehouse, and Event Year is specified so continue checks...
    '	If (poRecord.POAllocationEventID.HasValue And poRecord.BatchType = "W" And poRecord.EventYear.HasValue) Then
    '		'RULE: If Vendor is Import AND Ship Point Code is specified, OR if Vendor is Domestic
    '		If ((ValidationHelper.IsValidImportVendor(poRecord.VendorNumber) And DataHelper.SmartValue(poRecord.ShipPointCode, "CStr", "") <> String.Empty) Or ValidationHelper.IsValidDomesticVendor(poRecord.VendorNumber)) Then
    '			Return True
    '		End If
    '	End If

    '	'PO Batch Type is Direct, so run the checks below
    '	If (poRecord.BatchType = "D") Then
    '		'RULE: Allocation Event is populated, and Event Year is populated
    '		If (poRecord.POAllocationEventID.HasValue And poRecord.EventYear.HasValue) Then
    '			Return True
    '		End If
    '		'RULE: Estimated InStock Date is specified, AND Allocation Event is NOT specified
    '		If (poRecord.EstimatedInStockDate > Date.MinValue And Not (poRecord.POAllocationEventID.HasValue)) Then
    '			Return True
    '		End If
    '	End If

    '	Return False
    'End Function

    Private Shared Function GetAllocationEventID(ByVal poAllocationEventID As Integer?) As String

        Dim allocationEventID As String = String.Empty

        Dim sql As String = "PO_Allocation_Event_Get_By_ID"
        Dim reader As DBReader = Nothing
        Dim conn As DBConnection = Nothing

        Try
            conn = Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn)
            reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = poAllocationEventID
            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()
            If reader.Read() Then
                With reader
                    allocationEventID = DataHelper.SmartValuesDBNull(.Item("ALLOC_EVENT_ID"), True)
                End With
            End If

        Catch ex As Exception
            Throw ex
        Finally
            If Not reader Is Nothing Then
                reader.Dispose()
                reader = Nothing
            End If
            If Not conn Is Nothing Then
                conn.Dispose()
                conn = Nothing
            End If
        End Try

        Return allocationEventID
    End Function

    Private Shared Function GetLocationIDByConstant(ByVal locationConstant As String) As Integer?

        'In order to limit the number of database calls, I am using WebConstants to retrieve PO_Location_IDs
        Select Case (locationConstant)
            Case "US"
                Return WebConstants.PO_LOCATION_US_ZONE
            Case "CA"
                Return WebConstants.PO_LOCATION_CA_ZONE
            Case "CAN"
                Return WebConstants.PO_LOCATION_CA_ZONE
            Case "AL"
                Return WebConstants.PO_LOCATION_AK_ZONE
            Case "AK"
                Return WebConstants.PO_LOCATION_AK_ZONE
        End Select

        Return Nothing
    End Function

    Private Shared Function GetDateWithFormat(ByVal objDate As Date?) As String

        Dim dateString As String = ""
        If (objDate.HasValue) Then
            If (objDate.Value > Date.MinValue) Then
                dateString = Convert.ToDateTime(objDate).ToString("yyyy-MM-dd")
            End If
        End If

        Return dateString
    End Function

End Class



