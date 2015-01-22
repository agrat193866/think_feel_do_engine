;(function () {
  "use strict";

  var dates;

  window.dailyBreakdown = function (completed_activities, numOfDays) {
    var color, colorObj, data, getBucket, height, load_breakdown, margin, parse_time, width, x, xAxis, y;
    load_breakdown = function (title, data) {
      var averageHours, cleanDay, cleanWeek, container, flatten, formatAVizTime, formatXAxisLabels, grabLastXDays, height, isInt, margin, padStacks, sortDateArray, splitDateArray, svg, updateStacked, width, x, xAxis, y;

      formatXAxisLabels = function (formattedDate) {
        if (width >= (dates.length + 1) * 125) {
          return formattedDate;
        }
        if (width >= (dates.length + 1) * 50) {
          return formattedDate.substr(formattedDate.indexOf(",") + 1);
        }
        return formattedDate.substr(0, 1);
      };

      averageHours = function (list) {
        var byDay;
        byDay = [];
        _.each(list, function (daily) {
          _.each(daily, function (hourly) {
            var accomplishmentArray, avgAccomplishment, avgPleasure, mergeArray, mergedActivity, pleasureArray;
            if (hourly === null) {
              return;
            }
            mergeArray = [];
            $.grep(daily, function (activity, location) {
              if (activity.start_time === hourly.start_time && activity.end_time === hourly.end_time) {
                return mergeArray.push(location);
              }
            });
            if (mergeArray.length > 1) {
              pleasureArray = [];
              accomplishmentArray = [];
              mergedActivity = {
                start_time: hourly.start_time,
                start_date: hourly.start_date,
                end_time: hourly.end_time,
                time_diff: hourly.time_diff,
                start_datetime: hourly.start_datetime,
                end_datetime: hourly.end_datetime,
                start_hour: new Date(hourly.start_datetime).getHours(),
                end_hour: new Date(hourly.end_datetime).getHours(),
                start_minutes: new Date(hourly.start_datetime).getMinutes(),
                end_minutes: new Date(hourly.end_datetime).getMinutes()
              };
              _.each(mergeArray, (function (i) {
                pleasureArray.push((this[i].actual_pleasure > -1 ? this[i].actual_pleasure : 0));
                accomplishmentArray.push((this[i].actual_accomplishment > -1 ? this[i].actual_accomplishment : 0));
                if (mergedActivity.title) {
                  mergedActivity.title += "/" + this[i].title;
                } else {
                  mergedActivity.title = this[i].title;
                }
                if (mergedActivity.activity_type_id) {
                  mergedActivity.activity_type_id += "," + this[i].activity_type_id;
                } else {
                  mergedActivity.activity_type_id = this[i].activity_type_id;
                }
                this[i] = null;
              }), daily);
              daily = daily.filter(Boolean);
              avgPleasure = Math.floor(pleasureArray.reduce(function (prev, cur) {
                return prev + cur;
              }) / pleasureArray.length);
              avgAccomplishment = Math.floor(accomplishmentArray.reduce(function (prev, cur) {
                return prev + cur;
              }) / pleasureArray.length);
              mergedActivity.actual_accomplishment = avgAccomplishment;
              mergedActivity.actual_pleasure = avgPleasure;
              mergedActivity.bucket = getBucket(avgPleasure, avgAccomplishment);
              daily.push(mergedActivity);
            } else {
              hourly.start_time = hourly.start_time || -1;
              hourly.end_time = hourly.end_time || hourly.start_time + 1;
              hourly.time_diff = hourly.time_diff || 0;
              hourly.start_datetime = hourly.start_datetime || Date.now();
              hourly.end_datetime = hourly.end_datetime || Date.now();
              hourly.start_hour = hourly.start_hour || new Date(hourly.start_datetime).getHours();
              hourly.end_hour = hourly.end_hour || new Date(hourly.end_datetime).getHours();
              hourly.start_minutes = hourly.start_minutes || new Date(hourly.start_datetime).getMinutes();
              hourly.end_minutes = hourly.end_minutes || new Date(hourly.end_datetime).getMinutes();
            }
          });
          return byDay.push(daily);
        });
        return byDay;
      };
      cleanDay = function (day) {
        return _.each(day, function (activity, hour) {
          if (activity.activity_type_id === null) {
            day.splice(hour, 1);
          }
          if (activity.start_time === activity.end_time) {
            return day.splice(hour, 1);
          }
        });
      };
      sortDateArray = function (a, b) {
        if (a.start_datetime < b.start_datetime) {
          return -1;
        }
        if (a.start_datetime > b.start_datetime) {
          return 1;
        }
        return 0;
      };
      splitDateArray = function (arr) {
        var fixedArray, j, lastHour;
        if ((arr === null) || arr.length < 1) {
          return;
        }
        j = 0;
        lastHour = arr[0];
        fixedArray = [[arr[0]]];
        _.each(arr, function (hour, index) {
          if (index > 0) {
            if (lastHour.start_date === hour.start_date) {
              fixedArray[j].push(hour);
            } else {
              lastHour = hour;
              fixedArray.push([]);
              j++;
              fixedArray[j].push(hour);
            }
          }
        });
        return fixedArray;
      };
      flatten = function (list) {
        var flattenedArray;
        flattenedArray = [];
        _.each(list, function (day) {
          return _.each(day, function (hour) {
            return flattenedArray.push(hour);
          });
        });
        return flattenedArray;
      };
      cleanWeek = function (list) {
        var cleanedWeek;
        cleanedWeek = [];
        _.each(list, function (day, index) {
          cleanDay(day);
          if (day.length > 0) {
            return cleanedWeek.push(day);
          }
        });
        return cleanedWeek;
      };
      padStacks = function (list) {
        var max;
        max = d3.max(list, function (list) {
          return list.length;
        });
        _.each(list, function (data, index) {
          var _results;
          _results = [];
          while (data.length < max) {
            _results.push(data.push(data[data.length - 1]));
          }
          return _results;
        });
        return list;
      };
      grabLastXDays = function (data, x) {
        var d;
        d = splitDateArray(data.sort(sortDateArray));
        return d.slice(-x);
      };
      isInt = function (n) {
        return n % 1 === 0;
      };
      formatAVizTime = function (d) {
        if (isInt(d)) {
          if (d === 12) {
            return "12 PM";
          }
          if (d === 0) {
            return "12 AM";
          }
          if (d > 12) {
            return (d - 12) + " PM";
          } else {
            return d + " AM";
          }
        }
      };
      updateStacked = function (numOfDays, data) {
        var bucket, bucket_rect, color_g, earliestDateTimeHour, flat_list, grouped, latestDateTimeHour, latestHour, legend, main_list, positionHour, sizeHour, stack, svg_update, tip, yAxis, yRange;
        if (typeof svg === "undefined" || svg === null) {
          return;
        }
        if (data.length === 0) {
          $("#activities-chart").html("<div class='alert alert-info'><strong>Notice!</strong> No activities were completed during this " + numOfDays + "-day period.</div>");
        } else {
          data = grabLastXDays(data, numOfDays);
          grouped = _.groupBy(data, function (d) {
            return d.bucket;
          });
          main_list = [];
          main_list = averageHours(data);
          padStacks(main_list);
          stack = d3.layout.stack().offset("silhouette").x(function (d) {
            return d.start_date;
          }).y(function (d) {
            return d.time_diff;
          });
          stack(main_list);
          main_list = cleanWeek(main_list);
          flat_list = flatten(main_list);
          dates = _.uniq(_.pluck(flat_list, "start_date"));
          color.domain(["high pleasure/ high accomplishment", "low pleasure/ low accomplishment", "high pleasure/ low accomplishment", "low pleasure/ high accomplishment"]);
          latestHour = d3.max(main_list, function (d) {
            return d3.max(d, function (d) {
              return d.y0 + d.y;
            });
          });
          latestDateTimeHour = null;
          earliestDateTimeHour = null;
          _.each(main_list, function (day) {
            _.each(day, function (hour) {
              if ((!(earliestDateTimeHour !== null)) || hour.start_hour < earliestDateTimeHour.getHours()) {
                earliestDateTimeHour = new Date(hour.start_datetime);
              }
              if ((!(latestDateTimeHour !== null)) || hour.end_hour > latestDateTimeHour.getHours()) {
                latestDateTimeHour = new Date(hour.end_datetime);
              }
            });
          });
          x.domain(dates);
          y.domain([earliestDateTimeHour.getHours(), (latestDateTimeHour.getHours() === 23 ? latestDateTimeHour.getHours() : latestDateTimeHour.getHours() + 1)]);
          yRange = d3.scale.linear().range([0, height]).domain([earliestDateTimeHour.getHours(), (latestDateTimeHour.getHours() === 23 ? latestDateTimeHour.getHours() : latestDateTimeHour.getHours() + 1)]);
          yAxis = d3.svg.axis().scale(yRange).orient("left").tickFormat(formatAVizTime);
          svg.append("g").attr("class", "y axis").attr("transform", "translate(0,0)").call(yAxis);
          yAxis = d3.svg.axis().scale(yRange).orient("right").tickFormat(formatAVizTime);
          svg.append("g").attr("class", "y axis").attr("transform", "translate(" + width + ",0)").call(yAxis);
          svg.append("g").classed("grid y_grid", true).call(yAxis.tickSize(width, 0, 0).tickFormat(""));
          svg.append("g").attr("class", "x axis").attr("transform", "translate(0,0)").call(xAxis);
          svg_update = svg.selectAll(".bucket").data(main_list, function (d, i) {
            return d + i;
          });
          svg_update.exit().remove();
          bucket = svg_update.enter().append("g").attr("class", "bucket").attr("title", function (d, i) {
            return d.time_diff;
          });
          bucket_rect = bucket.selectAll("g").data(function (d, i) {
            return d.map(function (k) {
              k.parent_index = i;
              return k;
            });
          }).enter().append("g");
          sizeHour = function (hourLength) {
            var sizeOfAnHour;
            sizeOfAnHour = height / ((latestDateTimeHour.getHours() + 1) - earliestDateTimeHour.getHours());
            return hourLength * sizeOfAnHour;
          };
          positionHour = function (hourStart) {
            return sizeHour(hourStart) - sizeHour(earliestDateTimeHour.getHours());
          };
          tip = d3.select("body").append("div").attr("class", "tooltip").style("opacity", 0);
          bucket_rect.append("rect").attr("width", x.rangeBand()).attr("x", function (d, i) {
            $("body").append("<div class='" + d.title.replace(/\//g, "_") + " " + d.start_time + "' style='position: absolute; left:-1000px; top: -1000px; height:0; width:0;'><span class='bold'>" + d.title + "</span><br/><br/>" + d.start_time + " - " + d.end_time + "<br/><br/>" + "<span class='bold'>" + "Pleasure: </span>" + d.actual_pleasure + "<br/>" + "<span class='bold'>" + "Accomplishment: </span>" + d.actual_accomplishment + "</div>");
            return x(d.start_date);
          }).attr("stroke-width", 1).attr("stroke", "rgb(192,192,192)").attr("y", function (d) {
            return positionHour(d.start_hour + (d.start_minutes / 60));
          }).attr("height", function (d) {
            return sizeHour((d.end_hour + (d.end_minutes / 60)) - (d.start_hour + (d.start_minutes / 60))) || 0;
          }).style("fill", function (d) {
            if (typeof d.bucket !== "undefined") {
              return colorObj[d.bucket];
            } else {
              return "#000000";
            }
          }).on("mouseover", function (d) {
            tip.transition().duration(200).style("opacity", 0.9);
            tip.html("<span class='bold'>" + d.title + "</span><br/><br/>" + d.start_time + " - " + d.end_time + "<br/><br/>" + "<span class='bold'>" + "Pleasure: </span>" + d.actual_pleasure + "<br/>" + "<span class='bold'>" + "Accomplishment: </span>" + d.actual_accomplishment).style("left", d3.event.pageX + "px").style("top", (d3.event.pageY - 28) + "px");
          }).on("mouseout", function (d) {
            tip.transition().duration(500).style("opacity", 0);
          });
          d3.select(".legend").remove();
          legend = svg.append("g").attr("class", "legend").attr("transform", "translate(0," + (height + 10) + ")");
          if ($(window).innerWidth() > 1000) {
            color_g = legend.selectAll("g").data(color.domain()).enter().append("g").attr("transform", function (d, i) {
              return "translate(" + (20 + (i * 200)) + ",0)";
            });
            color_g.append("rect").attr("width", "20px").attr("height", "20px").attr("fill", function (d) {
              return colorObj[d];
            }).attr("stroke", "black");
            return color_g.selectAll("text").data(function (d) {
              return d.split("/");
            }).enter().append("text").attr("dx", "35px").attr("dy", function (d, i) {
              return i * 20 + 5;
            }).text(String);
          } else {
            color_g = legend.selectAll("g").data(color.domain()).enter().append("g").attr("transform", function (d, i) {
              return "translate(0," + (20 + (i * 50)) + ")";
            });
            color_g.append("rect").attr("width", "20px").attr("height", "20px").attr("fill", function (d) {
              return colorObj[d];
            }).attr("stroke", "black");
            return color_g.selectAll("text").data(function (d) {
              return d.split("/");
            }).enter().append("text").attr("dx", "35px").attr("dy", function (d, i) {
              return i * 20 + 5;
            }).text(String);
          }
        }
      };
      $("#activities-chart").children().remove();
      margin = {
        top: 20,
        right: 50,
        bottom: 50,
        left: 50
      };
      width = $("#do-viz-wrapper").width() - margin.left - margin.right;
      height = 500 - margin.top - margin.bottom;
      if ($(window).innerWidth() <= 1000) {
        margin.bottom = 220;
        height = 500 - margin.top - margin.bottom;
      }
      x = d3.scale.ordinal().rangeRoundBands([0, width], 0.4);
      xAxis = d3.svg.axis().scale(x).orient("top").tickFormat(formatXAxisLabels);
      y = d3.scale.linear().rangeRound([200, 0]);
      container = d3.select("#activities-chart").append("div");
      svg = container.append("svg").attr("class", "activity_viz").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
      updateStacked(numOfDays, data);
      $("#activities-chart div").prepend("<p class=\"text-center\">"+numOfDays+"-Day View</p>");
    };
    getBucket = function (pleasure, accomplishment) {
      if (pleasure >= 5 && accomplishment >= 5) {
        return "high pleasure/ high accomplishment";
      } else if (pleasure < 5 && accomplishment < 5) {
        return "low pleasure/ low accomplishment";
      } else if (pleasure >= 5 && accomplishment < 5) {
        return "high pleasure/ low accomplishment";
      } else {
        return "low pleasure/ high accomplishment";
      }
    };
    parse_time = d3.time.format("%A, %m/%d");
    margin = {
      top: 20,
      right: 50,
      bottom: 30,
      left: 40
    };
    width = 832 - margin.left - margin.right;
    height = 500 - margin.top - margin.bottom;
    x = d3.scale.ordinal().rangeRoundBands([0, width], 0.4);
    xAxis = d3.svg.axis().scale(x).orient("top");
    y = d3.scale.linear().rangeRound([200, 0]);
    colorObj = {
      "high pleasure/ high accomplishment": "#83F056",
      "low pleasure/ low accomplishment": "#F25757",
      "high pleasure/ low accomplishment": "#FCE25B",
      "low pleasure/ high accomplishment": "#59C2F7"
    };
    color = d3.scale.ordinal().range(["#F25757", "#FCE25B", "#59C2F7", "#83F056", "#ff7f00", "#ffff33", "#a65628"]);
    xAxis = d3.svg.axis().scale(x).orient("top");
    data = completed_activities.map(function (d) {
      d.start_datetime = (d.start_time !== null ? Date.parse(d.start_time) : Date.now());
      if (d.end_time === null) {
        d.end_datetime = new Date(d.start_datetime).setHours(new Date(d.start_datetime).getHours() + 1);
      } else {
        d.end_datetime = Date.parse(d.end_time);
      }
      d.predicted_pleasure = (d.predicted_pleasure_intensity !== null ? d.predicted_pleasure_intensity : -1);
      d.predicted_accomplishment = (d.predicted_accomplishment_intensity !== null ? d.predicted_accomplishment_intensity : -1);
      d.actual_pleasure = (d.actual_pleasure_intensity !== null ? d.actual_pleasure_intensity : -1);
      d.actual_accomplishment = (d.actual_accomplishment_intensity !== null ? d.actual_accomplishment_intensity : -1);
      d.completed = d.is_complete === true;
      d.start_date = parse_time(new Date(d.start_datetime));
      d.bucket = getBucket(d.actual_pleasure, d.actual_accomplishment);
      if (!isNaN(d.start_datetime) && !isNaN(d.end_datetime)) {
        d.time_diff = (d.end_datetime - d.start_datetime) / 1000;
      } else {
        d.time_diff = 0;
      }
      d.start_time = d3.time.format("%I:%M %p")(new Date(d.start_datetime));
      d.end_time = d3.time.format("%I:%M %p")(new Date(d.end_datetime));
      d.discrepancy_pleasure = (d.predicted_pleasure > -1 ? Math.abs(d.actual_pleasure - d.predicted_pleasure) : 0);
      d.discrepancy_accomplishment = (d.predicted_accomplishment > -1 ? Math.abs(d.actual_accomplishment - d.predicted_accomplishment) : 0);
      return d;
    });
    data = _.sortBy(data, function (d) {
      return d.start_datetime;
    });
    load_breakdown("Daily Breakdown", data);
  };
}());