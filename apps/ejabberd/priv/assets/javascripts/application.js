$(document).ready(function() {
	$('.main-content.auth').hide().delay(200).fadeIn('1000');
	$('#change_subject').click(function() {
		$('#form_setSubject').addClass('open');
	});

	$('#form_setSubject button.close').click(function () {
		$('#form_setSubject').removeClass('open');
	});
});