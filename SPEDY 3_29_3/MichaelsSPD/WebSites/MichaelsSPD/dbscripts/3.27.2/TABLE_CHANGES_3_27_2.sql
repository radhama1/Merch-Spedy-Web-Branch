--*********************
--  TRIGGER UPDATES Version 3.27.2
--*********************

alter table spd_import_items add CoinBattery varchar(1) null
go

alter table SPD_Item_Master_SKU add CoinBattery varchar(5) null
go
