<%
'==============================================================================
' CLASS: cls_Security_Privileged_Object
' Generated using CodeSmith on Friday, October 14, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with 
' table DriversEdDirect_Dev.dbo.Security_Privilege_Object.  
'
' NOTE THE SPELLING DIFFERENCE BETWEEN THIS OBJECT AND THE DATABASE OBJECT
' N O T E   T H E   S P E L L I N G   D I F F E R E N C E   B E T W E E N   
' T H I S   O B J E C T   A N D   T H E   D A T A B A S E   O B J E C T 
' NOTE THE SPELLING DIFFERENCE BETWEEN THIS OBJECT AND THE DATABASE OBJECT
'
'==============================================================================
Class cls_Security_Privileged_Object
	'Private, class member variable
	Private m_ID
	Private m_Privilege_ID
	Private m_Secured_Object_ID
	Private m_User_ID
	Private m_Group_ID
	Private m_Date_Created
	Private utils

	Private Sub Class_Initialize()
		Set utils = New cls_Security_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set utils = Nothing
	End Sub

	'Read the current ID value
	Public Property Get ID()
		ID = CInt(m_ID)
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property
	'Read the current Privilege_ID value
	Public Property Get Privilege_ID()
		Privilege_ID = CInt(m_Privilege_ID)
	End Property
	'store a new Privilege_ID value
	Public Property Let Privilege_ID(p_Data)
		m_Privilege_ID = p_Data
	End Property
	'Read the current Secured_Object_ID value
	Public Property Get Secured_Object_ID()
		Secured_Object_ID = CInt(m_Secured_Object_ID)
	End Property
	'store a new Secured_Object_ID value
	Public Property Let Secured_Object_ID(p_Data)
		m_Secured_Object_ID = p_Data
	End Property
	'Read the current User_ID value
	Public Property Get User_ID()
		User_ID = CInt(m_User_ID)
	End Property
	'store a new User_ID value
	Public Property Let User_ID(p_Data)
		m_User_ID = p_Data
	End Property
	'Read the current Group_ID value
	Public Property Get Group_ID()
		Group_ID = CInt(m_Group_ID)
	End Property
	'store a new Group_ID value
	Public Property Let Group_ID(p_Data)
		m_Group_ID = p_Data
	End Property
	'Read the current Date_Created value
	Public Property Get Date_Created()
		Date_Created = CDate(m_Date_Created)
	End Property
	'store a new Date_Created value
	Public Property Let Date_Created(p_Data)
		m_Date_Created = p_Data
	End Property
	
	' Returns a list of ALL privileged objects, or optionally, returns a list 
	' of all privileged objects within a given context in a variety of formats
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
			SQLStr = "sp_security_list_privileged_objects_by_scopeConstant_return_xml '" & p_ContextScope & "'"
			xmlout.selectSingleNode("//Root").appendChild utils.loadXMLFromRS(SQLStr, "Security_Privileged_Objects").selectSingleNode("//Security_Privileged_Objects")
			Set All = xmlout
			Set xmlout = Nothing
		elseif p_outputType = OUTPUT_RECORDSET then
			SQLStr = "sp_security_list_privileged_objects_by_scopeConstant '" & p_ContextScope & "'"
			Set All = utils.LoadRSFromDB(SQLStr)
		elseif p_outputType = OUTPUT_CONSTANTARRAY then
			SQLStr = "sp_security_list_privileged_objects_by_scopeConstant_return_constantarray '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				arrayout = rs("Output_Array")
			end if
			All = arrayout
			Set rs = Nothing
		elseif p_outputType = OUTPUT_DICTIONARY then
			Dim tmpDictionaryOut
			Set tmpDictionaryOut = Server.CreateObject("Scripting.Dictionary")
			SQLStr = "sp_security_list_privileged_objects_by_scopeConstant '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				Do Until rs.EOF
					Set tmpObject = New cls_Security_Privileged_Object
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
			SQLStr = "sp_security_list_privileged_objects_by_scopeConstant_return_array '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				arrayout = rs("Output_Array")
			end if
			All = arrayout
			Set rs = Nothing
		end if
	End Function

	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim SQLStr, rs

		SQLStr = "SELECT * FROM Security_Privilege_Object WHERE ID = '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_Privilege_ID = SmartValues(rs("Privilege_ID"), "CInt")
				m_Secured_Object_ID = SmartValues(rs("Secured_Object_ID"), "CInt")
				m_User_ID = SmartValues(rs("User_ID"), "CInt")
				m_Group_ID = SmartValues(rs("Group_ID"), "CInt")
				m_Date_Created = SmartValues(rs("Date_Created"), "CDate")
				Load = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_Privileged_Object", "Error loading class cls_Security_Privileged_Object [Load]: Item was not found."
			Case else
				err.raise 3, "cls_Security_Privileged_Object", "Error loading class cls_Security_Privileged_Object [Load]: Item was not unique."			
		end Select
	End Function

	'Loads this object's values by loading a record based on the given ID and the current security context
	Public Function LoadFromCurrentContext(ByRef p_CurrentContextXMLObject, p_ID)
		Dim tempxmldoc, tempxmlattribute
		Set tempxmldoc = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
		Set tempxmlattribute = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")

		tempxmldoc.async = False
		tempxmldoc.validateOnParse = False
		tempxmldoc.preserveWhitespace = True
		tempxmldoc.resolveExternals = False
		tempxmldoc.load p_CurrentContextXMLObject

		if tempxmldoc.selectNodes("//Security_Privileged_Object[@ID = '" & CStr(p_ID) & "']").length > 0 then
			for each tempxmlattribute in tempxmldoc.selectSingleNode("//Security_Privileged_Object[@ID = '" & CStr(p_ID) & "']").attributes
				'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
				if tempxmlattribute.nodeName = "ID" then m_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Privilege_ID" then m_Privilege_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Secured_Object_ID" then m_Secured_Object_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "User_ID" then m_User_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Group_ID" then m_Group_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Date_Created" then m_Date_Created = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
			next
		end if
		
		Set tempxmldoc = Nothing
		Set tempxmlattribute = Nothing
	End Function

    Public Function Save()
		Dim SQLStr

		SQLStr = "sp_Security_Privilege_Object_InsertUpdate " & _
		SQLStr = SQLStr & " @ID = " & m_ID & ", "
		SQLStr = SQLStr & " @Privilege_ID = " & m_Privilege_ID & ", "
		SQLStr = SQLStr & " @Secured_Object_ID = " & m_Secured_Object_ID & ", "
		SQLStr = SQLStr & " @User_ID = " & m_User_ID & ", "
		SQLStr = SQLStr & " @Group_ID = " & m_Group_ID & ", "
		SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
		SQLStr = SQLStr & " " & m_ID & " OUTPUT "
		
		utils.LoadRSFromDB SQLStr
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "DELETE FROM Security_Privilege_Object WHERE [ID] = '0" & CLng(p_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>