<%
'==============================================================================
' CLASS: cls_FilterSet
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'	m_FilterHeading			'Filter header
'	numDisplayPanesPerRow	'Number of panes to display per table row
'	Count
'	FilterPanes
'	GetPane
'
'	:: Methods
'	AddPane(p_FilterPane)
'	AddNewPane()
'	RemoveAll
'==============================================================================
Class cls_FilterSet
	'Private, class member variable
	Private m_ApplicationPath
	Private m_NumDisplayPanesPerRow
	Private m_FilterHeading
	Private m_FilterFrameCurrentHeight
	Private m_ParentFramesetName
	Private m_DimensionsPrefixString
	Private m_DimensionsSuffixString
	Private m_useEffects
	Private m_ScopeName
	Private m_ReferenceID
	Private m_FilterID
	Private utils
	Private m_FilterPanes

	Private Sub Class_Initialize()
		m_ApplicationPath			= "./"
		m_NumDisplayPanesPerRow		= 3
		m_FilterHeading				= "Filter Content"
		m_FilterFrameCurrentHeight	= "35"
		m_ParentFramesetName		= ""
		m_DimensionsPrefixString	= ""
		m_DimensionsSuffixString	= ""
		m_useEffects				= "false"
		m_ScopeName					= ""
		m_ReferenceID				= 0
		m_FilterID					= checkQueryID(Request("Filter_ID"), 0)
		
		Set m_FilterPanes		= Server.CreateObject("Scripting.Dictionary")
		Set utils				= New cls_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set m_FilterPanes	= Nothing
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
	
	'Get the NumDisplayPanesPerRow value
	Public Property Get NumDisplayPanesPerRow()
		NumDisplayPanesPerRow = m_NumDisplayPanesPerRow
	End Property
	'store a new NumDisplayPanesPerRow value
	Public Property Let NumDisplayPanesPerRow(p_Data)
		m_NumDisplayPanesPerRow = p_Data
	End Property
	
	'Get the FilterHeading value
	Public Property Get FilterHeading()
		FilterHeading = m_FilterHeading
	End Property
	'store a new FilterHeading value
	Public Property Let FilterHeading(p_Data)
		m_FilterHeading = p_Data
	End Property
	
	'Get the FilterFrameCurrentHeight value
	Public Property Get FilterFrameCurrentHeight()
		FilterFrameCurrentHeight = m_FilterFrameCurrentHeight
	End Property
	'store a new FilterFrameCurrentHeight value
	Public Property Let FilterFrameCurrentHeight(p_Data)
		m_FilterFrameCurrentHeight = p_Data
	End Property
		
	'Get the ParentFramesetName value
	Public Property Get ParentFramesetName()
		ParentFramesetName = m_ParentFramesetName
	End Property
	'store a new ParentFramesetName value
	Public Property Let ParentFramesetName(p_Data)
		m_ParentFramesetName = p_Data
	End Property

	'Get the DimensionsPrefixString value
	Public Property Get DimensionsPrefixString()
		DimensionsPrefixString = m_DimensionsPrefixString
	End Property
	'store a new DimensionsPrefixString value
	Public Property Let DimensionsPrefixString(p_Data)
		m_DimensionsPrefixString = p_Data
	End Property

	'Get the m_DimensionsSuffixString value
	Public Property Get DimensionsSuffixString()
		DimensionsSuffixString = m_DimensionsSuffixString
	End Property
	'store a new DimensionsSuffixString value
	Public Property Let DimensionsSuffixString(p_Data)
		m_DimensionsSuffixString = p_Data
	End Property
	
	'Get the useEffects value
	Public Property Get useEffects()
		useEffects = m_useEffects
	End Property
	'store a new useEffects value
	Public Property Let useEffects(p_Data)
		m_useEffects = p_Data
	End Property

	'Get the ScopeName value
	Public Property Get ScopeName()
		ScopeName = m_ScopeName
	End Property
	'store a new ScopeName value
	Public Property Let ScopeName(p_Data)
		m_ScopeName = p_Data
	End Property
	
	'Get the ReferenceID value
	Public Property Get ReferenceID()
		ReferenceID = m_ReferenceID
	End Property
	'store a new ReferenceID value
	Public Property Let ReferenceID(p_Data)
		m_ReferenceID = p_Data
	End Property
	
	'Get the Count value
	Public Property Get Count()
		Count = m_FilterPanes.Count
	End Property
	
	Public Property Get FilterPanes()
		Set FilterPanes = m_FilterPanes
	End Property
	
	'Gets a pane
	Public Property Get GetPane(p_Key)
		if m_FilterPanes.Exists(p_Key) then
			Set GetPane = m_FilterPanes.Item(p_Key)
		else
			Set GetPane = Nothing
		end if
	End Property
	
	'Adds an existing pane object
	Public Function AddPane(p_FilterPane)
		p_FilterPane.ApplicationPath = m_ApplicationPath
		p_FilterPane.ID	= CStr(m_FilterPanes.Count + 1)
		m_FilterPanes.Add CStr(m_FilterPanes.Count + 1), p_FilterPane
	End Function
	
	'Adds a new pane object
	Public Function AddNewPane()
		Dim FilterPaneObj
		
		Set FilterPaneObj = New cls_FilterPane
		FilterPaneObj.ApplicationPath = m_ApplicationPath
		FilterPaneObj.ID = CStr(m_FilterPanes.Count + 1)
		
		m_FilterPanes.Add CStr(m_FilterPanes.Count + 1), FilterPaneObj
		
		Set AddNewPane = m_FilterPanes.Item(CStr(m_FilterPanes.Count))
		Set FilterPaneObj = Nothing
	End Function
		
	'Removes all object from the dictionary
	Public Function RemoveAll()
		m_FilterPanes.RemoveAll()
	End Function
	
	Public Function Display()
		Dim rs
		Dim numDisplayPanes, numRows
		Dim curRowNum, cellCounter, curRowColCounter
		Dim curPane
		
		'Get Necessary Information
		numDisplayPanes = m_FilterPanes.Count
		numRows = Fix(numDisplayPanes/m_NumDisplayPanesPerRow) 
		If (numDisplayPanes Mod m_NumDisplayPanesPerRow) > 0 Then numRows = numRows + 1
		
		'Initialize Needed Variables
		curRowNum = 0
		cellCounter = 0
	
		'Begin Container Div
		Response.Write "<div id=""FrameDiv"">" & vbcrlf
		
		'Begin Display Header
		Response.Write	"<div class=""FilterSubHeaderText"" style=""width: auto; float: left;"">" & vbcrlf
		
		Response.Write 	"	<div style=""float: left;"">" & m_FilterHeading & "</div>" & vbcrlf
		
		Response.Write	"	<div  style=""float: left; margin-left: 15px;""><span class=""formElements"">Save current search as:</span></div>" & vbcrlf
		
		Response.Write	"	<div  style=""float: left; margin-left: 5px;""><input type=text name=""Save_Search_Name"" value="""" maxlength=""100"" class=""formElements""></div>" & vbcrlf
		
		'Get all saved searches
		Set rs = utils.LoadRSFromDB("sp_Filter_Select_By_User_Reference_Scope '0" & Session.Value("UserID") & "', '0" & m_ReferenceID & "', '" & m_ScopeName &  "'")
		
		'Loop through the searches
		if NOT rs.EOF then
			Response.Write	"	<div id=""Load_Saved_Search_Div"" style=""float: left; margin-left: 15px;"">" & vbcrlf & _
							"		<select id=""Select_Load_Saved_Search"" name=""Select_Load_Saved_Search"" class=""formElements"" onchange=""Load_Saved_Search(this.value);"">" & vbcrlf & _
							"			<option value=""0"">Load a Saved Search</option>" & vbcrlf

			Do Until rs.EOF
				Response.Write	"		<option value=""" & rs("ID") & """"
				
				if m_FilterID = SmartValues(rs("ID"), "CLng") then Response.Write " selected " 
				
				Response.Write	">" & rs("Filter_Name") & "</option>" & vbcrlf
							
				rs.MoveNext
			Loop
		
			Response.Write 	"		</select>" & vbcrlf & _
							"	</div>" & vbcrlf
							
			Response.Write	"	<div id=""Delete_Search_Div"" style=""float: left; margin-left: 7px;"
			if m_FilterID = 0 then Response.Write " display:none; "
			Response.Write	""">" & vbcrlf & _
							"		<a href="""" onclick=""DeleteSearch(); return false;""><img src=""" & m_ApplicationPath & "app_images/app_icons/trash.gif"" border=0></a>" & vbcrlf & _
							"	</div>" & vbcrlf
		end if
		
		Set rs = Nothing
						
		'End Display Header
		Response.Write	"</div>" & vbcrlf
		
		'Display Command Buttons
		Response.Write	"<div>" & vbcrlf & _
						"	<input type=button value="" Search "" name=""btnSubmit"" ID=""btnSubmit"" class=""btn"" onclick=""SubmitForm();"">" & vbcrlf & _
						"	<input type=button value=""Export xls"" name=""btnExport"" ID=""btnExport"" class=""btn"" onclick=""ExportCSV();"">" & vbcrlf & _
						"	<input type=hidden name=""excel"" value=""0"">" & vbcrlf & _
						"</div>" & vbcrlf
												
		'Begin Table
		Response.Write "<table border=0 cellpadding=0 cellspacing=0 class="""" style="""">" & vbcrlf
				
		'Display X Number of Rows
		Do Until cellCounter >= (m_NumDisplayPanesPerRow * numRows)
		
			'Initialize Variables
			curRowColCounter = 0
			curRowNum = curRowNum + 1
			
			'Begin Row
			Response.Write "<tr>" & vbcrlf
			
			'Display X Number of Panes
			Do Until curRowColCounter >= m_NumDisplayPanesPerRow
			
				cellCounter	= cellCounter + 1
				curRowColCounter = curRowColCounter + 1
				
				if m_FilterPanes.Exists(CStr(cellCounter)) then
					Set curPane = m_FilterPanes.Item(CStr(cellCounter))
		
					'Change the Class if it is the first column in it's row
					if curRowColCounter = 1 then
						curPane.Class_HTML = "filterVerbs leftVerb"
					end if
					
					'Display the pane
					curPane.Display()
					
					Set curPane = Nothing
				else	
					Response.Write "<td>&nbsp;</td>" & vbcrlf
				end if
				
			Loop 
			
			'Display Buttons to the right
			'if curRowNum = 1 Then
			'	Response.Write	"<td rowspan=" & (numRows * 2) - 1 & " valign=top style=""padding: 0; padding-left: 5px; padding-top: 4px; border-left: 1px solid #ececec;"">" & vbcrlf & _
			'					"<input type=button value=""   Search   "" name=""btnSubmit"" ID=""btnSubmit"" class=""btn"" style=""margin-bottom: 2px;"" onclick=""SubmitForm();"">" & vbcrlf & _
			'					"<input type=button value=""Export xls"" name=""btnExport"" ID=""btnExport"" class=""btn"" style=""margin-bottom: 2px;"" onclick=""ExportCSV();"">" & vbcrlf & _
			'					"<input type=hidden name=""excel"" value=""0"">" & vbcrlf & _
			'					"</td>" & vbcrlf
			'end If
			
			'End Row
			Response.Write "</tr>" & vbcrlf
			
			'Display A Spacer Row (only if it is not the last row)
			if curRowNum <> numRows then
				Response.Write "<tr><td colspan=" & m_NumDisplayPanesPerRow & " style=""border-bottom: 1px solid #ececec;""><img src=""./images/spacer.gif"" height=""10"" width=""1""></td></tr>" & vbcrlf
			end if
			
		Loop 
		
		'Display the total Panes
		Response.write "<input type=hidden id=""Num_Panes"" name=""Num_Panes"" value=""" & m_FilterPanes.Count & """>" & vbcrlf
		
		'End Table
		Response.Write "</table>" & vbcrlf
		
		'End Container Div
		Response.Write "</div>" & vbcrlf
				
		'Resize the screen if they loaded a filter
		if SmartValues(Request("Filter_ID"), "CStr") <> "" then
			Response.Write	"<script language=javascript>			" & vbcrlf & _
							"	determineAppropriateFrameSize();	" & vbcrlf & _
							"</script>								" & vbcrlf
		end if
		
		'This contains the hidden input field parameters for the chosen questions.
		Response.Write "<div id=""LastFilterDiv""></div>"
		
		Response.Flush()
		
	End Function
	
	Public Function DisplayJS()
		
		Dim curPaneSetCount, curPaneCounter, curPane
		Dim curQuestionSetCount, curQuestionCounter, curQuestion
		Dim curParameterSetCount, curParameterCounter, curParameter
		
		'Display the neccessary javascript functions needed	
		Response.Write	"<script language=""javascript"">" & vbcrlf
		
		Response.Write	"	var filterFrameCurrentHeight	= " & m_FilterFrameCurrentHeight & ";	// desired maximum height of filter frame when opened" & vbcrlf & _
						"	var ParentFramesetPath			= parent.frames;						// path up to frameset" & vbcrlf & _
						"	var ParentFramesetName			= """ & m_ParentFramesetName & """;		// id assigned to frameset"  & vbcrlf & _
						"	var FramesetType				= ""rows"";								// rows or cols" & vbcrlf & _
						"	var DimensionsPrefixString		= """ & m_DimensionsPrefixString & """;	// string to precede the filter frame dimension" & vbcrlf & _
						"	var DimensionsSuffixString		= """ & m_DimensionsSuffixString & """;	// string to follow the filter frame dimension" & vbcrlf & _
						"	var useEffects					= " & m_useEffects & "					// true or false" & vbcrlf
		
		'Filter Parameters
		Response.Write	"	var Parameters = new Array();			" & vbcrlf & _
						"	var Parameter = function( id, str )	{	" & vbcrlf & _
						"		this.id = id;						" & vbcrlf & _
						"		this.str = str;						" & vbcrlf & _
						"	}										" & vbcrlf
		
		curPaneSetCount = m_FilterPanes.Count
		curPaneCounter = 0
		
		'Loop through each pane
		Do Until curPaneCounter >= curPaneSetCount
		
			curPaneCounter = curPaneCounter + 1
			
			Set curPane = m_FilterPanes.Item(CStr(curPaneCounter))
	
			curQuestionSetCount = curPane.QuestionSet.Count()
			curQuestionCounter = 0
				
			'Loop through each question
			Do Until curQuestionCounter >= curQuestionSetCount
			
				curQuestionCounter = curQuestionCounter + 1
				
				Set curQuestion = curPane.QuestionSet.GetQuestion(CStr(curQuestionCounter))
				
				curParameterSetCount = curQuestion.FilterParameters.Count()
				curParameterCounter = 0
				
				'Display Parameter count
				Response.Write	"Parameters.push(""P" & curPane.ID & "_Q" & curQuestion.Value & "_PCount"");" & vbcrlf & _
								"Parameters[""P" & curPane.ID & "_Q" & curQuestion.Value & "_PCount""] = " & curParameterSetCount & ";" & vbcrlf
									
				'Loop through each parameter
				Do Until curParameterCounter >= curParameterSetCount
				
					curParameterCounter = curParameterCounter + 1
					
					Set curParameter = curQuestion.FilterParameters.GetParameter(CStr(curParameterCounter))
				
					Response.Write	"Parameters.push(""P" & curPane.ID & "_Q" & curQuestion.Value & "_P" & curParameter.ID & """);" & vbcrlf & _
									"Parameters[""P" & curPane.ID & "_Q" & curQuestion.Value & "_P" & curParameter.ID & """] = new Parameter('" & curParameter.Parameter_ID & "','" & Replace(curParameter.Parameter_Str, "'", "\'") & "');" & vbcrlf
				
					Set curParameter = Nothing
					
				Loop
				
				Set curQuestion = Nothing
												
			Loop
			
			Set curPane = Nothing
			
		Loop 
		
		Response.Write	"	function populateParameterContainerDiv() {													" & vbcrlf & _
						"		var DivName = 'LastFilterDiv';															" & vbcrlf & _
						"		var numPanes = " & m_FilterPanes.Count & ";												" & vbcrlf & _
						"		var selectedQuestionID;																	" & vbcrlf & _
						"		var numParameters;																		" & vbcrlf & _
						"		var hiddenInputFields = """";															" & vbcrlf & _
						"																								" & vbcrlf & _
						"		for(var i = 1; i <= numPanes; i++) {													" & vbcrlf & _
						"																								" & vbcrlf & _
						"			selectedQuestionID = eval('document.theForm.Select_Questions_' + i + '.value');		" & vbcrlf & _
						"																								" & vbcrlf & _
						"			numParameters = Parameters[""P"" + i + ""_Q"" + selectedQuestionID + ""_PCount""];	" & vbcrlf & _
						"																								" & vbcrlf & _
						"			if(numParameters > 0) {																																																				" & vbcrlf & _
						"				hiddenInputFields = hiddenInputFields + ""<input type=hidden id=\""QS"" + i + ""_PS"" + selectedQuestionID + ""_PCount\"" name=\""QS"" + i + ""_PS"" + selectedQuestionID + ""_PCount\"" value=\"""" + numParameters + ""\"">"";" & vbcrlf & _
						"			}																																																									" & vbcrlf & _
						"																																																												" & vbcrlf & _
						"			for(var j = 1; j <= numParameters; j++)																																																" & vbcrlf & _
						"			{																																																									" & vbcrlf & _
						"				curParameter = Parameters[""P"" + i + ""_Q"" + selectedQuestionID + ""_P"" + j];																																										" & vbcrlf & _
						"																																																																		" & vbcrlf & _
						"				hiddenInputFields = hiddenInputFields + ""<input type=hidden id=\""QS"" + i + ""_PS"" + selectedQuestionID + ""_PID"" + j + ""\"" name=\""QS"" + i + ""_PS"" + selectedQuestionID + ""_PID"" + j + ""\"" value=\"""" + curParameter.id + ""\"">"";		" & vbcrlf & _
						"				hiddenInputFields = hiddenInputFields + ""<input type=hidden id=\""QS"" + i + ""_PS"" + selectedQuestionID + ""_PStr"" + j + ""\"" name=\""QS"" + i + ""_PS"" + selectedQuestionID + ""_PStr"" + j + ""\"" value=\"""" + curParameter.str + ""\"">"";	" & vbcrlf & _
						"													" & vbcrlf & _
						"				curParameter = null;				" & vbcrlf & _
						"			}										" & vbcrlf & _
						"		}											" & vbcrlf & _
						"		$(DivName).innerHTML = hiddenInputFields;	" & vbcrlf & _
						"		hiddenInputFields = null;					" & vbcrlf & _
						"		numParameters = null;						" & vbcrlf & _
						"		//Parameters = null;						" & vbcrlf & _
						"		//Parameter = null;							" & vbcrlf & _
						"	}												" & vbcrlf
						
		Response.Write	"	function lengthenFilterFrame(newsize) { " & vbcrlf & _
						"		if (useEffects) { " & vbcrlf & _
						"			var FilterFrameTween = new Tween(new Object(),'',Tween.strongEaseOut,filterFrameCurrentHeight,newsize,1);" & vbcrlf & _
						"			FilterFrameTween.onMotionChanged = function(event){ " & vbcrlf & _
						"				resizeFrame(DimensionsPrefixString + Math.round(event.target._pos) + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);" & vbcrlf & _
						"			};" & vbcrlf & _
						"			FilterFrameTween.start();" & vbcrlf & _
						"		}" & vbcrlf & _
						"		else {" & vbcrlf & _
						"			resizeFrame(DimensionsPrefixString + newsize + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);" & vbcrlf & _
						"		}" & vbcrlf & _
						"	}" &vbcrlf
						
		Response.Write	"	function shortenFilterFrame(newsize) {" & vbcrlf & _
						"		if (useEffects)" & vbcrlf & _
						"		{" & vbcrlf & _
						"			var FilterFrameTween = new Tween(new Object(),'',Tween.strongEaseIn,filterFrameCurrentHeight,newsize,1);" & vbcrlf & _
						"			FilterFrameTween.onMotionChanged = function(event){" & vbcrlf & _
						"				resizeFrame(DimensionsPrefixString + Math.round(event.target._pos) + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);" & vbcrlf & _
						"			};" & vbcrlf & _
						"			FilterFrameTween.start();" & vbcrlf & _
						"		}" & vbcrlf & _
						"		else" & vbcrlf & _
						"		{" & vbcrlf & _
						"			resizeFrame(DimensionsPrefixString + newsize + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);" & vbcrlf & _
						"		}" & vbcrlf & _
						"	}" & vbcrlf
		
		Response.Write	"	function toggleChoiceDiv(Element_Name, selectedValue, DataSetTypeID) {	" & vbcrlf & _
						"		Element.hide($(Element_Name));										" & vbcrlf & _
						"		if(selectedValue > 1) {												" & vbcrlf & _
						"			Element.show($(Element_Name));									" & vbcrlf & _
						"		}																	" & vbcrlf & _
						"		determineAppropriateFrameSize();									" & vbcrlf & _
						"	}																		" & vbcrlf
						
		Response.Write	"	function showDatePicker(selectedElementID, selectedValue) {" & vbcrlf & _
						"		Element.hide($(""Date_Picker_"" + selectedElementID));" & vbcrlf & _
						"		Element.hide($(""StartDate_DatePicker_"" + selectedElementID));" & vbcrlf & _
						"		Element.hide($(""EndDate_DatePicker_"" + selectedElementID));" & vbcrlf & _
						"		switch(selectedValue) {" & vbcrlf & _
						"			case ""7"":" & vbcrlf & _
						"				Element.show($(""Date_Picker_"" + selectedElementID));" & vbcrlf & _
						"				Element.show($(""StartDate_DatePicker_"" + selectedElementID));" & vbcrlf & _
						"				break;" & vbcrlf & _
						"			case ""8"":" & vbcrlf & _
						"				Element.show($(""Date_Picker_"" + selectedElementID));" & vbcrlf & _
						"				Element.show($(""EndDate_DatePicker_"" + selectedElementID));" & vbcrlf & _
						"				break;" & vbcrlf & _
						"			case ""9"":" & vbcrlf & _
						"				Element.show($(""Date_Picker_"" + selectedElementID));" & vbcrlf & _
						"				Element.show($(""StartDate_DatePicker_"" + selectedElementID));" & vbcrlf & _
						"				Element.show($(""EndDate_DatePicker_"" + selectedElementID));" & vbcrlf & _
						"				break;" & vbcrlf & _
						"		}" & vbcrlf & _
						"		determineAppropriateFrameSize();" & vbcrlf & _
						"	}" & vbcrlf
						
		Response.Write	"	function dateWin(field)	{ " & _
						"		hwnd = window.open('" & m_ApplicationPath & "app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');" & vbcrlf & _
						"		hwnd.focus();" & vbcrlf & _
						"	}" & vbcrlf
		
		Response.Write	"	function determineAppropriateFrameSize(Element_Name) {" & vbcrlf & _
						"		var requiredSize = 1 * $(""FrameDiv"").getHeight() + 20;" & vbcrlf & _
						"		resizeFilterFrame(requiredSize);" & vbcrlf & _
						"	}" & vbcrlf
		
		Response.Write	"	function resizeFilterFrame(newsize) {" & vbcrlf & _
						"		if(!ParentFramesetPath) return false;" & vbcrlf & _
						"		if(!ParentFramesetPath.document) return false;" & vbcrlf & _
						"		if(!ParentFramesetPath.document.getElementById(ParentFramesetName)) return false;"  & vbcrlf & _
						"		var targetObject;" & vbcrlf & _
						"		if(FramesetType == ""rows"") {" & vbcrlf & _
						"			if(!ParentFramesetPath.document.getElementById(ParentFramesetName).rows) return false;" & vbcrlf & _
						"			targetObject = ParentFramesetPath.document.getElementById(ParentFramesetName).rows;" & vbcrlf & _
						"		}" & vbcrlf & _
						"		if(FramesetType == ""cols"") {" & vbcrlf & _
						"			if(!ParentFramesetPath.document.getElementById(ParentFramesetName).cols) return false;" & vbcrlf & _
						"			targetObject = ParentFramesetPath.document.getElementById(ParentFramesetName).cols;" & vbcrlf & _
						"		}" & vbcrlf & _
						"		if(newsize > filterFrameCurrentHeight) {" & vbcrlf & _
						"			lengthenFilterFrame(newsize);" & vbcrlf & _
						"		}" & vbcrlf & _
						"		if(newsize < filterFrameCurrentHeight) {" & vbcrlf & _
						"			shortenFilterFrame(newsize);" & vbcrlf & _
						"		}" & vbcrlf & _
						"		filterFrameCurrentHeight = newsize;" & vbcrlf & _
						"		ParentFramesetPath.FilterFrameHandle.filterFrameMaxHeight = newsize;" & vbcrlf & _
						"	}" & vbcrlf
		
		Response.Write	"	function SubmitForm() {" & vbcrlf & _
						"		populateParameterContainerDiv();" & vbcrlf & _
						"		document.theForm.excel.value = ""0"";" & vbcrlf & _
						"		document.theForm.submit();" & vbcrlf & _
						"	}" & vbcrlf

		Response.Write	"	function ExportCSV() {" & vbcrlf & _
						"		populateParameterContainerDiv();" & vbcrlf & _
						"		document.theForm.excel.value = ""1"";" & vbcrlf & _
						"		document.theForm.submit();" & vbcrlf & _
						"	}" & vbcrlf 

		Response.Write	"	function Load_Saved_Search(selectedValue) {" & vbcrlf & _
						"		var sLocation = document.location.toString();" & vbcrlf & _
						"		var sQuery = document.location.search.toString();" & vbcrlf & _
						"		var sFilterID;" & vbcrlf & _
						"		if(sQuery.length <= 1) {																" & vbcrlf & _
						"			sQuery = '?Filter_ID=' + selectedValue;												" & vbcrlf & _
						"		}																						" & vbcrlf & _
						"		else {																					" & vbcrlf & _
						"			sFilterID = sQuery.replace( /.*Filter_ID=([0-9]+).*/i,'$1' );						" & vbcrlf & _
						"			sQuery = sQuery.replace('&Filter_ID=' + sFilterID, '');								" & vbcrlf & _
						"			sQuery = sQuery.replace('Filter_ID=' + sFilterID, '');								" & vbcrlf & _
						"			if(sQuery.length <= 1) {															" & vbcrlf & _
						"				sQuery = '?Filter_ID=' + selectedValue;											" & vbcrlf & _
						"			}																					" & vbcrlf & _
						"			else {																				" & vbcrlf & _
						"				sQuery = sQuery + '&Filter_ID=' + selectedValue;								" & vbcrlf & _
						"			}																					" & vbcrlf & _
						"		}																						" & vbcrlf & _
						"		if(document.location.search.toString().length <= 1) {									" & vbcrlf & _
						"			sLocation = document.location.toString() + sQuery;									" & vbcrlf & _
						"		}																						" & vbcrlf & _
						"		else {																					" & vbcrlf & _
						"			sLocation = sLocation.replace(document.location.search.toString(), sQuery);			" & vbcrlf & _
						"		}																						" & vbcrlf & _
						"		document.location = sLocation;															" & vbcrlf & _
						"	}" & vbcrlf
						
		Response.Write	"	function DeleteSearch() {														" & vbcrlf & _
						"		if(confirm('Are you sure you want to delete this saved search?')) {			" & vbcrlf & _
						"			var fID = document.theForm.Select_Load_Saved_Search.value;				" & vbcrlf & _
						"			var newDocWin = window.open(""" & m_ApplicationPath & "app_include/filter_delete.asp?Filter_ID="" + fID, ""newDeleteWindow_"" + fID, ""width=200,height=200,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=0"");" & vbcrlf & _
						"			newDocWin.focus();														" & vbcrlf & _
						"		}																			" & vbcrlf & _
						"	}																				" & vbcrlf 
		
		Response.Write 	"	function getFrameHeight() {								" & vbcrlf & _
						"		return 1 * $(""FrameDiv"").getHeight();				" & vbcrlf & _
						"	}														" & vbcrlf
						
		Response.Write "</script>" & vbcrlf
		
		Response.Flush()

	End Function
End Class
%>
