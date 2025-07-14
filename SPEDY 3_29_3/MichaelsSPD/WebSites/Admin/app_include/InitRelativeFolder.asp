<%
function InitRelativeFolder(strRelativeFolderPath, boolReturnAsRelativePath)
	'FUNCTION INITRELATIVEFOLDER
	'RETURNS: String
	'PARAMETERS:
	'	strRelativeFolderPath: A folder path relative to the current dir.
	'	boolReturnAsRelativePath = [ true | false ]: This boolean indicates the 
	'		desired output format of the function, which will be either the relative 
	'		or absolute folder path.  'True' Returns a relative path, 'False' 
	'		returns an absolute path.
	
	Dim thisFSO, thisFile, tmpFilePath, filePathArray, i

	strRelativeFolderPath = Replace(strRelativeFolderPath, "\", "/")	'Replace backslashes with forward slashes, because, you know, why not.
	filePathArray = Split(strRelativeFolderPath, "/")
	boolReturnAsRelativePath = CBool(boolReturnAsRelativePath)
	
	tmpFilePath = "."
	Set thisFSO = CreateObject("Scripting.FileSystemObject")
	For i = 0 to UBound(filePathArray) - 1
		tmpFilePath = tmpFilePath & "/" & filePathArray(i)
		If Not thisFSO.FolderExists(Server.MapPath(tmpFilePath)) Then
			thisFSO.CreateFolder(Server.MapPath(tmpFilePath))
		End If
	Next
	Set thisFSO = Nothing
	
	if boolReturnAsRelativePath then
		InitRelativeFolder = tmpFilePath
	else
		InitRelativeFolder = Server.MapPath(tmpFilePath)
	end if
end function

%>