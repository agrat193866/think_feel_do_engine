window.mediaAccessCreate = function (media_type, media_link) {
  var postPath = "/participants/media_access_events"
  $('.jp-play').on("click", function (){
    $.ajax({
      type: "POST",
      url: postPath,
      data: { media_access_event: { media_type: media_type, media_link: media_link }}
    }).
    done(function(data) {
      bindStopEvent(data.media_access_event_id);
      bindEndedEvent(data.media_access_event_id);
    });
  });
}

window.mediaAccessUpdate = function(media_access_event_id) {
  var mediaAccessEventId = media_access_event_id;
  var putPath = "/participants/media_access_events/"+mediaAccessEventId
  $.ajax({
    type: "PUT",
    url: putPath,
    data: { media_access_event: { id: mediaAccessEventId, end_time: new Date() }}
  });
}

window.bindStopEvent = function (media_access_event_id) {
  $('.jp-stop').on("click", function() {
    mediaAccessUpdate(media_access_event_id);
  });
}

window.bindEndedEvent = function (media_access_event_id) {
  $("#jquery_jplayer_1").bind($.jPlayer.event.ended, function(){
    mediaAccessUpdate(media_access_event_id);
  });
}
