Namespace Michaels
    Public Class ItemMaintItem
        Private _ID As Integer = Integer.MinValue
        Private _batchID As Long = Long.MinValue
        Private _batchTypeID As Integer = Integer.MinValue
        Private _SKU As String = String.Empty
        Private _SKUID As Integer = Integer.MinValue
        Private _vendorNumber As Long = Long.MinValue
        Private _isValid As Int16 = Int16.MinValue
        Private _lastUpdateDate As String = String.Empty
        Private _lastUpdateUserID As Integer = Integer.MinValue
        Private _lastUpdateUserName As String = String.Empty
        Private _enabled As Boolean = True
        Private _createdUserID As Integer = Integer.MinValue
        Private _isIndEditable As Boolean = True

        Public Sub New()

        End Sub

        Public Property CreatedUserID() As Integer
            Get
                Return _createdUserID
            End Get
            Set(ByVal value As Integer)
                _createdUserID = value
            End Set
        End Property

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
            End Set
        End Property

        Public Property BatchID() As Integer
            Get
                Return _batchID
            End Get
            Set(ByVal value As Integer)
                _batchID = value
            End Set
        End Property

        Public Property BatchTypeID() As Integer
            Get
                Return _batchTypeID
            End Get
            Set(value As Integer)
                _batchTypeID = value
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

        Public Property IsValid() As Integer
            Get
                Return _isValid
            End Get
            Set(ByVal value As Integer)
                _isValid = value
            End Set
        End Property

        Public Property LastUpdateUserID() As Integer
            Get
                Return _lastUpdateUserID
            End Get
            Set(ByVal value As Integer)
                _lastUpdateUserID = value
            End Set
        End Property

        Public Property IsIndEditable() As Boolean
            Get
                Return _isIndEditable
            End Get
            Set(ByVal value As Boolean)
                _isIndEditable = value
            End Set
        End Property

        Public Property Enabled() As Boolean
            Get
                Return _enabled
            End Get
            Set(ByVal value As Boolean)
                _enabled = value
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

        Public Property LastUpdateDate() As String
            Get
                Return _lastUpdateDate
            End Get
            Set(ByVal value As String)
                _lastUpdateDate = value
            End Set
        End Property


        Public Property LastUpdateUserName() As String
            Get
                Return _lastUpdateUserName
            End Get
            Set(ByVal value As String)
                _lastUpdateUserName = value
            End Set
        End Property

    End Class

    'Public Class ItemMaintItemDetails

    '    Private _ID
    '    Private _IsValid
    '    Private _IsLockedForChange
    '    Private _SKU
    '    Private _VendorNumber
    '    Private _VPN
    '    Private _PrimaryUPC
    '    Private _AdditionalUPCs
    '    Private _ItemDesc
    '    Private _ClassNum
    '    Private _SubClassNum
    '    Private _CountryOfOrigin
    '    Private _PrePriced
    '    Private _PrePricedUDA
    '    Private _ItemCost
    '    Private _TaxUDA
    '    Private _TaxValueUDA
    '    Private _AutoReplenish
    '    Private _AllowStoreOrder
    '    Private _Discountable
    '    Private _InventoryControl
    '    Private _PrivateBrand
    '    Private _EachesInnerPack
    '    Private _EachesMasterPack
    '    Private _InnerPackHeight
    '    Private _InnerPackWidth
    '    Private _InnerPackLength
    '    Private _InnerPackCube
    '    Private _InnerPackCubeUOM
    '    Private _InnerPackWeight
    '    Private _InnerPackWeightUOM
    '    Private _MasterPackHeight
    '    Private _MasterPackWidth
    '    Private _MasterPackLength
    '    Private _MasterPackCube
    '    Private _MasterPackCubeUOM
    '    Private _MasterPackWeight
    '    Private _MasterPackWeightUOM
    '    Private _ImportBurden
    '    Private _ShippingPoint
    '    Private _PlanogramName
    '    Private _Hazardous
    '    Private _Flammable
    '    Private _HazardousCountainerType
    '    Private _HazardousContainerSize
    '    Private _HazardousMSDS
    'End Class
End Namespace
