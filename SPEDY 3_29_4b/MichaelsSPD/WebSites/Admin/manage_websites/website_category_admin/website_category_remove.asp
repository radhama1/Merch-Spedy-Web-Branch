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
Dim categoryID, newParentCategoryID

categoryID = Request("cid")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

newParentCategoryID = 0

if categoryID > 0 then
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.BeginTrans

	'Find this category's parent category, so we can jog the documents up a level...
	SQLStr = "SELECT Parent_Category_ID FROM Website_Category WHERE Website_ID = " & Session.Value("websiteID") & " AND ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)
	newParentCategoryID = objRec(0)
	objRec.Close

	'Move all child documents up one level
	SQLStr = "UPDATE Website_Category_Topic SET Category_ID = " & newParentCategoryID & " WHERE Website_ID = " & Session.Value("websiteID") & " AND Category_ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)

	'Move all child categories up one level
	SQLStr = "UPDATE Website_Category SET Parent_Category_ID = " & newParentCategoryID & " WHERE Website_ID = " & Session.Value("websiteID") & " AND Parent_Category_ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)

	'kill the category in the sortorder table
	SQLStr = "DELETE FROM Website_SortOrder WHERE Website_ID = " & Session.Value("websiteID") & " AND Website_Category_ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)

	'Now, finally, kill the category
	SQLStr = "DELETE FROM Website_Category WHERE Website_ID = " & Session.Value("websiteID") & " AND ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
	else
		objConn.RollbackTrans
	end if

	Call DB_CleanUp
end if

Response.Redirect "./../website_details.asp"

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