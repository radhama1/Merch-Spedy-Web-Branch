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
Security.Initialize Session.Value("UserID"), "ADMIN.WEBSITES.WEBSITE", checkQueryID(Request("wid"), 0)


Dim websiteID, boolIsNewWebsite
Dim winTitle
Dim objConn, objRec, SQLStr, connStr, i, rowcolor
Dim Website_ID, Website_GUID, Website_Name, Website_Summary, isEnabled
Dim Website_Language_ID, Website_Keywords, Website_Abstract
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime
Dim Staging_URL, Staging_Path, Live_URL, Live_Path
Dim Staging_Allow_Anon, Live_Allow_Anon

Dim rowCounter, curIteration
Dim arWebsiteDataRows, dictWebsiteDataCols
Dim arPromotionDataRows_Staging, dictPromotionDataCols_Staging
Dim arPromotionDataRows_Live, dictPromotionDataCols_Live

Dim boolUseSchedule, boolUseStartDate, boolUseEndDate

Set dictWebsiteDataCols		= Server.CreateObject("Scripting.Dictionary")
Set dictPromotionDataCols_Staging	= Server.CreateObject("Scripting.Dictionary")
Set dictPromotionDataCols_Live	= Server.CreateObject("Scripting.Dictionary")

websiteID = checkQueryID(Request("wid"), 0)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if websiteID = 0 then
	boolIsNewWebsite = true
else
	boolIsNewWebsite = false

	Call returnDataWithGetRows(connStr, "sp_websites_return_website_details " & websiteID, arWebsiteDataRows, dictWebsiteDataCols)
	Call returnDataWithGetRows(connStr, "sp_websites_return_website_promotion_details " & websiteID & ", 1", arPromotionDataRows_Staging, dictPromotionDataCols_Staging)
	Call returnDataWithGetRows(connStr, "sp_websites_return_website_promotion_details " & websiteID & ", 2", arPromotionDataRows_Live, dictPromotionDataCols_Live)
end if

%>
<html>
<head>
	<title><%if boolIsNewWebsite then%>Add Website<%else%>Edit Website:&nbsp;&nbsp;"<%=winTitle%>"<%end if%></title>
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
				
				case "promotionTab":
					workspace_promotion.style.display = "";
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
				
				case "promotionTab":
					workspace_promotion.style.display = "";
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
			workspace_promotion.style.display = "none";
			workspace_security.style.display = "none";
			workspace_schedule.style.display = "none";
		}
				
		//called when the Calendar icon is clicked
		function dateWin(field)
		{ 
			hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
			hwnd.focus();
		}
		
		function showSampleURL()
		{
			var msg = "Enter any valid root-level URL, omitting protocol prefixes \(\"http\:\/\/\"\),\npath details and file-specific details \(\"index.htm\"\).\n\n";
			msg = msg + "For example:\n\n";
			msg = msg + "\t- 207.208.244.58\:97\n";
			msg = msg + "\t- www.google.com\n";

			alert(msg);
		}
		
		function showSamplePath()
		{
			var msg = "Enter any valid web path, omitting the root URL, protocol prefixes \(\"http\:\/\/\"\)\nand file-specific details \(\"index.htm\"\).\n\n";
			msg = msg + "For example:\n\n";
			msg = msg + "\t- \/staging\/root\n";
			msg = msg + "\t- \/www\/documents\n";

			alert(msg);
		}

	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="website_details_work.asp" method="POST">
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="../images/spacer.gif" height=400 width=10 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictWebsiteDataCols("ColCount") > 0 and dictWebsiteDataCols("RecordCount") > 0 then
				Website_ID = SmartValues(arWebsiteDataRows(dictWebsiteDataCols("ID"), 0), "CLng")
				Website_GUID = SmartValues(arWebsiteDataRows(dictWebsiteDataCols("Access_Key"), 0), "CStr")
				Website_Name = SmartValues(arWebsiteDataRows(dictWebsiteDataCols("Website_Name"), 0), "CStr")
				Website_Summary = SmartValues(arWebsiteDataRows(dictWebsiteDataCols("Website_Summary"), 0), "CStr")
				Website_Language_ID = SmartValues(arWebsiteDataRows(dictWebsiteDataCols("Website_Language_ID"), 0), "CInt")
				Website_Keywords = SmartValues(arWebsiteDataRows(dictWebsiteDataCols("Website_Keywords"), 0), "CStr")
				Website_Abstract = SmartValues(arWebsiteDataRows(dictWebsiteDataCols("Website_Abstract"), 0), "CStr")
			end if
			%>
			<div id="workspace_description" name="workspace_description" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td nowrap=true width=100% valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Website Name</b>
										</font>
									</td>
								</tr>
								<tr><td><input type="text" size=60 maxlength=500 name="Website_Name" value="<%=Website_Name%>" AutoComplete="off"></td></tr>
								<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<b>Administrator's Notes</b>
													</font>
												</td>
											</tr>
											<tr>
												<td><textarea wrap="off" name="Website_Summary" rows=5 cols=45><%=Website_Summary%></textarea></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<%
								SQLStr = "SELECT ID, Language_PrettyName, Language_LongName FROM app_languages ORDER BY isDefault DESC, SortOrder, Language_PrettyName, [ID]"
								objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
								if not objRec.EOF then
								%>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Default Language</b>
										</font>
									</td>
								</tr>
								<tr>
									<td>
										<select name="Website_Language_ID" style="width: 250px;" id="Website_Language_ID">
										<%
										Do Until objRec.EOF
										%>
											<option value="<%=objRec("ID")%>"<%if Website_Language_ID = objRec("ID") then Response.Write " SELECTED"%>><%=objRec("Language_PrettyName")%> (<%=Server.HTMLEncode(objRec("Language_LongName"))%>)
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
								<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Global Keywords for Search Engines (optional, comma-separated list)</b>
										</font>
									</td>
								</tr>
								<tr>
									<td><input type="text" size=60 maxlength=500 name="Website_Keywords" value="<%=Website_Keywords%>" AutoComplete="off"></td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Global Description for Search Engines (optional)</b>
										</font>
									</td>
								</tr>
								<tr>
									<td><textarea wrap="none" name="Website_Abstract" rows=3 cols=45><%=Website_Abstract%></textarea></td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<table border=0 cellpadding=0 cellspacing=0>
											<tr>
												<td style="font-family:Arial, Helvetica;font-size:12px;color:#666"><b>Website&nbsp;ID:</b><td>
												<td>&nbsp;&nbsp;&nbsp;</td>
												<td style="font-family:Arial, Helvetica;font-size:12px;color:#000000"><%=Website_ID%></td>
											</tr>
											<tr>
												<td style="font-family:Arial, Helvetica;font-size:12px;color:#666"><b>Website&nbsp;Key:</b><td>
												<td>&nbsp;&nbsp;&nbsp;</td>
												<td style="font-family:Arial, Helvetica;font-size:12px;color:#000000"><%=Replace(Replace(Website_GUID, "{", ""), "}", "")%></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'PROMOTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictPromotionDataCols_Staging("ColCount") > 0 and dictPromotionDataCols_Staging("RecordCount") > 0 then
				Staging_URL = SmartValues(arPromotionDataRows_Staging(dictPromotionDataCols_Staging("Promotion_State_URL"), 0), "CStr")
				Staging_Path = SmartValues(arPromotionDataRows_Staging(dictPromotionDataCols_Staging("Promotion_State_Path"), 0), "CStr")
				Staging_Allow_Anon = CBool(arPromotionDataRows_Staging(dictPromotionDataCols_Staging("Allow_Anon_Access"), 0))
			end if
			if dictPromotionDataCols_Live("ColCount") > 0 and dictPromotionDataCols_Live("RecordCount") > 0 then
				Live_URL = SmartValues(arPromotionDataRows_Live(dictPromotionDataCols_Live("Promotion_State_URL"), 0), "CStr")
				Live_Path = SmartValues(arPromotionDataRows_Live(dictPromotionDataCols_Live("Promotion_State_Path"), 0), "CStr")
				Live_Allow_Anon = CBool(arPromotionDataRows_Live(dictPromotionDataCols_Live("Allow_Anon_Access"), 0))
			end if
			%>
			<div id="workspace_promotion" name="workspace_promotion" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td nowrap=true width=100% valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td valign=top>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:16px;color:#333333">
																<b>Staging Site Settings</b>
																</font>
															</td>
														</tr>
														<tr><td bgcolor=666666><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td bgcolor=ffffff><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#666666">
																<b>Staging Website Location</b>
																</font>
															</td>
														</tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																Provide the location of the staging site.
																</font>
															</td>
														</tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																<b>Staging Website URL</b> (<a href="javascript: void(0); showSampleURL();">example</a>)
																</font>
															</td>
														</tr>
														<tr><td><input type="text" size=30 maxlength=200 name="Staging_URL" value="<%=Staging_URL%>" AutoComplete="off"></td></tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																<b>Staging Website Path</b> (<a href="javascript: void(0); showSamplePath();">example</a>)
																</font>
															</td>
														</tr>
														<tr><td><input type="text" size=30 maxlength=200 name="Staging_Path" value="<%=Staging_Path%>" AutoComplete="off"></td></tr>
														<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
														<tr><td bgcolor=666666><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td bgcolor=ffffff><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#666666">
																<b>Staging Site Access</b>
																</font>
															</td>
														</tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<table cellpadding=0 cellspacing=0 border=0>
																	<tr>
																		<td valign=top><input type=radio value="1" name="Staging_Allow_Anon"<%if Staging_Allow_Anon then Response.Write " CHECKED" end if%>></td>
																		<td><img src="../images/spacer.gif" height=1 width=2 border=0></td>
																		<td>
																			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																			<span style="cursor:hand" onClick="document.theForm.Staging_Allow_Anon[0].checked=true;"><b>Anonymous Access Allowed</b></span><br>
																			All users may view the staging site.
																			</font>
																		</td>
																	</tr>
																	<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
																	<tr>
																		<td valign=top><input type=radio value="0" name="Staging_Allow_Anon"<%if not Staging_Allow_Anon then Response.Write " CHECKED" end if%>></td>
																		<td><img src="../images/spacer.gif" height=1 width=1 border=0></td>
																		<td>
																			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																			<span style="cursor:hand" onClick="document.theForm.Staging_Allow_Anon[1].checked=true;"><b>Authentication Required</b></span><br>
																			Access to the staging site is restricted to authenticated users.
																			</font>
																		</td>
																	</tr>
																</table>
															</td>
														</tr>
													</table>
												</td>
												<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
												<td bgcolor=666666><img src="./images/spacer.gif" height=1 width=1 border=0></td>
												<td bgcolor=ffffff><img src="./images/spacer.gif" height=1 width=1 border=0></td>
												<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
												<td valign=top width="50%">
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:16px;color:#333333">
																<b>Live Site Settings</b>
																</font>
															</td>
														</tr>
														<tr><td bgcolor=666666><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td bgcolor=ffffff><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#666666">
																<b>Live Website Location</b>
																</font>
															</td>
														</tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																Provide the location of the live website.
																</font>
															</td>
														</tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																<b>Live Site URL</b> (<a href="javascript: void(0); showSampleURL();">example</a>)
																</font>
															</td>
														</tr>
														<tr><td><input type="text" size=30 maxlength=200 name="Live_URL" value="<%=Live_URL%>" AutoComplete="off"></td></tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																<b>Live Site Path</b> (<a href="javascript: void(0); showSamplePath();">example</a>)
																</font>
															</td>
														</tr>
														<tr><td><input type="text" size=30 maxlength=200 name="Live_Path" value="<%=Live_Path%>" AutoComplete="off"></td></tr>
														<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
														<tr><td bgcolor=666666><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td bgcolor=ffffff><img src="./images/spacer.gif" height=1 width=1 border=0></td></tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#666666">
																<b>Live Site Access</b>
																</font>
															</td>
														</tr>
														<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
														<tr>
															<td>
																<table cellpadding=0 cellspacing=0 border=0>
																	<tr>
																		<td valign=top><input type=radio value="1" name="Live_Allow_Anon"<%if Live_Allow_Anon then Response.Write " CHECKED" end if%>></td>
																		<td><img src="../images/spacer.gif" height=1 width=2 border=0></td>
																		<td>
																			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																			<span style="cursor:hand" onClick="document.theForm.Live_Allow_Anon[0].checked=true;"><b>Anonymous Access Allowed</b></span><br>
																			All users may view the live site.
																			</font>
																		</td>
																	</tr>
																	<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
																	<tr>
																		<td valign=top><input type=radio value="0" name="Live_Allow_Anon"<%if not Live_Allow_Anon then Response.Write " CHECKED" end if%>></td>
																		<td><img src="../images/spacer.gif" height=1 width=1 border=0></td>
																		<td>
																			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																			<span style="cursor:hand" onClick="document.theForm.Live_Allow_Anon[1].checked=true;"><b>Authentication Required</b></span><br>
																			Access to the live site is restricted to authenticated users.
																			</font>
																		</td>
																	</tr>
																</table>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
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
			%>
			<div id="workspace_security" name="workspace_security" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table1">
					<tr>
						<td><img src="./../../app_images/spacer.gif" height=1 width=10 border=0></td>
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
											#boundingBox	{width: 550px; height: 380px; clip: auto; overflow: hidden; margin-top: 2px; background-color: #ccc; border: 1px solid #666;}
											#dataHeader		{width: 100%; height: 15px; clip: auto; overflow: hidden; background-color: #ccc; border-bottom: 1px solid #666;}
											#dataBody		{width: 100%; height: 362px; clip: auto; overflow: scroll; background-color: #fff;}
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
			if dictWebsiteDataCols("ColCount") > 0 and dictWebsiteDataCols("RecordCount") > 0 then
				boolUseSchedule = false
				if not IsNull(arWebsiteDataRows(dictWebsiteDataCols("Start_Date"), 0)) and IsDate(arWebsiteDataRows(dictWebsiteDataCols("Start_Date"), 0)) then
					txtStartDate = FormatDateTime(CDate(arWebsiteDataRows(dictWebsiteDataCols("Start_Date"), 0)), vbShortDate)
					txtStartTime = FormatDateTime(CDate(arWebsiteDataRows(dictWebsiteDataCols("Start_Date"), 0)), vbShortTime)
					boolUseStartDate = true
					boolUseSchedule = true
				end if
				if not IsNull(arWebsiteDataRows(dictWebsiteDataCols("End_Date"), 0)) and IsDate(arWebsiteDataRows(dictWebsiteDataCols("End_Date"), 0)) then
					txtEndDate = FormatDateTime(CDate(arWebsiteDataRows(dictWebsiteDataCols("End_Date"), 0)), vbShortDate)
					txtEndTime = FormatDateTime(CDate(arWebsiteDataRows(dictWebsiteDataCols("End_Date"), 0)), vbShortTime)
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
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td align=top>
							<table width=500 cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										The following settings determine when this website is available.
										</font>
									</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><input type=radio value="0" name="boolUseSchedule"<%if not boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[0].checked=true;">This website is always available.</span>
													</font>
												</td>
											</tr>
											<tr>
												<td><input type=radio value="1" name="boolUseSchedule"<%if boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true;">Website availability is determined by this schedule.</span>
													</font>
												</td>
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
												<td nowrap=true width=100%>
													<div id="editScheduleOneTime">
														<table cellpadding=0 cellspacing=0 border=0>
															<tr>
																<td>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																	<b>Start Date</b>
																	</font>
																</td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseStartDate"<%if not boolUseStartDate then Response.Write " CHECKED" end if%>></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseStartDate[0].checked=true;">This website is available immediately after it is saved.</span>
																				</font>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseStartDate"<%if boolUseStartDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;">This website will be available on the following date:</span>
																				</font>
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
																			<td nowrap=true>
																				<font style="font-family:Arial,Helvetica;font-size:10px;color:#666666">
																				(MM/DD/YY)
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
															<tr>
																<td>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																	<b>End Date</b>
																	</font>
																</td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseEndDate"<%if not boolUseEndDate then Response.Write " CHECKED" end if%>></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseEndDate[0].checked=true;">This website never expires.</span>
																				</font>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseEndDate"<%if boolUseEndDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;">This website will end on the following date:</span>
																				</font>
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
																			<td nowrap=true>
																				<font style="font-family:Arial,Helvetica;font-size:10px;color:#666666">
																				(MM/DD/YY)
																				</font>
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
	<input type=hidden name="wid" value="<%=websiteID%>">
	<input type=hidden name="boolIsNewWebsite" value="<%=boolIsNewWebsite%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "website_details_header.asp?wid=<%=websiteID%>";
		parent.frames["controls"].document.location = "website_details_footer.asp?wid=<%=websiteID%>";
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

Set arWebsiteDataRows = Nothing
Set dictWebsiteDataCols = Nothing

Set arPromotionDataRows_Staging = Nothing
Set dictPromotionDataCols_Staging = Nothing

Set arPromotionDataRows_Live = Nothing
Set dictPromotionDataCols_Live = Nothing
%>