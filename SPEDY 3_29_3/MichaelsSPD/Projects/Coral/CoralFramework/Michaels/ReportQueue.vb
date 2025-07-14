Namespace Michaels

    Public Class ReportQueue

        Private _id As Integer?
        Private _reportID As Integer
        Private _reportParameters As String
        Private _enabled As Boolean
        Private _isReoccurring As Boolean
        Private _lastRunDate As DateTime?
        Private _reportInterval As Integer?
        Private _emailRecipients As String
        Private _errorMessage As String

        Public Property ID As Integer?
            Get
                Return _id
            End Get
            Set(value As Integer?)
                _id = value
            End Set
        End Property

        Public Property ReportID As Integer
            Get
                Return _reportID
            End Get
            Set(value As Integer)
                _reportID = value
            End Set
        End Property

        Public Property ReportParameters As String
            Get
                Return _reportParameters
            End Get
            Set(value As String)
                _reportParameters = value
            End Set
        End Property

        Public Property Enabled As Boolean
            Get
                Return _enabled
            End Get
            Set(value As Boolean)
                _enabled = value
            End Set
        End Property

        Public Property IsReoccurring As Boolean
            Get
                Return _isReoccurring
            End Get
            Set(value As Boolean)
                _isReoccurring = value
            End Set
        End Property

        Public Property LastRunDate As DateTime?
            Get
                Return _lastRunDate
            End Get
            Set(value As DateTime?)
                _lastRunDate = value
            End Set
        End Property

        Public Property ReportInterval As Integer?
            Get
                Return _reportInterval
            End Get
            Set(value As Integer?)
                _reportInterval = value
            End Set
        End Property

        Public Property EmailRecipients As String
            Get
                Return _emailRecipients
            End Get
            Set(value As String)
                _emailRecipients = value
            End Set
        End Property

        Public Property ErrorMessage As String
            Get
                Return _errorMessage
            End Get
            Set(value As String)
                _errorMessage = value
            End Set
        End Property

    End Class

End Namespace