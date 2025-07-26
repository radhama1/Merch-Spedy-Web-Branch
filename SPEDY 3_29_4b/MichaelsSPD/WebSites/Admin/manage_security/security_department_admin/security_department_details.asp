<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Oscar Treto
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="../../app_include/smartValues.asp"-->
<!--#include file="../../app_include/dal_cls_UtilityLibrary.asp"-->
<%
Dim SQLStr, utils, rs
Dim depListScopeID

'CONSTANT
depListScopeID = 1002

Set utils = New cls_UtilityLibrary
%>
<html>
<head>
	<title>Manage Department List</title>
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
	//-->
	</style>
	<script type="text/javascript" src="./../../app_include/global.js"></script>
	<script type="text/javascript" src="./../../app_include/prototype/prototype.js"></script>
	<script language=javascript>
	<!--
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;
		var newDepartments = 0;

		//client side js
		function clickButton(e, buttonid){ 
			var bt = document.getElementById(buttonid); 
			if (typeof bt == 'object'){ 
					if(navigator.appName.indexOf("Netscape")>(-1)){ 
						if (e.keyCode == 13){ 
								bt.click(); 
								return false; 
						} 
					} 
					if (navigator.appName.indexOf("Microsoft Internet Explorer")>(-1)){ 
						if (event.keyCode == 13){ 
								bt.click(); 
								return false; 
						} 
					} 
			} 
		}
		
		function initTabs(thisTabName)
		{
			clearMenus();
			switch (thisTabName)
			{
				case "descriptionTab":
					workspace_description.style.display = "";
					break;
			}
		}
	
		function clickMenu(tabName)
		{
			clearMenus();

			switch (tabName)
			{
				case "descriptionTab":
					workspace_description.style.display = "";
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			workspace_description.style.display = "none";
		}

		function doSubmit()
		{
			if (confirm('Are you sure you want to save?'))
			{
				document.theForm.submit();
			}
		}
		
		function HTMLEncodeStr(strHTML) 
		{
			var html = "" + strHTML;
			var arrE = [["&","&amp;"], ["\"","&quot;"] ,["<","&lt;"], [">","&gt;"]];
			var arrO = [];

			for (var i=0, j=html.length, k=arrE.length; i<j; ++i) {
				var c = arrO[i] = html.charAt(i);
				for (var l=0; l<k; ++l) {
					if (c == arrE[l][0]) {
						arrO[i] = arrE[l][1];
						break;
					}
				}
			}
			return arrO.join("");
		}
		
		function addNewDepartment()
		{
			var depNum = trim($('newDeptNum').value);
			var depName = trim($('newDeptName').value).toUpperCase();
			
			//Validation
			if(depNum.length == 0)
			{
				alert('Department number cannot be left blank');
				$('newDeptNum').focus();
				return;
			}
			
			if(!IsPosNumber(depNum))
			{
				alert('Please enter a valid department number');
				$('newDeptNum').focus();
				return;
			}
			
			if(depName.length == 0)
			{
				alert('Department name cannot be left blank');
				$('newDeptName').focus();
				return;
			}
			
			//Increment Number of new departments
			depNum = depNum * 1;
			newDepartments++;
			$('NumNewDepartments').value = newDepartments;
			
			//Dynamically Add Department to HTML Table
			var tbl = $('DepartmentListTable');
			var lastRow = tbl.rows.length;
			var row = tbl.insertRow(lastRow);
					
			var cell0 = row.insertCell(0);
			cell0.className = 'bodyText';
			cell0.innerHTML = '<input type=hidden id="new_' + newDepartments + '_Num" name="new_' + newDepartments + '_Num" value=""><input type=hidden id="new_' + newDepartments + '_Name" name="new_' + newDepartments + '_Name" value="">';
			$('new_' + newDepartments + '_Num').value = depNum;
			$('new_' + newDepartments + '_Name').value = depName;
			
			var cell1 = row.insertCell(1);
			cell1.className = 'bodyText';
			cell1.innerHTML = depNum;			
			
			var cell2 = row.insertCell(2);
			cell2.className = 'bodyText childcatlist';
			cell2.innerHTML = HTMLEncodeStr(depNum + ' - ' + depName);			
			
			$('newDeptNum').value = "";
			$('newDeptName').value = "";
			
			cell0 = null;
			cell1 = null;
			cell2 = null;
			row = null;
			tbl = null;			
		}
		
	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<form name="theForm" action="security_department_details_work.asp" method="POST" onSubmit="doSubmit();" ID="Form1">
<table width="100%" cellpadding=0 cellspacing=0 border=0>
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="../images/spacer.gif" height=400 width=1 border=0></td>
		<td width="100%" valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SQLStr = "Select ID, Privilege_Name, Privilege_Summary, Constant, SortOrder From Security_Privilege Where Scope_ID = " & depListScopeID & " Order By SortOrder, Privilege_Name"
			Set rs = utils.LoadRSFromDB(SQLStr)
			%>
			<div id="workspace_description" name="workspace_description" style="display:none">
				<table cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width="100%" valign=top>
							<table cellpadding=0 cellspacing=0 border=0 width="100%" ID="Table1">
								<tr>
									<td><img src="../images/spacer.gif" height=1 width=60 border=0></td>
									<td><img src="../images/spacer.gif" height=1 width=300 border=0></td>
									<td width="100%"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
								</tr>
								<tr>
									<td class="bodyText header">&nbsp;&nbsp;#</td>									
									<td class="bodyText header">Department Name</td>
									<td class="bodyText header">&nbsp;</td>
								</tr>
								<tr>
									<td><input type="text" value="" name="newDeptNum" id="newDeptNum" style="width: 30px;" maxlength="3"></td>
									<td><input type="text" value="" name="newDeptName" id="newDeptName" style="width: 300px;" maxlength="95" onkeypress="return clickButton(event, 'AddNewDeptButton');"></td>
									<td><input type="button" name="Add" value="ADD" onclick="addNewDepartment();" id="AddNewDeptButton" name="AddNewDeptButton">&nbsp;<font size="1">(added to bottom of list)</font></td>
								</tr>
								<tr><td colspan=3>&nbsp;</td></tr>
							</table>
						</td>
					</tr>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width="100%" valign=top>
							<table cellpadding=0 cellspacing=0 border=0 width="100%">
								<tr>
									<td><img src="../images/spacer.gif" height=1 width=50 border=0></td>
									<td><img src="../images/spacer.gif" height=1 width=50 border=0></td>
									<td width="100%"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
								</tr>
								<tr>
									<td class="bodyText header">Remove</td>
									<td class="bodyText header">Dept #</td>
									<td class="bodyText header">Department Name</td>
								</tr>
								<tr><td colspan=3><hr></td></tr>
							</table>
							<div style="height: 380px; overflow: auto;">
							<table cellpadding=0 cellspacing=0 border=0 width="100%" id="DepartmentListTable">
								<tr>
									<td><img src="../images/spacer.gif" height=1 width=50 border=0></td>
									<td><img src="../images/spacer.gif" height=1 width=50 border=0></td>
									<td width="100%"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
								</tr>								
								<%
								Do Until rs.EOF
								%>
								<tr>
									<td class="bodyText"><input type="checkbox" value="<%=rs("ID")%>" name="strRemovePrivileges" id="chkRemove_<%=rs("ID")%>" /></td>
									<td class="bodyText"><%=Server.HTMLEncode(Replace(SmartValues(rs("Constant"), "CStr"), "SPD.DEPT.", ""))%></td>
									<td class="bodyText"><input type="text" value="<%=Server.HTMLEncode(SmartValues(rs("Privilege_Name"), "CStr"))%>" name="<%=rs("ID")%>_Name" id="<%=rs("ID")%>_Name" maxlength="100" style="width: 300px;"></td>
								</tr>
								<%
									rs.MoveNext
								Loop
								%>								
							</table>
							</div>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
			<%
			Set rs = Nothing
			%>
		</td>
	</tr>
</table>
<input type="hidden" value="<%=depListScopeID%>" name="ScopeID" id="ScopeID">
<input type="hidden" value="0" name="NumNewDepartments" id="NumNewDepartments">
</form>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "security_department_details_header.asp";
		parent.frames["controls"].document.location = "security_department_details_footer.asp";
	//-->
</script>

</body>
</html>

<%
Set utils = Nothing
%>