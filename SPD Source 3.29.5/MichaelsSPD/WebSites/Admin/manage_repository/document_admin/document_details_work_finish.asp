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

Dim boolIsNewDocument
Dim topicID

topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

boolIsNewDocument = false
if topicID = 0 then
	boolIsNewDocument = true
end if
%>
<html>
<head>
	<title>Unlock Document...</title>
</head>
<body bgcolor="CCCCCC" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
/*	
	function doLockPrompt()
	{
		<%if not boolIsNewDocument then%>
		var msg = "This document is currently locked for your exclusive\nuse.  Would you like to unlock this document?  ";
		msg = msg + "\n\nA document is automatically locked for exclusive use\nwhen it is edited.  ";
		msg = msg + "Other users cannot edit this\ndocument while it remains locked.";
		msg = msg + "\n";
		msg = msg + "\nClick 'OK' to UNLOCK this document";
		msg = msg + "\nClick 'Cancel' to leave document locked";

		if (confirm(msg))
		{
			parent.frames["calcFrame"].document.location = "document_details_toggle_lock.asp?tid=<%=topicID%>&lock=0";
		}
		<%end if%>
	}

	doLockPrompt();
*/
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
