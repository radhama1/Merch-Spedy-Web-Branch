<?php
# File             : browseimages.php
# Programmer       : John Wong
# Copyright (c) Q-Surf Computing Solutions, 2003-2004. All rights reserved.
# http://www.q-surf.com

# configuration

# It specifies the directory where this script looks for images file.
# It can be a abs. path name or a path relative to qwebeditor installation directory.
# A trailing slash must be specified
$imagedir = "pages/images/";

# The following option specifies the URL to access image directory.
# It is used to construct the URL of the selected image.
$imagediruri = (isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"]) ? "https://" : "http://";   # probably exported by Apache only ...
$imagediruri .= $_SERVER["HTTP_HOST"];
$pos = strpos($_SERVER['REQUEST_URI'], "?");
if ($pos) {
    $uri = substr($_SERVER['REQUEST_URI'], 0, $pos);
}
else {
    $uri = $_SERVER['REQUEST_URI'];
}
$imagediruri .= substr($uri, 0, strlen($uri) - strlen('browseimages2.php'));
$imagediruri .= "pages/images/";

# Allows user to upload images?
$bAllowUpload = true;

# whether support image only
$bImageOnly = false;

# Max. allowed upload size in bytes
$lMaxUploadFileSize = 250000;

# copy command is used to copy the uploaded image file to images directory
# to avoid openbasedir problem. some servers are very restrictive and
# the upload directory is completely inaccessible from PHP functions.
# Using the system copy command to copy the image to accessible directory
# to get around the problem. If system copy command is not used, this script
# will use PHP copy function to transfer the uploaded files to image directory.
$bSysCopy = false;

# "cp" for unix and "copy" for windows
$strCopyCmd = "copy";

# Using Windows server? If so, need to change all forward slashes to backward
# slashes for copy command.
$bWin = true;

# thumbnail dimension in pixels
$thumbsize = 80;

# num thumbnail per row
$numcols = 4;

# end configuration

# if gd_info() is not available, uses the following code instead

$code = 'function gd_info() {
       $array = Array(
                       "GD Version" => "",
                       "FreeType Support" => 0,
                       "FreeType Support" => 0,
                       "FreeType Linkage" => "",
                       "T1Lib Support" => 0,
                       "GIF Read Support" => 0,
                       "GIF Create Support" => 0,
                       "JPG Support" => 0,
                       "PNG Support" => 0,
                       "WBMP Support" => 0,
                       "XBM Support" => 0
                     );
       $gif_support = 0;

       ob_start();
       eval("phpinfo();");
       $info = ob_get_contents();
       ob_end_clean();
     
       foreach(explode("\n", $info) as $line) {
           if(strpos($line, "GD Version")!==false)
               $array["GD Version"] = trim(str_replace("GD Version", "", strip_tags($line)));
           if(strpos($line, "FreeType Support")!==false)
               $array["FreeType Support"] = trim(str_replace("FreeType Support", "", strip_tags($line)));
           if(strpos($line, "FreeType Linkage")!==false)
               $array["FreeType Linkage"] = trim(str_replace("FreeType Linkage", "", strip_tags($line)));
           if(strpos($line, "T1Lib Support")!==false)
               $array["T1Lib Support"] = trim(str_replace("T1Lib Support", "", strip_tags($line)));
           if(strpos($line, "GIF Read Support")!==false)
               $array["GIF Read Support"] = trim(str_replace("GIF Read Support", "", strip_tags($line)));
           if(strpos($line, "GIF Create Support")!==false)
               $array["GIF Create Support"] = trim(str_replace("GIF Create Support", "", strip_tags($line)));
           if(strpos($line, "GIF Support")!==false)
               $gif_support = trim(str_replace("GIF Support", "", strip_tags($line)));
           if(strpos($line, "JPG Support")!==false)
               $array["JPG Support"] = trim(str_replace("JPG Support", "", strip_tags($line)));
           if(strpos($line, "PNG Support")!==false)
               $array["PNG Support"] = trim(str_replace("PNG Support", "", strip_tags($line)));
           if(strpos($line, "WBMP Support")!==false)
               $array["WBMP Support"] = trim(str_replace("WBMP Support", "", strip_tags($line)));
           if(strpos($line, "XBM Support")!==false)
               $array["XBM Support"] = trim(str_replace("XBM Support", "", strip_tags($line)));
       }
       
       if($gif_support==="enabled") {
           $array["GIF Read Support"]  = 1;
           $array["GIF Create Support"] = 1;
       }

       if($array["FreeType Support"]==="enabled"){
           $array["FreeType Support"] = 1;    }
 
       if($array["T1Lib Support"]==="enabled")
           $array["T1Lib Support"] = 1;    
       
       if($array["GIF Read Support"]==="enabled"){
           $array["GIF Read Support"] = 1;    }
 
       if($array["GIF Create Support"]==="enabled")
           $array["GIF Create Support"] = 1;    

       if($array["JPG Support"]==="enabled")
           $array["JPG Support"] = 1;
           
       if($array["PNG Support"]==="enabled")
           $array["PNG Support"] = 1;
           
       if($array["WBMP Support"]==="enabled")
           $array["WBMP Support"] = 1;
           
       if($array["XBM Support"]==="enabled")
           $array["XBM Support"] = 1;
       
       return $array;
   }';

if(!function_exists("gd_info")) eval($code);

# try to find out gd capabilities
$arrGdCap = gd_info();
$bSupportGD2 = substr($arrGdCap['GD Version'], strpos($arrGdCap['GD Version'], "(") + 1, 1) > 1;
$bSupportReadingJpeg = $arrGdCap['GIF Read Support'];
$bSupportReadingGif = $arrGdCap['JPG Support'];
$bSupportReadingPng = $arrGdCap['PNG Support'];

# saving the uploaded image
if (isset($HTTP_POST_VARS['mysubmit']) && $HTTP_POST_VARS['mysubmit'])
{
    if ($HTTP_POST_FILES['binImage']['tmp_name'] &&
        $HTTP_POST_FILES['binImage']['tmp_name'] != "none")
    {
        $dstfile = $imagedir . $HTTP_POST_FILES['binImage']['name'];

		if (file_exists($dstfile)) {
            $msg = "File exists. Please delete existing one before uploading a new one.";
        }
		else if (filesize($HTTP_POST_FILES['binImage']['tmp_name']) > $lMaxUploadFileSize) {
			$msg = "Uploaded file's size exceeds allowed size $lMaxUploadFileSize bytes.";
		}
        else {
            # attempt to copy the uploaded image to images directory
            if ($bSysCopy) {
                $cmd = $strCopyCmd . " " . $HTTP_POST_FILES['binImage']['tmp_name'] . " " . $dstfile;
                if ($bWin) $cmd = str_replace('/', "\\", $cmd);
                exec($cmd);
            }
            else {
                copy($HTTP_POST_FILES['binImage']['tmp_name'], $dstfile);
            }
            @chmod($dstfile, 0666);

            # if successful, attempt to open the image
            if (file_exists($dstfile))
            {
                $type = $HTTP_POST_FILES['binImage']['type'];
                if ($bSupportReadingJpeg && (eregi("jpeg", $type) || eregi("jpg", $type))) {
                    $hSrc = ImageCreateFromJpeg($dstfile);
                }
                else if ($bSupportReadingPng && eregi("png", $type)) {
                    $hSrc = ImageCreateFromPng($dstfile);
                }
                else if($bSupportReadingGif && eregi("gif", $type)) {
                    $hSrc = ImageCreateFromGif($dstfile);
                }

                # able to load the image, create thumbnail
                if (isset($hSrc) && $hSrc)
                {
                    # calculate thumbnail dimension
                    $srcw = (float) imagesx($hSrc);
                    $srch = (float) imagesy($hSrc);
                    $filesize = @filesize($dstfile);
                    if ($srcw > $thumbsize || $srch > $thumbsize)
                    {
                        if (($srcw / $srch) > 1)
                        {
                            $dstw = $thumbsize;
                            $dsth = round($thumbsize * $srch / $srcw);
                        }
                        else
                        {
                            $dsth = $thumbsize;
                            $dstw = round($thumbsize * $srcw / $srch);
                        }
                    }
                    else
                    {
                        $dsth = $srch;
                        $dstw = $srcw;
                    }

                    # create thumbnail image and copy the source image to it
                    $hDst = ($bSupportGD2) ? ImageCreateTrueColor($dstw, $dsth) : ImageCreate($dstw, $dsth);
                    ImagePaletteCopy($hDst, $hSrc);
					$dstx = 0;
					$dsty = 0;
                    if ($bSupportGD2)
                        imagecopyresampled($hDst, $hSrc, $dstx, $dsty, 0, 0, $dstw, $dsth, $srcw, $srch);
                    else
                        imagecopyresized($hDst, $hSrc, $dstx, $dsty, 0, 0, $dstw, $dsth, $srcw, $srch);

                    # save the thumbnail image
                    $thumbfile = $imagedir."thumbs/".$HTTP_POST_FILES['binImage']['name'].".jpg";
                    ImageJpeg($hDst, $thumbfile);
                    @chmod($thumbfile, 0666);

					# write the stat file
					$fh = @fopen($imagedir."thumbs/".$HTTP_POST_FILES['binImage']['name'].".txt", "w+");
					if ($fh) {
						fputs($fh, "$srcw,$srch,$filesize");
						fclose($fh);
					}
					
                    $msg = "Image uploaded successfully.";
                }
                else if ($bImageOnly)
                {
                    unlink($dstfile);
                    $msg = "Unable to read the image. It may not be a valid image.";
                }
            }
            else
            {
                $msg = "Unable to save the image. Please contact your system administrator.";
            }
        }
	}
}
else if (isset($HTTP_GET_VARS['action'])
	&& $HTTP_GET_VARS['action'] == 'delete' 
    && isset($HTTP_GET_VARS['file'])
    && file_exists($imagedir.str_replace("..", "", $HTTP_GET_VARS['file'])))
{
	$file=str_replace("..","",$HTTP_GET_VARS['file']);
    @unlink($imagedir.$file);
    @unlink($imagedir.'thumbs/'.$file.".jpg");
    @unlink($imagedir.'thumbs/'.$file.".txt");
    $msg = "The file has been successfully deleted.";
}

?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Strict//EN">
<html>
<head>
<script language="javascript">
var charset = (top.opener.document.characterSet) ? top.opener.document.characterSet : top.opener.document.charset
document.write("<meta HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; CHARSET=" + charset + "\" />")
</script>
<script language="javascript">
var g_strHtmlEditPath = top.opener.g_strHtmlEditPath
var g_strHtmlEditLangFile = top.opener.g_strHtmlEditLangFile
function ijs(file){document.write("<scr"+"ipt language=\"javascript\" src=\""
	+g_strHtmlEditPath+file+"\"></scr"+"ipt>")}
ijs(g_strHtmlEditLangFile)
</script>
<title></title>
<LINK REL=STYLESHEET TYPE="text/css" HREF="../style.css">
<script language="javascript" src="../utils.js"></script>
<script language="javascript" src="../mydlg.js"></script>
<script language="javascript">
	top.document.title = "Browse ..."
	function OnSubmit(myform) {
		if (myform.imgurl.value.length) {
			var obj = new Object()
			obj.src = myform.imgurl.value
			if (myform.objtype.value == "image") {
				obj.type = "image"
				obj.align = myform.align.value
				obj.border = myform.border.value
				obj.alt = myform.alt.value
				obj.width = myform.width.value
				obj.height = myform.height.value
			}
			else if (myform.objtype.value == "flash") {
				obj.type = "flash"
				obj.width = myform.objWidth.value
				obj.height = myform.objHeight.value
			}
			else {
				obj.type = "other"
			}
			MyDlgHandleOK(obj)
		}
		else {
			window.alert(g_strHeTextEnterImageUrl)
		}
	}
	
	function ShowHideProperties() {
		var reImage = /\.(jpg|jpeg|png|gif)$/i
		var reFlash = /\.swf$/i
		
		if (reImage.test(document.myform.imgurl.value)) {
			document.myform.objtype.value = "image"
			document.getElementById("imageprop").style.display = "block"
			document.getElementById("objprop").style.display = "none"
		}
		else if (reFlash.test(document.myform.imgurl.value)) {
			document.myform.objtype.value = "flash"
			document.getElementById("imageprop").style.display = "none"
			document.getElementById("objprop").style.display = "block"
		}
		else {
			document.myform.objtype.value = "other"
			document.getElementById("imageprop").style.display = "none"
			document.getElementById("objprop").style.display = "none"
		}
	}
</script>
<style type="text/css">
legend {font-size: 8pt; color: #4f4fdf;}
</style>
</head>
<body style="background-color: white;" leftmargin=10 topmargin=10 <?php
if (isset($msg) && $msg) echo "onload=\"alert('".addslashes($msg)."')\"";
?>>
<script language="javascript">
document.body.style.backgroundColor = top.opener.g_strHeCssThreedFace
document.body.style.color = top.opener.g_strHeCssWindowText
</script>
<div align=center>
<form name=myform action="browseimages2.php" method="post" enctype="multipart/form-data">
<script language="javascript">
document.writeln("    <fieldset style=\"margin-bottom: 4px;\"><legend>Specify an image by entering its URL:</legend>")
document.writeln("      <table width=\"100%\" align=center>")
document.writeln("        <tr> ")
document.writeln("          <td align=left>" + g_strHeTextImageURL + "</td>")
document.writeln("          <td><input type=text name=imgurl style=\"width: 360px;\"></td>")
document.writeln("        </tr></table></fieldset>");
</script>

<fieldset style="margin-bottom: 4px;"><legend>Or by selecting an image from photo gallery: </legend>
<div style="overflow: auto; height: <?php echo ($bAllowUpload) ? "185px" : "240px"; ?>; ">
<table cellpadding=4 cellspacing=0 border=0 width=96%>
<?php
$count = 0;
$colwidth = round(100 / $numcols) . "%";
if (is_dir($imagedir)) {
    if ($dh = opendir($imagedir)) {
        while (($file = readdir($dh)) !== false)
        {
            if (is_file($imagedir.$file))
            {
            	$strOnClick = "javascript: if (document.myform.imgurl.disabled) return false; document.myform.imgurl.value = '$imagediruri".addslashes(htmlspecialchars($file))."'; ShowHideProperties(); ";
            	if (file_exists($imagedir."thumbs/".$file.".txt")) {
            		$data = @file_get_contents($imagedir."thumbs/".$file.".txt");
            		list($width,$height,$size)=explode(",",$data);
            		if ($width) { $strOnClick .= "document.myform.width.value = '$width'; "; }
            		if ($height) { $strOnClick .= "document.myform.height.value = '$height'; "; }
            	}
                if (!($count % $numcols)) {
                    echo "<tr>";
                }
                echo "<td width=$colwidth align=center><table cellpadding=0 cellspacing=0 border=0>"
                    . "<tr height=$thumbsize><td colspan=2 width=$thumbsize align=center valign=middle>"
					. "<a href=\"#\" onclick=\"$strOnClick\">";
            	if (file_exists($imagedir."thumbs/".$file.".jpg")) {
					echo "<img src=\"$imagediruri"."thumbs/$file.jpg\" alt=\"\" border=0 />";
				}
				else {
					echo "<img src=\"file_document_lg.gif\" alt=\"\" border=0 />";
				}
				echo "</a></td></tr>"
                    . "<tr><td align=left style=\"font-size: 8pt;\"><a href=\"#\" onclick=\"$strOnClick\">$file</a>&nbsp;</td>"
                    . "<td align=right><a href=\"browseimages2.php?action=delete&amp;file=".urlencode($file)."\" onclick=\"return confirm('Are you sure to delete the file?')\">"
                    . "<img src=\"delete_sm.gif\" width=\"16\" height=\"16\" alt=\"Delete\" border=\"0\" style=\"cursor: hand;\" /></a></td>"
                    . "</tr></table><br /></td>\n";
                $count ++;
                if (!($count % $numcols)) {
                    echo "</tr>";
                }
            }
        }
        closedir($dh);
    }
    if ($count == 0) {
        echo "<tr><td>Images directory is empty.<td></tr>";
    }
    else {
        if ($count % $numcols)
        {
            while ($count % $numcols)
            {
                echo "<td width=$colwidth>&nbsp;</td>";
                $count ++;
            }
            echo "</tr>";
        }
    }
}
else
{
    echo "$imagedir is not a directory";
}
?>
</table></div></fieldset>

<?php if ($bAllowUpload) { ?>
<fieldset style="margin-bottom: 4px;"><legend>Upload file to photo gallery:</legend>
<table cellpadding=2 cellspacing=0 border=0 width=100%><tr>
<td align=left>File Name: <input type="file" name="binImage" /></td>
<td align=right><input type="submit" name="mysubmit" value="Upload"></td>
</tr></table></fieldset>
<?php } ?>

<script language="javascript">
document.writeln("<fieldset style=\"margin-bottom: 4px; display: none;\" id=\"imageprop\"><legend>Image Properties:</legend>")
document.writeln("<table width=100%><tr><input type=hidden name=width /><input type=hidden name=height /><input type=hidden name=objtype />")
document.writeln("          <td width=50% align=left>" + g_strHeTextImageAlignment + " ")
document.writeln("            <select name=align> ")
document.writeln("              <option value=\"\">-----</option> ")
document.writeln("              <option value=left>" + g_strHeTextLeft + "</option> ")
document.writeln("              <option value=right>" + g_strHeTextRight + "</option> ")
document.writeln("              <option value=top>" + g_strHeTextTop + "</option> ")
document.writeln("                <option value=middle>" + g_strHeTextMiddle + "</option> ")
document.writeln("                <option value=bottom>" + g_strHeTextBottom + "</option> ")
document.writeln("            </select></td>")
document.writeln("          <td width=50% align=left>" + g_strHeTextBorder + " ")
document.writeln("            <select name=border> ")
document.writeln("              <option value=0>0</option> ")
document.writeln("              <option value=1>1</option> ")
document.writeln("              <option value=2>2</option> ")
document.writeln("              <option value=3>3</option> ")
document.writeln("              <option value=4>4</option> ")
document.writeln("              <option value=5>5</option> ")
document.writeln("              <option value=6>6</option> ")
document.writeln("              <option value=7>7</option> ")
document.writeln("              <option value=8>8</option> ")
document.writeln("            </select></td></tr> ")
document.writeln("        <tr>")
document.writeln("          <td colspan=2 align=left>" + g_strHeTextImageDesc + " <input type=text name=alt style=\"width: 240px;\" /></td>")
document.write("</tr></table></fieldset>")
document.writeln("<fieldset style=\"margin-bottom: 4px; display: none;\" id=\"objprop\"><legend>Object Properties:</legend>")
document.writeln("<table width=100%><tr>")
document.writeln("          <td width=50% align=left>Width: <input type=text name=objWidth style=\"width: 60px;\" /></td>")
document.writeln("          <td width=50% align=left>Height: <input type=text name=objHeight style=\"width: 60px;\" /></td>")
document.writeln("</tr></table>")
document.writeln("</fieldset>")
document.write("<table width=\"100%\" align=center>")
document.writeln("        <tr>")
document.writeln("          <td align=right><input type=button value=\"" + g_strHeTextOk + "\" onclick=\"javascript: OnSubmit(document.forms[0])\"><input type=button value=\"" + g_strHeTextCancel + "\" onclick=\"javascript: MyDlgHandleCancel()\"></td></tr>")
document.writeln("    </table>")
</script>

</form>
<script language="javascript">
    if (MyDlgGetObj().args) {

        // width
        if (MyDlgGetObj().args.src) {
            str = new String(MyDlgGetObj().args.src)
            document.myform.imgurl.value = str
        }
        else {
            document.myform.imgurl.value = ""
        }

        if (MyDlgGetObj().args.align) {
            for (i = 0; i < document.myform.align.options.length; i ++) {
                var str = new String(document.myform.align.options[i].value)
                str = str.toLowerCase()
                if (MyDlgGetObj().args.align == str) {
                    document.myform.align.selectedIndex = i
                    break
                }
            }
        }

        // border
        if (MyDlgGetObj().args.border) {
            str = new String(MyDlgGetObj().args.border)
            document.myform.border.selectedIndex = str
        }
        else {
            document.myform.border.selectIndex = 0
        }

        // alt
        if (MyDlgGetObj().args.alt) {
            str = new String(MyDlgGetObj().args.alt)
            document.myform.alt.value = str
        }
        else {
            document.myform.alt.value = ""
        }

        if (MyDlgGetObj().args.width) {
            str = new String(MyDlgGetObj().args.width)
            document.myform.width.value = str
        }
        else {
            document.myform.width.value = ""
        }

        if (MyDlgGetObj().args.height) {
            str = new String(MyDlgGetObj().args.height)
            document.myform.height.value = str
        }
        else {
            document.myform.height.value = ""
        }
    }
	
	ShowHideProperties()
</script>
</div>
</body></html>
