<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim boolIsNew
Dim productID

productID = Request("pid")
if IsNumeric(productID) then
	productID = CInt(productID)
else
	productID = 0
end if

boolIsNew = false
if productID = 0 then
	boolIsNew = true
end if
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
	<!--
		function preloadImgs()
		{
			if (document.images)
			{		
				descriptionTabImgOn = new Image(100, 12);
				descriptionTabImgOff = new Image(100, 12);
				scheduleTabImgOn = new Image(100, 12);
				scheduleTabImgOff = new Image(100, 12);
				priceTabImgOn = new Image(100, 12);
				priceTabImgOff = new Image(100, 12);
				taxTabImgOn = new Image(100, 12);
				taxTabImgOff = new Image(100, 12);
				inventoryTabImgOn = new Image(100, 12);
				inventoryTabImgOff = new Image(100, 12);
				shippingTabImgOn = new Image(100, 12);
				shippingTabImgOff = new Image(100, 12);

				descriptionTabImgOn.src = "../images/tab_description_on.gif";
				descriptionTabImgOff.src = "../images/tab_description_off.gif";
				scheduleTabImgOn.src = "../images/tab_schedule_on.gif";
				scheduleTabImgOff.src = "../images/tab_schedule_off.gif";
				priceTabImgOn.src = "../images/tab_price_on.gif";
				priceTabImgOff.src = "../images/tab_price_off.gif";
				taxTabImgOn.src = "../images/tab_tax_on.gif";
				taxTabImgOff.src = "../images/tab_tax_off.gif";
				inventoryTabImgOn.src = "../images/tab_inventory_on.gif";
				inventoryTabImgOff.src = "../images/tab_inventory_off.gif";
				shippingTabImgOn.src = "../images/tab_shipping_on.gif";
				shippingTabImgOff.src = "../images/tab_shipping_off.gif";
			}
		}

		function initTabs(thisTabName)
		{
			clearMenus();
			switch (thisTabName)
			{
				case "descriptionTab":
					parent.frames['body'].workspace_description.style.display = "";
					document.images['descriptionTab'].src = descriptionTabImgOn.src;
					break;
				
				case "scheduleTab":
					parent.frames['body'].workspace_schedule.style.display = "";
					document.images['scheduleTab'].src = scheduleTabImgOn.src;
					break;

				case "priceTab":
					parent.frames['body'].workspace_price.style.display = "";
					document.images['priceTab'].src = priceTabImgOn.src;
					break;

				case "taxTab":
				//	parent.frames['body'].workspace_tax.style.display = "";
					document.images['taxTab'].src = taxTabImgOn.src;
					break;

				case "inventoryTab":
				//	parent.frames['body'].workspace_inventory.style.display = "";
					document.images['inventoryTab'].src = inventoryTabImgOn.src;
					break;

				case "shippingTab":
				//	parent.frames['body'].workspace_shipping.style.display = "";
					document.images['shippingTab'].src = shippingTabImgOn.src;
					break;
			}
		}
	
		function clickMenu(tabName)
		{
			parent.frames['body'].clickMenu(tabName);
			clearMenus();

			switch (tabName)
			{
				case "descriptionTab":
					document.images['descriptionTab'].src = descriptionTabImgOn.src;
					break;
				
				case "scheduleTab":
					document.images['scheduleTab'].src = scheduleTabImgOn.src;
					break;
				
				case "priceTab":
					document.images['priceTab'].src = priceTabImgOn.src;
					break;
				
				case "taxTab":
					document.images['taxTab'].src = taxTabImgOn.src;
					break;
				
				case "inventoryTab":
					document.images['inventoryTab'].src = inventoryTabImgOn.src;
					break;
				
				case "shippingTab":
					document.images['shippingTab'].src = shippingTabImgOn.src;
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			document.images['descriptionTab'].src = descriptionTabImgOff.src;
			document.images['scheduleTab'].src = scheduleTabImgOff.src;
			document.images['priceTab'].src = priceTabImgOff.src;
		//	document.images['taxTab'].src = taxTabImgOff.src;
			document.images['inventoryTab'].src = inventoryTabImgOff.src;
			document.images['shippingTab'].src = shippingTabImgOff.src;
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="preloadImgs(); initTabs('descriptionTab')">
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr bgcolor=333333><td colspan=2><img src="../images/editscreen_label_product_<%if boolIsNew then Response.Write "new" else Response.Write "edit" end if%>.gif" height=25 width=300 border=0></td></tr>
	<tr>
		<td colspan=2>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr bgcolor=333333>
					<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					<td><a href="javascript: void(0); clickMenu('descriptionTab')"><img name="descriptionTab" id="descriptionTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product details"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('priceTab')"><img name="priceTab" id="priceTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product price details"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<!--
					<td><a href="javascript: void(0); clickMenu('taxTab')"><img name="taxTab" id="taxTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product tax details"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					-->
					<td><a href="javascript: void(0); clickMenu('inventoryTab')"><img name="inventoryTab" id="inventoryTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product inventory details"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('shippingTab')"><img name="shippingTab" id="shippingTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product shipping details"></a></td>
					<td><img src="../images/spacer.gif" height=1 width=4 border=0></td>
					<td><a href="javascript: void(0); clickMenu('scheduleTab')"><img name="scheduleTab" id="scheduleTab" src="../images/spacer.gif" height=12 width=100 border=0 alt="manage product schedule"></a></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=13 border=0></td></tr>
</table>

</body>
</html>