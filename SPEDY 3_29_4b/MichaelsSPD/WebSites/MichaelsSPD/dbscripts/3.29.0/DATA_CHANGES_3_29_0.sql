--************************
-- DATA CHANGES FOR 3.29.0
--************************

--************************
--  SPD_Metadata_Column
--************************
--GTIN
update SPD_Metadata_Column 
set 
enabled = 0, 
Validation_Enabled = 0,
Send_To_RMS = null, 
Update_Item_Master = null
where column_name in
(
'InnerGTIN',
'CaseGTIN',
'GenerateMichaelsGTIN',
'Vendor_Inner_GTIN',
'Vendor_Case_GTIN',
'InnerGTIN',
'CaseGTIN'
)

--TSSA
update SPD_Metadata_Column 
set 
enabled = 0,  
Send_To_RMS = Null, 
Update_Item_Master =null
where column_name in
(
'TSSA'
) 


--************************
--  SPD_FIELD_LOCKING
--************************
--TSSA
update SPD_Field_Locking
set Permission = 'N' 
where Metadata_Column_ID in
(
	Select ID from SPD_Metadata_Column where column_name in
	(
	'TSSA'
	)
)


update SPD_Field_Locking
set permission = 'E' 
where Metadata_Column_ID in
(
	Select id from SPD_Metadata_Column
	where column_name = 'ProductIdentifiesAsCosmetic'
) 


update SPD_Field_Locking
set permission = 'V' 
where Metadata_Column_ID in
(
	Select id from SPD_Metadata_Column
	where column_name = 'ProductIdentifiesAsCosmetic'
) 
and Workflow_Stage_ID in (11,12,33,34)


--set them all to E
update SPD_Field_Locking
set Permission = 'E' 
where Metadata_Column_ID in
(
	Select Id from SPD_Metadata_Column 
	where Column_Name in
	(
	'CoinBattery'
	)
)

--Fix the V
update SPD_Field_Locking
set Permission = 'V' 
where Metadata_Column_ID in
(
	Select Id from SPD_Metadata_Column 
	where Column_Name in
	(
	'CoinBattery'
	)
)
and 
(
	(Workflow_Stage_ID = 12 and Field_Locking_User_Catagories_ID =5)
	or
	(Workflow_Stage_ID = 25 and Field_Locking_User_Catagories_ID =2)
	or
	(Workflow_Stage_ID = 32 and Field_Locking_User_Catagories_ID =2)
	or
	(Workflow_Stage_ID in (26,29,30,31,33,34))
)

--Fix the N
update SPD_Field_Locking
set Permission = 'N' 
where Metadata_Column_ID in
(
	Select Id from SPD_Metadata_Column 
	where Column_Name in
	(
	'CoinBattery'
	)
)
and Workflow_Stage_ID = 2 and Field_Locking_User_Catagories_ID =5

--************************
--  ColumnDisplayName
--************************
update ColumnDisplayName set display = 0 where column_name in ('InnerGTIN','CaseGTIN','TSSA')


update ColumnDisplayName set display = 1 where column_name in ('CoinBattery')


INSERT INTO [dbo].[ColumnDisplayName]
           ([Column_Type]
           ,[Column_Name]
           ,[Column_Ordinal]
           ,[Column_Generic_Type]
           ,[Column_Format]
           ,[Column_Format_String]
           ,[Fixed_Column]
           ,[Allow_Sort]
           ,[Allow_Filter]
           ,[Allow_UserDisable]
           ,[Allow_Admin]
           ,[Allow_AjaxEdit]
           ,[Is_Custom]
           ,[Default_UserDisplay]
           ,[Display]
           ,[Display_Name]
           ,[Display_Width]
           ,[Max_Length]
           ,[Security_Privilege_Constant_Suffix]
           ,[Date_Last_Modified]
           ,[Date_Created]
           ,[GUID]
           ,[Workflow_ID])
     VALUES
           ('I'
           ,'ProductIdentifiesAsCosmetic'
           ,107
           ,'string'
           ,'listvalue'
           ,'YESNO'
           ,0
           ,1
           ,1
           ,1
           ,1
           ,1
           ,0
           ,1
           ,1
           ,'Product Identifies As Cosmetic'
           ,0
           ,10
           ,Null
           ,getdate()
           ,getdate()
           ,NEWID()
           ,7)


--************************
--  Validation_Rules
--************************
update Validation_Rules set enabled = 0 where 
Metadata_Column_ID in
(
	Select Id from SPD_Metadata_Column 
	where column_name in
	(
	'InnerGTIN',
	'CaseGTIN',
	'GenerateMichaelsGTIN',
	'Vendor_Inner_GTIN',
	'Vendor_Case_GTIN',
	'InnerGTIN',
	'CaseGTIN',
	'TSSA'
	)
)

update Validation_Rules set enabled = 1 where 
Metadata_Column_ID in
(
	Select Id from SPD_Metadata_Column 
	where column_name in
	(
	'CoinBattery',
	'ProductIdentifiesAsCosmetic'
	)
)


--************************
--  Validation_Condition_Types
--************************
update Validation_Condition_Types set Enabled = 0 where ID = 52


--************************
--  SPD_Item_Mapping  remove old
--************************
update SPD_Item_Mapping set enabled= 0 where Mapping_name in ('DOMITEM','DOMITEMHEADER') and Mapping_Version = '16.01 Version'
update SPD_Item_Mapping set enabled= 0 where Mapping_name in ('IMPORTITEM') and Mapping_Version = '16'



--************************
--  SPD_Item_Mapping  radd new
--************************
--MAPPING FOR IMPORT
if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '16.75')
BEGIN
	exec usp_Copy_Item_Mapping 'IMPORTITEM', '16.50', '16.75'
END


--MAPPING FOR DOMESTIC
if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'DOMITEMHEADER' and Mapping_Version = '17.00 Version')
BEGIN
	exec usp_Copy_Item_Mapping 'DOMITEMHEADER', '16.75 Version', '17.00 Version'
END

if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'DOMITEM' and Mapping_Version = '17.00 Version')
BEGIN
	exec usp_Copy_Item_Mapping 'DOMITEM', '16.75 Version', '17.00 Version'
END

--MAPPING FOR BULK
if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
BEGIN
	exec usp_Copy_Item_Mapping 'BULKMAINT', '1.0', '2.0'
END


--fix columns for new bulk
Update spd_item_mapping_columns set Excel_column = 'BA' where column_name = 'CSA' and excel_column='BB' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BB' where column_name = 'UL' and excel_column='BC' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BC' where column_name = 'LicenceAgreement' and excel_column='BD' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BD' where column_name = 'FumigationCertificate' and excel_column='BE' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BE' where column_name = 'KILNDriedCertificate' and excel_column='BF' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BF' where column_name = 'ChinaComInspecNumAndCCIBStickers' and excel_column='BG' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BG' where column_name = 'OriginalVisa' and excel_column='BH' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BH' where column_name = 'TextileDeclarationMidCode' and excel_column='BI' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BI' where column_name = 'QuotaChargeStatement' and excel_column='BJ' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BJ' where column_name = 'MSDS' and excel_column='BK' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BK' where column_name = 'TSCA' and excel_column='BL' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BL' where column_name = 'DropBallTestCert' and excel_column='BM' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BM' where column_name = 'ManMedicalDeviceListing' and excel_column='BN' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BN' where column_name = 'ManFDARegistration' and excel_column='BO' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BO' where column_name = 'CopyRightIndemnification' and excel_column='BP' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BP' where column_name = 'FishWildLifeCert' and excel_column='BQ' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BQ' where column_name = 'Proposition65LabelReq' and excel_column='BR' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BR' where column_name = 'CCCR' and excel_column='BS' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BS' where column_name = 'FormaldehydeCompliant' and excel_column='BT' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BT' where column_name = 'EachCaseHeight' and excel_column='BU' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BU' where column_name = 'EachCaseWidth' and excel_column='BV' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BV' where column_name = 'EachCaseLength' and excel_column='BW' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BW' where column_name = 'EachCaseWeight' and excel_column='BX' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BX' where column_name = 'CanadaHarmonizedCodeNumber' and excel_column='BY' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')
Update spd_item_mapping_columns set Excel_column = 'BY' where column_name = 'SuppTariffPercent' and excel_column='BZ' and Item_Mapping_ID = (Select id from SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0')

--SET DEFAULTS

update SPD_Item_Mapping set [default] = 0 where mapping_name = 'BULKMAINT' and Mapping_Version = '1.0'
update SPD_Item_Mapping set [default] = 1 where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0'


update SPD_Item_Mapping set [default] = 0 where mapping_name = 'IMPORTITEM' and Mapping_Version <> '16.75'
update SPD_Item_Mapping set [default] = 1 where mapping_name = 'IMPORTITEM' and Mapping_Version = '16.75'


update SPD_Item_Mapping set [default] = 0 where mapping_name = 'DOMITEM' and Mapping_Version <> '17.00 Version'
update SPD_Item_Mapping set [default] = 1 where mapping_name = 'DOMITEM' and Mapping_Version = '17.00 Version'

update SPD_Item_Mapping set [default] = 0 where mapping_name = 'DOMITEMHEADER' and Mapping_Version <> '17.00 Version'
update SPD_Item_Mapping set [default] = 1 where mapping_name = 'DOMITEMHEADER' and Mapping_Version = '17.00 Version'



