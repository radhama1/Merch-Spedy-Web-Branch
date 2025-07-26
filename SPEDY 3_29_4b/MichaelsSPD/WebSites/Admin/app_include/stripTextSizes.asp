<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

Function stripTextSizes(strtext)
	if 1 = 2 then
		'Ensure that strtext contains something
		If len(strtext) = 0 then
			stripTextSizes = strtext
			Exit Function
		End If
		
		Dim objRegEx, strTmpOutput


		strTmpOutput = strtext
		Set objRegEx = New RegExp

		with objRegEx
			.Pattern = "(size=\d{1})"
			.IgnoreCase = True
			.Multiline = True
			.Global = True
		end with
		strTmpOutput = objRegEx.Replace(strTmpOutput, "style=""font-size: 12px""")

		with objRegEx
			.Pattern = "font-size:\s*\d*((pt)|(px)|(%)|(em))*"
			.IgnoreCase = True
			.Multiline = True
			.Global = True
		end with
		strTmpOutput = objRegEx.Replace(strTmpOutput, "font-size: 12px")

	'	with objRegEx
	'		.Pattern = "http:\/\/207.208.244.58\:97\/www\/images"
	'		.IgnoreCase = True
	'		.Multiline = True
	'		.Global = True
	'	end with
	'	strTmpOutput = objRegEx.Replace(strTmpOutput, "./images")

		with objRegEx
			.Pattern = "http:\/\/207.208.244.58\:97\/www\/staging\/"
			.IgnoreCase = True
			.Multiline = True
			.Global = True
		end with
		strTmpOutput = objRegEx.Replace(strTmpOutput, "")

		Set objRegEx = nothing

		stripTextSizes = strTmpOutput
	else
		stripTextSizes = strtext
	end if
End Function
%>