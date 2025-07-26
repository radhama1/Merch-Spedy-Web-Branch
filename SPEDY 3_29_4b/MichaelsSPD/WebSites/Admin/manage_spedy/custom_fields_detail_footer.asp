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
	<script language=javascript>
	<!--
		var selectedFieldID = 0;
		
		function openNewFieldWindow()
		{
			var newFieldWin = window.open("./custom_field_admin/field_details_frm.asp?tid=<%=Record_ID%>&fid=" + selectedFieldID, "newFieldWindow_" + selectedFieldID, "width=500,height=400,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newFieldWin.focus();
		}
		
	//-->
	</script>
</head>
<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div id="CategoryOptionsLyr" name="CategoryOptionsLyr">
<table cellpadding=0 cellspacing=0 border=0>
	<tr><td colspan=2><img src="./images/spacer.gif" height=3 width=1></td></tr>
	<tr>
		<td><a href="javascript: openNewFieldWindow(); void(0);"><img src="./images/newfield.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
	</tr>
</table>
</div>

</body>
</html>
