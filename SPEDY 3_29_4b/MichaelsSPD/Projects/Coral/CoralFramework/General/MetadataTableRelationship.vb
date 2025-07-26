
Public Class MetadataTableRelationship
    Private _parentTable As MetadataTable = Nothing
    Private _parentColumn As MetadataColumn
    Private _childTable As MetadataTable = Nothing
    Private _childColumn As MetadataColumn

    Public Property ParentTable() As MetadataTable
        Get
            Return _parentTable
        End Get
        Set(ByVal value As MetadataTable)
            _parentTable = value
        End Set
    End Property

    Public Property ParentColumn() As MetadataColumn
        Get
            Return _parentColumn
        End Get
        Set(ByVal value As MetadataColumn)
            _parentColumn = value
        End Set
    End Property

    Public Property ChildTable() As MetadataTable
        Get
            Return _childTable
        End Get
        Set(ByVal value As MetadataTable)
            _childTable = value
        End Set
    End Property

    Public Property ChildColumn() As MetadataColumn
        Get
            Return _childColumn
        End Get
        Set(ByVal value As MetadataColumn)
            _childColumn = value
        End Set
    End Property

End Class
