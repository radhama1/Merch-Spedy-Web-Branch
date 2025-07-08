
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Littlefield, Jeff
-- Create date: Sep 2010
-- Description:	Calculate Import Burden using change values except for unit cost.  
--				Return Import burden if different from Item Master, else NULL
-- =============================================
ALTER FUNCTION [dbo].[udf_SPD_CalcImportBurdenFromChgRecs] ( @ItemID int )
RETURNS decimal(18,4)
AS
BEGIN
	Declare 
		  @SKU varchar(10)
		, @VendorNumber bigint
		, @VendorOrAgent char(1)
		, @DutyPct decimal(18,6)
		, @SuppTariffPct decimal(18,6) 
		, @UnitCost decimal(18,6)
		, @DisplayerCost decimal(18,6)
		, @OtherImportCostsPct decimal(18,6)
		, @OceanFrtCompAmt decimal(18,6)
		, @AddDutyAmt decimal(18,6)
		, @AgentCommPct decimal(18,6)
		, @AgentCommAmt decimal(18,6)
		, @DutyAmt decimal(18,6)
		, @SuppTariffAmt decimal(18,6)
		, @OtherImpCostsAmt decimal(18,6)
		, @ImportBurden decimal(18,6)
		, @ImportBurdenCalced decimal(18,6)
		, @tmpChar varchar(20)
		, @tmpDec decimal(18,6)
		, @ReturnValue decimal(18,6)

	Declare @Changes table (
			ID int
			, FieldName varchar(50)
			, Value varchar(max)
			)

	-- Get Item Master Values
	SELECT
		  @SKU = SKU 
		, @VendorNumber = VendorNumber
		, @VendorOrAgent = VendorOrAgent					-- core
		, @DutyPct = DutyPercent							-- core
		, @SuppTariffPct = SuppTariffPercent				-- core
		, @DisplayerCost = DisplayerCost					-- Don't update from Change
		, @UnitCost = ItemCost								-- Don't update from Change
		, @OtherImportCostsPct = OtherImportCostsPercent	-- core
		, @OceanFrtCompAmt = OceanFreightComputedAmount		-- core
		, @AddDutyAmt = AdditionalDutyAmount				-- core
		, @AgentCommPct = AgentCommissionPercent			-- core
		, @AgentCommAmt = AgentCommissionAmount				-- calced
		, @DutyAmt = DutyAmount								-- calced
		, @SuppTariffAmt = SuppTariffAmount					-- calced
		, @OtherImpCostsAmt = OtherImportCostsAmount		-- calced
		, @ImportBurden = ImportBurden						-- Don't update from Change
	FROM vwItemMaintItemDetail
	WHERE ID = @ItemID

/*
PRINT ' -----------------   VALUES FROM ITEM MASTER -----------------------------'
Print   '@DutyPct = ' + isNull(convert(varchar(20),@DutyPct),'NULL')
Print   '@SuppTariffPct = ' + isNull(convert(varchar(20),@SuppTariffPct),'NULL')
Print   '@DisplayerCost = ' + isNull(convert(varchar(20),@DisplayerCost),'NULL')
Print	'@UnitCost = ' + isNull(convert(varchar(20),@UnitCost),'NULL')
Print	'@OtherImportCostsPct = ' + isNull(convert(varchar(20),@OtherImportCostsPct),'NULL')
Print	'@OceanFrtCompAmt = ' + isNull(convert(varchar(20),@OceanFrtCompAmt),'NULL')
Print	'@AddDutyAmt = ' + isNull(convert(varchar(20),@AddDutyAmt),'NULL')
Print	'@AgentCommPct = ' + isNull(convert(varchar(20),@AgentCommPct),'NULL')
Print	'@AgentCommAmt = ' + isNull(convert(varchar(20),@AgentCommAmt),'NULL')
Print	'@DutyAmt = ' + isNull(convert(varchar(20),@DutyAmt),'NULL')
Print	'@OtherImpCostsAmt = ' + isNull(convert(varchar(20),@OtherImpCostsAmt),'NULL')
Print	'@ImportBurden = ' + isNull(convert(varchar(20),@ImportBurden)	,'NULL')
PRINT ' -----------------   VALUES FROM ITEM MASTER -----------------------------'
*/
	
	SELECT
		@UnitCost = IsNULL(@UnitCost,0.00)
		, @DisplayerCost = IsNULL(@DisplayerCost,0.00)
		, @AgentCommPct = ISNULL(@AgentCommPct,0.00)	-- check trigger on this
		, @DutyPct = IsNULL(@DutyPct,0.00)
		, @OtherImportCostsPct = IsNULL(@OtherImportCostsPct,0.00)

	-- Get Change recs for this item
	INSERT INTO @Changes
		SELECT Item_Maint_Items_ID
			, Field_Name
			, Field_Value
		FROM SPD_Item_Master_Changes
		WHERE Item_Maint_Items_ID = @ItemID
		
	-- Apply any changes to the records (core fields only)
	Set @tmpChar = NULL
	SELECT @tmpChar = Value
	FROM @Changes
	WHERE FieldName = 'VendorOrAgent'
	Set @VendorOrAgent = IsNULL(@tmpChar, @VendorOrAgent)

	Set @tmpDec = NULL
	SELECT @tmpDec = isnull(convert(decimal(18,6), NullIF(Value,'')),0)
	FROM @Changes
	WHERE FieldName = 'DisplayerCost'
	Set @DisplayerCost = IsNULL(@tmpDec, @DisplayerCost)
	
	Set @tmpDec = NULL
	SELECT @tmpDec = isnull(convert(decimal(18,6), NullIF(Value,'')),0)
	FROM @Changes
	WHERE FieldName = 'DutyPercent'
	Set @DutyPct = IsNULL(@tmpDec, @DutyPct)
	
	Set @tmpDec = NULL
	SELECT @tmpDec = isnull(convert(decimal(18,6), NullIF(Value,'')),0)
	FROM @Changes
	WHERE FieldName = 'SuppTariffPercent'
	Set @SuppTariffPct = IsNULL(@tmpDec, @SuppTariffPct)
	
	Set @tmpDec = NULL
	SELECT @tmpDec = isnull(convert(decimal(18,6), NullIF(Value,'')),0)
	FROM @Changes
	WHERE FieldName = 'OtherImportCostsPercent'
	Set @OtherImportCostsPct = IsNULL(@tmpDec, @OtherImportCostsPct)
	
	Set @tmpDec = NULL
	SELECT @tmpDec = isnull(convert(decimal(18,6), NullIF(Value,'')),0)
	FROM @Changes
	WHERE FieldName = 'OceanFreightComputedAmount'
	Set @OceanFrtCompAmt = IsNULL(@tmpDec, @OceanFrtCompAmt)

	Set @tmpDec = NULL
	SELECT @tmpDec = isnull(convert(decimal(18,6), NullIF(Value,'')),0)
	FROM @Changes
	WHERE FieldName = 'AdditionalDutyAmount'
	Set @AddDutyAmt = IsNULL(@tmpDec, @AddDutyAmt)
	
	Set @tmpDec = NULL
	SELECT @tmpDec = isnull(convert(decimal(18,6), NullIF(Value,'')),0)
	FROM @Changes
	WHERE FieldName = 'AgentCommissionPercent'
	Set @AgentCommPct = IsNULL(@tmpDec, @AgentCommPct)

	-- select * from @Changes
	
	-- Calc Intermediary values
	SELECT @AgentCommAmt = CASE
		WHEN @VendorOrAgent = 'A' THEN @AgentCommPct * ( @UnitCost + @DisplayerCost )
		ELSE 0.00
		END
		
	SELECT @DutyAmt = @DutyPct * (@UnitCost + @DisplayerCost)
	SELECT @SuppTariffAmt = @SuppTariffPct * (@UnitCost + @DisplayerCost)
		
	SELECT @OtherImpCostsAmt = @OtherImportCostsPct * (@UnitCost + @DisplayerCost)
	
	-- Now Caclulate Import Burden 
	Set @ImportBurdenCalced = IsNULL(@DutyAmt,0.00)
      + IsNULL(@SuppTariffAmt, 0.00)   
      + IsNULL(@AddDutyAmt, 0.00)   
      + IsNULL(@OceanFrtCompAmt,0.00)
      + IsNULL(@AgentCommAmt,0.00)
      + IsNULL(@OtherImpCostsAmt,0.00)
	
	IF @ImportBurden != @ImportBurdenCalced
		Set @ReturnValue = @ImportBurdenCalced
	ELSE
		Set @ReturnValue = NULL
/*
PRINT ' -----------------   VALUES FROM ITEM MASTER  / CHANGE RECORDS / RECALCED -------------------'
Print   '@DutyPct = ' + convert(varchar(20),@DutyPct)
Print   '@DisplayerCost = ' + convert(varchar(20),@DisplayerCost)
Print	'@UnitCost = ' + convert(varchar(20),@UnitCost)
Print	'@OtherImportCostsPct = ' + convert(varchar(20),@OtherImportCostsPct)
Print	'@OceanFrtCompAmt = ' + convert(varchar(20),@OceanFrtCompAmt)
Print	'@AddDutyAmt = ' + convert(varchar(20),@AddDutyAmt)
Print	'@AgentCommPct = ' + convert(varchar(20),@AgentCommPct)
Print	'@AgentCommAmt = ' + convert(varchar(20),@AgentCommAmt)
Print	'@DutyAmt = ' + convert(varchar(20),@DutyAmt)
Print	'@OtherImpCostsAmt = ' + convert(varchar(20),@OtherImpCostsAmt)
Print	'@ImportBurden = ' + convert(varchar(20),@ImportBurden)
Print	'@ImportBurdenCalced = ' + convert(varchar(20),@ImportBurdenCalced)
Print	'RETURN VALUE  = ' + convert(varchar(20),@ReturnValue)
PRINT ' -----------------   VALUES FROM ITEM MASTER  / CHANGE RECORDS / RECALCED -------------------'
*/

	RETURN @ReturnValue
END

GO

