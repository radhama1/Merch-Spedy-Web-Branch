
Namespace Michaels

    Public Class ItemMappingColumn
        Private _ID As Integer
        'Private _itemMappingID As Integer
        Private _columnName As String
        Private _excelColumn As String
        Private _excelRow As Integer
        'Private _columnType As String

        Public Sub New()
            _ID = 0
            '_itemMappingID = 0
            _columnName = String.Empty
            _excelColumn = String.Empty
            _excelRow = 0
            '_columnType = String.Empty
        End Sub

        Public Sub New(ByVal ID As Integer, ByVal columnName As String, ByVal excelColumn As String, ByVal excelRow As Integer) ', ByVal columnType As String)
            _ID = ID
            '_itemMappingID = itemMappingID
            _columnName = columnName
            _excelColumn = excelColumn
            _excelRow = excelRow
            '_columnType = columnType
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
        'Public Property ItemMappingID() As Integer
        '    Get
        '        Return _itemMappingID
        '    End Get
        '    Set(ByVal value As Integer)
        '        _itemMappingID = value
        '    End Set
        'End Property
        Public Property ColumnName() As String
            Get
                Return _columnName
            End Get
            Set(ByVal value As String)
                _columnName = value
            End Set
        End Property
        Public Property ExcelColumn() As String
            Get
                Return _excelColumn
            End Get
            Set(ByVal value As String)
                _excelColumn = value
            End Set
        End Property
        Public Property ExcelRow() As Integer
            Get
                Return _excelRow
            End Get
            Set(ByVal value As Integer)
                _excelRow = value
            End Set
        End Property
        'Public Property ColumnType() As String
        '    Get
        '        Return _columnType
        '    End Get
        '    Set(ByVal value As String)
        '        _columnType = value
        '    End Set
        'End Property

    End Class

End Namespace


