<%
'==============================================================================
' CLASS: cls_ActivityLogCollection
' Generated using CodeSmith on Tuesday, October 17, 2006
' By Oscar.Treto
'==============================================================================
'
' This object represents properties and methods for interacting with Activity Log Collection. 
'
'	:: Properties
'	Count
'	Lists (Collection)
'
'	:: Public Methods
'	LoadByCategoryID(p_Data)
'	LoadByCategoryIDWChildren(p_Data)
'	Clear()
'
'==============================================================================
Class cls_ActivityLogCollection
	'Private, class member variable
	Private m_ActivityLogs
	Private utils

	Private Sub Class_Initialize()
		Set m_ActivityLogs = Server.CreateObject("Scripting.Dictionary")
		Set utils = New cls_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set m_ActivityLogs = Nothing
		Set utils = Nothing
	End Sub

	'store a new Count value
	Public Property Get Count()
		Count = m_ActivityLogs.Count
	End Property

	Public Property Get Lists()
		Set Lists = m_ActivityLogs
	End Property

	Public Function LoadByCategoryID(p_Data)
		Dim SQLStr, rs, i
		Dim tmpBaseObj

		SQLStr = "sp_Security_Activity_Log_SelectBy_Category_ID '0" & p_Data & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)
		
		Do Until rs.EOF
			Set tmpBaseObj = New cls_ActivityLog
			
			tmpBaseObj.Load(rs("ID"))
			
			If Not m_ActivityLogs.Exists(tmpBaseObj) Then 
				m_ActivityLogs.Add tmpBaseObj, 0
			End If				
			Set tmpBaseObj = Nothing
			rs.MoveNext
		Loop
		
		LoadByCategoryID = m_ActivityLogs.Count
		
	End Function
	
	Public Function LoadByCategoryIDWChildren(p_Data)
	
		Dim SQLStr, rs, i
		Dim tmpBaseObj

		'If checkQueryID(p_Data, 0) > 0 Then
		
			SQLStr = "sp_Security_Activity_Log_SelectBy_Category_ID_And_Children '0" & p_Data & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			
			Do Until rs.EOF
				Set tmpBaseObj = New cls_ActivityLog
				
				tmpBaseObj.Load(rs("ID"))
				
				If Not m_ActivityLogs.Exists(tmpBaseObj) Then 
					m_ActivityLogs.Add tmpBaseObj, 0
				End If				
				Set tmpBaseObj = Nothing
				rs.MoveNext
			Loop
			
		'End If
		
		LoadByCategoryIDWChildren = m_ActivityLogs.Count
		
	End Function
	
	Private Function ClearAll()
		m_ActivityLogs.RemoveAll()
	End Function

End Class
%>
