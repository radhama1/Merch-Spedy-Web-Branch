Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class SettingsData

        Public Shared Function GetAll() As List(Of SettingsRecord)
            Dim settings As New List(Of SettingsRecord)

            Dim sql As String = "SPD_Settings_GetAll"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        Dim setting As New SettingsRecord
                        setting.ID = .Item("ID")
                        setting.Name = DataHelper.SmartValues(.Item("Name"), "string", True)
                        setting.SettingValue = DataHelper.SmartValues(.Item("Setting_Value"), "string", True)
                        setting.SortOrder = DataHelper.SmartValues(.Item("Sort_Order"), "CInt", True)
                        setting.SettingType = DataHelper.SmartValues(.Item("Setting_Type"), "CInt", True)

                        settings.Add(setting)
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

            Return settings
        End Function

        Public Shared Function GetByName(ByVal settingName As String) As SettingsRecord
            Dim setting As New SettingsRecord

            Dim sql As String = "SPD_Settings_GetByName"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add(New SqlParameter("@Name", SqlDbType.VarChar)).Value = settingName
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        setting.ID = .Item("ID")
                        setting.Name = DataHelper.SmartValues(.Item("Name"), "string", True)
                        setting.SettingValue = DataHelper.SmartValues(.Item("Value"), "string", True)
                        setting.SortOrder = DataHelper.SmartValues(.Item("Sort_Order"), "CInt", True)
                        setting.SettingType = DataHelper.SmartValues(.Item("Setting_Type"), "CInt", True)
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

            Return setting
        End Function

    End Class

End Namespace
