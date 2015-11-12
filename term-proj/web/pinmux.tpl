% rebase('base.tpl', title='PRU Pin Configuration')
<form action="/pru/pinmux" method="post">
<label>PRU Subsystem Enabled:
	<input name="enable_pruss" type="checkbox"
	%if pruss_enabled:
		checked
	%end
	>
</label>
<table>
<caption>P8</caption>
<%for i in range(1, 46, 2):
	l = P8[i]
	r = P8[i+1]
	%>

	<tr>
		%include('pinmux-pin.tpl', pin=l, pin_num="P8_" + str(i), reverse=True)
		<td>{{i}}</td>
		<td>{{i+1}}</td>
		%include('pinmux-pin.tpl', pin=r, pin_num="P8_" + str(i+1), reverse=False)
	</tr>
%end
</table>
<input type="submit" value="Submit">
</form>
