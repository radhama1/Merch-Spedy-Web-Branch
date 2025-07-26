<%
'==============================================================================
' CLASS: cls_Security_User
' Generated using CodeSmith on Friday, October 14, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with 
' table DriversEdDirect_Dev.dbo.Security_User.  
'
'==============================================================================
Class cls_Security_User
	'Private, class member variable
	Private m_ID
	Private m_GUID
	Private m_Email_Address
	Private m_UserName
	Private m_Password
	Private m_Enabled
	Private m_Last_Name
	Private m_First_Name
	Private m_Middle_Name
	Private m_Title
	Private m_Suffix
	Private m_Organization
	Private m_Department
	Private m_Job_Title
	Private m_Office_Location
	Private m_Gender
	Private m_Language_ID
	Private m_Comments
	Private m_Start_Date
	Private m_End_Date
	Private m_Date_Created
	Private m_Date_Last_Modified
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
	'Read the current GUID value
	Public Property Get GUID()
		GUID = CStr(m_GUID)
	End Property
	'store a new GUID value
	Private Property Let GUID(p_Data)
		m_GUID = p_Data
	End Property
	'Read the current Email_Address value
	Public Property Get Email_Address()
		Email_Address = CStr(m_Email_Address)
	End Property
	'store a new Email_Address value
	Public Property Let Email_Address(p_Data)
		m_Email_Address = p_Data
	End Property
	'Read the current UserName value
	Public Property Get UserName()
		UserName = CStr(m_UserName)
	End Property
	'store a new UserName value
	Public Property Let UserName(p_Data)
		m_UserName = p_Data
	End Property
	'Read the current Password value
	Public Property Get Password()
		Password = CStr(m_Password)
	End Property
	'store a new Password value
	Public Property Let Password(p_Data)
		m_Password = p_Data
	End Property
	'Read the current Enabled value
	Public Property Get Enabled()
		Enabled = CBool(m_Enabled)
	End Property
	'store a new Enabled value
	Public Property Let Enabled(p_Data)
		m_Enabled = p_Data
	End Property
	'Read the current Last_Name value
	Public Property Get Last_Name()
		Last_Name = CStr(m_Last_Name)
	End Property
	'store a new Last_Name value
	Public Property Let Last_Name(p_Data)
		m_Last_Name = p_Data
	End Property
	'Read the current First_Name value
	Public Property Get First_Name()
		First_Name = CStr(m_First_Name)
	End Property
	'store a new First_Name value
	Public Property Let First_Name(p_Data)
		m_First_Name = p_Data
	End Property
	'Read the current Middle_Name value
	Public Property Get Middle_Name()
		Middle_Name = CStr(m_Middle_Name)
	End Property
	'store a new Middle_Name value
	Public Property Let Middle_Name(p_Data)
		m_Middle_Name = p_Data
	End Property
	'Read the current Title value
	Public Property Get Title()
		Title = CStr(m_Title)
	End Property
	'store a new Title value
	Public Property Let Title(p_Data)
		m_Title = p_Data
	End Property
	'Read the current Suffix value
	Public Property Get Suffix()
		Suffix = CStr(m_Suffix)
	End Property
	'store a new Suffix value
	Public Property Let Suffix(p_Data)
		m_Suffix = p_Data
	End Property
	'Read the current Organization value
	Public Property Get Organization()
		Organization = CStr(m_Organization)
	End Property
	'store a new Organization value
	Public Property Let Organization(p_Data)
		m_Organization = p_Data
	End Property
	'Read the current Department value
	Public Property Get Department()
		Department = CStr(m_Department)
	End Property
	'store a new Department value
	Public Property Let Department(p_Data)
		m_Department = p_Data
	End Property
	'Read the current Job_Title value
	Public Property Get Job_Title()
		Job_Title = CStr(m_Job_Title)
	End Property
	'store a new Job_Title value
	Public Property Let Job_Title(p_Data)
		m_Job_Title = p_Data
	End Property
	'Read the current Office_Location value
	Public Property Get Office_Location()
		Office_Location = CStr(m_Office_Location)
	End Property
	'store a new Office_Location value
	Public Property Let Office_Location(p_Data)
		m_Office_Location = p_Data
	End Property
	'Read the current Gender value
	Public Property Get Gender()
		Gender = CStr(m_Gender)
	End Property
	'store a new Gender value
	Public Property Let Gender(p_Data)
		m_Gender = p_Data
	End Property
	'Read the current Language_ID value
	Public Property Get Language_ID()
		Language_ID = CInt(m_Language_ID)
	End Property
	'store a new Language_ID value
	Public Property Let Language_ID(p_Data)
		m_Language_ID = p_Data
	End Property
	'Read the current Comments value
	Public Property Get Comments()
		Comments = CStr(m_Comments)
	End Property
	'store a new Comments value
	Public Property Let Comments(p_Data)
		m_Comments = p_Data
	End Property
	'Read the current Start_Date value
	Public Property Get Start_Date()
		Start_Date = CDate(m_Start_Date)
	End Property
	'store a new Start_Date value
	Public Property Let Start_Date(p_Data)
		m_Start_Date = p_Data
	End Property
	'Read the current End_Date value
	Public Property Get End_Date()
		End_Date = CDate(m_End_Date)
	End Property
	'store a new End_Date value
	Public Property Let End_Date(p_Data)
		m_End_Date = p_Data
	End Property
	'Read the current Date_Created value
	Public Property Get Date_Created()
		Date_Created = CDate(m_Date_Created)
	End Property
	'store a new Date_Created value
	Public Property Let Date_Created(p_Data)
		m_Date_Created = p_Data
	End Property
	'Read the current Date_Last_Modified value
	Public Property Get Date_Last_Modified()
		Date_Last_Modified = CDate(m_Date_Last_Modified)
	End Property
	'store a new Date_Last_Modified value
	Public Property Let Date_Last_Modified(p_Data)
		m_Date_Last_Modified = p_Data
	End Property

	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim SQLStr, rs

		SQLStr = "SELECT * FROM Security_User WHERE ID = '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_GUID = SmartValues(rs("GUID"), "CStr")
				m_Email_Address = SmartValues(rs("Email_Address"), "CStr")
				m_UserName = SmartValues(rs("UserName"), "CStr")
				m_Password = SmartValues(rs("Password"), "CStr")
				m_Enabled = SmartValues(rs("Enabled"), "CBool")
				m_Last_Name = SmartValues(rs("Last_Name"), "CStr")
				m_First_Name = SmartValues(rs("First_Name"), "CStr")
				m_Middle_Name = SmartValues(rs("Middle_Name"), "CStr")
				m_Title = SmartValues(rs("Title"), "CStr")
				m_Suffix = SmartValues(rs("Suffix"), "CStr")
				m_Organization = SmartValues(rs("Organization"), "CStr")
				m_Department = SmartValues(rs("Department"), "CStr")
				m_Job_Title = SmartValues(rs("Job_Title"), "CStr")
				m_Office_Location = SmartValues(rs("Office_Location"), "CStr")
				m_Gender = SmartValues(rs("Gender"), "CStr")
				m_Language_ID = SmartValues(rs("Language_ID"), "CInt")
				m_Comments = SmartValues(rs("Comments"), "CStr")
				m_Start_Date = SmartValues(rs("Start_Date"), "CDate")
				m_End_Date = SmartValues(rs("End_Date"), "CDate")
				m_Date_Created = SmartValues(rs("Date_Created"), "CDate")
				m_Date_Last_Modified = SmartValues(rs("Date_Last_Modified"), "CDate")
				Load = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_User", "Error loading class cls_Security_User [Load]: Item was not found."
			Case else
				err.raise 3, "cls_Security_User", "Error loading class cls_Security_User [Load]: Item was not unique."			
		end Select
	End Function

	'Loads this object's values by loading a record based on the given GUID
	Public Function LoadFromGUID(p_GUID)
		Dim SQLStr, rs

		SQLStr = "SELECT * FROM Security_User WHERE GUID = '" & CStr(p_GUID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_GUID = SmartValues(rs("GUID"), "CStr")
				m_Email_Address = SmartValues(rs("Email_Address"), "CStr")
				m_UserName = SmartValues(rs("UserName"), "CStr")
				m_Password = SmartValues(rs("Password"), "CStr")
				m_Enabled = SmartValues(rs("Enabled"), "CBool")
				m_Last_Name = SmartValues(rs("Last_Name"), "CStr")
				m_First_Name = SmartValues(rs("First_Name"), "CStr")
				m_Middle_Name = SmartValues(rs("Middle_Name"), "CStr")
				m_Title = SmartValues(rs("Title"), "CStr")
				m_Suffix = SmartValues(rs("Suffix"), "CStr")
				m_Organization = SmartValues(rs("Organization"), "CStr")
				m_Department = SmartValues(rs("Department"), "CStr")
				m_Job_Title = SmartValues(rs("Job_Title"), "CStr")
				m_Office_Location = SmartValues(rs("Office_Location"), "CStr")
				m_Gender = SmartValues(rs("Gender"), "CStr")
				m_Language_ID = SmartValues(rs("Language_ID"), "CInt")
				m_Comments = SmartValues(rs("Comments"), "CStr")
				m_Start_Date = SmartValues(rs("Start_Date"), "CDate")
				m_End_Date = SmartValues(rs("End_Date"), "CDate")
				m_Date_Created = SmartValues(rs("Date_Created"), "CDate")
				m_Date_Last_Modified = SmartValues(rs("Date_Last_Modified"), "CDate")
				LoadFromGUID = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_User", "Error loading class cls_Security_User [LoadFromGUID]: Item was not found."
			Case else
				err.raise 3, "cls_Security_User", "Error loading class cls_Security_User [LoadFromGUID]: Item was not unique."			
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

		if tempxmldoc.selectNodes("//Security_User[@ID = '" & CStr(p_ID) & "']").length > 0 then
			for each tempxmlattribute in tempxmldoc.selectSingleNode("//Security_User[@ID = '" & CStr(p_ID) & "']").attributes
				'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
				if tempxmlattribute.nodeName = "ID" then m_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "GUID" then m_GUID = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Email_Address" then m_Email_Address = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "UserName" then m_UserName = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Password" then m_Password = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Enabled" then m_Enabled = SmartValues(tempxmlattribute.nodeValue, "CBool")
				if tempxmlattribute.nodeName = "Last_Name" then m_Last_Name = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "First_Name" then m_First_Name = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Middle_Name" then m_Middle_Name = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Title" then m_Title = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Suffix" then m_Suffix = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Organization" then m_Organization = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Department" then m_Department = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Job_Title" then m_Job_Title = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Office_Location" then m_Office_Location = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Gender" then m_Gender = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Language_ID" then m_Language_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Comments" then m_Comments = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Start_Date" then m_Start_Date = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "End_Date" then m_End_Date = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "Date_Created" then m_Date_Created = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "Date_Last_Modified" then m_Date_Last_Modified = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
			next
		end if
		
		Set tempxmldoc = Nothing
		Set tempxmlattribute = Nothing
	End Function

    Public Function Save()
		Dim SQLStr

		SQLStr = "sp_Security_User_InsertUpdate " & _
		SQLStr = SQLStr & " @ID = " & m_ID & ", "
		SQLStr = SQLStr & " @Email_Address = " & m_Email_Address & ", "
		SQLStr = SQLStr & " @UserName = " & m_UserName & ", "
		SQLStr = SQLStr & " @Password = " & m_Password & ", "
		SQLStr = SQLStr & " @Enabled = " & m_Enabled & ", "
		SQLStr = SQLStr & " @Last_Name = " & m_Last_Name & ", "
		SQLStr = SQLStr & " @First_Name = " & m_First_Name & ", "
		SQLStr = SQLStr & " @Middle_Name = " & m_Middle_Name & ", "
		SQLStr = SQLStr & " @Title = " & m_Title & ", "
		SQLStr = SQLStr & " @Suffix = " & m_Suffix & ", "
		SQLStr = SQLStr & " @Organization = " & m_Organization & ", "
		SQLStr = SQLStr & " @Department = " & m_Department & ", "
		SQLStr = SQLStr & " @Job_Title = " & m_Job_Title & ", "
		SQLStr = SQLStr & " @Office_Location = " & m_Office_Location & ", "
		SQLStr = SQLStr & " @Gender = " & m_Gender & ", "
		SQLStr = SQLStr & " @Language_ID = " & m_Language_ID & ", "
		SQLStr = SQLStr & " @Comments = " & m_Comments & ", "
		SQLStr = SQLStr & " @Start_Date = " & m_Start_Date & ", "
		SQLStr = SQLStr & " @End_Date = " & m_End_Date & ", "
		SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
		SQLStr = SQLStr & " @Date_Last_Modified = " & m_Date_Last_Modified & ", "
		SQLStr = SQLStr & " " & m_ID & " OUTPUT "
		
		utils.LoadRSFromDB SQLStr
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "DELETE FROM Security_User WHERE [ID] = '0" & CLng(p_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>