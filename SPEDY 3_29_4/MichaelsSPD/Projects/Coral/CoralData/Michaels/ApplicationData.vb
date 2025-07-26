Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Collections.Generic

Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels
    Public Class Application

        Public Shared Function GetApplicationMessages() As List(Of ApplicationMessage)
            Dim sql As String = "usp_SPD_Application_GetMessages"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objRecord As ApplicationMessage
            Dim MessageList As New List(Of ApplicationMessage)
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        objRecord = New ApplicationMessage
                        objRecord.IsSpedyOnline = DataHelper.SmartValues(.Item("Is_Spedy_Online"), "boolean", True)
                        objRecord.Message = DataHelper.SmartValues(.Item("Message"), "string", True)
                        objRecord.ActiveStartDate = DataHelper.SmartValues(.Item("Active_Start_Date"), "date", True)
                        objRecord.ActiveEndDate = DataHelper.SmartValues(.Item("Active_End_Date"), "date", True)
                    End With
                    MessageList.Add(objRecord)
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
            Return MessageList

        End Function
    End Class
End Namespace

