SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--*****************************************************************************
--ColumnDisplayName new fields and dispable Source DC -- NEW DOMESTIC
--*****************************************************************************

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'D',	'Each_Case_Height',	0,	'decimal',	'formatnumber',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Height',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	1
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'D',	'Each_Case_Width',	0,	'decimal',	'formatnumber',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Width',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	1
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'D',	'Each_Case_Length',	0,	'decimal',	'formatnumber',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Length',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	1
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'D',	'Each_Case_Weight',	0,	'decimal',	'formatnumber',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Weight',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	1
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'D',	'Each_Case_Pack_Cube',	0,	'decimal',	'formatnumber3',	NULL,	0,
1,	1,	1,	1,	0,	0,	1,	1,
'Each Case<br />Pack Cube',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	1
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'D',	'Stocking_Strategy_Code',	0,	'string',	'listvalue',	'STOCKSTRAT',	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Stocking Strategy<br />Code',	0,	5,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	1
)


--*****************************************************************************
--remove columns 
--*****************************************************************************
Delete ColumnDisplayName where Workflow_ID = 1  
and Column_Name in
(
'Hybrid_Type',
'Hybrid_Source_DC',
'Hybrid_Lead_Time',
'Hybrid_Conversion_Date'
)


--*****************************************************************************
--Update order of ColumnDisplayName for New Item
--*****************************************************************************
Update ColumnDisplayName set column_ordinal = 1 where workflow_id = 1 and column_name = 'Vendor_UPC'
Update ColumnDisplayName set column_ordinal = 2 where workflow_id = 1 and column_name = 'Vendor_Style_Num'
Update ColumnDisplayName set column_ordinal = 3 where workflow_id = 1 and column_name = 'Additional_UPC_Count'
Update ColumnDisplayName set column_ordinal = 4 where workflow_id = 1 and column_name = 'Add_Change'
Update ColumnDisplayName set column_ordinal = 5 where workflow_id = 1 and column_name = 'Pack_Item_Indicator'
Update ColumnDisplayName set column_ordinal = 6 where workflow_id = 1 and column_name = 'Michaels_SKU'
Update ColumnDisplayName set column_ordinal = 7 where workflow_id = 1 and column_name = 'Class_Num'
Update ColumnDisplayName set column_ordinal = 8 where workflow_id = 1 and column_name = 'Sub_Class_Num'
Update ColumnDisplayName set column_ordinal = 9 where workflow_id = 1 and column_name = 'Item_Desc'
Update ColumnDisplayName set column_ordinal = 10 where workflow_id = 1 and column_name = 'Private_Brand_Label'
Update ColumnDisplayName set column_ordinal = 11 where workflow_id = 1 and column_name = 'Hybrid_Type'
Update ColumnDisplayName set column_ordinal = 12 where workflow_id = 1 and column_name = 'Hybrid_Source_DC'
Update ColumnDisplayName set column_ordinal = 12 where workflow_id = 1 and column_name = 'Stocking_Strategy_Code'
Update ColumnDisplayName set column_ordinal = 13 where workflow_id = 1 and column_name = 'Hybrid_Lead_Time'
Update ColumnDisplayName set column_ordinal = 14 where workflow_id = 1 and column_name = 'Hybrid_Conversion_Date'
Update ColumnDisplayName set column_ordinal = 15 where workflow_id = 1 and column_name = 'Qty_In_Pack'
Update ColumnDisplayName set column_ordinal = 16 where workflow_id = 1 and column_name = 'Eaches_Master_Case'
Update ColumnDisplayName set column_ordinal = 17 where workflow_id = 1 and column_name = 'Eaches_Inner_Pack'
Update ColumnDisplayName set column_ordinal = 18 where workflow_id = 1 and column_name = 'Pre_Priced'
Update ColumnDisplayName set column_ordinal = 19 where workflow_id = 1 and column_name = 'Pre_Priced_UDA'
Update ColumnDisplayName set column_ordinal = 20 where workflow_id = 1 and column_name = 'US_Cost'
Update ColumnDisplayName set column_ordinal = 21 where workflow_id = 1 and column_name = 'Total_US_Cost'
Update ColumnDisplayName set column_ordinal = 22 where workflow_id = 1 and column_name = 'Canada_Cost'
Update ColumnDisplayName set column_ordinal = 23 where workflow_id = 1 and column_name = 'Total_Canada_Cost'
Update ColumnDisplayName set column_ordinal = 24 where workflow_id = 1 and column_name = 'Base_Retail'
Update ColumnDisplayName set column_ordinal = 25 where workflow_id = 1 and column_name = 'Central_Retail'
Update ColumnDisplayName set column_ordinal = 26 where workflow_id = 1 and column_name = 'Test_Retail'
Update ColumnDisplayName set column_ordinal = 27 where workflow_id = 1 and column_name = 'Alaska_Retail'
Update ColumnDisplayName set column_ordinal = 28 where workflow_id = 1 and column_name = 'Canada_Retail'
Update ColumnDisplayName set column_ordinal = 29 where workflow_id = 1 and column_name = 'Zero_Nine_Retail'
Update ColumnDisplayName set column_ordinal = 30 where workflow_id = 1 and column_name = 'California_Retail'
Update ColumnDisplayName set column_ordinal = 31 where workflow_id = 1 and column_name = 'Village_Craft_Retail'
Update ColumnDisplayName set column_ordinal = 32 where workflow_id = 1 and column_name = 'Retail9'
Update ColumnDisplayName set column_ordinal = 33 where workflow_id = 1 and column_name = 'Retail10'
Update ColumnDisplayName set column_ordinal = 34 where workflow_id = 1 and column_name = 'Retail11'
Update ColumnDisplayName set column_ordinal = 35 where workflow_id = 1 and column_name = 'Retail12'
Update ColumnDisplayName set column_ordinal = 36 where workflow_id = 1 and column_name = 'Retail13'
Update ColumnDisplayName set column_ordinal = 37 where workflow_id = 1 and column_name = 'RDQuebec'
Update ColumnDisplayName set column_ordinal = 38 where workflow_id = 1 and column_name = 'RDPuertoRico'
Update ColumnDisplayName set column_ordinal = 39 where workflow_id = 1 and column_name = 'Each_Case_Height'
Update ColumnDisplayName set column_ordinal = 40 where workflow_id = 1 and column_name = 'Each_Case_Width'
Update ColumnDisplayName set column_ordinal = 41 where workflow_id = 1 and column_name = 'Each_Case_Length'
Update ColumnDisplayName set column_ordinal = 42 where workflow_id = 1 and column_name = 'Each_Case_Weight'
Update ColumnDisplayName set column_ordinal = 43 where workflow_id = 1 and column_name = 'Each_Case_Pack_Cube'
Update ColumnDisplayName set column_ordinal = 44 where workflow_id = 1 and column_name = 'Inner_Case_Height'
Update ColumnDisplayName set column_ordinal = 45 where workflow_id = 1 and column_name = 'Inner_Case_Width'
Update ColumnDisplayName set column_ordinal = 46 where workflow_id = 1 and column_name = 'Inner_Case_Length'
Update ColumnDisplayName set column_ordinal = 47 where workflow_id = 1 and column_name = 'Inner_Case_Weight'
Update ColumnDisplayName set column_ordinal = 48 where workflow_id = 1 and column_name = 'Inner_Case_Pack_Cube'
Update ColumnDisplayName set column_ordinal = 49 where workflow_id = 1 and column_name = 'Master_Case_Height'
Update ColumnDisplayName set column_ordinal = 50 where workflow_id = 1 and column_name = 'Master_Case_Width'
Update ColumnDisplayName set column_ordinal = 51 where workflow_id = 1 and column_name = 'Master_Case_Length'
Update ColumnDisplayName set column_ordinal = 52 where workflow_id = 1 and column_name = 'Master_Case_Weight'
Update ColumnDisplayName set column_ordinal = 53 where workflow_id = 1 and column_name = 'Master_Case_Pack_Cube'
Update ColumnDisplayName set column_ordinal = 54 where workflow_id = 1 and column_name = 'Country_Of_Origin_Name'
Update ColumnDisplayName set column_ordinal = 55 where workflow_id = 1 and column_name = 'Tax_Wizard'
Update ColumnDisplayName set column_ordinal = 56 where workflow_id = 1 and column_name = 'Tax_UDA'
Update ColumnDisplayName set column_ordinal = 57 where workflow_id = 1 and column_name = 'Tax_Value_UDA'
Update ColumnDisplayName set column_ordinal = 58 where workflow_id = 1 and column_name = 'Hazardous'
Update ColumnDisplayName set column_ordinal = 59 where workflow_id = 1 and column_name = 'Hazardous_Flammable'
Update ColumnDisplayName set column_ordinal = 60 where workflow_id = 1 and column_name = 'Hazardous_Container_Type'
Update ColumnDisplayName set column_ordinal = 61 where workflow_id = 1 and column_name = 'Hazardous_Container_Size'
Update ColumnDisplayName set column_ordinal = 62 where workflow_id = 1 and column_name = 'Hazardous_MSDS_UOM'
Update ColumnDisplayName set column_ordinal = 63 where workflow_id = 1 and column_name = 'Hazardous_Manufacturer_Name'
Update ColumnDisplayName set column_ordinal = 64 where workflow_id = 1 and column_name = 'Hazardous_Manufacturer_City'
Update ColumnDisplayName set column_ordinal = 65 where workflow_id = 1 and column_name = 'Hazardous_Manufacturer_State'
Update ColumnDisplayName set column_ordinal = 66 where workflow_id = 1 and column_name = 'Hazardous_Manufacturer_Phone'
Update ColumnDisplayName set column_ordinal = 67 where workflow_id = 1 and column_name = 'Hazardous_Manufacturer_Country'
Update ColumnDisplayName set column_ordinal = 70 where workflow_id = 1 and column_name = 'Like_Item_SKU'
Update ColumnDisplayName set column_ordinal = 71 where workflow_id = 1 and column_name = 'Like_Item_Description'
Update ColumnDisplayName set column_ordinal = 72 where workflow_id = 1 and column_name = 'Like_Item_Retail'
Update ColumnDisplayName set column_ordinal = 73 where workflow_id = 1 and column_name = 'Annual_Regular_Unit_Forecast'
Update ColumnDisplayName set column_ordinal = 74 where workflow_id = 1 and column_name = 'Like_Item_Unit_Store_Month'
Update ColumnDisplayName set column_ordinal = 75 where workflow_id = 1 and column_name = 'Like_Item_Store_Count'
Update ColumnDisplayName set column_ordinal = 76 where workflow_id = 1 and column_name = 'Like_Item_Regular_Unit'
Update ColumnDisplayName set column_ordinal = 77 where workflow_id = 1 and column_name = 'Annual_Reg_Retail_Sales'
Update ColumnDisplayName set column_ordinal = 78 where workflow_id = 1 and column_name = 'Facings'
Update ColumnDisplayName set column_ordinal = 79 where workflow_id = 1 and column_name = 'POG_Min_Qty'
Update ColumnDisplayName set column_ordinal = 80 where workflow_id = 1 and column_name = 'POG_Max_Qty'
Update ColumnDisplayName set column_ordinal = 81 where workflow_id = 1 and column_name = 'POG_Setup_Per_Store'
Update ColumnDisplayName set column_ordinal = 82 where workflow_id = 1 and column_name = 'QuoteReferenceNumber'
Update ColumnDisplayName set column_ordinal = 83 where workflow_id = 1 and column_name = 'PLIEnglish'
Update ColumnDisplayName set column_ordinal = 84 where workflow_id = 1 and column_name = 'PLIFrench'
Update ColumnDisplayName set column_ordinal = 85 where workflow_id = 1 and column_name = 'PLISpanish'
Update ColumnDisplayName set column_ordinal = 86 where workflow_id = 1 and column_name = 'ExemptEndDateFrench'
Update ColumnDisplayName set column_ordinal = 87 where workflow_id = 1 and column_name = 'TIEnglish'
Update ColumnDisplayName set column_ordinal = 88 where workflow_id = 1 and column_name = 'TIFrench'
Update ColumnDisplayName set column_ordinal = 89 where workflow_id = 1 and column_name = 'TISpanish'
Update ColumnDisplayName set column_ordinal = 90 where workflow_id = 1 and column_name = 'Customs_Description'
Update ColumnDisplayName set column_ordinal = 91 where workflow_id = 1 and column_name = 'EnglishShortDescription'
Update ColumnDisplayName set column_ordinal = 92 where workflow_id = 1 and column_name = 'EnglishLongDescription'
Update ColumnDisplayName set column_ordinal = 93 where workflow_id = 1 and column_name = 'FrenchShortDescription'
Update ColumnDisplayName set column_ordinal = 94 where workflow_id = 1 and column_name = 'FrenchLongDescription'
Update ColumnDisplayName set column_ordinal = 95 where workflow_id = 1 and column_name = 'SpanishShortDescription'
Update ColumnDisplayName set column_ordinal = 96 where workflow_id = 1 and column_name = 'SpanishLongDescription'
Update ColumnDisplayName set column_ordinal = 97 where workflow_id = 1 and column_name = 'Harmonized_Code_Number'
Update ColumnDisplayName set column_ordinal = 98 where workflow_id = 1 and column_name = 'Canada_Harmonized_Code_Number'
Update ColumnDisplayName set column_ordinal = 100 where workflow_id = 1 and column_name = 'Detail_Invoice_Customs_Desc'
Update ColumnDisplayName set column_ordinal = 101 where workflow_id = 1 and column_name = 'Component_Material_Breakdown'
Update ColumnDisplayName set column_ordinal = 102 where workflow_id = 1 and column_name = 'Image_ID'
Update ColumnDisplayName set column_ordinal = 103 where workflow_id = 1 and column_name = 'MSDS_ID'

--*****************************************************************************
--Insert new Each pack ColumnDisplayName ordinals ITEM MAINT
--*****************************************************************************

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseHeight',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Height',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	2
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseWidth',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Width',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	2
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseLength',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Length',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	2
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseWeight',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Weight',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	2
)

Insert into ColumnDisplayName 
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseCube',	24,	'decimal',	'formatnumber3',	NULL,	0,
1,	1,	1,	1,	0,	0,	1,	1,
'Each Case<br />Pack Cube',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	2
)

--*****************************************************************************
--Insert new Each pack ColumnDisplayName ordinals ITEM MAINT BULK
--*****************************************************************************

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseHeight',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Height',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	7
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseWidth',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Width',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	7
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseLength',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Length',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	7
)

Insert into ColumnDisplayName
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseWeight',	24,	'decimal',	'formatnumber4',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Each Case<br />Pack Weight',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	7
)

Insert into ColumnDisplayName 
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'X',	'EachCaseCube',	24,	'decimal',	'formatnumber3',	NULL,	0,
1,	1,	1,	1,	0,	0,	1,	1,
'Each Case<br />Pack Cube',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	7
)

Insert into ColumnDisplayName 
(
Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	Column_Format_String,	Fixed_Column,
Allow_Sort,	Allow_Filter,	Allow_UserDisable,	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	Date_Created,	GUID,	Workflow_ID)
values
(
'D',	'CanadaHarmonizedCodeNumber',	75,	'string',	'string',	NULL,	0,
1,	1,	1,	1,	1,	0,	1,	1,
'Canada Harmonized<br />Code No.',	0,	10,	NULL,	GETDATE(),	GETDATE(),	NEWID(),	7
)

update ColumnDisplayName set Column_Type = 'D' where Workflow_ID = 7 and Column_Name = 'HarmonizedCodeNumber';

update ColumnDisplayName set Column_Type = 'X' where Workflow_ID in (2,7)  and Column_Name = 'InnerCaseWeight';


--*****************************************************************************
--Update order of ColumnDisplayName for Item Maint
--*****************************************************************************
Update ColumnDisplayName set column_ordinal = 1 where workflow_id = 2 and column_name = 'SKU'
Update ColumnDisplayName set column_ordinal = 2 where workflow_id = 2 and column_name = 'VendorNumber'
Update ColumnDisplayName set column_ordinal = 3 where workflow_id = 2 and column_name = 'PrimaryUPC'
Update ColumnDisplayName set column_ordinal = 4 where workflow_id = 2 and column_name = 'ItemStatus'
Update ColumnDisplayName set column_ordinal = 5 where workflow_id = 2 and column_name = 'VendorStyleNum'
Update ColumnDisplayName set column_ordinal = 6 where workflow_id = 2 and column_name = 'AdditionalUPCs'
Update ColumnDisplayName set column_ordinal = 7 where workflow_id = 2 and column_name = 'ItemDesc'
Update ColumnDisplayName set column_ordinal = 8 where workflow_id = 2 and column_name = 'ClassNum'
Update ColumnDisplayName set column_ordinal = 9 where workflow_id = 2 and column_name = 'SubClassNum'
Update ColumnDisplayName set column_ordinal = 10 where workflow_id = 2 and column_name = 'PrivateBrandLabel'
Update ColumnDisplayName set column_ordinal = 11 where workflow_id = 2 and column_name = 'PackItemIndicator'
Update ColumnDisplayName set column_ordinal = 12 where workflow_id = 2 and column_name = 'QtyInPack'
Update ColumnDisplayName set column_ordinal = 13 where workflow_id = 2 and column_name = 'EachesMasterCase'
Update ColumnDisplayName set column_ordinal = 14 where workflow_id = 2 and column_name = 'EachesInnerPack'
Update ColumnDisplayName set column_ordinal = 15 where workflow_id = 2 and column_name = 'AllowStoreOrder'
Update ColumnDisplayName set column_ordinal = 16 where workflow_id = 2 and column_name = 'InventoryControl'
Update ColumnDisplayName set column_ordinal = 17 where workflow_id = 2 and column_name = 'Discountable'
Update ColumnDisplayName set column_ordinal = 18 where workflow_id = 2 and column_name = 'AutoReplenish'
Update ColumnDisplayName set column_ordinal = 19 where workflow_id = 2 and column_name = 'PrePriced'
Update ColumnDisplayName set column_ordinal = 20 where workflow_id = 2 and column_name = 'PrePricedUDA'
Update ColumnDisplayName set column_ordinal = 21 where workflow_id = 2 and column_name = 'DisplayerCost'
Update ColumnDisplayName set column_ordinal = 22 where workflow_id = 2 and column_name = 'ItemCost'
Update ColumnDisplayName set column_ordinal = 23 where workflow_id = 2 and column_name = 'FOBShippingPoint'
Update ColumnDisplayName set column_ordinal = 24 where workflow_id = 2 and column_name = 'EachCaseHeight'
Update ColumnDisplayName set column_ordinal = 25 where workflow_id = 2 and column_name = 'EachCaseWidth'
Update ColumnDisplayName set column_ordinal = 26 where workflow_id = 2 and column_name = 'EachCaseLength'
Update ColumnDisplayName set column_ordinal = 27 where workflow_id = 2 and column_name = 'EachCaseCube'
Update ColumnDisplayName set column_ordinal = 28 where workflow_id = 2 and column_name = 'EachCaseWeight'
Update ColumnDisplayName set column_ordinal = 29 where workflow_id = 2 and column_name = 'InnerCaseHeight'
Update ColumnDisplayName set column_ordinal = 30 where workflow_id = 2 and column_name = 'InnerCaseWidth'
Update ColumnDisplayName set column_ordinal = 31 where workflow_id = 2 and column_name = 'InnerCaseLength'
Update ColumnDisplayName set column_ordinal = 32 where workflow_id = 2 and column_name = 'InnerCaseCube'
Update ColumnDisplayName set column_ordinal = 33 where workflow_id = 2 and column_name = 'InnerCaseCubeUOM'
Update ColumnDisplayName set column_ordinal = 34 where workflow_id = 2 and column_name = 'InnerCaseWeight'
Update ColumnDisplayName set column_ordinal = 35 where workflow_id = 2 and column_name = 'InnerCaseWeightUOM'
Update ColumnDisplayName set column_ordinal = 36 where workflow_id = 2 and column_name = 'MasterCaseHeight'
Update ColumnDisplayName set column_ordinal = 37 where workflow_id = 2 and column_name = 'MasterCaseWidth'
Update ColumnDisplayName set column_ordinal = 38 where workflow_id = 2 and column_name = 'MasterCaseLength'
Update ColumnDisplayName set column_ordinal = 39 where workflow_id = 2 and column_name = 'MasterCaseCube'
Update ColumnDisplayName set column_ordinal = 40 where workflow_id = 2 and column_name = 'MasterCaseCubeUOM'
Update ColumnDisplayName set column_ordinal = 41 where workflow_id = 2 and column_name = 'MasterCaseWeight'
Update ColumnDisplayName set column_ordinal = 42 where workflow_id = 2 and column_name = 'MasterCaseWeightUOM'
Update ColumnDisplayName set column_ordinal = 43 where workflow_id = 2 and column_name = 'CountryOfOriginName'
Update ColumnDisplayName set column_ordinal = 44 where workflow_id = 2 and column_name = 'TaxUDA'
Update ColumnDisplayName set column_ordinal = 45 where workflow_id = 2 and column_name = 'TaxValueUDA'
Update ColumnDisplayName set column_ordinal = 46 where workflow_id = 2 and column_name = 'VendorOrAgent'
Update ColumnDisplayName set column_ordinal = 47 where workflow_id = 2 and column_name = 'DisplayerCost'
Update ColumnDisplayName set column_ordinal = 48 where workflow_id = 2 and column_name = 'ProductCost'
Update ColumnDisplayName set column_ordinal = 49 where workflow_id = 2 and column_name = 'FOBShippingPoint'
Update ColumnDisplayName set column_ordinal = 50 where workflow_id = 2 and column_name = 'DutyPercent'
Update ColumnDisplayName set column_ordinal = 51 where workflow_id = 2 and column_name = 'DutyAmount'
Update ColumnDisplayName set column_ordinal = 52 where workflow_id = 2 and column_name = 'AdditionalDutyComment'
Update ColumnDisplayName set column_ordinal = 53 where workflow_id = 2 and column_name = 'AdditionalDutyAmount'
Update ColumnDisplayName set column_ordinal = 54 where workflow_id = 2 and column_name = 'OceanFreightAmount'
Update ColumnDisplayName set column_ordinal = 55 where workflow_id = 2 and column_name = 'OceanFreightComputedAmount'
Update ColumnDisplayName set column_ordinal = 56 where workflow_id = 2 and column_name = 'AgentCommissionPercent'
Update ColumnDisplayName set column_ordinal = 57 where workflow_id = 2 and column_name = 'AgentCommissionAmount'
Update ColumnDisplayName set column_ordinal = 58 where workflow_id = 2 and column_name = 'OtherImportCostsPercent'
Update ColumnDisplayName set column_ordinal = 59 where workflow_id = 2 and column_name = 'OtherImportCostsAmount'
Update ColumnDisplayName set column_ordinal = 60 where workflow_id = 2 and column_name = 'ImportBurden'
Update ColumnDisplayName set column_ordinal = 61 where workflow_id = 2 and column_name = 'WarehouseLandedCost'
Update ColumnDisplayName set column_ordinal = 62 where workflow_id = 2 and column_name = 'OutboundFreight'
Update ColumnDisplayName set column_ordinal = 63 where workflow_id = 2 and column_name = 'NinePercentWhseCharge'
Update ColumnDisplayName set column_ordinal = 64 where workflow_id = 2 and column_name = 'TotalStoreLandedCost'
Update ColumnDisplayName set column_ordinal = 65 where workflow_id = 2 and column_name = 'ShippingPoint'
Update ColumnDisplayName set column_ordinal = 66 where workflow_id = 2 and column_name = 'PlanogramName'
Update ColumnDisplayName set column_ordinal = 67 where workflow_id = 2 and column_name = 'Hazardous'
Update ColumnDisplayName set column_ordinal = 68 where workflow_id = 2 and column_name = 'HazardousFlammable'
Update ColumnDisplayName set column_ordinal = 69 where workflow_id = 2 and column_name = 'HazardousContainerType'
Update ColumnDisplayName set column_ordinal = 70 where workflow_id = 2 and column_name = 'HazardousContainerSize'
Update ColumnDisplayName set column_ordinal = 71 where workflow_id = 2 and column_name = 'HazardousMSDSUOM'
Update ColumnDisplayName set column_ordinal = 72 where workflow_id = 2 and column_name = 'HazardousManufacturerName'
Update ColumnDisplayName set column_ordinal = 73 where workflow_id = 2 and column_name = 'HazardousManufacturerCity'
Update ColumnDisplayName set column_ordinal = 74 where workflow_id = 2 and column_name = 'HazardousManufacturerState'
Update ColumnDisplayName set column_ordinal = 75 where workflow_id = 2 and column_name = 'HazardousManufacturerPhone'
Update ColumnDisplayName set column_ordinal = 76 where workflow_id = 2 and column_name = 'HazardousManufacturerCountry'
Update ColumnDisplayName set column_ordinal = 79 where workflow_id = 2 and column_name = 'QuoteReferenceNumber'
Update ColumnDisplayName set column_ordinal = 79 where workflow_id = 2 and column_name = 'QuoteReferenceNumber'
Update ColumnDisplayName set column_ordinal = 80 where workflow_id = 2 and column_name = 'PLIEnglish'
Update ColumnDisplayName set column_ordinal = 81 where workflow_id = 2 and column_name = 'PLIFrench'
Update ColumnDisplayName set column_ordinal = 82 where workflow_id = 2 and column_name = 'PLISpanish'
Update ColumnDisplayName set column_ordinal = 84 where workflow_id = 2 and column_name = 'TIEnglish'
Update ColumnDisplayName set column_ordinal = 85 where workflow_id = 2 and column_name = 'TIFrench'
Update ColumnDisplayName set column_ordinal = 86 where workflow_id = 2 and column_name = 'TISpanish'
Update ColumnDisplayName set column_ordinal = 87 where workflow_id = 2 and column_name = 'CustomsDescription'
Update ColumnDisplayName set column_ordinal = 88 where workflow_id = 2 and column_name = 'EnglishShortDescription'
Update ColumnDisplayName set column_ordinal = 89 where workflow_id = 2 and column_name = 'EnglishLongDescription'
Update ColumnDisplayName set column_ordinal = 90 where workflow_id = 2 and column_name = 'FrenchShortDescription'
Update ColumnDisplayName set column_ordinal = 91 where workflow_id = 2 and column_name = 'FrenchLongDescription'
Update ColumnDisplayName set column_ordinal = 92 where workflow_id = 2 and column_name = 'SpanishShortDescription'
Update ColumnDisplayName set column_ordinal = 93 where workflow_id = 2 and column_name = 'SpanishLongDescription'
Update ColumnDisplayName set column_ordinal = 94 where workflow_id = 2 and column_name = 'ExemptEndDateFrench'
Update ColumnDisplayName set column_ordinal = 95 where workflow_id = 2 and column_name = 'HarmonizedCodeNumber'
Update ColumnDisplayName set column_ordinal = 96 where workflow_id = 2 and column_name = 'CanadaHarmonizedCodeNumber'
Update ColumnDisplayName set column_ordinal = 97 where workflow_id = 2 and column_name = 'DetailInvoiceCustomsDesc0'
Update ColumnDisplayName set column_ordinal = 98 where workflow_id = 2 and column_name = 'ComponentMaterialBreakdown0'
Update ColumnDisplayName set column_ordinal = 102 where workflow_id = 2 and column_name = 'ImageID'
Update ColumnDisplayName set column_ordinal = 103 where workflow_id = 2 and column_name = 'MSDSID'


--*****************************************************************************
--Update order of ColumnDisplayName for Item Maint BULK
--*****************************************************************************
Update ColumnDisplayName set column_ordinal = 1 where workflow_id = 7 and column_name = 'SKU'
Update ColumnDisplayName set column_ordinal = 2 where workflow_id = 7 and column_name = 'VendorNumber'
Update ColumnDisplayName set column_ordinal = 3 where workflow_id = 7 and column_name = 'VendorName'
Update ColumnDisplayName set column_ordinal = 4 where workflow_id = 7 and column_name = 'VendorType'
Update ColumnDisplayName set column_ordinal = 5 where workflow_id = 7 and column_name = 'VendorStyleNum'
Update ColumnDisplayName set column_ordinal = 6 where workflow_id = 7 and column_name = 'SKUGroup'
Update ColumnDisplayName set column_ordinal = 7 where workflow_id = 7 and column_name = 'PrimaryUPC'
Update ColumnDisplayName set column_ordinal = 8 where workflow_id = 7 and column_name = 'ItemDesc'
Update ColumnDisplayName set column_ordinal = 9 where workflow_id = 7 and column_name = 'DepartmentNum'
Update ColumnDisplayName set column_ordinal = 10 where workflow_id = 7 and column_name = 'ClassNum'
Update ColumnDisplayName set column_ordinal = 11 where workflow_id = 7 and column_name = 'SubClassNum'
Update ColumnDisplayName set column_ordinal = 12 where workflow_id = 7 and column_name = 'PrivateBrandLabel'
Update ColumnDisplayName set column_ordinal = 13 where workflow_id = 7 and column_name = 'ItemTypeAttribute'
Update ColumnDisplayName set column_ordinal = 14 where workflow_id = 7 and column_name = 'PackItemIndicator'
Update ColumnDisplayName set column_ordinal = 15 where workflow_id = 7 and column_name = 'EachesMasterCase'
Update ColumnDisplayName set column_ordinal = 16 where workflow_id = 7 and column_name = 'EachesInnerPack'
Update ColumnDisplayName set column_ordinal = 17 where workflow_id = 7 and column_name = 'AllowStoreOrder'
Update ColumnDisplayName set column_ordinal = 18 where workflow_id = 7 and column_name = 'InventoryControl'
Update ColumnDisplayName set column_ordinal = 19 where workflow_id = 7 and column_name = 'Discountable'
Update ColumnDisplayName set column_ordinal = 20 where workflow_id = 7 and column_name = 'AutoReplenish'
Update ColumnDisplayName set column_ordinal = 21 where workflow_id = 7 and column_name = 'PrePriced'
Update ColumnDisplayName set column_ordinal = 22 where workflow_id = 7 and column_name = 'PrePricedUDA'
Update ColumnDisplayName set column_ordinal = 23 where workflow_id = 7 and column_name = 'ItemCost'
Update ColumnDisplayName set column_ordinal = 24 where workflow_id = 7 and column_name = 'FOBShippingPoint'
Update ColumnDisplayName set column_ordinal = 25 where workflow_id = 7 and column_name = 'ProductCost'
Update ColumnDisplayName set column_ordinal = 26 where workflow_id = 7 and column_name = 'FOBShippingPoint'
Update ColumnDisplayName set column_ordinal = 27 where workflow_id = 7 and column_name = 'EachCaseHeight'
Update ColumnDisplayName set column_ordinal = 28 where workflow_id = 7 and column_name = 'EachCaseWidth'
Update ColumnDisplayName set column_ordinal = 29 where workflow_id = 7 and column_name = 'EachCaseLength'
Update ColumnDisplayName set column_ordinal = 30 where workflow_id = 7 and column_name = 'EachCaseCube'
Update ColumnDisplayName set column_ordinal = 31 where workflow_id = 7 and column_name = 'EachCaseWeight'
Update ColumnDisplayName set column_ordinal = 32 where workflow_id = 7 and column_name = 'InnerCaseHeight'
Update ColumnDisplayName set column_ordinal = 33 where workflow_id = 7 and column_name = 'InnerCaseWidth'
Update ColumnDisplayName set column_ordinal = 34 where workflow_id = 7 and column_name = 'InnerCaseLength'
Update ColumnDisplayName set column_ordinal = 35 where workflow_id = 7 and column_name = 'InnerCaseCube'
Update ColumnDisplayName set column_ordinal = 36 where workflow_id = 7 and column_name = 'InnerCaseWeight'
Update ColumnDisplayName set column_ordinal = 37 where workflow_id = 7 and column_name = 'MasterCaseHeight'
Update ColumnDisplayName set column_ordinal = 38 where workflow_id = 7 and column_name = 'MasterCaseWidth'
Update ColumnDisplayName set column_ordinal = 39 where workflow_id = 7 and column_name = 'MasterCaseLength'
Update ColumnDisplayName set column_ordinal = 40 where workflow_id = 7 and column_name = 'MasterCaseCube'
Update ColumnDisplayName set column_ordinal = 41 where workflow_id = 7 and column_name = 'MasterCaseWeight'
Update ColumnDisplayName set column_ordinal = 42 where workflow_id = 7 and column_name = 'CountryOfOriginName'
Update ColumnDisplayName set column_ordinal = 43 where workflow_id = 7 and column_name = 'TaxUDA'
Update ColumnDisplayName set column_ordinal = 44 where workflow_id = 7 and column_name = 'TaxValueUDA'
Update ColumnDisplayName set column_ordinal = 45 where workflow_id = 7 and column_name = 'VendorOrAgent'
Update ColumnDisplayName set column_ordinal = 46 where workflow_id = 7 and column_name = 'DutyPercent'
Update ColumnDisplayName set column_ordinal = 47 where workflow_id = 7 and column_name = 'DutyAmount'
Update ColumnDisplayName set column_ordinal = 48 where workflow_id = 7 and column_name = 'AdditionalDutyComment'
Update ColumnDisplayName set column_ordinal = 49 where workflow_id = 7 and column_name = 'AdditionalDutyAmount'
Update ColumnDisplayName set column_ordinal = 50 where workflow_id = 7 and column_name = 'OceanFreightAmount'
Update ColumnDisplayName set column_ordinal = 51 where workflow_id = 7 and column_name = 'OceanFreightComputedAmount'
Update ColumnDisplayName set column_ordinal = 52 where workflow_id = 7 and column_name = 'AgentCommissionPercent'
Update ColumnDisplayName set column_ordinal = 53 where workflow_id = 7 and column_name = 'AgentCommissionAmount'
Update ColumnDisplayName set column_ordinal = 54 where workflow_id = 7 and column_name = 'OtherImportCostsPercent'
Update ColumnDisplayName set column_ordinal = 55 where workflow_id = 7 and column_name = 'OtherImportCostsAmount'
Update ColumnDisplayName set column_ordinal = 56 where workflow_id = 7 and column_name = 'ImportBurden'
Update ColumnDisplayName set column_ordinal = 57 where workflow_id = 7 and column_name = 'WarehouseLandedCost'
Update ColumnDisplayName set column_ordinal = 58 where workflow_id = 7 and column_name = 'OutboundFreight'
Update ColumnDisplayName set column_ordinal = 59 where workflow_id = 7 and column_name = 'NinePercentWhseCharge'
Update ColumnDisplayName set column_ordinal = 60 where workflow_id = 7 and column_name = 'TotalStoreLandedCost'
Update ColumnDisplayName set column_ordinal = 61 where workflow_id = 7 and column_name = 'ShippingPoint'
Update ColumnDisplayName set column_ordinal = 62 where workflow_id = 7 and column_name = 'PlanogramName'
Update ColumnDisplayName set column_ordinal = 63 where workflow_id = 7 and column_name = 'Hazardous'
Update ColumnDisplayName set column_ordinal = 64 where workflow_id = 7 and column_name = 'HazardousFlammable'
Update ColumnDisplayName set column_ordinal = 65 where workflow_id = 7 and column_name = 'HazardousContainerType'
Update ColumnDisplayName set column_ordinal = 66 where workflow_id = 7 and column_name = 'HazardousContainerSize'
Update ColumnDisplayName set column_ordinal = 67 where workflow_id = 7 and column_name = 'HazardousMSDSUOM'
Update ColumnDisplayName set column_ordinal = 68 where workflow_id = 7 and column_name = 'HazardousManufacturerName'
Update ColumnDisplayName set column_ordinal = 69 where workflow_id = 7 and column_name = 'HazardousManufacturerCity'
Update ColumnDisplayName set column_ordinal = 70 where workflow_id = 7 and column_name = 'HazardousManufacturerState'
Update ColumnDisplayName set column_ordinal = 71 where workflow_id = 7 and column_name = 'HazardousManufacturerPhone'
Update ColumnDisplayName set column_ordinal = 72 where workflow_id = 7 and column_name = 'HazardousManufacturerCountry'
Update ColumnDisplayName set column_ordinal = 73 where workflow_id = 7 and column_name = 'PLIFrench'
Update ColumnDisplayName set column_ordinal = 74 where workflow_id = 7 and column_name = 'PLISpanish'
Update ColumnDisplayName set column_ordinal = 75 where workflow_id = 7 and column_name = 'TIFrench'
Update ColumnDisplayName set column_ordinal = 76 where workflow_id = 7 and column_name = 'TISpanish'
Update ColumnDisplayName set column_ordinal = 77 where workflow_id = 7 and column_name = 'CustomsDescription'
Update ColumnDisplayName set column_ordinal = 78 where workflow_id = 7 and column_name = 'EnglishShortDescription'
Update ColumnDisplayName set column_ordinal = 79 where workflow_id = 7 and column_name = 'EnglishLongDescription'
Update ColumnDisplayName set column_ordinal = 80 where workflow_id = 7 and column_name = 'HarmonizedCodeNumber'
Update ColumnDisplayName set column_ordinal = 81 where workflow_id = 7 and column_name = 'CanadaHarmonizedCodeNumber'
Update ColumnDisplayName set column_ordinal = 82 where workflow_id = 7 and column_name = 'ComponentMaterialBreakdown0'
Update ColumnDisplayName set column_ordinal = 83 where workflow_id = 7 and column_name = 'ComponentConstructionMethod0'
Update ColumnDisplayName set column_ordinal = 84 where workflow_id = 7 and column_name = 'TSSA'
Update ColumnDisplayName set column_ordinal = 85 where workflow_id = 7 and column_name = 'CSA'
Update ColumnDisplayName set column_ordinal = 86 where workflow_id = 7 and column_name = 'UL'
Update ColumnDisplayName set column_ordinal = 87 where workflow_id = 7 and column_name = 'LicenceAgreement'
Update ColumnDisplayName set column_ordinal = 88 where workflow_id = 7 and column_name = 'FumigationCertificate'
Update ColumnDisplayName set column_ordinal = 89 where workflow_id = 7 and column_name = 'KILNDriedCertificate'
Update ColumnDisplayName set column_ordinal = 90 where workflow_id = 7 and column_name = 'ChinaComInspecNumAndCCIBStickers'
Update ColumnDisplayName set column_ordinal = 91 where workflow_id = 7 and column_name = 'OriginalVisa'
Update ColumnDisplayName set column_ordinal = 92 where workflow_id = 7 and column_name = 'TextileDeclarationMidCode'
Update ColumnDisplayName set column_ordinal = 93 where workflow_id = 7 and column_name = 'QuotaChargeStatement'
Update ColumnDisplayName set column_ordinal = 94 where workflow_id = 7 and column_name = 'MSDS'
Update ColumnDisplayName set column_ordinal = 95 where workflow_id = 7 and column_name = 'TSCA'
Update ColumnDisplayName set column_ordinal = 96 where workflow_id = 7 and column_name = 'DropBallTestCert'
Update ColumnDisplayName set column_ordinal = 97 where workflow_id = 7 and column_name = 'ManMedicalDeviceListing'
Update ColumnDisplayName set column_ordinal = 98 where workflow_id = 7 and column_name = 'ManFDARegistration'
Update ColumnDisplayName set column_ordinal = 99 where workflow_id = 7 and column_name = 'CopyRightIndemnification'
Update ColumnDisplayName set column_ordinal = 100 where workflow_id = 7 and column_name = 'FishWildLifeCert'
Update ColumnDisplayName set column_ordinal = 101 where workflow_id = 7 and column_name = 'Proposition65LabelReq'
Update ColumnDisplayName set column_ordinal = 102 where workflow_id = 7 and column_name = 'CCCR'
Update ColumnDisplayName set column_ordinal = 103 where workflow_id = 7 and column_name = 'FormaldehydeCompliant'


--*****************************************************************************
--Insert into SPD_RMS_Field_Lookup
--*****************************************************************************
Insert into SPD_RMS_Field_Lookup (Maint_Type, Field_Name, RMS_Field_Name) values ('B','EachCaseHeight','each_case_height')
Insert into SPD_RMS_Field_Lookup (Maint_Type, Field_Name, RMS_Field_Name) values ('B','EachCaseWidth','each_case_width')
Insert into SPD_RMS_Field_Lookup (Maint_Type, Field_Name, RMS_Field_Name) values ('B','EachCaseLength','each_case_length')
Insert into SPD_RMS_Field_Lookup (Maint_Type, Field_Name, RMS_Field_Name) values ('B','EachCaseWeight','each_case_weight')
Insert into SPD_RMS_Field_Lookup (Maint_Type, Field_Name, RMS_Field_Name) values ('B','CustomsDescription','short_customs_desc')
Insert into SPD_RMS_Field_Lookup (Maint_Type, Field_Name, RMS_Field_Name) values ('B','HarmonizedCodeNumber','import_hts_code')
Insert into SPD_RMS_Field_Lookup (Maint_Type, Field_Name, RMS_Field_Name) values ('B','CanadaHarmonizedCodeNumber','canada_hts_code')