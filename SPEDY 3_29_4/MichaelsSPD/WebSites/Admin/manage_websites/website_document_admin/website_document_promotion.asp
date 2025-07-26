<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
Server.ScriptTimeout = 99999
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim objConn, connStr
Dim objRec, SQLStr
Dim elementID, intPromoDirection, boolPromoteChildren, nestLevelRequired

elementID = checkQueryID(Request("tid"), 0)
intPromoDirection = checkQueryID(Request("promoswitch"), 0)
boolPromoteChildren = CBool(checkQueryID(Request("chkIncludeChildren"), 0))
nestLevelRequired = SmartValues(Request("LevelRequired"), "CStr")

if len(nestLevelRequired) = 0 then
	nestLevelRequired = "-1"
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.ConnectionTimeout = 9999
objConn.Open connStr
objConn.CommandTimeout = 9999

Dim newNavString
SQLStr = "sp_websites_admin_climbladder " & elementID & ", " & CInt(Session.Value("websiteID")) & ", 1"
Response.Write SQLStr & "<br>"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

if elementID > 0 then
	promoteElementTree elementID, boolPromoteChildren, intPromoDirection, nestLevelRequired
end if

Function promoteElementTree(p_Element_ID, p_Promote_Children, p_Promo_Direction, p_Nest_Level_Required)

	Dim SQL, utils, rs
	Dim ActivityLog, ActivityType, ActivityReferenceType, curDocName

	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary

	p_Element_ID = checkQueryID(p_Element_ID, 0)
	
	'Promote Children
	if p_Promote_Children then
		SQL = "sp_websites_promote_element_tree @Element_ID = " & p_Element_ID & ", @Promote_Direction = " & p_Promo_Direction & ", @Promotion_State_ID = 1 , @Promote_Children = 1, @Nest_Level_Required = " & p_Nest_Level_Required
	else
		SQL = "sp_websites_promote_element_tree @Element_ID = " & p_Element_ID & ", @Promote_Direction = " & p_Promo_Direction & ", @Promotion_State_ID = 1 , @Promote_Children = 0, @Nest_Level_Required = " & p_Nest_Level_Required
	end if
	
	'Execute SQL Statement	
	utils.RunSQL SQL
	
	'Audit
	if intPromoDirection = 1 then
		ActivityLog.Activity_Type = ActivityType.Promote_ID
		if p_Promote_Children then
			ActivityLog.Activity_Summary = "Promoted Document Tree Starting With Document"
		else
			ActivityLog.Activity_Summary = "Promoted Document"
		end if
	else
		ActivityLog.Activity_Type = ActivityType.Demote_ID
		if p_Promote_Children then
			ActivityLog.Activity_Summary = "Demoted Document Tree Starting With Document"
		else
			ActivityLog.Activity_Summary = "Demoted Document"
		end if
	end if
	
	'Get the Element_ShortTitle for auditing purposes
	SQL =	"Select wed.Element_ShortTitle " & _
				"From Website_Element we " & _
				"Inner Join Website_Element_Data wed On wed.[Element_ID] = we.[ID] " & _
				"Inner Join Website_Element_Promotion wep On wep.[Element_ID] = we.[ID] And wep.[Element_Data_ID] = wed.[ID] " & _
				"Where we.[ID] = " & p_Element_ID & " And wep.[Promotion_State_ID] = 1 "
	Set rs = utils.LoadRSFromDB(SQL)
	
	if Not rs.EOF then
	
		curDocName = SmartValues(rs("Element_ShortTitle"), "CStr")
			
		'Audit Promote/Demote
		ActivityLog.Reference_Type = ActivityReferenceType.Websites_Document
		ActivityLog.Reference_ID = p_Element_ID
		ActivityLog.Activity_Summary = ActivityLog.Activity_Summary & " " & curDocName
		ActivityLog.Save
		
	end if
	
	rs.Close
		
	Set rs						= Nothing
	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
End Function

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

Response.Redirect "./../website_details.asp?open=" & Server.URLEncode(newNavString)
%>