<%
function FormatFileSize(p_FileSize)
	Dim m_FileSizeOut
	Dim SIZE_KB, SIZE_MB, SIZE_GB

	SIZE_KB = 1024
	SIZE_MB = 1024 * SIZE_KB
	SIZE_GB = 1024 * SIZE_MB
  
	if not IsNumeric(p_FileSize) then 
		FormatFileSize = p_FileSize
		exit function
	end if

	if Len(p_FileSize) >= 10 and p_FileSize >= SIZE_GB then
		m_FileSizeOut = FormatNumber(p_FileSize/SIZE_GB) & " GB"
	elseif Len(p_FileSize) >= 7 and Len(p_FileSize) < 10 and p_FileSize >= SIZE_MB then
		m_FileSizeOut = FormatNumber(p_FileSize/SIZE_MB) & " MB"
	elseif Len(p_FileSize) >= 4 and Len(p_FileSize) < 7 and p_FileSize >= SIZE_KB then
		m_FileSizeOut = FormatNumber(p_FileSize/SIZE_KB) & " KB"
	else
		m_FileSizeOut = FormatNumber(p_FileSize) & " bytes"
	end if

	FormatFileSize = m_FileSizeOut
end function
%>