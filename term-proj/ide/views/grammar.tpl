<pre id="grammar" style="display: none;">
{
	var reg_var_map = {};
	var base_tmp_reg = 16;
	var tmp_reg = base_tmp_reg;
	var base_free_reg = 2;
	var free_reg = base_free_reg;
	var loop_cnt = 0;
	
	var pin_map = {
		"P8_11": { reg: 30, bit: 15, offset: 0x34, mode: 0x06 },
		"P8_16": { reg: 31, bit: 14, offset: 0x38, mode: 0x06 },
	};
	var pin_enable_pull_bit = (1 << 3);
	var pin_pullup_bit = (1 << 4);
	var pin_input_bit = (1 << 5);
	var pin_settings = {};

	window.asm_out_buf = "";
	window.pin_settings = pin_settings;

	function asm_out(str) {
		window.asm_out_buf += str + "\n";
	}

	function assign_reg(symbol) {
		var reg = reg_var_map[symbol];

		if (!reg) {
			var num = free_reg++;
			if (num >= base_tmp_reg) throw { message: "out of registers" };
			reg_var_map[symbol] = num;
		}

		return "r" + reg_var_map[symbol];
	}

	function assign_tmp_reg() {
		var num = tmp_reg++;
		if (num > 28) throw { message: "out of tmp registers" };
		return "r" + num;
	}

	function assign_tmp_reg_imm() {
		var num = tmp_reg;
		if (num > 28) throw { message: "out of tmp registers" };
		return "r" + num;
	}

	function reset_tmp_regs() {
		tmp_reg = base_tmp_reg;
	}

	function get_pin_info(pin) {
		var pin_info = pin_map[pin];
		if (!pin_info) throw { message: "invalid pin " + pin};
		return pin_info;
	}

	function assign_pin(pin, input) {
		var pin_conf = pin_settings[pin];
		if (pin_conf && pin_conf.input !== input) {
			throw { message: "" + pin + " cannot be used for input and output simultaneously" };	
		}
		if (pin_conf && pin_conf.input === input) return;

		var pin_info = pin_map[pin];
		if (!pin_info) throw { message: "" + pin + " does not exist" };

		var conf = "0x" + Number(pin_info.offset).toString(16) + " 0x" + Number(pin_info.mode).toString(16);
		if (input) {
			conf = "0x" + Number(pin_info.offset).toString(16) + " 0x" + Number(pin_info.mode | pin_enable_pull_bit | pin_input_bit).toString(16);
		}

		pin_settings[pin] = { input: input, conf: conf };	
	}
}

Root
	= Statement*

Statement
	= _ Assignment _ ";" _
	/ _ Loop _
	/ _ If _

Assignment
	= _ lhs:(Pin / Identifier) _ "=" _ rhs:Expression {
		if (lhs.type === 'pin') {
			if (rhs.type === 'int') {
				var pin_info = get_pin_info(lhs.value);
				var preg = "r" + pin_info.reg;
				var pbit = pin_info.bit;
				if (rhs.value === 0) {
					asm_out("clr " + preg + ", " + preg + ", " + pbit);
				} else {
					asm_out("set " + preg + ", " + preg + ", " + pbit);
				}
				assign_pin(lhs.value, false);
			} else {
				throw { message: "pin must be set with an integer literal" };
			}
		} else {
			if (rhs.type !== 'int') {
				asm_out("mov " + lhs.value + ", " + rhs.value);
			} else {
				asm_out("ldi " + lhs.value + ", " + rhs.value);
			}
		}
		reset_tmp_regs();
		return null;
	}

Loop
	= "while" _ "(" _ cond:CondExpression _ ")" _ "{" Statement* "}" {
		asm_out("jmp " + cond.value);
		asm_out("" + cond.value + "_END:");
	}

If
	= "if" _ "(" _ cond:CondExpression _ ")" _ "{" Statement* "}" {
		asm_out("" + cond.value + "_END:");
	}

CondExpression
	= not:("!"?) _ pin:Pin {
		var opcode = "qbbc ";
		if (not === "!") opcode = "qbbs ";
		
		var label = "COND_" + loop_cnt++;
		var label_end = label + "_END";

		asm_out(label + ":");

		var pin_info = get_pin_info(pin.value);
		var preg = "r" + pin_info.reg;
		var pbit = pin_info.bit;

		asm_out(opcode + label_end + ", " + preg + ", " + pbit);

		assign_pin(pin.value, true);

		return {
			type: 'label',
			value: label
		};
	}
	/ lhs:Expression _ op:(">" / "<" / ">=" / "<=" / "==") _ rhs:Expression {
		var opcode;
		if (op == ">") opcode = "qble ";
		else if (op == "<") opcode = "qbge";
		else if (op == ">=") opcode = "qblt ";
		else if (op == "<=") opcode = "qbgt ";
		else if (op == "==") opcode = "qbne ";
		
		var label = "COND_" + loop_cnt++;
		var label_end = label + "_END";

		asm_out(label + ":");

		if (lhs.type === 'int') {
			var treg = assign_tmp_reg_imm();
			asm_out("ldi " + treg + ", " + lhs.value);
			lhs = { type: 'reg', value: treg };
		}

		asm_out(opcode + label_end + ", " + lhs.value + ", " + rhs.value);

		return {
			type: 'label',
			value: label
		};
	}

Expression
	= head:Term tail:(_ ("&" / "|") _ Term)* {
		var lhs = head;

		if (tail.length == 0) {
			return lhs;
		}

		var treg = assign_tmp_reg();


		for (var i = 0; i < tail.length; i++) {
			var opcode;

			if (tail[i][1] === "&") opcode = "and ";
			if (tail[i][1] === "|") opcode = "or ";

			var rhs = tail[i][3];

			if (lhs.type === 'int' && rhs.type === 'int') {
				var result;
				if (opcode === "and ") result = lhs.value & rhs.value;
				else result = lhs.value | rhs.value;
				asm_out("ldi " + treg + ", " + result);
			} else if (lhs.type === 'int' && rhs.type !== 'int') {
				var head_tmp = assign_tmp_reg_imm();
				asm_out("ldi " + head_tmp + ", " + lhs.value);
				asm_out(opcode + treg + ", " + head_tmp + ", " + rhs.value);
			} else {
				asm_out(opcode + treg + ", " + lhs.value + ", " + rhs.value);
			}

			lhs = { type: 'reg', value: treg };
		}

		return {
			type: "reg",
			value: treg
		};
	}

Term
	= head:Factor tail:(_ ("+" / "-") _ Factor)* {
		var lhs = head;

		if (tail.length == 0) {
			return lhs;
		}

		var treg = assign_tmp_reg();

		for (var i = 0; i < tail.length; i++) {
			var opcode;

			if (tail[i][1] === "+") opcode = "add ";
			if (tail[i][1] === "-") opcode = "sub ";

			var rhs = tail[i][3];

			if (lhs.type === 'int' && rhs.type === 'int') {
				var result;
				if (opcode === "add ") result = lhs.value + rhs.value;
				else result = lhs.value - rhs.value;
				asm_out("ldi " + treg + ", " + result);
			} else if (lhs.type === 'int' && rhs.type !== 'int') {
				var head_tmp = assign_tmp_reg_imm();
				asm_out("ldi " + head_tmp + ", " + lhs.value);
				asm_out(opcode + treg + ", " + head_tmp + ", " + rhs.value);
			} else {
				asm_out(opcode + treg + ", " + lhs.value + ", " + rhs.value);
			}

			lhs = { type: 'reg', value: treg };
		}

		return {
			type: "reg",
			value: treg
		};
	}

Factor
	= "(" _ expr:Expression _ ")" {
		return expr;
	}
	/ Integer
	/ Identifier

Integer "integer"
	= [0-9]+ { 
		return {
			type: "int",
			value: parseInt(text(), 10)
		};
	}

Pin
	= "P" header:("8" / "9") "_" num:([1-9][0-9]*) {
		return {
			type: 'pin',
			value: text()
		}
	}

Identifier
	= ([a-zA-Z][a-zA-Z0-9]*) {
		return {
			type: "reg",
			value: assign_reg(text())
		};
	}

_ "whitespace"
	= [ \t\n\r]*
</pre>
