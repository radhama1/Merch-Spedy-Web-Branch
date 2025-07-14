<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Jeff Littlefield
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="../../app_include/smartValues.asp"-->
<!--#include file="../../app_include/dal_cls_UtilityLibrary.asp"-->
<%
Dim SQLStr, utils, rsDept, rsWorkflow, rsGroup
' Procs Used
' Get depts for Dropdown list   : usp_SPD_PrimaryApproval_GetDepts
' Get User info for dept ID     : usp_SPD_PrimaryApproval_GetUsers
' Save Pri Appr Flag for users  : usp_SPD_PrimaryApproval_SaveUsers

Set utils = New cls_UtilityLibrary

SQLStr = "usp_SPD_PrimaryApproval_GetWorkflows"
Set rsWorkflow = utils.LoadRSFromDB(SQLStr)

SQLStr = "usp_SPD_PrimaryApproval_GetDepts"
Set rsDept = utils.LoadRSFromDB(SQLStr)

SQLStr = "usp_SPD_PrimaryApproval_GetSecurityGroups"
Set rsGroup = utils.LoadRSFromDB(SQLStr)

%>
<html>
<head>
	<title>Manage Primary Approvers List</title>
	<style type="text/css">
	<!--
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
		td {
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:10pt;
			color: black;
			font-weight: normal;
		}
		th {
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:10pt;
			color: Navy;
			font-weight: normal;
		}
		.deptH {
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:11pt;
			color: black;
			font-weight: normal;
		}		
		
		.dept {
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:11pt;
			color: Navy;
			font-weight: normal;
		}			
	
		.langOption_Selected
		{
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:11px;
			color:#ffffff;
			cursor: hand;
		}
		.langOption
		{
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:11px;
			color:#000000;
			cursor: hand;
		}
		.bodyText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			color: #000;
		}
		.header
		{
			font-weight: bold;
		}
		#tblTitle {		
		    padding:2px; 
		    width:96%; 
		    margin-left:1%; 
		    margin-right:3%;
		}
		#tblDetails {
		    width:98%; 
		    padding:2px; 
		    margin-left:1%; 
		    margin-right:1%;
		    background-color:whitesmoke; 

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
            padding-bottom:1px; 
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
        
        .container {
            width:100%; 
            height:455px;
        
        .inner
        {
            overflow-x:hidden; 
            overflow-y:scroll;
            width:100%; 
            height:450px;
		    background-color:whitesmoke; 
        }
        
        .msg 
        {
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:10pt;
			color: darkgreen;
			font-weight: normal;
		}

        .err 
        {
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:10pt;
			color: red;
			font-weight: normal;
		}
   		 
	//-->
	</style>
	<script type="text/javascript" src="./../../app_include/global.js"></script>
	<script type="text/javascript" src="./../../app_include/prototype/prototype.js"></script>
	<script language=javascript>
	<!--
	var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

	function clickMenu(tabName) {
		clearMenus();
		switch (tabName) {
			case "descriptionTab":
				workspace_description.style.display = "";
				break;
			
			default:
				clearMenus();
				break;
		}
	}
	
	function clearMenus() {
		workspace_description.style.display = "none";
	}

	var currentDeptValue;
	var currentDeptSelectIndex;
	var currentWorkflowValue;
	var currentWorkflowSelectIndex;
	var currentGroupValue;
	var currentGroupSelectIndex;
	var isDirty = new Boolean();
	var isDirty = false;
	var numberUsers;
	var bEnableCalled = false   // Track if SAVE buttons are enabled
	var closeWindow;


	function CheckDirty() {
	    // if form changed and Save buttons are not on then call the Footer page to enable the SAVE buttons
	    if (isDirty && !bEnableCalled) {
	        bEnableCalled = parent.frames['controls'].EnableSaves();
	    }
	}
	
	function SD() {
	    if (!isDirty) {
	        isDirty = true;
       	    var lblMsg = $('lblMsg');
       	    lblMsg.style.color="Navy"
       	    lblMsg.innerHTML = "Changes not saved."
       	}
	}
	
	function GetWorkflows() {
		return false;
	}

    function GetUsers() {
        var selDept = $('selDept');
		var selGroup = $('selGroup');
		var selWorkflow = $('selWorkflow');
        if (isDirty) {
            if (!confirm("Primary Approvers have not been saved for Dept: \n" + selDept.options(selDept.selectedIndex).text + "\n\n Confirm you want to Load the new dept and LOSE YOUR CHANGES.") ) {
                selDept.selectedIndex = currentDeptSelectIndex;
                return false;
            }
            else {
   	            var lblMsg = $('lblMsg');
   	            lblMsg.innerHTML = ""
                isDirty = false;
                bEnableCalled = parent.frames['controls'].DisableSaves();
            }
        }
        
        currentDeptSelectIndex = selDept.selectedIndex;
        currentDeptValue = selDept.value
		currentGroupSelectIndex = selGroup.selectedIndex;
		currentGroupValue = selGroup.value;
		currentWorkflowSelectIndex = selWorkflow.selectedIndex;
		currentWorkflowValue = selWorkflow.value;

        var lblDept = $('lblDept')
        var lblDeptTitle = $('lblDeptTitle')
        
		// if one of the drop lists doesn't have a selection, clear out User div
		// then return from this function
        if (currentDeptValue == 0 || currentGroupValue == 0 || currentWorkflowValue == 0) {
            var divUsers = $('divUsers');
            divUsers.innerHTML = "";
            lblDeptTitle.innerHTML = "";
            lblDept.innerHTML = "";
            var lblMsg = $('lblMsg');
            lblMsg.innerHTML = ""
            return;
        }

        lblDeptTitle.innerHTML = "Select Primary Approvers for Department: "
        lblDept.innerHTML = selDept.options(selDept.selectedIndex).text

        // Call Ajax routine to load Users table and number of records loaded  
        var ts = new Date();
        var url = "security_PriApprover_Details_Ajax.asp?f=GetUsers&id=" + currentDeptValue + "&ts=" + ts.getTime();
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function(response) {
                ProcGetResponse(response);
            },
            onFailure: function(trouble) {
                ProcTrouble(trouble);
            },
            onException: function(r,trouble) {
                ProcTrouble(trouble);
            }
        } );
        return false; 
    }

    function ProcTrouble(trouble) {
        var lblErr = $('lblErr');
        lblErr.innerHTML = "ERROR Occurred. Contact Nova Libra Support with following info:<br/>" + trouble.responseText;
    }
    
    function  ProcGetResponse(response) {
        var optText = new String();
        var optText = response.responseText;
        var divUsers = $('divUsers');
        numberUsers = 0;
        
        if (optText.length>0) {
            var records = optText.split("|$|")
            if (records.length != 3) {
                alert('Error Getting users. Response from server not formed properly. Code 1.')
                return;
            }
            if (records[0] == '0') {        // error occurred in sql
                divUsers.innerHTML = records[1];
                return;
            }
            if (records[2] == '0') {
                divUsers.innerHTML = records[1];
                alert('No User Records for Department found. Please add users with the User Properties page.')
                return;
            }                    
            if (!/^-?\d+$/.test(records[2])) {
                alert('Error Getting users. Response from server not formed properly. Code 2.')
                return;
            }                    
            numberUsers = records[2];       // save records loaded for Save process
            divUsers.innerHTML = records[1];
        }
        else {
            alert('Error Getting users. Response from server not formed properly. Code 3.')
            return;
       }
    } 
    
    function validateForm(sRefresh) {
        // AJAX calls to save data and optionally close window
        // format: IDofUser_bitOnOFF|
        
        sTemp = new String();
        stemp = "";
        for (var i = 1; i <= numberUsers; i++) {
            sTemp += $('hidchk' + i).value + '_' 
            sTemp += (($('chk' + i).checked == true ) ? '1' : '0') 
            sTemp += ((i<numberUsers) ? '|' : '');  // Tack on record sep unless its the last record
        }
        var hdnUserData = $('hdnUserData');
        hdnUserData.value = sTemp;
        var hdnPrivID = $('hdnPrivID');
        hdnPrivID.value = currentDeptValue; // ID of dept to save
        closeWindow = sRefresh;
        
        var ts = new Date();
        var url = "security_PriApprover_Details_Ajax.asp?f=SaveUsers"
        new Ajax.Request(url, {
            method: 'post',
            parameters: $('theForm').serialize(true),
            onSuccess: function(response) {  
                ProcSaveRespose(response);
            },
            onFailure: function(trouble) {
                ProcTrouble(trouble);
            },
            onException: function(r,trouble) {
                ProcTrouble(trouble);
            }
        } );      
	}    
	
	function ProcSaveRespose(response) {
	    var divUsers = $('divUsers');
	    var lblMsg = $('lblMsg');
	    var resp = new String();
	    resp = response.responseText;
	    
	    var record = resp.split("|")
	    if (record[0] == '0')
	        lblMsg.style.color="red";
	    else
	        lblMsg.style.color="darkgreen";
	    lblMsg.innerHTML = record[1];
	    isDirty = false;
	    bEnableCalled = parent.frames['controls'].DisableSaves();
	    if (closeWindow == 0) {
			parent.window.close();
		}
	    else   
    	    GetUsers();
	}
    //-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0  onclick="javascript:CheckDirty()">

<form name="theForm" action="" method="POST" onSubmit="return false;" ID="theForm">
    <input type="hidden" name="hdnUserData" id="hdnUserData" value="" />
    <input type="hidden" name="hdnPrivID" id="hdnPrivID" value="" />
</form>

    
    <div id="workspace_description" style="display:none">
        <table border="0" cellspacing="0" id="Table2" style="padding:4px; width:100%;">
			<tr>
				<th align="right" width="12%"> Workflow:</th>
				<td align="left" width="88%">
					<select id="selWorkflow" name="selWorkflow" onchange="GetUsers()">
						<option value="0" selected="selected">*** Select Workflow ***</option>
						<%	
							do while not rsWorkflow.EOF
						%>
							<option value='<%=SmartValues(rsWorkflow("Workflow_Id"), "CStr")%>'><%=Server.HTMLEncode(SmartValues(rsWorkflow("Workflow_Name"), "CStr"))%></option>
						<%
								rsWorkflow.MoveNext
							loop
							rsWorkflow.Close()
							Set rsWorkflow = Nothing
						%>
					</select>
				</td>
			</tr>
            <tr>
                <th align="right" width="12%"> Department:</th>
                <td align="left" width="88%">
                    <select id="selDept" name="selDept" onchange="GetUsers()">
                        <option value="0" selected="selected">*** Select Department ***</option>
                    <%Do While not rsDept.EOF %>
                        <option value='<%=SmartValues(rsDept("ID"), "CStr") %>'><%=Server.HTMLEncode(SmartValues(rsDept("Privilege_Name"), "CStr")) %></option><%rsDept.MoveNext
                      loop
                      rsDept.close()
                      Set rsDept = Nothing
                     %>
                    </select>
                </td>
            </tr>
			<tr>
				<th align="right" width="12%"> Group:</th>
				<td align="left" width="88%">
					<select id="selGroup" name="selGroup" onchange="GetUsers()">
						<option value="0" selected="selected">*** Select Group ***</option>
						<%	
							do while not rsGroup.EOF
						%>
							<option value='<%=SmartValues(rsGroup("ID"), "CStr")%>'><%=Server.HTMLEncode(SmartValues(rsGroup("Group_Name"), "CStr"))%></option>
						<%
								rsGroup.MoveNext
							loop
							rsGroup.Close()
							Set rsGroup = Nothing
						%>
					</select>
				</td>
			</tr>
        </table>
    </div> <!-- style="padding:2px; width:96%; margin-left:1%; margin-right:3%;" -->
    &nbsp;<br />

    <div class="outer">
        <div class="tblHeader">
            <table border="0" cellspacing="0" cellpadding="2" id="tblTitle" width="100%" >
                <tr>
                    <th colspan="4" align="center"><span class='deptH' id="lblDeptTitle"></span><span id="lblDept" class='dept'></span>
                    </th>
                </tr>
                <tr>
                    <td colspan="4">&nbsp;</td>
                </tr>
                <tr>
                    <th align="center" width="10%">Primary<br />Approver</th>
                    <th align="left" width="20%"><br />Name</th>
                    <th align="left" width="15%"><br />Organization</th>
                    <th align="left" width="55%"><br />Groups</th>
                </tr>
            </table>
        </div>
        <div  id="divUsers" class="container">
        </div>
    </div>
    <table width="100%" border="0">
        <tr>
        <td align="center"><span id="lblMsg" class="msg"></span></td>
        </tr>
    </table>
    <table width="100%" border="0">
        <tr>
        <td align="left"><span id="lblErr" class="err"></span></td>
        </tr>
    </table>
    
    
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "security_PriApprover_details_header.asp";
		parent.frames["controls"].document.location = "security_PriApprover_details_footer.asp";
	//-->
</script>
</body>
</html>




</body>
</html>

<%
Set utils = Nothing
%>