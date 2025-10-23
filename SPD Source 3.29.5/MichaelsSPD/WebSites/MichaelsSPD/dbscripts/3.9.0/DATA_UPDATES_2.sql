SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--*****************************************************************************
--Add Stocking Strategy to List_Value_Groups
--*****************************************************************************
Insert into List_Value_Groups
(List_Value_Group, RMS_Group,RMS_UDA_ID,RMS_Name)
values
('STOCKSTRAT',0,Null, Null)



--*****************************************************************************
--Insert new Metadata Column records for Item Maint 
--*****************************************************************************

INSERT INTO SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,	'EachCaseHeight',	'Each Case Pack Height',	25,	1	,
1,	1	,25,	'decimal',	NULL,
'formatnumber4',	NULL,	GETDATE(),	GETDATE(),	NULL,	NULL,
1,	1,	1,	NULL,	NULL,	
NULL,	'(18,6)',	0
)

INSERT INTO SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,	'EachCaseWidth',	'Each Case Pack Width',	26,	1	,
1,	1	,26,	'decimal',	NULL,
'formatnumber4',	NULL,	GETDATE(),	GETDATE(),	NULL,	NULL,
1,	1,	1,	NULL,	NULL,	
NULL,	'(18,6)',	0
)

INSERT INTO SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,	'EachCaseLength',	'Each Case Pack Length',	27,	1	,
1,	1	,27,	'decimal',	NULL,
'formatnumber4',	NULL,	GETDATE(),	GETDATE(),	NULL,	NULL,
1,	1,	1,	NULL,	NULL,	
NULL,	'(18,6)',	0
)

INSERT INTO SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,	'EachCaseCube',	'Each Case Pack Cube',	28,	1	,
1,	1	,28,	'decimal',	NULL,
'formatnumber3',	NULL,	GETDATE(),	GETDATE(),	NULL,	NULL,
0,	0,	Null,	NULL,	NULL,	
NULL,	'(18,6)',	1
)

INSERT INTO SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,	'EachCaseWeight',	'Each Case Pack Weight',	29,	1	,
1,	1	,29,	'decimal',	NULL,
'formatnumber4',	NULL,	GETDATE(),	GETDATE(),	NULL,	NULL,
1,	1,	1,	NULL,	NULL,	
NULL,	'(18,6)',	0
)

INSERT INTO SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,	'EachCaseCubeUOM',	'Inner Case Pack Cube UOM',	30,	1	,
1,	1	,30,	'varchar',	10,
'string',	NULL,	GETDATE(),	GETDATE(),	NULL,	NULL,
0,	0,	Null,	NULL,	NULL,	
NULL,	Null,	0
)

INSERT INTO SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,	'EachCaseWeightUOM',	'Inner Case Weight UOM',	31,	1	,
1,	1	,31,	'varchar',	10,
'string',	NULL,	GETDATE(),	GETDATE(),	NULL,	NULL,
0,	0,	Null,	NULL,	NULL,	
NULL,	Null,	0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
11,'StockingStrategyCode','Stocking Strategy',219,2,
1,1,219,'string',5,
'string',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

--*****************************************************************************
--Insert new Metadata Column records for New Item Domestic
--*****************************************************************************

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
3,'Each_Case_Height','Each Case Pack Height',214,1,
1,1,214,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
3,'Each_Case_Width','Each Case Pack Width',215,1,
1,1,215,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
3,'Each_Case_Length','Each Case Pack Length',216,1,
1,1,216,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
3,'Each_Case_Weight','Each Case Pack Weight',217,1,
1,1,217,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
3,'Each_Case_Pack_Cube','Each Case Pack Cube',218,1,
1,1,218,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,1
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
3,'Stocking_Strategy_Code','Stocking Strategy',219,1,
1,1,219,'string',5,
'string',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)


--*****************************************************************************
--Insert field locking for domestic New Item
--*****************************************************************************

--insert all workflows for Field_Locking_User_Catagories_ID = 4
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 4, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'E'
from SPD_Metadata_Column SMC 
cross join
(
Select 1 as workflow_stage_id 
union select 2
union select 3
union select 5
union select 7
union select 8
union select 9
union select 10
union select 12 
) as  WS 
where SMC.Metadata_Table_ID = 3 and SMC.Column_Name in
('Each_Case_Height','Each_Case_Width','Each_Case_Length','Each_Case_Weight','Each_Case_Pack_Cube','Stocking_Strategy_Code')


--insert all workflows exect 2 and 12 for Field_Locking_User_Catagories_ID = 5
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 5, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'E'
from SPD_Metadata_Column SMC 
cross join
(
Select 1 as workflow_stage_id 
union select 3
union select 5
union select 7
union select 8
union select 9
union select 10
) as  WS 
where SMC.Metadata_Table_ID = 3 and SMC.Column_Name in
('Each_Case_Height','Each_Case_Width','Each_Case_Length','Each_Case_Weight','Each_Case_Pack_Cube','Stocking_Strategy_Code')

--insert  workflow  2  for Field_Locking_User_Catagories_ID = 5
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 5, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'N'
from SPD_Metadata_Column SMC 
cross join
(
Select 2 as workflow_stage_id 
) as  WS 
where SMC.Metadata_Table_ID = 3 and SMC.Column_Name in
('Each_Case_Height','Each_Case_Width','Each_Case_Length','Each_Case_Weight','Each_Case_Pack_Cube','Stocking_Strategy_Code')

--insert  workflow  12  for Field_Locking_User_Catagories_ID = 5
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 5, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'V'
from SPD_Metadata_Column SMC 
cross join
(
Select 12 as workflow_stage_id 
) as  WS 
where SMC.Metadata_Table_ID = 3 and SMC.Column_Name in
('Each_Case_Height','Each_Case_Width','Each_Case_Length','Each_Case_Weight','Each_Case_Pack_Cube','Stocking_Strategy_Code')



--*****************************************************************************
--Insert SPD_Metadata_Column for Import New Item
--*****************************************************************************


Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
1,'eachheight','Each Case Pack Height',214,1,
1,1,214,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
1,'eachwidth','Each Case Pack Width',215,1,
1,1,215,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
1,'eachlength','Each Case Pack Length',216,1,
1,1,216,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
1,'eachweight','Each Case Pack Weight',217,1,
1,1,217,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
1,'cubicfeeteach','Each Case Pack Cube',218,1,
1,1,218,'decimal',Null,
'decimal',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,1
)

Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
1,'Stocking_Strategy_Code','Stocking Strategy',219,1,
1,1,219,'string',5,
'string',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)


Insert into SPD_Metadata_Column
(Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,	Max_Length,
Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,	Created_By,	Modified_By,
Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
1,'CanadaHarmonizedCodeNumber','Canada Harmonized Code No.',220,1,
1,1,220,'string',10,
'string',null, GETDATE(),GETDATE(),1,1,
1,1,Null,null,null,
null,null,0
)


--*****************************************************************************
--Insert field locking for Import New Item
--*****************************************************************************

--insert all workflows for Field_Locking_User_Catagories_ID = 4
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 4, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'E'
from SPD_Metadata_Column SMC 
cross join
(
Select 1 as workflow_stage_id 
union select 2
union select 3
union select 5
union select 7
union select 8
union select 9
union select 10
union select 12 
) as  WS 
where SMC.Metadata_Table_ID = 1 and SMC.Column_Name in
('eachheight','eachwidth','eachlength','eachweight','cubicfeeteach','Stocking_Strategy_Code','CanadaHarmonizedCodeNumber')

--insert all workflows exect 2 and 12 for Field_Locking_User_Catagories_ID = 5
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 5, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'E'
from SPD_Metadata_Column SMC 
cross join
(
Select 1 as workflow_stage_id 
union select 3
union select 5
union select 7
union select 8
union select 9
union select 10
) as  WS 
where SMC.Metadata_Table_ID = 1 and SMC.Column_Name in
('eachheight','eachwidth','eachlength','eachweight','cubicfeeteach','Stocking_Strategy_Code','CanadaHarmonizedCodeNumber')

--insert  workflow  2  for Field_Locking_User_Catagories_ID = 5
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 5, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'N'
from SPD_Metadata_Column SMC 
cross join
(
Select 2 as workflow_stage_id 
) as  WS 
where SMC.Metadata_Table_ID = 1 and SMC.Column_Name in
('eachheight','eachwidth','eachlength','eachweight','cubicfeeteach','Stocking_Strategy_Code','CanadaHarmonizedCodeNumber')

--insert  workflow  12  for Field_Locking_User_Catagories_ID = 5
Insert into SPD_Field_Locking
(Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Created_User_ID, 
Date_Last_Modified, Update_User_ID, Workflow_Stage_ID, Permission)
Select SMC.ID, 5, GETDATE(), Null, GETDATE(),Null,ws.workflow_stage_id,'V'
from SPD_Metadata_Column SMC 
cross join
(
Select 12 as workflow_stage_id 
) as  WS 
where SMC.Metadata_Table_ID = 1 and SMC.Column_Name in
('eachheight','eachwidth','eachlength','eachweight','cubicfeeteach','Stocking_Strategy_Code','CanadaHarmonizedCodeNumber')


--*****************************************************************************
--Insert field locking for Item Maint
--*****************************************************************************
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'StockingStrategyCode') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseHeight') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWidth') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseLength') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeight') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCube') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseCubeUOM') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	8	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	9	,	GetDate()	,	GetDate()	,	76	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	8	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	9	,	GetDate()	,	GetDate()	,	75	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	8	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	9	,	GetDate()	,	GetDate()	,	74	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	10	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	11	,	GetDate()	,	GetDate()	,	77	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	10	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	11	,	GetDate()	,	GetDate()	,	78	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	10	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	11	,	GetDate()	,	GetDate()	,	79	,	'N'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	32	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	32	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	30	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	26	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'EachCaseWeightUOM') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	1	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	2	,	GetDate()	,	GetDate()	,	21	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	1	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	2	,	GetDate()	,	GetDate()	,	31	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	1	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	2	,	GetDate()	,	GetDate()	,	29	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	1	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	2	,	GetDate()	,	GetDate()	,	33	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	1	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	2	,	GetDate()	,	GetDate()	,	34	,	'V'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	1	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	2	,	GetDate()	,	GetDate()	,	38	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	1	,	GetDate()	,	GetDate()	,	25	,	'E'	)
Insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created, Date_Last_Modified, Workflow_Stage_ID, Permission) values (	(Select top 1 ID from SPD_Metadata_Column where Metadata_Table_ID = 11 and Column_Name = 'CanadaHarmonizedCodeNumber') 	,	2	,	GetDate()	,	GetDate()	,	25	,	'V'	)


--*****************************************************************************
--update send to RMS for Item_Maint
update SPD_Metadata_Column
set send_to_rms = 1
where Metadata_Table_ID = 11 and Column_Name in
(
'CanadaHarmonizedCodeNumber',
'HarmonizedCodeNumber'
)