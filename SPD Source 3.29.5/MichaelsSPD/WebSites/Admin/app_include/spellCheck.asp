<%
function spellCheck(strIn, boolDebug)
	Dim tmpStr, strOut, objSpellChecker
	Dim badWord, badWordIndex, strSuggestions, arSuggestions
	Dim arWords, wnum
	Dim arSuggestionsPerWord() 'arSuggestionsPerWord( <word_number>, <suggestion_number> )
	Dim arPossibleSpellings()
	Dim x, y

	boolDebug = CBool(boolDebug)
	
	'Test the input string for validity
	On Error Resume Next
	tmpStr = Trim(CStr(strIn))
	On Error GoTo 0
	If Err.number > 0 then exit function	'wasn't a string
	if Len(tmpStr) <= 0 then exit function	'was an empty string
	
	'Get rid of extra spaces between words
	tmpStr = Replace(tmpStr, chr(32) & chr(32), chr(32))
		
	Set objSpellChecker = Server.CreateObject("ChadoSpellServer.SessionlessEngine")

	objSpellChecker.LicenseKey = "D4F5-8808-E295-F0D8" 'Application.Value("CHADOSPELLSERVER_LICENSEKEY")
	objSpellChecker.StartCheckingAt = 0	
	objSpellChecker.CustomDictionary = ""
	objSpellChecker.IgnoreAllDictionary = ""
	objSpellChecker.IgnoreAllCaps = true
	objSpellChecker.IgnoreCase = true
	objSpellChecker.IgnoreInternetAddrs = true
	objSpellChecker.IgnoreWithNumbers = true
	objSpellChecker.IgnoreHTML = true
	objSpellChecker.RemoveWordsFromDictionary "damn fuck piss shit"

	objSpellChecker.StringToCheck = CleanString(tmpStr, false)

	badWord = objSpellChecker.GetNextMisspelling(strSuggestions, badWordIndex)

	strOut = strSuggestions
	if boolDebug then
		Response.Write "<br>" & vbCrLf
		Response.Write "input string: " & strIn & "<br>" & vbCrLf
		Response.Write "final string: " & strOut & "<br>" & vbCrLf
	end if

	spellCheck = strOut
end function

function spellCheck_returnBestGuess(strIn, boolDebug)
	Dim tmpStr, strOut, objSpellChecker
	Dim badWord, badWordIndex, strSuggestions, arSuggestions
	Dim arWords, wnum
	Dim boolFinished
	Dim arSuggestionsPerWord() 'arSuggestionsPerWord( <word_number>, <suggestion_number> )
	Dim arPossibleSpellings()
	Dim x, y

	boolDebug = CBool(boolDebug)
	boolFinished = false
	
	'Test the input string for validity
	On Error Resume Next
	tmpStr = Trim(CStr(strIn))
	On Error GoTo 0
	If Err.number > 0 then exit function	'wasn't a string
	if Len(tmpStr) <= 0 then exit function	'was an empty string
	
	'Get rid of extra spaces between words
	tmpStr = Replace(tmpStr, chr(32) & chr(32), chr(32))
		
	Set objSpellChecker = Server.CreateObject("ChadoSpellServer.SessionlessEngine")

	objSpellChecker.LicenseKey = "D4F5-8808-E295-F0D8" 'Application.Value("CHADOSPELLSERVER_LICENSEKEY")
	objSpellChecker.StartCheckingAt = 0	
	objSpellChecker.CustomDictionary = ""
	objSpellChecker.IgnoreAllDictionary = ""
	objSpellChecker.IgnoreAllCaps = true
	objSpellChecker.IgnoreCase = true
	objSpellChecker.IgnoreInternetAddrs = true
	objSpellChecker.IgnoreWithNumbers = true
	objSpellChecker.IgnoreHTML = true
	objSpellChecker.RemoveWordsFromDictionary "damn fuck piss shit"

	objSpellChecker.StringToCheck = CleanString(tmpStr, false)

	do until boolFinished
		badWord = objSpellChecker.GetNextMisspelling(strSuggestions, badWordIndex)
		if Trim(badWord) <> "" then
			if boolDebug then Response.Write "<br>" & vbCrLf
			if boolDebug then Response.Write "badWord: " & badWord & "<br>" & vbCrLf
			arSuggestions = Split(strSuggestions, chr(13))
			if UBound(arSuggestions) > 0 then
				objSpellChecker.ChangeWord badWord, arSuggestions(0), true
				if boolDebug then	
					Response.Write "best suggestion (ar): " & arSuggestions(0) & "<br>" & vbCrLf
					for i = 0 to UBound(arSuggestions)
						Response.Write i & ": " & arSuggestions(i) & "<br>" & vbCrLf
					next
				end if
			elseif Len(Trim(strSuggestions)) > 0 then
				objSpellChecker.ChangeWord badWord, strSuggestions, true
				if boolDebug then Response.Write "best suggestion (str): " & strSuggestions & "<br>" & vbCrLf
			else
				objSpellChecker.IgnoreWord badWord, true
			end if
		else
			boolFinished = true
		end if
	loop

	strOut = objSpellChecker.StringToCheck

	if boolDebug then
		Response.Write "<br>" & vbCrLf
		Response.Write "input string: " & strIn & "<br>" & vbCrLf
		Response.Write "final string: " & strOut & "<br>" & vbCrLf
	end if

	if strOut <> tmpStr then
		spellCheck_returnBestGuess = strOut
	else
		spellCheck_returnBestGuess = ""
	end if
end function

function spellCheck_returnAll(strIn, boolDebug)
	Dim tmpStr, strOut, objSpellChecker
	Dim badWord, badWordIndex, strSuggestions, arSuggestions
	Dim arWords, wnum
	Dim boolFinished
	Dim arSuggestionsPerWord() 'arSuggestionsPerWord( <word_number>, <suggestion_number> )
	Dim arPossibleSpellings(), strPossibleSpellings
	Dim x, y, max_i

	boolDebug = CBool(boolDebug)
	boolFinished = false
	
	'Test the input string for validity
	On Error Resume Next
	tmpStr = Trim(CStr(strIn))
	On Error GoTo 0
	If Err.number > 0 then exit function	'wasn't a string
	if Len(tmpStr) <= 0 then exit function	'was an empty string
	
	'Get rid of extra spaces between words
	tmpStr = Replace(tmpStr, chr(32) & chr(32), chr(32))
		
	Set objSpellChecker = Server.CreateObject("ChadoSpellServer.SessionlessEngine")

	objSpellChecker.LicenseKey = "D4F5-8808-E295-F0D8" 'Application.Value("CHADOSPELLSERVER_LICENSEKEY")
	objSpellChecker.StartCheckingAt = 0	
	objSpellChecker.CustomDictionary = ""
	objSpellChecker.IgnoreAllDictionary = ""
	objSpellChecker.IgnoreAllCaps = true
	objSpellChecker.IgnoreCase = true
	objSpellChecker.IgnoreInternetAddrs = true
	objSpellChecker.IgnoreWithNumbers = true
	objSpellChecker.IgnoreHTML = true
	objSpellChecker.RemoveWordsFromDictionary "damn fuck piss shit"

	arWords = Split(tmpStr, chr(32))
	ReDim Preserve arPossibleSpellings(1, 10)
	if UBound(arWords) > 0 then
		ReDim arPossibleSpellings(UBound(arWords), 10)
	end if
	max_i = 0
	for wnum = 0 to UBound(arWords)
		'if wnum >= 10 then exit for
		objSpellChecker.StringToCheck = CleanString(arWords(wnum), false)

		badWord = objSpellChecker.GetNextMisspelling(strSuggestions, badWordIndex)
		if Trim(badWord) <> "" then
			arSuggestions = Split(strSuggestions, chr(13))

			if boolDebug then Response.Write "<br>" & vbCrLf
			if boolDebug then Response.Write "badWord: " & badWord & "<br>" & vbCrLf

			arPossibleSpellings(wnum, 0) = arWords(wnum)
			if UBound(arSuggestions) > 0 then
				for i = 0 to UBound(arSuggestions)
					if i >= 10 then exit for
					arPossibleSpellings(wnum, i + 1) = arSuggestions(i)
					if boolDebug then Response.Write "arPossibleSpellings(" & wnum & ", " & i + 1 & "): " & arSuggestions(i) & "<br>" & vbCrLf
				next
				if i > max_i then max_i = i
			elseif Len(Trim(strSuggestions)) > 0 then
				arPossibleSpellings(wnum, 1) = strSuggestions
				if boolDebug then Response.Write "arPossibleSpellings(" & wnum & ", 1): " & strSuggestions & "<br>" & vbCrLf
				if 1 > max_i then max_i = 1
			end if

		end if
	next
	ReDim Preserve arPossibleSpellings(UBound(arPossibleSpellings, 1), max_i)

	if boolDebug then Response.Write "UBound(arPossibleSpellings, 1): " & UBound(arPossibleSpellings, 1) & "<br>" & vbCrLf
	if boolDebug then Response.Write "UBound(arPossibleSpellings, 2): " & UBound(arPossibleSpellings, 2) & "<br>" & vbCrLf
	
	spellCheck_returnAll = arPossibleSpellings
end function

function CleanString (sOriginal, bDirection)
	Dim sTemp
	sTemp = sOriginal

	if bDirection then 
		sTemp = Replace(sTemp, chr(34), "%22")
		sTemp = Replace(sTemp, chr(13), "%0D")
		sTemp = Replace(sTemp, chr(10), "%0A")
	else
		sTemp = Replace(sTemp, "%22", chr(34))
		sTemp = Replace(sTemp, "%0D", chr(13))
		sTemp = Replace(sTemp, "%0A", chr(10))
	end if 
		
	CleanString = sTemp	
end function
%>