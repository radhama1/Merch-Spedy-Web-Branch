<%@ Control Language="VB" AutoEventWireup="false" CodeFile="NovaGrid.ascx.vb" Inherits="NovaGrid" %>
<%@ Import Namespace="NovaLibra.Common.Utilities" %>
<%
	Dim i As Integer
%>

<%	If Not Me.ExcelMode Then%>
<div id="gridContainer">
	<input type="hidden" id="selectedItemID" value="0" />
	<input type="hidden" id="hoveredItemID" value="0" />
	<div id="divSearch" class="gS<%If Not ShowSearch() Then Response.Write(" gHideInit")%>">
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td style="height:29px;">
					Search
					<asp:TextBox ID="txtSearch" MaxLength="50" CssClass="gS" runat="server"></asp:TextBox> 
					<asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="searchButton" /> 
                    <asp:Button id="btnClear" runat="server" Text="Clear" CssClass="searchButton" /> &nbsp;
					<asp:HyperLink ID="btnSort" runat="server" NavigateUrl="#">Sort</asp:HyperLink> 
					<asp:Label ID="btnFilterLabel" runat="server" Text="  |  "></asp:Label> 
					<asp:HyperLink ID="btnFilter" runat="server" NavigateUrl="#">Filter</asp:HyperLink>
					<asp:Label ID="btnExcelLabel" runat="server" Text="  |  "></asp:Label> 
					<asp:HyperLink ID="btnExcel" runat="server" NavigateUrl="#">Excel</asp:HyperLink>
					<asp:Label ID="btnAddLabel" runat="server" Text="  |  "></asp:Label> 
					<asp:HyperLink ID="btnAdd" runat="server" NavigateUrl="#">Add record</asp:HyperLink>
					<asp:Label ID="btnCustomLabel" runat="server" Text="  |  "></asp:Label> 
					<asp:HyperLink ID="btnCustom" runat="server" NavigateUrl="#">Custom Link</asp:HyperLink>
				</td>
			</tr>
		</table>
	</div>
	<div id="gridWrapper" class="grid-container">
	<div id="gridFixed" class="grid-cell grid-cell-fixed <%If Not GridHasFixedColumns() Then Response.Write("gHideInit")%>">
		<div id="divFixedGridHeader" class="gS">

			<table border="0" cellpadding="0" cellspacing="0" class="">
				<tr>
				<%	If GridHasFixedColumns() And HighlightRow Then%>
					<td width="20" valign="bottom" class="gridHC"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "fixedheader")%>
				<%	End If%>
				<%	If GridHasFixedColumns() And HighlightRow Then%>
					<%=GetGridHeaderCells(True)%>
				<%	Else%>e
					<td></td>
				<%	End If%>
				</tr>
			</table>
		</div>

		<div id="divFixedGrid" class="gS gHide">
			<asp:Repeater ID="FixedGridDetailRowRepeater" runat="server" EnableViewState="false" >
				<HeaderTemplate>
			<table border="0" cellpadding="0" cellspacing="0">
				
				</HeaderTemplate>
				<ItemTemplate>
				<tr id="fixed_grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" class="<%=GridClassRow%>"<%#GetRowAction(DataBinder.Eval(Container.DataItem, "ID")) %>>
				<%	If GridHasFixedColumns() And HighlightRow Then%>
					<td id="h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" width="20" valign="middle" class="<%=GridClassAltRow%>" onclick="hGR('grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'fixed_grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>');" align="center"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "datahighlight")%>
				<%	End If%>
					<%#GetGridCells(Container.DataItem, "fixeddata", True)%>
				</tr>
				</ItemTemplate>
				<AlternatingItemTemplate>
				<tr id="fixed_grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" class="<%=GridClassAltRow%>"<%#GetRowAction(DataBinder.Eval(Container.DataItem, "ID")) %>>
				<%	If GridHasFixedColumns() And HighlightRow Then%>
					<td id="h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" width="20" valign="middle" class="<%=GridClassAltRow%>" onclick="hGR('grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'fixed_grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>');" align="center"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "datahighlight")%>
				<%	End If%>
					<%#GetGridCells(Container.DataItem, "fixeddata", True)%>
				</tr>
				</AlternatingItemTemplate>
				<FooterTemplate>
				<tr>
				<%	If GridHasFixedColumns() And HighlightRow Then%>
					<td width="20"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "dataimg")%>
				<%	End If%>
					<asp:Repeater ID="FixedGridDetailFooterRepeater" DataSource="<%# FixedGridItems %>" runat="server" EnableViewState="false">
					<ItemTemplate>
					<td id="col_<%# DataBinder.Eval(Container.DataItem, "ID") %>_data"><img id="col_<%# DataBinder.Eval(Container.DataItem, "ID") %>_dataimg" src="<%# ImagePath %>spacer.gif" width=""></td>
					<%#GetHeaderSep(Container.ItemIndex, "dataimg")%>
					</ItemTemplate>
					</asp:Repeater>
				</tr>
			</table>
				</FooterTemplate>
			</asp:Repeater>
		</div>
	</div>
	<div id="gridScrollable" class="grid-cell grid-cell-flex">
		<div id="divGridHeader" class="gS">
			<table border="0" cellpadding="0" cellspacing="0" class="">
				<tr>
				<%	If Not GridHasFixedColumns() And HighlightRow Then%>
					<td width="20" valign="bottom" class="gridHC"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "header")%>
				<%	End If%>
					<%=GetGridHeaderCells()%>
					<td class="gridHL"><img src="<%# ImagePath %>spacer.gif" height="1" width="45" /></td>
				</tr>
			</table>
		</div>

		<div id="gridLoader" style="padding: 25px; color: LightGrey; font-size: 12pt;">
			Loading...
		</div>
		
		<div id="divGrid" class="gS gHide">
			<asp:Repeater ID="GridDetailRowRepeater" runat="server" EnableViewState="false" >
				<HeaderTemplate>
			<table border="0" cellpadding="0" cellspacing="0">
				
				</HeaderTemplate>
				<ItemTemplate>
				<tr id="grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" class="<%=GridClassRow%>"<%#GetRowAction(DataBinder.Eval(Container.DataItem, "ID")) %>>
				<%	If Not GridHasFixedColumns() And HighlightRow Then%>
					<td id="h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" width="20" valign="middle" class="<%=GridClassAltRow%>" onclick="hGR('grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'fixed_grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>');" align="center"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "datahighlight")%>
				<%	End If%>
					<%#GetGridCells(Container.DataItem, "data")%>
				</tr>
				</ItemTemplate>
				<AlternatingItemTemplate>
				<tr id="grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" class="<%=GridClassAltRow%>"<%#GetRowAction(DataBinder.Eval(Container.DataItem, "ID")) %>>
				<%	If Not GridHasFixedColumns() And HighlightRow Then%>
					<td id="h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>" width="20" valign="middle" class="<%=GridClassAltRow%>" onclick="hGR('grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'fixed_grid_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>', 'h_row_<%#DataBinder.Eval(Container.DataItem, "ID")%>');" align="center"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "datahighlight")%>
				<%	End If%>
					<%#GetGridCells(Container.DataItem, "data")%>
				</tr>
				</AlternatingItemTemplate>
				<FooterTemplate>
				<tr>
				<%	If Not GridHasFixedColumns() And HighlightRow Then%>
					<td width="20"><img src="<%=ImagePath%>spacer.gif" width="20" height="1" alt="" /></td>
					<%=GetHeaderSep(0, "dataimg")%>
				<%	End If%>
					<asp:Repeater ID="GridDetailFooterRepeater" DataSource="<%# ScrollableGridItems %>" runat="server" EnableViewState="false">
					<ItemTemplate>
					<td id="col_<%# DataBinder.Eval(Container.DataItem, "ID") %>_data"><img id="col_<%# DataBinder.Eval(Container.DataItem, "ID") %>_dataimg" src="<%# ImagePath %>spacer.gif" height="1"></td>
					<%#GetHeaderSep(Container.ItemIndex, "dataimg")%>
					</ItemTemplate>
					</asp:Repeater>
				</tr>
			</table>
				</FooterTemplate>
			</asp:Repeater>
		</div>
		
	</div>
	</div>
	<div class="clear"></div>
	<div id="pagingNavBar" class="gS<%If Not ShowPaging() Then Response.Write(" gHideInit")%>" style="height: 20px; vertical-align: middle;">
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<%If 1 = 1 Or PageCount > 0 Then%>
				<td nowrap="nowrap"><a href="javascript:moveFirst();" /><img id="first" src="<%=ImagePath%>paging/btn_vcr_top.gif" border="0" alt="Jump to the first page" /></a><a href="javascript:<%if CurrentPage > 1 then%>movePrev();<%else%>moveFirst();<%End If%>"><img name="prev" src="<%=ImagePath%>paging/btn_vcr_prev.gif" border="0" alt="Jump to the previous page" /></a><img src="<%=ImagePath%>spacer.gif" height="2" width="5" alt=""></td>
				<td valign="top" nowrap="nowrap">
					Page <asp:DropDownList ID="pageList" runat="server" CssClass="pagingNavBarPageList"></asp:DropDownList> of <asp:Label ID="pageCountLabel" runat="server"></asp:Label>
				</td>
				<td nowrap="nowrap"><img src="<%=ImagePath%>spacer.gif" height="2" width="4" /><a href="javascript:<%if CInt(CurrentPage) = CInt(PageCount) then%>moveLast();<%else%>moveNext();<%End If%>"><img id="next" src="<%=ImagePath%>paging/btn_vcr_next.gif" border=0 alt="Jump to the next page" /></a><a href="javascript:moveLast();"><img id="last" src="<%=ImagePath%>paging/btn_vcr_bot.gif" border="0" alt="Jump to the last page" /></a></td>
				<td valign="top"><img src="<%=ImagePath%>spacer.gif" height="2" width="4" /></td>
				<td valign="middle">Show</td>
				<td valign="top"><img src="<%=ImagePath%>spacer.gif" height="2" width="4" /></td>
				<td valign="top"><asp:TextBox ID="pageSize" runat="server" CssClass="pagingNavBarPageSize" Columns="3" MaxLength="3"></asp:TextBox></td>
				<td valign="top"><img src="./../images/spacer.gif" height="2" width="4" /></td>
				<td valign="middle"><span>Records</span>
				</td>
				<td valign="top"><img src="<%=ImagePath%>spacer.gif" height="2" width="2" /></td>
				<td><a href="javascript:changePageSize();"><img id="pageSizeImg" src="<%=ImagePath%>paging/refresh.gif" alt="Click here to update number of items per page" border="0" /></a></td>
				<%	End If%>
				<% If 1 = 1 Or RecordCount > 0 Then%>
				<td valign="top"><img src="<%=ImagePath%>spacer.gif" height="2" width="10" /></td>
				<td valign="middle" align="right" width="100%">
					<span style="font-family:Arial; font-size:11px;">
					<%=RecordCount%>&nbsp;Found
					</span>
				</td>
				<td valign="top"><img src="<%=ImagePath%>spacer.gif" height="2" width="10" /></td>
				<%else%>
				<td valign="top"><img src="<%=ImagePath%>spacer.gif" height="2" width="40"></td>
				<%	End If%>
			</tr>
		</table>
	</div>
</div>

<div id="overlay" style="display:none"></div>
<div id="gridAdvancedSort" style="display:none">
<%If Me.ShowAdvancedSort Then %>
	<div class="gS" style="width: 100%;">
		<div class="gridSubheaderText">Sort Data</div>
		<div class="gS" style="width: 300px;">Specify how the data should be sorted.</div>

		<div class="gS" style="margin-top: 20px; white-space: nowrap;">
		
			<div class="gS" style="margin-bottom: 10px; white-space: nowrap;">
				<span style="width: 50px;">Sort by&nbsp;</span>
				<asp:DropDownList ID="SortSequence1" runat="server" CssClass="gS" style="width: 175px; border: 1px inset #ccc;"></asp:DropDownList>
				
				&nbsp;
				<asp:DropDownList ID="SortDirection1" runat="server" CssClass="gS" style="border: 1px inset #ccc;"></asp:DropDownList>
			</div>
			
			<div class="gS" style="margin-bottom: 10px; white-space: nowrap;">
				<span style="width: 50px;">then by&nbsp;</span>
				<asp:DropDownList ID="SortSequence2" runat="server" CssClass="gS" style="width: 175px; border: 1px inset #ccc;"></asp:DropDownList>
				
				&nbsp;
				<asp:DropDownList ID="SortDirection2" runat="server" CssClass="gS" style="border: 1px inset #ccc;"></asp:DropDownList>
			</div>
			
			<div class="gS" style="margin-bottom: 10px; white-space: nowrap;">
				<span style="width: 50px;">then by&nbsp;</span>
				<asp:DropDownList ID="SortSequence3" runat="server" CssClass="gS" style="width: 175px; border: 1px inset #ccc;" ></asp:DropDownList>
				
				&nbsp;
				<asp:DropDownList ID="SortDirection3" runat="server" CssClass="gS" style="border: 1px inset #ccc;"></asp:DropDownList>
			</div>
			
			<div class="gS" style="margin-bottom: 10px; white-space: nowrap;">
				<span style="width: 50px;">then by&nbsp;</span>
				<asp:DropDownList ID="SortSequence4" runat="server" CssClass="gS" style="width: 175px; border: 1px inset #ccc;"></asp:DropDownList>
				
				&nbsp;
				<asp:DropDownList ID="SortDirection4" runat="server" CssClass="gS" style="border: 1px inset #ccc;"></asp:DropDownList>
			</div>
			
			<div class="gS" style="margin-bottom: 10px; white-space: nowrap;">
				<span style="width: 50px;">then by&nbsp;</span>
				<asp:DropDownList ID="SortSequence5" runat="server" CssClass="gS" style="width: 175px; border: 1px inset #ccc;" ></asp:DropDownList>
				
				&nbsp;
				<asp:DropDownList ID="SortDirection5" runat="server" CssClass="gS" style="border: 1px inset #ccc;"></asp:DropDownList>
			</div>

		</div>
		
	</div>
	<div class="gS" style="width: 325px; padding-top: 20px;">
		<table cellpadding=0 cellspacing=0 border=0 width=100%>
			<tr>
				<td><input type=button id="btnCancel" value="Cancel" onclick=""></td>
				<td width="10"><img src="./../images/spacer.gif" height="1" width="5" border="0"></td>
				<td><input type=button id="btnClearSort" value="Clear" onclick="sortDoClear();"></td>
				<td width="100%"><img src="./../images/spacer.gif" height="1" width="5" border="0"></td>
				<td><input type=button id="btnCommit" value="Okay, Apply these Settings" onClick="sortDoCommit();"></td>
			</tr>
		</table>
	</div>
<%End If%>
</div>





<div id="gridAdvancedFilter" style="display:none">
<%	If Me.ShowAdvancedFilter Then%>
	<input type="hidden" id="EditSavedFilterID" value="" />
	<input type="hidden" id="SavedFilterID" value="" />
	<div class="gS" style="width: 100%;">
		<div class="gridSubheaderText">Filter Data</div>
		<div class="gS" style="width: 100%;">Filtering allows you to more efficiently analyze information by limiting the data displayed.</div>

		<div class="gS" style="width: 100%; padding-top: 10px;">
			<table cellpadding=0 cellspacing=0 border=0>
				<%	If Me.CurrentAdvancedFilter <> "<Filter />" And Len(Me.CurrentAdvancedFilter) > Len("<Filter />") Then%>
				<tr>
					<td><input type="radio" name="chkAction" id="chkAction_NewFilter" value="0"<%If Me.CurrentAdvancedFilterID = 0 then%> checked="checked"<%End If%> onclick="chooseAction(); loadDefaultFilter(); clickSaveAs();"></td>
					<td><img src="./../images/spacer.gif" height="1" width="5" border="0" /></td>
					<td class="gS" nowrap="nowrap"><label for="chkAction_NewFilter">Edit the current filter</label></td>
					<td><img src="./../images/spacer.gif" height="1" width="20" border="0" /></td>
					<td></td>
				</tr>
				<tr><td><img src="./../images/spacer.gif" height="5" width="1" border="0" /></td></tr>
				<tr>
					<td><input type="radio" name="chkAction" id="chkAction_ClearFilter" value="0" onclick="chooseAction()"></td>
					<td><img src="./../images/spacer.gif" height="1" width="5" border="0" /></td>
					<td class="gS" nowrap="nowrap"><label for="chkAction_ClearFilter">Clear the current filter</label></td>
					<td><img src="./../images/spacer.gif" height="1" width="20" border="0" /></td>
					<td></td>
				</tr>
				<tr><td><img src="./../images/spacer.gif" height="5" width="1" border="0" /></td></tr>
				<%	Else%>
				<tr>
					<td><input type="radio" name="chkAction" id="chkAction_NewFilter" value="0" checked onclick="chooseAction()"></td>
					<td><img src="./../images/spacer.gif" height="1" width="5" border="0" /></td>
					<td class="gS" nowrap="nowrap"><label for="chkAction_NewFilter">Create a new filter</label></td>
					<td><img src="./../images/spacer.gif" height="1" width="20" border="0" /></td>
					<td></td>
				</tr>
				<tr><td><img src="./../images/spacer.gif" height="5" width="1" border="0" /></td></tr>
				<%	End If%>
				<tr>
					<td><input type="radio" name="chkAction" id="chkAction_EditSavedFilter" value="1"<%If Session("Custom_Filter_ID") <> "" Then%> checked="checked"<%End If%> onclick="chooseAction()"<%If Not Me.SavedFilters.HasRows Then%> disabled="disabled"<%End If%>></td>
					<td></td>
					<td class="gS"<%If Not Me.SavedFilters.HasRows Then%> style="color: #999;"<%End If%> nowrap="nowrap"><label for="chkAction_EditSavedFilter">Apply this saved filter:</label></td>
					<td></td>
					<td class="gS" nowrap="nowrap">
						<select name="Select_EditSavedFilter" id="Select_EditSavedFilter"<%If Me.CurrentAdvancedFilterID = 0 Then%> disabled="disabled"<%End If%> class="gS<%If Me.CurrentAdvancedFilterID = 0 Then%> disabled<%End If%>" style="border: 1px inset #ccc; width: 200px;" onchange="">
							<option value="0"></option>
							<%
								If Me.SavedFilters.HasRows Then
									For i = 0 To Me.SavedFilters.Count - 1
										Response.Write("<option value=""" & Me.SavedFilters.Item(i, "ID") & """" & IIf(Me.CurrentAdvancedFilterID = DataHelper.SmartValues(Me.SavedFilters.Item(i, "ID"), "Integer"), " selected=""selected""", "") & ">" & DataHelper.SmartValues(Me.SavedFilters.Item(i, "Filter_Name"), "String") & "</option>")
									Next i
								End If
							%>
						</select>
					</td>
				</tr>
				<tr><td><img src="./../images/spacer.gif" height="5" width="1" border="0" /></td></tr>
				<tr>
					<td><input type="radio" name="chkAction" id="chkAction_DeleteSavedFilter" value="2" onclick="chooseAction()"<%If Not Me.SavedFilters.HasRows Then%> disabled="disabled"<%End If%>></td>
					<td></td>
					<td class="gS"<%If Not Me.SavedFilters.HasRows Then%> style="color: #999;"<%End If%> nowrap="nowrap"><label for="chkAction_DeleteSavedFilter">Remove this saved filter:</label></td>
					<td></td>
					<td class="gS" nowrap="nowrap">
						<select name="Select_RemoveSavedFilter" id="Select_RemoveSavedFilter" disabled="disabled" class="gS disabled" style="border: 1px inset #ccc; width: 200px;" onchange="">
							<option value="0"></option>
							<%
								If Me.SavedFilters.HasRows Then
									For i = 0 To Me.SavedFilters.Count - 1
										Response.Write("<option value=""" & Me.SavedFilters.Item(i, "ID") & """" & ">" & DataHelper.SmartValues(Me.SavedFilters.Item(i, "Filter_Name"), "String") & "</option>")
									Next i
								End If
							%>
						</select>
					</td>
				</tr>
			</table>
		</div>

		<div class="gS" style="margin-top: 20px; white-space: nowrap;">
			<table cellpadding="0" cellspacing="5" border="0">
			<%
			'Response.Write Server.HTMLEncode(Session.Value("Custom_Filter_XML")) & "<br>"
				For i = 1 To 10
					If Me.GridItems.Count > 0 Then
			%>
			<tr>
				<%	If i > 1 Then%>
				<td class="gS" style="white-space: nowrap;" valign=top>
					<div style="height: 22px;">
						<select name="<%=i%>_Filter_Conjunction" id="<%=i%>_Filter_Conjunction" disabled="disabled" class="gS disabled" style="border: 1px inset #ccc;" onchange="">
							<option value=""></option>
							<option value="and">AND</option>
							<option value="or">OR</option>
						</select>
					</div>
				</td>
				<%	End If%>
				<td class="gS" style="white-space: nowrap;"<%If i = 1 Then%> colspan="2"<%End If%> valign="top">
					<div style="height: 22px;">
						<select name="<%=i%>_Filter_Column" id="<%=i%>_Filter_Column"<%If i > 1 Then%> disabled="disabled"<%End If%> class="gS<%If i > 1 Then%> disabled="disabled"<%End If%>" style="<%if i = 1 then%>width: 204px;<%Else%>width: 150px;<%End If%> border: 1px inset #ccc;" onchange="validateSelection('<%=i%>');">
							<option value="" coltype="" colname=""></option>
							<%
								For Each gi As GridItem In GridItems
									If gi.FilterColumn Then
										Response.Write("<option value=""" & gi.FieldName & """ coltype=""" & gi.FieldType & """ colname=""" & gi.FieldName & """>" & gi.HeaderText.Replace("<br>", " ").Replace("<br />", " ").Replace("<em>", "").Replace("</em>", "") & "</option>")
									End If
								Next
							%>
						</select>
					</div>
				</td>
				<td class="gS" style="white-space: nowrap;" valign=top>
					<div style="height: 22px;">
						<select name="<%=i%>_Filter_Verb" id="<%=i%>_Filter_Verb" disabled="disabled" class="gS disabled" style="border: 1px inset #ccc; width: 150px;" onchange=""></select>
					</div>
				</td>
				<td class="gS" style="white-space: nowrap; padding: 0; margin: 0;" valign=top>
					<div id="" class="" style="white-space: nowrap; width: 104px; height: 24px; background: #ececec; padding: 0; margin: 0;">
						<input type="text" name="<%=i%>_Filter_Value_String" id="<%=i%>_Filter_Value_String" class="gS" style="width: 104px; display: none;" value="">
						<input type="text" name="<%=i%>_Filter_Value_Number" id="<%=i%>_Filter_Value_Number" class="gS" style="width: 104px; display: none;" value="">
						<div id="<%=i%>_Filter_Value_BetweenEntryBlock" class="gS" style="display: none; white-space: nowrap; line-height: 12px;"><input type="text" name="<%=i%>_Filter_Value_BetweenLeft" id="<%=i%>_Filter_Value_BetweenLeft" class="gS" style="width: 40px; text-align: right;" value="">&nbsp;and&nbsp;<input type="text" name="<%=i%>_Filter_Value_BetweenRight" id="<%=i%>_Filter_Value_BetweenRight" class="gS" style="width: 40px; text-align: right;" value=""></div>
						<select name="<%=i%>_Filter_Value_Select" id="<%=i%>_Filter_Value_Select" class="gS" style="border: 1px inset #ccc; width: 104px; display: none;" onchange=""></select>
						<select name="<%=i%>_Filter_Value_SelectMultiple" id="<%=i%>_Filter_Value_SelectMultiple" multiple="true" size="3" class="gS" style="border: 1px inset #ccc; width: 104px; display: none;" onchange=""></select>
						<input type="text" name="<%=i%>_Filter_Value_Date" id="<%=i%>_Filter_Value_Date" class="gS" style="width: 104px; display: none;" value="">
					</div>
				</td>
			</tr>
			<%
					End If
				Next
			%>
			</table>
		</div>
		
	</div>

	<div class="gS" style="width: 100%; padding-top: 10px;">
		<table cellpadding=0 cellspacing=0 border=0>
			<tr>
				<td><input type=checkbox name="chkSaveAs" id="chkSaveAs" value="1" onclick="clickSaveAs()"></td>
				<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
				<td class="gS" nowrap="nowrap"><label for="chkSaveAs">Save these filter settings as:</label></td>
				<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
				<td class="gS" nowrap="nowrap"><input type="text" disabled name="txtSaveAsName" id="txtSaveAsName" class="gS disabled" style="width: 200px;" maxlength="200" value=""></td>
			</tr>
			<tr><td><img src="./../images/spacer.gif" height=5 width=1 border=0></td></tr>
		</table>
		<input type="hidden" id="Select_SendTo" value="<%=Session("UserID")%>" />
	</div>

	<div class="gS" style="width: 100%; padding-top: 20px;">
		<table cellpadding=0 cellspacing=0 border=0 width=100%>
			<tr>
				<td><input type=button id="btnCancelFilter" value="Cancel" onClick=""></td>
				<td width="10"><img src="./../images/spacer.gif" height="1" width="5" border="0"></td>
				<td><input type=button id="btnClearFilter" value="Clear" onclick="filterDoClear();"></td>
				<td width="100%"><img src="./../images/spacer.gif" height="1" width="5" border="0"></td>
				<td><input type=button name="btnCommit" value="Okay, Apply these Settings" onclick="filterDoCommit();"></td>
			</tr>
		</table>
	</div>
<%	End If%>
</div>

<!-- set all fields -->

<div id="gridSetAll" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:300px; top: 300px; display: none; z-index: 2000; width: 250px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
	<div id="gridSetAllContent">
	    <table border="0" cellpadding="0" cellspacing="0" class="gridSetAllBG" style="width: 100%">
	    <tr><td>
	        <table border="0" cellpadding="2" cellspacing="1" style="width: 100%;">
	            <tr>
	                <td id="gridSetAllHeader"><img align="right" id="close" src="<%=ImagePath%>close.gif" alt="Close" title="" border="0" onclick="setAllClose();" />Set All Values for Column</td>
	            </tr>
	            <tr class="gridSetAllRow">
	                <td style="width: 100%;"><span id="gridSetAllColumn">COLUMN-NAME</span>
	                <input type="hidden" id="gridSetAllType" value="" />
	                <input type="hidden" id="gridSetAllParam" value="" />
	                <input type="hidden" id="gridSetAllCID" value="" />
	                <input type="hidden" id="gridSetAllCName" value="" /></td>
	            </tr>
	            <tr class="gridSetAllRow">
	                <td id="gridSetAllData">COLUMN-CONTROL&nbsp;</td>
	            </tr>
	            <tr class="gridSetAllFooter">
	                <td>
	                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;" class="gridSetAllFooter">
	                        <tr>
	                            <td align="left"><input type="button" id="btnSetAllClose" onclick="setAllClose()" value="Cancel" class="formButton" style="font-weight: bold;" /></td>
	                            <td align="right"><input type="button" id="btnSetAllSave" onclick="setAllSave()" value="Set All" class="formButton" style="font-weight: bold;" /></td>
	                        </tr>
	                    </table>
	                </td>
	            </tr>
	        </table>
	    </td></tr>
	    </table>
	</div>
</div>

<!-- context menu -->
<div id="contextMenu" onclick="clickMenu()" onmouseover="switchMenu()" onmouseout="switchMenu()" style="position:absolute; display: none; width: 155px; background-color: #ececec; border: 1px solid #333333; cursor: default; filter:progid:DXImageTransform.Microsoft.Shadow(color='#999999', Direction=120, Strength=3)">
	<%If Me.ItemEditURL <> "" Then %><div class="menuItem" style="font-weight:bold;" id="ItemEdit">Edit Record</div><%End If %>
	<% If Me.ItemViewURL <> "" And Me.ItemEditURL = "" Then%><div class="menuItem" style="font-weight:bold;" id="ItemView">View Record</div><%End If %>
	<%If Me.ItemDeleteURL <> "" Then %><div class="menuItem" id="ItemDelete">Delete Record</div><%End If %>
	<%If Me.ItemEditURL <> "" Or Me.ItemDeleteURL <> "" Then %><div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height=1 width=1></div></div><%End If%>
	<%If Me.ItemAddURL <> "" Then %><div class="menuItem" id="ItemAdd"><%If Me.ItemAddText <> String.Empty Then%><%=Me.ItemAddText%><%Else%>New Record<%End If%></div><%End If %>
	<% If Me.CustomLink <> String.Empty AndAlso Me.CustomLinkText <> String.Empty Then%>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height="1" width="1" alt="" /></div></div>
	<div class="menuItem" id="ItemCustom"><%=Me.CustomLinkText%></div>
	<%End If%>
	<div class="menuSeparator"><div style="background-color: #999999;"><img src="./images/spacer.gif" height="1" width="1" alt="" /></div></div>
	<div class="menuItem" id="CancelAction">Cancel</div>
</div>
	
<%Else %>

<asp:Repeater ID="ExcelGridHeaderRepeater" runat="server" EnableViewState="false">
	<HeaderTemplate>
<table border="1" cellpadding="0" cellspacing="0" class="">
	<tr>
	</HeaderTemplate>
	<ItemTemplate><td class="gridHC"><strong><%#GridGetHeaderText(Container.DataItem)%></strong></td></ItemTemplate>
	<FooterTemplate>
	</tr>
	</FooterTemplate>
</asp:Repeater>

<asp:Repeater ID="ExcelGridDetailRowRepeater" runat="server" EnableViewState="false" >
	<HeaderTemplate>
	</HeaderTemplate>
	<ItemTemplate>
	<tr class="<%=GridClassRow%>"><asp:Repeater ID="ExcelGridDetailRepeater" DataSource="<%# GridItems %>" runat="server" EnableViewState="false"><ItemTemplate><td class="gridC"><%#GetCellText(Container.DataItem, DataBinder.Eval(CType(CType(Container, RepeaterItem).Parent.Parent, RepeaterItem).DataItem, RecordIDColumn), DataBinder.Eval(CType(CType(Container, RepeaterItem).Parent.Parent, RepeaterItem).DataItem, DataBinder.Eval(Container.DataItem, "FieldName")))%></td></ItemTemplate></asp:Repeater></tr>
	</ItemTemplate>
	<AlternatingItemTemplate>
	<tr class="<%=GridClassAltRow%>"><asp:Repeater ID="ExcelGridDetailRepeater" DataSource="<%# GridItems %>" runat="server" EnableViewState="false"><ItemTemplate><td class="gridC"><%#GetCellText(Container.DataItem, DataBinder.Eval(CType(CType(Container, RepeaterItem).Parent.Parent, RepeaterItem).DataItem, RecordIDColumn), DataBinder.Eval(CType(CType(Container, RepeaterItem).Parent.Parent, RepeaterItem).DataItem, DataBinder.Eval(Container.DataItem, "FieldName")))%></td></ItemTemplate></asp:Repeater></tr>
	</AlternatingItemTemplate>
	<FooterTemplate>
</table>
	</FooterTemplate>
</asp:Repeater>

<%End If %>

