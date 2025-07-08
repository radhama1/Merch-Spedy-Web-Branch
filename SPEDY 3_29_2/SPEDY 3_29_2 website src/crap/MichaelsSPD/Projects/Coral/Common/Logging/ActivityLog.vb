Imports System

Public Class ActivityLog

    ' private members
    Private _activityType As Integer = 0
    Private _activity As String = String.Empty

    ' constructors
    Public Sub New()

    End Sub

    Public Sub New(ByVal activityType As Integer, ByVal activity As String)
        _activityType = activityType
        _activity = activity
    End Sub

    ' public properties
    Public Property ActivityType() As Integer
        Get
            Return _activityType
        End Get
        Set(ByVal value As Integer)
            _activityType = value
        End Set
    End Property

    Public Property Activity() As String
        Get
            Return _activity
        End Get
        Set(ByVal value As String)
            _activity = value
        End Set
    End Property
End Class
