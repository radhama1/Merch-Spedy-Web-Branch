<%
'==============================================================================
' Author: Ken Wallace for Nova Libra, Inc.
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, objRec2, SQLStr, connStr
Dim login_name
Dim strLoginGroups, arLoginGroups

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

Session.Value("LOGIN_ERROR_MSG") = ""

if Trim(Session.Value("UserID")) = "" then
	if Len(Trim(Request("HTTP_IV_USER"))) > 0 or Len(Trim(Request("HTTP_IV_GROUPS"))) > 0 or Len(Trim(Request("AUTH_USER"))) > 0 then

		if Len(Trim(Request("HTTP_IV_USER"))) > 0 then
			login_name = Trim(Request("HTTP_IV_USER"))
		elseif Len(Trim(Request("AUTH_USER"))) > 0 then
			login_name = Trim(Request("AUTH_USER"))
		else
			login_name = "guest"
		end if
		
		if Len(Trim(Request("HTTP_IV_GROUPS"))) > 0 then
			strLoginGroups = LCase(Trim(Request("HTTP_IV_GROUPS")))
			strLoginGroups = Replace(strLoginGroups, Chr(34), "")
			arLoginGroups = Split(strLoginGroups, ",")
		end if

		if Len(Trim(login_name)) = 0 and Len(strLoginGroups) = 0 then
			login_name = ""
		end if

		if Len(Trim(login_name)) > 0 then
			SQLStr = "sp_security_authenticate_user_by_username '" & login_name & "'"
			Response.Write SQLStr & "<br>"
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

					Response.Redirect "./../default.asp"
	 
				elseif CBool(objRec("Enabled")) = FALSE then
					Call DB_CleanUp
					Session.Value("LOGIN_ERROR_MSG") = "Login Forbidden.  Your account is currently disabled."
					Response.Redirect "./../login.asp"
				else
					Call DB_CleanUp
					Session.Value("LOGIN_ERROR_MSG") = "Errors Occured.  Your login request could not be granted because errors occurred during the login attempt."
					Response.Redirect "./../login.asp"
				end if
			else
				Call DB_CleanUp
				if (Len(Trim(Request("HTTP_IV_USER"))) > 0 or Len(Trim(Request("AUTH_USER"))) > 0) and Len(Trim(Request("HTTP_IV_GROUPS"))) > 0 then
					'This users login failed, so lets try to authenticate them as a"guest"...
					Response.Redirect Replace(Replace(Replace(Application.Value("AdminToolURL") & "/include/dologin_sso.asp?HTTP_IV_USER=" & Trim(Request("HTTP_IV_USER")) & "&AUTH_USER=" & Trim(Request("AUTH_USER")) & "&HTTP_IV_GROUPS=" & Trim(Request("HTTP_IV_GROUPS")), "//", "/"), "http:/", "http://"), "https:/", "https://")
				else
					Session.Value("LOGIN_ERROR_MSG") = "Username was not found.  Please specify a valid Username."
					Response.Redirect "./../login.asp"
				end if
			end if
			objRec.Close
		else
			Session.Value("LOGIN_ERROR_MSG") = "Your logon credentials were not supplied correctly. Please specify a valid Username."
			Response.Redirect "./../login.asp"
		end if
	else
		Session.Value("LOGIN_ERROR_MSG") = "Your logon credentials were not supplied correctly."
		Response.Redirect "./../login.asp"
	end if
else
	Response.Redirect "./../default.asp"
end if

Response.Write "Error: " & Session.Value("LOGIN_ERROR_MSG")

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