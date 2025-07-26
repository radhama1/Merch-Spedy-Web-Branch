
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].Import_Burden_Defaults (
	
Agent_Name varchar(50) not null,
Private_Brand_Flag bit not null,
Default_Rate float not null,
Date_Created datetime,
Date_Last_Modified datetime
 CONSTRAINT [PK_Import_Burden_Defaults] PRIMARY KEY CLUSTERED 
(
	Agent_Name ASC,
	Private_Brand_Flag ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].Import_Burden_Defaults ADD  CONSTRAINT [DF_Import_Burden_Defaults_Date_Created]  DEFAULT (getdate()) FOR [Date_Created]
GO

ALTER TABLE [dbo].Import_Burden_Defaults ADD  CONSTRAINT [DF_Import_Burden_Defaults_Date_Last_Modified]  DEFAULT (getdate()) FOR [Date_Last_Modified]
GO






