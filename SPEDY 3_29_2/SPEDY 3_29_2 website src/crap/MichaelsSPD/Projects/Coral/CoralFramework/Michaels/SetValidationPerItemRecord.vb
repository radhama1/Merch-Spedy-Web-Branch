
Namespace Michaels

    Public Class SetValidationPerItemRecord
        Private _itemRecords As ArrayList

        Public Sub New()
            _itemRecords = New ArrayList()
        End Sub

        Public Sub New(ByVal ID As Long, ByVal recordType As ItemRecordType, ByVal isValid As ItemValidFlag)
            _itemRecords = New ArrayList()
            _itemRecords.Add(New ValidationPerItemRecord(ID, recordType, isValid))
        End Sub

        Public Sub Add(ByVal ID As Long, ByVal recordType As ItemRecordType, ByVal isValid As ItemValidFlag)
            _itemRecords.Add(New ValidationPerItemRecord(ID, recordType, isValid))
        End Sub

        Public ReadOnly Property Count() As Integer
            Get
                Return _itemRecords.Count
            End Get
        End Property

        Public ReadOnly Property ValidationPerItemRecords() As ArrayList
            Get
                Return _itemRecords
            End Get
        End Property

        Default Public Property Item(ByVal index As Integer) As ValidationPerItemRecord
            Get
                If index >= 0 AndAlso index < _itemRecords.Count Then
                    Return CType(_itemRecords.Item(index), ValidationPerItemRecord)
                Else
                    Return Nothing
                End If
            End Get
            Set(ByVal value As ValidationPerItemRecord)
                If index > 0 AndAlso index <= _itemRecords.Count Then
                    _itemRecords.Item(index) = value
                End If
            End Set
        End Property

        Protected Overrides Sub Finalize()
            Do While _itemRecords.Count > 0
                _itemRecords.RemoveAt(0)
            Loop
            _itemRecords = Nothing
            MyBase.Finalize()
        End Sub

    End Class

    Public Class ValidationPerItemRecord
        Private _ID As Long
        Private _recordType As ItemRecordType
        Private _isValid As ItemValidFlag

        Public Sub New()
            _ID = 0
            _recordType = ItemRecordType.Unknown
            _isValid = ItemValidFlag.Unknown
        End Sub

        Public Sub New(ByVal ID As Long, ByVal recordType As ItemRecordType, ByVal isValid As ItemValidFlag)
            _ID = ID
            _recordType = recordType
            _isValid = isValid
        End Sub

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
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
    End Class
End Namespace
