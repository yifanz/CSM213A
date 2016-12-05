% rebase('base.tpl', title='PRU Editor')
<div id="editor-container">
	<div id="editor">function foo(items) {
		var x = "PRU num {{pru_num}}";
	</div>
</div>

<div id="console-container">
	<button id="compile" class="button" pru-num="{{pru_num}}">Compile</button>
</div>
