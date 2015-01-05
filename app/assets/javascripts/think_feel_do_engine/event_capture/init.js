;(function() {
  "use strict";

  var eventClient;

  $(document).on("ready, page:change", function() {
    logRenderEvent();

    // add listeners to clickable elements
    $(document).on("click", "a, button, input, textarea, option, .btn", logClickEvent);
  });

  // set the endpoint
  eventClient = new EventCaptureClient("/event_capture/events");

  function logRenderEvent() {
    var payload;

    payload = {
      currentUrl: window.location.href,
      headers: grabHeaders(),
      ua: window.navigator.userAgent
    };
    eventClient.log({ kind: "render", payload: payload });
  }

  function logClickEvent(event) {
    var targetElement, payload;

    targetElement = $(event.target);

    if (targetElement.data("clickTimestamp") === event.timeStamp) {
      // this click has already been logged
      return;
    } else {
      // log this click
      targetElement.data("clickTimestamp", event.timeStamp);
    }

    payload = {
      currentUrl: window.location.href,
      buttonHtml: outerHtml(targetElement),
      parentHtml: outerHtml(targetElement.parent()),
      headers: grabHeaders()
    };
    eventClient.log({ kind: "click", payload: payload });
  }

  function grabHeaders() {
    var headers = $("h1, h2").text().split(/\s\s+/);
    var cleaned = [];

    for (var i = 0; i < headers.length; i++) {
      if (headers[i] !== "") {
        cleaned.push(headers[i]);
      }
    }

    return cleaned;
  }

  function outerHtml(el) {
    // because .outerHTML() may not be implemented in all target browsers
    return el.clone().wrap("<p>").parent().html();
  }
})();
