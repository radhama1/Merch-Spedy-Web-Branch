Namespace Michaels

    Public Class ItemSearchRecord
        Private _SKU As String = String.Empty
        Private _SKUID As Integer = Integer.MinValue
        Private _deptNo As Integer = Integer.MinValue
        Private _deptName As String = String.Empty
        Private _classNum As Integer = Integer.MinValue
        Private _subClassNum As Integer = Integer.MinValue
        Private _itemDesc As String = String.Empty
        Private _vendorNumber As Integer = Integer.MinValue
        Private _vendorName As String = String.Empty
        Private _VPI As String = String.Empty
        Private _vendorStyleNum As String = String.Empty
        Private _UPC As String = String.Empty
        Private _UPCPI As String = String.Empty
        Private _batchID As Long = Long.MinValue
        Private _stockCategory As String = String.Empty
        Private _itemTypeAttribute As String = String.Empty
        Private _itemStatus As String = String.Empty
        Private _isPackParent As Boolean = False
        Private _itemType As String = String.Empty
        Private _indEditable As Boolean = True
        Private _packSKU As String = String.Empty
        Private _vendorType As Integer
        Private _hybridType As String = String.Empty
        Private _hybridSourceDC As String = String.Empty
        Private _conversionDate As DateTime?
        Private _qrn As String

        Public Sub New()

        End Sub

        Public Property VendorType() As Integer
            Get
                Return _vendorType
            End Get
            Set(ByVal value As Integer)
                _vendorType = value
            End Set
        End Property

        Public Property PackSKU() As String
            Get
                Return _packSKU
            End Get
            Set(ByVal value As String)
                _packSKU = value
            End Set
        End Property

        Public Property IndEditable() As Boolean
            Get
                Return _indEditable
            End Get
            Set(ByVal value As Boolean)
                _indEditable = value
            End Set
        End Property

        Public Property IsPackParent() As Boolean
            Get
                Return _isPackParent
            End Get
            Set(ByVal value As Boolean)
                _isPackParent = value
            End Set
        End Property

        Public Property ItemType() As String
            Get
                Return _itemType
            End Get
            Set(ByVal value As String)
                _itemType = value
            End Set
        End Property

        Public Property ItemStatus() As String
            Get
                Return _itemStatus
            End Get
            Set(ByVal value As String)
                _itemStatus = value
            End Set
        End Property

        Public Property StockCategory() As String
            Get
                Return _stockCategory
            End Get
            Set(ByVal value As String)
                _stockCategory = value
            End Set
        End Property

        Public Property ItemTypeAttribute() As String
            Get
                Return _itemTypeAttribute
            End Get
            Set(ByVal value As String)
                _itemTypeAttribute = value
            End Set
        End Property

        Public Property SKU() As String
            Get
                Return _SKU
            End Get
            Set(ByVal value As String)
                _SKU = value
            End Set
        End Property

        Public Property SKUID() As Integer
            Get
                Return _SKUID
            End Get
            Set(ByVal value As Integer)
                _SKUID = value
            End Set
        End Property

        Public Property DeptNo() As Integer
            Get
                Return _deptNo
            End Get
            Set(ByVal value As Integer)
                _deptNo = value
            End Set
        End Property

        Public Property DeptName() As String
            Get
                Return _deptName
            End Get
            Set(ByVal value As String)
                _deptName = value
            End Set
        End Property

        Public Property ClassNum() As Integer
            Get
                Return _classNum
            End Get
            Set(ByVal value As Integer)
                _classNum = value
            End Set
        End Property

        Public Property SubClassNum() As Integer
            Get
                Return _subClassNum
            End Get
            Set(ByVal value As Integer)
                _subClassNum = value
            End Set
        End Property

        Public Property ItemDesc() As String
            Get
                Return _itemDesc
            End Get
            Set(ByVal value As String)
                _itemDesc = value
            End Set
        End Property

        Public Property VendorNumber() As Integer
            Get
                Return _vendorNumber
            End Get
            Set(ByVal value As Integer)
                _vendorNumber = value
            End Set
        End Property

        Public Property VendorName() As String
            Get
                Return _vendorName
            End Get
            Set(ByVal value As String)
                _vendorName = value
            End Set
        End Property

        Public Property VPI() As String
            Get
                Return _VPI
            End Get
            Set(ByVal value As String)
                _VPI = value
            End Set
        End Property

        Public Property VendorStyleNum() As String
            Get
                Return _vendorStyleNum
            End Get
            Set(ByVal value As String)
                _vendorStyleNum = value
            End Set
        End Property

        Public Property UPC() As String
            Get
                Return _UPC
            End Get
            Set(ByVal value As String)
                _UPC = value
            End Set
        End Property

        Public Property UPCPI() As String
            Get
                Return _UPCPI
            End Get
            Set(ByVal value As String)
                _UPCPI = value
            End Set
        End Property

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property

        Public Property HybridType() As String
            Get
                Return _hybridType
            End Get
            Set(ByVal value As String)
                _hybridType = value
            End Set
        End Property

        Public Property HybridSourceDC() As String
            Get
                Return _hybridSourceDC
            End Get
            Set(ByVal value As String)
                _hybridSourceDC = value
            End Set
        End Property

        Public Property ConversionDate() As DateTime?
            Get
                Return _conversionDate
            End Get
            Set(ByVal value As DateTime?)
                _conversionDate = value
            End Set
        End Property

        Public Property QuoteReferenceNumber() As String
            Get
                Return _qrn
            End Get
            Set(ByVal value As String)
                _qrn = value
            End Set
        End Property

    End Class
End Namespace

