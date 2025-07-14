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

Dim Tax_ID
Tax_ID = Request("tid")
if not IsNumeric(Tax_ID) or Len(Trim(Tax_ID)) = 0 then
	if IsNumeric(Session.Value("taxID")) and Trim(Session.Value("taxID")) <> "" then
		Tax_ID = Session.Value("taxID")
	else
		Tax_ID = 0
	end if
end if
%>
<html>
<head>
	<title></title>
	<script language=javascript>
	<!--
		var selectedPQuestionID = 0;
		var selectedQuestionID = 0;
		
		function openNewQuestionWindow()
		{
			var newQuestionWin = window.open("./tax_wizard_admin/question_details_frm.asp?tid=<%=Tax_ID%>&pqid=" + selectedPQuestionID, "newQuestionWindow_" + selectedQuestionID, "width=500,height=400,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newQuestionWin.focus();
		}
		
	//-->
	</script>
</head>
<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div id="CategoryOptionsLyr" name="CategoryOptionsLyr">
<table cellpadding=0 cellspacing=0 border=0>
	<tr><td colspan=2><img src="./images/spacer.gif" height=3 width=1></td></tr>
	<tr>
		<td><a href="javascript: openNewQuestionWindow(); void(0);"><img src="./images/newquestion.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
	</tr>
</table>
</div>

</body>
</html>
