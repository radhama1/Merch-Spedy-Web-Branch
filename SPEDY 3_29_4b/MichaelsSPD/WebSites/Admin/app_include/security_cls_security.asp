<% 
'==============================================================================
' CLASS: cls_Security
' Created Friday, September 08, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with 
' the Security super class
'
'==============================================================================
Class cls_Security

	'Private, class member variables	
	Private m_CurrentUserID				'The Current User's ID
	Private m_CurrentUserGUID			'The Current User's Globally Unique Identifier
	Private m_CurrentScopeConstant		'The string constant of the current scope (where applicable).
	Private m_CurrentPrivilegedObjectID	'The ID of the current object (where applicable).
	Private m_xml						'String representation of the Security XML object
	Private m_objSecurityXML			'The Security XML object
	Private m_Groups
	Private utils

	Private Sub Class_Initialize()
		Set m_objSecurityXML = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
		Set m_Groups = Server.CreateObject("Scripting.Dictionary")
		Set utils = New cls_Security_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set m_objSecurityXML = Nothing
		Set m_Groups = Nothing
		Set utils = Nothing
	End Sub

	'Get the CurrentUserID Object
	Public Property Get CurrentUserID()
		CurrentUserID = CInt(m_CurrentUserID)
	End Property
	'Set the CurrentUserID Object
	Public Property Let CurrentUserID(p_Data)
		m_CurrentUserID = p_Data
	End Property

	'Get the CurrentUserGUID Object
	Public Property Get CurrentUserGUID()
		CurrentUserGUID = CStr(m_CurrentUserGUID)
	End Property
	'Set the CurrentUserGUID Object
	Public Property Let CurrentUserGUID(p_Data)
		m_CurrentUserGUID = p_Data
		m_CurrentUserID = resolveUserIDFromGUID()
	End Property

	'Get the CurrentScopeConstant Object
	Public Property Get CurrentScopeConstant()
		CurrentScopeConstant = CStr(m_CurrentScopeConstant)
	End Property
	'Set the CurrentScopeConstant Object
	Public Property Let CurrentScopeConstant(p_Data)
		m_CurrentScopeConstant = p_Data
	End Property

	'Get the CurrentPrivilegedObjectID Object
	Public Property Get CurrentPrivilegedObjectID()
		CurrentPrivilegedObjectID = CInt(m_CurrentPrivilegedObjectID)
	End Property
	'Set the CurrentPrivilegedObjectID Object
	Public Property Let CurrentPrivilegedObjectID(p_Data)
		m_CurrentPrivilegedObjectID = p_Data
	End Property

	'Get the XMLObject Object
	Public Property Get XMLObject()
		Set XMLObject = m_objSecurityXML
	End Property

	'Get the XMLSource Object
	Public Property Get XMLSource()
		XMLSource = CStr(m_xml)
	End Property
	'Set the XMLSource Object
	Private Property Let XMLSource(p_Data)
		m_xml = p_Data
	End Property

	'Get the Groups Collection
	Public Property Get Groups()
		Set Groups = m_Groups
	End Property

	Public Function Initialize(p_CurrentUserID, p_CurrentScopeConstant, p_CurrentPrivilegedObjectID)
		m_CurrentUserID = p_CurrentUserID
		m_CurrentScopeConstant = p_CurrentScopeConstant
		m_CurrentPrivilegedObjectID = p_CurrentPrivilegedObjectID
		Load()
	End Function

	Public Function isRequestedScopeAllowed(Requested_Scope_Constant)
		Dim retValue
		retValue = false

		if m_objSecurityXML.selectNodes("//Security_Scope[@Constant = '" & CStr(Requested_Scope_Constant) & "']").length > 0 then
			retValue = true	
		end if

		if not retValue then retValue = isSystemAdministrator()
		isRequestedScopeAllowed = retValue
	End Function

	Public Function isRequestedPrivilegeAllowed(Requested_Scope_Constant, Requested_Privilege_Constant)
		Dim retValue
		retValue = false

		if m_objSecurityXML.selectNodes("//Security_Privilege[@Constant = '" & CStr(Requested_Privilege_Constant) & "']/Security_Scope[@Constant = '" & CStr(Requested_Scope_Constant) & "']").length > 0 then
			retValue = true	
		end if

		if not retValue then retValue = isSystemAdministrator()
		isRequestedPrivilegeAllowed = retValue
	End Function

	Public Function isRequestedPrivilegeAllowedWithinCurrentContext(Requested_Privilege_Constant)

 		isRequestedPrivilegeAllowedWithinCurrentContext = isRequestedPrivilegeAllowed(m_CurrentScopeConstant, Requested_Privilege_Constant)

	End Function

	Public Function isRequestedAccessToObjectAllowed(Requested_Scope_Constant, Requested_Privilege_Constant, Requested_Object_ID)
		Dim retValue
		retValue = false

		if m_objSecurityXML.selectNodes("//Security_Privileged_Objects/Security_Privileged_Object[@Secured_Object_ID = '" & CStr(Requested_Object_ID) & "']/Security_Privilege[@Constant = '" & CStr(Requested_Privilege_Constant) & "']/Security_Scope[@Constant = '" & CStr(Requested_Scope_Constant) & "']").length > 0 then
			retValue = true	
		end if
		
		if not retValue then retValue = isSystemAdministrator()
		isRequestedAccessToObjectAllowed = retValue
	End Function

	Public Function isRequestedAccessToObjectAllowedWithinCurrentContext(Requested_Privilege_Constant, Requested_Object_ID)

		isRequestedAccessToObjectAllowedWithinCurrentContext = isRequestedAccessToObjectAllowed(m_CurrentScopeConstant, Requested_Privilege_Constant, Requested_Object_ID)

	End Function

	Public Function isSystemAdministrator()
		Dim retValue
		retValue = false

		if m_objSecurityXML.selectNodes("//Security_Group[@System_Role = '1']").length > 0 then
			retValue = true	
		end if
		
		isSystemAdministrator = retValue
	End Function

	Public Function Load()
		LoadCurrentContextFromDB()
		m_CurrentUserGUID = resolveUserGUIDFromID()
		LoadAllGroups()
		m_xml = m_objSecurityXML.xml
	End Function

	Public Function Clear()
		Set m_objSecurityXML = Nothing
		m_Groups.RemoveAll()
		CurrentUserID = ""
		CurrentUserGUID = ""
		CurrentScopeConstant = ""
		CurrentPrivilegedObjectID = ""
		XMLSource = ""
	End Function

	Public Function saveXMLToFile(p_FilePath)
		m_objSecurityXML.save(p_FilePath)
	End Function

	Private Function resolveUserGUIDFromID()
		resolveUserGUIDFromID = 0
		if Trim(m_CurrentUserID) <> "" and IsNumeric(m_CurrentUserID) then
			if m_CurrentUserID > 0 then
				Dim tmpSecurityUser	
				Set tmpSecurityUser = New cls_Security_User
				tmpSecurityUser.Load(m_CurrentUserID)
				resolveUserGUIDFromID = CStr(tmpSecurityUser.GUID)
				Set tmpSecurityUser = Nothing
			end if
		end if
	End Function

	Private Function resolveUserIDFromGUID()
		resolveUserIDFromGUID = 0
		if Len(Trim(m_CurrentUserGUID)) > 0 then
			Dim tmpSecurityUser	
			Set tmpSecurityUser = New cls_Security_User
			resolveUserIDFromGUID = CLng(tmpSecurityUser.LoadFromGUID(m_CurrentUserGUID))
			Set tmpSecurityUser = Nothing
		end if
	End Function

	Private Function LoadCurrentContextFromDB()
		Dim SQLStr

		m_objSecurityXML.async = False
		m_objSecurityXML.validateOnParse = False
		m_objSecurityXML.preserveWhitespace = True
		m_objSecurityXML.resolveExternals = False
		m_objSecurityXML.loadXML("<?xml version='1.0'?><Root></Root>")

		if Trim(m_CurrentUserID) <> "" and IsNumeric(m_CurrentUserID) then
		
			if m_CurrentUserID > 0 then
				SQLStr = "SELECT Security_User.* FROM Security_User WHERE Security_User.[ID] = '0" & m_CurrentUserID & "' FOR XML AUTO"
				m_objSecurityXML.selectSingleNode("//Root").appendChild utils.loadXMLFromRS(SQLStr, "Security_User").selectSingleNode("//Security_User[@ID=" & m_CurrentUserID & "]")

				SQLStr = "sp_security_generate_securitycontextxmldoc_securitygroups_by_UserID '0" & m_CurrentUserID & "', 1"
				m_objSecurityXML.selectSingleNode("//Security_User").appendChild utils.loadXMLFromRS(SQLStr, "Security_Groups").selectSingleNode("*")

				SQLStr = "sp_security_generate_securitycontextxmldoc_by_UserID '0" & m_CurrentUserID & "'"
				m_objSecurityXML.selectSingleNode("//Security_User").appendChild utils.loadXMLFromRS(SQLStr, "Security_Privileges").selectSingleNode("*")
				
				SQLStr = "sp_security_generate_securitycontextxmldoc_privilegedobjects_by_UserID '0" & m_CurrentUserID & "'"
				m_objSecurityXML.selectSingleNode("//Security_User").appendChild utils.loadXMLFromRS(SQLStr, "Security_Privileged_Objects").selectSingleNode("*")
			end if
		end if
		
	End Function

	Private Function LoadAllGroups()
		Dim tmpnode, tmpxmlattribute
		Dim tmpSecurityGroup
		
		Set tmpnode = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
		Set tmpxmlattribute = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")

		if m_objSecurityXML.selectNodes("//Security_Groups").length > 0 then
			for each tmpnode in m_objSecurityXML.selectNodes("//Security_Groups/*")
				Set tmpSecurityGroup = New cls_Security_Group
				tmpSecurityGroup.LoadFromCurrentContext m_objSecurityXML, tmpnode.getAttribute("ID")
				m_Groups.Add tmpnode.getAttribute("ID"), tmpSecurityGroup
				Set tmpSecurityGroup = Nothing
			next
		end if
		
		Set tmpnode = Nothing
	End Function

End Class
%>

