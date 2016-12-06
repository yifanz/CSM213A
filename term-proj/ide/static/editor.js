$(document).ready(function() {
	var editor = ace.edit("editor");
	editor.setTheme("ace/theme/solarized_light");
	editor.session.setMode("ace/mode/assembly_pru");

	var asm_editor = ace.edit("asm-editor");
	asm_editor.setTheme("ace/theme/dawn");
	asm_editor.session.setMode("ace/mode/assembly_pru");

	$('#compile').click(function() {
		var pru_num = $('#compile').attr('pru-num');
		var src = editor.getValue();
		$.post("pru/" + pru_num + "/compile", { "src": src }, function(data) {
			console.log("compile");
		});
	});

	function update_terminal() {
		var pru_num = $('#compile').attr('pru-num');
		$.get("pru/" + pru_num + "/out", function(data) {
			if (data) {
				$("#console").append(data);
				console.log(data);
			}
			window.setTimeout(update_terminal, 100);
		}).fail(function() { window.setTimeout(update_terminal, 5000); });
	}

	window.setTimeout(update_terminal, 100);
});
