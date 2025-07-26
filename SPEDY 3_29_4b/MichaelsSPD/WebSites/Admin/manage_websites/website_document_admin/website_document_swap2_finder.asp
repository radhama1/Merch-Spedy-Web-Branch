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

Dim objConn, objRec, SQLStr, connStr
Dim searchString, searchStatus

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title></title>
</head>
<body bgcolor="ececec" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr bgcolor=cccccc>
		<td>
			<font style="font-family:Arial,Helvetica;font-size:11px;color:#000000">
			<b>Quick Search</b>
			</font>
		</td>
	</tr>
	<tr><td><img src="./../images/spacer.gif" border=0 width=1 height=3></td></tr>
	<tr>
		<td>
			<form name="theForm" action="website_document_swap2_finder_results.asp" method="POST" target="DetailFrame">
			<table cellpadding=0 cellspacing=0 border=0 width=100%>
				<tr>
					<td><img src="./../images/spacer.gif" border=0 width=5 height=1></td>
					<td align=right>
						<font style="font-family:Arial,Helvetica;font-size:11px;color:#000000">
						Find
						</font>
					</td>
					<td><img src="./../images/spacer.gif" border=0 width=3 height=1></td>
					<td><input type="text" name="searchString" size=20 maxlength=255 value="<%=Trim(searchString)%>"></td>
					<td><img src="./../images/spacer.gif" border=0 width=2 height=1></td>
					<td><input type="image" src="./../images/search_icon.gif" border=0 width=14 height=14 alt="Search" id=image1 name=image1></td>
					<td width=100%><img src="./../images/spacer.gif" border=0 width=5 height=1></td>
				</tr>
				<tr><td><img src="./../images/spacer.gif" border=0 width=1 height=3></td></tr>
				<tr>
					<td><img src="./../images/spacer.gif" border=0 width=5 height=1></td>
					<td align=right>
						<font style="font-family:Arial,Helvetica;font-size:11px;color:#000000">
						in
						</font>
					</td>
					<td><img src="./../images/spacer.gif" border=0 width=3 height=1></td>
					<td colspan=4>
						<table cellpadding=0 cellspacing=0 border=0>
							<tr>
								<td>
								<%
								SQLStr = "SELECT * FROM Repository_Status ORDER BY SortOrder, Status_Name"
								objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
								if not objRec.EOF then
								%>
									<select name="searchStatus">
										<option value="0">-- any status --
									<%
									Do until objRec.EOF
									%>
										<option value="<%=objRec("ID")%>"><%=objRec("Status_Name")%>
									<%
										objRec.MoveNext
									Loop
									%>
									</select>
								<%
								end if
								objRec.Close
								%>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			</form>
		</td>
	</tr>
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