<%
'==============================================================================
' CLASS: cls_ActivityLogEventCollection
' Generated using CodeSmith on Tuesday, October 17, 2006
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with the cls_ActivityLogEventCollection class.  
'
'	:: Properties
'	Activity_Log_ID
'	Lists (Collection)
'
'	:: Collections
'	m_ActivityLogEvents
'
'	:: Methods
'	LoadByActivityLogID(p_ID)
'	Clear()
'	DeleteAll()
'
'==============================================================================
Class cls_ActivityLogEventCollection
	'Private, class member variable
	Private m_ActivityLogEvents
	Private m_Activity_Log_ID
	Private utils

	Private Sub Class_Initialize()
		Set m_ActivityLogEvents = Server.CreateObject("Scripting.Dictionary")
		Set utils = New cls_UtilityLibrary
		m_Activity_Log_ID = -1
	End Sub

	Private Sub Class_Terminate()
		Set m_ActivityLogEvents = Nothing
		Set utils = Nothing
	End Sub

	'Read the current Activity_Log_ID value
	Public Property Get Activity_Log_ID()
		Activity_Log_ID = m_Activity_Log_ID
	End Property
	'store a new Activity_Log_ID value
	Public Property Let Activity_Log_ID(p_Data)
		m_Activity_Log_ID = p_Data
	End Property

	'store a new Count value
	Public Property Get Count()
		Count = m_ActivityLogEvents.Count
	End Property

	Public Property Get Lists()
		Set Lists = m_ActivityLogEvents
	End Property

	Public Property Get ListIDs()
		ListIDs = m_ActivityLogEvents.Keys()
	End Property
	
	Public Function LoadByActivityLogID(p_Data)
		m_Activity_Log_ID = checkQueryID(SmartValues(p_Data, "CLng"), 0)
		LoadByActivityLogID = Enumerate()
	End Function

	Private Function Enumerate()
		Dim SQLStr, rs, i
		Dim tmpBaseObj

		SQLStr = "sp_Security_Activity_Log_Events_SelectBy_Activity_Log_ID '0" & m_Activity_Log_ID & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)
		
		Do Until rs.EOF
			Set tmpBaseObj = New cls_ActivityLogEvent
			
			tmpBaseObj.Hydrate(rs)
			
			If Not m_ActivityLogEvents.Exists(tmpBaseObj) Then 
				m_ActivityLogEvents.Add tmpBaseObj, 0
			End If				
			Set tmpBaseObj = Nothing
			rs.MoveNext
		Loop
		
		Enumerate = m_ActivityLogEvents.Count
		
	End Function
	
	Public Function Add(p_Summary)
	
		If Len(trim(p_Summary)) = 0 Then Add = False
		
		Dim t_ActivityLogEvent
		Set t_ActivityLogEvent = New cls_ActivityLogEvent
		
		t_ActivityLogEvent.Activity_Log_ID = m_Activity_Log_ID
		If Len(trim(p_Summary)) > 0 Then t_ActivityLogEvent.Summary = p_Summary
		
		If Not m_ActivityLogEvents.Exists(t_ActivityLogEvent) Then 
			m_ActivityLogEvents.Add t_ActivityLogEvent, 0
		End If
	
		Add = True
		
	End Function
	
	Public Function Save()
	
		If m_Activity_Log_ID <> -1 Then
			
			Dim ActivityLE
			
			For Each ActivityLE in m_ActivityLogEvents
				ActivityLE.Activity_Log_ID = m_Activity_Log_ID
				ActivityLE.Save
			Next
			
			Save = True
		Else
			Save = False
		End If
	
	End Function

	Private Function ClearAll()
		m_ActivityLogEvents.RemoveAll()
		m_Activity_Log_ID = -1
	End Function

	Public Function DeleteAll()
		Dim SQLStr
        SQLStr = "sp_Security_Activity_Log_Events_DeleteBy_Activity_Log_ID '0" & m_Activity_Log_ID & "'"
		utils.RunSQL SQLStr
		ClearAll()
	End Function

End Class
%>
