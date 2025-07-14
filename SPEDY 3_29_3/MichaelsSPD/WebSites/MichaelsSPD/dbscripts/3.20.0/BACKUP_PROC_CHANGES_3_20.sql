
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[usp_SPD_ItemMaint_PublishMQMessageByBatchID_backup_2019_06_27]
	@BatchID bigint
	, @UserID bigint
AS
BEGIN
--declare @BatchID bigint
--Set @BatchID= 45676	-- 45797

declare @MessageB xml
declare @MessageP xml
declare @MessageC xml
declare @Message_ID bigint
declare @msg varchar(2000)
declare @LTS datetime
declare @PriCOO varchar(20)

declare @ItemID int, @SKU varchar(20), @VendorNo bigint		-- outer cursor parms
declare @FieldName varchar(50), @FieldValue varchar(max), @RMSField varchar(50), @ColType varchar(50), @ColLength int, @DontSendToRMS bit
declare @ModifiedID bigint, @ModifiedDate datetime
declare @CreatedID bigint, @CreatedDate datetime

declare @BasicCount int, @PackCount int, @CostCount int, @CostCancel int, @DisplayerCost decimal
declare @msgWrapper varchar(max)
declare @ChangeRecs varchar(max)
declare @ChangeKey varchar(max)
declare @msgItems varchar(max)
declare @COOSnippet varchar(500)
declare @EffectiveDate varchar(20)
declare @TaxUDAFlag bit, @TaxValueUDAFlag bit, @UDAID int, @UDAValue int, @PrePriceUDAFlag bit, @PrePriceUDAValueFlag bit
declare @ImportBurden decimal(18,6)
DECLARE @Temp varchar(max)
Declare @ProcessTimeStamp varchar(100)
Declare @DirFlag tinyint
Declare @retCode int

-- stage ids
DECLARE @STAGE_COMPLETED int
DECLARE @STAGE_WAITINGFORSKU int
DECLARE @STAGE_DBC int

DECLARE @StatusTbl Table (
	Batch_ID bigint
	, Item_ID Int
	, Message_ID varchar(100)
	, Status_ID tinyint
	, Date_Created datetime
	, Effective_Date datetime null
	, Process_TimeStamp varchar(100)
	)
	
Set @ProcessTimeStamp = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(100), dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) ), '-05:00', ''), '-', ''), ' ', ''), ':', ''), '.', '')
Set @DirFlag = 1	-- default is Outbound
set @LTS = getdate()
 
-- build stage ids
select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 4
select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 3
select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 6

/*
  ............................................................................................

  When batches are moved from stage to stage in SPEDY, the user interface 
  (specifically ItemMaint.aspx) changes the Is_Valid flag to unknown (-1) to 
  force a human to physically click on a batch and make sure it is Valid.
  
  This procedure is run when a batch reaches stage "Waiting for SKU".

  For the "Waiting for SKU" stage, no human actually clicks on batches.  This 
  stage is completely automated, sending messages to RMS and awaiting response. 

  So, here, we are setting the batch to Valid (1) if it has been marked as 
  Unknown (-1) by Item_Maint
  ............................................................................................
*/  

UPDATE SPD_Batch SET Is_Valid = 1 WHERE ID = @BatchID AND Is_Valid = -1

--  Of course, explicitly invalid batches (0) will be sent back to the previous stage...
IF  ( SELECT Is_Valid FROM SPD_Batch WHERE ID = @BatchID ) = 0 
BEGIN
	UPDATE SPD_Batch SET 
	  Workflow_Stage_ID = @STAGE_DBC,
	  Date_Modified = getdate(),
	  Modified_User = @UserID
	WHERE ID = @BatchID

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
	  @BatchID,
	  @STAGE_WAITINGFORSKU,
	  'Reject',
	  getdate(),
	  @UserID,
	  'This batch is not valid. Sending back to previous stage (DBC/QA)'
	)
	Print 'Batch Invalid for processing'
	RETURN	-- We are Outahere
END

BEGIN tran


/* ******************************************************************** */
/* ***********************   PACK ITEM CHANGES  *********************** */
/* ******************************************************************** */

Print 'Pack Processing start'
-- See if Pack Change was made
declare @PackType varchar(20), @PackChange char(1), @ItemsInBatch int, @ItemsInPack int, @PackSKU varchar(20), @misMatch int, @QIPChange int
declare @addedSKUs varchar(max), @deletedSKUs varchar(max)
SET @PackChange = 'N'

SET @msgItems = ''
Select 
	@PackType = Pack_Type
	, @PackSKU = Pack_SKU 
FROM SPD_BATCH 
WHERE ID = @BatchID

IF @PackType in ('D', 'DP')
BEGIN
	-- Check if Counts are different
	SELECT @ItemsInBatch = Count(ID) FROM SPD_Item_Maint_Items WHERE Batch_ID = @BatchID and Michaels_SKU <> @PackSKU
	SELECT @ItemsInPack  = Count(Child_SKU) FROM SPD_Item_Master_PackItems WHERE Pack_SKU = @PackSKU

	-- get any added or deleted skus
	SELECT @addedSKUs = SKUsAddedToPack
		, @deletedSKUs = SKUSDeletedFromPack
	FROM dbo.udf_SPD_ItemMaint_GetPackChanges(@BatchID)

	Select @misMatch = Case WHEN (len(@addedSKUs) > 0 OR len(@deletedSKUs) > 0) THEN 1 ELSE 0 End
		
	-- Check if QtyinPack Change records exists for Batch
	SELECT @QIPChange = count(c.Item_Maint_Items_ID)
	FROM SPD_Item_Maint_Items I
		JOIN SPD_Item_Master_Changes c	ON c.Item_Maint_Items_ID = I.ID
	WHERE c.Field_Name = 'QtyInPack'
		and I.batch_ID = @BatchID

	IF @ItemsInBatch <> @ItemsInPack OR @misMatch > 0 OR @QIPChange > 0
	BEGIN
	
		-- PROCESS PACK CHANGE MESSAGE
		Declare @Components varchar(max), @QIP int
		SET @Components = ''
		
		Declare ItemCursor CURSOR FOR		-- Get all the children Items in the Batch
			SELECT ID, Michaels_SKU
			FROM SPD_Item_Maint_items
			WHERE Batch_ID = @BatchID
				and Michaels_SKU <> @PackSKU

		OPEN ItemCursor;
		FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU;
		SET @PackCount = 0
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @QIP = NULL
			SET @QIP = Coalesce( (
					SELECT top 1 Field_Value		-- Check Change Record
					FROM SPD_Item_Master_Changes 
					WHERE Item_Maint_Items_ID = @ItemID
						and Field_Name = 'QtyInPack'
				)
				, (
					SELECT top 1 Pack_Quantity		-- Check Item Master Pack Table
					FROM SPD_Item_Master_PackItems
					WHERE Pack_SKU = @PackSKU
						and Child_SKU = @SKU
				)
				, 0 )								-- Else 0
				
			SET @PackCount = @PackCount + 1
			SET @Components = @Components + (CASE @Components when '' then '' else ';' END) + @SKU + ',' + convert(varchar(20),@QIP)

			FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU;
		END
		CLOSE ItemCursor;
		DEALLOCATE ItemCursor;

		-- Now finish off the message
		SET @ChangeRecs = dbo.udf_MakeXMLSnippet(@Components, 'components')
				
		SELECT @VendorNo = Vendor_Number, @ModifiedID = Modified_User_ID, @ModifiedDate = convert(varchar(10),Date_Last_Modified, 120)
		FROM SPD_Item_Maint_items
		WHERE Batch_ID = @BatchID
			and Michaels_SKU = @PackSKU

		SET @temp = 'P.' + CONVERT(varchar(20), @BatchID) + '.' + CONVERT(varchar(20), @ItemID) + '.' + @ProcessTimeStamp

		INSERT @StatusTbl ( [Batch_ID],[Item_ID],[Message_ID],[Status_ID],[Date_Created], [Process_TimeStamp] )
			SELECT @BatchID, @ItemID, @temp, 1, getdate(), @ProcessTimeStamp
			
		SET @ChangeKey =  dbo.udf_MakeXMLSnippet(@temp, 'spd_batch_id') + dbo.udf_MakeXMLSnippet(@PackSKU, 'michaels_sku') + dbo.udf_MakeXMLSnippet(@VendorNo, 'supplier')
		SET @ChangeKey = @ChangeKey + dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(@ModifiedID), ''), 'update_user_domainlogin') 
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(@ModifiedDate), ''), 'date_last_modified')

		SET @msgItems = @msgItems + '<mikData id="' + @temp + '" '	+ 'type="SPEDYPackMod" action="Update">'
		SET @msgItems = @msgItems + @ChangeKey + @ChangeRecs + '</mikData>'

		SET @msgWrapper = '<mikMessage><mikHeader><Source>SPEDY</Source><Contents>SPEDYPackMod</Contents><ThreadID>' + convert(varchar(2), @BatchID % 9 + 1) + 
			'</ThreadID><PublishTime>' + dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) + '</PublishTime></mikHeader>' + @msgItems + '</mikMessage>'
	    
		SET @MessageP = CONVERT(XML,@msgWrapper)
		print 'Pack Item Recs processed: ' + convert(varchar(20),@PackCount)
		-- select @MessageP
		-- See if any error occurred in the process
		IF @PackCount > 0 and @msgWrapper is NULL
		BEGIN
			Rollback Tran
			INSERT INTO SPD_Batch_History (
				  SPD_Batch_ID,
				  Workflow_Stage_ID,
				  [Action],
				  Date_Modified,
				  Modified_User,
				  Notes
				) VALUES (
				  @BatchID,
				  @STAGE_WAITINGFORSKU,
				  'Error Detected',
				  getdate(),
				  @UserID,
				  'An Empty Pack Message was generated but the Pack Change Count was: ' + convert(varchar,@PackCount) + '. Sending back to DBC stage'
				)
			UPDATE SPD_Batch SET 
				Workflow_Stage_ID = @STAGE_DBC,
				Date_Modified = getdate(),
				Modified_User = @UserID
			WHERE ID = @BatchID

			set @msg = 'OutBound Message Generation  - Error Occurred on Pack Creation. Empty Pack Message Created for Batch ID: ' + convert(varchar,@BatchID)
				+ ' with a Pack Change Count of: ' + convert(varchar,@PackCount)
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			RETURN
		END 
	END
END
Print 'Pack Message Process ends. Pack Change Recs processed: ' + convert(varchar(20),@PackCount)

/* ********************************************************************* */
/* ***********************   BASIC ITEM CHANGES  *********************** */
/* ********************************************************************* */

Print 'Basic Process start'

-- Get Key Fields for Basic
SET @msgItems = ''
declare ItemCursor CURSOR FOR
	SELECT ID, Michaels_SKU, Vendor_Number, Modified_User_ID, Date_Last_Modified
	FROM SPD_Item_Maint_items
	WHERE Batch_ID = @BatchID

SET @BasicCount = 0

OPEN ItemCursor;
FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU, @VendorNo, @ModifiedID, @ModifiedDate

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Reset Tax Flags to 0 and ChangeRecs to Empty string for each SKU in the Batch
	Select @TaxUDAFlag = 0
		, @TaxValueUDAFlag = 0
		, @PrePriceUDAFlag = 0
		, @PrePriceUDAValueFlag = 0
		, @ChangeRecs = ''

	DECLARE ChangeCursor CURSOR FOR
		SELECT C.Field_name
			, C.Field_Value
			, L.RMS_Field_Name
			, Coalesce(MDC.[Column_Generic_Type],'')
			, Coalesce(MDC.[Max_Length],0)
			, Coalesce(C.Dont_Send_To_RMS,0)
		FROM spd_Item_Maint_items I
			join SPD_Item_Master_Changes C	on I.id = C.item_maint_items_id
			join SPD_Metadata_Column MDC	on MDC.metadata_table_ID = 11 
												and MDC.Send_To_RMS = 1
												and MDC.Column_Name = C.Field_Name 	
			join SPD_RMS_Field_Lookup L		on C.Field_Name = L.Field_Name 
		WHERE c.item_maint_items_id = @ItemID
			and L.Maint_Type = 'B'
			
	OPEN ChangeCursor;
	
	FETCH NEXT FROM ChangeCursor INTO @FieldName, @FieldValue, @RMSField, @ColType, @ColLength, @DontSendToRMS;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @DontSendToRMS = 0	-- Make sure this field is to be sent to RMS
		BEGIN
		
			IF @FieldName NOT IN ( 'AddCountryOfOrigin', 'CountryOfOrigin', 'ImportBurden') -- Handle these changes Separately
				--and @FieldName <> 'CountryOfOrigin'		
				--and @FieldName <> 'ImportBurden'		-- Handle changes Separately too
			BEGIN	-- Process All Other Change records
				IF @FieldName = 'TaxUDA'
					SET @TaxUDAFlag = 1
				IF @FieldName = 'TaxValueUDA'
					SET @TaxValueUDAFlag = 1
				IF @FieldName = 'PrePriced'
					SET @PrePriceUDAFlag = 1
				IF @FieldNAme = 'PrePricedUDA'
					SET @PrePriceUDAValueFlag = 1

				IF @FieldName = 'ItemDesc'
				BEGIN
					Set @FieldValue = replace(@FieldValue, char(13), ' ')
					Set @FieldValue = replace(@FieldValue, char(10), ' ')
					Set @FieldValue = rtrim(@FieldValue)
				END
					
				IF len(@FieldValue) = 0
					SET @FieldValue = 'NULL'
				IF @ColType = 'varchar' and @ColLength > 1
					SET @FieldValue = dbo.udf_ReplaceSpecialChars(@FieldValue)
				SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@FieldValue, @RMSField)
				SET @BasicCount = @BasicCount + 1
			END
			
			IF @FieldName IN ( 'AddCountryOfOrigin', 'CountryOfOrigin' )
			BEGIN		-- COO process
				SET @COOSnippet = dbo.udf_SPD_IM_GetCOOChanges(@ItemID, @SKU, @VendorNo)
				IF len(@COOSnippet) > 0
				BEGIN
					SET @BasicCount = @BasicCount + 1 
					SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@COOSnippet, @RMSField)
				END
			END
			
			IF @FieldName = 'ImportBurden'
			BEGIN
				PRINT ' IMPORT BURDEN RECORD PROCESSING...'
				-- Make sure the Import Burden Change was not the result of just a Cost change
				SET @ImportBurden = dbo.udf_SPD_CalcImportBurdenFromChgRecs(@ItemID)
				Print 'Change Rec IB: ' + @FieldValue + '   Calced IB: ' + isnull(convert(varchar(30),@ImportBurden),'No Difference from Item Master (ignoring Cost changes)')
				IF @ImportBurden is NOT NULL
				BEGIN
					SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(convert(varchar(30),@ImportBurden), @RMSField)
					SET @BasicCount = @BasicCount + 1
				END
			END
		END
		FETCH NEXT FROM ChangeCursor INTO @FieldName, @FieldValue, @RMSField, @ColType, @ColLength, @DontSendToRMS;
		--FETCH NEXT FROM ChangeCursor INTO @FieldName, @FieldValue, @RMSField, @ColType, @ColLength;
	END		-- END Inner Cursor
	CLOSE ChangeCursor;
	DEALLOCATE ChangeCursor;

	-- Now Make sure that if either tax flag is sent that we send both tax fields
	IF @TaxUDAFlag = 0 AND @TaxValueUDAFlag = 1
	BEGIN	-- Get the TaxUDA from Item Master and add to message
		Select top 1 @UDAID = UDA_ID
		From SPD_Item_Master_UDA 
		Where Michaels_SKU = @SKU
			and UDA_ID between 1 and 9 
		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@UDAID, 'tax_uda')
	END

	IF @TaxUDAFlag = 1 AND @TaxValueUDAFlag = 0
	BEGIN -- Get the Tax Value UDA from Item Master and add to message
		Select top 1 @UDAValue = UDA_Value
		From dbo.SPD_Item_Master_UDA
		Where Michaels_SKU = @SKU
			and UDA_ID between 1 and 9 
		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@UDAValue, 'tax_value_uda')
	END
 	
 	-- Now Make sure that if Pre Price Value is sent, we also send the Pre Price UDA Flag
 	If @PrePriceUDAFlag = 0 AND @PrePriceUDAValueFlag = 1
 	BEGIN
		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet('Y', 'pre_priced')
 	END
 	
 	--Now add PLI Multilingual changes
 	IF Exists(Select 1 FROM spd_Item_Maint_items I
						INNER JOIN SPD_Item_Master_Changes C	on I.id = C.item_maint_items_id
						WHERE c.item_maint_items_id = @ItemID
							AND c.Field_Name in ('PLIEnglish', 'PLIFrench', 'PLISpanish'))
	BEGIN
		--Construct the PLI Node if there were any PLI Changes
		DECLARE @PLIIndicators varchar(30)

		Select @PLIIndicators = 'en_US-' + COALESCE(C.Field_Value, l.Package_Language_Indicator,'N')
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Languages_Supplier as l on l.Michaels_SKU = I.Michaels_SKU and l.Vendor_Number = I.Vendor_Number and l.Language_Type_ID = 1
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'PLIEnglish'
		WHERE i.id = @itemID

		--If Exempt End Date is nothing, then send normal PLI
		IF Exists(Select 1 FROM SPD_Item_Master_Languages_Supplier WHERE Michaels_SKU = @SKU and Vendor_Number = @VendorNo and Language_Type_ID = 2 AND COALESCE(Exempt_End_Date,'') = '')
		BEGIN
			--No Exempt End Date specified.  Send normal Y/N value.
			Select @PLIIndicators = @PLIIndicators + ',fr_CA-' + COALESCE(C.Field_Value, l.Package_Language_Indicator,'N')
			FROM SPD_item_Maint_Items as I
			Left Join SPD_Item_Master_Languages_Supplier as l on l.Michaels_SKU = I.Michaels_SKU and l.Vendor_Number = I.Vendor_Number and l.Language_Type_ID = 2
			Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'PLIFrench'
			WHERE i.id = @itemID
		END
		ELSE
		BEGIN
			--Exempt End Date specified, so send X instead of Y/N
			SET @PLIIndicators = @PLIIndicators + ',fr_CA-X'
		END

		Select @PLIIndicators = @PLIIndicators + ',es_PR-' + COALESCE(C.Field_Value, l.Package_Language_Indicator,'N')
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Languages_Supplier as l on l.Michaels_SKU = I.Michaels_SKU and l.Vendor_Number = I.Vendor_Number and l.Language_Type_ID = 3
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'PLISpanish'
		WHERE i.id = @itemID

		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@PLIIndicators, 'pli')
		SET @BasicCount = @BasicCount + 1
	END
	
	--Now add TI Multilingual changes
 	IF Exists(Select 1 FROM spd_Item_Maint_items I
						INNER JOIN SPD_Item_Master_Changes C	on I.id = C.item_maint_items_id
						WHERE c.item_maint_items_id = @ItemID
							AND c.Field_Name in ('TIEnglish', 'TIFrench', 'TISpanish'))
	BEGIN
		--Construct the PLI Node if there were any PLI Changes
		DECLARE @TIIndicators varchar(30)

		Select @TIIndicators = 'en_US-' + COALESCE(C.Field_Value, l.Translation_Indicator,'N')
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Languages as l on l.Michaels_SKU = I.Michaels_SKU and l.Language_Type_ID = 1
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'TIEnglish'
		WHERE i.id = @itemID

		Select @TIIndicators = @TIIndicators + ',fr_CA-' + COALESCE(C.Field_Value, l.Translation_Indicator,'N')
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Languages as l on l.Michaels_SKU = I.Michaels_SKU and l.Language_Type_ID = 2
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'TIFrench'
		WHERE i.id = @itemID

		Select @TIIndicators = @TIIndicators + ',es_PR-' + COALESCE(C.Field_Value, l.Translation_Indicator,'N')
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Languages as l on l.Michaels_SKU = I.Michaels_SKU and l.Language_Type_ID = 3
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'TISpanish'
		WHERE i.id = @itemID

		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@TIIndicators, 'ti')
		SET @BasicCount = @BasicCount + 1
	END
		
 	
	-- Now create a message if any Changes Found
	IF len(@ChangeRecs) > 0  
	BEGIN
		-- add Key info to msg
		SET @temp = 'B.' + CONVERT(varchar(20), @BatchID) + '.' + CONVERT(varchar(20), @ItemID) + '.' + @ProcessTimeStamp

		INSERT @StatusTbl ([Batch_ID], [Item_ID], [Message_ID], [Status_ID], [Date_Created], [Process_TimeStamp] )
			SELECT @BatchID, @ItemID, @temp, 1, getdate(), @ProcessTimeStamp
			
		SET @ChangeKey =  dbo.udf_MakeXMLSnippet(@temp, 'spd_batch_id') 
			+ dbo.udf_MakeXMLSnippet(@SKU, 'michaels_sku') 
			+ dbo.udf_MakeXMLSnippet(@VendorNo, 'supplier')
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(@ModifiedID), ''), 'update_user_domainlogin') 
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(@ModifiedDate), ''), 'date_last_modified')

		-- Create Message
		SET @msgItems = @msgItems + '<mikData id="' + @temp + '" '	
			+ 'type="SPEDYItemMaint" action="Update">'
			+ @ChangeKey + @ChangeRecs + '</mikData>'
	END
	FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU, @VendorNo, @ModifiedID, @ModifiedDate
END
CLOSE ItemCursor;
DEALLOCATE ItemCursor;

-- Now see if Message and Header needs to be wrapped around this message
IF len(@msgItems) > 0 
BEGIN
	SET @msgWrapper = '<mikMessage><mikHeader><Source>SPEDY</Source><Contents>SPEDYItemMaint</Contents><ThreadID>' + convert(varchar(2), @BatchID % 9 + 1) + 
		'</ThreadID><PublishTime>' + dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) + '</PublishTime></mikHeader>' + @msgItems + '</mikMessage>'
    SET @MessageB = CONVERT(XML,@msgWrapper)
END

-- Check for error
IF @BasicCount > 0 and @msgWrapper is NULL
BEGIN
	Rollback Tran
	INSERT INTO SPD_Batch_History (
		  SPD_Batch_ID,
		  Workflow_Stage_ID,
		  [Action],
		  Date_Modified,
		  Modified_User,
		  Notes
		) VALUES (
		  @BatchID,
		  @STAGE_WAITINGFORSKU,
		  'Error Detected',
		  getdate(),
		  @UserID,
		  'An Empty Basic Message was generated but the Basic Change Count was: ' + convert(varchar,@BasicCount) + '. Sending back to DBC stage'
		)
	UPDATE SPD_Batch SET 
		Workflow_Stage_ID = @STAGE_DBC,
		Date_Modified = getdate(),
		Modified_User = @UserID
	WHERE ID = @BatchID

	set @msg = 'OutBound Message Generation  - Error Occurred on Basic Creation. Empty Basic Message Created for Batch ID: ' + convert(varchar,@BatchID)
		+ ' with a Basic Change Count of: ' + convert(varchar,@BasicCount)
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
	EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
	RETURN
END 
Print 'Basic Message Process ends. Basic Change Recs processed: ' + convert(varchar(20),@BasicCount)


/* ******************************************************************** */
/* ***********************   COST ITEM CHANGES  *********************** */
/* ******************************************************************** */
-- NOTE Two sets of routines to manage here
SET @msgItems = ''

Declare @dteEffectiveDate datetime
SELECT @dteEffectiveDate = coalesce(Effective_Date, getdate() )
FROM SPD_Batch WHERE ID = @BatchID

-- Make sure this effective date is at least Getdate +1.  If not then fix it
IF DateDiff(day, @dteEffectiveDate, getdate()) >= 0 
BEGIN	-- Effective Date must be a future date and its not. Set it to be GetDate() + 1 day
	UPDATE SPD_Batch SET
		Effective_Date = DateAdd(day, 1, getdate())
	WHERE ID = @BatchID and Effective_Date is not NULL	-- Only update if it was defined
END
 
SELECT @EffectiveDate = convert(varchar(10),Effective_Date,120)
FROM SPD_Batch WHERE ID = @BatchID


Print 'Cost Process start'

Declare ItemCursor CURSOR FOR
	SELECT ID, Michaels_SKU, Vendor_Number, Modified_User_ID, Date_Last_Modified
	FROM SPD_Item_Maint_items
	WHERE Batch_ID = @BatchID

OPEN ItemCursor;
FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU, @VendorNo, @ModifiedID, @ModifiedDate

--	SELECT ID, Michaels_SKU, Vendor_Number
--	FROM SPD_Item_Maint_items
--	WHERE Batch_ID = @BatchID

--OPEN ItemCursor;
--FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU, @VendorNo;
SET @CostCount = 0

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE ChangeCursor CURSOR FOR
		SELECT c.Field_name
			, c.Field_Value
			, L.RMS_Field_Name 
			, Coalesce(C.Dont_Send_To_RMS,0)
		FROM spd_Item_Maint_items I
			join SPD_Item_Master_Changes c	on i.id = c.item_maint_items_id
			join SPD_RMS_Field_Lookup L		on c.Field_Name = L.Field_Name 
		WHERE c.item_maint_items_id = @ItemID
			and L.Maint_Type = 'C'
			
	OPEN ChangeCursor;
	SET @ChangeRecs = ''
	FETCH NEXT FROM ChangeCursor INTO @FieldName, @FieldValue, @RMSField, @DontSendToRMS;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @DontSendToRMS = 0
		BEGIN
			-- Code commented out because we are now sending FOBShipping Point cost instead
			--IF @FieldName = 'ProductCost'
			--BEGIN	-- Get the DisplayerCost for this Item either from the Change record or Item Master and add it to the Cost to send
			--	SET @DisplayerCost = coalesce(
			--		  ( SELECT Convert(decimal,Field_Value) FROM SPD_Item_Master_Changes WHERE item_maint_items_id = @ItemID and Field_Name = 'DisplayerCost' )
			--		, ( SELECT Displayer_Cost FROM SPD_Item_Master_SKU WHERE Michaels_SKU = @SKU )
			--		, 0.00 )
			--	SET @FieldValue = Convert(varchar(30), ( Convert(decimal,@FieldValue) + @DisplayerCost ) )
			--END
			SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@FieldValue, @RMSField)
			SET @CostCount = @CostCount + 1
		END
		FETCH NEXT FROM ChangeCursor INTO @FieldName, @FieldValue, @RMSField, @DontSendToRMS
	END		-- END Inner Cursor
	CLOSE ChangeCursor;
	DEALLOCATE ChangeCursor;
	
	-- Now create a message if any Changes Found
	IF len(@ChangeRecs) > 0  
	BEGIN
		-- Get who created the batch and timestamp
		Select @CreatedID = CreatedID, @CreatedDate = CreatedDate From dbo.udf_SPD_ItemMaint_LookupCostBatchCreated(@ItemID)

		SET @temp = 'C.' + CONVERT(varchar(20), @BatchID) + '.' + CONVERT(varchar(20), @ItemID) + '.' + @ProcessTimeStamp

		-- Log this mikData node
		INSERT @StatusTbl ( [Batch_ID],[Item_ID],[Message_ID],[Status_ID],[Date_Created], [Process_TimeStamp] )
			SELECT @BatchID, @ItemID, @temp, 1, getdate(), @ProcessTimeStamp
			
		-- add Key info to msg
		SET @ChangeKey =  dbo.udf_MakeXMLSnippet(@temp, 'spd_batch_id') 
			+ dbo.udf_MakeXMLSnippet(@SKU, 'michaels_sku') 
			+ dbo.udf_MakeXMLSnippet(@VendorNo, 'supplier')
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(@ModifiedID), ''), 'update_user_domainlogin') 
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(@ModifiedDate), ''), 'date_last_modified')
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(@CreatedID), ''), 'create_user_domainlogin') 
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(@CreatedDate), ''), 'date_created')

		-- Get the Effective Date
		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@EffectiveDate, 'effective_date')
			+ dbo.udf_MakeXMLSnippet('A', 'Status')

		-- Create msg
		SET @msgItems = @msgItems + '<mikData id="' + @temp + '" '	+ 'type="SPEDYCostChange" action="Update">' + @ChangeKey + @ChangeRecs + '</mikData>'
	END
	FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU, @VendorNo, @ModifiedID, @ModifiedDate
END
CLOSE ItemCursor;
DEALLOCATE ItemCursor;

-- Now do the same thing for Future Cost Cancels

declare @tmpDate datetime

declare ItemCursor CURSOR FOR
	SELECT ID, Michaels_SKU, Vendor_Number, Modified_User_ID, Date_Last_Modified
	FROM SPD_Item_Maint_items
	WHERE Batch_ID = @BatchID

OPEN ItemCursor;
FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU, @VendorNo, @ModifiedID, @ModifiedDate

SET @CostCancel = 0

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Cursor used as an Item can have more than one future cost based on effectiveDate
	DECLARE ChangeCursor CURSOR FOR
		SELECT C.Field_name
			, C.Field_Value
			, L.RMS_Field_Name
			, C.Effective_Date 
		FROM spd_Item_Maint_items I
			join SPD_Item_Master_Changes C	on i.id = C.item_maint_items_id
			join SPD_RMS_Field_Lookup L		on C.Field_Name = L.Field_Name 
		WHERE c.item_maint_items_id = @ItemID
			and L.Maint_Type = 'F'
			
	OPEN ChangeCursor;
	FETCH NEXT FROM ChangeCursor INTO @FieldName, @FieldValue, @RMSField, @EffectiveDate

	Declare @FCCounter int
	Set @FCCounter = 1

	Select @CreatedID = CreatedID, @CreatedDate = CreatedDate From dbo.udf_SPD_ItemMaint_LookupCostBatchCreated(@ItemID)
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @FieldName = 'FutureCostStatus'	-- This only exists if this is a cancel
		BEGIN
			SET @ChangeRecs = ''
			SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet('C', @RMSField)
			SET @tmpDate = convert(datetime,@EffectiveDate)
			SET @ChangeRecs = @ChangeRecs + Replace(dbo.udf_MakeXMLSnippet(IsNull(dbo.udf_SPD_ItemMaint_LookupFutureCost(@ItemID,@tmpDate),'0'),'unit_cost'), ',', '')
			SET @CostCancel = @CostCancel + 1

			-- Create Message for this Cost Cancel
			
			SET @temp = 'F.' + CONVERT(varchar(20), @BatchID) 
				+ '.' + CONVERT(varchar(20), @ItemID) 
				+ '.' + @ProcessTimeStamp	--+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(100), dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) ), '-05:00', ''), '-', ''), ' ', ''), ':', ''), '.', '')
				+ '.' + convert(varchar(10),@FCCounter)
			-- Get the Effective Date
			SET @EffectiveDate = convert(varchar(10),@tmpDate,120)

			-- Create Change Key for this mikData node
			SET @ChangeKey =  dbo.udf_MakeXMLSnippet(@temp, 'spd_batch_id') 
				+ dbo.udf_MakeXMLSnippet(@SKU, 'michaels_sku') 
				+ dbo.udf_MakeXMLSnippet(@VendorNo, 'supplier')
				+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(@ModifiedID), ''), 'update_user_domainlogin') 
				+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(@ModifiedDate), ''), 'date_last_modified')
				+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_ResolveSecurityUserID_to_SecurityUserName(@CreatedID), ''), 'create_user_domainlogin') 
				+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(@CreatedDate), ''), 'date_created')
				+ dbo.udf_MakeXMLSnippet(@EffectiveDate, 'effective_date')

			-- Log this mikData node with the effective date for this cost cancel so we can use it to process later
			-- NAK 7/7/2011:  Add FCCounter to Timestamp, so code can properly identify Confirmation message
			INSERT @StatusTbl ( [Batch_ID],[Item_ID],[Message_ID],[Status_ID],[Date_Created], [Effective_Date], [Process_TimeStamp] )
				SELECT @BatchID, @ItemID, @temp, 1, getdate(), @EffectiveDate, @ProcessTimeStamp
				
			--SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@EffectiveDate, 'effective_date')
			-- Wrap the Change and keys in a mikData node
			SET @msgItems = @msgItems + '<mikData id="' + @temp + '" '	+ 'type="SPEDYCostChange" action="Update">' + @ChangeKey + @ChangeRecs + '</mikData>'

			Set @FCCounter = @FCCounter + 1 
		END
		FETCH NEXT FROM ChangeCursor INTO @FieldName, @FieldValue, @RMSField, @EffectiveDate
	END		-- END Inner Cursor
	CLOSE ChangeCursor;
	DEALLOCATE ChangeCursor;
	
	FETCH NEXT FROM ItemCursor INTO @ItemID, @SKU, @VendorNo, @ModifiedID, @ModifiedDate
END
CLOSE ItemCursor;
DEALLOCATE ItemCursor;

-- Now see if Message and Header needs to be wrapped around this set of mikData nodes
IF len(@msgItems) > 0 
BEGIN
	SET @msgWrapper = '<mikMessage><mikHeader><Source>SPEDY</Source><Contents>SPEDYCostChange</Contents><ThreadID>' + convert(varchar(2), @BatchID % 9 + 1) 
		+ '</ThreadID><PublishTime>' + dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) 
		+ '</PublishTime></mikHeader>' + @msgItems + '</mikMessage>'
    SET @MessageC = CONVERT(XML,@msgWrapper)
END

-- Check for error
IF @CostCount + @CostCancel > 0 and @msgWrapper is NULL
BEGIN
	Rollback Tran
	INSERT INTO SPD_Batch_History (
		  SPD_Batch_ID,
		  Workflow_Stage_ID,
		  [Action],
		  Date_Modified,
		  Modified_User,
		  Notes
		) VALUES (
		  @BatchID,
		  @STAGE_WAITINGFORSKU,
		  'Error Detected',
		  getdate(),
		  @UserID,
		  'An Empty Cost Message was generated but the Cost Change Count was: ' + convert(varchar,@CostCount + @CostCancel) + '. Sending back to DBC stage'
		)
	UPDATE SPD_Batch SET 
		Workflow_Stage_ID = @STAGE_DBC,
		Date_Modified = getdate(),
		Modified_User = @UserID
	WHERE ID = @BatchID

	set @msg = 'OutBound Message Generation  - Error Occurred on Cost Creation. Empty Cost Message Created for Batch ID: ' + convert(varchar,@BatchID)
		+ ' with a Cost Change Count of: ' + convert(varchar,@CostCount + @CostCancel)
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
	EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
	RETURN
END 
Print 'Cost Message Process ends. Cost Change Recs processed: ' 
	+ convert(varchar(20),@CostCount + @CostCancel) + '  -C: ' + convert(varchar(20),@CostCount) + '  -F: ' + convert(varchar(20),@CostCancel)

/* ******************************************************************** */
/*	 NOW PUT CREATED MESSAGES IN THE RMS QUEUE							*/
/* ******************************************************************** */

IF @MessageP is NOT NULL
BEGIN
	Print 'Inserting Pack Message...'
	INSERT INTO SPD_MQComm_Message (
	  [SPD_Batch_ID]
	  ,[Message_Type_ID]
	  ,[Message_Body]
	  ,[Message_Direction]
	) VALUES (
		@BatchID
		, 10	
		, @MessageP
		, 1 
		)
	SET @Message_ID = SCOPE_IDENTITY()

	print 'Message Inserted: ' + coalesce(convert(varchar,@Message_ID),'NULL!!!!')
	
	INSERT INTO SPD_MQComm_Message_Status (
	  [Message_ID]
	  ,[Status_ID]
	) VALUES (
		@Message_ID
		, 1 
		)
	if @@Rowcount >0 
		Print ' Status Updated...'
	else
		Print ' Stuat Update Failed'

	INSERT INTO SPD_Batch_History (
		  SPD_Batch_ID,
		  Workflow_Stage_ID,
		  [Action],
		  Date_Modified,
		  Modified_User,
		  Notes
		) VALUES (
		  @BatchID,
		  @STAGE_WAITINGFORSKU,
		  'Pack Change Message Queued to RMS',
		  getdate(),
		  @UserID,
		  ''
		)
		
	-- Force any other messages created to go into an Outbound HOLD STATUS since Pack Msg was created	
	SET @DirFlag = 2		
END

IF @MessageB is NOT NULL
BEGIN
	Print 'Inserting Basic Message...'
	INSERT INTO SPD_MQComm_Message (
	  [SPD_Batch_ID]
	  ,[Message_Type_ID]
	  ,[Message_Body]
	  ,[Message_Direction]
	) VALUES (
		@BatchID
		, 10
		, @MessageB
		, @DirFlag 
		)
	SET @Message_ID = SCOPE_IDENTITY()
	print 'Message Inserted: ' + coalesce(convert(varchar,@Message_ID),'NULL!!!!')

	INSERT INTO SPD_MQComm_Message_Status (
	  [Message_ID]
	  ,[Status_ID]
	) VALUES (
		@Message_ID
		, 1 
		)
	if @@Rowcount >0 
		Print ' Status Updated...'
	else
		Print ' Stuat Update Failed'
		
	INSERT INTO SPD_Batch_History (
		  SPD_Batch_ID,
		  Workflow_Stage_ID,
		  [Action],
		  Date_Modified,
		  Modified_User,
		  Notes
		) VALUES (
		  @BatchID,
		  @STAGE_WAITINGFORSKU,
		  'Basic Change Message Queued to RMS',
		  getdate(),
		  @UserID,
		  ''
		)
END

IF @MessageC is NOT NULL
BEGIN
	Print 'Inserting Cost Message...'
	INSERT INTO SPD_MQComm_Message (
	  [SPD_Batch_ID]
	  ,[Message_Type_ID]
	  ,[Message_Body]
	  ,[Message_Direction]
	) VALUES (
		@BatchID
		, 10		
		, @MessageC
		, @DirFlag 
		)
	SET @Message_ID = SCOPE_IDENTITY()
	print 'Message Inserted: ' + coalesce(convert(varchar,@Message_ID),'NULL!!!!')

	INSERT INTO SPD_MQComm_Message_Status (
	  [Message_ID]
	  ,[Status_ID]
	) VALUES (
		@Message_ID
		, 1 
		)

	if @@Rowcount >0 
		Print ' Status Updated...'
	else
		Print ' Stuat Update Failed'
		
	INSERT INTO SPD_Batch_History (
		  SPD_Batch_ID,
		  Workflow_Stage_ID,
		  [Action],
		  Date_Modified,
		  Modified_User,
		  Notes
		) VALUES (
		  @BatchID,
		  @STAGE_WAITINGFORSKU,
		  'Cost Change Message Queued to RMS',
		  getdate(),
		  @UserID,
		  ''
		)
END

IF (SELECT Count(*) FROM @StatusTbl) > 0
BEGIN
	Print ' Insert Tracking Table'
	-- Mark all Existing Batch Items as 4 regardless of their current status as all messages are being resent
	UPDATE SPD_Item_Maint_MQMessageTracking
		Set Status_ID = 4
		, Date_Updated = getdate()
	WHERE Batch_ID = @BatchID 	-- Sent, Pos Ack, Neg Ack
	
	--Select * from @StatusTbl
	-- Insert into the Status table with current Status
	INSERT SPD_Item_Maint_MQMessageTracking ( [Batch_ID],[Item_ID],[Message_ID],[Status_ID],[Date_Created], [Effective_Date], [Process_TimeStamp] )
		SELECT * from @StatusTbl

	if @@Rowcount > 0 
		Print ' Status Tracking Updated...'
	else
		Print ' Stuat Tracking Update Failed'
END
ELSE
	Print ' No Status Tracking Records to save'

declare @total int
set @total = isnull(@CostCount,0) + isnull(@CostCancel,0) + isnull(@BasicCount,0) + isnull(@PackCount,0)

IF @total > 0
BEGIN	-- Update Batch History 
		
	INSERT INTO SPD_Batch_History (
	  SPD_Batch_ID,
	  Workflow_Stage_ID,
	  [Action],
	  Date_Modified,
	  Modified_User,
	  Notes
	) VALUES (
	  @BatchID,
	  @STAGE_WAITINGFORSKU,
	  'RMS Message(s) Submitted',
	  getdate(),
	  @UserID,
	  'Total Changes submitted: ' + convert(varchar(max), @total )
	)
	
	UPDATE SPD_Batch
		SET date_modified = getdate(), modified_user = @UserID
	WHERE ID = @BatchID
END
ELSE	-- No RMS Changes created. Process The batch to completion
BEGIN
	INSERT INTO SPD_Batch_History (
	  SPD_Batch_ID,
	  Workflow_Stage_ID,
	  [Action],
	  Date_Modified,
	  Modified_User,
	  Notes
	) VALUES (
	  @BatchID,
	  @STAGE_WAITINGFORSKU,
	  'No RMS Changes Found',
	  getdate(),
	  @UserID,
	  'No RMS Changes Detected. Performing Batch Completion Process'
	)

	set @temp = 'Calling usp_SPD_ItemMaint_CompleteOrErrorBatch ' + convert(varchar,@BatchID) + ' cmd = C' 
		+ ' For Batch Process Time Stamp: ' + @ProcessTimeStamp
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

	Exec @retCode = usp_SPD_ItemMaint_CompleteOrErrorBatch @Batch_ID = @BatchID, @cmd = 'C', @LTS=@LTS
	IF @retCode != 0	
	BEGIN	-- Error Occurred. Make sure Batch is at the DBC stage and Log error
		INSERT INTO SPD_Batch_History (
		  SPD_Batch_ID,
		  Workflow_Stage_ID,
		  [Action],
		  Date_Modified,
		  Modified_User,
		  Notes
		) VALUES (
		  @BatchID,
		  @STAGE_WAITINGFORSKU,
		  'Error On Final Batch Process',
		  getdate(),
		  @UserID,
		  'An Error Occurred on Final Batch Process Sending Back to DBC. Contact Support.'
		)
		
		UPDATE SPD_Batch SET 
		  Workflow_Stage_ID = @STAGE_DBC,
		  Date_Modified = getdate(),
		  Modified_User = @UserID
		WHERE ID = @BatchID
	END

END

Commit Tran
				
END -- PROC


GO


create PROCEDURE [dbo].[sp_SPD_Batch_PublishMQMessage_ByBatchID_backup_2019_06_27]
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

