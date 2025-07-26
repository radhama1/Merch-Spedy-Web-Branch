
Namespace Security

    Public Class UserLogin
        ' private fields
        Private _ID As Long
        Private _GUID As Guid
        Private _username As String
        Private _password As String
        Private _firstName As String
        Private _lastName As String
        Private _emailAddress As String
        Private _organization As String
        Private _jobTitle As String
        Private _enabled As Boolean
        Private _loginCode As UserLoginCode

        ' constructors
        Public Sub New()
            _ID = 0
            _GUID = GUID.Empty
            _username = String.Empty
            _password = String.Empty
            _firstName = String.Empty
            _lastName = String.Empty
            _emailAddress = String.Empty
            _organization = String.Empty
            _jobTitle = String.Empty
            _enabled = False
            _loginCode = UserLoginCode.LoginDefault
        End Sub

        Public Sub New(ByVal ID As Long, _
            ByVal GUID As Guid, _
            ByVal username As String, _
            ByVal password As String, _
            ByVal firstName As String, _
            ByVal lastName As String, _
            ByVal emailAddress As String, _
            ByVal organization As String, _
            ByVal jobTitle As String, _
            ByVal enabled As Boolean)

            _ID = ID
            _GUID = GUID
            _username = username
            _password = password
            _firstName = firstName
            _lastName = lastName
            _emailAddress = emailAddress
            _organization = organization
            _jobTitle = jobTitle
            _enabled = enabled
        End Sub

        ' properties
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

        Public Property Username() As String
            Get
                Return _username
            End Get
            Set(ByVal value As String)
                _username = value
            End Set
        End Property

        Public Property Password() As String
            Get
                Return _password
            End Get
            Set(ByVal value As String)
                _password = value
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

        Public Property Enabled() As Boolean
            Get
                Return _enabled
            End Get
            Set(ByVal value As Boolean)
                _enabled = value
            End Set
        End Property

        Public Property LoginCode() As UserLoginCode
            Get
                Return _loginCode
            End Get
            Set(ByVal value As UserLoginCode)
                _loginCode = value
            End Set
        End Property

        ' methods

        ' destructor

    End Class

End Namespace
