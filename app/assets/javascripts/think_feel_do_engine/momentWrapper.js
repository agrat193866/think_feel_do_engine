(function(momentFn) {
  'use strict';

  window.sc = window.sc || {};

  function momentService(momentjs) {
    return momentjs;
  };

  return window.sc.momentjs = momentService(momentFn);
})(moment);