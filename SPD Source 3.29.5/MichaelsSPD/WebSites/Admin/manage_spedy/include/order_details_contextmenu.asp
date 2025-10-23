<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
%>
<div id="contextMenu" onclick="clickMenu()" onmouseover="switchMenu()" onmouseout="switchMenu()" 
style="position:absolute; 
display: none; 
width:130px; 
background-color: #ececec; 
border: 1px solid #333333; 
cursor: default; 
overflow: hidden;
filter:progid:DXImageTransform.Microsoft.Shadow(color='#999999', Direction=120, Strength=3)">
	<div class="menuItem" style="font-weight:bold;" id="ItemEdit">View Order…</div>
	<div class="menuItemDisabled" id="ItemDetails">Show Order Items</div>
	<div class="menuItem" id="ItemStatus">Modify Status…</div>
<%if 1 = 2 then%>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItemDisabled" id="ContactFind">Customer Contact…</div>
	<div class="menuItemDisabled" id="ContactFind">Email Customer…</div>
<%end if%>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemDelete">Delete Order</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>

