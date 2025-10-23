Imports System
Imports System.Web

Imports Microsoft.VisualBasic

Public Class UserManager

    Public Shared Function GetCurrentUser() As CurrentUser
        Dim objSession As HttpSessionState = HttpContext.Current.Session
        Dim objUser As CurrentUser
        If Not objSession(WebConstants.SESSION_CURRENT_USER) Is Nothing Then
            objUser = CType(objSession(WebConstants.SESSION_CURRENT_USER), CurrentUser)
        Else
            objUser = New CurrentUser()
        End If
        Return objUser
    End Function

    Public Shared Sub SetCurrentUser(ByVal objUser As CurrentUser)
        Dim objSession As HttpSessionState = HttpContext.Current.Session
        objSession(WebConstants.SESSION_CURRENT_USER) = objUser
    End Sub

    Public Shared Function GetCurrentUserName() As String
        Dim objUser As CurrentUser = GetCurrentUser()
        Return objUser.FirstName & " " & objUser.LastName
    End Function

    Public Shared Function GetCurrentUserGuid() As String
        Dim objUser As CurrentUser = GetCurrentUser()
        Return "{" & objUser.GUID.ToString() & "}"
    End Function

    Public Shared Function CanUserAccessAdmin() As Boolean
        Dim objUser As CurrentUser = GetCurrentUser()
        Return ((objUser.Access And CurrentUserAccess.AdminAccess) = CurrentUserAccess.AdminAccess)
    End Function

    Public Shared Function CanUserAdd() As Boolean
        Dim objUser As CurrentUser = GetCurrentUser()
        Return ((objUser.Access And CurrentUserAccess.CanAdd) = CurrentUserAccess.CanAdd)
    End Function

    Public Shared Function CanUserEdit() As Boolean
        Dim objUser As CurrentUser = GetCurrentUser()
        Return ((objUser.Access And CurrentUserAccess.CanEdit) = CurrentUserAccess.CanEdit)
    End Function

    Public Shared Function CanUserAddEdit() As Boolean
        Return (CanUserAdd() And CanUserEdit())
    End Function

    Public Shared Function CanUserDelete() As Boolean
        Dim objUser As CurrentUser = GetCurrentUser()
        Return ((objUser.Access And CurrentUserAccess.CanDelete) = CurrentUserAccess.CanDelete)
    End Function
End Class
