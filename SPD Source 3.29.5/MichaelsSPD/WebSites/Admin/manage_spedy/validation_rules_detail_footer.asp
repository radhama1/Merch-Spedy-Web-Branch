<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim Record_ID
Record_ID = Request("tid")
if not IsNumeric(Record_ID) or Len(Trim(Record_ID)) = 0 then
	if IsNumeric(Session.Value("recordID")) and Trim(Session.Value("recordID")) <> "" then
		Record_ID = Session.Value("recordID")
	else
		Record_ID = 0
	end if
end if
%>
<html>
<head>
	<title></title>
	<script language="javascript" type="text/javascript" src="./../app_include/prototype.js"></script>
	<script language=javascript>
	<!--
		var selectedRuleID = 0;
		
		function openNewRuleWindow()
		{
			var newFieldWin = window.open("./validation_admin/rule_details_frm.asp?tid=<%=Record_ID%>&rid=" + selectedRuleID, "newRuleWindow_" + selectedRuleID, "width=800,height=600,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newFieldWin.focus();
		}
		
		function searchRules()
		{
		    var searchText = $('searchRulesText').value;
		    var targetLocation = "validation_rules_detail.asp?tid=<%=Record_ID%>" + "&search=" + escape(searchText);
		    parent.frames["DetailFrame"].document.location = targetLocation;		
		}   
		
		function clearSearch()
		{
		    $('searchRulesText').value = '';
		    searchRules();
		}
		
	//-->
	</script>
</head>
<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div id="CategoryOptionsLyr" name="CategoryOptionsLyr">
<table cellpadding=0 cellspacing=0 border=0>
	<tr><td colspan="2"><img src="./images/spacer.gif" height="2" width="1"></td></tr>
	<tr>
		<td style="white-space: nowrap" nowrap="nowrap"><a href="javascript: openNewRuleWindow(); void(0);"><img src="./images/addrule.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
		<td style="white-space: nowrap" nowrap="nowrap"><img src="./images/spacer.gif" height=1 width=20></td>
		<td valign="middle" style="white-space: nowrap" nowrap="nowrap">
		    <input id="searchRulesText" value="" style="width: 100px; height: 20px; line-height: 14px; font-family: Arial; font-size: 10px" maxlength="25" /><input type="button" id="btnSearchRules" value="Search" style="height: 20px; line-height: 14px; font-family: Arial; font-size: 10px" onclick="searchRules();" /><input type="button" id="btnClearSearch" value="Clear" style="height: 20px; line-height: 14px; font-family: Arial; font-size: 10px" onclick="clearSearch();" />
		</td>
		<td width="*">&nbsp;</td>
	</tr>
</table>
</div>

</body>
</html>
