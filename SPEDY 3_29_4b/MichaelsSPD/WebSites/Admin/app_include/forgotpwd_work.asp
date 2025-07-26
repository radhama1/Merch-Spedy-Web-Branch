<%@ Language=VBScript %>
<%
Option Explicit
Response.Buffer = True
Response.Expires = True
Server.ScriptTimeout = 30

Dim objRec, objConn, SQLStr, connStr
Dim lostemailAddr, lostpwd, lostpwduser, lastAccessDate, txtFirstName, txtLastName, intUserID

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.Recordset")
connStr = Application.Value("connStr")
objConn.Open connStr

objConn.BeginTrans

if InStr(Trim(Request.Form("Login_UserName")),"'") > 0 or InStr(Trim(Request.Form("Login_UserName")),Chr(34)) > 0 or InStr(Trim(Request.Form("Login_UserName")),Chr(124)) > 0 then
	Response.Redirect Request.ServerVariables("HTTP_REFERER")
else
	SQLStr = "SELECT * FROM Security_User WHERE UserName LIKE '" & Request.Form("Login_UserName") & "'"
end if

objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if not objRec.EOF then
	txtFirstName = objRec("First_Name")
	txtLastName = objRec("Last_Name")
	lostpwduser = objRec("UserName")
	lostpwd = objRec("Password")
	lostemailAddr = objRec("Email_Address")
	intUserID = objRec("ID")
	objRec.UpdateBatch
else
	intUserID = 0
end if
objRec.Close

objRec.Open "Security_User_Forgotten_Pwds", objConn, adOpenKeyset, adLockBatchOptimistic, adCmdTable
objRec.AddNew
objRec("UserName") = Request.Form("Login_UserName")
objRec("User_ID") = intUserID
if lostpwduser <> "" then
	objRec("Request_Success") = true
else
	objRec("Request_Success") = false
end if
objRec.UpdateBatch
objRec.Close

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
else
	objConn.RollbackTrans
end if

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

if lostpwduser <> "" then
	Session.Value("USER_MESSAGE") = "Your password was sent to ''" & lostemailAddr & ".'' Check your email and sign in when your password arrives!"
	Call SendMail(lostpwduser, lostemailAddr)
else
	Session.Value("USER_MESSAGE") = "Your password was not sent because the username ''" & Request.Form("Login_UserName") & "'' was not found." 
end if

Response.Write "lostpwduser = " & lostpwduser & "<br>"
Response.Write "lostpwd = " & lostpwd & "<br>"
Response.Write "lostemailAddr = " & lostemailAddr & "<br>"
Response.Write "USER_MESSAGE = " & Session.Value("USER_MESSAGE") & "<br>"
Response.Write "HTTP_REFERER = " & Request.ServerVariables("HTTP_REFERER") & "<br>"
Response.Write "SMTP_SERVER_URL = " & Application.Value("SMTP_SERVER_URL") & "<br>"
Response.Write "SMTP_USERNAME = " & Application.Value("SMTP_USERNAME") & "<br>"
Response.Write "SMTP_PASSWORD = " & Application.Value("SMTP_PASSWORD") & "<br>"

Response.Redirect "./../login.asp"

Sub SendMail(locRecipName, locRecipAddr)
	Dim Mailer, BodyText
	Set Mailer = Server.CreateObject("SMTPsvg.Mailer")

	Mailer.RemoteHost	= Application.Value("SMTP_SERVER_URL")
	Mailer.UserName		= Application.Value("SMTP_USERNAME")
	Mailer.Password		= Application.Value("SMTP_PASSWORD")
	Mailer.FromName	= "Website Admin Tool"
	Mailer.FromAddress	= "ken.wallace-noresponse@novalibra.com"
	Mailer.AddRecipient locRecipName, locRecipAddr
	Mailer.Subject		= "The password you requested..."
	
	BodyText = "Greetings " & txtFirstName & "," & vbCrLf
	BodyText = BodyText & "Here is your Admin Tool username and password as you requested:" & vbCrLf & vbCrLf

	BodyText = BodyText & Space(4) & "Username:  " & lostpwduser & vbCrLf
	BodyText = BodyText & Space(4) & "Password:  " & lostpwd & vbCrLf & vbCrLf

	BodyText = BodyText & vbCrLf & vbCrLf
	BodyText = BodyText & "..........................................................." & vbCrLf
	BodyText = BodyText & "This email was generated from the Admin Tool" & vbCrLf
	BodyText = BodyText & "by an anonymous visitor requesting" & vbCrLf
	BodyText = BodyText & "login credentials for " & lostpwduser & "." & vbCrLf

	BodyText = BodyText & vbCrLf & vbCrLf & vbCrLf

	Mailer.BodyText = BodyText
	
	Mailer.QMessage	= true

	Mailer.IgnoreMalformedAddress = true
	Mailer.IgnoreRecipientErrors = true

	Call Mailer.SendMail
	
	Set Mailer = Nothing
End Sub

%>
