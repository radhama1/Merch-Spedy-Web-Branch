<%@ Page Language="VB" AutoEventWireup="false" CodeFile="closeform.aspx.vb" Inherits="closeform" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title></title>
<script type="text/javascript" language="javascript">
<!--
function closeForm()
{
    
    <% If Request("r") = "1" Then %>
    window.parent.opener.location.href = window.parent.opener.location.href;
    <% End If %>
    
    <% If Request("rl") = "1" Then %>
    window.parent.opener.reloadPage();
    <% End If %>
    window.close();
}
//-->
</script>
</head>
<body onload="closeForm();">
    <form id="form1" runat="server">
    <div>
    
    </div>
<script type="text/javascript" language="javascript">
<!--
   // debugger;
closeForm();
//-->
</script>
    </form>
</body>
</html>
