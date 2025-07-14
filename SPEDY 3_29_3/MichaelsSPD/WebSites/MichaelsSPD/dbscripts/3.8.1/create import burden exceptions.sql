

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].Import_Burden_Default_Exceptions (
	
Agent_Name varchar(50) not null,
dept float not null,
Private_Brand_Flag bit not null,
Default_Rate float not null,
Date_Created datetime,
Date_Last_Modified datetime
 CONSTRAINT [PK_Import_Burden_Default_Exceptions] PRIMARY KEY CLUSTERED 
(
	Agent_Name ASC,
	dept asc,
	Private_Brand_Flag ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].Import_Burden_Default_Exceptions ADD  CONSTRAINT [DF_Import_Burden_Default_Exceptions_Date_Created]  DEFAULT (getdate()) FOR [Date_Created]
GO

ALTER TABLE [dbo].Import_Burden_Default_Exceptions ADD  CONSTRAINT [DF_Import_Burden_Default_Exceptions_Date_Last_Modified]  DEFAULT (getdate()) FOR [Date_Last_Modified]
GO






