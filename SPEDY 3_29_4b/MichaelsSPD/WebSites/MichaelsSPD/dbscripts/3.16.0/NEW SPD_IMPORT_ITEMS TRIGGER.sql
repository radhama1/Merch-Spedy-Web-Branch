
CREATE TRIGGER [dbo].[TRG_SPD_Import_Items_IU] 
   ON  [dbo].[SPD_Import_Items]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	update SPD_Import_Items
    set cubicfeeteach = round(ins.eachheight * ins.eachwidth * ins.eachlength / 1728, 3)
    from inserted ins
    where ins.ID = SPD_Import_Items.ID
	and isnumeric(ins.eachheight) = 1 
	and isnumeric(ins.eachwidth) = 1 
	and isnumeric(ins.eachlength) = 1

	update SPD_Import_Items
    set CubicFeetPerInnerCarton = round(convert(decimal(18,3), ins.ReshippableInnerCartonHeight) * convert(decimal(18,3), ins.ReshippableInnerCartonWidth) * convert(decimal(18,3), ins.ReshippableInnerCartonLength) / 1728, 3)
    from inserted ins
    where ins.ID = SPD_Import_Items.ID
	and isnumeric(ins.ReshippableInnerCartonHeight) = 1 
	and isnumeric(ins.ReshippableInnerCartonWidth) = 1 
	and isnumeric(ins.ReshippableInnerCartonLength) = 1

	update SPD_Import_Items
    set CubicFeetPerMasterCarton = round(convert(decimal(18,3), ins.MasterCartonDimensionsHeight) * convert(decimal(18,3), ins.MasterCartonDimensionsWidth) * convert(decimal(18,3), ins.MasterCartonDimensionsLength) / 1728, 3)
    from inserted ins
    where ins.ID = SPD_Import_Items.ID
	and isnumeric(ins.MasterCartonDimensionsHeight) = 1 
	and isnumeric(ins.MasterCartonDimensionsWidth) = 1 
	and isnumeric(ins.MasterCartonDimensionsLength) = 1

END
