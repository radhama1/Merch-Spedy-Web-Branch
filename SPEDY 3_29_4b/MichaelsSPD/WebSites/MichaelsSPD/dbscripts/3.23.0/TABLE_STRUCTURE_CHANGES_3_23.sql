

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DC_Cutover_Schedule]
(
	[Cutover_Warehouse] [bigint] NOT NULL,
	[Destination_Warehouse] [bigint] NOT NULL,
	[Cutover_Date] [datetime] NULL,
 CONSTRAINT [DC_Cutover_Schedule_PK] PRIMARY KEY CLUSTERED 
(
	[Cutover_Warehouse] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


