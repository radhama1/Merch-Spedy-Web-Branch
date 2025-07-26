<%@ control language="VB" autoeventwireup="false" inherits="WebControls_ExceptionPanel, App_Web_14-o4yf8" %>

<script language="javascript" type="text/javascript" src="../App_Include/prototype.js"></script>
<script language="javascript" type="text/javascript" src="../App_Include/Workflow_Detail.js"></script>
<asp:Repeater ID="ExceptionRepeater" runat="server" OnItemDataBound="ExceptionRepeater_ItemDataBound" OnItemCommand="ExceptionRepeater_ItemCommand">
        <ItemTemplate>
            <asp:HiddenField ID="hdnExceptionIndex" runat="server"  EnableViewState="true" Value="0"/>
            <asp:Panel ID="PnlException" runat="server" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px" Width="980px">        
                <table id ="tblApprovalExc" runat="server" border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:" >
                    <tr>
                        <td align="left" style="width: 380px;">
                            <table>
                                <tr>
                                    <td><asp:label ID="lblApprove" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                                    <td><asp:DropDownList id="DDApprStageExc" runat="server" cssclass="bodyText" Enabled="true" Width="160px" AutoPostBack="True" CausesValidation="False" DataTextField="Stage_Name" DataValueField="Id" DataSource="<%# WorkflowStages %>" OnSelectedIndexChanged="DDApprStageExc_IndexChanged" ></asp:DropDownList ></td>
                                </tr>
                                <tr>
                                    <td><asp:Label ID="LblOrder" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                                    <td><asp:DropDownList ID="ExceptionOrder" runat="server" DataSource="<%# OrderList %>" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="ExceptionOrder_IndexChanged"></asp:DropDownList></td>
                                </tr>
                                <tr>
                                    <td><asp:Button ID="btnRemoveExc" CssClass="button" runat="server" Text="Remove Exception" Width= "120px" CommandName="RemoveException" ></asp:Button></td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <table>
                                <asp:Repeater ID="ConditionRepeater" runat="server" OnItemDataBound="ConditionRepeater_ItemDataBound" OnItemCommand="ConditionRepeater_ItemCommand" >
                                    <ItemTemplate>
                                        <tr>
                                            <td  align="right" style="width: 190px;" >
                                                <asp:HiddenField ID="hdnConditionIndex" runat="server" />
                                                <asp:Label ID="lblSelExc" runat="server" cssclass="formLabel"></asp:Label>
                                            </td>
                                            <td align="left" style="width: 180px;" >
                                                <asp:DropDownList id="ddCondExc" runat="server" cssclass="bodyText" Enabled="true" Width="180px" AutoPostBack="True" CausesValidation="false" DataTextField="Condition_Name" DataValueField="Condition_id" DataSource="<%# ExceptionConditions %>" OnSelectedIndexChanged="ddCondExc_IndexChanged"></asp:DropDownList >    
                                            </td>
                                            <td style="width:1px;">
                                                <asp:TextBox ID="txtThreshold" runat="server" CssClass="bodyText" Width="50px" Visible="false" />
                                                <asp:TextBox ID="txtShipWindow" runat="server" CssClass="bodyText" Width="50px" Visible="false" />
                                                <asp:HyperLink ID="hpSelDept" runat="server" Visible="false">Dept</asp:HyperLink>
                                                <asp:HiddenField ID="hdnDeptList" runat="server" Value="" />
                                                <asp:HyperLink ID="hpSelField" runat="server" Visible="false" >Fields</asp:HyperLink>
                                                <asp:HiddenField ID="hdnFieldList" runat="server" Value="" />
                                                <asp:HyperLink ID="hpInitiator" runat="server" Visible="false">Init.</asp:HyperLink>
                                                <asp:HiddenField ID="hdnInitiatorList" runat="server" Value="" />
                                            </td>
                                            <td style="width:25px;" >
                                                <asp:DropDownList id="ddAndOrExc" runat="server" cssclass="bodyText" Enabled="True" Width="55px" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="ddAndOrExc_IndexChanged">
                                                <asp:ListItem Selected="True">AND</asp:ListItem>
                                                <asp:ListItem>OR</asp:ListItem> 
                                                </asp:DropDownList ></td>
                                            <td style="width: 15px;" >
                                               &nbsp;
                                            </td>
                                            <td>
                                                <asp:Button ID="btnConditionCommand" runat="server" CausesValidation="false" CssClass="button" Width="110px"/>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </table>
                        </td>
                    </tr>     
                </table> 
            </asp:Panel>
    </ItemTemplate>
</asp:Repeater>