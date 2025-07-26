Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class MaintItemMasterData
        Inherits FieldLockingData

        ' ***************************
        ' * ITEM MAINT ITEM DETAIL  *
        ' ***************************

        Public Shared Function GetPackChanges(ByVal batchID As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.PackChanges
            Dim objRecord As PackChanges = New PackChanges(batchID)
            Dim sql As String = "usp_SPD_ItemMaint_GetPackChanges"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@BatchID", SqlDbType.BigInt)
                objParam.Value = batchID
                reader.Command.Parameters.Add(objParam)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader
                        objRecord.SKUsAddedToPack = DataHelper.SmartValues(.Item("SKUsAddedToPack"), "string", False)
                        objRecord.SKUsDeletedFromPack = DataHelper.SmartValues(.Item("SKUsDeletedFromPack"), "string", False)
                    End With

                End If


            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.BatchID = -1
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
            Return objRecord

        End Function

        Public Shared Function GetItemMaintItemDetailRecordByQRN(ByVal QRN As String, ByVal vendorID As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailFormRecord
            Dim sku As String
            Dim sql As String = "SELECT Michaels_SKU FROM spd_items WHERE QuoteReferenceNumber = @qrn "

            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.AddWithValue("@qrn", QRN)

                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()

                If reader.Read Then
                    sku = DataHelper.SmartValues(reader.Item("Michaels_SKU"), "string", True)
                Else
                    sku = String.Empty
                End If

            Catch ex As Exception
                Logger.LogError(ex)
                sku = String.Empty
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

            Return GetItemMaintItemDetailRecord(-1, vendorID, sku, vendorID)

        End Function

        Public Shared Function GetBatchValidCounts(ByVal batchID As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.BatchValidCounts
            Dim objRecord As BatchValidCounts = New BatchValidCounts(batchID)
            Dim sql As String = "usp_SPD_ItemMaint_GetValidCounts_By_BatchID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@batchID", SqlDbType.BigInt)
                objParam.Value = batchID
                reader.Command.Parameters.Add(objParam)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader
                        objRecord.ItemValidCount = DataHelper.SmartValues(.Item("Item_Valid_Count"), "integer", False)
                        objRecord.ItemNotValidCount = DataHelper.SmartValues(.Item("Item_NotValid_Count"), "integer", False)
                        objRecord.ItemUnknownCount = DataHelper.SmartValues(.Item("Item_Unknown_Count"), "integer", False)
                    End With

                End If


            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.BatchID = -1
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
            Return objRecord
        End Function

        Public Shared Function GetItemMaintItemDetailRecord(ByVal vendorID As Long, ByVal SKU As String, ByVal VendorNum As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailFormRecord
            Return GetItemMaintItemDetailRecord(-1, vendorID, SKU, VendorNum)
        End Function

        Public Shared Function GetItemMaintItemDetailRecord(ByVal itemID As Long, ByVal vendorID As Long, Optional ByVal sku As String = "", Optional ByVal VendorNum As Long = 0) _
                As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintItemDetailFormRecord

            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim sql As String = "usp_SPD_ItemMaint_GetItemByIDOrSKU"
            Dim objRecord As ItemMaintItemDetailFormRecord = New ItemMaintItemDetailFormRecord()

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = itemID
                cmd.Parameters.Add("@VendorID", SqlDbType.BigInt).Value = vendorID
                If sku <> "" Then cmd.Parameters.Add("@SKU", SqlDbType.VarChar).Value = sku
                If VendorNum > 0 Then cmd.Parameters.Add("@VendorNum", SqlDbType.Int).Value = VendorNum

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                If reader.Read() Then
                    LoadItemMaintRecord(objRecord, reader)
                Else
                    objRecord.ID = 0
                End If

                'Get language settings from SPD_Import_Item_Languages
                Dim languageDT As DataTable = GetItemLanguages(objRecord.SKU, objRecord.VendorNumber)
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
                                objRecord.PLIEnglish = pli
                                objRecord.TIEnglish = ti
                                objRecord.EnglishShortDescription = descShort
                                objRecord.EnglishLongDescription = descLong
                            Case 2
                                objRecord.PLIFrench = pli
                                objRecord.TIFrench = ti
                                objRecord.FrenchShortDescription = descShort
                                objRecord.FrenchLongDescription = descLong
                                objRecord.ExemptEndDateFrench = exemptEndDate
                            Case 3
                                objRecord.PLISpanish = pli
                                objRecord.TISpanish = ti
                                objRecord.SpanishShortDescription = descShort
                                objRecord.SpanishLongDescription = descLong
                        End Select
                    Next
                End If

                ' Get additional UPCs
                reader.NextResult()
                Dim AdditionalUPCs As List(Of ItemMasterVendorUPCRecord) = New List(Of ItemMasterVendorUPCRecord)
                If reader.HasRows Then
                    Dim UPCRecord As ItemMasterVendorUPCRecord
                    Do While reader.Read()
                        UPCRecord = New ItemMasterVendorUPCRecord
                        With reader
                            UPCRecord.UPC = DataHelper.SmartValues(.Item("UPC"), "string", True)
                        End With
                        AdditionalUPCs.Add(UPCRecord)
                    Loop
                End If
                objRecord.AdditionalUPCRecs = AdditionalUPCs

                ' Get addtional Countries
                reader.NextResult()
                Dim AdditionalCountries As List(Of ItemMasterVendorCountryRecord) = New List(Of ItemMasterVendorCountryRecord)
                If reader.HasRows Then
                    Dim CountryRecord As ItemMasterVendorCountryRecord
                    Do While reader.Read()
                        CountryRecord = New ItemMasterVendorCountryRecord
                        With reader
                            CountryRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("Country_Of_Origin"), "string", True)
                            CountryRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("Country_Of_Origin_Name"), "string", True)
                        End With
                        AdditionalCountries.Add(CountryRecord)
                    Loop
                End If
                objRecord.AdditionalCOORecs = AdditionalCountries

            Catch ex As Exception
                Dim exc As New Exception("Error Retrieving Item Record: " & ex.Message)
                Logger.LogError(exc)
                objRecord.ID = -1
                Throw exc
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
            Return objRecord
        End Function

        Public Shared Function GetItemInvalidCount(ByVal batchID As Long) As Integer
            Dim recCount As Integer = 0
            Dim sql As String = "select count(ID) as RecordCount from vwItemMaintItemDetail where BatchID = @batchID and ISNULL(IsValid, 0) = 0"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return recCount
        End Function

        Public Shared Function GetItemValidationUnknownCount(ByVal batchID As Long) As Integer
            Dim recCount As Integer = 0
            Dim sql As String = "select count(ID) as RecordCount from vwItemMaintItemDetail where BatchID = @batchID and ISNULL(IsValid, -1) = -1"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return recCount
        End Function

        Public Shared Function GetItemListCount(ByVal batchID As Long, ByVal xmlSortCriteria As String, ByVal userID As Long) As Integer
            Dim listCount As Integer = 0
            Dim sql As String = "usp_SPD_ItemMaint_GetListCount"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.NVarChar, -1).Value = xmlSortCriteria
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    listCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return listCount
        End Function

        Public Shared Function GetItemMaintItemsByBatchID(ByVal batchID As Long) As List(Of ItemMaintItemDetailRecord)
            Dim objItemsList As New List(Of ItemMaintItemDetailRecord)
            Dim objRecord As ItemMaintItemDetailRecord
            Dim sql As String = "usp_SPD_ItemMaint_GetItems_By_BatchID"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                'conn2 = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read
                    objRecord = New ItemMaintItemDetailRecord()
                    LoadItemMaintRecord(objRecord, reader)
                    objItemsList.Add(objRecord)
                Loop
                reader.Close()
                reader.Dispose()
                reader = Nothing
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objItemsList
        End Function

        Public Shared Function GetBulkItemList(ByVal batchID As Long, ByVal startRow As Integer, ByVal pageSize As Integer, ByVal xmlSortCriteria As String, ByVal userID As Long) As ItemMaintItemDetailRecordList
            Dim objItemsList As ItemMaintItemDetailRecordList = New ItemMaintItemDetailRecordList()
            Dim objRecord As ItemMaintItemDetailFormRecord
            Dim sql As String = "usp_SPD_BulkItemMaint_GetList"
            Dim reader As DBReader = Nothing
            'Dim reader2 As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn.Open()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = startRow
                cmd.Parameters.Add("@pageSize", SqlDbType.Int).Value = pageSize
                cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.NVarChar, -1).Value = xmlSortCriteria
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    objItemsList.TotalRecords = DataHelper.SmartValues(reader.Item("totRecords"), "integer", False)
                Else
                    objItemsList.TotalRecords = 0
                End If
                Do While bRead
                    objRecord = New ItemMaintItemDetailFormRecord()

                    LoadItemMaintRecordFromList(objRecord, reader)

                    objItemsList.ListRecords.Add(objRecord)
                    bRead = reader.Read()
                Loop
                reader.Dispose()
                reader = Nothing

                ' Get addtional Countries
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemIDs", SqlDbType.VarChar, 8000).Value = objItemsList.GetRecordIDs()
                reader.CommandText = "usp_SPD_ItemMaint_GetItemCOO"
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                If reader.HasRows Then
                    Dim countryRecord As ItemMasterVendorCountryRecord
                    Dim itemID As Integer
                    objRecord = Nothing
                    Do While reader.Read()
                        itemID = DataHelper.SmartValues(reader.Item("Item_ID"), "integer", False)
                        If objRecord Is Nothing OrElse objRecord.ID <> itemID Then
                            objRecord = objItemsList.ItemByID(itemID)
                        End If
                        If objRecord IsNot Nothing Then

                            countryRecord = New ItemMasterVendorCountryRecord()
                            With reader
                                countryRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("Country_Of_Origin"), "string", True)
                                countryRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("Country_Of_Origin_Name"), "string", True)
                            End With
                            objRecord.AddAdditionalCOO(countryRecord)

                        End If

                    Loop
                End If
                reader.Dispose()
                reader = Nothing

            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objItemsList
        End Function

        Public Shared Function GetBulkItemListCount(ByVal batchID As Long, ByVal xmlSortCriteria As String, ByVal userID As Long) As Integer
            Dim listCount As Integer = 0
            Dim sql As String = "usp_SPD_BulkItemMaint_GetListCount"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.NVarChar, -1).Value = xmlSortCriteria
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    listCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return listCount
        End Function

        Public Shared Function GetImageInfoBySKU(ByVal sku As String) As List(Of ItemMaintImageRecord)
            Dim images As New List(Of ItemMaintImageRecord)

            Dim sql As String = "usp_SPD_ItemMaint_GetImageInfoBySKU"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn.Open()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@MichaelsSKU", SqlDbType.VarChar).Value = sku
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    Dim imageRecord As New ItemMaintImageRecord
                    imageRecord.MichaelsSKU = DataHelper.SmartValues(reader.Item("Michaels_SKU"), "string", True)
                    imageRecord.VendorNumber = DataHelper.SmartValues(reader.Item("Vendor_Number"), "integer", True)
                    imageRecord.ImageID = DataHelper.SmartValues(reader.Item("Image_ID"), "integer", True)
                    imageRecord.FileData = reader.Item("File_Data")
                    imageRecord.FileSize = DataHelper.SmartValues(reader.Item("File_Size"), "integer", True)
                    imageRecord.FileName = DataHelper.SmartValues(reader.Item("File_Name"), "string", True)

                    images.Add(imageRecord)
                End While
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return images
        End Function

        Public Shared Function GetItemList(ByVal batchID As Long, ByVal startRow As Integer, ByVal pageSize As Integer, ByVal xmlSortCriteria As String, ByVal userID As Long) As ItemMaintItemDetailRecordList
            Dim objItemsList As ItemMaintItemDetailRecordList = New ItemMaintItemDetailRecordList()
            Dim objRecord As ItemMaintItemDetailFormRecord
            Dim sql As String = "usp_SPD_ItemMaint_GetList"
            Dim reader As DBReader = Nothing
            'Dim reader2 As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                conn.Open()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                cmd.Parameters.Add("@startRow", SqlDbType.Int).Value = startRow
                cmd.Parameters.Add("@pageSize", SqlDbType.Int).Value = pageSize
                cmd.Parameters.Add("@xmlSortCriteria", SqlDbType.NVarChar, -1).Value = xmlSortCriteria
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    objItemsList.TotalRecords = DataHelper.SmartValues(reader.Item("totRecords"), "integer", False)
                Else
                    objItemsList.TotalRecords = 0
                End If
                Do While bRead
                    objRecord = New ItemMaintItemDetailFormRecord()

                    LoadItemMaintRecordFromList(objRecord, reader)

                    objItemsList.ListRecords.Add(objRecord)
                    bRead = reader.Read()
                Loop
                reader.Dispose()
                reader = Nothing

                ' Get addtional Countries
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemIDs", SqlDbType.VarChar, 8000).Value = objItemsList.GetRecordIDs()
                reader.CommandText = "usp_SPD_ItemMaint_GetItemCOO"
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                If reader.HasRows Then
                    Dim countryRecord As ItemMasterVendorCountryRecord
                    Dim itemID As Integer
                    objRecord = Nothing
                    Do While reader.Read()
                        itemID = DataHelper.SmartValues(reader.Item("Item_ID"), "integer", False)
                        If objRecord Is Nothing OrElse objRecord.ID <> itemID Then
                            objRecord = objItemsList.ItemByID(itemID)
                        End If
                        If objRecord IsNot Nothing Then

                            countryRecord = New ItemMasterVendorCountryRecord()
                            With reader
                                countryRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("Country_Of_Origin"), "string", True)
                                countryRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("Country_Of_Origin_Name"), "string", True)
                            End With
                            objRecord.AddAdditionalCOO(countryRecord)

                        End If

                    Loop
                End If
                reader.Dispose()
                reader = Nothing

            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objItemsList
        End Function

        Protected Shared Sub LoadItemMaintRecord(ByRef objRecord As ItemMaintItemDetailRecord, ByRef reader As DBReader)

            With reader
                objRecord.ID = .Item("ID")
                objRecord.BatchID = DataHelper.SmartValues(.Item("BatchID"), "long", True)
                objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                'objRecord.IsValid = DataHelper.SmartValues(.Item("IsValid"), "smallint", True)
                Dim iv As Int16 = DataHelper.SmartValues(.Item("IsValid"), "smallint", True)
                If iv = 1 Then
                    objRecord.IsValid = ItemValidFlag.Valid
                ElseIf iv = 0 Then
                    objRecord.IsValid = ItemValidFlag.NotValid
                Else
                    objRecord.IsValid = ItemValidFlag.Unknown
                End If
                objRecord.SKU = DataHelper.SmartValues(.Item("SKU"), "string", True)
                objRecord.IsLockedForChange = DataHelper.SmartValues(.Item("IsLockedForChange"), "integer", True)
                objRecord.VendorNumber = DataHelper.SmartValues(.Item("VendorNumber"), "long", True)
                objRecord.BatchTypeID = DataHelper.SmartValues(.Item("BatchTypeID"), "integer", True)
                Dim vt As Integer = DataHelper.SmartValues(.Item("VendorType"), "integer", False)
                objRecord.VendorType = vt
                'If ItemType.IsDefined(GetType(ItemType), t) Then
                '    objRecord.VendorType = CType(t, ItemType)
                'Else
                '    objRecord.VendorType = ItemType.Unknown
                'End If
                objRecord.PrimaryUPC = DataHelper.SmartValues(.Item("PrimaryUPC"), "string", True)
                objRecord.VendorStyleNum = DataHelper.SmartValues(.Item("VendorStyleNum"), "string", True)
                objRecord.AdditionalUPCs = DataHelper.SmartValues(.Item("AdditionalUPCs"), "integer", True)
                objRecord.ItemDesc = DataHelper.SmartValues(.Item("ItemDesc"), "string", True)
                objRecord.ClassNum = DataHelper.SmartValues(.Item("ClassNum"), "integer", True)
                objRecord.SubClassNum = DataHelper.SmartValues(.Item("SubClassNum"), "integer", True)
                objRecord.PrivateBrandLabel = DataHelper.SmartValues(.Item("PrivateBrandLabel"), "string", True)
                objRecord.EachesMasterCase = DataHelper.SmartValues(.Item("EachesMasterCase"), "integer", True)
                objRecord.EachesInnerPack = DataHelper.SmartValues(.Item("EachesInnerPack"), "integer", True)
                objRecord.AllowStoreOrder = DataHelper.SmartValues(.Item("AllowStoreOrder"), "string", True)
                objRecord.InventoryControl = DataHelper.SmartValues(.Item("InventoryControl"), "string", True)
                objRecord.AutoReplenish = DataHelper.SmartValues(.Item("AutoReplenish"), "string", True)
                objRecord.PrePriced = DataHelper.SmartValues(.Item("PrePriced"), "string", True)
                objRecord.PrePricedUDA = DataHelper.SmartValues(.Item("PrePricedUDA"), "string", True)
                objRecord.ItemCost = DataHelper.SmartValues(.Item("ItemCost"), "decimal", True)

                'PMO200141 GTIN14 Enhancements changes
                objRecord.InnerGTIN = DataHelper.SmartValues(.Item("InnerGTIN"), "string", True)
                objRecord.CaseGTIN = DataHelper.SmartValues(.Item("CaseGTIN"), "string", True)

                objRecord.EachCaseHeight = DataHelper.SmartValues(.Item("EachCaseHeight"), "decimal", True)
                objRecord.EachCaseWidth = DataHelper.SmartValues(.Item("EachCaseWidth"), "decimal", True)
                objRecord.EachCaseLength = DataHelper.SmartValues(.Item("EachCaseLength"), "decimal", True)
                objRecord.EachCaseCube = DataHelper.SmartValues(.Item("EachCaseCube"), "decimal", True)
                objRecord.EachCaseWeight = DataHelper.SmartValues(.Item("EachCaseWeight"), "decimal", True)
                objRecord.EachCaseCubeUOM = DataHelper.SmartValues(.Item("EachCaseCubeUOM"), "string", True)
                objRecord.EachCaseWeightUOM = DataHelper.SmartValues(.Item("EachCaseWeightUOM"), "string", True)

                objRecord.InnerCaseHeight = DataHelper.SmartValues(.Item("InnerCaseHeight"), "decimal", True)
                objRecord.InnerCaseWidth = DataHelper.SmartValues(.Item("InnerCaseWidth"), "decimal", True)
                objRecord.InnerCaseLength = DataHelper.SmartValues(.Item("InnerCaseLength"), "decimal", True)
                objRecord.InnerCaseCube = DataHelper.SmartValues(.Item("InnerCaseCube"), "decimal", True)
                objRecord.InnerCaseWeight = DataHelper.SmartValues(.Item("InnerCaseWeight"), "decimal", True)
                objRecord.InnerCaseCubeUOM = DataHelper.SmartValues(.Item("InnerCaseCubeUOM"), "string", True)
                objRecord.InnerCaseWeightUOM = DataHelper.SmartValues(.Item("InnerCaseWeightUOM"), "string", True)
                objRecord.MasterCaseHeight = DataHelper.SmartValues(.Item("MasterCaseHeight"), "decimal", True)
                objRecord.MasterCaseWidth = DataHelper.SmartValues(.Item("MasterCaseWidth"), "decimal", True)
                objRecord.MasterCaseLength = DataHelper.SmartValues(.Item("MasterCaseLength"), "decimal", True)
                objRecord.MasterCaseWeight = DataHelper.SmartValues(.Item("MasterCaseWeight"), "decimal", True)
                objRecord.MasterCaseCube = DataHelper.SmartValues(.Item("MasterCaseCube"), "decimal", True)
                objRecord.MasterCaseCubeUOM = DataHelper.SmartValues(.Item("MasterCaseCubeUOM"), "string", True)
                objRecord.MasterCaseWeightUOM = DataHelper.SmartValues(.Item("MasterCaseWeightUOM"), "string", True)
                objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("CountryOfOrigin"), "string", True)
                objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("CountryOfOriginName"), "string", True)
                objRecord.TaxUDA = DataHelper.SmartValues(.Item("TaxUDA"), "string", True)
                objRecord.TaxValueUDA = DataHelper.SmartValues(.Item("TaxValueUDA"), "long", True)
                objRecord.Discountable = DataHelper.SmartValues(.Item("Discountable"), "string", True)
                objRecord.ImportBurden = DataHelper.SmartValues(.Item("ImportBurden"), "decimal", True)
                objRecord.ShippingPoint = DataHelper.SmartValues(.Item("ShippingPoint"), "string", True)
                objRecord.PlanogramName = DataHelper.SmartValues(.Item("PlanogramName"), "string", True)
                objRecord.Hazardous = DataHelper.SmartValues(.Item("Hazardous"), "string", True)
                objRecord.HazardousFlammable = DataHelper.SmartValues(.Item("HazardousFlammable"), "string", True)
                objRecord.HazardousContainerType = DataHelper.SmartValues(.Item("HazardousContainerType"), "string", True)
                objRecord.HazardousContainerSize = DataHelper.SmartValues(.Item("HazardousContainerSize"), "decimal", True)
                objRecord.MSDSID = DataHelper.SmartValues(.Item("MSDSID"), "long", True)
                objRecord.ImageID = DataHelper.SmartValues(.Item("ImageID"), "long", True)
                objRecord.Buyer = DataHelper.SmartValues(.Item("Buyer"), "string", True)
                objRecord.BuyerFax = DataHelper.SmartValues(.Item("BuyerFax"), "string", True)
                objRecord.BuyerEmail = DataHelper.SmartValues(.Item("BuyerEmail"), "string", True)
                objRecord.Season = DataHelper.SmartValues(.Item("Season"), "string", True)
                objRecord.SKUGroup = DataHelper.SmartValues(.Item("SKUGroup"), "string", True)
                objRecord.PackSKU = DataHelper.SmartValues(.Item("PackSKU"), "string", True)
                objRecord.StockCategory = DataHelper.SmartValues(.Item("StockCategory"), "string", True)
                objRecord.CoinBattery = DataHelper.SmartValues(.Item("CoinBattery"), "string", True)
                objRecord.TSSA = DataHelper.SmartValues(.Item("TSSA"), "string", True)
                objRecord.CSA = DataHelper.SmartValues(.Item("CSA"), "string", True)
                objRecord.UL = DataHelper.SmartValues(.Item("UL"), "string", True)
                objRecord.LicenceAgreement = DataHelper.SmartValues(.Item("LicenceAgreement"), "string", True)
                objRecord.FumigationCertificate = DataHelper.SmartValues(.Item("FumigationCertificate"), "string", True)
                objRecord.PhytoTemporaryShipment = DataHelper.SmartValues(.Item("PhytoTemporaryShipment"), "string", True)
                objRecord.KILNDriedCertificate = DataHelper.SmartValues(.Item("KILNDriedCertificate"), "string", True)
                objRecord.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(.Item("ChinaComInspecNumAndCCIBStickers"), "string", True)
                objRecord.OriginalVisa = DataHelper.SmartValues(.Item("OriginalVisa"), "string", True)
                objRecord.TextileDeclarationMidCode = DataHelper.SmartValues(.Item("TextileDeclarationMidCode"), "string", True)
                objRecord.QuotaChargeStatement = DataHelper.SmartValues(.Item("QuotaChargeStatement"), "string", True)
                objRecord.MSDS = DataHelper.SmartValues(.Item("MSDS"), "string", True)
                objRecord.TSCA = DataHelper.SmartValues(.Item("TSCA"), "string", True)
                objRecord.DropBallTestCert = DataHelper.SmartValues(.Item("DropBallTestCert"), "string", True)
                objRecord.ManMedicalDeviceListing = DataHelper.SmartValues(.Item("ManMedicalDeviceListing"), "string", True)
                objRecord.ManFDARegistration = DataHelper.SmartValues(.Item("ManFDARegistration"), "string", True)
                objRecord.CopyRightIndemnification = DataHelper.SmartValues(.Item("CopyRightIndemnification"), "string", True)
                objRecord.FishWildLifeCert = DataHelper.SmartValues(.Item("FishWildLifeCert"), "string", True)
                objRecord.Proposition65LabelReq = DataHelper.SmartValues(.Item("Proposition65LabelReq"), "string", True)
                objRecord.CCCR = DataHelper.SmartValues(.Item("CCCR"), "string", True)
                objRecord.FormaldehydeCompliant = DataHelper.SmartValues(.Item("FormaldehydeCompliant"), "string", True)
                objRecord.RMSSellable = DataHelper.SmartValues(.Item("RMSSellable"), "string", True)
                objRecord.RMSOrderable = DataHelper.SmartValues(.Item("RMSOrderable"), "string", True)
                objRecord.RMSInventory = DataHelper.SmartValues(.Item("RMSInventory"), "string", True)
                objRecord.StoreTotal = DataHelper.SmartValues(.Item("StoreTotal"), "integer", True)
                objRecord.DisplayerCost = DataHelper.SmartValues(.Item("DisplayerCost"), "decimal", True)
                objRecord.ProductCost = DataHelper.SmartValues(.Item("ProductCost"), "decimal", True)
                objRecord.AddChange = DataHelper.SmartValues(.Item("AddChange"), "string", True)
                objRecord.POGSetupPerStore = DataHelper.SmartValues(.Item("POGSetupPerStore"), "decimal", True)
                objRecord.POGMaxQty = DataHelper.SmartValues(.Item("POGMaxQty"), "decimal", True)
                objRecord.ProjectedUnitSales = DataHelper.SmartValues(.Item("ProjectedUnitSales"), "decimal", True)
                objRecord.VendorOrAgent = DataHelper.SmartValues(.Item("VendorOrAgent"), "string", True)
                objRecord.AgentType = DataHelper.SmartValues(.Item("AgentType"), "string", True)
                objRecord.PaymentTerms = DataHelper.SmartValues(.Item("PaymentTerms"), "string", True)
                objRecord.Days = DataHelper.SmartValues(.Item("Days"), "string", True)
                objRecord.VendorMinOrderAmount = DataHelper.SmartValues(.Item("VendorMinOrderAmount"), "string", True)
                objRecord.VendorName = DataHelper.SmartValues(.Item("VendorName"), "string", True)
                objRecord.VendorAddress1 = DataHelper.SmartValues(.Item("VendorAddress1"), "string", True)
                objRecord.VendorAddress2 = DataHelper.SmartValues(.Item("VendorAddress2"), "string", True)
                objRecord.VendorAddress3 = DataHelper.SmartValues(.Item("VendorAddress3"), "string", True)
                objRecord.VendorAddress4 = DataHelper.SmartValues(.Item("VendorAddress4"), "string", True)
                objRecord.VendorContactName = DataHelper.SmartValues(.Item("VendorContactName"), "string", True)
                objRecord.VendorContactPhone = DataHelper.SmartValues(.Item("VendorContactPhone"), "string", True)
                objRecord.VendorContactEmail = DataHelper.SmartValues(.Item("VendorContactEmail"), "string", True)
                objRecord.VendorContactFax = DataHelper.SmartValues(.Item("VendorContactFax"), "string", True)
                objRecord.ManufactureName = DataHelper.SmartValues(.Item("ManufactureName"), "string", True)
                objRecord.ManufactureAddress1 = DataHelper.SmartValues(.Item("ManufactureAddress1"), "string", True)
                objRecord.ManufactureAddress2 = DataHelper.SmartValues(.Item("ManufactureAddress2"), "string", True)
                objRecord.ManufactureContact = DataHelper.SmartValues(.Item("ManufactureContact"), "string", True)
                objRecord.ManufacturePhone = DataHelper.SmartValues(.Item("ManufacturePhone"), "string", True)
                objRecord.ManufactureEmail = DataHelper.SmartValues(.Item("ManufactureEmail"), "string", True)
                objRecord.ManufactureFax = DataHelper.SmartValues(.Item("ManufactureFax"), "string", True)
                objRecord.AgentContact = DataHelper.SmartValues(.Item("AgentContact"), "string", True)
                objRecord.AgentPhone = DataHelper.SmartValues(.Item("AgentPhone"), "string", True)
                objRecord.AgentEmail = DataHelper.SmartValues(.Item("AgentEmail"), "string", True)
                objRecord.AgentFax = DataHelper.SmartValues(.Item("AgentFax"), "string", True)
                objRecord.HarmonizedCodeNumber = DataHelper.SmartValues(.Item("HarmonizedCodeNumber"), "string", True)
                objRecord.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(.Item("CanadaHarmonizedCodeNumber"), "string", True)
                objRecord.DetailInvoiceCustomsDesc = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc"), "string", True)
                objRecord.ComponentMaterialBreakdown = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown"), "string", True)
                objRecord.ComponentConstructionMethod = DataHelper.SmartValues(.Item("ComponentConstructionMethod"), "string", True)
                objRecord.IndividualItemPackaging = DataHelper.SmartValues(.Item("IndividualItemPackaging"), "string", True)
                objRecord.FOBShippingPoint = DataHelper.SmartValues(.Item("FOBShippingPoint"), "decimal", True)
                objRecord.DutyPercent = DataHelper.SmartValues(.Item("DutyPercent"), "decimal", True)
                objRecord.DutyAmount = DataHelper.SmartValues(.Item("DutyAmount"), "decimal", True)
                objRecord.AdditionalDutyComment = DataHelper.SmartValues(.Item("AdditionalDutyComment"), "string", True)
                objRecord.AdditionalDutyAmount = DataHelper.SmartValues(.Item("AdditionalDutyAmount"), "decimal", True)

                objRecord.SuppTariffPercent = DataHelper.SmartValues(.Item("SuppTariffPercent"), "decimal", True)
                objRecord.SuppTariffAmount = DataHelper.SmartValues(.Item("SuppTariffAmount"), "decimal", True)

                objRecord.OceanFreightAmount = DataHelper.SmartValues(.Item("OceanFreightAmount"), "decimal", True)
                objRecord.OceanFreightComputedAmount = DataHelper.SmartValues(.Item("OceanFreightComputedAmount"), "decimal", True)
                objRecord.AgentCommissionPercent = DataHelper.SmartValues(.Item("AgentCommissionPercent"), "decimal", True)
                objRecord.AgentCommissionAmount = DataHelper.SmartValues(.Item("AgentCommissionAmount"), "decimal", True)
                objRecord.OtherImportCostsPercent = DataHelper.SmartValues(.Item("OtherImportCostsPercent"), "decimal", True)
                objRecord.OtherImportCostsAmount = DataHelper.SmartValues(.Item("OtherImportCostsAmount"), "decimal", True)
                objRecord.PackagingCostAmount = DataHelper.SmartValues(.Item("PackagingCostAmount"), "decimal", True)
                objRecord.WarehouseLandedCost = DataHelper.SmartValues(.Item("WarehouseLandedCost"), "decimal", True)
                objRecord.PurchaseOrderIssuedTo = DataHelper.SmartValues(.Item("PurchaseOrderIssuedTo"), "string", True)
                objRecord.VendorComments = DataHelper.SmartValues(.Item("VendorComments"), "string", True)
                objRecord.FreightTerms = DataHelper.SmartValues(.Item("FreightTerms"), "string", True)
                objRecord.OutboundFreight = DataHelper.SmartValues(.Item("OutboundFreight"), "decimal", True)
                objRecord.NinePercentWhseCharge = DataHelper.SmartValues(.Item("NinePercentWhseCharge"), "decimal", True)
                objRecord.TotalStoreLandedCost = DataHelper.SmartValues(.Item("TotalStoreLandedCost"), "decimal", True)
                objRecord.UpdateUserID = DataHelper.SmartValues(.Item("UpdateUserID"), "integer", True)
                objRecord.DateLastModified = DataHelper.SmartValues(.Item("DateLastModified"), "date", True)
                objRecord.UpdateUserName = DataHelper.SmartValues(.Item("UpdateUserName"), "string", True)
                objRecord.StoreSupplierZoneGroup = DataHelper.SmartValues(.Item("StoreSupplierZoneGroup"), "string", True)
                objRecord.WHSSupplierZoneGroup = DataHelper.SmartValues(.Item("WHSSupplierZoneGroup"), "string", True)
                objRecord.PackItemIndicator = DataHelper.SmartValues(.Item("PackItemIndicator"), "string", True)
                objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("ItemTypeAttribute"), "string", True)
                objRecord.HybridType = DataHelper.SmartValues(.Item("HybridType"), "string", True)
                objRecord.HybridSourceDC = DataHelper.SmartValues(.Item("HybridSourceDC"), "string", True)
                objRecord.HazardousMSDSUOM = DataHelper.SmartValues(.Item("HazardousMSDSUOM"), "string", True)
                objRecord.DetailInvoiceCustomsDesc0 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc0"), "string", True)
                objRecord.DetailInvoiceCustomsDesc1 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc1"), "string", True)
                objRecord.DetailInvoiceCustomsDesc2 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc2"), "string", True)
                objRecord.DetailInvoiceCustomsDesc3 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc3"), "string", True)
                objRecord.DetailInvoiceCustomsDesc4 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc4"), "string", True)
                objRecord.DetailInvoiceCustomsDesc5 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc5"), "string", True)
                objRecord.ComponentMaterialBreakdown0 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown0"), "string", True)
                objRecord.ComponentMaterialBreakdown1 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown1"), "string", True)
                objRecord.ComponentMaterialBreakdown2 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown2"), "string", True)
                objRecord.ComponentMaterialBreakdown3 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown3"), "string", True)
                objRecord.ComponentMaterialBreakdown4 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown4"), "string", True)
                objRecord.ComponentConstructionMethod0 = DataHelper.SmartValues(.Item("ComponentConstructionMethod0"), "string", True)
                objRecord.ComponentConstructionMethod1 = DataHelper.SmartValues(.Item("ComponentConstructionMethod1"), "string", True)
                objRecord.ComponentConstructionMethod2 = DataHelper.SmartValues(.Item("ComponentConstructionMethod2"), "string", True)
                objRecord.ComponentConstructionMethod3 = DataHelper.SmartValues(.Item("ComponentConstructionMethod3"), "string", True)
                objRecord.DepartmentNum = DataHelper.SmartValues(.Item("DepartmentNum"), "integer", True)
                objRecord.Base1Retail = DataHelper.SmartValues(.Item("Base1Retail"), "decimal", True)
                objRecord.Base2Retail = DataHelper.SmartValues(.Item("Base2Retail"), "decimal", True)
                objRecord.Base3Retail = DataHelper.SmartValues(.Item("Base3Retail"), "decimal", True)
                objRecord.TestRetail = DataHelper.SmartValues(.Item("TestRetail"), "decimal", True)
                objRecord.AlaskaRetail = DataHelper.SmartValues(.Item("AlaskaRetail"), "decimal", True)
                objRecord.CanadaRetail = DataHelper.SmartValues(.Item("CanadaRetail"), "decimal", True)
                objRecord.High1Retail = DataHelper.SmartValues(.Item("High1Retail"), "decimal", True)
                objRecord.High2Retail = DataHelper.SmartValues(.Item("High2Retail"), "decimal", True)
                objRecord.High3Retail = DataHelper.SmartValues(.Item("High3Retail"), "decimal", True)
                objRecord.SmallMarketRetail = DataHelper.SmartValues(.Item("SmallMarketRetail"), "decimal", True)
                objRecord.Low1Retail = DataHelper.SmartValues(.Item("Low1Retail"), "decimal", True)
                objRecord.Low2Retail = DataHelper.SmartValues(.Item("Low2Retail"), "decimal", True)
                objRecord.ManhattanRetail = DataHelper.SmartValues(.Item("ManhattanRetail"), "decimal", True)
                objRecord.QuebecRetail = DataHelper.SmartValues(.Item("QuebecRetail"), "decimal", True)
                objRecord.PuertoRicoRetail = DataHelper.SmartValues(.Item("PuertoRicoRetail"), "decimal", True)
                objRecord.HazardousManufacturerName = DataHelper.SmartValues(.Item("HazardousManufacturerName"), "string", True)
                objRecord.HazardousManufacturerCity = DataHelper.SmartValues(.Item("HazardousManufacturerCity"), "string", True)
                objRecord.HazardousManufacturerState = DataHelper.SmartValues(.Item("HazardousManufacturerState"), "string", True)
                objRecord.HazardousManufacturerPhone = DataHelper.SmartValues(.Item("HazardousManufacturerPhone"), "string", True)
                objRecord.HazardousManufacturerCountry = DataHelper.SmartValues(.Item("HazardousManufacturerCountry"), "string", True)
                objRecord.ItemType = DataHelper.SmartValues(.Item("ItemType"), "string", True)
                objRecord.QtyInPack = DataHelper.SmartValues(.Item("QtyInPack"), "integer", True)
                objRecord.PrimaryVendor = DataHelper.SmartValues(.Item("PrimaryVendor"), "boolean", True)
                objRecord.ItemStatus = DataHelper.SmartValues(.Item("ItemStatus"), "string", True)
                objRecord.Base1Clearance = DataHelper.SmartValues(.Item("Base1Clearance"), "decimal", True)
                objRecord.Base2Clearance = DataHelper.SmartValues(.Item("Base2Clearance"), "decimal", True)
                objRecord.Base3Clearance = DataHelper.SmartValues(.Item("Base3Clearance"), "decimal", True)
                objRecord.TestClearance = DataHelper.SmartValues(.Item("TestClearance"), "decimal", True)
                objRecord.AlaskaClearance = DataHelper.SmartValues(.Item("AlaskaClearance"), "decimal", True)
                objRecord.CanadaClearance = DataHelper.SmartValues(.Item("CanadaClearance"), "decimal", True)
                objRecord.High1Clearance = DataHelper.SmartValues(.Item("High1Clearance"), "decimal", True)
                objRecord.High2Clearance = DataHelper.SmartValues(.Item("High2Clearance"), "decimal", True)
                objRecord.High3Clearance = DataHelper.SmartValues(.Item("High3Clearance"), "decimal", True)
                objRecord.SmallMarketClearance = DataHelper.SmartValues(.Item("SmallMarketClearance"), "decimal", True)
                objRecord.Low1Clearance = DataHelper.SmartValues(.Item("Low1Clearance"), "decimal", True)
                objRecord.Low2Clearance = DataHelper.SmartValues(.Item("Low2Clearance"), "decimal", True)
                objRecord.ManhattanClearance = DataHelper.SmartValues(.Item("ManhattanClearance"), "decimal", True)
                objRecord.QuebecClearance = DataHelper.SmartValues(.Item("QuebecClearance"), "decimal", True)
                objRecord.PuertoRicoClearance = DataHelper.SmartValues(.Item("PuertoRicoClearance"), "decimal", True)
                objRecord.FutureCostExists = DataHelper.SmartValues(.Item("FutureCostExists"), "boolean", True)
                objRecord.QuoteSheetItemType = DataHelper.SmartValues(.Item("QuoteSheetItemType"), "string", True)
                objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", True)
                objRecord.CustomsDescription = DataHelper.SmartValues(.Item("CustomsDescription"), "string", True)
                objRecord.StockingStrategyCode = DataHelper.SmartValues(.Item("STOCKINGSTRATEGYCODE"), "string", True)

                objRecord.MinimumOrderQuantity = DataHelper.SmartValues(.Item("MinimumOrderQuantity"), "integer", True)
                objRecord.ProductIdentifiesAsCosmetic = DataHelper.SmartValues(.Item("ProductIdentifiesAsCosmetic"), "string", True)
            End With

        End Sub

        Protected Shared Sub LoadItemMaintRecordFromList(ByRef objRecord As ItemMaintItemDetailRecord, ByRef reader As DBReader)

            With reader
                objRecord.ID = .Item("ID")
                objRecord.BatchID = DataHelper.SmartValues(.Item("BatchID"), "long", True)
                objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                'objRecord.IsValid = DataHelper.SmartValues(.Item("IsValid"), "smallint", True)
                Dim iv As Int16 = DataHelper.SmartValues(.Item("IsValid"), "smallint", True)
                If iv = 1 Then
                    objRecord.IsValid = ItemValidFlag.Valid
                ElseIf iv = 0 Then
                    objRecord.IsValid = ItemValidFlag.NotValid
                Else
                    objRecord.IsValid = ItemValidFlag.Unknown
                End If
                objRecord.SKU = DataHelper.SmartValues(.Item("SKU"), "string", True)
                objRecord.IsLockedForChange = DataHelper.SmartValues(.Item("IsLockedForChange"), "integer", True)
                objRecord.VendorNumber = DataHelper.SmartValues(.Item("VendorNumber"), "long", True)
                objRecord.BatchTypeID = DataHelper.SmartValues(.Item("BatchTypeID"), "integer", True)
                Dim vt As Integer = DataHelper.SmartValues(.Item("VendorType"), "integer", False)
                objRecord.VendorType = vt
                'If ItemType.IsDefined(GetType(ItemType), t) Then
                '    objRecord.VendorType = CType(t, ItemType)
                'Else
                '    objRecord.VendorType = ItemType.Unknown
                'End If
                objRecord.PrimaryUPC = DataHelper.SmartValues(.Item("PrimaryUPC"), "string", True)
                objRecord.VendorStyleNum = DataHelper.SmartValues(.Item("VendorStyleNum"), "string", True)
                objRecord.AdditionalUPCs = DataHelper.SmartValues(.Item("AdditionalUPCs"), "integer", True)
                objRecord.ItemDesc = DataHelper.SmartValues(.Item("ItemDesc"), "string", True)
                objRecord.ClassNum = DataHelper.SmartValues(.Item("ClassNum"), "integer", True)
                objRecord.SubClassNum = DataHelper.SmartValues(.Item("SubClassNum"), "integer", True)
                objRecord.PrivateBrandLabel = DataHelper.SmartValues(.Item("PrivateBrandLabel"), "string", True)
                objRecord.EachesMasterCase = DataHelper.SmartValues(.Item("EachesMasterCase"), "integer", True)
                objRecord.EachesInnerPack = DataHelper.SmartValues(.Item("EachesInnerPack"), "integer", True)
                objRecord.AllowStoreOrder = DataHelper.SmartValues(.Item("AllowStoreOrder"), "string", True)
                objRecord.InventoryControl = DataHelper.SmartValues(.Item("InventoryControl"), "string", True)
                objRecord.AutoReplenish = DataHelper.SmartValues(.Item("AutoReplenish"), "string", True)
                objRecord.PrePriced = DataHelper.SmartValues(.Item("PrePriced"), "string", True)
                objRecord.PrePricedUDA = DataHelper.SmartValues(.Item("PrePricedUDA"), "string", True)
                objRecord.ItemCost = DataHelper.SmartValues(.Item("ItemCost"), "decimal", True)
                objRecord.InnerCaseHeight = DataHelper.SmartValues(.Item("InnerCaseHeight"), "decimal", True)
                objRecord.InnerCaseWidth = DataHelper.SmartValues(.Item("InnerCaseWidth"), "decimal", True)
                objRecord.InnerCaseLength = DataHelper.SmartValues(.Item("InnerCaseLength"), "decimal", True)
                objRecord.InnerCaseCube = DataHelper.SmartValues(.Item("InnerCaseCube"), "decimal", True)
                objRecord.InnerCaseWeight = DataHelper.SmartValues(.Item("InnerCaseWeight"), "decimal", True)
                objRecord.InnerCaseCubeUOM = DataHelper.SmartValues(.Item("InnerCaseCubeUOM"), "string", True)
                objRecord.InnerCaseWeightUOM = DataHelper.SmartValues(.Item("InnerCaseWeightUOM"), "string", True)
                objRecord.MasterCaseHeight = DataHelper.SmartValues(.Item("MasterCaseHeight"), "decimal", True)
                objRecord.MasterCaseWidth = DataHelper.SmartValues(.Item("MasterCaseWidth"), "decimal", True)
                objRecord.MasterCaseLength = DataHelper.SmartValues(.Item("MasterCaseLength"), "decimal", True)
                objRecord.MasterCaseWeight = DataHelper.SmartValues(.Item("MasterCaseWeight"), "decimal", True)
                objRecord.MasterCaseCube = DataHelper.SmartValues(.Item("MasterCaseCube"), "decimal", True)
                objRecord.MasterCaseCubeUOM = DataHelper.SmartValues(.Item("MasterCaseCubeUOM"), "string", True)
                objRecord.MasterCaseWeightUOM = DataHelper.SmartValues(.Item("MasterCaseWeightUOM"), "string", True)
                objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("CountryOfOrigin"), "string", True)
                objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("CountryOfOriginName"), "string", True)
                objRecord.TaxUDA = DataHelper.SmartValues(.Item("TaxUDA"), "string", True)
                objRecord.TaxValueUDA = DataHelper.SmartValues(.Item("TaxValueUDA"), "long", True)
                objRecord.Discountable = DataHelper.SmartValues(.Item("Discountable"), "string", True)
                objRecord.ImportBurden = DataHelper.SmartValues(.Item("ImportBurden"), "decimal", True)
                objRecord.ShippingPoint = DataHelper.SmartValues(.Item("ShippingPoint"), "string", True)
                objRecord.PlanogramName = DataHelper.SmartValues(.Item("PlanogramName"), "string", True)
                objRecord.Hazardous = DataHelper.SmartValues(.Item("Hazardous"), "string", True)
                objRecord.HazardousFlammable = DataHelper.SmartValues(.Item("HazardousFlammable"), "string", True)
                objRecord.HazardousContainerType = DataHelper.SmartValues(.Item("HazardousContainerType"), "string", True)
                objRecord.HazardousContainerSize = DataHelper.SmartValues(.Item("HazardousContainerSize"), "decimal", True)
                objRecord.MSDSID = DataHelper.SmartValues(.Item("MSDSID"), "long", True)
                objRecord.ImageID = DataHelper.SmartValues(.Item("ImageID"), "long", True)
                objRecord.Buyer = DataHelper.SmartValues(.Item("Buyer"), "string", True)
                objRecord.BuyerFax = DataHelper.SmartValues(.Item("BuyerFax"), "string", True)
                objRecord.BuyerEmail = DataHelper.SmartValues(.Item("BuyerEmail"), "string", True)
                objRecord.Season = DataHelper.SmartValues(.Item("Season"), "string", True)
                objRecord.SKUGroup = DataHelper.SmartValues(.Item("SKUGroup"), "string", True)
                objRecord.PackSKU = DataHelper.SmartValues(.Item("PackSKU"), "string", True)
                objRecord.StockCategory = DataHelper.SmartValues(.Item("StockCategory"), "string", True)
                objRecord.CoinBattery = DataHelper.SmartValues(.Item("CoinBattery"), "string", True)
                objRecord.TSSA = DataHelper.SmartValues(.Item("TSSA"), "string", True)
                objRecord.CSA = DataHelper.SmartValues(.Item("CSA"), "string", True)
                objRecord.UL = DataHelper.SmartValues(.Item("UL"), "string", True)
                objRecord.LicenceAgreement = DataHelper.SmartValues(.Item("LicenceAgreement"), "string", True)
                objRecord.FumigationCertificate = DataHelper.SmartValues(.Item("FumigationCertificate"), "string", True)
                objRecord.PhytoTemporaryShipment = DataHelper.SmartValues(.Item("PhytoTemporaryShipment"), "string", True)
                objRecord.KILNDriedCertificate = DataHelper.SmartValues(.Item("KILNDriedCertificate"), "string", True)
                objRecord.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(.Item("ChinaComInspecNumAndCCIBStickers"), "string", True)
                objRecord.OriginalVisa = DataHelper.SmartValues(.Item("OriginalVisa"), "string", True)
                objRecord.TextileDeclarationMidCode = DataHelper.SmartValues(.Item("TextileDeclarationMidCode"), "string", True)
                objRecord.QuotaChargeStatement = DataHelper.SmartValues(.Item("QuotaChargeStatement"), "string", True)
                objRecord.MSDS = DataHelper.SmartValues(.Item("MSDS"), "string", True)
                objRecord.TSCA = DataHelper.SmartValues(.Item("TSCA"), "string", True)
                objRecord.DropBallTestCert = DataHelper.SmartValues(.Item("DropBallTestCert"), "string", True)
                objRecord.ManMedicalDeviceListing = DataHelper.SmartValues(.Item("ManMedicalDeviceListing"), "string", True)
                objRecord.ManFDARegistration = DataHelper.SmartValues(.Item("ManFDARegistration"), "string", True)
                objRecord.CopyRightIndemnification = DataHelper.SmartValues(.Item("CopyRightIndemnification"), "string", True)
                objRecord.FishWildLifeCert = DataHelper.SmartValues(.Item("FishWildLifeCert"), "string", True)
                objRecord.Proposition65LabelReq = DataHelper.SmartValues(.Item("Proposition65LabelReq"), "string", True)
                objRecord.CCCR = DataHelper.SmartValues(.Item("CCCR"), "string", True)
                objRecord.FormaldehydeCompliant = DataHelper.SmartValues(.Item("FormaldehydeCompliant"), "string", True)
                objRecord.RMSSellable = DataHelper.SmartValues(.Item("RMSSellable"), "string", True)
                objRecord.RMSOrderable = DataHelper.SmartValues(.Item("RMSOrderable"), "string", True)
                objRecord.RMSInventory = DataHelper.SmartValues(.Item("RMSInventory"), "string", True)
                objRecord.StoreTotal = DataHelper.SmartValues(.Item("StoreTotal"), "integer", True)
                objRecord.DisplayerCost = DataHelper.SmartValues(.Item("DisplayerCost"), "decimal", True)
                objRecord.ProductCost = DataHelper.SmartValues(.Item("ProductCost"), "decimal", True)
                objRecord.AddChange = DataHelper.SmartValues(.Item("AddChange"), "string", True)
                objRecord.POGSetupPerStore = DataHelper.SmartValues(.Item("POGSetupPerStore"), "decimal", True)
                objRecord.POGMaxQty = DataHelper.SmartValues(.Item("POGMaxQty"), "decimal", True)
                objRecord.ProjectedUnitSales = DataHelper.SmartValues(.Item("ProjectedUnitSales"), "decimal", True)
                objRecord.VendorOrAgent = DataHelper.SmartValues(.Item("VendorOrAgent"), "string", True)
                objRecord.AgentType = DataHelper.SmartValues(.Item("AgentType"), "string", True)
                objRecord.PaymentTerms = DataHelper.SmartValues(.Item("PaymentTerms"), "string", True)
                objRecord.Days = DataHelper.SmartValues(.Item("Days"), "string", True)
                objRecord.VendorMinOrderAmount = DataHelper.SmartValues(.Item("VendorMinOrderAmount"), "string", True)
                objRecord.VendorName = DataHelper.SmartValues(.Item("VendorName"), "string", True)
                objRecord.VendorAddress1 = DataHelper.SmartValues(.Item("VendorAddress1"), "string", True)
                objRecord.VendorAddress2 = DataHelper.SmartValues(.Item("VendorAddress2"), "string", True)
                objRecord.VendorAddress3 = DataHelper.SmartValues(.Item("VendorAddress3"), "string", True)
                objRecord.VendorAddress4 = DataHelper.SmartValues(.Item("VendorAddress4"), "string", True)
                objRecord.VendorContactName = DataHelper.SmartValues(.Item("VendorContactName"), "string", True)
                objRecord.VendorContactPhone = DataHelper.SmartValues(.Item("VendorContactPhone"), "string", True)
                objRecord.VendorContactEmail = DataHelper.SmartValues(.Item("VendorContactEmail"), "string", True)
                objRecord.VendorContactFax = DataHelper.SmartValues(.Item("VendorContactFax"), "string", True)
                objRecord.ManufactureName = DataHelper.SmartValues(.Item("ManufactureName"), "string", True)
                objRecord.ManufactureAddress1 = DataHelper.SmartValues(.Item("ManufactureAddress1"), "string", True)
                objRecord.ManufactureAddress2 = DataHelper.SmartValues(.Item("ManufactureAddress2"), "string", True)
                objRecord.ManufactureContact = DataHelper.SmartValues(.Item("ManufactureContact"), "string", True)
                objRecord.ManufacturePhone = DataHelper.SmartValues(.Item("ManufacturePhone"), "string", True)
                objRecord.ManufactureEmail = DataHelper.SmartValues(.Item("ManufactureEmail"), "string", True)
                objRecord.ManufactureFax = DataHelper.SmartValues(.Item("ManufactureFax"), "string", True)
                objRecord.AgentContact = DataHelper.SmartValues(.Item("AgentContact"), "string", True)
                objRecord.AgentPhone = DataHelper.SmartValues(.Item("AgentPhone"), "string", True)
                objRecord.AgentEmail = DataHelper.SmartValues(.Item("AgentEmail"), "string", True)
                objRecord.AgentFax = DataHelper.SmartValues(.Item("AgentFax"), "string", True)
                objRecord.HarmonizedCodeNumber = DataHelper.SmartValues(.Item("HarmonizedCodeNumber"), "string", True)
                objRecord.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(.Item("CanadaHarmonizedCodeNumber"), "string", True)
                objRecord.DetailInvoiceCustomsDesc = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc"), "string", True)
                objRecord.ComponentMaterialBreakdown = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown"), "string", True)
                objRecord.ComponentConstructionMethod = DataHelper.SmartValues(.Item("ComponentConstructionMethod"), "string", True)
                objRecord.IndividualItemPackaging = DataHelper.SmartValues(.Item("IndividualItemPackaging"), "string", True)
                objRecord.FOBShippingPoint = DataHelper.SmartValues(.Item("FOBShippingPoint"), "decimal", True)
                objRecord.DutyPercent = DataHelper.SmartValues(.Item("DutyPercent"), "decimal", True)
                objRecord.DutyAmount = DataHelper.SmartValues(.Item("DutyAmount"), "decimal", True)
                objRecord.AdditionalDutyComment = DataHelper.SmartValues(.Item("AdditionalDutyComment"), "string", True)
                objRecord.AdditionalDutyAmount = DataHelper.SmartValues(.Item("AdditionalDutyAmount"), "decimal", True)

                'PMO200141 GTIN14 Enhancements changes
                objRecord.InnerGTIN = DataHelper.SmartValues(.Item("InnerGTIN"), "string", True)
                objRecord.CaseGTIN = DataHelper.SmartValues(.Item("CaseGTIN"), "string", True)

                objRecord.SuppTariffPercent = DataHelper.SmartValues(.Item("SuppTariffPercent"), "decimal", True)
                objRecord.SuppTariffAmount = DataHelper.SmartValues(.Item("SuppTariffAmount"), "decimal", True)

                objRecord.OceanFreightAmount = DataHelper.SmartValues(.Item("OceanFreightAmount"), "decimal", True)
                objRecord.OceanFreightComputedAmount = DataHelper.SmartValues(.Item("OceanFreightComputedAmount"), "decimal", True)
                objRecord.AgentCommissionPercent = DataHelper.SmartValues(.Item("AgentCommissionPercent"), "decimal", True)
                objRecord.AgentCommissionAmount = DataHelper.SmartValues(.Item("AgentCommissionAmount"), "decimal", True)
                objRecord.OtherImportCostsPercent = DataHelper.SmartValues(.Item("OtherImportCostsPercent"), "decimal", True)
                objRecord.OtherImportCostsAmount = DataHelper.SmartValues(.Item("OtherImportCostsAmount"), "decimal", True)
                objRecord.PackagingCostAmount = DataHelper.SmartValues(.Item("PackagingCostAmount"), "decimal", True)
                objRecord.WarehouseLandedCost = DataHelper.SmartValues(.Item("WarehouseLandedCost"), "decimal", True)
                objRecord.PurchaseOrderIssuedTo = DataHelper.SmartValues(.Item("PurchaseOrderIssuedTo"), "string", True)
                objRecord.VendorComments = DataHelper.SmartValues(.Item("VendorComments"), "string", True)
                objRecord.FreightTerms = DataHelper.SmartValues(.Item("FreightTerms"), "string", True)
                objRecord.OutboundFreight = DataHelper.SmartValues(.Item("OutboundFreight"), "decimal", True)
                objRecord.NinePercentWhseCharge = DataHelper.SmartValues(.Item("NinePercentWhseCharge"), "decimal", True)
                objRecord.TotalStoreLandedCost = DataHelper.SmartValues(.Item("TotalStoreLandedCost"), "decimal", True)
                objRecord.UpdateUserID = DataHelper.SmartValues(.Item("UpdateUserID"), "integer", True)
                objRecord.DateLastModified = DataHelper.SmartValues(.Item("DateLastModified"), "date", True)
                objRecord.UpdateUserName = DataHelper.SmartValues(.Item("UpdateUserName"), "string", True)
                objRecord.StoreSupplierZoneGroup = DataHelper.SmartValues(.Item("StoreSupplierZoneGroup"), "string", True)
                objRecord.WHSSupplierZoneGroup = DataHelper.SmartValues(.Item("WHSSupplierZoneGroup"), "string", True)
                objRecord.PackItemIndicator = DataHelper.SmartValues(.Item("PackItemIndicator"), "string", True)
                objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("ItemTypeAttribute"), "string", True)
                objRecord.HybridType = DataHelper.SmartValues(.Item("HybridType"), "string", True)
                objRecord.HybridSourceDC = DataHelper.SmartValues(.Item("HybridSourceDC"), "string", True)
                objRecord.HazardousMSDSUOM = DataHelper.SmartValues(.Item("HazardousMSDSUOM"), "string", True)
                objRecord.DetailInvoiceCustomsDesc0 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc0"), "string", True)
                objRecord.DetailInvoiceCustomsDesc1 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc1"), "string", True)
                objRecord.DetailInvoiceCustomsDesc2 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc2"), "string", True)
                objRecord.DetailInvoiceCustomsDesc3 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc3"), "string", True)
                objRecord.DetailInvoiceCustomsDesc4 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc4"), "string", True)
                objRecord.DetailInvoiceCustomsDesc5 = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc5"), "string", True)
                objRecord.ComponentMaterialBreakdown0 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown0"), "string", True)
                objRecord.ComponentMaterialBreakdown1 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown1"), "string", True)
                objRecord.ComponentMaterialBreakdown2 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown2"), "string", True)
                objRecord.ComponentMaterialBreakdown3 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown3"), "string", True)
                objRecord.ComponentMaterialBreakdown4 = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown4"), "string", True)
                objRecord.ComponentConstructionMethod0 = DataHelper.SmartValues(.Item("ComponentConstructionMethod0"), "string", True)
                objRecord.ComponentConstructionMethod1 = DataHelper.SmartValues(.Item("ComponentConstructionMethod1"), "string", True)
                objRecord.ComponentConstructionMethod2 = DataHelper.SmartValues(.Item("ComponentConstructionMethod2"), "string", True)
                objRecord.ComponentConstructionMethod3 = DataHelper.SmartValues(.Item("ComponentConstructionMethod3"), "string", True)
                objRecord.DepartmentNum = DataHelper.SmartValues(.Item("DepartmentNum"), "integer", True)
                objRecord.Base1Retail = DataHelper.SmartValues(.Item("Base1Retail"), "decimal", True)
                objRecord.Base2Retail = DataHelper.SmartValues(.Item("Base2Retail"), "decimal", True)
                objRecord.Base3Retail = DataHelper.SmartValues(.Item("Base3Retail"), "decimal", True)
                objRecord.TestRetail = DataHelper.SmartValues(.Item("TestRetail"), "decimal", True)
                objRecord.AlaskaRetail = DataHelper.SmartValues(.Item("AlaskaRetail"), "decimal", True)
                objRecord.CanadaRetail = DataHelper.SmartValues(.Item("CanadaRetail"), "decimal", True)
                objRecord.High1Retail = DataHelper.SmartValues(.Item("High1Retail"), "decimal", True)
                objRecord.High2Retail = DataHelper.SmartValues(.Item("High2Retail"), "decimal", True)
                objRecord.High3Retail = DataHelper.SmartValues(.Item("High3Retail"), "decimal", True)
                objRecord.SmallMarketRetail = DataHelper.SmartValues(.Item("SmallMarketRetail"), "decimal", True)
                objRecord.Low1Retail = DataHelper.SmartValues(.Item("Low1Retail"), "decimal", True)
                objRecord.Low2Retail = DataHelper.SmartValues(.Item("Low2Retail"), "decimal", True)
                objRecord.ManhattanRetail = DataHelper.SmartValues(.Item("ManhattanRetail"), "decimal", True)
                objRecord.QuebecRetail = DataHelper.SmartValues(.Item("QuebecRetail"), "decimal", True)
                objRecord.PuertoRicoRetail = DataHelper.SmartValues(.Item("PuertoRicoRetail"), "decimal", True)
                objRecord.HazardousManufacturerName = DataHelper.SmartValues(.Item("HazardousManufacturerName"), "string", True)
                objRecord.HazardousManufacturerCity = DataHelper.SmartValues(.Item("HazardousManufacturerCity"), "string", True)
                objRecord.HazardousManufacturerState = DataHelper.SmartValues(.Item("HazardousManufacturerState"), "string", True)
                objRecord.HazardousManufacturerPhone = DataHelper.SmartValues(.Item("HazardousManufacturerPhone"), "string", True)
                objRecord.HazardousManufacturerCountry = DataHelper.SmartValues(.Item("HazardousManufacturerCountry"), "string", True)
                objRecord.ItemType = DataHelper.SmartValues(.Item("ItemType"), "string", True)
                objRecord.QtyInPack = DataHelper.SmartValues(.Item("QtyInPack"), "integer", True)
                objRecord.PrimaryVendor = DataHelper.SmartValues(.Item("PrimaryVendor"), "boolean", True)
                objRecord.ItemStatus = DataHelper.SmartValues(.Item("ItemStatus"), "string", True)
                objRecord.Base1Clearance = DataHelper.SmartValues(.Item("Base1Clearance"), "decimal", True)
                objRecord.Base2Clearance = DataHelper.SmartValues(.Item("Base2Clearance"), "decimal", True)
                objRecord.Base3Clearance = DataHelper.SmartValues(.Item("Base3Clearance"), "decimal", True)
                objRecord.TestClearance = DataHelper.SmartValues(.Item("TestClearance"), "decimal", True)
                objRecord.AlaskaClearance = DataHelper.SmartValues(.Item("AlaskaClearance"), "decimal", True)
                objRecord.CanadaClearance = DataHelper.SmartValues(.Item("CanadaClearance"), "decimal", True)
                objRecord.High1Clearance = DataHelper.SmartValues(.Item("High1Clearance"), "decimal", True)
                objRecord.High2Clearance = DataHelper.SmartValues(.Item("High2Clearance"), "decimal", True)
                objRecord.High3Clearance = DataHelper.SmartValues(.Item("High3Clearance"), "decimal", True)
                objRecord.SmallMarketClearance = DataHelper.SmartValues(.Item("SmallMarketClearance"), "decimal", True)
                objRecord.Low1Clearance = DataHelper.SmartValues(.Item("Low1Clearance"), "decimal", True)
                objRecord.Low2Clearance = DataHelper.SmartValues(.Item("Low2Clearance"), "decimal", True)
                objRecord.ManhattanClearance = DataHelper.SmartValues(.Item("ManhattanClearance"), "decimal", True)
                objRecord.QuebecClearance = DataHelper.SmartValues(.Item("QuebecClearance"), "decimal", True)
                objRecord.PuertoRicoClearance = DataHelper.SmartValues(.Item("PuertoRicoClearance"), "decimal", True)
                objRecord.FutureCostExists = DataHelper.SmartValues(.Item("FutureCostExists"), "boolean", True)
                objRecord.QuoteSheetItemType = DataHelper.SmartValues(.Item("QuoteSheetItemType"), "string", True)
                objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", True)
                objRecord.CustomsDescription = DataHelper.SmartValues(.Item("CustomsDescription"), "string", True)

                objRecord.PLIEnglish = DataHelper.SmartValues(.Item("PLI_English"), "string", True)
                objRecord.PLIFrench = DataHelper.SmartValues(.Item("PLI_French"), "string", True)
                objRecord.PLISpanish = DataHelper.SmartValues(.Item("PLI_Spanish"), "string", True)
                objRecord.TIEnglish = DataHelper.SmartValues(.Item("TI_English"), "string", True)
                objRecord.TIFrench = DataHelper.SmartValues(.Item("TI_French"), "string", True)
                objRecord.TISpanish = DataHelper.SmartValues(.Item("TI_Spanish"), "string", True)
                objRecord.EnglishLongDescription = DataHelper.SmartValues(.Item("English_Long_Description"), "string", True)
                objRecord.EnglishShortDescription = DataHelper.SmartValues(.Item("English_Short_Description"), "string", True)
                objRecord.FrenchLongDescription = DataHelper.SmartValues(.Item("French_Long_Description"), "string", True)
                objRecord.FrenchShortDescription = DataHelper.SmartValues(.Item("French_Short_Description"), "string", True)
                objRecord.SpanishLongDescription = DataHelper.SmartValues(.Item("Spanish_Long_Description"), "string", True)
                objRecord.SpanishShortDescription = DataHelper.SmartValues(.Item("Spanish_Short_Description"), "string", True)
                objRecord.ExemptEndDateFrench = DataHelper.SmartValues(.Item("Exempt_End_Date_French"), "string", True)

                objRecord.StockingStrategyCode = DataHelper.SmartValues(.Item("StockingStrategyCode"), "string", True)

                objRecord.EachCaseHeight = DataHelper.SmartValues(.Item("EachCaseHeight"), "decimal", True)
                objRecord.EachCaseWidth = DataHelper.SmartValues(.Item("EachCaseWidth"), "decimal", True)
                objRecord.EachCaseLength = DataHelper.SmartValues(.Item("EachCaseLength"), "decimal", True)
                objRecord.EachCaseWeight = DataHelper.SmartValues(.Item("EachCaseWeight"), "decimal", True)
                objRecord.EachCaseCube = DataHelper.SmartValues(.Item("EachCaseCube"), "decimal", True)

                objRecord.EachCaseCubeUOM = DataHelper.SmartValues(.Item("EachCaseCubeUOM"), "string", True)
                objRecord.EachCaseWeightUOM = DataHelper.SmartValues(.Item("EachCaseWeightUOM"), "string", True)

                objRecord.MinimumOrderQuantity = DataHelper.SmartValues(.Item("MinimumOrderQuantity"), "integer", True)
                objRecord.ProductIdentifiesAsCosmetic = DataHelper.SmartValues(.Item("ProductIdentifiesAsCosmetic"), "string", True)
            End With

        End Sub

        Public Shared Function FindHeaderID(ByVal sku As String, ByVal vendorNum As Long, ByVal VendorID As Long) As List(Of ItemMaintItem)

            Dim itemHeaderList As New List(Of ItemMaintItem)
            Dim sql As String = "usp_SPD_ItemMaint_GetItemHeaderBySKUVendor"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand = Nothing
            If VendorID > 0 AndAlso VendorID <> vendorNum Then
                Return itemHeaderList
            End If
            Try
                conn = NovaLibra.Coral.Data.Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                Dim totalRowsParm As New SqlParameter("@totalRows", SqlDbType.Int)
                totalRowsParm.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(totalRowsParm)

                cmd.Parameters.Add("@SKU", SqlDbType.Int).Value = sku
                cmd.Parameters.Add("@VendorNum", SqlDbType.BigInt).Value = vendorNum

                ' HEY let's don't open this connection again!
                'conn = Utilities.ApplicationHelper.GetAppConnection()

                'objParam = New System.Data.SqlClient.SqlParameter("@VendorID", SqlDbType.BigInt)    ' for security returns empty recset if Vendor ID does not match rec
                'objParam.Value = vendorID
                'reader.Command.Parameters.Add(objParam)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        Dim objRecord As ItemMaintItem = New ItemMaintItem()
                        objRecord.ID = .Item("ID")
                        objRecord.BatchID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                        objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                        objRecord.SKU = DataHelper.SmartValues(.Item("Michaels_SKU"), "string", True)
                        objRecord.SKUID = DataHelper.SmartValues(.Item("SKU_ID"), "integer", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", True)
                        Dim iv As Int16 = DataHelper.SmartValues(.Item("Is_Valid"), "smallint", True)
                        If iv = 1 Then
                            objRecord.IsValid = ItemValidFlag.Valid
                        ElseIf iv = 0 Then
                            objRecord.IsValid = ItemValidFlag.NotValid
                        Else
                            objRecord.IsValid = ItemValidFlag.Unknown
                        End If
                        objRecord.LastUpdateDate = DataHelper.SmartValues(.Item("LastUpdateDate"), "string", True)
                        objRecord.LastUpdateUserID = DataHelper.SmartValues(.Item("LastUpdateUserID"), "integer", True)
                        objRecord.LastUpdateUserName = DataHelper.SmartValues(.Item("LastUpdateUserName"), "string", True)
                        itemHeaderList.Add(objRecord)
                    End With
                End While

            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
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
            Return itemHeaderList
        End Function

        Public Shared Function GetItemMaintHeaderRec(ByVal itemID As Integer) As ItemMaintItem
            Dim objRecord As ItemMaintItem = New ItemMaintItem()
            Dim sql As String = "usp_SPD_ItemMaint_GetItemHeaderByID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ItemID", SqlDbType.Int)
                objParam.Value = itemID
                reader.Command.Parameters.Add(objParam)

                'objParam = New System.Data.SqlClient.SqlParameter("@VendorID", SqlDbType.BigInt)    ' for security returns empty recset if Vendor ID does not match rec
                'objParam.Value = vendorID
                'reader.Command.Parameters.Add(objParam)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = .Item("ID")
                        objRecord.BatchID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                        objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", True)
                        objRecord.SKU = DataHelper.SmartValues(.Item("Michaels_SKU"), "string", True)
                        objRecord.SKUID = DataHelper.SmartValues(.Item("SKU_ID"), "integer", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", True)
                        Dim iv As Int16 = DataHelper.SmartValues(.Item("Is_Valid"), "smallint", True)
                        If iv = 1 Then
                            objRecord.IsValid = ItemValidFlag.Valid
                        ElseIf iv = 0 Then
                            objRecord.IsValid = ItemValidFlag.NotValid
                        Else
                            objRecord.IsValid = ItemValidFlag.Unknown
                        End If
                        objRecord.LastUpdateDate = DataHelper.SmartValues(.Item("LastUpdateDate"), "string", True)
                        objRecord.LastUpdateUserID = DataHelper.SmartValues(.Item("LastUpdateUserID"), "integer", True)
                        objRecord.LastUpdateUserName = DataHelper.SmartValues(.Item("LastUpdateUserName"), "string", True)
                    End With
                End If
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
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
            Return objRecord

        End Function

        ' Save the list of Item Maint "Header" (records)
        Public Shared Function SaveItemMaintHeaderRecs(ByRef records As List(Of ItemMaintItem)) As Integer
            Dim count As Integer = records.Count
            Dim RecsSaved As Integer = 0, retValue As Integer

            For i As Integer = 0 To count - 1
                retValue = SaveItemMaintHeaderRec(records(i))
                If retValue > 0 Then
                    RecsSaved += 1
                Else
                    Return retValue
                End If
            Next
            Return RecsSaved
        End Function

        Public Shared Function SaveItemMaintHeaderRec(ByRef record As ItemMaintItem) As Integer
            Dim sql As String = "usp_SPD_ItemMaint_AddItemToBatch"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand = Nothing
            Dim id As Integer = 0
            Try
                conn = NovaLibra.Coral.Data.Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                Dim idParam As New SqlParameter("@ID", SqlDbType.Int)
                idParam.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(idParam)

                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = record.CreatedUserID
                cmd.Parameters.Add("@VendorNumber", SqlDbType.Int).Value = record.VendorNumber
                cmd.Parameters.Add("@Batch_ID", SqlDbType.Int).Value = record.BatchID
                cmd.Parameters.Add("@SKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(record.SKU, "string", True)
                cmd.Parameters.Add("@SKUID", SqlDbType.Int).Value = record.SKUID

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                conn.Close()

                id = DataHelper.SmartValues(idParam.Value, "CInt", False, 0)

            Catch ex As Exception
                Logger.LogError(ex)
                Throw
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return id

        End Function

        Public Shared Function GetParentSKUS(ByVal childSKU As String, ByVal packSKU As String) As List(Of String)

            ' returns 2 records, one with D and DB, then one with DPs

            Dim parents As List(Of String) = New List(Of String)
            Dim parent As String
            Dim sql As String = "usp_SPD_ItemMaint_GetParentSKUs"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@ChildSKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(childSKU, "string", True)
                cmd.Parameters.Add("@PackSKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(packSKU, "string", True)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        parent = DataHelper.SmartValues(.Item("D_SKUs"), "string", True)
                        parents.Add(parent)
                        parent = DataHelper.SmartValues(.Item("DP_SKUs"), "string", True)
                        parents.Add(parent)
                    End With
                End If
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
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
            Return parents
        End Function

        Public Shared Function PackChildrenAvailable(ByVal SKU As String, ByVal packType As String, ByVal VendorNumber As Long) As String
            Dim objRecord As ItemMaintItem, i As Integer, childOK As Boolean = True, inUseCount As Integer = 0
            Dim Message As String = String.Empty
            Dim childRecs As List(Of ItemMaintItem) = New List(Of ItemMaintItem)

            Dim sql As String = "usp_SPD_ItemMaint_GetChildrenSKUsforPack"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@PackSKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(SKU, "string", True)
                cmd.Parameters.Add("@PackType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(packType, "string", True)
                cmd.Parameters.Add("@PackVendor", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(VendorNumber, "bigint", True)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read()
                    With reader
                        objRecord = New ItemMaintItem
                        objRecord.BatchID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                        objRecord.BatchTypeID = DataHelper.SmartValues(.Item("Batch_Type_ID"), "integer", True)
                        objRecord.SKU = DataHelper.SmartValues(.Item("Michaels_SKU"), "string", True)
                        objRecord.SKUID = DataHelper.SmartValues(.Item("SKU_ID"), "integer", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", True)
                    End With
                    childRecs.Add(objRecord)
                Loop
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
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
            ' Now Scan list of records returned to esnure none are in a batch
            Dim childCount As Integer = childRecs.Count - 1
            For i = 0 To childCount
                If childRecs(i).BatchID > 0 And (childRecs(i).BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic Or childRecs(i).BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import) Then
                    childOK = False
                    inUseCount += 1
                    If inUseCount = 1 Then Message = String.Format("Component SKU: {0} is a member of Batch: {1}.", childRecs(i).SKU, childRecs(i).BatchID)
                End If
            Next
            If inUseCount >= 1 Then Message += String.Format("&nbsp;&nbsp;&nbsp;Total In-Use Component SKUs found: {0}", inUseCount)
            Return Message
        End Function

        ' Add Pack record to IM Batch and then find and add all children
        Public Shared Function AddChildrenToIMBatch(ByRef records As List(Of ItemMaintItem), ByVal packType As String, ByVal VendorNumber As Long) As String
            Dim count As Integer = records.Count
            Dim RecsSaved As Integer = 0, retValue As String = "1", procResult As Integer
            If records.Count <> 1 Then
                Return "-1"   ' indicate error 1 : Invalid number of parent items
            End If

            ' Save the Pack Record
            procResult = SaveItemMaintHeaderRec(records(0))

            If procResult > 0 Then   ' Get children recs
                Dim objRecord As ItemMaintItem, i As Integer, childError As Boolean = False
                Dim childRecs As List(Of ItemMaintItem) = New List(Of ItemMaintItem)

                Dim sql As String = "usp_SPD_ItemMaint_GetChildrenSKUsforPack"
                Dim conn As DBConnection = Nothing
                Dim reader As DBReader = Nothing
                Dim cmd As DBCommand = Nothing
                Try
                    conn = Utilities.ApplicationHelper.GetAppConnection()
                    reader = New DBReader(conn)
                    cmd = reader.Command
                    cmd.Parameters.Add("@PackSKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(records(0).SKU, "string", True)
                    cmd.Parameters.Add("@PackType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(packType, "string", True)
                    cmd.Parameters.Add("@PackVendor", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(VendorNumber, "bigint", True)

                    reader.CommandText = sql
                    reader.CommandType = CommandType.StoredProcedure
                    reader.Open()
                    Do While reader.Read()
                        With reader
                            objRecord = New ItemMaintItem
                            objRecord.BatchID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                            objRecord.BatchTypeID = DataHelper.SmartValues(.Item("Batch_Type_ID"), "integer", True)
                            objRecord.SKU = DataHelper.SmartValues(.Item("Michaels_SKU"), "string", True)
                            objRecord.SKUID = DataHelper.SmartValues(.Item("SKU_ID"), "integer", True)
                            objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", True)
                        End With
                        childRecs.Add(objRecord)
                    Loop
                Catch sqlex As SqlException
                    Logger.LogError(sqlex)
                    Throw sqlex
                Catch ex As Exception
                    Logger.LogError(ex)
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

                ' Now Scan list of records returned to esnure none are in a batch
                Dim childCount As Integer = childRecs.Count - 1
                For i = 0 To childCount
                    If childRecs(i).BatchID > 0 And (childRecs(i).BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Domestic Or childRecs(i).BatchTypeID = NovaLibra.Coral.SystemFrameworks.Michaels.BatchType.Import) Then
                        childError = True
                        retValue = "-2|" & CStr(childRecs(i).SKU) & "|" & CStr(childRecs(i).BatchID)   ' Child rec found that is a member of another batch
                        Exit For
                    End If
                    childRecs(i).BatchID = records(0).BatchID
                    childRecs(i).CreatedUserID = records(0).CreatedUserID
                Next

                If Not childError Then
                    ' Save the children records
                    procResult = SaveItemMaintHeaderRecs(childRecs)
                    If procResult = childRecs.Count Then
                        procResult += 1
                        retValue = "1|" & procResult.ToString
                    Else
                        retValue = "-3|" & CStr(childRecs.Count) & "|" & CStr(procResult)
                    End If
                End If

            Else
                retValue = "-4"     ' Pack Record failed to save
            End If
            Return retValue
        End Function

        Public Shared Function GetIMChangeRecordsByItemID(ByVal itemID As Integer) As List(Of IMChangeRecord)
            Dim ChangeRecs As List(Of IMChangeRecord) = New List(Of IMChangeRecord)
            Dim ChangeRec As IMChangeRecord
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim sql As String = "usp_SPD_ItemMaint_GetItemChanges"
            ' Dim currentID As Integer, previousID As Integer = -1
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                cmd = reader.Command
                cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = itemID
                reader.Open()
                Do While reader.Read()
                    ChangeRec = New IMChangeRecord()
                    With reader
                        ChangeRec.ItemID = DataHelper.SmartValues(.Item("Item_Maint_Items_ID"), "integer", True)
                        ChangeRec.FieldName = DataHelper.SmartValues(.Item("Field_Name"), "string", True)
                        ChangeRec.CountryOfOrigin = DataHelper.SmartValues(.Item("Country_Of_Origin"), "string", True)
                        ChangeRec.UPC = DataHelper.SmartValues(.Item("UPC"), "string", True)
                        ChangeRec.EffectiveDate = DataHelper.SmartValues(.Item("Effective_Date"), "string", True)
                        ChangeRec.Counter = DataHelper.SmartValues(.Item("Counter"), "integer", True)
                        ChangeRec.FieldValue = DataHelper.SmartValues(.Item("Field_Value"), "string", True)
                        ChangeRec.ChangedByName = DataHelper.SmartValues(.Item("Changed_By_Name"), "string", True)
                        ChangeRec.ChangedDate = DataHelper.SmartValues(.Item("Date_Last_Modified"), "string", True)
                        ChangeRec.ChangedByID = DataHelper.SmartValues(.Item("Update_User_ID"), "integer", True)
                    End With
                    ChangeRecs.Add(ChangeRec)
                Loop
            Catch ex As Exception
                Debug.Assert(False)
                Logger.LogError(ex)
            Finally
                If Not reader Is Nothing Then
                    reader.Close()
                    reader.Dispose()
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return ChangeRecs
        End Function

        Public Shared Function GetIMChangeRecordsByID(ByVal ID As Integer) As IMRowChanges
            Dim objCell As IMCellChangeRecord
            Dim objRow As IMRowChanges = New IMRowChanges(ID)
            'Dim objTable As IMTableChanges = New IMTableChanges
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim sql As String = "usp_SPD_ItemMaint_GetItemChanges"
            'Dim currentID As Integer, previousID As Integer = -1
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = ID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read()
                    With reader
                        'currentID = DataHelper.SmartValues(reader.Item("Item_Maint_Items_ID"), "integer", True)
                        objCell = New IMCellChangeRecord
                        objCell.FieldName = DataHelper.SmartValues(.Item("Field_Name"), "string", True).ToString().Replace("_", "")
                        objCell.FieldValue = DataHelper.SmartValues(.Item("Field_Value"), "string", True)
                        objCell.Counter = DataHelper.SmartValues(.Item("Counter"), "integer", False)
                        objRow.Add(objCell)
                    End With
                Loop

            Catch ex As Exception
                Debug.Assert(False)
                Logger.LogError(ex)
            Finally
                If Not reader Is Nothing Then
                    reader.Close()
                    reader.Dispose()
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return objRow
        End Function

        Public Shared Function GetIMChangeRecordsByBatchID(ByVal BatchID As Long) As IMTableChanges
            Dim objCell As IMCellChangeRecord
            Dim objRow As IMRowChanges = Nothing
            Dim objTable As IMTableChanges = New IMTableChanges
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim sql As String = "usp_SPD_ItemMaint_GetItemChanges"
            Dim currentID As Integer, previousID As Integer = -1
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@BatchID", SqlDbType.BigInt).Value = BatchID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read()
                    With reader
                        currentID = DataHelper.SmartValues(reader.Item("Item_Maint_Items_ID"), "integer", True)
                        If currentID <> previousID Then
                            If objRow IsNot Nothing Then    ' set the ID of the row and save it
                                objRow.ID = previousID
                                objTable.Add(objRow)
                            End If
                            objRow = New IMRowChanges()       ' Then Create a new Row
                        End If
                        objCell = New IMCellChangeRecord
                        objCell.FieldName = DataHelper.SmartValues(.Item("Field_Name"), "string", True).ToString().Replace("_", "")
                        objCell.FieldValue = DataHelper.SmartValues(.Item("Field_Value"), "string", True)
                        objCell.Counter = DataHelper.SmartValues(.Item("Counter"), "integer", False)
                        objRow.Add(objCell)
                        previousID = currentID
                    End With
                Loop
                ' Save the last row to the table
                If objRow IsNot Nothing AndAlso objRow.RowRecords.Count > 0 Then
                    objRow.ID = previousID
                    objTable.Add(objRow)
                End If

            Catch ex As Exception
                Debug.Assert(False)
                Logger.LogError(ex)
            Finally
                If Not reader Is Nothing Then
                    reader.Close()
                    reader.Dispose()
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return objTable
        End Function

        Public Shared Function GetHasCostChangesByBatchID(ByVal BatchID As Long) As Boolean
            Dim ret As Boolean = False
            Dim count As Integer = 0
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim sql As String = "usp_SPD_ItemMaint_GetHasCostChangesByBatchID"
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@BatchID", SqlDbType.BigInt).Value = BatchID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        count = DataHelper.SmartValues(reader.Item("CostChangesCount"), "integer", False)
                        If count > 0 Then
                            ret = True
                        End If
                    End With
                End If

            Catch ex As Exception
                Debug.Assert(False)
                Logger.LogError(ex)
            Finally
                If Not reader Is Nothing Then
                    reader.Close()
                    reader.Dispose()
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return ret
        End Function

        Public Shared Function SaveItemMaintChanges(ByRef TableChanges As IMTableChanges, ByVal userID As Integer) As Boolean
            Dim objRow As IMRowChanges = Nothing
            Dim i As Integer
            Dim result As Boolean = True
            For i = 0 To TableChanges.Count - 1
                objRow = TableChanges.GetItem(i)
                If Not SaveItemMaintChanges(objRow, userID) Then
                    result = False
                End If
            Next
            Return result
        End Function

        Public Shared Function SaveItemMaintChanges(ByRef rowChanges As IMRowChanges, ByVal userID As Integer) As Boolean
            Dim result As Boolean = True
            Dim objRow As List(Of IMCellChangeRecord) = Nothing
            objRow = rowChanges.RowRecords
            For Each objCell As IMCellChangeRecord In objRow
                If Not SaveItemMaintChanges(rowChanges.ID, objCell, userID) Then
                    result = False
                End If
            Next
            Return result
        End Function

        Public Shared Function SaveItemMaintChanges(ByVal RecordID As Integer, ByRef cellChange As IMCellChangeRecord, ByVal userID As Integer, Optional ByVal isUploadChange As Boolean = False) As Boolean
            Return SaveItemMaintChanges(RecordID, cellChange.FieldName, cellChange.FieldValue, cellChange.HasChanged, userID, , , , cellChange.Counter, cellChange.DontSendToRMS, isUploadChange)
        End Function

        Public Shared Function SaveFormChanges(ByVal ChangeRec As IMChangeRecord, ByVal userID As Integer, ByVal changeFlag As String) As Boolean
            Dim result As Boolean
            Try
                'Dim objData As New NLData.Michaels.MaintItemMasterDetail
                Select Case UCase(changeFlag)
                    Case "SC"       ' Started out the same and was changed. Do an INSERT
                        ChangeRec.HasChanged = True
                    Case "DC"       ' Started out different and was changed.  Do an UPDATE
                        ChangeRec.HasChanged = True
                    Case "DR"       ' Started out different and was reverted.  Do DELETE
                        ChangeRec.HasChanged = False
                    Case Else
                        result = False
                End Select
                result = SaveItemMaintChanges(ChangeRec.ItemID, ChangeRec.FieldName, ChangeRec.FieldValue, ChangeRec.HasChanged, userID, _
                        ChangeRec.CountryOfOrigin, ChangeRec.UPC, ChangeRec.EffectiveDate, ChangeRec.Counter, ChangeRec.DontSendToRMS)
            Catch ex As Exception
                Logger.LogError(ex)
            Finally
            End Try
            Return result
        End Function

        Public Shared Function SaveItemMaintChanges(ByVal RecordID As Integer, ByVal FieldName As String, ByVal FieldValue As String, _
            ByVal HasChanged As Boolean, ByVal userID As Integer, _
            Optional ByVal CountryOfOrigin As String = "", Optional ByVal UPC As String = "", _
            Optional ByVal EffectiveDate As String = "", Optional ByVal Counter As Integer = 0, _
            Optional ByVal DontSendToRMS As Boolean = False, Optional ByVal IsUploadChange As Boolean = False) As Boolean

            Dim sql As String = "usp_SPD_ItemMaint_SaveItemChange"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objReturn As System.Data.SqlClient.SqlParameter
            Dim result As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objReturn = New System.Data.SqlClient.SqlParameter("@Result", SqlDbType.Int)
                objReturn.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(objReturn)

                cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = RecordID    'DataHelper.DBSmartValues(RecordID, "integer", True)
                cmd.Parameters.Add("@FieldName", SqlDbType.VarChar, 50).Value = FieldName   'DataHelper.DBSmartValues(FieldName, "string", True)
                cmd.Parameters.Add("@FieldValue", SqlDbType.VarChar, -1).Value = FieldValue   '  DataHelper.DBSmartValues(FieldValue, "string", True)
                cmd.Parameters.Add("@HasChanged", SqlDbType.Bit).Value = HasChanged
                cmd.Parameters.Add("@ChangedByID", SqlDbType.Int).Value = userID    ' DataHelper.DBSmartValues(userID, "integer", True)
                cmd.Parameters.Add("@DontSendToRMS", SqlDbType.Bit).Value = DontSendToRMS
                cmd.Parameters.Add("@IsUploadChange", SqlDbType.Bit).Value = IsUploadChange

                If CountryOfOrigin.Length > 0 Then cmd.Parameters.Add("@CountryOfOrigin", SqlDbType.VarChar).Value = CountryOfOrigin '   DataHelper.DBSmartValues(CountryOfOrigin, "string", True)
                If UPC.Length > 0 Then cmd.Parameters.Add("@UPC", SqlDbType.VarChar).Value = UPC ' DataHelper.DBSmartValues(UPC, "string", True)
                If EffectiveDate.Length > 0 Then cmd.Parameters.Add("@EffectiveDate", SqlDbType.VarChar).Value = EffectiveDate '  DataHelper.DBSmartValues(EffectiveDate, "string", True)
                If Counter >= 0 Then cmd.Parameters.Add("@Counter", SqlDbType.Int).Value = Counter '   DataHelper.DBSmartValues(Counter, "integer", True)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                conn.Close()
                result = DataHelper.DBSmartValues(objReturn.Value, "boolean", True)

                'If Not result Then
                '    Throw New Exception("Error saving item maintenance change(s).")
                'End If

            Catch ex As SqlException
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return result
        End Function

        Public Shared Function DeleteMatchingChangeRecords(ByVal ItemID As Integer, ByVal FieldName As String) As Boolean
            Dim sql As String = "usp_SPD_ItemMaint_DeleteChangeRecs"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objReturn As System.Data.SqlClient.SqlParameter
            Dim result As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objReturn = New System.Data.SqlClient.SqlParameter("@Result", SqlDbType.Int)
                objReturn.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(objReturn)

                cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = ItemID    'DataHelper.DBSmartValues(RecordID, "integer", True)
                cmd.Parameters.Add("@FieldName", SqlDbType.VarChar, 50).Value = FieldName   'DataHelper.DBSmartValues(FieldName, "string", True)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                conn.Close()
                result = True

                'If Not result Then
                '    Throw New Exception("Error saving item maintenance change(s).")
                'End If

            Catch ex As SqlException
                Logger.LogError(ex)
                Throw ex
                result = False
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return result
        End Function

        Public Shared Function DeleteItemMaintBatchData(ByVal batchID As Long, ByVal userID As Long) As Boolean
            Dim sql As String = "usp_SPD_ItemMaint_DeleteBatch_Data"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@BatchID", SqlDbType.BigInt).Value = batchID
                cmd.Parameters.Add("@UserID", SqlDbType.BigInt).Value = userID
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
                'Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return bSuccess

        End Function

        Public Shared Function DeleteItemMaintRecord(ByVal batchID As Long, ByVal id As Integer, ByVal userID As Integer, Optional ByVal deleteAll As Integer = 0) As Boolean
            Dim sql As String = "usp_SPD_ItemMaint_DeleteRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.Int)
                objParam.Value = id
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                cmd.Parameters.Add("@UserID", SqlDbType.BigInt).Value = userID
                cmd.Parameters.Add("@DeleteAll", SqlDbType.TinyInt).Value = deleteAll
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)

                bSuccess = False
                'Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return bSuccess
        End Function

        ' ******************
        ' * ITEM LANGUAGES *
        ' ******************

        Public Shared Function GetItemLanguages(ByVal sku As String, ByVal vendorNumber As Long) As DataTable
            Dim dt As New DataTable

            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Item_Master_Languages_GetBySKU", conn)
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.Parameters.AddWithValue("@MichaelsSKU", sku)
                        cmd.Parameters.AddWithValue("@VendorNumber", vendorNumber)
                        cmd.CommandTimeout = 1800

                        Using da As New SqlDataAdapter(cmd)
                            da.Fill(dt)
                        End Using   'da
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw ex
            End Try

            Return dt
        End Function

        Public Shared Sub SaveItemLanguage(ByVal sku As String, ByVal vendorNumber As Long, ByVal languageTypeID As Integer, ByVal pli As String, ByVal ti As String, ByVal descShort As String, ByVal descLong As String, ByVal userID As Integer)
            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Item_Master_Languages_InsertUpdate", conn)
                        cmd.CommandType = CommandType.StoredProcedure

                        cmd.Parameters.AddWithValue("@MichaelsSKU", sku)
                        cmd.Parameters.AddWithValue("@VendorNumber", vendorNumber)
                        cmd.Parameters.AddWithValue("@LanguageTypeID", languageTypeID)
                        cmd.Parameters.AddWithValue("@PackageLanguageIndicator", pli)
                        cmd.Parameters.AddWithValue("@TranslationIndicator", ti)
                        cmd.Parameters.AddWithValue("@DescriptionShort", descShort)
                        cmd.Parameters.AddWithValue("@DescriptionLong", descLong)
                        cmd.Parameters.AddWithValue("@UserID", userID)

                        cmd.ExecuteNonQuery()
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw
            End Try

        End Sub

    End Class

End Namespace

