'use strict';

sc.attachCollapsableIcons = function(idPrex) {
  $('[href^=' + idPrex + ']').each(function(index, value, list) {
    sc.collapsableIcon(value.hash);
  });
};

sc.collapsableIcon = function(anchorTag) {
  $(anchorTag).on('show.bs.collapse', function(event) {
    $('[href^=#' + event.currentTarget.id + ']').find('.fa-caret-right').addClass('fa-caret-down').removeClass('fa-caret-right');
  });
  $(anchorTag).on('hide.bs.collapse', function(event) {
    $('[href^=#' + event.currentTarget.id + ']').find('.fa-caret-down').addClass('fa-caret-right').removeClass('fa-caret-down');
  });
};
