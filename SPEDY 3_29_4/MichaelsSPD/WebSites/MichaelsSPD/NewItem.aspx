<%@ Page Language="VB" AutoEventWireup="false" CodeFile="NewItem.aspx.vb" Inherits="_NewItem" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pagelayout" TagPrefix="headerlayout" %>
<%@ Register Src="Taskheader.ascx" TagName="tasklayout" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache" />
    <title>Item Data Management: Search</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script type="text/javascript" language="javascript" src="NewItem.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>

	<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />

	<link rel="stylesheet" href="css/styles.css" type="text/css"/>
	<style type="text/css">
        .menu td
        {
            padding:5px 0px;
        }
        .selectedPage a
        {
            font-weight:bold;
            color:white;
        }
        .margin1 
        {
            margin-left:3px;
            margin-right:3px;
        }
	</style>

</head>

<%--background = "images/MichaelsBigLogo.GIF"   --%>
<body class="spacer">
<div id="bodydiv" class="margin1">
    <form id="formHome" runat="server">

	<asp:ScriptManager ID="ScriptManager1" runat="server" AsyncPostBackTimeout="7200"></asp:ScriptManager>
    <div id="header">
        <headerlayout:pagelayout ID="headerControl" SendToDefault="true" runat="server" />
	</div>

	<div>
	    <uclayout:tasklayout ID="tabHeader" runat="server" />
	</div>

    <div class="gridTitle">
        <span class="caption">New Item Induction Batches</span>
        <div id="divCreateOptions" runat="server">
            <span class="floatLeft" >&nbsp;&nbsp;&nbsp;&nbsp;
                <asp:LinkButton ID="lnkNewImport" OnCommand="lnkRedir_Command" 
                    CommandName="newItem" CommandArgument="importdetail.aspx" runat="server">Create New Import Batch</asp:LinkButton>
                &nbsp;&nbsp;|&nbsp;&nbsp;
                <asp:LinkButton ID="lnkNewDomestic" OnCommand="lnkRedir_Command" 
                    CommandName="newItem" CommandArgument="detail.aspx" runat="server">Create New Domestic Batch</asp:LinkButton>
                &nbsp;&nbsp;|&nbsp;&nbsp;
                <a href="#" onclick="openUpload('0','1'); return false;" >Upload Item Induction Spreadsheet</a>
            </span>
        </div>
        <span class="floatRight" >
            <span style="font:arial; font-weight:bold;">Show: </span>
            <asp:DropDownList ID="ddFindshowNew" runat="server" Width="140px" AutoPostBack="true">
            </asp:DropDownList>
            &nbsp; 
            <asp:Button ID="btnDDFFindNew" runat="server" Text="go" /> &nbsp; 
        </span>
    </div>
    
    <div class="clearBoth" ></div>

    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true" >
    <Triggers>
        <asp:AsyncPostBackTrigger ControlID="ddFindshowNew" />
        <asp:AsyncPostBackTrigger ControlID="btnDDFFindNew" />
    </Triggers>
    <ContentTemplate>
        <asp:Panel ID="Panel1" runat="server" CssClass="clearBoth">
            <asp:Label ID="lblNewItemMessage" runat="server" style="padding-left:5px;" CssClass="redText"></asp:Label>
            <asp:GridView ID="gvNewBatches" 
                runat="server" 
                Width="100%" 
                BackColor="#dedede" 
                BorderColor="#cecece" 
                BorderWidth="1px" 
                CellPadding="2" 
                ForeColor="Black" 
                GridLines="None" 
                AllowSorting="True"  
                AllowPaging="True" 
                AutoGenerateColumns="False" 
                DataKeyNames="ID" 
                DataSourceID="" 
                Font-Names="Arial" 
                Font-Size="Larger" 
                PageSize="12" 
                HorizontalAlign="Left"
                HeaderStyle-Height = "17px"
                PagerStyle-Height = "17px"
                EnableViewState="true" 
                EmptyDataText="No Batches were found matching your search criteria."
                >
               <Columns>
                    <asp:TemplateField  HeaderText="Vendor" SortExpression="Vendor"  >
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkEditDomestic" OnCommand="lnkRedir_Command" 
                                CommandName="newEdit" 
                                CommandArgument='<%# GetEditURL(Eval("Batch_Type_Desc"), Eval("Header_ID"), Eval("workflow_stage_id"), Eval("Dept_ID")) %>'
                                ToolTip="Show Batch Details"
                                runat="server"><%# Eval("Vendor") %></asp:LinkButton>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" ForeColor="Black" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Log Id" SortExpression="ID" >
                        <ItemTemplate>
                                <a title="Show History for Batch" href='#' onclick="ShowHistory('<%#Eval("ID") %>')" ><%#Eval("ID")%></a> 
                                <br />
                                <%#eval("Batch_Type_Desc") %>
                            </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                        </asp:TemplateField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="DEPT" 
                        HeaderText="Department" 
                        SortExpression="DEPT">
                        <ItemStyle HorizontalAlign="Left"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="Item_Count" 
                        HeaderText="# Items" 
                        SortExpression="Item_Count">
                        <ItemStyle HorizontalAlign="center"/>
                        <HeaderStyle HorizontalAlign="center" />
                    </asp:BoundField>
                    <asp:TemplateField HeaderText="Valid"
                        SortExpression="Valid">
                        <ItemTemplate><img src="<%# GetCheckBoxUrl(Eval("Valid")) %>" alt="Valid" />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <ItemStyle HorizontalAlign="Center" />
                   </asp:TemplateField>
                   <asp:BoundField 
                         HtmlEncode="False"
                        DataField="Workflow_Stage" 
                        HeaderText="Stage" 
                        SortExpression="Workflow_Stage">
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField 
                         HtmlEncode="False"
                        DataField="Approval_Name" 
                        HeaderText="Approver" 
                        SortExpression="Approval_Name">
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:TemplateField 
                        HeaderText="Action">
                        <ItemTemplate>
                            <asp:DropDownList ID="DDAction" runat="server" Width = "100px">
                            </asp:DropDownList>&nbsp;
                            <asp:Button ID="btnGol" 
                                runat="server" 
                                Text="go" 
                                Width = "20px" 
                                CommandName="Action"/>
                         </ItemTemplate>
                         <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" Width="130px" />
                   </asp:TemplateField>
<%--                   <asp:TemplateField>
                        <ItemTemplate>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" />
                       <ItemStyle HorizontalAlign="Left" Width="40px" />
                    </asp:TemplateField>
--%>                    <asp:BoundField DataField="Valid"
                        HeaderText="Valid" 
                        ReadOnly="True" 
                        Visible = "False" 
                        SortExpression="Valid">
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="DateCreated"
                        HeaderText="Created" 
                        ReadOnly="True" 
                        SortExpression="DateCreated">
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="DateModified"
                        HtmlEncode="False"
                        HeaderText="Last Reviewed" 
                        ReadOnly="True" 
                        SortExpression="DateModified">
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <%--following 3 columns used to handle row commands and get ID They are not generated in the grid but kept in viewstate --%>
                    <asp:BoundField DataField="ID" 
                        HeaderText="Log ID" 
                        Visible="False" 
                        ReadOnly="True"
                        SortExpression="ID">
                        <ItemStyle HorizontalAlign="Left" ForeColor="Black" width= "10%"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField DataField="Stage_Type_id"
                        HeaderText="Stage Type ID" 
                        Visible="False" 
                        ReadOnly="True">
                     </asp:BoundField>  
                     <asp:BoundField DataField="Stage_Sequence"
                        HeaderText="Stage Sequence" 
                        Visible="False" 
                        ReadOnly="True">
                     </asp:BoundField>
                     <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HiddenField ID="headerID" runat="server" Value='<%#eval("Header_ID") %>' />
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" width= "0"/>
                     </asp:TemplateField>    
                     <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HiddenField ID="BatchID" runat="server" Value='<%#eval("ID") %>' />
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" width= "0"/>
                     </asp:TemplateField>    
                     <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HiddenField ID="StageID" runat="server" Value='<%#eval("Workflow_Stage_ID") %>' />
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" width= "0"/>
                     </asp:TemplateField>    
                </Columns>
                <FooterStyle BackColor="#cecece" />
                <PagerStyle BackColor="Black" ForeColor="White" HorizontalAlign="Center" Height="17px" />
                <PagerTemplate>
                    <table cellpadding="5px" width="100%" style="margin-left:5px; margin-right:5px;">
                        <tr>
                            <td align="left" width="10%">
                                <asp:Label runat="server" ID="lblFiltered" CssClass="pager" ForeColor="LightGreen"></asp:Label>
                            </td>                        
                            <td align="center">
                                <asp:Label
                                    id="lblBatchesFound"
                                    runat="server"
                                    Text="Batch(es) Found"
                                    Width= "130px"
                                    CssClass="pager"
                                />
                                <asp:LinkButton
                                    id="LinkButton1"
                                    Text="<<"
                                    CommandName="Page"
                                    CommandArgument="First"
                                    ToolTip="First Page"
                                    CssClass="pager"
                                    Runat="server" ForeColor="White"
                                /> &nbsp;
                                <asp:LinkButton
                                    id="lnkPrevious"
                                    Text="<"
                                    CommandName="Page"
                                    CommandArgument="Prev"
                                    ToolTip="Previous Page"
                                    CssClass="pager"
                                    Runat="server"  
                                />  &nbsp;
                                <asp:label
                                    id="PagingInformation"
                                    runat="server"
                                    style="padding-left:5px; padding-right:5px;"
                                    CssClass="pager"
                                    BorderWidth = "0"                    
                                />  &nbsp;
                                <asp:LinkButton
                                    id="lnkNext"
                                    Text=">"
                                    CommandName="Page"
                                    CommandArgument="Next"
                                    ToolTip="Next Page"
                                    CssClass="pager"
                                    Runat="server" 
                                />  &nbsp;
                                <asp:LinkButton
                                    id="LinkButton2"
                                    Text=">>"
                                    CommandName="Page"
                                    CommandArgument="Last"
                                    ToolTip="Last Page"
                                    CssClass="pager"
                                    Runat="server" 
                                />  &nbsp;
                                <asp:button
                                    id="btngo"
                                    runat="server"
                                    width="60px"
                                    height="21px"
                                    style="vertical-align: middle"
                                    text="go to page"
                                    CommandName="PageGo"
                                    CommandArgument = "0"
                                /> 
                                <asp:TextBox
                                    id="txtgotopage"
                                    runat="server"
                                    Width="40px"
                                    CssClass="textBoxPad" 
                                    style="vertical-align: middle"
                                /> &nbsp;&nbsp;
                                <asp:button
                                    id="btnFind"
                                    runat="server"
                                    width="108px" 
                                    height="21px"
                                    style="vertical-align: middle"
                                    text="find batch containing:"
                                    CommandName="PageFind"
                                    CommandArgument = "0"
                                />
                                <asp:TextBox
                                    id="txtBatch"
                                    CssClass="textBoxPad" 
                                    style="vertical-align: middle"
                                    runat="server"
                                    Width="70px" 
                                    tooltip="Enter a Batch Log ID, Dept Name, Vendor Name, VPN, QRN, or SKU"              
                                />
                            </td>
                            <td align="right" >
                                 <asp:Label runat="server" ID="numBatches" style="text-align:right; color:White;"  Text="Batches / Page:"></asp:Label>
                                 <asp:TextBox CssClass="textBoxPad" runat="server" ID="txtBatchPerPage" style="vertical-align: middle" Width="20px"></asp:TextBox>
                                 <asp:button
                                    id="btnSetBP"
                                    runat="server"
                                    Width="20px"
                                    height="21px"
                                    style="vertical-align: middle"
                                    text="go"
                                    CommandName="PageReset"
                                    CommandArgument = "0"
                                 /> 
                            </td>
                        </tr>
                    </table>
                </PagerTemplate>
                <SelectedRowStyle BackColor="LightGray" ForeColor="GhostWhite" Height="17px" />
                <HeaderStyle BackColor="#cecece" Font-Bold="True" ForeColor="White" Font-Names="Arial" Font-Size="11px" Height="17px" HorizontalAlign="Left" />
                <AlternatingRowStyle BackColor="White" Height="17px" />
                <EditRowStyle HorizontalAlign="Center" />
                <RowStyle Height="17px" />
            </asp:GridView>
        <asp:HiddenField ID="hdnNotes" runat="server"/>
        <asp:HiddenField ID="hdnDisApproveStageID" runat="server" />
        </asp:Panel>
<%--  Object Data Source for New Batches 
        Select Parameters are coded here but set by the code behind page. 
 --%>
    <asp:ObjectDataSource ID="objNewData" runat="server"
        EnablePaging="True" StartRowIndexParameterName="rowIndex" MaximumRowsParameterName="maxRows" 
        TypeName="BatchesData"
        SelectMethod="GetNewBatchData"
        SelectCountMethod="GetNewBatchCount" >
        <SelectParameters>
            <asp:Parameter Type="Int32" Name="stageId" />
            <asp:Parameter Type="String" Name="batchSearch" />
            <asp:Parameter Type="Int32" Name="userID" />
            <asp:Parameter Type="Int32" Name="vendorID" />
            <asp:Parameter Type="String" Name="sortCol" />
            <asp:Parameter Type="String" Name="sortDir" />
            <asp:Parameter Type="Int32" Name="maxRows" />
            <asp:Parameter Type="Int32" Name="rowIndex" />
        </SelectParameters>
    </asp:ObjectDataSource>

    </ContentTemplate>
    </asp:UpdatePanel>

    <div id="shadowbottom1" style="clear:both"></div>

<!-- LightBox Divs  -->
    <div id="overlay" style="display:none"></div>
    <div id="dvPrompt" style="display:none">
        <div class="gS" style="width: 100%;">
	        <div id="msgHeader" class="gridSubheaderText"></div>
	        <div id="msgPrompt" class="gS" style="width: 300px;"></div>
	        <div class="gS" style="margin-top: 10px; white-space: nowrap;">
		        <div id="dvDDL" class="gS" style="margin-bottom: 2px; white-space: nowrap;">
			        <span id="txtPrompt" ></span>&nbsp;
			        <asp:TextBox runat="server" ID="txtResponse" CssClass="gS" style="width: 250px; border: 1px inset #ccc;"></asp:TextBox>
			        <br />
			        <br />
			        <span id="txtPrompt1" >Send Batch To:</span>&nbsp;
			        <select id="ddList"></select>
		        </div>
	        </div>
        </div>
        <div class="gS" style="width: 325px; padding-top: 20px;">
	        <table cellpadding='0' cellspacing='0' border='0' width='100%'>
		        <tr>
			        <td width="75%" align="right"><input type='button' id="btnCommit" value="OK" onclick="SaveReason();" style="width: 55px;" /></td>
			        <td width="3%">&nbsp;</td>
			        <td width="17%" align="left"><input type='button' id="btnCancel" value="Cancel" onclick="" style="width: 55px;" /></td>
			        <td width="5%">&nbsp;</td>
		        </tr>
	        </table>
        </div>
    </div>
   
    </form>
</div>
	<script type="text/javascript">
	    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(mAjaxBeginRequest);
	    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(mAjaxPageLoaded);	
	</script>	
</body>
</html>