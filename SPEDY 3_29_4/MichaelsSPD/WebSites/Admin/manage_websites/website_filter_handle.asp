<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, SQLStr, connStr
Dim SortColumn, SortDirection

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) then
	SortColumn = CInt(SortColumn)
else
	SortColumn = 0
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) then
	SortDirection = CInt(SortDirection)
else
	SortDirection = 0
end if
%>
<html>
<head>
	<title></title>
	<style type="text/css">
		@import url('./../app_include/global.css');
		A {text-decoration: none; color: #000;}
		A:HOVER {text-decoration: none; color: #00f;}

		BODY
		{
			margin: 0;
			padding: 0;
			background: #ccc;
			text-align: center;
		}

		INPUT * {font-family: Arial, Helvetica; font-size:12px; color:#000;}
		SELECT {font-family: Arial, Helvetica; font-size:11px; color:#000;}
		TEXTAREA {font-family: Arial, Helvetica; font-size:12px; color:#000;}
		UL {list-style: square; margin-left: 20px;}

	</style>
	<script language="javascript" src="./../app_include/resizeFrame.js"></script>
	<script language="javascript" src="./../app_include/tween/tween.js"></script>
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
	<script language="javascript">
		
		var filterFrameMinHeight		= 10;							// desired minimum height of filter frame when closed
		var filterFrameMaxHeight		= getFilterFrameMaxHeight();	// desired maximum height of filter frame when opened
		var ParentFramesetPath			= parent.frames;				// path up to frameset
		var ParentFramesetName			= "WebsiteWrapperFrameset";		// id assigned to frameset
		var FramesetType				= "rows";						// rows or cols
		var DimensionsPrefixString		= "25,4,";						// string to precede the filter frame dimension
		var DimensionsSuffixString		= ",*";							// string to follow the filter frame dimension
		var useEffects					= true							// true or false
		
		function setFilterFrameMaxHeight()
		{
			filterFrameMaxHeight = getFilterFrameMaxHeight();
		}
		
		function getFilterFrameMaxHeight()
		{
			if (parent.frames["FilterFrame"]) {
					
				if(parent.frames["FilterFrame"].document.getElementById('LastFilterDiv')) {
					return 1 * parent.frames["FilterFrame"].getFrameHeight() + 20;
				}
				else {
					return 0;
				}
			} 
			else {
				return 0;
			}
		}
		function openFilterFrame()
		{
			if (useEffects)
			{
				var FilterFrameTween = new Tween(new Object(),'',Tween.backEaseOut,filterFrameMinHeight,filterFrameMaxHeight,0.5);
				FilterFrameTween.onMotionChanged = function(event){
					resizeFrame(DimensionsPrefixString + Math.round(event.target._pos) + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);
				};
				FilterFrameTween.start();
			}
			else
			{
				resizeFrame(DimensionsPrefixString + filterFrameMaxHeight + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);
			}
		}
		
		function closeFilterFrame()
		{
			if (useEffects)
			{
				var FilterFrameTween = new Tween(new Object(),'',Tween.backEaseIn,filterFrameMaxHeight,filterFrameMinHeight,0.3);
				FilterFrameTween.onMotionChanged = function(event){
					resizeFrame(DimensionsPrefixString + Math.round(event.target._pos) + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);
				};
				FilterFrameTween.start();
			}
			else
			{
				resizeFrame(DimensionsPrefixString + filterFrameMinHeight + DimensionsSuffixString, ParentFramesetName, ParentFramesetPath, FramesetType);
			}
		}
		
		function toggleFilterFrame()
		{
			if(!ParentFramesetPath) return false;
			if(!ParentFramesetPath.document) return false;
			if(!ParentFramesetPath.document.getElementById(ParentFramesetName)) return false;
			
			var targetObject;
			
			setFilterFrameMaxHeight();
			
			if(FramesetType == "rows")
			{
				if(!ParentFramesetPath.document.getElementById(ParentFramesetName).rows) return false;
				targetObject = ParentFramesetPath.document.getElementById(ParentFramesetName).rows;
			}
			
			if(FramesetType == "cols")
			{
				if(!ParentFramesetPath.document.getElementById(ParentFramesetName).cols) return false;
				targetObject = ParentFramesetPath.document.getElementById(ParentFramesetName).cols;
			}

			if(targetObject == DimensionsPrefixString + filterFrameMinHeight + DimensionsSuffixString)
			{
					openFilterFrame();
					resizeBar.src = "./../app_images/resize_frame_3_up.gif";
			}
			else
			{
					closeFilterFrame();
					resizeBar.src = "./../app_images/resize_frame_3_dn.gif";
			}
		}
		
	</script>
</head>
<body topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onselectstart="return false">
<div id="FrameHandleDiv"></div>
<table cellpadding=0 cellspacing=0 onselectstart="return false" border=0 width=100%>
	<tr><td bgcolor=cccccc><img src="./images/spacer.gif" height=1 width=1></td></tr>
	<tr><td bgcolor=cccccc width=100% align=center valign=top><img id="resizeBar" name="resizeBar" src="./../app_images/resize_frame_3_dn.gif" onclick="toggleFilterFrame(); return false;" alt="Show/Hide Filter Options" style="border: 0; cursor: hand;"></td></tr>
	<tr><td bgcolor=cccccc><img src="./images/spacer.gif" height=2 width=1></td></tr>
</table>

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

%>