<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim boolIsNew
Dim groupID

groupID = Request("gid")
if IsNumeric(groupID) then
	groupID = CInt(groupID)
else
	groupID = 0
end if

boolIsNew = false
if groupID = 0 then
	boolIsNew = true
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
		window.defaultStatus = "<%if boolIsNew then%>New<%else%>Edit<%end if%> User"

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
				userTabImgOn = new Image(100, 12);
				userTabImgOff = new Image(100, 12);

				descriptionTabImgOn.src = "../images/tab_profile_on.gif";
				descriptionTabImgOff.src = "../images/tab_profile_off.gif";
				securityTabImgOn.src = "../images/tab_security_on.gif";
				securityTabImgOff.src = "../images/tab_security_off.gif";
				scheduleTabImgOn.src = "../images/tab_schedule_on.gif";
				scheduleTabImgOff.src = "../images/tab_schedule_off.gif";
				userTabImgOn.src = "../images/tab_user_on.gif";
				userTabImgOff.src = "../images/tab_user_off.gif";
			}
		}

		function initTabs(thisTabName)
		{
			clearMenus();
		//	alert(parent.frames['body'].name);
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
				
				case "userTab":
					parent.frames['body'].workspace_users.style.display = "";
					document.images['userTab'].src = userTabImgOn.src;
					break;
				
			//	case "scheduleTab":
			//		parent.frames['body'].workspace_schedule.style.display = "";
			//		document.images['scheduleTab'].src = scheduleTabImgOn.src;
			//		break;
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
				
				case "userTab":
					document.images['userTab'].src = userTabImgOn.src;
					break;
				
			//	case "scheduleTab":
			//		document.images['scheduleTab'].src = scheduleTabImgOn.src;
			//		break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			document.images['descriptionTab'].src = descriptionTabImgOff.src;
			document.images['securityTab'].src = securityTabImgOff.src;
			document.images['userTab'].src = userTabImgOff.src;
		//	document.images['scheduleTab'].src = scheduleTabImgOff.src;
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="preloadImgs(); initTabs('descriptionTab')">
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr bgcolor=333333><td colspan=2><img src="../images/editscreen_label_<%if boolIsNew then Response.Write "new" else Response.Write "edit" end if%>group.gif" height=25 width=125 border=0></td></tr>
	<tr>
		<td colspan=2>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr bgcolor=333333>
					<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					<td><a href="javascript: void(0); clickMenu('descriptionTab')"><img name="descriptionTab" id="descriptionTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage user profile"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('securityTab')"><img name="securityTab" id="securityTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage user security settings"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('userTab')"><img name="userTab" id="userTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage users associated with this group."></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<!--
					<td><a href="javascript: void(0); clickMenu('scheduleTab')"><img name="scheduleTab" id="scheduleTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage user schedule"></a></td>
					-->
					<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=13 border=0></td></tr>
</table>

</body>
</html>