	--*********************
	--  DATA UPDATES Version 3.27.2
	--*********************
	
	update SPD_Metadata_Column set Column_Format = 'formatnumber4' 
	where Metadata_Table_ID = 11 and column_name in
	(
	'InnerCaseCube',
	'MasterCaseCube',
	'EachCaseCube'
	)

	update ColumnDisplayName set Column_Format = 'formatnumber4' where Workflow_ID = 7 and column_name in
	(
	'InnerCaseCube',
	'MasterCaseCube',
	'EachCaseCube'
	)

	update ColumnDisplayName set Column_Format = 'formatnumber4' where Workflow_ID = 1 and column_name in
	(
	'Inner_Case_Pack_Cube',
	'Master_Case_Pack_Cube',
	'Each_Case_Pack_Cube'
	)

	update ColumnDisplayName set Column_Format = 'formatnumber4' where Workflow_ID = 2 and column_name in
	(
	'InnerCaseCube',
	'MasterCaseCube',
	'EachCaseCube'
	)

	update ColumnDisplayName 
	set column_format = 'formatnumber4'
	where Workflow_ID = 1 and
	column_name in 
	(
	'Inner_Case_Height',
	'Inner_Case_Width',
	'Inner_Case_Length',
	'Inner_Case_Weight',
	'Inner_Case_Pack_Cube',
	'Each_Case_Height',
	'Each_Case_Length',
	'Each_Case_Pack_Cube',
	'Each_Case_Weight',
	'Each_Case_Width',
	'Master_Case_Height',
	'Master_Case_Length',
	'Master_Case_Pack_Cube',
	'Master_Case_Weight',
	'Master_Case_Width'
	)

	--coin battery import mapping
	if not exists (Select 1 from SPD_Item_Mapping where mapping_name = 'IMPORTITEM' and Mapping_Version = '16.25')
	BEGIN
		exec usp_Copy_Item_Mapping 'IMPORTITEM', '16', '16.25'
	END

	DECLARE @IMID int
	Select @IMID = ID from SPD_Item_Mapping SIM where SIM.Mapping_Name= 'IMPORTITEM' and SIM.Mapping_Version = '16.25' 

	If not exists (Select 1 from SPD_Item_Mapping_Columns where item_mapping_id = @IMID and column_name = 'CoinBattery')
	BEGIN
		Insert into SPD_Item_Mapping_Columns (Item_Mapping_ID, Column_Name, Excel_Column, Excel_Row) values (@IMID,'CoinBattery','W',53)
	END


-- copy the TSSA metadata

insert [SPD_Metadata_Column] ([Metadata_Table_ID]
      ,[Column_Name]
      ,[Display_Name]
      ,[Sort_Order]
      ,[Enabled]
      ,[FieldLocking_Enabled]
      ,[Validation_Enabled]
      ,[Column_Ordinal]
      ,[Column_Generic_Type]
      ,[Max_Length]
      ,[Column_Format]
      ,[Column_Format_String]
      ,[Date_Created]
      ,[Date_Last_Modified]
      ,[Created_By]
      ,[Modified_By]
      ,[Maint_Workflow_Field]
      ,[Maint_Editable]
      ,[Send_To_RMS]
      ,[Update_Item_Master]
      ,[View_To_TableName]
      ,[View_To_ColumnName]
      ,[SQLPrecision]
      ,[Treat_Empty_As_Zero])

SELECT [Metadata_Table_ID]
      ,'CoinBattery'
      ,'CoinBattery'
      ,(select max(sort_order)+1 from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = [SPD_Metadata_Column].Metadata_Table_ID) as newsort
      ,[Enabled]
      ,[FieldLocking_Enabled]
      ,[Validation_Enabled]
      ,(select max(column_ordinal)+1 from [SPD_Metadata_Column] col2 where col2.Metadata_Table_ID = [SPD_Metadata_Column].Metadata_Table_ID) as neword
      ,[Column_Generic_Type]
      ,[Max_Length]
      ,[Column_Format]
      ,[Column_Format_String]
      ,[Date_Created]
      ,[Date_Last_Modified]
      ,[Created_By]
      ,[Modified_By]
      ,[Maint_Workflow_Field]
      ,[Maint_Editable]
      ,[Send_To_RMS]
      ,[Update_Item_Master]
      ,[View_To_TableName]
      ,case when [View_To_ColumnName] = 'TSSA' then 'CoinBattery' else [View_To_ColumnName] end as colname
      ,[SQLPrecision]
      ,[Treat_Empty_As_Zero]
  FROM [dbo].[SPD_Metadata_Column]
  where column_name = 'TSSA'