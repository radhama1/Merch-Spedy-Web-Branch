
Public Class ListValueGroup
    Private _name As String
    Private _listValues As ArrayList = Nothing

    Public Property Name() As String
        Get
            Return _name
        End Get
        Set(ByVal value As String)
            _name = value
        End Set
    End Property
    Public Property ListValues() As ArrayList
        Get
            Return _listValues
        End Get
        Set(ByVal value As ArrayList)
            _listValues = value
        End Set
    End Property
    Public Function ListValueExists(ByVal value As String) As Boolean
        Dim ret As Boolean = False
        If _listValues.Count > 0 Then
            For i As Integer = 0 To _listValues.Count - 1
                If ListValue(i).Value = value Then
                    ret = True
                    Exit For
                End If
            Next
        End If
        Return ret
    End Function
    Public ReadOnly Property ListValue(ByVal index As Integer) As ListValue
        Get
            If index >= 0 AndAlso index < _listValues.Count Then
                Return CType(_listValues.Item(index), ListValue)
            Else
                Return Nothing
            End If
        End Get
    End Property
    Public ReadOnly Property Value(ByVal index As Integer) As String
        Get
            If index >= 0 AndAlso index < _listValues.Count Then
                Return CType(_listValues.Item(index), ListValue).Value
            Else
                Return ""
            End If
        End Get
    End Property
    Public ReadOnly Property DisplayText(ByVal index As Integer) As String
        Get
            If index >= 0 AndAlso index < _listValues.Count Then
                Return CType(_listValues.Item(index), ListValue).DisplayText
            Else
                Return ""
            End If
        End Get
    End Property

    Public ReadOnly Property ListValueCount() As Integer
        Get
            Return _listValues.Count
        End Get
    End Property

    Public ReadOnly Property TotalListValues() As Integer
        Get
            Return _listValues.Count
        End Get
    End Property

    Public Sub New()
        Me.New(String.Empty)
    End Sub

    Public Sub New(ByVal groupName As String)
        _name = groupName
        _listValues = New ArrayList()
    End Sub

    Public Sub AddListValue(ByVal value As String, ByVal displayText As String)
        _listValues.Add(New ListValue(value, displayText))
    End Sub

    Public Sub Remove(ByVal value As String)

        Dim index As Integer = -1
        For i As Integer = 0 To _listValues.Count - 1
            If CType(_listValues.Item(i), ListValue).Value = value Then
                index = i
            End If
        Next

        If (index > 0) Then
            _listValues.RemoveAt(index)
        End If
    End Sub


    Protected Overrides Sub Finalize()
        _listValues.Clear()
        _listValues = Nothing
        MyBase.Finalize()
    End Sub
End Class
