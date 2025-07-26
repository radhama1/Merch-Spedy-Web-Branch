<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

function trimWords(strIn, maxWords, minWordLength)
	Dim arWords, wnum, numWordsCounted, endPos

	if IsNull(strIn) then exit function

	arWords = Split(Trim(strIn), " ")
	numWordsCounted = 0
	endPos = 0

	for wnum = 0 to UBound(arWords)
		if Len(Trim(arWords(wnum))) >= minWordLength then numWordsCounted = numWordsCounted + 1
		endPos = endPos + Len(arWords(wnum)) + 1
		if numWordsCounted = maxWords then exit for
	next
	
	if Len(strIn) > endPos then
		trimWords = Left(strIn, endPos-1) & "…"
	else
		trimWords = strIn
	end if
end function
%>