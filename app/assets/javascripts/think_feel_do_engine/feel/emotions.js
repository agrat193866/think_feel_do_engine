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

function columnChart(lowBound, highBound, title) {
  var margin = {top: 30, right: 10, bottom: 50, left: 50},
      width = 420,
      height = 420,
      xRoundBands = 0.2,
      xValue = function(d) { return d.day; },
      yValue = function(d) {
        if (d.is_positive === false) {
          return -d.intensity;
        }
        else {
          return d.intensity;
        }
      },
      xScale = d3.scale.linear(),
      yScale = d3.scale.linear(),
      yAxis = d3.svg.axis().scale(yScale).orient("left"),
      xAxis = d3.svg.axis().scale(xScale),
      titleHeight = 25,
      averageLineThickness = 5;


  function chart(selection) {
    selection.each(function(data) {

      // Convert data to standard representation greedily;
      // this is needed for nondeterministic accessors.
      data = data.map(function(d, i) {
        return [xValue.call(data, d, i), yValue.call(data, d, i), (d.is_positive !== false)];
      });
      // Update the x-scale.
      xScale
          .domain(data.map(function(d) { return d[0];} ))
          .rangeRoundBands([0, width - margin.left - margin.right], xRoundBands);


      // Update the y-scale.
      yScale
          .domain([lowBound, highBound])
          .range([height - margin.top - margin.bottom, 0])
          .nice();


      // Select the svg element, if it exists.
      var svg = d3.select(this).selectAll("svg").data([data]);

      // Otherwise, create the skeletal chart.
      var gEnter = svg.enter().append("svg").append("g");
      gEnter.append("g").attr("class", "average-lines");
      gEnter.append("g").attr("class", "bars");
      gEnter.append("g").attr("class", "y axis");
      gEnter.append("g").attr("class", "x axis");
      gEnter.append("g").attr("class", "x axis zero");

      // Update the outer dimensions.
      svg .attr("width", width)
          .attr("height", height)
          .append("text")
          .attr("x", graphWidth/2)
          .attr("y", titleHeight)
          .attr("font-size", titleHeight)
          .attr("font-family","sans-serif")
          .attr("text-anchor","middle")
          .attr("font-weight","bold")
          .text(title);

      // draw average line
      var positiveValues = [], negativeValues = [];
      for (var i = 0; i < data.length; i++) {
        if (data[i][2] === false) {
          negativeValues.push(data[i][1]);
        } else {
          positiveValues.push(data[i][1]);
        }
      }
      svg.select(".average-lines").append("rect")
         .attr("class", "positive-average-line")
         .attr("width", width)
         .attr("height", averageLineThickness)
         .attr("x", xScale(0))
         .attr("y", yScale(d3.mean(positiveValues)) - averageLineThickness / 2)
         .attr("fill", "green");
      if (negativeValues.length > 0) {
        svg.select(".average-lines").append("rect")
           .attr("class", "negative-average-line")
           .attr("width", width)
           .attr("height", averageLineThickness)
           .attr("x", xScale(0))
           .attr("y", yScale(d3.mean(negativeValues)) - averageLineThickness / 2)
           .attr("fill", "green");
      }

      // Update the inner dimensions.
      var g = svg.select("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

     // Update the bars.
      var bar = svg.select(".bars").selectAll(".bar").data(data);
      bar.enter().append("rect");
      bar.exit().remove();
      bar .attr("class", function(d, i) { return d[1] < 0 ? "bar negative" : "bar positive"; })
          .attr("x", function(d) { return X(d); })
          .attr("y", function(d, i) { return d[1] < 0 ? Y0() : Y(d); })
          .attr("width", xScale.rangeBand())
          .attr("height", function(d, i) { return Math.abs( Y(d) - Y0() ); });

    // x axis at the bottom of the chart
     g.select(".x.axis")
        .attr("transform", "translate(0," + (height - margin.top - margin.bottom) + ")")
        .call(xAxis.orient("bottom"));

    // zero line
     g.select(".x.axis.zero")
        .attr("transform", "translate(0," + Y0() + ")")
        .call(xAxis.tickFormat("").tickSize(0));


      // Update the y-axis.
      g.select(".y.axis")
        .call(yAxis);

    });
  }


// The x-accessor for the path generator; xScale ∘ xValue.
  function X(d) {
    return xScale(d[0]);
  }

  function Y0() {
    return yScale(0);
  }

  // The x-accessor for the path generator; yScale ∘ yValue.
  function Y(d) {
    return yScale(d[1]);
  }

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  chart.x = function(_) {
    if (!arguments.length) return xValue;
    xValue = _;
    return chart;
  };

  chart.y = function(_) {
    if (!arguments.length) return yValue;
    yValue = _;
    return chart;
  };

  return chart;
}

