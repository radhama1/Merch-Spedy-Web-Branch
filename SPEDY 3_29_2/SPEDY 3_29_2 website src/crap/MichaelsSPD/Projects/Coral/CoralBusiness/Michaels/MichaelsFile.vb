Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsFile

        Public Function GetRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord

            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord = Nothing
            Try

                objRecord = NLData.Michaels.FileData.GetFileRecord(id)

            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord()
                End If
                objRecord.ID = -1

            End Try
            Return objRecord

        End Function

        Public Function SaveRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord, ByVal userID As Integer) As Long

            Dim recordID As Long
            Try

                recordID = NLData.Michaels.FileData.SaveFileRecord(objRecord, userID)

            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0

            End Try
            Return recordID

        End Function

        Public Function DeleteRecord(ByVal id As Long) As Boolean

            Dim bSuccess As Boolean
            Try

                bSuccess = NLData.Michaels.FileData.DeleteFileRecord(id)

            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False

            End Try
            Return bSuccess

        End Function

    End Class

End Namespace

