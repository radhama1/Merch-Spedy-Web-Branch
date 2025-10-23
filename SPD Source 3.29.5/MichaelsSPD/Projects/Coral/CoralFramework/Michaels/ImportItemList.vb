
Namespace Michaels

    Public Class ImportItemList

        ' private fields
        Private _totalRecords As Integer
        Private _listRecords As ArrayList

        ' constructors
        Public Sub New()
            _totalRecords = 0
            _listRecords = New ArrayList
        End Sub

        ' public properties
        Public Property TotalRecords() As Integer
            Get
                Return _totalRecords
            End Get
            Set(ByVal value As Integer)
                _totalRecords = value
            End Set
        End Property

        Public Property ListRecords() As ArrayList
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

        Public Sub Add(ByRef importItem As ImportItemRecord)
            _listRecords.Add(importItem)
        End Sub

        Public Property Item(ByVal index As Integer) As ImportItemRecord
            Get
                Dim rec As ImportItemRecord = Nothing
                If _listRecords.Count > 0 And index > 0 And index < _listRecords.Count Then
                    rec = _listRecords(index)
                End If
                Return rec
            End Get
            Set(ByVal value As ImportItemRecord)
                If _listRecords.Count > 0 And index > 0 And index < _listRecords.Count Then
                    _listRecords(index) = value
                End If
            End Set
        End Property

        ' methods
        Public Sub ClearList()
            _listRecords.Clear()
        End Sub

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

