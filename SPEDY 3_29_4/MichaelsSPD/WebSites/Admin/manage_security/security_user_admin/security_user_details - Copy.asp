<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

%>
<!--#include file="../../app_include/smartValues.asp"-->
<!--#include file="../../app_include/findNeedleInHayStack.asp"-->
<!--#include file="../../app_include/returnDataWithGetRows.asp"-->
<%

Dim objConn, objRec, objRec2, SQLStr, connStr, i
Dim contactID, boolIsNewContact
Dim UserName, Password, Email_Address, Enabled, ID, Last_Name, First_Name, Middle_Name, Title, Suffix, Gender
Dim Language_ID, Comments, Organization, Department, Job_Title, Office_Location
Dim Start_Date, End_Date, Date_Created, Date_Last_Modified
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime
Dim strRoles, strGroups, strPrivileges
Dim arRoles, arGroups, arPrivileges
Dim role, group, user, privilege
Dim rowCounter, curIteration
Dim arContactDataRows, dictContactDataCols
Dim arSecurityDataRows, dictSecurityDataCols
Dim arScheduleDataRows, dictScheduleDataCols
Dim boolUseSchedule, boolUseStartDate, boolUseEndDate

Set dictContactDataCols	= Server.CreateObject("Scripting.Dictionary")

contactID = Request("cid")
if IsNumeric(contactID) then
	contactID = CInt(contactID)
else
	contactID = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

if contactID = 0 then
	boolIsNewContact = true
else
	boolIsNewContact = false
	Call returnDataWithGetRows(connStr, "sp_security_user_details " & contactID, arContactDataRows, dictContactDataCols)
end if

sub enumerateScopes(ByVal thisParentScopeID)
	Dim objScopeRec
	Set objScopeRec = Server.CreateObject("ADODB.RecordSet")

	SQLStr = "sp_security_list_scopes_by_parentScopeID '0" & thisParentScopeID & "', 1"
	'Response.Write SQLStr
	objScopeRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objScopeRec.EOF then
		Do until objScopeRec.EOF
	%>
	<div style="padding-left: 5px; padding-top: 2px; padding-bottom: 0px; width: 100%;">
		<div style="font-weight: bold; color: #333; width: 100%;"><%=objScopeRec("Scope_Name")%>&nbsp;&nbsp;<span style="font-weight: normal; font-size: 10px;">(<a href="" onclick="toggleAllByID('strPrivileges','_<%=objScopeRec("ID")%>$'); return false;">Toggle These</a>)</span></div>
		<%Call enumeratePrivilegesByScope(objScopeRec("Constant"), 0)%>
		<div style="padding-left: 24px; padding-top: 5px;">
		<%Call enumerateScopes(objScopeRec("ID"))%>
		</div>
	</div>
	<%
			objScopeRec.MoveNext
		Loop
	end if
	objScopeRec.Close

	Set objScopeRec = Nothing	
end sub

sub enumeratePrivilegesByScope(thisScopeConstant, thisParentPrivilegeID)
	Dim objPrivilegeRec
	Set objPrivilegeRec = Server.CreateObject("ADODB.RecordSet")

	SQLStr = "sp_security_list_privileges_by_scopeConstant '" & thisScopeConstant & "', '0" & thisParentPrivilegeID & "', 1"
	'Response.Write SQLStr
	objPrivilegeRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objPrivilegeRec.EOF then
		Do until objPrivilegeRec.EOF
	%>
	<div style="border-top: 1px dotted #ccc; padding-top: 2px; padding-bottom: 2px; width: 100%;">
		<div style="float: left;"><input type="checkbox" value="<%=objPrivilegeRec("ID")%>" name="strPrivileges" id="chkPermissions_<%=objPrivilegeRec("ID")%>_<%=objPrivilegeRec("Scope_ID")%>"<%=findNeedleInHayStack(arPrivileges, objPrivilegeRec("ID"), " CHECKED")%> /></div>
		<div style="float: left;">
			<div style=""><label for="chkPermissions_<%=objPrivilegeRec("ID")%>_<%=objPrivilegeRec("Scope_ID")%>" title="<%=Server.HTMLEncode(objPrivilegeRec("Privilege_Summary"))%>"><%=objPrivilegeRec("Privilege_Name")%></label></div>
			<div style="display: none;"><%=objPrivilegeRec("Privilege_Summary")%></div>
		</div>
		<div style="padding-left: 10px;">
		<%Call enumeratePrivilegesByScope(objPrivilegeRec("Constant"), objPrivilegeRec("ID"))%>
		</div>
	</div>
	<%
			objPrivilegeRec.MoveNext
		Loop
	end if
	objPrivilegeRec.Close	

	Set objPrivilegeRec = Nothing	
end sub
%>
<html>
<head>
	<title><%if boolIsNewContact then%>Add<%else%>Edit<%end if%> User</title>
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
	//-->
	</style>
	<script language=javascript>
	<!--
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function initTabs(thisTabName)
		{
			clearMenus();
			switch (thisTabName)
			{
				case "descriptionTab":
					workspace_description.style.display = "";
					break;
				
				case "notesTab":
					workspace_notes.style.display = "";
					break;
				
				case "securityTab":
					workspace_security.style.display = "";
					break;
				
				case "scheduleTab":
					workspace_schedule.style.display = "";
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
				
				case "notesTab":
					workspace_notes.style.display = "";
					break;
				
				case "securityTab":
					workspace_security.style.display = "";
					break;
				
				case "scheduleTab":
					workspace_schedule.style.display = "";
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			workspace_description.style.display = "none";
			workspace_notes.style.display = "none";
			workspace_security.style.display = "none";
			workspace_schedule.style.display = "none";
		}
				
		//called when the Calendar icon is clicked
		function dateWin(field)
		{ 
			hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
			hwnd.focus();
		}
		
		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
			var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=10,screenY=10,scrollbars=yes,titlebar=no,toolbar=no,status=no";
			var newWin = window.open(myLoc, myName, myFeatures);
		}
		
		function checkRequiredField(fld)
		{
			if (fld.value.length <= 0)
			{
				alert("Please specify a value for the " + fld.name + " field.");
				fld.focus();
				fld.select();
				return false;
			}
			return true;
		}
		function doSubmit()
		{
			if (checkRequiredField(document.theForm.UserName) && checkRequiredField(document.theForm.Password) && checkRequiredField(document.theForm.Email_Address))
			{
				document.theForm.submit();
			}
		}

		function toggleAllByID(p_chkCollectionName, p_idPattern)
		{
			if ( document.theForm[p_chkCollectionName].length > 0 )
			{
				for (var i = 0; i < document.theForm[p_chkCollectionName].length; i++)
				{
					var thisItemID = new String(document.theForm[p_chkCollectionName][i].id);
					var pattern = new RegExp(p_idPattern);
					
					if (thisItemID.match(pattern))
					{
						document.theForm[p_chkCollectionName][i].checked = (document.theForm[p_chkCollectionName][i].checked == true) ? false : true;
					}
				}
			}
			else
			{
				document.theForm.p_chkCollectionName.checked = true;
			}
			return false;
		}

		function checkAllByID(p_chkCollectionName, p_idPattern)
		{
			if ( document.theForm[p_chkCollectionName].length > 0 )
			{
				for (var i = 0; i < document.theForm[p_chkCollectionName].length; i++)
				{
					var thisItemID = new String(document.theForm[p_chkCollectionName][i].id);
					var pattern = new RegExp(p_idPattern);

					if (thisItemID.match(pattern))
					{
						document.theForm[p_chkCollectionName][i].checked = true;
					}
				}
			}
			else
			{
				document.theForm.p_chkCollectionName.checked = true;
			}
			return false;
		}

		function uncheckAllByID(p_chkCollectionName, p_idPattern)
		{
			if ( document.theForm[p_chkCollectionName].length > 0 )
			{
				for (var i = 0; i < document.theForm[p_chkCollectionName].length; i++)
				{
					var thisItemID = new String(document.theForm[p_chkCollectionName][i].id);
					var pattern = new RegExp(p_idPattern);

					if (thisItemID.match(pattern))
					{
						document.theForm[p_chkCollectionName][i].checked = false;
					}
				}
			}
			else
			{
				document.theForm.p_chkCollectionName.checked = false;
			}
			return false;
		}

	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width="100%" cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="security_user_details_work.asp" method="POST" onSubmit="doSubmit();">
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="../images/spacer.gif" height=400 width=1 border=0></td>
		<td width="100%" valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictContactDataCols("ColCount") > 0 and dictContactDataCols("RecordCount") > 0 then
				UserName = SmartValues(arContactDataRows(dictContactDataCols("UserName"), 0), "CStr")
				Password = SmartValues(arContactDataRows(dictContactDataCols("Password"), 0), "CStr")
				Email_Address = SmartValues(arContactDataRows(dictContactDataCols("Email_Address"), 0), "CStr")
				Enabled = CBool(SmartValues(arContactDataRows(dictContactDataCols("Enabled"), 0), "CInt"))
				ID = SmartValues(arContactDataRows(dictContactDataCols("ID"), 0), "CLng")
				Last_Name = SmartValues(arContactDataRows(dictContactDataCols("Last_Name"), 0), "CStr")
				First_Name = SmartValues(arContactDataRows(dictContactDataCols("First_Name"), 0), "CStr")
				Middle_Name = SmartValues(arContactDataRows(dictContactDataCols("Middle_Name"), 0), "CStr")
				Title = SmartValues(arContactDataRows(dictContactDataCols("Title"), 0), "CStr")
				Suffix = SmartValues(arContactDataRows(dictContactDataCols("Suffix"), 0), "CStr")
				Gender = SmartValues(arContactDataRows(dictContactDataCols("Gender"), 0), "CStr")
				Language_ID = SmartValues(arContactDataRows(dictContactDataCols("Language_ID"), 0), "CInt")
				Organization = SmartValues(arContactDataRows(dictContactDataCols("Organization"), 0), "CStr")
				Department = Server.HTMLEncode(SmartValues(arContactDataRows(dictContactDataCols("Department"), 0), "CStr"))
				Job_Title = Server.HTMLEncode(SmartValues(arContactDataRows(dictContactDataCols("Job_Title"), 0), "CStr"))
				Office_Location = Server.HTMLEncode(SmartValues(arContactDataRows(dictContactDataCols("Office_Location"), 0), "CStr"))
				Comments = SmartValues(arContactDataRows(dictContactDataCols("Comments"), 0), "CStr")
				Date_Created = SmartValues(arContactDataRows(dictContactDataCols("Date_Created"), 0), "CDate")
				Date_Last_Modified = SmartValues(arContactDataRows(dictContactDataCols("Date_Last_Modified"), 0), "CDate")
			end if
			%>
			<div id="workspace_description" name="workspace_description" style="display:none">
				<table cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width="100%" valign=top>
							<table cellpadding=0 cellspacing=0 border=0 width="100%">
								<tr>
									<td><img src="../images/spacer.gif" height=1 width=130 border=0></td>
									<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
									<td width="100%"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
								</tr>
								<tr>
									<td class="bodyText">Username</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="UserName" value="<%=UserName%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="bodyText">Password</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Password" value="<%=Password%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="bodyText">Email Address</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Email_Address" value="<%=Email_Address%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="bodyText">Enabled</td>
									<td></td>
									<td><input type="checkbox" name="Enabled" value="1"<%if Enabled or boolIsNewContact then Response.Write " CHECKED"%>></td>
								</tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr bgcolor=666666><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td class="bodyText">First Name</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="First_Name" value="<%=First_Name%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="bodyText">Last Name</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Last_Name" value="<%=Last_Name%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr bgcolor=666666><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td class="bodyText">Gender</td>
									<td></td>
									<td>
										<select name="Gender">
											<option value="">
											<option value="M"<%if Gender = "M" then Response.Write " SELECTED"%>>M
											<option value="F"<%if Gender = "F" then Response.Write " SELECTED"%>>F
										</select>
									</td>
								</tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
						<%
						SQLStr = "SELECT ID, Language_PrettyName, Language_LongName FROM app_languages ORDER BY isDefault DESC, SortOrder, Language_PrettyName, [ID]"
						objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
						if not objRec.EOF then
						%>
								<tr>
									<td class="bodyText">Preferred Language</td>
									<td></td>
									<td>
										<select name="Language_ID" style="width: 250px;">
										<%
										Do Until objRec.EOF
										%>
											<option value="<%=objRec("ID")%>"<%if Language_ID = objRec("ID") then Response.Write " SELECTED"%>><%=objRec("Language_PrettyName")%> (<%=Server.HTMLEncode(objRec("Language_LongName"))%>)
										<%
											objRec.MoveNext
										Loop
										%>
										</select>
									</td>
								</tr>
						<%
						end if
						objRec.Close
						%>
								<tr><td colspan=3><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr bgcolor=666666><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td class="bodyText">Organization</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Organization" value="<%=Organization%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="bodyText">Department</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Department" value="<%=Department%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="bodyText">Job Title</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Job_Title" value="<%=Job_Title%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="bodyText">Office Location</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Office_Location" value="<%=Office_Location%>" AutoComplete="off" style="width: 250px;" ID="Text1"></td>
								</tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=20 width=1 border=0></td></tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'OTHER INFO TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%>
			<div id="workspace_notes" name="workspace_notes" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0>
					<tr><td colspan=3><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width="100%" valign=top>
							<table cellpadding=0 cellspacing=0 border=0 width="100%">
								<tr><td class="bodyText" valign=top>Notes/Comments</td></tr>
								<tr><td><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr><td><textarea wrap="virtual" name="Comments" rows=20 cols=45 style="width: 400px;"><%=Comments%></textarea></td></tr>
								<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
					</tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'SECURITY EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictContactDataCols("ColCount") > 0 and dictContactDataCols("RecordCount") > 0 then
				strRoles = SmartValues(arContactDataRows(dictContactDataCols("Group_List"), 0), "CStr")
				arRoles = Split(strRoles,",")
				strGroups = SmartValues(arContactDataRows(dictContactDataCols("Group_List"), 0), "CStr")
				arGroups = Split(strGroups,",")
				strPrivileges = SmartValues(arContactDataRows(dictContactDataCols("Privilege_List"), 0), "CStr")
				arPrivileges = Split(strPrivileges,",")
			end if
			%>
			<div id="workspace_security" name="workspace_security" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top>
							<%if 1 = 1 then%>
							<table width=500 cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<%
												SQLStr = "sp_security_list_roles 1"
												objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objRec.EOF then
												%>
												<td>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td class="bodyText" valign=top><b>Roles</b></td>
														</tr>
														<tr>
															<td>
																<select name="strRoles" multiple=true size=5 style="width: 270px; height: 150px;">
																<%
																Do until objRec.EOF
																%>
																	<option value="<%=objRec("ID")%>"<%=findNeedleInHayStack(arRoles, objRec("ID"), " SELECTED")%>><%=objRec("Group_Name")%>
																<%
																	objRec.MoveNext
																Loop
																%>
																</select>
															</td>
														</tr>
													</table>
												</td>
												<td><img src="./images/spacer.gif" height=1 width=10 border=0></td>
												<%
												end if
												objRec.Close

												SQLStr = "sp_security_list_groups"
												objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objRec.EOF then
												%>
												<td>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td class="bodyText" valign=top><b>Groups</b></td>
														</tr>
														<tr>
															<td>
																<select name="strGroups" multiple=true size=5 style="width: 270px; height: 150px;">
																<%
																Do until objRec.EOF
																%>
																	<option value="<%=objRec("ID")%>"<%=findNeedleInHayStack(arGroups, objRec("ID"), " SELECTED")%>><%=objRec("Group_Name")%>
																<%
																	objRec.MoveNext
																Loop
																%>
																</select>
															</td>
														</tr>
													</table>
												</td>
												<%
												end if
												objRec.Close
												%>
											</tr>
											<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
											<tr>
												<td class="bodyText" colspan=3 valign=top><b>Permissions</b>&nbsp;&nbsp;<span style="font-weight: normal; font-size: 10px;">(<a href="" onclick="checkAllByID('strPrivileges','^chkPermissions_'); return false;">Check All</a> | <a href="" onclick="uncheckAllByID('strPrivileges','^chkPermissions_'); return false;">Uncheck All</a>)</span></td>
											</tr>
											<tr>
												<td class="bodyText" colspan=3>
													<div class="bodyText" style="background: #fff; border: 2px inset #fff; padding: 2px; height: 200px; width: 100%; clip: auto; overflow: auto;">
													<%call enumerateScopes(0)%>
													</div>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
							<%end if%>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'LIFESPAN EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictContactDataCols("ColCount") > 0 and dictContactDataCols("RecordCount") > 0 then
				boolUseSchedule = false
				if not IsNull(arContactDataRows(dictContactDataCols("Start_Date"), 0)) and IsDate(arContactDataRows(dictContactDataCols("Start_Date"), 0)) then
					txtStartDate = FormatDateTime(CDate(arContactDataRows(dictContactDataCols("Start_Date"), 0)), vbShortDate)
					txtStartTime = FormatDateTime(CDate(arContactDataRows(dictContactDataCols("Start_Date"), 0)), vbShortTime)
					boolUseStartDate = true
					boolUseSchedule = true
				end if
				if not IsNull(arContactDataRows(dictContactDataCols("End_Date"), 0)) and IsDate(arContactDataRows(dictContactDataCols("End_Date"), 0)) then
					txtEndDate = FormatDateTime(CDate(arContactDataRows(dictContactDataCols("End_Date"), 0)), vbShortDate)
					txtEndTime = FormatDateTime(CDate(arContactDataRows(dictContactDataCols("End_Date"), 0)), vbShortTime)
					boolUseEndDate = true
					boolUseSchedule = true
				end if
			else
				boolUseSchedule = false
				boolUseStartDate = false
				boolUseEndDate = false
			end if
			%>
			<div id="workspace_schedule" name="workspace_schedule" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top>
							<table width=500 cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td class="bodyText">The following schedule determines when this user account is available.</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><input type=radio value="0" name="boolUseSchedule"<%if not boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td class="bodyText" nowrap=true><span style="cursor:hand" onClick="document.theForm.boolUseSchedule[0].checked=true;">This user account is always available.</span></td>
											</tr>
											<tr>
												<td><input type=radio value="1" name="boolUseSchedule"<%if boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td class="bodyText" nowrap=true><span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true;">User availability is determined by this schedule.</span></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
												<td nowrap=true width="100%">
													<div id="editScheduleOneTime">
														<table cellpadding=0 cellspacing=0 border=0>
															<tr>
																<td class="bodyText"><b>Start Date</b></td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseStartDate"<%if not boolUseStartDate then Response.Write " CHECKED" end if%>></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseStartDate[0].checked=true;">This user account is available immediately after it is saved.</span>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseStartDate"<%if boolUseStartDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;">This user account will be available on the following date:</span>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
															<tr>
																<td nowrap=true>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
																			<td nowrap=true>
																				<input type=text name="txtStartDate" value="<%=txtStartDate%>" size=10 maxlength=10 onFocus="document.theForm.boolUseStartDate[1].checked=true;" AutoComplete="off">
																				<select name="txtStartTime" onFocus="document.theForm.boolUseStartDate[1].checked=true;">
																					<%for i = 0 to 23%>
																					<option value="<%=FormatDateTime(i & ":00", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":00", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":00", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":15", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":15", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":15", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":30", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":30", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":30", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":45", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":45", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":45", vbLongTime)%>
																					<%next%>
																				</select>
																				<a href="javascript:document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;dateWin('txtStartDate');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a>
																			</td>
																		</tr>
																		<tr>
																			<td></td>
																			<td class="bodyText" nowrap=true>
																				(MM/DD/YY)
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
															<tr>
																<td class="bodyText"><b>End Date</b></td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseEndDate"<%if not boolUseEndDate then Response.Write " CHECKED" end if%>></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseEndDate[0].checked=true;">This user account never expires.</span>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseEndDate"<%if boolUseEndDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;">This user account will end on the following date:</span>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
															<tr>
																<td nowrap=true>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
																			<td nowrap=true>
																				<input type=text name="txtEndDate" value="<%=txtEndDate%>" size=10 maxlength=10 onFocus="document.theForm.boolUseEndDate[1].checked=true;" AutoComplete="off">
																				<select name="txtEndTime" onFocus="document.theForm.boolUseEndDate[1].checked=true;">
																					<%for i = 0 to 23%>
																					<option value="<%=FormatDateTime(i & ":00", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":00", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":00", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":15", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":15", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":15", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":30", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":30", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":30", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":45", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":45", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":45", vbLongTime)%>
																					<%next%>
																				</select>
																				<a href="javascript:document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;dateWin('txtEndDate');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a>
																			</td>
																		</tr>
																		<tr>
																			<td></td>
																			<td class="bodyText" nowrap=true>
																				(MM/DD/YY)
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
														</table>
													</div>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<input type=hidden name="cid" value="<%=contactID%>">
	<input type=hidden name="boolIsNewContact" value="<%=boolIsNewContact%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "security_user_details_header.asp?cid=<%=contactID%>";
		parent.frames["controls"].document.location = "security_user_details_footer.asp?cid=<%=contactID%>";
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

Set arContactDataRows = Nothing
Set dictContactDataCols = Nothing
%>