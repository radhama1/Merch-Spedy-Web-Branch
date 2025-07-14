<%@ Page Language="VB" AutoEventWireup="false" CodeFile="detailsettings.aspx.vb" Inherits="detailsettings" %>
<%@ Import Namespace="NovaLibra.Common.Utilities" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Settings</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
<link rel="stylesheet" href="css/styles.css" type="text/css" />
<style type="text/css">
A {text-decoration: underline; color:#000;}
A:HOVER {text-decoration: underline; color: #00f;}
BODY 
{
	background: #ececec;
}

INPUT.bodyText {height: 20px; padding: 0; margin: 0;}
.disabled{background: #ececec;}
SELECT.disabled{background: #ececec;}		
INPUT.disabled{border: 0; padding: 2px; color: #999;}
</style>
<script language="javascript" type="text/javascript" src="js/prototype.js"></script>
<script language="javascript" type="text/javascript" src="js/scriptaculous.js"></script>
</head>
<body>
<!-- onload="window.resizeTo(650, 640);" -->
    <form id="form1" runat="server">

<div class="bodyText" style="padding: 5px;" id="settingsdiv">
	<div class="headerText" style="color: #999999; margin-left: 10px;display: none;">Display Settings</div>
	<div class="bodyText" style="margin-top: 10px; border: 1px solid #d9d9d9; padding: 10px; background: #fff;">
		<div class="subheaderText">Choose Columns</div>
		<div class="bodyText" style="">Select which columns you wish to view. (Some columns cannot be disabled)</div>

		<div class="bodyText" style="padding-top: 0px;">
		    <table cellpadding="0" cellspacing="0" border="0" style=""><tr><td>
			<table cellpadding="0" cellspacing="0" border="0">
				<%
				    Dim i As Integer = 0
				    If Not ColumnReader Is Nothing AndAlso ColumnReader.Tables(0).Rows.Count > 0 Then
				        Dim rowCount As Integer = ColumnReader.Tables(0).Rows.Count
				        Dim isUserDisabled As Boolean
				        Dim id As Integer
				        Dim displayName As String
				        Dim defaultDisplay As Boolean
				        i = 0
				%>
				<tr>
					<td valign="top" width="33%">
						<table cellpadding=0 cellspacing=0 border=0>
							<%
							    Do While i < ColumnCount And i < rowCount
							        isUserDisabled = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Allow_UserDisable"), "Boolean")
							        id = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("ID"), "Integer")
							        displayName = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Display_Name"), "String").Replace("<br>", " ").Replace("<br />", " ")
							        defaultDisplay = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Default_UserDisplay"), "Boolean")
							%>
							<tr>
								<td>
									<input type="checkbox" name="chk_EnabledCols" id="chk_EnabledCols_<%=id%>"<%If Not isUserDisabled Then%> disabled="disabled"<%End If%><%If Not isUserDisabled OrElse ColumnEnabledByUser(id, defaultDisplay) Then%> checked="checked"<%End If%> value="<%=id%>">
									<%If Not isUserDisabled Then%><input type="hidden" name="chk_EnabledCols" value="<%=id%>"><%End If%>
								</td>
								<td class="bodyText" nowrap="nowrap"><label for="chk_EnabledCols_<%=id%>"><%=displayName%></label></td>
							</tr>
							<%
							    i += 1
							    Loop
							%>
						</table>
					</td>
					<td><img src="./images/spacer.gif" width="20" height="1" alt="" /></td>
					<td valign="top" width="33%">
						<table cellpadding=0 cellspacing=0 border=0>
							<%
							    Do While i < (ColumnCount * 2) And i < rowCount
							        isUserDisabled = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Allow_UserDisable"), "Boolean")
							        id = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("ID"), "Integer")
							        displayName = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Display_Name"), "String").Replace("<br>", " ").Replace("<br />", " ")
							        defaultDisplay = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Default_UserDisplay"), "Boolean")
							%>
							<tr>
								<td>
									<input type="checkbox" name="chk_EnabledCols" id="Checkbox1"<%If Not isUserDisabled %> disabled="disabled"<%End If%><%If Not isUserDisabled OrElse ColumnEnabledByUser(id, defaultDisplay) Then%> checked="checked"<%End If%> value="<%=id%>">
									<%If Not isUserDisabled Then%><input type="hidden" name="chk_EnabledCols" value="<%=id%>"><%End If%>
								</td>
								<td class="bodyText" nowrap="nowrap"><label for="chk_EnabledCols_<%=id%>"><%=displayName%></label></td>
							</tr>
							<%
							    i += 1
							    Loop
							%>
						</table>
					</td>
					<td><img src="./images/spacer.gif" width="20" height="1" alt="" /></td>
					<td valign="top" width="33%">
						<table cellpadding=0 cellspacing=0 border=0>
							<%
							    Do While i < rowCount
							        isUserDisabled = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Allow_UserDisable"), "Boolean")
							        id = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("ID"), "Integer")
							        displayName = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Display_Name"), "String").Replace("<br>", " ").Replace("<br />", " ")
							        defaultDisplay = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Default_UserDisplay"), "Boolean")
							%>
							<tr>
								<td>
									<input type="checkbox" name="chk_EnabledCols" id="Checkbox2"<%If Not isUserDisabled Then%> disabled="disabled"<%End If%><%If Not isUserDisabled OrElse ColumnEnabledByUser(id, defaultDisplay) Then%> checked="checked"<%End If%> value="<%=id%>">
									<%If Not isUserDisabled Then%><input type="hidden" name="chk_EnabledCols" value="<%=id%>"><%End If%>
								</td>
								<td class="bodyText" nowrap="nowrap"><label for="chk_EnabledCols_<%=id%>"><%=displayName%></label></td>
							</tr>
							<%
							    i += 1
							    Loop
							%>
						</table>
					</td>
				</tr>
				<%
				End If
				%>
			</table>
			</td></tr></table>
		</div>
	</div>

	<div class="bodyText" style="margin-top: 10px; border: 1px solid #d9d9d9; padding: 10px; background: #fff;">
		<div class="subheaderText">Startup Filter</div>
		<div class="bodyText" style="">When I log in, show me data using the following filter:</div>

		<div class="bodyText" style="padding-top: 10px;">
			<asp:DropDownList ID="SelectStartupFilter" runat="server" CssClass="bodyText" style="border: 1px inset #ccc; width: 200px;">
			</asp:DropDownList>
		</div>
	</div>

	<div class="bodyText" style="padding-top: 10px;">
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td><input type=button name="btnCancel" value="Cancel" onclick="window.parent.closeSettings();"></td>
				<td width="100%"><img src="./../images/spacer.gif" height="1" width="5" border="0"></td>
				<td><asp:Button runat="server" ID="btnCommit" Text="Okay, Apply these Settings" /></td>
			</tr>
		</table>
	</div>
</div>
<script language="javascript" type="text/javascript">
<!--
//window.parent.setupSettings();
//-->
</script>
    </form>
</body>
</html>
