<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Dim ActivityLog, ActivityType, ActivityReferenceType, utils

Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("rid"), 0)
Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType
Set utils					= New cls_UtilityLibrary

ActivityLog.Reference_Type = ActivityReferenceType.Validation_Rule

Dim thisUserID
thisUserID = SmartValues(Session.Value("UserID"), "Integer")

Dim conn, cmd, param, rs, SQLStr, connStr, i, j, n, x, y
Dim recordID, ruleID, boolIsNew, ruleXML, xmlDoc
' Validation_Rules
Dim Validation_Document_ID, Validation_Rule, Metadata_Column_ID, Enabled
' Validation_Condition_Sets
Dim Validation_Condition_Set_ID, Validation_Rule_Type_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
' Validation_Condition_Set_Stages
Dim SPD_Workflow_Stage_ID
' Validation_Conditions
Dim Validation_Condition_ID, Validation_Condition_Type_ID, Condition_Ordinal, Field1, Field2, Field3, Value1, Value2, Value3, Operator, Conjunction

Dim Sort_Order, Current_Date

Set conn = Server.CreateObject("ADODB.Connection")
Set cmd = Server.CreateObject("ADODB.Command")
Set rs = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
conn.Open connStr

Set cmd.ActiveConnection = conn

recordID = checkQueryID(Request("tid"), 0)
ruleID = checkQueryID(Request("rid"), 0)

boolIsNew = CBool(Request.Form("boolIsNew"))

if boolIsNew and ruleID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if

' Validation_Rules record
Validation_Document_ID = recordID
Validation_Rule = SmartValues(Trim(Request.Form("Validation_Rule")), "String")
Metadata_Column_ID = checkQueryID(Request.Form("Metadata_Column_ID"), 0)
if Request.Form("Enabled") = "1" then
    Enabled = true
else
    Enabled = false
end if

' get the Sort_Order
'Sort_Order = 10000
'SQLStr = "sp_CustomFields_GetNextSortOrder " & Record_Type
'Set rs = utils.LoadRSFromDB(SQLStr)
'if Not rs.EOF then
'	Sort_Order = SmartValues(rs("Next_Sort_Order"), "CInt")
'end if
'rs.Close
'Set rs = Nothing

conn.BeginTrans

Current_Date = CDate(Now())

' ******************************************************************
' Save Validation_Rules record
' ******************************************************************
SQLStr = "usp_Validation_SaveRule"
cmd.CommandText = SQLStr
cmd.CommandType = adCmdStoredProc
cmd.Parameters.Append cmd.CreateParameter("@ID", adInteger, adParamInputOutput,, ruleID)
cmd.Parameters.Append cmd.CreateParameter("@Validation_Document_ID", adInteger, adParamInput,, Validation_Document_ID)
cmd.Parameters.Append cmd.CreateParameter("@Validation_Rule", adVarChar, adParamInput, 255, Validation_Rule)
cmd.Parameters.Append cmd.CreateParameter("@Metadata_Column_ID", adInteger, adParamInput,, Metadata_Column_ID)
cmd.Parameters.Append cmd.CreateParameter("@Validation_Rule_Type_ID", adInteger, adParamInput,, 1)
cmd.Parameters.Append cmd.CreateParameter("@Enabled", adBoolean, adParamInput,, Enabled)
cmd.Parameters.Append cmd.CreateParameter("@userID", adInteger, adParamInput,, thisUserID)
cmd.Execute
if boolIsNew then
    ruleID = cmd.Parameters("@ID")
end if

' ******************************************************************
' CLEAR current rule's record!  WHY?  easier than matching ids on 
' all sub objects... just clear/save... ID's are irrelevant anyway 
' and records should rarely change.
' ******************************************************************
if not boolIsNew then
    ' init
    do while cmd.Parameters.Count > 0
        cmd.Parameters.Delete(0)
    loop
    ' delete rule info
    SQLStr = "usp_Validation_DeleteRuleInfo"
    cmd.CommandText = SQLStr
    cmd.CommandType = adCmdStoredProc
    cmd.Parameters.Append cmd.CreateParameter("@ruleID", adInteger, adParamInput,, ruleID)
    cmd.Parameters("@ruleID").Value = ruleID
    cmd.Execute
end if

' ******************************************************************
' Process ruleXML
' ******************************************************************

ruleXML = Trim(SmartValues(Request.Form("ruleXML"), "String"))

Set xmlDoc = Server.CreateObject("MSXML2.DOMDocument")
xmlDoc.loadXML ruleXML

Dim root, conditionSets, conditionSet, conditions, stages, condition
Dim conditionSetOrdinal, conditionOrdinal
conditionSetOrdinal = 1
conditionOrdinal = 1

'Response.Write "<pre>" & Server.HTMLEncode(ruleXML) & "</pre>"
'Response.End
Set root = xmlDoc.documentElement

for i = 0 to root.childNodes.length - 1 step 1
    if (root.childNodes(i).tagName = "conditionsets") then
        ' condition sets
        set conditionSets = root.childNodes(i)
        for j = 0 to conditionSets.childNodes.length - 1 step 1
            if (conditionSets.childNodes(j).tagName = "conditionset") then
                ' condition set
                set conditionSet = conditionSets.childNodes(j)
                ' ******************************************************************
                ' Save Validation_Condition_Sets record(s)
                ' ******************************************************************
                Validation_Rule_Type_ID = SmartValues(conditionSet.getAttribute("type"), "Integer")
                Set_Ordinal = conditionSetOrdinal
                conditionSetOrdinal = conditionSetOrdinal + 1
                if conditionSet.getElementsByTagName("errortext").length > 0 then
                    Error_Text = conditionSet.getElementsByTagName("errortext")(0).text
                else
                    Error_Text = ""
                end if
                Validation_Rule_Severity_ID = SmartValues(conditionSet.getAttribute("severity"), "Integer")
                if conditionSet.getElementsByTagName("stages").length > 0 then
                    stages = conditionSet.getElementsByTagName("stages")(0).text
                else
                    stages = ""
                end if
                ' save record
                do while cmd.Parameters.Count > 0
                    cmd.Parameters.Delete(0)
                loop
                SQLStr = "usp_Validation_SaveConditionSet"
                cmd.CommandText = SQLStr
                cmd.CommandType = adCmdStoredProc
                cmd.Parameters.Append cmd.CreateParameter("@ID", adInteger, adParamInputOutput,, 0)
                cmd.Parameters.Append cmd.CreateParameter("@Validation_Rule_ID", adInteger, adParamInput,, ruleID)
                cmd.Parameters.Append cmd.CreateParameter("@Validation_Rule_Type_ID", adInteger, adParamInput,, Validation_Rule_Type_ID)
                cmd.Parameters.Append cmd.CreateParameter("@Validation_Rule_Severity_ID", adInteger, adParamInput,, Validation_Rule_Severity_ID)
                cmd.Parameters.Append cmd.CreateParameter("@Set_Ordinal", adInteger, adParamInput,, Set_Ordinal)
                cmd.Parameters.Append cmd.CreateParameter("@Error_Text", adVarChar, adParamInput, 255, Error_Text)
                cmd.Parameters.Append cmd.CreateParameter("@userID", adInteger, adParamInput,, thisUserID)
                cmd.Execute
                Validation_Condition_Set_ID = cmd.Parameters("@ID")
                
                ' ******************************************************************
                ' Save Validation_Condition_Set_Stages record(s)
                ' ******************************************************************
                do while cmd.Parameters.Count > 0
                    cmd.Parameters.Delete(0)
                loop
                SQLStr = "usp_Validation_SaveConditionSetStage"
                cmd.CommandText = SQLStr
                cmd.CommandType = adCmdStoredProc
                cmd.Parameters.Append cmd.CreateParameter("@Validation_Condition_Set_ID", adInteger, adParamInput)
                cmd.Parameters.Append cmd.CreateParameter("@SPD_Workflow_Stage_ID", adInteger, adParamInput)
                Dim arr 
                arr = Split(stages, ",")
                if UBound(arr) >= 0 then
                    if isnumeric(arr(0)) then
                        for x = 0 to UBound(arr)
                            cmd.Parameters("@Validation_Condition_Set_ID").Value = Validation_Condition_Set_ID
                            cmd.Parameters("@SPD_Workflow_Stage_ID").Value = SmartValues(arr(x), "Integer")
                            cmd.Execute
                        next
                    end if
                end if
                
                for n = 0 to conditionSet.childNodes.length - 1 step 1
                    if (conditionSet.childNodes(n).tagName = "conditions") then
                    
                        ' ******************************************************************
                        ' conditions
                        ' ******************************************************************
                        
                        SQLStr = "usp_Validation_SaveCondition"
                        cmd.CommandText = SQLStr
                        cmd.CommandType = adCmdStoredProc
                        
                        set conditions = conditionSet.childNodes(n)
                        for x = 0 to conditions.childNodes.length - 1 step 1
                            if (conditions.childNodes(x).tagName = "condition") then
                                set condition = conditions.childNodes(x)
                                ' ******************************************************************
                                ' Save Validation_Conditions record(s)
                                ' ******************************************************************
                                Validation_Condition_Type_ID = SmartValues(condition.getAttribute("type"), "Integer")
                                Condition_Ordinal = conditionOrdinal
                                conditionOrdinal = conditionOrdinal + 1
                                do while cmd.Parameters.Count > 0
                                    cmd.Parameters.Delete(0)
                                loop
                                cmd.Parameters.Append cmd.CreateParameter("@ID", adInteger, adParamInputOutput,, 0)
                                cmd.Parameters.Append cmd.CreateParameter("@Validation_Condition_Set_ID", adInteger, adParamInput,, Validation_Condition_Set_ID)
                                cmd.Parameters.Append cmd.CreateParameter("@Validation_Condition_Type_ID", adInteger, adParamInput,, Validation_Condition_Type_ID)
                                cmd.Parameters.Append cmd.CreateParameter("@Condition_Ordinal", adInteger, adParamInput,, Condition_Ordinal)
                                cmd.Parameters.Append cmd.CreateParameter("@Field1", adInteger, adParamInput)
                                cmd.Parameters.Append cmd.CreateParameter("@Field2", adInteger, adParamInput)
                                cmd.Parameters.Append cmd.CreateParameter("@Field3", adInteger, adParamInput)
                                cmd.Parameters.Append cmd.CreateParameter("@Value1", adVarChar, adParamInput, 255)
                                cmd.Parameters.Append cmd.CreateParameter("@Value2", adVarChar, adParamInput, 255)
                                cmd.Parameters.Append cmd.CreateParameter("@Value3", adVarChar, adParamInput, 255)
                                cmd.Parameters.Append cmd.CreateParameter("@Operator", adVarChar, adParamInput, 20)
                                cmd.Parameters.Append cmd.CreateParameter("@Conjunction", adVarChar, adParamInput, 3)
                                
                                if condition.getElementsByTagName("field1").length > 0 then
                                    if isnumeric(condition.getElementsByTagName("field1")(0).text) then
                                        Field1 = SmartValues(condition.getElementsByTagName("field1")(0).text, "Integer")
                                        if Field1 > 0 then
                                            cmd.Parameters("@Field1").Value = Field1
                                        end if
                                    end if
                                end if
                                if condition.getElementsByTagName("field2").length > 0 then
                                    if isnumeric(condition.getElementsByTagName("field2")(0).text) then
                                        Field2 = SmartValues(condition.getElementsByTagName("field2")(0).text, "Integer")
                                        if Field2 > 0 then
                                            cmd.Parameters("@Field2").Value = Field2
                                        end if
                                    end if
                                end if
                                if condition.getElementsByTagName("field3").length > 0 then
                                    if isnumeric(condition.getElementsByTagName("field3")(0).text) then
                                        Field3 = SmartValues(condition.getElementsByTagName("field3")(0).text, "Integer")
                                        if Field3 > 0 then
                                            cmd.Parameters("@Field3").Value = Field3
                                        end if
                                    end if
                                end if
                                if condition.getElementsByTagName("value1").length > 0 then
                                    if condition.getElementsByTagName("value1")(0).text <> "" then
                                        cmd.Parameters("@Value1").Value = condition.getElementsByTagName("value1")(0).text
                                    end if
                                end if
                                if condition.getElementsByTagName("value2").length > 0 then
                                    if condition.getElementsByTagName("value2")(0).text <> "" then
                                        cmd.Parameters("@Value2").Value = condition.getElementsByTagName("value2")(0).text
                                    end if
                                end if
                                if condition.getElementsByTagName("value3").length > 0 then
                                    if condition.getElementsByTagName("value3")(0).text <> "" then
                                        cmd.Parameters("@Value3").Value = condition.getElementsByTagName("value3")(0).text
                                    end if
                                end if
                                if condition.getElementsByTagName("operator").length > 0 then
                                    if condition.getElementsByTagName("operator")(0).text <> "" then
                                        cmd.Parameters("@Operator").Value = condition.getElementsByTagName("operator")(0).text
                                    end if
                                end if
                                if condition.getElementsByTagName("conjunction").length > 0 then
                                    cmd.Parameters("@Conjunction").Value = condition.getElementsByTagName("conjunction")(0).text
                                end if
                                
                                cmd.Execute
                                
                            end if
                        next
                    end if
                next 
            end if
        next
    end if
next

' ******************************************************************
' CLEAN UP
' ******************************************************************
Set xmlDoc = Nothing

' ******************************************************************
' finish !!
' ******************************************************************

if conn.Errors.Count < 1 and Err.number < 1 then
	conn.CommitTrans
	Session.Value("VALIDATIONRULE_SAVE_SUCCESS") = "1"
	
	ActivityLog.Reference_ID = ruleID
	
	if boolIsNew then
		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created New Validation Rule " & Validation_Rule
	else
		ActivityLog.Activity_Type = ActivityType.Modify_ID
		ActivityLog.Activity_Summary = "Modified Validation Rule " & Validation_Rule
	end if
	
	ActivityLog.Save
	
else
	conn.RollbackTrans
	Session.Value("VALIDATIONRULE_SAVE_SUCCESS") = "0"
end if

Set ActivityLog				= Nothing
Set ActivityType			= Nothing
Set ActivityReferenceType	= Nothing

' ******************************************************************
' clean up
' ******************************************************************
Call DB_CleanUp

Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

	if rs.State <> adStateClosed then
		On Error Resume Next
		rs.Close
	end if
	if conn.State <> adStateClosed then
		On Error Resume Next
		conn.Close
	end if
	Set rs = Nothing
	Set conn = Nothing
End Sub

if CBool(Session.Value("VALIDATIONRULE_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "rule_details_work_finish.asp";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("VALIDATIONRULE_SAVE_SUCCESS") = ""
'Response.Write "TEST": Response.End
%>
