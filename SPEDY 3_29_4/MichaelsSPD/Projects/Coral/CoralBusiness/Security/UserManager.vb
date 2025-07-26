Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Security


Namespace Security

    Public Class UserManager

        Public Shared Function UserLogin(ByVal username As String, ByVal password As String) As NovaLibra.Coral.SystemFrameworks.Security.UserLogin
            Dim objSec As NLData.Security.Security = New NLData.Security.Security()
            Dim objUserLogin As NovaLibra.Coral.SystemFrameworks.Security.UserLogin = Nothing
            Try
                objUserLogin = objSec.GetSecurityUserByUserName(username)
                objSec.GetSecurityUserByUserName(username)
                If password <> objUserLogin.Password Then
                    objUserLogin.LoginCode = UserLoginCode.LoginInvalidPassword
                ElseIf objUserLogin.Enabled = False Then
                    objUserLogin.LoginCode = UserLoginCode.LoginUserDisabled
                ElseIf objUserLogin.ID = -1 Then
                    objUserLogin.LoginCode = UserLoginCode.LoginUsernameNotFound
                Else
                    objUserLogin.LoginCode = UserLoginCode.LoginSuccess
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                If objUserLogin Is Nothing Then
                    objUserLogin = New NovaLibra.Coral.SystemFrameworks.Security.UserLogin()
                End If
                objUserLogin.LoginCode = UserLoginCode.LoginError
            Finally
                objSec = Nothing
            End Try
            Return objUserLogin
        End Function

    End Class

End Namespace
