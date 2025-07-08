--*********************
--  NEW PHYTO
--  PROC ALTERS Version PHTYO Changes
--*********************


/****** Object:  StoredProcedure [dbo].[sp_SPD_Import_Item_SaveRecord]    Script Date: 4/9/2024 10:22:06 AM ******/
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
	--PMO200141 GTIN14 Enhancements changes
	@InnerGTIN varchar(100) = null,
	@CaseGTIN varchar(100) = null,
	@GenerateMichaelsGTIN varchar(1) = null,
	--PMO200141 GTIN14 Enhancements changes end
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
	@CoinBattery varchar(1) = null,
	@TSSA varchar(1) = null,
	@CSA varchar(1) = null,
	@UL varchar(1) = null,
	@LicenceAgreement varchar(1) = null,
	@FumigationCertificate varchar(1) = null,
	@PhytoTemporaryShipment varchar(1) = null,
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
	@CanadaHarmonizedCodeNumber varchar(10) = Null,
	@SuppTariffPercent varchar(100) = null,
	@SuppTariffAmount varchar(100) = null,
	@MinimumOrderQuantity int = null, 
	@ProductIdentifiesAsCosmetic varchar(1) = null
	
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
			CoinBattery = @CoinBattery,
			TSSA = @TSSA,
			CSA = @CSA,
			UL = @UL,
			LicenceAgreement = @LicenceAgreement,
			FumigationCertificate = @FumigationCertificate,
			PhytoTemporaryShipment = @PhytoTemporaryShipment,
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
			CanadaHarmonizedCodeNumber = @CanadaHarmonizedCodeNumber,
			SuppTariffPercent = @SuppTariffPercent,
			SuppTariffAmount = @SuppTariffAmount,
		    InnerGTIN = @InnerGTIN,
			CaseGTIN = @CaseGTIN,
			GenerateMichaelsGTIN = @GenerateMichaelsGTIN,
			MinimumOrderQuantity = @MinimumOrderQuantity,
			ProductIdentifiesAsCosmetic = @ProductIdentifiesAsCosmetic
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
			CoinBattery,
			TSSA,
			CSA,
			UL,
			LicenceAgreement,
			FumigationCertificate,
			PhytoTemporaryShipment,
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
			CanadaHarmonizedCodeNumber,
			SuppTariffPercent,
			SuppTariffAmount,
			--PMO200141 GTIN14 Enhancements changes Start
			InnerGTIN,
			CaseGTIN,
			GenerateMichaelsGTIN,
			--PMO200141 GTIN14 Enhancements changes End
			MinimumOrderQuantity,
			ProductIdentifiesAsCosmetic
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
			@CoinBattery,
			@TSSA,
			@CSA,
			@UL,
			@LicenceAgreement,
			@FumigationCertificate,
			@PhytoTemporaryShipment,
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
			@CanadaHarmonizedCodeNumber,
			@SuppTariffPercent,
			@SuppTariffAmount,
			--PMO200141 GTIN14 Enhancements changes Start
			@InnerGTIN,
			@CaseGTIN,
			@GenerateMichaelsGTIN,
			--PMO200141 GTIN14 Enhancements changes End
			@MinimumOrderQuantity,
			@ProductIdentifiesAsCosmetic
		)
		SET @ID = SCOPE_IDENTITY()
	END



	GO

	/****** Object:  StoredProcedure [dbo].[sp_SPD_Batch_PublishMQMessage_ByBatchID]    Script Date: 4/2/2024 7:52:11 AM ******/
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
              ,COALESCE(rtrim(replace(replace(dbo.udf_ReplaceSpecialChars(item.[item_desc]), char(13), ' '), char(10), ' ')), '') As item_desc
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
              ,case when COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Short]), '') = '' then 'Desc. not available' else COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Short]), 'Desc. not available') end as short_cfd 
              ,case when COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Long]), '') = '' then 'Description not available' else COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Long]), 'Description not available') end as long_cfd
			  ,COALESCE(item.Harmonized_Code_Number, '') as import_hts_code
			  ,COALESCE(item.Canada_Harmonized_Code_Number, '') as canada_hts_code
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.Customs_Description), '') as short_customs_desc         
			  --PMO200141 GTIN14 Enhancements changes
			  ,COALESCE(item.[vendor_inner_gtin], '') As vendor_inner_gtin
			  ,COALESCE(item.[vendor_case_gtin], '') As vendor_case_gtin
			  ,COALESCE(item.[PhytoSanitaryCertificate], '') As phytosanitarycertificate 
			  ,COALESCE(item.[PhytoTemporaryShipment], '') As phytotemporaryshipment
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
              ,COALESCE(rtrim(replace(replace(dbo.udf_ReplaceSpecialChars(importitem.[description]), char(13), ' '), char(10), ' ')), '') As description
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
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.Customs_Description), '') as shortcustomsdescription
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
              ,COALESCE(importitem.[CoinBattery], '') As coinbattery
              ,COALESCE(importitem.[tssa], '') As tssa
              ,COALESCE(importitem.[csa], '') As csa
              ,COALESCE(importitem.[ul], '') As ul
              ,COALESCE(importitem.[licenceagreement], '') As licenceagreement
              ,COALESCE(importitem.[fumigationcertificate], '') As phytosanitarycertificate  
			  ,COALESCE(importitem.[PhytoTemporaryShipment], '') As phytotemporaryshipment
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
			  ,case when COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Short]), '') = '' then 'Desc. not available' else COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Short]), 'Desc. not available') end as short_cfd 
              ,case when COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Long]), '') = '' then 'Description not available' else COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Long]), 'Description not available') end as long_cfd
              --PMO200141 GTIN14 Enhancements changes
			  ,COALESCE(importitem.[innergtin], '') As innergtin
			  ,COALESCE(importitem.[casegtin], '') As casegtin
			  --,COALESCE(CONVERT(varchar(25),importitem.[MinimumOrderQuantity]), '') As MinimumOrderQuantity
			  --,COALESCE(importitem.[ProductIdentifiesAsCosmetic], '') As ProductIdentifiesAsCosmetic
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



  GO

  /****** Object:  StoredProcedure [dbo].[SPD_Report_CompletedImportItem]    Script Date: 4/2/2024 10:10:27 AM ******/
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
	  ii.VendorName, ii.VendorAddress1, ii.VendorAddress2, ii.VendorAddress3, ii.VendorAddress4, 
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
	  ii.FOBShippingPoint, ii.DutyPercent, ii.DutyAmount, ii.AdditionalDutyComment, ii.AdditionalDutyAmount, ii.SuppTariffPercent, ii.SuppTariffAmount, ii.OceanFreightAmount,
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
	  ii.HazMatMFGCity, ii.HazMatContainerType, ii.HazMatMFGState, ii.HazMatContainerSize, ii.HazMatMFGPhone,ii.HazMatMSDSUOM, ii.CoinBattery, ii.TSSA, 
	  ii.CSA, ii.UL, ii.LicenceAgreement, ii.FumigationCertificate as PhytoSanitaryCertificate, ii.PhytoTemporaryShipment, ii.KILNDriedCertificate, ii.ChinaComInspecNumAndCCIBStickers,     
	  ii.OriginalVisa, ii.TextileDeclarationMidCode, ii.QuotaChargeStatement, ii.MSDS, ii.TSCA, ii.DropBallTestCert, 
	  ii.ManMedicalDeviceListing, ii.ManFDARegistration,    ii.CopyRightIndemnification, ii.FishWildLifeCert, ii.Proposition65LabelReq, 
	  ii.CCCR, ii.FormaldehydeCompliant, ii.Is_Valid, ii.Tax_Wizard, ii.RMS_Sellable, ii.RMS_Orderable, ii.RMS_Inventory, ii.Parent_ID, 
	  ii.RegularBatchItem, ii.[Sequence], ii.Store_Total, ii.POG_Start_Date, ii.POG_Comp_Date, ii.Like_Item_SKU, ii.Like_Item_Description, 
	  ii.Like_Item_Retail, ii.Like_Item_Regular_Unit, ii.Like_Item_Sales, ii.Facings, ii.POG_Min_Qty, ii.Displayer_Cost, ii.Product_Cost,
	  ii.Calculate_Options, ii.Like_Item_Store_Count, ii.Like_Item_Unit_Store_Month, ii.Annual_Reg_Retail_Sales, 
	  ii.Annual_Regular_Unit_Forecast, ii.Inner_Pack,    ii.Min_Pres_Per_Facing, b.Date_Modified as Last_Modified,    
	  case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>' else '' end as Item_Image, 
	  case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>' else '' end as MSDS_Sheet, 
	  COALESCE(lv.Display_Text, '') as Private_Brand_Label, ii.QuoteReferenceNumber, ii.Customs_Description,  --ii.MinimumOrderQuantity, ii.VendorMinOrderAmount as MinimumOrderAmount, ii.ProductIdentifiesAsCosmetic,
	  silEs.Package_Language_Indicator as Package_Language_Indicator_English,   
	  silFs.Package_Language_Indicator as Package_Language_Indicator_French,   
	  silSs.Package_Language_Indicator as Package_Language_Indicator_Spanish,     
	  silE.Translation_Indicator as Translation_Indicator_English,   
	  silF.Translation_Indicator as Translation_Indicator_French,   
	  silS.Translation_Indicator as Translation_Indicator_Spanish,       
	  silE.Description_Short as English_Short_Description, silE.Description_Long as English_Long_Description, 
	  silF.Description_Short as French_Short_Description, --silF.Description_Medium as French_Item_Description, MWM:LCR
	  silF.Description_Long as French_Long_Description, 
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
		v.PaymentTerms as Payment_Terms, v.Days, v.Vendor_Name, v.Vendor_Address1, v.Vendor_Address2, v.Vendor_Address3, v.Vendor_Address4,
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
		V.FOB_Shipping_Point, V.Duty_Percent, V.Duty_Amount, V.Additional_Duty_Comment, V.Additional_Duty_Amount, V.Supp_Tariff_Percent, V.Supp_Tariff_Amount, V.Ocean_Freight_Amount,  V.Ocean_Freight_Computed_Amount,
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
		s.CoinBattery, s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate as PhytoSanitaryCertificate,s.PhytoTemporaryShipment, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
		s.Original_Visa, s.Textile_Declaration_Mid_Code, s.Quota_Charge_Statement, s.MSDS, s.TSCA, s.Drop_Bal_lTest_Cert as Drop_Ball_Test_Cert,
		s.Man_Medical_Device_Listing, s.Man_FDA_Registration, s.Copy_Right_Indemnification, s.Fish_Wild_Life_Cert, s.Proposition_65_Label_Req, s.CCCR,
		s.Formaldehyde_Compliant, s.RMS_Sellable, s.RMS_Orderable, s.RMS_Inventory, PKI.Pack_SKU as Parent_ID, 
		CASE WHEN UPPER(COALESCE(s.Pack_Item_Indicator,'')) = 'Y' Then 'NO' Else 'YES' END as Regular_Batch_Item, --TODO: Verify this is correct?
		s.Store_Total, 
		s.Displayer_Cost, C.Unit_Cost as Product_Cost, 
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=item_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS Private_Brand_Label,
		s.QuoteReferenceNumber as Quote_Reference_Number, s.Customs_Description, --v.MinimumOrderQuantity, v.Vendor_Min_Order_Amount as MinimumOrderAmount, v.ProductIdentifiesAsCosmetic,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, 
		simlF.Description_Short as French_Short_Description,   --simlF.Description_Medium as French_Item_Description,  MWM:LCR
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

/****** Object:  StoredProcedure [dbo].[SPD_Report_ImportItem]    Script Date: 4/2/2024 10:12:42 AM ******/
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
		ii.[Description], ii.PaymentTerms, ii.[Days], ii.VendorName, ii.VendorAddress1, ii.VendorAddress2,    
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
		ii.DutyPercent, ii.DutyAmount, ii.AdditionalDutyComment, ii.AdditionalDutyAmount, ii.SuppTariffPercent, ii.SuppTariffAmount, ii.OceanFreightAmount, ii.OceanFreightComputedAmount,     
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
		ii.HazMatContainerType, ii.HazMatMFGState, ii.HazMatContainerSize, ii.HazMatMFGPhone, ii.HazMatMSDSUOM, ii.CoinBattery, ii.TSSA, ii.CSA, ii.UL, ii.LicenceAgreement,     
		ii.FumigationCertificate as PhytoSanitaryCertificate,ii.PhytoTemporaryShipment, ii.KILNDriedCertificate, ii.ChinaComInspecNumAndCCIBStickers, ii.OriginalVisa, ii.TextileDeclarationMidCode, ii.QuotaChargeStatement,     
		ii.MSDS, ii.TSCA, ii.DropBallTestCert, ii.ManMedicalDeviceListing, ii.ManFDARegistration, ii.CopyRightIndemnification, ii.FishWildLifeCert,     
		ii.Proposition65LabelReq, ii.CCCR, ii.FormaldehydeCompliant, ii.Is_Valid, ii.Tax_Wizard, ii.RMS_Sellable, ii.RMS_Orderable, ii.RMS_Inventory, ii.Parent_ID,     
		ii.RegularBatchItem, ii.[Sequence], ii.Store_Total, ii.POG_Start_Date, ii.POG_Comp_Date, ii.Like_Item_SKU, ii.Like_Item_Description, ii.Like_Item_Retail,     
		ii.Like_Item_Regular_Unit, ii.Like_Item_Sales, ii.Facings, ii.POG_Min_Qty, ii.Displayer_Cost, ii.Product_Cost, ii.Calculate_Options, ii.Like_Item_Store_Count,     
		ii.Like_Item_Unit_Store_Month, ii.Annual_Reg_Retail_Sales, ii.Annual_Regular_Unit_Forecast, ii.Min_Pres_Per_Facing,   
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>'      else ''    end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>'      else ''    end as MSDS_Sheet, 
		COALESCE(lv.Display_Text, '') as Private_Brand_Label, ii.QuoteReferenceNumber, ii.Customs_Description, --ii.MinimumOrderQuantity,ii.VendorMinOrderAmount as MinimumOrderAmount , ii.ProductIdentifiesAsCosmetic, 
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
		v.PaymentTerms as Payment_Terms, v.Days, v.Vendor_Name, v.Vendor_Address1, v.Vendor_Address2, v.Vendor_Address3, v.Vendor_Address4,
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
		V.FOB_Shipping_Point, V.Duty_Percent, V.Duty_Amount, V.Additional_Duty_Comment, V.Additional_Duty_Amount, V.Supp_Tariff_Percent, V.Supp_Tariff_Amount, V.Ocean_Freight_Amount,  V.Ocean_Freight_Computed_Amount,
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
		s.CoinBattery, s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate as PhytoSanitaryCertificate,s.PhytoTemporaryShipment, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
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
		s.QuoteReferenceNumber as Quote_Reference_Number, s.Customs_Description,--v.MinimumOrderQuantity,v.Vendor_Min_Order_Amount as MinimumOrderAmount , v.ProductIdentifiesAsCosmetic, 
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, 
		simlF.Description_Short as French_Short_Description,   -- simlF.Description_Medium as French_Item_Description, MWM:LCR
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
	    SET Supp_Tariff_Percent = isNull(c.Field_Value, iim.Supp_Tariff_Percent)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'SuppTariffPercent'

	    UPDATE #ImportItemMaint
	    SET Supp_Tariff_Amount = isNull(c.Field_Value, iim.Supp_Tariff_Amount)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'SuppTariffAmount'

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
	    SET CoinBattery = isNull(c.Field_Value, iim.CoinBattery)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'CoinBattery'
	    
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
	    SET PhytoSanitaryCertificate = isNull(c.Field_Value, iim.PhytoSanitaryCertificate)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'FumigationCertificate'

		UPDATE #ImportItemMaint
	    SET PhytoTemporaryShipment = isNull(c.Field_Value, iim.PhytoTemporaryShipment)
	    FROM #ImportItemMaint as iim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		WHERE    c.Field_Name = 'PhytoTemporaryShipment'
		
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
	    
		--MWM:LCR
	 --   UPDATE #ImportItemMaint
	 --   SET French_Item_Description = isNull(c.Field_Value, iim.French_Item_Description)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'FrenchItemDescription'

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

	 --   UPDATE #ImportItemMaint
	 --   SET MinimumOrderQuantity = isNull(c.Field_Value, iim.MinimumOrderQuantity)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'MinimumOrderQuantity'

	 --   UPDATE #ImportItemMaint
	 --   SET MinimumOrderAmount = isNull(c.Field_Value, iim.MinimumOrderAmount)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'VendorMinOrderAmount'

	 --   UPDATE #ImportItemMaint
	 --   SET ProductIdentifiesAsCosmetic = isNull(c.Field_Value, iim.ProductIdentifiesAsCosmetic)
	 --   FROM #ImportItemMaint as iim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = iim.ID
		--WHERE    c.Field_Name = 'ProductIdentifiesAsCosmetic'
	    
	    Select * from #ImportItemMaint
	    
	    Drop Table #ImportItemMaint
END


GO

/****** Object:  StoredProcedure [dbo].[usp_SPD_UpdateNewItemFromIM]    Script Date: 4/2/2024 10:15:45 AM ******/
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
			  ,[PhytoSanitaryCertificate]	= IM.FumigationCertificate
			  ,[PhytoTemporaryShipment]		= IM.PhytoTemporaryShipment
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
			,[CoinBattery]						= IM.CoinBattery
			,[TSSA]								= IM.TSSA
			,[CSA]								= IM.CSA
			,[UL]								= IM.UL
			,[LicenceAgreement]					= IM.LicenceAgreement
			,[FumigationCertificate]			= IM.FumigationCertificate
			,[PhytoTemporaryShipment]			= IM.PhytoTemporaryShipment
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
			--,[MinimumOrderQuantity]	= IM.MinimumOrderQuantity
			--,[ProductIdentifiesAsCosmetic]	= IM.ProductIdentifiesAsCosmetic
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

/****** Object:  StoredProcedure [dbo].[sp_SPD_Item_GetList]    Script Date: 4/9/2024 8:32:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_SPD_Item_GetList] 
  @itemHeaderID bigint = 0,
	@startRow int = 0,
  @pageSize int = 0,
	@xmlSortCriteria text = null,
  @userID bigint = 0,
  @printDebugMsgs bit = 0
	
AS

  /* EXISTING SKU CHECK */
  declare @batchID bigint
  select @batchID = [Batch_ID] from [dbo].[SPD_Item_Headers] where [ID] = @itemHeaderID
  exec usp_SPD_UpdateNewItemFromIM @batchID
  /* END EXISTING SKU CHECK */

  DECLARE @intPageNo int
  DECLARE @intXMLDocHandle int
  DECLARE @strXMLDoc varchar(8000)
  DECLARE @intTempFilterCol int
  DECLARE @strTempFilterCriteria varchar(8000)
  DECLARE @strTempFilterConjunction varchar(3)
  DECLARE @strTempFilterOp varchar(20)
  DECLARE @intTempSortCol int
  DECLARE @intTempSortDir int
  DECLARE @strTempSortDir varchar(4)
  DECLARE @strBlock varchar(8000)
  DECLARE @strFields varchar(8000)
  DECLARE @strPK varchar(100)
  DECLARE @strTables varchar(8000)
  DECLARE @intPageSize int
  DECLARE @blnGetRecordCount bit
  DECLARE @blnUseFT bit 
  DECLARE @strFTColumn varchar(8000)
  DECLARE @strFTFilter varchar(8000)
  DECLARE @strFilter varchar(8000)
  DECLARE @strSort varchar(8000)
  DECLARE @strGroup varchar(8000)

  SET @strXMLDoc = @xmlSortCriteria
  EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc


  SET @blnUseFT = 0
  SET @strFTColumn = ''
  SET @strFTFilter = ''
  SET @strPK = 'i.[ID]'
  SET @intPageNo = @startRow
  SET @intPageSize = @pageSize
  SET @blnGetRecordCount = 1

  SET @strBlock = ''

/*=================================================================================================
  Sniff to see if we need to do a full-text search.
  =================================================================================================*/
  DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
    SELECT FilterCol, FilterCriteria
    FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter')
    WITH
    (
      FilterID int '@FilterID',
      FilterCol int '@ColOrdinal',
      FilterCriteria varchar(1000) 'text()'
    )
    WHERE (FilterCol = -100) 
      AND FilterCriteria IS NOT NULL
      AND LEN(FilterCriteria) > 2
    ORDER BY FilterID
  OPEN myCursor
  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  SET @strFTColumn = 
      (CASE @intTempFilterCol
        WHEN -100 THEN '*'
       END)
  IF (LEN(COALESCE(@strFTColumn, '')) > 0) SET @blnUseFT = 1
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF (LEN(@strFTFilter) > 0) SET @strFTFilter = @strFTFilter + ' '
    SET @strFTFilter = @strFTFilter + REPLACE(REPLACE(@strTempFilterCriteria, '![CDATA[', ''), ']]', '')
    FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  END
  CLOSE myCursor
  DEALLOCATE myCursor

  IF (@strFTFilter IS NOT NULL)
	BEGIN
		SET @strFTFilter = REPLACE(REPLACE(@strFTFilter, ' ', ' OR '), '"', '')
    --SET @strFTFilter = ((ISNULL(@strFTFilter, '') = '') OR (@strFTFilter IS NOT NULL AND (CONTAINS(i.*, @strFTFilter))))
	END

  IF (@printDebugMsgs = 1) PRINT 'ADVANCED FILTER:  ' + @strFTFilter

  /*=================================================================================================
  Set fields to be returned (SELECT statement)
  =================================================================================================*/
  SET @strFields = 'i.*, '
  --IF (@blnUseFT = 1) SET @strFields = @strFields + 'KEY_TBL.RANK As Rank, '
  --IF (@blnUseFT = 0) SET @strFields = @strFields + '0 As Rank, '
  SET @strFields = @strFields + '
    ih.Store_Total,
    (LTRIM(RTRIM((isnull(su1.First_Name, '''') + '' '' + isnull(su1.Last_Name, ''''))))) as Created_User,
    (LTRIM(RTRIM((isnull(su2.First_Name, '''') + '' '' + isnull(su2.Last_Name, ''''))))) as Update_User,
    COALESCE(b.ID, 0) as Batch_ID,
    COALESCE(s.ID, 0) as Stage_ID,
    COALESCE(s.stage_name, '''') as Stage_Name,
    COALESCE(s.Stage_Type_id, 0) as Stage_Type_ID,
    --f1.[File_ID] as Image_File_ID,
    --f2.[File_ID] as MSDS_File_ID
	CASE When Valid_Existing_SKU = 0 Then f1.[File_ID] Else Image_ID End AS Image_File_ID,
	CASE When Valid_Existing_SKU = 0 Then f2.[File_ID] Else MSDS_ID End AS MSDS_File_ID,
	silE.Package_Language_Indicator as PLI_English,
	silF.Package_Language_Indicator as PLI_French,
	silS.Package_Language_Indicator as PLI_Spanish,
	silE.Translation_Indicator as TI_English,
	silF.Translation_Indicator as TI_French,
	COALESCE(silS.Translation_Indicator, ''N'') as TI_Spanish,
	silE.Description_Long as English_Long_Description,
	silE.Description_Short as English_Short_Description,
	silF.Description_Long as French_Long_Description,
	silF.Description_Short as French_Short_Description,
	silS.Description_Long as Spanish_Long_Description,
	silS.Description_Short as Spanish_Short_Description,
	silF.Exempt_End_Date as Exempt_End_Date_French
	    
  '

  IF (@printDebugMsgs = 1) PRINT 'SELECT ' + @strFields

  /*=================================================================================================
  Set tables to be accessed (FROM statement)
  =================================================================================================*/
  SET @strTables = '[dbo].[SPD_Items] i WITH (NOLOCK)
    INNER JOIN [dbo].[SPD_Item_Headers] ih ON i.Item_Header_ID = ih.ID
    INNER JOIN [SPD_Batch] b ON ih.Batch_ID = b.ID
    LEFT OUTER JOIN [SPD_Workflow_Stage] s on b.Workflow_Stage_ID = s.ID
    LEFT OUTER JOIN [Security_User] su1 ON su1.ID = i.Created_User_ID 
    LEFT OUTER JOIN [Security_User] su2 ON su2.ID = i.Update_User_ID
    LEFT OUTER JOIN [SPD_Items_Files] f1 ON f1.Item_Type = ''D'' and f1.Item_ID = i.[ID] and f1.File_Type = ''IMG'' 
    LEFT OUTER JOIN [SPD_Items_Files] f2 ON f2.Item_Type = ''D'' and f2.Item_ID = i.[ID] and f2.File_Type = ''MSDS''
    LEFT OUTER JOIN [SPD_Item_Languages] as silE on silE.Item_ID = i.ID AND  silE.Language_Type_ID = 1
    LEFT OUTER JOIN [SPD_Item_Languages] as silF on silF.Item_ID = i.ID AND  silF.Language_Type_ID = 2
    LEFT OUTER JOIN [SPD_Item_Languages] as silS on silS.Item_ID = i.ID AND  silS.Language_Type_ID = 3
  '
    
--  IF (@blnUseFT = 1) SET @strTables = @strTables + 'INNER JOIN CONTAINSTABLE ([dbo].[SPD_Items], ' + @strFTColumn + ', ''' + @strFTFilter + ''') As KEY_TBL ON grid.[ID] = KEY_TBL.[KEY]
--  '
  IF (@printDebugMsgs = 1) PRINT 'FROM ' + @strTables



  /*=================================================================================================
  Set filter parameters (WHERE clause)
  =================================================================================================*/

  DECLARE @typeNumber varchar(10),
          @typeDate varchar(10),
          @typeString varchar(10)

  SET @typeNumber = 'number'
  SET @typeDate = 'date'
  SET @typeString = 'string'

  IF (COALESCE(@itemHeaderID,0) > 0)
  BEGIN
    SET @strFilter = 'i.Item_Header_ID = ' + CONVERT(varchar(40), @itemHeaderID)
  END

  DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
    SELECT FilterCol, FilterCriteria, COALESCE(FilterConjunction, 'AND'), FilterOperator
    FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter') 
    WITH
    (
      FilterID int '@FilterID',
      FilterCol int '@ColOrdinal',
      FilterCriteria varchar(1000) 'text()',
      FilterConjunction varchar(3) '@Conjunction',
      FilterOperator varchar(20) '@VerbID'
    )
    ORDER BY FilterID

  OPEN myCursor
  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria, @strTempFilterConjunction, @strTempFilterOp
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF(isnull(@strTempFilterConjunction, '') = '') set @strTempFilterConjunction = 'AND'
    IF (LEN(@strFilter) > 0) SET @strFilter = @strFilter + ' ' + @strTempFilterConjunction + ' '
    
    SET @strFilter = '(' + @strFilter + 
    (CASE @intTempFilterCol
      
		WHEN 0 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Vendor_UPC]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 2 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Vendor_Style_Num]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 3 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Additional_UPC_Count]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 4 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Add_Change]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 5 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Pack_Item_Indicator]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 6 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Michaels_SKU]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 7 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Class_Num]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 8 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Sub_Class_Num]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 9 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Item_Desc]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 10 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Private_Brand_Label]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 11 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hybrid_Type]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 12 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hybrid_Source_DC]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 12 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Stocking_Strategy_Code]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 13 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hybrid_Lead_Time]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 14 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hybrid_Conversion_Date]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 15 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Qty_In_Pack]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 16 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Eaches_Master_Case]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 17 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Eaches_Inner_Pack]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 18 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Pre_Priced]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 19 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Pre_Priced_UDA]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 20 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[US_Cost]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 21 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Total_US_Cost]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 22 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Canada_Cost]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 23 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Total_Canada_Cost]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 24 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Base_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 25 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Central_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 26 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Test_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 27 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Alaska_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 28 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Canada_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 29 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Zero_Nine_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 30 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[California_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 31 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Village_Craft_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 32 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Retail9]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 33 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Retail10]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 34 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Retail11]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 35 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Retail12]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 36 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Retail13]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 37 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[RDQuebec]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 38 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[RDPuertoRico]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 39 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Each_Case_Height]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 40 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Each_Case_Width]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 41 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Each_Case_Length]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 42 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Each_Case_Weight]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 43 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Each_Case_Pack_Cube]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 44 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Inner_Case_Height]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 45 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Inner_Case_Width]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 46 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Inner_Case_Length]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 47 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Inner_Case_Weight]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 48 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Inner_Case_Pack_Cube]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 49 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Master_Case_Height]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Master_Case_Width]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Master_Case_Length]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Master_Case_Weight]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Master_Case_Pack_Cube]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Country_Of_Origin_Name]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Tax_Wizard]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Tax_UDA]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Tax_Value_UDA]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Flammable]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Container_Type]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Container_Size]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_MSDS_UOM]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Manufacturer_Name]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Manufacturer_City]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Manufacturer_State]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Manufacturer_Phone]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous_Manufacturer_Country]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Like_Item_SKU]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Like_Item_Description]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Like_Item_Retail]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Annual_Regular_Unit_Forecast]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Like_Item_Unit_Store_Month]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Like_Item_Store_Count]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Like_Item_Regular_Unit]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Annual_Reg_Retail_Sales]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Facings]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[POG_Min_Qty]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[POG_Max_Qty]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[POG_Setup_Per_Store]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIEnglish]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ExemptEndDateFrench]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIEnglish]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Customs_Description]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchShortDescription]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchLongDescription]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishShortDescription]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishLongDescription]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Harmonized_Code_Number]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Canada_Harmonized_Code_Number]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Detail_Invoice_Customs_Desc]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Component_Material_Breakdown]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PhytoSanitaryCertificate]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PhytoTemporaryShipment]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 104 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Image_ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 105 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS_ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
	  
      -- 500 series is reserved for FT Searching (See Above)
      --WHEN 500 THEN 'KEY_TBL.RANK = ''' + @strTempFilterCriteria + ''''
      
      ELSE '1 = 1'
    END)
    SET @strFilter = @strFilter + ')'
    FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria, @strTempFilterConjunction, @strTempFilterOp
  END
  CLOSE myCursor
  DEALLOCATE myCursor

  IF (ISNULL(@strFTFilter, '') != '')
  BEGIN
    SET @strBlock = '
      declare @strFTFilter varchar(8000)
      set @strFTFilter = ''' + REPLACE(@strFTFilter, '''', '''''') + '''
      '
    IF (LEN(@strFilter) > 0) SET @strFilter = @strFilter + ' and '
    SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (CONTAINS(i.*, @strFTFilter)))) ' 
  END

  IF (@printDebugMsgs = 1) PRINT 'WHERE ' + @strFilter


  /*=================================================================================================
  Set sort parameters (ORDER BY clause)
  =================================================================================================*/
  SET @strSort = ''
  DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
    SELECT SortCol, SortDir
    FROM OPENXML (@intXMLDocHandle, '/Root/Sort/Parameter') 
    WITH
    (
      SortID int '@SortID',
      SortCol int '@intColOrdinal',
      SortDir int '@intDirection'
    )
    ORDER BY SortID

  OPEN myCursor
  FETCH NEXT FROM myCursor INTO @intTempSortCol, @intTempSortDir
  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @strTempSortDir = 'ASC'
    IF (@intTempSortDir = 1) SET @strTempSortDir = 'DESC'
    IF (LEN(@strSort) > 0) SET @strSort = RTRIM(@strSort) + ', '
    SET @strSort = @strSort + 
    (CASE @intTempSortCol

		WHEN 0 THEN 'i.[ID] ' + @strTempSortDir
		WHEN 1 THEN 'i.[Vendor_UPC] ' + @strTempSortDir
		WHEN 2 THEN 'i.[Vendor_Style_Num] ' + @strTempSortDir
		--WHEN 3 THEN 'i.[Additional_UPC_Count] ' + @strTempSortDir
		WHEN 4 THEN 'i.[Add_Change] ' + @strTempSortDir
		WHEN 5 THEN 'i.[Pack_Item_Indicator] ' + @strTempSortDir
		WHEN 6 THEN 'i.[Michaels_SKU] ' + @strTempSortDir
		WHEN 7 THEN 'i.[Class_Num] ' + @strTempSortDir
		WHEN 8 THEN 'i.[Sub_Class_Num] ' + @strTempSortDir
		WHEN 9 THEN 'i.[Item_Desc] ' + @strTempSortDir
		WHEN 10 THEN 'i.[Private_Brand_Label] ' + @strTempSortDir
		--WHEN 11 THEN 'i.[Hybrid_Type] ' + @strTempSortDir
		--WHEN 12 THEN 'i.[Hybrid_Source_DC] ' + @strTempSortDir
		WHEN 12 THEN 'i.[Stocking_Strategy_Code] ' + @strTempSortDir
		--WHEN 13 THEN 'i.[Hybrid_Lead_Time] ' + @strTempSortDir
		--WHEN 14 THEN 'i.[Hybrid_Conversion_Date] ' + @strTempSortDir
		WHEN 15 THEN 'i.[Qty_In_Pack] ' + @strTempSortDir
		WHEN 16 THEN 'i.[Eaches_Master_Case] ' + @strTempSortDir
		WHEN 17 THEN 'i.[Eaches_Inner_Pack] ' + @strTempSortDir
		WHEN 18 THEN 'i.[Pre_Priced] ' + @strTempSortDir
		WHEN 19 THEN 'i.[Pre_Priced_UDA] ' + @strTempSortDir
		WHEN 20 THEN 'i.[US_Cost] ' + @strTempSortDir
		WHEN 21 THEN 'i.[Total_US_Cost] ' + @strTempSortDir
		WHEN 22 THEN 'i.[Canada_Cost] ' + @strTempSortDir
		WHEN 23 THEN 'i.[Total_Canada_Cost] ' + @strTempSortDir
		WHEN 24 THEN 'i.[Base_Retail] ' + @strTempSortDir
		WHEN 25 THEN 'i.[Central_Retail] ' + @strTempSortDir
		WHEN 26 THEN 'i.[Test_Retail] ' + @strTempSortDir
		WHEN 27 THEN 'i.[Alaska_Retail] ' + @strTempSortDir
		WHEN 28 THEN 'i.[Canada_Retail] ' + @strTempSortDir
		WHEN 29 THEN 'i.[Zero_Nine_Retail] ' + @strTempSortDir
		WHEN 30 THEN 'i.[California_Retail] ' + @strTempSortDir
		WHEN 31 THEN 'i.[Village_Craft_Retail] ' + @strTempSortDir
		WHEN 32 THEN 'i.[Retail9] ' + @strTempSortDir
		WHEN 33 THEN 'i.[Retail10] ' + @strTempSortDir
		WHEN 34 THEN 'i.[Retail11] ' + @strTempSortDir
		WHEN 35 THEN 'i.[Retail12] ' + @strTempSortDir
		WHEN 36 THEN 'i.[Retail13] ' + @strTempSortDir
		WHEN 37 THEN 'i.[RDQuebec] ' + @strTempSortDir
		WHEN 38 THEN 'i.[RDPuertoRico] ' + @strTempSortDir
		WHEN 39 THEN 'i.[Each_Case_Height] ' + @strTempSortDir
		WHEN 40 THEN 'i.[Each_Case_Width] ' + @strTempSortDir
		WHEN 41 THEN 'i.[Each_Case_Length] ' + @strTempSortDir
		WHEN 42 THEN 'i.[Each_Case_Weight] ' + @strTempSortDir
		WHEN 43 THEN 'i.[Each_Case_Pack_Cube] ' + @strTempSortDir
		WHEN 44 THEN 'i.[Inner_Case_Height] ' + @strTempSortDir
		WHEN 45 THEN 'i.[Inner_Case_Width] ' + @strTempSortDir
		WHEN 46 THEN 'i.[Inner_Case_Length] ' + @strTempSortDir
		WHEN 47 THEN 'i.[Inner_Case_Weight] ' + @strTempSortDir
		WHEN 48 THEN 'i.[Inner_Case_Pack_Cube] ' + @strTempSortDir
		WHEN 49 THEN 'i.[Master_Case_Height] ' + @strTempSortDir
		WHEN 50 THEN 'i.[Master_Case_Width] ' + @strTempSortDir
		WHEN 51 THEN 'i.[Master_Case_Length] ' + @strTempSortDir
		WHEN 52 THEN 'i.[Master_Case_Weight] ' + @strTempSortDir
		WHEN 53 THEN 'i.[Master_Case_Pack_Cube] ' + @strTempSortDir
		WHEN 54 THEN 'i.[Country_Of_Origin_Name] ' + @strTempSortDir
		WHEN 55 THEN 'i.[Tax_Wizard] ' + @strTempSortDir
		WHEN 56 THEN 'i.[Tax_UDA] ' + @strTempSortDir
		WHEN 57 THEN 'i.[Tax_Value_UDA] ' + @strTempSortDir
		WHEN 58 THEN 'i.[Hazardous] ' + @strTempSortDir
		WHEN 59 THEN 'i.[Hazardous_Flammable] ' + @strTempSortDir
		WHEN 60 THEN 'i.[Hazardous_Container_Type] ' + @strTempSortDir
		WHEN 61 THEN 'i.[Hazardous_Container_Size] ' + @strTempSortDir
		WHEN 62 THEN 'i.[Hazardous_MSDS_UOM] ' + @strTempSortDir
		WHEN 63 THEN 'i.[Hazardous_Manufacturer_Name] ' + @strTempSortDir
		WHEN 64 THEN 'i.[Hazardous_Manufacturer_City] ' + @strTempSortDir
		WHEN 65 THEN 'i.[Hazardous_Manufacturer_State] ' + @strTempSortDir
		WHEN 66 THEN 'i.[Hazardous_Manufacturer_Phone] ' + @strTempSortDir
		WHEN 67 THEN 'i.[Hazardous_Manufacturer_Country] ' + @strTempSortDir
		WHEN 70 THEN 'i.[Like_Item_SKU] ' + @strTempSortDir
		WHEN 71 THEN 'i.[Like_Item_Description] ' + @strTempSortDir
		WHEN 72 THEN 'i.[Like_Item_Retail] ' + @strTempSortDir
		WHEN 73 THEN 'i.[Annual_Regular_Unit_Forecast] ' + @strTempSortDir
		WHEN 74 THEN 'i.[Like_Item_Unit_Store_Month] ' + @strTempSortDir
		WHEN 75 THEN 'i.[Like_Item_Store_Count] ' + @strTempSortDir
		WHEN 76 THEN 'i.[Like_Item_Regular_Unit] ' + @strTempSortDir
		WHEN 77 THEN 'i.[Annual_Reg_Retail_Sales] ' + @strTempSortDir
		WHEN 78 THEN 'i.[Facings] ' + @strTempSortDir
		WHEN 79 THEN 'i.[POG_Min_Qty] ' + @strTempSortDir
		WHEN 80 THEN 'i.[POG_Max_Qty] ' + @strTempSortDir
		WHEN 81 THEN 'i.[POG_Setup_Per_Store] ' + @strTempSortDir
		WHEN 82 THEN 'i.[QuoteReferenceNumber] ' + @strTempSortDir
		WHEN 83 THEN 'i.[PLIEnglish] ' + @strTempSortDir
		WHEN 84 THEN 'i.[PLIFrench] ' + @strTempSortDir
		WHEN 85 THEN 'i.[PLISpanish] ' + @strTempSortDir
		WHEN 86 THEN 'i.[ExemptEndDateFrench] ' + @strTempSortDir
		WHEN 87 THEN 'i.[TIEnglish] ' + @strTempSortDir
		WHEN 88 THEN 'i.[TIFrench] ' + @strTempSortDir
		WHEN 89 THEN 'i.[TISpanish] ' + @strTempSortDir
		WHEN 90 THEN 'i.[Customs_Description] ' + @strTempSortDir
		WHEN 91 THEN 'i.[EnglishShortDescription] ' + @strTempSortDir
		WHEN 92 THEN 'i.[EnglishLongDescription] ' + @strTempSortDir
		WHEN 93 THEN 'i.[FrenchShortDescription] ' + @strTempSortDir
		WHEN 94 THEN 'i.[FrenchLongDescription] ' + @strTempSortDir
		WHEN 95 THEN 'i.[SpanishShortDescription] ' + @strTempSortDir
		WHEN 96 THEN 'i.[SpanishLongDescription] ' + @strTempSortDir
		WHEN 97 THEN 'i.[Harmonized_Code_Number] ' + @strTempSortDir
		WHEN 98 THEN 'i.[Canada_Harmonized_Code_Number] ' + @strTempSortDir
		WHEN 100 THEN 'i.[Detail_Invoice_Customs_Desc] ' + @strTempSortDir
		WHEN 101 THEN 'i.[Component_Material_Breakdown] ' + @strTempSortDir
		WHEN 102 THEN 'i.[PhytoSanitaryCertificate] ' + @strTempSortDir
		WHEN 103 THEN 'i.[PhytoTemporaryShipment] ' + @strTempSortDir
		WHEN 104 THEN 'i.[Image_ID] ' + @strTempSortDir
		WHEN 105 THEN 'i.[MSDS_ID] ' + @strTempSortDir
		WHEN 500 THEN 'RowNumber ' + @strTempSortDir
		ELSE ''

    END)
    FETCH NEXT FROM myCursor INTO @intTempSortCol, @intTempSortDir
  END
  CLOSE myCursor
  DEALLOCATE myCursor
  
  SET @strSort = REPLACE(@strSort, ',,', '')

  IF(@strSort = '')
  BEGIN
    SET @strSort = 'i.[ID]'
  END

  IF (@printDebugMsgs = 1) PRINT 'ORDER BY ' + @strSort

/*=================================================================================================
  Run it!
  =================================================================================================*/

  --SET @strBlock = ''

  EXEC sys_returnPagedData_usingWith
    @strBlock, 
    @strFields, 
    @strPK, 
    @strTables, 
    @intPageNo, 
    @intPageSize, 
    @blnGetRecordCount, 
    @strFilter, 
    @strSort, 
    @strGroup,
    @printDebugMsgs


  IF (@printDebugMsgs = 1) PRINT '  EXEC sys_returnPagedData_usingWith
    ''' + @strBlock + ''', 
    ''' + @strFields + ''', 
    ''' + @strPK + ''', 
    ''' + REPLACE(@strTables, '''', '''''') + ''', 
    ' + CONVERT(varchar(10), @intPageNo) + ', 
    ' + CONVERT(varchar(10), @intPageSize) + ', 
    ' + CONVERT(varchar(1), @blnGetRecordCount) + ', 
    ''' + @strFilter + ''', 
    ''' + @strSort + ''', 
    ''' + @strGroup + ''', 
    ' + CONVERT(varchar(1), @printDebugMsgs)
  
  EXEC sp_xml_removedocument @intXMLDocHandle    


GO

/****** Object:  StoredProcedure [dbo].[sp_SPD_Item_SaveRecord]    Script Date: 4/9/2024 9:07:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_SPD_Item_SaveRecord] 
	@ID bigint OUTPUT,
	@Item_Header_ID bigint,
	@Add_Change varchar(10),
	@Pack_Item_Indicator varchar(20),
	@Michaels_SKU varchar(10),
	@Vendor_UPC varchar(20),
	@Class_Num int,
	@Sub_Class_Num int,
	@Vendor_Style_Num varchar(50),
	@Item_Desc varchar(30),
	@Hybrid_Type varchar(1),
	@Hybrid_Source_DC varchar(1),
	@Hybrid_Lead_Time int,
	@Hybrid_Conversion_Date datetime,
	@Eaches_Master_Case int,
	@Eaches_Inner_Pack int,
	@Pre_Priced varchar(1),
	@Pre_Priced_UDA varchar(1),
	@US_Cost money,
	@Canada_Cost money,
	@Base_Retail money,
	@Central_Retail money,
	@Test_Retail money,
	@Alaska_Retail money,
	@Canada_Retail money,
	@Zero_Nine_Retail money,
	@California_Retail money,
	@Village_Craft_Retail money,
	@Retail9 money,
	@Retail10 money,
	@Retail11 money,
	@Retail12 money,
	@Retail13 money,
	@RDQuebec money = null,
	@RDPuertoRico money = null,
	@POG_Setup_Per_Store decimal(18, 3),
	@POG_Max_Qty decimal(18, 3),
	@Inner_Case_Height decimal(18, 6),
	@Inner_Case_Width decimal(18, 6),
	@Inner_Case_Length decimal(18, 6),
	@Inner_Case_Weight decimal(18, 6),
	@Inner_Case_Pack_Cube decimal(18, 6),
	@Master_Case_Height decimal(18, 6),
	@Master_Case_Width decimal(18, 6),
	@Master_Case_Length decimal(18, 6),
	@Master_Case_Weight decimal(18, 6),
	@Master_Case_Pack_Cube decimal(18, 6),
	@Country_Of_Origin varchar(50),
	@Country_Of_Origin_Name varchar(50),
	@Tax_UDA varchar(2),
	@Tax_Value_UDA int,
	@Hazardous varchar(1),
	@Hazardous_Flammable varchar(1),
	@Hazardous_Container_Type varchar(20),
	@Hazardous_Container_Size decimal(18, 6),
	@Hazardous_MSDS_UOM varchar(20),
	@Hazardous_Manufacturer_Name varchar(100),
	@Hazardous_Manufacturer_City varchar(50),
	@Hazardous_Manufacturer_State varchar(50),
	@Hazardous_Manufacturer_Phone varchar(20),
	@Hazardous_Manufacturer_Country varchar(100),
	@Is_Valid smallint = null,
	@User_ID int,
	@Like_Item_SKU varchar(20) = null,
	@Like_Item_Description varchar(255) = null,
	@Like_Item_Retail money = null,
	@Like_Item_Regular_Units decimal(18,6) = null,
	@Like_Item_Store_Count decimal(18,6) = null,
	@Annual_Regular_Unit_Forecast decimal(18,6) = null,
	@Annual_Reg_Retail_Sales decimal(18,6) = null,
	@Like_Item_Unit_Store_Month decimal(18,6) = null,
	@Facings decimal(18,3) = null,
	@POG_Min_Qty decimal(18,3) = null,
	@Private_Brand_Label varchar(20) = null,
	@Qty_In_Pack int = null,
	@Total_US_Cost money = null,
	@Total_Canada_Cost money = null,
	@Valid_Existing_SKU bit = null,
	@Item_Status varchar(10) = null,
	@Stock_Category varchar(5) = null,
	@Item_Type_Attribute varchar(5) = null,
	@Department_Num int = null,
	@QuoteReferenceNumber varchar(20) = null, 
	@CustomsDescription as varchar(255) = null,	
	@HarmonizedCodeNumber as varchar(10) = null,
	@CanadaHarmonizedCodeNumber as varchar(10) = null,
	@DetailInvoiceCustomsDesc as varchar(35) = null,
	@ComponentMaterialBreakdown as varchar(35) = null,
	@IsDirty bit = 1,
	@StockingStrategyCode as nvarchar(5) = null,
	@Each_Case_Height decimal(18, 6),
	@Each_Case_Width decimal(18, 6),
	@Each_Case_Length decimal(18, 6),
	@Each_Case_Weight decimal(18, 6),
	@Each_Case_Pack_Cube decimal(18, 6),
	--PMO200141 GTIN14 Enhancements changes
	@Vendor_Inner_GTIN varchar(20) = null,
	@Vendor_Case_GTIN varchar(20) = null,
	@PhytoSanitaryCertificate varchar(1) = null,
	@PhytoTemporaryShipment varchar(1) = null
	
AS
	SET NOCOUNT ON
	
	declare @batchID bigint

	IF EXISTS(SELECT 1 FROM [dbo].[SPD_Items] where [ID] = @ID)
	BEGIN
		-- update record
		UPDATE [dbo].[SPD_Items] SET 
			Item_Header_ID = @Item_Header_ID,
			Add_Change = @Add_Change,
			Pack_Item_Indicator = @Pack_Item_Indicator,
			Michaels_SKU = @Michaels_SKU,
			Vendor_UPC = @Vendor_UPC,
			Class_Num = @Class_Num,
			Sub_Class_Num = @Sub_Class_Num,
			Vendor_Style_Num = @Vendor_Style_Num,
			Item_Desc = @Item_Desc,
			Hybrid_Type = @Hybrid_Type,
			Hybrid_Source_DC = @Hybrid_Source_DC,
			Hybrid_Lead_Time = @Hybrid_Lead_Time,
			Hybrid_Conversion_Date = @Hybrid_Conversion_Date,
			Eaches_Master_Case = @Eaches_Master_Case,
			Eaches_Inner_Pack = @Eaches_Inner_Pack,
			Pre_Priced = @Pre_Priced,
			Pre_Priced_UDA = @Pre_Priced_UDA,
			US_Cost = @US_Cost,
			Canada_Cost = @Canada_Cost,
			Base_Retail = @Base_Retail,
			Central_Retail = @Central_Retail,
			Test_Retail = @Test_Retail,
			Alaska_Retail = @Alaska_Retail,
			Canada_Retail = @Canada_Retail,
			Zero_Nine_Retail = @Zero_Nine_Retail,
			California_Retail = @California_Retail,
			Village_Craft_Retail = @Village_Craft_Retail,
			Retail9 = @Retail9,
			Retail10 = @Retail10,
			Retail11 = @Retail11,
			Retail12 = @Retail12,
			Retail13 = @Retail13,
			RDQuebec = @RDQuebec,
			RDPuertoRico = @RDPuertoRico,
			POG_Setup_Per_Store = @POG_Setup_Per_Store,
			POG_Max_Qty = @POG_Max_Qty,
			Inner_Case_Height = @Inner_Case_Height,
			Inner_Case_Width = @Inner_Case_Width,
			Inner_Case_Length = @Inner_Case_Length,
			Inner_Case_Weight = @Inner_Case_Weight,
			Inner_Case_Pack_Cube = @Inner_Case_Pack_Cube,
			Master_Case_Height = @Master_Case_Height,
			Master_Case_Width = @Master_Case_Width,
			Master_Case_Length = @Master_Case_Length,
			Master_Case_Weight = @Master_Case_Weight,
			Master_Case_Pack_Cube = @Master_Case_Pack_Cube,
			Country_Of_Origin = @Country_Of_Origin,
			Country_Of_Origin_Name = @Country_Of_Origin_Name,
			Tax_UDA = @Tax_UDA,
			Tax_Value_UDA = @Tax_Value_UDA,
			Hazardous = @Hazardous,
			Hazardous_Flammable = @Hazardous_Flammable,
			Hazardous_Container_Type = @Hazardous_Container_Type,
			Hazardous_Container_Size = @Hazardous_Container_Size,
			Hazardous_MSDS_UOM = @Hazardous_MSDS_UOM,
			Hazardous_Manufacturer_Name = @Hazardous_Manufacturer_Name,
			Hazardous_Manufacturer_City = @Hazardous_Manufacturer_City,
			Hazardous_Manufacturer_State = @Hazardous_Manufacturer_State,
			Hazardous_Manufacturer_Phone = @Hazardous_Manufacturer_Phone,
			Hazardous_Manufacturer_Country = @Hazardous_Manufacturer_Country,
			Update_User_ID = @User_ID,
			Like_Item_SKU = @Like_Item_SKU,
			Like_Item_Description = @Like_Item_Description,
			Like_Item_Retail = @Like_Item_Retail,
			Like_Item_Regular_Unit = @Like_Item_Regular_Units,
			Like_Item_Store_Count = @Like_Item_Store_Count,
			Annual_Regular_Unit_Forecast = @Annual_Regular_Unit_Forecast,
			Annual_Reg_Retail_Sales = @Annual_Reg_Retail_Sales, 
			Like_Item_Unit_Store_Month = @Like_Item_Unit_Store_Month,		
			Facings = @Facings,
			POG_Min_Qty = @POG_Min_Qty,
			Private_Brand_Label = @Private_Brand_Label,
			Qty_In_Pack = @Qty_In_Pack,
			Total_US_Cost = @Total_US_Cost,
			Total_Canada_Cost = @Total_Canada_Cost,
			Valid_Existing_SKU = @Valid_Existing_SKU,
			Item_Status = @Item_Status,
			Stock_Category = @Stock_Category,
			Item_Type_Attribute = @Item_Type_Attribute,
			Department_Num = @Department_Num, 
			QuoteReferenceNumber = @QuoteReferenceNumber,
			Customs_Description = @CustomsDescription,
			Harmonized_Code_Number = @HarmonizedCodeNumber,
			Canada_Harmonized_Code_Number = @CanadaHarmonizedCodeNumber,
			Detail_Invoice_Customs_Desc = @DetailInvoiceCustomsDesc,
			Component_Material_Breakdown = @ComponentMaterialBreakdown,
			Stocking_Strategy_Code = @StockingStrategyCode,
			Each_Case_Height = @Each_Case_Height,
			Each_Case_Width = @Each_Case_Width,
			Each_Case_Length = @Each_Case_Length,
			Each_Case_Weight = @Each_Case_Weight,
			Each_Case_Pack_Cube = @Each_Case_Pack_Cube,
			--PMO200141 GTIN14 Enhancements changes
			Vendor_Inner_GTIN = @Vendor_Inner_GTIN,
			Vendor_Case_GTIN = @Vendor_Case_GTIN,
			PhytoSanitaryCertificate = @PhytoSanitaryCertificate,
			PhytoTemporaryShipment = @PhytoTemporaryShipment
		WHERE 
			[ID] = @ID
	END
	ELSE
	BEGIN
		-- insert recored
		DECLARE @dateNow datetime
    SET @dateNow = getdate()
		INSERT INTO [dbo].[SPD_Items] (
			Item_Header_ID ,
			Add_Change ,
			Pack_Item_Indicator ,
			Michaels_SKU ,
			Vendor_UPC ,
			Class_Num ,
			Sub_Class_Num ,
			Vendor_Style_Num ,
			Item_Desc ,
			Hybrid_Type ,
			Hybrid_Source_DC ,
			Hybrid_Lead_Time ,
			Hybrid_Conversion_Date ,
			Eaches_Master_Case ,
			Eaches_Inner_Pack ,
			Pre_Priced ,
			Pre_Priced_UDA ,
			US_Cost ,
			Canada_Cost ,
			Base_Retail ,
			Central_Retail ,
			Test_Retail ,
			Alaska_Retail ,
			Canada_Retail ,
			Zero_Nine_Retail ,
			California_Retail ,
			Village_Craft_Retail ,
			POG_Setup_Per_Store ,
			POG_Max_Qty ,
			Inner_Case_Height ,
			Inner_Case_Width ,
			Inner_Case_Length ,
			Inner_Case_Weight ,
			Inner_Case_Pack_Cube ,
			Master_Case_Height ,
			Master_Case_Width ,
			Master_Case_Length ,
			Master_Case_Weight ,
			Master_Case_Pack_Cube ,
			Country_Of_Origin ,
			Country_Of_Origin_Name ,
			Tax_UDA ,
			Tax_Value_UDA ,
			Hazardous ,
			Hazardous_Flammable ,
			Hazardous_Container_Type ,
			Hazardous_Container_Size ,
			Hazardous_MSDS_UOM ,
			Hazardous_Manufacturer_Name ,
			Hazardous_Manufacturer_City ,
			Hazardous_Manufacturer_State ,
			Hazardous_Manufacturer_Phone ,
			Hazardous_Manufacturer_Country ,
			Date_Created,
			Created_User_ID,
			Date_Last_Modified,
			Update_User_ID,
			Like_Item_SKU,
			Like_Item_Description,
			Like_Item_Retail,
			Like_Item_Regular_Unit,
			Like_Item_Store_Count,
			Annual_Regular_Unit_Forecast,
			Annual_Reg_Retail_Sales,
			Like_Item_Unit_Store_Month,
			Facings,
			POG_Min_Qty,
			Retail9,
			Retail10,
			Retail11,
			Retail12,
			Retail13,
			RDQuebec,
			RDPuertoRico,
			Private_Brand_Label,
			Qty_In_Pack,
			Total_US_Cost,
			Total_Canada_Cost,
			Valid_Existing_SKU,
			Item_Status,
			Stock_Category,
			Item_Type_Attribute,
			Department_Num, 
			QuoteReferenceNumber,
			Customs_Description,
			Harmonized_Code_Number,
			Canada_Harmonized_Code_Number,
			Detail_Invoice_Customs_Desc,
			Component_Material_Breakdown,
			Stocking_Strategy_Code,
			Each_Case_Height ,
			Each_Case_Width ,
			Each_Case_Length ,
			Each_Case_Weight ,
			Each_Case_Pack_Cube,
			--PMO200141 GTIN14 Enhancements changes
			Vendor_Inner_GTIN,
			Vendor_case_GTIN,
			PhytoSanitaryCertificate,
			PhytoTemporaryShipment
		) VALUES (
			@Item_Header_ID ,
			@Add_Change ,
			@Pack_Item_Indicator ,
			@Michaels_SKU ,
			@Vendor_UPC ,
			@Class_Num ,
			@Sub_Class_Num ,
			@Vendor_Style_Num ,
			@Item_Desc ,
			@Hybrid_Type ,
			@Hybrid_Source_DC ,
			@Hybrid_Lead_Time ,
			@Hybrid_Conversion_Date ,
			@Eaches_Master_Case ,
			@Eaches_Inner_Pack ,
			@Pre_Priced ,
			@Pre_Priced_UDA ,
			@US_Cost ,
			@Canada_Cost ,
			@Base_Retail ,
			@Central_Retail ,
			@Test_Retail ,
			@Alaska_Retail ,
			@Canada_Retail ,
			@Zero_Nine_Retail ,
			@California_Retail ,
			@Village_Craft_Retail ,
			@POG_Setup_Per_Store ,
			@POG_Max_Qty ,
			@Inner_Case_Height ,
			@Inner_Case_Width ,
			@Inner_Case_Length ,
			@Inner_Case_Weight ,
			@Inner_Case_Pack_Cube ,
			@Master_Case_Height ,
			@Master_Case_Width ,
			@Master_Case_Length ,
			@Master_Case_Weight ,
			@Master_Case_Pack_Cube ,
			@Country_Of_Origin ,
			@Country_Of_Origin_Name ,
			@Tax_UDA ,
			@Tax_Value_UDA ,
			@Hazardous ,
			@Hazardous_Flammable ,
			@Hazardous_Container_Type ,
			@Hazardous_Container_Size ,
			@Hazardous_MSDS_UOM ,
			@Hazardous_Manufacturer_Name ,
			@Hazardous_Manufacturer_City ,
			@Hazardous_Manufacturer_State ,
			@Hazardous_Manufacturer_Phone ,
			@Hazardous_Manufacturer_Country ,
			@dateNow,
			@User_ID,
			@dateNow,
			@User_ID,
			@Like_Item_SKU,
			@Like_Item_Description,
			@Like_Item_Retail,
			@Like_Item_Regular_Units,
			@Like_Item_Store_Count,
			@Annual_Regular_Unit_Forecast,
			@Annual_Reg_Retail_Sales,	
			@Like_Item_Unit_Store_Month,	
			@Facings,
			@POG_Min_Qty,
			@Retail9,
			@Retail10,
			@Retail11,
			@Retail12,
			@Retail13,
			@RDQuebec,
			@RDPuertoRico,
			@Private_Brand_Label,
			@Qty_In_Pack,
			@Total_US_Cost,
			@Total_Canada_Cost,
			@Valid_Existing_SKU,
			@Item_Status,
			@Stock_Category,
			@Item_Type_Attribute,
			@Department_Num, 
			@QuoteReferenceNumber,
			@CustomsDescription,
			@HarmonizedCodeNumber,
			@CanadaHarmonizedCodeNumber,
			@DetailInvoiceCustomsDesc,
			@ComponentMaterialBreakdown,
			@StockingStrategyCode,
			@Each_Case_Height ,
			@Each_Case_Width ,
			@Each_Case_Length ,
			@Each_Case_Weight ,
			@Each_Case_Pack_Cube,
			@Vendor_Inner_GTIN,
			@Vendor_Case_GTIN,
			@PhytoSanitaryCertificate,
			@PhytoTemporaryShipment
		)
		SET @ID = SCOPE_IDENTITY()
	END

	IF (@IsDirty = 1)
	BEGIN
		exec [sp_SPD_Item_SetModified] @ID, 'D', @User_ID
	END
  


--*************************************************
--sp_SPD_MQComm_ProcessIncomingMQMessages 
--*************************************************

/****** Object:  StoredProcedure [dbo].[sp_SPD_MQComm_ProcessIncomingMQMessages]    Script Date: 12/18/2017 13:58:48 ******/
SET ANSI_NULLS ON


GO

/****** Object:  StoredProcedure [dbo].[SPD_Report_CompletedDomesticItem]    Script Date: 4/9/2024 10:01:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SPD_Report_CompletedDomesticItem] 
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

	SELECT  ih.ID, ih.Batch_ID, ih.Log_ID, ih.Submitted_By, ih.Date_Submitted, ih.Supply_Chain_Analyst, ih.Mgr_Supply_Chain, ih.Dir_SCVR, 
		ih.Rebuy_YN, ih.Replenish_YN, ih.Store_Order_YN, ih.Date_In_Retek, ih.Enter_Retek, ih.US_Vendor_Num, ih.Canadian_Vendor_num, 
		i.Harmonized_Code_Number, i.Canada_Harmonized_Code_Number,
		i.Detail_Invoice_Customs_Desc, i.Component_Material_Breakdown, 
		ih.US_Vendor_Name, ih.Canadian_Vendor_Name, ih.Department_Num, ih.Buyer_Approval, ih.Stock_Category, ih.Canada_Stock_Category, 
		ih.Item_Type, ih.Item_type_Attribute, ih.Allow_Store_Order, ih.Perpetual_Inventory, ih.Inventory_Control, ih.Freight_Terms, 
		ih.Auto_Replenish, ih.SKU_Group, ih.Store_Supplier_Zone_Group, ih.WHS_Supplier_Zone_Group, ih.Comments, ih.Worksheet_Desc, 
		ih.Batch_File_ID, ih.Date_Created,
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ih.Created_User_ID) as CreatedUser, 
		ih.Date_Last_Modified, 
		'System' as UpdateUser,
		ih.RMS_Sellable, ih.RMS_Orderable, 
		ih.RMS_Inventory, ih.Store_Total, ih.POG_Start_Date, ih.POG_Comp_Date, ih.Calculate_Options, ih.Discountable, ih.Add_Unit_Cost, 
		i.ID , i.Item_Header_ID , i.Add_Change , i.Pack_Item_Indicator, i.Michaels_SKU as SKU, i.Vendor_UPC, i.Class_Num, i.Sub_Class_Num, 
		i.Vendor_Style_Num, i.Item_Desc, i.Stocking_Strategy_Code,
		--i.Hybrid_Source_DC, i.Hybrid_Type, 
		--i.Hybrid_Lead_Time, i.Hybrid_Conversion_Date, 
		i.Eaches_Master_Case, i.Eaches_Inner_Pack, i.Pre_Priced, i.Pre_Priced_UDA, i.US_Cost, i.Canada_Cost, 
		i.Base_Retail as Base1_Retail, i.Central_Retail as Base2_Retail, i.Test_Retail, i.Alaska_Retail, i.Canada_Retail,    
		i.Zero_Nine_Retail as High2_Retail, i.California_Retail as High3_Retail, i.Village_Craft_Retail as Small_Market_Retail, 
		i.Retail9 as High1_Retail, i.Retail10 as Base3_Retail, i.Retail11 as Low1_Retail, i.Retail12 as Low2_Retail, 
		i.Retail13 as Manhattan_Retail, i.RDQuebec as Q5_Retail, i.RDPuertoRico as PR_Retail, 
		i.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store, i.POG_Max_Qty, 
		i.Each_Case_Height, i.Each_Case_Width,     
		i.Each_Case_Length, i.Each_Case_Weight, i.Each_Case_Pack_Cube,
		i.Inner_Case_Height, i.Inner_Case_Width,     
		i.Inner_Case_Length, i.Inner_Case_Weight, i.Inner_Case_Pack_Cube, i.Master_Case_Height, i.Master_Case_Width, i.Master_Case_Length, 
		i.Master_Case_Weight, i.Master_Case_Pack_Cube, i.Country_Of_Origin, i.Country_Of_Origin_Name, i.Tax_UDA, i.Tax_Value_UDA, 
		i.Hazardous, i.Hazardous_Flammable, i.Hazardous_Container_Type, i.Hazardous_Container_Size, i.Hazardous_MSDS_UOM,
		i.Hazardous_Manufacturer_Name,i.Hazardous_Manufacturer_City,i.Hazardous_Manufacturer_State, i.Hazardous_Manufacturer_Phone, 
		i.Hazardous_Manufacturer_Country, i.MSDS_ID, i.Image_ID, i.Tax_Wizard, i.Is_Valid, i.Like_Item_SKU, i.Like_Item_Description, i.Like_Item_Retail, i.Like_Item_Regular_Unit, 
		i.Like_Item_Sales, i.Facings, i.POG_Min_Qty,    i.Like_Item_Store_Count, i.Annual_Regular_Unit_Forecast, i.Annual_Reg_Retail_Sales, 
		i.Like_Item_Unit_Store_Month, b.Date_Modified as Last_Modified,    
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>' else '' end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>' else '' end as MSDS_Sheet, 
		COALESCE(lv.Display_Text, '') as Private_Brand_Label,    i.Customs_Description,   
		silEs.Package_Language_Indicator as Package_Language_Indicator_English, silFs.Package_Language_Indicator as Package_Language_Indicator_French,
		silSs.Package_Language_Indicator as Package_Language_Indicator_Spanish, silE.Translation_Indicator as Translation_Indicator_English,
		silF.Translation_Indicator as Translation_Indicator_French, silS.Translation_Indicator as Translation_Indicator_Spanish,
		silE.Description_Short as English_Short_Description, silE.Description_Long as English_Long_Description, 
		silF.Description_Short as French_Short_Description, --silF.Description_Medium as French_Item_Description, MWM:LCR
		silF.Description_Long as French_Long_Description, 
		silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description,
		i.PhytoSanitaryCertificate, i.PhytoTemporaryShipment
	FROM [SPD_Items] i with(nolock)            
	inner join [SPD_Item_Headers] ih with(nolock) on i.Item_Header_ID = ih.ID             
	inner join [SPD_Batch] b with(nolock) on ih.Batch_ID = b.ID             
	left outer join SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1             
	LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'D' and f1.Item_ID = i.[ID] and f1.File_Type = 'IMG'              
	LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'D' and f2.Item_ID = i.[ID] and f2.File_Type = 'MSDS'         
	LEFT JOIN SPD_Item_Master_Languages as silE with(nolock) on silE.Michaels_SKU = i.Michaels_SKU and silE.Language_Type_ID = 1 -- ENGLISH Language Fields            
	LEFT JOIN SPD_Item_Master_Languages as silF with(nolock) on silF.Michaels_SKU = i.Michaels_SKU and silF.Language_Type_ID = 2 -- FRENCH Language Fields            
	LEFT JOIN SPD_Item_Master_Languages as silS with(nolock) on silS.Michaels_SKU = i.Michaels_SKU and silS.Language_Type_ID = 3 -- SPANISH Language Fields               
	LEFT JOIN SPD_Item_Master_Languages_Supplier as silEs with(nolock) on silEs.Michaels_SKU = i.Michaels_SKU and silEs.Vendor_Number = b.Vendor_Number and silEs.Language_Type_ID = 1 -- ENGLISH Language Fields            
	LEFT JOIN SPD_Item_Master_Languages_Supplier as silFs with(nolock) on silFs.Michaels_SKU = i.Michaels_SKU and silFs.Vendor_Number = b.Vendor_Number and silFs.Language_Type_ID = 2 -- FRENCH Language Fields            
	LEFT JOIN SPD_Item_Master_Languages_Supplier as silSs with(nolock) on silSs.Michaels_SKU = i.Michaels_SKU and silSs.Vendor_Number = b.Vendor_Number and silSs.Language_Type_ID = 3 -- SPANISH Language Fields      
	LEFT OUTER JOIN List_Values as lv with(nolock) on lv.List_Value_Group_ID = 16 And i.Private_Brand_Label = lv.List_Value        
	WHERE b.Batch_Type_ID=1 AND
		(@startDate is null or (@startDate is not null and b.date_modified >= @startDate))      
		and (@endDate is null or (@endDate is not null and b.date_modified <= @endDate))      
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept))      
		and (COALESCE(ws.Workflow_id, 1) = 1 and COALESCE(ws.Stage_Type_id, 1) = 4)   
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and (ih.US_Vendor_Num = @vendor or ih.Canadian_Vendor_Num = @vendor))) 
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and b.Vendor_Number = @vendorFilter))   
		and (isnull(@approver, 0) = 0 or (isnull(@approver, 0) > 0 and b.ID in (SELECT distinct spd_batch_ID from SPD_Batch_History WHERE modified_user = @approver)))      
END

IF (@workflowId = 2)
BEGIN

	SELECT simi.ID, simi.Batch_ID as Log_ID,
		su.First_Name + ' ' + su.Last_Name as Submitted_By,
		b.Date_Created as Date_Submitted, 
		v.Vendor_Number as Vendor_Number, 
		V.Harmonized_CodeNumber as Harmonized_Code_Number, v.Canada_Harmonized_CodeNumber as Canada_Harmonized_Code_Number,
		V.Detail_Invoice_Customs_Desc0 as Detail_Invoice_Customs_Desc, V.Component_Material_Breakdown,
		sv.Vendor_Name as Vendor_Name, 
		s.Department_Num, 
		s.Stock_Category,
		UPPER(s.Item_Type) as item_Type, s.Item_Type_Attribute, UPPER(s.Allow_Store_Order) as Allow_Store_Order,
		UPPER(s.Inventory_Control) as Inventory_Control,v.Freight_Terms, UPPER(s.Auto_Replenish) AS Auto_Replenish,
		s.SKU_Group, s.Store_Supplier_Zone_Group, s.WHS_Supplier_Zone_Group, 
		b.Date_Created,
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = b.Created_User) as [Created User],		
		b.Date_Modified as Date_Last_Modified, 
		'System' as Update_User,
		s.RMS_Sellable, s.RMS_Orderable, s.RMS_Inventory,
		s.Store_Total,
		UPPER(s.Discountable) as Discountable,
		s.Add_Change, UPPER(s.Item_Type) as Pack_Item_Indicator, s.Michaels_SKU, UPC.UPC AS Vendor_UPC, 
		s.Class_Num, s.Sub_Class_Num, UPPER(V.Vendor_Style_Num) as Vendor_Style_Num, s.Item_Desc, --s.Hybrid_Type, 
		--s.Hybrid_Source_DC,
		s.STOCKING_STRATEGY_CODE as STOCKING_STRATEGY_CODE,
		C.Eaches_Master_Case, C.Eaches_Inner_Pack, 
		CASE WHEN (SELECT COUNT(*) FROM SPD_Item_Master_UDA UDA4 WHERE UDA4.Michaels_SKU = s.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS Pre_Priced,
		(SELECT TOP (1) ISNULL(UDA_Value, 0) AS Expr1 FROM SPD_Item_Master_UDA AS UDA5 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 10)) AS Pre_Priced_UDA,
		C.Unit_Cost as Unit_Cost,
		s.Base1_Retail, s.Base2_Retail, s.Test_Retail, s.Alaska_Retail, s.Canada_Retail, s.High2_Retail, s.High3_Retail,
		s.Small_Market_Retail, s.High1_Retail, s.Base3_Retail, s.Low1_Retail, s.Low2_Retail, s.Manhattan_Retail, 
		s.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store, s.POG_Max_Qty, s.Quebec_Retail as Q5_Retail,s.PuertoRico_Retail as PR_Retail,
		C.Each_Case_Height, C.Each_Case_Width, C.Each_Case_Length, C.Each_Case_Weight, C.Each_Case_Cube as Each_Case_Pack_Cube, 
		C.Inner_Case_Height, C.Inner_Case_Width, C.Inner_Case_Length, C.Inner_Case_Weight, C.Inner_Case_Cube as Inner_Case_Pack_Cube, 
		C.Master_Case_Height, C.Master_Case_Width,C.Master_Case_Length, C.Master_Case_Weight, C.Master_Case_Cube as Master_Case_Pack_Cube, 
		C.Country_Of_Origin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS Country_Of_Origin_Name,
		(SELECT TOP (1) UDA_ID FROM SPD_Item_Master_UDA AS UDA2 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_UDA,
		(SELECT TOP (1) UDA_Value FROM SPD_Item_Master_UDA AS UDA3 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_Value_UDA,
		UPPER(s.Hazardous) AS Hazardous, UPPER(s.Hazardous_Flammable) AS Hazardous_Flammable, UPPER(s.Hazardous_Container_Type) as Hazardous_Container_Type,
		s.Hazardous_Container_Size, UPPER(s.Hazardous_MSDS_UOM) as Hazardous_MSDS_UOM, v.Hazardous_Manufacturer_Name, v.Hazardous_Manufacturer_City, 
		v.Hazardous_Manufacturer_State, v.Hazardous_Manufacturer_Phone, v.Hazardous_Manufacturer_Country, V.MSDS_ID, V.Image_ID,
		simi.Is_Valid, 
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>' else '' end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=item_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>' else '' end as MSDS_Sheet, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS PrivateBrandLabel, s.Customs_Description,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, simlF.Description_Short as French_Short_Description,    
		--simlF.Description_Medium as French_Item_Description,  MWM:LCR
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, 
		simlS.Description_Long as Spanish_Long_Description,
		S.Fumigation_Certificate, S.PhytoTemporaryShipment
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
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'D' and f1.[Item_ID] = v.Image_ID and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'D' and f2.[Item_ID] = v.MSDS_ID and f2.File_Type = 'MSDS'       
		LEFT JOIN SPD_Item_Master_Languages as simlE with(nolock) on simlE.Michaels_SKU = s.Michaels_SKU and simlE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlF with(nolock) on simlF.Michaels_SKU = s.Michaels_SKU and simlF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlS with(nolock) on simlS.Michaels_SKU = s.Michaels_SKU  and simlS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsE with(nolock) on simlsE.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsF.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsS.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
	WHERE b.Enabled = 1 AND sv.Vendor_Type = 110 and b.Batch_Type_ID=1
		and (@startDate is null or (@startDate is not null and b.date_modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.date_modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and s.Department_Num = @dept))        
		and ws.Workflow_id = 2 and COALESCE(ws.Stage_Type_id, 1) = 4 
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and v.Vendor_Number = @vendor))      
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and v.Vendor_Number = @vendorFilter))
		and (isnull(@approver, 0) = 0 or (isnull(@approver, 0) > 0 and b.ID in (SELECT distinct spd_batch_ID from SPD_Batch_History WHERE modified_user = @approver)))      
END



--*************************************************
--SPD_Report_CompletedImportItem
--*************************************************
SET ANSI_NULLS ON

GO

/****** Object:  StoredProcedure [dbo].[SPD_Report_DomesticItem]    Script Date: 4/9/2024 10:22:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SPD_Report_DomesticItem] 
	@startDate as Datetime = null,
	@endDate as DateTime = null,
	@dept as integer = null,
	@stage as integer = null,
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

	SELECT  ih.ID, ih.Batch_ID as Log_ID, ih.Submitted_By, ih.Date_Submitted, ih.Supply_Chain_Analyst, ih.Mgr_Supply_Chain, 
		ih.Dir_SCVR, ih.Rebuy_YN, ih.Replenish_YN, ih.Store_Order_YN, ih.Date_In_Retek, ih.Enter_Retek, ih.US_Vendor_Num, 
		ih.Canadian_Vendor_num, i.Harmonized_Code_Number, i.Canada_Harmonized_Code_Number,
		 i.Detail_Invoice_Customs_Desc, 
		i.Component_Material_Breakdown, ih.US_Vendor_Name, ih.Canadian_Vendor_Name, ih.Department_Num, ih.Buyer_Approval, 
		ih.Stock_Category, ih.Canada_Stock_Category, ih.Item_Type, ih.Item_type_Attribute, ih.Allow_Store_Order, ih.Perpetual_Inventory, 
		ih.Inventory_Control, ih.Freight_Terms, ih.Auto_Replenish, ih.SKU_Group, ih.Store_Supplier_Zone_Group, ih.WHS_Supplier_Zone_Group, 
		ih.Comments, ih.Worksheet_Desc, ih.Batch_File_ID, ih.Date_Created, 
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ih.Created_User_ID) as CreatedUser,
		b.Date_Modified as Last_Modified,    
		COALESCE((SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = ih.Update_User_ID), 'System') as UpdateUser,
		ih.RMS_Sellable, 
		ih.RMS_Orderable, ih.RMS_Inventory, ih.Store_Total, ih.POG_Start_Date, ih.POG_Comp_Date, ih.Calculate_Options, ih.Discountable, 
		ih.Add_Unit_Cost, i.Item_Header_ID, i.Add_Change, i.Pack_Item_Indicator, i.Michaels_SKU as SKU, i.Vendor_UPC, i.Class_Num, 
		i.Sub_Class_Num, i.Vendor_Style_Num, i.Item_Desc,    --i.Hybrid_Type, 
		--i.Hybrid_Source_DC,
		i.Stocking_Strategy_Code,
		 --i.Hybrid_Lead_Time, i.Hybrid_Conversion_Date, 
		i.Eaches_Master_Case, i.Eaches_Inner_Pack, i.Pre_Priced, i.Pre_Priced_UDA, i.US_Cost, i.Canada_Cost, i.Base_Retail as Base1_Retail, 
		i.Central_Retail as Base2_Retail, i.Test_Retail, i.Alaska_Retail, i.Canada_Retail,     
		i.Zero_Nine_Retail as High2_Retail, i.California_Retail as High3_Retail, i.Village_Craft_Retail as Small_Market_Retail, 
		i.Retail9 as High1_Retail,     i.Retail10 as Base3_Retail, i.Retail11 as Low1_Retail, i.Retail12 as Low2_Retail, i.Retail13 as Manhattan_Retail, 
		i.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store,    i.POG_Max_Qty, i.RDQuebec as Q5_Retail, i.RDPuertoRico as PR_Retail, 
		
		i.Each_Case_Height, i.Each_Case_Width, i.Each_Case_Length, i.Each_Case_Weight, i.Each_Case_Pack_Cube, 
		i.Inner_Case_Height, i.Inner_Case_Width, i.Inner_Case_Length, i.Inner_Case_Weight, i.Inner_Case_Pack_Cube, 
		i.Master_Case_Height, i.Master_Case_Width, i.Master_Case_Length, i.Master_Case_Weight, i.Master_Case_Pack_Cube, 
		
		i.Country_Of_Origin, i.Country_Of_Origin_Name, i.Tax_UDA, i.Tax_Value_UDA, 
		i.Hazardous, i.Hazardous_Flammable, i.Hazardous_Container_Type, i.Hazardous_Container_Size, i.Hazardous_MSDS_UOM,    
		i.Hazardous_Manufacturer_Name, i.Hazardous_Manufacturer_City, i.Hazardous_Manufacturer_State, i.Hazardous_Manufacturer_Phone, 
		i.Hazardous_Manufacturer_Country, i.MSDS_ID, i.Image_ID, i.Tax_Wizard, i.Is_Valid, i.Like_Item_SKU, i.Like_Item_Description, 
		i.Like_Item_Retail, i.Like_Item_Regular_Unit, i.Like_Item_Sales, i.Facings, i.POG_Min_Qty, i.Like_Item_Store_Count, 
		i.Annual_Regular_Unit_Forecast, i.Annual_Reg_Retail_Sales, i.Like_Item_Unit_Store_Month,
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>' else '' end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=importitem_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>' else '' end as MSDS_Sheet, 
		COALESCE(lv.Display_Text, '') as Private_Brand_Label,    i.Customs_Description,   
		silE.Package_Language_Indicator as Package_Language_Indicator_English, 
		silF.Package_Language_Indicator as Package_Language_Indicator_French, 
		silS.Package_Language_Indicator as Package_Language_Indicator_Spanish,    
		silE.Translation_Indicator as Translation_Indicator_English, 
		silF.Translation_Indicator as Translation_Indicator_French, 
		silS.Translation_Indicator as Translation_Indicator_Spanish,     
		silE.Description_Short as English_Short_Description, silE.Description_Long as English_Long_Description, 
		silF.Description_Short as French_Short_Description, silF.Description_Long as French_Long_Description, 
		silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description,
		I.PhytoSanitaryCertificate, i.PhytoTemporaryShipment
	FROM [SPD_Items] i with(nolock)         
		inner join [SPD_Item_Headers] ih with(nolock) on i.Item_Header_ID = ih.ID           
		inner join [SPD_Batch] b with(nolock) on ih.Batch_ID = b.ID           
		left outer join SPD_Workflow_Stage ws with(nolock) on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1           
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'D' and f1.Item_ID = i.[ID] and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'D' and f2.Item_ID = i.[ID] and f2.File_Type = 'MSDS'       
		LEFT JOIN SPD_Item_Languages as silE with(nolock) on silE.Item_ID = i.ID and silE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Languages as silF with(nolock) on silF.Item_ID = i.ID and silF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Languages as silS with(nolock) on silS.Item_ID = i.ID and silS.Language_Type_ID = 3 -- SPANISH Language Fields            
		LEFT OUTER JOIN List_Values as lv with(nolock) on lv.List_Value_Group_ID = 16 And i.Private_Brand_Label = lv.List_Value     
	WHERE b.enabled = 1  and b.Batch_Type_ID=1 and 
		(@startDate is null or (@startDate is not null and b.date_modified >= @startDate)) and
		(@endDate is null or (@endDate is not null and b.date_modified <= @endDate))  and    
		(isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept))  and    
		((isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 1) = 1 and COALESCE(ws.Stage_Type_id, 1) <> 4 ) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage))  and
		((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and (ih.US_Vendor_Num = @vendor or ih.Canadian_Vendor_Num = @vendor))) and
		((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and b.Vendor_Number = @vendorFilter)) and
		(@approver is null or (b.Workflow_Stage_ID in (select wap.Workflow_Stage_id from SPD_Workflow_Approval_Group wap inner join Security_User_Group sug on wap.Approval_group_id = sug.Group_ID inner join Security_User su on sug.[User_ID] = su.[ID] where su.[ID] = @approver ) 
								and b.fineline_dept_ID in (select isnull(convert(int, substring(sp.constant, 10, len(sp.constant))), 0) from Security_Privilege sp inner join Security_User_Privilege sup on sp.[ID] = sup.Privilege_ID where sp.Scope_ID = 1002 and sup.[User_ID] = @approver)))
END

IF (@workflowId = 2)
BEGIN

	SELECT simi.ID, simi.Batch_ID as Log_ID,
		su.First_Name + ' ' + su.Last_Name as Submitted_By,
		b.Date_Created as Date_Submitted, 
		v.Vendor_Number as Vendor_Number, 
		V.Harmonized_CodeNumber as Harmonized_Code_Number, v.Canada_Harmonized_CodeNumber as Canada_Harmonized_Code_Number,
		V.Detail_Invoice_Customs_Desc0 as Detail_Invoice_Customs_Desc, V.Component_Material_Breakdown,
		sv.Vendor_Name as Vendor_Name, 
		s.Department_Num, 
		s.Stock_Category,
		UPPER(s.Item_Type) as item_Type, s.Item_Type_Attribute, UPPER(s.Allow_Store_Order) as Allow_Store_Order,
		UPPER(s.Inventory_Control) as Inventory_Control,v.Freight_Terms, UPPER(s.Auto_Replenish) AS Auto_Replenish,
		s.SKU_Group, s.Store_Supplier_Zone_Group, s.WHS_Supplier_Zone_Group, b.Date_Created,
		(SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = b.Created_User) as [Created User],
		b.Date_Modified as Date_Last_Modified, 		
		COALESCE((SELECT First_Name + ' ' + Last_Name FROM Security_User where ID = b.Modified_User),'System') as [Update User],
		s.RMS_Sellable, s.RMS_Orderable, s.RMS_Inventory,
		s.Store_Total,
		UPPER(s.Discountable) as Discountable,
		s.Add_Change, UPPER(s.Item_Type) as Pack_Item_Indicator, s.Michaels_SKU as SKU, UPC.UPC AS Vendor_UPC, 
		s.Class_Num, s.Sub_Class_Num, UPPER(V.Vendor_Style_Num) as Vendor_Style_Num, s.Item_Desc, --s.Hybrid_Type, 
		--s.Hybrid_Source_DC,
		s.STOCKING_STRATEGY_CODE,
		C.Eaches_Master_Case, C.Eaches_Inner_Pack, 
		CASE WHEN (SELECT COUNT(*) FROM SPD_Item_Master_UDA UDA4 WHERE UDA4.Michaels_SKU = s.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS Pre_Priced,
		(SELECT TOP (1) ISNULL(UDA_Value, 0) AS Expr1 FROM SPD_Item_Master_UDA AS UDA5 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 10)) AS Pre_Priced_UDA,
		C.Unit_Cost as Unit_Cost,
		s.Base1_Retail, s.Base2_Retail, s.Test_Retail, s.Alaska_Retail, s.Canada_Retail, s.High2_Retail, s.High3_Retail,
		s.Small_Market_Retail, s.High1_Retail, s.Base3_Retail, s.Low1_Retail, s.Low2_Retail, s.Manhattan_Retail, 
		s.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store, s.POG_Max_Qty,  s.Quebec_Retail as Q5_Retail,s.PuertoRico_Retail as PR_Retail,
		
		C.Each_Case_Height, C.Each_Case_Width, C.Each_Case_Length, C.Each_Case_Weight, C.Each_Case_Cube as Each_Case_Pack_Cube, 
		C.Inner_Case_Height, C.Inner_Case_Width, C.Inner_Case_Length, C.Inner_Case_Weight, C.Inner_Case_Cube as Inner_Case_Pack_Cube, 
		C.Master_Case_Height, C.Master_Case_Width, C.Master_Case_Length, C.Master_Case_Weight, C.Master_Case_Cube as Master_Case_Pack_Cube, 
		
		C.Country_Of_Origin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS Country_Of_Origin_Name,
		(SELECT TOP (1) UDA_ID FROM SPD_Item_Master_UDA AS UDA2 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_UDA,
		(SELECT TOP (1) UDA_Value FROM SPD_Item_Master_UDA AS UDA3 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_Value_UDA,
		UPPER(s.Hazardous) AS Hazardous, UPPER(s.Hazardous_Flammable) AS Hazardous_Flammable, UPPER(s.Hazardous_Container_Type) as Hazardous_Container_Type,
		s.Hazardous_Container_Size, UPPER(s.Hazardous_MSDS_UOM) as Hazardous_MSDS_UOM, v.Hazardous_Manufacturer_Name, v.Hazardous_Manufacturer_City, 
		v.Hazardous_Manufacturer_State, v.Hazardous_Manufacturer_Phone, v.Hazardous_Manufacturer_Country, V.MSDS_ID, V.Image_ID,
		simi.Is_Valid, 
		case when isnull(f1.[File_ID], 0) > 0 then '<a href="getimage.aspx?id=' + convert(varchar(20), f1.[File_ID]) + '" target="_blank">Image</a>' else '' end as Item_Image,    
		case when isnull(f2.[File_ID], 0) > 0 then '<a href="getfile.aspx?ad=1&id=' + convert(varchar(20), f2.[File_ID]) + '&filename=item_' + convert(varchar(20), b.ID) + '_' + @dateNowStr + '.pdf">MSDS Sheet</a>' else '' end as MSDS_Sheet, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS Private_Brand_Label, s.Customs_Description,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, 
		simlF.Description_Short as French_Short_Description,    --simlF.Description_Medium as French_Item_Description, MWM:LCR
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, simlS.Description_Long as Spanish_Long_Description,
		s.Fumigation_Certificate, s.PhytoTemporaryShipment
	INTO #DomesticItemMaint
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
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'D' and f1.[file_ID] = v.Image_ID and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'D' and f2.[file_ID] = v.MSDS_ID and f2.File_Type = 'MSDS'       
		LEFT JOIN SPD_Item_Master_Languages as simlE with(nolock) on simlE.Michaels_SKU = s.Michaels_SKU and simlE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlF with(nolock) on simlF.Michaels_SKU = s.Michaels_SKU and simlF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlS with(nolock) on simlS.Michaels_SKU = s.Michaels_SKU  and simlS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsE with(nolock) on simlsE.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsF.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsS.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
	WHERE b.Enabled = 1 AND sv.Vendor_Type = 110 and b.Batch_Type_ID=1
		and (@startDate is null or (@startDate is not null and b.Date_Modified >= @startDate))        
		and (@endDate is null or (@endDate is not null and b.Date_Modified <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and s.Department_Num = @dept))        
		and ((isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 2) = 2    
		and COALESCE(ws.Stage_Type_id, 1) <> 4) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage))        
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and v.Vendor_Number = @vendor))      
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and simi.Vendor_Number = @vendorFilter))    
		and (@approver is null or (b.Workflow_Stage_ID in (select wap.Workflow_Stage_id from SPD_Workflow_Approval_Group wap inner join Security_User_Group sug on wap.Approval_group_id = sug.Group_ID inner join Security_User su on sug.[User_ID] = su.[ID] where su.[ID] = @approver ) 
									and b.fineline_dept_ID in (select isnull(convert(int, substring(sp.constant, 10, len(sp.constant))), 0) from Security_Privilege sp inner join Security_User_Privilege sup on sp.[ID] = sup.Privilege_ID where sp.Scope_ID = 1002 and sup.[User_ID] = @approver)))
		
		
		--UPDATE Temp Table with CHANGE Values	  
	    UPDATE #DomesticItemMaint
	    SET Item_Desc = isNull(c.Field_Value, dim.Item_Desc)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'ItemDesc'
		
	    UPDATE #DomesticItemMaint
	    SET Vendor_Style_Num = isNull(c.Field_Value, dim.Vendor_Style_Num)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'VendorStyleNum' 
	    
		UPDATE #DomesticItemMaint
	    SET Canada_Harmonized_Code_Number = isNull(c.Field_Value, dim.Canada_Harmonized_Code_Number)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'CanadaHarmonizedCodeNumber' 
	    
	    UPDATE #DomesticItemMaint
	    SET Harmonized_Code_Number = isNull(c.Field_Value, dim.Harmonized_Code_Number)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'HarmonizedCodeNumber' 
	    
	    UPDATE #DomesticItemMaint
	    SET Detail_Invoice_Customs_Desc = isNull(c.Field_Value, dim.Detail_Invoice_Customs_Desc)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'DetailInvoiceCustomsDesc0' 
	   
	    UPDATE #DomesticItemMaint
	    SET Component_Material_Breakdown = isNull(c.Field_Value, dim.Component_Material_Breakdown)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'ComponentMaterialBreakdown0'  
			    
	    UPDATE #DomesticItemMaint
	    SET Eaches_Master_Case = isNull(c.Field_Value, dim.Eaches_Master_Case)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EachesMasterCase' 
	    
	    UPDATE #DomesticItemMaint
	    SET Eaches_Inner_Pack = isNull(c.Field_Value, dim.Eaches_Inner_Pack)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EachesInnerPack' 
	    
	    UPDATE #DomesticItemMaint
	    SET Each_Case_Weight = isNull(c.Field_Value, dim.Each_Case_Weight)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EachCaseWeight' 
	    
	    UPDATE #DomesticItemMaint
	    SET Each_Case_Length = isNull(c.Field_Value, dim.Each_Case_Length)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EachCaseLength' 
	    
	    UPDATE #DomesticItemMaint
	    SET Each_Case_Width = isNull(c.Field_Value, dim.Each_Case_Width)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EachCaseWidth' 
	    
	    UPDATE #DomesticItemMaint
	    SET Each_Case_Height = isNull(c.Field_Value, dim.Each_Case_Height)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EachCaseHeight' 
	    
	    UPDATE #DomesticItemMaint
	    SET Each_Case_Pack_Cube = isNull(c.Field_Value, dim.Each_Case_Pack_Cube)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EachCaseCube' 

	    UPDATE #DomesticItemMaint
	    SET Inner_Case_Weight = isNull(c.Field_Value, dim.Inner_Case_Weight)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'InnerCaseWeight' 
	    
	    UPDATE #DomesticItemMaint
	    SET Inner_Case_Length = isNull(c.Field_Value, dim.Inner_Case_Length)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'InnerCaseLength' 
	    
	    UPDATE #DomesticItemMaint
	    SET Inner_Case_Width = isNull(c.Field_Value, dim.Inner_Case_Width)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'InnerCaseWidth' 
	    
	    UPDATE #DomesticItemMaint
	    SET Inner_Case_Height = isNull(c.Field_Value, dim.Inner_Case_Height)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'InnerCaseHeight' 
	    
	    UPDATE #DomesticItemMaint
	    SET Inner_Case_Pack_Cube = isNull(c.Field_Value, dim.Inner_Case_Pack_Cube)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'InnerCaseCube' 
	    
	    UPDATE #DomesticItemMaint
	    SET Master_Case_Length = isNull(c.Field_Value, dim.Master_Case_Length)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'MasterCaseLength' 
	    
	    UPDATE #DomesticItemMaint
	    SET Master_Case_Width = isNull(c.Field_Value, dim.Master_Case_Width)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'MasterCaseWidth'
	    
	    UPDATE #DomesticItemMaint
	    SET Master_Case_Height = isNull(c.Field_Value, dim.Master_Case_Height)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'MasterCaseHeight'
		
		UPDATE #DomesticItemMaint
	    SET Master_Case_Weight = isNull(c.Field_Value, dim.Master_Case_Weight)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'MasterCaseWeight'
		
		UPDATE #DomesticItemMaint
	    SET Master_Case_Pack_Cube = isNull(c.Field_Value, dim.Master_Case_Pack_Cube)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'MasterCaseCube'
		
		UPDATE #DomesticItemMaint
	    SET Country_Of_Origin = isNull(c.Field_Value, dim.Country_Of_Origin)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'CountryOfOrigin'
		
		UPDATE #DomesticItemMaint
	    SET Country_Of_Origin_Name = isNull(c.Field_Value, dim.Country_Of_Origin_Name)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'CountryOfOriginName'
				
		UPDATE #DomesticItemMaint
	    SET Stock_Category = isNull(c.Field_Value, dim.Stock_Category)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'StockCategory'
	    
	    UPDATE #DomesticItemMaint
	    SET Freight_Terms = isNull(c.Field_Value, dim.Freight_Terms)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'FreightTerms'
	    
	    UPDATE #DomesticItemMaint
	    SET Item_Type = isNull(c.Field_Value, dim.Item_Type)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'ItemType'
	    
	    UPDATE #DomesticItemMaint
	    SET Pack_Item_Indicator = isNull(c.Field_Value, dim.Pack_Item_Indicator)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'ItemType'
	    
	    UPDATE #DomesticItemMaint
	    SET Item_Type_Attribute = isNull(c.Field_Value, dim.Item_Type_Attribute)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'ItemTypeAttribute'
	    
	    UPDATE #DomesticItemMaint
	    SET Allow_Store_Order = isNull(c.Field_Value, dim.Allow_Store_Order)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'AllowStoreOrder'
	    
	    UPDATE #DomesticItemMaint
	    SET Inventory_Control = isNull(c.Field_Value, dim.Inventory_Control)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'InventoryControl'
	    
	    UPDATE #DomesticItemMaint
	    SET Auto_Replenish = isNull(c.Field_Value, dim.Auto_Replenish)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'AutoReplenish'
		
		UPDATE #DomesticItemMaint
	    SET Pre_Priced = isNull(c.Field_Value, dim.Pre_Priced)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'PrePriced'
		
		UPDATE #DomesticItemMaint
	    SET Pre_Priced_UDA = isNull(c.Field_Value, dim.Pre_Priced_UDA)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'PrePricedUDA'
		
		UPDATE #DomesticItemMaint
	    SET Tax_UDA = isNull(c.Field_Value, dim.Tax_UDA)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'TaxUDA'
	    
	    UPDATE #DomesticItemMaint
	    SET Tax_Value_UDA = isNull(c.Field_Value, dim.Tax_Value_UDA)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'TaxValueUDA'
	    
	 --   UPDATE #DomesticItemMaint
	 --   SET Hybrid_Type = isNull(c.Field_Value, dim.Hybrid_Type)
	 --   FROM #DomesticItemMaint as dim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		--WHERE    c.Field_Name = 'HybridType'
	    
	 --   UPDATE #DomesticItemMaint
	 --   SET Hybrid_Source_DC = isNull(c.Field_Value, dim.Hybrid_Source_DC)
	 --   FROM #DomesticItemMaint as dim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		--WHERE    c.Field_Name = 'HybridSourceDC'
		
		UPDATE #DomesticItemMaint
	    SET Stocking_Strategy_Code = isNull(c.Field_Value, dim.Stocking_Strategy_Code)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'StockingStrategyCode'
	 	    
	    UPDATE #DomesticItemMaint
	    SET Hazardous = isNull(c.Field_Value, dim.Hazardous)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'Hazardous'
	    		
		UPDATE #DomesticItemMaint
	    SET Hazardous_Container_Type = isNull(c.Field_Value, dim.Hazardous_Container_Type)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'HazardousContainerType'

	    UPDATE #DomesticItemMaint
	    SET Hazardous_Container_Size = CASE WHEN c.Field_Value <> '' THEN isNull(c.Field_Value, dim.Hazardous_Container_Size) Else dim.Hazardous_Container_Size END
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'HazardousContainerSize'

	    UPDATE #DomesticItemMaint
	    SET Hazardous_MSDS_UOM = isNull(c.Field_Value, dim.Hazardous_MSDS_UOM)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'HazardousMSDSUOM'
   
	    UPDATE #DomesticItemMaint
	    SET RMS_Sellable = isNull(c.Field_Value, dim.RMS_Sellable)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'RMSSellable'
	    
	    UPDATE #DomesticItemMaint
	    SET RMS_Orderable = isNull(c.Field_Value, dim.RMS_Orderable)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'RMSOrderable'
	    
	    UPDATE #DomesticItemMaint
	    SET RMS_Inventory = isNull(c.Field_Value, dim.RMS_Inventory)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'RMSInventory'
		
		UPDATE #DomesticItemMaint
	    SET Store_Total = isNull(c.Field_Value, dim.Store_Total)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'StoreTotal'

		UPDATE #DomesticItemMaint
	    SET Private_Brand_Label = isNull(c.Field_Value, dim.Private_Brand_Label)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'PrivateBrandLabel'
		
		UPDATE #DomesticItemMaint
	    SET Customs_Description = isNull(c.Field_Value, dim.Customs_Description)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'CustomsDescription'
		
		UPDATE #DomesticItemMaint
	    SET Package_Language_Indicator_English = isNull(c.Field_Value, dim.Package_Language_Indicator_English)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'PLIEnglish'
		
	    UPDATE #DomesticItemMaint
	    SET Package_Language_Indicator_French = isNull(c.Field_Value, dim.Package_Language_Indicator_French)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'PLIFrench'
		
		UPDATE #DomesticItemMaint
	    SET Package_Language_Indicator_Spanish = isNull(c.Field_Value, dim.Package_Language_Indicator_Spanish)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'PLISpanish'
	    
	    UPDATE #DomesticItemMaint
	    SET Translation_Indicator_English = isNull(c.Field_Value, dim.Translation_Indicator_English)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'TIEnglish'
	    
	    UPDATE #DomesticItemMaint
	    SET Translation_Indicator_French = isNull(c.Field_Value, dim.Translation_Indicator_French)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'TIFrench'
		
		UPDATE #DomesticItemMaint
	    SET Translation_Indicator_Spanish = isNull(c.Field_Value, dim.Translation_Indicator_Spanish)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'TISpanish'
	    
		UPDATE #DomesticItemMaint
	    SET English_Short_Description = isNull(c.Field_Value, dim.English_Short_Description)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EnglishShortDescription'
	    
	    UPDATE #DomesticItemMaint
	    SET English_Long_Description = isNull(c.Field_Value, dim.English_Long_Description)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'EnglishLongDescription'
	    
	    UPDATE #DomesticItemMaint
	    SET French_Short_Description = isNull(c.Field_Value, dim.French_Short_Description)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'FrenchShortDescription'

		--MWM:LCR
		--UPDATE #DomesticItemMaint
	 --   SET French_Item_Description = isNull(c.Field_Value, dim.French_Item_Description)
	 --   FROM #DomesticItemMaint as dim
	 --   LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		--WHERE    c.Field_Name = 'FrenchItemDescription'
	    
	    UPDATE #DomesticItemMaint
	    SET French_Long_Description = isNull(c.Field_Value, dim.French_Long_Description)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'FrenchLongDescription'
		
		UPDATE #DomesticItemMaint
	    SET Spanish_Short_Description = isNull(c.Field_Value, dim.Spanish_Short_Description)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'SpanishShortDescription'
	    
	    UPDATE #DomesticItemMaint
	    SET Spanish_Long_Description = isNull(c.Field_Value, dim.Spanish_Long_Description)
	    FROM #DomesticItemMaint as dim
	    LEFT JOIN SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = dim.ID
		WHERE    c.Field_Name = 'SpanishLongDescription'
	    
	    Select * from #DomesticItemMaint
	    
	    Drop Table #DomesticItemMaint      
	               
END

GO



--*********************
--PHYTO REPORT CHANGS POST 6/13/2024
--*********************

--***********
--ALTER
--**********

/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster]    Script Date: 6/13/2024 2:37:55 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

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
	
	

	DECLARE @SCFH table
	(
		Michaels_SKU varchar(10),
		Metadata_Column_ID int,
		New_Value varchar(max)
	)

	DECLARE @PhytoCertID int = 0
	DECLARE @PhytoTempShipID int = 0


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

		Select @PhytoCertID = isNull(id,0) from spd_metadata_column mc 
		where MC.MetaData_table_id = 3 and MC.Column_Name = 'PhytoSanitaryCertificate'
		and isNull(MC.Track_History,0) = 1

		Select @PhytoTempShipID = isNull(id,0) from spd_metadata_column mc 
		where MC.MetaData_table_id = 3 and MC.Column_Name = 'PhytoTemporaryShipment'
		and isNull(MC.Track_History,0) = 1


		BEGIN TRY

			--insert history columns
			if @PhytoCertID > 0
			BEGIN
				Insert into @SCFH
				(Michaels_SKU, 
				Metadata_Column_ID, 
				New_Value)
				Select distinct
				SKU.Michaels_SKU, 
				@PhytoCertID, 
				DI.[PhytoSanitaryCertificate]
				FROM [SPD_Item_Master_SKU] SKU
					Join SPD_Items DI			on SKU.[Michaels_SKU] = DI.Michaels_SKU
					join SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
					join SPD_Batch B			on DH.Batch_ID = B.ID
					join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				WHERE 	B.ID = @BatchID
					and DI.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
					and WS.Stage_Type_id = 4	-- ONLY COMPLETED BATCHES PLEASE
			END

			--insert history columns
			if @PhytoTempShipID > 0
			BEGIN
				Insert into @SCFH
				(Michaels_SKU, 
				Metadata_Column_ID, 
				New_Value)
				Select distinct
				SKU.Michaels_SKU, 
				@PhytoTempShipID, 
				DI.[PhytoTemporaryShipment]
				FROM [SPD_Item_Master_SKU] SKU
					Join SPD_Items DI			on SKU.[Michaels_SKU] = DI.Michaels_SKU
					join SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
					join SPD_Batch B			on DH.Batch_ID = B.ID
					join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				WHERE 	B.ID = @BatchID
					and DI.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
					and WS.Stage_Type_id = 4	-- ONLY COMPLETED BATCHES PLEASE
			END


			Insert into  SPD_Change_Field_History
			(Michaels_SKU, Batch_ID, Metadata_Column_ID, Old_Value, New_Value)
			Select Distinct
			Michaels_SKU, @BatchID, Metadata_Column_ID, Null, New_Value
			from @SCFH SCFH
			where not exists
			(
				Select 1 from SPD_Change_Field_History SCFH2
				where SCFH2.Michaels_SKU = SCFH.Michaels_SKU
				and SCFH2.Batch_ID = @BatchID
				and SCFH2.Metadata_Column_ID = SCFH.Metadata_Column_ID
			) and New_Value is not null

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
				,[Fumigation_Certificate] = DI.[PhytoSanitaryCertificate]
				,[PhytoTemporaryShipment] = DI.[PhytoTemporaryShipment]
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
				, [Each_LWH_UOM] = 'IN'
				, [Each_Weight_UOM] = 'LB'
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

		--MWM:LCR
		---- Update SPD_Item_Translation_Required
		--Set @msg = 'Adding items to SPD_Item_Translation_Required from Domestic New Item. Batch: ' + @vcBatchID
		--IF @Debug=1  Print @msg
		--EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		--BEGIN TRY
		--	Insert into SPD_Item_Translation_Required
		--	(Michaels_SKU)
		--	Select distinct sku.Michaels_SKU
		--	FROM [SPD_Item_Master_SKU] SKU
		--		Join SPD_Items DI			on SKU.[Michaels_SKU] = DI.Michaels_SKU
		--		join SPD_Item_Headers DH	on DI.Item_Header_ID = DH.ID
		--		join SPD_Batch B			on DH.Batch_ID = B.ID
		--		join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
		--	WHERE 	B.ID = @BatchID
		--		and DI.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
		--		and WS.Stage_Type_id = 4	-- ONLY COMPLETED BATCHES PLEASE
		--		and ltrim(rtrim(SKU.SKU_Group)) In ('US AND CANADA','CANADA ONLY')
		--		and sku.POG_Start_Date is not null
		--		and not exists
		--		(
		--			Select 1 from SPD_Item_Translation_Required R where R.Michaels_SKU = sku.Michaels_SKU
		--		)

		--	set @rows = @@Rowcount
		--	set @msg = '    Records Inserted: ' + convert(varchar(20),@rows)
		--	IF @Debug=1  Print @msg
		--	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		--END TRY
		
		--BEGIN CATCH
		--	set @msg = 'Adding items to SPD_Item_Translation_Required SKU from Domestic... Error Occurred in Insert' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
		--	Rollback Tran
		--	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		--	EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		--	RETURN
		--END CATCH

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

		Select @PhytoCertID = isNull(id,0) from spd_metadata_column mc 
		where MC.MetaData_table_id = 1 and MC.Column_Name = 'FumigationCertificate'
		and isNull(MC.Track_History,0) = 1

		Select @PhytoTempShipID = isNull(id,0) from spd_metadata_column mc 
		where MC.MetaData_table_id = 1 and MC.Column_Name = 'PhytoTemporaryShipment'
		and isNull(MC.Track_History,0) = 1



		BEGIN TRY


					--insert history columns
			if @PhytoCertID > 0
			BEGIN
				Insert into @SCFH
				(Michaels_SKU, 
				Metadata_Column_ID, 
				New_Value)
				Select distinct
				SKU.Michaels_SKU, 
				@PhytoCertID, 
				II.[FumigationCertificate]
				FROM [SPD_Item_Master_SKU] SKU
					Join SPD_Import_Items II	on SKU.[Michaels_SKU] = II.MichaelsSKU
					join SPD_Batch B			on II.Batch_ID = B.ID
					join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				WHERE B.ID = @BatchID
					and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
					and II.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
			END

			--insert history columns
			if @PhytoTempShipID > 0
			BEGIN
				Insert into @SCFH
				(Michaels_SKU, 
				Metadata_Column_ID, 
				New_Value)
				Select distinct
				SKU.Michaels_SKU, 
				@PhytoTempShipID, 
				II.[PhytoTemporaryShipment]
				FROM [SPD_Item_Master_SKU] SKU
					Join SPD_Import_Items II	on SKU.[Michaels_SKU] = II.MichaelsSKU
					join SPD_Batch B			on II.Batch_ID = B.ID
					join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
				WHERE B.ID = @BatchID
					and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
					and II.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
			END


			Insert into  SPD_Change_Field_History
			(Michaels_SKU, Batch_ID, Metadata_Column_ID, Old_Value, New_Value)
			Select Distinct
			Michaels_SKU, @BatchID, Metadata_Column_ID, Null, New_Value
			from @SCFH SCFH
			where not exists
			(
				Select 1 from SPD_Change_Field_History SCFH2
				where SCFH2.Michaels_SKU = SCFH.Michaels_SKU
				and SCFH2.Batch_ID = @BatchID
				and SCFH2.Metadata_Column_ID = SCFH.Metadata_Column_ID
			)
			and New_Value is not null

			UPDATE [SPD_Item_Master_SKU]
				SET 
				Date_Last_Modified = @CurDate
				, Update_User_ID = 0
				, Planogram_Name = II.PlanogramName
				,[Buyer] = II.[Buyer]
				,[Buyer_Fax] = II.[Fax]
				,[Buyer_Email] = II.[Email]
				,[Season] = II.[Season]
				,CoinBattery = II.CoinBattery
				,[TSSA] = II.TSSA
				,[CSA] = II.CSA
				,[UL] = II.UL
				,[Licence_Agreement] = II.[LicenceAgreement]
				,[Fumigation_Certificate] = II.[FumigationCertificate]
				,[PhytoTemporaryShipment] = II.[PhytoTemporaryShipment]
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
				,[Supp_Tariff_Percent] = case when isNumeric(II.[SuppTariffPercent]) = 1 then II.[SuppTariffPercent] else NULL END
				,[Supp_Tariff_Amount] = case when isNumeric(II.[SuppTariffAmount]) = 1 then II.[SuppTariffAmount] else NULL END
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
				--,MinimumOrderQuantity = case when isNumeric(II.[MinimumOrderQuantity]) = 1 then II.[MinimumOrderQuantity] else NULL END
				--,ProductIdentifiesAsCosmetic = II.[ProductIdentifiesAsCosmetic]
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
				, [Each_LWH_UOM] = 'IN'
				, [Each_Weight_UOM] = 'LB'
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
					Select @r0 = left(Element,1000) from @t1 where ElementID = 1
					Select @r1 = left(Element,1000) from @t1 where ElementID = 2
					Select @r2 = left(Element,1000) from @t1 where ElementID = 3
					Select @r3 = left(Element,1000) from @t1 where ElementID = 4
					Select @r4 = left(Element,1000) from @t1 where ElementID = 5
					Select @r5 = left(Element,1000) from @t1 where ElementID = 6

					DELETE FROM @t1

					Update [SPD_Item_Master_Vendor] 
						SET 
						  [Detail_Invoice_Customs_Desc0] = left(Coalesce(@r0,''), 1000)
						, [Detail_Invoice_Customs_Desc1] = left(Coalesce(@r1,''), 1000)
						, [Detail_Invoice_Customs_Desc2] = left(Coalesce(@r2,''), 1000)
						, [Detail_Invoice_Customs_Desc3] = left(Coalesce(@r3,''), 1000)
						, [Detail_Invoice_Customs_Desc4] = left(Coalesce(@r4,''), 1000)
						, [Detail_Invoice_Customs_Desc5] = left(Coalesce(@r5,''), 1000)
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c1 = @c1 + 1	
				END
				
				IF @break is not NULL
				BEGIN

					INSERT @t1
						Select ElementID, Element FROM SPLIT(@break, '<MULTILINEDELIMITER>')

					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = left(Element,1000) from @t1 where ElementID = 1
					Select @r1 = left(Element,1000) from @t1 where ElementID = 2
					Select @r2 = left(Element,1000) from @t1 where ElementID = 3
					Select @r3 = left(Element,1000) from @t1 where ElementID = 4
					Select @r4 = left(Element,1000) from @t1 where ElementID = 5

					DELETE FROM @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
  						  [Component_Material_Breakdown0] = left(coalesce(@r0,''), 1000)
						, [Component_Material_Breakdown1] = left(coalesce(@r1,''), 1000)
						, [Component_Material_Breakdown2] = left(coalesce(@r2,''), 1000)
						, [Component_Material_Breakdown3] = left(coalesce(@r3,''), 1000)
						, [Component_Material_Breakdown4] = left(coalesce(@r4,''), 1000)
					--FROM [SPD_Item_Master_Vendor]
					WHERE [Michaels_SKU] = @SKU and [Vendor_Number] = @VendorNo
					SET @c2 = @c2 + 1	
				END		

				IF @method is not NULL
				BEGIN
					Insert @t1
						Select ElementID, Element FROM SPLIT(@method, '<MULTILINEDELIMITER>')

					select @r0 = '',@r1 = '',@r2 = '',@r3 = '',@r4 = '',@r5 = ''
					Select @r0 = left(Element,1000) from @t1 where ElementID = 1
					Select @r1 = left(Element,1000) from @t1 where ElementID = 2
					Select @r2 = left(Element,1000) from @t1 where ElementID = 3
					Select @r3 = left(Element,1000) from @t1 where ElementID = 4
					delete from @t1
					
					Update [SPD_Item_Master_Vendor] 
						SET 
						  [Component_Construction_Method0] = left(coalesce(@r0,''), 1000)
						, [Component_Construction_Method1] = left(coalesce(@r1,''), 1000)
						, [Component_Construction_Method2] = left(coalesce(@r2,''), 1000)
						, [Component_Construction_Method3] = left(coalesce(@r3,''), 1000)
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
			IF @Debug=1  Print @msg
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
		
		--MWM:LCR
		---- Update SPD_Item_Translation_Required
		--Set @msg = 'Adding items to SPD_Item_Translation_Required from Import New Item. Batch: ' + @vcBatchID
		--IF @Debug=1  Print @msg
		--EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		--BEGIN TRY
		--	Insert into SPD_Item_Translation_Required
		--	(Michaels_SKU)
		--	Select distinct sku.Michaels_SKU
		--	FROM [SPD_Item_Master_SKU] SKU
		--		Join SPD_Import_Items II	on SKU.[Michaels_SKU] = II.MichaelsSKU
		--		join SPD_Batch B			on II.Batch_ID = B.ID
		--		join SPD_Workflow_Stage WS	on B.Workflow_Stage_ID = WS.ID
		--	WHERE B.ID = @BatchID
		--		and WS.Stage_Type_id = 4		-- ONLY COMPLETED BATCHES PLEASE
		--		and II.Valid_Existing_SKU = 0	-- Make sure that Item is new and not loaded initially from the Item Master
		--		and ltrim(rtrim(SKU.SKU_Group)) In ('US AND CANADA','CANADA ONLY')
		--		and sku.POG_Start_Date is not null
		--		and not exists
		--		(
		--			Select 1 from SPD_Item_Translation_Required R where R.Michaels_SKU = sku.Michaels_SKU
		--		)

		--	set @rows = @@Rowcount
		--	set @msg = '    Records Inserted: ' + convert(varchar(20),@rows)
		--	IF @Debug=1  Print @msg
		--	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		--END TRY
		
		--BEGIN CATCH
		--	set @msg = 'Adding items to SPD_Item_Translation_Required SKU from Import... Error Occurred in Insert' + ' (Batch: ' + @vcBatchID + ') ' + ERROR_MESSAGE()
		--	Rollback Tran
		--	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		--	EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		--	RETURN
		--END CATCH

	END	
	
	Commit Tran
	IF @Debug=1  Print 'Updating Item Master Proc Ends'
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Updating Item Master From New Item Proc Ends'


END




GO



/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_CompleteOrErrorBatch]    Script Date: 6/14/2024 9:27:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
-- =============================================
Author:			Littlefield, Jeff
Create date:	July 2010
Description:	Mark Batch as Complete and Process Change records 
--				OR Mark Batch as error and send error message
				CALLED BY Item Maint process: usp_SPD_ItemMaint_ProcessIncomingMessage

Chang Log: 
Sept 7 2010 - FJL Added logic to process cost records when batch completes
Oct 7,2010 - FJL add safeguards on email addresses to set to the BCC address if the email address are null
Mar 25, 2013 - NAK Added logic for new Batch Types to properly handle workflow changes
Mar 16,2015 - Trilingual Batch Completion Error 
Jun 14, 2024 - adding change history for phyto fields
-- =============================================
*/

ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_CompleteOrErrorBatch]
	@Batch_ID bigint
	, @cmd	char
	, @Msg varchar(max) = ''
	, @ErrorSKU varchar(20) = ''
	, @debug bit = 1
	, @LTS datetime = null
AS
BEGIN
	SET NOCOUNT ON;
	
IF @LTS is NULL
	SET @LTS = getdate()
	
DECLARE @STAGE_COMPLETED int
DECLARE @STAGE_WAITINGFORSKU int
DECLARE @STAGE_DBC int
DECLARE @MichaelsEmailRecipients varchar(max)
DECLARE @EmailRecipients varchar(max)
DECLARE @EmailSubject varchar(4000)
DECLARE @SPEDYBatchGUID varchar(4000)
DECLARE @EmailBody varchar(max)
DECLARE @EmailQuery varchar(max)
DECLARE @WorkflowStageID tinyint
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
Declare @Error int
declare @IntErrorMsg varchar(1000)
declare @temp varchar(1000)
DECLARE @myID int, @EffectiveDate varchar(10), @mySKU varchar(20), @myVendorNo bigint, @myCOO varchar(10)
		, @myTotalCost decimal(18,6), @myDisplayerCost decimal(18,6), @myFieldName varchar(50), @myFieldValue varchar(50)
		, @DeptNo varchar(5), @VendorNumber varchar(20), @VendorName varchar(200), @DontSendToRMS bit, @apos char(1)
		, @procUserID int, @BatchType as int, @Metadata_Column_ID int, @Track_History bit
		
Set @procUserID = -3	-- Flag in Item master that this record was changed / inserted by the Message process
		
SET @Error = 0
set @IntErrorMsg = ''
set @apos = char(39)

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
FROM SPD_Environment
WHERE Server_Name = @@SERVERNAME AND Database_Name = DB_NAME()


IF @SPEDYEnvVars_SPD_Email_BCCAddress is NULL
	SET @SPEDYEnvVars_SPD_Email_BCCAddress = 'spedyerror@novalibra.com'

select @DeptNo = 'n/a', @VendorNumber = 'n/a', @VendorName = 'n/a'
Select @DeptNo = convert(varchar(5), Fineline_Dept_ID)
	, @VendorNumber = convert(varchar(20), Vendor_Number)
	, @VendorName = Vendor_Name
	,@BatchType = Batch_Type_ID
From SPD_Batch
Where ID = @Batch_ID 

IF @BatchType = 3
BEGIN
	--Set Workflow Stages for Vendor Relation Batches
	select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 6 and Stage_Type_id = 4
	select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 6 and Stage_Type_id = 3
	select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 6 and Stage_Type_id = 8
END
--Change as a part Of Trilingual Completion Error 
--If @BatchType = 5 
Else If @BatchType = 5 
--Change as a part Of Trilingual Completion Error 
BEGIN
	--Set Workflow Stages for Vendor Relation Batches
	select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 7 and Stage_Type_id = 4
	select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 7 and Stage_Type_id = 3
	select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 7 and Stage_Type_id = 6
END
ELSE
BEGIN

	If @BatchType = 4 
	BEGIN
		--Set Workflow Stages for Translation Batches
		select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 5 and Stage_Type_id = 4
		select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 5 and Stage_Type_id = 3
		select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 5 and Stage_Type_id = 6
	END
	ELSE
	BEGIN
		--Set Workflow Stages for Item Maintenances Batches
		select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 4
		select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 3
		select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 6
	END
END

-- *************************************************************************************************************************************************
-- Handle Complete Batch Process
-- *************************************************************************************************************************************************
if @cmd = 'C'
BEGIN
	-- Get list of change records to Update Item master with
	Declare @Table varchar(50), @Column varchar(50), @Type varchar(50), @Length int, @NewValue varchar(max)
	Declare @SKU varchar(20), @VendorNo bigint, @Precision varchar(50)
	Declare @sql varchar(max)

	SET @Error = 0

	Declare ChangeRecs Cursor FOR
		SELECT 
			M.[View_To_TableName]
			, M.[View_To_ColumnName]
			, M.[Column_Generic_Type]
			, M.[Max_Length]
			, M.[SQLPrecision]
			, C.Field_Value
			, I.Michaels_SKU
			, I.Vendor_Number
			, Coalesce(C.Dont_Send_To_RMS,0)
			, M.ID as Metadata_Column_ID
			, isNull(M.Track_History,0) as Track_History
		FROM [SPD_Metadata_Column] M
			Join SPD_Item_Master_Changes C	ON M.[Column_Name] = C.Field_Name
			Join SPD_Item_Maint_Items I		ON C.Item_Maint_Items_ID = I.ID
		WHERE M.[Metadata_Table_ID]=11	-- ItemMaint view Only
			and M.[Update_Item_Master] = 1
			and M.[View_To_TableName] is not null
			and M.[View_To_ColumnName] is not null
			and I.Batch_ID = @Batch_ID
				
	OPEN ChangeRecs
	FETCH NEXT FROM ChangeRecs INTO @Table, @Column, @Type, @Length, @Precision, @NewValue, @SKU, @VendorNo, @DontSendToRMS, @Metadata_Column_ID, @Track_History

	set @temp = ' Processing Change Records for Batch: ' + convert(varchar(20),@Batch_ID)
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

	BEGIN TRAN
	WHILE @@FETCH_STATUS = 0 AND @Error = 0
	BEGIN
		-- If DontSentToRMS = 1 that means the field is functionally equivelent to the Item Master (Treat Empty as Zero).  Do not save change
		IF @DontSendToRMS = 0	-- Update IM with this field.  
		BEGIN
			if @Column like '%GTIN%'
			begin
				if not exists(select 'x' from SPD_Item_Master_GTINs where Michaels_SKU = @SKU)
					insert SPD_Item_Master_GTINs ([Michaels_SKU], [InnerGTIN], [CaseGTIN], [Is_Active], [Created_User_Id], [Date_created], [Update_User_Id], [Date_Last_modified])
					values (@SKU, '', '', 1, 3, getdate(), 3, getdate())
			end


			--track history
			If @Track_History = 1
			BEGIN
				Set @sql = '
					Insert into SPD_Change_Field_History
					(Michaels_SKU, Batch_ID, Metadata_Column_ID, Old_Value, New_Value)
					Select ''' + @SKU + ''',' + convert(varchar,@Batch_ID) + ',' + convert(varchar, @Metadata_Column_ID) + ',
				'
				+ 
					'(Select ' + @Column + ' from ' + @Table + ' WHERE Michaels_SKU = ''' + @SKU + ''''
					+ CASE WHEN @Table = 'SPD_Item_Master_Vendor' 
							THEN ' and Vendor_Number = ' + convert(varchar(20),@VendorNo) 
							ELSE '' 
					END
				+ ') , ''' +	convert(varchar,@NewValue) + '''
					where not exists 
					(
						Select 1 from SPD_Change_Field_History SCFH
						where SCFH.Michaels_SKU = ''' + @SKU + '''
						and SCFH.Batch_ID =' + convert(varchar,@Batch_ID) + '
						and SCFH.Metadata_Column_ID = ' + convert(varchar, @Metadata_Column_ID) + '
					)
					and ''' +	convert(varchar,@NewValue) + ''' <> isNull((Select isnull(' + @Column + ','''') from ' + @Table + ' WHERE Michaels_SKU = ''' + @SKU + ''''
					+ CASE WHEN @Table = 'SPD_Item_Master_Vendor' 
							THEN ' and Vendor_Number = ' + convert(varchar(20),@VendorNo) 
							ELSE '' 
					END
				+ '),'''')
				'
				if @debug=1 
				BEGIN
					print @sql
				END
				ELSE
				BEGIN
					exec (@Sql)
				END
				
			END


			SET @sql = 'Update ' + @Table + ' SET ' + @Column + ' = '
				+ CASE WHEN @Type = 'varchar' 
						THEN '''' + Replace(@NewValue, @apos, @apos+@apos) + ''''		-- escape any apostrophes
						ELSE CASE WHEN NULLIF(@NewValue,'') is NULL 
								THEN 'NULL' 
								ELSE 'convert(' + @Type + Coalesce(@Precision,'') + ',''' + @NewValue + ''')' 
							 END
				  END
				+ ', Date_Last_Modified = getdate() '  
				+ ' WHERE Michaels_SKU = ''' + @SKU + '''' 
				+ CASE WHEN @Table = 'SPD_Item_Master_Vendor' 
							THEN ' and Vendor_Number = ' + convert(varchar(20),@VendorNo) 
							ELSE '' 
				  END
				  
			if @debug=1 print @sql
			BEGIN TRY
				EXEC (@sql)
				IF @@Rowcount = 0 	-- Update failed but no SQL error
				BEGIN
					ROLLBACK TRAN -- Save no Changes if error
					set @IntErrorMsg = 'Update failed but no SQL Proc error occured. SQL Stmt that failed: ' + @sql
					Set @Error = 1	
				END
			END TRY
			BEGIN CATCH
				ROLLBACK TRAN -- Save no Changes if error
				set @IntErrorMsg = ERROR_MESSAGE() + '   SQL Command: ' + @sql
				Set @Error = 1	
			END CATCH

		END
		IF @Error = 0
		BEGIN
			FETCH NEXT FROM ChangeRecs INTO @Table, @Column, @Type, @Length, @Precision, @NewValue, @SKU, @VendorNo, @DontSendToRMS,@Metadata_Column_ID, @Track_History
		END
	END
	Close ChangeRecs
	DEALLOCATE ChangeRecs
	
	IF @Error = 0	-- Commit previous trans 
	BEGIN
		COMMIT TRAN
	END
	
	-- ***************************************************************************************************************
	-- NAK 10/2/2012:  Update Multilingual Fields - pt 1
	-- **************************************************************************************************************
	Declare ChangeRecs Cursor FOR
		SELECT M.Column_Name
			, C.Field_Value
			, I.Michaels_SKU
			, I.Vendor_Number
			, Coalesce(C.Dont_Send_To_RMS,0)
		FROM [SPD_Metadata_Column] M
			Join SPD_Item_Master_Changes C	ON M.[Column_Name] = C.Field_Name
			Join SPD_Item_Maint_Items I		ON C.Item_Maint_Items_ID = I.ID
		WHERE M.[Metadata_Table_ID]=11	-- ItemMaint view Only
			AND M.Column_Name in ('TIEnglish','TIFrench','TISpanish','EnglishShortDescription','EnglishLongDescription')
			and I.Batch_ID = @Batch_ID
				
	OPEN ChangeRecs
	FETCH NEXT FROM ChangeRecs INTO @Column, @NewValue, @SKU, @VendorNo, @DontSendToRMS

	set @temp = ' Processing Multilingual Change Records pt 1 for Batch: ' + convert(varchar(20),@Batch_ID)
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

	BEGIN TRAN
	WHILE @@FETCH_STATUS = 0 AND @Error = 0
	BEGIN
		-- If DontSentToRMS = 1 that means the field is functionally equivelent to the Item Master (Treat Empty as Zero).  Do not save change
		IF @DontSendToRMS = 0	-- Update IM with this field.  
		BEGIN
			DECLARE @LanguageTypeID as integer

			SELECT @LanguageTypeID = CASE WHEN @Column in ('TIEnglish', 'EnglishShortDescription', 'EnglishLongDescription') THEN 1
										 WHEN @Column in ('TIFrench') THEN 2
										 WHEN @Column in ('TISpanish') THEN 3 END
										 
			IF Exists(Select * FROM SPD_Item_Master_Languages
						WHERE Michaels_SKU = @SKU AND Language_Type_ID = @LanguageTypeID)
			BEGIN
				--UPDATE
				
				SET @sql = 'UPDATE SPD_Item_Master_Languages SET ' + 
					CASE WHEN @Column in ('TIEnglish', 'TIFrench', 'TISpanish') THEN ' Translation_Indicator '
						 WHEN @Column like '%ShortDescription' THEN ' Description_Short '
						 WHEN @Column like '%LongDescription' THEN ' Description_Long ' END 
					 + ' = ' + 
					 '''' + Replace(@NewValue, @apos, @apos+@apos) + '''' +		-- escape any apostrophes
					 '' + CASE WHEN @Column in ('TIFrench','TISpanish') AND @NewValue = 'Y' THEN ', Date_Requested= getDate() '  Else '' END + 
					 ' , Date_Last_Modified = getdate() WHERE Michaels_SKU = ''' + @SKU + ''' AND Language_type_ID = ' + CAST(@LanguageTypeID as varchar(10))
					 
			END	 
			ELSE
			BEGIN
				--INSERT
				SET @sql = 'INSERT Into SPD_Item_Master_Languages (Michaels_SKU, Language_Type_ID, Translation_Indicator, Description_Short, Description_Long, Date_Requested, Created_User_ID, Date_Created, Modified_User_Id, Date_Last_Modified) ' + 
						' VALUES (''' + @SKU + ''', ' + 
									CAST(@LanguageTypeID as varchar(10)) + ', ' + 
									CASE WHEN @Column in ('TIEnglish', 'TIFrench', 'TISpanish') THEN '''' + @NewValue + '''' ELSE '''''' END + ', ' + 
									CASE WHEN @Column like '%ShortDescription' THEN '''' + Replace(@NewValue, @apos, @apos+@apos) + '''' ELSE '''''' END + ', ' + 
									CASE WHEN @Column like '%LongDescription' THEN '''' + Replace(@NewValue, @apos, @apos+@apos) + '''' ELSE '''''' END + ', ' + 
									' getDate(), 0, getDate(), 0, getDate())'
			END
		
			if @debug=1 print @sql
			BEGIN TRY
				EXEC (@sql)
				IF @@Rowcount = 0 	-- Update failed but no SQL error
				BEGIN
					ROLLBACK TRAN -- Save no Changes if error
					set @IntErrorMsg = 'Update failed but no SQL Proc error occured. SQL Stmt that failed: ' + @sql
					Set @Error = 1	
				END
			END TRY
			BEGIN CATCH
				ROLLBACK TRAN -- Save no Changes if error
				set @IntErrorMsg = ERROR_MESSAGE() + '   SQL Command: ' + @sql
				Set @Error = 1	
			END CATCH
			
		END
		IF @Error = 0
		BEGIN
			FETCH NEXT FROM ChangeRecs INTO @Column, @NewValue, @SKU, @VendorNo, @DontSendToRMS
		END
	END
	Close ChangeRecs
	DEALLOCATE ChangeRecs

	IF @Error = 0	-- Commit previous trans 
	BEGIN
		COMMIT TRAN
	END
	
	--END OF TRILINGUAL pt 1
	
	-- ***************************************************************************************************************
	-- KH 2/21/2013:  Update Multilingual Fields - pt 2
	-- **************************************************************************************************************
	
	Declare ChangeRecs Cursor FOR
		SELECT M.Column_Name
			, C.Field_Value
			, I.Michaels_SKU
			, I.Vendor_Number
			, Coalesce(C.Dont_Send_To_RMS,0)
		FROM [SPD_Metadata_Column] M
			Join SPD_Item_Master_Changes C	ON M.[Column_Name] = C.Field_Name
			Join SPD_Item_Maint_Items I		ON C.Item_Maint_Items_ID = I.ID
		WHERE M.[Metadata_Table_ID]=11	-- ItemMaint view Only
			AND M.Column_Name in ('PLIEnglish','PLIFrench','PLISpanish', 'ExemptEndDateFrench')
			and I.Batch_ID = @Batch_ID
			
	OPEN ChangeRecs
	FETCH NEXT FROM ChangeRecs INTO @Column, @NewValue, @SKU, @VendorNo, @DontSendToRMS

	set @temp = ' Processing Multilingual Change Records pt 2 for Batch: ' + convert(varchar(20),@Batch_ID)
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

	BEGIN TRAN
	WHILE @@FETCH_STATUS = 0 AND @Error = 0
	BEGIN
		-- If DontSentToRMS = 1 that means the field is functionally equivelent to the Item Master (Treat Empty as Zero).  Do not save change
		IF @DontSendToRMS = 0	-- Update IM with this field.  
		BEGIN

			DECLARE @DBColumnName as varchar(70)
			SELECT  @DBColumnName = CASE WHEN @Column like 'PLI%' Then 'Package_Language_Indicator'
									     WHEN @Column like 'ExemptEndDate%' Then 'Exempt_End_Date' END
			
			SELECT @LanguageTypeID = CASE WHEN @Column in ('PLIEnglish') THEN 1
										 WHEN @Column in ('PLIFrench') THEN 2
										 WHEN @Column in ('PLISpanish') THEN 3 
										 WHEN @Column in ('ExemptEndDateFrench') Then 2 END
										 										 
			IF Exists(Select * FROM SPD_Item_Master_Languages_Supplier
						WHERE Michaels_SKU = @SKU AND Vendor_Number = @VendorNo AND Language_Type_ID = @LanguageTypeID)
			BEGIN
				--UPDATE
				
						
				SET @sql = 'UPDATE SPD_Item_Master_Languages_Supplier SET ' + @DBColumnName + ' = ' + 
					 '''' + Replace(@NewValue, @apos, @apos+@apos) + '''' +		-- escape any apostrophes
					 ' , Date_Last_Modified = getdate() WHERE Michaels_SKU = ''' + @SKU + ''' AND Vendor_Number = ' + CAST(@VendorNo as varchar(20)) + ' AND Language_type_ID = ' + CAST(@LanguageTypeID as varchar(10))
					 
			END	 
			ELSE
			BEGIN
				--INSERT
				SET @sql = 'INSERT Into SPD_Item_Master_Languages_Supplier (Michaels_SKU, Vendor_Number, Language_Type_ID, ' + @DBColumnName + ', Created_User_ID, Date_Created, Modified_User_Id, Date_Last_Modified) ' + 
						' VALUES (''' + @SKU + ''', ' + CAST(@VendorNo as varchar(20)) + ', ' +
									CAST(@LanguageTypeID as varchar(10)) + ', ''' + Replace(@NewValue, @apos, @apos+@apos) + ''', 0, getDate(), 0, getDate())'
			END
			
			if @debug=1 print @sql
			BEGIN TRY
				EXEC (@sql)
				IF @@Rowcount = 0 	-- Update failed but no SQL error
				BEGIN
					ROLLBACK TRAN -- Save no Changes if error
					set @IntErrorMsg = 'Update failed but no SQL Proc error occured. SQL Stmt that failed: ' + @sql
					Set @Error = 1	
				END
			END TRY
			BEGIN CATCH
				ROLLBACK TRAN -- Save no Changes if error
				set @IntErrorMsg = ERROR_MESSAGE() + '   SQL Command: ' + @sql
				Set @Error = 1	
			END CATCH
			
			--Reset Multilingual Date_Requested flag for any SKUs in the Batch 
			-- that have a YES for the French/Spanish Translation Indicator
			Update SPD_Item_Master_Languages
			Set Date_Requested = getDate()
			WHERE Translation_Indicator = 'Y' AND Language_Type_ID in (2,3) AND Michaels_SKU in (Select Michaels_SKU From SPD_Item_Maint_Items WHERE Batch_ID = @Batch_ID)
			
		END
		IF @Error = 0
		BEGIN
			FETCH NEXT FROM ChangeRecs INTO @Column, @NewValue, @SKU, @VendorNo, @DontSendToRMS
		END
	END
	Close ChangeRecs
	DEALLOCATE ChangeRecs
	
	--END OF TRILINGUAL PT 2

	IF @Error = 0	-- Commit previous trans 
	BEGIN
		COMMIT TRAN
	END
	
		
	IF @Error = 0
	BEGIN
		-- *************************************************************************************************************************************************
		-- Scan to see if any Cost Batches were sent.  If so Update the Item_Master_Country_Costs Table because RMS does not send back a message for this
		-- *************************************************************************************************************************************************
		SELECT @EffectiveDate = Convert(varchar(10),Effective_Date,101)
		FROM SPD_Batch WHERE ID = @Batch_ID

		IF Exists(
			SELECT Batch_ID
			FROM [SPD_Item_Maint_MQMessageTracking]
			WHERE Batch_ID = @Batch_ID	-- Matching Batch
				and Message_ID like 'C.%' -- That's a cost Change
				and Status_ID = 2 -- and its complete
			)
		BEGIN	-- Add a record to the country cost table
		
			Set @temp = ' Processing Cost Records for Batch: ' + convert(varchar(20),@Batch_ID)
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp
			
			Declare CostCursor Cursor FOR
				SELECT		-- Costs same for each country in a SKU/Vendor record
					I.ID 
					, I.Michaels_SKU
					, I.Vendor_Number
				FROM [SPD_Item_Maint_MQMessageTracking] T
					join SPD_Item_Maint_Items I	ON I.ID = T.Item_ID
					--join dbo.SPD_Item_Master_Vendor_Countries C ON I.Michaels_SKU = C.Michaels_SKU
					--												and I.Vendor_Number = C.Vendor_Number
					--												and C.Primary_Indicator = 1 -- Primary country only
				WHERE T.Batch_ID = @Batch_ID	-- Matching Batch
					and T.Message_ID like 'C.%' -- That's a cost Change
					and T.Status_ID = 2			-- and its complete
					
			Open CostCursor
			FETCH NEXT FROM CostCursor INTO @myID, @mySKU, @myVendorNo		
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @myDisplayerCost = DisplayerCost
					, @myTotalCost = TotalCost
				FROM  dbo.[udf_SPD_GetCosts](@mySKU, @myVendorNo, @myID)		-- get flamerged values from Change recs / Item Master
				
				UPDATE SPD_Item_Master_Vendor_Country_Cost
					SET Future_Cost = convert(money,@myTotalCost) 
						, Future_Displayer_Cost = @myDisplayerCost
						, Date_Last_Modified = getdate()
				WHERE Michaels_SKU = @mySKU 
					and Vendor_Number = @myVendorNo 
					and convert(varchar(20),Effective_Date,101) = @EffectiveDate

				INSERT  SPD_Item_Master_Vendor_Country_Cost (
					[Michaels_SKU] ,[Vendor_Number] ,[Country_Of_Origin] ,[Effective_Date] ,[Future_Cost] ,[Future_Displayer_Cost] ,[Date_Created] 
					)
				SELECT @mySKU, @myVendorNo, C.Country_Of_Origin, @EffectiveDate, @myTotalCost, @myDisplayerCost, getdate()
				FROM SPD_Item_Master_Vendor_Countries  C
					left join SPD_Item_Master_Vendor_Country_Cost Cost	ON C.[Michaels_SKU] = Cost.[Michaels_SKU]
						and C.[Vendor_Number] = Cost.[Vendor_Number]
						and C.Country_Of_Origin = Cost.Country_Of_Origin
						and convert(varchar(20),Cost.[Effective_Date],101) = @EffectiveDate
				WHERE C.[Michaels_SKU] = @mySKU
					and C.[Vendor_Number] = @myVendorNo
					and Cost.[Future_Cost] is NULL
						
				FETCH NEXT FROM CostCursor INTO @myID, @mySKU, @myVendorNo	
			END
			CLOSE CostCursor;
			DEALLOCATE CostCursor;
		END
		
		-- *************************************************************************************************************************************************
		-- Scan to see if any Future Cost Cancel Batches were sent.  If so Delete the record from the Future Costs table
		-- *************************************************************************************************************************************************
		-- See if any Future Cost cancel messages received.  
		-- Need to get the saved effective date from the tracking table
		IF Exists(
			SELECT Batch_ID
			FROM [SPD_Item_Maint_MQMessageTracking]
			WHERE Batch_ID = @Batch_ID	-- Matching Batch
				and Message_ID like 'F.%' -- That's a Future Cost Cancel
				and Status_ID = 2 -- and its complete
			)
		BEGIN
			DELETE Cost 
			FROM [SPD_Item_Maint_MQMessageTracking] T
				join SPD_Item_Maint_Items I						ON I.ID = T.Item_ID
				join SPD_Item_Master_Vendor_Country_Cost Cost	ON I.Michaels_SKU = Cost.Michaels_SKU
																	and I.Vendor_Number = Cost.Vendor_Number		-- all country records that match
																	and convert(varchar(20),T.Effective_Date,101) = convert(varchar(20),Cost.Effective_Date,101)
			WHERE T.Batch_ID = @Batch_ID	-- Matching Batch
				and T.Message_ID like 'F.%' -- That's a cost Change
				and T.Status_ID = 2			-- and it's complete
			--IF @@RowCount > 0
			--BEGIN
			--	-- Send the updated Import Burden
			--END
		END		
	END
	
	-- *************************************************************************************************************************************************
	-- Process Batch Complete Logic
	-- *************************************************************************************************************************************************
	IF @Error = 0
	BEGIN
		-- All changes processed.  Mark Batch as Complete if the batch is at the waiting for confirmation stage

		Select @WorkflowStageID = Workflow_Stage_ID
		From SPD_Batch
		WHERE ID = @Batch_ID
		
		IF @WorkflowStageID = @STAGE_WAITINGFORSKU or @WorkflowStageID = @STAGE_COMPLETED
		BEGIN

			-- Update the Batch to Completed (again if nec)
			if @debug=1 print 'Marking Batch as complete...'
			set @temp = ' Batch: ' + convert(varchar(20),@Batch_ID) + ' Being Marked as Complete'
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

			Update SPD_Batch
				SET Workflow_Stage_ID = @STAGE_COMPLETED
					, Is_Valid = 1
					, date_modified = getdate()
					, modified_user = @procUserID
			WHERE ID = @Batch_ID
			
			-- Delete all the change records (gulp)
			
			if @debug=1 print 'Deleting Change Records...'
			exec usp_SPD_ItemMaint_DeleteChangeRecsForBatch @batchID = @Batch_ID, @UserID = @procUserID
			--DELETE FROM SPD_Item_Master_Changes 
			--WHERE Item_Maint_Items_ID in (
			--	Select ID
			--	From SPD_Item_Maint_Items 
			--	WHERE Batch_ID = @Batch_ID )
			
			-- Update Batch History and send email ONLY IF this is the first time the Batch is completed
			IF ( @WorkflowStageID <> @STAGE_COMPLETED )
			BEGIN
				if @debug=1 print 'Updating Batch History...'
				
				INSERT INTO SPD_Batch_History (
				SPD_Batch_ID,
				Workflow_Stage_ID,
				[Action],
				Date_Modified,
				Modified_User,
				Notes 
				) 
				VALUES (
				@Batch_ID,
				@STAGE_WAITINGFORSKU,
				'Complete',
				getdate(),
				@procUserID,
				'All Changes have been confirmed and applied to Item Master. Batch Marked as Complete.'
				)
				
				--Update SPD_Batch_History_Stage_Durations table with End Date for "Waiting" stage
				Update SPD_Batch_History_Stage_Durations
				Set End_Date = getDate(), [Hours]=dbo.BDATEDIFF_BUSINESS_HOURS([Start_Date], getDate(), DEFAULT, DEFAULT)
				Where Batch_ID = @Batch_ID And Stage_ID = @STAGE_WAITINGFORSKU and End_Date is null
      

				if @debug=1 print 'Sending Email...'
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Sending Item Maint Completed Email Messages'
				
				-- Send Completed Email
				SET @MichaelsEmailRecipients = NULL
				SET @EmailRecipients = NULL

				-- Error emails only go to the DBC 			          
				if @debug=1 print '   Getting Email Addresses...'
				SELECT @MichaelsEmailRecipients = COALESCE(@MichaelsEmailRecipients + '; ', '') + su.Email_Address
				FROM SPD_Batch_History bh
					INNER JOIN Security_User su ON su.ID = bh.modified_user
				WHERE IsNumeric(bh.modified_user) = 1 
				  AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
				  AND SPD_Batch_ID = @Batch_ID
				  AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) > 0
				GROUP BY su.Email_Address
				
				if @debug=1 print '   Getting Email Addresses non Michaels...'
				SELECT @EmailRecipients = COALESCE(@EmailRecipients + '; ', '') + su.Email_Address
				FROM SPD_Batch_History bh
					INNER JOIN Security_User su ON su.ID = bh.modified_user
				WHERE IsNumeric(bh.modified_user) = 1 
				  AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
				  AND SPD_Batch_ID = @Batch_ID
				  AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) = 0
				GROUP BY su.Email_Address

				SELECT @SPEDYBatchGUID = [GUID] FROM SPD_Batch WHERE ID = @Batch_ID

				IF NULLIF(@MichaelsEmailRecipients,'') is NULL AND NULLIF(@EmailRecipients,'') is NULL
					SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_BCCAddress
					
				if @debug=1 print '   Reset Emails for test?...' + convert(varchar,@SPEDYEnvVars_Test_Mode)
				
				Declare @SavedEmails varchar(max)
				Set @SavedEmails  = ''
				
				IF (@SPEDYEnvVars_Test_Mode = 1)
				BEGIN
					if @debug=1 print 'Setting EMAIL TO TEST USERS... found users were: ' + @MichaelsEmailRecipients + ' - ' + @EmailRecipients
					SET @SavedEmails = @MichaelsEmailRecipients + ' :: ' + @EmailRecipients
					SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
					SET @EmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
				END

				-- FJL July 2010 - Get more info for the subject line per IS Req F47
				
				if @debug=1 print '   Get batch info for batch: ' + convert(varchar,@Batch_ID)
				--NAK 5/20/2013:  Construct Email subject, but don't include Department or Vendor if there isn't one associated with the batch (i.e. Trilingual Maintenance Translation Batches)
				SET @EmailSubject = 'SPEDY Item Maintenance Batch Complete.' 
				IF COALESCE(@DeptNo,'0') <> '0' AND COALESCE(convert(varchar(20),@VendorNumber), '0') <> '0' 
				BEGIN
					SET @EmailSubject = @EmailSubject + ' D: ' + COALESCE(@DeptNo, '') + ' ' + COALESCE(convert(varchar(20),@VendorNumber), '') + '-' + COALESCE(@VendorName, '') + '.'
				END
				SET @EmailSubject =  @EmailSubject + ' Log ID#: ' +  convert(varchar,@Batch_ID)

				-- *** Michaels Email
				if @debug=1 print '   Set Email Body'
				SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
					+ '  Congratulations!</p><p>Next Steps:<ul type="square" style="padding-top: 0; margin-top: 0;">'
					-- + '<li><a href="' + @SPEDYEnvVars_SPD_Root_URL + '/batchexport.aspx?guid=' + @SPEDYBatchGUID + '">Download the completed batch to Excel</a></li>'
					+ '<li><a href="' + COALESCE(@SPEDYEnvVars_SPD_Root_URL,'') + '">Login to SPEDY to review this batch.</a></li>'
					+ '</ul></p></font>'

				set @IntErrorMsg = 'TestMode = ' + coalesce(convert(varchar,@SPEDYEnvVars_Test_Mode),'NULL' )
					+ ' :: Email addresses: Vendor-' + coalesce(@EmailRecipients,'NULL') 
					+ ' :: Michaels-' + coalesce(@MichaelsEmailRecipients,'NULL')
					+ ' :: CC-' + coalesce(@SPEDYEnvVars_SPD_Email_CCAddress,'NULL') 
					+ ' :: BCC-' + coalesce(@SPEDYEnvVars_SPD_Email_BCCAddress,'NULL')
					+ ' :: Saved Emails (test mode on)-' + coalesce(@SavedEmails,'NULL')
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@IntErrorMsg
				
				if @debug=1 print '   Send Email EXEC '
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
				BEGIN	-- *** Send Vendor Email ***
					SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
					+ '  Congratulations!</p><p>Next Steps:<ul type="square" style="padding-top: 0; margin-top: 0;">'
					--+ '<li><a href="' + @SPEDYEnvVars_SPD_Vendor_URL + '/batchexport.aspx?guid=' + @SPEDYBatchGUID + '">Download the completed batch to Excel</a></li>'
					+ '<li><a href="' + @SPEDYEnvVars_SPD_Vendor_URL + '">Login to SPEDY to review this batch.</a></li>'
					+ '</ul></p></font>'
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
				ELSE	
				BEGIN	-- Testing only. Send what the Vendor Email would look like
					SET @EmailBody = '<font face="Arial" size="2"><p>V E N D O R &nbsp;&nbsp;&nbsp; E M A I L</p><p>' + @EmailSubject 
					+ '  Congratulations!</p><p>Next Steps:<ul type="square" style="padding-top: 0; margin-top: 0;">'
					--+ '<li><a href="' + @SPEDYEnvVars_SPD_Vendor_URL + '/batchexport.aspx?guid=' + @SPEDYBatchGUID + '">Download the completed batch to Excel</a></li>'
					+ '<li><a href="' + @SPEDYEnvVars_SPD_Vendor_URL + '">Login to SPEDY to review this batch.</a></li>'
					+ '<li>Email List: ' + COalesce(@SavedEmails,'') + '</li>'
					+ '</ul></p></font>'
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
		END		-- Batch Stage Check
		ELSE
		BEGIN
			INSERT INTO SPD_Batch_History (
			SPD_Batch_ID,
			Workflow_Stage_ID,
			[Action],
			Date_Modified,
			Modified_User,
			Notes 
			) 
			VALUES (
			@Batch_ID,
			@WorkflowStageID,
			'System Activity',
			getdate(),
			@procUserID,
			'All Batch Messages received, But Batch was not at the Confirmation Stage. Contact Nova Libra.'
			)
		
			Set @Error = 2
			Set @IntErrorMsg = 'Batch Has received Confirmations for all Changes but was not at the correct stage to complete. Currently at Stage: ' + convert(varchar(20),@WorkflowStageID)
		END
	END -- Process Error 0 return code
	
	If @Error <> 0	-- Ran into an error during Change Rec processing.  Log it in the Batch and send an email error
	BEGIN
		if @debug=1 print '   *** Processing Change Record ISSUE...'

		set @Temp = '* * * ERROR OCCURRED * * *  on Batch End Process: ' + @IntErrorMsg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@Temp
		
		Select @WorkflowStageID = Workflow_Stage_ID
		From SPD_Batch
		WHERE ID = @Batch_ID

		If @Error = 1
		BEGIN
			INSERT INTO SPD_Batch_History (
			  SPD_Batch_ID,
			  Workflow_Stage_ID,
			  [Action],
			  Date_Modified,
			  Modified_User,
			  Notes
			)
			VALUES (
			  @Batch_ID,
			  @WorkflowStageID,
			  'System Activity',
			  getdate(),
			  @procUserID,
			  'Error occurred processing the SPEDY Only Change Records for batch. Contact Nova Libra.'
			)
		END
        SET @MichaelsEmailRecipients = NULL

        SELECT @MichaelsEmailRecipients = COALESCE(@MichaelsEmailRecipients + '; ', '') + su.Email_Address
        FROM SPD_Batch_History bh
			INNER JOIN Security_User su ON su.ID = bh.modified_user
        WHERE IsNumeric(bh.modified_user) = 1 
          AND bh.workflow_stage_id = @STAGE_DBC
          AND LOWER(bh.[action]) = 'approve'
          AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
          AND SPD_Batch_ID = @Batch_ID
          AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) > 0
		  --AND sg.Group_Name = 'DBC/QA'
        GROUP BY su.Email_Address

		IF NULLIF(@MichaelsEmailRecipients,'') is NULL --AND NULLIF(@EmailRecipients,'') is NULL
			SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_BCCAddress

        IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
        
        SET @EmailSubject = 'SPEDY had an internal SQL Error Or Stage Error for Item Maintenance Batch ' + CONVERT(varchar(20), COALESCE(@Batch_ID, '')) + '.'
        IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
        
        -- *** Michaels Email
        SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
			+ 'Error occurred while processing the SPEDY Only change records for the batch.</p>'
			+ '<p><b>Batch:</b> ' + CONVERT(varchar(20), @Batch_ID) + '</p>'
			+ '<p><b>Dept:</b> ' + COALESCE(@DeptNo,'') + '</p>'
			+ '<p><b>Vendor #:</b> ' + COALESCE(@VendorNumber,'') + '</p>'
			+ '<p><b>Vendor Name:</b> ' + COALESCE(@VendorName,'') + '</p>'
			+ '<p><b>Error Message:</b><br />&nbsp;&nbsp;&nbsp;' + @IntErrorMsg + '</p></font>'  
			
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
	END
END	-- Command C

-- ***************************************************************************************************************

IF @cmd = 'E'	-- Error Occurred
BEGIN
	Declare @stageMessage varchar(1000)
	set @stageMessage = ''
	
	if @debug=1 print 'Processing Error Message...'
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=' Processing Error Message...'

	Select @WorkflowStageID = Workflow_Stage_ID
	From SPD_Batch
	WHERE ID = @Batch_ID

	-- Update the Batch to DBC stage (again if nec)
    INSERT INTO SPD_Batch_History (
      SPD_Batch_ID,
      Workflow_Stage_ID,
      [Action],
      Date_Modified,
      Modified_User,
      Notes
    )
    VALUES (
      @Batch_ID,
      @WorkflowStageID,
      'System Activity',
      getdate(),
      @procUserID,
      'Error response received from RMS.<br><b>SKU:</b> ' + @ErrorSKU + '<br><b>Error Text:</b> ' + @Msg
    )

    IF ( @WorkflowStageID <> @STAGE_COMPLETED)
    BEGIN
		if @debug=1 print 'Updating Batch History since stage is not completed...'
    
		INSERT INTO SPD_Batch_History (
			SPD_Batch_ID,
			Workflow_Stage_ID,
			[Action],
			Date_Modified,
			Modified_User,
			Notes
		)
		VALUES (
			@Batch_ID,
			@STAGE_WAITINGFORSKU,
			'System Activity',
			getdate(),
			@procUserID,
			'Sending batch back to previous stage because of error message received from RMS.'
		)
		Update SPD_Batch
			SET Workflow_Stage_ID = @STAGE_DBC
				, Is_Valid = -1
				, date_modified = getdate()
				, modified_user = @procUserID
		WHERE ID = @Batch_ID
	END
	ELSE
		set @stageMessage = ' *** PLEASE NOTE ***  Batch was marked completed.  This needs to be investigated.'
		
	if @debug=1 print '   *** Sending Error Message email...'
	-- Send EMAIL
    SET @MichaelsEmailRecipients = NULL

    SELECT @MichaelsEmailRecipients = COALESCE(@MichaelsEmailRecipients + '; ', '') + su.Email_Address
    FROM SPD_Batch_History bh
		INNER JOIN Security_User su ON su.ID = bh.modified_user
		--INNER JOIN Security_User_Group sug ON sug.[User_ID] = su.[ID]
		--INNER JOIN Security_Group sg ON sug.Group_ID = sg.[ID]
    WHERE IsNumeric(bh.modified_user) = 1 
      AND bh.workflow_stage_id = @STAGE_DBC
      AND LOWER(bh.[action]) = 'approve'
      AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
      AND SPD_Batch_ID = @Batch_ID
      AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) > 0
	  --AND sg.Group_Name = 'DBC/QA'
    GROUP BY su.Email_Address

	IF NULLIF(@MichaelsEmailRecipients,'') is NULL --AND NULLIF(@EmailRecipients,'') is NULL
		SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_BCCAddress

    IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

    SET @EmailSubject = 'SPEDY has received an RMS Error for Item Maintenance Batch ' + CONVERT(varchar(20), COALESCE(@Batch_ID, '')) + '.'
    IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
    
    -- *** Michaels Email
    SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
		+ '&nbsp;&nbsp;Please view the provided Error Message to resolve this matter.</p>'
		+ '<p><b>Batch:</b> ' + CONVERT(varchar(20), @Batch_ID) + '</p>'
		+ '<p><b>Dept:</b> ' + COALESCE(@DeptNo,'') + '</p>'
		+ '<p><b>Vendor #:</b> ' + COALESCE(@VendorNumber,'') + '</p>'
		+ '<p><b>Vendor Name:</b> ' + COALESCE(@VendorName,'') + '</p>'
		+ '<p><b>Error Message:</b><br />&nbsp;&nbsp;&nbsp;' + COALESCE(@Msg, '') + '</p>'  			
		+ '<p><a href="' + @SPEDYEnvVars_SPD_Root_URL + '">Login to SPEDY</a> to review this batch and correct any errors.</p></font>'
		+ '<p><b>' + @stageMessage + '</b></p>'
		
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

    Set @Error = 0
END	-- Error message 

-- ***************************************************************************************************************

IF @cmd = 'W'	-- Warning Occurred Just send an email to everyone concerned
BEGIN
	if @debug=1 print 'Processing Warning Message...'
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=' Processing Warning Message...'

	Select @WorkflowStageID = Workflow_Stage_ID
	From SPD_Batch
	WHERE ID = @Batch_ID

	-- Update the Batch to DBC stage (again if nec)
    INSERT INTO SPD_Batch_History (
      SPD_Batch_ID,
      Workflow_Stage_ID,
      [Action],
      Date_Modified,
      Modified_User,
      Notes
    )
    VALUES (
      @Batch_ID,
      @WorkflowStageID,
      'System Activity',
      getdate(),
      @procUserID,
      'Warning response received from RMS.<br><b>SKU:</b> ' + @ErrorSKU + '<br><b>Error Text:</b> ' + @Msg
    )

	if @debug=1 print '    *** Sending Warning Message email...'
	-- Send EMAIL
    SET @MichaelsEmailRecipients = NULL

    SELECT @MichaelsEmailRecipients = COALESCE(@MichaelsEmailRecipients + '; ', '') + su.Email_Address
    FROM SPD_Batch_History bh
		INNER JOIN Security_User su ON su.ID = bh.modified_user
    WHERE IsNumeric(bh.modified_user) = 1 
      --AND bh.workflow_stage_id = @STAGE_DBC
      AND LOWER(bh.[action]) = 'approve'
      AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
      AND SPD_Batch_ID = @Batch_ID
      AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) > 0
    GROUP BY su.Email_Address

	IF NULLIF(@MichaelsEmailRecipients,'') is NULL --AND NULLIF(@EmailRecipients,'') is NULL
		SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_BCCAddress

    IF (@SPEDYEnvVars_Test_Mode = 1) SET @Msg = @Msg + '<br />[ Found Recipients: ' + @MichaelsEmailRecipients + '] ' 
    IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

    SET @EmailSubject = 'SPEDY has received an RMS Warning Message for Item Maintenance Batch ' + CONVERT(varchar(20), COALESCE(@Batch_ID, '')) + '.'

    IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
    
    -- *** Michaels Email
    SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
		+ '&nbsp;&nbsp;Please view the provided warning text to resolve this matter.</p>'
		+ '<p><b>Batch:</b> ' + CONVERT(varchar(20), @Batch_ID) + '</p>'
		+ '<p><b>SKU:</b> ' + @ErrorSKU + '</p>'
		+ '<p><b>Dept:</b> ' + COALESCE(@DeptNo,'') + '</p>'
		+ '<p><b>Vendor #:</b> ' + COALESCE(@VendorNumber,'') + '</p>'
		+ '<p><b>Vendor Name:</b> ' + COALESCE(@VendorName,'') + '</p>'
		+ '<p><b>Warning Message:</b><br />&nbsp;&nbsp;&nbsp;' + COALESCE(@Msg, '') + '</p>'  			
		+ '<p><a href="' + @SPEDYEnvVars_SPD_Root_URL + '">Login to SPEDY</a> to review this batch and correct any errors.</p></font>'
		+ '<p><b>This warning does not mean the batch has completed yet. Please wait for the completed email before taking any action on the PO.</b></p>'
--print '@EmailSubject :' + coalesce(@EmailSubject,'NULL')
--print '@batchID :' + coalesce(CONVERT(varchar(20), @Batch_ID),'NULL')
--print '@ErrorSKU :' + coalesce(@ErrorSKU,'NULL')
--print '@DeptNo :' + coalesce(@DeptNo,'NULL')
--print '@VendorNumber :' + coalesce(@VendorNumber,'NULL')
--print '@VendorName :' + coalesce(@VendorName,'NULL')
--print '@Msg :' + coalesce(@Msg,'NULL')
--print '@SPEDYEnvVars_SPD_Root_URL :' + coalesce(@SPEDYEnvVars_SPD_Root_URL,'NULL')
--print 'EMAIL BODY: ' + coalesce(@EmailBody,'NULL Encountered')

		--+ '<p><b>Batch:</b> ' + CONVERT(varchar(20), @Batch_ID) + '</p>'
		--+ '<p><b>SKU:</b> ' + @ErrorSKU + '<br /></p><p><b>Warning Text:</b><br />&nbsp;&nbsp;&nbsp;' 
		--+ COALESCE(@Msg, '') 
		--+ '</p><p><a href="' + @SPEDYEnvVars_SPD_Root_URL + '">Login to SPEDY</a> to review this batch.</p></font>'
    EXEC sp_SQLSMTPMail
        @vcSender = @SPEDYEnvVars_SPD_Email_FromAddress,
        @vcFrom = @SPEDYEnvVars_SPD_Email_FromAddress,
        @vcTo = @MichaelsEmailRecipients,
        @vcCC = @SPEDYEnvVars_SPD_Email_CCAddress,
        @vcBCC = '',		-- No warnings BCC at this time to Nova Libra @SPEDYEnvVars_SPD_Email_BCCAddress,
        @vcSubject = @EmailSubject,
        @vcHTMLBody = @EmailBody,
        @bAutoGenerateTextBody = 1,
        @vcSMTPServer = @SPEDYEnvVars_SPD_SMTP_Server,
        @cDSNOptions = '2',
        @bAuthenticate = @SPEDYEnvVars_SPD_SMTP_Authentication_Required,
        @vcSMTPAuth_UserName = @SPEDYEnvVars_SPD_SMTP_Authentication_User,
        @vcSMTPAuth_UserPassword = @SPEDYEnvVars_SPD_SMTP_Authentication_Password
    Set @Error = 0
END	-- Warning message 

-- ***************************************************************************************************************

IF @cmd = 'S'	-- Proc System Error Occurred Send Email to NL
BEGIN
	Set @Error = 0

    SET @MichaelsEmailRecipients = NULL

    IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
    
    SET @EmailSubject = 'SPEDY had an internal SQL Error Or Stage Error during Message Processing'
    IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
    
    -- *** Michaels Email
    SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
		+ 'Error occurred.</p>'
		+ '<p><b>Error Message:</b><br />&nbsp;&nbsp;&nbsp;' + @msg + '</p></font>'  
    EXEC sp_SQLSMTPMail
        @vcSender = @SPEDYEnvVars_SPD_Email_FromAddress,
        @vcFrom = @SPEDYEnvVars_SPD_Email_FromAddress,
        @vcTo = @SPEDYEnvVars_SPD_Email_BCCAddress,
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


Return @Error
RETURN

END











GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SPD_Report_Modified_Phyto_Fields] 
@startDate datetime = null,
@endDate datetime = null,
@dept int = null,
@vendor bigint = null,
@vendorFilter int = null,
@itemStatus varchar(10) = null,
@sku varchar(10) = null,
@itemGroup varchar(50) = null,
@stockCategory varchar(5) = null,
@itemType int = null
AS

BEGIN

declare @dateNow datetime          
declare @dateNowStr varchar(20)          
declare @month varchar(2), @day varchar(2), @year varchar(4)                    
set @dateNow = getdate()          
set @month = convert(varchar(2), Month(@dateNow))          

if (len(@month) < 2)   
BEGIN
	set @month = '0' + @month           
	set @day = convert(varchar(2), Day(@dateNow)) 
END        

if (len(@day) < 2)             
BEGIN
	set @day = '0' + @day             
	set @year = convert(varchar(4), Year(@dateNow))        
END

if (len(@year) < 4)            
BEGIN
	set @year = '00' + @year           
	set @dateNowStr =  @year + @month + @day                  
END

Select 0 as ID, 
b.id as Batch_Id,   SIMV.Vendor_Number AS VendorNumber,
COALESCE (NULLIF (LTRIM(RTRIM(SIMV.Vendor_Name)), ''),
(SELECT     Vendor_Name
FROM          dbo.SPD_Vendor AS VL
WHERE      (Vendor_Number = SIMV.Vendor_Number)), 'NA') AS VendorName,
CASE b.Batch_Type_ID WHEN 1 THEN 'Domestic' WHEN 2 THEN 'Import' ELSE 'Uknown' END AS Supplier_Type,       
SIMS.Michaels_SKU, UPPER(SIMS.Item_Desc) AS ItemDesc, 
MCS.Display_Name as Column_Name, SCFH.Old_Value as OldValue, SCFH.New_Value as NewValue, 
case 
	when MCS.Column_Name = 'PhytoTemporaryShipment' then SIMS.PhytoTemporaryShipment
	when MCS.Column_name in ('PhytoSanitaryCertificate','FumigationCertificate') then SIMS.Fumigation_Certificate 
End as CurrentValue,
SCFH.Date_Created as DateFieldModified,
SIMS.Department_Num as DepartmentNum,  SIMS.Class_Num AS ClassNum, SIMS.Sub_Class_Num AS SubClassNum,
SIMS.SKU_Group as SKUGroup,  SIMS.Item_Status as ItemStatus, sims.Stock_Category as StockCategory,
SIMS.Item_Type_Attribute asItemTypeAttribute, SIMS.Pack_Item_Indicator as PackItemIndicator,
b.Date_Created as BatchCreated, b.Date_Modified as BatchModified
FROM 
SPD_Change_Field_History SCFH
inner join SPD_Batch b on b.Id = SCFH.Batch_ID
inner join SPD_Item_Master_SKU SIMS on SIMS.Michaels_SKU = SCFH.Michaels_SKU
inner join SPD_Item_Master_Vendor SIMV on SIMV.Michaels_SKU = SIMS.Michaels_SKU and SIMV.Vendor_Number = b.Vendor_Number
inner join 
(
	Select SMC.Id as MetaData_Column_id, SMC.Column_Name, SMC.Display_Name
	from SPD_Metadata_Column SMC
	where SMC.Metadata_Table_ID in (1,3,11)
	and SMC.Column_Name in
	(
		'PhytoSanitaryCertificate',
		'PhytoTemporaryShipment',
		'FumigationCertificate'
	) and isNull(smc.Track_History,0) = 1
) as MCS on MCS.MetaData_Column_id = SCFH.Metadata_Column_ID
WHERE 
(
	@startDate is null 
	or 
	(@startDate is not null and SCFH.Date_Created >= @startDate)
)   
and 
(
	@endDate is null 
	or 
	(@endDate is not null and SCFH.Date_Created <= @endDate)
)   
and 
(
	isnull(@dept, 0) = 0 
	or 
	(isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept)
)   
and 
(
	(isnull(@vendor, 0) <= 0) 
	or 
	(isnull(@vendor,0) > 0 and SIMV.Vendor_Number = @vendor)
) 
and 
(
	(isnull(@vendorFilter, 0) <= 0) 
	or 
	(isnull(@vendorFilter,0) > 0 and SIMV.Vendor_Number = @vendorFilter)
)   
and 
(
	isnull(@itemStatus, '') = '' 
	or 
	(isnull(@itemStatus, '') != '' and SIMS.Item_Status = @itemStatus)
)   
and 
(
	isnull(@sku, '') = '' 
	or 
	(isnull(@sku, '') != '' and SIMS.Michaels_SKU= @sku)
)   
and 
(
	isnull(@itemGroup, '') = '' 
	or 
	(isnull(@itemGroup, '') != '' and SIMS.SKU_Group = @itemGroup)
)   
and 
(
	isnull(@stockCategory, '') = '' 
	or 
	(isnull(@stockCategory, '') != '' and SIMS.Stock_Category = @stockCategory)
)   
and 
(
	isnull(@itemType, '') = '' 
	or 
	(isnull(@itemType, '') != '' and b.Batch_Type_ID = @itemType)
)
Order by SCFH.Michaels_SKU, SCFH.Date_Created,  SCFH.Batch_ID, MCS.Display_Name

END




GO

--*********************
--SORT ISSUES  6/17/2024
--*********************

GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_GetNewItemBatches_AllOther_PS]    Script Date: 6/17/2024 11:35:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Leon Popilov 
-- Create date: 09/08/09
-- Description:	Get New Item Batch Records for Spedy version 2,
-- used in default.aspx

-- NOTE: Test after cataloging to ensure completed does not time out. Recatalog as nec
-- Change Log
-- Dec 8, 2009 FJL - Add logic to return Workflow_Stage_ID and Dept_ID for editing logic
-- Dec 21, 22 2009, LP Workflow changes! 29 degrees, no precipitation
-- hardcoded workflow_id to 1 for New Items, completed items Stage_type_id to 4
-- Dec 29 2009, LP changed logic to get users names based on the workflow group & user id
-- Jan 5 10 added vendorid Lp
-- Jan10 got rid of top 1 for import item header selection, only one parent item is allowed
-- Jan12 added Approval Name, separated it from Stage per Ron's request
--  Need to confirm Approval Name logic
--  Need to add department logic for my items -done Jan 13
-- Jan 14, 2010 FJL - Add isNull checks to new fields
-- Jan 15, 2010 FJL - Add logic to handle dynamic sorting and Paging info
-- Jan 25,2010 FJL - Add logic to correctly sort the Date fields
-- Jan 26, 2010 FJL - Convert bottom two queries to use view to aid in sorting large record sets
-- Feb 18, 2010 FJL - add ItemCount field
-- Feb 25, 2010 FJL - Split Query to two Queries.  My Items need its own execution plan. Eliminates need to add Option Recompile to query
--					- Added logic to query to select My Items based on a match in Primary_Approval_Group.
--					- Added Logic to query and view to base approver on being a member of the Primary_Approval_Group
-- 
-- Jul 22, 2011 NAK - Adding with(nolock) on Select to prevent deadlocks
-- JUN 17, 2024 MWM - Adding sorting on final select
/*Test Code:

-- Completed
exec usp_SPD_GetNewItemBatches_AllOther_PS @StageId=12,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10

-- Vendor/CAA
exec usp_SPD_GetNewItemBatches_AllOther_PS @StageId=1,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10

-- Deleted
exec usp_SPD_GetNewItemBatches_AllOther_PS @StageId=-3,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm= '28302'

-- 48 hours
exec usp_SPD_GetNewItemBatches_AllOther_PS @Less48hours=1,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10

-- All Stages
exec usp_SPD_GetNewItemBatches_AllOther_PS @UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm= 'poly'


*/
-- =============================================
ALTER PROCEDURE [dbo].[usp_SPD_GetNewItemBatches_AllOther_PS]
	-- Add the parameters for the stored procedure here
--		@totalRows int OUTPUT,
		@StageId int = null,
		@SearchParm varchar(20) = null,
		@UserID bigint = null,
		@VendorID bigint = null,
		@Less48hours int = 0,
		@SortCol varchar(255) = null,
		@SortDir char(1) = 'A',
		@RowIndex int = 0,
		@MaxRows int = null	
	-- WITH RECOMPILE
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- If no sort ino is specified set it to ID
--	IF @SortCol is NULL
--		SET @SortCol = 'ID'
	
	DECLARE @StartRow int, @EndRow int, @totalRows int
	SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based
	IF @MaxRows is NULL
		SET @EndRow = 2147483647	-- Max int size
	ELSE
		SET @EndRow = @RowIndex + @MaxRows;
		
	declare @workflow_Id int ;
	set @workflow_id = 1;
	declare @complvalue int;
	set @complvalue = null;
	
	--if stage id is not passed, select all stages except Completed
	--Completeted stage has Stage_Type_id = 4 in spd_workflow_stage table
    if @StageID is null 
	BEGIN
		set @complvalue= 4;
	END

	IF @SearchParm is not NULL
	BEGIN
		if (CASE
			WHEN ISNUMERIC(@SearchParm) = 0											THEN 0
			WHEN @SearchParm LIKE '%[^0-9]%'										THEN 0
			WHEN CAST(@SearchParm AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 2147483647.	THEN 0
			ELSE 1
		  END ) = 0		-- TRUE its STRING
			SET @SearchParm = '%' + @SearchParm + '%';		-- set search for the Like option
	END
	
	-- *********************************************************************************************************************************
		
	IF @Less48hours <> 0
	BEGIN
		--PRINT 'Q2'
		SELECT *
		, Row_Number() Over ( ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
				-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
		) as RowNumber
		INTO #Results1
		FROM vwNewItemBatches with(nolock)
		WHERE
		--Spd_Batch.Workflow_Stage_Id <> 13 
			workflow_id = @workflow_id 
			and (Stage_Type_id <> @complvalue or @complvalue is null)
			and [enabled] = 1
			and (Workflow_Stage_Id = @StageId or @StageId is null)
			and ( @SearchParm is null
				OR cast(ID as varchar) = @SearchParm
				OR DEPT like @SearchParm
				OR Vendor like @SearchParm
				OR ( Len(@SearchParm) = 8 
					AND ( Batch_Type_ID = 1 
						and ID in ( Select Batch_ID From SPD_Item_Headers H join SPD_Items I on I.Item_Header_ID = H.ID Where I.Michaels_SKU = @SearchParm ) )
					OR ( Batch_Type_ID = 2
						and ID in ( Select Batch_ID From SPD_Import_Items I Where I.MichaelsSKU = @SearchParm ) )
					)
				OR ( (Batch_Type_ID = 1 
					 and ID in ( Select Batch_ID From SPD_Item_Headers H join SPD_Items I on I.Item_Header_ID = H.ID WHERE I.QuoteReferenceNumber Like @SearchParm )
					 )
					 OR 
					 (Batch_Type_ID = 2
					 and ID in ( Select Batch_ID From SPD_Import_Items I WHERE I.QuoteReferenceNumber Like @SearchParm)
					 )
					)
				OR ( ID in (Select Batch_ID from SPD_Import_Items WHERE VendorStyleNumber like @SearchParm))
				OR ( Header_ID in (Select Item_Header_ID From SPD_Items as i WHERE Vendor_Style_Num like @SearchParm))
				)
			and (Vendor_Number = @VendorId or @VendorID is null)
			and (tmpDateModified < dateadd(hour, -48, getdate())) 	-- subtract 48 hours from getdate and find batches older than that

		SET @totalRows = @@RowCount;

		-- Select Paged set of results from the CTE
		SELECT	*	-- , @@RowCount as TotalRows
		FROM	#Results1
		WHERE	RowNumber Between @StartRow and @EndRow
		ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		DROP table #Results1

	END  -- 48 Hours

	-- *********************************************************************************************************************************
	ELSE IF @StageId = -3	-- Show Deleted Items
	BEGIN
		--PRINT 'Q3'
		SELECT *
		, Row_Number() Over ( ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
				-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
		) as RowNumber
		INTO #Results3
		FROM vwNewItemBatches with(nolock)
		WHERE
		--Spd_Batch.Workflow_Stage_Id <> 13 
			workflow_id = @workflow_id 
			AND (Stage_Type_id <> @complvalue or @complvalue is null) 
			AND [enabled] = 0
--			(Workflow_Stage_Id = @StageId or @StageId is null) --and
			and ( @SearchParm is null
				OR cast(ID as varchar) = @SearchParm
				OR DEPT like @SearchParm
				OR Vendor like @SearchParm
				OR ( Len(@SearchParm) = 8 
					AND ( Batch_Type_ID = 1 
						and ID in ( Select Batch_ID From SPD_Item_Headers H join SPD_Items I on I.Item_Header_ID = H.ID Where I.Michaels_SKU = @SearchParm ) )
					OR ( Batch_Type_ID = 2
						and ID in ( Select Batch_ID From SPD_Import_Items I Where I.MichaelsSKU = @SearchParm ) )
					)
				OR ( (Batch_Type_ID = 1 
					 and ID in ( Select Batch_ID From SPD_Item_Headers H join SPD_Items I on I.Item_Header_ID = H.ID WHERE I.QuoteReferenceNumber Like @SearchParm )
					 )
					 OR 
					 (Batch_Type_ID = 2
					 and ID in ( Select Batch_ID From SPD_Import_Items I WHERE I.QuoteReferenceNumber Like @SearchParm)
					 )
					)
				OR ( ID in (Select Batch_ID from SPD_Import_Items WHERE VendorStyleNumber like @SearchParm))
				OR ( Header_ID in (Select Item_Header_ID From SPD_Items as i WHERE Vendor_Style_Num like @SearchParm))
				)
--			AND (cast(id as varchar) = @SearchParm or @SearchParm is null)
			AND (Vendor_Number= @VendorId or @VendorID is null)
		--OPTION(RECOMPILE);

		SET @totalRows = @@RowCount;
		
		-- Select Paged set of results from the CTE -- Return totalRows along with the page subset
		SELECT	*	-- , @@RowCount as TotalRows
		FROM	#Results3
		WHERE	RowNumber Between @StartRow and @EndRow
		ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		DROP table #Results3
	END

	-- *********************************************************************************************************************************
	ELSE -- All other queries
	BEGIN
		--PRINT 'Q4'
		SELECT *
		, Row_Number() Over ( ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
				-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
		) as RowNumber
		INTO #Results2
		FROM vwNewItemBatches with(nolock)
		WHERE
		--Spd_Batch.Workflow_Stage_Id <> 13 
			workflow_id = @workflow_id 
			and (Stage_Type_id <> @complvalue or @complvalue is null)
			and [enabled] = 1
			and (Workflow_Stage_Id = @StageId or @StageId is null)
			and ( @SearchParm is null
				OR cast(ID as varchar) = @SearchParm
				OR DEPT like @SearchParm
				OR Vendor like @SearchParm
				OR ( Len(@SearchParm) = 8 
					AND ( Batch_Type_ID = 1 
						and ID in ( Select Batch_ID From SPD_Item_Headers H join SPD_Items I on I.Item_Header_ID = H.ID Where I.Michaels_SKU = @SearchParm ) )
					OR ( Batch_Type_ID = 2
						and ID in ( Select Batch_ID From SPD_Import_Items I Where I.MichaelsSKU = @SearchParm ) )
					)
				OR ( (Batch_Type_ID = 1 
					 and ID in ( Select Batch_ID From SPD_Item_Headers H join SPD_Items I on I.Item_Header_ID = H.ID WHERE I.QuoteReferenceNumber Like @SearchParm )
					 )
					 OR 
					 (Batch_Type_ID = 2
					 and ID in ( Select Batch_ID From SPD_Import_Items I WHERE I.QuoteReferenceNumber Like @SearchParm)
					 )
					)
				OR ( ID in (Select Batch_ID from SPD_Import_Items WHERE VendorStyleNumber like @SearchParm))
				OR ( Header_ID in (Select Item_Header_ID From SPD_Items as i WHERE Vendor_Style_Num like @SearchParm))
				)

--			and (cast(id as varchar) = @SearchParm or @SearchParm is null)
			and (Vendor_Number= @VendorId or @VendorID is null)
		--OPTION(RECOMPILE);




		SET @totalRows = @@RowCount;
		
		-- Select Paged set of results from the CTE -- Return totalRows along with the page subset
		SELECT	*	-- , @@RowCount as TotalRows
		FROM	#Results2
		WHERE	RowNumber Between @StartRow and @EndRow

				--------------
		ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		--------------

		DROP table #Results2

	END -- All Other queries 

return @totalRows

END

GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_GetNewItemBatches_MyItems_PS]    Script Date: 6/17/2024 11:36:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Leon Popilov 
-- Create date: 09/08/09
-- Description:	Get New Item Batch Records for Spedy version 2,
-- used in default.aspx

-- NOTE: Test after cataloging to ensure completed does not time out. Recatalog as nec
-- Change Log
-- Dec 8, 2009 FJL - Add logic to return Workflow_Stage_ID and Dept_ID for editing logic
-- Dec 21, 22 2009, LP Workflow changes! 29 degrees, no precipitation
-- hardcoded workflow_id to 1 for New Items, completed items Stage_type_id to 4
-- Dec 29 2009, LP changed logic to get users names based on the workflow group & user id
-- Jan 5 10 added vendorid Lp
-- Jan10 got rid of top 1 for import item header selection, only one parent item is allowed
-- Jan12 added Approval Name, separated it from Stage per Ron's request
--  Need to confirm Approval Name logic
--  Need to add department logic for my items -done Jan 13
-- Jan 14, 2010 FJL - Add isNull checks to new fields
-- Jan 15, 2010 FJL - Add logic to handle dynamic sorting and Paging info
-- Jan 25,2010 FJL - Add logic to correctly sort the Date fields
-- Jan 26, 2010 FJL - Convert bottom two queries to use view to aid in sorting large record sets
-- Feb 18, 2010 FJL - add ItemCount field
-- Feb 25, 2010 FJL - Split Query to two Queries.  My Items need its own execution plan. Eliminates need to add Option Recompile to query
--					- Added logic to query to select My Items based on a match in Primary_Approval_Group.
--					- Added Logic to query and view to base approver on being a member of the Primary_Approval_Group
-- Apr 5, 2010 FJL  - Add logic for search for Log ID or partial string in Dept or vendor using following filter
-- May 14, 2010 FJL - Add logic to return my items if vendor logs in
-- Nov 15, 2010 FJL - Changed logic to join on Security table based on VendorID > 0 Minimize need for SELECT Distinct
-- Jun 17 2024 adding sorting MWM
/*Test Code:

exec usp_SPD_GetNewItemBatches_MyItems_PS @StageId=0,@UserId=1337,@SortDir='A',@RowIndex=0,@MaxRows=10	
exec usp_SPD_GetNewItemBatches_MyItems_PS @StageId=0,@UserId=1337,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm = 'poly'
exec usp_SPD_GetNewItemBatches_MyItems_PS @StageId=0,@UserId=1337,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm = '31910'

User IDs to test with
AriasK 40	VasquezM 1473	StatonJ 1337


*/
-- =============================================
ALTER PROCEDURE [dbo].[usp_SPD_GetNewItemBatches_MyItems_PS]
	-- Add the parameters for the stored procedure here
--		@totalRows int OUTPUT,
		@StageId int = null,
		@SearchParm varchar(20) = null,
		@UserID int = null,
		@VendorID bigint = null,
		@Less48hours int = 0,
		@SortCol varchar(255) = null,
		@SortDir char(1) = 'A',
		@RowIndex int = 0,
		@MaxRows int = null	
	-- WITH RECOMPILE
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @StartRow int, @EndRow int, @totalRows int
	SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based
	IF @MaxRows is NULL
		SET @EndRow = 2147483647	-- Max int size
	ELSE
		SET @EndRow = @RowIndex + @MaxRows;
		
	declare @workflow_Id int ;
	set @workflow_id = 1;
	declare @complvalue int;
	set @complvalue = null;
	
	--if stage id is not passed, select all stages except Completed
	--Completeted stage has Stage_Type_id = 4 in spd_workflow_stage table
    if @StageID is null 
	begin
		set @complvalue= 4;
	end
	
	IF @SearchParm is not NULL
	BEGIN
		if (CASE
				WHEN ISNUMERIC(@SearchParm) = 0											THEN 0
				WHEN @SearchParm LIKE '%[^0-9]%'										THEN 0
				WHEN CAST(@SearchParm AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 2147483647.	THEN 0
				ELSE 1
			END ) = 0		-- TRUE. it's a STRING to search on
			SET @SearchParm = '%' + @SearchParm + '%';		-- set search for the Like option
	END

	-- First query is MY Items query, stageId is 0.  
	-- NOTE: View not used in this option because of the sub query that references a parameter
    IF @UserID is not null and @StageId = 0
	BEGIN
		SELECT	Distinct
		coalesce(Vendor_Name, 'Uknown Vendor,Please Correct',  Vendor_Name) + '<br />' + str(coalesce(Vendor_Number,'',Vendor_Number)) as Vendor
		-- FJL add to separate type from URL field created in aspx
		, case Batch_Type_ID when 1 then 'Domestic' when 2 then 'Import' else 'Uknown' end as Batch_Type_Desc
		-- FJL for Domestic vs Import Header ID
					, coalesce(H.ID, (select TOP 1 ID from [SPD_Import_Items] where [SPD_Import_Items].Batch_ID = SPD_Batch.Id and Parent_ID = 0 ORDER BY ID ASC),'') as Header_ID
		-- Test	, H.ID as TH1, (select top 1 ID from [SPD_Import_Items] where [SPD_Import_Items].Batch_ID = SPD_Batch.Id and Parent_ID = 0) as TH2,
		, SPD_Batch.Id as ID
		, coalesce(Convert(varchar,DEPT),'')+ '<br />' + coalesce(DEPT_Name,'UKNOWN DEPARTMENT') as DEPT
		, Convert(varchar,cast(SPD_Batch.date_created as smalldatetime)) + '<br />' + coalesce(Security_User.Last_Name + ' ' + Security_User.First_Name,'') as DateCreated
		, Convert(varchar,cast(date_Modified as smalldatetime)) + '<br />' + coalesce(Security_User2.Last_Name +' '+ Security_User2.First_Name,'System') as DateModified
		, case SPD_Batch.Is_Valid when -1 then 'unknown' when 0 then 'no' when 1 then 'yes' else 'xxx' end as Valid
		, stage_name as Workflow_Stage
        , CASE

			WHEN SPD_Batch.Fineline_Dept_ID IS NOT NULL 
				AND SPD_Workflow_Stage.[Stage_Type_id] NOT IN (3, 4) 
				AND EXISTS (
					SELECT *
					FROM security_user ssu 
					INNER JOIN spd_workflow_primary_approver swpa ON swpa.security_user_id = ssu.id
					INNER JOIN spd_workflow_stage sws ON swpa.security_group_id = sws.primary_approval_group_id 
					INNER JOIN security_privilege ssp ON swpa.security_dept_id = ssp.id 
						AND ssp.scope_id = 1002 
						AND CAST(ssp.sortorder AS integer) = SPD_Batch.Fineline_Dept_ID
					WHERE sws.ID = SPD_Batch.Workflow_Stage_ID 
						AND swpa.spd_workflow_id = SPD_Workflow_Stage.Workflow_ID 
						AND ssu.[enabled] = 1) 
			THEN (
				SELECT top (1) COALESCE (ssu.first_name, '') + ' ' + COALESCE (ssu.last_name, '') + COALESCE (' (x' + ssu.office_location + ')', '')
				FROM security_user ssu 
				INNER JOIN spd_workflow_primary_approver swpa ON swpa.security_user_id = ssu.id 
				INNER JOIN spd_workflow_stage sws ON swpa.security_group_id = sws.primary_approval_group_id 
				INNER JOIN security_privilege ssp ON swpa.security_dept_id = ssp.id 
					AND ssp.scope_id = 1002 
					AND CAST(ssp.sortorder AS integer) = SPD_Batch.Fineline_Dept_ID
				WHERE sws.ID = SPD_Batch.Workflow_Stage_ID 
					AND swpa.spd_workflow_id = SPD_Workflow_Stage.Workflow_ID 
					AND ssu.[enabled] = 1) 
			WHEN SPD_Batch.Fineline_Dept_ID IS NOT NULL AND SPD_Workflow_Stage.[Stage_Type_id] NOT IN (3, 4) 
			THEN (
				SELECT TOP (1) COALESCE (ssu.first_name, '') + ' ' + COALESCE (ssu.last_name, '') + COALESCE (' (x' + ssu.office_location + ')', '')
				FROM security_user ssu 
				INNER JOIN security_user_privilege ssup ON ssu.id = ssup.[user_id] 
				INNER JOIN security_privilege ssp ON ssup.privilege_id = ssp.id 
					AND ssp.scope_id = 1002 
					AND CAST(ssp.sortorder AS integer) = SPD_Batch.Fineline_Dept_ID 
				INNER JOIN security_user_group ssug ON ssu.id = ssug.[user_id] 
				INNER JOIN spd_workflow_stage sws ON sws.primary_approval_group_id = ssug.group_id 
					AND sws.id = SPD_Batch.Workflow_Stage_ID
				WHERE ssu.[enabled] = 1
				ORDER BY ssu.last_name ASC, ssu.first_name ASC) 

			/*WHEN SPD_Batch.Fineline_Dept_ID is NOT NULL AND SPD_Workflow_Stage.[Stage_Type_id] not in(3,4) THEN (
				SELECT TOP (1) coalesce(first_name, '')+' '+coalesce(last_name, '')+coalesce(' (x'+office_location+')', '')
				FROM security_user 
					inner join Security_User_Group 			on Security_User_Group.[User_ID] = security_user.ID				-- get groups user is in
					inner join SPD_Workflow_Approval_group 	on SPD_Workflow_Approval_group.Approval_Group_ID = Security_User_Group.Group_ID -- get groups that can approve stages
					inner join SPD_Workflow_Stage ws 		on ws.ID = SPD_Workflow_Approval_group.Workflow_Stage_ID		-- get the Primary Group assoc w/ this stage 
																and ws.Primary_Approval_Group_ID = Security_User_Group.Group_ID
																and ws.ID = SPD_Workflow_Stage.ID
					inner join Security_User_Privilege 		on security_user.ID = Security_User_Privilege.[User_ID]				-- get priv (depts) of user
					inner join Security_Privilege 			on Security_User_Privilege.Privilege_ID = Security_Privilege.ID				-- Get Depts
																and Security_Privilege.Scope_ID = 1002
																and cast(Security_Privilege.SortOrder as integer) = SPD_Batch.Fineline_Dept_ID -- matching dept
				--ORDER BY coalesce(security_user.Primary_Approver,0) desc , security_user.last_name asc, security_user.first_name
				ORDER BY coalesce(Security_User_Privilege.Primary_Approver_Flag,0) desc
					, security_user.last_name asc
					, security_user.first_name asc
				)*/
				
			ELSE '' END		AS Approval_Name

		 -- ITEM COUNT For batch. Feb 2010
		,  CASE 
			WHEN Batch_Type_ID = 1 THEN
			(	SELECT count(*) 
				FROM SPD_Items i
					Join SPD_Item_Headers h on i.[Item_Header_ID] = h.ID 
				WHERE h.Batch_ID = SPD_Batch.Id )
			WHEN Batch_Type_ID = 2 THEN
			(	SELECT count(*)
				FROM SPD_Import_Items 
				WHERE [Batch_ID] = SPD_Batch.Id )
			ELSE	0
			END as Item_Count
				
		-- FJL Jan 2010: wrap below fields in IsNull				
		, isNull(workflow_stage_id,0) as Workflow_Stage_ID
		, isNull(SPD_Workflow_Stage.Stage_Type_id,0) as Stage_Type_ID
		, isNull(SPD_Workflow_Stage.Sequence,0) as Stage_Sequence
		, isNull(SPD_Batch.Fineline_Dept_ID,0) as Dept_ID
		, SPD_Batch.date_created as tmpDateCreated			-- used for sorting only
		, date_Modified as tmpDateModified					-- used for sorting only
		, SPD_Workflow_Stage.Workflow_id
		, SPD_Batch.[enabled]
		, SPD_Batch.Vendor_Number
		, SPD_Batch.Created_User	As Created_By
		INTO #Results		-- Allows CASE Sorting of result set
		FROM SPD_Batch 
			left outer join Security_User on SPD_Batch.created_user =Security_User.id 
			left outer join Security_User as Security_User2 on SPD_Batch.modified_user = Security_User2.id 
			inner join SPD_Workflow_Stage on Spd_Batch.Workflow_Stage_Id = SPD_Workflow_Stage.ID 
			left outer join SPD_FineLine_Dept on SPD_Batch.Fineline_Dept_ID = SPD_FineLine_Dept.Dept
			-- FJL for Header Lookup -- Left because NULL indicates its Import for sub query above
			left join [SPD_Item_Headers] H on SPD_Batch.ID = H.Batch_ID
			inner join Security_privilege sp on sp.scope_id = 1002
				and cast(sp.SortOrder as integer) = SPD_Batch.Fineline_Dept_ID -- matching dept

			-- FJL Feb 2010 - use following tables to determine what groups the user is in
			--inner join security_user_privilege sup on sp.id = sup.privilege_id
			--inner join dbo.Security_User_Group sug on sup.[User_id] = sug.[User_ID]

			-- FJL CHange Nov 2010 to minimize need for distint clause need. Only join to these tables when its not a vendor running the query
			left join security_user_privilege SUP	on SP.id = SUP.privilege_id and IsNull(@VendorID,0) = 0
			left join dbo.Security_User_Group SUG	on SUP.[User_id] = SUG.[User_ID] and IsNull(@VendorID,0) = 0	--and (@VendorID is NULL or @VendorID = 0)
			--inner join dbo.Security_Group sg on sg.id = [sug.Group_ID]
		WHERE  
			-- do not return Completed Batches when My items selected
			SPD_Workflow_Stage.Stage_Type_id <> 4
			and SPD_Workflow_Stage.workflow_Id = @workflow_Id
			and spd_Batch.enabled = 1
			and ( @SearchParm is null
				OR cast(SPD_Batch.Id as varchar) = @SearchParm
				OR SPD_FineLine_Dept.DEPT_NAME like @SearchParm
				OR SPD_Batch.Vendor_Name like @SearchParm
				
				OR ( (Batch_Type_ID = 1 
					 and spd_Batch.ID in ( Select Batch_ID From SPD_Item_Headers H join SPD_Items I on I.Item_Header_ID = H.ID WHERE I.QuoteReferenceNumber Like @SearchParm )
					 )
					 OR 
					 (Batch_Type_ID = 2
					 and spd_Batch.ID in ( Select Batch_ID From SPD_Import_Items I WHERE I.QuoteReferenceNumber Like @SearchParm)
					 )
					)
				OR ( SPD_Batch.ID in (Select Batch_ID from SPD_Import_Items WHERE VendorStyleNumber like @SearchParm))
				OR ( SPD_Batch.ID in (Select Batch_ID  From SPD_Items as i INNER JOIN SPD_Item_HEaders as h on h.id = i.Item_Header_ID WHERE Vendor_Style_Num like @SearchParm))
				)
			and (	-- For Michaels Users
				   (sup.[user_id] = @UserID and sug.Group_ID = SPD_Workflow_Stage.Primary_Approval_Group_ID)
				or	-- For Vendor
					( spd_Batch.Vendor_Number = isnull(@VendorId, 0) 
						and spd_Batch.Vendor_Number is not null 
						and SPD_Workflow_Stage.Stage_Type_id = 5
					)
				)				
				;

		SET @totalRows = @@RowCount;
		
		-- Create a CTE to determine number of rows over the Request Sort Order
		WITH SortedResult 
		AS (
			SELECT *
			, Row_Number() Over ( ORDER BY
					CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
					CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
					CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
					CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
					CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
					CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
					CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
					CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
					CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
					CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
					CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
					CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
					-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
				) as RowNumber
			FROM  #Results R
		)
		
		-- Select Paged set of results from the CTE Sorted Result
		SELECT	* 
		FROM	SortedResult
		WHERE	RowNumber Between @StartRow and @EndRow
		ORDER BY
					CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
					CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
					CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
					CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
					CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
					CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
					CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
					CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
					CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
					CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
					CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
					CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		DROP table #Results

	END -- My Items
ELSE
BEGIN
	set @totalRows = 0
	RAISError('Invalid Parameters Passed to MyItems Query. User_ID: %d Stage_ID: %d',
				16,
				1,
				@UserID, @StageId)
	
END
return @totalRows

END


GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_GetIMBatches_AllOther_PS]    Script Date: 6/17/2024 11:39:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Littlefield Jeff
-- Create date: 09/08/09
-- Description:	Get New Item Batch Records for Spedy version 2,
-- used in default.aspx

-- NOTE: Test after cataloging to ensure completed does not time out. Recatalog as nec
-- Change Log
-- Dec 8, 2009 FJL - Add logic to return Workflow_Stage_ID and Dept_ID for editing logic
-- Dec 21, 22 2009, LP Workflow changes! 29 degrees, no precipitation
-- hardcoded workflow_id to 1 for New Items, completed items Stage_type_id to 4
-- Dec 29 2009, LP changed logic to get users names based on the workflow group & user id
-- Jan 5 10 added vendorid Lp
-- Jan10 got rid of top 1 for import item header selection, only one parent item is allowed
-- Jan12 added Approval Name, separated it from Stage per Ron's request
--  Need to confirm Approval Name logic
--  Need to add department logic for my items -done Jan 13
-- Jan 14, 2010 FJL - Add isNull checks to new fields
-- Jan 15, 2010 FJL - Add logic to handle dynamic sorting and Paging info
-- Jan 25,2010 FJL - Add logic to correctly sort the Date fields
-- Jan 26, 2010 FJL - Convert bottom two queries to use view to aid in sorting large record sets
-- Feb 18, 2010 FJL - add ItemCount field
-- Feb 25, 2010 FJL - Split Query to two Queries.  My Items need its own execution plan. Eliminates need to add Option Recompile to query
--					- Added logic to query to select My Items based on a match in Primary_Approval_Group.
--					- Added Logic to query and view to base approver on being a member of the Primary_Approval_Group
-- 
/*Test Code:

-- Completed
exec usp_SPD_GetIMBatches_AllOther_PS @StageId=12,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10

-- Vendor/CAA
exec usp_SPD_GetIMBatches_AllOther_PS @StageId=1,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10

-- Deleted
exec usp_SPD_GetIMBatches_AllOther_PS @StageId=-3,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm= '28302'

-- 48 hours
exec usp_SPD_GetIMBatches_AllOther_PS @Less48hours=1,@UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10

-- All Stages
exec usp_SPD_GetIMBatches_AllOther_PS @UserId=0,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm= 'poly'

exec usp_SPD_GetIMBatches_AllOther_PS @WorkflowID=2,@UserId=3417,@SortCol='ID',@SortDir='A',@RowIndex=0,@MaxRows=10

*/
-- =============================================
ALTER PROCEDURE [dbo].[usp_SPD_GetIMBatches_AllOther_PS]
	-- Add the parameters for the stored procedure here
		  @StageId int = null
		, @WorkflowID int = 2  
		, @SearchParm varchar(20) = null
		, @UserID int = null
		, @VendorID bigint = null
		, @Less48hours int = 0
		, @SortCol varchar(255) = null
		, @SortDir char(1) = 'A'
		, @RowIndex int = 0
		, @MaxRows int = null	
	AS
BEGIN
--	print 'Proc Starting'
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRow int, @EndRow int, @totalRows int
	SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based
	IF @MaxRows is NULL
		SET @EndRow = 2147483647	-- Max int size
	ELSE
		SET @EndRow = @RowIndex + @MaxRows;
		
	--declare @workflow_Id int ;
	--set @workflow_Id = @workflow_Id
	
	declare @complvalue int;
	set @complvalue = null;
	
	--if stage id is not passed, select all stages except Completed
	--Completeted stage has Stage_Type_id = 4 in spd_workflow_stage table
	IF @StageID is null 
	BEGIN
		--set @complvalue = 4;
		Select @complvalue = [Stage_Type_id]
		FROM [SPD_Workflow_Stage_Type]
		WHERE [Stage_Type_Name] like 'Completed%'
		IF @complvalue is NULL 
			set @complvalue = 4;
	END
	
	IF @SearchParm is not NULL
	BEGIN
		if (CASE
				WHEN ISNUMERIC(@SearchParm) = 0											THEN 0
				WHEN @SearchParm LIKE '%[^0-9]%'										THEN 0
				WHEN CAST(@SearchParm AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 2147483647.	THEN 0
				ELSE 1
			END ) = 0		-- TRUE. it's a STRING to search on. FALSE its a batch ID to find
			SET @SearchParm = '%' + @SearchParm + '%';		-- set search for the Like option
	END

	-- *********************************************************************************************************************************
		
	IF @Less48hours <> 0
	BEGIN
		PRINT 'Q2 - 48 hours'
		SELECT *
		, Row_Number() Over ( ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
				-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
		) as RowNumber
		INTO #Results1
		FROM vwIMBatches 
		WHERE
		--Spd_Batch.Workflow_Stage_Id <> 13 
			workflow_id = @WorkflowID 
			and (Stage_Type_id <> @complvalue or @complvalue is null)
			and [enabled] = 1
			and (Workflow_Stage_Id = @StageId or @StageId is null)
			and ( @SearchParm is null
				OR cast(ID as varchar) = @SearchParm
				OR DEPT like @SearchParm
				OR Vendor like @SearchParm
				OR ( Len(@SearchParm) = 8 
					AND  ID in ( Select Batch_ID From SPD_Item_Maint_Items I Where I.Michaels_SKU like @SearchParm )
					)
				OR ID in (Select Batch_ID from SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Vendor as v on v.Michaels_SKU = i.Michaels_SKU AND v.Vendor_Number = i.Vendor_Number WHERE v.Vendor_Style_Num like @SearchParm)
				OR ID in (Select Batch_ID From SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = i.ID WHERE c.Field_Name = 'VendorStyleNum' AND c.Field_Value like @SearchParm)
				)
			and (Vendor_Number = @VendorId or @VendorID is null)
			and (tmpDateModified < dateadd(hour, -48, getdate())) 	-- subtract 48 hours from getdate and find batches older than that

		SET @totalRows = @@RowCount;

		-- Select Paged set of results from the CTE
		SELECT	*	
		FROM	#Results1
		WHERE	RowNumber Between @StartRow and @EndRow
		ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		DROP table #Results1

	END  -- 48 Hours

	-- *********************************************************************************************************************************
	ELSE IF @StageId = -3	-- Show Deleted Items
	BEGIN
		PRINT 'Q3 - deleted'
		SELECT *
		, Row_Number() Over ( ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
				-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
		) as RowNumber
		INTO #Results3
		FROM vwIMBatches 
		WHERE
			workflow_id = @WorkflowID 
			AND (Stage_Type_id <> @complvalue or @complvalue is null) 
			AND [enabled] = 0
			and ( @SearchParm is null
				OR cast(ID as varchar) = @SearchParm
				OR DEPT like @SearchParm
				OR Vendor like @SearchParm
				OR ( Len(@SearchParm) = 8 
					AND  ID in ( Select Batch_ID From SPD_Item_Maint_Items I Where I.Michaels_SKU like @SearchParm )
					)
				OR ID in (Select Batch_ID from SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Vendor as v on v.Michaels_SKU = i.Michaels_SKU AND v.Vendor_Number = i.Vendor_Number WHERE v.Vendor_Style_Num like @SearchParm)
				OR ID in (Select Batch_ID From SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = i.ID WHERE c.Field_Name = 'VendorStyleNum' AND c.Field_Value like @SearchParm)
				)
			AND (Vendor_Number= @VendorId or @VendorID is null)

		SET @totalRows = @@RowCount;
		
		-- Select Paged set of results from the CTE -- Return totalRows along with the page subset
		SELECT	*	
		FROM	#Results3
		WHERE	RowNumber Between @StartRow and @EndRow
		ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		DROP table #Results3
	END

	-- *********************************************************************************************************************************
	ELSE -- All other queries
	BEGIN
		PRINT 'Q4 - All Other.  Stage ID = ' + cast(@StageId as varchar)
		SELECT *
		, Row_Number() Over ( ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
				-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
		) as RowNumber
		INTO #Results2
		FROM vwIMBatches 
		WHERE
			workflow_id = @WorkflowID 
			and (Stage_Type_id <> @complvalue or @complvalue is null)
			and [enabled] = 1
			and (Workflow_Stage_Id = @StageId or @StageId is null)
			and ( @SearchParm is null
				OR cast(ID as varchar) = @SearchParm
				OR DEPT like @SearchParm
				OR Vendor like @SearchParm
				OR ( Len(@SearchParm) = 8 
					AND  ID in ( Select Batch_ID From SPD_Item_Maint_Items I Where I.Michaels_SKU like @SearchParm )
					)
				OR ID in (Select Batch_ID from SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Vendor as v on v.Michaels_SKU = i.Michaels_SKU AND v.Vendor_Number = i.Vendor_Number WHERE v.Vendor_Style_Num like @SearchParm)
				OR ID in (Select Batch_ID From SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = i.ID WHERE c.Field_Name = 'VendorStyleNum' AND c.Field_Value like @SearchParm)
				)
			and (Vendor_Number= @VendorId or @VendorID is null)

		SET @totalRows = @@RowCount;
		
		-- Select Paged set of results from the CTE -- Return totalRows along with the page subset
		SELECT	*	
		FROM	#Results2
		WHERE	RowNumber Between @StartRow and @EndRow
		ORDER BY
				CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
				CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
				CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
				--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
				CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
				CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
				CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
				CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
				CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
				CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
				CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
				CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
				CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
				CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
				CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
				CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
				CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
				CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
				CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
				CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
				CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		DROP table #Results2

	END -- All Other queries 

return @totalRows

END

GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_GetIMBatches_Completed_PS]    Script Date: 6/17/2024 11:40:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ned Kost
-- Create date: 10/25/11
-- Description:	Get Completed Item Batch Records for Spedy version 3
-- used in ItemMaint.aspx
-- =============================================
ALTER PROCEDURE [dbo].[usp_SPD_GetIMBatches_Completed_PS]
	-- Add the parameters for the stored procedure here
		  @StageId int = null
		, @WorkflowID int = 2  
		, @SearchParm varchar(20) = null
		, @UserID int = null
		, @VendorID bigint = null
		, @Less48hours int = 0
		, @SortCol varchar(255) = null
		, @SortDir char(1) = 'A'
		, @RowIndex int = 0
		, @MaxRows int = null	
	AS
BEGIN
--	print 'Proc Starting'
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartRow int, @EndRow int, @totalRows int
	SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based
	IF @MaxRows is NULL
		SET @EndRow = 2147483647	-- Max int size
	ELSE
		SET @EndRow = @RowIndex + @MaxRows;
			
	IF @SearchParm is not NULL
	BEGIN
		if (CASE
				WHEN ISNUMERIC(@SearchParm) = 0											THEN 0
				WHEN @SearchParm LIKE '%[^0-9]%'										THEN 0
				WHEN CAST(@SearchParm AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 2147483647.	THEN 0
				ELSE 1
			END ) = 0		-- TRUE. it's a STRING to search on. FALSE its a batch ID to find
			SET @SearchParm = '%' + @SearchParm + '%';		-- set search for the Like option
	END

	-- *********************************************************************************************************************************

	SELECT *
	, Row_Number() Over ( ORDER BY
			CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
			CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
			CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
			CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
			--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
			--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
			CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
			CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
			CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
			CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
			CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
			CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
			CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
			CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
			CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
			CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
			CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
			CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
			CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
			CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
			CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
			CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
			CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
			CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
			CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
			CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
			CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
			CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
			CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
			CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
			CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
			CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
			CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
			-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
	) as RowNumber
	INTO #Results2
	FROM vwIMBatches 
	WHERE
		workflow_id = @WorkflowID 
		and [enabled] = 1
		and (Workflow_Stage_Id = @StageId or @StageId is null)
		and ( @SearchParm is null
			OR cast(ID as varchar) = @SearchParm
			OR DEPT like @SearchParm
			OR Vendor like @SearchParm
			OR ( Len(@SearchParm) = 8 
				AND  ID in ( Select Batch_ID From SPD_Item_Maint_Items I Where I.Michaels_SKU like @SearchParm )
				)
			OR ID in (Select Batch_ID from SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Vendor as v on v.Michaels_SKU = i.Michaels_SKU AND v.Vendor_Number = i.Vendor_Number WHERE v.Vendor_Style_Num like @SearchParm)
			)
		and (Vendor_Number= @VendorId or @VendorID is null)

	SET @totalRows = @@RowCount;
	
	-- Select Paged set of results from the CTE -- Return totalRows along with the page subset
	SELECT	*	
	FROM	#Results2
	WHERE	RowNumber Between @StartRow and @EndRow
	ORDER BY
			CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
			CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
			CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
			CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
			--CASE WHEN @SortCol = 'Header_ID' and @SortDir = 'D' then Header_ID END DESC,
			--CASE WHEN @SortCol = 'Header_ID' and @SortDir != 'D' then Header_ID END,
			CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
			CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
			CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
			CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
			CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
			CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
			CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
			CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
			CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
			CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
			CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
			CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
			CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
			CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
			CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
			CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
			CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
			CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
			CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
			CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
			CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
			CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
			CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
			CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
			CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
			CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
			CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
	DROP table #Results2


return @totalRows

END

GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_GetIMBatches_MyItems_PS]    Script Date: 6/17/2024 11:40:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		J. Littlefield 
-- Create date: Apr 2010
-- Description:	Get Item Maint Batch Records for Spedy version 2.2 Clone from NewItem and changed
--				Used in ItemMaint.aspx

-- NOTE: Test after cataloging to ensure completed does not time out. Recatalog as nec
-- Change Log

--  

/*Test Code:

exec usp_SPD_GetIMBatches_MyItems_PS @StageId=0,@UserId=1473,@SortDir='A',@RowIndex=0,@MaxRows=10	-- Michelle ID
exec usp_SPD_GetIMBatches_MyItems_PS @StageId=0,@UserId=3417,@SortDir='A',@RowIndex=0,@MaxRows=10, @workflowID = 2	-- Jeff ID
exec usp_SPD_GetIMBatches_MyItems_PS @StageId=0,@UserId=1473,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm = 'poly'
exec usp_SPD_GetIMBatches_MyItems_PS @StageId=0,@UserId=1473,@SortDir='A',@RowIndex=0,@MaxRows=10, @SearchParm = '31910'

User IDs to test with
AriasK 40	VasquezM 1473	StatonJ 1337


*/
-- =============================================
ALTER PROCEDURE [dbo].[usp_SPD_GetIMBatches_MyItems_PS]
	-- Add the parameters for the stored procedure here
		  @StageId int = null
		, @WorkflowID int = 2  
		, @SearchParm varchar(20) = null
		, @UserID int = null
		, @VendorID bigint = null
		, @Less48hours int = 0
		, @SortCol varchar(255) = null
		, @SortDir char(1) = 'A'
		, @RowIndex int = 0
		, @MaxRows int = null	
		
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @StartRow int, @EndRow int, @totalRows int
	SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based
	IF @MaxRows is NULL
		SET @EndRow = 2147483647	-- Max int size
	ELSE
		SET @EndRow = @RowIndex + @MaxRows;
		
	declare @complvalue int;
	set @complvalue = null;
	
	-- If stage id is not passed, select all stages except Completed
	--   Completeted stage has Stage_Type_id = 4 in spd_workflow_stage table
    if @StageID is null 
	BEGIN
		--set @complvalue = 4;
		Select @complvalue = [Stage_Type_id]
		FROM [SPD_Workflow_Stage_Type]
		WHERE [Stage_Type_Name] like 'Completed%'
		IF @complvalue is NULL 
			set @complvalue = 4;
	END
	
	IF @SearchParm is not NULL
	BEGIN
		IF (CASE
				WHEN ISNUMERIC(@SearchParm) = 0											THEN 0
				WHEN @SearchParm LIKE '%[^0-9]%'										THEN 0
				WHEN CAST(@SearchParm AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 9999999999.	THEN 0	--2147483647
				ELSE 1
			END ) = 0		-- TRUE. it's a STRING to search on. FALSE its a batch ID or SKU to find
			SET @SearchParm = '%' + @SearchParm + '%';		-- set search for the Like option
	END

    IF @UserID IS NOT NULL AND @StageId = 0
	BEGIN
		SELECT Distinct
		coalesce(Vendor_Name, 'Uknown Vendor. Please Correct') + '<br />' + coalesce(convert(varchar(20),Vendor_Number),'') as Vendor
		, case Batch_Type_ID when 1 then 'Domestic' when 2 then 'Import' else 'Uknown' end as Batch_Type_Desc
		, B.ID as ID
		, coalesce(Convert(varchar(20),D.DEPT),'')+ '<br />' + coalesce(D.DEPT_Name,'UKNOWN DEPARTMENT') as DEPT
		, Convert(varchar(20),cast(B.Date_Created as smalldatetime)) + '<br />' 
			+ coalesce(SU.Last_Name + ' ' + SU.First_Name,'') as DateCreated
		, Convert(varchar(20),cast(B.Date_Modified as smalldatetime)) + '<br />' 
			+ coalesce(SU2.Last_Name +' '+ SU2.First_Name,'System') as DateModified
		, case B.Is_Valid 
			when -1 then 'unknown' 
			when 0 then 'no' 
			when 1 then 'yes' 
			else 'xxx' end as Valid
		, WS.stage_name as Workflow_Stage
        , CASE
			  WHEN B.Fineline_Dept_ID IS NOT NULL AND WS.[Stage_Type_id] NOT IN (3, 4) AND EXISTS
			  (SELECT *
				FROM security_user ssu 
				INNER JOIN spd_workflow_primary_approver swpa ON swpa.security_user_id = ssu.id
				INNER JOIN spd_workflow_stage sws ON swpa.security_group_id = sws.primary_approval_group_id 
				INNER JOIN security_privilege ssp ON swpa.security_dept_id = ssp.id 
					AND ssp.scope_id = 1002 
					AND CAST(ssp.sortorder AS integer) = B.Fineline_Dept_ID
				WHERE sws.ID = B.Workflow_Stage_ID 
					AND swpa.spd_workflow_id = WS.Workflow_ID 
					AND ssu.[enabled] = 1) THEN
			  (SELECT top 1
					COALESCE (ssu.first_name, '') + ' ' + COALESCE (ssu.last_name, '') + COALESCE (' (x' + ssu.office_location + ')', '')
				FROM security_user ssu 
				INNER JOIN spd_workflow_primary_approver swpa ON swpa.security_user_id = ssu.id 
				INNER JOIN spd_workflow_stage sws ON swpa.security_group_id = sws.primary_approval_group_id 
				INNER JOIN security_privilege ssp ON swpa.security_dept_id = ssp.id 
					AND ssp.scope_id = 1002 
					AND CAST(ssp.sortorder AS integer) = B.Fineline_Dept_ID
				WHERE sws.ID = B.Workflow_Stage_ID 
					AND swpa.spd_workflow_id = WS.Workflow_ID 
					AND ssu.[enabled] = 1) 
		  WHEN B.Fineline_Dept_ID IS NOT NULL AND WS.[Stage_Type_id] NOT IN (3, 4) THEN
			  (SELECT TOP (1) COALESCE (ssu.first_name, '') + ' ' + COALESCE (ssu.last_name, '') + COALESCE (' (x' + ssu.office_location + ')', '')
				FROM security_user ssu 
				INNER JOIN security_user_privilege ssup ON ssu.id = ssup.[user_id] 
				INNER JOIN security_privilege ssp ON ssup.privilege_id = ssp.id 
					AND ssp.scope_id = 1002 
					AND CAST(ssp.sortorder AS integer) = B.Fineline_Dept_ID 
				INNER JOIN security_user_group ssug ON ssu.id = ssug.[user_id] 
				INNER JOIN spd_workflow_stage sws ON sws.primary_approval_group_id = ssug.group_id 
					AND sws.id = B.Workflow_Stage_ID
				WHERE ssu.[enabled] = 1
				ORDER BY ssu.last_name ASC, ssu.first_name ASC) 
							
			ELSE '' END AS Approval_Name

		 -- ITEM COUNT For batch.
		 , Item_Count = ( SELECT count(*) FROM SPD_Item_Maint_Items IMH WHERE IMH.Batch_ID = B.ID )
				
		-- FJL Jan 2010: wrap below fields in IsNull				
		, isNull(workflow_stage_id, 0) as Workflow_Stage_ID
		, isNull(WS.Stage_Type_id, 0) as Stage_Type_ID
		, isNull(WS.Sequence, 0) as Stage_Sequence
		, isNull(B.Fineline_Dept_ID, 0) as Dept_ID
		, B.Date_Created as tmpDateCreated				-- used for sorting only
		, B.date_Modified as tmpDateModified			-- used for sorting only
		, WS.Workflow_id
		, B.[enabled]
		, B.Vendor_Number
		, B.Stock_Category
		, B.Item_Type_Attribute
		, B.Created_User	As Created_By

		INTO #Results		-- Allows CASE Sorting of result set
		FROM SPD_Batch B
			left outer join Security_User SU		on B.created_user = SU.id 
			left outer join Security_User as SU2	on B.modified_user = SU2.id 
			inner join SPD_Workflow_Stage WS		on B.Workflow_Stage_Id = WS.ID 
			left outer join SPD_FineLine_Dept D		on B.Fineline_Dept_ID = D.Dept
--			 Get dept based on sort order
			inner join Security_privilege SP		on SP.scope_id = 1002
				and cast(SP.SortOrder as integer) = B.Fineline_Dept_ID -- matching dept
			-- FJL Feb 2010 - use following tables to determine what groups the user is in
			--inner join security_user_privilege sup on sp.id = sup.privilege_id
			--inner join dbo.Security_User_Group sug on sup.[User_id] = sug.[User_ID]

			-- FJL CHange Nov 2010 to minimize need for distint clause need. Only join to these tables when its not a vendor running the query
			left join security_user_privilege SUP	on SP.id = SUP.privilege_id and IsNull(@VendorID,0) = 0
			left join dbo.Security_User_Group SUG	on SUP.[User_id] = SUG.[User_ID] and IsNull(@VendorID,0) = 0	--and (@VendorID is NULL or @VendorID = 0)
		WHERE  
			WS.Stage_Type_id <> 4	-- do not return Completed Batches when My items selected
			and WS.workflow_Id = @WorkflowID
			and B.Enabled = 1
			and ( @SearchParm is null
				OR cast(B.Id as varchar(20)) = @SearchParm
				OR D.DEPT_NAME like @SearchParm
				OR B.Vendor_Name like @SearchParm
				OR ( Len(@SearchParm) = 8 
					AND  B.ID in ( Select Batch_ID From SPD_Item_Maint_Items I Where I.Michaels_SKU like @SearchParm )
					)
				OR B.ID in (Select Batch_ID from SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Vendor as v on v.Michaels_SKU = i.Michaels_SKU AND v.Vendor_Number = i.Vendor_Number WHERE v.Vendor_Style_Num like @SearchParm)
				OR B.ID in (Select Batch_ID From SPD_Item_Maint_Items as i Inner Join SPD_Item_Master_Changes as c on c.Item_Maint_Items_ID = i.ID WHERE c.Field_Name = 'VendorStyleNum' AND c.Field_Value like @SearchParm)
				)
			and ( @VendorID IS NULL 
				OR B.Vendor_Number = @VendorId )
			--and SUP.[user_id] = @UserID and SUG.Group_ID = WS.Primary_Approval_Group_ID

			and (	-- For Michaels Users
				   ( SUP.[user_id] = @UserID 
						and SUG.Group_ID = WS.Primary_Approval_Group_ID )
				OR	-- For Vendor
					( B.Vendor_Number = isnull(@VendorId, 0) 
						and B.Vendor_Number is not null 
						and WS.Stage_Type_id = 5 )
				)				
			;

		SET @totalRows = @@RowCount;
		
		-- Create a CTE to determine number of rows over the Request Sort Order
		WITH SortedResult 
		AS (
			SELECT *
			, Row_Number() Over ( ORDER BY
					CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
					CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
					CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
					CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
					CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
					CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
					CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
					CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
					CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
					CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
					CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
					CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
					CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
					CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
					-- Add CASE Pairs as necessary to handle additional sort columns All have comma's at end except last one
				) as RowNumber
			FROM  #Results R
		)
		
		-- Select Paged set of results from the CTE Sorted Result
		SELECT	* 
		FROM	SortedResult
		WHERE	RowNumber Between @StartRow and @EndRow
		ORDER BY
					CASE WHEN @SortCol = 'Vendor' and @SortDir = 'D' then Vendor END DESC,
					CASE WHEN @SortCol = 'Vendor' and @SortDir != 'D' then Vendor END,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir = 'D' then Batch_Type_Desc END DESC,
					CASE WHEN @SortCol = 'Batch_Type_Desc' and @SortDir != 'D' then Batch_Type_Desc END,
					CASE WHEN @SortCol = 'ID' and @SortDir = 'D' then ID END DESC,
					CASE WHEN @SortCol = 'ID' and @SortDir != 'D' then ID END,
					CASE WHEN @SortCol = 'Dept' and @SortDir = 'D' then DEPT END DESC,
					CASE WHEN @SortCol = 'Dept' and @SortDir != 'D' then DEPT END,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir = 'D' then Item_Count END DESC,
					CASE WHEN @SortCol = 'Item_Count' and @SortDir != 'D' then Item_Count END,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir = 'D' then tmpDateCreated END DESC,
					CASE WHEN @SortCol = 'DateCreated' and @SortDir != 'D' then tmpDateCreated END,
					CASE WHEN @SortCol = 'DateModified' and @SortDir = 'D' then tmpDateModified END DESC,
					CASE WHEN @SortCol = 'DateModified' and @SortDir != 'D' then tmpDateModified END,
					CASE WHEN @SortCol = 'Valid' and @SortDir = 'D' then Valid END DESC,
					CASE WHEN @SortCol = 'Valid' and @SortDir != 'D' then Valid END,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir = 'D' then Workflow_Stage END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage' and @SortDir != 'D' then Workflow_Stage END,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir = 'D' then Approval_Name END DESC,
					CASE WHEN @SortCol = 'Approval_Name' and @SortDir != 'D' then Approval_Name END,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir = 'D' then workflow_stage_id END DESC,
					CASE WHEN @SortCol = 'Workflow_Stage_ID' and @SortDir != 'D' then workflow_stage_id END,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir = 'D' then Stage_Type_id END DESC,
					CASE WHEN @SortCol = 'Stage_Type_ID' and @SortDir != 'D' then Stage_Type_id END,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir = 'D' then Stage_Sequence END DESC,
					CASE WHEN @SortCol = 'Stage_Sequence' and @SortDir != 'D' then Stage_Sequence END,
					CASE WHEN @SortCol = 'Stock_Category' and @SortDir = 'D' then Stock_Category END DESC,
					CASE WHEN @SortCol = 'Stock_Category' and @SortDir != 'D' then Stock_Category END,
					CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir = 'D' then Item_Type_Attribute END DESC,
					CASE WHEN @SortCol = 'Item_Type_Attribute' and @SortDir != 'D' then Item_Type_Attribute END,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir = 'D' then Dept_ID END DESC,
					CASE WHEN @SortCol = 'Dept_ID' and @SortDir != 'D' then Dept_ID END
		DROP table #Results

	END -- My Items
ELSE
BEGIN
	set @totalRows = 0
	RAISError('Invalid Parameters Passed to usp_SPD_GetIMBatches_MyItems_PS Query. User_ID: %d Stage_ID: %d',
				16,
				1,
				@UserID, @StageId)
END

RETURN @totalRows

END


