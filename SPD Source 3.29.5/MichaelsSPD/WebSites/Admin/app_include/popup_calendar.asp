<%
dim f, today, m, y, d, i, firstday, daysinmonth, thismonth, SCRIPT

SCRIPT = request.servervariables("script_name")
f = request("f")
today = date()
m = request("m")
y = request("y")
if (m = "") then m = month(today)
if (y = "") then y = year(today)
thismonth = dateserial(y, m, 1)
%>
<html>
<head>
<title>Calendar</title>
<script language="javascript">
function getvalue(d) {
	window.opener.document.theForm.<%=f%>.value = d;
	window.close();
	return(1);
}
</script>
<style type="text/css">
	.small {
		font-size:8pt;
		font-family:verdana,sans-serif;
		text-align:center;
	}
	td {
		font-size:8pt;
		font-family:verdana,sans-serif;
		text-align:center;
	}
	a {
		font-size:8pt;
		font-family:verdana,sans-serif;
		text-align:center;
		text-decoration: none;
	}
	a:hover {
		text-decoration: none;
		color: white;
		background-color: #333;
	}
</style>
</head>

<body bgcolor="cccccc" link="0000ff" vlink="0000ff" alink="0000ff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor=cccccc class="small">
	<tr>
		<td colspan=7>
			<table width="100%" border="0" cellspacing="1" cellpadding="1">
				<tr>
					<td><a href="<%= SCRIPT %>?f=<%= server.urlencode(f) %>&m=<%= month(dateadd("m", -1, thismonth)) %>&y=<%= year(dateadd("m", -1, thismonth)) %>">&lt;&lt;</a></td>
					<td><b><%= monthname(m) %></b></td>
					<td><a href="<%= SCRIPT %>?f=<%= server.urlencode(f) %>&m=<%= month(dateadd("m", 1, thismonth)) %>&y=<%= year(dateadd("m", 1, thismonth)) %>">&gt;&gt;</a></td>
				</tr>
				<tr>
					<td><a href="<%= SCRIPT %>?f=<%= server.urlencode(f) %>&m=<%= month(thismonth) %>&y=<%= y-1 %>">&lt;&lt;</a></td>
					<td><b><%= y %></b></td>
					<td><a href="<%= SCRIPT %>?f=<%= server.urlencode(f) %>&m=<%= month(thismonth) %>&y=<%= y+1 %>">&gt;&gt;</a></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="ffffff">
		<td><b>S</b></td>
		<td><b>M</b></td>
		<td><b>T</b></td>
		<td><b>W</b></td>
		<td><b>T</b></td>
		<td><b>F</b></td>
		<td><b>S</b></td>
	</tr>
	<tr bgcolor="ececec">
	<%
		daysinmonth = datepart("d", dateadd("d", -1, month(dateadd("m", 1, thismonth)) & "/1/" & y))
		firstday = weekday(thismonth)

		for i = 1 to 42
			d = i-firstday+1
			if (i >= firstday and d <= daysinmonth) then
				if (today = dateserial(y, m, d)) then	
					response.write "<td align=""center"" bgcolor=""ffff00"">"
				else
					response.write "<td align=""center"" id=""dateTD"">"
				end if
				if (today = dateserial(y, m, d)) then response.write "<b>"
				response.write "<a href=""javascript:getvalue('" & dateserial(y, m, d) & "');"">"
				response.write d
				response.write "</a>"
				if (today = dateserial(y, m, d)) then response.write "</b>"
				response.write "</td>"
			else
				response.write "<td>&nbsp;</td>"
			end if
			if i < 36 then
				if (i mod 7 = 0) then response.write "</tr><tr bgcolor=""ececec"">"
			end if
		next
	%>
	</tr>
</table>


</body>
</html>
