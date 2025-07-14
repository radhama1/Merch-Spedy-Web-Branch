
Public Class MetadataColumn
    Private _table As MetadataTable
    Private _ID As Integer
    Private _columnName As String
    Private _displayName As String
    Private _genericType As String
    'Private _maxLength As Integer
    Private _format As String
    'Private _formatString As String
    Private _maintEditable As Boolean
    Private _columnFormat As String
    Private _treatEmptyAsZero As Boolean = False

    Public Property Table() As MetadataTable
        Get
            Return _table
        End Get
        Set(ByVal value As MetadataTable)
            _table = value
        End Set
    End Property

    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property

    Public Property ColumnName() As String
        Get
            Return _columnName
        End Get
        Set(ByVal value As String)
            _columnName = value
        End Set
    End Property

    Public Property DisplayName() As String
        Get
            Return _displayName
        End Get
        Set(ByVal value As String)
            _displayName = value
        End Set
    End Property

    Public Property GenericType() As String
        Get
            Return _genericType
        End Get
        Set(ByVal value As String)
            _genericType = value
        End Set
    End Property

    'Public Property MaxLength() As Integer
    '    Get
    '        Return _maxLength
    '    End Get
    '    Set(ByVal value As Integer)
    '        _maxLength = value
    '    End Set
    'End Property

    Public Property Format() As String
        Get
            Return _format
        End Get
        Set(ByVal value As String)
            _format = value
        End Set
    End Property

    'Public Property FormatString() As String
    '    Get
    '        Return _formatString
    '    End Get
    '    Set(ByVal value As String)
    '        _formatString = value
    '    End Set
    'End Property

    Public Property MaintEditable() As Boolean
        Get
            Return _maintEditable
        End Get
        Set(ByVal value As Boolean)
            _maintEditable = value
        End Set
    End Property

    Public Property ColumnFormat() As String
        Get
            Return _columnFormat
        End Get
        Set(ByVal value As String)
            _columnFormat = value
        End Set
    End Property

    Public Property TreatEmptyAsZero() As Boolean
        Get
            Return _treatEmptyAsZero
        End Get
        Set(ByVal value As Boolean)
            _treatEmptyAsZero = value
        End Set
    End Property

End Class
