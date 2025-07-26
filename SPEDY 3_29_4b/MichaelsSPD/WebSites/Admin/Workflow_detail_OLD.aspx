<%@ page language="VB" autoeventwireup="false" inherits="Workflow_detail_OLD, App_Web_1xpdmjgj" %>

<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>

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
        
    </style>
    <script language="javascript" type="text/javascript" src="app_include/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="app_include/Workflow_Detail.js"></script>
</head>

<body style="background-color:#cccccc;" onload="javascript:CheckSecurity()" onunload="javascript:RefreshParent()" >
    <form id="frmWorkflow" runat="server" style=" font-family:Arial; font-size:12px">

    <div runat="server" id="maindiv">
     <table cellpadding="0" cellspacing="0" border="0" style="width: 100%">
		<tr style="background-color:Black; color:White">
		    <th valign="top" >Workflow Stage ADDITION &amp; CHANGES &nbsp<asp:Label ID="lblWorkflow" runat="server" Text="" Visible="true"></asp:Label>
			</th>
			<th><asp:Label ID="lblType" visible="true" runat="server" Text="ADD NEW STAGE" CssClass="green"></asp:Label></th>
			</tr>
	 </table>
	 <br />
	 </div>
	 <div style="border-style:solid; border-width:1px;  border-color:DimGray; padding:3px; margin-left:3px; margin-right:3px;">

    <!-- Comment below out to debug and manage controls
    -->
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>

    <asp:HiddenField ID="hdnCloseme" runat="server" EnableViewState="true" Value="0" />
    <asp:HiddenField ID="hdnScrollTo" runat="server" EnableViewState="false" Value="" />
    
    <asp:HiddenField ID="hdnCurrentStageId" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnWorkflowId" runat="server"  EnableViewState="true" Value="-1"/>
    <asp:HiddenField ID="hdnUserId" runat="server"  EnableViewState="true"/>
    <asp:HiddenField ID="hdnExcDeptId" runat="server"  EnableViewState="true"/>
    <%--<asp:HiddenField ID="hdnRefControl" runat="server" Value="" />--%>

    <asp:HiddenField ID="hdnAddedCond1" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond2" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond3" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond4" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond5" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond6" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond7" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond8" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond9" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond10" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond11" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond12" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond13" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond14" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond15" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond16" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond17" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond18" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond19" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnAddedCond20" runat="server"  EnableViewState="true" Value="0"/>
    
    <asp:HiddenField ID="hdnAddedApprExcept" runat="server"  EnableViewState="true" Value="0"/>
<%--    <asp:HiddenField ID="hdnAddedDisApprExcept" runat="server"  EnableViewState="true" Value="0"/>
--%>
    <asp:HiddenField ID="hdnIdofExc1" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc2" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc3" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc4" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc5" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc6" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc7" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc8" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc9" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc10" runat="server"  EnableViewState="true" Value="0"/>

    <asp:HiddenField ID="hdnIdofExc11" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc12" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc13" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc14" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc15" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc16" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc17" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc18" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc19" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofExc20" runat="server"  EnableViewState="true" Value="0"/>

<%--    <asp:HiddenField ID="hdnIdofDAExc1" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc2" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc3" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc4" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc5" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc6" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc7" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc8" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc9" runat="server"  EnableViewState="true" Value="0"/>
    <asp:HiddenField ID="hdnIdofDAExc10" runat="server"  EnableViewState="true" Value="0"/>

    <asp:HiddenField ID="hdnAddedDACond1" runat="server" value="0"/>
    <asp:HiddenField ID="hdnAddedDACond2" runat="server" value="0"/>
    <asp:HiddenField ID="hdnAddedDACond3" runat="server" value="0"/> 
    <asp:HiddenField ID="hdnAddedDACond4" runat="server" value="0"/> 
    <asp:HiddenField ID="hdnAddedDACond5" runat="server" value="0"/> 
    <asp:HiddenField ID="hdnAddedDACond6" runat="server" value="0"/> 
    <asp:HiddenField ID="hdnAddedDACond7" runat="server" value="0"/> 
    <asp:HiddenField ID="hdnAddedDACond8" runat="server" value="0"/> 
    <asp:HiddenField ID="hdnAddedDACond9" runat="server" value="0"/> 
    <asp:HiddenField ID="hdnAddedDACond10" runat="server" value="0"/> 
--%>	 
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
                </td>
                </tr>
                <tr>
                <td align="left" style="height: 28px; width: 210px">
                     <asp:Label ID="lblStage" runat="server" Text="Stage Type:" CssClass="formLabel"></asp:Label>
                    <asp:Label ID="lblrfield2" runat="server" Text="*" CssClass="Req"></asp:Label>
                 </td>
                 <td align="left" style="height: 28px; width: 170px">
                    <asp:DropDownList id="ddStageType" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList >
                </td>
                </tr>
                <tr>
                    <td align="left" style="height: 28px; width: 210px">
                         <asp:Label ID="lblPrimaryApprover" runat="server" Text="Primary Approver:" CssClass="formLabel"></asp:Label>
                        <asp:Label ID="lblrfield3" runat="server" Text="*" CssClass="Req"></asp:Label>
                    </td>
                     <td align="left" style="height: 28px; width: 170px">
                        <asp:DropDownList id="ddPrimaryApprover" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList >
                    </td>
                </tr>
                
                 <tr>
                <td align="left" style="height: 28px;width: 210px">
                    <asp:Label ID="lblDapprStage" runat="server" Text="Default Approval Next Stage:" width="170px" CssClass="formLabel"></asp:Label>
                    <asp:Label ID="lblrfield6" runat="server" Text="*" CssClass="Req"></asp:Label>
                    </td>
                <td align="left" style="height: 28px; width: 210px">
                    <asp:DropDownList id="ddNextStage" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList >
                </td>
                </tr>
                <tr>
                <td align="left" style="width: 170px; height: 28px;">
                    <asp:Label ID="lblEnable" runat="server" text="Enabled" cssclass="formLabel"></asp:Label><span id="Span3" runat="server" class="requiredFieldsIcon"></span>:</td>
                <td align="left" style="height: 28px; width: 210px">
                    <asp:CheckBox runat="server" ID="chkEnabled" Checked="true">
                    </asp:CheckBox>
                </td>
                </tr>
                <tr>
                <td align="left" style="width: 170px; height: 28px;" class="formLabel">Sequence #:
                    <asp:Label ID="lblrfield4" runat="server" Text="*" CssClass="Req"></asp:Label>
                </td>
                <td align="left" style="height: 28px; width:214px">
                    <asp:TextBox id="txtSequence" width ="30" runat="server" cssclass="bodyText" maxlength="4"></asp:TextBox>
                </td>
                 
            </tr>
            <tr>
                <td align="left" style="width: 210px; height: 28px;">
                    <asp:Label ID="lblDAstage" runat="server" Text="Default Disapproval Next Stage:" CssClass="formLabel"></asp:Label>
                    <asp:Label ID="lblrfield7" runat="server" Text="*" CssClass="Req"></asp:Label>
                </td>
                <td align="left" style="width: 170px">
                    <asp:DropDownList id="ddDisapprovalStage" cssclass="bodyText" runat="server" Enabled = "true" Width="160px"></asp:DropDownList >
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
                    <asp:Button ID="btnAddGrp" runat="server" CssClass="button" Text="Add Group >>" Width="120px"/>
                    <br />
                    <asp:Button ID="btnRemoveGrp" runat="server" CssClass="button" Text="<< Remove Group" Width="120px"/>
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
	        <asp:Button ID="btnAddApprovalException"  CssClass="button" runat="server" Text="Add Approval Exception" OnClientClick= "javascript:return AddExcClick('A')" Width="160px"/>
		</th>
		</tr>
	 </table>             
    <br />
    
    <div id="divExceptions" style="overflow:auto; overflow-x:hidden; height:340px; " onscroll="saveScroll();">
    <asp:Panel ID="pnlException1" runat="server" Visible = "true" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px" Width = "980px" Height="75px" > 
        <table id ="tblApprovalExc1" runat="server" border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="height: 42px; width:380px;" >
                 <table>
                    <tr>
                        <td><asp:label ID="lblApprov" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList id="DDApprStageExc1" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td> 
                    <tr>
                        <td><asp:Label ID="lblOrder1" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder1" runat="server" EnableViewState="true" /></td>
                    </tr>
                 </table>
                </td>
                <td  align = "right" style="width: 190px;">
                    <asp:Label ID="lblSelExc" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
                </td>
                <td align = "left" style="width: 180px;">
                    <asp:DropDownList id="ddCondExc1" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
                </td>
                <td style="width: 25px">
                    <asp:DropDownList id="ddAndOrExc1" runat="server" cssclass="bodyText" Enabled ="false" Width="55px">
                    <asp:ListItem Selected="True">AND</asp:ListItem>
                    <asp:ListItem>OR</asp:ListItem>
                    </asp:DropDownList ></td>
                <td style="width: 30px">
                    <asp:HyperLink ID="hpSelDept1" runat="server"  visible = "false" NavigateUrl="javascript:openDepartSet(1,1,'Approval','hdnDeptList1');">Dept</asp:HyperLink>
                    <asp:HiddenField ID="hdnDeptList1" runat="server" Value="" />
                    <asp:HyperLink ID="hpSelField1" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(1,1,'hdnFieldList1');">Fields</asp:HyperLink>
                    <asp:HiddenField ID="hdnFieldList1" runat="server" Value="" />
                </td>
                <td style="width: 110px" align="right"><asp:Button ID="btnAddExc1Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/></td> 
            </tr>              
        </table> 
    </asp:Panel>   &nbsp;<!--style="position:relative;left:0px; top:10px"  --> <!-- style="position:relative;left:10px; top:20px"-->

    <asp:Panel ID="PnlException2" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px" Width = "980px" Height = "90px">        
        <table id ="tblApprovalExc2" runat="server" border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:" >
            <tr>
            <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove2" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc2" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder2" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder2" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc2" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(2,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align = "right" style="width: 190px;" >
                <asp:Label ID="lblSelExc2" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align = "left" style="width: 180px;" >
                <asp:DropDownList id="ddCondExc2" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width:25px;" >
                <asp:DropDownList id="ddAndOrExc2" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem> 
                </asp:DropDownList ></td>
             <td style="width: 30px;" >
                <asp:HyperLink ID="hpSelDept2" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(2,1,'Approval','hdnDeptList2');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList2" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField2" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(2,1,'hdnFieldList2');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList2" runat="server" Value="" />
            </td>
            <td align="right" style="" >        
                <asp:Button ID="btnAddExc2Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/></td>
            </tr> 
            
        </table> 
    </asp:Panel>   &nbsp; <!--style="position:relative;left:0px; top:10px"  style="position:relative;left:10px; top:20px"-->

    <asp:Panel ID="PnlException3" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px" Width = "980px" Height = "90px">        
        <table id ="tblApprovalExc3" runat="server" border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove3" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc3" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder3" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder3" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc3" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(3,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align = "right" style="width: 190px;">
                <asp:Label ID="lblSelExc3" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align = "left" style="width: 180px; height: 36px;">
                <asp:DropDownList id="ddCondExc3" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="height: 36px; width: 25px;" >
                <asp:DropDownList id="ddAndOrExc3" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem> 
                </asp:DropDownList ></td>
             <td style="width: 30px; height: 36px;">
                <asp:HyperLink ID="hpSelDept3" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(3,1,'Approval','hdnDeptList3');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList3" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField3" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(3,1,'hdnFieldList3');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList3" runat="server" Value="" />
            </td>
            <td align="right" style="height: 36px" >        
            <asp:Button ID="btnAddExc3Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/></td>
            </tr> 
        </table> 
    </asp:Panel> 
    &nbsp; <!--style="position:relative;left:0px; top:10px"  style="position:relative;left:10px; top:20px"-->
    
    <asp:Panel ID="PnlException4" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc4" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
            <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove4" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc4" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblOrder4" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder4" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc4" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(4,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc4" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc4" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc4" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept4" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(4,1,'Approval','hdnDeptList4');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList4" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField4" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(4,1,'hdnFieldList4');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList4" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc4Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  
    &nbsp;	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException5" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc5" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
            <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove5" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc5" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder5" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder5" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc5" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(5,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align = "right" style="width: 190px;" >
                <asp:Label ID="lblSelExc5" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc5" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc5" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept5" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(5,1,'Approval','hdnDeptList5');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList5" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField5" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(5,1,'hdnFieldList5');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList5" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc5Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table>
    </asp:Panel> 
    &nbsp;	
    <!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException6" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc6" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove6" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc6" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder6" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder6" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc6" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(6,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align = "right" style="width: 190px;" >
                <asp:Label ID="lblSelExc6" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc6" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc6" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept6" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(6,1,'Approval','hdnDeptList6');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList6" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField6" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(6,1,'hdnFieldList6');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList6" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc6Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel> 
    &nbsp;	
	<!-- style="position:relative;left:0px; top:10px"  style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException7" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc7" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove7" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc7" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder7" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder7" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc7" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(7,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align = "right" style="width: 190px;" >
                <asp:Label ID="lblSelExc7" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc7" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc7" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept7" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(7,1,'Approval','hdnDeptList7');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList7" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField7" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(7,1,'hdnFieldList7');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList7" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc7Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>
    &nbsp;	
	<!-- style="position:relative;left:0px; top:10px"  style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException8" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc8" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove8" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc8" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder8" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder8" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc8" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(8,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align = "right" style="width: 190px;" >
                <asp:Label ID="lblSelExc8" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc8" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc8" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept8" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(8,1,'Approval','hdnDeptList8');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList8" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField8" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(8,1,'hdnFieldList8');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList8" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc8Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table>
    </asp:Panel>  
    &nbsp;	
	<!--style="position:relative;left:0px; top:10px"  style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException9" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc9" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove9" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc9" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder9" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder9" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc9" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(9,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align = "right" style="width: 190px;" >
                <asp:Label ID="lblSelExc9" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc9" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc9" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept9" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(9,1,'Approval','hdnDeptList9');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList9" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField9" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(9,1,'hdnFieldList9');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList9" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc9Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table>
    </asp:Panel>  
    
    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException10" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc10" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove10" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc10" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder10" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder10" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc10" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(10,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc10" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc10" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc10" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept10" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(10,1,'Approval','hdnDeptList10');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList10" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField10" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(10,1,'hdnFieldList10');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList10" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc10Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException11" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc11" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove11" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc11" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder11" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder11" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc11" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(11,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc11" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc11" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc11" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept11" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(11,1,'Approval','hdnDeptList11');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList11" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField11" runat="server" Visible="False" NavigateUrl="javascript:openFieldSet(11,1,'hdnFieldList11');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList11" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc11Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException12" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc12" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove12" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc12" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder12" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder12" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc12" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(12,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc12" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc12" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc12" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept12" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(12,1,'Approval','hdnDeptList12');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList12" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField12" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(12,1,'hdnFieldList12');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList12" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc12Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException13" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc13" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove13" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc13" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder13" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder13" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc13" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(13,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc13" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc13" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc13" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept13" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(13,1,'Approval','hdnDeptList13');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList13" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField13" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(13,1,'hdnFieldList13');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList13" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc13Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException14" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc14" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove14" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc14" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder14" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder14" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc14" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(14,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc14" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc14" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc14" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept14" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(14,1,'Approval','hdnDeptList14');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList14" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField14" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(14,1,'hdnFieldList14');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList14" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc14Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException15" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc15" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove15" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc15" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder15" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder15" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc15" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(15,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc15" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc15" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc15" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept15" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(15,1,'Approval','hdnDeptList15');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList15" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField15" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(15,1,'hdnFieldList15');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList15" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc15Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException16" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc16" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove16" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc16" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder16" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder16" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc16" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(16,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc16" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc16" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc16" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept16" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(16,1,'Approval','hdnDeptList16');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList16" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField16" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(16,1,'hdnFieldList16');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList16" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc16Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException17" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc17" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove17" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc17" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder17" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder17" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc17" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(17,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc17" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc17" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc17" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept17" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(17,1,'Approval','hdnDeptList17');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList17" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField17" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(17,1,'hdnFieldList17');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList17" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc17Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException18" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc18" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove18" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc18" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder18" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder18" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc18" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(18,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc18" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc18" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc18" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept18" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(18,1,'Approval','hdnDeptList18');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList18" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField18" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(18,1,'hdnFieldList18');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList18" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc18Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException19" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc19" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove19" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc19" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder19" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder19" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc19" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(19,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc19" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc19" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc19" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept19" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(19,1,'Approval','hdnDeptList19');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList19" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField19" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(19,1,'hdnFieldList19');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList19" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc19Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  

    &nbsp;	
	<!--style="position:relative;left:0px; top:10px" style="position:relative;left:10px; top:20px"-->
    <asp:Panel ID="PnlException20" runat="server" Visible = "false" BorderStyle="solid" BorderColor="WhiteSmoke" BorderWidth="1px"  Height = "90px" width="980px">
        <table id ="tblApprovalExc20" runat="server"  border="0" cellpadding="3" cellspacing="0" title="Add Stage Exceptions:">
            <tr>
                <td align="left" style="width: 380px;">
                <table>
                    <tr>
                        <td><asp:label ID="lblApprove20" runat="server" Font-Bold="true" Text="Approval Stage:" CssClass="formLabel"/></td>
                        <td> <asp:DropDownList id="DDApprStageExc20" runat="server" cssclass="bodyText" Enabled = "true" Width="160px"></asp:DropDownList ></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="LblOrder20" runat="server" Font-Bold="true" Text="Exception Order:" CssClass="formLabel"/></td>
                        <td><asp:DropDownList ID="ExceptionOrder20" runat="server"></asp:DropDownList></td>
                    </tr>
                    <tr>
                        <td><asp:Button ID="btnRemoveExc20" CssClass="button" runat="server" Text="Remove Exception" Width= "120px"  OnClientClick ="JavaScript:return RemoveBtnClickEx(20,'A');" ></asp:Button></td>
                    </tr>
                </table>
            </td>
            <td  align="right" style="width: 190px;" >
                <asp:Label ID="lblSelExc20" runat="server" Text="Exception Condition 1:" cssclass ="formLabel"></asp:Label>
            </td>
            <td align="left" style="width: 180px; height: 30px;">
                <asp:DropDownList id="ddCondExc20" runat="server" cssclass="bodyText" Enabled = "true" Width="180px" AutoPostBack="True"></asp:DropDownList >    
            </td>
            <td style="width: 25px; height: 30px;">
                <asp:DropDownList id="ddAndOrExc20" runat="server" cssclass="bodyText" Enabled = "False" Width="55px">
                <asp:ListItem Selected="True">AND</asp:ListItem>
                <asp:ListItem>OR</asp:ListItem>                     
               </asp:DropDownList ></td>
            <td style="width: 30px; height: 30px;">
                <asp:HyperLink ID="hpSelDept20" runat="server"  visible = "False" NavigateUrl="javascript:openDepartSet(20,1,'Approval','hdnDeptList20');">Dept</asp:HyperLink>
                <asp:HiddenField ID="hdnDeptList20" runat="server" Value="" />
                <asp:HyperLink ID="hpSelField20" runat="server" Visible = "false" NavigateUrl="javascript:openFieldSet(20,1,'hdnFieldList20');">Fields</asp:HyperLink>
                <asp:HiddenField ID="hdnFieldList20" runat="server" Value="" />
            </td>
            <td align="right" style="height: 30px">        
                <asp:Button ID="btnAddExc20Cond" runat="server" CssClass="button" Text="Add Condition" Width="110px"/>
             </td>
            </tr>
        </table> 
    </asp:Panel>  
</div>

    <br />
	<table border="0" cellpadding="0" cellspacing="0" style="width: 980px">
        <tr>
        <td align="left" style="width: 840px; text-align: left" >
            <asp:Label ID="lblProblem" runat="server" Text="" ForeColor="red" Visible="False"></asp:Label>
        </td>
        <td align="right"style="width: 120px">
            <asp:Button ID="btnClose" CssClass="button2" runat="server" Text="Close" OnCLientClick="javascript:return CloseButtonClick()" Width="110px" UseSubmitBehavior ="true"/>
        </td>
        <td align="right" style="width: 120px">
            <asp:Button ID="btnSaveClose" CssClass="button2" runat="server" Text="Save" OnCLientClick="javascript:return SaveButtonClick()" Width="110px" UseSubmitBehavior ="true"/> 
        </td>
        </tr>
     </table> 

    </ContentTemplate>
    </asp:UpdatePanel>


    </div>

    <br />
     &nbsp;
    <div id="sessionExpiredDiv" runat="server">
      <div style="width: 100%; text-align: center; padding-top: 25px;">
          Your session has expired.  Please log into the SPEDY Admin tool and relaunch the application.<br />
          <br />
          <input type="button" onclick="closeWin();" value="Close Window" id="Button1"  />
      </div>
	</div>    
	 </form>
</body>
<script language="javascript" type="text/javascript">

    //Initialize a Handle to the .Net AJAX Postback
    // Begin Comment for AJAX disable
    //-----------------------------------------------------------------------------------

    Sys.Application.add_init(appl_init);

    //-----------------------------------------------------------------------------------
    // End comment for AJAX Disable

</script>
</html>