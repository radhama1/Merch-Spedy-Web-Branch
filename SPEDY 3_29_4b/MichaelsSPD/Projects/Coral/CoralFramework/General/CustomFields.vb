
Public Class CustomFields
    ' private fields
    Private _fields As ArrayList
    Private _values As Hashtable

    ' constructors
    Public Sub New()
        _fields = New ArrayList
        _values = New Hashtable
    End Sub

    Public Sub New(ByRef fields As ArrayList)
        _fields = fields
        _values = New Hashtable
    End Sub

    Public Sub New(ByRef fields As ArrayList, ByRef values As Hashtable)
        _fields = fields
        _values = values
    End Sub

    ' public properties

    Public ReadOnly Property Count() As Integer
        Get
            Return _fields.Count
        End Get
    End Property

    Default Public Property Item(ByVal index As Integer) As CustomField
        Get
            Dim field As CustomField = Nothing
            If index >= 0 AndAlso index < _fields.Count Then
                field = CType(_fields.Item(index), CustomField)
            End If
            Return field
        End Get
        Set(ByVal value As CustomField)
            If index >= 0 AndAlso index < _fields.Count Then
                _fields.Item(index) = value
            End If
        End Set
    End Property


    ' properties / methods (CustomField)

    Public ReadOnly Property Fields() As ArrayList
        Get
            Return _fields
        End Get
    End Property

    Public ReadOnly Property FieldCount() As Integer
        Get
            Return _fields.Count
        End Get
    End Property

    Public Function GetCustomField(ByVal ID As Integer) As CustomField
        Dim field As CustomField = Nothing
        For i As Integer = 0 To _fields.Count - 1
            If CType(_fields.Item(i), CustomField).ID = ID Then
                field = _fields.Item(i)
                Exit For
            End If
        Next
        Return field
    End Function

    Public Function GetCustomField(ByVal fieldName As String) As CustomField
        Dim field As CustomField = Nothing
        For i As Integer = 0 To _fields.Count - 1
            If CType(_fields.Item(i), CustomField).FieldName = fieldName Then
                field = _fields.Item(i)
                Exit For
            End If
        Next
        Return field
    End Function

    Public Function GetCustomField(ByVal fieldName As String, ByVal createNewIfNotExists As Boolean) As CustomField
        Dim field As CustomField = GetCustomField(fieldName)
        If field Is Nothing Then
            field = New CustomField()
            field.FieldName = fieldName
            _fields.Add(field)
        End If
        Return field
    End Function

    Public Sub AddCustomField(ByVal recordType As Integer, ByVal fieldName As String, ByVal fieldType As CustomFieldType, ByVal fieldLimit As Integer)
        _fields.Add(New CustomField(recordType, fieldName, fieldType, fieldLimit))
    End Sub

    Public Sub AddCustomField(ByVal ID As Integer, ByVal recordType As Integer, ByVal fieldName As String, ByVal fieldType As CustomFieldType, ByVal fieldLimit As Integer)
        _fields.Add(New CustomField(ID, recordType, fieldName, fieldType, fieldLimit))
    End Sub

    Public Sub AddCustomField(ByRef field As CustomField)
        _fields.Add(field)
    End Sub

    ' properties / methods (CustomFieldValue)

    Public ReadOnly Property Values() As Hashtable
        Get
            Return _values
        End Get
    End Property

    Public ReadOnly Property ValueCount() As Integer
        Get
            Return _values.Count
        End Get
    End Property

    Public Function ContainsValue(ByVal recordID As Long, ByVal fieldID As Integer) As Boolean
        Return _values.Contains(CreateValueKey(recordID, fieldID))
    End Function

    Public Function GetValue(ByVal recordID As Long, ByVal fieldID As Integer) As CustomFieldValue
        Dim value As CustomFieldValue = Nothing
        Dim field As CustomField = Me.GetCustomField(fieldID)
        Dim key As String = CreateValueKey(recordID, fieldID)
        If _values.Contains(key) Then
            value = CType(_values.Item(key), CustomFieldValue)
        Else
            If Not field Is Nothing Then
                value = New CustomFieldValue(recordID, field)
                _values.Add(key, value)
            End If
        End If
        Return value
    End Function

    Public Function AddValue(ByVal recordID As Long, ByVal fieldID As Integer, ByVal fieldValue As Object) As CustomFieldValue
        Dim value As CustomFieldValue
        Dim key As String = CreateValueKey(recordID, fieldID)
        Dim field As CustomField = GetCustomField(fieldID)
        If Not field Is Nothing Then
            value = GetValue(recordID, fieldID)
            If value Is Nothing Then
                value = New CustomFieldValue(recordID, field, fieldValue)
                _values.Add(key, value)
            Else
                'value.RecordID = recordID
                'value.Field = field
                value.FieldValue = fieldValue
            End If
            Return value
        Else
            Return Nothing
        End If
    End Function

    'Public Function AddValue(ByVal ID As Long, ByVal recordID As Long, ByVal fieldID As Integer, ByVal fieldValue As Object) As CustomFieldValue
    '    Dim value As CustomFieldValue
    '    Dim key As String = CreateValueKey(recordID, fieldID)
    '    Dim field As CustomField = GetCustomField(fieldID)
    '    If Not field Is Nothing Then
    '        value = GetValue(recordID, fieldID)
    '        If value Is Nothing Then
    '            value = New CustomFieldValue(ID, recordID, field, fieldValue)
    '            _values.Add(key, value)
    '        Else
    '            value.ID = ID
    '            value.RecordID = recordID
    '            value.Field = field
    '            value.FieldValue = fieldValue
    '        End If
    '        Return value
    '    Else
    '        Return Nothing
    '    End If
    'End Function

    Public Function AddValue(ByRef value As CustomFieldValue) As CustomFieldValue
        Dim key As String = CreateValueKey(value.RecordID, value.FieldID)
        Dim field As CustomField = GetCustomField(value.FieldID)
        If Not field Is Nothing Then
            If _values.Contains(key) Then
                _values.Remove(key)
            End If
            _values.Add(key, value)
            Return value
        Else
            Return Nothing
        End If
    End Function

    ' this is used after a new record (recordID = 0) is posted from a form
    Public Sub SetRecordIDForAllValues(ByVal recordID As Long)
        Dim value As CustomFieldValue
        For Each de As DictionaryEntry In _values
            value = CType(de.Value, CustomFieldValue)
            value.RecordID = recordID
        Next
    End Sub

    Protected Function CreateValueKey(ByVal recordID As Long, ByVal fieldID As Integer) As String
        Dim key As String = recordID.ToString() & "_" & fieldID.ToString()
        Return key
    End Function

    ' methods (other)

    Public Sub ClearAll()
        _values.Clear()
        _fields.Clear()
    End Sub

    ' destructors
    Protected Overrides Sub Finalize()
        If Not _values Is Nothing Then
            _values.Clear()
        End If
        _values = Nothing
        If Not _fields Is Nothing Then
            _fields.Clear()
        End If
        _fields = Nothing
        MyBase.Finalize()
    End Sub

End Class
