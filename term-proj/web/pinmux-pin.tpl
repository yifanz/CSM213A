<%
name = pin['name']
mode = pin['mode']
pru_assignable = bool(filter(lambda x: 'pru' in str(x), pin['modes']))
slew = 'checked' if pin['slew'] else ''
input = 'checked' if pin['input'] else ''
pullup = 'checked' if pin['pullup'] else ''
enable_pullupdown = 'checked' if pin['enable_pullupdown'] else ''
disabled = '' if pru_assignable else 'disabled'
row = [('mode', None), ('input', input), ('enable_pullupdown', enable_pullupdown), ('pullup', pullup), ('slew', slew)]
row = list(reversed(row)) if reverse else row
%>

%for cell in row:
	<td class="
	%if mode == None:
		fixed
	%elif disabled:
		disabled
	%end
	">
		%if cell[0] == 'mode':
			%if mode != None:
				%if pru_assignable:
					<select name="{{pin_num}}_mode">
						%for k, m in enumerate(pin['modes']):
							%if m != None:
								<option value="{{k}}"
								%if m and k == mode:
									selected
								%end
								>{{m}}</option>
							%end
						%end
					</select>
				%else:
					{{pin['modes'][mode]}}
				%end
			%else:
				{{name}}
			%end
		%else:
			%if mode != None:
				<input type="checkbox"
					title="{{cell[0]}}"
					name="{{pin_num}}_{{cell[0]}}"
					value="1"
					{{cell[1]}} {{disabled}}>
			%end
		%end
	</td>
%end
