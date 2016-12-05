var editor = ace.edit("editor");
editor.setTheme("ace/theme/chrome");
editor.session.setMode("ace/mode/assembly_pru");

$('#compile').click(function() {
	var pru_num = $('#compile').attr('pru-num');
	var src = editor.getValue();
	$.post("pru/" + pru_num + "/compile", { "src": src }, function(data) {
		alert("ok");
	});
});
