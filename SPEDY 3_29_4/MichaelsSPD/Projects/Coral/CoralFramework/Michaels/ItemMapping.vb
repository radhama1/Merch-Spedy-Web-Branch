
Namespace Michaels

    Public Class ItemMapping
        Private _ID As Integer
        Private _mappingName As String
        Private _mappingVersion As String
        Private _mappingColumns As ArrayList = Nothing

        Public Sub New()
            _ID = 0
            _mappingName = String.Empty
            _mappingVersion = String.Empty
            _mappingColumns = New ArrayList()
        End Sub

        Public Sub New(ByVal ID As Integer, ByVal mappingName As String, ByVal mappingVersion As String)
            _ID = ID
            _mappingName = mappingName
            _mappingVersion = mappingVersion
            _mappingColumns = New ArrayList()
        End Sub

        Protected Overrides Sub Finalize()
            RemoveAll()
            _mappingColumns = Nothing
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
        Public Property MappingName() As String
            Get
                Return _mappingName
            End Get
            Set(ByVal value As String)
                _mappingName = value
            End Set
        End Property
        Public Property MappingVersion() As String
            Get
                Return _mappingVersion
            End Get
            Set(ByVal value As String)
                _mappingVersion = value
            End Set
        End Property

        Public Function Add(ByVal value As Object) As Integer
            Return _mappingColumns.Add(value)
        End Function

        Public Function Add(ByVal columnName As String, ByVal excelColumn As String, ByVal excelRow As Integer, ByVal columnType As String)
            Return _mappingColumns.Add(New ItemMappingColumn(columnName, excelColumn, excelRow, columnType))
        End Function

        Public Sub Insert(ByVal index As Integer, ByVal value As Object)
            _mappingColumns.Insert(index, value)
        End Sub

        Public Property ItemMappingColumns() As ArrayList
            Get
                Return _mappingColumns
            End Get
            Set(ByVal value As ArrayList)
                _mappingColumns = value
            End Set
        End Property

        Public ReadOnly Property Count() As Integer
            Get
                Return _mappingColumns.Count
            End Get
        End Property

        Default Public Property Item(ByVal index As Integer) As Object
            Get
                Return _mappingColumns.Item(index)
            End Get
            Set(ByVal value As Object)
                _mappingColumns.Item(index) = value
            End Set
        End Property

        Public Function GetMappingColumn(ByVal columnName As String) As ItemMappingColumn
            Dim ret As ItemMappingColumn = Nothing
            For Each col As ItemMappingColumn In _mappingColumns
                If col.ColumnName = columnName Then
                    ret = col
                    If columnName <> "Image" Then Exit For
                End If
            Next
            Return ret
        End Function

        Public Function GetMappingColumns(ByVal columnName As String) As ArrayList

            Dim arList As New ArrayList
            For Each col As ItemMappingColumn In _mappingColumns
                If col.ColumnName = columnName Then
                    arList.Add(col)
                End If
            Next
            Return arList

        End Function

        Public Sub RemoteAt(ByVal index As Integer)
            If index > 0 AndAlso index <= _mappingColumns.Count - 1 Then
                _mappingColumns.RemoveAt(index)
            End If
        End Sub

        Public Sub RemoveAll()
            Do While _mappingColumns.Count > 0
                _mappingColumns.RemoveAt(0)
            Loop
        End Sub
    End Class

End Namespace

