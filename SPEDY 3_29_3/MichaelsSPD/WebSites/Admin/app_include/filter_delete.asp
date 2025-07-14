<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
Server.ScriptTimeout = 10800
%>
<!--#include file="./../app_include/_globalInclude.asp"--> 
<%
Dim Filter_ID, utils

Set utils = New cls_UtilityLibrary

'Get the Filter ID
Filter_ID = checkQueryID(Request("Filter_ID"), 0)

%>
<html>
	<head></head>
	<body>
		<div style="position: absolute; z-index:100; width:100%; height:100%; top:0px; left:0px; clip: auto; overflow: hidden; border-top: 1px solid #333; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#FFE8E8E8', EndColorStr='#33FFFFFF')" id="waitLyr" name="waitLyr">
			<div id="waitText" name="waitText" style="position: absolute; top:10px; left:10px; font-family:Arial, Helvetica;font-size:12px; color:#666666;">
				Performing Requested Action<br>
				Please Wait…
			</div>
			<img src="./../app_images/spacer.gif" border=0 style="width:100%; height:1000px;" galleryimg="no">
		</div>
	</body>
<%Response.Flush()%>

<%

If Filter_ID > 0 Then

	utils.RunSQL "sp_Filter_Delete '0" & Filter_ID & "'"
	
End If

Set utils = Nothing
%>
<script language=javascript>
	if (window.opener && !window.opener.closed) {
		window.opener.Load_Saved_Search(0);
	  }
	self.close();
</script>
</html>