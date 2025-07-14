<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
%>
<div id="contextMenu" onclick="clickMenu()" onmouseover="switchMenu()" onmouseout="switchMenu()" 
style="position:absolute; 
display: none; 
width:150px; 
background-color: #ececec; 
border: 1px solid #333333; 
cursor: default; 
overflow: hidden;
filter:progid:DXImageTransform.Microsoft.Shadow(color='#999999', Direction=120, Strength=3)">
	<div class="menuItem" style="font-weight:bold;" id="ItemEdit">Edit Rule</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemMoveUp">Move Up</div>
	<div class="menuItem" id="ItemMoveDown">Move Down</div>
	<div class="menuItem" id="ItemDelete">Delete Rule</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemAdd">Add New Rule</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>

