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

categoryID = checkQueryID(Request("cid"), 0)

boolIsNew = false
if categoryID = 0 then
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
		function preloadImgs()
		{
			if (document.images)
			{		
				descriptionTabImgOn = new Image(100, 12);
				descriptionTabImgOff = new Image(100, 12);
				securityTabImgOn = new Image(100, 12);
				securityTabImgOff = new Image(100, 12);

				descriptionTabImgOn.src = "../images/tab_description_on.gif";
				descriptionTabImgOff.src = "../images/tab_description_off.gif";
				securityTabImgOn.src = "../images/tab_security_on.gif";
				securityTabImgOff.src = "../images/tab_security_off.gif";
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
				
				case "securityTab":
					parent.frames['body'].workspace_security.style.display = "";
					document.images['securityTab'].src = securityTabImgOn.src;
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
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			document.images['descriptionTab'].src = descriptionTabImgOff.src;
			document.images['securityTab'].src = securityTabImgOff.src;
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="preloadImgs(); initTabs('descriptionTab')">
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr bgcolor=333333><td colspan=2><img src="../images/editscreen_label_category_<%if boolIsNew then Response.Write "new" else Response.Write "edit" end if%>.gif" height=25 width=125 border=0></td></tr>
	<tr>
		<td colspan=2>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr bgcolor=333333>
					<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					<td><a href="javascript: void(0); clickMenu('descriptionTab')"><img name="descriptionTab" id="descriptionTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product category details"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('securityTab')"><img name="securityTab" id="securityTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product category security settings"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=13 border=0></td></tr>
</table>

</body>
</html>