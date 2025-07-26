
Namespace Michaels

    Public Class ValidationRecord
        Private _recordID As Long
        Private _recordType As ItemRecordType
        Private _errors As ArrayList = Nothing

        Public Sub New()
            _recordID = 0
            _recordType = ItemRecordType.Unknown
            _errors = New ArrayList()
        End Sub

        Public Sub New(ByVal recordID As Long)
            _recordID = recordID
            _recordType = ItemRecordType.Unknown
            _errors = New ArrayList()
        End Sub

        Public Sub New(ByVal recordID As Long, ByVal recordType As ItemRecordType)
            _recordID = recordID
            _recordType = recordType
            _errors = New ArrayList()
        End Sub

        Protected Overrides Sub Finalize()
            RemoveAll()
            _errors = Nothing
            MyBase.Finalize()
        End Sub

        Public Property RecordID() As Long
            Get
                Return _recordID
            End Get
            Set(ByVal value As Long)
                _recordID = value
            End Set
        End Property

        Public Property RecordType() As ItemRecordType
            Get
                Return _recordType
            End Get
            Set(ByVal value As ItemRecordType)
                _recordType = value
            End Set
        End Property

        Public Function Add(ByVal field As String, ByVal errorText As String, Optional ByVal errorSeverity As ValidationRuleSeverityType = ValidationRuleSeverityType.TypeError)
            Return _errors.Add(New ValidationError(field, field.Replace("_", " "), errorText, errorSeverity))
        End Function

        Public Function Add(ByVal field As String, ByVal errorText As String, ByVal useFieldName As Boolean, Optional ByVal errorSeverity As ValidationRuleSeverityType = ValidationRuleSeverityType.TypeError)
            Dim fn As String = field.Replace("_", " ")
            If useFieldName Then
                Return _errors.Add(New ValidationError(field, fn, String.Format(errorText, fn), errorSeverity))
            Else
                Return Me.Add(field, fn, errorText, errorSeverity)
            End If
        End Function

        Public Function Add(ByVal field As String, ByVal fieldName As String, ByVal errorText As String, Optional ByVal errorSeverity As ValidationRuleSeverityType = ValidationRuleSeverityType.TypeError)
            Return _errors.Add(New ValidationError(field, fieldName, errorText, errorSeverity))
        End Function

        Public Function Add(ByVal field As String, ByVal fieldName As String, ByVal errorType As Integer, ByVal errorText As String, Optional ByVal errorSeverity As ValidationRuleSeverityType = ValidationRuleSeverityType.TypeError)
            Return _errors.Add(New ValidationError(field, fieldName, errorType, errorText, errorSeverity))
        End Function

        Public Function Add(ByVal value As ValidationError) As Integer
            Return _errors.Add(value)
        End Function

        Public Sub Insert(ByVal index As Integer, ByVal value As ValidationError)
            _errors.Insert(index, value)
        End Sub

        Public Sub Merge(ByRef other As ValidationRecord)
            Merge(other, False)
        End Sub

        Public Sub Merge(ByRef other As ValidationRecord, ByVal addToBeginning As Boolean)
            If other IsNot Nothing AndAlso other.Count > 0 Then
                For i As Integer = 0 To other.Count - 1
                    If addToBeginning Then
                        Me.Insert(i, other.Item(i))
                    Else
                        Me.Add(other.Item(i))
                    End If
                Next
            End If
        End Sub

        Public Property ValidationErrors() As ArrayList
            Get
                Return _errors
            End Get
            Set(ByVal value As ArrayList)
                _errors = value
            End Set
        End Property

        Public ReadOnly Property Count() As Integer
            Get
                Return _errors.Count
            End Get
        End Property

        ' FJL Mar 2010 update to do it based on errorSeverity
        Public ReadOnly Property Count(ByVal errorSeverity As ValidationRuleSeverityType) As Integer
            Get
                Dim cnt As Integer = 0
                For Each errorRec As ValidationError In ValidationErrors
                    If errorRec.ErrorSeverity = errorSeverity Then
                        cnt += 1
                    End If
                Next
                Return cnt
            End Get
        End Property

        ' FJL Mar 2010 Update this to return check for count of records that have severity = error
        Public ReadOnly Property IsValid() As Boolean
            Get
                Dim ret As Boolean = True
                For Each errorRec As ValidationError In ValidationErrors
                    If errorRec.ErrorSeverity = ValidationRuleSeverityType.TypeError Then
                        ret = False
                        Exit For
                    End If
                Next
                Return ret
                ' Return (Me.Count <= 0)
            End Get
        End Property

        Default Public Property Item(ByVal index As Integer) As ValidationError
            Get
                If index >= 0 AndAlso index < _errors.Count Then
                    Return CType(_errors.Item(index), ValidationError)
                Else
                    Return Nothing
                End If
            End Get
            Set(ByVal value As ValidationError)
                If index >= 0 AndAlso index < _errors.Count Then
                    _errors.Item(index) = value
                End If
            End Set
        End Property

        Public Sub RemoveErrorsByField(ByVal field As String)
            If _errors.Count > 0 Then
                For i As Integer = _errors.Count - 1 To 0 Step -1
                    If Me.Item(i).Field = field Then
                        _errors.RemoveAt(i)
                    End If
                Next
            End If
        End Sub

        Public Function HasAnyError() As Boolean
            If Me.Count > 0 Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Function ErrorExists(Optional ByVal errorSeverity As ValidationRuleSeverityType = ValidationRuleSeverityType.TypeError) As Boolean
            Dim ret As Boolean = False

            If _errors IsNot Nothing Then
                For Each ve As ValidationError In _errors
                    If ve.ErrorSeverity = errorSeverity Then
                        ret = True
                        Exit For
                    End If
                Next
            End If

            Return ret
        End Function

        ' FJL Mar 2010 Update this to return check for count of records that have severity = error
        Public Function FieldErrorExists(ByVal field As String, Optional ByVal errorSeverity As ValidationRuleSeverityType = ValidationRuleSeverityType.TypeError) As Boolean
            Dim ret As Boolean = False
            For Each ve As ValidationError In _errors
                If ve.Field = field AndAlso ve.ErrorSeverity = errorSeverity Then
                    ret = True
                    Exit For
                End If
            Next
            Return ret
        End Function

        Public Sub RemoteAt(ByVal index As Integer)
            If index > 0 AndAlso index <= _errors.Count - 1 Then
                _errors.RemoveAt(index)
            End If
        End Sub

        Public Sub RemoveAll()
            Do While _errors.Count > 0
                _errors.RemoveAt(0)
            Loop
		End Sub

		Public Shared Function GetValidationRuleSeverityType(ByVal ruleInt As Integer) As NovaLibra.Coral.SystemFrameworks.ValidationRuleSeverityType
			Select Case ruleInt
				Case 1
					Return ValidationRuleSeverityType.TypeError
				Case 2
					Return ValidationRuleSeverityType.TypeWarning
				Case 3
					Return ValidationRuleSeverityType.TypeInformation
				Case Else
					Return ValidationRuleSeverityType.typeUnknown
			End Select
		End Function
    End Class

#Region "ValidationError Class"

    ' Validation Error Class
    Public Class ValidationError
        Private _field As String
        Private _fieldName As String
        Private _errorType As Integer
        Private _errorText As String
        Private _errorSeverity As ValidationRuleSeverityType

        Public Sub New()
            _field = String.Empty
            _fieldName = String.Empty
            _errorType = 0
            _errorText = String.Empty
            _errorSeverity = ValidationRuleSeverityType.TypeError
        End Sub

        Public Sub New(ByVal field As String, ByVal fieldName As String, ByVal errorText As String, ByVal errorSeverity As ValidationRuleSeverityType)
            Me.New(field, fieldName, 0, errorText, errorSeverity)
        End Sub

        Public Sub New(ByVal field As String, ByVal fieldName As String, ByVal errorType As Integer, ByVal errorText As String, ByVal errorSeverity As ValidationRuleSeverityType)
            _field = field
            _fieldName = fieldName
            _errorType = errorType
            _errorText = errorText
            _errorSeverity = errorSeverity
        End Sub

        Public Property Field() As String
            Get
                Return _field
            End Get
            Set(ByVal value As String)
                _field = value
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

        Public Property ErrorType() As Integer
            Get
                Return _errorType
            End Get
            Set(ByVal value As Integer)
                _errorType = value
            End Set
        End Property

        Public Property ErrorText() As String
            Get
                Return _errorText
            End Get
            Set(ByVal value As String)
                _errorText = value
            End Set
        End Property
        Public Property ErrorSeverity() As ValidationRuleSeverityType
            Get
                Return _errorSeverity
            End Get
            Set(ByVal value As ValidationRuleSeverityType)
                _errorSeverity = value
            End Set
        End Property

    End Class
#End Region


End Namespace

