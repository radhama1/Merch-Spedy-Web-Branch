

/****** Object:  StoredProcedure [dbo].[PO_Maintenance_Publish_Purchase_Order_Message_Step_2]    Script Date: 7/3/2018 12:49:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PO_Maintenance_Publish_Purchase_Order_Message_Step_2]
	@PO_Maintenance_ID bigint,
	@CurMajorRevisionNumber int,
	@CurMinorRevisionNumber int
AS
BEGIN

	Declare @Batch_Type char(1)

	Select @Batch_Type = Batch_Type
	From PO_Maintenance
	Where ID = @PO_Maintenance_ID
	
	------------------------------------------------------------------------------------
	-- ORDER DETAILS : Send Info Only If There Are Changes 
	-- (MUST SEND ALL INFO FOR THAT SKU/LOCATION IF ANYTHING CHANGES FOR A LOCATION/SKU)
	------------------------------------------------------------------------------------

	-- 2018-07-03 KH
	-- Logic changed to always send every sku/loc 
	-- if there were no changes to any skus, we could end up with an empty <details> section in the message, which causes problems on RMS side
	-- so, now we send them all
	--left joins below were commented out
	------------------------------------------------------------------------------------
	
	IF @Batch_Type = 'W'
	BEGIN

		Select
			dbo.udf_HTMLEncode(
				'<sku_loc>' +
					'<sku>' + ms.Michaels_SKU + '</sku>' +
					'<loc>' + Coalesce(Right('00' + Coalesce(l.Constant, ''), 2), '') + '</loc>' +
					'<vpn>' + REPLACE(Coalesce((Select Top 1 Vendor_Style_Num From SPD_Item_Master_Vendor WITH (NOLOCK) 
												Where Michaels_SKU = ms.Michaels_SKU And Vendor_Number = m.Vendor_Number), ''),'&','|*ampersand*|') + '</vpn>' +
					'<upc>' + Coalesce(ms.UPC, '') + '</upc>' +
					'<qty_ordered>' + Coalesce(Cast(ms.Location_Total_Qty - ms.Cancelled_Qty As varchar), '') + '</qty_ordered>' +
					'<qty_cancelled>' + Coalesce(Cast(ms.Cancelled_Qty As varchar), '') + '</qty_cancelled>' +
					'<cancel_code>' + Coalesce(ms.Cancel_Code, '') + '</cancel_code>' +
					'<cost>' + Coalesce(Convert(varchar, ms.Unit_Cost, 2), '') + '</cost>' +
					'<ip>' + Coalesce(Cast(ms.Inner_Pack As varchar), '') + '</ip>' +
					'<mp>' + Coalesce(Cast(ms.Master_Pack As varchar), '') + '</mp>' +
					'<retail>' + Coalesce(Convert(varchar, ms.Order_Retail, 2), '') + '</retail>' +
				'</sku_loc>'
			) As SKU_LOC
		From PO_Maintenance m
		Inner Join PO_Location l On l.ID = m.PO_Location_ID And m.ID = @PO_Maintenance_ID
		Inner Join PO_Maintenance_SKU ms WITH (NOLOCK) On ms.PO_Maintenance_ID = m.ID And Coalesce(ms.Location_Total_Qty, 0) > 0
		Inner Join PO_History_Maintenance hm WITH (NOLOCK) On hm.PO_Maintenance_ID = m.ID And hm.Major_Revision_Number = @CurMajorRevisionNumber And hm.Minor_Revision_Number = @CurMinorRevisionNumber
	-- 2018-07-03 KH
	-- lines below commented out to always send every sku_loc 
		--Left Join PO_History_Maintenance_SKU hms WITH (NOLOCK) On hms.PO_History_Maintenance_ID = hm.ID
		--	And hms.Michaels_SKU = ms.Michaels_SKU
		--	And hms.UPC = ms.UPC
		--	And hms.Unit_Cost = ms.Unit_Cost
		--	And hms.Inner_Pack = ms.Inner_Pack
		--	And hms.Master_Pack = ms.Master_Pack
		--	And hms.Location_Total_Qty = ms.Location_Total_Qty
		--	And hms.Cancelled_Qty = ms.Cancelled_Qty
		--	And hms.Cancel_code = ms.Cancel_Code
		--	And hms.Order_Retail = ms.Order_Retail
		--Where hms.ID IS NULL
	-- 2018-07-03 end change
	
	END
	ELSE IF @Batch_Type = 'D'
	BEGIN

		Select
			dbo.udf_HTMLEncode(
				'<sku_loc>' +
					'<sku>' + ms.Michaels_SKU + '</sku>' +
					'<loc>' + Coalesce(Cast(mss.Store_Number As varchar), '') + '</loc>' +
					'<vpn>' + REPLACE(Coalesce((Select Top 1 Vendor_Style_Num From SPD_Item_Master_Vendor WITH (NOLOCK) 
												Where Michaels_SKU = ms.Michaels_SKU And Vendor_Number = m.Vendor_Number), ''),'&','|*ampersand*|') + '</vpn>' +
					'<upc>' + Coalesce(ms.UPC, '') + '</upc>' +
					'<qty_ordered>' + Coalesce(Cast(mss.Ordered_Qty - mss.Cancelled_Qty As varchar), '') + '</qty_ordered>' +
					'<qty_cancelled>' + Coalesce(Cast(mss.Cancelled_Qty As varchar), '') + '</qty_cancelled>' +
					'<cancel_code>' + Coalesce(ms.Cancel_Code, '') + '</cancel_code>' +
					'<cost>' + Coalesce(Convert(varchar, ms.Unit_Cost, 2), '') + '</cost>' +
					'<ip>' + Coalesce(Cast(ms.Inner_Pack As varchar), '') + '</ip>' +
					'<mp>' + Coalesce(Cast(ms.Master_Pack As varchar), '') + '</mp>' +
					'<retail>' + Coalesce(Convert(varchar, mss.Order_Retail, 2), '') + '</retail>' +
				'</sku_loc>'
			) As SKU_LOC
		From PO_Maintenance m
		Inner Join PO_Location l On l.ID = m.PO_Location_ID And m.ID = @PO_Maintenance_ID
		Inner Join PO_Maintenance_SKU ms WITH (NOLOCK) On ms.PO_Maintenance_ID = m.ID And Coalesce(ms.Location_Total_Qty, 0) > 0
		Inner Join PO_Maintenance_SKU_Store mss WITH (NOLOCK) On mss.PO_Maintenance_ID = m.ID And mss.PO_Location_ID = m.PO_Location_ID And mss.Michaels_SKU = ms.Michaels_SKU
		Inner Join PO_History_Maintenance hm WITH (NOLOCK) On hm.PO_Maintenance_ID = m.ID And hm.Major_Revision_Number = @CurMajorRevisionNumber And hm.Minor_Revision_Number = @CurMinorRevisionNumber
	-- 2018-07-03 KH
	-- lines below commented out to always send every sku_loc 
		--Left Join PO_History_Maintenance_SKU hms WITH (NOLOCK) On hms.PO_History_Maintenance_ID = hm.ID
		--	And hms.Michaels_SKU = ms.Michaels_SKU
		--	And hms.UPC = ms.UPC
		--	And hms.Unit_Cost = ms.Unit_Cost
		--	And hms.Inner_Pack = ms.Inner_Pack
		--	And hms.Master_Pack = ms.Master_Pack
		--	And hms.Location_Total_Qty = ms.Location_Total_Qty
		--	And hms.Cancelled_Qty = ms.Cancelled_Qty
		--	And hms.Cancel_code = ms.Cancel_Code
		--	And hms.Order_Retail = ms.Order_Retail
		--Left Join PO_History_Maintenance_SKU_Store hmss WITH (NOLOCK) On hmss.PO_History_Maintenance_ID = hm.ID
		--	And hmss.PO_Location_ID = mss.PO_Location_ID
		--	And hmss.Michaels_SKU = mss.Michaels_SKU
		--	And hmss.Store_Name = mss.Store_Name
		--	And hmss.Store_Number = mss.Store_Number
		--	And hmss.Ordered_Qty = mss.Ordered_Qty
		--	And hmss.Order_Retail = mss.Order_Retail
		--Where hmss.ID IS NULL OR hms.ID IS NULL
	-- 2018-07-03 end change

	END
				
END