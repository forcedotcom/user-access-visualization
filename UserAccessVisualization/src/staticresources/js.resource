/**
 * Copyright (c) 2012, Salesforce.com, Inc.  All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 * 
 *   * Neither the name of Salesforce.com nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
j = jQuery.noConflict();

/*
 * Method to draw a polygon connection each 2d point found in pts
 */
function poly(context, xOffs, yOffs, pts) {
  var ii;
  context.moveTo(pts[0][0] + xOffs, pts[0][1] + yOffs);
  for (ii = 1; ii < pts.length; ii++) {
    context.lineTo(pts[ii][0] + xOffs, pts[ii][1] + yOffs);
  }
  context.closePath();
}

/*
 * Wrapper used to invoke loadFls(..) with the appropriate arguments.
 * Uses jQuery to traverse the event target's hierarchy until it
 * finds an element matching the colName_* pattern.  It then extracts
 * the column name from the CSS class and call loadFls with that.
 */
function showFls(e) {
  var tgt = j(e.target)
  while (!tgt.hasClass('objectColumn')) tgt = tgt.parent();
  
  loadFls(/.*colName_([^ ]+)/.exec(tgt.attr('class'))[1], e);
}

/*
 * A pretty hacky function that draws our cool polygon on the HTML5 canvas.
 * I certainly don't know HTML5 Canvas APIs well, and I'm a complete thrasher
 * when it comes to HTML's box model, so the below, while functional may
 * not make much sense, either.  :)
 *
 * Caveat Emptor.
 */
var lastLeft = null;
function drawCanvas(e) {
  var jl = j('.fls-canvas');
  if (jl.length == 0) return; // No canvas in which to draw
  var canvas = jl.get(0);
  var tgt = j(e.target);
  while (tgt.length > 0 && !tgt.hasClass('objectColumn')) tgt = tgt.parent();
  if (tgt.length == 0) return; // No objectColumn ancestor
  var opPos = tgt.position();
  if (lastLeft && opPos.left == lastLeft) return
  lastLeft = opPos.left;
  var flsTableElt = j('.flsTableContainer');
  var flsPos = flsTableElt.position();
  var context = canvas.getContext("2d");
  var offs = 1;
  
  context.clearRect(0, 0, canvas.width, canvas.height);
  context.beginPath();
  poly(context, offs, 0, [[0, canvas.height],
                          [opPos.left - flsPos.left, 5], 
                          [opPos.left - flsPos.left, 0],
                          [opPos.left - flsPos.left + tgt.width(), 0],
                          [opPos.left - flsPos.left + tgt.width(), 5],
                          [flsTableElt.width() - 2, canvas.height]]);
                          
  context.lineWidth = 1;
  context.fillStyle = '#666666';
  context.strokeStyle = '#666666';
  context.fill();
  context.stroke();
}
  
/*
 * When the document is loaded, compute the appropriate width for the FLS table display,
 * setup some click handlers for FLS display, and then draw our cool polygon for the first
 * object with object perms.
 */
j(document).ready(function() {
  j('.fls-canvas').attr('width', Math.max(j('.objectPermTable').width(), j('.flsTableContainer').width()));
  j('.objectPermDetail').click(showFls);
  j('.objectPermTable .headingLabel').click(showFls);
  drawCanvas({target: j('.objectPermTable td.objectColumn.colEnabled').get(0)});
});