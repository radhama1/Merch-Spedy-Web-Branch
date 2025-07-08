

select * from [List_Values] where List_Value_Group_ID = 2

insert into [dbo].[List_Values](List_Value_Group_ID,List_Value,Display_Text,Sort_Order)
values('2','SB','Sellable Bundle','7');

-- update [List_Values] set list_value = 'SB', Display_Text =  'Sellable Bundle' where  List_Value_Group_ID = 2 and sort_order = 7

-- not necessary in prod

select * from SPD_UDA_Value_Descriptions where uda_id = 701

insert into SPD_UDA_Value_Descriptions
values('701','1','Baloon bundle');


update Validation_Conditions
set value1='D,D-PDQ,D-PIAB,DP-PDQ,DP-PIAB,DP,SB'
where id in(select id from Validation_Conditions where value1 ='D,D-PDQ,D-PIAB,DP-PDQ,DP-PIAB,DP');

--exclude SB from existing vendor validation
insert validation_conditions (Validation_Condition_Set_ID, Validation_Condition_Type_ID, condition_ordinal, field1, value1, operator, Conjunction)
values (480, 27, 4, 102, 'SB', null, 'AND')

