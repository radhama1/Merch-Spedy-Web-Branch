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

%>
<!--#include file="./../app_include/getfile_MIMEtype.asp"-->
<!--#include file="./../app_include/getfile_icon_name.asp"-->
<%

Dim objConn, objRec, SQLStr, i, connStr
Dim topicID, Topic_ID, curLangID
Dim Topic_Name
Dim Topic_NavName
Dim Topic_Byline
Dim Topic_Summary
Dim Topic_Abstract, Topic_Keywords
Dim Topic_Type
Dim Type1_FileName
Dim Type1_FileID
Dim Type1_FileSize
Dim Type2_LinkURL
Dim Topic_ContactInfo, Topic_SourceWebsite
Dim UserDefinedField1, UserDefinedField2, UserDefinedField3, UserDefinedField4, UserDefinedField5

Dim strNavTrail

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

topicID = Trim(Request("tid"))
if IsNumeric(topicID) and Trim(topicID) <> "" then
	topicID = CInt(topicID)
else
	topicID = 0
end if

curLangID = Trim(Request("curlang"))
if IsNumeric(curLangID) and Trim(curLangID) <> "" then
	curLangID = CInt(curLangID)
else
	curLangID = -1
end if

if topicID > 0 then
	SQLStr = "sp_repository_topic_content_by_topicID " & topicID & ", " & curLangID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
		Topic_ID					= topicID
		Topic_Name					= SmartValues(objRec("Topic_Name"), "CStr")
		Topic_NavName				= SmartValues(objRec("Topic_Name"), "CStr")
		Topic_Byline				= SmartValues(objRec("Topic_Byline"), "CStr")
		Topic_Summary				= SmartValues(objRec("Topic_Summary"), "CStr")
		Topic_Abstract				= SmartValues(objRec("Topic_Abstract"), "CStr")
		Topic_Keywords				= SmartValues(objRec("Topic_Keywords"), "CStr")
		Topic_Type					= SmartValues(objRec("Topic_Type"), "CStr")
		Type1_FileName				= SmartValues(objRec("Type1_FileName"), "CStr")
		Type1_FileID				= SmartValues(objRec("Type1_FileID"), "CInt")
		Type1_FileSize				= SmartValues(objRec("Type1_FileSize"), "CDbl")
		Type2_LinkURL				= SmartValues(objRec("Type2_LinkURL"), "CStr")
		Topic_ContactInfo			= SmartValues(objRec("Topic_ContactInfo"), "CStr")
		Topic_SourceWebsite		 	= SmartValues(objRec("Topic_SourceWebsite"), "CStr")
		UserDefinedField1			= SmartValues(objRec("UserDefinedField1"), "CStr")
		UserDefinedField2			= SmartValues(objRec("UserDefinedField2"), "CStr")
		UserDefinedField3			= SmartValues(objRec("UserDefinedField3"), "CStr")
		UserDefinedField4			= SmartValues(objRec("UserDefinedField4"), "CStr")
		UserDefinedField5			= SmartValues(objRec("UserDefinedField5"), "CStr")
	end if
	objRec.Close
end if
%>
<html>
<head>
	<title><%=Topic_Name%></title>
	<style type="text/css">
		A {text-decoration: underline; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: none; color: #000000; cursor: hand;}
		A.navLink {text-decoration: none; color: #000000; cursor: hand;}
		A.navLink:HOVER {text-decoration: underline; color: #000000; cursor: hand;}
		A.footerLink {text-decoration: none; color: #000000; cursor: hand;}
		A.footerLink:HOVER {text-decoration: none; color: #000000; cursor: hand;}
		A.calloutText_Link {text-decoration: none; color: #000000; cursor: hand;}
		A.navTrail {text-decoration: none; color: #555; cursor: hand;}
		A.navTrail:HOVER {text-decoration: underline; color: #000000; cursor: hand;}
		A.searchResultTitle {text-decoration: none; color: #000000; cursor: hand;}
		A.searchResultTitle:HOVER {text-decoration: none; color: #000000; cursor: hand;}
		INPUT * {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		SELECT {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		TEXTAREA {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		UL {list-style: square; margin-left: 20px;}

		TD
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 13px;
			color: #000;
		}

		#printerFriendlyFooter
		{
			clip: auto;
			overflow: hidden;
		}

		#contentLyr
		{
			width: 100%;
		}

		.SiteNavigation
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			line-height:14px;
			color: #369;
			font-weight: bold;
			padding-right: 5px;
		}

		.SiteNavigation_Selected
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			line-height:14px;
			color: #000;
			font-weight: bold;
			padding-right: 5px;
		}

		.calloutText_Level1
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			color: #000;
			padding-left: 10px;
		}

		.newsdateText
		{
			padding: 2px;
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			color: #344534;
			text-align: center;
		}

		.headerText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 18px;
			font-weight: bold;
			color: #000;
		}

		.subheaderText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 14px;
			line-height: 18px;
			font-weight: bold;
			color: #000;
		}

		.searchResultTitle
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			text-align: left;
			font-weight: bold;
			color: #000;
		}
		A.searchResultTitle {text-decoration: none; color: #000; cursor: hand;}
		A.searchResultTitle:HOVER {text-decoration: underline; color: #66f; cursor: hand;}

		.bodyText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 13px;
			line-height: 18px;
			color: #000;
		}

		#topmastLinksLeft
		{
			background: #eee; 
			font-size: 10px; 
			padding-bottom: 3px; 
			padding-left: 10px; 
			letter-spacing: 0.2em;
			float: left;
		}
		#topmastLinksRight
		{
			background: #eee; 
			font-size: 10px; 
			text-align: right; 
			padding-bottom: 3px; 
			padding-right: 10px; 
			letter-spacing: 0.2em;
			float: right;
		}
		A.topmastLinks {text-decoration: none; color: #000; cursor: hand;}
		A.topmastLinks:HOVER {text-decoration: underline; color: #00f; cursor: hand;}

		.portalList_containerDiv
		{
			float: left;
			margin-top: 10px;
			margin-left: 5px;
			margin-right: 10px;
			padding: 0px;
			width: 250px;
			height: 150px;
			clip: auto;
			overflow: hidden;
		/*
			padding-right: 10px;
		*/
		}
		.portalList_title
		{
			padding: 3px;
			padding-right: 10px;
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 14px;
			line-height: 18px;
			font-weight: bold;
			color: #000;
		}

		.portalList_body
		{
			border-top: 1px solid #ccc;
			padding: 3px;
			padding-right: 10px;
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			color: #000;
			width: 100%;
			height: 80%;
			clip: auto;
			overflow: hidden;
			white-space: nowrap;
			text-overflow: ellipsis;
		}

		.portalList_links
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			color: #000;
		}

		A.portalList_title {text-decoration: none; color: #000; cursor: hand;}
		A.portalList_title:HOVER {text-decoration: underline; color: #66f; cursor: hand;}
		A.portalList_links {text-decoration: none; color: #000; cursor: hand;}
		A.portalList_links:HOVER {text-decoration: underline; color: #66f; cursor: hand;}

		#contentFileLinkDiv
		{
			border: 1px solid #ccc;
			background: #fff;
			padding: 10px;
			width: 480px;
		}

		#contentWebLinkDiv
		{
			border: 1px solid #ccc;
			background: #fff;
			padding: 10px;
			width: 480px;
		}

		.content_portalList_containerDiv
		{
			border: 1px solid #ccc;
			background: #fff;
			float: left;
			margin-top: 10px;
			margin-left: 5px;
			margin-right: 10px;
			padding: 10px;
			padding-bottom: 0px;
			width: 480px;
		}
		.content_portalList_title
		{
			display: none;
			padding: 3px;
			padding-right: 10px;
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 14px;
			line-height: 18px;
			color: #000;
		}

		.content_portalList_body
		{
			padding: 3px;
			padding-right: 10px;
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			color: #000;
			width: 100%;
		}

		.content_portalList_links
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			color: #000;
		}

		A.content_portalList_body {text-decoration: none; color: #000; cursor: hand;}
		A.content_portalList_body:HOVER {text-decoration: underline; color: #000; cursor: hand;}


		A.content_portalList_title {text-decoration: none; color: #000; cursor: hand;}
		A.content_portalList_title:HOVER {text-decoration: underline; color: #000; cursor: hand;}
		A.content_portalList_links {text-decoration: none; color: #000; cursor: hand;}
		A.content_portalList_links:HOVER {text-decoration: underline; color: #000; cursor: hand;}

		.sitemapText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			line-height: 18px;
			color: #333;
			white-space: nowrap;
		}

		.sitemapLink
		{
			color: #33c;
		}

		.footerText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			line-height: 18px;
			color: #336699;
		}

		#contentDiv
		{
			width: 500px;
		}

		#contentDivDefault
		{
			padding: 0px;
		}

		#contentDocFrame_breadCrumb
		{
		}
		#contentDocFrame_topicName
		{
			margin-top: 10px;
			margin-top: 5px;
		}
		#contentDocFrame_topicByline
		{
			display: none;
		}

		.UnitedEFBContentTitle
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			font-weight: bold;
			margin-bottom: 0px;
		}

		/*
		@media print
		{
			#pageHeader				{display: none;}
			#pageLeftNav			{display: none;}
			#pageSubNav				{display: none;}
			#pageFooter				{display: none;}
			#pageEffectTopSpacer	{display: none;}
			#pageEffectTopTab		{display: none;}
			.pageEffectLeftShadow	{display: none;}
			#contentLyr				{top: 0px;}
			#printerFriendlyFooter	{display: none;}
			#printonly_ContentHeader{display: all;}
			.screenOnly				{display: none;}
			.headerText				{text-align: left; padding: none;}
		}
		@media screen
		{
			#printonly_ContentHeader{display: none;}
		}
		*/
		#printonly_ContentHeader{display: none;}
		@media print
		{
			.screenOnly {display: none;}
		}

		.CourseList_Heading
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 18px;
			font-weight: bold;
			color: #000;
		}

		.CourseList_ProductName
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 13px;
			font-weight: bold;
		}

		.CourseList_Message
		{
			color: Red;	
		}

		.MyCourses_Heading
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 14px;
			font-weight: bold;
		}

		.Quiz_Question
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			font-weight: bold;
		}

	</style>
	<script language="javascript" src="./../app_include/launchNewPopupWin.js"></script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 link=000099 vlink=000099 alink=F5D44C>

<!--
######################################################
BODY
######################################################
-->
<table border="0" cellpadding="0" cellspacing="0" width=90% align=center>
	<tr class="screenOnly"><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
	<tr class="screenOnly">
		<td>
			<table cellpadding=0 cellspacing=0 border=0 width=100%>
				<tr>
					<td align=right valign=bottom width=100%>
						<table cellpadding=0 cellspacing=0 border=0 width=100%>
							<tr>
								<td valign=top align=right nowrap>
									<font style="font-family:Arial,Helvetica;font-size:11px;color:#666666">
									<a href="#" onClick="window.print();">Print</a>
									</font>
								</td>
							</tr>
							<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=1 border=0></td></tr>
						</table>
					</td>
					<td><img src="./../app_images/preview/spacer.gif" width=5 height=1 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr class="screenOnly"><td><hr noshade=true size=1></td></tr>
	<tr class="screenOnly"><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
	<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
	<tr> 
		<td valign=top> 
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr> 
					<td width=100% valign=top>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff>
							<tr> 
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:16px;color:#000000"> 
									<b><%=Topic_Name%></b>
									</font> 
								</td>
							</tr>
							<tr> 
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b><%=Topic_Byline%></b>
									</font> 
								</td>
							</tr>
						</table>
					</td>
					<td valign=top><!--<img src="./../app_images/preview/content_callout_crop_02.jpg" align=right vspace=0 hspace=0 width="263" height="50">--></td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2 WIDTH="704">
							<%=Topic_Summary%>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr><td bgcolor=000000><img src="./../app_images/preview/spacer.gif" width=1 height=1 border=0></td></tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff>
							<tr> 
								<td valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Keywords:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=Topic_Keywords%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff>
							<tr> 
								<td valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Description:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=Topic_Abstract%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff ID="Table1">
							<tr> 
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Contact Info:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=Topic_ContactInfo%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff ID="Table2">
							<tr> 
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Source Website:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=Topic_SourceWebsite%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff ID="Table3">
							<tr> 
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Custom Data 1:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=UserDefinedField1%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff ID="Table4">
							<tr> 
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Custom Data 2:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=UserDefinedField2%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff ID="Table5">
							<tr> 
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Custom Data 3:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=UserDefinedField3%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff ID="Table6">
							<tr> 
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Custom Data 4:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=UserDefinedField4%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
				<tr>
					<td colspan=2>
						<table width=100% cellpadding=0 cellspacing=0 border=0 bgcolor=ffffff ID="Table7">
							<tr> 
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<b>Custom Data 5:</b>
									</font> 
								</td>
								<td><img src="./../app_images/preview/spacer.gif" width=10 height=1 border=0>
								<td width=100% valign=top>
									<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000"> 
									<%=UserDefinedField5%>
									</font> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=10 border=0></td></tr>
			</table>
		</td>
	</tr>
	<tr><td><img src="./../app_images/preview/spacer.gif" width=1 height=40 border=0></td></tr>
</table>

</body>
</html>
<%
Call DB_CleanUp
Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008
	'--------------------------------

	if objRec.State <> &H00000000 then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> &H00000000 then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing
End Sub
%>
