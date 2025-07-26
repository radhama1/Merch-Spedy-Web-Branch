<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, SQLStr, connStr

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

if Trim(Session.Value("UserID")) = "" then
	Dim login_name, login_pwd

	login_name = Trim(Request.Form("Login_UserName"))
	login_pwd = Trim(Request.Form("Login_Password"))

	Session.Value("Login_UserName") = login_name
	Session.Value("LOGIN_ERROR_MSG") = ""

	if Request.Form.Count > 0 AND (Trim(login_name) <> "" AND Trim(login_pwd) <> "") then
		login_name = Replace(CStr(login_name), ";", "")

		SQLStr = "sp_security_authenticate_user_by_username '" & login_name & "'"
		Response.Write SQLStr & "<br>"
		objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
		if not objRec.EOF then
			if objRec("Password") = login_pwd and CBool(objRec("Enabled")) then

				Session.Value("UserID") = CLng(objRec("ID"))
				Session.Value("User_First_Name") = objRec("First_Name")
				Session.Value("User_Last_Name") = objRec("Last_Name")
				Session.Value("User_Organization") = objRec("Organization")
				Session.Value("User_Email_Address") = objRec("Email_Address")
				Session.Value("User_Date_Created") = objRec("Date_Created")
				Session.Value("User_Date_Last_Modified") = objRec("Date_Last_Modified")
				Session.Value("Login_Password") = login_pwd

				Response.Redirect "../default.asp"
 
			elseif objRec("Password") <> login_pwd then
				Call DB_CleanUp
				Session.Value("LOGIN_ERROR_MSG") = "Incorrect Password.  Please specify a valid Password."
				Response.Redirect "../login.asp"
			elseif CBool(objRec("Enabled")) = false then
				Call DB_CleanUp
				Session.Value("LOGIN_ERROR_MSG") = "Login Forbidden.  Your account is currently disabled."
				Response.Redirect "../login.asp"
			else
				Call DB_CleanUp
				Session.Value("LOGIN_ERROR_MSG") = "Errors Occured.  Your login request could not be granted because errors occurred during the login attempt."
				Response.Redirect "../login.asp"
			end if
		else
			Call DB_CleanUp
			Session.Value("LOGIN_ERROR_MSG") = "Username was not found.  Please specify a valid Username."
			Response.Redirect "../login.asp"
		end if
		objRec.Close
	elseif Request.Form.Count > 0 AND (Trim(login_name) <> "" AND Trim(login_pwd) = "") then
		Call DB_CleanUp
		Session.Value("LOGIN_ERROR_MSG") = "Missing Password.  Please specify a valid Password."
		Response.Redirect "../login.asp"
	else
		Call DB_CleanUp
		Response.Write SQLStr & "<br>"
		Response.Redirect "../login.asp"
	end if
else
	Response.Redirect "../default.asp"
end if


Call DB_CleanUp
Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
	Const adStateClosed = &H00000000
	Const adStateOpen = &H00000001
	Const adStateConnecting = &H00000002
	Const adStateExecuting = &H00000004
	Const adStateFetching = &H00000008

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