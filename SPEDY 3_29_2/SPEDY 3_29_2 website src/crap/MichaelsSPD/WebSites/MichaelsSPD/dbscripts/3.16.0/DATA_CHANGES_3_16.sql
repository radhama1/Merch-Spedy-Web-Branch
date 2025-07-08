--data updates for version 3.16

update SPD_Item_Mapping
set 
Enabled = 0
where 
Mapping_Name = 'DOMITEM' and Enabled = 1
and Mapping_Version <> '16.01 Version'

update SPD_Item_Mapping
set 
Enabled = 0
where 
Mapping_Name = 'DOMITEMHEADER' and Enabled = 1
and Mapping_Version <> '16.01 Version'

update SPD_Item_Mapping
set 
Enabled = 0
where 
Mapping_Name = 'IMPORTITEM' and Enabled = 1
and Mapping_Version <> '15'

Insert into SPD_Item_Mapping
([Default],	Mapping_Name,	Mapping_Version,	Date_Created,	Created_User_ID,	Date_Last_Modified,	Update_User_ID,	[Enabled])
Values
(0,'DOMITEMHEADER', '16.01 Version', Getdate(), 0, Getdate(),0,1)

Insert into SPD_Item_Mapping
([Default],	Mapping_Name,	Mapping_Version,	Date_Created,	Created_User_ID,	Date_Last_Modified,	Update_User_ID,	[Enabled])
Values
(0,'DOMITEM', '16.01 Version', Getdate(), 0, Getdate(),0,1)

Insert into SPD_Item_Mapping_Columns
Select 
(Select ID from SPD_Item_Mapping where Mapping_Name = 'DOMITEMHEADER' and Mapping_Version = '16.01 Version'),
Column_Name, excel_column, Excel_row
from SPD_Item_Mapping_Columns where Item_Mapping_ID = 
(
Select ID from SPD_Item_Mapping where Mapping_Name = 'DOMITEMHEADER' and Mapping_Version = '16 Version'
)

Insert into SPD_Item_Mapping_Columns
Select 
(Select ID from SPD_Item_Mapping where Mapping_Name = 'DOMITEM' and Mapping_Version = '16.01 Version'),
Column_Name, excel_column, Excel_row
from SPD_Item_Mapping_Columns where Item_Mapping_ID = 
(
Select ID from SPD_Item_Mapping where Mapping_Name = 'DOMITEM' and Mapping_Version = '16 Version'
)