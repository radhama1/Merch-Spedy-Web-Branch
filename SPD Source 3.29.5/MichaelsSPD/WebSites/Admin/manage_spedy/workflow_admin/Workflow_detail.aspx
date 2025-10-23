<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Workflow_detail.aspx.vb" Inherits="workflowscreens._Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >

<head runat="server">
    <title>Add/Edit Workflow Stage</title>
    <link rel="stylesheet" href="/css/styles.css" type="text/css"/>
    <style type="text/css">
th { text-align: left; padding: 5px; }
input, select, textarea
{
    background-color: #ffffff;
}
.formLabel
{
	text-align: right;
	white-space: nowrap;
	height: 21px;
	line-height: 21px;
}
.formField
{
	height: 21px;
	line-height: 21px;
}
</style>
</head>
<body style="background-color:#cccccc;overflow:scroll" >
    <form id="frmWorkflow" runat="server">
    <div>
     <table cellpadding="0" cellspacing="0" border="0" style="width: 100%">
		<tr style="background-color:Black; color:White">
		    <th valign="top" colspan="2">Workflow Stage ADDITION &amp; CHANGES &nbsp<asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label>
			</th>
			</tr>
	 </table>
	 <br />
	 <asp:Panel ID="Panel3" runat="server" Visible = "true" BorderStyle ="Solid"  BorderWidth = "1px" Width = "960px">
	  <table border="0" cellpadding="2" cellspacing="0" width="960">
             <tr>
                <td align="left" style="width: 195px">
                    <asp:Label ID="lblName" runat="server" Text="Work Stage Name:" Width = "120px"></asp:Label> </td>
                <td class="formField" style="width: 160px">
                    <asp:TextBox id="txtName" runat="server" cssclass="formTextBox" maxlength="100" width="140px"></asp:TextBox >
                </td>
                <td align="left" style="width: 60px">
                    Enabled<span id="Span3" runat="server" class="requiredFieldsIcon"></span>:</td>
                <td align="left">
                    <asp:CheckBox runat="server" ID="chkEnabled" Checked="true">
                    </asp:CheckBox>
                </td>
                <td align="left" style="width: 80px">
                    Sequence #:</td>
                <td align="left">
                    <asp:TextBox id="txtSequence" width ="30" runat="server" cssclass="formTextBox" maxlength="4"></asp:TextBox>
                </td>
                <td align="left" style="width: 200px">
                    Default Approval Next Stage :</td>
                <td align="right">
                    <asp:DropDownList id="ddNextStage" runat="server" cssclass="formTextBox" Enabled = "true" Width="140px"></asp:DropDownList >
                </td>
                
            </tr>
            </table> 
            <table border="0" cellpadding="2" cellspacing="0" width="960">
            <tr>
             <td  align="left" style="width: 195px">
                    Select User Approval Groups:</td>
             <td class="formField">
                <asp:DropDownList id="ddGrouplist" runat="server" Enabled = "true" Width="160px"></asp:DropDownList >
             </td>
             <td align = "left">
                 <div style="width: 100px; height: 30px; position:relative; ">
                  <asp:Button ID="btnAddGrp" runat="server" Text="Add Group >>" Width="120px"/>
                 </div>
                 <div style="width: 100px; height: 30px; position:relative; ">
                 <asp:Button ID="btnRemoveGrp" runat="server" Text="<< Remove Group" Width="120px"/>
                 </div>
             </td> 
             <td>
                 <asp:ListBox ID="lstGroupList" runat="server" Width = "120px" Height="100px" ></asp:ListBox>
             </td>
             <td class="formLabel">
                    Default Disapproval Next Stage:</td>
                <td align="right">
                    <asp:DropDownList id="DropDownList1" runat="server" cssclass="formTextBox" Enabled = "true" Width="140px"></asp:DropDownList >
                </td>      
            </tr>
       </table> 
       </asp:Panel> <br \>
       <asp:Panel ID="Panel1" runat="server" Visible = "true" BorderStyle ="Solid"  BorderWidth = "1px" Width = "960px">
            
            <strong>Set Workflow Stage Approval Exceptions:</strong>
            <table border="0" cellpadding="3" cellspacing="0" width="1024" title="Add Stage Exceptions:">
                <tr>
                    <td class="formLabel" style="width: 200px;">
                    Exception 1 Approval Stage:</td>
                    <td class="formField"  style="width: 200px;">
                    <asp:DropDownList id="DDExceptList1" runat="server" cssclass="formTextBox" Enabled = "true" Width="90px"></asp:DropDownList >
                </td>
                <td class="formLabel"  style="width: 200px;">
                    Select Exception 1 Condition:
                </td>
                <td class="formField" style="width: 120px;">
                    <asp:DropDownList id="DDCondition" runat="server" cssclass="formTextBox" Enabled = "true" Width="120px"></asp:DropDownList >    
                </td>
                <td><asp:DropDownList id="DDConjunction" runat="server" cssclass="formTextBox" Enabled = "true" Width="50px">
                    <asp:ListItem Selected="True">And</asp:ListItem>
                    <asp:ListItem>Or</asp:ListItem>
                    <asp:ListItem></asp:ListItem>
                    </asp:DropDownList >    
                </td> 
                </tr>
                <tr>
                <td><asp:Button ID="Button1" runat="server" Text="Add Approval Exception" Width="165px"/></td>
                <td style="width: 200px;" colspan = "1"> </td>
                <td class="formLabel"  style="width: 200px;">
                    Select Exception 2 Condition:
                </td>
                <td class="formField" style="width: 120px;">
                    <asp:DropDownList id="DropDownList2" runat="server" cssclass="formTextBox" Enabled = "true" Width="120px"></asp:DropDownList >    
                </td>
                <td><asp:DropDownList id="DDAndOr2" runat="server" cssclass="formTextBox" Enabled = "false" Width="50px">
                    <asp:ListItem Selected="True">And</asp:ListItem>
                    <asp:ListItem>Or</asp:ListItem>
                    <asp:ListItem></asp:ListItem>
                    </asp:DropDownList >    
                </td>
                <td>
                <asp:Button ID="BtnAddCondition" runat="server" Text="Add Condition" Width="120px"/>
                </td> 
                </tr>   
               
            </table> 
        </asp:Panel> <br \>
        <asp:Panel ID="Panel2" runat="server" Visible = "true" BorderStyle ="Solid"  BorderWidth = "1px" Width = "960px">
            
            <strong>Set Workflow Stage Dispproval Exceptions:</strong>
            <table border="0" cellpadding="3" cellspacing="0" width="1024" title="Add Stage Exceptions:">
                <tr>
                    <td class="formLabel" style="width: 200px;">
                    Exception 1 Disapproval Stage:</td>
                    <td class="formField"  style="width: 200px;">
                    <asp:DropDownList id="DropDownList3" runat="server" cssclass="formTextBox" Enabled = "true" Width="90px"></asp:DropDownList >
                </td>
                <td class="formLabel"  style="width: 200px;">
                    Select Exception 1 Condition:
                </td>
                <td class="formField" style="width: 120px;">
                    <asp:DropDownList id="DropDownList4" runat="server" cssclass="formTextBox" Enabled = "true" Width="120px"></asp:DropDownList >    
                </td>
                <td><asp:DropDownList id="DropDownList5" runat="server" cssclass="formTextBox" Enabled = "true" Width="50px">
                    <asp:ListItem Selected="True">And</asp:ListItem>
                    <asp:ListItem>Or</asp:ListItem>
                    <asp:ListItem></asp:ListItem>
                    </asp:DropDownList >    
                </td> 
                </tr>
                <tr>
                <td><asp:Button ID="Button2" runat="server" Text="Add Disapproval Exception" Width="165px"/></td>
                <td style="width: 200px;" colspan = "1"> </td>
                <td class="formLabel"  style="width: 200px;">
                    Select Exception 2 Condition:
                </td>
                <td class="formField" style="width: 120px;">
                    <asp:DropDownList id="DropDownList6" runat="server" cssclass="formTextBox" Enabled = "true" Width="120px"></asp:DropDownList >    
                </td>
                <td><asp:DropDownList id="DropDownList7" runat="server" cssclass="formTextBox" Enabled = "false" Width="50px">
                    <asp:ListItem Selected="True">And</asp:ListItem>
                    <asp:ListItem>Or</asp:ListItem>
                    <asp:ListItem></asp:ListItem>
                    </asp:DropDownList >    
                </td>
                <td>
                <asp:Button ID="btnAddCond2" runat="server" Text="Add Condition" Width="120px"/>
                </td> 
                </tr>   
               
            </table> 
        </asp:Panel>
         <br />
         <div id="savediv"  style="position:absolute; left: 840px;">
            <asp:Button ID="Button3" runat="server" Text="Save and Close" Width="120px"/> 
         </div>            
    </div>
    </form>
</body>
</html>
