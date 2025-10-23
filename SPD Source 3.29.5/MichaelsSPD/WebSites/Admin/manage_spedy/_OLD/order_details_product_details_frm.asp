<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim showOptions, headingID, displayType
Dim Order_ID

displayType = Trim(Request("displaytype"))
if IsNumeric(displayType) and Trim(displayType) <> "" then
	displayType = CInt(displayType)
	Session.Value("Order_Product_DisplayStyle") = displayType
else
	if IsNumeric(Session.Value("Order_Product_DisplayStyle")) and Trim(Session.Value("Order_Product_DisplayStyle")) <> "" then
		displayType = CInt(Session.Value("Order_Product_DisplayStyle"))
	else
		displayType = 1
		Session.Value("Order_Product_DisplayStyle") = displayType
	end if
end if

showOptions = CBool(checkQueryID(Request("showoptions"), 0))
headingID = CInt(checkQueryID(Request("hid"), 0))
Order_ID = CInt(checkQueryID(Request("oid"), 0))
%>
<html>
<head>
	<title>Product Details Frameset</title>
	<style type="text/css">
	<!--
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#cccccc"; 
			scrollbar-shadow-color: "#cccccc";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#FFFFFF";
			scrollbar-darkshadow-color: "#cccccc";
		}
	//-->
	</style>
</head>

<frameset rows="25,*" border="0" framespacing=0 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no bordercolor=cccccc>
	<frame name="FooterFrame" src="order_details_product_details_footer.asp?oid=<%=Request("oid")%>&displaytype=<%=displayType%>" scrolling="no" noresize frameborder=no>
	<frameset cols="*" border="0" framespacing=0 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
		<frameset rows="1,15,*" border="0" framespacing=0 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
			<frame name="blankheaderframe" src="../app_include/blank_999999.html" scrolling="no" noresize frameborder=no>
			<frameset cols="1,*,1,18" framespacing=0 border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
				<frame name="edge_separator1" src="../app_include/blank.html" scrolling="no" noresize frameborder=no>
				<frame name="DetailFrameHdr" src="../app_include/blank.html" scrolling="no" noresize frameborder=no><!-- Detail View Header -->
				<frame name="edge_separator2" src="../app_include/blank_cccccc.html" scrolling="no" noresize frameborder=no>
				<frame name="edge_separator3" src="../app_include/blank_cccccc.html" scrolling="no" noresize frameborder=no>
			</frameset>
		<%if displayType = 1 then%>
			<frame name="DetailFrame" src="order_details_product_details_results_listview.asp?oid=<%=Request("oid")%>" scrolling="yes" frameborder=no><!-- Detail View Content -->
		<%elseif displayType = 2 then%>
			<frame name="DetailFrame" src="order_details_product_details_results_thumbview.asp?oid=<%=Request("oid")%>" scrolling="yes" frameborder=no><!-- Detail View Content -->
		<%end if%>
		</frameset>
		<!--<frame name="ThumbFrame" src="order_details_product_thumbtabs.asp" scrolling="no"  frameborder=no>-->
	</frameset>
</frameset>

</html>
