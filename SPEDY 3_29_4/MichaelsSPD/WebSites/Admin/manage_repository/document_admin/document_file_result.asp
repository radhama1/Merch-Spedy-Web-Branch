<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441
%>
<html>
<head>
	<title>File Upload Successful</title>
	<script language="javascript">
	<!--
		function returnNewFileName()
		{
			if (typeof(window.opener.document.theForm.Type1_FileName == 'object'))
			{
				window.opener.document.theForm.Type1_FileName.value = "<%=Session.Value("FileName")%>";
			}
			if (typeof(window.opener.document.theForm.Type1_FileID == 'object'))
			{
				window.opener.document.theForm.Type1_FileID.value = "<%=Session.Value("FileID")%>";
			}
			window.opener.focus();
			window.close();
			return(1);
		}
	//-->
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="returnNewFileName();">

</body>
</html>