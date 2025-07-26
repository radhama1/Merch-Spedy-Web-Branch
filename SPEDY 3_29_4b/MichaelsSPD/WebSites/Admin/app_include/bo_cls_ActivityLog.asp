<%
'==============================================================================
' CLASS: cls_ActivityLog
' Generated using CodeSmith on Tuesday, October 17, 2006
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with Activity Log. 
'
'	:: Properties
'	ID
'	Activity_User_ID
'	Activity_Type
'	Activity_Summary
'	Reference_ID
'	Reference_Type
'	Activity_Date
'
'	:: Methods
'	Load(p_ID)
'	Save()
'	Delete()
'
'==============================================================================
Class cls_ActivityLog
	'Private, class member variable
	Private MyBase
	Private utils
	Public ActivityLogEvents

	Private Sub Class_Initialize()
		Set MyBase = New cls_SecurityActivityLog
		Set utils = New cls_UtilityLibrary
		Set ActivityLogEvents = New cls_ActivityLogEventCollection
	End Sub

	Private Sub Class_Terminate()
		Set ActivityLogEvents = Nothing
		Set MyBase = Nothing
		Set utils = Nothing
	End Sub

	'Read the current ID value
	Public Property Get ID()
		ID = MyBase.ID
	End Property
	
	'Read the current Activity_User_ID value
	Public Property Get Activity_User_ID()
		Activity_User_ID = MyBase.Activity_User_ID
	End Property
	'store a new Activity_User_ID value
	Public Property Let Activity_User_ID(p_Data)
		MyBase.Activity_User_ID = p_Data
	End Property

	'Read the current Activity_Type value
	Public Property Get Activity_Type()
		Activity_Type = MyBase.Activity_Type
	End Property
	'store a new Activity_Type value
	Public Property Let Activity_Type(p_Data)
		MyBase.Activity_Type = p_Data
	End Property

	'Read the current Activity_Summary value
	Public Property Get Activity_Summary()
		Activity_Summary = MyBase.Activity_Summary
	End Property
	'store a new Activity_Summary value
	Public Property Let Activity_Summary(p_Data)
		MyBase.Activity_Summary = p_Data
	End Property

	'Read the current Reference_ID value
	Public Property Get Reference_ID()
		Reference_ID = MyBase.Reference_ID
	End Property
	'store a new Reference_ID value
	Public Property Let Reference_ID(p_Data)
		MyBase.Reference_ID = p_Data
	End Property

	'Read the current Reference_Type value
	Public Property Get Reference_Type()
		Reference_Type = MyBase.Reference_Type
	End Property
	'store a new Reference_Type value
	Public Property Let Reference_Type(p_Data)
		MyBase.Reference_Type = p_Data
	End Property

	'Read the current Activity_Date value
	Public Property Get Activity_Date()
		Activity_Date = MyBase.Activity_Date
	End Property
	'store a new Activity_Date value
	Public Property Let Activity_Date(p_Data)
		MyBase.Activity_Date = p_Data
	End Property

	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim retValue
		
		'If checkQueryID(p_ID, 0) > 0 Then
			retValue = MyBase.Load(p_ID)
			ActivityLogEvents.LoadByActivityLogID(p_ID)
		'Else
		'	retValue = 0	
		'End if
		
		Load = retValue
		
	End Function
	
    Public Function Save()
    
		'Save Activity
		MyBase.Save
			
		If ActivityLogEvents.Count > 0 Then
					
			'Save Activity Log Events
			ActivityLogEvents.Activity_Log_ID = MyBase.ID
			ActivityLogEvents.Save
			
		End If
		
		Save = MyBase.ID	

    End Function
	
	Public Function Delete()
		Delete = MyBase.Delete()
	End Function

End Class
%>
