<%
' File:         browsersniffer.asp
' Programmer:   John Wong
' Description:  ASP helper class to determine client browser details
' Product:      QWebEditor 3.0
' History:
'   20030928JW
'       Initial Version
' Copyright (c) Q-Surf Computing Solutions, 2003-5. All rights reserved.
' http://www.q-surf.com

class BrowserSniffer
    dim m_strUserAgent
    dim m_strPlatform
    dim m_strBrowser
    dim m_strMajor
    dim m_strMinor
    dim m_strVersion
    dim m_bGecko
    dim m_strGeckoVersion
    dim m_bHtmlEdit

    private sub Class_Initialize()
        dim pos, mystart, myend, arr

        m_strUserAgent = LCase(Request.ServerVariables("HTTP_USER_AGENT"))
        m_strPlatform = ""
        m_strBrowser = ""
        m_strMajor = ""
        m_strMinor = ""
        m_strVersion = ""
        m_bGecko = false
        m_strGeckoVersion = 0
        m_bHtmlEdit = false

        ' gecko?
        if InStr(m_strUserAgent, "gecko") then
            m_bGecko = true
            pos = InStr(m_strUserAgent, "gecko")
            m_strGeckoVersion = mid(m_strUserAgent, pos + 6, 8)
        else
            m_bGecko = false
        end if

        ' detect browser
        if InStr(m_strUserAgent, "lynx") then
            m_strBrowser = "Lynx"
        elseif InStr(m_strUserAgent, "links") then
            m_strBrowser = "Links"
        elseif InStr(m_strUserAgent, "konqueror") then
            m_strBrowser = "Konqueror"
        elseif InStr(m_strUserAgent, "opera") then
            m_strBrowser = "Opera"
            mystart = InStr(m_strUserAgent, "Opera") + 7
            myend = InStr(mystart, m_strUserAgent, " ")
            m_strVersion = mid(m_strUserAgent, mystart, myend - mystart)
            arr = Split(m_strVersion, ".")
            if UBound(arr) >= 1 then
                m_strMajor = arr(0)
                m_strMinor = arr(1)
            end if
            m_bGecko = false
            m_strGeckoVersion = 0
        elseif InStr(m_strUserAgent, "safari") then
            m_strBrowser = "Safari"
            mystart = InStr(m_strUserAgent, "safari/") + 7
            m_strVersion = right(m_strUserAgent, len(m_strUserAgent) - mystart + 1)
            m_bGecko = false
            m_strGeckoVersion = 0
        elseif InStr(m_strUserAgent, "bot") or InStr(m_strUserAgent, "google") or _
            InStr(m_strUserAgent, "slurp") or InStr(m_strUserAgent, "scooter") or _
            InStr(m_strUserAgent, "spider") or InStr(m_strUserAgent, "infoseek") then
            m_strBrowser = "bot"
        elseif InStr(m_strUserAgent, "msie") then
            m_strBrowser = "MSIE"
            mystart = InStr(m_strUserAgent, "msie")
            myend = InStr(mystart, m_strUserAgent, ";")
            m_strVersion = mid(m_strUserAgent, mystart + 5, myend - mystart - 5)
            arr = Split(m_strVersion, ".")
            if UBound(arr) >= 1 then
                m_strMajor = arr(0)
                m_strMinor = arr(1)
            end if
        elseif InStr(m_strUserAgent, "netscape") then
            m_strBrowser = "Netscape"
            mystart = InStr(m_strUserAgent, "netscape")
            myend = InStr(mystart, m_strUserAgent, " ")
            if myend < mystart then
	            m_strVersion = right(m_strUserAgent, len(m_strUserAgent) - mystart - 8)
            else
	            m_strVersion = mid(m_strUserAgent, mystart + 9, myend - mystart - 9)
	        end if
            arr = Split(m_strVersion, ".")
            if UBound(arr) >= 1 then
                m_strMajor = arr(0)
                m_strMinor = arr(1)
            end if
        elseif InStr(m_strUserAgent, "firebird") then
            m_strBrowser = "Firebird"
            m_strVersion = m_strGeckoVersion
        elseif InStr(m_strUserAgent, "mozilla") then
            mystart = InStr(m_strUserAgent, "mozilla/")
            myend = InStr(mystart, m_strUserAgent, " ")
            m_strVersion = mid(m_strUserAgent, mystart + 8, myend - mystart - 8)
            arr = Split(m_strVersion, ".")
            if UBound(arr) >= 1 then
                m_strMajor = arr(0)
                m_strMinor = arr(1)
            end if
            if m_strMajor <= 4 then
                m_strBrowser = "Netscape"
                m_strMinor = left(m_strMinor, 1)
                m_strVersion = m_strMajor & "." & m_strMinor
            else
                m_strBrowser = "Mozilla"
                m_strVersion = m_strGeckoVersion
            end if
        else
            m_strBrowser = "Other"
        end if
        
        if InStr(m_strUserAgent, "win") then
            if InStr(m_strUserAgent, "windows 9") or InStr(m_strUserAgent, "win9") then
                m_strPlatform = "Windows9X"
            elseif InStr(m_strUserAgent, "windows nt") or InStr(m_strUserAgent, "windows 2000") or InStr(m_strUserAgent, "windows xp") then
                m_strPlatform = "WindowsNT"
            else
                m_strPlatform = "Windows"
            end if
        elseif InStr(m_strUserAgent, "linux") then
            m_strPlatform = "Linux"
        elseif InStr(m_strUserAgent, "mac") then
            m_strPlatform = "Mac"
        elseif InStr(m_strUserAgent, "freebsd") then
            m_strPlatform = "FreeBSD"
        elseif InStr(m_strUserAgent, "sunos") then
            m_strPlatform = "SunOS"
        elseif InStr(m_strUserAgent, "irix") then
            m_strPlatform = "IRIX"
        elseif InStr(m_strUserAgent, "beos") then
            m_strPlatform = "BeOS"
        elseif InStr(m_strUserAgent, "os/2") then
            m_strPlatform = "OS/2"
        elseif InStr(m_strUserAgent, "aix") then
            m_strPlatform = "AIX"
        elseif InStr(m_strUserAgent, "nix") then
            m_strPlatform = "Unix"
        else
            m_strPlatform = "Other"
        end if

        m_bHtmlEdit = _
			((m_strBrowser = "MSIE") and (m_strVersion >= 5.5) and InStr(m_strPlatform, "Windows")) or _
			((m_strBrowser = "Firebird") and (m_strGeckoVersion >= 20030924)) or _
			(m_bGecko and (m_strGeckoVersion >= 20030624)) or _
			((m_strBrowser = "Safari") and (m_strVersion >= 412.5))

    end sub

    public function GetUserAgent
        GetUserAgent = m_strUserAgent
    end function

    public function GetPlatform
        GetPlatform = m_strPlatform
    end function

    public function GetBrowser
        GetBrowser = m_strBrowser
    end function

    public function GetMajor
        GetMajor = m_strMajor
    end function

    public function GetMinor
        GetMinor = m_strMinor
    end function

    public function GetVersion
        GetVersion = m_strVersion
    end function

    public function IsGecko
        IsGecko = m_bGecko
    end function

    public function GetGeckoVersion
        GetGeckoVersion = m_strGeckoVersion
    end function

    public function HasHtmlEdit
        HasHtmlEdit = m_bHtmlEdit
    end function

end class

%>