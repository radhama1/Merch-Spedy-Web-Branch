
Namespace Michaels

	Public Class POCreationLocationSKURecord

		Private _id As Long?
		Private _poCreationLocationID As Long?
		Private _michaelsSKU As String
		Private _upc As String
		Private _unitCost As Decimal?
		Private _innerPack As Integer?
		Private _masterPack As Integer?
		Private _isValid As Boolean?
		Private _isWSValid As Boolean?
		Private _orderedQty As Integer?
		Private _calculatedOrderTotalQty As Integer?
        Private _locationTotalQty As Integer?
        Private _landedCost As Decimal?
        Private _orderRetail As Decimal?
		Private _dateCreated As Date?
		Private _createdUserID As Integer?
		Private _dateLastModified As Date?
		Private _modifiedUserID As Integer?
        Private _itemTypeAttribute As String
        Private _defaultUPC As String

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

		Public Property POCreationLocationID() As Long?
			Get
				Return _poCreationLocationID
			End Get
			Set(ByVal value As Long?)
				_poCreationLocationID = value
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

		Public Property UPC() As String
			Get
				Return _upc
			End Get
			Set(ByVal value As String)
				_upc = value
			End Set
		End Property

		Public Property UnitCost() As Decimal?
			Get
				Return _unitCost
			End Get
			Set(ByVal value As Decimal?)
				_unitCost = value
			End Set
		End Property

		Public Property InnerPack() As Integer?
			Get
				Return _innerPack
			End Get
			Set(ByVal value As Integer?)
				_innerPack = value
			End Set
		End Property

		Public Property MasterPack() As Integer?
			Get
				Return _masterPack
			End Get
			Set(ByVal value As Integer?)
				_masterPack = value
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

		Public Property IsWSValid() As Boolean?
			Get
				Return _isWSValid
			End Get
			Set(ByVal value As Boolean?)
				_isWSValid = value
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

		Public Property CalculatedOrderTotalQty() As Integer?
			Get
				Return _calculatedOrderTotalQty
			End Get
			Set(ByVal value As Integer?)
				_calculatedOrderTotalQty = value
			End Set
		End Property

		Public Property LocationTotalQty() As Integer?
			Get
				Return _locationTotalQty
			End Get
			Set(ByVal value As Integer?)
				_locationTotalQty = value
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

		Public Property ItemTypeAttribute() As String
			Get
				Return _itemTypeAttribute
			End Get
			Set(ByVal value As String)
				_itemTypeAttribute = value
			End Set
		End Property

        Public Property DefaultUPC() As String
            Get
                Return _defaultUPC
            End Get
            Set(ByVal value As String)
                _defaultUPC = value
            End Set
        End Property

	End Class

End Namespace
