

Namespace Michaels

    Public Class TaxQuestionRecord
        Private _ID As Long
        Private _taxUDAID As Integer
        Private _parentTaxQuestionID As Long
        Private _taxQuestion As String
        Private _sortOrder As String
        Private _childrenCount As Integer

        Public Sub New()
            _ID = 0
            _taxUDAID = 0
            _parentTaxQuestionID = 0
            _taxQuestion = String.Empty
            _sortOrder = String.Empty
            _childrenCount = 0
        End Sub

        Public Sub New(ByVal id As Long, ByVal taxUDAID As Integer, ByVal parentTaxQuestionID As Long, ByVal taxQuestion As String, ByVal sortOrder As String)
            _ID = id
            _taxUDAID = taxUDAID
            _parentTaxQuestionID = parentTaxQuestionID
            _taxQuestion = taxQuestion
            _sortOrder = sortOrder
        End Sub

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property
        Public Property TaxUDAID() As Integer
            Get
                Return _taxUDAID
            End Get
            Set(ByVal value As Integer)
                _taxUDAID = value
            End Set
        End Property
        Public Property ParentTaxQuestionID() As Long
            Get
                Return _parentTaxQuestionID
            End Get
            Set(ByVal value As Long)
                _parentTaxQuestionID = value
            End Set
        End Property
        Public Property TaxQuestion() As String
            Get
                Return _taxQuestion
            End Get
            Set(ByVal value As String)
                _taxQuestion = value
            End Set
        End Property
        Public Property SortOrder() As String
            Get
                Return _sortOrder
            End Get
            Set(ByVal value As String)
                _sortOrder = value
            End Set
        End Property
        Public Property ChildrenCount() As Integer
            Get
                Return _childrenCount
            End Get
            Set(ByVal value As Integer)
                _childrenCount = value
            End Set
        End Property

        Public ReadOnly Property HasChildren() As Boolean
            Get
                If _childrenCount > 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
    End Class

End Namespace

