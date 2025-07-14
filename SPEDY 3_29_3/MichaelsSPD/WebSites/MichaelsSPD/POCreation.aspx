<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POCreation.aspx.vb" Inherits="_POCreation" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="headerlayout" %>
<%@ Register Src="Taskheader.ascx" TagName="taskheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <title>Purchase Order Creation</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script language="javascript" type="text/javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script language="javascript" type="text/javascript" src="include/PurchaseOrder/POCreation.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
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
    <!--
        function Search()
        {
            $('FilteredSearchContainer').toggle();
        }
        
        function RemoveFilterClicked()
        {
            return confirm('Are you sure you want to remove all filters?');
        }
        
        function WriteCalendar(textCtrl) 
		{
			new tcal 
			(
				{
					'id': 0,
					'formname': 'formHome',
					'controlname': textCtrl,
					'selectinthepast': true
				}
			);
		}
		function clickButton(e, buttonid){ 
              var bt = document.getElementById(buttonid); 
              if (typeof bt == 'object'){ 
                    if(navigator.appName.indexOf("Netscape")>(-1)){ 
                          if (e.keyCode == 13){ 
                                bt.click(); 
                                return false; 
                          } 
                    } 
                    if (navigator.appName.indexOf("Microsoft Internet Explorer")>(-1)){ 
                          if (event.keyCode == 13){ 
                                bt.click(); 
                                return false; 
                          } 
                    } 
              } 
        }

    -->
    </script>

</head>

<body class="spacer">
<div id="bodydiv" class="margin1" style="width: 100%;">
    <form id="formHome" runat="server">

    <asp:HiddenField ID="hidClass" runat="server"  />
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
        <span class="caption">New Purchase Order Batches</span>
        <span class="floatLeft" >&nbsp;&nbsp;&nbsp;&nbsp;
            <a href="POAddNew.aspx" id="lnkAddNew" runat="server" >Create New PO Batch</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;<a href="#" onclick="Search(); return false;">Search For Batch</a>
        </span>
        <span class="floatRight" >
            <span style="font:arial; font-weight:bold;">Show: </span>
            <asp:DropDownList ID="ddFindshowNew" runat="server" Width="140px" AutoPostBack="true"></asp:DropDownList>
            &nbsp;<asp:Button ID="btnDDFFindNew" runat="server" Text=" go " />&nbsp; 
        </span>
    </div>
    
    <div class="clearBoth" ></div>

    <div class="gridTitle" id="FilteredSearchContainer" runat="server">
        <div id="Shadowbottom2" ></div>
        <div id="ItemSearch">
            <table width="100%" align="center" border="0">
                <tr>
                    <td width="50%" align="left">
                        <span class="caption">Search for Batches</span>
                    </td>              
                </tr>
            </table>
            <table width="100%" align="center" border="0" cellpadding="2" cellspacing="0">
            <tr>
                <td colspan="6"><novalibra:NLValidationSummary ID="SearchValidationSummary" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" EnableViewState="true" runat="server" /></td>
            </tr>
            <tr>
                <td align="right" width="5%" style="white-space:nowrap">
                    <span class="srchParm">Log ID:</span>
                </td>
                <td align="left" style="white-space:nowrap">
                    <novalibra:NLTextBox ID="srchBatchNumber" MaxLength="10" Width="60px" CssClass="srchTextMed textboxpad" runat="server"></novalibra:NLTextBox>
                </td>
                <td align="right" width="5%" style="padding-left: 30px; white-space: nowrap;">
                    <span class="srchParm">Written Date:</span>
                </td>
                <td  align="left" style="white-space:nowrap">
                    <novalibra:NLTextBox ID="srchWrittenStartDate" MaxLength="10" Width="60px" CssClass="srchTextLarge textBoxPad" runat="server"></novalibra:NLTextBox><script type="text/javascript">WriteCalendar('srchWrittenStartDate');</script>
                    &nbsp;To&nbsp;
                    <novalibra:NLTextBox ID="srchWrittenEndDate" MaxLength="10" Width="60px" CssClass="srchTextLarge textBoxPad" runat="server"></novalibra:NLTextBox><script type="text/javascript">WriteCalendar('srchWrittenEndDate');</script>
                </td>
                <td width="5%" align="right" valign="top" style="padding-left: 70px; white-space:nowrap">
                    <span class="srchParm">SKU:</span>
                </td>
                <td align="left" width="100%">
                    <novalibra:NLTextBox ID="srchSKU" CssClass="srchTextMed textBoxPad" runat="server" MaxLength="12" Width="125px"></novalibra:NLTextBox>&nbsp;&nbsp;
                </td>
            </tr>
             <tr>
                <td align="right" width="5%" style="white-space:nowrap" >
                    <span class="srchParm">Batch Vendor No:</span>
                </td>
                <td align="left" style="white-space:nowrap">
                    <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <novalibra:NLTextBox ID="srchVendor" MaxLength="10" Width="60px" CssClass="srchTextMed textBoxPad" runat="server"></novalibra:NLTextBox>&nbsp;
                            </td>
                            <td style="padding-top:4px;">
                                <a id="vendorLookUp" runat="server" href="#" onclick="GetVendorID();" title="Lookup Vendor Number"><img src="images/view.gif" alt="Lookup" border="0"/></a>
                            </td>
                            <td style="padding-left:5px;" >
                                <asp:Label runat="server" ID="vendorName"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
                <td align="right" width="5%" style="white-space:nowrap">
                    <span class="srchParm">Location:</span>
                </td>
                <td  align="left" style="white-space:nowrap">                    
                    <novalibra:NLTextBox ID="srchLocation" MaxLength="10" Width="60px" CssClass="srchTextLarge textBoxPad" runat="server"></novalibra:NLTextBox>
                </td>
                <td width="5%" align="right" valign="top" style="padding-top:6px;white-space:nowrap">
                    <span class="srchParm">VPN:</span>
                </td>
                <td  align="left">
                    <novalibra:NLTextBox ID="srchVPN" CssClass="srchTextMed textBoxPad" Width="125px" MaxLength="20" runat="server"></novalibra:NLTextBox>&nbsp;&nbsp;
                </td>
            </tr>
            <tr>
                <td align="right" width="5%" style="white-space:nowrap" >
                    <span class="srchParm">Workflow Department No:</span>
                </td>
                <td align="left" style="white-space:nowrap">
                    <asp:DropDownList ID="srchDept" runat="server"></asp:DropDownList>
                </td>
                <td align="right" width="5%" style="white-space:nowrap" >
                    <span class="srchParm">Allocation Event:</span>
                </td>
                <td align="left" style="white-space:nowrap">
                    <asp:DropDownList ID="srchAllocationEvent" runat="server"></asp:DropDownList>
                </td>
                <td width="5%" align="right" valign="top" style="padding-top:6px;white-space:nowrap">
                    <span class="srchParm">Vendor UPC No:</span>
                </td>
                <td  align="left">
                    <novalibra:NLTextBox ID="srchUPC" CssClass="srchTextMed textBoxPad" MaxLength="14" runat="server" Width="125px"></novalibra:NLTextBox>&nbsp;&nbsp;<span id="UPCMsg" style="color:Red";></span>
                </td>
            </tr>
            <tr>
                <td align="right" width="5%" style="white-space:nowrap">
                    <span class="srchParm">PO Department:</span>
                </td>
                <td  align="left" style="white-space:nowrap">
                    <asp:DropDownList ID="srchPODept" runat="server"></asp:DropDownList>
                </td>
                <td width="5%" align="right" style="white-space:nowrap">
                    <span class="srchParm">Basic/Seasonal:</span>
                </td>
                <td align="left">
                    <asp:DropDownList ID="srchBasicSeasonal" runat="server"></asp:DropDownList>
                </td>
                <td width="5%" align="right" style="white-space:nowrap">
                    <span class="srchParm">PO Type:</span>
                </td>
                <td align="left">
                    <asp:DropDownList ID="srchPOType" runat="server"></asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td align="right" width="5%" style="white-space:nowrap">
                    <span class="srchParm">Batch Stock Category:</span>
                </td>
                <td  align="left" style="white-space:nowrap">
                    <asp:DropDownList ID="srchStockCat" runat="server"></asp:DropDownList>
                </td>
                <td align="right" width="5%" style="white-space:nowrap">
                    <span class="srchParm">Initiator Role:</span>
                </td>
                <td  align="left" style="white-space:nowrap">
                    <asp:DropDownList ID="srchInitiator" runat="server"></asp:DropDownList>
                </td>
            </tr>            
            <tr>
                <td colspan="6" align="center">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="formButton" /> &nbsp;&nbsp;&nbsp;
                    <asp:Button ID="btnReset" runat="server" Text="Reset Form"  CssClass="formButton" OnClientClick="ResetSearch();return false;" />&nbsp;&nbsp;&nbsp;
                    <asp:Button ID="btnFiltered" OnClientClick="return RemoveFilterClicked();" Text="Remove Filter(s)" CssClass="formButton" runat="server" />
                </td>
            </tr>
            </table>
        </div>
	<div id="shadowtop"></div>
        
    </div>    
    <div class="clearBoth" ></div>
    
    <%--
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true" >
    <Triggers>
        <asp:AsyncPostBackTrigger ControlID="ddFindshowNew" />
        <asp:AsyncPostBackTrigger ControlID="btnDDFFindNew" />
    </Triggers>    
    <ContentTemplate>
    --%>
  
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
                EnableViewState="true"
                >
                <SelectedRowStyle BackColor="LightGray" ForeColor="GhostWhite" Height="17px" />
                <HeaderStyle BackColor="#cecece" Font-Bold="True" ForeColor="White" Font-Names="Arial" Font-Size="11px" Height="17px" HorizontalAlign="Left" />
                <AlternatingRowStyle BackColor="White" Height="17px" />
                <EditRowStyle HorizontalAlign="Center" />
                <RowStyle Height="17px" />
                <Columns>
                    <asp:TemplateField  HeaderText="Vendor" SortExpression="1">
                        <ItemTemplate>
                            <a title="Show Batch Details" href="POCreationHeader.aspx?POID=<%#Eval("ID")%>"><%#Eval("Vendor_Name")%><br /><%#Eval("Vendor_Number")%></a>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" ForeColor="Black" />
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Log ID" SortExpression="0" >
                        <ItemTemplate>
                            <a title="Show History for Batch" href="#" onclick="ShowHistory('<%#Eval("ID") %>'); return false;"><%#Eval("Batch_Number")%></a>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="Original_Batch_Number" 
                        HeaderText="Parent Log ID"
                        SortExpression="11">
                        <ItemStyle HorizontalAlign="Left"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:TemplateField HeaderText="W / D" SortExpression="2" >
                        <ItemTemplate><%#Eval("Batch_Type")%></ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="B / S" SortExpression="12" >
                        <ItemTemplate><%#Eval("Basic_Seasonal")%></ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    <asp:BoundField
                        HtmlEncode="false"
                        DataField="ALLOC_EVENT_ID"
                        HeaderText="Event"
                        SortExpression="14">
                        <ItemStyle HorizontalAlign="Left"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>                    
                    <asp:BoundField
                        HtmlEncode="false"
                        DataField="Item_Count"
                        HeaderText="Item Count"
                        SortExpression="13">
                        <ItemStyle HorizontalAlign="Center"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>                    
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="Workflow_Department_Name" 
                        HeaderText="WF Dept."
                        SortExpression="3">
                        <ItemStyle HorizontalAlign="Left"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="PO_Department_Name" 
                        HeaderText="PO Dept."
                        SortExpression="9">
                        <ItemStyle HorizontalAlign="Left"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="PO_Class" 
                        HeaderText="Class"
                        SortExpression="15">
                        <ItemStyle HorizontalAlign="Left"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="PO_Subclass" 
                        HeaderText="Subclass"
                        SortExpression="16">
                        <ItemStyle HorizontalAlign="Left"/>
                        <HeaderStyle HorizontalAlign="Left" />
                    </asp:BoundField>
                    <asp:TemplateField
                        HeaderText="Valid"
                        SortExpression="4">
                        <ItemTemplate><img src="<%# GetCheckBoxUrl(Eval("Is_Valid")) %>" alt="Valid" />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <ItemStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:TemplateField
                        HeaderText=" WF Stage"
                        SortExpression="5">
                        <ItemTemplate><%#Eval("Stage_Name")%></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField 
                        HtmlEncode="False"
                        DataField="Approval_Name" 
                        HeaderText="Approver" 
                        SortExpression="6">
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
                    <asp:TemplateField HeaderText="Created" SortExpression="7">
                        <ItemTemplate>
                            <div style="white-space:nowrap;"><%#String.Format("{0:MMM dd yyyy h:mm tt}", Eval("Date_Created"))%></div><%#Eval("Created_By")%>
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Last Reviewed" SortExpression="8">
                        <ItemTemplate>
                            <div style="white-space:nowrap;"><%#String.Format("{0:MMM dd yyyy h:mm tt}", Eval("Date_Last_Modified"))%></div><%#Eval("Modified_By")%>
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
                    <table cellpadding="5px" width="100%" border="0">
                    <tr>
                        <td align="center" width="80%">
                    <asp:Label
                        id="lblBatchesFound"
                        runat="server"
                        Text="Batch(es) Found"
                        Style="padding-right: 15px;"
                        CssClass="pager"
                        />
                        <asp:LinkButton
                            id="LinkButton1"
                            Text="<<"
                            CommandName="Page"
                            CommandArgument="First"
                            ToolTip="First Page"
                            CssClass="pager"
                            Runat="server" ForeColor="White"/> &nbsp;
                        <asp:LinkButton
                            id="lnkPrevious"
                            Text="<"
                            CommandName="Page"
                            CommandArgument="Prev"
                            ToolTip="Previous Page"
                            CssClass="pager"
                            Runat="server"  />  &nbsp;
                        <asp:label
                            id="PagingInformation"
                            runat="server"                                    
                            CssClass="pager"
                            BorderWidth = "0"
                            Text="Page 1 of 1"
                            Style="padding-left:5px; padding-right:5px; white-space: nowrap;"                   
                            />  &nbsp;
                        <asp:LinkButton
                            id="lnkNext"
                            Text=">"
                            CommandName="Page"
                            CommandArgument="Next"
                            ToolTip="Next Page"
                            CssClass="pager"
                            Runat="server" />  &nbsp;
                        <asp:LinkButton
                            id="LinkButton2"
                            Text=">>"
                            CommandName="Page"
                            CommandArgument="Last"
                            ToolTip="Last Page"
                            CssClass="pager"                                    
                            Runat="server" />  &nbsp;
                        <asp:button
                            id="btngo"
                            runat="server"
                            Width="60px"
                            text="go to page"
                            CommandName="PageGo"
                            CommandArgument = "0"
                            Style="height:21px; vertical-align: middle;"
                            /> 
                         <asp:TextBox
                            id="txtgotopage"
                            runat="server"
                            Width="40px"
                            CssClass="textBoxPad"
                            Style="vertical-align: middle;"
                          />
                         </td>
                         <td align="right" width="20%" style="white-space: nowrap;">
                         <asp:Label runat="server" ID="numBatches" Width="200px" style="text-align:right; white-space:nowrap;" CssClass="pager"  Text="Batches / Page:"></asp:Label>
                         <asp:TextBox CssClass="textBoxPad" runat="server" ID="txtBatchPerPage" Width="20px" Style="vertical-align: middle;"></asp:TextBox>
                         <asp:button
                            id="btnSetBP"
                            runat="server"
                            Width="20px"
                            height="21px"
                            style="vertical-align: middle;"
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

    <%--
    </ContentTemplate>
    </asp:UpdatePanel>
    --%>

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