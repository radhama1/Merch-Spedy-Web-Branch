Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsItemMapping

        ' ****************
        ' * ITEM MAPPING *
        ' ****************

        Public Function GetMapping(ByVal mappingName As String, ByVal mappingVersion As String) As ItemMapping
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping = Nothing
            Try
                Dim objData As New NLData.Michaels.ItemMappingData()
                objRecord = objData.GetItemList(mappingName, mappingVersion)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemMapping()
                End If
            End Try
            Return objRecord
        End Function

    End Class

End Namespace

