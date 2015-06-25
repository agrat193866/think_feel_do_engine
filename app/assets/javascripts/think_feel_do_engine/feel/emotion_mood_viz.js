(function() {
  'use strict';

  window.sc = window.sc || {};

  sc.filterEmotionMoodViz = function (graphParameters) {
    $('label.interval').on('click', function(event) {
      var input;

      input = $(event.currentTarget).find('input[type="radio"]');
      graphParameters.interval = input.val();
      graphParameters.offset = 1;
      sc.offsetInterval(graphParameters);
      sc.drawGraphs();
    });

    $('.offset').on('click', function(event) {
      event.preventDefault();

      if ($(this).attr('id') === 'next' && graphParameters.offset === 1) {
        return null;
      } else if ($(this).attr('id') === 'previous' && graphParameters.offset === maxOffset(activationDate, graphParameters.interval)) {
        return null;
      } else {
        graphParameters.offset += parseInt($(this).data('value'), 10);
        sc.offsetInterval(graphParameters);
        sc.drawGraphs();
      }
    });
  };
})();