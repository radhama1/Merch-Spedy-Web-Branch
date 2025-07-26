Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

	Public Class POMaintenanceSKUStoreData

        Public Shared Sub BatchUpdateSKUStores(ByVal storeList As ArrayList)

            'CREATE needed Bulk Copy objects
            Dim bulkCopy As SqlBulkCopy = New SqlBulkCopy(Utilities.ApplicationConnectionStrings.AppConnectionString)
            Dim storeTable As DataTable = New DataTable
            storeTable.Columns.Add("PO_Maintenance_ID", GetType(Int64))
            storeTable.Columns.Add("PO_Location_ID", GetType(Int32))
            storeTable.Columns.Add("Michaels_SKU", GetType(String))
            storeTable.Columns.Add("Store_Name", GetType(String))
            storeTable.Columns.Add("Store_Number", GetType(Int32))
            storeTable.Columns.Add("Ordered_Qty", GetType(Int32))
            storeTable.Columns.Add("Landed_Cost", GetType(Decimal))
            storeTable.Columns.Add("Order_Retail", GetType(Decimal))
            storeTable.Columns.Add("Is_Valid", GetType(Boolean))
            storeTable.Columns.Add("Date_Created", GetType(DateTime))

            Try
                'Put Stores in DataTable
                For Each store As POMaintenanceSKUStoreRecord In storeList
                    storeTable.Rows.Add(store.POMaintenanceID, store.POLocationID, store.MichaelsSKU, store.StoreName, store.StoreNumber, store.OrderedQty, store.LandedCost, store.OrderRetail, store.IsValid, DateTime.Now)
                Next

                'COPY Stores into Processing table
                bulkCopy.DestinationTableName = "PO_Maintenance_SKU_Store_PROCESSING"
                bulkCopy.BulkCopyTimeout = 3600
                bulkCopy.WriteToServer(storeTable)
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                bulkCopy.Close()
            End Try
        End Sub

        Public Shared Sub DeleteBatchSKUs(ByVal poCreationID As Long?)
            Dim sql As String = "PO_Maintenance_SKU_Store_PROCESSING_Delete"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
                cmd.CommandTimeout = 3600
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
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

        End Sub

        Public Shared Sub MergeBatchSKUs(ByVal poCreationID As Long)
            Dim sql As String = "PO_Maintenance_SKU_Store_Update_Batch"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID

                cmd.CommandTimeout = 3600
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
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

        End Sub

        Public Shared Function GetByPOID(ByVal poID As Long) As ArrayList
            Dim storeList As New ArrayList
            Dim store As POMaintenanceSKUStoreRecord

            Dim sql As String = "PO_Maintenance_SKU_Store_Get_By_POID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        store = New POMaintenanceSKUStoreRecord
                        store.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        store.POMaintenanceID = DataHelper.SmartValuesDBNull(.Item("PO_Maintenance_ID"))
                        store.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        store.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        store.StoreName = DataHelper.SmartValuesDBNull(.Item("Store_Name"))
                        store.StoreNumber = DataHelper.SmartValuesDBNull(.Item("Store_Number"))
                        store.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        store.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        store.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        store.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        store.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        store.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        store.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        store.IsSelected = False

                        storeList.Add(store)
                    End With
                Loop

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

            Return storeList
        End Function

        Public Shared Function GetBySKU(ByVal poID As Long, ByVal sku As String, ByVal userID As Integer) As ArrayList
            Dim storeList As New ArrayList
            Dim store As POMaintenanceSKUStoreRecord

            Dim sql As String = "PO_Maintenance_SKU_Store_Get_By_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                reader.Command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = sku
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        store = New POMaintenanceSKUStoreRecord
                        store.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        store.POMaintenanceID = DataHelper.SmartValuesDBNull(.Item("PO_Maintenance_ID"))
                        store.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        store.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        store.StoreName = DataHelper.SmartValuesDBNull(.Item("Store_Name"))
                        store.StoreNumber = DataHelper.SmartValuesDBNull(.Item("Store_Number"))
                        store.Zone = DataHelper.SmartValuesDBNull(.Item("Zone"))
                        store.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        store.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        store.ReceivedQty = DataHelper.SmartValuesDBNull(.Item("Received_Qty"))
                        store.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        store.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        store.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        store.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        store.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        store.IsRemoveable = DataHelper.SmartValuesDBNull(.Item("Is_Removeable"))
                        store.IsWarning = DataHelper.SmartValuesDBNull(.Item("Is_Warning"))
                        store.IsSelected = False

                        storeList.Add(store)
                    End With
                Loop

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

            Return storeList
        End Function

        Public Shared Function GetValidatingStoresBySKU(ByVal poID As Long, ByVal sku As String, ByVal userID As Integer) As ArrayList
            Dim storeList As New ArrayList
            Dim store As POMaintenanceSKUStoreRecord

            Dim sql As String = "PO_Maintenance_SKU_Store_Get_Validating_Stores_By_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                reader.Command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = sku
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        store = New POMaintenanceSKUStoreRecord
                        store.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        store.POMaintenanceID = DataHelper.SmartValuesDBNull(.Item("PO_Maintenance_ID"))
                        store.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        store.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        store.StoreName = DataHelper.SmartValuesDBNull(.Item("Store_Name"))
                        store.StoreNumber = DataHelper.SmartValuesDBNull(.Item("Store_Number"))
                        store.Zone = DataHelper.SmartValuesDBNull(.Item("Zone"))
                        store.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        store.OriginalOrderedQty = DataHelper.SmartValuesDBNull(.Item("Original_Ordered_Qty"))
                        store.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        store.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        store.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        store.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        store.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        store.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        store.IsRemoveable = DataHelper.SmartValuesDBNull(.Item("Is_Removeable"))
                        store.IsSelected = False

                        storeList.Add(store)
                    End With
                Loop

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

            Return storeList
        End Function

        Public Shared Function GetRevisionBySku(ByVal poID As Long, ByVal sku As String, ByVal revisionNumber As Double) As ArrayList
            Dim storeList As New ArrayList
            Dim store As POMaintenanceSKUStoreRecord

            Dim sql As String = "PO_Maintenance_SKU_Store_Get_Revision_By_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                'Separate out Major and Minor Revision numbers
                Dim splitRevisionNumbers As String() = revisionNumber.ToString("0.0").Split(".")
                Dim majorRevisionNumber As String = splitRevisionNumbers(0)
                Dim minorRevisionNumber As String = splitRevisionNumbers(1)

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                reader.Command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = sku
                reader.Command.Parameters.Add("@Major_Revision_Number", SqlDbType.Int).Value = majorRevisionNumber
                reader.Command.Parameters.Add("@Minor_Revision_Number", SqlDbType.Int).Value = minorRevisionNumber

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        store = New POMaintenanceSKUStoreRecord
                        store.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        store.POMaintenanceID = DataHelper.SmartValuesDBNull(.Item("PO_Maintenance_ID"))
                        store.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        store.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        store.StoreName = DataHelper.SmartValuesDBNull(.Item("Store_Name"))
                        store.StoreNumber = DataHelper.SmartValuesDBNull(.Item("Store_Number"))
                        store.Zone = DataHelper.SmartValuesDBNull(.Item("Zone"))
                        store.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        store.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        store.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        store.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        store.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        store.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        store.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        store.IsRemoveable = DataHelper.SmartValuesDBNull(.Item("Is_Removeable"))
                        store.IsSelected = False

                        storeList.Add(store)
                    End With
                Loop

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

            Return storeList
        End Function

        Public Shared Function GetRevisionRecord(ByVal poMaintenanceID As Long?, ByVal sku As String, ByVal storeNumber As Integer, ByVal revisionNumber As Double) As POMaintenanceSKUStoreRecord
            Dim storeRecord As New POMaintenanceSKUStoreRecord

            Dim sql As String = "PO_History_Maintenance_SKU_Store_Get_Revision"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                'Separate out Major and Minor Revision numbers
                Dim splitRevisionNumbers As String() = revisionNumber.ToString("0.0").Split(".")
                Dim majorRevisionNumber As String = splitRevisionNumbers(0)
                Dim minorRevisionNumber As String = splitRevisionNumbers(1)

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.Command.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                reader.Command.Parameters.Add("@Store_Number", SqlDbType.Int).Value = storeNumber
                reader.Command.Parameters.Add("@Major_Revision_Number", SqlDbType.Int).Value = majorRevisionNumber
                reader.Command.Parameters.Add("@Minor_Revision_Number", SqlDbType.Int).Value = minorRevisionNumber
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        storeRecord = New POMaintenanceSKUStoreRecord
                        storeRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        storeRecord.POMaintenanceID = DataHelper.SmartValuesDBNull(.Item("PO_Maintenance_ID"))
                        storeRecord.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        storeRecord.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        storeRecord.StoreName = DataHelper.SmartValuesDBNull(.Item("Store_Name"))
                        storeRecord.StoreNumber = DataHelper.SmartValuesDBNull(.Item("Store_Number"))
                        storeRecord.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        storeRecord.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        storeRecord.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        storeRecord.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        storeRecord.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        storeRecord.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        storeRecord.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
                        storeRecord.IsSelected = False
                    End With
                Loop

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

            Return storeRecord

        End Function

        Public Shared Sub DeleteCache(ByVal poMaintenanceID As Long, ByVal sku As String, ByVal storeNumber As Integer, ByVal userID As Integer)

            Dim sql As String = "PO_Maintenance_SKU_Store_CACHE_Delete"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                cmd.Parameters.Add("@Store_Number", SqlDbType.Int).Value = storeNumber
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
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
        End Sub

        Public Shared Sub SaveCacheRecord(ByVal objRec As POMaintenanceSKUStoreRecord, ByVal userID As Integer)
            Dim sql As String = "PO_Maintenance_SKU_Store_CACHE_InsertUpdate"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.Input
                objParam.Value = objRec.ID
                reader.Command.Parameters.Add(objParam)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = objRec.POMaintenanceID
                reader.Command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = objRec.MichaelsSKU
                reader.Command.Parameters.Add("@PO_Location_ID", SqlDbType.VarChar).Value = objRec.POLocationID
                reader.Command.Parameters.Add("@Store_Number", SqlDbType.Int).Value = objRec.StoreNumber
                reader.Command.Parameters.Add("@Store_Name", SqlDbType.VarChar).Value = objRec.StoreName
                reader.Command.Parameters.Add("@Ordered_Qty", SqlDbType.Int).Value = objRec.OrderedQty
                reader.Command.Parameters.Add("@Cancelled_Qty", SqlDbType.Int).Value = objRec.CancelledQty
                reader.Command.Parameters.Add("@Landed_Cost", SqlDbType.Decimal).Value = objRec.LandedCost
                reader.Command.Parameters.Add("@Order_Retail", SqlDbType.Decimal).Value = objRec.OrderRetail
                reader.Command.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = objRec.IsValid
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Command.ExecuteNonQuery()

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

        End Sub

        Public Shared Sub UpdateCacheRecord(ByVal objRec As POMaintenanceSKUStoreRecord, ByVal userID As Integer)
            Dim sql As String = "PO_Maintenance_SKU_Store_CACHE_Update_By_System"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = objRec.ID
                reader.Command.Parameters.Add(objParam)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = objRec.POMaintenanceID
                reader.Command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = objRec.MichaelsSKU
                reader.Command.Parameters.Add("@PO_Location_ID", SqlDbType.VarChar).Value = objRec.POLocationID
                reader.Command.Parameters.Add("@Store_Number", SqlDbType.Int).Value = objRec.StoreNumber
                reader.Command.Parameters.Add("@Store_Name", SqlDbType.VarChar).Value = objRec.StoreName
                reader.Command.Parameters.Add("@Ordered_Qty", SqlDbType.Int).Value = objRec.OrderedQty
                reader.Command.Parameters.Add("@Cancelled_Qty", SqlDbType.Int).Value = objRec.CancelledQty
                reader.Command.Parameters.Add("@Landed_Cost", SqlDbType.Decimal).Value = objRec.LandedCost
                reader.Command.Parameters.Add("@Order_Retail", SqlDbType.Decimal).Value = objRec.OrderRetail
                reader.Command.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = objRec.IsValid
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Command.ExecuteNonQuery()

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
        End Sub

        Public Shared Sub UpdateRecordBySystem(ByVal objRec As POMaintenanceSKUStoreRecord)
            Dim sql As String = "PO_Maintenance_SKU_Store_Update_By_System"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)

                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = objRec.POMaintenanceID
                reader.Command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = objRec.MichaelsSKU
                reader.Command.Parameters.Add("@PO_Location_ID", SqlDbType.VarChar).Value = objRec.POLocationID
                reader.Command.Parameters.Add("@Store_Number", SqlDbType.Int).Value = objRec.StoreNumber
                reader.Command.Parameters.Add("@Store_Name", SqlDbType.VarChar).Value = objRec.StoreName
                reader.Command.Parameters.Add("@Landed_Cost", SqlDbType.Decimal).Value = objRec.LandedCost
                reader.Command.Parameters.Add("@Order_Retail", SqlDbType.Decimal).Value = objRec.OrderRetail
                reader.Command.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = objRec.IsValid

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Command.ExecuteNonQuery()

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

        End Sub

        Public Shared Function GetLocationIDByZone(ByVal zone As String) As Integer

            Dim poLocationID As Integer = 0
            Dim sql As String = "PO_Location_Get_By_Constant"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Constant", SqlDbType.VarChar).Value = zone
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        poLocationID = DataHelper.SmartValuesDBNull(reader.Item("ID"))
                    End With
                Loop

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

            Return poLocationID
        End Function

        Public Shared Sub UpdateSKUCacheTotals(ByVal PO_Maintenance_ID As Integer, ByVal Michaels_SKU As String, ByVal UserID As Integer)

            Dim sql As String = "PO_Maintenance_SKU_Store_CACHE_Recalculate_Totals_By_SKU"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = PO_Maintenance_ID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = Michaels_SKU
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
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

        End Sub

        Public Shared Sub UpdateSKUTotals(ByVal PO_Maintenance_ID As Integer, ByVal Michaels_SKU As String)

            Dim sql As String = "PO_Maintenance_SKU_Store_Recalculate_Totals_By_SKU"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = PO_Maintenance_ID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = Michaels_SKU
                cmd.CommandTimeout = 1800
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
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

        End Sub

    End Class
End Namespace