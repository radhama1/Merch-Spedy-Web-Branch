Namespace Michaels

    Public Class POCreationUploadRecord

        Private _ID As Long?
        Private _POCreationID As Long?
        Private _FileName As String
        Private _IsValid As Boolean?
        Private _DetailTypeID As Byte?
        Private _AppliedToPO As Boolean?
        Private _DateCreated As Date?
        Private _CreatedUserID As Integer?
        Private _CreatedUserName As String

        Public Property ID() As Long?
            Get
                Return _ID
            End Get
            Set(ByVal value As Long?)
                _ID = value
            End Set
        End Property

        Public Property POCreationID() As Long?
            Get
                Return _POCreationID
            End Get
            Set(ByVal value As Long?)
                _POCreationID = value
            End Set
        End Property

        Public Property FileName() As String
            Get
                Return _FileName
            End Get
            Set(ByVal value As String)
                _FileName = value
            End Set
        End Property

        Public Property IsValid() As Boolean?
            Get
                Return _IsValid
            End Get
            Set(ByVal value As Boolean?)
                _IsValid = value
            End Set
        End Property

        Public Property DetailTypeID() As Byte?
            Get
                Return _DetailTypeID
            End Get
            Set(ByVal value As Byte?)
                _DetailTypeID = value
            End Set
        End Property

        Public Property AppliedToPO() As Boolean?
            Get
                Return _AppliedToPO
            End Get
            Set(ByVal value As Boolean?)
                _AppliedToPO = value
            End Set
        End Property

        Public Property DateCreated() As Date?
            Get
                Return _dateCreated
            End Get
            Set(ByVal value As Date?)
                _dateCreated = value
            End Set
        End Property

        Public Property CreatedUserID() As Integer?
            Get
                Return _CreatedUserID
            End Get
            Set(ByVal value As Integer?)
                _CreatedUserID = value
            End Set
        End Property

        Public Property CreatedUserName() As String
            Get
                Return _createdUserName
            End Get
            Set(ByVal value As String)
                _createdUserName = value
            End Set
        End Property

        Public Sub New()

        End Sub

        Public Enum DetailType As Byte
            PreAllocation = 1
            Excel = 2
            MMS = 3
        End Enum

    End Class
End Namespace