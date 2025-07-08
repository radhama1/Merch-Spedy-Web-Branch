
alter table SPD_Import_Items add  SuppTariffPercent varchar(100);
go

alter table SPD_Import_Items add  SuppTariffAmount varchar(100);
go

alter table SPD_Item_Master_Vendor add Supp_Tariff_Percent decimal(18,6)
go

alter table SPD_Item_Master_Vendor add Supp_Tariff_Amount decimal(18,6)
go


