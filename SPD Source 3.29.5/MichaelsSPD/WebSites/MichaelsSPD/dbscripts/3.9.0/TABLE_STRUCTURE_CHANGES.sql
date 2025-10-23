


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--***************************************************************************
--CREATE STOCKING_STRATEGY
--***************************************************************************

IF EXISTS (SELECT * FROM sysobjects where xtype = 'U' and name = 'Stocking_Strategy')
	DROP TABLE [dbo].[Stocking_Strategy]
go

CREATE TABLE [dbo].[Stocking_Strategy](
	[Strategy_Code] [nvarchar](5) NOT NULL,
	[Strategy_Desc] [nvarchar](300) NOT NULL,
	[Strategy_Type] [nvarchar](1) NOT NULL,
	[Warehouse] [bigint] NOT NULL,
	[Start_Date] [datetime] NULL,
	[End_Date] [datetime] NULL,
	[Strategy_Status] [nvarchar](1) NOT NULL,
 CONSTRAINT [PK_Stocking_Strategy] PRIMARY KEY CLUSTERED 
(
	[Strategy_Code] ASC,
	[Warehouse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRG_Stocking_Strategy_IUD]'))
	DROP TRIGGER [dbo].TRG_Stocking_Strategy_IUD
go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create TRIGGER [dbo].[TRG_Stocking_Strategy_IUD]
   ON  [dbo].[Stocking_Strategy]
   AFTER INSERT,UPDATE,DELETE
AS 
BEGIN
	SET NOCOUNT ON;

	declare @stock_group_id int

	select @stock_group_id = ID from List_Value_Groups where List_Value_Group = 'STOCKSTRAT'

	if @stock_group_id > 0
	begin
		delete list_values where List_Value_Group_ID = @stock_group_id

		insert list_values (List_Value_Group_ID, List_Value, Display_Text, Sort_Order)
		select @stock_group_id, t.Strategy_Code, t.Strategy_Desc, row_number() over(order by strategy_code asc) from (select strategy_code, min(strategy_desc) as strategy_desc from stocking_strategy group by strategy_code) t
	end

END
GO



--***************************************************************************
--ALTER TABLE SPD_ITEMS
--***************************************************************************
ALTER TABLE SPD_Items
ADD 
Each_Case_Height decimal(18,6) NULL,
Each_Case_Width decimal(18,6) NULL,
Each_Case_Length decimal(18,6) NULL,
Each_Case_Weight decimal(18,6) NULL,
Each_Case_Pack_Cube decimal(18,6) NULL,
Stocking_Strategy_Code nvarchar(5) NULL

GO

--***************************************************************************
--ALTER TABLE SPD_IMPORT_ITEMS
--***************************************************************************
ALTER TABLE SPD_IMPORT_ITEMS
ADD 
Stocking_Strategy_Code	nvarchar(5) NULL,
eachheight	decimal(18,6) NULL,
eachwidth	decimal(18,6) NULL,
eachlength	decimal(18,6) NULL,
eachweight	decimal(18,6) NULL,
cubicfeeteach	decimal(18,6) NULL,
CanadaHarmonizedCodeNumber	varchar(10)	NULL

GO


--***************************************************************************
--ALTER TABLE SPD_Item_Master_Vendor_Countries
--***************************************************************************
ALTER TABLE SPD_Item_Master_Vendor_Countries
ADD 
Each_Case_Height decimal(18,6),
Each_Case_Width decimal(18,6),
Each_Case_Length decimal(18,6),
Each_Case_Weight decimal(18,6),
Each_LWH_UOM varchar(10),
Each_Weight_UOM varchar(10),
Each_Case_Cube decimal(18,6)

GO

--***************************************************************************
--ALTER TABLE SPD_Item_Master
--***************************************************************************

ALTER TABLE SPD_Item_Master
ADD 
STOCKING_STRATEGY_CODE nvarchar(5) NULL

--***************************************************************************
--ALTER TABLE SPD_Item_Master_SKU
--***************************************************************************
ALTER TABLE SPD_Item_Master_SKU
ADD 
STOCKING_STRATEGY_CODE nvarchar(5)

GO


