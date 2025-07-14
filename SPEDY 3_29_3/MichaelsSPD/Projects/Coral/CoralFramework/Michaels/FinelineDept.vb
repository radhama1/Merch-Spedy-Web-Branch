
Namespace Michaels

    Public Class FinelineDept
        Private _dept As Integer
        Private _deptName As String

        Public Sub New()
            _dept = Integer.MinValue
            _deptName = String.Empty
        End Sub

        Public Sub New(ByVal dept As Integer, ByVal deptName As String)
            _dept = dept
            _deptName = deptName
        End Sub

        Public Property Dept() As Integer
            Get
                Return _dept
            End Get
            Set(ByVal value As Integer)
                _dept = value
            End Set
        End Property
        Public Property DeptName() As String
            Get
                Return _deptName
            End Get
            Set(ByVal value As String)
                _deptName = value
            End Set
        End Property
    End Class

End Namespace

