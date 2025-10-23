<%
'==============================================================================
' CLASS: cls_FilterPaneChoiceSet
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'	Name
'	Class_HTML
'	Style_HTML
'	Type_ID
'	Count
'	Choices
'	GetChoice
'
'	:: Methods
'	AddChoice(p_PaneChoice)
'	AddNewChoice()
'	Remove
'	RemoveAll
'
'==============================================================================
Class cls_FilterPaneChoiceSet
	'Private, class member variable
	Private m_ApplicationPath
	Private m_ID
	Private m_Class_HTML
	Private m_Style_HTML
	Private m_Multiple_HTML
	Private m_Max_Length
	Private m_Type_ID
	Private m_SQL_String
	Private m_SQL_ID
	Private m_SQL_Text
	Private utils
	Private m_ChoiceSet
	Private m_DataSet_Type

	Private Sub Class_Initialize()
		Set m_ChoiceSet		= Server.CreateObject("Scripting.Dictionary")
		Set m_DataSet_Type	= New cls_FilterPaneChoiceSetType
		Set utils			= New cls_UtilityLibrary
		
		m_ApplicationPath	= "./"
		m_ID				= ""
		m_Class_HTML		= "formElements"
		m_Multiple_HTML		= "multiple=""true"""
		m_Style_HTML		= "width: 200px;"
		m_Max_Length		= "500"
		m_Type_ID			= m_DataSet_Type.LIST
		m_SQL_ID			= ""
		m_SQL_Text			= ""
		m_SQL_String		= ""
		
	End Sub

	Private Sub Class_Terminate()
		Set m_ChoiceSet		= Nothing
		Set m_DataSet_Type	= Nothing
		Set utils			= Nothing
	End Sub
	
	'Get the ApplicationPath value
	Public Property Get ApplicationPath()
		ApplicationPath = m_ApplicationPath
	End Property
	'store a new ApplicationPath value
	Public Property Let ApplicationPath(p_Data)
		m_ApplicationPath = p_Data
	End Property
	
	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property

	'Read the current Class_HTML value
	Public Property Get Class_HTML()
		Class_HTML = m_Class_HTML
	End Property
	'store a new Class_HTML value
	Public Property Let Class_HTML(p_Data)
		m_Class_HTML = p_Data
	End Property
	
	'Read the current List_Multiple_HTML value
	Public Property Get List_Multiple_HTML()
		List_Multiple_HTML = m_Multiple_HTML
	End Property
	'store a new List_Multiple_HTML value
	Public Property Let List_Multiple_HTML(p_Data)
		m_Multiple_HTML = p_Data
	End Property
	
	'Read the current Style_HTML value
	Public Property Get Style_HTML()
		Style_HTML = m_Style_HTML
	End Property
	'store a new Style_HTML value
	Public Property Let Style_HTML(p_Data)
		m_Style_HTML = p_Data
	End Property
	
	'Read the current Type_ID value
	Public Property Get Type_ID()
		Type_ID = m_Type_ID
	End Property
	'store a new Type_ID value
	Public Property Let Type_ID(p_Data)
		
		Dim rs
		RemoveAll()
		
		Select Case p_Data
		
			Case m_DataSet_Type.TEXT
				m_Type_ID = m_DataSet_Type.TEXT
				AddChoiceWValues "", ""
				
			Case m_DataSet_Type.DATE_TIME
				m_Type_ID = m_DataSet_Type.DATE_TIME
			
			Case m_DataSet_Type.DB_LOOKUP
				
				if m_SQL_String <> "" then
			
					Set rs = utils.LoadRSFromDB(m_SQL_String)
					
					Do until rs.EOF
					
						if m_SQL_ID = "" OR m_SQL_Text = "" then
							AddChoiceWValues rs(0), rs(1)
						else
							AddChoiceWValues rs(m_SQL_ID), rs(m_SQL_Text)
						end if
						
						rs.MoveNext()
					Loop
					
					Set rs = nothing
				end if
				
				m_Type_ID = m_DataSet_Type.DB_LOOKUP
			
			Case Else
				m_Type_ID = m_DataSet_Type.LIST
		End Select
		
	End Property
	
	'Read the current SQL_String value
	Public Property Get SQL_String()
		SQL_String = m_SQL_String
	End Property
	'store a new SQL_String value
	Public Property Let SQL_String(p_Data)
	
		Dim rs
		
		if m_Type_ID = m_DataSet_Type.DB_LOOKUP then
			
			RemoveAll()
			
			Set rs = utils.LoadRSFromDB(p_Data)
			
			Do until rs.EOF
			
				if m_SQL_ID = "" OR m_SQL_Text = "" then
					AddChoiceWValues rs(0), rs(1)
				else
					AddChoiceWValues rs(m_SQL_ID), rs(m_SQL_Text)
				end if
				
				rs.MoveNext()
			Loop
			
			Set rs = nothing
	
		end if
		
		m_SQL_String = p_Data
		
	End Property
	
	'Read the current SQL_ID value
	Public Property Get SQL_ID()
		SQL_ID = m_SQL_ID
	End Property
	'store a new SQL_ID value
	Public Property Let SQL_ID(p_Data)
		m_SQL_ID = p_Data
	End Property
	
	'Read the current SQL_Text value
	Public Property Get SQL_Text()
		SQL_Text = m_SQL_Text
	End Property
	'store a new SQL_Text value
	Public Property Let SQL_Text(p_Data)
		m_SQL_Text = p_Data
	End Property
	
	'Get the Count value
	Public Property Get Count()
		Count = m_ChoiceSet.Count
	End Property
	
	'Get all choices
	Public Property Get Choices()
		Set Choices = m_ChoiceSet
	End Property
	
	'Gets a choice
	Public Property Get GetChoice(p_Key)
		if m_ChoiceSet.Exists(p_Key) then
			Set GetChoice = m_ChoiceSet.Item(p_Key)
		else
			Set GetChoice = Nothing
		end if
	End Property
	
	'Adds an existing choice object
	Public Function AddChoice(p_PaneChoice)
		p_PaneChoice.ID = CStr(m_ChoiceSet.Count + 1)
		m_ChoiceSet.Add CStr(m_ChoiceSet.Count + 1), p_PaneChoice
	End Function
	
	'Adds a new Choice object
	Public Function AddNewChoice()
		Dim ChoiceObj
		
		Set ChoiceObj = New cls_FilterPaneChoice
		ChoiceObj.ID = CStr(m_ChoiceSet.Count + 1)
		ChoiceObj.Value = CStr(m_ChoiceSet.Count + 1)
		m_ChoiceSet.Add CStr(m_ChoiceSet.Count + 1), ChoiceObj
		
		Set AddNewChoice = m_ChoiceSet.Item(CStr(m_ChoiceSet.Count))
		Set ChoiceObj = Nothing
	End Function
	
	Private Function AddChoiceWValues(p_Value, p_Text)
	
		Dim ChoiceObj
		
		Set ChoiceObj = New cls_FilterPaneChoice
		ChoiceObj.ID = CStr(m_ChoiceSet.Count + 1)
		ChoiceObj.Value = SmartValues(p_Value, "CStr")
		ChoiceObj.Text = SmartValues(p_Text, "CStr")
		m_ChoiceSet.Add CStr(m_ChoiceSet.Count + 1), ChoiceObj
		
		Set ChoiceObj = Nothing
	End Function
	
	'Removes all object from the dictionary
	Public Function RemoveAll()
		m_ChoiceSet.RemoveAll()
	End Function
	
	Public Function Display()
	
		Dim rs, divHideStr
		Dim curWhenIndex, curWhenArray(9), savedWhen, datePickerShowHide, startDateShowHide, endDateShowHide
		Dim savedStartDate, savedStartTime, savedEndDate, savedEndTime
		Dim Counter, CurChoice
		
		'Initialize Variables
		Counter = 0
	
		'Check to see if the choice div needs to be displayed initially
		Set rs = utils.LoadRSFromDB("sp_Filter_Question_Select_By_FilterID_Ordinal '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "'")
		
			if rs.EOF then
				divHideStr = " display:none; "
			else
				divHideStr = ""
			end if
			
		Set rs = Nothing
		
		'Begin Display of Choices
		Response.Write  "<div id=""Div_Choices_" & m_ID & """ class=""bodyText"" style=""margin-top: 5px; " & divHideStr & """>" & vbcrlf
		
		'Display Choice according to its type
		Select Case m_Type_ID
			Case m_DataSet_Type.TEXT
				if m_ChoiceSet.Exists("1") then
					Set curChoice = m_ChoiceSet.Item("1")
					Response.Write "<input type=""text"" name=""Text_Choices_" & m_ID & """ id=""Text_Choices_" & m_ID & """ "
					CurChoice.Display m_Type_ID, m_ID
					Response.Write " maxlength=""" & m_Max_Length & """ autocomplete=""off"" class=""" & m_Class_HTML & """ style=""" & m_Style_HTML & """>" & vbcrlf
					Set CurChoice = Nothing
				end if
								
			Case m_DataSet_Type.DATE_TIME
				
				'Initialize Variables
				datePickerShowHide = "display: none;"
				startDateShowHide = "display: none;"
				endDateShowHide = "display: none;"
				savedWhen = 0
				savedStartDate = "Start Date"
				savedStartTime = ""
				savedEndDate = "End Date"
				savedEndTime = ""
				
				'Get selected when
				Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 1")
					if Not rs.EOF then
						savedWhen =  SmartValues(rs("Value"), "CInt")
					end if
				Set rs = Nothing
				
				'Set array values to selected value
				for curWhenIndex = 1 to UBound(curWhenArray)
				
					curWhenArray(curWhenIndex) = ""
					
					if curWhenIndex = savedWhen then
						curWhenArray(curWhenIndex) = " selected "				
					end if
										
				next
				
				'Determine if start/end date will be shown (On or After this date, on or before this date, between these dates)
				if savedWhen >= 7 then
					datePickerShowHide = ""
					
					if savedWhen = 7 then
						
						startDateShowHide  = ""
						
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 2")
						if not rs.EOF then
							savedStartDate = SmartValues(rs("Value"), "CStr")
						end if
						
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 3")
						if not rs.EOF then
							savedStartTime = FormatDateTime(SmartValues(rs("Value"), "CStr"), vbLongTime)
						end if
						
						Set rs = nothing
				
					elseif savedWhen = 8 then
						
						endDateShowHide  = ""
						
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 4")
						if not rs.EOF then
							savedEndDate = SmartValues(rs("Value"), "CStr")
						end if
						
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 5")
						if not rs.EOF then
							savedEndTime = FormatDateTime(SmartValues(rs("Value"), "CStr"), vbLongTime)
						end if
						
						Set rs = nothing
						
					elseif savedWhen = 9 then
					
						startDateShowHide  = ""
						endDateShowHide  = ""
						
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 2")
						if not rs.EOF then
							savedStartDate = SmartValues(rs("Value"), "CStr")
						end if
						
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 3")
						if not rs.EOF then
							savedStartTime = SmartValues(rs("Value"), "CStr")
						end if
											
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 4")
						if not rs.EOF then
							savedEndDate = SmartValues(rs("Value"), "CStr")
						end if
						
						Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_ChoiceTypeID '0" & checkQueryID(Request("Filter_ID"), 0) & "', '0" & m_ID & "', 5")
						if not rs.EOF then
							savedEndTime = SmartValues(rs("Value"), "CStr")
						end if
						
						Set rs = nothing
					end if
					
				end if
				
				'Display the Select When
				Response.Write	"<select id=""Select_When_" & m_ID & """ name=""Select_When_" & m_ID & """ class=""" & m_Class_HTML & """ onchange=""showDatePicker('" & m_ID & "', this.value);"" style=""" & m_Style_HTML & """>" & vbcrlf & _
								"	<option value=""1"" " & curWhenArray(1) & ">Today</option>" & vbcrlf & _
								"	<option value=""2"" " & curWhenArray(2) & ">This Week</option>" & vbcrlf & _
								"	<option value=""3"" " & curWhenArray(3) & ">This Month</option>" & vbcrlf & _
								"	<option value=""4"" " & curWhenArray(4) & ">Yesterday</option>" & vbcrlf & _
								"	<option value=""5"" " & curWhenArray(5) & ">Last Week</option>" & vbcrlf & _
								"	<option value=""6"" " & curWhenArray(6) & ">Last Month</option>" & vbcrlf & _
								"	<option value=""7"" " & curWhenArray(7) & ">On or After this Date…</option>" & vbcrlf & _
								"	<option value=""8"" " & curWhenArray(8) & ">On or Before this Date…</option>" & vbcrlf & _
								"	<option value=""9"" " & curWhenArray(9) & ">Between these Dates…</option>" & vbcrlf & _
								"</select>" & vbcrlf
				
				
				'Display the Date Picker Div
				Response.Write	"<div id=""Date_Picker_" & m_ID & """ class=""bodyText"" style=""margin-top: 5px; " & datePickerShowHide & """>" & vbcrlf
				
				'Display the Start Date Div
				Response.Write 	"	<div id=""StartDate_DatePicker_" & m_ID & """ class=""bodyText"" style=""" & startDateShowHide & """>" & vbcrlf & _
								"	<a href=""javascript: dateWin('txtStartDate_" & m_ID & "');""><img src=""" & m_ApplicationPath & "app_images/mini_calendar.gif"" border=0 alt=""Click here to select your date from a calendar""></a>" & vbcrlf & _
								"	<input type=text name=""txtStartDate_" & m_ID & """ id=""txtStartDate_" & m_ID & """ value=""" & savedStartDate & """ size=10 maxlength=10 autocomplete=""off"" onblur=""if(!isDate(this.value)){this.value='Start Date'}"" onfocus=""if(this.value=='Start Date'){this.value=''}"" class=""formElements"">" & vbcrlf & _
								"	<select name=""txtStartTime_" & m_ID & """ id=""txtStartTime_" & m_ID & """ class=""formElements"">" & vbcrlf
				
				For Counter = 0 to 23
					if len(savedStartTime) > 0 then
						
						if savedStartTime = FormatDateTime(Counter & ":00", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":00", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":00", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
						if savedStartTime = FormatDateTime(Counter & ":15", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":15", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":15", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
						if savedStartTime = FormatDateTime(Counter & ":30", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":30", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":30", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
						if savedStartTime = FormatDateTime(Counter & ":45", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":45", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":45", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
					else
					
						Response.Write	"	<option value=""" & FormatDateTime(Counter & ":00", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf & _
										"	<option value=""" & FormatDateTime(Counter & ":15", vbLongTime) & """>" & FormatDateTime(Counter & ":15", vbLongTime) & "</option>" & vbcrlf & _
										"	<option value=""" & FormatDateTime(Counter & ":30", vbLongTime) & """>" & FormatDateTime(Counter & ":30", vbLongTime) & "</option>" & vbcrlf & _
										"	<option value=""" & FormatDateTime(Counter & ":45", vbLongTime) & """>" & FormatDateTime(Counter & ":45", vbLongTime) & "</option>" & vbcrlf
									
					end if
			
				Next
				
				Response.Write	"	</select>" & vbcrlf & _
								"	</div>" & vbcrlf
				
				'Display the End Date Div
				Response.Write 	"	<div id=""EndDate_DatePicker_" & m_ID & """ class=""bodyText"" style=""" & endDateShowHide & """>" & vbcrlf & _
								"	<a href=""javascript: dateWin('txtEndDate_" & m_ID & "');""><img src=""" & m_ApplicationPath & "app_images/mini_calendar.gif"" border=0 alt=""Click here to select your date from a calendar""></a>" & vbcrlf & _
								"	<input type=text name=""txtEndDate_" & m_ID & """ id=""txtEndDate_" & m_ID & """ value=""" & savedEndDate & """ size=10 maxlength=10 autocomplete=""off"" onblur=""if(!isDate(this.value)){this.value='End Date'}"" onfocus=""if(this.value=='End Date'){this.value=''}"" class=""formElements"">" & vbcrlf & _
								"	<select name=""txtEndTime_" & m_ID & """ id=""txtEndTime_" & m_ID & """ class=""formElements"">" & vbcrlf
				
				For Counter = 0 to 23
				
					if len(savedEndTime) > 0 then
						
						if savedEndTime = FormatDateTime(Counter & ":00", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":00", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":00", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
						if savedEndTime = FormatDateTime(Counter & ":15", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":15", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":15", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
						if savedEndTime = FormatDateTime(Counter & ":30", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":30", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":30", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
						if savedEndTime = FormatDateTime(Counter & ":45", vbLongTime) then
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":45", vbLongTime) & """ selected>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
							savedStartTime = ""
						else
							Response.Write	"	<option value=""" & FormatDateTime(Counter & ":45", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf
						end if
						
					else
					
						Response.Write	"	<option value=""" & FormatDateTime(Counter & ":00", vbLongTime) & """>" & FormatDateTime(Counter & ":00", vbLongTime) & "</option>" & vbcrlf & _
										"	<option value=""" & FormatDateTime(Counter & ":15", vbLongTime) & """>" & FormatDateTime(Counter & ":15", vbLongTime) & "</option>" & vbcrlf & _
										"	<option value=""" & FormatDateTime(Counter & ":30", vbLongTime) & """>" & FormatDateTime(Counter & ":30", vbLongTime) & "</option>" & vbcrlf & _
										"	<option value=""" & FormatDateTime(Counter & ":45", vbLongTime) & """>" & FormatDateTime(Counter & ":45", vbLongTime) & "</option>" & vbcrlf
									
					end if
		
				Next
				
				Response.Write	"	</select>" & vbcrlf & _
								"	</div>" & vbcrlf & _
								"</div>" & vbcrlf
				
			Case m_DataSet_Type.LIST, m_DataSet_Type.DB_LOOKUP
			
				if m_ChoiceSet.Count > 0 then
					Response.Write 	"<select name=""Select_Choices_" & m_ID & """ class=""" & m_Class_HTML & """ " & m_Multiple_HTML & " size=""5"" style=""" & m_Style_HTML & """>" & vbcrlf
					
					'Display Each Choice
					Do Until Counter >= m_ChoiceSet.Count
					
						Counter	= Counter + 1
						
						if m_ChoiceSet.Exists(CStr(Counter)) then
							Set CurChoice = m_ChoiceSet.Item(CStr(Counter))
							CurChoice.Display m_Type_ID, m_ID
							Set CurChoice = Nothing
						end if
							
					Loop
					
					Response.Write "</select>" & vbcrlf
				end if
		
		End Select
		
		'End Display of Choices
		Response.Write "</div>" & vbcrlf
	
		
	End Function

End Class
%>
