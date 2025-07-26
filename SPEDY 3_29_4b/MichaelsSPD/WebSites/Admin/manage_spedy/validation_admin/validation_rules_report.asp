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
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("tid"), 0)


Dim recordID, ruleID, boolIsNew
Dim winTitle
Dim objConn, objConn2, objRec, objRec2, SQLStr, connStr, i, rowcolor
Dim thisUserID
thisUserID = SmartValues(Session.Value("UserID"), "Integer")

' Validation_Documents
Dim Workflow_ID, Workflow_Name, Metadata_Table_ID, Validation_Document

' Validation_Rules
Dim Validation_Document_ID, Validation_Rule, Metadata_Column_ID, Metadata_Column_Display_Name, Validation_Rule_Type_ID, Enabled
Dim ruleCount : ruleCount = 0

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
Dim Validation_Condition_Set_Num
Dim Validation_Condition_Set_ID, Set_Ordinal, Error_Text, Validation_Rule_Severity_ID

' Validation_Condition_Set_Stages
Dim SPD_Workflow_Stage_ID

' Validation_Conditions
Dim Validation_Condition_ID, Validation_Condition_Type_ID, Condition_Ordinal, Field1, Field2, Field3, Value1, Value2, Value3, Operator, Conjunction
Dim conditionText


Dim Current_Date
Current_Date = Now()

' Startup Scripts
Dim startupScripts
startupScripts = ""


Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols

Set dictDetailsDataCols	= Server.CreateObject("Scripting.Dictionary")

recordID = checkQueryID(Request("tid"), 0)
' response.Write(recordID & "   " & fieldID & "<br />")

Set objConn = Server.CreateObject("ADODB.Connection")
Set objConn2 = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr
objConn2.Open connStr

if recordID > 0 then
	SQLStr = "usp_Validation_Docs_GetRecord " & recordID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
	    Workflow_ID = SmartValues(objRec("Workflow_ID"), "Integer")
	    Workflow_Name = SmartValues(objRec("Workflow_Name"), "String")
	    Metadata_Table_ID = SmartValues(objRec("Metadata_Table_ID"), "Integer")
	    Validation_Document = SmartValues(objRec("Validation_Document"), "String")
	end if
	objRec.Close
end if
							            

Call returnDataWithGetRows(connStr, "SELECT r.*, isnull(c.Display_Name, '') as Metadata_Column_Display_Name FROM Validation_Rules r LEFT OUTER JOIN SPD_Metadata_Column c ON r.Metadata_Column_ID = c.[ID] WHERE r.[Validation_Document_ID] = " & recordID, arDetailsDataRows, dictDetailsDataCols)

%>
<html>
<head>
<title>Validation Report - <%=Validation_Document%></title>
<style type="text/css">

a {text-decoration: none; cursor: hand; color: #4444ff;}
a:hover {text-decoration: underline; cursor: hand;}
body
{
	scrollbar-face-color: "#cccccc"; 
	scrollbar-highlight-color: "#ffffff"; 
	scrollbar-shadow: "#999999";
	scrollbar-3dlight-color: "#cccccc"; 
	scrollbar-arrow-color: "#000000";
	scrollbar-track-color: "#ececec";
	scrollbar-darkshadow-color: "#000000";
	cursor: default;
	font-family: Arial, Verdana, Geneva, Helvetica;
	font-size: 10px;
	margin: 0;
	padding: 0;
}
div, a, td, th, span
{   
    font-family: Arial, Helvetica, Sans-Serif;
	font-size: 10px;
	line-height: 14px;
}
.bodyText
{
	font-family: Arial, Helvetica, Sans-Serif;
	font-size: 10px;
	line-height: 18px;
	color: #000;
}
.formLabel
{
    padding-left: 4px;
    padding-right: 4px;
    text-align: right;
    width: 80px;
    font-weight: bold;
}
.formLabel2
{
    padding-left: 4px;
    padding-right: 4px;
    font-weight: bold;
}
fieldset
{
    font-family: Arial, Helvetica, Sans-Serif;
	font-size: 12px;
	color: #000;
	border-color: #eeeeee;
	/*border: 1px solid #eeeeee;*/
	margin-top: 20px;
	margin-bottom: 10px;
	margin-right: 20px;
}
legend
{
    font-family: Arial, Helvetica, Sans-Serif;
	font-size: 12px;
	font-weight: bold;
	color: #777777;
	/*background: #eeeeee;
	border: 1px solid #eeeeee;*/
	padding: 1px 4px;
}
.header
{
    font-size: 12px;
    line-height: 18px;
}
.ruleHeader
{
    padding: 5px 3px 5px 3px;
    background-color: #aaaaaa;
    color: #ffff77; /*#FFFF99;*/
    font-weight: bold;
    font-size: 12px;
    border-bottom-style: solid;
    border-bottom-width: 1px;
    border-bottom-color: #000;
    border-top-style: solid;
    border-top-width: 1px;
    border-top-color: #000;
}
.conditionSet
{
    padding: 4px 3px 4px 3px;
    background-color: #cecece;
    color: #000;
    font-weight: bold;
    font-size: 11px;
}
.conditionSetDetails
{
    border-bottom-style: solid;
    border-bottom-width: 1px;
    border-bottom-color: #fff;
}
.uline
{
    text-decoration: underline;
}
.enabledText
{
    color: #FFFFCC;
}
.disabledText
{
    color: #cccccc;
}
</style>
<script language="javascript" type="text/javascript">
<!--

//-->
</script>
</head>
<body  onload="" style="margin-top: 0px; margin-left: 5px; margin-right: 5px; margin-bottom: 5px;">


<!-- HEADER -->
<div>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="100%" valign="top" style="width: 100%;">
		    <table width="100%" cellpadding="0" cellspacing="0" border="0">
		        <tr><td colspan="2">&nbsp;</td></tr>
		        <tr>
		            <td valign="bottom" class="header">
		                <h3 style="margin-bottom: 5px;">Validation Report</h3>
		                <b>Workflow: </b><%=Workflow_Name %><br />
		                <b>Document: </b><%=Validation_Document %>
		            </td>
		            <td valign="bottom" align="right" class="header">
		                <b>Date: </b><%=Current_Date%>&nbsp; 
		            </td>
		        </tr>
		        <tr><td colspan="2"><hr size="2" style="color: #000;" /></td></tr>
		    </table>
		</td>
	</tr>
</table>
</div>


<!-- BODY -->
<div>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="100%" valign="top" style="width: 100%;">
		    <table width="100%" cellpadding="0" cellspacing="0" border="0">
<%
    for rowCounter = 0 to dictDetailsDataCols("RecordCount") - 1
        ruleCount = ruleCount + 1
        ruleID = SmartValues(arDetailsDataRows(dictDetailsDataCols("ID"), rowCounter), "Integer")
        Validation_Document_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("Validation_Document_ID"), rowCounter), "Integer")
		Validation_Rule = SmartValues(arDetailsDataRows(dictDetailsDataCols("Validation_Rule"), rowCounter), "String")
		Metadata_Column_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("Metadata_Column_ID"), rowCounter), "Integer")
		Metadata_Column_Display_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("Metadata_Column_Display_Name"), rowCounter), "String")
		Enabled = SmartValues(arDetailsDataRows(dictDetailsDataCols("Enabled"), rowCounter), "Boolean")
%>
		        <tr><td colspan="3"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
		            <td class="ruleHeader" width="33%" style="width: 40%;"><span class="">RULE</span>: &nbsp;<%=Validation_Rule %></td>
		            <td class="ruleHeader" width="34%" style="width: 40%;"><span class="">FIELD</span>: &nbsp;<%=Metadata_Column_Display_Name %></td>
		            <td class="ruleHeader" width="33%" style="width: 20%;" align="right" valign="bottom"><span style="font-size: smaller;"><%if Enabled then%><span class="enabledText">[ENABLED]</span><%else%><span class="disabledText">[DISABLED]</span><%end if%></span></td>
		        </tr></table></td></tr>
<%
        ' load condition sets
        Validation_Condition_Set_Num = 0
        SQLStr = "usp_Validation_GetConditionSetList " & ruleID
        set objRec = Nothing
        set objRec = Server.CreateObject("ADODB.RecordSet")
        objRec.Open SQLStr, objConn2, adOpenStatic, adLockReadOnly, adCmdText
        do while not objRec.EOF
            Validation_Condition_Set_Num = Validation_Condition_Set_Num + 1
            Validation_Condition_Set_ID = checkQueryID(objRec("ID"), 0)
            Validation_Rule_Type_ID = SmartValues(objRec("Validation_Rule_Type_ID"), "Integer")
            Validation_Rule_Severity_ID = SmartValues(objRec("Validation_Rule_Severity_ID"), "Integer")
            Error_Text = SmartValues(objRec("Error_Text"), "String")
%>
		        <tr>
		            <td class="conditionSet" style="white-space: nowrap;" valign="top">
		                <span class="uline"><b>Condition Set #<%=Validation_Condition_Set_Num %></b></span> &nbsp;&nbsp;&nbsp; 
		            </td>
		            <td class="conditionSet" style="white-space: nowrap;" valign="top">
		                <b><span class="">Type</span>: &nbsp;</b> 
		                <%
		                select case Validation_Rule_Type_ID
		                    case 2
		                        Response.Write "Required Field"
		                    case 3
		                        Response.Write "Valid Field"
		                    case 4
		                        Response.Write "Valid Range"
		                    case else
		                        Response.Write "Custom"
		                end select
		                %>
		                 &nbsp;[<%
		                select case Validation_Rule_Severity_ID
		                    case 1
		                        Response.Write "Error"
		                    case 2
		                        Response.Write "Warning"
		                    case 3
		                        Response.Write "Information"
		                end select
		                  %>] &nbsp;&nbsp;&nbsp; 
		            </td>
		            <td class="conditionSet">
		                <b><span class="">Error Text</span>: &nbsp;</b> &lt;FIELD_NAME&gt; 
		                <%
		                select case Validation_Rule_Type_ID
		                    case 2
		                        Response.Write "is a required field."
		                    case 3
		                        Response.Write "is not valid."
		                    case 4
		                        Response.Write "must be between {VALUE 1} and {VALUE 1}."
		                    case else
		                        Response.Write Server.HtmlEncode(Error_Text)
		                end select
		                %>
		                
		            </td>
		        </tr>
		        
		        <tr>
		            <td colspan="3" class="conditionSetDetails">
		                <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color: #cecece;">
		                    <tr>
		                        <td>
		                            <table width="100%" cellpadding="3" cellspacing="1" border="0">
		                                <tr style="background-color: #ffffff;" valign="top">
		                                    <td align="left"><span style="font-weight: bold;"><span class="uline">Conditions</span>:</span></td>
		                                    <td align="left" width="250" style="width: 250px;"><span style="font-weight: bold;"><span class="uline">Stages</span>:</span></td>
		                                </tr>
		                                
		                                <tr style="background-color: #ffffff;" valign="top">
		                                    <td>
<%
            ' *****************************************************
            ' CONDITIONS
            ' *****************************************************
            ' conditions
            objRec2.Open "select c.*, isnull(mc1.Display_Name, '') as Field1_Name, isnull(mc2.Display_Name, '') as Field2_Name, isnull(mc3.Display_Name, '') as Field3_Name from Validation_Conditions c left outer join SPD_Metadata_Column mc1 on c.Field1 = mc1.[ID] left outer join SPD_Metadata_Column mc2 on c.Field2 = mc2.[ID] left outer join SPD_Metadata_Column mc3 on c.Field3 = mc3.[ID] where c.Validation_Condition_Set_ID = " & Validation_Condition_Set_ID, objConn, adOpenStatic, adLockReadOnly, adCmdText
            conditionText = ""
            
            do while not objRec2.EOF
                if conditionText <> "" then
                    conditionText = conditionText & " &nbsp; [" & UCase(Conjunction) & "]&nbsp;<br />"
                end if
                Validation_Condition_Type_ID = SmartValues(objRec2("Validation_Condition_Type_ID"), "Integer")
                Field1 = Server.HtmlEncode("""" & SmartValues(objRec2("Field1_Name"), "String") & """")
                Field2 = Server.HtmlEncode("""" & SmartValues(objRec2("Field2_Name"), "String") & """")
                Field3 = Server.HtmlEncode("""" & SmartValues(objRec2("Field3_Name"), "String") & """")
                Value1 = Server.HtmlEncode(SmartValues(objRec2("Value1"), "String"))
                Value2 = Server.HtmlEncode(SmartValues(objRec2("Value2"), "String"))
                Value3 = Server.HtmlEncode(SmartValues(objRec2("Value3"), "String"))
                Operator = Server.HtmlEncode(SmartValues(objRec2("Operator"), "String"))
                Conjunction = SmartValues(objRec2("Conjunction"), "String")
                
                select case Validation_Condition_Type_ID
                    case 1
                        ' Alphabetic
                        conditionText = conditionText & "if " & Field1 & " is not <strong>Alphabetic</strong>"
                        
                    case 2
                        ' Alphanumeric
                        conditionText = conditionText & "if " & Field1 & " is not <strong>Alphanumeric</strong>"
                        
                    case 3
                        ' Divisible by (Field/Field)
                        conditionText = conditionText & "if " & Field1 & " is not <strong>Divisible by</strong> " & Field2
                        
                    case 4
                        ' Divisible by (Field/#)
                        conditionText = conditionText & "if " & Field1 & " is not <strong>Divisible by</strong> " & Value1
                        
                    case 5
                        ' Empty
                        conditionText = conditionText & "if " & Field1 & " is <strong>Empty</strong>"
                        
                    case 6
                        ' Not Empty
                        conditionText = conditionText & "if " & Field1 & " is <strong>Not Empty</strong>"
                        
                    case 7
                        ' General (Field/Field)
                        conditionText = conditionText & "" & Field1 & " " & Operator & " " & Field2
                        
                    case 8
                        ' General (Field/value)
                        conditionText = conditionText & "" & Field1 & " " & Operator & " " & Value1
                        
                    case 9
                        ' Length
                        conditionText = conditionText & "if <strong>Length</strong> of " & Field1 & " " & Operator & " " & Value1
                        
                    case 10
                        ' Lookup - Batch Departments
                        conditionText = conditionText & "if <strong>Lookup - Batch Departments</strong> fails"
                        
                    case 11
                        ' Lookup - Batch Vendors
                        conditionText = conditionText & "if <strong>Lookup - Batch Vendors</strong> fails"
                        
                    case 12
                        ' Lookup - UPC Validation*
                        conditionText = conditionText & "if <strong>Lookup - UPC Validation*</strong> fails"
                        
                    case 13
                        ' Lookup - Valid Class
                        conditionText = conditionText & "if <strong>Lookup - Valid Class</strong> fails"
                        
                    case 14
                        ' Lookup - Valid Country of Origin
                        conditionText = conditionText & "if <strong>Lookup - Valid Country of Origin</strong> fails"
                        
                    case 15
                        ' Lookup - Valid Department
                        conditionText = conditionText & "if <strong>Lookup - Valid Department</strong> fails"
                        
                    case 16
                        ' Lookup - Valid Sub-Class
                        conditionText = conditionText & "if <strong>Lookup - Valid Sub-Class</strong> fails"
                        
                    case 17
                        ' Lookup - Valid Tax Value UDA
                        conditionText = conditionText & "if <strong>Lookup - Valid Tax Value UDA</strong> fails"
                        
                    case 18
                        ' Lookup - Valid Vendor # (US)
                        conditionText = conditionText & "if <strong>Lookup - Valid Vendor # (US)</strong> fails"
                        
                    case 19
                        ' Lookup - Valid Vendor # (Canadian)
                        conditionText = conditionText & "if <strong>Lookup - Valid Vendor # (Canadian)</strong> fails"
                        
                    case 20
                        ' Range
                        conditionText = conditionText & "if " & Field1 & " " & _ 
                            " not in <strong>Range</strong>: " & _  
                            Value1 & _ 
                            " - " & _ 
                            Value2
                        
                    case 21
                        ' Required Field
                        conditionText = conditionText & "<strong>Required Field</strong>: " & Field1
                        
                    case 22
                        ' Valid Characters
                        conditionText = conditionText & "if " & Field1 & " " & _ 
                            " does not have only <strong>Valid Characters</strong>: " & _ 
                            Value1
                        
                    case 23
                        ' Invalid Characters
                        conditionText = conditionText & "if " & Field1 & " " & _ 
                            " has <strong>Invalid Characters</strong>: " & _
                            Value1
                        
                    case 24
                        ' Valid Field (type)
                        conditionText = conditionText & "if " & Field1 & " " & _ 
                            " does not have a <strong>Valid Field</strong> value "
                        
                    case 25
                        ' Valid UPC
                        conditionText = conditionText & "if " & Field1 & " " & _
                            " is not a <strong>Valid UPC</strong> "
                        
                    case 26
                        ' Value In
                        conditionText = conditionText & "if " & Field1 & " " & _ 
                            " has <strong>Value In</strong>: " & _ 
                            Value1
                        
                    case 27
                        ' Value Not In
                        conditionText = conditionText & "if " & Field1 & " " & _ 
                            " has <strong>Value Not In</strong>: " & _ 
                            Value1
                        
                    case 28
                        ' * End Validation *
                        conditionText = conditionText & "<strong>End Validation</strong> if this is the only condition or if condition set fails."
                        
                    case 29
                        ' Lookup - Valid Vendor #
                        conditionText = conditionText & "if <strong>Lookup - Valid Vendor #</strong> fails"
                        
                    case 30
                        ' Empty (After Removing)
                        conditionText = conditionText & "if " & Field1 & " " & _ 
                            " is <strong>Empty</strong> after removing " & _ 
                            Value1
                        
                    case 31
                        ' Lookup - Batch D/DP Validation
                        conditionText = conditionText & "if <strong>Lookup - Batch D/DP Validation*</strong> fails"
                        
                    case 32
                        ' Changes - General (Original Field/Value)
                        conditionText = conditionText & "Original " & Field1 & " " & Operator & " " & Value1
                    
                    case 33
                        ' Changes - General (Changed Field/Value)
                        conditionText = conditionText & "Changed " & Field1 & " " & Operator & " " & Value1
                        
                    case 34
                        ' Lookup - Pack Item Validation
                        conditionText = conditionText & "if <strong>Lookup - Pack Item Validation*</strong> fails"
                        
                    case else
                        conditionText = conditionText & "<b>ERROR: Tried to create a condition of an unknown type (" & Validation_Condition_Type_ID & ").</b>"
                        
                end select
                
                objRec2.MoveNext ' Validation_Conditions
            loop
            objRec2.Close
            Response.Write conditionText
%>
		                                    </td>
		                                    <td><div style="width: 250px">
<%
            ' *****************************************************
            ' STAGES
            ' *****************************************************
            objRec2.Open "select css.*, ws.stage_name from Validation_Condition_Set_Stages css inner join SPD_Workflow_Stage ws on css.SPD_Workflow_Stage_ID = ws.[id] where css.Validation_Condition_Set_ID = " & Validation_Condition_Set_ID, objConn, adOpenStatic, adLockReadOnly, adCmdText
            Stage_Name = ""
            do while not objRec2.EOF
                if Stage_Name <> "" then Stage_Name = Stage_Name & ", " end if
                Stage_Name = Stage_Name & SmartValues(objRec2("stage_name"), "String")
                objRec2.MoveNext ' Validation_Condition_Set_Stages
            loop
            objRec2.Close
            Response.Write Stage_Name
%>
		                                    </div></td>
		                                </tr>
		                                
		                            </table>
		                        </td>
		                    </tr>
		                </table>
		            </td>
		        </tr>
<%
            objRec.MoveNext ' Validation_Condition_Sets
        loop
%>
		        <tr>
		            <td colspan="3" class="">&nbsp;</td>
		        </tr>
<%
    next
%>
		        
		    </table>
		</td>
	</tr>
</table>
</div>


<!-- FOOTER -->
<div>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="100%" valign="top" style="width: 100%;">
		    <table width="100%" cellpadding="0" cellspacing="0" border="0">
		        <tr><td colspan="2"><hr size="1" style="color: #000;" /></td></tr>
		        <tr><td colspan="2">Number of Rules: &nbsp; <%=ruleCount %></td></tr>
		        <tr><td colspan="2">&nbsp;</td></tr>
		    </table>
		</td>
	</tr>
</table>
</div>
<%

%>
<script language="javascript" type="text/javascript">
	<!--
		
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
	if objConn2.State <> adStateClosed then
		On Error Resume Next
		objConn2.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec2 = Nothing
	Set objRec = Nothing
	Set objConn2 = Nothing
	Set objConn = Nothing
End Sub

Set arDetailsDataRows = Nothing
Set dictDetailsDataCols = Nothing
%>