(function() {
  'use strict';
  
  describe('sc.filterEmotionMoodViz', function() {
    beforeEach(function() {
      sc.drawGraphs = function() {};
      sc.offsetInterval = function() {};
    });
    
    describe('when day filter input is clicked', function() {
      beforeEach(function() {
        spyOn(sc, 'offsetInterval');
        spyOn(sc, 'drawGraphs');
      });
      
      it('re/draws the graph', function() {
        $("div").append('<label class="interval"></label>');
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
      });
      
      it('re/draws the graph', function() {
        $("div").append('<a class="offset"></a>');
        sc.filterEmotionMoodViz({});
        $('a.offset').trigger('click');

        expect(sc.offsetInterval).toHaveBeenCalled();
        expect(sc.drawGraphs).toHaveBeenCalled();
      });
    });
  });
})();