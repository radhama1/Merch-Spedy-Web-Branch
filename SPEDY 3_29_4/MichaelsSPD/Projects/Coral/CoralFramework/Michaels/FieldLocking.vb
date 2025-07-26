

Namespace Michaels

    Public Class FieldLocking

        Private _userID As Long
        Private _tableID As MetadataTable
        Private _tableName As String
        Private _columns As ArrayList = Nothing

        Public Sub New()
            Me.New(Long.MinValue, MetadataTable.Unknown, String.Empty, New ArrayList())
        End Sub

        Public Sub New(ByVal userID As Long, ByVal tableID As MetadataTable)
            Me.New(userID, tableID, String.Empty, New ArrayList())
        End Sub

        Public Sub New(ByVal userID As Long, ByVal tableID As MetadataTable, ByVal tableName As String)
            Me.New(userID, tableID, tableName, New ArrayList())
        End Sub

        Public Sub New(ByVal userID As Long, ByVal tableID As MetadataTable, ByVal tableName As String, ByRef columns As ArrayList)
            _userID = Long.MinValue
            _tableID = tableID
            _tableName = tableName
            _columns = columns
        End Sub

        Protected Overrides Sub Finalize()
            RemoveAll()
            _columns = Nothing
            MyBase.Finalize()
        End Sub

        Public Property userID() As Long
            Get
                Return _userID
            End Get
            Set(ByVal value As Long)
                _userID = value
            End Set
        End Property
        Public Property TableID() As MetadataTable
            Get
                Return _tableID
            End Get
            Set(ByVal value As MetadataTable)
                _tableID = value
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

        Public Function Add(ByVal value As Object) As Integer
            Return _columns.Add(value)
        End Function

        Public Function Add(ByVal ID As Integer, ByVal columnName As String, ByVal displayName As String, ByVal sortOrder As String, Optional ByVal permission As Char = "N")
            Return _columns.Add(New MetadataColumn(ID, columnName, displayName, sortOrder, permission))
        End Function

        Public Sub Insert(ByVal index As Integer, ByVal value As Object)
            _columns.Insert(index, value)
        End Sub

        Public Property Columns() As ArrayList
            Get
                Return _columns
            End Get
            Set(ByVal value As ArrayList)
                _columns = value
            End Set
        End Property

        Public ReadOnly Property Count() As Integer
            Get
                Return _columns.Count
            End Get
        End Property

        Default Public Property Item(ByVal index As Integer) As Object
            Get
                Return _columns.Item(index)
            End Get
            Set(ByVal value As Object)
                _columns.Item(index) = value
            End Set
        End Property

        Public Property Column(ByVal index As Integer) As MetadataColumn
            Get
                Dim obj As MetadataColumn = Nothing
                If index >= 0 And index < _columns.Count Then
                    obj = CType(_columns.Item(index), MetadataColumn)
                End If
                Return obj
            End Get
            Set(ByVal value As MetadataColumn)
                _columns.Item(index) = value
            End Set
        End Property

        Public Function GetColumn(ByVal columnName As String) As MetadataColumn
            Dim ret As MetadataColumn = Nothing
            For Each col As MetadataColumn In _columns
                If col.ColumnName = columnName Then
                    ret = col
                    Exit For
                End If
            Next
            Return ret
        End Function

        Public Function IsColumnLocked(ByVal columnName As String) As Boolean
            Dim ret As Boolean = False
            For Each col As MetadataColumn In _columns
                If col.ColumnName = columnName Then
                    ret = True
                    Exit For
                End If
            Next
            Return ret
        End Function

        Public Sub RemoteAt(ByVal index As Integer)
            If index > 0 AndAlso index <= _columns.Count - 1 Then
                _columns.RemoveAt(index)
            End If
        End Sub

        Public Sub RemoveAll()
            Do While _columns.Count > 0
                _columns.RemoveAt(0)
            Loop
        End Sub
    End Class

End Namespace

