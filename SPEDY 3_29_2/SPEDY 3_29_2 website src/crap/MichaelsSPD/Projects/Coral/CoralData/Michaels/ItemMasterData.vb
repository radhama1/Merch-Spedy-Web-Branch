Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ItemMasterData

        Public Function UPCExists(ByVal upc As String) As Boolean

            Dim sql As String = "Select Count(*) as UPC_Exists From SPD_Item_Master_Vendor_UPCs Where UPC = @UPC"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean
            Dim exists As Boolean = False

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@UPC", SqlDbType.NVarChar).Value = upc
                reader.CommandText = sql

                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    exists = DataHelper.SmartValues(reader.Item("UPC_Exists"), "boolean", True)
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

            Return exists

        End Function

        Public Shared Function GetBySKU(ByVal sku As String) As ItemMasterRecord
            Dim objRecord As New ItemMasterRecord

            Dim sql As String = "usp_SPD_ItemMaster_Get_By_SKU"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@SKU", SqlDbType.VarChar)
                objParam.Value = sku
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.Item = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        objRecord.ItemID = DataHelper.SmartValues(.Item("ID"), "CInt", False)
                        objRecord.ItemDescription = DataHelper.SmartValuesDBNull(.Item("Item_Desc"))
                        objRecord.VendorStyleNum = DataHelper.SmartValuesDBNull(.Item("Vendor_Style_Num"))
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "CLng", False)
                    End With

                End If

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

        Public Shared Function GetBySKUVendor(ByVal sku As String, ByVal vendorNumber As Integer) As ItemMasterRecord
            Dim objRecord As New ItemMasterRecord

            Dim sql As String = "usp_SPD_ItemMaster_Get_By_SKU_Vendor"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@SKU", SqlDbType.VarChar).Value = sku
                reader.Command.Parameters.Add("@VendorNbr", SqlDbType.BigInt).Value = vendorNumber

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.Item = DataHelper.SmartValuesDBNull(.Item("Michaels_SKU"))
                        objRecord.ItemID = DataHelper.SmartValues(.Item("ID"), "CInt", False)
                        objRecord.ItemDescription = DataHelper.SmartValuesDBNull(.Item("Item_Desc"))
                        objRecord.VendorStyleNum = DataHelper.SmartValuesDBNull(.Item("Vendor_Style_Num"))
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "CLng", False)
                    End With

                End If

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

    End Class

End Namespace


