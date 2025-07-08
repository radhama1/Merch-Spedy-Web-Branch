

--------------------------------------------------------------------------------------------------

--*****************************
--Import SPD_Item_Mapping  - Import quote
--*****************************
Insert into SPD_Item_Mapping 
([Default],Mapping_Name, Mapping_Version, Date_Created, Created_User_Id, Date_Last_modified, Update_User_Id, Enabled)
values
(0,'IMPORTITEM','15.12', GETDATE(),0,GETDATE(),0,1)

--disable old import
--update SPD_Item_Mapping 
--set Enabled = 0 
--where Mapping_Name = 'IMPORTITEM' and Mapping_Version = '15'

--------------------------------------------------------------------------------------------------

--*****************************
--Import SPD_Item_Mapping_Columns - Import quote
--*****************************
insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) 
select 
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.12')
, mc.Column_Name, mc.Excel_Column, mc.Excel_Row 
from SPD_Item_Mapping_Columns mc where mc.Item_Mapping_ID = 
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.11')

----------