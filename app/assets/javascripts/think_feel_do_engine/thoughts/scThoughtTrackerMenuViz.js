scThoughtTrackerMenuViz = function(vizData, page){
	//Properties
	var thoughtPatterns, thoughtsList,patternFrequencies,self;

	//Viz Variables
	var margin,width,height,svg,color,rRange,text, widescreen;

	//Utility Methods
	var showOnlyTopX,showOnlyAboveX, placeInGrid, getTooltipTop, getTooltipLeft;

	/****************************/

	self = this;
	thoughtPatterns = {}
	patternFrequencies = {};
	thoughtsList = [];
    widescreen = window.innerWidth > window.innerHeight;
    height = widescreen ? 200 : (page == "home" ? 500 : 768);
    width = $("#ThoughtVizContainer").width();

	/**********[Utility Methods]**********/

	//Show only the top x patterns with the most thoughts associated with them
	showOnlyTopX = function(x){
		var topX, i;

		topX = [];
		i = 0;
		
		_.each(patternFrequencies, function(value,key){
			topX.push([key,value]);
			delete patternFrequencies[key];
		});
		
		topX.sort(function(a,b){
			a = a[1];
			b = b[1];
			return a > b ? -1 : (a < b ? 1 : 0);
		});
		
		while(i < topX.length && i < x){
			patternFrequencies[(topX[i])[0]] = (topX[i])[1];
			i++;
		}
	}

	//Show only the patterns with at least x thoughts associated with them
	showOnlyAboveX = function(x){
		_.each(patternFrequencies, function(value,key){
			if(value < x) delete patternFrequencies[key];
		});
	};

	//The circles and text need to be aligned the same, so rather than repeat
	//myself, this function returns location for a given circle.
	placeInGrid = function(x, i){
		var objCount = _.size(patternFrequencies);
        //If x, return the x location. Else return the y location.
        if(x){
            if(widescreen) return ((width+160)/(Math.min(objCount + 1, 4))) * ((i%3)+1);
            else if(page == "home") return (width+160)/2;
            else return (i%2 + 1)*((width)/3) + 80;
        }
        else{
            if(widescreen){
                if(page == "home") return (height/2);
                return (Math.floor(i/3) + 1) * (Math.max(((Math.min(height,width) - 80)/3),10) + 50);
            }
            else if (page == "home") return (height)/(objCount + 1) * (i+1);
            else return (i+1) * (Math.max((Math.min(height,width) - 80)/(objCount*2),10) + 50);
        }
	}

	getTooltipLeft = function(e,sel){
		return (e.pageX - $(sel).offset().left < 0) ? 
			0 : 
			e.pageX - $(sel).offset().left;
	}

	getTooltipTop = function(e,sel,patternId){
		if (page == "home")	return e.pageY - $(sel).offset().top + 80;
		return (e.pageY - $(sel).offset().top + $("#tool_" + patternId).height() > 400) ? 
    			0 :
    			e.pageY - $(sel).offset().top;
	}

	/****[Build the Thought List from the page JSON]****/
	_.each(vizData,function(value,index){
        if(value.pattern == null) return;
		thoughtsList.push(
			{
				"thought": value.content,
				"challenge": value.challenging_thought,
				"asIfAction": value.act_as_if,
				"patternId": value.pattern.id
			}
		);
		if(!(value.pattern.id in thoughtPatterns)){
			thoughtPatterns[value.pattern.id] = value.pattern;
			patternFrequencies[value.pattern.id] = 1;
		}
		else patternFrequencies[value.pattern.id] += 1;
	});

	/********[Filter Results]************/

	showOnlyAboveX(3);
	if(page == "home") showOnlyTopX(3);
          
	//Using these ^ functions allows us to very easily dynamically
	//change how the data is shown on the page

    /***********[Set Colors]*************/
    color = d3
    		.scale
    		.category20();

    /********[Circle Radius Method]*********/
    objCount = d3.values(patternFrequencies).length;

    var radiusScale = null;
    if(widescreen){
        if(page == "home")
        radiusScale = [Math.max(Math.min(height,width)/(objCount*3),10), Math.max(Math.min(height,width)/3,10)];
        else
        radiusScale = [Math.max((Math.min(height,width) - 80)/(objCount*3),10),
                        Math.max((Math.min(height,width) - 80)/3,10)];
    }
    else{
        if(page == "home")
            radiusScale = [Math.max((Math.min(height,width) - 80)/(objCount*6),10),
                        Math.max((Math.min(height,width) - 80)/6,10)];
        else
        radiusScale = [Math.max((Math.min(height,width) - 80)/(objCount*6),10),
                        Math.max((Math.min(height,width) - 80)/(objCount*2),10)];
    }

    rRange = d3
	.scale
	.linear()
	.domain(
				[
					d3.min(d3.values(patternFrequencies)),
					d3.max(d3.values(patternFrequencies))
				]
			)
	.range(radiusScale);

    /******[Add Canvas To Container]******/
    
    //If there's already a viz here, replace it
    if($("#ThoughtVizContainer svg").length > 0) $("#ThoughtVizContainer svg").remove();

    //screenRatio = (window.innerWidth > window.innerHeight) ? "0 0 1140 204" : "0 0 200 800";
    svg = d3
    	.select("#ThoughtVizContainer")
    	.insert("svg", ":first-child")
        .attr("height", widescreen ? (page == "home" ? "200px" : "500px") : (page == "home" ? "500px" : "768px"))
        .attr("width",width + "px")
        .append("g")
        .attr("id", "ThoughtVizSvg")
        .attr("transform", "translate("+ ("-80") + ","+ ("10")+")");

    svg.selectAll(".dot")
        .data(d3.entries(patternFrequencies))
        .attr("class", "dot")
        .enter().append("circle")
        .attr("r", 
	        	function(d){
	        		//Circle Radius
	            	return rRange(d.value);
	            }
            )
        .style("fill", 
        		function(d, i){
        			//Color
            		return color(i); 
        		}
        	)
        .attr("cx", 
        		function(d, i){
        			//Circle X-Coord
            		return placeInGrid(true,i);
            	}
            )
        .attr("cy", 
        		function(d, i){
        			//Circle Y-Coord
            		return placeInGrid(false,i);
        		}
        	)
        .attr("data-toggle","modal")
        .attr("data-target",function(d,i){return "#tool_" + d.key;})
        .attr("stroke", "grey")
        .attr("class", "viz-clickable")
        .attr("stroke-width", 2)
        .attr("id",
        		function(d){
        			//Circle Tracking ID
        			return "circ_" + d.key;
        		}
        );

    /******[Format and Add Text]******/
    text = svg
    	.selectAll("text")
        .data(d3.entries(patternFrequencies))
        .enter()
        .append("text")
        .attr("x",
        		function(d, i){
        			//Text X-Coord
            		return placeInGrid(true,i);
            	}
            )
        .attr("y", 
        		function(d, i){
        			//Text Y-Coord
            		return placeInGrid(false,i);
            	}
            )
        .attr("dy", ".3em")
        .attr("data-toggle","modal")
        .attr("data-target",function(d,i){return "#tool_" + d.key;})
        .style("text-anchor", "middle")
        .attr("class","thoughtviz_text viz-clickable")
        .attr("id",
        		function(d){
        			return "text_" + d.key;
        		}
        	)
        .text(
    		function(d, i) {
	            if (d.value > 0)
		            return (thoughtPatterns[d.key].title.length > 27)?
		        			thoughtPatterns[d.key].title.substr(0,25) + "..." :
		        			thoughtPatterns[d.key].title;
	        }
        );

    if(objCount > 0)
    svg.append("text").text("Click a bubble for more info").attr("x",
                100
            )
        .attr("y", 
                20
            )
        .attr("font-weight",
            "bold");

    /******[Build Tooltips]******/
    if(page == "solo"){
        _.each(thoughtPatterns,function(value,index){
        	var newTip,newDialog,newContent,newHeader,newBody,newFooter,userThoughts,listLength,
            closeButtonTop,closeButtonBottom,closeSpanX,closeSpanText,headerText;

        	newTip = $("<div/>");
        	
            newDialog = $("<div/>");
            newDialog.attr("class","modal-dialog");
            
            newContent = $("<div/>");
            newContent.attr("class","modal-content");
            
            newHeader = $("<div/>");
            newHeader.attr("class","modal-header");
            
            closeButtonTop = $("<button/>");
            closeButtonTop.attr("class","close")
                .attr("data-dismiss","modal");
            
            closeSpanX = $("<span/>");
            closeSpanX.attr("aria-hidden","true").html("&times");
            
            closeSpanText = $("<span/>");
            closeSpanText.attr("class","sr-only").text("Close");

        	headerText = $("<h3/>");
            headerText.attr("id",value.title + "_modal").attr("class","modal-title").text(value.title);

            newBody = $("<div/>");
            newBody.attr("class","modal-body");

            newBody.append($("<h4/>",{text:"Some Thoughts You've Entered"}));
            userThoughts = "<ul>";
            _.each(thoughtsList,function(tValue,tIndex){
             listLength = tIndex == 0 ? 0 : listLength;
             if(listLength < 5 && tValue.patternId == index)
                 userThoughts += "<li>" + tValue.thought + "</li>";
            });
            newBody.append(userThoughts);
            newBody.append($("<h4/>",{text:"Remember..."}));
            if(value.recommendations.indexOf("</")>=0){
                newBody.append($(value.recommendations));
            }else{
                newBody.append($("<p>" + value.recommendations + "</p>"));
            }

            newFooter = $("<div/>");
            newFooter.attr("class","modal-footer");

            closeButtonBottom = $("<button/>");
            closeButtonBottom.attr("class","btn btn-default")
                .attr("data-dismiss","modal");

            closeButtonBottom.text("Close");

            newFooter.append(closeButtonBottom);
            closeButtonTop.append(closeSpanText);
            closeButtonTop.append(closeSpanX);

            newHeader.append(closeButtonTop);
            newHeader.append(headerText);
            newContent.append(newHeader);
            newContent.append(newBody);
            newContent.append(newFooter);
            newDialog.append(newContent);
            newTip.append(newDialog);

        	newTip.attr("id","tool_" + index)
        	.attr("class","modal fade")
            .attr("role","dialog")
            .attr("aria-labelledby", value.title + "_modal")
            .attr("aria-hidden","true");        	
        	$("body").append(newTip);
        });
	}

	/******[Event Handelers]******/

    this.handleVizTooltipModal = function(e){
    	var patternId, left, top, sel;

        if(e.toElement.textContent == "Click a bubble for more info") return;

    	patternId = $(this).attr("id").substr(5);
    	if($("#tool_" + patternId).hasClass("active_tooltip") 
    		|| $("#tool_" + patternId).hasClass("disabled_tooltip")) return;
    	
    	sel = ($(this).attr("id").indexOf("circ") >= 0) ? $(this):$("#circ_" + patternId);	
    	left = (e.type == "touchstart")? 0 : getTooltipLeft(e,sel);
    	top = (e.type == "touchstart")? 0 : getTooltipTop(e,sel,patternId);
    	$("#tool_" + patternId).addClass("active_tooltip").css({top: top,left: left});
    	if(e.type == "touchstart") self.tempDisableTooltip(patternId,"toggled");
    };
};
