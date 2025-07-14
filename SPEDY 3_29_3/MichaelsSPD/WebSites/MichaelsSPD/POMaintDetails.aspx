<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POMaintDetails.aspx.vb" Inherits="POMaintDetails" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title>Purchase Order Maintenance</title>
	<meta name="author" content="Randy Cochran" />
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
	<link rel="stylesheet" href="css/calendar.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" type="text/css" />
	<link rel="stylesheet" href="nlcontrols/nlcontrols.css" type="text/css" />
	<style type="text/css"> 
		th 
		{ 
			text-align: left; 
			padding: 5px; 
		}
		th A:LINK 
		{ 
			color:Lime; 
			text-decoration:underline; 
		}
		th A:HOVER 
		{ 
			color:Green; 
			text-decoration:none; 
		}
		th A:ACTIVE 
		{ 
			color:Lime; 
			text-decoration:underline; 
		}
		.formLabel
		{
			text-align: right;
			white-space: nowrap;
			height: 21px;
			color:Navy;
		}
		.formField
		{
			height: 21px;
			text-align: left;
		}
		input[type='text'],input.text 
		{ 
			padding-left:2px; 
		}
		.nlcCCC
		{
			float: none;
		}
		.nlcCCC_hide
		{
			float: none;
		}
		#tblPOSKUHeaders
	    {
	        border:1px solid silver; 
	        width: 100%;
	        background-color: #cccccc;
	    }
	    #tblPOSKUHeaders td
	    {
	        text-align: center;
		    white-space: nowrap;
		    height: 21px;
		    color:Navy;
	        background-color: #cccccc;
	        padding-left:2px;
	        padding-right: 2px;
	    }
		
		#gvSKUs td
	    {
	        margin-right:3px;
	    }
	
	    #gvSKUs
	    {
	        border: 1px solid silver;
	    display: block;
	    }
			
	    #gvSKUs th
	    {
	        background-color: #cccccc;
	        color:Navy;
	        font-weight: normal;
	        font-size: 11px;
	        padding-top: 5px;
	        padding-bottom: 5px;
	    }
	
	    .gvnumbers
	    {
	        text-align:right;
	    }
	
	    .FreezeHeader
	    {
	        font-weight:bold;
            position: absolute;
        display: block;
	    }
	
		#lightbox 
		{
			display: none;
			position: absolute;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 100%;
			z-index: 200;
			text-align: center;
			vertical-align: middle;
		}
		#SKUUpdateContent
		{
			padding: 10px;
			font-size: 11px;
			line-height: 16px;
			color: #000000;
			background-color: #dedede;
		}
		#SKUUpdateSaving
		{
			padding: 10px;
			color: #000000;
			background-color: #FFFFFF;
			display: none;
			visibility: hidden;
			position: absolute;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 100%;
			z-index: 300;
		}
		#shadow 
		{
			display: none;
			visibility: hidden;
			position: absolute;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 100%;
			z-index: 100;
		}
		#validationDisplay
		{
            padding: 0;
            margin: 0;   
		}
	</style>
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
	<script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
	<script language="javascript" type="text/javascript" src="novagrid/novagrid.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script language="javascript" type="text/javascript" src="include/PurchaseOrder/POMaintDetails.js"></script>
    <script language="javascript" type="text/javascript" src="./js/calendar_us.js"></script>
	<script type="text/javascript">
	<!--

        var ajaxCounter = 0;
	    var saveSkusUpdate = 0;
	    
			function SumExpCol() 
			{
			var link = $('lnkSumExpCol');
		    var div = $('divSummary');
				if (link) 
				{
				if (link.firstChild.data == 'Show') 
					{
					link.firstChild.data = 'Hide';
						div.style.display = "block"
					}
					else 
					{
					link.firstChild.data = 'Show';
						div.style.display = "none"
					}
				}
				return false;
			}

	    function cancelForm() 
		{
		    if(PromptToSave()) {
		        if(confirm('Are you sure you want to exit the page without saving?')){
		                window.location.href = 'POMaint.aspx';		                
		        }
            }
            else {
                window.location.href = 'POMaint.aspx';
		   }
        }
		
		function ValidateDateControls()
		{
			var ctrlCollection = document.getElementById("tblAllocationsTotals").cells;
			var display;
			for (var i = 0; i < ctrlCollection.length; i++)
			{
				if (ctrlCollection[i].children.length > 1)
				{
					var ctrl = ctrlCollection[i].children[0];
					if (ctrl.type == "text")
					{
						if (ctrl.id.indexOf("NotBefore") > 0)
						{
							display = "'Not Before'";
						}
						else if (ctrl.id.indexOf("NotAfter") > 0)
						{
							display = "'Not After'";
						}
						else if (ctrl.id.indexOf("EstimatedInStockDate") > 0)
						{
							display = "'Estimated In Stock Date'";
						}
						if (ctrl.value != "")
						{
							if (!ValidateUSDate(ctrl.value)) 
							{
								ctrl.value = "";
								ctrl.focus();
								alert("One of " + display + " values is not in valid format. Please correct before continuing.");
								ctrl.style.backgroundColor = "Red";
								ctrl.onblur = function(){this.style.backgroundColor = "White";};
								return false;
							}
						}
					}
				}
			}	
			return true;	
		}
		function WriteCalendar(textCtrl)
		{
		    new tcal 
			(
				{
					'id': 0,
					'formname': 'frmPOMaintDetails',
					'controlname': textCtrl
				}
			);			
		}
		
		function FindSku(e)
		{
			if (!e)
			{
				e = window.event;
			}
			if (e.keyCode == 13) 
			{
				var btn;
				if(e.srcElement.value == "")
				{				
					btn = document.getElementById("btnClearSKU");
				}
				else
				{
					btn = document.getElementById("btnFindSKU");
				}
				btn.click();
				e.returnValue  = false;
			}
		}

		function SearchBySKU(michaelsSKU) {
		    //NAK - Repurposing this to scroll to sku instead of filtering grid
		    var sku = ""
		    var rowCollection = document.getElementById("gvSKUs").rows;
		    for (var i = 1; i < rowCollection.length; i++) {
		        var cellCollection = rowCollection[i].cells
		        if (cellCollection[2].children.length > 0) {
		            sku = cellCollection[2].children[0].innerHTML;
		        }
		        else {
		            sku = cellCollection[2].innerHTML;
		        }
		        if (michaelsSKU == sku) {
		            var element = document.getElementById("gvSKUs").rows[i]
		            element.style.backgroundColor = "#F6F6C6";
		            cellCollection[2].scrollIntoView();
		            cellCollection[2].focus();
		        }
		        else {
		            var element = document.getElementById("gvSKUs").rows[i]
                    element.style.backgroundColor = "#dedede"
		        }
		    }
		}
		function ClearSKUFilter()
		{
			document.getElementById("txtFindSKU").value = "";
			return SearchBySKU("");
		}
		function ValidateDeleteSKUs() 
		{
		    var deleteChecked = false;

	        var checkBoxes = $('gvSKUs').select('[type="checkbox"]');
	        for (var i = 0; i < checkBoxes.length; i++) {                    
                if (checkBoxes[i].checked) {
                    deleteChecked = true;
	                break;                        	                    
                }
            }
	        
	        if (!deleteChecked) {
	            alert("No items were selected to be removed!");
	        }
            
		    return deleteChecked;
		}
		
		function GetSelectedCheckboxesStr(pCheckboxGroupStr, pAttributeName, pDelimiter)
		{
		    var returnStr = '';
		    
		    var checkBoxes = $('gvSKUs').select(pCheckboxGroupStr);
		    
	        for (var i = 0; i < checkBoxes.length; i++)
	        {
                if (checkBoxes[i].checked) {
                    if(returnStr.length > 0){
                        returnStr += pDelimiter;
                    }
                    returnStr += checkBoxes[i].readAttribute(pAttributeName);
                }                
            }

		    return returnStr;
		}
		
		function SetSelectedCheckboxesByStr(pCheckboxGroupStr, pAttributeName, pDelimiter, pCheckBoxSelectedStr)
		{
		    if(pCheckBoxSelectedStr.length > 0) {
		    
		        var checkBoxes = $('gvSKUs').select(pCheckboxGroupStr);
		        var selectedCheckBoxes = pCheckBoxSelectedStr.split(pDelimiter);
    		    
    		    //Loop Through Checkboxes
	            for(var i = 0; i < checkBoxes.length; i++)
	            {
	                //Loop Through Selected Checkboxes
	                for(var j = 0; j < selectedCheckBoxes.length; j++){
	                
	                    if(checkBoxes[i].readAttribute(pAttributeName) == selectedCheckBoxes[j]){	                    
	                        checkBoxes[i].checked = true;
	                        break;
	                    }
	                    	                    
	                }                    
                }
            }
		}
		
		function UpdateSKUs()
		{
		   var isDirty = $('hdnPageIsDirty');
            
            if (isDirty.value == "1") {

                //Open Window On Next Load
                $('hdnOpenPopup').value = 'UPDATESKUS';
                $('hdnQueryStrValue').value = GetSelectedCheckboxesStr('[group="SKUCheckbox"]', 'sku', '|');

                //Save Current Cache
                SaveCache();

            }
            else {

	            var skusStr = GetSelectedCheckboxesStr('[group="SKUCheckbox"]', 'sku', '|');
	            
	            if(skusStr.length > 0) {	                
		            WriteSKUsTable(skusStr);
		        }
		        else {
		            alert("No items were selected to be updated!");
		        }
		    }

			return false;
		}
		function WriteSKUsTable(pSkusStr)
		{
		    var skus = pSkusStr.split('|');
			var table;
			table = document.getElementById("tblSKUUpdateContent");
			var tableBody;
			tableBody = document.createElement("tbody");
			tableBody.id = "tBodyContent";
			row = new Array(skus.length);
			for (var i = 0; i < skus.length; i++)
			{
				row[i] = document.createElement("tr");
				cell = new Array(4);
				for (var j = 0; j < cell.length; j++)
				{
					cell[j] = document.createElement("td");
					var firstCol = false;
					var chkID;
					switch(j)
					{
						case 0:
							cell[j].style.textAlign = "left";
							cell[j].appendChild(document.createTextNode(skus[i]));
							cell[j].style.fontWeight ="bold";
							firstCol = true;
							break;
						case 1:
							firstCol = false;
							chkID = "UnitCost";
							break;
						case 2:
							firstCol = false;
							chkID = "InnerPack"
							break;
						case 3:
							firstCol = false;
							chkID = "MasterCase";
							break;
					}
					if (!firstCol)
					{
						var chkControl = document.createElement("input");
						chkControl.type = "checkbox";
						chkControl.id = "chk" + chkID + "|" + skus[i];
						chkControl.name = "chk" + chkID + "|" + skus[i];
						cell[j].appendChild(chkControl);
						cell[j].style.textAlign = "center";
					}	
					row[i].appendChild(cell[j]);
				}
			tableBody.appendChild(row[i]);
			}
			table.appendChild(tableBody);
			DisplayOverlay();
		}
		function CancelSkusUpdate()
		{
			var table;
			table = document.getElementById("tblSKUUpdateContent");
			var tableBody;
			tableBody = table.tBodies["tBodyContent"];
			tableBody.parentNode.removeChild(tableBody);
			HideOverlay();
			return false;
		}
		function SaveSkusUpdate()
		{
			var table;
			table = document.getElementById("tblSKUUpdateContent");
			var tableBody;
			tableBody = table.tBodies["tBodyContent"];
			var checked = 0;
			for (var i = 0; i < tableBody.rows.length; i++)
			{
				for (j = 1; j < tableBody.rows[i].cells.length; j++)
				{
					var cell = tableBody.rows[i].cells[j];
					if (cell.children.length > 0)
					{
						var ctrl = cell.children[0];
						if (ctrl.type == "checkbox")
						{
							if (ctrl.checked){
								checked++;
							}
						}
					}
				}
			}
			if (checked > 0)
			{
			    //Save Initiated
		        saveSkusUpdate = 1;
		        
				var counter = 0;
				ShowProcessing();
				for (var i = 0; i < tableBody.rows.length; i++)
				{
					var sku = tableBody.rows[i].cells[0].innerText;
					for (j = 1; j < tableBody.rows[i].cells.length; j++)
					{
						var cell = tableBody.rows[i].cells[j];
						if (cell.children.length > 0)
						{
							var ctrl = cell.children[0];
							if (ctrl.type == "checkbox")
							{
								if (ctrl.checked)
								{
									counter++;
									var refresh;
									(checked == counter) ? refresh = true : refresh = false;
									if (ctrl.name.indexOf("UnitCost") > -1)
									{
										SaveSKUDefaultsUPC(sku, "Unit_Cost", refresh);
									}
									if (ctrl.name.indexOf("InnerPack") > -1)
									{
										SaveSKUDefaultsUPC(sku, "Inner_Pack", refresh);
									}
									if (ctrl.name.indexOf("MasterCase") > -1)
									{
										SaveSKUDefaultsUPC(sku, "Master_Case", refresh);
									}
								}
							}
						}
					}
				}
			}
			else
			{
				alert("Please select fields to update.");
			}
			return false;
		}
		function getQuerystring(key)
		{
			key = key.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
			var regex = new RegExp("[\\?&]"+key+"=([^&#]*)");
			var qs = regex.exec(window.location.href);
			if(qs == null)
			{
				return "";
			}
			else
			{
				return qs[1];
			}
		}
		function SaveSKUDefaultsUPC(SKU, field, refresh)
		{
		    //Increment Counter
		    ajaxCounter++;
		    
			var url = "POMaintenanceDetailsUpdSKUsGrid.aspx";
			new Ajax.Request(url, {
			    method: 'post',
			    parameters: { Action: 'SaveSKUDefault', POID: getQuerystring("POID"), SKU: SKU.toString(), Field: field },
			    onFailure: function() {
			        alert("Error setting " + field.replace("_", " ") + " default for SKU:" + SKU.toString() + ".");
			    },
			    onComplete: function(response) {
			    
			        //Decrement Counter
			        ajaxCounter--;
			            
			        if (response.responseText == "0") {
			            alert("Error setting " + field.replace("_", " ") + " default for SKU:" + SKU.toString() + ".");
			        }
			        else {
			            
			            //Refresh Parent Screen
			            if(ajaxCounter == 0 && saveSkusUpdate == 1)
			            {
			                saveSkusUpdate = 0;
			                
			                RefreshDisplayOfCache();
			            }
			        }
			    }
			});
		}
		
		function ShowSaving() {
            togglePopup('SKUUpdateSaving', 'block', 'visible');

            var divContent = document.getElementById("SKUUpdateContent");
            var divProcessing = document.getElementById("SKUUpdateSaving");

            divProcessing.style.position = "absolute";

            if (divContent.offsetHeight > 0) {
                divProcessing.style.height = divContent.offsetHeight - 20;
            }
            else {
                divProcessing.style.height = 0;
            }
            divProcessing.style.width = 400;
            divProcessing.style.top = divContent.style.top;
            divProcessing.style.left = divContent.style.left;
            divProcessing.setStyle(
			{
			    opacity: 0.8
			});

            xScroll = divContent.clientWidth;
            yScroll = divContent.clientHeight;

            var img = document.getElementById("imgWaiting");
            img.style.position = "absolute";

            img.style.top = (yScroll - img.height) / 2;
            img.style.left = (xScroll - img.width) / 2;
            togglePopup('SKUUpdateContent', 'none', 'hidden');

        }

		function ShowProcessing()
		{
			togglePopup('SKUUpdateSaving', 'block', 'visible');

			var divContent = document.getElementById("SKUUpdateContent");
			var divProcessing = document.getElementById("SKUUpdateSaving");

			divProcessing.style.position = "absolute";
			divProcessing.style.height = divContent.offsetHeight - 20;
			divProcessing.style.width = 400;
			divProcessing.style.top = divContent.style.top;
			divProcessing.style.left = divContent.style.left;			
			divProcessing.setStyle(
			{
				opacity: 0.8
			});

			xScroll = divContent.clientWidth;
			yScroll = divContent.clientHeight;
			
			
			
			var img = document.getElementById("imgWaiting");
			img.style.position = "absolute";
			
			img.style.top = (yScroll - img.height) / 2;
			img.style.left = (xScroll - img.width) / 2;
			
		}
		function DisplayOverlay() 
		{
			toggleLightBox('shadow', 'block', 'visible');
			togglePopup('lightbox', 'block', 'visible');
			
			var div	= document.getElementById("SKUUpdateContent");
			var divHeight = div.offsetHeight;
			var divWidth = div.offsetWidth;

			xScroll = document.body.offsetWidth;
			yScroll = document.body.offsetHeight;

			div.style.position = "absolute";
			div.style.top = (yScroll - divHeight) / 1.5
			div.style.left = (xScroll - divWidth) / 2
			
			return false;
		}
		function HideOverlay() 
		{
			toggleLightBox('shadow', 'none', 'hidden');
			togglePopup('SKUUpdateSaving', 'none', 'hidden');
			togglePopup('lightbox', 'none', 'hidden');
			return false;
		}
		function SaveOnEnter(e)
		{
			if (!e)
			{
				e = window.event;
			}
			if (e.keyCode == 13) 
			{
				return false;
			}
		}
			
		function RevisionChanged(poID, ctrl)
		{
			document.location.href = "POMaintDetails.aspx?POID=" + poID + "&Revision=" + ctrl.options[ctrl.selectedIndex].value
		}

		function toggleLightBox(divtotoggle, display, visibility) 
		{
			var xScroll, yScroll;
			if (window.innerHeight && window.scrollMaxY) 
			{
				xScroll = document.body.scrollWidth;
				yScroll = window.innerHeight + window.scrollMaxY;
			} 
			else if (document.body.scrollHeight > document.body.offsetHeight)
			{ 
				xScroll = document.body.scrollWidth;
				yScroll = document.body.scrollHeight;
			} 
			else 
			{ 
				xScroll = document.body.offsetWidth;
				yScroll = document.body.offsetHeight;
			}

			var windowWidth, windowHeight;
			if (self.innerHeight) 
			{	
				windowWidth = self.innerWidth;
				windowHeight = self.innerHeight;
			} 
			else if (document.documentElement && document.documentElement.clientHeight) 
			{ 
				windowWidth = document.documentElement.clientWidth;
				windowHeight = document.documentElement.clientHeight;
			} 
			else if (document.body) 
			{ 
				windowWidth = document.body.clientWidth;
				windowHeight = document.body.clientHeight;
			}	
	
			var adjustedWidth, adjustedHeight;
			if(xScroll < windowWidth)
			{	
				adjustedWidth = windowWidth;
			} 
			else 
			{
				adjustedWidth = xScroll;
			}
			if(yScroll < windowHeight)
			{
				adjustedHeight = windowHeight;
			} 
			else 
			{
				adjustedHeight = yScroll;
			}

			var overlay = $(divtotoggle);

			overlay.setStyle(
			{
				opacity: 0.8,
				backgroundImage: 'url(images/black_50.png)',
				backgroundRepeat: 'repeat',
				height: adjustedHeight+'px',
				display: display,
				visibility: visibility
			});
		}

		function togglePopup(pDivToToggle, pDisplay, pVisibility)
		{
			var popup = $(pDivToToggle);

			popup.setStyle(
			{
				display: pDisplay,
				visibility: pVisibility
			});
		}	

        function confirmSave() 
        {
            var isDirty = $('hdnPageIsDirty');
            
            //IF the page has been modified, remind the user they have not saved
            if (isDirty.value == "1") {
                if (confirm('Any changes you have made will be saved.  Do you want to continue?'))
                    return true;
            }
            else {
                return true;
            }
            
            return false;
        }
        
        function OpenAddSKU()
        {
            var isDirty = $('hdnPageIsDirty');
            
            if (isDirty.value == "1") {
               
                //Open Window On Next Load
                $('hdnOpenPopup').value = 'ADDSKU';
                
                //Save Current Cache
                SaveCache();

            }
            else {
                OpenNewPopupWindow('POMaintenanceDetailsAddSKU.aspx?POID=<%=Request("POID")%>', 'AddSKU', 1000, 750);
            }
        }
        
        function ShowPOMaintenanceDetailsSKUStore(poID, SKU, revision)
		{
            var isDirty = $('hdnPageIsDirty');
            
            if (isDirty.value == "1") {

                //Open Window On Next Load
                $('hdnOpenPopup').value = 'ADDSTORE';
                $('hdnQueryStrValue').value = '&SKU=' + SKU + '&Revision=' + revision;

                //Save Current Cache
                SaveCache();

            }
            else {
		        OpenNewPopupWindow('POMaintenanceSKUStore.aspx?POID=' + poID + '&SKU=' + SKU + '&Revision=' + revision, 'SKUStore', 1000, 750);
		    }
		    
		    $('hdnPageIsDirty').value = "1";
		}
		
		function ValidateSKUs()
		{
            if (PromptToSave()) {
                if (confirm('Any changes you have made will be saved.  Do you want to continue?'))
                {
                    return true;
                }
            }
            else {
		        return true;
		    }
		    
		    return false;
		}
		
		function SortSKUData(pLinkID)
		{
//		    var isDirty = $('hdnPageIsDirty');
//            
//            if (isDirty.value == "1") {
//                if (confirm('Any changes you have made will be saved.  Do you want to continue?'))
//                {
//                    return true;                    
//                }
//            }
//            else {
//		        return true;
//		    }
//
		    //		    return false;
		    return true;
		}
		
        function PageSetup()
		{		    		    
		    preloadItemImages();
		    
		    //Reset IsDirty Flag To Zero
		    $('hdnPageIsDirty').value = '0';
		    
		    //Honor Auto-Popup Window
		    var popupWindow = $('hdnOpenPopup').value;
		    
		    switch(popupWindow)
		    {
		        case "ADDSKU":
		            OpenNewPopupWindow('POMaintenanceDetailsAddSKU.aspx?POID=<%=Request("POID")%>', 'AddSKU', 1000, 750);
		            break;
                
                case "ADDSKUFOCUS":
		            var tempWin = window.open('', 'AddSKU');
		            tempWin.focus();
		            break;

		        case "ADDSTORE":
		            OpenNewPopupWindow('POMaintenanceSKUStore.aspx?POID=<%=Request("POID")%>' + $('hdnQueryStrValue').value, 'SKUStore', 1000, 750);
		            break;
		        
		        case "ADDSTOREFOCUS":
		            var tempWin = window.open('', 'SKUStore');
		            tempWin.focus();
		            break;

                case "UPDATESKUS":
		            SetSelectedCheckboxesByStr('[group="SKUCheckbox"]', 'sku', '|', $('hdnQueryStrValue').value);
		            UpdateSKUs();
		            break;

		        case "VALIDATESKUS":
		            $('btnValidateSKUs').click();
		            break;
		            
		        case "CANCELCHECKED":
		            SetSelectedCheckboxesByStr('[group="SKUCheckbox"]', 'sku', '|', $('hdnQueryStrValue').value);		            
		            $('btnCancelChecked').click();
		            break;
		        
		        case "RESTORECHECKED":
		            SetSelectedCheckboxesByStr('[group="SKUCheckbox"]', 'sku', '|', $('hdnQueryStrValue').value);		            
		            $('btnRestoreChecked').click();
		            break;

		        case "TOTALSYNCCHECKED":
		            SetSelectedCheckboxesByStr('[group="SKUCheckbox"]', 'sku', '|', $('hdnQueryStrValue').value);
		            $('btnTotalSyncCheckedSKUs').click();
		            break;
		    }
		    
		    $('hdnOpenPopup').value = '';
		    $('hdnQueryStrValue').value = '';
		}

        function ClearDates() {
		    var ctrlCollection = document.getElementById("tblAllocationsTotals").cells;
		    for (var i = 0; i < ctrlCollection.length; i++) {
		        if (ctrlCollection[i].children.length > 1) {
		            var ctrl = ctrlCollection[i].children[0];
		            if (ctrl.type == "text") {
		                ctrl.value = ""
		                
		            }
		        }
		    }
		}

		function CopyDates(rowIndex) {
		    var row = document.getElementById("tblAllocationsTotals").rows[rowIndex]
		    var copyValue = row.cells[1].children[0].value
		    if (copyValue != "") {
		        for (var i = 2; i < row.cells.length; i++) {
		            if (row.cells[i].children.length > 1) {
		                var ctrl = row.cells[i].children[0]
		                if (ctrl.type == "text") {
		                    ctrl.value = copyValue
		                }
		            }
		        }
		    }
		    return false;
		}

		function TabEnter(e) {
		    if (window.event && window.event.keyCode == 13) {
		        window.event.keyCode = 9;
		    }
		}
		
		function mSaveBeginRequest(sender, args) {
		    window.status = "Please wait...";
		    document.body.style.cursor = "wait";
		    // if a control is defined that caused a postback (not during initial load) or if this is called by a non .net ajax process
		    // set it to disabled
		    DisplayOverlay();
		    ShowSaving();
		    if ((args) && (args._postBackElement)) {
		        var e = $(args._postBackElement.id);
		        if (e) e.disabled = true;
		    }
		}

		function mSavePageLoaded(sender, args) {
		    window.status = "Done";
		    document.body.style.cursor = "auto";
		    HideOverlay();
		    // Turn control back on if one was passed in with the args parm
		    if ((sender) && (sender._postBackSettings) && (sender._postBackSettings.sourceElement)) {
		        var e = $(sender._postBackSettings.sourceElement.id);
		        if (e) e.disabled = false;
		    }
		}

		function SaveCache() {
		    DisplayDetailWait();
		
		    var poID = getQuerystring("POID");
		    var revision = getQuerystring("Revision");
		    frmPOMaintDetails.action = "POMaintDetails.aspx?POID=" + poID + "&Revision=" + revision + "&RELOAD=N";
		    $('hdnBtnSaveCache').click();
		}
		
		function RefreshDisplayOfCache()
		{
		    var poID = getQuerystring("POID");
		    var revision = getQuerystring("Revision");
		    document.location = "POMaintDetails.aspx?POID=" + poID + "&Revision=" + revision + "&RELOAD=N";
		}
		
		function CacheIsDirty()
		{
		    var reload = getQuerystring("RELOAD");
		    if(reload == "N"){
		        return true;
		    }
		    return false;
		}
		
		function PromptToSave()
		{
		    if( $('hdnPageIsDirty').value == '1' || CacheIsDirty()){		    
		        return true;
		    }
		    else {
		        return false;
		    }
		}

		function CheckUncheckAll(headerChkBox) {
		    var isChecked = $(headerChkBox).checked;

		    var rowCollection = document.getElementById("gvSKUs").rows;
		    for (var i = 1; i < rowCollection.length; i++) {
		        var cellCollection = rowCollection[i].cells
		        if (cellCollection[0].children.length > 0) {
		            cellCollection[0].children[0].checked = isChecked;
		        }
		    } 

		    //for (var i = 0; i < checkBoxes.length; i++) {
		    //   checkBoxes[i].checked = isChecked;
		    //}
		}
		
		function CancelChecked(){

		    var isDirty = $('hdnPageIsDirty');
            
            if (isDirty.value == "1") {

                //Open Window On Next Load
                $('hdnOpenPopup').value = 'CANCELCHECKED';
                $('hdnQueryStrValue').value = GetSelectedCheckboxesStr('[group="SKUCheckbox"]', 'sku', '|');

                //Save Current Cache
                SaveCache();

                return false;
            }

            DisplayDetailWait();
            return true;
		}

		function RestoreChecked() {

		    var isDirty = $('hdnPageIsDirty');
            
            if (isDirty.value == "1") {

                //Open Window On Next Load
                $('hdnOpenPopup').value = 'RESTORECHECKED';
                $('hdnQueryStrValue').value = GetSelectedCheckboxesStr('[group="SKUCheckbox"]', 'sku', '|');

                //Save Current Cache
                SaveCache();

                return false;
            }
            DisplayDetailWait();
            return true;
        }

        function TotalSyncChecked() {

            var isDirty = $('hdnPageIsDirty');

            if (isDirty.value == "1") {

                //Open Window On Next Load
                $('hdnOpenPopup').value = 'TOTALSYNCCHECKED';
                $('hdnQueryStrValue').value = GetSelectedCheckboxesStr('[group="SKUCheckbox"]', 'sku', '|');

                //Save Current Cache
                SaveCache();

                return false;
            }
            
            DisplayDetailWait();
            return true;
        }

        function DisplayDetailWait() {
            DisplayOverlay();
            ShowSaving();

            setTimeout('document.images["imgWaiting"].src = "images/wait30trans.gif"');
        }

        function ValidateAndWait() {
            var isValid = ValidateDateControls();
            if (isValid) {
                DisplayDetailWait();
            }

            return isValid;
        }
	//-->
    </script>
</head>

<body style="background-color:#dedede">
<form id="frmPOMaintDetails" runat="server" defaultbutton="btnUpdate">
	<div id="sitediv">
		<div id="bodydiv">
			<div id="header">
				<uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			</div>
			<div id="content">
			    <asp:ScriptManager ID="ScriptManager1" runat="server" AsyncPostBackTimeOut="600" />
				<div id="submissiondetail">
					<div style="padding-top:10px; padding-bottom: 10px;">
					    <table cellpadding="0" cellspacing="0" width="100%" id="AlignmentTable" border="0">
					    <tr>
                            <td style="padding-left: 10px;">
						        <table border="0" cellpadding="0" cellspacing="0" width="100%">
						            <tr>
						                <td colspan="3" style="width:100%">
						                    <asp:Label ID="lblErrorCount" runat="server" CssClass="redText" Text="Errors: 0" Visible="false"  ></asp:Label><span style="padding-left:40px;">&nbsp;&nbsp;</span><asp:Label ID="lblWarningCount" runat="server" CssClass="redText" Text="Warnings: 0" Visible="false" ></asp:Label>
						                    <novalibra:NLValidationSummary ID="validationDisplay" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" runat="server" Width="100%" />
						                </td>
						                <td>&nbsp;</td>
						            </tr>
						            <tr>
						                <td valign="bottom" style="width: 209px;">
									        <table cellpadding="0" cellspacing="0" border="0" width="209" style="height: 30px;">
										        <tr>
				                                    <td id="POHeaderTab" runat="server" width="110" height="27"  align="right" valign="bottom">
				                                        <asp:LinkButton id="POHeaderLink" runat="server" CssClass="tabPOText" Text="PO Header" Width="109" Height="20" OnClientClick="javascript:return ValidateAndWait();">
				                                            <span>PO Header</span>&nbsp;<img runat="server" id="POHeaderImage" src="images/spacer.gif" alt="" style="padding-left:8px;" width="11" height="11" border="0" />
				                                        </asp:LinkButton>
											        </td>
				                                    <td id="PODetailTab" runat="server" valign="bottom" align="right" width="100" height="27">
			                                            <asp:LinkButton ID="PODetailLink" runat="server" CssClass="tabPOTextActive" Text="PO Detail" Width="109" Height="20" Enabled="false">
			                                                <span>PO Detail</span>&nbsp;<img runat="server" id="PODetailImage" src="images/spacer.gif" alt="" style="padding-left:8px;" width="11" height="11" border="0" />    
			                                            </asp:LinkButton>
				                                    </td>
				                                </tr>
				                            </table>
						                </td>
						                <td style="width: 30px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="30" /></td>
                                        <td id="validationDisplayTD" style="width: 100%;">
                                            <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="btnUpdate" />
                                                    <asp:AsyncPostBackTrigger ControlID="btnUpdateClose" />
                                                    <asp:AsyncPostBackTrigger ControlID="btnEditRevision" />
                                                    <asp:AsyncPostBackTrigger ControlID="btnValidateSKUs" />
                                                </Triggers>
                                                <ContentTemplate>
                                                    <asp:Label ID="lblErrorMsg" runat="server" CssClass="redText" Width="100%" />
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
						                <td align="right" valign="bottom">
						                    <span style="color:Red; font-size:10pt; white-space: nowrap;">* * * Revision:&nbsp;<asp:DropDownList ID="ddlRevisions" runat="server" /> * * *</span>
						                </td>						        
						            </tr>
                                </table>
						            <table cellpadding="0" cellspacing="0" border="0" width="100%">
							        <tr>
								        <th valign="top" >
								            SUMMARY&nbsp;&nbsp;&nbsp;
								            <a id="lnkSumExpCol" href="#" onclick="SumExpCol();">Hide</a>
								        </th>
                                        <th valign="top">
								            <table cellpadding="0" cellspacing="0" border="0" class="whiteText" width="100%">
										        <tr>
										            <td class="formField whiteText" style="padding-left: 15px;">
												        Purchase Order:&nbsp;
												        <asp:Label runat="server" ID="lblPurchaseOrderNumber"/>
											        </td>
											        <td class="formField whiteText" style="padding-left: 15px;">
												        Log ID:&nbsp;
												        <asp:Label runat="server" ID="lblBatchOrderNumber"/>
											        </td>
											        <td class="whiteText" style="padding-left: 15px;">
												        Workflow Department:&nbsp;
												        <asp:Label runat="server" ID="lblWorkflowDepartment"></asp:Label>
											        </td>
											        <td class="formField whiteText" style="padding-left: 15px;">
												        PO Department:&nbsp;
												        <asp:Label runat="server" ID="PODept"/>
												        &nbsp;&nbsp;
												        Class: &nbsp;
												        <asp:Label runat="server" ID="POClass"/>
												        &nbsp;&nbsp;
												        Subclass: &nbsp;
												        <asp:Label runat="server" ID="POSubclass"/>
											        </td>
                                                    <td align="right" valign="top" style="padding-left: 15px;">
							                           <asp:Button ID="btnEditRevision" runat="server" Text="Edit Revision" CssClass="formButton" Visible="false" />
							                        </td>
							                        <td>
							                            <div style="float:right"><asp:Button runat="server" ID="btnValidateSKUs" Text="Submit for Validation" OnClientClick="return ValidateSKUs();" CssClass="formButton" /></div>
							                        </td>
										        </tr>
								            </table>
								        </th>
    						        </tr>
							        <tr>
								        <td colspan="2">
								            <div id="divSummary">
								            <table cellpadding="5" cellspacing="0" border="0" >
										        <tr>
											        <td valign="top" >
											            <table id="tblAllocationsTotals" name="tblAllocationsTotals" runat="server" cellpadding="2" cellspacing="0" border="0" ></table>
                                                    </td>
										        </tr>
									        </table>
									        </div>
								        </td>
							        </tr>
							        <tr>
							            <td colspan="2" style="height: 10px;">
									        <img src="images/spacer.gif" border="0" alt="" height="5" width="1" />
								        </td>
							        </tr>
							        <tr>
								        <th valign="top" colspan="2">
								            SKU LIST
								        </th>
							        </tr>
							        <tr>
								        <td colspan="2">
								            <table cellpadding="5" cellspacing="0" border="0" width="100%">
								                <tr>
				                                    <td style="height: 22px; white-space: nowrap;" valign="middle" align="left" nowrap="nowrap">                                                
												        <%
												            If _isAddSKULocked Then
													        %>
														        &nbsp;
													        <%
													        Else
													        %>
														        <div style="white-space: nowrap; float: left;"><a href="#" onclick="OpenAddSKU(); return false;">Add SKUs</a>&nbsp;</div>														
													        <%
													        End If
												        %>
                                                    </td>
								                </tr>
										        <tr>
											        <td>
											                <asp:GridView ID="gvSKUs" runat="server" BackColor="#dedede" BorderColor="#cecece" BorderWidth="0px" Width="100%"
												                      CellPadding="2" ForeColor="#D3D3A3" GridLines="None" AllowSorting="true" AllowPaging="False" AutoGenerateColumns="False" 
												                      Font-Names="Arial" Font-Size="Larger" HorizontalAlign="Left" PagerStyle-Height="17px" EnableViewState="true" onKeyDown="javascript:TabEnter(event);" >
												                <HeaderStyle Height="20px" ForeColor="Navy" BackColor="#cccccc"/>
												                <Columns>
												                     <asp:TemplateField >
                                                                        <ItemTemplate><novalibra:NLCheckBox ID="IsChecked" runat="server" Visible='<%# Not _isSkuLocked %>' /></ItemTemplate>
                                                                        <ItemStyle Width="1%" />
                                                                        <HeaderTemplate>
                                                                            <asp:CheckBox ID="CheckAll" runat="server" Visible='<%# Not _isSkuLocked %>' />
                                                                        </HeaderTemplate>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField SortExpression="Is_Valid">
                                                                        <ItemTemplate><img src="<%# GetCheckBoxUrl(Eval("Is_Valid")) %>" alt="" /></ItemTemplate>
                                                                        <ItemStyle Width="1%" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField Visible="false">
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblSKU" runat="server" Text='<%# Eval("Michaels SKU")%>' />
                                                                        </ItemTemplate>
                                                                     </asp:TemplateField>
                                                                      <asp:TemplateField HeaderText="VPN" SortExpression="VPN">
                                                                        <ItemTemplate><asp:Label ID="lblVPN" runat="server" Text='<%# Eval("VPN") %>'/></ItemTemplate>
                                                                        <ItemStyle Wrap="true" Width="6%" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="UPC" SortExpression="UPC">
                                                                        <ItemTemplate><novalibra:NLDropDownList ID="ddlUPC" runat="server" AppendDataBoundItems="true" SelectedValue='<%# Bind("UPC") %>' DataTextField="UPCText" DataValueField="UPCVal" DataSource='<%# GetSKUUPCs(Eval("Michaels SKU"), Eval("UPC")) %>' RenderReadOnly='<%# _isUPCLocked %>'  onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="15%" />
                                                                     </asp:TemplateField>
                                                                      <asp:TemplateField Visible="false">
                                                                        <ItemTemplate>
                                                                            <asp:Label ID="lblUPC" runat="server" Text='<%# Eval("UPC")%>' />
                                                                        </ItemTemplate>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Desc" SortExpression="Item_Desc">
                                                                        <ItemTemplate><asp:Label ID="lblDesc" runat="server" Text='<%# Eval("Item_Desc") %>'/></ItemTemplate>
                                                                        <ItemStyle Width="20%" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Total Order <br/>Qty" HeaderStyle-CssClass="gvnumbers" SortExpression="Ordered_Qty">
                                                                        <ItemTemplate>
                                                                            <novalibra:NLTextBox ID="txtOrderQty" runat="server" Text='<%# Eval("Ordered_Qty") %>'
                                                                                Width="50px" RenderReadOnly='<%# _isOrderedQtyLocked%>' onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Calculated <br/>Total" HeaderStyle-CssClass="gvnumbers" SortExpression="Calculated_Order_Total_Qty">
                                                                        <ItemTemplate>
                                                                             <novalibra:NLTextBox ID="txtCalculatedQty" runat="server" Text='<%# Eval("Calculated_Order_Total_Qty") %>'
                                                                                Width="50px" RenderReadOnly="True" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Cancelled<br/>Qty" HeaderStyle-CssClass="gvnumbers"  SortExpression="Cancelled_Qty">
                                                                        <ItemTemplate><novalibra:NLTextBox ID="txtCancelledQty" runat="server" Text='<%# Eval("Cancelled_Qty") %>' Width="35px" RenderReadOnly='<%# _isCancelledQtyLocked %>' onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Cancel<br/>Code" HeaderStyle-CssClass="gvnumbers"  SortExpression="Cancel_Code">
                                                                        <ItemTemplate>
                                                                            <novalibra:NLDropDownList ID="ddlCancelCode" runat="server" Text='<%# Eval("Cancel_Code") %>' Width="35px" RenderReadOnly='<%# _isCancelCodeLocked %>' MaxLength="1" onChange="javascript:setPageAsDirty()">
                                                                                <asp:ListItem Text="-" Value="-" />
                                                                                <asp:ListItem Text="A" Value="A" />
                                                                                <asp:ListItem Text="B" Value="B" />
                                                                                <asp:ListItem Text="V" Value="V" />
                                                                            </novalibra:NLDropDownList></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Received<br/>Qty" HeaderStyle-CssClass="gvnumbers"  SortExpression="Received_Qty">
                                                                        <ItemTemplate><novalibra:NLTextBox ID="txtReceivedQty" runat="server" Text='<%# Eval("Received_Qty") %>' Width="35px" RenderReadOnly="true"/></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Outstanding<br/>Qty" HeaderStyle-CssClass="gvnumbers" SortExpression="Outstanding_Qty" >
                                                                        <ItemTemplate><novalibra:NLTextBox ID="txtOutstandingQty" runat="server" Text='<%# Eval("Outstanding_Qty") %>' Width="35px" RenderReadOnly="true" onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="Unit Cost" HeaderStyle-CssClass="gvnumbers" SortExpression="Unit_Cost">
                                                                        <ItemTemplate><novalibra:NLTextBox ID="txtUnitCost" runat="server" Text='<%# Eval("Unit_Cost") %>' Width="50px" RenderReadOnly='<%# _isUnitCostLocked%>' onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="7%" HorizontalAlign="Right"/>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="RMS<BR/>Unit Cost" HeaderStyle-CssClass="gvnumbers" SortExpression="RMS_Cost">
                                                                        <ItemTemplate><asp:Label ID="lblRMSUnitCost" runat="server" Text='<%# Eval("RMS_Cost")%>' Width="45px" CssClass="gvnumbers" onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="7%" HorizontalAlign="Right"/>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="IP" HeaderStyle-CssClass="gvnumbers" SortExpression="Inner_Pack">
                                                                        <ItemTemplate><novalibra:NLTextBox ID="txtIP" runat="server" Text='<%# Eval("Inner_Pack")%>' Width="35px" RenderReadOnly='<%# _isIPLocked%>' onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right"/>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="RMS IP" HeaderStyle-CssClass="gvnumbers" SortExpression="RMS_Inner_Pack">
                                                                        <ItemTemplate><asp:Label ID="lblRMSIP" runat="server" Text='<%# Eval("RMS_Inner_Pack")%>' Width="35px" CssClass="gvnumbers" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right"/>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="MC" HeaderStyle-CssClass="gvnumbers" SortExpression="Master_Pack">
                                                                        <ItemTemplate><novalibra:NLTextBox ID="txtMC" runat="server" Text='<%# Eval("Master_Pack") %>' Width="35px" RenderReadOnly='<%# _isMasterPackLocked%>' onChange="javascript:setPageAsDirty()" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right"/>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField HeaderText="RMS MC" HeaderStyle-CssClass="gvnumbers" SortExpression="RMS_Master_Case">
                                                                        <ItemTemplate><asp:Label ID="lblRMSMC" runat="server" Text='<%# Eval("RMS_Master_Case")%>' Width="35px" CssClass="gvnumbers" /></ItemTemplate>
                                                                        <ItemStyle Width="5%" HorizontalAlign="Right" />
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField Visible="false">
                                                                        <ItemTemplate><asp:Label ID="lblID" runat="server" Text='<%# Eval("ID") %>' Visible="false" /></ItemTemplate>
                                                                     </asp:TemplateField>
                                                                     <asp:TemplateField Visible="false">
                                                                        <ItemTemplate><asp:Label ID="lblAddedByRMS" runat="server" Text='<%# Eval("Added_By_RMS") %>' Visible="false" /></ItemTemplate>
                                                                     </asp:TemplateField>
												                </Columns>												                
												            </asp:GridView>
											        </td>
										        </tr>
										        <tr>
											        <td valign="top">
												        <table runat="server" id="tblTmpFooter" cellpadding="2" cellspacing="0" border="0" width="100%" style="border:1px solid silver">
												        <tr>
												            <td class="formLabel subHeading" >
												                <table border="0" cellpadding="5" cellspacing="0" width="100%" runat="server" id="tblSKUsFooter">
											                    <tr>
        											               
											                        <td style="text-align:left"><asp:Button ID="btnUpdateCheckedSKUs" runat="server" Text="Update Checked" OnClientClick="javascript:return UpdateSKUs();" CssClass="formButton" /> </td>
											                        <td style="text-align:left"><asp:Button ID="btnCancelChecked" runat="server" Text="Cancel Checked" OnClientClick="javascript:return CancelChecked();" CssClass="formButton" /> </td>
											                        <td style="text-align:left"><asp:Button ID="btnRestoreChecked" runat="server" Text="Restore Checked" OnClientClick="javascript:return RestoreChecked();" CssClass="formButton" /> </td>
											                        <td style="text-align:left"><asp:Button ID="btnTotalSyncCheckedSKUs" runat="server" Text="Sync Checked Totals" OnClientClick="javascript:return TotalSyncChecked();" CssClass="formButton" /> </td>
											                        <td style="width: 100%"></td>
											                    </tr>
												                </table>
												            </td>
												        </tr>
												        </table>
										            </td>
										        </tr>
									        </table>
								        </td>
							        </tr>
							        <tr>
                                        <td colspan="2" style="height: 10px;">
                                            <img src="images/spacer.gif" border="0" alt="" height="5" width="1" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <th colspan="2" class="detailFooter">
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                <tr>
                                                    <td width="50%" style="width: 50%;" align="left" valign="top">
                                                        <input type="button" id="btnCancel" onclick="cancelForm(); return false;" value="Cancel" class="formButton" />&nbsp;
                                                    </td>
                                                    <td width="50%" style="width: 50%;" align="right" valign="top">
												        &nbsp;<asp:Button runat="server" ID="btnUpdate" Text="Save" CssClass="formButton" OnClientClick="javascript:return ValidateDateControls();" />
                                                        &nbsp;&nbsp;<asp:Button runat="server" ID="btnUpdateClose" Text="Save &amp; Close" CssClass="formButton" OnClientClick="javascript:return ValidateDateControls();" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </th>
                                    </tr>
						        </table>
						    </td>
					    </tr>
					    </table>
					</div>
				</div>
				<div id="shadow"></div>
				<div id="lightbox">
					<div style="text-align: center; width: 400px;" id="SKUUpdateContent">
						<table id="tblSKUUpdateContent" width="100%">
							<thead>
								<tr>
									<th colspan="4">
										UPDATE WITH DEFAULT VALUES
									</th>
								</tr>
								<tr>
									<th style="text-align: left">SKU</th>
									<th style="text-align: center">Unit Cost</th>
									<th style="text-align: center">Inner Pack</th>
									<th style="text-align: center">Master Case</th>
								</tr>
							</thead>
						</table>
						<div style="width: 100%; height: 30px" class="detailFooter">
							<asp:Button runat="server" id="btnCancelSKUsUpdate" OnClientClick="javascrpipt:return CancelSkusUpdate();" class="formButton" Text="Cancel" style="margin-top: 7px"></asp:Button>
							<asp:Button runat="server" id="btnSaveSKUsUpdate" OnClientClick="javascrpipt:return SaveSkusUpdate();" class="formButton" Text="Save" style="margin-top: 7px"></asp:Button>
							
						</div>
					</div>
					<div id="SKUUpdateSaving">
						<img id="imgWaiting" src="images/wait30trans.gif" alt="Saving..." />
					</div>
				</div>
			</div>
		</div>		
	</div>
	<asp:HiddenField runat="server" ID="hdnPageIsDirty" Value="0" /> 
	<asp:HiddenField runat="server" ID="hdnOpenPopup" Value="" />
	<asp:HiddenField runat="server" ID="hdnQueryStrValue" Value="" />
    <asp:Button runat="server" ID="hdnBtnSaveCache" Height="1" Width="1" />
        
    <asp:UpdatePanel ID="upTimer" runat="server">
        <ContentTemplate>
            <asp:Timer runat="server" ID="ValidationTimer" Interval="10000" OnTick="ValidationTimer_Tick" Enabled="false" />
        </ContentTemplate>
    </asp:UpdatePanel>
</form>
<script language="javascript" type="text/javascript">
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(mSaveBeginRequest);
    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(mSavePageLoaded);
    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(PageSetup);
</script>
</body>
</html>


