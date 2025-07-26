	--*********************
	--  TRIGGER UPDATES Version 3.27.2
	--*********************
	/****** Object:  Trigger [dbo].[TRG_SPD_Items_IU]    Script Date: 12/11/2023 12:56:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[TRG_SPD_Items_IU] 
   ON  [dbo].[SPD_Items]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    update SPD_Items
    set Each_Case_Pack_Cube = round(ins.Each_Case_Height * ins.Each_Case_Width * ins.Each_Case_Length / 1728, 4)
		, Inner_Case_Pack_Cube = round(ins.Inner_Case_Height * ins.Inner_Case_Width * ins.Inner_Case_Length / 1728, 4)
		, Master_Case_Pack_Cube = round(ins.Master_Case_Height * ins.Master_Case_Width * ins.Master_Case_Length / 1728, 4)
    from inserted ins
    where ins.ID = SPD_Items.ID

END

GO


/****** Object:  Trigger [dbo].[TRG_SPD_Import_Items_IU]    Script Date: 12/11/2023 2:15:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[TRG_SPD_Import_Items_IU] 
   ON  [dbo].[SPD_Import_Items]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	update SPD_Import_Items
    set cubicfeeteach = round(ins.eachheight * ins.eachwidth * ins.eachlength / 1728, 4)
    from inserted ins
    where ins.ID = SPD_Import_Items.ID
	and isnumeric(ins.eachheight) = 1 
	and isnumeric(ins.eachwidth) = 1 
	and isnumeric(ins.eachlength) = 1

	update SPD_Import_Items
    set CubicFeetPerInnerCarton = round(convert(decimal(18,4), ins.ReshippableInnerCartonHeight) * convert(decimal(18,4), ins.ReshippableInnerCartonWidth) * convert(decimal(18,4), ins.ReshippableInnerCartonLength) / 1728, 4)
    from inserted ins
    where ins.ID = SPD_Import_Items.ID
	and isnumeric(ins.ReshippableInnerCartonHeight) = 1 
	and isnumeric(ins.ReshippableInnerCartonWidth) = 1 
	and isnumeric(ins.ReshippableInnerCartonLength) = 1

	update SPD_Import_Items
    set CubicFeetPerMasterCarton = round(convert(decimal(18,4), ins.MasterCartonDimensionsHeight) * convert(decimal(18,4), ins.MasterCartonDimensionsWidth) * convert(decimal(18,4), ins.MasterCartonDimensionsLength) / 1728, 4)
    from inserted ins
    where ins.ID = SPD_Import_Items.ID
	and isnumeric(ins.MasterCartonDimensionsHeight) = 1 
	and isnumeric(ins.MasterCartonDimensionsWidth) = 1 
	and isnumeric(ins.MasterCartonDimensionsLength) = 1

END

GO