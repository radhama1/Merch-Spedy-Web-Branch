'Imports System
'Imports System.Data

'Imports NovaLibra.Common
'Imports NovaLibra.Common.Utilities
'Imports NLData = NovaLibra.Coral.Data
'Imports NovaLibra.Coral.SystemFrameworks.Michaels


'Namespace Michaels

'    Public Class MichaelsImportItemFile

'        Public Function GetFileID(ByVal importItemID As Long, ByVal fileType As ItemFileType) As Long

'            Dim FileID As Long

'            Try
'                Dim objData As New NLData.Michaels.ImportItemFileData()
'                FileID = objData.GetFileID(importItemID, fileType)
'                objData = Nothing
'            Catch ex As Exception
'                Logger.LogError(ex)
'                FileID = 0
'            End Try

'            Return FileID

'        End Function

'        Public Function AddRecord(ByVal importItemID As Long, ByVal fileID As Long, ByVal fileType As ItemFileType) As Long

'            Dim recordID As Long
'            Try
'                Dim objData As New NLData.Michaels.ImportItemFileData()
'                recordID = objData.AddRecord(importItemID, fileID, fileType)
'                objData = Nothing
'            Catch ex As Exception
'                Logger.LogError(ex)
'                recordID = 0
'            Finally
'                'objData = Nothing
'            End Try
'            Return recordID

'        End Function

'        Public Function DeleteRecord(ByVal importItemID As Long, ByVal fileType As ItemFileType) As Boolean

'            Dim bSuccess As Boolean
'            Try
'                Dim objData As New NLData.Michaels.ImportItemFileData()
'                bSuccess = objData.DeleteRecordsByImportItemID(importItemID, filetype)
'                objData = Nothing
'            Catch ex As Exception
'                Logger.LogError(ex)
'                bSuccess = False
'            Finally
'                'objData = Nothing
'            End Try
'            Return bSuccess

'        End Function

'    End Class

'End Namespace

