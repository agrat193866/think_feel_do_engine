(function() {
  'use strict';

  describe('sc.attachCollapsableIcons', function() {
    describe('toggling', function() {
      var html, $jasmine_content;

      beforeEach(function() {
        $jasmine_content = $('#jasmine_content');
        html = '' +
          '<a data-toggle="collapse" data-parent="#accordion" href="#activity-summary">' +
            '<i class="fa fa-caret-right"></i></a><div id="activity-summary" class="collapse">' +
          '</div>';
        $jasmine_content.append(html);
      });

      afterEach(function() {
        $jasmine_content.empty();
      });

      it('udpates the class from "right" to "down" and back to "right" when toggling', function() {
        sc.attachCollapsableIcons('#activity-');

        expect($jasmine_content.find('i.fa-caret-right').length).toEqual(1);
        expect($jasmine_content.find('i.fa-caret-down').length).toEqual(0);

        $('#activity-summary').trigger('show.bs.collapse');

        expect($jasmine_content.find('i.fa-caret-right').length).toEqual(0);
        expect($jasmine_content.find('i.fa-caret-down').length).toEqual(1);

        $('#activity-summary').trigger('hide.bs.collapse');

        expect($jasmine_content.find('i.fa-caret-right').length).toEqual(1);
        expect($jasmine_content.find('.fa-caret-down').length).toEqual(0);
      });
    });
  });
})();