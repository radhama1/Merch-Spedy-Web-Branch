Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities


Public Class DataUtilities

    Public Shared Function RunSQL(ByVal SQLStr As String) As Boolean
        Dim retValue As Boolean = True
        Dim cmd As DBCommand = Nothing
        Dim conn As DBConnection = Nothing
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection()
            cmd = New DBCommand(conn, SQLStr, CommandType.Text)
            cmd.ExecuteNonQuery()

        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            retValue = False
            'Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
            retValue = False
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
        Return retValue
    End Function

    Public Shared Function GetDBReader(ByVal SQLStr As String) As NovaLibra.Coral.Data.DBReader
        Dim reader As DBReader = Nothing
        Dim conn As DBConnection = Nothing
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn, SQLStr, CommandType.Text)
            reader.Open()
        Catch ex As Exception
            Logger.LogError(ex)
            If Not reader Is Nothing Then
                reader.Close()
                reader.Dispose()
            End If
            reader = Nothing
            If Not conn Is Nothing Then
                conn.Close()
                conn.Dispose()
                conn = Nothing
            End If
            Throw ex
        End Try
        Return reader
    End Function

    Public Shared Function FillTable(ByVal sql As String) As DataTable

        Dim command As DBCommand
        Dim table As DataTable
        Dim adapter As SqlDataAdapter
        Try
            command = New DBCommand
            command.Connection = Utilities.ApplicationHelper.GetAppConnection()
            command.CommandText = sql
            command.CommandType = CommandType.Text

            adapter = New SqlDataAdapter(command.CommandObject)
            table = New DataTable
            adapter.Fill(table)
            Return table
        Catch ex As Exception
            Logger.LogError(ex)
            Throw ex
        Finally
            If Not adapter Is Nothing Then
                adapter.Dispose()
            End If
            If Not command Is Nothing Then
                command.Connection.Close()
                command.Dispose()
            End If
        End Try

    End Function

End Class
