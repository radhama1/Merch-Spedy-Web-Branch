<%@ Page Language="VB" AutoEventWireup="false" CodeFile="reportlist.aspx.vb" Inherits="reportlist" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Item Data Management</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
<style type="text/css">
th { text-align: left; padding: 5px; }
</style>
<script type="text/javascript">
<!--
function showReportExcel(reportid)
{
	document.location = 'reportexcel.aspx?id=' + reportid;
	return false;
}
//-->
</script>
<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
<link href="novagrid/SpryValidationTextField.css" rel="stylesheet" type="text/css" />
<script src="novagrid/SpryValidationTextField.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/novagrid.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="./reportlist.js"></script>

</head>
<body oncontextmenu="return false;">
    <form id="form1" runat="server">
		<asp:HiddenField ID="sort" runat="server" />
        <asp:HiddenField ID="hdnUserID" runat="server" />
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
						        <td>
						            <span class="pageTitle">SPEDY :: REPORTS</span>&nbsp;
						        </td>
						    </tr>
						    <tr>
							    <td colspan="5" style="height: 5px;"><img src="images/spacer.gif" border="0" alt="" height="5" width="1" /></td>
							</tr>
                        </table>
						<table cellpadding="5" cellspacing="0" border="0" width="100%" style="table-layout: fixed">
							<tr>
								<th width="225" style="width: 225px; white-space: nowrap;">Report Name<br /><img src="images/spacer.gif" width="225" height="1" alt="" /></th>
								<th width="450" style="width: 450px; white-space: nowrap;">Report Summary<br /><img src="images/spacer.gif" width="450" height="1" alt="" /></th>
								<th width="70" style="width: 70px; white-space: nowrap;">View<br /><img src="images/spacer.gif" width="70" height="1" alt="" /></th>
								<th width="70" style="width: 70px; white-space: nowrap;">Excel<br /><img src="images/spacer.gif" width="70" height="1" alt="" /></th>
                                <th width="70" style="width: 70px; white-space: nowrap;">Email<br /><img src="images/spacer.gif" width="70" height="1" alt="" /></th>
								<th width="" style="">&nbsp;</th>
							</tr>
							<asp:Repeater ID="reportsRepeater" runat="server">
                            <ItemTemplate>
                            <tr class="tr_light">
							    <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "view")%>"><%#Server.HtmlEncode(DataBinder.Eval(Container.DataItem, "ReportName"))%></a></td>
							    <td valign="top" width="450" style="width: 450px;"><%#Server.HtmlEncode(DataBinder.Eval(Container.DataItem, "ReportSummary"))%></td>
							    <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "view")%>" style='display: <%# IIf(Eval("IsViewable") = True, "static", "none")%>'>View</a></td>
							    <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "excel")%>" style='display: <%# IIf(Eval("IsViewable") = True, "static", "none")%>'>Excel</a></td>
                                <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "email")%>" style='display: <%# IIf(Eval("IsEmailable") = True, "static", "none")%>'>Email</a></td>
							    <td>&nbsp;</td>
							</tr>
                            </ItemTemplate>     
							<AlternatingItemTemplate>
							<tr class="tr_dark">
							    <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "view")%>"><%#Server.HtmlEncode(DataBinder.Eval(Container.DataItem, "ReportName"))%></a></td>
							    <td valign="top" width="450" style="width: 450px;"><%#Server.HtmlEncode(DataBinder.Eval(Container.DataItem, "ReportSummary"))%></td>
							    <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "view")%>" style='display: <%# IIf(Eval("IsViewable") = True, "static", "none")%>'>View</a></td>
							    <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "excel")%>" style='display: <%# IIf(Eval("IsViewable") = True, "static", "none")%>'>Excel</a></td>
                                <td valign="top"><a href="#" onclick="<%#GetLinkClickEvent(Container.DataItem, "email")%>" style='display: <%# IIf(Eval("IsEmailable") = True, "static", "none")%>'>Email</a></td>
							    <td>&nbsp;</td>
							</tr>
							</AlternatingItemTemplate>
							</asp:Repeater>
						</table>
					</div>
				</div>
				<div id="shadowtop"></div>
				<div id="main">
				</div>
			</div>
		</div>
	</div>
	
<!-- report options box -->

<div id="opBox" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:300px; top: 300px; display: none; z-index: 2000; width: 350px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
	<div id="opBoxContent">
	    <table border="0" cellpadding="0" cellspacing="0" class="opBoxBG" style="width: 100%">
	    <tr><td>
	        <table border="0" cellpadding="2" cellspacing="1" style="width: 100%;">
	            <tr>
	                <td colspan="2" id="opBoxHeader"><img align="right" id="close" src="images/close.gif" alt="Close" title="" border="0" onclick="reportOptionsClose();" />Report Options</td>
	            </tr>
	            <!--
	            <tr class="opBoxRow">
	                <td style="width: 100%;"><span id="opBoxColumn">Duplicate Item</span>
	                </td>
	            </tr>
	            -->
	            <tr class="opBoxRow">
	                <td colspan="2"><span style="text-decoration: underline;">Report</span>: &nbsp;<strong><span id="reportName"></span></strong></td>
	            </tr>
	            
	            <tr class="opBoxRow">
	                <td colspan="2">
	                    <input type="hidden" id="reportID" value="" />
	                    <input type="hidden" id="reportOutput" value="" />
	                    <input type="hidden" id="reportOptions" value="" />
                        <input type="hidden" id="reportConstant" value="" />
	                    <span class="opBoxMessage" id="opBoxMessage"></span>
	                    <span class="opBoxErrorMessage" id="opBoxErrorMessage"></span>
	                    &nbsp;
	                </td>
	            </tr>
	            <!--
	            <tr class="opBoxRow">
	                <td colspan="2">&nbsp;</td>
	            </tr>
	            -->
	            <tr class="opBoxRow" id="reportNoOptions">
	                <td colspan="2"><em>Click &quot;Run Report&quot; to run this report.</em></td>
	            </tr>
	            
	            <tr class="opBoxRow" id="reportDateRange">
	                <td colspan="2"><span style="text-decoration: underline;"><asp:Label id="lblDateRange" runat="server" /></span>:&nbsp;</td>
	            </tr>
	            <tr class="opBoxRow" id="reportStartDateRow">
	                <td width="75" align="right">Starting Date</td>
	                <td width="271"><input type="text" id="reportStartDate" runat="server" value="" size="10" maxlength="10" /></td>
	            </tr>
	            <tr class="opBoxRow" id="reportEndDateRow">
	                <td width="75" align="right">Ending Date</td>
	                <td><input type="text" id="reportEndDate" runat="server" value="" size="10" maxlength="10" /></td>
	            </tr>
	            
	            <tr class="opBoxRow" id="reportDateRange2">
	                <td colspan="2">&nbsp;</td>
	            </tr>

                <tr class="opBoxRow" id="reportHoursRow">
	               <td width="75" align="right">Hours Delayed</td>
	               <td><input type="text" id="reportHoursDelayed" runat="server" value="" size="10" maxlength="10" /></td>
	            </tr>
	            	            
	            <tr class="opBoxRow" id="reportVendorRow">
	               <td width="75" align="right">Vendor Num</td>
	               <td><input type="text" id="reportVendorNum" runat="server" value="" size="10" maxlength="10" /></td>
	            </tr>
	            
	            <tr class="opBoxRow" id="reportDeptRow">
	                <td width="75" align="right">Department</td>
	                <td>
                        <asp:DropDownList ID="reportDept" runat="server">
                        </asp:DropDownList>
                    </td>
	            </tr>
	            
	            <tr class="opBoxRow" id="reportItemStatusRow">
	               <td width="75" align="right">Item Status</td>
	               <td><input type="text" id="reportItemStatus" runat="server" value="" size="10" maxlength="10" /></td>
	            </tr>
	            
	            <tr class="opBoxRow" id="reportItemTypeRow">
	                <td width="75" align="right">Item Type</td>
	                <td>
                        <asp:DropDownList ID="reportItemType" runat="server">
                            <asp:ListItem Text="-- All --" Value="" />
                            <asp:ListItem Text="Domestic" Value="1" />
                            <asp:ListItem Text="Import" Value="2" />
                        </asp:DropDownList>
                    </td>
	            </tr>
	            
	            <tr class="opBoxRow" id="reportSKURow">
	               <td width="75" align="right">SKU</td>
	               <td><input type="text" id="reportSKU" runat="server" value="" size="10" maxlength="10" /></td>
	            </tr>
	            
	            <tr class="opBoxRow" id="reportSKUGroupRow">
	               <td width="75" align="right">SKU Group</td>
	               <td><input type="text" id="reportSKUGroup" runat="server" value="" size="20" maxlength="20" /></td>
	            </tr>

	            <tr class="opBoxRow" id="reportStockCategoryRow">
	               <td width="75" align="right">Stock Category</td>
	               <td><input type="text" id="reportStockCategory" runat="server" value="" size="10" maxlength="10" /></td>
	            </tr>

	            <tr class="opBoxRow" id="reportWorkflowRow">
	                <td width="75" align="right">Workflow</td>
	                <td>
                        <asp:DropDownList ID="reportWorkflow" runat="server">
                        </asp:DropDownList>
                    </td>
	            </tr>

                <tr class="opBoxRow" id="reportPOTypeRow">
	                <td width="75" align="right">PO Batch Type</td>
	                <td>
                        <asp:DropDownList ID="reportPOType" runat="server" onchange="GetPOStages()">
                            <asp:ListItem Text="PO Creation" Value="C" />
                            <asp:ListItem Text="PO Maintenance" Value="M" />
                        </asp:DropDownList>
                    </td>
	            </tr>

	            <tr class="opBoxRow" id="reportStageRow">
	                <td width="75" align="right">Stage</td>
	                <td>
                        <select ID="reportStage" runat="server" ></select>&nbsp;&nbsp;
	                </td>
	            </tr>

                <tr class="opBoxRow" id="reportPOStageRow">
	                <td width="75" align="right">Stage</td>
	                <td>
                        <select ID="reportPOStage" runat="server" ></select>&nbsp;&nbsp;
	                </td>
	            </tr>

                <tr class="opBoxRow" id="reportApproverRow">
	                <td width="75" align="right">Approver</td>
	                <td>
                        <asp:DropDownList ID="reportApprover" runat="server">
                        </asp:DropDownList>
                    </td>
	            </tr>

                <tr class="opBoxRow" id="reportMssOrSpedyRow">
	               <td width="75" align="right">MSS/SPEDY</td>
	               <td> <asp:DropDownList ID="reportMssOrSpedy" runat="server">
                            <asp:ListItem Text="-- All --" Value="" />
                            <asp:ListItem Text="MSS" Value="MSS" />
                            <asp:ListItem Text="Non-MSS" Value="SPEDY" />
                        </asp:DropDownList>
	               </td>
	            </tr>
	            
                
                <tr class="opBoxRow" id="reportPLIFrenchRow">
	               <td width="75" align="right">PLI French</td>
	               <td> <asp:DropDownList ID="reportPLIFrench" runat="server">
                            <asp:ListItem Text="-- All --" Value="" />
                            <asp:ListItem Text="Yes" Value="Y" />
                            <asp:ListItem Text="No" Value="N" />
                        </asp:DropDownList>
	               </td>
	            </tr>

                <tr class="opBoxRow" id="reportPOStockCategoryRow">
	               <td width="75" align="right">Stock Category</td>
	               <td> <asp:DropDownList ID="reportPOStockCategory" runat="server">
                            <asp:ListItem Text="-- All --" Value="" />
                            <asp:ListItem Text="Warehouse" Value="W" />
                            <asp:ListItem Text="Domestic" Value="D" />
                        </asp:DropDownList>
	               </td>
	            </tr>

                <tr class="opBoxRow" id="reportPOStatusRow">
	               <td width="75" align="right">Status</td>
	               <td> <asp:DropDownList ID="reportPOStatus" runat="server">
                            <asp:ListItem Text="-- All --" Value="" />
                            <asp:ListItem Text="Approved" Value="2" />
                            <asp:ListItem Text="Completed" Value="4" />
                        </asp:DropDownList>
	               </td>
	            </tr>
	            

	            <tr class="opBoxRow">
	                <td colspan="2">&nbsp;</td>
	            </tr>
	            
	            <tr class="opBoxFooter">
	                <td colspan="2">
	                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;" class="opBoxFooter">
	                        <tr>
	                            <td align="left"><input type="button" id="btnOpBoxClose" onclick="reportOptionsClose()" value="Cancel" class="formButton" style="font-weight: bold;" /></td>
	                            <td align="right"><input type="button" id="btnOpBoxSave" onclick="runReport()" value="Run Report" class="formButton" style="font-weight: bold;" /></td>
	                        </tr>
	                    </table>
	                </td>
	            </tr>
	        </table>
	    </td></tr>
	    </table>
	</div>
</div>
	
	<script language="javascript" type="text/javascript">
    <!--
    initPage();
    //-->
	</script>
    </form>
</body>
</html>
