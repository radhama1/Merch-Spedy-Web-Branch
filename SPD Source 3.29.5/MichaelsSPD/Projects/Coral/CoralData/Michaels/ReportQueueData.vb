Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

    Public Class ReportQueueData

        Public Shared Function GetByID(ByVal ID As Long) As ReportQueue
            Dim rq As New ReportQueue

            Return rq
        End Function

        Public Shared Function Save(ByVal objRecord As ReportQueue) As Integer
            Dim id As Integer

            Try
                Using conn As New SqlConnection(Utilities.ApplicationHelper.GetAppConnection().ConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("SPD_Report_Queue_InsertUpdate", conn)
                        cmd.CommandType = CommandType.StoredProcedure
                        Dim objParam As New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.Int)
                        objParam.Direction = ParameterDirection.InputOutput
                        objParam.Value = id
                        cmd.Parameters.Add(objParam)

                        cmd.Parameters.AddWithValue("@ReportID", objRecord.ReportID)
                        cmd.Parameters.AddWithValue("@ReportParameters", objRecord.ReportParameters)
                        cmd.Parameters.AddWithValue("@Enabled", objRecord.Enabled)
                        cmd.Parameters.AddWithValue("@IsReoccurring", objRecord.IsReoccurring)
                        If objRecord.LastRunDate.HasValue Then
                            cmd.Parameters.AddWithValue("@LastRunDate", objRecord.LastRunDate)
                        End If
                        If objRecord.ReportInterval.HasValue Then
                            cmd.Parameters.AddWithValue("@ReportInterval", objRecord.ReportInterval)
                        End If
                        cmd.Parameters.AddWithValue("@EmailRecipients", objRecord.EmailRecipients)
                        cmd.Parameters.AddWithValue("@ErrorMessage", objRecord.ErrorMessage)

                        cmd.ExecuteNonQuery()

                        id = cmd.Parameters("@ID").Value

                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                'ERROR LOG
                Logger.LogError(ex)

                Throw ex
            End Try

            Return id
        End Function

    End Class

End Namespace