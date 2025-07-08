Imports Microsoft.VisualBasic
Imports System

<Serializable()> _
Public Class CurrentUser

    ' private members
    Private _ID As Long
    Private _GUID As System.Guid
    Private _firstName As String
    Private _lastName As String
    Private _username As String
    Private _emailAddress As String
    Private _organization As String
    Private _jobTitle As String
    Private _access As CurrentUserAccess


    Public Sub New()
        _ID = 0
        _GUID = GUID.Empty
        _firstName = ""
        _lastName = ""
        _username = ""
        _emailAddress = ""
        _organization = ""
        _jobTitle = ""
        _access = CurrentUserAccess.NoAccess
    End Sub

    Public Sub New(ByVal ID As Long, _
        ByVal GUID As System.Guid, _
        ByVal firstName As String, _
        ByVal lastName As String, _
        ByVal userName As String, _
        ByVal emailAddress As String, _
        ByVal organization As String, _
        ByVal jobTitle As String)

        _ID = ID
        _GUID = GUID
        _firstName = firstName
        _lastName = lastName
        _username = userName
        _emailAddress = emailAddress
        _organization = organization
        _jobTitle = jobTitle
    End Sub


    ' public properties
    Public Property ID() As Long
        Get
            Return _ID
        End Get
        Set(ByVal value As Long)
            _ID = value
        End Set
    End Property

    Public Property GUID() As Guid
        Get
            Return _GUID
        End Get
        Set(ByVal value As Guid)
            _GUID = value
        End Set
    End Property

    Public Property FirstName() As String
        Get
            Return _firstName
        End Get
        Set(ByVal value As String)
            _firstName = value
        End Set
    End Property

    Public Property LastName() As String
        Get
            Return _lastName
        End Get
        Set(ByVal value As String)
            _lastName = value
        End Set
    End Property

    Public Property Username() As String
        Get
            Return _username
        End Get
        Set(ByVal value As String)
            _username = value
        End Set
    End Property

    Public Property EmailAddress() As String
        Get
            Return _emailAddress
        End Get
        Set(ByVal value As String)
            _emailAddress = value
        End Set
    End Property

    Public Property Organization() As String
        Get
            Return _organization
        End Get
        Set(ByVal value As String)
            _organization = value
        End Set
    End Property

    Public Property JobTitle() As String
        Get
            Return _jobTitle
        End Get
        Set(ByVal value As String)
            _jobTitle = value
        End Set
    End Property

    Public Property Access() As CurrentUserAccess
        Get
            Return _access
        End Get
        Set(ByVal value As CurrentUserAccess)
            _access = value
        End Set
    End Property

End Class

Public Enum CurrentUserAccess
    NoAccess = 0
    AdminAccess = 1
    CanAccess = 2
    CanView = 4
    CanAdd = 8
    CanEdit = 16
    CanDelete = 32
End Enum
