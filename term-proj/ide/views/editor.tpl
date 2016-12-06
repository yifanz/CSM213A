% rebase('base.tpl', title='PRU Editor', pru_num=pru_num)

<div class="editor-container">
	<div id="editor" class="editor">
	</div>
</div>

<div class="editor-container asm-editor-container">
	<div id="asm-editor" class="editor">
// PRU {{pru_num}}
.origin 0
.entrypoint TOP

TOP:

// use r0 as a constant zero register
mov r0, 0

// Writing bit 15 in the magic PRU GPIO output register
// PRU0, register 30, bit 15 turns on pin 11 on BeagleBone
// header P8.
//set r30, r30, 15

// Uncomment to turn the pin off instead.
//clr r30, r30, 15

// Control register base address
mov r2, 0x22000
// Read in control register
lbbo r3, r2, 0, 1
// Turn on bit 3 to enable counters
set r3.t3
// Write to control register
sbbo r3, r2, 0, 1

// loop repeat counter
mov r1, 0

// bit 14 corresponds to pin 16 on header P8
// r31.t14
// bit 15 corresponds to pin 11 on header P8
// r30.t15

// reset cycle counter
sbbo r0, r2, 0xC, 4

Repeat:
call Timestamp
add r1, r1, 1
qbgt Repeat, r1, 4

// Interrupt the host so it knows we're done
mov r31.b0, 19 + 16

// Don't forget to halt or the PRU will keep executing and probably
// require rebooting the system before it'll work again!
halt

Timestamp:

// Read counter
lbbo r3, r2, 0xC, 4

// Write counter to data memory
lsl r4, r1, 3
sbbo r3, r0, r4, 4
add r4, r4, 4
sbbo r1, r0, r4, 4

ret
	</div>
</div>

<div id="console-container">
	<pre id="console"></pre>
</div>
