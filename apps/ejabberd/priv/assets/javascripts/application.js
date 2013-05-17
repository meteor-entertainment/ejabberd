$(document).ready(function() {
	$('#change_subject').click(function() {
		$('#form_setSubject').addClass('open');
	});

	$('#form_setSubject button.close').click(function () {
		$('#form_setSubject').removeClass('open');
	});
});