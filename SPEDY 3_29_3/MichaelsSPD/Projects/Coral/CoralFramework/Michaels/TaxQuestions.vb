
Namespace Michaels

    Public Class TaxQuestions
        ' private fields
        Private _listRecords As ArrayList

        ' constructors
        Public Sub New()
            _listRecords = New ArrayList
        End Sub

        ' public properties

        Public Property Questions() As ArrayList
            Get
                Return _listRecords
            End Get
            Set(ByVal value As ArrayList)
                _listRecords = value
            End Set
        End Property

        Public ReadOnly Property RecordCount() As Integer
            Get
                Return _listRecords.Count
            End Get
        End Property

        Default Public Property Item(ByVal index As Integer) As TaxQuestionRecord
            Get
                Dim rec As TaxQuestionRecord = Nothing
                If _listRecords.Count >= 0 And index > 0 And index < _listRecords.Count Then
                    rec = CType(_listRecords(index), TaxQuestionRecord)
                End If
                Return rec
            End Get
            Set(ByVal value As TaxQuestionRecord)
                If _listRecords.Count >= 0 And index > 0 And index < _listRecords.Count Then
                    _listRecords(index) = value
                End If
            End Set
        End Property


        ' methods
        Public Sub ClearList()
            _listRecords.Clear()
        End Sub

        Public Function GetRootQuestions() As ArrayList
            Return GetChildren(0)
        End Function

        Public Function GetChildren(ByVal parentID As Long) As ArrayList
            Dim arr As New ArrayList()
            For Each tq As TaxQuestionRecord In _listRecords
                If tq.ParentTaxQuestionID = parentID Then arr.Add(tq)
            Next
            Return arr
        End Function

        ' destructors
        Protected Overrides Sub Finalize()
            If Not _listRecords Is Nothing Then
                _listRecords.Clear()
            End If
            _listRecords = Nothing
            MyBase.Finalize()
        End Sub
    End Class

End Namespace


