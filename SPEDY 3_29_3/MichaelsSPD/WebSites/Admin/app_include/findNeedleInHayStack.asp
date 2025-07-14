<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

function findNeedleInHayStack(myHayStack, myNeedle, myResultString)
	Dim myHay
	if IsArray(myHayStack) then
		for each myHay in myHayStack
			if IsNumeric(myNeedle) and IsNumeric(myHay) then
				if CLng(myHay) = CLng(myNeedle) then findNeedleInHayStack = myResultString
			else
				if CStr(myHay) = CStr(myNeedle) then findNeedleInHayStack = myResultString
			end if
		next
	else
		if IsNumeric(myNeedle) and IsNumeric(myHayStack) then
			if CLng(myHayStack) = CLng(myNeedle) then findNeedleInHayStack = myResultString
		else
			if CStr(myHayStack) = CStr(myNeedle) then findNeedleInHayStack = myResultString
		end if
	end if 
end function
%>