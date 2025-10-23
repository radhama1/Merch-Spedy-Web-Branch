// File:            colorpicker.js
// Description:     For QWebEditor
//
// Copyright (c) Q-Surf Computing Solutions, 2003-05. All rights reserved.
// http://www.qwebeditor.com

var g_cpDisableEventProcessing = false
// holds all created color pickers
var g_cpArray = new Array()

// close all color picker popups
function cpCloseAllPopups()
{
	for (var i = 0; i < g_cpArray.length; i ++) {
		PopupHide(g_cpArray[i])
	}
}

// temporary disable event processing.
// used to autoclose (by clicking on window area) color pickers for mozilla.
// mozilla uses layer to implement color pickers.
// so, want to capture onclick for content area and close color pickers.
// however, when the color picker is clicked, the content area got the onclick
// message and close the window right away. this function just set a flag
// and tell window content area onclick handler not to close the color picker.
function cpDisableEventProcessing(duration)
{
	g_cpDisableEventProcessing = true
	// resume processing after so many milliseconds
	window.setTimeout("cpResumeEventProcessing()", duration)
}

function cpResumeEventProcessing()
{
	g_cpDisableEventProcessing = false
}

function cpOnWindowClicked()
{
	if (!g_cpDisableEventProcessing)
	{
		cpCloseAllPopups()
	}
}

// show the color picker
// colorpicker - handle created by cpCreate
// parentobj - x, y will be relative to this parentobj on screen. 
//     can be a button or even document.body
// x, y - x, y coordinates
function cpShow(colorpicker, parentobj, x, y)
{
	cpCloseAllPopups(); 
	cpDisableEventProcessing(1); 
	PopupShow(colorpicker, x, y, 104, 84, parentobj)
}

// create a color picker.
// strFunc - callback function name
function cpCreate(strFunc)
{
	var popup = CreatePopup()

    // color dialog
    var arrColor=new Array(
        new Array("ff0000","400000","800000","c00000","ff4040","ff8080","ffc0c0","000000"),
        new Array("ff8000","402000","804000","c06000","ffa040","ffc080","ffe0c0","171717"),
        new Array("ffff00","404000","808000","c0c000","ffff40","ffff80","ffffc0","2e2e2e"),
        new Array("80ff00","204000","408000","60c000","a0ff40","c0ff80","e0ffc0","464646"),
        new Array("00ff00","004000","008000","00c000","40ff40","80ff80","c0ffc0","5d5d5d"),
        new Array("00ff80","004020","008040","00c060","40ffa0","80ffc0","c0ffe0","747474"),
        new Array("00ffff","004040","008080","00c0c0","40ffff","80ffff","c0ffff","8b8b8b"),
        new Array("0080ff","002040","004080","0060c0","40a0ff","80c0ff","c0e0ff","a2a2a2"),
        new Array("0000ff","000040","000080","0000c0","4040ff","8080ff","c0c0ff","b9b9b9"),
        new Array("8000ff","200040","400080","6000c0","a040ff","c080ff","e0c0ff","d1d1d1"),
        new Array("ff00ff","400040","800080","c000c0","ff40ff","ff80ff","ffc0ff","e8e8e8"),
        new Array("ff0080","400020","800040","c00060","ff40a0","ff80c0","ffc0e0","ffffff"));
    var str=new String();
    var strParent=(!popup.bDiv)?"parent.":''
    for (i=0;i<arrColor.length;i++)
    {
        for (j=0;j<arrColor[i].length;j++)
        {
            var coords = (j*13)+","+(i*7)+","+((j+1)*13)+","+((i+1)*7)
            str=str+"<area shape=\"rect\" coords=\""+coords
                +"\" onclick=\"javascript: "+strParent+strFunc+"('#"+arrColor[i][j]+"')\" title=\"#"+arrColor[i][j]+"\" />"
        }
    }
    PopupSetContent(popup,
		"<div oncontextmenu=\"return false\" style=\"position: relative; top:0; left:0; border:2px solid threedshadow;  border-top:2px solid threedhighlight; border-left:2px solid threedhighlight; background: threedshadow; height:100%; width:100%;\">\n" +
        "<map name=\"colormap_"+g_cpArray.length+"\">" + str +"</map>" + 
        "<img src="+g_strHtmlEditPath+"/htmleditimg/colortable.gif width=104 height=84 alt=\"\" border=0 usemap=\"#colormap_"+g_cpArray.length+"\" style=\"cursor: pointer;\" />" +
        "</div>")
     
    // using DIV to implement popup. need to close it manually   
	if (popup.bDiv && g_cpArray.length == 0) {
    	AttachEventListener(window,"click",cpOnWindowClicked)
	}
	
	g_cpArray[g_cpArray.length] = popup
	
	return popup
}
