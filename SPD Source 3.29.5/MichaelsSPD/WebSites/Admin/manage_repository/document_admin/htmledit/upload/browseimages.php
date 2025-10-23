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
$imagediruri = $_SERVER["HTTPS"] ? "https://" : "http://";   # probably exported by Apache only ...
$imagediruri .= $_SERVER["HTTP_HOST"];
$pos = strpos($_SERVER['REQUEST_URI'], "?");
if ($pos) {
    $uri = substr($_SERVER['REQUEST_URI'], 0, $pos);
}
else {
    $uri = $_SERVER['REQUEST_URI'];
}
$imagediruri .= substr($uri, 0, strlen($uri) - strlen('browseimages.php'));
$imagediruri .= "pages/images/";

# Allows user to upload images?
$bAllowUpload = true;


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

$arrGdCap = gd_info();

$bSupportGD2 = substr($arrGdCap['GD Version'], strpos($arrGdCap['GD Version'], "(") + 1, 1) > 1;
$bSupportReadingJpeg = $arrGdCap['GIF Read Support'];
$bSupportReadingGif = $arrGdCap['JPG Support'];
$bSupportReadingPng = $arrGdCap['PNG Support'];

# copy command is used to copy the uploaded image file to images directory
# to avoid openbasedir problem. some servers are very restrictive and
# the upload directory is completely inaccessible from PHP functions.
# Using the system copy command to copy the image to accessible directory
# to get around the problem. If not using system copy command, use PHP
# copy function.
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

# end of configuration

# saving the uploaded image
if ($HTTP_POST_VARS['mysubmit'])
{
    if ($HTTP_POST_FILES['binImage']['tmp_name'] &&
        $HTTP_POST_FILES['binImage']['tmp_name'] != "none")
    {
        $dstfile = $imagedir . $HTTP_POST_FILES['binImage']['name'];

        if (file_exists($dstfile))
        {
            $msg = "File exists. Please delete existing one before uploading a new one.";
        }
        else
        {
            # attempt to copy the uploaded image to images directory
            if ($bSysCopy)
            {
                $cmd = $strCopyCmd . " " . $HTTP_POST_FILES['binImage']['tmp_name'] . " " . $dstfile;
                if ($bWin) $cmd = str_replace('/', "\\", $cmd);
                exec($cmd);
            }
            else
            {
                copy($HTTP_POST_FILES['binImage']['tmp_name'], $dstfile);
            }
            @chmod($dstfile, 0666);

            # if successful, attempt to open the image
            if (file_exists($dstfile))
            {
                $type = $HTTP_POST_FILES['binImage']['type'];
                if ($bSupportReadingJpeg && (eregi("jpeg", $type) || eregi("jpg", $type)))
                {
                    $hSrc = ImageCreateFromJpeg($dstfile);
                }
                else if ($bSupportReadingPng && eregi("png", $type))
                {
                    $hSrc = ImageCreateFromPng($dstfile);
                }
                else if($bSupportReadingGif && eregi("gif", $type))
                {
                    $hSrc = ImageCreateFromGif($dstfile);
                }

                # able to load the image, create thumbnail
                if ($hSrc)
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
                else
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
else if ($HTTP_GET_VARS['action'] == 'delete' 
    && $HTTP_GET_VARS['file']
    && file_exists($imagedir.$HTTP_GET_VARS['file']))
{
    @unlink($imagedir.$HTTP_GET_VARS['file']);
    @unlink($imagedir.'thumbs/'.$HTTP_GET_VARS['file'].".jpg");
    $msg = "The file has been successfully deleted.";
}

?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Strict//EN">
<html>
<head>
<script language="javascript">
var charset = (top.opener.document.characterSet) ? top.opener.document.characterSet : top.opener.document.charset
document.write("<meta HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; CHARSET=" + charset + "\" />")
</script>
<title></title>
<LINK REL=STYLESHEET TYPE="text/css" HREF="../style.css">
<script language="javascript" src="../utils.js"></script>
<script language="javascript" src="../mydlg.js"></script>
<script language="javascript">
    top.document.title = "Browse ..."
</script>
</head>
<body style="background-color: threedface;" leftmargin=10 topmargin=10 <?php
if ($msg) echo "onload=\"alert('$msg')\"";
?>>
<div align=center>
<?php
if ($bAllowUpload) { ?>
<table cellpadding=1 cellspacing=0 border=0 width=97% bgcolor=black>
<form action="browseimages.php" method="post" enctype="multipart/form-data">
<tr><td><table cellpadding=2 cellspacing=0 border=0 width=100% bgcolor=white><tr><td align=left>
File Name: <input type="file" name="binImage" /><br />
<input type="submit" name="mysubmit" value="Upload Now!">
</td></tr></table></td></tr></form></table><br />
<?php } ?>

<div style="width: 97%; text-align: left;">Please click on an image file to select:</div>
<div style="overflow: auto; width: 97%; height: <?php echo ($bAllowUpload) ? "245px" : "300px"; ?>; border: black 1px solid; background-color: white;">
<table cellpadding=2 cellspacing=0 border=0 width=94% bgcolor=white>
<?php
$count = 0;
$colwidth = round(100 / $numcols) . "%";
if (is_dir($imagedir)) {
    if ($dh = opendir($imagedir)) {
        while (($file = readdir($dh)) !== false)
        {
            if (is_file($imagedir.$file))
            {
                if (!($count % $numcols))
                {
                    echo "<tr>";
                }
            	if (file_exists($imagedir."thumbs/".$file.".txt")) {
            		$data = @file_get_contents($imagedir."thumbs/".$file.".txt");
            		list($width,$height,$size)=explode(",",$data);
            	}
                echo "<td width=$colwidth align=center><a href=\"#\" onclick=\"javascript: MyDlgHandleOK(new Array('$imagediruri"."$file','$width','$height'))\">"
                    . "<img src=\"$imagediruri"."thumbs/$file.jpg\" alt=\"\" border=0 /></a>"
                    . "<table cellpadding=0 cellspacing=0 border=0><tr><td><a href=\"#\" onclick=\"javascript: MyDlgHandleOK(new Array('$imagediruri".addslashes(htmlspecialchars($file))."','$width','$height'))\">$file</a></td> "
                    . "<td><a href=\"browseimages.php?action=delete&amp;file=".urlencode($file)."\" onclick=\"return confirm('Are you sure to delete the file?')\">"
                    . "<img src=\"delete_sm.gif\" width=\"16\" height=\"16\" alt=\"Delete\" border=\"0\" style=\"cursor: hand;\" /></a></td></tr></table><br /></td>\n";
                $count ++;
                if (!($count % $numcols))
                {
                    echo "</tr>";
                }
            }
        }
        closedir($dh);
    }
    if ($count == 0)
    {
        echo "<tr><td>Images directory is empty.<td></tr>";
    }
    else
    {
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
</table></div>
</div>
</body></html>
