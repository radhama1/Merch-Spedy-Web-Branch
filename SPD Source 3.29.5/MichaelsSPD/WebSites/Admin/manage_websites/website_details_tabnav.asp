<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim selectedTab

selectedTab = Trim(Request("tab"))
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("WEBSITE_SELECTEDTAB")) and Trim(Session.Value("WEBSITE_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("WEBSITE_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

Session.Value("WEBSITE_SELECTEDTAB") = selectedTab

function writeTabImgSuffix(tabOrdinal)
	Dim strImgSuffix
	strImgSuffix = "_off"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(tabOrdinal) and not IsNull(tabOrdinal) and tabOrdinal <> "" then
		if CInt(selectedTab) = CInt(tabOrdinal) then
			strImgSuffix = "_on"
		end if
	end if

	writeTabImgSuffix = strImgSuffix
end function

function writeLabelGraphic()
	Dim strReturnVal
	strReturnVal = "spacer.gif"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(selectedTab) and not IsNull(selectedTab) and selectedTab <> "" then

		Select Case selectedTab
			Case 0
				strReturnVal = "label_websites.gif"
			Case 1
				strReturnVal = "label_website_settings.gif"
		End Select

	end if

	writeLabelGraphic = strReturnVal
end function
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		BODY
		{
			cursor: default;
		}
		.navTab
		{
			cursor: hand;
		}
	//-->
	</style>
	<script language=javascript>
	<!--
		function switchTab(tabID)
		{
			parent.frames['DetailFrameWrapper'].document.location = "website_details_frm.asp?tab=" + tabID;
			parent.frames['DetailsTabFrame'].document.location = "website_details_tabnav.asp?tab=" + tabID;
		}
	//-->
	</script>
</head>
<body bgcolor="333333" text=ffffff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr bgcolor=333333><td><img src="./images/spacer.gif" height=13 width=1 border=0></td></tr>
	<tr>
		<td>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr bgcolor=333333>
					<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
					<td><a href="javascript:switchTab('0'); void(0);"><img src="./images/tab_websitecontent<%=writeTabImgSuffix(0)%>.gif" height=12 width=100 border=0 alt="" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
					<!--
					<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript:switchTab('1'); void(0);"><img src="./images/tab_settings<%=writeTabImgSuffix(1)%>.gif" height=12 width=100 border=0 alt="" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
					-->
					<td width=100%><img src="./images/spacer.gif" height=1 width=4 border=0></td>
					<td align=right><img src="./images/<%=writeLabelGraphic%>" height=12 width=200 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

</body>
</html>