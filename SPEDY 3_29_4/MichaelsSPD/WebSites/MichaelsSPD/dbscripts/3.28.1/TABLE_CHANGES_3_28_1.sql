--*********************
--  NEW PHYTO
--  TABLE ALTERS Version PHTYO Changes
--*********************

--IMPORT
ALTER TABLE SPD_Import_Items 
ADD PhytoTemporaryShipment varchar(1) null

--MAINT
ALTER TABLE SPD_Item_Master_SKU
add PhytoTemporaryShipment varchar(5) null


--DOMESTIC
ALTER TABLE SPD_Items 
ADD PhytoSanitaryCertificate varchar(1) null

ALTER TABLE SPD_Items 
ADD PhytoTemporaryShipment varchar(1) null


ALTER TABLE SPD_Import_Items 
ADD 
MinimumOrderQuantity int null,
ProductIdentifiesAsCosmetic varchar(1) null


ALTER TABLE SPD_Item_Master_Vendor 
ADD 
MinimumOrderQuantity int null,
ProductIdentifiesAsCosmetic varchar(1) null



--*********************
--PHYTO REPORT CHANGS POST 6/13/2024
--**********************

--*********************
--  NEW PHYTO
--  TABLE CHANGES Version PHTYO Changes Post 6/13/2024
--*********************

/****** Object:  Table [dbo].[SPD_Change_Field_History]    Script Date: 6/13/2024 1:06:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPD_Change_Field_History](
	[Michaels_SKU] [varchar](10) NOT NULL,
	[Batch_ID] [bigint] NOT NULL,
	[Metadata_Column_ID] [int] NOT NULL,
	[Old_Value] [varchar](max) NULL,
	[New_Value] [varchar](max) NULL,
	[Date_Created] [datetime] NOT NULL,
 CONSTRAINT [PK_SPD_Change_Field_History] PRIMARY KEY CLUSTERED 
(
	[Michaels_SKU] ASC,
	[Batch_ID] ASC,
	[Metadata_Column_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPD_Change_Field_History] ADD  CONSTRAINT [DF_SPD_Change_Field_History_Date_Created]  DEFAULT (getdate()) FOR [Date_Created]
GO

--add track history flag
ALTER TABLE SPD_Metadata_Column
ADD Track_History bit default (0)