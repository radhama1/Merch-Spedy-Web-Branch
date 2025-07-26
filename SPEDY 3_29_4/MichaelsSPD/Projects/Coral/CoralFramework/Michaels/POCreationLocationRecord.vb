Namespace Michaels

	Public Class POCreationLocationRecord

		Private _id As Long?
		Private _poCreationID As Long?
		Private _poLocationID As Integer?
		Private _externalReferenceID As String
		Private _writtedDate As Date?
		Private _notBefore As Date?
		Private _notAfter As Date?
		Private _estimatedInStockDate As Date?
		Private _dateCreated As Date?
		Private _createdUserID As Integer?
		Private _dateLastModified As Date?
		Private _modifiedUserID As Integer?
		Private _locationName As String
		Private _locationConstant As String

		'Properties used during validateDate WebService calls
		Private _isValidating As Boolean = False
		Private _isPopulating As Boolean = False

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

		Public Property POCreationID() As Long?
			Get
				Return _poCreationID
			End Get
			Set(ByVal value As Long?)
				_poCreationID = value
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

		Public Property ExternalReferenceID() As String
			Get
				Return _externalReferenceID
			End Get
			Set(ByVal value As String)
				_externalReferenceID = value
			End Set
		End Property

		Public Property WrittenDate() As Date?
			Get
				Return _writtedDate
			End Get
			Set(ByVal value As Date?)
				_writtedDate = value
			End Set
		End Property

		Public Property NotBefore() As Date?
			Get
				Return _notBefore
			End Get
			Set(ByVal value As Date?)
				_notBefore = value
			End Set
		End Property

		Public Property NotAfter() As Date?
			Get
				Return _notAfter
			End Get
			Set(ByVal value As Date?)
				_notAfter = value
			End Set
		End Property

		Public Property EstimatedInStockDate() As Date?
			Get
				Return _estimatedInStockDate
			End Get
			Set(ByVal value As Date?)
				_estimatedInStockDate = value
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

		Public Property LocationName() As String
			Get
				Return _locationName
			End Get
			Set(ByVal value As String)
				_locationName = value
			End Set
		End Property

		Public Property LocationConstant() As String
			Get
				Return _locationConstant
			End Get
			Set(ByVal value As String)
				_locationConstant = value
			End Set
		End Property

		Public Property IsValidating() As Boolean
			Get
				Return _isValidating
			End Get
			Set(ByVal value As Boolean)
				_isValidating = value
			End Set
		End Property

		Public Property IsPopulating() As Boolean
			Get
				Return _isPopulating
			End Get
			Set(ByVal value As Boolean)
				_isPopulating = value
			End Set
		End Property

	End Class


End Namespace