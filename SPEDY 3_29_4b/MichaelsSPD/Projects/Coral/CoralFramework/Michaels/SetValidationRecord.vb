
Namespace Michaels

    Public Class SetValidationRecord
        Private _IDs As ArrayList
        Private _recordType As ItemRecordType
        Private _isValid As ItemValidFlag

        Public Sub New()
            _IDs = New ArrayList()
        End Sub

        Public Sub New(ByVal ID As Long)
            _IDs = New ArrayList()
            _IDs.Add(ID)
            _recordType = ItemRecordType.Unknown
            _isValid = ItemValidFlag.Unknown
        End Sub

        Public Sub New(ByVal ID As Long, ByVal recordType As ItemRecordType)
            _IDs = New ArrayList()
            _IDs.Add(ID)
            _recordType = recordType
            _isValid = ItemValidFlag.Unknown
        End Sub

        Public Sub New(ByVal ID As Long, ByVal recordType As ItemRecordType, ByVal isValid As ItemValidFlag)
            _IDs = New ArrayList()
            _IDs.Add(ID)
            _recordType = recordType
            _isValid = isValid
        End Sub

        Public Sub New(ByVal IDs As ArrayList, ByVal recordType As ItemRecordType, ByVal isValid As ItemValidFlag)
            _IDs = IDs
            _recordType = recordType
            _isValid = isValid
        End Sub

        Public ReadOnly Property IDCount() As Integer
            Get
                Return _IDs.Count
            End Get
        End Property

        Public ReadOnly Property IDs() As ArrayList
            Get
                Return _IDs
            End Get
        End Property

        Default Public Property Item(ByVal index As Integer) As Long
            Get
                If index >= 0 AndAlso index < _IDs.Count Then
                    Return _IDs.Item(index)
                Else
                    Return 0
                End If
            End Get
            Set(ByVal value As Long)
                If index > 0 AndAlso index <= _IDs.Count Then
                    _IDs.Item(index) = value
                End If
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

        Public Property IsValid() As ItemValidFlag
            Get
                Return _isValid
            End Get
            Set(ByVal value As ItemValidFlag)
                _isValid = value
            End Set
        End Property

        Protected Overrides Sub Finalize()
            Do While _IDs.Count > 0
                _IDs.RemoveAt(0)
            Loop
            _IDs = Nothing
            MyBase.Finalize()
        End Sub

    End Class
End Namespace
