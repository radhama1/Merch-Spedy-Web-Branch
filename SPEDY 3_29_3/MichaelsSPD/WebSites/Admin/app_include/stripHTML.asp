<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

Function stripHTML(strtext)
	'Ensure that strtext contains something
	If len(strtext) = 0 then
		stripHTML = strtext
		Exit Function
	End If
	
	'Look for common tags...
	strtext = Replace(strtext, "<li>", "- ")
	strtext = Replace(strtext, "<LI>", "- ")
	strtext = Replace(strtext, "<li type=square>", "- ")
	strtext = Replace(strtext, "<LI TYPE=SQUARE>", "- ")
	strtext = Replace(strtext, "<li type=circle>", "- ")
	strtext = Replace(strtext, "<LI TYPE=CIRCLE>", "- ")
	strtext = Replace(strtext, "<li type=disc>", "- ")
	strtext = Replace(strtext, "<LI TYPE=DISC>", "- ")
	strtext = Replace(strtext, "<br>", " ")
	strtext = Replace(strtext, "<BR>", " ")
	strtext = Replace(strtext, "<Br>", " ")
	
	Dim arysplit, i, j, strTmpOutput, strOutput
	
	'Check for HTML tags
	arysplit = Split(strtext, "<")
	if len(arysplit(0)) > 0 then j = 1 else j = 0
	for i = j to UBound(arysplit)
		if InStr(arysplit(i), ">") then
			arysplit(i) = Mid(arysplit(i), InStr(arysplit(i), ">") + 1)
		else
			arysplit(i) = "<" & arysplit(i)
		end if
	next
	strTmpOutput = Join(arysplit, "")
	strTmpOutput = Mid(strTmpOutput, 2 - j)
	stripHTML = strTmpOutput

	strTmpOutput = replace(strTmpOutput,"&nbsp;"," ")
	strTmpOutput = replace(strTmpOutput,">","&gt;")
	strTmpOutput = replace(strTmpOutput,"<","&lt;")

	'Check for HTML Entity Codes (&nbsp;, &apos;, etc)
	arysplit = Split(strTmpOutput, "&")
	if UBound(arysplit) > 0 then
		if len(arysplit(0)) > 0 then j = 1 else j = 0
		for i = j to UBound(arysplit)
			if InStr(arysplit(i), ";") then
				arysplit(i) = Mid(arysplit(i), InStr(arysplit(i), ";") + 1)
			else
				arysplit(i) = "&" & arysplit(i)
			end if
		next
		strOutput = Join(arysplit, "")
		strOutput = Mid(strOutput, 2 - j)
	else
		strOutput = strTmpOutput
	end if

	stripHTML = strOutput
End Function
%>