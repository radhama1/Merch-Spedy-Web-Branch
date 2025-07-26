--**************
--supp tariff metadata new import
--**************
--------------------------------------------------------------------------------------------------
insert into SPD_Metadata_Column
(
Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,	
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	
Modified_By,	Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	
View_To_TableName,	View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero
)
values
(
1,	'SuppTariffPercent',	'Supplementary Tariff Percent',	221,	1,	
1,	1,	221,	'string',	100,
'decimal',	Null,	GETDATE(),	GETDATE(),	0,	
0,	1,	1,	Null,	null,	
null,	null,	null,	0
)

insert into SPD_Metadata_Column
(
Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,	
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	
Modified_By,	Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	
View_To_TableName,	View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero
)
values
(
1,	'SuppTariffAmount',	'Supplementary Tariff',	222,	1,	
1,	1,	222,	'string',	100,
'decimal',	Null,	GETDATE(),	GETDATE(),	0,	
0,	1,	1,	Null,	null,	
null,	null,	null,	1
)
--------------------------------------------------------------------------------------------------


--**************
--supp tariff field locking new import
--**************
--------------------------------------------------------------------------------------------------
DECLARE @dutyPCTId int
Select @dutyPCTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 1 and Column_Name = 'DutyPercent';

DECLARE @dutyAMTId int
Select @dutyAMTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 1 and Column_Name = 'DutyAmount';

DECLARE @suppTariffPCTId int
Select @suppTariffPCTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 1 and Column_Name = 'SuppTariffPercent';

DECLARE @suppTariffAMTId int
Select @suppTariffAMTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 1 and Column_Name = 'SuppTariffAmount';

Insert into spd_field_locking
(
Metadata_Column_ID,	Field_Locking_User_Catagories_ID,	Date_Created,	Created_User_ID,	
Date_Last_Modified,	Update_User_ID,	Workflow_Stage_ID,	Permission
)
Select 
@suppTariffPCTId,	Field_Locking_User_Catagories_ID,	GETDATE(),	0,	
GETDATE(),	0,	Workflow_Stage_ID,	Permission
from spd_field_locking
where Metadata_Column_ID = @dutyPCTId


Insert into spd_field_locking
(
Metadata_Column_ID,	Field_Locking_User_Catagories_ID,	Date_Created,	Created_User_ID,	
Date_Last_Modified,	Update_User_ID,	Workflow_Stage_ID,	Permission
)
Select 
@suppTariffAMTId,	Field_Locking_User_Catagories_ID,	GETDATE(),	0,	
GETDATE(),	0,	Workflow_Stage_ID,	Permission
from spd_field_locking
where Metadata_Column_ID = @dutyAMTId
--------------------------------------------------------------------------------------------------


--**************
--supp tariff metadata item maint
--**************
--------------------------------------------------------------------------------------------------
insert into SPD_Metadata_Column
(
Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,	
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	
Modified_By,	Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	
View_To_TableName,	View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero
)
values
(
11,	'SuppTariffAmount',	'Supplementary Tariff',	222,	1,	
1,	1,	222,	'decimal',	Null,
'formatnumber4',	Null,	GETDATE(),	GETDATE(),	0,	
0,	1,	1,	Null,	0,	
'SPD_Item_Master_Vendor',	'Supp_Tariff_Amount',	'(18,6)',	1
)

insert into SPD_Metadata_Column
(
Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,	
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	
Modified_By,	Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	
View_To_TableName,	View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero
)
values
(
11,	'SuppTariffPercent',	'Supplementary Tariff Percent',	221,	1,	
1,	1,	221,	'decimal',	Null,
'percent',	Null,	GETDATE(),	GETDATE(),	0,	
0,	1,	1,	Null,	1,	
'SPD_Item_Master_Vendor',	'Supp_Tariff_Percent',	'(18,6)',	0
)


--------------------------------------------------------------------------------------------------

--**************
--supp tariff field locking item maint
--**************
--------------------------------------------------------------------------------------------------

DECLARE @IMdutyPCTId int
Select @IMdutyPCTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'DutyPercent';

DECLARE @IMdutyAMTId int
Select @IMdutyAMTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'DutyAmount';

DECLARE @IMsuppTariffPCTId int
Select @IMsuppTariffPCTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'SuppTariffPercent';

DECLARE @IMsuppTariffAMTId int
Select @IMsuppTariffAMTId = ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'SuppTariffAmount';

Insert into spd_field_locking
(
Metadata_Column_ID,	Field_Locking_User_Catagories_ID,	Date_Created,	Created_User_ID,	
Date_Last_Modified,	Update_User_ID,	Workflow_Stage_ID,	Permission
)
Select 
@IMsuppTariffPCTId,	Field_Locking_User_Catagories_ID,	GETDATE(),	0,	
GETDATE(),	0,	Workflow_Stage_ID,	Permission
from spd_field_locking
where Metadata_Column_ID = @IMdutyPCTId


Insert into spd_field_locking
(
Metadata_Column_ID,	Field_Locking_User_Catagories_ID,	Date_Created,	Created_User_ID,	
Date_Last_Modified,	Update_User_ID,	Workflow_Stage_ID,	Permission
)
Select 
@IMsuppTariffAMTId,	Field_Locking_User_Catagories_ID,	GETDATE(),	0,	
GETDATE(),	0,	Workflow_Stage_ID,	Permission
from spd_field_locking
where Metadata_Column_ID = @IMdutyAMTId


--------------------------------------------------------------------------------------------------

--**************
--supp tariff ColumnDisplayName item maint
--**************
--------------------------------------------------------------------------------------------------

--move old columns down
DECLARE @addDutyPos int
Select @addDutyPos = CDN.Column_Ordinal
from ColumnDisplayName CDN
where Workflow_ID = 2 and CDN.Column_Name = 'AdditionalDutyAmount'

Update ColumnDisplayName 
set Column_Ordinal = Column_Ordinal + 2
where Workflow_ID = 2
and Column_Ordinal > @addDutyPos

--add supp tariff columns
insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,	
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,	
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
values
(
'I',	'SuppTariffPercent',	@addDutyPos + 1,	'decimal',	'percent',	
null,	0,	1,	1,	1,	
1,	1,	0,	1,	1,	
'Supplementary<br />Tariff Percent',	0,	10,	null,	GETDATE(),
GETDATE(),	NEWID(),	2
)

insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,	
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,	
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
values
(
'I',	'SuppTariffAmount',	@addDutyPos + 2,	'decimal',	'formatnumber4',	
null,	0,	1,	1,	1,	
1,	0,	0,	1,	1,	
'Supplementary<br />Tariff',	0,	20,	null,	GETDATE(),
GETDATE(),	NEWID(),	2
)
--------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------

--**************
--supp tariff ColumnDisplayName BULK item maint
--**************
--------------------------------------------------------------------------------------------------

DECLARE @addBulkDutyPos int
Select @addBulkDutyPos = CDN.Column_Ordinal
from ColumnDisplayName CDN
where Workflow_ID = 7 and CDN.Column_Name = 'AdditionalDutyAmount'

Update ColumnDisplayName 
set Column_Ordinal = Column_Ordinal + 2
where Workflow_ID = 7
and Column_Ordinal > @addBulkDutyPos


insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,	
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,	
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
values
(
'I',	'SuppTariffPercent',	@addBulkDutyPos + 1,	'decimal',	'percent',	
null,	0,	1,	1,	1,	
1,	1,	0,	1,	1,	
'Supplementary<br />Tariff Percent',	0,	10,	null,	GETDATE(),
GETDATE(),	NEWID(),	7
)

insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	
Column_Format_String,	Fixed_Column,	Allow_Sort,	Allow_Filter,	Allow_UserDisable,	
Allow_Admin,	Allow_AjaxEdit,	Is_Custom,	Default_UserDisplay,	Display,	
Display_Name,	Display_Width,	Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,
Date_Created,	GUID,	Workflow_ID
)
values
(
'I',	'SuppTariffAmount',	@addBulkDutyPos + 2,	'decimal',	'formatnumber4',	
null,	0,	1,	1,	1,	
1,	0,	0,	1,	1,	
'Supplementary<br />Tariff',	0,	20,	null,	GETDATE(),
GETDATE(),	NEWID(),	7
)

--------------------------------------------------------------------------------------------------

--*****************************
--Import SPD_Item_Mapping  - Import quote
--*****************************
Insert into SPD_Item_Mapping 
([Default],Mapping_Name, Mapping_Version, Date_Created, Created_User_Id, Date_Last_modified, Update_User_Id, Enabled)
values
(0,'IMPORTITEM','15.10', GETDATE(),0,GETDATE(),0,1)

--disable old import
update SPD_Item_Mapping 
set Enabled = 0 
where Mapping_Name = 'IMPORTITEM' and Mapping_Version = '15'

--------------------------------------------------------------------------------------------------

--*****************************
--Import SPD_Item_Mapping_Columns - Import quote
--*****************************
insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) 
select 
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.10')
, mc.Column_Name, mc.Excel_Column, mc.Excel_Row 
from SPD_Item_Mapping_Columns mc where mc.Item_Mapping_ID = 
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15')


Insert into SPD_Item_Mapping_Columns
(Item_Mapping_ID, Column_Name,Excel_Column,Excel_Row)
values
(
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.10'),
'SuppTariffPercent', 'C', 84
)

Insert into SPD_Item_Mapping_Columns
(Item_Mapping_ID, Column_Name,Excel_Column,Excel_Row)
values
(
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.10'),
'SuppTariffAmount', 'J', 84
)

--------------------------------------------------------------------------------------------------

--*****************************
--Import SPD_Report
--*****************************

update SPD_Report  
set report_sql =
'declare @dateNow datetime    declare @dateNowStr varchar(20)    declare @month varchar(2), @day varchar(2), @year varchar(4)        set @dateNow = getdate()    set @month = convert(varchar(2), Month(@dateNow))      if (len(@month) < 2)       set @month = ''0'' + @month      set @day = convert(varchar(2), Day(@dateNow))    if (len(@day) < 2)       set @day = ''0'' + @day      set @year = convert(varchar(4), Year(@dateNow))    if (len(@year) < 4)       set @year = ''00'' + @year      set @dateNowStr =  @year + @month + @day      select     ii.ID        ,ii.Batch_ID        ,ii.DateCreated        ,ii.DateLastModified        ,ii.CreatedUserID        ,ii.UpdateUserID        ,ii.DateSubmitted        ,ii.Vendor        ,ii.Agent As MerchBurden        ,ii.AgentType As MerchBurdenType        ,ii.Buyer        ,ii.Fax        ,ii.EnteredBy        ,ii.QuoteSheetStatus        ,ii.Season        ,ii.SKUGroup        ,ii.Email        ,ii.EnteredDate        ,ii.Dept        ,ii.Class        ,ii.SubClass        ,ii.PrimaryUPC        ,ii.MichaelsSKU as SKU        ,ii.GenerateMichaelsUPC as GenerateUPC       ,ii.AdditionalUPC1        ,ii.AdditionalUPC2        ,ii.AdditionalUPC3        ,ii.AdditionalUPC4        ,ii.AdditionalUPC5        ,ii.AdditionalUPC6        ,ii.AdditionalUPC7        ,ii.AdditionalUPC8        ,ii.PackSKU        ,ii.PlanogramName        ,ii.VendorNumber        ,ii.VendorRank        ,ii.ItemTask        ,ii.Description        ,ii.PaymentTerms        ,ii.Days        ,ii.VendorMinOrderAmount        ,ii.VendorName        ,ii.VendorAddress1        ,ii.VendorAddress2        ,ii.VendorAddress3        ,ii.VendorAddress4        ,ii.VendorContactName        ,ii.VendorContactPhone        ,ii.VendorContactEmail        ,ii.VendorContactFax        ,ii.ManufactureName        ,ii.ManufactureAddress1        ,ii.ManufactureAddress2        ,ii.ManufactureContact        ,ii.ManufacturePhone        ,ii.ManufactureEmail        ,ii.ManufactureFax        ,ii.AgentContact        ,ii.AgentPhone        ,ii.AgentEmail        ,ii.AgentFax        ,ii.VendorStyleNumber        ,ii.HarmonizedCodeNumber, ii.CanadaHarmonizedCodeNumber        ,ii.DetailInvoiceCustomsDesc        ,ii.ComponentMaterialBreakdown        ,ii.ComponentConstructionMethod        ,ii.IndividualItemPackaging        ,ii.EachInsideMasterCaseBox        ,ii.EachInsideInnerPack        ,ii.ReshippableInnerCartonWeight        ,ii.ReshippableInnerCartonLength        ,ii.ReshippableInnerCartonWidth        ,ii.ReshippableInnerCartonHeight        ,ii.MasterCartonDimensionsLength        ,ii.MasterCartonDimensionsWidth        ,ii.MasterCartonDimensionsHeight        ,ii.CubicFeetPerMasterCarton        ,ii.WeightMasterCarton        ,ii.CubicFeetPerInnerCarton        ,ii.FOBShippingPoint        ,ii.DutyPercent        ,ii.DutyAmount        ,ii.AdditionalDutyComment        ,ii.AdditionalDutyAmount , ii.SuppTariffPercent, ii.SuppTariffAmount,  ii.OceanFreightAmount        ,ii.OceanFreightComputedAmount        ,ii.AgentCommissionPercent As MerchBurdenPercent        ,ii.AgentCommissionAmount As MerchBurdenAmount        ,ii.OtherImportCostsPercent        ,ii.OtherImportCostsAmount        ,ii.PackagingCostAmount        ,ii.TotalImportBurden        ,ii.WarehouseLandedCost        ,ii.PurchaseOrderIssuedTo        ,ii.ShippingPoint        ,ii.CountryOfOrigin        ,ii.CountryOfOriginName        ,ii.VendorComments        ,ii.StockCategory        ,ii.FreightTerms        ,ii.ItemType        ,ii.PackItemIndicator        ,ii.ItemTypeAttribute        ,ii.AllowStoreOrder        ,ii.InventoryControl        ,ii.AutoReplenish        ,ii.PrePriced        ,ii.TaxUDA        ,ii.PrePricedUDA        ,ii.TaxValueUDA        ,ii.Stocking_Strategy_Code       ,ii.StoreSuppZoneGRP        ,ii.WhseSuppZoneGRP        ,ii.POGMaxQty        ,ii.POGSetupPerStore as Initial_Set_Qty_Per_Store    ,ii.OutboundFreight        ,ii.NinePercentWhseCharge        ,ii.TotalStoreLandedCost        ,ii.RDBase as Base1_Retail        ,ii.RDCentral as Base2_Retail        ,ii.RDTest as Test_Retail        ,ii.RDAlaska as Alaska_Retail        ,ii.RDCanada as Canada_Retail        ,ii.RD0Thru9 as High2_Retail        ,ii.RDCalifornia as High3_Retail        ,ii.RDVillageCraft as Small_Market_Retail     ,ii.Retail9 as High1_Retail        ,ii.Retail10 as Base3_Retail        ,ii.Retail11 as Low1_Retail        ,ii.Retail12 as Low2_Retail        ,ii.Retail13 as Manhattan_Retail        ,ii.HazMatYes        ,ii.HazMatNo        ,ii.HazMatMFGCountry        ,ii.HazMatMFGName        ,ii.HazMatMFGFlammable        ,ii.HazMatMFGCity        ,ii.HazMatContainerType        ,ii.HazMatMFGState        ,ii.HazMatContainerSize        ,ii.HazMatMFGPhone        ,ii.HazMatMSDSUOM        ,ii.TSSA        ,ii.CSA        ,ii.UL        ,ii.LicenceAgreement        ,ii.FumigationCertificate        ,ii.KILNDriedCertificate        ,ii.ChinaComInspecNumAndCCIBStickers        ,ii.OriginalVisa        ,ii.TextileDeclarationMidCode        ,ii.QuotaChargeStatement        ,ii.MSDS        ,ii.TSCA        ,ii.DropBallTestCert        ,ii.ManMedicalDeviceListing        ,ii.ManFDARegistration        ,ii.CopyRightIndemnification        ,ii.FishWildLifeCert        ,ii.Proposition65LabelReq        ,ii.CCCR        ,ii.FormaldehydeCompliant        ,ii.Is_Valid        ,ii.Tax_Wizard        ,ii.RMS_Sellable        ,ii.RMS_Orderable        ,ii.RMS_Inventory        ,ii.Parent_ID        ,ii.RegularBatchItem        ,ii.Sequence        ,ii.Store_Total        ,ii.POG_Start_Date        ,ii.POG_Comp_Date        ,ii.Like_Item_SKU        ,ii.Like_Item_Description        ,ii.Like_Item_Retail        ,ii.Like_Item_Regular_Unit        ,ii.Like_Item_Sales        ,ii.Facings        ,ii.POG_Min_Qty        ,ii.Displayer_Cost        ,ii.Product_Cost        ,ii.Calculate_Options        ,ii.Like_Item_Store_Count        ,ii.Like_Item_Unit_Store_Month        ,ii.Annual_Reg_Retail_Sales        ,ii.Annual_Regular_Unit_Forecast        ,ii.Inner_Pack        ,ii.Min_Pres_Per_Facing,    b.Date_Modified as Last_Modified,      case      when isnull(f1.[File_ID], 0) > 0 then ''<a href="getimage.aspx?id='' + convert(varchar(20), f1.[File_ID]) + ''" target="_blank">Image</a>''      else ''''    end as Item_Image,      case      when isnull(f2.[File_ID], 0) > 0 then ''<a href="getfile.aspx?ad=1&id='' + convert(varchar(20), f2.[File_ID]) + ''&filename=importitem_'' + convert(varchar(20), b.ID) + ''_'' + @dateNowStr + ''.pdf">MSDS Sheet</a>''      else ''''    end as MSDS_Sheet    from [SPD_Import_Items] ii       inner join [SPD_Batch] b on ii.Batch_ID = b.ID      left outer join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1      LEFT OUTER JOIN [SPD_Items_Files] f1 ON f1.Item_Type = ''I'' and f1.Item_ID = ii.[ID] and f1.File_Type = ''IMG''       LEFT OUTER JOIN [SPD_Items_Files] f2 ON f2.Item_Type = ''I'' and f2.Item_ID = ii.[ID] and f2.File_Type = ''MSDS''     where     b.enabled = 1 and       (isnull(ii.HazMatYes, '''') != '''') and       (@startDate is null or (@startDate is not null and b.date_modified >= @startDate)) and    (@endDate is null or (@endDate is not null and b.date_modified <= @endDate)) and       (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept)) and    ( (isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 1) = 1 and COALESCE(ws.Stage_Type_id, 1) <> 4 ) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage)) and    ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and b.Vendor_Number = @vendor))'  
where report_name = 'Import Item Chemical Inventory'

update SPD_Report  
set report_sql =
'declare @dateNow datetime      declare @dateNowStr varchar(20)      declare @month varchar(2), @day varchar(2), @year varchar(4)          set @dateNow = getdate()      set @month = convert(varchar(2), Month(@dateNow))      if (len(@month) < 2)          set @month = ''0'' + @month          set @day = convert(varchar(2), Day(@dateNow))      if (len(@day) < 2)          set @day = ''0'' + @day          set @year = convert(varchar(4), Year(@dateNow))      if (len(@year) < 4)          set @year = ''00'' + @year           set @dateNowStr =  @year + @month + @day        select     ii.ID        ,ii.Batch_ID        ,ii.DateCreated        ,ii.DateLastModified        ,ii.CreatedUserID        ,ii.UpdateUserID          ,ii.DateSubmitted        ,ii.Vendor        ,ii.Agent As MerchBurden        ,ii.AgentType As MerchBurdenType        ,ii.Buyer        ,ii.Fax        ,ii.EnteredBy        ,ii.QuoteSheetStatus          ,ii.Season        ,ii.SKUGroup        ,ii.Email        ,ii.EnteredDate        ,ii.Dept        ,ii.Class        ,ii.SubClass        ,ii.PrimaryUPC          ,ii.MichaelsSKU as SKU       ,ii.GenerateMichaelsUPC as GenerateUPC   ,ii.AdditionalUPC1        ,ii.AdditionalUPC2        ,ii.AdditionalUPC3        ,ii.AdditionalUPC4          ,ii.AdditionalUPC5        ,ii.AdditionalUPC6        ,ii.AdditionalUPC7        ,ii.AdditionalUPC8        ,ii.PackSKU        ,ii.PlanogramName          ,ii.VendorNumber        ,ii.VendorRank        ,ii.ItemTask        ,ii.Description        ,ii.PaymentTerms        ,ii.Days        ,ii.VendorMinOrderAmount          ,ii.VendorName        ,ii.VendorAddress1        ,ii.VendorAddress2        ,ii.VendorAddress3        ,ii.VendorAddress4        ,ii.VendorContactName          ,ii.VendorContactPhone        ,ii.VendorContactEmail        ,ii.VendorContactFax        ,ii.ManufactureName        ,ii.ManufactureAddress1          ,ii.ManufactureAddress2        ,ii.ManufactureContact        ,ii.ManufacturePhone        ,ii.ManufactureEmail        ,ii.ManufactureFax          ,ii.AgentContact        ,ii.AgentPhone        ,ii.AgentEmail        ,ii.AgentFax        ,ii.VendorStyleNumber        ,ii.HarmonizedCodeNumber, ii.CanadaHarmonizedCodeNumber           ,ii.DetailInvoiceCustomsDesc        ,ii.ComponentMaterialBreakdown        ,ii.ComponentConstructionMethod        ,ii.IndividualItemPackaging          ,ii.EachInsideMasterCaseBox        ,ii.EachInsideInnerPack        ,ii.ReshippableInnerCartonWeight        ,ii.ReshippableInnerCartonLength          ,ii.ReshippableInnerCartonWidth        ,ii.ReshippableInnerCartonHeight        ,ii.MasterCartonDimensionsLength        ,ii.MasterCartonDimensionsWidth          ,ii.MasterCartonDimensionsHeight        ,ii.CubicFeetPerMasterCarton        ,ii.WeightMasterCarton        ,ii.CubicFeetPerInnerCarton        ,ii.FOBShippingPoint          ,ii.DutyPercent        ,ii.DutyAmount        ,ii.AdditionalDutyComment        ,ii.AdditionalDutyAmount, ii.SuppTariffPercent, ii.SuppTariffAmount        ,ii.OceanFreightAmount        ,ii.OceanFreightComputedAmount          ,ii.AgentCommissionPercent As MerchBurdenPercent        ,ii.AgentCommissionAmount As MerchBurdenAmount        ,ii.OtherImportCostsPercent        ,ii.OtherImportCostsAmount        ,ii.PackagingCostAmount          ,ii.TotalImportBurden        ,ii.WarehouseLandedCost        ,ii.PurchaseOrderIssuedTo        ,ii.ShippingPoint        ,ii.CountryOfOrigin          ,ii.CountryOfOriginName        ,ii.VendorComments        ,ii.StockCategory        ,ii.FreightTerms        ,ii.ItemType        ,ii.PackItemIndicator          ,ii.ItemTypeAttribute        ,ii.AllowStoreOrder        ,ii.InventoryControl        ,ii.AutoReplenish        ,ii.PrePriced        ,ii.TaxUDA          ,ii.PrePricedUDA        ,ii.TaxValueUDA        ,ii.Stocking_Strategy_Code      ,ii.StoreSuppZoneGRP          ,ii.WhseSuppZoneGRP        ,ii.POGMaxQty        ,ii.POGSetupPerStore as Initial_Set_Qty_Per_Store        ,ii.OutboundFreight        ,ii.NinePercentWhseCharge          ,ii.TotalStoreLandedCost        ,ii.RDBase as Base1_Retail        ,ii.RDCentral as Base2_Retail        ,ii.RDTest as Test_Retail        ,ii.RDAlaska as Alaska_Retail          ,ii.RDCanada as Canada_Retail        ,ii.RD0Thru9 as High2_Retail        ,ii.RDCalifornia as High3_Retail        ,ii.RDVillageCraft as Small_Market_Retail       ,ii.Retail9 as High1_Retail        ,ii.Retail10 as Base3_Retail        ,ii.Retail11 as Low1_Retail        ,ii.Retail12 as Low2_Retail          ,ii.Retail13 as Manhattan_Retail        ,ii.RDQuebec as Q5_Retail, ii.RDPuertoRico as PR_Retail ,ii.HazMatYes        ,ii.HazMatNo          ,ii.HazMatMFGCountry        ,ii.HazMatMFGName        ,ii.HazMatMFGFlammable        ,ii.HazMatMFGCity        ,ii.HazMatContainerType        ,ii.HazMatMFGState          ,ii.HazMatContainerSize        ,ii.HazMatMFGPhone        ,ii.HazMatMSDSUOM        ,ii.TSSA        ,ii.CSA        ,ii.UL        ,ii.LicenceAgreement          ,ii.FumigationCertificate        ,ii.KILNDriedCertificate        ,ii.ChinaComInspecNumAndCCIBStickers        ,ii.OriginalVisa        ,ii.TextileDeclarationMidCode          ,ii.QuotaChargeStatement        ,ii.MSDS        ,ii.TSCA        ,ii.DropBallTestCert        ,ii.ManMedicalDeviceListing        ,ii.ManFDARegistration          ,ii.CopyRightIndemnification        ,ii.FishWildLifeCert        ,ii.Proposition65LabelReq        ,ii.CCCR        ,ii.FormaldehydeCompliant        ,ii.Is_Valid          ,ii.Tax_Wizard        ,ii.RMS_Sellable        ,ii.RMS_Orderable        ,ii.RMS_Inventory        ,ii.Parent_ID        ,ii.RegularBatchItem        ,ii.Sequence          ,ii.Store_Total        ,ii.POG_Start_Date        ,ii.POG_Comp_Date        ,ii.Like_Item_SKU        ,ii.Like_Item_Description        ,ii.Like_Item_Retail          ,ii.Like_Item_Regular_Unit        ,ii.Like_Item_Sales        ,ii.Facings        ,ii.POG_Min_Qty        ,ii.Displayer_Cost        ,ii.Product_Cost        ,ii.Calculate_Options          ,ii.Like_Item_Store_Count        ,ii.Like_Item_Unit_Store_Month        ,ii.Annual_Reg_Retail_Sales        ,ii.Annual_Regular_Unit_Forecast        ,ii.Inner_Pack        ,ii.Min_Pres_Per_Facing,      COALESCE(lv.Display_Text, '''') as Private_Brand_Label  ,ii.QuoteReferenceNumber, ii.Customs_Description,   l1.Package_Language_Indicator as Package_Language_Indicator_English,   l2.Package_Language_Indicator as Package_Language_Indicator_French,   l3.Package_Language_Indicator as Package_Language_Indicator_Spanish,   l1.Translation_Indicator as Translation_Indicator_English,   l2.Translation_Indicator as Translation_Indicator_French,   l3.Translation_Indicator as Translation_Indicator_Spanish, l1.Description_Short as English_Short_Description, l1.Description_Long as English_Long_Description  ,l2.Description_Short as French_Short_Description, l2.Description_Long as French_Long_Description, l3.Description_Short as Spanish_Short_Description, l3.Description_Long as Spanish_Long_Description  ,b.Date_Modified as Last_Modified,     case      when isnull(f1.[File_ID], 0) > 0 then ''<a href="getimage.aspx?id='' + convert(varchar(20), f1.[File_ID]) + ''" target="_blank">Image</a>''      else ''''    end as Item_Image,        case      when isnull(f2.[File_ID], 0) > 0 then ''<a href="getfile.aspx?ad=1&id='' + convert(varchar(20), f2.[File_ID]) + ''&filename=importitem_'' + convert(varchar(20), b.ID) + ''_'' + @dateNowStr + ''.pdf">MSDS Sheet</a>''      else ''''    end as MSDS_Sheet      from [SPD_Import_Items] ii         inner join [SPD_Batch] b on ii.Batch_ID = b.ID        left outer join SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 1        LEFT OUTER JOIN [SPD_Items_Files] f1 ON f1.Item_Type = ''I'' and f1.Item_ID = ii.[ID] and f1.File_Type = ''IMG''         LEFT OUTER JOIN [SPD_Items_Files] f2 ON f2.Item_Type = ''I'' and f2.Item_ID = ii.[ID] and f2.File_Type = ''MSDS''       LEFT OUTER JOIN SPD_Import_Item_Languages as l1 on l1.Import_Item_ID = ii.ID AND l1.Language_Type_ID = 1    LEFT OUTER JOIN SPD_Import_Item_Languages as l2 on l2.Import_Item_ID = ii.ID AND l2.Language_Type_ID = 2    LEFT OUTER JOIN SPD_Import_Item_Languages as l3 on l3.Import_Item_ID = ii.ID AND l3.Language_Type_ID = 3    LEFT OUTER JOIN List_Values as lv on lv.List_Value_Group_ID = 16 And ii.Private_Brand_Label = lv.List_Value    where     b.enabled = 1 and       (@startDate is null or (@startDate is not null and b.date_modified >= @startDate)) and    (@endDate is null or (@endDate is not null and b.date_modified <= @endDate)) and       (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept)) and    ((isnull(@stage, 0) = 0 and COALESCE(ws.Workflow_id, 1) = 1 and COALESCE(ws.Stage_Type_id, 1) <> 4) or (isnull(@stage, 0) > 0 and b.Workflow_Stage_ID = @stage)) and     ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and b.Vendor_Number = @vendor))'  
where report_name = 'Import Item Language'

--------------------------------------------------------------------------------------------------

--*****************************
--Import SPD_Item_Mapping_Columns - bulk item
--*****************************

--------------------------------------------------------------------------------------------------

update SPD_Item_Mapping_Columns
set Column_Name = 'SuppTariffPercent' 
where Excel_Column = 'BZ' and Excel_Row = 1
and Item_Mapping_ID = 
(
Select ID from SPD_Item_Mapping where Mapping_Name = 'BULKMAINT'
)



--------------------------------------------------------------------------------------------------