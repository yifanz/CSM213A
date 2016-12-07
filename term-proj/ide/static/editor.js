$(document).ready(function() {
	var editor = ace.edit("editor");
	editor.setTheme("ace/theme/solarized_light");
	editor.session.setMode("ace/mode/assembly_pru");

	var asm_editor = ace.edit("asm-editor");
	asm_editor.setTheme("ace/theme/dawn");
	asm_editor.session.setMode("ace/mode/assembly_pru");

	$('#compile').click(function() {
		var asm_src = compile(editor.getValue());
		asm_editor.setValue(asm_src);
	});

	$('#run').click(function() {
		var pru_num = $('#run').attr('pru-num');
		var src = asm_editor.getValue();
		$.post("pru/" + pru_num + "/run", { "src": src }, function(data) {
			console.log("run");
		});
	});

	$('#stop').click(function() {
		var pru_num = $('#stop').attr('pru-num');
		$.ajax({
			url: "pru/" + pru_num + "/stop", 
			type: "PUT"
		});
	});

	function update_terminal() {
		var pru_num = $('#run').attr('pru-num');
		$.get("pru/" + pru_num + "/out", function(data) {
			if (data) {
				var terminal = $("#console");
				terminal.append(data);
				var height = terminal[0].scrollHeight;
				terminal.scrollTop(height);
				console.log(data);
			}
			window.setTimeout(update_terminal, 100);
		}).fail(function() { window.setTimeout(update_terminal, 5000); });
	}

	window.setTimeout(update_terminal, 100);
});
