Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsFieldAuditing

        Public Function SaveAuditRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecord) As Boolean
            Dim ret As Boolean = False
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                ret = objData.SaveAuditRecord(objRecord)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
            End Try
            Return ret
        End Function


        Public Function SaveAuditRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecord, ByRef conn As NovaLibra.Coral.Data.DBConnection) As Boolean
            Dim ret As Boolean = False
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                ret = objData.SaveAuditRecord(objRecord, conn)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
            End Try
            Return ret
        End Function
    End Class

End Namespace

