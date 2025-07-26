<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Jeff Littlefield
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
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
		window.defaultStatus = "Manage Primary Approval List"

		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function preloadImgs()
		{
			if (document.images)
			{		
				descriptionTabImgOn = new Image(100, 12);
				descriptionTabImgOff = new Image(100, 12);

				descriptionTabImgOn.src = "../images/tab_department_on.gif";
				descriptionTabImgOff.src = "../images/tab_department_off.gif";
			}
		}

		function initTabs(thisTabName)
		{
			clearMenus();
			switch (thisTabName)
			{
				case "descriptionTab":
					parent.frames['body'].workspace_description.style.display = "";
					document.images['descriptionTab'].src = descriptionTabImgOn.src;
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
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			document.images['descriptionTab'].src = descriptionTabImgOff.src;
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 onLoad="preloadImgs(); initTabs('descriptionTab')">
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr bgcolor=333333><td colspan=2><img src="../images/editscreen_label_departments.gif" height=25 width=170 border=0></td></tr>
	<tr>
		<td colspan=2>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr bgcolor=333333>
					<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					<td><a href="javascript: void(0); clickMenu('descriptionTab')"><img name="descriptionTab" id="descriptionTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage department list"></a></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=13 border=0></td></tr>
</table>

</body>
</html>