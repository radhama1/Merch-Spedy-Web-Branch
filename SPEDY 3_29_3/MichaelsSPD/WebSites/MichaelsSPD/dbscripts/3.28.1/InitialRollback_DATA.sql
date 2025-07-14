--******************
--DO NOT RUN THIS AS PART OF THE DEPLOY THIS IS JUST TO ROLLBACK .31
--*****************

--*****************
--SPD_RMS_Field_Lookup
--*****************
delete SPD_RMS_Field_Lookup where field_name in ('FrenchLongDescription','FrenchItemDescription','FrenchShortDescription')


--*****************
--Security_User_Group
--*****************
--MOVE MANON back to DBC/QA
Update Security_User_Group 
set group_id = 42
where group_id = 60
and User_id in
(
	Select ID from security_user su where su.Email_Address = 'BRADSH48@michaels.com' and su.UserName = 'BRADSH48'
)


--*****************
--SPD_Workflow_Approval_Group
--*****************
delete SPD_Workflow_Approval_Group where Approval_Group_id = 60


--*****************
--Security_Group
--*****************
delete from Security_Group where id = 60


--*****************
--SPD_Field_Locking
--*****************
delete SPD_Field_Locking 
where Metadata_Column_ID in
(
    SELECT  id from SPD_Metadata_Column M where M.Column_Name = 'FrenchShortDescription' and Metadata_Table_ID = 11
	union
    SELECT  id from SPD_Metadata_Column M where M.Column_Name = 'FrenchItemDescription' and Metadata_Table_ID = 11
)


update SPD_Field_Locking 
set Permission = 'E' 
where ID in
(
	Select F.ID from SPD_Field_Locking F 
	inner join SPD_Metadata_Column M on M.id = F.Metadata_Column_ID
	where F.Workflow_Stage_ID = 74 
	and M.Column_Name in
	(
	'FrenchLongDescription','FrenchShortDescription','FrenchItemDescription'
	) and f.Field_Locking_User_Catagories_ID = 8
)

update SPD_Field_Locking 
set Permission = 'E' 
where Metadata_Column_ID in
(
Select C.id from SPD_Metadata_Column C where C.Column_Name in
	(
	'TI_English',
	'TI_French',
	'TI_Spanish',
	'TIEnglish',
	'TIFrench',
	'TISpanish'
	)
) and Workflow_Stage_ID in (2,10,25,32)


Update SPD_Field_Locking
set Permission = 'V'  
where Metadata_Column_ID in
(
	Select C.id from SPD_Metadata_Column C where C.Metadata_Table_ID in (1,2,3)
	and column_name in
	(
	'French_Long_Description',
	'French_Short_Description',
	'Spanish_Long_Description',
	'Spanish_Short_Description',
	'English_Long_Description',
	'English_Short_Description'
	)
)
and Workflow_Stage_ID in
(
Select Id from SPD_Workflow_Stage ws where ws.Workflow_id = 1
)


Update SPD_Field_Locking
set Permission = 'E'  
where Metadata_Column_ID in
(
	Select C.id from SPD_Metadata_Column C where C.Metadata_Table_ID in (1,2,3)
	and column_name in
	(
	'French_Long_Description',
	'French_Short_Description',
	'Spanish_Long_Description',
	'Spanish_Short_Description',
	'English_Long_Description',
	'English_Short_Description'
	)
)
and Workflow_Stage_ID in
(
1,2,10
)

Update SPD_Field_Locking
set Permission = 'E' 
where Metadata_Column_ID in
(
	Select c.id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and c.column_name in
	(

	'EnglishLongDescription',
	'EnglishShortDescription',
	'FrenchLongDescription',
	'FrenchShortDescription',
	'SpanishLongDescription',
	'SpanishShortDescription',
	'FrenchItemDescription'
	)
) and Workflow_Stage_ID in
(
	21,25,32
)


update SPD_Field_Locking 
set Permission = 'V' 
where Metadata_Column_ID in
(
	Select ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 11 and column_name in
	(
	'TIFrench',
	'SpanishLongDescription',
	'SpanishShortDescription',
	'ItemType',
	'VendorStyleNum'
	)
)
and Workflow_Stage_ID in
(
	Select ID from SPD_Workflow_Stage ws where ws.Workflow_id = 5
)


update SPD_Field_Locking 
set Permission = 'V' where id in
(
	Select FL.ID from SPD_Field_Locking FL where FL.Metadata_Column_ID in
	(
		Select C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 1
		and column_name in
		(
		'TI_English',
		'TI_French',
		'TI_Spanish'
		)
	)
	and Workflow_Stage_ID in
	(
		Select ws.id from SPD_Workflow_Stage ws 
		where ws.Workflow_id = 1
	)
)


update SPD_Field_Locking 
set Permission = 'E' where id in
(
	Select FL.ID from SPD_Field_Locking FL where FL.Metadata_Column_ID in
	(
		Select C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 1
		and column_name in
		(
		'TI_English',
		'TI_French',
		'TI_Spanish'
		)
	)
	and Workflow_Stage_ID in
	(
		2,10
	)
)

update SPD_Field_Locking 
set Permission = 'V' where id in
(
	Select FL.ID from SPD_Field_Locking FL where FL.Metadata_Column_ID in
	(
		Select C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 3
		and column_name in
		(
		'TI_English',
		'TI_French',
		'TI_Spanish'
		)
	)
	and Workflow_Stage_ID in
	(
		Select ws.id from SPD_Workflow_Stage ws 
		where ws.Workflow_id = 1
	)
)


update SPD_Field_Locking 
set Permission = 'E' where id in
(
	Select FL.ID from SPD_Field_Locking FL where FL.Metadata_Column_ID in
	(
		Select C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 3
		and column_name in
		(
		'TI_English',
		'TI_French',
		'TI_Spanish'
		)
	)
	and Workflow_Stage_ID in
	(
		2,10
	)
)


update SPD_Field_Locking 
set Permission = 'V' 
where id in
(
	Select FL.id from SPD_Field_Locking FL
	where FL.Metadata_Column_ID in
	(
		Select SMC.ID from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11
		and SMC.Column_Name in
		(
			'TIEnglish',
			'TIFrench',
			'TISpanish',
			'EnglishLongDescription',
			'EnglishShortDescription',
			'FrenchItemDescription',
			'FrenchLongDescription',
			'FrenchShortDescription',
			'SpanishLongDescription',
			'SpanishShortDescription'
		)
	)
	and FL.Workflow_Stage_ID in
	(
		Select ws.id from SPD_Workflow_Stage ws where ws.Workflow_id = 2
	)
)



update SPD_Field_Locking 
set Permission = 'E' 
where id in
(
	Select FL.id from SPD_Field_Locking FL
	where FL.Metadata_Column_ID in
	(
		Select SMC.ID from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11
		and SMC.Column_Name in
		(
			'TIEnglish',
			'TIFrench',
			'TISpanish',
			'EnglishLongDescription',
			'EnglishShortDescription',
			'FrenchItemDescription',
			'FrenchLongDescription',
			'FrenchShortDescription',
			'SpanishLongDescription',
			'SpanishShortDescription'
		)
	)
	and FL.Workflow_Stage_ID in
	(
		21,25,32
	)
)

delete SPD_Field_Locking 
where Metadata_Column_ID in
(
	Select id from SPD_Metadata_Column MC where MC.Metadata_Table_ID = 11 and Column_Name in
	('FrenchItemDescription','FrenchLongDescription')
)


Delete SPD_Field_Locking where Workflow_Stage_ID = 
(
	Select Id from SPD_Workflow_Stage WSN where WSN.Workflow_id = 5 and stage_name = 'French Translation'
)

--*****************
--Validation_Condition_Set_Stages
--*****************

delete Validation_Condition_Set_Stages
where SPD_Workflow_Stage_ID = (Select Id from SPD_Workflow_Stage WSN where WSN.Workflow_id = 5 and stage_name = 'French Translation')


delete Validation_Condition_Set_Stages
where SPD_Workflow_Stage_ID = 74
and Validation_Condition_Set_ID in
(
	Select ID from Validation_Condition_Sets VCS 
	where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'Item Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'ItemDesc'
		)and Rule_Ordinal =2
	) 
	and Validation_Rule_Type_ID = 2 
	and Set_Ordinal = 2 and Validation_Rule_Severity_ID = 1
)

delete Validation_Condition_Set_Stages
where SPD_Workflow_Stage_ID = 74
and Validation_Condition_Set_ID in
(
	Select ID from Validation_Condition_Sets VCS 
	where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'English Short Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'EnglishShortDescription'
		)and Rule_Ordinal =3
	) 
	and Validation_Rule_Type_ID = 2 
	and Set_Ordinal = 3 and Validation_Rule_Severity_ID = 1
)

delete Validation_Condition_Set_Stages
where SPD_Workflow_Stage_ID = 74
and Validation_Condition_Set_ID in
(
	Select ID from Validation_Condition_Sets VCS 
	where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'English Long Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'EnglishLongDescription'
		)and Rule_Ordinal =4
	) 
	and Validation_Rule_Type_ID = 2 
	and Set_Ordinal = 4 and Validation_Rule_Severity_ID = 1
)


--*****************
--Validation_Conditions
--*****************

delete Validation_Conditions
where Validation_Condition_Set_ID = 
(
	Select  ID from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'Item Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'ItemDesc'
		) and Rule_Ordinal =2
	)
	and Validation_Rule_Type_ID = 2 and Set_Ordinal = 2 and Validation_Rule_Severity_ID = 1
)


delete Validation_Conditions
where Validation_Condition_Set_ID = 
(
	Select  ID from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'English Short Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'EnglishShortDescription'
		) and Rule_Ordinal =3
	)
	and Validation_Rule_Type_ID = 2 and Set_Ordinal = 3 and Validation_Rule_Severity_ID = 1
)

delete Validation_Conditions
where Validation_Condition_Set_ID = 
(
	Select  ID from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'English Long Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'EnglishLongDescription'
		) and Rule_Ordinal =4
	)
	and Validation_Rule_Type_ID = 2 and Set_Ordinal = 4 and Validation_Rule_Severity_ID = 1
)

delete Validation_Conditions
where Validation_Condition_Set_ID = 
(
	Select  ID from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'French Short Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'FrenchShortDescription'
		) and Rule_Ordinal =5
	)
	and Validation_Rule_Type_ID = 2 and Set_Ordinal = 5 and Validation_Rule_Severity_ID = 1
)

delete Validation_Conditions
where Validation_Condition_Set_ID = 
(
	Select  ID from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'French Medium Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'FrenchItemDescription'
		) and Rule_Ordinal =6
	)
	and Validation_Rule_Type_ID = 2 and Set_Ordinal = 6 and Validation_Rule_Severity_ID = 1
)

delete Validation_Conditions
where Validation_Condition_Set_ID = 
(
	Select  ID from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
	(
		Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'French Long Description' and Metadata_Column_ID = 
		(
			Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'FrenchLongDescription'
		) and Rule_Ordinal =7
	)
	and Validation_Rule_Type_ID = 2 and Set_Ordinal = 7 and Validation_Rule_Severity_ID = 1
)


--*****************
--Validation_Condition_Sets
--*****************

delete from
Validation_Condition_Sets
where Set_Ordinal = 2
and Validation_Rule_ID =
(
	Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'Item Description' 
	and Metadata_Column_ID = 
	(
		Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'ItemDesc'
	)
	and Rule_Ordinal =2
)


delete from
Validation_Condition_Sets
where Set_Ordinal = 3
and Validation_Rule_ID =
(
	Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'English Short Description'
	and Metadata_Column_ID = 
	(
		Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'EnglishShortDescription'
	)
	and Rule_Ordinal =3
)

delete from
Validation_Condition_Sets
where Set_Ordinal = 4
and Validation_Rule_ID =
(
	Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'English Long Description'
	and Metadata_Column_ID = 
	(
		Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'EnglishLongDescription'
	)
	and Rule_Ordinal =4
)

delete from
Validation_Condition_Sets
where Set_Ordinal = 5
and Validation_Rule_ID =
(
	Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'French Short Description'
	and Metadata_Column_ID = 
	(
		Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'FrenchShortDescription'
	)
	and Rule_Ordinal =5
)

delete from
Validation_Condition_Sets
where Set_Ordinal = 6
and Validation_Rule_ID =
(
	Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'French Medium Description'
	and Metadata_Column_ID = 
	(
		Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'FrenchItemDescription'
	)
	and Rule_Ordinal =6
)

delete from
Validation_Condition_Sets
where Set_Ordinal = 7
and Validation_Rule_ID =
(
	Select  ID from Validation_Rules vr where vr.Validation_Document_ID = 16 and vr.Validation_Rule = 'French Long Description'
	and Metadata_Column_ID = 
	(
		Select  id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and column_name = 'FrenchLongDescription'
	)
	and Rule_Ordinal =7
)


--*****************
--Validation_Rules
--*****************

update validation_rules 
set enabled = 1
where Validation_Document_ID = 4 
and Metadata_Column_ID in
(
	Select c.id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and c.column_name in
	(

	'EnglishLongDescription',
	'EnglishShortDescription'
	)
)


delete from 
Validation_Rules
where Validation_Document_ID = 16 
and Validation_Rule in
(
'Item Description',
'English Short Description',
'English Long Description',
'French Short Description',
'French Medium Description',
'French Long Description'
)

Update Validation_rules set enabled = 1 where Validation_Document_ID = 1 and Validation_rule in
(
'English Long Description','English Short Description'
)


Update Validation_rules set enabled = 1 where Validation_Document_ID = 3 and Validation_rule in
(
'English Long Description','English Short Description'
)

update Validation_rules
set enabled = 1 
where id in
(
	Select VR.ID from Validation_Rules VR where VR.Metadata_Column_ID in
	(
		Select SMC.id from SPD_Metadata_Column SMC where smc.Metadata_Table_ID in
		(
		1,	--SPD_Import_Items
		3,	--SPD_Items
		11	--vwItemMaintItemDetail
		) 
		and SMC.column_name in
		(
		'TI_French',
		'TIFrench'
		) 
	)
)


--*****************
--SPD_Workflow_Stage
--*****************
delete SPD_Workflow_Stage where stage_name = 'French Translation'

update SPD_Workflow_Stage
set Default_NextStage_ID = 
(
	Select Id from SPD_Workflow_Stage WSN where WSN.Workflow_id = 5 and stage_name = 'Waiting For Confirmation'
)
where Workflow_id = 5 and stage_name = 'DBC/QA' and stage_type_id = 6

update SPD_Workflow_Stage
set Default_PrevStage_ID = 
(
	Select Id from SPD_Workflow_Stage WSN where WSN.Workflow_id = 5 and stage_name = 'DBC/QA'
)
where Workflow_id = 5 and stage_name = 'Waiting For Confirmation' and stage_type_id = 3

update SPD_Workflow_Stage
set Default_NextStage_ID = 
(
	Select Id from SPD_Workflow_Stage WSN where WSN.Workflow_id = 5 and stage_name = 'Completed'
)
where Workflow_id = 5 and stage_name = 'Waiting For Confirmation'

--*****************
--SPD_Workflow_Stage_Type
--*****************

delete from 
SPD_Workflow_Stage_Type where Stage_Type_id = 12


--*****************
--SPD_Metadata_Column
--*****************
delete from
SPD_Metadata_Column 
where Metadata_Table_ID = 11 and Column_Name in
(
'FrenchItemDescription'
)


--*****************
--ColumnDisplayName
--*****************
delete from 
ColumnDisplayName
where column_name = 'FrenchItemDescription'


update ColumnDisplayName 
    set Column_Ordinal = Column_Ordinal - 1
    where Workflow_ID =2
    and Column_Ordinal > 92


update ColumnDisplayName 
set Display = 1 
where Workflow_ID = 7
and column_name in
(
'EnglishLongDescription',
'EnglishShortDescription'
)


update ColumnDisplayName
set Display = 1 where id in
(
	Select CDN.ID from ColumnDisplayName CDN
	where CDN.Column_Name in
	(
	'TIEnglish',
	'TIFrench',
	'TISpanish'
	) and CDN.Workflow_ID = 1
)



update ColumnDisplayName
set Display = 1 where id in
(
	Select CDN.id from ColumnDisplayName CDN
	where CDN.Workflow_ID= 2
	and CDN.column_name in
	(
	'TIEnglish',
	'TIFrench',
	'TISpanish',
	'EnglishLongDescription',
	'EnglishShortDescription',
	'FrenchItemDescription',
	'FrenchLongDescription',
	'FrenchShortDescription',
	'SpanishLongDescription',
	'SpanishShortDescription'
	)
)

update ColumnDisplayName
set Display = 1 where id in
(
	Select CDN.id from ColumnDisplayName CDN
	where CDN.Workflow_ID= 7
	and CDN.column_name in
	(
	'TIEnglish',
	'TIFrench',
	'TISpanish',
	'EnglishLongDescription',
	'EnglishShortDescription',
	'FrenchItemDescription',
	'FrenchLongDescription',
	'FrenchShortDescription',
	'SpanishLongDescription',
	'SpanishShortDescription'
	)
)