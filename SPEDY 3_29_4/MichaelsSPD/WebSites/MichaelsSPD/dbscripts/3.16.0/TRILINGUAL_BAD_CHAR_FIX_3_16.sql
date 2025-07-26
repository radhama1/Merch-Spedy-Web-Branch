
update SPD_Item_Master_Languages set description_short = replace(description_short, char(26), '') where description_short like '%' + char(26) + '%'
update SPD_Item_Master_Languages set description_long = replace(description_long, char(26), '') where description_long like '%' + char(26) + '%'
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create TRIGGER [dbo].[TRG_SPD_Item_Master_Languages_IU] 
   ON  [dbo].[SPD_Item_Master_Languages]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    update SPD_Item_Master_Languages
    set description_short = replace(ins.description_short, char(26), ''),
	description_long = replace(ins.description_long, char(26), '')
    from inserted ins
    where ins.ID = SPD_Item_Master_Languages.ID

END

go

ALTER TRIGGER [dbo].[SPD_Item_Master_Changes_TrI] ON [dbo].[SPD_Item_Master_Changes] FOR INSERT AS  /* Generated on Jun 19 2010  2:27:22:473PM */ 

Update SPD_Item_Master_Changes set Field_Value = replace(ins.Field_Value, char(26), '')
from Inserted ins
where ins.Item_Maint_Items_ID = SPD_Item_Master_Changes.Item_Maint_Items_ID
and ins.Field_Name = SPD_Item_Master_Changes.Field_Name
and ins.Country_Of_Origin = SPD_Item_Master_Changes.Country_Of_Origin
and ins.UPC = SPD_Item_Master_Changes.UPC
and ins.Effective_Date = SPD_Item_Master_Changes.Effective_Date
and ins.Counter = SPD_Item_Master_Changes.Counter


INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
       SELECT 'SPD_Item_Master_Changes','New Record',Null,INS.[Field_Value],'I',getdate(),IsNull(convert(varchar(50),INS.Created_User_ID),SUser_SName()),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
       FROM Inserted INS

go

/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2012 (11.0.7462)
    Source Database Engine Edition : Microsoft SQL Server Standard Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [MichaelsSPD]
GO
/****** Object:  Trigger [dbo].[SPD_Item_Master_Changes_TrU]    Script Date: 5/24/2018 2:24:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[SPD_Item_Master_Changes_TrU] ON [dbo].[SPD_Item_Master_Changes] FOR UPDATE AS  /* Generated on Jun 19 2010  4:24:23:283PM */ 
Declare @Uname varchar(50), @ChangedUpdate char(1)
Set @Uname = '-2' 
If Not Update(Update_User_ID)
 Begin
 Set @ChangedUpdate = 'N'
 Update SPD_Item_Master_Changes Set Update_User_ID = @Uname, Date_Last_Modified = GetDate() 
 From SPD_Item_Master_Changes X 
 Join Inserted INS on INS.[Item_Maint_Items_ID] = X.[Item_Maint_Items_ID]
    AND INS.[Field_Name] = X.[Field_Name]
    AND INS.[Country_Of_Origin] = X.[Country_Of_Origin]
    AND INS.[UPC] = X.[UPC]
    AND INS.[Effective_Date] = X.[Effective_Date]
    AND INS.[Counter] = X.[Counter]
 End
Else
 Set @ChangedUpdate = 'Y' 
 
If Not Update(Date_Last_Modified)
   Update SPD_Item_Master_Changes Set Date_Last_Modified = GetDate() 
   From SPD_Item_Master_Changes X 
   Join Inserted INS on INS.[Item_Maint_Items_ID] = X.[Item_Maint_Items_ID]
                    AND INS.[Field_Name] = X.[Field_Name]
                    AND INS.[Country_Of_Origin] = X.[Country_Of_Origin]
                    AND INS.[UPC] = X.[UPC]
                    AND INS.[Effective_Date] = X.[Effective_Date]
                    AND INS.[Counter] = X.[Counter]
   Where Isnull(INS.Update_User_ID,'') <> ''  
   
If Update(Item_Maint_Items_ID)    INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
   SELECT 'SPD_Item_Master_Changes','Item_Maint_Items_ID',convert(nvarchar(2000),DEL.Item_Maint_Items_ID),convert(nvarchar(2000),INS.Item_Maint_Items_ID),'U',getdate(),(Case @ChangedUpdate When 'Y' Then IsNull(INS.Update_User_ID,@UName) Else @Uname End),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
   FROM   Inserted INS, Deleted DEL    WHERE  INS.[Item_Maint_Items_ID] =  DEL.[Item_Maint_Items_ID] and
          INS.[Field_Name] =  DEL.[Field_Name] and           INS.[Country_Of_Origin] =  DEL.[Country_Of_Origin] and
          INS.[UPC] =  DEL.[UPC] and           INS.[Effective_Date] =  DEL.[Effective_Date] and
          INS.[Counter] =  DEL.[Counter] and          (isnull(INS.Item_Maint_Items_ID,0) <> isnull(DEL.Item_Maint_Items_ID,0)) 
          
If Update(Field_Name)    INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
   SELECT 'SPD_Item_Master_Changes','Field_Name',convert(nvarchar(2000),DEL.Field_Name),convert(nvarchar(2000),INS.Field_Name),'U',getdate(),(Case @ChangedUpdate When 'Y' Then IsNull(INS.Update_User_ID,@UName) Else @Uname End),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
   FROM   Inserted INS, Deleted DEL    WHERE  INS.[Item_Maint_Items_ID] =  DEL.[Item_Maint_Items_ID] and
          INS.[Field_Name] =  DEL.[Field_Name] and           INS.[Country_Of_Origin] =  DEL.[Country_Of_Origin] and
          INS.[UPC] =  DEL.[UPC] and           INS.[Effective_Date] =  DEL.[Effective_Date] and
          INS.[Counter] =  DEL.[Counter] and          (isnull(INS.Field_Name,'') <> isnull(DEL.Field_Name,'')) 
          
If Update(Country_Of_Origin)    INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
   SELECT 'SPD_Item_Master_Changes','Country_Of_Origin',convert(nvarchar(2000),DEL.Country_Of_Origin),convert(nvarchar(2000),INS.Country_Of_Origin),'U',getdate(),(Case @ChangedUpdate When 'Y' Then IsNull(INS.Update_User_ID,@UName) Else @Uname End),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
   FROM   Inserted INS, Deleted DEL    WHERE  INS.[Item_Maint_Items_ID] =  DEL.[Item_Maint_Items_ID] and
          INS.[Field_Name] =  DEL.[Field_Name] and           INS.[Country_Of_Origin] =  DEL.[Country_Of_Origin] and
          INS.[UPC] =  DEL.[UPC] and           INS.[Effective_Date] =  DEL.[Effective_Date] and
          INS.[Counter] =  DEL.[Counter] and          (isnull(INS.Country_Of_Origin,'') <> isnull(DEL.Country_Of_Origin,'')) 
          
If Update(UPC)    INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
   SELECT 'SPD_Item_Master_Changes','UPC',convert(nvarchar(2000),DEL.UPC),convert(nvarchar(2000),INS.UPC),'U',getdate(),(Case @ChangedUpdate When 'Y' Then IsNull(INS.Update_User_ID,@UName) Else @Uname End),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
   FROM   Inserted INS, Deleted DEL    WHERE  INS.[Item_Maint_Items_ID] =  DEL.[Item_Maint_Items_ID] and
          INS.[Field_Name] =  DEL.[Field_Name] and           INS.[Country_Of_Origin] =  DEL.[Country_Of_Origin] and
          INS.[UPC] =  DEL.[UPC] and           INS.[Effective_Date] =  DEL.[Effective_Date] and
          INS.[Counter] =  DEL.[Counter] and          (isnull(INS.UPC,'') <> isnull(DEL.UPC,'')) 
          
If Update(Effective_Date)    INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
   SELECT 'SPD_Item_Master_Changes','Effective_Date',convert(nvarchar(2000),DEL.Effective_Date),convert(nvarchar(2000),INS.Effective_Date),'U',getdate(),(Case @ChangedUpdate When 'Y' Then IsNull(INS.Update_User_ID,@UName) Else @Uname End),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
   FROM   Inserted INS, Deleted DEL    WHERE  INS.[Item_Maint_Items_ID] =  DEL.[Item_Maint_Items_ID] and
          INS.[Field_Name] =  DEL.[Field_Name] and           INS.[Country_Of_Origin] =  DEL.[Country_Of_Origin] and
          INS.[UPC] =  DEL.[UPC] and           INS.[Effective_Date] =  DEL.[Effective_Date] and
          INS.[Counter] =  DEL.[Counter] and          (isnull(INS.Effective_Date,'') <> isnull(DEL.Effective_Date,'')) 
          
If Update(Counter)    INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
   SELECT 'SPD_Item_Master_Changes','Counter',convert(nvarchar(2000),DEL.Counter),convert(nvarchar(2000),INS.Counter),'U',getdate(),(Case @ChangedUpdate When 'Y' Then IsNull(INS.Update_User_ID,@UName) Else @Uname End),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
   FROM   Inserted INS, Deleted DEL    WHERE  INS.[Item_Maint_Items_ID] =  DEL.[Item_Maint_Items_ID] and
          INS.[Field_Name] =  DEL.[Field_Name] and           INS.[Country_Of_Origin] =  DEL.[Country_Of_Origin] and
          INS.[UPC] =  DEL.[UPC] and           INS.[Effective_Date] =  DEL.[Effective_Date] and
          INS.[Counter] =  DEL.[Counter] and          (isnull(INS.Counter,0) <> isnull(DEL.Counter,0)) 
          
If Update(Field_Value)
BEGIN
	Update SPD_Item_Master_Changes set Field_Value = replace(ins.Field_Value, char(26), '')
	from Inserted ins
	where ins.Item_Maint_Items_ID = SPD_Item_Master_Changes.Item_Maint_Items_ID
	and ins.Field_Name = SPD_Item_Master_Changes.Field_Name
	and ins.Country_Of_Origin = SPD_Item_Master_Changes.Country_Of_Origin
	and ins.UPC = SPD_Item_Master_Changes.UPC
	and ins.Effective_Date = SPD_Item_Master_Changes.Effective_Date
	and ins.Counter = SPD_Item_Master_Changes.Counter

   INSERT SPD_AuditLog (TableName,FieldName,OldValue,NewValue,ActionCode,ActionDate,UserLogin,KeyValue1,KeyValue2,KeyValue3,KeyValue4,KeyValue5,KeyValue6)
   SELECT 'SPD_Item_Master_Changes','Field_Value',convert(nvarchar(2000),DEL.Field_Value),convert(nvarchar(2000),INS.Field_Value),'U',getdate(),(Case @ChangedUpdate When 'Y' Then IsNull(INS.Update_User_ID,@UName) Else @Uname End),
                Convert(varchar(255),INS.[Item_Maint_Items_ID]),Convert(varchar(255),INS.[Field_Name]),Convert(varchar(255),INS.[Country_Of_Origin]),
                Convert(varchar(255),INS.[UPC]),Convert(varchar(255),INS.[Effective_Date]),Convert(varchar(255),INS.[Counter])
   FROM   Inserted INS, Deleted DEL    WHERE  INS.[Item_Maint_Items_ID] =  DEL.[Item_Maint_Items_ID] and
          INS.[Field_Name] =  DEL.[Field_Name] and           INS.[Country_Of_Origin] =  DEL.[Country_Of_Origin] and
          INS.[UPC] =  DEL.[UPC] and           INS.[Effective_Date] =  DEL.[Effective_Date] and
          INS.[Counter] =  DEL.[Counter] and          (isnull(INS.Field_Value,'') <> isnull(DEL.Field_Value,'')) 
END

go


