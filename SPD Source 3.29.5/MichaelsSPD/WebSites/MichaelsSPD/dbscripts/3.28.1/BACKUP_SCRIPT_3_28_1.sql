--****************
--BACK UP SCRIPT
--****************

SELECT *
INTO SPD_Workflow_Stage_PhytoBkup
FROM SPD_Workflow_Stage

GO

SELECT *
INTO SPD_workflow_stage_Exception_PhytoBkup
FROM SPD_workflow_stage_Exception

GO

SELECT *
INTO SPD_Workflow_Condition_PhytoBkup
FROM SPD_Workflow_Condition

GO

SELECT * 
INTO SPD_Workflow_Exception_Condition_PhytoBkup
from SPD_Workflow_Exception_Condition

GO

SELECT * 
INTO SPD_Workflow_Exception_Dept_PhytoBkup
from SPD_Workflow_Exception_Dept

GO


SELECT * 
INTO SPD_RMS_Field_Lookup_PhytoBkup
from SPD_RMS_Field_Lookup

GO

SELECT * 
INTO SPD_Metadata_Column_PhytoBkup
from SPD_Metadata_Column

GO


SELECT * 
INTO SPD_Field_Locking_PhytoBkup
from SPD_Field_Locking

GO

SELECT * 
INTO ColumnDisplayName_PhytoBkup
from ColumnDisplayName

GO

SELECT * 
INTO Validation_Rules_PhytoBkup
from Validation_Rules

GO

SELECT * 
INTO Validation_Condition_Sets_PhytoBkup
from Validation_Condition_Sets

GO

SELECT * 
INTO Validation_Conditions_PhytoBkup
from Validation_Conditions

GO


SELECT * 
INTO Validation_Condition_Set_Stages_PhytoBkup
from Validation_Condition_Set_Stages

GO


SELECT * 
INTO SPD_Item_Mapping_Columns_PhytoBkup
from SPD_Item_Mapping_Columns

GO


SELECT * 
INTO SPD_Item_Mapping_PhytoBkup
from SPD_Item_Mapping

GO

SELECT * 
INTO SPD_Report_PhytoBkup
from SPD_Report

GO