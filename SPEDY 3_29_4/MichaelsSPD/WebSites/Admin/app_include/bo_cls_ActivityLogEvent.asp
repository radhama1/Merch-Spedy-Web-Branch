<%
'==============================================================================
' CLASS: cls_ActivityLogEvent
' Generated using CodeSmith on Tuesday, October 17, 2006
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with the ActivityLogEvent class.  
'
'	:: Properties
'	ID
'	Activity_Log_ID
'	Summary
'
'	:: Methods
'	Load(p_ID)
'	Save()
'	Delete()
'
'==============================================================================
Class cls_ActivityLogEvent
	'Private, class member variable
	Private MyBase
	Private utils

	Private Sub Class_Initialize()
		Set MyBase = New cls_SecurityActivityLogEvent
		Set utils = New cls_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set MyBase = Nothing
		Set utils = Nothing
	End Sub

	'Read the current ID value
	Public Property Get ID()
		ID = MyBase.ID
	End Property

	'Read the current Activity_Log_ID value
	Public Property Get Activity_Log_ID()
		Activity_Log_ID = MyBase.Activity_Log_ID
	End Property
	'store a new Activity_Log_ID value
	Public Property Let Activity_Log_ID(p_Data)
		MyBase.Activity_Log_ID = p_Data
	End Property

	'Read the current Summary value
	Public Property Get Summary()
		Summary = MyBase.Summary
	End Property
	'store a new Summary value
	Public Property Let Summary(p_Data)
		MyBase.Summary = p_Data
	End Property

	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		MyBase.Load(p_ID)
	End Function

	Public Function Hydrate(rs)
		If Not rs.EOF Then
			MyBase.ID = SmartValues(rs("ID"), "CLng")
			MyBase.Activity_Log_ID = SmartValues(rs("Activity_Log_ID"), "CLng")
			MyBase.Summary = SmartValues(rs("Summary"), "CStr")
		End If
	End Function
	
    Public Function Save()
		Save = MyBase.Save
    End Function
	
	Public Function Delete()
		Delete = MyBase.Delete()
	End Function

End Class
%>
