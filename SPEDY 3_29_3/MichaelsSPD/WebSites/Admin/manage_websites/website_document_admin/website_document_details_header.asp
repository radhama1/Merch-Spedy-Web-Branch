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

Dim elementID

elementID = Request("tid")
if IsNumeric(elementID) then
	elementID = CInt(elementID)
else
	elementID = 0
end if
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
	<!--
		window.defaultStatus = "Web Document Display Settings"

		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function preloadImgs()
		{
			if (document.images)
			{		
				descriptionTabImgOn = new Image(100, 12);
				descriptionTabImgOff = new Image(100, 12);
				securityTabImgOn = new Image(100, 12);
				securityTabImgOff = new Image(100, 12);
				scheduleTabImgOn = new Image(100, 12);
				scheduleTabImgOff = new Image(100, 12);

				descriptionTabImgOn.src = "../images/tab_settings_on.gif";
				descriptionTabImgOff.src = "../images/tab_settings_off.gif";
				securityTabImgOn.src = "../images/tab_security_on.gif";
				securityTabImgOff.src = "../images/tab_security_off.gif";
				scheduleTabImgOn.src = "../images/tab_schedule_on.gif";
				scheduleTabImgOff.src = "../images/tab_schedule_off.gif";
			}
		}

		function initTabs(thisTabName)
		{
			parent.frames['body'].clickMenu(thisTabName);
			clearMenus();

			switch (thisTabName)
			{
				case "descriptionTab":
					parent.frames['body'].workspace_description.style.display = "";
					document.images['descriptionTab'].src = descriptionTabImgOn.src;
					break;
				
				case "securityTab":
					parent.frames['body'].workspace_security.style.display = "";
					document.images['securityTab'].src = securityTabImgOn.src;
					break;
				
				case "scheduleTab":
					parent.frames['body'].workspace_schedule.style.display = "";
					document.images['scheduleTab'].src = scheduleTabImgOn.src;
					break;
			}
		}
	
		function clickMenu(tabName)
		{
			parent.frames['body'].clickMenu(tabName);
			clearMenus();

			switch (tabName)
			{
				case "descriptionTab":
					document.images['descriptionTab'].src = descriptionTabImgOn.src;
					break;
				
				case "securityTab":
					document.images['securityTab'].src = securityTabImgOn.src;
					break;
				
				case "scheduleTab":
					document.images['scheduleTab'].src = scheduleTabImgOn.src;
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			document.images['descriptionTab'].src = descriptionTabImgOff.src;
			document.images['securityTab'].src = securityTabImgOff.src;
			document.images['scheduleTab'].src = scheduleTabImgOff.src;
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="preloadImgs(); initTabs('descriptionTab')">
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr bgcolor=333333><td colspan=2><img src="../images/editscreen_label_webdocumentsettings.gif" border=0></td></tr>
	<tr>
		<td colspan=2>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr bgcolor=333333>
					<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					<td><a href="javascript: void(0); clickMenu('descriptionTab')"><img name="descriptionTab" id="descriptionTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage user profile"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('securityTab')"><img name="securityTab" id="securityTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage user security settings"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('scheduleTab')"><img name="scheduleTab" id="scheduleTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage user schedule"></a></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=13 border=0></td></tr>
</table>

</body>
</html>