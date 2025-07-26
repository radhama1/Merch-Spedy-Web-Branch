
Public Class ListValueGroups
    ' private fields
    Private _lvgs As ArrayList

    ' constructors
    Public Sub New()
        _lvgs = New ArrayList
    End Sub

    ' public properties
    Public ReadOnly Property RecordCount() As Integer
        Get
            Return _lvgs.Count
        End Get
    End Property

    Default Public Property Item(ByVal index As Integer) As ListValueGroup
        Get
            Dim lvg As ListValueGroup = Nothing
            If index >= 0 AndAlso index < _lvgs.Count Then
                lvg = CType(_lvgs.Item(index), ListValueGroup)
            End If
            Return lvg
        End Get
        Set(ByVal value As ListValueGroup)
            If index >= 0 AndAlso index < _lvgs.Count Then
                _lvgs.Item(index) = value
            End If
        End Set
    End Property

    ' methods
    Public Function GetListValueGroup(ByVal groupName As String) As ListValueGroup
        Dim lvg As ListValueGroup = Nothing
        For i As Integer = 0 To _lvgs.Count - 1
            If CType(_lvgs.Item(i), ListValueGroup).Name = groupName Then
                lvg = _lvgs.Item(i)
                Exit For
            End If
        Next
        Return lvg
    End Function

    ' methods
    Public Function GetListValueGroup(ByVal groupName As String, ByVal createNewIfNotExists As Boolean) As ListValueGroup
        Dim lvg As ListValueGroup = GetListValueGroup(groupName)
        If lvg Is Nothing Then
            lvg = New ListValueGroup(groupName)
            _lvgs.Add(lvg)
        End If
        Return lvg
    End Function

    Public Sub AddListValueGroup(ByVal groupName As String)
        _lvgs.Add(New ListValueGroup(groupName))
    End Sub

    Public Sub AddListValueGroup(ByVal lvg As ListValueGroup)
        _lvgs.Add(lvg)
    End Sub

    Public Sub AddListValue(ByVal groupName As String, ByVal value As String, ByVal displayText As String)
        GetListValueGroup(groupName, True).AddListValue(value, displayText)
    End Sub

    Public Sub ClearAll()
        _lvgs.Clear()
    End Sub

    Public Sub Remove(ByVal groupName As String, ByVal value As String)
        Dim lvg As ListValueGroup = GetListValueGroup(groupName)
        lvg.Remove(value)
    End Sub

    ' destructors
    Protected Overrides Sub Finalize()
        If Not _lvgs Is Nothing Then
            _lvgs.Clear()
        End If
        _lvgs = Nothing
        MyBase.Finalize()
    End Sub

End Class
