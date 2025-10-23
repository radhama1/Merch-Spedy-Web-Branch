Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsVendor

        Public Function GetVendorRecord(ByVal vendorNumber As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.VendorRecord
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.VendorRecord = Nothing
            Try
                Dim objData As New NLData.Michaels.VendorData()
                objRecord = objData.GetVendorRecord(vendorNumber)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.VendorRecord()
                End If
                objRecord.ID = -1
                Throw ex
            End Try
            Return objRecord
        End Function

    End Class

End Namespace
