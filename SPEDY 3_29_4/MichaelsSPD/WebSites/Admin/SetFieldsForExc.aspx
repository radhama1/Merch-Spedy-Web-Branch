<%@ page language="VB" autoeventwireup="false" inherits="SetFieldsForExc, App_Web_1xpdmjgj" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Set Modified Fields For Exception</title>
    <script type="text/javascript" language="javascript">
    <!--
        function closeme()
        {
            //window.close();            //OnClientClick="javascript:return closeme()"

            return true;
        }

        function Cancel() {
            window.close();
            return false;
        }

        function CheckClose() {
            //debugger;
            var myValue = document.forms[0].returnValue.value
            if (myValue != "") {
                var field = document.forms[0].returnField.value
                window.opener.document.getElementById(field).value = myValue;
                window.close();
                return false;
            }
        }
    //-->
    </script>
</head>
<body style="background-color:#cccccc; overflow:hidden;" onload="CheckClose();">
    <form id="frmSelDepts" runat="server" style=" font-family:Arial; font-size:12px">
    <div style="">
        <asp:HiddenField ID="returnValue" runat="server" Value="" />
        <asp:HiddenField ID="returnField" runat="server" Value="" />
        
        <asp:HiddenField ID="hdnStageID" runat="server" Value="0"/>
        <asp:Label ID="Label2" ForeColor="Navy" runat="server" Text="Stage Name: "></asp:Label>
        <asp:Label ID="lblStageID" Font-Bold="true" runat="server" Text=""></asp:Label>
        <br />
        <asp:Label ID="Label3" ForeColor="Navy" runat="server" Text="Exception: "></asp:Label>
        <asp:Label ID="lblExcOrder" Font-Bold="true" runat="server" Text=""></asp:Label>
        <br />
        <asp:Label ID="Label4" ForeColor="Navy" runat="server" Text="Condition: "></asp:Label>
        <asp:Label ID="lblCondOrder" Font-Bold="true" runat="server" Text=""></asp:Label><br />
        <div style="text-align:center">
            <h3>
                <asp:Label ID="Label1" ForeColor="Navy" runat="server" Text="Select Modified Fields for Exception"></asp:Label>
            </h3> 
        </div>
        <div style="overflow-y:auto; overflow-x:hidden; height:425px; border-style:inset;">
            <asp:CheckBoxList ID="ChbksFieldlist" runat="server" Width = "400px" Font-Size ="10" ></asp:CheckBoxList>
        </div>
        <div style="padding-top:5px; text-align:center;">
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" Width="120px" OnClientClick="javascript:Cancel();" />&nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="btnSaveClose" runat="server" Text="Return Choices" Width="120px" />
        </div>
    </div>
    </form>
    
</body>
</html>
