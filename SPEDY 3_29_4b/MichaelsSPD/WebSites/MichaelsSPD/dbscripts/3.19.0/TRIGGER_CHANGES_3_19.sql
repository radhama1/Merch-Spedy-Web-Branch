

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRG_SPD_Item_Master_SKU_IU]
   ON  [dbo].[SPD_Item_Master_SKU]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    if UPDATE(Displayer_Cost)
    BEGIN
		--recalculate import_burden
   
		update SPD_Item_Master_Vendor
			set Duty_Amount = isnull(Duty_Percent,0.00) * (isnull(Unit_cost,0.00) + isnull(ins.Displayer_Cost,0.00))
			, Supp_Tariff_Amount = isnull(Supp_Tariff_Percent,0.00) * (isnull(Unit_cost,0.00) + isnull(ins.Displayer_Cost,0.00))
			, Agent_Commission_Amount = CASE 
					WHEN Exists (Select top 1 A.Agent From SPD_Item_Master_Vendor_Agent A Where A.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number)
						THEN Agent_Commission_Percent * (Unit_cost + isnull(ins.Displayer_Cost,0.00))
					ELSE 0
					END
			, Other_Import_Costs_Amount = isnull(Other_Import_Costs_Percent,0.00) * (isnull(Unit_cost,0.00) + isnull(ins.Displayer_Cost,0.00))
			, FOB_Shipping_Point = isnull(Unit_cost,0.00) + isnull(ins.Displayer_Cost,0.00)
		from inserted ins, SPD_Item_Master_Vendor_Countries
		where ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and SPD_Item_Master_Vendor.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and SPD_Item_Master_Vendor_Countries.Primary_Indicator = 1

	    update SPD_Item_Master_Vendor_Countries
		    set Import_Burden = isnull(SPD_Item_Master_Vendor.Duty_Amount,0.00) 
						+ isnull(SPD_Item_Master_Vendor.Supp_Tariff_Amount, 0.00)
						+ isnull(SPD_Item_Master_Vendor.Additional_Duty_Amount, 0.00)
						+ isnull(SPD_Item_Master_Vendor.Ocean_Freight_Computed_Amount,0.00) 
						+ isnull(SPD_Item_Master_Vendor.Agent_Commission_Amount,0.00)
						+ isnull(SPD_Item_Master_Vendor.Other_Import_Costs_Amount,0.00)
		from inserted ins, SPD_Item_Master_Vendor
		where ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and SPD_Item_Master_Vendor.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number

		update SPD_Item_Master_Vendor
			set Warehouse_Landed_Cost = SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden
			, Outbound_Freight = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 0.0325
			, Nine_Percent_Whse_Charge = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 1.0325 * 0.09
		from inserted ins, SPD_Item_Master_Vendor_Countries
		where ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and SPD_Item_Master_Vendor.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and SPD_Item_Master_Vendor_Countries.Primary_Indicator = 1

		update SPD_Item_Master_Vendor
			set Total_Store_Landed_Cost = SPD_Item_Master_Vendor.Warehouse_Landed_Cost 
					+ SPD_Item_Master_Vendor.Outbound_Freight 
					+ SPD_Item_Master_Vendor.Nine_Percent_Whse_Charge
		from inserted ins, SPD_Item_Master_Vendor_Countries
		where ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and SPD_Item_Master_Vendor.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and SPD_Item_Master_Vendor_Countries.Primary_Indicator = 1

    END
END

GO


ALTER TRIGGER [dbo].[TRG_SPD_Item_Master_Vendor_Countries_IU] 
   ON  [dbo].[SPD_Item_Master_Vendor_Countries]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    --always fix columns that are only dependent on countries level fields
    
    update SPD_Item_Master_Vendor_Countries
    set Each_Case_Cube = round(ins.Each_Case_Height * ins.Each_Case_Width * ins.Each_Case_Length / 1728, 3)
		, Inner_Case_Cube = round(ins.Inner_Case_Height * ins.Inner_Case_Width * ins.Inner_Case_Length / 1728, 3)
		, Master_Case_Cube = round(ins.Master_Case_Height * ins.Master_Case_Width * ins.Master_Case_Length / 1728, 3)
    from inserted ins
    where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
		and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
		and ins.Country_Of_Origin = SPD_Item_Master_Vendor_Countries.Country_Of_Origin
    
    --only fix import burden if a field changes that impacts calc
    if UPDATE(Unit_Cost) OR UPDATE(Master_Case_Height) OR UPDATE(Master_Case_Width) OR UPDATE(Master_Case_Length) OR UPDATE(Eaches_Master_Case)
    BEGIN
		--recalculate components of import burden in order
		
		update SPD_Item_Master_Vendor
		set Duty_Amount = isnull(Duty_Percent,0.00) * (isnull(ins.Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
			, Supp_Tariff_Amount = isnull(Supp_Tariff_Percent,0.00) * (isnull(ins.Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
			, Ocean_Freight_Computed_Amount = Ocean_Freight_Amount * ins.Master_Case_Height * ins.Master_Case_Width * ins.Master_Case_Length / 1728 / ins.Eaches_Master_Case
			, Agent_Commission_Amount = CASE 
					WHEN Exists (Select top 1 A.Agent From SPD_Item_Master_Vendor_Agent A Where A.Vendor_Number = ins.Vendor_Number)
						THEN Agent_Commission_Percent * (ins.Unit_cost + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
					ELSE 0.00
					END
			, Other_Import_Costs_Amount = isnull(Other_Import_Costs_Percent,0.00) * (isnull(ins.Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
			, FOB_Shipping_Point = isnull(ins.Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00)
		from inserted ins, SPD_Item_Master_SKU
		where ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
			and ins.Michaels_SKU = SPD_Item_Master_SKU.Michaels_SKU
			and ins.Primary_Indicator = 1

	    update SPD_Item_Master_Vendor_Countries
	    set Import_Burden = isnull(Duty_Amount,0.00) 
								+ isnull(Supp_Tariff_Amount, 0.00)
								+ isnull(Additional_Duty_Amount, 0.00)
								+ isnull(Ocean_Freight_Computed_Amount,0.00) 
								+ isnull(Agent_Commission_Amount,0.00) 
								+ isnull(Other_Import_Costs_Amount,0.00)
		from inserted ins, SPD_Item_Master_Vendor, SPD_Item_Master_SKU
		where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and ins.Country_Of_Origin = SPD_Item_Master_Vendor_Countries.Country_Of_Origin
			and ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
			and ins.Michaels_SKU = SPD_Item_Master_SKU.Michaels_SKU

		update SPD_Item_Master_Vendor
		set Warehouse_Landed_Cost = SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden
			, Outbound_Freight = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 0.0325
			, Nine_Percent_Whse_Charge = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 1.0325 * 0.09
		from inserted ins, SPD_Item_Master_Vendor_Countries
		where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and ins.Country_Of_Origin = SPD_Item_Master_Vendor_Countries.Country_Of_Origin
			and ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
		
		update SPD_Item_Master_Vendor
		set Total_Store_Landed_Cost = Warehouse_Landed_Cost + Outbound_Freight + Nine_Percent_Whse_Charge
		from inserted ins, SPD_Item_Master_Vendor_Countries
		where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and ins.Country_Of_Origin = SPD_Item_Master_Vendor_Countries.Country_Of_Origin
			and ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
    END

END

GO

ALTER TRIGGER [dbo].[TRG_SPD_Item_Master_Vendor_IU] 
   ON  [dbo].[SPD_Item_Master_Vendor]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    if UPDATE(Duty_Percent) OR UPDATE(Supp_Tariff_Percent) OR UPDATE(Ocean_Freight_Amount) OR UPDATE(Agent_Commission_Percent) OR UPDATE(Other_Import_Costs_Percent) OR UPDATE (Additional_Duty_Amount)
    BEGIN
		--recalculate import_burden
   
		update SPD_Item_Master_Vendor
			set Duty_Amount = isnull(ins.Duty_Percent,0.00) * (isnull(Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
			, Supp_Tariff_Amount = isnull(ins.Supp_Tariff_Percent,0.00) * (isnull(Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
			, Ocean_Freight_Computed_Amount = ins.Ocean_Freight_Amount * Master_Case_Cube / Eaches_Master_Case
			, Agent_Commission_Amount = CASE 
					WHEN Exists (Select top 1 A.Agent From SPD_Item_Master_Vendor_Agent A Where A.Vendor_Number = ins.Vendor_Number)
						THEN ins.Agent_Commission_Percent * (Unit_cost + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
					ELSE 0
					END
			, Other_Import_Costs_Amount = isnull(ins.Other_Import_Costs_Percent,0.00) * (isnull(Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00))
			, FOB_Shipping_Point = isnull(Unit_cost,0.00) + isnull(SPD_Item_Master_SKU.Displayer_Cost,0.00)
		from inserted ins, SPD_Item_Master_Vendor_Countries, SPD_Item_Master_SKU
		where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and SPD_Item_Master_Vendor_Countries.Primary_Indicator = 1
			and ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
			and ins.Michaels_SKU = SPD_Item_Master_SKU.Michaels_SKU

	    update SPD_Item_Master_Vendor_Countries
		    set Import_Burden = isnull(SPD_Item_Master_Vendor.Duty_Amount,0.00) 
						+ isnull(SPD_Item_Master_Vendor.Supp_Tariff_Amount, 0.00)
						+ isnull(SPD_Item_Master_Vendor.Additional_Duty_Amount, 0.00)
						+ isnull(SPD_Item_Master_Vendor.Ocean_Freight_Computed_Amount,0.00) 
						+ isnull(SPD_Item_Master_Vendor.Agent_Commission_Amount,0.00)
						+ isnull(SPD_Item_Master_Vendor.Other_Import_Costs_Amount,0.00)
		from inserted ins, SPD_Item_Master_Vendor, SPD_Item_Master_SKU
		where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
			and ins.Michaels_SKU = SPD_Item_Master_SKU.Michaels_SKU

		update SPD_Item_Master_Vendor
			set Warehouse_Landed_Cost = SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden
			, Outbound_Freight = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 0.0325
			, Nine_Percent_Whse_Charge = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 1.0325 * 0.09
		from inserted ins, SPD_Item_Master_Vendor_Countries
		where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and SPD_Item_Master_Vendor_Countries.Primary_Indicator = 1
			and ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
		
		update SPD_Item_Master_Vendor
			set Total_Store_Landed_Cost = SPD_Item_Master_Vendor.Warehouse_Landed_Cost 
					+ SPD_Item_Master_Vendor.Outbound_Freight 
					+ SPD_Item_Master_Vendor.Nine_Percent_Whse_Charge
		from inserted ins, SPD_Item_Master_Vendor_Countries
		where ins.Michaels_SKU = SPD_Item_Master_Vendor_Countries.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor_Countries.Vendor_Number
			and SPD_Item_Master_Vendor_Countries.Primary_Indicator = 1
			and ins.Michaels_SKU = SPD_Item_Master_Vendor.Michaels_SKU
			and ins.Vendor_Number = SPD_Item_Master_Vendor.Vendor_Number
    END

END

GO
