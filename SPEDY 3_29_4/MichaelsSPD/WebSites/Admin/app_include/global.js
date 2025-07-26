function checkEmail(value) {
	if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(value)){
		return (true);
	}
	else {
		return (false);
	}
}

function trim(sText)
{
	sText = sText.replace(/^\s*|\s*$/g,"");
	
	return sText;
}

function ltrim(stringToTrim) {
	return stringToTrim.replace(/^\s+/,"");
}
function rtrim(stringToTrim) {
	return stringToTrim.replace(/\s+$/,"");
}


function IsPosNumber(sText)
{
	var strExp = /^\d*$/;
	var IsNumber = strExp.test(sText);
		
	return IsNumber;

}

function IsDecimal(sText)
{
	var strExp = /^[0-9]*(\.)?[0-9]+$/;
	var IsNumber = strExp.test(sText);
		
	return IsNumber;
}

function IsANumericValue(sText)
{
	var strExp = /^(\d|-)?(\d|,)*\.?\d*$/;
	var IsNumber = strExp.test(sText);

	return IsNumber;
}
