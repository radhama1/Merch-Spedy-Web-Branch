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



ALTER  PROCEDURE [dbo].[usp_SPD_TrilingualMaint_GetList]
  @xmlSortCriteria varchar(max) = NULL,
  @maxRows int = -1,
  @startRow int = 0,
  @printDebugMsgs bit = 0,
  @UserID int = 0
AS
  SET NOCOUNT ON
  
  DECLARE @intPageNo int
  DECLARE @intSkippedRows int
  DECLARE @intXMLDocHandle int
  DECLARE @strXMLDoc varchar(max)
  DECLARE @intTempFilterCol int
  DECLARE @strTempFilterCriteria varchar(500)
  DECLARE @intTempSortCol int
  DECLARE @intTempSortDir int
  DECLARE @strTempSortDir varchar(4)
  DECLARE @strFields varchar(max)
  DECLARE @strPK varchar(100)
  DECLARE @strTables varchar(max)
  DECLARE @intPageSize int
  DECLARE @blnGetRecordCount bit
  DECLARE @blnUseFT bit 
  DECLARE @strFTColumn varchar(max)
  DECLARE @strFTFilter varchar(max)
  DECLARE @strFilter varchar(max)
  DECLARE @strSortCols varchar(max)
  DECLARE @strSort varchar(max)
  DECLARE @strGroup varchar(max)
  DECLARE @firstIndex int, @lastIndex int, @totalLength int
  DECLARE @blnUseACT bit, @strServerDBName varchar(250), @strCategoryIDs varchar(1000)
  DECLARE @blnUseSupplierFT bit, @strSupplierFTColumn varchar(8000), @strSupplierFTFilter varchar(8000)
  DECLARE @blnUseDescriptionFT bit, @strDescriptionFTColumn varchar(8000), @strDescriptionFTFilter varchar(8000)
  DECLARE @blnUseGroup bit, @strUseGroupTemp varchar(1), @strUseGroup varchar(8000)
  DECLARE @endRow int
  
  SET @endRow = @startRow + @maxRows - 1
  SET @strXMLDoc = @xmlSortCriteria
  EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc

  IF (@maxRows = 0) 
    SET @intPageNo = CEILING(CONVERT(float, @startRow)/CONVERT(float, 1))
  ELSE
    SET @intPageNo = CEILING(CONVERT(float, @startRow)/CONVERT(float, COALESCE(@maxRows, 1)))

  SET @intSkippedRows = @maxRows * (@intPageNo - 1)
  SET @blnUseACT = 0
  SET @blnUseFT = 0
  SET @blnUseSupplierFT = 0
  SET @blnUseDescriptionFT = 0
  SET @blnUseGroup = 0
  SET @strFTColumn = ''
  SET @strSupplierFTColumn = ''
  SET @strDescriptionFTColumn = ''
  SET @strUseGroupTemp = ''
  SET @strFTFilter = ''
  SET @strSupplierFTFilter = ''
  SET @strDescriptionFTFilter = ''
  SET @strUseGroup = ''
  SET @strPK = 'imi.[ID]'

/*=================================================================================================
  Set Appropriate Flags Used For Table Joins
  =================================================================================================*/
  --Declare @FindBatchContainingSearchID int
  --Declare @FindBatchContainingSearchString varchar(max)
  
  --Set @FindBatchContainingSearchID = 0
  --Set @FindBatchContainingSearchString = ''
  
  --DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
  --  SELECT FilterCol, FilterCriteria
  --  FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter') 
  --  WITH
  --  (
  --    FilterID int '@FilterID',
  --    FilterCol int '@intColOrdinal',
  --    FilterCriteria varchar(1000) 'text()'
  --  )
  --  ORDER BY FilterID

  --OPEN myCursor
  --FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  --WHILE @@FETCH_STATUS = 0
  --BEGIN
    
  --  --Filter ID: 1 - Used For 'Find Batch Containing'
  --  IF @intTempFilterCol = 1
  --  BEGIN
		--IF (CASE
		--		WHEN ISNUMERIC(@strTempFilterCriteria) = 0											THEN 0
		--		WHEN @strTempFilterCriteria LIKE '%[^0-9]%'											THEN 0
		--		WHEN CAST(@strTempFilterCriteria AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 9999999999.	THEN 0	--2147483647
		--		ELSE 1
		--	END ) = 0
		--	SET @FindBatchContainingSearchString = @strTempFilterCriteria
		--ELSE
		--	SET @FindBatchContainingSearchID = @strTempFilterCriteria
  --  END

  --  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  --END
  --CLOSE myCursor
  --DEALLOCATE myCursor
  
  /*=================================================================================================
  Set fields to be returned (SELECT statement)
  =================================================================================================*/
  SET @strFields = '
	imi.ID, imi.Michaels_SKU, imi.Vendor_Number, imi.is_Valid, v.Vendor_Name, 
	CASE WHEN v.Vendor_Type = ''110'' Then ''Domestic'' Else ''Import'' End as Item_Type,
	imv.Vendor_Style_Num, s.Item_Desc, s.Item_Status, s.Department_Num, s.Class_Num, s.Sub_Class_Num, s.SKU_Group, s.Item_Type as Pack_Item_Indicator,
	u.UDA_Value AS Private_Brand_Label,
	simlE.Description_Long as ''English_Long_Description'', simlE.Description_Short as ''English_Short_Description'', 
	simlF.Description_Long as ''French_Long_Description'', simlF.Description_Short as ''French_Short_Description'',
	simlS.Description_Long as ''Spanish_Long_Description'', simlS.Description_Short as ''Spanish_Short_Description'', 
	simlF.Translation_Indicator as ''TI_French'',
	simlES.Package_Language_Indicator as ''PLI_English'',
	simlFS.Package_Language_Indicator as ''PLI_French'',
	simlSS.Package_Language_Indicator as ''PLI_Spanish'',
	COALESCE(simlFS.Exempt_End_Date,'''') as ''Exempt_End_Date_French''
'

  /*=================================================================================================
  Set tables to be accessed (FROM statement)
  =================================================================================================*/
  --SET @strTables = 'SPD_Batch b WITH (NOLOCK)'
  SET @strTables = ' SPD_Item_Maint_Items as imi
		INNER JOIN SPD_Item_Master_SKU as s on s.Michaels_SKU = imi.Michaels_SKU
		LEFT JOIN SPD_Item_Master_Vendor as imv on imv.Vendor_Number = imi.Vendor_Number and imv.Michaels_SKU = imi.Michaels_SKU
		LEFT JOIN SPD_Vendor as v on v.Vendor_Number = imi.Vendor_Number
		LEFT JOIN SPD_Item_Master_Languages as simlE on simlE.Michaels_SKU = imi.Michaels_SKU and simlE.Language_Type_ID = 1
		LEFT JOIN SPD_Item_Master_Languages as simlF on simlF.Michaels_SKU = imi.Michaels_SKU and simlF.Language_Type_ID = 2
		LEFT JOIN SPD_Item_Master_Languages as simlS on simlS.Michaels_SKU = imi.Michaels_SKU and simlS.Language_Type_ID = 3
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlES on simlES.Michaels_SKU = imi.Michaels_SKU and simlES.Vendor_Number = imi.Vendor_Number and simlES.Language_Type_ID = 1
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlFS on simlFS.Michaels_SKU = imi.Michaels_SKU and simlFS.Vendor_Number = imi.Vendor_Number and simlFS.Language_Type_ID = 2
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlSS on simlSS.Michaels_SKU = imi.Michaels_SKU and simlSS.Vendor_Number = imi.Vendor_Number and simlSS.Language_Type_ID = 3
		LEFT JOIN SPD_Item_Master_UDA AS U on u.Michaels_SKU = imi.Michaels_SKU AND u.UDA_ID = 11
  '

  SET @intPageSize = @maxRows
  SET @blnGetRecordCount = 1
  
  --Filer on Batch Type
  SET @strFilter = ''

  /*=================================================================================================
  Set filter parameters (WHERE clause)
  =================================================================================================*/
  DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
    SELECT FilterCol, FilterCriteria
    FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter') 
    WITH
    (
      FilterID int '@FilterID',
      FilterCol int '@intColOrdinal',
      FilterCriteria varchar(1000) 'text()'
    )
    ORDER BY FilterID

  OPEN myCursor
  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF (LEN(@strFilter) > 0) SET @strFilter = @strFilter + ' AND '
    SET @strFilter = @strFilter + 
    (CASE @intTempFilterCol
		WHEN -1 THEN ' imi.Batch_ID = ' + @strTempFilterCriteria
		
		---------------------
		--Search Filters
		---------------------
		WHEN 51 THEN ' ' + @strTempFilterCriteria + ''

      ELSE '1=1'
    END)

    FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  END
  CLOSE myCursor
  DEALLOCATE myCursor


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
      WHEN 0 THEN ' imi.Michaels_SKU ' + @strTempSortDir
      WHEN 1 THEN ' imi.Vendor_Number ' + @strTempSortDir
      WHEN 2 THEN ' v.Vendor_Name ' + @strTempSortDir
      WHEN 3 THEN ' v.Vendor_type ' + @strTempSortDir
      WHEN 4 THEN ' imv.Vendor_Style_Num ' + @strTempSortDir
      WHEN 5 THEN ' s.Item_Desc ' + @strTempSortDir
      WHEN 6 THEN ' s.Item_Status ' + @strTempSortDir
      WHEN 7 THEN ' s.Department_Num ' + @strTempSortDir
      WHEN 8 THEN ' s.Class_Num ' + @strTempSortDir
      WHEN 9 THEN ' s.Sub_Class_Num ' + @strTempSortDir
      WHEN 10 THEN ' s.SKU_Group ' + @strTempSortDir
      WHEN 11 THEN ' u.UDA_Value ' + @strTempSortDir
      WHEN 12 THEN ' simlEs.Package_Language_Indicator ' + @strTempSortDir --PLI English
      WHEN 13 THEN ' simlFs.Package_Language_Indicator ' + @strTempSortDir --PLI French
      WHEN 14 THEN ' simlSs.Package_Language_Indicator ' + @strTempSortDir --PLI Spanish
      WHEN 15 THEN ' simlF.Translation_Indicator ' + @strTempSortDir 
      WHEN 16 THEN ' simlE.Description_Short ' + @strTempSortDir
      WHEN 17 THEN ' simlE.Description_Long ' + @strTempSortDir
      WHEN 18 THEN ' simlF.Description_Short ' + @strTempSortDir
      WHEN 19 THEN ' simlF.Description_Short ' + @strTempSortDir
      WHEN 20 THEN ' simlS.Description_Short ' + @strTempSortDir
      WHEN 21 THEN ' simlS.Description_Short ' + @strTempSortDir
      WHEN 23 THEN 'CASE Is_Valid WHEN - 1 THEN ''unknown'' WHEN 0 THEN ''no'' WHEN 1 THEN ''yes'' ELSE ''xxx'' END ' + @strTempSortDir
      --WHEN 22 THEN ' ' + @@strTempSortDir	--EXEMPT END DATE (FRENCH)
      ELSE ''
    END)
    FETCH NEXT FROM myCursor INTO @intTempSortCol, @intTempSortDir
  END
  CLOSE myCursor
  DEALLOCATE myCursor
  
  SET @strSort = REPLACE(@strSort, ',,', '')

  /*=================================================================================================
  Set grouping parameters (GROUP BY clause)
  =================================================================================================*/
  SET @strGroup = ''


  /*=================================================================================================
  Run it!
  =================================================================================================*/

  EXEC sys_returnPagedData_usingWith
	'',
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


ALTER  PROCEDURE [dbo].[usp_SPD_GetBIMBatches]
  @xmlSortCriteria varchar(max) = NULL,
  @maxRows int = -1,
  @startRow int = 0,
  @printDebugMsgs bit = 0,
  @UserID int = 0
AS
  SET NOCOUNT ON
  
  DECLARE @intPageNo int
  DECLARE @intSkippedRows int
  DECLARE @intXMLDocHandle int
  DECLARE @strXMLDoc varchar(max)
  DECLARE @intTempFilterCol int
  DECLARE @strTempFilterCriteria varchar(500)
  DECLARE @intTempSortCol int
  DECLARE @intTempSortDir int
  DECLARE @strTempSortDir varchar(4)
  DECLARE @strFields varchar(max)
  DECLARE @strPK varchar(100)
  DECLARE @strTables varchar(max)
  DECLARE @intPageSize int
  DECLARE @blnGetRecordCount bit
  DECLARE @blnUseFT bit 
  DECLARE @strFTColumn varchar(max)
  DECLARE @strFTFilter varchar(max)
  DECLARE @strFilter varchar(max)
  DECLARE @strSortCols varchar(max)
  DECLARE @strSort varchar(max)
  DECLARE @strGroup varchar(max)
  DECLARE @firstIndex int, @lastIndex int, @totalLength int
  DECLARE @blnUseACT bit, @strServerDBName varchar(250), @strCategoryIDs varchar(1000)
  DECLARE @blnUseSupplierFT bit, @strSupplierFTColumn varchar(8000), @strSupplierFTFilter varchar(8000)
  DECLARE @blnUseDescriptionFT bit, @strDescriptionFTColumn varchar(8000), @strDescriptionFTFilter varchar(8000)
  DECLARE @blnUseGroup bit, @strUseGroupTemp varchar(1), @strUseGroup varchar(8000)
  DECLARE @endRow int
  
  SET @endRow = @startRow + @maxRows - 1
  SET @strXMLDoc = @xmlSortCriteria
  EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc

  IF (@maxRows = 0) 
    SET @intPageNo = CEILING(CONVERT(float, @startRow)/CONVERT(float, 1))
  ELSE
    SET @intPageNo = CEILING(CONVERT(float, @startRow)/CONVERT(float, COALESCE(@maxRows, 1)))

  SET @intSkippedRows = @maxRows * (@intPageNo - 1)
  SET @blnUseACT = 0
  SET @blnUseFT = 0
  SET @blnUseSupplierFT = 0
  SET @blnUseDescriptionFT = 0
  SET @blnUseGroup = 0
  SET @strFTColumn = ''
  SET @strSupplierFTColumn = ''
  SET @strDescriptionFTColumn = ''
  SET @strUseGroupTemp = ''
  SET @strFTFilter = ''
  SET @strSupplierFTFilter = ''
  SET @strDescriptionFTFilter = ''
  SET @strUseGroup = ''
  SET @strPK = 'b.[ID]'

/*=================================================================================================
  Set Appropriate Flags Used For Table Joins
  =================================================================================================*/
  --Declare @FindBatchContainingSearchID int
  --Declare @FindBatchContainingSearchString varchar(max)
  
  --Set @FindBatchContainingSearchID = 0
  --Set @FindBatchContainingSearchString = ''
  
  --DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
  --  SELECT FilterCol, FilterCriteria
  --  FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter') 
  --  WITH
  --  (
  --    FilterID int '@FilterID',
  --    FilterCol int '@intColOrdinal',
  --    FilterCriteria varchar(1000) 'text()'
  --  )
  --  ORDER BY FilterID

  --OPEN myCursor
  --FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  --WHILE @@FETCH_STATUS = 0
  --BEGIN
    
  --  --Filter ID: 1 - Used For 'Find Batch Containing'
  --  IF @intTempFilterCol = 1
  --  BEGIN
		--IF (CASE
		--		WHEN ISNUMERIC(@strTempFilterCriteria) = 0											THEN 0
		--		WHEN @strTempFilterCriteria LIKE '%[^0-9]%'											THEN 0
		--		WHEN CAST(@strTempFilterCriteria AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 9999999999.	THEN 0	--2147483647
		--		ELSE 1
		--	END ) = 0
		--	SET @FindBatchContainingSearchString = @strTempFilterCriteria
		--ELSE
		--	SET @FindBatchContainingSearchID = @strTempFilterCriteria
  --  END

  --  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  --END
  --CLOSE myCursor
  --DEALLOCATE myCursor
  
  /*=================================================================================================
  Set fields to be returned (SELECT statement)
  =================================================================================================*/
  SET @strFields = '
	b.*,
	bt.Batch_Type_Desc,
	(SELECT top (1) COALESCE (ssu.first_name, '''') + '' '' + COALESCE (ssu.last_name, '''') + COALESCE ('' (x'' + ssu.office_location + '')'', '''')
			FROM security_user ssu 
			INNER JOIN spd_workflow_primary_approver swpa ON swpa.security_user_id = ssu.id 
			INNER JOIN spd_workflow_stage sws ON swpa.security_group_id = sws.primary_approval_group_id 
			WHERE sws.ID = B.Workflow_Stage_ID AND swpa.spd_workflow_id = WS.Workflow_ID AND ssu.[enabled] = 1) AS Approval_Name,
	Coalesce(ic.Item_Count, 0) As Item_Count,
	Coalesce(c.First_Name + '' '', '''') + Coalesce(c.Last_Name, '''') As Created_By,
	Coalesce(m.First_Name + '' '', '''') + Coalesce(m.Last_Name, '''') As Modified_By,
	ws.Stage_Name,
	ws.Stage_Type_ID,
	CASE Is_Valid WHEN - 1 THEN ''unknown'' WHEN 0 THEN ''no'' WHEN 1 THEN ''yes'' ELSE ''xxx'' END AS SortValid
	
'

  /*=================================================================================================
  Set tables to be accessed (FROM statement)
  =================================================================================================*/
  --SET @strTables = 'SPD_Batch b WITH (NOLOCK)'
  SET @strTables = 'SPD_Batch as b
		INNER JOIN SPD_Batch_Types as bt on b.Batch_Type_ID = bt.ID
		Left Join Security_User c On c.ID = b.Created_User
		Left Join Security_User m On m.ID = b.Modified_User
		Left Join SPD_Workflow_Stage as ws on ws.ID = b.Workflow_Stage_ID
		Left Join (Select Batch_ID, Count(Michaels_SKU) As Item_Count
			From SPD_Item_Maint_Items
			Group By Batch_ID) ic On ic.Batch_ID= b.ID	
  '

  SET @intPageSize = @maxRows
  SET @blnGetRecordCount = 1
  
  --Filer on Batch Type
  SET @strFilter = ' b.Batch_Type_ID in (5) '

  /*=================================================================================================
  Set filter parameters (WHERE clause)
  =================================================================================================*/
  DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
    SELECT FilterCol, FilterCriteria
    FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter') 
    WITH
    (
      FilterID int '@FilterID',
      FilterCol int '@intColOrdinal',
      FilterCriteria varchar(1000) 'text()'
    )
    ORDER BY FilterID

  OPEN myCursor
  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF (LEN(@strFilter) > 0) SET @strFilter = @strFilter + ' AND '
    SET @strFilter = @strFilter + 
    (CASE @intTempFilterCol
		WHEN -4 THEN ' b.Enabled = 1 AND ws.Stage_Type_ID =  ' + @strTempFilterCriteria
		WHEN -3 THEN ' b.Enabled = 0 ' --Deleted Batches
		WHEN -1 THEN ' b.Enabled = 1 AND ws.Stage_Name <> ''Completed''' --All Stages except Completed
		
		WHEN 3 THEN ' b.Enabled = 1 AND b.Workflow_Stage_ID = ' + @strTempFilterCriteria	
		WHEN 4 THEN ' b.Batch_Type_ID = ' + @strTempFilterCriteria
		
		---------------------
		--Search Filters
		---------------------
		WHEN 51 THEN ' (b.ID = ' + @strTempFilterCriteria + ' OR Exists(
			Select 1
			From SPD_Item_Maint_Items as simi
			WHERE simi.Batch_ID = b.ID and simi.Michaels_SKU = ''' +  @strTempFilterCriteria + ''') )'
			
      ELSE '1=1'
    END)

    FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  END
  CLOSE myCursor
  DEALLOCATE myCursor


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
      WHEN 0 THEN 'b.ID ' + @strTempSortDir
      WHEN 1 THEN 'ic.Item_Count ' + @strTempSortDir
      WHEN 2 THEN 'CASE Is_Valid WHEN - 1 THEN ''unknown'' WHEN 0 THEN ''no'' WHEN 1 THEN ''yes'' ELSE ''xxx'' END ' + @strTempSortDir
      WHEN 3 THEN 'ws.Stage_Name ' + @strTempSortDir
      WHEN 4 THEN 'Coalesce(c.First_Name + '' '', '''') + Coalesce(c.Last_Name, '''') ' + @strTempSortDir
      WHEN 5 THEN 'b.Date_Created ' + @strTempSortDir
      WHEN 6 THEN 'b.Date_Modified ' + @strTempSortDir
      ELSE ''
    END)
    FETCH NEXT FROM myCursor INTO @intTempSortCol, @intTempSortDir
  END
  CLOSE myCursor
  DEALLOCATE myCursor
  
  SET @strSort = REPLACE(@strSort, ',,', '')

  /*=================================================================================================
  Set grouping parameters (GROUP BY clause)
  =================================================================================================*/
  SET @strGroup = ''


  /*=================================================================================================
  Run it!
  =================================================================================================*/

  EXEC sys_returnPagedData_usingWith
	'',
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



ALTER  PROCEDURE [dbo].[usp_SPD_GetTMBatches]
  @xmlSortCriteria varchar(max) = NULL,
  @maxRows int = -1,
  @startRow int = 0,
  @printDebugMsgs bit = 0,
  @UserID int = 0
AS
  SET NOCOUNT ON
  
  DECLARE @intPageNo int
  DECLARE @intSkippedRows int
  DECLARE @intXMLDocHandle int
  DECLARE @strXMLDoc varchar(max)
  DECLARE @intTempFilterCol int
  DECLARE @strTempFilterCriteria varchar(500)
  DECLARE @intTempSortCol int
  DECLARE @intTempSortDir int
  DECLARE @strTempSortDir varchar(4)
  DECLARE @strFields varchar(max)
  DECLARE @strPK varchar(100)
  DECLARE @strTables varchar(max)
  DECLARE @intPageSize int
  DECLARE @blnGetRecordCount bit
  DECLARE @blnUseFT bit 
  DECLARE @strFTColumn varchar(max)
  DECLARE @strFTFilter varchar(max)
  DECLARE @strFilter varchar(max)
  DECLARE @strSortCols varchar(max)
  DECLARE @strSort varchar(max)
  DECLARE @strGroup varchar(max)
  DECLARE @firstIndex int, @lastIndex int, @totalLength int
  DECLARE @blnUseACT bit, @strServerDBName varchar(250), @strCategoryIDs varchar(1000)
  DECLARE @blnUseSupplierFT bit, @strSupplierFTColumn varchar(8000), @strSupplierFTFilter varchar(8000)
  DECLARE @blnUseDescriptionFT bit, @strDescriptionFTColumn varchar(8000), @strDescriptionFTFilter varchar(8000)
  DECLARE @blnUseGroup bit, @strUseGroupTemp varchar(1), @strUseGroup varchar(8000)
  DECLARE @endRow int
  
  SET @endRow = @startRow + @maxRows - 1
  SET @strXMLDoc = @xmlSortCriteria
  EXEC sp_xml_preparedocument @intXMLDocHandle OUTPUT, @strXMLDoc

  IF (@maxRows = 0) 
    SET @intPageNo = CEILING(CONVERT(float, @startRow)/CONVERT(float, 1))
  ELSE
    SET @intPageNo = CEILING(CONVERT(float, @startRow)/CONVERT(float, COALESCE(@maxRows, 1)))

  SET @intSkippedRows = @maxRows * (@intPageNo - 1)
  SET @blnUseACT = 0
  SET @blnUseFT = 0
  SET @blnUseSupplierFT = 0
  SET @blnUseDescriptionFT = 0
  SET @blnUseGroup = 0
  SET @strFTColumn = ''
  SET @strSupplierFTColumn = ''
  SET @strDescriptionFTColumn = ''
  SET @strUseGroupTemp = ''
  SET @strFTFilter = ''
  SET @strSupplierFTFilter = ''
  SET @strDescriptionFTFilter = ''
  SET @strUseGroup = ''
  SET @strPK = 'b.[ID]'

/*=================================================================================================
  Set Appropriate Flags Used For Table Joins
  =================================================================================================*/
  --Declare @FindBatchContainingSearchID int
  --Declare @FindBatchContainingSearchString varchar(max)
  
  --Set @FindBatchContainingSearchID = 0
  --Set @FindBatchContainingSearchString = ''
  
  --DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
  --  SELECT FilterCol, FilterCriteria
  --  FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter') 
  --  WITH
  --  (
  --    FilterID int '@FilterID',
  --    FilterCol int '@intColOrdinal',
  --    FilterCriteria varchar(1000) 'text()'
  --  )
  --  ORDER BY FilterID

  --OPEN myCursor
  --FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  --WHILE @@FETCH_STATUS = 0
  --BEGIN
    
  --  --Filter ID: 1 - Used For 'Find Batch Containing'
  --  IF @intTempFilterCol = 1
  --  BEGIN
		--IF (CASE
		--		WHEN ISNUMERIC(@strTempFilterCriteria) = 0											THEN 0
		--		WHEN @strTempFilterCriteria LIKE '%[^0-9]%'											THEN 0
		--		WHEN CAST(@strTempFilterCriteria AS NUMERIC(38, 0)) NOT BETWEEN 1. AND 9999999999.	THEN 0	--2147483647
		--		ELSE 1
		--	END ) = 0
		--	SET @FindBatchContainingSearchString = @strTempFilterCriteria
		--ELSE
		--	SET @FindBatchContainingSearchID = @strTempFilterCriteria
  --  END

  --  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  --END
  --CLOSE myCursor
  --DEALLOCATE myCursor
  
  /*=================================================================================================
  Set fields to be returned (SELECT statement)
  =================================================================================================*/
  SET @strFields = '
	b.*,
	bt.Batch_Type_Desc,
	(SELECT top (1) COALESCE (ssu.first_name, '''') + '' '' + COALESCE (ssu.last_name, '''') + COALESCE ('' (x'' + ssu.office_location + '')'', '''')
			FROM security_user ssu 
			INNER JOIN spd_workflow_primary_approver swpa ON swpa.security_user_id = ssu.id 
			INNER JOIN spd_workflow_stage sws ON swpa.security_group_id = sws.primary_approval_group_id 
			WHERE sws.ID = B.Workflow_Stage_ID AND swpa.spd_workflow_id = WS.Workflow_ID AND ssu.[enabled] = 1) AS Approval_Name,
	Coalesce(ic.Item_Count, 0) As Item_Count,
	Coalesce(c.First_Name + '' '', '''') + Coalesce(c.Last_Name, '''') As Created_By,
	Coalesce(m.First_Name + '' '', '''') + Coalesce(m.Last_Name, '''') As Modified_By,
	ws.Stage_Name,
	ws.Stage_Type_ID,
	CASE Is_Valid WHEN - 1 THEN ''unknown'' WHEN 0 THEN ''no'' WHEN 1 THEN ''yes'' ELSE ''xxx'' END AS SortValid
	
'

  /*=================================================================================================
  Set tables to be accessed (FROM statement)
  =================================================================================================*/
  --SET @strTables = 'SPD_Batch b WITH (NOLOCK)'
  SET @strTables = 'SPD_Batch as b
		INNER JOIN SPD_Batch_Types as bt on b.Batch_Type_ID = bt.ID
		Left Join Security_User c On c.ID = b.Created_User
		Left Join Security_User m On m.ID = b.Modified_User
		Left Join SPD_Workflow_Stage as ws on ws.ID = b.Workflow_Stage_ID
		Left Join (Select Batch_ID, Count(Michaels_SKU) As Item_Count
			From SPD_Item_Maint_Items
			Group By Batch_ID) ic On ic.Batch_ID= b.ID	
  '

  SET @intPageSize = @maxRows
  SET @blnGetRecordCount = 1
  
  --Filer on Batch Type
  SET @strFilter = ' b.Batch_Type_ID in (3,4) '

  /*=================================================================================================
  Set filter parameters (WHERE clause)
  =================================================================================================*/
  DECLARE myCursor CURSOR LOCAL FAST_FORWARD FOR 
    SELECT FilterCol, FilterCriteria
    FROM OPENXML (@intXMLDocHandle, '/Root/Filter/Parameter') 
    WITH
    (
      FilterID int '@FilterID',
      FilterCol int '@intColOrdinal',
      FilterCriteria varchar(1000) 'text()'
    )
    ORDER BY FilterID

  OPEN myCursor
  FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF (LEN(@strFilter) > 0) SET @strFilter = @strFilter + ' AND '
    SET @strFilter = @strFilter + 
    (CASE @intTempFilterCol
		WHEN -4 THEN ' b.Enabled = 1 AND ws.Stage_Type_ID =  ' + @strTempFilterCriteria
		WHEN -3 THEN ' b.Enabled = 0 ' --Deleted Batches
		WHEN -1 THEN ' b.Enabled = 1 AND ws.Stage_Name <> ''Completed''' --All Stages except Completed
		
		WHEN 3 THEN ' b.Enabled = 1 AND b.Workflow_Stage_ID = ' + @strTempFilterCriteria	
		WHEN 4 THEN ' b.Batch_Type_ID = ' + @strTempFilterCriteria
		
		---------------------
		--Search Filters
		---------------------
		WHEN 51 THEN ' (b.ID = ' + @strTempFilterCriteria + ' OR Exists(
			Select 1
			From SPD_Item_Maint_Items as simi
			WHERE simi.Batch_ID = b.ID and simi.Michaels_SKU = ''' +  @strTempFilterCriteria + ''') )'
			
      ELSE '1=1'
    END)

    FETCH NEXT FROM myCursor INTO @intTempFilterCol, @strTempFilterCriteria
  END
  CLOSE myCursor
  DEALLOCATE myCursor


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
      WHEN 0 THEN 'b.ID ' + @strTempSortDir
      WHEN 1 THEN 'ic.Item_Count ' + @strTempSortDir
      WHEN 2 THEN 'CASE Is_Valid WHEN - 1 THEN ''unknown'' WHEN 0 THEN ''no'' WHEN 1 THEN ''yes'' ELSE ''xxx'' END ' + @strTempSortDir
      WHEN 3 THEN 'ws.Stage_Name ' + @strTempSortDir
      WHEN 4 THEN 'Coalesce(c.First_Name + '' '', '''') + Coalesce(c.Last_Name, '''') ' + @strTempSortDir
      WHEN 5 THEN 'b.Date_Created ' + @strTempSortDir
      WHEN 6 THEN 'b.Date_Modified ' + @strTempSortDir
      ELSE ''
    END)
    FETCH NEXT FROM myCursor INTO @intTempSortCol, @intTempSortDir
  END
  CLOSE myCursor
  DEALLOCATE myCursor
  
  SET @strSort = REPLACE(@strSort, ',,', '')

  /*=================================================================================================
  Set grouping parameters (GROUP BY clause)
  =================================================================================================*/
  SET @strGroup = ''


  /*=================================================================================================
  Run it!
  =================================================================================================*/

  EXEC sys_returnPagedData_usingWith
	'',
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


--------------------------------
--CREATE NEW PROCS
--------------------------------

CREATE Proc [dbo].[usp_SPD_Item_Additional_UPC_GetList_byItemIDList]
	@itemHeaderID bigint,
	@itemIDs varchar(8000) -- comma delimited list of item ids
AS

	SELECT 
    iau.[ID] as Item_Additional_UPC_ID,
    iau.Item_Header_ID,
    iau.Item_ID,
    iau.Sequence,
    iau.Additional_UPC
	FROM
		[dbo].[SPD_Item_Additional_UPC] iau 
	WHERE 
    iau.Item_Header_ID = @itemHeaderID 
	and iau.item_id in (select CONVERT(int, Element) from dbo.Split(@ItemIDs, ',')) 
	ORDER BY Item_Header_ID, item_id, sequence

GO

CREATE Proc [dbo].[usp_SPD_Item_Additional_UPC_GetList_byItemHeaderID]
	@itemHeaderID bigint
AS

	SELECT 
    iau.[ID] as Item_Additional_UPC_ID,
    iau.Item_Header_ID,
    iau.Item_ID,
    iau.Sequence,
    iau.Additional_UPC
	FROM
		[dbo].[SPD_Item_Additional_UPC] iau 
	WHERE 
    iau.Item_Header_ID = @itemHeaderID 
	ORDER BY Item_Header_ID, item_id, sequence

GO




USE [MichaelsSPD]
GO
/****** Object:  StoredProcedure [dbo].[PO_Location_Get_By_Type]    Script Date: 3/31/2020 9:19:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[PO_Location_Get_By_Type]
	@Warehouse_Type char(1)  = null,
	@Create_POID bigint = null,
	@Maint_POID bigint = null
AS
BEGIN

declare @As_Of_date datetime
declare @stage_id int
declare @batch_number varchar(100)
declare @Derived_Create_POID bigint

if @Maint_POID is not null
begin
	--find the corresponding PO Creation batch and get the max date from the PO Creation history

	select @batch_number = batch_number from PO_Maintenance where ID = @Maint_POID
	select @Derived_Create_POID = ID from PO_Creation where Batch_Number = @batch_number

	select @As_Of_Date = max(date_modified) from PO_Creation_Workflow_History where po_id = @Derived_Create_POID 
end


if @Create_POID is not null
begin
	select @stage_id = Workflow_Stage_ID from PO_Creation where ID = @Create_POID
	if @stage_id = (select id from spd_workflow_stage where Stage_Type_id = 4 and Workflow_id = 3)
	begin
		select @As_Of_Date = max(date_modified) from PO_Creation_Workflow_History where po_id = @Create_POID
	end
	else
	begin
		--incomplete batches should use today's date to determine how to display DCs
		select @As_Of_Date = getdate()
	end
end


IF @Warehouse_Type is not null
	BEGIN
		if @As_Of_Date is null
		BEGIN
			Select *, '' as Destination, '' as CombinedFrom
			From PO_Location
			Where Warehouse_Type = @Warehouse_Type
			Order By Sort_Order, Name
		END
		ELSE
		BEGIN
			Select PO_Location.*, coalesce(right(dcs1.Destination_Warehouse,2), '') as Destination, coalesce(right(dcs2.Cutover_Warehouse,2), '') as CombinedFrom
			From PO_Location
			left outer join DC_Cutover_Schedule dcs1
				on PO_Location.ID = cast(right(dcs1.Cutover_Warehouse, 2) as int) and dcs1.Cutover_Date <= @As_Of_Date
			left outer join DC_Cutover_Schedule dcs2
				on PO_Location.ID = cast(right(dcs2.Destination_Warehouse, 2) as int) and dcs2.Cutover_Date <= @As_Of_Date
			Where Warehouse_Type = @Warehouse_Type
			Order By Sort_Order, Name
		END
	END
ELSE
	BEGIN
		Select *, '' as Destination, '' as CombinedFrom
		From PO_Location
		WHERE Warehouse_Type is null
		Order By Sort_Order, Name	
	END
END



GO

