	function getElement(el)
	{
		var tagList = new Object
		for (var i = 1; i < arguments.length; i++)
			tagList[arguments[i]] = true
			while ((el!=null) && (tagList[el.tagName]==null))
				el = el.parentElement
		return el
	}

	function checkHighlight(which)
	{
		var el = getElement(event.srcElement,"TH","TD")
		if (el==null) return
		if ((el.tagName=="TD"))
		{
			var row = getElement(el, "TR") 
			var TABLE = getElement(row, "TABLE")

			if (which) 
				row.className = "rover"
			else
				row.className = ""

		//	if (row.className == "rover") 
		//		row.className = ""
		//	else
		//		row.className = "rover"
		}
	}
  