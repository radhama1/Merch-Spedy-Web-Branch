<%@ Page Language="VB" AutoEventWireup="false" CodeFile="TrilingualMaintDetails.aspx.vb" Inherits="TrilingualMaintDetails" ValidateRequest="false" %>

<%@ Register Assembly="Infragistics35.Web.v12.2, Version=12.2.20122.2075, Culture=neutral, PublicKeyToken=7dd5c3163f2cd0cb" Namespace="Infragistics.Web.UI" TagPrefix="ig" %>
<%@ Register Assembly="Infragistics35.Web.v12.2, Version=12.2.20122.2075, Culture=neutral, PublicKeyToken=7dd5c3163f2cd0cb" Namespace="Infragistics.Web.UI.GridControls" TagPrefix="ig" %>
<%@ Import Namespace="NovaLibra.Common.Utilities" %>
<%@ Register Src="NovaGrid.ascx" TagName="NovaGrid" TagPrefix="ucgrid" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
   
    <title>Trilingual Item Data Management</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
    <link href="nlcontrols/nlcontrols.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript" src="js/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="js/scriptaculous.js"></script>
    <style type="text/css">
        .itemgrid
        {
            margin-left: 10px;
        }
        .itemheader
        {
            background-color: rgb(226, 226, 178);
            color: #000000;
            font-size: 11px;
            text-decoration: underline;
            font-weight: bold;
            border-color: white;
            vertical-align:bottom;
        }

        .altitemrow .itemcell
        {
            border: 1px solid #FFFFFF;
        }
        .itemcell
        {
            border: 1px solid rgb(226, 226, 178);
        }
        
        .changecell
        {
            background-color: rgb(211, 211, 163);
            width: 100%;
            overflow: visible;
        }
        
        .changecell_hide
        {
            
        }

        .changeundo
        {
            text-align:right;
            background-image: url(nlcontrols/btn_undo.gif);
            cursor: pointer;
            height: 20px;
            width: 18px;
            display:block;
        }
        .changeorig
        {
            color: #51512a;
        }

        /**********************/
        /*  Set All Control   */
        /**********************/
        
        #gridSetAll
        {
	        font-family: Arial, Helvetica;
	        background: #dedede;
            position: absolute;
            left: 40%;
            top: 30%;
        }
        #gridSetAllContent
        {
        }
        #gridSetAllHeader
        {
	        background: #000000;
	        color: #ffffff;
	        padding-left: 3px;
	        padding-right: 0px;
	        padding-top: 0px;
	        padding-bottom: 0px;
	        font-weight: bold;
        }
        #gridSetAllColumn
        {
	        font-family: Arial, Helvetica;
	        font-weight: bold;
        }
        .gridSetAllBG
        {
	        background: #d3d3a3;
        }
        .gridSetAllRow
        {
	        font-family: Arial, Helvetica;
	        background: #dedede;
        }
        .gridSetAllFooter
        {
	        font-family: Arial, Helvetica;
	        background: #dedede;
        }
        .gridSetAllFooter .formButton, .gridSetAllFooter input .formButton
        {
	        font-family: Arial, Helvetica;
	        height: 17px;
	        padding-left: 1px;
	        padding-right: 1px;
	        padding-bottom: 2px;
	        font-size: 10px;
	        line-height: 10px;
	        vertical-align: top;
	        background-color: #ffffff;
	        font-weight: bold;
        }

        .gCVE
        {
	        /*background-color: #ff9999;*/
	        background-color: #FF9F9F;
        }

        .gCVW
        {
            /*background-color: #ff9999;*/
            background-color: #FFFF99;
        }

        #gridlightbox
        {
            position: absolute;
            width: 100%;
            height: 100%;
            left: 0px;
            top: 0px;
            background-color: rgba(225,225,225,0.5);
        }

    </style>
    <script type="text/javascript" language="javascript">

        /********************  Javascript for saving data    *******************************/
        
        function FindColumnName(colID) {
            var columnName = "";
            switch (colID.toString()) {
                case "7":
                    columnName = "ItemDesc"
                    break;
                case "14":
                    columnName = "PLIEnglish"
                    break;
                case "15":
                    columnName = "PLIFrench"
                    break;
                case "16":
                    columnName = "PLISpanish"
                    break;
                case "17":
                    columnName = "ExemptEndDateFrench"
                    break;
                case "18":
                    columnName = "TIFrench"
                    break;
                case "19":
                    columnName = "EnglishShortDescription"
                    break;
                case "20":
                    columnName = "EnglishLongDescription"
                    break;
                case "21":
                    columnName = "FrenchShortDescription"
                    break;
                case "22":
                    columnName = "FrenchLongDescription"
                    break;
                case "23":
                    columnName = "SpanishShortDescription"
                    break;
                case "24":
                    columnName = "SpanishLongDescription"
                    break;
            }

            return columnName;
        }
                     
        function editGridCell(rowID, cellID) {
            //Hide original and change labels
            $('gvItemList_it' + cellID + '_' + rowID + '_chg_value').hide();    
            $('gvItemList_it' + cellID + '_' + rowID + '_orig_value').hide();   
            $('gvItemList_it' + cellID + '_' + rowID + '_edit_undo').hide();
            //SHOW change control

            $('gvItemList_it' + cellID + '_' + rowID + '_change_div').addClassName("changecell");
            $('gvItemList_it' + cellID + '_' + rowID + '_change_div').removeClassName("changecell_hide");

            $('gvItemList_it' + cellID + '_' + rowID + '_edit_value').show();
            $('gvItemList_it' + cellID + '_' + rowID + '_edit_value').focus();
        }

        function saveCell(itemID, rowID, cellID) {
            var origValue = $('gvItemList_it' + cellID + '_' + rowID + '_orig_value').innerText;
            var chgValue = $('gvItemList_it' + cellID + '_' + rowID + '_edit_value').value;
            
            //Find ColumnName
            var columnName = FindColumnName(cellID);

            //IF the field being updated is ItemDesc, then make sure the change value is in upper case
            if (columnName == "ItemDesc") {
                chgValue = chgValue.toUpperCase();
            }
            //IF this is a pack item, override value (Per Michaels:  These values must be used for pack parent items)
            if ((columnName == "EnglishShortDescription") || (columnName == "EnglishLongDescription")) {
                var itemType = $('gvItemList_it1_' + rowID + '_hdn_PackItemIndicator').value;
                if (itemType.indexOf('DP') == 0) {
                    chgValue = 'Display Pack';
                }
                else if (itemType.indexOf('SB') == 0) {
                    chgValue = 'Sellable Bundle';
                }
                else if (itemType.indexOf('D') == 0) {
                    chgValue = 'Displayer';
                }
            }

            //Set change label to new change value
            $('gvItemList_it' + cellID + '_' + rowID + '_chg_value').innerText = chgValue;
 
            //IF original value equals change value, Hide change control
            if (chgValue == origValue) {
                //HIDE change controls
                $('gvItemList_it' + cellID + '_' + rowID + '_change_div').addClassName("changecell_hide");
                $('gvItemList_it' + cellID + '_' + rowID + '_change_div').removeClassName("changecell");
                $('gvItemList_it' + cellID + '_' + rowID + '_edit_value').hide();
                $('gvItemList_it' + cellID + '_' + rowID + '_chg_value').hide();
                $('gvItemList_it' + cellID + '_' + rowID + '_edit_undo').hide();
                $('gvItemList_it' + cellID + '_' + rowID + '_orig_value').removeClassName("changeorig");
                $('gvItemList_it' + cellID + '_' + rowID + '_orig_value').show();
            }
            else {
                //SHOW change controls
                $('gvItemList_it' + cellID + '_' + rowID + '_orig_value').addClassName("changeorig");
                $('gvItemList_it' + cellID + '_' + rowID + '_orig_value').show();
                $('gvItemList_it' + cellID + '_' + rowID + '_chg_value').show();
                $('gvItemList_it' + cellID + '_' + rowID + '_edit_undo').show();
                $('gvItemList_it' + cellID + '_' + rowID + '_edit_value').hide();  //HIDE edit controls.
            }
            
            var uID = $('hdnUID').value;
            PageMethods.UpdateField(itemID, uID, rowID, columnName, chgValue, onSuccess, onFailure);
        }

        function revertCell(itemID,rowID, cellID) {
            //SET current value to original value
            var origValue = $('gvItemList_it' + cellID + '_' + rowID + '_orig_value').innerText;
            $('gvItemList_it' + cellID + '_' + rowID + '_edit_value').value = origValue;

            //SAVE Cell
            saveCell(itemID, rowID, cellID);
        }

        function onSuccess(response) {
            //Determine if response was successful
            if (response.UpdateSuccess == true) {
                //Set Batch Validity graphic
                if (response.BatchIsValid == true) {
                    $('validBatch').src = 'images/valid_yes_small.gif';
                    
                }
                else {
                    $('validBatch').src = 'images/valid_no_small.gif';
                }

                //Hide Validation Summary if the Batch is Valid (no Errors), and there are no warnings
                if (response.BatchIsValid == true && response.HasWarning == false) {
                    HideValidationSummary();
                }


                //HIDE all old validation errors for the SKU
                HideItemValidation(response.ItemID);

                //Set Item Validity graphic
                if (response.ItemIsValid == true) {
                    $('gvItemList_it1_' + response.RowID + '_is_valid').src = 'images/Valid_yes.gif';
                }
                else {
                    $('gvItemList_it1_' + response.RowID + '_is_valid').src = 'images/Valid_no.gif';
                    //SKU is invalid, so recreate the Validation errors
                    ShowItemValidation(response.itemID, response.Message);
                }
            }
            else{
                alert('UPDATE FAILED! There was a problem updating the Item: ' & response.Message);
            }

        }

        function onFailure(response) {
            alert('UPDATE FAILED! There was a problem updating the Item: ' & response);
        }

        /***********************************************************************************/


        /*************  Javascript for Displaying the Validation Summary  ******************/
        function CreateValidationSummary() {
            var validationSummary = $('validationSummary')
            if (validationSummary != null) {
                validationSummary.innerHTML = '<div style="color: rgb(153, 51, 0);" id="validationDisplay" class="validationDisplay">Validation Errors<ul></ul></div>'
            }
        }

        function FindValidationMessage(validationNode, message) {
            var children = validationNode.children;
            for (var i = 0; i < children.length; i++) {
                //HACK for IE 8 which does not always use quotation marks in generated HTML
                message = message.replace(/"/g, "");
                var validationMessage = children[i].innerHTML.replace(/"/g, "");
                message = message.replace(/SPAN/g, 'span');
                validationMessage = validationMessage.replace(/SPAN/g, 'span');

                if (validationMessage == message) {
                    return children[i];
                }
                else {
                    var result = FindValidationMessage(children[i], message)
                    if (result != null) {
                        return result;
                    }
                }
            }
        }

        function HideItemValidation(itemID) {
            var validationSummary = $('validationDisplay')
            if (validationSummary != null) {

                var childSet1 = validationSummary.children
                if (childSet1 != null) {
                    var childSet2 = childSet1[0].children
                    for (var i = 0; i < childSet2.length; i++) {
                        if (childSet2[i].innerHTML.indexOf(itemID) > 1 && (childSet2[i].innerHTML.indexOf('class="sevError"') > 1 || childSet2[i].innerHTML.indexOf('class=sevError') > 1)) {
                            childSet2[i].outerHTML = '';
                            i--; //Must decrement i since the above changes the length of childSet
                        }
                    }
                }
            }
        }

        function HideValidationSummary() {
            var validationSummary = $('validationDisplay');
            if (validationSummary != null) {
                validationSummary.hide();
            }
        }

        function ShowItemValidation(itemID, validationMessages) {
            //Check to see if the Valdiation Summary exists, and make sure it is shown.
            var validationSummary = $('validationDisplay')
            if (validationSummary == null) {
                //Create Validation Summary Display
                CreateValidationSummary();
                validationSummary = $('validationDisplay');
            }
            validationSummary.show();
            
            //Loop through Validation messages, and add ones from the AJAX response
            var messages = validationMessages.split(["||"])
            for(var i =0; i<messages.length; i++)
            {
                if (messages[i] != '') {
                    //If the error is not already in the validation summary, then add it.
                    var errorNode = FindValidationMessage(validationSummary, messages[i])
                    if (errorNode == null) {
                        validationSummary.children[0].innerHTML = validationSummary.children[0].innerHTML + '<li>' + messages[i] + '</li>';
                    }
                }
            }

        }
        /***********************************************************************************/

        /*********************  Set All Javascript  ****************************************/
        var setAllID;

        function FindEditControl(ctrl) {
            var children = ctrl.children;
            for (var i = 0; i < children.length; i++) {
                if (children[i].id.indexOf('edit_value') > 0) {
                    return children[i];
                }
                else {
                    var result = FindEditControl(children[i])
                    if (result != null) {
                        return result;
                    }
                }
            }
        }

        function onAllFailure(response) {
            alert('UPDATE FAILED! There was a problem updating the Batch Items: ' & response);
            //Reload Page
            window.location = window.location;
        }

        function onAllSuccess(response) {
            if (response.UpdateSuccess == true) {
                //Reload Page
                window.location = window.location;
            }
            else {
                alert('UPDATE FAILED! There was a problem updating the Item: ' & response.Message);
            }
        }

        function setAllClose() {
            var o = $('gridlightbox')
            if (o) {
                // clear the header text
                $('gridSetAllColumn').innerHTML = "&nbsp;";
                // clear the control
                $('gridSetAllData').innerHTML = "&nbsp;";
                // hide the div
                //o.style.display = "none";
                o.hide();
            }
            // clear the id
            setAllID = 0;
        }

        function setAllSave() {
            //Get Values for updates
            var chgValue = $('gvItemList_setAll_edit_value').value;
            var columnID = $('gridSetAllCID').value;
            var batchID = $('hdnBatchID').value;
            var uID = $('hdnUID').value;

            //Find ColumnName
            var columnName = FindColumnName(columnID);

            //Hide save all lightbox
            $('gridlightbox').hide();

            //Call AJAX method to update items
            PageMethods.UpdateAll(uID, batchID, columnName, chgValue, onAllSuccess, onAllFailure);
        }

        function showSetAll(cell, colID) {
            //Close and reopen SetAll control to refresh it.
            if (setAllID > 0) {
                setAllClose();
            }
            setallID = colID;

            //Display Set All Lightbox
            var o = $('gridlightbox');
            o.show();

            //Initialize Set All control using first edit control of the grid's related column
            var columnName = $find("gvItemList").get_columns().get_column(colID).get_headerText();
            $('gridSetAllColumn').innerText = columnName;
            $('gridSetAllCID').value = colID;

            var newCtrl = null;
            var editCtrl = FindEditControl($find("gvItemList").get_rows().get_row(0).get_cell(colID).get_element());
            if (editCtrl != null) {
                newCtrl = Element.clone(editCtrl, true);
                newCtrl.id = 'gvItemList_setAll_edit_value';
                newCtrl.removeAttribute('onblur');
                newCtrl.show();
                newCtrl.value = '';
                $('gridSetAllData').innerHTML = newCtrl.outerHTML;
            }

        }

        /***********************************************************************************/


        /*********************  Delete All Javascript  *************************************/

        function deleteItem(itemID, sku) {
            if (confirm('Are you sure you want to delete SKU ' + sku + ' from this batch?')) {
                var uID = $('hdnUID').value;
                PageMethods.DeleteItem(itemID, uID, onDeleteSuccess, onDeleteFailure);
            }

            return false;
        }

        function onDeleteSuccess(response) {
            if (response.UpdateSuccess == true) {
                //Reload Page
                window.location = window.location;
            }
            else {
                alert('DELETE FAILED! There was a problem deleting the Item: ' & response.Message);
            }
        }

        function onDeleteFailure(response) {
            alert('DELETE FAILED! There was a problem deleting the Item: ' & response);
            //Reload Page
            window.location = window.location;
        }

        /***********************************************************************************/
      
    </script>
</head>
<body onload="">
    <script type="text/javascript" language="javascript" src="./include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnBatchID" runat="server" />
        <asp:HiddenField ID="hdnWorkflowStageID" runat="server" />
        <asp:HiddenField ID="hdnUID" runat="server" />
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
						            <td valign="bottom" style="width: 209px;"></td>
						            <td style="width: 15px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="15" /></td>
						            <td style="width: 10px;" valign="bottom">
						                <table cellpadding="0" cellspacing="0" border="0">
						                    <tr>
						                        <td style="height: 22px; white-space: nowrap;" valign="middle" align="left" nowrap="nowrap">
                                                    <asp:HyperLink ID="linkExcel" runat="server" ToolTip="Export to Excel in Item Maintenance Format">Export to Excel</asp:HyperLink>
						                        </td>
						                    </tr>
						                </table>
						            </td>
						            <td style="width: 200px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="200" /></td>
						            <td id="validationDisplayTD" runat="server">
                                        <div id="validationSummary">
                                            <novalibra:NLValidationSummary ID="validationDisplay" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" runat="server" />
                                        </div>
                                        <asp:Label ID="lblItemMessage" runat="server" style="padding-left:5px;" CssClass="redText" ></asp:Label>
                                    </td>
						            <td style="width: 100%;" align="right" valign="bottom">
                                        <img id="validBatch" runat="server" alt="Batch Validity" width="11" height="11" src="images/valid_null_small.gif" />
						            </td>
						        </tr>
                            </table>
						    <table cellpadding="0" cellspacing="0" border="0" width="100%">
							    <tr>
								   <th valign="top" colspan="2" style="padding: 5px;" align="left">
								    <asp:Label ID="lblMaintType" runat="server" Text=""></asp:Label>
								    &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;
								    Log ID: <asp:Label ID="batch" runat="server" Text=""></asp:Label>
								    &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;
								    Type: <asp:Label ID="lblBatchType" runat="server" Text=""></asp:Label>
								    &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;
								    Stage: <asp:Label ID="stageName" runat="server" Text=""></asp:Label>
								    &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;
								    Last Updated: <asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label> 
								    <asp:HiddenField ID="lastUpdatedMe" runat="server" Value="" />
								</th>
							    </tr>
						    </table>
					    </div>
				    </div>
                    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
				    <div id="main">
                        <ig:WebDataGrid ID="gvItemList" runat="server" Width="98%" AutoGenerateColumns="False" DataKeyFields="ID" DefaultColumnWidth="150px" CssClass="itemgrid" AltItemCssClass="altitemrow" ItemCssClass="itemrow" >
                            <Columns>
                                <ig:TemplateDataField Header-Text="ID" Hidden="true" Key="ID" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdn_ID" runat="server" Value='<%# Eval("ID")%>' />
                                    </ItemTemplate>
<Header Text="ID" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Key="Is_Valid" Header-CssClass="itemheader" Width="50px" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Image ID="is_valid" AlternateText="IsValid" runat="server" ImageUrl='<%# GetCheckBoxUrl(Eval("Is_Valid")) %>' />
                                        <asp:HiddenField ID="hdn_PackItemIndicator" runat="server" Value='<%# Eval("Pack_Item_Indicator")%>' />
                                    </ItemTemplate>
<Header Text="Valid" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="SKU" Key="Michaels_SKU" Width="100px" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSKU" runat="server" CssClass="itemcelltext" Text='<%# Eval("Michaels_SKU")%>' /><br />
                                        <asp:LinkButton ID="btnDelete" runat="server" OnClientClick='<%# Eval("ID", "deleteItem({0}, ").ToString() + Eval("Michaels_SKU", """{0}""); return false;").ToString()%>' Text="Delete" />
                                    </ItemTemplate>
<Header Text="SKU" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="Vendor Number" Key="Vendor_Number" Width="100px" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblVendorNumber" runat="server" CssClass="itemcellText" Text='<%# Eval("Vendor_Number")%>' />
                                    </ItemTemplate>

<Header Text="Vendor Number" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="Vendor Name" Key="Vendor_Name" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblVendorName" runat="server" CssClass="itemcellText" Text='<%# Eval("Vendor_Name") %>' />
                                    </ItemTemplate>

<Header Text="Vendor Name" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="Item Type" Key="Item_Type" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblItemType" runat="server" CssClass="itemcellText" Text='<%# Eval("Item_Type") %>' />
                                    </ItemTemplate>

<Header Text="Item Type" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="Vendor Style Number" Key="Vendor_Style_Num" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblVendorStyleNum" runat="server" CssClass="itemcellText" Text='<%# Eval("Vendor_Style_Num") %>' />
                                    </ItemTemplate>

<Header Text="Vendor Style Number" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="SKU Description" Key="Item_Desc" Header-CssClass="itemheader" CssClass="itemcell">
                                     <ItemTemplate>
                                        <asp:HiddenField ID="hdnItemDesc" runat="server" Value='<%# Eval("Item_Desc")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false"  /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("Item_Desc")%>' EnableViewState="false"  /><br />
                                            <asp:TextBox ID="edit_value" runat="server" EnableViewState="false" />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" ></asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrItemDesc" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("ItemDesc")%>'></div><br />SKU Description</HeaderTemplate>
<Header Text="SKU Description"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="Status" Key="Item_Status" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblItemStatus" runat="server" CssClass="itemcellText" Text='<%# Eval("Item_Status") %>' />
                                    </ItemTemplate>

<Header Text="Status" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="Department" Key="Department_Num" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblDepartmentNum" runat="server" CssClass="itemcellText" Text='<%# Eval("Department_Num") %>' />
                                    </ItemTemplate>

<Header Text="Department" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>    
                                <ig:TemplateDataField Header-Text="Class" Key="Class_Num" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblClassNum" runat="server" CssClass="itemcellText" Text='<%# Eval("Class_Num") %>' />
                                    </ItemTemplate>

<Header Text="Class" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>   
                                <ig:TemplateDataField Header-Text="Sub-Class" Key="Sub_Class_Num" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSubClassNum" runat="server" CssClass="itemcellText" Text='<%# Eval("Sub_Class_Num") %>' />
                                    </ItemTemplate>

<Header Text="Sub-Class" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>     
                                <ig:TemplateDataField Header-Text="SKU Group" Key="SKU_Group" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblSKUGroup" runat="server" CssClass="itemcellText" Text='<%# Eval("SKU_Group") %>' />
                                    </ItemTemplate>
<Header Text="SKU Group" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="Private Brand Label" Key="Private_Brand_Label" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:Label ID="lblPrivateBrandLabel" runat="server" CssClass="itemcellText" Text='<%# Eval("Private_Brand_Label") %>' />
                                    </ItemTemplate>
<Header Text="Private Brand Label" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>     
                                <ig:TemplateDataField Header-Text="Package Language Indicator English" Key="PLI_English" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnPLIEnglish" runat="server" Value='<%# Eval("PLI_English")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false"  >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false"  /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("PLI_English")%>' EnableViewState="false"  /><br />
                                            <asp:DropDownList ID="edit_value" runat="server" EnableViewState="false"   >
                                                <asp:ListItem Value="" Text=""  />
                                                <asp:ListItem Value="N" Text="N" />
                                                <asp:ListItem Value="Y" Text="Y" />
                                            </asp:DropDownList>
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" >&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrPLIEnglish" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("PLIEnglish")%>'></div><br />Package Language Indicator English</HeaderTemplate>
<Header Text="Package Language Indicator English" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>     
                                <ig:TemplateDataField Header-Text="Package Language Indicator French" Key="PLI_French" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnPLIFrench" runat="server" Value='<%# Eval("PLI_French")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false"  >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false"  /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("PLI_French")%>'  EnableViewState="false" /><br />
                                            <asp:DropDownList ID="edit_value" runat="server" EnableViewState="false"  >
                                                <asp:ListItem Value="" Text="" />
                                                <asp:ListItem Value="N" Text="N" />
                                                <asp:ListItem Value="Y" Text="Y" />
                                            </asp:DropDownList>
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" >&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrPLIFrench" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("PLIFrench")%>'></div><br />Package Language Indicator French</HeaderTemplate>
<Header Text="Package Language Indicator French" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="Package Language Indicator Spanish" Key="PLI_Spanish" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnPLISpanish" runat="server" Value='<%# Eval("PLI_Spanish")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false"  /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("PLI_Spanish")%>' EnableViewState="false"  /><br />
                                            <asp:DropDownList ID="edit_value" runat="server" EnableViewState="false"  >
                                                <asp:ListItem Value="" Text="" />
                                                <asp:ListItem Value="N" Text="N" />
                                                <asp:ListItem Value="Y" Text="Y" />
                                            </asp:DropDownList>
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false">&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrPLISpanish" style="height: 50px;width:100%;text-decoration:none;"  ondblclick='<%# GetUpdateAllFunction("PLISpanish")%>'></div><br />Package Language Indicator Spanish</HeaderTemplate>
<Header Text="Package Language Indicator Spanish" CssClass="itemheader"></Header>
                                </ig:TemplateDataField>
                                <ig:TemplateDataField Header-Text="Exempt End Date" Key="Exempt_End_Date_French" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnExemptEndDateFrench" runat="server" Value='<%# Eval("Exempt_End_Date_French")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("Exempt_End_Date_French")%>' EnableViewState="false" /><br />
                                            <asp:TextBox ID="edit_value" runat="server" EnableViewState="false" />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" ></asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrExemptEndDateFrench" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("ExemptEndDateFrench")%>'></div><br />Exempt End Date French</HeaderTemplate>
<Header Text="Exempt End Date"></Header>
                                </ig:TemplateDataField>  
                                <ig:TemplateDataField Header-Text="Translation Indicator French" Key="TI_French" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnTIFrench" runat="server" Value='<%# Eval("TI_French")%>' EnableViewState="false" />
                                        <asp:Panel ID="change_div" runat="server" >
                                            <asp:Label ID="chg_value" runat="server" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("TI_French")%>' EnableViewState="false" /><br />
                                            <asp:DropDownList ID="edit_value" runat="server" EnableViewState="false"  >
                                                <asp:ListItem Value="" Text="" />
                                                <asp:ListItem Value="N" Text="N" />
                                                <asp:ListItem Value="Y" Text="Y" />
                                            </asp:DropDownList>
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" >&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrTIFrench" style="height: 50px;width:100%;text-decoration:none;"  ondblclick='<%# GetUpdateAllFunction("TIFrench")%>'></div><br />Translation Indicator French</HeaderTemplate>
<Header Text="Translation Indicator French" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="English Short Description" Key="English_Short_Description" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnEnglishShortDescription" runat="server" Value='<%# Eval("English_Short_Description")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("English_Short_Description")%>' EnableViewState="false" /><br />
                                            <asp:TextBox ID="edit_value" runat="server" EnableViewState="false" />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" ></asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrEnglishShortDescription" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("EnglishShortDescription")%>'></div><br />English Short Description</HeaderTemplate>
<Header Text="English Short Description"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="English Long Description" Key="English_Long_Description" Header-CssClass="itemheader" CssClass="itemcell" Width="300px">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnEnglishLongDescription" runat="server" Value='<%# Eval("English_Long_Description")%>' />
                                        <asp:Panel ID="change_div" runat="server" >
                                            <asp:Label ID="chg_value" runat="server" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("English_Long_Description")%>' /><br />
                                            <asp:TextBox ID="edit_value" runat="server" />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo">&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrEnglishLongDescription" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("EnglishLongDescription")%>'></div><br />English Long Description</HeaderTemplate>
<Header Text="English Long Description" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="French Short Description" Key="French_Short_Description" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnFrenchShortDescription" runat="server" Value='<%# Eval("French_Short_Description")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("French_Short_Description")%>' EnableViewState="false" /><br />
                                            <asp:TextBox ID="edit_value" runat="server" EnableViewState="false" />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" >&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrFrenchShortDescription" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("FrenchShortDescription")%>'></div><br />French Short Description</HeaderTemplate>
<Header Text="French Short Description" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="French Long Description" Key="French_Long_Description" Header-CssClass="itemheader" CssClass="itemcell" Width="300px">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnFrenchLongDescription" runat="server" Value='<%# Eval("French_Long_Description")%>' />
                                        <asp:Panel ID="change_div" runat="server"  EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("French_Long_Description")%>' EnableViewState="false" /><br />
                                            <asp:TextBox ID="edit_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" >&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrFrenchLongDescription" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("FrenchLongDescription")%>'></div><br />French Long Description</HeaderTemplate>
<Header Text="French Long Description" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="Spanish Short Description" Key="Spanish_Short_Description" Header-CssClass="itemheader" CssClass="itemcell">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnSpanishShortDescription" runat="server" Value='<%# Eval("Spanish_Short_Description")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("Spanish_Short_Description")%>' EnableViewState="false"  /><br />
                                            <asp:TextBox ID="edit_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" >&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrSpanishShortDescription" style="height: 50px;width:100%;text-decoration:none;" ondblclick='<%# GetUpdateAllFunction("SpanishShortDescription")%>'></div><br />Spanish Short Description</HeaderTemplate>
<Header Text="Spanish Short Description" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                                <ig:TemplateDataField Header-Text="Spanish Long Description" Key="Spanish_Long_Description" Header-CssClass="itemheader" CssClass="itemcell" Width="300px">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnSpanishLongDescription" runat="server" Value='<%# Eval("Spanish_Long_Description")%>' />
                                        <asp:Panel ID="change_div" runat="server" EnableViewState="false" >
                                            <asp:Label ID="chg_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Label id="orig_value" runat="server" Text='<%# Eval("Spanish_Long_Description")%>' EnableViewState="false" /><br />
                                            <asp:TextBox ID="edit_value" runat="server" EnableViewState="false" /><br />
                                            <asp:Panel id="edit_undo" runat="server" CssClass="changeundo" EnableViewState="false" >&nbsp;</asp:Panel>
                                        </asp:Panel>
                                    </ItemTemplate>
                                    <HeaderTemplate><div id="hdrSpanishLongDescription" style="height: 50px;width:100%;text-decoration:none;"  ondblclick='<%# GetUpdateAllFunction("SpanishLongDescription")%>'></div><br />Spanish Long Description</HeaderTemplate>
<Header Text="Spanish Long Description" CssClass="itemheader"></Header>
                                </ig:TemplateDataField> 
                            </Columns>
                            <Behaviors>
                                <ig:ColumnFixing Enabled="True" FixLocation="Left" AutoAdjustCells="false" ShowFixButtons="false" CellCssClass="itemfixedcell">
                                </ig:ColumnFixing>
                                <ig:Activation>
                                </ig:Activation>
                                <ig:Sorting AscendingImageUrl="~\images\sort_asc.gif" DescendingImageUrl="~\images\sort_desc.gif">
                                    <ColumnSettings>
                                        <ig:SortingColumnSetting ColumnKey="IsValid" Sortable="False" />
                                    </ColumnSettings>
                                </ig:Sorting>
                                <ig:Paging Enabled="true" PagerAppearance="Bottom" PageSize="10" >
                                    <PagerTemplate>
                                       <table style="width: 100%"  >
                                           <tr align="left">
                                               <td>
                                                   <asp:ImageButton ID="lnkFirst" CommandName="Page" CommandArgument="First" runat="server" ImageUrl="~/images/grid/paging/btn_vcr_top.gif" AlternateText="Jump to the first page" BorderStyle="None" />
                                                   <asp:ImageButton ID="lnkPrevious" CommandName="Page" CommandArgument="Prev" runat="server" ImageUrl="~/images/grid/paging/btn_vcr_prev.gif" AlternateText="Jump to the previous page" BorderStyle="None" />&nbsp;
                                                   Page&nbsp;<asp:DropDownList ID="ddlPageList" runat="server" OnSelectedIndexChanged="PageList_SelectedIndexChanged" AutoPostBack="true" /><asp:label id="PagingInformation" runat="server" style="padding-left:5px; padding-right:5px;" BorderWidth="0"/>  &nbsp;
                                                   <asp:ImageButton ID="lnkNext" CommandName="Page" CommandArgument="Next" runat="server" ImageUrl="~/images/grid/paging/btn_vcr_next.gif" AlternateText="Jump to the next page" BorderStyle="None" />
                                                   <asp:ImageButton ID="lnkLast" CommandName="Page" CommandArgument="Last" runat="server" ImageUrl="~/images/grid/paging/btn_vcr_bot.gif" AlternateText="Jump to the last page" BorderStyle="None" />&nbsp;
                                                   <asp:ImageButton id="btnSetBP" runat="server" style="vertical-align: middle" ImageUrl="~/images/grid/paging/refresh.gif" CommandName="PageReset" CommandArgument = "0" /> 
                                                   <asp:Label id="lblItemsFound" runat="server" Text="Item(es) Found" Width= "130px"/>           
                                               </td>
                                           </tr>
                                       </table>
                                    </PagerTemplate>
                                </ig:Paging>
                            </Behaviors>
                        </ig:WebDataGrid>
				    </div>
			    </div>
            </div>
        </div>


        <!-- set all fields -->
        <div id="gridlightbox" style="width:100%; height: 100%; display: none;" >
            <div id="gridSetAll" style="z-index: 2000; width: 250px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
	            <div id="gridSetAllContent">
	                <table border="0" cellpadding="0" cellspacing="0" class="gridSetAllBG" style="width: 100%">
	                    <tr>
                            <td>
	                            <table border="0" cellpadding="2" cellspacing="1" style="width: 100%;">
	                                <tr>
	                                    <td id="gridSetAllHeader"><img align="right" id="close" src="images/close.gif" alt="Close" title="" border="0" onclick="setAllClose();" style="padding-bottom: 5px;cursor:pointer;" />Set All Values for Column</td>
	                                </tr>
	                                <tr class="gridSetAllRow">
	                                    <td style="width: 100%;"><span id="gridSetAllColumn">COLUMN-NAME</span>
	                                    <input type="hidden" id="gridSetAllType" value="" />
	                                    <input type="hidden" id="gridSetAllParam" value="" />
	                                    <input type="hidden" id="gridSetAllCID" value="" />
	                                    <input type="hidden" id="gridSetAllCName" value="" /></td>
	                                </tr>
	                                <tr class="gridSetAllRow">
	                                    <td id="gridSetAllData">COLUMN-CONTROL&nbsp;</td>
	                                </tr>
	                                <tr class="gridSetAllFooter">
	                                    <td>
	                                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;" class="gridSetAllFooter">
	                                            <tr>
	                                                <td align="left"><input type="button" id="btnSetAllClose" onclick="setAllClose()" value="Cancel" class="formButton" style="font-weight: bold;" /></td>
	                                                <td align="right"><input type="button" id="btnSetAllSave" onclick="setAllSave()" value="Set All" class="formButton" style="font-weight: bold;" /></td>
	                                            </tr>
	                                        </table>
	                                    </td>
	                                </tr>
	                            </table>
	                        </td>
	                    </tr>
	                </table>
	            </div>
            </div>
        </div>
    </form>
</body>
</html>
