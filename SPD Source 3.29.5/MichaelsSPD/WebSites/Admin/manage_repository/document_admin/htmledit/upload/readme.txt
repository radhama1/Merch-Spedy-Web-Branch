Image browsing feature for QWebEditor

QWebEditor supports using a popup dialog for selecting images. It is not an integrated component for
QWebEditor since the main goal for QWebEditor relies on client sided scripts instead of particular server 
requirements. Moreover, the current design allows you to use third party photo gallery as the image 
browser. 

If image browsing is enabled, an additional button will be displayed beside image URL text box in the 
insert image dialog box. The currect version of QWebEditor provides a PHP example and a HTML template 
for the image browser. The HTML template (browseimages.html) demonstrates the minimal code to 
implement the image browser. And, the PHP example (browseimages.php) is a complete implementation of 
the image browser.

browseimages.php 

It has the following features:
	* Display all images in the images directory (a directory in your server)
	* Upload images to images directory
	* Create thumbnail for uploaded image
To use this file, you must set the upload/images directory and upload/images/thumbs directories to world 
writable and therefore the script can write the uploaded images and thumbnails to them. Then, you should 
modify some settings in browseimages.php. You should especially check out the followings: 
$bSupportGD2, $bSupportReadingJpeg, $bSupportReadingGif and $bSupportReadingPng. These settings
specifies the PHP image library capabilities and it affects the thumbnails generation. At the end, you
should tell QWebEditor to use browseimages.php as the image browser. If you are using the JavaScript
interface, you should specify "g_strHtmlEditImgUrl" variable. For example,

<!-- Initialize the QWebEditor library --><script language="javascript"><!--
// some important global variables
var g_strHtmlEditPath = "/htmledit/"
var g_strHtmlEditImgUrl = "/htmledit/upload/browseimages.php"
var g_strHtmlEditLangFile = "lang_eng.js"

If you are using the PHP interface, you should specify the second argument of HtmlEditInit()
function:

HtmlEditInit("/htmledit/", "/htmledit/upload/browseimages.php");

You can specify an absolute URL or an URL relative to where QWebEditor installed for the argument.

If you are using the ASP interface, please refer to browseimage.asp for details.