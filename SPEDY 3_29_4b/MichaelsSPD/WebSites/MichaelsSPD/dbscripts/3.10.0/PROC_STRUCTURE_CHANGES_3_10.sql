SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

--*********************************************
--SPD_Report_SKUDetails
--*********************************************

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
		s.Item_Desc, 
		--s.Hybrid_Type, s.Hybrid_Source_DC, s.Hybrid_Lead_Time, s.Hybrid_Conversion_Date, 
		s.STOCKING_STRATEGY_CODE as Stocking_Strategy_Code,
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
		
