<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim selectedTab

selectedTab = Trim(Request("tab"))
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("SPEDY_SELECTEDTAB")) and Trim(Session.Value("SPEDY_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("SPEDY_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

Session.Value("SPEDY_SELECTEDTAB") = selectedTab

function writeTabImgSuffix(tabOrdinal)
	Dim strImgSuffix
	strImgSuffix = "_off"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(tabOrdinal) and not IsNull(tabOrdinal) and tabOrdinal <> "" then
		if CInt(selectedTab) = CInt(tabOrdinal) then
			strImgSuffix = "_on"
		end if
	end if

	writeTabImgSuffix = strImgSuffix
end function

function writeLabelGraphic()
	Dim strReturnVal
	strReturnVal = "spacer.gif"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(selectedTab) and not IsNull(selectedTab) and selectedTab <> "" then

		Select Case selectedTab
			Case 0
				strReturnVal = "label_tax_wizard.gif"
			Case 1
			    strReturnVal = "label_workflow_exception.gif"
			Case 2
			    strReturnVal = "label_custom_fields.gif"
			Case 3
			    strReturnVal = "label_custom_validation.gif"
			Case 4
			    strReturnVal = "label_settings.gif"
		End Select

	end if

	writeLabelGraphic = strReturnVal
end function
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		BODY
		{
			cursor: default;
		}
		.navTab
		{
			cursor: hand;
		}
	//-->
	</style>
</head>
<body bgcolor="333333" text=ffffff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr bgcolor=333333><td><img src="./images/spacer.gif" height=13 width=1 border=0></td></tr>
	<tr>
		<td>
			<div id="navigation" name="navigation">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr bgcolor=333333>
						<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
						
						<td><a href="spedy_default.asp?tab=0" target="MainDisplayFrame"><img name="navTab" class="navTab" id="taxWizardTab" src="./images/tab_spedy_taxwizard<%=writeTabImgSuffix(0)%>.gif" height="12" width="100" border="0" alt="tax wizard management: explore all tax uda values and questions from this view." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						
						<td><a href="spedy_default.asp?tab=1" target="MainDisplayFrame"><img name="navTab" class="navTab" id="workflowExceptionTab" src="./images/tab_spedy_workflowexc<%=writeTabImgSuffix(1)%>.gif" height="12" width="100" border="0" alt="workflow exception management: explore all workflow exceptions from this view." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						
						<td><a href="spedy_default.asp?tab=2" target="MainDisplayFrame"><img name="navTab" class="navTab" id="customFieldsTab" src="./images/tab_spedy_custfields<%=writeTabImgSuffix(2)%>.gif" height="12" width="100" border="0" alt="custom field management: explore all custom fields from this view." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						
						<td><a href="spedy_default.asp?tab=3" target="MainDisplayFrame"><img name="navTab" class="navTab" id="validationTab" src="./images/tab_spedy_validation<%=writeTabImgSuffix(3)%>.gif" height="12" width="100" border="0" alt="custom validation management: explore all custom validations from this view." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						
						<td><a href="spedy_default.asp?tab=4" target="MainDisplayFrame"><img name="navTab" class="navTab" id="settingsTab" src="./images/tab_spedy_settings<%=writeTabImgSuffix(4)%>.gif" height="12" width="100" border="0" alt="spedy validation settings: explore all settings from this view." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						
						<td width=100%><img src="./images/spacer.gif" height=1 width=20 border=0></td>
						<td align=right><img src="./images/<%=writeLabelGraphic%>" height=12 width=200 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
</table>

</body>
</html>