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
	<div class="menuItem" style="font-weight:bold;" id="CatEdit">Edit Category</div>
	<div class="menuItem" id="CatMove">Move Category</div>
	<div class="menuItem" id="CatDelete">Delete Category</div>
	<div class="menuSeparator" id="CatAdd_Separator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="CatAdd">Add Child Category</div>
	<div class="menuItem" id="ItemAdd">Add Child Document</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>

<div id="contextMenuLite" onclick="clickMenu()" onmouseover="switchMenu()" onmouseout="switchMenu()" 
style="position:absolute; 
display: none; 
width:130; 
background-color: #ececec; 
border: 1px solid #333333; 
cursor: default; 
filter:progid:DXImageTransform.Microsoft.Shadow(color='#999999', Direction=120, Strength=3)">
	<div class="menuItem" id="CatAddTop">Add New Category...</div>
	<div class="menuItem" id="ItemAddTop">Add New Document...</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>
