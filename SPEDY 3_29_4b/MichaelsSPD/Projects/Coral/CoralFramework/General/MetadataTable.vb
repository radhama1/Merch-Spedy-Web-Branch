
Public Class MetadataTable
    Private _ID As Integer
    Private _tableName As String
    Private _displayName As String
    ' columns
    Private _columnIDHash As Hashtable = Nothing
    Private _columnNameHash As Hashtable = Nothing
    ' parent
    Private _parentTables As List(Of MetadataTableRelationship) = Nothing
    ' child
    Private _childTables As List(Of MetadataTableRelationship) = Nothing

    Public Sub New()
        _columnIDHash = New Hashtable()
        _columnNameHash = New Hashtable()
        _parentTables = New List(Of MetadataTableRelationship)
        _childTables = New List(Of MetadataTableRelationship)
    End Sub

    Protected Overrides Sub Finalize()
        If Not _columnIDHash Is Nothing Then
            _columnIDHash.Clear()
            _columnIDHash = Nothing
        End If
        If Not _columnNameHash Is Nothing Then
            _columnNameHash.Clear()
            _columnNameHash = Nothing
        End If
        If Not _parentTables Is Nothing Then
            _parentTables.Clear()
            _parentTables = Nothing
        End If
        If Not _childTables Is Nothing Then
            _childTables.Clear()
            _childTables = Nothing
        End If
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

    Public Property TableName() As String
        Get
            Return _tableName
        End Get
        Set(ByVal value As String)
            _tableName = value
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

    Public Sub AddColumn(ByRef column As MetadataColumn)
        column.Table = Me
        If _columnIDHash.Contains(column.ID) Then _columnIDHash.Remove(column.ID)
        _columnIDHash.Add(column.ID, column)
        Dim key As String = column.ColumnName.Replace("_", "").ToLower()
        If _columnNameHash.Contains(key) Then _columnNameHash.Remove(key)
        _columnNameHash.Add(key, column)
    End Sub

    Public Function GetColumnByID(ByVal columnID As Integer) As MetadataColumn
        Dim column As MetadataColumn = Nothing
        If _columnIDHash.Contains(columnID) Then
            column = _columnIDHash.Item(columnID)
        End If
        Return column
    End Function

    Public Function GetColums() As Hashtable
        Return _columnIDHash
    End Function

    Public Function GetColumnByName(ByVal columnName As String) As MetadataColumn
        Dim column As MetadataColumn = Nothing
        Dim key As String = columnName.Replace("_", "").ToLower()
        If _columnNameHash.Contains(key) Then
            column = _columnNameHash.Item(key)
        End If
        Return column
    End Function

    Public Function DoesColumnTreatEmptyAsZero(ByVal columnName As String) As Boolean
        Dim column As MetadataColumn = Me.GetColumnByName(columnName)
        If column IsNot Nothing Then
            Return column.TreatEmptyAsZero
        Else
            Return False
        End If

    End Function

    Public Sub AddParentRelationship(ByRef relationship As MetadataTableRelationship)
        If relationship.ChildTable.ID = Me.ID And Not Me.GetColumnByID(relationship.ChildColumn.ID) Is Nothing Then
            If Not ContainsParent(relationship.ParentTable.ID) Then
                Me._parentTables.Add(relationship)
            End If
        End If
    End Sub

    Public Sub AddChildRelationship(ByRef relationship As MetadataTableRelationship)
        If relationship.ParentTable.ID = Me.ID And Not Me.GetColumnByID(relationship.ParentColumn.ID) Is Nothing Then
            If Not ContainsChild(relationship.ChildTable.ID) Then
                Me._childTables.Add(relationship)
            End If
        End If
    End Sub

    Public Function GetParentRelationships() As List(Of MetadataTableRelationship)
        Return _parentTables
    End Function

    Public Function GetChildRelationships() As List(Of MetadataTableRelationship)
        Return _childTables
    End Function

    Public Function ContainsParent(ByVal parentTableID As Integer) As Boolean
        Dim found As Boolean = False
        For i As Integer = 0 To _parentTables.Count() - 1
            If _parentTables.Item(i).ParentTable.ID = parentTableID Then
                found = True
                Exit For
            End If
        Next
        Return found
    End Function

    Public Function ContainsChild(ByVal childTableID As Integer) As Boolean
        Dim found As Boolean = False
        For i As Integer = 0 To _childTables.Count() - 1
            If _childTables.Item(i).ChildTable.ID = childTableID Then
                found = True
                Exit For
            End If
        Next
        Return found
    End Function

End Class
