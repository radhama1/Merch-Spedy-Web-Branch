Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

	Public Class POMaintenanceSKUData

		Public Shared Sub AddSKU(ByVal POID As Long, ByVal objRecord As POMaintenanceSKURecord, ByVal UserID As Integer)

            Dim sql As String = "PO_Maintenance_Add_SKU"
			Dim cmd As DBCommand = Nothing
			Dim conn As DBConnection = Nothing
			Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = POID
                cmd.Parameters.Add("@SKU", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.MichaelsSKU, True)
                cmd.Parameters.Add("@UPC", SqlDbType.VarChar).Value = DataHelper.SmartValuesDBNull(objRecord.UPC, True)
                cmd.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = objRecord.IsValid
                cmd.Parameters.Add("@Is_WS_Valid", SqlDbType.Bit).Value = objRecord.IsWSValid
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

        Public Shared Function GetRecentRevisionRecord(ByVal poMaintenanceID As Long?, ByVal sku As String) As POMaintenanceSKURecord
            Dim skuRecord As New POMaintenanceSKURecord
            Dim sql As String = "PO_History_Maintenance_SKU_Get_Recent_Revision"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                reader.Command.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()
                    With reader

                        skuRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        skuRecord.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        skuRecord.UPC = DataHelper.SmartValuesDBNull(.Item("UPC"))
                        skuRecord.UnitCost = DataHelper.SmartValuesDBNull(.Item("Unit_Cost"))
                        skuRecord.InnerPack = DataHelper.SmartValuesDBNull(.Item("Inner_Pack"))
                        skuRecord.MasterPack = DataHelper.SmartValuesDBNull(.Item("Master_Pack"))
                        skuRecord.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        skuRecord.IsWSValid = DataHelper.SmartValuesDBNull(.Item("Is_WS_Valid"))
                        skuRecord.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        skuRecord.ReceivedQty = DataHelper.SmartValuesDBNull(.Item("Received_Qty"))
                        skuRecord.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        skuRecord.CancelCode = DataHelper.SmartValuesDBNull(.Item("Cancel_Code"))

                    End With
                End While

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

            Return skuRecord

        End Function

        Public Shared Function GetSKUTableByPOID(ByVal poID As Long?, ByVal userID As Integer) As DataTable
            Dim skuTable As New DataTable

            Dim sql As String = "PO_Maintenance_SKU_Get_Details"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                adapter = New SqlDataAdapter(command.CommandObject)
                adapter.Fill(skuTable)
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return skuTable
        End Function

        Public Shared Function GetSKUsByPOID(ByVal poID As Long) As List(Of POMaintenanceSKURecord)
            Dim recordList As New List(Of POMaintenanceSKURecord)
            Dim sql As String = "PO_Maintenance_SKU_Get_By_POID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@POID", SqlDbType.BigInt)
                objParam.Value = poID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()
                    With reader

                        Dim objRecord As New POMaintenanceSKURecord
                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.POMaintenanceID = DataHelper.SmartValuesDBNull(.Item("PO_Maintenance_ID"))
                        objRecord.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        objRecord.UPC = DataHelper.SmartValuesDBNull(.Item("UPC"))
                        objRecord.UnitCost = DataHelper.SmartValuesDBNull(.Item("Unit_Cost"))
                        objRecord.InnerPack = DataHelper.SmartValuesDBNull(.Item("Inner_Pack"))
                        objRecord.MasterPack = DataHelper.SmartValuesDBNull(.Item("Master_Pack"))
                        objRecord.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        objRecord.IsWSValid = DataHelper.SmartValuesDBNull(.Item("Is_WS_Valid"))
                        objRecord.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        objRecord.CalculatedOrderTotalQty = DataHelper.SmartValuesDBNull(.Item("Calculated_Order_Total_Qty"))
                        objRecord.LocationTotalQty = DataHelper.SmartValuesDBNull(.Item("Location_Total_Qty"))
                        objRecord.ReceivedQty = DataHelper.SmartValuesDBNull(.Item("Received_Qty"))
                        objRecord.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        objRecord.CancelCode = DataHelper.SmartValuesDBNull(.Item("Cancel_Code"))
                        objRecord.ItemTypeAttribute = DataHelper.SmartValuesDBNull(.Item("Item_Type_Attribute"))
                        objRecord.DefaultUPC = DataHelper.SmartValuesDBNull(.Item("Default_UPC"))

                        recordList.Add(objRecord)
                    End With
                End While

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

            Return recordList
        End Function

        Public Shared Function GetSKUsCACHEByPOID(ByVal poID As Long, ByVal userID As Integer) As List(Of POMaintenanceSKURecord)
            Dim recordList As New List(Of POMaintenanceSKURecord)
            Dim sql As String = "PO_Maintenance_SKU_CACHE_Get_By_POID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()
                    With reader

                        Dim objRecord As New POMaintenanceSKURecord
                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.POMaintenanceID = DataHelper.SmartValuesDBNull(.Item("PO_Maintenance_ID"))
                        objRecord.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        objRecord.UPC = DataHelper.SmartValuesDBNull(.Item("UPC"))
                        objRecord.UnitCost = DataHelper.SmartValuesDBNull(.Item("Unit_Cost"))
                        objRecord.InnerPack = DataHelper.SmartValuesDBNull(.Item("Inner_Pack"))
                        objRecord.MasterPack = DataHelper.SmartValuesDBNull(.Item("Master_Pack"))
                        objRecord.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        objRecord.IsWSValid = DataHelper.SmartValuesDBNull(.Item("Is_WS_Valid"))
                        objRecord.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        objRecord.CalculatedOrderTotalQty = DataHelper.SmartValuesDBNull(.Item("Calculated_Order_Total_Qty"))
                        objRecord.LocationTotalQty = DataHelper.SmartValuesDBNull(.Item("Location_Total_Qty"))
                        objRecord.ReceivedQty = DataHelper.SmartValuesDBNull(.Item("Received_Qty"))
                        objRecord.CancelledQty = DataHelper.SmartValuesDBNull(.Item("Cancelled_Qty"))
                        objRecord.CancelCode = DataHelper.SmartValuesDBNull(.Item("Cancel_Code"))
                        objRecord.ItemTypeAttribute = DataHelper.SmartValuesDBNull(.Item("Item_Type_Attribute"))

                        recordList.Add(objRecord)
                    End With
                End While

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

            Return recordList
        End Function

        Public Shared Sub UpdateAllocTotals(ByVal poMaintenanceID As Long?, ByVal sku As String, ByVal landedCost As Decimal, ByVal orderRetail As Decimal)
            Dim sql As String = "PO_Maintenance_SKU_Update_Alloc_Totals"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                cmd.Parameters.Add("@Landed_Cost", SqlDbType.Decimal).Value = landedCost
                cmd.Parameters.Add("@Order_Retail", SqlDbType.Decimal).Value = orderRetail

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

        Public Shared Sub UpdateSKUCACHE(ByVal poMaintenanceID As Long?, ByVal objRecord As POMaintenanceSKURecord, ByVal userID As Integer)
            Dim sql As String = "PO_Maintenance_SKU_CACHE_Update"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.CommandTimeout = 1800
                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poMaintenanceID
                'cmd.Parameters.Add("@ID", SqlDbType.BigInt).Value = objRecord.ID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = objRecord.MichaelsSKU
                cmd.Parameters.Add("@UPC", SqlDbType.VarChar).Value = objRecord.UPC
                cmd.Parameters.Add("@Default_UPC", SqlDbType.VarChar).Value = objRecord.DefaultUPC
                cmd.Parameters.Add("@Unit_Cost", SqlDbType.Money).Value = objRecord.UnitCost
                cmd.Parameters.Add("@Inner_Pack", SqlDbType.Int).Value = objRecord.InnerPack
                cmd.Parameters.Add("@Master_Pack", SqlDbType.Int).Value = objRecord.MasterPack
                cmd.Parameters.Add("@Calculated_Order_Total_Qty", SqlDbType.Int).Value = objRecord.CalculatedOrderTotalQty
                cmd.Parameters.Add("@Location_Total_Qty", SqlDbType.Int).Value = objRecord.LocationTotalQty
                cmd.Parameters.Add("@Ordered_Qty", SqlDbType.Int).Value = objRecord.OrderedQty
                cmd.Parameters.Add("@Received_Qty", SqlDbType.Int).Value = objRecord.ReceivedQty
                cmd.Parameters.Add("@Cancelled_Qty", SqlDbType.Int).Value = objRecord.CancelledQty
                cmd.Parameters.Add("@Cancel_Code", SqlDbType.Char).Value = objRecord.CancelCode
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

        Public Shared Sub UpdateSKUCacheTotalsByPOID(ByVal poMaintenanceID As Integer, ByVal User_ID As Integer)

            Dim sql As String = "PO_Maintenance_SKU_Store_CACHE_Recalculate_Totals_By_POID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = User_ID
                cmd.CommandText = sql
                cmd.CommandTimeout = 3600
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

        Public Shared Sub UpdateCacheValidity(ByVal poMaintenanceID As Long?, ByVal sku As String, ByVal isValid As Boolean?, ByVal isWSValid As Boolean?, ByVal userID As Integer)

            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandText = "PO_Maintenance_SKU_CACHE_Update_Validity"

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                cmd.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = isValid
                cmd.Parameters.Add("@Is_WS_Valid", SqlDbType.Bit).Value = isWSValid
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID

                cmd.Connection.Open()

                cmd.ExecuteNonQuery()
            Catch ex As Exception
                Throw ex
            Finally
                If Not cmd.Connection Is Nothing Then cmd.Connection.Close()
            End Try
        End Sub

        Public Shared Sub UpdateValidity(ByVal poMaintenanceID As Long?, ByVal sku As String, ByVal isValid As Boolean?, ByVal isWSValid As Boolean?)

            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandText = "PO_Maintenance_SKU_Update_Validity"

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                cmd.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = isValid
                cmd.Parameters.Add("@Is_WS_Valid", SqlDbType.Bit).Value = isWSValid
                cmd.Connection.Open()

                cmd.ExecuteNonQuery()
            Catch ex As Exception
                Throw ex
            Finally
                If Not cmd.Connection Is Nothing Then cmd.Connection.Close()
            End Try
        End Sub

        Public Shared Sub UpdateSKUDefaultUPC(ByVal poMaintenanceID As Long, ByVal sku As String, ByVal defaultUPC As String)
            Dim sql As String = "PO_Maintenance_SKU_Update_Default_UPC"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                cmd.Parameters.Add("@Default_UPC", SqlDbType.VarChar).Value = defaultUPC

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

        Public Shared Function AddedByRMS(ByVal poMaintenanceID As Long, ByVal sku As String) As Boolean

            Dim _addedByRMS As Boolean = False

            Dim sql As String = "Select Added_By_RMS From PO_Maintenance_SKU Where PO_Maintenance_ID = @PO_Maintenance_ID And Michaels_SKU = @Michaels_SKU"
            Dim command As DBCommand

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.Text
                command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                command.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku

                _addedByRMS = DataHelper.SmartValue(command.CommandObject.ExecuteScalar(), "CBool", False)

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return _addedByRMS

        End Function

	End Class
End Namespace

