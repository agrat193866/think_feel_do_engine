window.audioStream = function (track, client_id) {
  SC.initialize({
    client_id: client_id
  });
  SC.stream('/tracks/'+track, function (result) {
    result.url;
  });
};
