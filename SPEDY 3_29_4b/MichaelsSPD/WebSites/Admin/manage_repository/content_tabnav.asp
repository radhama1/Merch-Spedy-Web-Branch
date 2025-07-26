<%@ LANGUAGE=VBSCRIPT%> 
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim Security
Set Security = New cls_Security
Security.Initialize CLng(Session.Value("UserID")), "ADMIN.CONTENT", 0
'Security.saveXMLToFile "f:\International\DocMan_NewAdmin\Security_Out.xml"

Dim selectedTab

selectedTab = Trim(Request("tab"))
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("CONTENT_SELECTEDTAB")) and Trim(Session.Value("CONTENT_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("CONTENT_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

Session.Value("CONTENT_SELECTEDTAB") = selectedTab

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
				strReturnVal = "label_repository.gif"
			Case 1
				strReturnVal = "label_content_settings.gif"
			Case 2
				strReturnVal = "label_content_languages.gif"
		End Select

	end if

	writeLabelGraphic = strReturnVal
end function
%>
<html>
<head>
	<title></title>
	<style type="text/css">
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		.navTab
		{
			cursor: hand;
		}
	</style>
</head>
<body bgcolor="333333" text=ffffff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr bgcolor=333333><td><img src="./images/spacer.gif" height=13 width=1 border=0></td></tr>
	<tr>
		<td>
			<div id="navigation" name="navigation">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr bgcolor=333333>
						<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
						<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.REPOSITORY", "ADMINACCESS.MODULEACCESS") then%>
						<td><a href="content_default.asp?tab=0" target="MainDisplayFrame"><img name="navTab" class="navTab" id="contentTab" src="./images/tab_repository<%=writeTabImgSuffix(0)%>.gif" height=12 width=100 border=0 alt="content repository: explore all content and digital assets from this view." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						<%end if%>
						<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.LANGUAGES", "ADMINACCESS.MODULEACCESS") then%>
						<td><a href="content_default.asp?tab=2" target="MainDisplayFrame"><img name="navTab" class="navTab" id="languageTab" src="./images/tab_languages<%=writeTabImgSuffix(2)%>.gif" height=12 width=100 border=0 alt="content languages: manage repository-wide language variations of applicable documents and digital assets." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						<%end if%>
						<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.CUSTOMDATA", "ADMINACCESS.MODULEACCESS") then%>
						<td><a href="content_default.asp?tab=1" target="MainDisplayFrame"><img name="navTab" class="navTab" id="settingsTab" src="./images/tab_customdata<%=writeTabImgSuffix(1)%>.gif" height=12 width=100 border=0 alt="content settings: manage repository-wide content settings." onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						<%end if%>
						<td width=100%><img src="./images/spacer.gif" height=1 width=20 border=0></td>
						<td align=right><img src="./images/<%=writeLabelGraphic%>" height=12 width=200 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
</table>

</body>
</html>