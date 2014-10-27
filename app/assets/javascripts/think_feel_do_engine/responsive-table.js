$(document).on('page:load ready', function() {

	var addOrRemoveHide = function() {
		if ($(window).width() < 768) {
			$('table.responsive tr td').not(':first-child').addClass('hide');
		}
		else {
			$('table.responsive tr td').removeClass('hide');
		}
	};

	addOrRemoveHide();

	var headerText = [];
	var headers = document.querySelectorAll("table.responsive th");
	var tableRows = $('table.responsive tbody tr');

	$.each(headers, function(idx) {
		headerText.push(headers[idx].textContent);
	})
	$.each(tableRows, function(idx, el) {
		var tableCells = $(el).children('td');
		$.each(tableCells, function(idx) {
			tableCells[idx].setAttribute('data-th', headerText[idx]);
		})
	})
	
	$('table.responsive tr td:first-child').on('click', function() {
		if ( $(window).width() < 768 ) {
			var siblings = $(this).siblings();
			if ($(siblings).hasClass('hide')) {
				$(siblings).removeClass('hide');
			}
			else {
				$(siblings).addClass('hide');
			}
		}
	});

	$(window).on('resize', addOrRemoveHide);

});