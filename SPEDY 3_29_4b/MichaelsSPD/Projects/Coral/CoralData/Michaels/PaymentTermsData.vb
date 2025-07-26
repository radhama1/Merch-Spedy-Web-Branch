Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class PaymentTermsData

        Public Shared Function GetByID(ByVal ID As Integer) As PaymentTerm
            Dim term As New PaymentTerm

            Dim sql As String = "PO_Payment_Terms_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = ID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        term = New PaymentTerm(.Item("ID"), .Item("Terms"), .Item("Terms_Desc"))

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

            Return term

        End Function

        Public Shared Function GetByTerm(ByVal terms As String) As PaymentTerm
            Dim term As New PaymentTerm

            Dim sql As String = "PO_Payment_Terms_Get_By_Term"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Term", SqlDbType.VarChar).Value = terms
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        term = New PaymentTerm(.Item("ID"), .Item("Terms"), .Item("Terms_Desc"))
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

            Return term

        End Function

    End Class

End Namespace