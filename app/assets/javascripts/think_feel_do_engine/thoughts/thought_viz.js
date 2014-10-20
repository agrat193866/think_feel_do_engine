/*Thought Tracker Class
=
= enableViz: load the viz data and attempt to draw the viz in the 
= 	correctly named locations if present
= page: a string indicating what kind of view to deal with, currently:
== "home:(link_to_solo)" - Show the top 3 distortions if present, no tooltips, links to solo
== "solo" - Show a large version with all distortions with at least 3 thoughts per
==		distortion.
*/

sc.thoughtTracker = function(enableViz, page){
	var self = this, thePage = page, resizeTimer;

	if($("small").first().text().trim() == "Thought Distortions"){
		thePage = page = "solo";
	}

	this.reRenderViz = function(page){
		self.menuViz = new scThoughtTrackerMenuViz(thoughtsWithPatterns,page.substr(0,4));

		//forceCloseVizTooltip
		$("div.thoughtviz_tooltip")
			.on("click", this.menuViz.forceCloseVizTooltip);

		//handleVizShowTooltipModal
		$("g#ThoughtVizSvg text, g#ThoughtVizSvg circle")
			.on("click", this.menuViz.handleVizTooltipModal);

		// //handleVizTooltipLeave
		// $("g#ThoughtVizSvg text, g#ThoughtVizSvg circle, .thoughtviz_tooltip")
		// 	.on("mouseout focusout", this.menuViz.handleVizTooltipLeave);

		if (page.substr(0,4) == "home"){
			$("g#ThoughtVizSvg text, g#ThoughtVizSvg circle").off("click")
				.on("click", function(){ location.pathname = page.substr(5); });
		}
	}

	this.timedReRender = function(page){
		clearTimeout(resizeTimer);
		resizeTimer = setTimeout(function(){self.reRenderViz(page);}, 1000);
	}

	if(enableViz){
		self.reRenderViz(thePage);

		//Event Handelers

		//handle change viz ratio
		$(window).off('.scThoughtTracker');
		$(window).on('resize.scThoughtTracker', function(){self.timedReRender(thePage)});
	}
};
