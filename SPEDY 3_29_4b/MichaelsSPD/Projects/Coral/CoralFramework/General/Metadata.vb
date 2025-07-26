
Public Class Metadata
    Private _tableIDHash As Hashtable = Nothing
    Private _tableNameHash As Hashtable = Nothing

    Public Sub New()
        _tableIDHash = New Hashtable()
        _tableNameHash = New Hashtable()
    End Sub

    Protected Overrides Sub Finalize()
        If Not _tableIDHash Is Nothing Then
            _tableIDHash.Clear()
            _tableIDHash = Nothing
        End If
        If Not _tableNameHash Is Nothing Then
            _tableNameHash.Clear()
            _tableNameHash = Nothing
        End If
        MyBase.Finalize()
    End Sub

    Public Sub AddTable(ByRef table As MetadataTable)
        If _tableIDHash.Contains(table.ID) Then _tableIDHash.Remove(table.ID)
        _tableIDHash.Add(table.ID, table)
        If _tableNameHash.Contains(table.TableName) Then _tableNameHash.Remove(table.TableName)
        _tableNameHash.Add(table.TableName, table)
    End Sub

    Public Function GetTableByID(ByVal tableID As Integer) As MetadataTable
        Dim table As MetadataTable = Nothing
        If _tableIDHash.Contains(tableID) Then
            table = _tableIDHash.Item(tableID)
        End If
        Return table
    End Function

    Public Function GetTableByName(ByVal tableName As String) As MetadataTable
        Dim table As MetadataTable = Nothing
        If _tableNameHash.Contains(tableName) Then
            table = _tableNameHash.Item(tableName)
        End If
        Return table
    End Function

    Public Sub AddTableRelationship(ByVal parentTableID As Integer, ByVal parentColumnID As Integer, ByVal childTableID As Integer, ByVal childColumnID As Integer)
        Dim parent As MetadataTable = Me.GetTableByID(parentTableID)
        Dim child As MetadataTable = Me.GetTableByID(childTableID)
        Dim parentCol As MetadataColumn = Nothing, childCol As MetadataColumn = Nothing
        If Not parent Is Nothing Then parentCol = parent.GetColumnByID(parentColumnID)
        If Not child Is Nothing Then childCol = child.GetColumnByID(childColumnID)
        If Not parentCol Is Nothing And Not childCol Is Nothing Then
            Dim rel As New MetadataTableRelationship()
            rel.ChildColumn = childCol
            rel.ChildTable = child
            rel.ParentColumn = parentCol
            rel.ParentTable = parent
            child.AddParentRelationship(rel)
            parent.AddChildRelationship(rel)
        End If
    End Sub

End Class
