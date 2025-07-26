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
Dim categoryID, categoryName, newParentCategoryID
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs

categoryID = Request("cid")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

categoryName = ""
newParentCategoryID = 0

if categoryID > 0 then

	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Set the reference type
	ActivityLog.Reference_Type = ActivityReferenceType.Content_Category
	
	'Get the Category Name for auditing purposes
	SQLStr = "Select Category_Name From Repository_Category Where ID = " & categoryID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		categoryName = SmartValues(rs("Category_Name"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
			
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.BeginTrans

	'Find this category's parent category, so we can jog the documents up a level...
	SQLStr = "SELECT Parent_Category_ID FROM Repository_Category WHERE ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)
	newParentCategoryID = objRec(0)
	objRec.Close

	'Move all child documents up one level
	SQLStr = "UPDATE Repository_Category_Topic SET Category_ID = " & newParentCategoryID & " WHERE Category_ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)

	'Move all child categories up one level
	SQLStr = "UPDATE Repository_Category SET Parent_Category_ID = " & newParentCategoryID & " WHERE Parent_Category_ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)

	'Now, finally, kill the category
	SQLStr = "DELETE FROM Repository_Category WHERE ID = " & categoryID
	Set objRec = objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
	'	Session.Value("CATEGORY_REMOVE_SUCCESS") = "1"

		'Audit delete activity
		ActivityLog.Reference_ID = categoryID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Category " & categoryName	
		ActivityLog.Save
	
	else
		objConn.RollbackTrans
	'	Session.Value("CATEGORY_REMOVE_SUCCESS") = "0"
	end if

	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing

	Call DB_CleanUp
end if

Response.Redirect "./../repository_tree.asp?cid=" & newParentCategoryID

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