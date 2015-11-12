/dts-v1/;
/plugin/;

/ {
	compatible = "ti,beaglebone", "ti,beaglebone-green", "ti,beaglebone-black";
	part-number = "{{part_num}}";
	version = "{{version}}";

	exclusive-use =
		"P8.11", "P8.16", "pru0";
	%if pins:
	fragment@0 {
		target = <&am33xx_pinmux>;
		__overlay__ {
			example_pins: pinmux_pru_pru_pins {
				pinctrl-single,pins = <
				%for pin in pins:
					{{hex(pin[0])}} {{hex(pin[1])}}
				%end
				>;
			};
		};
	};
	%end

	fragment@1 {
		target = <&pruss>;
		__overlay__ {
			status = "{{status}}";
			%if pins:
			pinctrl-names = "default";
			pinctrl-0 = <&example_pins>;
			%end
		};
	};
};
