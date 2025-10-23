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
Dim groupID, boolIsNew
Dim Group_Name, Group_Summary
Dim Start_Date, End_Date, Date_Created, Date_Last_Modified
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime
Dim strPrivileges, arPrivileges, privilege
Dim rowCounter, curIteration
Dim arDataRows, dictDataCols
Dim arSecurityDataRows, dictSecurityDataCols
Dim arScheduleDataRows, dictScheduleDataCols
Dim boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim Num_Members

Set dictDataCols	= Server.CreateObject("Scripting.Dictionary")

groupID = Request("gid")
if IsNumeric(groupID) then
	groupID = CInt(groupID)
else
	groupID = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

if groupID = 0 then
	boolIsNew = true
	Num_Members = 0
else
	boolIsNew = false
	Call returnDataWithGetRows(connStr, "sp_security_group_details " & groupID, arDataRows, dictDataCols)
	Num_Members = SmartValues(arDataRows(dictDataCols("Num_Members"), 0), "CLng")
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
	<div style="padding-top: 10px; padding-bottom: 0px; width: 100%;">
		<div style="font-weight: bold; color: #333; width: 100%;"><%=objScopeRec("Scope_Name")%>&nbsp;&nbsp;<span style="font-weight: normal; font-size: 10px;">(<a href="" onclick="toggleAllByID('strPrivileges','_<%=objScopeRec("ID")%>$'); return false;">Toggle These</a>)</span></div>
		<%Call enumeratePrivilegesByScope(objScopeRec("Constant"), 0)%>
		<div style="padding-left: 24px;">
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
	<div style="border-top: 1px dotted #ccc; padding-top: 2px; padding-bottom: 2px; width: 100%; white-space: nowrap;">
		<input type="checkbox" value="<%=objPrivilegeRec("ID")%>" name="strPrivileges" id="chkPermissions_<%=objPrivilegeRec("ID")%>_<%=objPrivilegeRec("Scope_ID")%>"<%=findNeedleInHayStack(arPrivileges, objPrivilegeRec("ID"), " CHECKED")%> />
		<label for="chkPermissions_<%=objPrivilegeRec("ID")%>_<%=objPrivilegeRec("Scope_ID")%>" title="<%=Server.HTMLEncode(objPrivilegeRec("Privilege_Summary"))%>"><%=objPrivilegeRec("Privilege_Name")%></label>
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
	<title><%if boolIsNew then%>Add<%else%>Edit<%end if%> Group</title>
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
				
				case "securityTab":
					workspace_security.style.display = "";
					break;
				
				case "scheduleTab":
					workspace_schedule.style.display = "";
					break;

				case "userTab":
					workspace_users.style.display = "";
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
					break;
				
				case "scheduleTab":
					workspace_schedule.style.display = "";
					break;
				
				case "userTab":
					workspace_users.style.display = "";
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
			workspace_schedule.style.display = "none";
			workspace_users.style.display = "none";
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
			if (checkRequiredField(document.theForm.Group_Name))
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
	<form name="theForm" action="security_group_details_work.asp" method="POST" onSubmit="doSubmit();">
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="../images/spacer.gif" height=400 width=1 border=0></td>
		<td width="100%" valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDataCols("ColCount") > 0 and dictDataCols("RecordCount") > 0 then
				Group_Name = SmartValues(arDataRows(dictDataCols("Group_Name"), 0), "CStr")
				Group_Summary = SmartValues(arDataRows(dictDataCols("Group_Summary"), 0), "CStr")

				Date_Created = SmartValues(arDataRows(dictDataCols("Date_Created"), 0), "CDate")
				Date_Last_Modified = SmartValues(arDataRows(dictDataCols("Date_Last_Modified"), 0), "CDate")
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
									<td class="bodyText">Group Name</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Group_Name" value="<%=Group_Name%>" AutoComplete="off" style="width: 250px;"></td>
								</tr>
								<tr><td colspan=3><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td class="bodyText"valign="top">Group Summary</td>
									<td></td>
									<td><textarea wrap="virtual" name="Group_Summary" rows=10 cols=45 style="width: 250px;"><%=Group_Summary%></textarea></td>
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
			'SECURITY EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDataCols("ColCount") > 0 and dictDataCols("RecordCount") > 0 then
				strPrivileges = SmartValues(arDataRows(dictDataCols("Privilege_List"), 0), "CStr")
				arPrivileges = Split(strPrivileges,",")
			end if
			%>
			<div id="workspace_security" name="workspace_security" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top width="100%">
							<table width=100% cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td class="bodyText" colspan=3 valign=top><b>Permissions</b>&nbsp;&nbsp;<span style="font-weight: normal; font-size: 10px;">(<a href="" onclick="checkAllByID('strPrivileges','^chkPermissions_'); return false;">Check All</a> | <a href="" onclick="uncheckAllByID('strPrivileges','^chkPermissions_'); return false;">Uncheck All</a>)</span></td>
								</tr>
								<tr>
									<td class="bodyText" colspan=3>
										<div class="bodyText" style="background: #fff; border: 0; padding: 10px; padding-top: 0px; height: 370px; width: 100%; clip: auto; overflow: auto;">
										
										<%call enumerateScopes(0)%>
										
										</div>
									</td>
								</tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
					</tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'GROUP MEMBERS EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%>
			<div id="workspace_users" name="workspace_users" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top width="100%">
							<table width=100% cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td class="bodyText" colspan=3 valign=top><b>Members of this Group</b><%if Num_Members > 0 then%>&nbsp;&nbsp;(<%=Num_Members%> current members highlighted in gray)<%end if%>&nbsp;&nbsp;<span style="font-weight: normal; font-size: 10px;">(<a href="" onclick="checkAllByID('chkSelectedUsers','^chkSelectedUsers_'); return false;">Check All</a> | <a href="" onclick="uncheckAllByID('chkSelectedUsers','^chkSelectedUsers_'); return false;">Uncheck All</a>)</span></td>
								</tr>
								<tr>
									<td class="bodyText" colspan=3>
										<div class="bodyText" style="background: #fff; border: 0; padding: 10px; height: 370px; width: 100%; clip: auto; overflow: auto;">
										
										<%
										SQLStr = "SELECT u.*, (CASE WHEN COALESCE(ug.ID, 0) > 0 THEN 1 ELSE 0 END) As Is_Member " & _
												" FROM Security_User u " & _
												" LEFT OUTER JOIN Security_User_Group ug ON ug.User_ID = u.ID AND ug.Group_ID = '0" & groupID & "'" & _
												" Where u.Deleted = 0 " & _
												" ORDER BY First_Name, Last_Name, UserName, u.ID "
										objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
										if not objRec.EOF then
											i = 0
											Do Until objRec.EOF
										%>
											<div class="bodyText" style="white-space: nowrap; <%if i > 0 then%>border-top: 1px dotted #ccc; <%end if%>padding-top: 2px; padding-bottom: 2px; width: 100%; <%if CInt(objRec("Is_Member")) = 1 then%>background: #ececec;<%end if%>">
												<input type=checkbox name="chkSelectedUsers" id="chkSelectedUsers_<%=objRec("ID")%>" value="<%=objRec("ID")%>" style="margin-right: 5px;"<%if CInt(objRec("Is_Member")) = 1 then%> checked<%end if%>>
												<label for="chkSelectedUsers_<%=objRec("ID")%>"><%=objRec("First_Name") & " "%><%=objRec("Last_Name")%>&nbsp;(<%=objRec("UserName")%>)</label>
											</div>
										<%	
												i = i + 1
												objRec.MoveNext
											Loop
										
										end if
										%>
										
										</div>
									</td>
								</tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
					</tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'LIFESPAN EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDataCols("ColCount") > 0 and dictDataCols("RecordCount") > 0 then
				boolUseSchedule = false
				if not IsNull(arDataRows(dictDataCols("Start_Date"), 0)) and IsDate(arDataRows(dictDataCols("Start_Date"), 0)) then
					txtStartDate = FormatDateTime(CDate(arDataRows(dictDataCols("Start_Date"), 0)), vbShortDate)
					txtStartTime = FormatDateTime(CDate(arDataRows(dictDataCols("Start_Date"), 0)), vbShortTime)
					boolUseStartDate = true
					boolUseSchedule = true
				end if
				if not IsNull(arDataRows(dictDataCols("End_Date"), 0)) and IsDate(arDataRows(dictDataCols("End_Date"), 0)) then
					txtEndDate = FormatDateTime(CDate(arDataRows(dictDataCols("End_Date"), 0)), vbShortDate)
					txtEndTime = FormatDateTime(CDate(arDataRows(dictDataCols("End_Date"), 0)), vbShortTime)
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
												<td class="bodyText" nowrap=true><span style="cursor:hand" onClick="document.theForm.boolUseSchedule[0].checked=true;">This contact is always available.</span></td>
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
																				<span style="cursor:hand" onClick="document.theForm.boolUseStartDate[0].checked=true;">This contact is available immediately after it is saved.</span>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseStartDate"<%if boolUseStartDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;">This contact will be available on the following date:</span>
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
																				<span style="cursor:hand" onClick="document.theForm.boolUseEndDate[0].checked=true;">This contact never expires.</span>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseEndDate"<%if boolUseEndDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;">This contact will end on the following date:</span>
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
	<input type=hidden name="gid" value="<%=groupID%>">
	<input type=hidden name="boolIsNew" value="<%=boolIsNew%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "security_group_details_header.asp?gid=<%=groupID%>";
		parent.frames["controls"].document.location = "security_group_details_footer.asp?gid=<%=groupID%>";
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

Set arDataRows = Nothing
Set dictDataCols = Nothing
%>