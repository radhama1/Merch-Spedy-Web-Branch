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

Dim boolIsNewWebsite
Dim websiteID

websiteID = Request("wid")
if IsNumeric(websiteID) then
	websiteID = CInt(websiteID)
else
	websiteID = 0
end if

boolIsNewWebsite = false
if websiteID = 0 then
	boolIsNewWebsite = true
end if
%>
<html>
<head>
	<title>Finish...</title>
</head>
<body bgcolor="CCCCCC" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	//var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	var myFrameSetRef = new Object(parent.window.opener.parent.frames['TreeFrame']);

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
