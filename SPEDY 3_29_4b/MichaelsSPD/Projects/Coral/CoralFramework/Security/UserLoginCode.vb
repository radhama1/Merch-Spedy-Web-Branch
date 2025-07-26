
' Securty Enums

Namespace Security

    Public Enum UserLoginCode
        LoginDefault = 0
        LoginSuccess = 1
        LoginUsernameNotFound = 2
        LoginInvalidPassword = 4
        LoginUserDisabled = 8
        LoginError = 16
    End Enum

End Namespace
