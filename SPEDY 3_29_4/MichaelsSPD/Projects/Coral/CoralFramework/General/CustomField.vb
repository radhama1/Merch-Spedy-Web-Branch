
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Public Class CustomField
    Private _ID As Integer = Integer.MinValue
    Private _recordType As Integer = Integer.MinValue
    Private _fieldName As String = String.Empty
    Private _fieldType As CustomFieldType = CustomFieldType.TypeUnknown
    Private _fieldLimit As Integer = Integer.MinValue
    Private _grid As Boolean = False

    Public Sub New()

    End Sub

    Public Sub New(ByVal recordType As Integer, ByVal fieldName As String, ByVal fieldType As CustomFieldType, ByVal fieldLimit As Integer)
       _recordType = recordType
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldLimit = fieldLimit
    End Sub

    Public Sub New(ByVal recordType As Integer, ByVal fieldName As String, ByVal fieldType As CustomFieldType, ByVal fieldLimit As Integer, ByVal grid As Boolean)
        _recordType = recordType
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldLimit = fieldLimit
        _grid = grid
    End Sub

    Public Sub New(ByVal ID As Integer, ByVal recordType As Integer, ByVal fieldName As String, ByVal fieldType As CustomFieldType, ByVal fieldLimit As Integer)
        _ID = ID
        _recordType = recordType
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldLimit = fieldLimit
    End Sub

    Public Sub New(ByVal ID As Integer, ByVal recordType As Integer, ByVal fieldName As String, ByVal fieldType As CustomFieldType, ByVal fieldLimit As Integer, ByVal grid As Boolean)
        _ID = ID
        _recordType = recordType
        _fieldName = fieldName
        _fieldType = fieldType
        _fieldLimit = fieldLimit
        _grid = grid
    End Sub

    Protected Overrides Sub Finalize()
        ' Custom logic
        ' Call base
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

    Public Property RecordType() As Integer
        Get
            Return _recordType
        End Get
        Set(ByVal value As Integer)
            _recordType = value
        End Set
    End Property

    Public Property FieldName() As String
        Get
            Return _fieldName
        End Get
        Set(ByVal value As String)
            _fieldName = value
        End Set
    End Property

    Public Property FieldType() As CustomFieldType
        Get
            Return _fieldType
        End Get
        Set(ByVal value As CustomFieldType)
            _fieldType = value
        End Set
    End Property

    Public Property FieldLimit() As Integer
        Get
            Return _fieldLimit
        End Get
        Set(ByVal value As Integer)
            _fieldLimit = value
        End Set
    End Property

    Public Property Grid() As Boolean
        Get
            Return _grid
        End Get
        Set(ByVal value As Boolean)
            _grid = value
        End Set
    End Property

    Public Function GetGenericType() As String
        Dim typeString As String
        Select Case _fieldType
            'Case CustomFieldType.TypeUnknown
            Case CustomFieldType.TypeBoolean
                typeString = "boolean"
            Case CustomFieldType.TypeDate
                typeString = "date"
                'Case CustomFieldType.TypeDateTime
            Case CustomFieldType.TypeDecimal
                typeString = "decimal"
            Case CustomFieldType.TypeInteger
                typeString = "integer"
            Case CustomFieldType.TypeLong
                typeString = "long"
            Case CustomFieldType.TypeMoney
                typeString = "decimal"
            Case CustomFieldType.TypePercent
                typeString = "decimal"
                'Case CustomFieldType.TypeString
                'Case CustomFieldType.TypeText
                'Case CustomFieldType.TypeTime
            Case Else
                typeString = "string"
        End Select
        Return typeString
    End Function
    Public Function GetFormat() As String
        Dim typeString As String
        Select Case _fieldType
            'Case CustomFieldType.TypeUnknown
            Case CustomFieldType.TypeBoolean
                typeString = "boolean"
            Case CustomFieldType.TypeDate
                typeString = "formatdate"
                'Case CustomFieldType.TypeDateTime
            Case CustomFieldType.TypeDecimal
                typeString = "formatnumber"
            Case CustomFieldType.TypeInteger
                typeString = "integer"
            Case CustomFieldType.TypeLong
                typeString = "long"
            Case CustomFieldType.TypeMoney
                typeString = "formatcurrency"
            Case CustomFieldType.TypePercent
                typeString = "percent"
                'Case CustomFieldType.TypeString
                'Case CustomFieldType.TypeText
                'Case CustomFieldType.TypeTime
            Case Else
                typeString = "string"
        End Select
        Return typeString
    End Function

    Public Enum CustomFieldType2
        TypeUnknown = 0     ' String
        TypeBoolean = 1     ' Integer 1|0
        TypeDate = 2        ' DateTime
        TypeDateTime = 3    ' DateTime
        TypeDecimal = 4     ' Decimal
        TypeInteger = 5     ' Integer
        TypeLong = 6        ' Integer
        TypeMoney = 7       ' Decimal (formatted $0,000.00)
        TypePercent = 8     ' Decimal (formatted 0.00%)
        TypeString = 9      ' String
        TypeText = 10       ' String
        TypeTime = 11       ' DateTime
    End Enum
End Class

