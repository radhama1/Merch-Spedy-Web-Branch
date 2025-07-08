Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

    Public Class POCreationLocationSKUData

		Public Shared Sub AddSKU(ByVal POCreationID As Long, ByVal objRecord As POCreationLocationSKURecord, ByVal UserID As Integer)

            Dim sql As String = "PO_Creation_Add_SKU"
			Dim cmd As DBCommand = Nothing
			Dim conn As DBConnection = Nothing
			Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
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

        Public Shared Sub DeleteSku(ByVal poCreationID As Long?, ByVal michaelsSKU As String)
            Dim sql As String = "PO_Creation_Location_SKU_Delete"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = michaelsSKU
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

        Public Shared Function GetSKULocationsByPCLID(ByVal poCreationLocationID As Integer) As List(Of POCreationLocationSKURecord)
            Dim recordList As New List(Of POCreationLocationSKURecord)
            Dim sql As String = "PO_Creation_Location_SKU_Get_By_PCLID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@PO_Creation_Location_ID", SqlDbType.BigInt)
                objParam.Value = poCreationLocationID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()
                    With reader

                        Dim objRecord As New POCreationLocationSKURecord
                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.POCreationLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Creation_Location_ID"))
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
                        objRecord.DateCreated = DataHelper.SmartValuesDBNull(.Item("Date_Created"))
                        objRecord.CreatedUserID = DataHelper.SmartValuesDBNull(.Item("Created_User_ID"))
                        objRecord.DateLastModified = DataHelper.SmartValuesDBNull(.Item("Date_Last_Modified"))
                        objRecord.ModifiedUserID = DataHelper.SmartValuesDBNull(.Item("Modified_User_ID"))
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

        Public Shared Function GetSKUTableByPOID(ByVal poCreationID As Long?, ByVal userID As Integer) As DataTable

            Dim skuTable As New DataTable

            Dim sql As String = "[PO_Creation_Details_Get_SKUs_By_POID]"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
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

        Public Shared Function GetSKUsByPOID(ByVal poID As Long) As List(Of POCreationLocationSKURecord)
            Dim recordList As New List(Of POCreationLocationSKURecord)
            Dim sql As String = "PO_Creation_Location_SKU_Get_By_POID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@POID", SqlDbType.BigInt)
                objParam.Value = poID
                reader.Command.CommandTimeout = 600
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                While reader.Read()
                    With reader

                        Dim objRecord As New POCreationLocationSKURecord
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

        Public Shared Function GetSKUsCacheByPOID(ByVal poID As Long, ByVal userID As Integer) As List(Of POCreationLocationSKURecord)
            Dim recordList As New List(Of POCreationLocationSKURecord)
            Dim sql As String = "PO_Creation_Location_SKU_CACHE_Get_By_POID"
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

                        Dim objRecord As New POCreationLocationSKURecord
                        objRecord.MichaelsSKU = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        objRecord.UPC = DataHelper.SmartValuesDBNull(.Item("UPC"))
                        objRecord.DefaultUPC = DataHelper.SmartValuesDBNull(.Item("Default_UPC"))
                        objRecord.UnitCost = DataHelper.SmartValuesDBNull(.Item("Unit_Cost"))
                        objRecord.InnerPack = DataHelper.SmartValuesDBNull(.Item("Inner_Pack"))
                        objRecord.MasterPack = DataHelper.SmartValuesDBNull(.Item("Master_Pack"))
                        objRecord.IsValid = DataHelper.SmartValuesDBNull(.Item("Is_Valid"))
                        objRecord.IsWSValid = DataHelper.SmartValuesDBNull(.Item("Is_WS_Valid"))
                        objRecord.OrderedQty = DataHelper.SmartValuesDBNull(.Item("Ordered_Qty"))
                        objRecord.CalculatedOrderTotalQty = DataHelper.SmartValuesDBNull(.Item("Calculated_Order_Total_Qty"))
                        objRecord.LocationTotalQty = DataHelper.SmartValuesDBNull(.Item("Location_Total_Qty"))
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

        Public Shared Sub UpdateAllocTotals(ByVal poCreationID As Long?, ByVal sku As String, ByVal poLocationID As Integer, ByVal landedCost As Decimal, ByVal orderRetail As Decimal)
            Dim sql As String = "PO_Creation_Location_SKU_Update_Alloc_Totals"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
                cmd.Parameters.Add("@PO_Location_ID", SqlDbType.Int).Value = poLocationID
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

        Public Shared Sub UpdateCache(ByVal poCreationID As Long?, ByVal poLocationID As Integer, ByVal skuRecord As POCreationLocationSKURecord, ByVal userID As Integer)
            Dim sql As String = "PO_Creation_Location_SKU_CACHE_Update"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
                cmd.Parameters.Add("@PO_Location_ID", SqlDbType.Int).Value = poLocationID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = skuRecord.MichaelsSKU
                cmd.Parameters.Add("@UPC", SqlDbType.VarChar).Value = skuRecord.UPC
                cmd.Parameters.Add("@Unit_Cost", SqlDbType.Money).Value = skuRecord.UnitCost
                cmd.Parameters.Add("@Inner_Pack", SqlDbType.Int).Value = skuRecord.InnerPack
                cmd.Parameters.Add("@Master_Pack", SqlDbType.Int).Value = skuRecord.MasterPack
                cmd.Parameters.Add("@Calculated_Order_Total_Qty", SqlDbType.Int).Value = skuRecord.CalculatedOrderTotalQty
                cmd.Parameters.Add("@Ordered_Qty", SqlDbType.Int).Value = skuRecord.OrderedQty
                cmd.Parameters.Add("@Location_Total_Qty", SqlDbType.Int).Value = skuRecord.LocationTotalQty
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

        Public Shared Sub UpdateSKUCacheTotalsByPOID(ByVal PO_Creation_ID As Integer, ByVal User_ID As Integer)

            Dim sql As String = "PO_Creation_Location_SKU_Store_CACHE_Recalculate_Totals_By_POID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = PO_Creation_ID
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = User_ID
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

        Public Shared Sub UpdateSKUsByPOID(ByVal poCreationID As Long, ByVal objRecord As POCreationLocationSKURecord)
            Dim sql As String = "PO_Creation_Location_SKU_Update_By_POID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = objRecord.MichaelsSKU
                cmd.Parameters.Add("@UPC", SqlDbType.VarChar).Value = objRecord.UPC
                cmd.Parameters.Add("@Unit_Cost", SqlDbType.Money).Value = objRecord.UnitCost
                cmd.Parameters.Add("@Inner_Pack", SqlDbType.Int).Value = objRecord.InnerPack
                cmd.Parameters.Add("@Master_Pack", SqlDbType.Int).Value = objRecord.MasterPack
                cmd.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = objRecord.IsValid
                cmd.Parameters.Add("@Is_WS_Valid", SqlDbType.Bit).Value = objRecord.IsWSValid
                cmd.Parameters.Add("@Default_UPC", SqlDbType.VarChar).Value = objRecord.DefaultUPC

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

        Public Shared Sub UpdateSKUsCacheByPOID(ByVal poCreationID As Long, ByVal objRecord As POCreationLocationSKURecord, ByVal userID As Integer)
            Dim sql As String = "PO_Creation_Location_SKU_CACHE_Update_By_POID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@POID", SqlDbType.BigInt).Value = poCreationID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = objRecord.MichaelsSKU
                cmd.Parameters.Add("@UPC", SqlDbType.VarChar).Value = objRecord.UPC
                cmd.Parameters.Add("@Unit_Cost", SqlDbType.Money).Value = objRecord.UnitCost
                cmd.Parameters.Add("@Inner_Pack", SqlDbType.Int).Value = objRecord.InnerPack
                cmd.Parameters.Add("@Master_Pack", SqlDbType.Int).Value = objRecord.MasterPack
                cmd.Parameters.Add("@Is_Valid", SqlDbType.Bit).Value = objRecord.IsValid
                cmd.Parameters.Add("@Is_WS_Valid", SqlDbType.Bit).Value = objRecord.IsWSValid
                cmd.Parameters.Add("@Default_UPC", SqlDbType.VarChar).Value = objRecord.DefaultUPC
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

    End Class

End Namespace

