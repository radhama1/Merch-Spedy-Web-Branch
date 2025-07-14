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
dim curFieldName, tblName, fieldName, userCatID, uiRow, strTemp, strTemp1, strLocked, titleID, dRow, strPermission

wfID = checkQueryID(Request("wid"), 0)
wfsID = checkQueryID(Request("wfsID"), 0)
' response.Write(recordID & "   " & fieldID)

Set objConn = Server.CreateObject("ADODB.Connection")
connStr = Application.Value("connStr")
objConn.Open connStr

' response.Write(wfID & "   " & wfsID & "<br />")
if wfID > 0 and wfsID > 0 then
    ' Get Headers for columns (one set of columns repeated twice (Edit vs View) )
	SQLStr = "usp_SPD_FieldLocking_GetFieldLockingCategories " & wfID
	' Fields Returned: ID, Category
   	Call returnDataWithGetRows(connStr, SQLStr, aFieldCols, dictHeaderDataCols)  

   	if dictHeaderDataCols("RecordCount") = 0 then
        response.Write("No Column Info found for Workflow: " & wfid & "<br />" )
        response.end
	end if

    ' Get Details. Each row is a checkbox in the column set
	SQLStr = "usp_SPD_FieldLocking_GetData " & wfid & ", " & wfsID
	' Fields Returned: FieldLockingID, WorkFlowStageID, MetaDataColumnID, FLUserCatID, WorkFlowName, WorkFlowStageName, 
	'                  TableName, FieldName, Locked
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
colWidth = 10       ' Base width for each checkbox col
baseCol = int((100 - (numCols * 2 * colWidth)) / 2)
Col1 = 6   ' First Col width
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

         tr 
            .initial { background-color: #DDDDDD; color:#000000 }
            .normal { background-color: #CCCCCC }
            .highlight { background-color: lightyellow }

		th 
		{
		    color: navy;
		    font-weight:bold;
		}
	    th.colHeader1
		{
		    background-color: silver;			
        }

	    th.colHeader2
		{
			border-right-style: solid;
			border-right-width: 1px;
			border-right-color: Gray;
			background-color: silver;
        }
        th.separator
        {
			border-left-style: solid;
			border-left-width: 2px;
			border-left-color: Gray;
			background-color: silver;
	    }
        
		th.rowHeader
		{
			font-size: 14px;
			padding-top:10px;
        }

        td.separator
        {
			border-left-style: solid;
			border-left-width: 2px;
			border-left-color: Gray;
	    }
        
        .outer
        {
            border-style:solid; 
            border-width:1px; 
            border-bottom-color:whitesmoke; 
            border-right-color:whitesmoke; 
            border-top-color:Gray; 
            border-left-color:Gray; 
            margin-left:5px; 
            margin-right:5px;        
            padding-bottom:3px;
        }
        
        .tblHeader
        {
            overflow:hidden; 
            width:100%; 
            background-color:Silver; 
            border-bottom-style: solid; 
            border-bottom-width: 1px;	
            border-bottom-color: Gray;
        }

        .inner
        {
            overflow-x:hidden; 
            overflow-y:auto;
            width:100%; 
            height:480px;"
        }
                   		    
	</style>
	<script language=javascript>
		var bDirty = false      // track page changed
		var bEnableCalled = false   // Track if SAVE buttons are enabled
		
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function validateForm(sRefresh) {
	        if (sRefresh == "1")  // Save Form
	            document.theForm.HRefresh.value = 1;
	        else                // Save and Close
	            document.theForm.HRefresh.value = 0;
		    document.theForm.submit();
		}

        function SetClearCat(obj,c) {
            // Set / Clear all Checkboxes in a column and update its assoc hidden field
            var iRows = document.getElementById("HuiRows").value;
            var iCols = document.getElementById("HuiCols").value;
            var sTemp = new String();
            sTemp = obj.id;
            var checked = obj.checked;
            var colID = "";
            if (sTemp.substr(1,1) == 'E') {         // Edit Column
                var sViewID = "cV_" + sTemp.substr(3);
                var objView = document.getElementById(sViewID);
                colID = "E_"
                objView.checked = true;
                if ( obj.checked ) {                // Turn View on and lock
                    objView.disabled = true;
                }
                else {    
                    objView.disabled = false;
                }
            }
            else {                                  // View Column
                colID = "V_";
            }
            // Now set all the checkboxes in the column 
            for (var i=1; i<=iRows; i++) {
                var sID = colID + i + "_" + c;
                var objChk = document.getElementById(sID);
                objChk.checked = obj.checked;
                UpdateCheckBox(objChk);
            }
        }
                 
		function UpdateCheckBox(obj) {
		    // Update the assoc hidden field of a checkbox based on matching IDs
		    // debugger;
		    
		    bDirty = false;
		    var strCheckBox = new String();
		    strCheckBox = obj.id;
		    if (strCheckBox == null) {
		        alert("Internal error: Could not determine name of checkbox element.");
		        return
		    }
            var sTemp = strCheckBox.substr(0,1)
		    if ( sTemp != "E" && sTemp != "V" ) {
		        alert("Internal Error. Check box not found");
		        return;
		    }
		    // Get Hidden field assoc with these check boxes
		    var hidID = "H" + strCheckBox.substr(1);
    	    var objHid = document.getElementById(hidID);
    	    var sValue = new String();
            sValue = objHid.value;
            var iIndex = sValue.lastIndexOf("_");
            if ( iIndex >=0 )
                sValue = sValue.substr(0,iIndex+1)
            else {
    	        alert("Internal Error. Bad Checkbox name for Tracking field.");
		        return;
    	    }

		    if ( sTemp == "E" ) {       // Edit Check box was clicked
		        var ViewID = "V" + strCheckBox.substr(1);
		        var objView = document.getElementById(ViewID);
		        if (obj.checked == 1) {     // Check was turned on
		            objView.checked = true;
		            objView.disabled = true;
		            sValue += "E";      // hidden field value to E
		        }
		        else {
		            objView.checked = true;     // default View to true if not Edit
		            objView.disabled = false;
		            sValue += "V";      // hidden field value to V
		        }
		    }
		    else {                      // View Check box was clicked
		        if (obj.checked == 1) {     // Check was turned on
		            sValue += "V";      // hidden field value to V
		        }
		        else {
		            sValue += "N";      // hidden field value to N
		        }
		    }
		    // Save hidden field
            objHid.value = sValue;
	        bDirty = true;
	    }
		
		function CheckDirty() {
		    // if form changed and Save buttons are not on then call the Footer page to enable the SAVE buttons
		    if (bDirty && !bEnableCalled) {
		        bEnableCalled = parent.frames['controls'].EnableSaves();
		    }
		}
		
	    function doLoad() {
	        //Save JIC: ?tid=<%=recordID%>&fid=<%=fieldID%>
    		parent.frames["header"].document.location = "FieldLocking_details_header.asp?p1=<%=wfName%>&p2=<%=wfsName%>";
	    	parent.frames["controls"].document.location = "FieldLocking_details_footer.asp";

	    	// Initialize Grid of Checkboxes based on hidden fields
            var iRows = document.getElementById("HuiRows").value;
            var iCols = document.getElementById("HuiCols").value;
            var sTemp = new String();
            var sValue = new String();

            for (var i = 1; i <= iRows; i++) {
                for (var c = 1; c <= iCols; c++) {
                    var sID = "H_" + i + "_" + c;
                    var objHid = document.getElementById(sID);
                    sValue = objHid.value;
                    sValue = sValue.charAt(sValue.length-1);       // last char of string is permission
                    if ( sValue == "E" )    {           // Force View on and disable
                        sTemp = "V_" + i + "_" + c;
                        var objV = document.getElementById(sTemp);
                        objV.checked = true;
                        objV.disabled = true;
                    }
                }   // next col
            }   // next row
	    }
	    
	</script>
</head>

<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onclick="javascript:CheckDirty()" onload="doLoad(); ">
<form name="theForm" action="FieldLocking_details_work.asp" method="post">
    
    <div id="dTitle" style="height:28px; padding:10px 0 10px 0">
        <h4 style="text-align:center; font-style:italic">Check the appropriate boxes to allow Editing / Viewing of field</h4>
    </div>
    <div class="outer">
    <div class="tblHeader">
        <table border="0" cellspacing="0" cellpadding="2" id="tblTitle" style="padding:2px; width:96%; margin-left:1%; margin-right:3%;">
            <tr>
                <th colspan="2" width="<%=Col1+Col2 %>%">&nbsp;</th>
                <th colspan="<%=numCols %>" align="center">E D I T</th>
                <th width="1%" class="separator">&nbsp;</th>
                <th colspan="<%=numCols %>" align="center">V I E W</th>
            </tr>
            
            <tr >
                <th class="colHeader1" align="right" colspan="2" width="<%=Col1+Col2 %>%">Set / Clear ALL Check boxes in Category</th>
                <% for c = 1 to numCols         ' Create EDIT CheckAll checkboxes
                    if c=numCols then
                        strTemp = "colHeader1"
                    else
                        strTemp = "colHeader2"
                    end if
                %>
                    <th class="<% =strTemp%>" align="center" width="<%=colWidth %>%">
                        <input type="checkbox" id="cE_<%=c %>" onclick="javascript:SetClearCat(this,'<%=c %>')" />
                    </th>
                <%next ' c %>
                <th width="3" class="separator"><img src="../../app_images/col_spacer.gif" alt=" " /></th>
                <% for c = 1 to numCols          ' Create VIEW CheckAll checkboxes
                    if c=numCols then
                        strTemp = "colHeader1"
                    else
                        strTemp = "colHeader2"
                    end if
                %>
                    <th class="<% =strTemp%>" align="center" width="<%=colWidth %>%">
                        <input type="checkbox" id="cV_<%=c %>" onclick="javascript:SetClearCat(this,'<%=c %>')" />
                    </th>
                <%next ' c %>

            </tr>
            <tr >
                <th class="colHeader1" align="left" colspan="2" width="<%=Col1+Col2 %>%">Table / Field Name</th>
                <% for c = 1 to numCols     ' Col Headers for EDIT
                    if c=numCols then
                        strTemp = "colHeader1"
                    else
                        strTemp = "colHeader2"
                    end if
                 %>
                    <th class="<% =strTemp%>" align="center" id="C<%=c %>" width="<%=colWidth %>%"><%=SmartValues(aFieldCols(dictHeaderDataCols("Category"), c-1), "String") %></th>
                <%next ' c %>
                <th width="3" class="separator"><img src="../../app_images/col_spacer.gif" alt=" " /></th>
                <%for c = 1 to numCols     ' Col Headers for VIEW
                    if c=numCols then
                        strTemp = "colHeader1"
                    else
                        strTemp = "colHeader2"
                    end if
                 %>
                    <th class="<% =strTemp%>" align="center" id="Th1" width="<%=colWidth %>%"><%=SmartValues(aFieldCols(dictHeaderDataCols("Category"), c-1), "String") %></th>
                <%next ' c %>

            </tr>
        </table>
    </div>

    <div class="inner">
        <table border="0" cellspacing="0" cellpadding="2" id="tblDetails" style="width:96%; margin-left:1%; margin-right:1%;" >
            <%      ' DATA ROWS
            uiRow = 1
            r = 0
            ' ======= FOR TESTING.
            ' numRows = 6
            dim aPerms()    ' Keep Track of Permission variable across two sets of cols.
            ReDim Preserve aPerms(numCols)  ' Used to save permissions when rendering the View Columns
            while r < numRows 
           	    ' Fields Returned: FieldLockingID, WorkFlowStageID, MetaDataColumnID, FLUserCatID, WorkFlowName, 
           	    '   WorkFlowStageName, TableName, FieldName, Permission
           	    tblName = SmartValues(aDataRows(dictDetailsDataCols("TableName"), r), "String")
                if curTableName <> tblName Then
                    curTableName = tblName
                    ' Create a Row with just the Table Name in it
            %>
            <tr>
                <th class="rowHeader" style="text-align:left;" width="100%" colspan="<%=numCols*2+3 %>">
                    <%=tblName %>
                </th>
            </tr>
            <% end if  %>
            <tr class="normal" onMouseOver="this.style.backgroundColor='lightyellow'" onMouseOut="this.style.backgroundColor='#CCCCCC'">
                <td width="<%=Col1 %>%" >
                    &nbsp;
                </td>
                <td width="<%=Col2 %>%">
                    <% ' Now Write Field Name
               	    fieldName = SmartValues(aDataRows(dictDetailsDataCols("FieldName"), r), "String")
                    if curFieldName <> fieldName Then
                        curFieldName = fieldName
                    end if
                        %>
                    <span style="font-weight:normal"><%=fieldName %></span>
                </td>
                <% ' Spit out the columns for Edit and View
                    for c = 1 to numCols
                        ' Get a check box and make sure its ID matches the Column we are creating
                        userCatID = SmartValues(aDataRows(dictDetailsDataCols("FLUserCatID"), r), "Integer")
                        titleID = SmartValues(aFieldCols(dictHeaderDataCols("ID"), c-1), "Integer")
                        aPerms(c) = uCase(SmartValues(aDataRows(dictDetailsDataCols("Permission"), r), "String"))
                        if  titleID <> userCatID then   
                            response.Write("<br />ERROR EDIT: Header Col ID does not match ColID from Data: " & titleID & " - " & userCatID & "  row: " & r & "<br />" )
                            response.End
                        end if
                        if aPerms(c) = "E"   then
                            strTemp = "checked=""checked"" "
                        else
                            strTemp = " "
                        end if
                 %>
                <td align="center">
                    <input type="checkbox" id="E_<%= uiRow & "_" & c %>" onclick="javascript:UpdateCheckBox(this);" <%=strTemp %> />
                <%
                        strTemp1 = SmartValues(aDataRows(dictDetailsDataCols("FieldLockingID"), r), "Integer")
                        if strTemp1 = -1 then ' NEW DATA ROW
                            strTemp1 = SmartValues(aDataRows(dictDetailsDataCols("MetaDataColumnID"), r), "String")
                            strTemp = "N_" & strTemp1 & "_" & userCatID & "_" & aPerms(c)
                        else    ' Save Pri Key info in hidden field
                            strTemp = "P_" & strTemp1 & "_" & aPerms(c)
                        end if
                 %>
                    <input type="hidden" name="H_<%=uiRow & "_" & c %>" id="H_<%=uiRow & "_" & c %>" value="<%=strTemp %>" />
                </td>
                <% 
                        r = r + 1   ' GOTO the next Data Row after referencing each check box record (EDIT / Hidden field)
                    next ' c
                %>
                <td width="1%" class="separator">&nbsp;</td>
                <% ' Spit out the columns for View Checkboxes
                    for c = 1 to numCols
                        ' Get a check box and make sure its ID matches the Column we are creating
                        if aPerms(c) = "V"   then
                            strTemp = "checked=""checked"" "
                        else
                            strTemp = " "
                        end if
                 %>
                <td align="center">
                    <input type="checkbox" id="V_<%= uiRow & "_" & c %>" onclick="javascript:UpdateCheckBox(this);" <%=strTemp %> />
                </td>
                <% 
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
    <input type="hidden" name="HwfsID" id="HwfsID" value="<%=wfsID %>" />
    <input type="hidden" name="HRefresh" id="HRefresh" value="0" />
    </div>
</div>  
</form>

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