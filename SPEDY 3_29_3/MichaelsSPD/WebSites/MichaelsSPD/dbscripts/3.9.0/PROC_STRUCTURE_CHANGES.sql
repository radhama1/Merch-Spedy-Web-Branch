SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--*************************************************
--sp_SPD_Batch_PublishMQMessage_ByBatchID 
--*************************************************
/****** Object:  StoredProcedure [dbo].[sp_SPD_Batch_PublishMQMessage_ByBatchID]    Script Date: 12/18/2017 13:42:56 ******/
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
              --new fields for stocking strategy
			  ,COALESCE(item.Stocking_Strategy_Code, '') as stocking_strategy_code
			  ,COALESCE(item.Harmonized_Code_Number, '') as import_hts_code
			  ,COALESCE(item.Canada_Harmonized_Code_Number, '') as canada_hts_code
			  ,COALESCE(CONVERT(varchar(20),item.[each_case_height]), '') As each_case_height
              ,COALESCE(CONVERT(varchar(20),item.[each_case_width]), '') As each_case_width
              ,COALESCE(CONVERT(varchar(20),item.[each_case_length]), '') As each_case_length
              ,COALESCE(CONVERT(varchar(20),item.[each_case_weight]), '') As each_case_weight
              ,COALESCE(CONVERT(varchar(20),item.[each_case_pack_cube]), '') As each_case_pack_cube
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
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[detailinvoicecustomsdesc]), '') As detailinvoicecustomsdesc
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[componentmaterialbreakdown]), '') As componentmaterialbreakdown
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[componentconstructionmethod]), '') As componentconstructionmethod
              ,COALESCE(dbo.udf_ReplaceSpecialChars(importitem.[individualitempackaging]), '') As individualitempackaging
              ,COALESCE(importitem.[eachinsidemastercasebox], '') As eachinsidemastercasebox
              ,COALESCE(importitem.[eachinsideinnerpack], '') As eachinsideinnerpack
              ,COALESCE(importitem.[eachpiecenetweightlbsperounce], '') As eachpiecenetweightlbsperounce
              ,COALESCE(importitem.[reshippableinnercartonlength], '') As reshippableinnercartonlength
              ,COALESCE(importitem.[reshippableinnercartonwidth], '') As reshippableinnercartonwidth
              ,COALESCE(importitem.[reshippableinnercartonheight], '') As reshippableinnercartonheight
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
              --new fields for stocking strategy
              ,COALESCE(importitem.Stocking_Strategy_Code, '') as stocking_strategy_code
              ,COALESCE(convert(varchar(20),importitem.eachheight),'') as eachheight
              ,COALESCE(convert(varchar(20),importitem.eachwidth),'') as eachwidth
              ,COALESCE(convert(varchar(20),importitem.eachlength),'') as eachlength
              ,COALESCE(convert(varchar(20),importitem.eachweight),'') as eachweight
              ,COALESCE(convert(varchar(20),importitem.cubicfeeteach),'') as cubicfeeteach
              ,COALESCE(importitem.CanadaHarmonizedCodeNumber, '') as canadaharmonizedcodenumber
              ,COALESCE(importitem.Customs_Description, '') as shortcustomsdescription
              ,COALESCE(importitem.[eachpiecenetweightlbsperounce], '') As reshippableinnercartonweight
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


--*************************************************
--sp_SPD_Import_Item_SaveRecord 
--*************************************************


/****** Object:  StoredProcedure [dbo].[sp_SPD_Import_Item_SaveRecord]    Script Date: 12/18/2017 13:43:56 ******/
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
	@EachPieceNetWeightLbsPerOunce varchar(100) = null,
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
			EachPieceNetWeightLbsPerOunce = @EachPieceNetWeightLbsPerOunce,
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
			EachPieceNetWeightLbsPerOunce,
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
			@EachPieceNetWeightLbsPerOunce,
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



--*************************************************
--sp_SPD_Item_GetList 
--*************************************************

/****** Object:  StoredProcedure [dbo].[sp_SPD_Item_GetList]    Script Date: 12/18/2017 13:51:41 ******/
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
		--WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Image_ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS_ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
	  
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
		WHEN 102 THEN 'i.[Image_ID] ' + @strTempSortDir
		WHEN 103 THEN 'i.[MSDS_ID] ' + @strTempSortDir

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


--*************************************************
--sp_SPD_Item_GetListCount 
--*************************************************
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[sp_SPD_Item_GetListCount] 
  @itemHeaderID bigint = 0,
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

  IF (COALESCE(@itemHeaderID,0) > 0)
  BEGIN
    SET @strFilter = 'i.Item_Header_ID = ' + CONVERT(varchar(40), @itemHeaderID)
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
		--WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Image_ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
		--WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS_ID]', @typeNumber, @strTempFilterOp, @strTempFilterCriteria)
	  
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





	SET @strSelect = 'SELECT COUNT(i.[ID]) AS RecordCount FROM [dbo].[SPD_Items] i '
  IF(@strFilter != '') set @strSelect = @strSelect + ' where ' + @strFilter

  EXEC(@strBlock + @strSelect)

  IF (@printDebugMsgs = 1) PRINT @strBlock + @strSelect

  EXEC sp_xml_removedocument @intXMLDocHandle    

GO

--*************************************************
--sp_SPD_Item_SaveRecord 
--*************************************************
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
	@Each_Case_Pack_Cube decimal(18, 6)
	
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
			Each_Case_Pack_Cube = @Each_Case_Pack_Cube	
			
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
			Each_Case_Pack_Cube 		
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
			@Each_Case_Pack_Cube 
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

SET QUOTED_IDENTIFIER ON
GO



/*
INBOUND RMS MESSAGE PROCESSING
Ken Wallace and Jeff Littlefield

This is the main starting point for inbound message processing.  Incoming messages are collected into a cursor along with any already processed messages that have 
a time stamp later than the first in the list. This ensures that message are reapplied as necessary to the item master (Inserts occur then updates)

Each message is first evaluated for the New Item Process as well as updates to the control tables (Class, subclass, dept etc)
When a New Item Batch goes to completion a flag is set to Update the Item Master with SPEDY Only Data (data that is not maintained by RMS). 
This update of the Item Master is done AFTER the Message has been processed by the "Update Item Master routines" to ensure that the Item master record exists before
the SPEDY Only data from the New Item Record is committed to the Item Master

At the bottom of this routine is the logic to Call the Item Master Update and Item Maintenance routines as well as the call to Update Item Master from New Item.

Note that Logging is now incorporated into the routines.  At key points, process and diagnostic info is logged using the routine usp_SPD_MQ_LogMessage.  
Log messages are grouped together with a common Timestamp that is passed from routine to routine.

-- To rerun messages, use the following template to clear our the statues for the messages to rerun
-- Delete from SPD_MQComm_Message_Status where message_ID in (Message IDs to reprocess) and status_ID <> 1

*/

ALTER PROCEDURE [dbo].[sp_SPD_MQComm_ProcessIncomingMQMessages]
	-- This allows us to rerun manually to reprocess Specific messages by specifying N
	@AddAllReadyProcessedMessages char(1) = 'Y'
AS
  DECLARE @TimeZoneOffset int
  DECLARE @MessageID bigint
  DECLARE @strXMLDoc xml
  DECLARE @intXMLDocHandle int
  DECLARE @XML_HeaderSegment_Source varchar(1000)
  DECLARE @XML_HeaderSegment_Contents varchar(1000)
  DECLARE @XML_HeaderSegment_ThreadID varchar(1000)
  DECLARE @XML_HeaderSegment_PublishTime varchar(1000)
  DECLARE @XML_DataSegment_ID varchar(1000)
  DECLARE @XML_DataSegment_Type varchar(1000)
  DECLARE @XML_DataSegment_Action varchar(1000)
  DECLARE @XML_DataSegment_LastID varchar(1000)
  DECLARE @SPEDYRefString varchar(1000)
  DECLARE @SPEDYBatchID bigint
  DECLARE @SPEDYBatchTypeID tinyint
  DECLARE @SPEDYItemHeaderID bigint
  DECLARE @SPEDYItemID bigint
  DECLARE @NumItemsInBatch bigint
  DECLARE @NumCompleteItemsInBatch bigint
  DECLARE @NumParentItemsInBatchNeedingaSKU smallint
  DECLARE @VERBSTATEMENTSTRING varchar(max)
  DECLARE @VERBSTATEMENTSTRING2 varchar(max)
  DECLARE @SELECTSTATEMENTSTRING varchar(max)
  DECLARE @PREPARESTRING varchar(max)
  DECLARE @CLEANUPSTRING varchar(max)
  DECLARE @WHERECLAUSE1 varchar(max)
  DECLARE @WHERECLAUSE2 varchar(max)
  DECLARE @SUCCESSFLAG bit
  DECLARE @SUCCESSMSG varchar(max)
  DECLARE @XML_DataSegment_PrimaryUPC varchar(20)
  DECLARE @XML_DataSegment_ErrorMessage1 varchar(max)
  DECLARE @XML_DataSegment_ErrorMessage2 varchar(max)
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
  DECLARE @WorkflowStageID tinyint
  DECLARE @WorkflowID tinyint
  DECLARE @MsgTimeStamp datetime
  DECLARE @msg varchar(1000)
  DECLARE @MessageRecNo int
  DECLARE @MessageCount int
  Declare @UpdateIMFromNI bit
  Declare @UpdateBID bigint


  SET NOCOUNT ON
  -- stage ids
  DECLARE @STAGE_COMPLETED int
  DECLARE @STAGE_WAITINGFORSKU int
  DECLARE @STAGE_DBC int

   --build stage ids work worflowID = 1
  select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 1 and Stage_Type_id = 4
  select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 1 and Stage_Type_id = 3
  select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 1 and Stage_Type_id = 6
  
  --select @STAGE_COMPLETED, @STAGE_PRIOR_TO_COMPLETED
  
  -- This variable used to set a common timestamp for all logged messages in the execution of the routine
  SET @MsgTimeStamp = getdate()
  
  --Set @msg = 'P R O C   P R E P R O C E S S   B E G I N S...'
  --EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

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
  
  DECLARE @intOffset int
  Declare @tDate datetime	--, @temp1 varchar(100)
  DECLARE @MinPublishTime datetime

  -- Create a temp table so process all message in process sequence order
  CREATE TABLE #Messages (
		  RecordNumber int Identity(1,1)
		, MessageID	bigint
		, MessageBody XML
		, PublishTime datetime
		)
  
-- *****************************************************************************************************************************************
--	Build list of messages to process based on the Message Published time stamp so we know we are processing the messages in the right order
-- *****************************************************************************************************************************************
Print 'Selecting Messages to Process...'
  DECLARE myCursor CURSOR FOR 
    SELECT m.ID, m.Message_Body 
    FROM SPD_MQComm_Message m
    INNER JOIN (
		  SELECT 
			x.Message_ID 
			, COUNT(x.ID)							As NumEntries
			, MAX(x.ID)								As MostRecentID
			, MAX(x.Status_ID)						As MaxStatusID
			, ( SELECT Status_ID 
				FROM SPD_MQComm_Message_Status 
				WHERE ID = MAX(x.ID) )				As MostRecentStatusID
		  FROM SPD_MQComm_Message_Status x
		  GROUP BY x.Message_ID
	    ) ms ON ms.Message_ID = m.ID
	WHERE m.Message_Direction = 0			-- Inbound Messages
		AND ms.MostRecentStatusID = 1		-- With an unprocessed flag 
    ORDER BY m.ID ASC

Print 'Updating Message recordss with the Message Type and Publish date...'
  OPEN myCursor
  FETCH NEXT FROM myCursor INTO @MessageID, @strXMLDoc
  WHILE @@FETCH_STATUS = 0
  BEGIN
		EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc
		SELECT
			@XML_HeaderSegment_Source = mikHeader_Source
		  , @XML_HeaderSegment_PublishTime = mikHeader_PublishTime
		FROM OPENXML (@intXMLDocHandle, '/mikMessage')
		WITH (
		   mikHeader_Source varchar(1000) 'mikHeader/Source'
		  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
		  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
		  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
		) hdr
		EXEC sp_xml_removedocument @intXMLDocHandle

		-- Normalize the time
		SET @TimeZoneOffset = 0
		SET @intOffset = CharIndex(' +', @XML_HeaderSegment_PublishTime) - 1
		IF @intOffset <= 0
		BEGIN
			SET @intOffset = CharIndex(' -', @XML_HeaderSegment_PublishTime) - 1
		END
		IF @intOffset > 0
		BEGIN
			SET @TimeZoneOffset = (convert(int, substring(@XML_HeaderSegment_PublishTime, @intOffset+2, 3))) * -1
			SET @XML_HeaderSegment_PublishTime = LEFT(@XML_HeaderSegment_PublishTime, @intOffset)
		END
		SET @tDate = DateAdd(hour, @TimeZoneOffset, convert(datetime,@XML_HeaderSegment_PublishTime))

		INSERT #Messages
			SELECT @MessageID, @strXMLDoc, @tDate
			--SELECT @RecNo as RecNo, @MessageID, @strXMLDoc, @temp, @intOffset, @temp1, @TimeZoneOffset, @tDate

		-- Now save the Process Time with the Message
		UPDATE SPD_MQComm_Message
			SET Message_Source = @XML_HeaderSegment_Source
				, Message_Publish_Time = @tDate
		WHERE ID = @MessageID
		FETCH NEXT FROM myCursor INTO @MessageID, @strXMLDoc
  END
  CLOSE myCursor
  DEALLOCATE myCursor

	-- Now Get any Messages ALREADY PROCESSED that have a PublishTime Time Stamp greater than the Min PublishTime time from Temp table
	-- Inbound messages that have already been processed and are Item Master type.  Need to do them again if its a Item master source
	-- This ensures we have processed them in the correct order.
  IF @AddAllReadyProcessedMessages = 'Y'
  BEGIN	
	  Print ' Adding in Message that need to be reprocessed...'
	  SELECT @MinPublishTime = min(PublishTime) FROM #Messages
	  INSERT #Messages
		SELECT M.ID, M.Message_Body, M.Message_Publish_Time
		FROM SPD_MQComm_Message M
			Left Join #Messages tM	ON M.ID = tM.MessageID
		WHERE Message_Publish_Time > @MinPublishTime
			AND Message_Direction = 0	-- inbound message 
			AND Message_Source = 'RIB.etItemsFromRMS'
			AND tM.MessageID is NULL		-- Make sure it's not already selected

  END

-- *****************************************************************************************************************************************
--									B E G I N      P R O C E S S I N G
-- *****************************************************************************************************************************************
    --SELECT MessageID, MessageBody
    --FROM #Messages
    --ORDER BY PublishTime ASC
  
  Set @MessageCount = (Select count(*) from #Messages )
  IF @MessageCount > 0
	Set @msg = 'P R O C E S S     B E G I N S     - Total Msgs: ' + convert(varchar(20), @MessageCount)
  ELSE
	Set @msg = 'P R O C E S S     C H E C K     - Total Msgs: 0'
  	
  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg
  
-- USE TEMP file #Messages to process the messages
  DECLARE myXMLMessages CURSOR FOR 
    SELECT MessageID, MessageBody, RecordNumber		
    FROM #Messages
    ORDER BY PublishTime ASC, MessageID asc
    
  OPEN myXMLMessages
  FETCH NEXT FROM myXMLMessages INTO @MessageID, @strXMLDoc, @MessageRecNo
  WHILE @@FETCH_STATUS = 0
  BEGIN
	SET @UpdateIMFromNI = 0		-- Reset Flag to not update Item Master from New Item for each message
	Set @UpdateBID = 0

    SET @XML_HeaderSegment_Source = NULL
    SET @XML_HeaderSegment_Contents = NULL
    SET @XML_HeaderSegment_ThreadID = NULL
    SET @XML_HeaderSegment_PublishTime = NULL
    SET @XML_DataSegment_ID = NULL
    SET @XML_DataSegment_Type = NULL
    SET @XML_DataSegment_Action = NULL
    SET @XML_DataSegment_LastID = NULL
    SET @XML_DataSegment_PrimaryUPC = NULL
    SET @XML_DataSegment_ErrorMessage1 = NULL
    SET @XML_DataSegment_ErrorMessage2 = NULL
    SET @SPEDYRefString = NULL
    SET @SPEDYBatchID = NULL
    SET @SPEDYBatchTypeID = NULL
    SET @SPEDYItemHeaderID = NULL
    SET @SPEDYItemID = NULL
    SET @VERBSTATEMENTSTRING = NULL
    SET @VERBSTATEMENTSTRING2 = NULL
    SET @SELECTSTATEMENTSTRING = NULL
    SET @PREPARESTRING = NULL
    SET @CLEANUPSTRING = NULL
    SET @WHERECLAUSE1 = NULL
    SET @WHERECLAUSE2 = NULL

    -- ========================================================================
    -- SET STATUS TO PROCESSING
    -- ========================================================================
    INSERT INTO SPD_MQComm_Message_Status (Message_ID, Status_ID) VALUES (@MessageID, 2)
    set @msg = 'Retrieving Message: ' + convert(varchar(20),@MessageID) + ' ( Record No. ' + convert(varchar(20),@MessageRecNo) + ' )'
	EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

    SET @SUCCESSFLAG = 0
    SET @SUCCESSMSG = NULL
    SET @NumItemsInBatch = 0
    SET @NumCompleteItemsInBatch = 0
    SET @NumParentItemsInBatchNeedingaSKU = 0

    EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc
    SET @PREPARESTRING = '
      SET NOCOUNT ON
      
      DECLARE @strXMLDoc xml
      DECLARE @intXMLDocHandle int
      
      SELECT @strXMLDoc = m.Message_Body 
      FROM SPD_MQComm_Message m
      WHERE m.ID = ''0' + CONVERT(varchar(20), @MessageID) + '''
      
      EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc
    '

    SET @CLEANUPSTRING = '
      EXEC sp_xml_removedocument @intXMLDocHandle    
      SET NOCOUNT OFF
    '

    -- ========================================================================
    -- DETERMINE MESSAGE TYPE
    -- ========================================================================
    SELECT
      @XML_HeaderSegment_Source = mikHeader_Source,
      @XML_HeaderSegment_Contents = mikHeader_Contents,
      @XML_HeaderSegment_ThreadID = mikHeader_ThreadID,
      @XML_HeaderSegment_PublishTime = mikHeader_PublishTime
    FROM OPENXML (@intXMLDocHandle, '/mikMessage')
    WITH
    (
       mikHeader_Source varchar(1000) 'mikHeader/Source'
      ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
      ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
      ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
    )

    -- ========================================================================
    -- MESSAGE TYPE: ITEM RESPONSE or ITEM UPDATE
    --   - Item Response updates SPEDY and affects spedy workflow
    --   - Item Updates only update the item_master table.
    -- ========================================================================
    
    
    IF ( @XML_HeaderSegment_Source = 'RIB.etItemsFromRMS' )
    BEGIN
      -- Get the identifier string for the referenced spedy transaction
      SELECT 
         @SPEDYRefString = mikData_spedy_item_id
        ,@XML_DataSegment_ID = data.mikDataAttrs_id
        ,@XML_DataSegment_Type = data.mikDataAttrs_type
        ,@XML_DataSegment_Action = data.mikDataAttrs_action
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Sku'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_spedy_item_id varchar(1000) 'spedy_item_id'
      ) data

      SELECT 
         @XML_DataSegment_ID = COALESCE(@XML_DataSegment_ID, upc.mikDataUPCAttrs_id)
        ,@XML_DataSegment_Type = COALESCE(@XML_DataSegment_Type, upc.mikDataUPCAttrs_type)
        ,@XML_DataSegment_Action = COALESCE(@XML_DataSegment_Action, upc.mikDataUPCAttrs_action)
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''UPC'']')
      WITH 
      (
         mikDataUPCAttrs_id varchar(1000) '@id'
        ,mikDataUPCAttrs_type varchar(1000) '@type'
        ,mikDataUPCAttrs_action varchar(1000) '@action'
        ,mikDataUPC_upc varchar(1000) 'upc'
        ,mikDataUPC_item varchar(1000) 'item'
        ,mikDataUPC_primary_ref_item_ind varchar(1000) 'primary_ref_item_ind'
        ,mikDataUPC_item_number_type varchar(1000) 'item_number_type'
        ,mikDataUPC_upc_desc varchar(1000) 'upc_desc'
      ) upc
      
      SET @VERBSTATEMENTSTRING = NULL
      SET @VERBSTATEMENTSTRING2 = NULL
      SET @SELECTSTATEMENTSTRING = NULL     

      PRINT '@XML_HeaderSegment_Source: ' + @XML_HeaderSegment_Source 
      PRINT '@SPEDYRefString: ' + COALESCE(@SPEDYRefString, 'n\a')
      PRINT '@XML_DataSegment_ID: ' + COALESCE(@XML_DataSegment_ID , 'n\a')
      PRINT '@XML_DataSegment_Type: ' + COALESCE(@XML_DataSegment_Type , 'n\a')
      PRINT '@XML_DataSegment_Action: ' +COALESCE( @XML_DataSegment_Action , 'n\a')

      -- + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
      -- PROCESS ITEM RESPONSE MESSAGE
      -- + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
      IF ( NULLIF(@SPEDYRefString, '') IS NOT NULL )
      BEGIN
      
        -- this is a New Item response message
        IF (@SPEDYEnvVars_Test_Mode = 1) PRINT @msg
        IF (@SPEDYEnvVars_Test_Mode = 1) PRINT '@SPEDYRefString: ' + @SPEDYRefString  

        -- Split Batch from Item_ID
        SET @SPEDYBatchID = 0
        SET @SPEDYBatchTypeID = 0
        SET @SPEDYItemID = 0

        IF (LEN(@SPEDYRefString) > 0)
        BEGIN
			IF (CHARINDEX('.', @SPEDYRefString) > 0)
			BEGIN
				IF (ISNUMERIC(SUBSTRING(@SPEDYRefString, 0, CHARINDEX('.', @SPEDYRefString))) = 1)
				BEGIN
					SET @SPEDYBatchID = SUBSTRING(@SPEDYRefString, 0, CHARINDEX('.', @SPEDYRefString))
				END        
			END
        END
        
        -- Make sure that this message is for an active, uncompleted batch.
        -- SPEDYBatchIDs are only associated with New Item Batches (Item originiated in SPEDY as opposed to originating in RMS)
        IF (@SPEDYBatchID > 0)
        BEGIN
			SET @WorkflowID = 0
			SET @WorkflowID = coalesce(
				(	SELECT WS.Workflow_ID
					FROM SPD_Batch B
						join SPD_Workflow_Stage ws on B.workflow_Stage_ID = ws.ID
					WHERE B.ID = @SPEDYBatchID
						and B.[enabled] = 1			-- Must be an enabled batch
						and ws.[Stage_Type_id] <> 4	-- Must not be a completed batch
				), 0 )
        END

        IF ( @SPEDYBatchID > 0 and @WorkflowID = 1 )
        BEGIN
          -- Lookup Batch and determine if Import or Domestic
          -- Domestic Batch = 1
          -- Import Batch = 2
	
			EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing New Item Response Message'
			SELECT @SPEDYBatchTypeID = COALESCE(Batch_Type_ID, 0) FROM SPD_Batch WHERE ID = @SPEDYBatchID

			-- Indicate that this is a New Item Response Message
			UPDATE SPD_MQComm_Message
			SET Message_Type_ID = 2, SPD_Batch_ID = @SPEDYBatchID
			WHERE ID = @MessageID

			IF ( @SPEDYBatchTypeID > 0)
			BEGIN
				IF ( ISNUMERIC(SUBSTRING(@SPEDYRefString, CHARINDEX('.', @SPEDYRefString)+1, LEN(@SPEDYRefString) ) ) = 1)
				BEGIN
					SET @SPEDYItemID = SUBSTRING(@SPEDYRefString, CHARINDEX('.', @SPEDYRefString)+1, LEN(@SPEDYRefString) )
					SET @SPEDYItemID = COALESCE(@SPEDYItemID, 0)

					SELECT @SPEDYItemHeaderID = h.ID 
					FROM SPD_Item_Headers h
					INNER JOIN SPD_Items i ON i.Item_Header_ID = h.ID
					WHERE i.ID = @SPEDYItemID

					SET @SPEDYItemHeaderID = COALESCE(@SPEDYItemHeaderID, 0)
				END
			END
        END

		-- FJL ONLY DO THIS STUFF if WORKFLOW ID=1 (an uncompleted New Item message)
		-- Convert the XML message to a New Item Response record (SKU, Vendor, UPC, etc info)
        IF (@SPEDYBatchID > 0 and @WorkflowID = 1)
        BEGIN
			SET @SELECTSTATEMENTSTRING = '
			FROM OPENXML (@intXMLDocHandle, ''/mikMessage'')
			WITH
			(
			   mikHeader_Source varchar(1000) ''mikHeader/Source''
			  ,mikHeader_Contents varchar(1000) ''mikHeader/Contents''
			  ,mikHeader_ThreadID varchar(1000) ''mikHeader/ThreadID''
			  ,mikHeader_PublishTime varchar(1000) ''mikHeader/PublishTime''
			) hdr
			INNER JOIN (
			  SELECT *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''Sku'''']'')
			  WITH
			  (
				 mikDataAttrs_ID varchar(1000) ''@id''
				,mikDataAttrs_Type varchar(1000) ''@type''
				,mikDataAttrs_Action varchar(1000) ''@action''
				,mikData_item varchar(1000) ''item''
				,mikData_spedy_item_id varchar(1000) ''spedy_item_id''
				,mikData_item_number_type varchar(1000) ''item_number_type''
				,mikData_pack_ind varchar(1000) ''pack_ind''
				,mikData_item_level varchar(1000) ''item_level''
				,mikData_tran_level varchar(1000) ''tran_level''
				,mikData_dept varchar(1000) ''dept''
				,mikData_dept_name varchar(1000) ''dept_name''
				,mikData_class varchar(1000) ''class''
				,mikData_class_name varchar(1000) ''class_name''
				,mikData_subclass varchar(1000) ''subclass''
				,mikData_sub_name varchar(1000) ''sub_name''
				,mikData_status varchar(1000) ''status''
				,mikData_item_desc varchar(1000) ''item_desc''
				,mikData_short_desc varchar(1000) ''short_desc''
				,mikData_desc_up varchar(1000) ''desc_up''
				,mikData_primary_ref_item_ind varchar(1000) ''primary_ref_item_ind''
				,mikData_retail_zone_group_id varchar(1000) ''retail_zone_group_id''
				,mikData_cost_zone_group_id varchar(1000) ''cost_zone_group_id''
				,mikData_standard_uom varchar(1000) ''standard_uom''
				,mikData_merchandise_ind varchar(1000) ''merchandise_ind''
				,mikData_store_ord_mult varchar(1000) ''store_ord_mult''
				,mikData_forecast_ind varchar(1000) ''forecast_ind''
				,mikData_mfg_rec_retail varchar(1000) ''mfg_rec_retail''
				,mikData_catch_weight_ind varchar(1000) ''catch_weight_ind''
				,mikData_const_dimen_ind varchar(1000) ''const_dimen_ind''
				,mikData_simple_pack_ind varchar(1000) ''simple_pack_ind''
				,mikData_contains_inner_ind varchar(1000) ''contains_inner_ind''
				,mikData_sellable_ind varchar(1000) ''sellable_ind''
				,mikData_orderable_ind varchar(1000) ''orderable_ind''
				,mikData_unit_retail varchar(1000) ''unit_retail''
				,mikData_gift_wrap_ind varchar(1000) ''gift_wrap_ind''
				,mikData_ship_alone_ind varchar(1000) ''ship_alone_ind''
				,mikData_item_xform_ind varchar(1000) ''item_xform_ind''
				,mikData_inventory_ind varchar(1000) ''inventory_ind''
				,mikData_item_type_attr varchar(1000) ''item_type_attr''
				,mikData_stock_category varchar(1000) ''stock_category''
				,mikData_sku_group varchar(1000) ''sku_group''
				,mikData_hyb_cnv_date varchar(1000) ''hyb_cnv_date''
				,mikData_repl_ind varchar(1000) ''repl_ind''
				,mikData_pi_ind varchar(1000) ''pi_ind''
				,mikData_store_orderable_ind varchar(1000) ''store_orderable_ind''
				,mikData_inv_control varchar(1000) ''inv_control''
				,mikData_discountable_ind varchar(1000) ''discountable_ind''
				,mikData_age_ver_req_ind varchar(1000) ''age_ver_req_ind''
				,mikData_price_prompt_ind varchar(1000) ''price_prompt_ind''
				,mikData_store_level_default varchar(1000) ''store_level_default''
				,mikData_pack_item_type varchar(1000) ''pack_item_type''
				,mikData_hazmat_ind varchar(1000) ''hazmat_ind''
				,mikData_flammable_ind varchar(1000) ''flammable_ind''
				,mikData_store_sup_zone_group varchar(1000) ''store_sup_zone_group''
				,mikData_wh_sup_zone_group varchar(1000) ''wh_sup_zone_group''
				,mikData_store_order_max_qty varchar(1000) ''store_order_max_qty''
				,mikData_min_order_qty varchar(1000) ''min_order_qty''
				,mikData_create_datetime varchar(1000) ''create_datetime''
				,mikData_last_update_datetime varchar(1000) ''last_update_datetime''
				,mikData_last_update_id varchar(1000) ''last_update_id''
				,mikData_prmy_supplier varchar(1000) ''prmy_supplier''
				,mikData_prmy_supp_country varchar(1000) ''prmy_supp_country''
				,mikData_prmy_supp_inner_pack_size varchar(1000) ''prmy_supp_inner_pack_size''
				,mikData_prmy_ref_item_no varchar(1000) ''prmy_ref_item_no''
				,mikData_prmy_ref_item_type varchar(1000) ''prmy_ref_item_type''
				,mikData_unit_cost varchar(1000) ''unit_cost''
			  )
			) data ON data.mikData_spedy_item_id IS NOT NULL

			--* UPC
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''UPC'''']'')
			  WITH
			  (
				 mikDataUPCAttrs_ID varchar(1000) ''@id''
				,mikDataUPCAttrs_Type varchar(1000) ''@type''
				,mikDataUPCAttrs_Action varchar(1000) ''@action''
				,mikDataUPC_upc varchar(1000) ''upc''
				,mikDataUPC_item varchar(1000) ''item''
				,mikDataUPC_primary_ref_item_ind varchar(1000) ''primary_ref_item_ind''
				,mikDataUPC_item_number_type varchar(1000) ''item_number_type''
				,mikDataUPC_upc_desc varchar(1000) ''upc_desc''
			  )
			) upc ON 1 = 1

			--* SkuSupplier
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuSupplier'''']'')
			  WITH
			  (
				 mikDataSkuSupplierAttrs_ID varchar(1000) ''@id''
				,mikDataSkuSupplierAttrs_Type varchar(1000) ''@type''
				,mikDataSkuSupplierAttrs_Action varchar(1000) ''@action''
				,mikDataSkuSupplier_item varchar(1000) ''item''
				,mikDataSkuSupplier_supplier varchar(1000) ''supplier''
				,mikDataSkuSupplier_primary_supp_ind varchar(1000) ''primary_supp_ind''
				,mikDataSkuSupplier_vpn varchar(1000) ''vpn''
				,mikDataSkuSupplier_pallet_name varchar(1000) ''pallet_name''
				,mikDataSkuSupplier_case_name varchar(1000) ''case_name''
				,mikDataSkuSupplier_inner_name varchar(1000) ''inner_name''
				,mikDataSkuSupplier_direct_ship_ind varchar(1000) ''direct_ship_ind''
				,mikDataSkuSupplier_origin_country_id varchar(1000) ''origin_country_id''
				,mikDataSkuSupplier_primary_country_ind varchar(1000) ''primary_country_ind''
				,mikDataSkuSupplier_unit_cost varchar(1000) ''unit_cost''
				,mikDataSkuSupplier_supp_pack_size varchar(1000) ''supp_pack_size''
				,mikDataSkuSupplier_inner_pack_size varchar(1000) ''inner_pack_size''
				,mikDataSkuSupplier_round_lvl varchar(1000) ''round_lvl''
				,mikDataSkuSupplier_packing_method varchar(1000) ''packing_method''
				,mikDataSkuSupplier_default_uop varchar(1000) ''default_uop''
				,mikDataSkuSupplier_ti varchar(1000) ''ti''
				,mikDataSkuSupplier_hi varchar(1000) ''hi''
				,mikDataSkuSupplier_cost_uom varchar(1000) ''cost_uom''
			  )
			) supplier ON 1 = 1

			--* Zone 1: Base Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''1'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone1 ON 1 = 1

			--* Zone 2: Central Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''2'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone2 ON 1 = 1

			--* Zone 3: Test Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''3'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone3 ON 1 = 1

			--* Zone 4: Alaska Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''4'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone4 ON 1 = 1

			--* Zone 5: Canada Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''5'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone5 ON 1 = 1

			--* Zone 6: 0-9 Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''6'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone6 ON 1 = 1

			--* Zone 7: California Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''7'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone7 ON 1 = 1

			--* Zone 8: VILLAGE CRFT Retail Zone
			LEFT OUTER JOIN (
			  SELECT TOP 1 *
			  FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''SkuZonePrice'''' and zone_id = ''''8'''']'')
			  WITH
			  (
				 mikDataSkuZonePriceAttrs_ID varchar(1000) ''@id''
				,mikDataSkuZonePriceAttrs_Type varchar(1000) ''@type''
				,mikDataSkuZonePriceAttrs_Action varchar(1000) ''@action''
				,mikDataSkuZonePrice_item_zone_price_id varchar(1000) ''item_zone_price_id''
				,mikDataSkuZonePrice_item varchar(1000) ''item''
				,mikDataSkuZonePrice_zone_id varchar(1000) ''zone_id''
				,mikDataSkuZonePrice_standard_retail varchar(1000) ''standard_retail''
				,mikDataSkuZonePrice_standard_retail_currency varchar(1000) ''standard_retail_currency''
				,mikDataSkuZonePrice_selling_retail varchar(1000) ''selling_retail''
				,mikDataSkuZonePrice_selling_retail_currency varchar(1000) ''selling_retail_currency''
				,mikDataSkuZonePrice_multi_unit_retail_currency varchar(1000) ''multi_unit_retail_currency''
				,mikDataSkuZonePrice_zone_group_id varchar(1000) ''zone_group_id''
			  )
			) priceZone8 ON 1 = 1
			'

			-- Lookup this item to see if it exists in the specified batch
			--  If Domestic...
			IF ( @SPEDYBatchTypeID = 1 )
			BEGIN
			  SET @VERBSTATEMENTSTRING = '
			  UPDATE SPD_Items
				SET
				-- ! [add_change] = data.mikData_add_change
				-- ! [pack_item_indicator] = data.mikData_pi_ind
				 [michaels_sku] = data.mikData_item
				,[vendor_upc] = data.mikData_prmy_ref_item_no
				-- ! ,[class_num] = data.mikData_class
				-- ! ,[sub_class_num] = data.mikData_subclass
				-- ? ,[vendor_style_num] = mikData_vendor_style_num
				-- ! ,[item_desc] = data.mikData_item_desc
				-- ? ,[hybrid_type] = mikData_hybrid_type
				-- ? ,[hybrid_source_dc] = mikData_hybrid_source_dc
				-- ! ,[hybrid_lead_time] = mikData_hybrid_lead_time
				-- ! ,[hybrid_conversion_date] = mikData_hybrid_conversion_date
				-- ! ,[eaches_master_case] = supplier.mikDataSkuSupplier_supp_pack_size
				-- ! ,[eaches_inner_pack] = supplier.mikDataSkuSupplier_inner_pack_size
				-- ! ,[pre_priced] = mikData_pre_priced
				-- ! ,[pre_priced_uda] = mikData_pre_priced_uda
				-- ! ,[us_cost] = data.mikData_unit_cost
				-- ! ,[canada_cost] = data.mikData_unit_cost
				-- ! ,[base_retail] = priceZone1.mikDataSkuZonePrice_standard_retail
				-- ! ,[central_retail] = priceZone2.mikDataSkuZonePrice_standard_retail
				-- ! ,[test_retail] = priceZone3.mikDataSkuZonePrice_standard_retail
				-- ! ,[alaska_retail] = priceZone4.mikDataSkuZonePrice_standard_retail
				-- ! ,[canada_retail] = priceZone5.mikDataSkuZonePrice_standard_retail
				-- ! ,[zero_nine_retail] = priceZone6.mikDataSkuZonePrice_standard_retail
				-- ! ,[california_retail] = priceZone7.mikDataSkuZonePrice_standard_retail
				-- ! ,[village_craft_retail] = priceZone8.mikDataSkuZonePrice_standard_retail
				-- ! ,[pog_setup_per_store] = mikData_pog_setup_per_store
				-- ! ,[pog_max_qty] = mikData_pog_max_qty
				-- ! ,[projected_unit_sales] = mikData_projected_unit_sales
				-- ? ,[inner_case_height] = mikData_inner_case_height
				-- ? ,[inner_case_width] = mikData_inner_case_width
				-- ? ,[inner_case_length] = mikData_inner_case_length
				-- ? ,[inner_case_weight] = mikData_inner_case_weight
				-- ? ,[inner_case_pack_cube] = mikData_inner_case_pack_cube
				-- ? ,[master_case_height] = mikData_master_case_height
				-- ? ,[master_case_width] = mikData_master_case_width
				-- ? ,[master_case_length] = mikData_master_case_length
				-- ? ,[master_case_weight] = mikData_master_case_weight
				-- ? ,[master_case_pack_cube] = mikData_master_case_pack_cube
				-- ! ,[country_of_origin] = data.mikData_prmy_supp_country
				-- ! ,[tax_uda] = mikData_tax_uda
				-- ! ,[tax_value_uda] = mikData_tax_value_uda
				-- ! ,[hazardous] = data.mikData_hazmat_ind
				-- ! ,[hazardous_flammable] = data.mikData_flammable_ind
				-- ! ,[hazardous_container_type] = mikData_hazardous_container_type
				-- ! ,[hazardous_container_size] = mikData_hazardous_container_size
				-- ! ,[hazardous_msds_uom] = mikData_hazardous_msds_uom
				-- ! ,[hazardous_manufacturer_name] = mikData_hazardous_manufacturer_name
				-- ! ,[hazardous_manufacturer_city] = mikData_hazardous_manufacturer_city
				-- ! ,[hazardous_manufacturer_state] = mikData_hazardous_manufacturer_state
				-- ! ,[hazardous_manufacturer_phone] = mikData_hazardous_manufacturer_phone
				-- ! ,[hazardous_manufacturer_country] = mikData_hazardous_manufacturer_country
				,Date_Last_Modified = getdate()
				,Update_User_ID = 0
			  '

			  SET @VERBSTATEMENTSTRING2 = '
			  UPDATE SPD_Item_Headers
				SET
				-- !  [us_vendor_num] = data.mikData_prmy_supplier
				-- ! ,[canadian_vendor_num] = data.mikData_prmy_supplier
				-- ! ,[department_num] = data.mikData_dept
				-- ! ,[stock_category] = data.mikData_stock_category
				-- ! ,[canada_stock_category] = data.mikData_stock_category
				-- ? ,[item_type] = mikdata_item_type
				-- ? ,[item_type_attribute] = mikdata_item_type_attribute
				-- ! ,[allow_store_order] = mikdata_allow_store_order
				-- ! ,[perpetual_inventory] = data.mikData_pi_ind
				-- ! ,[inventory_control] = data.mikData_inv_control
				-- ? ,[freight_terms] = mikdata_freight_terms
				-- ! ,[auto_replenish] = data.mikData_repl_ind
				-- ! ,[sku_group] = data.mikData_sku_group
				-- ! ,[store_supplier_zone_group] = data.mikData_store_sup_zone_group
				-- ! ,[whs_supplier_zone_group] = data.mikData_wh_sup_zone_group
				-- ! ,[rms_sellable] = data.mikData_sellable_ind
				-- ! ,[rms_orderable] = data.mikData_orderable_ind
				-- ! ,[rms_inventory] = data.mikData_inventory_ind
				 Date_Last_Modified = getdate()
				,Update_User_ID = 0
			  '
			END
	       
			--  If Import...
			IF ( @SPEDYBatchTypeID = 2 )
			BEGIN
			  SET @VERBSTATEMENTSTRING = '
			  UPDATE SPD_Import_Items
				SET
				-- !  [skugroup] = data.mikData_sku_group
				-- ! ,[dept] = data.mikData_dept
				-- ! ,[class] = data.mikData_class
				-- ! ,[subclass] = data.mikData_subclass
				 [michaelssku] = data.mikData_item
				,[primaryupc] = data.mikData_prmy_ref_item_no
				-- ! ,[additionalupc1] = mikData_additionalupc1
				-- ! ,[additionalupc2] = mikData_additionalupc2
				-- ! ,[additionalupc3] = mikData_additionalupc3
				-- ! ,[additionalupc4] = mikData_additionalupc4
				-- ! ,[additionalupc5] = mikData_additionalupc5
				-- ! ,[additionalupc6] = mikData_additionalupc6
				-- ! ,[additionalupc7] = mikData_additionalupc7
				-- ! ,[additionalupc8] = mikData_additionalupc8
				-- ! ,[packsku] = mikData_packsku
				-- ! ,[planogramname] = mikData_planogramname
				-- ! ,[vendornumber] = data.mikData_prmy_supplier
				-- ! ,[vendorrank] = mikData_vendorrank
				-- ! ,[itemtask] = data.mikData_add_change
				-- ! ,[description] = data.mikData_item_desc
				-- ! ,[paymentterms] = mikData_paymentterms
				-- ! ,[days] = mikData_days
				-- ! ,[vendorminorderamount] = mikData_vendorminorderamount
				-- ! ,[vendorname] = mikData_vendorname
				-- ! ,[vendoraddress1] = mikData_vendoraddress1
				-- ! ,[vendoraddress2] = mikData_vendoraddress2
				-- ! ,[vendoraddress3] = mikData_vendoraddress3
				-- ! ,[vendoraddress4] = mikData_vendoraddress4
				-- ! ,[vendorcontactname] = mikData_vendorcontactname
				-- ! ,[vendorcontactphone] = mikData_vendorcontactphone
				-- ! ,[vendorcontactemail] = mikData_vendorcontactemail
				-- ! ,[vendorcontactfax] = mikData_vendorcontactfax
				-- ! ,[manufacturename] = mikData_manufacturename
				-- ! ,[manufactureaddress1] = mikData_manufactureaddress1
				-- ! ,[manufactureaddress2] = mikData_manufactureaddress2
				-- ! ,[manufacturecontact] = mikData_manufacturecontact
				-- ! ,[manufacturephone] = mikData_manufacturephone
				-- ! ,[manufactureemail] = mikData_manufactureemail
				-- ! ,[manufacturefax] = mikData_manufacturefax
				-- ! ,[agentcontact] = mikData_agentcontact
				-- ! ,[agentphone] = mikData_agentphone
				-- ! ,[agentemail] = mikData_agentemail
				-- ! ,[agentfax] = mikData_agentfax
				-- ! ,[vendorstylenumber] = mikData_vendorstylenumber
				-- ! ,[harmonizedcodenumber] = mikData_harmonizedcodenumber
				-- ! ,[detailinvoicecustomsdesc] = mikData_detailinvoicecustomsdesc
				-- ! ,[componentmaterialbreakdown] = mikData_componentmaterialbreakdown
				-- ! ,[componentconstructionmethod] = mikData_componentconstructionmethod
				-- ! ,[individualitempackaging] = mikData_individualitempackaging
				-- ! ,[eachinsidemastercasebox] = mikData_eachinsidemastercasebox
				-- ! ,[eachinsideinnerpack] = mikData_eachinsideinnerpack
				-- ! ,[eachpiecenetweightlbsperounce] = mikData_eachpiecenetweightlbsperounce
				-- ! ,[reshippableinnercartonlength] = mikData_reshippableinnercartonlength
				-- ! ,[reshippableinnercartonwidth] = mikData_reshippableinnercartonwidth
				-- ! ,[reshippableinnercartonheight] = mikData_reshippableinnercartonheight
				-- ! ,[mastercartondimensionslength] = mikData_mastercartondimensionslength
				-- ! ,[mastercartondimensionswidth] = mikData_mastercartondimensionswidth
				-- ! ,[mastercartondimensionsheight] = mikData_mastercartondimensionsheight
				-- ! ,[cubicfeetpermastercarton] = mikData_cubicfeetpermastercarton
				-- ! ,[weightmastercarton] = mikData_weightmastercarton
				-- ! ,[cubicfeetperinnercarton] = mikData_cubicfeetperinnercarton
				-- ! ,[fobshippingpoint] = mikData_fobshippingpoint
				-- ! ,[dutypercent] = mikData_dutypercent
				-- ! ,[dutyamount] = mikData_dutyamount
				-- ! ,[additionaldutycomment] = mikData_additionaldutycomment
				-- ! ,[additionaldutyamount] = mikData_additionaldutyamount
				-- ! ,[oceanfreightamount] = mikData_oceanfreightamount
				-- ! ,[oceanfreightcomputedamount] = mikData_oceanfreightcomputedamount
				-- ! ,[agentcommissionpercent] = mikData_agentcommissionpercent
				-- ! ,[agentcommissionamount] = mikData_agentcommissionamount
				-- ! ,[otherimportcostspercent] = mikData_otherimportcostspercent
				-- ! ,[otherimportcostsamount] = mikData_otherimportcostsamount
				-- ! ,[packagingcostamount] = mikData_packagingcostamount
				-- ! ,[totalimportburden] = mikData_totalimportburden
				-- ! ,[warehouselandedcost] = mikData_warehouselandedcost
				-- ! ,[purchaseorderissuedto] = mikData_purchaseorderissuedto
				-- ! ,[shippingpoint] = mikData_shippingpoint
				-- ! ,[countryoforigin] = mikData_countryoforigin
				-- ! ,[vendorcomments] = mikData_vendorcomments
				-- ! ,[stockcategory] = mikData_stockcategory
				-- ! ,[freightterms] = mikData_freightterms
				-- ! ,[itemtype] = mikData_itemtype
				-- ! ,[packitemindicator] = mikData_packitemindicator
				-- ! ,[itemtypeattribute] = mikData_itemtypeattribute
				-- ! ,[allowstoreorder] = mikData_allowstoreorder
				-- ! ,[inventorycontrol] = mikData_inventorycontrol
				-- ! ,[autoreplenish] = mikData_autoreplenish
				-- ! ,[prepriced] = mikData_prepriced
				-- ! ,[taxuda] = mikData_taxuda
				-- ! ,[prepriceduda] = mikData_prepriceduda
				-- ! ,[taxvalueuda] = mikData_taxvalueuda
				-- ! ,[hybridtype] = mikData_hybridtype
				-- ! ,[sourcingdc] = mikData_sourcingdc
				-- ! ,[leadtime] = mikData_leadtime
				-- ! ,[conversiondate] = mikData_conversiondate
				-- ! ,[storesuppzonegrp] = mikData_storesuppzonegrp
				-- ! ,[whsesuppzonegrp] = mikData_whsesuppzonegrp
				-- ! ,[pogmaxqty] = mikData_pogmaxqty
				-- ! ,[pogsetupperstore] = mikData_pogsetupperstore
				-- ! ,[projsalesperstorepermonth] = mikData_projsalesperstorepermonth
				-- ! ,[outboundfreight] = mikData_outboundfreight
				-- ! ,[ninepercentwhsecharge] = mikData_ninepercentwhsecharge
				-- ! ,[totalstorelandedcost] = mikData_totalstorelandedcost
				-- ! ,[rdbase] = mikData_rdbase
				-- ! ,[rdcentral] = mikData_rdcentral
				-- ! ,[rdtest] = mikData_rdtest
				-- ! ,[rdalaska] = mikData_rdalaska
				-- ! ,[rdcanada] = mikData_rdcanada
				-- ! ,[rd0thru9] = mikData_rd0thru9
				-- ! ,[rdcalifornia] = mikData_rdcalifornia
				-- ! ,[rdvillagecraft] = mikData_rdvillagecraft
				-- ! ,[hazmatyes] = mikData_hazmatyes
				-- ! ,[hazmatno] = mikData_hazmatno
				-- ! ,[hazmatmfgcountry] = mikData_hazmatmfgcountry
				-- ! ,[hazmatmfgname] = mikData_hazmatmfgname
				-- ! ,[hazmatmfgflammable] = mikData_hazmatmfgflammable
				-- ! ,[hazmatmfgcity] = mikData_hazmatmfgcity
				-- ! ,[hazmatcontainertype] = mikData_hazmatcontainertype
				-- ! ,[hazmatmfgstate] = mikData_hazmatmfgstate
				-- ! ,[hazmatcontainersize] = mikData_hazmatcontainersize
				-- ! ,[hazmatmfgphone] = mikData_hazmatmfgphone
				-- ! ,[hazmatmsdsuom] = mikData_hazmatmsdsuom
				-- ! ,[tssa] = mikData_tssa
				-- ! ,[csa] = mikData_csa
				-- ! ,[ul] = mikData_ul
				-- ! ,[licenceagreement] = mikData_licenceagreement
				-- ! ,[fumigationcertificate] = mikData_fumigationcertificate
				-- ! ,[kilndriedcertificate] = mikData_kilndriedcertificate
				-- ! ,[chinacominspecnumandccibstickers] = mikData_chinacominspecnumandccibstickers
				-- ! ,[originalvisa] = mikData_originalvisa
				-- ! ,[textiledeclarationmidcode] = mikData_textiledeclarationmidcode
				-- ! ,[quotachargestatement] = mikData_quotachargestatement
				-- ! ,[msds] = mikData_msds
				-- ! ,[tsca] = mikData_tsca
				-- ! ,[dropballtestcert] = mikData_dropballtestcert
				-- ! ,[manmedicaldevicelisting] = mikData_manmedicaldevicelisting
				-- ! ,[manfdaregistration] = mikData_manfdaregistration
				-- ! ,[copyrightindemnification] = mikData_copyrightindemnification
				-- ! ,[fishwildlifecert] = mikData_fishwildlifecert
				-- ! ,[proposition65labelreq] = mikData_proposition65labelreq
				-- ! ,[cccr] = mikData_cccr
				-- ! ,[formaldehydecompliant] = mikData_formaldehydecompliant
				-- ! ,[is_valid] = mikData_is_valid
				-- ! ,[tax_wizard] = mikData_tax_wizard
				-- ! ,[rms_sellable] = data.mikData_sellable_ind
				-- ! ,[rms_orderable] = data.mikData_orderable_ind
				-- ! ,[rms_inventory] = data.mikData_inventory_ind
				,DateLastModified = getdate()
				,UpdateUserID = 0
			  '
			END
	        
			SET @WHERECLAUSE1 = '
			  WHERE ID = ''0' + CONVERT(varchar(20), @SPEDYItemID) + '''
			'

			SET @WHERECLAUSE2 = '
			  WHERE ID = ''0' + CONVERT(varchar(20), @SPEDYItemHeaderID) + '''
			'

			IF ( (NULLIF(@VERBSTATEMENTSTRING, '') + @SELECTSTATEMENTSTRING) IS NOT NULL )
			BEGIN
			  EXEC(@PREPARESTRING + @VERBSTATEMENTSTRING + @SELECTSTATEMENTSTRING + @WHERECLAUSE1 + @CLEANUPSTRING)

			  PRINT('Updated import with SKU')

			  IF ( (NULLIF(@VERBSTATEMENTSTRING2, '') + @SELECTSTATEMENTSTRING) IS NOT NULL )
			  BEGIN
				EXEC(@PREPARESTRING + @VERBSTATEMENTSTRING2 + @SELECTSTATEMENTSTRING + @WHERECLAUSE2 + @CLEANUPSTRING)
			  END

			  IF ( @SPEDYBatchTypeID = 1 )
			  BEGIN
				SELECT @NumParentItemsInBatchNeedingaSKU = COUNT(*)
				FROM SPD_Batch b
				INNER JOIN SPD_Item_Headers h ON h.Batch_ID = b.ID
				INNER JOIN SPD_Items i ON i.Item_Header_ID = h.ID
				WHERE b.ID = @SPEDYBatchID AND Michaels_SKU IS NULL
				-- FJL Feb 2010 Just check first 2 chars of PackItemIndicator
				  AND COALESCE(RTRIM(REPLACE(LEFT(i.[pack_item_indicator],2), '-', '')), '') IN ('D','DP')

				SELECT @NumItemsInBatch = COUNT(*)
				FROM SPD_Batch b
				INNER JOIN SPD_Item_Headers h ON h.Batch_ID = b.ID
				INNER JOIN SPD_Items i ON i.Item_Header_ID = h.ID
				WHERE b.ID = @SPEDYBatchID 
				-- FJL Feb 2010 Just check first 2 chars of PackItemIndicator
				  AND COALESCE(RTRIM(REPLACE(LEFT(i.[pack_item_indicator],2), '-', '')), '') NOT IN ('D','DP')

				SELECT @NumCompleteItemsInBatch = COUNT(*)
				FROM SPD_Batch b
				INNER JOIN SPD_Item_Headers h ON h.Batch_ID = b.ID
				INNER JOIN SPD_Items i ON i.Item_Header_ID = h.ID
				WHERE b.ID = @SPEDYBatchID AND Michaels_SKU IS NOT NULL
				  AND COALESCE(RTRIM(REPLACE(LEFT(i.[pack_item_indicator],2), '-', '')), '') NOT IN ('D','DP')
	              
				IF (@SPEDYEnvVars_Test_Mode = 1) PRINT 'Completed ' + CONVERT(varchar(15), @NumCompleteItemsInBatch) + ' of ' + CONVERT(varchar(15), @NumItemsInBatch)
			  END
	          
			  IF ( @SPEDYBatchTypeID = 2 )
			  BEGIN
				SELECT @NumParentItemsInBatchNeedingaSKU = COUNT(*)
				FROM SPD_Batch b
				INNER JOIN SPD_Import_Items i ON i.Batch_ID = b.ID
				WHERE b.ID = @SPEDYBatchID AND MichaelsSKU IS NULL
				-- FJL Feb 2010 Just check first 2 chars of PackItemIndicator
				  AND COALESCE(RTRIM(REPLACE(LEFT(i.[packitemindicator],2), '-', '')), '') IN ('D','DP')

				SELECT @NumItemsInBatch = COUNT(*)
				FROM SPD_Batch b
				INNER JOIN SPD_Import_Items i ON i.Batch_ID = b.ID
				WHERE b.ID = @SPEDYBatchID
				-- FJL Feb 2010 Just check first 2 chars of PackItemIndicator
				  AND COALESCE(RTRIM(REPLACE(LEFT(i.[packitemindicator],2), '-', '')), '') NOT IN ('D','DP')

				SELECT @NumCompleteItemsInBatch = COUNT(*)
				FROM SPD_Batch b
				INNER JOIN SPD_Import_Items i ON i.Batch_ID = b.ID
				WHERE b.ID = @SPEDYBatchID AND MichaelsSKU IS NOT NULL
				  AND COALESCE(RTRIM(REPLACE(LEFT(i.[packitemindicator],2), '-', '')), '') NOT IN ('D','DP')

				IF (@SPEDYEnvVars_Test_Mode = 1) PRINT 'Completed ' + CONVERT(varchar(15), @NumCompleteItemsInBatch) + ' of ' + CONVERT(varchar(15), @NumItemsInBatch)
			  END
	          
	          -- FJL Aug 2010 - Only log update message if Items have not been SKUed and History Record Completed message not saved
			  IF (
				COALESCE(
				  (
				  SELECT COUNT(*) 
				  FROM SPD_Batch_History 
				  WHERE SPD_Batch_ID = @SPEDYBatchID
					AND Workflow_Stage_ID = @STAGE_COMPLETED
				  ), 0) = 0 --Only log this update if the batch has not been marked Complete (to prevent duplicate log entries).
				AND (
				  SELECT isNull(NI_AllSKUItems_Received,0)
				  FROM SPD_Batch
				  WHERE ID = @SPEDYBatchID ) = 0
			  )
			  BEGIN
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
				  @SPEDYBatchID,
				  @STAGE_WAITINGFORSKU,
				  'System Activity',
				  getdate(),
				  0,
				  'An update message was received for an item in this batch. ' + CONVERT(varchar(15), @NumCompleteItemsInBatch) 
				  + ' of the ' + CONVERT(varchar(15), @NumItemsInBatch) + ' items in this batch have received a sku.'
				)
				
				-- Flag the batch so these Update messages don't fill the batch history
				IF @NumCompleteItemsInBatch = @NumItemsInBatch
				BEGIN
					UPDATE SPD_Batch SET
						NI_AllSKUItems_Received = 1
						,date_modified = getdate()
						,modified_user = 0
					WHERE ID = @SPEDYBatchID
				END
			  END

				-- Because Item Messages can come in to update the Rel 2 Item Master that look like new item, do not log dup messages.
			/*	
			  IF (
				COALESCE(
				(
				  SELECT COUNT(*) 
				  FROM SPD_Batch_History 
				  WHERE SPD_Batch_ID = @SPEDYBatchID
					AND Workflow_Stage_ID = @STAGE_COMPLETED
				), 0) > 0 --If the batch has been marked Complete, raise an eyebrow in the logs.
			  )
			  BEGIN
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
				  @SPEDYBatchID,
				  @STAGE_COMPLETED,
				  'System Activity',
				  getdate(),
				  0,
				  'An update message was received for an item in this batch even though this batch was already marked Complete.'
				)
			  END
			*/
			
			  -- Batch goes to @STAGE_COMPLETED if successful
			  IF ( 
				@NumCompleteItemsInBatch = @NumItemsInBatch 		-- All Items received a SKU
				AND @NumParentItemsInBatchNeedingaSKU = 0 			-- No Pack Item record needs a sku either
				AND COALESCE((										-- Batch has not already been logged as complete
					SELECT COUNT(*) 
					FROM SPD_Batch_History 
					WHERE SPD_Batch_ID = @SPEDYBatchID
					  AND Workflow_Stage_ID = @STAGE_COMPLETED
					), 0) = 0 --Only log completion if it hasn't been logged before (to prevent duplicate emails).
			  )
			  BEGIN
				EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Logging Batch as complete...'
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
				  @SPEDYBatchID,
				  @STAGE_WAITINGFORSKU,
				  'Complete',
				  getdate(),
				  0,
				  'All items have received a Positive Response from RMS.  Marking Batch as Complete.'
				)
				
				 --Update SPD_Batch_History_Stage_Durations table with End Date for "Waiting" stage
				Update SPD_Batch_History_Stage_Durations
				Set End_Date = getDate(), [Hours]=dbo.BDATEDIFF_BUSINESS_HOURS([Start_Date], getDate(), DEFAULT, DEFAULT)
				Where Batch_ID = @SPEDYBatchID And Stage_ID = @STAGE_WAITINGFORSKU and End_Date is null
      

				UPDATE SPD_Batch SET 
				  Workflow_Stage_ID = @STAGE_COMPLETED,
				  Is_Valid = 1,
				  Date_Modified = getdate(),
				  Modified_User = 0
				WHERE ID = @SPEDYBatchID
	          
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
				  @SPEDYBatchID,
				  @STAGE_COMPLETED,
				  'Complete',
				  getdate(),
				  0,
				  'Batch Complete.'
				)
				
				-- Set Flag on to Update the Item Master when this message has been process by the Item Maint routines
				SET @UpdateIMFromNI = 1
				Set @UpdateBID = @SPEDYBatchID
				
				EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Sending New Item Completed Email Message'
				-- Send emails
				SET @MichaelsEmailRecipients = NULL
				SET @EmailRecipients = NULL
	                      
				SELECT @MichaelsEmailRecipients = COALESCE(@MichaelsEmailRecipients + '; ', '') + su.Email_Address
				FROM SPD_Batch_History bh
				INNER JOIN Security_User su ON su.ID = bh.modified_user
				WHERE IsNumeric(bh.modified_user) = 1 
				  AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
				  AND SPD_Batch_ID = @SPEDYBatchID
				  AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) > 0
				GROUP BY su.Email_Address
	            
				SELECT @EmailRecipients = COALESCE(@EmailRecipients + '; ', '') + su.Email_Address
				FROM SPD_Batch_History bh
				INNER JOIN Security_User su ON su.ID = bh.modified_user
				WHERE IsNumeric(bh.modified_user) = 1 
				  AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
				  AND SPD_Batch_ID = @SPEDYBatchID
				  AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) = 0
				GROUP BY su.Email_Address
	            
				SELECT @SPEDYBatchGUID = [GUID] FROM SPD_Batch WHERE ID = @SPEDYBatchID

				IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
				IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

				-- FJL July 2010 - Get more info for the subject line per IS Req F47
					Declare @DeptNo varchar(5), @VendorNo varchar(20), @VendorName varchar(50)
					Select @DeptNo = convert(varchar(5), Fineline_Dept_ID)
						, @VendorNo = convert(varchar(20), Vendor_Number)
						, @VendorName = Vendor_Name
					From SPD_Batch
					Where ID = @SPEDYBatchID
				  --NAK 5/20/2013:  Construct Email subject, but don't include Department or Vendor if there isn't one associated with the batch (i.e. Trilingual Maintenance Translation Batches)
				  SET @EmailSubject = 'SPEDY New Item Complete. ' 
				  IF COALESCE(@DeptNo,'0') <> '0' AND COALESCE(@VendorNo, '0') <> '0' 
				  BEGIN
					SET @EmailSubject = @EmailSubject + 'D: ' + COALESCE(@DeptNo, '') + ' ' + COALESCE(@VendorNo, '') + '-' + COALESCE(@VendorName, '') + '.'
				  END
				  SET @EmailSubject = @EmailSubject + ' Log ID#: ' +  convert(varchar(20),@SPEDYBatchID)
				--SET @EmailSubject = 'SPEDY Batch ' + CONVERT(varchar(20), COALESCE(@SPEDYBatchID, '')) + ' is Complete.'
				--IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
	            
				-- *** Michaels Email
				SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
					+ '  Congratulations!</p><p>Next Steps:<ul type="square" style="padding-top: 0; margin-top: 0;">'
					+ '<li><a href="' + @SPEDYEnvVars_SPD_Root_URL + '/batchexport.aspx?guid=' + @SPEDYBatchGUID + '">Download the completed batch to Excel</a></li>'
					+ '<li><a href="' + @SPEDYEnvVars_SPD_Root_URL + '">Login to SPEDY to review this batch.</a></li>'
					+ '</ul></p></font>'
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
				  SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
				  + '  Congratulations!</p><p>Next Steps:<ul type="square" style="padding-top: 0; margin-top: 0;">'
				  + '<li><a href="' + @SPEDYEnvVars_SPD_Vendor_URL + '/batchexport.aspx?guid=' + @SPEDYBatchGUID + '">Download the completed batch to Excel</a></li>'
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

			  END --IF ( @NumCompleteItemsInBatch = @NumItemsInBatch)



			  -------------------------------------------------------------------------------------------------------------------
			  -- Batch with Pack skus (if it needs a sku) goes back to stage 10 when all other skus have been received.
			  -------------------------------------------------------------------------------------------------------------------
			  -- 1/27/2010 - NDF - CHANGED => now sends the parent(s) to RMS
			  -- 8/28/2010 - FJL - Changed : Only do this if the message has not been sent yet so that repeated messages are not sent
			  -------------------------------------------------------------------------------------------------------------------
			  IF ( 
				@NumCompleteItemsInBatch = @NumItemsInBatch 
				AND @NumParentItemsInBatchNeedingaSKU > 0 
				AND (	SELECT COUNT(*) 
						FROM SPD_Batch_History
						WHERE SPD_Batch_ID = @SPEDYBatchID
						  AND Workflow_Stage_ID = @STAGE_COMPLETED ) = 0
				AND (	Select isNull(NI_PackMsg_Sent,0)
						From SPD_Batch
						Where ID = @SPEDYBatchID ) = 0 
				)
			  BEGIN
				-- Resend the batch to generate the Pack Request message
				EXEC sp_SPD_Batch_PublishMQMessage_ByBatchID @SPEDYBatchID
			  END 

			  SET @SUCCESSFLAG = 1
			END
		END
		ELSE
		BEGIN
		  PRINT 'Batch reference number "' + COALESCE(@SPEDYRefString, '') + '" does not refer to a valid (non-completed / active) batch. No update attempted.'
		END	-- Process When @WorkflowID = 1
      END
      
      -- + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
      -- PROCESS ITEM UPDATE MESSAGE
      -- + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
      -- FJL Sept 2010 -- NO LONGER UPDATE THIS TABLE as its functionality has been moved to the SPD_Item_Master_SKU table maintained by Item Maint process
      
  --    IF (@XML_DataSegment_Action IN ('Update', 'Insert', 'Delete'))
  --    BEGIN
  --      set @msg = 'Processing New Item Item Master Message: ' + convert(varchar(20),@MessageID) + ' ( Record No. ' + convert(varchar(20),@MessageRecNo) + ' )'
		--EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg
  --      IF (NULLIF(@SPEDYRefString, '') IS NULL)
  --      BEGIN
  --        -- this is an item update message only.
  --        UPDATE SPD_MQComm_Message
  --        SET Message_Type_ID = 9
  --        WHERE ID = @MessageID AND Message_Type_ID <> 2
  --      END

  --      IF (@XML_DataSegment_Action = 'Delete')
  --      BEGIN
  --        PRINT 'Item Delete Message'

  --        SET @VERBSTATEMENTSTRING = '
  --        DELETE SPD_Item_Master
  --        '

  --        SET @WHERECLAUSE1 = '
  --        WHERE 
  --          [ITEM] = data.mikData_item 
  --          OR [UPC] = COALESCE(data.mikData_prmy_ref_item_no, mikData_upc)
  --        '
  --      END
  --      ELSE
  --      BEGIN
  --        -- PRINT 'Item Update Message'

  --        SET @VERBSTATEMENTSTRING = '
  --        UPDATE SPD_Item_Master
  --        SET 
  --           [ITEM] = data.mikData_item
  --          ,[UPC] = COALESCE(data.mikData_prmy_ref_item_no, mikData_upc)
  --          ,[ITEM_DESCRIPTION] = COALESCE(data.mikData_item_desc, ''MISSING ITEM DESCRIPTION IN RMS XML MESSAGE ' + CONVERT(NVARCHAR(20), @MessageID) + ''')
  --          ,Date_Last_Modified = getdate()
  --        '

  --        SET @VERBSTATEMENTSTRING2 = '
  --        INSERT INTO SPD_Item_Master 
  --        (
  --           [ITEM]
  --          ,[UPC]
  --          ,[ITEM_DESCRIPTION]
  --        )
  --        SELECT 
  --           data.mikData_item
  --          ,COALESCE(data.mikData_prmy_ref_item_no, mikData_upc)
  --          ,COALESCE(data.mikData_item_desc, ''MISSING ITEM DESCRIPTION IN RMS XML MESSAGE ' + CONVERT(NVARCHAR(20), @MessageID) + ''')
  --        '

  --        SET @WHERECLAUSE1 = '
  --        WHERE [ITEM] = data.mikData_item AND [UPC] = COALESCE(data.mikData_prmy_ref_item_no, mikData_upc)
  --        '

  --        SET @WHERECLAUSE2 = '
  --        WHERE NOT EXISTS (SELECT [item] FROM SPD_Item_Master WHERE [ITEM] = data.mikData_item AND [UPC] = COALESCE(data.mikData_prmy_ref_item_no, mikData_upc))
  --        '
       
  --      END

  --      SET @SELECTSTATEMENTSTRING = '
  --      FROM OPENXML (@intXMLDocHandle, ''/mikMessage'')
  --      WITH
  --      (
	 --        mikHeader_Source varchar(1000) ''mikHeader/Source''
	 --       ,mikHeader_Contents varchar(1000) ''mikHeader/Contents''
	 --       ,mikHeader_ThreadID varchar(1000) ''mikHeader/ThreadID''
	 --       ,mikHeader_PublishTime varchar(1000) ''mikHeader/PublishTime''
  --      ) hdr
  --      INNER JOIN (
	 --       SELECT *
	 --       FROM OPENXML (@intXMLDocHandle, ''/mikMessage/mikData[@type=''''Sku'''' or @type=''''UPC'''']'')
	 --       WITH
	 --       (
	 --          mikDataAttrs_ID varchar(1000) ''@id''
	 --         ,mikDataAttrs_Type varchar(1000) ''@type''
	 --         ,mikDataAttrs_Action varchar(1000) ''@action''
	 --         ,mikData_item varchar(1000) ''item''
	 --         ,mikData_prmy_ref_item_no varchar(1000) ''prmy_ref_item_no''
	 --         ,mikData_upc varchar(1000) ''upc''
  --          ,mikData_item_desc varchar(1000) ''item_desc''
  --          ,mikData_short_desc varchar(1000) ''short_desc''
  --          ,mikData_desc_up varchar(1000) ''desc_up''
	 --       )
  --      ) data ON 1 = 1 -- NULLIF(data.mikData_item, '''') IS NOT NULL
  --      '

  --      IF ( (NULLIF(@VERBSTATEMENTSTRING, '') + @SELECTSTATEMENTSTRING) IS NOT NULL )
  --      BEGIN
  --        --PRINT @PREPARESTRING + @VERBSTATEMENTSTRING + @SELECTSTATEMENTSTRING + @WHERECLAUSE1 + @CLEANUPSTRING
  --        EXEC(@PREPARESTRING + @VERBSTATEMENTSTRING + @SELECTSTATEMENTSTRING + @WHERECLAUSE1 + @CLEANUPSTRING)
  --      END
        
  --      IF ( (NULLIF(@VERBSTATEMENTSTRING2, '') + @SELECTSTATEMENTSTRING) IS NOT NULL )
  --      BEGIN
  --        EXEC(@PREPARESTRING + @VERBSTATEMENTSTRING2 + @SELECTSTATEMENTSTRING + @WHERECLAUSE2 + @CLEANUPSTRING)
  --      END
/*
        SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_FromAddress
        IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address
        --SET @MichaelsEmailRecipients = 'ken.wallace@novalibra.com'

        SET @EmailSubject = 'SPEDY has received an Item Master update from RMS.'
        --IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
        
        -- *** Michaels Email
        SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  </p><p>This is an informational message only. No action is required.</p></font>'
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
*/
      --  SET @SUCCESSFLAG = 1
      --END
                 
    END -- IF ( @XML_HeaderSegment_Source = 'RIB.etItemsFromRMS' )

    -- ========================================================================
    -- MESSAGE TYPE: ITEM ERROR MESSAGE  -- These are only good for New Item 
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'SPEDYItemError' )
    BEGIN      
  	  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing New Item Error Message'
      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 3
      WHERE ID = @MessageID

      -- Step 1. Get the identifier string for the referenced spedy transaction
      SELECT 
         @SPEDYRefString = mikData_spedy_item_id
        ,@XML_DataSegment_ID = mikDataAttrs_id
        ,@XML_DataSegment_Type = mikDataAttrs_type
        ,@XML_DataSegment_Action = mikDataAttrs_action
        ,@XML_DataSegment_PrimaryUPC = mikData_primary_upc
        ,@XML_DataSegment_ErrorMessage1 = mikData_error_message1
        ,@XML_DataSegment_ErrorMessage2 = mikData_error_message2
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''SPEDYItemError'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_spedy_item_id varchar(1000) 'spedy_item_id'
        ,mikData_primary_upc varchar(1000) 'primary_upc'
        ,mikData_error_message1 varchar(1000) 'error_message1'
        ,mikData_error_message2 varchar(1000) 'error_message2'
      )
      IF (@SPEDYEnvVars_Test_Mode = 1) PRINT '@SPEDYRefString: ' + @SPEDYRefString  

      -- Step 2. Split Batch from Item_ID
      SET @SPEDYBatchID = 0
      SET @SPEDYBatchTypeID = 0
      SET @SPEDYItemID = 0
      SET @WorkflowStageID = 0

      IF (LEN(@SPEDYRefString) > 0)
      BEGIN
        IF (CHARINDEX('.', @SPEDYRefString) > 0)
        BEGIN
          IF (ISNUMERIC(SUBSTRING(@SPEDYRefString, 0, CHARINDEX('.', @SPEDYRefString))) = 1)
          BEGIN
            SET @SPEDYBatchID = SUBSTRING(@SPEDYRefString, 0, CHARINDEX('.', @SPEDYRefString))
          END        
        END
      END

      IF (@SPEDYBatchID > 0)
      BEGIN
		SELECT @WorkflowID = WS.Workflow_ID
		FROM SPD_Batch B
			join SPD_Workflow_Stage ws on B.workflow_Stage_ID = ws.ID
		WHERE B.ID = @SPEDYBatchID
      END
      
      IF (@SPEDYBatchID > 0 and @WorkflowID = 1)
      BEGIN
        UPDATE SPD_MQComm_Message
        SET SPD_Batch_ID = @SPEDYBatchID
        WHERE ID = @MessageID

        -- Step 3. Lookup Batch and determine if Import or Domestic
        -- Domestic Batch = 1
        -- Import Batch = 2
        SELECT @SPEDYBatchTypeID = COALESCE(Batch_Type_ID, 0) FROM SPD_Batch WHERE ID = @SPEDYBatchID

        IF ( @SPEDYBatchTypeID > 0)
        BEGIN
          IF ( ISNUMERIC(SUBSTRING(@SPEDYRefString, CHARINDEX('.', @SPEDYRefString)+1, LEN(@SPEDYRefString) ) ) = 1)
          BEGIN
            SET @SPEDYItemID = SUBSTRING(@SPEDYRefString, CHARINDEX('.', @SPEDYRefString)+1, LEN(@SPEDYRefString) )
          END
        END
      END

	  -- Set Stages based on Workflow for the error
	  select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = @WorkflowID and Stage_Type_id = 4
	  select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = @WorkflowID and Stage_Type_id = 3
	  select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = @WorkflowID and Stage_Type_id = 6
      
      SELECT @WorkflowStageID = Workflow_Stage_ID FROM SPD_Batch WHERE ID = @SPEDYBatchID

      IF ( @SPEDYBatchTypeID NOT IN (1, 2) )
      BEGIN
        PRINT 'Batch reference number "' + COALESCE(@SPEDYRefString, '') + '" does not refer to a valid batch. No update attempted.'
      END
      ELSE
      BEGIN
        -- Step 5. Record log of update
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
          @SPEDYBatchID,
          @WorkflowStageID,
          'System Activity',
          getdate(),
          0,
          'Error response received from RMS.<br><b>Error Item:</b> ' + CONVERT(varchar(20), @SPEDYItemID) + '<br><b>Error Text:</b> ' + COALESCE(@XML_DataSegment_ErrorMessage1, '') + COALESCE(' ' + @XML_DataSegment_ErrorMessage2, '')
        )

        IF ( @WorkflowStageID <> @STAGE_COMPLETED)
        BEGIN
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
            @SPEDYBatchID,
            @STAGE_WAITINGFORSKU,
            'System Activity',
            getdate(),
            0,
            'Sending batch back to previous stage (DBC/QA) because of item addition error message received from RMS.'
          )

          UPDATE SPD_Batch SET 
            Workflow_Stage_ID = @STAGE_DBC,
            Date_Modified = getdate(),
            Modified_User = 0
          WHERE ID = @SPEDYBatchID
        END
      
        -- Step 6. Send email alerts
        SET @MichaelsEmailRecipients = NULL

        SELECT @MichaelsEmailRecipients = COALESCE(@MichaelsEmailRecipients + '; ', '') + su.Email_Address
        FROM SPD_Batch_History bh
        INNER JOIN Security_User su ON su.ID = bh.modified_user
        WHERE IsNumeric(bh.modified_user) = 1 
          AND bh.workflow_stage_id = @STAGE_DBC
          AND LOWER(bh.[action]) = 'approve'
          AND NULLIF(LTRIM(RTRIM(su.Email_Address)), '') IS NOT NULL
          AND SPD_Batch_ID = @SPEDYBatchID
          AND CHARINDEX('michaels.com', LOWER(su.Email_Address)) > 0
        GROUP BY su.Email_Address

        IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

        SET @EmailSubject = 'SPEDY has received an RMS Error for New Item Batch ' + COALESCE(CONVERT(varchar(20),@SPEDYBatchID), '') + '.'
        --IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
        
        -- *** Michaels Email
        SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject 
        + '&nbsp;&nbsp;Please view the provided error text to resolve this matter.</p><p><b>Error Batch:</b> ' + CONVERT(varchar(20), @SPEDYBatchID) + '</p>'
        + '<p><b>Error Item:</b> ' + CONVERT(varchar(20), @SPEDYItemID) + '<br /></p>'
        + '<p><b>Error Text:</b><br />&nbsp;&nbsp;&nbsp;' + COALESCE(@XML_DataSegment_ErrorMessage1, '') + COALESCE('<br />&nbsp;&nbsp;&nbsp;' + @XML_DataSegment_ErrorMessage2, '') + '</p>'
        + '<p><a href="' + @SPEDYEnvVars_SPD_Root_URL + '">Login to SPEDY</a> to review this batch and correct any errors.</p></font>'
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

        SET @SUCCESSFLAG = 1
      END
    END

    -- =======================================================================================================
    -- MESSAGE TYPE: DEPARTMENT MESSAGE - Updates both Security_Privilege Table And SPD_Fineline_Dept table
    -- =======================================================================================================
    IF ( @XML_HeaderSegment_Source = 'RIB.etMerchHierFromRMS' AND @XML_HeaderSegment_Contents = 'Deps' )
    BEGIN
  	  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing Department Message'
      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 4
      WHERE ID = @MessageID
      
      UPDATE SPD_Fineline_Dept
        SET DEPT = x.mikData_dept, DEPT_NAME = x.mikData_dept_name,
        Date_Last_Modified = getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Deps'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_dept varchar(1000) 'dept'
        ,mikData_dept_name varchar(1000) 'dept_name'
      ) x
      WHERE DEPT = x.mikData_dept

      INSERT INTO SPD_Fineline_Dept
      (DEPT, DEPT_NAME)
      SELECT x.mikData_dept, x.mikData_dept_name
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Deps'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_dept varchar(1000) 'dept'
        ,mikData_dept_name varchar(1000) 'dept_name'
      ) x
      WHERE NOT EXISTS (SELECT DEPT FROM SPD_Fineline_Dept WHERE DEPT = x.mikData_dept)

	  -- Now do the Security_Privilege table based on the Fineline dept table
	  UPDATE sp 
		SET
			 [Privilege_Name]		= CONVERT(varchar(10), d.DEPT) + ' - ' + d.DEPT_NAME
			, [Privilege_Summary]	= 'Can View Department ' + CONVERT(varchar(10), d.DEPT) + ': ' + d.DEPT_NAME
			, [Date_Last_Modified] = getdate()
			
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Deps'']')
      WITH (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_dept varchar(1000) 'dept'
        ,mikData_dept_name varchar(1000) 'dept_name'
      ) as X
		Join SPD_Fineline_Dept d	on convert(varchar(10),D.Dept) = X.mikData_dept			--SPD.DEPT.20
		Join Security_Privilege sp	on convert(int,D.Dept) = convert(int, SUBSTRING(Constant,10,len(Constant)-9))	
		Where sp.scope_id = 1002


		--FROM Security_Privilege sp
		--	Join SPD_Fineline_Dept d on convert(int,D.Dept) = convert(int, SUBSTRING(Constant,10,len(Constant)-9))			--SPD.DEPT.20
		--Where sp.scope_id = 1002

	  -- and Inserts	
      INSERT INTO Security_Privilege
                 ([Scope_ID]
                 ,[Privilege_Name]
                 ,[Privilege_ShortName]
                 ,[Privilege_Summary]
                 ,[Constant]
                 ,[SortOrder]
                 ,[Date_Created]
                 )
      SELECT
                 1002
                 ,CONVERT(varchar(10), d.DEPT) + ' - ' + d.DEPT_NAME
                 ,'DEPT' + RIGHT('000' + CONVERT(varchar(10), d.DEPT), 3)
                 ,'Can View Department ' + CONVERT(varchar(10), d.DEPT) + ': ' + d.DEPT_NAME
                 ,'SPD.DEPT.' + CONVERT(varchar(10), d.DEPT)
                 ,RIGHT('00000' + CONVERT(varchar(10), d.DEPT), 5)
                 , getdate()
      FROM SPD_Fineline_Dept d
      WHERE NOT EXISTS (SELECT [Constant] FROM Security_Privilege WHERE [Constant] = 'SPD.DEPT.' + CONVERT(varchar(10), d.DEPT))

      SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_FromAddress
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

      SET @EmailSubject = 'SPEDY has received a Fineline Department update from RMS.'
      --IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
      
      -- *** Michaels Email
      SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  </p><p>This is an informational message only. No action is required.</p></font>'
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

      SET @SUCCESSFLAG = 1
    END

    -- ========================================================================
    -- MESSAGE TYPE: CLASS MESSAGE
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RIB.etMerchHierFromRMS' AND @XML_HeaderSegment_Contents = 'Class' )
    BEGIN
  	  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing Class Message'
      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 5
      WHERE ID = @MessageID
      
      UPDATE SPD_Fineline_Class
        SET DEPT = x.mikData_dept, 
        CLASS = x.mikData_class, 
        CLASS_NAME = x.mikData_class_name,
        Date_Last_Modified = getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Class'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_dept varchar(1000) 'dept'
        ,mikData_class varchar(1000) 'class'
        ,mikData_class_name varchar(1000) 'class_name'
      ) x
      WHERE DEPT = x.mikData_dept AND CLASS = x.mikData_class

      INSERT INTO SPD_Fineline_Class
      (
        DEPT, 
        CLASS,
        CLASS_NAME
      )
      SELECT 
        x.mikData_dept, 
        x.mikData_class,
        x.mikData_class_name
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Class'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_dept varchar(1000) 'dept'
        ,mikData_class varchar(1000) 'class'
        ,mikData_class_name varchar(1000) 'class_name'
      ) x
      WHERE NOT EXISTS (SELECT * FROM SPD_Fineline_Class WHERE DEPT = x.mikData_dept AND CLASS = x.mikData_class)

      SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_FromAddress
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

      SET @EmailSubject = 'SPEDY has received a Fineline Class update from RMS.'
      --IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
      
      -- *** Michaels Email
      SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  </p><p>This is an informational message only. No action is required.</p></font>'
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

      SET @SUCCESSFLAG = 1
    END

    -- ========================================================================
    -- MESSAGE TYPE: SUBCLASS MESSAGE
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RIB.etMerchHierFromRMS' AND @XML_HeaderSegment_Contents = 'Subclass' )
    BEGIN
  	  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing SubClass Message'
      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 6
      WHERE ID = @MessageID
      
      UPDATE SPD_Fineline_SubClass
        SET DEPT = x.mikData_dept, 
        CLASS = mikData_class, 
        SUBCLASS = mikData_subclass, 
        SUB_NAME = x.mikData_sub_name,
        Date_Last_Modified = getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Subclass'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_dept varchar(1000) 'dept'
        ,mikData_class varchar(1000) 'class'
        ,mikData_subclass varchar(1000) 'subclass'
        ,mikData_sub_name varchar(1000) 'sub_name'
      ) x
      WHERE DEPT = x.mikData_dept AND CLASS = x.mikData_class AND SUBCLASS = x.mikData_subclass

      INSERT INTO SPD_Fineline_SubClass
      (
        DEPT, 
        CLASS,
        SUBCLASS,
        SUB_NAME
      )
      SELECT 
        x.mikData_dept, 
        x.mikData_class,
        x.mikData_subclass,
        x.mikData_subclass_name
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Subclass'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_dept varchar(1000) 'dept'
        ,mikData_class varchar(1000) 'class'
        ,mikData_subclass varchar(1000) 'subclass'
        ,mikData_subclass_name varchar(1000) 'subclass_name'
      ) x
      WHERE NOT EXISTS (SELECT * FROM SPD_Fineline_SubClass WHERE DEPT = x.mikData_dept AND CLASS = x.mikData_class AND SUBCLASS = x.mikData_subclass)

      SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_FromAddress
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

      SET @EmailSubject = 'SPEDY has received a Fineline Subclass update from RMS.'
      --IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
      
      -- *** Michaels Email
      SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  </p><p>This is an informational message only. No action is required.</p></font>'
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

      SET @SUCCESSFLAG = 1
    END

    -- ========================================================================
    -- MESSAGE TYPE: USERS UPDATE MESSAGE
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'Users' )
    BEGIN
  	  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing User Update Message'
      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 7
      WHERE ID = @MessageID
      
      UPDATE Security_User
        SET Email_Address = COALESCE(NULLIF(x.mikData_user_email, ''), x.mikData_user_login + '@michaels.com'),
        Date_Last_Modified = getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Users'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_user_login varchar(1000) 'user_id' -- user_id in the message is the loginid
        ,mikData_user_name varchar(1000) 'user_name' -- this is the full name
        ,mikData_user_email varchar(1000) 'user_email' -- user email addy
      ) x
      WHERE UserName = x.mikData_user_login AND NULLIF(x.mikData_user_email, '') IS NOT NULL

      INSERT INTO Security_User
      (
        UserName,
        [Password],
        Email_Address
      )
      SELECT x.mikData_user_login, 'c13v3r_pwd', 
        COALESCE(NULLIF(x.mikData_user_email, ''), x.mikData_user_login + '@michaels.com')
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Users'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_user_login varchar(1000) 'user_id' -- user_id in the message is the loginid
        ,mikData_user_name varchar(1000) 'user_name' -- this is the full name
        ,mikData_user_email varchar(1000) 'user_email' -- user email addy
      ) x
      WHERE NOT EXISTS (SELECT * FROM Security_User WHERE UserName = x.mikData_user_login)
      AND NULLIF(mikData_user_login, '') IS NOT NULL

      SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_FromAddress
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

      SET @EmailSubject = 'SPEDY has received a User update from RMS.'
      --IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
      
      -- *** Michaels Email
      SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  </p><p>You may need to <a href="' + @SPEDYEnvVars_SPD_Admin_URL + '">login to the SPEDY admin tools</a> to modify user permissions.</p></font>'
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

      SET @SUCCESSFLAG = 1
    END

    -- ========================================================================
    -- MESSAGE TYPE: SUPPLIER UPDATE MESSAGE
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'ORFN_MQSEND' AND @XML_HeaderSegment_Contents = 'Supplier' )
    BEGIN
  	  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing Supplier (Vendor) Update Message'

      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 8
      WHERE ID = @MessageID
      
      UPDATE SPD_Vendor
        SET Vendor_Number = x.mikData_supplier_nbr,
        Vendor_Name = x.mikData_supplier_name,
        Vendor_Type = x.mikData_vendor_type,
        --PaymentTerms = x.mikData_payment_terms_cd,
        --NAK 7/5/2011: Take this out until Michaels fixes this to work in inbound messages
        --EDIFlag = case when x.mikData_msi_po_edi_flag = 'Y' then 1 else 0 end,
        FreightTerms = x.mikData_freight_terms,
        CurrencyCode = CASE WHEN x.mikData_currency_cd = 'CAN' THEN 'CAD' ELSE x.mikData_currency_cd END,
        Date_Last_Modified = getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Supplier'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_supplier_nbr varchar(1000) 'supplier_nbr'
        ,mikData_supplier_name varchar(1000) 'supplier_name' 
        ,mikData_vendor_type varchar(1000) 'vendor_type'
        ,mikData_payment_terms_cd varchar(1000) 'payment_terms_cd'
        ,mikData_msi_po_edi_flag varchar(1000) 'msi_po_edi_flag'
        ,mikData_freight_terms varchar(1000) 'freight_terms'
        ,mikData_currency_cd varchar(1000) 'currency_cd'
      ) x
      WHERE Vendor_Number = x.mikData_supplier_nbr
     
     
      INSERT INTO SPD_Vendor
      (
        Vendor_Number, Vendor_Name, Vendor_Type, 
        --PaymentTerms, 'NAK: Update the payment terms after the insert using node where address_type=04 
        EDIFlag,
        FreightTerms, CurrencyCode, Date_Last_Modified
      )
      SELECT DISTINCT 
		x.mikData_supplier_nbr, x.mikData_supplier_name, x.mikData_vendor_type,
		--x.mikData_payment_terms_cd, 
		case when x.mikData_msi_po_edi_flag = 'Y' then 1 else 0 end,
        x.mikData_freight_terms, CASE WHEN x.mikData_currency_cd = 'CAN' THEN 'CAD' else x.mikData_currency_cd END, getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Supplier'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_supplier_nbr varchar(1000) 'supplier_nbr'
        ,mikData_supplier_name varchar(1000) 'supplier_name'
        ,mikData_vendor_type varchar(1000) 'vendor_type'
        ,mikData_payment_terms_cd varchar(1000) 'payment_terms_cd'
        ,mikData_msi_po_edi_flag varchar(1000) 'msi_po_edi_flag'
        ,mikData_freight_terms varchar(1000) 'freight_terms'
        ,mikData_currency_cd varchar(1000) 'currency_cd'
      ) x
      WHERE NOT EXISTS (SELECT * FROM SPD_Vendor WHERE Vendor_Number = x.mikData_supplier_nbr)

		--NAK 7/5/2011:  Rule defined by Michaels
      --UPDATE Vendor Payment Terms using the node where address_type = 04
      UPDATE SPD_Vendor
      SET 
        PaymentTerms = x.mikData_payment_terms_cd,
        Date_Last_Modified = getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''Supplier'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_supplier_nbr varchar(1000) 'supplier_nbr'
        ,mikData_supplier_name varchar(1000) 'supplier_name' 
        ,mikData_vendor_type varchar(1000) 'vendor_type'
        ,mikData_payment_terms_cd varchar(1000) 'payment_terms_cd'
        ,mikData_msi_po_edi_flag varchar(1000) 'msi_po_edi_flag'
        ,mikData_freight_terms varchar(1000) 'freight_terms'
        ,mikData_currency_cd varchar(1000) 'currency_cd'
        ,mikData_address_type varchar(1000) 'address_type'
      ) x
      WHERE Vendor_Number = x.mikData_supplier_nbr
		AND x.mikData_address_type = '04'

      SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_FromAddress
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

      SET @EmailSubject = 'SPEDY has received a Supplier update from RMS.'
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
      
	  IF (@SPEDYEnvVars_Test_Mode = 1) PRINT 'Sending Email ' + @EmailSubject
      -- *** Michaels Email
      SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  </p><p>This is an informational message only. No action is required.</p></font>'
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

      SET @SUCCESSFLAG = 1
    END
    
    -- ========================================================================
    -- MESSAGE TYPE: SUPPLIER EDI UPDATE MESSAGE
    -- ========================================================================
    
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'SupsEDI' )
    BEGIN
  	  EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='Processing Supplier (Vendor) EDI Update Message'

      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 8
      WHERE ID = @MessageID
      
      UPDATE SPD_Vendor
        SET Vendor_Number = x.mikData_supplier_nbr,
        EDIFlag = case when x.mikData_msi_po_edi_flag = 'Y' then 1 else 0 end,
        Date_Last_Modified = getdate()
      FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type=''SupsEDI'']')
      WITH 
      (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_supplier_nbr varchar(1000) 'supplier'
        ,mikData_msi_po_edi_flag varchar(1000) 'edi_po_ind'
      ) x
      WHERE Vendor_Number = x.mikData_supplier_nbr
      
      SET @MichaelsEmailRecipients = @SPEDYEnvVars_SPD_Email_FromAddress
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @MichaelsEmailRecipients = @SPEDYEnvVars_Test_Mode_Email_Address

      SET @EmailSubject = 'SPEDY has received a Supplier EDI update from RMS.'
      IF (@SPEDYEnvVars_Test_Mode = 1) SET @EmailSubject = '[' + @SPEDYEnvVars_Environment_Name + '] ' + @EmailSubject
      
	  IF (@SPEDYEnvVars_Test_Mode = 1) PRINT 'Sending Email ' + @EmailSubject
      -- *** Michaels Email
      SET @EmailBody = '<font face="Arial" size="2"><p>' + @EmailSubject + '  </p><p>This is an informational message only. No action is required.</p></font>'
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

      SET @SUCCESSFLAG = 1
    END
    
    
    -- ========================================================================
	-- Now Pass the Message into the Item Maint Process
    -- ========================================================================
    DECLARE @IMStatus bit
    Set @msg = 'Calling Item Maint Process to check message ID: ' + convert(varchar(20),@MessageID) + ' ( Record No. ' + convert(varchar(20),@MessageRecNo) + ' )'
	EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg
	EXEC @IMStatus = usp_SPD_ItemMaint_ProcessIncomingMessage @MessageID = @MessageID, @strXMLDoc = @strXMLDoc, @Debug=1, @LTS = @MsgTimeStamp
	IF @SUCCESSFLAG = 0
		SET @SUCCESSFLAG = @IMStatus

    -- ============================================================================================================
	-- Now that message has been processed by Item Maint, see if Update Item Master from New Item needs to be run
    -- ============================================================================================================
    IF @UpdateIMFromNI = 1
    BEGIN
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='New Item Complete: Updating Item Master with New Item SPEDY Only Data'
		EXEC usp_SPD_MQComm_UpdateItemMaster @BatchID = @UpdateBID, @LTS = @MsgTimeStamp, @debug = 1		    
    END

--***************************************************************************************************************************
-- PURCHASE ORDER MESSAGES
--***************************************************************************************************************************
	
	DECLARE @POSuccess int

	-- ========================================================================
    -- MESSAGE TYPE: 50 - Seasonal Purchase Order Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS6_MQSEND' AND @XML_HeaderSegment_Contents = 'SeasonalPO' )
    BEGIN      
  	  
		--Log Event
		Set @msg = 'Calling PO_Proccess_Purchase_Order_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 50
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Purchase_Order_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess
	
	END

	-- ========================================================================
    -- MESSAGE TYPE: 51 - Ship Point Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'ShipPoint' )
    BEGIN      
  	  
		--Log Event
		Set @msg = 'Calling PO_Proccess_Ship_Point_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 51
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Ship_Point_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess
		
	END
	
	-- ========================================================================
    -- MESSAGE TYPE: 52 - Payment Terms Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'PaymentTerms' )
    BEGIN      
  	  
		--Log Event
		Set @msg = 'Calling PO_Proccess_Payment_Terms_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 52
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Payment_Terms_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess
		
	END
	
	-- ========================================================================
    -- MESSAGE TYPE: 53 - Allocation Event Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'AllocationEvent' )
    BEGIN      

		--Log Event
		Set @msg = 'Calling PO_Proccess_Allocation_Event_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 53
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Allocation_Event_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess

	END
	
	-- ========================================================================
    -- MESSAGE TYPE: 56 - Purchase Order Confirm Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'SPEDYOrderConfirm' )
    BEGIN      

		--Log Event
		Set @msg = 'Calling PO_Proccess_Purchase_Order_Confirm_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 56
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Purchase_Order_Confirm_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess

	END

	-- ========================================================================
    -- MESSAGE TYPE: 57 - Purchase Order Error Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'SPEDYOrderError' )
    BEGIN      

		--Log Event
		Set @msg = 'Calling PO_Proccess_Purchase_Order_Error_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 57
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Purchase_Order_Error_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess

	END
	
	
	-- ========================================================================
    -- MESSAGE TYPE: 58 - Purchase Order Receipt Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'RMS12_MQSEND' AND @XML_HeaderSegment_Contents = 'OrderReceipt' )
    BEGIN      

		--Log Event
		Set @msg = 'Calling PO_Proccess_Purchase_Order_Receipt_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 58
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Purchase_Order_Receipt_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess

	END
	
	-- ========================================================================
    -- MESSAGE TYPE: 59 - Purchase Order Revision Message
    -- ========================================================================
    IF ( @XML_HeaderSegment_Source = 'OrderRevFromRMS12' AND @XML_HeaderSegment_Contents = 'OrderRevision' )
    BEGIN      

		--Log Event
		Set @msg = 'Calling PO_Proccess_Purchase_Order_Revision_Message to process message ID: ' + convert(varchar(20),@MessageID)  	  
		EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M=@msg

		--Update Message Type
		UPDATE SPD_MQComm_Message
		SET Message_Type_ID = 59
		WHERE ID = @MessageID

		--Process Message
		EXEC @POSuccess = PO_Proccess_Purchase_Order_Revision_Message @Message_ID = @MessageID, @Current_Date_Time = @MsgTimeStamp

		SET @SUCCESSFLAG = @POSuccess

	END

--***************************************************************************************************************************
-- END OF PURCHASE ORDER MESSAGES
--***************************************************************************************************************************
      
    -- ========================================================================
    -- OTHER UNUSED MESSAGES
    -- ========================================================================
    IF ( (@SUCCESSFLAG <> 1) AND ((SELECT Message_Type_ID FROM SPD_MQComm_Message WHERE ID = @MessageID) = -1) )
    BEGIN
      UPDATE SPD_MQComm_Message
      SET Message_Type_ID = 0
      WHERE ID = @MessageID

      SET @SUCCESSFLAG = 1
    END

    EXEC sp_xml_removedocument @intXMLDocHandle    

    -- ========================================================================
    -- SET STATUS TO COMPLETE
    -- ========================================================================
    IF ( @SUCCESSFLAG = 2 )
	BEGIN
		--DO NOT SET STATUS CHANGE AS WE WANT THIS TO BE PROCESSED THE NEXT TIME AROUND
		PRINT 'Message ' + CONVERT(varchar(20), @MessageID) + ' is being delayed.'
	END	
	ELSE IF ( @SUCCESSFLAG = 1 ) 
	BEGIN
	  INSERT INTO SPD_MQComm_Message_Status (Message_ID, Status_ID) VALUES (@MessageID, 3)
	  PRINT 'Message ' + CONVERT(varchar(20), @MessageID) + ' processed.'
	END
	ELSE
	BEGIN
	  INSERT INTO SPD_MQComm_Message_Status (Message_ID, Status_ID) VALUES (@MessageID, 0)
	  PRINT 'Message ' + CONVERT(varchar(20), @MessageID) + ' could not be processed.'
	END

    FETCH NEXT FROM myXMLMessages INTO @MessageID, @strXMLDoc, @MessageRecNo
  END	-- OUTER LOOP
  CLOSE myXMLMessages
  DEALLOCATE myXMLMessages

  IF @MessageCount > 0
	EXEC usp_SPD_MQ_LogMessage @D=@MsgTimeStamp, @M='P R O C E S S     E N D S'

  SET NOCOUNT OFF


GO


--*************************************************
--SPD_Report_CompletedDomesticItem 
--*************************************************
/****** Object:  StoredProcedure [dbo].[SPD_Report_CompletedDomesticItem]    Script Date: 12/18/2017 14:03:58 ******/
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
		silF.Description_Short as French_Short_Description, silF.Description_Long as French_Long_Description, 
		silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description      
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
	  ii.EachInsideInnerPack, ii.EachPieceNetWeightLbsPerOunce,
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



--*************************************************
--SPD_Report_DomesticItem 
--*************************************************
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
		silS.Description_Short as Spanish_Short_Description, silS.Description_Long as Spanish_Long_Description    
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
		simlE.Description_Short as English_Short_Description, simlE.Description_Long as English_Long_Description, simlF.Description_Short as French_Short_Description,    
		simlF.Description_Long as French_Long_Description, simlS.Description_Short as Spanish_Short_Description, simlS.Description_Long as Spanish_Long_Description          
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

--*************************************************
--SPD_Report_ImportItem 
--*************************************************
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
		ii.EachInsideMasterCaseBox, ii.EachInsideInnerPack, ii.EachPieceNetWeightLbsPerOunce, 
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


--*************************************************
--SPD_Report_SKUDetails 
--*************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		s.Item_Desc, s.Hybrid_Type, s.Hybrid_Source_DC, s.Hybrid_Lead_Time, s.Hybrid_Conversion_Date, 
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
		v.Ocean_Freight_Amount, v.Agent_Commission_Percent As Merch_Burden_Percent, v.Other_Import_Costs_Percent, s.POG_Max_Qty,
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
		


--*************************************************
--usp_SPD_BulkItemMaint_GetList 
--*************************************************
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
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentConstructionMethod0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[UL]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[LicenceAgreement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FumigationCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[KILNDriedCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ChinaComInspecNumAndCCIBStickers]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OriginalVisa]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TextileDeclarationMidCode]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuotaChargeStatement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSCA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DropBallTestCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManMedicalDeviceListing]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManFDARegistration]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 99 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CopyRightIndemnification]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FishWildLifeCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Proposition65LabelReq]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CCCR]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FormaldehydeCompliant]', @typeString, @strTempFilterOp, @strTempFilterCriteria)

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
		WHEN 50 THEN 'i.[OceanFreightAmount] ' + @strTempSortDir 
		WHEN 51 THEN 'i.[OceanFreightComputedAmount] ' + @strTempSortDir 
		WHEN 52 THEN 'i.[AgentCommissionPercent] ' + @strTempSortDir 
		WHEN 53 THEN 'i.[AgentCommissionAmount] ' + @strTempSortDir 
		WHEN 54 THEN 'i.[OtherImportCostsPercent] ' + @strTempSortDir 
		WHEN 55 THEN 'i.[OtherImportCostsAmount] ' + @strTempSortDir 
		WHEN 56 THEN 'i.[ImportBurden] ' + @strTempSortDir 
		WHEN 57 THEN 'i.[WarehouseLandedCost] ' + @strTempSortDir 
		WHEN 58 THEN 'i.[OutboundFreight] ' + @strTempSortDir 
		WHEN 59 THEN 'i.[NinePercentWhseCharge] ' + @strTempSortDir 
		WHEN 60 THEN 'i.[TotalStoreLandedCost] ' + @strTempSortDir 
		WHEN 61 THEN 'i.[ShippingPoint] ' + @strTempSortDir 
		WHEN 62 THEN 'i.[PlanogramName] ' + @strTempSortDir 
		WHEN 63 THEN 'i.[Hazardous] ' + @strTempSortDir 
		WHEN 64 THEN 'i.[HazardousFlammable] ' + @strTempSortDir 
		WHEN 65 THEN 'i.[HazardousContainerType] ' + @strTempSortDir 
		WHEN 66 THEN 'i.[HazardousContainerSize] ' + @strTempSortDir 
		WHEN 67 THEN 'i.[HazardousMSDSUOM] ' + @strTempSortDir 
		WHEN 68 THEN 'i.[HazardousManufacturerName] ' + @strTempSortDir 
		WHEN 69 THEN 'i.[HazardousManufacturerCity] ' + @strTempSortDir 
		WHEN 70 THEN 'i.[HazardousManufacturerState] ' + @strTempSortDir 
		WHEN 71 THEN 'i.[HazardousManufacturerPhone] ' + @strTempSortDir 
		WHEN 72 THEN 'i.[HazardousManufacturerCountry] ' + @strTempSortDir 
		WHEN 73 THEN 'i.[PLIFrench] ' + @strTempSortDir 
		WHEN 74 THEN 'i.[PLISpanish] ' + @strTempSortDir 
		WHEN 75 THEN 'i.[TIFrench] ' + @strTempSortDir 
		WHEN 76 THEN 'i.[TISpanish] ' + @strTempSortDir 
		WHEN 77 THEN 'i.[CustomsDescription] ' + @strTempSortDir 
		WHEN 78 THEN 'i.[EnglishShortDescription] ' + @strTempSortDir 
		WHEN 79 THEN 'i.[EnglishLongDescription] ' + @strTempSortDir 
		WHEN 80 THEN 'i.[HarmonizedCodeNumber] ' + @strTempSortDir 
		WHEN 81 THEN 'i.[CanadaHarmonizedCodeNumber] ' + @strTempSortDir 
		WHEN 82 THEN 'i.[ComponentMaterialBreakdown0] ' + @strTempSortDir 
		WHEN 83 THEN 'i.[ComponentConstructionMethod0] ' + @strTempSortDir 
		WHEN 84 THEN 'i.[TSSA] ' + @strTempSortDir 
		WHEN 85 THEN 'i.[CSA] ' + @strTempSortDir 
		WHEN 86 THEN 'i.[UL] ' + @strTempSortDir 
		WHEN 87 THEN 'i.[LicenceAgreement] ' + @strTempSortDir 
		WHEN 88 THEN 'i.[FumigationCertificate] ' + @strTempSortDir 
		WHEN 89 THEN 'i.[KILNDriedCertificate] ' + @strTempSortDir 
		WHEN 90 THEN 'i.[ChinaComInspecNumAndCCIBStickers] ' + @strTempSortDir 
		WHEN 91 THEN 'i.[OriginalVisa] ' + @strTempSortDir 
		WHEN 92 THEN 'i.[TextileDeclarationMidCode] ' + @strTempSortDir 
		WHEN 93 THEN 'i.[QuotaChargeStatement] ' + @strTempSortDir 
		WHEN 94 THEN 'i.[MSDS] ' + @strTempSortDir 
		WHEN 95 THEN 'i.[TSCA] ' + @strTempSortDir 
		WHEN 96 THEN 'i.[DropBallTestCert] ' + @strTempSortDir 
		WHEN 97 THEN 'i.[ManMedicalDeviceListing] ' + @strTempSortDir 
		WHEN 98 THEN 'i.[ManFDARegistration] ' + @strTempSortDir 
		WHEN 99 THEN 'i.[CopyRightIndemnification] ' + @strTempSortDir 
		WHEN 100 THEN 'i.[FishWildLifeCert] ' + @strTempSortDir 
		WHEN 101 THEN 'i.[Proposition65LabelReq] ' + @strTempSortDir 
		WHEN 102 THEN 'i.[CCCR] ' + @strTempSortDir 
		WHEN 103 THEN 'i.[FormaldehydeCompliant] ' + @strTempSortDir 
      
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





--*************************************************
--usp_SPD_BulkItemMaint_GetListCount 
--*************************************************
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
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentConstructionMethod0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[UL]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[LicenceAgreement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FumigationCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[KILNDriedCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ChinaComInspecNumAndCCIBStickers]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OriginalVisa]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TextileDeclarationMidCode]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuotaChargeStatement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSCA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DropBallTestCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManMedicalDeviceListing]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManFDARegistration]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 99 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CopyRightIndemnification]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FishWildLifeCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Proposition65LabelReq]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CCCR]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FormaldehydeCompliant]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
      
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





--*************************************************
--usp_SPD_ItemMaint_GetList 
--*************************************************
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
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ExemptEndDateFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DetailInvoiceCustomsDesc0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImageID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDSID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
     
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
		WHEN 54 THEN 'i.[OceanFreightAmount] ' + @strTempSortDir 
		WHEN 55 THEN 'i.[OceanFreightComputedAmount] ' + @strTempSortDir 
		WHEN 56 THEN 'i.[AgentCommissionPercent] ' + @strTempSortDir 
		WHEN 57 THEN 'i.[AgentCommissionAmount] ' + @strTempSortDir 
		WHEN 58 THEN 'i.[OtherImportCostsPercent] ' + @strTempSortDir 
		WHEN 59 THEN 'i.[OtherImportCostsAmount] ' + @strTempSortDir 
		WHEN 60 THEN 'i.[ImportBurden] ' + @strTempSortDir 
		WHEN 61 THEN 'i.[WarehouseLandedCost] ' + @strTempSortDir 
		WHEN 62 THEN 'i.[OutboundFreight] ' + @strTempSortDir 
		WHEN 63 THEN 'i.[NinePercentWhseCharge] ' + @strTempSortDir 
		WHEN 64 THEN 'i.[TotalStoreLandedCost] ' + @strTempSortDir 
		WHEN 65 THEN 'i.[ShippingPoint] ' + @strTempSortDir 
		WHEN 66 THEN 'i.[PlanogramName] ' + @strTempSortDir 
		WHEN 67 THEN 'i.[Hazardous] ' + @strTempSortDir 
		WHEN 68 THEN 'i.[HazardousFlammable] ' + @strTempSortDir 
		WHEN 69 THEN 'i.[HazardousContainerType] ' + @strTempSortDir 
		WHEN 70 THEN 'i.[HazardousContainerSize] ' + @strTempSortDir 
		WHEN 71 THEN 'i.[HazardousMSDSUOM] ' + @strTempSortDir 
		WHEN 72 THEN 'i.[HazardousManufacturerName] ' + @strTempSortDir 
		WHEN 73 THEN 'i.[HazardousManufacturerCity] ' + @strTempSortDir 
		WHEN 74 THEN 'i.[HazardousManufacturerState] ' + @strTempSortDir 
		WHEN 75 THEN 'i.[HazardousManufacturerPhone] ' + @strTempSortDir 
		WHEN 76 THEN 'i.[HazardousManufacturerCountry] ' + @strTempSortDir 
		WHEN 79 THEN 'i.[QuoteReferenceNumber] ' + @strTempSortDir 
		WHEN 79 THEN 'i.[QuoteReferenceNumber] ' + @strTempSortDir 
		WHEN 80 THEN 'i.[PLIEnglish] ' + @strTempSortDir 
		WHEN 81 THEN 'i.[PLIFrench] ' + @strTempSortDir 
		WHEN 82 THEN 'i.[PLISpanish] ' + @strTempSortDir 
		WHEN 84 THEN 'i.[TIEnglish] ' + @strTempSortDir 
		WHEN 85 THEN 'i.[TIFrench] ' + @strTempSortDir 
		WHEN 86 THEN 'i.[TISpanish] ' + @strTempSortDir 
		WHEN 87 THEN 'i.[CustomsDescription] ' + @strTempSortDir 
		WHEN 88 THEN 'i.[EnglishShortDescription] ' + @strTempSortDir 
		WHEN 89 THEN 'i.[EnglishLongDescription] ' + @strTempSortDir 
		WHEN 90 THEN 'i.[FrenchShortDescription] ' + @strTempSortDir 
		WHEN 91 THEN 'i.[FrenchLongDescription] ' + @strTempSortDir 
		WHEN 92 THEN 'i.[SpanishShortDescription] ' + @strTempSortDir 
		WHEN 93 THEN 'i.[SpanishLongDescription] ' + @strTempSortDir 
		WHEN 94 THEN 'i.[ExemptEndDateFrench] ' + @strTempSortDir 
		WHEN 95 THEN 'i.[HarmonizedCodeNumber] ' + @strTempSortDir 
		WHEN 96 THEN 'i.[CanadaHarmonizedCodeNumber] ' + @strTempSortDir 
		WHEN 97 THEN 'i.[DetailInvoiceCustomsDesc0] ' + @strTempSortDir 
		WHEN 98 THEN 'i.[ComponentMaterialBreakdown0] ' + @strTempSortDir 
		WHEN 102 THEN 'i.[ImageID] ' + @strTempSortDir 
		WHEN 103 THEN 'i.[MSDSID] ' + @strTempSortDir 
      
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




--*************************************************
--usp_SPD_ItemMaint_GetListCount 
--*************************************************
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
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuoteReferenceNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIEnglish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FrenchLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SpanishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ExemptEndDateFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DetailInvoiceCustomsDesc0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImageID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDSID]', @typeString, @strTempFilterOp, @strTempFilterCriteria)

   
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




--*************************************************
--usp_SPD_ItemMaint_ProcessIncomingMessage 
--*************************************************
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------------------------------
Author:			Littlefield, Jeff
Create date:	August 2010
Description:	Process Incoming RMS Message for Item Maintenance.  This routine evaluates the passed in message for a variety of Inserts and 
				Updates to the Item Master Tables.  In addition, It checks if the message is a Item Maintenenace Batch Confirmation message and
				updates the log table that keeps track of messages sent / confirmed.  Once all messages have been confirmed the Batch Completion 
				Process is run.
				All Messages are selected into Temp tables for ease of testing and processing

Calls Procs:	[usp_SPD_ItemMaint_CompleteOrErrorBatch]	-- To process a completed batch or log an error
				[usp_SPD_ItemMaint_ProcessCostChange]		-- To update the costs based on future cost records and send ImportBurden if nec.
				[usp_SPD_MQ_LogMessage]						-- Log Status messages to Message Log table: [SPD_MQComm_Message_Log]
Change Log:
	FJL - 09/21/2010 Add Logic to handle UCP Deletes
	FJL - 09/29/2010 Added logic to handle time stamps on Batch Confirm and Error messages
	FJL - 11/04/2010 Added logic to update the Vendor Table with Agent info on Insert and Update
	NAK - 07/01/2011 Added logic to set the Displayer_Cost when inserting data into the SPD_Item_Master_SKU table (for New Items)
	wet - 04/19/2017 Added logic to send message if master qty or dimension change results in import burden change
	MWM - 11/09/2017 Added Each (EA) type Dimensions
------------------------------------------------------------------------------------------------------------------------------------------------
*/
ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_ProcessIncomingMessage] 
	@strXMLDoc XML
	, @MessageID bigint
	, @Debug int = 1
	, @LTS datetime = null
AS
BEGIN

if @LTS is NULL
	SET @LTS = getdate()

Declare @cMessageID varchar(20)
Set @cMessageID = convert(varchar(20),@MessageID)

DECLARE @XML_HeaderSegment_Source varchar(1000)
DECLARE @XML_HeaderSegment_Contents varchar(1000)
DECLARE @XML_HeaderSegment_ThreadID varchar(1000)
DECLARE @XML_HeaderSegment_PublishTime varchar(1000)
DECLARE @XML_DataSegment_ID varchar(1000)
DECLARE @XML_DataSegment_Type varchar(1000)
DECLARE @XML_DataSegment_Action varchar(1000)
DECLARE @XML_DataSegment_LastID varchar(1000)

DECLARE @SUCCESSFLAG bit
DECLARE @MsgType int
DECLARE @SUCCESSMSG varchar(max)
Declare @MsgID varchar(100), @SKU varchar(100), @PrimaryInd varchar(10)
Declare @ErrorMsg1 varchar(1000), @ErrorMsg2 varchar(1000)
DECLARE @BatchID bigint, @CompletedMsg int , @SentMsg int, @ErrorMsg int, @tempVar varchar(1000), @TotalMsg int
declare @msgs varchar(max)
declare @temp varchar(100)
declare @DomDate datetime, @ImportDate datetime
declare @mySKU varchar(10), @myVendorNumber bigint, @Desc varchar(3000), @myAction varchar(30)	--, @MinDate datetime
Declare @VendorNo bigint, @COO varchar(50), @NewTotalCost decimal(18,6), @CountryOfOrigin varchar(10)
declare @t1 table  (ElementID int, Element varchar(max) )
declare @r0 varchar(1000), @r1 varchar(1000), @r2 varchar(1000), @r3 varchar(1000), @r4 varchar(1000), @r5 varchar(1000)
declare @msg varchar(2000)
Declare @retCode int, @dotPos int
Declare @procUserID int
Declare @ProcessTimeStamp varchar(100)
Declare @MaxProcessTimeStamp varchar(100)
DECLARE @STAGE_COMPLETED int
DECLARE @STAGE_WAITINGFORSKU int
DECLARE @STAGE_DBC int
declare @OldEachesMasterCase int = 0
declare @NewEachesMasterCase int = 0
declare @OldMasterLength decimal(18,6) = 0
declare @OldMasterWidth decimal(18,6) = 0
declare @OldMasterHeight decimal(18,6) = 0
declare @NewMasterLength decimal(18,6) = 0
declare @NewMasterWidth decimal(18,6) = 0
declare @NewMasterHeight decimal(18,6) = 0
declare @VendorType int
declare @DutyPct decimal(18,6)
declare @OceanFrt decimal(18,6)
declare @OldDim varchar(100)
declare @NewDim varchar(100)
declare @Lmsg varchar(1000)
declare @PriInd varchar(20)

SET NOCOUNT ON

DECLARE  @intXMLDocHandle int
DECLARE  @SPEDYRefString varchar(100)
DECLARE  @SPEDYBatchID bigint
SET @SPEDYRefString = NULL
SET @SPEDYBatchID = NULL
-- Prepare the XML Doc

-- Flag for if message was processed or not
SET @SUCCESSFLAG = 0
SET @retCode = 0

Set @procUserID = -3	-- Flag in Item master that this record was changed / inserted by the Message process

--Set Stages based on Workflow for the error
select @STAGE_COMPLETED = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 4
select @STAGE_WAITINGFORSKU = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 3
select @STAGE_DBC = [id] from SPD_Workflow_Stage where Workflow_id = 2 and Stage_Type_id = 6

EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc

SELECT
  @XML_HeaderSegment_Source = mikHeader_Source,
  @XML_HeaderSegment_Contents = mikHeader_Contents,
  @XML_HeaderSegment_ThreadID = mikHeader_ThreadID,
  @XML_HeaderSegment_PublishTime = mikHeader_PublishTime
FROM OPENXML (@intXMLDocHandle, '/mikMessage')
WITH
(
   mikHeader_Source varchar(1000) 'mikHeader/Source'
  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
)

--SELECT @XML_HeaderSegment_Source as XML_HeaderSegment_Source
--, @XML_HeaderSegment_Contents as XML_HeaderSegment_Contents
--, @MessageID as messageID

-- Check for Message Types that we are interested in
IF @XML_HeaderSegment_Source = 'RIB.etItemsFromRMS'
BEGIN
	IF @Debug=1  Print 'Processing etItemsFromRMS for Item Maint. MessageID: ' + convert(varchar(20),@MessageID)
	-- *************************************************************
	-- Get any SKU Info.  Should be only one SKU per message based on Michaels Documentation
	-- *************************************************************
	SELECT
	  * into #SKU
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH
	(
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (
	  SELECT top 1 *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="Sku"]')
	  WITH
	  (	 mikDataAttrs_ID varchar(1000) '@id'
		,mikDataAttrs_Type varchar(1000) '@type'
		,mikData_Action varchar(1000) '@action'
		,michaels_sku varchar(1000) 'item'
		,pack_ind varchar(1000) 'pack_ind'
		,simple_pack_ind varchar(1000) 'simple_pack_ind'
		,dept varchar(1000) 'dept'
		,class varchar(1000) 'class'
		,subclass varchar(1000) 'subclass'
		,item_status varchar(1000) 'overall_item_status'
		,item_desc varchar(1000) 'item_desc'
		,item_type_attr varchar(1000) 'item_type_attr'
		,hyb_type varchar(1000) 'hyb_type'
		,hyb_source_DC varchar(1000) 'source_wh'
		,stock_category varchar(1000) 'stock_category'
		,store_orderable_ind varchar(1000) 'store_orderable_ind'
		,inv_control varchar(1000) 'inv_control'
		,repl_ind varchar(1000) 'repl_ind'
		,store_sup_zone_group varchar(1000) 'store_sup_zone_group'
		,wh_sup_zone_group varchar(1000) 'wh_sup_zone_group'
		,pack_item_type varchar(1000) 'pack_item_type'
		,hazmat_ind varchar(1000) 'hazmat_ind'
		,flammable_ind varchar(1000) 'flammable_ind'
		,haz_container_type varchar(1000) 'container_type'
		,haz_container_size varchar(1000) 'package_size'
		,haz_msds_uom varchar(1000) 'package_uom'
		,clearance_ind varchar(1000) 'clearance_ind'
		,discountable_ind varchar(1000) 'discountable_ind'
		,sku_group	varchar(1000) 'sku_group'
		,create_datetime varchar(1000) 'create_datetime'
		,last_update_datetime varchar(1000) 'last_update_datetime'
		,last_update_id varchar(1000) 'last_update_id'
		,conversion_date varchar(1000) 'hyb_cnv_date'
	  )
	) data ON data.michaels_sku IS NOT NULL	and data.mikData_Action in ('Insert', 'Update')
	
	--NAK 11/8/2011: Adding code to get BatchID from message
	SELECT @SPEDYRefString = mikData_spedy_item_id
	FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="Sku"]')
    WITH 
    (
         mikDataAttrs_id varchar(1000) '@id'
        ,mikDataAttrs_type varchar(1000) '@type'
        ,mikDataAttrs_action varchar(1000) '@action'
        ,mikData_spedy_item_id varchar(1000) 'spedy_item_id'
    ) data
  
	IF (LEN(@SPEDYRefString) > 0)
	BEGIN
		IF (CHARINDEX('.', @SPEDYRefString) > 0)
		BEGIN
			IF (ISNUMERIC(SUBSTRING(@SPEDYRefString, 0, CHARINDEX('.', @SPEDYRefString))) = 1)
			BEGIN
				SET @SPEDYBatchID = SUBSTRING(@SPEDYRefString, 0, CHARINDEX('.', @SPEDYRefString))
			END        
		END
	END
	
	IF (select count(*) from #SKU) > 0
	BEGIN
		IF @Debug=1  Print 'Processing etItemsFromRMS for Item Maint - SKU'
		set @msg = 'Processing Item Maint - SKU...' + (Select top 1 convert(varchar(20),michaels_sku) from #SKU) + ' (Message: ' + @cMessageID + ')'
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			UPDATE SPD_Item_Master_SKU
			  Set 
			   [Item_Status] = S.item_status
			  ,[Department_Num] = S.dept
			  ,[Class_Num] = S.class
			  ,[Sub_Class_Num] = S.subclass
			  ,[Hybrid_Type] = S.hyb_type
			  ,[Hybrid_Source_DC] = S.hyb_source_DC
			  ,[Hybrid_Conversion_Date] = CAST(S.Conversion_Date as datetime)		  
			  ,[Stock_Category] = S.stock_category
			  ,[Item_Type] = CASE
						WHEN S.pack_item_type = 'P'	THEN SKU.[Item_Type]		--'D'	-- Let New Item handle this update
						WHEN S.pack_item_type = 'D'	THEN SKU.[Item_Type]		--'DP'	-- Let New Item Handle this update
						WHEN S.pack_item_type = 'S' 
							and Exists (Select Child_SKU from SPD_Item_Master_PackItems where Child_SKU = S.michaels_sku) THEN 'C'
						ELSE ' '
						END
			  ,[Allow_Store_Order] = S.store_orderable_ind
			  ,[Inventory_Control] = case S.inv_control when 'R' then 'Y' when 'B' then 'N' else NULL end
			  ,[Auto_Replenish] = S.repl_ind
			  ,[Store_Supplier_Zone_Group] = S.store_sup_zone_group
			  ,[WHS_Supplier_Zone_Group] = S.wh_sup_zone_group
			  ,[Pack_Item_Indicator] = S.pack_ind
			  ,[Item_Desc] = S.item_desc
			  ,[Item_Type_Attribute] = S.item_type_attr
			  ,[Clearance_Indicator] = S.clearance_ind
			  ,[Hazardous] = S.hazmat_ind
			  ,[Hazardous_Flammable] = S.flammable_ind
			  ,[Hazardous_Container_Type] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 8 and S.haz_container_type = RMS_Field_Value ), '')
			  ,[Hazardous_Container_Size] = S.haz_container_size
			  ,[Hazardous_MSDS_UOM] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 9 and S.haz_msds_uom = RMS_Field_Value ), '')	--S.haz_msds_uom
			  ,[Simple_Pack_Indicator] = S.simple_pack_ind
			  ,[Discountable] = S.discountable_ind
			  ,[SKU_Group] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 15 and S.sku_group = RMS_Field_Value ), '')
			  ,[Update_User_ID] = @procUserID
			  ,[Date_Last_Modified] = getdate()
			FROM SPD_Item_Master_SKU SKU
				join #SKU S on SKU.michaels_sku = S.michaels_sku

			--NAK 7/1/2011: Added the Displayer_Cost
			INSERT SPD_Item_Master_SKU (
			   [Michaels_SKU]
			  ,[Item_Status]
			  ,[Department_Num]
			  ,[Class_Num]
			  ,[Sub_Class_Num]
			  ,[Hybrid_Type]
			  ,[Hybrid_Source_DC]
			  ,[Hybrid_Conversion_Date]
			  ,[Stock_Category]
			  ,[Item_Type]
			  ,[Allow_Store_Order]
			  ,[Inventory_Control]
			  ,[Auto_Replenish]
			  ,[Store_Supplier_Zone_Group]
			  ,[WHS_Supplier_Zone_Group]
			  ,[Pack_Item_Indicator]
			  ,[Displayer_Cost]
			  ,[Item_Desc]
			  ,[Item_Type_Attribute]
			  ,[Clearance_Indicator]
			  ,[Hazardous]
			  ,[Hazardous_Flammable]
			  ,[Hazardous_Container_Type]
			  ,[Hazardous_Container_Size]
			  ,[Hazardous_MSDS_UOM]
			  ,[Simple_Pack_Indicator]
			  ,[Discountable]
			  ,[SKU_Group]
			  ,[Created_User_ID]
			  ,[Date_Created] )
			SELECT
			   [Michaels_SKU] = S.michaels_sku
			  ,[Item_Status] = S.item_status
			  ,[Department_Num] = S.dept
			  ,[Class_Num] = S.class
			  ,[Sub_Class_Num] = S.subclass
			  ,[Hybrid_Type] = S.hyb_type
			  ,[Hybrid_Source_DC] = S.hyb_source_DC
			  ,[Hybrid_Conversion_Date] = CAST(S.Conversion_Date as datetime)
			  ,[Stock_Category] = S.stock_category
			  ,[Item_Type] = CASE
						WHEN S.pack_item_type = 'P'	THEN 'D'
						WHEN S.pack_item_type = 'D'	THEN 'DP'
						WHEN S.pack_item_type = 'S' 
							and Exists (Select Child_SKU from SPD_Item_Master_PackItems where Child_SKU = S.michaels_sku) THEN 'C'
						ELSE ' '
						END
			  ,[Allow_Store_Order] = S.store_orderable_ind
			  ,[Inventory_Control] = case S.inv_control when 'R' then 'Y' when 'B' then 'N' else NULL end
			  ,[Auto_Replenish] = S.repl_ind
			  ,[Store_Supplier_Zone_Group] = S.store_sup_zone_group
			  ,[WHS_Supplier_Zone_Group] = S.wh_sup_zone_group
			  ,[Pack_Item_Indicator] = S.pack_ind
			  ,[Displayer_Cost] = CASE WHEN IsNull(D.Pack_Item_Indicator, '') = 'C' THEN IsNull(ii.Displayer_Cost,0) ELSE IsNull(COALESCE(ii.Displayer_Cost, D.Add_Unit_Cost),0) END	--Domestic Child items cannot have a Displayer Cost
			  ,[Item_Desc] = S.item_desc
			  ,[Item_Type_Attribute] = S.item_type_attr
			  ,[Clearance_Indicator] = S.clearance_ind
			  ,[Hazardous] = S.hazmat_ind
			  ,[Hazardous_Flammable] = S.flammable_ind
			  ,[Hazardous_Container_Type] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 8 and S.haz_container_type = RMS_Field_Value ), '')
			  ,[Hazardous_Container_Size] = S.haz_container_size
			  ,[Hazardous_MSDS_UOM] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 9 and S.haz_msds_uom = RMS_Field_Value ), '')	--S.haz_msds_uom
			  ,[Simple_Pack_Indicator] = S.simple_pack_ind
			  ,[Discountable] = S.discountable_ind
			  ,[SKU_Group] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 15 and S.sku_group = RMS_Field_Value ), '')
			  ,[Created_User_ID] = @procUserID
			  ,[Date_Created] = getdate()
			FROM #SKU S
				Left Join SPD_Item_Master_SKU SKU on S.Michaels_SKU = SKU.Michaels_SKU
				LEFT JOIN SPD_Import_Items as II on II.MichaelsSKU = S.Michaels_SKU AND II.Batch_ID = @SPEDYBatchID
				Left Join (Select Michaels_SKU, Pack_Item_Indicator, Add_Unit_Cost From SPD_Items as i Inner Join SPD_Item_Headers as h on i.Item_Header_ID = h.ID AND h.Batch_ID = @SPEDYBatchID) as D on D.Michaels_SKU = S.Michaels_SKU
			WHERE SKU.Michaels_SKU is NULL


			SET @MsgType = 20
		END TRY

		BEGIN CATCH
			set @msg = 'Processing Item Maint - SKU... Error Occurred in Insert/Update' + ' (Message: ' + @cMessageID + ') ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
		
			-- Cut 1 here		

	END	-- Records exist
	Drop table #SKU
	
	-- *************************************************************
	-- Look for ZKUZonePrice Records for Retails 
	-- *************************************************************
	-- Note: these are new Item messages only.  Updates on Retails (both clearance and regular) come in on RMS6 messages too. See further down for those.
	SELECT
		SKU.Michaels_SKU
	  , zone_id
	  , standard_retail
	   into #Retails
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH
	(
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (
	 SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="Sku"]')
	  WITH (
		Michaels_SKU varchar(1000) 'item' 
		,mikSKU_Action varchar(1000) '@action'
		)
	  ) SKU on SKU.Michaels_SKU IS NOT NULL	and SKU.mikSKU_Action in ('Insert', 'Update')
	INNER JOIN (
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="SkuZonePrice"]')
	  WITH (
		mikData_item varchar(1000) 'item'
		,mikRetail_Action varchar(1000) '@action'
		,zone_id varchar(1000) 'zone_id'
		,standard_retail varchar(1000) 'standard_retail'
		)
	 ) Retail ON Retail.mikData_item = SKU.Michaels_SKU	and Retail.mikRetail_Action in ('Insert', 'Update')
	
	/*	Below is a Cross reference on Retail Names and Zones
		Base 1 Retail	 (Zone 1): 
		Base 2 Retail	 (Zone 2):
		Test Retail		 (Zone 3):  
		Alaska Retail	 (Zone 4):
		Canada Retail	 (Zone 5):
		High 2 Retail	 (Zone 6):
		High 3 Retail	 (Zone 7):
		Small Mkt Retail (Zone 8):
		High 1 Retail	 (Zone 9):
		Base 3 Retail	 (Zone 10):
		Low 1 Retail	 (Zone 11): 
		Low 2 Retail	 (Zone 12): 
		Manhattan Retail (Zone 13): 	
	*/

	IF (select count(*) from #Retails) > 0
	BEGIN
		IF @Debug=1  Print 'Processing etItemsFromRMS for Item Maint - Retails'
		set @msg = 'Processing Item Maint - Retails...' + ' (Message: ' + @cMessageID + ')'
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			IF EXISTS ( select Michaels_sku from SPD_Item_Master_SKU where Michaels_sku = (Select top 1 michaels_sku from #Retails) )
			BEGIN
				UPDATE SPD_Item_Master_SKU
				  Set 
				   [Base1_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 1),[Base1_Retail])
				  ,[Base2_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 2),[Base2_Retail])
				  ,[Base3_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 10),[Base3_Retail])
				  ,[Test_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 3),[Test_Retail])
				  ,[Alaska_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 4),[Alaska_Retail])
				  ,[Canada_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 5),[Canada_Retail])
				  ,[High1_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 9),[High1_Retail])
				  ,[High2_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 6),[High2_Retail])
				  ,[High3_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 7),[High3_Retail])
				  ,[Small_Market_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 8),[Small_Market_Retail])
				  ,[Low1_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 11),[Low1_Retail])
				  ,[Low2_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 12),[Low2_Retail])
				  ,[Manhattan_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 13),[Manhattan_Retail])
				  ,[Quebec_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 14),[Quebec_Retail])
				  ,[PuertoRico_Retail] = coalesce((Select standard_retail from #Retails where zone_id = 15),[PuertoRico_Retail])
				  ,[Update_User_ID] = @procUserID
				  ,[Date_Last_Modified] = getdate()
				  
				WHERE Michaels_SKU = (select top 1 Michaels_SKU from #Retails)
			END		-- No else because the SKU should have been created from a SKU record
			SET @MsgType = 21
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Retails... Error Occurred on Update' + ' (Message: ' + @cMessageID + ') ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop table #Retails
	
	-- ***************************************************************************************************************************************
	-- Now look for SkuSupplier -- NOTE: Cost Change tests are now done with a stored proc to resend Import Burden message if necessary
	-- ***************************************************************************************************************************************
	--
	-- NOTE: IF a cost change comes in then we need to find the future cost record and subtract the displayer cost if found
	SELECT
		Michaels_SKU
	  , mikData_Action 
	  , Vendor_Number
	  , VPN
	  , Primary_Vendor_Ind
	  , Country_of_Origin
	  , Primary_Country_Ind
	  , Unit_Cost
	  , Eaches_Master_Case
	  , Eaches_Inner_Pack
	   into #Vendor
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (
	 SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="SkuSupplier"]')
	  WITH (
		Michaels_SKU varchar(1000) 'item'
	  , mikData_Action varchar(1000) '@action'
	  , Vendor_Number varchar(1000) 'supplier'
	  , VPN varchar(1000) 'vpn'
	  , Primary_Vendor_Ind varchar(1000) 'primary_supp_ind'
	  , Country_of_Origin varchar(1000) 'origin_country_id'
	  , Primary_Country_Ind varchar(1000) 'primary_country_ind'
	  , Unit_Cost varchar(1000) 'unit_cost'
	  , Eaches_Master_Case varchar(1000) 'supp_pack_size'
	  , Eaches_Inner_Pack varchar(1000) 'inner_pack_size'
		 )
	  ) Vendor on Vendor.Michaels_SKU IS NOT NULL and Vendor.Vendor_Number is NOT NULL and Vendor.mikData_Action in ('Insert', 'Update')
	
	IF (select count(*) from #Vendor) > 0
	BEGIN
		IF @Debug=1  Print 'Processing etItemsFromRMS for Item Maint - Supplier'
		set @msg = 'Processing Item Maint - Supplier...' + ' (Message: ' + @cMessageID + ')'
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
		-- Multiple Vendors can be sent in. Do Update / Insert combo
		
			IF @Debug=1  Print '...Update'
			UPDATE SPD_Item_Master_Vendor
				Set       
				[Primary_Indicator] = CASE WHEN Vm.Primary_Vendor_Ind = 'Y' THEN 1 ELSE 0 END
				, [Vendor_Style_Num] = Vm.VPN
				, [Vendor_Or_Agent] = CASE	WHEN NullIf(A.Agent,'') is NULL	THEN 'V'
										ELSE 'A' END
				, [Agent_Type] = NullIf(A.Agent,'')
				, [Other_Import_Costs_Percent] = CASE	WHEN VL.[Vendor_Number] is not NULL then 0.02	-- Default value for Other Import Costs Percent
													ELSE NULL END
				, [Update_User_ID] = @procUserID
				, Date_Last_Modified = getdate()
			FROM SPD_Item_Master_Vendor V
				Join #Vendor Vm								ON V.Vendor_Number = Vm.Vendor_Number and V.Michaels_sku = Vm.Michaels_sku 
				Left join SPD_Item_Master_Vendor_Agent A	ON V.Vendor_Number = A.Vendor_Number
				Left Join SPD_Vendor VL						ON V.Vendor_number = VL.Vendor_Number and VL.Vendor_type = 300	-- An import Vendor
		
			IF @Debug=1  Print '...Insert'
			INSERT SPD_Item_Master_Vendor (
			  [Michaels_SKU]
			  , [Vendor_Number]
			  , [Primary_Indicator]
			  , [Vendor_Style_Num]
			  , [Vendor_Or_Agent]
			  , [Agent_Type]
			  , [Other_Import_Costs_Percent]
			  , [SKU_ID]
			  , [Created_User_ID]
			  , [Date_Created]			  				
			)
			SELECT 
				Vm.Michaels_SKU
				, Vm.Vendor_Number
				, CASE	WHEN Vm.Primary_Vendor_Ind = 'Y' THEN 1 ELSE 0 END
				, Vm.VPN
				, CASE	WHEN NullIf(A.Agent,'') is NULL	THEN 'V'
						ELSE 'A' END
				, NullIf(A.Agent,'')
				, CASE	WHEN VL.[Vendor_Number] is not NULL then 0.02	-- Default value for Other Import Costs Percent
						ELSE NULL	END
				, ( Select ID From SPD_Item_Master_SKU Where Michaels_SKU = Vm.Michaels_SKU )
				, @procUserID
				, getdate()
			FROM #Vendor Vm
				Left Join SPD_Item_Master_Vendor V			ON Vm.Michaels_SKU = V.Michaels_SKU
																and Vm.Vendor_Number = V.Vendor_Number
				Left Join SPD_Item_Master_Vendor_Agent A	ON Vm.Vendor_Number = A.Vendor_Number
				Left Join SPD_Vendor VL						ON Vm.Vendor_number = VL.Vendor_Number and VL.Vendor_type = 300	-- An import Vendor
			WHERE V.Vendor_Number is NULL
			
			--NAK 8/24/2011
			--TODO: Update Image_ID field?  Should we also update other fields on this PO?  Need to figure out what exactly is updating, and from where... (New Item?  Other maintenance item?)
			
			-- Now Update / Insert the country table portion of the data
			
			-- Keep old and new eaches_master_case values for later compare
			select @NewEachesMasterCase = IsNull(eaches_master_case, 0)
			from #vendor

			select @OldEachesMasterCase = IsNull(C.eaches_master_case, 0)
			      ,@SKU = C.Michaels_SKU
				  ,@VendorNo = C.Vendor_Number
			FROM SPD_Item_Master_Vendor_Countries C 
				join #Vendor Vm ON C.Vendor_Number = Vm.Vendor_Number 
						and C.Michaels_sku = Vm.Michaels_sku 
						and C.Country_Of_Origin = Vm.Country_of_Origin

			-- Update specific country info
			IF @Debug=1  Print '...Country Table Update'
			UPDATE SPD_Item_Master_Vendor_Countries
				Set
				Primary_Indicator = CASE 
					WHEN Vm.Primary_Country_Ind = 'Y' THEN 1 
					WHEN Vm.Primary_Country_Ind = 'N' THEN 0
					ELSE C.Primary_Indicator END
				,Eaches_Master_Case = cast(round(Vm.Eaches_Master_Case,0,1) as int)
				,Eaches_Inner_Pack =  cast(round(Vm.Eaches_Inner_Pack,0,1) as int)
				,[Update_User_ID] = @procUserID
				,[Date_Last_Modified] = getdate()
			FROM SPD_Item_Master_Vendor_Countries C 
				join #Vendor Vm ON C.Vendor_Number = Vm.Vendor_Number 
						and C.Michaels_sku = Vm.Michaels_sku 
						and C.Country_Of_Origin = Vm.Country_of_Origin

			-- Insert any records not found
			IF @Debug=1  Print '...Country Table Insert'
			INSERT SPD_Item_Master_Vendor_Countries (
				[Michaels_SKU]
				,[Vendor_Number]
				,[Country_Of_Origin]
				,[Primary_Indicator]
				,[Eaches_Master_Case]
				,[Eaches_Inner_Pack]
				,[Created_User_ID]
				,[Date_Created] 
				)
			SELECT
				Vm.Michaels_SKU
				, Vm.Vendor_Number
				, Vm.Country_of_Origin
				, CASE WHEN Vm.Primary_Country_Ind = 'Y' THEN 1 ELSE 0 END
				, cast(round(Vm.Eaches_Master_Case,0,1) as int)
				, cast(round(Vm.Eaches_Inner_Pack,0,1) as int)
				, @procUserID
				, getdate()
			FROM #Vendor Vm
				Left Join SPD_Item_Master_Vendor_Countries C On Vm.[Michaels_SKU] = C.[Michaels_SKU]
					and Vm.Vendor_Number = C.Vendor_Number
					and Vm.Country_of_Origin = C.Country_of_Origin
			WHERE C.Country_of_Origin is NULL

			--Use a cursor to set other countries as non-primary
			BEGIN TRY
				DECLARE NonPrimaryCountry CURSOR FOR
					SELECT DISTINCT 
						Michaels_SKU,
						Vendor_Number,
						Country_Of_Origin,
						Primary_Country_Ind
					From #Vendor
					
				OPEN NonPrimaryCountry 
				FETCH NEXT FROM NonPrimaryCountry INTO @SKU, @VendorNo, @CountryOfOrigin, @PrimaryInd
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF (@PrimaryInd = 'Y')
					BEGIN
						UPDATE SPD_Item_Master_Vendor_Countries
						Set Primary_Indicator = 0
						WHERE Michaels_SKU = @SKU AND Vendor_Number = @VendorNo AND Country_Of_Origin <> @CountryOfOrigin
					END

					FETCH NEXT FROM NonPrimaryCountry INTO @SKU, @VendorNo, @CountryOfOrigin, @PrimaryInd
				END
				CLOSE NonPrimaryCountry
				DEALLOCATE NonPrimaryCountry
			END TRY
			BEGIN CATCH
				set @msg = 'Processing Item Maint - Supplier... Error Occurred in ProcessCostChange - SKU:'  + coalesce(@SKU,'???') 
					+ ' Vendor: ' + coalesce(convert(varchar(20),@VendorNo),'???')
					+ ' ' + ERROR_MESSAGE()
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
				EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			END CATCH


			BEGIN TRY
			-- Use a cursor to process each record received for Cost changes
				Declare ProcCostChange Cursor FOR
					SELECT Distinct		-- ignore different countries
						Michaels_SKU
					  , Vendor_Number
					  , Unit_Cost
			--		  , Country_of_Origin
					FROM #Vendor

				OPEN ProcCostChange
				FETCH NEXT FROM ProcCostChange INTO @SKU, @VendorNo, @NewTotalCost --, @CountryOfOrigin
				WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC usp_SPD_ItemMaint_ProcessCostChange 
						@SKU = @SKU
						, @VendorNo = @VendorNo
						, @NewTotalCost = @NewTotalCost
						, @MessageID = @MessageID
						, @LTS = @LTS
						--, @CountryOfOrigin = @CountryOfOrigin
					FETCH NEXT FROM ProcCostChange INTO @SKU, @VendorNo, @NewTotalCost
				END	
				CLOSE ProcCostChange
				DEALLOCATE ProcCostChange
			END TRY
			BEGIN CATCH
				set @msg = 'Processing Item Maint - Supplier... Error Occurred in ProcessCostChange - SKU:'  + coalesce(@SKU,'???') 
					+ ' Vendor: ' + coalesce(convert(varchar(20),@VendorNo),'???')
					+ ' ' + ERROR_MESSAGE()
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
				EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			END CATCH
			
			SET @MsgType = 22
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Supplier... Error Occurred in Update/Insert'  + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
		-- CUT 2 goes here if nec
	END -- Vendor Info
	Drop table #Vendor

	-- *************************************************************
	-- Now look for SkuSupplier -- DELETE
	-- *************************************************************
	SELECT
		Michaels_SKU
	  , Vendor_Number
	  , Country_of_Origin
	   into #VendorDel
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (
	 SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="SkuSupplier"]')
	  WITH (
		Michaels_SKU varchar(1000) 'item'
		  , mikData_Action varchar(1000) '@action'
		  , Vendor_Number varchar(1000) 'supplier'
		  , Country_of_Origin varchar(1000) 'origin_country_id'
  	    )
	  ) Vendor on Vendor.Michaels_SKU IS NOT NULL and Vendor.Vendor_Number is NOT NULL and Vendor.mikData_Action = 'Delete' and Vendor.Country_of_Origin = 'none'
	
	IF (select count(*) from #VendorDel) > 0
	BEGIN
		set @msg = 'Processing Item Maint - Supplier -- DELETE...' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
		
			Begin Tran
		-- Delete all Costs, Countries, Vendor UPCs, and Vendor
			DELETE FC
			FROM SPD_Item_Master_Vendor_Country_Cost FC
				Join #VendorDel mVD ON FC.Michaels_SKU = mVD.Michaels_SKU
									and FC.Vendor_Number = mVD.Vendor_Number
			DELETE COUNTRY
			FROM SPD_Item_Master_Vendor_Countries COUNTRY
				Join #VendorDel mVD ON COUNTRY.Michaels_SKU = mVD.Michaels_SKU
									and COUNTRY.Vendor_Number = mVD.Vendor_Number
			DELETE UPC
			FROM SPD_Item_Master_Vendor_UPCs UPC
				Join #VendorDel mVD ON UPC.Michaels_SKU = mVD.Michaels_SKU
									and UPC.Vendor_Number = mVD.Vendor_Number
			DELETE VENDOR
			FROM SPD_Item_Master_Vendor VENDOR
				Join #VendorDel mVD ON VENDOR.Michaels_SKU = mVD.Michaels_SKU
									and VENDOR.Vendor_Number = mVD.Vendor_Number
			SET @MsgType = 22
			Commit Tran
		END TRY
		BEGIN CATCH
			Rollback Tran
			set @msg = 'Processing Item Maint - Supplier -- DELETE... Error occurred on Delete' + ' (Message: ' + @cMessageID + ')' + ' ' +  ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
		
	END -- Vendor Info
	Drop table #VendorDel

	-- *************************************************************
	-- Process Item Dimension Info - Note that Dimension info is not sent when a New Item Batch goes to completion.
	-- *************************************************************

	SELECT
		DIM.Michaels_SKU
	  , DIM.Vendor_Number
	  , DIM.Country_of_Origin
	  , DIM.DimType
	  , DIM.DimLength
	  , DIM.DimWidth
	  , DIM.DimHeight
	  , DIM.DimWeight
	   into #DIM
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="ItemDimension"]')
		WITH (
		  mikData_Action varchar(1000) '@action'
		, Michaels_SKU varchar(1000) 'item'
		, Vendor_Number varchar(1000) 'supplier'
		, Country_of_Origin varchar(1000) 'origin_country_id'
		, DimType varchar(1000) 'dim_object'
		, DimLength varchar(1000) 'length'
		, DimWidth varchar(1000) 'width'
		, DimHeight varchar(1000) 'height'
		, DimWeight varchar(1000) 'weight'
		)
	  ) DIM ON 	DIM.Michaels_SKU is not NULL and DIM.Vendor_Number is not NULL and DIM.Country_of_Origin is not NULL and DIM.mikData_Action in ('Insert', 'Update')
	
	Declare @EachCount int, @InnerCount int, @MasterCount int
	Select @EachCount = COUNT(*) from #DIM Where DimType = 'EA'
	Select @InnerCount = count(*) FROM #DIM Where DimType = 'IN'
	Select @MasterCount = count(*) FROM #DIM Where DimType = 'CA'

	IF @EachCount > 0
	BEGIN
		set @msg = 'Processing etItemsFromRMS for Item Maint - Each Dim ' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
			UPDATE SPD_Item_Master_Vendor_Countries
				Set
				[Each_Case_Height] = isNull(NullIF(D.DimHeight,''),0)
				, [Each_Case_Width] = isNull(NullIF(D.DimWidth,''),0)
				, [Each_Case_Length] = isnull(NullIF(D.DimLength,''),0)
				, [Each_Case_Weight] = isnull(NullIF(D.DimWeight,''),0)
				, [Each_LWH_UOM] = 'IN'
				, [Each_Weight_UOM] = 'LB'
				, [Update_User_ID] = @procUserID
				, [Date_Last_Modified] = getdate()
			FROM SPD_Item_Master_Vendor_Countries C
				Join #DIM D	ON C.Michaels_sku = D.Michaels_sku
					and C.Vendor_Number = D.Vendor_Number
					and C.Country_Of_Origin = D.Country_of_Origin
			WHERE D.DimType = 'EA'
			
			INSERT SPD_Item_Master_Vendor_Countries (
				[Michaels_SKU]
				, [Vendor_Number]
				, [Country_Of_Origin]
				, [Each_Case_Height]
				, [Each_Case_Width]
				, [Each_Case_Length]
				, [Each_Case_Weight]
				, [Each_LWH_UOM]
				, [Each_Weight_UOM]
				, [Created_User_ID]
				, [Date_Created]			  				
			)
			SELECT
				D.Michaels_SKU
				, D.Vendor_Number
				, D.Country_of_Origin
				, isnull(NullIF(D.DimHeight,''),0)
				, isnull(NullIF(D.DimWidth,''),0)
				, isnull(NullIF(D.DimLength,''),0)
				, isnull(NullIF(D.DimWeight,''),0)
				, 'IN'
				, 'LB'
				, @procUserID
				, getdate()
			FROM #DIM D
				Left Join SPD_Item_Master_Vendor_Countries C On D.[Michaels_SKU] = C.[Michaels_SKU]
					and D.Vendor_Number = C.Vendor_Number
					and D.Country_of_Origin = C.Country_of_Origin
			WHERE D.DimType = 'EA'
				and C.Country_of_Origin is NULL
		
			SET @MsgType = 23
		END TRY
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Each Dim... Error Occurred on Insert / Update' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	
	IF @InnerCount > 0
	BEGIN
		set @msg = 'Processing etItemsFromRMS for Item Maint - Inner Dim ' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
			UPDATE SPD_Item_Master_Vendor_Countries
				Set
				[Inner_Case_Height] = isNull(NullIF(D.DimHeight,''),0)
				, [Inner_Case_Width] = isNull(NullIF(D.DimWidth,''),0)
				, [Inner_Case_Length] = isnull(NullIF(D.DimLength,''),0)
				, [Inner_Case_Weight] = isnull(NullIF(D.DimWeight,''),0)
				, [Inner_LWH_UOM] = 'IN'
				, [Inner_Weight_UOM] = 'LB'
				, [Update_User_ID] = @procUserID
				, [Date_Last_Modified] = getdate()
			FROM SPD_Item_Master_Vendor_Countries C
				Join #DIM D	ON C.Michaels_sku = D.Michaels_sku
					and C.Vendor_Number = D.Vendor_Number
					and C.Country_Of_Origin = D.Country_of_Origin
			WHERE D.DimType = 'IN'
			
			INSERT SPD_Item_Master_Vendor_Countries (
				[Michaels_SKU]
				, [Vendor_Number]
				, [Country_Of_Origin]
				, [Inner_Case_Height]
				, [Inner_Case_Width]
				, [Inner_Case_Length]
				, [Inner_Case_Weight]
				, [Inner_LWH_UOM]
				, [Inner_Weight_UOM]
				, [Created_User_ID]
				, [Date_Created]			  				
			)
			SELECT
				D.Michaels_SKU
				, D.Vendor_Number
				, D.Country_of_Origin
				, isnull(NullIF(D.DimHeight,''),0)
				, isnull(NullIF(D.DimWidth,''),0)
				, isnull(NullIF(D.DimLength,''),0)
				, isnull(NullIF(D.DimWeight,''),0)
				, 'IN'
				, 'LB'
				, @procUserID
				, getdate()
			FROM #DIM D
				Left Join SPD_Item_Master_Vendor_Countries C On D.[Michaels_SKU] = C.[Michaels_SKU]
					and D.Vendor_Number = C.Vendor_Number
					and D.Country_of_Origin = C.Country_of_Origin
			WHERE D.DimType = 'IN'
				and C.Country_of_Origin is NULL
		
			SET @MsgType = 23
		END TRY
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Inner Dim... Error Occurred on Insert / Update' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END

	IF @MasterCount > 0
	BEGIN
	-- save old and new values for later compare
	select @NewMasterLength =  isnull(NullIF(D.DimLength,''),0)
	      ,@NewMasterWidth = isnull(NullIF(D.DimWidth,''),0)
		  ,@NewMasterHeight = isnull(NullIF(D.DimHeight,''),0)
	from #DIM D
	where  D.Dimtype = 'CA'
	
	select @OldMasterLength = NULLIF(Master_Case_Length, 0)
	      ,@OldMasterWidth = NULLIF(Master_Case_Width, 0)
		  ,@OldMasterHeight = NULLIF(Master_Case_Height, 0)
		  ,@SKU = C.Michaels_SKU
		  ,@VendorNo = C.Vendor_Number
	FROM SPD_Item_Master_Vendor_Countries C
				Join #DIM D	ON C.Michaels_sku = D.Michaels_sku
					and C.Vendor_Number = D.Vendor_Number
					and C.Country_Of_Origin = D.Country_of_Origin
	WHERE D.DimType = 'CA'


		set @msg = 'Processing etItemsFromRMS for Item Maint - Master Dim' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
			UPDATE SPD_Item_Master_Vendor_Countries
				Set
				[Master_Case_Height] = isnull(NullIF(D.DimHeight,''),0)
				, [Master_Case_Width] = isnull(NullIF(D.DimWidth,''),0)
				, [Master_Case_Length] = isnull(NullIF(D.DimLength,''),0)
				, [Master_Case_Weight] = isnull(NullIF(D.DimWeight,''),0)
				, [Master_LWH_UOM] = 'IN'
				, [Master_Weight_UOM] = 'LB'
				, [Update_User_ID] = @procUserID
				, [Date_Last_Modified] = getdate()
			FROM SPD_Item_Master_Vendor_Countries C
				Join #DIM D	ON C.Michaels_sku = D.Michaels_sku
					and C.Vendor_Number = D.Vendor_Number
					and C.Country_Of_Origin = D.Country_of_Origin
			WHERE D.DimType = 'CA'
			
			INSERT SPD_Item_Master_Vendor_Countries (
				[Michaels_SKU]
				, [Vendor_Number]
				, [Country_Of_Origin]
				, [Master_Case_Height]
				, [Master_Case_Width]
				, [Master_Case_Length]
				, [Master_Case_Weight]
				, [Master_LWH_UOM]
				, [Master_Weight_UOM]
				, [Created_User_ID]
				, [Date_Created]			  				
			)
			SELECT
				D.Michaels_SKU
				, D.Vendor_Number
				, D.Country_of_Origin
				, isnull(NullIF(D.DimHeight,''),0)
				, isnull(NullIF(D.DimWidth,''),0)
				, isnull(NullIF(D.DimLength,''),0)
				, isnull(NullIF(D.DimWeight,''),0)
				, 'IN'
				, 'LB'
				, @procUserID
				, getdate()
			FROM #DIM D
				Left Join SPD_Item_Master_Vendor_Countries C On D.[Michaels_SKU] = C.[Michaels_SKU]
					and D.Vendor_Number = C.Vendor_Number
					and D.Country_of_Origin = C.Country_of_Origin
			WHERE D.DimType = 'CA'
				and C.Country_of_Origin is NULL

			SET @MsgType = 23
		END TRY
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Master Dim... Error On Update / Delete' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		END CATCH
		
	END
	Drop Table #DIM  
	
/*
	--- *** Per Ken H.  Do not load import burden.  Let the trigger calc it ***
	
	-- *************************************************************
	-- Get Import Burden
	-- *************************************************************
	SELECT
		IB.Michaels_SKU
	  , IB.Vendor_Number
	  , IB.Zone_ID
	  , IB.Comp_ID
	  , IB.Import_Burden
	   into #IB
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="SkuZoneComp"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,Michaels_SKU varchar(1000) 'item'
		,vendor_number varchar(1000) 'supplier'
		,Zone_ID varchar(1000) 'zone_id'
		,Comp_ID varchar(1000) 'comp_id'
		,Import_Burden varchar(1000) 'comp_rate'
		)
	  ) IB ON IB.Michaels_SKU is not NULL and IB.vendor_number is not NULL and IB.mikData_Action in ('Insert', 'Update')
	WHERE IB.Zone_ID = '1' and IB.Comp_ID = '03' -- Per Lopa Ganguli
	  	  
	IF (Select count(*) from #IB) > 0
	BEGIN
		IF @Debug=1  Print 'Processing etItemsFromRMS for Item Maint - Import Burden'
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Processing Item Maint - Import Burden...'

		BEGIN TRY
		UPDATE SPD_Item_Master_Vendor_Countries 
			Set Import_Burden = convert(decimal,IB.Import_Burden)
				, Date_Last_Modified = getdate()
				, Update_User_ID = @procUserID
		FROM SPD_Item_Master_Vendor_Countries C
			Join #IB IB on C.Michaels_SKU = IB.Michaels_SKU
				and C.Vendor_Number = IB.Vendor_Number

		SET @MsgType = 11
		END TRY
		BEGIN CATCH
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Processing Item Maint - Import Burden... Error on Update'
		END CATCH
	END
	Drop Table #IB
*/
	-- *************************************************************
	-- Process UPC / Vendor info 0 to many UPC records
	-- *************************************************************
	-- First Get all Vendor / UPC records and do the Inserts
	SELECT Distinct
		UPC.Michaels_SKU
	  , UPCVendor.Vendor_Number
	  , UPC.UPC
	  , UPC.UPC_Type
	  , UPC.Primary_Ind
	   into #UPC
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH
	(
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UPC"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,UPC varchar(1000) 'upc'
		,Michaels_SKU varchar(1000) 'item'
		,Primary_Ind varchar(1000) 'primary_ref_item_ind'
		,UPC_Type varchar(1000) 'item_number_type'
		)
	  ) UPC ON 	UPC.Michaels_SKU is not NULL and UPC.mikData_Action in ('Insert', 'Update')
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UPCSupplier"]')
		WITH
		(
		mikData_Action varchar(1000) '@action'
		,UPC varchar(1000) 'upc'
		,Vendor_Number varchar(1000) 'supplier'
		,UPC_Country_Of_Origin varchar(1000) 'origin_country_id'
		,Michaels_SKU varchar(1000) 'item'
		)
	  ) UPCVendor ON UPCVendor.Michaels_SKU = UPC.Michaels_SKU 
			and UPCVendor.UPC = UPC.UPC
			and UPCVendor.mikData_Action in ('Insert', 'Update')
	
	IF (select count(*) from #UPC) > 0
	BEGIN	-- Can be more than one UPC record so Do Combo Update / Insert
		set @msg = 'Processing etItemsFromRMS for Item Maint - UPC / Vendor' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			UPDATE #UPC		-- Make sure all the UPCs are 14 char
				Set UPC = dbo.udf_PadUPC(UPC,14)
			
			-- Commentted out. See below for the Update process
			--UPDATE SPD_Item_Master_Vendor_UPCs
			--	Set       
			--	[Primary_Indicator] = CASE	WHEN Um.Primary_Ind = 'Y' THEN 1 
			--								WHEN Um.Primary_Ind = 'N' THEN 0 
			--								ELSE UPC.[Primary_Indicator] END
			--	,[Update_User_ID] = @procUserID
			--	,[Date_Last_Modified] = getdate()
			--	,Is_Active = 1
			--FROM SPD_Item_Master_Vendor_UPCs UPC
			--	join #UPC Um ON  UPC.[Michaels_SKU] = Um.Michaels_SKU
			--		and UPC.[Vendor_Number] = Um.Vendor_Number
			--		and UPC.[UPC] = Um.UPC

			INSERT SPD_Item_Master_Vendor_UPCs (
				[Michaels_SKU]
			  ,[Vendor_Number]
			  ,[UPC]
			  ,[Primary_Indicator]
			  ,[Created_User_ID]
			  ,[Date_Created]
			  ,Is_Active
			   )
			SELECT 
				Um.Michaels_SKU
			  , Um.Vendor_Number
			  , dbo.udf_PadUPC(Um.UPC,14)
			  , CASE	WHEN Um.Primary_Ind = 'Y' THEN 1 
						WHEN Um.Primary_Ind = 'N' THEN 0 
						ELSE UPC.[Primary_Indicator] END
			  , @procUserID
			  , getdate()
			  , 1
			FROM #UPC Um
				left join SPD_Item_Master_Vendor_UPCs UPC ON Um.Michaels_SKU = UPC.Michaels_SKU
					and Um.Vendor_Number = UPC.Vendor_Number
					and Um.UPC = UPC.UPC
			WHERE UPC.UPC is NULL
			--SET @MsgType = 24
		END TRY

		BEGIN CATCH
			set @msg = 'Processing Item Maint - UPC / Vendor... Error on Insert / Update' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END	-- UPC Vendor Process
	Drop Table #UPC
		
	-- *************************************************************
	-- Process UPC info 1 to many UPC records - Update
	-- *************************************************************
	-- Now get just the UPC record and set the Primary Indicator for all SKU / UPC records (across all vendors)
	SELECT
		UPC.Michaels_SKU
	  , UPC.UPC
	  , UPC.UPC_Type
	  , UPC.Primary_Ind
	   into #UPC2
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH
	(
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UPC"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,UPC varchar(1000) 'upc'
		,Michaels_SKU varchar(1000) 'item'
		,Primary_Ind varchar(1000) 'primary_ref_item_ind'
		,UPC_Type varchar(1000) 'item_number_type'
		)
	  ) UPC ON 	UPC.Michaels_SKU is not NULL and UPC.mikData_Action in ('Insert', 'Update')		

	IF (select count(*) from #UPC2) > 0
	BEGIN	
		set @msg = 'Processing etItemsFromRMS for Item Maint - UPC Update' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			UPDATE #UPC2		-- Make sure all the UPCs are 14 char
				Set UPC = dbo.udf_PadUPC(UPC,14)
			
			UPDATE SPD_Item_Master_Vendor_UPCs
				Set       
				[Primary_Indicator] = CASE	WHEN Um.Primary_Ind = 'Y' THEN 1 
											WHEN Um.Primary_Ind = 'N' THEN 0 
											ELSE UPC.[Primary_Indicator] END
				,[Update_User_ID] = @procUserID
				,[Date_Last_Modified] = getdate()
				,Is_Active = 1
			FROM SPD_Item_Master_Vendor_UPCs UPC
				join #UPC2 Um ON  UPC.[Michaels_SKU] = Um.Michaels_SKU
					and UPC.[UPC] = Um.UPC

			SET @MsgType = 24  -- Set the Message Type here since there will always be a UPC if there was a UPC / UPC supplier message
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - UPC... Error on Update' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END -- UPC process
	Drop Table #UPC2

	-- *************************************************************
	-- Process UPC info -- Delete Command
	-- *************************************************************
	SELECT
	  UPC.UPC
	   into #UPCDelete
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH
	(
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UPC"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,UPC varchar(1000) 'upc'
		)
	  ) UPC ON 	UPC.UPC is not NULL and UPC.mikData_Action = 'Delete'

	IF (select count(*) from #UPCDelete) > 0
	BEGIN	-- Can be more than one UPC record
		set @msg = 'Processing etItemsFromRMS for Item Maint - UPC Delete' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			DELETE FROM SPD_Item_Master_Vendor_UPCs
			WHERE UPC in ( Select UPC From #UPCDelete )
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - UPC... Error on Delete' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END	-- UPC Delete process
	Drop Table #UPCDelete
	  
	-- *************************************************************
	-- Process UDA Info - Note RMS Does not send this info when its a New Item.
	-- *************************************************************
	SELECT
		UDA.Michaels_SKU
	  , UDA.uda_id
	  , UDA.uda_value
	   into #UDA
	   FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UDAItem"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,Michaels_SKU varchar(1000) 'item'
		,uda_id varchar(1000) 'uda_id'
		,uda_value varchar(1000) 'uda_value'
		)
	  ) UDA ON 	UDA.Michaels_SKU is not NULL and UDA.mikData_Action in ('Insert', 'Update')		
	
	IF (select count(*) from #UDA) > 0
	BEGIN
		set @msg = 'Processing etItemsFromRMS for Item Maint - UDA'+ ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			UPDATE SPD_Item_Master_UDA	-- First do Updates on matching records
				Set UDA_Value = Um.uda_value
			FROM SPD_Item_Master_UDA UDA 
				join #UDA Um ON  UDA.[Michaels_SKU] = Um.Michaels_SKU
					and UDA.UDA_ID = Um.uda_id
			
			INSERT SPD_Item_Master_UDA (	-- Then Insert any non matching records
				[Michaels_SKU]
			  ,[UDA_ID]
			  ,[UDA_Value] )
			SELECT 
				Um.Michaels_SKU
			  , Um.uda_id
			  , Um.uda_value
			FROM #UDA Um
			  left join SPD_Item_Master_UDA UDA on Um.Michaels_SKU = UDA.Michaels_SKU
				and Um.uda_id = UDA.uda_id
			WHERE UDA.[UDA_Value] is NULL

			SET @MsgType = 25
		END TRY
		BEGIN CATCH
			set @msg = 'Processing Item Maint - UDA... Error on Insert/Update'+ ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop Table #UDA


	-- *************************************************************
	-- Process UDA Info	-- DELETE
	-- *************************************************************
	SELECT
		UDA.Michaels_SKU
	  , UDA.uda_id
	  , UDA.uda_value
	   into #UDADelete
	   FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UDAItem"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,Michaels_SKU varchar(1000) 'item'
		,uda_id varchar(1000) 'uda_id'
		,uda_value varchar(1000) 'uda_value'
		)
	  ) UDA ON 	UDA.Michaels_SKU is not NULL and UDA.mikData_Action in ('Delete')
	  
	IF (select count(*) from #UDADelete) > 0 
	BEGIN
		set @msg = 'Processing etItemsFromRMS for Item Maint - UDA Delete' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
	
		BEGIN TRY
			DELETE UDA
			FROM dbo.SPD_Item_Master_UDA UDA
				join #UDADelete Um ON UDA.Michaels_SKU = Um.Michaels_SKU
									and UDA.UDA_ID = Um.uda_id
									and UDA.UDA_Value = Um.uda_value
			SET @MsgType = 25
		END TRY
		BEGIN CATCH
			set @msg = 'Processing Item Maint - UDA Delete... Error on Delete' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop table #UDADelete
	  	
	-- *************************************************************
	-- Process Pack Item Info -- Process Updates and Inserts
	-- *************************************************************
	SELECT
		Pack_SKU
		,Child_SKU
		,Pack_Quantity
       into #Pack
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="PackItem"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,Pack_SKU varchar(1000) 'pack_no'
		,Child_SKU varchar(1000) 'item'
		,Pack_Quantity varchar(1000) 'pack_qty'
		)
	  ) Pack ON Pack.Pack_SKU is not NULL and Pack.mikData_Action in ('Insert', 'Update')

	IF (SELECT  Count(*) FROM #Pack) > 0
	BEGIN
		set @msg = 'Processing etItemsFromRMS for Item Maint - Pack Item' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			UPDATE Pack
				SET Pack_Quantity = mP.Pack_Quantity
				, Date_Last_Modified = getdate()
				, Update_User_ID = @procUserID
				, Is_Active = 1
			FROM SPD_Item_Master_PackItems Pack
				Join #Pack mP	ON Pack.Pack_SKU = mP.Pack_SKU
								and Pack.Child_SKU = mP.Child_SKU
								
			INSERT SPD_Item_Master_PackItems (
				[Pack_SKU]
				,[Child_SKU]
				,[Pack_Quantity]
				,[Created_User_ID]
				,[Date_Created]
				,[Is_Active]
				)
				SELECT 	
					mP.Pack_SKU
					, mP.Child_SKU
					, mP.Pack_Quantity
					, @procUserID
					, getdate()
					, 1
				FROM #Pack mP	
					Left Join SPD_Item_Master_PackItems Pack	ON mP.Pack_SKU = Pack.[Pack_SKU]
																and mP.Child_SKU = Pack.[Child_SKU]
				WHERE Pack.Pack_SKU is NULL 
					and Pack.Child_SKU is NULL
			SET @MsgType = 26
		END TRY
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Pack Item... Error on Insert / Update' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END -- Pack Processing
	Drop Table #Pack

	-- *************************************************************
	-- Process Pack Item Info -- Process Deletes
	-- *************************************************************
	SELECT
		Pack_SKU
		,Child_SKU
       into #PackDelete
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="PackItem"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,Pack_SKU varchar(1000) 'pack_no'
		,Child_SKU varchar(1000) 'item'
		)
	  ) Pack ON Pack.Pack_SKU is not NULL and Pack.mikData_Action ='Delete'

	IF (SELECT Count(*) FROM #PackDelete) > 0
	BEGIN
		set @msg = 'Processing etItemsFromRMS for Item Maint - Pack Item Delete' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			DELETE Pack
			FROM SPD_Item_Master_PackItems Pack
				Join #PackDelete mP	ON Pack.Pack_SKU = mP.Pack_SKU
									and Pack.Child_SKU = mP.Child_SKU
			SET @MsgType = 26
		END TRY
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Pack Item Delete... Error on Delete' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END -- Pack Processing
	Drop Table #PackDelete

END	-- EtItems

-- *************************************************************
-- Look for UDAValues for New Descriptions
-- *************************************************************

IF @XML_HeaderSegment_Source = 'RIB.etUDAValuesFromRMS'
BEGIN
	IF @Debug=1  Print 'Processing etUDAValuesFromRMS for Item Maint - UPC'

	SELECT
		UDA_ID
      ,UDA_Value
      ,UDA_Value_Desc
       into #UDADesc
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UDAValue"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,UDA_ID varchar(1000) 'uda_id'
		,UDA_Value varchar(1000) 'uda_value'
		,UDA_Value_Desc varchar(1000) 'uda_value_desc' 
		)
	  ) UDADesc ON UDADesc.UDA_ID is not NULL and UDADesc.UDA_Value is not NULL and UDADesc.UDA_Value_Desc is not NULL and UDADesc.mikData_Action in ('Insert', 'Update')
	
	IF (Select Count(*) FROM #UDADesc) > 0
	BEGIN
		set @msg= 'Processing etUDAValuesFromRMS for Item Maint - UDA Descriptions' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			UPDATE SPD_UDA_Value_Descriptions	-- First do Updates on matching records
				Set UDA_Value_Desc = Dm.UDA_Value_Desc
			FROM SPD_UDA_Value_Descriptions D 
				join #UDADesc Dm ON  D.UDA_ID = dm.UDA_ID
					and D.UDA_Value = Dm.UDA_Value
			
			INSERT SPD_UDA_Value_Descriptions (	-- Then Insert any non matching records
				UDA_ID
				,UDA_Value
				,UDA_Value_Desc )
			SELECT 
				dm.uda_id
				, dm.uda_value
				, dm.UDA_Value_Desc
			FROM #UDADesc Dm
			  left join SPD_UDA_Value_Descriptions D  on D.UDA_ID = dm.UDA_ID
					and D.UDA_Value = Dm.UDA_Value
			WHERE D.uda_value is NULL and D.UDA_ID is NULL	
			
			-- Now Update the List Values table with this info
			UPDATE LV
				SET [Display_Text] = dm.UDA_Value_Desc
			FROM #UDADesc dm
				join [List_Value_Groups] G	on G.[RMS_UDA_ID] = dm.uda_id
				join [List_Values] LV		on G.ID = LV.List_value_Group_ID and dm.uda_value = LV.List_Value
			WHERE dm.uda_id in (10,11)	-- only Private Brand and Item Type Attributes now
				
			INSERT [List_Values] (
				[List_Value_Group_ID]
				,[List_Value]
				,[Display_Text]
				,[Sort_Order]
				)
			SELECT 
				G.ID
				, dm.uda_value
				, dm.UDA_Value_Desc
				, dm.uda_value
			FROM #UDADesc dm
				join [List_Value_Groups] G on G.[RMS_UDA_ID] = dm.uda_id
				left join [List_Values] LV on G.ID = LV.List_value_Group_ID and dm.uda_value = LV.List_Value
			WHERE LV.List_Value is NULL
				and dm.uda_id in (10,11)	-- only Private Brand and Item Type Attributes now

			--NAK 7/19/2011:  UPDATE TAX UDA Values (or Re-enable it)
			UPDATE [SPD_TAX_UDA_VALUE]
			SET TAX_UDA_Value_Description = dm.UDA_Value_Desc,
				[Enabled] = 1
			FROM #UDADesc dm
				join [SPD_TAX_UDA_VALUE] TV	on TV.Tax_UDA_ID = dm.uda_id AND dm.uda_value = TV.Tax_UDA_Value_Number
			WHERE dm.uda_id between 1 and 9 	-- only TAX UDAs

			--NAK 7/19/2011: INSERT TAX UDA Values
			INSERT [SPD_TAX_UDA_VALUE] (
				Tax_UDA_ID,
				Tax_UDA_Value_Number,
				Tax_UDA_Value_Description,
				Enabled,
				Date_Last_Modified,
				Date_Created
			)
			Select
				dm.uda_id,
				dm.uda_value,
				dm.uda_value_desc,
				1,
				getDate(),
				getDate()
			FROM #UDADesc dm
			Left Join [SPD_TAX_UDA_VALUE] TV on TV.Tax_UDA_ID = dm.uda_ID AND dm.uda_value = TV.Tax_UDA_Value_Number
			WHERE Tax_UDA_Value_Number is NULL
				AND dm.uda_id Between 1 and 9 -- only TAX UDAs

			SET @MsgType = 14
		END TRY
		BEGIN CATCH
			set @msg='Processing Item Maint - UDA Descriptions... Error on Insert / Update' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop table #UDADesc
	
-- *************************************************************
-- Look for UDAValues for New Descriptions -- DELETE
-- *************************************************************

	SELECT
	  UDA_ID
      ,UDA_Value
      ,UDA_Value_Desc
       into #UDADescDelete
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="UDAValue"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,UDA_ID varchar(1000) 'uda_id'
		,UDA_Value varchar(1000) 'uda_value'
		,UDA_Value_Desc varchar(1000) 'uda_value_desc' 
		)
	  ) UDADesc ON UDADesc.UDA_ID is not NULL and UDADesc.UDA_Value is not NULL and UDADesc.UDA_Value_Desc is not NULL and UDADesc.mikData_Action in ('Delete')

	IF (Select Count(*) FROM #UDADescDelete) > 0
	BEGIN
		set @msg='Processing etUDAValuesFromRMS for Item Maint - UDA Descriptions -- DELETE' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			DELETE UDAD
			FROM dbo.SPD_UDA_Value_Descriptions UDAD
				Join #UDADescDelete mD on UDAD.UDA_ID = mD.UDA_ID
										and UDAD.UDA_Value = mD.UDA_Value
			
			--NAK 7/19/2011: Delete Tax UDAs by disabling them
			UPDATE [SPD_TAX_UDA_VALUE]
			SET Enabled = 0
			FROM #UDADescDelete dm
				join [SPD_TAX_UDA_VALUE] TV	on TV.Tax_UDA_ID = dm.uda_id AND dm.uda_value = TV.Tax_UDA_Value_Number
			WHERE dm.uda_id between 1 and 9 	-- only TAX UDAs
			
			--Set New Domestic Items and Batch validity to Unknown if an item contains one of the deleted tax udas
			Update SPD_Items
			Set Is_Valid = -1
			FROM SPD_Batch b
				INNER JOIN SPD_Workflow_Stage ws on ws.ID = b.Workflow_Stage_ID
				INNER JOIN SPD_Item_Headers ih on ih.Batch_ID = b.ID
				INNER JOIN SPD_Items i on i.Item_Header_ID = ih.ID AND IsNumeric(i.Tax_UDA)=1
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = i.Tax_UDA AND t.Tax_UDA_Value_Number = i.Tax_Value_UDA
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
			WHERE b.[Enabled] = 1 and ws.Stage_Type_ID not in (3,4)
			
			Update SPD_Batch 
			Set Is_Valid = -1
			FROM SPD_Batch b
				INNER JOIN SPD_Workflow_Stage ws on ws.ID = b.Workflow_Stage_ID
				INNER JOIN SPD_Item_Headers ih on ih.Batch_ID = b.ID
				INNER JOIN SPD_Items i on i.Item_Header_ID = ih.ID AND IsNumeric(i.Tax_UDA)=1
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = i.Tax_UDA AND t.Tax_UDA_Value_Number = i.Tax_Value_UDA
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
			WHERE b.[Enabled] = 1 and ws.Stage_Type_ID not in (3,4)
	
			--Set New Import Batches validity to Unknown if an item contains one of the deleted tax udas
			Update SPD_Batch
			Set Is_Valid = -1
			FROM SPD_Batch b
				INNER JOIN SPD_Workflow_Stage ws on ws.ID = b.Workflow_Stage_ID
				INNER JOIN SPD_Import_Items i on i.Batch_ID = b.ID AND IsNumeric(i.TaxUDA)=1
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = i.TaxUDA AND t.Tax_UDA_Value_Number = i.TaxValueUDA
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
			WHERE b.[Enabled] = 1 and ws.Stage_Type_ID not in (3,4)
		
			--Set Item Maint item validity to Unknown if it contains a change to the tax value that has been deleted
			Update SPD_Item_Maint_Items
			Set IS_Valid = -1
			FROM SPD_Batch b
				INNER JOIN SPD_Workflow_Stage ws on ws.ID = b.Workflow_Stage_ID
				INNER JOIN SPD_Item_Maint_Items im on im.Batch_ID = b.ID
				INNER JOIN SPD_Item_Master_Changes c1 on c1.Item_Maint_Items_ID = im.ID and c1.Field_Name = 'TaxUDA'
				INNER JOIN SPD_Item_Master_Changes c2 on c2.Item_Maint_Items_ID = im.ID and c2.Field_Name = 'TaxValueUDA'
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = c1.Field_Value AND t.Tax_UDA_Value_Number = c2.Field_Value
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
			WHERE b.[Enabled] = 1 and ws.Stage_Type_ID not in (3,4)
			
			Update SPD_Batch
			Set IS_Valid = -1
			FROM SPD_Batch b
				INNER JOIN SPD_Workflow_Stage ws on ws.ID = b.Workflow_Stage_ID
				INNER JOIN SPD_Item_Maint_Items im on im.Batch_ID = b.ID
				INNER JOIN SPD_Item_Master_Changes c1 on c1.Item_Maint_Items_ID = im.ID and c1.Field_Name = 'TaxUDA'
				INNER JOIN SPD_Item_Master_Changes c2 on c2.Item_Maint_Items_ID = im.ID and c2.Field_Name = 'TaxValueUDA'
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = c1.Field_Value AND t.Tax_UDA_Value_Number = c2.Field_Value
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
			WHERE b.[Enabled] = 1 and ws.Stage_Type_ID not in (3,4)

			--Set Item Maint item validity to Unknown if item is in a batch that is being edited, it has no changes to Tax values, and the current tax values are invalid
			Update SPD_Item_Maint_Items
			Set IS_Valid = -1
			FROM SPD_Batch b
				INNER JOIN SPD_Workflow_Stage ws on ws.ID = b.Workflow_Stage_ID
				INNER JOIN SPD_Item_Maint_Items im on im.Batch_ID = b.ID
				LEFT JOIN SPD_Item_Master_Changes c1 on c1.Item_Maint_Items_ID = im.ID and c1.Field_Name = 'TaxUDA'
				LEFT JOIN SPD_Item_Master_Changes c2 on c2.Item_Maint_Items_ID = im.ID and c2.Field_Name = 'TaxValueUDA'
				INNER JOIN SPD_Item_Master_UDA u on u.Michaels_SKU = im.Michaels_SKU
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = u.UDA_ID AND t.Tax_UDA_Value_Number = u.UDA_Value
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
			WHERE b.[Enabled] = 1 and ws.Stage_Type_ID not in (3,4)
				AND (c1.Field_Value is null OR c2.Field_Value is null)
				
			Update SPD_Batch
			Set IS_Valid = -1
			FROM SPD_Batch b
				INNER JOIN SPD_Workflow_Stage ws on ws.ID = b.Workflow_Stage_ID
				INNER JOIN SPD_Item_Maint_Items im on im.Batch_ID = b.ID
				LEFT JOIN SPD_Item_Master_Changes c1 on c1.Item_Maint_Items_ID = im.ID and c1.Field_Name = 'TaxUDA'
				LEFT JOIN SPD_Item_Master_Changes c2 on c2.Item_Maint_Items_ID = im.ID and c2.Field_Name = 'TaxValueUDA'
				INNER JOIN SPD_Item_Master_UDA u on u.Michaels_SKU = im.Michaels_SKU
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = u.UDA_ID AND t.Tax_UDA_Value_Number = u.UDA_Value
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
			WHERE b.[Enabled] = 1 and ws.Stage_Type_ID not in (3,4)
				AND (c1.Field_Value is null OR c2.Field_Value is null)

			--Send email to inform Michaels of items that are currently using the deleted Tax Value UDa
			DECLARE @SPEDYEnvVars_SPD_Email_FromAddress nvarchar(2048)
			DECLARE @EmailBody varchar(max)
			DECLARE @SPEDYEnvVars_SPD_SMTP_Server nvarchar(2048)
			DECLARE @SPEDYEnvVars_SPD_SMTP_Authentication_Required bit
			DECLARE @SPEDYEnvVars_SPD_SMTP_Authentication_User nvarchar(2048)
			DECLARE @SPEDYEnvVars_SPD_SMTP_Authentication_Password nvarchar(2048)
								
			SELECT  
				@SPEDYEnvVars_SPD_Email_FromAddress = [SPD_Email_FromAddress]
				,@SPEDYEnvVars_SPD_SMTP_Server = [SPD_SMTP_Server]
				,@SPEDYEnvVars_SPD_SMTP_Authentication_Required = [SPD_SMTP_Authentication_Required]
				,@SPEDYEnvVars_SPD_SMTP_Authentication_User = [SPD_SMTP_Authentication_User]
				,@SPEDYEnvVars_SPD_SMTP_Authentication_Password = [SPD_SMTP_Authentication_Password]
			FROM SPD_Environment
			WHERE Server_Name = @@SERVERNAME AND Database_Name = DB_NAME()
			
			SET @EmailBody = 'The following items are still using a deleted Tax UDA Value.  Please modify these items in Item Maintenance to remove the invalid Tax UDA VAlue. <br/> <br/>'
			
			Select @EmailBody = @EmailBody + u.Michaels_SKU + '<br/>' 
			FROM SPD_Item_Master_UDA u 
				INNER JOIN SPD_TAX_UDA_VALUE t on t.Tax_UDA_ID = u.UDA_ID AND t.Tax_UDA_Value_Number = u.UDA_Value
				INNER JOIN #UDADescDelete dm on dm.uda_id = t.Tax_UDA_ID and dm.uda_value = t.Tax_UDA_Value_Number
												
						
			EXEC sp_SQLSMTPMail
					  @vcSender = @SPEDYEnvVars_SPD_Email_FromAddress,
					  @vcFrom = @SPEDYEnvVars_SPD_Email_FromAddress,
					  @vcTo = @SPEDYEnvVars_SPD_Email_FromAddress,
					  @vcCC = '',
				      @vcBCC = '',
					  @vcSubject = 'Items using deleted Tax UDA Value',
					  @vcHTMLBody = @EmailBody,
					  @bAutoGenerateTextBody = 1,
					  @vcSMTPServer = @SPEDYEnvVars_SPD_SMTP_Server,
					  @cDSNOptions = '2',
					  @bAuthenticate = @SPEDYEnvVars_SPD_SMTP_Authentication_Required,
					  @vcSMTPAuth_UserName = @SPEDYEnvVars_SPD_SMTP_Authentication_User,
					  @vcSMTPAuth_UserPassword = @SPEDYEnvVars_SPD_SMTP_Authentication_Password

					
								
			SET @MsgType = 14
		END TRY
		BEGIN CATCH
			set @msg='Processing Item Maint - UDA Descriptions -- DELETE... Error on Delete' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop table #UDADescDelete

END

-- *************************************************************
-- Check for Message Item Maint Process Complete Messages
-- *************************************************************

--set @msg = 'Source: ' + @XML_HeaderSegment_Source + '   Contents: ' + @XML_HeaderSegment_Contents
--if @Debug=1  Print @msg

IF @XML_HeaderSegment_Source = 'RMS12_MQSEND' and @XML_HeaderSegment_Contents = 'SPEDYBatchConfirm'
BEGIN
	IF @Debug=1  Print 'Processing SPEDYBatchConfirm for Item Maint'

	SELECT
		@MsgID = SpdMessage_ID
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT top 1 * 
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="SPEDYBatchConfirm"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,SpdMessage_ID varchar(1000) 'spd_message_id'
		)
	  ) data ON SpdMessage_ID is not NULL

	IF @MsgID is not NULL 
	BEGIN
		IF @Debug=1  Print 'Processing SPEDYBatchConfirm for Item Maint ' + @MsgID
		Set @msg = 'Processing Item Maint - SPEDYBatchConfirm for Message ID: ' + @MsgID
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			SET @MsgType = 13	-- Set Message type in case no issues
		
			SELECT @BatchID = Batch_ID
			FROM SPD_Item_Maint_MQMessageTracking
			Where  Message_ID = @MsgID
			
			IF @BatchID is NULL
				-- Sameple MsgID	B.51219.74.20100723155102663	2010 07 23 15 51 02 663
				SET @BatchID = SUBSTRING(@MsgID, 3, CharIndex('.', @MsgID, 3) - 3)			
				
			Set @dotPos = charIndex('.', @MsgID, 3) -- End of batch #
			Set @dotPos = charIndex('.', @MsgID, @dotPos+1)	-- End of item #
			SET @ProcessTimeStamp = SUBSTRING(@MsgID,@dotPos+1,100)	-- Get the process time stamp using a really big length to ensure we get all of it
	
			--Make sure there are no more dots in the timestamp.  If this is a FutureCost Cancel change, there might be.
			Set @dotPos = charIndex('.', @ProcessTimeStamp, 1)
			If @dotPos > 0 
			BEGIN
				Set @ProcessTimeStamp = SUBSTRING(@ProcessTimeStamp,0,@dotPos)
			END
			
			IF @BatchID is not NULL
			BEGIN

				UPDATE SPD_MQComm_Message
					Set SPD_Batch_ID = @BatchID
				WHERE ID = @MessageID
			
				-- Find the Matching Message ID in the Message Tracking table (latest message sent for the Batch / message)
				Set @MaxProcessTimeStamp = (Select max(Process_TimeStamp) From SPD_Item_Maint_MQMessageTracking where Batch_ID = @BatchID and Process_TimeStamp is not NULL )
				IF @Debug=1  Print 'Process Time stamp =  ' + @ProcessTimeStamp + ' Max: ' + isNull(@MaxProcessTimeStamp,'NULL') + '  BatchID = ' + isNull(convert(varchar(20),@BatchID),'NULL')
 
				--Automated messages (Changes to import burden) aren't associated with a batch (batch id = 00000)
				IF @MaxProcessTimeStamp is not NULL and @MaxProcessTimeStamp = @ProcessTimeStamp and @BatchID > 0
				BEGIN	-- We've received a message for a current Batch message set
					
					-- Check current status of message.  It needs to be 1 for an active message, otherwise this is a possible error that needs to be reported.
					UPDATE SPD_Item_Maint_MQMessageTracking
						Set Status_ID = 2	-- Batch message was processed by RMS
						, Date_Updated = getdate()
					WHERE Message_ID = @MsgID
						and Status_ID <= 2	-- make sure message is at the sent phase or acknowledged phase
					IF @@rowcount = 0 
					BEGIN
						Set @msg = 'Processing Item Maint - SPEDYBatchConfirm for Message ID: ' + @MsgID + '. Message confirmation message was received for a message that is not in the SENT / Accepted State. This indicates that an error message was received for this message.'
						EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
						exec usp_SPD_ItemMaint_CompleteOrErrorBatch @Batch_ID = @BatchID, @cmd = 'S', @Msg = @msg, @debug = 1, @LTS=@LTS
					END

					IF @Debug=1  print 'MessageID '+convert(varchar(20),@MessageID)
					IF @Debug=1  print 'Batch ID '+convert(varchar(20),@BatchID)
					Set @msg = 'Updating Message Record ' + isNULL(convert(varchar(20),@MessageID),'na') 
						+ ' to Batch: ' + isNULL(convert(varchar(20),@BatchID),'-1') + ' - Process TimeStamp: ' + @ProcessTimeStamp
					EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

					-- *****************************************************************************************************************************************************************
					-- Is this a Pack Completed Message?  If so, change any messages that are on Hold to the Outbound Normal state so they can be sent (Basic and Cost Change messages)
					-- *****************************************************************************************************************************************************************
					IF Left(@MsgID,2) = 'P.'
					BEGIN
						Set @msg = 'Pack Msg Received. Releasing any other Batch Update Messages for Batch: '+ isNULL(convert(varchar(20),@BatchID),'-1')
						EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
						
						UPDATE SPD_MQComm_Message
							Set [Message_Direction] = 1
								, Date_Last_Modified = getdate()
						WHERE [SPD_Batch_ID] = @BatchID
							and [Message_Direction] = 2
						IF @@RowCount > 0 
						BEGIN
							Set @msg = 'Messages Released from Hold: ' + convert(varchar(20),@@RowCount)
							EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
						END
					END
					
					-- Now Check to see if all the sent messages have been acknowledged
					SELECT @TotalMsg = Count(*) 
					FROM SPD_Item_Maint_MQMessageTracking
					WHERE [Batch_ID] = @BatchID
						and [Process_TimeStamp] = @ProcessTimeStamp
					
					SELECT @CompletedMsg = Count(*) 
					FROM SPD_Item_Maint_MQMessageTracking
					WHERE [Batch_ID] = @BatchID
						and [Status_ID] = 2
						and [Process_TimeStamp] = @ProcessTimeStamp

					SELECT @SentMsg = Count(*)		-- Get count of Batch messages that have been sent and not updated to Completed
					FROM SPD_Item_Maint_MQMessageTracking
					WHERE [Batch_ID] = @BatchID
						and [Status_ID] = 1
						and [Process_TimeStamp] = @ProcessTimeStamp

					SELECT @ErrorMsg = Count(*)		-- Get count of Batch messages that have been sent and not updated to Completed
					FROM SPD_Item_Maint_MQMessageTracking
					WHERE [Batch_ID] = @BatchID
						and [Status_ID] > 2	-- Error or Abandoned 
						and [Process_TimeStamp] = @ProcessTimeStamp

					IF @debug=1 print 'Updating Batch History wit confirm message'
					INSERT INTO SPD_Batch_History (
						SPD_Batch_ID,
						Workflow_Stage_ID,
						[Action],
						Date_Modified,
						Modified_User,
						Notes 
						) 
					VALUES (
						@BatchID
						, @STAGE_WAITINGFORSKU
						, 'System Activity'
						, getdate()
						, @procUserID
						, 'SPEDY received an RMS confirmation message for the batch. Msgs Sent: ' 
							+ convert(varchar(20),@TotalMsg) + '. Confirmed: ' + convert(varchar(20),@CompletedMsg)
						)
					
					-- Note any errors or Resents force all messages for the batch to be error or Resent so there would be no completed messages found
					IF ( @CompletedMsg > 0 and @SentMsg = 0 and @ErrorMsg = 0)	-- No Outstanding Sent messages and the Sent Messages weren't updated to 3 or 4 (error / resent)
					BEGIN	-- All messages completed
						IF @Debug=1  Print '..... Calling usp_SPD_ItemMaint_CompleteOrErrorBatch ' + convert(varchar,@BatchID) + ' cmd = C'
						set @temp = 'Calling usp_SPD_ItemMaint_CompleteOrErrorBatch ' + convert(varchar,@BatchID) + ' cmd = C' 
							+ ' For Batch Process Time Stamp: ' + @ProcessTimeStamp
						EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

						Exec @retCode = usp_SPD_ItemMaint_CompleteOrErrorBatch @Batch_ID = @BatchID, @cmd = 'C', @LTS=@LTS
						IF @retCode != 0	
						BEGIN
							-- Some Error Occurred on Batch Ending Process.  Flag the last message as an error so it can be reset after the error has been corrected.
							SET @MsgType = 99
							-- ****************************************************************************************************************************
							-- Set Batch Message back to SENT so Batch won't complete.  
							-- To Complete this batch the following must be done:
							--		1. The Error must be corrected. See Emails and Logs for additional info on the error
							--		2. Update the Message Type for the messsage to -1 (now set at 99 to easily find it.
							--		3. The records in [SPD_MQComm_Message_Status] that pertain to this Message AND HAVE a Status_ID > 1 
							--		   must be deleted so the Inbound process will reprocess the message.
							-- ****************************************************************************************************************************
							UPDATE SPD_Item_Maint_MQMessageTracking
								Set Status_ID = 1	
								, Date_Updated = getdate()
							WHERE Message_ID = @MsgID
							
						END
					END
				END
				ELSE	-- Mismatch time stamp
				BEGIN
					IF @BatchID > 0	-- Trouble Mismatch Process Time stamp
					BEGIN
						Set @msg = 'SPEDY received a Batch Message Confirmation for a message that is nolonger in the active Message set. This indicates that RMS processed changes for a Batch that received an error and was sent back to the DBC stage.' 
						+ '<p><b>Diagnostic Info:</b></p>'
						+ '<p>  Process Time Stamp: ' + @ProcessTimeStamp + '</p>'
						+ '<p>  Max Batch Time Stamp: ' + isNull(@MaxProcessTimeStamp,'NULL')  + '</p>'
						+ '<p>  BatchID: ' + isNull(convert(varchar(20),@BatchID),'NULL') + '</p>'
						+ '<p>  Message ID: ' + @MsgID + '</p>'
						exec @retCode = usp_SPD_ItemMaint_CompleteOrErrorBatch @Batch_ID = @BatchID, @cmd = 'S', @ErrorSKU = @SKU, @Msg = @msg, @debug = 1, @LTS=@LTS
					END
				END
			END
			ELSE	-- Bad batch number
			BEGIN
				Set @msg = 'Could not Extract Batch ID from Message: '+coalesce(convert(varchar(20),@MessageID),'na')+ '. Marking message as processed.'
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
				EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			END
		END TRY
		
		BEGIN CATCH
			Set @msg = 'Processing Item Maint - SPEDYBatchConfirm for Message ID: ' + @MsgID + ' ERROR OCCURRED ON Processing' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
END

-- ****************************************************************
-- Look for Clearance and Retail Update /create messages from RMS6
-- ****************************************************************

IF @XML_HeaderSegment_Source = 'RMS6_MQSEND' and @XML_HeaderSegment_Contents = 'SkuZoneRetail'
BEGIN
	IF @Debug=1  Print 'Processing Clearance Retail message'

	SELECT
		Michaels_SKU
	  , Zone_ID
	  , Clearance_Price
	  , Retail_Price
	   into #ItemPrices
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="SkuZoneRetail"]')
	  WITH (
		Michaels_SKU varchar(1000) 'sku'
		, mikRetail_Action varchar(1000) '@action'
		, Zone_ID varchar(1000) 'zone_id'
		, Clearance_Price varchar(1000) 'unit_retail'
		, Retail_Price varchar(1000) 'was_price'
		)
	 ) ItemPrice ON ItemPrice.mikRetail_Action in ('Update', 'Create')
	
	/*	Base 1 Retail		(Zone 1): 
		Base 2 Retail		(Zone 2):
		Test Retail			(Zone 3):  
		Alaska Retail		(Zone 4):
		Canada Retail		(Zone 5):
		High 2 Retail		(Zone 6):
		High 3 Retail		(Zone 7):
		Small Mkt Retail	(Zone 8):
		High 1 Retail		(Zone 9):
		Base 3 Retail		(Zone 10):
		Low 1 Retail		(Zone 11): 
		Low 2 Retail		(Zone 12): 
		Manhattan Retail	(Zone 13): 	*/

	IF ( select count(*) from #ItemPrices) > 0
	BEGIN
		set @msg='Processing RMS6_MQSEND for Item Maint - Price Changes' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY

			IF EXISTS ( select Michaels_SKU from SPD_Item_Master_SKU where Michaels_SKU in ( Select Michaels_SKU from #ItemPrices ) )
			BEGIN
				Declare @SKUPrice varchar(10), @zoneID int, @ClearPrice money, @RetailPrice money
				Declare price CURSOR for
					Select
						Michaels_SKU
					  , Zone_ID
					  , Clearance_Price
					  , Retail_Price
					From #ItemPrices
				
				OPEN price
				FETCH NEXT From Price INTO  @SKUPrice, @zoneID, @ClearPrice, @RetailPrice
				WHILE @@Fetch_status = 0
				BEGIN
					IF @zoneID = 1
						UPDATE SPD_Item_Master_SKU 
							Set Base1_Clearance_Retail = @ClearPrice 
								, Base1_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 2
						UPDATE SPD_Item_Master_SKU 
							Set Base2_Clearance_Retail = @ClearPrice 
								, Base2_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 10
						UPDATE SPD_Item_Master_SKU 
							Set Base3_Clearance_Retail = @ClearPrice 
								, Base3_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 3
						UPDATE SPD_Item_Master_SKU 
							Set Test_Clearance_Retail = @ClearPrice 
								, Test_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 4
						UPDATE SPD_Item_Master_SKU 
							Set Alaska_Clearance_Retail = @ClearPrice
								, Alaska_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 5
						UPDATE SPD_Item_Master_SKU 
							Set Canada_Clearance_Retail = @ClearPrice 
								, Canada_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 9
						UPDATE SPD_Item_Master_SKU 
							Set High1_Clearance_Retail = @ClearPrice 
								, High1_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 6
						UPDATE SPD_Item_Master_SKU 
							Set High2_Clearance_Retail = @ClearPrice 
								, High2_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 7
						UPDATE SPD_Item_Master_SKU 
							Set High3_Clearance_Retail = @ClearPrice 
								, High3_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 8
						UPDATE SPD_Item_Master_SKU 
							Set Small_Market_Clearance_Retail = @ClearPrice
								, Small_Market_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 11
						UPDATE SPD_Item_Master_SKU 
							Set Low1_Clearance_Retail = @ClearPrice
								, Low1_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 12
						UPDATE SPD_Item_Master_SKU 
							Set Low2_Clearance_Retail = @ClearPrice 
								, Low2_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 13
						UPDATE SPD_Item_Master_SKU 
							Set Manhattan_Clearance_Retail = @ClearPrice
								, Manhattan_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
					
					IF @zoneID = 14
						UPDATE SPD_Item_Master_SKU 
							Set Quebec_Clearance = @ClearPrice
								, Quebec_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					IF @zoneID = 15
						UPDATE SPD_Item_Master_SKU 
							Set PuertoRico_Clearance = @ClearPrice
								, PuertoRico_Retail = @RetailPrice
						WHERE Michaels_SKU = @SKUPrice
						
					FETCH NEXT From Price INTO  @SKUPrice, @zoneID, @ClearPrice, @RetailPrice
				END

				Close Price
				DEALLOCATE Price

			END		-- No else because the SKU should have been created from a SKU record
			SET @MsgType = 15
		END TRY

		BEGIN CATCH
			set @msg = 'Processing Item Maint - Price Changes... ERROR on Update' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop table #ItemPrices
END	

-- *************************************************************
-- Check for Supplier Agent Updates
-- *************************************************************
IF @XML_HeaderSegment_Source = 'RMS12_MQSEND' and @XML_HeaderSegment_Contents = 'SupplierAgent'
BEGIN
	IF @Debug=1  Print 'Processing SupplierAgent for Item Maint'

	SELECT distinct
		Vendor_Number
		, Agent
	  INTO #VendorAgent		
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="SupplierAgent"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,Vendor_Number varchar(30) 'supplier'
		,Agent varchar(100) 'agent'
		)
	  ) data ON mikData_Action in ('Update', 'Delete', 'Create') 

	IF (select count(*) from #VendorAgent) > 0 
	BEGIN
		set @msg='Processing RMS12_MQSEND for Item Maint - Supplier Agent' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		BEGIN TRY
		
			UPDATE SPD_Item_Master_Vendor
				SET Vendor_Or_Agent = CASE
						WHEN NullIf(mVA.Agent,'') is NULL	THEN 'V'
						ELSE 'A' END
					, [Agent_Type] = NullIf(mVA.Agent,'')
					, [Update_User_ID] = @procUserID
					, [Date_Last_Modified] = getdate()
			FROM SPD_Item_Master_Vendor V
				Join  #VendorAgent mVA	ON V.Vendor_Number = mVA.Vendor_Number
				
			-- Keep the SPD_Item_Master_Vendor_Agent Table in sync (used by triggers)
			UPDATE [SPD_Item_Master_Vendor_Agent]
				SET [Agent] = mVA.Agent
					,[Update_User_ID] = @procUserID
					,[Date_Last_Modified] = getdate()
			FROM [SPD_Item_Master_Vendor_Agent] VA
				Join  #VendorAgent mVA	ON VA.Vendor_Number = mVA.Vendor_Number
											and  NullIf(mVA.Agent,'') is Not NULL

			INSERT 	[SPD_Item_Master_Vendor_Agent] (
				[Vendor_Number]
				,[Agent]
				,[Created_User_ID]
				,[Date_Created]
				,[Is_Active]
				)
			SELECT mVA.Vendor_Number			
				, mVA.Agent
				, @procUserID
				, getdate()
				, 1
			FROM #VendorAgent mVA
				Left Join [SPD_Item_Master_Vendor_Agent] VA on mVA.Vendor_Number = VA.Vendor_Number
			WHERE NullIf(mVA.Agent,'') is Not NULL
				and VA.[Vendor_Number] is NULL

			DELETE VA
			FROM [SPD_Item_Master_Vendor_Agent] VA
				Join  #VendorAgent mVA	ON VA.Vendor_Number = mVA.Vendor_Number
											and  NullIf(mVA.Agent,'') is NULL
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Supplier Agent... ERROR on Update' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg		
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop Table #VendorAgent
	SET @MsgType = 16
		  
END

-----------------------------------------------------------------------------------------------------------
	-- ******************************************************************************************************
	-- Did any master pack quantity or dimensions change? If so, Send Import Burden to RMS If this is an Import Vendor (who has Import Burden)
	-- ******************************************************************************************************

	if @LTS is null
		set @LTS = sysdatetime()

		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
	
	Set @VendorType = IsNull( (
		Select coalesce(Vendor_Type,0)
		From SPD_Vendor
		Where Vendor_Number = @VendorNo ), 0 )
	
	Select @DutyPct = Duty_Percent
		, @OceanFrt = Ocean_Freight_Amount
	From SPD_Item_Master_Vendor
	Where Michaels_SKU = @SKU and Vendor_Number = @VendorNo

		-- Import Vendor
	IF @VendorType = 300	
		AND (@OldMasterLength != @NewMasterLength
		 or  @OldMasterWidth != @NewMasterWidth
		 or  @OldMasterHeight != @NewMasterHeight
		 or  @OldEachesMasterCase != @NewEachesMasterCase)
		AND @DutyPct is NOT NULL
		AND @OceanFrt IS NOT NULL
	BEGIN
		set @OldDim = convert(varchar(20),@OldMasterLength) + ' x ' + convert(varchar(20),@OldMasterWidth) + ' x ' + convert(varchar(20),@OldMasterHeight)
		set @NewDim = convert(varchar(20),@NewMasterLength) + ' x ' + convert(varchar(20),@NewMasterWidth) + ' x ' + convert(varchar(20),@NewMasterHeight)
		
		set @Lmsg = 'Creating New Import Burden Message for ' + @SKU + ' : ' + convert(varchar(20),@VendorNo) 
			+ '. OLD Master Dimensions: ' + convert(varchar,@OldDim) + '  NEW Master Dimensions: ' + convert(varchar,@NewDim)
			+ '. OLD Eaches Master Case: ' + convert(varchar(20),@OldEachesMasterCase) + '  NEW Eaches Master Case: ' + convert(varchar(20),@NewEachesMasterCase)
			+ '  Duty Pct: ' + convert(varchar(20),@DutyPct) + '  Ocean Frt: ' + convert(varchar(20),@OceanFrt)
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@Lmsg

		DECLARE @ChangeRecs varchar(1000), @ImportBurden decimal(18,6), @RMSField varchar(30), @temp1 varchar(1000), @ChangeKey varchar(1000)
			, @msgItems varchar(2000), @msgWrapper varchar(3000), @MessageB XML, @NewMessage_ID bigint
		
		--Declare @ProcessTimeStamp varchar(100)
		Set @ProcessTimeStamp = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(100), dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) ), '-05:00', ''), '-', ''), ' ', ''), ':', ''), '.', '')
		
		SET @ChangeRecs = ''
		SET @ImportBurden = ( 
			Select top 1 Import_Burden 
			FROM SPD_Item_Master_Vendor_Countries
			WHERE Michaels_SKU = @SKU 
				and Vendor_Number = @VendorNo 
				and Primary_Indicator = 1
			)

		SET @RMSField = coalesce( (Select RMS_Field_Name
			FROM [SPD_RMS_Field_Lookup]
			WHERE [Field_Name] = 'ImportBurden'
				and [Maint_Type] = 'B' )
			, 'totalimportburden' )
			
		SET @ChangeRecs = dbo.udf_MakeXMLSnippet(convert(varchar(30),@ImportBurden), @RMSField)

		SET @temp1 = 'B.00000.' + convert(varchar(20),@MessageID) + '.' + @ProcessTimeStamp

		SET @ChangeKey =  dbo.udf_MakeXMLSnippet(@temp1, 'spd_batch_id') 
			+ dbo.udf_MakeXMLSnippet(@SKU, 'michaels_sku') 
			+ dbo.udf_MakeXMLSnippet(@VendorNo, 'supplier')
			+ dbo.udf_MakeXMLSnippet('SPEDY', 'update_user_domainlogin') 
			+ dbo.udf_MakeXMLSnippet(COALESCE(dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()), ''), 'date_last_modified')

		-- create msg
		SET @msgItems = '<mikData id="' 
			+ @temp1 + '" '	+ 'type="SPEDYItemMaint" action="Update">'
			+ @ChangeKey 
			+ @ChangeRecs 
			+ '</mikData>'

		SET @msgWrapper = '<mikMessage><mikHeader><Source>SPEDY</Source><Contents>SPEDYItemMaint</Contents><ThreadID>1'		-- + convert(varchar(2), @BatchID % 9 + 1)
			+ '</ThreadID><PublishTime>' 
			+ dbo.udf_s_Convert_SQLDateTime_To_UTCDateTimeString(getdate()) 
			+ '</PublishTime></mikHeader>' + @msgItems + '</mikMessage>'


	    IF @msgWrapper is NOT NULL
	    BEGIN
			SET @MessageB = CONVERT(XML,@msgWrapper)
			
			INSERT INTO SPD_MQComm_Message (
			  [SPD_Batch_ID]
			  ,[Message_Type_ID]
			  ,[Message_Body]
			  ,[Message_Direction]
			) VALUES (
				0
				, 10
				, @MessageB
				, 1 
			)
			SET @NewMessage_ID = SCOPE_IDENTITY()
			INSERT INTO SPD_MQComm_Message_Status (
			  [Message_ID]
			  ,[Status_ID]
			) VALUES (
				@NewMessage_ID
				, 1 
			)
		END
		ELSE
		BEGIN
			Set @PriInd = isNull( ( 
				Select top 1 convert(varchar(10),Primary_Indicator)
				FROM SPD_Item_Master_Vendor_Countries
				WHERE Michaels_SKU = @SKU 
					and Vendor_Number = @VendorNo 
					and Primary_Indicator = 1 ), 'NULL')
							
			Set @msg = 'NULL Import Burden Message Generated for an Import Vendor. Check trigger.'
				+ '<br />SKU: ' + @SKU 
				+ '<br />Vendor Number: ' + convert(varchar(20),@VendorNo)
				+ '<br />Primary Ind: ' + @PriInd
				+ '<br />Message ID: ' + convert(varchar(20),@MessageID)
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] 	
				@Batch_ID=0
				, @cmd = 'S'
				, @Msg = @msg
		END			
	END
	ELSE
	BEGIN
		set @Lmsg = 'Criteria NOT MET for Sending Import Burdern Message for ' + @SKU + ' : ' + Coalesce(convert(varchar(20),@VendorNo),'NULL')
			+ '. OLD Eaches Master Case: ' + coalesce(convert(varchar(20),@OldEachesMasterCase),'NULL') 
			+ '  NEW Eaches MasterCase: ' + coalesce(convert(varchar(20),@NewEachesMasterCase),'NULL')
			+ '  Duty Pct: ' + coalesce(convert(varchar(20),@DutyPct),'NULL') 
			+ '  Ocean Frt: ' + coalesce(convert(varchar(20),@OceanFrt),'NULL')
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@Lmsg
	END

-----------------------------------------------------------------------------------------------------------


-- *************************************************************
-- Check for Nasty ItemMaint Error Messages and Warnings
-- *************************************************************

IF @XML_HeaderSegment_Source = 'RMS12_MQSEND' --and @XML_HeaderSegment_Contents = 'SPEDYItemMaint'
BEGIN
	SET @MsgID = NULL
	SET @SKU = NULL
	SET @ErrorMsg1 = NULL
	SET @ErrorMsg2 = NULL
	SELECT
		@MsgID = MSG.Message_ID
		, @SKU = MSG.SKU
		, @ErrorMsg1 = MSG.ErrorMessage1
		, @ErrorMsg2 = MSG.ErrorMessage2	
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH (
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr 
	INNER JOIN (	
	  SELECT  *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData')
		WITH (
		mikData_Type varchar(1000) '@type'
		,mikData_Action varchar(1000) '@action'
		,Message_ID varchar(1000) 'spd_batch_id'
		,SKU varchar(30) 'michaels_sku'
		,VendorNo varchar(30) 'supplier'
		,ErrorMessage1 varchar(1000) 'error_message1'
		,ErrorMessage2 varchar(1000) 'error_message2'
		)
	  ) MSG ON 	MSG.mikData_Type in ('SPEDYPackMod', 'SPEDYCostChange', 'SPEDYItemMaint') and MSG.ErrorMessage1 is Not NULL 

	IF @MsgID is not NULL
	BEGIN	-- Found 1.  Set Message type to error.  Check if Warning or Error
		set @msg='Processing SPEDYItemMaint for Item Maint Error / Warning Message...' + ' (Message: ' + @cMessageID + ')'
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			SET @MsgType = 12
			SET @tempVar = SUBSTRING(@MsgID, 3, CharIndex('.', @MsgID, 3) - 3)
			IF isNumeric(@tempVar) = 1
				SET @BatchID = convert(bigint,@tempVar)
			ELSE 
				SET @BatchID = -1

			SET @msgs = @ErrorMsg1 + '<br />' + coalesce(@ErrorMsg2,'')

			IF left(@ErrorMsg1,7) = 'WARNING'
			BEGIN
				IF @Debug=1  Print '..... Calling usp_SPD_ItemMaint_CompleteOrErrorBatch ' + convert(varchar,@BatchID) + ' cmd = W  SKU = ' + @SKU + '  Message = ' + @msgs
				exec @retCode = usp_SPD_ItemMaint_CompleteOrErrorBatch @Batch_ID = @BatchID, @cmd = 'W', @ErrorSKU = @SKU, @Msg = @msgs, @debug = 1, @LTS=@LTS
			END
			ELSE
			BEGIN -- Process Error Message.
				-- Make sure message is for the current set of messages.
				Set @dotPos = charIndex('.', @MsgID, 3) -- End of batch #
				Set @dotPos = charIndex('.', @MsgID, @dotPos+1)	-- End of item #
				SET @ProcessTimeStamp = SUBSTRING(@MsgID,@dotPos+1,100)	-- Get the process time stamp using a really big length to ensure we get all of it				
				
				--Make sure there are no more dots in the timestamp.  If this is a FutureCost Cancel change, there might be.
				Set @dotPos = charIndex('.', @ProcessTimeStamp, 1)
				If @dotPos > 0 
				BEGIN
					Set @ProcessTimeStamp = SUBSTRING(@ProcessTimeStamp,0,@dotPos)
				END
				
				set @MaxProcessTimeStamp = NULL
				Set @MaxProcessTimeStamp = (Select max(Process_TimeStamp) From SPD_Item_Maint_MQMessageTracking where Batch_ID = @BatchID)
				IF @MaxProcessTimeStamp is not NULL and @MaxProcessTimeStamp = @ProcessTimeStamp 
				BEGIN
					UPDATE SPD_Item_Maint_MQMessageTracking
						Set Status_ID = 3
							, Date_Updated = getdate()
					WHERE Message_ID = @MsgID
					-- Send the Batch Back to DBC Stage if its not there already and send error email
					IF @Debug=1  Print '..... Calling usp_SPD_ItemMaint_CompleteOrErrorBatch ' + convert(varchar,@BatchID) + ' cmd = E  SKU = ' + @SKU + '  Message = ' + @msgs
					exec @retCode = usp_SPD_ItemMaint_CompleteOrErrorBatch @Batch_ID = @BatchID, @cmd = 'E', @ErrorSKU = @SKU, @Msg = @msgs, @debug = 1, @LTS=@LTS
				END
				ELSE
				BEGIN
					set @msg = 'RMS Error Message received for a Batch Message that is: a) not current, b) not a valid Batch, or c) was a response to an Import Burden Change.' + ' (Message: ' + @cMessageID + ')' + '  Message = ' + @msgs
						+ '<p><b>Diagnostic Info:</b></p>'
						+ '<p>  Process Time Stamp: ' + @ProcessTimeStamp + '</p>'
						+ '<p>  Max Batch Time Stamp: ' + isNull(@MaxProcessTimeStamp,'NULL')  + '</p>'
						+ '<p>  BatchID: ' + isNull(convert(varchar(20),@BatchID),'NULL') + '</p>'
						+ '<p>  Message ID: ' + @MsgID + '</p>'
					EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
					EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
				END
			END
		END TRY
		BEGIN CATCH
			set @msg = 'Processing SPEDYItemMaint for Item Maint Error / Warning Message... ERROR on Processing of message' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
END

-- *************************************************************************************
--				E N D    I T E M   M A I N T E N A N C E   P R O C E S S I N G
-- *************************************************************************************
IF @MsgType is not NULL 
BEGIN
	set @temp = 'Setting Message Type = ' + convert(varchar(10), @MsgType)
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp
	UPDATE SPD_MQComm_Message
	SET Message_Type_ID = @MsgType
	WHERE ID = @MessageID AND Message_Type_ID <> 2
	SET @SUCCESSFLAG = 1
END
ELSE 
	SET @SUCCESSFLAG = 0
	
EXEC sp_xml_removedocument @intXMLDocHandle    

RETURN @SUCCESSFLAG

END

GO




--*************************************************
--usp_SPD_MQComm_UpdateItemMaster 
--*************************************************
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
				, [Inner_Case_Height] = II.[reshippableinnercartonheight]
				, [Inner_Case_Width] = II.[reshippableinnercartonwidth]
				, [Inner_Case_Length] = II.[reshippableinnercartonlength]
				, [Inner_Case_Weight] = II.[eachpiecenetweightlbsperounce]
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




--*************************************************
--usp_SPD_MQComm_UpdateItemMaster_BySKU 
--*************************************************
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
				, [Inner_Case_Height] = II.[reshippableinnercartonheight]
				, [Inner_Case_Width] = II.[reshippableinnercartonwidth]
				, [Inner_Case_Length] = II.[reshippableinnercartonlength]
				, [Inner_Case_Weight] = case when isnumeric(II.[eachpiecenetweightlbsperounce])=1 then convert(decimal(18,6),II.[eachpiecenetweightlbsperounce]) else 0.00 end
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


--*************************************************
--usp_SPD_UpdateNewItemFromIM 
--*************************************************
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
			,[EachPieceNetWeightLbsPerOunce]	= IM.InnerCaseWeight
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



--*************************************************
--usp_Get_Stocking_Strategy_All
--*************************************************
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Get_Stocking_Strategy_All] 

AS
BEGIN
	SELECT * from Stocking_Strategy order by Strategy_Code
END
GO











