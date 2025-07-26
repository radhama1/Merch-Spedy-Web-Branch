<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

function checkQueryID(strIDNum, defaultIDNum)
	Dim localIDNum
	if IsNumeric(strIDNum) then
		localIDNum = CLng(strIDNum)
	else
		if IsNumeric(defaultIDNum) then
			localIDNum = CLng(defaultIDNum)
		else
			localIDNum = CLng(0)
		end if
	end if
	checkQueryID = localIDNum
end function
%>