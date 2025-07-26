<%
'==============================================================================
' CLASS: cls_ActivityType
' Generated using CodeSmith on Tuesday, October 17, 2006
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with the Activity Type class.  
'
'	:: Properties
'	Modify_ID
'	Create_ID
'	Delete_ID
'	Publish_ID
'	Copy_ID
'	Move_ID
'	Swap_ID
'	Promote_ID
'	Demote_ID
'	Login_ID
'
'==============================================================================
Class cls_ActivityType
	'Private, class member variable
	Private m_Modify_ID
	Private m_Create_ID
	Private m_Delete_ID
	Private m_Publish_ID
	Private m_Copy_ID
	Private m_Move_ID
	Private m_Swap_ID
	Private m_Promote_ID
	Private m_Demote_ID
	Private m_Login_ID

	Private Sub Class_Initialize()
		
		'Set IDs
		m_Modify_ID = 1
		m_Create_ID = 2
		m_Delete_ID = 3
		m_Publish_ID = 4
		m_Copy_ID = 5
		m_Move_ID = 6
		m_Swap_ID = 7
		m_Promote_ID = 8
		m_Demote_ID = 9
		m_Login_ID = 10
		
	End Sub

	Private Sub Class_Terminate()
		'Nothing To Do
	End Sub

	Public Property Get Modify_ID()
		Modify_ID = m_Modify_ID
	End Property
	
	Public Property Get Create_ID()
		Create_ID = m_Create_ID
	End Property
	
	Public Property Get Delete_ID()
		Delete_ID = m_Delete_ID
	End Property
	
	Public Property Get Publish_ID()
		Publish_ID = m_Publish_ID
	End Property
	
	Public Property Get Copy_ID()
		Copy_ID = m_Copy_ID
	End Property
	
	Public Property Get Move_ID()
		Move_ID = m_Move_ID
	End Property

	Public Property Get Swap_ID()
		Swap_ID = m_Swap_ID
	End Property
	
	Public Property Get Promote_ID()
		Promote_ID = m_Promote_ID
	End Property
	
	Public Property Get Demote_ID()
		Demote_ID = m_Demote_ID
	End Property
	
	Public Property Get Login_ID()
		Login_ID = m_Login_ID
	End Property
	
End Class
%>
