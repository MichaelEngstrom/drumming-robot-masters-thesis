#cs/* ECE_MastersThesis_DrummingRobot - an application for the Pololu Orangutan SVP
 *
 * This application uses the Pololu AVR C/C++ Library.  For help, see:
 * -User's guide: http://www.pololu.com/docs/0J20
 * -Command reference: http://www.pololu.com/docs/0J18
 *
 * Created: 3/21/2014 3:25:46 PM
 * Last Modified: 1/15/2015
 *  Author: Michael Engstrom
 *
 */
#ce
#include <pololu/orangutan.h>
#include <string.h>

#cs	 /*
	 * To use the SERVOs, you must connect the correct AVR I/O pins to their corresponding
	 * servo demultiplexer output-selection pins on the Orangutan Robot Controller.
	 *   - Connect PB3 to SA.
	 *   - Connect PB4 to SB.
	 */
#ce
	; This array specifies the correspondence between I/O pins and DEMUX
	; output-selection pins.  This demo uses three pins, which allows you
	; to control up to 8 servos.  You can also use two, one, or zero pins
	; to control fewer servos.
	;const unsigned char demuxPins[] = {IO_B3, IO_B4, IO_C0}; 	; select for eight servos
	const unsigned char demuxPins[] = {IO_B3, IO_B4};			; select for four servos
	;const unsigned char demuxPins[] = {IO_B3};             	; select for two servos
	;const unsigned char demuxPins[] = {};                  	; select for one servo

	static unsigned char init_speed = 150;
	static unsigned int neutral_servo_pos = 1300;
	static unsigned int rt_shoulder_rot_lt = 2000;
	static unsigned int rt_shoulder_rot_rt = 1600;
	static unsigned int rt_shoulder_rot = 1600;
	static unsigned int rt_elbow_up = 1950;
	static unsigned int rt_elbow_dn = 1550;
	static unsigned int rt_elbow = 1800;
	static unsigned int lt_shoulder_rot_lt = 1200;
	static unsigned int lt_shoulder_rot_rt = 850;
	static unsigned int lt_shoulder_rot = 1200;
	static unsigned int lt_elbow_up = 2050;
	static unsigned int lt_elbow_dn = 2400;
	static unsigned int lt_elbow = 2200;

; receive_buffer: A ring buffer that we will use to receive bytes on USB_COMM.
; The OrangutanSerial library will put received bytes in to
; the buffer starting at the beginning (receiveBuffer[0]).
; After the buffer has been filled, the library will automatically
; start over at the beginning.
char receive_buffer[32];

; receive_buffer_position: This variable will keep track of which bytes in the
; receive buffer we have already processed. It is the offset(0-31) of the
; next byte in the buffer to process.

unsigned char receive_buffer_position = 0;

; send_buffer: A buffer for sending bytes on USB_COMM.
char send_buffer[32];

; sensor_buffer: A buffer for holding sensor bytes received on USB_COMM.
;char sensor_buffer[5];
char mode[2];		; Changed to single char 3/22/13 -ME
char result[20];
int test = 10;
unsigned int pb_delay = 500;
int flipper2 = 0;		; allows alternating drumstick beats for two robot arms


int byte_counter = 0;

; wait_for_sending_to_finish:  Waits for the bytes in the send buffer to
; finish transmitting on USB_COMM.  We must call this before modifying
; send_buffer or trying to send more bytes, because otherwise we could
; corrupt an existing transmission.
void wait_for_sending_to_finish()
{
	while(!serial_send_buffer_empty(USB_COMM))
		serial_check();		; USB_COMM port is always in SERIAL_CHECK mode
}

; process_received_byte: Responds to a byte that has been received on
; USB_COMM.  If you are writing your own serial program, you can
; replace all the code in this function with your own custom behaviors.
void process_received_byte(char byte)
{
   ;Orangutan LCD user interface initialization
	clear();		; clear LCD
	print("Byte Received");
	lcd_goto_xy(0, 1);	; go to start of second LCD row
	print("RX: ");
	delay_ms(750);
/*
byte = '3';*/
	switch(byte)
	{
		; State Machine-style setup for incoming Serial values; expecting ':::'
		; then single byte over Serial connection. Increment 'byte_counter'
		; for each ':' until we have three, then next Serial byte is valid.
		; Single byte is BPM with granularity of 6 from range 60-120.
		case ':':
			byte_counter += 1;
			print_character(byte);
			break;
		case '0':
			test = 0;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '1':
			test = 1;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '2':
			test = 2;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '3':
			test = 3;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '4':
			test = 4;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '5':
			test = 5;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '6':
			test = 6;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '7':
			test = 7;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '8':
			test = 8;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;
		case '9':
			test = 9;
			print_long(test);
			delay_ms(400);
			byte_counter += 1;
			break;

		; Default is to place byte in 'send_buffer' until finished
		default:
			wait_for_sending_to_finish();
			send_buffer[0] = byte;; ^ 0x20;

			break;
	}
}

void check_for_new_bytes_received()
{
	while(serial_get_received_bytes(USB_COMM) != receive_buffer_position)
	{
		; Process the new byte that has just been received.
		process_received_byte(receive_buffer[receive_buffer_position]);

		; Increment receive_buffer_position, but wrap around when it gets to
		; the end of the buffer.
		if (receive_buffer_position == sizeof(receive_buffer)-1)
		{
			receive_buffer_position = 0;
		}
		else
		{
			receive_buffer_position++;
		}
	}
}

int main()
{


	servos_start(demuxPins, sizeof(demuxPins));

	; Set the servo speed to 150.  This means that the pulse width
	; will change by at most 15 microseconds every 20 ms.  So it will
	; take 1.33 seconds to go from a pulse width of 1000 us to 2000 us.
	set_servo_speed(0, init_speed);
	set_servo_speed(1, init_speed);
	set_servo_speed(2, init_speed);
	set_servo_speed(3, init_speed);

	; Make all the servos go to a neutral position.
	set_servo_target(0, rt_shoulder_rot);	;right shoulder rotation
	set_servo_target(1, rt_elbow);				;right elbow
	set_servo_target(2, lt_shoulder_rot);	;left shoulder rotation
	set_servo_target(3, lt_elbow);			;left elbow

   ;More user information for the interface
	clear();	; clear the LCD
	print("Robot Drummer");
	lcd_goto_xy(0, 1);	; go to start of second LCD row
	print("Send BPM Mode");

	delay_ms(3000);

	; Set the baud rate in bits per second.  Each byte takes ten bit
	; times.
	serial_set_baud_rate(USB_COMM, 115200);

	; Start receiving bytes in the ring buffer.
	serial_receive_ring(USB_COMM, receive_buffer, sizeof(receive_buffer));

   ;Main Loop for performing drum beats
    while(1)
    {
		; USB_COMM is always in SERIAL_CHECK mode, so we need to call this
		; function often to make sure serial receptions and transmissions
		; occur.
		serial_check();
		; Deal with any new bytes received unless we have a complete sample
		; of three ':' bytes, then 4th byte is desired BPM byte
		if (byte_counter < 4)
		{
			check_for_new_bytes_received();
		}

		;Mode value key for Beats Per Minute (BPM) granularity:
		; 0 = 60-65 BPM
		; 1 = 66-71 BPM
		; 2 = 72-77 BPM
		; 3 = 78-83 BPM
		; 4 = 84-89 BPM
		; 5 = 90-95 BPM
		; 6 = 96-101 BPM
		; 7 = 102-107 BPM
		; 8 = 108-113 BPM
		; 9 = 114-120 BPM

		; The 'flipper2' variable in this section and the next makes sure that
		; the drumming arms alternate beats. Only one of the two drumming arms
		; strikes the drum per beat, and the other is up in the air ready to
		; strike on the next beat.
		if ( flipper2 % 2 != 0 )
		{
			set_servo_speed(0, init_speed);
			set_servo_speed(1, init_speed);
			set_servo_speed(2, init_speed);
			set_servo_speed(3, init_speed);

			; Shoulder servos are static
			; Right arm strikes drum
			; Left arm raises
			set_servo_target(0, rt_shoulder_rot_lt);	;right shoulder rotation
			set_servo_target(1, rt_elbow_dn);				;right elbow
			set_servo_target(2, lt_shoulder_rot_rt);	;left shoulder rotation
			set_servo_target(3, lt_elbow_up);			;left elbow
		}
		else
		{
			set_servo_speed(0, init_speed);
			set_servo_speed(1, init_speed);
			set_servo_speed(2, init_speed);
			set_servo_speed(3, init_speed);

			; Shoulder servos are static
			; Right arm raises
			; Left arm strikes drum
			set_servo_target(0, rt_shoulder_rot_lt);	;right shoulder rotation
			set_servo_target(1, rt_elbow_up);				;right elbow
			set_servo_target(2, lt_shoulder_rot_rt);	;left shoulder rotation
			set_servo_target(3, lt_elbow_dn);			;left elbow
		}

		flipper2 += 1;							; increment flipper2 toggle value

		 ;Robot Controller Display and BPM functionality
		 ;This is where the delay occurs for calculated BPM values
		if (test == 0)							; 0 = 60-65 BPM
		{
			clear();							; clear the LCD
			print("BPM = 60-65");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(500);
			byte_counter = 0;					;reset counter

		}
		else if (test == 1)						; 1 = 66-71 BPM
		{
			clear();							; clear the LCD
			print("BPM = 66-71");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(440);
			byte_counter = 0;					;reset counter

		}
		else if (test == 2)						; 2 = 72-77 BPM
		{

			clear();							; clear the LCD
			print("BPM = 72-77");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(400);
			byte_counter = 0;					;reset counter

		}
		else if (test == 3)						; 3 = 78-83 BPM
		{
			clear();							; clear the LCD
			print("BPM = 78-83");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(360);
			byte_counter = 0;					;reset counter


		}
		else if (test == 4)						; 4 = 84-89 BPM
		{
			clear();							; clear the LCD
			print("BPM = 84-89");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(345);
			byte_counter = 0;					;reset counter

		}
		else if (test == 5)						; 5 = 90-95 BPM
		{
			clear();							; clear the LCD
			print("BPM = 90-95");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(335);
			byte_counter = 0;					;reset counter

		}
		else if (test == 6)						; 6 = 96-101 BPM
		{
			clear();							; clear the LCD
			print("BPM = 96-101");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(310);
			byte_counter = 0;					;reset counter

		}
		else if (test == 7)						; 7 = 102-107 BPM
		{
			clear();							; clear the LCD
			print("BPM = 102-107");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(290);
			byte_counter = 0;					;reset counter

		}
		else if (test == 8)						; 8 = 108-113 BPM
		{
			clear();							; clear the LCD
			print("BPM = 108-113");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(270);
			byte_counter = 0;					;reset counter

		}
		else if (test == 9)						; 9 = 114-120 BPM
		{
			clear();							; clear the LCD
			print("BPM = 114-120");				; display BPM
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Mode: ");
			print_long(test);
			green_led(TOGGLE);
			delay_ms(250);
			byte_counter = 0;					;reset counter

		}
		else
		{
			green_led(TOGGLE);
			clear();							; clear the LCD
			print("Robot Drummer");				; default if no BPM has been sent over Serial
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("Send BPM Mode");
			delay_ms(pb_delay);

		}

		 ;Button Interface for Orangutan Robot Controller
		 ;Increase or Decrease BPM (or send fun message!)

		; If the user presses the middle button, send "Robots Rule!"
		; and wait until the user releases the button.
		if (button_is_pressed(MIDDLE_BUTTON))
		{
			wait_for_sending_to_finish();
			memcpy_P(send_buffer, PSTR("Robots Rule!\r\n"), 12);
			serial_send(USB_COMM, send_buffer, 12);
			send_buffer[12] = 0;				; terminate the string
			clear();							; clear the LCD
			lcd_goto_xy(0, 1);					; go to start of second LCD row
			print("TX: ");
			print_long(test);

			delay_ms(2000);
			byte_counter = 0;		; reset detect cycle by pressing button

			; Wait for the user to release the button.  While the processor is
			; waiting, the OrangutanSerial library will not be able to receive
			; bytes from the USB_COMM port since this requires calls to the
			; serial_check() function, which could cause serial bytes to be
			; lost.  It will also not be able to send any bytes, so the bytes
			; bytes we just queued for transmission will not be sent until
			; after the following blocking function exits once the button is
			; released.
			wait_for_button_release(MIDDLE_BUTTON);
		}
		; If the user presses the TOP button, increment delay by 10 ms
		;and display the new Millisecond delay used
		if (button_is_pressed(TOP_BUTTON))
		{
			wait_for_sending_to_finish();
			clear();				; clear the LCD
			print("Delay Up");

			if (pb_delay <= 500)
			{
				pb_delay = pb_delay + 10;
			}

			lcd_goto_xy(0, 1);		; go to start of second LCD row
			print("Milliseconds:");
			print_long(pb_delay);
			delay_ms(250);
			byte_counter = 0;		; reset detect cycle by pressing button
			wait_for_button_release(TOP_BUTTON);
		}
		; If the user presses the BOTTOM button, decrement delay by 10 ms
		;and display the new Millisecond delay used
		if (button_is_pressed(BOTTOM_BUTTON))
		{
			wait_for_sending_to_finish();
			clear();				; clear the LCD
			print("Delay Down");

			if (pb_delay >= 50)
			{
				pb_delay = pb_delay - 10;
			}

			lcd_goto_xy(0, 1);		; go to start of second LCD row
			print("Milliseconds:");
			print_long(pb_delay);
			delay_ms(200);
			byte_counter = 0;		; reset detect cycle by pressing button
			wait_for_button_release(BOTTOM_BUTTON);
		}
    }
}
