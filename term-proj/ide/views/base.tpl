<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta charset="utf-8">
	<title>{{title or 'PRU'}}</title>
	<meta name="description" content="Beaglebone black PRU">
	<meta name="author" content="Yi-Fan Zhang">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="static/editor.css">
	<link rel="shortcut icon" href="">
	<style>

	</style>
</head>
<body>
	<div class="menu-bar">
		<button id="compile" class="button" pru-num="{{pru_num}}">Compile</button>
	</div>
	<div class="body-container">
		{{!base}}
	</div>
	<script src="static/jquery.js" type="text/javascript"></script>
	<script src="static/ace/ace.js" type="text/javascript"></script>
	<script src="static/editor.js" type="text/javascript"></script>
</body>
</html>
