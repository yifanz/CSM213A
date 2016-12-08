<pre id="grammar" style="display: none;">
{
	var reg_var_map = {};
	var base_tmp_reg = 16;
	var tmp_reg = base_tmp_reg;
	var base_free_reg = 2;
	var free_reg = base_free_reg;
	var loop_cnt = 0;

	window.asm_out_buf = "";

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
}

Root
	= Statement*

Statement
	= _ Assignment _ ";" _
	/ _ Loop _
	/ _ If _

Assignment
	= _ lhs:Identifier _ "=" _ rhs:Expression {
		if (rhs.type !== 'int') {
			asm_out("mov " + lhs.value + ", " + rhs.value);
		} else {
			asm_out("ldi " + lhs.value + ", " + rhs.value);
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
	= lhs:Expression _ op:(">" / "<" / ">=" / "<=" / "==") _ rhs:Expression {
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
