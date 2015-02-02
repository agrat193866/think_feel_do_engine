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

function columnChart(startDate, endDate, lowBound, highBound, title, yLabel) {
  var margin = {top: 30, right: 10, bottom: 50, left: 50},
      width = 420,
      height = 420,
      xRoundBands = 0.2,
      xValue = function(d) { return moment(new Date(d.day)).startOf('day')._d; },
      yValue = function(d) { return d.is_positive === false ? -d.intensity : d.intensity },
      xScale = d3.scale.ordinal(),
      yScale = d3.scale.linear(),
      yAxis = d3.svg.axis().scale(yScale).orient("left"),
      xAxis = d3.svg.axis().scale(xScale),
      parseDate = d3.time.format("%Y-%m-%d").parse,
      titleHeight = 25,
      averageLineThickness = 2;

  function chart(selection) {
    selection.each(function(data) {
      // Convert data to standard representation greedily;
      // this is needed for nondeterministic accessors.
      data = data.map(function(d, i) {
        if(moment(new Date(d.day)).startOf('day') >= startDate._d && moment(new Date(d.day)).startOf('day') <= endDate._d) {
          return [xValue.call(data, d, i), yValue.call(data, d, i), d.is_positive, d.drill_down, d.data_type];
        }
      });
      data = data.filter(function(n){ return n !== undefined; });
      // Update the x-scale.
      var domain = data.map(function(d) { return moment(new Date(d[0]))._d } );
      var dayRange = d3.time.days(startDate._d, endDate._d).length
      var x_domain = [endDate.startOf('day')._d];

      for(var i = 0; i < dayRange; i++) {
        var day = x_domain[i]
        x_domain.push(moment(new Date(day)).subtract(1, 'days').startOf('day')._d);
      }

      xScale
        .domain(x_domain)
        .rangeRoundBands([width - margin.left - margin.right, 0], xRoundBands);

      yScale
        .domain([lowBound, highBound])
        .range([height - margin.top - margin.bottom, 0])
        .nice();

      var  date_format = d3.time.format("%d %b");
      xAxis
        .ticks(d3.time.days(x_domain[0], x_domain[x_domain.length -1]).length)
            .tickFormat(function (d){
              var currentDate = moment(new Date(d))
              var startDate = moment(new Date(x_domain[0]))
              var endDate = moment(new Date(x_domain[x_domain.length - 1]))
              if (startDate.diff(endDate, 'days') <= 6) {
                return date_format(d)
              }
              else if (startDate.diff(currentDate, 'days') == 0  || startDate.diff(currentDate, 'days') % 6 == 0 ){
                return date_format(d)
              }
              else {
                return ''
              }
            })
            .tickSize(8);

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
          .attr("class", "title")
          .attr("x", width/2+23)
          .attr("y", titleHeight/2)
          .attr("font-size", "1.2em")
          .attr("text-anchor","middle")
          .attr("font-weight","bold")
          .text(title)
          .attr("fill", "purple");
      
      // x axis label
      svg.append("text")
        .attr("class", "x axis-label")
        .attr("text-anchor", "end")
        .attr("x", width/2 +43)
        .attr("y", height -5)
        .attr("font-size", "1.8em")
        .text("Date");
    
      // y axis label
      if(yLabel === "mood") {
        svg.append("text")
          .attr("class", "y axis-label")
          .attr("text-anchor", "end")
          .attr("x", -220)
          .attr("y", 0)
          .attr("dy", "1.4em")
          .attr("transform", "rotate(-90)")
          .attr("font-size", "1.2em")
          .text("Bad");
        svg.append("text")
          .attr("class", "y axis-label")
          .attr("text-anchor", "end")
          .attr("x", -115)
          .attr("y", 0)
          .attr("dy", "1.4em")
          .attr("transform", "rotate(-90)")
          .attr("font-size", "1.2em")
          .text("Neither");
        svg.append("text")
          .attr("class", "y axis-label")
          .attr("text-anchor", "end")
          .attr("x", -30)
          .attr("y", 0)
          .attr("dy", "1.4em")
          .attr("transform", "rotate(-90)")
          .attr("font-size", "1.2em")
          .text("Good");
      }
      else {
        svg.append("text")
          .attr("class", "y axis-label")
          .attr("text-anchor", "end")
          .attr("x", -90)
          .attr("y", 0)
          .attr("dy", "1em")
          .attr("transform", "rotate(-90)")
          .attr("font-size", "1.8em")
          .text(yLabel);
      
      }
      

      // draw average line
      var positiveValues = [], negativeValues = [];
      for (var i = 0; i < data.length; i++) {
        if (data[i][2] === false) {
          negativeValues.push(data[i][1]);
        } else {
          positiveValues.push(data[i][1]);
        }
      }
      if (positiveValues.length > 1) {
        svg.select(".average-lines").append("rect")
           .attr("class", "positive-average-line")
           .attr("width", width)
           .attr("height", averageLineThickness)
           .attr("x", xScale(0))
           .attr("y", yScale(d3.mean(positiveValues)) - averageLineThickness / 2)
           .attr("fill", "green");
      }
      if (negativeValues.length > 1) {
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
              .attr("x", function (d) { return X(d); })
              .attr("y", function (d, i) { return d[1] < 0 ? Y0() : Y(d); })
              .attr("width", xScale.rangeBand())
              .attr("height", function(d, i) { return Math.abs( Y(d) - Y0() ); })
              .on("click", function (d,i){
                if(d[3] !== false) {
                  dailyDrillModal(d);
                }
              })

    // x axis at the bottom of the chart
     g.select(".x.axis")
        .attr("transform", "translate(0," + (height - margin.top - margin.bottom) + ")")
        .call(xAxis.orient("bottom"))

      // Update the y-axis.
      g.select(".y.axis")
        .call(yAxis);
      
      d3.selectAll("g.x.axis g.tick line")
          .attr("y2", function(d){
            var currentDate = moment(new Date(d))
            var startDate = moment(new Date(x_domain[0]))
            var endDate = moment(new Date(x_domain[x_domain.length - 1]))
            if (startDate.diff(currentDate, 'days') == 0  || startDate.diff(currentDate, 'days') % 6 == 0 ){
              return 8
            }
            else {
              return 4
            }
        });
    // zero line
     g.select(".x.axis.zero")
        .attr("transform", "translate(0," + Y0() + ")")
        .call(xAxis.tickFormat("").tickSize(0));


    });
  }


  // The x-accessor for the path generator; xScale ∘ xValue.
  function X(d) {
    return xScale(d[0]);
  }

  function X0() {
    return xScale(0);
  }

  function Y0() {
    return yScale(0);
  }

  // The x-accessor for the path generator; yScale ∘ yValue.
  function Y(d) {
    return yScale(d[1]);
  }

  chart.appendText = function(container, helpText, count) {
    return container
           .append("text")
           .attr("y", count * 20 + 15)
           .text(helpText);
  };

  chart.drawLegend = function(legendContainer, legendItems, helpTextArray) {
    var count, svgContainer;

    count = 0;
    svgContainer = d3.select(legendContainer).append("svg");

    _.each(legendItems, function(item, index) {
      chart.legendKeyColor(svgContainer, item, count);
      chart.legendKeyText(svgContainer, item, count);
      return count++;
    });

    chart.addSpacing(svgContainer, count++)

    _.each(helpTextArray, function(text, index, list) {
      chart.appendText(svgContainer, text, count);
      return count++;
    });
    return chart;
  };

  chart.legendKeyColor = function(container, item, index) {
    return container
           .append("rect")
           .attr("y", index * 20)
           .attr("width", 15)
           .attr("height", 15)
           .attr("fill", item[1]);
  };

  chart.legendKeyText = function(container, item, index) {
    return container
           .append("text")
           .attr("x", 20)
           .attr("y", index * 20 + 15)
           .attr("fill", item[1])
           .text(item[0]);
  };

  chart.addSpacing = function(container, count) {
    container
      .append("rect")
      .attr("y", count * 20)
  };

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

function dailyDrillModal (data) {
  var guid = Math.floor((1 + Math.random()) * 0x10000)
               .toString(16)
               .substring(1);
  var charge = data[4] === "Emotion" ? (data[2] ? "Positive" : "Negative") : "";
  html = "";
  html += "<div class='modal fade' id='smallModal-"+guid+"' tabindex='-1' role='dialog' aria-labelledby='smallModal' aria-hidden='true'><div class='modal-dialog modal-sm'><div class='modal-content'><div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>"
  html += "<h4 class='modal-title' id='myModalLabel'><strong>"+charge+" "+data[4]+"</strong><br>"+ moment(new Date(data[0])).format('LL') + "</h4></div><div class='modal-body'>"
  $.each(data[3], function(i, d){
    var emotion = d[2] == undefined ? '' : d[2]
    html += "<p>"+moment(new Date(d[1])).format('hh:mm a')+": "+d[0]+" "+emotion+"</p>"
  });
  html += "</div><div class='modal-footer'><button type='button' class='btn btn-default' data-dismiss='modal'>Close</button></div></div></div></div>"
  $('body').append(html);
  $('#smallModal-'+guid).modal();
}

function activation (date) {
  return moment(new Date(date));
}

function Graph (moodData, emotionsData, phqData, container) {
  this.moodData = moodData;
  this.emotionsData = emotionsData;
  this.phqData = phqData;
  this.graphWidth = container.width() *.97;
  this.startDate = moment().subtract(6, 'days').startOf('day');
  this.endDate = moment().startOf('day');
  this.interval = 7;
  this.offset = 1;
}

function offsetInterval (graphParameters) {
  var startOffset = (graphParameters.interval * graphParameters.offset) - 1;
  var endOffset = graphParameters.offset === 1 ? 0 : graphParameters.interval * (graphParameters.offset-1)
  graphParameters.startDate = moment().subtract(startOffset, 'days').startOf('day');
  graphParameters.endDate = moment().subtract(endOffset, 'days').startOf('day');
}

function appendDateRange (graphParameters) {
  $('div#date-range strong').empty().append(graphParameters.startDate.format('LL')+' / '+graphParameters.endDate.format('LL'));
}

function maxOffset (activationDate, interval) {
  return Math.ceil(moment().diff(activationDate, 'days')/interval)
}
