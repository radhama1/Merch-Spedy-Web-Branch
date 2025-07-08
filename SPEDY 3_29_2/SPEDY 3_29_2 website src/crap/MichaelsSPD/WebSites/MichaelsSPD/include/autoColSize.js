	function headerCol_Resize(colReference, newWidth)
	{
		if (document.all || document.getElementById)
		{
			var oHandle = document.all ? document.all[colReference] : document.getElementById(colReference);
			if (newWidth >= 0)
			{
				oHandle.style.width = newWidth;
			}
		}
	}

	function dataCol_Resize(colReference, newWidth)
	{
		if (parent.frames[ParentFrameRef].document.all || parent.frames[ParentFrameRef].document.getElementById)
		{
			var oHandle = parent.frames[ParentFrameRef].document.all ? parent.frames[ParentFrameRef].document.all[colReference] : parent.frames[ParentFrameRef].document.getElementById(colReference);
			if (newWidth >= 0)
			{
				oHandle.style.width = newWidth;
			}
		}
	}
	
	var ParentFrameRef = "";
	function initDataLayout(targetFrame, returnFunc)
	{
		var msg = "";
		ParentFrameRef = targetFrame;
		for (var i = 0; i < document.all.length; i++)
		{
			if (document.all(i).id)
			{
				var thisObjectName = new String(document.all(i).id)
				if (thisObjectName.indexOf("col_") >= 0 && thisObjectName.indexOf("_data") < 0)
				{
					var odataHeaderHandle = eval("document.all." + thisObjectName);
					var odataRowsetHandle = eval("parent.frames[ParentFrameRef].document.all." + thisObjectName + "_data");
					if (odataHeaderHandle && odataRowsetHandle)
					{
						var headercolWidth = odataHeaderHandle.scrollWidth;
						var datacolWidth = odataRowsetHandle.scrollWidth;
						if (headercolWidth < datacolWidth) headerCol_Resize(thisObjectName, datacolWidth);
						if (headercolWidth > datacolWidth) dataCol_Resize(thisObjectName + "_data", headercolWidth);
						if (headercolWidth > datacolWidth) dataCol_Resize(thisObjectName + "_dataimg", headercolWidth);
						msg = msg + thisObjectName + ">> headercolWidth: " + headercolWidth + " datacolWidth:" + datacolWidth + "\n";
					}
				}
			}
		}
		
	//	alert(msg);
		if (returnFunc) eval(returnFunc);
	}
