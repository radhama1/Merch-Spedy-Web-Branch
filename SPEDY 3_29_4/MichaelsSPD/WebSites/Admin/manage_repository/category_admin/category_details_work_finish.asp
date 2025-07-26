<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%

Dim boolIsNew
Dim categoryID

categoryID = Request("cid")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

boolIsNew = false
if categoryID = 0 then
	boolIsNew = true
end if
%>
<html>
<head>
	<title>Finish...</title>
</head>
<body bgcolor="CCCCCC" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<script language="javascript">
<!--

	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['TreeFrameWrapper'].frames['TreeFrame']);

	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location.reload();
	}

	//we're all done, so leave...
	parent.window.close();

//-->
</script>

</body>
</html>
