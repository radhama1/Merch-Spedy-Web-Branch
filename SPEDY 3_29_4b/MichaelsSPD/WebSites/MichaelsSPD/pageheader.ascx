<%@ Control Language="VB" AutoEventWireup="false" CodeFile="pageheader.ascx.vb" Inherits="pageheader" ClassName="pageheader" %>
    <div class="spacer"></div>
        <table width="100%" cellpadding="3px" >
            <tr>
                <td width="15%" align="left" style="white-space:nowrap">
                    <a href="default.aspx"><img src="images/logo.png" border="0" alt="Home" /></a>
                </td>
                <td width="70%">
                    <div style="height:34px; overflow-x:hidden; overflow-y:auto; text-align:center; margin-left:5px; margin-right:5px;">
                        <asp:Label runat="server" ID="lblSPDAppMessage" ></asp:Label>
                    </div>
                </td>
                <td width="15%" align="right" style="white-space:nowrap; padding-right: 15px;">
        	        <img src="images/spedy-logo.png" width="135" height="40" border="0" alt="" title="<%=VersionNo %>" />
                </td>
            </tr>
        </table>
			<div class="spacer"></div>
				<div id="navigation">
					<span style="padding: 3px 10px 0px 0px; float: right; display: inline;">
					    <asp:Label id = "LabelW" runat ="server" Font-Bold= "True" Font-Names="verdana" Font-Size="Larger" > </asp:Label>
                        &nbsp;&nbsp;
					</span>
					<ul>
						<li><a href="default.aspx"><img src="images/btn_home.gif" width="80" height="22" border="0" alt="Home" /></a></li>
						<li><a href="reportlist.aspx"><img src="images/btn_report.gif" width="86" height="22" border="0" alt="Report" /></a></li>
						<li><a href="content.aspx?tid=1"><img src="images/btn_help.gif" width="73" height="22" border="0" alt="Help" /></a></li>
					    <li><a href="login.aspx"><img src="images/btn_logout.gif" width="73" height="22" border="0" alt="Logout" /></a></li>
					</ul>
				</div>