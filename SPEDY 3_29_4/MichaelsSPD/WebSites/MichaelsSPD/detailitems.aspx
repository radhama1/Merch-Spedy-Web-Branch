<%@ Page Language="VB" AutoEventWireup="false" CodeFile="detailitems.aspx.vb" Inherits="detailitems" ValidateRequest="false"  %>
<%@ Import Namespace="NovaLibra.Common.Utilities" %>
<%@ Register Src="NovaGrid.ascx" TagName="NovaGrid" TagPrefix="ucgrid" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Item Data Management</title>
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
    <link href="nlcontrols/nlcontrols.css" rel="stylesheet" type="text/css" />
<style type="text/css">
th { text-align: left; padding: 5px; }
.formLabel
{
	width: 124px;
	text-align: right;
	white-space: nowrap;
	height: 21px;
	line-height: 21px;
}
.formField
{
	width: 174px;
	height: 21px;
	line-height: 21px;
}

#settingsDiv INPUT.bodyText {height: 20px; padding: 0; margin: 0;}
#settingsDiv .disabled{background: #ececec;}
#settingsDiv SELECT.disabled{background: #ececec;}
#settingsDiv INPUT.disabled{border: 0; padding: 2px; color: #999;}
</style>


	<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/gridcontextmenu.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/SpryValidationTextField.css" rel="stylesheet" type="text/css" />
	
<script src="novagrid/SpryValidationTextField.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/novagrid.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/gridcontextmenu.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/gridajaxedit.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="./detailitems.js?v=139"></script>

</head>
<body oncontextmenu="return false;" onload="preloadItemImages();" style="background-color:#dedede">
    <form id="form1" runat="server">
		<asp:HiddenField ID="hid" runat="server" />
        <asp:HiddenField ID="hdnWorkflowStageID" runat="server" Value="0" />
	<div id="sitediv">
		<div id="bodydiv">
			<div id="header">
				<uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			</div>
			<div id="content">
				<div id="submissiondetail">
					<div style="padding:10px;">
						<table border="0" cellpadding="0" cellspacing="0" width="100%">
						    <tr>
						        <td valign="bottom" style="width: 209px;">
						        <table cellpadding="0" cellspacing="0" border="0" width="209" height="30">
						            <tr>
						                <td id="itemHeaderTab" width="109" height="30" class="tabItemHeader tabItemHeaderOff" align="right" valign="bottom" 
						                    onclick="goUrl('detail.aspx?hid=<%=Request("hid")%>');" 
						                    onmouseover="Element.removeClassName('itemHeaderTab', 'tabItemHeaderOff');Element.addClassName('itemHeaderTab', 'tabItemHeaderOn');" 
						                    onmousedown="Element.removeClassName('itemHeaderTab', 'tabItemHeaderOff');Element.addClassName('itemHeaderTab', 'tabItemHeaderOn');" 
						                    onmouseout="Element.removeClassName('itemHeaderTab', 'tabItemHeaderOn');Element.addClassName('itemHeaderTab', 'tabItemHeaderOff');">
						                <span>Item Header</span>&nbsp;<img runat="server" id="itemHeaderImage" src="images/spacer.gif" alt="" width="11" height="11" border="0" />
						                </td>
						                <td id="itemDetailTab" width="100" height="30" class="tabItemDetail tabItemDetailOn" align="right" valign="bottom" onclick="goUrl('detailitems.aspx?hid=<%=Request("hid")%>');">
						                <span>Item Detail</span>&nbsp;<img runat="server" id="itemDetailImage" src="images/spacer.gif" alt="" width="11" height="11" border="0" />
						                </td>
						            </tr>
						        </table>
						        </td>
						        <td style="width: 15px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="15" /></td>
						        <td style="width: 10px;" valign="bottom">
						            <table cellpadding="0" cellspacing="0" border="0">
						            <tr>
						                <td style="height: 22px; white-space: nowrap;" valign="middle" align="left" nowrap="nowrap">
                                            <asp:HyperLink ID="linkExcel" runat="server" NavigateUrl="#">Excel</asp:HyperLink>
					                        <asp:Label ID="sep1" runat="server" Text=" &nbsp;|&nbsp;  "></asp:Label>
					                        <a href="#" onclick="new Lightbox.base('settingsDiv'); return false;" class="">Settings</a>
						                </td>
						            </tr>
						            </table>
						        </td>
						        <td style="width: 50px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="50" /></td>
						        <td id="validationDisplayTD" runat="server">
                                    <novalibra:NLValidationSummary ID="validationDisplay" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" runat="server" />
                                </td>
						        <td style="width: 100%;" align="right" valign="bottom">
                                    <asp:Label ID="validFlagDisplay" runat="server" Text=""></asp:Label>
						        </td>
						    </tr>
                        </table>
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
								<th valign="top" colspan="2">DOMESTIC ITEM ADDITION &amp; CHANGES
								<asp:Label ID="batch" runat="server" Text=""></asp:Label>
								<asp:Label ID="batchVendorName" runat="server" Text=""></asp:Label>
								<asp:Label ID="stageName" runat="server" Text=""></asp:Label>
								<asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label>
								<asp:HiddenField ID="lastUpdatedMe" runat="server" Value="" />
								</th>
							</tr>
						</table>
					</div>
				</div>
				<!--<div id="detailframe"></div>-->
				<!--<div id="shadowtop"></div>-->
				<div id="main">
					<ucgrid:NovaGrid ID="ItemGrid" GridID="1" runat="server" />
				</div>
			</div>
		</div>
	</div>
	
	<div id="settingsDiv" style="display:none; background: #ececec;">
        <div class="bodyText" style="padding: 5px;" id="settingsdiv2">
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
						        <table cellpadding="0" cellspacing="0" border="0">
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
                                            <%If Not isUserDisabled Then%>  <input type="hidden" name="chk_EnabledCols" value="<%=id%>">
                                            <%End If%>
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
						        <table cellpadding="0" cellspacing="0" border="0">
							        <%
							            Do While i < (ColumnCount * 2) And i < rowCount
							                isUserDisabled = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Allow_UserDisable"), "Boolean")
							                id = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("ID"), "Integer")
							                displayName = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Display_Name"), "String").Replace("<br>", " ").Replace("<br />", " ")
							                defaultDisplay = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Default_UserDisplay"), "Boolean")
							        %>
							        <tr>
							            <td>
									       <input type="checkbox" name="chk_EnabledCols" id="chk_EnabledCols_<%=id%>"<%If Not isUserDisabled Then%> disabled="disabled"<%End If%><%If Not isUserDisabled OrElse ColumnEnabledByUser(id, defaultDisplay) Then%> checked="checked"<%End If%> value="<%=id%>">
                                            <%If Not isUserDisabled Then%>  <input type="hidden" name="chk_EnabledCols" value="<%=id%>">
                                            <%End If%>
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
						        <table cellpadding="0" cellspacing="0" border="0">
							        <%
							            Do While i < rowCount
							                isUserDisabled = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Allow_UserDisable"), "Boolean")
							                id = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("ID"), "Integer")
							                displayName = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Display_Name"), "String").Replace("<br>", " ").Replace("<br />", " ")
							                defaultDisplay = DataHelper.SmartValues(ColumnReader.Tables(0).Rows(i)("Default_UserDisplay"), "Boolean")
							        %>
							        <tr>
								        <td>
									       <input type="checkbox" name="chk_EnabledCols" id="chk_EnabledCols_<%=id%>"<%If Not isUserDisabled Then%> disabled="disabled"<%End If%><%If Not isUserDisabled OrElse ColumnEnabledByUser(id, defaultDisplay) Then%> checked="checked"<%End If%> value="<%=id%>">
                                            <%If Not isUserDisabled Then%>  <input type="hidden" name="chk_EnabledCols" value="<%=id%>">
                                            <%End If%>
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
				        <td><input type=button name="btnCancel" value="Cancel" onclick="closeSettings();"></td>
				        <td width="100%"><img src="./../images/spacer.gif" height="1" width="5" border="0"></td>
				        <td><input type="button" id="btnCommit" value="Okay, Apply these Settings" onclick="closeSettings(true);" />
				        <!--<asp:Button runat="server" ID="btnCommit" Text="Okay, Apply these Settings" />--></td>
			        </tr>
		        </table>
	        </div>
        </div>
	</div>
    
	<script language="javascript" type="text/javascript">
    <!--
    //Effect.toggle('submissiondetail','slide',{duration:0.5, afterFinish:toggleCallbackOnFinish});
    //-->
	</script>
    </form>
    
</body>
</html>
