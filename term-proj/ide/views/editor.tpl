% rebase('base.tpl', title='PRU Editor', pru_num=pru_num)

<div class="editor-container">
	<div id="editor" class="editor">function foo(items) {
		var x = "PRU num {{pru_num}}";
	</div>
</div>

<div class="editor-container asm-editor-container">
	<div id="asm-editor" class="editor">function foo(items) {
		var x = "PRU num {{pru_num}}";
	</div>
</div>

<div id="console-container">
	<pre id="console"></pre>
</div>
