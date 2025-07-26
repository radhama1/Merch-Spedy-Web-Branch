
update SPD_Items
set Each_Case_Pack_Cube = round(Each_Case_Height * Each_Case_Width * Each_Case_Length / 1728, 3)
	, Inner_Case_Pack_Cube = round(Inner_Case_Height * Inner_Case_Width * Inner_Case_Length / 1728, 3)
	, Master_Case_Pack_Cube = round(Master_Case_Height * Master_Case_Width * Master_Case_Length / 1728, 3)

go


CREATE TRIGGER [dbo].[TRG_SPD_Items_IU] 
   ON  [dbo].[SPD_Items]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    update SPD_Items
    set Each_Case_Pack_Cube = round(ins.Each_Case_Height * ins.Each_Case_Width * ins.Each_Case_Length / 1728, 3)
		, Inner_Case_Pack_Cube = round(ins.Inner_Case_Height * ins.Inner_Case_Width * ins.Inner_Case_Length / 1728, 3)
		, Master_Case_Pack_Cube = round(ins.Master_Case_Height * ins.Master_Case_Width * ins.Master_Case_Length / 1728, 3)
    from inserted ins
    where ins.ID = SPD_Items.ID

END


