--************************
-- PROD ROLLBACK FOR 3.29.0
--************************

USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[sp_SPD_Batch_PublishMQMessage_ByBatchID]    Script Date: 9/17/2024 2:18:46 PM ******/
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

/****** Object:  StoredProcedure [dbo].[SPD_Report_CompletedImportItem]    Script Date: 9/17/2024 2:18:46 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SPD_Report_ImportItem]    Script Date: 9/17/2024 2:18:46 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_CompleteOrErrorBatch]    Script Date: 9/17/2024 2:18:46 PM ******/
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
				if @debug=1 print @sql

				set @temp = left('CFH: ' + isNull(@sql,'was null'),1000)
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@temp

				exec (@Sql)

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
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_ProcessIncomingMessage]    Script Date: 9/17/2024 2:18:46 PM ******/
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
		,stocking_strategy_code varchar(1000) 'mik_strategy_code'
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - SKU...')
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
--removed 2020-07-15, RMS is incorrectly sending blank values
--			  ,[Hazardous] = S.hazmat_ind
--			  ,[Hazardous_Flammable] = S.flammable_ind
--			  ,[Hazardous_Container_Type] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 8 and S.haz_container_type = RMS_Field_Value ), '')
--			  ,[Hazardous_Container_Size] = S.haz_container_size
--			  ,[Hazardous_MSDS_UOM] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 9 and S.haz_msds_uom = RMS_Field_Value ), '')	--S.haz_msds_uom
			  ,[Simple_Pack_Indicator] = S.simple_pack_ind
			  ,[Discountable] = S.discountable_ind
			  ,[SKU_Group] = Coalesce(( Select top 1 List_Value FROM List_Values WHERE List_Value_Group_ID = 15 and S.sku_group = RMS_Field_Value ), '')
			  ,[Update_User_ID] = @procUserID
			  ,[Date_Last_Modified] = getdate()
			  ,STOCKING_STRATEGY_CODE = case when S.stocking_strategy_code = '' then NULL else S.stocking_strategy_code end
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
			  ,[Date_Created]
			  ,STOCKING_STRATEGY_CODE )
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
			  ,case when S.stocking_strategy_code = '' then NULL else S.stocking_strategy_code end
			FROM #SKU S
				Left Join SPD_Item_Master_SKU SKU on S.Michaels_SKU = SKU.Michaels_SKU
				LEFT JOIN SPD_Import_Items as II on II.MichaelsSKU = S.Michaels_SKU AND II.Batch_ID = @SPEDYBatchID
				Left Join (Select Michaels_SKU, Pack_Item_Indicator, Add_Unit_Cost From SPD_Items as i Inner Join SPD_Item_Headers as h on i.Item_Header_ID = h.ID AND h.Batch_ID = @SPEDYBatchID) as D on D.Michaels_SKU = S.Michaels_SKU
			WHERE SKU.Michaels_SKU is NULL


			SET @MsgType = 20
		END TRY

		BEGIN CATCH
			set @msg = 'Processing Item Maint - SKU... Error Occurred in Insert/Update' + ' (Message: ' + @cMessageID + ') ' + ERROR_MESSAGE()
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - SKU... Error Occurred in Insert/Update' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - SKU... Error Occurred in Insert/Update')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Retails...')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Retails... Error Occurred on Update' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Retails... Error Occurred on Update')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Supplier...')
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
				Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Supplier... Error Occurred in ProcessCostChange - SKU' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Supplier... Error Occurred in ProcessCostChange - SKU')
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
				set @msg = 'Processing Item Maint - Supplier... Error Occurred in ProcessCostChange - SKU2:'  + coalesce(@SKU,'???') 
					+ ' Vendor: ' + coalesce(convert(varchar(20),@VendorNo),'???')
					+ ' ' + ERROR_MESSAGE()
				Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Supplier... Error Occurred in ProcessCostChange - SKU2: ' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Supplier... Error Occurred in ProcessCostChange - SKU2')
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
				EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			END CATCH
			
			SET @MsgType = 22
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Supplier... Error Occurred in Update/Insert'  + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Supplier... Error Occurred in Update/Insert:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Supplier... Error Occurred in Update/Insert:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Supplier -- DELETE...')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Supplier... DELETE... Error occurred on Delete:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Supplier... DELETE... Error occurred on Delete:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - Each Dim')
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
				, Primary_Indicator
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
				, case when exists(select 'x' from SPD_Item_Master_Vendor_Countries imvc where imvc.Michaels_SKU = D.Michaels_SKU and imvc.Vendor_Number = D.Vendor_Number and imvc.primary_indicator = 1) then 0 else 1 end
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Each Dim... Error Occurred on Insert / Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Each Dim... Error Occurred on Insert / Update:')
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	
	IF @InnerCount > 0
	BEGIN
		set @msg = 'Processing etItemsFromRMS for Item Maint - Inner Dim ' + ' (Message: ' + @cMessageID + ')'
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - Inner Dim')
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
				, Primary_Indicator
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
				, case when exists(select 'x' from SPD_Item_Master_Vendor_Countries imvc where imvc.Michaels_SKU = D.Michaels_SKU and imvc.Vendor_Number = D.Vendor_Number and imvc.primary_indicator = 1) then 0 else 1 end
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Inner Dim... Error Occurred on Insert / Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Inner Dim... Error Occurred on Insert / Update:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - Master Dim')
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
				, Primary_Indicator
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
				, case when exists(select 'x' from SPD_Item_Master_Vendor_Countries imvc where imvc.Michaels_SKU = D.Michaels_SKU and imvc.Vendor_Number = D.Vendor_Number and imvc.primary_indicator = 1) then 0 else 1 end
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Master Dim... Error Occurred on Insert / Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Master Dim... Error Occurred on Insert / Update:')
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
		END CATCH
		
	END
	Drop Table #DIM  
	
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - UPC / Vendor')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - UPC / Vendor... Error Occurred on Insert / Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UPC / Vendor... Error Occurred on Insert / Update:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - UPC Update')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - UPC... Error on Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UPC... Error on Update:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - UPC Delete')
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
			DELETE FROM SPD_Item_Master_Vendor_UPCs
			WHERE UPC in ( Select UPC From #UPCDelete )
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - UPC... Error on Delete' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - UPC... Error on Delete:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UPC... Error on Delete:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - UDA')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - UDA... Error on Insert/Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UDA... Error on Insert/Update:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - UDA Delete')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - UDA... Error on Delete:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UDA... Error on Delete:')
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END
	Drop table #UDADelete

		-- *************************************************************
	-- Process GTIN14 
	-- *************************************************************
	-- First Get Primary Inner and Case GTIN14 records and do the Inserts
	SELECT Distinct
		PrimaryGTIN.Michaels_SKU
	  , PrimaryGTIN.innergtin
	  , PrimaryGTIN.casegtin
	   into #primaryGTIN
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
		WITH
		(
		mikData_Action varchar(1000) '@action'
		,innergtin varchar(1000) 'innergtin'
		,casegtin varchar(1000) 'casegtin'
		,Michaels_SKU varchar(1000) 'item'
		)
	  ) PrimaryGTIN on PrimaryGTIN.Michaels_SKU is not null and PrimaryGTIN.mikData_Action in ('Insert', 'Update')
	
	IF (select count(*) from #primaryGTIN) > 0
	BEGIN	-- Primary Inner/Case GTIN14
		set @msg = 'Processing etItemsFromRMS for Item Maint - Primary Inner/case GTIN' + ' (Message: ' + @cMessageID + ')'
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Primary Inner/case GTIN')
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY
		
			delete from SPD_Item_Master_GTINs where Michaels_SKU in  (Select Michaels_SKU from #primaryGTIN) and Is_Active =1

			INSERT SPD_Item_Master_GTINs (
				[Michaels_SKU]
			  ,[InnerGTIN]
			  ,[CaseGTIN]
			  ,[Is_Active]
			  ,[Created_User_Id]
			  ,[Date_created]
			  ,Date_Last_modified
			   )
			SELECT 
				Um.Michaels_SKU
			  , Um.InnerGTIN
			  , Um.CaseGTIN
			  , 1
			  , @procUserID
			  , getdate()
			  , getdate()
			FROM #primaryGTIN Um
				left join SPD_Item_Master_GTINs GTIN ON Um.Michaels_SKU = GTIN.Michaels_SKU
					and Um.InnerGTIN = GTIN.InnerGTIN or Um.CASEGTIN = GTIN.CASEGTIN   
			WHERE GTIN.InnerGTIN is NULL or GTIN.InnerGTIN is null
			--SET @MsgType = 24
		END TRY

		BEGIN CATCH
			set @msg = 'Processing Item Maint - Primary Inner/case GTIN... Error on Insert / Update' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Primary Inner/case GTIN... Error Occurred on Insert / Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Primary Inner/case GTIN... Error Occurred on Insert / Update:')
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END	-- #primaryGTIN Process
	Drop Table #primaryGTIN
		
	-- *************************************************************
	-- Process Case GTIN info - Insert -  Inner/Case GTINs
	-- *************************************************************
	-- Now get just the Case GTIN record and insert into the table if it is not available

 SELECT Distinct
		CGTIN.Michaels_SKU Michaels_SKU
	  , coalesce(CGTIN.CGTIN14,'1') CASEGTIN
	 , CGTIN.primary_ind Case_primary_ind
	 , CGTIN.upc Case_upc
	  into #casegtin
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH
	(
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT distinct  *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="GTIN14"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,CGTIN14 varchar(1000) 'gtin14'
		,Michaels_SKU varchar(1000) 'item'
		,pack_size_type varchar(1000) 'pack_size_type'
		,upc varchar(1000) 'upc'
		,primary_ind varchar(1) 'primary_ind'
		)
	  ) CGTIN ON CGTIN.Michaels_SKU is not NULL and CGTIN.mikData_Action in ('Insert', 'Update') and CGTIN.pack_size_type = 'C'


	  SELECT Distinct
		IGTIN.Michaels_SKU Michaels_SKU
	  , IGTIN.IGTIN14 INNERGTIN
	 , IGTIN.primary_ind Inner_primary_ind
	 , IGTIN.upc Inner_upc
	  into #innergtin
	FROM OPENXML (@intXMLDocHandle, '/mikMessage')
	WITH
	(
	   mikHeader_Source varchar(1000) 'mikHeader/Source'
	  ,mikHeader_Contents varchar(1000) 'mikHeader/Contents'
	  ,mikHeader_ThreadID varchar(1000) 'mikHeader/ThreadID'
	  ,mikHeader_PublishTime varchar(1000) 'mikHeader/PublishTime'
	) hdr
	INNER JOIN (	
	  SELECT distinct  *
	  FROM OPENXML (@intXMLDocHandle, '/mikMessage/mikData[@type="GTIN14"]')
		WITH (
		mikData_Action varchar(1000) '@action'
		,IGTIN14 varchar(1000) 'gtin14'
		,Michaels_SKU varchar(1000) 'item'
		,pack_size_type varchar(1000) 'pack_size_type'
		,upc varchar(1000) 'upc'
		,primary_ind varchar(1) 'primary_ind'
		)
	  ) IGTIN ON IGTIN.Michaels_SKU is not NULL and IGTIN.mikData_Action in ('Insert', 'Update') and IGTIN.pack_size_type = 'I'

	IF (select count(*) from #casegtin) > 0
	BEGIN	
		set @msg = 'Processing etItemsFromRMS for Item Maint - Inner/Case GTIN update' + ' (Message: ' + @cMessageID + ')'
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint -Inner/Case GTIN update')
		IF @Debug=1  Print @msg
		EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

		BEGIN TRY

			delete from SPD_Item_Master_GTINs where Michaels_SKU in  (Select Michaels_SKU from #caseGTIN) 
				
				INSERT SPD_Item_Master_GTINs (
						[Michaels_SKU]
					  ,[InnerGTIN]
					  ,[CaseGTIN]
					  ,[Is_Active]
					  ,[Created_User_Id]
					  ,[Date_created]
					  ,Date_Last_modified
					   )
				select 
					TGTIN.michaels_sku
					,TGTIN.INNERGTIN
					,TGTIN.CASEGTIN
					,TGTIN.is_active
					,TGTIN.procUserID
					,TGTIN.Date_created
					,TGTIN.Date_last_modified
				from 
				(select 
					coalesce(c.michaels_sku,i.michaels_sku) michaels_sku,
					i.INNERGTIN,
					c.CASEGTIN
				   , is_active = CASE when coalesce(c.Case_primary_ind,i.Inner_primary_ind) = 'Y' then 1
										else 0
									end
					,@procUserID procUserID
					,getdate() Date_created
					,getdate() Date_last_modified
				from #casegtin c
				full outer join #innergtin i
				on c.Michaels_SKU=i.Michaels_SKU and c.Case_primary_ind=i.Inner_primary_ind
					and SUBSTRING(c.Case_upc,2,12)=SUBSTRING(i.Inner_upc,2,12)) TGTIN
				left join SPD_Item_Master_GTINs GTIN ON TGTIN.Michaels_SKU = GTIN.Michaels_SKU 

			--SET @MsgType = 24  -- Set the Message Type here since there will always be a UPC if there was a UPC / UPC supplier message
		END TRY
		
		BEGIN CATCH
			set @msg = 'Processing Item Maint - Inner/Case GTIN update update... Error on Update' + ' (Message: ' + @cMessageID + ')' + ' ' + ERROR_MESSAGE()
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Inner/Case GTIN update update... Error on Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UPC... Error on Update:')
			EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
			EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
		END CATCH
	END -- Inner/Case GTIN Process end
	
	Drop Table #casegtin

	drop table #innergtin
	  	
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - Pack Item')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Pack Item... Error on Insert / Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Pack Item... Error on Insert / Update:')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - Pack Item Delete')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Pack Item Delete... Error on Delete:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Pack Item Delete... Error on Delete')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etItemsFromRMS for Item Maint - UDA Descriptions')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - UDA Descriptions... Error on Insert / Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UDA Descriptions... Error on Insert / Update')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing etUDAValuesFromRMS for Item Maint - UDA Descriptions -- DELETE')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - UDA Descriptions -- DELETE... Error on Delete:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - UDA Descriptions -- DELETE... Error on Delete')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - SPEDYBatchConfirm for Message ID')
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
						Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'SPEDYBatchConfirm  message was received for a message that is not in the SENT / Accepted State:')
						EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
						exec usp_SPD_ItemMaint_CompleteOrErrorBatch @Batch_ID = @BatchID, @cmd = 'S', @Msg = @msg, @debug = 1, @LTS=@LTS
					END

					IF @Debug=1  print 'MessageID '+convert(varchar(20),@MessageID)
					IF @Debug=1  print 'Batch ID '+convert(varchar(20),@BatchID)
					Set @msg = 'Updating Message Record ' + isNULL(convert(varchar(20),@MessageID),'na') 
						+ ' to Batch: ' + isNULL(convert(varchar(20),@BatchID),'-1') + ' - Process TimeStamp: ' + @ProcessTimeStamp
					Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'SPEDYBatchConfirm  updating message record')
					EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg

					-- *****************************************************************************************************************************************************************
					-- Is this a Pack Completed Message?  If so, change any messages that are on Hold to the Outbound Normal state so they can be sent (Basic and Cost Change messages)
					-- *****************************************************************************************************************************************************************
					IF Left(@MsgID,2) = 'P.'
					BEGIN
						Set @msg = 'Pack Msg Received. Releasing any other Batch Update Messages for Batch: '+ isNULL(convert(varchar(20),@BatchID),'-1')
						Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'SPEDYBatchConfirm  Pack Msg Received. Releasing')
						EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
						
						UPDATE SPD_MQComm_Message
							Set [Message_Direction] = 1
								, Date_Last_Modified = getdate()
						WHERE [SPD_Batch_ID] = @BatchID
							and [Message_Direction] = 2
						IF @@RowCount > 0 
						BEGIN
							Set @msg = 'Messages Released from Hold: ' + convert(varchar(20),@@RowCount)
							Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'SPEDYBatchConfirm  Messages Released from Hold')
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
						Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'calling usp_SPD_ItemMaint_CompleteOrErrorBatch')
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
				Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Could not Extract Batch ID from Message')
				EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
				EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
			END
		END TRY
		
		BEGIN CATCH
			Set @msg = 'Processing Item Maint - SPEDYBatchConfirm for Message ID: ' + @MsgID + ' ERROR OCCURRED ON Processing' + ' '  + ERROR_MESSAGE()
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - SPEDYBatchConfirm for Message:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - SPEDYBatchConfirm for Message')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Could not Extract Batch ID from Message')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Price Changes... ERROR on Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Price Changes... ERROR on Update')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing RMS12_MQSEND ')
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
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - Supplier Agent... ERROR on Update:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Supplier Agent... ERROR on Update')
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
		Set @Lmsg = coalesce(@Lmsg, 'Error constructing log message while: ' + 'Processing Item Maint - Creating New Import Burden Message')
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
		Set @Lmsg = coalesce(@Lmsg, 'Error constructing log message while: ' + 'Processing Item Maint - Criteria NOT MET for Sending Import Burdern Message')
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
		Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - for Item Maint Error / Warning Message')
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
					Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Processing Item Maint - RMS Error Message received for a Batch Message')
					EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M=@msg
					EXEC [usp_SPD_ItemMaint_CompleteOrErrorBatch] @Batch_ID=0, @cmd = 'S', @Msg = @msg
				END
			END
		END TRY
		BEGIN CATCH
			set @msg = 'Processing SPEDYItemMaint for Item Maint Error / Warning Message... ERROR on Processing of message' + ' (Message: ' + @cMessageID + ')' + ' '  + ERROR_MESSAGE()
			Set @msg = coalesce(@msg, 'Error constructing log message while: ' + 'Item Maint Error / Warning Message... ERROR on Processing of message:' + ERROR_MESSAGE(), 'null ERROR_MESSAGE when trying to: ' + 'Processing Item Maint - Item Maint Error / Warning Message... ERROR on Processing of message')
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_PublishMQMessageByBatchID]    Script Date: 9/17/2024 2:18:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_PublishMQMessageByBatchID]
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
		
			IF @FieldName NOT IN ( 'AddCountryOfOrigin', 'CountryOfOrigin', 'ImportBurden', 'InnerGTIN','CaseGTIN') -- Handle these changes Separately
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

		--If Exempt End Date is provided, send X
		IF Exists(Select 1 FROM SPD_Item_Master_Languages_Supplier WHERE Michaels_SKU = @SKU and Vendor_Number = @VendorNo and Language_Type_ID = 2 AND COALESCE(Exempt_End_Date,'') <> '')
		BEGIN
			--Exempt End Date specified, so send X instead of Y/N
			SET @PLIIndicators = @PLIIndicators + ',fr_CA-X'
		END
		ELSE
		BEGIN
			--No Exempt End Date specified.  Send normal Y/N value.
			Select @PLIIndicators = @PLIIndicators + ',fr_CA-' + COALESCE(C.Field_Value, l.Package_Language_Indicator,'N')
			FROM SPD_item_Maint_Items as I
			Left Join SPD_Item_Master_Languages_Supplier as l on l.Michaels_SKU = I.Michaels_SKU and l.Vendor_Number = I.Vendor_Number and l.Language_Type_ID = 2
			Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'PLIFrench'
			WHERE i.id = @itemID
		END

		Select @PLIIndicators = @PLIIndicators + ',es_PR-' + COALESCE(C.Field_Value, l.Package_Language_Indicator,'N')
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Languages_Supplier as l on l.Michaels_SKU = I.Michaels_SKU and l.Vendor_Number = I.Vendor_Number and l.Language_Type_ID = 3
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'PLISpanish'
		WHERE i.id = @itemID

		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@PLIIndicators, 'pli')
		SET @BasicCount = @BasicCount + 1
	END
	
	--Now add InnerGTIN 
 	IF Exists(Select 1 FROM spd_Item_Maint_items I
						INNER JOIN SPD_Item_Master_Changes C	on I.id = C.item_maint_items_id
						WHERE c.item_maint_items_id = @ItemID
							AND c.Field_Name in ('InnerGTIN'))
	BEGIN
		--Construct the PLI Node if there were any PLI Changes
		DECLARE @InnerGTIN varchar(14)

		Select @InnerGTIN = C.Field_Value
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'InnerGTIN'
		WHERE i.id = @itemID

		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@InnerGTIN, 'InnerGTIN')
		SET @BasicCount = @BasicCount + 1
	END
		
	--Now add CaseGTIN 
 	IF Exists(Select 1 FROM spd_Item_Maint_items I
						INNER JOIN SPD_Item_Master_Changes C	on I.id = C.item_maint_items_id
						WHERE c.item_maint_items_id = @ItemID
							AND c.Field_Name in ('CaseGTIN'))
	BEGIN
		--Construct the PLI Node if there were any PLI Changes
		DECLARE @CaseGTIN varchar(14)

		Select @CaseGTIN =  C.Field_Value
		FROM SPD_item_Maint_Items as I
		Left Join SPD_Item_Master_Changes as C on C.item_maint_items_id = I.id and c.field_name = 'CaseGTIN'
		WHERE i.id = @itemID

		SET @ChangeRecs = @ChangeRecs + dbo.udf_MakeXMLSnippet(@CaseGTIN, 'CaseGTIN')
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
			if isnumeric(@FieldValue) = 1
			begin
				set @FieldValue = replace(@FieldValue, ',', '')
			end

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
/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster]    Script Date: 9/17/2024 2:18:46 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster_BySKU]    Script Date: 9/17/2024 2:18:46 PM ******/
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
				,CoinBattery = II.CoinBattery
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_UpdateNewItemFromIM]    Script Date: 9/17/2024 2:18:46 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateImportItem]    Script Date: 9/17/2024 2:18:46 PM ******/
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


    -- GTIN14
  
  declare @innergtin table(ID int identity(1,1), Sequence int, InnerGTIN varchar(20), InnerGTINExists bit, InnerGTINDupBatch bit, InnerGTINDupWorkflow bit)
  -- primary upc
  insert into @innergtin (Sequence, InnerGTIN, InnerGTINExists, InnerGTINDupBatch, InnerGTINDupWorkflow) 
  select 0, InnerGTIN, 0, 0, 0 from SPD_Import_Items where [ID] = @itemID

  -- GTIN exists ?
  update @innergtin set InnerGTINExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.InnerGTIN = [@innergtin].InnerGTIN)
    
  -- duplicate in the batch ?
  update @innergtin set InnerGTINDupBatch = 1 
    where InnerGTIN in (select i.InnerGTIN from SPD_Import_Items i where i.Batch_ID = @batchID and i.[ID] != @itemID)
      or InnerGTIN in (select u.innergtin from @innergtin u group by u.innergtin having count(u.innergtin) > 1)
  -- duplicate in workflow ?
  
  update @innergtin set InnerGTINDupWorkflow = 1 
    where InnerGTIN in (select i.InnerGTIN from SPD_Import_Items i 
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where b.[ID] != @batchID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      ) 
    or
    InnerGTIN in (select i.Vendor_Inner_GTIN from SPD_Items i 
      inner join SPD_Item_Headers ih on ih.[ID] = i.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      ) 

  -- delete the recs with no errors
  delete from @innergtin where InnerGTINExists = 0 and InnerGTINDupBatch = 0 and InnerGTINDupWorkflow = 0
  -- return results
  select ID,Sequence,InnerGTIN,InnerGTINExists,InnerGTINDupBatch,InnerGTINDupWorkflow from @innergtin



   declare @casegtin table(ID int identity(1,1), Sequence int, caseGTIN varchar(20), caseGTINExists bit, caseGTINDupBatch bit, caseGTINDupWorkflow bit)
  -- primary upc
  insert into @casegtin (Sequence, caseGTIN, caseGTINExists, caseGTINDupBatch, caseGTINDupWorkflow) 
  select 0, caseGTIN, 0, 0, 0 from SPD_Import_Items where [ID] = @itemID

  -- upc exists ?
  update @casegtin set caseGTINExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.caseGTIN = [@casegtin].caseGTIN)
    
  -- duplicate in the batch ?
  update @casegtin set caseGTINDupBatch = 1 
    where caseGTIN in (select i.caseGTIN from SPD_Import_Items i where i.Batch_ID = @batchID and i.[ID] != @itemID)


  -- duplicate in workflow ?
  update @casegtin set caseGTINDupWorkflow = 1 
    where caseGTIN in (select i.caseGTIN from SPD_Import_Items i 
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where b.[ID] != @batchID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      ) 
    or
    caseGTIN in (select i.Vendor_Case_GTIN from SPD_Items i 
      inner join SPD_Item_Headers ih on ih.[ID] = i.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      ) 
      
  -- delete the recs with no errors
  delete from @casegtin where caseGTINExists = 0 and caseGTINDupBatch = 0 and caseGTINDupWorkflow = 0
  -- return results
  select ID,Sequence,caseGTIN,caseGTINExists,caseGTINDupBatch,caseGTINDupWorkflow from @casegtin
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateItem]    Script Date: 9/17/2024 2:18:46 PM ******/
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


  -- Inner GTIN Validation
  
  declare @innergtin table(ID int identity(1,1), Sequence int, innergtin varchar(20), innergtinExists bit, innergtinDupBatch bit, innergtinDupWorkflow bit)

  insert into @innergtin (Sequence, innergtin, innergtinExists, innergtinDupBatch, innergtinDupWorkflow) 
  select 0, Vendor_Inner_GTIN, 0, 0, 0 from SPD_Items where [ID] = @itemID
    
  -- gtin exists ?
  update @innergtin set innergtinExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.InnerGTIN = [@innergtin].innergtin)
  
  update @innergtin set innergtinExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.CaseGTIN = [@innergtin].innergtin)
  
  -- duplicate in the batch ?
  update @innergtin set innergtinDupBatch = 1 
    where innergtin in (select i.Vendor_Inner_GTIN from SPD_Items i where i.Item_Header_ID = @itemHeaderID and i.[ID] != @itemID)
  
  -- duplicate in workflow ?
  update @innergtin set innergtinDupWorkflow = 1 
    where innergtin in (select i.Vendor_Inner_GTIN from SPD_Items i 
      inner join SPD_Item_Headers ih on ih.[ID] = i.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ih.[ID] != @itemHeaderID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      ) 
    or 
    innergtin in (select i.InnerGTIN from SPD_Import_Items i 
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      ) 

  -- delete the recs with no errors
  delete from @innergtin where innergtinExists = 0 and innergtinDupBatch = 0 and innergtinDupWorkflow = 0
  
  -- return results
  select ID,Sequence,innergtin,innergtinExists,innergtinDupBatch,innergtinDupWorkflow from @innergtin


   -- Case GTIN Validation
  
  declare @casegtin table(ID int identity(1,1), Sequence int, casegtin varchar(20), casegtinExists bit, casegtinDupBatch bit, casegtinDupWorkflow bit)
  insert into @casegtin (Sequence, casegtin, casegtinExists, casegtinDupBatch, casegtinDupWorkflow) 
  select 0, Vendor_case_GTIN, 0, 0, 0 from SPD_Items where [ID] = @itemID
    
  -- upc exists ?
  update @casegtin set casegtinExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.casegtin = [@casegtin].casegtin)
  
  update @casegtin set casegtinExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.InnerGTIN = [@casegtin].casegtin)
  
  -- duplicate in the batch ?
  update @casegtin set casegtinDupBatch = 1 
    where casegtin in (select i.Vendor_case_GTIN from SPD_Items i where i.Item_Header_ID = @itemHeaderID and i.[ID] != @itemID)
  
  -- duplicate in workflow ?
  update @casegtin set casegtinDupWorkflow = 1 
    where casegtin in (select i.Vendor_case_GTIN from SPD_Items i 
      inner join SPD_Item_Headers ih on ih.[ID] = i.Item_Header_ID
      inner join SPD_Batch b on ih.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ih.[ID] != @itemHeaderID and b.[enabled] = 1
        and ws.Workflow_id = 1
        and ws.Stage_Type_id != 4
      ) 
    or 
    casegtin in (select i.casegtin from SPD_Import_Items i 
      inner join SPD_Batch b on i.Batch_ID = b.[ID]
      inner join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.[id]
      where ws.Workflow_id = 1
        and ws.Stage_Type_id != 4 and b.[enabled] = 1
      ) 

  -- delete the recs with no errors
  delete from @casegtin where casegtinExists = 0 and casegtinDupBatch = 0 and casegtinDupWorkflow = 0
  
  -- return results
  select ID,Sequence,casegtin,casegtinExists,casegtinDupBatch,casegtinDupWorkflow from @casegtin


GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateItemMaintItem]    Script Date: 9/17/2024 2:18:46 PM ******/
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
  declare @MichaelsSKU varchar(10)
  declare @t table (id int identity(1,1), SKU varchar(20), VendorNumber bigint, child bit)
  
  SET NOCOUNT ON
  
  --select @batchID = [BatchID] from vwItemMaintItemDetail where [ID] = @itemID
  select @batchID = [Batch_ID], @VendorNumber = Vendor_Number, @MichaelsSKU = Michaels_SKU from SPD_Item_Maint_Items where [ID] = @itemID
  
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

  declare @InnerGTIN table(ID int identity(1,1), Sequence int, InnerGTIN varchar(20), InnerGTINExists bit, InnerGTINDupBatch bit, InnerGTINDupWorkflow bit)
  -- primary upc
  insert into @InnerGTIN (Sequence, InnerGTIN, InnerGTINExists, InnerGTINDupBatch, InnerGTINDupWorkflow) 
  select 0, InnerGTIN, 0, 0, 0 from SPD_Item_Master_GTINs where Michaels_SKU = @MichaelsSKU

  update @InnerGTIN set InnerGTIN = coalesce(field_value, InnerGTIN) from @InnerGTIN
  left join SPD_Item_Master_Changes c1 ON c1.[Item_Maint_Items_ID] = @itemid and c1.[Field_Name] = 'InnerGTIN' and c1.[Counter] = 0 
          
  update @InnerGTIN set InnerGTINExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.InnerGTIN = [@InnerGTIN].InnerGTIN and Michaels_SKU <> @MichaelsSKU)

  update @InnerGTIN set InnerGTINExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.CaseGTIN = [@InnerGTIN].InnerGTIN and Michaels_SKU <> @MichaelsSKU)

  update @InnerGTIN set InnerGTINDupBatch = 1 
    where InnerGTIN in (select field_value from SPD_Item_Master_Changes c1, SPD_Item_Maint_Items m1 where c1.Item_Maint_Items_ID = m1.ID and m1.ID = @batchID and c1.Item_Maint_Items_ID <> @itemID)

  --update @InnerGTIN set InnerGTINDupWorkflow = 1 
  --this Case is not needed for maint

  delete from @InnerGTIN where InnerGTINExists = 0 and InnerGTINDupBatch = 0 and InnerGTINDupWorkflow = 0
  
  -- return results
  select ID,Sequence,InnerGTIN,InnerGTINExists,InnerGTINDupBatch,InnerGTINDupWorkflow from @InnerGTIN

  --CASE GTIN VALIDATION

  declare @CaseGTIN table(ID int identity(1,1), Sequence int, CaseGTIN varchar(20), CaseGTINExists bit, CaseGTINDupBatch bit, CaseGTINDupWorkflow bit)
  insert into @CaseGTIN (Sequence, CaseGTIN, CaseGTINExists, CaseGTINDupBatch, CaseGTINDupWorkflow) 
  select 0, CaseGTIN, 0, 0, 0 from SPD_Item_Master_GTINs where Michaels_SKU = @MichaelsSKU

  update @CaseGTIN set CaseGTIN = coalesce(field_value, CaseGTIN) from @CaseGTIN
  left join SPD_Item_Master_Changes c1 ON c1.[Item_Maint_Items_ID] = @itemid and c1.[Field_Name] = 'CaseGTIN' and c1.[Counter] = 0 
          
  update @CaseGTIN set CaseGTINExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.CaseGTIN = [@CaseGTIN].CaseGTIN and Michaels_SKU <> @MichaelsSKU)

  update @CaseGTIN set CaseGTINExists = 1
    where exists (select 1 from SPD_Item_Master_GTINs v where v.InnerGTIN = [@CaseGTIN].CaseGTIN and Michaels_SKU <> @MichaelsSKU)

  update @CaseGTIN set CaseGTINDupBatch = 1 
    where CaseGTIN in (select field_value from SPD_Item_Master_Changes c1, SPD_Item_Maint_Items m1 where c1.Item_Maint_Items_ID = m1.ID and m1.ID = @batchID and c1.Item_Maint_Items_ID <> @itemID)

  --update @CaseGTIN set CaseGTINDupWorkflow = 1 
  --this Case is not needed for maint

  delete from @CaseGTIN where CaseGTINExists = 0 and CaseGTINDupBatch = 0 and CaseGTINDupWorkflow = 0
  
  -- return results
  select ID,Sequence,CaseGTIN,CaseGTINExists,CaseGTINDupBatch,CaseGTINDupWorkflow from @CaseGTIN


GO
