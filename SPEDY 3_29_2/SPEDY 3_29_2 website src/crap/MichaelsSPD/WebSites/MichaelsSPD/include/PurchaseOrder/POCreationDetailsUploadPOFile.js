function closewin()
{   
    window.close();
}
function onUpload()
{
    var b1 = $('btnSubmit');
    var b2 = $('btnSubmitting');
    if(b1 != null && b2 != null){
        b1.addClassName("hideElement");
        
        b2.removeClassName('hideElement');
        b1.addClassName("formButton");
        b2.disabled = true;
    }
    return true;
}
function DoUnload()
{
    <% If RefreshParent Then %>
    window.parent.opener.location = window.parent.opener.location;
    <% End If %>	    
}