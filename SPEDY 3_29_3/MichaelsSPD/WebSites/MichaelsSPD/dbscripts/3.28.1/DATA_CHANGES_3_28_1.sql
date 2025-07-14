--*********************
--  NEW PHYTO
--  DATA Updates PHTYO Changes
--*********************

--*********************
--SPD_RMS_Field_Lookup
--*********************
insert into SPD_RMS_Field_Lookup (Maint_type, Field_name, RMS_Field_Name) values ('B', 'FumigationCertificate','Fumigation_Certificate')
insert into SPD_RMS_Field_Lookup (Maint_type, Field_name, RMS_Field_Name) values ('B', 'PhytoTemporaryShipment','PhytoTemporaryShipment')

--*********************
--SPD_Metadata_Column
--*********************
--add SPD_Metadata_Column import item for new import item 
insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
1 ,'PhytoTemporaryShipment' ,'Phyto Temporary Shipment' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 1),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 1),
'string' ,1,'string' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,Null ,Null,Null ,Null,
0 --,Null
)

insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
3 ,'PhytoSanitaryCertificate' ,'Phyto Sanitary Certificate' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 3),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 3),
'string' ,1,'string' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,Null ,Null,Null ,Null,
0 --,Null
)


insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
3 ,'PhytoTemporaryShipment' ,'Phyto Temporary Shipment' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 3),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 3),
'string' ,1,'string' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,Null ,Null,Null ,Null,
0 --,Null
)

--add SPD_Metadata_Column import item for Item Maint/Bulk maint
insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
11 ,'PhytoTemporaryShipment' ,'Phyto Temporary Shipment' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 11),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 11),
'varchar' ,1,'string' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,1 ,'SPD_Item_Master_SKU','PhytoTemporaryShipment' ,Null,
0 --,Null
)

--ADD PHYTO FIELDS TO ITEM MAINT MESSAGING
update SPD_Metadata_Column set Send_To_RMS = 1 where ID in
(
	Select MC.ID From SPD_Metadata_Column MC 
	where MC.Metadata_Table_ID = 11 and column_name in
	('FumigationCertificate',
	'PhytoTemporaryShipment'
	)
)



--*********************
--SPD_Field_Locking
--*********************

--add field locking for new import item 
DECLARE @TempShipIDIMP int
Select @TempShipIDIMP = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 1 and C.Column_Name = 'PhytoTemporaryShipment'
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),1,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),2,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),5,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),6,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),7,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),8,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),9,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,4,getdate(),getdate(),12,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),1,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),2,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),5,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),6,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),7,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),8,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),9,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipIDIMP,5,getdate(),getdate(),12,'V')

DECLARE @CertID int
Select @CertID = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 3 and C.Column_Name = 'PhytoSanitaryCertificate'
DECLARE @TempShipID int
Select @TempShipID = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 3 and C.Column_Name = 'PhytoTemporaryShipment'

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),1,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),2,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),5,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),6,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),7,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),8,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),9,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,4,getdate(),getdate(),12,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),1,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),2,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),5,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),6,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),7,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),8,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),9,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@CertID,5,getdate(),getdate(),12,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),1,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),2,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),5,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),6,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),7,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),8,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),9,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,4,getdate(),getdate(),12,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),1,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),2,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),5,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),6,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),7,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),8,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),9,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempShipID,5,getdate(),getdate(),12,'V')

--add field locking for item Maint
DECLARE @TempMaintShipID int
Select @TempMaintShipID = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 11 and C.Column_Name = 'PhytoTemporaryShipment'

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),21,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),25,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),26,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),29,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),30,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),31,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),32,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),33,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),34,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,1,getdate(),getdate(),38,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),21,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),25,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),26,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),29,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),30,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),31,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),32,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),33,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),34,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@TempMaintShipID,2,getdate(),getdate(),38,'V')



--*********************
--SPD_Field_Locking
--*********************
--insert column for domestic item
Insert into ColumnDisplayName 
(
	Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	
	Column_Format_String,	Fixed_Column, Allow_Sort,	Allow_Filter,	Allow_UserDisable,	
	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
	Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	
	Date_Created,	GUID,	Workflow_ID
)
values
(
	'D',	'PhytoSanitaryCertificate',	102,	'string',	'listvalue',	
	'YESNO',	0, 1,	1,	1,	
	1,	1, 0,	1,	1,
	'Phyto Sanitary Certificate',	0, 0,	null,	GETDATE(),	
	GETDATE(),	NEWID(),	1
)

Insert into ColumnDisplayName 
(
	Column_Type,	Column_Name,	Column_Ordinal,	Column_Generic_Type,	Column_Format,	
	Column_Format_String,	Fixed_Column, Allow_Sort,	Allow_Filter,	Allow_UserDisable,	
	Allow_Admin,	Allow_AjaxEdit, Is_Custom,	Default_UserDisplay,	Display,
	Display_Name,	Display_Width, Max_Length,	Security_Privilege_Constant_Suffix,	Date_Last_Modified,	
	Date_Created,	GUID,	Workflow_ID
)
values
(
	'D',	'PhytoTemporaryShipment',	103,	'string',	'listvalue',	
	'YESNO',	0, 1,	1,	1,	
	1,	1, 0,	1,	1,
	'Phyto Temporary Shipment',	0, 0,	null,	GETDATE(),	
	GETDATE(),	NEWID(),	1
)

update ColumnDisplayName set Column_Ordinal = 104 where Workflow_ID = 1 and Column_Name= 'Image_ID'
update ColumnDisplayName set Column_Ordinal = 105 where Workflow_ID = 1 and Column_Name= 'MSDS_ID'

update ColumnDisplayName 
set Display_Name = 'Phytosanitary Certificate'
where Workflow_ID = 7 and column_name = 'FumigationCertificate'


--*********************
--VALIDATION RULES
--*********************

--add Validation_Rules for new import item PhytoTemporaryShipment
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
1,'Phyto Temporary Shipment', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 1 and column_name = 'PhytoTemporaryShipment'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 1),
1,0,0,getdate(),getdate()
)


--add Validation_Condition_Sets for New Import PhytoTemporaryShipment

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Phyto Temporary Shipment'),
2, 1, '', 1
)


--add Validation_Conditions for New import item PhytoTemporaryShipment
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Phyto Temporary Shipment')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 1 and column_name = 'PhytoTemporaryShipment'), 
	'AND'
)


--add Validation_Condition_Set_Stages for New import item PhytoTemporaryShipment  NEW only editable and validated at import manager
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Phyto Temporary Shipment')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =1 and ws.id in (3)


--add Validation_Rules for new import item PhytoSanitaryCertificate
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
3,'Phyto Sanitary Certificate', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 3 and column_name = 'PhytoSanitaryCertificate'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 3),
1,0,0,getdate(),getdate()
)


--add Validation_Condition_Sets for New Import PhytoSanitaryCertificate

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 3 and vr.Validation_Rule = 'Phyto Sanitary Certificate'),
2, 1, '', 1
)


--add Validation_Conditions for New import item PhytoSanitaryCertificate
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 3 and vr.Validation_Rule = 'Phyto Sanitary Certificate')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 3 and column_name = 'PhytoSanitaryCertificate'), 
	'AND'
)


--add Validation_Condition_Set_Stages for New import item PhytoSanitaryCertificate  NEW only editable and validated at import manager and dbc/qa stage
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 3 and vr.Validation_Rule = 'Phyto Sanitary Certificate')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =1 and ws.id in (3,10)

--add Validation_Rules for new import item PhytoTemporaryShipment
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
3,'Phyto Temporary Shipment', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 3 and column_name = 'PhytoTemporaryShipment'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 3),
1,0,0,getdate(),getdate()
)


--add Validation_Condition_Sets for New Import PhytoTemporaryShipment

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 3 and vr.Validation_Rule = 'Phyto Temporary Shipment'),
2, 1, '', 1
)


--add Validation_Conditions for New import item PhytoTemporaryShipment
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 3 and vr.Validation_Rule = 'Phyto Temporary Shipment')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 3 and column_name = 'PhytoTemporaryShipment'), 
	'AND'
)


--add Validation_Condition_Set_Stages for New import item PhytoTemporaryShipment  NEW only editable and validated at import manager and dbc/qa stage
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 3 and vr.Validation_Rule = 'Phyto Temporary Shipment')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =1 and ws.id in (3)

--add Validation_Rules for Item Maint PhytoTemporaryShipment
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
4,'Phyto Temporary Shipment', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'PhytoTemporaryShipment'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 4),
1,0,0,getdate(),getdate()
)


----add Validation_Condition_Sets for Item Maint PhytoTemporaryShipment

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Phyto Temporary Shipment'),
2, 1, '', 1
)


--add Validation_Conditions for Item Maint PhytoTemporaryShipment
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Phyto Temporary Shipment')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'PhytoTemporaryShipment'), 
	'AND'
)

--add Validation_Condition_Set_Stages for Item Maint PhytoTemporaryShipment
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Phyto Temporary Shipment')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =2 and ws.stage_name  in ('Import Manager','DBC / QA')



---------------------------
--Workflow changes new item batches
--------------------------

delete SPD_Workflow_exception_Condition where Exception_ID in
(
	Select Exception_ID from SPD_workflow_stage_Exception where Workflow_Stage_id = 2
)

delete SPD_Workflow_Exception_Dept where Exception_ID in
(
	Select Exception_ID from SPD_workflow_stage_Exception where Workflow_Stage_id = 2
)

delete SPD_workflow_stage_Exception where Workflow_Stage_id = 2 


update SPD_Workflow_Stage set Default_NextStage_ID = 3 where ID = 2

--************************
--SPD_Item_Mapping/ SPD_Item_Mapping_Columns 
--************************
--update ITEM MAPPING for Phyto
Insert into SPD_Item_Mapping_Columns
(Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row)
values
(
(Select ID from spd_item_mapping where Mapping_Name = 'IMPORTITEM' and Mapping_Version = 16.25),
'PhytoTemporaryShipment', 'V', 107
)

--MAPPING FOR DOMESTIC
--PHYTO Domestic mapping
if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'DOMITEMHEADER' and Mapping_Version = '16.75 Version')
BEGIN
	exec usp_Copy_Item_Mapping 'DOMITEMHEADER', '16.5 Version', '16.75 Version'
END

if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'DOMITEM' and Mapping_Version = '16.75 Version')
BEGIN
	exec usp_Copy_Item_Mapping 'DOMITEM', '16.5 Version', '16.75 Version'
END


DECLARE @SIMID int
Select @SIMID = ID from SPD_Item_Mapping where mapping_name = 'DOMITEM' and Mapping_Version = '16.75 Version'

If not exists (Select 1 from SPD_Item_Mapping_Columns where item_mapping_id = @SIMID and column_name = 'PhytoSanitaryCertificate')
BEGIN
	Insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) values (@SIMID,'PhytoSanitaryCertificate','CL',23)
END

If not exists (Select 1 from SPD_Item_Mapping_Columns where item_mapping_id = @SIMID and column_name = 'PhytoTemporaryShipment')
BEGIN
	Insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) values (@SIMID,'PhytoTemporaryShipment','CM',23)
END

--***************
--HIDE TI AND CFD FIELDS IN OTHER BATCH TYPES
--***************

--Translation Indicators should not be editable in any batch type
update SPD_Field_Locking 
set Permission = 'V' 
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
) and Permission = 'E' 



--hide CFD from new Items
Update SPD_Field_Locking
set Permission = 'N'  
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


--hide CFD from  bulk maint items
Update SPD_Field_Locking
set Permission = 'N' 
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
	Select Id from SPD_Workflow_Stage ws where ws.Workflow_id in (7)
)


--HIDE CFD from Bulk maint
update ColumnDisplayName 
set Display = 0 
where Workflow_ID = 7
and column_name in
(
'EnglishLongDescription',
'EnglishShortDescription'
)


--view only CFD fields in Regular Item maint
Update SPD_Field_Locking
set Permission = 'V' 
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
	Select Id from SPD_Workflow_Stage ws where ws.Workflow_id in (2)
)


--turn off validation in regular item maint for CFD english
update validation_rules 
set enabled = 0
where Validation_Document_ID = 4 
and Metadata_Column_ID in
(
	Select c.id from SPD_Metadata_Column c where c.Metadata_Table_ID = 11 and c.column_name in
	(

	'EnglishLongDescription',
	'EnglishShortDescription'
	)
)


update Validation_rules
set enabled = 0 
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


--Hide TI frenchand spanish fields from Trilingual maint batches
update SPD_Field_Locking 
set Permission = 'N' 
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
set Permission = 'N' where id in
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

--domestic new
update ColumnDisplayName
set Display = 0 where id in
(
	Select CDN.ID from ColumnDisplayName CDN
	where CDN.Column_Name in
	(
	'TIEnglish',
	'TIFrench',
	'TISpanish'
	) and CDN.Workflow_ID = 1
)

update SPD_Field_Locking 
set Permission = 'N' where id in
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

--Item Maint List
update ColumnDisplayName
set Display = 0 where id in
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

--BULK Maint list
update ColumnDisplayName
set Display = 0 where id in
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

--maint detail
update SPD_Field_Locking 
set Permission = 'N' 
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


--VALIDATION FIXES FROM TESTING
delete Validation_Conditions

where Validation_Condition_Type_ID = 8
and Condition_Ordinal = 2
and Validation_Condition_Set_ID = (
	Select id from Validation_Condition_Sets VCS
	where VCS.Validation_Rule_ID = 
	(
		Select ID from Validation_Rules VR
		where VR.Validation_Document_ID = 4
		and VR.Metadata_Column_ID = 
		(
			Select ID from SPD_Metadata_Column SMC where SMC.Column_Name = 'FumigationCertificate'
			and Metadata_table_ID = 11
		)
	)
)


update SPD_Field_Locking
set Permission = 'E'
where
Workflow_Stage_ID in (1,2,4,5,7,8,9,10)
and Metadata_Column_ID =
(
	Select Id from SPD_Metadata_Column C where C.Metadata_Table_ID = 3
	and Column_Name = 'PhytoSanitaryCertificate'
)


update SPD_Field_Locking
set Permission = 'N'
where Field_Locking_User_Catagories_ID = 5
and Workflow_Stage_ID = 2
and Metadata_Column_ID =
(
	Select Id from SPD_Metadata_Column C where C.Metadata_Table_ID = 3
	and Column_Name = 'PhytoSanitaryCertificate'
)


Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 3 and vr.Validation_Rule = 'Phyto Sanitary Certificate')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =1 and ws.id in (1,2,5,6,7,8,11,12)


update SPD_Metadata_Column set Display_Name = 'Phytosanitary Certificate'
where Metadata_Table_ID in (1,11) and Column_Name = 'FumigationCertificate'


update ColumnDisplayName 
set Display_Name = 'Phytosanitary Certificate'
where Workflow_ID = 1 and column_name = 'PhytoSanitaryCertificate'

update SPD_Metadata_Column set Display_Name = 'Phytosanitary Certificate'
where Metadata_Table_ID in (3) and Column_Name = 'PhytoSanitaryCertificate'


--********************
--NEW FIELDS 
--********************

--upate new version of import template

if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '16.50')
BEGIN
	exec usp_Copy_Item_Mapping 'IMPORTITEM', '16.25', '16.50'
END

DECLARE @IMPMAPID1 int
Select @IMPMAPID1 = ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and mapping_version = '16.50'
Insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) values (@IMPMAPID1,'MinimumOrderQuantity','V',104)
Insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) values (@IMPMAPID1,'VendorMinOrderAmount','V',105)
Insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) values (@IMPMAPID1,'ProductIdentifiesAsCosmetic','G',105)

delete SPD_Item_Mapping_Columns
where column_name = 'VendorMinOrderAmount' and Excel_Column = 'H' and Excel_Row = 20 and
Item_Mapping_ID =
(
	Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and mapping_version = '16.50'
)


update SPD_Metadata_Column set Display_Name = 'Minimum Order Amount' where Metadata_Table_ID = 1 and Column_name = 'VendorMinOrderAmount'


--NEW IMPORT!

--add SPD_Metadata_Column import item for new import item 
insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
1 ,'MinimumOrderQuantity' ,'Minimum Order Quantity' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 1),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 1),
'integer' ,null,'integer' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,Null ,Null,Null ,Null,
0 --,Null
)

insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
1 ,'ProductIdentifiesAsCosmetic' ,'Product Identifies as a Cosmetic' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 1),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 1),
'string' ,1,'string' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,Null ,Null,Null ,Null,
0 --,Null
)


DECLARE @MOQFLNew int
Select @MOQFLNew = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 1 and C.Column_Name = 'MinimumOrderQuantity'

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),1,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),2,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),5,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),6,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),7,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),8,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),9,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,4,getdate(),getdate(),12,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),1,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),2,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),5,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),6,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),7,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),8,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),9,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLNew,5,getdate(),getdate(),12,'V')

DECLARE @PICFLNew int
Select @PICFLNew = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 1 and C.Column_Name = 'ProductIdentifiesAsCosmetic'

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),1,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),2,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),5,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),6,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),7,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),8,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),9,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,4,getdate(),getdate(),12,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),1,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),2,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),3,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),5,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),6,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),7,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),8,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),9,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),10,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),11,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLNew,5,getdate(),getdate(),12,'V')



--add Validation_Rules for new import item MinimumOrderQuantity
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
1,'Minimum Order Quantity', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 1 and column_name = 'MinimumOrderQuantity'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 1),
1,0,0,getdate(),getdate()
)


--add Validation_Condition_Sets for New Import MinimumOrderQuantity

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Minimum Order Quantity'),
2, 1, '', 1
)


--add Validation_Conditions for New import item MinimumOrderQuantity
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Minimum Order Quantity')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 1 and column_name = 'MinimumOrderQuantity'), 
	'AND'
)


--add Validation_Condition_Set_Stages for New import item MinimumOrderQuantity  
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Minimum Order Quantity')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =1 and ws.id in (1,2,3,5,6,7,8,9,10)


--add Validation_Rules for new import item ProductIdentifiesAsCosmetic
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
1,'Product Identifies As Cosmetic', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 1 and column_name = 'ProductIdentifiesAsCosmetic'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 1),
1,0,0,getdate(),getdate()
)


--add Validation_Condition_Sets for New Import ProductIdentifiesAsCosmetic

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Product Identifies As Cosmetic'),
2, 1, '', 1
)


--add Validation_Conditions for New import item ProductIdentifiesAsCosmetic
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Product Identifies As Cosmetic')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 1 and column_name = 'ProductIdentifiesAsCosmetic'), 
	'AND'
)


--add Validation_Condition_Set_Stages for New import item ProductIdentifiesAsCosmetic  
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Product Identifies As Cosmetic')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =1 and ws.id in (1,2,3,5,6,7,8,9,10)



--*******************
--ITEM MAINT!
--*******************

--add SPD_Metadata_Column import item for item maint
insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
11 ,'MinimumOrderQuantity' ,'Minimum Order Quantity' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 11),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 11),
'integer' ,null,'integer' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,Null ,Null,Null ,Null,
0 --,Null
)

insert into [SPD_Metadata_Column] 
(
[Metadata_Table_ID] ,[Column_Name] ,[Display_Name] ,
[Sort_Order] ,
[Enabled], [FieldLocking_Enabled] ,[Validation_Enabled] ,
[Column_Ordinal] ,
[Column_Generic_Type] ,[Max_Length],[Column_Format] ,[Column_Format_String] ,[Date_Created] ,
[Date_Last_Modified],[Created_By] ,[Modified_By] ,[Maint_Workflow_Field] ,[Maint_Editable] ,
[Send_To_RMS] ,[Update_Item_Master] ,[View_To_TableName] ,[View_To_ColumnName] ,[SQLPrecision] ,
[Treat_Empty_As_Zero] --,[Translation_Trigger]
)
values
(
11 ,'ProductIdentifiesAsCosmetic' ,'Product Identifies as a Cosmetic' ,
(select max(sort_order)+1 as newsort from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 11),
1,1 ,1,
(select max(column_ordinal)+1 as neword from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = 11),
'string' ,1,'string' ,null ,getdate() ,
getdate(),Null ,null ,1 ,1,
Null ,Null ,Null,Null ,Null,
0 --,Null
)


DECLARE @MOQFLMaint int
Select @MOQFLMaint = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 11 and C.Column_Name = 'MinimumOrderQuantity'

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),21,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),25,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),38,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),26,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),30,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),29,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),31,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),32,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),33,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,1,getdate(),getdate(),34,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),21,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),25,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),38,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),26,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),30,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),29,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),31,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),32,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),33,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@MOQFLMaint,2,getdate(),getdate(),34,'V')

DECLARE @PICFLMaint int
Select @PICFLMaint = C.ID from SPD_Metadata_Column C where C.Metadata_Table_ID = 11 and C.Column_Name = 'ProductIdentifiesAsCosmetic'

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),21,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),25,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),38,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),26,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),30,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),29,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),31,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),32,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),33,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,1,getdate(),getdate(),34,'V')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),21,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),25,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),38,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),26,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),30,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),29,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),31,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),32,'E')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),33,'V')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@PICFLMaint,2,getdate(),getdate(),34,'V')


--add Validation_Rules for  import item Maint MinimumOrderQuantity
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
4,'Minimum Order Quantity', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'MinimumOrderQuantity'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 4),
1,0,0,getdate(),getdate()
)


--add Validation_Condition_Sets for import item Maint MinimumOrderQuantity

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Minimum Order Quantity'),
2, 1, '', 1
)


--add Validation_Conditions for import item Maint MinimumOrderQuantity
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Minimum Order Quantity')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'MinimumOrderQuantity'), 
	'AND'
)

Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Value1, Operator, Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Minimum Order Quantity')
	), 
	8, 2, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'VendorType'), 
	2,'=','AND'
)

--add Validation_Condition_Set_Stages for import item Maint MinimumOrderQuantity  
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Minimum Order Quantity')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =2 and ws.id in (21,25,38,26,30,29,31,32)


--add Validation_Rules for import item Maint ProductIdentifiesAsCosmetic
Insert into Validation_Rules
(
Validation_Document_ID, Validation_Rule, 
Metadata_Column_ID, 
Validation_Rule_Type_ID, 
Rule_Ordinal, 
Enabled, Last_Update_User_ID, Create_User_ID, Date_Last_Modified, Date_Created
)
values
(
4,'Product Identifies As Cosmetic', 
(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'ProductIdentifiesAsCosmetic'),
1,
(Select max(rule_ordinal) + 1 from Validation_Rules where Validation_Document_ID = 4),
1,0,0,getdate(),getdate()
)


--add Validation_Condition_Sets for import item Maint ProductIdentifiesAsCosmetic

Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Product Identifies As Cosmetic'),
2, 1, '', 1
)


--add Validation_Conditions for import item Maint ProductIdentifiesAsCosmetic
Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Product Identifies As Cosmetic')
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'ProductIdentifiesAsCosmetic'), 
	'AND'
)

Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Value1, Operator, Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Product Identifies As Cosmetic')
	), 
	8, 2, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'VendorType'), 
	2,'=','AND'
)

--add Validation_Condition_Set_Stages for import item Maint ProductIdentifiesAsCosmetic  
Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Product Identifies As Cosmetic')
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =2 and ws.id in (21,25,38,26,30,29,31,32)


--************
--Update old field with new rules  RUN IN .33
--************

--NEW ITEM
update SPD_Field_Locking set Permission = 'V' where Workflow_Stage_ID in (11,12) and Metadata_Column_ID =
(
	Select ID from SPD_Metadata_Column where Metadata_Table_ID = 1 and Column_Name = 'vendorMinOrderAmount'  -- 41
)

update SPD_Field_Locking set Permission = 'E' where Workflow_Stage_ID not in (11,12) and Metadata_Column_ID =
(
	Select ID from SPD_Metadata_Column where Metadata_Table_ID = 1 and Column_Name = 'vendorMinOrderAmount'  -- 41
)



update SPD_Metadata_Column set Display_Name = 'Minimum Order Amount' where Metadata_Table_ID = 11 and Column_Name = 'VendorMinOrderAmount'

update SPD_Metadata_Column set Display_Name = 'Minimum Order Amount' where Metadata_Table_ID = 1 and Column_name = 'VendorMinOrderAmount'

--NEW Validation Rules--
Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select ID from Validation_Rules where Validation_Document_ID = 1 and Validation_Rule = 'Vendor Order Minimum AMT'),
2, 2, '', 1
)

Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Vendor Order Minimum AMT')
		and vcs.Set_Ordinal = 2
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 1 and column_name = 'VendorMinOrderAmount'), 
	'AND'
)

Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Vendor Order Minimum AMT')
		and vcs.Set_Ordinal = 2
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =1 and ws.id in (1,2,3,5,6,7,8,9,10)



Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
values
(
	(
		Select id from Validation_Condition_Sets where Validation_Rule_ID = 
			(
				Select id from Validation_Rules VR where VR.Validation_Document_ID = 1 and vr.Validation_Rule = 'Vendor Order Minimum AMT'
			) and Set_Ordinal = 1
	),
9
)



Insert into Validation_Condition_Sets
(
Validation_Rule_ID, 
Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
)
values
(
(Select ID from Validation_Rules where Validation_Document_ID = 4 and Validation_Rule = 'Vendor Order Minimum AMT'),
2, 2, '', 1
)

Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Vendor Order Minimum AMT')
		and vcs.Set_Ordinal = 2
	), 
	21, 1, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'VendorMinOrderAmount'), 
	'AND'
)

Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
Select 
(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Vendor Order Minimum AMT')
		and vcs.Set_Ordinal = 2
	), ws.id 
from
SPD_Workflow_Stage ws 
where ws.Workflow_id =2 and ws.id in (21,25,38,26,30,29,31,32)


Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
values
(
	(
		Select id from Validation_Condition_Sets where Validation_Rule_ID = 
			(
				Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Vendor Order Minimum AMT'
			) and Set_Ordinal = 1
	),
31
)

Insert into Validation_Condition_Set_Stages
(Validation_Condition_Set_ID, SPD_Workflow_Stage_ID)
values
(
	(
		Select id from Validation_Condition_Sets where Validation_Rule_ID = 
			(
				Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Vendor Order Minimum AMT'
			) and Set_Ordinal = 1
	),
38
)


Insert into Validation_Conditions 
(
	Validation_Condition_Set_ID, 
	Validation_Condition_Type_ID, Condition_Ordinal, 
	Field1, 
	Value1, Operator, Conjunction
)
values
(
	(Select Id from Validation_Condition_Sets VCS where VCS.Validation_Rule_ID = 
		(Select id from Validation_Rules VR where VR.Validation_Document_ID = 4 and vr.Validation_Rule = 'Vendor Order Minimum AMT')
		and Set_Ordinal = 2
	), 
	8, 2, 
	(Select id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and column_name = 'VendorType'), 
	2,'=','AND'
)


update Validation_Rules set Enabled = 1 where Validation_Document_ID = 4 and Validation_Rule = 'Vendor Order Minimum AMT'

--shut off TSSA validation

update validation_rules set Enabled = 0 where Validation_Rule = 'TSSA' 

--update stage name
update SPD_Workflow_Stage set stage_name = 'Trade Compliance' where stage_name = 'Import Mgr.'
update SPD_Workflow_Stage set stage_name = 'Trade Compliance' where stage_name = 'Import Manager'

--new report
Insert into SPD_Report
(Report_name, Report_Summary, Custom_Stylesheet, 
Report_SQL,
Start_Date, End_Date, Enabled, Update_User_ID, Date_Last_Modified, 
Date_Created, Created_User_ID, DateRange_Label, Is_Viewable, Is_Emailable,
Report_Constant)
values
('Modified Phyto Fields', 'This report shows when the phytosanitary fields have been added or modified.', null, 
'exec SPD_Report_Modified_Phyto_Fields @startDate, @endDate, @dept, @vendor, @vendorFilter, @itemStatus, @sku, @itemGroup, @stockCategory, @itemType',
null,null,1,0,getdate(),
getdate(),0,null,1,1,
null)


update SPD_Report set Report_SQL = 
'declare @dateNow datetime          declare @dateNowStr varchar(20)          declare @month varchar(2), @day varchar(2), @year varchar(4)                    set @dateNow = getdate()          set @month = convert(varchar(2), Month(@dateNow))          if (len(@month) < 2)             set @month = ''0'' + @month           set @day = convert(varchar(2), Day(@dateNow))        if (len(@day) < 2)             set @day = ''0'' + @day             set @year = convert(varchar(4), Year(@dateNow))            if (len(@year) < 4)            set @year = ''00'' + @year           set @dateNowStr =  @year + @month + @day                  Select  vw.ID, vw.VendorNumber, vw.VendorName,         CASE b.Batch_Type_ID WHEN 1 THEN ''Domestic'' WHEN 2 THEN ''Import'' ELSE ''Uknown'' END AS Supplier_Type,       CASE vw.VendorOrAgent WHEN ''A'' THEN ''MB'' ELSE vw.VendorOrAgent END AS VendorOrMerchBurden,   vw.AgentType as MerchBurdenType, vw.SKU, vw.ItemDesc, vw.SubClassNum, vw.VendorStylenum,    vw.HarmonizedCodeNumber as ''Harmonized_CodeNumber'', vw.CanadaHarmonizedCodeNumber as ''Canada_Harmonized_CodeNumber'', vw.DetailInvoiceCustomsDesc0 as ''Detail_Invoice_Customs_Desc'', vw.ComponentMaterialBreakdown0 as ''Component_Material_Breakdown'',       vw.CustomsDescription,       simlEs.Package_Language_Indicator as ''Package_Language_Indicator_English'', simlE.Translation_Indicator as ''Translation_Indicator_English'', simlE.Description_Long as ''English_Long_Description'', simlE.Description_Short as ''English_Short_Description'',      simlFs.Package_Language_Indicator as ''Package_Language_Indicator_French'', simlF.Translation_Indicator as ''Translation_Indicator_French'', simlF.Description_Long as ''French_Long_Description'', simlF.Description_Short as ''French_Short_Description'',      simlSs.Package_Language_Indicator as ''Package_Language_Indicator_Spanish'', simlS.Translation_Indicator as ''Translation_Indicator_Spanish'', simlS.Description_Long as ''Spanish_Long_Description'', simlS.Description_Short as ''Spanish_Short_Description'',      vw.DepartmentNum, vw.StockCategory, vw.ItemTypeAttribute, vw.PackItemIndicator, vw.SKUGroup, vw.ItemStatus, b.Date_Created, b.Date_Modified      FROM vwItemMaintItemDetail as vw      INNER JOIN SPD_Batch as b on b.ID = vw.BatchID      LEFT JOIN SPD_Workflow_Stage ws on b.Workflow_Stage_ID = ws.id and ws.Workflow_id = 2      LEFT JOIN SPD_Item_Master_Languages as simlE on simlE.Michaels_SKU = vw.SKU and simlE.Language_Type_ID = 1      LEFT JOIN SPD_Item_Master_Languages as simlF on simlF.Michaels_SKU = vw.SKU and simlF.Language_Type_ID = 2      LEFT JOIN SPD_Item_Master_Languages as simlS on simlS.Michaels_SKU = vw.SKU and simlS.Language_Type_ID = 3      LEFT JOIN SPD_Item_Master_Languages_Supplier as simlEs on simlEs.Michaels_SKU = vw.SKU and simlEs.Vendor_Number = vw.VendorNumber and simlEs.Language_Type_ID = 1      LEFT JOIN SPD_Item_Master_Languages_Supplier as simlFs on simlFs.Michaels_SKU = vw.SKU and simlFs.Vendor_Number = vw.VendorNumber and simlFs.Language_Type_ID = 2      LEFT JOIN SPD_Item_Master_Languages_Supplier as simlSs on simlSs.Michaels_SKU = vw.SKU and simlSs.Vendor_Number = vw.VendorNumber and simlSs.Language_Type_ID = 3   WHERE vw.SKU in (SELECT imi.Michaels_SKU                        FROM SPD_Item_Master_Changes as c                       INNER JOIN SPD_Item_Maint_Items as imi on imi.ID = c.Item_Maint_Items_ID                       WHERE c.Field_Name in (''ItemDesc'',''CustomsDescription'',''EnglishShortDescription'',''EnglishLongDescription''))   AND (@startDate is null or (@startDate is not null and b.date_modified >= @startDate))   and (@endDate is null or (@endDate is not null and b.date_modified <= @endDate))   and (isnull(@dept, 0) = 0 or (isnull(@dept, 0) > 0 and b.Fineline_Dept_ID = @dept))   and ((isnull(@vendor, 0) <= 0) or (isnull(@vendor,0) > 0 and vw.VendorNumber = @vendor))   and ((isnull(@vendorFilter, 0) <= 0) or (isnull(@vendorFilter,0) > 0 and vw.VendorNumber = @vendorFilter))   and (isnull(@itemStatus, '''') = '''' or (isnull(@itemStatus, '''') != '''' and vw.ItemStatus = @itemStatus))   and (isnull(@sku, '''') = '''' or (isnull(@sku, '''') != '''' and vw.SKU= @sku))   and (isnull(@itemGroup, '''') = '''' or (isnull(@itemGroup, '''') != '''' and vw.SKUGroup = @itemGroup))   and (isnull(@stockCategory, '''') = '''' or (isnull(@stockCategory, '''') != '''' and vw.StockCategory = @stockCategory))   and (isnull(@itemType, '''') = '''' or (isnull(@itemType, '''') != '''' and b.Batch_Type_ID = @itemType))'
where report_name = 'Modified Item Description '



update validation_rules
set Enabled = 0
where Validation_Rule in ('English Long Description','English Short Description')
and Validation_Document_ID in (1,3,4)

--***********************************
--udpdates from testing 5/9/2024 v1
--**********************************
update SPD_RMS_Field_Lookup set RMS_Field_Name = 'phytosanitarycertificate' where Maint_Type = 'B' and Field_Name = 'FumigationCertificate'  --Fumigation_Certificate


DECLARE  @FShortID int
Select @FShortID = id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and smc.Column_Name = 'FrenchShortDescription'
--Select @FShortID

Delete SPD_Field_Locking where Metadata_Column_ID = @FShortID and Workflow_Stage_ID in
(
	Select Id from SPD_Workflow_Stage ws where ws.Workflow_id in (2)
)

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),21,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),25,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),26,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),29,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),30,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),31,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),32,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),33,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),34,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,1,getdate(),getdate(),38,'N')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),21,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),25,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),26,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),29,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),30,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),31,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),32,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),33,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),34,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FShortID,2,getdate(),getdate(),38,'N')


DECLARE  @FLongID int
Select @FLongID = id from SPD_Metadata_Column SMC where SMC.Metadata_Table_ID = 11 and smc.Column_Name = 'FrenchLongDescription'
--Select @FLongID

Delete SPD_Field_Locking where Metadata_Column_ID = @FLongID and Workflow_Stage_ID in
(
	Select Id from SPD_Workflow_Stage ws where ws.Workflow_id in (2)
)

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),21,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),25,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),26,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),29,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),30,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),31,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),32,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),33,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),34,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,1,getdate(),getdate(),38,'N')

insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),21,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),25,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),26,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),29,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),30,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),31,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),32,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),33,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),34,'N')
insert into SPD_Field_Locking (Metadata_Column_ID, Field_Locking_User_Catagories_ID, Date_Created,Date_Last_Modified, Workflow_Stage_ID, Permission) values (@FLongID,2,getdate(),getdate(),38,'N')

--*****************************
--POST 5/21/2024 MEETING
--*****************************
--turn off validation for fields going away for this version
update Validation_Rules
set enabled = 0
where Metadata_Column_ID in
(
	Select C.ID 
	from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (1,3,11)
	and C.Column_Name in
	(
		'CoinBattery',
		'MinimumOrderQuantity',
		'VendorMinOrderAmount',
		'ProductIdentifiesAsCosmetic'
	)
)


--hide fields that are going away for this version
update SPD_Field_Locking
set Permission = 'N' 
where Metadata_Column_ID in
(
	Select C.ID 
	from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (1,3,11)
	and C.Column_Name in
	(
		'CoinBattery',
		'MinimumOrderQuantity',
		'VendorMinOrderAmount',
		'ProductIdentifiesAsCosmetic'
	)
)

--set to E
update SPD_Field_Locking 
set Permission = 'E'
where Metadata_Column_ID in
(
	Select ID from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (1,3)
	and C.Column_Name in
	(
	'English_Long_Description',
	'English_Short_Description'
	)
) and Workflow_Stage_ID in (1,2,10)


--set to V
update SPD_Field_Locking 
set Permission = 'V'
where Metadata_Column_ID in
(
	Select ID from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (1,3)
	and C.Column_Name in
	(
	'English_Long_Description',
	'English_Short_Description'
	)
) and Workflow_Stage_ID not in (1,2,10)

--set to E
update SPD_Field_Locking 
set Permission = 'E'
where Metadata_Column_ID in
(
	Select ID from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (11)
	and C.Column_Name in
	(
	'EnglishLongDescription',
	'EnglishShortDescription'
	)
) and Workflow_Stage_ID in (21,25)


--set to V
update SPD_Field_Locking 
set Permission = 'V'
where Metadata_Column_ID in
(
	Select ID from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (11)
	and C.Column_Name in
	(
	'EnglishLongDescription',
	'EnglishShortDescription'
	)
) and Workflow_Stage_ID  in (26,29,30,31,38)


update SPD_Field_Locking 
set Permission = 'E'
where Metadata_Column_ID in
(
	Select ID from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (11)
	and C.Column_Name in
	(
	'EnglishLongDescription',
	'EnglishShortDescription'
	)
) and Workflow_Stage_ID in (32) and Field_Locking_User_Catagories_ID = 1

update SPD_Field_Locking 
set Permission = 'V'
where Metadata_Column_ID in
(
	Select ID from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (11)
	and C.Column_Name in
	(
	'EnglishLongDescription',
	'EnglishShortDescription'
	)
) and Workflow_Stage_ID in (32) and Field_Locking_User_Catagories_ID = 2

--turn back on validation
update Validation_Rules
set enabled = 1
where Validation_Document_ID in (1,3,4)
and Metadata_Column_ID in
(
	Select C.ID
	from 
	SPD_Metadata_Column C
	where C.Metadata_Table_ID in (1,3,11)
	and C.Column_Name in
	(
		'TSSA',
		'English_Long_Description',
		'English_Short_Description',
		'EnglishLongDescription',
		'EnglishShortDescription'
	)
)

update ColumnDisplayName
set display = 1
where id in
(
	Select CDN.id from ColumnDisplayName CDN
	where CDN.Workflow_ID= 2
	and CDN.column_name in
	(
	'EnglishLongDescription',
	'EnglishShortDescription'
	)
)


update ColumnDisplayName
set Display = 1 where id in
(
	Select CDN.id from ColumnDisplayName CDN
	where CDN.Workflow_ID= 7
	and CDN.column_name in
	(
	'EnglishLongDescription',
	'EnglishShortDescription'
	)
)


update ColumnDisplayName set Display = 0 where column_name = 'CoinBattery'

update SPD_Item_Mapping set enabled = 1 where Mapping_Name = 'IMPORTITEM' and Mapping_Version = '16'


update SPD_RMS_Field_Lookup set RMS_Field_Name = 'phytotemporaryshipment' where Maint_Type = 'B' and Field_Name = 'PhytoTemporaryShipment'

-----------------
update SPD_Field_Locking 
set Permission = 'E' 
where 
Metadata_Column_ID in
(
	Select id from SPD_Metadata_Column C 
	where C.Metadata_Table_ID = 11
	and column_name like '%FumigationCertificate%'
)
and Workflow_Stage_ID = 26



--*********************
--PHYTO REPORT CHANGS POST 6/13/2024
--**********************

update SPD_Metadata_Column set Track_History  = 0 

update SPD_Metadata_Column set Track_History = 1 
where column_name in
(
'PhytoTemporaryShipment','PhytoSanitaryCertificate','FumigationCertificate'
)