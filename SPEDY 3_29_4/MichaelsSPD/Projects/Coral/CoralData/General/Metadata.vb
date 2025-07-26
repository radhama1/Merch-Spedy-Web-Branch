Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks

Public Class MetadataData

    Public Shared Function GetMetadata() As NovaLibra.Coral.SystemFrameworks.Metadata
        Dim md As New NovaLibra.Coral.SystemFrameworks.Metadata()
        Dim table As MetadataTable = Nothing
        Dim parent As MetadataTable = Nothing
        Dim child As MetadataTable = Nothing
        Dim parentColumn As MetadataColumn = Nothing
        Dim childColumn As MetadataColumn = Nothing
        Dim column As MetadataColumn = Nothing
        Dim tableID As Integer
        Dim parentTableID As Integer, childTableID As Integer
        Dim parentColumnID As Integer, childColumnID As Integer
        Dim rel As MetadataTableRelationship = Nothing
        Dim sql As String = "usp_Metadata_GetMetaData"
        Dim reader As DBReader = Nothing
        Dim conn As DBConnection = Nothing
        Dim cmd As DBCommand
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn)
            cmd = reader.Command
            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()

            ' MetadataTable
            Do While reader.Read()
                With reader
                    table = New MetadataTable()
                    table.ID = DataHelper.SmartValues(.Item("ID"), "integer", True)
                    table.TableName = DataHelper.SmartValues(.Item("Table_Name"), "string", True)
                    table.DisplayName = DataHelper.SmartValues(.Item("Display_Name"), "string", True)
                    md.AddTable(table)
                End With
            Loop

            ' MetadataColumn
            If reader.NextResult() Then
                Do While reader.Read()
                    With reader
                        tableID = DataHelper.SmartValues(.Item("Metadata_Table_ID"), "integer", True)
                        If table Is Nothing OrElse table.ID <> tableID Then
                            table = md.GetTableByID(tableID)
                            If table Is Nothing Then Continue Do
                        End If
                        column = New MetadataColumn()
                        column.ID = DataHelper.SmartValues(.Item("ID"), "integer", True)
                        column.ColumnName = DataHelper.SmartValues(.Item("Column_Name"), "string", True)
                        column.DisplayName = DataHelper.SmartValues(.Item("Display_Name"), "string", True)
                        column.GenericType = DataHelper.SmartValues(.Item("Column_Generic_Type"), "string", True)
                        'column.MaxLength = DataHelper.SmartValues(.Item("Max_Length"), "integer", False)
                        column.Format = DataHelper.SmartValues(.Item("Column_Format"), "string", True)
                        'column.FormatString = DataHelper.SmartValues(.Item("Column_Format_String"), "string", True)
                        column.MaintEditable = DataHelper.SmartValues(.Item("Maint_Editable"), "boolean", True)
                        column.ColumnFormat = DataHelper.SmartValues(.Item("Column_Format"), "string", True)
                        column.TreatEmptyAsZero = DataHelper.SmartValues(.Item("Treat_Empty_As_Zero"), "boolean", False)
                        table.AddColumn(column)
                    End With
                Loop
            End If

            ' MetadataTableRelationship
            If reader.NextResult() Then
                Do While reader.Read()
                    With reader
                        parentTableID = DataHelper.SmartValues(.Item("Parent_Table_ID"), "integer", True)
                        parentColumnID = DataHelper.SmartValues(.Item("Parent_Column_ID"), "integer", True)
                        childTableID = DataHelper.SmartValues(.Item("Child_Table_ID"), "integer", True)
                        childColumnID = DataHelper.SmartValues(.Item("Child_Column_ID"), "integer", True)
                        md.AddTableRelationship(parentTableID, parentColumnID, childTableID, childColumnID)
                    End With
                Loop
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
        Return md
    End Function

End Class
