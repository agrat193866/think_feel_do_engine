(function() {
  // HT http://stackoverflow.com/a/4029518
  // Modified to trigger keepalive calls.
  var idleTime = 0;
  var keepAlive = false;

  $(document).ready(function () {
    //Increment the idle time counter every minute.
    var idleInterval = setInterval(timerIncrement, 60000); // 1 minute
    //Increment the keep alive time counter every five minutes.
    var keepAliveCheckInterval = setInterval(keepAliveCheck, 300000); // 5 minutes

    //Zero the idle timer on mouse movement.
    $(this).mousemove(function (e) {
      idleTime = 0;
      keepAlive = true;
    });
    $(this).keypress(function (e) {
      idleTime = 0;
      keepAlive = true;
    });
  });

  function timerIncrement() {
    idleTime = idleTime + 1;
    if (idleTime >= 25) { // 25 minutes
      window.location.reload();
    }
  }

  function keepAliveCheck() {
    if(keepAlive) {
      $.ajax({
        async: false,
        dataType: "script",
        type: "GET",
        url: "/keepalive/"
      });
    }
    keepAlive = false;
  }
})();
