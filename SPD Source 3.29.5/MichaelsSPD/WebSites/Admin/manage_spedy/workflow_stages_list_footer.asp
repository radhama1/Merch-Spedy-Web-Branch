<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design, Nova Libra Inc.
'==============================================================================
Option Explicit
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441
Dim Workflow_ID
Workflow_ID = Request("id")
%>
<html>
<head>
	<title></title>
	<script language="javascript" type="text/javascript">
	<!--
		
		function openNewExceptionWindow()
		{
			var url = './../transfersession.asp?url=' + escape("workflow_detail.aspx?id=" + "&Workflowid=<%=Workflow_ID%>");
			//url = "./../workflow_detail.aspx?id=" + "&Workflowid=<%=Workflow_ID%>";
			var newQuestionWin = window.open(url, "_blank", "width=1024,height=750,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
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
		<td><a href="javascript: openNewExceptionWindow(); void(0);"><img src="./images/newstage.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
	</tr>
</table>
</div>

</body>
</html>
