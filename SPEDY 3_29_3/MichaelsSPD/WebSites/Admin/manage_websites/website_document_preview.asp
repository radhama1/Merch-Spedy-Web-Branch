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

%>
<!--#include file="./../app_include/getfile_MIMEtype.asp"-->
<!--#include file="./../app_include/getfile_icon_name.asp"-->
<%

Dim objConn, objRec, SQLStr, i, connStr
Dim topicID, Topic_ID
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

if topicID > 0 then
	SQLStr = "sp_websites_admin_content_by_elementID " & topicID & ", " & Session.Value("websiteID") & ", 1"
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
		Topic_ID					 = topicID
		Topic_Name					 = SmartValues(objRec("Element_FullTitle"), "CStr")
		Topic_NavName				 = SmartValues(objRec("Element_ShortTitle"), "CStr")
		Topic_Byline				 = SmartValues(objRec("Element_FullTitle_SubTitle"), "CStr")
		Topic_Summary				 = stripTextSizes(SmartValues(objRec("Element_Body"), "CStr"))
		Topic_Abstract				 = SmartValues(objRec("Element_Abstract"), "CStr")
		Topic_Keywords				 = SmartValues(objRec("Element_Keywords"), "CStr")
		Topic_Type					 = SmartValues(objRec("Element_Type"), "CStr")
		Type1_FileName				 = SmartValues(objRec("Type1_FileName"), "CStr")
		Type1_FileID				 = SmartValues(objRec("Type1_FileID"), "CInt")
		Type1_FileSize				 = SmartValues(objRec("Type1_FileSize"), "CDbl")
		Type2_LinkURL				 = SmartValues(objRec("Element_Body"), "CStr")
	end if
	objRec.Close
end if
%>
<html>
<head>
	<title><%=Topic_Name%></title>
	<style type="text/css">
		@media print {
		.screenOnly {display: none;}
		}

		A:link {color: #666666; text-decoration: underline; font-weight: normal;}
		A:link:hover {color: #666666; text-decoration: underline; font-weight: normal;}
		A:visited {color: #688A92; text-decoration: underline; font-weight: normal;}
		A:visited:hover {color: #688A92; text-decoration: underline; font-weight: normal;}
		A:active {color: #666666; text-decoration: underline; font-weight: normal;}
		
		/*-----------------------------------------------------------------------------*/
		/*  Shouldnt have to list each HTML element like this, but this is the         */
		/*  only way Netscape 4.x will display the stylesheets correctly. C'est La Vie */
		/*-----------------------------------------------------------------------------*/

		TD {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}
		BLOCKQUOTE {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}
		BODY {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}
		UL {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}
		P {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}
		I {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px; font-style: italic;}
		EM {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px; font-style: italic;}
		DIV {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}
		STRONG {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px; font-weight: bold;}
		B {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px; font-weight: bold;}
		BIG {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 17px;}
		SMALL {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 10px;}
		SPAN {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}
		FONT {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px;}

		#contentHeader  {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 16px; font-weight: bold;}
		#contentSubHeader  {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px; font-weight: bold;}
		#contentBody  {font-family: Arial, Verdana, Geneva, Helvetica !important; font-size: 12px !important;}

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
					<td colspan=2>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#000000;line-height:18px;"> 
							<%=Topic_Summary%>
						</font> 
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
