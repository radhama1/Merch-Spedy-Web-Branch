//<!--
// client-side JavaScript client sniffer. 
// Copyright (c) Q-Surf Computing Solutions, 2005. All rights reserved.
var agt=navigator.userAgent.toLowerCase()
var g_heBrowser = {
	"browser":"",
	"version":"",
	"os":"",
	"gecko":false,
	"geckoVersion":0,
	"dom1":false
	}

// following browser spoof other browsers.
// so detect them first.
if(agt.indexOf("opera")!=-1){
	g_heBrowser.browser="opera"
	var reg=/opera( |\/)([0-9]+\.[0-9])/
	reg.exec(agt)
	g_heBrowser.version=RegExp.$2
}
else if(agt.indexOf("konqueror")!=-1){
	g_heBrowser.browser="konqueror"
	var reg=/konqueror( |\/)([0-9]+\.[0-9])/
	reg.exec(agt)
	g_heBrowser.version=RegExp.$2
}
else if(agt.indexOf("safari")!=-1){
	g_heBrowser.browser="safari"
	var reg=/safari( |\/)([0-9]+\.[0-9])/
	reg.exec(agt)
	g_heBrowser.version=RegExp.$2
}

// resume detection
if(g_heBrowser.browser.length==0){
	g_heBrowser.gecko=agt.indexOf('gecko')!=-1
	g_heBrowser.geckoVersion=agt.indexOf('gecko')
	if(g_heBrowser.geckoVersion>0)g_heBrowser.geckoVersion=parseInt(agt.substr(g_heBrowser.geckoVersion+6,8))

	if(agt.indexOf("lynx")!=-1){
		g_heBrowser.browser="lynx"
	}
    else if(agt.indexOf("links")!=-1){
		g_heBrowser.browser="links"
	}
	else if(agt.indexOf("bot")!=-1||
		agt.indexOf("google")!=-1||
		agt.indexOf("scooter")!=-1||
		agt.indexOf("slurp")!=-1||
		agt.indexOf("spider")!=-1||
		agt.indexOf("spider")!=-1){
		g_heBrowser.browser="bot"
	}
	else if(agt.indexOf("msie")!=-1){
		g_heBrowser.browser="msie"
		var reg=/msie( |\/)([0-9]+\.[0-9])/
		reg.exec(agt)
		g_heBrowser.version=RegExp.$2
	}
	else if(agt.indexOf("netscape")!=-1){
		g_heBrowser.browser="netscape"
		var reg=/netscape( |\/)([0-9]+\.[0-9])/
		reg.exec(agt)
		g_heBrowser.version=RegExp.$2
	}
	else if(agt.indexOf("firefox")!=-1){
		g_heBrowser.browser="firefox"
		var reg=/firefox( |\/)([0-9]+\.[0-9])/
		reg.exec(agt)
		g_heBrowser.version=RegExp.$2
	}
	else if(agt.indexOf("mozilla")!=-1){
		g_heBrowser.browser="mozilla"
		var reg=/rv:([0-9]+\.[0-9])/
		reg.exec(agt)
		g_heBrowser.version=RegExp.$1
	}
	else if(agt.indexOf("hotjava")!=-1){
		g_heBrowser.browser="hotjava"
	}	
	else{
		g_heBrowser.browser="other"
	}
}

if(agt.indexOf("win")){
	if ((agt.indexOf("win16")!=-1) ||
	    (agt.indexOf("16bit")!=-1) || (agt.indexOf("windows 3.1")!=-1) ||
    	(agt.indexOf("windows 16-bit")!=-1)){
		g_heBrowser.os="win16"
	}
	else{
		g_heBrowser.os="win32"
	}
}
else if(agt.indexOf("linux")){
	g_heBrowser.os="linux"
}
else if(agt.indexOf("mac")){
	g_heBrowser.os="mac"
}
else if(agt.indexOf("sunos")){
	g_heBrowser.os="sunos"
}
else if(agt.indexOf("freebsd")){
	g_heBrowser.os="freebsd"
}
else if(agt.indexOf("irix")){
	g_heBrowser.os="irix"
}
else if(agt.indexOf("beos")){
	g_heBrowser.os="beos"
}
else if(agt.indexOf("os/2")){
	g_heBrowser.os="os/2"
}
else if(agt.indexOf("aix")){
	g_heBrowser.os="aix"
}
else {
	g_heBrowser.os="other"
}

g_heBrowser.dom1=((document.getElementById) ? true : false)

// following used by qwebeditor
var is_ie=g_heBrowser.browser=="msie"
var is_gecko=g_heBrowser.gecko
var is_safari=g_heBrowser.browser=="safari"
var is_ie6up=is_ie&&g_heBrowser.version>=6
var is_nav4=g_heBrowser.browser=="netscape"&&g_heBrowser.version<5

var has_htmledit = (g_heBrowser.os=="win32"&&g_heBrowser.browser=="msie"&&g_heBrowser.version>=5.5)
    ||(g_heBrowser.gecko&&g_heBrowser.geckoVersion>=20030624) // Netscape 7.1 (20030624), Mozilla 1.4 (20030630)
	||(g_heBrowser.browser=="safari"&&g_heBrowser.version>=412)
	
//--> end hide Javascript
