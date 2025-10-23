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
	<title>Category Save Successful</title>
	<script language="javascript">
	<!--

		var myFrameSetRef = new Object(window.opener.parent.parent.frames['TreeFrameWrapper'].frames['TreeFrame']);
	
		if (typeof(myFrameSetRef == 'object'))
		{
			myFrameSetRef.document.location.reload();
		}
	
		//we're all done, so leave...
		self.close();

	//-->
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

</body>
</html>