Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks


Public Class SystemListValues

    Public Shared Function GetListValueGroup(ByVal groupName) As NovaLibra.Coral.SystemFrameworks.ListValueGroup
        Dim objRecord As NovaLibra.Coral.SystemFrameworks.ListValueGroup = Nothing
        Try
            objRecord = NLData.ListValues.GetListValueGroup(groupName)
        Catch ex As Exception
            Logger.LogError(ex)
            If objRecord Is Nothing Then
                objRecord = New NovaLibra.Coral.SystemFrameworks.ListValueGroup
            End If
        End Try
        Return objRecord
    End Function

    Public Shared Function GetListValueGroups(ByVal groupNames) As NovaLibra.Coral.SystemFrameworks.ListValueGroups
        Dim objRecord As NovaLibra.Coral.SystemFrameworks.ListValueGroups = Nothing
        Try
            objRecord = NLData.ListValues.GetListValueGroups(groupNames)
        Catch ex As Exception
            Logger.LogError(ex)
            If objRecord Is Nothing Then
                objRecord = New NovaLibra.Coral.SystemFrameworks.ListValueGroups
            End If
        End Try
        Return objRecord
    End Function

End Class
