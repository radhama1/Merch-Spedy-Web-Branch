
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Public Class CustomFieldValue
    'Private _ID As Long = Long.MinValue
    Private _recordID As Long = Long.MinValue
    'Private _fieldID As Integer = Integer.MinValue
    Private _field As CustomField = Nothing
    Private _fieldValue As Object = Nothing

    Public Sub New(ByRef field As CustomField)
        _field = field
    End Sub

    Public Sub New(ByVal recordID As Long, ByRef field As CustomField)
        _recordID = recordID
        _field = field
    End Sub

    'Public Sub New(ByVal recordID As Long, ByRef field As CustomField, ByVal fieldValue As Object)
    '    _recordID = recordID
    '    _field = field
    '    _fieldValue = fieldValue
    'End Sub

    Public Sub New(ByVal recordID As Long, ByRef field As CustomField, ByVal fieldValue As Object)
        '_ID = ID
        _recordID = RecordID
        _field = Field
        _fieldValue = FieldValue
    End Sub

    Public Sub New(ByVal recordID As Long, ByRef field As CustomField, ByVal fieldValue As Long)
        '_ID = ID
        _recordID = recordID
        _field = field
        _fieldValue = fieldValue
    End Sub

    Public Sub New(ByVal recordID As Long, ByRef field As CustomField, ByVal fieldValue As Decimal)
        '_ID = ID
        _recordID = recordID
        _field = field
        _fieldValue = fieldValue
    End Sub

    Public Sub New(ByVal recordID As Long, ByRef field As CustomField, ByVal fieldValue As DateTime)
        '_ID = ID
        _recordID = recordID
        _field = field
        _fieldValue = fieldValue
    End Sub

    Public Sub New(ByVal recordID As Long, ByRef field As CustomField, ByVal fieldValue As String)
        '_ID = ID
        _recordID = recordID
        _field = field
        _fieldValue = fieldValue
    End Sub

    'Public Property ID() As Long
    '    Get
    '        Return _ID
    '    End Get
    '    Set(ByVal value As Long)
    '        _ID = value
    '    End Set
    'End Property

    Public Property RecordID() As Long
        Get
            Return _recordID
        End Get
        Set(ByVal value As Long)
            _recordID = value
        End Set
    End Property

    Public Property Field() As CustomField
        Get
            Return _field
        End Get
        Set(ByVal value As CustomField)
            _field = value
        End Set
    End Property

    Public ReadOnly Property FieldID() As Integer
        Get
            If Not _field Is Nothing Then
                Return _field.ID
            Else
                Return Integer.MinValue
            End If
        End Get
    End Property

    Public ReadOnly Property FieldType() As Integer
        Get
            if not _field is nothing then
                Return _field.FieldType()
            Else
                Return CustomFieldType.TypeUnknown
            End If
        End Get
    End Property

    Public Property FieldValue() As Object
        Get
            Return _fieldValue
        End Get
        Set(ByVal value As Object)
            _fieldValue = value
        End Set
    End Property

    Public ReadOnly Property FieldValueInteger() As Long
        Get
            Return DataHelper.SmartValues(_fieldValue, "long", True)
        End Get
    End Property

    Public ReadOnly Property FieldValueDecimal() As Decimal
        Get
            Return DataHelper.SmartValues(_fieldValue, "decimal", True)
        End Get
    End Property

    Public ReadOnly Property FieldValueDateTime() As DateTime
        Get
            Return DataHelper.SmartValues(_fieldValue, "datetime", True)
        End Get
    End Property

    Public ReadOnly Property FieldValueString() As String
        Get
            Return DataHelper.SmartValues(_fieldValue, "string", True)
        End Get
    End Property

    Public ReadOnly Property FieldValueIntegerDB() As Object
        Get
            Return DataHelper.DBSmartValues(_fieldValue, "long", True)
        End Get
    End Property

    Public ReadOnly Property FieldValueDecimalDB() As Object
        Get
            Return DataHelper.DBSmartValues(_fieldValue, "decimal", True)
        End Get
    End Property

    Public ReadOnly Property FieldValueDateTimeDB() As Object
        Get
            Return DataHelper.DBSmartValues(_fieldValue, "datetime", True)
        End Get
    End Property

    Public ReadOnly Property FieldValueStringDB() As Object
        Get
            Return DataHelper.DBSmartValues(_fieldValue, "string", True)
        End Get
    End Property

    Public Sub SetFieldValue(ByVal stringValue As String)
        Dim valueInteger As Long
        Dim valueDecimal As Decimal
        'Dim valueDateTime As DateTime
        If Not Me.Field Is Nothing Then
            Select Case Field.FieldType
                Case CustomFieldType.TypeBoolean
                    If (Not stringValue Is Nothing) AndAlso (stringValue = "1" OrElse stringValue = "-1" OrElse stringValue.ToUpper() = "ON") Then
                        valueInteger = 1
                    Else
                        valueInteger = 0
                    End If
                    Me.FieldValue = valueInteger
                Case CustomFieldType.TypeDate
                    Me.FieldValue = DataHelper.SmartValues(stringValue, "datetime", True)
                Case CustomFieldType.TypeDateTime
                    Me.FieldValue = DataHelper.SmartValues(stringValue, "datetime", True)
                Case CustomFieldType.TypeDecimal
                    Me.FieldValue = DataHelper.SmartValues(stringValue, "decimal", True)
                Case CustomFieldType.TypeInteger, CustomFieldType.TypeInteger
                    Me.FieldValue = DataHelper.SmartValues(stringValue, "long", True)
                Case CustomFieldType.TypeMoney
                    Me.FieldValue = DataHelper.SmartValues(stringValue.Replace("$", "").Replace(",", "").Replace(" ", ""), "decimal", True)
                Case CustomFieldType.TypePercent
                    valueDecimal = DataHelper.SmartValues(stringValue.Replace("%", "").Replace(",", "").Replace(" ", ""), "decimal", True)
                    If valueDecimal = Decimal.MinValue Then
                        Me.FieldValue = valueDecimal
                    Else
                        Dim dec As Decimal = 100
                        valueDecimal = valueDecimal / dec
                        Me.FieldValue = valueDecimal
                    End If
                Case CustomFieldType.TypeTime
                    Me.FieldValue = DataHelper.SmartValues(stringValue, "datetime", True)
                Case Else ' CustomFieldType.TypeString, CustomFieldType.TypeText, CustomFieldType.TypeUnknown
                    Me.FieldValue = stringValue
            End Select
        Else
            Me.FieldValue = stringValue
        End If
    End Sub

    Public Function GetFieldValueFormatted() As String
        Dim value As String = ""
        Dim valueInteger As Long
        Dim valueDecimal As Decimal
        Dim valueDateTime As DateTime
        If Not Me.Field Is Nothing Then
            Select Case Field.FieldType
                Case CustomFieldType.TypeBoolean
                    valueInteger = Me.FieldValueInteger
                    If valueInteger = Long.MinValue Then
                        value = ""
                    ElseIf valueInteger = 1 Or valueInteger = -1 Then
                        value = "1"
                    Else
                        value = "0"
                    End If
                Case CustomFieldType.TypeDate
                    valueDateTime = Me.FieldValueDateTime
                    If valueDateTime = DateTime.MinValue Then
                        value = ""
                    Else
                        value = valueDateTime.ToString("M/d/yyyy")
                    End If
                Case CustomFieldType.TypeDateTime
                    valueDateTime = Me.FieldValueDateTime
                    If valueDateTime = DateTime.MinValue Then
                        value = ""
                    Else
                        value = valueDateTime.ToString("M/d/yyyy hh:mm tt")
                    End If
                Case CustomFieldType.TypeDecimal
                    valueDecimal = Me.FieldValueDecimal
                    If valueDecimal = Decimal.MinValue Then
                        value = 0
                    Else
                        value = valueDecimal.ToString("#,##0.0###")
                    End If
                Case CustomFieldType.TypeInteger, CustomFieldType.TypeInteger
                    valueInteger = Me.FieldValueInteger
                    If valueInteger = Long.MinValue Then
                        value = ""
                    Else
                        value = valueInteger.ToString
                    End If
                Case CustomFieldType.TypeMoney
                    valueDecimal = Me.FieldValueDecimal
                    If valueDecimal = Decimal.MinValue Then
                        value = ""
                    Else
                        value = valueDecimal.ToString("#,##0.00")
                    End If
                Case CustomFieldType.TypePercent
                    valueDecimal = Me.FieldValueDecimal
                    If valueDecimal = Decimal.MinValue Then
                        value = ""
                    Else
                        value = valueDecimal.ToString("#0.#%")
                        value = value.Replace("%", "")
                    End If
                Case CustomFieldType.TypeTime
                    valueDateTime = Me.FieldValueDateTime
                    If valueDateTime = DateTime.MinValue Then
                        value = ""
                    Else
                        value = valueDateTime.ToString("hh:mm tt")
                    End If
                Case Else ' CustomFieldType.TypeString, CustomFieldType.TypeText, CustomFieldType.TypeUnknown
                    value = Me.FieldValueString
            End Select
        End If
        Return value
    End Function

End Class

