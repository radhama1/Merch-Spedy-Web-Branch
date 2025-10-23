

--truncate table Import_Burden_Defaults
--truncate table Import_Burden_Default_Exceptions
--select * from List_Values where List_Value_Group_ID = 19

insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('LI & FUNG', 0, 0.04)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('LI & FUNG', 1, 0.04)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('LI & FUNG - MEXICO', 0, 0.04)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('LI & FUNG - MEXICO', 1, 0.04)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('TEST RITE', 0, 0.04)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('TEST RITE', 1, 0.04)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('TEST RITE - VIETNAM', 0, 0.04)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('TEST RITE - VIETNAM', 1, 0.04)

insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('DGS', 0, 0.0)
insert Import_Burden_Defaults (Agent_Name, Private_Brand_Flag, Default_Rate) values ('DGS', 1, 0.02)

insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 20, 0, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 22, 0, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 23, 0, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 30, 0, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 74, 0, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 77, 0, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 78, 0, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 79, 0, 0.0)

insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 20, 1, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 22, 1, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 23, 1, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 30, 1, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 74, 1, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 77, 1, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 78, 1, 0.0)
insert Import_Burden_Default_Exceptions (Agent_Name, Dept, Private_Brand_Flag, Default_Rate) values ('DGS', 79, 1, 0.0)


