/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include "system.h"
#include "sys/alt_stdio.h"
#include "sys/alt_sys_wrappers.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_timer_regs.h"

#include "sys/alt_irq.h"
#include "sys/alt_cache.h"
#include "altera_avalon_fifo.h"
#include "altera_avalon_fifo_util.h"

#include "sys/alt_dma.h"
#include "altera_avalon_dma.h"
#include "altera_avalon_dma_regs.h"

#include "SigmaStudioFW.h"
#include "adau1761_IC_1.h"
#include "adau1761_IC_1_PARAM.h"

#define FLASH_DEVICE_ID 0x4d182001

#define I2S_BUF_SIZE 256
#define MAX_BUF_SIZE 2048

//int data[MAX_BUF_SIZE] = {0};
//int odata[MAX_BUF_SIZE] = {0};
int callback_count = 0;
int fill_count = 0;

// fifo rx
alt_dma_txchan txchan;
alt_dma_rxchan rxchan;
int rx_done = 0;
int rx_buffer[MAX_BUF_SIZE] = {0};

// fifo tx
alt_dma_txchan txchan1;
alt_dma_rxchan rxchan1;
int rx_done1 = 0;
//int rx_buffer[I2S_BUF_SIZE] = {0};

int pwm_addr0 = 0;
int pwm_addr1 = 2;
int pwm_interval0 = 0;
int pwm_interval1 = 0;
int pwm_direction[4] = {-1, -1, -1, -1};
int pwm_counter[4] = {60000, 60000, 60000, 60000};

void msleep(int msec)
{
	for (int i = 0; i < msec; i++)
	{
		usleep(1000);
	}
}

// for QSPI Flash
int read_device_id(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x0000489F);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xc);
}

int read_status_register(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00001805);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xc);
}

int read_flag_status_register(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00001870);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xc);
}

void write_enable(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00000006);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,1);
}

void enter_4byte_addressing_mode(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x000000B7);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,1);
}

void clear_flag_status_register(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00000050);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,1);
}

int read_bank_register(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00001816);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xc);
}

//for cypress flash to enter four byte addr
void write_bank_register_enter4byte(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00001017);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,0x00000080);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
}

//for cypress flash to enter 3 byte addr
void write_bank_register_exit4byte(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00001017);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
}

//to check cypress flash in dual or quad mode
int read_config_register(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00001835);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xc);
}

//for cypress flash to enter quad mode
void write_config_register(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00002001);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,0x00000200);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
}

//exit p_err & e_err mode
void clear_status_register(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00001030);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,1);
}

void erase_sector_cypress(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x000003D8);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x9,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
}

int read_memory(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x4,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x0,0x00000101);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x5,0x00000003);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,0x00000000);
}
int read_memory_3byte(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x4,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x0,0x00000001);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x5,0x00000003);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,0x00000000);
}
//cypress 4 byte fast read (0C)
int cypress_four_byte_fast_read(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x4,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x0,0x00000101);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x5,0x000080C);
	return IORD(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,0x00000000);
}

//4byte addr page program
void write_memory(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x4,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x0,0x00000101);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x6,0x00007002);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,0x00000000,0xabcd1234);
}
void write_memory_3byte(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x4,0x00000000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x0,0x00000001);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x6,0x00000502);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_MEM_BASE,0x00000000,0xabcd1234);
}

//Bit 5 & Bit 3 set of configuration register set to 1; Sector 0 of memory array is protected(TB-BP2-BP1-BP0:1-0-0-1) in status register;
void write_register_for_sector_protect_cypress(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00002001);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,0x0000201c);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
}

void write_register_for_sector_unprotect_cypress(){
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x7,0x00002001);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0xA,0x00002000);
	IOWR(INTEL_GENERIC_SERIAL_FLASH_INTERFACE_TOP_0_AVL_CSR_BASE,0x8,0x1);
}

static void isr_timer0(void *context)
{
	pwm_interval0++;
	if (pwm_interval0 > 4)
	{
		IOWR(AVALON_PWM_0_BASE, pwm_addr0, pwm_counter[pwm_addr0]);
		pwm_counter[pwm_addr0] += pwm_direction[pwm_addr0];

		if (pwm_counter[pwm_addr0] > 60000)
		{
			pwm_direction[pwm_addr0] = -1;

			pwm_addr0++;
			if (pwm_addr0 > 1)
				pwm_addr0 = 0;
			}
		else if (pwm_counter[pwm_addr0] < 0)
		{
			pwm_direction[pwm_addr0] = 1;
		}
		pwm_interval0 = 0;
	}

	pwm_interval1++;
	if (pwm_interval1 > 2)
	{
		IOWR(AVALON_PWM_0_BASE, pwm_addr1, pwm_counter[pwm_addr1]);
		pwm_counter[pwm_addr1] += pwm_direction[pwm_addr1];

		if (pwm_counter[pwm_addr1] > 59000)
		{
			pwm_direction[pwm_addr1] = -1;

			pwm_addr1++;
			if (pwm_addr1 > 3)
				pwm_addr1 = 2;
		}
		else if (pwm_counter[pwm_addr1] < 2000)
		{
			pwm_direction[pwm_addr1] = 1;
		}
		pwm_interval1 = 0;
	}

	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE, 0);
}

static void dma_rx_done1(void *handle, void *data)
{
	rx_done1++;
}

static void dma_rx_done(void *handle, void *data)
{
	rx_done++;

	//int fifo_level = altera_avalon_fifo_read_level(FIFO_TX_BASE);
	int rc = alt_dma_txchan_send(txchan1, rx_buffer, I2S_BUF_SIZE, NULL, NULL);
	//int rc = alt_dma_txchan_send(txchan1, rx_buffer, fifo_level, NULL, NULL);
	if (rc < 0)
	{
		printf("Failed to post write request, reason = %d\n", rc);
	}

	rc = alt_dma_rxchan_prepare(rxchan1, (void *)0x0, I2S_BUF_SIZE, dma_rx_done1, NULL);
	//rc = alt_dma_rxchan_prepare(rxchan1, (void *)0x0, fifo_level, dma_rx_done1, NULL);
	if (rc < 0)
	{
		printf("Failed to post read request, reason = %d\n", rc);
	}
}

static void fifo_callback(void *context)
{
	int status = altera_avalon_fifo_read_status(FIFO_RX_BASE, ALTERA_AVALON_FIFO_IENABLE_ALL);
	if (status & (ALTERA_AVALON_FIFO_STATUS_AF_MSK | ALTERA_AVALON_FIFO_STATUS_F_MSK))
	{
		//int fifo_level = altera_avalon_fifo_read_level(FIFO_RX_BASE);
		int rc = alt_dma_txchan_send(txchan, (void *)0x0, I2S_BUF_SIZE, NULL, NULL);
		//int rc = alt_dma_txchan_send(txchan, (void *)0x0, fifo_level, NULL, NULL);
		if (rc < 0)
		{
			printf("Failed to post write request, reason = %d\n", rc);
		}

		rc = alt_dma_rxchan_prepare(rxchan, rx_buffer, I2S_BUF_SIZE, dma_rx_done, NULL);
		//rc = alt_dma_rxchan_prepare(rxchan, rx_buffer, fifo_level, dma_rx_done, NULL);
		if (rc < 0)
		{
			printf("Failed to post read request, reason = %d\n", rc);
		}

		//printf("data = %08X\n", ((int *)rx_buffer)[0]);
	}

	altera_avalon_fifo_clear_event(FIFO_RX_BASE, ALTERA_AVALON_FIFO_EVENT_ALL);
}

int initDMA()
{
	if ((txchan = alt_dma_txchan_open(DMA_RX_NAME)) == NULL)
	{
		printf("Failed to open transit channel\n");
		return -1;
	}

	if ((rxchan = alt_dma_rxchan_open(DMA_RX_NAME)) == NULL)
	{
		printf("Failed to open receive channel\n");
		return -2;
	}

	if ((txchan1 = alt_dma_txchan_open(DMA_TX_NAME)) == NULL)
	{
		printf("Failed to open transit channel\n");
		return -3;
	}

	if ((rxchan1 = alt_dma_rxchan_open(DMA_TX_NAME)) == NULL)
	{
		printf("Failed to open receive channel\n");
		return -4;
	}

	return 0;
}

int initCODEC()
{
	//ADAU1761 RESET
	IOWR_ALTERA_AVALON_PIO_DIRECTION(PIO_4_BASE, 1);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_4_BASE, 1);

	i2c_setup(0x00, 0xB3);
	default_download_IC_1();

	IOWR_ALTERA_AVALON_PIO_DATA(PIO_4_BASE, 0);
	usleep(1000 * 200);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_4_BASE, 1);

	default_download_IC_1();

	return 0;
}

int main()
{
	printf("Hello from Nios II\n");

	//test reset
	IOWR(AVALON_I2S_0_BASE, 0, 0);

	initDMA();
	initCODEC();

#if 1
    IOWR_ALTERA_AVALON_PIO_DIRECTION(PIO_5_BASE, 1);
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_5_BASE, 0x1);

#if 0
    IOWR_ALTERA_AVALON_PIO_DIRECTION(PIO_2_BASE, 0x11);
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_2_BASE, 0x01);
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_2_BASE, 0x10);
#endif

    // PMOD2
    IOWR_ALTERA_AVALON_PIO_DIRECTION(PIO_3_BASE, 0);

    // ADC
    IOWR_ALTERA_AVALON_PIO_DIRECTION(PIO_6_BASE, 0);
#endif

#if 0
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_0_BASE, 15);
    usleep(1000 * 1000);
#endif

    IOWR_32DIRECT(AVALON_PWM_0_BASE, 0, pwm_counter);

#if 0
    // QSPI
    printf("flash device id = %X\n", read_device_id());

    int mask_wip = 0x00000001; //set mask to check Write in Progress (WIP) bit to determine device busy or ready
	int block_protect_cr = 0x00000020; //set BP starts at bottom
	int block_protect_sr = 0x0000001c; //set BP2-0 in status register to protect all sectors
	int mask_wel = 0x00000002; //set mask to check write enable latch
	int mask_sr = 0x000000e3; // set mask to check bit 4:2 of status register
	int mask_e_err = 0x00000020; //set mask to check erase error bit

	//PERFORM SECTOR PROTECT CONFIGURATION DEVICE

	if ((read_status_register() | mask_sr) == mask_sr)
	{
		printf("All sectors in this configuration device is not protected\n");
		printf("Now performing sector protection...\n");
		write_enable();
		write_register_for_sector_protect_cypress(); //sector protect all sector(BP2:BP1:BP0=1:1:1)

		int mask_wip = 0x00000001; //set mask to check Write in Progress (WIP) bit to determine device busy or ready

		while (read_status_register() & mask_wip == mask_wip)
		{
			//printf("Write register for sector protect in progress...\n");
			//usleep(1000);
		}

		//Check Status Register and Configuration Register to see whether both of them set to perform sector protect

		if (((read_status_register() & block_protect_sr) != block_protect_sr) && ((read_config_register() & block_protect_cr) != block_protect_cr))
		{
			printf("Setor protection failed due to error in setting status and configuration register");
			printf("Status Register: %08x\n", read_status_register());
			printf("Configuration Register: %08x\n", read_config_register());
			printf("Check datasheet to find out");
			return 0;
		}
	}

	printf("All sectors in this configuration device is now successfully protected\n");
	//PERFORM SECTOR ERASE ON PROTECTED SECTOR

	write_enable();

	if ((read_status_register() & mask_wel) != mask_wel)
	{ //check if write enable latch is set
		printf("Sector erase cannot be executed as write enable latch do not set\n");
		return 0;
	}

	printf("Trying to erase sector 0...\n");

	erase_sector_cypress();

	if ((read_status_register() & mask_e_err) != mask_e_err)
	{
		printf("ERASE ERROR do not occur. Check status register for more details.\n");
		return 0;
	}

	printf("ERASE ERROR as sector is protected!\n");
	clear_status_register(); //clear erase error bit

	//UNPROTECT ALL SECTORS IN CONFIGURATION DEVICE
	printf("Now perform sector unprotect...\n");

	write_enable();

	if ((read_status_register() & mask_wel) != mask_wel)
	{ //check if write enable latch is set
		printf("Sector unprotect cannot be executed as write enable latch do not set\n");
		return 0;
	}

	write_register_for_sector_unprotect_cypress();

	while ((read_status_register() & mask_wip) == mask_wip)
	{
		usleep(1000);
	}

	if (read_status_register() | mask_sr != mask_sr)
	{
		printf("Sector unprotect not successful! :(\n");
		return 0;
	}

	printf("Sector unprotect successfully! :)\n");

	//READ AND WRTIE DATA
	printf("Reading data at address 0...\n");
	printf("Memory content at address 0: %x\n", read_memory_3byte());
	int empty_data = 0xffffffff;

	if (read_memory_3byte() != empty_data)
	{
		//PERFORM SECTOR ERASE to clear sector 0

		write_enable();

		if ((read_status_register() & mask_wel) != mask_wel)
		{ //check if write enable latch is set
			printf("Sector erase cannot be executed as write enable latch do not set\n");
		}

		printf("Trying to erase sector 0...\n");
		erase_sector_cypress();
	}

	//WRITING DATA
	printf("Address 0 not containing data...\n");
	printf("Writing data to address 0...\n");

	write_memory_3byte();

	while ((read_status_register() & mask_wip) == mask_wip)
	{
		//printf("Write data in progress...\n");
		usleep(10000000);
	}

	//READ BACK DATA
	printf("Read back data from address 0...\n");

	int data1 = 0xabcd1234;

	if(read_memory_3byte() != data1)
	{
		printf("Current memory in address 0: %x\n",read_memory_3byte());
		printf("Something is wrong...");
		return 0;
	}

	printf("Current memory in address 0: %x\n",read_memory_3byte());
	printf("Read data match with data written. Write memory successful.");

	//SECTOR PROTECT
	printf("Now performing sector protection...\n");
	write_enable();
	write_register_for_sector_protect_cypress();

	while ((read_status_register() & mask_wip) == mask_wip)
	{
		//printf("Write register for sector protect in progress...\n");
		//usleep(1000);
	}

	//Check Status Register and Configuration Register to see whether both of them set to perform sector protect


	if ( ((read_status_register()& block_protect_sr) == block_protect_sr) && ((read_config_register() & block_protect_cr)!= block_protect_cr))
	{
		printf("Setor protection failed due to error in setting status and configuration register");
		printf("Status Register: %08x\n",read_status_register());
		printf("Configuration Register: %08x\n",read_config_register());
		printf("Check datasheet to find out");
		return 0;
	}

	printf("All sectors in this configuration device is now successfully protected\n");

	//PERFORM SECTOR ERASE ON PROTECTED SECTOR
	write_enable();

	if ((read_status_register()& mask_wel) != mask_wel)
	{ //check if write enable latch is set
		printf("Sector erase cannot be executed as write enable latch do not set\n");
		return 0;
	}

	printf("Trying to erase sector 0...\n");
	erase_sector_cypress();

	if (read_status_register()& mask_e_err!= mask_e_err)
	{
		printf("ERASE ERROR do not occur. Check status register for more details.\n");
		return 0;
	}
	printf("ERASE ERROR as sector is protected!\n");
	clear_status_register(); //clear erase error bit

	if(read_memory_3byte() == data1)
	{
		printf("Current memory in address 0: %x\n",read_memory_3byte());
		printf("Read data match with data written previously. Sector erase does not perform during sector is protected.");
	}
	else
	{
		printf("Current memory in address 0: %x\n",read_memory_3byte());
		printf("Something is wrong...");
		return 0;
	}
#endif

	IOWR(AVALON_PWM_0_BASE, 0b100, 1);
	IOWR(AVALON_PWM_0_BASE, 0b101, 1);
	IOWR(AVALON_PWM_0_BASE, 0b110, 1);
	IOWR(AVALON_PWM_0_BASE, 0b111, 1);

	IOWR(AVALON_PWM_0_BASE, 0, 60000);
	IOWR(AVALON_PWM_0_BASE, 1, 60000);
	IOWR(AVALON_PWM_0_BASE, 2, 60000);
	IOWR(AVALON_PWM_0_BASE, 3, 60000);

	alt_ic_isr_register(TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID,
						TIMER_0_IRQ,
						isr_timer0,
						NULL,
						NULL);

	alt_u32 count = 5000000 - 1;
	IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_0_BASE, count & 0xffff);
	IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_0_BASE, (count >> 16) & 0xffff);
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE,
									 ALTERA_AVALON_TIMER_CONTROL_ITO_MSK |
									 ALTERA_AVALON_TIMER_CONTROL_CONT_MSK |
									 ALTERA_AVALON_TIMER_CONTROL_START_MSK);


	//altera_avalon_fifo_clear_event(FIFO_0_IN_CSR_BASE, ALTERA_AVALON_FIFO_EVENT_ALL);
	int fifo_status = altera_avalon_fifo_init(FIFO_RX_BASE,
#if 1
											  (ALTERA_AVALON_FIFO_IENABLE_AF_MSK |
											   ALTERA_AVALON_FIFO_IENABLE_F_MSK
#if 0
											   ALTERA_AVALON_FIFO_IENABLE_AE_MSK |
											   ALTERA_AVALON_FIFO_IENABLE_E_MSK
											   ALTERA_AVALON_FIFO_IENABLE_OVF_MSK |
											   ALTERA_AVALON_FIFO_IENABLE_UDF_MSK
#endif
											  ),
#else
											  ALTERA_AVALON_FIFO_IENABLE_ALL,
#endif
											  1,
											  I2S_BUF_SIZE);
	if (fifo_status != ALTERA_AVALON_FIFO_OK)
	{
		printf("FIFO init Failed %d\n", fifo_status);
		return 0;
	}
	alt_ic_isr_register(FIFO_RX_IRQ_INTERRUPT_CONTROLLER_ID,
						FIFO_RX_IRQ,
						fifo_callback,
						NULL,
						NULL);

	IOWR(AVALON_I2S_0_BASE, 0, 1);

#if 0
	int fifo_ie = altera_avalon_fifo_read_ienable(FIFO_0_IN_CSR_BASE, ALTERA_AVALON_FIFO_IENABLE_ALL);
	int fifo_af = altera_avalon_fifo_read_almostfull(FIFO_0_IN_CSR_BASE);
	int fifo_ae = altera_avalon_fifo_read_almostempty(FIFO_0_IN_CSR_BASE);
	int fifo_e = altera_avalon_fifo_read_event(FIFO_0_IN_CSR_BASE, ALTERA_AVALON_FIFO_EVENT_ALL);
	printf("%d %d %d\n", fifo_af, fifo_ae, fifo_e);
#endif

    /* Event loop never exits. */
	while (1)
	{
		//int key = alt_getchar();
		//alt_printf("\n => %c", key);

		//if (callback_count != callback_count_old)
		{
			int fifo_level = altera_avalon_fifo_read_level(FIFO_RX_BASE);
			printf("fifo_level => %d\n", fifo_level);
		}

		printf("rx_done = %d\n", rx_done);
		//printf("data = %08X\n", ((int *)rx_buffer)[0]);
	}

	return 0;
}
