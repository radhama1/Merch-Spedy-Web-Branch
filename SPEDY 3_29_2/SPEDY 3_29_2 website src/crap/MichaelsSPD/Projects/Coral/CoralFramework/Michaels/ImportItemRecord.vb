
Namespace Michaels

    Public Class ImportItemRecord
        Inherits AuditRecord

        Private _ID As Long = Long.MinValue
        Private _Batch_ID As Long = Long.MinValue
        Private _DateSubmitted As Date = Date.MinValue
        Private _Vendor As String = String.Empty
        Private _Agent As String = String.Empty
        Private _AgentType As String = String.Empty
        Private _Buyer As String = String.Empty
        Private _Fax As String = String.Empty
        Private _EnteredBy As String = String.Empty
        Private _SKUGroup As String = String.Empty
        Private _Email As String = String.Empty
        Private _EnteredDate As Date = Date.MinValue
        Private _Dept As String = String.Empty
        Private _Class As String = String.Empty
        Private _SubClass As String = String.Empty
        Private _PrimaryUPC As String = String.Empty
        Private _MichaelsSKU As String = String.Empty
        Private _GenerateMichaelsUPC As String = String.Empty
        'Private _AdditionalUPC1 As String = String.Empty
        'Private _AdditionalUPC2 As String = String.Empty
        'Private _AdditionalUPC3 As String = String.Empty
        'Private _AdditionalUPC4 As String = String.Empty
        'Private _AdditionalUPC5 As String = String.Empty
        'Private _AdditionalUPC6 As String = String.Empty
        'Private _AdditionalUPC7 As String = String.Empty
        'Private _AdditionalUPC8 As String = String.Empty
        Private _PackSKU As String = String.Empty
        Private _PlanogramName As String = String.Empty
        Private _VendorNumber As String = String.Empty
        Private _VendorRank As String = String.Empty
        Private _ItemTask As String = String.Empty
        Private _Description As String = String.Empty
        Private _QuoteSheetStatus As String = String.Empty
        Private _Season As String = String.Empty
        Private _PaymentTerms As String = String.Empty
        Private _Days As String = String.Empty
        Private _VendorMinOrderAmount As String = String.Empty
        Private _VendorName As String = String.Empty
        Private _VendorAddress1 As String = String.Empty
        Private _VendorAddress2 As String = String.Empty
        Private _VendorAddress3 As String = String.Empty
        Private _VendorAddress4 As String = String.Empty
        Private _VendorContactName As String = String.Empty
        Private _VendorContactPhone As String = String.Empty
        Private _VendorContactEmail As String = String.Empty
        Private _VendorContactFax As String = String.Empty
        Private _ManufactureName As String = String.Empty
        Private _ManufactureAddress1 As String = String.Empty
        Private _ManufactureAddress2 As String = String.Empty
        Private _ManufactureContact As String = String.Empty
        Private _ManufacturePhone As String = String.Empty
        Private _ManufactureEmail As String = String.Empty
        Private _ManufactureFax As String = String.Empty
        Private _AgentContact As String = String.Empty
        Private _AgentPhone As String = String.Empty
        Private _AgentEmail As String = String.Empty
        Private _AgentFax As String = String.Empty
        Private _VendorStyleNumber As String = String.Empty
        Private _HarmonizedCodeNumber As String = String.Empty
        Private _DetailInvoiceCustomsDesc As String = String.Empty
        Private _ComponentMaterialBreakdown As String = String.Empty
        Private _ComponentConstructionMethod As String = String.Empty
        Private _IndividualItemPackaging As String = String.Empty
        Private _EachInsideMasterCaseBox As String = String.Empty
        Private _EachInsideInnerPack As String = String.Empty
        'Private _EachPieceNetWeightLbsPerOunce As String = String.Empty
        Private _ReshippableInnerCartonLength As String = String.Empty
        Private _ReshippableInnerCartonWidth As String = String.Empty
        Private _ReshippableInnerCartonHeight As String = String.Empty
        Private _MasterCartonDimensionsLength As String = String.Empty
        Private _MasterCartonDimensionsWidth As String = String.Empty
        Private _MasterCartonDimensionsHeight As String = String.Empty
        Private _CubicFeetPerMasterCarton As String = String.Empty
        Private _WeightMasterCarton As String = String.Empty
        Private _CubicFeetPerInnerCarton As String = String.Empty
        Private _FOBShippingPoint As String = String.Empty
        Private _DutyPercent As String = String.Empty
        Private _DutyAmount As String = String.Empty
        Private _AdditionalDutyComment As String = String.Empty
        Private _AdditionalDutyAmount As String = String.Empty
        Private _OceanFreightAmount As String = String.Empty
        Private _OceanFreightComputedAmount As String = String.Empty
        Private _AgentCommissionPercent As String = String.Empty
        Private _RecAgentCommissionPercent As String = String.Empty
        Private _AgentCommissionAmount As String = String.Empty
        Private _OtherImportCostsPercent As String = String.Empty
        Private _OtherImportCostsAmount As String = String.Empty
        Private _PackagingCostAmount As String = String.Empty
        Private _TotalImportBurden As String = String.Empty
        Private _WarehouseLandedCost As String = String.Empty
        Private _PurchaseOrderIssuedTo As String = String.Empty
        Private _ShippingPoint As String = String.Empty
        Private _CountryOfOrigin As String = String.Empty
        Private _CountryOfOriginName As String = String.Empty
        Private _VendorComments As String = String.Empty
        Private _StockCategory As String = String.Empty
        Private _FreightTerms As String = String.Empty
        Private _ItemType As String = String.Empty
        Private _PackItemIndicator As String = String.Empty
        Private _ItemTypeAttribute As String = String.Empty
        Private _AllowStoreOrder As String = String.Empty
        Private _InventoryControl As String = String.Empty
        Private _AutoReplenish As String = String.Empty
        Private _PrePriced As String = String.Empty
        Private _TaxUDA As String = String.Empty
        Private _PrePricedUDA As String = String.Empty
        Private _TaxValueUDA As String = String.Empty
        Private _HybridType As String = String.Empty
        Private _SourcingDC As String = String.Empty
        Private _LeadTime As String = String.Empty
        Private _ConversionDate As Date = Date.MinValue
        Private _StoreSuppZoneGRP As String = String.Empty
        Private _WhseSuppZoneGRP As String = String.Empty
        Private _POGMaxQty As String = String.Empty
        Private _POGSetupPerStore As String = String.Empty
        Private _ProjSalesPerStorePerMonth As String = String.Empty
        Private _OutboundFreight As String = String.Empty
        Private _NinePercentWhseCharge As String = String.Empty
        Private _TotalStoreLandedCost As String = String.Empty
        Private _RDBase As String = String.Empty
        Private _RDCentral As String = String.Empty
        Private _RDTest As String = String.Empty
        Private _RDAlaska As String = String.Empty
        Private _RDCanada As String = String.Empty
        Private _RD0Thru9 As String = String.Empty
        Private _RDCalifornia As String = String.Empty
        Private _RDVillageCraft As String = String.Empty
        'LP change Order 14 Aug 2009, sunny and warm :-)
        Private _Retail9 As Decimal = Decimal.MinValue
        Private _Retail10 As Decimal = Decimal.MinValue
        Private _Retail11 As Decimal = Decimal.MinValue
        Private _Retail12 As Decimal = Decimal.MinValue
        Private _Retail13 As Decimal = Decimal.MinValue
        Private _RDQuebec As Decimal = Decimal.MinValue
        Private _RDPuertoRico As Decimal = Decimal.MinValue

        Private _HazMatYes As String = String.Empty
        Private _HazMatNo As String = String.Empty
        Private _HazMatMFGCountry As String = String.Empty
        Private _HazMatMFGName As String = String.Empty
        Private _HazMatMFGFlammable As String = String.Empty
        Private _HazMatMFGCity As String = String.Empty
        Private _HazMatContainerType As String = String.Empty
        Private _HazMatMFGState As String = String.Empty
        Private _HazMatContainerSize As String = String.Empty
        Private _HazMatMFGPhone As String = String.Empty
        Private _HazMatMSDSUOM As String = String.Empty
        Private _CoinBattery As String = String.Empty
        Private _TSSA As String = String.Empty
        Private _CSA As String = String.Empty
        Private _UL As String = String.Empty
        Private _LicenceAgreement As String = String.Empty
        Private _FumigationCertificate As String = String.Empty
        Private _KILNDriedCertificate As String = String.Empty
        Private _ChinaComInspecNumAndCCIBStickers As String = String.Empty
        Private _OriginalVisa As String = String.Empty
        Private _TextileDeclarationMidCode As String = String.Empty
        Private _QuotaChargeStatement As String = String.Empty
        Private _MSDS As String = String.Empty
        Private _TSCA As String = String.Empty
        Private _DropBallTestCert As String = String.Empty
        Private _ManMedicalDeviceListing As String = String.Empty
        Private _ManFDARegistration As String = String.Empty
        Private _CopyRightIndemnification As String = String.Empty
        Private _FishWildLifeCert As String = String.Empty
        Private _Proposition65LabelReq As String = String.Empty
        Private _CCCR As String = String.Empty
        Private _FormaldehydeCompliant As String = String.Empty
        Private _ImageID As Long = Long.MinValue
        Private _MSDSID As Long = Long.MinValue

        Private _taxWizard As Boolean = False

        Private _isValid As ItemValidFlag = ItemValidFlag.Unknown
        Private _RMSSellable As String = String.Empty
        Private _RMSOrderable As String = String.Empty
        Private _RMSInventory As String = String.Empty

        Private _ParentID As Long = 0

        Private _RegularBatchItem As Boolean = False

        Private _displayerCost As Decimal = Decimal.MinValue
        Private _productCost As Decimal = Decimal.MinValue

        Private _storeTotal As Integer = Integer.MinValue
        Private _POGStartDate As Date = Date.MinValue
        Private _POGCompDate As Date = Date.MinValue
        Private _calculateOptions As Integer = 0
        Private _likeItemSKU As String = String.Empty
        Private _likeItemDescription As String = String.Empty
        Private _likeItemRetail As Decimal = Decimal.MinValue
        Private _annualRegularUnitForecast As Decimal = Decimal.MinValue
        Private _unitStoreMonth As Decimal = Decimal.MinValue
        Private _likeItemStoreCount As Decimal = Decimal.MinValue
        Private _likeItemRegularUnit As Decimal = Decimal.MinValue
        Private _likeItemUnitStoreMonth As Decimal = Decimal.MinValue
        Private _likeItemSales As Decimal = Decimal.MinValue
        Private _adjustedYearlyDemandForecast As Decimal = Decimal.MinValue
        Private _adjustedUnitStoreMonth As Decimal = Decimal.MinValue
        Private _annualRegRetailSales As Decimal = Decimal.MinValue
        Private _facings As Decimal = Decimal.MinValue
        Private _minPresPerFacing As Decimal = Decimal.MinValue
        Private _innerPack As Decimal = Decimal.MinValue
        'lp Spedy Order 12
        Private _POGMinQty As Decimal = Decimal.MinValue

        Private _CreatedUserName As String = String.Empty
        Private _CreatedUserID As Integer = Integer.MinValue
        Private _DateCreated As Date = Date.MinValue
        Private _discountable As String = String.Empty

        Private _UpdatedUserName As String = String.Empty
        Private _UpdateUserID As Integer = Integer.MinValue
        Private _DateLastModified As Date = Date.MinValue

        Private _privateBrandLabel As String = String.Empty

        Private _qtyInPack As Integer = Integer.MinValue

        Private _validExistingSKU As Boolean = False
        Private _itemStatus As String = String.Empty

        Private _additionalUPCRecord As ItemAdditionalUPCRecord = Nothing

        Private _quoteReferenceNumber As String = String.Empty

        'Multi-lingual fields
        Private _customsDescription As String = String.Empty
        Private _PLIEnglish As String
        Private _PLIFrench As String
        Private _PLISpanish As String
        Private _TIEnglish As String
        Private _TIFrench As String
        Private _TISpanish As String
        Private _englishShortDesc As String = String.Empty
        Private _englishLongDesc As String = String.Empty
        Private _frenchShortDesc As String = String.Empty
        Private _frenchLongDesc As String = String.Empty
        Private _spanishShortDesc As String = String.Empty
        Private _spanishLongDesc As String = String.Empty

        Private _exemptEndDateFrench As String = String.Empty

        Private _EachHeight As Decimal = Decimal.MinValue
        Private _EachWidth As Decimal = Decimal.MinValue
        Private _EachLength As Decimal = Decimal.MinValue
        Private _EachWeight As Decimal = Decimal.MinValue
        Private _CubicFeetEach As Decimal = Decimal.MinValue

        Private _CanadaHarmonizedCodeNumber As String = String.Empty
        Private _StockingStrategyCode As String = String.Empty

        Private _ReshippableInnerCartonWeight As Decimal = Decimal.MinValue
        Private _SuppTariffPercent As String = String.Empty
        Private _SuppTariffAmount As String = String.Empty

        'PMO200141 GTIN14 Enhancements changes Start
        Private _InnerGTIN As String = String.Empty
        Private _CaseGTIN As String = String.Empty
        Private _GenerateMichaelsGTIN As String = String.Empty

        Private _PhytoTemporaryShipment As String = String.Empty

        Private _MinimumOrderQuantity As Integer = Integer.MinValue
        Private _ProductIdentifiesAsCosmetic As String = String.Empty



        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
                If Not _additionalUPCRecord Is Nothing Then
                    _additionalUPCRecord.ItemID = _ID
                    _additionalUPCRecord.ItemHeaderID = 0   ' Import Records have no header ID so force it to zero for queries that manipulate this
                End If
            End Set
        End Property

        'Public Property ID() As Long
        '    Get
        '        Return _ID
        '    End Get
        '    Set(ByVal value As Long)
        '        _ID = value
        '    End Set
        'End Property

        Public Property AdditionalUPCRecord() As ItemAdditionalUPCRecord
            Get
                If _additionalUPCRecord Is Nothing Then
                    _additionalUPCRecord = New ItemAdditionalUPCRecord(0, Me.ID)
                End If
                Return _additionalUPCRecord
            End Get
            Set(ByVal value As ItemAdditionalUPCRecord)
                If Not _additionalUPCRecord Is Nothing Then
                    _additionalUPCRecord.AdditionalUPCs.Clear()
                    _additionalUPCRecord = Nothing
                End If
                _additionalUPCRecord = value
                _additionalUPCRecord.ItemHeaderID = 0
                _additionalUPCRecord.ItemID = Me.ID
            End Set
        End Property

        Public ReadOnly Property AdditionalUPCCount() As Integer
            Get
                If Not _additionalUPCRecord Is Nothing Then
                    Return _additionalUPCRecord.AdditionalUPCs.Count
                Else
                    Return 0
                End If
            End Get
        End Property

        Public Property Batch_ID() As Long
            Get
                Return _Batch_ID
            End Get
            Set(ByVal value As Long)
                If Me.SaveAudit AndAlso value <> _Batch_ID Then Me.AddAuditField("Batch_ID", value)
                _Batch_ID = value
            End Set
        End Property

        Public Property DateSubmitted() As Date
            Get
                Return _DateSubmitted
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _DateSubmitted Then Me.AddAuditField("DateSubmitted", value)
                _DateSubmitted = value
            End Set
        End Property

        Public Property Vendor() As String
            Get
                Return _Vendor
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Vendor Then Me.AddAuditField("Vendor", value)
                _Vendor = value
            End Set
        End Property
        Public Property Agent() As String
            Get
                Return _Agent
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Agent Then Me.AddAuditField("Agent", value)
                _Agent = value
            End Set
        End Property
        Public Property AgentType() As String
            Get
                Return _AgentType
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AgentType Then Me.AddAuditField("AgentType", value)
                _AgentType = value
            End Set
        End Property
        Public Property Buyer() As String
            Get
                Return _Buyer
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Buyer Then Me.AddAuditField("Buyer", value)
                _Buyer = value
            End Set
        End Property
        Public Property Fax() As String
            Get
                Return _Fax
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Fax Then Me.AddAuditField("Fax", value)
                _Fax = value
            End Set
        End Property
        Public Property EnteredBy() As String
            Get
                Return _EnteredBy
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _EnteredBy Then Me.AddAuditField("EnteredBy", value)
                _EnteredBy = value
            End Set
        End Property
        Public Property SKUGroup() As String
            Get
                Return _SKUGroup
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _SKUGroup Then Me.AddAuditField("SKUGroup", value)
                _SKUGroup = value
            End Set
        End Property
        Public Property Email() As String
            Get
                Return _Email
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Email Then Me.AddAuditField("Email", value)
                _Email = value
            End Set
        End Property
        Public Property EnteredDate() As Date
            Get
                Return _EnteredDate
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _EnteredDate Then Me.AddAuditField("EnteredDate", value)
                _EnteredDate = value
            End Set
        End Property
        Public Property Dept() As String
            Get
                Return _Dept
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Dept Then Me.AddAuditField("Dept", value)
                _Dept = value
            End Set
        End Property
        Public Property [Class]() As String
            Get
                Return _Class
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Class Then Me.AddAuditField("Class", value)
                _Class = value
            End Set
        End Property
        Public Property SubClass() As String
            Get
                Return _SubClass
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _SubClass Then Me.AddAuditField("SubClass", value)
                _SubClass = value
            End Set
        End Property
        Public Property PrimaryUPC() As String
            Get
                Return _PrimaryUPC
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PrimaryUPC Then Me.AddAuditField("PrimaryUPC", value)
                _PrimaryUPC = value
            End Set
        End Property
        Public Property MichaelsSKU() As String
            Get
                Return _MichaelsSKU
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _MichaelsSKU Then Me.AddAuditField("MichaelsSKU", value)
                _MichaelsSKU = value
            End Set
        End Property
        Public Property GenerateMichaelsUPC() As String
            Get
                Return _GenerateMichaelsUPC
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _GenerateMichaelsUPC Then Me.AddAuditField("GenerateMichaelsUPC", value)
                _GenerateMichaelsUPC = value
            End Set
        End Property

        Public Property PackSKU() As String

            Get
                If IsPackParent() And Not RegularBatchItem Then
                    Return MichaelsSKU
                Else
                    Return _PackSKU
                End If
                'Return _PackSKU
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PackSKU Then Me.AddAuditField("PackSKU", value)
                _PackSKU = value
            End Set
        End Property

        'PMO200141 GTIN14 Enhancements changes 
        Public Property InnerGTIN() As String
            Get
                Return _InnerGTIN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _InnerGTIN Then Me.AddAuditField("InnerGTIN", value)
                _InnerGTIN = value
            End Set
        End Property

        'PMO200141 GTIN14 Enhancements changes 
        Public Property CaseGTIN() As String
            Get
                Return _CaseGTIN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CaseGTIN Then Me.AddAuditField("CaseGTIN", value)
                _CaseGTIN = value
            End Set
        End Property

        'PMO200141 GTIN14 Enhancements changes 
        Public Property GenerateMichaelsGTIN() As String
            Get
                Return _GenerateMichaelsGTIN
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _GenerateMichaelsGTIN Then Me.AddAuditField("GenerateMichaelsGTIN", value)
                _GenerateMichaelsGTIN = value
            End Set
        End Property

        Public Property PlanogramName() As String
            Get
                Return _PlanogramName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PlanogramName Then Me.AddAuditField("PlanogramName", value)
                _PlanogramName = value
            End Set
        End Property
        Public Property VendorNumber() As String
            Get
                Return _VendorNumber
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorNumber Then Me.AddAuditField("VendorNumber", value)
                _VendorNumber = value
            End Set
        End Property
        Public Property Description() As String
            Get
                Return _Description
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Description Then Me.AddAuditField("Description", value)
                _Description = value
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
        Public Property PaymentTerms() As String
            Get
                Return _PaymentTerms
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PaymentTerms Then Me.AddAuditField("PaymentTerms", value)
                _PaymentTerms = value
            End Set
        End Property
        Public Property QuoteSheetStatus() As String
            Get
                Return _QuoteSheetStatus
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _QuoteSheetStatus Then Me.AddAuditField("QuoteSheetStatus", value)
                _QuoteSheetStatus = value
            End Set
        End Property
        Public Property Season() As String
            Get
                Return _Season
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Season Then Me.AddAuditField("Season", value)
                _Season = value
            End Set
        End Property
        Public Property Days() As String
            Get
                Return _Days
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Days Then Me.AddAuditField("Days", value)
                _Days = value
            End Set
        End Property
        Public Property VendorMinOrderAmount() As String
            Get
                Return _VendorMinOrderAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorMinOrderAmount Then Me.AddAuditField("VendorMinOrderAmount", value)
                _VendorMinOrderAmount = value
            End Set
        End Property
        Public Property VendorName() As String
            Get
                Return _VendorName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorName Then Me.AddAuditField("VendorName", value)
                _VendorName = value
            End Set
        End Property
        Public Property VendorAddress1() As String
            Get
                Return _VendorAddress1
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorAddress1 Then Me.AddAuditField("VendorAddress1", value)
                _VendorAddress1 = value
            End Set
        End Property
        Public Property VendorAddress2() As String
            Get
                Return _VendorAddress2
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorAddress2 Then Me.AddAuditField("VendorAddress2", value)
                _VendorAddress2 = value
            End Set
        End Property
        Public Property VendorAddress3() As String
            Get
                Return _VendorAddress3
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorAddress3 Then Me.AddAuditField("VendorAddress3", value)
                _VendorAddress3 = value
            End Set
        End Property
        Public Property VendorAddress4() As String
            Get
                Return _VendorAddress4
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorAddress4 Then Me.AddAuditField("VendorAddress4", value)
                _VendorAddress4 = value
            End Set
        End Property
        Public Property VendorContactName() As String
            Get
                Return _VendorContactName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorContactName Then Me.AddAuditField("VendorContactName", value)
                _VendorContactName = value
            End Set
        End Property
        Public Property VendorContactPhone() As String
            Get
                Return _VendorContactPhone
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorContactPhone Then Me.AddAuditField("VendorContactPhone", value)
                _VendorContactPhone = value
            End Set
        End Property
        Public Property VendorContactEmail() As String
            Get
                Return _VendorContactEmail
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorContactEmail Then Me.AddAuditField("VendorContactEmail", value)
                _VendorContactEmail = value
            End Set
        End Property
        Public Property VendorContactFax() As String
            Get
                Return _VendorContactFax
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorContactFax Then Me.AddAuditField("VendorContactFax", value)
                _VendorContactFax = value
            End Set
        End Property
        Public Property ManufactureName() As String
            Get
                Return _ManufactureName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManufactureName Then Me.AddAuditField("ManufactureName", value)
                _ManufactureName = value
            End Set
        End Property
        Public Property ManufactureAddress1() As String
            Get
                Return _ManufactureAddress1
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManufactureAddress1 Then Me.AddAuditField("ManufactureAddress1", value)
                _ManufactureAddress1 = value
            End Set
        End Property
        Public Property ManufactureAddress2() As String
            Get
                Return _ManufactureAddress2
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManufactureAddress2 Then Me.AddAuditField("ManufactureAddress2", value)
                _ManufactureAddress2 = value
            End Set
        End Property
        Public Property ManufactureContact() As String
            Get
                Return _ManufactureContact
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManufactureContact Then Me.AddAuditField("ManufactureContact", value)
                _ManufactureContact = value
            End Set
        End Property
        Public Property ManufacturePhone() As String
            Get
                Return _ManufacturePhone
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManufacturePhone Then Me.AddAuditField("ManufacturePhone", value)
                _ManufacturePhone = value
            End Set
        End Property
        Public Property ManufactureEmail() As String
            Get
                Return _ManufactureEmail
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManufactureEmail Then Me.AddAuditField("ManufactureEmail", value)
                _ManufactureEmail = value
            End Set
        End Property
        Public Property ManufactureFax() As String
            Get
                Return _ManufactureFax
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManufactureFax Then Me.AddAuditField("ManufactureFax", value)
                _ManufactureFax = value
            End Set
        End Property
        Public Property AgentContact() As String
            Get
                Return _AgentContact
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AgentContact Then Me.AddAuditField("AgentContact", value)
                _AgentContact = value
            End Set
        End Property
        Public Property AgentPhone() As String
            Get
                Return _AgentPhone
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AgentPhone Then Me.AddAuditField("AgentPhone", value)
                _AgentPhone = value
            End Set
        End Property
        Public Property AgentEmail() As String
            Get
                Return _AgentEmail
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AgentEmail Then Me.AddAuditField("AgentEmail", value)
                _AgentEmail = value
            End Set
        End Property
        Public Property AgentFax() As String
            Get
                Return _AgentFax
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AgentFax Then Me.AddAuditField("AgentFax", value)
                _AgentFax = value
            End Set
        End Property
        Public Property VendorStyleNumber() As String
            Get
                Return _VendorStyleNumber
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorStyleNumber Then Me.AddAuditField("VendorStyleNumber", value)
                _VendorStyleNumber = value
            End Set
        End Property
        Public Property HarmonizedCodeNumber() As String
            Get
                Return _HarmonizedCodeNumber
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HarmonizedCodeNumber Then Me.AddAuditField("HarmonizedCodeNumber", value)
                _HarmonizedCodeNumber = value
            End Set
        End Property
        Public Property DetailInvoiceCustomsDesc() As String
            Get
                Return _DetailInvoiceCustomsDesc
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _DetailInvoiceCustomsDesc Then Me.AddAuditField("DetailInvoiceCustomsDesc", value)
                _DetailInvoiceCustomsDesc = value
            End Set
        End Property
        Public Property ComponentMaterialBreakdown() As String
            Get
                Return _ComponentMaterialBreakdown
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ComponentMaterialBreakdown Then Me.AddAuditField("ComponentMaterialBreakdown", value)
                _ComponentMaterialBreakdown = value
            End Set
        End Property
        Public Property ComponentConstructionMethod() As String
            Get
                Return _ComponentConstructionMethod
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ComponentConstructionMethod Then Me.AddAuditField("ComponentConstructionMethod", value)
                _ComponentConstructionMethod = value
            End Set
        End Property
        Public Property IndividualItemPackaging() As String
            Get
                Return _IndividualItemPackaging
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _IndividualItemPackaging Then Me.AddAuditField("IndividualItemPackaging", value)
                _IndividualItemPackaging = value
            End Set
        End Property
        Public Property EachInsideMasterCaseBox() As String
            Get
                Return _EachInsideMasterCaseBox
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _EachInsideMasterCaseBox Then Me.AddAuditField("EachInsideMasterCaseBox", value)
                _EachInsideMasterCaseBox = value
            End Set
        End Property
        Public Property EachInsideInnerPack() As String
            Get
                Return _EachInsideInnerPack
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _EachInsideInnerPack Then Me.AddAuditField("EachInsideInnerPack", value)
                _EachInsideInnerPack = value
            End Set
        End Property
        'Public Property EachPieceNetWeightLbsPerOunce() As String
        '    Get
        '        Return _EachPieceNetWeightLbsPerOunce
        '    End Get
        '    Set(ByVal value As String)
        '        If Me.SaveAudit AndAlso value <> _EachPieceNetWeightLbsPerOunce Then Me.AddAuditField("EachPieceNetWeightLbsPerOunce", value)
        '        _EachPieceNetWeightLbsPerOunce = value
        '    End Set
        'End Property
        Public Property ReshippableInnerCartonLength() As String
            Get
                Return _ReshippableInnerCartonLength
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ReshippableInnerCartonLength Then Me.AddAuditField("ReshippableInnerCartonLength", value)
                _ReshippableInnerCartonLength = value
            End Set
        End Property
        Public Property ReshippableInnerCartonWidth() As String
            Get
                Return _ReshippableInnerCartonWidth
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ReshippableInnerCartonWidth Then Me.AddAuditField("ReshippableInnerCartonWidth", value)
                _ReshippableInnerCartonWidth = value
            End Set
        End Property
        Public Property ReshippableInnerCartonHeight() As String
            Get
                Return _ReshippableInnerCartonHeight
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ReshippableInnerCartonHeight Then Me.AddAuditField("ReshippableInnerCartonHeight", value)
                _ReshippableInnerCartonHeight = value
            End Set
        End Property
        Public Property MasterCartonDimensionsLength() As String
            Get
                Return _MasterCartonDimensionsLength
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _MasterCartonDimensionsLength Then Me.AddAuditField("MasterCartonDimensionsLength", value)
                _MasterCartonDimensionsLength = value
            End Set
        End Property
        Public Property MasterCartonDimensionsWidth() As String
            Get
                Return _MasterCartonDimensionsWidth
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _MasterCartonDimensionsWidth Then Me.AddAuditField("MasterCartonDimensionsWidth", value)
                _MasterCartonDimensionsWidth = value
            End Set
        End Property
        Public Property MasterCartonDimensionsHeight() As String
            Get
                Return _MasterCartonDimensionsHeight
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _MasterCartonDimensionsHeight Then Me.AddAuditField("MasterCartonDimensionsHeight", value)
                _MasterCartonDimensionsHeight = value
            End Set
        End Property
        Public Property CubicFeetPerMasterCarton() As String
            Get
                Return _CubicFeetPerMasterCarton
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CubicFeetPerMasterCarton Then Me.AddAuditField("CubicFeetPerMasterCarton", value)
                _CubicFeetPerMasterCarton = value
            End Set
        End Property
        Public Property WeightMasterCarton() As String
            Get
                Return _WeightMasterCarton
            End Get
            Set(ByVal value As String)
                If _trackChanges AndAlso value <> _WeightMasterCarton Then _masterWeightChanged = True
                If Me.SaveAudit AndAlso value <> _WeightMasterCarton Then Me.AddAuditField("WeightMasterCarton", value)
                _WeightMasterCarton = value
            End Set
        End Property
        Public Property CubicFeetPerInnerCarton() As String
            Get
                Return _CubicFeetPerInnerCarton
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CubicFeetPerInnerCarton Then Me.AddAuditField("CubicFeetPerInnerCarton", value)
                _CubicFeetPerInnerCarton = value
            End Set
        End Property

        Public Property FOBShippingPoint() As String
            Get
                Return _FOBShippingPoint
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _FOBShippingPoint Then Me.AddAuditField("FOBShippingPoint", value)
                _FOBShippingPoint = value
            End Set
        End Property
        Public Property DutyPercent() As String
            Get
                Return _DutyPercent
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _DutyPercent Then Me.AddAuditField("DutyPercent", value)
                _DutyPercent = value
            End Set
        End Property
        Public Property DutyAmount() As String
            Get
                Return _DutyAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _DutyAmount Then Me.AddAuditField("DutyAmount", value)
                _DutyAmount = value
            End Set
        End Property
        Public Property AdditionalDutyComment() As String
            Get
                Return _AdditionalDutyComment
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AdditionalDutyComment Then Me.AddAuditField("AdditionalDutyComment", value)
                _AdditionalDutyComment = value
            End Set
        End Property
        Public Property AdditionalDutyAmount() As String
            Get
                Return _AdditionalDutyAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AdditionalDutyAmount Then Me.AddAuditField("AdditionalDutyAmount", value)
                _AdditionalDutyAmount = value
            End Set
        End Property
        Public Property OceanFreightAmount() As String
            Get
                Return _OceanFreightAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _OceanFreightAmount Then Me.AddAuditField("OceanFreightAmount", value)
                _OceanFreightAmount = value
            End Set
        End Property
        Public Property OceanFreightComputedAmount() As String
            Get
                Return _OceanFreightComputedAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _OceanFreightComputedAmount Then Me.AddAuditField("OceanFreightComputedAmount", value)
                _OceanFreightComputedAmount = value
            End Set
        End Property
        Public Property AgentCommissionPercent() As String
            Get
                Return _AgentCommissionPercent
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AgentCommissionPercent Then Me.AddAuditField("AgentCommissionPercent", value)
                _AgentCommissionPercent = value
            End Set
        End Property
        Public Property RecAgentCommissionPercent() As String
            Get
                Return _RecAgentCommissionPercent
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RecAgentCommissionPercent Then Me.AddAuditField("RecAgentCommissionPercent", value)
                _RecAgentCommissionPercent = value
            End Set
        End Property
        Public Property AgentCommissionAmount() As String
            Get
                Return _AgentCommissionAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AgentCommissionAmount Then Me.AddAuditField("AgentCommissionAmount", value)
                _AgentCommissionAmount = value
            End Set
        End Property
        Public Property OtherImportCostsPercent() As String
            Get
                Return _OtherImportCostsPercent
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _OtherImportCostsPercent Then Me.AddAuditField("OtherImportCostsPercent", value)
                _OtherImportCostsPercent = value
            End Set
        End Property
        Public Property OtherImportCostsAmount() As String
            Get
                Return _OtherImportCostsAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _OtherImportCostsAmount Then Me.AddAuditField("OtherImportCostsAmount", value)
                _OtherImportCostsAmount = value
            End Set
        End Property
        Public Property PackagingCostAmount() As String
            Get
                Return _PackagingCostAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PackagingCostAmount Then Me.AddAuditField("PackagingCostAmount", value)
                _PackagingCostAmount = value
            End Set
        End Property
        Public Property TotalImportBurden() As String
            Get
                Return _TotalImportBurden
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _TotalImportBurden Then Me.AddAuditField("TotalImportBurden", value)
                _TotalImportBurden = value
            End Set
        End Property
        Public Property WarehouseLandedCost() As String
            Get
                Return _WarehouseLandedCost
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _WarehouseLandedCost Then Me.AddAuditField("WarehouseLandedCost", value)
                _WarehouseLandedCost = value
            End Set
        End Property
        Public Property PurchaseOrderIssuedTo() As String
            Get
                Return _PurchaseOrderIssuedTo
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PurchaseOrderIssuedTo Then Me.AddAuditField("PurchaseOrderIssuedTo", value)
                _PurchaseOrderIssuedTo = value
            End Set
        End Property
        Public Property ShippingPoint() As String
            Get
                Return _ShippingPoint
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ShippingPoint Then Me.AddAuditField("ShippingPoint", value)
                _ShippingPoint = value
            End Set
        End Property
        Public Property CountryOfOrigin() As String
            Get
                Return _CountryOfOrigin
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CountryOfOrigin Then Me.AddAuditField("CountryOfOrigin", value)
                _CountryOfOrigin = value
            End Set
        End Property
        Public Property CountryOfOriginName() As String
            Get
                Return _CountryOfOriginName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CountryOfOriginName Then Me.AddAuditField("CountryOfOriginName", value)
                _CountryOfOriginName = value
            End Set
        End Property
        Public Property VendorComments() As String
            Get
                Return _VendorComments
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorComments Then Me.AddAuditField("VendorComments", value)
                _VendorComments = value
            End Set
        End Property
        Public Property StockCategory() As String
            Get
                Return _StockCategory
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _StockCategory Then Me.AddAuditField("StockCategory", value)
                _StockCategory = value
            End Set
        End Property
        Public Property FreightTerms() As String
            Get
                Return _FreightTerms
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _FreightTerms Then Me.AddAuditField("FreightTerms", value)
                _FreightTerms = value
            End Set
        End Property
        Public Property ItemType() As String
            Get
                Return _ItemType
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ItemType Then Me.AddAuditField("ItemType", value)
                _ItemType = value
            End Set
        End Property
        Public Property PackItemIndicator() As String
            Get
                Return _PackItemIndicator
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PackItemIndicator Then Me.AddAuditField("PackItemIndicator", value)
                _PackItemIndicator = value
            End Set
        End Property
        Public Property ItemTypeAttribute() As String
            Get
                Return _ItemTypeAttribute
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ItemTypeAttribute Then Me.AddAuditField("ItemTypeAttribute", value)
                _ItemTypeAttribute = value
            End Set
        End Property
        Public Property AllowStoreOrder() As String
            Get
                Return _AllowStoreOrder
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AllowStoreOrder Then Me.AddAuditField("AllowStoreOrder", value)
                _AllowStoreOrder = value
            End Set
        End Property
        Public Property InventoryControl() As String
            Get
                Return _InventoryControl
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _InventoryControl Then Me.AddAuditField("InventoryControl", value)
                _InventoryControl = value
            End Set
        End Property
        Public Property AutoReplenish() As String
            Get
                Return _AutoReplenish
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _AutoReplenish Then Me.AddAuditField("AutoReplenish", value)
                _AutoReplenish = value
            End Set
        End Property
        Public Property PrePriced() As String
            Get
                Return _PrePriced
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PrePriced Then Me.AddAuditField("PrePriced", value)
                _PrePriced = value
            End Set
        End Property
        Public Property TaxUDA() As String
            Get
                Return _TaxUDA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _TaxUDA Then Me.AddAuditField("TaxUDA", value)
                _TaxUDA = value
            End Set
        End Property
        Public Property PrePricedUDA() As String
            Get
                Return _PrePricedUDA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PrePricedUDA Then Me.AddAuditField("PrePricedUDA", value)
                _PrePricedUDA = value
            End Set
        End Property
        Public Property TaxValueUDA() As String
            Get
                Return _TaxValueUDA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _TaxValueUDA Then Me.AddAuditField("TaxValueUDA", value)
                _TaxValueUDA = value
            End Set
        End Property
        Public Property HybridType() As String
            Get
                Return _HybridType
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HybridType Then Me.AddAuditField("HybridType", value)
                _HybridType = value
            End Set
        End Property
        Public Property SourcingDC() As String
            Get
                Return _SourcingDC
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _SourcingDC Then Me.AddAuditField("SourcingDC", value)
                _SourcingDC = value
            End Set
        End Property
        Public Property LeadTime() As String
            Get
                Return _LeadTime
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _LeadTime Then Me.AddAuditField("LeadTime", value)
                _LeadTime = value
            End Set
        End Property
        Public Property ConversionDate() As Date
            Get
                Return _ConversionDate
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _ConversionDate Then Me.AddAuditField("ConversionDate", value)
                _ConversionDate = value
            End Set
        End Property
        Public Property StoreSuppZoneGRP() As String
            Get
                Return _StoreSuppZoneGRP
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _StoreSuppZoneGRP Then Me.AddAuditField("StoreSuppZoneGRP", value)
                _StoreSuppZoneGRP = value
            End Set
        End Property
        Public Property WhseSuppZoneGRP() As String
            Get
                Return _WhseSuppZoneGRP
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _WhseSuppZoneGRP Then Me.AddAuditField("WhseSuppZoneGRP", value)
                _WhseSuppZoneGRP = value
            End Set
        End Property
        Public Property POGMaxQty() As String
            Get
                Return _POGMaxQty
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _POGMaxQty Then Me.AddAuditField("POGMaxQty", value)
                _POGMaxQty = value
            End Set
        End Property
        Public Property POGMinQty() As Decimal
            'lp Spedy Order 12
            Get
                Return _POGMinQty
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _POGMinQty Then Me.AddAuditField("POG_Min_Qty", value)
                _POGMinQty = value
            End Set
        End Property
        Public Property POGSetupPerStore() As String
            Get
                Return _POGSetupPerStore
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _POGSetupPerStore Then Me.AddAuditField("POGSetupPerStore", value)
                _POGSetupPerStore = value
            End Set
        End Property
        Public Property ProjSalesPerStorePerMonth() As String
            Get
                Return _ProjSalesPerStorePerMonth
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ProjSalesPerStorePerMonth Then Me.AddAuditField("ProjSalesPerStorePerMonth", value)
                _ProjSalesPerStorePerMonth = value
            End Set
        End Property
        Public Property RDBase() As String
            Get
                Return _RDBase
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RDBase Then Me.AddAuditField("RDBase", value)
                _RDBase = value
            End Set
        End Property
        Public Property RDCentral() As String
            Get
                Return _RDCentral
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RDCentral Then Me.AddAuditField("RDCentral", value)
                _RDCentral = value
            End Set
        End Property
        Public Property RDTest() As String
            Get
                Return _RDTest
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RDTest Then Me.AddAuditField("RDTest", value)
                _RDTest = value
            End Set
        End Property
        Public Property OutboundFreight() As String
            Get
                Return _OutboundFreight
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _OutboundFreight Then Me.AddAuditField("OutboundFreight", value)
                _OutboundFreight = value
            End Set
        End Property
        Public Property RDAlaska() As String
            Get
                Return _RDAlaska
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RDAlaska Then Me.AddAuditField("RDAlaska", value)
                _RDAlaska = value
            End Set
        End Property
        Public Property NinePercentWhseCharge() As String
            Get
                Return _NinePercentWhseCharge
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _NinePercentWhseCharge Then Me.AddAuditField("NinePercentWhseCharge", value)
                _NinePercentWhseCharge = value
            End Set
        End Property
        Public Property RDCanada() As String
            Get
                Return _RDCanada
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RDCanada Then Me.AddAuditField("RDCanada", value)
                _RDCanada = value
            End Set
        End Property
        Public Property TotalStoreLandedCost() As String
            Get
                Return _TotalStoreLandedCost
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _TotalStoreLandedCost Then Me.AddAuditField("TotalStoreLandedCost", value)
                _TotalStoreLandedCost = value
            End Set
        End Property
        Public Property RD0Thru9() As String
            Get
                Return _RD0Thru9
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RD0Thru9 Then Me.AddAuditField("RD0Thru9", value)
                _RD0Thru9 = value
            End Set
        End Property
        Public Property RDCalifornia() As String
            Get
                Return _RDCalifornia
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RDCalifornia Then Me.AddAuditField("RDCalifornia", value)
                _RDCalifornia = value
            End Set
        End Property
        Public Property RDVillageCraft() As String
            Get
                Return _RDVillageCraft
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _RDVillageCraft Then Me.AddAuditField("RDVillageCraft", value)
                _RDVillageCraft = value
            End Set
        End Property
        Public Property HazMatYes() As String
            Get
                Return _HazMatYes
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatYes Then Me.AddAuditField("HazMatYes", value)
                _HazMatYes = value
            End Set
        End Property
        Public Property HazMatNo() As String
            Get
                Return _HazMatNo
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatNo Then Me.AddAuditField("HazMatNo", value)
                _HazMatNo = value
            End Set
        End Property
        Public Property HazMatMFGCountry() As String
            Get
                Return _HazMatMFGCountry
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatMFGCountry Then Me.AddAuditField("HazMatMFGCountry", value)
                _HazMatMFGCountry = value
            End Set
        End Property
        Public Property HazMatMFGName() As String
            Get
                Return _HazMatMFGName
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatMFGName Then Me.AddAuditField("HazMatMFGName", value)
                _HazMatMFGName = value
            End Set
        End Property
        Public Property HazMatMFGFlammable() As String
            Get
                Return _HazMatMFGFlammable
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatMFGFlammable Then Me.AddAuditField("HazMatMFGFlammable", value)
                _HazMatMFGFlammable = value
            End Set
        End Property
        Public Property HazMatMFGCity() As String
            Get
                Return _HazMatMFGCity
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatMFGCity Then Me.AddAuditField("HazMatMFGCity", value)
                _HazMatMFGCity = value
            End Set
        End Property
        Public Property HazMatContainerType() As String
            Get
                Return _HazMatContainerType
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatContainerType Then Me.AddAuditField("HazMatContainerType", value)
                _HazMatContainerType = value
            End Set
        End Property
        Public Property HazMatMFGState() As String
            Get
                Return _HazMatMFGState
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatMFGState Then Me.AddAuditField("HazMatMFGState", value)
                _HazMatMFGState = value
            End Set
        End Property
        Public Property HazMatContainerSize() As String
            Get
                Return _HazMatContainerSize
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatContainerSize Then Me.AddAuditField("HazMatContainerSize", value)
                _HazMatContainerSize = value
            End Set
        End Property
        Public Property HazMatMFGPhone() As String
            Get
                Return _HazMatMFGPhone
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatMFGPhone Then Me.AddAuditField("HazMatMFGPhone", value)
                _HazMatMFGPhone = value
            End Set
        End Property
        Public Property HazMatMSDSUOM() As String
            Get
                Return _HazMatMSDSUOM
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _HazMatMSDSUOM Then Me.AddAuditField("HazMatMSDSUOM", value)
                _HazMatMSDSUOM = value
            End Set
        End Property
        Public Property CoinBattery() As String
            Get
                Return _CoinBattery
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CoinBattery Then Me.AddAuditField("CoinBattery", value)
                _CoinBattery = value
            End Set
        End Property
        Public Property TSSA() As String
            Get
                Return _TSSA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _TSSA Then Me.AddAuditField("TSSA", value)
                _TSSA = value
            End Set
        End Property
        Public Property CSA() As String
            Get
                Return _CSA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CSA Then Me.AddAuditField("CSA", value)
                _CSA = value
            End Set
        End Property
        Public Property UL() As String
            Get
                Return _UL
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _UL Then Me.AddAuditField("UL", value)
                _UL = value
            End Set
        End Property
        Public Property LicenceAgreement() As String
            Get
                Return _LicenceAgreement
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _LicenceAgreement Then Me.AddAuditField("LicenceAgreement", value)
                _LicenceAgreement = value
            End Set
        End Property
        Public Property FumigationCertificate() As String
            Get
                Return _FumigationCertificate
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _FumigationCertificate Then Me.AddAuditField("FumigationCertificate", value)
                _FumigationCertificate = value
            End Set
        End Property

        Public Property PhytoTemporaryShipment() As String
            Get
                Return _PhytoTemporaryShipment
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _PhytoTemporaryShipment Then Me.AddAuditField("PhytoTemporaryShipment", value)
                _PhytoTemporaryShipment = value
            End Set
        End Property

        Public Property KILNDriedCertificate() As String
            Get
                Return _KILNDriedCertificate
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _KILNDriedCertificate Then Me.AddAuditField("KILNDriedCertificate", value)
                _KILNDriedCertificate = value
            End Set
        End Property
        Public Property ChinaComInspecNumAndCCIBStickers() As String
            Get
                Return _ChinaComInspecNumAndCCIBStickers
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ChinaComInspecNumAndCCIBStickers Then Me.AddAuditField("ChinaComInspecNumAndCCIBStickers", value)
                _ChinaComInspecNumAndCCIBStickers = value
            End Set
        End Property
        Public Property OriginalVisa() As String
            Get
                Return _OriginalVisa
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _OriginalVisa Then Me.AddAuditField("OriginalVisa", value)
                _OriginalVisa = value
            End Set
        End Property
        Public Property TextileDeclarationMidCode() As String
            Get
                Return _TextileDeclarationMidCode
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _TextileDeclarationMidCode Then Me.AddAuditField("TextileDeclarationMidCode", value)
                _TextileDeclarationMidCode = value
            End Set
        End Property
        Public Property QuotaChargeStatement() As String
            Get
                Return _QuotaChargeStatement
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _QuotaChargeStatement Then Me.AddAuditField("QuotaChargeStatement", value)
                _QuotaChargeStatement = value
            End Set
        End Property
        Public Property MSDS() As String
            Get
                Return _MSDS
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _MSDS Then Me.AddAuditField("MSDS", value)
                _MSDS = value
            End Set
        End Property
        Public Property TSCA() As String
            Get
                Return _TSCA
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _TSCA Then Me.AddAuditField("TSCA", value)
                _TSCA = value
            End Set
        End Property
        Public Property DropBallTestCert() As String
            Get
                Return _DropBallTestCert
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _DropBallTestCert Then Me.AddAuditField("DropBallTestCert", value)
                _DropBallTestCert = value
            End Set
        End Property
        Public Property ManMedicalDeviceListing() As String
            Get
                Return _ManMedicalDeviceListing
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManMedicalDeviceListing Then Me.AddAuditField("ManMedicalDeviceListing", value)
                _ManMedicalDeviceListing = value
            End Set
        End Property
        Public Property ManFDARegistration() As String
            Get
                Return _ManFDARegistration
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ManFDARegistration Then Me.AddAuditField("ManFDARegistration", value)
                _ManFDARegistration = value
            End Set
        End Property
        Public Property CopyRightIndemnification() As String
            Get
                Return _CopyRightIndemnification
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CopyRightIndemnification Then Me.AddAuditField("CopyRightIndemnification", value)
                _CopyRightIndemnification = value
            End Set
        End Property
        Public Property FishWildLifeCert() As String
            Get
                Return _FishWildLifeCert
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _FishWildLifeCert Then Me.AddAuditField("FishWildLifeCert", value)
                _FishWildLifeCert = value
            End Set
        End Property
        Public Property Proposition65LabelReq() As String
            Get
                Return _Proposition65LabelReq
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _Proposition65LabelReq Then Me.AddAuditField("Proposition65LabelReq", value)
                _Proposition65LabelReq = value
            End Set
        End Property
        Public Property CCCR() As String
            Get
                Return _CCCR
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CCCR Then Me.AddAuditField("CCCR", value)
                _CCCR = value
            End Set
        End Property
        Public Property FormaldehydeCompliant() As String
            Get
                Return _FormaldehydeCompliant
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _FormaldehydeCompliant Then Me.AddAuditField("FormaldehydeCompliant", value)
                _FormaldehydeCompliant = value
            End Set
        End Property
        Public Property VendorRank() As String
            Get
                Return _VendorRank
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _VendorRank Then Me.AddAuditField("VendorRank", value)
                _VendorRank = value
            End Set
        End Property
        Public Property ItemTask() As String
            Get
                Return _ItemTask
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ItemTask Then Me.AddAuditField("ItemTask", value)
                _ItemTask = value
            End Set
        End Property
        Public ReadOnly Property DateCreated() As Date
            Get
                Return _DateCreated
            End Get
        End Property
        Public ReadOnly Property CreatedUserID() As Integer
            Get
                Return _CreatedUserID
            End Get
        End Property
        Public ReadOnly Property DateLastModified() As Date
            Get
                Return _DateLastModified
            End Get
        End Property
        Public ReadOnly Property UpdateUserID() As Integer
            Get
                Return _UpdateUserID
            End Get
        End Property
        Public ReadOnly Property CreatedUserName() As String
            Get
                Return _CreatedUserName
            End Get
        End Property
        Public ReadOnly Property UpdatedUserName() As String
            Get
                Return _UpdatedUserName
            End Get
        End Property
        Public ReadOnly Property ImageID() As Long
            Get
                Return _ImageID
            End Get
        End Property
        Public ReadOnly Property MSDSID() As Long
            Get
                Return _MSDSID
            End Get
        End Property

        Public Property TaxWizard() As Boolean
            Get
                Return _taxWizard
            End Get
            Set(ByVal value As Boolean)
                _taxWizard = value
            End Set
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

        Public Property ParentID() As Long
            Get
                Return _ParentID
            End Get
            Set(ByVal value As Long)
                If Me.SaveAudit AndAlso value <> _ParentID Then Me.AddAuditField("Parent_ID", value)
                _ParentID = value
            End Set
        End Property

        Public Property RegularBatchItem() As Boolean
            Get
                Return _RegularBatchItem
            End Get
            Set(ByVal value As Boolean)
                If Me.SaveAudit AndAlso value <> _RegularBatchItem Then Me.AddAuditField("RegularBatchItem", value)
                _RegularBatchItem = value
            End Set
        End Property


        Public Property DisplayerCost() As Decimal
            Get
                Return _displayerCost
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _displayerCost Then Me.AddAuditField("DisplayerCost", value)
                _displayerCost = value
            End Set
        End Property

        Public Property ProductCost() As Decimal
            Get
                Return _productCost
            End Get
            Set(ByVal value As Decimal)
                If _trackChanges AndAlso value <> _productCost Then _costFieldsChanged = True
                If Me.SaveAudit AndAlso value <> _productCost Then Me.AddAuditField("ProductCost", value)
                _productCost = value
            End Set
        End Property

        Public Property StoreTotal() As Integer
            Get
                Return _storeTotal
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _storeTotal Then Me.AddAuditField("StoreTotal", value)
                _storeTotal = value
            End Set
        End Property
        Public Property POGStartDate() As Date
            Get
                Return _POGStartDate
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _POGStartDate Then Me.AddAuditField("POGStartDate", value)
                _POGStartDate = value
            End Set
        End Property
        Public Property POGCompDate() As Date
            Get
                Return _POGCompDate
            End Get
            Set(ByVal value As Date)
                If Me.SaveAudit AndAlso value <> _POGCompDate Then Me.AddAuditField("POGCompDate", value)
                _POGCompDate = value
            End Set
        End Property
        Public Property CalculateOptions() As Integer
            Get
                Return _calculateOptions
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _calculateOptions Then Me.AddAuditField("CalculateOptions", value)
                _calculateOptions = value
            End Set
        End Property
        Public Property LikeItemSKU() As String
            Get
                Return _likeItemSKU
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _likeItemSKU Then Me.AddAuditField("LikeItemSKU", value)
                _likeItemSKU = value
            End Set
        End Property
        Public Property LikeItemDescription() As String
            Get
                Return _likeItemDescription
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _likeItemDescription Then Me.AddAuditField("LikeItemDescription", value)
                _likeItemDescription = value
            End Set
        End Property
        Public Property LikeItemRetail() As Decimal
            Get
                Return _likeItemRetail
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemRetail Then Me.AddAuditField("LikeItemRetail", value)
                _likeItemRetail = value
            End Set
        End Property
        Public Property AnnualRegularUnitForecast() As Decimal
            Get
                Return _annualRegularUnitForecast
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _annualRegularUnitForecast Then Me.AddAuditField("AnnualRegularUnitForecast", value)
                _annualRegularUnitForecast = value
            End Set
        End Property
        Public Property UnitStoreMonth() As Decimal
            Get
                Return _unitStoreMonth
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _unitStoreMonth Then Me.AddAuditField("UnitStoreMonth", value)
                _unitStoreMonth = value
            End Set
        End Property
        Public Property LikeItemStoreCount() As Decimal
            Get
                Return _likeItemStoreCount
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemStoreCount Then Me.AddAuditField("LikeItemStoreCount", value)
                _likeItemStoreCount = value
            End Set
        End Property
        Public Property LikeItemRegularUnit() As Decimal
            Get
                Return _likeItemRegularUnit
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemRegularUnit Then Me.AddAuditField("LikeItemRegularUnit", value)
                _likeItemRegularUnit = value
            End Set
        End Property
        Public Property LikeItemUnitStoreMonth() As Decimal
            Get
                Return _likeItemUnitStoreMonth
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemUnitStoreMonth Then Me.AddAuditField("LikeItemUnitStoreMonth", value)
                _likeItemUnitStoreMonth = value
            End Set
        End Property
        Public Property LikeItemSales() As Decimal
            Get
                Return _likeItemSales
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _likeItemSales Then Me.AddAuditField("LIkeItemSales", value)
                _likeItemSales = value
            End Set
        End Property
        Public Property AdjustedYearlyDemandForecast() As Decimal
            Get
                Return _adjustedYearlyDemandForecast
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _adjustedYearlyDemandForecast Then Me.AddAuditField("AdjustedYearlyDemandForecast", value)
                _adjustedYearlyDemandForecast = value
            End Set
        End Property
        Public Property AdjustedUnitStoreMonth() As Decimal
            Get
                Return _adjustedUnitStoreMonth
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _adjustedUnitStoreMonth Then Me.AddAuditField("AdjustedUnitStoreMonth", value)
                _adjustedUnitStoreMonth = value
            End Set
        End Property
        Public Property AnnualRegRetailSales() As Decimal
            Get
                Return _annualRegRetailSales
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _annualRegRetailSales Then Me.AddAuditField("AnnualRegRetailSales", value)
                _annualRegRetailSales = value
            End Set
        End Property
        Public Property Facings() As Decimal
            Get
                Return _facings
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _facings Then Me.AddAuditField("Facings", value)
                _facings = value
            End Set
        End Property
        Public Property MinPresPerFacing() As Decimal
            Get
                Return _minPresPerFacing
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _minPresPerFacing Then Me.AddAuditField("MinPresPerFacing", value)
                _minPresPerFacing = value
            End Set
        End Property
        Public Property InnerPack() As Decimal
            Get
                Return _innerPack
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _innerPack Then Me.AddAuditField("InnerPack", value)
                _innerPack = value
            End Set
        End Property

        Public Property Retail9() As Decimal
            Get
                Return _retail9
            End Get
            Set(ByVal value As Decimal)
                _retail9 = value
            End Set
        End Property
        Public Property Retail10() As Decimal
            Get
                Return _retail10
            End Get
            Set(ByVal value As Decimal)
                _retail10 = value
            End Set
        End Property
        Public Property Retail11() As Decimal
            Get
                Return _retail11
            End Get
            Set(ByVal value As Decimal)
                _retail11 = value
            End Set
        End Property
        Public Property Retail12() As Decimal
            Get
                Return _retail12
            End Get
            Set(ByVal value As Decimal)
                _retail12 = value
            End Set
        End Property
        Public Property Retail13() As Decimal
            Get
                Return _retail13
            End Get
            Set(ByVal value As Decimal)
                _retail13 = value
            End Set
        End Property
        Public Property RDQuebec() As Decimal
            Get
                Return _RDQuebec
            End Get
            Set(ByVal value As Decimal)
                _RDQuebec = value
            End Set
        End Property
        Public Property RDPuertoRico() As Decimal
            Get
                Return _RDPuertoRico
            End Get
            Set(ByVal value As Decimal)
                _RDPuertoRico = value
            End Set
        End Property

        Public Property PrivateBrandLabel() As String
            Get
                Return _privateBrandLabel
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _privateBrandLabel Then Me.AddAuditField("Private_Brand_Label", value)
                _privateBrandLabel = value
            End Set
        End Property

        Public Property QtyInPack() As Integer
            Get
                Return _qtyInPack
            End Get
            Set(ByVal value As Integer)
                If  _trackChanges AndAlso value <> _qtyInPack Then _costFieldsChanged = True
                If Me.SaveAudit AndAlso value <> _qtyInPack Then Me.AddAuditField("Qty_In_Pack", value)
                _qtyInPack = value
            End Set
        End Property

        Public Property ValidExistingSKU() As Boolean
            Get
                Return _validExistingSKU
            End Get
            Set(ByVal value As Boolean)
                If Me.SaveAudit AndAlso value <> _validExistingSKU Then Me.AddAuditField("Valid_Existing_SKU", value)
                _validExistingSKU = value
            End Set
        End Property

        Public Property ItemStatus() As String
            Get
                Return _itemStatus
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _itemStatus Then Me.AddAuditField("Item_Status", value)
                _itemStatus = value
            End Set
        End Property

        Public Property QuoteReferenceNumber() As String
            Get
                Return _quoteReferenceNumber
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _quoteReferenceNumber Then Me.AddAuditField("Quote_Reference_Number", value)
                _quoteReferenceNumber = value
            End Set
        End Property

        Public Property PLIEnglish() As String
            Get
                Return _PLIEnglish
            End Get
            Set(ByVal value As String)
                _PLIEnglish = value
            End Set
        End Property
        Public Property PLIFrench() As String
            Get
                Return _PLIFrench
            End Get
            Set(ByVal value As String)
                _PLIFrench = value
            End Set
        End Property
        Public Property PLISpanish() As String
            Get
                Return _PLISpanish
            End Get
            Set(ByVal value As String)
                _PLISpanish = value
            End Set
        End Property
        Public Property CustomsDescription() As String
            Get
                Return _customsDescription
            End Get
            Set(ByVal value As String)
                _customsDescription = value
            End Set
        End Property
        Public Property TIEnglish() As String
            Get
                Return _TIEnglish
            End Get
            Set(ByVal value As String)
                _TIEnglish = value
            End Set
        End Property
        Public Property TIFrench() As String
            Get
                Return _TIFrench
            End Get
            Set(ByVal value As String)
                _TIFrench = value
            End Set
        End Property
        Public Property TISpanish() As String
            Get
                Return _TISpanish
            End Get
            Set(ByVal value As String)
                _TISpanish = value
            End Set
        End Property
        Public Property EnglishShortDescription() As String
            Get
                Return _englishShortDesc
            End Get
            Set(ByVal value As String)
                _englishShortDesc = value
            End Set
        End Property
        Public Property EnglishLongDescription() As String
            Get
                Return _englishLongDesc
            End Get
            Set(ByVal value As String)
                _englishLongDesc = value
            End Set
        End Property
        Public Property FrenchShortDescription() As String
            Get
                Return _frenchShortDesc
            End Get
            Set(ByVal value As String)
                _frenchShortDesc = value
            End Set
        End Property
        Public Property FrenchLongDescription() As String
            Get
                Return _frenchLongDesc
            End Get
            Set(ByVal value As String)
                _frenchLongDesc = value
            End Set
        End Property
        Public Property SpanishShortDescription() As String
            Get
                Return _spanishShortDesc
            End Get
            Set(ByVal value As String)
                _spanishShortDesc = value
            End Set
        End Property
        Public Property SpanishLongDescription() As String
            Get
                Return _spanishLongDesc
            End Get
            Set(ByVal value As String)
                _spanishLongDesc = value
            End Set
        End Property
        Public Property ExemptEndDateFrench() As String
            Get
                Return _exemptEndDateFrench
            End Get
            Set(value As String)
                _exemptEndDateFrench = value
            End Set
        End Property


        Public Property EachHeight() As Decimal
            Get
                Return _EachHeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachHeight Then Me.AddAuditField("EachHeight", value)
                _EachHeight = value
            End Set
        End Property

        Public Property EachWidth() As Decimal
            Get
                Return _EachWidth
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachWidth Then Me.AddAuditField("EachWidth", value)
                _EachWidth = value
            End Set
        End Property

        Public Property EachLength() As Decimal
            Get
                Return _EachLength
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachLength Then Me.AddAuditField("EachLength", value)
                _EachLength = value
            End Set
        End Property

        Public Property EachWeight() As Decimal
            Get
                Return _EachWeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _EachWeight Then Me.AddAuditField("EachWeight", value)
                _EachWeight = value
            End Set
        End Property

        Public Property CubicFeetEach() As Decimal
            Get
                Return _CubicFeetEach
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _CubicFeetEach Then Me.AddAuditField("CubicFeetEach", value)
                _CubicFeetEach = value
            End Set
        End Property


        Public Property CanadaHarmonizedCodeNumber() As String
            Get
                Return _CanadaHarmonizedCodeNumber
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _CanadaHarmonizedCodeNumber Then Me.AddAuditField("CanadaHarmonizedCodeNumber", value)
                _CanadaHarmonizedCodeNumber = value
            End Set
        End Property

        Public Property StockingStrategyCode() As String
            Get
                Return _StockingStrategyCode
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _StockingStrategyCode Then Me.AddAuditField("StockingStrategyCode", value)
                _StockingStrategyCode = value
            End Set
        End Property


        Public Property ReshippableInnerCartonWeight() As Decimal
            Get
                Return _ReshippableInnerCartonWeight
            End Get
            Set(ByVal value As Decimal)
                If Me.SaveAudit AndAlso value <> _ReshippableInnerCartonWeight Then Me.AddAuditField("ReshippableInnerCartonWeight", value)
                _ReshippableInnerCartonWeight = value
            End Set
        End Property

        Public Property SuppTariffPercent() As String
            Get
                Return _SuppTariffPercent
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _SuppTariffPercent Then Me.AddAuditField("SuppTariffPercent", value)
                _SuppTariffPercent = value
            End Set
        End Property

        Public Property SuppTariffAmount() As String
            Get
                Return _SuppTariffAmount
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _SuppTariffAmount Then Me.AddAuditField("SuppTariffAmount", value)
                _SuppTariffAmount = value
            End Set
        End Property

        Public Property MinimumOrderQuantity() As Integer
            Get
                Return _MinimumOrderQuantity
            End Get
            Set(ByVal value As Integer)
                If Me.SaveAudit AndAlso value <> _MinimumOrderQuantity Then Me.AddAuditField("MinimumOrderQuantity", value)
                _MinimumOrderQuantity = value
            End Set
        End Property

        Public Property ProductIdentifiesAsCosmetic() As String
            Get
                Return _ProductIdentifiesAsCosmetic
            End Get
            Set(ByVal value As String)
                If Me.SaveAudit AndAlso value <> _ProductIdentifiesAsCosmetic Then Me.AddAuditField("ProductIdentifiesAsCosmetic", value)
                _ProductIdentifiesAsCosmetic = value
            End Set
        End Property

        Protected Friend Sub SetReadOnlyData( _
            ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updatedUser As String, _
            ByVal imageID As Long, _
            ByVal msdsID As Long)

            _DateCreated = dateCreated
            _CreatedUserID = createdUserID
            _DateLastModified = dateLastModified
            _UpdateUserID = updateUserID
            _CreatedUserName = createdUser
            _UpdatedUserName = updatedUser
            _ImageID = imageID
            _MSDSID = msdsID

        End Sub

        Public Sub SetImageFileID(ByVal imageID As Long)
            _ImageID = imageID
        End Sub
        Public Sub SetMSDSFileID(ByVal msdsID As Long)
            _MSDSID = msdsID
        End Sub

        Protected Friend Sub SetTaxWizard(ByVal taxWizard As Boolean)
            _taxWizard = taxWizard
        End Sub

        Public Function IsPackParent() As Boolean
            Dim str As String = Me.PackItemIndicator
            If str.Length > 2 Then str = str.Substring(0, 2)
            str = str.ToUpper().Replace("-", "")
            If str = "D" Or str = "DP" Or str = "SB" Then
                Return True
            Else
                Return False
            End If

        End Function

        Private _trackChanges As Boolean = False
        Public Sub TrackChanges()
            _trackChanges = True
        End Sub
        Private _costFieldsChanged As Boolean = False
        Public ReadOnly Property CostFieldsChanged() As Boolean
            Get
                Return _costFieldsChanged
            End Get
        End Property
        Private _masterWeightChanged As Boolean = False
        Public ReadOnly Property MasterWeightChanged() As Boolean
            Get
                Return _masterWeightChanged
            End Get
        End Property



    End Class

End Namespace

