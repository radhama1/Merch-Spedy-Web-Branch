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
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("rid"), 0)

Dim recordID, ruleID, boolIsNew
Dim winTitle
Dim objConn, objRec, objRec2, SQLStr, connStr, i, rowcolor
Dim thisUserID
thisUserID = SmartValues(Session.Value("UserID"), "Integer")
' Validation_Documents
Dim Workflow_ID, Workflow_Name, Metadata_Table_ID, Validation_Document, Allow_Changes
Allow_Changes = False
' Validation_Rules
Dim Validation_Document_ID, Validation_Rule, Metadata_Column_ID, Validation_Rule_Type_ID, Enabled
' SPD_Metadata_Column lookup
Dim Column_ID, Column_Name, Display_Name, Parent_ID, Parent_Display_Name
' Validation_Rule_Types
Dim Rule_Type_ID, Rule_Type
' Validation_Rule_Severity
Dim Severity_ID, Severity
' Validation_Rule_Types
Dim Condition_Type_ID, Condition_Type
' SPD_Workflow_Stage lookup
Dim Stage_ID, Stage_Name

' Validation_Condition_Sets
Dim Validation_Condition_Set_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID
' Validation_Condition_Set_Stages
Dim SPD_Workflow_Stage_ID
' Validation_Conditions
Dim Validation_Condition_ID, Validation_Condition_Type_ID, Condition_Ordinal, Field1, Field2, Field3, Value1, Value2, Value3, Operator, Conjunction


' Startup Scripts
Dim startupScripts
startupScripts = ""


Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols

Set dictDetailsDataCols	= Server.CreateObject("Scripting.Dictionary")

recordID = checkQueryID(Request("tid"), 0)
ruleID = checkQueryID(Request("rid"), 0)
' response.Write(recordID & "   " & fieldID & "<br />")

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if recordID > 0 then
	SQLStr = "usp_Validation_Docs_GetRecord " & recordID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
	    Workflow_ID = SmartValues(objRec("Workflow_ID"), "Integer")
	    Workflow_Name = SmartValues(objRec("Workflow_Name"), "String")
	    Metadata_Table_ID = SmartValues(objRec("Metadata_Table_ID"), "Integer")
	    Validation_Document = SmartValues(objRec("Validation_Document"), "String")
	    Allow_Changes = SmartValues(objRec("Allow_Changes"), "Boolean")
	end if
	objRec.Close
end if


'***************************************************
' COLUMNS (FOR THIS TABLE [AND PARENT])
'***************************************************
Dim fields, parentFields

fields = ""
parentFields = ""

if Metadata_Table_ID > 0 then
    SQLStr = "select * from SPD_Metadata_Column where Metadata_Table_ID = " & Metadata_Table_ID & " and isnull(Enabled, 0) = 1 and isnull(Validation_Enabled, 0) = 1 order by Display_Name"
    objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
    do while not objRec.EOF
        Column_ID = SmartValues(objRec("ID"), "Integer")
        Display_Name = SmartValues(objRec("Display_Name"), "String")
        if fields <> "" then fields = fields & "," end if
        fields = fields & Column_ID & "," & Replace(Display_Name, "'", "\'")
        objRec.MoveNext
    loop
    objRec.Close
    
    parentFields = fields
    
    SQLStr = "select t.ID, t.Display_Name from SPD_Metadata_Table t inner join SPD_Metadata_Table_Relationship tr on t.ID = tr.Parent_Table_ID where tr.Child_Table_ID = " & Metadata_Table_ID & " order by t.Table_Name"
    objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
    if not objRec.EOF then
        Parent_ID = SmartValues(objRec("ID"), "Integer")
        Parent_Display_Name = SmartValues(objRec("Display_Name"), "String")
    else
        Parent_ID = 0
    end if
    objRec.Close
    
    if Parent_ID > 0 then
        SQLStr = "select * from SPD_Metadata_Column where Metadata_Table_ID = " & Parent_ID & " and isnull(Enabled, 0) = 1 and isnull(Validation_Enabled, 0) = 1 order by Display_Name"
        objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
        do while not objRec.EOF
            Column_ID = SmartValues(objRec("ID"), "Integer")
            Display_Name = SmartValues(objRec("Display_Name"), "String")
            if parentFields <> "" then parentFields = parentFields & "," end if
            parentFields = parentFields & Column_ID & "," & "[" & Replace(Parent_Display_Name, "'", "\'") & "] - " & Replace(Display_Name, "'", "\'")
            'parentFields = parentFields & Column_ID & "," & "[Parent] - " & Replace(Display_Name, "'", "\'")
            objRec.MoveNext
        loop
        objRec.Close
    end if
end if

'***************************************************
' WORKFLOW STAGES ([id,name,...])
'***************************************************
Dim stages
stages = ""
SQLStr = "select * from SPD_Workflow_Stage where ISNULL([Enabled], 0) = 1 and [workflow_id] = " & Workflow_ID & " order by [sequence]"
objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
do while not objRec.EOF
    Stage_ID = SmartValues(objRec("id"), "Integer")
    Stage_Name = SmartValues(objRec("Stage_Name"), "String")
    if stages <> "" then stages = stages & "," end if
    stages = stages & Stage_ID & "," & Replace(Stage_Name, "'", "\'")
    objRec.MoveNext
loop
objRec.Close

'***************************************************
' RULE TYPES ([id,name,...])
'***************************************************
Dim ruleTypes
ruleTypes = ""
if Metadata_Table_ID > 0 then
    SQLStr = "select * from Validation_Rule_Types order by Rule_Type"
    objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
    do while not objRec.EOF
        Rule_Type_ID = SmartValues(objRec("ID"), "Integer")
        Rule_Type = SmartValues(objRec("Rule_Type"), "String")
        if ruleTypes <> "" then ruleTypes = ruleTypes & "," end if
        ruleTypes = ruleTypes & Rule_Type_ID & "," & Replace(Rule_Type, "'", "\'")
        objRec.MoveNext
    loop
    objRec.Close
end if

'***************************************************
' SEVERITY TYPES ([id,name,...])
'***************************************************
Dim severityTypes
severityTypes = ""
if Metadata_Table_ID > 0 then
    SQLStr = "select * from Validation_Rule_Severity where [Enabled] = 1 order by Severity"
    objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
    do while not objRec.EOF
        Severity_ID = SmartValues(objRec("ID"), "Integer")
        Severity = SmartValues(objRec("Severity"), "String")
        if severityTypes <> "" then severityTypes = severityTypes & "," end if
        severityTypes = severityTypes & Severity_ID & "," & Replace(Severity, "'", "\'")
        objRec.MoveNext
    loop
    objRec.Close
end if

'***************************************************
' CONDITION TYPES ([id,name,...])
'***************************************************
Dim conditionTypes
conditionTypes = ""
Dim filterForChanges
if Allow_Changes then
    filterForChanges = ""
else
    filterForChanges = " and ISNULL(IsChange, 0) = 0"
end if
if Metadata_Table_ID > 0 then
    SQLStr = "select [ID], [Condition] from Validation_Condition_Types where ISNULL([Enabled], 0) = 1" & filterForChanges & " order by Sort_Order"
    objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
    do while not objRec.EOF
        Condition_Type_ID = SmartValues(objRec("ID"), "Integer")
        Condition_Type = SmartValues(objRec("Condition"), "String")
        if conditionTypes <> "" then conditionTypes = conditionTypes & "," end if
        conditionTypes = conditionTypes & Condition_Type_ID & "," & Replace(Condition_Type, "'", "\'")
        objRec.MoveNext
    loop
    objRec.Close
end if
									            


if ruleID = 0 then
	boolIsNew = true
else
	boolIsNew = false

	Call returnDataWithGetRows(connStr, "SELECT * FROM Validation_Rules WHERE [ID] = " & ruleID, arDetailsDataRows, dictDetailsDataCols)
end if

%>
<html>
<head>
<title><%if boolIsNew then%>Add Rule<%else%>Edit Rule<%end if%></title>
<link type="text/css" rel="stylesheet" href="./rule_details.css" />
<script language="javascript" type="text/javascript" src="./../../app_include/prototype.js"></script>
<script language="javascript" type="text/javascript" src="./../../app_include/scriptaculous.js?load=effects,dragdrop"></script>
<script language="javascript" type="text/javascript" src="./rule_details.js"></script>
<script language="javascript" type="text/javascript">
<!--
// setup vars
isNew = <% if boolIsNew then Response.Write "true" else Response.Write "false" end if %>;
fields = parseList2('<%=Replace(fields, "\", "\\")%>');
parentFields = parseList2('<%=Replace(parentFields, "\", "\\")%>');
stages = parseList2('<%=Replace(stages, "\", "\\")%>');
ruleTypes = parseList2('<%=Replace(ruleTypes, "\", "\\")%>');
severityTypes = parseList2('<%=Replace(severityTypes, "\", "\\")%>');
conditionTypes = parseList2('<%=Replace(conditionTypes, "\", "\\")%>');
//-->
</script>
</head>
<body bgcolor="#cccccc" onload="">
<form id="theForm" name="theForm" action="rule_details_work.asp" method="post">
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr bgcolor="#cccccc">
		<td bgcolor="#cccccc" width="100%" valign="top" style="width: 100%;">
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				Validation_Document_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("Validation_Document_ID"), 0), "Integer")
				Validation_Rule = SmartValues(arDetailsDataRows(dictDetailsDataCols("Validation_Rule"), 0), "String")
				Metadata_Column_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("Metadata_Column_ID"), 0), "Integer")
				Validation_Rule_Type_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("Validation_Rule_Type_ID"), 0), "Integer")
				Enabled = SmartValues(arDetailsDataRows(dictDetailsDataCols("Enabled"), 0), "Boolean")
			else
			    Validation_Rule = ""
			    Metadata_Column_ID = 0
			    Enabled = True
			end if
			%>
			<div id="rule_description" name="rule_description" style="display:none">
				<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr>
						<td><img src="./../images/spacer.gif" height="1" width="20" border="0" alt="" /></td>
						<td nowrap="nowrap" width="100%" valign="top">
						    <div id="rule_info">
						        <fieldset>
						        <table border="0" cellpadding="0" cellspacing="0">
						        <tr>
						        <td width="50%" style="width: 50%" valign="top">
							    <table border="0" cellpadding="0" cellspacing="0">
								    <tr><td colspan="4"><img src="./../images/spacer.gif" height="15" width="1" border="0" alt="" /></td></tr>
								    <tr>
									    <td class="bodyText formLabel"><img src="./../images/spacer.gif" id="ValidationRuleWarningImg" style="margin-right: 1px;" />Rule</td>
									    <td class="formField"><input type="text" size="50" maxlength="255" style="width: 250px;" id="Validation_Rule" name="Validation_Rule" value="<%=Validation_Rule%>" AutoComplete="off" /></td>
									    <td class="bodyText formLabel">Workflow:</td>
									    <td class="formField"><%=Workflow_Name%></td>
								    </tr>
								    <tr><td colspan="4"><img src="./../images/spacer.gif" height="5" width="1" border="0" alt="" /></td></tr>
								    <tr>
									    <td class="bodyText formLabel"><img src="./../images/spacer.gif" id="MetadataColumnIDWarningImg" style="margin-right: 1px;" />Field</td>
									    <td class="formField">
									        <select id="Metadata_Column_ID" name="Metadata_Column_ID" onchange="fieldChanged();">
									            <option value="">--Select--</option>
									            <%
									            if Metadata_Table_ID > 0 then
									                SQLStr = "select * from SPD_Metadata_Column where Metadata_Table_ID = " & Metadata_Table_ID & " order by Display_Name"
                                                    objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
                                                    do while not objRec.EOF
                                                        Column_ID = SmartValues(objRec("ID"), "Integer")
                                                        Display_Name = SmartValues(objRec("Display_Name"), "String")
									            %>
									            <option value="<%=Column_ID%>"<%if Column_ID = Metadata_Column_ID then Response.Write(" selected=""selected""") end if%>><%=Display_Name%></option>
									            <%
									                    objRec.MoveNext
									                loop
									                objRec.Close
									            end if
									            %>
									        </select>
									    </td>
									    <td class="bodyText formLabel">Document:</td>
									    <td class="formField"><%=Validation_Document%></td>
								    </tr>
    								<tr><td colspan="4"><img src="./../images/spacer.gif" height="5" width="1" border="0" alt="" /></td></tr>
								    <tr>
									    <td class="bodyText formLabel"><img src="./../images/spacer.gif" id="EnabledWarningImg" />Enabled</td>
									    <td class="formField"><input type="checkbox" id="Enabled" name="Enabled" AutoComplete="off" value="1" <% if Enabled = true then Response.Write " checked=""checked""" end if  %> /></td>
									    <td class="bodyText formLabel">&nbsp;</td>
									    <td class="formField">&nbsp;</td>
								    </tr>
								    <tr><td colspan="4"><img src="./../images/spacer.gif" height="1" width="1" border="0" alt="" /></td></tr>
							    </table>
							    </td>
							    </tr>
							    </table>
							    </fieldset>
							</div>
							
							<div id="condition_sets_wrapper">
							    <div id="condition_sets"></div>
							    <div id="loading" style="text-align: center; color: #aaaaaa; font-size: 10px;"><img src="./../images/processing_lite_cccccc.gif" alt="" style="padding-left: 50%; padding-right: 50%;" /> loading...</div>
							    <div id="condition_set_template">
							    <fieldset id="condition_set_SETNUMBER" style="display: none;">
							        <legend id="condition_set_legend_SETNUMBER" class="handle"><img src="./../images/spacer.gif" id="SetSETNUMBERWarningImg" style="margin-right: 1px;" />Condition Set #<span id="condition_set_position_SETNUMBER">SETPOSITION</span></legend>
						            <div class="ruleSet">
							            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="width: 100%">
							                <tr>
							                    <td width="100%" style="width: 100%">
							                        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="width: 100%">
							                            <tr>
							                                <td class="bodyText formLabel2" nowrap="nowrap">Type</td>
							                                <td nowrap="nowrap"><select id="rule_type_SETNUMBER" onchange="Rule.ruleTypeChanged(SETNUMBER);"><option value="">--Select--</option></select></td>
							                                <td nowrap="nowrap"><select id="severity_SETNUMBER" onchange="Rule.severityChanged(SETNUMBER);"><option value="">--Select--</option></select></td>
							                                <td class="bodyText formLabel2" nowrap="nowrap"><span id="error_text_label_SETNUMBER">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Error Text&nbsp;&nbsp;&nbsp;<span style="color: #777777;">&lt;FIELD NAME&gt;</span></span></td>
							                                <td valign="middle" style="vertical-align: middle; line-height: 24px; height: 24px;" nowrap="nowrap">
							                                    <span id="error_text_control_SETNUMBER" style="width: 315px;">
							                                    <input id="error_text_SETNUMBER" maxlength="255" size="70" value="" style="width: 315px;" onchange="Rule.errorTextChanged(SETNUMBER);" />
							                                    </span>
							                                    <span id="error_text_string_SETNUMBER" style="width: 315px; color: #777777; display: none;"></span>
							                                </td>
							                                <td width="25" align="right" valign="middle" style="width: 25px;"><a id="condition_set_delete_SETNUMBER" href="#" onclick="Rule.deleteConditionSet(SETNUMBER); return false;"><img src="./../images/action_x.gif" border="0" alt="" /></a></td>
							                            </tr>
							                        </table>
							                    </td>
							                </tr>
							                <tr><td><img src="./../images/spacer.gif" width="1" height="10" alt="" /></td></tr>
							                <tr>
							                    <td width="100%" style="width: 100%">
							                        <table border="0" cellpadding="0" cellspacing="0" style="background-color: #777777; width: 100%;" width="100%"><tr><td width="100%" style="width: 100%">
							                        <table border="0" cellpadding="0" cellspacing="1" width="100%" style="width: 100%">
							                            <tr style="background-color: #aaaaaa;">
							                                <td class="bodyText formLabel2" align="left" width="100%" style="width: 100%; color: #ffffff;"><img src="./../images/spacer.gif" width="1" height="1" alt="" /><br />Conditions</td>
							                                <td class="bodyText formLabel2" align="left" width="170" style="width: 170px; color: #ffffff;"><img src="./../images/spacer.gif" width="170" height="1" alt="" /><br />
							                                <table border="0" cellpadding="0" cellspacing="0" width="170"><tr><td align="left" width="90" style="width: 90px;">Stages</td><td align="right" width="80" style="width: 80px;"><a href="#" onclick="Rule.selectAllStages(SETNUMBER); return false;">select all</a></td></tr></table>
							                                </td>
							                            </tr>
							                            <tr style="background-color: #cccccc;">
							                                <td class="bodyText" valign="top">
							                                    <div id="conditions_SETNUMBER" class="conditions">
							                                        <div id="conditions_string_SETNUMBER" class="conditionstring">Please add at least one condition to this condition set.</div>
							                                    </div>
							                                    <div id="add_condition_SETNUMBER" class="addCondition"><a href="#" onclick="Rule.addCondition(SETNUMBER); return false;"><img src="./../images/icon_plus.gif" border="0" alt="add condition" /></a><a href="#" onclick="Rule.addCondition(SETNUMBER); return false;">add condition</a>&nbsp;<select id="add_condition_type_SETNUMBER" class="addConditionType"></select></div>
							                                </td>
							                                <td class="bodyText" valign="top" style="background-color: #aaaaaa;">
							                                    <div id="stages_SETNUMBER" class="stagesList"></div>
							                                    <div class="stagesDesc">Select stages for this condition set.</div>
							                                </td>
							                            </tr>
							                        </table>
							                        </td></tr></table>
							                    </td>
							                </tr>
							            </table>
							        </div>
						        </fieldset>
						        </div>
						        <div id="condition_set_add" style="display: none;">
						        <a href="#" onclick="Rule.addConditionSet(); return false;"><img src="./../images/icon_plus.gif" border="0" alt="add condition" />add condition set</a>
						        </div>
						        <div><img src="./../images/spacer.gif" height="30" width="1" border="0" alt="" /></div>
						    </div>
						</td>
						<td><img src="./../images/spacer.gif" height="1" width="10" border="0" alt="" /></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
</table>
<input type="hidden" name="tid" value="<%=recordID%>" />
<input type="hidden" name="rid" value="<%=ruleID%>" />
<input type="hidden" name="boolIsNew" value="<%=boolIsNew%>" />
<input type="hidden" id="ruleXML" name="ruleXML" value="" />
</form>
<%
if boolIsNew then
    ' add new
    startupScripts = "setTimeout('Rule.addConditionSet();', 100);"
else
    ' load form
    startupScripts = "setupMode = true;" & vbCrLf
    ' -------------------------------------------------------------------------
    ' load condition sets
    SQLStr = "usp_Validation_GetConditionSetList " & ruleID
    objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
    do while not objRec.EOF
        Validation_Condition_Set_ID = checkQueryID(objRec("ID"), 0)
        Validation_Rule_Type_ID = SmartValues(objRec("Validation_Rule_Type_ID"), "Integer")
        Validation_Rule_Severity_ID = SmartValues(objRec("Validation_Rule_Severity_ID"), "Integer")
        Error_Text = SmartValues(objRec("Error_Text"), "String")
        startupScripts = startupScripts & "oCSet = Rule.addConditionSet(" & Validation_Condition_Set_ID & ", " & Validation_Rule_Type_ID & ");" & _
            " oCSet.setErrorText('" & Replace(Replace(Error_Text, "\", "\\"), "'", "\'") & "');" & _
            " oCSet.setSeverity(" & Validation_Rule_Severity_ID & ");"
            ' stages
            objRec2.Open "select * from Validation_Condition_Set_Stages where Validation_Condition_Set_ID = " & Validation_Condition_Set_ID, objConn, adOpenStatic, adLockReadOnly, adCmdText
            do while not objRec2.EOF
                startupScripts = startupScripts & " oCSet.addStage(" & SmartValues(objRec2("SPD_Workflow_Stage_ID"), "Integer") & ", true);"
                objRec2.MoveNext ' Validation_Condition_Set_Stages
            loop
            objRec2.Close
            'startupScripts = startupScripts & " oCSet.stagesChanged();"
            ' conditions
            objRec2.Open "select * from Validation_Conditions where Validation_Condition_Set_ID = " & Validation_Condition_Set_ID, objConn, adOpenStatic, adLockReadOnly, adCmdText
            do while not objRec2.EOF
                startupScripts = startupScripts & " oC = oCSet.addCondition(" & SmartValues(objRec2("ID"), "Integer") & ", " & SmartValues(objRec2("Validation_Condition_Type_ID"), "Integer") & ", true);"
                Field1 = SmartValues(objRec2("Field1"), "Integer")
                Field2 = SmartValues(objRec2("Field2"), "Integer")
                Field3 = SmartValues(objRec2("Field3"), "Integer")
                Value1 = SmartValues(objRec2("Value1"), "String")
                Value2 = SmartValues(objRec2("Value2"), "String")
                Value3 = SmartValues(objRec2("Value3"), "String")
                Operator = SmartValues(objRec2("Operator"), "String")
                Conjunction = SmartValues(objRec2("Conjunction"), "String")
                startupScripts = startupScripts & " oC.setField1(" & Field1 & ");"
                startupScripts = startupScripts & " oC.setField2(" & Field2 & ");"
                startupScripts = startupScripts & " oC.setField3(" & Field3 & ");"
                startupScripts = startupScripts & " oC.setValue1('" & Replace(Replace(Value1, "\", "\\"), "'", "\'") & "');"
                startupScripts = startupScripts & " oC.setValue2('" & Replace(Replace(Value2, "\", "\\"), "'", "\'") & "');"
                startupScripts = startupScripts & " oC.setValue3('" & Replace(Replace(Value3, "\", "\\"), "'", "\'") & "');"
                startupScripts = startupScripts & " oC.setOperator('" & Replace(Replace(Operator, "\", "\\"), "'", "\'") & "');"
                startupScripts = startupScripts & " oC.setConjunction('" & Replace(Replace(Conjunction, "\", "\\"), "'", "\'") & "');"
                startupScripts = startupScripts & vbCrLf
                objRec2.MoveNext ' Validation_Conditions
            loop
            objRec2.Close
        objRec.MoveNext ' Validation_Condition_Sets
    loop
    objRec.Close
    startupScripts = startupScripts & "setupMode = false;" & vbCrLf
end if
%>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "rule_details_header.asp?tid=<%=recordID%>&rid=<%=ruleID%>";
		parent.frames["controls"].document.location = "rule_details_footer.asp?tid=<%=recordID%>&rid=<%=ruleID%>";
		// setup page
		initPage();
		// Init Rule !!!
        <%=startupScripts%>
        // show add condition set link;
        $('condition_set_add').show();
        // hide loading
        $('loading').hide();
	//-->
</script>

</body>
</html>

<%
Call DB_CleanUp
Sub DB_CleanUp
	if objRec2.State <> adStateClosed then
		On Error Resume Next
		objRec2.Close
	end if
	if objRec.State <> adStateClosed then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objRec = Nothing
	Set objConn = Nothing
End Sub

Set arDetailsDataRows = Nothing
Set dictDetailsDataCols = Nothing
%>