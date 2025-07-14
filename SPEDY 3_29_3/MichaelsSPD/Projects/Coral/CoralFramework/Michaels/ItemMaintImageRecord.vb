Namespace Michaels

    Public Class ItemMaintImageRecord
        Private _michaelsSKU As String
        Private _vendorNumber As Integer
        Private _imageID As Integer
        Private _fileData As Byte()
        Private _fileSize As Integer
        Private _fileName As String

        Public Property MichaelsSKU As String
            Get
                Return _michaelsSKU
            End Get
            Set(value As String)
                _michaelsSKU = value
            End Set
        End Property

        Public Property VendorNumber As Integer
            Get
                Return _vendorNumber
            End Get
            Set(value As Integer)
                _vendorNumber = value
            End Set
        End Property

        Public Property ImageID As Integer
            Get
                Return _imageID
            End Get
            Set(value As Integer)
                _imageID = value
            End Set
        End Property

        Public Property FileData As Byte()
            Get
                Return _fileData
            End Get
            Set(value As Byte())
                _fileData = value
            End Set
        End Property

        Public Property FileSize As Integer
            Get
                Return _fileSize
            End Get
            Set(value As Integer)
                _fileSize = value
            End Set
        End Property

        Public Property FileName As String
            Get
                Return _fileName
            End Get
            Set(value As String)
                _fileName = value
            End Set
        End Property

    End Class

End Namespace