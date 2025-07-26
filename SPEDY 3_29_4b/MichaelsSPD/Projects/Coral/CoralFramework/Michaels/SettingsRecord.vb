Namespace Michaels
    Public Class SettingsRecord
        Private _id As Integer?
        Private _name As String
        Private _settingValue As String
        Private _sortOrder As Integer
        Private _settingType As Integer

        Public Property ID As Integer?
            Get
                Return _id
            End Get
            Set(value As Integer?)
                _id = value
            End Set
        End Property

        Public Property Name As String
            Get
                Return _name
            End Get
            Set(value As String)
                _name = value
            End Set
        End Property

        Public Property SettingValue As String
            Get
                Return _settingValue
            End Get
            Set(value As String)
                _settingValue = value
            End Set
        End Property

        Public Property SortOrder As Integer
            Get
                Return _sortOrder
            End Get
            Set(value As Integer)
                _sortOrder = value
            End Set
        End Property

        Public Property SettingType As Integer
            Get
                Return _settingType
            End Get
            Set(value As Integer)
                _settingType = value
            End Set
        End Property

    End Class
End Namespace

