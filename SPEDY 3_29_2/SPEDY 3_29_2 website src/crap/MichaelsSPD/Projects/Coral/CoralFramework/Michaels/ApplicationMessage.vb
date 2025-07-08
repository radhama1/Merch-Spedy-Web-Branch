Namespace Michaels

    Public Class ApplicationMessage

        Dim _isSpedyOnline As Boolean = True
        Dim _message As String = String.Empty
        Dim _activeStartDate As Date = Date.MinValue
        Dim _activeEndDate As Date = Date.MinValue


        Public Property IsSpedyOnline() As Boolean
            Get
                Return _isSpedyOnline
            End Get
            Set(ByVal value As Boolean)
                _isSpedyOnline = value
            End Set
        End Property
        Public Property Message() As String
            Get
                Return _message
            End Get
            Set(ByVal value As String)
                _message = value
            End Set
        End Property
        Public Property ActiveStartDate() As Date
            Get
                Return _activeStartDate
            End Get
            Set(ByVal value As Date)
                _activeStartDate = value
            End Set
        End Property
        Public Property ActiveEndDate() As Date
            Get
                Return _activeEndDate
            End Get
            Set(ByVal value As Date)
                _activeEndDate = value
            End Set
        End Property

    End Class
End Namespace
