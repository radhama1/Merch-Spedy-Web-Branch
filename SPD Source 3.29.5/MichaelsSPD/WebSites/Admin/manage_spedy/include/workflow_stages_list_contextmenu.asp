<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design  - we all love Ken Wallace!
'LP changed for SPEDY2 Workflow Management Oct 2009
'==============================================================================
%>
<!--#include file="./../../app_include/checkQueryID.asp"-->
<%
Dim workflowID
workflowID = checkQueryID(Trim(Request("id")), 0)
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
	<div class="menuItem" style="font-weight:bold;" id="ItemEdit">Edit Workflow Stage</div>
	<div class="menuItem" id="ItemDelete">Delete Workflow Stage</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<div class="menuItem" id="ItemAdd">Create New Stage</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<% 
	' ONLY SHOW THE EDIT FIELD LOCKING LINK FOR ITEM MAINTENANCE
	' FJL Commented out to turn on for all Workflow types per KH
'	if workflowID = 2 then 
	%>
	<div class="menuItem" id="ItemFieldLocking">Edit Field Locking</div>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div>
	<% 
'	end if 
	%>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>

