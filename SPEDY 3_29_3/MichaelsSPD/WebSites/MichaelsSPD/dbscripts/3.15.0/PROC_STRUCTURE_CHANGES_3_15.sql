SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_Get_Stocking_Strategy_By_Warehouses] 
	@ItemTypeAttribute varchar(20),
	@Warehouses varchar(8000) = '',
	@WorkflowStageTypeID int
	
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



If @WorkflowStageTypeID = 4 --4 = COMPLETED
BEGIN
	select @stock_group_id = ID from List_Value_Groups where List_Value_Group = 'STOCKSTRATALL'
END
ELSE IF @ItemTypeAttribute = 'S'
BEGIN
	select @stock_group_id = ID from List_Value_Groups where List_Value_Group = 'STOCKSTRATSEASONAL'
END
ELSE IF @ItemTypeAttribute <> 'S' and @ItemTypeAttribute <> ''
BEGIN
	select @stock_group_id = ID from List_Value_Groups where List_Value_Group = 'STOCKSTRATBASIC'
END
ELSE
BEGIN
	select @stock_group_id = ID from List_Value_Groups where List_Value_Group = 'STOCKSTRAT'
END



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

go



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==================================================================
Proc:	[usp_SPD_ItemMaster_SearchRecords_VendorDept]
Author:	J. Littlefield
Date:	May 2010
Desc:	Used by Item Maintenance Application. Search for SKU Records and DP Pack Item records
	
Test Code

[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @SKU = '10143822'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @VendorNumber=128
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @SortCol = 'Item_Desc', @SortDir='D', @RowIndex=30, @MaxRows=20 
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ItemDesc = 'Refill'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @VPN = '4'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ClassNo = 81, @SubClassNo=1337

Change Log
FJL 7/28/10 - per KH / MV : comment out special search filters on D / DP
FJL 8/23/10 - Add logic to ensure that Item Type returns first 1 or two chars of the Item Type
FJL 8/25/10 - Add logic to check Batch info from New Item and Item Maint.  Moved to filter table for performance sake
FJL 9/09/10 - Commented out Pack Searches as the Where clause is the same on all 3
JC  2/24/11 - Added support for QuoteReferenceNumber
==================================================================
*/
ALTER Procedure [dbo].[usp_SPD_ItemMaster_SearchRecords_VendorDept]
	@UserID bigint			-- required
	, @VendorID bigint		-- required
	, @DeptNum  int = null
	, @VendorNumber int = null
	, @ClassNo int = null
	, @SubClassNo int = null
	, @VPN varchar(50) = null
	, @UPC varchar(20) = null
	, @SKU varchar(20) = null
	, @ItemDesc varchar(250) = null
	, @StockCat varchar(10) = null
	, @ItemTypeAttr varchar(10) = null
	, @ItemStatus varchar(1) = null
	, @PackSearch varchar(5) = null
	, @PackSKU varchar(20) = null
	, @SortCol varchar(255) = null
	, @SortDir char(1) = 'A'
	, @RowIndex int = 0
	, @MaxRows int = null	
	, @QuoteRefNum varchar(50) = null
AS

set NOCOUNT on

-- for D / DP queries
--declare @HybridType varchar(5)
--	, @HybridSourceDC varchar(10)
--	, @DeptNo1 int
--	, @StockCat1 varchar(5)  
--	, @ClassNo1 int
--	, @SubClassNo1 int
--	, @ItemTypeAttr1 varchar(5)
--	, @PackVendorNumber bigint

-- for paging
DECLARE @StartRow int
	, @EndRow int
	, @totalRows int


SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based

IF @MaxRows is NULL
	SET @EndRow = 2147483647	-- Max int size
ELSE
	SET @EndRow = @RowIndex + @MaxRows;

	
-- Get the subset of data Sorted with a RowNumber to Page it	
-- Certain fields just have a place holder to minimize subqueries. NOTE: Can be done on non-sortable fields only
SELECT
	SKU.Michaels_SKU											as SKU
	, SKU.ID													as SKU_ID
	, coalesce(SKU.[Department_Num], 0)							as Dept_No
	, ''														as Dept_Name				-- filled in later
	, coalesce(SKU.[Class_Num], 0)								as Class_Num
	, coalesce(SKU.[Sub_Class_Num], 0)							as Sub_Class_Num
	, coalesce(SKU.[Item_Desc],'')								as Item_Desc
	, V.Vendor_Number											as Vendor_Number
	, ''														as Vendor_Name				-- filled in later
	, case V.Primary_Indicator WHEN 1 then '*' ELSE '' end		as VPI
	, coalesce(V.Vendor_Style_Num,'')							as Vendor_Style_Num
	, coalesce(UPC.UPC,'Not Defined')							as UPC
	, CASE coalesce(UPC.Primary_Indicator,0) 
		WHEN 1 THEN '*' ELSE '' END								as UPCPI
	, convert(bigint,-1)										as Batch_ID					-- filled in later
	, coalesce(SKU.Stock_Category,'')							as Stock_Category
	, coalesce(SKU.Item_Type_Attribute,'')						as Item_Type_Attribute
	, SKU.Item_Status											as Item_Status
	, dbo.udf_SPD_PackItemLeft2([Item_Type])					as Item_Type
	, 0															as Is_Pack_Parent			-- filled in later
	, 0															as Independent_Editable		-- filled in later
	, convert(varchar(10),'')									as Pack_SKU					-- filled in later
	, 0															as Vendor_Type				-- filled in later
	, coalesce(SKU.QuoteReferenceNumber, '')					as QuoteReferenceNumber
	,sku.Hybrid_Type 
	,sku.Hybrid_Source_DC
	,CASE WHEN sku.Hybrid_Conversion_Date > '1900-01-01 00:00:00.000' THEN sku.Hybrid_Conversion_Date Else null END as Hybrid_Conversion_Date
	, Row_Number() Over ( ORDER BY
			CASE WHEN @SortCol = 'DeptNo' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptNo' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'DeptName' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptName' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'SKU' and @SortDir = 'D' then SKU.Michaels_SKU END DESC,
			CASE WHEN @SortCol = 'SKU' and @SortDir != 'D' then SKU.Michaels_SKU END,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir = 'D' then SKU.[Class_Num] END DESC,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir != 'D' then SKU.[Class_Num] END,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir = 'D' then SKU.[Sub_Class_Num] END DESC,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir != 'D' then SKU.[Sub_Class_Num] END,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir = 'D' then SKU.[Item_Desc] END DESC,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir != 'D' then SKU.[Item_Desc] END,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorName' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorName' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir = 'D' then V.Vendor_Style_Num END DESC,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir != 'D' then V.Vendor_Style_Num END,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir = 'D' then SKU.Stock_Category END DESC,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir != 'D' then SKU.Stock_Category END,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir = 'D' then SKU.Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir != 'D' then SKU.Item_Type_Attribute END,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir = 'D' then SKU.Item_Status END DESC,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir != 'D' then SKU.Item_Status END,
			CASE WHEN @SortCol = 'ItemType' and @SortDir = 'D' then [Item_Type] END DESC,
			CASE WHEN @SortCol = 'ItemType' and @SortDir != 'D' then [Item_Type] END,
			CASE WHEN @SortCol = 'UPC' and @SortDir = 'D' then UPC.UPC END DESC,
			CASE WHEN @SortCol = 'UPC' and @SortDir != 'D' then UPC.UPC END,
			CASE WHEN @SortCol = 'HybridType' and @SortDir = 'D' then SKU.Hybrid_Type END DESC,
			CASE WHEN @SortCol = 'HybridType' and @SortDir != 'D' then SKU.Hybrid_Type END,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir = 'D' then SKU.Hybrid_Source_DC END DESC,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir != 'D' then SKU.Hybrid_Source_DC END,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir = 'D' then SKU.Hybrid_Conversion_Date END DESC,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir != 'D' then SKU.Hybrid_Conversion_Date END
			-- Add CASE Pairs as necessary to handle additional sort columns. All have comma's at the end except the last one
		)														as RowNumber
INTO #Results
FROM SPD_Item_Master_SKU					SKU
	join SPD_Item_Master_Vendor				V	on SKU.ID = V.SKU_ID
	left join SPD_Item_Master_Vendor_UPCs	UPC	on V.Michaels_SKU = UPC.Michaels_SKU 
													and V.Vendor_Number = UPC.Vendor_Number
WHERE ( V.Vendor_Number = @VendorNumber
		and SKU.Department_Num = @DeptNum
		and ( @ItemStatus is NULL OR SKU.Item_Status = @ItemStatus )
		and ( @ClassNo is NULL OR SKU.[Class_Num] = @ClassNo )
		and ( @SubClassNo is NULL OR SKU.Sub_Class_Num = @SubClassNo )
		and ( @SKU is NULL OR SKU.Michaels_SKU = @SKU )
		and ( ( @UPC is NULL and UPC.Primary_Indicator = 1 ) 
			OR ( UPC.UPC = @UPC )
			OR ( UPC.UPC is NULL ) )
		and ( @VPN is NULL OR V.Vendor_Style_Num like ('%' + @VPN + '%') )
		and ( @ItemDesc is NULL OR SKU.Item_Desc like ('%' + @ItemDesc + '%') )
		and ( @StockCat is NULL OR SKU.Stock_Category = @StockCat )
		and ( @ItemTypeAttr is NULL OR SKU.Item_Type_Attribute = @ItemTypeAttr )
		and ( @QuoteRefNum is NULL OR SKU.QuoteReferenceNumber like('%'+ @QuoteRefNum +'%'))
	) 
	
SET @totalRows = @@RowCount;	-- Grid needs to know how many total rows there are
--Print 'Total Rows Selected ' + convert(varchar(20),@totalRows)

-- Get the Paged results and update the fields with subquery lookups
SELECT 
	R.SKU	
	, R.SKU_ID 
	, R.Dept_No
	, Dept_Name = Coalesce( ( Select D.DEPT_Name From SPD_FineLine_Dept	D Where	R.Dept_No = D.Dept and D.[enabled] = 1 )
				, 'Unknown Department') 
	, R.Class_Num 
	, R.Sub_Class_Num
	, R.Item_Desc 
	, R.Vendor_Number 
	, Vendor_Name = coalesce( ( Select VL.Vendor_Name From SPD_Vendor VL Where R.Vendor_Number = VL.Vendor_Number )
			, 'Unknown Vendor')
	, R.VPI 
	, R.Vendor_Style_Num 
	, R.UPC 
	, R.UPCPI 
	, Batch_ID =  dbo.udf_SPD_FindBatchID(R.SKU_ID, R.SKU) 
	, R.Stock_Category 
	, R.Item_Type_Attribute 
	, R.Item_Status 
	, R.Item_Type 
	, Is_Pack_Parent = case 
			WHEN dbo.udf_SPD_PackItemLeft2(R.Item_Type) in ('D','DP') 
				THEN 1 
			ELSE 0 END
	, Independent_Editable = case 
			WHEN R.Item_Type = 'C' and Exists( 
				  Select SKU2.[Item_Type] 
				  From SPD_Item_Master_PackItems PKI
					join SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU
														and PKI.Child_SKU = R.SKU
				  Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' 
					and SKU2.Item_Status = 'A' ) 
				 THEN 0
			ELSE 1 END
	, Pack_SKU = coalesce(case
			WHEN R.Item_Type ='C' 
				THEN (  
						Select top 1 PI2.Pack_SKU 
						From SPD_Item_Master_PackItems PI2, SPD_Item_Master_SKU SKU3
						Where PI2.Child_SKU = R.SKU
						and PI2.Pack_SKU = SKU3.Michaels_SKU
						and SKU3.Item_Status = 'A'
						order by dbo.udf_SPD_PackItemLeft2(SKU3.[Item_Type]) desc
					)				
			ELSE '' END
			, '' )
	, Vendor_Type = coalesce( (
					  Select case VL2.Vendor_Type
						WHEN 110 then 1 
						WHEN 300 then 2 
						ELSE 0 END
					  From SPD_Vendor VL2 Where R.Vendor_Number = VL2.Vendor_Number )
					, 0)
	, R.QuoteReferenceNumber
	, R.Hybrid_Type
	, R.Hybrid_Source_DC
	, R.Hybrid_Conversion_Date
FROM ( Select *
	   From #Results
	   WHERE RowNumber Between @StartRow and @EndRow ) as R
Order By R.RowNumber asc

--Print 'Total Rows Selected ' + convert(varchar(20),@@RowCount)

DROP table #Results

RETURN @totalRows		

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==================================================================
Proc:	[usp_SPD_ItemMaster_SearchRecords]
Author:	J. Littlefield
Date:	May 2010
Desc:	Used by Item Maintenance Application. Search for SKU Records and DP Pack Item records
	
Test Code

[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @SKU = '10143822'
[usp_SPD_ItemMaster_SearchRecords_Vendor] @userID=1473, @vendorID=0, @VendorNumber=874, @SKU = '10105386'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @SortCol = 'Item_Desc', @SortDir='D', @RowIndex=30, @MaxRows=20 
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ItemDesc = 'Refill'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @VPN = '4'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ClassNo = 81, @SubClassNo=1337

Change Log
FJL 7/28/10 - per KH / MV : comment out special search filters on D / DP
FJL 8/23/10 - Add logic to ensure that Item Type returns first 1 or two chars of the Item Type
FJL 8/25/10 - Add logic to check Batch info from New Item and Item Maint.  Moved to filter table for performance sake
FJL 9/09/10 - Commented out Pack Searches as the Where clause is the same on all 3
JC  2/24/11 - Added support for QuoteReferenceNumber
==================================================================
*/
ALTER Procedure [dbo].[usp_SPD_ItemMaster_SearchRecords_Vendor]
	@UserID bigint			-- required
	, @VendorID bigint		-- required
	, @DeptNum  int = null
	, @VendorNumber int = null
	, @ClassNo int = null
	, @SubClassNo int = null
	, @VPN varchar(50) = null
	, @UPC varchar(20) = null
	, @SKU varchar(20) = null
	, @ItemDesc varchar(250) = null
	, @StockCat varchar(10) = null
	, @ItemTypeAttr varchar(10) = null
	, @ItemStatus varchar(1) = null
	, @PackSearch varchar(5) = null
	, @PackSKU varchar(20) = null
	, @SortCol varchar(255) = null
	, @SortDir char(1) = 'A'
	, @RowIndex int = 0
	, @MaxRows int = null	
	, @QuoteRefNum varchar(50) = null
AS

set NOCOUNT on

-- for D / DP queries
--declare @HybridType varchar(5)
--	, @HybridSourceDC varchar(10)
--	, @DeptNo1 int
--	, @StockCat1 varchar(5)  
--	, @ClassNo1 int
--	, @SubClassNo1 int
--	, @ItemTypeAttr1 varchar(5)
--	, @PackVendorNumber bigint

-- for paging
DECLARE @StartRow int
	, @EndRow int
	, @totalRows int


SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based

IF @MaxRows is NULL
	SET @EndRow = 2147483647	-- Max int size
ELSE
	SET @EndRow = @RowIndex + @MaxRows;

	
-- Get the subset of data Sorted with a RowNumber to Page it	
-- Certain fields just have a place holder to minimize subqueries. NOTE: Can be done on non-sortable fields only
SELECT
	SKU.Michaels_SKU											as SKU
	, SKU.ID													as SKU_ID
	, coalesce(SKU.[Department_Num], 0)							as Dept_No
	, coalesce(D.DEPT_Name,'UNKNOWN DEPARTMENT')				as Dept_Name
	, coalesce(SKU.[Class_Num], 0)								as Class_Num
	, coalesce(SKU.[Sub_Class_Num], 0)							as Sub_Class_Num
	, coalesce(SKU.[Item_Desc],'')								as Item_Desc
	, V.Vendor_Number											as Vendor_Number
	, ''														as Vendor_Name				-- filled in later
	, CASE V.Primary_Indicator WHEN 1 then '*' ELSE '' END		as VPI
	, coalesce(V.Vendor_Style_Num,'')							as Vendor_Style_Num
	, coalesce(UPC.UPC,'Not Defined')							as UPC
	, CASE coalesce(UPC.Primary_Indicator,0) 
		WHEN 1 THEN '*' ELSE '' END								as UPCPI
	, convert(bigint,-1)										as Batch_ID					-- filled in later
	, coalesce(SKU.Stock_Category,'')							as Stock_Category
	, coalesce(SKU.Item_Type_Attribute,'')						as Item_Type_Attribute
	, SKU.Item_Status											as Item_Status
	, dbo.udf_SPD_PackItemLeft2([Item_Type])					as Item_Type
	, 0															as Is_Pack_Parent			-- filled in later
	, 0															as Independent_Editable		-- filled in later
	, convert(varchar(10),'')									as Pack_SKU					-- filled in later
	, 0															as Vendor_Type				-- filled in later
	, coalesce(SKU.QuoteReferenceNumber, '')					as QuoteReferenceNumber
	,sku.Hybrid_Type 
	,sku.Hybrid_Source_DC
	,CASE WHEN sku.Hybrid_Conversion_Date > '1900-01-01 00:00:00.000' THEN sku.Hybrid_Conversion_Date Else null END as Hybrid_Conversion_Date
	, Row_Number() Over ( ORDER BY
			CASE WHEN @SortCol = 'DeptNo' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptNo' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'DeptName' and @SortDir = 'D' then D.DEPT_Name END DESC,
			CASE WHEN @SortCol = 'DeptName' and @SortDir != 'D' then D.DEPT_Name END,
			CASE WHEN @SortCol = 'SKU' and @SortDir = 'D' then SKU.Michaels_SKU END DESC,
			CASE WHEN @SortCol = 'SKU' and @SortDir != 'D' then SKU.Michaels_SKU END,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir = 'D' then SKU.[Class_Num] END DESC,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir != 'D' then SKU.[Class_Num] END,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir = 'D' then SKU.[Sub_Class_Num] END DESC,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir != 'D' then SKU.[Sub_Class_Num] END,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir = 'D' then SKU.[Item_Desc] END DESC,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir != 'D' then SKU.[Item_Desc] END,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorName' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorName' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir = 'D' then V.Vendor_Style_Num END DESC,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir != 'D' then V.Vendor_Style_Num END,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir = 'D' then SKU.Stock_Category END DESC,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir != 'D' then SKU.Stock_Category END,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir = 'D' then SKU.Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir != 'D' then SKU.Item_Type_Attribute END,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir = 'D' then SKU.Item_Status END DESC,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir != 'D' then SKU.Item_Status END,
			CASE WHEN @SortCol = 'ItemType' and @SortDir = 'D' then [Item_Type] END DESC,
			CASE WHEN @SortCol = 'ItemType' and @SortDir != 'D' then [Item_Type] END,
			CASE WHEN @SortCol = 'UPC' and @SortDir = 'D' then UPC.UPC END DESC,
			CASE WHEN @SortCol = 'UPC' and @SortDir != 'D' then UPC.UPC END,
			CASE WHEN @SortCol = 'HybridType' and @SortDir = 'D' then SKU.Hybrid_Type END DESC,
			CASE WHEN @SortCol = 'HybridType' and @SortDir != 'D' then SKU.Hybrid_Type END,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir = 'D' then SKU.Hybrid_Source_DC END DESC,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir != 'D' then SKU.Hybrid_Source_DC END,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir = 'D' then SKU.Hybrid_Conversion_Date END DESC,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir != 'D' then SKU.Hybrid_Conversion_Date END
			-- Add CASE Pairs as necessary to handle additional sort columns. All have comma's at the end except the last one
		)														as RowNumber
INTO #Results
FROM SPD_Item_Master_SKU					SKU
	join SPD_Item_Master_Vendor				V	on SKU.ID = V.SKU_ID
	left join SPD_Item_Master_Vendor_UPCs	UPC	on V.Michaels_SKU = UPC.Michaels_SKU 
													and V.Vendor_Number = UPC.Vendor_Number
	left join SPD_FineLine_Dept				D	on SKU.Department_Num = D.Dept
													and D.[enabled] = 1
WHERE ( V.Vendor_Number = @VendorNumber
		and ( @ItemStatus is NULL OR SKU.Item_Status = @ItemStatus )
		and ( @DeptNum is NULL OR SKU.Department_Num = @DeptNum )
		and ( @ClassNo is NULL OR SKU.[Class_Num] = @ClassNo )
		and ( @SubClassNo is NULL OR SKU.Sub_Class_Num = @SubClassNo )
		and ( @SKU is NULL OR SKU.Michaels_SKU = @SKU )
		and ( ( @UPC is NULL and UPC.Primary_Indicator = 1 ) 
			OR ( UPC.UPC = @UPC )
			OR ( UPC.UPC is NULL ) )
		and ( @VPN is NULL OR V.Vendor_Style_Num like ('%' + @VPN + '%') )
		and ( @ItemDesc is NULL OR SKU.Item_Desc like ('%' + @ItemDesc + '%') )
		and ( @StockCat is NULL OR SKU.Stock_Category = @StockCat )
		and ( @ItemTypeAttr is NULL OR SKU.Item_Type_Attribute = @ItemTypeAttr )
		and ( @QuoteRefNum is NULL OR SKU.QuoteReferenceNumber like('%'+ @QuoteRefNum +'%'))
	) 
	
SET @totalRows = @@RowCount;	-- Grid needs to know how many total rows there are
--Print 'Total Rows Selected ' + convert(varchar(20),@totalRows)

-- Get the Paged results and update the fields with subquery lookups
SELECT 
	R.SKU	
	, R.SKU_ID 
	, R.Dept_No
	, R.Dept_Name
	, R.Class_Num 
	, R.Sub_Class_Num
	, R.Item_Desc 
	, R.Vendor_Number 
	, Vendor_Name = coalesce( ( Select VL.Vendor_Name From SPD_Vendor VL Where R.Vendor_Number = VL.Vendor_Number )
			, 'Unknown Vendor')
	, R.VPI 
	, R.Vendor_Style_Num 
	, R.UPC 
	, R.UPCPI 
	, Batch_ID =  dbo.udf_SPD_FindBatchID(R.SKU_ID, R.SKU) 
	, R.Stock_Category 
	, R.Item_Type_Attribute 
	, R.Item_Status 
	, R.Item_Type 
	, Is_Pack_Parent = case 
			WHEN dbo.udf_SPD_PackItemLeft2(R.Item_Type) in ('D','DP') 
				THEN 1 
			ELSE 0 END
	, Independent_Editable = case 
			WHEN R.Item_Type = 'C' and Exists( 
				  Select SKU2.[Item_Type] 
				  From SPD_Item_Master_PackItems PKI
					join SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU
														and PKI.Child_SKU = R.SKU
				  Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' 
					and SKU2.Item_Status = 'A' ) 
				 THEN 0
			ELSE 1 END
	, Pack_SKU = coalesce(case
			WHEN R.Item_Type ='C' 
				THEN (  
						Select top 1 PI2.Pack_SKU 
						From SPD_Item_Master_PackItems PI2, SPD_Item_Master_SKU SKU3
						Where PI2.Child_SKU = R.SKU
						and PI2.Pack_SKU = SKU3.Michaels_SKU
						and SKU3.Item_Status = 'A'
						order by dbo.udf_SPD_PackItemLeft2(SKU3.[Item_Type]) desc
					)				
			ELSE '' END
			, '' )
	, Vendor_Type = coalesce( (
			Select case VL2.Vendor_Type
				WHEN 110 then 1 
				WHEN 300 then 2 
				ELSE 0 END		
			From SPD_Vendor VL2 Where R.Vendor_Number = VL2.Vendor_Number )
		, 0)
	, R.QuoteReferenceNumber
	, R.Hybrid_Type
	, R.Hybrid_Source_DC
	, R.Hybrid_Conversion_Date
FROM ( Select * 
	   From #Results
	   WHERE RowNumber Between @StartRow and @EndRow ) As R
Order By R.RowNumber asc

--Print 'Total Rows Selected ' + convert(varchar(20),@@RowCount)

DROP table #Results

RETURN @totalRows

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==================================================================
Proc:	[usp_SPD_ItemMaster_SearchRecords]
Author:	J. Littlefield
Date:	May 2010
Desc:	Used by Item Maintenance Application. Search for SKU Records and DP Pack Item records
	
Test Code

[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @SKU = '10143822'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @VendorNumber=128
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @SortCol = 'Item_Desc', @SortDir='D', @RowIndex=30, @MaxRows=20 
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ItemDesc = 'Refill'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @VPN = '4'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ClassNo = 81, @SubClassNo=1337

Change Log
FJL 7/28/10 - per KH / MV : comment out special search filters on D / DP
FJL 8/23/10 - Add logic to ensure that Item Type returns first 1 or two chars of the Item Type
FJL 8/25/10 - Add logic to check Batch info from New Item and Item Maint.  Moved to filter table for performance sake
FJL 9/09/10 - Commented out Pack Searches as the Where clause is the same on all 3
JC  2/24/11 - Added support for QuoteReferenceNumber
==================================================================
*/
ALTER Procedure [dbo].[usp_SPD_ItemMaster_SearchRecords_Dept]
	@UserID bigint			-- required
	, @VendorID bigint		-- required
	, @DeptNum  int = null
	, @VendorNumber int = null
	, @ClassNo int = null
	, @SubClassNo int = null
	, @VPN varchar(50) = null
	, @UPC varchar(20) = null
	, @SKU varchar(20) = null
	, @ItemDesc varchar(250) = null
	, @StockCat varchar(10) = null
	, @ItemTypeAttr varchar(10) = null
	, @ItemStatus varchar(1) = null
	, @PackSearch varchar(5) = null
	, @PackSKU varchar(20) = null
	, @SortCol varchar(255) = null
	, @SortDir char(1) = 'A'
	, @RowIndex int = 0
	, @MaxRows int = null	
	, @QuoteRefNum varchar(50) = null
AS

set NOCOUNT on

-- for D / DP queries
--declare @HybridType varchar(5)
--	, @HybridSourceDC varchar(10)
--	, @DeptNo1 int
--	, @StockCat1 varchar(5)  
--	, @ClassNo1 int
--	, @SubClassNo1 int
--	, @ItemTypeAttr1 varchar(5)
--	, @PackVendorNumber bigint

-- for paging
DECLARE @StartRow int
	, @EndRow int
	, @totalRows int


SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based

IF @MaxRows is NULL
	SET @EndRow = 2147483647	-- Max int size
ELSE
	SET @EndRow = @RowIndex + @MaxRows;

	
-- Get the subset of data Sorted with a RowNumber to Page it	
-- Certain fields just have a place holder to minimize subqueries. NOTE: Can be done on non-sortable fields only
SELECT
	SKU.Michaels_SKU											as SKU
	, SKU.ID													as SKU_ID
	, coalesce(SKU.[Department_Num], 0)							as Dept_No
	, ''														as Dept_Name				-- filled in later
	, coalesce(SKU.[Class_Num], 0)								as Class_Num
	, coalesce(SKU.[Sub_Class_Num], 0)							as Sub_Class_Num
	, coalesce(SKU.[Item_Desc],'')								as Item_Desc
	, V.Vendor_Number											as Vendor_Number
	, coalesce(VL.Vendor_Name, 'Unknown Vendor')				as Vendor_Name
	, case V.Primary_Indicator WHEN 1 then '*' ELSE '' end		as VPI
	, coalesce(V.Vendor_Style_Num,'')							as Vendor_Style_Num
	, coalesce(UPC.UPC,'Not Defined')							as UPC
	, CASE coalesce(UPC.Primary_Indicator,0) 
		WHEN 1 THEN '*' ELSE '' END								as UPCPI
	, convert(bigint,-1)										as Batch_ID					-- filled in later
	, coalesce(SKU.Stock_Category,'')							as Stock_Category
	, coalesce(SKU.Item_Type_Attribute,'')						as Item_Type_Attribute
	, SKU.Item_Status											as Item_Status
	, dbo.udf_SPD_PackItemLeft2([Item_Type])					as Item_Type
	, 0															as Is_Pack_Parent			-- filled in later
	, 0															as Independent_Editable		-- filled in later
	, convert(varchar(10),'')									as Pack_SKU					-- filled in later
	, case VL.Vendor_Type																	-- since the join is required for this table, get the vendor type now
		WHEN 110 then 1 
		WHEN 300 then 2 
		ELSE 0 END												as Vendor_Type
	, coalesce(SKU.QuoteReferenceNumber, '')					as QuoteReferenceNumber
	,sku.Hybrid_Type 
	,sku.Hybrid_Source_DC
	,CASE WHEN sku.Hybrid_Conversion_Date > '1900-01-01 00:00:00.000' THEN sku.Hybrid_Conversion_Date Else null END as Hybrid_Conversion_Date
	, Row_Number() Over ( ORDER BY
			CASE WHEN @SortCol = 'DeptNo' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptNo' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'DeptName' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptName' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'SKU' and @SortDir = 'D' then SKU.Michaels_SKU END DESC,
			CASE WHEN @SortCol = 'SKU' and @SortDir != 'D' then SKU.Michaels_SKU END,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir = 'D' then SKU.[Class_Num] END DESC,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir != 'D' then SKU.[Class_Num] END,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir = 'D' then SKU.[Sub_Class_Num] END DESC,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir != 'D' then SKU.[Sub_Class_Num] END,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir = 'D' then SKU.[Item_Desc] END DESC,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir != 'D' then SKU.[Item_Desc] END,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorName' and @SortDir = 'D' then VL.Vendor_Name END DESC,
			CASE WHEN @SortCol = 'VendorName' and @SortDir != 'D' then VL.Vendor_Name END,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir = 'D' then V.Vendor_Style_Num END DESC,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir != 'D' then V.Vendor_Style_Num END,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir = 'D' then SKU.Stock_Category END DESC,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir != 'D' then SKU.Stock_Category END,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir = 'D' then SKU.Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir != 'D' then SKU.Item_Type_Attribute END,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir = 'D' then SKU.Item_Status END DESC,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir != 'D' then SKU.Item_Status END,
			CASE WHEN @SortCol = 'ItemType' and @SortDir = 'D' then [Item_Type] END DESC,
			CASE WHEN @SortCol = 'ItemType' and @SortDir != 'D' then [Item_Type] END,
			CASE WHEN @SortCol = 'UPC' and @SortDir = 'D' then UPC.UPC END DESC,
			CASE WHEN @SortCol = 'UPC' and @SortDir != 'D' then UPC.UPC END,
			CASE WHEN @SortCol = 'HybridType' and @SortDir = 'D' then SKU.Hybrid_Type END DESC,
			CASE WHEN @SortCol = 'HybridType' and @SortDir != 'D' then SKU.Hybrid_Type END,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir = 'D' then SKU.Hybrid_Source_DC END DESC,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir != 'D' then SKU.Hybrid_Source_DC END,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir = 'D' then SKU.Hybrid_Conversion_Date END DESC,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir != 'D' then SKU.Hybrid_Conversion_Date END
			-- Add CASE Pairs as necessary to handle additional sort columns. All have comma's at the end except the last one
		)	as RowNumber
INTO #Results
FROM SPD_Item_Master_SKU					SKU
	join SPD_Item_Master_Vendor				V	on SKU.ID = V.SKU_ID
	left join SPD_Item_Master_Vendor_UPCs	UPC	on V.Michaels_SKU = UPC.Michaels_SKU 
													and V.Vendor_Number = UPC.Vendor_Number
	left join dbo.SPD_Vendor				VL	on V.Vendor_Number = VL.Vendor_Number
WHERE ( SKU.Department_Num = @DeptNum
		and ( @ItemStatus is NULL OR SKU.Item_Status = @ItemStatus )
		and ( @ClassNo is NULL OR SKU.[Class_Num] = @ClassNo )
		and ( @SubClassNo is NULL OR SKU.Sub_Class_Num = @SubClassNo )
		and ( ( @VendorNumber is NULL and V.Primary_Indicator = 1 ) 
			OR V.Vendor_Number = @VendorNumber )
		and ( @SKU is NULL OR SKU.Michaels_SKU = @SKU )
		and ( ( @UPC is NULL and UPC.Primary_Indicator = 1 ) 
			OR ( UPC.UPC = @UPC )
			OR ( UPC.UPC is NULL ) )
		and ( @VPN is NULL OR V.Vendor_Style_Num like ('%' + @VPN + '%') )
		and ( @ItemDesc is NULL OR SKU.Item_Desc like ('%' + @ItemDesc + '%') )
		and ( @StockCat is NULL OR SKU.Stock_Category = @StockCat )
		and ( @ItemTypeAttr is NULL OR SKU.Item_Type_Attribute = @ItemTypeAttr )
		and ( @QuoteRefNum is NULL OR SKU.QuoteReferenceNumber like('%'+ @QuoteRefNum +'%'))
	) 
	
SET @totalRows = @@RowCount;	-- Grid needs to know how many total rows there are
--Print 'Total Rows Selected ' + convert(varchar(20),@totalRows)

-- Get the Paged results and update the fields with subquery lookups
SELECT 
	R.SKU	
	, R.SKU_ID 
	, R.Dept_No
	, Dept_Name = Coalesce( (Select D.DEPT_Name From SPD_FineLine_Dept D Where D.Dept = R.Dept_No and D.[enabled] = 1 )
					,'Unknown Department' )
	, R.Class_Num 
	, R.Sub_Class_Num
	, R.Item_Desc 
	, R.Vendor_Number 
	, R.Vendor_Name 
	, R.VPI 
	, R.Vendor_Style_Num 
	, R.UPC 
	, R.UPCPI 
	, Batch_ID = dbo.udf_SPD_FindBatchID(R.SKU_ID, R.SKU) 
	, R.Stock_Category 
	, R.Item_Type_Attribute 
	, R.Item_Status 
	, R.Item_Type 
	, Is_Pack_Parent = case 
			WHEN dbo.udf_SPD_PackItemLeft2(R.Item_Type) in ('D','DP') 
				THEN 1 
			ELSE 0 END
	, Independent_Editable = case 
			WHEN R.Item_Type = 'C' and Exists( 
				  Select SKU2.[Item_Type] 
				  From SPD_Item_Master_PackItems PKI
					join SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU
														and PKI.Child_SKU = R.SKU
				  Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' 
					and SKU2.Item_Status = 'A' ) 
				 THEN 0
			ELSE 1 END
	, Pack_SKU = coalesce(case
			WHEN R.Item_Type ='C' 
				THEN (  
						Select top 1 PI2.Pack_SKU 
						From SPD_Item_Master_PackItems PI2, SPD_Item_Master_SKU SKU3
						Where PI2.Child_SKU = R.SKU
						and PI2.Pack_SKU = SKU3.Michaels_SKU
						and SKU3.Item_Status = 'A'
						order by dbo.udf_SPD_PackItemLeft2(SKU3.[Item_Type]) desc
					)				
			ELSE '' END
			, '' )
	, R.Vendor_Type 
	, R.QuoteReferenceNumber
	, R.Hybrid_Type
	, R.Hybrid_Source_DC
	, R.Hybrid_Conversion_Date
FROM ( Select *
	   From #Results
	   WHERE RowNumber Between @StartRow and @EndRow ) as R
Order BY R.RowNumber asc

--Print 'Total Rows Selected ' + convert(varchar(20),@@RowCount)

DROP table #Results

RETURN @totalRows

go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==================================================================
Proc:	[usp_SPD_ItemMaster_SearchRecords]
Author:	J. Littlefield
Date:	May 2010
Desc:	Used by Item Maintenance Application. Search for SKU Records and DP Pack Item records
	
Test Code

[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @SKU = '10143822'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @VendorNumber=128
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @SortCol = 'Item_Desc', @SortDir='D', @RowIndex=30, @MaxRows=20 
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ItemDesc = 'Refill'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @VPN = '4'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ClassNo = 81, @SubClassNo=1337

Change Log
FJL 7/28/10 - per KH / MV : comment out special search filters on D / DP
FJL 8/23/10 - Add logic to ensure that Item Type returns first 1 or two chars of the Item Type
FJL 8/25/10 - Add logic to check Batch info from New Item and Item Maint.  Moved to filter table for performance sake
FJL 9/09/10 - Commented out Pack Searches as the Where clause is the same on all 3
JC  2/24/11 - Added support for QuoteReferenceNumber
==================================================================
*/
ALTER Procedure [dbo].[usp_SPD_ItemMaster_SearchRecords_ItemDesc]
	@UserID bigint			-- required
	, @VendorID bigint		-- required
	, @DeptNum  int = null
	, @VendorNumber int = null
	, @ClassNo int = null
	, @SubClassNo int = null
	, @VPN varchar(50) = null
	, @UPC varchar(20) = null
	, @SKU varchar(20) = null
	, @ItemDesc varchar(250) = null
	, @StockCat varchar(10) = null
	, @ItemTypeAttr varchar(10) = null
	, @ItemStatus varchar(1) = null
	, @PackSearch varchar(5) = null
	, @PackSKU varchar(20) = null
	, @SortCol varchar(255) = null
	, @SortDir char(1) = 'A'
	, @RowIndex int = 0
	, @MaxRows int = null	
	, @QuoteRefNum varchar(50) = null
AS

set NOCOUNT on

-- for D / DP queries
--declare @HybridType varchar(5)
--	, @HybridSourceDC varchar(10)
--	, @DeptNo1 int
--	, @StockCat1 varchar(5)  
--	, @ClassNo1 int
--	, @SubClassNo1 int
--	, @ItemTypeAttr1 varchar(5)
--	, @PackVendorNumber bigint

-- for paging
DECLARE @StartRow int
	, @EndRow int
	, @totalRows int


SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based

IF @MaxRows is NULL
	SET @EndRow = 2147483647	-- Max int size
ELSE
	SET @EndRow = @RowIndex + @MaxRows;

	
-- Get the subset of data Sorted with a RowNumber to Page it	
-- Certain fields just have a place holder to minimize subqueries. NOTE: Can be done on non-sortable fields only
SELECT
	SKU.Michaels_SKU											as SKU
	, SKU.ID													as SKU_ID
	, coalesce(SKU.[Department_Num], 0)							as Dept_No
	, coalesce(D.DEPT_Name,'UNKNOWN DEPARTMENT')				as Dept_Name
	, coalesce(SKU.[Class_Num], 0)								as Class_Num
	, coalesce(SKU.[Sub_Class_Num], 0)							as Sub_Class_Num
	, coalesce(SKU.[Item_Desc],'')								as Item_Desc
	, V.Vendor_Number											as Vendor_Number
	, coalesce(VL.Vendor_Name, 'Unknown Vendor')				as Vendor_Name
	, case V.Primary_Indicator WHEN 1 then '*' ELSE '' end		as VPI
	, coalesce(V.Vendor_Style_Num,'')							as Vendor_Style_Num
	, coalesce(UPC.UPC,'Not Defined')							as UPC
	, CASE coalesce(UPC.Primary_Indicator,0) 
		WHEN 1 THEN '*' ELSE '' END								as UPCPI
	, convert(bigint,-1)										as Batch_ID					-- filled in later
	, coalesce(SKU.Stock_Category,'')							as Stock_Category
	, coalesce(SKU.Item_Type_Attribute,'')						as Item_Type_Attribute
	, SKU.Item_Status											as Item_Status
	, dbo.udf_SPD_PackItemLeft2([Item_Type])					as Item_Type
	, 0															as Is_Pack_Parent			-- filled in later
	, 0															as Independent_Editable		-- filled in later
	, convert(varchar(10),'')									as Pack_SKU					-- filled in later
	, case VL.Vendor_Type																	-- since the join is required for this table, get the vendor type now
		WHEN 110 then 1 
		WHEN 300 then 2 
		ELSE 0 END												as Vendor_Type
	, coalesce(SKU.QuoteReferenceNumber, '')					as QuoteReferenceNumber
	,sku.Hybrid_Type 
	,sku.Hybrid_Source_DC
	,CASE WHEN sku.Hybrid_Conversion_Date > '1900-01-01 00:00:00.000' THEN sku.Hybrid_Conversion_Date Else null END as Hybrid_Conversion_Date
	, Row_Number() Over ( ORDER BY
			CASE WHEN @SortCol = 'DeptNo' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptNo' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'DeptName' and @SortDir = 'D' then D.DEPT_Name END DESC,
			CASE WHEN @SortCol = 'DeptName' and @SortDir != 'D' then D.DEPT_Name END,
			CASE WHEN @SortCol = 'SKU' and @SortDir = 'D' then SKU.Michaels_SKU END DESC,
			CASE WHEN @SortCol = 'SKU' and @SortDir != 'D' then SKU.Michaels_SKU END,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir = 'D' then SKU.[Class_Num] END DESC,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir != 'D' then SKU.[Class_Num] END,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir = 'D' then SKU.[Sub_Class_Num] END DESC,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir != 'D' then SKU.[Sub_Class_Num] END,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir = 'D' then SKU.[Item_Desc] END DESC,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir != 'D' then SKU.[Item_Desc] END,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorName' and @SortDir = 'D' then VL.Vendor_Name END DESC,
			CASE WHEN @SortCol = 'VendorName' and @SortDir != 'D' then VL.Vendor_Name END,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir = 'D' then V.Vendor_Style_Num END DESC,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir != 'D' then V.Vendor_Style_Num END,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir = 'D' then SKU.Stock_Category END DESC,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir != 'D' then SKU.Stock_Category END,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir = 'D' then SKU.Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir != 'D' then SKU.Item_Type_Attribute END,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir = 'D' then SKU.Item_Status END DESC,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir != 'D' then SKU.Item_Status END,
			CASE WHEN @SortCol = 'ItemType' and @SortDir = 'D' then [Item_Type] END DESC,
			CASE WHEN @SortCol = 'ItemType' and @SortDir != 'D' then [Item_Type] END,
			CASE WHEN @SortCol = 'UPC' and @SortDir = 'D' then UPC.UPC END DESC,
			CASE WHEN @SortCol = 'UPC' and @SortDir != 'D' then UPC.UPC END,
			CASE WHEN @SortCol = 'HybridType' and @SortDir = 'D' then SKU.Hybrid_Type END DESC,
			CASE WHEN @SortCol = 'HybridType' and @SortDir != 'D' then SKU.Hybrid_Type END,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir = 'D' then SKU.Hybrid_Source_DC END DESC,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir != 'D' then SKU.Hybrid_Source_DC END,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir = 'D' then SKU.Hybrid_Conversion_Date END DESC,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir != 'D' then SKU.Hybrid_Conversion_Date END
			-- Add CASE Pairs as necessary to handle additional sort columns. All have comma's at the end except the last one
		)														as RowNumber
INTO #Results
FROM SPD_Item_Master_SKU					SKU
	join SPD_Item_Master_Vendor				V	on SKU.ID = V.SKU_ID
	left join SPD_Item_Master_Vendor_UPCs	UPC	on V.Michaels_SKU = UPC.Michaels_SKU 
													and V.Vendor_Number = UPC.Vendor_Number
													--and UPC.Primary_Indicator = 1
	left join dbo.SPD_Vendor				VL	on V.Vendor_Number = VL.Vendor_Number
	left join SPD_FineLine_Dept				D	on SKU.Department_Num = D.Dept
													and D.[enabled] = 1
WHERE ( SKU.Item_Desc like ('%' + @ItemDesc + '%') 
		and	( @ItemStatus is NULL OR SKU.Item_Status = @ItemStatus )
		and ( @DeptNum is NULL OR SKU.Department_Num = @DeptNum )
		and ( @ClassNo is NULL OR SKU.[Class_Num] = @ClassNo )
		and ( @SubClassNo is NULL OR SKU.Sub_Class_Num = @SubClassNo )
		and ( ( @VendorNumber is NULL and V.Primary_Indicator = 1 ) 
			OR V.Vendor_Number = @VendorNumber )
		and ( @SKU is NULL OR SKU.Michaels_SKU = @SKU )
		and ( ( @UPC is NULL and UPC.Primary_Indicator = 1 ) 
			OR ( UPC.UPC = @UPC )
			OR ( UPC.UPC is NULL ) )
		and ( @VPN is NULL OR V.Vendor_Style_Num like ('%' + @VPN + '%') )
		and ( @StockCat is NULL OR SKU.Stock_Category = @StockCat )
		and ( @ItemTypeAttr is NULL OR SKU.Item_Type_Attribute = @ItemTypeAttr )
		and ( @QuoteRefNum is NULL OR SKU.QuoteReferenceNumber like('%'+ @QuoteRefNum +'%'))
	) 
	
SET @totalRows = @@RowCount;	-- Grid needs to know how many total rows there are
--Print 'Total Rows Selected ' + convert(varchar(20),@totalRows)

-- Get the Paged results and update the fields with subquery lookups
SELECT R.SKU	
	, R.SKU_ID 
	, R.Dept_No
	, R.Dept_Name
	, R.Class_Num 
	, R.Sub_Class_Num
	, R.Item_Desc 
	, R.Vendor_Number 
	, R.Vendor_Name 
	, R.VPI 
	, R.Vendor_Style_Num 
	, R.UPC 
	, R.UPCPI 
	, Batch_ID =  dbo.udf_SPD_FindBatchID(R.SKU_ID, R.SKU) 
	, R.Stock_Category 
	, R.Item_Type_Attribute 
	, R.Item_Status 
	, R.Item_Type 
	, Is_Pack_Parent = case 
			WHEN dbo.udf_SPD_PackItemLeft2(R.Item_Type) in ('D','DP') 
				THEN 1 
			ELSE 0 END
	, Independent_Editable = case 
			WHEN R.Item_Type = 'C' and Exists( 
				  Select SKU2.[Item_Type] 
				  From SPD_Item_Master_PackItems PKI
					join SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU
														and PKI.Child_SKU = R.SKU
				  Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' 
					and SKU2.Item_Status = 'A' ) 
				 THEN 0
			ELSE 1 END
	, Pack_SKU = coalesce(case
			WHEN R.Item_Type ='C' 
				THEN (  
						Select top 1 PI2.Pack_SKU 
						From SPD_Item_Master_PackItems PI2, SPD_Item_Master_SKU SKU3
						Where PI2.Child_SKU = R.SKU
						and PI2.Pack_SKU = SKU3.Michaels_SKU
						and SKU3.Item_Status = 'A'
						order by dbo.udf_SPD_PackItemLeft2(SKU3.[Item_Type]) desc
					)				
			ELSE '' END
			, '' )
	, R.Vendor_Type 
	, R.QuoteReferenceNumber
	, R.Hybrid_Type
	, R.Hybrid_Source_DC
	, R.Hybrid_Conversion_Date
	
FROM ( Select * 
	   From	#Results
	   WHERE RowNumber Between @StartRow and @EndRow ) as R
Order By R.RowNumber asc

--Print 'Total Rows Selected ' + convert(varchar(20),@@RowCount)

DROP table #Results

RETURN @totalRows

go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==================================================================
Proc:	[usp_SPD_ItemMaster_SearchRecords]
Author:	J. Littlefield
Date:	May 2010
Desc:	Used by Item Maintenance Application. Search for SKU Records and DP Pack Item records
	
Test Code

[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @SKU = '10143822'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @VendorNumber=128
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @SortCol = 'Item_Desc', @SortDir='D', @RowIndex=30, @MaxRows=20 
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ItemDesc = 'Refill'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @VPN = '4'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ClassNo = 81, @SubClassNo=1337

Change Log
FJL 7/28/10 - per KH / MV : comment out special search filters on D / DP
FJL 8/23/10 - Add logic to ensure that Item Type returns first 1 or two chars of the Item Type
FJL 8/25/10 - Add logic to check Batch info from New Item and Item Maint.  Moved to filter table for performance sake
FJL 9/09/10 - Commented out Pack Searches as the Where clause is the same on all 3
FJL 9/21/10 - Added logic to call clones of this proc for specific search criteria hopefully using an optimized query plan
JC  2/24/11 - Added support for QuoteReferenceNumber
==================================================================
*/
ALTER Procedure [dbo].[usp_SPD_ItemMaster_SearchRecords]
	@UserID bigint			-- required
	, @VendorID bigint		-- required
	, @DeptNum  int = null
	, @VendorNumber int = null
	, @ClassNo int = null
	, @SubClassNo int = null
	, @VPN varchar(50) = null
	, @UPC varchar(20) = null
	, @SKU varchar(20) = null
	, @ItemDesc varchar(250) = null
	, @StockCat varchar(10) = null
	, @ItemTypeAttr varchar(10) = null
	, @ItemStatus varchar(1) = null
	, @PackSearch varchar(5) = null
	, @PackSKU varchar(20) = null
	, @SortCol varchar(255) = null
	, @SortDir char(1) = 'A'
	, @RowIndex int = 0
	, @MaxRows int = null
	, @QuoteRefNum varchar(50) = null	
AS

set NOCOUNT on
-- Use separate tweaked queries based on Search Criteria for performace consistency
Declare @rows int

IF @DeptNum is not NULL and @VendorNumber is not NULL
BEGIN
	Exec @rows = [usp_SPD_ItemMaster_SearchRecords_Dept] 
		@UserID = @UserID
		, @VendorID = @VendorID
		, @DeptNum = @DeptNum
		, @VendorNumber = @VendorNumber
		, @ClassNo = @ClassNo
		, @SubClassNo = @SubClassNo
		, @VPN = @VPN
		, @UPC = @UPC
		, @SKU = @SKU
		, @ItemDesc = @ItemDesc
		, @StockCat = @StockCat
		, @ItemTypeAttr = @ItemTypeAttr
		, @ItemStatus = @ItemStatus
		, @PackSearch = @PackSearch
		, @PackSKU = @PackSKU
		, @SortCol = @SortCol
		, @SortDir = @SortDir
		, @RowIndex = @RowIndex
		, @MaxRows = @MaxRows
		, @QuoteRefNum = @QuoteRefNum
	Return @rows
END

IF @DeptNum is not NULL
BEGIN
	Exec @rows = [usp_SPD_ItemMaster_SearchRecords_Dept] 
		@UserID = @UserID
		, @VendorID = @VendorID
		, @DeptNum = @DeptNum
		, @VendorNumber = @VendorNumber
		, @ClassNo = @ClassNo
		, @SubClassNo = @SubClassNo
		, @VPN = @VPN
		, @UPC = @UPC
		, @SKU = @SKU
		, @ItemDesc = @ItemDesc
		, @StockCat = @StockCat
		, @ItemTypeAttr = @ItemTypeAttr
		, @ItemStatus = @ItemStatus
		, @PackSearch = @PackSearch
		, @PackSKU = @PackSKU
		, @SortCol = @SortCol
		, @SortDir = @SortDir
		, @RowIndex = @RowIndex
		, @MaxRows = @MaxRows
		, @QuoteRefNum = @QuoteRefNum
	Return @rows
END

IF @VendorNumber is not NULL
BEGIN
	Exec @rows = [usp_SPD_ItemMaster_SearchRecords_Vendor] 
		@UserID = @UserID
		, @VendorID = @VendorID
		, @DeptNum = @DeptNum
		, @VendorNumber = @VendorNumber
		, @ClassNo = @ClassNo
		, @SubClassNo = @SubClassNo
		, @VPN = @VPN
		, @UPC = @UPC
		, @SKU = @SKU
		, @ItemDesc = @ItemDesc
		, @StockCat = @StockCat
		, @ItemTypeAttr = @ItemTypeAttr
		, @ItemStatus = @ItemStatus
		, @PackSearch = @PackSearch
		, @PackSKU = @PackSKU
		, @SortCol = @SortCol
		, @SortDir = @SortDir
		, @RowIndex = @RowIndex
		, @MaxRows = @MaxRows
		, @QuoteRefNum = @QuoteRefNum
	Return @rows
END

IF @SKU is not NULL
BEGIN
	Exec @rows = [usp_SPD_ItemMaster_SearchRecords_SKU] 
		@UserID = @UserID
		, @VendorID = @VendorID
		, @DeptNum = @DeptNum
		, @VendorNumber = @VendorNumber
		, @ClassNo = @ClassNo
		, @SubClassNo = @SubClassNo
		, @VPN = @VPN
		, @UPC = @UPC
		, @SKU = @SKU
		, @ItemDesc = @ItemDesc
		, @StockCat = @StockCat
		, @ItemTypeAttr = @ItemTypeAttr
		, @ItemStatus = @ItemStatus
		, @PackSearch = @PackSearch
		, @PackSKU = @PackSKU
		, @SortCol = @SortCol
		, @SortDir = @SortDir
		, @RowIndex = @RowIndex
		, @MaxRows = @MaxRows
		, @QuoteRefNum = @QuoteRefNum
	Return @rows
END

IF @ItemDesc is not NULL
BEGIN
	Exec @rows = [usp_SPD_ItemMaster_SearchRecords_ItemDesc] 
		@UserID = @UserID
		, @VendorID = @VendorID
		, @DeptNum = @DeptNum
		, @VendorNumber = @VendorNumber
		, @ClassNo = @ClassNo
		, @SubClassNo = @SubClassNo
		, @VPN = @VPN
		, @UPC = @UPC
		, @SKU = @SKU
		, @ItemDesc = @ItemDesc
		, @StockCat = @StockCat
		, @ItemTypeAttr = @ItemTypeAttr
		, @ItemStatus = @ItemStatus
		, @PackSearch = @PackSearch
		, @PackSKU = @PackSKU
		, @SortCol = @SortCol
		, @SortDir = @SortDir
		, @RowIndex = @RowIndex
		, @MaxRows = @MaxRows
		, @QuoteRefNum = @QuoteRefNum
	Return @rows
END

-- for D / DP queries
--declare @HybridType varchar(5)
--	, @HybridSourceDC varchar(10)
--	, @DeptNo1 int
--	, @StockCat1 varchar(5)  
--	, @ClassNo1 int
--	, @SubClassNo1 int
--	, @ItemTypeAttr1 varchar(5)
--	, @PackVendorNumber bigint

-- for paging
DECLARE @StartRow int
	, @EndRow int
	, @totalRows int

SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based

IF @MaxRows is NULL
	SET @EndRow = 2147483647	-- Max int size
ELSE
	SET @EndRow = @RowIndex + @MaxRows;
	
-- Get the subset of data Sorted with a RowNumber to Page it	
-- Certain fields just have a place holder to minimize subqueries. NOTE: Can be done on non-sortable fields only
SELECT
	SKU.Michaels_SKU											as SKU
	, SKU.ID													as SKU_ID
	, coalesce(SKU.[Department_Num], 0)							as Dept_No
	, coalesce(D.DEPT_Name,'UNKNOWN DEPARTMENT')				as Dept_Name
	, coalesce(SKU.[Class_Num], 0)								as Class_Num
	, coalesce(SKU.[Sub_Class_Num], 0)							as Sub_Class_Num
	, coalesce(SKU.[Item_Desc],'')								as Item_Desc
	, V.Vendor_Number											as Vendor_Number
	, coalesce(VL.Vendor_Name, 'Unknown Vendor')				as Vendor_Name
	, CASE V.Primary_Indicator WHEN 1 then '*' ELSE '' END		as VPI
	, coalesce(V.Vendor_Style_Num,'')							as Vendor_Style_Num
	, coalesce(UPC.UPC,'Not Defined')							as UPC
	, CASE coalesce(UPC.Primary_Indicator,0) 
		WHEN 1 THEN '*' ELSE '' END								as UPCPI
	, convert(bigint,-1)										as Batch_ID					-- filled in later
	, coalesce(SKU.Stock_Category,'')							as Stock_Category
	, coalesce(SKU.Item_Type_Attribute,'')						as Item_Type_Attribute
	, SKU.Item_Status											as Item_Status
	, dbo.udf_SPD_PackItemLeft2([Item_Type])					as Item_Type
	, 0															as Is_Pack_Parent			-- filled in later
	, 0															as Independent_Editable		-- filled in later
	, convert(varchar(10),'')									as Pack_SKU					-- filled in later
	, case VL.Vendor_Type																	-- since the join is required for this table, get the vendor type now
		WHEN 110 then 1 
		WHEN 300 then 2 
		ELSE 0 END												as Vendor_Type
	, coalesce(SKU.QuoteReferenceNumber, '')					as QuoteReferenceNumber
	,sku.Hybrid_Type 
	,sku.Hybrid_Source_DC
	,CASE WHEN sku.Hybrid_Conversion_Date > '1900-01-01 00:00:00.000' THEN sku.Hybrid_Conversion_Date Else null END as Hybrid_Conversion_Date
	, Row_Number() Over ( ORDER BY
			CASE WHEN @SortCol = 'DeptNo' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptNo' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'DeptName' and @SortDir = 'D' then D.DEPT_Name END DESC,
			CASE WHEN @SortCol = 'DeptName' and @SortDir != 'D' then D.DEPT_Name END,
			CASE WHEN @SortCol = 'SKU' and @SortDir = 'D' then SKU.Michaels_SKU END DESC,
			CASE WHEN @SortCol = 'SKU' and @SortDir != 'D' then SKU.Michaels_SKU END,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir = 'D' then SKU.[Class_Num] END DESC,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir != 'D' then SKU.[Class_Num] END,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir = 'D' then SKU.[Sub_Class_Num] END DESC,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir != 'D' then SKU.[Sub_Class_Num] END,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir = 'D' then SKU.[Item_Desc] END DESC,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir != 'D' then SKU.[Item_Desc] END,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorName' and @SortDir = 'D' then VL.Vendor_Name END DESC,
			CASE WHEN @SortCol = 'VendorName' and @SortDir != 'D' then VL.Vendor_Name END,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir = 'D' then V.Vendor_Style_Num END DESC,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir != 'D' then V.Vendor_Style_Num END,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir = 'D' then SKU.Stock_Category END DESC,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir != 'D' then SKU.Stock_Category END,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir = 'D' then SKU.Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir != 'D' then SKU.Item_Type_Attribute END,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir = 'D' then SKU.Item_Status END DESC,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir != 'D' then SKU.Item_Status END,
			CASE WHEN @SortCol = 'ItemType' and @SortDir = 'D' then [Item_Type] END DESC,
			CASE WHEN @SortCol = 'ItemType' and @SortDir != 'D' then [Item_Type] END,
			CASE WHEN @SortCol = 'UPC' and @SortDir = 'D' then UPC.UPC END DESC,
			CASE WHEN @SortCol = 'UPC' and @SortDir != 'D' then UPC.UPC END,
			CASE WHEN @SortCol = 'HybridType' and @SortDir = 'D' then SKU.Hybrid_Type END DESC,
			CASE WHEN @SortCol = 'HybridType' and @SortDir != 'D' then SKU.Hybrid_Type END,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir = 'D' then SKU.Hybrid_Source_DC END DESC,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir != 'D' then SKU.Hybrid_Source_DC END,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir = 'D' then SKU.Hybrid_Conversion_Date END DESC,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir != 'D' then SKU.Hybrid_Conversion_Date END
			-- Add CASE Pairs as necessary to handle additional sort columns. All have comma's at the end except the last one
		)	as RowNumber
INTO #Results
FROM SPD_Item_Master_SKU					SKU
	join SPD_Item_Master_Vendor				V	on SKU.ID = V.SKU_ID
	left join SPD_Item_Master_Vendor_UPCs	UPC	on V.Michaels_SKU = UPC.Michaels_SKU 
													and V.Vendor_Number = UPC.Vendor_Number
	left join dbo.SPD_Vendor				VL	on V.Vendor_Number = VL.Vendor_Number
	left join SPD_FineLine_Dept				D	on SKU.Department_Num = D.Dept
													and D.[enabled] = 1
WHERE ( ( @ItemStatus is NULL OR SKU.Item_Status = @ItemStatus )
		and ( @DeptNum is NULL OR SKU.Department_Num = @DeptNum )
		and ( @ClassNo is NULL OR SKU.[Class_Num] = @ClassNo )
		and ( @SubClassNo is NULL OR SKU.Sub_Class_Num = @SubClassNo )
		and ( ( @VendorNumber is NULL and V.Primary_Indicator = 1 ) 
			OR V.Vendor_Number = @VendorNumber )
		and ( @SKU is NULL OR SKU.Michaels_SKU = @SKU )
		and ( ( @UPC is NULL and UPC.Primary_Indicator = 1 ) 
			OR ( UPC.UPC = @UPC )
			OR ( UPC.UPC is NULL ) )
		and ( @VPN is NULL OR V.Vendor_Style_Num like ('%' + @VPN + '%') )
		and ( @ItemDesc is NULL OR SKU.Item_Desc like ('%' + @ItemDesc + '%') )
		and ( @StockCat is NULL OR SKU.Stock_Category = @StockCat )
		and ( @ItemTypeAttr is NULL OR SKU.Item_Type_Attribute = @ItemTypeAttr )
		and ( @QuoteRefNum is NULL or SKU.QuoteReferenceNumber like('%'+ @QuoteRefNum +'%'))
	) 
	
SET @totalRows = @@RowCount;	-- Grid needs to know how many total rows there are
--Print 'Total Rows Selected ' + convert(varchar(20),@totalRows)

-- Get the Paged results and update the fields with subquery lookups

--Select * 
--	INTO #SRSubset
--FROM #Results
--WHERE	RowNumber Between @StartRow and @EndRow
--Order By RowNumber asc 

--Print 'Total Rows Selected ' + convert(varchar(20),@@RowCount)
	
SELECT 
	R.SKU	
	, R.SKU_ID 
	, R.Dept_No
	, R.Dept_Name
	, R.Class_Num 
	, R.Sub_Class_Num
	, R.Item_Desc 
	, R.Vendor_Number 
	, R.Vendor_Name 
	, R.VPI 
	, R.Vendor_Style_Num 
	, R.UPC 
	, R.UPCPI 
	, Batch_ID = dbo.udf_SPD_FindBatchID(R.SKU_ID, R.SKU) 
	, R.Stock_Category 
	, R.Item_Type_Attribute 
	, R.Item_Status 
	, R.Item_Type 
	, Is_Pack_Parent = case 
			WHEN dbo.udf_SPD_PackItemLeft2(R.Item_Type) in ('D','DP') 
				THEN 1 
			ELSE 0 end
	, Independent_Editable = case 
			WHEN R.Item_Type = 'C' and Exists( 
				  Select SKU2.[Item_Type] 
				  From SPD_Item_Master_PackItems PKI
					join SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU
														and PKI.Child_SKU = R.SKU
				  Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' 
					and SKU2.Item_Status = 'A' ) 
				 THEN 0
			ELSE 1 end
	, Pack_SKU = coalesce(case
			WHEN R.Item_Type ='C' 
				THEN (  
						Select top 1 PI2.Pack_SKU 
						From SPD_Item_Master_PackItems PI2, SPD_Item_Master_SKU SKU3
						Where PI2.Child_SKU = R.SKU
						and PI2.Pack_SKU = SKU3.Michaels_SKU
						and SKU3.Item_Status = 'A'
						order by dbo.udf_SPD_PackItemLeft2(SKU3.[Item_Type]) desc
					)				
			ELSE '' END
			, '' )
	, R.Vendor_Type 
	, R.QuoteReferenceNumber
	, R.Hybrid_Type
	, R.Hybrid_Source_DC
	, R.Hybrid_Conversion_Date
	
--FROM #SRSubset R
FROM ( 
	Select * 
	FROM #Results
	WHERE	RowNumber Between @StartRow and @EndRow ) as R
	
Print 'Total Rows Selected ' + convert(varchar(20),@@RowCount)

DROP table #Results
--DROP table #SRSubset

RETURN @totalRows

go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==================================================================
Proc:	[usp_SPD_ItemMaster_SearchRecords]
Author:	J. Littlefield
Date:	May 2010
Desc:	Used by Item Maintenance Application. Search for SKU Records and DP Pack Item records
	
Test Code

[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @SKU = '10143822'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @VendorNumber=128
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @SortCol = 'Item_Desc', @SortDir='D', @RowIndex=30, @MaxRows=20 
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ItemDesc = 'Refill'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @VPN = '4'
[usp_SPD_ItemMaster_SearchRecords] @userID=1473, @vendorID=0, @DeptNum = 18, @ClassNo = 81, @SubClassNo=1337

Change Log
FJL 7/28/10 - per KH / MV : comment out special search filters on D / DP
FJL 8/23/10 - Add logic to ensure that Item Type returns first 1 or two chars of the Item Type
FJL 8/25/10 - Add logic to check Batch info from New Item and Item Maint.  Moved to filter table for performance sake
FJL 9/09/10 - Commented out Pack Searches as the Where clause is the same on all 3
JC  2/24/11 - Added support for QuoteReferenceNumber
==================================================================
*/
ALTER Procedure [dbo].[usp_SPD_ItemMaster_SearchRecords_SKU]
	@UserID bigint			-- required
	, @VendorID bigint		-- required
	, @DeptNum  int = null
	, @VendorNumber int = null
	, @ClassNo int = null
	, @SubClassNo int = null
	, @VPN varchar(50) = null
	, @UPC varchar(20) = null
	, @SKU varchar(20) = null
	, @ItemDesc varchar(250) = null
	, @StockCat varchar(10) = null
	, @ItemTypeAttr varchar(10) = null
	, @ItemStatus varchar(1) = null
	, @PackSearch varchar(5) = null
	, @PackSKU varchar(20) = null
	, @SortCol varchar(255) = null
	, @SortDir char(1) = 'A'
	, @RowIndex int = 0
	, @MaxRows int = null	
	, @QuoteRefNum varchar(50) = null
AS

set NOCOUNT on

---- for D / DP queries
--declare @HybridType varchar(5)
--	, @HybridSourceDC varchar(10)
--	, @DeptNo1 int
--	, @StockCat1 varchar(5)  
--	, @ClassNo1 int
--	, @SubClassNo1 int
--	, @ItemTypeAttr1 varchar(5)
--	, @PackVendorNumber bigint

-- for paging
DECLARE @StartRow int
	, @EndRow int
	, @totalRows int

SET @StartRow = @RowIndex + 1;		-- Grid call is zero based but Row_Number() is 1 based

IF @MaxRows is NULL
	SET @EndRow = 2147483647	-- Max int size
ELSE
	SET @EndRow = @RowIndex + @MaxRows;

	
-- Get the subset of data Sorted with a RowNumber to Page it	
-- Certain fields just have a place holder to minimize subqueries. NOTE: Can be done on non-sortable fields only
SELECT
	SKU.Michaels_SKU											as SKU
	, SKU.ID													as SKU_ID
	, coalesce(SKU.[Department_Num], 0)							as Dept_No
	, coalesce(D.DEPT_Name,'UNKNOWN DEPARTMENT')				as Dept_Name
	, coalesce(SKU.[Class_Num], 0)								as Class_Num
	, coalesce(SKU.[Sub_Class_Num], 0)							as Sub_Class_Num
	, coalesce(SKU.[Item_Desc],'')								as Item_Desc
	, V.Vendor_Number											as Vendor_Number
	, coalesce(VL.Vendor_Name, 'Unknown Vendor')				as Vendor_Name
	, case V.Primary_Indicator WHEN 1 then '*' ELSE '' end		as VPI
	, coalesce(V.Vendor_Style_Num,'')							as Vendor_Style_Num
	, coalesce(UPC.UPC,'Not Defined')							as UPC
	, CASE coalesce(UPC.Primary_Indicator,0) 
		WHEN 1 THEN '*' ELSE '' END								as UPCPI
	, convert(bigint,-1)										as Batch_ID					-- filled in later
	, coalesce(SKU.Stock_Category,'')							as Stock_Category
	, coalesce(SKU.Item_Type_Attribute,'')						as Item_Type_Attribute
	, SKU.Item_Status											as Item_Status
	, dbo.udf_SPD_PackItemLeft2([Item_Type])					as Item_Type
	, 0															as Is_Pack_Parent			-- filled in later
	, 0															as Independent_Editable		-- filled in later
	, convert(varchar(10),'')									as Pack_SKU					-- filled in later
	, case VL.Vendor_Type																	-- since the join is required for this table, get the vendor type now
		WHEN 110 then 1 
		WHEN 300 then 2 
		ELSE 0 END												as Vendor_Type
	, coalesce(SKU.QuoteReferenceNumber, '')					as QuoteReferenceNumber
	,sku.Hybrid_Type 
	,sku.Hybrid_Source_DC
	,CASE WHEN sku.Hybrid_Conversion_Date > '1900-01-01 00:00:00.000' THEN sku.Hybrid_Conversion_Date Else null END as Hybrid_Conversion_Date
	, Row_Number() Over ( ORDER BY
			CASE WHEN @SortCol = 'DeptNo' and @SortDir = 'D' then SKU.[Department_Num] END DESC,
			CASE WHEN @SortCol = 'DeptNo' and @SortDir != 'D' then SKU.[Department_Num] END,
			CASE WHEN @SortCol = 'DeptName' and @SortDir = 'D' then D.DEPT_Name END DESC,
			CASE WHEN @SortCol = 'DeptName' and @SortDir != 'D' then D.DEPT_Name END,
			CASE WHEN @SortCol = 'SKU' and @SortDir = 'D' then SKU.Michaels_SKU END DESC,
			CASE WHEN @SortCol = 'SKU' and @SortDir != 'D' then SKU.Michaels_SKU END,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir = 'D' then SKU.[Class_Num] END DESC,
			CASE WHEN @SortCol = 'ClassNum' and @SortDir != 'D' then SKU.[Class_Num] END,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir = 'D' then SKU.[Sub_Class_Num] END DESC,
			CASE WHEN @SortCol = 'SubClassNum' and @SortDir != 'D' then SKU.[Sub_Class_Num] END,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir = 'D' then SKU.[Item_Desc] END DESC,
			CASE WHEN @SortCol = 'ItemDesc' and @SortDir != 'D' then SKU.[Item_Desc] END,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir = 'D' then V.Vendor_Number END DESC,
			CASE WHEN @SortCol = 'VendorNumber' and @SortDir != 'D' then V.Vendor_Number END,
			CASE WHEN @SortCol = 'VendorName' and @SortDir = 'D' then VL.Vendor_Name END DESC,
			CASE WHEN @SortCol = 'VendorName' and @SortDir != 'D' then VL.Vendor_Name END,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir = 'D' then V.Vendor_Style_Num END DESC,
			CASE WHEN @SortCol = 'VendorStyleNum' and @SortDir != 'D' then V.Vendor_Style_Num END,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir = 'D' then SKU.Stock_Category END DESC,
			CASE WHEN @SortCol = 'StockCategory' and @SortDir != 'D' then SKU.Stock_Category END,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir = 'D' then SKU.Item_Type_Attribute END DESC,
			CASE WHEN @SortCol = 'ItemTypeAttribute' and @SortDir != 'D' then SKU.Item_Type_Attribute END,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir = 'D' then SKU.Item_Status END DESC,
			CASE WHEN @SortCol = 'ItemStatus' and @SortDir != 'D' then SKU.Item_Status END,
			CASE WHEN @SortCol = 'ItemType' and @SortDir = 'D' then [Item_Type] END DESC,
			CASE WHEN @SortCol = 'ItemType' and @SortDir != 'D' then [Item_Type] END,
			CASE WHEN @SortCol = 'UPC' and @SortDir = 'D' then UPC.UPC END DESC,
			CASE WHEN @SortCol = 'UPC' and @SortDir != 'D' then UPC.UPC END,
			CASE WHEN @SortCol = 'HybridType' and @SortDir = 'D' then SKU.Hybrid_Type END DESC,
			CASE WHEN @SortCol = 'HybridType' and @SortDir != 'D' then SKU.Hybrid_Type END,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir = 'D' then SKU.Hybrid_Source_DC END DESC,
			CASE WHEN @SortCol = 'HybridSourceDC' and @SortDir != 'D' then SKU.Hybrid_Source_DC END,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir = 'D' then SKU.Hybrid_Conversion_Date END DESC,
			CASE WHEN @SortCol = 'ConversionDate' and @SortDir != 'D' then SKU.Hybrid_Conversion_Date END
			-- Add CASE Pairs as necessary to handle additional sort columns. All have comma's at the end except the last one
		)														as RowNumber
INTO #Results
FROM SPD_Item_Master_SKU					SKU
	join SPD_Item_Master_Vendor				V	on SKU.ID = V.SKU_ID
	left join SPD_Item_Master_Vendor_UPCs	UPC	on V.Michaels_SKU = UPC.Michaels_SKU 
													and V.Vendor_Number = UPC.Vendor_Number
	left join dbo.SPD_Vendor				VL	on V.Vendor_Number = VL.Vendor_Number
	left join SPD_FineLine_Dept				D	on SKU.Department_Num = D.Dept
													and D.[enabled] = 1
WHERE ( SKU.Michaels_SKU = @SKU
		and ( @ItemStatus is NULL OR SKU.Item_Status = @ItemStatus )
		and ( @DeptNum is NULL OR SKU.Department_Num = @DeptNum )
		and ( @ClassNo is NULL OR SKU.[Class_Num] = @ClassNo )
		and ( @SubClassNo is NULL OR SKU.Sub_Class_Num = @SubClassNo )
		and ( ( @VendorNumber is NULL and V.Primary_Indicator = 1 ) 
			OR V.Vendor_Number = @VendorNumber )
		and ( ( @UPC is NULL and UPC.Primary_Indicator = 1 ) 
			OR ( UPC.UPC = @UPC )
			OR ( UPC.UPC is NULL ) )
		and ( @VPN is NULL OR V.Vendor_Style_Num like ('%' + @VPN + '%') )
		and ( @ItemDesc is NULL OR SKU.Item_Desc like ('%' + @ItemDesc + '%') )
		and ( @StockCat is NULL OR SKU.Stock_Category = @StockCat )
		and ( @ItemTypeAttr is NULL OR SKU.Item_Type_Attribute = @ItemTypeAttr )
		and ( @QuoteRefNum is NULL OR SKU.QuoteReferenceNumber like('%'+ @QuoteRefNum +'%'))
	) 
	
SET @totalRows = @@RowCount;	-- Grid needs to know how many total rows there are
--Print 'Total Rows Selected ' + convert(varchar(20),@totalRows)

-- Get the Paged results and update the fields with subquery lookups
SELECT R.SKU	
	, R.SKU_ID 
	, R.Dept_No
	, R.Dept_Name
	, R.Class_Num 
	, R.Sub_Class_Num
	, R.Item_Desc 
	, R.Vendor_Number 
	, R.Vendor_Name 
	, R.VPI 
	, R.Vendor_Style_Num 
	, R.UPC 
	, R.UPCPI 
	, Batch_ID =  dbo.udf_SPD_FindBatchID(R.SKU_ID, R.SKU) 
	, R.Stock_Category 
	, R.Item_Type_Attribute 
	, R.Item_Status 
	, R.Item_Type 
	, Is_Pack_Parent = case 
			WHEN dbo.udf_SPD_PackItemLeft2(R.Item_Type) in ('D','DP') 
				THEN 1 
			ELSE 0 END
	, Independent_Editable = case 
			WHEN R.Item_Type = 'C' and Exists( 
				  Select SKU2.[Item_Type] 
				  From SPD_Item_Master_PackItems PKI
					join SPD_Item_Master_SKU SKU2	on PKI.Pack_SKU = SKU2.Michaels_SKU
														and PKI.Child_SKU = R.SKU
				  Where dbo.udf_SPD_PackItemLeft2(SKU2.[Item_Type]) = 'DP' 
					and SKU2.Item_Status = 'A' ) 
				 THEN 0
			ELSE 1 END
	, Pack_SKU = coalesce(case
			WHEN R.Item_Type ='C' 
				THEN (  
						Select top 1 PI2.Pack_SKU 
						From SPD_Item_Master_PackItems PI2, SPD_Item_Master_SKU SKU3
						Where PI2.Child_SKU = R.SKU
						and PI2.Pack_SKU = SKU3.Michaels_SKU
						and SKU3.Item_Status = 'A'
						order by dbo.udf_SPD_PackItemLeft2(SKU3.[Item_Type]) desc
					)				
			ELSE '' END
			, '' )
	, R.Vendor_Type 
	, R.QuoteReferenceNumber
	, R.Hybrid_Type
	, R.Hybrid_Source_DC
	, R.Hybrid_Conversion_Date 
FROM ( 
	Select *
	From #Results
	WHERE RowNumber Between @StartRow and @EndRow ) as R
Order By R.RowNumber asc

--Print 'Total Rows Selected ' + convert(varchar(20),@@RowCount)

DROP table #Results

RETURN @totalRows

go
