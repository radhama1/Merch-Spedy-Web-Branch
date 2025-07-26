
Namespace Michaels

    Public Class AuditRecord
        Private _auditTableID As MetadataTable
        Private _auditRecordID As Long
        Private _auditType As AuditRecordType
        Private _userID As Integer
        Private _auditFields As ArrayList = Nothing

        ' save audit (flag used by child classes to determine whether or not to save the record)
        Private _saveAudit As Boolean = False
        Public Property SaveAudit() As Boolean
            Get
                Return _saveAudit
            End Get
            Set(ByVal value As Boolean)
                _saveAudit = value
            End Set
        End Property

        ' constructors
        Public Sub New()
            _auditTableID = MetadataTable.Unknown
            _auditRecordID = Long.MinValue
            _auditType = AuditRecordType.Insert
            _userID = Integer.MinValue
        End Sub
        Public Sub New(ByVal auditTableID As MetadataTable)
            _auditTableID = auditTableID
            _auditRecordID = Long.MinValue
            _auditType = AuditRecordType.Insert
            _userID = Integer.MinValue
        End Sub
        Public Sub New(ByVal auditTableID As MetadataTable, ByVal auditRecordID As Long)
            _auditTableID = auditTableID
            _auditRecordID = auditRecordID
            _auditType = AuditRecordType.Insert
            _userID = Integer.MinValue
        End Sub
        Public Sub New(ByVal auditTableID As MetadataTable, ByVal auditRecordID As Long, ByVal auditType As AuditRecordType)
            _auditTableID = auditTableID
            _auditRecordID = auditRecordID
            _auditType = auditType
            _userID = Integer.MinValue
        End Sub
        Public Sub New(ByVal auditTableID As MetadataTable, ByVal auditRecordID As Long, ByVal auditType As AuditRecordType, ByVal userID As Integer)
            _auditTableID = auditTableID
            _auditRecordID = auditRecordID
            _auditType = auditType
            _userID = userID
        End Sub

        ' properties
        Public Property AuditTableID() As MetadataTable
            Get
                Return _auditTableID
            End Get
            Set(ByVal value As MetadataTable)
                _auditTableID = value
            End Set
        End Property
        Public Property AuditRecordID() As Long
            Get
                Return _auditRecordID
            End Get
            Set(ByVal value As Long)
                _auditRecordID = value
            End Set
        End Property
        Public Property AuditType() As AuditRecordType
            Get
                Return _auditType
            End Get
            Set(ByVal value As AuditRecordType)
                _auditType = value
            End Set
        End Property
        Public Property UserID() As Integer
            Get
                Return _userID
            End Get
            Set(ByVal value As Integer)
                _userID = value
            End Set
        End Property
        Public Property AuditFields() As ArrayList
            Get
                Return _auditFields
            End Get
            Set(ByVal value As ArrayList)
                If Not _auditFields Is Nothing Then
                    _auditFields.Clear()
                    _auditFields = Nothing
                End If
                _auditFields = value
            End Set
        End Property
        Public ReadOnly Property FieldCount() As Integer
            Get
                If _auditFields Is Nothing Then Return 0
                Return _auditFields.Count
            End Get
        End Property
        Public Property Item(ByVal index As Integer) As AuditField
            Get
                Dim fld As AuditField = Nothing
                If (Not _auditFields Is Nothing) AndAlso _auditFields.Count >= 0 AndAlso index > 0 AndAlso index < _auditFields.Count Then
                    fld = _auditFields(index)
                End If
                Return fld
            End Get
            Set(ByVal value As AuditField)
                If (Not _auditFields Is Nothing) AndAlso _auditFields.Count >= 0 AndAlso index > 0 AndAlso index < _auditFields.Count Then
                    _auditFields(index) = value
                End If
            End Set
        End Property

        ' methods
        Public Sub SetupAudit(ByVal auditTableID As MetadataTable, ByVal auditRecordID As Long, ByVal auditType As AuditRecordType, ByVal userID As Integer)
            _auditTableID = auditTableID
            _auditRecordID = auditRecordID
            _auditType = auditType
            _userID = userID
            Me.SaveAudit = True
        End Sub
        Public Sub AddAuditField(ByVal fieldName As String, ByVal fieldValue As Object)
            If _auditFields Is Nothing Then _auditFields = New ArrayList()
            If Not AuditFieldExists(fieldName) Then _auditFields.Add(New AuditField(fieldName, fieldValue))
        End Sub
        Public Function AuditFieldExists(ByVal fieldName As String) As Boolean
            If _auditFields Is Nothing Then
                Return False
            Else
                For Each fld As AuditField In _auditFields
                    If fld.FieldName = fieldName Then Return True
                Next
            End If
            Return False
        End Function
        Public Sub RemoveAuditField(ByVal fieldName As String)
            Dim fld As AuditField
            For i As Integer = 0 To _auditFields.Count - 1
                fld = CType(_auditFields(i), AuditField)
                If fld.FieldName = fieldName Then
                    _auditFields.RemoveAt(i)
                    Exit For
                End If
            Next
        End Sub
        Public Sub ClearFields()
            If Not _auditFields Is Nothing Then
                _auditFields.Clear()
            End If
        End Sub
        ' destructors
        Protected Overrides Sub Finalize()
            ClearFields()
            _auditFields = Nothing
            MyBase.Finalize()
        End Sub
    End Class

    Public Enum AuditRecordType
        Insert = 1
        Update = 2
        Delete = 3
    End Enum

    Public Class AuditField
        Private _fieldName As String
        Private _fieldValue As String
        Public Sub New()
            _fieldName = String.Empty
            _fieldValue = String.Empty
        End Sub
        Public Sub New(ByVal fieldName As String, ByVal fieldValue As Object)
            _fieldName = fieldName
            SetFieldValue(fieldValue)
        End Sub
        Public Property FieldName() As String
            Get
                Return _fieldName
            End Get
            Set(ByVal value As String)
                _fieldName = value
            End Set
        End Property
        Public ReadOnly Property FieldValue() As String
            Get
                Return _fieldValue
            End Get
        End Property
        Public Sub SetFieldValue(ByVal value As Int16)
            If value = Int16.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Integer)
            If value = Integer.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Long)
            If value = Long.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Decimal)
            If value = Decimal.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Single)
            If value = Single.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Double)
            If value = Double.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As String)
            _fieldValue = value
        End Sub
        Public Sub SetFieldValue(ByVal value As Date)
            If value = Date.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Boolean)
            If value = True Then
                _fieldValue = "1"
            Else
                _fieldValue = "0"
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Byte)
            If value = Byte.MinValue Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
        Public Sub SetFieldValue(ByVal value As Guid)
            If value = Guid.Empty Then
                _fieldValue = String.Empty
            Else
                _fieldValue = value.ToString()
            End If
        End Sub
    End Class

End Namespace

