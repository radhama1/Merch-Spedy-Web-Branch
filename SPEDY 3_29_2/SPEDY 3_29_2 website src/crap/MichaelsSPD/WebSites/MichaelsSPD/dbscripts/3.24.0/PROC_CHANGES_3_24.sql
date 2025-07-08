SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster2]    Script Date: 5/27/2020 3:39:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_SPD_MQComm_UpdateItemMaster2] 
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
		
	END	
	
	Commit Tran
	IF @Debug=1  Print 'Updating Item Master Proc Ends'
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Updating Item Master From New Item Proc Ends'


END

GO

USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster_BySKU]    Script Date: 5/27/2020 3:38:55 PM ******/
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
				, [Each_LWH_UOM] = 'IN'
				, [Each_Weight_UOM] = 'LB'
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
				, [Each_LWH_UOM] = 'IN'
				, [Each_Weight_UOM] = 'LB'
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


USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster]    Script Date: 5/27/2020 3:38:40 PM ******/
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
		
	END	
	
	Commit Tran
	IF @Debug=1  Print 'Updating Item Master Proc Ends'
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Updating Item Master From New Item Proc Ends'


END








