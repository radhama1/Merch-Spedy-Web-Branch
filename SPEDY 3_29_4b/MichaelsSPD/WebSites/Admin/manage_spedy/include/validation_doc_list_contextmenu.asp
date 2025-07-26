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
	<div class="menuItem" style="font-weight:bold;" id="ItemView">Validation Rules</div>
	
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height="1" width="1" alt="" /></div></div>
	<div class="menuItem" style="font-weight:bold;" id="ItemReport">Report</div>
	
<!--
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemEdit">Edit Record Type</div>
	<div class="menuItem" id="ItemDelete">Delete Record Type</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemAdd">Create New Record Type</div>
-->
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height="1" width="1" alt="" /></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>

