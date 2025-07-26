
Namespace Michaels

    Public Class MetadataColumn
        Private _ID As Integer
        Private _columnName As String
        Private _displayName As String
        Private _sortOrder As String
        Private _permission As Char
        Private _controlNames As ArrayList = Nothing

        Public Sub New()
            _ID = Integer.MinValue
            _columnName = String.Empty
            _displayName = String.Empty
            _sortOrder = String.Empty
            _permission = "N"
            _controlNames = New ArrayList
        End Sub

        Public Sub New(ByVal ID As Integer, ByVal columnName As String, ByVal displayName As String, ByVal sortOrder As String, ByVal permission As Char)
            _ID = ID
            _columnName = columnName
            _displayName = displayName
            _sortOrder = sortOrder
            _permission = permission
        End Sub

        Protected Overrides Sub Finalize()
            MyBase.Finalize()
        End Sub

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
        Public Property SortOrder() As String
            Get
                Return _sortOrder
            End Get
            Set(ByVal value As String)
                _sortOrder = value
            End Set
        End Property
        Public Property Permission() As Char
            Get
                Return _permission
            End Get
            Set(ByVal value As Char)
                _permission = value
            End Set
        End Property
        Public Property ControlNames() As ArrayList
            Get
                Return _controlNames
            End Get
            Set(ByVal value As ArrayList)
                _controlNames = value
            End Set
        End Property

    End Class

End Namespace
