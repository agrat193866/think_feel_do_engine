window.mediaAccessCreate = function (mediaType, mediaLink, slideId) {
  var postPath = "/participants/media_access_events"
  $('.jp-play').on("click", function (){
    $.ajax({
      type: "POST",
      url: postPath,
      data: { media_access_event: { media_type: mediaType, media_link: mediaLink, bit_core_slide_id: slideId }}
    }).
    done(function(data) {
      bindStopEvent(data.media_access_event_id);
      bindEndedEvent(data.media_access_event_id);
    });
  });
}

window.mediaAccessUpdate = function(mediaAccessEventId) {
  var putPath = "/participants/media_access_events/"+mediaAccessEventId
  $.ajax({
    type: "PUT",
    url: putPath,
    data: { media_access_event: { id: mediaAccessEventId, end_time: new Date() }}
  });
}

window.bindStopEvent = function (mediaAccessEventId) {
  $('.jp-stop').on("click", function() {
    mediaAccessUpdate(mediaAccessEventId);
  });
}

window.bindEndedEvent = function (mediaAccessEventId) {
  $("#jquery_jplayer_1").bind($.jPlayer.event.ended, function(){
    mediaAccessUpdate(media_access_event_id);
  });
}
