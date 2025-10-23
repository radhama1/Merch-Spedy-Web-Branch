<%
'==============================================================================
' CLASS: cls_SecurityActivityLogEvent
' Generated using CodeSmith on Tuesday, October 17, 2006
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with the dbo.Security_Activity_Log_Event table.  
'
'	:: Properties
'	ID = CInt(m_ID)
'	Activity_Log_ID = CInt(m_Activity_Log_ID)
'	Summary = CStr(m_Summary)
'
'	:: Methods
'	Load(p_ID)
'	Save()
'	Delete()
'
'==============================================================================
Class cls_SecurityActivityLogEvent
	'Private, class member variable
	Private m_ID
	Private m_Activity_Log_ID
	Private m_Summary
	Private utils

	Private Sub Class_Initialize()
		Set utils = New cls_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set utils = Nothing
	End Sub

	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property

	'Read the current Activity_Log_ID value
	Public Property Get Activity_Log_ID()
		Activity_Log_ID = m_Activity_Log_ID
	End Property
	'store a new Activity_Log_ID value
	Public Property Let Activity_Log_ID(p_Data)
		m_Activity_Log_ID = p_Data
	End Property

	'Read the current Summary value
	Public Property Get Summary()
		Summary = m_Summary
	End Property
	'store a new Summary value
	Public Property Let Summary(p_Data)
		m_Summary = p_Data
	End Property


	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim SQLStr, rs

		SQLStr = "sp_Security_Activity_Log_Event_Select '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		if rs.recordcount = 1 then
			m_ID = SmartValues(rs("ID"), "CLng")
			m_Activity_Log_ID = SmartValues(rs("Activity_Log_ID"), "CLng")
			m_Summary = SmartValues(rs("Summary"), "CStr")

			Load = true
		else
			Select Case rs.recordcount
				Case -1, 0
					Session.Value("LASTOBJECTLOADERROR") = "Error loading class cls_Security_Activity_Log_Event [Load]: Item was not found."
				Case else
					Session.Value("LASTOBJECTLOADERROR") = "Error loading class cls_Security_Activity_Log_Event [Load]: Item was not unique."
			End Select
			Response.Write vbCrLf & vbCrLf & "<!--" & Session.Value("LASTOBJECTLOADERROR") & "-->" & vbCrLf & vbCrLf
		
			Load = false
		end if
	End Function

    Public Function Save()
		Dim SQLStr, rs

		SQLStr = "sp_Security_Activity_Log_Event_InsertUpdate @ID = '0" & m_ID & "'"
		if Len(m_Activity_Log_ID) > 0 then SQLStr = SQLStr & ", @Activity_Log_ID = '" & m_Activity_Log_ID & "'"
		if Len(m_Summary) > 0 then SQLStr = SQLStr & ", @Summary = '" & utils.FormatDBStringForInsert(m_Summary) & "'"
				
		Set rs = utils.LoadRSFromDB(SQLStr)
		m_ID = SmartValues(rs(0), "CLng")
		
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "sp_Security_Activity_Log_Event_Delete '0" & CLng(m_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>
