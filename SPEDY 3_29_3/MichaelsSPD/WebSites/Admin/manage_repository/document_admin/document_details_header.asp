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
Dim categoryID, topicID

categoryID = Request("cid")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

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
	<title>Move Item</title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
	<!--
		window.defaultStatus = "Edit Document"

		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function preloadImgs()
		{
			if (document.images)
			{		
				contentTabImgOn = new Image(100, 12);
				contentTabImgOff = new Image(100, 12);
			//	securityTabImgOn = new Image(100, 12);
			//	securityTabImgOff = new Image(100, 12);
				customdataTabImgOn = new Image(100, 12);
				customdataTabImgOff = new Image(100, 12);
				scheduleTabImgOn = new Image(100, 12);
				scheduleTabImgOff = new Image(100, 12);

				contentTabImgOn.src = "../images/tab_content_on.gif";
				contentTabImgOff.src = "../images/tab_content_off.gif";
			//	securityTabImgOn.src = "../images/tab_security_on.gif";
			//	securityTabImgOff.src = "../images/tab_security_off.gif";
				customdataTabImgOn.src = "../images/tab_customdata_on.gif";
				customdataTabImgOff.src = "../images/tab_customdata_off.gif";
				scheduleTabImgOn.src = "../images/tab_schedule_on.gif";
				scheduleTabImgOff.src = "../images/tab_schedule_off.gif";
			}
		}

		function initTabs(thisTabName)
		{
			clearMenus();
		//	alert(parent.frames['body'].name);
			switch (thisTabName)
			{
				case "contentTab":
					parent.frames['body'].workspace_content.style.display = "";
					document.images['contentTab'].src = contentTabImgOn.src;
					break;
				
			//	case "securityTab":
			//		parent.frames['body'].workspace_security.style.display = "";
			//		document.images['securityTab'].src = securityTabImgOn.src;
			//		break;
				
				case "customdataTab":
					parent.frames['body'].workspace_customdata.style.display = "";
					document.images['customdataTab'].src = customdataTabImgOn.src;
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
				case "contentTab":
					document.images['contentTab'].src = contentTabImgOn.src;
					break;
				
			//	case "securityTab":
			//		document.images['securityTab'].src = securityTabImgOn.src;
			//		break;
				
				case "customdataTab":
					document.images['customdataTab'].src = customdataTabImgOn.src;
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
			document.images['contentTab'].src = contentTabImgOff.src;
		//	document.images['securityTab'].src = securityTabImgOff.src;
			document.images['customdataTab'].src = customdataTabImgOff.src;
			document.images['scheduleTab'].src = scheduleTabImgOff.src;
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="preloadImgs(); initTabs('contentTab');">
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr bgcolor=333333><td colspan=2><img src="../images/document_details_<%if boolIsNewDocument then Response.Write "new" else Response.Write "edit" end if%>.gif" height=25 width=125 border=0></td></tr>
	<tr>
		<td colspan=2>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr bgcolor=333333>
					<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					<td><a href="javascript: void(0); clickMenu('contentTab')"><img name="contentTab" id="contentTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage document content"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<!--
					<td><a href="javascript: void(0); clickMenu('securityTab')"><img name="securityTab" id="securityTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage document security settings"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					-->
					<td><a href="javascript: void(0); clickMenu('customdataTab')"><img name="customdataTab" id="customdataTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage document security settings"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('scheduleTab')"><img name="scheduleTab" id="scheduleTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage document schedule"></a></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=13 border=0></td></tr>
</table>

</body>
</html>