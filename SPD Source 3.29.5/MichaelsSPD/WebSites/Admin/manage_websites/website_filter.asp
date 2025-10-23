<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
Server.ScriptTimeout = 10800
%>
<!--#include file="./../app_include/_globalInclude.asp"--> 
<%
Dim Website_ID
Dim fs, fp, fpq, fpc, dataset_types

Set fs				= New cls_FilterSet
Set dataset_types	= New cls_FilterPaneChoiceSetType

'Get the Website ID
Website_ID = Request("webid")
if not IsNumeric(Website_ID) or Len(Trim(Website_ID)) = 0 then
	if IsNumeric(Session.Value("websiteID")) and Trim(Session.Value("websiteID")) <> "" then
		Website_ID = Session.Value("websiteID")
	else
		Website_ID = 0
	end if
end if
Session.Value("websiteID") = Website_ID

'Set the FrameSet Variables
fs.NumDisplayPanesPerRow	= 3
fs.ApplicationPath			= Application.Value("AdminToolURL")
fs.ParentFramesetName		= "WebsiteWrapperFrameset"
fs.ScopeName				= "ADMIN.WEBSITE"
fs.ReferenceID				= Website_ID
fs.DimensionsPrefixString	= "25, 4,"
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
fpq.FilterParameters.AddNewParameter "14",""

'Set the DataSet type
fp.Type_ID = dataset_types.LIST

'Define the choices for type LIST
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Documents"
fpc.Value = "2"
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Files"
fpc.Value = "3"
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Web Links"
fpc.Value = "4"

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Promotion State"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Show all…"
fpq.FilterParameters.AddNewParameter "28",""

'Set the DataSet type
fp.Type_ID = dataset_types.LIST

'Define the choices for type LIST
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Content Published to Live"
fpc.Value = "1"
Set fpc = fp.ChoiceSet.AddNewChoice()
fpc.Text = "Content Not Published to Live"
fpc.Value = "0"

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Modification State"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Live is Different from Staging"
fpq.FilterParameters.AddNewParameter "30", "Ken"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Live is Same as Staging"
fpq.FilterParameters.AddNewParameter "29", "Ken"

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
fpq.FilterParameters.AddNewParameter "4",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Document Subheading Contains…"
fpq.FilterParameters.AddNewParameter "5",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Filename Contains…"
fpq.FilterParameters.AddNewParameter "7",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Web Link Contains…"
fpq.FilterParameters.AddNewParameter "10",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Custom Data Contains…"
fpq.FilterParameters.AddNewParameter "21",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Abstract Contains…"
fpq.FilterParameters.AddNewParameter "16",""
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Keywords Contain…"
fpq.FilterParameters.AddNewParameter "17",""

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
fpq.FilterParameters.AddNewParameter "18", ""

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
fpq.FilterParameters.AddNewParameter "120", null				'Today
fpq.FilterParameters.AddNewParameter "130", null				'This Week
fpq.FilterParameters.AddNewParameter "140", null				'This Month
fpq.FilterParameters.AddNewParameter "170", null				'Yesterday
fpq.FilterParameters.AddNewParameter "180", null				'Last Week
fpq.FilterParameters.AddNewParameter "190", null				'Last Month
fpq.FilterParameters.AddNewParameter "150", "[START_DATE]"		'On or After this Date...
fpq.FilterParameters.AddNewParameter "160", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "150", "[START_DATE]"		'Between these dates...
fpq.FilterParameters.AddNewParameter "160", "[END_DATE]"		'..cont Between these dates
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Ending…"
fpq.FilterParameters.AddNewParameter "121", null				'Today
fpq.FilterParameters.AddNewParameter "131", null				'This Week
fpq.FilterParameters.AddNewParameter "141", null				'This Month
fpq.FilterParameters.AddNewParameter "171", null				'Yesterday
fpq.FilterParameters.AddNewParameter "181", null				'Last Week
fpq.FilterParameters.AddNewParameter "191", null				'Last Month
fpq.FilterParameters.AddNewParameter "151", "[START_DATE]"		'On or After this Date...
fpq.FilterParameters.AddNewParameter "161", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "151", "[START_DATE]"		'Between these dates...
fpq.FilterParameters.AddNewParameter "161", "[END_DATE]"		'..cont Between these dates

'Set the DataSet type
fp.Type_ID = dataset_types.DATE_TIME

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
'Add New Pane
Set fp = fs.AddNewPane()
		
'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of Publish Date"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "First Published to Staging…"
fpq.FilterParameters.AddNewParameter "124", null				'Today
fpq.FilterParameters.AddNewParameter "134", null				'This Week
fpq.FilterParameters.AddNewParameter "144", null				'This Month
fpq.FilterParameters.AddNewParameter "174", null				'Yesterday
fpq.FilterParameters.AddNewParameter "184", null				'Last Week
fpq.FilterParameters.AddNewParameter "194", null				'Last Month
fpq.FilterParameters.AddNewParameter "154", "[START_DATE]"		'On or After this Date...
fpq.FilterParameters.AddNewParameter "164", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "154", "[START_DATE]"		'Between these dates...
fpq.FilterParameters.AddNewParameter "164", "[END_DATE]"		'..cont Between these dates
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Last Modified on Staging…"
fpq.FilterParameters.AddNewParameter "125", null				'Today
fpq.FilterParameters.AddNewParameter "135", null				'This Week
fpq.FilterParameters.AddNewParameter "145", null				'This Month
fpq.FilterParameters.AddNewParameter "175", null				'Yesterday
fpq.FilterParameters.AddNewParameter "185", null				'Last Week
fpq.FilterParameters.AddNewParameter "195", null				'Last Month
fpq.FilterParameters.AddNewParameter "155", "[START_DATE]"		'On or After this Date...
fpq.FilterParameters.AddNewParameter "165", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "155", "[START_DATE]"		'Between these dates...
fpq.FilterParameters.AddNewParameter "165", "[END_DATE]"		'..cont Between these dates
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Published to Live…"
fpq.FilterParameters.AddNewParameter "126", null				'Today
fpq.FilterParameters.AddNewParameter "136", null				'This Week
fpq.FilterParameters.AddNewParameter "146", null				'This Month
fpq.FilterParameters.AddNewParameter "176", null				'Yesterday
fpq.FilterParameters.AddNewParameter "186", null				'Last Week
fpq.FilterParameters.AddNewParameter "196", null				'Last Month
fpq.FilterParameters.AddNewParameter "156", "[START_DATE]"		'On or After this Date...
fpq.FilterParameters.AddNewParameter "166", "[END_DATE]"		'On or Before this Date...
fpq.FilterParameters.AddNewParameter "156", "[START_DATE]"		'Between these dates...
fpq.FilterParameters.AddNewParameter "166", "[END_DATE]"		'..cont Between these dates

'Set the DataSet type
fp.Type_ID = dataset_types.DATE_TIME

'. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
'Add New Pane
Set fp = fs.AddNewPane()

'Add Questions to the pane
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Regardless of User Activity"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Published By…"
Set fpq = fp.QuestionSet.AddNewQuestion()
fpq.Text = "Modified By…"

'Set the DataSet type
fp.Type_ID = dataset_types.DB_LOOKUP
'Requires a unique ID column followed by the text/number to display as an option declared before the sql_Str
fp.ChoiceSet.SQL_ID = "ID"
fp.ChoiceSet.SQL_Text = "UserName"
fp.ChoiceSet.SQL_String = "sp_security_list_users"

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
	<form id="theForm" name="theForm" action="website_filter_details.asp" target="DetailFrame" method="get" style="padding: 0; margin: 0;">
	<%
		fs.Display()
	%>
	<input type="hidden" name="filterHiddenParams" id="filterHiddenParams" value="0, <%=Session.Value("websiteID")%>;">
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