
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
	@CanadaHarmonizedCodeNumber varchar(10) = Null,
	@SuppTariffPercent varchar(100) = null,
	@SuppTariffAmount varchar(100) = null
	
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
			CanadaHarmonizedCodeNumber = @CanadaHarmonizedCodeNumber,
			SuppTariffPercent = @SuppTariffPercent,
			SuppTariffAmount = @SuppTariffAmount
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
			CanadaHarmonizedCodeNumber,
			SuppTariffPercent,
			SuppTariffAmount
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
			@CanadaHarmonizedCodeNumber,
			@SuppTariffPercent,
			@SuppTariffAmount
		)
		SET @ID = SCOPE_IDENTITY()
	END

GO



ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_GetListCount] 
  @batchID bigint = 0,
	@xmlSortCriteria varchar(8000) = null,
  @userID bigint = 0,
  @printDebugMsgs bit = 0
	
AS


  DECLARE @intXMLDocHandle int
  DECLARE @strXMLDoc varchar(8000)
  DECLARE @intTempFilterCol int
  DECLARE @strTempFilterCriteria varchar(8000)
  DECLARE @strTempFilterConjunction varchar(3)
  DECLARE @strTempFilterOp varchar(20)

  DECLARE @strBlock varchar(8000)
  DECLARE @strSelect varchar(8000)

  DECLARE @blnUseFT bit 
  DECLARE @strFTColumn varchar(8000)
  DECLARE @strFTFilter varchar(8000)
  DECLARE @strFilter varchar(8000)


  SET @strXMLDoc = @xmlSortCriteria
  EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc

  SET @blnUseFT = 0
  SET @strFTColumn = ''
  SET @strFTFilter = ''


/*=================================================================================================
  Sniff to see if we need to do a full-text search.
  =================================================================================================*/
  DECLARE myCursor CURSOR FOR 
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
  Set filter parameters (WHERE clause)
  =================================================================================================*/

  DECLARE @typeNumber varchar(10),
          @typeDate varchar(10),
          @typeString varchar(10)

  SET @typeNumber = 'number'
  SET @typeDate = 'date'
  SET @typeString = 'string'

  IF (COALESCE(@batchID,0) > 0)
  BEGIN
    SET @strFilter = 'i.BatchID = ' + CONVERT(varchar(40), @batchID)
  END

  DECLARE myCursor CURSOR FOR 
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
		WHEN 1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKU]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 2 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 3 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrimaryUPC]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 4 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemStatus]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 5 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorStyleNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 6 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalUPCs]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 7 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemDesc]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 8 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 9 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SubClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 10 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrivateBrandLabel]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 11 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PackItemIndicator]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 12 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QtyInPack]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 13 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesMasterCase]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 14 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesInnerPack]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 15 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AllowStoreOrder]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 16 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InventoryControl]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 17 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Discountable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 18 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AutoReplenish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 19 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePriced]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 20 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePricedUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 21 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DisplayerCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 22 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 23 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 24 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 25 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 26 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 27 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 28 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 29 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 30 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 31 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 32 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 33 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 34 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 35 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 36 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 37 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 38 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 39 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 40 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 41 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 42 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 43 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CountryOfOriginName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 44 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 45 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxValueUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 46 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorOrAgent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 47 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DisplayerCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 48 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ProductCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 49 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyComment]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria) 
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                           
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                        
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                       
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)           
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                               
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ExemptEndDateFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
	    WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DetailInvoiceCustomsDesc0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
	    WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
	    WHEN 104 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImageID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                
	    WHEN 105 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDSID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                 
 
   
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
	   SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (I.SKU in (select michaels_sku from SPD_Item_Master_SKU im where contains (im.*, @strFTFilter) 
union select it.Michaels_SKU from SPD_Item_Master_Changes ch, SPD_Item_Maint_Items it where field_value like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' and ch.Item_Maint_Items_ID = it.ID and it.Batch_ID = ' + convert(varchar, @batchID) + '
union select Michaels_SKU from SPD_Item_Master_Vendor where Vendor_Style_Num like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' )))) ' 

--		SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (CONTAINS(i.*, @strFTFilter)))) ' 
  END

  IF (@printDebugMsgs = 1) PRINT 'WHERE ' + @strFilter





	SET @strSelect = 'SELECT COUNT(i.[ID]) AS RecordCount FROM [dbo].[vwItemMaintItemDetail] i '
  IF(@strFilter != '') set @strSelect = @strSelect + ' where ' + @strFilter

  EXEC(@strBlock + @strSelect)

  IF (@printDebugMsgs = 1) PRINT @strBlock + @strSelect

  EXEC sp_xml_removedocument @intXMLDocHandle    

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_GetList] 
  @batchID bigint = 0,
	@startRow int = 0,
  @pageSize int = 0,
	@xmlSortCriteria text = null,
  @userID bigint = 0,
  @printDebugMsgs bit = 0
	
AS

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
  DECLARE myCursor CURSOR FOR 
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
--  SET @strFields = @strFields + '
--    (LTRIM(RTRIM((isnull(su1.First_Name, '''') + '' '' + isnull(su1.Last_Name, ''''))))) as Created_User,
--    (LTRIM(RTRIM((isnull(su2.First_Name, '''') + '' '' + isnull(su2.Last_Name, ''''))))) as Update_User,
  SET @strFields = @strFields + '
    COALESCE(b.ID, 0) as Batch_ID,
    COALESCE(s.ID, 0) as Stage_ID,
    COALESCE(s.stage_name, '''') as Stage_Name,
    COALESCE(s.Stage_Type_id, 0) as Stage_Type_ID,
    f1.[File_ID] as Image_ID,
    f2.[File_ID] as MSDS_ID,
    silsE.Package_Language_Indicator as PLI_English,
	silsF.Package_Language_Indicator as PLI_French,
	silsS.Package_Language_Indicator as PLI_Spanish,
	silE.Translation_Indicator as TI_English,
	silF.Translation_Indicator as TI_French,
	COALESCE(silS.Translation_Indicator, ''N'') as TI_Spanish,
	silE.Description_Long as English_Long_Description,
	silE.Description_Short as English_Short_Description,
	silF.Description_Long as French_Long_Description,
	silF.Description_Short as French_Short_Description,
	silS.Description_Long as Spanish_Long_Description,
	silS.Description_Short as Spanish_Short_Description,
	silsF.Exempt_End_Date as Exempt_End_Date_French
  '

  IF (@printDebugMsgs = 1) PRINT 'SELECT ' + @strFields

  /*=================================================================================================
  Set tables to be accessed (FROM statement)
  =================================================================================================*/
  SET @strTables = '[dbo].[vwItemMaintItemDetail] i WITH (NOLOCK)
    INNER JOIN [SPD_Batch] b ON i.BatchID = b.ID
    LEFT OUTER JOIN [SPD_Workflow_Stage] s on b.Workflow_Stage_ID = s.ID
    LEFT OUTER JOIN [SPD_Items_Files] f1 ON f1.Item_Type = ''M'' and f1.Item_ID = i.[ID] and f1.File_Type = ''IMG'' 
    LEFT OUTER JOIN [SPD_Items_Files] f2 ON f2.Item_Type = ''M'' and f2.Item_ID = i.[ID] and f2.File_Type = ''MSDS'' 
    LEFT OUTER JOIN [SPD_Item_Master_Languages] as silE on silE.Michaels_SKU = i.SKU AND  silE.Language_Type_ID = 1
    LEFT OUTER JOIN [SPD_Item_Master_Languages] as silF on silF.Michaels_SKU = i.SKU AND  silF.Language_Type_ID = 2
    LEFT OUTER JOIN [SPD_Item_Master_Languages] as silS on silS.Michaels_SKU = i.SKU AND  silS.Language_Type_ID = 3
    LEFT OUTER JOIN [SPD_Item_Master_Languages_Supplier] as silsE on silsE.Michaels_SKU = i.SKU AND silsE.Vendor_Number = i.VendorNumber AND  silsE.Language_Type_ID = 1
    LEFT OUTER JOIN [SPD_Item_Master_Languages_Supplier] as silsF on silsF.Michaels_SKU = i.SKU AND silsF.Vendor_Number = i.VendorNumber AND silsF.Language_Type_ID = 2
    LEFT OUTER JOIN [SPD_Item_Master_Languages_Supplier] as silsS on silsS.Michaels_SKU = i.SKU AND silsS.Vendor_Number = i.VendorNumber AND silsS.Language_Type_ID = 3
  '
--    LEFT OUTER JOIN [Security_User] su1 ON su1.ID = i.Created_User_ID 
--    LEFT OUTER JOIN [Security_User] su2 ON su2.ID = i.Update_User_ID


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

  IF (COALESCE(@batchID,0) > 0)
  BEGIN
    SET @strFilter = 'i.BatchID = ' + CONVERT(varchar(40), @batchID)
  END

  DECLARE myCursor CURSOR FOR 
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
		WHEN 1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKU]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 2 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 3 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrimaryUPC]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 4 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemStatus]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 5 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorStyleNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 6 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalUPCs]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 7 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemDesc]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 8 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 9 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SubClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 10 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrivateBrandLabel]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 11 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PackItemIndicator]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 12 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QtyInPack]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 13 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesMasterCase]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 14 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesInnerPack]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 15 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AllowStoreOrder]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 16 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InventoryControl]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 17 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Discountable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 18 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AutoReplenish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 19 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePriced]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 20 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePricedUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 21 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DisplayerCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 22 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 23 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 24 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 25 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 26 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 27 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 28 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 29 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 30 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 31 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 32 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 33 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 34 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 35 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 36 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 37 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 38 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 39 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 40 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 41 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	      --WHEN 42 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 43 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CountryOfOriginName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 44 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 45 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxValueUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 46 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorOrAgent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 47 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DisplayerCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 48 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ProductCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 49 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyComment]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria) 
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                           
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                        
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                       
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)           
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                               
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ExemptEndDateFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
	       WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DetailInvoiceCustomsDesc0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
	       WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
	       WHEN 104 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImageID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                
	       WHEN 105 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDSID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                 
     
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
	   SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (I.SKU in (select michaels_sku from SPD_Item_Master_SKU im where contains (im.*, @strFTFilter) 
union select it.Michaels_SKU from SPD_Item_Master_Changes ch, SPD_Item_Maint_Items it where field_value like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' and ch.Item_Maint_Items_ID = it.ID and it.Batch_ID = ' + convert(varchar, @batchID) + '
union select Michaels_SKU from SPD_Item_Master_Vendor where Vendor_Style_Num like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' )))) ' 

--   SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (CONTAINS(i.*, @strFTFilter)))) ' 
  END

  IF (@printDebugMsgs = 1) PRINT 'WHERE ' + @strFilter


  /*=================================================================================================
  Set sort parameters (ORDER BY clause)
  =================================================================================================*/
  SET @strSort = ''
  DECLARE myCursor CURSOR FOR 
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

		WHEN  0 THEN 'i.[ID] ' + @strTempSortDir
		WHEN 1 THEN 'i.[SKU] ' + @strTempSortDir 
		WHEN 2 THEN 'i.[VendorNumber] ' + @strTempSortDir 
		WHEN 3 THEN 'i.[PrimaryUPC] ' + @strTempSortDir 
		WHEN 4 THEN 'i.[ItemStatus] ' + @strTempSortDir 
		WHEN 5 THEN 'i.[VendorStyleNum] ' + @strTempSortDir 
		WHEN 6 THEN 'i.[AdditionalUPCs] ' + @strTempSortDir 
		WHEN 7 THEN 'i.[ItemDesc] ' + @strTempSortDir 
		WHEN 8 THEN 'i.[ClassNum] ' + @strTempSortDir 
		WHEN 9 THEN 'i.[SubClassNum] ' + @strTempSortDir 
		WHEN 10 THEN 'i.[PrivateBrandLabel] ' + @strTempSortDir 
		WHEN 11 THEN 'i.[PackItemIndicator] ' + @strTempSortDir 
		WHEN 12 THEN 'i.[QtyInPack] ' + @strTempSortDir 
		WHEN 13 THEN 'i.[EachesMasterCase] ' + @strTempSortDir 
		WHEN 14 THEN 'i.[EachesInnerPack] ' + @strTempSortDir 
		WHEN 15 THEN 'i.[AllowStoreOrder] ' + @strTempSortDir 
		WHEN 16 THEN 'i.[InventoryControl] ' + @strTempSortDir 
		WHEN 17 THEN 'i.[Discountable] ' + @strTempSortDir 
		WHEN 18 THEN 'i.[AutoReplenish] ' + @strTempSortDir 
		WHEN 19 THEN 'i.[PrePriced] ' + @strTempSortDir 
		WHEN 20 THEN 'i.[PrePricedUDA] ' + @strTempSortDir 
		WHEN 21 THEN 'i.[DisplayerCost] ' + @strTempSortDir 
		WHEN 22 THEN 'i.[ItemCost] ' + @strTempSortDir 
		WHEN 23 THEN 'i.[FOBShippingPoint] ' + @strTempSortDir 
		WHEN 24 THEN 'i.[EachCaseHeight] ' + @strTempSortDir 
		WHEN 25 THEN 'i.[EachCaseWidth] ' + @strTempSortDir 
		WHEN 26 THEN 'i.[EachCaseLength] ' + @strTempSortDir 
		WHEN 27 THEN 'i.[EachCaseCube] ' + @strTempSortDir 
		WHEN 28 THEN 'i.[EachCaseWeight] ' + @strTempSortDir 
		WHEN 29 THEN 'i.[InnerCaseHeight] ' + @strTempSortDir 
		WHEN 30 THEN 'i.[InnerCaseWidth] ' + @strTempSortDir 
		WHEN 31 THEN 'i.[InnerCaseLength] ' + @strTempSortDir 
		WHEN 32 THEN 'i.[InnerCaseCube] ' + @strTempSortDir 
	      --WHEN 33 THEN 'i.[InnerCaseCubeUOM] ' + @strTempSortDir 
		WHEN 34 THEN 'i.[InnerCaseWeight] ' + @strTempSortDir 
	      --WHEN 35 THEN 'i.[InnerCaseWeightUOM] ' + @strTempSortDir 
		WHEN 36 THEN 'i.[MasterCaseHeight] ' + @strTempSortDir 
		WHEN 37 THEN 'i.[MasterCaseWidth] ' + @strTempSortDir 
		WHEN 38 THEN 'i.[MasterCaseLength] ' + @strTempSortDir 
		WHEN 39 THEN 'i.[MasterCaseCube] ' + @strTempSortDir 
	      --WHEN 40 THEN 'i.[MasterCaseCubeUOM] ' + @strTempSortDir 
		WHEN 41 THEN 'i.[MasterCaseWeight] ' + @strTempSortDir 
	      --WHEN 42 THEN 'i.[MasterCaseWeightUOM] ' + @strTempSortDir 
		WHEN 43 THEN 'i.[CountryOfOriginName] ' + @strTempSortDir 
		WHEN 44 THEN 'i.[TaxUDA] ' + @strTempSortDir 
		WHEN 45 THEN 'i.[TaxValueUDA] ' + @strTempSortDir 
		WHEN 46 THEN 'i.[VendorOrAgent] ' + @strTempSortDir 
		WHEN 47 THEN 'i.[DisplayerCost] ' + @strTempSortDir 
		WHEN 48 THEN 'i.[ProductCost] ' + @strTempSortDir 
		WHEN 49 THEN 'i.[FOBShippingPoint] ' + @strTempSortDir 
		WHEN 50 THEN 'i.[DutyPercent] ' + @strTempSortDir 
		WHEN 51 THEN 'i.[DutyAmount] ' + @strTempSortDir 
		WHEN 52 THEN 'i.[AdditionalDutyComment] ' + @strTempSortDir 
		WHEN 53 THEN 'i.[AdditionalDutyAmount] ' + @strTempSortDir 
		WHEN 54 THEN 'i.[SuppTariffPercent] ' + @strTempSortDir 
		WHEN 55 THEN 'i.[SuppTariffAmount] ' + @strTempSortDir 
		WHEN 56 THEN 'i.[OceanFreightAmount] ' + @strTempSortDir                                          
		WHEN 57 THEN 'i.[OceanFreightComputedAmount] ' + @strTempSortDir                                  
		WHEN 58 THEN 'i.[AgentCommissionPercent] ' + @strTempSortDir                                      
		WHEN 59 THEN 'i.[AgentCommissionAmount] ' + @strTempSortDir                                       
		WHEN 60 THEN 'i.[OtherImportCostsPercent] ' + @strTempSortDir                                     
		WHEN 61 THEN 'i.[OtherImportCostsAmount] ' + @strTempSortDir                                      
		WHEN 62 THEN 'i.[ImportBurden] ' + @strTempSortDir                                                
		WHEN 63 THEN 'i.[WarehouseLandedCost] ' + @strTempSortDir                                         
		WHEN 64 THEN 'i.[OutboundFreight] ' + @strTempSortDir                                             
		WHEN 65 THEN 'i.[NinePercentWhseCharge] ' + @strTempSortDir                                       
		WHEN 66 THEN 'i.[TotalStoreLandedCost] ' + @strTempSortDir                                        
		WHEN 67 THEN 'i.[ShippingPoint] ' + @strTempSortDir                                               
		WHEN 68 THEN 'i.[PlanogramName] ' + @strTempSortDir                                               
		WHEN 69 THEN 'i.[Hazardous] ' + @strTempSortDir                                                   
		WHEN 70 THEN 'i.[HazardousFlammable] ' + @strTempSortDir                                          
		WHEN 71 THEN 'i.[HazardousContainerType] ' + @strTempSortDir                                      
		WHEN 72 THEN 'i.[HazardousContainerSize] ' + @strTempSortDir                                      
		WHEN 73 THEN 'i.[HazardousMSDSUOM] ' + @strTempSortDir                                            
		WHEN 74 THEN 'i.[HazardousManufacturerName] ' + @strTempSortDir                                   
		WHEN 75 THEN 'i.[HazardousManufacturerCity] ' + @strTempSortDir                                   
		WHEN 76 THEN 'i.[HazardousManufacturerState] ' + @strTempSortDir                                  
		WHEN 79 THEN 'i.[HazardousManufacturerPhone] ' + @strTempSortDir                                  
		WHEN 80 THEN 'i.[HazardousManufacturerCountry] ' + @strTempSortDir                                
		WHEN 81 THEN 'i.[QuoteReferenceNumber] ' + @strTempSortDir                                        
		WHEN 82 THEN 'i.[PLIEnglish] ' + @strTempSortDir                                                  
		WHEN 84 THEN 'i.[PLIFrench] ' + @strTempSortDir                                                   
		WHEN 85 THEN 'i.[PLISpanish] ' + @strTempSortDir                                                  
		WHEN 86 THEN 'i.[TIEnglish] ' + @strTempSortDir                                                   
		WHEN 87 THEN 'i.[TIFrench] ' + @strTempSortDir                                                    
		WHEN 88 THEN 'i.[TISpanish] ' + @strTempSortDir                                                   
		WHEN 89 THEN 'i.[CustomsDescription] ' + @strTempSortDir                                          
		WHEN 90 THEN 'i.[EnglishShortDescription] ' + @strTempSortDir                                     
		WHEN 91 THEN 'i.[EnglishLongDescription] ' + @strTempSortDir                                      
		WHEN 92 THEN 'i.[FrenchShortDescription] ' + @strTempSortDir                                      
		WHEN 93 THEN 'i.[FrenchLongDescription] ' + @strTempSortDir                                       
		WHEN 94 THEN 'i.[SpanishShortDescription] ' + @strTempSortDir                                     
		WHEN 95 THEN 'i.[SpanishLongDescription] ' + @strTempSortDir                                      
		WHEN 96 THEN 'i.[ExemptEndDateFrench] ' + @strTempSortDir                                         
		WHEN 97 THEN 'i.[HarmonizedCodeNumber] ' + @strTempSortDir                                        
		WHEN 98 THEN 'i.[CanadaHarmonizedCodeNumber] ' + @strTempSortDir                                  
	       WHEN 102 THEN 'i.[DetailInvoiceCustomsDesc0] ' + @strTempSortDir                                   
	       WHEN 103 THEN 'i.[ComponentMaterialBreakdown0] ' + @strTempSortDir                                 
	       WHEN 104 THEN 'i.[ImageID] ' + @strTempSortDir                                                     
	       WHEN 105 THEN 'i.[MSDSID] ' + @strTempSortDir                                                      

      
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




SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[usp_SPD_BulkItemMaint_GetListCount] 
  @batchID bigint = 0,
	@xmlSortCriteria varchar(8000) = null,
  @userID bigint = 0,
  @printDebugMsgs bit = 0
	
AS


  DECLARE @intXMLDocHandle int
  DECLARE @strXMLDoc varchar(8000)
  DECLARE @intTempFilterCol int
  DECLARE @strTempFilterCriteria varchar(8000)
  DECLARE @strTempFilterConjunction varchar(3)
  DECLARE @strTempFilterOp varchar(20)

  DECLARE @strBlock varchar(8000)
  DECLARE @strSelect varchar(8000)

  DECLARE @blnUseFT bit 
  DECLARE @strFTColumn varchar(8000)
  DECLARE @strFTFilter varchar(8000)
  DECLARE @strFilter varchar(8000)


  SET @strXMLDoc = @xmlSortCriteria
  EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc

  SET @blnUseFT = 0
  SET @strFTColumn = ''
  SET @strFTFilter = ''


/*=================================================================================================
  Sniff to see if we need to do a full-text search.
  =================================================================================================*/
  DECLARE myCursor CURSOR FOR 
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
  Set filter parameters (WHERE clause)
  =================================================================================================*/

  DECLARE @typeNumber varchar(10),
          @typeDate varchar(10),
          @typeString varchar(10)

  SET @typeNumber = 'number'
  SET @typeDate = 'date'
  SET @typeString = 'string'

  IF (COALESCE(@batchID,0) > 0)
  BEGIN
    SET @strFilter = 'i.BatchID = ' + CONVERT(varchar(40), @batchID)
  END

  DECLARE myCursor CURSOR FOR 
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
		WHEN 1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKU]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 2 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 3 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 4 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 5 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorStyleNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 6 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKUGroup]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 7 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrimaryUPC]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 8 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemDesc]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 9 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DepartmentNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 10 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 11 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SubClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 12 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrivateBrandLabel]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 13 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemTypeAttribute]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 14 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PackItemIndicator]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 15 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesMasterCase]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 16 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesInnerPack]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 17 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AllowStoreOrder]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 18 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InventoryControl]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 19 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Discountable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 20 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AutoReplenish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 21 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePriced]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 22 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePricedUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 23 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 24 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 25 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ProductCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 26 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 27 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 28 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 29 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 30 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 31 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 32 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 33 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 34 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 35 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 36 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 37 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 38 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 39 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 40 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 41 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 42 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CountryOfOriginName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 43 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 44 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxValueUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 45 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorOrAgent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 46 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 47 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 48 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyComment]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 49 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)         
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                       
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)          
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)          
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)         
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)         
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)       
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                         
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                           
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)         
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)        
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentConstructionMethod0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)       
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                               
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[UL]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                 
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[LicenceAgreement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FumigationCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[KILNDriedCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ChinaComInspecNumAndCCIBStickers]', @typeString, @strTempFilterOp, @strTempFilterCriteria)   
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OriginalVisa]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                       
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TextileDeclarationMidCode]', @typeString, @strTempFilterOp, @strTempFilterCriteria)          
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuotaChargeStatement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                               
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSCA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                               
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DropBallTestCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 99 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManMedicalDeviceListing]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
	       WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManFDARegistration]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
	       WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CopyRightIndemnification]', @typeString, @strTempFilterOp, @strTempFilterCriteria)           
	       WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FishWildLifeCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
	       WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Proposition65LabelReq]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
	       WHEN 104 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CCCR]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                
	       WHEN 105 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FormaldehydeCompliant]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
      
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
	   SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (I.SKU in (select michaels_sku from SPD_Item_Master_SKU im where contains (im.*, @strFTFilter) 
union select it.Michaels_SKU from SPD_Item_Master_Changes ch, SPD_Item_Maint_Items it where field_value like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' and ch.Item_Maint_Items_ID = it.ID and it.Batch_ID = ' + convert(varchar, @batchID) + '
union select Michaels_SKU from SPD_Item_Master_Vendor where Vendor_Style_Num like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' )))) ' 

--		SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (CONTAINS(i.*, @strFTFilter)))) ' 
  END

  IF (@printDebugMsgs = 1) PRINT 'WHERE ' + @strFilter





	SET @strSelect = 'SELECT COUNT(i.[ID]) AS RecordCount FROM [dbo].[vwItemMaintItemDetail] i '
  IF(@strFilter != '') set @strSelect = @strSelect + ' where ' + @strFilter

  EXEC(@strBlock + @strSelect)

  IF (@printDebugMsgs = 1) PRINT @strBlock + @strSelect

  EXEC sp_xml_removedocument @intXMLDocHandle    

GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[usp_SPD_BulkItemMaint_GetList] 
  @batchID bigint = 0,
	@startRow int = 0,
  @pageSize int = 0,
	@xmlSortCriteria text = null,
  @userID bigint = 0,
  @printDebugMsgs bit = 0
	
AS

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
  DECLARE myCursor CURSOR FOR 
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
--  SET @strFields = @strFields + '
--    (LTRIM(RTRIM((isnull(su1.First_Name, '''') + '' '' + isnull(su1.Last_Name, ''''))))) as Created_User,
--    (LTRIM(RTRIM((isnull(su2.First_Name, '''') + '' '' + isnull(su2.Last_Name, ''''))))) as Update_User,
  SET @strFields = @strFields + '
    COALESCE(b.ID, 0) as Batch_ID,
    COALESCE(s.ID, 0) as Stage_ID,
    COALESCE(s.stage_name, '''') as Stage_Name,
    COALESCE(s.Stage_Type_id, 0) as Stage_Type_ID,
    f1.[File_ID] as Image_ID,
    f2.[File_ID] as MSDS_ID,
    silsE.Package_Language_Indicator as PLI_English,
	silsF.Package_Language_Indicator as PLI_French,
	silsS.Package_Language_Indicator as PLI_Spanish,
	silE.Translation_Indicator as TI_English,
	silF.Translation_Indicator as TI_French,
	COALESCE(silS.Translation_Indicator, ''N'') as TI_Spanish,
	silE.Description_Long as English_Long_Description,
	silE.Description_Short as English_Short_Description,
	silF.Description_Long as French_Long_Description,
	silF.Description_Short as French_Short_Description,
	silS.Description_Long as Spanish_Long_Description,
	silS.Description_Short as Spanish_Short_Description,
	silsF.Exempt_End_Date as Exempt_End_Date_French
  '

  IF (@printDebugMsgs = 1) PRINT 'SELECT ' + @strFields

  /*=================================================================================================
  Set tables to be accessed (FROM statement)
  =================================================================================================*/
  SET @strTables = '[dbo].[vwItemMaintItemDetail] i WITH (NOLOCK)
    INNER JOIN [SPD_Batch] b ON i.BatchID = b.ID
    LEFT OUTER JOIN [SPD_Workflow_Stage] s on b.Workflow_Stage_ID = s.ID
    LEFT OUTER JOIN [SPD_Items_Files] f1 ON f1.Item_Type = ''M'' and f1.Item_ID = i.[ID] and f1.File_Type = ''IMG'' 
    LEFT OUTER JOIN [SPD_Items_Files] f2 ON f2.Item_Type = ''M'' and f2.Item_ID = i.[ID] and f2.File_Type = ''MSDS'' 
    LEFT OUTER JOIN [SPD_Item_Master_Languages] as silE on silE.Michaels_SKU = i.SKU AND  silE.Language_Type_ID = 1
    LEFT OUTER JOIN [SPD_Item_Master_Languages] as silF on silF.Michaels_SKU = i.SKU AND  silF.Language_Type_ID = 2
    LEFT OUTER JOIN [SPD_Item_Master_Languages] as silS on silS.Michaels_SKU = i.SKU AND  silS.Language_Type_ID = 3
    LEFT OUTER JOIN [SPD_Item_Master_Languages_Supplier] as silsE on silsE.Michaels_SKU = i.SKU AND silsE.Vendor_Number = i.VendorNumber AND  silsE.Language_Type_ID = 1
    LEFT OUTER JOIN [SPD_Item_Master_Languages_Supplier] as silsF on silsF.Michaels_SKU = i.SKU AND silsF.Vendor_Number = i.VendorNumber AND silsF.Language_Type_ID = 2
    LEFT OUTER JOIN [SPD_Item_Master_Languages_Supplier] as silsS on silsS.Michaels_SKU = i.SKU AND silsS.Vendor_Number = i.VendorNumber AND silsS.Language_Type_ID = 3
  '
--    LEFT OUTER JOIN [Security_User] su1 ON su1.ID = i.Created_User_ID 
--    LEFT OUTER JOIN [Security_User] su2 ON su2.ID = i.Update_User_ID


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

  IF (COALESCE(@batchID,0) > 0)
  BEGIN
    SET @strFilter = 'i.BatchID = ' + CONVERT(varchar(40), @batchID)
  END

  DECLARE myCursor CURSOR FOR 
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
		WHEN 1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKU]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 2 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 3 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 4 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 5 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorStyleNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 6 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKUGroup]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 7 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrimaryUPC]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 8 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemDesc]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 9 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DepartmentNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 10 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 11 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SubClassNum]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 12 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrivateBrandLabel]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 13 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemTypeAttribute]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 14 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PackItemIndicator]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 15 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesMasterCase]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 16 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachesInnerPack]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 17 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AllowStoreOrder]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 18 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InventoryControl]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 19 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Discountable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 20 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AutoReplenish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 21 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePriced]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 22 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrePricedUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 23 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 24 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 25 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ProductCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 26 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 27 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 28 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 29 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 30 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 31 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 32 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 33 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 34 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 35 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 36 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 37 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 38 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 39 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 40 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 41 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 42 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CountryOfOriginName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 43 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 44 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TaxValueUDA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 45 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorOrAgent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 46 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 47 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 48 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyComment]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 49 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AdditionalDutyAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                       
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                         
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                         
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)          
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                            
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)           
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentConstructionMethod0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)          
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                  
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                   
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[UL]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                    
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[LicenceAgreement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FumigationCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[KILNDriedCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ChinaComInspecNumAndCCIBStickers]', @typeString, @strTempFilterOp, @strTempFilterCriteria)      
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OriginalVisa]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TextileDeclarationMidCode]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuotaChargeStatement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                  
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSCA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                  
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DropBallTestCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 99 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManMedicalDeviceListing]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
	       WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManFDARegistration]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
	       WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CopyRightIndemnification]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
	       WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FishWildLifeCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
	       WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Proposition65LabelReq]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
	       WHEN 104 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CCCR]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                   
	       WHEN 105 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FormaldehydeCompliant]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  

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
	   SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (I.SKU in (select michaels_sku from SPD_Item_Master_SKU im where contains (im.*, @strFTFilter) 
union select it.Michaels_SKU from SPD_Item_Master_Changes ch, SPD_Item_Maint_Items it where field_value like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' and ch.Item_Maint_Items_ID = it.ID and it.Batch_ID = ' + convert(varchar, @batchID) + '
union select Michaels_SKU from SPD_Item_Master_Vendor where Vendor_Style_Num like ''%' + REPLACE(@strFTFilter, '''', '''''') + '%'' )))) ' 

--   SET @strFilter = @strFilter + '((ISNULL(@strFTFilter, '''') = '''') OR (@strFTFilter IS NOT NULL AND (CONTAINS(i.*, @strFTFilter)))) ' 
  END

  IF (@printDebugMsgs = 1) PRINT 'WHERE ' + @strFilter


  /*=================================================================================================
  Set sort parameters (ORDER BY clause)
  =================================================================================================*/
  SET @strSort = ''
  DECLARE myCursor CURSOR FOR 
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
		WHEN 1 THEN 'i.[SKU] ' + @strTempSortDir 
		WHEN 2 THEN 'i.[VendorNumber] ' + @strTempSortDir 
		WHEN 3 THEN 'i.[VendorName] ' + @strTempSortDir 
		WHEN 4 THEN 'i.[VendorType] ' + @strTempSortDir 
		WHEN 5 THEN 'i.[VendorStyleNum] ' + @strTempSortDir 
		WHEN 6 THEN 'i.[SKUGroup] ' + @strTempSortDir 
		WHEN 7 THEN 'i.[PrimaryUPC] ' + @strTempSortDir 
		WHEN 8 THEN 'i.[ItemDesc] ' + @strTempSortDir 
		WHEN 9 THEN 'i.[DepartmentNum] ' + @strTempSortDir 
		WHEN 10 THEN 'i.[ClassNum] ' + @strTempSortDir 
		WHEN 11 THEN 'i.[SubClassNum] ' + @strTempSortDir 
		WHEN 12 THEN 'i.[PrivateBrandLabel] ' + @strTempSortDir 
		WHEN 13 THEN 'i.[ItemTypeAttribute] ' + @strTempSortDir 
		WHEN 14 THEN 'i.[PackItemIndicator] ' + @strTempSortDir 
		WHEN 15 THEN 'i.[EachesMasterCase] ' + @strTempSortDir 
		WHEN 16 THEN 'i.[EachesInnerPack] ' + @strTempSortDir 
		WHEN 17 THEN 'i.[AllowStoreOrder] ' + @strTempSortDir 
		WHEN 18 THEN 'i.[InventoryControl] ' + @strTempSortDir 
		WHEN 19 THEN 'i.[Discountable] ' + @strTempSortDir 
		WHEN 20 THEN 'i.[AutoReplenish] ' + @strTempSortDir 
		WHEN 21 THEN 'i.[PrePriced] ' + @strTempSortDir 
		WHEN 22 THEN 'i.[PrePricedUDA] ' + @strTempSortDir 
		WHEN 23 THEN 'i.[ItemCost] ' + @strTempSortDir 
		WHEN 24 THEN 'i.[FOBShippingPoint] ' + @strTempSortDir 
		WHEN 25 THEN 'i.[ProductCost] ' + @strTempSortDir 
		WHEN 26 THEN 'i.[FOBShippingPoint] ' + @strTempSortDir 
		WHEN 27 THEN 'i.[EachCaseHeight] ' + @strTempSortDir 
		WHEN 28 THEN 'i.[EachCaseWidth] ' + @strTempSortDir 
		WHEN 29 THEN 'i.[EachCaseLength] ' + @strTempSortDir 
		WHEN 30 THEN 'i.[EachCaseCube] ' + @strTempSortDir 
		WHEN 31 THEN 'i.[EachCaseWeight] ' + @strTempSortDir 
		WHEN 32 THEN 'i.[InnerCaseHeight] ' + @strTempSortDir 
		WHEN 33 THEN 'i.[InnerCaseWidth] ' + @strTempSortDir 
		WHEN 34 THEN 'i.[InnerCaseLength] ' + @strTempSortDir 
		WHEN 35 THEN 'i.[InnerCaseCube] ' + @strTempSortDir 
		WHEN 36 THEN 'i.[InnerCaseWeight] ' + @strTempSortDir 
		WHEN 37 THEN 'i.[MasterCaseHeight] ' + @strTempSortDir 
		WHEN 38 THEN 'i.[MasterCaseWidth] ' + @strTempSortDir 
		WHEN 39 THEN 'i.[MasterCaseLength] ' + @strTempSortDir 
		WHEN 40 THEN 'i.[MasterCaseCube] ' + @strTempSortDir 
		WHEN 41 THEN 'i.[MasterCaseWeight] ' + @strTempSortDir 
		WHEN 42 THEN 'i.[CountryOfOriginName] ' + @strTempSortDir 
		WHEN 43 THEN 'i.[TaxUDA] ' + @strTempSortDir 
		WHEN 44 THEN 'i.[TaxValueUDA] ' + @strTempSortDir 
		WHEN 45 THEN 'i.[VendorOrAgent] ' + @strTempSortDir 
		WHEN 46 THEN 'i.[DutyPercent] ' + @strTempSortDir 
		WHEN 47 THEN 'i.[DutyAmount] ' + @strTempSortDir 
		WHEN 48 THEN 'i.[AdditionalDutyComment] ' + @strTempSortDir 
		WHEN 49 THEN 'i.[AdditionalDutyAmount] ' + @strTempSortDir 
		WHEN 50 THEN 'i.[SuppTariffPercent] ' + @strTempSortDir 
		WHEN 51 THEN 'i.[SuppTariffAmount] ' + @strTempSortDir 
		WHEN 52 THEN 'i.[OceanFreightAmount] ' + @strTempSortDir                              
		WHEN 53 THEN 'i.[OceanFreightComputedAmount] ' + @strTempSortDir                      
		WHEN 54 THEN 'i.[AgentCommissionPercent] ' + @strTempSortDir                          
		WHEN 55 THEN 'i.[AgentCommissionAmount] ' + @strTempSortDir                           
		WHEN 56 THEN 'i.[OtherImportCostsPercent] ' + @strTempSortDir                         
		WHEN 57 THEN 'i.[OtherImportCostsAmount] ' + @strTempSortDir                          
		WHEN 58 THEN 'i.[ImportBurden] ' + @strTempSortDir                                    
		WHEN 59 THEN 'i.[WarehouseLandedCost] ' + @strTempSortDir                             
		WHEN 60 THEN 'i.[OutboundFreight] ' + @strTempSortDir                                 
		WHEN 61 THEN 'i.[NinePercentWhseCharge] ' + @strTempSortDir                           
		WHEN 62 THEN 'i.[TotalStoreLandedCost] ' + @strTempSortDir                            
		WHEN 63 THEN 'i.[ShippingPoint] ' + @strTempSortDir                                   
		WHEN 64 THEN 'i.[PlanogramName] ' + @strTempSortDir                                   
		WHEN 65 THEN 'i.[Hazardous] ' + @strTempSortDir                                       
		WHEN 66 THEN 'i.[HazardousFlammable] ' + @strTempSortDir                              
		WHEN 67 THEN 'i.[HazardousContainerType] ' + @strTempSortDir                          
		WHEN 68 THEN 'i.[HazardousContainerSize] ' + @strTempSortDir                          
		WHEN 69 THEN 'i.[HazardousMSDSUOM] ' + @strTempSortDir                                
		WHEN 70 THEN 'i.[HazardousManufacturerName] ' + @strTempSortDir                       
		WHEN 71 THEN 'i.[HazardousManufacturerCity] ' + @strTempSortDir                       
		WHEN 72 THEN 'i.[HazardousManufacturerState] ' + @strTempSortDir                      
		WHEN 73 THEN 'i.[HazardousManufacturerPhone] ' + @strTempSortDir                      
		WHEN 74 THEN 'i.[HazardousManufacturerCountry] ' + @strTempSortDir                    
		WHEN 75 THEN 'i.[PLIFrench] ' + @strTempSortDir                                       
		WHEN 76 THEN 'i.[PLISpanish] ' + @strTempSortDir                                      
		WHEN 77 THEN 'i.[TIFrench] ' + @strTempSortDir                                        
		WHEN 78 THEN 'i.[TISpanish] ' + @strTempSortDir                                       
		WHEN 79 THEN 'i.[CustomsDescription] ' + @strTempSortDir                              
		WHEN 80 THEN 'i.[EnglishShortDescription] ' + @strTempSortDir                         
		WHEN 81 THEN 'i.[EnglishLongDescription] ' + @strTempSortDir                          
		WHEN 82 THEN 'i.[HarmonizedCodeNumber] ' + @strTempSortDir                            
		WHEN 83 THEN 'i.[CanadaHarmonizedCodeNumber] ' + @strTempSortDir                      
		WHEN 84 THEN 'i.[ComponentMaterialBreakdown0] ' + @strTempSortDir                     
		WHEN 85 THEN 'i.[ComponentConstructionMethod0] ' + @strTempSortDir                    
		WHEN 86 THEN 'i.[TSSA] ' + @strTempSortDir                                            
		WHEN 87 THEN 'i.[CSA] ' + @strTempSortDir                                             
		WHEN 88 THEN 'i.[UL] ' + @strTempSortDir                                              
		WHEN 89 THEN 'i.[LicenceAgreement] ' + @strTempSortDir                                
		WHEN 90 THEN 'i.[FumigationCertificate] ' + @strTempSortDir                           
		WHEN 91 THEN 'i.[KILNDriedCertificate] ' + @strTempSortDir                            
		WHEN 92 THEN 'i.[ChinaComInspecNumAndCCIBStickers] ' + @strTempSortDir                
		WHEN 93 THEN 'i.[OriginalVisa] ' + @strTempSortDir                                    
		WHEN 94 THEN 'i.[TextileDeclarationMidCode] ' + @strTempSortDir                       
		WHEN 95 THEN 'i.[QuotaChargeStatement] ' + @strTempSortDir                            
		WHEN 96 THEN 'i.[MSDS] ' + @strTempSortDir                                            
		WHEN 97 THEN 'i.[TSCA] ' + @strTempSortDir                                            
		WHEN 98 THEN 'i.[DropBallTestCert] ' + @strTempSortDir                                
		WHEN 99 THEN 'i.[ManMedicalDeviceListing] ' + @strTempSortDir                         
	       WHEN 100 THEN 'i.[ManFDARegistration] ' + @strTempSortDir                              
	       WHEN 101 THEN 'i.[CopyRightIndemnification] ' + @strTempSortDir                        
	       WHEN 102 THEN 'i.[FishWildLifeCert] ' + @strTempSortDir                                
	       WHEN 103 THEN 'i.[Proposition65LabelReq] ' + @strTempSortDir                           
	       WHEN 104 THEN 'i.[CCCR] ' + @strTempSortDir                                            
	       WHEN 105 THEN 'i.[FormaldehydeCompliant] ' + @strTempSortDir                           
      
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



ALTER PROCEDURE [dbo].[SPD_Report_SKUDetails] 
	@startDate as Datetime = null,
	@endDate as DateTime = null,
	@dept as integer = null,
	@vendor as bigint = null,
	@vendorFilter as bigint = null,
	@itemStatus as varchar(10) = null,
	@itemType as varchar(20) = null,
	@skuGroup as varchar(50) = null,
	@pliFrench as varchar(10) = null
	
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

If @itemType = '1' 
	set @itemType = '110'
	
If @itemType = '2'
	set @itemType = '300'


SELECT 
		--ITEM MAINT Fields
		s.ID, 
		'System' as Created_By,
		'System' as Last_Modified_By, --This field is always either 0 or -3.  We don't seem to capture this info...
		s.Date_Created, s.Date_Last_Modified, v.Vendor_Number as Vendor_Number, sv.Vendor_Name as Vendor_Name, 
		V.Harmonized_CodeNumber as Harmonized_Code_Number, v.Canada_Harmonized_CodeNumber as Canada_Harmonized_Code_Number,
		s.STOCKING_STRATEGY_CODE as STOCKING_STRATEGY_CODE,
		s.Add_Change, UPPER(s.Item_Type) as Pack_Item_Indicator, s.Michaels_SKU as SKU, UPC.UPC AS Vendor_UPC, s.Department_Num as Department_Number,
		s.Class_Num as Class_Number, s.Sub_Class_Num as Subclass_Number, UPPER(V.Vendor_Style_Num) as Vendor_Style_Num,
		s.Item_Desc, 
		--s.Hybrid_Type, s.Hybrid_Source_DC, s.Hybrid_Lead_Time, s.Hybrid_Conversion_Date, 
		s.STOCKING_STRATEGY_CODE as Stocking_Strategy_Code,
		C.Eaches_Master_Case, C.Eaches_Inner_Pack, 
		CASE WHEN (SELECT COUNT(*) FROM SPD_Item_Master_UDA UDA4 WHERE UDA4.Michaels_SKU = s.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS Pre_Priced,
		(SELECT TOP (1) ISNULL(UDA_Value, 0) AS Expr1 FROM SPD_Item_Master_UDA AS UDA5 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 10)) AS Pre_Priced_UDA,
		C.Unit_Cost, V.Detail_Invoice_Customs_Desc0 as Detail_Invoice_Customs_Desc, V.Component_Material_Breakdown,
		s.Stock_Category,UPPER(s.Item_Type) as Item_Type, s.Item_Type_Attribute, UPPER(s.Inventory_Control) as Inventory_Control, s.SKU_Group,
		s.Base1_Retail, s.Base2_Retail, s.Test_Retail, s.Alaska_Retail, s.Canada_Retail, s.High2_Retail, s.High3_Retail,
		s.Small_Market_Retail, s.High1_Retail, s.Base3_Retail, s.Low1_Retail, s.Low2_Retail, s.Manhattan_Retail, s.Quebec_Retail as Q5_Retail,s.PuertoRico_Retail as PR_Retail,
		s.POG_Setup_Per_Store as Initial_Set_Qty_Per_Store, s.WHS_Supplier_Zone_Group, s.POG_Comp_Date, 
		C.Each_Case_Height, C.Each_Case_Width, C.Each_Case_Length, C.Each_Case_Weight, C.Each_Case_Cube as Each_Case_Pack_Cube,
		C.Inner_Case_Height, C.Inner_Case_Width, C.Inner_Case_Length, C.Inner_Case_Weight, C.Inner_Case_Cube as Inner_Case_Pack_Cube,
		C.Master_Case_Height, C.Master_Case_Width, C.Master_Case_Length, C.Master_Case_Weight, C.Master_Case_Cube as Master_Case_Pack_Cube,  
		UPPER(s.Hazardous) AS Hazardous, UPPER(s.Hazardous_Flammable) AS Hazardous_Flammable, UPPER(s.Hazardous_Container_Type) as Hazardous_Container_Type,
		s.Hazardous_Container_Size, UPPER(s.Hazardous_MSDS_UOM) as Hazardous_MSDS_UOM, v.Hazardous_Manufacturer_Name, v.Hazardous_Manufacturer_City, 
		v.Hazardous_Manufacturer_State, v.Hazardous_Manufacturer_Phone, v.Hazardous_Manufacturer_Country, 
		v.Image_ID as Image_ID, v.MSDS_ID as MSDS_ID, 
		s.Season, UPPER(s.Allow_Store_Order) as Allow_Store_Order, s.Store_Supplier_Zone_Group, s.RMS_Sellable, s.Store_Total,
		C.Country_Of_Origin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS Country_Of_Origin_Name, 
		(SELECT UDA_Value FROM SPD_Item_Master_UDA AS UDA WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID = 11)) AS PrivateBrandLabel,
		s.Customs_Description,
		simlsE.Package_Language_Indicator as Package_Language_Indicator_English,   
		simlsF.Package_Language_Indicator as Package_Language_Indicator_French,   
		simlsS.Package_Language_Indicator as Package_Language_Indicator_Spanish,      
		simlE.Translation_Indicator as Translation_Indicator_English,   
		simlF.Translation_Indicator as Translation_Indicator_French,   
		simlS.Translation_Indicator as Translation_Indicator_Spanish,       
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, simlF.Description_Short as French_Short_Description,    
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, simlS.Description_Long as Spanish_Long_Description,
		simlsF.Exempt_End_Date as Exempt_End_Date,
		s.POG_Start_Date, v.Freight_Terms, s.RMS_Orderable,
		s.POG_Max_Qty, UPPER(s.Discountable) as Discountable,
		(SELECT TOP (1) UDA_ID FROM SPD_Item_Master_UDA AS UDA2 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_UDA,
		(SELECT TOP (1) UDA_Value FROM SPD_Item_Master_UDA AS UDA3 WHERE (Michaels_SKU = s.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS Tax_Value_UDA,
		CASE WHEN COALESCE(v.Vendor_Or_Agent,'') = 'A' Then 'YES' Else 'NO' END as [Agent], v.Agent_Type, s.Buyer, UPPER(s.Auto_Replenish) AS Auto_Replenish,
		s.RMS_Inventory, s.Pack_SKU, s.Planogram_Name, v.PaymentTerms, v.Warehouse_Landed_Cost, v.Manufacture_Name,
		v.Nine_Percent_Whse_Charge, v.Total_Store_Landed_Cost, v.Duty_Percent, v.Duty_Amount, v.Additional_Duty_Amount, v.Additional_Duty_Comment,
		v.Supp_Tariff_Percent, v.Supp_Tariff_Amount, v.Ocean_Freight_Amount, v.Agent_Commission_Percent As Merch_Burden_Percent, v.Other_Import_Costs_Percent, s.POG_Max_Qty,
		--NEW ITEM Fields
		COALESCE(i.Rebuy_YN, '') as Rebuy_YN, COALESCE(i.Store_Order_YN, '') as Store_Order_YN,
		COALESCE(ii.LeadTime, '') as Lead_Time,  COALESCE(ii.ConversionDate,'') as Conversion_Date,
		COALESCE(i.Canada_Stock_Category, '') as Canada_Stock_Category,
		COALESCE(ii.QuoteSheetStatus,'') as Quote_Sheet_Status, COALESCE(ii.Sequence, '') as Sequence,
		COALESCE(ii.VendorRank,'') as Vendor_Rank, COALESCE(ii.Like_Item_SKU, i.Like_Item_SKU, '') as Like_Item_SKU,
		COALESCE(ii.Like_Item_Description, i.Like_Item_Description, '') as Like_Item_Description,
		COALESCE(ii.Like_Item_Retail, i.Like_Item_Retail, '') as Like_Item_Retail,
		COALESCE(ii.Like_Item_Regular_Unit, i.Like_Item_Regular_Unit, null) as Like_Item_Regular_Unit,
		COALESCE(ii.Like_Item_Sales, i.Like_Item_Sales, null) as Like_Item_Sales,
		COALESCE(ii.Facings, i.Facings, null) as Facings, COALESCE(ii.POG_Min_Qty, i.POG_Min_Qty, null) as POG_Min_Qty,
		COALESCE(ii.Like_Item_Store_Count, i.Like_Item_Store_Count, null) as Like_Item_Store_Count,
		COALESCE(ii.Annual_Regular_Unit_Forecast, i.Annual_Regular_Unit_Forecast, null) as Annual_Regular_Unit_Forecast,
		COALESCE(ii.Annual_Reg_Retail_Sales, i.Annual_Reg_Retail_Sales, null) as Annual_Regular_Retail_Sales,
		COALESCE(ii.Like_Item_Unit_Store_Month, i.Like_Item_Unit_Store_Month, null) as Like_Item_Unit_Store_Month,
		COALESCE(ii.Min_Pres_Per_Facing, null) as Min_Pres_Per_Facing,
		COALESCE(i.Perpetual_Inventory, '') as Perpetual_Inventory, COALESCE(i.Add_Unit_Cost, null) as Add_Unit_Cost,
		COALESCE(i.Replenish_YN, '') as Replenish_YN
		
FROM SPD_Item_Master_SKU as s with(nolock) 
		INNER JOIN SPD_Item_Master_Vendor as v with(nolock) on v.Michaels_SKU = s.Michaels_SKU
		INNER JOIN SPD_Vendor as sv with(nolock) on sv.Vendor_Number = v.Vendor_Number
		LEFT OUTER JOIN SPD_Item_Master_Vendor_UPCs AS UPC with(nolock) ON v.Michaels_SKU = UPC.Michaels_SKU AND v.Vendor_Number = UPC.Vendor_Number AND UPC.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_Item_Master_Vendor_Countries AS C with(nolock) ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND C.Primary_Indicator = 1
		LEFT OUTER JOIN SPD_COUNTRY AS CO with(nolock) ON CO.COUNTRY_CODE = C.Country_Of_Origin
		LEFT OUTER JOIN SPD_Item_Master_PackItems AS PKI with(nolock) ON s.Michaels_SKU = PKI.Child_SKU AND s.Pack_SKU = PKI.Pack_SKU     
		LEFT OUTER JOIN [SPD_Items_Files] f1 with(nolock) ON f1.Item_Type = 'D' and f1.[file_ID] = v.Image_ID and f1.File_Type = 'IMG'            
		LEFT OUTER JOIN [SPD_Items_Files] f2 with(nolock) ON f2.Item_Type = 'D' and f2.[file_ID] = v.MSDS_ID and f2.File_Type = 'MSDS'       
		LEFT JOIN SPD_Item_Master_Languages as simlE with(nolock) on simlE.Michaels_SKU = s.Michaels_SKU and simlE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlF with(nolock) on simlF.Michaels_SKU = s.Michaels_SKU and simlF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages as simlS with(nolock) on simlS.Michaels_SKU = s.Michaels_SKU  and simlS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsE with(nolock) on simlsE.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsE.Language_Type_ID = 1 -- ENGLISH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsE.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
		OUTER APPLY (Select top 1 * from SPD_Import_Items as ii with(nolock) WHERE ii.MichaelsSKU = s.Michaels_SKU Order By ID) as ii 
		OUTER APPLY (select top 1 i.Michaels_SKU, ih.Rebuy_YN, ih.Store_Order_YN, i.Like_Item_SKU, i.Like_Item_Description, i.Like_Item_Retail, 
									i.Like_Item_Regular_Unit, i.Like_Item_Sales, i.Facings, i.POG_Min_Qty, i.Like_Item_Store_Count, ih.Canada_Stock_Category,
									i.Annual_Regular_Unit_Forecast, i.Annual_Reg_Retail_Sales, i.Like_Item_Unit_Store_Month,
									ih.Perpetual_Inventory, ih.Add_Unit_Cost, ih.Replenish_YN from SPD_Items as i with(nolock) Inner Join SPD_Item_Headers as ih with(nolock) on ih.ID = i.Item_Header_ID WHERE i.Michaels_SKU = s.Michaels_SKU Order by i.ID) as i
WHERE (@startDate is null or (@startDate is not null and s.Date_Created >= @startDate))        
		and (@endDate is null or (@endDate is not null and s.Date_Created <= @endDate))
		and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and s.Department_Num = @dept))        
		and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and v.Vendor_Number = @vendor))      
		and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and v.Vendor_Number = @vendorFilter))    
		and (@itemStatus is null or (@itemStatus is not null and s.Item_Status = @itemStatus))
		and (@itemType is null or (@itemType is not null and sv.Vendor_Type = @itemType))
		and (isnull(@skuGroup, '') = '' or (isnull(@skuGroup, '') != '' and s.Sku_Group = @skuGroup))  
		and (@pliFrench is null or (@pliFrench is not null and simlsF.Package_Language_Indicator = (CASE WHEN @pliFrench ='Y' Then 'Y' Else 'N' End) ))
		
