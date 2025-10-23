--delete SPD_Metadata_Column where column_name = 'RecAgentCommissionPercent' and Metadata_Table_ID = 1

Insert into SPD_Metadata_Column
(
	Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,	FieldLocking_Enabled,	Validation_Enabled,
	Column_Ordinal,	Column_Generic_Type,	Max_Length,	Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,
	Created_By,	Modified_By,	Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,	Update_Item_Master,	View_To_TableName,
	View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero
)
values
(
	1,	'RecAgentCommissionPercent',	'Rec. Merch Burden',	216,	1,	1,	1,
	216,	'string',	100,	'decimal',	Null,	GETDATE(),	GETDATE(),
	Null,	null,	0,	0,	Null,	null,	null,
	Null,	null,	0
)
