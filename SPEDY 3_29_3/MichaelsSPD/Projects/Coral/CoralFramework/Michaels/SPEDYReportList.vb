
Namespace Michaels

    Public Class SPEDYReportList
        ' private fields
        Private _listRecords As ArrayList

        ' constructors
        Public Sub New()
            _listRecords = New ArrayList
        End Sub

        ' public properties

        Public Property ReportList() As ArrayList
            Get
                Return _listRecords
            End Get
            Set(ByVal value As ArrayList)
                _listRecords = value
            End Set
        End Property

        Public ReadOnly Property ReportCount() As Integer
            Get
                Return _listRecords.Count
            End Get
        End Property

        Public Property Item(ByVal index As Integer) As SPEDYReport
            Get
                Dim rec As SPEDYReport = Nothing
                If _listRecords.Count > 0 And index >= 0 And index < _listRecords.Count Then
                    rec = _listRecords(index)
                End If
                Return rec
            End Get
            Set(ByVal value As SPEDYReport)
                If _listRecords.Count > 0 And index >= 0 And index < _listRecords.Count Then
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

