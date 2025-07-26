<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

function returnRandomFile(myFilePath)
	Dim objFS
	Dim objArFiles
	Dim thisFile, count
	Dim randomNum, randomInteger, randomChar
	Dim chosenFileName

	Set objFS = Server.CreateObject("Scripting.FileSystemObject")
	Set objArFiles = objFS.GetFolder(Server.MapPath(myFilePath)).Files
	Session.Value("randomInteger") = 0

	if objArFiles.Count > 1 then
		Randomize
		randomNum = Rnd
		randomInteger = CInt((objArFiles.Count - 1) * randomNum)
	
		count = 0
		for each thisFile in objArFiles
			if count = randomInteger then
				chosenFileName = myFilePath & thisFile.Name
				exit for
			else
				count = count + 1
			end if			
		next
	else
		count = 0
		for each thisFile in objArFiles
			chosenFileName = myFilePath & thisFile.Name
			exit for
		next
	end if

	Set thisFile = Nothing
	Set objArFiles = Nothing
	Set objFS = Nothing
	
	if chosenFileName = Session.Value("Random_Image" & Server.URLEncode(myFilePath)) then
		chosenFileName = returnRandomFile(myFilePath)
	else
		Session.Value("Random_Image" & Server.URLEncode(myFilePath)) = chosenFileName
	end if
	
	returnRandomFile = chosenFileName
end function
%>
