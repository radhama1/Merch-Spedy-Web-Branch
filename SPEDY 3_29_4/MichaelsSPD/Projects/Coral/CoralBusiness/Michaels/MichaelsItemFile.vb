Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsItemFile

        Public Function GetFileID(ByVal itemType As String, ByVal itemID As Long, ByVal fileType As ItemFileType) As Long

            Dim FileID As Long

            Try
                Dim objData As New NLData.Michaels.ItemFileData()
                FileID = objData.GetFileID(itemType, itemID, fileType)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                FileID = 0
            End Try

            Return FileID

        End Function

        Public Function AddRecord(ByVal itemType As String, ByVal itemID As Long, ByVal fileID As Long, ByVal fileType As ItemFileType, ByVal userID As Integer, Optional ByVal isDirty As Boolean = True) As Long

            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.ItemFileData()
                recordID = objData.AddRecord(itemType, itemID, fileID, fileType, userID, isDirty)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID

        End Function

        Public Function DeleteRecord(ByVal itemType As String, ByVal itemID As Long, ByVal fileID As Long) As Boolean

            Dim bSuccess As Boolean
            Try
                Dim objData As New NLData.Michaels.ItemFileData()
                bSuccess = objData.DeleteRecord(itemType, itemID, fileID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
            Finally
                'objData = Nothing
            End Try
            Return bSuccess

        End Function

        Public Function DeleteRecord(ByVal fileID As Long) As Boolean

            Dim bSuccess As Boolean
            Try
                Dim objData As New NLData.Michaels.ItemFileData()
                bSuccess = objData.DeleteRecord(fileID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
            Finally
                'objData = Nothing
            End Try
            Return bSuccess

        End Function

    End Class

End Namespace

