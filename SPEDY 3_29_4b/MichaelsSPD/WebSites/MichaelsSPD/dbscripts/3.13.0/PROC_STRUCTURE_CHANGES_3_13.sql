
/****** Object:  StoredProcedure [dbo].[usp_SPD_UpdateNewItemFromIM]    Script Date: 01/22/2018 14:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
-- Update New Item Tables from Item Master
-- This routine updates New Item records from the Item Master data when:
--	: There is a match on SKU and Vendor
--	: The Valid_Existing_SKU = 1
--	: Valid_Existing_SKU_Modified < MIN Item Master Modified (SKU or vendor)
--	: Batch is not in a completed stage

TO DOs: Additional Countries?  POG stuff in IM that is Empty
-- =============================================
*/
ALTER PROCEDURE [dbo].[usp_SPD_UpdateNewItemFromIM]
	@BatchID bigint
	, @ItemID bigint = 0		-- if ItemID is 0 then do all matching items in batch
	, @Force int = 0
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LangRecordsExist as integer
	Declare @RecUpdated int
	DECLARE @BatchType int
	Declare @HeaderID bigint, @VendorNum int, @SKU varchar(10)
	declare @delim varchar(50)
	Set @delim = '<MULTILINEDELIMITER>'
	
	Set @BatchType = -1		-- default if not found
	set @RecUpdated = 0
	
	-- Ensure Batch is good by looking up the batch type with conditions
	Select @BatchType = coalesce(B.Batch_Type_ID,-1)
	FROM SPD_Batch B
		join SPD_Workflow_Stage WS on B.Workflow_Stage_ID = WS.ID
	Where B.ID = @BatchID
		and B.[Enabled] = 1
		and WS.Workflow_ID <> 4	-- not completed

	-- GOOD Batch if @BatchType is > 0
	IF @BatchType = 1	-- Domestic Update on an active Batch 
	BEGIN
		--Print 'Updating Domestic Batch'
		UPDATE Item
			SET
				--[ID]
			  --,[Item_Header_ID]
			  --,[Add_Change]
			  [Pack_Item_Indicator]			= IM.PackItemIndicator
			  --,[Michaels_SKU]
			  ,[Vendor_UPC]					= IM.PrimaryUPC
			  ,[Class_Num]					= IM.ClassNum
			  ,[Sub_Class_Num]				= IM.SubClassNum
			  ,[Vendor_Style_Num]			= IM.VendorStyleNum
			  ,[Item_Desc]					= IM.ItemDesc
			  ,[Hybrid_Type]				= IM.HybridType
			  ,[Hybrid_Source_DC]			= IM.HybridSourceDC
			  --,[Hybrid_Lead_Time]
			  --,[Hybrid_Conversion_Date]
			  ,[Eaches_Master_Case]			= IM.EachesMasterCase
			  ,[Eaches_Inner_Pack]			= IM.EachesInnerPack
			  ,[Pre_Priced]					= IM.PrePriced
			  ,[Pre_Priced_UDA]				= IM.PrePricedUDA
			  ,[US_Cost]					= Case When isNull(H.US_Vendor_Num,-1) > 0 Then IM.ItemCost Else Item.US_Cost End
			  ,[Canada_Cost]				= Case When isNull(H.Canadian_Vendor_Num,-1) > 0 Then IM.ItemCost Else Item.Canada_Cost End
			  ,[Base_Retail]				= IM.Base1Retail
			  ,[Central_Retail]				= IM.Base2Retail
			  ,[Test_Retail]				= IM.TestRetail
			  ,[Alaska_Retail]				= IM.AlaskaRetail
			  ,[Canada_Retail]				= IM.CanadaRetail
			  ,[Zero_Nine_Retail]			= IM.High2Retail
			  ,[California_Retail]			= IM.High3Retail
			  ,[Village_Craft_Retail]		= IM.SmallMarketRetail
			  --,[POG_Setup_Per_Store] NOT UPDATED IN IM
			  --,[POG_Max_Qty]  NOT UPDATED IN IM
			  --,[Projected_Unit_Sales]
			  ,[Inner_Case_Height]			= IM.InnerCaseHeight
			  ,[Inner_Case_Width]			= IM.InnerCaseWidth
			  ,[Inner_Case_Length]			= IM.InnerCaseLength
			  ,[Inner_Case_Weight]			= IM.InnerCaseWeight
			  ,[Inner_Case_Pack_Cube]		= IM.InnerCaseCube
			  ,[Master_Case_Height]			= IM.MasterCaseHeight
			  ,[Master_Case_Width]			= IM.MasterCaseWidth
			  ,[Master_Case_Length]			= IM.MasterCaseLength
			  ,[Master_Case_Weight]			= IM.MasterCaseWeight
			  ,[Master_Case_Pack_Cube]		= IM.MasterCaseCube
			  ,[Country_Of_Origin]			= IM.CountryOfOrigin
			  ,[Country_Of_Origin_Name]		= IM.CountryOfOriginName
			  ,[Tax_UDA]					= IM.TaxUDA
			  ,[Tax_Value_UDA]				= IM.TaxValueUDA
			  ,[Hazardous]					= IM.Hazardous
			  ,[Hazardous_Flammable]		= IM.HazardousFlammable
			  ,[Hazardous_Container_Type]	= IM.HazardousContainerType
			  ,[Hazardous_Container_Size]	= IM.HazardousContainerSize
			  ,[Hazardous_MSDS_UOM]			= IM.HazardousMSDSUOM
			  ,[Hazardous_Manufacturer_Name] = IM.HazardousManufacturerName
			  ,[Hazardous_Manufacturer_City] = IM.HazardousManufacturerCity
			  ,[Hazardous_Manufacturer_State] = IM.HazardousManufacturerState
			  ,[Hazardous_Manufacturer_Phone] = IM.HazardousManufacturerPhone
			  ,[Hazardous_Manufacturer_Country] = IM.HazardousManufacturerCountry
			  --,[Tax_Wizard]
			  --,[Date_Created]
			  --,[Created_User_ID]
			  --,[Date_Last_Modified]
			  --,[Update_User_ID]
			  --,[Is_Valid]
			  --,[Like_Item_SKU]
			  --,[Like_Item_Description]
			  --,[Like_Item_Retail]
			  --,[Like_Item_Regular_Unit]
			  --,[Like_Item_Sales]
			  --,[Facings]
			  --,[POG_Min_Qty]
			  --,[Like_Item_Store_Count]
			  --,[Annual_Regular_Unit_Forecast]
			  --,[Annual_Reg_Retail_Sales]
			  --,[Like_Item_Unit_Store_Month]
			  ,[Retail9]					= IM.High1Retail
			  ,[Retail10]					= IM.Base3Retail
			  ,[Retail11]					= IM.Low1Retail
			  ,[Retail12]					= IM.Low2Retail
			  ,[Retail13]					= IM.ManhattanRetail
			  ,[Private_Brand_Label]		= IM.PrivateBrandLabel 
			  ,[Image_ID]					= IM.ImageID
			  ,[MSDS_ID]					= IM.MSDSID
			  ,[UPC_List]					= dbo.udf_SPD_ItemMaint_GetUPCsAsList(IM.SKU,IM.VendorNumber)
			  --,[Qty_In_Pack]
			  ,[Total_US_Cost]				= Case When isNull(H.US_Vendor_Num,-1) > 0 Then IM.FOBShippingPoint Else Item.[Total_US_Cost] End
			  ,[Total_Canada_Cost]			= Case When isNull(H.Canadian_Vendor_Num,-1) > 0 Then IM.FOBShippingPoint Else Item.[Total_Canada_Cost] End
			  --,[Valid_Existing_SKU]
			  ,[Item_Status]				= IM.ItemStatus
			  ,[Valid_Existing_SKU_Modified] = coalesce(IM.DateLastModified, IM.DateCreated)
			  ,[Stock_Category]				= IM.StockCategory
			  ,[Item_Type_Attribute]		= IM.ItemTypeAttribute
			  ,[Department_Num]				= IM.DepartmentNum
			  ,[Customs_Description]		= IM.CustomsDescription
			  ,[RDQuebec]					= IM.QuebecRetail
			  ,[RDPuertoRico]				= IM.PuertoRicoRetail
			  ,[Harmonized_Code_Number]		= IM.HarmonizedCodeNumber
			  ,[Canada_Harmonized_Code_Number] = IM.CanadaHarmonizedCodeNumber
			  ,[Detail_Invoice_Customs_Desc]    = LEFT(IM.DetailInvoiceCustomsDesc0, 35)
			  ,[Component_Material_Breakdown] = LEFT(IM.ComponentMaterialBreakdown0, 35)
			  ,[Each_Case_Height]			= IM.EachCaseHeight
			  ,[Each_Case_Width]			= IM.EachCaseWidth
			  ,[Each_Case_Length]			= IM.EachCaseLength
			  ,[Each_Case_Weight]			= IM.EachCaseWeight
			  ,[Each_Case_Pack_Cube]		= IM.EachCaseCube
			  ,[Stocking_Strategy_Code]		= IM.STOCKINGSTRATEGYCODE
		FROM [SPD_Items] Item
			Join SPD_Item_Headers H				ON Item.[Item_Header_ID] = H.ID
			Join SPD_Batch B					ON H.Batch_ID = B.ID
			Join vwItemMaintItemDetailBySKU	IM	ON Item.Michaels_SKU = IM.SKU
												and Coalesce(H.US_Vendor_Num, H.Canadian_Vendor_Num, -1) = IM.VendorNumber
		WHERE B.ID = @BatchID
			and ( @ItemID = 0 OR Item.ID = @ItemID )
			and Item.Valid_Existing_SKU = 1
			and ( Item.Valid_Existing_SKU_Modified is NULL OR Item.Valid_Existing_SKU_Modified < coalesce(IM.DateLastModified, IM.DateCreated)
				OR @Force <> 0 )
		Set @RecUpdated = @@Rowcount
		
		Select @HeaderID = H.ID
				, @VendorNum = Coalesce(H.US_Vendor_Num, H.Canadian_Vendor_Num, -1)
				, @SKU = Item.Michaels_SKU
			FROM [SPD_Items] Item 
				Join SPD_Item_Headers H	ON Item.[Item_Header_ID] = H.ID
			WHERE Item.ID = @ItemID
		
		IF @RecUpdated > 0 -- Update any additional UPCs
		BEGIN
			
			IF @VendorNum > 0
			BEGIN
				-- Delete any existing UPC records
				DELETE FROM SPD_Item_Additional_UPC 
				WHERE Item_Header_ID = @HeaderID
					and Item_ID = @ItemID
				
				INSERT SPD_Item_Additional_UPC (
					[Item_Header_ID]
					,[Item_ID]
					,[Sequence]
					,[Additional_UPC]
					,[Date_Created]
					,[Created_User_ID]
					,[Date_Last_Modified]
					,[Update_User_ID]
				)
				SELECT 
					 @HeaderID
					, @ItemID
					, row_number() OVER ( Order By IMUPC.UPC asc) as newSeq 
					, IMUPC.UPC
					, coalesce(IMUPC.Date_Created,getdate())
					, coalesce(IMUPC.Created_User_ID, -3)
					, getdate()
					,-3
				FROM SPD_Item_Master_Vendor_UPCs IMUPC
				Where Michaels_SKU = @SKU
					and IMUPC.Vendor_Number = @VendorNum
					and IMUPC.Primary_Indicator = 0
			END
		END
		
		--Insert/Update Update Multilingual fields (using only BatchID so that the entire Batch's Items are updated in GridView)
		INSERT INTO SPD_Item_Languages (Item_ID, Language_Type_ID, Package_Language_Indicator, Translation_Indicator, Description_Short, Description_Long, Date_Created, Created_User_ID, Date_Last_Modified, Modified_User_ID)
		Select i.ID, siml.Language_Type_ID, '', siml.Translation_Indicator, siml.Description_Short, siml.Description_Long,  coalesce(siml.Date_Created,getdate()), coalesce(siml.Created_User_ID, -3), getdate(), -3
		FROM SPD_Item_Master_Languages as siml
		INNER JOIN SPD_Items as i on i.Michaels_SKU = siml.Michaels_SKU
		INNER JOIN SPD_Item_Headers as h on h.ID = i.Item_Header_ID
		LEFT Join SPD_Item_Languages as sil on sil.Item_ID = i.ID
		WHERE h.Batch_ID = @BatchID AND sil.Item_ID is null
		
		Update SPD_Item_Languages
		Set Translation_Indicator = l.Translation_Indicator, 
			Description_Short = l.Description_Short,
			Description_Long = l.Description_Long
		From SPD_Item_Languages as sil
		INNER JOIN SPD_Items as i on i.ID = sil.Item_ID
		INNER JOIN SPD_Item_Headers as h on h.ID = i.Item_Header_ID
		INNER JOIN SPD_Item_Master_Languages as l on sil.Language_Type_ID = l.Language_type_ID and i.Michaels_SKU = l.Michaels_SKU
		WHERE h.Batch_ID = @BatchID

		Update SPD_Item_Languages
		Set Package_Language_Indicator = l.Package_Language_Indicator, Exempt_End_Date = l.Exempt_End_Date
		From SPD_Item_Languages as sil
		INNER JOIN SPD_Items as i on i.ID = sil.Item_ID
		INNER JOIN SPD_Item_Headers as h on h.ID = i.Item_Header_ID
		INNER JOIN SPD_Item_Master_Languages_Supplier as l on sil.Language_Type_ID = l.Language_type_ID and i.Michaels_SKU = l.Michaels_SKU and Vendor_Number = Coalesce(H.US_Vendor_Num, H.Canadian_Vendor_Num,0)
		WHERE h.Batch_ID = @BatchID		
		
	END	-- Domestic Item Update
	
	IF @BatchType = 2 -- Import Update
	BEGIN

		--Print 'Updating Import Batch'
		UPDATE II
		SET
			--[ID]
			--,[Batch_ID]
			--,[DateCreated]
			--,[DateLastModified]
			--,[CreatedUserID]
			--,[UpdateUserID]
			--,[DateSubmitted]
			[Vendor]							= case when IM.VendorOrAgent ='V' THEN 'YES' ELSE NULL end
			,[Agent]							= case when IM.VendorOrAgent ='A' THEN 'YES' ELSE NULL end
			,[AgentType]						= IM.AgentType
			,[Buyer]							= IM.Buyer
			,[Fax]								= IM.BuyerFax
			--,[EnteredBy]
			--,[QuoteSheetStatus]
			,[Season]							= IM.Season
			,[SKUGroup]							= IM.SKUGroup
			,[Email]							= IM.BuyerEmail
			--,[EnteredDate]
			,[Dept]								= IM.DepartmentNum
			,[Class]							= IM.ClassNum
			,[SubClass]							= IM.SubClassNum
			,[PrimaryUPC]						= IM.PrimaryUPC
			,[MichaelsSKU]						= IM.SKU
			--,[GenerateMichaelsUPC]
			--,[AdditionalUPC1]
			--,[AdditionalUPC2]
			--,[AdditionalUPC3]
			--,[AdditionalUPC4]
			--,[AdditionalUPC5]
			--,[AdditionalUPC6]
			--,[AdditionalUPC7]
			--,[AdditionalUPC8]
			--,[PackSKU]							= IM.
			,[PlanogramName]					= IM.PlanogramName
			,[VendorNumber]						= IM.VendorNumber
			,[VendorRank]						= case when IM.PrimaryVendor = 1 then 'PRIMARY' when IM.PrimaryVendor = 0 then 'SECONDARY' else NULL END
			--,[ItemTask]
			,[Description]						= IM.ItemDesc
			,[PaymentTerms]						= IM.PaymentTerms
			,[Days]								= IM.Days
			,[VendorMinOrderAmount]				= IM.VendorMinOrderAmount
			,[VendorName]						= IM.VendorName
			,[VendorAddress1]					= IM.VendorAddress1
			,[VendorAddress2]					= IM.VendorAddress2
			,[VendorAddress3]					= IM.VendorAddress3
			,[VendorAddress4]					= IM.VendorAddress4
			,[VendorContactName]				= IM.VendorContactName
			,[VendorContactPhone]				= IM.VendorContactPhone
			,[VendorContactEmail]				= IM.VendorContactEmail
			,[VendorContactFax]					= IM.VendorContactFax
			,[ManufactureName]					= IM.ManufactureName
			,[ManufactureAddress1]				= IM.ManufactureAddress1
			,[ManufactureAddress2]				= IM.ManufactureAddress2
			,[ManufactureContact]				= IM.ManufactureContact
			,[ManufacturePhone]					= IM.ManufacturePhone
			,[ManufactureEmail]					= IM.ManufactureEmail
			,[ManufactureFax]					= IM.ManufactureFax
			,[AgentContact]						= IM.AgentContact
			,[AgentPhone]						= IM.AgentPhone
			,[AgentEmail]						= IM.AgentEmail
			,[AgentFax]							= IM.AgentFax
			,[VendorStyleNumber]				= IM.VendorStyleNum
			,[HarmonizedCodeNumber]				= IM.HarmonizedCodeNumber
			,[DetailInvoiceCustomsDesc]			= coalesce(IM.DetailInvoiceCustomsDesc0,'') 
													+ @delim + coalesce(IM.DetailInvoiceCustomsDesc1,'') 
													+ @delim + coalesce(IM.DetailInvoiceCustomsDesc2,'') 
													+ @delim + coalesce(IM.DetailInvoiceCustomsDesc3,'') 
													+ @delim + coalesce(IM.DetailInvoiceCustomsDesc4,'') 
													+ @delim + coalesce(IM.DetailInvoiceCustomsDesc5,'')
			,[ComponentMaterialBreakdown]		= coalesce(IM.ComponentMaterialBreakdown0,'') 
													+ @delim + coalesce(IM.ComponentMaterialBreakdown1,'') 
													+ @delim + coalesce(IM.ComponentMaterialBreakdown2,'') 
													+ @delim + coalesce(IM.ComponentMaterialBreakdown3,'') 
													+ @delim + coalesce(IM.ComponentMaterialBreakdown4,'')
			,[ComponentConstructionMethod]		= coalesce(IM.ComponentConstructionMethod0,'') 
													+ @delim + coalesce(IM.ComponentConstructionMethod1,'') 
													+ @delim + coalesce(IM.ComponentConstructionMethod2,'') 
													+ @delim + coalesce(IM.ComponentConstructionMethod3,'')
			,[IndividualItemPackaging]			= IM.IndividualItemPackaging
			,[EachInsideMasterCaseBox]			= IM.EachesMasterCase
			,[EachInsideInnerPack]				= IM.EachesInnerPack
			--,[EachPieceNetWeightLbsPerOunce]	= IM.InnerCaseWeight
			,[ReshippableInnerCartonWeight]		= IM.InnerCaseWeight
			,[ReshippableInnerCartonLength]		= IM.InnerCaseLength
			,[ReshippableInnerCartonWidth]		= IM.InnerCaseWidth
			,[ReshippableInnerCartonHeight]		= IM.InnerCaseHeight
			,[MasterCartonDimensionsLength]		= IM.MasterCaseLength
			,[MasterCartonDimensionsWidth]		= IM.MasterCaseWidth
			,[MasterCartonDimensionsHeight]		= IM.MasterCaseHeight
			,[CubicFeetPerMasterCarton]			= IM.MasterCaseCube
			,[WeightMasterCarton]				= IM.MasterCaseWeight
			,[CubicFeetPerInnerCarton]			= IM.InnerCaseCube
			,[FOBShippingPoint]					= IM.FOBShippingPoint
			,[DutyPercent]						= IM.DutyPercent
			,[DutyAmount]						= IM.DutyAmount
			,[AdditionalDutyComment]			= IM.AdditionalDutyComment
			,[AdditionalDutyAmount]				= IM.AdditionalDutyAmount
			,[OceanFreightAmount]				= IM.OceanFreightAmount
			,[OceanFreightComputedAmount]		= IM.OceanFreightComputedAmount
			,[AgentCommissionPercent]			= IM.AgentCommissionPercent
			,[AgentCommissionAmount]			= IM.AgentCommissionAmount
			,[OtherImportCostsPercent]			= IM.OtherImportCostsPercent
			,[OtherImportCostsAmount]			= IM.OtherImportCostsAmount
			,[PackagingCostAmount]				= IM.PackagingCostAmount
			,[TotalImportBurden]				= IM.ImportBurden
			,[WarehouseLandedCost]				= IM.WarehouseLandedCost
			,[PurchaseOrderIssuedTo]			= IM.PurchaseOrderIssuedTo
			,[ShippingPoint]					= IM.ShippingPoint
			,[CountryOfOrigin]					= IM.CountryOfOrigin
			,[CountryOfOriginName]				= IM.CountryOfOriginName
			,[VendorComments]					= IM.VendorComments
			,[StockCategory]					= IM.StockCategory
			,[FreightTerms]						= IM.FreightTerms
			,[ItemType]							= IM.ItemType
			,[PackItemIndicator]				= IM.PackItemIndicator
			,[ItemTypeAttribute]				= IM.ItemTypeAttribute
			,[AllowStoreOrder]					= IM.AllowStoreOrder
			,[InventoryControl]					= IM.InventoryControl
			,[AutoReplenish]					= IM.AutoReplenish
			,[PrePriced]						= IM.PrePriced
			,[TaxUDA]							= IM.TaxUDA
			,[PrePricedUDA]						= IM.PrePricedUDA
			,[TaxValueUDA]						= IM.TaxValueUDA
			,[HybridType]						= IM.HybridType
			,[SourcingDC]						= IM.HybridSourceDC
			--,[LeadTime]						= IM.
			--,[ConversionDate]					= IM.
			,[StoreSuppZoneGRP]					= IM.StoreSupplierZoneGroup
			,[WhseSuppZoneGRP]					= IM.WHSSupplierZoneGroup
			--,[POGMaxQty]						= IM.POGMaxQty
			--,[POGSetupPerStore]				= IM.POGSetupPerStore
			--,[ProjSalesPerStorePerMonth]		= IM.ProjectedUnitSales
			,[OutboundFreight]					= IM.OutboundFreight
			,[NinePercentWhseCharge]			= IM.NinePercentWhseCharge
			,[TotalStoreLandedCost]				= IM.TotalStoreLandedCost
			,[RDBase]							= IM.Base1Retail
			,[RDCentral]						= IM.Base2Retail
			,[RDTest]							= IM.TestRetail
			,[RDAlaska]							= IM.AlaskaRetail
			,[RDCanada]							= IM.CanadaRetail
			,[RD0Thru9]							= IM.High2Retail
			,[RDCalifornia]						= IM.High3Retail
			,[RDVillageCraft]					= IM.SmallMarketRetail
			,[HazMatYes]						= CASE When IM.Hazardous = 'Y' Then 'X' Else NULL END
			,[HazMatNo]							= CASE When IM.Hazardous = 'N' Then 'X' Else NULL END
			,[HazMatMFGCountry]					= IM.HazardousManufacturerCountry
			,[HazMatMFGName]					= IM.HazardousManufacturerName
			,[HazMatMFGFlammable]				= IM.HazardousFlammable
			,[HazMatMFGCity]					= IM.HazardousManufacturerCity
			,[HazMatContainerType]				= IM.HazardousContainerType
			,[HazMatMFGState]					= IM.HazardousManufacturerState
			,[HazMatContainerSize]				= IM.HazardousContainerSize
			,[HazMatMFGPhone]					= IM.HazardousManufacturerPhone
			,[HazMatMSDSUOM]					= IM.HazardousMSDSUOM
			,[TSSA]								= IM.TSSA
			,[CSA]								= IM.CSA
			,[UL]								= IM.UL
			,[LicenceAgreement]					= IM.LicenceAgreement
			,[FumigationCertificate]			= IM.FumigationCertificate
			,[KILNDriedCertificate]				= IM.KILNDriedCertificate
			,[ChinaComInspecNumAndCCIBStickers]	= IM.ChinaComInspecNumAndCCIBStickers
			,[OriginalVisa]						= IM.OriginalVisa
			,[TextileDeclarationMidCode]		= IM.TextileDeclarationMidCode
			,[QuotaChargeStatement]				= IM.QuotaChargeStatement
			,[MSDS]								= IM.MSDS
			,[TSCA]								= IM.TSCA
			,[DropBallTestCert]					= IM.DropBallTestCert
			,[ManMedicalDeviceListing]			= IM.ManMedicalDeviceListing
			,[ManFDARegistration]				= IM.ManFDARegistration
			,[CopyRightIndemnification]			= IM.CopyRightIndemnification
			,[FishWildLifeCert]					= IM.FishWildLifeCert
			,[Proposition65LabelReq]			= IM.Proposition65LabelReq
			,[CCCR]								= IM.CCCR
			,[FormaldehydeCompliant]			= IM.FormaldehydeCompliant
			--,[Is_Valid]						= IM.
			--,[Tax_Wizard]						= IM.
			,[RMS_Sellable]						= IM.RMSSellable
			,[RMS_Orderable]					= IM.RMSOrderable
			,[RMS_Inventory]					= IM.RMSInventory
			--,[Parent_ID]						= IM.
			--,[RegularBatchItem]				= IM.
			--,[Sequence]						= IM.
			,[Store_Total]						= IM.StoreTotal
			--,[POG_Start_Date]					= IM.
			--,[POG_Comp_Date]					= IM.
			--,[Like_Item_SKU]					= IM.
			--,[Like_Item_Description]
			--,[Like_Item_Retail]
			--,[Like_Item_Regular_Unit]
			--,[Like_Item_Sales]
			--,[Facings]
			--,[POG_Min_Qty]
			,[Displayer_Cost]					= IM.DisplayerCost
			,[Product_Cost]						= IM.ProductCost
			--,[Calculate_Options]
			--,[Like_Item_Store_Count]
			--,[Like_Item_Unit_Store_Month]
			--,[Annual_Reg_Retail_Sales]
			--,[Annual_Regular_Unit_Forecast]
			--,[Inner_Pack]
			--,[Min_Pres_Per_Facing]
			,[Retail9]							= IM.High1Retail
			,[Retail10]							= IM.Base3Retail
			,[Retail11]							= IM.Low1Retail
			,[Retail12]							= IM.Low2Retail
			,[Retail13]							= IM.ManhattanRetail
			,[Private_Brand_Label]				= IM.PrivateBrandLabel
			,[Image_ID]							= IM.ImageID
			,[MSDS_ID]							= IM.MSDSID
			,[Discountable]						= IM.Discountable
			,[UPC_List]							= dbo.udf_SPD_ItemMaint_GetUPCsAsList(IM.SKU,IM.VendorNumber)
			,[Item_Status]						= IM.ItemStatus
			--,[Qty_In_Pack]
			--,[Valid_Existing_SKU]
			,[Valid_Existing_SKU_Modified]		= coalesce(IM.DateLastModified, IM.DateCreated)
		    ,[Customs_Description]		= IM.CustomsDescription
			,[RDQuebec]					= IM.QuebecRetail
			,[RDPuertoRico]				= IM.PuertoRicoRetail
			,[eachlength]				= IM.EachCaseLength
			,[eachWidth]				= IM.eachCaseWidth
			,[eachHeight]				= IM.eachCaseHeight
			,[cubicfeeteach]			= IM.eachCaseCube
			,[eachweight]				= IM.eachCaseWeight
			,[Stocking_Strategy_Code]	= IM.STOCKINGSTRATEGYCODE
			,[CanadaHarmonizedCodeNumber]	= IM.CanadaHarmonizedCodeNumber
		FROM [SPD_Import_Items] II
			Join SPD_Batch B					ON II.Batch_ID = B.ID
			Join vwItemMaintItemDetailBySKU	IM	ON II.MichaelsSKU = IM.SKU
												and Coalesce(II.VendorNumber, -1) = IM.VendorNumber
		WHERE B.ID = @BatchID
			and ( @ItemID = 0 OR II.ID = @ItemID )
			and II.Valid_Existing_SKU = 1
			and ( II.Valid_Existing_SKU_Modified is NULL OR II.Valid_Existing_SKU_Modified < coalesce(IM.DateLastModified, IM.DateCreated)
				OR @Force <> 0 )			
		Set @RecUpdated = @@Rowcount

		Select 
				 @VendorNum = Coalesce(Item.VendorNumber, -1)
				, @SKU = Item.MichaelsSKU
			FROM [SPD_Import_Items] Item 
			WHERE Item.ID = @ItemID

		IF @RecUpdated > 0 -- Update any additional UPCs
		BEGIN
			
			IF @VendorNum > 0
			BEGIN
				-- Delete any existing UPC records
				DELETE FROM SPD_Import_Item_Additional_UPC
				WHERE Import_Item_ID = @ItemID
				
				INSERT SPD_Import_Item_Additional_UPC (
					Import_Item_ID
					,[Sequence]
					,[Additional_UPC]
					,[Date_Created]
					,[Created_User_ID]
					,[Date_Last_Modified]
					,[Update_User_ID]
				)
				SELECT 
					 @ItemID
					, row_number() OVER ( Order By IMUPC.UPC asc) as newSeq 
					, IMUPC.UPC
					, coalesce(IMUPC.Date_Created,getdate())
					, coalesce(IMUPC.Created_User_ID, -3)
					, getdate()
					,-3
				FROM SPD_Item_Master_Vendor_UPCs IMUPC
				Where Michaels_SKU = @SKU
					and IMUPC.Vendor_Number = @VendorNum
					and IMUPC.Primary_Indicator = 0
			END
		END
		
		--Update Multilingual fields
		Set @LangRecordsExist = 0
		
		Select @LangRecordsExist = count(*) from SPD_Import_Item_Languages as sil
		WHERE sil.Import_Item_ID = @ItemID	

		If(@LangRecordsExist = 0)
		BEGIN
			--Insert Multilingual Records
			INSERT INTO SPD_Import_Item_Languages (Import_Item_ID, Language_Type_ID, Package_Language_Indicator, Translation_Indicator, Description_Short, Description_Long, Date_Created, Created_User_ID, Date_Last_Modified, Modified_User_ID)
			Select @ItemID, Language_Type_ID, '', Translation_Indicator, Description_Short, Description_Long,  coalesce(Date_Created,getdate()), coalesce(Created_User_ID, -3), getdate(), -3
			FROM SPD_Item_Master_Languages
			WHERE Michaels_SKU = @SKU
		END
		
		--Update Multilingual Records
		Update SPD_Import_Item_Languages
		Set Translation_Indicator = l.Translation_Indicator, 
			Description_Short = l.Description_Short,
			Description_Long = l.Description_Long
		From SPD_Import_Item_Languages as sil
		INNER JOIN SPD_Item_Master_Languages as l on sil.Language_Type_ID = l.Language_type_ID AND l.Michaels_SKU = @SKU
		WHERE sil.Import_Item_ID = @ItemID

		Update SPD_Import_Item_Languages
		Set Package_Language_Indicator = l.Package_Language_Indicator, Exempt_End_Date = l.Exempt_End_Date
		From SPD_Import_Item_Languages as sil
		INNER JOIN SPD_Item_Master_Languages_Supplier as l on sil.Language_Type_ID = l.Language_type_ID AND l.Michaels_SKU = @SKU and l.Vendor_Number = @VendorNum
		WHERE sil.Import_Item_ID = @ItemID

	END
	
	if (@Force != 0)
	begin
	  Select @RecUpdated as UpdateCount
	end
	--ELSE
	--	Print convert(varchar(20),@RecUpdated)
END
GO

/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster_BySKU]    Script Date: 01/22/2018 14:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	this is a variation of usp_SPD_MQComm_UpdateItemMaster
	the original works by batchid and is called when a batch completes
	
	this version is intended for use when a SKU is purged and then recreated in SPEDY
*/
ALTER PROCEDURE [dbo].[usp_SPD_MQComm_UpdateItemMaster_BySKU] 
	@RepairSKU varchar(10)
	, @debug int = 0
AS
BEGIN

  if @debug = 0
  begin
    set NOCOUNT on;
  end

	Declare @BatchType int
		, @BatchID bigint
		, @rows int
		, @msg varchar(1000)
		, @vcBatchID varchar(20)
		, @Error bit
		, @CurDate datetime
		
	select @BatchID = b.id from spd_items it, spd_item_headers ith, spd_batch b where it.michaels_sku = @RepairSKU
			and it.item_header_id = ith.id and ith.batch_id = b.id and b.enabled = 1
			
	if @BatchID is null
	begin
		select @BatchID = b.id from spd_import_items it, spd_batch b where it.michaelssku = @RepairSKU
			and b.id = it.batch_id and b.enabled = 1
	end
	
	if @BatchID is null
  begin
    print 'batch not found'
		return
  end
	
	Set @vcBatchID = convert(varchar(20),@BatchID)
	Set @Error = 0
	Set @CurDate = getdate()
	
	Select @BatchType = Batch_Type_ID
	From SPD_Batch 
	Where ID = @BatchID
	
	BEGIN TRAN
	IF @BatchType = 1
	BEGIN
	
		-- ****************************************************************************
		-- From Domestic Update
		-- ****************************************************************************
	
		-- Update SKU Level Info
		Set @msg = 'Updating Item Master SKU from Domestic New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg

		BEGIN TRY
			UPDATE [SPD_Item_Master_SKU]
				SET 
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, Buyer = DH.[Buyer_Approval] 
				,[RMS_Sellable] = DH.[RMS_Sellable]
				,[RMS_Orderable] = DH.[RMS_Orderable]
				,[RMS_Inventory] = DH.[RMS_Inventory]
				,[Store_Total] = DH.[Store_Total]
				,[Item_Type] = DI.[Pack_Item_Indicator]
				, [Pack_Item_Indicator] = Case 
					WHEN dbo.udf_SPD_PackItemLeft2(DI.[Pack_Item_Indicator]) in ('D','DP')
					THEN 'Y' 
					ELSE 'N' end
				,Updated_From_NewItem = 1	-- now just for informational purposes since an item can go through new item more than once
			FROM [SPD_Item_Master_SKU] SKU
				Join SPD_Items DI			on SKU.[Michaels_SKU] = DI.Michaels_SKU
				join SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
				join SPD_Batch B			on DH.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE 	B.ID = @BatchID
				and SKU.Michaels_SKU = @RepairSKU
				and DI.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4	-- ONLY COMPLETED BATCHES PLEASE

			set @rows = @@Rowcount
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
			IF @Debug=1  Print @msg
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master SKU from Domestic... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN
		END CATCH
		
		-- Update UDA Level Data.  This should be an Insert as the data is not returned
		-- Update.  Since a New Item Batch can be done twice
		Set @msg = 'Updating Item Master UDA from Domestic New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg

		BEGIN TRY
			-- **********************************************************************************************
			-- First the Tax info: Update / Insert
			IF @Debug=1  Print 'Domestic Tax UDA'
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_ID = I.Tax_UDA
					, UDA_Value = I.Tax_Value_UDA
			FROM SPD_Items I
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID between 1 and 9 
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.Michaels_SKU = @RepairSKU

			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.Michaels_SKU
				, I.Tax_UDA
				, I.Tax_Value_UDA
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.Michaels_SKU = UDA.Michaels_SKU 
													and UDA.UDA_ID between 1 and 9 
			WHERE 	B.ID = @BatchID
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL
				and I.Michaels_SKU = @RepairSKU
				and not exists (select null from SPD_Item_Master_UDA where Michaels_SKU = I.Michaels_SKU and UDA_ID = I.Tax_UDA and UDA_Value = I.Tax_Value_UDA)
			

			-- **********************************************************************************************
			-- Now the PrePriced: Update, Insert, Delete
			IF @Debug=1  Print 'Domestic PrePriced UDA'
			UPDATE SPD_Item_Master_UDA
				Set UDA_Value = I.Pre_Priced_UDA
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.Pre_Priced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.Michaels_SKU = @RepairSKU
			
			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.Michaels_SKU
				, 10
				, I.Pre_Priced_UDA
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE 	B.ID = @BatchID
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.Pre_Priced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table
				and I.Michaels_SKU = @RepairSKU
				and not exists (select null from SPD_Item_Master_UDA where Michaels_SKU = I.Michaels_SKU and UDA_ID = 10 and UDA_Value = I.Pre_Priced_UDA)
				
			DELETE UDA		-- Most likely this will never fire as New Items that are dups should be from Existing SKUs
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.Pre_Priced ='N'			-- UDA defined in Item as NO	
				and I.Michaels_SKU = @RepairSKU
					
			-- **********************************************************************************************
			-- Now the Private Brand Label: Update and Insert
			IF @Debug=1  Print 'Domestic PBL UDA'
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_Value = coalesce(I.Private_Brand_Label,12)
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.Michaels_SKU = @RepairSKU
							
			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.Michaels_SKU
				, 11
				, coalesce(I.Private_Brand_Label,12)
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE 	B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table
				and I.Michaels_SKU = @RepairSKU
				and not exists (select null from SPD_Item_Master_UDA where Michaels_SKU = I.Michaels_SKU and UDA_ID = 11 and UDA_Value = coalesce(I.Private_Brand_Label,12))
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master UDA from Domestic... Error Occurred in Insert' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN
		END CATCH
		
		-- **********************************************************************************************
		-- Update Vendor Level Info - Use temp table to hold all the skus assoc with the batch
		BEGIN TRY
			set @msg = 'Updating Item Master VENDOR from Domestic New Item. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg

			SELECT
				DI.ID													as Item_ID
				, DI.Item_Header_ID										as Item_Header_ID	  
				, DI.[Michaels_SKU]										as Michaels_SKU
				, coalesce(DH.US_Vendor_Num, DH.Canadian_Vendor_Num,0)	as Vendor_Number
			INTO #DI_SKURecs
			FROM SPD_Items DI
				join SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
				join SPD_Batch B			on DH.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and DI.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and DI.Michaels_SKU = @RepairSKU

			UPDATE SPD_Item_Master_Vendor
				SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				,[Hazardous_Manufacturer_Name] = DI.[Hazardous_Manufacturer_Name]
				,[Hazardous_Manufacturer_City] = DI.[Hazardous_Manufacturer_City]
				,[Hazardous_Manufacturer_State] = DI.[Hazardous_Manufacturer_State]
				,[Hazardous_Manufacturer_Phone] = DI.[Hazardous_Manufacturer_Phone]
				,[Hazardous_Manufacturer_Country] = DI.[Hazardous_Manufacturer_Country]
				, Image_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = DI.ID and [Item_Type] = 'D' and [File_Type] = 'IMG' )
				, MSDS_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = DI.ID and [Item_Type] = 'D' and [File_Type] = 'MSDS' )
				, Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor V
				Join #DI_SKURecs LU			on  V.Michaels_SKU = LU.Michaels_SKU 
												and V.Vendor_Number = LU.Vendor_Number
				Join SPD_Items DI			on LU.Item_ID = DI.ID

			set @rows = @@Rowcount
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
			IF @Debug=1  Print @msg
		END TRY

		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor from Domestic... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN	
		END CATCH
		
		-- Update Vendor Country Level Info
		BEGIN TRY
			set @msg = 'Updating Item Master Vendor Countries from Domestic New Item. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg

			UPDATE SPD_Item_Master_Vendor_Countries
			SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, [Each_Case_Height] = DI.[Each_Case_Height]
				, [Each_Case_Width] = DI.[Each_Case_Width]
				, [Each_Case_Length] = DI.[Each_Case_Length]
				, [Each_Case_Weight] = DI.[Each_Case_Weight]
				, [Each_LWH_UOM] = 'LB'
				, [Each_Weight_UOM] = 'IN'
				, [Inner_Case_Height] = DI.[inner_case_height]
				, [Inner_Case_Width] = DI.[inner_case_width]
				, [Inner_Case_Length] = DI.[inner_case_length]
				, [Inner_Case_Weight] = case when isnumeric(DI.[inner_case_weight])=1 then convert(decimal(18,6),DI.[inner_case_weight]) else 0.00 end
				, [Inner_LWH_UOM] = 'IN'
				, [Inner_Weight_UOM] = 'LB'
				, [Master_Case_Height] = DI.[master_case_height]
				, [Master_Case_Width] = DI.[master_case_width]
				, [Master_Case_Length] = DI.[master_case_length]
				, [Master_Case_Weight] = DI.[master_case_weight]
				, [Master_LWH_UOM] = 'IN'
				, [Master_Weight_UOM] = 'LB'
				, Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor_Countries VC
				Join #DI_SKURecs LU			on  VC.Michaels_SKU = LU.Michaels_SKU 
												and VC.Vendor_Number = LU.Vendor_Number
				Join SPD_Items DI			on LU.Item_ID = DI.ID
												and VC.Country_Of_Origin = DI.[country_of_origin]
		END TRY

		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor Countries from Domestic... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN	
		END CATCH
		
		Drop table #DI_SKURecs
	END
	
	IF @BatchType = 2
	BEGIN
		-- ****************************************************************************
		-- From Import Update
		-- ****************************************************************************
		-- Update SKU Level Info
		Set @msg = 'Updating Item Master SKU from Import New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		BEGIN TRY
			UPDATE [SPD_Item_Master_SKU]
				SET 
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, Planogram_Name = II.PlanogramName
				,[Buyer] = II.[Buyer]
				,[Buyer_Fax] = II.[Fax]
				,[Buyer_Email] = II.[Email]
				,[Season] = II.[Season]
				,[TSSA] = II.TSSA
				,[CSA] = II.CSA
				,[UL] = II.UL
				,[Licence_Agreement] = II.[LicenceAgreement]
				,[Fumigation_Certificate] = II.[FumigationCertificate]
				,[KILN_Dried_Certificate] = II.[KILNDriedCertificate]
				,[China_Com_Inspec_Num_And_CCIB_Stickers] = II.[ChinaComInspecNumAndCCIBStickers]
				,[Original_Visa] = II.[OriginalVisa]
				,[Textile_Declaration_Mid_Code] = II.[TextileDeclarationMidCode]
				,[Quota_Charge_Statement] = II.[QuotaChargeStatement]
				,[MSDS] = II.[MSDS]
				,[TSCA] = II.[TSCA]
				,[Drop_Bal_lTest_Cert] = II.[DropBallTestCert]
				,[Man_Medical_Device_Listing] = II.[ManMedicalDeviceListing]
				,[Man_FDA_Registration] = II.[ManFDARegistration]
				,[Copy_Right_Indemnification] = II.[CopyRightIndemnification]
				,[Fish_Wild_Life_Cert] = II.[FishWildLifeCert]
				,[Proposition_65_Label_Req] = II.[Proposition65LabelReq]
				,[CCCR] = II.[CCCR]
				,[Formaldehyde_Compliant] = II.[FormaldehydeCompliant]
				,[RMS_Sellable] = II.[RMS_Sellable]
				,[RMS_Orderable] = II.[RMS_Orderable]
				,[RMS_Inventory] = II.[RMS_Inventory]
				,[Store_Total] = II.[Store_Total]
				,[Displayer_Cost] = II.[Displayer_Cost]
				,[Item_Type] = II.[PackItemIndicator]
				,[Pack_Item_Indicator] = Case WHEN dbo.udf_SPD_PackItemLeft2(II.[PackItemIndicator]) in ('D','DP')
												THEN 'Y' ELSE 'N' end
				, Updated_From_NewItem = 1
			FROM [SPD_Item_Master_SKU] SKU
				Join SPD_Import_Items II	on SKU.[Michaels_SKU] = II.MichaelsSKU
				join SPD_Batch B			on II.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and isnull(II.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and SKU.Michaels_SKU = @RepairSKU

			set @rows = @@Rowcount
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
			IF @Debug=1  Print @msg
		END TRY

		BEGIN CATCH
			set @msg = 'Updating Item Master SKU from Import... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN	
		END CATCH

		-- Update UDA Level Data.  This should be an Insert as the data is not returned
		Set @msg = 'Updating Item Master UDA from Import New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		
		BEGIN TRY
			-- ***************************************************************************
			-- First the Tax info: Update / Insert
			IF @Debug=1  Print 'Import Tax UDA'
			
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_ID = I.TaxUDA
					, UDA_Value = I.TaxValueUDA
			From SPD_Import_Items I
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID between 1 and 9 
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.MichaelsSKU = @RepairSKU

			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.MichaelsSKU
				, I.TaxUDA
				, I.TaxValueUDA
			From SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.MichaelsSKU = UDA.Michaels_SKU 
													and UDA.UDA_ID between 1 and 9 
			WHERE 	B.ID = @BatchID
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL
				and I.MichaelsSKU = @RepairSKU
				and not exists (select null from SPD_Item_Master_UDA where Michaels_SKU = I.MichaelsSKU and UDA_ID = I.TaxUDA and UDA_Value = I.TaxValueUDA)

			-- ***************************************************************************
			-- Now the PrePriced: Update, Insert, Delete
			IF @Debug=1  Print 'Import PrePriced UDA'
			UPDATE SPD_Item_Master_UDA
				Set UDA_Value = I.PrePricedUDA
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.PrePriced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.MichaelsSKU = @RepairSKU
																		
			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.MichaelsSKU
				, 10
				, I.PrePricedUDA
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE 	B.ID = @BatchID
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.PrePriced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table
				and I.MichaelsSKU = @RepairSKU
				and not exists (select null from SPD_Item_Master_UDA where Michaels_SKU = I.MichaelsSKU and UDA_ID = 10 and UDA_Value = I.PrePricedUDA)

			DELETE UDA		-- Most likely this will never fire as New Items that are dups should be from Existing SKUs
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.PrePriced ='N'			-- UDA defined in Item as NO	
				and I.MichaelsSKU = @RepairSKU
							
			-- ***************************************************************************
			-- Now the Private Brand Label: Update and Insert
			IF @Debug=1  Print 'Import PBL UDA'
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_Value = coalesce(I.Private_Brand_Label,12)
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.MichaelsSKU = @RepairSKU

			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.MichaelsSKU
				, 11
				, coalesce(I.Private_Brand_Label,12)
			From SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE 	B.ID = @BatchID
				and isnull(I.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table
				and I.MichaelsSKU = @RepairSKU
				and not exists (select null from SPD_Item_Master_UDA where Michaels_SKU = I.MichaelsSKU and UDA_ID = 11 and UDA_Value = coalesce(I.Private_Brand_Label,12))
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master UDA from Import... Error Occurred in Insert' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN
		END CATCH
		
		-- ***************************************************************************
		-- Update Vendor Level Info
		Set @msg = 'Updating Item Master Vendor from Import New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		BEGIN TRY
			UPDATE SPD_Item_Master_Vendor
				SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, Hazardous_Manufacturer_Name = II.HazMatMFGName
				, Hazardous_Manufacturer_City = II.HazMatMFGCity
				, Hazardous_Manufacturer_State = II.HazMatMFGState
				, Hazardous_Manufacturer_Phone = II.HazMatMFGPhone
				, Hazardous_Manufacturer_Country = II.HazMatMFGCountry
				, Image_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = II.ID and [Item_Type] = 'I' and [File_Type] = 'IMG' )
				, MSDS_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = II.ID and [Item_Type] = 'I' and [File_Type] = 'MSDS' )
				,[PaymentTerms] = II.[PaymentTerms]
				,[Days] = II.[Days]
				,[Vendor_Min_Order_Amount] = case when isNumeric(II.[VendorMinOrderAmount]) = 1 then II.[VendorMinOrderAmount] else NULL END
				,[Vendor_Name] = II.[VendorName]
				,[Vendor_Address1] = II.[VendorAddress1]
				,[Vendor_Address2] = II.[VendorAddress2]
				,[Vendor_Address3] = II.[VendorAddress3]
				,[Vendor_Address4] = II.[VendorAddress4]
				,[Vendor_Contact_Name] = II.[VendorContactName]
				,[Vendor_Contact_Phone] = II.[VendorContactPhone]
				,[Vendor_Contact_Email] = II.[VendorContactEmail]
				,[Vendor_Contact_Fax] = II.[VendorContactFax]
				,[Manufacture_Name] = II.[ManufactureName]
				,[Manufacture_Address1] = II.[ManufactureAddress1]
				,[Manufacture_Address2] = II.[ManufactureAddress2]
				,[Manufacture_Contact] = II.[ManufactureContact]
				,[Manufacture_Phone] = II.[ManufacturePhone]
				,[Manufacture_Email] = II.[ManufactureEmail]
				,[Manufacture_Fax] = II.[ManufactureFax]
				,[Agent_Contact] = II.[AgentContact]
				,[Agent_Phone] = II.[AgentPhone]
				,[Agent_Email] = II.[AgentEmail]
				,[Agent_Fax] = II.[AgentFax]
				,[Harmonized_CodeNumber] = II.[HarmonizedCodeNumber]
				,[Detail_Invoice_Customs_Desc] = II.[DetailInvoiceCustomsDesc]
				,[Component_Material_Breakdown] = II.[ComponentMaterialBreakdown]
				,[Component_Construction_Method] = II.[ComponentConstructionMethod]
				,[Individual_Item_Packaging] = II.[IndividualItemPackaging]
				,[FOB_Shipping_Point] =  case when isNumeric(II.[FOBShippingPoint]) = 1 then II.[FOBShippingPoint] else NULL END
				,[Duty_Percent] = case when isNumeric(II.[DutyPercent]) = 1 then II.[DutyPercent] else NULL END
				,[Duty_Amount] = case when isNumeric(II.[DutyAmount]) = 1 then II.[DutyAmount] else NULL END
				,[Additional_Duty_Comment] = II.[AdditionalDutyComment]
				,[Additional_Duty_Amount] = case when isNumeric(II.[AdditionalDutyAmount]) = 1 and II.[AdditionalDutyAmount] not like '-79228%' then II.[AdditionalDutyAmount] else NULL END
				,[Ocean_Freight_Amount] = case when isNumeric(II.[OceanFreightAmount]) = 1 then II.[OceanFreightAmount] else NULL END
				,[Ocean_Freight_Computed_Amount] = case when isNumeric(II.[OceanFreightComputedAmount]) = 1 then II.[OceanFreightComputedAmount] else NULL END
				,[Agent_Commission_Percent] = case when isNumeric(II.[AgentCommissionPercent]) = 1 then II.[AgentCommissionPercent] else NULL END
				,[Agent_Commission_Amount] = case when isNumeric(II.[AgentCommissionAmount]) = 1 then II.[AgentCommissionAmount] else NULL END
				,[Other_Import_Costs_Percent] = case when isNumeric(II.[OtherImportCostsPercent]) = 1 then II.[OtherImportCostsPercent] else NULL END
				,[Other_Import_Costs_Amount] = case when isNumeric(II.[OtherImportCostsAmount]) = 1 then II.[OtherImportCostsAmount] else NULL END
				,[Packaging_Cost_Amount] = case when isNumeric(II.[PackagingCostAmount]) = 1 then II.[PackagingCostAmount] else NULL END
				,[Warehouse_Landed_Cost] = case when isNumeric(II.[WarehouseLandedCost]) = 1 then II.[WarehouseLandedCost] else NULL END
				,[Purchase_Order_Issued_To] = II.[PurchaseOrderIssuedTo]
				,[Shipping_Point] = Upper(II.[ShippingPoint])
				,[Vendor_Comments] = II.[VendorComments]
				,[Freight_Terms] = II.[FreightTerms]
				,[Outbound_Freight] = case when isNumeric(II.[OutboundFreight]) = 1 then II.[OutboundFreight] else NULL END
				,[Nine_Percent_Whse_Charge] = case when isNumeric(II.[NinePercentWhseCharge]) = 1 then II.[NinePercentWhseCharge] else NULL END
				,[Total_Store_Landed_Cost] = case when isNumeric(II.[TotalStoreLandedCost]) = 1 then II.[TotalStoreLandedCost] else NULL END
				,Vendor_Or_Agent = Case when A.Vendor_Number is NULL then 'V' else 'A' end
				,Agent_Type = Case when A.Vendor_Number is NULL then NULL else A.Agent end			
				,Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor V
				Join SPD_Import_Items II	on V.[Michaels_SKU] = II.MichaelsSKU
											and V.Vendor_Number = II.VendorNumber
				join SPD_Batch B			on II.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				left join SPD_Item_Master_Vendor_Agent A on V.Vendor_Number =  A.Vendor_Number
			WHERE B.ID = @BatchID
				and isnull(II.Valid_Existing_SKU,0) = 0		-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4			-- ONLY COMPLETED BATCHES PLEASE
				and II.MichaelsSKU = @RepairSKU

			set @rows = @@Rowcount
			IF @Debug=1  Print 'Records Updated'
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
		END TRY
		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor from Import... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN		
		END CATCH

		-- Update Vendor Country Level Info
		BEGIN TRY
			set @msg = 'Updating Item Master Vendor Countries from Import New Item. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg

			UPDATE SPD_Item_Master_Vendor_Countries
			SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, [Each_Case_Height] = II.[eachheight]
				, [Each_Case_Width] = II.[eachwidth]
				, [Each_Case_Length] = II.[eachlength]
				, [Each_Case_Weight] = II.[eachweight]
				, [Each_LWH_UOM] = 'LB'
				, [Each_Weight_UOM] = 'IN'
				, [Each_Case_Cube] = II.[cubicfeeteach]
				, [Inner_Case_Height] = II.[reshippableinnercartonheight]
				, [Inner_Case_Width] = II.[reshippableinnercartonwidth]
				, [Inner_Case_Length] = II.[reshippableinnercartonlength]
				--, [Inner_Case_Weight] = case when isnumeric(II.[eachpiecenetweightlbsperounce])=1 then convert(decimal(18,6),II.[eachpiecenetweightlbsperounce]) else 0.00 end
				, [Inner_Case_Weight] = case when isnumeric(II.[ReshippableInnerCartonWeight])=1 then convert(decimal(18,6),II.[ReshippableInnerCartonWeight]) else 0.00 end
				, [Inner_LWH_UOM] = 'IN'
				, [Inner_Weight_UOM] = 'LB'
				, [Master_Case_Height] = II.[mastercartondimensionsheight]
				, [Master_Case_Width] = II.[mastercartondimensionswidth]
				, [Master_Case_Length] = II.[mastercartondimensionslength]
				, [Master_Case_Weight] = II.[weightmastercarton]
				, [Master_LWH_UOM] = 'IN'
				, [Master_Weight_UOM] = 'LB'
				, Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor_Countries VC
				Join SPD_Import_Items II	on VC.[Michaels_SKU] = II.MichaelsSKU
												and VC.Vendor_Number = II.VendorNumber
												and VC.Country_Of_Origin = II.[CountryOfOrigin]
				join SPD_Batch B			on II.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and isnull(II.Valid_Existing_SKU,0) = 0		-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4					-- ONLY COMPLETED BATCHES PLEASE
				and II.MichaelsSKU = @RepairSKU
		END TRY

		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor Countries from Import... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			RETURN	
		END CATCH
		
		/* ******************************************************************************************************************* */
		-- Update Vendor Multiline info for above records where its the Updated_From_NewItem is at 1
		/* ******************************************************************************************************************* */
		BEGIN TRY
			declare @desc varchar(max), @SKU varchar(30), @VendorNo bigint, @break varchar(max), @method varchar(max)
			declare @r0 varchar(1000), @r1 varchar(1000), @r2 varchar(1000), @r3 varchar(1000), @r4 varchar(1000), @r5 varchar(1000)
			declare @t1 table  (ElementID int, Element varchar(max) )
			declare @c1 int, @c2 int, @c3 int
			select @c1= 0, @c2=0, @c3=0

			DECLARE row CURSOR FOR 
				SELECT 
					V.[Michaels_SKU]
					,V.[Vendor_Number]
					,V.[Detail_Invoice_Customs_Desc]
					,V.[Component_Material_Breakdown]
					,V.[Component_Construction_Method]
				FROM [dbo].[SPD_Item_Master_Vendor] V
					Join SPD_Import_Items II	on V.[Michaels_SKU] = II.MichaelsSKU
													and V.Vendor_Number = II.VendorNumber
													and isnull(II.Valid_Existing_SKU,0) = 0	-- Make sure that Item is new and not loaded initially from the Item Master
					join SPD_Batch B			on II.Batch_ID = B.ID
					join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				WHERE WS.Stage_Type_id = 4	-- ONLY COMPLETED BATCHES PLEASE
					and B.ID = @BatchID
					and (  [Detail_Invoice_Customs_Desc] is not null
						or [Component_Material_Breakdown] is not null
						or [Component_Construction_Method] is not null
						)
					and Updated_From_NewItem = 1	-- Been Update from New Item
					and II.MichaelsSKU = @RepairSKU
					
			OPEN row
			FETCH NEXT FROM row INTO @SKU, @VendorNo, @desc, @break, @method;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				UPDATE [SPD_Item_Master_Vendor]
					SET Updated_From_NewItem = 2	-- Flag that we have updated the multiline fields
				WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					
				IF @desc is not NULL
				BEGIN 
					INSERT @t1
						Select ElementID, Element FROM SPLIT(@desc, '<MULTILINEDELIMITER>')
					
					-- Force the variables to be '' for each pass
					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = Element from @t1 where ElementID = 1
					Select @r1 = Element from @t1 where ElementID = 2
					Select @r2 = Element from @t1 where ElementID = 3
					Select @r3 = Element from @t1 where ElementID = 4
					Select @r4 = Element from @t1 where ElementID = 5
					Select @r5 = Element from @t1 where ElementID = 6

					DELETE FROM @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
						  [Detail_Invoice_Customs_Desc0] = Coalesce(@r0,'')
						, [Detail_Invoice_Customs_Desc1] = Coalesce(@r1,'')
						, [Detail_Invoice_Customs_Desc2] = Coalesce(@r2,'')
						, [Detail_Invoice_Customs_Desc3] = Coalesce(@r3,'')
						, [Detail_Invoice_Customs_Desc4] = Coalesce(@r4,'')
						, [Detail_Invoice_Customs_Desc5] = Coalesce(@r5,'')
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c1 = @c1 + 1	
				END
				
				IF @break is not NULL
				BEGIN
					INSERT @t1
						Select ElementID, Element FROM SPLIT(@break, '<MULTILINEDELIMITER>')

					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = Element from @t1 where ElementID = 1
					Select @r1 = Element from @t1 where ElementID = 2
					Select @r2 = Element from @t1 where ElementID = 3
					Select @r3 = Element from @t1 where ElementID = 4
					Select @r4 = Element from @t1 where ElementID = 5

					DELETE FROM @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
  						  [Component_Material_Breakdown0] = coalesce(@r0,'')
						, [Component_Material_Breakdown1] = coalesce(@r1,'')
						, [Component_Material_Breakdown2] = coalesce(@r2,'')
						, [Component_Material_Breakdown3] = coalesce(@r3,'')
						, [Component_Material_Breakdown4] = coalesce(@r4,'')
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c2 = @c2 + 1	
				END		

				IF @method is not NULL
				BEGIN
					Insert @t1
						Select ElementID, Element FROM SPLIT(@method, '<MULTILINEDELIMITER>')

					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = Element from @t1 where ElementID = 1
					Select @r1 = Element from @t1 where ElementID = 2
					Select @r2 = Element from @t1 where ElementID = 3
					Select @r3 = Element from @t1 where ElementID = 4
					delete from @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
						  [Component_Construction_Method0] = coalesce(@r0,'')
						, [Component_Construction_Method1] = coalesce(@r1,'')
						, [Component_Construction_Method2] = coalesce(@r2,'')
						, [Component_Construction_Method3] = coalesce(@r3,'')
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c3 = @c3 + 1	
				END	
				
				FETCH NEXT FROM row INTO @SKU, @VendorNo, @desc, @break, @method;
			END	
			CLOSE row;
			DEALLOCATE row;
			DELETE FROM @t1

			IF @Debug=1  Print 'MultiLines were Updated'
			set @msg = '   Total Count of Multiline Updates: ' + convert(varchar(20),(@c1 + @c2 + @c3))
		END TRY
		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor MultiLines... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			print @msg
			Rollback Tran
			CLOSE row;
			DEALLOCATE row;
			RETURN	
		END CATCH
	END	
	
	Commit Tran
	IF @Debug=1
  begin
    Print 'Updating Item Master Proc Ends'
  end

  print 'SUCCESS ' + @RepairSKU

END
GO

/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster]    Script Date: 01/22/2018 14:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Author:	Littlefield, Jeff
	Desc:   Update Item Master with SPEDY Only Data
		    This is run after a New Item Batch is completed and the last message has been processed by the Item Maint Process.  
	Changes: FJL - Oct 13, 2010 Add dimension fields to the Update process
			 FJL - OCt 21, 2010 Add UDA fields to the Update Process as they are not returned on a New Item Creation message
			 FJL - OCt 28, 2010 Add logic to ensure records from New Item have not been populated from Item Master (Valid_Existing_SKU = 0)
								Code Updates and with the inserts in case batch is rerun.
*/
ALTER PROCEDURE [dbo].[usp_SPD_MQComm_UpdateItemMaster] 
	@BatchID bigint
	, @LTS datetime = null
	, @debug int
AS
BEGIN

	IF  @LTS is NULL
		SET @LTS = getdate()
		
	Declare @BatchType int
		, @rows int
		, @msg varchar(1000)
		, @vcBatchID varchar(20)
		, @Error bit
		, @CurDate datetime
	
	Set @vcBatchID = convert(varchar(20),@BatchID)
	Set @Error = 0
	Set @CurDate = getdate()
	
	Select @BatchType = Batch_Type_ID
	From SPD_Batch 
	Where ID = @BatchID
	
	BEGIN TRAN
	IF @BatchType = 1
	BEGIN
		-- ****************************************************************************
		-- From Domestic Update
		-- ****************************************************************************
	
		-- Update SKU Level Info
		Set @msg = 'Updating Item Master SKU from Domestic New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
			UPDATE [SPD_Item_Master_SKU]
				SET 
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, Buyer = DH.[Buyer_Approval] 
				,[RMS_Sellable] = DH.[RMS_Sellable]
				,[RMS_Orderable] = DH.[RMS_Orderable]
				,[RMS_Inventory] = DH.[RMS_Inventory]
				,[Store_Total] = DH.[Store_Total]
				,[Item_Type] = DI.[Pack_Item_Indicator]
				,[Customs_Description] = DI.[Customs_Description]
				, [Pack_Item_Indicator] = Case 
					WHEN dbo.udf_SPD_PackItemLeft2(DI.[Pack_Item_Indicator]) in ('D','DP')
					THEN 'Y' 
					ELSE 'N' end
				,Updated_From_NewItem = 1	-- now just for informational purposes since an item can go through new item more than once
			FROM [SPD_Item_Master_SKU] SKU
				Join SPD_Items DI			on SKU.[Michaels_SKU] = DI.Michaels_SKU
				join SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
				join SPD_Batch B			on DH.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE 	B.ID = @BatchID
				and DI.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4	-- ONLY COMPLETED BATCHES PLEASE

			set @rows = @@Rowcount
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master SKU from Domestic... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN
		END CATCH
		
		-- Update UDA Level Data.  This should be an Insert as the data is not returned
		-- Update.  Since a New Item Batch can be done twice
		Set @msg = 'Updating Item Master UDA from Domestic New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			-- **********************************************************************************************
			-- First the Tax info: Update / Insert
			IF @Debug=1  Print 'Domestic Tax UDA'
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_ID = I.Tax_UDA
					, UDA_Value = I.Tax_Value_UDA
			FROM SPD_Items I
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID between 1 and 9 
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE

			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.Michaels_SKU
				, I.Tax_UDA
				, I.Tax_Value_UDA
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.Michaels_SKU = UDA.Michaels_SKU 
													and UDA.UDA_ID between 1 and 9 
			WHERE 	B.ID = @BatchID
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL

			-- **********************************************************************************************
			-- Now the PrePriced: Update, Insert, Delete
			IF @Debug=1  Print 'Domestic PrePriced UDA'
			UPDATE SPD_Item_Master_UDA
				Set UDA_Value = I.Pre_Priced_UDA
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.Pre_Priced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
			
			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.Michaels_SKU
				, 10
				, I.Pre_Priced_UDA
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE 	B.ID = @BatchID
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.Pre_Priced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table
				
			DELETE UDA		-- Most likely this will never fire as New Items that are dups should be from Existing SKUs
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.Pre_Priced ='N'			-- UDA defined in Item as NO	
					
			-- **********************************************************************************************
			-- Now the Private Brand Label: Update and Insert
			IF @Debug=1  Print 'Domestic PBL UDA'
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_Value = coalesce(I.Private_Brand_Label,12)
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
							
			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.Michaels_SKU
				, 11
				, coalesce(I.Private_Brand_Label,12)
			FROM SPD_Items I
				Join SPD_Item_Headers H				on I.Item_Header_ID = H.ID
				Join SPD_Batch B					on H.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.Michaels_SKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE 	B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master UDA from Domestic... Error Occurred in Insert' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN
		END CATCH
		
		-- **********************************************************************************************
		-- Update Vendor Level Info - Use temp table to hold all the skus assoc with the batch
		BEGIN TRY
			set @msg = 'Updating Item Master VENDOR from Domestic New Item. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

			SELECT
				DI.ID													as Item_ID
				, DI.Item_Header_ID										as Item_Header_ID	  
				, DI.[Michaels_SKU]										as Michaels_SKU
				, coalesce(DH.US_Vendor_Num, DH.Canadian_Vendor_Num,0)	as Vendor_Number
			INTO #DI_SKURecs
			FROM SPD_Items DI
				join SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
				join SPD_Batch B			on DH.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and DI.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master

			UPDATE SPD_Item_Master_Vendor
				SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				,[Harmonized_CodeNumber] = DI.[Harmonized_Code_Number]
				,[Canada_Harmonized_CodeNumber] = DI.[Canada_Harmonized_Code_Number]
				,[Detail_Invoice_Customs_Desc0] = DI.[Detail_Invoice_Customs_Desc]
				,[Component_Material_Breakdown0] = DI.[Component_Material_Breakdown]
				,[Hazardous_Manufacturer_Name] = DI.[Hazardous_Manufacturer_Name]
				,[Hazardous_Manufacturer_City] = DI.[Hazardous_Manufacturer_City]
				,[Hazardous_Manufacturer_State] = DI.[Hazardous_Manufacturer_State]
				,[Hazardous_Manufacturer_Phone] = DI.[Hazardous_Manufacturer_Phone]
				,[Hazardous_Manufacturer_Country] = DI.[Hazardous_Manufacturer_Country]
				, Image_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = DI.ID and [Item_Type] = 'D' and [File_Type] = 'IMG' )
				, MSDS_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = DI.ID and [Item_Type] = 'D' and [File_Type] = 'MSDS' )
				, Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor V
				Join #DI_SKURecs LU			on  V.Michaels_SKU = LU.Michaels_SKU 
												and V.Vendor_Number = LU.Vendor_Number
				Join SPD_Items DI			on LU.Item_ID = DI.ID

			set @rows = @@Rowcount
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor from Domestic... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH
		
		-- Update Vendor Country Level Info
		BEGIN TRY
			set @msg = 'Updating Item Master Vendor Countries from Domestic New Item. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

			UPDATE SPD_Item_Master_Vendor_Countries
			SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, [Each_Case_Height] = DI.[Each_Case_Height]
				, [Each_Case_Width] = DI.[Each_Case_Width]
				, [Each_Case_Length] = DI.[Each_Case_Length]
				, [Each_Case_Weight] = DI.[Each_Case_Weight]
				, [Each_LWH_UOM] = 'LB'
				, [Each_Weight_UOM] = 'IN'
				, [Inner_Case_Height] = DI.[inner_case_height]
				, [Inner_Case_Width] = DI.[inner_case_width]
				, [Inner_Case_Length] = DI.[inner_case_length]
				, [Inner_Case_Weight] = DI.[inner_case_weight]
				, [Inner_LWH_UOM] = 'IN'
				, [Inner_Weight_UOM] = 'LB'
				, [Master_Case_Height] = DI.[master_case_height]
				, [Master_Case_Width] = DI.[master_case_width]
				, [Master_Case_Length] = DI.[master_case_length]
				, [Master_Case_Weight] = DI.[master_case_weight]
				, [Master_LWH_UOM] = 'IN'
				, [Master_Weight_UOM] = 'LB'
				, Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor_Countries VC
				Join #DI_SKURecs LU			on  VC.Michaels_SKU = LU.Michaels_SKU 
												and VC.Vendor_Number = LU.Vendor_Number
				Join SPD_Items DI			on LU.Item_ID = DI.ID
												and VC.Country_Of_Origin = DI.[country_of_origin]
		END TRY

		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor Countries from Domestic... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH
		
		Drop table #DI_SKURecs
		
		-- **********************************************************************************************
		-- Update Multilingual Info pt 1
		BEGIN TRY
			set @msg = 'Updating Item Master Languages from Domestic Item Languages Table. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

			-- FIRST, Update the Langauge table, in case the languages already exist.
			-- This should never be the case, but adding the code here in case we need to support it later.
			UPDATE SPD_Item_Master_Languages
			SET Translation_Indicator = SIL.Translation_Indicator,
				Description_Short = SIL.Description_Short,
				Description_Long = SIL.Description_Long,
				Modified_User_ID = 0,
				Date_Requested = getDate(),
				Date_Last_Modified = getDate()
			FROM SPD_Item_Master_Languages as SIML
			INNER JOIN SPD_Items as DI on SIML.Michaels_SKU = DI.Michaels_SKU
			INNER JOIN SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
			INNER JOIN SPD_Item_Languages SIL on DI.ID = SIL.Item_ID and SIML.Language_Type_ID = SIL.Language_Type_ID
			WHERE DH.Batch_ID = @BatchID

			-- INSERT new records into the Langauge table
			INSERT INTO SPD_Item_Master_Languages (Michaels_SKU, Language_Type_ID, Translation_Indicator, Description_Short, Description_Long, Date_Requested, Created_User_ID, Date_Created, Modified_User_ID, Date_Last_Modified)
			Select DI.Michaels_SKU, SIL.Language_Type_ID, SIL.Translation_Indicator, SIL.Description_Short, SIL.Description_Long, GetDate(), 0, GetDate(), 0, GetDate()
			FROM SPD_Items as DI
			INNER JOIN SPD_Item_Headers as DH on DI.Item_Header_ID = DH.ID
			INNER JOIN SPD_Item_Languages as SIL on DI.ID = SIL.Item_ID
			LEFT JOIN SPD_Item_Master_Languages as SIML on SIML.Michaels_SKU = DI.Michaels_SKU AND SIML.Language_Type_ID = SIL.Language_Type_ID
			WHERE SIML.ID is null AND DH.Batch_ID = @BatchID
			
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master Languages from Domestic Item Languages Table pt 1... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH
		
		-- **********************************************************************************************
		-- Update Multilingual Info pt 2
		BEGIN TRY
			set @msg = 'Updating Item Master Languages from Domestic Item Languages Table pt 2. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

			-- FIRST, Update the Langauge table, in case the languages already exist.
			-- This should never be the case, but adding the code here in case we need to support it later.
			UPDATE SPD_Item_Master_Languages_Supplier
			SET Package_Language_Indicator = SIL.Package_Language_Indicator,
				Modified_User_ID = 0,
				Date_Last_Modified = getDate()
			FROM SPD_Item_Master_Languages_Supplier as SIML
			INNER JOIN SPD_Items as DI on SIML.Michaels_SKU = DI.Michaels_SKU
			INNER JOIN SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
			INNER JOIN SPD_Item_Languages SIL on DI.ID = SIL.Item_ID and SIML.Language_Type_ID = SIL.Language_Type_ID AND SIML.Vendor_Number = coalesce(DH.US_Vendor_Num, DH.Canadian_Vendor_Num,0)
			WHERE DH.Batch_ID = @BatchID

			-- INSERT new records into the Langauge table
			INSERT INTO SPD_Item_Master_Languages_Supplier (Michaels_SKU, Vendor_Number, Language_Type_ID, Package_Language_Indicator, Created_User_ID, Date_Created, Modified_User_ID, Date_Last_Modified)
			Select DI.Michaels_SKU, coalesce(DH.US_Vendor_Num, DH.Canadian_Vendor_Num,0), SIL.Language_Type_ID, SIL.Package_Language_Indicator, 0, GetDate(), 0, GetDate()
			FROM SPD_Items as DI
			INNER JOIN SPD_Item_Headers as DH on DI.Item_Header_ID = DH.ID
			INNER JOIN SPD_Item_Languages as SIL on DI.ID = SIL.Item_ID
			LEFT JOIN SPD_Item_Master_Languages_Supplier as SIML on SIML.Michaels_SKU = DI.Michaels_SKU AND SIML.Vendor_Number = coalesce(DH.US_Vendor_Num, DH.Canadian_Vendor_Num,0) AND SIML.Language_Type_ID = SIL.Language_Type_ID
			WHERE SIML.ID is null AND DH.Batch_ID = @BatchID
			
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master Languages from Domestic Item Languages Table pt 2... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH
		
	END
	
	ELSE
	
	BEGIN
		-- ****************************************************************************
		-- From Import Update
		-- ****************************************************************************
		-- Update SKU Level Info
		Set @msg = 'Updating Item Master SKU from Import New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
			UPDATE [SPD_Item_Master_SKU]
				SET 
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, Planogram_Name = II.PlanogramName
				,[Buyer] = II.[Buyer]
				,[Buyer_Fax] = II.[Fax]
				,[Buyer_Email] = II.[Email]
				,[Season] = II.[Season]
				,[TSSA] = II.TSSA
				,[CSA] = II.CSA
				,[UL] = II.UL
				,[Licence_Agreement] = II.[LicenceAgreement]
				,[Fumigation_Certificate] = II.[FumigationCertificate]
				,[KILN_Dried_Certificate] = II.[KILNDriedCertificate]
				,[China_Com_Inspec_Num_And_CCIB_Stickers] = II.[ChinaComInspecNumAndCCIBStickers]
				,[Original_Visa] = II.[OriginalVisa]
				,[Textile_Declaration_Mid_Code] = II.[TextileDeclarationMidCode]
				,[Quota_Charge_Statement] = II.[QuotaChargeStatement]
				,[MSDS] = II.[MSDS]
				,[TSCA] = II.[TSCA]
				,[Drop_Bal_lTest_Cert] = II.[DropBallTestCert]
				,[Man_Medical_Device_Listing] = II.[ManMedicalDeviceListing]
				,[Man_FDA_Registration] = II.[ManFDARegistration]
				,[Copy_Right_Indemnification] = II.[CopyRightIndemnification]
				,[Fish_Wild_Life_Cert] = II.[FishWildLifeCert]
				,[Proposition_65_Label_Req] = II.[Proposition65LabelReq]
				,[CCCR] = II.[CCCR]
				,[Formaldehyde_Compliant] = II.[FormaldehydeCompliant]
				,[RMS_Sellable] = II.[RMS_Sellable]
				,[RMS_Orderable] = II.[RMS_Orderable]
				,[RMS_Inventory] = II.[RMS_Inventory]
				,[Store_Total] = II.[Store_Total]
				,[Displayer_Cost] = II.[Displayer_Cost]
				,Product_Cost = II.Product_Cost
				,[Item_Type] = II.[PackItemIndicator]
				,[Pack_Item_Indicator] = Case WHEN dbo.udf_SPD_PackItemLeft2(II.[PackItemIndicator]) in ('D','DP')
												THEN 'Y' ELSE 'N' end
				,QuoteReferenceNumber = II.QuoteReferenceNumber
				,Customs_Description = II.Customs_Description
				, Updated_From_NewItem = 1
			FROM [SPD_Item_Master_SKU] SKU
				Join SPD_Import_Items II	on SKU.[Michaels_SKU] = II.MichaelsSKU
				join SPD_Batch B			on II.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and II.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master

			set @rows = @@Rowcount
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		END TRY

		BEGIN CATCH
			set @msg = 'Updating Item Master SKU from Import... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH

		-- Update UDA Level Data.  This should be an Insert as the data is not returned
		Set @msg = 'Updating Item Master UDA from Import New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
			-- ***************************************************************************
			-- First the Tax info: Update / Insert
			IF @Debug=1  Print 'Import Tax UDA'
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_ID = I.TaxUDA
					, UDA_Value = I.TaxValueUDA
			From SPD_Import_Items I
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID between 1 and 9 
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE

			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.MichaelsSKU
				, I.TaxUDA
				, I.TaxValueUDA
			From SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.MichaelsSKU = UDA.Michaels_SKU 
													and UDA.UDA_ID between 1 and 9 
			WHERE 	B.ID = @BatchID
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL

			-- ***************************************************************************
			-- Now the PrePriced: Update, Insert, Delete
			IF @Debug=1  Print 'Import PrePriced UDA'
			UPDATE SPD_Item_Master_UDA
				Set UDA_Value = I.PrePricedUDA
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.PrePriced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
																		
			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.MichaelsSKU
				, 10
				, I.PrePricedUDA
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE 	B.ID = @BatchID
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.PrePriced ='Y'			-- UDA defined in Item
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table

			DELETE UDA		-- Most likely this will never fire as New Items that are dups should be from Existing SKUs
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 10
			WHERE B.ID = @BatchID			
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and I.PrePriced ='N'			-- UDA defined in Item as NO	
							
			-- ***************************************************************************
			-- Now the Private Brand Label: Update and Insert
			IF @Debug=1  Print 'Import PBL UDA'
			UPDATE SPD_Item_Master_UDA
				Set 
					UDA_Value = coalesce(I.Private_Brand_Label,12)
			FROM SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Join SPD_Item_Master_UDA UDA		on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE B.ID = @BatchID
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master

			INSERT SPD_Item_Master_UDA ( Michaels_SKU, UDA_ID, UDA_Value )
			Select  
				I.MichaelsSKU
				, 11
				, coalesce(I.Private_Brand_Label,12)
			From SPD_Import_Items I
				Join SPD_Batch B					on I.Batch_ID = B.ID
				join SPD_Workflow_Stage WS			on B.Workflow_Stage_ID = WS.ID
				Left Join SPD_Item_Master_UDA UDA	on I.MichaelsSKU = UDA.Michaels_SKU 
														and UDA.UDA_ID = 11
			WHERE 	B.ID = @BatchID
				and I.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
				and UDA.UDA_ID is NULL			-- Does not exist in UDA Table
		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master UDA from Import... Error Occurred in Insert' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN
		END CATCH
		
		-- ***************************************************************************
		-- Update Vendor Level Info
		Set @msg = 'Updating Item Master Vendor from Import New Item. Batch: ' + @vcBatchID
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
			UPDATE SPD_Item_Master_Vendor
				SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, Hazardous_Manufacturer_Name = II.HazMatMFGName
				, Hazardous_Manufacturer_City = II.HazMatMFGCity
				, Hazardous_Manufacturer_State = II.HazMatMFGState
				, Hazardous_Manufacturer_Phone = II.HazMatMFGPhone
				, Hazardous_Manufacturer_Country = II.HazMatMFGCountry
				, Image_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = II.ID and [Item_Type] = 'I' and [File_Type] = 'IMG' )
				, MSDS_ID = (	Select [File_ID] 
								From [SPD_Items_Files]
								Where item_id = II.ID and [Item_Type] = 'I' and [File_Type] = 'MSDS' )
				,[PaymentTerms] = II.[PaymentTerms]
				,[Days] = II.[Days]
				,[Vendor_Min_Order_Amount] = case when isNumeric(II.[VendorMinOrderAmount]) = 1 then II.[VendorMinOrderAmount] else NULL END
				,[Vendor_Name] = II.[VendorName]
				,[Vendor_Address1] = II.[VendorAddress1]
				,[Vendor_Address2] = II.[VendorAddress2]
				,[Vendor_Address3] = II.[VendorAddress3]
				,[Vendor_Address4] = II.[VendorAddress4]
				,[Vendor_Contact_Name] = II.[VendorContactName]
				,[Vendor_Contact_Phone] = II.[VendorContactPhone]
				,[Vendor_Contact_Email] = II.[VendorContactEmail]
				,[Vendor_Contact_Fax] = II.[VendorContactFax]
				,[Manufacture_Name] = II.[ManufactureName]
				,[Manufacture_Address1] = II.[ManufactureAddress1]
				,[Manufacture_Address2] = II.[ManufactureAddress2]
				,[Manufacture_Contact] = II.[ManufactureContact]
				,[Manufacture_Phone] = II.[ManufacturePhone]
				,[Manufacture_Email] = II.[ManufactureEmail]
				,[Manufacture_Fax] = II.[ManufactureFax]
				,[Agent_Contact] = II.[AgentContact]
				,[Agent_Phone] = II.[AgentPhone]
				,[Agent_Email] = II.[AgentEmail]
				,[Agent_Fax] = II.[AgentFax]
				,[Harmonized_CodeNumber] = II.[HarmonizedCodeNumber]
				,[Detail_Invoice_Customs_Desc] = II.[DetailInvoiceCustomsDesc]
				,[Component_Material_Breakdown] = II.[ComponentMaterialBreakdown]
				,[Component_Construction_Method] = II.[ComponentConstructionMethod]
				,[Individual_Item_Packaging] = II.[IndividualItemPackaging]
				,[FOB_Shipping_Point] =  case when isNumeric(II.[FOBShippingPoint]) = 1 then II.[FOBShippingPoint] else NULL END
				,[Duty_Percent] = case when isNumeric(II.[DutyPercent]) = 1 then II.[DutyPercent] else NULL END
				,[Duty_Amount] = case when isNumeric(II.[DutyAmount]) = 1 then II.[DutyAmount] else NULL END
				,[Additional_Duty_Comment] = II.[AdditionalDutyComment]
				,[Additional_Duty_Amount] = case when isNumeric(II.[AdditionalDutyAmount]) = 1 and II.[AdditionalDutyAmount] not like '-79228%' then II.[AdditionalDutyAmount] else NULL END
				,[Ocean_Freight_Amount] = case when isNumeric(II.[OceanFreightAmount]) = 1 then II.[OceanFreightAmount] else NULL END
				,[Ocean_Freight_Computed_Amount] = case when isNumeric(II.[OceanFreightComputedAmount]) = 1 then II.[OceanFreightComputedAmount] else NULL END
				,[Agent_Commission_Percent] = case when isNumeric(II.[AgentCommissionPercent]) = 1 then II.[AgentCommissionPercent] else NULL END
				,[Agent_Commission_Amount] = case when isNumeric(II.[AgentCommissionAmount]) = 1 then II.[AgentCommissionAmount] else NULL END
				,[Other_Import_Costs_Percent] = case when isNumeric(II.[OtherImportCostsPercent]) = 1 then II.[OtherImportCostsPercent] else NULL END
				,[Other_Import_Costs_Amount] = case when isNumeric(II.[OtherImportCostsAmount]) = 1 then II.[OtherImportCostsAmount] else NULL END
				,[Packaging_Cost_Amount] = case when isNumeric(II.[PackagingCostAmount]) = 1 then II.[PackagingCostAmount] else NULL END
				,[Warehouse_Landed_Cost] = case when isNumeric(II.[WarehouseLandedCost]) = 1 then II.[WarehouseLandedCost] else NULL END
				,[Purchase_Order_Issued_To] = II.[PurchaseOrderIssuedTo]
				,[Shipping_Point] = Upper(II.[ShippingPoint])
				,[Vendor_Comments] = II.[VendorComments]
				,[Freight_Terms] = II.[FreightTerms]
				,[Outbound_Freight] = case when isNumeric(II.[OutboundFreight]) = 1 then II.[OutboundFreight] else NULL END
				,[Nine_Percent_Whse_Charge] = case when isNumeric(II.[NinePercentWhseCharge]) = 1 then II.[NinePercentWhseCharge] else NULL END
				,[Total_Store_Landed_Cost] = case when isNumeric(II.[TotalStoreLandedCost]) = 1 then II.[TotalStoreLandedCost] else NULL END
				,Vendor_Or_Agent = Case when A.Vendor_Number is NULL then 'V' else 'A' end
				,Agent_Type = Case when A.Vendor_Number is NULL then NULL else A.Agent end			
				,Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor V
				Join SPD_Import_Items II	on V.[Michaels_SKU] = II.MichaelsSKU
											and V.Vendor_Number = II.VendorNumber
				join SPD_Batch B			on II.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				left join SPD_Item_Master_Vendor_Agent A on V.Vendor_Number =  A.Vendor_Number
			WHERE B.ID = @BatchID
				and II.Valid_Existing_SKU = 0		-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4			-- ONLY COMPLETED BATCHES PLEASE

			set @rows = @@Rowcount
			IF @Debug=1  Print 'Records Updated'
			set @msg = '    Records Updated: ' + convert(varchar(20),@rows)
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		END TRY
		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor from Import... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN		
		END CATCH

		-- Update Vendor Country Level Info
		BEGIN TRY
			set @msg = 'Updating Item Master Vendor Countries from Import New Item. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

			UPDATE SPD_Item_Master_Vendor_Countries
			SET
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, [Each_Case_Height] = II.[eachheight]
				, [Each_Case_Width] = II.[eachwidth]
				, [Each_Case_Length] = II.[eachlength]
				, [Each_Case_Weight] = II.[eachweight]
				, [Each_LWH_UOM] = 'LB'
				, [Each_Weight_UOM] = 'IN'
				, [Each_Case_Cube] = II.[cubicfeeteach]
				, [Inner_Case_Height] = II.[reshippableinnercartonheight]
				, [Inner_Case_Width] = II.[reshippableinnercartonwidth]
				, [Inner_Case_Length] = II.[reshippableinnercartonlength]
				--, [Inner_Case_Weight] = II.[eachpiecenetweightlbsperounce]
				, [Inner_Case_Weight] = II.ReshippableInnerCartonWeight
				, [Inner_LWH_UOM] = 'IN'
				, [Inner_Weight_UOM] = 'LB'
				, [Master_Case_Height] = II.[mastercartondimensionsheight]
				, [Master_Case_Width] = II.[mastercartondimensionswidth]
				, [Master_Case_Length] = II.[mastercartondimensionslength]
				, [Master_Case_Weight] = II.[weightmastercarton]
				, [Master_LWH_UOM] = 'IN'
				, [Master_Weight_UOM] = 'LB'
				, Updated_From_NewItem = 1
			FROM SPD_Item_Master_Vendor_Countries VC
				Join SPD_Import_Items II	on VC.[Michaels_SKU] = II.MichaelsSKU
												and VC.Vendor_Number = II.VendorNumber
												and VC.Country_Of_Origin = II.[CountryOfOrigin]
				join SPD_Batch B			on II.Batch_ID = B.ID
				join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
			WHERE B.ID = @BatchID
				and II.Valid_Existing_SKU = 0		-- Make sure that Item is new and not loaded initially from the Item Master
				and WS.Stage_Type_id = 4			-- ONLY COMPLETED BATCHES PLEASE
		END TRY

		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor Countries from Import... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH
		
		/* ******************************************************************************************************************* */
		-- Update Vendor Multiline info for above records where its the Updated_From_NewItem is at 1
		/* ******************************************************************************************************************* */
		BEGIN TRY
			declare @desc varchar(max), @SKU varchar(30), @VendorNo bigint, @break varchar(max), @method varchar(max)
			declare @r0 varchar(1000), @r1 varchar(1000), @r2 varchar(1000), @r3 varchar(1000), @r4 varchar(1000), @r5 varchar(1000)
			declare @t1 table  (ElementID int, Element varchar(max) )
			declare @c1 int, @c2 int, @c3 int
			select @c1= 0, @c2=0, @c3=0

			DECLARE row CURSOR FOR 
				SELECT 
					V.[Michaels_SKU]
					,V.[Vendor_Number]
					,V.[Detail_Invoice_Customs_Desc]
					,V.[Component_Material_Breakdown]
					,V.[Component_Construction_Method]
				FROM [dbo].[SPD_Item_Master_Vendor] V
					Join SPD_Import_Items II	on V.[Michaels_SKU] = II.MichaelsSKU
													and V.Vendor_Number = II.VendorNumber
													and II.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
					join SPD_Batch B			on II.Batch_ID = B.ID
					join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				WHERE WS.Stage_Type_id = 4	-- ONLY COMPLETED BATCHES PLEASE
					and B.ID = @BatchID
					and (  [Detail_Invoice_Customs_Desc] is not null
						or [Component_Material_Breakdown] is not null
						or [Component_Construction_Method] is not null
						)
					and Updated_From_NewItem = 1	-- Been Update from New Item
					
			OPEN row
			FETCH NEXT FROM row INTO @SKU, @VendorNo, @desc, @break, @method;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				UPDATE [SPD_Item_Master_Vendor]
					SET Updated_From_NewItem = 2	-- Flag that we have updated the multiline fields
				WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					
				IF @desc is not NULL
				BEGIN 
					INSERT @t1
						Select ElementID, Element FROM SPLIT(@desc, '<MULTILINEDELIMITER>')
					
					-- Force the variables to be '' for each pass
					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = Element from @t1 where ElementID = 1
					Select @r1 = Element from @t1 where ElementID = 2
					Select @r2 = Element from @t1 where ElementID = 3
					Select @r3 = Element from @t1 where ElementID = 4
					Select @r4 = Element from @t1 where ElementID = 5
					Select @r5 = Element from @t1 where ElementID = 6

					DELETE FROM @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
						  [Detail_Invoice_Customs_Desc0] = Coalesce(@r0,'')
						, [Detail_Invoice_Customs_Desc1] = Coalesce(@r1,'')
						, [Detail_Invoice_Customs_Desc2] = Coalesce(@r2,'')
						, [Detail_Invoice_Customs_Desc3] = Coalesce(@r3,'')
						, [Detail_Invoice_Customs_Desc4] = Coalesce(@r4,'')
						, [Detail_Invoice_Customs_Desc5] = Coalesce(@r5,'')
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c1 = @c1 + 1	
				END
				
				IF @break is not NULL
				BEGIN
					INSERT @t1
						Select ElementID, Element FROM SPLIT(@break, '<MULTILINEDELIMITER>')

					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = Element from @t1 where ElementID = 1
					Select @r1 = Element from @t1 where ElementID = 2
					Select @r2 = Element from @t1 where ElementID = 3
					Select @r3 = Element from @t1 where ElementID = 4
					Select @r4 = Element from @t1 where ElementID = 5

					DELETE FROM @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
  						  [Component_Material_Breakdown0] = coalesce(@r0,'')
						, [Component_Material_Breakdown1] = coalesce(@r1,'')
						, [Component_Material_Breakdown2] = coalesce(@r2,'')
						, [Component_Material_Breakdown3] = coalesce(@r3,'')
						, [Component_Material_Breakdown4] = coalesce(@r4,'')
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c2 = @c2 + 1	
				END		

				IF @method is not NULL
				BEGIN
					Insert @t1
						Select ElementID, Element FROM SPLIT(@method, '<MULTILINEDELIMITER>')

					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = Element from @t1 where ElementID = 1
					Select @r1 = Element from @t1 where ElementID = 2
					Select @r2 = Element from @t1 where ElementID = 3
					Select @r3 = Element from @t1 where ElementID = 4
					delete from @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
						  [Component_Construction_Method0] = coalesce(@r0,'')
						, [Component_Construction_Method1] = coalesce(@r1,'')
						, [Component_Construction_Method2] = coalesce(@r2,'')
						, [Component_Construction_Method3] = coalesce(@r3,'')
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c3 = @c3 + 1	
				END	
				
				FETCH NEXT FROM row INTO @SKU, @VendorNo, @desc, @break, @method;
			END	
			CLOSE row;
			DEALLOCATE row;
			DELETE FROM @t1

			IF @Debug=1  Print 'MultiLines were Updated'
			set @msg = '   Total Count of Multiline Updates: ' + convert(varchar(20),(@c1 + @c2 + @c3))
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		END TRY
		BEGIN CATCH
			set @msg = 'Updating Item Master Vendor MultiLines... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			CLOSE row;
			DEALLOCATE row;
			RETURN	
		END CATCH
		
		
		-- **********************************************************************************************
		-- Update Multilingual Info
		BEGIN TRY
			set @msg = 'Updating Item Master Languages from Import Item Languages Table pt 1. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

			-- FIRST, Update the Langauge table, in case the languages already exist.
			-- This should never be the case, but adding the code here in case we need to support it later.
			UPDATE SPD_Item_Master_Languages
			SET Translation_Indicator = SIIL.Translation_Indicator,
				Description_Short = SIIL.Description_Short,
				Description_Long = SIIL.Description_Long,
				Modified_User_ID = 0,
				Date_Requested = getDate(),
				Date_Last_Modified = getDate()
			FROM SPD_Item_Master_Languages as SIML
			INNER JOIN SPD_Import_Items as II on SIML.Michaels_SKU = II.MichaelsSKU
			INNER JOIN SPD_Import_Item_Languages SIIL on II.ID = SIIL.Import_Item_ID and SIML.Language_Type_ID = SIIL.Language_Type_ID
			WHERE II.Batch_ID = @BatchID

			-- INSERT new records into the Langauge table
			INSERT INTO SPD_Item_Master_Languages (Michaels_SKU, Language_Type_ID, Translation_Indicator, Description_Short, Description_Long, Date_Requested, Created_User_ID, Date_Created, Modified_User_ID, Date_Last_Modified)
			Select II.MichaelsSKU, SIIL.Language_Type_ID, SIIL.Translation_Indicator, SIIL.Description_Short, SIIL.Description_Long, GetDate(), 0, GetDate(), 0, GetDate()
			FROM SPD_Import_Items as II
			INNER JOIN SPD_Import_Item_Languages as SIIL on II.ID = SIIL.Import_Item_ID
			LEFT JOIN SPD_Item_Master_Languages as SIML on SIML.Michaels_SKU = II.MichaelsSKU AND SIML.Language_Type_ID = SIIL.Language_Type_ID
			WHERE SIML.ID is null AND II.Batch_ID = @BatchID

		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master Languages from Import Item Languages Table pt 1... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH
		
		-- **********************************************************************************************
		-- Update Multilingual Info
		BEGIN TRY
			set @msg = 'Updating Item Master Languages from Import Item Languages Table pt 2. Batch ID: ' + @vcBatchID
			IF @Debug=1  Print @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

			-- FIRST, Update the Langauge table, in case the languages already exist.
			-- This should never be the case, but adding the code here in case we need to support it later.
			UPDATE SPD_Item_Master_Languages_Supplier
			SET Package_Language_Indicator = SIIL.Package_Language_Indicator,
				Modified_User_ID = 0,
				Date_Last_Modified = getDate()
			FROM SPD_Item_Master_Languages_Supplier as SIML
			INNER JOIN SPD_Import_Items as II on SIML.Michaels_SKU = II.MichaelsSKU
			INNER JOIN SPD_Import_Item_Languages SIIL on II.ID = SIIL.Import_Item_ID and SIML.Language_Type_ID = SIIL.Language_Type_ID and SIML.Vendor_Number = II.VendorNumber
			WHERE II.Batch_ID = @BatchID

			-- INSERT new records into the Langauge table
			INSERT INTO SPD_Item_Master_Languages_Supplier (Michaels_SKU, Vendor_Number, Language_Type_ID, Package_Language_Indicator, Created_User_ID, Date_Created, Modified_User_ID, Date_Last_Modified)
			Select II.MichaelsSKU, II.VendorNumber, SIIL.Language_Type_ID, SIIL.Package_Language_Indicator, 0, GetDate(), 0, GetDate()
			FROM SPD_Import_Items as II
			INNER JOIN SPD_Import_Item_Languages as SIIL on II.ID = SIIL.Import_Item_ID
			LEFT JOIN SPD_Item_Master_Languages_supplier as SIML on SIML.Michaels_SKU = II.MichaelsSKU AND SIML.Language_Type_ID = SIIL.Language_Type_ID and SIML.Vendor_Number = II.VendorNumber
			WHERE SIML.ID is null AND II.Batch_ID = @BatchID

		END TRY
		
		BEGIN CATCH
			set @msg = 'Updating Item Master Languages from Import Item Languages Table pt 2... Error Occurred in Update' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
			Rollback Tran
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN	
		END CATCH		
		
	END	
	
	Commit Tran
	IF @Debug=1  Print 'Updating Item Master Proc Ends'
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Updating Item Master From New Item Proc Ends'


END
go

/****** Object:  StoredProcedure [dbo].[SPD_Report_ImportItem]    Script Date: 01/22/2018 14:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SPD_Report_ImportItem] 
	@startDate as Datetime = null,
	@endDate as DateTime = null,
	@dept as integer = null,
	@stage as integer = null,
	@vendor as bigint = null,
	@vendorFilter as bigint = null,
	@workflowId as integer = 1,
	@approver as int = null
AS

declare @dateNow datetime        
declare @dateNowStr varchar(20)        
declare @month varchar(2), @day varchar(2), @year varchar(4)            

set @dateNow = getdate()        
set @month = convert(varchar(2), Month(@dateNow))          
if (len(@month) < 2)             
	set @month = '0' + @month          

set @day = convert(varchar(2), Day(@dateNow))          
if (len(@day) < 2)             
	set @day = '0' + @day         

set @year = convert(varchar(4), Year(@dateNow))          
if (len(@year) < 4)             
	set @year = '00' + @year             

set @dateNowStr =  @year + @month + @day                


IF (@workflowId = 1)
BEGIN

	SELECT  ii.ID, ii.Batch_ID, ii.DateCreated, b.Date_Modified, 
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ii.CreatedUserID) as CreatedUser,
		COALESCE((SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ii.UpdateUserID),'System') as UpdateUser, 
		ii.DateSubmitted,     
		ii.Vendor, ii.Agent as MerchBurden, ii.AgentType as MerchBurdenType, ii.Buyer, ii.Fax, ii.EnteredBy, ii.QuoteSheetStatus, ii.Season, ii.SKUGroup,    
		ii.Email, ii.EnteredDate, ii.Dept, ii.Class, ii.SubClass, ii.PrimaryUPC, ii.MichaelsSKU as SKU, ii.GenerateMichaelsUPC as GenerateUPC,     
		ii.AdditionalUPC1, ii.AdditionalUPC2, ii.AdditionalUPC3, ii.AdditionalUPC4, ii.AdditionalUPC5, ii.AdditionalUPC6,    
		ii.AdditionalUPC7, ii.AdditionalUPC8, ii.PackSKU, ii.PlanogramName, ii.VendorNumber, ii.VendorRank, ii.ItemTask,     
		ii.[Description], ii.PaymentTerms, ii.[Days], ii.VendorMinOrderAmount, ii.VendorName, ii.VendorAddress1, ii.VendorAddress2,    
		ii.VendorAddress3, ii.VendorAddress4, ii.VendorContactName, ii.VendorContactPhone, ii.VendorContactEmail, ii.VendorContactFax,     
		ii.ManufactureName, ii.ManufactureAddress1, ii.ManufactureAddress2, ii.ManufactureContact, ii.ManufacturePhone,    
		ii.ManufactureEmail, ii.ManufactureFax, ii.AgentContact, ii.AgentPhone, ii.AgentEmail, ii.AgentFax, ii.VendorStyleNumber,     
		ii.HarmonizedCodeNumber, ii.canadaHarmonizedCodeNumber,
		ii.DetailInvoiceCustomsDesc, ii.ComponentMaterialBreakdown, ii.ComponentConstructionMethod, ii.IndividualItemPackaging,     
		ii.EachInsideMasterCaseBox, ii.EachInsideInnerPack, ii.ReshippableInnerCartonWeight,--ii.EachPieceNetWeightLbsPerOunce, 
		ii.eachheight, ii.eachwidth, ii.eachlength, ii.eachweight, ii.cubicfeeteach,
		ii.ReshippableInnerCartonLength,     
		ii.ReshippableInnerCartonWidth, ii.ReshippableInnerCartonHeight, ii.MasterCartonDimensionsLength, ii.MasterCartonDimensionsWidth,     
		ii.MasterCartonDimensionsHeight, ii.CubicFeetPerMasterCarton, ii.WeightMasterCarton, ii.CubicFeetPerInnerCarton, ii.FOBShippingPoint,    
		ii.DutyPercent, ii.DutyAmount, ii.AdditionalDutyComment, ii.AdditionalDutyAmount, ii.OceanFreightAmount, ii.OceanFreightComputedAmount,     
		ii.AgentCommissionPercent As MerchBurdenPercent, ii.AgentCommissionAmount As MerchBurdenAmount, ii.OtherImportCostsPercent, ii.OtherImportCostsAmount, ii.PackagingCostAmount,     
		ii.TotalImportBurden, ii.WarehouseLandedCost, ii.PurchaseOrderIssuedTo, ii.ShippingPoint, ii.CountryOfOrigin, ii.CountryOfOriginName,     
		ii.VendorComments, ii.StockCategory, ii.FreightTerms, ii.ItemType, ii.PackItemIndicator, ii.ItemTypeAttribute, ii.AllowStoreOrder,    
		ii.InventoryControl, ii.AutoReplenish, ii.PrePriced, ii.TaxUDA, ii.PrePricedUDA, ii.TaxValueUDA, 
		--ii.HybridType, ii.SourcingDC, ii.LeadTime,  ii.ConversionDate, 
		ii.Stocking_Strategy_Code,
		ii.StoreSuppZoneGRP, ii.WhseSuppZoneGRP, ii.POGMaxQty, ii.POGSetupPerStore as Initial_Set_Qty_Per_Store, ii.OutboundFreight,    
		ii.NinePercentWhseCharge, ii.TotalStoreLandedCost, ii.RDBase as Base1_Retail, ii.RDCentral as Base2_Retail, ii.RDTest as Test_Retail, ii.RDAlaska as Alaska_Retail,    
		ii.RDCanada as Canada_Retail, ii.RD0Thru9 as High2_Retail, ii.RDCalifornia as High3_Retail, ii.RDVillageCraft as Small_Market_Retail, ii.Retail9 as High1_Retail,    
		ii.Retail10 as Base3_Retail, ii.Retail11 as Low1_Retail, ii.Retail12 as Low2_Retail, ii.Retail13 as Manhattan_Retail, ii.RDQuebec as Q5_Retail,    
		ii.RDPuertoRico as PR_Retail, ii.HazMatYes, ii.HazMatNo, ii.HazMatMFGCountry, ii.HazMatMFGName, ii.HazMatMFGFlammable, ii.HazMatMFGCity,     
		ii.HazMatContainerType, ii.HazMatMFGState, ii.HazMatContainerSize, ii.HazMatMFGPhone, ii.HazMatMSDSUOM, ii.TSSA, ii.CSA, ii.UL, ii.LicenceAgreement,     
		ii.FumigationCertificate, ii.KILNDriedCertificate, ii.ChinaComInspecNumAndCCIBStickers, ii.OriginalVisa, ii.TextileDeclarationMidCode, ii.QuotaChargeStatement,     
		ii.MSDS, ii.TSCA, ii.DropBallTestCert, ii.ManMedicalDeviceListing, ii.ManFDARegistration, ii.CopyRightIndemnification, ii.FishWildLifeCert,     
		ii.Proposition65LabelReq, ii.CCCR, ii.FormaldehydeCompliant, ii.Is_Valid, ii.Tax_Wizard, ii.RMS_Sellable, ii.RMS_Orderable, ii.RMS_Inventory, ii.Parent_ID,     
		ii.RegularBatchItem, ii.[Sequence], ii.Store_Total, ii.POG_Start_Date, ii.POG_Comp_Date, ii.Like_Item_SKU, ii.Like_Item_Description, ii.Like_Item_Retail,     
		ii.Like_Item_Regular_Unit, ii.Like_Item_Sales, ii.Facings, ii.POG_Min_Qty, ii.Displayer_Cost, ii.Product_Cost, ii.Calculate_Options, ii.Like_Item_Store_Count,     
		ii.Like_Item_Unit_Store_Month, ii.Annual_Reg_Retail_Sales, ii.Annual_Regular_Unit_Forecast, ii.Min_Pres_Per_Facing,   
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		COALESCE(lv.Display_Text, '') as Private_Brand_Label, ii.QuoteReferenceNumber, ii.Customs_Description,   
		silE.Package_Language_Indicator as Package_Language_Indicator_English,   
		silF.Package_Language_Indicator as Package_Language_Indicator_French,   
		silS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		silE.Translation_Indicator as Translation_Indicator_English,   
		silF.Translation_Indicator as Translation_Indicator_French,   
		silS.Translation_Indicator as Translation_Indicator_Spanish,       
		silE.Description_Short as English_Short_Description, silE.Description_Long as English_Long_Description, silF.Description_Short as French_Short_Description,    
		silF.Description_Long as French_Long_Description, silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description          
	FROM [SPD_Import_Items] ii with(nolock)         
		inner join [SPD_Batch] b with(nolock) on ii.Batch_ID = b.ID           
		left outer join SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1           
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = ii.[ID] and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = ii.[ID] and f2.File_Type = 'MSDS'        
		LEFT JOIN SPD_Import_Item_Languages as silE with(nolock) on silE.Import_Item_ID = ii.ID and silE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Import_Item_Languages as silF with(nolock) on silF.Import_Item_ID = ii.ID and silF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Import_Item_Languages as silS with(nolock) on silS.Import_Item_ID = ii.ID and silS.Language_Type_ID = 3 -- SPANISH Language Fields          
		LEFT OUTER JOIN List_Values as lv on lv.List_Value_Group_ID = 16 And ii.Private_Brand_Label = lv.List_Value        
	WHERE b.enabled = 1 and b.Batch_Type_ID=2      
		and (@startDate is null or (@startDate is not null and b.date_modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.date_modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept))        
		and ((isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 1) = 1    
		and COALESCE(ws.Stage_Type_id, 1) <> 4) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage))        
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and b.Vendor_Number = @vendor))
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and b.Vendor_Number = @vendorFilter))            
	    and (@approver is null or (b.Workflow_Stage_ID in (select wap.Workflow_Stage_id from SPD_Workflow_Approval_Group wap inner join Security_User_Group sug on wap.Approval_group_id = sug.Group_ID inner join Security_User su on sug.[User_ID] = su.[ID] where su.[ID] = @approver ) 
									and b.fineline_dept_ID in (select isnull(convert(int, substring(sp.constant, 10, len(sp.constant))), 0) from Security_Privilege sp inner join Security_User_Privilege sup on sp.[ID] = sup.Privilege_ID where sp.Scope_ID = 1002 and sup.[User_ID] = @approver)))
END

IF (@workflowId = 2)
BEGIN

	SELECT simi.ID, simi.Batch_ID, simi.Date_Created, b.Date_Modified, 
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = b.Created_User) as [Created User],
		COALESCE((Select First_Name + Last_Name From Security_User Where ID = b.Modified_User),'System') as [Update User],
		b.Date_Created as Date_Submitted, 
		CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'V' Then 'YES' Else 'NO' END as [Vendor], CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'A' Then 'YES' Else 'NO' END as [Agent], 
		v.Agent_Type as Merch_Burden_Type, s.Buyer, s.Buyer_Fax as [Fax],
		su.First_Name + ' ' + su.Last_Name as [Entered_By], 
		s.Season, s.SKU_Group, s.Buyer_Email,
		b.Date_Created as [Entered_Date], 
		s.Department_Num, s.Class_Num, s.Sub_Class_Num, upc.UPC as Primary_UPC, s.Michaels_SKU, 
		(SELECT     COUNT(*) AS Expr1
			FROM          dbo.SPD_Item_Master_Vendor_UPCs AS UPC2
            WHERE      (Michaels_SKU = s.Michaels_SKU) AND (Vendor_Number = V.Vendor_Number) AND (Primary_Indicator = 0)) AS AdditionalUPCs, --TODO: Figure out how to handle multiple UPC stuff..
		s.Pack_SKU, s.Planogram_Name, v.Vendor_Number,
		'EDIT ITEM' as Item_Task, 
		s.Item_Desc as [Description], 
		v.PaymentTerms as Payment_Terms, v.Days,v.Vendor_Min_Order_Amount, v.Vendor_Name, v.Vendor_Address1, v.Vendor_Address2, v.Vendor_Address3, v.Vendor_Address4,
		v.Vendor_Contact_Name, v.Vendor_Contact_Phone, v.Vendor_Contact_Email, v.Vendor_Contact_Fax,
		v.Manufacture_Name, v.Manufacture_Address1, v.Manufacture_Address2, v.Manufacture_Contact, v.Manufacture_Phone, v.Manufacture_Email, v.Manufacture_Fax,
		v.Agent_Contact, v.Agent_Phone, v.Agent_Email, v.Agent_Fax, v.Vendor_Style_Num as [Vendor_Style_Number], v.Harmonized_CodeNumber as [Harmonized_Code_Number],
		v.Canada_Harmonized_CodeNumber as [Canada_Harmonized_CodeNumber],
		v.Detail_Invoice_Customs_Desc0 as Detail_Invoice_Customs_Desc, v.Component_Material_Breakdown, v.Component_Construction_Method, v.Individual_Item_Packaging,
		C.Eaches_Master_Case, C.Eaches_Inner_Pack,
		
		C.Each_Case_Height as Each_Dimensions_Height,
		C.Each_Case_Width as Each_Dimensions_Width,
		C.Each_Case_Length as Each_Dimensions_Length,
		C.Each_Case_Weight as Each_Dimensions_Weight,
		C.Each_Case_Cube as Cubic_Feet_Per_Each_Carton,
		
		C.Inner_Case_Weight as Each_Piece_Net_Weight_Lbs_Per_Ounce, 
		C.Inner_Case_Length as Reshippable_Inner_Carton_Length,
		C.Inner_Case_Width as Reshippable_Inner_Carton_Width, 
		C.Inner_Case_Height as Reshippable_Inner_Carton_Height, 
		C.Master_Case_Length as Master_Carton_Dimensions_Length,
		C.Master_Case_Width as Master_Carton_Dimensions_Width,
		C.Master_Case_Height as Master_Carton_Dimensions_Height,
		C.Master_Case_Cube as Cubic_Feet_Per_Master_Carton, 
		C.Master_Case_Weight as Weight_Master_Carton,
		C.Inner_Case_Cube as Cubic_Feet_Per_Inner_Carton,
		V.FOB_Shipping_Point, V.Duty_Percent, V.Duty_Amount, V.Additional_Duty_Comment, V.Additional_Duty_Amount, V.Ocean_Freight_Amount,  V.Ocean_Freight_Computed_Amount,
		V.Agent_Commission_Percent As Merch_Burden_Percent, V.Agent_Commission_Amount As Merch_Burden_Amount, V.Other_Import_Costs_Percent, V.Other_Import_Costs_Amount, V.Packaging_Cost_Amount,
		C.Import_Burden AS Import_Burden,  V.Warehouse_Landed_Cost, V.Purchase_Order_Issued_To, V.Shipping_Point, C.Country_Of_Origin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS Country_Of_Origin_Name,
		V.Vendor_Comments, s.Stock_Category, V.Freight_Terms, 
		UPPER(s.Item_Type) as Item_Type, UPPER(s.Item_Type) AS Pack_Item_Indicator,
		s.Item_Type_Attribute, UPPER(s.Allow_Store_Order) AS Allow_Store_Order, UPPER(s.Inventory_Control) as Inventory_Control, 
		UPPER(s.Auto_Replenish) AS Auto_Replenish, 
		CASE WHEN (SELECT COUNT(*) FROM  SPD_Item_Master_UDA UDA4 WHERE  UDA4.Michaels_SKU = s.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS Pre_Priced,
		(SELECT TOP (1) ISNULL(UDA_Value, 0) AS Expr1 FROM SPD_Item_Master_UDA AS UDA5 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 10)) AS Pre_Priced_UDA,
		(SELECT TOP (1) UDA_ID FROM SPD_Item_Master_UDA AS UDA2 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_UDA,
		(SELECT TOP (1) UDA_Value FROM SPD_Item_Master_UDA AS UDA3 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_Value_UDA,
		--s.Hybrid_Type, s.Hybrid_Source_DC as Sourcing_DC, 
		s.STOCKING_STRATEGY_CODE,
		s.Store_Supplier_Zone_Group as Store_Supp_Zone_GRP, s.WHS_Supplier_Zone_Group as Whse_Supp_Zone_GRP, s.POG_Max_Qty, s.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store,
		v.Outbound_Freight, v.Nine_Percent_Whse_Charge, v.Total_Store_Landed_Cost, s.Base1_Retail, s.Base2_Retail, s.Test_Retail, s.Alaska_Retail,
		s.Canada_Retail, s.High2_Retail, s.High3_Retail, s.Small_Market_Retail, s.High1_Retail, s.Base3_Retail, s.Low1_Retail, s.Low2_Retail, s.Manhattan_Retail, s.Quebec_Retail as Q5_Retail,
		s.PuertoRico_Retail as PR_Retail,  
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'Y' Then 'X' Else '' END as Haz_Mat_Yes, 
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'N' Then 'X' Else '' END as Haz_Mat_No, 
		V.Hazardous_Manufacturer_Country as Haz_Mat_MFG_Country, V.Hazardous_Manufacturer_Name as Haz_Mat_MFG_Name, UPPER(s.Hazardous_Flammable) as Haz_Mat_MFG_Flammable,
		V.Hazardous_Manufacturer_City as Haz_Mat_MFG_City, UPPER(s.Hazardous_Container_Type) as Haz_Mat_Container_Type, V.Hazardous_Manufacturer_State as Haz_Mat_MFG_State,
		s.Hazardous_Container_Size as Haz_Mat_Container_Size, V.Hazardous_Manufacturer_Phone as Haz_Mat_MFG_Phone, UPPER(s.Hazardous_MSDS_UOM) as Haz_Mat_MSDS_UOM,
		s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
		s.Original_Visa, s.Textile_Declaration_Mid_Code, s.Quota_Charge_Statement, s.MSDS, s.TSCA, s.Drop_Bal_lTest_Cert as Drop_Ball_Test_Cert,
		s.Man_Medical_Device_Listing, s.Man_FDA_Registration, s.Copy_Right_Indemnification, s.Fish_Wild_Life_Cert, s.Proposition_65_Label_Req, s.CCCR,
		s.Formaldehyde_Compliant, simi.Is_Valid, 
		s.RMS_Sellable, s.RMS_Orderable, s.RMS_Inventory, 
		PKI.Pack_SKU as Parent_ID, 
		CASE WHEN UPPER(COALESCE(s.Pack_Item_Indicator,'')) = 'Y' Then 'NO' Else 'YES' END as Regular_Batch_Item, --TODO: Verify this is correct?
		s.Store_Total, 
		s.Displayer_Cost, C.Unit_Cost as Product_Cost, 
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=item_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS Private_Brand_Label,
		s.QuoteReferenceNumber as Quote_Reference_Number, s.Customs_Description,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, simlF.Description_Short as French_Short_Description,    
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, simlS.Description_Long as Spanish_Long_Description          
	INTO #ImportItemMaint
	FROM SPD_Item_Maint_Items as simi with(nolock) 
		INNER JOIN SPD_Batch as b with(nolock) on b.ID = simi.Batch_ID
		INNER JOIN SPD_Item_Master_SKU as s with(nolock) on s.Michaels_SKU = simi.Michaels_SKU
		INNER JOIN SPD_Item_Master_Vendor as v with(nolock) on v.Michaels_SKU = simi.Michaels_SKU and v.Vendor_Number = simi.Vendor_Number
		INNER JOIN SPD_Vendor as sv with(nolock) on sv.Vendor_Number = v.Vendor_Number	
		Left Outer Join Security_User as su with(nolock) on su.ID = b.Created_User
		LEFT OUTER JOIN SPD_Item_Master_Vendor_UPCs AS UPC with(nolock) ON v.Michaels_SKU = UPC.Michaels_SKU AND v.Vendor_Number = UPC.Vendor_Number AND UPC.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_Item_Master_Vendor_Countries AS C with(nolock) ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND C.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_COUNTRY AS CO with(nolock) ON CO.COUNTRY_CODE = C.Country_Of_Origin
		LEFT OUTER JOIN SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 2
		LEFT OUTER JOIN SPD_Item_Master_PackItems AS PKI with(nolock) ON s.Michaels_SKU = PKI.Child_SKU AND B.Pack_SKU = PKI.Pack_SKU   
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = v.Image_ID and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = v.MSDS_ID and f2.File_Type = 'MSDS'          
		LEFT JOIN SPD_Item_Master_Languages as simlE with(nolock) on simlE.Michaels_SKU = s.Michaels_SKU and simlE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlF with(nolock) on simlF.Michaels_SKU = s.Michaels_SKU and simlF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlS with(nolock) on simlS.Michaels_SKU = s.Michaels_SKU  and simlS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsE with(nolock) on simlsE.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsF.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsS.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
	WHERE b.Enabled = 1 AND sv.Vendor_Type = 300 and b.Batch_Type_ID=2   
		and (@startDate is null or (@startDate is not null and b.Date_Modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.Date_Modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and s.Department_Num = @dept))        
		and ((isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 2) = 2    
		and COALESCE(ws.Stage_Type_id, 1) <> 4) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage))        
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and v.Vendor_Number = @vendor))
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and v.Vendor_Number = @vendorFilter))            
		and (@approver is null or (b.Workflow_Stage_ID in (select wap.Workflow_Stage_id from SPD_Workflow_Approval_Group wap inner join Security_User_Group sug on wap.Approval_group_id = sug.Group_ID inner join Security_User su on sug.[User_ID] = su.[ID] where su.[ID] = @approver ) 
									and b.fineline_dept_ID in (select isnull(convert(int, substring(sp.constant, 10, len(sp.constant))), 0) from Security_Privilege sp inner join Security_User_Privilege sup on sp.[ID] = sup.Privilege_ID where sp.Scope_ID = 1002 and sup.[User_ID] = @approver)))
	    
		--UPDATE Temp Table with CHANGE Values	  
		UPDATE #ImportItemMaint
	    SET Season = isNull(c.Field_Value, iim.Season)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Season'
		  	    	    
	    UPDATE #ImportItemMaint
	    SET Planogram_Name = isNull(c.Field_Value, iim.Planogram_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PlanogramName'
	    
	    UPDATE #ImportItemMaint
	    SET [Description] = isNull(c.Field_Value, iim.[Description])
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemDesc'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Address1 = isNull(c.Field_Value, iim.Vendor_Address1)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress1'
	    
	    UPDATE #ImportItemMaint
	    SET Vendor_Address2 = isNull(c.Field_Value, iim.Vendor_Address2)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress2'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Address3 = isNull(c.Field_Value, iim.Vendor_Address3)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress3'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Address4 = isNull(c.Field_Value, iim.Vendor_Address4)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress4'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Contact_Email = isNull(c.Field_Value, iim.Vendor_Contact_Email)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactEmail'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Contact_Fax = isNull(c.Field_Value, iim.Vendor_Contact_Fax)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactFax'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Contact_Name = isNull(c.Field_Value, iim.Vendor_Contact_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactName'
	    
	    UPDATE #ImportItemMaint
	    SET Vendor_Contact_Phone = isNull(c.Field_Value, iim.Vendor_Contact_Phone)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactPhone'
	    
	    UPDATE #ImportItemMaint
	    SET Manufacture_Address1 = isNull(c.Field_Value, iim.Manufacture_Address1)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureAddress1'
	    
		UPDATE #ImportItemMaint
	    SET Manufacture_Address2 = isNull(c.Field_Value, iim.Manufacture_Address2)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureAddress2'
		
		UPDATE #ImportItemMaint
	    SET Manufacture_Contact = isNull(c.Field_Value, iim.Manufacture_Contact)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureContact'
		
		UPDATE #ImportItemMaint
	    SET Manufacture_Email = isNull(c.Field_Value, iim.Manufacture_Email)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureEmail'
	   
		UPDATE #ImportItemMaint
	    SET Manufacture_Fax = isNull(c.Field_Value, iim.Manufacture_Fax)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureFax' 
		
		UPDATE #ImportItemMaint
	    SET Manufacture_Name = isNull(c.Field_Value, iim.Manufacture_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureName' 
		
		UPDATE #ImportItemMaint
	    SET Agent_Contact = isNull(c.Field_Value, iim.Agent_Contact)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentContact' 
	    
	    UPDATE #ImportItemMaint
	    SET Agent_Email = isNull(c.Field_Value, iim.Agent_Email)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentEmail' 
		
		UPDATE #ImportItemMaint
	    SET Agent_Fax = isNull(c.Field_Value, iim.Agent_Fax)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentFax' 
		
		UPDATE #ImportItemMaint
	    SET Agent_Phone = isNull(c.Field_Value, iim.Agent_Phone)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentPhone' 
	    
	    UPDATE #ImportItemMaint
	    SET Vendor_Style_Number = isNull(c.Field_Value, iim.Vendor_Style_Number)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorStyleNum' 
	    
	    UPDATE #ImportItemMaint
	    SET Harmonized_Code_Number = isNull(c.Field_Value, iim.Harmonized_Code_Number)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HarmonizedCodeNumber' 
		
		UPDATE #ImportItemMaint
	    SET Canada_Harmonized_CodeNumber = isNull(c.Field_Value, iim.Canada_Harmonized_CodeNumber)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CanadaHarmonizedCodeNumber' 
	    
	    UPDATE #ImportItemMaint
	    SET Detail_Invoice_Customs_Desc = isNull(c.Field_Value, iim.Detail_Invoice_Customs_Desc)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DetailInvoiceCustomsDesc0' 
	   
	    UPDATE #ImportItemMaint
	    SET Component_Material_Breakdown = isNull(c.Field_Value, iim.Component_Material_Breakdown)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ComponentMaterialBreakdown0'  
		
		UPDATE #ImportItemMaint
	    SET Component_Construction_Method = isNull(c.Field_Value, iim.Component_Construction_Method)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ComponentConstructionMethod0' 
	    
	    UPDATE #ImportItemMaint
	    SET Individual_Item_Packaging = isNull(c.Field_Value, iim.Individual_Item_Packaging)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'IndividualItemPackaging' 
	    
	    UPDATE #ImportItemMaint
	    SET Eaches_Master_Case = isNull(c.Field_Value, iim.Eaches_Master_Case)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EachesMasterCase' 
	    
	    UPDATE #ImportItemMaint
	    SET Eaches_Inner_Pack = isNull(c.Field_Value, iim.Eaches_Inner_Pack)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EachesInnerPack' 

	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Weight = isNull(c.Field_Value, iim.Each_Dimensions_Weight)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseWeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Length = isNull(c.Field_Value, iim.Each_Dimensions_Length)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseLength' 
	    
	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Width = isNull(c.Field_Value, iim.Each_Dimensions_Width)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseWidth' 
	    
	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Height = isNull(c.Field_Value, iim.Each_Dimensions_Height)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseHeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Cubic_Feet_Per_Each_Carton = isNull(c.Field_Value, iim.Cubic_Feet_Per_Each_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseCube' 

	    UPDATE #ImportItemMaint
	    SET Each_Piece_Net_Weight_Lbs_Per_Ounce = isNull(c.Field_Value, iim.Each_Piece_Net_Weight_Lbs_Per_Ounce)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseWeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Reshippable_Inner_Carton_Length = isNull(c.Field_Value, iim.Reshippable_Inner_Carton_Length)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseLength' 
	    
	    UPDATE #ImportItemMaint
	    SET Reshippable_Inner_Carton_Width = isNull(c.Field_Value, iim.Reshippable_Inner_Carton_Width)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseWidth' 
	    
	    UPDATE #ImportItemMaint
	    SET Reshippable_Inner_Carton_Height = isNull(c.Field_Value, iim.Reshippable_Inner_Carton_Height)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseHeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Cubic_Feet_Per_Inner_Carton = isNull(c.Field_Value, iim.Cubic_Feet_Per_Inner_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseCube' 
	    
	    UPDATE #ImportItemMaint
	    SET Master_Carton_Dimensions_Length = isNull(c.Field_Value, iim.Master_Carton_Dimensions_Length)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseLength' 
	    
	    UPDATE #ImportItemMaint
	    SET Master_Carton_Dimensions_Width = isNull(c.Field_Value, iim.Master_Carton_Dimensions_Width)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseWidth'
	    
	    UPDATE #ImportItemMaint
	    SET Master_Carton_Dimensions_Height = isNull(c.Field_Value, iim.Master_Carton_Dimensions_Height)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseHeight'
		
		UPDATE #ImportItemMaint
	    SET Weight_Master_Carton = isNull(c.Field_Value, iim.Weight_Master_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseWeight'
		
		UPDATE #ImportItemMaint
	    SET Cubic_Feet_Per_Master_Carton = isNull(c.Field_Value, iim.Cubic_Feet_Per_Master_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseCube'
		
		UPDATE #ImportItemMaint
	    SET FOB_Shipping_Point = isNull(c.Field_Value, iim.FOB_Shipping_Point)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FOBShippingPoint'
		
		UPDATE #ImportItemMaint
	    SET Duty_Percent = isNull(c.Field_Value, iim.Duty_Percent)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DutyPercent'
    
	    UPDATE #ImportItemMaint
	    SET Duty_Amount = isNull(c.Field_Value, iim.Duty_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DutyAmount'

	    UPDATE #ImportItemMaint
	    SET Additional_Duty_Comment = isNull(c.Field_Value, iim.Additional_Duty_Comment)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AdditionalDutyComment'
	    
	    UPDATE #ImportItemMaint
	    SET Additional_Duty_Amount = CAST(isNull(c.Field_Value, iim.Additional_Duty_Amount) as money)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AdditionalDutyAmount'
 	    
	    UPDATE #ImportItemMaint
	    SET Ocean_Freight_Amount = isNull(c.Field_Value, iim.Ocean_Freight_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OceanFreightAmount'
 	    
	    UPDATE #ImportItemMaint
	    SET Ocean_Freight_Computed_Amount = isNull(c.Field_Value, iim.Ocean_Freight_Computed_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OceanFreightComputedAmount'
     
	    UPDATE #ImportItemMaint
	    SET Merch_Burden_Percent = isNull(c.Field_Value, iim.Merch_Burden_Percent)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentCommissionPercent'
    
	    UPDATE #ImportItemMaint
	    SET Merch_Burden_Amount = Case When c.Field_Value <> '' Then isNull(c.Field_Value, iim.Merch_Burden_Amount) Else iim.Merch_Burden_Amount End
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentCommissionAmount'
 
	    UPDATE #ImportItemMaint
	    SET Other_Import_Costs_Percent = isNull(c.Field_Value, iim.Other_Import_Costs_Percent)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OtherImportCostsPercent'
	    
	    UPDATE #ImportItemMaint
	    SET Other_Import_Costs_Amount = isNull(c.Field_Value, iim.Other_Import_Costs_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OtherImportCostsAmount'
	  
		UPDATE #ImportItemMaint
	    SET Packaging_Cost_Amount = isNull(c.Field_Value, iim.Packaging_Cost_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PackagingCostAmount'
	  
		UPDATE #ImportItemMaint
	    SET Import_Burden = isNull(c.Field_Value, iim.Import_Burden)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ImportBurden'
		
		UPDATE #ImportItemMaint
	    SET Warehouse_Landed_Cost = isNull(c.Field_Value, iim.Warehouse_Landed_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'WarehouseLandedCost'
	  
	    UPDATE #ImportItemMaint
	    SET Purchase_Order_Issued_To = isNull(c.Field_Value, iim.Purchase_Order_Issued_To)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PurchaseOrderIssuedTo'
	    
	    UPDATE #ImportItemMaint
	    SET Shipping_Point = isNull(c.Field_Value, iim.Shipping_Point)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ShippingPoint'
	    
	    UPDATE #ImportItemMaint
	    SET Country_Of_Origin = isNull(c.Field_Value, iim.Country_Of_Origin)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CountryOfOrigin'
		
		UPDATE #ImportItemMaint
	    SET Country_Of_Origin_Name = isNull(c.Field_Value, iim.Country_Of_Origin_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CountryOfOriginName'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Comments = isNull(c.Field_Value, iim.Vendor_Comments)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorComments'
		
		UPDATE #ImportItemMaint
	    SET Stock_Category = isNull(c.Field_Value, iim.Stock_Category)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'StockCategory'
	    
	    UPDATE #ImportItemMaint
	    SET Freight_Terms = isNull(c.Field_Value, iim.Freight_Terms)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FreightTerms'
	    
	    UPDATE #ImportItemMaint
	    SET Item_Type = isNull(c.Field_Value, iim.Item_Type)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemType'
	    
	    UPDATE #ImportItemMaint
	    SET Pack_Item_Indicator = isNull(c.Field_Value, iim.Pack_Item_Indicator)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemType'
	    
	    UPDATE #ImportItemMaint
	    SET Item_Type_Attribute = isNull(c.Field_Value, iim.Item_Type_Attribute)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemTypeAttribute'
	    
	    UPDATE #ImportItemMaint
	    SET Allow_Store_Order = isNull(c.Field_Value, iim.Allow_Store_Order)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AllowStoreOrder'
	    
	    UPDATE #ImportItemMaint
	    SET Inventory_Control = isNull(c.Field_Value, iim.Inventory_Control)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InventoryControl'
	    
	    UPDATE #ImportItemMaint
	    SET Auto_Replenish = isNull(c.Field_Value, iim.Auto_Replenish)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AutoReplenish'
		
		UPDATE #ImportItemMaint
	    SET Pre_Priced = isNull(c.Field_Value, iim.Pre_Priced)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PrePriced'
		
		UPDATE #ImportItemMaint
	    SET Pre_Priced_UDA = isNull(c.Field_Value, iim.Pre_Priced_UDA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PrePricedUDA'
		
		UPDATE #ImportItemMaint
	    SET Tax_UDA = isNull(c.Field_Value, iim.Tax_UDA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TaxUDA'
	    
	    UPDATE #ImportItemMaint
	    SET Tax_Value_UDA = isNull(c.Field_Value, iim.Tax_Value_UDA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TaxValueUDA'
	    
	 --   UPDATE #ImportItemMaint
	 --   SET Hybrid_Type = isNull(c.Field_Value, iim.Hybrid_Type)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'HybridType'
	    
	 --   UPDATE #ImportItemMaint
	 --   SET Sourcing_DC = isNull(c.Field_Value, iim.Sourcing_DC)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'HybridSourceDC'
	    
	    UPDATE #ImportItemMaint 
	    SET STOCKING_STRATEGY_CODE = isNull(c.Field_Value, iim.STOCKING_STRATEGY_CODE)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
	    WHERE    c.Field_Name = 'StockingStrategyCode'
	    
	    UPDATE #ImportItemMaint
	    SET Outbound_Freight = isNull(c.Field_Value, iim.Outbound_Freight)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OutboundFreight'
	    
	    UPDATE #ImportItemMaint
	    SET Nine_Percent_Whse_Charge = isNull(c.Field_Value, iim.Nine_Percent_Whse_Charge)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'NinePercentWhseCharge'
	    
	    UPDATE #ImportItemMaint
	    SET Total_Store_Landed_Cost = isNull(c.Field_Value, iim.Total_Store_Landed_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TotalStoreLandedCost'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_Yes = CASE WHEN c.Field_Value is not null THEN 
								CASE WHEN c.Field_Value = 'Y' THEN 'X' Else '' END
						  ELSE Haz_Mat_Yes END
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Hazardous'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_No = CASE WHEN c.Field_Value is not null THEN 
								CASE WHEN c.Field_Value = 'N' THEN 'X' Else '' END
						  ELSE Haz_Mat_No END
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Hazardous'
		
		UPDATE #ImportItemMaint
	    SET Haz_Mat_Container_Type = isNull(c.Field_Value, iim.Haz_Mat_Container_Type)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousContainerType'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_Container_Size = isNull(c.Field_Value, iim.Haz_Mat_Container_Size)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousContainerSize'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_MSDS_UOM = isNull(c.Field_Value, iim.Haz_Mat_MSDS_UOM)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousMSDSUOM'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_MSDS_UOM = isNull(c.Field_Value, iim.Haz_Mat_MSDS_UOM)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousMSDSUOM'
	    
	    UPDATE #ImportItemMaint
	    SET TSSA = isNull(c.Field_Value, iim.TSSA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TSSA'
	    
	    UPDATE #ImportItemMaint
	    SET CSA = isNull(c.Field_Value, iim.CSA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CSA'
	    
	    UPDATE #ImportItemMaint
	    SET UL = isNull(c.Field_Value, iim.UL)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'UL'
	    
	    UPDATE #ImportItemMaint
	    SET Licence_Agreement = isNull(c.Field_Value, iim.Licence_Agreement)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'LicenceAgreement'
	    
	    UPDATE #ImportItemMaint
	    SET Fumigation_Certificate = isNull(c.Field_Value, iim.Fumigation_Certificate)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FumigationCertificate'
		
	    UPDATE #ImportItemMaint
	    SET KILN_Dried_Certificate = isNull(c.Field_Value, iim.KILN_Dried_Certificate)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'KILNDriedCertificate'
		
		UPDATE #ImportItemMaint
	    SET China_Com_Inspec_Num_And_CCIB_Stickers = isNull(c.Field_Value, iim.China_Com_Inspec_Num_And_CCIB_Stickers)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ChinaComInspecNumAndCCIBStickers'
		
		UPDATE #ImportItemMaint
	    SET Original_Visa = isNull(c.Field_Value, iim.Original_Visa)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OriginalVisa'
		
		UPDATE #ImportItemMaint
	    SET Textile_Declaration_Mid_Code = isNull(c.Field_Value, iim.Textile_Declaration_Mid_Code)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TextileDeclarationMidCode'
	    
	    UPDATE #ImportItemMaint
	    SET Quota_Charge_Statement = isNull(c.Field_Value, iim.Quota_Charge_Statement)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'QuotaChargeStatement'
	    
	    UPDATE #ImportItemMaint
	    SET MSDS = isNull(c.Field_Value, iim.MSDS)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MSDS'
	    
	    UPDATE #ImportItemMaint
	    SET TSCA = isNull(c.Field_Value, iim.TSCA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TSCA'
		
		UPDATE #ImportItemMaint
	    SET Drop_Ball_Test_Cert = isNull(c.Field_Value, iim.Drop_Ball_Test_Cert)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DropBallTestCert'
	    
	    UPDATE #ImportItemMaint
	    SET Man_Medical_Device_Listing = isNull(c.Field_Value, iim.Man_Medical_Device_Listing)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManMedicalDeviceListing'
	    
	    UPDATE #ImportItemMaint
	    SET Man_FDA_Registration = isNull(c.Field_Value, iim.Man_FDA_Registration)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManFDARegistration'
		
		UPDATE #ImportItemMaint
	    SET Copy_Right_Indemnification = isNull(c.Field_Value, iim.Copy_Right_Indemnification)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CopyRightIndemnification'
		
		UPDATE #ImportItemMaint
	    SET Fish_Wild_Life_Cert = isNull(c.Field_Value, iim.Fish_Wild_Life_Cert)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FishWildLifeCert'
	    
	    UPDATE #ImportItemMaint
	    SET Proposition_65_Label_Req = isNull(c.Field_Value, iim.Proposition_65_Label_Req)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Proposition65LabelReq'
	    
	    UPDATE #ImportItemMaint
	    SET CCCR = isNull(c.Field_Value, iim.CCCR)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CCCR'
	    
	    UPDATE #ImportItemMaint
	    SET Formaldehyde_Compliant = isNull(c.Field_Value, iim.Formaldehyde_Compliant)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FormaldehydeCompliant'
	    
	    UPDATE #ImportItemMaint
	    SET RMS_Sellable = isNull(c.Field_Value, iim.RMS_Sellable)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'RMSSellable'
	    
	    UPDATE #ImportItemMaint
	    SET RMS_Orderable = isNull(c.Field_Value, iim.RMS_Orderable)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'RMSOrderable'
	    
	    UPDATE #ImportItemMaint
	    SET RMS_Inventory = isNull(c.Field_Value, iim.RMS_Inventory)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'RMSInventory'
		
		UPDATE #ImportItemMaint
	    SET Store_Total = isNull(c.Field_Value, iim.Store_Total)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'StoreTotal'
		
		UPDATE #ImportItemMaint
	    SET Displayer_Cost = isNull(c.Field_Value, iim.Displayer_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DisplayerCost'
		
		UPDATE #ImportItemMaint
	    SET Product_Cost = isNull(c.Field_Value, iim.Product_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ProductCost'
	    	    
		UPDATE #ImportItemMaint
	    SET Private_Brand_Label = isNull(c.Field_Value, iim.Private_Brand_Label)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PrivateBrandLabel'
		
		UPDATE #ImportItemMaint
	    SET Quote_Reference_Number = isNull(c.Field_Value, iim.Quote_Reference_Number)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'QuoteReferenceNumber'
		
		UPDATE #ImportItemMaint
	    SET Customs_Description = isNull(c.Field_Value, iim.Customs_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CustomsDescription'
		
		UPDATE #ImportItemMaint
	    SET Package_Language_Indicator_English = isNull(c.Field_Value, iim.Package_Language_Indicator_English)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PLIEnglish'
		
	    UPDATE #ImportItemMaint
	    SET Package_Language_Indicator_French = isNull(c.Field_Value, iim.Package_Language_Indicator_French)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PLIFrench'
		
		UPDATE #ImportItemMaint
	    SET Package_Language_Indicator_Spanish = isNull(c.Field_Value, iim.Package_Language_Indicator_Spanish)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PLISpanish'
	    
	    UPDATE #ImportItemMaint
	    SET Translation_Indicator_English = isNull(c.Field_Value, iim.Translation_Indicator_English)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TIEnglish'
	    
	    UPDATE #ImportItemMaint
	    SET Translation_Indicator_French = isNull(c.Field_Value, iim.Translation_Indicator_French)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TIFrench'
		
		UPDATE #ImportItemMaint
	    SET Translation_Indicator_Spanish = isNull(c.Field_Value, iim.Translation_Indicator_Spanish)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TISpanish'
	    
		UPDATE #ImportItemMaint
	    SET English_Short_Description = isNull(c.Field_Value, iim.English_Short_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EnglishShortDescription'
	    
	    UPDATE #ImportItemMaint
	    SET English_Long_Description = isNull(c.Field_Value, iim.English_Long_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EnglishLongDescription'
	    
	    UPDATE #ImportItemMaint
	    SET French_Short_Description = isNull(c.Field_Value, iim.French_Short_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FrenchShortDescription'
	    
	    UPDATE #ImportItemMaint
	    SET French_Long_Description = isNull(c.Field_Value, iim.French_Long_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FrenchLongDescription'
		
		UPDATE #ImportItemMaint
	    SET Spanish_Short_Description = isNull(c.Field_Value, iim.Spanish_Short_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'SpanishShortDescription'
	    
	    UPDATE #ImportItemMaint
	    SET Spanish_Long_Description = isNull(c.Field_Value, iim.Spanish_Long_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'SpanishLongDescription'
	    
	    Select * from #ImportItemMaint
	    
	    Drop Table #ImportItemMaint
END
GO
/****** Object:  StoredProcedure [dbo].[SPD_Report_CompletedImportItem]    Script Date: 01/22/2018 14:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SPD_Report_CompletedImportItem] 
	@startDate as Datetime = null,
	@endDate as DateTime = null,
	@dept as integer = null,
	@vendor as bigint = null,
	@vendorFilter as bigint = null,
	@workflowId as integer = 1,
	@approver as integer = null
AS

declare @dateNow datetime        
declare @dateNowStr varchar(20)        
declare @month varchar(2), @day varchar(2), @year varchar(4)            

set @dateNow = getdate()        
set @month = convert(varchar(2), Month(@dateNow))          
if (len(@month) < 2)             
	set @month = '0' + @month          

set @day = convert(varchar(2), Day(@dateNow))          
if (len(@day) < 2)             
	set @day = '0' + @day         

set @year = convert(varchar(4), Year(@dateNow))          
if (len(@year) < 4)             
	set @year = '00' + @year             

set @dateNowStr =  @year + @month + @day                


IF (@workflowId = 1)
BEGIN

  SELECT  ii.ID, ii.Batch_ID, ii.DateCreated, ii.DateLastModified, 		
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ii.CreatedUserID) as CreatedUser,
		'System' as UpdateUser,
	  ii.DateSubmitted, ii.Vendor, ii.Agent as MerchBurden, ii.AgentType as MerchBurdenType, ii.Buyer, ii.Fax, ii.EnteredBy, ii.QuoteSheetStatus, ii.Season, ii.SKUGroup, ii.Email, 
	  ii.EnteredDate, ii.Dept, ii.[Class], ii.SubClass, ii.PrimaryUPC, ii.MichaelsSKU as SKU, ii.GenerateMichaelsUPC as GenerateUPC, ii.AdditionalUPC1, 
	  ii.AdditionalUPC2, ii.AdditionalUPC3, ii.AdditionalUPC4, ii.AdditionalUPC5, ii.AdditionalUPC6, ii.AdditionalUPC7, ii.AdditionalUPC8, 
	  ii.PackSKU, ii.PlanogramName, ii.VendorNumber, ii.VendorRank, ii.ItemTask, ii.Description, ii.PaymentTerms, ii.Days,     
	  ii.VendorMinOrderAmount, ii.VendorName, ii.VendorAddress1, ii.VendorAddress2, ii.VendorAddress3, ii.VendorAddress4, 
	  ii.VendorContactName, ii.VendorContactPhone, ii.VendorContactEmail, ii.VendorContactFax, ii.ManufactureName, ii.ManufactureAddress1, 
	  ii.ManufactureAddress2, ii.ManufactureContact, ii.ManufacturePhone, ii.ManufactureEmail, ii.ManufactureFax, ii.AgentContact, 
	  ii.AgentPhone, ii.AgentEmail, ii.AgentFax, ii.VendorStyleNumber, ii.HarmonizedCodeNumber, ii.canadaHarmonizedCodeNumber,
	  ii.DetailInvoiceCustomsDesc, 
	  ii.ComponentMaterialBreakdown, ii.ComponentConstructionMethod, ii.IndividualItemPackaging, ii.EachInsideMasterCaseBox,    
	  ii.EachInsideInnerPack, ii.ReshippableInnerCartonWeight,--ii.EachPieceNetWeightLbsPerOunce,
	  ii.eachlength,ii.eachwidth,ii.eachheight,ii.cubicfeeteach,ii.eachweight,  
	  ii.ReshippableInnerCartonLength, ii.ReshippableInnerCartonWidth, 
	  ii.ReshippableInnerCartonHeight, ii.MasterCartonDimensionsLength, ii.MasterCartonDimensionsWidth, 
	  ii.MasterCartonDimensionsHeight, ii.CubicFeetPerMasterCarton, ii.WeightMasterCarton, ii.CubicFeetPerInnerCarton, 
	  ii.FOBShippingPoint, ii.DutyPercent, ii.DutyAmount, ii.AdditionalDutyComment, ii.AdditionalDutyAmount, ii.OceanFreightAmount,
	  ii.OceanFreightComputedAmount, ii.AgentCommissionPercent As MerchBurdenPercent, ii.AgentCommissionAmount As MerchBurdenAmount, ii.OtherImportCostsPercent, 
	  ii.OtherImportCostsAmount, ii.PackagingCostAmount, ii.TotalImportBurden, ii.WarehouseLandedCost, ii.PurchaseOrderIssuedTo, 
	  ii.ShippingPoint, ii.CountryOfOrigin, ii.CountryOfOriginName, ii.VendorComments, ii.StockCategory, ii.FreightTerms, 
	  ii.ItemType, ii.PackItemIndicator, ii.ItemTypeAttribute, ii.AllowStoreOrder, ii.InventoryControl, ii.AutoReplenish, 
	  ii.PrePriced, ii.TaxUDA, ii.PrePricedUDA, ii.TaxValueUDA, ii.Stocking_Strategy_Code, 
	  --ii.HybridType, ii.SourcingDC, ii.LeadTime, ii.ConversionDate, 
	  ii.StoreSuppZoneGRP, ii.WhseSuppZoneGRP,    ii.POGMaxQty, ii.POGSetupPerStore as Initial_Set_Qty_Per_Store, ii.OutboundFreight, 
	  ii.NinePercentWhseCharge, ii.TotalStoreLandedCost, ii.RDBase as Base1_Retail, ii.RDCentral as Base2_Retail, 
	  ii.RDTest as Test_Retail, ii.RDAlaska as Alaska_Retail, ii.RDCanada as Canada_Retail, ii.RD0Thru9 as High2_Retail,
	  ii.RDCalifornia as High3_Retail, ii.RDVillageCraft as Small_Market_Retail, ii.Retail9 as High1_Retail, ii.Retail10 as Base3_Retail,
	  ii.Retail11 as Low1_Retail, ii.Retail12 as Low2_Retail, ii.Retail13 as Manhattan_Retail, ii.RDQuebec as Q5_Retail, 
	  ii.RDPuertoRico as PR_Retail, ii.HazMatYes, ii.HazMatNo, ii.HazMatMFGCountry, ii.HazMatMFGName, ii.HazMatMFGFlammable, 
	  ii.HazMatMFGCity, ii.HazMatContainerType, ii.HazMatMFGState, ii.HazMatContainerSize, ii.HazMatMFGPhone,ii.HazMatMSDSUOM, ii.TSSA, 
	  ii.CSA, ii.UL, ii.LicenceAgreement, ii.FumigationCertificate, ii.KILNDriedCertificate, ii.ChinaComInspecNumAndCCIBStickers,     
	  ii.OriginalVisa, ii.TextileDeclarationMidCode, ii.QuotaChargeStatement, ii.MSDS, ii.TSCA, ii.DropBallTestCert, 
	  ii.ManMedicalDeviceListing, ii.ManFDARegistration,    ii.CopyRightIndemnification, ii.FishWildLifeCert, ii.Proposition65LabelReq, 
	  ii.CCCR, ii.FormaldehydeCompliant, ii.Is_Valid, ii.Tax_Wizard, ii.RMS_Sellable, ii.RMS_Orderable, ii.RMS_Inventory, ii.Parent_ID, 
	  ii.RegularBatchItem, ii.[Sequence], ii.Store_Total, ii.POG_Start_Date, ii.POG_Comp_Date, ii.Like_Item_SKU, ii.Like_Item_Description, 
	  ii.Like_Item_Retail, ii.Like_Item_Regular_Unit, ii.Like_Item_Sales, ii.Facings, ii.POG_Min_Qty, ii.Displayer_Cost, ii.Product_Cost,
	  ii.Calculate_Options, ii.Like_Item_Store_Count, ii.Like_Item_Unit_Store_Month, ii.Annual_Reg_Retail_Sales, 
	  ii.Annual_Regular_Unit_Forecast, ii.Inner_Pack,    ii.Min_Pres_Per_Facing, b.Date_Modified as Last_Modified,    
	  case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>' else '' end as Item_Image, 
	  case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>' else '' end as MSDS_Sheet, 
	  COALESCE(lv.Display_Text, '') as Private_Brand_Label, ii.QuoteReferenceNumber, ii.Customs_Description,   
	  silEs.Package_Language_Indicator as Package_Language_Indicator_English,   
	  silFs.Package_Language_Indicator as Package_Language_Indicator_French,   
	  silSs.Package_Language_Indicator as Package_Language_Indicator_Spanish,     
	  silE.Translation_Indicator as Translation_Indicator_English,   
	  silF.Translation_Indicator as Translation_Indicator_French,   
	  silS.Translation_Indicator as Translation_Indicator_Spanish,       
	  silE.Description_Short as English_Short_Description, silE.Description_Long as English_Long_Description, 
	  silF.Description_Short as French_Short_Description, silF.Description_Long as French_Long_Description, 
	  silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description            
  FROM [SPD_Import_Items] ii with(nolock)            
	  inner join [SPD_Batch] b with(nolock) on ii.Batch_ID = b.ID             
	  left outer join SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1             
	  LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = ii.[ID] and f1.File_Type = 'IMG'              
	  LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = ii.[ID] and f2.File_Type = 'MSDS'          
	  LEFT JOIN SPD_Item_Master_Languages as silE with(nolock) on silE.Michaels_SKU = ii.MichaelsSKU and silE.Language_Type_ID = 1 -- ENGLISH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages as silF with(nolock) on silF.Michaels_SKU = ii.MichaelsSKU and silF.Language_Type_ID = 2 -- FRENCH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages as silS with(nolock) on silS.Michaels_SKU = ii.MichaelsSKU and silS.Language_Type_ID = 3 -- SPANISH Language Fields             
	  LEFT JOIN SPD_Item_Master_Languages_Supplier as silEs with(nolock) on silEs.Michaels_SKU = ii.MichaelsSKU and silEs.Vendor_Number = ii.VendorNumber and silEs.Language_Type_ID = 1 -- ENGLISH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages_Supplier as silFs with(nolock) on silFs.Michaels_SKU = ii.MichaelsSKU and silFs.Vendor_Number = ii.VendorNumber and silFs.Language_Type_ID = 2 -- FRENCH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages_Supplier as silSs with(nolock) on silSs.Michaels_SKU = ii.MichaelsSKU and silSs.Vendor_Number = ii.VendorNumber and silSs.Language_Type_ID = 3 -- SPANISH Language Fields             
	  LEFT OUTER JOIN List_Values as lv with(nolock) on lv.List_Value_Group_ID = 16 And ii.Private_Brand_Label = lv.List_Value        
  WHERE b.Batch_Type_ID = 2 
	and	(@startDate is null or (@startDate is not null and b.date_modified >= @startDate))      
	and (@endDate is null or (@endDate is not null and b.date_modified <= @endDate))      
	and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept))      
	and (COALESCE(ws.Workflow_id, 1) = 1 and COALESCE(ws.Stage_Type_id, 1) = 4)   
	and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and b.Vendor_Number = @vendor))    
	and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and b.Vendor_Number = @vendorFilter))            
	and (isnull(@approver, 0) = 0 or (isnull(@approver, 0) > 0 and b.ID in (SELECT distinct spd_batch_ID from SPD_Batch_History WHERE modified_user = @approver)))      
END

IF (@workflowId = 2)
BEGIN

	SELECT simi.ID, simi.Batch_ID, simi.Date_Created, b.Date_Modified, 
	    (SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = b.Created_User) as [Created User],
	    'System' as Update_User,
		b.Date_Created as Date_Submitted, 
		CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'V' Then 'YES' Else 'NO' END as [Vendor], CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'A' Then 'YES' Else 'NO' END as [Merch_Burden], 
		v.Agent_Type as Merch_Burden_Type, s.Buyer, s.Buyer_Fax as [Fax],
		su.First_Name + ' ' + su.Last_Name as [Entered_By], 
		s.Season, s.SKU_Group, s.Buyer_Email,
		b.Date_Created as [Entered_Date], 
		s.Department_Num, s.Class_Num, s.Sub_Class_Num, upc.UPC as Primary_UPC, s.Michaels_SKU as SKU, 
		(SELECT     COUNT(*) AS Expr1
			FROM          dbo.SPD_Item_Master_Vendor_UPCs AS UPC2
            WHERE      (Michaels_SKU = s.Michaels_SKU) AND (Vendor_Number = V.Vendor_Number) AND (Primary_Indicator = 0)) AS AdditionalUPCs, --TODO: Figure out how to handle multiple UPC stuff..
		s.Pack_SKU, s.Planogram_Name, v.Vendor_Number,
		'EDIT ITEM' as Item_Task, 
		s.Item_Desc as [Description], 
		v.PaymentTerms as Payment_Terms, v.Days,v.Vendor_Min_Order_Amount, v.Vendor_Name, v.Vendor_Address1, v.Vendor_Address2, v.Vendor_Address3, v.Vendor_Address4,
		v.Vendor_Contact_Name, v.Vendor_Contact_Phone, v.Vendor_Contact_Email, v.Vendor_Contact_Fax,
		v.Manufacture_Name, v.Manufacture_Address1, v.Manufacture_Address2, v.Manufacture_Contact, v.Manufacture_Phone, v.Manufacture_Email, v.Manufacture_Fax,
		v.Agent_Contact, v.Agent_Phone, v.Agent_Email, v.Agent_Fax, v.Vendor_Style_Num as [Vendor_Style_Number], v.Harmonized_CodeNumber as [Harmonized_Code_Number],
		v.Canada_Harmonized_CodeNumber as [Canada_Harmonized_CodeNumber],
		v.Detail_Invoice_Customs_Desc0 as Detail_Invoice_Customs_Desc, v.Component_Material_Breakdown, v.Component_Construction_Method, v.Individual_Item_Packaging,
		C.Eaches_Master_Case, C.Eaches_Inner_Pack,
		C.Each_Case_Length as Each_Carton_Dimensions_Length,
		C.Each_Case_Width as Each_Carton_Dimensions_Width,
		C.Each_Case_Height as Each_Carton_Dimensions_Height,
		C.Each_Case_Cube as Cubic_Feet_Per_Each_Carton, 
		C.Each_Case_Weight as Weight_Each_Carton,
		C.Inner_Case_Weight as Each_Piece_Net_Weight_Lbs_Per_Ounce, 
		C.Inner_Case_Length as Reshippable_Inner_Carton_Length,
		C.Inner_Case_Width as Reshippable_Inner_Carton_Width, 
		C.Inner_Case_Height as Reshippable_Inner_Carton_Height, 
		C.Master_Case_Length as Master_Carton_Dimensions_Length,
		C.Master_Case_Width as Master_Carton_Dimensions_Width,
		C.Master_Case_Height as Master_Carton_Dimensions_Height,
		C.Master_Case_Cube as Cubic_Feet_Per_Master_Carton, 
		C.Master_Case_Weight as Weight_Master_Carton,
		C.Inner_Case_Cube as Cubic_Feet_Per_Inner_Carton,
		V.FOB_Shipping_Point, V.Duty_Percent, V.Duty_Amount, V.Additional_Duty_Comment, V.Additional_Duty_Amount, V.Ocean_Freight_Amount,  V.Ocean_Freight_Computed_Amount,
		V.Agent_Commission_Percent As Merch_Burden_Percent, V.Agent_Commission_Amount As Merch_Burden_Amount, V.Other_Import_Costs_Percent, V.Other_Import_Costs_Amount, V.Packaging_Cost_Amount,
		C.Import_Burden AS Import_Burden,  V.Warehouse_Landed_Cost, V.Purchase_Order_Issued_To, V.Shipping_Point, C.Country_Of_Origin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS Country_Of_Origin_Name,
		V.Vendor_Comments, s.Stock_Category, V.Freight_Terms, 
		UPPER(s.Item_Type) as Item_Type, UPPER(s.Item_Type) AS Pack_Item_Indicator,
		s.Item_Type_Attribute, UPPER(s.Allow_Store_Order) AS Allow_Store_Order, UPPER(s.Inventory_Control) as Inventory_Control, 
		UPPER(s.Auto_Replenish) AS Auto_Replenish, 
		CASE WHEN (SELECT COUNT(*) FROM  SPD_Item_Master_UDA UDA4 WHERE  UDA4.Michaels_SKU = s.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS Pre_Priced,
		(SELECT TOP (1) ISNULL(UDA_Value, 0) AS Expr1 FROM SPD_Item_Master_UDA AS UDA5 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 10)) AS Pre_Priced_UDA,
		(SELECT TOP (1) UDA_ID FROM SPD_Item_Master_UDA AS UDA2 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_UDA,
		(SELECT TOP (1) UDA_Value FROM SPD_Item_Master_UDA AS UDA3 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_Value_UDA,
		s.STOCKING_STRATEGY_CODE, --s.Hybrid_Type, s.Hybrid_Source_DC as Sourcing_DC, 
		s.Store_Supplier_Zone_Group as Store_Supp_Zone_GRP, s.WHS_Supplier_Zone_Group as Whse_Supp_Zone_GRP, s.POG_Max_Qty, s.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store,
		v.Outbound_Freight, v.Nine_Percent_Whse_Charge, v.Total_Store_Landed_Cost, s.Base1_Retail, s.Base2_Retail, s.Test_Retail, s.Alaska_Retail,
		s.Canada_Retail, s.High2_Retail, s.High3_Retail, s.Small_Market_Retail, s.High1_Retail, s.Base3_Retail, s.Low1_Retail, s.Low2_Retail, s.Manhattan_Retail, s.Quebec_Retail as Q5_Retail,
		s.PuertoRico_Retail as PR_Retail,  
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'Y' Then 'X' Else '' END as Haz_Mat_Yes, 
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'N' Then 'X' Else '' END as Haz_Mat_No, 
		V.Hazardous_Manufacturer_Country as Haz_Mat_MFG_Country, V.Hazardous_Manufacturer_Name as Haz_Mat_MFG_Name, UPPER(s.Hazardous_Flammable) as Haz_Mat_MFG_Flammable,
		V.Hazardous_Manufacturer_City as Haz_Mat_MFG_City, UPPER(s.Hazardous_Container_Type) as Haz_Mat_Container_Type, V.Hazardous_Manufacturer_State as Haz_Mat_MFG_State,
		s.Hazardous_Container_Size as Haz_Mat_Container_Size, V.Hazardous_Manufacturer_Phone as Haz_Mat_MFG_Phone, UPPER(s.Hazardous_MSDS_UOM) as Haz_Mat_MSDS_UOM,
		s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
		s.Original_Visa, s.Textile_Declaration_Mid_Code, s.Quota_Charge_Statement, s.MSDS, s.TSCA, s.Drop_Bal_lTest_Cert as Drop_Ball_Test_Cert,
		s.Man_Medical_Device_Listing, s.Man_FDA_Registration, s.Copy_Right_Indemnification, s.Fish_Wild_Life_Cert, s.Proposition_65_Label_Req, s.CCCR,
		s.Formaldehyde_Compliant, s.RMS_Sellable, s.RMS_Orderable, s.RMS_Inventory, PKI.Pack_SKU as Parent_ID, 
		CASE WHEN UPPER(COALESCE(s.Pack_Item_Indicator,'')) = 'Y' Then 'NO' Else 'YES' END as Regular_Batch_Item, --TODO: Verify this is correct?
		s.Store_Total, 
		s.Displayer_Cost, C.Unit_Cost as Product_Cost, 
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=item_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS Private_Brand_Label,
		s.QuoteReferenceNumber as Quote_Reference_Number, s.Customs_Description,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, simlF.Description_Short as French_Short_Description,    
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, simlS.Description_Long as Spanish_Long_Description          
	FROM SPD_Item_Maint_Items as simi with(nolock) 
		INNER JOIN SPD_Batch as b with(nolock) on b.ID = simi.Batch_ID
		INNER JOIN SPD_Item_Master_SKU as s with(nolock) on s.Michaels_SKU = simi.Michaels_SKU
		INNER JOIN SPD_Item_Master_Vendor as v with(nolock) on v.Michaels_SKU = simi.Michaels_SKU and v.Vendor_Number = simi.Vendor_Number
		INNER JOIN SPD_Vendor as sv with(nolock) on sv.Vendor_Number = v.Vendor_Number	
		Left Outer Join Security_User as su with(nolock) on su.ID = b.Created_User
		LEFT OUTER JOIN SPD_Item_Master_Vendor_UPCs AS UPC with(nolock) ON v.Michaels_SKU = UPC.Michaels_SKU AND v.Vendor_Number = UPC.Vendor_Number AND UPC.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_Item_Master_Vendor_Countries AS C with(nolock) ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND C.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_COUNTRY AS CO with(nolock) ON CO.COUNTRY_CODE = C.Country_Of_Origin
		LEFT OUTER JOIN SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 2
		LEFT OUTER JOIN SPD_Item_Master_PackItems AS PKI with(nolock) ON s.Michaels_SKU = PKI.Child_SKU AND B.Pack_SKU = PKI.Pack_SKU   
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = v.Image_ID and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = v.MSDS_ID and f2.File_Type = 'MSDS'          
		LEFT JOIN SPD_Item_Master_Languages as simlE with(nolock) on simlE.Michaels_SKU = s.Michaels_SKU and simlE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlF with(nolock) on simlF.Michaels_SKU = s.Michaels_SKU and simlF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlS with(nolock) on simlS.Michaels_SKU = s.Michaels_SKU  and simlS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsE with(nolock) on simlsE.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsF.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsS.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
	WHERE b.Enabled = 1 AND sv.Vendor_Type = 300  and b.Batch_Type_ID=2
		and (@startDate is null or (@startDate is not null and b.Date_Modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.Date_Modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and s.Department_Num = @dept))        
		and ws.Workflow_id = 2 and COALESCE(ws.Stage_Type_id, 1) = 4
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and v.Vendor_Number = @vendor))
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and v.Vendor_Number = @vendorFilter))            
	    and (isnull(@approver, 0) = 0 or (isnull(@approver, 0) > 0 and b.ID in (SELECT distinct spd_batch_ID from SPD_Batch_History WHERE modified_user = @approver)))      
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SPD_Import_Item_SaveRecord]    Script Date: 01/22/2018 14:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_SPD_Import_Item_SaveRecord] 
	@ID bigint OUTPUT,
	@Batch_ID bigint,
	@DateSubmitted datetime = null,
	@Vendor varchar(100) = null,
	@Agent varchar(100) = null,
	@AgentType varchar(20) = null,
	@Buyer varchar(100) = null,
	@Fax varchar(100) = null,
	@EnteredBy varchar(100) = null,
	@SKUGroup varchar(100) = null,
	@Email varchar(100) = null,
	@EnteredDate datetime = null,
	@Dept varchar(100) = null,
	@Class varchar(100) = null,
	@SubClass varchar(100) = null,
	@PrimaryUPC varchar(100) = null,
	@MichaelsSKU varchar(100) = null,
	@GenerateMichaelsUPC varchar(1) = null,
	@AdditionalUPC1 varchar(100) = null,
	@AdditionalUPC2 varchar(100) = null,
	@AdditionalUPC3 varchar(100) = null,
	@AdditionalUPC4 varchar(100) = null,
	@AdditionalUPC5 varchar(100) = null,
	@AdditionalUPC6 varchar(100) = null,
	@AdditionalUPC7 varchar(100) = null,
	@AdditionalUPC8 varchar(100) = null,
	@PackSKU varchar(100) = null,
	@PlanogramName varchar(100) = null,
	@VendorNumber varchar(100) = null,
	@VendorRank varchar(100) = null,
	@ItemTask varchar(100) = null,
	@Description varchar(100) = null,
	@Days varchar(20) = null,
	@VendorMinOrderAmount varchar(20) = null,
	@VendorContactName varchar(100) = null,
	@VendorContactPhone varchar(100) = null,
	@VendorContactEmail varchar(100) = null,
	@VendorContactFax varchar(100) = null,
	@ManufactureContact varchar(100) = null,
	@ManufacturePhone varchar(100) = null,
	@ManufactureEmail varchar(100) = null,
	@ManufactureFax varchar(100) = null,
	@AgentContact varchar(100) = null,
	@AgentPhone varchar(100) = null,
	@AgentEmail varchar(100) = null,
	@AgentFax varchar(100) = null,
	@VendorStyleNumber varchar(100) = null,
	@HarmonizedCodeNumber varchar(100) = null,
	@DetailInvoiceCustomsDesc varchar(max) = null,
	@ComponentMaterialBreakdown varchar(max) = null,
	@ComponentConstructionMethod varchar(max) = null,
	@IndividualItemPackaging varchar(100) = null,
	@EachInsideMasterCaseBox varchar(100) = null,
	@EachInsideInnerPack varchar(100) = null,
	--@EachPieceNetWeightLbsPerOunce varchar(100) = null,
	@ReshippableInnerCartonWeight decimal(18,6) = Null,
	@ReshippableInnerCartonLength varchar(100) = null,
	@ReshippableInnerCartonWidth varchar(100) = null,
	@ReshippableInnerCartonHeight varchar(100) = null,
	@MasterCartonDimensionsLength varchar(100) = null,
	@MasterCartonDimensionsWidth varchar(100) = null,
	@MasterCartonDimensionsHeight varchar(100) = null,
	@CubicFeetPerMasterCarton varchar(100) = null,
	@WeightMasterCarton varchar(100) = null,
	@CubicFeetPerInnerCarton varchar(100) = null,
	@FOBShippingPoint varchar(100) = null,
	@DutyPercent varchar(100) = null,
	@DutyAmount varchar(100) = null,
	@AdditionalDutyComment varchar(100) = null,
	@AdditionalDutyAmount varchar(100) = null,
	@OceanFreightAmount varchar(100) = null,
	@OceanFreightComputedAmount varchar(100) = null,
	@AgentCommissionPercent varchar(100) = null,
	@AgentCommissionAmount varchar(100) = null,
	@OtherImportCostsPercent varchar(100) = null,
	@OtherImportCostsAmount varchar(100) = null,
	@PackagingCostAmount varchar(100) = null,
	@TotalImportBurden varchar(100) = null,
	@WarehouseLandedCost varchar(100) = null,
	@PurchaseOrderIssuedTo varchar(max) = null,
	@ShippingPoint varchar(100) = null,
	@CountryOfOrigin varchar(100) = null,
	@CountryOfOriginName varchar(50) = null,
	@VendorComments varchar(max) = null,
	@StockCategory varchar(20) = null,
	@FreightTerms varchar(20) = null,
	@ItemType varchar(20) = null,
	@PackItemIndicator varchar(20) = null,
	@ItemTypeAttribute varchar(20) = null,
	@AllowStoreOrder varchar(20) = null,
	@InventoryControl varchar(20) = null,
	@AutoReplenish varchar(20) = null,
	@PrePriced varchar(20) = null,
	@TaxUDA varchar(20) = null,
	@PrePricedUDA varchar(20) = null,
	@TaxValueUDA varchar(20) = null,
	@HybridType varchar(20) = null,
	@SourcingDC varchar(20) = null,
	@LeadTime varchar(20) = null,
	@ConversionDate datetime = null,
	@StoreSuppZoneGRP varchar(20) = null,
	@WhseSuppZoneGRP varchar(20) = null,
	@POGMaxQty varchar(20) = null,
	@POGSetupPerStore varchar(20) = null,
	@ProjSalesPerStorePerMonth varchar(20) = null,
	@OutboundFreight varchar(20) = null,
	@NinePercentWhseCharge varchar(20) = null,
	@TotalStoreLandedCost varchar(20) = null,
	@RDBase varchar(20) = null,
	@RDCentral varchar(20) = null,
	@RDTest varchar(20) = null,
	@RDAlaska varchar(20) = null,
	@RDCanada varchar(20) = null,
	@RD0Thru9 varchar(20) = null,
	@RDCalifornia varchar(20) = null,
	@RDVillageCraft varchar(20) = null,
	@Retail9 money,
	@Retail10 money,
	@Retail11 money,
	@Retail12 money,
	@Retail13 money,
	@RDQuebec money = null,
	@RDPuertoRico money = null,
	@HazMatYes varchar(1) = null,
	@HazMatNo varchar(1) = null,
	@HazMatMFGCountry varchar(40) = null,
	@HazMatMFGName varchar(40) = null,
	@HazMatMFGFlammable varchar(40) = null,
	@HazMatMFGCity varchar(40) = null,
	@HazMatContainerType varchar(40) = null,
	@HazMatMFGState varchar(40) = null,
	@HazMatContainerSize varchar(40) = null,
	@HazMatMFGPhone varchar(40) = null,
	@HazMatMSDSUOM varchar(40) = null,
	@TSSA varchar(1) = null,
	@CSA varchar(1) = null,
	@UL varchar(1) = null,
	@LicenceAgreement varchar(1) = null,
	@FumigationCertificate varchar(1) = null,
	@KILNDriedCertificate varchar(1) = null,
	@ChinaComInspecNumAndCCIBStickers varchar(1) = null,
	@OriginalVisa varchar(1) = null,
	@TextileDeclarationMidCode varchar(1) = null,
	@QuotaChargeStatement varchar(1) = null,
	@MSDS varchar(1) = null,
	@TSCA varchar(1) = null,
	@DropBallTestCert varchar(1) = null,
	@ManMedicalDeviceListing varchar(1) = null,
	@ManFDARegistration varchar(1) = null,
	@CopyRightIndemnification varchar(1) = null,
	@FishWildLifeCert varchar(1) = null,
	@Proposition65LabelReq varchar(1) = null,
	@CCCR varchar(1) = null,
	@FormaldehydeCompliant varchar(1) = null,
	@QuoteSheetStatus varchar(20) = null,
	@Season varchar(20) = null,
	@PaymentTerms varchar(20) = null,
	@VendorName varchar(100) = null,
	@VendorAddress1 varchar(100) = null,
	@VendorAddress2 varchar(100) = null,
	@VendorAddress3 varchar(100) = null,
	@VendorAddress4 varchar(100) = null,
	@ManufactureName varchar(100) = null,
	@ManufactureAddress1 varchar(100) = null,
	@ManufactureAddress2 varchar(100) = null,
	@UserID int,
	@Batch_Action varchar(50) = null,
	@Batch_Notes varchar(max) = null,
	@RMS_Sellable varchar(1) = null,
	@RMS_Orderable varchar(1) = null,
	@RMS_Inventory varchar(1) = null,
	@Parent_ID bigint = 0,
	@RegularBatchItem bit = 0,
	@Displayer_Cost decimal(18,6) = null,
	@Product_Cost decimal(18,6) = null,
	@Store_Total int = null,
	@POG_Start_Date datetime = null,
	@POG_Comp_Date datetime = null,
	@Calculate_Options int = 0,
	@Like_Item_SKU varchar(20) = null,
	@Like_Item_Description varchar(255) = null,
	@Like_Item_Retail money = null,
	@Annual_Regular_Unit_Forecast decimal(18,6) = null,
	@Like_Item_Store_Count decimal(18,6) = null,
	@Like_Item_Regular_Unit decimal(18,6) = null,
	@Like_Item_Unit_Store_Month decimal(18,6) = null,
	@Annual_Reg_Retail_Sales decimal(18,6) = null,
	@Facings decimal(18,6) = null,
	@Min_Pres_Per_Facing decimal(18,6) = null,
	@Inner_Pack decimal(18,6) = null,
	@POG_Min_Qty decimal(18,3) = null,
	@Private_Brand_Label varchar(20) = null,
	@Discountable varchar(1) = null,
	@Qty_In_Pack int = null, 
	@Valid_Existing_SKU bit = null,
	@Item_Status varchar(10) = null,
	@SkipInvalidatingPackChildren bit = 0, 
	@QuoteReferenceNumber varchar(20) = null,
	@CustomsDescription varchar(255) = null, 
	@IsDirty bit = 1,
	@Stocking_Strategy_Code nvarchar(5) = Null,
	@eachheight decimal(18,6) = Null,
	@eachwidth decimal(18,6) = Null,
	@eachlength decimal(18,6) = Null,
	@eachweight decimal(18,6) = Null,
	@cubicfeeteach decimal(18,6) = Null,
	@CanadaHarmonizedCodeNumber varchar(10) = Null
	
AS
	SET NOCOUNT ON

	DECLARE @CurrentDate datetime,
			@BatchImportItemType smallint

    SET @CurrentDate = getdate()
	SET @BatchImportItemType = 2

  DECLARE @Vendor_Num int,
					@Vendor_Name varchar(50),
					@Department_ID int

  SET @Vendor_Num = Cast(@VendorNumber as int)
	SET @Vendor_Name = Left(@VendorName, 50)
	SET @Department_ID = @Dept

	--BEGIN calculate RecAgentCommissionPercent 
	DECLARE @RecAgentCommissionPercent varchar(100)
	SET @RecAgentCommissionPercent = Null
	
	--only do this if they have agent selected
	IF (@Agent is not null and @Agent <> '')
	BEGIN
		DECLARE @IsPrivateBrand bit
		SET @IsPrivateBrand = 0
		If coalesce(@Private_Brand_Label,'') <> '12'
		BEGIN
			SET @IsPrivateBrand = 1
		END
		
		Select @RecAgentCommissionPercent = default_rate
		from Import_Burden_Default_Exceptions IBDE
		where ltrim(rtrim(upper(IBDE.Agent_Name))) = ltrim(rtrim(upper(@AgentType)))
		and coalesce(IBDE.Private_brand_flag,0) = @IsPrivateBrand
		and IBDE.dept = @Dept and @Dept is not null and @AgentType is not null
		
		IF @RecAgentCommissionPercent is null
		BEGIN
			Select @RecAgentCommissionPercent = default_rate 
			from Import_Burden_Defaults IBD
			where ltrim(rtrim(upper(IBD.Agent_Name))) = ltrim(rtrim(upper(@AgentType)))
			and coalesce(IBD.Private_brand_flag,0) = @IsPrivateBrand 
		END	
	END
	
	--END calculate RecAgentCommissionPercent

	IF EXISTS(SELECT 1 FROM [dbo].[SPD_Import_Items] where [ID] = @ID)
	BEGIN
		-- update record
		UPDATE [dbo].[SPD_Import_Items] SET 
			Batch_ID = @Batch_ID,
			DateSubmitted = @DateSubmitted,
			Vendor = @Vendor,
			Agent = @Agent,
			AgentType = @AgentType,
			Buyer = @Buyer,
			Fax = @Fax,
			EnteredBy = @EnteredBy,
			SKUGroup = @SKUGroup,
			Email = @Email,
			EnteredDate = @EnteredDate,
			Dept = @Dept,
			Class = @Class,
			SubClass = @SubClass,
			PrimaryUPC = @PrimaryUPC,
			MichaelsSKU = @MichaelsSKU,
			GenerateMichaelsUPC = @GenerateMichaelsUPC,
			AdditionalUPC1 = @AdditionalUPC1,
			AdditionalUPC2 = @AdditionalUPC2,
			AdditionalUPC3 = @AdditionalUPC3,
			AdditionalUPC4 = @AdditionalUPC4,
			AdditionalUPC5 = @AdditionalUPC5,
			AdditionalUPC6 = @AdditionalUPC6,
			AdditionalUPC7 = @AdditionalUPC7,
			AdditionalUPC8 = @AdditionalUPC8,
			PackSKU = @PackSKU,
			PlanogramName = @PlanogramName,
			VendorNumber = @VendorNumber,
			VendorRank = @VendorRank,
			ItemTask = @ItemTask,
			Description = @Description,
			Days = @Days,
			VendorMinOrderAmount = @VendorMinOrderAmount,
			VendorContactName = @VendorContactName,
			VendorContactPhone = @VendorContactPhone,
			VendorContactEmail = @VendorContactEmail,
			VendorContactFax = @VendorContactFax,
			ManufactureContact = @ManufactureContact,
			ManufacturePhone = @ManufacturePhone,
			ManufactureEmail = @ManufactureEmail,
			ManufactureFax = @ManufactureFax,
			AgentContact = @AgentContact,
			AgentPhone = @AgentPhone,
			AgentEmail = @AgentEmail,
			AgentFax = @AgentFax,
			VendorStyleNumber = @VendorStyleNumber,
			HarmonizedCodeNumber = @HarmonizedCodeNumber,
			DetailInvoiceCustomsDesc = @DetailInvoiceCustomsDesc,
			ComponentMaterialBreakdown = @ComponentMaterialBreakdown,
			ComponentConstructionMethod = @ComponentConstructionMethod,
			IndividualItemPackaging = @IndividualItemPackaging,
			EachInsideMasterCaseBox = @EachInsideMasterCaseBox,
			EachInsideInnerPack = @EachInsideInnerPack,
			--EachPieceNetWeightLbsPerOunce = @EachPieceNetWeightLbsPerOunce,
			ReshippableInnerCartonWeight = @ReshippableInnerCartonWeight,
			ReshippableInnerCartonLength = @ReshippableInnerCartonLength,
			ReshippableInnerCartonWidth = @ReshippableInnerCartonWidth,
			ReshippableInnerCartonHeight = @ReshippableInnerCartonHeight,
			MasterCartonDimensionsLength = @MasterCartonDimensionsLength,
			MasterCartonDimensionsWidth = @MasterCartonDimensionsWidth,
			MasterCartonDimensionsHeight = @MasterCartonDimensionsHeight,
			CubicFeetPerMasterCarton = @CubicFeetPerMasterCarton,
			WeightMasterCarton = @WeightMasterCarton,
			CubicFeetPerInnerCarton = @CubicFeetPerInnerCarton,
			FOBShippingPoint = @FOBShippingPoint,
			DutyPercent = @DutyPercent,
			DutyAmount = @DutyAmount,
			AdditionalDutyComment = @AdditionalDutyComment,
			AdditionalDutyAmount = @AdditionalDutyAmount,
			OceanFreightAmount = @OceanFreightAmount,
			OceanFreightComputedAmount = @OceanFreightComputedAmount,
			AgentCommissionPercent = @AgentCommissionPercent,
			AgentCommissionAmount = @AgentCommissionAmount,
			OtherImportCostsPercent = @OtherImportCostsPercent,
			OtherImportCostsAmount = @OtherImportCostsAmount,
			PackagingCostAmount = @PackagingCostAmount,
			TotalImportBurden = @TotalImportBurden,
			WarehouseLandedCost = @WarehouseLandedCost,
			PurchaseOrderIssuedTo = @PurchaseOrderIssuedTo,
			ShippingPoint = @ShippingPoint,
			CountryOfOrigin = @CountryOfOrigin,
			CountryOfOriginName = @CountryOfOriginName,
			VendorComments = @VendorComments,
			StockCategory = @StockCategory,
			FreightTerms = @FreightTerms,
			ItemType = @ItemType,
			PackItemIndicator = @PackItemIndicator,
			ItemTypeAttribute = @ItemTypeAttribute,
			AllowStoreOrder = @AllowStoreOrder,
			InventoryControl = @InventoryControl,
			AutoReplenish = @AutoReplenish,
			PrePriced = @PrePriced,
			TaxUDA = @TaxUDA,
			PrePricedUDA = @PrePricedUDA,
			TaxValueUDA = @TaxValueUDA,
			HybridType = @HybridType,
			SourcingDC = @SourcingDC,
			LeadTime = @LeadTime,
			ConversionDate = @ConversionDate,
			StoreSuppZoneGRP = @StoreSuppZoneGRP,
			WhseSuppZoneGRP = @WhseSuppZoneGRP,
			POGMaxQty = @POGMaxQty,
			POGSetupPerStore = @POGSetupPerStore,
			ProjSalesPerStorePerMonth = @ProjSalesPerStorePerMonth,
			OutboundFreight = @OutboundFreight,
			NinePercentWhseCharge = @NinePercentWhseCharge,
			TotalStoreLandedCost = @TotalStoreLandedCost,
			RDBase = @RDBase,
			RDCentral = @RDCentral,
			RDTest = @RDTest,		
			RDAlaska = @RDAlaska,			
			RDCanada = @RDCanada,			
			RD0Thru9 = @RD0Thru9,
			RDCalifornia = @RDCalifornia,
			RDVillageCraft = @RDVillageCraft,
			Retail9 = @Retail9,
			Retail10 = @Retail10,
			Retail11 = @Retail11,
			Retail12 = @Retail12,
			Retail13 = @Retail13,
			RDQuebec = @RDQuebec,
			RDPuertoRico = @RDPuertoRico,
			HazMatYes = @HazMatYes,
			HazMatNo = @HazMatNo,
			HazMatMFGCountry = @HazMatMFGCountry,
			HazMatMFGName = @HazMatMFGName,
			HazMatMFGFlammable = @HazMatMFGFlammable,
			HazMatMFGCity = @HazMatMFGCity,
			HazMatContainerType = @HazMatContainerType,
			HazMatMFGState = @HazMatMFGState,
			HazMatContainerSize = @HazMatContainerSize,
			HazMatMFGPhone = @HazMatMFGPhone,
			HazMatMSDSUOM = @HazMatMSDSUOM,
			TSSA = @TSSA,
			CSA = @CSA,
			UL = @UL,
			LicenceAgreement = @LicenceAgreement,
			FumigationCertificate = @FumigationCertificate,
			KILNDriedCertificate = @KILNDriedCertificate,
			ChinaComInspecNumAndCCIBStickers = @ChinaComInspecNumAndCCIBStickers,
			OriginalVisa = @OriginalVisa,
			TextileDeclarationMidCode = @TextileDeclarationMidCode,
			QuotaChargeStatement = @QuotaChargeStatement,
			MSDS = @MSDS,
			TSCA = @TSCA,
			DropBallTestCert = @DropBallTestCert,
			ManMedicalDeviceListing = @ManMedicalDeviceListing,
			ManFDARegistration = @ManFDARegistration,
			CopyRightIndemnification = @CopyRightIndemnification,
			FishWildLifeCert = @FishWildLifeCert,
			Proposition65LabelReq = @Proposition65LabelReq,
			CCCR = @CCCR,
			FormaldehydeCompliant = @FormaldehydeCompliant,
			QuoteSheetStatus = @QuoteSheetStatus,
			Season = @Season,
			PaymentTerms = @PaymentTerms,
			VendorName = @VendorName,
			VendorAddress1 = @VendorAddress1,
			VendorAddress2 = @VendorAddress2,
			VendorAddress3 = @VendorAddress3,
			VendorAddress4 = @VendorAddress4,
			ManufactureName = @ManufactureName,
			ManufactureAddress1 = @ManufactureAddress1,
			ManufactureAddress2 = @ManufactureAddress2,
			RMS_Sellable = @RMS_Sellable,
			RMS_Orderable = @RMS_Orderable,
			RMS_Inventory = @RMS_Inventory,
			Parent_ID = @Parent_ID,
			RegularBatchItem = @RegularBatchItem,
			UpdateUserID = @UserID,
			Displayer_Cost = @Displayer_Cost,
			Product_Cost = @Product_Cost,
			Store_Total = @Store_Total,
			POG_Start_Date = @POG_Start_Date,
			POG_Comp_Date = @POG_Comp_Date,
			Calculate_Options = @Calculate_Options,
			Like_Item_SKU = @Like_Item_SKU,
			Like_Item_Description = @Like_Item_Description,
			Like_Item_Retail = @Like_Item_Retail,
			Annual_Regular_Unit_Forecast = @Annual_Regular_Unit_Forecast,
			Like_Item_Store_Count = @Like_Item_Store_Count,
			Like_Item_Regular_Unit = @Like_Item_Regular_Unit,
			Like_Item_Unit_Store_Month = @Like_Item_Unit_Store_Month,
			Annual_Reg_Retail_Sales = @Annual_Reg_Retail_Sales,
			Facings = @Facings,
			Min_Pres_Per_Facing = @Min_Pres_Per_Facing,
			Inner_Pack = @Inner_Pack,
			POG_Min_Qty = @POG_Min_Qty,
			Private_Brand_Label = @Private_Brand_Label,
			Discountable = @Discountable,
			Qty_In_Pack = @Qty_In_Pack, 
			Valid_Existing_SKU = @Valid_Existing_SKU,
			Item_Status = @Item_Status, 
			QuoteReferenceNumber = @QuoteReferenceNumber,
			Customs_Description = @CustomsDescription,
			RecAgentCommissionPercent = @RecAgentCommissionPercent,
			Stocking_Strategy_Code = @Stocking_Strategy_Code,
			eachheight = @eachheight,
			eachwidth = @eachwidth,
			eachlength = @eachlength,
			eachweight = @eachweight,
			cubicfeeteach = @cubicfeeteach,
			CanadaHarmonizedCodeNumber = @CanadaHarmonizedCodeNumber
		WHERE 
			[ID] = @ID
		--LP Spedy Order 12, enforce calc options of childern on Like Item
		IF (@Parent_ID = 0)
		BEGIN
		--NAK 12/5/2012: Per Srilatha @ Michaels, MSS Quotes should not have the Forecast Type overwritten for Child items.
			IF (Coalesce(@QuoteReferenceNumber,'') = '')
			BEGIN
				update [dbo].[SPD_Import_Items] SET
					Calculate_Options = @Calculate_Options,
					Store_Total = @Store_Total,
					POG_Start_Date = @POG_Start_Date,
					POG_Comp_Date = @POG_Comp_Date
				where Batch_ID = @Batch_ID and Parent_ID > 0
			END
			Else
			BEGIN
				update [dbo].[SPD_Import_Items] SET
					Store_Total = @Store_Total,
					POG_Start_Date = @POG_Start_Date,
					POG_Comp_Date = @POG_Comp_Date
				where Batch_ID = @Batch_ID and Parent_ID > 0
			END
				
		End
		
		-- update [dbo].[SPD_Import_Items] SET
		declare @str varchar(20)
		set @str = COALESCE(RTRIM(REPLACE(LEFT(COALESCE(@PackItemIndicator, ''),2), '-', '')), '')
		if ( ISNULL(@Batch_ID, 0) > 0 and (@str = 'D' or @str = 'DP') and (@SkipInvalidatingPackChildren != 1) )
		begin
		  update [dbo].[SPD_Import_Items] SET Is_Valid = -1 where [ID] != @ID and ([Batch_ID] = @Batch_ID or [Parent_ID] = @ID) and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(PackItemIndicator, ''),2), '-', '')), '') NOT IN ('D', 'DP')
		end
		
		-- update batch ??
		IF (ISNULL(@Batch_ID, 0) > 0 and @Parent_ID = 0)
		BEGIN

			update [dbo].[SPD_Batch] set 
				Vendor_Name = @Vendor_Name,
				Vendor_Number = @Vendor_Num,
				Fineline_Dept_ID = @Department_ID,
				date_modified = @CurrentDate,
				modified_user = @UserID
			where [ID] = @Batch_ID
		END
		
		-- update date modified?
		IF (@IsDirty = 1)
		BEGIN
			UPDATE [dbo].[SPD_Import_Items] SET
			DateLastModified = @CurrentDate
			WHERE [ID] = @ID
		
		END

	END
	ELSE
	BEGIN

		-- insert into batch ??
		IF (ISNULL(@Batch_ID, 0) <= 0 and @Parent_ID = 0)
		BEGIN

			INSERT INTO [dbo].[SPD_Batch](
				Vendor_Name,
				Vendor_Number,
				Batch_Type_ID,
				WorkFlow_Stage_ID,
				Fineline_Dept_ID,
				date_created,
				created_user,
				date_modified,
				modified_user
			) values (
				@Vendor_Name,
				@Vendor_Num,
				@BatchImportItemType,
				1,
				@Department_ID,
				@CurrentDate,
				@UserID,
				@CurrentDate,
				@UserID
			)
			
			SET @Batch_ID = SCOPE_IDENTITY()

			-- insert into batch history
			INSERT INTO [dbo].[SPD_Batch_History](
				spd_batch_id,
				workflow_stage_id,
				[action],
				modified_user,
				date_modified,
				notes
			) values (
				@Batch_ID,
				1,
				@Batch_Action,
				@UserID,
				@CurrentDate,
				@Batch_Notes
			)
			
			--Insert Into Batch History Stage Durations table if Action was "Created" or "Uploaded"
			If @Batch_Action = 'Created' or @Batch_Action = 'Uploaded' AND Not EXISTS(SELECT 1 FROM SPD_Batch_History_Stage_Durations Where Batch_ID = @Batch_ID AND Stage_ID = 1)
			Begin
				INSERT INTO SPD_Batch_History_Stage_Durations(Batch_ID, Stage_ID, Start_Date, End_Date, Hours)
				VALUES(@Batch_ID, 1, getDate(), null, null)
			END
		END

		-- insert record
		INSERT INTO [dbo].[SPD_Import_Items] (
			Batch_ID,
			DateSubmitted,
			Vendor,
			Agent,
			AgentType,
			Buyer,
			Fax,
			EnteredBy,
			SKUGroup,
			Email,
			EnteredDate,
			Dept,
			Class,
			SubClass,
			PrimaryUPC,
			MichaelsSKU,
			GenerateMichaelsUPC,
			AdditionalUPC1,
			AdditionalUPC2,
			AdditionalUPC3,
			AdditionalUPC4,
			AdditionalUPC5,
			AdditionalUPC6,
			AdditionalUPC7,
			AdditionalUPC8,
			PackSKU,
			PlanogramName,
			VendorNumber,
			VendorRank,
			ItemTask,
			Description,
			Days,
			VendorMinOrderAmount,
			VendorContactName,
			VendorContactPhone,
			VendorContactEmail,
			VendorContactFax,
			ManufactureContact,
			ManufacturePhone,
			ManufactureEmail,
			ManufactureFax,
			AgentContact,
			AgentPhone,
			AgentEmail,
			AgentFax,
			VendorStyleNumber,
			HarmonizedCodeNumber,
			DetailInvoiceCustomsDesc,
			ComponentMaterialBreakdown,
			ComponentConstructionMethod,
			IndividualItemPackaging,
			EachInsideMasterCaseBox,
			EachInsideInnerPack,
			--EachPieceNetWeightLbsPerOunce,
			ReshippableInnerCartonWeight,
			ReshippableInnerCartonLength,
			ReshippableInnerCartonWidth,
			ReshippableInnerCartonHeight,
			MasterCartonDimensionsLength,
			MasterCartonDimensionsWidth,
			MasterCartonDimensionsHeight,
			CubicFeetPerMasterCarton,
			WeightMasterCarton,
			CubicFeetPerInnerCarton,
			FOBShippingPoint,
			DutyPercent,
			DutyAmount,
			AdditionalDutyComment,
			AdditionalDutyAmount,
			OceanFreightAmount,
			OceanFreightComputedAmount,
			AgentCommissionPercent,
			AgentCommissionAmount,
			OtherImportCostsPercent,
			OtherImportCostsAmount,
			PackagingCostAmount,
			TotalImportBurden,
			WarehouseLandedCost,
			PurchaseOrderIssuedTo,
			ShippingPoint,
			CountryOfOrigin,
			CountryOfOriginName,
			VendorComments,
			StockCategory,
			FreightTerms,
			ItemType,
			PackItemIndicator,
			ItemTypeAttribute,
			AllowStoreOrder,
			InventoryControl,
			AutoReplenish,
			PrePriced,
			TaxUDA,
			PrePricedUDA,
			TaxValueUDA,
			HybridType,
			SourcingDC,
			LeadTime,
			ConversionDate,
			StoreSuppZoneGRP,
			WhseSuppZoneGRP,
			POGMaxQty,
			POGSetupPerStore,
			ProjSalesPerStorePerMonth,
			OutboundFreight,
			NinePercentWhseCharge,
			TotalStoreLandedCost,
			RDBase,
			RDCentral,
			RDTest,
			RDAlaska,			
			RDCanada,			
			RD0Thru9,
			RDCalifornia,
			RDVillageCraft,
			HazMatYes,
			HazMatNo,
			HazMatMFGCountry,
			HazMatMFGName,
			HazMatMFGFlammable,
			HazMatMFGCity,
			HazMatContainerType,
			HazMatMFGState,
			HazMatContainerSize,
			HazMatMFGPhone,
			HazMatMSDSUOM,
			TSSA,
			CSA,
			UL,
			LicenceAgreement,
			FumigationCertificate,
			KILNDriedCertificate,
			ChinaComInspecNumAndCCIBStickers,
			OriginalVisa,
			TextileDeclarationMidCode,
			QuotaChargeStatement,
			MSDS,
			TSCA,
			DropBallTestCert,
			ManMedicalDeviceListing,
			ManFDARegistration,
			CopyRightIndemnification,
			FishWildLifeCert,
			Proposition65LabelReq,
			CCCR,
			FormaldehydeCompliant,
			QuoteSheetStatus,
			Season,
			PaymentTerms,
			VendorName,
			VendorAddress1,
			VendorAddress2,
			VendorAddress3,
			VendorAddress4,
			ManufactureName,
			ManufactureAddress1,
			ManufactureAddress2,
			RMS_Sellable ,
			RMS_Orderable ,
			RMS_Inventory ,
			Parent_ID ,
			RegularBatchItem ,
			DateCreated,
			CreatedUserID,
			DateLastModified,
			UpdateUserID,
			Displayer_Cost,
			Product_Cost,
			Store_Total,
			POG_Start_Date,
			POG_Comp_Date,
			Calculate_Options,
			Like_Item_SKU,
			Like_Item_Description,
			Like_Item_Retail,
			Annual_Regular_Unit_Forecast,
			Like_Item_Store_Count,
			Like_Item_Regular_Unit,
			Like_Item_Unit_Store_Month,
			Annual_Reg_Retail_Sales,
			Facings,
			Min_Pres_Per_Facing,
			Inner_Pack,
			POG_Min_Qty,
			Retail9,
			Retail10,
			Retail11,
			Retail12,
			Retail13,
			RDQuebec,
			RDPuertoRico,
			Private_Brand_Label,
			Discountable,
			Qty_In_Pack,
			Valid_Existing_SKU,
			Item_Status, 
			QuoteReferenceNumber,
			Customs_Description,
			RecAgentCommissionPercent,
			Stocking_Strategy_Code,
			eachheight,
			eachwidth,
			eachlength,
			eachweight,
			cubicfeeteach,
			CanadaHarmonizedCodeNumber
		) VALUES (
			@Batch_ID,
			@DateSubmitted,
			@Vendor,
			@Agent,
			@AgentType,
			@Buyer,
			@Fax,
			@EnteredBy,
			@SKUGroup,
			@Email,
			@EnteredDate,
			@Dept,
			@Class,
			@SubClass,
			@PrimaryUPC,
			@MichaelsSKU,
			@GenerateMichaelsUPC,
			@AdditionalUPC1,
			@AdditionalUPC2,
			@AdditionalUPC3,
			@AdditionalUPC4,
			@AdditionalUPC5,
			@AdditionalUPC6,
			@AdditionalUPC7,
			@AdditionalUPC8,
			@PackSKU,
			@PlanogramName,
			@VendorNumber,
			@VendorRank,
			@ItemTask,
			@Description,
			@Days,
			@VendorMinOrderAmount,
			@VendorContactName,
			@VendorContactPhone,
			@VendorContactEmail,
			@VendorContactFax,
			@ManufactureContact,
			@ManufacturePhone,
			@ManufactureEmail,
			@ManufactureFax,
			@AgentContact,
			@AgentPhone,
			@AgentEmail,
			@AgentFax,
			@VendorStyleNumber,
			@HarmonizedCodeNumber,
			@DetailInvoiceCustomsDesc,
			@ComponentMaterialBreakdown,
			@ComponentConstructionMethod,
			@IndividualItemPackaging,
			@EachInsideMasterCaseBox,
			@EachInsideInnerPack,
			--@EachPieceNetWeightLbsPerOunce,
			@ReshippableInnerCartonWeight,
			@ReshippableInnerCartonLength,
			@ReshippableInnerCartonWidth,
			@ReshippableInnerCartonHeight,
			@MasterCartonDimensionsLength,
			@MasterCartonDimensionsWidth,
			@MasterCartonDimensionsHeight,
			@CubicFeetPerMasterCarton,
			@WeightMasterCarton,
			@CubicFeetPerInnerCarton,
			@FOBShippingPoint,
			@DutyPercent,
			@DutyAmount,
			@AdditionalDutyComment,
			@AdditionalDutyAmount,
			@OceanFreightAmount,
			@OceanFreightComputedAmount,
			@AgentCommissionPercent,
			@AgentCommissionAmount,
			@OtherImportCostsPercent,
			@OtherImportCostsAmount,
			@PackagingCostAmount,
			@TotalImportBurden,
			@WarehouseLandedCost,
			@PurchaseOrderIssuedTo,
			@ShippingPoint,
			@CountryOfOrigin,
			@CountryOfOriginName,
			@VendorComments,
			@StockCategory,
			@FreightTerms,
			@ItemType,
			@PackItemIndicator,
			@ItemTypeAttribute,
			@AllowStoreOrder,
			@InventoryControl,
			@AutoReplenish,
			@PrePriced,
			@TaxUDA,
			@PrePricedUDA,
			@TaxValueUDA,
			@HybridType,
			@SourcingDC,
			@LeadTime,
			@ConversionDate,
			@StoreSuppZoneGRP,
			@WhseSuppZoneGRP,
			@POGMaxQty,
			@POGSetupPerStore,
			@ProjSalesPerStorePerMonth,
			@OutboundFreight,
			@NinePercentWhseCharge,
			@TotalStoreLandedCost,
			@RDBase,
			@RDCentral,
			@RDTest,	
			@RDAlaska,			
			@RDCanada,			
			@RD0Thru9,
			@RDCalifornia,
			@RDVillageCraft,
			@HazMatYes,
			@HazMatNo,
			@HazMatMFGCountry,
			@HazMatMFGName,
			@HazMatMFGFlammable,
			@HazMatMFGCity,
			@HazMatContainerType,
			@HazMatMFGState,
			@HazMatContainerSize,
			@HazMatMFGPhone,
			@HazMatMSDSUOM,
			@TSSA,
			@CSA,
			@UL,
			@LicenceAgreement,
			@FumigationCertificate,
			@KILNDriedCertificate,
			@ChinaComInspecNumAndCCIBStickers,
			@OriginalVisa,
			@TextileDeclarationMidCode,
			@QuotaChargeStatement,
			@MSDS,
			@TSCA,
			@DropBallTestCert,
			@ManMedicalDeviceListing,
			@ManFDARegistration,
			@CopyRightIndemnification,
			@FishWildLifeCert,
			@Proposition65LabelReq,
			@CCCR,
			@FormaldehydeCompliant,
			@QuoteSheetStatus,
			@Season,
			@PaymentTerms,
			@VendorName,
			@VendorAddress1,
			@VendorAddress2,
			@VendorAddress3,
			@VendorAddress4,
			@ManufactureName,
			@ManufactureAddress1,
			@ManufactureAddress2,
			@RMS_Sellable ,
			@RMS_Orderable ,
			@RMS_Inventory ,
			@Parent_ID ,
			@RegularBatchItem ,
			@CurrentDate,
			@UserID,
			@CurrentDate,
			@UserID,
			@Displayer_Cost,
			@Product_Cost,
			@Store_Total,
			@POG_Start_Date,
			@POG_Comp_Date,
			@Calculate_Options,
			@Like_Item_SKU,
			@Like_Item_Description,
			@Like_Item_Retail,
			@Annual_Regular_Unit_Forecast,
			@Like_Item_Store_Count,
			@Like_Item_Regular_Unit,
			@Like_Item_Unit_Store_Month,
			@Annual_Reg_Retail_Sales,
			@Facings,
			@Min_Pres_Per_Facing,
			@Inner_Pack,
			@POG_Min_Qty,
			@Retail9,
			@Retail10,
			@Retail11,
			@Retail12,
			@Retail13,
			@RDQuebec,
			@RDPuertoRico, 
			@Private_Brand_Label,
			@Discountable,
			@Qty_In_Pack,
			@Valid_Existing_SKU,
			@Item_Status, 
			@QuoteReferenceNumber,
			@CustomsDescription,
			@RecAgentCommissionPercent,
			@Stocking_Strategy_Code,
			@eachheight,
			@eachwidth,
			@eachlength,
			@eachweight,
			@cubicfeeteach,
			@CanadaHarmonizedCodeNumber
		)
		SET @ID = SCOPE_IDENTITY()
	END
GO
/****** Object:  StoredProcedure [dbo].[sp_SPD_Batch_PublishMQMessage_ByBatchID]    Script Date: 01/22/2018 14:09:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_SPD_Batch_PublishMQMessage_ByBatchID]
  @SPD_Batch_ID bigint = 0
AS
  SET NOCOUNT ON

  DECLARE @Message_Body xml
  DECLARE @SPD_Batch_Type_ID int --* 1=Domestic; 2=Import
  DECLARE @Message_ID bigint
  DECLARE @numSendableItemsInBatch int
  DECLARE @NumParentItemsInBatchNeedingaSKU smallint
  DECLARE @SPEDYEnvVars_Environment_Name varchar(50)
  DECLARE @SPEDYEnvVars_Environment_GUID uniqueidentifier
  DECLARE @SPEDYEnvVars_Server_Name nvarchar(2048)
  DECLARE @SPEDYEnvVars_Database_Name nvarchar(2048)
  DECLARE @SPEDYEnvVars_SPD_Root_URL nvarchar(2048)
  DECLARE @SPEDYEnvVars_SPD_Admin_URL nvarchar(2048)
  DECLARE @SPEDYEnvVars_SPD_Vendor_URL nvarchar(2048)
  DECLARE @SPEDYEnvVars_Test_Mode bit
  DECLARE @SPEDYEnvVars_Test_Mode_Email_Address nvarchar(2048)
  DECLARE @SPEDYEnvVars_SPD_Email_FromAddress nvarchar(2048)
  DECLARE @SPEDYEnvVars_SPD_Email_CCAddress varchar(max)
  DECLARE @SPEDYEnvVars_SPD_Email_BCCAddress varchar(max)
  DECLARE @SPEDYEnvVars_SPD_SMTP_Server nvarchar(2048)
  DECLARE @SPEDYEnvVars_SPD_SMTP_Authentication_Required bit
  DECLARE @SPEDYEnvVars_SPD_SMTP_Authentication_User nvarchar(2048)
  DECLARE @SPEDYEnvVars_SPD_SMTP_Authentication_Password nvarchar(2048)
  DECLARE @MichaelsEmailRecipients varchar(max)
  DECLARE @EmailRecipients varchar(max)
  DECLARE @EmailSubject varchar(4000)
  DECLARE @SPEDYBatchGUID varchar(4000)
  DECLARE @EmailBody varchar(max)
  DECLARE @EmailQuery varchar(max)
  DECLARE @DisplayerCost decimal(20, 4)
  DECLARE @DisplayerRetail money
  
  DECLARE @Components varchar(max)
  SET @Components = ''

  SET @numSendableItemsInBatch = 0
  SET @NumParentItemsInBatchNeedingaSKU = 0
 
  SELECT  
       @SPEDYEnvVars_Environment_Name = [Environment_Name]
      ,@SPEDYEnvVars_Environment_GUID = [Environment_GUID]
      ,@SPEDYEnvVars_Server_Name = [Server_Name]
      ,@SPEDYEnvVars_Database_Name = [Database_Name]
      ,@SPEDYEnvVars_SPD_Root_URL = [SPD_Root_URL]
      ,@SPEDYEnvVars_SPD_Admin_URL = [SPD_Admin_URL]
      ,@SPEDYEnvVars_SPD_Vendor_URL = [SPD_Vendor_URL]
      ,@SPEDYEnvVars_Test_Mode = [Test_Mode]
      ,@SPEDYEnvVars_Test_Mode_Email_Address = [Test_Mode_Email_Address]
      ,@SPEDYEnvVars_SPD_Email_FromAddress = [SPD_Email_FromAddress]
      ,@SPEDYEnvVars_SPD_Email_CCAddress = [SPD_Email_CCAddress]
      ,@SPEDYEnvVars_SPD_Email_BCCAddress = [SPD_Email_BCCAddress]
      ,@SPEDYEnvVars_SPD_SMTP_Server = [SPD_SMTP_Server]
      ,@SPEDYEnvVars_SPD_SMTP_Authentication_Required = [SPD_SMTP_Authentication_Required]
      ,@SPEDYEnvVars_SPD_SMTP_Authentication_User = [SPD_SMTP_Authentication_User]
      ,@SPEDYEnvVars_SPD_SMTP_Authentication_Password = [SPD_SMTP_Authentication_Password]
      --SELECT *
  FROM SPD_Environment
  WHERE Server_Name = @@SERVERNAME AND Database_Name = DB_NAME()
  
  -- stage ids
  DECLARE @STAGE_COMPLETED int
  DECLARE @STAGE_WAITINGFORSKU int
  DECLARE @STAGE_DBC int
  -- build stage ids
  select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 1 and Stage_Type_id = 4
  select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 1 and Stage_Type_id = 3
  select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 1 and Stage_Type_id = 6

  --  ............................................................................................
  --  ............................................................................................
  --
  --  When batches are moved from stage to stage in SPEDY, the user interface 
  --  (specifically item_action.aspx) changes the Is_Valid flag to unknown (-1) to 
  --  force a human to physically click on a batch and make sure it is Valid.
  --  
  --  This procedure is run when a batch reaches stage "Waiting for SKU".
  --
  --  For the "Waiting for SKU" stage, no human actually clicks on batches.  This 
  --  stage is completely automated, sending messages to RMS and awaiting response. 
  --
  --  So, here, we are setting the batch to Valid (1) if it has been marked as 
  --  Unknown (-1) by item_action.aspx.
  --  
      UPDATE SPD_Batch SET Is_Valid = 1 WHERE ID = @SPD_Batch_ID AND Is_Valid = -1
  --  
  --  ............................................................................................
  --  ............................................................................................


  --  Of course, explicitly invalid batches (0) will be sent back to the previous stage...
  IF ( (SELECT Is_Valid FROM SPD_Batch WHERE ID = @SPD_Batch_ID) = 0 )
  BEGIN
    UPDATE SPD_Batch SET 
      Workflow_Stage_ID = @STAGE_DBC,
      Date_Modified = getdate(),
      Modified_User = 0
    WHERE ID = @SPD_Batch_ID
  
    -- Record log of update
    INSERT INTO SPD_Batch_History
    (
      SPD_Batch_ID,
      Workflow_Stage_ID,
      [Action],
      Date_Modified,
      Modified_User,
      Notes
    )
    VALUES
    (
      @SPD_Batch_ID,
      @STAGE_WAITINGFORSKU,
      'Reject',
      getdate(),
      0,
      'This batch is not valid. Sending back to previous stage (DBC/QA)'
    )
  END
  ELSE
  BEGIN
	-- Process valid batch
    SELECT @SPD_Batch_Type_ID = COALESCE(Batch_Type_ID, 0) FROM SPD_Batch WHERE ID = @SPD_Batch_ID
    
    IF (@SPD_Batch_Type_ID = 1)
    BEGIN
      -- Domestic
      SELECT @NumParentItemsInBatchNeedingaSKU = COUNT(*)
      FROM SPD_Batch b
		  INNER JOIN SPD_Item_Headers h ON h.Batch_ID = b.ID
		  INNER JOIN SPD_Items i ON i.Item_Header_ID = h.ID
      WHERE b.ID = @SPD_Batch_ID AND Michaels_SKU IS NULL
      -- FJL Feb 2010 Only Check first 2 chars of Pack_Item_Indicator
        AND COALESCE(RTRIM(REPLACE(LEFT(i.[pack_item_indicator],2), '-', '')), '') IN ('D','DP')

      SELECT @numSendableItemsInBatch = COUNT(item.id)
      FROM SPD_Items item
		  INNER JOIN SPD_Item_Headers header ON header.id = item.item_header_id 
		  INNER JOIN SPD_Batch batch ON header.batch_id = batch.id
		  INNER JOIN SPD_Batch_Types batchtype ON batchtype.ID = batch.batch_type_id
      WHERE batch.ID = @SPD_Batch_ID AND NULLIF(item.[michaels_sku], '') IS NULL
      -- FJL Feb 2010 Only Check first 2 chars of Pack_Item_Indicator
        AND COALESCE(RTRIM(REPLACE(LEFT(item.[pack_item_indicator],2), '-', '')), '') NOT IN ('D','DP')
        
      if (@NumParentItemsInBatchNeedingaSKU > 0 and @numSendableItemsInBatch = 0)
      begin
        select @Components = @Components + 
          (CASE @Components when '' then '' else ';' END) + 
          item.[michaels_sku] + ',' + convert(varchar(20), item.Qty_In_Pack)
        from SPD_Items item
          INNER JOIN SPD_Item_Headers header ON header.id = item.item_header_id 
          INNER JOIN SPD_Batch batch ON header.batch_id = batch.id
          WHERE batch.ID = @SPD_Batch_ID AND NULLIF(item.[michaels_sku], '') IS NOT NULL
	      -- FJL Feb 2010 Only Check first 2 chars of Pack_Item_Indicator
            AND COALESCE(RTRIM(REPLACE(LEFT(item.[pack_item_indicator],2), '-', '')), '') NOT IN ('D','DP')
      end

      SET @Message_Body = (
        SELECT
          CONVERT(xml, (
            SELECT
              'SPEDY' As "Source"
              ,'SPEDYItemDomestic' As "Contents"
              ,((@SPD_Batch_ID % 3) + 1) As "ThreadID"
              ,dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) As "PublishTime"
            FOR XML PATH ('mikHeader')
			) )
          , CONVERT(xml, (
            SELECT
              CONVERT(varchar(20), batch.id) + '.' + CONVERT(varchar(20), item.id) + '.' + 
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(100), dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) ), '-05:00', ''), '-', ''), ' ', ''), ':', ''), '.', '') As "@id"
              ,'SPEDYItem' + batchtype.Batch_Type_Desc As "@type"
              ,'Create' As "@action"
              ,COALESCE(batch.id, '') As spd_batch_id
              ,COALESCE(LOWER(batchtype.Batch_Type_Desc) , '') As spd_batch_type
              ,COALESCE(dbo.udf_ReplaceSpecialChars(batch.[vendor_name]), '') As vendor_name
              ,COALESCE(batch.[vendor_number], '') As vendor_number
              ,COALESCE(batch.[batch_type_id], '') As spd_batch_type_id
              ,COALESCE(batch.[workflow_stage_id], '') As spd_workflow_stage_id
              ,COALESCE(header.[id] , '') As spd_header_id
              ,COALESCE(header.[log_id], '') As log_id
              ,COALESCE(header.[submitted_by], '') As submitted_by
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(header.[date_submitted]) , '') As date_submitted
              ,COALESCE(dbo.udf_ReplaceSpecialChars(header.[supply_chain_analyst]), '') As supply_chain_analyst
              ,COALESCE(dbo.udf_ReplaceSpecialChars(header.[mgr_supply_chain]), '') As mgr_supply_chain
              ,COALESCE(header.[dir_scvr], '') As dir_scvr
              ,COALESCE(header.[rebuy_yn], '') As rebuy_yn
              ,COALESCE(header.[replenish_yn], '') As replenish_yn
              ,COALESCE(header.[store_order_yn], '') As store_order_yn
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(header.[date_in_retek]), '') As date_in_retek
              ,COALESCE(header.[enter_retek], '') As enter_retek
              ,COALESCE(header.[us_vendor_num], '') As us_vendor_num
              ,COALESCE(header.[canadian_vendor_num], '') As canadian_vendor_num
              ,COALESCE(dbo.udf_ReplaceSpecialChars(header.[us_vendor_name]), '') As us_vendor_name
              ,COALESCE(dbo.udf_ReplaceSpecialChars(header.[canadian_vendor_name]), '') As canadian_vendor_name
              ,COALESCE(header.[buyer_approval], '') As buyer_approval
              ,COALESCE(header.[stock_category], '') As stock_category
              ,COALESCE(header.[canada_stock_category], '') As canada_stock_category
              ,COALESCE(header.[item_type], '') As item_type
              ,COALESCE(header.[item_type_attribute], '') As item_type_attribute
              ,COALESCE(header.[allow_store_order], '') As allow_store_order
              ,COALESCE(header.[perpetual_inventory], '') As perpetual_inventory
              ,COALESCE(header.[inventory_control], '') As inventory_control
              ,COALESCE(header.[freight_terms], '') As freight_terms
              ,COALESCE(header.[auto_replenish], '') As auto_replenish
              ,COALESCE(header.[sku_group], '') As sku_group
              ,COALESCE(header.[store_supplier_zone_group], '') As store_supplier_zone_group
              ,COALESCE(header.[whs_supplier_zone_group], '') As whs_supplier_zone_group
              ,COALESCE(dbo.udf_ReplaceSpecialChars(header.[comments]), '') As comments
              ,COALESCE(header.[batch_file_id], '') As batch_file_id
              ,COALESCE(header.[RMS_Orderable], '') As rms_sellable
              ,COALESCE(header.[RMS_Orderable], '') As rms_orderable
              ,COALESCE(header.[RMS_Inventory], '') As rms_inventory
              -- FJL July 2010
              ,COALESCE(header.Discountable,'Y')	As discountable_ind
              ,COALESCE(item.[id],'') As spd_item_id
              ,COALESCE(item.[item_header_id] , '') As item_header_id
              ,COALESCE(item.[add_change], '') As add_change
		      -- FJL Feb 2010 Only SEND first 2 chars of Pack_Item_Indicator per Lopa Mudra Ganguli
              ,COALESCE(RTRIM(REPLACE(LEFT(item.[pack_item_indicator],2), '-', '')), '') As pack_item_indicator
              ,COALESCE(item.[michaels_sku], '') As michaels_sku
              ,COALESCE(item.[vendor_upc], '') As vendor_upc
              -- FJL Replace 8 upc fields with comma delimited list (made by trigger)
              ,Coalesce(item.[UPC_List],'')		As upc
              ,COALESCE(header.[department_num], '') As department
              ,COALESCE(item.[class_num] , '') As class
              ,COALESCE(item.[sub_class_num] , '') As subclass
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[vendor_style_num]), '') As vendor_style_num
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[item_desc]), '') As item_desc
              ,COALESCE(item.Stocking_Strategy_Code, '') as stocking_strategy_code
              --,COALESCE(item.[hybrid_type], '') As hybrid_type
              --,COALESCE(item.[hybrid_source_dc], '') As hybrid_source_dc
              --,COALESCE(item.[hybrid_lead_time], '') As hybrid_lead_time
              --,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(item.[hybrid_conversion_date]), '') As hybrid_conversion_date
              ,COALESCE(item.[eaches_master_case], '') As eaches_master_case
              ,COALESCE(item.[eaches_inner_pack], '') As eaches_inner_pack
              ,COALESCE(item.[pre_priced], '') As pre_priced
              ,COALESCE(item.[pre_priced_uda], '') As pre_priced_uda
              --,COALESCE(item.[us_cost], '') As us_cost
              --,COALESCE(item.[canada_cost], '') As canada_cost
              ,COALESCE(item.[Total_US_Cost], '') As us_cost
              ,COALESCE(item.[Total_Canada_Cost], '') As canada_cost
              
              ,COALESCE(item.[base_retail], '') As base_retail
              ,COALESCE(item.[central_retail], '') As central_retail
              ,COALESCE(item.[test_retail], '') As test_retail
              ,COALESCE(item.[alaska_retail], '') As alaska_retail
              ,COALESCE(item.[canada_retail], '') As canada_retail
              ,COALESCE(item.[zero_nine_retail], '') As zero_nine_retail
              ,COALESCE(item.[california_retail], '') As california_retail
              ,COALESCE(item.[village_craft_retail], '') As village_craft_retail
              ,COALESCE(CONVERT(varchar(20),item.[Retail9]), '') As zone9_retail    --Change Order 14 LP
              ,COALESCE(CONVERT(varchar(20),item.[Retail10]), '') As zone10_retail  --Change Order 14 LP
              ,COALESCE(CONVERT(varchar(20),item.[Retail11]), '') As zone11_retail  --Change Order 14 LP
              ,COALESCE(CONVERT(varchar(20),item.[Retail12]), '') As zone12_retail  --Change Order 14 LP
              ,COALESCE(CONVERT(varchar(20),item.[Retail13]), '') As zone13_retail  --Change Order 14 LP
              ,COALESCE(CONVERT(varchar(20),item.[RDQuebec]), '') As zone14_retail 
              ,COALESCE(CONVERT(varchar(20),item.[RDPuertoRico]), '') As zone15_retail
              ,COALESCE(CONVERT(varchar(20),item.[pog_setup_per_store]), '') As pog_setup_per_store
              ,COALESCE(CONVERT(varchar(20),item.[pog_max_qty]), '') As pog_max_qty
              ,COALESCE(CONVERT(varchar(20),item.[projected_unit_sales]), '') As projected_unit_sales
              ,COALESCE(CONVERT(varchar(20),item.[each_case_height]), '') As each_case_height
              ,COALESCE(CONVERT(varchar(20),item.[each_case_width]), '') As each_case_width
              ,COALESCE(CONVERT(varchar(20),item.[each_case_length]), '') As each_case_length
              ,COALESCE(CONVERT(varchar(20),item.[each_case_weight]), '') As each_case_weight
              ,COALESCE(CONVERT(varchar(20),item.[each_case_pack_cube]), '') As each_case_pack_cube
              ,COALESCE(CONVERT(varchar(20),item.[inner_case_height]), '') As inner_case_height
              ,COALESCE(CONVERT(varchar(20),item.[inner_case_width]), '') As inner_case_width
              ,COALESCE(CONVERT(varchar(20),item.[inner_case_length]), '') As inner_case_length
              ,COALESCE(CONVERT(varchar(20),item.[inner_case_weight]), '') As inner_case_weight
              ,COALESCE(CONVERT(varchar(20),item.[inner_case_pack_cube]), '') As inner_case_pack_cube
              ,COALESCE(CONVERT(varchar(20),item.[master_case_height]), '') As master_case_height
              ,COALESCE(CONVERT(varchar(20),item.[master_case_width]), '') As master_case_width
              ,COALESCE(CONVERT(varchar(20),item.[master_case_length]), '') As master_case_length
              ,COALESCE(CONVERT(varchar(20),item.[master_case_weight]), '') As master_case_weight
              ,COALESCE(CONVERT(varchar(20),item.[master_case_pack_cube]), '') As master_case_pack_cube
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[country_of_origin]), '') As country_of_origin
              ,COALESCE(item.[tax_uda], '') As tax_uda
              ,COALESCE(item.[tax_value_uda], '') As tax_value_uda
              ,COALESCE(item.[hazardous], '') As hazardous
              ,COALESCE(item.[hazardous_flammable], '') As hazardous_flammable
              ,COALESCE(item.[hazardous_container_type], '') As hazardous_container_type
              ,COALESCE(CONVERT(varchar(20),item.[hazardous_container_size]), '') As hazardous_container_size
              ,COALESCE(item.[hazardous_msds_uom], '') As hazardous_msds_uom
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[hazardous_manufacturer_name]), '') As hazardous_manufacturer_name
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[hazardous_manufacturer_city]), '') As hazardous_manufacturer_city
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[hazardous_manufacturer_state]), '') As hazardous_manufacturer_state
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[hazardous_manufacturer_phone]), '') As hazardous_manufacturer_phone
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.[hazardous_manufacturer_country]), '') As hazardous_manufacturer_country
              ,COALESCE(item.[MSDS_ID], '') As msds_file_id
              ,COALESCE(item.[Image_ID], '') As product_image_file_id
              ,COALESCE(item.[tax_wizard], '') As tax_wizard
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(batch.[date_created]), '') As date_created
              ,COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(batch.[created_user]), 'MQRECV ') As create_user_domainlogin
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(item.[date_last_modified]), '') As date_last_modified
              ,COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(item.[update_user_id]), 'MQRECV ') As update_user_domainlogin
              ,case when ltrim(rtrim(isnull(item.[private_brand_label], ''))) != '' then 'Y' else 'N' end as private_brand_uda
              ,COALESCE(item.[private_brand_label], '') as private_brand_value_uda
              ,@Components As components
              ,COALESCE(item.[QuoteReferenceNumber], '') as QuoteReferenceNumber 
              --Multilingual fields...
              ,'en_US-' + CASE WHEN silE.[Package_Language_Indicator] = '' THEN 'N' ELSE COALESCE(silE.[Package_Language_Indicator], 'N') END + ',fr_CA-'+ CASE WHEN silF.[Package_Language_Indicator] = '' THEN 'N' ELSE COALESCE(silF.[Package_Language_Indicator], 'N') END + ',es_PR-'+ CASE WHEN silS.[Package_Language_Indicator] = '' THEN 'N' ELSE COALESCE(silS.[Package_Language_Indicator], 'N') END as pli
              ,'en_US-' + CASE WHEN silE.[Translation_Indicator] = '' THEN 'N' ELSE COALESCE(silE.[Translation_Indicator], 'N') END + ',fr_CA-'+ CASE WHEN silF.[Translation_Indicator] = '' THEN 'N' ELSE COALESCE(silF.[Translation_Indicator], 'N') END + ',es_PR-'+ CASE WHEN silS.[Translation_Indicator] = '' THEN 'N' ELSE COALESCE(silS.[Translation_Indicator], 'N') END as ti			  
              ,COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Short]), '') as short_cfd 
              ,COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Long]), '') as long_cfd
			  ,COALESCE(item.Harmonized_Code_Number, '') as import_hts_code
			  ,COALESCE(item.Canada_Harmonized_Code_Number, '') as canada_hts_code
			  

              ,COALESCE(item.Customs_Description, '') as short_customs_desc         
            FROM SPD_Items item
            INNER JOIN SPD_Item_Headers header ON header.id = item.item_header_id 
            INNER JOIN SPD_Batch batch ON header.batch_id = batch.id
            INNER JOIN SPD_Batch_Types batchtype ON batchtype.ID = batch.batch_type_id
            LEFT JOIN SPD_Item_Languages as silE on silE.Item_ID = item.ID and silE.Language_Type_ID = 1	-- ENGLISH Language Fields
            LEFT JOIN SPD_Item_Languages as silF on silF.Item_ID = item.ID and silF.Language_Type_ID = 2	-- FRENSH Language Fields
            LEFT JOIN SPD_Item_Languages as silS on silS.Item_ID = item.ID and silS.Language_Type_ID = 3	-- SPANISH Language Fields
            WHERE batch.ID = @SPD_Batch_ID AND NULLIF(item.[michaels_sku], '') IS NULL
		      -- FJL Feb 2010 Only check first 2 chars of Pack_Item_Indicator per Lopa Mudra Ganguli
              AND ( 
                ( (@numSendableItemsInBatch > 0) and COALESCE(RTRIM(REPLACE(LEFT(item.[pack_item_indicator],2), '-', '')), '') NOT IN ('D','DP') )
                OR
                ( (@NumParentItemsInBatchNeedingaSKU > 0 and @numSendableItemsInBatch = 0) 
					and COALESCE(RTRIM(REPLACE(LEFT(item.[pack_item_indicator],2), '-', '')), '') IN ('D','DP') )
                )
            ORDER BY batch.id, item.id
            FOR XML PATH ('mikData')
          ))
        FOR XML PATH ('mikMessage')
      )
      
    END

    IF (@SPD_Batch_Type_ID = 2)
    BEGIN
      -- Import
      SELECT @NumParentItemsInBatchNeedingaSKU = COUNT(*)
      FROM SPD_Batch b
      INNER JOIN SPD_Import_Items i ON i.Batch_ID = b.ID
      WHERE b.ID = @SPD_Batch_ID AND MichaelsSKU IS NULL
		-- FJL Feb 2010 Check just left 2 chars of PackItemIndicator
        AND COALESCE(RTRIM(REPLACE(LEFT(i.[packitemindicator],2), '-', '')), '') IN ('D','DP')

      SELECT @numSendableItemsInBatch = COUNT(importitem.id)
      FROM SPD_Import_Items importitem
      INNER JOIN SPD_Batch batch ON importitem.batch_id = batch.id
      INNER JOIN SPD_Batch_Types batchtype ON batchtype.ID = batch.batch_type_id
      WHERE batch.ID = @SPD_Batch_ID AND NULLIF(importitem.[michaelssku], '') IS NULL
		-- FJL Feb 2010 Check just left 2 chars of PackItemIndicator
        AND COALESCE(RTRIM(REPLACE(LEFT(importitem.[packitemindicator],2), '-', '')), '') NOT IN ('D','DP')
        
      if (@NumParentItemsInBatchNeedingaSKU > 0 and @numSendableItemsInBatch = 0)
      begin
        select @Components = @Components + 
          (CASE @Components when '' then '' else ';' END) + 
          importitem.[michaelssku] + ',' + convert(varchar(20), importitem.Qty_In_Pack)
        from SPD_Import_Items importitem
          INNER JOIN SPD_Batch batch ON importitem.batch_id = batch.id
          WHERE batch.ID = @SPD_Batch_ID AND NULLIF(importitem.[michaelssku], '') IS NOT NULL
		-- FJL Feb 2010 Check just left 2 chars of PackItemIndicator
            AND COALESCE(RTRIM(REPLACE(LEFT(importitem.[packitemindicator],2), '-', '')), '') NOT IN ('D','DP')
      end

      SET @Message_Body = (
        SELECT
          CONVERT(xml, (
            SELECT
              'SPEDY' As "Source"
              ,'SPEDYItemImport' As "Contents"
              ,((@SPD_Batch_ID % 3) + 1) As "ThreadID"
              ,dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) As "PublishTime"
            FOR XML PATH ('mikHeader')
			))
		  , CONVERT(xml, (
            SELECT
              CONVERT(varchar(20), batch.id) + '.' + CONVERT(varchar(20), importitem.id) + '.' + 
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(100), dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) ), '-05:00', ''), '-', ''), ' ', ''), ':', ''), '.', '') As "@id"
              ,'SPEDYItem' + batchtype.Batch_Type_Desc As "@type"
              ,'Create' As "@action"
              ,COALESCE(batch.id , '') As spd_batch_id
              ,COALESCE(LOWER(batchtype.Batch_Type_Desc) , '') As spd_batch_type
              ,COALESCE(dbo.udf_ReplaceSpecialChars(batch.[vendor_name]), '') As vendor_name
              ,COALESCE(batch.[vendor_number], '') As vendor_number
              ,COALESCE(batch.[batch_type_id], '') As batch_type_id
              ,COALESCE(batch.[workflow_stage_id], '') As spd_workflow_stage_id
              ,COALESCE(importitem.[id] , '') As spd_importitem_id
              ,COALESCE(importitem.[itemtask], '') As add_change 
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(importitem.[datecreated]), '') As date_created
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(importitem.[datelastmodified]), '') As date_last_modified
              ,COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(importitem.[createduserid]), 'MQRECV') As create_user_domainlogin
              ,COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(importitem.[updateuserid]), 'MQRECV') As update_user_domainlogin
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(importitem.[datesubmitted]), '') As date_submitted
              ,COALESCE(importitem.[vendor], '') As vendor
              ,COALESCE(importitem.[agent], '') As agent
              ,COALESCE(importitem.[agenttype], '') As agenttype
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[buyer]), '') As buyer
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[fax]), '') As fax
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[enteredby]), '') As enteredby
              ,COALESCE(importitem.[quotesheetstatus], '') As quotesheetstatus
              ,COALESCE(importitem.[season], '') As season
              ,COALESCE(importitem.[skugroup], '') As skugroup
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[email]), '') As email
              ,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(importitem.[entereddate]), '') As entereddate
              ,COALESCE(importitem.[dept], '') As dept
              ,COALESCE(importitem.[class], '') As class
              ,COALESCE(importitem.[subclass], '') As subclass
              ,COALESCE(importitem.[primaryupc], '') As primaryupc
              ,COALESCE(importitem.[michaelssku], '') As michaelssku
              -- FJL July 2010
              ,Coalesce(importitem.UPC_List,'')		As upc
              ,COALESCE(importitem.[packsku], '') As packsku
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[planogramname]), '') As planogramname
              ,COALESCE(importitem.[vendornumber], '') As vendornumber
              ,COALESCE(importitem.[vendorrank], '') As vendorrank
              ,COALESCE(importitem.[itemtask], '') As itemtask
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[description]), '') As description
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[paymentterms]), '') As paymentterms
              ,COALESCE(importitem.[days], '') As days
              ,COALESCE(importitem.[vendorminorderamount], '') As vendorminorderamount
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendorname]), '') As vendorname
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendoraddress1]), '') As vendoraddress1
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendoraddress2]), '') As vendoraddress2
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendoraddress3]), '') As vendoraddress3
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendoraddress4]), '') As vendoraddress4
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendorcontactname]), '') As vendorcontactname
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendorcontactphone]), '') As vendorcontactphone
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendorcontactemail]), '') As vendorcontactemail
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendorcontactfax]), '') As vendorcontactfax
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[manufacturename]), '') As manufacturename
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[manufactureaddress1]), '') As manufactureaddress1
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[manufactureaddress2]), '') As manufactureaddress2
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[manufacturecontact]), '') As manufacturecontact
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[manufacturephone]), '') As manufacturephone
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[manufactureemail]), '') As manufactureemail
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[manufacturefax]), '') As manufacturefax
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[agentcontact]), '') As agentcontact
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[agentphone]), '') As agentphone
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[agentemail]), '') As agentemail
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[agentfax]), '') As agentfax
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendorstylenumber]), '') As vendorstylenumber
              ,COALESCE(importitem.[harmonizedcodenumber], '') As harmonizedcodenumber
              ,COALESCE(importitem.CanadaHarmonizedCodeNumber, '') as canadaharmonizedcodenumber
              ,COALESCE(importitem.Customs_Description, '') as shortcustomsdescription
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[detailinvoicecustomsdesc]), '') As detailinvoicecustomsdesc
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[componentmaterialbreakdown]), '') As componentmaterialbreakdown
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[componentconstructionmethod]), '') As componentconstructionmethod
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[individualitempackaging]), '') As individualitempackaging
              ,COALESCE(importitem.[eachinsidemastercasebox], '') As eachinsidemastercasebox
              ,COALESCE(importitem.[eachinsideinnerpack], '') As eachinsideinnerpack
              --,COALESCE(importitem.[eachpiecenetweightlbsperounce], '') As eachpiecenetweightlbsperounce
              ,COALESCE(importitem.[ReshippableInnerCartonWeight], '') As eachpiecenetweightlbsperounce
              ,COALESCE(convert(varchar(20),importitem.eachlength),'') as eachlength
              ,COALESCE(convert(varchar(20),importitem.eachwidth),'') as eachwidth
              ,COALESCE(convert(varchar(20),importitem.eachheight),'') as eachheight
              ,COALESCE(convert(varchar(20),importitem.eachweight),'') as eachweight
              ,COALESCE(convert(varchar(20),importitem.cubicfeeteach),'') as cubicfeeteach
              ,COALESCE(importitem.[reshippableinnercartonlength], '') As reshippableinnercartonlength
              ,COALESCE(importitem.[reshippableinnercartonwidth], '') As reshippableinnercartonwidth
              ,COALESCE(importitem.[reshippableinnercartonheight], '') As reshippableinnercartonheight
              ,COALESCE(importitem.[ReshippableInnerCartonWeight], '') As reshippableinnercartonweight
              ,COALESCE(importitem.[mastercartondimensionslength], '') As mastercartondimensionslength
              ,COALESCE(importitem.[mastercartondimensionswidth], '') As mastercartondimensionswidth
              ,COALESCE(importitem.[mastercartondimensionsheight], '') As mastercartondimensionsheight
              ,COALESCE(importitem.[cubicfeetpermastercarton], '') As cubicfeetpermastercarton
              ,COALESCE(importitem.[weightmastercarton], '') As weightmastercarton
              ,COALESCE(importitem.[cubicfeetperinnercarton], '') As cubicfeetperinnercarton
              ,COALESCE(importitem.[fobshippingpoint], '') As fobshippingpoint
              ,COALESCE(importitem.[dutypercent], '') As dutypercent
              ,COALESCE(importitem.[dutyamount], '') As dutyamount
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[additionaldutycomment]), '') As additionaldutycomment
              ,COALESCE(importitem.[additionaldutyamount], '') As additionaldutyamount
              ,COALESCE(importitem.[oceanfreightamount], '') As oceanfreightamount
              ,COALESCE(importitem.[oceanfreightcomputedamount], '') As oceanfreightcomputedamount
              ,COALESCE(importitem.[agentcommissionpercent], '') As agentcommissionpercent
              ,COALESCE(importitem.[agentcommissionamount], '') As agentcommissionamount
              ,COALESCE(importitem.[otherimportcostspercent], '') As otherimportcostspercent
              ,COALESCE(importitem.[otherimportcostsamount], '') As otherimportcostsamount
              ,COALESCE(importitem.[packagingcostamount], '') As packagingcostamount
              ,COALESCE(importitem.[totalimportburden], '') As totalimportburden
              ,COALESCE(importitem.[warehouselandedcost], '') As warehouselandedcost
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[purchaseorderissuedto]), '') As purchaseorderissuedto
              ,COALESCE(importitem.[shippingpoint], '') As shippingpoint
              ,COALESCE(importitem.[countryoforigin], '') As countryoforigin
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[vendorcomments]), '') As vendorcomments
              ,COALESCE(importitem.[stockcategory], '') As stockcategory
              ,COALESCE(importitem.[freightterms], '') As freightterms
              ,COALESCE(importitem.[itemtype], '') As itemtype
			-- FJL Feb 2010 SEND just left 2 chars of PackItemIndicator per Lopa Mudra Ganguli
              ,COALESCE(RTRIM(REPLACE(LEFT(importitem.[packitemindicator],2), '-', '')), '') As packitemindicator
              ,COALESCE(importitem.[itemtypeattribute], '') As itemtypeattribute
              ,COALESCE(importitem.[allowstoreorder], '') As allowstoreorder
              -- FJL July 2010 add
              ,Coalesce(importitem.Discountable,'Y')	As discountable_ind
              ,COALESCE(importitem.[inventorycontrol], '') As inventorycontrol
              ,COALESCE(importitem.[autoreplenish], '') As autoreplenish
              ,COALESCE(importitem.[prepriced], '') As prepriced
              ,COALESCE(importitem.[taxuda], '') As taxuda
              ,COALESCE(importitem.[prepriceduda], '') As prepriceduda
              ,COALESCE(importitem.[taxvalueuda], '') As taxvalueuda
              ,COALESCE(importitem.Stocking_Strategy_Code, '') as stocking_strategy_code
              --,COALESCE(importitem.[hybridtype], '') As hybridtype
              --,COALESCE(importitem.[sourcingdc], '') As sourcingdc
              --,COALESCE(importitem.[leadtime], '') As leadtime
              --,COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(importitem.[conversiondate]), '') As conversiondate
              ,COALESCE(importitem.[storesuppzonegrp], '') As storesuppzonegrp
              ,COALESCE(importitem.[whsesuppzonegrp], '') As whsesuppzonegrp
              ,COALESCE(importitem.[pogmaxqty], '') As pogmaxqty
              ,COALESCE(importitem.[pogsetupperstore], '') As pogsetupperstore
              ,COALESCE(importitem.[projsalesperstorepermonth], '') As projsalesperstorepermonth
              ,COALESCE(importitem.[outboundfreight], '') As outboundfreight
              ,COALESCE(importitem.[ninepercentwhsecharge], '') As ninepercentwhsecharge
              ,COALESCE(importitem.[totalstorelandedcost], '') As totalstorelandedcost
              ,COALESCE(importitem.[rdbase], '') As rdbase
              ,COALESCE(importitem.[rdcentral], '') As rdcentral
              ,COALESCE(importitem.[rdtest], '') As rdtest
              ,COALESCE(importitem.[rdalaska], '') As rdalaska
              ,COALESCE(importitem.[rdcanada], '') As rdcanada
              ,COALESCE(importitem.[rd0thru9], '') As rd0thru9
              ,COALESCE(importitem.[rdcalifornia], '') As rdcalifornia
              ,COALESCE(importitem.[rdvillagecraft], '') As rdvillagecraft
              ,COALESCE(CONVERT(varchar(20),importitem.[Retail9]), '') As zone9_retail    --LP Change Order 14
              ,COALESCE(CONVERT(varchar(20),importitem.[Retail10]), '') As zone10_retail  --LP Change Order 14
              ,COALESCE(CONVERT(varchar(20),importitem.[Retail11]), '') As zone11_retail  --LP Change Order 14
              ,COALESCE(CONVERT(varchar(20),importitem.[Retail12]), '') As zone12_retail  --LP Change Order 14
              ,COALESCE(CONVERT(varchar(20),importitem.[Retail13]), '') As zone13_retail  --LP Change Order 14
              ,COALESCE(CONVERT(varchar(20),importitem.[RDQuebec]), '') As zone14_retail 
              ,COALESCE(CONVERT(varchar(20),importitem.[RDPuertoRico]), '') As zone15_retail
              --,COALESCE(importitem.[hazmatyes], '') As hazmatyes
              --,COALESCE(importitem.[hazmatno], '') As hazmatno
              ,CONVERT(varchar(1), (CASE WHEN COALESCE(importitem.[hazmatyes], '') = 'X' THEN 'Y' ELSE 'N' END)) As hazmat
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[hazmatmfgcountry]), '') As hazmatmfgcountry
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[hazmatmfgname]), '') As hazmatmfgname
              ,COALESCE(importitem.[hazmatmfgflammable], '') As hazmatmfgflammable
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[hazmatmfgcity]), '') As hazmatmfgcity
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[hazmatcontainertype]), '') As hazmatcontainertype
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[hazmatmfgstate]), '') As hazmatmfgstate
              ,COALESCE(importitem.[hazmatcontainersize], '') As hazmatcontainersize
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[hazmatmfgphone]), '') As hazmatmfgphone
              ,COALESCE(importitem.[hazmatmsdsuom], '') As hazmatmsdsuom
              ,COALESCE(importitem.[tssa], '') As tssa
              ,COALESCE(importitem.[csa], '') As csa
              ,COALESCE(importitem.[ul], '') As ul
              ,COALESCE(importitem.[licenceagreement], '') As licenceagreement
              ,COALESCE(importitem.[fumigationcertificate], '') As fumigationcertificate
              ,COALESCE(importitem.[kilndriedcertificate], '') As kilndriedcertificate
              ,COALESCE(importitem.[chinacominspecnumandccibstickers], '') As chinacominspecnumandccibstickers
              ,COALESCE(importitem.[originalvisa], '') As originalvisa
              ,COALESCE(importitem.[textiledeclarationmidcode], '') As textiledeclarationmidcode
              ,COALESCE(importitem.[quotachargestatement], '') As quotachargestatement
              ,COALESCE(importitem.[msds], '') As msds
              ,COALESCE(importitem.[tsca], '') As tsca
              ,COALESCE(importitem.[dropballtestcert], '') As dropballtestcert
              ,COALESCE(importitem.[manmedicaldevicelisting], '') As manmedicaldevicelisting
              ,COALESCE(importitem.[manfdaregistration], '') As manfdaregistration
              ,COALESCE(importitem.[copyrightindemnification], '') As copyrightindemnification
              ,COALESCE(importitem.[fishwildlifecert], '') As fishwildlifecert
              ,COALESCE(importitem.[proposition65labelreq], '') As proposition65labelreq
              ,COALESCE(importitem.[cccr], '') As cccr
              ,COALESCE(importitem.[formaldehydecompliant], '') As formaldehydecompliant
              ,COALESCE(importitem.[is_valid], '') As is_valid
              ,COALESCE(importitem.[RMS_Orderable], '') As rms_sellable
              ,COALESCE(importitem.[RMS_Orderable], '') As rms_orderable
              ,COALESCE(importitem.[RMS_Inventory], '') As rms_inventory
              ,case when ltrim(rtrim(isnull(importitem.[private_brand_label], ''))) != '' then 'Y' else 'N' end as private_brand_uda
              ,COALESCE(importitem.[private_brand_label], '') as private_brand_value_uda
              ,@Components As components
              ,COALESCE(importitem.[QuoteReferenceNumber], '') as QuoteReferenceNumber
              --Multilingual fields...
              ,'en_US-' + CASE WHEN silE.[Package_Language_Indicator] = '' THEN 'N' ELSE COALESCE(silE.[Package_Language_Indicator], 'N') END + ',fr_CA-'+ CASE WHEN silF.[Package_Language_Indicator] = '' THEN 'N' ELSE COALESCE(silF.[Package_Language_Indicator], 'N') END + ',es_PR-'+ CASE WHEN silS.[Package_Language_Indicator] = '' THEN 'N' ELSE COALESCE(silS.[Package_Language_Indicator], 'N') END as pli
              ,'en_US-' + CASE WHEN silE.[Translation_Indicator] = '' THEN 'N' ELSE COALESCE(silE.[Translation_Indicator], 'N') END + ',fr_CA-'+ CASE WHEN silF.[Translation_Indicator] = '' THEN 'N' ELSE COALESCE(silF.[Translation_Indicator], 'N') END + ',es_PR-'+ CASE WHEN silS.[Translation_Indicator] = '' THEN 'N' ELSE COALESCE(silS.[Translation_Indicator], 'N') END as ti			  
              ,COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Short]), '') as short_cfd 
              ,COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Long]), '') as long_cfd
              
            FROM SPD_Import_Items importitem
            INNER JOIN SPD_Batch batch ON importitem.batch_id = batch.id
            INNER JOIN SPD_Batch_Types batchtype ON batchtype.ID = batch.batch_type_id
            LEFT JOIN SPD_Import_Item_Languages as silE on silE.Import_Item_ID = importitem.ID and silE.Language_Type_ID = 1	-- ENGLISH Language Fields
            LEFT JOIN SPD_Import_Item_Languages as silF on silF.Import_Item_ID = importitem.ID and silF.Language_Type_ID = 2	-- FRENCH Language Fields
            LEFT JOIN SPD_Import_Item_Languages as silS on silS.Import_Item_ID = importitem.ID and silS.Language_Type_ID = 3	-- SPANISH Language Fields
            WHERE batch.ID = @SPD_Batch_ID AND NULLIF(importitem.[michaelssku], '') IS NULL
              AND (
					-- FJL Feb 2010 Only check first 2 chars of PackItemIndicator
                ( (@numSendableItemsInBatch > 0) and COALESCE(RTRIM(REPLACE(LEFT(importitem.[packitemindicator],2), '-', '')), '') NOT IN ('D','DP') )
                OR
                ( (@NumParentItemsInBatchNeedingaSKU > 0 and @numSendableItemsInBatch = 0) 
					and COALESCE(RTRIM(REPLACE(LEFT(importitem.[packitemindicator],2), '-', '')), '') IN ('D','DP') )
                )
            ORDER BY batch.id, importitem.id
            FOR XML PATH ('mikData')
          ))
        FOR XML PATH ('mikMessage')
      )
    END
  END -- Is Valid?
  

  IF ((@Message_Body IS NOT NULL) AND ( @numSendableItemsInBatch > 0 or (@NumParentItemsInBatchNeedingaSKU > 0 and @numSendableItemsInBatch = 0) ))
  BEGIN
    
    INSERT INTO SPD_MQComm_Message
    (
      [SPD_Batch_ID]
      ,[Message_Type_ID]
      ,[Message_Body]
      ,[Message_Direction]
    )
    VALUES
    (
      @SPD_Batch_ID
      ,1
      ,@Message_Body
      ,1
    )
    
    SET @Message_ID = SCOPE_IDENTITY()

    INSERT INTO SPD_MQComm_Message_Status
    (
      [Message_ID]
      ,[Status_ID]
    )
    VALUES
    (
      @Message_ID
      ,1
    )
  END
  
  PRINT '@numSendableItemsInBatch: ' + CONVERT(varchar(10), @numSendableItemsInBatch)
  PRINT '@NumParentItemsInBatchNeedingaSKU: ' + CONVERT(varchar(10), @NumParentItemsInBatchNeedingaSKU)
 
  -- Did we create a Pack SKU Message request?  If so Mark the Batch as NI Pack Message Sent
  IF ( @NumParentItemsInBatchNeedingaSKU > 0 and @numSendableItemsInBatch = 0 )
  BEGIN
	UPDATE SPD_Batch SET
		NI_PackMsg_Sent	= 1
		,Date_Modified = getdate()
        ,Modified_User = 0
	WHERE ID =  @SPD_Batch_ID

	INSERT INTO SPD_Batch_History (
		SPD_Batch_ID,
		Workflow_Stage_ID,
		[Action],
		Date_Modified,
		Modified_User,
		Notes
	)
	VALUES (
		@SPD_Batch_ID,
		@STAGE_WAITINGFORSKU,
		'System Activity',
		getdate(),
		0,
		'Pack SKU Request Message Sent to RMS.'
	)
		
  END

  IF (@numSendableItemsInBatch = 0 AND @NumParentItemsInBatchNeedingaSKU = 0)
  BEGIN

    IF ( (SELECT Is_Valid FROM SPD_Batch WHERE ID = @SPD_Batch_ID) = 1)
    BEGIN
      UPDATE SPD_Batch SET 
        Workflow_Stage_ID = @STAGE_COMPLETED,
        Is_Valid = 1,
        Date_Modified = getdate(),
        Modified_User = 0
      WHERE ID = @SPD_Batch_ID
    
      -- Record log of update
      INSERT INTO SPD_Batch_History
      (
        SPD_Batch_ID,
        Workflow_Stage_ID,
        [Action],
        Date_Modified,
        Modified_User,
        Notes
      )
      VALUES
      (
        @SPD_Batch_ID,
        @STAGE_WAITINGFORSKU,
        'Approve',
        getdate(),
        0,
        'There are no items to send to RMS.  Marking batch as complete.'
      )
      
      --Update SPD_Batch_History_Stage_Durations table with End Date for "Waiting" stage
      Update SPD_Batch_History_Stage_Durations
      Set End_Date = getDate(), [Hours]=dbo.BDATEDIFF_BUSINESS_HOURS([Start_Date], getDate(), DEFAULT, DEFAULT),
		Approved_User_ID = 0
      Where Batch_ID = @SPD_BATCH_ID And Stage_ID = @STAGE_WAITINGFORSKU and End_Date is null
      
      -- Record log of update
      INSERT INTO SPD_Batch_History
      (
        SPD_Batch_ID,
        Workflow_Stage_ID,
        [Action],
        Date_Modified,
        Modified_User,
        Notes
      )
      VALUES
      (
        @SPD_Batch_ID,
        @STAGE_COMPLETED,
        'Complete',
        getdate(),
        0,
        'Batch Complete.'
      )

      -- Send emails          
      SELECT @MichaelsEmailRecipients = COALESCE(@MichaelsEmailRecipients + '; ', '') + su.Email_Address
      FROM SPD_Batch_History bh
      INNER JOIN Security_User su ON su.ID = bh.modified_user
      WHERE IsNumeric(bh.modified_user) = 1 
        AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
        AND SPD_Batch_ID = @SPD_Batch_ID
        AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) > 0
      GROUP BY bh.modified_user, su.Email_Address
      
      SELECT @EmailRecipients = COALESCE(@EmailRecipients + '; ', '') + su.Email_Address
      FROM SPD_Batch_History bh
      INNER JOIN Security_User su ON su.ID = bh.modified_user
      WHERE IsNumeric(bh.modified_user) = 1 
        AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
        AND SPD_Batch_ID = @SPD_Batch_ID
        AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) = 0
      GROUP BY bh.modified_user, su.Email_Address
      
      SELECT @SPEDYBatchGUID = [GUID] FROM SPD_Batch WHERE ID = @SPD_Batch_ID

      IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
      

	-- FJL July 2010 - Get more info for the subject line per IS Req F47
		Declare @DeptNo varchar(5), @VendorNo varchar(20), @VendorName varchar(50)
		Select @DeptNo = convert(varchar(5), Fineline_Dept_ID)
			, @VendorNo = convert(varchar(20), Vendor_Number)
			, @VendorName = Vendor_Name
		From SPD_Batch
		Where ID = @SPD_Batch_ID
	  SET @EmailSubject = 'SPEDY Complete. D' + COALESCE(@DeptNo, '') + ' ' + COALESCE(@VendorNo,'') + '-' + COALESCE(@VendorName,'') + '. Log ID#: ' +  convert(varchar(20),@SPD_Batch_ID)
      --SET @EmailSubject = 'SPEDY Batch ' + CONVERT(varchar(20), COALESCE(@SPD_Batch_ID, '')) + ' is Complete.'
      --IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
      
      -- *** Michaels Email
      SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  Congratulations!</p><p>Next Steps:<ul type="square" style="padding-top: 0; margin-top: 0;"><li><a href="' + @SPEDYEnvVars_SPD_Root_URL + '/batchexport.aspx?guid=' + @SPEDYBatchGUID + '">Download the completed batch to Excel</a></li><li><a href="' + @SPEDYEnvVars_SPD_Root_URL + '">Login to SPEDY to review this batch.</a></li></ul></p></font>'
      EXEC sp_SQLSMTPMail
        @vcSender = @SPEDYEnvVars_SPD_Email_FromAddress,
        @vcFrom = @SPEDYEnvVars_SPD_Email_FromAddress,
        @vcTo = @MichaelsEmailRecipients,
        @vcCC = @SPEDYEnvVars_SPD_Email_CCAddress,
        @vcBCC = @SPEDYEnvVars_SPD_Email_BCCAddress,
        @vcSubject = @EmailSubject,
        @vcHTMLBody = @EmailBody,
        @bAutoGenerateTextBody = 1,
        @vcSMTPServer = @SPEDYEnvVars_SPD_SMTP_Server,
        @cDSNOptions = '2',
        @bAuthenticate = @SPEDYEnvVars_SPD_SMTP_Authentication_Required,
        @vcSMTPAuth_UserName = @SPEDYEnvVars_SPD_SMTP_Authentication_User,
        @vcSMTPAuth_UserPassword = @SPEDYEnvVars_SPD_SMTP_Authentication_Password

      IF (@SPEDYEnvVars_Test_Mode = 0)
      BEGIN
        -- *** Vendor Email
        SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  Congratulations!</p><p>Next Steps:<ul type="square" style="padding-top: 0; margin-top: 0;"><li><a href="' + @SPEDYEnvVars_SPD_Vendor_URL + '/batchexport.aspx?guid=' + @SPEDYBatchGUID + '">Download the completed batch to Excel</a></li><li><a href="' + @SPEDYEnvVars_SPD_Vendor_URL + '">Login to SPEDY to review this batch.</a></li></ul></p></font>'
        EXEC sp_SQLSMTPMail
          @vcSender = @SPEDYEnvVars_SPD_Email_FromAddress,
          @vcFrom = @SPEDYEnvVars_SPD_Email_FromAddress,
          @vcTo = @EmailRecipients,
          @vcCC = @SPEDYEnvVars_SPD_Email_CCAddress,
          @vcBCC = @SPEDYEnvVars_SPD_Email_BCCAddress,
          @vcSubject = @EmailSubject,
          @vcHTMLBody = @EmailBody,
          @bAutoGenerateTextBody = 1,
          @vcSMTPServer = @SPEDYEnvVars_SPD_SMTP_Server,
          @cDSNOptions = '2',
          @bAuthenticate = @SPEDYEnvVars_SPD_SMTP_Authentication_Required,
          @vcSMTPAuth_UserName = @SPEDYEnvVars_SPD_SMTP_Authentication_User,
          @vcSMTPAuth_UserPassword = @SPEDYEnvVars_SPD_SMTP_Authentication_Password
      END

    END

  END

  
  SET NOCOUNT OFF
GO



CREATE PROCEDURE [dbo].[usp_Get_Stocking_Strategy_By_Warehouses] 
	@ItemTypeAttribute varchar(20),
	@Warehouses varchar(8000) = ''
	
AS

	
Declare @WHCount int
	
DECLARE @tblWH TABLE
(
	warehouse bigint
)


Insert into @tblWH
select convert(bigint,Element) from [dbo].[Split](@Warehouses, ',')

Select @WHCount = COUNT(*) from @tblWH

declare @stock_group_id int

select @stock_group_id = ID from List_Value_Groups where List_Value_Group = 'STOCKSTRAT'

Select distinct S.Strategy_Code, S.Strategy_Desc
from
Stocking_Strategy S
inner join 
(
	Select Strategy_Code--, Strategy_Desc 
	from Stocking_Strategy SS 
	where SS.Strategy_Status <> 'D'  
	and (case when @ItemTypeAttribute = 'S' and ss.Strategy_Type = 'S' then 1 
	when @ItemTypeAttribute <> 'S' and ss.Strategy_Type = 'B' then 1 else 0 end) = 1  
	and SS.Warehouse in ( Select warehouse from @tblWH)
	group by Strategy_Code
	having COUNT(Strategy_Code) = @WHCount
) C on C.Strategy_Code = S.Strategy_Code
inner join list_values LV on LV.Display_Text = S.Strategy_Desc and LV.List_Value_Group_ID = @stock_group_id
and lv.List_Value = s.Strategy_Code
order by s.Strategy_Desc 


GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateItem]    Script Date: 01/31/2018 14:11:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_SPD_Validation_ValidateItem]
  @itemID bigint
AS

  declare @itemErrors int
  set @itemErrors = 0
  
  declare @batchID bigint, @parentID int, @itemHeaderID bigint
  declare @batchType int
  declare @hid int
  declare @DPCount int
  declare @DCount int
  declare @CCount int
  declare @itemCount int
  declare @costParent money, @costChildren money
  declare @int1 int, @int2 int, @int3 int
  declare @str1 varchar(255)
  declare @reg bit
  
  declare @str varchar(50), @int int, @bigint bigint, @bit bit
  
  select @itemHeaderID = [Item_Header_ID] from SPD_Items where [ID] = @itemID
  
  --select @batchID = [BatchID] from vwItemMaintItemDetail where [ID] = @itemID
  select @batchID = [Batch_ID] from SPD_Item_Headers where [ID] = @itemHeaderID
  
  select @batchType = Batch_Type_ID from SPD_Batch where [ID] = @batchID
  
  declare @itemType varchar(20)
  
  select @itemType = REPLACE(LEFT(COALESCE(i.Pack_Item_Indicator, ''), 2), '-', '') from SPD_Items i 
    where i.[ID] = @itemID
  
  -----------------------------
  -- DOMESTIC BATCH
  -----------------------------
  select @itemCount = isnull(count(1), 0) from SPD_Items i where i.Item_Header_ID = @itemHeaderID
  
  select @DPCount = isnull(count(1), 0) from SPD_Items i 
    where i.Item_Header_ID = @itemHeaderID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[Pack_Item_Indicator], ''),2), '-', '')), '') = 'DP'
  
  select @DCount = isnull(count(1), 0) from SPD_Items i 
    where i.Item_Header_ID = @itemHeaderID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[Pack_Item_Indicator], ''),2), '-', '')), '') = 'D' 
  
  select @CCount = isnull(count(1), 0) from SPD_Items i 
    where i.Item_Header_ID = @itemHeaderID and 
      ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
  
  -- START ERRORS - DOMESTIC ---------------------------
    
  if (@itemType != 'D' and @itemType != 'DP')
  begin
  
    
    ----------------
    -- COMPONENTS --
    ----------------
    
    --None = 0

    ----------
    -- D/DP --
    ----------
    if ((@DPCount + @DCount) = 1)
    begin
    
	  select @parentID = i.[ID]
      from SPD_Items i 
      where i.Item_Header_ID = @itemHeaderID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[Pack_Item_Indicator], ''),2), '-', '')), '') = 'DP'
      
      if (@DPCount = 1)
      begin
        
        declare @ItemTypeAttributeDP varchar(50) -- header
        declare @StockCategoryDP varchar(1) -- header
        --declare @HybridTypeDP varchar(1)
        --declare @HybridSourceDCDP varchar(1)
        declare @StockingStrategyCodeDP nvarchar(20)
        declare @DepartmentNumDP int, @ClassNumDP int, @SubClassNumDP int -- dept is header -- class subclass are item
        declare @VendorNumberDP bigint -- header
        
          
        select 
          @ItemTypeAttributeDP = COALESCE(ih.Item_Type_Attribute, ''),
          @StockCategoryDP = case 
            when isnull(ih.US_Vendor_Num, 0) > 0 then COALESCE(ih.Stock_Category, '') 
            when isnull(ih.Canadian_Vendor_Num, 0) > 0 then COALESCE(ih.Canada_Stock_Category, '')
            else COALESCE(ih.Stock_Category, '')
          end,
          --@HybridTypeDP = COALESCE(i.Hybrid_Type, ''),
          --@HybridSourceDCDP = COALESCE(i.Hybrid_Source_DC, ''),
          @StockingStrategyCodeDP = COALESCE(i.Stocking_Strategy_Code,''),
          @DepartmentNumDP = COALESCE(ih.Department_Num, 0),
          @ClassNumDP = COALESCE(i.Class_Num, 0),
          @SubClassNumDP = COALESCE(i.Sub_Class_Num, 0),
          @VendorNumberDP = case 
            when isnull(ih.US_Vendor_Num, 0) > 0 then COALESCE(ih.US_Vendor_Num, 0) 
            when isnull(ih.Canadian_Vendor_Num, 0) > 0 then COALESCE(ih.Canadian_Vendor_Num, 0)
            else COALESCE(ih.US_Vendor_Num, 0)
          end
        from SPD_Items i 
          inner join SPD_Item_Headers ih on i.[Item_Header_ID] = ih.[ID]
        where i.[ID] = @parentID
      
        --ComponentsSameItemType = 1 ' DP
        set @bit = 0
        select @bit = ISNULL(i.Valid_Existing_SKU, 0), @str = COALESCE(i.Item_Type_Attribute, '') from SPD_Items i
          where i.[ID] = @itemID
        if (@bit = 1 and @str != @ItemTypeAttributeDP) set @itemErrors = @itemErrors + 1
        
        --ComponentsSameStockCategory = 2 ' DP
        set @bit = 0
        select @bit = ISNULL(i.Valid_Existing_SKU, 0), @str = COALESCE(i.Stock_Category, '') from SPD_Items i  
          where i.[ID] = @itemID
        if (@bit = 1 and @str != @StockCategoryDP) set @itemErrors = @itemErrors + 2
        
        --ComponentsSameStockingStrategyCode = 4 ' DP
        
        select @str = COALESCE(i.Stocking_Strategy_Code, '') from SPD_Items i 
          where i.[ID] = @itemID
        if (@str != @StockingStrategyCodeDP) set @itemErrors = @itemErrors + 4
        
        
        ----ComponentsSameHybridType = 4 ' DP
        
        --select @str = COALESCE(i.Hybrid_Type, '') from SPD_Items i 
        --  where i.[ID] = @itemID
        --if (@str != @HybridTypeDP) set @itemErrors = @itemErrors + 4
        
        ----ComponentsSameHybridSourcingDC = 8 ' DP
        
        --select @str = COALESCE(i.Hybrid_Source_DC, '') from SPD_Items i 
        --  where i.[ID] = @itemID
        --if (@str != @HybridSourceDCDP) set @itemErrors = @itemErrors + 8
        
        --ComponentsSameHierarchyD = 16 ' DP
        set @bit = 0
        select @bit = ISNULL(i.Valid_Existing_SKU, 0), @int = COALESCE(i.Department_Num, 0) from SPD_Items i 
          where i.[ID] = @itemID
        if (@bit = 1 and @int != @DepartmentNumDP) set @itemErrors = @itemErrors + 16
        
        --ComponentsSameHierarchyC = 32 ' DP
        
        select @int = COALESCE(i.Class_Num, 0) from SPD_Items i 
          where i.[ID] = @itemID
        if (@int != @ClassNumDP) set @itemErrors = @itemErrors + 32
        
        --ComponentsSameHierarchySC = 64 ' DP
        
        select @int = COALESCE(i.Sub_Class_Num, 0) from SPD_Items i 
          where i.[ID] = @itemID
        if (@int != @SubClassNumDP) set @itemErrors = @itemErrors + 64
        
        --ComponentsSameVendor = 128 ' DP
        DECLARE @items as integer
        Select @bigint = Sum(Primary_Indicator), @items = count(*) FROM (Select COALESCE(v.Primary_Indicator,1) as Primary_Indicator from SPD_Items as i
														Inner Join SPD_Item_Headers as ih on i.Item_Header_ID = ih.ID
														LEft Join SPD_Item_MAster_Vendor as v on v.Michaels_SKU = i.Michaels_SKU and v.Vendor_Number = ih.US_Vendor_Num
														WHERE ih.Batch_ID = @batchID ) as V
        If(COALESCE(@bigint,0) != @items) Set @itemErrors = @itemERrors + 128
        --select @bigint = COALESCE(ih.VendorNumber, 0) from SPD_Items i 
        --  inner join SPD_Item_Headers ih on i.[Item_Header_ID] = ih.[ID]
        --  where i.[ID] = @itemID
        --if (@bigint != @VendorNumberDP) set @itemErrors = @itemErrors + 128
      
      end
  
      declare @SKUGroupDDP varchar(50)
      declare @SKUGroup varchar(50)
      
      select 
        @SKUGroupDDP = COALESCE(ih.SKU_Group, '')
      from SPD_Item_Headers ih 
      where ih.[ID] = @itemHeaderID
      
      
      --ComponentsMustBeActive = 1024 ' D/DP
        
      --select @str = COALESCE(c1.[Field_Value], i.ItemStatus, '') from vwItemMaintItemDetail i 
      --  left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemStatus' and c1.[Counter] = 0 
      --  where i.[ID] = @itemID
      --if (ltrim(rtrim(@str)) != 'A') set @itemErrors = @itemErrors + 1024
        
      --ComponentsSameSkuGroup = 2048 ' D/DP
      -- REMOVED FROM THE SPEDY REQUIREMENTS
      -- NOPE PUT BACK IN
      if (@DPCount = 1)
      begin
        declare @VES bit
        select @VES = isnull(i.Valid_Existing_SKU, 0) from SPD_Items i where i.[ID] = @itemID
        if (@VES = 1)
        begin
          select @SKUGroup = COALESCE(v.SKUGroup, '') from SPD_Items i 
            inner join SPD_Item_Headers ih on i.Item_Header_ID = ih.[ID]
            inner join [vwItemMaintItemDetailBySKU] v on
	            v.SKU = i.Michaels_SKU and v.VendorNumber = COALESCE(ih.US_Vendor_Num, ih.Canadian_Vendor_Num, '') and v.VendorNumber != ''
            where i.[ID] = @itemID and (
              (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
            )
            
          if (@SKUGroupDDP != @SKUGroup) set @itemErrors = @itemErrors + 2048
        end 
      end
      
      
      select @parentID = i.[ID]
      from SPD_Items i 
      where i.Item_Header_ID = @itemHeaderID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[Pack_Item_Indicator], ''),2), '-', '')), '') in('DP','D')
      
      -- D/DP 
      --ComponentsSamePLI (Package Language Indicator)
      declare @parentPLI varchar(10)
      declare @childPLI varchar(10)
      SET @parentPLI = ''
	  SET @childPLI = ''
	  
      --English (PARENT)
      select @parentPLI = Coalesce(Package_Language_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @parentID and Language_Type_ID = 1
      --French (PARENT)
      select @parentPLI = @parentPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @parentID and Language_Type_ID = 2
      --SPanish (PARENT)
      select @parentPLI = @parentPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @parentID and Language_Type_ID = 3
      
      --English     
      select @childPLI = Coalesce(Package_Language_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @itemID and Language_Type_ID = 1
      --French
      select @childPLI = @childPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @itemID and Language_Type_ID = 2
      --SPanish
      select @childPLI = @childPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @itemID and Language_Type_ID = 3
      
      If(@parentPLI != @childPLI) set @itemErrors = @itemErrors + 262144
      
      --ComponentsSameTI (Translation Indicator)
      declare @parentTI varchar(10)
      declare @childTI varchar(10)
      SET @parentPLI = ''
	  SET @childTI = ''
	  
      --English (PARENT)
      select @parentTI = Coalesce(Translation_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @parentID and Language_Type_ID = 1
      --French (PARENT)
      select @parentTI = @parentTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @parentID and Language_Type_ID = 2
      --SPanish (PARENT)
      select @parentTI = @parentTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @parentID and Language_Type_ID = 3
      
      --English     
      select @childTI = Coalesce(Translation_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @itemID and Language_Type_ID = 1
      --French
      select @childTI = @childTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @itemID and Language_Type_ID = 2
      --SPanish
      select @childTI = @childTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Item_Languages as l1
      WHERE Item_ID = @itemID and Language_Type_ID = 3
      
      If(@parentTI != @childTI) set @itemErrors = @itemErrors + 524288
      
      --ComponentsQtyInPack = 4096 ' D/DP
      
      select @int = COALESCE(i.Qty_In_Pack, 0) from SPD_Items i 
        where i.[ID] = @itemID
      if (@int <= 0) set @itemErrors = @itemErrors + 4096


    end
    
   
  end
  
  if (@DCount = 1 AND @itemType = 'D')
      begin
        
        --ComponentsWarehouseSeasonalW = 256 ' D
        
        select @str = COALESCE(ih.Stock_Category, ih.Canada_Stock_Category, '') from SPD_Items i 
          inner join SPD_Item_Headers ih on i.[Item_Header_ID] = ih.[ID] 
          where i.[ID] = @itemID
        if (ltrim(rtrim(@str)) != 'W') set @itemErrors = @itemErrors + 256
        
        --ComponentsWarehouseSeasonalS = 512 'D
        
        select @str = COALESCE(ih.Item_Type_Attribute, '') from SPD_Items i 
          inner join SPD_Item_Headers ih on i.[Item_Header_ID] = ih.[ID] 
          where i.[ID] = @itemID
        if (ltrim(rtrim(@str)) != 'S') set @itemErrors = @itemErrors + 512
        
      end
  
  -- DDPActive = 8192
  set @str = ''
  set @bit = 0
  select @str = COALESCE(i.Item_Status, ''), @bit = COALESCE(i.Valid_Existing_SKU, 0) from SPD_Items i 
    where i.[ID] = @itemID
  if (@bit = 1 and ltrim(rtrim(@str)) = 'C') set @itemErrors = @itemErrors + 8192
  
  
  if (@itemType = 'D' or @itemType = 'DP')
  begin
    ---------------
    -- PACK SKUS --
    ---------------
    
    -- MultipleDDP = 16384
    if ( (@DCount + @DPCount) > 1 ) set @itemErrors = @itemErrors + 16384 
  end
  
  --DuplicateSKU = 32768
  select @int1 = count(i.[ID]) from SPD_Items i
    inner join (select ii.Michaels_SKU, count(ii.Michaels_SKU) as SKUCount from SPD_Items ii where ii.Item_Header_ID = @itemHeaderID group by ii.Michaels_SKU having count(ii.Michaels_SKU) > 1) t
      on i.Michaels_SKU = t.Michaels_SKU
  where i.[ID] = @itemID
  if (@int1 > 0) set @itemErrors = @itemErrors + 32768 


  --DuplicateComponent = 131072
  select @int1 = CASE WHEN S.Item_Type = 'C' AND EXISTS( 
						Select SKU2.[Item_Type] 
						From SPD_Item_Master_PackItems PKI
						JOIN SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU and PKI.Child_SKU = S.Michaels_SKU
						Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' and SKU2.Item_Status = 'A' ) 
					THEN 1
					ELSE 0 END
	FROM SPD_Items as i 
	INNER JOIN SPD_Item_Master_SKU as S on S.Michaels_SKU = i.Michaels_SKU
	WHERE i.ID = @itemID
  if (@int1 > 0) set @itemErrors = @itemErrors +  131072


  select @itemErrors as [ItemErrors]
  
  
  -- UPC AND ADDITIONAL UPCS
  
  declare @upc table(ID int identity(1,1), Sequence int, UPC varchar(20), UPCExists bit, DupBatch bit, DupWorkflow bit)
  -- primary upc
  insert into @upc (Sequence, UPC, UPCExists, DupBatch, DupWorkflow) 
  select 0, Vendor_UPC, 0, 0, 0 from SPD_Items where [ID] = @itemID
  -- additional upcs
  insert into @upc (Sequence, UPC, UPCExists, DupBatch, DupWorkflow) 
  select Sequence, Additional_UPC, 0, 0, 0 from SPD_Item_Additional_UPC where [Item_Header_ID] = @itemHeaderID and [Item_ID] = @itemID order by [Sequence]
  -- upc exists ?
  update @upc set UPCExists = 1
    where exists (select 1 from SPD_Item_Master_Vendor_UPCs v where v.UPC = [@upc].UPC)
    --where UPC in (select UPC from SPD_Item_Master_Vendor_UPCs)
    --where UPC in (select UPC from SPD_Item_Master)
    
    --where isnull((select count(1) from SPD_Item_Master m where m.UPC = [@upc].UPC),0) > 0
    --where UPC in (select UPC from SPD_Item_Master)
  -- duplicate in the batch ?
  update @upc set DupBatch = 1 
    where UPC in (select i.Vendor_UPC from SPD_Items i where i.Item_Header_ID = @itemHeaderID and i.[ID] != @itemID)
    or UPC in (select a.Additional_UPC from SPD_Item_Additional_UPC a where a.Item_Header_ID = @itemHeaderID and a.[Item_ID] != @itemID)
    or UPC in (select u.UPC from @upc u group by u.UPC having count(u.UPC) > 1)
  -- duplicate in workflow ?
  update @upc set DupWorkflow = 1 
    where UPC in (select i.Vendor_UPC from SPD_Items i 
      inner join SPD_Item_Headers ih on ih.[ID] = i.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ih.[ID] != @itemHeaderID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      ) 
    or 
    UPC in (select a.Additional_UPC from SPD_Item_Additional_UPC a 
      inner join SPD_Item_Headers ih on ih.[ID] = a.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where a.Item_Header_ID != @itemHeaderID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      )
    or
    UPC in (select i.PrimaryUPC from SPD_Import_Items i 
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      ) 
    or 
    UPC in (select a.Additional_UPC from SPD_Import_Item_Additional_UPC a 
      inner join SPD_Import_Items i on a.Import_Item_ID = i.[ID]
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      )
  -- delete the recs with no errors
  delete from @upc where UPCExists = 0 and DupBatch = 0 and DupWorkflow = 0
  -- return results
  select ID,Sequence,UPC,UPCExists,DupBatch,DupWorkflow from @upc
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateImportItem]    Script Date: 01/31/2018 14:11:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_SPD_Validation_ValidateImportItem]
  @itemID bigint
AS

  declare @itemErrors int
  set @itemErrors = 0
  
  declare @batchID bigint, @parentID int
  declare @batchType int
  declare @hid int
  declare @DPCount int
  declare @DCount int
  declare @CCount int
  declare @itemCount int
  declare @costParent money, @costChildren money
  declare @int1 int, @int2 int, @int3 int
  declare @str1 varchar(255)
  declare @reg bit
  
  declare @str varchar(20), @int int, @bigint bigint, @bit bit 
  
  --select @batchID = [BatchID] from vwItemMaintItemDetail where [ID] = @itemID
  select @batchID = [Batch_ID] from SPD_Import_Items where [ID] = @itemID
  
  select @batchType = Batch_Type_ID from SPD_Batch where [ID] = @batchID
  
  declare @itemType varchar(20)
  
  select @itemType = REPLACE(LEFT(COALESCE(i.PackItemIndicator, ''), 2), '-', '') from SPD_Import_Items i 
    where i.[ID] = @itemID
  
  
  -----------------------------
  -- IMPORT BATCH
  -----------------------------
  select @itemCount = isnull(count(1), 0) from SPD_Import_Items i where i.[Batch_ID] = @batchID
  
  select @DPCount = isnull(count(1), 0) from SPD_Import_Items i 
    where i.[Batch_ID] = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[PackItemIndicator], ''),2), '-', '')), '') = 'DP'
  
  select @DCount = isnull(count(1), 0) from SPD_Import_Items i 
    where i.[Batch_ID] = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[PackItemIndicator], ''),2), '-', '')), '') = 'D' 
  
  select @CCount = isnull(count(1), 0) from SPD_Import_Items i 
    where i.[Batch_ID] = @batchID and 
      ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )

  -- START ERRORS - IMPORT ---------------------------
  
  --None = 0

  ----------
  -- D/DP --
  ----------
  if ((@DPCount + @DCount) = 1)
  begin
  
    if (@itemType != 'D' and @itemType != 'DP')
    begin
    
      -- --------------------------------------------
      -- ONLY C (COMPONENT) ITEMS
      -- --------------------------------------------
      
      if (@DPCount = 1)
      begin
        
        declare @ItemTypeAttributeDP varchar(20) 
        declare @StockCategoryDP varchar(20)
        --declare @HybridTypeDP varchar(20)
        --declare @HybridSourceDCDP varchar(20)
        declare @StockingStrategyCodeDP nvarchar(20)
        declare @DepartmentNumDP int, @ClassNumDP int, @SubClassNumDP int 
        declare @VendorNumberDP bigint -- header
        set @parentID = 0
        select @parentID = i.[ID]
        from SPD_Import_Items i 
        where i.[Batch_ID] = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[PackItemIndicator], ''),2), '-', '')), '') = 'DP'
        
        select 
          @ItemTypeAttributeDP = COALESCE(i.ItemTypeAttribute, ''),
          @StockCategoryDP = COALESCE(i.StockCategory, ''),
          --@HybridTypeDP = COALESCE(i.HybridType, ''),
          --@HybridSourceDCDP = COALESCE(i.SourcingDC, ''),
          @StockingStrategyCodeDP = COALESCE(i.Stocking_Strategy_Code,''),
          @DepartmentNumDP = COALESCE(i.Dept, 0),
          @ClassNumDP = COALESCE(i.Class, 0),
          @SubClassNumDP = COALESCE(i.SubClass, 0),
          @VendorNumberDP = COALESCE(i.VendorNumber, 0)
        from SPD_Import_Items i 
        where i.[ID] = @parentID
      
        --ComponentsSameItemTypeAttribute = 1 ' DP
        
        select @str = COALESCE(i.ItemTypeAttribute, '') from SPD_Import_Items i
          where i.[ID] = @itemID
        if (@str != @ItemTypeAttributeDP) set @itemErrors = @itemErrors + 1
        
        --ComponentsSameStockCategory = 2 ' DP
        
        select @str = COALESCE(i.StockCategory, '') from SPD_Import_Items i 
          where i.[ID] = @itemID
        if (@str != @StockCategoryDP) set @itemErrors = @itemErrors + 2
        
        --ComponentsSameStockingStrategyCode = 4 ' DP  'reusing 4
        
        select @str = COALESCE(i.Stocking_Strategy_Code, '') from SPD_Import_Items i 
          where i.[ID] = @itemID
        if (@str != @StockingStrategyCodeDP) set @itemErrors = @itemErrors + 4
        
        ----ComponentsSameHybridType = 4 ' DP
        
        --select @str = COALESCE(i.HybridType, '') from SPD_Import_Items i 
        --  where i.[ID] = @itemID
        --if (@str != @HybridTypeDP) set @itemErrors = @itemErrors + 4
        
        --ComponentsSameHybridSourcingDC = 8 ' DP
        
        --select @str = COALESCE(i.SourcingDC, '') from SPD_Import_Items i 
        --  where i.[ID] = @itemID
        --if (@str != @HybridSourceDCDP) set @itemErrors = @itemErrors + 8
        
        --ComponentsSameHierarchyD = 16 ' DP
        
        select @int = COALESCE(i.Dept, 0) from SPD_Import_Items i 
          where i.[ID] = @itemID
        if (@int != @DepartmentNumDP) set @itemErrors = @itemErrors + 16
        
        --ComponentsSameHierarchyC = 32 ' DP
        
        select @int = COALESCE(i.Class, 0) from SPD_Import_Items i 
          where i.[ID] = @itemID
        if (@int != @ClassNumDP) set @itemErrors = @itemErrors + 32
        
        --ComponentsSameHierarchySC = 64 ' DP
        
        select @int = COALESCE(i.SubClass, 0) from SPD_Import_Items i 
          where i.[ID] = @itemID
        if (@int != @SubClassNumDP) set @itemErrors = @itemErrors + 64
        
        --ComponentsSameVendor = 128 ' DP
        
        select @bigint = COALESCE(i.VendorNumber, 0) from SPD_Import_Items i 
          where i.[ID] = @itemID
        if (@bigint != @VendorNumberDP) set @itemErrors = @itemErrors + 128
      
      end
      
      --Get Parent Item Information
      declare @SKUGroupDDP varchar(50)
      declare @SKUGroup varchar(50)
      set @parentID = 0
      select @parentID = i.[ID]
      from SPD_Import_Items i 
      where i.Batch_ID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[PackItemIndicator], ''),2), '-', '')), '') IN ('D','DP')
      
      select @SKUGroupDDP = COALESCE(i.SKUGroup, '')
      from SPD_Import_Items i 
      where i.[ID] = @parentID

      
      -- D/DP 
      --ComponentsSamePLI (Package Language Indicator)
      declare @parentPLI varchar(10)
      declare @childPLI varchar(10)
	  SET @parentPLI = ''
	  SET @childPLI = ''
      
      --English (PARENT)
      select @parentPLI = Coalesce(Package_Language_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @parentID and Language_Type_ID = 1
      --French (PARENT)
      select @parentPLI = @parentPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @parentID and Language_Type_ID = 2
      --SPanish (PARENT)
      select @parentPLI = @parentPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @parentID and Language_Type_ID = 3
   
      --English     
      select @childPLI = Coalesce(Package_Language_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @itemID and Language_Type_ID = 1
      --French
      select @childPLI = @childPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @itemID and Language_Type_ID = 2
      --SPanish
      select @childPLI = @childPLI + Coalesce(Package_Language_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @itemID and Language_Type_ID = 3

      If(@parentPLI != @childPLI) set @itemErrors = @itemErrors + 262144 
      
       --ComponentsSameTI (Translation Indicator)
      declare @parentTI varchar(10)
      declare @childTI varchar(10)
	  SET @parentTI = ''
	  SET @childTI = ''
      
      --English (PARENT)
      select @parentTI = Coalesce(Translation_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @parentID and Language_Type_ID = 1
      --French (PARENT)
      select @parentTI = @parentTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @parentID and Language_Type_ID = 2
      --SPanish (PARENT)
      select @parentTI = @parentTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @parentID and Language_Type_ID = 3
   
      --English     
      select @childTI = Coalesce(Translation_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @itemID and Language_Type_ID = 1
      --French
      select @childTI = @childTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @itemID and Language_Type_ID = 2
      --SPanish
      select @childTI = @childTI + Coalesce(Translation_Indicator, 'B')
      from SPD_Import_Item_Languages as l1
      WHERE Import_Item_ID = @itemID and Language_Type_ID = 3

      If(@parentTI != @childTI) set @itemErrors = @itemErrors + 524288 


      --ComponentsSameSkuGroup = 2048 ' D/DP
      -- REMOVED FROM THE SPEDY REQUIREMENTS  
      -- NOPE PUT BACK IN FOR DP
      if (@DPCount = 1)
      begin
        select @SKUGroup = COALESCE(i.SKUGroup, '') from SPD_Import_Items i 
          where i.[ID] = @itemID
        if (@SKUGroupDDP != @SKUGroup) set @itemErrors = @itemErrors + 2048
      end
      
      --ComponentsQtyInPack = 4096 ' D/DP
      
      select @int = COALESCE(i.Qty_In_Pack, 0) from SPD_Import_Items i 
        where i.[ID] = @itemID
      if (@int <= 0) set @itemErrors = @itemErrors + 4096
          
    end    -- @itemType != 'D' and @itemType != 'DP'

    if (@DCount = 1 and @itemType = 'D')
    begin
      
      --DisplayerWarehouseSeasonalW = 256 ' D
      set @str = ''
      select @str = COALESCE(i.StockCategory, '') from SPD_Import_Items i 
        where i.[ID] = @itemID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[PackItemIndicator], ''),2), '-', '')), '') IN ('D')
      if (ltrim(rtrim(@str)) != 'W') set @itemErrors = @itemErrors + 256
      
      --DisplayerWarehouseSeasonalS = 512 'D
      set @str = ''
      select @str = COALESCE(i.ItemTypeAttribute, '') from SPD_Import_Items i 
        where i.[ID] = @itemID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(i.[PackItemIndicator], ''),2), '-', '')), '') IN ('D')
      if (ltrim(rtrim(@str)) != 'S') set @itemErrors = @itemErrors + 512
      
    end


  end
   
  -- DDPActive = 8192
  set @str = ''
  set @bit = 0
  select @str = COALESCE(i.Item_Status, ''), @bit = COALESCE(i.Valid_Existing_SKU, 0) from SPD_Import_Items i 
    where i.[ID] = @itemID
  if (@bit = 1 and ltrim(rtrim(@str)) = 'C') set @itemErrors = @itemErrors + 8192
  
  if (@itemType = 'D' or @itemType = 'DP')
  begin
    ---------------
    -- PACK SKUS --
    ---------------
    
    -- MultipleDDP = 16384
    if ( (@DCount + @DPCount) > 1 ) set @itemErrors = @itemErrors + 16384 

  end

  --DuplicateSKU = 32768
  select @int1 = count(i.[ID]) from SPD_Import_items i
    inner join (select ii.MichaelsSKU, count(ii.MichaelsSKU) as SKUCount from SPD_Import_items ii where ii.Batch_ID = @batchID group by ii.MichaelsSKU having count(ii.MichaelsSKU) > 1) t
      on i.MichaelsSKU = t.MichaelsSKU
  where i.[ID] = @itemID
  if (@int1 > 0) set @itemErrors = @itemErrors + 32768 



  --DuplicateComponent = 131072
  select @int1 = CASE WHEN S.Item_Type = 'C' AND EXISTS( 
						Select SKU2.[Item_Type] 
						From SPD_Item_Master_PackItems PKI
						JOIN SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU and PKI.Child_SKU = S.Michaels_SKU
						Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' and SKU2.Item_Status = 'A' ) 
					THEN 1
					ELSE 0 END
	FROM SPD_Import_Items as i 
	INNER JOIN SPD_Item_Master_SKU as S on S.Michaels_SKU = i.MichaelsSKU
	WHERE i.ID = @itemID
  if (@int1 > 0) set @itemErrors = @itemErrors +  131072
  
  
  
  -- END ERRORS - IMPORT ---------------------------


  select @itemErrors as [ItemErrors]
  
  
  -- UPC AND ADDITIONAL UPCS
  
  declare @upc table(ID int identity(1,1), Sequence int, UPC varchar(20), UPCExists bit, DupBatch bit, DupWorkflow bit)
  -- primary upc
  insert into @upc (Sequence, UPC, UPCExists, DupBatch, DupWorkflow) 
  select 0, PrimaryUPC, 0, 0, 0 from SPD_Import_Items where [ID] = @itemID
  -- additional upcs
  insert into @upc (Sequence, UPC, UPCExists, DupBatch, DupWorkflow) 
  select Sequence, Additional_UPC, 0, 0, 0 from SPD_Import_Item_Additional_UPC where [Import_Item_ID] = @itemID order by [Sequence]
  -- upc exists ?
  update @upc set UPCExists = 1
    where exists (select 1 from SPD_Item_Master_Vendor_UPCs v where v.UPC = [@upc].UPC)
    --where UPC in (select UPC from SPD_Item_Master_Vendor_UPCs)
    --where UPC in (select UPC from SPD_Item_Master)
    --where isnull((select count(1) from SPD_Item_Master m where m.UPC = [@upc].UPC),0) > 0
    --where UPC in (select UPC from SPD_Item_Master)
  -- duplicate in the batch ?
  update @upc set DupBatch = 1 
    where UPC in (select i.PrimaryUPC from SPD_Import_Items i where i.Batch_ID = @batchID and i.[ID] != @itemID)
    or UPC in (select a.Additional_UPC from SPD_Import_Item_Additional_UPC a where a.[Import_Item_ID] != @itemID and a.[Import_Item_ID] in (select [ID] from SPD_Import_Items where Batch_ID = @batchID))
    or UPC in (select u.UPC from @upc u group by u.UPC having count(u.UPC) > 1)
  -- duplicate in workflow ?
  update @upc set DupWorkflow = 1 
    where UPC in (select i.PrimaryUPC from SPD_Import_Items i 
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where b.[ID] != @batchID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      ) 
    or 
    UPC in (select a.Additional_UPC from SPD_Import_Item_Additional_UPC a 
      inner join SPD_Import_Items i on a.Import_Item_ID = i.[ID]
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where b.ID != @batchID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      )
    or
    UPC in (select i.Vendor_UPC from SPD_Items i 
      inner join SPD_Item_Headers ih on ih.[ID] = i.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      ) 
    or 
    UPC in (select a.Additional_UPC from SPD_Item_Additional_UPC a 
      inner join SPD_Item_Headers ih on ih.[ID] = a.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      )
  -- delete the recs with no errors
  delete from @upc where UPCExists = 0 and DupBatch = 0 and DupWorkflow = 0
  -- return results
  select ID,Sequence,UPC,UPCExists,DupBatch,DupWorkflow from @upc
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateBatch]    Script Date: 01/31/2018 14:11:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_SPD_Validation_ValidateBatch]
  @batchID bigint
AS

  declare @batchErrors int
  set @batchErrors = 0
  
  declare @batchType int
  declare @hid int
  declare @DPCount int
  declare @DCount int
  declare @CCount int
  declare @itemCount int
  declare @costParent money, @costChildren money
  declare @int1 int, @int2 int, @int3 int
  declare @str1 varchar(255)
  declare @reg bit
  declare @US varchar(50), @CANADA varchar(50), @BOTH varchar(50)
  declare @SKUGroupD varchar(50)
  declare @d int
  
  
  select @batchType = Batch_Type_ID from SPD_Batch where [ID] = @batchID
  
  if (@batchType = 2)
  begin
    -----------------------------
    -- IMPORT BATCH
    -----------------------------
    --select @hid = [ID] from SPD_Item_Headers where Batch_ID = @batchID
    select @itemCount = isnull(count(1), 0) from SPD_Import_Items i where i.Batch_ID = @batchID
    select @DPCount = isnull(count(1), 0) from SPD_Import_Items i where i.Batch_ID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'DP' and COALESCE(i.[RegularBatchItem], 0) = 0
    select @DCount = isnull(count(1), 0) from SPD_Import_Items i where i.Batch_ID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'D' and COALESCE(i.[RegularBatchItem], 0) = 0
    select @CCount = isnull(count(1), 0) from SPD_Import_Items i 
      where i.Batch_ID = @batchID 
        and 
        (
          COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' 
          or
          ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
        )
        and COALESCE(i.[RegularBatchItem], 0) = 0
    
    -- START ERRORS - IMPORT ---------------------------
    
    --None = 0
    --DDPMultipleParents = 1
    if ((@DPCount + @DCount) > 1) set @batchErrors = @batchErrors + 1
    --DDPNoComponents = 2
    if ((@DPCount + @DCount) >= 1 and @CCount <= 0) set @batchErrors = @batchErrors + 2
    --DDPMissingParent = 4
    if (@CCount >= 1 and (@DPCount + @DCount) <= 0) set @batchErrors = @batchErrors + 4
    --DDPMissingTypes = 8
    if ( (@DPCount > 0 or @DCount > 0 or @CCount > 0) and ( (@CCount + @DCount + @DPCount) != @itemCount)) set @batchErrors = @batchErrors + 8
    ----------
    -- D/DP --
    ----------
    if ((@DPCount + @DCount) = 1)
    begin
      --DDPComponentsNotActive = 16
      -- ... currently, not enough data to implement this validation rule !
      --DDPPackCost1NotEqual = 32
      select @costParent = sum(coalesce(convert(decimal(18, 6), i.Product_Cost), 0)) from SPD_Import_Items i where i.Batch_ID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') IN ('DP', 'D')
      select @costChildren = sum(isnull(i.Qty_In_Pack, 0) * coalesce(convert(decimal(18, 6), i.Product_Cost), 0)) from SPD_Import_Items i where i.Batch_ID = @batchID and 
        ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
      if (isnull(@costParent, 0) != isnull(@costChildren, 0)) set @batchErrors = @batchErrors + 32
      -------select @costParent as [PARENT], @costChildren as [CHILDREN]
      --DDPPackCost2NotEqual = 64
      -- ... not needed for Import Batch
      
      ------------
      -- DP ONLY --
      ------------
      if (@DPCount = 1)
      begin
        --DDPSameSKUGroup = 128
        -- REMOVED FROM THE SPEDY REQUIREMENTS
        -- NOPE PUT BACK FOR DP ONLY
        select @int1 = count(distinct i.SKUGroup) from SPD_Import_Items i where i.Batch_ID = @batchID
        if (@int1 > 1) set @batchErrors = @batchErrors + 128
        --DPComponentsSameItemTypeAttribute = 256
        select @int1 = count(distinct i.ItemTypeAttribute) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        if (@int1 > 1) set @batchErrors = @batchErrors + 256
        --DPComponentsSameStockCategory = 512
        select @int1 = count(distinct i.StockCategory) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        if (@int1 > 1) set @batchErrors = @batchErrors + 512
        
        --DPComponentsSameStockingStrategyCode = 1024
        select @int1 = count(distinct i.Stocking_Strategy_Code) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        if (@int1 > 1) set @batchErrors = @batchErrors + 1024
        
        ----DPComponentsSameHybridInfo = 1024
        --select @int1 = count(distinct i.HybridType) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        --select @int2 = count(distinct i.SourcingDC) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        --if (@int1 > 1 or @int2 > 1) set @batchErrors = @batchErrors + 1024
        
        --DPSamePrimaryVendor = 2048
        select @int1 = count(distinct i.Vendor) from SPD_Import_Items i where i.Batch_ID = @batchID
        if (@int1 > 1) set @batchErrors = @batchErrors + 2048
        --DPComponentsSameHierarchy = 4096
        select @int1 = count(distinct i.Class) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        select @int2 = count(distinct i.SubClass) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        select @int3 = count(distinct i.Dept) from SPD_Import_Items i where i.Batch_ID = @batchID and ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'C' or ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        if (@int1 > 1 or @int2 > 1 or @int3 > 1) set @batchErrors = @batchErrors + 4096
      end 
      
      ------------
      -- D ONLY --
      ------------
      if (@DCount = 1)
      begin
        --SKUGroupRules = 131072
        select @US = 'US ONLY'
        select @CANADA = 'CANADA ONLY'
        select @BOTH = 'US AND CANADA'
        select @SKUGroupD = RTRIM(LTRIM(UPPER(SKUGroup))) from SPD_Import_Items i where i.Batch_ID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],2), '-', '')), '') = 'D' and COALESCE(i.[RegularBatchItem], 0) = 0
        select @d = case @SKUGroupD
          when @US then 1
          when @CANADA then 2
          when @BOTH then 3
          else 0
          end
        -- US
        select @int1 = isnull(count(1), 0) from SPD_Import_Items i 
          where i.Batch_ID = @batchID and (
              COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') = 'C' 
              or
              ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
            ) and COALESCE(i.[RegularBatchItem], 0) = 0 
            and SKUGroup = @US
        -- CANADA
        select @int2 = isnull(count(1), 0) from SPD_Import_Items i 
          where i.Batch_ID = @batchID and (
              COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') = 'C' 
              or
              ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
            ) and COALESCE(i.[RegularBatchItem], 0) = 0 
            and SKUGroup = @CANADA
        -- BOTH
        select @int3 = isnull(count(1), 0) from SPD_Import_Items i 
          where i.Batch_ID = @batchID and (
              COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') = 'C' 
              or
              ( COALESCE(RTRIM(REPLACE(LEFT(i.[PackItemIndicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
            ) and COALESCE(i.[RegularBatchItem], 0) = 0 
            and SKUGroup = @BOTH
        -- COMPARE
        if (
          (@int1 = 0 and @int2 = 0 and @int3 > 0 and @d = 0) or
          (@int1 = 0 and @int2 > 0 and @int3 = 0 and @d != 2) or
          (@int1 > 0 and @int2 = 0 and @int3 = 0 and @d != 1) or
          (@int1 > 0 and @int2 = 0 and @int3 > 0 and @d != 1) or
          (@int1 = 0 and @int2 > 0 and @int3 > 0 and @d != 2) or
          (@int1 > 0 and @int2 > 0) or
          (@int1 > 0 and @int2 > 0 and @int3 > 0))
        begin
          set @batchErrors = @batchErrors + 131072
        end
      end -- if (@DCount = 1)
      
    end
    
    --DuplicateSKUs = 65536
    select @int1 = count(i.[ID]) from SPD_Import_items i
      inner join (select ii.MichaelsSKU, count(ii.MichaelsSKU) as SKUCount from SPD_Import_items ii where ii.Batch_ID = @batchID group by ii.MichaelsSKU having count(ii.MichaelsSKU) > 1) t
        on i.MichaelsSKU = t.MichaelsSKU
    where i.[Batch_ID] = @batchID
    if (@int1 > 0) set @batchErrors = @batchErrors + 65536
    
    -- END ERRORS - IMPORT ---------------------------
  end
  else
  begin
    -----------------------------
    -- DOMESTIC BATCH
    -----------------------------
    select @hid = [ID] from SPD_Item_Headers where Batch_ID = @batchID
    select @itemCount = isnull(count(1), 0) from SPD_Items i where i.Item_Header_ID = @hid
    select @DPCount = isnull(count(1), 0) from SPD_Items i where i.Item_Header_ID = @hid and COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'DP'
    select @DCount = isnull(count(1), 0) from SPD_Items i where i.Item_Header_ID = @hid and COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'D'
    select @CCount = isnull(count(1), 0) 
      from SPD_Items i 
      where i.Item_Header_ID = @hid 
      and 
      (
        COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C'
        or
        (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
      )
    
    -- START ERRORS - DOMESTIC ---------------------------
    
    --None = 0
    --DDPMultipleParents = 1
    if ((@DPCount + @DCount) > 1) set @batchErrors = @batchErrors + 1
    --DDPNoComponents = 2
    if ((@DPCount + @DCount) >= 1 and @CCount <= 0) set @batchErrors = @batchErrors + 2
    --DDPMissingParent = 4
    if (@CCount >= 1 and (@DPCount + @DCount) <= 0) set @batchErrors = @batchErrors + 4
    --DDPMissingTypes = 8
    if ( (@DPCount > 0 or @DCount > 0 or @CCount > 0) and ( (@CCount + @DCount + @DPCount) != @itemCount)) set @batchErrors = @batchErrors + 8
    ----------
    -- D/DP --
    ----------
    if ((@DPCount + @DCount) = 1)
    begin
      --DDPComponentsNotActive = 16
      -- ... currently, not enough data to implement this validation rule !
      --DDPPackCost1NotEqual = 32
      select @costParent = sum(i.US_Cost) from SPD_Items i where i.Item_Header_ID = @hid and COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') IN ('DP', 'D')
      select @costChildren = sum(isnull(i.Qty_In_Pack, 1) * isnull(i.Us_Cost, 0)) from SPD_Items i where i.Item_Header_ID = @hid and ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
      if (isnull(@costParent, 0) != isnull(@costChildren, 0)) set @batchErrors = @batchErrors + 32
      --DDPPackCost2NotEqual = 64
      select @costParent = sum(i.Canada_Cost) from SPD_Items i where i.Item_Header_ID = @hid and COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') IN ('DP', 'D')
      select @costChildren = sum(isnull(i.Qty_In_Pack, 1) * isnull(i.Canada_Cost, 0)) from SPD_Items i where i.Item_Header_ID = @hid and ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
      if (isnull(@costParent, 0) != isnull(@costChildren, 0)) set @batchErrors = @batchErrors + 64
      
      
      
      ------------
      -- DP ONLY --
      ------------
      if (@DPCount = 1)
      begin
        --DDPSameSKUGroup = 128
        select @int1 = isnull(count(1), 0) from SPD_Items i 
          inner join SPD_Item_Headers ih on i.Item_Header_ID = ih.[ID]
          inner join [vwItemMaintItemDetailBySKU] v on
		        v.SKU = i.Michaels_SKU and v.VendorNumber = COALESCE(ih.US_Vendor_Num, ih.Canadian_Vendor_Num, '') and v.VendorNumber != ''
          where i.Item_Header_ID = @hid and (
            (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
          ) and v.SKUGroup != ih.SKU_Group
          
        if (@int1 > 0) set @batchErrors = @batchErrors + 128 
        
        --DPComponentsSameItemTypeAttribute = 256
        -- ... not needed for Domestic because Item_Type_Attribute is in the header !
        --DPComponentsSameStockCategory = 512
        -- ... not needed for Domestic because Stock_Category is in the header !
        
        --DPComponentsSameStockingStrategyCode = 1024
        select @int1 = count(distinct i.Stocking_Strategy_Code) from SPD_Items i where i.Item_Header_ID = @hid and ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        if (@int1 > 1) set @batchErrors = @batchErrors + 1024
        
        ----DPComponentsSameHybridInfo = 1024
        --select @int1 = count(distinct i.Hybrid_Type) from SPD_Items i where i.Item_Header_ID = @hid and ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        --select @int2 = count(distinct i.Hybrid_Source_DC) from SPD_items i where i.Item_Header_ID = @hid and ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        --if (@int1 > 1 or @int2 > 1) set @batchErrors = @batchErrors + 1024
        
        
        --DPSamePrimaryVendor = 2048
        -- ... not needed for Domestic because Vendor is in the header !
        --DPComponentsSameHierarchy = 4096
        select @int1 = count(distinct i.Class_Num) from SPD_Items i where i.Item_Header_ID = @hid and ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        select @int2 = count(distinct i.Sub_Class_Num) from SPD_items i where i.Item_Header_ID = @hid and ( COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],2), '-', '')), '') = 'C' or (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1) )
        if (@int1 > 1 or @int2 > 1) set @batchErrors = @batchErrors + 4096
      end 
      ------------
      -- D ONLY --
      ------------
      if (@DCount = 1)
      begin
        --SKUGroupRules = 131072
        select @US = 'US ONLY'
        select @CANADA = 'CANADA ONLY'
        select @BOTH = 'US AND CANADA'
        select @SKUGroupD = RTRIM(LTRIM(UPPER(SKU_Group))) from SPD_Item_Headers i where i.[ID] = @hid
        select @d = case @SKUGroupD
          when @US then 1
          when @CANADA then 2
          when @BOTH then 3
          else 0
          end
        -- US
        select @int1 = isnull(count(1), 0) from SPD_Items i 
          inner join SPD_Item_Headers ih on i.Item_Header_ID = ih.[ID]
          inner join [vwItemMaintItemDetailBySKU] v on
		        v.SKU = i.Michaels_SKU and v.VendorNumber = COALESCE(ih.US_Vendor_Num, ih.Canadian_Vendor_Num, '') and v.VendorNumber != ''
          where i.Item_Header_ID = @hid and (
            (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
          ) and v.SKUGroup = @US
        -- CANADA
        select @int2 = isnull(count(1), 0) from SPD_Items i 
          inner join SPD_Item_Headers ih on i.Item_Header_ID = ih.[ID]
          inner join [vwItemMaintItemDetailBySKU] v on
		        v.SKU = i.Michaels_SKU and v.VendorNumber = COALESCE(ih.US_Vendor_Num, ih.Canadian_Vendor_Num, '') and v.VendorNumber != ''
          where i.Item_Header_ID = @hid and (
            (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
          ) and v.SKUGroup = @CANADA
        -- BOTH
        select @int3 = isnull(count(1), 0) from SPD_Items i 
          inner join SPD_Item_Headers ih on i.Item_Header_ID = ih.[ID]
          inner join [vwItemMaintItemDetailBySKU] v on
		        v.SKU = i.Michaels_SKU and v.VendorNumber = COALESCE(ih.US_Vendor_Num, ih.Canadian_Vendor_Num, '') and v.VendorNumber != ''
          where i.Item_Header_ID = @hid and (
            (COALESCE(RTRIM(REPLACE(LEFT(i.[Pack_Item_Indicator],1), '-', '')), '') != 'D' and isnull(i.Valid_Existing_SKU, 0) = 1)
          ) and v.SKUGroup = @BOTH
        -- COMPARE
        if (
          (@int1 = 0 and @int2 = 0 and @int3 > 0 and @d = 0) or
          (@int1 = 0 and @int2 > 0 and @int3 = 0 and @d != 2) or
          (@int1 > 0 and @int2 = 0 and @int3 = 0 and @d != 1) or
          (@int1 > 0 and @int2 = 0 and @int3 > 0 and @d != 1) or
          (@int1 = 0 and @int2 > 0 and @int3 > 0 and @d != 2) or
          (@int1 > 0 and @int2 > 0) or
          (@int1 > 0 and @int2 > 0 and @int3 > 0))
        begin
          set @batchErrors = @batchErrors + 131072
        end
      end -- if (@DCount = 1)
      
    end
    
    --DuplicateSKUs = 65536
    select @int1 = count(i.[ID]) from SPD_Items i
      inner join (select ii.Michaels_SKU, count(ii.Michaels_SKU) as SKUCount from SPD_Items ii where ii.Item_Header_ID = @hid group by ii.Michaels_SKU having count(ii.Michaels_SKU) > 1) t
        on i.Michaels_SKU = t.Michaels_SKU
    where i.Item_Header_ID = @hid
    if (@int1 > 0) set @batchErrors = @batchErrors + 65536
    
    -- END ERRORS - DOMESTIC ---------------------------
  end



  select @batchErrors as [BatchErrors]
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateItemMaintItem]    Script Date: 01/31/2018 14:11:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_SPD_Validation_ValidateItemMaintItem]
  @itemID int
AS

  declare @itemErrors int
  set @itemErrors = 0
  
  declare @batchID bigint, @parentID int
  declare @VendorNumber bigint
  declare @batchType int
  declare @hid int
  declare @DPCount int
  declare @DCount int
  declare @CCount int
  declare @itemCount int
  declare @costParent money, @costChildren money
  declare @int1 int, @int2 int, @int3 int
  declare @str1 varchar(255)
  declare @reg bit
  declare @t table (id int identity(1,1), SKU varchar(20), VendorNumber bigint, child bit)
  
  SET NOCOUNT ON
  
  --select @batchID = [BatchID] from vwItemMaintItemDetail where [ID] = @itemID
  select @batchID = [Batch_ID], @VendorNumber = Vendor_Number from SPD_Item_Maint_Items where [ID] = @itemID
  
  select @batchType = Batch_Type_ID from SPD_Batch where [ID] = @batchID
  
  declare @itemType varchar(5)
  
  select @itemType = REPLACE(LEFT(COALESCE(c1.[Field_Value], i.PackItemIndicator, ''), 2), '-', '') from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'PackItemIndicator' and c1.[Counter] = 0 
          where i.[ID] = @itemID
  
  -----------------------------
  -- ITEM MAINT >> IMPORT / DOMESTIC BATCH
  -----------------------------
  select @itemCount = isnull(count(1), 0) from vwItemMaintItemDetail i where i.BatchID = @batchID
  
  select @DPCount = isnull(count(1), 0) from vwItemMaintItemDetail i 
    left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
    where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') = 'DP'
  
  select @DCount = isnull(count(1), 0) from vwItemMaintItemDetail i 
    left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
    where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') = 'D' 
  
  select @CCount = isnull(count(1), 0) from vwItemMaintItemDetail i 
    left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
    where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') = 'C' 
  
  -- START ERRORS - IMPORT / DOMESTIC ---------------------------
  
  --None = 0

  ----------
  -- D/DP --
  ----------
  if ((@DPCount + @DCount) = 1)
  begin
  
    declare @str varchar(5), @int int, @bigint bigint
  
    if(@itemType != 'D' and @itemType != 'DP')
    begin
    
      -- --------------------------------------------
      -- ONLY C (COMPONENT) ITEMS
      -- --------------------------------------------
      
      --select @parentID = i.[ID]
      --from vwItemMaintItemDetail i 
      --  left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      --where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),1), '-', '')), '') = 'D'
    
      if (@DPCount = 1)
      begin
        
        declare @ItemTypeAttributeDP varchar(5)
        declare @StockCategoryDP varchar(5)
        --declare @HybridTypeDP varchar(5)
        --declare @HybridSourceDCDP varchar(5)
        declare @StockingStrategyCodeDP nvarchar(20)
        declare @DepartmentNumDP int, @ClassNumDP int, @SubClassNumDP int
        declare @VendorNumberDP bigint
        
        select @parentID = i.[ID]
        from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
        where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') = 'DP'
        
        select 
          @ItemTypeAttributeDP = COALESCE(c1.[Field_Value], i.ItemTypeAttribute, ''),
          @StockCategoryDP = COALESCE(c2.[Field_Value], i.StockCategory, ''),
          --@HybridTypeDP = COALESCE(c3.[Field_Value], i.HybridType, ''),
          --@HybridSourceDCDP = COALESCE(c4.[Field_Value], i.HybridSourceDC, ''),
          @StockingStrategyCodeDP = COALESCE(c3.[Field_Value], i.StockingStrategyCode, ''),
          @DepartmentNumDP = CONVERT(int, COALESCE(c5.[Field_Value], i.DepartmentNum, 0)),
          @ClassNumDP = CONVERT(int, COALESCE(c6.[Field_Value], i.ClassNum, 0)),
          @SubClassNumDP = CONVERT(int, COALESCE(c7.[Field_Value], i.SubClassNum, 0)),
          @VendorNumberDP = CONVERT(bigint, COALESCE(c8.[Field_Value], i.VendorNumber, 0))
        from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemTypeAttribute' and c1.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c2 ON i.[ID] = c2.[Item_Maint_Items_ID] and c2.[Field_Name] = 'StockCategory' and c2.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c3 ON i.[ID] = c3.[Item_Maint_Items_ID] and c3.[Field_Name] = 'StockingStrategyCode' and c3.[Counter] = 0 
          --left outer join SPD_Item_Master_Changes c3 ON i.[ID] = c3.[Item_Maint_Items_ID] and c3.[Field_Name] = 'HybridType' and c3.[Counter] = 0 
          --left outer join SPD_Item_Master_Changes c4 ON i.[ID] = c4.[Item_Maint_Items_ID] and c4.[Field_Name] = 'HybridSourceDC' and c4.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c5 ON i.[ID] = c5.[Item_Maint_Items_ID] and c5.[Field_Name] = 'DepartmentNum' and c5.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c6 ON i.[ID] = c6.[Item_Maint_Items_ID] and c6.[Field_Name] = 'ClassNum' and c6.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c7 ON i.[ID] = c7.[Item_Maint_Items_ID] and c7.[Field_Name] = 'SubClassNum' and c7.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c8 ON i.[ID] = c8.[Item_Maint_Items_ID] and c8.[Field_Name] = 'VendorNumber' and c8.[Counter] = 0 
        where i.[ID] = @parentID
      
        --ComponentsSameItemTypeAttribute = 1 ' DP
        
        select @str = COALESCE(c1.[Field_Value], i.ItemTypeAttribute, '') from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemTypeAttribute' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@str != @ItemTypeAttributeDP) set @itemErrors = @itemErrors + 1
        
        --ComponentsSameStockCategory = 2 ' DP
        
        select @str = COALESCE(c1.[Field_Value], i.StockCategory, '') from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'StockCategory' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@str != @StockCategoryDP) set @itemErrors = @itemErrors + 2
        
        
        --ComponentsSameHybridType = 4 ' DP
        
        select @str = COALESCE(c1.[Field_Value], i.StockingStrategyCode, '') from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'StockingStrategyCode' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@str != @StockingStrategyCodeDP) set @itemErrors = @itemErrors + 4
        
        ----ComponentsSameHybridType = 4 ' DP
        
        --select @str = COALESCE(c1.[Field_Value], i.HybridType, '') from vwItemMaintItemDetail i 
        --  left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'HybridType' and c1.[Counter] = 0 
        --  where i.[ID] = @itemID
        --if (@str != @HybridTypeDP) set @itemErrors = @itemErrors + 4
        
        ----ComponentsSameHybridSourcingDC = 8 ' DP
        
        --select @str = COALESCE(c1.[Field_Value], i.HybridSourceDC, '') from vwItemMaintItemDetail i 
        --  left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'HybridSourceDC' and c1.[Counter] = 0 
        --  where i.[ID] = @itemID
        --if (@str != @HybridSourceDCDP) set @itemErrors = @itemErrors + 8
        
        --ComponentsSameHierarchyD = 16 ' DP
        
        select @int = CONVERT(int, COALESCE(c1.[Field_Value], i.DepartmentNum, 0)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'DepartmentNum' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@int != @DepartmentNumDP) set @itemErrors = @itemErrors + 16
        
        --ComponentsSameHierarchyC = 32 ' DP
        
        select @int = CONVERT(int, COALESCE(c1.[Field_Value], i.ClassNum, 0)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ClassNum' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@int != @ClassNumDP) set @itemErrors = @itemErrors + 32
        
        --ComponentsSameHierarchySC = 64 ' DP
        
        select @int = CONVERT(int, COALESCE(c1.[Field_Value], i.SubClassNum, 0)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SubClassNum' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@int != @SubClassNumDP) set @itemErrors = @itemErrors + 64
        
        --ComponentsSameVendor = 128 ' DP
        
        select @bigint = CONVERT(bigint, COALESCE(c1.[Field_Value], i.VendorNumber, 0)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'VendorNumber' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@bigint != @VendorNumberDP) set @itemErrors = @itemErrors + 128
      
      end
      
      -- MOVED DOWN
      ----if (@DCount = 1)
      ----begin
        
      ----  --DisplayerWarehouseSeasonalW = 256 ' D
        
      ----  select @str = COALESCE(c1.[Field_Value], i.StockCategory, '') from vwItemMaintItemDetail i 
      ----    left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      ----    left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'StockCategory' and c1.[Counter] = 0 
      ----    where i.[ID] = @itemID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('D')
      ----  if (ltrim(rtrim(@str)) != 'W') set @itemErrors = @itemErrors + 256
        
      ----  --DisplayerWarehouseSeasonalS = 512 'D
        
      ----  select @str = COALESCE(c1.[Field_Value], i.ItemTypeAttribute, '') from vwItemMaintItemDetail i 
      ----    left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      ----    left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemTypeAttribute' and c1.[Counter] = 0 
      ----    where i.[ID] = @itemID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('D')
      ----  if (ltrim(rtrim(@str)) != 'S') set @itemErrors = @itemErrors + 512
        
      ----end
      
      declare @SKUDDP varchar(20)
      declare @SKU varchar(20)
      declare @SKUGroupDDP varchar(50)
      declare @SKUGroup varchar(50)
      set @parentID = 0
      
      select @parentID = i.[ID]
      from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),1), '-', '')), '') = 'D'
      
      select 
        @SKUGroupDDP = COALESCE(c1.[Field_Value], i.SKUGroup, ''),
        @SKUDDP = COALESCE(c2.[Field_Value], i.SKU, '')
      from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SKUGroup' and c1.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c2 ON i.[ID] = c2.[Item_Maint_Items_ID] and c2.[Field_Name] = 'SKU' and c1.[Counter] = 0 
      where i.[ID] = @parentID
      
      
      -- D/DP 
      --ComponentsSamePLI (Package Language Indicator)
      declare @parentPLI varchar(10)
      declare @childPLI varchar(10)
      DECLARE @pli as varchar(1)
      SET @parentPLI = ''
	  SET @childPLI = ''
	  SET @pli = ''

      --English (PARENT)
      Select @pli = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @parentID and field_Name = 'PLIEnglish'

	  IF  @pli = ''
	  Begin
		Select @pli = COALESCE(Package_Language_Indicator,'')
		FROM SPD_Item_Master_Languages_Supplier
		WHERE Language_Type_ID = 1 and Michaels_SKU = @SKUDDP and Vendor_Number = @VendorNumber
	  End
	  
	  SET @parentPLI = @pli
      SET @pli = ''
      
      --French (PARENT)
      Select @pli = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @parentID and field_Name = 'PLIFrench'

	  IF  @pli = ''
	  Begin
		Select @pli = COALESCE(Package_Language_Indicator,'')
		FROM SPD_Item_Master_Languages_Supplier
		WHERE Language_Type_ID = 2 and Michaels_SKU = @SKUDDP and Vendor_Number = @VendorNumber
	  End
	  
	  SET @parentPLI = @parentPLI + @pli
	  SET @pli = ''
	  
      --SPanish (PARENT)
      Select @pli = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @parentID and field_Name = 'PLISpanish'

	  IF  @pli = ''
	  Begin
		Select @pli = COALESCE(Package_Language_Indicator,'')
		FROM SPD_Item_Master_Languages_Supplier
		WHERE Language_Type_ID = 3 and Michaels_SKU = @SKUDDP and Vendor_Number = @VendorNumber
	  End
	  
	  SET @parentPLI = @parentPLI + @pli
	  SET @pli = ''
      
      --GET Component SKU
      DECLARE @childSKU as varchar(20)
      Select @childSKU = SKU
      FROM vwItemMaintItemDetail WHERE ID = @itemID
     
      --English (PARENT)
      Select @pli = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @itemID and field_Name = 'PLIEnglish'

	  IF  @pli = ''
	  Begin
		Select @pli = COALESCE(Package_Language_Indicator,'')
		FROM SPD_Item_Master_Languages_Supplier
		WHERE Language_Type_ID = 1 and Michaels_SKU = @childSKU and Vendor_Number = @VendorNumber
	  End
	  
	  SET @childPLI = @pli
	  SET @pli = ''
	  
      --French (PARENT)
      Select @pli = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @itemID and field_Name = 'PLIFrench'

	  IF  @pli = ''
	  Begin
		Select @pli = COALESCE(Package_Language_Indicator,'')
		FROM SPD_Item_Master_Languages_Supplier
		WHERE Language_Type_ID = 2 and Michaels_SKU = @childSKU and Vendor_Number = @VendorNumber
	  End
	  
	  SET @childPLI = @childPLI + @pli
	  SET @pli = ''
	  
      --SPanish (PARENT)
      Select @pli = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @itemID and field_Name = 'PLISpanish'

	  IF  @pli = ''
	  Begin
		Select @pli = COALESCE(Package_Language_Indicator,'')
		FROM SPD_Item_Master_Languages_Supplier
		WHERE Language_Type_ID = 3 and Michaels_SKU = @childSKU and Vendor_Number = @VendorNumber
	  End
	  
	  SET @childPLI = @childPLI + @pli
	  SET @pli = ''
	      
      If(@parentPLI != @childPLI) set @itemErrors = @itemErrors + 262144
 
 
	  --ComponentsSameTI (Translation Indicator)
      declare @parentTI varchar(10)
      declare @childTI varchar(10)
      DECLARE @ti as varchar(1)
      SET @parentTI = ''
	  SET @childTI = ''
	  SET @ti = ''

      --English (PARENT)
      Select @ti = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @parentID and field_Name = 'TIEnglish'

	  IF  @ti = ''
	  Begin
		Select @ti = COALESCE(Translation_Indicator,'')
		FROM SPD_Item_Master_Languages
		WHERE Language_Type_ID = 1 and Michaels_SKU = @SKUDDP
	  End
	  
	  SET @parentTI = @ti
      SET @ti = ''
      
      --French (PARENT)
      Select @ti = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @parentID and field_Name = 'TIFrench'

	  IF  @ti = ''
	  Begin
		Select @ti = COALESCE(Translation_Indicator,'')
		FROM SPD_Item_Master_Languages
		WHERE Language_Type_ID = 2 and Michaels_SKU = @SKUDDP
	  End
	  
	  SET @parentTI = @parentTI + @ti
	  SET @ti = ''
	  
      --SPanish (PARENT)
      Select @ti = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @parentID and field_Name = 'TISpanish'

	  IF  @ti = ''
	  Begin
		Select @ti = COALESCE(Translation_Indicator,'')
		FROM SPD_Item_Master_Languages
		WHERE Language_Type_ID = 3 and Michaels_SKU = @SKUDDP
	  End
	  
	  SET @parentTI = @parentTI + @ti
	  SET @ti = ''
      
      --GET Component SKU
      Select @childSKU = SKU
      FROM vwItemMaintItemDetail WHERE ID = @itemID
     
      --English (PARENT)
      Select @ti = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @itemID and field_Name = 'TIEnglish'

	  IF  @ti = ''
	  Begin
		Select @ti = COALESCE(Translation_Indicator,'')
		FROM SPD_Item_Master_Languages
		WHERE Language_Type_ID = 1 and Michaels_SKU = @childSKU 
	  End
	  
	  SET @childTI = @ti
	  SET @ti = ''
	  
      --French (PARENT)
      Select @ti = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @itemID and field_Name = 'TIFrench'

	  IF  @ti = ''
	  Begin
		Select @ti = COALESCE(Translation_Indicator,'')
		FROM SPD_Item_Master_Languages
		WHERE Language_Type_ID = 2 and Michaels_SKU = @childSKU
	  End
	  
	  SET @childTI = @childTI + @ti
	  SET @ti = ''
	  
      --SPanish (PARENT)
      Select @ti = COALESCE(Field_Value, '')
	  FROM  SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @itemID and field_Name = 'TISpanish'

	  IF  @ti = ''
	  Begin
		Select @ti = COALESCE(Translation_Indicator,'')
		FROM SPD_Item_Master_Languages
		WHERE Language_Type_ID = 3 and Michaels_SKU = @childSKU
	  End
	  
	  SET @childTI = @childTI + @ti
	  SET @ti = ''

      If(@parentTI != @childTI) set @itemErrors = @itemErrors + 524288 
       
       
      --ComponentsMustBeActive = 1024 ' D/DP
      select @str = COALESCE(c1.[Field_Value], i.ItemStatus, '') from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemStatus' and c1.[Counter] = 0 
        where i.[ID] = @itemID
      if (ltrim(rtrim(@str)) != 'A') set @itemErrors = @itemErrors + 1024
        
      --ComponentsSameSkuGroup = 2048 ' D/DP
      -- REMOVED FROM THE SPEDY REQUIREMENTS
      -- NOPE PUT BACK IN #14
        
      if (@DPCount = 1)
      begin
        select @SKUGroup = COALESCE(c1.[Field_Value], i.SKUGroup, '') from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SKUGroup' and c1.[Counter] = 0 
          where i.[ID] = @itemID
        if (@SKUGroupDDP != @SKUGroup) set @itemErrors = @itemErrors + 2048
      end
      
      --ComponentsQtyInPack = 4096 ' D/DP
      
      select @int = CONVERT(int, COALESCE(c1.[Field_Value], i.QtyInPack, -1)) from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'QtyInPack' and c1.[Counter] = 0 
        where i.[ID] = @itemID
      if (@int < 0) set @itemErrors = @itemErrors + 4096


      --DDPComponentVendors = 65536
      insert into @t (SKU,VendorNumber,child)
      select distinct Michaels_SKU, Vendor_Number, 0 from SPD_Item_Master_Vendor where Michaels_SKU = @SKUDDP
      select @SKU = COALESCE(c1.[Field_Value], i.SKU, '') from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SKU' and c1.[Counter] = 0 
        where i.[ID] = @itemID
      update @t set child = 1 where VendorNumber in (select distinct Vendor_Number from SPD_Item_Master_Vendor where Michaels_SKU = @SKU)
      select @int1 = isnull(count(1), 0) from @t
      select @int2 = isnull(count(1), 0) from @t where child = 0
      if (@int1 > 1 and @int2 > 0) set @itemErrors = @itemErrors + 65536
      
    
    end  -- @itemType != 'D' and @itemType != 'DP'
    
    if (@DCount = 1 and @itemType = 'D')
    begin
      
      --DisplayerWarehouseSeasonalW = 256 ' D
      set @str = ''
      select @str = COALESCE(c1.[Field_Value], i.StockCategory, '') from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'StockCategory' and c1.[Counter] = 0 
        where i.[ID] = @itemID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c1.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('D')
      if (ltrim(rtrim(@str)) != 'W') set @itemErrors = @itemErrors + 256
      
      --DisplayerWarehouseSeasonalS = 512 'D
      set @str = ''
      select @str = COALESCE(c1.[Field_Value], i.ItemTypeAttribute, '') from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemTypeAttribute' and c1.[Counter] = 0 
        where i.[ID] = @itemID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c1.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('D')
      if (ltrim(rtrim(@str)) != 'S') set @itemErrors = @itemErrors + 512
      
    end
    
    --DDPActive = 8192 ' D/DP
    set @str = ''
    select @str = COALESCE(c1.[Field_Value], i.ItemStatus, '') from vwItemMaintItemDetail i 
      left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemStatus' and c1.[Counter] = 0 
      where i.[ID] = @itemID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''), 2), '-', '')), '') IN ('D','DP')
    if (ltrim(rtrim(@str)) = 'C') set @itemErrors = @itemErrors + 8192
   
  end
  
  -- END ERRORS - ITEM MAINT ---------------------------

  SET NOCOUNT OFF

  select @itemErrors as [ItemErrors]
  
  select VendorNumber from @t where child = 0
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateItemMaintBatch]    Script Date: 01/31/2018 14:11:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_SPD_Validation_ValidateItemMaintBatch]
  @batchID bigint
AS

  declare @batchErrors int
  set @batchErrors = 0
  
  declare @batchType int
  declare @hid int
  declare @DPCount int
  declare @DCount int
  declare @CCount int
  declare @itemCount int
  declare @costParent money, @costChildren money
  declare @int1 int, @int2 int, @int3 int
  declare @str1 varchar(255)
  declare @reg bit
  declare @changeCount int
  declare @AddedSKUs varchar(max), @DeletedSKUs varchar(max), @PackSKU varchar(20)
  declare @qty int
  declare @US varchar(50), @CANADA varchar(50), @BOTH varchar(50)
  declare @SKUGroupD varchar(50)
  declare @d int
  Declare @weightParent as Decimal(18,6)
  Declare @weightChildren as Decimal(18,6)
  
  
  select @batchType = Batch_Type_ID from SPD_Batch where [ID] = @batchID
 
  if (@batchType = 1 or @batchType = 2)
  begin
    -----------------------------
    -- ITEM MAINT >> IMPORT / DOMESTIC BATCH
    -----------------------------
    select @itemCount = isnull(count(1), 0) from vwItemMaintItemDetail i where i.BatchID = @batchID
    
    select @DPCount = isnull(count(1), 0) from vwItemMaintItemDetail i 
      left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') = 'DP'
  
    select @DCount = isnull(count(1), 0) from vwItemMaintItemDetail i 
      left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') = 'D' 
    
    select @CCount = isnull(count(1), 0) from vwItemMaintItemDetail i 
      left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','') 
    
    -- START ERRORS - IMPORT / DOMESTIC ---------------------------
   
    --None = 0
    --DDPMultipleParents = 1
    if ((@DPCount + @DCount) > 1) set @batchErrors = @batchErrors + 1
    --DDPNoComponents = 2
    if ((@DPCount + @DCount) >= 1 and @CCount <= 0) set @batchErrors = @batchErrors + 2
    --DDPMissingParent = 4
    if (@CCount >= 1 and (@DPCount + @DCount) <= 0) set @batchErrors = @batchErrors + 4
    --DDPMissingTypes = 8
    if ( (@DPCount > 0 or @DCount > 0 or @CCount > 0) and ( (@CCount + @DCount + @DPCount) != @itemCount)) set @batchErrors = @batchErrors + 8
    ----------
    -- D/DP --
    ----------
    if ((@DPCount + @DCount) >= 1)
    begin
      --DDPComponentsNotActive = 16
      -- ... currently, not enough data to implement this validation rule !
      --DDPPackCost1NotEqual = 32
   
      select @costParent = sum(coalesce(convert(decimal(18, 6), COALESCE(case @batchType when 1 then CAST(c3.[Field_Value] as money) else CAST(c2.[Field_Value] as money) end, case @batchType when 1 then i.ItemCost else i.ProductCost end, 0)), 0)) from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c3 ON i.[ID] = c3.[Item_Maint_Items_ID] and c3.[Field_Name] = 'ItemCost' and c3.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c2 ON i.[ID] = c2.[Item_Maint_Items_ID] and c2.[Field_Name] = 'ProductCost' and c2.[Counter] = 0 
        --left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'FOBShippingPoint' and c1.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
        where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('DP', 'D')
 
      select @costChildren = sum(
          (
            coalesce(convert(int, COALESCE(c4.[Field_Value], i.QtyInPack, 0)), 0) * 
            coalesce(convert(decimal(18, 6), COALESCE(case @batchType when 1 then CAST(c3.[Field_Value] as money) else CAST(c2.[Field_Value] as money) end, case @batchType when 1 then i.ItemCost else i.ProductCost end, 0)), 0)
          )
        ) from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c4 ON i.[ID] = c4.[Item_Maint_Items_ID] and c4.[Field_Name] = 'QtyInPack' and c4.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c3 ON i.[ID] = c3.[Item_Maint_Items_ID] and c3.[Field_Name] = 'ItemCost' and c3.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c2 ON i.[ID] = c2.[Item_Maint_Items_ID] and c2.[Field_Name] = 'ProductCost' and c2.[Counter] = 0 
        --left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'FOBShippingPoint' and c1.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
        where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
           
      if (@costParent != @costChildren) set @batchErrors = @batchErrors + 32
      
      --DDPPackCost2NotEqual = 64
      -- ... not needed for Import Batch
               
      ------------
      -- DP ONLY --
      ------------
      if (@DPCount = 1)
      begin
      
        --DDPSameSKUGroup = 128
        -- REMOVED FROM THE SPEDY REQUIREMENTS
        -- NOPE >> MOVED TO THE DP ONLY REQUIREMENTS
        select @int1 = count(distinct COALESCE(c.[Field_Value], i.SKUGroup)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'SKUGroup' and c.[Counter] = 0 
          where i.BatchID = @batchID
          
        if (@int1 > 1) set @batchErrors = @batchErrors + 128
      
        --DPComponentsSameItemTypeAttribute = 256
        select @int1 = count(distinct COALESCE(c1.[Field_Value], i.ItemTypeAttribute)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ItemTypeAttribute' and c1.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        if (@int1 > 1) set @batchErrors = @batchErrors + 256
        
        --DPComponentsSameStockCategory = 512
        select @int1 = count(distinct COALESCE(c1.[Field_Value], i.StockCategory)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'StockCategory' and c1.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        if (@int1 > 1) set @batchErrors = @batchErrors + 512
        
        ----DPComponentsSameHybridInfo = 1024
        --select @int1 = count(distinct COALESCE(c1.[Field_Value],i.HybridType)) from vwItemMaintItemDetail i 
        --  left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'HybridType' and c1.[Counter] = 0 
        --  left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
        --  where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        --select @int2 = count(distinct COALESCE(c1.[Field_Value], i.HybridSourceDC)) from vwItemMaintItemDetail i 
        --  left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'HybridSourceDC' and c1.[Counter] = 0 
        --  left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
        --  where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        --if (@int1 > 1 or @int2 > 1) set @batchErrors = @batchErrors + 1024
        
        --DPComponentsSameStockingStrategyCode = 1024
        select @int1 = count(distinct COALESCE(c1.[Field_Value],i.StockingStrategyCode)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'StockingStrategyCode' and c1.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        if (@int1 > 1) set @batchErrors = @batchErrors + 1024
        
        
        --DPSamePrimaryVendor = 2048
        select @int1 = count(distinct COALESCE(CONVERT(int, COALESCE(c1.[Field_Value], i.VendorNumber)), 0)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'VendorNumber' and c1.[Counter] = 0 
          where i.BatchID = @batchID
        
        if (@int1 > 1) set @batchErrors = @batchErrors + 2048
        
        --DPComponentsSameHierarchy = 4096
        select @int1 = count(distinct COALESCE(c1.[Field_Value], i.ClassNum)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'ClassNum' and c1.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        select @int2 = count(distinct COALESCE(c1.[Field_Value], i.SubClassNum)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SubClassNum' and c1.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        select @int3 = count(distinct COALESCE(c1.[Field_Value],i.DepartmentNum)) from vwItemMaintItemDetail i 
          left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'DepartmentNum' and c1.[Counter] = 0 
          left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
        
        if (@int1 > 1 or @int2 > 1 or @int3 > 1) set @batchErrors = @batchErrors + 4096
        
      end 
      
    end
    
    --NoItems = 8192
    if (@itemCount <= 0) set @batchErrors = @batchErrors + 8192
    
    --select @DPCount,@DCount
    if ((@DPCount + @DCount) >= 1)
    begin
      --NoChanges = 16384
      
      Set @AddedSKUs = ''
	    Set @DeletedSKUs = ''
	    Select @PackSKU = Pack_SKU from SPD_Batch Where id = @BatchID
      
      select @changeCount = count(1) from SPD_Item_Master_Changes c
        inner join SPD_Item_Maint_Items i ON c.[Item_Maint_Items_ID] = i.[ID]
      where i.[Batch_ID] = @batchID AND c.Field_Name <> 'QuoteReferenceNumber'
      select @changeCount = isnull(@changeCount, 0)
      
      if(@changeCount = 0)
      begin
        select @AddedSKUs = SKUsAddedToPack, @DeletedSKUs = SKUSDeletedFromPack
	      from dbo.udf_SPD_ItemMaint_GetPackChanges(@BatchID)
	    end
	    
	    --select @changeCount, @AddedSKUs , @DeletedSKUs
	    if (@changeCount = 0 and @AddedSKUs = '' and @DeletedSKUs = '') set @batchErrors = @batchErrors + 16384
	    
	    
	    --DDPComponentQtyZero = 32768
	    select @qty = sum( coalesce(convert(int, COALESCE(c4.[Field_Value], i.QtyInPack, 0)), 0) ) 
	    from vwItemMaintItemDetail i 
        left outer join SPD_Item_Master_Changes c4 ON i.[ID] = c4.[Item_Maint_Items_ID] and c4.[Field_Name] = 'QtyInPack' and c4.[Counter] = 0 
        left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
      where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','')
      
      if (isnull(@qty, 0) <= 0) set @batchErrors = @batchErrors + 32768
      
      ------------
      -- D ONLY --
      ------------
      if (@DCount = 1)
      begin
        --SKUGroupRules = 131072
        select @US = 'US ONLY'
        select @CANADA = 'CANADA ONLY'
        select @BOTH = 'US AND CANADA'
        select @SKUGroupD = RTRIM(LTRIM(UPPER(COALESCE(c1.[Field_Value], i.SKUGroup)))) 
          from vwItemMaintItemDetail i 
            left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SKUGroup' and c1.[Counter] = 0 
            left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') = 'D' 
        select @d = case @SKUGroupD
          when @US then 1
          when @CANADA then 2
          when @BOTH then 3
          else 0
          end
        -- US
        select @int1 = isnull(count(1), 0) from vwItemMaintItemDetail i 
            left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SKUGroup' and c1.[Counter] = 0 
            left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','') 
            and COALESCE(c1.[Field_Value], i.SKUGroup) = @US
        -- CANADA
        select @int2 = isnull(count(1), 0) from vwItemMaintItemDetail i 
            left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SKUGroup' and c1.[Counter] = 0 
            left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','') 
            and COALESCE(c1.[Field_Value], i.SKUGroup) = @CANADA
        -- BOTH
        select @int3 = isnull(count(1), 0) from vwItemMaintItemDetail i 
            left outer join SPD_Item_Master_Changes c1 ON i.[ID] = c1.[Item_Maint_Items_ID] and c1.[Field_Name] = 'SKUGroup' and c1.[Counter] = 0 
            left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
          where i.BatchID = @batchID and COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') IN ('C','R','') 
            and COALESCE(c1.[Field_Value], i.SKUGroup) = @BOTH
        -- COMPARE
        if (
          (@int1 = 0 and @int2 = 0 and @int3 > 0 and @d = 0) or
          (@int1 = 0 and @int2 > 0 and @int3 = 0 and @d != 2) or
          (@int1 > 0 and @int2 = 0 and @int3 = 0 and @d != 1) or
          (@int1 > 0 and @int2 = 0 and @int3 > 0 and @d != 1) or
          (@int1 = 0 and @int2 > 0 and @int3 > 0 and @d != 2) or
          (@int1 > 0 and @int2 > 0) or
          (@int1 > 0 and @int2 > 0 and @int3 > 0))
        begin
          set @batchErrors = @batchErrors + 131072
        end
      end -- if (@DCount = 1)
      
      
    end
    
    -- END ERRORS - ITEM MAINT ---------------------------
  end

  --------------------------------------------------
  -- get the errors
  --------------------------------------------------
  select @batchErrors as [BatchErrors]
  
  
  --------------------------------------------------
  -- Future Costs by SKU (Warning(s))
  --------------------------------------------------
  SELECT distinct I.ID								as ID
	--, I.Batch_ID						as BatchID
	, SKU.Michaels_SKU					as SKU
	--, V.Vendor_Number					as VendorNumber
	--, CC.Effective_Date					as EffectiveDate
	--, CC.Future_Cost					as FutureCost
	, 1 as FutureCostExists
	, Case WHEN (
			Select count(*) From SPD_Item_Master_Changes imc
			Where imc.Item_Maint_Items_ID = I.ID and imc.Field_Name = 'FutureCostStatus'
		) > 0 THEN 1 
		ELSE 0 End as FutureCostCancelled

FROM SPD_Item_Maint_Items I
	--Join SPD_Batch B ON I.Batch_ID = B.ID and B.[enabled] = 1				
	inner join SPD_Item_Master_SKU SKU ON I.SKU_ID = SKU.ID
	inner join SPD_Item_Master_Vendor V	ON I.Michaels_SKU = V.Michaels_SKU and I.Vendor_Number = V.Vendor_Number
	inner join SPD_Item_Master_Vendor_Countries C	ON V.Michaels_SKU = C.Michaels_SKU and V.Vendor_Number = C.Vendor_Number and C.Primary_Indicator = 1
	inner join SPD_Item_Master_Vendor_Country_Cost CC	ON C.Michaels_SKU = CC.Michaels_SKU and C.Vendor_Number = CC.Vendor_Number and C.Country_Of_Origin = CC.Country_Of_Origin
  where I.Batch_ID = @batchID
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SPD_Report_ImportItem] 
	@startDate as Datetime = null,
	@endDate as DateTime = null,
	@dept as integer = null,
	@stage as integer = null,
	@vendor as bigint = null,
	@vendorFilter as bigint = null,
	@workflowId as integer = 1,
	@approver as int = null
AS

declare @dateNow datetime        
declare @dateNowStr varchar(20)        
declare @month varchar(2), @day varchar(2), @year varchar(4)            

set @dateNow = getdate()        
set @month = convert(varchar(2), Month(@dateNow))          
if (len(@month) < 2)             
	set @month = '0' + @month          

set @day = convert(varchar(2), Day(@dateNow))          
if (len(@day) < 2)             
	set @day = '0' + @day         

set @year = convert(varchar(4), Year(@dateNow))          
if (len(@year) < 4)             
	set @year = '00' + @year             

set @dateNowStr =  @year + @month + @day                


IF (@workflowId = 1)
BEGIN

	SELECT  ii.ID, ii.Batch_ID, ii.DateCreated, b.Date_Modified, 
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ii.CreatedUserID) as CreatedUser,
		COALESCE((SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ii.UpdateUserID),'System') as UpdateUser, 
		ii.DateSubmitted,     
		ii.Vendor, ii.Agent as MerchBurden, ii.AgentType as MerchBurdenType, ii.Buyer, ii.Fax, ii.EnteredBy, ii.QuoteSheetStatus, ii.Season, ii.SKUGroup,    
		ii.Email, ii.EnteredDate, ii.Dept, ii.Class, ii.SubClass, ii.PrimaryUPC, ii.MichaelsSKU as SKU, ii.GenerateMichaelsUPC as GenerateUPC,     
		ii.AdditionalUPC1, ii.AdditionalUPC2, ii.AdditionalUPC3, ii.AdditionalUPC4, ii.AdditionalUPC5, ii.AdditionalUPC6,    
		ii.AdditionalUPC7, ii.AdditionalUPC8, ii.PackSKU, ii.PlanogramName, ii.VendorNumber, ii.VendorRank, ii.ItemTask,     
		ii.[Description], ii.PaymentTerms, ii.[Days], ii.VendorMinOrderAmount, ii.VendorName, ii.VendorAddress1, ii.VendorAddress2,    
		ii.VendorAddress3, ii.VendorAddress4, ii.VendorContactName, ii.VendorContactPhone, ii.VendorContactEmail, ii.VendorContactFax,     
		ii.ManufactureName, ii.ManufactureAddress1, ii.ManufactureAddress2, ii.ManufactureContact, ii.ManufacturePhone,    
		ii.ManufactureEmail, ii.ManufactureFax, ii.AgentContact, ii.AgentPhone, ii.AgentEmail, ii.AgentFax, ii.VendorStyleNumber,     
		ii.HarmonizedCodeNumber, ii.canadaHarmonizedCodeNumber as CanadaHarmonizedCodeNumber,
		ii.DetailInvoiceCustomsDesc, ii.ComponentMaterialBreakdown, ii.ComponentConstructionMethod, ii.IndividualItemPackaging,     
		ii.EachInsideMasterCaseBox, ii.EachInsideInnerPack, 
	    ii.eachlength as EachCartonLength, ii.eachwidth as EachCartonWidth, ii.eachheight as EachCartonHeight, ii.cubicfeeteach as CubicFeetPerEachCarton, ii.eachweight as EachCartonWeight,  
		ii.ReshippableInnerCartonLength,     
		ii.ReshippableInnerCartonWidth, ii.ReshippableInnerCartonHeight, ii.CubicFeetPerInnerCarton, ii.ReshippableInnerCartonWeight, ii.MasterCartonDimensionsLength, ii.MasterCartonDimensionsWidth,     
		ii.MasterCartonDimensionsHeight, ii.CubicFeetPerMasterCarton, ii.WeightMasterCarton, ii.FOBShippingPoint,    
		ii.DutyPercent, ii.DutyAmount, ii.AdditionalDutyComment, ii.AdditionalDutyAmount, ii.OceanFreightAmount, ii.OceanFreightComputedAmount,     
		ii.AgentCommissionPercent As MerchBurdenPercent, ii.AgentCommissionAmount As MerchBurdenAmount, ii.OtherImportCostsPercent, ii.OtherImportCostsAmount, ii.PackagingCostAmount,     
		ii.TotalImportBurden, ii.WarehouseLandedCost, ii.PurchaseOrderIssuedTo, ii.ShippingPoint, ii.CountryOfOrigin, ii.CountryOfOriginName,     
		ii.VendorComments, ii.StockCategory, ii.FreightTerms, ii.ItemType, ii.PackItemIndicator, ii.ItemTypeAttribute, ii.AllowStoreOrder,    
		ii.InventoryControl, ii.AutoReplenish, ii.PrePriced, ii.TaxUDA, ii.PrePricedUDA, ii.TaxValueUDA, 
		--ii.HybridType, ii.SourcingDC, ii.LeadTime,  ii.ConversionDate, 
		ii.Stocking_Strategy_Code,
		ii.StoreSuppZoneGRP, ii.WhseSuppZoneGRP, ii.POGMaxQty, ii.POGSetupPerStore as Initial_Set_Qty_Per_Store, ii.OutboundFreight,    
		ii.NinePercentWhseCharge, ii.TotalStoreLandedCost, ii.RDBase as Base1_Retail, ii.RDCentral as Base2_Retail, ii.RDTest as Test_Retail, ii.RDAlaska as Alaska_Retail,    
		ii.RDCanada as Canada_Retail, ii.RD0Thru9 as High2_Retail, ii.RDCalifornia as High3_Retail, ii.RDVillageCraft as Small_Market_Retail, ii.Retail9 as High1_Retail,    
		ii.Retail10 as Base3_Retail, ii.Retail11 as Low1_Retail, ii.Retail12 as Low2_Retail, ii.Retail13 as Manhattan_Retail, ii.RDQuebec as Q5_Retail,    
		ii.RDPuertoRico as PR_Retail, ii.HazMatYes, ii.HazMatNo, ii.HazMatMFGCountry, ii.HazMatMFGName, ii.HazMatMFGFlammable, ii.HazMatMFGCity,     
		ii.HazMatContainerType, ii.HazMatMFGState, ii.HazMatContainerSize, ii.HazMatMFGPhone, ii.HazMatMSDSUOM, ii.TSSA, ii.CSA, ii.UL, ii.LicenceAgreement,     
		ii.FumigationCertificate, ii.KILNDriedCertificate, ii.ChinaComInspecNumAndCCIBStickers, ii.OriginalVisa, ii.TextileDeclarationMidCode, ii.QuotaChargeStatement,     
		ii.MSDS, ii.TSCA, ii.DropBallTestCert, ii.ManMedicalDeviceListing, ii.ManFDARegistration, ii.CopyRightIndemnification, ii.FishWildLifeCert,     
		ii.Proposition65LabelReq, ii.CCCR, ii.FormaldehydeCompliant, ii.Is_Valid, ii.Tax_Wizard, ii.RMS_Sellable, ii.RMS_Orderable, ii.RMS_Inventory, ii.Parent_ID,     
		ii.RegularBatchItem, ii.[Sequence], ii.Store_Total, ii.POG_Start_Date, ii.POG_Comp_Date, ii.Like_Item_SKU, ii.Like_Item_Description, ii.Like_Item_Retail,     
		ii.Like_Item_Regular_Unit, ii.Like_Item_Sales, ii.Facings, ii.POG_Min_Qty, ii.Displayer_Cost, ii.Product_Cost, ii.Calculate_Options, ii.Like_Item_Store_Count,     
		ii.Like_Item_Unit_Store_Month, ii.Annual_Reg_Retail_Sales, ii.Annual_Regular_Unit_Forecast, ii.Min_Pres_Per_Facing,   
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		COALESCE(lv.Display_Text, '') as Private_Brand_Label, ii.QuoteReferenceNumber, ii.Customs_Description,   
		silE.Package_Language_Indicator as Package_Language_Indicator_English,   
		silF.Package_Language_Indicator as Package_Language_Indicator_French,   
		silS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		silE.Translation_Indicator as Translation_Indicator_English,   
		silF.Translation_Indicator as Translation_Indicator_French,   
		silS.Translation_Indicator as Translation_Indicator_Spanish,       
		silE.Description_Short as English_Short_Description, silE.Description_Long as English_Long_Description, silF.Description_Short as French_Short_Description,    
		silF.Description_Long as French_Long_Description, silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description          
	FROM [SPD_Import_Items] ii with(nolock)         
		inner join [SPD_Batch] b with(nolock) on ii.Batch_ID = b.ID           
		left outer join SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1           
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = ii.[ID] and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = ii.[ID] and f2.File_Type = 'MSDS'        
		LEFT JOIN SPD_Import_Item_Languages as silE with(nolock) on silE.Import_Item_ID = ii.ID and silE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Import_Item_Languages as silF with(nolock) on silF.Import_Item_ID = ii.ID and silF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Import_Item_Languages as silS with(nolock) on silS.Import_Item_ID = ii.ID and silS.Language_Type_ID = 3 -- SPANISH Language Fields          
		LEFT OUTER JOIN List_Values as lv on lv.List_Value_Group_ID = 16 And ii.Private_Brand_Label = lv.List_Value        
	WHERE b.enabled = 1 and b.Batch_Type_ID=2      
		and (@startDate is null or (@startDate is not null and b.date_modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.date_modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept))        
		and ((isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 1) = 1    
		and COALESCE(ws.Stage_Type_id, 1) <> 4) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage))        
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and b.Vendor_Number = @vendor))
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and b.Vendor_Number = @vendorFilter))            
	    and (@approver is null or (b.Workflow_Stage_ID in (select wap.Workflow_Stage_id from SPD_Workflow_Approval_Group wap inner join Security_User_Group sug on wap.Approval_group_id = sug.Group_ID inner join Security_User su on sug.[User_ID] = su.[ID] where su.[ID] = @approver ) 
									and b.fineline_dept_ID in (select isnull(convert(int, substring(sp.constant, 10, len(sp.constant))), 0) from Security_Privilege sp inner join Security_User_Privilege sup on sp.[ID] = sup.Privilege_ID where sp.Scope_ID = 1002 and sup.[User_ID] = @approver)))
END

IF (@workflowId = 2)
BEGIN

	SELECT simi.ID, simi.Batch_ID, simi.Date_Created, b.Date_Modified, 
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = b.Created_User) as [Created User],
		COALESCE((Select First_Name + Last_Name From Security_User Where ID = b.Modified_User),'System') as [Update User],
		b.Date_Created as Date_Submitted, 
		CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'V' Then 'YES' Else 'NO' END as [Vendor], CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'A' Then 'YES' Else 'NO' END as [Agent], 
		v.Agent_Type as Merch_Burden_Type, s.Buyer, s.Buyer_Fax as [Fax],
		su.First_Name + ' ' + su.Last_Name as [Entered_By], 
		s.Season, s.SKU_Group, s.Buyer_Email,
		b.Date_Created as [Entered_Date], 
		s.Department_Num, s.Class_Num, s.Sub_Class_Num, upc.UPC as Primary_UPC, s.Michaels_SKU, 
		(SELECT     COUNT(*) AS Expr1
			FROM          dbo.SPD_Item_Master_Vendor_UPCs AS UPC2
            WHERE      (Michaels_SKU = s.Michaels_SKU) AND (Vendor_Number = V.Vendor_Number) AND (Primary_Indicator = 0)) AS AdditionalUPCs, --TODO: Figure out how to handle multiple UPC stuff..
		s.Pack_SKU, s.Planogram_Name, v.Vendor_Number,
		'EDIT ITEM' as Item_Task, 
		s.Item_Desc as [Description], 
		v.PaymentTerms as Payment_Terms, v.Days,v.Vendor_Min_Order_Amount, v.Vendor_Name, v.Vendor_Address1, v.Vendor_Address2, v.Vendor_Address3, v.Vendor_Address4,
		v.Vendor_Contact_Name, v.Vendor_Contact_Phone, v.Vendor_Contact_Email, v.Vendor_Contact_Fax,
		v.Manufacture_Name, v.Manufacture_Address1, v.Manufacture_Address2, v.Manufacture_Contact, v.Manufacture_Phone, v.Manufacture_Email, v.Manufacture_Fax,
		v.Agent_Contact, v.Agent_Phone, v.Agent_Email, v.Agent_Fax, v.Vendor_Style_Num as [Vendor_Style_Number], v.Harmonized_CodeNumber as [Harmonized_Code_Number],
		v.Canada_Harmonized_CodeNumber as [Canada_Harmonized_CodeNumber],
		v.Detail_Invoice_Customs_Desc0 as Detail_Invoice_Customs_Desc, v.Component_Material_Breakdown, v.Component_Construction_Method, v.Individual_Item_Packaging,
		C.Eaches_Master_Case, C.Eaches_Inner_Pack,
		
		C.Each_Case_Height as Each_Dimensions_Height,
		C.Each_Case_Width as Each_Dimensions_Width,
		C.Each_Case_Length as Each_Dimensions_Length,
		C.Each_Case_Weight as Each_Dimensions_Weight,
		C.Each_Case_Cube as Cubic_Feet_Per_Each_Carton,
		
		C.Inner_Case_Weight as Each_Piece_Net_Weight_Lbs_Per_Ounce, 
		C.Inner_Case_Length as Reshippable_Inner_Carton_Length,
		C.Inner_Case_Width as Reshippable_Inner_Carton_Width, 
		C.Inner_Case_Height as Reshippable_Inner_Carton_Height, 
		C.Master_Case_Length as Master_Carton_Dimensions_Length,
		C.Master_Case_Width as Master_Carton_Dimensions_Width,
		C.Master_Case_Height as Master_Carton_Dimensions_Height,
		C.Master_Case_Cube as Cubic_Feet_Per_Master_Carton, 
		C.Master_Case_Weight as Weight_Master_Carton,
		C.Inner_Case_Cube as Cubic_Feet_Per_Inner_Carton,
		V.FOB_Shipping_Point, V.Duty_Percent, V.Duty_Amount, V.Additional_Duty_Comment, V.Additional_Duty_Amount, V.Ocean_Freight_Amount,  V.Ocean_Freight_Computed_Amount,
		V.Agent_Commission_Percent As Merch_Burden_Percent, V.Agent_Commission_Amount As Merch_Burden_Amount, V.Other_Import_Costs_Percent, V.Other_Import_Costs_Amount, V.Packaging_Cost_Amount,
		C.Import_Burden AS Import_Burden,  V.Warehouse_Landed_Cost, V.Purchase_Order_Issued_To, V.Shipping_Point, C.Country_Of_Origin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS Country_Of_Origin_Name,
		V.Vendor_Comments, s.Stock_Category, V.Freight_Terms, 
		UPPER(s.Item_Type) as Item_Type, UPPER(s.Item_Type) AS Pack_Item_Indicator,
		s.Item_Type_Attribute, UPPER(s.Allow_Store_Order) AS Allow_Store_Order, UPPER(s.Inventory_Control) as Inventory_Control, 
		UPPER(s.Auto_Replenish) AS Auto_Replenish, 
		CASE WHEN (SELECT COUNT(*) FROM  SPD_Item_Master_UDA UDA4 WHERE  UDA4.Michaels_SKU = s.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS Pre_Priced,
		(SELECT TOP (1) ISNULL(UDA_Value, 0) AS Expr1 FROM SPD_Item_Master_UDA AS UDA5 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 10)) AS Pre_Priced_UDA,
		(SELECT TOP (1) UDA_ID FROM SPD_Item_Master_UDA AS UDA2 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_UDA,
		(SELECT TOP (1) UDA_Value FROM SPD_Item_Master_UDA AS UDA3 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_Value_UDA,
		--s.Hybrid_Type, s.Hybrid_Source_DC as Sourcing_DC, 
		s.STOCKING_STRATEGY_CODE,
		s.Store_Supplier_Zone_Group as Store_Supp_Zone_GRP, s.WHS_Supplier_Zone_Group as Whse_Supp_Zone_GRP, s.POG_Max_Qty, s.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store,
		v.Outbound_Freight, v.Nine_Percent_Whse_Charge, v.Total_Store_Landed_Cost, s.Base1_Retail, s.Base2_Retail, s.Test_Retail, s.Alaska_Retail,
		s.Canada_Retail, s.High2_Retail, s.High3_Retail, s.Small_Market_Retail, s.High1_Retail, s.Base3_Retail, s.Low1_Retail, s.Low2_Retail, s.Manhattan_Retail, s.Quebec_Retail as Q5_Retail,
		s.PuertoRico_Retail as PR_Retail,  
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'Y' Then 'X' Else '' END as Haz_Mat_Yes, 
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'N' Then 'X' Else '' END as Haz_Mat_No, 
		V.Hazardous_Manufacturer_Country as Haz_Mat_MFG_Country, V.Hazardous_Manufacturer_Name as Haz_Mat_MFG_Name, UPPER(s.Hazardous_Flammable) as Haz_Mat_MFG_Flammable,
		V.Hazardous_Manufacturer_City as Haz_Mat_MFG_City, UPPER(s.Hazardous_Container_Type) as Haz_Mat_Container_Type, V.Hazardous_Manufacturer_State as Haz_Mat_MFG_State,
		s.Hazardous_Container_Size as Haz_Mat_Container_Size, V.Hazardous_Manufacturer_Phone as Haz_Mat_MFG_Phone, UPPER(s.Hazardous_MSDS_UOM) as Haz_Mat_MSDS_UOM,
		s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
		s.Original_Visa, s.Textile_Declaration_Mid_Code, s.Quota_Charge_Statement, s.MSDS, s.TSCA, s.Drop_Bal_lTest_Cert as Drop_Ball_Test_Cert,
		s.Man_Medical_Device_Listing, s.Man_FDA_Registration, s.Copy_Right_Indemnification, s.Fish_Wild_Life_Cert, s.Proposition_65_Label_Req, s.CCCR,
		s.Formaldehyde_Compliant, simi.Is_Valid, 
		s.RMS_Sellable, s.RMS_Orderable, s.RMS_Inventory, 
		PKI.Pack_SKU as Parent_ID, 
		CASE WHEN UPPER(COALESCE(s.Pack_Item_Indicator,'')) = 'Y' Then 'NO' Else 'YES' END as Regular_Batch_Item, --TODO: Verify this is correct?
		s.Store_Total, 
		s.Displayer_Cost, C.Unit_Cost as Product_Cost, 
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=item_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS Private_Brand_Label,
		s.QuoteReferenceNumber as Quote_Reference_Number, s.Customs_Description,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, simlF.Description_Short as French_Short_Description,    
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, simlS.Description_Long as Spanish_Long_Description          
	INTO #ImportItemMaint
	FROM SPD_Item_Maint_Items as simi with(nolock) 
		INNER JOIN SPD_Batch as b with(nolock) on b.ID = simi.Batch_ID
		INNER JOIN SPD_Item_Master_SKU as s with(nolock) on s.Michaels_SKU = simi.Michaels_SKU
		INNER JOIN SPD_Item_Master_Vendor as v with(nolock) on v.Michaels_SKU = simi.Michaels_SKU and v.Vendor_Number = simi.Vendor_Number
		INNER JOIN SPD_Vendor as sv with(nolock) on sv.Vendor_Number = v.Vendor_Number	
		Left Outer Join Security_User as su with(nolock) on su.ID = b.Created_User
		LEFT OUTER JOIN SPD_Item_Master_Vendor_UPCs AS UPC with(nolock) ON v.Michaels_SKU = UPC.Michaels_SKU AND v.Vendor_Number = UPC.Vendor_Number AND UPC.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_Item_Master_Vendor_Countries AS C with(nolock) ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND C.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_COUNTRY AS CO with(nolock) ON CO.COUNTRY_CODE = C.Country_Of_Origin
		LEFT OUTER JOIN SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 2
		LEFT OUTER JOIN SPD_Item_Master_PackItems AS PKI with(nolock) ON s.Michaels_SKU = PKI.Child_SKU AND B.Pack_SKU = PKI.Pack_SKU   
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = v.Image_ID and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = v.MSDS_ID and f2.File_Type = 'MSDS'          
		LEFT JOIN SPD_Item_Master_Languages as simlE with(nolock) on simlE.Michaels_SKU = s.Michaels_SKU and simlE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlF with(nolock) on simlF.Michaels_SKU = s.Michaels_SKU and simlF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlS with(nolock) on simlS.Michaels_SKU = s.Michaels_SKU  and simlS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsE with(nolock) on simlsE.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsF.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsS.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
	WHERE b.Enabled = 1 AND sv.Vendor_Type = 300 and b.Batch_Type_ID=2   
		and (@startDate is null or (@startDate is not null and b.Date_Modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.Date_Modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and s.Department_Num = @dept))        
		and ((isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 2) = 2    
		and COALESCE(ws.Stage_Type_id, 1) <> 4) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage))        
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and v.Vendor_Number = @vendor))
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and v.Vendor_Number = @vendorFilter))            
		and (@approver is null or (b.Workflow_Stage_ID in (select wap.Workflow_Stage_id from SPD_Workflow_Approval_Group wap inner join Security_User_Group sug on wap.Approval_group_id = sug.Group_ID inner join Security_User su on sug.[User_ID] = su.[ID] where su.[ID] = @approver ) 
									and b.fineline_dept_ID in (select isnull(convert(int, substring(sp.constant, 10, len(sp.constant))), 0) from Security_Privilege sp inner join Security_User_Privilege sup on sp.[ID] = sup.Privilege_ID where sp.Scope_ID = 1002 and sup.[User_ID] = @approver)))
	    
		--UPDATE Temp Table with CHANGE Values	  
		UPDATE #ImportItemMaint
	    SET Season = isNull(c.Field_Value, iim.Season)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Season'
		  	    	    
	    UPDATE #ImportItemMaint
	    SET Planogram_Name = isNull(c.Field_Value, iim.Planogram_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PlanogramName'
	    
	    UPDATE #ImportItemMaint
	    SET [Description] = isNull(c.Field_Value, iim.[Description])
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemDesc'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Address1 = isNull(c.Field_Value, iim.Vendor_Address1)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress1'
	    
	    UPDATE #ImportItemMaint
	    SET Vendor_Address2 = isNull(c.Field_Value, iim.Vendor_Address2)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress2'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Address3 = isNull(c.Field_Value, iim.Vendor_Address3)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress3'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Address4 = isNull(c.Field_Value, iim.Vendor_Address4)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorAddress4'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Contact_Email = isNull(c.Field_Value, iim.Vendor_Contact_Email)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactEmail'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Contact_Fax = isNull(c.Field_Value, iim.Vendor_Contact_Fax)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactFax'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Contact_Name = isNull(c.Field_Value, iim.Vendor_Contact_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactName'
	    
	    UPDATE #ImportItemMaint
	    SET Vendor_Contact_Phone = isNull(c.Field_Value, iim.Vendor_Contact_Phone)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorContactPhone'
	    
	    UPDATE #ImportItemMaint
	    SET Manufacture_Address1 = isNull(c.Field_Value, iim.Manufacture_Address1)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureAddress1'
	    
		UPDATE #ImportItemMaint
	    SET Manufacture_Address2 = isNull(c.Field_Value, iim.Manufacture_Address2)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureAddress2'
		
		UPDATE #ImportItemMaint
	    SET Manufacture_Contact = isNull(c.Field_Value, iim.Manufacture_Contact)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureContact'
		
		UPDATE #ImportItemMaint
	    SET Manufacture_Email = isNull(c.Field_Value, iim.Manufacture_Email)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureEmail'
	   
		UPDATE #ImportItemMaint
	    SET Manufacture_Fax = isNull(c.Field_Value, iim.Manufacture_Fax)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureFax' 
		
		UPDATE #ImportItemMaint
	    SET Manufacture_Name = isNull(c.Field_Value, iim.Manufacture_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManufactureName' 
		
		UPDATE #ImportItemMaint
	    SET Agent_Contact = isNull(c.Field_Value, iim.Agent_Contact)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentContact' 
	    
	    UPDATE #ImportItemMaint
	    SET Agent_Email = isNull(c.Field_Value, iim.Agent_Email)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentEmail' 
		
		UPDATE #ImportItemMaint
	    SET Agent_Fax = isNull(c.Field_Value, iim.Agent_Fax)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentFax' 
		
		UPDATE #ImportItemMaint
	    SET Agent_Phone = isNull(c.Field_Value, iim.Agent_Phone)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentPhone' 
	    
	    UPDATE #ImportItemMaint
	    SET Vendor_Style_Number = isNull(c.Field_Value, iim.Vendor_Style_Number)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorStyleNum' 
	    
	    UPDATE #ImportItemMaint
	    SET Harmonized_Code_Number = isNull(c.Field_Value, iim.Harmonized_Code_Number)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HarmonizedCodeNumber' 
	    
	    UPDATE #ImportItemMaint
	    SET Detail_Invoice_Customs_Desc = isNull(c.Field_Value, iim.Detail_Invoice_Customs_Desc)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DetailInvoiceCustomsDesc0' 
	   
	    UPDATE #ImportItemMaint
	    SET Component_Material_Breakdown = isNull(c.Field_Value, iim.Component_Material_Breakdown)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ComponentMaterialBreakdown0'  
		
		UPDATE #ImportItemMaint
	    SET Component_Construction_Method = isNull(c.Field_Value, iim.Component_Construction_Method)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ComponentConstructionMethod0' 
	    
	    UPDATE #ImportItemMaint
	    SET Individual_Item_Packaging = isNull(c.Field_Value, iim.Individual_Item_Packaging)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'IndividualItemPackaging' 
	    
	    UPDATE #ImportItemMaint
	    SET Eaches_Master_Case = isNull(c.Field_Value, iim.Eaches_Master_Case)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EachesMasterCase' 
	    
	    UPDATE #ImportItemMaint
	    SET Eaches_Inner_Pack = isNull(c.Field_Value, iim.Eaches_Inner_Pack)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EachesInnerPack' 

	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Weight = isNull(c.Field_Value, iim.Each_Dimensions_Weight)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseWeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Length = isNull(c.Field_Value, iim.Each_Dimensions_Length)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseLength' 
	    
	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Width = isNull(c.Field_Value, iim.Each_Dimensions_Width)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseWidth' 
	    
	    UPDATE #ImportItemMaint
	    SET Each_Dimensions_Height = isNull(c.Field_Value, iim.Each_Dimensions_Height)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseHeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Cubic_Feet_Per_Each_Carton = isNull(c.Field_Value, iim.Cubic_Feet_Per_Each_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'eachCaseCube' 

	    UPDATE #ImportItemMaint
	    SET Each_Piece_Net_Weight_Lbs_Per_Ounce = isNull(c.Field_Value, iim.Each_Piece_Net_Weight_Lbs_Per_Ounce)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseWeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Reshippable_Inner_Carton_Length = isNull(c.Field_Value, iim.Reshippable_Inner_Carton_Length)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseLength' 
	    
	    UPDATE #ImportItemMaint
	    SET Reshippable_Inner_Carton_Width = isNull(c.Field_Value, iim.Reshippable_Inner_Carton_Width)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseWidth' 
	    
	    UPDATE #ImportItemMaint
	    SET Reshippable_Inner_Carton_Height = isNull(c.Field_Value, iim.Reshippable_Inner_Carton_Height)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseHeight' 
	    
	    UPDATE #ImportItemMaint
	    SET Cubic_Feet_Per_Inner_Carton = isNull(c.Field_Value, iim.Cubic_Feet_Per_Inner_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InnerCaseCube' 
	    
	    UPDATE #ImportItemMaint
	    SET Master_Carton_Dimensions_Length = isNull(c.Field_Value, iim.Master_Carton_Dimensions_Length)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseLength' 
	    
	    UPDATE #ImportItemMaint
	    SET Master_Carton_Dimensions_Width = isNull(c.Field_Value, iim.Master_Carton_Dimensions_Width)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseWidth'
	    
	    UPDATE #ImportItemMaint
	    SET Master_Carton_Dimensions_Height = isNull(c.Field_Value, iim.Master_Carton_Dimensions_Height)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseHeight'
		
		UPDATE #ImportItemMaint
	    SET Weight_Master_Carton = isNull(c.Field_Value, iim.Weight_Master_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseWeight'
		
		UPDATE #ImportItemMaint
	    SET Cubic_Feet_Per_Master_Carton = isNull(c.Field_Value, iim.Cubic_Feet_Per_Master_Carton)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MasterCaseCube'
		
		UPDATE #ImportItemMaint
	    SET FOB_Shipping_Point = isNull(c.Field_Value, iim.FOB_Shipping_Point)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FOBShippingPoint'
		
		UPDATE #ImportItemMaint
	    SET Duty_Percent = isNull(c.Field_Value, iim.Duty_Percent)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DutyPercent'
    
	    UPDATE #ImportItemMaint
	    SET Duty_Amount = isNull(c.Field_Value, iim.Duty_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DutyAmount'

	    UPDATE #ImportItemMaint
	    SET Additional_Duty_Comment = isNull(c.Field_Value, iim.Additional_Duty_Comment)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AdditionalDutyComment'
	    
	    UPDATE #ImportItemMaint
	    SET Additional_Duty_Amount = CAST(isNull(c.Field_Value, iim.Additional_Duty_Amount) as money)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AdditionalDutyAmount'
 	    
	    UPDATE #ImportItemMaint
	    SET Ocean_Freight_Amount = isNull(c.Field_Value, iim.Ocean_Freight_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OceanFreightAmount'
 	    
	    UPDATE #ImportItemMaint
	    SET Ocean_Freight_Computed_Amount = isNull(c.Field_Value, iim.Ocean_Freight_Computed_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OceanFreightComputedAmount'
     
	    UPDATE #ImportItemMaint
	    SET Merch_Burden_Percent = isNull(c.Field_Value, iim.Merch_Burden_Percent)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentCommissionPercent'
    
	    UPDATE #ImportItemMaint
	    SET Agent_Commission_Amount = Case When c.Field_Value <> '' Then isNull(c.Field_Value, iim.Agent_Commission_Amount) Else iim.Agent_Commission_Amount End
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AgentCommissionAmount'
 
	    UPDATE #ImportItemMaint
	    SET Other_Import_Costs_Percent = isNull(c.Field_Value, iim.Other_Import_Costs_Percent)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OtherImportCostsPercent'
	    
	    UPDATE #ImportItemMaint
	    SET Other_Import_Costs_Amount = isNull(c.Field_Value, iim.Other_Import_Costs_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OtherImportCostsAmount'
	  
		UPDATE #ImportItemMaint
	    SET Packaging_Cost_Amount = isNull(c.Field_Value, iim.Packaging_Cost_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PackagingCostAmount'
	  
		UPDATE #ImportItemMaint
	    SET Import_Burden = isNull(c.Field_Value, iim.Import_Burden)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ImportBurden'
		
		UPDATE #ImportItemMaint
	    SET Warehouse_Landed_Cost = isNull(c.Field_Value, iim.Warehouse_Landed_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'WarehouseLandedCost'
	  
	    UPDATE #ImportItemMaint
	    SET Purchase_Order_Issued_To = isNull(c.Field_Value, iim.Purchase_Order_Issued_To)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PurchaseOrderIssuedTo'
	    
	    UPDATE #ImportItemMaint
	    SET Shipping_Point = isNull(c.Field_Value, iim.Shipping_Point)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ShippingPoint'
	    
	    UPDATE #ImportItemMaint
	    SET Country_Of_Origin = isNull(c.Field_Value, iim.Country_Of_Origin)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CountryOfOrigin'
		
		UPDATE #ImportItemMaint
	    SET Country_Of_Origin_Name = isNull(c.Field_Value, iim.Country_Of_Origin_Name)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CountryOfOriginName'
		
		UPDATE #ImportItemMaint
	    SET Vendor_Comments = isNull(c.Field_Value, iim.Vendor_Comments)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'VendorComments'
		
		UPDATE #ImportItemMaint
	    SET Stock_Category = isNull(c.Field_Value, iim.Stock_Category)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'StockCategory'
	    
	    UPDATE #ImportItemMaint
	    SET Freight_Terms = isNull(c.Field_Value, iim.Freight_Terms)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FreightTerms'
	    
	    UPDATE #ImportItemMaint
	    SET Item_Type = isNull(c.Field_Value, iim.Item_Type)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemType'
	    
	    UPDATE #ImportItemMaint
	    SET Pack_Item_Indicator = isNull(c.Field_Value, iim.Pack_Item_Indicator)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemType'
	    
	    UPDATE #ImportItemMaint
	    SET Item_Type_Attribute = isNull(c.Field_Value, iim.Item_Type_Attribute)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ItemTypeAttribute'
	    
	    UPDATE #ImportItemMaint
	    SET Allow_Store_Order = isNull(c.Field_Value, iim.Allow_Store_Order)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AllowStoreOrder'
	    
	    UPDATE #ImportItemMaint
	    SET Inventory_Control = isNull(c.Field_Value, iim.Inventory_Control)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'InventoryControl'
	    
	    UPDATE #ImportItemMaint
	    SET Auto_Replenish = isNull(c.Field_Value, iim.Auto_Replenish)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'AutoReplenish'
		
		UPDATE #ImportItemMaint
	    SET Pre_Priced = isNull(c.Field_Value, iim.Pre_Priced)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PrePriced'
		
		UPDATE #ImportItemMaint
	    SET Pre_Priced_UDA = isNull(c.Field_Value, iim.Pre_Priced_UDA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PrePricedUDA'
		
		UPDATE #ImportItemMaint
	    SET Tax_UDA = isNull(c.Field_Value, iim.Tax_UDA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TaxUDA'
	    
	    UPDATE #ImportItemMaint
	    SET Tax_Value_UDA = isNull(c.Field_Value, iim.Tax_Value_UDA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TaxValueUDA'
	    
	 --   UPDATE #ImportItemMaint
	 --   SET Hybrid_Type = isNull(c.Field_Value, iim.Hybrid_Type)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'HybridType'
	    
	 --   UPDATE #ImportItemMaint
	 --   SET Sourcing_DC = isNull(c.Field_Value, iim.Sourcing_DC)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'HybridSourceDC'
	    
	    UPDATE #ImportItemMaint 
	    SET STOCKING_STRATEGY_CODE = isNull(c.Field_Value, iim.STOCKING_STRATEGY_CODE)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
	    WHERE    c.Field_Name = 'StockingStrategy'
	    
	    UPDATE #ImportItemMaint
	    SET Outbound_Freight = isNull(c.Field_Value, iim.Outbound_Freight)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OutboundFreight'
	    
	    UPDATE #ImportItemMaint
	    SET Nine_Percent_Whse_Charge = isNull(c.Field_Value, iim.Nine_Percent_Whse_Charge)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'NinePercentWhseCharge'
	    
	    UPDATE #ImportItemMaint
	    SET Total_Store_Landed_Cost = isNull(c.Field_Value, iim.Total_Store_Landed_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TotalStoreLandedCost'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_Yes = CASE WHEN c.Field_Value is not null THEN 
								CASE WHEN c.Field_Value = 'Y' THEN 'X' Else '' END
						  ELSE Haz_Mat_Yes END
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Hazardous'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_No = CASE WHEN c.Field_Value is not null THEN 
								CASE WHEN c.Field_Value = 'N' THEN 'X' Else '' END
						  ELSE Haz_Mat_No END
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Hazardous'
		
		UPDATE #ImportItemMaint
	    SET Haz_Mat_Container_Type = isNull(c.Field_Value, iim.Haz_Mat_Container_Type)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousContainerType'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_Container_Size = isNull(c.Field_Value, iim.Haz_Mat_Container_Size)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousContainerSize'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_MSDS_UOM = isNull(c.Field_Value, iim.Haz_Mat_MSDS_UOM)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousMSDSUOM'
	    
	    UPDATE #ImportItemMaint
	    SET Haz_Mat_MSDS_UOM = isNull(c.Field_Value, iim.Haz_Mat_MSDS_UOM)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'HazardousMSDSUOM'
	    
	    UPDATE #ImportItemMaint
	    SET TSSA = isNull(c.Field_Value, iim.TSSA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TSSA'
	    
	    UPDATE #ImportItemMaint
	    SET CSA = isNull(c.Field_Value, iim.CSA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CSA'
	    
	    UPDATE #ImportItemMaint
	    SET UL = isNull(c.Field_Value, iim.UL)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'UL'
	    
	    UPDATE #ImportItemMaint
	    SET Licence_Agreement = isNull(c.Field_Value, iim.Licence_Agreement)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'LicenceAgreement'
	    
	    UPDATE #ImportItemMaint
	    SET Fumigation_Certificate = isNull(c.Field_Value, iim.Fumigation_Certificate)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FumigationCertificate'
		
	    UPDATE #ImportItemMaint
	    SET KILN_Dried_Certificate = isNull(c.Field_Value, iim.KILN_Dried_Certificate)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'KILNDriedCertificate'
		
		UPDATE #ImportItemMaint
	    SET China_Com_Inspec_Num_And_CCIB_Stickers = isNull(c.Field_Value, iim.China_Com_Inspec_Num_And_CCIB_Stickers)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ChinaComInspecNumAndCCIBStickers'
		
		UPDATE #ImportItemMaint
	    SET Original_Visa = isNull(c.Field_Value, iim.Original_Visa)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'OriginalVisa'
		
		UPDATE #ImportItemMaint
	    SET Textile_Declaration_Mid_Code = isNull(c.Field_Value, iim.Textile_Declaration_Mid_Code)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TextileDeclarationMidCode'
	    
	    UPDATE #ImportItemMaint
	    SET Quota_Charge_Statement = isNull(c.Field_Value, iim.Quota_Charge_Statement)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'QuotaChargeStatement'
	    
	    UPDATE #ImportItemMaint
	    SET MSDS = isNull(c.Field_Value, iim.MSDS)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'MSDS'
	    
	    UPDATE #ImportItemMaint
	    SET TSCA = isNull(c.Field_Value, iim.TSCA)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TSCA'
		
		UPDATE #ImportItemMaint
	    SET Drop_Ball_Test_Cert = isNull(c.Field_Value, iim.Drop_Ball_Test_Cert)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DropBallTestCert'
	    
	    UPDATE #ImportItemMaint
	    SET Man_Medical_Device_Listing = isNull(c.Field_Value, iim.Man_Medical_Device_Listing)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManMedicalDeviceListing'
	    
	    UPDATE #ImportItemMaint
	    SET Man_FDA_Registration = isNull(c.Field_Value, iim.Man_FDA_Registration)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ManFDARegistration'
		
		UPDATE #ImportItemMaint
	    SET Copy_Right_Indemnification = isNull(c.Field_Value, iim.Copy_Right_Indemnification)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CopyRightIndemnification'
		
		UPDATE #ImportItemMaint
	    SET Fish_Wild_Life_Cert = isNull(c.Field_Value, iim.Fish_Wild_Life_Cert)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FishWildLifeCert'
	    
	    UPDATE #ImportItemMaint
	    SET Proposition_65_Label_Req = isNull(c.Field_Value, iim.Proposition_65_Label_Req)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'Proposition65LabelReq'
	    
	    UPDATE #ImportItemMaint
	    SET CCCR = isNull(c.Field_Value, iim.CCCR)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CCCR'
	    
	    UPDATE #ImportItemMaint
	    SET Formaldehyde_Compliant = isNull(c.Field_Value, iim.Formaldehyde_Compliant)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FormaldehydeCompliant'
	    
	    UPDATE #ImportItemMaint
	    SET RMS_Sellable = isNull(c.Field_Value, iim.RMS_Sellable)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'RMSSellable'
	    
	    UPDATE #ImportItemMaint
	    SET RMS_Orderable = isNull(c.Field_Value, iim.RMS_Orderable)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'RMSOrderable'
	    
	    UPDATE #ImportItemMaint
	    SET RMS_Inventory = isNull(c.Field_Value, iim.RMS_Inventory)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'RMSInventory'
		
		UPDATE #ImportItemMaint
	    SET Store_Total = isNull(c.Field_Value, iim.Store_Total)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'StoreTotal'
		
		UPDATE #ImportItemMaint
	    SET Displayer_Cost = isNull(c.Field_Value, iim.Displayer_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'DisplayerCost'
		
		UPDATE #ImportItemMaint
	    SET Product_Cost = isNull(c.Field_Value, iim.Product_Cost)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'ProductCost'
	    	    
		UPDATE #ImportItemMaint
	    SET Private_Brand_Label = isNull(c.Field_Value, iim.Private_Brand_Label)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PrivateBrandLabel'
		
		UPDATE #ImportItemMaint
	    SET Quote_Reference_Number = isNull(c.Field_Value, iim.Quote_Reference_Number)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'QuoteReferenceNumber'
		
		UPDATE #ImportItemMaint
	    SET Customs_Description = isNull(c.Field_Value, iim.Customs_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CustomsDescription'
		
		UPDATE #ImportItemMaint
	    SET Package_Language_Indicator_English = isNull(c.Field_Value, iim.Package_Language_Indicator_English)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PLIEnglish'
		
	    UPDATE #ImportItemMaint
	    SET Package_Language_Indicator_French = isNull(c.Field_Value, iim.Package_Language_Indicator_French)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PLIFrench'
		
		UPDATE #ImportItemMaint
	    SET Package_Language_Indicator_Spanish = isNull(c.Field_Value, iim.Package_Language_Indicator_Spanish)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PLISpanish'
	    
	    UPDATE #ImportItemMaint
	    SET Translation_Indicator_English = isNull(c.Field_Value, iim.Translation_Indicator_English)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TIEnglish'
	    
	    UPDATE #ImportItemMaint
	    SET Translation_Indicator_French = isNull(c.Field_Value, iim.Translation_Indicator_French)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TIFrench'
		
		UPDATE #ImportItemMaint
	    SET Translation_Indicator_Spanish = isNull(c.Field_Value, iim.Translation_Indicator_Spanish)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'TISpanish'
	    
		UPDATE #ImportItemMaint
	    SET English_Short_Description = isNull(c.Field_Value, iim.English_Short_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EnglishShortDescription'
	    
	    UPDATE #ImportItemMaint
	    SET English_Long_Description = isNull(c.Field_Value, iim.English_Long_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'EnglishLongDescription'
	    
	    UPDATE #ImportItemMaint
	    SET French_Short_Description = isNull(c.Field_Value, iim.French_Short_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FrenchShortDescription'
	    
	    UPDATE #ImportItemMaint
	    SET French_Long_Description = isNull(c.Field_Value, iim.French_Long_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FrenchLongDescription'
		
		UPDATE #ImportItemMaint
	    SET Spanish_Short_Description = isNull(c.Field_Value, iim.Spanish_Short_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'SpanishShortDescription'
	    
	    UPDATE #ImportItemMaint
	    SET Spanish_Long_Description = isNull(c.Field_Value, iim.Spanish_Long_Description)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'SpanishLongDescription'
	    
	    Select * from #ImportItemMaint
	    
	    Drop Table #ImportItemMaint
END

go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SPD_Report_CompletedImportItem] 
	@startDate as Datetime = null,
	@endDate as DateTime = null,
	@dept as integer = null,
	@vendor as bigint = null,
	@vendorFilter as bigint = null,
	@workflowId as integer = 1,
	@approver as integer = null
AS

declare @dateNow datetime        
declare @dateNowStr varchar(20)        
declare @month varchar(2), @day varchar(2), @year varchar(4)            

set @dateNow = getdate()        
set @month = convert(varchar(2), Month(@dateNow))          
if (len(@month) < 2)             
	set @month = '0' + @month          

set @day = convert(varchar(2), Day(@dateNow))          
if (len(@day) < 2)             
	set @day = '0' + @day         

set @year = convert(varchar(4), Year(@dateNow))          
if (len(@year) < 4)             
	set @year = '00' + @year             

set @dateNowStr =  @year + @month + @day                


IF (@workflowId = 1)
BEGIN

  SELECT  ii.ID, ii.Batch_ID, ii.DateCreated, ii.DateLastModified, 		
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ii.CreatedUserID) as CreatedUser,
		'System' as UpdateUser,
	  ii.DateSubmitted, ii.Vendor, ii.Agent as MerchBurden, ii.AgentType as MerchBurdenType, ii.Buyer, ii.Fax, ii.EnteredBy, ii.QuoteSheetStatus, ii.Season, ii.SKUGroup, ii.Email, 
	  ii.EnteredDate, ii.Dept, ii.[Class], ii.SubClass, ii.PrimaryUPC, ii.MichaelsSKU as SKU, ii.GenerateMichaelsUPC as GenerateUPC, ii.AdditionalUPC1, 
	  ii.AdditionalUPC2, ii.AdditionalUPC3, ii.AdditionalUPC4, ii.AdditionalUPC5, ii.AdditionalUPC6, ii.AdditionalUPC7, ii.AdditionalUPC8, 
	  ii.PackSKU, ii.PlanogramName, ii.VendorNumber, ii.VendorRank, ii.ItemTask, ii.Description, ii.PaymentTerms, ii.Days,     
	  ii.VendorMinOrderAmount, ii.VendorName, ii.VendorAddress1, ii.VendorAddress2, ii.VendorAddress3, ii.VendorAddress4, 
	  ii.VendorContactName, ii.VendorContactPhone, ii.VendorContactEmail, ii.VendorContactFax, ii.ManufactureName, ii.ManufactureAddress1, 
	  ii.ManufactureAddress2, ii.ManufactureContact, ii.ManufacturePhone, ii.ManufactureEmail, ii.ManufactureFax, ii.AgentContact, 
	  ii.AgentPhone, ii.AgentEmail, ii.AgentFax, ii.VendorStyleNumber, ii.HarmonizedCodeNumber, ii.canadaHarmonizedCodeNumber as CanadaHarmonizedCodeNumber,
	  ii.DetailInvoiceCustomsDesc, 
	  ii.ComponentMaterialBreakdown, ii.ComponentConstructionMethod, ii.IndividualItemPackaging, ii.EachInsideMasterCaseBox,    
	  ii.EachInsideInnerPack, ii.ReshippableInnerCartonWeight,--ii.EachPieceNetWeightLbsPerOunce,
	  ii.eachlength as EachCartonLength, ii.eachwidth as EachCartonWidth,ii.eachheight as EachCartonHeight,ii.cubicfeeteach as CubicFeetPerEachCarton,ii.eachweight as EachCartonWeight,  
	  ii.ReshippableInnerCartonLength, ii.ReshippableInnerCartonWidth, 
	  ii.ReshippableInnerCartonHeight, ii.MasterCartonDimensionsLength, ii.MasterCartonDimensionsWidth, 
	  ii.MasterCartonDimensionsHeight, ii.CubicFeetPerMasterCarton, ii.WeightMasterCarton, ii.CubicFeetPerInnerCarton, 
	  ii.FOBShippingPoint, ii.DutyPercent, ii.DutyAmount, ii.AdditionalDutyComment, ii.AdditionalDutyAmount, ii.OceanFreightAmount,
	  ii.OceanFreightComputedAmount, ii.AgentCommissionPercent As MerchBurdenPercent, ii.AgentCommissionAmount As MerchBurdenAmount, ii.OtherImportCostsPercent, 
	  ii.OtherImportCostsAmount, ii.PackagingCostAmount, ii.TotalImportBurden, ii.WarehouseLandedCost, ii.PurchaseOrderIssuedTo, 
	  ii.ShippingPoint, ii.CountryOfOrigin, ii.CountryOfOriginName, ii.VendorComments, ii.StockCategory, ii.FreightTerms, 
	  ii.ItemType, ii.PackItemIndicator, ii.ItemTypeAttribute, ii.AllowStoreOrder, ii.InventoryControl, ii.AutoReplenish, 
	  ii.PrePriced, ii.TaxUDA, ii.PrePricedUDA, ii.TaxValueUDA, ii.Stocking_Strategy_Code, 
	  --ii.HybridType, ii.SourcingDC, ii.LeadTime, ii.ConversionDate, 
	  ii.StoreSuppZoneGRP, ii.WhseSuppZoneGRP,    ii.POGMaxQty, ii.POGSetupPerStore as Initial_Set_Qty_Per_Store, ii.OutboundFreight, 
	  ii.NinePercentWhseCharge, ii.TotalStoreLandedCost, ii.RDBase as Base1_Retail, ii.RDCentral as Base2_Retail, 
	  ii.RDTest as Test_Retail, ii.RDAlaska as Alaska_Retail, ii.RDCanada as Canada_Retail, ii.RD0Thru9 as High2_Retail,
	  ii.RDCalifornia as High3_Retail, ii.RDVillageCraft as Small_Market_Retail, ii.Retail9 as High1_Retail, ii.Retail10 as Base3_Retail,
	  ii.Retail11 as Low1_Retail, ii.Retail12 as Low2_Retail, ii.Retail13 as Manhattan_Retail, ii.RDQuebec as Q5_Retail, 
	  ii.RDPuertoRico as PR_Retail, ii.HazMatYes, ii.HazMatNo, ii.HazMatMFGCountry, ii.HazMatMFGName, ii.HazMatMFGFlammable, 
	  ii.HazMatMFGCity, ii.HazMatContainerType, ii.HazMatMFGState, ii.HazMatContainerSize, ii.HazMatMFGPhone,ii.HazMatMSDSUOM, ii.TSSA, 
	  ii.CSA, ii.UL, ii.LicenceAgreement, ii.FumigationCertificate, ii.KILNDriedCertificate, ii.ChinaComInspecNumAndCCIBStickers,     
	  ii.OriginalVisa, ii.TextileDeclarationMidCode, ii.QuotaChargeStatement, ii.MSDS, ii.TSCA, ii.DropBallTestCert, 
	  ii.ManMedicalDeviceListing, ii.ManFDARegistration,    ii.CopyRightIndemnification, ii.FishWildLifeCert, ii.Proposition65LabelReq, 
	  ii.CCCR, ii.FormaldehydeCompliant, ii.Is_Valid, ii.Tax_Wizard, ii.RMS_Sellable, ii.RMS_Orderable, ii.RMS_Inventory, ii.Parent_ID, 
	  ii.RegularBatchItem, ii.[Sequence], ii.Store_Total, ii.POG_Start_Date, ii.POG_Comp_Date, ii.Like_Item_SKU, ii.Like_Item_Description, 
	  ii.Like_Item_Retail, ii.Like_Item_Regular_Unit, ii.Like_Item_Sales, ii.Facings, ii.POG_Min_Qty, ii.Displayer_Cost, ii.Product_Cost,
	  ii.Calculate_Options, ii.Like_Item_Store_Count, ii.Like_Item_Unit_Store_Month, ii.Annual_Reg_Retail_Sales, 
	  ii.Annual_Regular_Unit_Forecast, ii.Inner_Pack,    ii.Min_Pres_Per_Facing, b.Date_Modified as Last_Modified,    
	  case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>' else '' end as Item_Image, 
	  case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>' else '' end as MSDS_Sheet, 
	  COALESCE(lv.Display_Text, '') as Private_Brand_Label, ii.QuoteReferenceNumber, ii.Customs_Description,   
	  silEs.Package_Language_Indicator as Package_Language_Indicator_English,   
	  silFs.Package_Language_Indicator as Package_Language_Indicator_French,   
	  silSs.Package_Language_Indicator as Package_Language_Indicator_Spanish,     
	  silE.Translation_Indicator as Translation_Indicator_English,   
	  silF.Translation_Indicator as Translation_Indicator_French,   
	  silS.Translation_Indicator as Translation_Indicator_Spanish,       
	  silE.Description_Short as English_Short_Description, silE.Description_Long as English_Long_Description, 
	  silF.Description_Short as French_Short_Description, silF.Description_Long as French_Long_Description, 
	  silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description            
  FROM [SPD_Import_Items] ii with(nolock)            
	  inner join [SPD_Batch] b with(nolock) on ii.Batch_ID = b.ID             
	  left outer join SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1             
	  LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = ii.[ID] and f1.File_Type = 'IMG'              
	  LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = ii.[ID] and f2.File_Type = 'MSDS'          
	  LEFT JOIN SPD_Item_Master_Languages as silE with(nolock) on silE.Michaels_SKU = ii.MichaelsSKU and silE.Language_Type_ID = 1 -- ENGLISH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages as silF with(nolock) on silF.Michaels_SKU = ii.MichaelsSKU and silF.Language_Type_ID = 2 -- FRENCH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages as silS with(nolock) on silS.Michaels_SKU = ii.MichaelsSKU and silS.Language_Type_ID = 3 -- SPANISH Language Fields             
	  LEFT JOIN SPD_Item_Master_Languages_Supplier as silEs with(nolock) on silEs.Michaels_SKU = ii.MichaelsSKU and silEs.Vendor_Number = ii.VendorNumber and silEs.Language_Type_ID = 1 -- ENGLISH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages_Supplier as silFs with(nolock) on silFs.Michaels_SKU = ii.MichaelsSKU and silFs.Vendor_Number = ii.VendorNumber and silFs.Language_Type_ID = 2 -- FRENCH Language Fields            
	  LEFT JOIN SPD_Item_Master_Languages_Supplier as silSs with(nolock) on silSs.Michaels_SKU = ii.MichaelsSKU and silSs.Vendor_Number = ii.VendorNumber and silSs.Language_Type_ID = 3 -- SPANISH Language Fields             
	  LEFT OUTER JOIN List_Values as lv with(nolock) on lv.List_Value_Group_ID = 16 And ii.Private_Brand_Label = lv.List_Value        
  WHERE b.Batch_Type_ID = 2 
	and	(@startDate is null or (@startDate is not null and b.date_modified >= @startDate))      
	and (@endDate is null or (@endDate is not null and b.date_modified <= @endDate))      
	and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept))      
	and (COALESCE(ws.Workflow_id, 1) = 1 and COALESCE(ws.Stage_Type_id, 1) = 4)   
	and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and b.Vendor_Number = @vendor))    
	and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and b.Vendor_Number = @vendorFilter))            
	and (isnull(@approver, 0) = 0 or (isnull(@approver, 0) > 0 and b.ID in (SELECT distinct spd_batch_ID from SPD_Batch_History WHERE modified_user = @approver)))      
END

IF (@workflowId = 2)
BEGIN

	SELECT simi.ID, simi.Batch_ID, simi.Date_Created, b.Date_Modified, 
	    (SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = b.Created_User) as [Created User],
	    'System' as Update_User,
		b.Date_Created as Date_Submitted, 
		CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'V' Then 'YES' Else 'NO' END as [Vendor], CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'A' Then 'YES' Else 'NO' END as [Merch_Burden], 
		v.Agent_Type as Merch_Burden_Type, s.Buyer, s.Buyer_Fax as [Fax],
		su.First_Name + ' ' + su.Last_Name as [Entered_By], 
		s.Season, s.SKU_Group, s.Buyer_Email,
		b.Date_Created as [Entered_Date], 
		s.Department_Num, s.Class_Num, s.Sub_Class_Num, upc.UPC as Primary_UPC, s.Michaels_SKU as SKU, 
		(SELECT     COUNT(*) AS Expr1
			FROM          dbo.SPD_Item_Master_Vendor_UPCs AS UPC2
            WHERE      (Michaels_SKU = s.Michaels_SKU) AND (Vendor_Number = V.Vendor_Number) AND (Primary_Indicator = 0)) AS AdditionalUPCs, --TODO: Figure out how to handle multiple UPC stuff..
		s.Pack_SKU, s.Planogram_Name, v.Vendor_Number,
		'EDIT ITEM' as Item_Task, 
		s.Item_Desc as [Description], 
		v.PaymentTerms as Payment_Terms, v.Days,v.Vendor_Min_Order_Amount, v.Vendor_Name, v.Vendor_Address1, v.Vendor_Address2, v.Vendor_Address3, v.Vendor_Address4,
		v.Vendor_Contact_Name, v.Vendor_Contact_Phone, v.Vendor_Contact_Email, v.Vendor_Contact_Fax,
		v.Manufacture_Name, v.Manufacture_Address1, v.Manufacture_Address2, v.Manufacture_Contact, v.Manufacture_Phone, v.Manufacture_Email, v.Manufacture_Fax,
		v.Agent_Contact, v.Agent_Phone, v.Agent_Email, v.Agent_Fax, v.Vendor_Style_Num as [Vendor_Style_Number], v.Harmonized_CodeNumber as [Harmonized_Code_Number],
		v.Canada_Harmonized_CodeNumber as [Canada_Harmonized_CodeNumber],
		v.Detail_Invoice_Customs_Desc0 as Detail_Invoice_Customs_Desc, v.Component_Material_Breakdown, v.Component_Construction_Method, v.Individual_Item_Packaging,
		C.Eaches_Master_Case, C.Eaches_Inner_Pack,
		C.Each_Case_Length as Each_Carton_Dimensions_Length,
		C.Each_Case_Width as Each_Carton_Dimensions_Width,
		C.Each_Case_Height as Each_Carton_Dimensions_Height,
		C.Each_Case_Cube as Cubic_Feet_Per_Each_Carton, 
		C.Each_Case_Weight as Weight_Each_Carton,
		C.Inner_Case_Weight as Each_Piece_Net_Weight_Lbs_Per_Ounce, 
		C.Inner_Case_Length as Reshippable_Inner_Carton_Length,
		C.Inner_Case_Width as Reshippable_Inner_Carton_Width, 
		C.Inner_Case_Height as Reshippable_Inner_Carton_Height, 
		C.Master_Case_Length as Master_Carton_Dimensions_Length,
		C.Master_Case_Width as Master_Carton_Dimensions_Width,
		C.Master_Case_Height as Master_Carton_Dimensions_Height,
		C.Master_Case_Cube as Cubic_Feet_Per_Master_Carton, 
		C.Master_Case_Weight as Weight_Master_Carton,
		C.Inner_Case_Cube as Cubic_Feet_Per_Inner_Carton,
		V.FOB_Shipping_Point, V.Duty_Percent, V.Duty_Amount, V.Additional_Duty_Comment, V.Additional_Duty_Amount, V.Ocean_Freight_Amount,  V.Ocean_Freight_Computed_Amount,
		V.Agent_Commission_Percent As Merch_Burden_Percent, V.Agent_Commission_Amount As Merch_Burden_Amount, V.Other_Import_Costs_Percent, V.Other_Import_Costs_Amount, V.Packaging_Cost_Amount,
		C.Import_Burden AS Import_Burden,  V.Warehouse_Landed_Cost, V.Purchase_Order_Issued_To, V.Shipping_Point, C.Country_Of_Origin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS Country_Of_Origin_Name,
		V.Vendor_Comments, s.Stock_Category, V.Freight_Terms, 
		UPPER(s.Item_Type) as Item_Type, UPPER(s.Item_Type) AS Pack_Item_Indicator,
		s.Item_Type_Attribute, UPPER(s.Allow_Store_Order) AS Allow_Store_Order, UPPER(s.Inventory_Control) as Inventory_Control, 
		UPPER(s.Auto_Replenish) AS Auto_Replenish, 
		CASE WHEN (SELECT COUNT(*) FROM  SPD_Item_Master_UDA UDA4 WHERE  UDA4.Michaels_SKU = s.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS Pre_Priced,
		(SELECT TOP (1) ISNULL(UDA_Value, 0) AS Expr1 FROM SPD_Item_Master_UDA AS UDA5 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 10)) AS Pre_Priced_UDA,
		(SELECT TOP (1) UDA_ID FROM SPD_Item_Master_UDA AS UDA2 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_UDA,
		(SELECT TOP (1) UDA_Value FROM SPD_Item_Master_UDA AS UDA3 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_Value_UDA,
		s.STOCKING_STRATEGY_CODE, --s.Hybrid_Type, s.Hybrid_Source_DC as Sourcing_DC, 
		s.Store_Supplier_Zone_Group as Store_Supp_Zone_GRP, s.WHS_Supplier_Zone_Group as Whse_Supp_Zone_GRP, s.POG_Max_Qty, s.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store,
		v.Outbound_Freight, v.Nine_Percent_Whse_Charge, v.Total_Store_Landed_Cost, s.Base1_Retail, s.Base2_Retail, s.Test_Retail, s.Alaska_Retail,
		s.Canada_Retail, s.High2_Retail, s.High3_Retail, s.Small_Market_Retail, s.High1_Retail, s.Base3_Retail, s.Low1_Retail, s.Low2_Retail, s.Manhattan_Retail, s.Quebec_Retail as Q5_Retail,
		s.PuertoRico_Retail as PR_Retail,  
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'Y' Then 'X' Else '' END as Haz_Mat_Yes, 
		CASE WHEN UPPER(COALESCE(s.Hazardous, '')) = 'N' Then 'X' Else '' END as Haz_Mat_No, 
		V.Hazardous_Manufacturer_Country as Haz_Mat_MFG_Country, V.Hazardous_Manufacturer_Name as Haz_Mat_MFG_Name, UPPER(s.Hazardous_Flammable) as Haz_Mat_MFG_Flammable,
		V.Hazardous_Manufacturer_City as Haz_Mat_MFG_City, UPPER(s.Hazardous_Container_Type) as Haz_Mat_Container_Type, V.Hazardous_Manufacturer_State as Haz_Mat_MFG_State,
		s.Hazardous_Container_Size as Haz_Mat_Container_Size, V.Hazardous_Manufacturer_Phone as Haz_Mat_MFG_Phone, UPPER(s.Hazardous_MSDS_UOM) as Haz_Mat_MSDS_UOM,
		s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
		s.Original_Visa, s.Textile_Declaration_Mid_Code, s.Quota_Charge_Statement, s.MSDS, s.TSCA, s.Drop_Bal_lTest_Cert as Drop_Ball_Test_Cert,
		s.Man_Medical_Device_Listing, s.Man_FDA_Registration, s.Copy_Right_Indemnification, s.Fish_Wild_Life_Cert, s.Proposition_65_Label_Req, s.CCCR,
		s.Formaldehyde_Compliant, s.RMS_Sellable, s.RMS_Orderable, s.RMS_Inventory, PKI.Pack_SKU as Parent_ID, 
		CASE WHEN UPPER(COALESCE(s.Pack_Item_Indicator,'')) = 'Y' Then 'NO' Else 'YES' END as Regular_Batch_Item, --TODO: Verify this is correct?
		s.Store_Total, 
		s.Displayer_Cost, C.Unit_Cost as Product_Cost, 
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=item_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS Private_Brand_Label,
		s.QuoteReferenceNumber as Quote_Reference_Number, s.Customs_Description,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, simlF.Description_Short as French_Short_Description,    
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, simlS.Description_Long as Spanish_Long_Description          
	FROM SPD_Item_Maint_Items as simi with(nolock) 
		INNER JOIN SPD_Batch as b with(nolock) on b.ID = simi.Batch_ID
		INNER JOIN SPD_Item_Master_SKU as s with(nolock) on s.Michaels_SKU = simi.Michaels_SKU
		INNER JOIN SPD_Item_Master_Vendor as v with(nolock) on v.Michaels_SKU = simi.Michaels_SKU and v.Vendor_Number = simi.Vendor_Number
		INNER JOIN SPD_Vendor as sv with(nolock) on sv.Vendor_Number = v.Vendor_Number	
		Left Outer Join Security_User as su with(nolock) on su.ID = b.Created_User
		LEFT OUTER JOIN SPD_Item_Master_Vendor_UPCs AS UPC with(nolock) ON v.Michaels_SKU = UPC.Michaels_SKU AND v.Vendor_Number = UPC.Vendor_Number AND UPC.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_Item_Master_Vendor_Countries AS C with(nolock) ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND C.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_COUNTRY AS CO with(nolock) ON CO.COUNTRY_CODE = C.Country_Of_Origin
		LEFT OUTER JOIN SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 2
		LEFT OUTER JOIN SPD_Item_Master_PackItems AS PKI with(nolock) ON s.Michaels_SKU = PKI.Child_SKU AND B.Pack_SKU = PKI.Pack_SKU   
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'I' and f1.Item_ID = v.Image_ID and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'I' and f2.Item_ID = v.MSDS_ID and f2.File_Type = 'MSDS'          
		LEFT JOIN SPD_Item_Master_Languages as simlE with(nolock) on simlE.Michaels_SKU = s.Michaels_SKU and simlE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlF with(nolock) on simlF.Michaels_SKU = s.Michaels_SKU and simlF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlS with(nolock) on simlS.Michaels_SKU = s.Michaels_SKU  and simlS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsE with(nolock) on simlsE.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsF.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsS.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
	WHERE b.Enabled = 1 AND sv.Vendor_Type = 300  and b.Batch_Type_ID=2
		and (@startDate is null or (@startDate is not null and b.Date_Modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.Date_Modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and s.Department_Num = @dept))        
		and ws.Workflow_id = 2 and COALESCE(ws.Stage_Type_id, 1) = 4
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and v.Vendor_Number = @vendor))
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and v.Vendor_Number = @vendorFilter))            
	    and (isnull(@approver, 0) = 0 or (isnull(@approver, 0) > 0 and b.ID in (SELECT distinct spd_batch_ID from SPD_Batch_History WHERE modified_user = @approver)))      
END
GO