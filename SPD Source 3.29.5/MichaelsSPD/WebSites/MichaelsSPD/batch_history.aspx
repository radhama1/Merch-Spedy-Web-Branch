<%@ Page Language="VB" AutoEventWireup="false" CodeFile="batch_history.aspx.vb" Inherits="batch_history" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<title>Batch Item History</title>
	<link rel="stylesheet" href="css/styles.css" type="text/css"/>
</head>
<body>
    <form id="form1" runat="server">
        <div id="sitediv">
		    <div id="bodydiv">
		        <%if request("modal") <> "1" then %>
			        <div id="header">
				        <uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			        </div>
			    <% end if %>
			    <div id="content">
				    <div id="shadowtop"></div>
				    <div id="main">
					    <div class="spacer"></div>
                        <asp:HiddenField id="hdnBatchType" runat="server" />
                        <asp:HiddenField id="hdnBatchID" runat="server" />
                        <asp:HiddenField id="hdnAction" runat="server" />
					    <br />
					    <table width="98%" >
    					    <tr>
    					        <td rowspan=2 width="2%">
    					            <img src="images/spacer.gif" alt="spacer" width="10" height="1"/></td>
    					        <td width="98%"><b>History For Batch:&nbsp;<%= request("hid")%></b></td>
    				        </tr>
    				    </table>
    				    <br />
			            <table cellspacing="0" cellpadding="2" border="0" width="94%" align="center">
		                    <tr bgcolor="000000">
		                        <td><b><font color="ffffff">Log ID</font></b></td>
		                        <td><b><font color="ffffff">Stage</font></b></td>
		                        <td><font color="ffffff"><b>Action</b></font></td>
		                        <td><font color="ffffff"><b>User Name</b></font></td>
		                        <td><font color="ffffff"><b>Date</b></font></td>
		                        <td><font color="ffffff"><b>Notes</b></font></td>
		                    </tr>
                            <asp:Repeater ID="rptBatchHistory" runat="server" >
                                <ItemTemplate>
                                    <tr>
		                                <td><b><%# Eval("spd_batch_id")%></b></td>
		                                <td><b><%# Eval("stage_name")%></b></td>
		                                <td><b><%# Eval("action")%></b></td>
		                                <td><b><%# Eval("modified_user_name")%></b></td>
		                                <td><b><%# Eval("date_modified")%></b></td>
		                                <td><b><%# Eval("notes")%></b></td>
		                            </tr>
                                </ItemTemplate>
                            </asp:Repeater>
		                    <tr bgcolor="000000">
		                        <td colspan="6">&nbsp;</td>
		                    </tr>
		                </table>
		                <br/><br/>
        		        <%if request("modal")="1" then %>
        		            <table border="0" align="center">
        		                <tr>
        		                    <td>
        		                        <input type="button" id="close" value="Close" onclick="javascript: window.close();" />
        		                    </td>
        		                </tr>
        		            </table>
        		        <%end if %>
				    </div>
			    </div>
		    </div>
	    </div>
    </form>
</body>
</html>
