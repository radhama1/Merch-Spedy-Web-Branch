Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsReport

        ' ***********
        ' * REPORTS *
        ' ***********

        Public Function GetReport(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReport
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReport = Nothing
            Try
                Dim objData As New NLData.Michaels.ReportData()
                objRecord = objData.GetReportRecord(id)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReport()
                End If
                objRecord.ID = -1
            Finally
                'objData = Nothing
            End Try
            Return objRecord
        End Function

        Public Function GetList() As SPEDYReportList
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReportList = Nothing
            Try
                Dim objData As New NLData.Michaels.ReportData()
                objRecord = objData.GetReportList()
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReportList()
                End If
            End Try
            Return objRecord
        End Function

        Public Function RunReport(ByRef objReport As NovaLibra.Coral.SystemFrameworks.Michaels.SPEDYReport, ByVal startDate As String, ByVal endDate As String, ByVal dept As String, ByVal stage As String, ByVal vendor As Integer, ByVal vendorFilter As Integer, ByVal itemStatus As String, ByVal sku As String, ByVal skuGroup As String, ByVal stockCategory As String, ByVal itemtype As String, ByVal workflowID As String, ByVal approver As String, ByVal hours As String, ByVal mssOrSpedy As String, ByVal pliFrench As String, poStockCategory As String, poStatus As String, poType As String, poStage As String) As DataTable
            Dim dt As DataTable = Nothing
            Try
                Dim objData As New NLData.Michaels.ReportData()
                dt = objData.CreateReportDBDataTable(objReport, startDate, endDate, dept, stage, vendor, vendorFilter, itemStatus, sku, skuGroup, stockCategory, itemtype, workflowID, approver, hours, mssOrSpedy, pliFrench, poStockCategory, poStatus, poType, poStage)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
            Finally
                'objData = Nothing
            End Try
            Return dt
        End Function

    End Class

End Namespace

