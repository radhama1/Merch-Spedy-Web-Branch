--************************
-- DATA ROLLBACK FOR 3.29.0
--************************


--************************
--  SPD_Metadata_Column
--************************
--rollback
--GTIN
update SPD_Metadata_Column 
set 
enabled = 1, 
fieldlocking_enabled = 1,
Validation_Enabled = 1, 
Maint_Workflow_Field = 1,
Maint_Editable = 1, 
Send_To_RMS = Null, 
Update_Item_Master =null
where column_name in
(
'InnerGTIN',
'CaseGTIN',
'GenerateMichaelsGTIN',
'Vendor_Inner_GTIN',
'Vendor_Case_GTIN'
)

--TSSA
update SPD_Metadata_Column 
set 
enabled = 1, 
fieldlocking_enabled = 1,
Validation_Enabled = 1, 
Maint_Workflow_Field = 1,
Maint_Editable = 1, 
Send_To_RMS = Null, 
Update_Item_Master =null
where column_name in
(
'TSSA'
) and Metadata_Table_ID = 1

update SPD_Metadata_Column 
set 
enabled = 1, 
fieldlocking_enabled = 1,
Validation_Enabled = 1, 
Maint_Workflow_Field = 1,
Maint_Editable = 1, 
Send_To_RMS = Null, 
Update_Item_Master =1
where column_name in
(
'TSSA'
) and Metadata_Table_ID = 11

update SPD_Metadata_Column 
set 
enabled = 1, 
fieldlocking_enabled = 1,
Validation_Enabled = 1, 
Maint_Workflow_Field = 0,
Maint_Editable = 0, 
Send_To_RMS = 1, 
Update_Item_Master =1
where column_name in
(
'InnerGTIN',
'CaseGTIN'
)


--************************
--  SPD_FIELD_LOCKING
--************************
--there were no field locking records in PRD, UAT, Or PRE
--GTIN
delete SPD_Field_Locking 
where Metadata_Column_ID in
(
	Select ID from SPD_Metadata_Column where column_name in
	(
	'InnerGTIN',
	'CaseGTIN',
	'GenerateMichaelsGTIN',
	'Vendor_Inner_GTIN',
	'Vendor_Case_GTIN',
	'InnerGTIN',
	'CaseGTIN'
	)
)

--TSSA
DECLARE @TSSA_MCI_1 int
Select @TSSA_MCI_1 = id from SPD_Metadata_Column where column_name = 'TSSA' and Metadata_Table_ID = 1

update SPD_Field_Locking set Permission = 'E' 
where Metadata_Column_ID = @TSSA_MCI_1 and Workflow_Stage_ID in (1,2,3,5,7,8,9,10)

update SPD_Field_Locking set Permission = 'E' 
where Metadata_Column_ID = @TSSA_MCI_1 and Workflow_Stage_ID in (12) and Field_Locking_User_Catagories_ID = 4

update SPD_Field_Locking set Permission = 'V' 
where Metadata_Column_ID = @TSSA_MCI_1 and Workflow_Stage_ID in (12) and Field_Locking_User_Catagories_ID = 5

DECLARE @TSSA_MCI_11 int
Select @TSSA_MCI_11 = id from SPD_Metadata_Column where column_name = 'TSSA' and Metadata_Table_ID = 11

update SPD_Field_Locking set Permission = 'E' 
where Metadata_Column_ID = @TSSA_MCI_1 and Workflow_Stage_ID in (21,25,32,38) and Field_Locking_User_Catagories_ID = 1

update SPD_Field_Locking set Permission = 'V' 
where Metadata_Column_ID = @TSSA_MCI_1 and Workflow_Stage_ID in (26,29,30,31,33,34) and Field_Locking_User_Catagories_ID = 1

update SPD_Field_Locking set Permission = 'E' 
where Metadata_Column_ID = @TSSA_MCI_1 and Workflow_Stage_ID in (21,38) and Field_Locking_User_Catagories_ID = 2

update SPD_Field_Locking set Permission = 'V' 
where Metadata_Column_ID = @TSSA_MCI_1 and Workflow_Stage_ID in (26,29,30,31,32,33,34) and Field_Locking_User_Catagories_ID = 2


update spd_field_locking set Permission = 'N' 
where Metadata_Column_ID in
(
	Select Id from SPD_Metadata_Column 
	where Column_Name in
	(
	'CoinBattery',
	'ProductIdentifiesAsCosmetic'
	)
)

--************************
--  ColumnDisplayName
--************************
update ColumnDisplayName set display = 1 where column_name in ('InnerGTIN','CaseGTIN', 'TSSA')

update ColumnDisplayName set display = 0 where column_name in ('CoinBattery')
--************************
--  Validation_Rules
--************************
update Validation_Rules set enabled = 1 where 
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


update Validation_Rules set enabled = 0 where 
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
update Validation_Condition_Types set Enabled = 1 where ID = 52


--************************
--  SPD_Item_Mapping OLD
--************************
update SPD_Item_Mapping set enabled= 1 where Mapping_name in ('DOMITEM','DOMITEMHEADER') and Mapping_Version = '16.01 Version'
update SPD_Item_Mapping set enabled= 1 where Mapping_name in ('IMPORTITEM') and Mapping_Version = '16'


--************************
--  SPD_Item_Mapping new
--************************
DECLARE @importMappingID int
Select @importMappingID = id from  SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '16.75'

delete SPD_Item_Mapping_Columns where Item_Mapping_ID = @importMappingID
Delete SPD_Item_Mapping where id = @importMappingID

DECLARE @domMappingHeaderID int
Select @domMappingHeaderID = id from  SPD_Item_Mapping where mapping_name = 'DOMITEMHEADER' and Mapping_Version = '17.00 Version'

delete SPD_Item_Mapping_Columns where Item_Mapping_ID = @domMappingHeaderID
Delete SPD_Item_Mapping where id = @domMappingHeaderID

DECLARE @domMappingID int
Select @domMappingID = id from  SPD_Item_Mapping where mapping_name = 'DOMITEM' and Mapping_Version = '17.00 Version'

delete SPD_Item_Mapping_Columns where Item_Mapping_ID = @domMappingID
Delete SPD_Item_Mapping where id = @domMappingID


DECLARE @BULKMappingID int
Select @BULKMappingID = id from  SPD_Item_Mapping where mapping_name = 'BULKMAINT' and Mapping_Version = '2.0'

delete SPD_Item_Mapping_Columns where Item_Mapping_ID = @BULKMappingID
Delete SPD_Item_Mapping where id = @BULKMappingID


update SPD_Item_Mapping set [default] = 1 where mapping_name = 'BULKMAINT' and Mapping_Version = '1.0'
update SPD_Item_Mapping set [default] = 1 where mapping_name = 'IMPORTITEM' and Mapping_Version = '16.50'
update SPD_Item_Mapping set [default] = 1 where mapping_name = 'DOMITEM' and Mapping_Version = '16.75 Version'
update SPD_Item_Mapping set [default] = 1 where mapping_name = 'DOMITEMHEADER' and Mapping_Version = '16.75 Version'