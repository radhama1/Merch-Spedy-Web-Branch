<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
function padMe(strInput, reqdLength, padChar, padDir)
	'--------------------------------------------------
	'Pad a value for fixed field style-output. -KW 01/16/01
	'--------------------------------------------------
	'strInput		- the string to be padded.
	'reqdLength		- the desired length of the final string.
	'padChar		- the character with which to pad the string.
	'padDir			- which side (l or r, left or right) to throw the padding onto.
	'--------------------------------------------------
	if padChar <> "" and Trim(padDir) <> "" and IsNumeric(reqdLength) and Trim(strInput) <> "" then
		if len(strInput) > reqdLength then
			if LCase(Trim(padDir)) = "l" or LCase(Trim(padDir)) = "left" then
				strInput = Right(strInput, reqdLength)
			elseif LCase(Trim(padDir)) = "r" or LCase(Trim(padDir)) = "right" then
				strInput = Left(strInput, reqdLength)
			else
				strInput = Left(strInput, reqdLength)
			end if
		end if
		do until len(strInput) = reqdLength
			if LCase(Trim(padDir)) = "l" or LCase(Trim(padDir)) = "left" then
				strInput = padChar & strInput
			elseif LCase(Trim(padDir)) = "r" or LCase(Trim(padDir)) = "right" then
				strInput = strInput & padChar
			else
				strInput = strInput
			end if
		loop
	else
		strInput = strInput
	end if
	padMe = strInput
end function
%>