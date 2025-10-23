Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ItemMappingData

        ' *********************
        ' * ITEM MAPPING DATA *
        ' *********************

        Public Function GetItemList(ByVal mappingName As String, ByVal mappingVersion As String) As ItemMapping
            Dim objIM As ItemMapping = New ItemMapping()
            Dim objRecord As ItemMappingColumn
            Dim sql As String = "sp_SPD_ItemMapping_GetMapping"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bRead As Boolean
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@mappingName", SqlDbType.VarChar, 20).Value = mappingName
                cmd.Parameters.Add("@mappingVersion", SqlDbType.VarChar, 20).Value = mappingVersion
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    objIM.ID = DataHelper.SmartValues(reader.Item("Item_Mapping_ID"), "integer", False)
                    objIM.MappingName = DataHelper.SmartValues(reader.Item("Mapping_Name"), "string", True)
                    objIM.MappingVersion = DataHelper.SmartValues(reader.Item("Mapping_Version"), "string", True)
                End If
                Do While bRead

                    objRecord = New ItemMappingColumn()
                    With reader

                        objRecord.ID = .Item("Item_Mapping_Column_ID")
                        objRecord.ColumnName = DataHelper.SmartValues(.Item("Column_Name"), "string", True)
                        objRecord.ExcelColumn = DataHelper.SmartValues(.Item("Excel_Column"), "string", True)
                        objRecord.ExcelRow = DataHelper.SmartValues(.Item("Excel_Row"), "integer", False)
                        'objRecord.ColumnType = DataHelper.SmartValues(.Item("Column_Generic_Type"), "string", True)

                    End With
                    objIM.Add(objRecord)
                    bRead = reader.Read()
                Loop
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
            Return objIM
        End Function
    End Class

End Namespace


