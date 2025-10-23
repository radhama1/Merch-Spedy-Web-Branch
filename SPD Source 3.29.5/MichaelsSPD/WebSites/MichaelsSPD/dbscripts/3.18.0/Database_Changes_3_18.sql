----------------------------------
--ALTER PO_CREATION TABLE
----------------------------------

ALTER TABLE PO_CREATION
ADD Allow_Seasonal_Items_Basic_DC bit

---------------------------------------------------------------------------
----------------------------------
--add data to SPD_Metadata_Column
----------------------------------
Insert into SPD_Metadata_Column 
(
Metadata_Table_ID,	Column_Name,	Display_Name,	Sort_Order,	Enabled,
FieldLocking_Enabled,	Validation_Enabled,	Column_Ordinal,	Column_Generic_Type,
Max_Length,	Column_Format,	Column_Format_String,	Date_Created,	Date_Last_Modified,
Created_By,	Modified_By,	Maint_Workflow_Field,	Maint_Editable,	Send_To_RMS,
Update_Item_Master,	View_To_TableName,	View_To_ColumnName,	SQLPrecision,	Treat_Empty_As_Zero)
values
(
15, 'Allow_Seasonal_Items_Basic_DC', 'Allow Seasonal Items at Basic DC',35,1,
1,1,35,'boolean',
null,'boolean',null,GETDATE(),GETDATE(),
Null,null,1,1,Null,
Null,null,null,null,0
)


---------------------------------------------------------------------------
----------------------------------
--add data to SPD_Field_Locking
----------------------------------

DECLARE @newID int
Select @newID = ID 
from SPD_Metadata_Column SMC 
where SMC.Metadata_Table_ID = 15
and Column_Name = 'Allow_Seasonal_Items_Basic_DC'

DECLARE @templateID int
Select @templateID = ID 
from SPD_Metadata_Column SMC 
where SMC.Metadata_Table_ID = 15
and Column_Name = 'Internal_Comment'

Insert into SPD_Field_Locking
(Metadata_Column_ID,Field_Locking_User_Catagories_ID,Date_Created,Created_User_ID,Date_Last_Modified,Update_User_ID,Workflow_Stage_ID,Permission)
Select 
@newID, 6,GETDATE(),0,GETDATE(),0,FL.Workflow_Stage_ID,FL.Permission
from SPD_Field_Locking FL where FL.Metadata_Column_ID = @templateID


---------------------------------------------------------------------------

GO
/****** Object:  StoredProcedure [dbo].[PO_Creation_Get_By_ID]    Script Date: 08/28/2018 14:04:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PO_Creation_Get_By_ID]
	@ID bigint = 0
AS
BEGIN


	Select
		po.ID,
		po.Batch_Number,
		po.PO_Construct_ID,
		po.Batch_Type,
		po.PO_Status_ID,
		po.Workflow_Stage_ID,
		po.Vendor_Name,
		po.Vendor_Number,
		po.Basic_Seasonal,
		po.Workflow_Department_ID,
		po.PO_Department_ID,
		po.PO_Class,
		po.PO_Subclass,
		po.Approver_User_ID,
		po.Initiator_Role_ID,
		po.PO_Allocation_Event_ID,
		po.PO_Seasonal_Symbol_ID,
		po.Event_Year,
		po.Ship_Point_Description,
		po.Ship_Point_Code,
		po.POG_Number,
		po.POG_Start_Date,
		po.POG_End_Date,
		po.PO_Special_ID,
		po.Payment_Terms_ID,
		po.Freight_Terms_ID,
		po.Internal_Comment,
		po.External_Comment,
		po.Generated_Comment,
		po.Is_Alloc_Dirty,
		po.Is_Planner_Dirty,
		po.Is_Date_Warning,
		po.Is_Header_Valid,
		po.Is_Detail_Valid,
		po.Is_Validating,
		po.Validating_Job_ID,
		po.Enabled,
		po.Date_Created,
		po.Created_User_ID,
		Coalesce(c.First_Name + ' ', '') + Coalesce(c.Last_Name, '') as Created_User_Name,
		po.Date_Last_Modified,
		po.Modified_User_ID,
		Coalesce(m.First_Name + ' ', '') + Coalesce(m.Last_Name, '')  as Modified_User_Name,
		po.Allow_Seasonal_Items_Basic_DC
	From PO_Creation po
	LEFT JOIN Security_User as c on c.ID = po.Created_User_ID
	LEFT JOIN Security_USer as m on m.ID = po.Modified_User_ID
	Where po.ID = @ID
	
END

---------------------------------------------------------------------------

GO
/****** Object:  StoredProcedure [dbo].[PO_Creation_InsertUpdate]    Script Date: 08/28/2018 14:04:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PO_Creation_InsertUpdate] 
	@ID bigint = null OUTPUT,
	@Batch_Number varchar(100) = null,
	@PO_Construct_ID as tinyint,
	@Batch_Type as char(1) = null,
	@PO_Status_ID as tinyint = null,
	@Workflow_Stage_ID int = null,
	@Vendor_Name varchar(200) = null,
	@Vendor_Number bigint = null,
	@Basic_Seasonal char(1) = null,
	@Workflow_Department_ID int = null,
	@PO_Department_ID int = null,
	@PO_Class int = null,
	@PO_Subclass int = null,
	@Approver_User_ID int = null,
	@Initiator_Role_ID int = null,
	@PO_Allocation_Event_ID int = null,
	@PO_Seasonal_Symbol_ID int = null,
	@Event_Year int = null,
	@Ship_Point_Description varchar(100) = null,
	@Ship_Point_Code varchar(20) = null,
	@POG_Number as varchar(100) = null,
	@POG_Start_Date as datetime = null,
	@POG_End_Date as datetime = null,
	@PO_Special_ID int = null,
	@Payment_Terms_ID int = null,
	@Freight_Terms_ID int = null,
	@Internal_Comment varchar(MAX) = null,
	@External_Comment varchar(MAX) = null,
	@Generated_Comment varchar(MAX) = null,
	@Is_Header_Valid bit = null,
	@Is_Detail_Valid bit = null,
	@Is_Alloc_Dirty bit = null,
	@Enabled bit = null,
	@User_ID int,
	@Allow_Seasonal_Items_Basic_DC bit = null
	
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @Current_Date datetime	
	SET @Current_Date = getdate()

	IF Exists(Select 1 From [dbo].[PO_Creation] Where [ID] = @ID)
	BEGIN

		Update PO_Creation
		Set		
			Batch_Number = @Batch_Number,
			PO_Construct_ID = @PO_Construct_ID,
			Batch_Type = @Batch_Type,
			PO_Status_ID = @PO_Status_ID,
			Workflow_Stage_ID = @Workflow_Stage_ID,
			Vendor_Name = @Vendor_Name,
			Vendor_Number = @Vendor_Number,
			Basic_Seasonal = @Basic_Seasonal,
			Workflow_Department_ID = @Workflow_Department_ID,
			PO_Department_ID = @PO_Department_ID,
			PO_Class = @PO_Class,
			PO_Subclass = @PO_Subclass,
			Approver_User_ID = @Approver_User_ID,
			Initiator_Role_ID = @Initiator_Role_ID,
			PO_Allocation_Event_ID = @PO_Allocation_Event_ID,
			PO_Seasonal_Symbol_ID = @PO_Seasonal_Symbol_ID,
			Event_Year = @Event_Year,
			Ship_Point_Description = @Ship_Point_Description,
			Ship_Point_Code = @Ship_Point_Code,
			POG_Number = @POG_Number,
			POG_Start_Date = @POG_Start_Date,
			POG_End_Date = @POG_End_Date,
			PO_Special_ID = @PO_Special_ID,
			Payment_Terms_ID = @Payment_Terms_ID,
			Freight_Terms_ID = @Freight_Terms_ID,
			Internal_Comment = @Internal_Comment,
			External_Comment = @External_Comment,
			Generated_comment = @Generated_Comment,
			Is_Header_Valid = @Is_Header_Valid,
			Is_Detail_Valid = @Is_Detail_Valid,
			Is_Alloc_Dirty = @Is_Alloc_Dirty,
			Enabled = @Enabled,
			Date_Last_Modified = @Current_Date,
			Modified_User_ID = @User_ID,
			Allow_Seasonal_Items_Basic_DC = @Allow_Seasonal_Items_Basic_DC
		Where [ID] = @ID

	END
	ELSE
	BEGIN

		Insert Into PO_Creation(
			Batch_Number,
			PO_Construct_ID,
			Batch_Type,
			PO_Status_ID,
			Workflow_Stage_ID,
			Vendor_Name,
			Vendor_Number,
			Basic_Seasonal,
			Workflow_Department_ID,
			PO_Department_ID,
			PO_Class,
			PO_Subclass,
			Approver_User_ID,
			Initiator_Role_ID,
			PO_Allocation_Event_ID,
			PO_Seasonal_Symbol_ID,
			Event_Year,
			Ship_Point_Description,
			Ship_Point_Code,
			POG_Number,
			POG_Start_Date,
			POG_End_Date,
			PO_Special_ID,
			Payment_Terms_ID,
			Freight_Terms_ID,
			Internal_Comment,
			External_Comment,
			Generated_Comment,
			Is_Header_Valid,
			Is_Detail_Valid,
			Enabled,
			Date_Created,
			Created_User_ID,
			Date_Last_Modified,
			Modified_User_ID,
			Allow_Seasonal_Items_Basic_DC
		) Values (
			@Batch_Number,
			@PO_Construct_ID,
			@Batch_Type,
			@PO_Status_ID,
			@Workflow_Stage_ID,
			@Vendor_Name,
			@Vendor_Number,
			@Basic_Seasonal,
			@Workflow_Department_ID,
			@PO_Department_ID,
			@PO_Class,
			@PO_Subclass,
			@Approver_User_ID,
			@Initiator_Role_ID,
			@PO_Allocation_Event_ID,
			@PO_Seasonal_Symbol_ID,
			@Event_Year,
			@Ship_Point_Description,
			@Ship_Point_Code,
			@POG_Number,
			@POG_Start_Date,
			@POG_End_Date,
			@PO_Special_ID,
			@Payment_Terms_ID,
			@Freight_Terms_ID,
			@Internal_Comment,
			@External_Comment,
			@Generated_Comment,
			@Is_Header_Valid,
			@Is_Detail_Valid,
			@Enabled,
			@Current_Date,
			@User_ID,
			@Current_Date,
			@User_ID,
			@Allow_Seasonal_Items_Basic_DC
		)

		SET @ID = SCOPE_IDENTITY()
		
		IF Exists(Select 1 From PO_Construct Where ID = @PO_Construct_ID And Constant = 'MAN')
		BEGIN
			Update PO_Creation
			Set Batch_Number = 'MAN' + Cast(@ID as varchar)
			Where ID = @ID
		END

	END
	
END

---------------------------------------------------------------------------

GO
/****** Object:  StoredProcedure [dbo].[PO_Creation_Update_By_System]    Script Date: 08/28/2018 14:06:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PO_Creation_Update_By_System] 
	@ID bigint = null OUTPUT,
	@Batch_Number varchar(100),
	@PO_Construct_ID as tinyint,
	@Batch_Type as char(1) = null,
	@PO_Status_ID as tinyint = null,
	@Workflow_Stage_ID int = null,
	@Vendor_Name varchar(200) = null,
	@Vendor_Number bigint = null,
	@Basic_Seasonal char(1) = null,
	@Workflow_Department_ID int = null,
	@PO_Department_ID int = null,
	@PO_Class int = null,
	@PO_Subclass int = null,
	@Approver_User_ID int = null,
	@Initiator_Role_ID int = null,
	@PO_Allocation_Event_ID int = null,
	@PO_Seasonal_Symbol_ID int = null,
	@Event_Year int = null,
	@Ship_Point_Description varchar(100) = null,
	@Ship_Point_Code varchar(20) = null,
	@POG_Number varchar(100) = null,
	@POG_Start_Date datetime = null,
	@POG_End_Date datetime = null,
	@PO_Special_ID int = null,
	@Payment_Terms_ID varchar(50) = null,
	@Freight_Terms_ID varchar(50) = null,
	@Internal_Comment varchar(MAX) = null,
	@External_Comment varchar(MAX) = null,
	@Generated_Comment varchar(MAX) = null,
	@Is_Header_Valid bit = null,
	@Is_Detail_Valid bit = null,
	@Is_Validating bit = null,
	@Validating_Job_ID bigint = null,
	@Enabled bit = null,
	@Allow_Seasonal_Items_Basic_DC bit = Null
AS
BEGIN

	SET NOCOUNT ON

		Update PO_Creation
		Set		
			Batch_Number = @Batch_Number,
			PO_Construct_ID = @PO_Construct_ID,
			Batch_Type = @Batch_Type,
			PO_Status_ID = @PO_Status_ID,
			Workflow_Stage_ID = @Workflow_Stage_ID,
			Vendor_Name = @Vendor_Name,
			Vendor_Number = @Vendor_Number,
			Basic_Seasonal = @Basic_Seasonal,
			Workflow_Department_ID = @Workflow_Department_ID,
			PO_Department_ID = @PO_Department_ID,
			PO_Class = @PO_Class,
			PO_Subclass = @PO_Subclass,
			Approver_User_ID = @Approver_User_ID,
			Initiator_Role_ID = @Initiator_Role_ID,
			PO_Allocation_Event_ID = @PO_Allocation_Event_ID,
			PO_Seasonal_Symbol_ID = @PO_Seasonal_Symbol_ID,
			Event_Year = @Event_Year,
			Ship_Point_Description = @Ship_Point_Description,
			Ship_Point_Code = @Ship_Point_Code,
			POG_Number = @POG_Number,
			POG_Start_Date = @POG_Start_Date,
			POG_End_Date = @POG_End_Date,
			PO_Special_ID = @PO_Special_ID,
			Payment_Terms_ID= @Payment_Terms_ID,
			Freight_Terms_ID= @Freight_Terms_ID,
			Internal_Comment = @Internal_Comment,
			External_Comment = @External_Comment,
			Generated_comment = @Generated_Comment,
			Is_Header_Valid = @Is_Header_Valid,
			Is_Detail_Valid = @Is_Detail_Valid,
			Is_Validating = @Is_Validating,
			Validating_Job_ID = @Validating_Job_ID,
			Enabled = @Enabled,
			Allow_Seasonal_Items_Basic_DC = @Allow_Seasonal_Items_Basic_DC
		Where [ID] = @ID

END























