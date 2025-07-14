Imports System
Imports System.Configuration
Imports NovaLibra.Common

Namespace Utilities

    Public NotInheritable Class ApplicationConnectionStrings

        Public Shared ReadOnly Property AppConnectionString() As String
            Get
                Dim str As String = System.Configuration.ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString
                If str = "" Or IsDBNull(str) Then
                    Logger.LogError(New ApplicationException(DBErrorCode.DBERR0R_NO_APP_CONNECTION_STRING))
                End If
                Return str
            End Get
        End Property

        Public Shared ReadOnly Property AppSecurityConnectionString() As String
            Get
                Dim str As String = System.Configuration.ConfigurationManager.ConnectionStrings("AppSecurityConnection").ConnectionString
                If str = "" Or IsDBNull(str) Then
                    str = AppConnectionString()
                End If
                Return str
            End Get
        End Property
    End Class

End Namespace

