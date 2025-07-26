<%
Dim security_redirStr
if InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "forgotpwd.asp") <= 0 _
	and InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "thumbnail.asp") <= 0 _
	and InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "image.asp") <= 0 _
	and InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "file.asp") <= 0 _
	and InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "batch_thumbnail.asp") <= 0 _
	and InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "login.asp") <= 0 _
	and InStr(LCase(Request.ServerVariables("SCRIPT_NAME")), "logout.asp") <= 0 then
	
	security_redirStr = "http://"
	if Len(Trim(Request.ServerVariables("HTTPS"))) > 0 then
		if LCase(Trim(Request.ServerVariables("HTTPS"))) = "on" then
			security_redirStr = "https://"
		end if
	end if
	security_redirStr = security_redirStr & Request.ServerVariables("SERVER_NAME")
	if Len(Trim(Request.ServerVariables("SERVER_PORT"))) > 0 then
		if Trim(Request.ServerVariables("SERVER_PORT")) <> "80" then
			security_redirStr = security_redirStr & ":" & Trim(Request.ServerVariables("SERVER_PORT"))
		end if
	end if
	if Len(Trim(Request.ServerVariables("URL"))) > 0 then
		security_redirStr = security_redirStr & Trim(Request.ServerVariables("URL"))
	end if
	if Len(Trim(Request.ServerVariables("QUERY_STRING"))) > 0 then
		security_redirStr = security_redirStr & "?" & Trim(Request.ServerVariables("QUERY_STRING"))
	end if

	if Trim(Session.Value("UserID")) = "" then
		if Len(Trim(Request("g"))) >= 28 then
			Response.Redirect Replace(Replace(Replace(Application.Value("AdminToolURL") & "/app_include/dologin_guid.asp?g=" & Request("g") & "&redir=" & Server.URLPathEncode(security_redirStr), "//", "/"), "http:/", "http://"), "https:/", "https://")
		elseif Len(Trim(Request.Cookies("PORTAL_AUTHENTICATED_USER")("USER_GUID"))) >= 28 then
			Response.Redirect Replace(Replace(Replace(Application.Value("AdminToolURL") & "/app_include/dologin_guid.asp?g=" & Request.Cookies("PORTAL_AUTHENTICATED_USER")("USER_GUID") & "&redir=" & Server.URLPathEncode(security_redirStr), "//", "/"), "http:/", "http://"), "https:/", "https://")
		elseif Len(Trim(Request.ServerVariables("HTTP_IV_USER"))) > 0 or Len(Trim(Request.ServerVariables("HTTP_IV_GROUPS"))) > 0 or Len(Trim(Request.ServerVariables("AUTH_USER"))) > 0 then
			Response.Redirect Replace(Replace(Replace(Application.Value("AdminToolURL") & "/app_include/dologin_sso.asp?HTTP_IV_USER=" & Trim(Request.ServerVariables("HTTP_IV_USER")) & "&HTTP_IV_GROUPS=" & Trim(Request.ServerVariables("HTTP_IV_GROUPS")) & "&AUTH_USER=" & Trim(Request.ServerVariables("AUTH_USER")), "//", "/"), "http:/", "http://"), "https:/", "https://")
		else
			Response.Redirect Replace(Replace(Replace(Application.Value("AdminToolURL") & "/login.asp?redir=" & Server.URLPathEncode(security_redirStr), "//", "/"), "http:/", "http://"), "https:/", "https://")
		end if
	end if
	
end if
%>
