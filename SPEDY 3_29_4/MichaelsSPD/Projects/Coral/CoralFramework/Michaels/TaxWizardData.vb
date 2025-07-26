
Namespace Michaels

    Public Class TaxWizardData
        Private _itemType As TaxWizardItemType
        Private _itemID As Long
        Private _taxUDAID As Long
        Private _taxQuestions As ArrayList = Nothing

        Public Sub New()
            _itemType = TaxWizardItemType.Domestic
            _itemID = 0
            _taxUDAID = 0
            _taxQuestions = New ArrayList()
        End Sub

        Public Sub New(ByVal itemType As TaxWizardItemType, ByVal itemID As Long, ByVal taxUDAID As Long)
            _itemType = itemType
            _itemID = itemID
            _taxUDAID = taxUDAID
            _taxQuestions = New ArrayList()
        End Sub

        Protected Overrides Sub Finalize()
            RemoveAll()
            _taxQuestions = Nothing
            MyBase.Finalize()
        End Sub

        Public Property ItemType() As TaxWizardItemType
            Get
                Return _itemType
            End Get
            Set(ByVal value As TaxWizardItemType)
                _itemType = value
            End Set
        End Property
        Public Property ItemID() As Long
            Get
                Return _itemID
            End Get
            Set(ByVal value As Long)
                _itemID = value
            End Set
        End Property
        Public Property TaxUDAID() As Long
            Get
                Return _taxUDAID
            End Get
            Set(ByVal value As Long)
                _taxUDAID = value
            End Set
        End Property

        Public Function Add(ByVal value As Object) As Integer
            Return _taxQuestions.Add(value)
        End Function

        Public Sub Insert(ByVal index As Integer, ByVal value As Object)
            _taxQuestions.Insert(index, value)
        End Sub

        Public Property TaxQuestions() As ArrayList
            Get
                Return _taxQuestions
            End Get
            Set(ByVal value As ArrayList)
                _taxQuestions = value
            End Set
        End Property

        Public ReadOnly Property Count() As Integer
            Get
                Return _taxQuestions.Count
            End Get
        End Property

        Default Public Property Item(ByVal index As Integer) As Object
            Get
                Return _taxQuestions.Item(index)
            End Get
            Set(ByVal value As Object)
                _taxQuestions.Item(index) = value
            End Set
        End Property

        Public Function QuestionExists(ByVal taxQuestionID As Long) As Boolean
            Dim ret As Boolean = False
            For Each col As Long In _taxQuestions
                If col = taxQuestionID Then
                    ret = True
                    Exit For
                End If
            Next
            Return ret
        End Function

        Public Sub RemoteAt(ByVal index As Integer)
            If index > 0 AndAlso index <= _taxQuestions.Count - 1 Then
                _taxQuestions.RemoveAt(index)
            End If
        End Sub

        Public Sub RemoveAll()
            Do While _taxQuestions.Count > 0
                _taxQuestions.RemoveAt(0)
            Loop
        End Sub

        Public Enum TaxWizardItemType
            Domestic
            Import
        End Enum
    End Class

End Namespace

