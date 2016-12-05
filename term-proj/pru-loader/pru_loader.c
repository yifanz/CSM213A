#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <prussdrv.h>
#include <pruss_intc_mapping.h>

int main(int argc, const char *argv[]) {
	int pru_num;

	if (argc != 3) {
		printf("Usage: %s <pru_code.bin> <pru num>\n", argv[0]);
		return 1;
	}

	pru_num = atoi(argv[2]);

	prussdrv_init();

	if (prussdrv_open(PRU_EVTOUT_0) == -1) {
		printf("prussdrv_open() failed\n");
		return 1;
	}

	tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
	prussdrv_pruintc_init(&pruss_intc_initdata);

	int which_pru = 0;

	if (pru_num == 0) {
		which_pru = 0;
	} else if (pru_num == 1) {
		which_pru = 1;
	}

	void* dataram;
	if (prussdrv_map_prumem(which_pru ? PRUSS0_PRU1_DATARAM : PRUSS0_PRU0_DATARAM, &dataram)) {
		printf("pru mem map failed\n");
		return 1;
	}
	memset(dataram, 0, 100);

	printf("Executing program and waiting for termination\n");
	prussdrv_exec_program(which_pru, argv[1]);

	// Wait for the PRU to let us know it's done
	prussdrv_pru_wait_event(PRU_EVTOUT_0);

/*
	uint32_t* p = (uint32_t*) dataram;
	for (int i = 0; i < 3; i++) {
		printf("%d: %d cycles, %f ms\n",
				*(p+1),
				*p,
				(float) *p * 5 / (1000 * 1000));
		p += 2;
	}
*/

	printf("All done\n");

	prussdrv_pru_disable(which_pru);
	prussdrv_exit();

	return 0;
}
