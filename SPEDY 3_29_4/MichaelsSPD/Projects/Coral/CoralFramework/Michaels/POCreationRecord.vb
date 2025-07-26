Namespace Michaels

    Public Class POCreationRecord

        Private _ID As Long?
        Private _poConstructID As Byte? = Construct.Manual

        Private _batchNumber As String
        Private _batchType As String
        Private _poStatusID As Byte?
        Private _workflowStageID As Integer?
        Private _vendorName As String
        Private _vendorNumber As Long?
        Private _basicSeasonal As String
        Private _workflowDepartmentID As Integer?
        Private _poDepartmentID As Integer?
        Private _poClass As Integer?
        Private _poSubclass As Integer?
        Private _approverUserID As Integer?
        Private _initiatorRoleID As Integer?
        Private _poAllocationEventID As Integer?
        Private _poSeasonalSymbolID As Integer?
        Private _eventYear As Integer?
        Private _shipPointDescription As String
        Private _shipPointCode As String
        Private _pogNumber As String
        Private _pogStartDate As Date?
        Private _pogEndDate As Date?
        Private _poSpecialID As Integer?
        Private _paymentTermsID As Integer?
        Private _freightTermsID As Integer?
        Private _internalComment As String
        Private _externalComment As String
        Private _generatedcomment As String
        Private _isHeaderValid As Boolean?
		Private _isDetailValid As Boolean?
		Private _isValidating As Boolean?
		Private _validatingJobID As Long?
        Private _enabled As Boolean?
        Private _dateCreated As Date?
        Private _createdUserID As Integer?
        Private _createdUserName As String
        Private _dateLastModified As Date?
        Private _modifiedUserID As Integer?
        Private _modifiedUserName As String
        Private _allowSeasonalItemsBasicDC As Boolean?
        Private _seasonCode As String

        'Used for determining workflow progression
        Private _isAllocDirty As Boolean?
        Private _isPlannerDirty As Boolean?
        Private _isDateWarning As Boolean?

        Public Property ID() As Long?
            Get
                Return _ID
            End Get
            Set(ByVal value As Long?)
                _ID = value
            End Set
        End Property

        Public Property POConstructID() As Byte?
            Get
                Return _poConstructID
            End Get
            Set(ByVal value As Byte?)
                _poConstructID = value
            End Set
        End Property

        Public Property BatchNumber() As String
            Get
                Return _batchNumber
            End Get
            Set(ByVal value As String)
                _batchNumber = value
            End Set
        End Property

        Public Property BatchType() As String
            Get
                Return _batchType
            End Get
            Set(ByVal value As String)
                _batchType = value
            End Set
        End Property

		Public Property POStatusID() As Byte?
			Get
				Return _poStatusID
			End Get
			Set(ByVal value As Byte?)
				_poStatusID = value
			End Set
		End Property

        Public Property WorkflowStageID() As Integer?
            Get
                Return _workflowStageID
            End Get
            Set(ByVal value As Integer?)
                _workflowStageID = value
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

        Public Property VendorNumber() As Long?
            Get
                Return _vendorNumber
            End Get
            Set(ByVal value As Long?)
                _vendorNumber = value
            End Set
        End Property

        Public Property BasicSeasonal() As String
            Get
                Return _basicSeasonal
            End Get
            Set(ByVal value As String)
                _basicSeasonal = value
            End Set
        End Property

		Public Property WorkflowDepartmentID() As Integer?
			Get
				Return _workflowDepartmentID
			End Get
			Set(ByVal value As Integer?)
				_workflowDepartmentID = value
			End Set
		End Property

        Public Property PODepartmentID() As Integer?
            Get
                Return _poDepartmentID
            End Get
            Set(ByVal value As Integer?)
                _poDepartmentID = value
            End Set
        End Property

        Public Property POClass() As Integer?
            Get
                Return _poClass
            End Get
            Set(ByVal value As Integer?)
                _poClass = value
            End Set
        End Property

        Public Property POSubclass() As Integer?
            Get
                Return _poSubclass
            End Get
            Set(ByVal value As Integer?)
                _poSubclass = value
            End Set
        End Property

        Public Property ApproverUserID() As Integer?
            Get
                Return _approverUserID
            End Get
            Set(ByVal value As Integer?)
                _approverUserID = value
            End Set
        End Property

        Public Property InitiatorRoleID() As Integer?
            Get
                Return _initiatorRoleID
            End Get
            Set(ByVal value As Integer?)
                _initiatorRoleID = value
            End Set
        End Property

        Public Property POAllocationEventID() As Integer?
            Get
                Return _poAllocationEventID
            End Get
            Set(ByVal value As Integer?)
                _poAllocationEventID = value
            End Set
        End Property

        Public Property POSeasonalSymbolID() As Integer?
            Get
                Return _poSeasonalSymbolID
            End Get
            Set(ByVal value As Integer?)
                _poSeasonalSymbolID = value
            End Set
        End Property

        Public Property EventYear() As Integer?
            Get
                Return _eventYear
            End Get
            Set(ByVal value As Integer?)
                _eventYear = value
            End Set
        End Property

        Public Property ShipPointDescription() As String
            Get
                Return _shipPointDescription
            End Get
            Set(ByVal value As String)
                _shipPointDescription = value
            End Set
        End Property

        Public Property ShipPointCode() As String
            Get
                Return _shipPointCode
            End Get
            Set(ByVal value As String)
                _shipPointCode = value
            End Set
        End Property

        Public Property POGNumber() As String
            Get
                Return _pogNumber
            End Get
            Set(ByVal value As String)
                _pogNumber = value
            End Set
        End Property

        Public Property POGStartDate() As Date?
            Get
                Return _pogStartDate
            End Get
            Set(ByVal value As Date?)
                _pogStartDate = value
            End Set
        End Property

        Public Property POGEndDate() As Date?
            Get
                Return _pogEndDate
            End Get
            Set(ByVal value As Date?)
                _pogEndDate = value
            End Set
        End Property

        Public Property POSpecialID() As Integer?
            Get
                Return _poSpecialID
            End Get
            Set(ByVal value As Integer?)
                _poSpecialID = value
            End Set
        End Property

        Public Property PaymentTermsID() As Integer?
            Get
                Return _paymentTermsID
            End Get
            Set(ByVal value As Integer?)
                _paymentTermsID = value
            End Set
        End Property

        Public Property FreightTermsID() As Integer?
            Get
                Return _freightTermsID
            End Get
            Set(ByVal value As Integer?)
                _freightTermsID = value
            End Set
        End Property

        Public Property InternalComment() As String
            Get
                Return _internalComment
            End Get
            Set(ByVal value As String)
                _internalComment = value
            End Set
        End Property

        Public Property ExternalComment() As String
            Get
                Return _externalComment
            End Get
            Set(ByVal value As String)
                _externalComment = value
            End Set
        End Property

        Public Property GeneratedComment() As String
            Get
                Return _generatedcomment
            End Get
            Set(ByVal value As String)
                _generatedcomment = value
            End Set
        End Property

        Public Property IsHeaderValid() As Boolean?
            Get
                Return _isHeaderValid
            End Get
            Set(ByVal value As Boolean?)
                _isHeaderValid = value
            End Set
        End Property

        Public Property IsDetailValid() As Boolean?
            Get
                Return _isDetailValid
            End Get
            Set(ByVal value As Boolean?)
                _isDetailValid = value
            End Set
		End Property

		Public Property IsValidating() As Boolean?
			Get
				Return _isValidating
			End Get
			Set(ByVal value As Boolean?)
				_isValidating = value
			End Set
        End Property

        Public Property IsAllocDirty() As Boolean?
            Get
                Return _isAllocDirty
            End Get
            Set(ByVal value As Boolean?)
                _isAllocDirty = value
            End Set
        End Property

        Public Property IsPlannerDirty() As Boolean?
            Get
                Return _isPlannerDirty
            End Get
            Set(ByVal value As Boolean?)
                _isPlannerDirty = value
            End Set
        End Property

        Public Property IsDateWarning() As Boolean?
            Get
                Return _isDateWarning
            End Get
            Set(ByVal value As Boolean?)
                _isDateWarning = value
            End Set
        End Property

		Public Property ValidatingJobID() As Long?
			Get
				Return _validatingJobID
			End Get
			Set(ByVal value As Long?)
				_validatingJobID = value
			End Set
		End Property

        Public Property Enabled() As Boolean?
            Get
                Return _enabled
            End Get
            Set(ByVal value As Boolean?)
                _enabled = value
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

        Public Property CreatedUserName() As String
            Get
                Return _createdUserName
            End Get
            Set(ByVal value As String)
                _createdUserName = value
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

        Public Property ModifiedUserName() As String
            Get
                Return _modifiedUserName
            End Get
            Set(ByVal value As String)
                _modifiedUserName = value
            End Set
        End Property

        Public Property AllowSeasonalItemsBasicDC() As Boolean?
            Get
                Return _allowSeasonalItemsBasicDC
            End Get
            Set(ByVal value As Boolean?)
                _allowSeasonalItemsBasicDC = value
            End Set
        End Property

        Public Property SeasonCode() As String
            Get
                Return _seasonCode
            End Get
            Set(ByVal value As String)
                _seasonCode = value
            End Set
        End Property

        Public Sub New()

        End Sub

        Public Enum Construct As Byte
            Manual = 1
            AST = 2
        End Enum

        Public Enum Status As Byte
            Worksheet = 1
            Approved = 2
            Revised = 3
        End Enum

        Public Class POBatchType

            Public Shared ReadOnly Warehouse As String = "W"
            Public Shared ReadOnly Direct As String = "D"

            Public Shared Function GetPOBatchTypeName(ByVal value As String) As String
                Select Case UCase(value)
                    Case Warehouse
                        Return "Warehouse"
                    Case Direct
                        Return "Direct"
                    Case Else
                        Return ""
                End Select
            End Function

		End Class

		Public Class POSpecial

			Public Shared ReadOnly Custom As Integer = 1
			Public Shared ReadOnly Test As Integer = 2
			Public Shared ReadOnly NewStore As Integer = 3

			Public Shared Function GetPOSpecialName(ByVal value As Integer) As String
				Select Case (value)
					Case 1
						Return "Custom Order"
					Case 2
						Return "Test"
					Case 3
						Return "New Store"
					Case Else
						Return "None"
				End Select
			End Function

		End Class

    End Class
End Namespace