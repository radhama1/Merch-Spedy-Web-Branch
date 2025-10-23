		var ns4 = (document.layers)? true:false;
		var ns6 = (document.getElementById)? true:false;
		var ie4 = (document.all)? true:false;
		var ie5 = false;

		var useLiteMenu = true;

		var o3_width = 150;
		var o3_x = 150;
		var o3_offsetx = -15;
		var o3_y = 0;
		var o3_offsety = 0;
		var o3_aboveheight = 90;
		var o3_hpos = "";
		var o3_vpos = "";

		var selectedItemID = -1;
		var hoveredItemID = -1;

		if (ie4) {
			if ((navigator.userAgent.indexOf('MSIE 5') > 0) || (navigator.userAgent.indexOf('MSIE 6') > 0)) {
				ie5 = true;
			}
			if (ns6) {
				ns6 = false;
			}
		}

		var clickRowSrc = -1;

		function displayMenu()
		{
			configureOptions(selectedItemID);
			if (clickRowSrc >= 0)
			{
				if (clickRowSrc > 0)
				{
					useLiteMenu = false;
					o3_aboveheight = 90;
				}
				else if (clickRowSrc == 0)
				{
					useLiteMenu = true;
					o3_aboveheight = 90;
				}

				if (hoveredItemID == selectedItemID)
				{
					allowMove = -1;
					placeLayer();

					if (useLiteMenu)
					{
					    contextMenuLite.style.display = "";
					    o3_aboveheight = contextMenuLite.clientHeight;
					    try {
					        contextMenu.setCapture(err);
					    }
					    catch (err) {
					    }
					}
					else
					{
					    contextMenu.style.display = "";
					    o3_aboveheight = contextMenu.clientHeight;
					    try {
					        contextMenu.setCapture(err);
					    }
					    catch (err) {
					    }
					}
					setClickTimer(2000);
				}
				clickRowSrc = -1;				
			}
			else
			{
				if (hoveredItemID >= 0)
				{
					clickRowSrc = hoveredItemID;
					displayMenu();
				}
			}
		}
		
		function hideMenu()
		{
		    if (useLiteMenu)
		    {
		        try {
		            contextMenuLite.releaseCapture();
		        }
		        catch (err) {
		        }
		        contextMenuLite.style.display = "none";
		    }
		    else
		    {
		        try {
		            contextMenu.releaseCapture();
		        }
		        catch (err) {
		        }
		        contextMenu.style.display = "none";
		    }

		    clickRowSrc = -1;
		    allowMove = 0;
		    useLiteMenu = true;
		}
		
		var clickTimerID = 0;
		function switchMenu()
		{
			el = event.srcElement;
			if (el.className == "menuItem")
			{
				el.className = "highlightItem";
			}
			else if (el.className == "highlightItem")
			{
				el.className="menuItem";
			}
			else
			{
				setClickTimer(2000);
			}
		}	

		function setClickTimer(intDelay)
		{
			if (clickTimerID > 0) clearTimeout(clickTimerID);
			clickTimerID = setTimeout("hideMenu()", intDelay);
		}

		function SelectRow(rowID)
		{
			if (rowID >= 0)
			{
				selectedItemID = rowID;
				document.frmMenu.selectedItemID.value = selectedItemID;
			}
			else
			{
				selectedItemID = -1;
				document.frmMenu.selectedItemID.value = -1;
			}
		}
		
		function HoverRow(rowID)
		{
			if (rowID >= 0)
			{
				hoveredItemID = rowID;
				document.frmMenu.hoveredItemID.value = hoveredItemID;
			}
			else
			{
				hoveredItemID = -1;
				document.frmMenu.hoveredItemID.value = -1;
			}
		}

		var menuObj = "";
		var menuObjLite = "";
		var allowMove = 0;
		
		function initPlaceLayers()
		{
			if ( (ns4) || (ie4) || (ns6) )
			{
				if (ns4) menuObj = document.contextMenu; 
				if (ns4) menuObjLite = document.contextMenuLite; 

				if (ie4) menuObj = contextMenu.style;
				if (ie4) menuObjLite = contextMenuLite.style;

				if (ns6) menuObj = document.getElementById("contextMenu");
				if (ns6) menuObjLite = document.getElementById("contextMenuLite");
			}

			if ( (ns4) || (ie4) || (ns6))
			{
				document.onmousemove = mouseMove;
				if (ns4) document.captureEvents(Event.MOUSEMOVE);
			}
		}

		// Moves the layer
		function mouseMove(e)
		{
		//	window.status = "" + event.x + " " + event.y + "";
			if (allowMove == 0)
			{
				if ( (ns4) || (ns6) ) {o3_x = e.pageX; o3_y = e.pageY;}
				if ((ie4) || (ie5)) {o3_x = event.x + self.document.body.scrollLeft; o3_y = event.y + self.document.body.scrollTop;}

				placeLayer();
			}
			else
			{
				//if allowmove == 1, then we've already displayed the contextmenu.  So,
				//every time the user moves their mouse over the available menu options,
				//reset the timer so the menu doesnt close until they stop moving their mouse.
			
				setClickTimer(2000); //every time the user moves his mouse, reset the click timer.
			}
		}

		function placeLayer() 
		{
			var placeX, placeY;
			
			// HORIZONTAL PLACEMENT
			winoffset = (ie4) ? self.document.body.scrollLeft : self.pageXOffset;

			if (ie4) iwidth = self.document.body.clientWidth;
			if (ns4) iwidth = self.innerWidth;
			if (ns6) iwidth = self.outerWidth;
			
			if ( (o3_x - winoffset) > ((eval(iwidth)) / 2))
			{
				o3_hpos = "left";
			}
			else 
			{
				o3_hpos = "right";
			}
					
			if (o3_hpos == "right") 
			{
				placeX = o3_x+o3_offsetx;
				if ( (eval(placeX) + eval(o3_width)) > (winoffset + iwidth) )
				{
					placeX = iwidth + winoffset - o3_width;
					if (placeX < 0) placeX = 0;
				}
			}
			if (o3_hpos == "left")
			{
				placeX = o3_x-o3_offsetx-o3_width;
				if (placeX < winoffset) placeX = winoffset;
			}
			
			// VERTICAL PLACEMENT
			scrolloffset = (ie4) ? self.document.body.scrollTop : self.pageYOffset;

			if (ie4) iheight = self.document.body.clientHeight;
			if (ns4) iheight = self.innerHeight;
			if (ns6) iheight = self.outerHeight;

			iheight = (eval(iheight)) / 2;
			if ( (o3_y - scrolloffset) > iheight)
			{
				o3_vpos = "above";
			}
			else
			{
				o3_vpos = "below";
			}

			if (o3_vpos == "above")
			{
				if (o3_aboveheight == 0)
				{
					if (useLiteMenu)
					{
						var divref = (ie4) ? self.document.all['contextMenuLite'] : menuObjLite;
					}
					else
					{
						var divref = (ie4) ? self.document.all['contextMenu'] : menuObj;
					}

					o3_aboveheight = (ns4) ? divref.clip.height : divref.offsetHeight;
				}
				placeY = o3_y - (o3_aboveheight + o3_offsety);
				if (placeY < scrolloffset) placeY = scrolloffset;
			}
			else
			{
				placeY = o3_y + o3_offsety;
			}

			// Actually move the object.	
			if (useLiteMenu)
			{
				repositionTo(menuObjLite, placeX, placeY);
			}
			else
			{
				repositionTo(menuObj, placeX, placeY);
			}
		//	window.status = "" + placeX + " " + placeY + ""; return true;
		}

		// Move a layer
		function repositionTo(obj,xL,yL)
		{
			if ( (ns4) || (ie4) ) 
			{
				obj.left = xL;
				obj.top = yL;
			}
			else if (ns6)
			{
				obj.style.left = xL + "px";
				obj.style.top = yL+ "px";
			}
			
		}
