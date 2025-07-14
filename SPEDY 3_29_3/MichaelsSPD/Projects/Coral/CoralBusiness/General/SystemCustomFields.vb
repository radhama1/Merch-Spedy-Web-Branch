Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks

Public Class SystemCustomFields

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDs As ArrayList) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Return GetCustomFields(recordType, recordIDs, False)
    End Function

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDs As ArrayList, ByVal gridFieldsOnly As Boolean) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Dim objRecord As NovaLibra.Coral.SystemFrameworks.CustomFields = Nothing
        Try
            objRecord = NLData.CustomFields.GetCustomFields(recordType, recordIDs, gridFieldsOnly)
        Catch ex As Exception
            Logger.LogError(ex)
            If objRecord Is Nothing Then
                objRecord = New NovaLibra.Coral.SystemFrameworks.CustomFields
            End If
        End Try
        Return objRecord
    End Function

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDString As String) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Return GetCustomFields(recordType, recordIDString, False)
    End Function

    Public Shared Function GetCustomFields(ByVal recordType As Integer, ByVal recordIDString As String, ByVal gridFieldsOnly As Boolean) As NovaLibra.Coral.SystemFrameworks.CustomFields
        Dim objRecord As NovaLibra.Coral.SystemFrameworks.CustomFields = Nothing
        Try
            objRecord = NLData.CustomFields.GetCustomFields(recordType, recordIDString, gridFieldsOnly)
        Catch ex As Exception
            Logger.LogError(ex)
            If objRecord Is Nothing Then
                objRecord = New NovaLibra.Coral.SystemFrameworks.CustomFields
            End If
        End Try
        Return objRecord
    End Function

    Public Shared Function SaveCustomFieldValues(ByRef objCFields As NovaLibra.Coral.SystemFrameworks.CustomFields) As Boolean
        Dim success As Boolean
        Try
            success = NLData.CustomFields.SaveCustomFieldValues(objCFields)
        Catch ex As Exception
            Logger.LogError(ex)
            success = False
        Finally
            'objData = Nothing
        End Try
        Return success
    End Function

End Class
