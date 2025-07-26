<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Dim topicID, thisParentCatID
Dim query_string

topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

thisParentCatID = Request("cid")
if IsNumeric(thisParentCatID) then
	thisParentCatID = CInt(thisParentCatID)
else
	thisParentCatID = 0
end if

query_string = "?tid=" & topicID & "&cid=" & thisParentCatID

%>