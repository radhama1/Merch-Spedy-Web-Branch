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
	<div class="menuItem" style="font-weight:bold;" id="ItemView">View Document</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemSettings">Settings…</div>
	<div class="menuItem" id="ItemStatus">Modify Status…</div>
	<div class="menuItem" id="ItemSwap">Update/Swap…</div>
	<div class="menuItem" id="ItemApproval" style="display: none;">Request Approval…</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemDemote">Demote from Live</div>
	<div class="menuItem" id="ItemTreeDemote">Demote Tree from Live</div>
	<div class="menuItem" id="ItemPromote">Promote to Live</div>
	<div class="menuItem" id="ItemPromoteWFirstSubLevel">Promote Sublevel to Live</div>
	<div class="menuItem" id="ItemTreePromote">Promote Tree to Live</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemMove">Move Document…</div>
	<div class="menuItem" id="ItemSortAlpha">Sort Children by Name</div>
	<div class="menuItem" id="ItemSort">Sort Child Documents…</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemDelete">Remove Document</div>
	<div class="menuItem" id="TreeDelete">Remove Document Tree</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemAdd">Add Child Document…</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>

