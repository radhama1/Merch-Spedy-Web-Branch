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

Dim objConn, objRec, SQLStr, connStr, i

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title></title>
	<style type="text/css">
		@import url('./../app_include/global.css');
		.bodyText{line-height: 14px;}
		A {text-decoration: underline; color:#000;}
		A:HOVER {text-decoration: underline; color: #00f;}
		.childcatlist {white-space: nowrap; vertical-align: top; border-bottom: 1px solid #ececec;}
		.childcatlistheader {color: #999; vertical-align: bottom; border-bottom: 1px solid #ccc;}
		.right {text-align: right;}

		.listDivContainer
		{
			width: 100%; 
		}

	</style>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="content_language.asp" method=POST style="margin: 0; padding: 0;">
	<tr><td colspan=3><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
	<tr>
		<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
		<td align=top>
			<table width=500 cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td class="bodyText headerText">
						<b>Language Settings</b>
					</td>
				</tr>
				<tr>
					<td class="bodyText" nowrap=true>
						Content can be created in any of the following languages.
					</td>
				</tr>
				<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
				<tr>
					<td nowrap=true>
						<table cellpadding=0 cellspacing=0 border=0>
							<tr>
								<td valign=bottom>
									<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
									Default<br>
									Language
									</font>
								</td>
								<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
								<td valign=bottom nowrap=true>
									<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
									Language<br>
									Name
									</font>
								</td>
								<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
								<td valign=bottom>
									<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
									Enable
									</font>
								</td>
								<td><img src="./images/spacer.gif" height=1 width=5 border=0></td>
								<td valign=bottom>
									<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
									Disable
									</font>
								</td>
								<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
								<td valign=bottom align=right>
									<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
									Number of<br>
									Documents
									</font>
								</td>
								<td><img src="./images/spacer.gif" height=1 width=5 border=0></td>
							</tr>
							<tr><td colspan=10><img src="./images/spacer.gif" width=1 height=5></td></tr>
							<tr bgcolor="999999"><td colspan=10><img src="./i mages/spacer.gif" width=1 height=1></td></tr>
							<tr bgcolor="ececec"><td colspan=10><img src="./images/spacer.gif" width=1 height=1></td></tr>
							<tr><td colspan=10><img src="./images/spacer.gif" width=1 height=5></td></tr>
						<%
						SQLStr = "SELECT a.ID, a.isDefault, a.Language_PrettyName, a.Language_LongName, a.Enabled, (SELECT Count(ID) FROM Repository_Topic_Details WHERE Language_ID = a.ID) AS numEntries FROM app_languages a ORDER BY a.SortOrder, a.Language_PrettyName"
						objRec.Open SQLStr, objConn, adOpenDynamic, adLockOptimistic, adCmdText
						i = 0
						Do Until objRec.EOF
							if Request.Form.Count > 0 then
								if CBool(Request.Form("rdo_" & objRec("ID"))) then
									objRec("Enabled") = 1
								else
									objRec("Enabled") = 0
								end if

								if CInt(Request.Form("rdo_isDefaultLanguage")) = CInt(objRec("ID")) then
									objRec("isDefault") = 1
								else
									objRec("isDefault") = 0
								end if
							end if
							
						%>
							<tr>
								<td align=center><input type=radio name="rdo_isDefaultLanguage" value="<%=objRec("ID")%>"<%if CBool(objRec("isDefault")) then Response.Write " CHECKED" end if%>></td>
								<td></td>
								<td nowrap=true>
									<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
									<%=objRec("Language_PrettyName")%>&nbsp;<%if not IsNull(objRec("Language_LongName")) then Response.Write "(" & Server.HTMLEncode(objRec("Language_LongName")) & ")" end if%>
									</font>
								</td>
								<td></td>
								<td align=center><input type=radio name="rdo_<%=objRec("ID")%>" value="1"<%if CBool(objRec("Enabled")) then Response.Write " CHECKED" end if%>></td>
								<td></td>
								<td align=center><input type=radio name="rdo_<%=objRec("ID")%>" value="0"<%if not CBool(objRec("Enabled")) then Response.Write " CHECKED" end if%>></td>
								<td></td>
								<td align=right>
									<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
									<%=objRec("numEntries")%>
									</font>
								</td>
								<td></td>
							</tr>
						<%
							i = i + 1
							objRec.MoveNext
						Loop
						if i > 0 then
							objRec.UpdateBatch
						end if
						objRec.Close
						%>
							<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
							<tr><td colspan=10><img src="./images/spacer.gif" width=1 height=5></td></tr>
							<tr bgcolor="999999"><td colspan=10><img src="./i mages/spacer.gif" width=1 height=1></td></tr>
							<tr bgcolor="ececec"><td colspan=10><img src="./images/spacer.gif" width=1 height=1></td></tr>
							<tr><td colspan=10><img src="./images/spacer.gif" width=1 height=5></td></tr>
							<tr>
								<td colspan=10>
									<table width=100% cellpadding=0 cellspacing=0 border=0>
										<tr>
											<td width=100%><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
											<td><input type=reset name="btnCancel" value="Cancel"></td>
											<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
											<td align=right><input type=submit name="btnCommit" value="    Save Changes    "></td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td><img src="./images/spacer.gif" height=100 width=1 border=0></td></tr>
			</table>
		</td>
		<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
	</tr>
	</form>
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

	if objRec.State <> adStateClosed then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing
End Sub

%>