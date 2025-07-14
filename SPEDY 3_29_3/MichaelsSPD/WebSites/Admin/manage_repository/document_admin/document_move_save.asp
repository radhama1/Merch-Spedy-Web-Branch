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
Dim topicID, targetID, topicName, targetCategoryName
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs

topicName = ""
targetCategoryName = ""
topicID = Request.Form("topicID")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	Response.Redirect Trim(Request.ServerVariables("HTTP_REFERER"))
end if

targetID = Request.Form("targetID")
if IsNumeric(targetID) then
	targetID = CInt(targetID)
else
	targetID = 0
end if

Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType
Set utils					= New cls_UtilityLibrary
	
ActivityLog.Reference_Type = ActivityReferenceType.Content_Document
ActivityLog.Activity_Type = ActivityType.Move_ID

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

objConn.BeginTrans

SQLStr = "UPDATE Repository_Category_Topic SET Category_ID = " & targetID & " WHERE Topic_ID = " & topicID
Set objRec = objConn.Execute(SQLStr)

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("CONTENT_MOVE_SUCCESS") = "1"
	
	'Get the topic Name for auditing purposes
	SQLStr = "Select Top 1 Topic_Name From Repository_Topic_Details Where Topic_ID = " & topicID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		topicName = SmartValues(rs("Topic_Name"), "CStr")
	end if
	
	rs.Close
	
	
	'Get the Target Category Name for auditing purposes
	
	if targetID = 0 then
		targetCategoryName = "Content Repository"
	else
		SQLStr = "Select Category_Name From Repository_Category Where ID = " & targetID
		Set rs = utils.LoadRSFromDB(SQLStr)

		if Not rs.EOF then
			targetCategoryName = SmartValues(rs("Category_Name"), "CStr")
		end if
		
		rs.Close
	end if
	
	Set rs = Nothing
	
	'Audit move activity
	ActivityLog.Reference_ID = topicID
	ActivityLog.Activity_Summary = "Moved Document " & topicName	& " to " & targetCategoryName
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("CONTENT_MOVE_SUCCESS") = "0"
end if

Set utils					= Nothing
Set ActivityLog				= Nothing
Set ActivityType			= Nothing
Set ActivityReferenceType	= Nothing

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

%>
<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	
	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location.reload();
	}
	
	//we're all done, so leave...
	parent.window.close();
</script>
