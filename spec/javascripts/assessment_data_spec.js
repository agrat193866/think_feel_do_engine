//= require assessment_data
describe('sc.assessmentData', function() {
  it('should not throw an exception with empty data', function() {
  $("body").append('<div id="vizcontainer" class="linechart" style="display:none;">' +
                     '<div id="axisL" class="axis"></div>' +
                     '<div id="graphArea"></div>' +
                     '<div id="legend"></div>' +
                     '<div id="legend_hidden"></div>' +
                     '<div id="axisR" class="axis"></div>' +
                  '</div>');
    expect(function() {
      sc.assessmentData([[1403028743, 1]], [], []);
    }).not.toThrow();
    expect(function() {
      sc.assessmentData([], [["envy", [[1403028743, 1]]]], []);
    }).not.toThrow();
    expect(function() {
      sc.assessmentData([], [], [[1403028743, 1]]);
    }).not.toThrow();
    expect(function() {
      sc.assessmentData([], [], []);
    }).not.toThrow();
    $("#vizcontainer").remove();
  });
});
