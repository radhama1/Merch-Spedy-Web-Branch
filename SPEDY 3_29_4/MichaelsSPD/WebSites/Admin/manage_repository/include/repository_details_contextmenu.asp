<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
%>
<div id="contextMenu" onclick="clickMenu()" onmouseover="switchMenu();" onmouseout="switchMenu()" 
style="position:absolute; 
display: none; 
width:130px; 
background-color: #ececec; 
border: 1px solid #333333; 
cursor: default; 
overflow: hidden;
filter:progid:DXImageTransform.Microsoft.Shadow(color='#999999', Direction=120, Strength=3)">
	<div class="menuItem" style="font-weight:bold;" id="ItemEdit">Edit Document</div>
	<div class="menuItem" id="ItemView">View Document</div>
	<div class="menuSeparator" id="ItemStatus_Separator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemStatus">Modify Status…</div>
	<div class="menuItem" id="ItemLock">Lock Document</div>
	<div class="menuItem" id="ItemUnlock">Unlock Document</div>
	<div class="menuItem" id="ItemOverridelock">Override Lock</div>
	<!--<div class="menuItem" id="ItemApproval">Request Approval…</div>-->
	<div class="menuSeparator" id="ItemCopy_Separator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemCopyHere">Copy Document</div>
	<div class="menuItem" id="ItemCopy">Advanced Copy…</div>
	<div class="menuItem" id="ItemMove">Move Document…</div>
	<div class="menuItem" id="ItemDelete">Delete Document</div>
	<div class="menuSeparator" id="ItemAdd_Separator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemAdd">New Document…</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>

