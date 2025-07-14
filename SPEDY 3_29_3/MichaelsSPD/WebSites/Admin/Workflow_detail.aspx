<%@ page language="VB" autoeventwireup="false" inherits="Workflow_Detail, App_Web_1xpdmjgj" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register TagPrefix="customcontrol" TagName="ExceptionPanel" Src="~/WebControls/ExceptionPanel.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >

<head id="Head1" runat="server">
    <title>Add/Edit Workflow Stage</title>
    <link rel="stylesheet" href="/css/styles.css" type="text/css"/>
    <style type="text/css">
        th { text-align: left; padding: 5px; }
        body {background-color: #E2E2B2;}
        input, select, textarea
        {
            background-color: #ffffff;
        }
        .formLabel
        {
            font-family: Arial, Helvetica, Sans-Serif;
	        text-align: left;
	        white-space: nowrap;
	        font-size: 10pt;
        }
        .formField
        {
	        font-size: 10pt;
	        font-family: Arial, Helvetica, Sans-Serif;
        }
        .bodyText
        {
	        font-family: Arial, Helvetica, Sans-Serif;
	        font-size: 10pt;
	        color: #000;
        }
        .button
        {
		        font-family: Arial, Helvetica, Sans-Serif;
		        font-size: 8pt; /*background-color:#63639C; color:#ffffff;*/
		        background-color:silver;
		        color:navy;
        }		
        .button2
        {
		        font-family: Arial, Helvetica, Sans-Serif;
		        font-size: 10pt; /*background-color:#63639C; color:#ffffff;*/
		        background-color:silver;
		        color:navy;
        }
        .Req
        {
        	color:Red;
        	font-size: 10pt;
        	font-family: Arial, Helvetica, Sans-Serif;
        }
        .green
        {
            color:LightGreen;
        }
        
        .exceptionBox select
        {
            margin-left:30px;
        }
        .exceptionBox p
        {
            margin-top: 3px;
        }
		#valSum ul,li
        {
            color: Red;
        }
        
    </style>
    <script language="javascript" type="text/javascript" src="App_Include/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="App_Include/Workflow_Detail.js"></script>
</head>

<body style="background-color:#cccccc;" onload="javascript:CheckSecurity()" onunload="javascript:RefreshParent()" >
    <form id="frmWorkflow" runat="server" style=" font-family:Arial; font-size:12px">
    
        <asp:HiddenField ID="hdnWorkflowId" runat="server"  EnableViewState="true" Value="-1"/>
        <asp:HiddenField ID="hdnWorkflowTypeId" runat="server"  EnableViewState="true" Value="-1"/>
        <asp:HiddenField ID="hdnCurrentStageId" runat="server"  EnableViewState="true" Value="0"/>
        <asp:HiddenField ID="hdnUserId" runat="server"  EnableViewState="true" Value="0"/>
        <asp:HiddenField ID="hdnCloseme" runat="server" Value="" />
        
        <div runat="server" id="maindiv">
            <table cellpadding="0" cellspacing="0" border="0" style="width: 100%">
		        <tr style="background-color:Black; color:White">
		            <th valign="top" >Workflow Stage ADDITION &amp; CHANGES &nbsp<asp:Label ID="lblWorkflow" runat="server" Text="" Visible="true"></asp:Label></th>
			        <th><asp:Label ID="lblType" visible="true" runat="server" Text="ADD NEW STAGE" CssClass="green"></asp:Label></th>
                </tr>
            </table>
	    </div> 
	    <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
	    <div id="validationSummary">
    	      <asp:ValidationSummary ID="valSum" runat="server" HeaderText="The following fields are required: " />
	    </div>
	    <asp:Panel ID="pnlMain" runat="server" Visible = "true" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Width = "980px">
	        <table border="0">
	            <tr>
	                <td>
	                    <table border="0" cellpadding="2" cellspacing="0" >
                            <tr>
                                <td align="left" style="height: 28px; width: 210px">
                                    <asp:Label ID="lblName" runat="server" Text="Work Stage Name:" CssClass="formLabel"></asp:Label>
                                    <asp:Label ID="lblrfield1" runat="server" Text="*" CssClass="Req"></asp:Label>
                                </td>
                                <td align="left" style="height: 28px; width: 170px">     
                                    <asp:TextBox id="txtName" runat="server" cssclass="bodyText" maxlength="100" width="160px"></asp:TextBox >
                                    <asp:RequiredFieldValidator ID="NameValidator" runat="server" ControlToValidate="txtName" ErrorMessage="Work Stage Name is a required field" ><span /></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" style="height: 28px; width: 210px">
                                    <asp:Label ID="lblStage" runat="server" Text="Stage Type:" CssClass="formLabel"></asp:Label>
                                    <asp:Label ID="lblrfield2" runat="server" Text="*" CssClass="Req"></asp:Label>
                                </td>
                                <td align="left" style="height: 28px; width: 170px">
                                    <asp:DropDownList id="ddStageType" runat="server" cssclass="bodyText" Enabled="true" Width="160px" DataTextField="Stage_Type_Name" DataValueField="Stage_Type_Id"></asp:DropDownList >
                                    <asp:RequiredFieldValidator ID="StageTypeValidator" runat="server" ControlToValidate="txtName" ErrorMessage="Stage Type is a required field" Display="Dynamic"><span /></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" style="height: 28px; width: 210px">
                                     <asp:Label ID="lblPrimaryApprover" runat="server" Text="Primary Approver:" CssClass="formLabel"></asp:Label>
                                    <asp:Label ID="lblrfield3" runat="server" Text="*" CssClass="Req"></asp:Label>
                                </td>
                                 <td align="left" style="height: 28px; width: 170px">
                                    <asp:DropDownList id="ddPrimaryApprover" runat="server" cssclass="bodyText" Enabled = "true" Width="160px" DataTextField="Group_Name" DataValueField="id"></asp:DropDownList >
                                    <asp:RequiredFieldValidator ID="ApproverValidator" runat="server" ControlToValidate="ddPrimaryApprover" ErrorMessage="Primary Approver is a required field" Display="Dynamic"><span /></asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" style="height: 28px;width: 210px">
                                    <asp:Label ID="lblDapprStage" runat="server" Text="Default Approval Next Stage:" width="170px" CssClass="formLabel"></asp:Label>
                                    <asp:Label ID="lblrfield6" runat="server" Text="*" CssClass="Req"></asp:Label>
                                    </td>
                                <td align="left" style="height: 28px; width: 210px">
                                    <asp:DropDownList id="ddNextStage" runat="server" cssclass="bodyText" Enabled = "true" Width="160px" DataTextField="Stage_Name" DataValueField="id"></asp:DropDownList >
                                </td>
                            </tr>
                            <tr>
                                <td align="left" style="width: 170px; height: 28px;">
                                    <asp:Label ID="lblEnable" runat="server" text="Enabled" cssclass="formLabel"></asp:Label><span id="Span3" runat="server" class="requiredFieldsIcon"></span>:</td>
                                <td align="left" style="height: 28px; width: 210px">
                                    <asp:CheckBox runat="server" ID="chkEnabled" Checked="true"></asp:CheckBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="left" style="width: 170px; height: 28px;" class="formLabel">Sequence #:
                                    <asp:Label ID="lblrfield4" runat="server" Text="*" CssClass="Req"></asp:Label>
                                </td>
                                <td align="left" style="height: 28px; width:214px">
                                    <asp:TextBox id="txtSequence" width ="30" runat="server" cssclass="bodyText" maxlength="4" ></asp:TextBox>
                                </td>     
                            </tr>
                            <tr>
                                <td align="left" style="width: 210px; height: 28px;">
                                    <asp:Label ID="lblDAstage" runat="server" Text="Default Disapproval Next Stage:" CssClass="formLabel"></asp:Label>
                                    <asp:Label ID="lblrfield7" runat="server" Text="*" CssClass="Req"></asp:Label>
                                </td>
                                <td align="left" style="width: 170px">
                                    <asp:DropDownList id="ddDisapprovalStage" cssclass="bodyText" runat="server" Enabled = "true" Width="160px"  DataTextField="Stage_Name" DataValueField="id"></asp:DropDownList >
                                </td>      
                            </tr>
                        </table> <!--style="position:absolute; top:60px; left:400px"  position: relative; top:5px; -->
                    </td>
                    <td>
                        <table border="0" cellpadding="2" cellspacing="0" >
                            <tr>
                                <td  align="left" style="width: 120px; text-align:right;">
                                    <asp:Label ID="lblSelAppr" runat="server" CssClass="formLabel" Text="Select User&nbsp;&nbsp;<br/>Approval Groups:"></asp:Label>
                                    <asp:Label ID="lblrfield5" runat="server" Text="*" CssClass="Req"></asp:Label>
                                </td>
                                <td class="formField" style="width: 142px">
                                    <asp:ListBox id="lstGrouplistSource" runat="server" cssclass="bodyText" Enabled = "true" Width="140px" Height="210px" DataTextField="Group_Name" DataValueField="id"></asp:ListBox >
                                </td>
                                <td align ="center"  style="width: 120px">
                                    <asp:Button ID="btnAddGrp" runat="server" CssClass="button" Text="Add Group >>" Width="120px" CausesValidation="false"/>
                                    <br />
                                    <asp:Button ID="btnRemoveGrp" runat="server" CssClass="button" Text="<< Remove Group" Width="120px" CausesValidation="false"/>
                                </td> 
                                <td>
                                     <asp:ListBox ID="lstGroupList" runat="server" Width = "140px" Height="210px" cssclass="bodyText" ></asp:ListBox>
                                </td>
                            </tr>
                        </table> 
                    </td>
	            </tr>
	        </table>                   
        </asp:Panel> 
        <br \> <!--style="position:absolute;left:820px;"  -->
        <table cellpadding="0" cellspacing="0" border="0" style="width:980px;">
	        <tr style="background-color:Black; color:White; height: 26px;">
	            <th width="90%">Set Workflow Stage Approval Exceptions</th>
	            <th width="10%">
	                <asp:Button ID="btnAddApprovalException"  CssClass="button" runat="server" Text="Add Approval Exception" OnClick="btnAddApprovalException_Click" CausesValidation="false" Width="160px"/>
		        </th>
		    </tr>
	    </table>             
        <br />
        <div id="divExceptions" runat="server" style="overflow: auto; overflow-x: hidden;
            height: 340px;" onscroll="saveScroll();">
            <!-- Exception Panels are dynamically added here -->
            <customcontrol:ExceptionPanel ID="ExceptionPanel" runat="server" />
        </div>
        <table border="0" cellpadding="0" cellspacing="0" style="width: 980px">
            <tr>
                <td align="left" style="width: 840px; text-align: left">
                    <asp:Label ID="lblProblem" runat="server" Text="" ForeColor="red" Visible="False"></asp:Label>
                </td>
                <td align="right" style="width: 120px">
                    <asp:Button ID="btnClose" CssClass="button2" runat="server" Text="Close" OnClientClick="javascript:return CloseButtonClick()"
                        Width="110px" UseSubmitBehavior="true" />
                </td>
                <td align="right" style="width: 120px">
                    <asp:Button ID="btnSaveClose" CssClass="button2" runat="server" Text="Save"
                        Width="110px" UseSubmitBehavior="true" />
                </td>
            </tr>
        </table>
        </ContentTemplate>
        </asp:UpdatePanel>
        
    </form>
</body>