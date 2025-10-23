<%@ Page Language="VB" AutoEventWireup="false" CodeFile="IMPackChange.aspx.vb" Inherits="IMPackChange" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Edit Item Master</title>
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<link href="nlcontrols/nlcontrols.css" rel="stylesheet" type="text/css" />

<style type="text/css">
body {background-color: #dedede;}
th {padding-left: 5px; padding-right: 5px;}
input, select, textarea
{
    background-color: #ffffff;
}
.formGroupLabel
{
	text-align: left; padding-left: 2px; padding-right: 2px;
	border-bottom-width: 1px;
	border-bottom-style: solid;
	border-bottom-color: #d3d3a3;
	height: 21px;
	line-height: 21px;
}
.formGroupEndLabel
{
	border-top-width: 1px;
	border-top-style: solid;
	border-top-color: #d3d3a3;
	height: 21px;
	line-height: 21px;
}
.formGroupEndLabelBottom
{
	border-bottom-width: 1px;
	border-bottom-style: solid;
	border-bottom-color: #d3d3a3;
	height: 21px;
	line-height: 21px;
}
.formLabel
{
/*	width: 134px; */
	text-align: right;
	white-space: nowrap;
	height: 15px;
	line-height: 15px;
}
.formField
{
	height: 15px;
	line-height: 15px;
}

div.autocomplete {
  position:absolute;
  width:250px;
  background-color:white;
  border:1px solid #888;
  margin:0px;
  padding:0px;
  height: 70px;
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
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script type="text/javascript" language="javascript" src="novagrid/prototype.js"></script>
<script type="text/javascript" language="javascript" src="novagrid/scriptaculous.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryData.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryUtils.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryXML.js"></script>
<script language="javascript" type="text/javascript" src="./js/xpath.js"></script>
<script language="javascript" type="text/javascript" src="./Maintdetailform.js"></script>
<script type="text/javascript" language="javascript" src="nlcontrols/nlcontrols.js"></script>

<script type="text/javascript" language="javascript">
<!--

//-->
</script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:HiddenField ID="hidBatchID" runat="server" />
    <asp:HiddenField ID="recordID" runat="server" />    <!-- ID of Item record to edit -->
    <asp:HiddenField ID="hidMichaelsSKU" runat="server" />
	<asp:HiddenField ID="hidVendorNumber" runat="server" />
	
    <div id="content" style="padding: 10px;">
        <div id="itemdetail">
            <table border="0" cellpadding="3" cellspacing="0" style="width: 100%; height: 100%; ">
                <tr>
                    <td width="100%">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
			                <tr>
			                    <td valign="bottom" style="width: 189px;">
			                        <img src="images/spacer.gif" border="0" alt="" height="1" width="189" />
			                    </td>
			                    <td style="width: 15px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="15" /></td>
			                    <td style="width: 50px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="50" /></td>
			                    <td>
                                    <novalibra:NLValidationSummary ID="validationDisplay" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" runat="server" />
                                </td>
			                    <td style="width: 100%;" align="right" valign="bottom">
                                    <asp:Label ID="validFlagDisplay" runat="server" Text=""></asp:Label>
			                    </td>
			                </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
			                <tr>
                                <th align="left" style="height: 22px">
                                    <asp:Label ID="lblHeading" runat="server" Text="Item Master Pack Change "></asp:Label>&nbsp;
                                </th>
                                <th align="right" style="white-space:nowrap;">Supplier:</th>
                                <th align="left" ><asp:DropDownList runat="server" ID="VendorID"></asp:DropDownList></th>
                                <th style="white-space:nowrap; text-align:left;">&nbsp;
                                    <asp:Label runat="server" ID="lblVendor">Joe's Emporium</asp:Label> </th>
                                <th align="left" width="20%">
                                    <asp:Label runat="server" style="color:LightGreen;" ID="lblPrimaryVendor">( Primary )</asp:Label>
                                </th>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <table width="100%">
                <tr>
                    <td align="left" width="100%" class="subHeading" style="height: 16px">
                        <asp:Label ID="lblSubHeading" runat="server" Text="junk. replaced in code" CssClass="bodyText"></asp:Label>
                    </td>
                </tr>
            </table>
            <table width="90%" align="center" cellpadding="3">
                <tr>
                    <td width="30%" runat="server" id="Td1" class="formLabel">SKU:</td>
                    <td runat="server" id="Td2" width="20%">
						<novalibra:NLTextBox ID="SKU" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="10%" runat="server" id="Td3" class="formLabel">VPN:</td>
                    <td runat="server" id="Td4" width="40%" class="formField">
						<novalibra:NLTextBox ID="VendorStyleNum" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                </tr>
                <tr>
                    <td width="30%" runat="server" id="Td5" class="formLabel">Item Description:</td>
                    <td runat="server" id="Td6" width="20%" class="formField">
						<novalibra:NLTextBox ID="ItemDesc" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="10%" runat="server" id="Td7" class="formLabel">Primary UPC:</td>
                    <td runat="server" id="Td8" width="40%" class="formField">
						<novalibra:NLTextBox ID="PrimaryUPC" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                </tr>
<%--                <tr>
                </tr>
                <tr>
                </tr>
                <tr>
                    <td width="30%" runat="server" id="DepartmentFL" class="formLabel">Department:</td>
                    <td runat="server" id="DepartmentParent" width="70%" class="formField">
						<novalibra:NLTextBox ID="DepartmentName" runat="server" RenderReadOnly=True>
						</novalibra:NLTextBox>
						<asp:HiddenField runat="server" ID="DepartmentNum" />
                    </td>
                </tr>
--%><%--                <tr>
                    <td width="30%" runat="server" id="EffectiveDateFL" class="formLabel">Effective Date:</td>
                    <td runat="server" id="EffectiveDateParent" width="70%" class="formField">
						<novalibra:NLTextBox ID="EffectiveDate" runat="server" RenderReadOnly=True>
						</novalibra:NLTextBox>
                    </td>
                </tr>
--%>                <tr>
                    <td width="100%" colspan="2">
                        <img src="images/spacer.gif" border="0" alt="" height="1" width="15" />                    
                    </td>
                </tr>
            </table>
            
            <table width="90%" align="center" cellpadding="3">
                <tr>
                    <td width="20%" runat="server" id="PackCostFL" class="formLabel">&nbsp;Cost:</td>
                    <td runat="server" id="PackCostParent"  class="formField">
						<novalibra:NLTextBox ID="PackCost" runat="server" ChangeControl="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="20%" runat="server" id="AddCostFL" class="formLabel">&nbsp;Additional Cost:</td>
                    <td runat="server" id="AddCostParent"  class="formField">
						<novalibra:NLTextBox ID="AddCost" runat="server" ChangeControl="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="20%" runat="server" id="TotalCostFL" class="formLabel">&nbsp;Total Cost:</td>
                    <td runat="server" id="TotalCostParent"  class="formField">
						<novalibra:NLTextBox ID="TotalCost" runat="server" ReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                </tr>
                <tr>
                    <td width="20%" runat="server" id="RollupFL" class="formLabel">&nbsp;Rollup:</td>
                    <td runat="server" id="RollupParent"  class="formField">
						<novalibra:NLTextBox ID="Rollup" runat="server"  RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="20%" runat="server" id="AddCostNotesFL" class="formLabel">&nbsp;Add'l Cost Notes:</td>
                    <td colspan="3" runat="server" id="AddCostNotesParent" class="formField">
						<novalibra:NLTextBox ID="AddCostNotes" runat="server" Width="300"  ChangeControl="true" >
						</novalibra:NLTextBox>
                    </td>
                </tr>
            </table>

            <table border="0" cellpadding="3" cellspacing="0" style="width: 100%; height: 100%; ">
            <tr>
                <th align="left">Components</th>
            </tr>
            </table>
            <table width="500px;" align="center" style="border:1px solid silver; padding-left:2px;">
                <tr style="background-color:silver; color:Navy">
                    <td width="100px">SKU</td>
                    <td width="100px">VPN</td>
                    <td width="100px">UPC</td>
                    <td width="100px">Cost</td>
                    <td width="100px">Qty</td>
                    <td width="100px"></td>
                </tr>
                <tr style="background-color:LightGoldenrodYellow;">
                    <td>
                        <asp:Label runat="server" ID="label1" >12345672</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label5" >VPX-3411</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label12" >012345233124</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label13" >$ 2.38</asp:Label>
                    </td>
                    <td>
						<novalibra:NLTextBox ID="NLTextBox1" runat="server" ChangeControl="true">
						</novalibra:NLTextBox>
                    </td>
                    <td>
                        <asp:Button runat="server" ID="btnFCDel1" Text="Delete" />
                        <asp:HiddenField runat="server" ID="hdnStatus1" Value="A" />
                    </td>
                </tr>
                <tr style="background-color:white;">
                    <td>
                        <asp:Label runat="server" ID="label2" >12345671</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label6" >VPX-3412</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label9" >012345233118</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label14" >$ 2.38</asp:Label>
                    </td>
                    <td>
						<novalibra:NLTextBox ID="NLTextBox10" runat="server" ChangeControl="true">
						</novalibra:NLTextBox>
                    </td>
                    <td>
                        <asp:Button runat="server" ID="Button2" Text="Delete" />
                        <asp:HiddenField runat="server" ID="HiddenField1" Value="A" />
                    </td>
                </tr>
                <tr style="background-color:LightGoldenrodYellow;">
                    <td>
                        <asp:Label runat="server" ID="label3" >12345674</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label7" >VPX-3413</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label10" >012345233135</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label15" >$ 2.38</asp:Label>
                    </td>
                    <td>
						<novalibra:NLTextBox ID="NLTextBox15" runat="server" ChangeControl="true">
						</novalibra:NLTextBox>
                    </td>
                    <td>
                        <asp:Button runat="server" ID="Button3" Text="Delete" />
                        <asp:HiddenField runat="server" ID="HiddenField2" Value="A" />
                    </td>
                </tr>
                <tr style="background-color:white;">
                    <td>
                        <asp:Label runat="server" ID="label4" >12345677</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label8" >VPX-3414</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label11" >012345233182</asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="label16" >$ 2.38</asp:Label>
                    </td>
                    <td>
						<novalibra:NLTextBox ID="NLTextBox20" runat="server" ChangeControl="true">
						</novalibra:NLTextBox>
                    </td>
                    <td>
                        <asp:Button runat="server" ID="Button4" Text="Delete" />
                        <asp:HiddenField runat="server" ID="HiddenField3" Value="A" />
                    </td>
                </tr>
                <tr style="background-color:silver;">
                    <td colspan="6" align="left">
                        <input type="button" id="Button1" onclick="javascript:Alert('Add a SKU');" value="Add" class="formButton" />&nbsp;
                    </td>
                </tr>
            </table>
            
            <table width="100%">
                <tr>
                    <th class="detailFooter">
                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
                            <tr>
                                <td width="50%" style="width: 50%;" align="left" valign="top">
                                    <input type="button" id="btnCancel" onclick="javascript:window.close()" value="Cancel" class="formButton" />&nbsp;
                                </td>
                                <td width="50%" style="width: 50%;" align="right" valign="top">
                                    &nbsp;<asp:Button ID="btnUpdate" runat="server" CommandName="Update" Text="Save" CssClass="formButton" /> 
                                    &nbsp;&nbsp;<asp:Button ID="btnUpdateClose" runat="server" CommandName="UpdateClose" Text="Save &amp; Close" CssClass="formButton" />
                                </td>
                            </tr>
                        </table>
                    </th>
                </tr>
                <tr>
                    <td><img src="images/spacer.gif" width="1" height="2" alt="" /></td>
                </tr>
            </table>
        </div>
    </div>
<script language="javascript" type="text/javascript">
<!--
    <% If RefreshGrid Then %>
    //window.parent.opener.location = window.parent.opener.location;
    window.parent.opener.reloadPage();
    <% End If %>
    <%if CloseForm then %>
    setTimeout("closeDetailForm();", 250);
    <%Else%>
    initPageOnLoad();
    <%End IF %>
//-->
</script>
    </form>
</body>
</html>
