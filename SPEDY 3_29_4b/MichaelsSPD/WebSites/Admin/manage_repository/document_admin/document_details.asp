<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.CONTENT.REPOSITORY.ITEM", checkQueryID(Request("tid"), 0)

Dim categoryID, topicID, boolIsNewDocument
Dim winTitle, defaultContent, defaultLanguageOrdinal, showLangOrdinal
Dim objConn, objRec, objRec2, SQLStr, connStr, i, rowcolor
Dim Topic_Name, Topic_Byline, Topic_Summary, Topic_Type, isEnabled, curLangOrdinal
Dim Topic_ContactInfo, Topic_SourceWebsite
Dim UserDefinedField1, UserDefinedField2, UserDefinedField3, UserDefinedField4, UserDefinedField5
Dim Topic_Abstract, Topic_Keywords
Dim Type1_FileName, Type1_FileID, Type2_LinkURL
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime
Dim topicLanguageID, masterLanguageID
Dim isDefault, boolIsPublishedItemCopy
Dim	Editor
Dim thisUserDefinedField, arThisUserDefinedField

Dim rowCounter, curIteration
Dim arLanguagesDataRows, dictLanguagesDataCols
Dim arDataRows, dictDataCols
Dim arTopicDataRows, dictTopicDataCols
Dim arScheduleDataRows, dictScheduleDataCols

Dim boolUseSchedule, boolUseStartDate, boolUseEndDate

Set dictDataCols			= Server.CreateObject("Scripting.Dictionary")
Set dictLanguagesDataCols	= Server.CreateObject("Scripting.Dictionary")
Set dictTopicDataCols		= Server.CreateObject("Scripting.Dictionary")
Set dictScheduleDataCols	= Server.CreateObject("Scripting.Dictionary")

categoryID = Request("cid")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

curLangOrdinal = Trim(Request("curlangord"))
if IsNumeric(curLangOrdinal) and Trim(curLangOrdinal) <> "" then
	curLangOrdinal = CInt(curLangOrdinal)
else
	curLangOrdinal = -1
end if

boolIsPublishedItemCopy = Trim(Request("pub"))
if IsNumeric(boolIsPublishedItemCopy) then
	boolIsPublishedItemCopy = CBool(boolIsPublishedItemCopy)
else
	boolIsPublishedItemCopy = false
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

SQLStr = "sp_repository_languages_return_enabled " & topicID
Call returnDataWithGetRows(connStr, SQLStr, arLanguagesDataRows, dictLanguagesDataCols)

if topicID = 0 then
	boolIsNewDocument = true
	defaultContent = ""

	if dictLanguagesDataCols("RecordCount") > 0 then
		for i = 0 to dictLanguagesDataCols("RecordCount") - 1
			if CBool(arLanguagesDataRows(dictLanguagesDataCols("isDefault"), i)) then
				defaultLanguageOrdinal = i + 1
			end if
		next
	else
		defaultLanguageOrdinal = 1
	end if
else
	boolIsNewDocument = false

	SQLStr = "sp_repository_topic_content_by_topicID " & topicID
	Call returnDataWithGetRows(connStr, SQLStr, arTopicDataRows, dictTopicDataCols)

	SQLStr = "sp_repository_topic_schedule_by_topicID " & topicID
	Call returnDataWithGetRows(connStr, SQLStr, arScheduleDataRows, dictScheduleDataCols)

	if dictTopicDataCols("RecordCount") > 0 then
		for i = 0 to dictTopicDataCols("RecordCount") - 1
			if CBool(arTopicDataRows(dictTopicDataCols("Default_Language"), i)) then
				defaultLanguageOrdinal = i + 1
				winTitle = Server.HTMLEncode(SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Name"), i), "CStr"))
				
				defaultContent = stripTextSizes(SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Summary"), i), "CStr"))
			'	defaultContent = SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Summary"), i), "CStr")
			end if
		next
	else
		defaultLanguageOrdinal = 1
	end if
end if
if not boolIsPublishedItemCopy and not boolIsNewDocument then
	SQLStr = "sp_toggle_topic_lock " & topicID & ", " & CLng(Session.Value("UserID")) & ", 1"
	Set objRec = objConn.Execute(SQLStr)
end if
%>
<html>
<head>
	<title><%if boolIsNewDocument then%>Add Document<%else%>Edit Document:&nbsp;&nbsp;"<%=winTitle%>"<%end if%></title>
	<style type="text/css">

		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#ffffff"; 
			scrollbar-shadow: "#999999";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#ececec";
			scrollbar-darkshadow-color: "#000000";
			cursor: default;
			font-family: Arial, Verdana, Geneva, Helvetica;
			font-size: 11px;
		}
		.langOption_Selected
		{
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:11px;
			color:#ffffff;
			cursor: hand;
		}
		.langOption
		{
			font-family:Arial, Verdana, Geneva, Helvetica;
			font-size:11px;
			color:#000000;
			cursor: hand;
		}
		#embeddedTags {border:1px !important; font-family:Arial, Helvetica;font-size:30px;color:#0000ff;line-height:18px;}

	</style>
	<script language="javascript" src="./../../app_include/evaluator.js"></script>
	<script language=javascript>
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function preloadImgs()
		{
			if (document.images)
			{		
				langSelectorOn = new Image(12, 12);
				langSelectorOff = new Image(12, 12);

				langSelectorOn.src = "../images/lang_selector.gif";
				langSelectorOff.src = "../images/spacer.gif";
			}
		}

		function initTabs(thisTabName)
		{
			clearMenus();
			switch (thisTabName)
			{
				case "contentTab":
					workspace_content.style.display = "";
					break;
				
				case "securityTab":
					workspace_security.style.display = "";
					break;
				
				case "customdataTab":
					workspace_customdata.style.display = "";
					break;

				case "scheduleTab":
					workspace_schedule.style.display = "";
					break;
			}
		}
	
		function clickMenu(tabName)
		{
			saveChanges();
			showhideDirtyContentFlag(intPrevSelectedLanguageID, checkContentState(intPrevSelectedLanguageID));
			clearMenus();

			switch (tabName)
			{
				case "contentTab":
					workspace_content.style.display = "";
					break;
				
				case "securityTab":
					workspace_security.style.display = "";
					initDataLayout(10);
					doLoad();
					break;
				
				case "customdataTab":
					workspace_customdata.style.display = "";
					break;

				case "scheduleTab":
					workspace_schedule.style.display = "";
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			workspace_content.style.display = "none";
			workspace_security.style.display = "none";
			workspace_customdata.style.display = "none";
			workspace_schedule.style.display = "none";
		}
		
		var intPrevSelectedLanguageID = 0;
		
		
		//This function is a combination of showContent() and replaceEditableContent(), and this function is only displayed onLoad.
		//This is to avoid ActiveEdit errors, which would occur should objects load in the window out of the
		//anticipated order (this happens for some dumb reason in IE6).
		function initContent(selectedID)
		{
			if (selectedID >= 0)
			{
				changeSelectedLangColor(selectedID, true);
				intPrevSelectedLanguageID = selectedID;
			
				document.theForm.Topic_Name.value = eval("document.theForm.lang" + selectedID + "_dirty_title.value");
				document.theForm.Topic_Byline.value = eval("document.theForm.lang" + selectedID + "_dirty_byline.value");
				if (isMac)
				{
					document.theForm.Topic_Summary.value = eval("document.theForm.lang" + selectedID + "_dirty_content.value");
				}
				
				document.theForm.Topic_Name.focus();
			
				if(eval("document.theForm.lang" + selectedID + "_dirty_boolDefault.value") == "1")
				{
					document.theForm.boolDefault.checked = true;
					document.theForm.boolDefault.disabled = true;
				}
				else
				{
					document.theForm.boolDefault.checked = false;
					document.theForm.boolDefault.disabled = false;
				}
				
				document.theForm.Type1_FileName.value = eval("document.theForm.lang" + selectedID + "_dirty_filename.value");
				document.theForm.Type1_FileID.value = eval("document.theForm.lang" + selectedID + "_dirty_fileID.value");
				document.theForm.Type2_URL.value = eval("document.theForm.lang" + selectedID + "_dirty_url.value");
				document.theForm.Topic_ContactInfo.value = eval("document.theForm.lang" + selectedID + "_dirty_topic_contactinfo.value");
				document.theForm.Topic_SourceWebsite.value = eval("document.theForm.lang" + selectedID + "_dirty_topic_sourcewebsite.value");
				<%if 1 = 2 then%>
				document.theForm.UserDefinedField1.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield1.value");
				document.theForm.UserDefinedField2.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield2.value");
				document.theForm.UserDefinedField3.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield3.value");
				document.theForm.UserDefinedField4.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield4.value");
				document.theForm.UserDefinedField5.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield5.value");
				<%end if%>
				document.theForm.Topic_Abstract.value = eval("document.theForm.lang" + selectedID + "_dirty_abstract.value");
				document.theForm.Topic_Keywords.value = eval("document.theForm.lang" + selectedID + "_dirty_keywords.value");

				docFileNameLyr.style.display = "";
				docURLLyr.style.display = "";
				document.theForm.Topic_Type.selectedIndex = eval("document.theForm.lang" + selectedID + "_dirty_type.value");
				showhideDocTypeDetails();

				document.theForm.Topic_Name.focus();
			}
			else
			{
				changeSelectedLangColor(<%=defaultLanguageOrdinal%>, true);
			}
			setDefaultLanguage();
 		}

		//DO NOT call showContent() in the BODY onLoad event handler.
		function showContent(selectedID)
		{
			if (selectedID > 0 && intPrevSelectedLanguageID != selectedID)
			{
				showhideDirtyContentFlag(selectedID, checkContentState(selectedID));
				saveChanges();
				showhideDirtyContentFlag(intPrevSelectedLanguageID, checkContentState(intPrevSelectedLanguageID));
				if (intPrevSelectedLanguageID > 0)
				{
					changeSelectedLangColor(intPrevSelectedLanguageID, false);
				}
				changeSelectedLangColor(selectedID, true);
				intPrevSelectedLanguageID = selectedID;
				document.theForm.CurrentSelectedLanguageOrdinal.value = intPrevSelectedLanguageID;
				replaceEditableContent(selectedID);
			}
		}

		function changeSelectedLangColor(selectedID, boolOn)
		{
			if (selectedID > 0)
			{
				var oLangTextHandle1 = langOptionText[selectedID - 1] ? langOptionText[selectedID - 1] : langOptionText;
				var oLangTextHandle2 = langOptionText_DirtyFlag[selectedID - 1] ? langOptionText_DirtyFlag[selectedID - 1] : langOptionText_DirtyFlag;
				var oLangImgHandle = document.theForm.langSelectorImg[selectedID - 1] ? document.theForm.langSelectorImg[selectedID - 1] : document.theForm.langSelectorImg;
				var selectedLangRow = new Object();
				
				selectedLangRow = eval("langRow" + selectedID);
				
				if (boolOn)
				{
					selectedLangRow.style.backgroundColor = "#999999";
					oLangTextHandle1.className = "langOption_Selected";
					oLangTextHandle2.style.color = "#ffffff";
					oLangImgHandle.src = langSelectorOn.src;
				}
				else
				{
					selectedLangRow.style.backgroundColor = '#cccccc';
					oLangTextHandle1.className = "langOption";
					oLangTextHandle2.style.color = "#000000";
					oLangImgHandle.src = langSelectorOff.src;
				}
				
				defaultLang_DisplayName1.innerText = eval("document.theForm.lang" + selectedID + "_lang_prettyname.value");
				defaultLang_DisplayName2.innerText = eval("document.theForm.lang" + selectedID + "_lang_prettyname.value");
				defaultLang_DisplayName3.innerText = eval("document.theForm.lang" + selectedID + "_lang_prettyname.value");
			}
		}
		
		function saveChanges()
		{
			if (intPrevSelectedLanguageID > 0)
			{
				var savedTitle = new Object();
				var savedByline = new Object();
				var savedContent = new Object();
				var savedAbstract = new Object();
				var savedKeywords = new Object();
				var savedBoolDefault = new Object();
				var savedDocType = new Object();
				var savedFileName = new Object();
				var savedFileID = new Object();
				var savedWebURL = new Object();
				var savedTopicContactInfo = new Object();
				var savedTopicSourceWebsite = new Object();
				var savedUserDefinedField1 = new Object();
				var savedUserDefinedField2 = new Object();
				var savedUserDefinedField3 = new Object();
				var savedUserDefinedField4 = new Object();
				var savedUserDefinedField5 = new Object();

				savedTitle = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_title");
				savedByline = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_byline");
				savedContent = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_content");
				savedAbstract = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_abstract");
				savedKeywords = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_keywords");
				savedBoolDefault = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_boolDefault");
				savedDocType = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_type");
				savedFileName = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_filename");
				savedFileID = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_fileID");
				savedWebURL = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_url");
				savedTopicContactInfo = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_topic_contactinfo");
				savedTopicSourceWebsite = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_topic_sourcewebsite");
				<%if 1 = 2 then%>
				savedUserDefinedField1 = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_userdefinedfield1");
				savedUserDefinedField2 = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_userdefinedfield2");
				savedUserDefinedField3 = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_userdefinedfield3");
				savedUserDefinedField4 = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_userdefinedfield4");
				savedUserDefinedField5 = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_userdefinedfield5");
				<%end if%>

				savedTitle.value = document.theForm.Topic_Name.value;
				savedByline.value = document.theForm.Topic_Byline.value;
				if (isMac)
				{
					savedContent.value = document.theForm.Topic_Summary.value // = eval("document.theForm.lang" + selectedID + "_dirty_content.value");
				}
				else
				{
				//	ae_onSubmit();
				//	savedContent.value = aeObjects["Topic_Summary"].DOM.body.innerHTML;
					savedContent.value = HtmlEditGetContent("Topic_Summary_EditorPanel");
				}

				if (document.theForm.boolDefault.checked == true)
				{
					savedBoolDefault.value = "1";
				}
				else
				{
					savedBoolDefault.value = "0";
				}
				savedDocType.value = document.theForm.Topic_Type.selectedIndex;
				if (savedDocType.value == "1")
				{
					savedFileName.value = document.theForm.Type1_FileName.value;
					savedFileID.value = document.theForm.Type1_FileID.value;
				}
				if (savedDocType.value == "2")
				{
					savedWebURL.value = document.theForm.Type2_URL.value;
				}
				savedTopicContactInfo.value = document.theForm.Topic_ContactInfo.value;
				savedTopicSourceWebsite.value = document.theForm.Topic_SourceWebsite.value;
				<%if 1 = 2 then%>
				savedUserDefinedField1.value = document.theForm.UserDefinedField1.value;
				savedUserDefinedField2.value = document.theForm.UserDefinedField2.value;
				savedUserDefinedField3.value = document.theForm.UserDefinedField3.value;
				savedUserDefinedField4.value = document.theForm.UserDefinedField4.value;
				savedUserDefinedField5.value = document.theForm.UserDefinedField5.value;
				<%end if%>
				savedAbstract.value = document.theForm.Topic_Abstract.value;
				savedKeywords.value = document.theForm.Topic_Keywords.value;
			}
		}
		
		function replaceEditableContent(selectedID)
		{
			document.theForm.Topic_Name.value = eval("document.theForm.lang" + selectedID + "_dirty_title.value");
			document.theForm.Topic_Byline.value = eval("document.theForm.lang" + selectedID + "_dirty_byline.value");
			document.theForm.Topic_Name.focus();
			
			if (isMac)
			{
				document.theForm.Topic_Summary.value  = eval("document.theForm.lang" + selectedID + "_dirty_content.value");
			}
			else
			{
			//	var DHTMLSafe = new Object(aeObjects["Topic_Summary"]);
			//	DHTMLSafe.focus();
			//	DHTMLSafe.DOM.body.focus();
			//	DHTMLSafe.DOM.body.innerHTML = eval("document.theForm.lang" + selectedID + "_dirty_content.value");
				HtmlEditSetContent( "Topic_Summary_EditorPanel", eval("document.theForm.lang" + selectedID + "_dirty_content.value") );
			}
		
			if(eval("document.theForm.lang" + selectedID + "_dirty_boolDefault.value") == "1")
			{
				document.theForm.boolDefault.checked = true;
				document.theForm.boolDefault.disabled = true;
			}
			else
			{
				document.theForm.boolDefault.checked = false;
				document.theForm.boolDefault.disabled = false;
			}
					
			document.theForm.Type1_FileName.value = eval("document.theForm.lang" + selectedID + "_dirty_filename.value");
			document.theForm.Type1_FileID.value = eval("document.theForm.lang" + selectedID + "_dirty_fileID.value");
			document.theForm.Type2_URL.value = eval("document.theForm.lang" + selectedID + "_dirty_url.value");
			document.theForm.Topic_Type.selectedIndex = eval("document.theForm.lang" + selectedID + "_dirty_type.value");
			document.theForm.Topic_ContactInfo.value = eval("document.theForm.lang" + selectedID + "_dirty_topic_contactinfo.value");
			document.theForm.Topic_SourceWebsite.value = eval("document.theForm.lang" + selectedID + "_dirty_topic_sourcewebsite.value");
			<%if 1 = 2 then%>
			document.theForm.UserDefinedField1.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield1.value");
			document.theForm.UserDefinedField2.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield2.value");
			document.theForm.UserDefinedField3.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield3.value");
			document.theForm.UserDefinedField4.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield4.value");
			document.theForm.UserDefinedField5.value = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield5.value");
			<%end if%>
			document.theForm.Topic_Abstract.value = eval("document.theForm.lang" + selectedID + "_dirty_abstract.value");
			document.theForm.Topic_Keywords.value = eval("document.theForm.lang" + selectedID + "_dirty_keywords.value");

			showhideDocTypeDetails();
			document.theForm.Topic_Name.focus();
		}
		
		function revertToOrig()
		{
			if (intPrevSelectedLanguageID > 0)
			{
				saveChanges();
				document.theForm.Topic_Name.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_title.value");
				document.theForm.Topic_Byline.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_byline.value");
				document.theForm.Topic_Name.focus();
			
				if (isMac)
				{
					document.theForm.Topic_Summary.value  = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_content.value");
				}
				else
				{
				//	var DHTMLSafe = new Object(aeObjects["Topic_Summary"]);
				//	DHTMLSafe.focus();
				//	DHTMLSafe.DOM.body.focus();
				//	DHTMLSafe.DOM.body.innerHTML = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_content.value");
					HtmlEditSetContent( "Topic_Summary_EditorPanel", eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_content.value") );
				}
				
				document.theForm.Topic_Type.selectedIndex = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_type.value");
				document.theForm.Type1_FileName.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_filename.value");
				document.theForm.Type1_FileID.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_fileID.value");
				document.theForm.Type2_URL.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_url.value");
				document.theForm.Topic_Type.selectedIndex = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_type.value");
				document.theForm.Topic_ContactInfo.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_topic_contactinfo.value");
				document.theForm.Topic_SourceWebsite.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_topic_sourcewebsite.value");
				<%if 1 = 2 then%>
				document.theForm.UserDefinedField1.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_userdefinedfield1.value");
				document.theForm.UserDefinedField2.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_userdefinedfield2.value");
				document.theForm.UserDefinedField3.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_userdefinedfield3.value");
				document.theForm.UserDefinedField4.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_userdefinedfield4.value");
				document.theForm.UserDefinedField5.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_userdefinedfield5.value");
				<%end if%>
				document.theForm.Topic_Abstract.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_abstract.value");
				document.theForm.Topic_Keywords.value = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_keywords.value");

				showhideDocTypeDetails();
				document.theForm.Topic_Name.focus();
				saveChanges();
				showhideDirtyContentFlag(intPrevSelectedLanguageID, checkContentState(intPrevSelectedLanguageID));
			}
		}
		
		function clearAll()
		{
			if (intPrevSelectedLanguageID > 0)
			{
				document.theForm.Topic_Name.value = "";			
				document.theForm.Topic_Byline.value = "";			
			
				if (isMac)
				{
					document.theForm.Topic_Summary.value  = "";
				}
				else
				{
				//	var DHTMLSafe = new Object(aeObjects["Topic_Summary"]);
				//	DHTMLSafe.focus();
				//	DHTMLSafe.DOM.body.focus();
				//	DHTMLSafe.DOM.body.innerHTML = "";
					HtmlEditSetContent( "Topic_Summary_EditorPanel", "" );
				}
				
				document.theForm.Topic_Type.selectedIndex = 0;
				document.theForm.Type1_FileName.value = "";
				document.theForm.Type1_FileID.value = "";
				document.theForm.Type2_URL.value = "";
				document.theForm.Topic_Type.selectedIndex = "";
				document.theForm.Topic_ContactInfo.value = "";
				document.theForm.Topic_SourceWebsite.value = "";
				<%if 1 = 2 then%>
				document.theForm.UserDefinedField1.value = "";
				document.theForm.UserDefinedField2.value = "";
				document.theForm.UserDefinedField3.value = "";
				document.theForm.UserDefinedField4.value = "";
				document.theForm.UserDefinedField5.value = "";
				<%end if%>
				document.theForm.Topic_Abstract.value = "";			
				document.theForm.Topic_Keywords.value = "";			

				showhideDocTypeDetails();
				document.theForm.Topic_Name.focus();
				saveChanges();
				showhideDirtyContentFlag(intPrevSelectedLanguageID, checkContentState(intPrevSelectedLanguageID));
			}
		}
		
		function checkContentState(selectedID)
		{
			var isDirty = 0;
			if (selectedID > 0)
			{
				var origTitle = new Object();
				var origByline = new Object();
				var origContent = new Object();
				var origAbstract = new Object();
				var origKeywords = new Object();
				var origBoolDefault = new Object();
				var origDocType = new Object();
				var origFileName = new Object();
				var origFileID = new Object();
				var origWebURL = new Object();
				var origTopicContactInfo = new Object();
				var origTopicSourceWebsite = new Object();
				<%if 1 = 2 then%>
				var origUserDefinedField1 = new Object();
				var origUserDefinedField2 = new Object();
				var origUserDefinedField3 = new Object();
				var origUserDefinedField4 = new Object();
				var origUserDefinedField5 = new Object();
				<%end if%>

				var dirtyTitle = new Object();
				var dirtyByline = new Object();
				var dirtyContent = new Object();
				var dirtyAbstract = new Object();
				var dirtyKeywords = new Object();
				var dirtyBoolDefault = new Object();
				var dirtyDocType = new Object();
				var dirtyFileName = new Object();
				var dirtyFileID = new Object();
				var dirtyWebURL = new Object();
				var dirtyTopicContactInfo = new Object();
				var dirtyTopicSourceWebsite = new Object();
				<%if 1 = 2 then%>
				var dirtyUserDefinedField1 = new Object();
				var dirtyUserDefinedField2 = new Object();
				var dirtyUserDefinedField3 = new Object();
				var dirtyUserDefinedField4 = new Object();
				var dirtyUserDefinedField5 = new Object();
				<%end if%>

				origTitle = eval("document.theForm.lang" + selectedID + "_orig_title");
				origByline = eval("document.theForm.lang" + selectedID + "_orig_byline");
				origContent = eval("document.theForm.lang" + selectedID + "_orig_content");
				origAbstract = eval("document.theForm.lang" + selectedID + "_orig_abstract");
				origKeywords = eval("document.theForm.lang" + selectedID + "_orig_keywords");
				origBoolDefault = eval("document.theForm.lang" + selectedID + "_orig_boolDefault");
				origDocType = eval("document.theForm.lang" + selectedID + "_orig_type");
				origFileName = eval("document.theForm.lang" + selectedID + "_orig_filename");
				origFileID = eval("document.theForm.lang" + selectedID + "_orig_fileID");
				origWebURL = eval("document.theForm.lang" + selectedID + "_orig_url");
				origTopicContactInfo = eval("document.theForm.lang" + selectedID + "_orig_topic_contactinfo");
				origTopicSourceWebsite = eval("document.theForm.lang" + selectedID + "_orig_topic_sourcewebsite");
				<%if 1 = 2 then%>
				origUserDefinedField1 = eval("document.theForm.lang" + selectedID + "_orig_userdefinedfield1");
				origUserDefinedField2 = eval("document.theForm.lang" + selectedID + "_orig_userdefinedfield2");
				origUserDefinedField3 = eval("document.theForm.lang" + selectedID + "_orig_userdefinedfield3");
				origUserDefinedField4 = eval("document.theForm.lang" + selectedID + "_orig_userdefinedfield4");
				origUserDefinedField5 = eval("document.theForm.lang" + selectedID + "_orig_userdefinedfield5");
				<%end if%>

				dirtyTitle = eval("document.theForm.lang" + selectedID + "_dirty_title");
				dirtyByline = eval("document.theForm.lang" + selectedID + "_dirty_byline");
				dirtyContent = eval("document.theForm.lang" + selectedID + "_dirty_content");
				dirtyAbstract = eval("document.theForm.lang" + selectedID + "_dirty_abstract");
				dirtyKeywords = eval("document.theForm.lang" + selectedID + "_dirty_keywords");
				dirtyBoolDefault = eval("document.theForm.lang" + selectedID + "_dirty_boolDefault");
				dirtyDocType = eval("document.theForm.lang" + selectedID + "_dirty_type");
				dirtyFileName = eval("document.theForm.lang" + selectedID + "_dirty_filename");
				dirtyFileID = eval("document.theForm.lang" + selectedID + "_dirty_fileID");
				dirtyWebURL = eval("document.theForm.lang" + selectedID + "_dirty_url");
				dirtyTopicContactInfo = eval("document.theForm.lang" + selectedID + "_dirty_topic_contactinfo");
				dirtyTopicSourceWebsite = eval("document.theForm.lang" + selectedID + "_dirty_topic_sourcewebsite");
				<%if 1 = 2 then%>
				dirtyUserDefinedField1 = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield1");
				dirtyUserDefinedField2 = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield2");
				dirtyUserDefinedField3 = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield3");
				dirtyUserDefinedField4 = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield4");
				dirtyUserDefinedField5 = eval("document.theForm.lang" + selectedID + "_dirty_userdefinedfield5");
				<%end if%>


				if (origTitle.value != dirtyTitle.value)
				{
					isDirty = 1;
				}

				if (origByline.value != dirtyByline.value)
				{
					isDirty = 1;
				}

				if (origContent.value != dirtyContent.value)
				{
				//	alert(origContent.value);
				//	alert(dirtyContent.value);
					
					isDirty = 1;
				}

				if (origAbstract.value != dirtyAbstract.value)
				{
					isDirty = 1;
				}

				if (origKeywords.value != dirtyKeywords.value)
				{
					isDirty = 1;
				}

				if (origDocType.value != dirtyDocType.value)
				{
					isDirty = 1;
				}

				if (dirtyDocType.value == "1" && origFileName.value != dirtyFileName.value)
				{
					isDirty = 1;
				}

				if (dirtyDocType.value == "1" && origFileID.value != dirtyFileID.value)
				{
					isDirty = 1;
				}

				if (dirtyDocType.value == "2" && origWebURL.value != dirtyWebURL.value)
				{
					isDirty = 1;
				}

				if (origTopicContactInfo.value != dirtyTopicContactInfo.value)
				{
					isDirty = 1;
				}
				if (origTopicSourceWebsite.value != dirtyTopicSourceWebsite.value)
				{
					isDirty = 1;
				}
				<%if 1 = 2 then%>
				if (origUserDefinedField1.value != dirtyUserDefinedField1.value)
				{
					isDirty = 1;
				}
				if (origUserDefinedField2.value != dirtyUserDefinedField2.value)
				{
					isDirty = 1;
				}
				if (origUserDefinedField3.value != dirtyUserDefinedField3.value)
				{
					isDirty = 1;
				}
				if (origUserDefinedField4.value != dirtyUserDefinedField4.value)
				{
					isDirty = 1;
				}
				if (origUserDefinedField5.value != dirtyUserDefinedField5.value)
				{
					isDirty = 1;
				}
				<%end if%>
			}
			return isDirty;
		}
			
		function showhideDirtyContentFlag(selectedID, boolShow)
		{
			var oLangTextHandle = langOptionText_DirtyFlag[selectedID - 1] ? langOptionText_DirtyFlag[selectedID - 1] : langOptionText_DirtyFlag;
			if (selectedID > 0)
			{
				if (boolShow)
				{
					oLangTextHandle.style.display = "";
				}
				else
				{
					oLangTextHandle.style.display = "none";
				}
			}
		}
		
		var intDefaultLangID = 0;
		
		function setDefaultLanguage()
		{
			if (intPrevSelectedLanguageID > 0)
			{
				defaultLang_DisplayName1.innerText = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_lang_prettyname.value");
				defaultLang_DisplayName2.innerText = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_lang_prettyname.value");
				defaultLang_DisplayName3.innerText = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_lang_prettyname.value");
				
				if (document.theForm.boolDefault.checked == true)
				{
					var oLangTextHandle = langOptionText[intPrevSelectedLanguageID - 1] ? langOptionText[intPrevSelectedLanguageID - 1] : langOptionText;
					if (intDefaultLangID > 0)
					{
						var savedBoolDefault = new Object();
						savedBoolDefault = eval("document.theForm.lang" + intDefaultLangID + "_dirty_boolDefault");
						savedBoolDefault.value = "0";
						oLangTextHandle.style.fontWeight = "NORMAL";
						showhideDirtyContentFlag(intDefaultLangID, checkContentState(intDefaultLangID));
					}
					
					oLangTextHandle.style.fontWeight = "BOLD";
					intDefaultLangID = intPrevSelectedLanguageID;

					var savedBoolDefault = new Object();
					savedBoolDefault = eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_boolDefault");
					savedBoolDefault.value = "1";
				
					showhideDirtyContentFlag(intPrevSelectedLanguageID, checkContentState(intPrevSelectedLanguageID));
					document.theForm.boolDefault.disabled = true;
				}
				else
				{
					document.theForm.boolDefault.checked = true;
				}
			}
		}
		
		function showhideDocTypeDetails()
		{
			switch (document.theForm.Topic_Type.selectedIndex)
			{
				case 0:
					docTypeDetailsSeparator.style.display = "none";
					docFileNameLyr.style.display = "none";
					docURLLyr.style.display = "none";
					body_title.innerText = "Document Body"
					break;
				
				case 1:
					docTypeDetailsSeparator.style.display = "";
					docFileNameLyr.style.display = "";
										
					if (intPrevSelectedLanguageID > 0 && eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_filename.value") == eval("document.theForm.lang" + intPrevSelectedLanguageID + "_orig_filename.value"))
					{
						document.theForm.Type1_FileName.style.backgroundColor = "#cccccc";
						document.theForm.Type1_FileName.style.color = "#000000";
					}
					else
					{
						document.theForm.Type1_FileName.style.backgroundColor = "#ffffff";
						document.theForm.Type1_FileName.style.color = "#000000";
					}
					
					docURLLyr.style.display = "none";
					body_title.innerText = "File Summary/Abstract"
					break;
				
				case 2:
					docTypeDetailsSeparator.style.display = "";
					docFileNameLyr.style.display = "none";
					docURLLyr.style.display = "";
					body_title.innerText = "Web Link Summary/Abstract"
					break;
				
				default:
					docTypeDetailsSeparator.style.display = "none";
					docFileNameLyr.style.display = "none";
					docURLLyr.style.display = "none";
					body_title.innerText = "Document Body"
					break;
			}
		}

		//called when the Check spelling button is clicked
		function doSpellCheck(fieldname)
		{
		//	window.open("../../app_include/ActiveEdit/inc/spellchecker/window.asp?jsvar=document.theForm." + fieldname + ".value", null, "height=230,width=450,status=no,toolbar=no,menubar=no,location=no"); 
		}
 
		//called when the Calendar icon is clicked
		function dateWin(field)
		{ 
			hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
			hwnd.focus();
		}

		//called when the Choose File link is clicked
		function chooseFile()
		{ 
			hwnd = window.open('./document_file_choose.asp', 'fileChooseWin', 'width=500,height=200,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
			hwnd.focus();
		}
		
		function showPreview(field)
		{
			previewWin = window.open('./../content_preview.asp?tid='+escape(field)+"&curlang="+eval("document.theForm.lang" + intPrevSelectedLanguageID + "_langID.value"), 'previewWin', 'width=600,height=500,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1');
			previewWin.focus();
		}
		
		function launchFileWin()
		{
			var myFeatures = "directories=no,dependent=yes,width=800,height=600,hotkeys=no,location=no,menubar=no,resizable=yes,screenX=10,screenY=10,scrollbars=yes,titlebar=no,toolbar=no,status=no";
			var newWin = window.open('./getfile.asp?tid=0&fid=' + escape(eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_fileID.value")) + '&fn=' + escape(eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_filename.value")) + '', 'viewFileWin', myFeatures);
		}
		
//		function showPreview(field)
//		{
//			saveChanges();		
//
//			var urlstring = "TopicName="+escape(eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_title.value")); 
//			urlstring += "&TopicSummary="+escape(eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_content.value"));
//			urlstring += "&Topic_Abstract="+escape(eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_abstract.value"));
//			urlstring += "&Topic_Keywords="+escape(eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_keywords.value"));
//			urlstring += "&Topic_Byline="+escape(eval("document.theForm.lang" + intPrevSelectedLanguageID + "_dirty_byline.value"));
//
//			posTop = screen.height/2 - 300;
//			posLeft = screen.width/2 - 310;
//			newWindow = window.open("./preview.asp?"+urlstring,"newWindow","width=620,scrollbars=yes,resizable=yes,scrolling=auto,height=600,left="+posLeft+",top="+posTop);
//			newWindow.focus();
//		}

	</script>
<!-- #include file="htmledit/browsersniffer.asp" -->
<!-- #include file="htmledit/htmledit.asp" -->
<%HtmlEditInit2 Application.Value("AdminToolURL") & "/manage_repository/document_admin/htmledit/", "g_strHtmlEditImgUrl = 'upload/browseimages2.asp';"%>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="preloadImgs(); initTabs('contentTab'); initContent(<%=defaultLanguageOrdinal%>);">
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="document_details_work.asp" method="POST">
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="../images/spacer.gif" height=400 width=1 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'CONTENT EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%>
			<div id="workspace_content" name="workspace_content" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td valign=top>
							<%
							Dim langBorderColor
							langBorderColor = "666666"
							%>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr bgcolor="<%=langBorderColor%>"><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr>
									<td bgcolor="<%=langBorderColor%>"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#<%=langBorderColor%>">
													<b>Edit Language</b>
													</font>
												</td>
												<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
											</tr>
										</table>
									</td>
									<td bgcolor="<%=langBorderColor%>"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
								</tr>
								<tr bgcolor="<%=langBorderColor%>"><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr>
									<td colspan=3 valign=top>
										<table cellpadding=0 cellspacing=0 border=0 width=100%>
											<tr>
												<td valign=top>
													<table width=100% cellpadding=0 cellspacing=0 border=0>
														<%
															if dictLanguagesDataCols("ColCount") > 0 and dictLanguagesDataCols("RecordCount") > 0 then
																for rowCounter = 0 to dictLanguagesDataCols("RecordCount") - 1
																	curIteration = rowCounter + 1
														%>
														<tr id="langRow<%=curIteration%>">
															<td><img src="../../app_images/checkbox_<%if CInt(arLanguagesDataRows(dictLanguagesDataCols("hasContent"), rowCounter)) > 0 then%>true<%else%>false<%end if%>.gif" height=11 width=13 border=0></td>
															<td nowrap=true>
																<table cellpadding=0 cellspacing=0 border=0>
																	<tr>
																		<td nowrap=true><div id="langOptionText" class="langOption" onClick="showContent(<%=curIteration%>)"><%=arLanguagesDataRows(dictLanguagesDataCols("Language_PrettyName"), rowCounter)%></div></td>
																		<td nowrap=true><div id="langOptionText_DirtyFlag" class="langOption" style="display: none;">*</div></td>
																	</tr>
																	<tr>
																		<td></td>
																		<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
																	</tr>
																</table>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><img name="langSelectorImg" src="../images/spacer.gif" height=12 width=12 border=0></td>
														</tr>
														<%
																next
															end if
														%>
														<tr>
															<td></td>
															<td><img src="../images/spacer.gif" height=1 width=60 border=0></td>
															<td></td>
															<td></td>
														</tr>
													</table>
												</td>
												<td bgcolor="<%=langBorderColor%>"><img src="../images/spacer.gif" height=270 width=1 border=0></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr bgcolor="<%=langBorderColor%>"><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr>
									<td bgcolor="<%=langBorderColor%>"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#<%=langBorderColor%>">
													<b>Language Options</b>
													</font>
												</td>
												<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
											</tr>
										</table>
									</td>
									<td bgcolor="<%=langBorderColor%>"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
								</tr>
								<tr bgcolor="<%=langBorderColor%>"><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr>
									<td bgcolor="<%=langBorderColor%>"><img src="../images/spacer.gif" height=100 width=1 border=0></td>
									<td valign=top>
										<table width=100% cellpadding=0 cellspacing=0 border=0>
											<tr><td colspan=3><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
											<tr>
												<td>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td>
																<table cellpadding=0 cellspacing=0 border=0>
																	<tr>
																		<td valign=top><input type=checkbox value="1" name="boolDefault" CHECKED onClick="setDefaultLanguage()"></td>
																		<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
																		<td valign=top>
																			<font style="font-family:Arial, Helvetica;font-size:11px;color:#000000">
																			<a href="javascript: void(0); document.theForm.boolDefault.checked=true;setDefaultLanguage()" style="color:#000000; text-decoration: none;">Set <span id="defaultLang_DisplayName1">this</span> as Default Language</a>
																			</font>
																		</td>
																	</tr>
																</table>
															</td>
														</tr>
													</table>
												</td>
											</tr>
											<tr><td colspan=3><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
											<tr>
												<td>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
															<td valign=top><img src="../images/undo.gif" height=16 width=16 border=0></td>
															<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
															<td valign=top>
																<font style="font-family:Arial, Helvetica;font-size:11px;color:#000000">
																<a href="javascript: void(0); revertToOrig();" style="color:#000000; text-decoration: none;">Revert to Saved <span id="defaultLang_DisplayName2">&nbsp;</span> Content</a>
																</font>
															</td>
														</tr>
													</table>
												</td>
											</tr>
											<tr><td colspan=3><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
											<tr>
												<td>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
															<td valign=top><img src="../images/delete.gif" height=16 width=16 border=0></td>
															<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
															<td valign=top>
																<font style="font-family:Arial, Helvetica;font-size:11px;color:#000000">
																<a href="javascript: void(0); clearAll();" style="color:#000000; text-decoration: none;">Clear <span id="defaultLang_DisplayName3">&nbsp;</span> Content</a>
																</font>
															</td>
														</tr>
													</table>
												</td>
											</tr>
											<tr><td colspan=3><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
										</table>
									</td>
									<td><img src="../images/spacer.gif" height=1 width=1 border=0></td>
								</tr>
								<tr bgcolor="<%=langBorderColor%>"><td colspan=3><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td><img src="./../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td colspan=3 align=right nowrap>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
												<td valign=top><img src="../images/view.gif" height=16 width=16 border=0></td>
												<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
												<td valign=top>
													<font style="font-family:Arial, Helvetica;font-size:11px;color:#000000">
													<a href="javascript: void(0); showPreview(<%=topicID%>);" style="color:#000000; text-decoration: none;">Preview Document</a>
													</font>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width=100% valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Document Title</b>
										</font>
									</td>
								</tr>
								<tr>
									<td>
										<input type="text" size=60 maxlength=500 name="Topic_Name" value="" AutoComplete="off" ID="Text2">
									</td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Document Subheading (optional)</b>
										</font>
									</td>
								</tr>
								<tr>
									<td>
										<input type="text" size=60 maxlength=500 name="Topic_Byline" value="" AutoComplete="off" ID="Text1">
									</td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td nowrap=true valign=top>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td>
																<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																<b>Document Type</b>
																</font>
															</td>
														</tr>
														<tr>
															<td>
																<select name="Topic_Type" onChange="showhideDocTypeDetails()">
																	<option value="0">Document
																	<option value="1">File
																	<option value="2">Web Link
																<!--<option value="3">List-->
																<!--<option value="4">Portal-->
																</select>
															</td>
														</tr>
													</table>
												</td>
												<td><img src="../images/spacer.gif" height=40 width=10 border=0></td>
												<td nowrap=true valign=top>
													<div id="docTypeDetailsSeparator" style="display:none;">
														<table cellpadding=0 cellspacing=0 border=0>
															<tr>
																<td bgcolor=666666><img src="../images/spacer.gif" height=40 width=1 border=0></td>
																<td bgcolor=ffffff><img src="../images/spacer.gif" height=40 width=1 border=0></td>
																<td><img src="../images/spacer.gif" height=40 width=10 border=0></td>
															</tr>
														</table>
													</div>
												</td>
												<td nowrap=true valign=top>
													<div id="docFileNameLyr" style="display:none;">
														<table cellpadding=0 cellspacing=0 border=0>
															<tr>
																<td colspan=2>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																	<b>File Name</b>
																	</font>
																</td>
															</tr>  
															<tr>
																<td><input type="text" size=40 maxlength=500 name="Type1_FileName" value="" AutoComplete="off"><input type=button name="chooseFileBtn" id="chooseFileBtn" value=" ... " onClick="javascript:void(0); chooseFile();"></td>
																<td><a href="javascript: void(0); launchFileWin()"><img src="../images/document_details_viewfile.gif" height=26 width=50 border=0></a></td>
															</tr>
														</table>
														<input type=hidden name="Type1_FileID" value="">
													</div>
													<div id="docURLLyr" style="display:none;">
														<table cellpadding=0 cellspacing=0 border=0>
															<tr>
																<td>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																	<b>Target Website URL</b>
																	</font>
																</td>
															</tr>
															<tr><td><input type="text" size=40 maxlength=500 name="Type2_URL" value="" AutoComplete="off"></td></tr>
														</table>
													</div>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<b><span id="body_title">Document Body</span></b>
													</font>
												</td>
											</tr>
											<% 
											if InStr(LCase(Request.ServerVariables("HTTP_USER_AGENT")), "mac") > 0 then
											%>
											<tr>
												<td>
													<textarea wrap="off" name="Topic_Summary" rows=30 cols=60><%=defaultContent%></textarea>
												</td>
											</tr>
											<%
											else
											%>
											<tr>
												<td>
												<%
													Set Editor = new QWebEditor
													Editor.SetCtrlName "Topic_Summary_EditorPanel"
													Editor.SetElementName "Topic_Summary"
													Editor.SetWidth "100%"
													Editor.SetHeight "290px"
													Editor.EnableUseDivForIE True
													Editor.EnableXHtmlSource  True
													'Editor.SetEditorCSSFile("/include/editorstyle.css")
													Editor.SetContent defaultContent
													Editor.CreateControl
												%>
												</td>
											</tr>
											<%
											end if
											%>
										</table>
									</td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=15 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Contact Info</b>
										</font>
									</td>
								</tr>
								<tr>
									<td><input type="text" size=60 maxlength=500 name="Topic_ContactInfo" value="" AutoComplete="off" ID="Topic_ContactInfo"></td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Source Website</b>
										</font>
									</td>
								</tr>
								<tr>
									<td><input type="text" size=60 maxlength=500 name="Topic_SourceWebsite" value="" AutoComplete="off" ID="Topic_SourceWebsite"></td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Keywords (optional, comma-separated)</b>
										</font>
									</td>
								</tr>
								<tr>
									<td><input type="text" size=60 maxlength=500 name="Topic_Keywords" value="" AutoComplete="off" ID="Text3"></td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Abstract/Short Description (optional)</b>
										</font>
									</td>
								</tr>
								<tr>
									<td><textarea wrap="none" name="Topic_Abstract" rows=3 cols=60 ID="Textarea1"></textarea></td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=20 width=1 border=0></td></tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
			<% 
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'CUSTOM FIELDS TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%>
			<div id="workspace_customdata" name="workspace_customdata" style="display:none">
				<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table5">
					<tr>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top width="100%">
							<table cellpadding=0 cellspacing=0 border=0 ID="Table6">
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Custom Document Data</b><br />
										The following fields have been configured to allow you to store additional information with this document.
										</font>
									</td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr bgcolor=666666><td><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<%
								SQLStr = "SELECT " & _ 
										"   a.[ID], " & _ 
										"   a.[Field_Ordinal], " & _ 
										"   a.[Field_Type], " & _ 
										"   c.[Type_Name], " & _ 
										"   a.[Field_Size], " & _ 
										"   a.[Field_ClassName], " & _ 
										"   a.[Field_StyleString], " & _ 
										"   a.[Field_Label], " & _ 
										"   a.[Field_HelpText], " & _ 
										"   a.[AllowNullData], " & _ 
										"   a.[UseDefaultValueWhenBlank], " & _ 
										"   a.[UseDefaultValueWhenValidationFails] " & _ 
										" FROM Repository_UserDefinedField_Settings a " & _ 
										" INNER JOIN Repository_UserDefinedField_Type c ON c.[ID] = a.[Field_Type] " & _ 
										" ORDER BY Field_Ordinal, a.[ID] "
								objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
								if not objRec.EOF then
									Do Until objRec.EOF

										SQLStr = "SELECT " & _ 
												"   b.[UserDefinedField_Settings_ID], " & _ 
												"   b.[isDefault], " & _ 
												"   b.[Data_Label], " & _ 
												"   b.[Data_Value_Text], " & _ 
												"   b.[Data_Value_Date], " & _ 
												"   b.[Data_Value_Number], " & _ 
												"   b.[Data_Value_Money], " & _ 
												"   b.[Data_Value_Boolean] " & _ 
												" FROM Repository_UserDefinedField_CandidateData b " & _ 
												" WHERE UserDefinedField_Settings_ID = '0" & objRec("ID") & "' " & _ 
												" ORDER BY b.SortOrder, b.Data_Label, b.[ID] "
										objRec2.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
										if not objRec2.EOF then

											if dictTopicDataCols("RecordCount") > 0 then
												for i = 0 to dictTopicDataCols("RecordCount") - 1
													if CInt(topicLanguageID) = CInt(masterLanguageID) then
														thisUserDefinedField = SmartValues(arTopicDataRows(dictTopicDataCols("UserDefinedField" & checkQueryID(SmartValues(objRec("Field_Ordinal"), "CLng"), 0) ), i), "CStr")
													end if
												next
											end if
											arThisUserDefinedField = Split(thisUserDefinedField, ",")

											Select Case SmartValues(objRec("Field_Type"), "CLng")
												
												Case 1 'Text
												%>
												<!-- =====================================================================================	-->
												<!-- UserDefinedField<%=objRec("Field_Ordinal")%> (<%=objRec("Type_Name")%>)				-->
												<!-- =====================================================================================	-->
												<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
												<tr>
													<td>
														<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
														<b><%=objRec("Field_Label")%></b>
														</font>
													</td>
												</tr>
												<tr>
													<td><input type="text" size=60 maxlength=500 name="UserDefinedField<%=objRec("Field_Ordinal")%>" value="<%if boolIsNewDocument then Response.Write objRec2("Data_Value_Text") else Response.Write thisUserDefinedField%>" AutoComplete="off" ID="UserDefinedField<%=objRec("Field_Ordinal")%>" size="<%=objRec("Field_Size")%>" maxlength="200" class="<%=objRec("Field_ClassName")%>" style="<%=objRec("Field_StyleString")%>"></td>
												</tr>
												<%
												Case 2 'Date/Time
												%>
												<!-- =====================================================================================	-->
												<!-- UserDefinedField<%=objRec("Field_Ordinal")%> (<%=objRec("Type_Name")%>)				-->
												<!-- =====================================================================================	-->
												<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
												<tr>
													<td>
														<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
														<b><%=objRec("Field_Label")%></b>
														</font>
													</td>
												</tr>
												<tr>
													<td nowrap>
														<input type=text name="UserDefinedField<%=objRec("Field_Ordinal")%>" value="<%if boolIsNewDocument then Response.Write objRec2("Data_Value_Date") else Response.Write thisUserDefinedField%>" size=10 maxlength=10 AutoComplete="off" ID="UserDefinedField<%=objRec("Field_Ordinal")%>" class="<%=objRec("Field_ClassName")%>" style="<%=objRec("Field_StyleString")%>">
														<a href="javascript: dateWin('UserDefinedField<%=objRec("Field_Ordinal")%>');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a>
													</td>
												</tr>
												<%									
												Case 3 'Number
												%>
												<!-- =====================================================================================	-->
												<!-- UserDefinedField<%=objRec("Field_Ordinal")%> (<%=objRec("Type_Name")%>)				-->
												<!-- =====================================================================================	-->
												<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
												<tr>
													<td>
														<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
														<b><%=objRec("Field_Label")%></b>
														</font>
													</td>
												</tr>
												<tr>
													<td><input type="text" size=60 maxlength=500 name="UserDefinedField<%=objRec("Field_Ordinal")%>" value="<%if boolIsNewDocument then Response.Write objRec2("Data_Value_Number") else Response.Write thisUserDefinedField%>" AutoComplete="off" ID="UserDefinedField<%=objRec("Field_Ordinal")%>" size="<%=objRec("Field_Size")%>" maxlength="200" class="<%=objRec("Field_ClassName")%>" style="<%=objRec("Field_StyleString")%>"></td>
												</tr>
												<%
												Case 4 'Money
												%>
												<!-- =====================================================================================	-->
												<!-- UserDefinedField<%=objRec("Field_Ordinal")%> (<%=objRec("Type_Name")%>)				-->
												<!-- =====================================================================================	-->
												<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
												<tr>
													<td>
														<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
														<b><%=objRec("Field_Label")%></b>
														</font>
													</td>
												</tr>
												<tr>
													<td><input type="text" size=60 maxlength=500 name="UserDefinedField<%=objRec("Field_Ordinal")%>" value="<%if boolIsNewDocument then Response.Write objRec2("Data_Value_Money") else Response.Write thisUserDefinedField%>" AutoComplete="off" ID="UserDefinedField<%=objRec("Field_Ordinal")%>" size="<%=objRec("Field_Size")%>" maxlength="200" class="<%=objRec("Field_ClassName")%>" style="<%=objRec("Field_StyleString")%>"></td>
												</tr>
												<%
												Case 5 'Boolean
												%>
												<!-- =====================================================================================	-->
												<!-- UserDefinedField<%=objRec("Field_Ordinal")%> (<%=objRec("Type_Name")%>)				-->
												<!-- =====================================================================================	-->
												<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
												<tr>
													<td>
														<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
														<div class="<%=objRec("Field_ClassName")%>" style="<%=objRec("Field_StyleString")%>"><input type="checkbox" name="UserDefinedField<%=objRec("Field_Ordinal")%>" value="1"<%if boolIsNewDocument then%><%if SmartValues(objRec2("Data_Value_Boolean"), "CBool") then Response.Write " CHECKED"%><%else%><%if CBool(checkQueryID(thisUserDefinedField, 0)) then Response.Write " CHECKED"%><%end if%> ID="UserDefinedField<%=objRec("Field_Ordinal")%>" style="margin-right: 10px;"><label for="UserDefinedField<%=objRec("Field_Ordinal")%>"><b><%=objRec("Field_Label")%></b></label></div>
														</font>
													</td>
												</tr>
												<%
												Case 6 'Select List
												%>
												<!-- =====================================================================================	-->
												<!-- UserDefinedField<%=objRec("Field_Ordinal")%> (<%=objRec("Type_Name")%>)				-->
												<!-- =====================================================================================	-->
												<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
												<tr>
													<td>
														<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
														<b><%=objRec("Field_Label")%></b>
														</font>
													</td>
												</tr>
												<tr>
													<td>
														<select name="UserDefinedField<%=objRec("Field_Ordinal")%>" ID="UserDefinedField<%=objRec("Field_Ordinal")%>" class="<%=objRec("Field_ClassName")%>" style="<%=objRec("Field_StyleString")%>">
														<%
														if CBool(objRec("AllowNullData")) then
														%>
															<option value="">
														<%
														end if
														
														Do Until objRec2.EOF
														%>
															<option value="<%=objRec2("Data_Value_Number")%>"<%if (boolIsNewDocument and CBool(objRec2("isDefault"))) or (not boolIsNewDocument and CBool(findNeedleInHayStack(arThisUserDefinedField, SmartValues(objRec2("Data_Value_Number"), "CStr"), "true"))) then Response.Write " SELECTED"%>><%=objRec2("Data_Label")%></option>
														<%
															objRec2.MoveNext
														Loop
														%>
														</select>
													</td>
												</tr>
												<%
												Case 7 'Multi-Select List
												%>
												<!-- =====================================================================================	-->
												<!-- UserDefinedField<%=objRec("Field_Ordinal")%> (<%=objRec("Type_Name")%>)				-->
												<!-- =====================================================================================	-->
												<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
												<tr>
													<td>
														<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
														<b><%=objRec("Field_Label")%></b>
														</font>
													</td>
												</tr>
												<tr>
													<td>
														<select name="UserDefinedField<%=objRec("Field_Ordinal")%>" ID="UserDefinedField<%=objRec("Field_Ordinal")%>" multiple size="<%=objRec("Field_Size")%>" class="<%=objRec("Field_ClassName")%>" style="<%=objRec("Field_StyleString")%>">
														<%
														Do Until objRec2.EOF
														%>
															<option value="<%=objRec2("Data_Value_Number")%>"<%if (boolIsNewDocument and CBool(objRec2("isDefault"))) or (not boolIsNewDocument and CBool(findNeedleInHayStack(arThisUserDefinedField, SmartValues(objRec2("Data_Value_Number"), "CStr"), "true"))) then Response.Write " SELECTED"%>><%=objRec2("Data_Label")%></option>
														<%
															objRec2.MoveNext
														Loop
														%>
														</select>
													</td>
												</tr>
												<%
											End Select
										end if

										objRec2.Close
									objRec.MoveNext
									Loop
									
								else
								%>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										No Custom Data Fields configured.  Please see your administrator for details.
										</font>
									</td>
								<%
								end if
								objRec.Close
								%>
								<tr>
							</table>
						</td>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
			<% 
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'SECURITY EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%>
			<div id="workspace_security" name="workspace_security" style="display:none">
			<%if 1 = 2 then%>
				<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table1">
					<tr>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top>
							<table cellpadding=0 cellspacing=0 border=0 ID="Table2">
								<tr>
									<td class="bodyText" colspan=3 valign=top>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Permissions</b>
										</font>
									</td>
								</tr>
								<tr>
									<td>
										<script language="javascript" src="./../../app_include/lockscroll_div.js"></script><!--locked headers code-->
										<script language="javascript" src="./../../app_include/autoColSize_div.js"></script><!--column resizing code-->
										<style type="text/css">
											.scrollingDiv_colHeaderText { font-family: Arial, Helvetica, Sans-Serif; font-size: 11px; line-height: 14px; color: #000; } 
											.scrollingDiv_headerText    { font-family: Arial, Helvetica, Sans-Serif; font-size: 12px; line-height: 14px; color: #000; font-weight: bold; } 
											.scrollingDiv_bodyText      { font-family: Arial, Helvetica, Sans-Serif; font-size: 12px; line-height: 15px; color: #000; } 
											.scrollingDiv_separatorBar  { background-color: #666; } 
											#boundingBox	{width: 750px; height: 470px; clip: auto; overflow: hidden; margin-top: 2px; background-color: #ccc; border: 1px solid #666;}
											#dataHeader		{width: 100%; height: 15px; clip: auto; overflow: hidden; background-color: #ccc; border-bottom: 1px solid #666;}
											#dataBody		{width: 100%; height: 453px; clip: auto; overflow: scroll; background-color: #fff;}
										</style>
										<%
										Dim objSecurityPrivilegeRec, objSecurityUserRec, x, z
										Dim Security_Privileges, Security_Privileged_Objects, Security_Privileged_Objects_XML
										
										Set objSecurityPrivilegeRec			= Server.CreateObject("ADODB.RecordSet")
										Set objSecurityUserRec				= Server.CreateObject("ADODB.RecordSet")
										Set Security_Privileges				= New cls_Security_Privileges
										Set Security_Privileged_Objects		= New cls_Security_Privileged_Objects
										
										Set objSecurityPrivilegeRec = Security_Privileges.All(Security.CurrentScopeConstant, 1)
										if not objSecurityPrivilegeRec.EOF then
										%>
										<div id="boundingBox">
											<div id="dataHeader">
												<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table3">
													<tr>
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap=true id="col_0" valign=bottom class="scrollingDiv_colHeaderText">
															Name
														</td>
														
														<%
														x = 1
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=4></td>
														<td class="scrollingDiv_separatorBar"><img src="./../images/spacer.gif" height=1 width=1></td>
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap=true id="col_<%=x%>" valign=bottom class="scrollingDiv_colHeaderText" align=center>
															<%=SmartValues(objSecurityPrivilegeRec("Privilege_ShortName"), "CStr")%>
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														x = x + 1
														Loop
														%>

														<td><img src="./../images/spacer.gif" height=1 width=100></td>
														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
												</table>
											</div>

											<div id="dataBody">
												<table width="100%" cellpadding=0 cellspacing=0 border=0 ID="Table4">
												<%
												SQLStr = "sp_security_list_roles"
												objSecurityUserRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objSecurityUserRec.EOF then
												%>
													<tr><td colspan=20 nowrap class="scrollingDiv_bodyText" style="background: #ececec; padding-left: 5px; color: #666; border-top: 1px solid #999; border-bottom: 1px solid #999;">Roles</td></tr>
												<%
													z = 0
													Do Until objSecurityUserRec.EOF
														if not objSecurityUserRec("System_Role") then
															if z mod 2 = 1 then				
																rowcolor = "fcf9f6"
															else
																rowcolor = "ffffff"
															end if 
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
													<tr bgcolor="<%=rowcolor%>">
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap class="scrollingDiv_bodyText">
															<%=objSecurityUserRec("Group_Name")%> 
														</td>

														<%
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=10></td>
														<td nowrap valign=top class="scrollingDiv_bodyText" align=center>
															<input type=checkbox name="chk_priv_<%=SmartValues(objSecurityPrivilegeRec("ID"), "CStr")%>" value="role_<%=objSecurityUserRec("ID")%>"<%if Security_Privileged_Objects.isRequestedAccessToObjectAllowed(objSecurityPrivilegeRec("ID"), Security.CurrentPrivilegedObjectID, 0, objSecurityUserRec("ID")) then Response.Write " CHECKED" end if%> ID="Checkbox1"><!-- Privilege: <%=SmartValues(objSecurityPrivilegeRec("Constant"), "CStr")%> -->
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														Loop
														%>

														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
												<%
															z = z + 1
														end if
														objSecurityUserRec.MoveNext
													Loop
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=10 width=1></td></tr>
												<%
												end if
												objSecurityUserRec.Close

												SQLStr = "sp_security_list_groups"
												objSecurityUserRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objSecurityUserRec.EOF then
												%>
													<tr><td colspan=20 nowrap class="scrollingDiv_bodyText" style="background: #ececec; padding-left: 5px; color: #666; border-top: 1px solid #999; border-bottom: 1px solid #999;">Groups</td></tr>
												<%
													z = 0
													Do Until objSecurityUserRec.EOF
														if z mod 2 = 1 then				
															rowcolor = "fcf9f6"
														else
															rowcolor = "ffffff"
														end if 
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
													<tr bgcolor="<%=rowcolor%>">
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap class="scrollingDiv_bodyText">
															<%=objSecurityUserRec("Group_Name")%> 
														</td>

														<%
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=10></td>
														<td nowrap valign=top class="scrollingDiv_bodyText" align=center>
															<input type=checkbox name="chk_priv_<%=SmartValues(objSecurityPrivilegeRec("ID"), "CStr")%>" value="group_<%=objSecurityUserRec("ID")%>"<%if Security_Privileged_Objects.isRequestedAccessToObjectAllowed(objSecurityPrivilegeRec("ID"), Security.CurrentPrivilegedObjectID, 0, objSecurityUserRec("ID")) then Response.Write " CHECKED" end if%> ID="Checkbox2"><!-- Privilege: <%=SmartValues(objSecurityPrivilegeRec("Constant"), "CStr")%> -->
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														Loop
														%>

														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
												<%
														z = z + 1
														objSecurityUserRec.MoveNext
													Loop
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=10 width=1></td></tr>
												<%
												end if
												objSecurityUserRec.Close

												SQLStr = "sp_security_list_users"
												objSecurityUserRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
												if not objSecurityUserRec.EOF then
												%>
													<tr><td colspan=20 nowrap class="scrollingDiv_bodyText" style="background: #ececec; padding-left: 5px; color: #666; border-top: 1px solid #999; border-bottom: 1px solid #999;">Admin Users</td></tr>
												<%
													z = 0
													Do Until objSecurityUserRec.EOF
														if z mod 2 = 1 then				
															rowcolor = "fcf9f6"
														else
															rowcolor = "ffffff"
														end if 
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
													<tr bgcolor="<%=rowcolor%>">
														<td><img src="./../images/spacer.gif" height=1 width=5></td>
														<td nowrap class="scrollingDiv_bodyText">
															<%=objSecurityUserRec("UserName")%>
														</td>

														<%
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=10></td>
														<td nowrap valign=top class="scrollingDiv_bodyText" align=center>
															<input type=checkbox name="chk_priv_<%=SmartValues(objSecurityPrivilegeRec("ID"), "CStr")%>" value="user_<%=objSecurityUserRec("ID")%>"<%if Security_Privileged_Objects.isRequestedAccessToObjectAllowed(objSecurityPrivilegeRec("ID"), Security.CurrentPrivilegedObjectID, objSecurityUserRec("ID"), 0) then Response.Write " CHECKED" end if%> ID="Checkbox3"><!-- Privilege: <%=SmartValues(objSecurityPrivilegeRec("Constant"), "CStr")%> -->
														</td>
														<%
														objSecurityPrivilegeRec.MoveNext
														Loop
														%>

														<td width=100%><img src="./../images/spacer.gif" height=1 width=5></td>
													</tr>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=1 width=1></td></tr>
												<%
														z = z + 1
														objSecurityUserRec.MoveNext
													Loop
												%>
													<tr><td colspan=10><img src="./../images/spacer.gif" height=10 width=1></td></tr>
												<%
												end if
												objSecurityUserRec.Close
												%>
													<tr style="visibility:none;">
														<td><img src="./../images/spacer.gif" height=1 width=1></td>
														<td id="col_0_data"><img id="col_0_dataimg" src="./../images/spacer.gif" height=1 width=100></td>
														<%
														x = 1
														objSecurityPrivilegeRec.MoveFirst
														Do until objSecurityPrivilegeRec.EOF
														%>
														<td><img src="./../images/spacer.gif" height=1 width=1></td>
														<td id="col_<%=x%>_data"><img id="col_<%=x%>_dataimg" src="./../images/spacer.gif" height=1 width=30></td>
														<%
														objSecurityPrivilegeRec.MoveNext
														x = x + 1
														Loop
														%>

														<td><img src="./../images/spacer.gif" height=1 width=1></td>
													</tr>
												</table>
											</div>
										</div>
										<%
										else
										%>
										<div id="EOF_Message" class="bodyText" style="color: #999;">
											<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
											There are no Privileges that can be set on this object.
											</font>
										</div>
										<%
										end if
										Set objSecurityPrivilegeRec = Nothing
										Set objSecurityUserRec = Nothing
										%>

									</td>
								</tr>
							</table>
						</td>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
				<%end if%>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'LIFESPAN EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictScheduleDataCols("ColCount") > 0 and dictScheduleDataCols("RecordCount") > 0 then
				boolUseSchedule = false
				if not IsNull(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)) and IsDate(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)) then
					txtStartDate = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)), vbShortDate)
					txtStartTime = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)), vbShortTime)
					boolUseStartDate = true
					boolUseSchedule = true
				end if
				if not IsNull(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)) and IsDate(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)) then
					txtEndDate = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)), vbShortDate)
					txtEndTime = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)), vbShortTime)
					boolUseEndDate = true
					boolUseSchedule = true
				end if
			else
				boolUseSchedule = false
				boolUseStartDate = false
				boolUseEndDate = false
			end if
			%>
			<div id="workspace_schedule" name="workspace_schedule" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top width="100%">
							<table width=500 cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										The following settings determine when this document is available.
										</font>
									</td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr bgcolor=666666><td><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td><img src="./../images/spacer.gif" height=20 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><input type=radio value="0" name="boolUseSchedule"<%if not boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[0].checked=true;">This document is always available.</span>
													</font>
												</td>
											</tr>
											<tr>
												<td><input type=radio value="1" name="boolUseSchedule"<%if boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true;">Document availability is determined by a schedule.</span>
													</font>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
												<td nowrap=true width=100%>
													<div id="editScheduleOneTime">
														<table cellpadding=0 cellspacing=0 border=0>
															<tr>
																<td>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																	<b>Start Date</b>
																	</font>
																</td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseStartDate"<%if not boolUseStartDate then Response.Write " CHECKED" end if%>></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseStartDate[0].checked=true;">This document is available immediately after it is saved.</span>
																				</font>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseStartDate"<%if boolUseStartDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;">This document will be available on the following date:</span>
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./../images/spacer.gif" height=5 width=1 border=0></td></tr>
															<tr>
																<td nowrap=true>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
																			<td nowrap=true>
																				<input type=text name="txtStartDate" value="<%=txtStartDate%>" size=10 maxlength=10 onFocus="document.theForm.boolUseStartDate[1].checked=true;" AutoComplete="off">
																				<select name="txtStartTime" onFocus="document.theForm.boolUseStartDate[1].checked=true;">
																					<%for i = 0 to 23%>
																					<option value="<%=FormatDateTime(i & ":00", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":00", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":00", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":15", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":15", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":15", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":30", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":30", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":30", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":45", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":45", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":45", vbLongTime)%>
																					<%next%>
																				</select>
																				<a href="javascript:document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;dateWin('txtStartDate');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a>
																			</td>
																		</tr>
																		<tr>
																			<td></td>
																			<td nowrap=true>
																				<font style="font-family:Arial,Helvetica;font-size:10px;color:#666666">
																				(MM/DD/YY)
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
															<tr>
																<td>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																	<b>End Date</b>
																	</font>
																</td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseEndDate"<%if not boolUseEndDate then Response.Write " CHECKED" end if%>></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseEndDate[0].checked=true;">This document never expires.</span>
																				</font>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseEndDate"<%if boolUseEndDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;">This document will end on the following date:</span>
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./../images/spacer.gif" height=5 width=1 border=0></td></tr>
															<tr>
																<td nowrap=true>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
																			<td nowrap=true>
																				<input type=text name="txtEndDate" value="<%=txtEndDate%>" size=10 maxlength=10 onFocus="document.theForm.boolUseEndDate[1].checked=true;" AutoComplete="off">
																				<select name="txtEndTime" onFocus="document.theForm.boolUseEndDate[1].checked=true;">
																					<%for i = 0 to 23%>
																					<option value="<%=FormatDateTime(i & ":00", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":00", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":00", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":15", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":15", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":15", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":30", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":30", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":30", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":45", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":45", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":45", vbLongTime)%>
																					<%next%>
																				</select>
																				<a href="javascript:document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;dateWin('txtEndDate');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a>
																			</td>
																		</tr>
																		<tr>
																			<td></td>
																			<td nowrap=true>
																				<font style="font-family:Arial,Helvetica;font-size:10px;color:#666666">
																				(MM/DD/YY)
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
														</table>
													</div>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<input type=hidden name="categoryID" value="<%=categoryID%>">
	<input type=hidden name="topicID" value="<%=topicID%>">
	<input type=hidden name="boolIsNewDocument" value="<%=boolIsNewDocument%>">
	<input type=hidden name="NewDocumentStatus" value="0">
	<input type=hidden name="keeplocked" value="0">
	<input type=hidden name="CurrentSelectedLanguageOrdinal" value="<%=defaultLanguageOrdinal%>">
	<input type=hidden name="totNumlanguages" value="<%=dictLanguagesDataCols("RecordCount")%>">
	<%
	if dictLanguagesDataCols("RecordCount") > 0 then
		for rowCounter = 0 to dictLanguagesDataCols("RecordCount") - 1
			curIteration = rowCounter + 1

			Topic_Name			= ""
			Topic_Byline		= ""
			Topic_Summary		= ""
			Topic_Abstract		= ""
			Topic_Keywords		= ""
			Topic_Type			= 0
			Type1_FileName		= ""
			Type1_FileID		= 0
			Type2_LinkURL		= ""
			Topic_ContactInfo	= ""
			Topic_SourceWebsite	= ""
		'	UserDefinedField1	= ""
		'	UserDefinedField2	= ""
		'	UserDefinedField3	= ""
		'	UserDefinedField4	= ""
		'	UserDefinedField5	= ""
			isDefault			= Abs(CInt(CBool(arLanguagesDataRows(dictLanguagesDataCols("isDefault"), rowCounter))))

			if dictTopicDataCols("RecordCount") > 0 then
				masterLanguageID = CInt(arLanguagesDataRows(dictLanguagesDataCols("ID"), rowCounter))
				for i = 0 to dictTopicDataCols("RecordCount") - 1
					topicLanguageID = CInt(arTopicDataRows(dictTopicDataCols("Language_ID"), i))
					if CInt(topicLanguageID) = CInt(masterLanguageID) then
						Topic_Name			= Server.HTMLEncode(SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Name"), i), "CStr"))
						Topic_Byline		= Server.HTMLEncode(SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Byline"), i), "CStr"))
						Topic_Summary		= stripTextSizes(Server.HTMLEncode(SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Summary"), i), "CStr")))
						Topic_Abstract		= Server.HTMLEncode(SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Abstract"), i), "CStr"))
						Topic_Keywords		= Server.HTMLEncode(SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Keywords"), i), "CStr"))
						Topic_Type			= SmartValues(arTopicDataRows(dictTopicDataCols("Topic_Type"), i), "CInt")
						Type1_FileName		= SmartValues(arTopicDataRows(dictTopicDataCols("Type1_FileName"), i), "CStr")
						Type1_FileID		= SmartValues(arTopicDataRows(dictTopicDataCols("Type1_FileID"), i), "CInt")
						Type2_LinkURL		= SmartValues(arTopicDataRows(dictTopicDataCols("Type2_LinkURL"), i), "CStr")
						Topic_ContactInfo	= SmartValues(arTopicDataRows(dictTopicDataCols("Topic_ContactInfo"), i), "CStr")
						Topic_SourceWebsite	= SmartValues(arTopicDataRows(dictTopicDataCols("Topic_SourceWebsite"), i), "CStr")
					'	UserDefinedField1	= SmartValues(arTopicDataRows(dictTopicDataCols("UserDefinedField1"), i), "CStr")
					'	UserDefinedField2	= SmartValues(arTopicDataRows(dictTopicDataCols("UserDefinedField2"), i), "CStr")
					'	UserDefinedField3	= SmartValues(arTopicDataRows(dictTopicDataCols("UserDefinedField3"), i), "CStr")
					'	UserDefinedField4	= SmartValues(arTopicDataRows(dictTopicDataCols("UserDefinedField4"), i), "CStr")
					'	UserDefinedField5	= SmartValues(arTopicDataRows(dictTopicDataCols("UserDefinedField5"), i), "CStr")
						isDefault		= Abs(CInt(CBool(arTopicDataRows(dictTopicDataCols("Default_Language"), i))))
					end if
				next
			end if
	%>
	<!--
	'==============================================================================
	LANGUAGE_<%=curIteration%> DATA: <%=arLanguagesDataRows(dictLanguagesDataCols("Language_PrettyName"), rowCounter)%>
	'==============================================================================
	-->
		<input type=hidden name="lang<%=curIteration%>_langID" value="<%=arLanguagesDataRows(dictLanguagesDataCols("ID"), rowCounter)%>">
		<input type=hidden name="lang<%=curIteration%>_lang_prettyname" value="<%=arLanguagesDataRows(dictLanguagesDataCols("Language_PrettyName"), rowCounter)%>">

		<!-- ORIGINAL DATA FOR THIS LANGUAGE -->
		<input type=hidden name="lang<%=curIteration%>_orig_title" value="<%=Topic_Name%>">
		<input type=hidden name="lang<%=curIteration%>_orig_byline" value="<%=Topic_Byline%>">
		<input type=hidden name="lang<%=curIteration%>_orig_content" value="<%=Topic_Summary%>">
		<input type=hidden name="lang<%=curIteration%>_orig_abstract" value="<%=Topic_Abstract%>">
		<input type=hidden name="lang<%=curIteration%>_orig_keywords" value="<%=Topic_Keywords%>">
		<input type=hidden name="lang<%=curIteration%>_orig_boolDefault" value="<%=isDefault%>">
		<input type=hidden name="lang<%=curIteration%>_orig_type" value="<%=Topic_Type%>">
		<input type=hidden name="lang<%=curIteration%>_orig_filename" value="<%=Type1_FileName%>">
		<input type=hidden name="lang<%=curIteration%>_orig_fileID" value="<%=Type1_FileID%>">
		<input type=hidden name="lang<%=curIteration%>_orig_url" value="<%=Type2_LinkURL%>">
		<input type=hidden name="lang<%=curIteration%>_orig_topic_contactinfo" value="<%=Topic_ContactInfo%>">
		<input type=hidden name="lang<%=curIteration%>_orig_topic_sourcewebsite" value="<%=Topic_SourceWebsite%>">
		<%if 1 = 2 then%>
		<input type=hidden name="lang<%=curIteration%>_orig_userdefinedfield1" value="<%=UserDefinedField1%>">
		<input type=hidden name="lang<%=curIteration%>_orig_userdefinedfield2" value="<%=UserDefinedField2%>">
		<input type=hidden name="lang<%=curIteration%>_orig_userdefinedfield3" value="<%=UserDefinedField3%>">
		<input type=hidden name="lang<%=curIteration%>_orig_userdefinedfield4" value="<%=UserDefinedField4%>">
		<input type=hidden name="lang<%=curIteration%>_orig_userdefinedfield5" value="<%=UserDefinedField5%>">
		<%end if%>

		<!-- MODIFIED DATA FOR THIS LANGUAGE -->
		<input type=hidden name="lang<%=curIteration%>_dirty_title" value="<%=Topic_Name%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_byline" value="<%=Topic_Byline%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_content" value="<%=Topic_Summary%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_abstract" value="<%=Topic_Abstract%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_keywords" value="<%=Topic_Keywords%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_boolDefault" value="<%=isDefault%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_type" value="<%=Topic_Type%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_filename" value="<%=Type1_FileName%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_fileID" value="<%=Type1_FileID%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_url" value="<%=Type2_LinkURL%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_topic_contactinfo" value="<%=Topic_ContactInfo%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_topic_sourcewebsite" value="<%=Topic_SourceWebsite%>">
		<%if 1 = 2 then%>
		<input type=hidden name="lang<%=curIteration%>_dirty_userdefinedfield1" value="<%=UserDefinedField1%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_userdefinedfield2" value="<%=UserDefinedField2%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_userdefinedfield3" value="<%=UserDefinedField3%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_userdefinedfield4" value="<%=UserDefinedField4%>">
		<input type=hidden name="lang<%=curIteration%>_dirty_userdefinedfield5" value="<%=UserDefinedField5%>">
		<%end if%>

	<%
		next
	end if
	%>
		<input type=hidden name="boolIsPublishedItemCopy" value="<%=boolIsPublishedItemCopy%>">
	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "document_details_header.asp?pub=<%=Request("pub")%>&tid=<%=topicID%>&cid=<%=categoryID%>";
		parent.frames["controls"].document.location = "document_details_footer.asp?pub=<%=Request("pub")%>&tid=<%=topicID%>&cid=<%=categoryID%>";
		
		<%if not boolIsNewDocument and not boolIsPublishedItemCopy then%>
		/*
		//Set a reference to the Details frame in the Repository frameset...
		var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	
		//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
		if (typeof(myFrameSetRef == 'object'))
		{
		//	myFrameSetRef.document.location.reload();
		}
		*/
		<%end if%>
		
		<%if boolIsPublishedItemCopy then%>
		alert("You are editing a copy of the selected Published document.");
		<%end if%>

		if ("<%=defaultLanguageOrdinal%>" != "<%=showLangOrdinal%>")
		{
			showContent(<%=showLangOrdinal%>);
		}

	//-->
</script>

<%
'Print data for debuggin'
if 1 = 2 then
	if dictLanguagesDataCols("RecordCount") > 0 then
		response.write "<table border='1'><tr>" & vbcrlf
		response.write "<tr>" & vbcrlf
		for i = 0 to dictLanguagesDataCols("ColCount")
			response.write "<td valign=top>" & dictLanguagesDataCols("COL_" & i) & "</td>" & vbcrlf 
		next
		response.write "</tr>" & vbcrlf
		for rowCounter = 0 to dictLanguagesDataCols("RecordCount") - 1
			response.write "<tr>" & vbcrlf
			for i = 0 to dictLanguagesDataCols("ColCount")
				response.write "<td valign=top>" & arLanguagesDataRows(i, rowCounter) & "</td>" & vbcrlf 
			next
			response.write "</tr>" & vbcrlf
		next
		response.write "</table>" 
	end if

	if dictTopicDataCols("RecordCount") > 0 then
		response.write "<table border='1'><tr>" & vbcrlf
		response.write "<tr>" & vbcrlf
		for i = 0 to dictTopicDataCols("ColCount")
			response.write "<td valign=top>" & dictTopicDataCols("COL_" & i) & "</td>" & vbcrlf 
		next
		response.write "</tr>" & vbcrlf
		for rowCounter = 0 to dictTopicDataCols("RecordCount") - 1
			response.write "<tr>" & vbcrlf
			for i = 0 to dictTopicDataCols("ColCount")
				response.write "<td valign=top>" & arTopicDataRows(i, rowCounter) & "</td>" & vbcrlf 
			next
			response.write "</tr>" & vbcrlf
		next
		response.write "</table>" 
	end if

	if dictScheduleDataCols("RecordCount") > 0 then
		response.write "<table border='1'><tr>" & vbcrlf
		response.write "<tr>" & vbcrlf
		for i = 0 to dictScheduleDataCols("ColCount")
			response.write "<td valign=top>" & dictScheduleDataCols("COL_" & i) & "</td>" & vbcrlf 
		next
		response.write "</tr>" & vbcrlf
		for rowCounter = 0 to dictScheduleDataCols("RecordCount") - 1
			response.write "<tr>" & vbcrlf
			for i = 0 to dictScheduleDataCols("ColCount")
				response.write "<td valign=top>" & arScheduleDataRows(i, rowCounter) & "</td>" & vbcrlf 
			next
			response.write "</tr>" & vbcrlf
		next
		response.write "</table>" 
	end if
end if
%>

<script language="javascript">
//printEvaluator()
</script>



</body>
</html>

<%
Call DB_CleanUp
Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

	if objRec.State <> adStateClosed then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing
End Sub

Set arLanguagesDataRows = Nothing
Set dictLanguagesDataCols = Nothing

Set arTopicDataRows = Nothing
Set dictTopicDataCols = Nothing

Set arScheduleDataRows = Nothing
Set dictScheduleDataCols = Nothing
%>