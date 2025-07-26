<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
Server.ScriptTimeout = 10800
%>
<!--#include file="./../app_include/_globalInclude.asp"--> 
<%
Dim enumerateUserGroup, enumerateUserRole

enumerateUserGroup = Request("enumgroup")
if IsNumeric(enumerateUserGroup) then
	enumerateUserGroup = CBool(enumerateUserGroup)
else
	enumerateUserGroup = CBool(0)
end if

enumerateUserRole = Request("enumrole")
if IsNumeric(enumerateUserRole) then
	enumerateUserRole = CBool(enumerateUserRole)
else
	enumerateUserRole = CBool(0)
end if

Dim fs, fp, fpq, fpc, dataset_types

Set fs				= New cls_FilterSet
Set dataset_types	= New cls_FilterPaneChoiceSetType

'Set the FrameSet Variables
fs.ApplicationPath			= Application.Value("AdminToolURL")
fs.ParentFramesetName		= "MainDetailFrame"
fs.ScopeName				= "ADMIN.SECURITY"
fs.FilterHeading			= ""
fs.useEffects				= "false"
If enumerateUserGroup Or enumerateUserRole Then
	fs.DimensionsPrefixString	= "15,"
	fs.DimensionsSuffixString	= ",1,15,*,20"
Else
	fs.DimensionsPrefixString	= "1,"
	fs.DimensionsSuffixString	= ",15,*,20"
End If

'Choices will be automatically generated for the following types
'TEXT
'DB_LOOKUP
'DATES
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
fpq.Text = "User Name Contains…"
fpq.FilterParameters.AddNewParameter "1",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Last Name Contains…"
fpq.FilterParameters.AddNewParameter "2",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "First Name Contains…"
fpq.FilterParameters.AddNewParameter "3",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Organization Contains…"
fpq.FilterParameters.AddNewParameter "4",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Email Address Contains…"
fpq.FilterParameters.AddNewParameter "5",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Department Contains…"
fpq.FilterParameters.AddNewParameter "6",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Job Title Contains…"
fpq.FilterParameters.AddNewParameter "7",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Office Location Contains…"
fpq.FilterParameters.AddNewParameter "8",""

'Set the DataSet type
fp.Type_ID = dataset_types.TEXT

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Status"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Show only…"
fpq.FilterParameters.AddNewParameter "9",""

'Set the DataSet type
fp.Type_ID = dataset_types.LIST
fp.ChoiceSet.List_Multiple_HTML = ""

'Define the choices for type LIST
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Enabled"
fpc.Value = "1"
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Disabled"
fpc.Value = "0"

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
'Add New Pane
Set fp = fs.AddNewPane()
		
'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Date"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Created…"
fpq.FilterParameters.AddNewParameter "20", null				'Today
fpq.FilterParameters.AddNewParameter "30", null				'This Week
fpq.FilterParameters.AddNewParameter "40", null				'This Month
fpq.FilterParameters.AddNewParameter "70", null				'Yesterday
fpq.FilterParameters.AddNewParameter "80", null				'Last Week
fpq.FilterParameters.AddNewParameter "90", null				'Last Month
fpq.FilterParameters.AddNewParameter "50", "[START_DATE]"	'On or After this Date...
fpq.FilterParameters.AddNewParameter "60", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "50", "[START_DATE]"	'Between these dates...
fpq.FilterParameters.AddNewParameter "60", "[END_DATE]"		'..cont Between these dates
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Last Modified…"
fpq.FilterParameters.AddNewParameter "21", null				'Today
fpq.FilterParameters.AddNewParameter "31", null				'This Week
fpq.FilterParameters.AddNewParameter "41", null				'This Month
fpq.FilterParameters.AddNewParameter "71", null				'Yesterday
fpq.FilterParameters.AddNewParameter "81", null				'Last Week
fpq.FilterParameters.AddNewParameter "91", null				'Last Month
fpq.FilterParameters.AddNewParameter "51", "[START_DATE]"	'On or After this Date...
fpq.FilterParameters.AddNewParameter "61", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "51", "[START_DATE]"	'Between these dates...
fpq.FilterParameters.AddNewParameter "61", "[END_DATE]"		'..cont Between these dates

'Set the DataSet type
fp.Type_ID = dataset_types.DATE_TIME

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of User Privilege"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Having a privilege of…"
fpq.FilterParameters.AddNewParameter "100", ""

'Set the DataSet type
fp.Type_ID = dataset_types.DB_LOOKUP

'Requires a unique ID column followed by the text/number to display as an option
fp.ChoiceSet.SQL_String = "SELECT sp.ID, Replace(sp.Privilege_Name, '$$SCOPE_NAME$$', ss.Scope_Name) FROM Security_Privilege sp INNER JOIN Security_Scope ss On sp.Scope_ID = ss.ID WHERE sp.Advanced = 0 ORDER BY sp.SortOrder" 

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Group"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Having a group of…"
fpq.FilterParameters.AddNewParameter "101", ""

'Set the DataSet type
fp.Type_ID = dataset_types.DB_LOOKUP

'Requires a unique ID column followed by the text/number to display as an option
fp.ChoiceSet.SQL_String = "SELECT ID, Group_Name FROM Security_Group ORDER BY SortOrder" 

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Department"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Belonging to department…"
fpq.FilterParameters.AddNewParameter "102", ""

'Set the DataSet type
fp.Type_ID = dataset_types.DB_LOOKUP

'Requires a unique ID column followed by the text/number to display as an option
fp.ChoiceSet.SQL_String = "SELECT sp.ID, Privilege_Name FROM Security_Privilege sp INNER JOIN Security_Scope ss On sp.Scope_ID = ss.ID WHERE ss.Constant = 'SPD.DEPTS' ORDER BY sp.SortOrder" 


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
		<script language="javascript" src="./../app_include/ediTable_v1.1.js"></script>
		<script language="javascript" src="./../app_include/resizeFrame.js"></script>
		<script language="javascript" src="./../app_include/tween/tween.js"></script>
		<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
		<script language="javascript" src="./../app_include/evaluator.js"></script>
		<%
			fs.DisplayJS()
		%>
	</head>
	<body>
	<form id="theForm" name="theForm" action="security_details_results_redirect.asp" target="DetailFrame" method="post" style="padding: 0; margin: 0;" oncontextmenu="return false;">
		<input type=hidden name="enumgroup" value="<%=Request.QueryString("enumgroup")%>">
		<input type=hidden name="enumrole" value="<%=Request.QueryString("enumrole")%>">
	<%
		fs.Display()
	%>
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