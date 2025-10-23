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

Dim objConn, objRec, SQLStr, connStr, i
Dim parentCategoryID

parentCategoryID = Request("pcid")
if IsNumeric(parentCategoryID) then
	parentCategoryID = CInt(parentCategoryID)
else
	parentCategoryID = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

SQLStr = "sp_websites_admin_alphasortcontent_by_parentElementID '0" & Session.Value("websiteID") & "', '0" & parentCategoryID & "'"
'Response.Write "SQLStr = " & SQLStr & "<br>"
Set objRec = objConn.Execute(SQLStr)

Dim newNavString
SQLStr = "sp_websites_admin_climbladder " & parentCategoryID & ", " & CInt(Session.Value("websiteID")) & ", 1"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

Call DB_CleanUp

Response.Redirect "./../website_details.asp?open=" & Server.URLEncode(newNavString)

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