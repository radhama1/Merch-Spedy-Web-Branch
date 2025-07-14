<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POBatchHistory.aspx.vb" Inherits="POBatchHistory" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head2" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <META HTTP-EQUIV="expires" CONTENT="Wed, 19 Feb 2003 08:00:00 GMT">
    <title>PO Batch History</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
    <link rel="stylesheet" href="css/styles.css" type="text/css"/>
    
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
	<script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
	<script language="javascript" type="text/javascript" src="novagrid/novagrid.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script type="text/javascript">
	<!--
        function ShowCreation(show) {
            if(show)
            {
                $("CreationDiv").style.display='block'
                $("HideCreationLink").style.display = 'block'
                $("ShowCreationLink").style.display = 'none'
            }
            else 
            {
                $("CreationDiv").style.display = 'none'
                $("HideCreationLink").style.display = 'none'
                $("ShowCreationLink").style.display = 'block'
            }
        }
	//-->
	</script>
</head>
<body>
    <div style="width:100%; margin-left:auto; margin-right:auto; overflow-x:hidden;">
        <form id="formHome" runat="server">
            <div id="content" style="background-color:#dedede">
		            <div id="shadowtop"></div>
		            
                    <asp:HiddenField ID="POID" runat="server" />
		            <asp:HiddenField ID="POType" runat="server" />
                    <asp:HiddenField ID="Action" runat="server" />
                    
                    <br/>
    			    <div id="MaintenanceDiv" runat="server" style="width:98%">
    			        <table>
    					    <tr>
    					        <td rowspan=2 width="2%">
    					            <img src="images/spacer.gif" width="10" height="1" />
    					        </td>
    					        <td style="width:98%; font-weight:bold;">History For PO Number: <asp:Label ID="lblMaintenanceNumber" runat="server" /></td>
    				        </tr>
                        </table>
                        <br />
    			        <asp:GridView ID="gvPOMaintenanceHistory" runat="server" HorizontalAlign="Center" Width="94%" AutoGenerateColumns="false" BorderStyle="None" BorderWidth="0px" CellPadding="2" ForeColor="Black" GridLines="None"  >
                            <HeaderStyle />
                            <RowStyle HorizontalAlign="Center" />
    				        <Columns>
    				            <asp:BoundField DataField="ID" HeaderText="Log ID" ItemStyle-Width="10%" />
    				            <asp:BoundField DataField="Stage_Name" HeaderText="Stage" ItemStyle-Width="20%" />
    				            <asp:BoundField DataField="Action" HeaderText="Action" ItemStyle-Width="10%" />
    				            <asp:BoundField DataField="UserName" HeaderText="User Name" ItemStyle-Width="15%" />
    				            <asp:BoundField DataField="Date_Modified" HeaderText="Date" ItemStyle-Width="15%" />
    				            <asp:BoundField DataField="Notes" HeaderText="Notes" ItemStyle-Width="30%" />
    				            <asp:BoundField DataField="PO_ID" Visible="false" />
    				        </Columns>
    				    </asp:GridView>
    				    
    				    <div class="spacer" />
    				    
    				    <table style="width:99%">
    			            <tr>
    			                <td rowspan=1 width="1%">
    					                <img src="images/spacer.gif" width="10" height="1" />
    					        </td>
    			                <td>
    			                    <a id="ShowCreationLink" href="#" style="display:none" onclick="javascript:ShowCreation(true)">Show PO Creation History</a>
    			                    <a id="HideCreationLink" href="#" style="display:inline" onclick="javascript:ShowCreation(false)">Hide PO Creation History</a>
    			                </td>
    			            </tr>
    			        </table>
    				</div>
    			    <div id="CreationDiv" runat="server" style="width:98%">
    			        <table>
    					    <tr>
    					        <td rowspan=2 width="2%">
    					            <img src="images/spacer.gif" width="10" height="1" />
    					        </td>
    					        <td style="width:98%; font-weight:bold;">History For PO Batch Number: <asp:Label ID="lblCreationNumber" runat="server" /></td>
    				        </tr>
                        </table>
                        <br />
                        <asp:GridView ID="gvPOCreationHistory" runat="server" HorizontalAlign="Center" Width="94%" AutoGenerateColumns="false"  BorderStyle="None" BorderWidth="0px"  CellPadding="2" ForeColor="Black" GridLines="None"  >
    				        <HeaderStyle />
    				        <RowStyle HorizontalAlign="Center" />
    				        <Columns>
    				            <asp:BoundField DataField="ID" HeaderText="Log ID" ItemStyle-Width="10%" />
    				            <asp:BoundField DataField="Stage_Name" HeaderText="Stage" ItemStyle-Width="20%" />
    				            <asp:BoundField DataField="Action" HeaderText="Action" ItemStyle-Width="10%" />
    				            <asp:BoundField DataField="UserName" HeaderText="User Name" ItemStyle-Width="15%" />
    				            <asp:BoundField DataField="Date_Modified" HeaderText="Date" ItemStyle-Width="15%" />
    				            <asp:BoundField DataField="Notes" HeaderText="Notes" ItemStyle-Width="30%" />
    				            <asp:BoundField DataField="PO_ID" Visible="false" />
    				        </Columns>
    				    </asp:GridView>
    			    </div>
		            <br />
                    <table border="0" align="center">
                            <tr>
                                <td>
        		                    <input type="button" id="close" value="Close" onclick="javascript:window.close();" />
        		                </td>
        		            </tr>
        		        </table>
            </div>	
        </form>
	</div>
</body>
</html>
