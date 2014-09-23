$(document).on("page:change", function() {
  var forms;
  $("form.edit-emotion-form .checkbox input").on("change", function(event) {
    var form, target;
    target = $(event.currentTarget);
    form = $(target).closest("form.edit-emotion-form");
    return form.find(".intensity-scale").toggle();
  });
  return $("#update-emotions").on("click", function(event) {
    var $target, numberOfForms;
    event.preventDefault();
    forms = $("form input:checked").closest("form");
    numberOfForms = forms.length;
    $target = $(event.currentTarget);
    $.each(forms, function(index, form) {
      var data;
      data = $(form).serialize();
      return $.ajax({
        type: $(form).attr("method"),
        url: $(form).attr("action"),
        data: data,
        dataType: "script",
        success: function(response) {
          numberOfForms = numberOfForms - 1;
          if (numberOfForms === 0) {
            return window.location.href = $target.attr("href");
          }
        }
      });
    });
    return false;
  });
});

sc.dynamicallyToggleEmotionInputField = function() {
  return $(".emotion-name-group.form-group select").on("change", function(event) {
    var $target;
    $target = $(event.currentTarget);
    if ($target.find("option:selected").val() === "") {
      return $target.closest(".new_emotional_rating").find(".written-option").show();
    } else {
      var writtenOption;
      $writtenOption = $target.closest(".new_emotional_rating").find(".written-option");
      $writtenOption.hide();
      return $writtenOption.find("input").val("");
    }
  });
};

sc.rateEmotions = function(formContainers, path, partial) {
  sc.dynamicallyToggleEmotionInputField();
  $("#add-forms").on("click", function() {
    var count;
    count = $(formContainers).length;
    $("#forms-container").append("<div id='subcontainer-" + count + "'>" + partial + "</div>");
    sc.dynamicallyToggleEmotionInputField();
    return false;
  });
  $("#submit-forms").on("click", function(event) {
    event.preventDefault();
    _.each($(formContainers), function(form, index, list) {
      var $form;
      $form = $(form);
      return $.ajax({
        async: false,
        data: $form.serialize(),
        dataType: "script",
        type: "POST",
        url: $form.attr("action"),
        success: function() {
          if ((index + 1) === list.length) {
            window.location.href = path;
          }
        }
      });
    });
    return false;
  });
};

sc.createEmotionSeries = function(emotionData, moodRatings, palette) {
  // Returns a JSON object, 
  //   line: line chart series
  //   dots: dot chart series
  seriesData = [];
  seriesData_LrgDots = [];
  colors = [];
  if(emotionData.length > 0){
    _.each(emotionData, function(value, index, list) {
      var points;
      points = value[1].map(function(d) {
        return {
          x: d[0],
          y: d[1]
        };
      });
      colors.push(palette.color());
      seriesData_LrgDots.push({
        color: colors[index],
        data: points,
        name: value[0],
        renderer: "scatterplot"
      });
      return seriesData.push({
        color: colors[index],
        data: points,
        name: value[0],
        renderer: "line"
      });
    });
  }

  if(moodRatings.length > 0){

    colors.push(palette.color());

    seriesData_LrgDots.push({
      color: colors[colors.length -1],
      data: moodRatings.map(function(d) {
      return {
        x: d[0],
        y: d[1]
      };
    }),
    name: "Mood",
      renderer: "scatterplot"
    });

    seriesData.push({
      color: colors[colors.length -1],
      data: moodRatings.map(function(d) {
        return {
          x: d[0],
          y: d[1]
        };
      }),
      name: "Mood",
      renderer: "line"
    });
  }

  return {"line": seriesData,
          "dots": seriesData_LrgDots
         }
}

sc.emotionViz = function(emotionData, moodRatings) {

  $("#chart-container").children().remove();
  if((emotionData.length == 0))
  {
    $("#chart-container").append('<p class="lead">No emotions have been recorded yet.</p>');
  }
  if((moodRatings.length == 0))
  {
    $("#chart-container").append('<p class="lead">No moods have been recorded yet.</p>');
  }
  if (!((emotionData.length == 0) && (moodRatings.length == 0))) {

    $("#chart-container").append('<div id="y-axis"></div><div id="chart"></div><div id="legend"></div><div id="legend_hidden"></div>');

    var axes, allData, emotionData, graph, hoverDetail, legend, palette, seriesData, shelving;
    
    palette = new Rickshaw.Color.Palette();

    allData = sc.createEmotionSeries(emotionData, moodRatings, palette);

    seriesData = allData.line;
    seriesData_LrgDots = allData.dots;
    
    graph = new Rickshaw.Graph({
      element: document.getElementById("chart"),
      renderer: "multi",
      series: seriesData,
      padding: {
        top: 0.05,
        left: 0.05,
        right: 0.05,
        bottom: 0.05
      },
      interpolation: "linear"
    });

    axes = new Rickshaw.Graph.Axis.Time({
      graph: graph
    });

    hoverDetail = new Rickshaw.Graph.HoverDetail({
      graph: graph
    });

    legend = new Rickshaw.Graph.Legend({
      element: document.getElementById("legend"),
      graph: graph,
      margin: {
        left:10
      }
    });

    _.each(seriesData_LrgDots,function(value)
      {
        graph.series.push(value);
      });

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
      var index, toggle, moodCount;
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
    });

    yAxis = new Rickshaw.Graph.Axis.Y({
      element: document.getElementById('y-axis'),
      graph: graph,
      orientation: 'left',
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
    });

    graph.render();
    axes.render();
  }
};