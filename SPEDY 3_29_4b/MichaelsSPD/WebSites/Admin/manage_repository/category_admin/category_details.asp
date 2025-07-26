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
Security.Initialize Session.Value("UserID"), "ADMIN.CONTENT.REPOSITORY.CATEGORY", checkQueryID(Request("cid"), 0)

Dim categoryID, boolIsNew, parentCategoryID
Dim winTitle
Dim objConn, objRec, SQLStr, connStr, i, rowcolor
Dim Category_Name, Category_Summary, isEnabled

Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols

Set dictDetailsDataCols	= Server.CreateObject("Scripting.Dictionary")

categoryID = checkQueryID(Request("cid"), 0)
parentCategoryID = checkQueryID(Request("pcid"), 0)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if categoryID = 0 then
	boolIsNew = true
	Security.CurrentPrivilegedObjectID = parentCategoryID
else
	boolIsNew = false

	Call returnDataWithGetRows(connStr, "SELECT * FROM Repository_Category WHERE [ID] = " & categoryID, arDetailsDataRows, dictDetailsDataCols)
end if

%>
<html>
<head>
	<title><%if boolIsNew then%>Add Category<%else%>Edit Category<%end if%></title>
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
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function initTabs(thisTabName)
		{
			clearMenus();
			switch (thisTabName)
			{
				case "descriptionTab":
					workspace_description.style.display = "";
					break;
				
				case "securityTab":
					workspace_security.style.display = "";
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
				
				case "securityTab":
					workspace_security.style.display = "";
					initDataLayout(10);
					doLoad();
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			workspace_description.style.display = "none";
			workspace_security.style.display = "none";
		}
				
		//called when the Calendar icon is clicked
		function dateWin(field)
		{ 
			hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
			hwnd.focus();
		}
		
		function validateForm()
		{
			//Check Category Name
			if (document.theForm.Category_Name.value == "")
			{
				parent.frames['header'].clickMenu("descriptionTab");
				if(document.getElementById("CategoryNameWarningImg")) document.getElementById("CategoryNameWarningImg").src = "./../images/alert_icon_small.gif";
				if (!confirm("You did not specify a name for this category.  A default name will be assigned.\n\nContinue?"))
				{
					return false;
				}
			}
			if(document.getElementById("CategoryNameWarningImg"))document.getElementById("CategoryNameWarningImg").src = "./../images/spacer.gif";
			
			//Check Security
			var numPrivilegesAssigned = 0;
			for (var i = 0; i < document.theForm.length; i++)
			{
				var fldName = new String(document.theForm.elements[i].name);
				if (fldName.indexOf("chk_priv_") >= 0)
				{
					if(document.theForm.elements[i].checked) numPrivilegesAssigned++;
				}
			}
			if (numPrivilegesAssigned == 0)
			{
				parent.frames['header'].clickMenu("securityTab");
				if(document.getElementById("PermissionWarningImg")) document.getElementById("PermissionWarningImg").src = "./../images/alert_icon_small.gif";
				if (!confirm("You did not specify any permissions for this category.\n\nContinue?"))
				{
					return false;
				}
			}
			if(document.getElementById("PermissionWarningImg")) document.getElementById("PermissionWarningImg").src = "./../images/spacer.gif";
			
			document.theForm.submit();
		}
		
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onload="doLoad();">
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="category_details_work.asp" method="POST">
	<tr bgcolor="cccccc"><td colspan=2><img src="./../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="./../images/spacer.gif" height=400 width=1 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				Category_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("Category_Name"), 0), "CStr")
				Category_Summary = SmartValues(arDetailsDataRows(dictDetailsDataCols("Category_Summary"), 0), "CStr")
			end if
			%>
			<div id="workspace_description" name="workspace_description" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width=100% valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="CategoryNameWarningImg"><b>Category Name</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size=60 maxlength=500 style="width: 450px;" name="Category_Name" value="<%=Category_Name%>" AutoComplete="off"></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td colspan=3 class="bodyText">
										<b>Category Summary</b>
									</td>
								</tr>
								<tr>
									<td colspan=3><textarea wrap="virtual" name="Category_Summary" rows=5 cols=45 style="width: 450px;"><%=Category_Summary%></textarea></td>
								</tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<%if boolIsNew then%>
								<tr>
									<td valign=top><input type="checkbox" name="boolCreateDefaultDocumentOnSave" value="1" ID="boolCreateDefaultDocumentOnSave"></td>
									<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
									<td class="bodyText">
										<div class="bodyText" style="width: 400px;">
											<label for="boolCreateDefaultDocumentOnSave" title="This option proves useful when you are creating a category that will later be published to a website.">When I save this new category, create a placeholder document of the same name within this new category.</label> 
										</div>
									</td>
								</tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<%end if%>
							</table>
						</td>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
			<% 
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'SECURITY EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%>
			<div id="workspace_security" name="workspace_security" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table1">
					<tr>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top>
							<table cellpadding=0 cellspacing=0 border=0 ID="Table2">
								<tr>
									<td class="bodyText" colspan=3 valign=top>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<img src="./../images/spacer.gif" id="PermissionWarningImg"><b>Permissions</b>
										</font>
									</td>
								</tr>
								<tr>
									<td>
										<script language="javascript" src="./../../app_include/lockscroll_div.js"></script><!--locked headers code-->
										<script language="javascript" src="./../../app_include/autoColSize_div.js"></script><!--column resizing code-->
										<style type="text/css">
											.scrollingDiv_colHeaderText { font-family: Arial, Helvetica, Sans-Serif; font-size: 11px; line-height: 14px; color: #000; } 
											.scrollingDiv_headerText    { font-family: Arial, Helvetica, Sans-Serif; font-size: 12px; line-height: 14px; color: #000; font-weight: bold; } 
											.scrollingDiv_bodyText      { font-family: Arial, Helvetica, Sans-Serif; font-size: 12px; line-height: 15px; color: #000; } 
											.scrollingDiv_separatorBar  { background-color: #666; } 
											#boundingBox	{width: 450px; height: 365px; clip: auto; overflow: hidden; margin-top: 2px; background-color: #fff; border: 1px solid #666;}
											#dataHeader		{width: 100%; height: 15px; clip: auto; overflow: hidden; background-color: #ccc; border-bottom: 1px solid #666;}
											#dataBody		{width: 100%; height: 350px; clip: auto; overflow: scroll;}
										</style>
										<%
										Dim objSecurityPrivilegeRec, objSecurityUserRec, x, z
										Dim Security_Privileges, Security_Privileged_Objects, Security_Privileged_Objects_XML
										
										Set objSecurityPrivilegeRec			= Server.CreateObject("ADODB.RecordSet")
										Set objSecurityUserRec				= Server.CreateObject("ADODB.RecordSet")
										Set Security_Privileges				= New cls_Security_Privileges
										Set Security_Privileged_Objects		= New cls_Security_Privileged_Objects
										
										Set objSecurityPrivilegeRec = Security_Privileges.All(Security.CurrentScopeConstant, 1)
										if not objSecurityPrivilegeRec.EOF then
										%>
										<div id="boundingBox">
											<div id="dataHeader">
												<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table3">
													<tr>
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap=true id="col_0" valign=bottom class="scrollingDiv_colHeaderText">
															Name
														</td>
														
														<%
														x = 1
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=4></td>
														<td class="scrollingDiv_separatorBar"><img src="./../images/spacer.gif" height=1 width=1></td>
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap=true id="col_<%=x%>" valign=bottom class="scrollingDiv_colHeaderText" align=center>
															<%=SmartValues(objSecurityPrivilegeRec("Privilege_ShortName"), "CStr")%>
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														x = x + 1
														Loop
														%>

														<td><img src="./../images/spacer.gif" height=1 width=100></td>
														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
												</table>
											</div>

											<div id="dataBody">
												<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table4">
												<%
												SQLStr = "sp_security_list_roles"
												objSecurityUserRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objSecurityUserRec.EOF then
												%>
													<tr><td colspan=20 nowrap class="scrollingDiv_bodyText" style="background: #ececec; padding-left: 5px; color: #666; border-top: 1px solid #999; border-bottom: 1px solid #999;">Roles</td></tr>
												<%
													z = 0
													Do Until objSecurityUserRec.EOF
														if not objSecurityUserRec("System_Role") then
															if z mod 2 = 1 then				
																rowcolor = "fcf9f6"
															else
																rowcolor = "ffffff"
															end if 
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
													<tr bgcolor="<%=rowcolor%>">
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap class="scrollingDiv_bodyText">
															<%=objSecurityUserRec("Group_Name")%> 
														</td>

														<%
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=10></td>
														<td nowrap valign=top class="scrollingDiv_bodyText" align=center>
															<input type=checkbox name="chk_priv_<%=SmartValues(objSecurityPrivilegeRec("ID"), "CStr")%>" value="role_<%=objSecurityUserRec("ID")%>"<%if Security_Privileged_Objects.isRequestedAccessToObjectAllowed(objSecurityPrivilegeRec("ID"), Security.CurrentPrivilegedObjectID, 0, objSecurityUserRec("ID")) then Response.Write " CHECKED" end if%> ID="Checkbox1"><!-- Privilege: <%=SmartValues(objSecurityPrivilegeRec("Constant"), "CStr")%> -->
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														Loop
														%>

														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
												<%
															z = z + 1
														end if
														objSecurityUserRec.MoveNext
													Loop
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=10 width=1></td></tr>
												<%
												end if
												objSecurityUserRec.Close

												SQLStr = "sp_security_list_groups"
												objSecurityUserRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objSecurityUserRec.EOF then
												%>
													<tr><td colspan=20 nowrap class="scrollingDiv_bodyText" style="background: #ececec; padding-left: 5px; color: #666; border-top: 1px solid #999; border-bottom: 1px solid #999;">Groups</td></tr>
												<%
													z = 0
													Do Until objSecurityUserRec.EOF
														if z mod 2 = 1 then				
															rowcolor = "fcf9f6"
														else
															rowcolor = "ffffff"
														end if 
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
													<tr bgcolor="<%=rowcolor%>">
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap class="scrollingDiv_bodyText">
															<%=objSecurityUserRec("Group_Name")%> 
														</td>

														<%
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=10></td>
														<td nowrap valign=top class="scrollingDiv_bodyText" align=center>
															<input type=checkbox name="chk_priv_<%=SmartValues(objSecurityPrivilegeRec("ID"), "CStr")%>" value="group_<%=objSecurityUserRec("ID")%>"<%if Security_Privileged_Objects.isRequestedAccessToObjectAllowed(objSecurityPrivilegeRec("ID"), Security.CurrentPrivilegedObjectID, 0, objSecurityUserRec("ID")) then Response.Write " CHECKED" end if%> ID="Checkbox2"><!-- Privilege: <%=SmartValues(objSecurityPrivilegeRec("Constant"), "CStr")%> -->
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														Loop
														%>

														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
												<%
														z = z + 1
														objSecurityUserRec.MoveNext
													Loop
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=10 width=1></td></tr>
												<%
												end if
												objSecurityUserRec.Close

												SQLStr = "sp_security_list_users"
												objSecurityUserRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objSecurityUserRec.EOF then
												%>
													<tr><td colspan=20 nowrap class="scrollingDiv_bodyText" style="background: #ececec; padding-left: 5px; color: #666; border-top: 1px solid #999; border-bottom: 1px solid #999;">Admin Users</td></tr>
												<%
													z = 0
													Do Until objSecurityUserRec.EOF
														if z mod 2 = 1 then				
															rowcolor = "fcf9f6"
														else
															rowcolor = "ffffff"
														end if 
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
													<tr bgcolor="<%=rowcolor%>">
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap class="scrollingDiv_bodyText">
															<%=objSecurityUserRec("UserName")%>
														</td>

														<%
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=10></td>
														<td nowrap valign=top class="scrollingDiv_bodyText" align=center>
															<input type=checkbox name="chk_priv_<%=SmartValues(objSecurityPrivilegeRec("ID"), "CStr")%>" value="user_<%=objSecurityUserRec("ID")%>"<%if Security_Privileged_Objects.isRequestedAccessToObjectAllowed(objSecurityPrivilegeRec("ID"), Security.CurrentPrivilegedObjectID, objSecurityUserRec("ID"), 0) then Response.Write " CHECKED" end if%> ID="Checkbox3"><!-- Privilege: <%=SmartValues(objSecurityPrivilegeRec("Constant"), "CStr")%> -->
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														Loop
														%>

														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
												<%
														z = z + 1
														objSecurityUserRec.MoveNext
													Loop
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=10 width=1></td></tr>
												<%
												end if
												objSecurityUserRec.Close
												%>
													<tr style="visibility:none;">
														<td><img src="./../images/spacer.gif" height=1 width=1></td>
														<td id="col_0_data"><img id="col_0_dataimg" src="./../images/spacer.gif" height=1 width=100></td>
														<%
														x = 1
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=1></td>
														<td id="col_<%=x%>_data"><img id="col_<%=x%>_dataimg" src="./../images/spacer.gif" height=1 width=30></td>
														<%
														objSecurityPrivilegeRec.MoveNext
														x = x + 1
														Loop
														%>

														<td><img src="./../images/spacer.gif" height=1 width=1></td>
													</tr>
												</table>
											</div>
										</div>
										<div class="bodyText"><input type="checkbox" value="1" name="PropogatePrivilegesToChildren" ID="PropogatePrivilegesToChildren" onclick="if(document.theForm.PropogatePrivilegesToChildren.checked){return confirm(' W A R N I N G !   W A R N I N G !   W A R N I N G !    \n\nSelecting this option will replace security settings\non ALL child categories below this category.\n\nThere is no Undo!\n\nAre you really sure?')};"><label for="PropogatePrivilegesToChildren">Propagate these security settings to all child categories when I save.</label></div>
										<%
										else
										%>
										<div id="EOF_Message" class="bodyText" style="color: #999;">
											<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
											There are no Privileges that can be set on this object.
											</font>
										</div>
										<%
										end if
										Set objSecurityPrivilegeRec = Nothing
										Set objSecurityUserRec = Nothing
										%>

									</td>
								</tr>
							</table>
						</td>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<input type=hidden name="cid" value="<%=categoryID%>">
	<input type=hidden name="pcid" value="<%=parentCategoryID%>">
	<input type=hidden name="boolIsNew" value="<%=boolIsNew%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "category_details_header.asp?cid=<%=categoryID%>";
		parent.frames["controls"].document.location = "category_details_footer.asp?cid=<%=categoryID%>";
	//-->
</script>

</body>
</html>

<%
Call DB_CleanUp
Sub DB_CleanUp
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

Set arDetailsDataRows = Nothing
Set dictDetailsDataCols = Nothing
%>