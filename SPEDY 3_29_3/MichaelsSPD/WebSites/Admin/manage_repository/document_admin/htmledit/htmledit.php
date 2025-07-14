<?php
# File:         htmledit.php
# Description:  PHP helper class to use QWebEditor
# Programmer:   John Wong
# Version:
#   20030601JW
#       Initial version
#   20030929JW
#       * Enhanced HtmlEditGetBrowser() for browser detection
#       * Enhanced handling if client browser does not support QWebEditor. CQWebEditor class
#       generate correct codes for HeCModeStandaloneForm and HeCModeFormElement modes.
# Copyright (c) Q-Surf Computing Solutions, 2003-5. All rights reserved.

define('HeCModeMask', 3);
define('HeCModeFormElement', 0);
define('HeCModeStandaloneForm', 1);
define('HeCModeStandaloneDialog', 2);
define('HeCResizeToWindow', 4);
define('HeCDisableParagraph', 8);
define('HeCDisableFontSize', 16);
define('HeCDisableFontName', 32);
define('HeCDisableNewBtn', 64);
define('HeCDisableCutCopyPasteBtn', 128);
define('HeCDisableUndoRedoBtn', 256);
define('HeCDisableSourceBtn', 512);
define('HeCDisableForeColor', 1024);
define('HeCDisableBackColor', 2048);
define('HeCDisableAlignBtn', 4096);
define('HeCDisableTableBtn', 8192);
define('HeCDisableImageBtn', 16384);
define('HeCEnumSysFonts', 32768);
define('HeCBorder', 65536);
define('HeCDetectPlainText', 131072);
define('HeCDisableStyleBox', 262144);
define('HeCDisableStatusBar', 524288);
define('HeCToTextIfFail', 1048576);
define('HeCEditPage', 2097152);
define('HeCDisableFormattingBtns1',4194304);
define('HeCDisableFormattingBtns2',8388608);
define('HeCDisableFormattingBtns3',16777216);
define('HeCDisableLinkBtn',33554432);
define('HeCDisableHorizontalRuleBtn',67108864);
define('HeCDisableSymbolBtn',134217728);
define('HeCXHTMLSource',268435456);
define('HeCUseDivForIE',536870912);
define('HeCEnableSafeHtml',1073741824);
define('HeCDisableIncDecFontSizeBtns',2147483648);

define('HECEnableMergedImageDialog',1);

global $g_lNumControl;
global $g_arrBrowser;

$g_lNumControl = 0;
$g_arrBrowser = HtmlEditGetBrowser();

class CQWebEditor
{
var $m_strCtrlName = null;
var $m_strWidth = null;
var $m_strHeight = null;
var $m_strContent = null;
var $m_dwFlags = 0;
var $m_dwMask = 0;
var $m_strFormName = null;
var $m_strElementName = null;
var $m_strFormActionUrl = null;
var $m_strFormTarget = null;
var $m_strCssUrl = null;
var $m_strPageSrc = null;
var $m_lTabIndex = null;
var $m_lMarginWidth = null;
var $m_lMarginHeight = null;
var $m_strBaseHref = null;
var $m_strOnLoadHandler = null;
var $m_customBtns = null;
var $m_textAreaId = null;
var $m_strClassName = null;

// private member functions
function EnableFlag($value, $a_bEnable) 
{
    $this->m_dwFlags = ($this->m_dwFlags & ~$value) | ($a_bEnable ? $value : 0);
    $this->m_dwMask |= $value;
}

// public member functions
function SetCtrlName($a_strCtrlName) { $this->m_strCtrlName = $a_strCtrlName; }
function SetWidth($a_strWidth) { $this->m_strWidth = $a_strWidth; }
function SetHeight($a_strHeight) { $this->m_strHeight = $a_strHeight; }
function SetContent($a_strContent) { $this->m_strContent = $a_strContent; }
function SetContentFromUrl($a_strUrl) {$this->m_strPageSrc = $a_strUrl; }
function SetFlags($a_dwFlags) {$this->m_dwFlags = $a_dwFlags; }
function SetTabIndex($a_lTabIndex) {$this->m_lTabIndex = $a_lTabIndex;}

function EnableParagraphBox($a_bEnable) { $this->EnableFlag(HeCDisableParagraph, !$a_bEnable); }
function EnableFontSizeBox($a_bEnable) { $this->EnableFlag(HeCDisableFontSize, !$a_bEnable); }
function EnableFontNameBox($a_bEnable) { $this->EnableFlag(HeCDisableFontName, !$a_bEnable); }
function EnableHelpBtn($a_bEnable) { $this->EnableFlag(HeCDisableHelpBtn, !$a_bEnable); }
function EnableCutCopyPasteBtn($a_bEnable) { $this->EnableFlag(HeCDisableCutCopyPasteBtn, !$a_bEnable); }
function EnableUndoRedoBtn($a_bEnable) { $this->EnableFlag(HeCDisableUndoRedoBtn, !$a_bEnable); }
function EnableSourceBtn($a_bEnable) { $this->EnableFlag(HeCDisableSourceBtn, !$a_bEnable); }
function EnableForeColorBtn($a_bEnable) { $this->EnableFlag(HeCDisableForeColor, !$a_bEnable); }
function EnableBackColorBtn($a_bEnable) { $this->EnableFlag(HeCDisableBackColor, !$a_bEnable); }
function EnableAlignBtn($a_bEnable) { $this->EnableFlag(HeCDisableAlignBtn, !$a_bEnable); }
function EnableBorder($a_bEnable) { $this->EnableFlag(HeCBorder, $a_bEnable); }
function EnableEnumSysFonts($a_bEnable) { $this->EnableFlag(HeCEnumSysFonts, $a_bEnable); }
function EnableDetectPlainText($a_bEnable) { $this->EnableFlag(HeCDetectPlainText, $a_bEnable); }
function EnableToTextIfFail($a_bEnable) { $this->EnableFlag(HeCToTextIfFail, $a_bEnable); }
function EnableStatusBar($a_bEnable) { $this->EnableFlag(HeCDisableStatusBar, !$a_bEnable); }
function EnableStyleBox($a_bEnable) { $this->EnableFlag(HeCDisableStyleBox, !$a_bEnable); }
function EnableEditPage($a_bEnable) { $this->EnableFlag(HeCEditPage, $a_bEnable); }
function EnableTableBtn($a_bEnable) { $this->EnableFlag(HeCDisableTableBtn, !$a_bEnable); }
function EnableNewBtn($a_bEnable) { $this->EnableFlag(HeCDisableNewBtn, !$a_bEnable); }
function EnableFormattingBtns1($a_bEnable) { $this->EnableFlag(HeCDisableFormattingBtns1, !$a_bEnable); }
function EnableFormattingBtns2($a_bEnable) { $this->EnableFlag(HeCDisableFormattingBtns2, !$a_bEnable); }
function EnableFormattingBtns3($a_bEnable) { $this->EnableFlag(HeCDisableFormattingBtns3, !$a_bEnable); }
function EnableImageBtn($a_bEnable) { $this->EnableFlag(HeCDisableImageBtn, !$a_bEnable); }
function EnableIncDecFontSizeBtns($a_bEnable) { $this->EnableFlag(HeCDisableIncDecFontSizeBtns, !$a_bEnable); }
function EnableLinkBtn($a_bEnable) { $this->EnableFlag(HeCDisableLinkBtn, !$a_bEnable); }
function EnableHorizontalRuleBtn($a_bEnable) { $this->EnableFlag(HeCDisableHorizontalRuleBtn, !$a_bEnable); }
function EnableSymbolBtn($a_bEnable) { $this->EnableFlag(HeCDisableSymbolBtn, !$a_bEnable); }
function EnableXHtmlSource($a_bEnable) { $this->EnableFlag(HeCXHTMLSource, $a_bEnable); }
function EnableUseDivForIE($a_bEnable) { $this->EnableFlag(HeCUseDivForIE, $a_bEnable); }
function EnableSafeHtml($a_bEnable) { $this->EnableFlag(HeCEnableSafeHtml, $a_bEnable); }

function SetEditorCssFile($a_strUrl) { $this->m_strCssUrl = $a_strUrl; }
function SetMarginWidth($a_lMarginWidth) {$this->m_lMarginWidth = $a_lMarginWidth; }
function SetMarginHeight($a_lMarginHeight) {$this->m_lMarginHeight = $a_lMarginHeight; }
function SetBaseHref($a_strBaseHref) {$this->m_strBaseHref = $a_strBaseHref;}
function SetClassName($a_strClassName) {$this->m_strClassName = $a_strClassName; }

function ResizeToWindow($a_bEnable) { $this->EnableFlag(HeCResizeToWindow, $a_bEnable); }
function SetMode($a_mode) { $this->m_dwFlags = ($this->m_dwFlags & ~3) | $a_mode; }

function SetFormName($a_value) { $this->m_strFormName = $a_value; }
function SetElementName($a_value) { $this->m_strElementName = $a_value; }
function SetFormActionUrl($a_value) { $this->m_strFormActionUrl = $a_value; }
function SetFormTarget($a_value) { $this->m_strFormTarget = $a_value; }

function SetOnLoadHandler($a_value) { $this->m_strOnLoadHandler = $a_value; }

function AddCustomButton($title, $funcname, $imgname) {
	$this->m_customBtns[] = array(
		'title'=>$title,
		'funcname'=>$funcname,
		'imgname'=>$imgname);
}

function QuotePhpStr($a_str) {
    return '"' . addcslashes($a_str,"\0..\37\\\"\$") . '"';
}

function unhtmlentities($string) {
    if (function_exists("html_entity_decode")) {
        return html_entity_decode($string);
    }
    else {
       $trans_tbl = get_html_translation_table (HTML_ENTITIES);
       $trans_tbl = array_flip ($trans_tbl);
       return strtr ($string, $trans_tbl);
    }
}

function HtmlToPlainText($a_str) {
    $str = $a_str;
    $str = str_replace(">\r\n", ">", $str);
    $str = str_replace(">\n", ">", $str);
    $str = str_replace(">\r", ">", $str);
    $str = str_replace("\r\n", " ", $str);
    $str = str_replace("\n", " ", $str);
    $str = str_replace("\r", " ", $str);
    $str = eregi_replace('</p[^>]*>|</h1[^>]*>|</h2[^>]*>|</h3[^>]*>|</h4[^>]*>|</h5[^>]*>|</h6[^>]*>|</blockquote[^>]*>|</ul[^>]*>|</ol[^>]*>', "\n\n", $str);
    $str = eregi_replace('<br[^>]*>|</tr[^>]*>', "\n", $str);
    $str = eregi_replace('<li[^>]*>', "\n  * ", $str);
    $str = eregi_replace('</td[^>]*>', "  ", $str);
    $str = eregi_replace('<hr[^>]*>', "\n-------------------------------\n", $str);
    $str = eregi_replace('<[^>]*>', '', $str);
    $str = $this->unhtmlentities($str);
    return $str;
}

function GetControlString() {
    global $g_arrBrowser;
    global $g_lNumControl;
    
    $g_lNumControl ++;

    if ($g_arrBrowser['has_htmledit']){
        $id = "tmpcontent_he_".$g_lNumControl;
        $str =
        "<div style=\"width:1px; height: 1px; position: absolute; visibility: hidden;\">"
        . (($this->m_dwFlags & HeCModeMask != HeCModeFormElement) ? "<form>" : "")
        . "<textarea id=\"$id\" name=\"$id\">"
        . htmlspecialchars($this->m_strContent) . "</textarea>"
        . (($this->m_dwFlags & HeCModeMask != HeCModeFormElement) ? "</form>" : "")
        . "</div>"
        . "<script language=\"javascript\"><!--\n"
        . "var obj = new Object()\n";
		$str .= "obj.strAPI = 'php'\n";
        if ($this->m_strCtrlName) $str .= "obj.strId = " . $this->QuotePhpStr($this->m_strCtrlName) . "\n";
        if ($this->m_strWidth) $str .= "obj.strWidth = " . $this->QuotePhpStr($this->m_strWidth) . "\n";
        if ($this->m_strHeight) $str .= "obj.strHeight = " . $this->QuotePhpStr($this->m_strHeight) . "\n";
        if ($this->m_strPageSrc) $str .= "obj.strPageSrc = " . $this->QuotePhpStr($this->m_strPageSrc) . "\n";
        else $str .= "obj.strTextareaId = 'tmpcontent_he_".$g_lNumControl."'\n";
        if (!is_null($this->m_dwFlags)) {
            $str .= "obj.lFlags = " . $this->m_dwFlags . "\n";
            $str .= "obj.lMask = " . $this->m_dwMask . "\n";
        }
        if ($this->m_strFormName) $str .= "obj.strFormName = " . $this->QuotePhpStr($this->m_strFormName) . "\n";
        if ($this->m_strElementName) $str .= "obj.strElementName = " . $this->QuotePhpStr($this->m_strElementName) . "\n";
        if ($this->m_strFormTarget) $str .= "obj.strTarget = " . $this->QuotePhpStr($this->m_strFormTarget) . "\n";
        if ($this->m_strFormActionUrl) $str .= "obj.strAction = " . $this->QuotePhpStr($this->m_strFormActionUrl) . "\n";
        if ($this->m_strCssUrl) {
			if (is_array($this->m_strCssUrl)) {
				$str .= "obj.strCssStyle = new Array()\n";
				$i = 0;
				foreach ($this->m_strCssUrl as $css) {
					$str .= "obj.strCssStyle[$i] = " . $this->QuotePhpStr($css) . "\n";
					$i ++;
				}
			}
			else {
				$str .= "obj.strCssStyle = " . $this->QuotePhpStr($this->m_strCssUrl) . "\n";
			}
		}
        if ($this->m_lTabIndex) $str .= "obj.lTabIndex = " . $this->QuotePhpStr($this->m_lTabIndex) . "\n";
        if ($this->m_lMarginWidth) $str .= "obj.lMarginWidth = " . $this->QuotePhpStr($this->m_lMarginWidth) . "\n";
        if ($this->m_lMarginHeight) $str .= "obj.lMarginHeight = " . $this->QuotePhpStr($this->m_lMarginHeight) . "\n";
        if ($this->m_strBaseHref) $str .= "obj.strBaseHref = " . $this->QuotePhpStr($this->m_strBaseHref) . "\n";
        if ($this->m_strClassName) $str .= "obj.className = " . $this->QuotePhpStr($this->m_strClassName) . "\n";
        if ($this->m_strOnLoadHandler) $str .= "obj.onLoad = " . $this->m_strOnLoadHandler . "\n";
		if (is_array($this->m_customBtns) && count($this->m_customBtns) > 0) {
			$str .= "obj.customBtns = new Array()\n";
			$i = 0;
			foreach ($this->m_customBtns as $btn) {
				$str .= "obj.customBtns[$i] = new Object()\n";
				$str .= "obj.customBtns[$i].title = " . $this->QuotePhpStr($btn['title']) . "\n";
				$str .= "obj.customBtns[$i].funcname = " . $this->QuotePhpStr($btn['funcname']) . "\n";
				$str .= "obj.customBtns[$i].imgname = " . $this->QuotePhpStr($btn['imgname']) . "\n";
				$i++;
			}
		}
        $str .= "HtmlEditCreateControlFromObj(obj)\n";
        $str .= "//--></script>";
        return $str;
    }
    else{
        $nav4 = ($g_arrBrowser['browser'] == "Netscape" && $g_arrBrowser['version'] < 6);
        $value = ($this->m_dwFlags & HeCToTextIfFail) ? $this->HtmlToPlainText($this->m_strContent) : $this->m_strContent;
        if (($this->m_dwFlags & HeCModeMask) == HeCModeStandaloneForm)
        {
            $str = '';
            if ($nav4)
            {
                $str .= "<form name=\"" . $this->m_strFormName . "\" action=\"" . $this->m_strFormActionUrl . "\" method=\"post\" target=\"" . $this->m_strFormTarget . "\">";
                $str .= "<input type=submit name=mysubmit value=\"Save\" /><br />";
                $str .= "<textarea name=\"".$this->m_strElementName."\" cols=40 rows=10 "
                    . "style=\"position: relative; width: ".$this->m_strWidth."; height: ".$this->m_strHeight.";\" >"
                    .HtmlSpecialChars($value)."</textarea><br />";
                $str .= "</form>";
                echo $str;
            }
            else
            {
                if ($this->m_dwFlags & HeCBorder)
                    $str .= "<div style=\"padding: 1px 1px 1px 1px; background-color: black; width: " . $this->m_strWidth . ";\">"
                        ."<div id=\"hetoolbar_" . $this->m_strCtrlName . "\" unselectable=on class=\"htmledittoolbar\" oncontextmenu=\"return false\">";
                else
                    $str .= "<div id=\"hetoolbar_" . $this->m_strCtrlName . "\" unselectable=on class=\"htmledittoolbar\" style=\"width: " . $this->m_strWidth . ";\" oncontextmenu=\"return false\">";

                $str .= "<table cellpadding=0 cellspacing=0 border=0 width=100%>";
                $str .= "<form name=\"" . $this->m_strFormName . "\" action=\"" . $this->m_strFormActionUrl . "\" method=\"post\" target=\"" . $this->m_strFormTarget . "\">";
                $str .= "<tr><td><input type=submit name=mysubmit value=\"Save\" /><br />";
                $str .= "<textarea name=\"".$this->m_strElementName."\" id=\"" . $this->m_strCtrlName . "\" cols=40 rows=10 "
                    . "style=\"position: relative; width: 100%; height: ".$this->m_strHeight.";\" >"
                    .HtmlSpecialChars($value)."</textarea></td></tr>";
                $str .= "</form></table>";

                $str .= "</div>";
                if ($this->m_dwFlags & HeCBorder)
                    $str .= "</div>";
                return $str;
            }
        }
        else
        {
            return "<textarea name=\"".$this->m_strElementName."\" id=\"" . $this->m_strCtrlName . "\" cols=40 rows=10 "
                . (!$nav4 ? "style=\"position: relative; width: ".$this->m_strWidth."; height: ".$this->m_strHeight.";\" >" : '>')
                . HtmlSpecialChars($value)."</textarea><br />";
        }
    }
}

function CreateControl()
{
    echo $this->GetControlString();
}

}

function HtmlEditInit($strHtmlEditPath='/htmledit/', $strImageUrl='', $strLangFileUrl='', $strThemeFile = '', $dwFlags = 0)
{
    global $g_arrBrowser;
    $strMyPath = $strHtmlEditPath;
    $strMyLang = $strLangFileUrl? $strLangFileUrl: 'lang_eng.js';
    
    if ($g_arrBrowser['has_htmledit'])
    {
?><!-- Initialize the QWebEditor 3.0 library -->
<script language="javascript"><!--
// some important global variables
var g_strHtmlEditPath = "<?php echo $strMyPath; ?>"
//--></script>
<script language=javascript src="<?php echo $strMyPath; ?>browserSniffer.js"></script>
<script language=javascript src="<?php echo $strMyPath; ?>utils.js"></script>
<script language=javascript src="<?php echo $strMyPath; ?>mydlg.js"></script>
<script language=javascript src="<?php echo $strMyPath.$strMyLang; ?>"></script>
<?php 
if ($strThemeFile) echo "<script language=javascript src=\"$strMyPath"."$strThemeFile\"></script>\n";
?><script language=javascript src="<?php echo $strMyPath; ?>license.js"></script>
<script language=javascript src="<?php echo $strMyPath; ?>htmledit_cfg.js"></script>
<script language="javascript"><!--
// some important global variables
var g_strHtmlEditImgUrl = "<?php echo $strImageUrl; ?>"
var g_strHtmlEditLangFile = "<?php echo $strMyLang; ?>"
var g_bMergedImageDialog = <?php echo ($dwFlags & HECEnableMergedImageDialog) ? 'true' : 'false'; ?>
//--></script>
<script language=javascript src="<?php echo $strMyPath; ?>htmledit.js"></script>
<script language=javascript src="<?php echo $strMyPath; ?>htmledit_styles.js"></script>
<!-- End of initialization --><?php
    }
    else
    {
?>
<!-- Initialize the QWebEditor 3.0 library -->
<script language="javascript"><!--
// some important global variables
var g_strHtmlEditPath = "<?php echo $strMyPath; ?>"
//--></script>
<script language=javascript src="<?php echo $strMyPath; ?>browserSniffer.js"></script>
<script language=javascript src="<?php echo $strMyPath; ?>utils.js"></script>
<script language=javascript src="<?php echo $strMyPath; ?>mydlg.js"></script>
<script language=javascript src="<?php echo $strMyPath.$strMyLang; ?>"></script>
<script language=javascript src="<?php echo $strMyPath; ?>htmledit_cfg.js"></script>
<script language=javascript src="<?php echo $strMyPath; ?>htmledit_ta.js"></script>
<?php
    }
}

function HtmlEditInit2($strHtmlEditPath='/htmledit/', $strOverride='')
{
?>
<!-- QWebEditor 3.12 Initialization Start 
--><script language="javascript"><!--
// variables to match your qwebeditor installation
var g_strHtmlEditPath="<?php echo addslashes($strHtmlEditPath); ?>"			// uri to qwebeditor directory
function ijs(file){document.write("<scr"+"ipt language=\"javascript\" src=\""
	+g_strHtmlEditPath+file+"\"></scr"+"ipt>")}
// load utility libraries and configuration file
ijs("browserSniffer.js");ijs("utils.js");ijs("mydlg.js");ijs("htmledit_cfg.js")
//--></script><script language="javascript"><!--
// load necessary file if browser supports the editor
<?php echo $strOverride; ?>
ijs(g_strHtmlEditLangFile)
if(has_htmledit){ijs(g_strHtmlEditThemeUrl);ijs("license.js");ijs("htmledit.js");ijs("htmledit_styles.js")}
// browser does not support the editor. load compatibility file
else {ijs("htmledit_ta.js")}
//--></script><!-- 
QWebEditor 3.12 Initialization End -->
<?php
}

function HtmlEditCreateControlString($strCtrlName, $width = "100%", $height = "250px", 
    $strText = "", $lFlags = 64,
    $strForm = "", $strElement = "", $strAction= "", $strTarget = "")
{
    $browser = new CQWebEditor();
    $browser->SetCtrlName($strCtrlName);
    $browser->SetWidth($width);
    $browser->SetHeight($height);
    $browser->SetContent($strText);
    $browser->SetFlags($lFlags);
    $browser->SetFormName($strForm);
    $browser->SetElementName($strElement);
    $browser->SetFormActionUrl($strAction);
    $browser->SetFormTarget($strTarget);
    return $browser->GetControlString();
}

function HtmlEditCreateControl($strCtrlName, $width = "100%", $height = "250px", 
    $strText = "", $lFlags = 64,
    $strForm = "", $strElement = "", $strAction= "", $strTarget = "")
{
    echo HtmlEditCreateControlString($strCtrlName, $width, $height,
        $strText, $lFlags,
        $strForm, $strElement, $strAction, $strTarget);
}

function HtmlEditGetBrowser()
{
    global $HTTP_SERVER_VARS;
    $arr['useragent'] = strtolower($HTTP_SERVER_VARS['HTTP_USER_AGENT']);
    if (strstr($arr['useragent'], "gecko"))
    {
        $arr['gecko'] = 1;
        $pos = strpos($arr['useragent'], "gecko");
        $arr['gecko_version'] = substr($arr['useragent'], $pos + 6, 8);
    }

    if (ereg('lynx', $arr['useragent']))
    {
        // got from mandrake 8
        // lynx/2.8.5dev.8 libwww-fm/2.14 ssl-mm/1.4.1 openssl/0.9.6c
        $arr['browser'] = 'Lynx';
    }
    else if (ereg('links', $arr['useragent']))
    {
        // got from mandrake 8
        // links (0.97pre3; unix)
        $arr['browser'] = 'Links';
    }
    else if (ereg("opera", $arr['useragent']))
    {
        // Opera 7.2
        // opera/7.20 (windows nt 5.0; u) [en]
        $arr['browser'] = "Opera";
        $start = strpos($arr['useragent'], "Opera") + strlen("Opera") + 1;
        $end = strpos($arr['useragent'], '(', $start);
        $version = substr($arr['useragent'], $start, $end - $start);
        list($arr['major'], $arr['minor']) = explode('.', $version);
        $arr['minor'] = substr($arr['minor'], 0, 1);
        $arr['version'] = $arr['major'] . "." . $arr['minor'];
        $arr['gecko'] = false;
        $arr['gecko_version'] = null;
    }
    else if (ereg("konqueror", $arr['useragent']))
    {
        // mozilla/5.0 (compatible; konqueror/2.2.2; linux)
        $arr['browser'] = "Konqueror";
    }
    else if (eregi("Safari", $arr['useragent']))
    {
        $arr['browser'] = "Safari";
        $start = strpos($arr['useragent'], 'safari/') + 7;
        $arr['version'] = substr($arr['useragent'], $start);
        $arr['gecko'] = false;
        $arr['gecko_version'] = null;
    }
    else if (ereg("bot", $arr['useragent']) || ereg("google", $arr['useragent']) ||
    ereg("slurp", $arr['useragent']) || ereg("scooter", $arr['useragent']) ||
    ereg("spider", $arr['useragent']) || ereg("infoseek", $arr['useragent']))
    {
        $arr['browser'] = "bot";
    }
    else if (ereg('msie', $arr['useragent']))
    {
        // mozilla/4.0 (compatible; msie 6.0; windows nt 5.0; q312461; .net clr 1.0.3705)
        $arr['browser'] = 'MSIE';
        $start = strpos($arr['useragent'], 'msie');
        $end = strpos($arr['useragent'], ";", $start);
        $version = substr($arr['useragent'], $start + 5, $end - $start -5);
        list($arr['major'], $arr['minor']) = explode('.', $version);
        $arr['version'] = $arr['major'] . "." . $arr['minor'];
    }
    else if (strstr($arr['useragent'], "netscape/"))
    {
        // mozilla/5.0 (windows; u; windows nt 5.0; en-us; rv:1.4) gecko/20030624 netscape/7.1 (ax)
        $arr['browser'] = 'Netscape';
        $start = strpos($arr['useragent'], 'netscape/');
        $end = strpos($arr['useragent'], " ", $start);
        if ($end < $start) {
            $version = substr($arr['useragent'], $start + 9);
        }
        else {
            $version = substr($arr['useragent'], $start + 9, $end - $start - 9);
        }
        list($arr['major'], $arr['minor']) = explode('.', $version);
        $arr['version'] = $arr['major'] . "." . $arr['minor'];
    }
    else if (strstr($arr['useragent'], "firebird"))
    {
        $arr['browser'] = "Firebird";
        $arr['version'] = $arr['gecko_version'];
    }
    else if (strstr($arr['useragent'], "mozilla/"))
    {
        // mozilla/4.78 [en] (windows nt 5.0; u)
        // Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.5b) Gecko/20030827
        $start = strpos($arr['useragent'], "Mozilla/") + strlen("Mozilla/");
        $end = strpos($arr['useragent'], ' ');
        $version = substr($arr['useragent'], $start, $end - $start);
        list($arr['major'], $arr['minor']) = explode('.', $version);
        if ($arr['major'] <= 4)
        {
            $arr['browser'] = "Netscape";
            $arr['minor'] = substr($arr['minor'], 0, 1);
            $arr['version'] = $arr['major'] . "." . $arr['minor'];
        }
        else
        {
            $arr['browser'] = "Mozilla";
            $arr['version'] = $arr['gecko_version'];
        }
    }
    else
    {
        $arr['browser'] = "Other";
    }

    if (ereg("win", $arr['useragent']))
    {
        if (ereg("windows 9", $arr['useragent']) || ereg("win9", $arr['useragent']))
        {
            $arr['platform'] = "Windows9X";
        }
        else if (ereg("windows nt", $arr['useragent']) || ereg("windows 2000", $arr['useragent']) || ereg("windows xp", $arr['useragent']))
        {
            $arr['platform'] = "WindowsNT";
        }
        else
        {
            $arr['platform'] = "Windows";
        }
    }
    else if (ereg("linux", $arr['useragent']))
    {
        $arr['platform'] = "Linux";
    }
    else if (ereg("mac", $arr['useragent']))
    {
        $arr['platform'] = "Mac";
    }
    else if (ereg("freebsd", $arr['useragent']))
    {
        $arr['platform'] = "FreeBSD";
    }
    else if (ereg("sunos", $arr['useragent']))
    {
        $arr['platform'] = "SunOS";
    }
    else if (ereg("irix", $arr['useragent']))
    {
        $arr['platform'] = "IRIX";
    }
    else if (ereg("beos", $arr['useragent']))
    {
        $arr['platform'] = "BeOS";
    }
    else if (ereg("os/2", $arr['useragent']))
    {
        $arr['platform'] = "OS/2";
    }
    else if (ereg("aix", $arr['useragent']))
    {
        $arr['platform'] = "AIX";
    }
    else
    {
        $arr['platform'] = "Other";
    }

    $arr['has_htmledit'] =
        ($arr['browser'] == "MSIE" && $arr['version'] >= 5.5 && ereg("Windows", $arr['platform'])) ||
        ($arr['browser'] == "Firebird" && $arr['version'] >= "20030924") ||
        (isset($arr['gecko']) && $arr['gecko'] && $arr['gecko_version'] >= "20030624") ||
        ($arr['browser'] == "Safari" && $arr['version'] >= 412.5);
    return $arr;
}
?>