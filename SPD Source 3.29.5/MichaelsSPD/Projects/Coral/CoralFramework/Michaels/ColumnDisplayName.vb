
Namespace Michaels

    Public Class ColumnDisplayName

        Private _ID As Integer?
        Private _ColumnType As String
        Private _ColumnName As String
        Private _ColumnOrdinal As Integer
        Private _ColumnGenericType As String
        Private _ColumnFormat As String
        Private _ColumnFormatString As String
        Private _FixedColumn As Boolean
        Private _AllowSort As Boolean
        Private _AllowFilter As Boolean
        Private _AllowUserDisable As Boolean
        Private _AllowAdmin As Boolean
        Private _AllowAjaxEdit As Boolean
        Private _IsCustom As Boolean
        Private _DefaultuserDisplay As Boolean
        Private _Display As Boolean
        Private _DisplayName As String
        Private _DisplayWidth As Integer
        Private _MaxLength As Integer
        Private _SecurityPrivilegeConstantSuffix As String
        Private _DateLastModified As DateTime
        Private _DateCreated As DateTime
        Private _WorkflowID As Integer

        Public Property ID() As Integer?
            Get
                Return _ID
            End Get
            Set(value As Integer?)
                _ID = value
            End Set
        End Property

        Public Property ColumnType() As String
            Get
                Return _ColumnType
            End Get
            Set(value As String)
                _ColumnType = value
            End Set
        End Property

        Public Property ColumnName() As String
            Get
                Return _ColumnName
            End Get
            Set(value As String)
                _ColumnName = value
            End Set
        End Property

        Public Property ColumnOrdinal() As Integer
            Get
                Return _ColumnOrdinal
            End Get
            Set(value As Integer)
                _ColumnOrdinal = value
            End Set
        End Property

        Public Property ColumnGenericType() As String
            Get
                Return _ColumnGenericType
            End Get
            Set(value As String)
                _ColumnGenericType = value
            End Set
        End Property

        Public Property ColumnFormat() As String
            Get
                Return _ColumnFormat
            End Get
            Set(value As String)
                _ColumnFormat = value
            End Set
        End Property

        Public Property ColumnFormatString() As String
            Get
                Return _ColumnFormatString
            End Get
            Set(value As String)
                _ColumnFormatString = value
            End Set
        End Property

        Public Property FixedColumn() As Boolean
            Get
                Return _FixedColumn
            End Get
            Set(value As Boolean)
                _FixedColumn = value
            End Set
        End Property

        Public Property AllowSort() As Boolean
            Get
                Return _AllowSort
            End Get
            Set(value As Boolean)
                _AllowSort = value
            End Set
        End Property

        Public Property AllowFilter() As Boolean
            Get
                Return _AllowFilter
            End Get
            Set(value As Boolean)
                _AllowFilter = value
            End Set
        End Property

        Public Property AllowUserDisable() As Boolean
            Get
                Return _AllowUserDisable
            End Get
            Set(value As Boolean)
                _AllowUserDisable = value
            End Set
        End Property

        Public Property AllowAdmin() As Boolean
            Get
                Return _AllowAdmin
            End Get
            Set(value As Boolean)
                _AllowAdmin = value
            End Set
        End Property

        Public Property AllowAjaxEdit() As Boolean
            Get
                Return _AllowAjaxEdit
            End Get
            Set(value As Boolean)
                _AllowAjaxEdit = value
            End Set
        End Property

        Public Property IsCustom() As Boolean
            Get
                Return _IsCustom
            End Get
            Set(value As Boolean)
                _IsCustom = value
            End Set
        End Property

        Public Property DefaultUserDisplay() As Boolean
            Get
                Return _DefaultuserDisplay
            End Get
            Set(value As Boolean)
                _DefaultuserDisplay = value
            End Set
        End Property

        Public Property Display() As Boolean
            Get
                Return _Display
            End Get
            Set(value As Boolean)
                _Display = value
            End Set
        End Property

        Public Property DisplayName() As String
            Get
                Return _DisplayName
            End Get
            Set(value As String)
                _DisplayName = value
            End Set
        End Property

        Public Property DisplayWidth() As Integer
            Get
                Return _DisplayWidth
            End Get
            Set(value As Integer)
                _DisplayWidth = value
            End Set
        End Property

        Public Property MaxLength() As Integer
            Get
                Return _MaxLength
            End Get
            Set(value As Integer)
                _MaxLength = value
            End Set
        End Property

        Public Property SecurityPrivelegeConstantSuffix As String
            Get
                Return _SecurityPrivilegeConstantSuffix
            End Get
            Set(value As String)
                _SecurityPrivilegeConstantSuffix = value
            End Set
        End Property

        Public Property DateLastModified As DateTime
            Get
                Return _DateLastModified
            End Get
            Set(value As DateTime)
                _DateLastModified = value
            End Set
        End Property

        Public Property DateCreated As DateTime?
            Get
                Return _DateCreated
            End Get
            Set(value As DateTime?)
                _DateCreated = value
            End Set
        End Property

        Public Property WorkflowID As Integer
            Get
                Return _WorkflowID
            End Get
            Set(value As Integer)
                _WorkflowID = value
            End Set
        End Property

    End Class

End Namespace
