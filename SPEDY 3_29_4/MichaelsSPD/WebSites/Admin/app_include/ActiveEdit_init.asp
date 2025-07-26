<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Dim ae
Set ae=Server.CreateObject("CFDEV.Activedit")

ae.Inc="./../../app_include/ActiveEdit/inc/"
ae.Width = "500"
ae.Height = "300"
ae.ImageURL = Application.Value("WebsiteRootURL") & "images/uploads/"
ae.ImagePath = Application.Value("Activedit_Upload_Image_Path")
ae.AllowImage = true
ae.Toolbar="quickfont,|,cut,copy,paste,|,redo,undo,|,font,bold,italic,underline,|,outdent,indent,|,justifyleft,justifycenter,justifyright,bullets,numbers,|,table,image,hyperlink,|,find,specialchars,spellcheck,|,help,showdetails" 
ae.DefaultFont = "11px Arial"
ae.ButtonColor = "#cccccc"
ae.Border = 0
ae.RemoveCopyright = "1"
%>
