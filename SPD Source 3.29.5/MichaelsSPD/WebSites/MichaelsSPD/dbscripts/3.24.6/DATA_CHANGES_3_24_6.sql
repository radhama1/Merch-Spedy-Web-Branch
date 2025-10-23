
update spd_item_mapping_columns set Excel_Column = 'BO' where Item_Mapping_ID = 73 and Excel_Row = 23 and Column_Name = 'PrivateBrandLabel'
update spd_item_mapping_columns set Excel_Column = 'BP' where Item_Mapping_ID = 73 and Excel_Row = 23 and Column_Name = 'TIEnglish'
update spd_item_mapping_columns set Excel_Column = 'BQ' where Item_Mapping_ID = 73 and Excel_Row = 23 and Column_Name = 'EnglishLongDescription'
update spd_item_mapping_columns set Excel_Column = 'BS' where Item_Mapping_ID = 73 and Excel_Row = 23 and Column_Name = 'EnglishShortDescription'
update spd_item_mapping_columns set Excel_Column = 'BT' where Item_Mapping_ID = 73 and Excel_Row = 23 and Column_Name = 'TIFrench'
update spd_item_mapping_columns set Excel_Column = 'BX' where Item_Mapping_ID = 73 and Excel_Row = 23 and Column_Name = 'TISpanish'
go

if not exists (select 1 from List_Values where List_value = '22' and List_Value_Group_ID = (select ID from List_Value_Groups where List_Value_Group = 'RMS_PBL'))
BEGIN
	insert List_Values (List_Value_Group_ID, List_Value, Display_Text, Sort_Order)
	select ID, 22, 'Artistree',22 from List_Value_Groups where List_Value_Group = 'RMS_PBL'
END
go

if not exists (select 1 from List_Values where List_value = '23' and List_Value_Group_ID = (select ID from List_Value_Groups where List_Value_Group = 'RMS_PBL'))
BEGIN
	insert List_Values (List_Value_Group_ID, List_Value, Display_Text, Sort_Order)
	select ID, 23, 'B2C',23 from List_Value_Groups where List_Value_Group = 'RMS_PBL'
END
go


update ColumnDisplayName set Display_Name = 'Low Elas3<br />Retail' where id = 20
update ColumnDisplayName set Display_Name = 'High Elas3<br />Retail' where id = 21
update ColumnDisplayName set Display_Name = 'Do Not Use<br />Retail' where id = 22
update ColumnDisplayName set Display_Name = 'High Cost<br />Retail' where id = 23
update ColumnDisplayName set Display_Name = 'Canada2<br />Retail' where id = 25
update ColumnDisplayName set Display_Name = 'Canada E-Comm<br />Retail' where id = 26
update ColumnDisplayName set Display_Name = 'Do Not Use<br />Retail' where id = 27
update ColumnDisplayName set Display_Name = 'Do Not Use<br />Retail' where id = 68
update ColumnDisplayName set Display_Name = 'Do Not Use<br />Retail' where id = 69
update ColumnDisplayName set Display_Name = 'Do Not Use<br />Retail' where id = 70
update ColumnDisplayName set Display_Name = 'Do Not Use<br />Retail' where id = 71
update ColumnDisplayName set Display_Name = 'E-Comm<br />Retail' where id = 72
update ColumnDisplayName set Display_Name = 'Quebec<br />Retail' where id = 256
update ColumnDisplayName set Display_Name = 'Comp<br />Retail' where id = 257

go


--*****************************
--Import Header
--*****************************
update SPD_Item_Mapping set [Default] = 0
go

Insert into SPD_Item_Mapping 
([Default],Mapping_Name, Mapping_Version, Date_Created, Created_User_Id, Date_Last_modified, Update_User_Id, Enabled)
values
(1,'IMPORTITEM','15.75', GETDATE(),0,GETDATE(),0,1)

go


--*****************************
--Import SPD_Item_Mapping_Columns - Import quote
--*****************************
insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) 
select 
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.75')
, mc.Column_Name, mc.Excel_Column, mc.Excel_Row 
from SPD_Item_Mapping_Columns mc where mc.Item_Mapping_ID = 
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.50')

go


--*****************************
--Domestic Header
--*****************************

Insert into SPD_Item_Mapping 
([Default],Mapping_Name, Mapping_Version, Date_Created, Created_User_Id, Date_Last_modified, Update_User_Id, Enabled)
values
(0,'DOMITEMHEADER','16.5 Version', GETDATE(),0,GETDATE(),0,1)

Insert into SPD_Item_Mapping 
([Default],Mapping_Name, Mapping_Version, Date_Created, Created_User_Id, Date_Last_modified, Update_User_Id, Enabled)
values
(0,'DOMITEM','16.5 Version', GETDATE(),0,GETDATE(),0,1)

go

--*****************************
--Domestic SPD_Item_Mapping_Columns
--*****************************
insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) 
select 
(Select ID from SPD_Item_Mapping where mapping_name = 'DOMITEM' and Mapping_Version = '16.5 Version')
, mc.Column_Name, mc.Excel_Column, mc.Excel_Row 
from SPD_Item_Mapping_Columns mc where mc.Item_Mapping_ID = 
(Select ID from SPD_Item_Mapping where mapping_name = 'DOMITEM' and Mapping_Version = '16.25 Version')

go

insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) 
select 
(Select ID from SPD_Item_Mapping where mapping_name = 'DOMITEMHEADER' and Mapping_Version = '16.5 Version')
, mc.Column_Name, mc.Excel_Column, mc.Excel_Row 
from SPD_Item_Mapping_Columns mc where mc.Item_Mapping_ID = 
(Select ID from SPD_Item_Mapping where mapping_name = 'DOMITEMHEADER' and Mapping_Version = '16.25 Version')

go


update spd_metadata_column set Update_Item_Master = 1, View_To_TableName = 'SPD_Item_Master_GTINs'  where Column_Name like '%GTIN%' and Metadata_Table_ID = 11

go


