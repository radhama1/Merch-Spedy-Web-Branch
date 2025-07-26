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
Dim categoryID
Dim Category_Name, Date_Created, Date_Last_Modified

categoryID = Request("cid")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	Response.Redirect "category_add.asp?pcid=0"
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if Request.Form.Count > 0 and len(Request.Form("Category_Name")) > 0 then
	SQLStr = "SELECT * FROM Repository_Category WHERE ID = " & categoryID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
	if not objRec.EOF then
		objRec("Category_Name") = Request.Form("Category_Name")
		objRec("Date_Last_Modified") = CDate(Now)
		objRec.Update
	end if
	objRec.Close
	
	Call DB_CleanUp
	Response.Redirect "category_save_result.asp"
end if

SQLStr = "SELECT Category_Name, Date_Created, Date_Last_Modified FROM Repository_Category WHERE ID = " & categoryID
objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
if not objRec.EOF then
	Category_Name = objRec("Category_Name")
	Date_Created = CDate(objRec("Date_Created"))
	Date_Last_Modified = CDate(objRec("Date_Last_Modified"))
end if
objRec.Close

Call DB_CleanUp
%>
<html>
<head>
	<title>Edit Category:&nbsp;<%=Category_Name%></title>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table cellpadding=0 cellspacing=0 border=0 align=center>
	<tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<form name="theForm" action="category_edit.asp" method=POST>
	<tr>
		<td colspan=2>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Category Name</b>
			</font>
		</td>
	</tr>
	<tr><td colspan=2><input type="text" size=40 maxlength=200 name="Category_Name" value="<%=Category_Name%>" AutoComplete="off"></td></tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<tr>
		<td>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Date Created</b>
			</font>
		</td>
		<td align=right>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<%=Date_Created%>
			</font>
		</td>
	</tr>
	<tr>
		<td>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Date Last Modified</b>
			</font>
		</td>
		<td align=right>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<%=Date_Last_Modified%>
			</font>
		</td>
	</tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<tr>
		<td colspan=2 align=right>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr width=100%>
					<td><input type=button name="doSubmit" value=" Cancel " onClick="self.close();"></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=submit name="doSubmit" value=" Save & Close "></td>
				</tr>
			</table>
		</td>
	</tr>
	<input type="hidden" name="cid" value="<%=categoryID%>">
	</form>
</table>

</body>
</html>

<!--
<table cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td colspan=2>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#333333">
			</font>
		</td>
	</tr>
</table>
-->

<%
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