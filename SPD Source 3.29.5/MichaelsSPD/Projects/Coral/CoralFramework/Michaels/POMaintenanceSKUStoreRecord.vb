Namespace Michaels

	Public Class POMaintenanceSKUStoreRecord

		Private _id As Long?
		Private _poMaintenanceID As Long?
		Private _poLocationID As Integer?
		Private _michaelsSKU As String
		Private _storeName As String
        Private _storeNumber As Integer?
        Private _orderedQty As Integer?
        Private _originalOrderedQty As Integer?
        Private _cancelledQty As Integer?
        Private _receivedQty As Integer?
        Private _landedCost As Decimal?
        Private _orderRetail As Decimal?
		Private _dateCreated As Date?
		Private _createdUserID As Integer?
		Private _dateLastModified As Date?
		Private _modifiedUserID As Integer?
		Private _isValid As Boolean?
		Private _zone As String

		Private _isRemoveable As Boolean?
        Private _isSelected As Boolean?
        Private _isWarning As Boolean?


		Public Sub New()

		End Sub

		Public Property ID() As Long?
			Get
				Return _id
			End Get
			Set(ByVal value As Long?)
				_id = value
			End Set
		End Property

		Public Property POMaintenanceID() As Long?
			Get
				Return _poMaintenanceID
			End Get
			Set(ByVal value As Long?)
				_poMaintenanceID = value
			End Set
		End Property

		Public Property POLocationID() As Integer?
			Get
				Return _poLocationID
			End Get
			Set(ByVal value As Integer?)
				_poLocationID = value
			End Set
		End Property

		Public Property MichaelsSKU() As String
			Get
				Return _michaelsSKU
			End Get
			Set(ByVal value As String)
				_michaelsSKU = value
			End Set
		End Property

		Public Property StoreName() As String
			Get
				Return _storeName
			End Get
			Set(ByVal value As String)
				_storeName = value
			End Set
		End Property
		Public Property StoreNumber() As Integer?
			Get
				Return _storeNumber
			End Get
			Set(ByVal value As Integer?)
				_storeNumber = value
			End Set
		End Property

		Public Property OrderedQty() As Integer?
			Get
				Return _orderedQty
			End Get
			Set(ByVal value As Integer?)
				_orderedQty = value
			End Set
        End Property

        Public Property OriginalOrderedQty() As Integer?
            Get
                Return _originalOrderedQty
            End Get
            Set(ByVal value As Integer?)
                _originalOrderedQty = value
            End Set
        End Property

        Public Property CancelledQty() As Integer?
            Get
                Return _cancelledQty
            End Get
            Set(ByVal value As Integer?)
                _cancelledQty = value
            End Set
        End Property

        Public Property ReceivedQty() As Integer?
            Get
                Return _receivedQty
            End Get
            Set(ByVal value As Integer?)
                _receivedQty = value
            End Set
        End Property

        Public Property LandedCost() As Decimal?
            Get
                Return _landedCost
            End Get
            Set(ByVal value As Decimal?)
                _landedCost = value
            End Set
        End Property

        Public Property OrderRetail() As Decimal?
            Get
                Return _orderRetail
            End Get
            Set(ByVal value As Decimal?)
                _orderRetail = value
            End Set
        End Property

		Public Property IsValid() As Boolean?
			Get
				Return _isValid
			End Get
			Set(ByVal value As Boolean?)
				_isValid = value
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
				Return _createdUserID
			End Get
			Set(ByVal value As Integer?)
				_createdUserID = value
			End Set
		End Property

		Public Property DateLastModified() As Date?
			Get
				Return _dateLastModified
			End Get
			Set(ByVal value As Date?)
				_dateLastModified = value
			End Set
		End Property

		Public Property ModifiedUserID() As Integer?
			Get
				Return _modifiedUserID
			End Get
			Set(ByVal value As Integer?)
				_modifiedUserID = value
			End Set
		End Property

		Public Property IsSelected() As Boolean?
			Get
				Return _isSelected
			End Get
			Set(ByVal value As Boolean?)
				_isSelected = value
			End Set
		End Property

		Public Property IsRemoveable() As Boolean?
			Get
				Return _isRemoveable
			End Get
			Set(ByVal value As Boolean?)
				_isRemoveable = value
			End Set
        End Property

        Public Property IsWarning() As Boolean?
            Get
                Return _isWarning
            End Get
            Set(ByVal value As Boolean?)
                _isWarning = value
            End Set
        End Property

		Public Property Zone() As String
			Get
				Return _zone
			End Get
			Set(ByVal value As String)
				_zone = value
			End Set
		End Property
	End Class
End Namespace
