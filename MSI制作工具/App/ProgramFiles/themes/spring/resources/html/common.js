function InitPage() {
  document.getElementById('main').style.zoom = external.GetFontHeight() / 16;
}

function ResolveElValue(element) {
  text = element.value;

  if (element.origHtml)
    text = element.origHtml;
  else
    element.origHtml = text;

  text = external.MsiResolveFormatted(text);

  /*if (element.attributes["formatted"].value == "twice")
    text = external.MsiResolveFormatted(text);


  if (element.attributes["formatted"].value == "noarrow") {
    text = text.replace("<", "");
    text = text.replace(">", "");
  }

  text = text.replace("&", "");*/

  element.value = text;
  element.style.visibility = "visible";

  //alert('NewText:' + text);
}

function ResolveElement(element) {
  text = element.innerHTML;
  if (element.origHtml)
    text = element.origHtml;
  else
    element.origHtml = text;

  text = external.MsiResolveFormatted(text);

  if (element.attributes["formatted"].value == "twice")
    text = external.MsiResolveFormatted(text);


  if (element.attributes["formatted"].value == "noarrow") {
    text = text.replace("<", "");
    text = text.replace(">", "");
  }

  if (element.attributes["keepamp"] && element.attributes["keepamp"].value == "true") {
    text = text.replace("&", "&amp;");
  }
  else {
    text = text.replace("&", "");
  }

  element.innerHTML = text;
  element.style.visibility = "visible";
}

function ResolveTag(tag) {
  //get list of all specified elements:
  var arrElements = document.getElementsByTagName(tag);
  //alert(arrElements.length);
  //iterate over elements:
  for (var i = 0; i < arrElements.length; i++) {
    //get pointer to current element:
    var element = arrElements[i];

    //check for desired attribute:
    if (element.attributes["formatted"])
      ResolveElement(element);
  }
}

function ResolveTagValue(tag) {
  //get list of all specified elements:
  var arrElements = document.getElementsByTagName(tag);
  //alert(arrElements.length);
  //iterate over elements:
  for (var i = 0; i < arrElements.length; i++) {
    //get pointer to current element:
    var element = arrElements[i];

    //check for desired attribute:
    if (element.attributes["formatted"])
      ResolveElValue(element);
  }
}

function UpdateBackGroundIndVec(imageProp, a) {
  backImgPath = "url(file://" + external.MsiGetBinaryPathIndirect(imageProp) + ")";
  //alert(backImgPath);

  for(var i = 0; i < a.length; i++) {
    el = document.getElementById(a[i]);
	if (el)
		el.style.backgroundImage = backImgPath;
  }
}


function UpdateBackGroundInd(imageProp, id) {
  backImgPath = "url(file://" + external.MsiGetBinaryPathIndirect(imageProp) + ")";
  //alert(backImgPath);

  el = document.getElementById(id);
  el.style.backgroundImage = backImgPath;
}

function UpdateBackGround(imageBin, id) {
  backImgPath = "url(file://" + external.MsiGetBinaryPath(imageBin) + ")";
  //alert(backImgPath);

  el = document.getElementById(id);
  el.style.backgroundImage = backImgPath;
}


function UpdateSizeText(aProperty) {
  element = document.getElementById(aProperty);
  text = element.innerHTML;

  if (element.origHtml)
    text = element.origHtml;
  else
    element.origHtml = text;

  //if ( element.attributes["formatted"].value == "twice" )
  text = external.MsiResolveFormatted(text);

  //alert(external.MsiGetSizeText(aProperty));

  x = "[" + aProperty + "]"
  text = text.replace(x, external.MsiGetBytesCountText(aProperty));

  text = external.MsiResolveFormatted(text);

  element.innerHTML = text;
  element.style.visibility = "visible";
}

function ShowFooter() {
  element = document.getElementById("footer");
  element.style.visibility = "visible";
}

function AdvinstTextMark() {
  advinsttext = 'Advanced Installer';
  document.write('<div id=\'advinst-text-shadow\'>' + advinsttext + '</div><div id=\'advinst-text\'>' + advinsttext + '</div>');
}