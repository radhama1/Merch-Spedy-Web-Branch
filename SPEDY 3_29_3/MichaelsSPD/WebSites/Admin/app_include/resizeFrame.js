function resizeFrame(newSizeFramesetArgs, what, where, how)
{
	if (what == "")
		return false;
	if (newSizeFramesetArgs == "")
		return false;
	
	var parentDoc = new Object();
	if (where)
	{
		parentDoc = where;
	}
	else
	{
		alert(parentDoc + " does not exist!")
	}
	
	if (parentDoc )
	{
		switch(how)
		{
			case "cols":
				parentDoc.document.getElementById(what).cols = newSizeFramesetArgs;
				break;

			case "rows":
				parentDoc.document.getElementById(what).rows = newSizeFramesetArgs;
				break;
		}
	}
	else
	{
		alert(parentDoc + " does not exist!")
	}
}
