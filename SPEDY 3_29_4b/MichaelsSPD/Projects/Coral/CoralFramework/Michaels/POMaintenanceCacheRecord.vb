Namespace Michaels

    Public Class POMaintenanceCacheRecord

        Private _activeUserID As Integer?
        Private _id As Long?

        Private _workflowDepartmentID As Integer?
        Private _poDepartmentID As Integer?
        Private _poClass As Integer?
        Private _poSubClass As Integer?
        Private _isDetailValid As Boolean?
        Private _poLocationID As Integer?
        Private _externalReferenceID As String
        Private _writtenDate As Date?
        Private _notBefore As Date?
        Private _notAfter As Date?
        Private _estimatedInStockDate As Date?

        Public Property ActiveUserID() As Integer?
            Get
                Return _activeUserID
            End Get
            Set(ByVal value As Integer?)
                _activeUserID = value
            End Set
        End Property

        Public Property ID() As Long?
            Get
                Return _id
            End Get
            Set(ByVal value As Long?)
                _id = value
            End Set
        End Property

        Public Property WorkflowDepartmentID() As Integer?
            Get
                Return _workflowDepartmentID
            End Get
            Set(ByVal value As Integer?)
                _workflowDepartmentID = value
            End Set
        End Property

        Public Property PODepartmentID() As Integer?
            Get
                Return _poDepartmentID
            End Get
            Set(ByVal value As Integer?)
                _poDepartmentID = value
            End Set
        End Property

        Public Property POClass() As Integer?
            Get
                Return _poClass
            End Get
            Set(ByVal value As Integer?)
                _poClass = value
            End Set
        End Property

        Public Property POSubclass() As Integer?
            Get
                Return _poSubClass
            End Get
            Set(ByVal value As Integer?)
                _poSubClass = value
            End Set
        End Property

        Public Property IsDetailValid() As Boolean?
            Get
                Return _isDetailValid
            End Get
            Set(ByVal value As Boolean?)
                _isDetailValid = value
            End Set
        End Property

        Public Property POLocationID() As Integer?
            Get
                Return _poLocationID
            End Get
            Set(ByVal value As Integer?)
                _poLocationID = value
            End Set
        End Property

        Public Property ExternalReferenceID() As String
            Get
                Return _externalReferenceID
            End Get
            Set(ByVal value As String)
                _externalReferenceID = value
            End Set
        End Property

        Public Property WrittenDate() As Date?
            Get
                Return _writtenDate
            End Get
            Set(ByVal value As Date?)
                _writtenDate = value
            End Set
        End Property

        Public Property NotBefore() As Date?
            Get
                Return _notBefore
            End Get
            Set(ByVal value As Date?)
                _notBefore = value
            End Set
        End Property

        Public Property NotAfter() As Date?
            Get
                Return _notAfter
            End Get
            Set(ByVal value As Date?)
                _notAfter = value
            End Set
        End Property

        Public Property EstimatedInStockDate() As Date?
            Get
                Return _estimatedInStockDate
            End Get
            Set(ByVal value As Date?)
                _estimatedInStockDate = value
            End Set
        End Property

        Public Sub New()

        End Sub

    End Class
End Namespace