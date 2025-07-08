Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ReportData

        ' ***********
        ' * REPORTS *
        ' ***********

        Public Function GetReportRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReport
            Dim objRecord As SPEDYReport = New SPEDYReport()
            Dim sql As String = "sp_SPD_Report_GetRecord"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = .Item("ID")
                        objRecord.ReportName = DataHelper.SmartValues(.Item("Report_Name"), "string", True)
                        objRecord.ReportSummary = DataHelper.SmartValues(.Item("Report_Summary"), "string", True)
                        objRecord.ReportConstant = DataHelper.SmartValues(.Item("Report_Constant"), "string", True)
                        objRecord.ReportSQL = DataHelper.SmartValues(.Item("Report_SQL"), "string", True)
                        objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", False)
                    End With
                Else
                    objRecord.ID = 0
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
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

        Public Function GetReportList() As SPEDYReportList
            Dim objList As SPEDYReportList = New SPEDYReportList()
            Dim objRecord As SPEDYReport
            Dim sql As String = "sp_SPD_Report_GetList"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                'cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = userID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                Do While bRead
                    objRecord = New SPEDYReport()
                    With reader
                        objRecord.ID = .Item("ID")
                        objRecord.ReportName = DataHelper.SmartValues(.Item("Report_Name"), "string", True)
                        objRecord.ReportSummary = DataHelper.SmartValues(.Item("Report_Summary"), "string", True)
                        objRecord.ReportConstant = DataHelper.SmartValues(.Item("Report_Constant"), "string", True)
                        objRecord.ReportSQL = DataHelper.SmartValues(.Item("Report_SQL"), "string", True)
                        objRecord.Enabled = DataHelper.SmartValues(.Item("Enabled"), "boolean", False)
                        objRecord.DateRangeLabel = DataHelper.SmartValues(.Item("DateRange_Label"), "string", True)
                        objRecord.IsViewable = DataHelper.SmartValues(.Item("Is_Viewable"), "boolean", True)
                        objRecord.IsEmailable = DataHelper.SmartValues(.Item("Is_Emailable"), "boolean", True)
                    End With
                    objList.ReportList.Add(objRecord)
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
            Return objList
        End Function

        Public Function CreateReportDBDataTable(ByRef objReport As NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReport, ByVal startDate As String, ByVal endDate As String, ByVal dept As String, ByVal stage As String, ByVal vendor As Integer, ByVal vendorFilter As Integer, ByVal itemStatus As String, ByVal sku As String, ByVal skuGroup As String, ByVal stockCategory As String, ByVal itemType As String, ByVal workflowID As String, ByVal approver As String, ByVal hours As String, ByVal mssOrSpedy As String, ByVal pliFrench As String, poStockCategory As String, poStatus As String, poType As String, poStage As String) As DataTable
            Dim dt As New DataTable
            Dim paramDate As Date
            Try

                Using conn As New SqlConnection(Utilities.ApplicationHelper.GetAppConnection().ConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand(objReport.ReportSQL, conn)
                        cmd.CommandType = CommandType.Text
                        cmd.CommandTimeout = 600

                        If objReport.UsesStartDateParam Then
                            'If the startdate is 99/99/9999 (which is used for the PLI Exemption report), then use a string for the @startDate
                            If startDate = "99/99/9999" Then
                                cmd.Parameters.Add("@startDate", SqlDbType.VarChar).Value = startDate
                            Else
                                paramDate = DataHelper.SmartValues(startDate, "date", True)
                                If paramDate <> Date.MinValue Then
                                    cmd.Parameters.Add("@startDate", SqlDbType.DateTime).Value = DataHelper.DBSmartValues((CType(DataHelper.SmartValues(startDate, "date", True), Date).ToString("M/d/yyyy") & " 00:00:00"), "date", True)
                                Else
                                    cmd.Parameters.Add("@startDate", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(startDate, "date", True)
                                End If
                            End If
                        End If
                        If objReport.UsesEndDateParam Then
                            'If the endDate is 99/99/9999 (which is used for the PLI Exemption report), then use a string for the @endDate
                            If endDate = "99/99/9999" Then
                                cmd.Parameters.Add("@endDate", SqlDbType.VarChar).Value = endDate
                            Else
                                paramDate = DataHelper.SmartValues(endDate, "date", True)
                                If paramDate <> Date.MinValue Then
                                    cmd.Parameters.Add("@endDate", SqlDbType.DateTime).Value = DataHelper.DBSmartValues((CType(DataHelper.SmartValues(endDate, "date", True), Date).ToString("M/d/yyyy") & " 23:59:59"), "date", True)
                                Else
                                    cmd.Parameters.Add("@endDate", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(endDate, "date", True)
                                End If
                            End If
                        End If
                        If objReport.UsesDeptParam Then
                            cmd.Parameters.Add("@dept", SqlDbType.Int).Value = DataHelper.DBSmartValues(dept, "integer", True)
                        End If
                        If objReport.UsesWorkflowParam Then
                            cmd.Parameters.Add("@workflowID", SqlDbType.Int).Value = DataHelper.DBSmartValues(workflowID, "integer", True)
                        End If
                        If objReport.UsesStageParam Then
                            cmd.Parameters.Add("@stage", SqlDbType.Int).Value = DataHelper.DBSmartValues(stage, "integer", True)
                        End If
                        If objReport.UsesVendorParam Then
                            cmd.Parameters.Add("@vendor", SqlDbType.Int).Value = DataHelper.DBSmartValues(vendor, "integer", True)
                        End If
                        If objReport.UsesVendorFilterParam Then
                            cmd.Parameters.Add("@vendorFilter", SqlDbType.Int).Value = DataHelper.DBSmartValues(vendorFilter, "integer", True)
                        End If
                        If objReport.UsesStatusParam Then
                            cmd.Parameters.Add("@itemStatus", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(itemStatus, "String", True)
                        End If
                        If objReport.UsesSKUParam Then
                            cmd.Parameters.Add("@sku", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(sku, "String", True)
                        End If
                        If objReport.UsesSKUGroupParam Then
                            cmd.Parameters.Add("@itemGroup", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(skuGroup, "String", True)
                        End If
                        If objReport.UsesStockCategoryParam Then
                            cmd.Parameters.Add("@stockCategory", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(stockCategory, "String", True)
                        End If
                        If objReport.UsesItemTypeParam Then
                            cmd.Parameters.Add("@itemType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(itemType, "String", True)
                        End If
                        If objReport.UsesApproverParam Then
                            cmd.Parameters.Add("@approver", SqlDbType.Int).Value = DataHelper.DBSmartValues(approver, "integer", True)
                        End If
                        If objReport.UsesHoursParam Then
                            cmd.Parameters.Add("@hours", SqlDbType.Int).Value = DataHelper.DBSmartValues(hours, "integer", True)
                        End If
                        If objReport.UsesMSSOrSPEDYParam Then
                            cmd.Parameters.Add("@mssOrSpedy", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(mssOrSpedy, "String", True)
                        End If
                        If objReport.UsesPLIFrenchParam Then
                            cmd.Parameters.Add("@pliFrench", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(pliFrench, "String", True)
                        End If
                        If objReport.UsesPOStockCategoryParam Then
                            cmd.Parameters.Add("@poStockCategory", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(poStockCategory, "String", True)
                        End If
                        If objReport.UsesPOStatusParam Then
                            cmd.Parameters.Add("@poStatus", SqlDbType.Int).Value = DataHelper.DBSmartValues(poStatus, "integer", True)
                        End If
                        If objReport.UsesPOTypeParam Then
                            cmd.Parameters.Add("@poType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(poType, "String", True)
                        End If
                        If objReport.UsesPOStageParam Then
                            cmd.Parameters.Add("@poSTage", SqlDbType.Int).Value = DataHelper.DBSmartValues(poStage, "integer", True)
                        End If

                        Using da As New SqlDataAdapter(cmd)
                            da.SelectCommand.CommandTimeout = 600
                            da.Fill(dt)
                        End Using

                    End Using
                End Using


            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try

            Return dt
        End Function

    End Class

End Namespace


