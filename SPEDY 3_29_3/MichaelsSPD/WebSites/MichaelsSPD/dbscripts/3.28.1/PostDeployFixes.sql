
--**********************
--data changes
--**********************
--delete new item batch changes where it is going from null to 'N'
delete SPD_Change_Field_History where batch_id in
(
Select b.id from SPD_Batch b 
inner join SPD_Workflow_Stage ws on ws.id = b.Workflow_Stage_ID
where b.Batch_Type_ID in (1,2)
and ws.Workflow_id = 1
)
and Old_Value is null and New_Value = 'N'


--**********************
--adding column display changes
--**********************


insert into ColumnDisplayName 
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
values
(
'X', 'FumigationCertificate', 101,'string','listvalue',
'YESNO',0,1,1,1,
1,1,0,1,1,
'Phytosanitary Certificate', 0,0,null, getdate(),
getdate(),NEWID(),2
)

insert into ColumnDisplayName 
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
values
(
'X', 'PhytoTemporaryShipment', 102,'string','listvalue',
'YESNO',0,1,1,1,
1,1,0,1,1,
'Phyto Temporary Shipment', 0,0,null, getdate(),
getdate(),NEWID(),2
)

insert into ColumnDisplayName 
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
Select 
'I',	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	getdate(),
getdate(),	NEWID(),	Workflow_ID
from ColumnDisplayName
where Workflow_ID = 2 and column_type = 'D' and Column_name = 'HarmonizedCodeNumber'

insert into ColumnDisplayName 
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
Select 
'I',	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	getdate(),
getdate(),	NEWID(),	Workflow_ID
from ColumnDisplayName
where Workflow_ID = 2 and column_type = 'D' and Column_name = 'CanadaHarmonizedCodeNumber'

GO

--**********************
--PROC changes
--**********************

/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster]    Script Date: 7/1/2024 11:25:34 AM ******/
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
				and isNull(DI.[PhytoSanitaryCertificate],'') = 'Y'
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
				and isNull(DI.[PhytoTemporaryShipment],'') = 'Y'
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
				and isNull(II.[FumigationCertificate],'') = 'Y'
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
				and isNull(II.[PhytoTemporaryShipment],'') = 'Y'
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




/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_CompleteOrErrorBatch]    Script Date: 7/1/2024 11:38:19 AM ******/
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
			if @debug=1 print @sql

			--set @temp = left('CFH: ' + isNull(@sql,'was null'),1000)
			--EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

			exec (@Sql)

		END


		-- If DontSentToRMS = 1 that means the field is functionally equivelent to the Item Master (Treat Empty as Zero).  Do not save change
		IF @DontSendToRMS = 0	-- Update IM with this field.  
		BEGIN
			if @Column like '%GTIN%'
			begin
				if not exists(select 'x' from SPD_Item_Master_GTINs where Michaels_SKU = @SKU)
					insert SPD_Item_Master_GTINs ([Michaels_SKU], [InnerGTIN], [CaseGTIN], [Is_Active], [Created_User_Id], [Date_created], [Update_User_Id], [Date_Last_modified])
					values (@SKU, '', '', 1, 3, getdate(), 3, getdate())
			end





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



/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_GetList]    Script Date: 7/3/2024 8:22:36 AM ******/
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

		WHEN -1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN -1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKU]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 0 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrimaryUPC]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 2 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerGTIN]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 3 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CaseGTIN]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
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
		--WHEN 21 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DisplayerCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 22 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 23 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 24 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 25 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 26 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 27 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 28 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 29 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 30 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 31 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 32 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 33 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 34 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 35 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 36 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 37 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 38 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 39 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 40 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 41 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 42 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
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
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)           
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsE.Package_Language_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsF.Package_Language_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsS.Package_Language_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silE.Translation_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silF.Translation_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                               
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silS.Translation_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silE.[Description_Short]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silE.[Description_Long]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silF.[Description_Short]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silF.[Description_Long]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsS.[Description_Short]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsS.[Description_Long]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsF.Exempt_End_Date', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
	    WHEN 99 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DetailInvoiceCustomsDesc0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
	    WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FumigationCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PhytoTemporaryShipment]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
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

		WHEN -1 THEN 'i.[ID] ' + @strTempSortDir
		WHEN -1 THEN 'i.[SKU] ' + @strTempSortDir 
		WHEN 0 THEN 'i.[VendorNumber] ' + @strTempSortDir 
		WHEN 1 THEN 'i.[PrimaryUPC] ' + @strTempSortDir 
		WHEN 2 THEN 'i.[InnerGTIN] ' + @strTempSortDir 
		WHEN 3 THEN 'i.[CaseGTIN] ' + @strTempSortDir 
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
		--WHEN 21 THEN 'i.[DisplayerCost] ' + @strTempSortDir 
		WHEN 22 THEN 'i.[ItemCost] ' + @strTempSortDir 
		--WHEN 23 THEN 'i.[FOBShippingPoint] ' + @strTempSortDir 
		WHEN 24 THEN 'i.[EachCaseHeight] ' + @strTempSortDir 
		WHEN 25 THEN 'i.[EachCaseWidth] ' + @strTempSortDir 
		WHEN 26 THEN 'i.[EachCaseLength] ' + @strTempSortDir 
		WHEN 27 THEN 'i.[EachCaseCube] ' + @strTempSortDir 
		WHEN 28 THEN 'i.[EachCaseWeight] ' + @strTempSortDir 
		WHEN 29 THEN 'i.[InnerCaseHeight] ' + @strTempSortDir 
		WHEN 30 THEN 'i.[InnerCaseWidth] ' + @strTempSortDir 
		WHEN 31 THEN 'i.[InnerCaseLength] ' + @strTempSortDir 
		WHEN 32 THEN 'i.[InnerCaseCube] ' + @strTempSortDir 
	    WHEN 33 THEN 'i.[InnerCaseCubeUOM] ' + @strTempSortDir 
		WHEN 34 THEN 'i.[InnerCaseWeight] ' + @strTempSortDir 
	    WHEN 35 THEN 'i.[InnerCaseWeightUOM] ' + @strTempSortDir 
		WHEN 36 THEN 'i.[MasterCaseHeight] ' + @strTempSortDir 
		WHEN 37 THEN 'i.[MasterCaseWidth] ' + @strTempSortDir 
		WHEN 38 THEN 'i.[MasterCaseLength] ' + @strTempSortDir 
		WHEN 39 THEN 'i.[MasterCaseCube] ' + @strTempSortDir 
	    WHEN 40 THEN 'i.[MasterCaseCubeUOM] ' + @strTempSortDir 
		WHEN 41 THEN 'i.[MasterCaseWeight] ' + @strTempSortDir 
	    WHEN 42 THEN 'i.[MasterCaseWeightUOM] ' + @strTempSortDir 
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
		WHEN 77 THEN 'i.[HazardousManufacturerPhone] ' + @strTempSortDir                                  
		WHEN 78 THEN 'i.[HazardousManufacturerCountry] ' + @strTempSortDir                                
		WHEN 81 THEN 'i.[QuoteReferenceNumber] ' + @strTempSortDir                                        
		WHEN 82 THEN 'silsE.Package_Language_Indicator ' + @strTempSortDir                                                  
		WHEN 83 THEN 'silsF.Package_Language_Indicator ' + @strTempSortDir                                                   
		WHEN 84 THEN 'silsS.Package_Language_Indicator ' + @strTempSortDir                                                  
		WHEN 86 THEN 'silE.Translation_Indicator ' + @strTempSortDir                                                   
		WHEN 87 THEN 'silF.Translation_Indicator' + @strTempSortDir                                                    
		WHEN 88 THEN 'silS.Translation_Indicator ' + @strTempSortDir                                                   
		WHEN 89 THEN 'i.[CustomsDescription] ' + @strTempSortDir                                          
		WHEN 90 THEN 'silE.[Description_Short] ' + @strTempSortDir                                     
		WHEN 91 THEN 'silE.[Description_Long] ' + @strTempSortDir                                      
		WHEN 92 THEN 'silF.[Description_Short] ' + @strTempSortDir                                      
		WHEN 93 THEN 'silF.[Description_Long] ' + @strTempSortDir                                       
		WHEN 94 THEN 'silS.[Description_Short] ' + @strTempSortDir                                     
		WHEN 95 THEN 'silS.[Description_Long] ' + @strTempSortDir                                      
		WHEN 96 THEN 'silsF.Exempt_End_Date ' + @strTempSortDir                                         
		WHEN 97 THEN 'i.[HarmonizedCodeNumber] ' + @strTempSortDir                                        
		WHEN 98 THEN 'i.[CanadaHarmonizedCodeNumber] ' + @strTempSortDir                                  
	    WHEN 99 THEN 'i.[DetailInvoiceCustomsDesc0] ' + @strTempSortDir                                   
	    WHEN 100 THEN 'i.[ComponentMaterialBreakdown0] ' + @strTempSortDir     
		WHEN 101 THEN 'i.[FumigationCertificate] ' + @strTempSortDir   
		WHEN 102 THEN 'i.[PhytoTemporaryShipment] ' + @strTempSortDir   
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

/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_GetListCount]    Script Date: 7/3/2024 8:22:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

		WHEN -1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		WHEN -1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SKU]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 0 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[VendorNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 1 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PrimaryUPC]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 2 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerGTIN]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 3 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CaseGTIN]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
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
		--WHEN 21 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DisplayerCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 22 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ItemCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 23 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FOBShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 24 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 25 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 26 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 27 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 28 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EachCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 29 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 30 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 31 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 32 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 33 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 34 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 35 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[InnerCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 36 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseHeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 37 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWidth]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 38 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseLength]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 39 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCube]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 40 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseCubeUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 41 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
	    WHEN 42 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MasterCaseWeightUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
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
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)           
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsE.Package_Language_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsF.Package_Language_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsS.Package_Language_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silE.Translation_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silF.Translation_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                               
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silS.Translation_Indicator', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                     
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silE.[Description_Short]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silE.[Description_Long]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silF.[Description_Short]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silF.[Description_Long]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsS.[Description_Short]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsS.[Description_Long]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('silsF.Exempt_End_Date', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
	    WHEN 99 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DetailInvoiceCustomsDesc0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
	    WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FumigationCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PhytoTemporaryShipment]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
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










