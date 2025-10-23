
Namespace Michaels

    Public Class ItemHeaderRecord
        Inherits AuditRecord

        Private _ID As Long = 0
        Private _batchID As Long = Long.MinValue
        Private _logID As String = String.Empty
        Private _submittedBy As String = String.Empty
        Private _dateSubmitted As Date = Date.MinValue
        Private _supplyChainAnalyst As String = String.Empty
        Private _mgrSupplyChain As String = String.Empty
        Private _dirSCVR As String = String.Empty
        Private _rebuyYN As String
        Private _replenishYN As String
        Private _storeOrderYN As String
        Private _dateInRetek As Date = Date.MinValue
        Private _enterRetek As String = String.Empty
        Private _USVendorNum As Integer = Integer.MinValue
        Private _canadianVendorNum As Integer = Integer.MinValue
        Private _USVendorName As String = String.Empty
        Private _canadianVendorName As String = String.Empty
        Private _departmentNum As Integer = Integer.MinValue
        Private _buyerApproval As String = String.Empty
        Private _stockCategory As String = String.Empty
        Private _canadaStockCategory As String = String.Empty
        Private _itemType As String = String.Empty
        Private _itemTypeAttribute As String = String.Empty
        Private _allowStoreOrder As String
        Private _perpetualInventory As String
        Private _inventoryControl As String
        Private _freightTerms As String = String.Empty
        Private _autoReplenish As String
        Private _SKUGroup As String = String.Empty
        Private _storeSupplierZoneGroup As String = String.Empty
        Private _WHSSupplierZoneGroup As String = String.Empty
        Private _comments As String = String.Empty
        Private _worksheetDesc As String = String.Empty
        Private _batchFileID As Long
        Private _dateCreated As Date = Date.MinValue
        Private _createdUserID As Integer = Integer.MinValue
        Private _dateLastModified As Date = Date.MinValue
        Private _updateUserID As Integer = Integer.MinValue
        Private _isValid As ItemValidFlag = ItemValidFlag.Unknown
        Private _RMSSellable As String = String.Empty
        Private _RMSOrderable As String = String.Empty
        Private _RMSInventory As String = String.Empty
        Private _CalculateOptions As Integer = 0
        Private _discountable As String = String.Empty
        Private _addUnitCost As Decimal = Decimal.MinValue

        Private _storeTotal As Integer = Integer.MinValue
        Private _POGStartDate As Date = Date.MinValue
        Private _POGCompDate As Date = Date.MinValue

        Private _createdUser As String
        Private _updateUser As String

        Private _batchVendorName As String = String.Empty
        Private _batchStageID As Long
        Private _batchStageName As String
        Private _batchStageType As Michaels.WorkflowStageType = Michaels.WorkflowStageType.General

        Private _itemUnknownCount As Integer = 0
        Private _itemNotValidCount As Integer = 0
        Private _itemValidCount As Integer = 0
        


        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property
        Public Property LogID() As String
            Get
                Return _logID
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _logID Then Me.AddAuditField("Log_ID", value)
                _logID = value
            End Set
        End Property
        Public Property SubmittedBy() As String
            Get
                Return _submittedBy
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _submittedBy Then Me.AddAuditField("Submitted_By", value)
                _submittedBy = value
            End Set
        End Property
        Public Property DateSubmitted() As Date
            Get
                Return _dateSubmitted
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _dateSubmitted Then Me.AddAuditField("Date_Submitted", value)
                _dateSubmitted = value
            End Set
        End Property
        Public Property SupplyChainAnalyst() As String
            Get
                Return _supplyChainAnalyst
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _supplyChainAnalyst Then Me.AddAuditField("Supply_Chain_Analyst", value)
                _supplyChainAnalyst = value
            End Set
        End Property
        Public Property MgrSupplyChain() As String
            Get
                Return _mgrSupplyChain
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _mgrSupplyChain Then Me.AddAuditField("Mgr_Supply_Chain", value)
                _mgrSupplyChain = value
            End Set
        End Property
        Public Property DirSCVR() As String
            Get
                Return _dirSCVR
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _dirSCVR Then Me.AddAuditField("Dir_SCVR", value)
                _dirSCVR = value
            End Set
        End Property
        Public Property RebuyYN() As String
            Get
                Return _rebuyYN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _rebuyYN Then Me.AddAuditField("Rebuy_YN", value)
                _rebuyYN = value
            End Set
        End Property
        Public Property ReplenishYN() As String
            Get
                Return _replenishYN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _replenishYN Then Me.AddAuditField("Replenish_YN", value)
                _replenishYN = value
            End Set
        End Property
        Public Property StoreOrderYN() As String
            Get
                Return _storeOrderYN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _storeOrderYN Then Me.AddAuditField("Store_Order_YN", value)
                _storeOrderYN = value
            End Set
        End Property
        Public Property DateInRetek() As Date
            Get
                Return _dateInRetek
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _dateInRetek Then Me.AddAuditField("Date_In_Retek", value)
                _dateInRetek = value
            End Set
        End Property
        Public Property EnterRetek() As String
            Get
                Return _enterRetek
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _enterRetek Then Me.AddAuditField("Enter_Retek", value)
                _enterRetek = value
            End Set
        End Property
        Public Property USVendorNum() As Integer
            Get
                Return _USVendorNum
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _USVendorNum Then Me.AddAuditField("US_Vendor_Num", value)
                _USVendorNum = value
            End Set
        End Property
        Public Property CanadianVendorNum() As Integer
            Get
                Return _canadianVendorNum
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _canadianVendorNum Then Me.AddAuditField("Canadian_Vendor_Num", value)
                _canadianVendorNum = value
            End Set
        End Property
        Public Property USVendorName() As String
            Get
                Return _USVendorName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _USVendorName Then Me.AddAuditField("US_Vendor_Name", value)
                _USVendorName = value
            End Set
        End Property
        Public Property CanadianVendorName() As String
            Get
                Return _canadianVendorName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _canadianVendorName Then Me.AddAuditField("Canadian_Vendor_Name", value)
                _canadianVendorName = value
            End Set
        End Property
        Public Property DepartmentNum() As Integer
            Get
                Return _departmentNum
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _departmentNum Then Me.AddAuditField("Department_Num", value)
                _departmentNum = value
            End Set
        End Property
        Public Property BuyerApproval() As String
            Get
                Return _buyerApproval
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _buyerApproval Then Me.AddAuditField("Buyer_Approval", value)
                _buyerApproval = value
            End Set
        End Property
        Public Property StockCategory() As String
            Get
                Return _stockCategory
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _stockCategory Then Me.AddAuditField("Stock_Category", value)
                _stockCategory = value
            End Set
        End Property
        Public Property CanadaStockCategory() As String
            Get
                Return _canadaStockCategory
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _canadaStockCategory Then Me.AddAuditField("Canada_Stock_Category", value)
                _canadaStockCategory = value
            End Set
        End Property
        Public Property ItemType() As String
            Get
                Return _itemType
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemType Then Me.AddAuditField("Item_Type", value)
                _itemType = value
            End Set
        End Property
        Public Property ItemTypeAttribute() As String
            Get
                Return _itemTypeAttribute
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemTypeAttribute Then Me.AddAuditField("Item_Type_Attribute", value)
                _itemTypeAttribute = value
            End Set
        End Property
        Public Property AllowStoreOrder() As String
            Get
                Return _allowStoreOrder
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _allowStoreOrder Then Me.AddAuditField("Allow_Store_Order", value)
                _allowStoreOrder = value
            End Set
        End Property
        Public Property PerpetualInventory() As String
            Get
                Return _perpetualInventory
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _perpetualInventory Then Me.AddAuditField("Perpetual_Inventory", value)
                _perpetualInventory = value
            End Set
        End Property
        Public Property InventoryControl() As String
            Get
                Return _inventoryControl
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _inventoryControl Then Me.AddAuditField("Inventory_Control", value)
                _inventoryControl = value
            End Set
        End Property
        Public Property FreightTerms() As String
            Get
                Return _freightTerms
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _freightTerms Then Me.AddAuditField("Freight_Terms", value)
                _freightTerms = value
            End Set
        End Property
        Public Property AutoReplenish() As String
            Get
                Return _autoReplenish
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _autoReplenish Then Me.AddAuditField("Auto_Replenish", value)
                _autoReplenish = value
            End Set
        End Property
        Public Property SKUGroup() As String
            Get
                Return _SKUGroup
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _SKUGroup Then Me.AddAuditField("SKU_Group", value)
                _SKUGroup = value
            End Set
        End Property
        Public Property StoreSupplierZoneGroup() As String
            Get
                Return _storeSupplierZoneGroup
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _storeSupplierZoneGroup Then Me.AddAuditField("Store_Supplier_Zone_Group", value)
                _storeSupplierZoneGroup = value
            End Set
        End Property
        Public Property WHSSupplierZoneGroup() As String
            Get
                Return _WHSSupplierZoneGroup
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _WHSSupplierZoneGroup Then Me.AddAuditField("WHS_Supplier_Zone_Group", value)
                _WHSSupplierZoneGroup = value
            End Set
        End Property
        Public Property Comments() As String
            Get
                Return _comments
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _comments Then Me.AddAuditField("Comments", value)
                _comments = value
            End Set
        End Property
        Public Property WorksheetDesc() As String
            Get
                Return _worksheetDesc
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _worksheetDesc Then Me.AddAuditField("Worksheet_Desc", value)
                _worksheetDesc = value
            End Set
        End Property
        Public Property BatchFileID() As Long
            Get
                Return _batchFileID
            End Get
            Set(ByVal value As Long)
                If Me.SaveAudit AndAlso value <> _batchFileID Then Me.AddAuditField("Batch_File_ID", value)
                _batchFileID = value
            End Set
        End Property
        Public ReadOnly Property DateCreated() As Date
            Get
                Return _dateCreated
            End Get
        End Property
        Public ReadOnly Property CreatedUserID() As Integer
            Get
                Return _createdUserID
            End Get
        End Property
        Public ReadOnly Property DateLastModified() As Date
            Get
                Return _dateLastModified
            End Get
        End Property
        Public ReadOnly Property UpdateUserID() As Integer
            Get
                Return _updateUserID
            End Get
        End Property
        Public Property IsValid() As ItemValidFlag
            Get
                Return _isValid
            End Get
            Set(ByVal value As ItemValidFlag)
                If Me.SaveAudit AndAlso value <> _isValid Then Me.AddAuditField("Is_Valid", value)
                _isValid = value
            End Set
        End Property
        Public Property RMSSellable() As String
            Get
                Return _RMSSellable
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RMSSellable Then Me.AddAuditField("RMS_Sellable", value)
                _RMSSellable = value
            End Set
        End Property
        Public Property RMSOrderable() As String
            Get
                Return _RMSOrderable
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RMSOrderable Then Me.AddAuditField("RMS_Orderable", value)
                _RMSOrderable = value
            End Set
        End Property
        Public Property RMSInventory() As String
            Get
                Return _RMSInventory
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RMSInventory Then Me.AddAuditField("RMS_Inventory", value)
                _RMSInventory = value
            End Set
        End Property

        Public Property Discountable() As String
            Get
                Return _discountable
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _discountable Then Me.AddAuditField("Discountable", value)
                _discountable = value
            End Set
        End Property

        Public Property AddUnitCost() As Decimal
            Get
                Return _addUnitCost
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _addUnitCost Then Me.AddAuditField("Add_Unit_Cost", value)
                _addUnitCost = value
            End Set
        End Property

        Public Property StoreTotal() As Integer
            Get
                Return _storeTotal
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _storeTotal Then Me.AddAuditField("Store_Total", value)
                _storeTotal = value
            End Set
        End Property
        Public Property POGStartDate() As Date
            Get
                Return _POGStartDate
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _POGStartDate Then Me.AddAuditField("POG_Start_Date", value)
                _POGStartDate = value
            End Set
        End Property
        Public Property POGCompDate() As Date
            Get
                Return _POGCompDate
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _POGCompDate Then Me.AddAuditField("POG_Comp_Date", value)
                _POGCompDate = value
            End Set
        End Property


        Public ReadOnly Property CreatedUser() As String
            Get
                Return _createdUser
            End Get
        End Property
        Public ReadOnly Property UpdateUser() As String
            Get
                Return _updateUser
            End Get
        End Property

        Protected Friend Sub SetReadOnlyUserData(ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updateUser As String)

            _dateCreated = dateCreated
            _createdUserID = createdUserID
            _dateLastModified = dateLastModified
            _updateUserID = updateUserID
            _createdUser = createdUser
            _updateUser = updateUser
        End Sub

        Public Property BatchID() As Long
            Get
                Return _batchID
            End Get
            Set(ByVal value As Long)
                _batchID = value
            End Set
        End Property
        Public ReadOnly Property BatchVendorName() As String
            Get
                Return _batchVendorName
            End Get
        End Property
        Public ReadOnly Property BatchStageID() As Long
            Get
                Return _batchStageID
            End Get
        End Property
        Public ReadOnly Property BatchStageName() As String
            Get
                Return _batchStageName
            End Get
        End Property
        Public ReadOnly Property BatchStageType() As Michaels.WorkflowStageType
            Get
                Return _batchStageType
            End Get
        End Property

        Protected Friend Sub SetReadOnlyBatchData(ByVal batchID As Long, ByVal batchVendorName As String, ByVal batchStageID As Long, ByVal batchStageName As String, ByVal stageType As Integer)
            _batchID = batchID
            _batchVendorName = batchVendorName
            _batchStageID = batchStageID
            _batchStageName = batchStageName
            If Michaels.WorkflowStageType.IsDefined(GetType(Michaels.WorkflowStageType), stageType) Then
                _batchStageType = CType(stageType, Michaels.WorkflowStageType)
            Else
                _batchStageType = Michaels.WorkflowStageType.General
            End If
        End Sub

        Public ReadOnly Property ItemUnknownCount() As Integer
            Get
                Return _itemUnknownCount
            End Get
        End Property

        Public ReadOnly Property ItemNotValidCount() As Integer
            Get
                Return _itemNotValidCount
            End Get
        End Property

        Public ReadOnly Property ItemValidCount() As Integer
            Get
                Return _itemValidCount
            End Get
        End Property

        Public ReadOnly Property ItemCount() As Integer
            Get
                Return (_itemUnknownCount + _itemNotValidCount + _itemValidCount)
            End Get
        End Property
        Public Property CalculateOptions() As Integer
            Get
                Return _CalculateOptions
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _CalculateOptions Then Me.AddAuditField("CalculateOptions", value)
                _CalculateOptions = value
            End Set
        End Property

        Protected Friend Sub SetReadOnlyItemCounts(ByVal unknownCount As Integer, ByVal notValidCount As Integer, ByVal validCount As Integer)
            _itemUnknownCount = unknownCount
            _itemNotValidCount = notValidCount
            _itemValidCount = validCount
        End Sub

    End Class

End Namespace

