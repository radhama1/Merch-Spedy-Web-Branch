Imports System
Imports NovaLibra.Common

Namespace Utilities

    Public NotInheritable Class ApplicationHelper

        Public Shared Function GetAppConnection() As Coral.Data.DBConnection
            Return GetAppConnection(False)
        End Function

        Public Shared Function GetAppConnection(ByVal openConnection As Boolean) As Coral.Data.DBConnection
            Dim conn As DBConnection = New DBConnection(ApplicationConnectionStrings.AppConnectionString)
            If openConnection Then
                conn.Open()
            End If
            Return conn
        End Function

        Public Shared Function GetAppSecurityConnection() As Coral.Data.DBConnection
            Dim conn As DBConnection = New DBConnection(ApplicationConnectionStrings.AppSecurityConnectionString)
            Return conn
        End Function
    End Class

End Namespace
