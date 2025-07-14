
--force freight to recalculate after triggers updated

update SPD_Item_Master_Vendor_Countries set unit_cost = unit_cost + 0.1 where unit_cost is not null
go
update SPD_Item_Master_Vendor_Countries set unit_cost = unit_cost - 0.1 where unit_cost is not null
go


--fix bad data that causes trigger to fail

update spd_import_items set ReshippableInnerCartonHeight = 9.8 where id = 317527 
go

--fix calcs on existing items

update spd_import_items set outboundFreight = round(convert(numeric(18,4),WarehouseLandedCost) * .06,4)
go

update spd_import_items set NinePercentWhseCharge = round((convert(numeric(18,4),outboundFreight) + convert(numeric(18,4),warehouselandedcost)) * .09,4)
go


update spd_import_items set TotalStoreLandedCost = round((convert(numeric(18,4),outboundFreight) + convert(numeric(18,4),warehouselandedcost) + convert(numeric(18,4),NinePercentWhseCharge)),4)
go


-- set canada permissions to be same as california for domestic

update SPD_Field_Locking set Permission = cali.Permission
from SPD_Field_Locking, SPD_Field_Locking cali
where SPD_Field_Locking.Metadata_Column_ID = 265
and cali.Metadata_Column_ID = 267
and SPD_Field_Locking.Field_Locking_User_Catagories_ID = cali.Field_Locking_User_Catagories_ID
and SPD_Field_Locking.Workflow_Stage_ID = cali.Workflow_Stage_ID
go

-- set quebec permissions to be same as california for domestic

update SPD_Field_Locking set Permission = cali.Permission
from SPD_Field_Locking, SPD_Field_Locking cali
where SPD_Field_Locking.Metadata_Column_ID = 1198
and cali.Metadata_Column_ID = 267
and SPD_Field_Locking.Field_Locking_User_Catagories_ID = cali.Field_Locking_User_Catagories_ID
and SPD_Field_Locking.Workflow_Stage_ID = cali.Workflow_Stage_ID
go

-- set canada permissions to be same as california for import

update SPD_Field_Locking set Permission = cali.Permission
from SPD_Field_Locking, SPD_Field_Locking cali
where SPD_Field_Locking.Metadata_Column_ID = 127
and cali.Metadata_Column_ID = 129
and SPD_Field_Locking.Field_Locking_User_Catagories_ID = cali.Field_Locking_User_Catagories_ID
and SPD_Field_Locking.Workflow_Stage_ID = cali.Workflow_Stage_ID
go

-- set quebec permissions to be same as california for import

update SPD_Field_Locking set Permission = cali.Permission
from SPD_Field_Locking, SPD_Field_Locking cali
where SPD_Field_Locking.Metadata_Column_ID = 1205
and cali.Metadata_Column_ID = 129
and SPD_Field_Locking.Field_Locking_User_Catagories_ID = cali.Field_Locking_User_Catagories_ID
and SPD_Field_Locking.Workflow_Stage_ID = cali.Workflow_Stage_ID
go



--*****************************
--Import SPD_Item_Mapping  - Import quote
--*****************************
Insert into SPD_Item_Mapping 
([Default],Mapping_Name, Mapping_Version, Date_Created, Created_User_Id, Date_Last_modified, Update_User_Id, Enabled)
values
(0,'IMPORTITEM','15.11', GETDATE(),0,GETDATE(),0,1)

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
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.11')
, mc.Column_Name, mc.Excel_Column, mc.Excel_Row 
from SPD_Item_Mapping_Columns mc where mc.Item_Mapping_ID = 
(Select ID from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '15.10')



-- set recommended import burden to zero for DGS

update import_burden_defaults set default_rate = 0 where agent_name = 'DGS'

