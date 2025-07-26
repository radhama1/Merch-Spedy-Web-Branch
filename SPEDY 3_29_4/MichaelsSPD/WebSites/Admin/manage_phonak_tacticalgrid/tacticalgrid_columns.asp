<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp" -->
<%
Dim objConn, objRec, SQLStr, connStr

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

		.subheaderText{color: #333;}
		.colheaders
		{
			border-top: 2px outset #ececec; 
			border-left: 2px outset #ececec; 
			border-bottom: 1px outset #ececec; 
			padding: 5px;
			padding-left: 5px;
			padding-right: 5px;
		}
		.colcell
		{
			padding: 1px;
			padding-left: 5px;
			padding-right: 5px;
		}
	</style>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div class="" style="margin: 20px;">
	<form name="theForm" action="tacticalgrid_columns_save.asp" method="post" style="padding:0; margin:0;">
	<table border=0 cellpadding=0 cellspacing=0>
		<tr>
			<td class="bodyText subheaderText colheaders" style="">Enabled</td>
			<td class="bodyText subheaderText colheaders" style="">Database Column</td>
			<td class="bodyText subheaderText colheaders" style="">Display Name</td>
			<td class="bodyText subheaderText colheaders" style="">Default View<br>(When Enabled)</td>
			<td class="bodyText subheaderText colheaders" style="border-right: 1px solid #999;">User Can Disable<br>(When Enabled)</td>
		</tr>
		<%
		SQLStr = "SELECT * FROM Phonak_TacticalGrid_ColumnDisplayName WHERE Allow_Admin = 1 ORDER BY Column_Ordinal, [ID]"
		objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
		if not objRec.EOF then
			Do until objRec.EOF
		%>
		<tr>
			<td class="bodyText colcell" align="center">
				<input type="checkbox" name="chkEnabledCols" value="<%=objRec("ID")%>"<%if not SmartValues(objRec("Allow_UserDisable"), "CBool") and not SmartValues(objRec("Is_Custom"), "CBool") then%> disabled<%end if%><%if SmartValues(objRec("Display"), "CBool") then%> checked<%end if%>>
				<%if not SmartValues(objRec("Allow_UserDisable"), "CBool") and not SmartValues(objRec("Is_Custom"), "CBool") then%>
				<input type="hidden" name="chkEnabledCols" id="chkEnabledCols" value="<%=objRec("ID")%>">
				<%end if%>
			</td>
			<td class="bodyText colcell"><%=objRec("Column_Name")%></td>
			<td class="bodyText colcell"><input type="text" name="txtDisplayName_<%=objRec("ID")%>" style="width: 200px;" value="<%=Server.HTMLEncode(SmartValues(objRec("Display_Name"), "CStr"))%>"></td>
			<td class="bodyText colcell">
				<select name="Select_Default_UserDisplay_<%=objRec("ID")%>" id="Select_Default_UserDisplay_<%=objRec("ID")%>" style="width: 100px;"<%if (not SmartValues(objRec("Allow_UserDisable"), "CBool") and not SmartValues(objRec("Is_Custom"), "CBool")) or SmartValues(objRec("Is_Custom"), "CBool") then%> disabled<%end if%>>
					<option value="1"<%if SmartValues(objRec("Default_UserDisplay"), "CBool") then%> selected<%end if%>>On</option>
					<option value="0"<%if not SmartValues(objRec("Default_UserDisplay"), "CBool") then%> selected<%end if%>>Off</option>
				</select>
				<%if (not SmartValues(objRec("Allow_UserDisable"), "CBool") and not SmartValues(objRec("Is_Custom"), "CBool")) or SmartValues(objRec("Is_Custom"), "CBool") then%>
				<input type="hidden" name="Select_Default_UserDisplay_<%=objRec("ID")%>" id="Select_Default_UserDisplay_<%=objRec("ID")%>" value="1">
				<%end if%>
			</td>
			<td class="bodyText colcell">
				<select name="Select_Allow_UserDisable_<%=objRec("ID")%>" id="Select_Allow_UserDisable_<%=objRec("ID")%>" style="width: 100px;"<%if (not SmartValues(objRec("Allow_UserDisable"), "CBool") and not SmartValues(objRec("Is_Custom"), "CBool")) or SmartValues(objRec("Is_Custom"), "CBool") then%> disabled<%end if%>>
					<option value="1"<%if SmartValues(objRec("Allow_UserDisable"), "CBool") then%> selected<%end if%>>Yes</option>
					<option value="0"<%if not SmartValues(objRec("Allow_UserDisable"), "CBool") then%> selected<%end if%>>No</option>
				</select>
				<%if (not SmartValues(objRec("Allow_UserDisable"), "CBool") and not SmartValues(objRec("Is_Custom"), "CBool")) or SmartValues(objRec("Is_Custom"), "CBool") then%>
				<input type="hidden" name="Select_Allow_UserDisable_<%=objRec("ID")%>" id="Select_Allow_UserDisable_<%=objRec("ID")%>" value="0">
				<%end if%>
			</td>
		</tr>
		<%
				objRec.MoveNext
			Loop
		end if
		%>
		<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
		<tr>
			<td colspan=10>
				<table width=100% cellpadding=0 cellspacing=0 border=0 ID="Table1">
					<tr>
						<td width=100%><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
						<td><input type=reset name="btnCancel" value="Cancel" id="btnCancel"></td>
						<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
						<td align=right><input type=submit name="btnCommit" value="    Save Changes    " id="btnCommit"></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
	</table>
	</form>
</div>

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