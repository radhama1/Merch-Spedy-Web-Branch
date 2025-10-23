<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

function trimSummary(strTxtIn, strDefaultValue, intMaxLength)
	Dim strTxtOut, summaryMaxChars

	if not IsNumeric(intMaxLength) or Len(Trim(intMaxLength)) = 0 then
		intMaxLength = 200
	end if

	summaryMaxChars = intMaxLength
	strTxtOut = ""
	
	if not IsNull(strDefaultValue) then
		if Len(Trim(strDefaultValue)) > 0 then
			strTxtOut = CStr(strDefaultValue)
		end if
	end if

	if not IsNull(strTxtIn) then
		if Len(Trim(strTxtIn)) > 0 then
			strTxtOut = CStr(strTxtIn)
			strTxtOut = stripHTML(strTxtOut)
			if Len(strTxtOut) <= summaryMaxChars then
				strTxtOut = strTxtOut
			else
				strTxtOut = Left(strTxtOut, summaryMaxChars)
				strTxtOut = Mid(strTxtOut, 1, InStrRev(strTxtOut, " "))
				strTxtOut = strTxtOut & "&#133;"
			end if
		end if
	end if
	
	trimSummary = strTxtOut
end function
%>