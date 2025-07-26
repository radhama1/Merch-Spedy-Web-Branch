<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
' Dec 2009 Jeff Littlefield
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("wid"), 0)

Dim recordID, fieldID, boolIsNew
Dim winTitle
Dim objConn, SQLStr, connStr, i, rowcolor
Dim thisUserID

thisUserID = SmartValues(Session.Value("UserID"), "Integer")
Dim Record_Type, Field_Name, Field_Type, Field_Limit, Field_Limit_Str, Grid, isEnabled

Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols, dictHeaderDataCols

Set dictDetailsDataCols	= Server.CreateObject("Scripting.Dictionary")   ' For Details
Set dictHeaderDataCols =  Server.CreateObject("Scripting.Dictionary")   ' for Headings

dim wfID, wfsID
dim c, r, aFieldCols, aDataRows, wfName, wfsName, numRows, numCols, colWidth, baseCol, curTableName, Col1, Col2
dim curFieldName, tblName, fieldName, userCatID, uiRow, strTemp, strTemp1, strLocked, titleID

wfID = checkQueryID(Request("wid"), 0)
wfsID = checkQueryID(Request("wfsID"), 0)
' response.Write(recordID & "   " & fieldID)

Set objConn = Server.CreateObject("ADODB.Connection")
connStr = Application.Value("connStr")
objConn.Open connStr

' response.Write(wfID & "   " & wfsID & "<br />")
if wfID > 0 and wfsID > 0 then
    ' Get Headers for columns
	SQLStr = "sp_SPD_FieldLocking_GetFieldLockingCategories " & wfID
	' Fields Returned: ID, Category
   	Call returnDataWithGetRows(connStr, SQLStr, aFieldCols, dictHeaderDataCols)  

   	if dictHeaderDataCols("RecordCount") = 0 then
        response.Write("No Column Info found for Workflow: " & wfid & "<br />" )
        response.end
	end if

    ' Get Details
	SQLStr = "sp_SPD_FieldLocking_GetFieldData " & wfid & ", " & wfsID
	' Fields Returned: FieldLockingID, WorkFlowStageID, MetaDataColumnID, FLUserCatID, WorkFlowName, WorkFlowStageName, TableName, FieldName, Locked
	Call returnDataWithGetRows(connStr, SQLStr, aDataRows, dictDetailsDataCols)

	if dictDetailsDataCols("RecordCount") = 0 then
        response.Write("No Table Info found for Workflow: " & wfid & "<br />" )
        response.end
	end if
else
' BAD record. Gracefully exit
    response.Write("Invalid Workflow specified. " & wfid & "<br />" )
    response.end
end if

' Get Page Key Info
wfName = SmartValues(aDataRows(dictDetailsDataCols("WorkFlowName"), 0), "String")
wfsName = SmartValues(aDataRows(dictDetailsDataCols("WorkFlowStageName"), 0), "String")

' figure out number of columns to display
numCols = dictHeaderDataCols("RecordCount")    ' Each row is a column
colWidth = 10
baseCol = int((100 - (numCols * colWidth)) / 2)
Col1 = 10
c = baseCol - Col1
if c < 0 then
    response.Write("Internal Error. Too many columns to display.<br />")
    response.End
end if
Col2 = baseCol + c

' Number of rows in details
numRows = dictDetailsDataCols("RecordCount")

' Init Tracking fields
curTableName = ""
curFieldName = ""
uiRow = 0

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
	<title>Field Locking</title>
	<style type="text/css">
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		BODY
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
			font-size: 11px;
		}

		.bodyText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			color: #000;
		}
	</style>
	<script language=javascript>
		var bDirty = false
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function validateForm(sRefresh) {
		    if ((bDirty) || confirm("No Records were change. Please confirm you want to SAVE.")) {
		        if (sRefresh == "1")  // Save Form
		            document.theForm.HRefresh.value = 1;
		        else                // Save and Close
		            document.theForm.HRefresh.value = 0;
			    document.theForm.submit();
			}
		}

        function SetClearCat(obj,c) {
            var iRows = document.getElementById("HuiRows").value;
            for (var i=1; i<=iRows; i++) {
                var sID = "C_" + i + "_" + c;
                var objChk = document.getElementById(sID);
                objChk.checked = obj.checked;
                UpdateCheckBox(objChk);
            }
        }
        
		function UpdateCheckBox(obj) {
		    bDirty = false;
		    var strCheckBox = new String();
		    strCheckBox = obj.id;
		    if (strCheckBox == null) {
		        alert("Internal error: Could not determine name of checkbox element.");
		        return
		    }
            var sTemp = strCheckBox.substr(0,2)
		    if ( sTemp != "C_" ) {
		        alert("Internal Error. Check box not found");
		        return;
		    }
		    var hidID = "H_" + strCheckBox.substr(2)
		    // alert ("Changing hid value: "+hidID);
		    var objHid = document.getElementById(hidID);
		    if ( objHid != null ) {
                var sValue = new String();
                sValue = objHid.value;
                var iIndex = sValue.lastIndexOf("_");
                if ( iIndex >=0 )
                    sValue = sValue.substr(0,iIndex+1)
                    //sValue = sValue.slice(0,iIndex+1);
                else {
    		        alert("Internal Error. Bad Checkbox name");
	    	        return;
	    	    }
                if ( obj.checked == 1 )          // can edit. Set hid field to 0 else set to 1
                    sValue += "0";
                else                
                    sValue += "1";
                // alert("Value for hidID: B: "+objHid.value+" A:" +sValue);
                objHid.value = sValue;
		        bDirty = true;
           }
           else {
		        alert("Internal Error. Check box Tracking Field not found");
		        return;
		    }
		}
	    function doLoad() {
	    }
	</script>
</head>

<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onload="doLoad();">
<form name="theForm" action="FieldLocking_details_work.asp" method="post">
    
    <div id="dTitle" style="height:30px; padding:10px 0 10px 0">
        <h4 style="text-align:center; font-style:italic">Check the appropriate boxes to allow editing of field</h4>
    </div>

    <div style="border:1px solid dimgray; margin-left:3px; margin-right:3px;">
    <div style="overflow:hidden; width:100%;">
        <table border="0" id="tblTitle" style="padding:2px; width:96%; margin-left:1%; margin-right:3%;">
            <tr>
                <th width="<%=Col1 %>%">&nbsp;</th>
                <th align="right" width="<%=Col2 %>%">Set / Clear ALL Checkboxes in Category:</th>
                <%for c = 0 to numCols-1 %>
                    <th align="center" width="<%=colWidth %>%">
                        <input type="checkbox" id="cALL_<%=c+1 %>" onclick="javascript:SetClearCat(this,'<%=c+1 %>')" />
                    </th>
                <%next ' c %>
            </tr>
            <tr>
                <th width="<%=Col1 %>%">&nbsp;</th>
                <th width="<%=Col2 %>%">&nbsp;</th>
                <%for c = 0 to numCols-1 %>
                    <th align="center" id="C<%=c %>" width="<%=colWidth %>%"><%=SmartValues(aFieldCols(dictHeaderDataCols("Category"), c), "String") %></th>
                <%next ' c %>
            </tr>
        </table>
    </div>
    
    <div style="overflow:auto; width:100%; height:500px;">
        <table border="0" id="tblDetails" style="padding:2px; width:96%; margin-left:1%; margin-right:1%;">
            <%
            uiRow = 1
            r = 0
            ' ======= FOR TESTING.
            ' numRows = 6
            while r < numRows %>
            <tr>
                <%
           	    ' Fields Returned: FieldLockingID, WorkFlowStageID, MetaDataColumnID, FLUserCatID, WorkFlowName, WorkFlowStageName, TableName, FieldName, Locked
           	    tblName = SmartValues(aDataRows(dictDetailsDataCols("TableName"), r), "String")
                if curTableName <> tblName Then
                    curTableName = tblName
                    ' Create a Row with just the Table Name in it =baseCol 
                    %>
                <th style="text-align:left" width="100%" colspan="<%=numCols+2 %>">
                    <%=tblName %>
                </th>
                </tr>
            <tr>
               <td width="<%=Col1 %>%">
                    &nbsp;
               </td>
                <% else   %>
                <td width="<%=Col1 %>%">
                    &nbsp;
                </td>
                <% end if %>
                <td width="<%=Col2 %>%">
                    <% ' Now Write Field Name
               	    fieldName = SmartValues(aDataRows(dictDetailsDataCols("FieldName"), r), "String")
                    if curFieldName <> fieldName Then
                        curFieldName = fieldName
                    end if
                        %>
                    <span style="font-weight:normal"><%=fieldName %></span>
                </td>
                <% ' Now spit out the columns
                    for c = 0 to numCols-1
                        ' Get a check box and make sure its ID matches the Column we are creating
                        userCatID = SmartValues(aDataRows(dictDetailsDataCols("FLUserCatID"), r), "Integer")
                        titleID = SmartValues(aFieldCols(dictHeaderDataCols("ID"), c), "Integer")
                        if  titleID <> userCatID then   'c+1
                            response.Write("<br />ERROR: Internal Col ID does not match ColID from Data: " & c+1 & "  " & userCatID & "row: " & r & "<br />" )
                            response.End
                        end if
                        strLocked = SmartValues(aDataRows(dictDetailsDataCols("Locked"), r), "String")
                        if strLocked = "0" then
                            strTemp = "checked=""checked"" "
                        else
                            strTemp = " "
                        end if
                 %>
                <td align="center">
                    <input type="checkbox" id="C_<%= uiRow & "_" & c+1 %>" onclick="javascript:UpdateCheckBox(this);" <%=strTemp %> />
                <%  
                        strTemp1 = SmartValues(aDataRows(dictDetailsDataCols("FieldLockingID"), r), "Integer")
                        if strTemp1 = -1 then ' NEW DATA ROW
                            strTemp1 = SmartValues(aDataRows(dictDetailsDataCols("MetaDataColumnID"), r), "String")
                            strTemp = "N_" & strTemp1 & "_" & userCatID & "_" & strLocked
                        else    ' Save Pri Key info in hidden field
                            strTemp = "P_" & strTemp1 & "_" & strLocked
                        end if
                 %> 
                    <input type="hidden" name="H_<%=uiRow & "_" & c+1 %>" id="H_<%=uiRow & "_" & c+1 %>" value="<%=strTemp %>" />
                </td>
                <%
                        r = r + 1   ' GOTO the next Data Row after referencing each check box record
                    next ' c
                    uiRow = uiRow + 1 ' after all the check boxs on the row are complete inc the uiRow counter
                 %>
            </tr>
        <%
            wend    ' End Loop of Data Rows
         %>    
    </table>
    <input type="hidden" name="HuiRows" id="HuiRows" value="<%=uiRow-1 %>" />
    <input type="hidden" name="HuiCols" id="HuiCols" value="<%=numCols %>" />
    <input type="hidden" name="HwfID" id="HwfID" value="<%=wfID %>" />
    <input type="hidden" name="HwfsID" id="Hidden1" value="<%=wfsID %>" />
    <input type="hidden" name="HRefresh" id="HRefresh" value="0" />
    </div>
</div>  
</form>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "FieldLocking_details_header.asp?p1=<%=wfName%>&p2=<%=wfsName%>";
		parent.frames["controls"].document.location = "FieldLocking_details_footer.asp?tid=<%=recordID%>&fid=<%=fieldID%>";
	//-->
</script>
</body>
</html>

<%
Call DB_CleanUp
Sub DB_CleanUp
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing
End Sub

set dictHeaderDataCols = Nothing
set dictDetailsDataCols = nothing
set aDataRows = nothing
set aFieldCols = nothing

Set arDetailsDataRows = Nothing
Set dictDetailsDataCols = Nothing
%>