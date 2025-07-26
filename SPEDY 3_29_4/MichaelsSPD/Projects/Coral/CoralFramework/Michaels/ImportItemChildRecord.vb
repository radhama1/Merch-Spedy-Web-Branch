
Namespace Michaels

    Public Class ImportItemChildRecord
        Private _ID As Long = Long.MinValue
        Private _isValid As ItemValidFlag = ItemValidFlag.Unknown
        Private _regularBatchItem As Boolean = False
        'Private _dept As String = String.Empty
        'Private _vendorNumber As String = String.Empty

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
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

        Public Property RegularBatchItem() As Boolean
            Get
                Return _regularBatchItem
            End Get
            Set(ByVal value As Boolean)
                _regularBatchItem = value
            End Set
        End Property

        'Public Property Dept() As String
        '    Get
        '        Return _dept
        '    End Get
        '    Set(ByVal value As String)
        '        _dept = value
        '    End Set
        'End Property

        'Public Property VendorNumber() As String
        '    Get
        '        Return _vendorNumber
        '    End Get
        '    Set(ByVal value As String)
        '        _vendorNumber = value
        '    End Set
        'End Property

        Public Sub New()
            _ID = Long.MinValue
        End Sub

        Public Sub New(ByVal itemID As Long)
            _ID = itemID
        End Sub

        Public Sub New(ByVal itemID As Long, ByVal isValidFlag As ItemValidFlag)
            _ID = itemID
            _isValid = isValidFlag
        End Sub

        Public Sub New(ByVal itemID As Long, ByVal isValidFlag As ItemValidFlag, ByVal regularBatchItem As Boolean)
            _ID = itemID
            _isValid = isValidFlag
            _regularBatchItem = regularBatchItem
        End Sub

        'Public Sub New(ByVal itemID As Long, ByVal isValidFlag As ItemValidFlag, ByVal regularBatchItem As Boolean, ByVal dept As String, ByVal vendorNumber As String)
        '    _ID = itemID
        '    _isValid = isValidFlag
        '    _regularBatchItem = regularBatchItem
        '    _dept = dept
        '    _vendorNumber = vendorNumber
        'End Sub
    End Class

End Namespace

