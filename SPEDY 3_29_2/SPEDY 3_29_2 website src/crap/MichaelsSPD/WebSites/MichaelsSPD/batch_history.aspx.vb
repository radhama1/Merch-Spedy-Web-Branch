Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities.DataHelper

Partial Class batch_history
    Inherits MichaelsBasePage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim batchType As String = Request.Form("batch_type")
        Dim batchID As String = Request.Form("batch_id")
        Dim action As String = Request.Form("action")
        LoadBatchHistory()

    End Sub

    Private Sub LoadBatchHistory()
        rptBatchHistory.DataSource = GetBatchHistory()
        rptBatchHistory.DataBind()
    End Sub

    Private Function GetBatchHistory() As DataTable
        Dim connection As New SqlConnection(ConnectionString)
        Dim command As SqlCommand = New SqlCommand
        Dim dt As New DataTable

        Try
            command.Connection = connection
            command.CommandType = CommandType.Text
            command.CommandText = "select *, (select top 1 first_name+' '+last_name+' (x'+coalesce(office_location, '')+')' from security_user where id=modified_user) as modified_user_name from spd_batch_history, spd_workflow_stage where spd_batch_history.workflow_stage_id=spd_workflow_stage.id and spd_batch_id=" & Request("hid") & " order by spd_batch_history.id desc"
            command.CommandTimeout = 1500
            command.Connection.Open()

            Dim da As SqlDataAdapter = New SqlDataAdapter(command)
            da.Fill(dt)

            command.Connection.Close()
        Catch ex As Exception
            Logger.LogError(ex)
        Finally
            command.Dispose()
            connection.Dispose()
            command = Nothing
            connection = Nothing
        End Try

        Return dt
    End Function


End Class
