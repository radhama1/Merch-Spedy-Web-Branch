<%@ Control Language="VB" AutoEventWireup="false" CodeFile="pageheader.ascx.vb" Inherits="pageheader" %>
                <div class="spacer"></div>
                <table width="100%" cellpadding="0" style="height: 90px; width: 100%;">
                    <tr>
                        <td width="215px" align="left" style="white-space:nowrap; padding-left: 15px; padding-right: 10px; padding-top: 3px;">
							<div class="header-logo">
								<a href="default.aspx"><img src="images/logo-big.png" border="0" alt="Home" width="187" height="73" /></a>
							</div>
                        </td>
                        <td>
                            <div style="height:34px; overflow-x:hidden; overflow-y:auto; text-align:center; margin-left:5px; margin-right:5px;">
            				    <asp:Label runat="server" ID="lblSPDAppMessage" ></asp:Label>
                            </div>
                        </td>
                        <td width="15%" align="right" style="white-space:nowrap; text-align: right; padding-right: 15px;">
        					<img src="images/spedy-logo.png" width="135" height="40" border="0" alt="" title="<%=VersionNo %>" />
                        </td>
                    </tr>
                </table>
<%--				<div id="logo">
				    <a href="default.aspx"><img src="images/logo.png" width="125" height="41" border="0" alt="Home" /></a>
				</div>
				<div id="msgCenter" >
				    <table border="0" width="75%">
				        <tr>
				            <td align="center" >
            				    <asp:Label runat="server" ID="lblSPDAppMessage" ></asp:Label>
				            </td>
				        </tr>
				    </table>
				</div>
				<div id="search" >
					<img src="images/spedy_logo.gif" width="121" height="34" border="0" alt="" title="<%=VersionNo %>" />
				</div>
--%>				<div class="spacer"></div>
				<div id="navigation">
					<span style="padding: 3px 10px 0px 0px; float: right; display: inline; color: #fff; height: 40px;">
					    <asp:Label id = "LabelW" runat ="server" Font-Bold= "True" Font-Names="verdana" Font-Size="Larger" > </asp:Label>
                        &nbsp;&nbsp;
					</span>
					<ul style="height: 40px; margin-left: 20px;">
						<li class="first"><a href="default.aspx" title="Home">Home</a></li>
						<li><a href="reportlist.aspx" title="Report">Report</a></li>
						<li><a href="content.aspx?tid=1" title="Help">Help</a></li>
                        <li id="imageDownloadLinkListItem" runat="server"><a id="imageDownloadLink" runat="server" href="~/imagedownloader.aspx" title="Item Images">Item Images</a></li>
					    <li><a href="login.aspx" title="Logout">Logout</a></li>
					</ul>
				</div>