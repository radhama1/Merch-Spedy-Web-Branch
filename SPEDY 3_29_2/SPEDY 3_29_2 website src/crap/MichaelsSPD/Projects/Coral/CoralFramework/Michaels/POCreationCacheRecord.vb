Namespace Michaels

    Public Class POCreationCacheRecord

        Private _activeUserID As Integer?
        Private _id As Long?

        Private _workflowDepartmentID As Integer?
        Private _poDepartmentID As Integer?
        Private _poClass As Integer?
        Private _poSubclass As Integer?
        Private _isDetailValid As Boolean?

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
                Return _poSubclass
            End Get
            Set(ByVal value As Integer?)
                _poSubclass = value
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

        Public Sub New()

        End Sub

    End Class
End Namespace