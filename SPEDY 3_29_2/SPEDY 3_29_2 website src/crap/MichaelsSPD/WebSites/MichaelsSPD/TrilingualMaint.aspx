<%@ Page Language="VB" AutoEventWireup="false" CodeFile="TrilingualMaint.aspx.vb" Inherits="TrilingualMaint" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="headerlayout" %>
<%@ Register Src="Taskheader.ascx" TagName="taskheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Trilingual Maintenance</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script language="javascript" type="text/javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script language="javascript" type="text/javascript" src="js/calendar_us.js"></script>

	<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />	
	<link href="css/styles.css" rel="stylesheet" type="text/css"/>	
	<link href="css/calendar.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	
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
            overflow: hidden;
            max-width: 100%;
        }.srchParm
        {
            color:Navy
        }
        .srchTextLarge
        {
            width:300px;
        }
        .srchTextMed
        {
            width:100px;
        }
        .srchTextSmall
        {
            width:50px;
        }
        div.autocomplete {
          position:absolute;
          width:500px;
          background-color:white;
          border:1px solid #888;
          margin:0px;
          padding:0px;
          height: 250px;
          overflow: auto;
        }
        div.autocomplete ul {
          list-style-type:none;
          margin:0px;
          padding:0px;
        }
        div.autocomplete ul li.selected { background-color: #ffb;}
        div.autocomplete ul li {
          list-style-type:none;
          display:block;
          margin:0;
          padding:1px;
          cursor:pointer;
        }            
	</style>
    <script language="javascript" type="text/javascript">
        function openTMUpload() {
            var url = 'UploadTrilingualMaint.aspx?r=1';
            var win = window.open(url, '_TMuploadWin', 'scrollbars=1,resizable=1,location=0,menubar=0,titlebar=0,toolbar=0,width=600,HEIGHT=600');
            win.focus();
            return false;
        }

        function ShowHistory(id) {
            var now = new Date();
            var url = 'Batch_History.aspx?hid=' + id + '&modal=1&tstamp=' + now.getTime()
            
            if (window.showModalDialog) {
                var features = "center:yes; dialogHeight:650px; dialogWidth:950px; edge:raised; help:no; resizable:yes; status:yes;"
                window.showModalDialog(url, "junk", features);
            } else {
                var features = 'height=650,width=950,toolbar=no,directories=no,status=yes,menubar=no,scrollbars=no,resizable=yes,modal=yes';
                window.open(url, 'junk', features);
            }
        }

        
    </script>

</head>

<body class="spacer">
<div id="bodydiv" class="margin1" style="width: 100%;">
    <form id="formHome" runat="server">
        
    <asp:HiddenField ID="hidClass" runat="server" />
	<asp:HiddenField ID="hidSubClass" runat="server" />
	<asp:HiddenField ID="hidLockClass" runat="server" />
	<asp:HiddenField ID="hidFilterApplied" runat="server" Value="0" />
	
	<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div id="header">
		<headerlayout:pageheader ID="headerControl" SendToDefault="true" runat="server" />
	</div>

	<div>
	    <uclayout:taskheader ID="tabHeader" runat="server" />
	</div>
    <div class="gridTitle">
        <span class="caption">Trilingual Maintenance Batches</span>
        <span class="floatLeft" >&nbsp;&nbsp;&nbsp;&nbsp;
            <a id="lnkUpload" runat="server" href="#" onclick="openTMUpload();return false;">Upload Trilingual Spreadsheet</a>
        </span>
        <span class="floatRight" >
            <span style="font:arial; font-weight:bold;">Show: </span>
            <asp:DropDownList ID="ddFindshowNew" runat="server" Width="140px"></asp:DropDownList>
            &nbsp;<asp:Button ID="btnDDFFindNew" runat="server" Text=" go " />&nbsp; 
        </span>
    </div>
    
    <div class="clearBoth" ></div>

    
    <div class="clearBoth" ></div>
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
            HorizontalAlign="Left"
            HeaderStyle-Height = "17px"
            PagerStyle-Height = "17px"
            EmptyDataText="No Batches were found matching your search criteria."
            EnableViewState="true">
            <SelectedRowStyle BackColor="LightGray" ForeColor="GhostWhite" Height="17px" />
            <HeaderStyle BackColor="#cecece" Font-Bold="True" ForeColor="White" Font-Names="Arial" Font-Size="11px" Height="17px" HorizontalAlign="Left" />
            <AlternatingRowStyle BackColor="White" Height="17px" />
            <EditRowStyle HorizontalAlign="Center" />
            <RowStyle Height="17px" />
            <Columns>
                <asp:TemplateField  HeaderText="Log ID" SortExpression="0">
                    <ItemTemplate>
                        <a title="Show Batch Details" href="TrilingualMaintDetails.aspx?ID=<%#Eval("ID")%>"><%#Eval("ID")%></a><br />
                        <a title="Show Batch Details" href="TrilingualMaintDetails.aspx?ID=<%#Eval("ID")%>">Details</a> | <a title="Show History for Batch" href="#" onclick="ShowHistory('<%#Eval("ID") %>'); return false;">History</a>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Left" ForeColor="Black" />
                    <HeaderStyle HorizontalAlign="Left" />
                </asp:TemplateField>
                 <asp:BoundField 
                    HtmlEncode="False"
                    DataField="Batch_Type_Desc" 
                    HeaderText="Batch Type" 
                    SortExpression="1">
                    <ItemStyle HorizontalAlign="center"/>
                    <HeaderStyle HorizontalAlign="center"  VerticalAlign="Bottom"  />
                </asp:BoundField>
                <asp:BoundField 
                    HtmlEncode="False"
                    DataField="Item_Count" 
                    HeaderText="Item<br/>Count" 
                    SortExpression="1">
                    <ItemStyle HorizontalAlign="center"/>
                    <HeaderStyle HorizontalAlign="center"  VerticalAlign="Bottom"  />
                </asp:BoundField>
                <asp:TemplateField
                    HeaderText="Valid"
                    SortExpression="2">
                    <ItemTemplate><img src="<%# GetCheckBoxUrl(Eval("Is_Valid")) %>" alt="Valid" />
                    </ItemTemplate>
                    <HeaderStyle HorizontalAlign="Center" />
                    <ItemStyle HorizontalAlign="Center" />
                </asp:TemplateField>
                <asp:TemplateField
                    HeaderText="Stage"
                    SortExpression="3">
                    <ItemTemplate><%#Eval("Stage_Name")%></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField 
                    HtmlEncode="False"
                    DataField="Created_By" 
                    HeaderText="Approver" 
                    SortExpression="4">
                    <ItemStyle HorizontalAlign="Left" />
                    <HeaderStyle HorizontalAlign="Left" />
                </asp:BoundField>
                <asp:TemplateField HeaderText="Action" >
                    <ItemTemplate>
                        <asp:DropDownList ID="DDAction" runat="server" Width="100px">
                        </asp:DropDownList>&nbsp;<asp:Button ID="DDActionGo" runat="server" Text="go" Width = "20px" CommandName="Action" />
                    </ItemTemplate>
                    <HeaderStyle HorizontalAlign="Left" VerticalAlign="Bottom" />
                    <ItemStyle HorizontalAlign="Left" Width="130px" Wrap="false"  />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Created" SortExpression="5">
                    <ItemTemplate>
                        <div style="white-space:nowrap;"><%#String.Format("{0:MMM dd yyyy h:mm tt}", Eval("Date_Created"))%></div><%#Eval("Created_By")%>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Left" />
                    <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Last Reviewed" SortExpression="6">
                    <ItemTemplate>
                        <div style="white-space:nowrap;"><%#String.Format("{0:MMM dd yyyy h:mm tt}", Eval("Date_Modified"))%></div><%#Eval("Modified_By")%>
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Left" />
                    <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom" />
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
                                tooltip="Enter a Batch Log ID, or SKU"          
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
        </asp:GridView>
        <asp:HiddenField ID="hdnNotes" runat="server"/>
        <asp:HiddenField ID="hdnDisApproveStageID" runat="server" />
    </asp:Panel>

    <div id="shadowbottom1" style="clear:both"></div>

    <!-- LightBox Divs  -->
    <div id="overlay" style="display:none"></div>
    <div id="dvPrompt" style="display:none">
        <div class="gS" style="width: 100%;">
	        <div id="msgHeader" class="gridSubheaderText"></div>
	        <div id="msgPrompt" class="gS" style="width: 300px;"></div>
	        <div class="gS" style="margin-top: 10px; white-space: nowrap;">
		        <div id="divDis" class="gS" style="margin-bottom: 2px; white-space: nowrap;">
			        <span id="txtPrompt" ></span>&nbsp;
			        <asp:TextBox runat="server" ID="txtResponse" CssClass="gS" style="width: 250px; border: 1px inset #ccc;"></asp:TextBox>
			        <br />
			        <br />
			        <span id="txtPrompt1" >Send Batch To:</span>&nbsp;
			        <select id="DisStages"></select>
		        </div>
	        </div>
        </div>
        <div class="gS" style="width: 325px; padding-top: 20px;">
	        <table cellpadding=0 cellspacing=0 border=0 width=100%>
		        <tr>
			        <td width="75%" align="right"><input type=button id="btnCommit" value="OK" onClick="SaveReason()"></td>
			        <td width="3%">&nbsp;</td>
			        <td width="17%" align="left"><input type=button id="btnCancel" value="Cancel" onclick=""></td>
			        <td width="5%">&nbsp;</td>
		        </tr>
	        </table>
        </div>
    </div>
    <div id="dvLookupVendor" style="display:none; width:400px;">
        <div class="gS">
	        <div id="LookupHeader" class="gridSubheaderText"></div>
	        <div id="LookupPrompt" class="gS" ></div>
	        <div class="gS" style="margin-top:10px; white-space:nowrap;">
		        <span id="txtLookupPrompt" ></span>&nbsp;
		        <asp:TextBox runat="server" ID="txtVendorLookup" CssClass="gS textBoxPad" style="width:350px; border:1px inset #ccc;"></asp:TextBox>
                <div id="VendorResults" class="autocomplete"></div>
                <input type="hidden" id="hidVendorID" name="hidVendorID" />
	        </div>
        </div>
        <div class="gS" style="width: 400px; padding-top: 20px;">
	        <table cellpadding="0" cellspacing="0" border="0" width="100%">
		        <tr>
			        <td width="95%" align="right">
			            <input type="button" id="btnSaveVendorLookup" value="OK" onclick="SaveVendorLookup()"/>
			            &nbsp;&nbsp;&nbsp;
			            <input type="button" id="btnCancel2" value="Cancel" onclick=""/>
			        </td>
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