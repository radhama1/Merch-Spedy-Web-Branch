Namespace Michaels

    Public Class FineLineClass
        Private _deptNo As Integer = 0
        Private _classNo As Integer = 0
        Private _className As String = String.Empty
        Private _classDesc As String = String.Empty

        Public Property DeptNo() As Integer
            Get
                Return _deptNo
            End Get
            Set(ByVal value As Integer)
                _deptNo = value
            End Set
        End Property

        Public Property ClassNo() As Integer
            Get
                Return _classNo
            End Get
            Set(ByVal value As Integer)
                _classNo = value
            End Set
        End Property

        Public Property ClassName() As String
            Get
                Return _className
            End Get
            Set(ByVal value As String)
                _className = value
            End Set
        End Property

        Public Property ClassDesc() As String
            Get
                Return _classDesc
            End Get
            Set(ByVal value As String)
                _classDesc = value
            End Set
        End Property
    End Class

    Public Class FineLineSubClass
        Private _deptNo As Integer = 0
        Private _classNo As Integer = 0
        Private _subClassNo As Integer = 0
        Private _subClassName As String = String.Empty
        Private _subClassDesc As String = String.Empty

        Public Property DeptNo() As Integer
            Get
                Return _deptNo
            End Get
            Set(ByVal value As Integer)
                _deptNo = value
            End Set
        End Property

        Public Property ClassNo() As Integer
            Get
                Return _classNo
            End Get
            Set(ByVal value As Integer)
                _classNo = value
            End Set
        End Property

        Public Property SubClassNo() As Integer
            Get
                Return _subClassNo
            End Get
            Set(ByVal value As Integer)
                _subClassNo = value
            End Set
        End Property

        Public Property SubClassName() As String
            Get
                Return _subClassName
            End Get
            Set(ByVal value As String)
                _subClassName = value
            End Set
        End Property

        Public Property SubClassDesc() As String
            Get
                Return _subClassDesc
            End Get
            Set(ByVal value As String)
                _subClassDesc = value
            End Set
        End Property
    End Class

End Namespace

