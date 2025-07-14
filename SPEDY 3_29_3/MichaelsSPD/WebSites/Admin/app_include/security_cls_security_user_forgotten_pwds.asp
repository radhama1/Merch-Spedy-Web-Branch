<%
'==============================================================================
' CLASS: cls_Security_User_Forgotten_Pwds
' Generated using CodeSmith on Friday, October 14, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with 
' table DriversEdDirect_Dev.dbo.Security_User_Forgotten_Pwds.  
'
'==============================================================================
Class cls_Security_User_Forgotten_Pwds
	'Private, class member variable
	Private m_ID
	Private m_UserName
	Private m_User_ID
	Private m_Date_Requested
	Private m_Request_Success
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
	'Read the current UserName value
	Public Property Get UserName()
		UserName = CStr(m_UserName)
	End Property
	'store a new UserName value
	Public Property Let UserName(p_Data)
		m_UserName = p_Data
	End Property
	'Read the current User_ID value
	Public Property Get User_ID()
		User_ID = CInt(m_User_ID)
	End Property
	'store a new User_ID value
	Public Property Let User_ID(p_Data)
		m_User_ID = p_Data
	End Property
	'Read the current Date_Requested value
	Public Property Get Date_Requested()
		Date_Requested = CDate(m_Date_Requested)
	End Property
	'store a new Date_Requested value
	Public Property Let Date_Requested(p_Data)
		m_Date_Requested = p_Data
	End Property
	'Read the current Request_Success value
	Public Property Get Request_Success()
		Request_Success = CBool(m_Request_Success)
	End Property
	'store a new Request_Success value
	Public Property Let Request_Success(p_Data)
		m_Request_Success = p_Data
	End Property

	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim SQLStr, rs

		SQLStr = "SELECT * FROM Security_User_Forgotten_Pwds WHERE ID = '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_UserName = SmartValues(rs("UserName"), "CStr")
				m_User_ID = SmartValues(rs("User_ID"), "CInt")
				m_Date_Requested = SmartValues(rs("Date_Requested"), "CDate")
				m_Request_Success = SmartValues(rs("Request_Success"), "CBool")
				Load = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_User_Forgotten_Pwds", "Error loading class cls_Security_User_Forgotten_Pwds [Load]: Item was not found."
			Case else
				err.raise 3, "cls_Security_User_Forgotten_Pwds", "Error loading class cls_Security_User_Forgotten_Pwds [Load]: Item was not unique."			
		end Select
	End Function

'	'Loads this object's values by loading a record based on the given ID and the current security context
'	Public Function LoadFromCurrentContext(ByRef p_CurrentContextXMLObject, p_ID)
'		Dim tempxmldoc, tempxmlattribute
'		Set tempxmldoc = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
'		Set tempxmlattribute = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
'
'		tempxmldoc.async = False
'		tempxmldoc.validateOnParse = False
'		tempxmldoc.preserveWhitespace = True
'		tempxmldoc.resolveExternals = False
'		tempxmldoc.load p_CurrentContextXMLObject
'
'		if tempxmldoc.selectNodes("//Security_User_Forgotten_Pwds[@ID = '" & CStr(p_ID) & "']").length > 0 then
'			for each tempxmlattribute in tempxmldoc.selectSingleNode("//Security_User_Forgotten_Pwds[@ID = '" & CStr(p_ID) & "']").attributes
'				'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
'				if tempxmlattribute.nodeName = "ID" then m_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
'				if tempxmlattribute.nodeName = "UserName" then m_UserName = SmartValues(tempxmlattribute.nodeValue, "CStr")
'				if tempxmlattribute.nodeName = "User_ID" then m_User_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
'				if tempxmlattribute.nodeName = "Date_Requested" then m_Date_Requested = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
'				if tempxmlattribute.nodeName = "Request_Success" then m_Request_Success = SmartValues(tempxmlattribute.nodeValue, "CBool")
'			next
'		end if
'		
'		Set tempxmldoc = Nothing
'		Set tempxmlattribute = Nothing
'	End Function

    Public Function Save()
		Dim SQLStr

		SQLStr = "sp_Security_User_Forgotten_Pwds_InsertUpdate " & _
		SQLStr = SQLStr & " @ID = " & m_ID & ", "
		SQLStr = SQLStr & " @UserName = " & m_UserName & ", "
		SQLStr = SQLStr & " @User_ID = " & m_User_ID & ", "
		SQLStr = SQLStr & " @Date_Requested = " & m_Date_Requested & ", "
		SQLStr = SQLStr & " @Request_Success = " & m_Request_Success & ", "
		SQLStr = SQLStr & " " & m_ID & " OUTPUT "
		
		utils.LoadRSFromDB SQLStr
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "DELETE FROM Security_User_Forgotten_Pwds WHERE [ID] = '0" & CLng(p_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>