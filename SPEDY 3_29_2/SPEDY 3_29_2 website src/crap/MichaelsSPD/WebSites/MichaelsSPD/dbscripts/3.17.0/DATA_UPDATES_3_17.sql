--DATA UPDATES FOR VERSION 3.17

--UPDATE ColumnDisplayName
update ColumnDisplayName 
set Column_Format = 'formatnumber4' 
where Workflow_ID = 1 and Column_Name in
(
'Inner_Case_Weight',
'Master_Case_Weight',
'Each_Case_Weight'
)

update ColumnDisplayName 
set Column_Format = 'formatnumber4' 
where Workflow_ID = 2 and Column_Name in
(
'InnerCaseWeight',
'MasterCaseWeight',
'EachCaseWeight'
)

update ColumnDisplayName 
set Column_Format = 'formatnumber4' 
where Workflow_ID = 7 and Column_Name in
(
'InnerCaseWeight',
'MasterCaseWeight',
'EachCaseWeight'
)