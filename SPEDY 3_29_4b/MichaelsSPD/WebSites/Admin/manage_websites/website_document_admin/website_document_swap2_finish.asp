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
	<title></title>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	var myFrameSetRef = new Object(parent.parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	
	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
	//	myFrameSetRef.document.location.reload();
		myFrameSetRef.document.location = "./../website_details.asp?open=<%=Request("open")%>";
	}
	
	//we're all done, so leave...
	parent.parent.window.close();
</script>

</body>
</html>
