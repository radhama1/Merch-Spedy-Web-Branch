/*
'==============================================================================
' CLASS: cls_Security
' Created Friday, September 08, 2005
' By ken.wallace
'==============================================================================
'
' This object allows the web client to access a basic set of security methods
'
'==============================================================================
*/
function cls_Security(CurrentUserGUID)
{
	var _securityxml, _timeouthandle;

	_securityxml = new ActiveXObject("MSXML2.DOMDocument");
	_securityxml.async = false;
	_securityxml.setProperty("SelectionLanguage", "XPath");

	this.load = function()
	{
		_load();
	}

	_load = function()
	{
		_loadXMLFile("./../app_include/security_out.asp?g=" + CurrentUserGUID + "&r=" + Math.round(Math.random()*1000000));
	}

	_loadXMLFile = function(xmlLocation)
	{
		window.status = "Loading security context ... ";
		_securityxml.load(xmlLocation);
		window.status = "Most recent security update processed: " + Date();
	}

	this.isRequestedScopeAllowed = function(Requested_Scope_Constant)
	{
		if (!_securityxml.xml) return false;
		var retValue = false;

		if (_securityxml.selectNodes("//Security_Scope[@Constant = '" + Requested_Scope_Constant + "']").length > 0)
		{
			retValue = true;
		}

		if (!retValue) retValue = this.isSystemAdministrator();
		return retValue;
	}

	this.isRequestedPrivilegeAllowed = function(Requested_Scope_Constant, Requested_Privilege_Constant)
	{
		if (!_securityxml.xml) return false;
		var retValue = false;

		if (_securityxml.selectNodes("//Security_Privilege[@Constant = '" + Requested_Privilege_Constant + "']/Security_Scope[@Constant = '" + Requested_Scope_Constant + "']").length > 0)
		{
			retValue = true;
		}

		if (!retValue) retValue = this.isSystemAdministrator();
		return retValue;
	}

	this.isRequestedAccessToObjectAllowed = function(Requested_Scope_Constant, Requested_Privilege_Constant, Requested_Object_ID)
	{
		if (!_securityxml.xml) return false;
		var retValue = false;

		if (_securityxml.selectNodes("//Security_Privileged_Objects/Security_Privileged_Object[@Secured_Object_ID = '" + Requested_Object_ID + "']/Security_Privilege[@Constant = '" + Requested_Privilege_Constant + "']/Security_Scope[@Constant = '" + Requested_Scope_Constant + "']").length > 0)
		{
			retValue = true;
		}
		
		if (!retValue) retValue = this.isSystemAdministrator();
		return retValue;
	}

	this.isSystemAdministrator = function()
	{
		if (!_securityxml.xml) return false;
		var retValue = false;
		
		//Check to see if this is a system administrator
		if (_securityxml.selectNodes("//Security_Group[@System_Role = '1']").length > 0)
		{
			retValue = true;
		}

		return retValue;
	}

	this.load();
}
