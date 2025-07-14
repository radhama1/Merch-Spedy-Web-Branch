<%
'==============================================================================
' CLASS: cls_FilterPaneChoiceSetType
' By Oscar.Treto
'==============================================================================
'
' This object represents properties and methods for interacting with Activity Log. 
'
'	:: Properties
'	TEXT
'	DATE_TIME
'	LIST
'	DB_LOOKUP
'
'	:: Methods
'
'==============================================================================
Class cls_FilterPaneChoiceSetType
	'Private, class member variable
	Private m_TEXT
	Private m_DATE_TIME
	Private m_LIST
	Private m_DB_LOOKUP

	Private Sub Class_Initialize()
		m_TEXT		= 1
		m_DATE_TIME	= 2
		m_LIST		= 3
		m_DB_LOOKUP = 4
	End Sub

	Private Sub Class_Terminate()
		
	End Sub

	'Read the TEXT value
	Public Property Get TEXT()
		TEXT = m_TEXT
	End Property

	'Read the DATE_TIME value
	Public Property Get DATE_TIME()
		DATE_TIME = m_DATE_TIME
	End Property
	
	'Read the LIST value
	Public Property Get LIST()
		LIST = m_LIST
	End Property
	
	'Read the DB_LOOKUP value
	Public Property Get DB_LOOKUP()
		DB_LOOKUP = m_DB_LOOKUP
	End Property

End Class
%>
