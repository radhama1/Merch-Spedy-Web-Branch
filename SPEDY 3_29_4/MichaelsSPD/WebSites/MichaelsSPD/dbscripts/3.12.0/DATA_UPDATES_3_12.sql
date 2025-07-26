--*****************************
--Validation_Condition_Types: add new validation conditions
--*****************************

insert into Validation_Condition_Types
(ID, Condition,Enabled,IsLookup,Sort_Order,IsChange)
values
(47, 'Lookup - Valid Stocking Strategy Status', 1, 1, 32, 0)

insert into Validation_Condition_Types
(ID, Condition,Enabled,IsLookup,Sort_Order,IsChange)
values
(48, 'Lookup - Valid Stocking Strategy Type', 1, 1, 33, 0)


--*****************************
--Validation_Condition_Types: reorder conditions
--*****************************
update Validation_Condition_Types set sort_order = 	34	where Id = 	16
update Validation_Condition_Types set sort_order = 	35	where Id = 	17
update Validation_Condition_Types set sort_order = 	36	where Id = 	29
update Validation_Condition_Types set sort_order = 	37	where Id = 	18
update Validation_Condition_Types set sort_order = 	38	where Id = 	19
update Validation_Condition_Types set sort_order = 	39	where Id = 	20
update Validation_Condition_Types set sort_order = 	40	where Id = 	21
update Validation_Condition_Types set sort_order = 	41	where Id = 	22
update Validation_Condition_Types set sort_order = 	42	where Id = 	23
update Validation_Condition_Types set sort_order = 	43	where Id = 	24
update Validation_Condition_Types set sort_order = 	44	where Id = 	25
update Validation_Condition_Types set sort_order = 	45	where Id = 	26
update Validation_Condition_Types set sort_order = 	46	where Id = 	27
update Validation_Condition_Types set sort_order = 	47	where Id = 	28


--*****************************
--SPD_Metadata_Column
--*****************************
update SPD_Metadata_Column set column_name = 'EachHeight' where Metadata_Table_ID = 1 and Column_Name = 'eachheight';
update SPD_Metadata_Column set column_name = 'EachWidth' where Metadata_Table_ID = 1 and Column_Name = 'eachwidth';
update SPD_Metadata_Column set column_name = 'EachLength' where Metadata_Table_ID = 1 and Column_Name = 'eachlength';
update SPD_Metadata_Column set column_name = 'EachWeight' where Metadata_Table_ID = 1 and Column_Name = 'eachweight';
update SPD_Metadata_Column set column_name = 'CubicFeetEach' where Metadata_Table_ID = 1 and Column_Name = 'cubicfeeteach';