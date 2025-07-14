<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Tax_Wizard.aspx.vb" Inherits="_Tax_Wizard" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>SPD - Tax Wizard</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<style type="text/css">
		A {text-decoration: underline; color:#000;}
		A:HOVER {text-decoration: underline; color: #00f;}
		BODY {background: #ececec;}
		.headerText
		{
			font-family: Arial, Helvetica;
			font-size: 18px;
			line-height: 22px;
			font-weight: bold;
			color: #000;
		}

		.subheaderText
		{
			font-family: Arial, Helvetica;
			font-size: 14px;
			line-height: 18px;
			font-weight: bold;
			color: #000;
		}

		.bodyText
		{
			font-family: Arial, Helvetica;
			font-size: 11px;
			line-height: 14px;
			color: #000;
		}
	
		INPUT.bodyText {height: 20px; padding: 0; margin: 0;}
		.disabled{background: #ececec;}
		SELECT.disabled{background: #ececec;}		
		INPUT.disabled{border: 0; padding: 2px; color: #999;}
	</style>
<script language="javascript" type="text/javascript">
<!--
function refreshAndClose(id, completed, taxUDA)
{
    window.opener.window.updateItemTaxWizard(id, completed, taxUDA);
    window.close();
}
function refreshReloadAndClose(id, completed, taxUDA)
{
    window.opener.window.updateItemTaxWizard(id, completed, taxUDA);
    window.opener.window.reloadPage('TWSetAll');
    //window.opener.window.location.reload();
    window.close();
}
function reloadAndClose()
{
    window.opener.window.reloadPage('TWSetAll');
    //window.opener.window.location.reload();
    window.close();
}
//-->
</script>
</head>
<body style="margin: 0; padding: 10px;" onload="window.resizeTo(700, 525);">
<form id="form1" runat="server">

<asp:Panel ID="panelForm" runat="server">
    
<div class="bodyText" style="padding: 10px;">
	<div class="headerText" style="color: #999; margin-left: 10px;display: none;">Tax Questionaire</div>

	<div class="bodyText" style="margin-top: 10px; border: 1px solid #d9d9d9; padding: 10px; background: #fff;">
		<div class="subheaderText">Choose Tax UDA</div>
		<div class="bodyText">This item falls into the following Tax UDA:</div>

		<div class="bodyText" style="padding-top: 10px;">
			<asp:DropDownList runat="server" ID="ddlTaxUDA"
			    DataTextField="Tax_UDA_Description" 
                DataValueField="ID" AutoPostBack="true">
            </asp:DropDownList>
		</div>
	</div>

	<div class="bodyText" style="margin-top: 10px; border: 1px solid #d9d9d9; padding: 10px; background: #fff;">
		<div class="subheaderText">Check all that Apply</div>
		<div class="bodyText">Select all options that describe the item.</div>

		<div class="bodyText" style="margin-top: 5px; height: 220px; clip: auto; overflow: auto; border: 1px solid #dadada;">
		
            <asp:TreeView id="tvTaxQuestions" showcheckboxes="All" runat="server" />
		</div>
	</div>

	<div class="bodyText" style="padding-top: 10px;">
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td><input type="button" id="btnCancel" value="Cancel" onclick="parent.window.close();" /></td>
				<td style="width: 100%;"><img src="./../images/spacer.gif" height="1" width="5" alt="" /></td>
				<td><asp:Button ID="btnCommit" runat="server" Text="Okay, Apply these Settings" /></td>
			</tr>
		</table>
	</div>
</div>
    
</asp:Panel>
<asp:Panel ID="panelClose" runat="server">


    <script language="javascript" type="text/javascript">
    <!--
    <%=CloseScript %>
    //-->
    </script>
    
</asp:Panel>
    
</form>
</body>
</html>
