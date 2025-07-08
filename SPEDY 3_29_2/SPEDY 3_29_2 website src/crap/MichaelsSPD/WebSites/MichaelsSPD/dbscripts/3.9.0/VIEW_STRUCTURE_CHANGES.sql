SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--***************************************************************************
--ALTER vwItemMaintItemDetail
--***************************************************************************

/****** Object:  View [dbo].[vwItemMaintItemDetail]    Script Date: 12/18/2017 13:39:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






/* Get SKU info w/o any Batch related data
 Used in Item Maint Read Only Forms
 NOTE: Keep this View in sync with [vwItemMaintItemDetailBySKU] as far as the fields returned are concerned
 NOTE 2:  ALTER THIS VIEW using the steps
			Right click on view*/
ALTER VIEW [dbo].[vwItemMaintItemDetail]
AS
SELECT     I.ID, I.Batch_ID AS BatchID, I.Enabled, I.Is_Valid AS IsValid, SKU.Michaels_SKU AS SKU, CASE WHEN
                          (SELECT     COUNT(*)
                            FROM          dbo.SPD_Item_Maint_Items I2 JOIN
                                                   dbo.SPD_Batch B2 ON I2.Batch_ID = B2.ID JOIN
                                                   dbo.SPD_Workflow_Stage WS ON B2.Workflow_Stage_ID = WS.ID
                            WHERE      I2.Michaels_SKU = I.Michaels_SKU AND I2.Batch_ID <> I.Batch_ID AND B2.Date_Created < B.Date_Created AND WS.Stage_Type_id <> 4) 
                      > 0 THEN 1 ELSE 0 END AS IsLockedForChange, V.Vendor_Number AS VendorNumber, B.Batch_Type_ID AS BatchTypeID, 
                      COALESCE ((Select Case When Vendor_Type = 110 Then 1 When Vendor_Type = 300 Then 2  Else 0 End as VendorType
						From SPD_Vendor Where vendor_Number = v.Vendor_Number) , 0) AS VendorType, 
					  UPC.UPC AS PrimaryUPC, UPPER(V.Vendor_Style_Num) AS VendorStyleNum,
                          (SELECT     COUNT(*) AS Expr1
                            FROM          dbo.SPD_Item_Master_Vendor_UPCs AS UPC2
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (Vendor_Number = V.Vendor_Number) AND (Primary_Indicator = 0)) AS AdditionalUPCs, 
                      UPPER(SKU.Item_Desc) AS ItemDesc, SKU.Class_Num AS ClassNum, SKU.Sub_Class_Num AS SubClassNum,
                          (SELECT     UDA_Value
                            FROM          dbo.SPD_Item_Master_UDA AS UDA
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID = 11)) AS PrivateBrandLabel, C.Eaches_Master_Case AS EachesMasterCase, 
                      C.Eaches_Inner_Pack AS EachesInnerPack, UPPER(SKU.Allow_Store_Order) AS AllowStoreOrder, UPPER(SKU.Inventory_Control) AS InventoryControl, 
                      UPPER(SKU.Auto_Replenish) AS AutoReplenish, CASE WHEN
                          (SELECT     COUNT(*)
                            FROM          dbo.SPD_Item_Master_UDA UDA4
                            WHERE      UDA4.Michaels_SKU = SKU.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS PrePriced,
                          (SELECT     TOP (1) ISNULL(UDA_Value, 0) AS Expr1
                            FROM          dbo.SPD_Item_Master_UDA AS UDA5
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID = 10)) AS PrePricedUDA, C.Unit_Cost AS ItemCost, 
                      C.Each_Case_Height AS EachCaseHeight, 
                      C.Each_Case_Width AS EachCaseWidth, C.Each_Case_Length AS EachCaseLength, C.Each_Case_Cube AS EachCaseCube, 
                      C.Each_Case_Weight AS EachCaseWeight, C.Each_LWH_UOM AS EachCaseCubeUOM, C.Each_Weight_UOM AS EachCaseWeightUOM, 
                      C.Inner_Case_Height AS InnerCaseHeight, 
                      C.Inner_Case_Width AS InnerCaseWidth, C.Inner_Case_Length AS InnerCaseLength, C.Inner_Case_Cube AS InnerCaseCube, 
                      C.Inner_Case_Weight AS InnerCaseWeight, C.Inner_LWH_UOM AS InnerCaseCubeUOM, C.Inner_Weight_UOM AS InnerCaseWeightUOM, 
                      C.Master_Case_Height AS MasterCaseHeight, C.Master_Case_Width AS MasterCaseWidth, C.Master_Case_Length AS MasterCaseLength, 
                      C.Master_Case_Weight AS MasterCaseWeight, C.Master_Case_Cube AS MasterCaseCube, C.Master_LWH_UOM AS MasterCaseCubeUOM, 
                      C.Master_Weight_UOM AS MasterCaseWeightUOM, C.Country_Of_Origin AS CountryOfOrigin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS CountryOfOriginName,
                          (SELECT     TOP (1) UDA_ID
                            FROM          dbo.SPD_Item_Master_UDA AS UDA2
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxUDA,
                          (SELECT     TOP (1) UDA_Value
                            FROM          dbo.SPD_Item_Master_UDA AS UDA3
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxValueUDA, UPPER(SKU.Discountable) AS Discountable, 
                      C.Import_Burden AS ImportBurden, V.Shipping_Point AS ShippingPoint, SKU.Planogram_Name AS PlanogramName, UPPER(SKU.Hazardous) AS Hazardous, 
                      UPPER(SKU.Hazardous_Flammable) AS HazardousFlammable, UPPER(SKU.Hazardous_Container_Type) AS HazardousContainerType, 
                      SKU.Hazardous_Container_Size AS HazardousContainerSize, V.MSDS_ID AS MSDSID, V.Image_ID AS ImageID, SKU.Buyer, SKU.Buyer_Fax AS BuyerFax, 
                      SKU.Buyer_Email AS BuyerEmail, SKU.Season, SKU.SKU_Group AS SKUGroup, SKU.Pack_SKU AS PackSKU, SKU.Stock_Category AS StockCategory, SKU.TSSA, 
                      SKU.CSA, SKU.UL, SKU.Licence_Agreement AS LicenceAgreement, SKU.Fumigation_Certificate AS FumigationCertificate, 
                      SKU.KILN_Dried_Certificate AS KILNDriedCertificate, SKU.China_Com_Inspec_Num_And_CCIB_Stickers AS ChinaComInspecNumAndCCIBStickers, 
                      SKU.Original_Visa AS OriginalVisa, SKU.Textile_Declaration_Mid_Code AS TextileDeclarationMidCode, SKU.Quota_Charge_Statement AS QuotaChargeStatement, 
                      SKU.MSDS, SKU.TSCA, SKU.Drop_Bal_lTest_Cert AS DropBallTestCert, SKU.Man_Medical_Device_Listing AS ManMedicalDeviceListing, 
                      SKU.Man_FDA_Registration AS ManFDARegistration, SKU.Copy_Right_Indemnification AS CopyRightIndemnification, SKU.Fish_Wild_Life_Cert AS FishWildLifeCert, 
                      SKU.Proposition_65_Label_Req AS Proposition65LabelReq, SKU.CCCR, SKU.Formaldehyde_Compliant AS FormaldehydeCompliant, 
                      SKU.RMS_Sellable AS RMSSellable, SKU.RMS_Orderable AS RMSOrderable, SKU.RMS_Inventory AS RMSInventory, SKU.Store_Total AS StoreTotal, 
                      SKU.Displayer_Cost AS DisplayerCost, C.Unit_Cost AS ProductCost, SKU.Add_Change AS AddChange, SKU.POG_Setup_Per_Store AS POGSetupPerStore, 
                      SKU.POG_Max_Qty AS POGMaxQty, SKU.Projected_Unit_Sales AS ProjectedUnitSales, V.Vendor_Or_Agent AS VendorOrAgent, V.Agent_Type AS AgentType, 
                      V.PaymentTerms, V.Days, V.Vendor_Min_Order_Amount AS VendorMinOrderAmount, COALESCE (NULLIF (LTRIM(RTRIM(V.Vendor_Name)), ''),
                          (SELECT     Vendor_Name
                            FROM          dbo.SPD_Vendor AS VL
                            WHERE      (Vendor_Number = V.Vendor_Number)), 'NA') AS VendorName, V.Vendor_Address1 AS VendorAddress1, V.Vendor_Address2 AS VendorAddress2, 
                      V.Vendor_Address3 AS VendorAddress3, V.Vendor_Address4 AS VendorAddress4, V.Vendor_Contact_Name AS VendorContactName, 
                      V.Vendor_Contact_Phone AS VendorContactPhone, V.Vendor_Contact_Email AS VendorContactEmail, V.Vendor_Contact_Fax AS VendorContactFax, 
                      V.Manufacture_Name AS ManufactureName, V.Manufacture_Address1 AS ManufactureAddress1, V.Manufacture_Address2 AS ManufactureAddress2, 
                      V.Manufacture_Contact AS ManufactureContact, V.Manufacture_Phone AS ManufacturePhone, V.Manufacture_Email AS ManufactureEmail, 
                      V.Manufacture_Fax AS ManufactureFax, V.Agent_Contact AS AgentContact, V.Agent_Phone AS AgentPhone, V.Agent_Email AS AgentEmail, V.Agent_Fax AS AgentFax, 
                      V.Harmonized_CodeNumber AS HarmonizedCodeNumber, V.Detail_Invoice_Customs_Desc AS DetailInvoiceCustomsDesc, 
                      V.Component_Material_Breakdown AS ComponentMaterialBreakdown, V.Component_Construction_Method AS ComponentConstructionMethod, 
                      V.Individual_Item_Packaging AS IndividualItemPackaging, V.FOB_Shipping_Point AS FOBShippingPoint, V.Duty_Percent AS DutyPercent, 
                      V.Duty_Amount AS DutyAmount, V.Additional_Duty_Comment AS AdditionalDutyComment, V.Additional_Duty_Amount AS AdditionalDutyAmount, 
                      V.Ocean_Freight_Amount AS OceanFreightAmount, V.Ocean_Freight_Computed_Amount AS OceanFreightComputedAmount, 
                      V.Agent_Commission_Percent AS AgentCommissionPercent, V.Agent_Commission_Amount AS AgentCommissionAmount, 
                      V.Other_Import_Costs_Percent AS OtherImportCostsPercent, V.Other_Import_Costs_Amount AS OtherImportCostsAmount, 
                      V.Packaging_Cost_Amount AS PackagingCostAmount, V.Warehouse_Landed_Cost AS WarehouseLandedCost, 
                      V.Purchase_Order_Issued_To AS PurchaseOrderIssuedTo, V.Vendor_Comments AS VendorComments, V.Freight_Terms AS FreightTerms, 
                      V.Outbound_Freight AS OutboundFreight, V.Nine_Percent_Whse_Charge AS NinePercentWhseCharge, V.Total_Store_Landed_Cost AS TotalStoreLandedCost, 
                      I.Modified_User_ID AS UpdateUserID, I.Date_Last_Modified AS DateLastModified, COALESCE (SU.First_Name, '') + ' ' + COALESCE (SU.Last_Name, '') 
                      AS UpdateUserName, SKU.Store_Supplier_Zone_Group AS StoreSupplierZoneGroup, SKU.WHS_Supplier_Zone_Group AS WHSSupplierZoneGroup, 
                      V.Primary_Indicator AS PrimaryVendor, UPPER(SKU.Item_Type) AS PackItemIndicator, SKU.Item_Type_Attribute AS ItemTypeAttribute, 
                      SKU.Hybrid_Type AS HybridType, SKU.Hybrid_Source_DC AS HybridSourceDC, UPPER(SKU.Hazardous_MSDS_UOM) AS HazardousMSDSUOM, 
                      V.Detail_Invoice_Customs_Desc0 AS DetailInvoiceCustomsDesc0, V.Detail_Invoice_Customs_Desc1 AS DetailInvoiceCustomsDesc1, 
                      V.Detail_Invoice_Customs_Desc2 AS DetailInvoiceCustomsDesc2, V.Detail_Invoice_Customs_Desc3 AS DetailInvoiceCustomsDesc3, 
                      V.Detail_Invoice_Customs_Desc4 AS DetailInvoiceCustomsDesc4, V.Detail_Invoice_Customs_Desc5 AS DetailInvoiceCustomsDesc5, 
                      V.Component_Material_Breakdown0 AS ComponentMaterialBreakdown0, V.Component_Material_Breakdown1 AS ComponentMaterialBreakdown1, 
                      V.Component_Material_Breakdown2 AS ComponentMaterialBreakdown2, V.Component_Material_Breakdown3 AS ComponentMaterialBreakdown3, 
                      V.Component_Material_Breakdown4 AS ComponentMaterialBreakdown4, V.Component_Construction_Method0 AS ComponentConstructionMethod0, 
                      V.Component_Construction_Method1 AS ComponentConstructionMethod1, V.Component_Construction_Method2 AS ComponentConstructionMethod2, 
                      V.Component_Construction_Method3 AS ComponentConstructionMethod3, SKU.Department_Num AS DepartmentNum, SKU.Base1_Retail AS Base1Retail, 
                      SKU.Base2_Retail AS Base2Retail, SKU.Base3_Retail AS Base3Retail, SKU.Test_Retail AS TestRetail, SKU.Alaska_Retail AS AlaskaRetail, 
                      SKU.Canada_Retail AS CanadaRetail, SKU.High1_Retail AS High1Retail, SKU.High2_Retail AS High2Retail, SKU.High3_Retail AS High3Retail, 
                      SKU.Small_Market_Retail AS SmallMarketRetail, SKU.Low1_Retail AS Low1Retail, SKU.Low2_Retail AS Low2Retail, SKU.Manhattan_Retail AS ManhattanRetail, 
                      V.Hazardous_Manufacturer_Name AS HazardousManufacturerName, V.Hazardous_Manufacturer_City AS HazardousManufacturerCity, 
                      V.Hazardous_Manufacturer_State AS HazardousManufacturerState, V.Hazardous_Manufacturer_Phone AS HazardousManufacturerPhone, 
                      V.Hazardous_Manufacturer_Country AS HazardousManufacturerCountry, UPPER(SKU.Item_Type) AS ItemType, PKI.Pack_Quantity AS QtyInPack, 
                      UPPER(SKU.Item_Status) AS ItemStatus, SKU.Base1_Clearance_Retail AS Base1Clearance, SKU.Base2_Clearance_Retail AS Base2Clearance, 
                      SKU.Base3_Clearance_Retail AS Base3Clearance, SKU.Test_Clearance_Retail AS TestClearance, SKU.Alaska_Clearance_Retail AS AlaskaClearance, 
                      SKU.Canada_Clearance_Retail AS CanadaClearance, SKU.High1_Clearance_Retail AS High1Clearance, SKU.High2_Clearance_Retail AS High2Clearance, 
                      SKU.High3_Clearance_Retail AS High3Clearance, SKU.Small_Market_Clearance_Retail AS SmallMarketClearance, SKU.Low1_Clearance_Retail AS Low1Clearance, 
                      SKU.Low2_Clearance_Retail AS Low2Clearance, SKU.Manhattan_Clearance_Retail AS ManhattanClearance, I.Date_Created AS DateCreated, CASE WHEN
                          (SELECT     COUNT(*)
                            FROM          SPD_Item_Master_Vendor_Country_Cost CC
                            WHERE      CC.Michaels_SKU = SKU.Michaels_SKU AND CC.Vendor_Number = V.Vendor_Number AND CC.Country_Of_Origin = C.Country_Of_Origin) 
                      > 0 THEN 1 ELSE 0 END AS FutureCostExists, SKU.QuoteReferenceNumber, 
                      CASE WHEN SKU.Pack_Item_Indicator = 'Y' THEN 'C' ELSE 'R' END AS QuoteSheetItemType, SKU.Customs_Description AS CustomsDescription, 
                      SKU.Quebec_Clearance AS QuebecClearance, SKU.Quebec_Retail AS QuebecRetail, SKU.PuertoRico_Retail AS PuertoRicoRetail, 
                      SKU.PuertoRico_Clearance AS PuertoRicoClearance, V.Canada_Harmonized_CodeNumber AS CanadaHarmonizedCodeNumber,
                      SKU.STOCKING_STRATEGY_CODE as STOCKINGSTRATEGYCODE
FROM         dbo.SPD_Item_Maint_Items AS I INNER JOIN
                      dbo.SPD_Batch AS B ON I.Batch_ID = B.ID AND B.enabled = 1 INNER JOIN
                      dbo.SPD_Item_Master_SKU AS SKU ON I.SKU_ID = SKU.ID INNER JOIN
                      dbo.SPD_Item_Master_Vendor AS V ON I.Michaels_SKU = V.Michaels_SKU AND I.Vendor_Number = V.Vendor_Number LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_UPCs AS UPC ON V.Michaels_SKU = UPC.Michaels_SKU AND V.Vendor_Number = UPC.Vendor_Number AND 
                      UPC.Primary_Indicator = 1 LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_Countries AS C ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND 
                      C.Primary_Indicator = 1 LEFT OUTER JOIN
                      dbo.Security_User AS SU ON I.Modified_User_ID = SU.ID LEFT OUTER JOIN
                      dbo.SPD_COUNTRY AS CO ON CO.COUNTRY_CODE = C.Country_Of_Origin LEFT OUTER JOIN
                      dbo.SPD_Item_Master_PackItems AS PKI ON SKU.Michaels_SKU = PKI.Child_SKU AND B.Pack_SKU = PKI.Pack_SKU






GO




--***************************************************************************
--ALTER vwItemMaintItemDetailBySKU
--***************************************************************************


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






/* Get SKU info w/o any Batch related data
 Used in Item Maint Read Only Forms
 NOTE: Keep this View in sync with vwItemMaintItemDetail as far as the fields returned are concerned
 NOTE 2:  ALTER THIS VIEW using the steps
			Right click on view*/
ALTER VIEW [dbo].[vwItemMaintItemDetailBySKU]
AS
SELECT     0 AS ID, 0 AS BatchID, 0 AS Enabled, - 1 AS IsValid, SKU.Michaels_SKU AS SKU, 0 AS IsLockedForChange, V.Vendor_Number AS VendorNumber, 0 AS BatchTypeID, 
                       COALESCE ((Select Case When Vendor_Type = 110 Then 1 When Vendor_Type = 300 Then 2  Else 0 End as VendorType
						From SPD_Vendor Where vendor_Number = v.Vendor_Number) , 0) AS VendorType, 
					  UPC.UPC AS PrimaryUPC, UPPER(V.Vendor_Style_Num) AS VendorStyleNum, 0 AS AdditionalUPCs, 
                      UPPER(SKU.Item_Desc) AS ItemDesc, SKU.Class_Num AS ClassNum, SKU.Sub_Class_Num AS SubClassNum,
                          (SELECT     UDA_Value
                            FROM          dbo.SPD_Item_Master_UDA AS UDA
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID = 11)) AS PrivateBrandLabel, C.Eaches_Master_Case AS EachesMasterCase, 
                      C.Eaches_Inner_Pack AS EachesInnerPack, UPPER(SKU.Allow_Store_Order) AS AllowStoreOrder, UPPER(SKU.Inventory_Control) AS InventoryControl, 
                      UPPER(SKU.Auto_Replenish) AS AutoReplenish, CASE WHEN
                          (SELECT     COUNT(*)
                            FROM          SPD_Item_Master_UDA UDA4
                            WHERE      UDA4.Michaels_SKU = SKU.Michaels_SKU AND UDA4.UDA_ID = 10) > 0 THEN 'Y' ELSE 'N' END AS PrePriced,
                          (SELECT     TOP (1) ISNULL(UDA_Value, 0) AS Expr1
                            FROM          dbo.SPD_Item_Master_UDA AS UDA5
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID = 10)) AS PrePricedUDA, C.Unit_Cost AS ItemCost, 
                      C.Each_Case_Height AS EachCaseHeight, 
                      C.Each_Case_Width AS EachCaseWidth, C.Each_Case_Length AS EachCaseLength, C.Each_Case_Cube AS EachCaseCube, 
                      C.Each_Case_Weight AS EachCaseWeight, C.Each_LWH_UOM AS EachCaseCubeUOM, C.Each_Weight_UOM AS EachCaseWeightUOM,    
                      C.Inner_Case_Height AS InnerCaseHeight, 
                      C.Inner_Case_Width AS InnerCaseWidth, C.Inner_Case_Length AS InnerCaseLength, C.Inner_Case_Cube AS InnerCaseCube, 
                      C.Inner_Case_Weight AS InnerCaseWeight, C.Inner_LWH_UOM AS InnerCaseCubeUOM, C.Inner_Weight_UOM AS InnerCaseWeightUOM, 
                      C.Master_Case_Height AS MasterCaseHeight, C.Master_Case_Width AS MasterCaseWidth, C.Master_Case_Length AS MasterCaseLength, 
                      C.Master_Case_Weight AS MasterCaseWeight, C.Master_Case_Cube AS MasterCaseCube, C.Master_LWH_UOM AS MasterCaseCubeUOM, 
                      C.Master_Weight_UOM AS MasterCaseWeightUOM, C.Country_Of_Origin AS CountryOfOrigin, RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS CountryOfOriginName,
                          (SELECT     TOP (1) UDA_ID
                            FROM          dbo.SPD_Item_Master_UDA AS UDA2
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxUDA,
                          (SELECT     TOP (1) UDA_Value
                            FROM          dbo.SPD_Item_Master_UDA AS UDA3
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxValueUDA, UPPER(SKU.Discountable) AS Discountable, 
                      C.Import_Burden AS ImportBurden, V.Shipping_Point AS ShippingPoint, SKU.Planogram_Name AS PlanogramName, UPPER(SKU.Hazardous) AS Hazardous, 
                      UPPER(SKU.Hazardous_Flammable) AS HazardousFlammable, UPPER(SKU.Hazardous_Container_Type) AS HazardousContainerType, 
                      SKU.Hazardous_Container_Size AS HazardousContainerSize, V.MSDS_ID AS MSDSID, V.Image_ID AS ImageID, SKU.Buyer, SKU.Buyer_Fax AS BuyerFax, 
                      SKU.Buyer_Email AS BuyerEmail, SKU.Season, SKU.SKU_Group AS SKUGroup, SKU.Pack_SKU AS PackSKU, SKU.Stock_Category AS StockCategory, SKU.TSSA, 
                      SKU.CSA, SKU.UL, SKU.Licence_Agreement AS LicenceAgreement, SKU.Fumigation_Certificate AS FumigationCertificate, 
                      SKU.KILN_Dried_Certificate AS KILNDriedCertificate, SKU.China_Com_Inspec_Num_And_CCIB_Stickers AS ChinaComInspecNumAndCCIBStickers, 
                      SKU.Original_Visa AS OriginalVisa, SKU.Textile_Declaration_Mid_Code AS TextileDeclarationMidCode, SKU.Quota_Charge_Statement AS QuotaChargeStatement, 
                      SKU.MSDS, SKU.TSCA, SKU.Drop_Bal_lTest_Cert AS DropBallTestCert, SKU.Man_Medical_Device_Listing AS ManMedicalDeviceListing, 
                      SKU.Man_FDA_Registration AS ManFDARegistration, SKU.Copy_Right_Indemnification AS CopyRightIndemnification, SKU.Fish_Wild_Life_Cert AS FishWildLifeCert, 
                      SKU.Proposition_65_Label_Req AS Proposition65LabelReq, SKU.CCCR, SKU.Formaldehyde_Compliant AS FormaldehydeCompliant, 
                      SKU.RMS_Sellable AS RMSSellable, SKU.RMS_Orderable AS RMSOrderable, SKU.RMS_Inventory AS RMSInventory, SKU.Store_Total AS StoreTotal, 
                      SKU.Displayer_Cost AS DisplayerCost, C.Unit_Cost AS ProductCost, SKU.Add_Change AS AddChange, SKU.POG_Setup_Per_Store AS POGSetupPerStore, 
                      SKU.POG_Max_Qty AS POGMaxQty, SKU.Projected_Unit_Sales AS ProjectedUnitSales, V.Vendor_Or_Agent AS VendorOrAgent, V.Agent_Type AS AgentType, 
                      V.PaymentTerms, V.Days, V.Vendor_Min_Order_Amount AS VendorMinOrderAmount, COALESCE (NULLIF (LTRIM(RTRIM(V.Vendor_Name)), ''),
                          (SELECT     Vendor_Name
                            FROM          dbo.SPD_Vendor AS VL
                            WHERE      (Vendor_Number = V.Vendor_Number)), 'na') AS VendorName, V.Vendor_Address1 AS VendorAddress1, V.Vendor_Address2 AS VendorAddress2, 
                      V.Vendor_Address3 AS VendorAddress3, V.Vendor_Address4 AS VendorAddress4, V.Vendor_Contact_Name AS VendorContactName, 
                      V.Vendor_Contact_Phone AS VendorContactPhone, V.Vendor_Contact_Email AS VendorContactEmail, V.Vendor_Contact_Fax AS VendorContactFax, 
                      V.Manufacture_Name AS ManufactureName, V.Manufacture_Address1 AS ManufactureAddress1, V.Manufacture_Address2 AS ManufactureAddress2, 
                      V.Manufacture_Contact AS ManufactureContact, V.Manufacture_Phone AS ManufacturePhone, V.Manufacture_Email AS ManufactureEmail, 
                      V.Manufacture_Fax AS ManufactureFax, V.Agent_Contact AS AgentContact, V.Agent_Phone AS AgentPhone, V.Agent_Email AS AgentEmail, V.Agent_Fax AS AgentFax, 
                      V.Harmonized_CodeNumber AS HarmonizedCodeNumber, V.Detail_Invoice_Customs_Desc AS DetailInvoiceCustomsDesc, 
                      V.Component_Material_Breakdown AS ComponentMaterialBreakdown, V.Component_Construction_Method AS ComponentConstructionMethod, 
                      V.Individual_Item_Packaging AS IndividualItemPackaging, V.FOB_Shipping_Point AS FOBShippingPoint, V.Duty_Percent AS DutyPercent, 
                      V.Duty_Amount AS DutyAmount, V.Additional_Duty_Comment AS AdditionalDutyComment, V.Additional_Duty_Amount AS AdditionalDutyAmount, 
                      V.Ocean_Freight_Amount AS OceanFreightAmount, V.Ocean_Freight_Computed_Amount AS OceanFreightComputedAmount, 
                      V.Agent_Commission_Percent AS AgentCommissionPercent, V.Agent_Commission_Amount AS AgentCommissionAmount, 
                      V.Other_Import_Costs_Percent AS OtherImportCostsPercent, V.Other_Import_Costs_Amount AS OtherImportCostsAmount, 
                      V.Packaging_Cost_Amount AS PackagingCostAmount, V.Warehouse_Landed_Cost AS WarehouseLandedCost, 
                      V.Purchase_Order_Issued_To AS PurchaseOrderIssuedTo, V.Vendor_Comments AS VendorComments, V.Freight_Terms AS FreightTerms, 
                      V.Outbound_Freight AS OutboundFreight, V.Nine_Percent_Whse_Charge AS NinePercentWhseCharge, V.Total_Store_Landed_Cost AS TotalStoreLandedCost, 
                      0 AS UpdateUserID, CASE WHEN SKU.Date_Last_Modified IS NULL THEN V.Date_Last_Modified WHEN V.Date_Last_Modified IS NULL 
                      THEN SKU.Date_Last_Modified WHEN SKU.Date_Last_Modified >= V.Date_Last_Modified THEN SKU.Date_Last_Modified ELSE V.Date_Last_Modified END AS DateLastModified,
                       '' AS UpdateUserName, SKU.Store_Supplier_Zone_Group AS StoreSupplierZoneGroup, SKU.WHS_Supplier_Zone_Group AS WHSSupplierZoneGroup, 
                      V.Primary_Indicator AS PrimaryVendor, UPPER(SKU.Item_Type) AS PackItemIndicator, SKU.Item_Type_Attribute AS ItemTypeAttribute, 
                      SKU.Hybrid_Type AS HybridType, SKU.Hybrid_Source_DC AS HybridSourceDC, UPPER(SKU.Hazardous_MSDS_UOM) AS HazardousMSDSUOM, 
                      V.Detail_Invoice_Customs_Desc0 AS DetailInvoiceCustomsDesc0, V.Detail_Invoice_Customs_Desc1 AS DetailInvoiceCustomsDesc1, 
                      V.Detail_Invoice_Customs_Desc2 AS DetailInvoiceCustomsDesc2, V.Detail_Invoice_Customs_Desc3 AS DetailInvoiceCustomsDesc3, 
                      V.Detail_Invoice_Customs_Desc4 AS DetailInvoiceCustomsDesc4, V.Detail_Invoice_Customs_Desc5 AS DetailInvoiceCustomsDesc5, 
                      V.Component_Material_Breakdown0 AS ComponentMaterialBreakdown0, V.Component_Material_Breakdown1 AS ComponentMaterialBreakdown1, 
                      V.Component_Material_Breakdown2 AS ComponentMaterialBreakdown2, V.Component_Material_Breakdown3 AS ComponentMaterialBreakdown3, 
                      V.Component_Material_Breakdown4 AS ComponentMaterialBreakdown4, V.Component_Construction_Method0 AS ComponentConstructionMethod0, 
                      V.Component_Construction_Method1 AS ComponentConstructionMethod1, V.Component_Construction_Method2 AS ComponentConstructionMethod2, 
                      V.Component_Construction_Method3 AS ComponentConstructionMethod3, SKU.Department_Num AS DepartmentNum, SKU.Base1_Retail AS Base1Retail, 
                      SKU.Base2_Retail AS Base2Retail, SKU.Base3_Retail AS Base3Retail, SKU.Test_Retail AS TestRetail, SKU.Alaska_Retail AS AlaskaRetail, 
                      SKU.Canada_Retail AS CanadaRetail, SKU.High1_Retail AS High1Retail, SKU.High2_Retail AS High2Retail, SKU.High3_Retail AS High3Retail, 
                      SKU.Small_Market_Retail AS SmallMarketRetail, SKU.Low1_Retail AS Low1Retail, SKU.Low2_Retail AS Low2Retail, SKU.Manhattan_Retail AS ManhattanRetail, 
                      V.Hazardous_Manufacturer_Name AS HazardousManufacturerName, V.Hazardous_Manufacturer_City AS HazardousManufacturerCity, 
                      V.Hazardous_Manufacturer_State AS HazardousManufacturerState, V.Hazardous_Manufacturer_Phone AS HazardousManufacturerPhone, 
                      V.Hazardous_Manufacturer_Country AS HazardousManufacturerCountry, UPPER(SKU.Item_Type) AS ItemType, 0 AS QtyInPack, UPPER(SKU.Item_Status) 
                      AS ItemStatus, SKU.Base1_Clearance_Retail AS Base1Clearance, SKU.Base2_Clearance_Retail AS Base2Clearance, 
                      SKU.Base3_Clearance_Retail AS Base3Clearance, SKU.Test_Clearance_Retail AS TestClearance, SKU.Alaska_Clearance_Retail AS AlaskaClearance, 
                      SKU.Canada_Clearance_Retail AS CanadaClearance, SKU.High1_Clearance_Retail AS High1Clearance, SKU.High2_Clearance_Retail AS High2Clearance, 
                      SKU.High3_Clearance_Retail AS High3Clearance, SKU.Small_Market_Clearance_Retail AS SmallMarketClearance, SKU.Low1_Clearance_Retail AS Low1Clearance, 
                      SKU.Low2_Clearance_Retail AS Low2Clearance, SKU.Manhattan_Clearance_Retail AS ManhattanClearance, CASE WHEN SKU.Date_Created IS NULL 
                      THEN V.Date_Created WHEN V.Date_Created IS NULL 
                      THEN SKU.Date_Created WHEN SKU.Date_Created >= V.Date_Created THEN SKU.Date_Created ELSE V.Date_Created END AS DateCreated, CASE WHEN
                          (SELECT     COUNT(*)
                            FROM          SPD_Item_Master_Vendor_Country_Cost CC
                            WHERE      CC.Michaels_SKU = SKU.Michaels_SKU AND CC.Vendor_Number = V.Vendor_Number AND CC.Country_Of_Origin = C.Country_Of_Origin) 
                      > 0 THEN 1 ELSE 0 END AS FutureCostExists, SKU.QuoteReferenceNumber, 
                      CASE WHEN SKU.Pack_Item_Indicator = 'Y' THEN 'C' ELSE 'R' END AS QuoteSheetItemType, SKU.Quebec_Retail AS QuebecRetail, 
                      SKU.Quebec_Clearance AS QuebecClearance, SKU.PuertoRico_Retail AS PuertoRicoRetail, SKU.PuertoRico_Clearance AS PuertoRicoClearance, 
                      SKU.Customs_Description AS CustomsDescription, V.Canada_Harmonized_CodeNumber AS CanadaHarmonizedCodeNumber,
                      sku.STOCKING_STRATEGY_CODE as STOCKINGSTRATEGYCODE
FROM         dbo.SPD_Item_Master_SKU AS SKU INNER JOIN
                      dbo.SPD_Item_Master_Vendor AS V ON SKU.ID = V.SKU_ID LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_UPCs AS UPC ON V.Michaels_SKU = UPC.Michaels_SKU AND V.Vendor_Number = UPC.Vendor_Number AND 
                      UPC.Primary_Indicator = 1 LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_Countries AS C ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND 
                      C.Primary_Indicator = 1 LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_Country_Cost AS CC ON C.Michaels_SKU = CC.Michaels_SKU AND C.Vendor_Number = CC.Vendor_Number AND 
                      C.Country_Of_Origin = CC.Country_Of_Origin LEFT OUTER JOIN
                      dbo.SPD_COUNTRY AS CO ON CO.COUNTRY_CODE = C.Country_Of_Origin





GO

