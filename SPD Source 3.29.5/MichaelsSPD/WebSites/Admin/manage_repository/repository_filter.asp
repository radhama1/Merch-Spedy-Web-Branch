<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
Server.ScriptTimeout = 10800
%>
<!--#include file="./../app_include/_globalInclude.asp"--> 
<%
Dim fs, fp, fpq, fpc, dataset_types

Set fs				= New cls_FilterSet
Set dataset_types	= New cls_FilterPaneChoiceSetType

'Set the FrameSet Variables
fs.ApplicationPath			= Application.Value("AdminToolURL")
fs.ParentFramesetName		= "RepositoryWrapperFrameset"
fs.ScopeName				= "ADMIN.CONTENT"
'fs.ReferenceID				= Website_ID
fs.DimensionsPrefixString	= ""
fs.DimensionsSuffixString	= ",*"
fs.useEffects				= "false"

'Choices will be automatically generated for the following types
'TEXT
'DB_LOOKUP
'DATES
'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Show all Content"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Show all…"
fpq.FilterParameters.AddNewParameter "6",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Show Published…"
fpq.FilterParameters.AddNewParameter "6",""
fpq.FilterParameters.AddNewParameter "19","1"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Show Unpublished…"
fpq.FilterParameters.AddNewParameter "6",""
fpq.FilterParameters.AddNewParameter "19","0"

'Set the DataSet type
fp.Type_ID = dataset_types.LIST

'Define the choices for type LIST
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Documents"
fpc.Value = "0"
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Files"
fpc.Value = "1"
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Web Links"
fpc.Value = "2"

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Containing Any Text"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Matching the following phrase…"
fpq.FilterParameters.AddNewParameter "-400", "[EXACT_PHRASE]"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Matching any of the following words…"
fpq.FilterParameters.AddNewParameter "-400", "[OR_SEARCH]"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Matching all of the following words…"
fpq.FilterParameters.AddNewParameter "-400", "[AND_SEARCH]"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Document Title Contains…"
fpq.FilterParameters.AddNewParameter "2",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Document Subheading Contains…"
fpq.FilterParameters.AddNewParameter "3",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Filename Contains…"
fpq.FilterParameters.AddNewParameter "7",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Web Link Contains…"
fpq.FilterParameters.AddNewParameter "13",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Custom Data Contains…"
fpq.FilterParameters.AddNewParameter "18",""

'Set the DataSet type
fp.Type_ID = dataset_types.TEXT

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Status"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Having a Status of…"
fpq.FilterParameters.AddNewParameter "9", ""

'Set the DataSet type
fp.Type_ID = dataset_types.DB_LOOKUP

'Requires a unique ID column followed by the text/number to display as an option
fp.ChoiceSet.SQL_String = "SELECT ID, Status_Name FROM Repository_Status WHERE Display = 1 ORDER BY Status_Name" 

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Start or End Date"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Starting…"
fpq.FilterParameters.AddNewParameter "120", null			'Today
fpq.FilterParameters.AddNewParameter "130", null			'This Week
fpq.FilterParameters.AddNewParameter "140", null			'This Month
fpq.FilterParameters.AddNewParameter "150", null			'Yesterday
fpq.FilterParameters.AddNewParameter "160", null			'Last Week
fpq.FilterParameters.AddNewParameter "170", null			'Last Month
fpq.FilterParameters.AddNewParameter "180", "[START_DATE]"	'On or After this Date...
fpq.FilterParameters.AddNewParameter "190", "[END_DATE]"	'On or Before this Date...
fpq.FilterParameters.AddNewParameter "180", "[START_DATE]"	'Between these dates...
fpq.FilterParameters.AddNewParameter "190", "[END_DATE]"		'..cont Between these dates
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Ending…"
fpq.FilterParameters.AddNewParameter "121", null				'Today
fpq.FilterParameters.AddNewParameter "131", null				'This Week
fpq.FilterParameters.AddNewParameter "141", null				'This Month
fpq.FilterParameters.AddNewParameter "151", null				'Yesterday
fpq.FilterParameters.AddNewParameter "161", null				'Last Week
fpq.FilterParameters.AddNewParameter "171", null				'Last Month
fpq.FilterParameters.AddNewParameter "181", "[START_DATE]"		'On or After this Date...
fpq.FilterParameters.AddNewParameter "191", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "181", "[START_DATE]"		'Between these dates...
fpq.FilterParameters.AddNewParameter "191", "[END_DATE]"		'..cont Between these dates

'Set the DataSet type
fp.Type_ID = dataset_types.DATE_TIME

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Language"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Containing Content in…"
fpq.FilterParameters.AddNewParameter "8", ""

'Set the DataSet type
fp.Type_ID = dataset_types.DB_LOOKUP

'Requires a unique ID column followed by the text/number to display as an option
fp.ChoiceSet.SQL_String = "SELECT a.ID, a.Language_PrettyName FROM app_languages a WHERE a.Enabled = 1 ORDER BY a.SortOrder, a.Language_PrettyName" 

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()
		
'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Date"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Created…"
fpq.FilterParameters.AddNewParameter "122", null			'Today
fpq.FilterParameters.AddNewParameter "132", null			'This Week
fpq.FilterParameters.AddNewParameter "142", null			'This Month
fpq.FilterParameters.AddNewParameter "152", null			'Yesterday
fpq.FilterParameters.AddNewParameter "162", null			'Last Week
fpq.FilterParameters.AddNewParameter "172", null			'Last Month
fpq.FilterParameters.AddNewParameter "182", "[START_DATE]"	'On or After this Date...
fpq.FilterParameters.AddNewParameter "192", "[END_DATE]"	'On or Before this Date...
fpq.FilterParameters.AddNewParameter "182", "[START_DATE]"	'Between these dates...
fpq.FilterParameters.AddNewParameter "192", "[END_DATE]"		'..cont Between these dates
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Last Modified…"
fpq.FilterParameters.AddNewParameter "123", null			'Today
fpq.FilterParameters.AddNewParameter "133", null			'This Week
fpq.FilterParameters.AddNewParameter "143", null			'This Month
fpq.FilterParameters.AddNewParameter "153", null			'Yesterday
fpq.FilterParameters.AddNewParameter "163", null			'Last Week
fpq.FilterParameters.AddNewParameter "173", null			'Last Month
fpq.FilterParameters.AddNewParameter "183", "[START_DATE]"	'On or After this Date...
fpq.FilterParameters.AddNewParameter "193", "[END_DATE]"	'On or Before this Date...
fpq.FilterParameters.AddNewParameter "183", "[START_DATE]"	'Between these dates...
fpq.FilterParameters.AddNewParameter "193", "[END_DATE]"		'..cont Between these dates
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Locked By…"
fpq.FilterParameters.AddNewParameter "124", null			'Today
fpq.FilterParameters.AddNewParameter "134", null			'This Week
fpq.FilterParameters.AddNewParameter "144", null			'This Month
fpq.FilterParameters.AddNewParameter "154", null			'Yesterday
fpq.FilterParameters.AddNewParameter "164", null			'Last Week
fpq.FilterParameters.AddNewParameter "174", null			'Last Month
fpq.FilterParameters.AddNewParameter "184", "[START_DATE]"	'On or After this Date...
fpq.FilterParameters.AddNewParameter "194", "[END_DATE]"	'On or Before this Date...
fpq.FilterParameters.AddNewParameter "184", "[START_DATE]"	'Between these dates...
fpq.FilterParameters.AddNewParameter "194", "[END_DATE]"		'..cont Between these dates

'Set the DataSet type
fp.Type_ID = dataset_types.DATE_TIME

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Locked State"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Locked By…"
fpq.FilterParameters.AddNewParameter "10",""

'Set the DataSet type
fp.Type_ID = dataset_types.DB_LOOKUP

'Requires a unique ID column followed by the text/number to display as an option declared before the sql_Str
fp.ChoiceSet.SQL_ID = "ID"
fp.ChoiceSet.SQL_Text = "UserName"
fp.ChoiceSet.SQL_String = "sp_security_list_users"

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

%>
<html>
	<head>
		<style type="text/css">
			@import url('./../app_include/Filter.css');
			@import url('./../app_include/global.css');
			A {text-decoration: none; color: #000;}
			A:HOVER {text-decoration: none; color: #00f;}
			BODY
			{
				margin: 0;
				padding: 5px;
				background: #ccc;
			}
			UL {list-style: square; margin-left: 20px;}
			
		</style>
		<script language="javascript" src="./../app_include/resizeFrame.js"></script>
		<script language="javascript" src="./../app_include/tween/tween.js"></script>
		<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
		<script language="javascript" src="./../app_include/evaluator.js"></script>
		<%
			fs.DisplayJS()
		%>
	</head>
	<body>
	<form id="theForm" name="theForm" action="repository_details.asp" target="DetailFrame" method="get" style="padding: 0; margin: 0;">
	<input type=hidden name="cid" value="-1" ID="cid">
	<%
		fs.Display()
	%>
	<!--<input type="hidden" name="filterHiddenParams" id="filterHiddenParams" value="0, 0;">-->
	</form>
	<script language=javascript>
		//printEvaluator();
	</script>
	</body>
</html>
<%
Set dataset_types	= Nothing
Set fpc				= Nothing
Set fpq				= Nothing
Set fp				= Nothing
Set fs				= Nothing
%>