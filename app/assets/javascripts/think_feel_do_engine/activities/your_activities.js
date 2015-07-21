'use strict';

sc.attachCollapsableIcons = function(idPrex, openPanelsOnPageLoadArray) {
  $('[href^=' + idPrex + ']').each(function(index, value, list) {
    sc.collapsableIcon(value.hash);
  });
  (openPanelsOnPageLoadArray || []).forEach(function(value) {
    var id = '#activity-' + value;

    $(id).addClass('in');
    sc.openOnDefault(id);
  });
};

sc.collapsableIcon = function(anchorTag) {
  var POUND_SIGN = '#';

  $(anchorTag).on('show.bs.collapse', function(event) {
    sc.openOnDefault(POUND_SIGN + event.currentTarget.id);
  });
  $(anchorTag).on('hide.bs.collapse', function(event) {
    $('[href^=' + POUND_SIGN + event.currentTarget.id + ']').find('.fa-caret-down').addClass('fa-caret-right').removeClass('fa-caret-down');
  });
};

sc.openOnDefault = function(id) {
  $('[href^=' + id + ']').find('.fa-caret-right').addClass('fa-caret-down').removeClass('fa-caret-right');
};
