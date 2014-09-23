$(document).on("page:change", function() {
  $(".menu-trigger").click(function () {
    $("body").toggleClass("mobile-menu");
  });
});