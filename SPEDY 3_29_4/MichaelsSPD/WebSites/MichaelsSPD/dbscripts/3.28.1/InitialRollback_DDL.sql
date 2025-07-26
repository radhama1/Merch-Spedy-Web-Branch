--******************
--DO NOT RUN THIS AS PART OF THE DEPLOY THIS IS JUST TO ROLLBACK .31
--*****************

--*****************
--TABLES
--*****************

DROP TABLE SPD_Item_Translation_Required
GO

ALTER TABLE SPD_Metadata_Column  DROP COLUMN Translation_Trigger
GO

ALTER TABLE SPD_Item_Master_Languages DROP COLUMN Description_Medium
GO

--*****************
-- VIEWS
--*****************
GO
/****** Object:  View [dbo].[vwItemMaintItemDetail]    Script Date: 4/29/2024 3:32:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vwItemMaintItemDetail]
AS
SELECT     I.ID, I.Batch_ID AS BatchID, I.Enabled, I.Is_Valid AS IsValid, SKU.Michaels_SKU AS SKU, CASE WHEN
                          (SELECT     COUNT(*)
                            FROM          dbo.SPD_Item_Maint_Items I2 JOIN
                                                   dbo.SPD_Batch B2 ON I2.Batch_ID = B2.ID JOIN
                                                   dbo.SPD_Workflow_Stage WS ON B2.Workflow_Stage_ID = WS.ID
                            WHERE      I2.Michaels_SKU = I.Michaels_SKU AND I2.Batch_ID <> I.Batch_ID AND B2.Date_Created < B.Date_Created AND WS.Stage_Type_id <> 4) 
                      > 0 THEN 1 ELSE 0 END AS IsLockedForChange, V.Vendor_Number AS VendorNumber, B.Batch_Type_ID AS BatchTypeID, COALESCE
                          ((SELECT     CASE WHEN Vendor_Type = 110 THEN 1 WHEN Vendor_Type = 300 THEN 2 ELSE 0 END AS VendorType
                              FROM         dbo.SPD_Vendor
                              WHERE     (Vendor_Number = V.Vendor_Number)), 0) AS VendorType, UPC.UPC AS PrimaryUPC, GTIN.InnerGTIN, GTIN.CaseGTIN, UPPER(V.Vendor_Style_Num) 
                      AS VendorStyleNum,
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
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID = 10)) AS PrePricedUDA, C.Unit_Cost AS ItemCost, C.Each_Case_Height AS EachCaseHeight, 
                      C.Each_Case_Width AS EachCaseWidth, C.Each_Case_Length AS EachCaseLength, C.Each_Case_Cube AS EachCaseCube, 
                      C.Each_Case_Weight AS EachCaseWeight, C.Each_LWH_UOM AS EachCaseCubeUOM, C.Each_Weight_UOM AS EachCaseWeightUOM, 
                      C.Inner_Case_Height AS InnerCaseHeight, C.Inner_Case_Width AS InnerCaseWidth, C.Inner_Case_Length AS InnerCaseLength, 
                      C.Inner_Case_Cube AS InnerCaseCube, C.Inner_Case_Weight AS InnerCaseWeight, C.Inner_LWH_UOM AS InnerCaseCubeUOM, 
                      C.Inner_Weight_UOM AS InnerCaseWeightUOM, C.Master_Case_Height AS MasterCaseHeight, C.Master_Case_Width AS MasterCaseWidth, 
                      C.Master_Case_Length AS MasterCaseLength, C.Master_Case_Weight AS MasterCaseWeight, C.Master_Case_Cube AS MasterCaseCube, 
                      C.Master_LWH_UOM AS MasterCaseCubeUOM, C.Master_Weight_UOM AS MasterCaseWeightUOM, C.Country_Of_Origin AS CountryOfOrigin, 
                      RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS CountryOfOriginName,
                          (SELECT     TOP (1) UDA_ID
                            FROM          dbo.SPD_Item_Master_UDA AS UDA2
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxUDA,
                          (SELECT     TOP (1) UDA_Value
                            FROM          dbo.SPD_Item_Master_UDA AS UDA3
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxValueUDA, UPPER(SKU.Discountable) AS Discountable, 
                      C.Import_Burden AS ImportBurden, V.Shipping_Point AS ShippingPoint, SKU.Planogram_Name AS PlanogramName, UPPER(SKU.Hazardous) AS Hazardous, 
                      UPPER(SKU.Hazardous_Flammable) AS HazardousFlammable, UPPER(SKU.Hazardous_Container_Type) AS HazardousContainerType, 
                      SKU.Hazardous_Container_Size AS HazardousContainerSize, V.MSDS_ID AS MSDSID, V.Image_ID AS ImageID, SKU.Buyer, SKU.Buyer_Fax AS BuyerFax, 
                      SKU.Buyer_Email AS BuyerEmail, SKU.Season, SKU.SKU_Group AS SKUGroup, SKU.Pack_SKU AS PackSKU, SKU.Stock_Category AS StockCategory, SKU.CoinBattery, SKU.TSSA, 
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
                      V.Duty_Amount AS DutyAmount, V.Supp_Tariff_Percent AS SuppTariffPercent, V.Supp_Tariff_Amount AS SuppTariffAmount, 
                      V.Additional_Duty_Comment AS AdditionalDutyComment, V.Additional_Duty_Amount AS AdditionalDutyAmount, V.Ocean_Freight_Amount AS OceanFreightAmount, 
                      V.Ocean_Freight_Computed_Amount AS OceanFreightComputedAmount, V.Agent_Commission_Percent AS AgentCommissionPercent, 
                      V.Agent_Commission_Amount AS AgentCommissionAmount, V.Other_Import_Costs_Percent AS OtherImportCostsPercent, 
                      V.Other_Import_Costs_Amount AS OtherImportCostsAmount, V.Packaging_Cost_Amount AS PackagingCostAmount, 
                      V.Warehouse_Landed_Cost AS WarehouseLandedCost, V.Purchase_Order_Issued_To AS PurchaseOrderIssuedTo, V.Vendor_Comments AS VendorComments, 
                      V.Freight_Terms AS FreightTerms, V.Outbound_Freight AS OutboundFreight, V.Nine_Percent_Whse_Charge AS NinePercentWhseCharge, 
                      V.Total_Store_Landed_Cost AS TotalStoreLandedCost, I.Modified_User_ID AS UpdateUserID, I.Date_Last_Modified AS DateLastModified, COALESCE (SU.First_Name, 
                      '') + ' ' + COALESCE (SU.Last_Name, '') AS UpdateUserName, SKU.Store_Supplier_Zone_Group AS StoreSupplierZoneGroup, 
                      SKU.WHS_Supplier_Zone_Group AS WHSSupplierZoneGroup, V.Primary_Indicator AS PrimaryVendor, UPPER(SKU.Item_Type) AS PackItemIndicator, 
                      SKU.Item_Type_Attribute AS ItemTypeAttribute, SKU.Hybrid_Type AS HybridType, SKU.Hybrid_Source_DC AS HybridSourceDC, UPPER(SKU.Hazardous_MSDS_UOM) 
                      AS HazardousMSDSUOM, V.Detail_Invoice_Customs_Desc0 AS DetailInvoiceCustomsDesc0, V.Detail_Invoice_Customs_Desc1 AS DetailInvoiceCustomsDesc1, 
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
                      SKU.STOCKING_STRATEGY_CODE AS STOCKINGSTRATEGYCODE
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
                      dbo.SPD_Item_Master_PackItems AS PKI ON SKU.Michaels_SKU = PKI.Child_SKU AND B.Pack_SKU = PKI.Pack_SKU LEFT OUTER JOIN
                      dbo.SPD_Item_Master_GTINs AS GTIN ON SKU.Michaels_SKU = GTIN.Michaels_SKU AND GTIN.Is_Active = 1




GO
/****** Object:  View [dbo].[vwItemMaintItemDetailBySKU]    Script Date: 4/29/2024 3:32:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vwItemMaintItemDetailBySKU]
AS
SELECT     0 AS ID, 0 AS BatchID, 0 AS Enabled, - 1 AS IsValid, SKU.Michaels_SKU AS SKU, 0 AS IsLockedForChange, V.Vendor_Number AS VendorNumber, 0 AS BatchTypeID, 
                      COALESCE
                          ((SELECT     CASE WHEN Vendor_Type = 110 THEN 1 WHEN Vendor_Type = 300 THEN 2 ELSE 0 END AS VendorType
                              FROM         dbo.SPD_Vendor
                              WHERE     (Vendor_Number = V.Vendor_Number)), 0) AS VendorType, UPC.UPC AS PrimaryUPC, GTIN.InnerGTIN, GTIN.CaseGTIN, UPPER(V.Vendor_Style_Num) 
                      AS VendorStyleNum, 0 AS AdditionalUPCs, UPPER(SKU.Item_Desc) AS ItemDesc, SKU.Class_Num AS ClassNum, SKU.Sub_Class_Num AS SubClassNum,
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
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID = 10)) AS PrePricedUDA, C.Unit_Cost AS ItemCost, C.Each_Case_Height AS EachCaseHeight, 
                      C.Each_Case_Width AS EachCaseWidth, C.Each_Case_Length AS EachCaseLength, C.Each_Case_Cube AS EachCaseCube, 
                      C.Each_Case_Weight AS EachCaseWeight, C.Each_LWH_UOM AS EachCaseCubeUOM, C.Each_Weight_UOM AS EachCaseWeightUOM, 
                      C.Inner_Case_Height AS InnerCaseHeight, C.Inner_Case_Width AS InnerCaseWidth, C.Inner_Case_Length AS InnerCaseLength, 
                      C.Inner_Case_Cube AS InnerCaseCube, C.Inner_Case_Weight AS InnerCaseWeight, C.Inner_LWH_UOM AS InnerCaseCubeUOM, 
                      C.Inner_Weight_UOM AS InnerCaseWeightUOM, C.Master_Case_Height AS MasterCaseHeight, C.Master_Case_Width AS MasterCaseWidth, 
                      C.Master_Case_Length AS MasterCaseLength, C.Master_Case_Weight AS MasterCaseWeight, C.Master_Case_Cube AS MasterCaseCube, 
                      C.Master_LWH_UOM AS MasterCaseCubeUOM, C.Master_Weight_UOM AS MasterCaseWeightUOM, C.Country_Of_Origin AS CountryOfOrigin, 
                      RTRIM(COALESCE (CO.COUNTRY_NAME, '')) AS CountryOfOriginName,
                          (SELECT     TOP (1) UDA_ID
                            FROM          dbo.SPD_Item_Master_UDA AS UDA2
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxUDA,
                          (SELECT     TOP (1) UDA_Value
                            FROM          dbo.SPD_Item_Master_UDA AS UDA3
                            WHERE      (Michaels_SKU = SKU.Michaels_SKU) AND (UDA_ID BETWEEN 1 AND 9)) AS TaxValueUDA, UPPER(SKU.Discountable) AS Discountable, 
                      C.Import_Burden AS ImportBurden, V.Shipping_Point AS ShippingPoint, SKU.Planogram_Name AS PlanogramName, UPPER(SKU.Hazardous) AS Hazardous, 
                      UPPER(SKU.Hazardous_Flammable) AS HazardousFlammable, UPPER(SKU.Hazardous_Container_Type) AS HazardousContainerType, 
                      SKU.Hazardous_Container_Size AS HazardousContainerSize, V.MSDS_ID AS MSDSID, V.Image_ID AS ImageID, SKU.Buyer, SKU.Buyer_Fax AS BuyerFax, 
                      SKU.Buyer_Email AS BuyerEmail, SKU.Season, SKU.SKU_Group AS SKUGroup, SKU.Pack_SKU AS PackSKU, SKU.Stock_Category AS StockCategory, SKU.CoinBattery, SKU.TSSA, 
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
                      V.Duty_Amount AS DutyAmount, V.Supp_Tariff_Percent AS SuppTariffPercent, V.Supp_Tariff_Amount AS SuppTariffAmount, 
                      V.Additional_Duty_Comment AS AdditionalDutyComment, V.Additional_Duty_Amount AS AdditionalDutyAmount, V.Ocean_Freight_Amount AS OceanFreightAmount, 
                      V.Ocean_Freight_Computed_Amount AS OceanFreightComputedAmount, V.Agent_Commission_Percent AS AgentCommissionPercent, 
                      V.Agent_Commission_Amount AS AgentCommissionAmount, V.Other_Import_Costs_Percent AS OtherImportCostsPercent, 
                      V.Other_Import_Costs_Amount AS OtherImportCostsAmount, V.Packaging_Cost_Amount AS PackagingCostAmount, 
                      V.Warehouse_Landed_Cost AS WarehouseLandedCost, V.Purchase_Order_Issued_To AS PurchaseOrderIssuedTo, V.Vendor_Comments AS VendorComments, 
                      V.Freight_Terms AS FreightTerms, V.Outbound_Freight AS OutboundFreight, V.Nine_Percent_Whse_Charge AS NinePercentWhseCharge, 
                      V.Total_Store_Landed_Cost AS TotalStoreLandedCost, 0 AS UpdateUserID, CASE WHEN SKU.Date_Last_Modified IS NULL 
                      THEN V.Date_Last_Modified WHEN V.Date_Last_Modified IS NULL 
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
                      SKU.STOCKING_STRATEGY_CODE AS STOCKINGSTRATEGYCODE
FROM         dbo.SPD_Item_Master_SKU AS SKU INNER JOIN
                      dbo.SPD_Item_Master_Vendor AS V ON SKU.ID = V.SKU_ID LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_UPCs AS UPC ON V.Michaels_SKU = UPC.Michaels_SKU AND V.Vendor_Number = UPC.Vendor_Number AND 
                      UPC.Primary_Indicator = 1 LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_Countries AS C ON V.Michaels_SKU = C.Michaels_SKU AND V.Vendor_Number = C.Vendor_Number AND 
                      C.Primary_Indicator = 1 LEFT OUTER JOIN
                      dbo.SPD_Item_Master_Vendor_Country_Cost AS CC ON C.Michaels_SKU = CC.Michaels_SKU AND C.Vendor_Number = CC.Vendor_Number AND 
                      C.Country_Of_Origin = CC.Country_Of_Origin LEFT OUTER JOIN
                      dbo.SPD_COUNTRY AS CO ON CO.COUNTRY_CODE = C.Country_Of_Origin LEFT OUTER JOIN
                      dbo.SPD_Item_Master_GTINs AS GTIN ON V.Michaels_SKU = GTIN.Michaels_SKU AND GTIN.Is_Active = 1

GO
--*****************
-- TRIGGER
--*****************

/****** Object:  Trigger [dbo].[TRG_SPD_Item_Master_SKU_IU]    Script Date: 4/29/2024 3:34:14 PM ******/
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
			, Outbound_Freight = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 0.06
			, Nine_Percent_Whse_Charge = (SPD_Item_Master_Vendor.FOB_Shipping_Point + SPD_Item_Master_Vendor_Countries.Import_Burden) * 1.06 * 0.09
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



--*****************
-- PROCS
--*****************
DROP PROCEDURE usp_SPD_Item_Translation_Required_Add_Items_New_Batch

GO


/****** Object:  StoredProcedure [dbo].[SKU_Purge]    Script Date: 4/29/2024 3:43:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SKU_Purge]

AS

	--Create Temp Table of unprocessed Purged SKUs 
	Select * 
	INTO #SKUPurgeList
	FROM SPD_RMS_SKU_Purge
	WHERE Coalesce(Is_Processed,0) = 0
			
	--PURGE SKU Data
	delete spd_item_master_UDA where michaels_sku in (select SKU from #SKUPurgeList)
	
	-- 03/31/2015 Change to delete from country cost before deleting from countries table
	delete spd_item_master_vendor_country_cost where michaels_sku in (select SKU from #SKUPurgeList)
	delete spd_item_master_vendor_countries where michaels_sku in (select SKU from #SKUPurgeList)
	delete spd_item_master_vendor_UPCs where michaels_sku in (select SKU from #SKUPurgeList)
	delete spd_item_master_vendor where michaels_sku in (select SKU from #SKUPurgeList)
	delete spd_item_master_packitems where pack_sku in (select SKU from #SKUPurgeList)
	delete spd_item_master_packitems where child_sku in (select SKU from #SKUPurgeList)
	delete spd_item_master_sku where michaels_sku in (select SKU from #SKUPurgeList)
	delete spd_item_master where ITEM in (select SKU from #SKUPurgeList)
	delete spd_item_master_languages where michaels_sku in (select SKU from #SKUPurgeList)
	delete SPD_item_master_languages_supplier where michaels_sku in (select SKU from #SKUPurgeList)
	--Mark IM Batches with purged SKUs as invalid
	Update SPD_Batch
	Set Is_Valid = -1
	From SPD_Batch as b
	Inner Join SPD_Item_Maint_Items as ii on ii.Batch_ID = b.ID
	Where Michaels_SKU in (Select SKU From #SKUPurgeList)
	--Mark New Batches with purged SKUs as Invalid
	UPDATE SPD_Batch
	Set Is_Valid = -1
	From sPD_Batch as b 
	Inner Join SPD_Import_Items as i on i.Batch_ID = b.ID
	Where Valid_Existing_SKU = 1 AND MichaelsSKU in (Select SKU From #SKUPurgeList)

	UPDATE SPD_Batch
	Set Batch_Valid = -1
	FROM SPD_Batch as b
	Inner Join SPD_Item_headers as h on h.Batch_ID = b.ID
	Inner Join SPD_Items as i on i.Item_Header_ID = h.ID
	Where Valid_Existing_SKU = 1 AND Michaels_SKU in (Select SKU From #SKUPurgeList)

	--Purge SKU Batch Data
	delete SPD_Item_Master_Changes WHERE Item_Maint_Items_ID in (Select i.ID from SPD_Item_Maint_Items  as i Inner Join #SKUPurgeList as s on s.SKU = i.Michaels_SKU)
	delete SPD_Item_Maint_Items Where Michaels_SKU in (Select SKU From #SKUPurgeList)
	delete SPD_Import_Item_Languages Where Import_Item_ID in (Select ID FROM SPD_Import_Items Where Valid_Existing_SKU = 1 AND MichaelsSKU in (Select SKU From #SKUPurgeList))
	Delete SPD_Item_Languages Where Item_ID in (Select ID from SPD_Items Where Valid_Existing_SKU = 1 AND Michaels_SKU in (Select SKU From #SKUPurgeList)) 
	delete SPD_Items where Valid_Existing_SKU = 1 AND Michaels_SKU in (Select SKU From #SKUPurgeList)
	delete SPD_Import_Items where Valid_Existing_SKU = 1 AND MichaelsSKU in (Select SKU From #SKUPurgeList)

	--UPDATE PO Batch validitiy to NULL for POs that contain purged SKUs
	Update PO_Creation
	Set Is_Detail_Valid = null
	From PO_Creation as c
	Inner Join PO_Creation_Location as l on l.PO_Creation_ID = c.ID
	INNER JOIN PO_Creation_Location_Sku as s on s.PO_Creation_Location_ID = l.ID
	Where s.Michaels_SKU in (Select SKU From #SKUPurgeList)

	--Update RMS Purge Table with processed data
	UPDATE SPD_RMS_SKU_Purge
	Set Is_Processed = 1, Date_Processed = getDate()
	From SPD_RMS_SKU_Purge as rms
	INNER Join #SKUPurgeList as spl on spl.SKU = rms.SKU
	
	--Drop Temp Table
	IF OBJECT_ID('#SKPurgeList', 'U') IS NOT NULL
		Drop Table #SKPurgeList
	
GO
/****** Object:  StoredProcedure [dbo].[sp_SPD_Batch_PublishMQMessage_ByBatchID]    Script Date: 4/29/2024 3:43:21 PM ******/
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
              ,COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Short]), '') as short_cfd 
              ,COALESCE(dbo.udf_ReplaceSpecialChars(silE.[Description_Long]), '') as long_cfd
			  ,COALESCE(item.Harmonized_Code_Number, '') as import_hts_code
			  ,COALESCE(item.Canada_Harmonized_Code_Number, '') as canada_hts_code
              ,COALESCE(dbo.udf_ReplaceSpecialChars(item.Customs_Description), '') as short_customs_desc         
			  --PMO200141 GTIN14 Enhancements changes
			  ,COALESCE(item.[vendor_inner_gtin], '') As vendor_inner_gtin
			  ,COALESCE(item.[vendor_case_gtin], '') As vendor_case_gtin
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
              --PMO200141 GTIN14 Enhancements changes
			  ,COALESCE(importitem.[innergtin], '') As innergtin
			  ,COALESCE(importitem.[casegtin], '') As casegtin
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
/****** Object:  StoredProcedure [dbo].[SPD_Report_CompletedDomesticItem]    Script Date: 4/29/2024 3:43:21 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SPD_Report_CompletedImportItem]    Script Date: 4/29/2024 3:43:21 PM ******/
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
		s.CoinBattery, s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
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

GO
/****** Object:  StoredProcedure [dbo].[SPD_Report_DomesticItem]    Script Date: 4/29/2024 3:43:21 PM ******/
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
/****** Object:  StoredProcedure [dbo].[SPD_Report_ImportItem]    Script Date: 4/29/2024 3:43:21 PM ******/
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
		s.CoinBattery, s.TSSA, s.CSA, s.UL, s.Licence_Agreement, s.Fumigation_Certificate, s.KILN_Dried_Certificate, s.China_Com_Inspec_Num_And_CCIB_Stickers,
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


GO
/****** Object:  StoredProcedure [dbo].[SPD_Report_SKUDetails]    Script Date: 4/29/2024 3:43:21 PM ******/
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
		v.Supp_Tariff_Percent, v.Supp_Tariff_Amount, v.Ocean_Freight_Amount, v.Agent_Commission_Percent As Merch_Burden_Percent, v.Other_Import_Costs_Percent, s.POG_Max_Qty,
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
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsF with(nolock) on simlsF.Michaels_SKU = s.Michaels_SKU and simlsF.Vendor_Number = v.Vendor_Number AND simlsF.Language_Type_ID = 2 -- FRENCH Language Fields          
		LEFT JOIN SPD_Item_Master_Languages_Supplier as simlsS with(nolock) on simlsS.Michaels_SKU = s.Michaels_SKU and simlsS.Vendor_Number = v.Vendor_Number AND simlsS.Language_Type_ID = 3 -- SPANISH Language Fields 					
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
		
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_BulkItemMaint_GetList]    Script Date: 4/29/2024 3:43:21 PM ******/
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
		WHEN 50 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 51 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[SuppTariffAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)
		WHEN 52 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 53 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OceanFreightComputedAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 54 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 55 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[AgentCommissionAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 56 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsPercent]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 57 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OtherImportCostsAmount]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 58 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ImportBurden]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 59 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[WarehouseLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                   
		WHEN 60 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OutboundFreight]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                       
		WHEN 61 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[NinePercentWhseCharge]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 62 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TotalStoreLandedCost]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 63 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ShippingPoint]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                         
		WHEN 64 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PlanogramName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                         
		WHEN 65 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Hazardous]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 66 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousFlammable]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 67 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerType]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 68 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousContainerSize]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 69 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousMSDSUOM]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 70 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerName]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 71 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCity]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 72 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerState]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 73 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerPhone]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 74 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HazardousManufacturerCountry]', @typeString, @strTempFilterOp, @strTempFilterCriteria)          
		WHEN 75 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 76 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[PLISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                            
		WHEN 77 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TIFrench]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                              
		WHEN 78 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TISpanish]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                             
		WHEN 79 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CustomsDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
		WHEN 80 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishShortDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
		WHEN 81 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[EnglishLongDescription]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                
		WHEN 82 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[HarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 83 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CanadaHarmonizedCodeNumber]', @typeString, @strTempFilterOp, @strTempFilterCriteria)            
		WHEN 84 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentMaterialBreakdown0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)           
		WHEN 85 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ComponentConstructionMethod0]', @typeString, @strTempFilterOp, @strTempFilterCriteria)          
		WHEN 86 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                  
		WHEN 87 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CSA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                   
		WHEN 88 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[UL]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                    
		WHEN 89 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[LicenceAgreement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 90 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FumigationCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
		WHEN 91 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[KILNDriedCertificate]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 92 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ChinaComInspecNumAndCCIBStickers]', @typeString, @strTempFilterOp, @strTempFilterCriteria)      
		WHEN 93 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[OriginalVisa]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                          
		WHEN 94 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TextileDeclarationMidCode]', @typeString, @strTempFilterOp, @strTempFilterCriteria)             
		WHEN 95 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[QuotaChargeStatement]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  
		WHEN 96 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[MSDS]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                  
		WHEN 97 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[TSCA]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                  
		WHEN 98 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[DropBallTestCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
		WHEN 99 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManMedicalDeviceListing]', @typeString, @strTempFilterOp, @strTempFilterCriteria)               
	       WHEN 100 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[ManFDARegistration]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                    
	       WHEN 101 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CopyRightIndemnification]', @typeString, @strTempFilterOp, @strTempFilterCriteria)              
	       WHEN 102 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FishWildLifeCert]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                      
	       WHEN 103 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[Proposition65LabelReq]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                 
	       WHEN 104 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[CCCR]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                                   
	       WHEN 105 THEN [dbo].[udf_s_GetAdvancedFilterOperatorValue]('i.[FormaldehydeCompliant]', @typeString, @strTempFilterOp, @strTempFilterCriteria)                  

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
		WHEN 50 THEN 'i.[SuppTariffPercent] ' + @strTempSortDir 
		WHEN 51 THEN 'i.[SuppTariffAmount] ' + @strTempSortDir 
		WHEN 52 THEN 'i.[OceanFreightAmount] ' + @strTempSortDir                              
		WHEN 53 THEN 'i.[OceanFreightComputedAmount] ' + @strTempSortDir                      
		WHEN 54 THEN 'i.[AgentCommissionPercent] ' + @strTempSortDir                          
		WHEN 55 THEN 'i.[AgentCommissionAmount] ' + @strTempSortDir                           
		WHEN 56 THEN 'i.[OtherImportCostsPercent] ' + @strTempSortDir                         
		WHEN 57 THEN 'i.[OtherImportCostsAmount] ' + @strTempSortDir                          
		WHEN 58 THEN 'i.[ImportBurden] ' + @strTempSortDir                                    
		WHEN 59 THEN 'i.[WarehouseLandedCost] ' + @strTempSortDir                             
		WHEN 60 THEN 'i.[OutboundFreight] ' + @strTempSortDir                                 
		WHEN 61 THEN 'i.[NinePercentWhseCharge] ' + @strTempSortDir                           
		WHEN 62 THEN 'i.[TotalStoreLandedCost] ' + @strTempSortDir                            
		WHEN 63 THEN 'i.[ShippingPoint] ' + @strTempSortDir                                   
		WHEN 64 THEN 'i.[PlanogramName] ' + @strTempSortDir                                   
		WHEN 65 THEN 'i.[Hazardous] ' + @strTempSortDir                                       
		WHEN 66 THEN 'i.[HazardousFlammable] ' + @strTempSortDir                              
		WHEN 67 THEN 'i.[HazardousContainerType] ' + @strTempSortDir                          
		WHEN 68 THEN 'i.[HazardousContainerSize] ' + @strTempSortDir                          
		WHEN 69 THEN 'i.[HazardousMSDSUOM] ' + @strTempSortDir                                
		WHEN 70 THEN 'i.[HazardousManufacturerName] ' + @strTempSortDir                       
		WHEN 71 THEN 'i.[HazardousManufacturerCity] ' + @strTempSortDir                       
		WHEN 72 THEN 'i.[HazardousManufacturerState] ' + @strTempSortDir                      
		WHEN 73 THEN 'i.[HazardousManufacturerPhone] ' + @strTempSortDir                      
		WHEN 74 THEN 'i.[HazardousManufacturerCountry] ' + @strTempSortDir                    
		WHEN 75 THEN 'i.[PLIFrench] ' + @strTempSortDir                                       
		WHEN 76 THEN 'i.[PLISpanish] ' + @strTempSortDir                                      
		WHEN 77 THEN 'i.[TIFrench] ' + @strTempSortDir                                        
		WHEN 78 THEN 'i.[TISpanish] ' + @strTempSortDir                                       
		WHEN 79 THEN 'i.[CustomsDescription] ' + @strTempSortDir                              
		WHEN 80 THEN 'i.[EnglishShortDescription] ' + @strTempSortDir                         
		WHEN 81 THEN 'i.[EnglishLongDescription] ' + @strTempSortDir                          
		WHEN 82 THEN 'i.[HarmonizedCodeNumber] ' + @strTempSortDir                            
		WHEN 83 THEN 'i.[CanadaHarmonizedCodeNumber] ' + @strTempSortDir                      
		WHEN 84 THEN 'i.[ComponentMaterialBreakdown0] ' + @strTempSortDir                     
		WHEN 85 THEN 'i.[ComponentConstructionMethod0] ' + @strTempSortDir                    
		WHEN 86 THEN 'i.[TSSA] ' + @strTempSortDir                                            
		WHEN 87 THEN 'i.[CSA] ' + @strTempSortDir                                             
		WHEN 88 THEN 'i.[UL] ' + @strTempSortDir                                              
		WHEN 89 THEN 'i.[LicenceAgreement] ' + @strTempSortDir                                
		WHEN 90 THEN 'i.[FumigationCertificate] ' + @strTempSortDir                           
		WHEN 91 THEN 'i.[KILNDriedCertificate] ' + @strTempSortDir                            
		WHEN 92 THEN 'i.[ChinaComInspecNumAndCCIBStickers] ' + @strTempSortDir                
		WHEN 93 THEN 'i.[OriginalVisa] ' + @strTempSortDir                                    
		WHEN 94 THEN 'i.[TextileDeclarationMidCode] ' + @strTempSortDir                       
		WHEN 95 THEN 'i.[QuotaChargeStatement] ' + @strTempSortDir                            
		WHEN 96 THEN 'i.[MSDS] ' + @strTempSortDir                                            
		WHEN 97 THEN 'i.[TSCA] ' + @strTempSortDir                                            
		WHEN 98 THEN 'i.[DropBallTestCert] ' + @strTempSortDir                                
		WHEN 99 THEN 'i.[ManMedicalDeviceListing] ' + @strTempSortDir                         
	       WHEN 100 THEN 'i.[ManFDARegistration] ' + @strTempSortDir                              
	       WHEN 101 THEN 'i.[CopyRightIndemnification] ' + @strTempSortDir                        
	       WHEN 102 THEN 'i.[FishWildLifeCert] ' + @strTempSortDir                                
	       WHEN 103 THEN 'i.[Proposition65LabelReq] ' + @strTempSortDir                           
	       WHEN 104 THEN 'i.[CCCR] ' + @strTempSortDir                                            
	       WHEN 105 THEN 'i.[FormaldehydeCompliant] ' + @strTempSortDir                           
      
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_AddItemToBatch]    Script Date: 4/29/2024 3:43:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Littlefield, Jeff
-- Create date: May 2010
-- Description:	Add a record to the IM batch Header
-- =============================================
ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_AddItemToBatch] 
	-- Add the parameters for the stored procedure here
	@Batch_ID int
	, @SKU varchar(20)
	, @SKUID int
	, @VendorNumber int
	, @UserID int
	
AS
declare @cnt int, @ID int, @rowCount int

BEGIN
	SET NOCOUNT ON;
	Select @cnt  = count(*)
	From SPD_Item_Maint_Items
	Where Batch_ID = @Batch_ID
		and Michaels_SKU = @SKU
		and Vendor_Number = @VendorNumber
		
	IF @cnt = 0		-- Record does not exist. OK to insert
	BEGIN
		BEGIN TRY
		INSERT SPD_Item_Maint_Items (
			[Batch_ID]
			, [Michaels_SKU]
			, [SKU_ID]
			, [Vendor_Number]
			, [Is_Valid]
			, [Date_Created]
			, [Created_User_ID]
			, [Enabled]
		) VALUES (
			@Batch_ID
			, @SKU
			, @SKUID
			, @VendorNumber
			, -1
			, getdate()
			, @UserID
			, 1  
		);
		
		SET @rowCount = @@RowCount
		SET @ID = SCOPE_IDENTITY()
		
		END TRY
		BEGIN CATCH
			SET @rowCount = -1;
			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;
			SELECT 
				@ErrorMessage = ERROR_MESSAGE()
				, @ErrorSeverity = ERROR_SEVERITY()
				, @ErrorState = ERROR_STATE();
			RAISERROR (@ErrorMessage, -- Message text.
					   @ErrorSeverity, -- Severity.
					   @ErrorState -- State.
					   );

		END CATCH
	END
	ELSE
	BEGIN
		set @ID =  0
	END
	
	return @ID
		
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_CompleteOrErrorBatch]    Script Date: 4/29/2024 3:43:21 PM ******/
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


GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_DeleteRecord]    Script Date: 4/29/2024 3:43:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_DeleteRecord] 
	@ID int
	, @batchID bigint
	, @UserID bigint = -1
	, @DeleteAll tinyint = 0
	
AS

declare @aID int, @aFN varchar(50), @aCOO varchar(50), @aUPC varchar(20), @aED varchar(50), @aCtr int, @aFV varchar(max)
declare @pii varchar(20)

select @pii = COALESCE(RTRIM(REPLACE(LEFT(COALESCE(c.[Field_Value], i.[PackItemIndicator], ''),2), '-', '')), '') from vwItemMaintItemDetail i 
    left outer join SPD_Item_Master_Changes c ON i.[ID] = c.[Item_Maint_Items_ID] and c.[Field_Name] = 'PackItemIndicator' and c.[Counter] = 0 
    where i.[ID] = @ID and i.[BatchID] = @batchID
    
IF ( (@pii != 'D' AND @pii != 'DP') OR @DeleteAll = 1 )
begin

  declare row cursor for 
  SELECT 
		  [Item_Maint_Items_ID]
		  , [Field_Name]
		  , [Country_Of_Origin]
		  , [UPC]
		  , [Effective_Date]
		  , [Counter]
		  , [Field_Value]
	  FROM SPD_Item_Master_Changes
	  WHERE Item_Maint_Items_ID = @ID
		  and Item_Maint_Items_ID in (select ID from SPD_Item_Maint_Items where ID = @ID and Batch_ID = @batchID)
  		
  Open row
  FETCH NEXT FROM row 
	  INTO @aID, @aFN, @aCOO, @aUPC, @aED, @aCtr, @aFV;

  -- Delete Change Recs one at a time for audit purposes
  WHILE @@FETCH_STATUS = 0
  BEGIN
	  -- Delete the rec
	  DELETE FROM SPD_Item_Master_Changes
	  WHERE [Item_Maint_Items_ID] = @aID
	    and [Field_Name] = @aFN
	    and [Country_Of_Origin] = @aCOO
	    and [UPC] = @aUPC
	    and [Effective_Date] = @aED
	    and [Counter] = @aCtr
	  IF @@Rowcount > 0
	  BEGIN
	  -- Audit the Delete Manually since Trigger does not know who did it
		  INSERT SPD_AuditLog ( 
			  TableName, FieldName, OldValue, NewValue, ActionCode, ActionDate, UserLogin
			  , KeyValue1, KeyValue2, KeyValue3, KeyValue4, KeyValue5, KeyValue6
			  )
		  VALUES (
			  'SPD_Item_Master_Changes'
			  , 'Field_Value'
			  , convert(nvarchar(2000),@aFV)
			  , '*NA*'
			  , 'D'
			  , getdate()
			  , @UserID
			  , Convert(varchar(255),@aID)
			  , Convert(varchar(255),@aFN)
			  , Convert(varchar(255),@aCOO)
			  , Convert(varchar(255),@aUPC)
			  , Convert(varchar(255),@aED)
			  , Convert(varchar(255),@aCtr)
			  )
	  END
  	
	  FETCH NEXT FROM row 
	  INTO @aID, @aFN, @aCOO, @aUPC, @aED, @aCtr, @aFV;
  END
  CLOSE row;
  DEALLOCATE row;


	  ---- SPD_Item_Master_Changes .Item_Maint_Items_ID
	  --delete from SPD_Item_Master_Changes 
	  --where Item_Maint_Items_ID = @ID
	  --  and Item_Maint_Items_ID in (select ID from SPD_Item_Maint_Items where ID = @ID and Batch_ID = @batchID)

    -- SPD_Item_Maint_Items .ID .Batch_ID
  Declare @aBN bigint, @aSKU varchar(25), @aVendorNo bigint
  SELECT 
	  @aID = [ID]
	  , @aBN = Batch_ID
	  , @aSKU = Michaels_SKU
	  , @aVendorNo = Vendor_Number
  FROM SPD_Item_Maint_Items
  WHERE ID = @ID and Batch_ID = @batchID

  If @aID is Not NULL
  BEGIN
	  DELETE FROM SPD_Item_Maint_Items
	  WHERE ID = @ID and Batch_ID = @batchID
  	
	  INSERT SPD_AuditLog ( 
		  TableName, FieldName, OldValue, NewValue, ActionCode, ActionDate, UserLogin
		  , KeyValue1
		  )
	  VALUES (
		  'SPD_Item_Maint_Items'
		  , 'Batch_ID'
		  , convert(nvarchar(2000),@aBN)
		  , '*NA*'
		  , 'D'
		  , getdate()
		  , @UserID
		  , Convert(varchar(255),@aID)
		  )
    
  	  INSERT SPD_AuditLog ( 
		  TableName, FieldName, OldValue, NewValue, ActionCode, ActionDate, UserLogin
		  , KeyValue1
		  )
	  VALUES (
		  'SPD_Item_Maint_Items'
		  , 'Michaels_SKU'
		  , convert(nvarchar(2000),@aSKU)
		  , '*NA*'
		  , 'D'
		  , getdate()
		  , @UserID
		  , Convert(varchar(255),@aID)
		  )
  		
  	  INSERT SPD_AuditLog ( 
		  TableName, FieldName, OldValue, NewValue, ActionCode, ActionDate, UserLogin
		  , KeyValue1
		  )
	  VALUES (
		  'SPD_Item_Maint_Items'
		  , 'Vendor_Number'
		  , convert(nvarchar(2000),@aVendorNo)
		  , '*NA*'
		  , 'D'
		  , getdate()
		  , @UserID
		  , Convert(varchar(255),@aID)
		  )
  END

end
	
  --delete from SPD_Item_Maint_Items
  --where ID = @ID and Batch_ID = @batchID
  
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_GetItemMaintBatchItemList_By_BatchID]    Script Date: 4/29/2024 3:43:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_SPD_ItemMaint_GetItemMaintBatchItemList_By_BatchID]
	@batchID int
AS
BEGIN
	SET NOCOUNT ON;

	select i.Batch_ID, i.SKU_ID, i.Michaels_SKU, i.Vendor_Number, s.department_num,
	i.ID item_maint_items_id
	from spd_item_maint_items i
	inner join spd_item_Master_SKU s on i.sku_id = s.[ID]
	where i.Batch_ID = @batchID
	--order by i.Michaels_SKU
	order by i.ID
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_GetList]    Script Date: 4/29/2024 3:43:21 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_ItemMaint_ProcessIncomingMessage]    Script Date: 4/29/2024 3:43:21 PM ******/
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
/****** Object:  StoredProcedure [dbo].[usp_SPD_MQComm_UpdateItemMaster]    Script Date: 4/29/2024 3:43:21 PM ******/
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
		
	END	
	
	Commit Tran
	IF @Debug=1  Print 'Updating Item Master Proc Ends'
	EXEC usp_SPD_MQ_LogMessage @D=@LTS, @M='Updating Item Master From New Item Proc Ends'


END




GO
/****** Object:  StoredProcedure [dbo].[usp_SPD_TrilingualMaint_GetList]    Script Date: 4/29/2024 3:43:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[usp_SPD_TrilingualMaint_GetList]
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
