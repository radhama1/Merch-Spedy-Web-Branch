<%
'==============================================================================
' CLASS: cls_Security_Privileges
' Generated using CodeSmith on Friday, October 14, 2005
' By ken.wallace
'==============================================================================
Class cls_Security_Privileges
	'Private, class member variable
	Private utils

	Private Sub Class_Initialize()
		Set utils = New cls_Security_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set utils = Nothing
	End Sub

	' Returns a list of ALL privileges, or optionally, returns a list 
	' of all privileges within a given context in a variety of formats
	Public Function All(p_ContextScope, p_outputType)
		Dim SQLStr, rs, arrayout, xmlout

		Const OUTPUT_ARRAY = 0			' Returns an array of object id's
		Const OUTPUT_CONSTANTARRAY = 3	' Returns an array of object constant's
		Const OUTPUT_DICTIONARY = 4		' returns a dictionary, whose keys are the 
										'   object id's and values are object references
		Const OUTPUT_RECORDSET = 1		' Returns a recordset
		Const OUTPUT_XML = 2			' returns an xml document
		
		Select Case LCase(p_outputType)
			Case OUTPUT_ARRAY, OUTPUT_CONSTANTARRAY, OUTPUT_RECORDSET, OUTPUT_XML, OUTPUT_DICTIONARY
				p_outputType = p_outputType
			Case "output_array"
				p_outputType = OUTPUT_ARRAY
			Case "output_constantarray"
				p_outputType = OUTPUT_CONSTANTARRAY
			Case "output_recordset"
				p_outputType = OUTPUT_RECORDSET
			Case "output_xml"
				p_outputType = OUTPUT_XML
			Case "output_dictionary"
				p_outputType = OUTPUT_DICTIONARY
		End Select
		
		if p_outputType = OUTPUT_XML then		
			Set xmlout = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
			xmlout.async = False
			xmlout.validateOnParse = False
			xmlout.preserveWhitespace = True
			xmlout.resolveExternals = False
			xmlout.loadXML("<?xml version='1.0'?><Root></Root>")
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return_xml '" & p_ContextScope & "'"
			xmlout.selectSingleNode("//Root").appendChild utils.loadXMLFromRS(SQLStr, "Security_Privileges").selectSingleNode("//Security_Privileges")
			Set All = xmlout
			Set xmlout = Nothing
		elseif p_outputType = OUTPUT_RECORDSET then
			SQLStr = "sp_security_list_privileges_by_scopeConstant '" & p_ContextScope & "'"
			Set All = utils.LoadRSFromDB(SQLStr)
		elseif p_outputType = OUTPUT_CONSTANTARRAY then
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return_constantarray '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				arrayout = rs("Output_Array")
			end if
			All = arrayout
			Set rs = Nothing
		elseif p_outputType = OUTPUT_DICTIONARY then
			Dim tmpDictionaryOut
			Set tmpDictionaryOut = Server.CreateObject("Scripting.Dictionary")
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				Do Until rs.EOF
					Set tmpObject = New cls_Security_Privilege
					tmpObject.Load(rs("ID"))
					tmpDictionaryOut.Add rs("ID"), tmpObject
					Set tmpObject = Nothing
					rs.MoveNext
				Loop
			end if
			All = tmpDictionaryOut
			Set rs = Nothing
			Set tmpDictionaryOut = Nothing
		else ' output the array
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return_array '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				arrayout = rs("Output_Array")
			end if
			All = arrayout
			Set rs = Nothing
		end if
	End Function

End Class
%>