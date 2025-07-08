
/*
scripted from .32 Test



usp_SPD_Validation_ValidateItemMaintItem
usp_SPD_Validation_ValidateItem
usp_SPD_ItemMaint_CompleteOrErrorBatch
*/


USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateItemMaintItem]    Script Date: 11/8/2021 2:36:58 PM ******/
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


go


USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_Validation_ValidateItem]    Script Date: 11/8/2021 2:36:51 PM ******/
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


go


USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_CompleteOrErrorBatch]    Script Date: 11/8/2021 2:37:37 PM ******/
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
		, @procUserID int, @BatchType as int
		
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
		FROM [SPD_Metadata_Column] M
			Join SPD_Item_Master_Changes C	ON M.[Column_Name] = C.Field_Name
			Join SPD_Item_Maint_Items I		ON C.Item_Maint_Items_ID = I.ID
		WHERE M.[Metadata_Table_ID]=11	-- ItemMaint view Only
			and M.[Update_Item_Master] = 1
			and M.[View_To_TableName] is not null
			and M.[View_To_ColumnName] is not null
			and I.Batch_ID = @Batch_ID
				
	OPEN ChangeRecs
	FETCH NEXT FROM ChangeRecs INTO @Table, @Column, @Type, @Length, @Precision, @NewValue, @SKU, @VendorNo, @DontSendToRMS

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
			FETCH NEXT FROM ChangeRecs INTO @Table, @Column, @Type, @Length, @Precision, @NewValue, @SKU, @VendorNo, @DontSendToRMS
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


go

