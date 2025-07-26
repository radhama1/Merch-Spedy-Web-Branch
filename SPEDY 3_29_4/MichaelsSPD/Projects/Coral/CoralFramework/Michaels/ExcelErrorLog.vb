Namespace Michaels

    Public Class ExcelAuditLog

        Dim _ID As Long = 0
        Dim _batchID As Long = Long.MinValue
        Dim _michaelsSKU As String = String.Empty
        Dim _vendorNumber As Long = Long.MinValue
        Dim _direction As String = String.Empty
        Dim _message As String = String.Empty
        Dim _dateCreated As Date = Date.MinValue
        Dim _createdUserID As Long = Long.MinValue
        Dim _xlFileName As String = String.Empty

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property
        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property
        Public Property MichaelsSKU() As String
            Get
                Return _michaelsSKU
            End Get
            Set(ByVal value As String)
                _michaelsSKU = value
            End Set
        End Property
        Public Property VendorNumber() As Long
            Get
                Return _vendorNumber
            End Get
            Set(ByVal value As Long)
                _vendorNumber = value
            End Set
        End Property
        Public Property Direction() As String
            Get
                Return _direction
            End Get
            Set(ByVal value As String)
                _direction = value
            End Set
        End Property
        Public Property Message() As String
            Get
                Return _message
            End Get
            Set(ByVal value As String)
                _message = value
            End Set
        End Property
        Public Property DateCreated() As Date
            Get
                Return _dateCreated
            End Get
            Set(ByVal value As Date)
                _dateCreated = value
            End Set
        End Property
        Public Property CreatedUserID() As Long
            Get
                Return _createdUserID
            End Get
            Set(ByVal value As Long)
                _createdUserID = value
            End Set
        End Property

        Public Property XLFileName() As String
            Get
                Return _xlFileName
            End Get
            Set(ByVal value As String)
                _xlFileName = value
            End Set
        End Property

    End Class
End Namespace

