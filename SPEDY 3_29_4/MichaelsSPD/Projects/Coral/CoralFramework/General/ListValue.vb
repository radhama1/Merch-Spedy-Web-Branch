
Public Class ListValue
    Private _value As String
    Private _displayText As String

    Public Property Value() As String
        Get
            Return _value
        End Get
        Set(ByVal newvalue As String)
            _value = newvalue
        End Set
    End Property

    Public Property DisplayText() As String
        Get
            Return _displayText
        End Get
        Set(ByVal value As String)
            _displayText = value
        End Set
    End Property

    Public Sub New()
        Me.New(String.Empty, String.Empty)
    End Sub

    Public Sub New(ByVal value As String)
        Me.New(value, String.Empty)
    End Sub

    Public Sub New(ByVal value As String, ByVal displayText As String)
        Me._value = value
        Me._displayText = displayText
    End Sub
End Class
