
Namespace Michaels

    Public Class DepartmentRecord
        Private _dept As Integer = 0
        Private _deptName As String = String.Empty
        Private _deptDesc As String = String.Empty      ' used for special purposes such as concatenating ID with Name

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

        Public Property DeptDesc() As String
            Get
                Return _deptDesc
            End Get
            Set(ByVal value As String)
                _deptDesc = value
            End Set
        End Property
    End Class

End Namespace
