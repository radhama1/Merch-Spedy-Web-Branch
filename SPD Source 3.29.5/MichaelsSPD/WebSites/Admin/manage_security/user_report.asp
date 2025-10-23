<%	
Response.ContentType = "application/vnd.ms-excel"
Response.AddHeader "Content-Disposition", "attachment; filename=spedy_users.xls"
'for each item in session.contents
'	response.write(item & ": " & session(item) & "<BR>")
'next
'response.end
'
if session("Login_UserName")="" then
	response.redirect("/login.asp")
end if
Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec1 = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

SQLStr = "select * from security_user"
objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE> SPEDY Users </TITLE>
<META NAME="Generator" CONTENT="EditPlus">
<META NAME="Author" CONTENT="">
<META NAME="Keywords" CONTENT="">
<META NAME="Description" CONTENT="">
<STYLE>
DIV, TD
{
	font-family: Arial_Narrow, Arial, sans-serif;
	font-size: 9;
}
</STYLE>
</HEAD>
<BODY>
<TABLE>
<TR>
	<TD>Email_Address</TD>
	<TD>UserName</TD>
	<TD>Password</TD>
	<TD>Enabled</TD>
	<TD>Last_Name</TD>
	<TD>First_Name</TD>
	<TD>Middle_Name</TD>
	<TD>Organization</TD>
	<TD>Office_Location</TD>
	<TD>User Group</TD>
	<TD>User Privilege</TD>
	<TD>Date_Created</TD>
	<TD>Date_Last_Modified</TD>
</TR>
<%
while not objRec.eof
%>
	<TR>
		<TD><%=objRec("Email_Address")%></TD>
		<TD><%=objRec("UserName")%></TD>
		<TD><%=objRec("Password")%></TD>
		<TD><%=objRec("Enabled")%></TD>
		<TD><%=objRec("Last_Name")%></TD>
		<TD><%=objRec("First_Name")%></TD>
		<TD><%=objRec("Middle_Name")%></TD>
		<TD><%=objRec("Organization")%></TD>
		<TD><%=objRec("Office_Location")%></TD>
		<TD><%
		SQLStr = "select group_name from security_user_group, security_group where security_user_group.group_id=security_group.id and User_id=" & objRec("id")
		objRec1.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
		while not objRec1.eof
			response.write(objRec1("group_name"))
			objRec1.movenext
			if not objRec1.eof then
				response.write(", " & vbcrlf)
			end if
		wend
		objRec1.close
		%></TD>
		<TD><%
		SQLStr = "select privilege_name from security_user_privilege, security_privilege where security_user_privilege.privilege_id=security_privilege.id and User_id=" & objRec("id")
		objRec1.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
		while not objRec1.eof
			response.write(objRec1("privilege_name"))
			objRec1.movenext
			if not objRec1.eof then
				response.write(", " & vbcrlf)
			end if
		wend
		objRec1.close
		%></TD>
		<TD><%=objRec("Date_Created")%></TD>
		<TD><%=objRec("Date_Last_Modified")%></TD>
	</TR>
<%
	objRec.movenext
wend
objRec.close
Set objConn = nothing
Set objRec = nothing
Set objRec1 = nothing
Set objRec2 = nothing
%></TABLE>

</BODY>
</HTML>
