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
Dim topicID, targetID, thisTopicID
Dim strCheckedItems, arCheckedItems
Dim thisElementID, thisElementType, intElementType
Dim ActivityLog, ActivityType, ActivityReferenceType, rs, utils
Dim topicName

topicName = ""
thisTopicID = 0

thisElementType = Trim(Request("itemType"))
if thisElementType = "document" then
	intElementType = 2
else
	intElementType = 1
end if

thisElementID = Request("itemID")
if IsNumeric(thisElementID) then
	thisElementID = CInt(thisElementID)
else
	thisElementID = 0
end if

strCheckedItems = Replace(Request.Form("chkItem"), "num_", "")
strCheckedItems = Replace(strCheckedItems, "_num", "")
arCheckedItems = Split(strCheckedItems, ", ")

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr
objConn.CommandTimeout = 99999

for i = 0 to UBound(arCheckedItems)
	if IsNumeric(arCheckedItems(i)) then
		thisTopicID = 0
		SQLStr = "sp_websites_addnew_element " & CInt(Session.Value("websiteID")) & ", " & thisElementID & ", " & CInt(arCheckedItems(i)) & ", " & intElementType
		Set objRec = objConn.Execute(SQLStr)
		thisTopicID = objRec("New_Element_ID")
		objRec.Close
		
		Set ActivityLog				= New cls_ActivityLog
		Set ActivityType			= New cls_ActivityType
		Set ActivityReferenceType	= New cls_ActivityReferenceType
		Set utils					= New cls_UtilityLibrary

		'Get the Element_ShortTitle for auditing purposes
		SQLStr = "Select Top 1 Element_ShortTitle From Website_Element_Data Where Element_ID = " & thisTopicID
		Set rs = utils.LoadRSFromDB(SQLStr)
		
		if Not rs.EOF then
			topicName = SmartValues(rs("Element_ShortTitle"), "CStr")
		end if
		
		rs.Close
		Set rs = Nothing

		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created Document " & topicName
		ActivityLog.Reference_Type = ActivityReferenceType.Websites_Document
		ActivityLog.Reference_ID = thisTopicID	
		ActivityLog.Save

		Set utils					= Nothing
		Set ActivityLog				= Nothing
		Set ActivityType			= Nothing
		Set ActivityReferenceType	= Nothing
	end if
next

Dim newNavString
SQLStr = "sp_websites_admin_climbladder " & thisTopicID & ", " & CInt(Session.Value("websiteID")) & ", 2"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

Call DB_CleanUp

Response.Redirect "./website_document_select_finish.asp?open=" & Server.URLEncode(newNavString)

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
