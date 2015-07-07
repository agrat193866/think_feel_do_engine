(function() {
  'use strict';
  
  describe('sc.filterEmotionMoodViz', function() {
    var $jasmine_content;

    beforeEach(function() {
      sc.drawGraphs = function() {};
      sc.offsetInterval = function() {};
      $jasmine_content = $('#jasmine_content');
    });
    
    afterEach(function() {
      $jasmine_content.empty();
    });

    describe('when day filter input is clicked', function() {
      beforeEach(function() {
        spyOn(sc, 'offsetInterval');
        spyOn(sc, 'drawGraphs');
        $jasmine_content.append('<label class="interval"></label>');
      });
      
      afterEach(function() {
        $jasmine_content.empty();
      });

      it('re/draws the graph', function() {
        sc.filterEmotionMoodViz({});
        $('label.interval').trigger('click');

        expect(sc.offsetInterval).toHaveBeenCalled();
        expect(sc.drawGraphs).toHaveBeenCalled();

        $('label.interval').trigger('click');

        expect(sc.offsetInterval).toHaveBeenCalled();
        expect(sc.drawGraphs).toHaveBeenCalled();
      });
    });

    describe('when pagination buttons are clicked', function() {
      beforeEach(function() {
        spyOn(sc, 'offsetInterval');
        spyOn(sc, 'drawGraphs');
        $jasmine_content.append('<a class="offset"></a>');
      });

      it('re/draws the graph', function() {
        sc.filterEmotionMoodViz({});
        $('a.offset').trigger('click');

        expect(sc.offsetInterval).toHaveBeenCalled();
        expect(sc.drawGraphs).toHaveBeenCalled();
      });
    });
  });
})();