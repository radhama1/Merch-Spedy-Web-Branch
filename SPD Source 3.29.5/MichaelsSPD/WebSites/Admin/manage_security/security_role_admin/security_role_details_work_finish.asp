<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<html>
<head>
	<title>Finish...</title>
</head>
<body bgcolor="CCCCCC" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	//from right-click
//	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['WorkspaceFrame'].frames['DetailFrame']);

	//from new
//	var myFrameSetRef = new Object(parent.window.opener.parent.frames['WorkspaceFrame'].frames['DetailFrame']);

	var myFrameSetRef = new Object(parent.window.opener.parent);
	if (myFrameSetRef.frames['WorkspaceFrame'])
	{
		myFrameSetRef = myFrameSetRef.frames['WorkspaceFrame'].frames['GroupDetailFrame']
	}
	else
	{
		myFrameSetRef = myFrameSetRef.parent.frames['WorkspaceFrame'].frames['GroupDetailFrame']
	}
	
	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location.reload();
	}

	//we're all done, so leave...
	parent.window.close();
</script>

</body>
</html>
