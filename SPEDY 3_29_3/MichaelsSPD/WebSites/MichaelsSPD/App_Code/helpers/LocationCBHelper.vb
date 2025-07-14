Imports Microsoft.VisualBasic

Public Class LocationCBHelper

    Private _id As Integer
    Private _name As String
    Private _isChecked As Boolean

    Public Sub New(ByVal id As Integer, ByVal name As String, ByVal isChecked As Boolean)
        _id = id
        _name = name
        _isChecked = isChecked
    End Sub

    Public Property ID() As Integer
        Get
            Return _id
        End Get
        Set(ByVal value As Integer)
            _id = value
        End Set
    End Property

    Public Property Name() As String
        Get
            Return _name
        End Get
        Set(ByVal value As String)
            _name = value
        End Set
    End Property

    Public Property IsChecked() As Boolean
        Get
            Return _isChecked
        End Get
        Set(ByVal value As Boolean)
            _isChecked = value
        End Set
    End Property

    Public ReadOnly Property CheckMark() As String
        Get
            If IsChecked Then
                Return "X"
            Else
                Return "&nbsp;&nbsp"
            End If
        End Get
    End Property

End Class
