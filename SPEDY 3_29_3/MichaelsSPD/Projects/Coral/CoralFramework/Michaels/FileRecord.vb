
Namespace Michaels

    Public Class FileRecord

        Private _ID As Long = Long.MinValue
        Private _File_Name As String = String.Empty
        Private _File_Type As String = String.Empty
        Private _File_Data As Byte()
        Private _File_Size As Long = Long.MinValue
        Private _Image_Width_Pixels As Integer = Integer.MinValue
        Private _Image_Height_Pixels As Integer = Integer.MinValue
        Private _Image_Thumbnail As Byte()

        Private _Date_Created As Date = Date.MinValue
        Private _Created_User_ID As Integer = Integer.MinValue
        Private _Created_User_Name As String = String.Empty

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property
        Public Property File_Name() As String
            Get
                Return _File_Name
            End Get
            Set(ByVal value As String)
                _File_Name = value
            End Set
        End Property
        Public Property File_Type() As String
            Get
                Return _File_Type
            End Get
            Set(ByVal value As String)
                _File_Type = value
            End Set
        End Property
        Public Property File_Data() As Byte()
            Get
                Return _File_Data
            End Get
            Set(ByVal value As Byte())
                _File_Data = value
            End Set
        End Property
        Public Property File_Size() As Long
            Get
                Return _File_Size
            End Get
            Set(ByVal value As Long)
                _File_Size = value
            End Set
        End Property
        Public Property Image_Width_Pixels() As Integer
            Get
                Return _Image_Width_Pixels
            End Get
            Set(ByVal value As Integer)
                _Image_Width_Pixels = value
            End Set
        End Property
        Public Property Image_Height_Pixels() As Integer
            Get
                Return _Image_Height_Pixels
            End Get
            Set(ByVal value As Integer)
                _Image_Height_Pixels = value
            End Set
        End Property
        Public Property Image_Thumbnail() As Byte()
            Get
                Return _Image_Thumbnail
            End Get
            Set(ByVal value As Byte())
                _Image_Thumbnail = value
            End Set
        End Property

        Public ReadOnly Property Date_Created() As Date
            Get
                Return _Date_Created
            End Get
        End Property
        Public ReadOnly Property Created_User_ID() As Integer
            Get
                Return _Created_User_ID
            End Get
        End Property
        Public ReadOnly Property Created_User_Name() As String
            Get
                Return _Created_User_Name
            End Get
        End Property

        Protected Friend Sub SetReadOnlyData(ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal createdUserName As String)

            _Date_Created = dateCreated
            _Created_User_ID = createdUserID
            _Created_User_Name = createdUserName

        End Sub

    End Class

End Namespace

