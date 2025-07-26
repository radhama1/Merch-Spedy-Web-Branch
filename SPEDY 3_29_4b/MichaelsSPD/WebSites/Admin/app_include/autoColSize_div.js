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
		if (document.all || document.getElementById)
		{
			var oHandle = document.all ? document.all[colReference] : document.getElementById(colReference);
			if (newWidth >= 0)
			{
				oHandle.style.width = newWidth;
			}
		}
	}
	
	function initDataLayout(numCols)
	{
		if (isNaN(numCols) || arguments.length != 1) initDataLayout_UnknownNumberOfCols();
		var msg = ">> numCols: " + numCols + "\n";
		
		for (var i = 0; i <= numCols; i++)
		{
			var thisObjectName = "col_" + i;
			msg = msg + ">> thisObjectName " + thisObjectName + "\n";

			var odataHeaderHandle = document.all(thisObjectName);
			var odataRowsetHandle = document.all(thisObjectName + "_data");

			msg = msg + ">> odataHeaderHandle: " + odataHeaderHandle + "\n";
			msg = msg + ">> odataRowsetHandle: " + odataRowsetHandle + "\n";
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
		
	//	alert(msg);
	}

	//this function attempts to figure out which columns are column headers and set their size.
	//this function can be costly and slow when run against a table with a lot of columns and rows of data.
	//whenever possible, pass the number of columns to the initDataLayout function.
	function initDataLayout_UnknownNumberOfCols()
	{
		var msg = "";
		for (var i = 0; i < document.all.length; i++)
		{
			if (document.all(i).id)
			{
				var thisObjectName = new String(document.all(i).id)
				if (thisObjectName.indexOf("col_") >= 0 && thisObjectName.indexOf("_data") < 0 && thisObjectName.indexOf("_data") < 0)
				{
					var odataHeaderHandle = eval("document.all." + thisObjectName);
					var odataRowsetHandle = eval("document.all." + thisObjectName + "_data");
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
	}

