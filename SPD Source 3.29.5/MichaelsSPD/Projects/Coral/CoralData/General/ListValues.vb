Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks

Public Class ListValues
    Public Shared Function GetListValueGroup(ByVal groupName As String) As ListValueGroup
        Dim objGroup As ListValueGroup = New ListValueGroup(groupName)
        Dim sql As String = "sp_ListValues_GetListValueGroup"
        Dim reader As DBReader = Nothing
        Dim conn As DBConnection = Nothing
        Dim cmd As DBCommand
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn)
            cmd = reader.Command
            cmd.Parameters.Add("@listValueGroupName", SqlDbType.VarChar, 20).Value = groupName
            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()
            Do While reader.Read()
                With reader
                    objGroup.AddListValue(DataHelper.SmartValues(.Item("List_Value"), "string", False), DataHelper.SmartValues(.Item("Display_Text"), "string", False))
                End With
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
        Return objGroup
    End Function

    Public Shared Function GetListValueGroups(ByVal groupNames As String) As ListValueGroups
        Dim objLVGroups As ListValueGroups = New ListValueGroups
        'Dim objGroup As ListValueGroup = Nothing
        'Dim currentGroup As String = ""
        Dim name As String = ""
        Dim lastname As String = ""
        Dim lvg As ListValueGroup = Nothing
        Dim sql As String = "sp_ListValues_GetListValueGroups"
        Dim reader As DBReader = Nothing
        Dim conn As DBConnection = Nothing
        Dim cmd As DBCommand
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection(False)
            conn.Open()
            reader = New DBReader(conn)
            cmd = reader.Command
            cmd.Parameters.Add("@listValueGroupNames", SqlDbType.VarChar, 8000).Value = groupNames.Replace(", ", ",").Replace(" ,", ",")
            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()
            Do While reader.Read()
                With reader
                    name = DataHelper.SmartValues(.Item("List_Value_Group"), "string", False)
                    objLVGroups.AddListValue(name, DataHelper.SmartValues(.Item("List_Value"), "string", False), DataHelper.SmartValues(.Item("Display_Text"), "string", False))
                End With
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
        Return objLVGroups
    End Function
End Class
