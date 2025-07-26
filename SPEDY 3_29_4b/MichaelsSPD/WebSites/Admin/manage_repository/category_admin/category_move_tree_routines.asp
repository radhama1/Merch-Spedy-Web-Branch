<%

'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
'This function loads XML data into an instance
'of an MSXML object.  objDocument is an empty variable that will return
'a populated XML document object.  bLoadSubItems is a Boolean that indicates 
'whether we want our "Load on Demand" folder loaded with subitems. If 
'the data is loaded successfully, the function returns TRUE, otherwise 
'it returns FALSE.
Function fnLoadXMLData(byRef objDocument, bLoadSubItems)
	Dim bResult
	bResult = true
	
'	on error resume next
	
	'Create instance of XML document object that we can manipulate
	Set objDocument = Server.CreateObject("MSXML2.FreeThreadedDOMDocument.3.0")

	if objDocument is nothing then
		Response.Write "objDocument object not created<br>"
		bResult = false
	else
		If Err Then 
			Response.Write "XML Document Object Creation Error - <BR>"
			Response.write Err.Description & "<BR>"
			bResult = false
		else
			
		'	on error resume next
			
			'Create the root folder
			Set objRootNode = objDocument.createElement("RootNode")						'XML tag name
			objRootNode.setAttribute("value") = "Content Repository"					'Display text
			objRootNode.setAttribute("type") = "root"									'Root/Folder/Document
			objRootNode.setAttribute("cid") = 0
			objRootNode.setAttribute("url") = "javascript: setTargetItemID('0'); void(0);"
			
			Dim objConn, connstr
			Dim objRootNode, objChildNode, tempNode
			
			Set objConn = Server.CreateObject("ADODB.Connection")
			connStr = Application.Value("connStr")
			objConn.Open connStr

	'		on error resume next
	
			'Append child nodes to the Root Node
			Call fnDescendTree(0, objDocument, objRootNode, objConn)

			objConn.Close
			Set objConn = nothing

			'Now append the root node to the main document node
			objDocument.appendChild objRootNode

			Set objRootNode = Nothing
			
			if err <> 0 then
				Response.Write err.Description & "<BR>"
				bResult = false
				err = 0
			end if
		end if
	end if
	
	fnLoadXMLData = bResult
End Function







'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
Function fnDescendTree(byVal intRootNodeRefID, byRef objDocument, byRef objRootNode, ByRef objConn)
	Dim bResult
	bResult = true
	
'	on error resume next
	
	if objDocument is nothing then
		Response.Write "objRootNode object not passed to recursive function ""fnDescendTree""<br>"
		bResult = false
	else
		If Err Then 
			Response.Write "byRef XML Document Object Reference Error - objRootNode<BR>"
			Response.write Err.Description & "<BR>"
			bResult = false
		else
			''''''''''''''''''''''
			' Declare our Objects and Variables here
			'''''''''''''''''''''
			Dim objRec, SQLStr
			Dim objChildNode
			
			Set objRec = Server.CreateObject("ADODB.RecordSet")
			
		'	on error resume next
					
			'SQLStr = "sp_repository_cats_by_catID " & intRootNodeRefID
			SQLStr = "sp_repository_cats_by_catID @CategoryID='0" & intRootNodeRefID & "', @UserID='0" & Session.Value("UserID") & "'"
			objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
			
			if not objRec.EOF then
				'Create a node in the XML document object for each subitem
				Do Until objRec.EOF
					Set objChildNode = objDocument.createElement("ChildNode" & objRec("ID"))
					objChildNode.setAttribute("value") = objRec("Category_Name")
					objChildNode.setAttribute("type") = "folder"
					objChildNode.setAttribute("cid") = objRec("ID")
					objChildNode.setAttribute("url") = "javascript: setTargetItemID('" & CInt(objRec("ID")) & "'); void(0);"
					objRootNode.appendChild objChildNode 'Attach the new node to its parent
						
					if CBool(objRec("hasChildren")) then
						Call fnDescendTree(objRec("ID"), objDocument, objChildNode, objConn)
					end if
						
					objRec.MoveNext
				Loop
				objRec.Close
			
				'Attach the child folder node to the root node
				objRootNode.appendChild objChildNode
												
				Set objChildNode = Nothing
			end if

			Set objRec = nothing
			
			if err <> 0 then
				Response.Write err.Description & "<BR>"
				bResult = false
				err = 0
			end if
		end if
	end if
	
	fnDescendTree = bResult
End Function







'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
'This subroutine is the workhorse of our menu page.  It is responsible for 
'traversing the XML tree to display each menu item.  The routine calls itself
'recursively and generates an HTML page containing javascript that handles
'showing/hiding menu items.
'[Parameters]
'--------------------
'objNodes :	The XML object containing our menu data
'iElement :	Passed by reference, this value increments twice each time we add
'			a new menu item.  The first time it increments, the value is to identify the 
'			menu item.  The value is immediately incremented and this time is used to
'			identify the element that will be shown/hidden
'sLeftIndent :	Passed by reference, this string accumulates the <td> and <img> tags necessary
'				to display empty space and dotted lines to the left of the menu item as
'				the item gets indented in the list.
'sOpenFolders :	This string contains values that tell the subroutine
'					which folders should be displayed as "open" by default.
Sub DisplayNode(ByVal objNodes, ByRef iElement, ByRef sLeftIndent, byRef sOpenFolders)
'	on error resume next
	
	Dim oNode, sAttrValue, sNodeType, sURL, sNodeName, sCatID
	Dim NODE_ELEMENT
	Dim sTempLeft, bHasChildren, bIsLast, bIsRoot, bShowOpen
	Dim sMode
	
	NODE_ELEMENT = 1
	iElement = iElement + 1
	For Each oNode In objNodes
		'Find out if current node has children
		bHasChildren = oNode.hasChildNodes
		
		'Find out if the current node is the last member
		'in the list or not
		if not(oNode.nextSibling is nothing) then
			bIsLast = false
		else
			bIsLast = true
		end if
		
		'Ignore NODE_TEXT node types
		if oNode.nodeType = NODE_ELEMENT Then
			sNodeName = oNode.nodeName
			sAttrValue = oNode.getAttribute("value")			'Get the display value of the current node 
			sNodeType = lcase(oNode.getAttribute("type"))		'Get the type of the current node Folder/Document
			sURL = oNode.getAttribute("url")
			sCatID = oNode.getAttribute("cid")
			
			'Find out if this is the root of the tree
			if (sNodeType = "root") then
				bIsRoot = true
			else
				bIsRoot = false
			end if

			'We set the LoadOnDemand value for the ChildNode folder
			'because we want it to be populated only when clicked by the user
			if (sNodeName = "ChildNode") then
				sMode = "LoadOnDemand"
			else
				sMode = ""
			end if
			
			if (sNodeType = "document") then
%><%=vbCrLf%><table border=0 cellspacing=0 cellpadding=0><tr><%
Response.write sLeftIndent  'Display the proper indentation formatting
						
'Now display the document node
%><td height="16"><img src="./../../app_images/folderlist_icons/<%=fnChooseIcon(bIsLast, bIsRoot, sNodeType, bHasChildren, true)%>" width=31 height=16 border=0></td><td><img src="./../../app_images/folderlist_icons/pixel.gif" width=2 height=1></td><td nowrap class=node><img src="./../../app_images/folderlist_icons/pixel.gif" width=2 height=1><a href=<%=sURL%> onClick=objPreviousLink=fnSelectItem(this,objPreviousLink)><%=sAttrValue%></a><img src="./../../app_images/folderlist_icons/pixel.gif" width=2 height=1></td></tr></table><%
			else  'Otherwise this is a folder
%><%=vbCrLf%><table border=0 cellspacing=0 cellpadding=0><!-- Category_ID: <%=sCatID%> --><tr><%

'Check if we are building the tree for the first time
if (Request.Form = "") then
	if (sNodeType = "root") then
		bShowOpen = true 'We want the root folder open by default
		sOpenFolders = sOpenFolders & "," & iElement
	else
		bShowOpen = false
	end if
else
	'Read the hidden field to determine if the current folder
	'should be displayed as Open
	bShowOpen = fnGetFolderStatus(iElement, sOpenFolders)
end if
			
Response.write sLeftIndent  'Display the proper indentation formatting
							
'Now display the folder
%><td height="16"><img onclick="doChangeTree(this, arClickedElementID, arAffectedMenuItemID);" class=LEVEL<%=iElement%> src="./../../app_images/folderlist_icons/<%=fnChooseIcon(bIsLast, bIsRoot, sNodeType, bHasChildren, bShowOpen)%>" id=<%=iElement%> width=31 height=16 border=0 name="<%=sMode%>"></td><td><img src="./../../app_images/folderlist_icons/pixel.gif" width=2 height=1></td><td nowrap class=node><img src="./../../app_images/folderlist_icons/pixel.gif" width=2 height=1><a href="<%=sURL%>" onMouseOver="window.status='';return true;" onClick="objPreviousLink=fnSelectItem(this,objPreviousLink)"><%=sAttrValue%></a><img src="./../../app_images/folderlist_icons/pixel.gif" width=2 height=1></td></tr></table><%
				'Increment the element ID 
				iElement = iElement + 1
					
				'After displaying the folder, let's see
				'if it contains any submenu items	      
				If bHasChildren Then
%><%=vbCrLf%><table border=0 cellspacing=0 cellpadding=0><tr class=LEVEL<%=iElement%> id=<%=iElement%> style=display:<%if bShowOpen=false then%>none<%end if%>><td><%
'First store the indentation code
sTempLeft = sLeftIndent
						
'We don't want to indent the first node on our tree
'so only generate indent code if this not the root menu item
if (iElement > 1) then
	sLeftIndent = fnBuildLeftIndent(oNode, bIsLast, sLeftIndent)
end if
							
'Call this subroutine again to process the submenu item
DisplayNode oNode.childNodes, iElement, sLeftIndent, sOpenFolders
						
'We're popping the stack, so reset the value of sLeftIndent
'to what it was before we went into the DisplayNode() subroutine above
sLeftIndent = sTempLeft%></td></tr></table><%
				End If
			end if
		End If
	Next
	'Display any error messages encountered while executing this subroutine
	if err <> 0 then
		Response.Write err.description & "<br>"
	end if
End Sub







'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
'This function returns the appropriate icon to be displayed in the menu.  It decides
'which icon to return based on the parameters that are passed in.
'[Parameters]
'--------------------
'bIsLast :		TRUE/FALSE - is this the last child in the current list?
'bIsRoot :		TRUE/FALSE - is this the root node of the tree?
'sNodeType :	String containing "document", "folder", or "root".
'bHasChildren :	TRUE/FALSE - specifies if the current item has any children
'bShowOpen :	TRUE/FALSE - specifies if we want the folder open or closed icon displayed
function fnChooseIcon(byval bIsLast, byval bIsRoot, byval sNodeType, byval bHasChildren, byval bShowOpen)
	dim sIcon
	
	sIcon = ""
	
	if (sNodeType = "document") then  
		if (bIsLast = false) then
			sIcon = "docjoin.gif"  'This is not the last document in list, so use JOIN graphic
		else
			sIcon = "doc.gif"  'This is the last document on the list so use the DOC angle graphic
		end if
	else 
		if (bIsRoot = true) then
			'Root item requires special icon
			if (bShowOpen = true) then
				sIcon = "minusonly.gif"
			else
				sIcon = "plusonly.gif"
			end if
		elseif  (bHasChildren = true) then
			'Folder has children, so use default folder open icon
			if (bShowOpen = true) then
				sIcon = "folderopen.gif"
			else
				sIcon = "folderclosed.gif"
			end if
		elseif (bHasChildren = false) then
			'Folder does NOT have children, so first check
			'what order it is in the list
			if (bIsLast = false) then
				'Not the last member, so use an empty folder with a line join graphic
				sIcon = "folderclosedjoinempty.gif"	
			else
				'Is the last member, so use an empty folder with a line angle graphic
				sIcon = "folderclosedempty.gif"
			end if
		end if
	end if
	
	fnChooseIcon = sIcon
end function







'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
'This function builds the html code necessary for indenting the menu
'item.  This includes any graphics that may be necessary for showing
'a continuation of a dotted line.  The new string is returned by the function.
'[Parameters]
'--------------------
'oNode :	Object reference for a node
'bIsLast :	TRUE/FALSE - Is this the last child in the list?
'sLeftIndent :	String containing the html code for indenting the item
function fnBuildLeftIndent(byval oNode, byval bIsLast, byVal sLeftIndent)
	
	'Check to see if this node is the last on the 
	'list or if it has more siblings.  We set up our indent
	'accordingly.  We need to set this up before displaying
	'any of the node's children.
	if (bIsLast = false) then
		'This node is not the last on the list, so we need to create
		'an indent that contains a dotted line.
		sLeftIndent = sLeftIndent & "<td><img src=""./../../app_images/folderlist_icons/line.gif"" width=18 height=16></td>"
	else
		'Otherwise it is the last on the list so we just need to
		'display a blank space
		sLeftIndent = sLeftIndent & "<td><img src=""./../../app_images/folderlist_icons/pixel.gif"" width=20 height=1 border=0></td>"
	end if
	
	fnBuildLeftIndent = sLeftIndent
end function







'¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯`·.¸¸.·´¯
'Determines whether a folder needs to be displayed as Open or not.
'If the value of the iID is present in the hidden
'field that contains the IDs of all open folders, then we know 
'it should be Open.  Returns TRUE if folder should be open,
'otherwise FALSE is returned
function fnGetFolderStatus(iID, sOpenFolders)
	dim bReturn, sValue
	
	bReturn = false
	
	if (instr(sOpenFolders, CStr(iID))) then
		bReturn = true
	end if
	
	fnGetFolderStatus = bReturn
end function
%>