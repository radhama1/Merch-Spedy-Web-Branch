<%@ page language="VB" autoeventwireup="false" aspcompat="true"  CodeBehind="" %>
    <!--#INCLUDE FILE="include/adovbs.inc"-->
<%
    dim objConn, objRS, connStr, strSQL, loginError, LOGON_USER, vendorId, company, userId, secChkURL, msg, phone, Env
    
    msg = ""
    on error resume next
    Env = ConfigurationManager.AppSettings("Environment")
    
    on error goto 0
    If Env = "DEV" then
        secChkURL = "http://192.168.12.56/check_sessionguid.asp"
    end if
    
    if Env = "BETA" then
        secChkURL = "http://192.168.12.56/check_sessionguid.asp"
    end if
    
    if Env = "PROD" then
        secChkURL = "https://www.vendorconnect.com/check_sessionguid.asp"
    end if

    if Env = "VENDOR" then
        secChkURL = "https://www.vendorconnect.com/check_sessionguid.asp"
    end if

    'process login form
        'dim item
    'for each item in request.form
    '	response.write(item & ": " & request(item) & "<br>")
    'next
    'response.end

    vendorId = Request.Form("vendorId")
    if vendorId="TEST01" then
	    vendorId="61153" 
	    company="LI & FUNG / 4KIDS CO. MFG LT"
    end if
    
    userId=request.form("userId")
    If userId="" then
	    userId=request.form("email")		'	"undefined"
    end if
    
    if instr(vendorId, ",") then
	    vendorId=left(vendorId, instr(vendorId, ",")-1)
    end if

' -------------------------------------------------------------------------------
' Verify User came from VendorConnect Website   -- Begin code
' FJL - 10/08/2010 Code commented out for now for later implementation
' -------------------------------------------------------------------------------

    'check that this is a valid user transfer by checking with vendorConnect.com
'    dim xmlhttp, inner_html, DataToSend, sessionGUID
'    xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")

    'open target login page
'    xmlhttp.Open("POST", secChkURL, False)

    'set header to tell the receiving site we are posting form data
'    xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")

'    sessionGUID = Request.Form("mySessionId")

'    DataToSend = "vendorID=" & vendorID & "&session_guid=" & sessionGUID ' & "&ts="  & cstr(now())
    
     'response.write ("Data to send: " & DataToSend & "<br />")
     'response.end

'    on error resume next
'    inner_html = ""

'    xmlhttp.send(DataToSend)				' send data in the form of a post

'    Response.ContentType = "text"		    ' get data as text
'    inner_html = xmlhttp.responsetext       ' return response from web page

    ' Response.Write("<html><head><title>hello</title></head><body><p>Response from VendorConnect. ---" & inner_html & "--- </p></body></html>")
    ' response.end

'    if inner_html = "0" then
'        msg = "Invalid credentials were sent for Spedy.  Contact Support if you believe you received this message in error."
'    end if
    
'    if len(inner_html) <> 1 then
'        msg = "Invalid Response from VendorConnect. Please contact support if this continues to happen."
'    end if
    
'    if len(inner_html) = 1 and inner_html <> "0" and inner_html <> "1" then
'        msg = "Invalid Return code: " & inner_html & " receieved from VendorConnect. Please contact support if this continues to happen."
'    end if

'    xmlhttp = nothing

'    on error goto 0

    ' response.write("OK")
    ' response.end

' -------------------------------------------------------------------------------
' Verify User came from VendorConnect Website   -- End code
' -------------------------------------------------------------------------------
' Disabled Vendor connect check. Remove following line with Handshake code is implemented
    msg = ""
    
    if msg = "" then
        if userId<>"" and isnumeric(vendorId) then
	        connStr = "Provider=sqloledb;" & ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString & ";"
	        objConn = Server.CreateObject("ADODB.Connection")
	        objRS = Server.CreateObject("ADODB.RecordSet")
	        objConn.Open(connStr)

            ' Replace with stored proc
	        ' strSQL = "select * from spd_vendor where vendor_number=" & vendorId
	        
	        strSQL = "exec usp_SPD_VC_GetVendorInfo @VendorID = " & vendorId
	        objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	        
	        company = ""
	        phone = ""

	        if not objRS.eof then
		        company=objRS("vendor_name").value
	        else
		        company="undefined"
	        end if

	        if len(company) = 0 then
	            company="undefined"
	        end if
	        
	        objRS.close

	        ' strSQL = "select * from security_user where username='" & userId & "_" & vendorId & "' and enabled=1"
	        strSQL = "exec usp_SPD_VC_GetUserInfo @UserName = '" & userId & "_" & vendorId & "'"
	        
	        objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	        if not objRS.eof then
                                'vendorId: TEST01
                                'userId: SPEDY_1@aplaceonthenet.com
                                'mySessionId: 1207850424873_5770214461453577
                                'email: SPEDY_1@aplaceonthenet.com
                                'company: TEST01
                                'phone: 123-123-1234
                                'lastname: User
                                'firstname: Test
		        Session("UserID") = CType(objRS("ID").value, Integer)
		        session("Email_Address")=objRS("Email_Address").value
		        session("UserName")=left(objRS("UserName").value, instrrev(objRS("UserName").value, "_")-1)
		        session("vendorId")=right(objRS("UserName").value, len(objRS("UserName").value)-instrrev(objRS("UserName").value, "_"))
		        session("Last_name")=objRS("Last_name").value
		        session("First_Name")=objRS("First_Name").value
		        session("Organization")=objRS("Organization").value
		        session("FromVendorConnect") = true
	        else
	            objRS.close
	            objRS = nothing

                phone = request.form("phone")

	            strSQL = "exec usp_SPD_VC_CreateUser "
	            strSQL = strSQL & "@Email = '" & request.form("email") & "', "
	            strSQL = strSQL & "@UserName = '" & userId & "_" & vendorId & "', "
	            strSQL = strSQL & "@LastName = '" & request.form("lastname") & "', "
	            strSQL = strSQL & "@FirstName = '" & request.form("firstname") & "', "
	            strSQL = strSQL & "@Org = '" & company & "', "
	            strSQL = strSQL & "@OffLoc = '" & phone & "'"
	            
	            objRS = Server.CreateObject("ADODB.RecordSet")
    	        objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
		        
		                'objRS.addnew
		                'objRS("Email_Address").value=request.form("email")
		                'objRS("UserName").value=userId & "_" & vendorId
		                'objRS("Last_name").value=request.form("lastname")
		                'objRS("First_Name").value=request.form("firstname")
		                'objRS("Organization").value=company
		                'objRS("office_location").value=request.form("phone")
		                'objRS.update
		                'objRS.requery
        		        
		        Session("UserID") = CType(objRS("ID").value, Integer)
		        session("Email_Address")=objRS("Email_Address").value
		        session("UserName")=left(objRS("UserName").value, instr(objRS("UserName").value, "_"))
		        session("vendorId")=right(objRS("UserName").value, len(objRS("UserName").value)-instrrev(objRS("UserName").value, "_"))
		        session("Last_name")=objRS("Last_name").value
		        session("First_Name")=objRS("First_Name").value
		        session("Organization")=objRS("Organization").value
	        end if
	        objRS.close
	        objRS = nothing
	        objConn = nothing
	        response.redirect("default.aspx")
        end if

        'process hardcoded password
        'if request.form("username")="admin" and request.form("password")="spedy" then
	    '    session("UserID")=2
	    '    session("Email_Address")="tom@novalibra.com"
	    '    session("UserName")="TGREENHAW"
	    '    session("Last_name")="User"
	    '    session("First_Name")="Test"
	    '    session("Organization")="Nova Libra"
	    '    response.redirect("default.aspx")
        'end if
        'dim item1
        'response.write("Session Contents:<BR>")
        'for each item1 in session.contents
        '	response.write(item1 & ": " & session(item1).tostring()  & "<BR>")
        'next 
    end if
 %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Item Data Management</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <meta name="author" content="Randy Cochran" />
    <link rel="stylesheet" href="css/styles.css" type="text/css" />
    <script type="text/javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
</head>
<body>
<%
    'dim item
    'response.write("Request Contents:<BR>")
    'for each item in request.form
    '	response.write(item & ": " & request.form(item).tostring()  & "<BR>")
    'next 

%>
    <form method="post" action="vendorconnect_login.aspx">
    <div id="sitediv">
	    <div id="bodydiv">
		    <div id="header">
			    <div class="spacer"></div>
			    <div id="logo"><img src="images/logo.png" border="0" alt="Home" /></div>
			    <div id="search">
				    &nbsp;
			    </div>
			    <div class="spacer"></div>
		    </div>
		    <div id="content">
			    <div id="shadowtop"></div>
			    <div id="main" style="text-align:center">
			        <p><%=msg %></p>
			        <br />
			        <input type="button" id="close" onclick="javascript:window.close();return false;" value="Close Window" />
<%--				    <div id="login">
					    <div id="logincontent">
							    <asp:Label ID="loginError" runat="server"></asp:Label><CENTER><FONT COLOR="DD0000"><B><%=loginError%></B></FONT></CENTER>
							    <table cellpadding="5" cellspacing="0" border="0">
								    <tr>
									    <td align="right">&nbsp;</td>
									    <td align="center"><img src="images/hdr_user_login.gif" width="91" height="18" border="0" alt="User Login" /></td>
								    </tr>
								    <tr>
									    <td align="right"><img src="images/hdr_username.gif" width="66" height="10" border="0" alt="Username" /></td>
									    <td align="left"><input type="text" name="username" maxlength="25" value="<%=request("username")%>" /></td>
								    </tr>
								    <tr>
									    <td align="right"><img src="images/hdr_password.gif" width="61" height="10" border="0" alt="Password" /></td>
									    <td align="left"><input type="password" name="password" maxlength="25" /></td>
								    </tr>
								    <tr>
									    <td align="right">&nbsp;</td>
									    <td align="center"><input type="image" src="images/btn_login.gif" width="46" height="16" border="0" alt="LOGIN" value="submit" /></td>
								    </tr>
							    </table>
					    </div>
				    </div>
--%>			    </div>
			    <div id="shadowbottom"></div>
		    </div>
		    <div id="footer">
			    &nbsp;
		    </div>
	    </div>
    </div>
    </form>
</body>
</html>

