Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsItemMaster

        Public Shared Function UPCExists(ByVal upc As String) As Boolean

            Dim exists As Boolean = False

            Try
                Dim objData As New NLData.Michaels.ItemMasterData()
                exists = objData.UPCExists(upc)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                exists = False
            End Try

            Return exists

        End Function

    End Class

End Namespace

