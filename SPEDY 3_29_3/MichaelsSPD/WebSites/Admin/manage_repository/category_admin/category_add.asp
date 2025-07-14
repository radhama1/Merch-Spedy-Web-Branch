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
Dim parentCategoryID

parentCategoryID = Request("pcid")
if IsNumeric(parentCategoryID) then
	parentCategoryID = CInt(parentCategoryID)
else
	parentCategoryID = 0
end if

if Request.Form.Count > 0 and len(Request.Form("Category_Name")) > 0 then
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")
	connStr = Application.Value("connStr")
	objConn.Open connStr

	objRec.Open "Repository_Category", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew
	
	objRec("Parent_Category_ID") = parentCategoryID
	objRec("Category_Name") = Left(Request.Form("Category_Name"), 200)

	objRec.Update
	objRec.Close

	Call DB_CleanUp
	Response.Redirect "category_save_result.asp"
end if

%>
<html>
<head>
	<title>Add Category</title>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table cellpadding=0 cellspacing=0 border=0 align=center>
	<tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<form name="theForm" action="category_add.asp" method=POST>
	<tr>
		<td colspan=2>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Enter a Category Name</b>
			</font>
		</td>
	</tr>
	<tr><td colspan=2><input type="text" size=40 maxlength=200 name="Category_Name" value="" AutoComplete="off"></td></tr>
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
	<input type="hidden" name="pcid" value="<%=parentCategoryID%>">
	</form>
</table>

</body>
</html>

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