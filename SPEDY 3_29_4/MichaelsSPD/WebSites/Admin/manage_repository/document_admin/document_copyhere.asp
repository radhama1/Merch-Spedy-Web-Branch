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
Dim numLanguages, i, dbFields, dbValues
Dim topicID, targetID, newTopicID
Dim parentFileName, parentFileID, parentFileSize, newFileID
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs
Dim targetCategoryName, topicName

Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType
Set utils					= New cls_UtilityLibrary

'Topic to be cloned...
topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	Response.Redirect Trim(Request.ServerVariables("HTTP_REFERER"))
end if

'New parent category...
targetID = Request("cid")
if IsNumeric(targetID) then
	targetID = CInt(targetID)
else
	targetID = 0
end if

'ID of newly-created topic...
newTopicID = 0

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

objConn.BeginTrans

'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
'	Begin Database Work....
'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯



'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
'	Insert the copied parent record.  This is the root of all Topic_ID-based relations...
'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
SQLStr = "INSERT INTO Repository_Topic (Start_Date, End_Date) (SELECT Start_Date, End_Date FROM Repository_Topic WHERE ID = " & topicID & ")"
Set objRec = objConn.Execute(SQLStr)


'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
'	Find out what ID was assigned to this new, copied topic...
'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 

SQLStr = "SELECT @@IDENTITY FROM Repository_Topic"
Set objRec = objConn.Execute(SQLStr)
newTopicID = objRec(0)
objRec.Close


'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
'	Find out how many languages there are
'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 

SQLStr = "SELECT MAX(ID) FROM app_languages"
Set objRec = objConn.Execute(SQLStr)
numLanguages = objRec(0)
objRec.Close


'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
'	Insert the actual language-specific data/document details
'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
dbFields = ""
dbFields = dbFields & "Topic_ID, "
dbFields = dbFields & "Default_Language, "
dbFields = dbFields & "Language_ID, "
dbFields = dbFields & "Topic_Name, "
dbFields = dbFields & "Topic_Byline, "
dbFields = dbFields & "Topic_Abstract, "
dbFields = dbFields & "Topic_Keywords, "
dbFields = dbFields & "Topic_Summary, "
dbFields = dbFields & "Topic_Type, "
dbFields = dbFields & "Type1_FileName, "
dbFields = dbFields & "Type1_FileID, "
dbFields = dbFields & "Type1_FileSize, "
dbFields = dbFields & "Type2_LinkURL, "
dbFields = dbFields & "Topic_ContactInfo, "
dbFields = dbFields & "Topic_SourceWebsite, "
dbFields = dbFields & "UserDefinedField1, "
dbFields = dbFields & "UserDefinedField2, "
dbFields = dbFields & "UserDefinedField3, "
dbFields = dbFields & "UserDefinedField4, "
dbFields = dbFields & "UserDefinedField5, "
dbFields = dbFields & "Start_Date, "
dbFields = dbFields & "End_Date, "
dbFields = dbFields & "Enabled "

for i = 0 to numLanguages
	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	'	Grab the location of the attached file (if one exists)
	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	SQLStr = "SELECT Type1_FileID FROM Repository_Topic_Details WHERE Topic_ID = " & topicID & " AND Language_ID = " & i
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		parentFileID = objRec(0)
	else
		parentFileID = 0
	end if
	objRec.Close


	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	'	Create new file to be attached to the copy...
	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	SQLStr = "INSERT INTO Repository_Topic_Files (FileName, Orig_FilePath, File_BLOB_Data, File_TotalSize, Enabled, Is_Temp_File, Creator_ID, Date_Created) (SELECT c.FileName, c.Orig_FilePath, c.File_BLOB_Data, c.File_TotalSize, c.Enabled, c.Is_Temp_File, c.Creator_ID, c.Date_Created FROM Repository_Topic_Files c WHERE c.ID = " & parentFileID & ")"
	Set objRec = objConn.Execute(SQLStr)


	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	'	Get the ID of the new file
	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	newFileID = 0
	SQLStr = "SELECT @@IDENTITY FROM Repository_Topic_Files"
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if not IsNull(objRec(0)) then
			newFileID = CInt(objRec(0))
		end if
	end if
	objRec.Close


	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	'	Finally, copy the new data...
	'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++
	dbValues = ""
	dbValues = dbValues & newTopicID & ", " 'Substitute our new Topic_ID for the old one
	dbValues = dbValues & "Default_Language, "
	dbValues = dbValues & "Language_ID, "
	dbValues = dbValues & "LEFT('Copy of ' + Topic_Name, 4000), "
	dbValues = dbValues & "Topic_Byline, "
	dbValues = dbValues & "Topic_Abstract, "
	dbValues = dbValues & "Topic_Keywords, "
	dbValues = dbValues & "Topic_Summary, "
	dbValues = dbValues & "Topic_Type, "	
	dbValues = dbValues & "Type1_FileName, "
	if newFileID > 0 then
		dbValues = dbValues & newFileID & ", " 'IF there was a new ID, insert it into the VALUE string, otherwise leave it be...
	else
		dbValues = dbValues & "Type1_FileID, "
	end if
	dbValues = dbValues & "Type1_FileSize, "
	dbValues = dbValues & "Type2_LinkURL, "
	dbValues = dbValues & "Topic_ContactInfo, "
	dbValues = dbValues & "Topic_SourceWebsite, "
	dbValues = dbValues & "UserDefinedField1, "
	dbValues = dbValues & "UserDefinedField2, "
	dbValues = dbValues & "UserDefinedField3, "
	dbValues = dbValues & "UserDefinedField4, "
	dbValues = dbValues & "UserDefinedField5, "
	dbValues = dbValues & "Start_Date, "
	dbValues = dbValues & "End_Date, "
	dbValues = dbValues & "Enabled "

	SQLStr = "INSERT INTO Repository_Topic_Details (" & dbFields & ") (SELECT " & dbValues & " FROM Repository_Topic_Details WHERE Topic_ID = " & topicID & " AND Language_ID = " & i & ")"
	Response.Write SQLStr
	Set objRec = objConn.Execute(SQLStr)
next

'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
'	Insert into the appropriate navigation location in the repository...
'-- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ -- +++ 
SQLStr = "INSERT INTO Repository_Category_Topic (Category_ID, Topic_ID) VALUES (" & targetID & ", " & newTopicID &")"
Set objRec = objConn.Execute(SQLStr)



'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
'	Commit our finished Database work
'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯


if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("CONTENT_COPY_SUCCESS") = "1"
	
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
	
	'Audit Copy activity
	ActivityLog.Reference_ID = topicID
	ActivityLog.Activity_Summary = "Copied Document " & topicName	& " to " & targetCategoryName
	ActivityLog.Reference_Type = ActivityReferenceType.Content_Document
	ActivityLog.Activity_Type = ActivityType.Copy_ID
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("CONTENT_COPY_SUCCESS") = "0"
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

Response.Redirect "./../repository_details.asp?cid=" & Request.QueryString("cid") & "&sort=" & Request.QueryString("sort") & "&direction=" & Request.QueryString("direction")
%>
