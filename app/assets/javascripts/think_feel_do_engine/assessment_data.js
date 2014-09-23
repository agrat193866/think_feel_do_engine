sc.assessmentData = function(moodData, emotionData, phq9) {

  /*Required for Rickshaw to pass the phantom js tests*/
  if (!Function.prototype.bind) {
  Function.prototype.bind = function (oThis) {
    if (typeof this !== "function") {
      // closest thing possible to the ECMAScript 5
      // internal IsCallable function
      throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
    }

    var aArgs = Array.prototype.slice.call(arguments, 1), 
        fToBind = this, 
        fNOP = function () {},
        fBound = function () {
          return fToBind.apply(this instanceof fNOP && oThis
                 ? this
                 : oThis,
                 aArgs.concat(Array.prototype.slice.call(arguments)));
        };

    fNOP.prototype = this.prototype;
    fBound.prototype = new fNOP();

    return fBound;
    };
  }

  $("#vizcontainer").children().remove();
  $("#vizcontainer").append('<div id="Title"><h2>Patient Mood Ratings and PHQ9 Assessment Scores</h2></div><div id="axisL" class="axis"></div><div id="graphArea"></div><div id="legend"></div><div id="legend_hidden"></div>');

  /* On with the show */
  var chartTitle, phqColor, graph, hoverDetail, legend, palette, scales,
  seriesDataHash, xAxis, yAxis1, yAxis2, moodsAndEmotions,
  feelingLines, feelingDots, allLines;
  palette = new Rickshaw.Color.Palette();
  moodsAndEmotions = sc.createEmotionSeries(emotionData, moodData, palette);
  feelingLines = moodsAndEmotions.line;
  feelingDots = moodsAndEmotions.dots;
  chartTitle = "Patient Mood Ratings and PHQ9 Assessment Scores";
  seriesDataHash = [];

  phqColor = palette.color();
  var max, min, seriesArray;
  seriesArray = [];
  min = max = 0;
  _.each(phq9, function(value) {
    min = ((min === max && max === 0) ? value[1] : Math.min(min, value[1]));
    max = Math.max(max, value[1]);
    return seriesArray.push({
      x: value[0] + 60*60*23,
      y: value[1]
    });
  });

  seriesDataHash.push(_.sortBy(seriesArray, function(obj) {
    return +obj.x;
  }));

  allLines = [];
  if (seriesDataHash[0].length > 0) {
    allLines = [
                  {
                    name: "PHQ9",
                    data: seriesDataHash[0],
                    color: phqColor,
                    renderer: "line"
                  }
                ];
  }

  if (feelingLines[0] && feelingLines[0].data.length === 0) {
    delete feelingLines[0];
  }
  if (feelingLines[1] && feelingLines[1].data.length === 0) {
    delete feelingLines[1];
  }
  if (feelingLines.length > 0) {
    allLines = allLines.concat(feelingLines);
  }

  graph = new Rickshaw.Graph({
    element: document.querySelector("#graphArea"),
    renderer: "multi",
    series: allLines,
    padding: {
      top: 0.05,
      left: 0.05,
      right: 0.05,
      bottom: 0.05
    }
  });

  legend = new Rickshaw.Graph.Legend({
    graph: graph,
    element: document.querySelector("#legend")
  });

  _.each(feelingDots, function(value){
    graph.series.push(value);
  });

  graph.series.push({
    name: "PHQ9",
    data: seriesDataHash[0],
    color: phqColor,
    renderer: "scatterplot"
  });

  yAxis1 = new Rickshaw.Graph.Axis.Y({
    graph: graph,
    orientation: "left",
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
    element: document.querySelector("#axisL")
  });

  xAxis = new Rickshaw.Graph.Axis.Time({
    graph: graph
  });

  hoverDetail = new Rickshaw.Graph.HoverDetail({
    graph: graph,
    formatter: function(series, x, y) {
      var content, date;
      date = "<span class=\"date\">" + d3.time.format("%x")(new Date(x * 1000)) + "</span>";
      content = series.name + ": " + parseInt(y) + "<br>" + date;
      return content;
    }
  });

  /* Update: Allow toggleable data */
  legend_hidden = new Rickshaw.Graph.Legend({
      element: document.getElementById("legend_hidden"),
      graph: graph,
      margin: {
        left:10
      }
    });

  shelving = new Rickshaw.Graph.Behavior.Series.Toggle({
    graph: graph,
    legend: legend
  });

  shelving_hidden = new Rickshaw.Graph.Behavior.Series.Toggle({
    graph: graph,
    legend: legend_hidden
  });

  $("#legend span, #legend a").on("click", function(){
    var index, toggle, moodCount

    index = $(this).is("span") ? $(this).text() : $(this).siblings("span").text();
    toggle = $($("#legend_hidden li span:contains('" + index + "')")[0]).siblings("a");
    moodCount = $("#legend li").length
    if($(this).hasClass("limit_disable_count")){
      $(this).removeClass("limit_disable_count");
      return;
    }
    if($(this).is("a")){
      //Toggle off/on
      if($("#legend li.disabled").length == moodCount){
        $(this).addClass("limit_disable_count");
        $(this).trigger("click");
      }
      else toggle.trigger("click");
      $("#legend_hidden li").removeClass("focused");
    }
    if($(this).is("span") || $(this).is("li")) {
      //Toggle everything else off/back on
      if($(toggle).parent().hasClass("focused") || $("#legend li.disabled").length == 0){
        $("#legend_hidden li").removeClass("focused");
        $("#legend_hidden li.disabled:nth-child(-n + " + moodCount + ") a").trigger("click");
      }
      else {
        $("#legend_hidden li").removeClass("focused");
        $(toggle).parent().addClass("focused");
        $("#legend_hidden li:not(.disabled):nth-child(-n + " + moodCount + ") a").trigger("click");
        toggle.trigger("click");
      }
    }
  })

  /* End Update */

  return graph.render();
};
