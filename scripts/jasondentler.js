$(function () {
	var currentYear = new Date().getFullYear();
	$('.post-date .year').each(function () {
		var year = $(this).text();
		if (year == currentYear) {
			$(this).hide();
		}
	})
})