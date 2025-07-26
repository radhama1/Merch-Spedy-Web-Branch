<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
if 1 = 1 then
	Response.Write "<!--" & vbCrLf
	Dim item
	for each item in Request.ServerVariables
		Response.Write item & " = " & Request.ServerVariables(item) & "<br>" & vbCrLf
	next
	
	Response.Write "-->" & vbCrLf
end if
%>
