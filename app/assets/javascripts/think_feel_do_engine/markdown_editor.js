window.cleanWordClipboard = function(input){
  var swapCodes   = new Array(8211, 8212, 8216, 8217, 8220, 8221, 8226, 8230); // dec codes from char at
  var swapStrings = new Array("--", "--", "'",  "'",  "\"",  "\"",  "*",  "...");  

  // debug for new codes
  // for (i = 0; i < input.length; i++)  alert("'" + input.charAt(i) + "': " + input.charCodeAt(i));    
  var output = input;
  for (i = 0; i < swapCodes.length; i++) {
      var swapper = new RegExp("\\u" + swapCodes[i].toString(16), "g"); // hex codes
      output = output.replace(swapper, swapStrings[i]);
  }
  return output;
}
