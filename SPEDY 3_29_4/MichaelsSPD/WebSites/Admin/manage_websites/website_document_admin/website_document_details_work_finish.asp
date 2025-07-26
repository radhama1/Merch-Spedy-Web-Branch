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
	<title>Finish...</title>
	<style type="text/css">
		.bodyText
		{
			font-family: Arial, Helvetica;
			font-size: 14px;
			line-height: 14px;
			color: #666;
		}
	</style>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div class="bodyText" style="margin: 20px;">
Please Wait...
</div>


<script language="javascript">
	window.setTimeout("doFinish()", 10);

	function doFinish()
	{
		var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
		//If the user hasnt left the frameset that opened this window, then refresh the details screen, otherwise dont worry bout it...
		if (typeof(myFrameSetRef == 'object'))
		{
			myFrameSetRef.document.location.reload();
		}

		//we're all done, so leave...
		parent.window.close();
	}
</script>

</body>
</html>
