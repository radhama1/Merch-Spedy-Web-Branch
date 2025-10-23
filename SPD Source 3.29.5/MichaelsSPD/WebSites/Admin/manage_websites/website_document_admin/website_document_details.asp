<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
' Modified for use by nova libra inc.
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.WEBSITES.WEBSITE.DOCUMENT", checkQueryID(Request("tid"), 0)

Dim objConn, objRec, objRec2, SQLStr, connStr, i, rowcolor
Dim elementID, Website_Template_ID, Element_ShortTitle, DisplayInNav, DisplayInSearchResults
Dim Element_Type, Enabled, Element_Abstract, Element_Keywords
Dim Start_Date, End_Date, Date_Created, Date_Last_Modified
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime
Dim strRoles, strGroups, strPrivileges
Dim arRoles, arGroups, arPrivileges
Dim role, group, user, privilege
Dim rowCounter, curIteration
Dim arDataRows, dictDataCols
Dim arSecurityDataRows, dictSecurityDataCols
Dim arScheduleDataRows, dictScheduleDataCols
Dim boolUseSchedule, boolUseStartDate, boolUseEndDate

Set dictDataCols = Server.CreateObject("Scripting.Dictionary")
elementID = checkQueryID(Request("tid"), 0)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

if elementID <> 0 then
	SQLStr = "sp_websites_admin_content_by_elementID " & elementID & ", " & Session.Value("websiteID") & ", 1"
	'Response.Write SQLStr
	Call returnDataWithGetRows(connStr, SQLStr, arDataRows, dictDataCols)
end if
%>
<html>
<head>
	<title>Web Document Settings</title>
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
			if (checkRequiredField(document.theForm.Element_ShortTitle))
			{
				document.theForm.submit();
			}
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onload="parent.window.resizeTo(460, 500); doLoad();">

<table width="100%" cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="website_document_details_work.asp" method="POST" onSubmit="doSubmit();">
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="../images/spacer.gif" height=1 width=1 border=0></td>
		<td width="100%" valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDataCols("ColCount") > 0 and dictDataCols("RecordCount") > 0 then
				Element_ShortTitle = SmartValues(arDataRows(dictDataCols("Element_ShortTitle"), 0), "CStr")
				Element_Abstract = SmartValues(arDataRows(dictDataCols("Element_Abstract"), 0), "CStr")
				Element_Keywords = SmartValues(arDataRows(dictDataCols("Element_Keywords"), 0), "CStr")
				Element_Type = SmartValues(arDataRows(dictDataCols("Element_Type"), 0), "CInt")
				Website_Template_ID = SmartValues(arDataRows(dictDataCols("Website_Template_ID"), 0), "CInt")
				Enabled = CBool(SmartValues(arDataRows(dictDataCols("Enabled"), 0), "CInt"))
				DisplayInNav = CBool(SmartValues(arDataRows(dictDataCols("DisplayInNav"), 0), "CInt"))
				DisplayInSearchResults = CBool(SmartValues(arDataRows(dictDataCols("DisplayInSearchResults"), 0), "CInt"))

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
									<td class="bodyText">Navigation Name</td>
									<td></td>
									<td><input type="text" size=20 maxlength=500 name="Element_ShortTitle" value="<%=Element_ShortTitle%>" AutoComplete="off" style="width: 250px;" onBlur="checkRequiredField(this)"></td>
								</tr>
								<tr>
									<td class="bodyText">Enabled</td>
									<td></td>
									<td><input type="checkbox" name="Enabled" value="1"<%if Enabled then Response.Write " CHECKED"%>></td>
								</tr>
								<tr><td colspan=3><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr bgcolor=666666><td colspan=3><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td colspan=3><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td colspan=3><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td class="bodyText" nowrap>Display Template</td>
									<td></td>
									<td>
										<select name="Website_Template_ID" style="width: 250px;">
											<option value="0">-- Unassigned -- 
											<%
											SQLStr = "sp_websites_template_list_current"
											objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
											if not objRec.EOF then
												Do until objRec.EOF
												%>
											<option value="<%=objRec("ID")%>"<%if Website_Template_ID = CInt(objRec("ID")) then Response.Write " SELECTED"%>><%=objRec("Template_Name")%>
												<%
													objRec.MoveNext
												Loop
											end if
											objRec.Close
											%>
										</select>
									</td>
								</tr>
								<tr>
									<td class="bodyText" nowrap>Display in Site Navigation</td>
									<td></td>
									<td><input type="checkbox" name="DisplayInNav" value="1"<%if DisplayInNav then Response.Write " CHECKED"%>></td>
								</tr>
								<tr>
									<td class="bodyText" nowrap>Display in Search Results</td>
									<td></td>
									<td><input type="checkbox" name="DisplayInSearchResults" value="1"<%if DisplayInSearchResults then Response.Write " CHECKED"%>></td>
								</tr>
								<tr><td colspan=3><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr bgcolor=666666><td colspan=3><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td colspan=3><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td colspan=3><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td class="bodyText" valign="top">Keywords (optional, comma-separated)</td>
									<td></td>
									<td><textarea wrap="virtual" name="Element_Keywords" rows=5 cols=45 style="width: 250px;"><%=Element_Keywords%></textarea></td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td class="bodyText" valign="top">Abstract/Short Description (optional)</td>
									<td></td>
									<td><textarea wrap="virtual" name="Element_Abstract" rows=5 cols=45 style="width: 250px;"><%=Element_Abstract%></textarea></td>
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
			%>
			<div id="workspace_security" name="workspace_security" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table1">
					<tr>
						<td><img src="./../../app_images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top>
							<table cellpadding=0 cellspacing=0 border=0 ID="Table2">
								<tr>
									<td class="bodyText" colspan=3 valign=top>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Permissions</b>
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
											#boundingBox	{width: 400px; height: 310px; clip: auto; overflow: hidden; margin-top: 2px; background-color: #ccc; border: 1px solid #666;}
											#dataHeader		{width: 100%; height: 15px; clip: auto; overflow: hidden; background-color: #ccc; border-bottom: 1px solid #666;}
											#dataBody		{width: 100%; height: 292px; clip: auto; overflow: scroll; background-color: #fff;}
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
						<td><img src="./../../app_images/spacer.gif" height=1 width=20 border=0></td>
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
							<table width=100% cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td class="bodyText">The following settings determine when this document is available.</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><input type=radio value="0" name="boolUseSchedule"<%if not boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td class="bodyText" nowrap=true><span style="cursor:hand" onClick="document.theForm.boolUseSchedule[0].checked=true;">This document is always available.</span></td>
											</tr>
											<tr>
												<td><input type=radio value="1" name="boolUseSchedule"<%if boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td class="bodyText" nowrap=true><span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true;">Availability is determined by this schedule.</span></td>
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
																				<span style="cursor:hand" onClick="document.theForm.boolUseStartDate[0].checked=true;">This document is available now.</span>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseStartDate"<%if boolUseStartDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;">This document will be available on the following date:</span>
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
																				<span style="cursor:hand" onClick="document.theForm.boolUseEndDate[0].checked=true;">This document never expires.</span>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseEndDate"<%if boolUseEndDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td class="bodyText" nowrap=true>
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;">This document will expire on the following date:</span>
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
	<input type=hidden name="tid" value="<%=elementID%>">
	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "website_document_details_header.asp?tid=<%=elementID%>";
		parent.frames["controls"].document.location = "website_document_details_footer.asp?tid=<%=elementID%>";
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