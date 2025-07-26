<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, objRec2, SQLStr, connStr

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

'	Trim(Request.ServerVariables("HTTP_IV_USER"))
'	Trim(Request.ServerVariables("AUTH_USER"))

if Trim(Session.Value("UserID")) = "" then
	if Len(Trim(Request("g"))) >= 28 then
		Dim login_guid

		login_guid = Trim(Request("g"))

		Session.Value("LOGIN_ERROR_MSG") = ""

		if Len(Trim(login_guid)) > 0 then
			login_guid = Replace(CStr(login_guid), ";", "")

			SQLStr = "sp_security_authenticate_user_by_guid '" & login_guid & "'"
			'Response.Write SQLStr & "<br>"
			objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
			if not objRec.EOF then
				if CBool(objRec("Enabled")) then

					Session.Value("UserID") = CLng(objRec("ID"))
					Session.Value("User_First_Name") = objRec("First_Name")
					Session.Value("User_Last_Name") = objRec("Last_Name")
					Session.Value("User_Organization") = objRec("Organization")
					Session.Value("User_Email_Address") = objRec("Email_Address")
					Session.Value("User_Date_Created") = objRec("Date_Created")
					Session.Value("User_Date_Last_Modified") = objRec("Date_Last_Modified")
					Session.Value("Login_UserName") = objRec("UserName")

					Response.Redirect "../default.asp"
	 
				elseif CBool(objRec("Enabled")) = FALSE then
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
				'Response.Redirect "../login.asp"
			end if
			objRec.Close
		else
			Call DB_CleanUp
			Session.Value("LOGIN_ERROR_MSG") = "Your domain logon credentials were not supplied correctly. Please specify a valid Username."
			Response.Redirect "../login.asp"
		end if
	else
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