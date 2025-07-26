<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE></TITLE>

</HEAD>
<BODY>
		<FORM METHOD="POST" name="skip_buyer_form" ACTION="item_action.aspx">
			<INPUT TYPE="hidden" name="batch_type" value="<%=request("batch_type")%>" />
			<INPUT TYPE="hidden" name="batch_id" value="<%=request("batch_id")%>" />
			<INPUT TYPE="hidden" name="action" value="<%=request("action")%>" />
			<INPUT TYPE="hidden" name="notes" value="<%=request("notes")%>" />
			<INPUT TYPE="hidden" name="stage" value="<%=request("stage")%>" />
		</FORM>
		<SCRIPT LANGUAGE="JavaScript">
		<!--
		skip_buyer_form.submit();
		//-->
		</SCRIPT>
</BODY>
</HTML>
