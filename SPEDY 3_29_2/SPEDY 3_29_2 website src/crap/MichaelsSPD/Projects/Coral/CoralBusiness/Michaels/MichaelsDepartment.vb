Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsDepartment

        Public Function GetDepartmentRecord(ByVal dept As Integer) As NovaLibra.Coral.SystemFrameworks.Michaels.DepartmentRecord
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.DepartmentRecord = Nothing
            Try
                Dim objData As New NLData.Michaels.DepartmentData()
                objRecord = objData.GetDepartmentRecord(dept)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.DepartmentRecord()
                End If
                objRecord.Dept = -1
                Throw ex
            End Try
            Return objRecord
        End Function

    End Class

End Namespace
