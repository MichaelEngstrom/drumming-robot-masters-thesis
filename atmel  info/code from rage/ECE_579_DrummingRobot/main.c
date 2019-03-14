/* DrummingRobot - an application for the Pololu Orangutan SVP
 *
 * This application uses the Pololu AVR C/C++ Library.  For help, see:
 * -User's guide: http://www.pololu.com/docs/0J20
 * -Command reference: http://www.pololu.com/docs/0J18
 *
 *  Author: mjengstx
 *
 * Updates: improved granularity of BPM output by changing the control
 * character set to CHAR[a-r] (25 chars) over the 60-120 BPM range. Granularity is
 * now 61/25 = 2.44
 * Previously used CHAR[0-9] (10 chars) with a granularity accuracy of 61/10 = 6.1
 * Assuming that the control character coming in from the serial input is accurate,
 * the maximum Robot Drum output offset gap is improved by 60%.
 */  
#include <pololu/orangutan.h>  
#include <string.h>

	 /*
	 * To use the SERVOs, you must connect the correct AVR I/O pins to their
	 * corresponding servo demultiplexer output-selection pins.
	 *   - Connect PB3 to SA.
	 *   - Connect PB4 to SB.
	 */
	
	// This array specifies the correspondence between I/O pins and DEMUX
	// output-selection pins.  This demo uses three pins, which allows you
	// to control up to 8 servos.  You can also use two, one, or zero pins
	// to control fewer servos.
	//const unsigned char demuxPins[] = {IO_B3, IO_B4, IO_C0}; // eight servos
	const unsigned char demuxPins[] = {IO_B3, IO_B4};	// four servos
	//const unsigned char demuxPins[] = {IO_B3};             // two servos
	//const unsigned char demuxPins[] = {};                  // one servo
		
	static unsigned char init_speed = 150;
	static unsigned char servo_speed = 150;
	static unsigned int neutral_servo_pos = 1300;
	//static unsigned int rt_shoulder_up = 300;
	//static unsigned int rt_shoulder_dn = 1300;
	//static unsigned int rt_shoulder = 1800;
	static unsigned int rt_shoulder_rot_lt = 2000;
	static unsigned int rt_shoulder_rot_rt = 1600;
	static unsigned int rt_shoulder_rot = 1600;
	static unsigned int rt_elbow_up = 1950;			//ltdn
	static unsigned int rt_elbow_dn = 1775;			//ltup
	static unsigned int rt_elbow = 1800;
	//static unsigned int lt_shoulder_up = 300;
	//static unsigned int lt_shoulder_dn = 1300;
	//static unsigned int lt_shoulder = 1800;
	static unsigned int lt_shoulder_rot_lt = 1200;
	static unsigned int lt_shoulder_rot_rt = 850;
	static unsigned int lt_shoulder_rot = 1200;
	static unsigned int lt_elbow_up = 1900;
	static unsigned int lt_elbow_dn = 2150;
	static unsigned int lt_elbow = 2200;

// receive_buffer: A ring buffer that we will use to receive bytes on USB_COMM.
// The OrangutanSerial library will put received bytes in to
// the buffer starting at the beginning (receiveBuffer[0]).
// After the buffer has been filled, the library will automatically
// start over at the beginning.
char receive_buffer[32];

// receive_buffer_position: This variable will keep track of which bytes in the
// receive buffer we have already processed. It is the offset(0-31) of the
// next byte in the buffer to process.

unsigned char receive_buffer_position = 0;

// send_buffer: A buffer for sending bytes on USB_COMM.
char send_buffer[32];

// sensor_buffer: A buffer for holding sensor bytes received on USB_COMM.
//char sensor_buffer[5];
char mode[2];		// Changed to single char 3/22/13 -ME
char result[20];
int test = 0;
unsigned int pb_delay = 500;	//60 BPM Default starting value
int flipper2 = 0;


int byte_counter = 0;
//string aNiceString = "";

// wait_for_sending_to_finish:  Waits for the bytes in the send buffer to
// finish transmitting on USB_COMM.  We must call this before modifying
// send_buffer or trying to send more bytes, because otherwise we could
// corrupt an existing transmission.
void wait_for_sending_to_finish()
{
	while(!serial_send_buffer_empty(USB_COMM))
		serial_check();		// USB_COMM port is always in SERIAL_CHECK mode
}

// process_received_byte: Responds to a byte that has been received on
// USB_COMM.  If you are writing your own serial program, you can
// replace all the code in this function with your own custom behaviors.
void process_received_byte(char byte)
{
	clear();		// clear LCD
	print("Byte Received");
	lcd_goto_xy(0, 1);	// go to start of second LCD row
	print("RX: ");
	delay_ms(750);
/*	
byte = '3';*/
	switch(byte)
	{
		// State Machine-style setup for incoming Serial values; expecting ':::'
		// then single byte over Serial connection. Increment 'byte_counter'
		// for each ':' until we have three, then next Serial byte is valid.
		// Single byte is BPM with granularity of 6 from range 60-120.
		case ':':
			byte_counter += 1;
			print_character(byte);
			break;
			
		case 'a':
			test = 0;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
			
		case 'b':
			test = 1;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
						
		case 'c':
			test = 2;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
									
		case 'd':
			test = 3;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
			
		case 'e':
			test = 4;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'f':
			test = 5;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'g':
			test = 6;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'h':
			test = 7;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'i':
			test = 8;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'j':
			test = 9;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'k':
			test = 10;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'l':
			test = 11;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;	
			
		case 'm':
			test = 12;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
			
		case 'n':
			test = 13;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'o':
			test = 14;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'p':
			test = 15;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;	
			
		case 'q':
			test = 16;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'r':
			test = 17;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 's':
			test = 18;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 't':
			test = 19;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
			
		case 'u':
			test = 20;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'v':
			test = 21;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'w':
			test = 22;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'x':
			test = 23;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;		
						
		case 'y':
			test = 24;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
		
		case 'z':
			test = 25;
			print_long(test);
			delay_ms(100);
			byte_counter += 1;
			break;
/*		case '0':
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
*/
		// Default is to place byte in 'send_buffer'
		default:
			wait_for_sending_to_finish();
			send_buffer[0] = byte;// ^ 0x20;

			//green_led(TOGGLE);
			//print(byte_counter);
			//delay_ms(400);
			
			break;
	}
}

void check_for_new_bytes_received()
{
	while(serial_get_received_bytes(USB_COMM) != receive_buffer_position)
	{
		// Process the new byte that has just been received.
		process_received_byte(receive_buffer[receive_buffer_position]);

		// Increment receive_buffer_position, but wrap around when it gets to
		// the end of the buffer. 
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
	
	// Set the servo speed to 150.  This means that the pulse width
	// will change by at most 15 microseconds every 20 ms.  So it will
	// take 1.33 seconds to go from a pulse width of 1000 us to 2000 us.
	set_servo_speed(0, init_speed);
	set_servo_speed(1, init_speed);
	set_servo_speed(2, init_speed);
	set_servo_speed(3, init_speed);

	// Make all the servos go to a neutral position.
	set_servo_target(0, rt_shoulder_rot);	//right shoulder rotation
	set_servo_target(1, rt_elbow);				//right elbow
	set_servo_target(2, lt_shoulder_rot);	//left shoulder rotation
	set_servo_target(3, lt_elbow);			//left elbow
	
	clear();	// clear the LCD
	print("Robot Drummer");
	lcd_goto_xy(0, 1);	// go to start of second LCD row
	//print("or press Btn");
	print("Send BPM Mode");
	
	delay_ms(2000);

	// Set the baud rate to 9600 bits per second.  Each byte takes ten bit
	// times, so you can get at most 960 bytes per second at this speed.
	serial_set_baud_rate(USB_COMM, 9600);

	// Start receiving bytes in the ring buffer.
	serial_receive_ring(USB_COMM, receive_buffer, sizeof(receive_buffer));

    while(1)
    {
		// USB_COMM is always in SERIAL_CHECK mode, so we need to call this
		// function often to make sure serial receptions and transmissions
		// occur.
		serial_check();
		// Deal with any new bytes received unless we have a complete sample
		// of three ':' bytes, then 4th byte is desired BPM byte
		if (byte_counter < 4)
		{
			check_for_new_bytes_received();
		}			

		 //NEW Mode value key:
		 // a = 60 BPM
		 // b = 62 BPM
		 // c = 65 BPM
		 // d = 68 BPM
		 // e = 70 BPM
		 // f = 72 BPM
		 // g = 75 BPM
		 // h = 78 BPM
		 // i = 80 BPM
		 // j = 82 BPM
		 // k = 85 BPM
		 // l = 88 BPM
		 // m = 90 BPM
		 // n = 92 BPM
		 // o = 95 BPM
		 // p = 98 BPM
		 // q = 100 BPM
		 // r = 102 BPM
		 // s = 105 BPM
		 // t = 108 BPM
		 // u = 110 BPM
		 // v = 112 BPM
		 // w = 115 BPM
		 // x = 118 BPM
		 // y = 120 BPM

		//OLD Mode value key:
		// 0 = 60-65 BPM
		// 1 = 66-71 BPM
		// 2 = 72-77 BPM
		// 3 = 78-83 BPM
		// 4 = 84-89 BPM
		// 5 = 90-95 BPM
		// 6 = 96-101 BPM
		// 7 = 102-107 BPM
		// 8 = 108-113 BPM
		// 9 = 114-120 BPM
		
		// The 'flipper2' variable in this section and the next makes sure that
		// the drumming arms alternate beats. Only one of the two drumming arms
		// strikes the drum per beat, and the other is up in the air ready to
		// strike on the next beat.
		if ( flipper2 % 2 != 0 )
		{
			//set_servo_speed(0, servo_speed);
			set_servo_speed(1, servo_speed);
			//set_servo_speed(2, servo_speed);
			set_servo_speed(3, servo_speed);

			// Make all the servos go to a neutral position.
			//set_servo_target(0, rt_shoulder_rot_lt);	//right shoulder rotation
			set_servo_target(1, rt_elbow_dn);				//right elbow
			//set_servo_target(2, lt_shoulder_rot_rt);	//left shoulder rotation
			set_servo_target(3, lt_elbow_up);			//left elbow
			//set_servo_target(3, lt_elbow_up);			//make left elbow random for up
			if ( (rand()) % 2 != 0 )
			{
				set_servo_target(3, lt_elbow_up);			//left elbow
			}
			else
			{
				set_servo_target(3, lt_elbow_dn);			//left elbow
			}
		}
		else
		{
			//set_servo_speed(0, servo_speed);
			set_servo_speed(1, servo_speed);
			//set_servo_speed(2, servo_speed);
			set_servo_speed(3, servo_speed);

			// Make all the servos go to a neutral position.
			//set_servo_target(0, rt_shoulder_rot_lt);	//right shoulder rotation
			set_servo_target(1, rt_elbow_up);				//right elbow
			//set_servo_target(2, lt_shoulder_rot_rt);	//left shoulder rotation
			//set_servo_target(3, lt_elbow_dn);			//make left elbow random for down
			if ( (rand()) % 2 != 0 )
			{
				set_servo_target(3, lt_elbow_dn);			//left elbow
			}
			else
			{
				set_servo_target(3, lt_elbow_up);			//left elbow
			}							
		}
		
		flipper2 += 1;				// increment flipper2 toggle value
	
		if (test == 0)				// 0 = serial input 'a' = 60 BPM
		{
			clear();				// clear the LCD
			print("BPM = 60-61");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 500;
			//delay_ms(500);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
			
		}	
		else if (test == 1)			// 1 = serial input 'b' = 62 BPM
		{
			clear();				// clear the LCD
			print("BPM = 62-64");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 484;
			//delay_ms(440);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter

		}	
		else if (test == 2)			// 2 = serial input 'c' =65 BPM
		{

			clear();				// clear the LCD
			print("BPM = 65-67");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 462;
			//delay_ms(400);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
				
		}
		else if (test == 3)			// 3 = serial input 'd' = 68 BPM
		{
			clear();				// clear the LCD
			print("BPM = 68-69");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 441;
			//delay_ms(360);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter

			
		}
		else if (test == 4)			// 4 = serial input 'e' = 70 BPM
		{
			clear();				// clear the LCD
			print("BPM = 70-71");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 429;
			//delay_ms(345);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
			
		}
		else if (test == 5)			// 5 = serial input 'f' = 72 BPM
		{
			clear();				// clear the LCD
			print("BPM = 72-74");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 417;
			//delay_ms(335);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
				
		}
		else if (test == 6)			// 6 = serial input 'g' = 75 BPM
		{
			clear();				// clear the LCD
			print("BPM = 75-77");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 400;
			//delay_ms(310);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
		
		}
		else if (test == 7)			// 7 = serial input 'h' = 78 BPM
		{
			clear();				// clear the LCD
			print("BPM = 78-79");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 385;
			//delay_ms(290);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
	
		}
		else if (test == 8)			// 8 = serial input 'i' = 80 BPM
		{
			clear();				// clear the LCD
			print("BPM = 80-81");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 375;
			//delay_ms(270);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
		
		}
		else if (test == 9)			// 9 = serial input 'j' = 82 BPM
		{
			clear();				// clear the LCD
			print("BPM = 82-84");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 366;
			//delay_ms(250);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
	
		}
		else if (test == 10)		// 10 = serial input 'k' = 85 BPM
		{
			clear();				// clear the LCD
			print("BPM = 85-87");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 353;
			//delay_ms(440);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter

		}
		else if (test == 11)		// 11 = serial input 'l' = 88 BPM
		{

			clear();				// clear the LCD
			print("BPM = 88-89");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 341;
			//delay_ms(400);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
					
		}
		else if (test == 12)		// 12 = serial input 'm' = 90 BPM
		{
			clear();				// clear the LCD
			print("BPM = 90-91");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 333;
			//delay_ms(360);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter

					
		}
		else if (test == 13)		// 13 = serial input 'n' = 92 BPM
		{
			clear();				// clear the LCD
			print("BPM = 92-94");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 326;
			//delay_ms(345);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
					
		}
		else if (test == 14)		// 14 = serial input 'o' = 95 BPM
		{
			clear();				// clear the LCD
			print("BPM = 95-97");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 316;
			//delay_ms(335);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
					
		}
		else if (test == 15)		// 15 = serial input 'p' = 98 BPM
		{
			clear();				// clear the LCD
			print("BPM = 98-99");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 306;
			//delay_ms(310);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
					
		}
		else if (test == 16)		// 16 = serial input 'q' = 100 BPM
		{
			clear();				// clear the LCD
			print("BPM = 100-101");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 300;
			//delay_ms(290);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
					
		}
		else if (test == 17)		// 17 = serial input 'r' = 102 BPM
		{
			clear();				// clear the LCD
			print("BPM = 102-104");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 294;
			//delay_ms(270);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
					
		}
		else if (test == 18)		// 18 = serial input 's' = 105 BPM
		{
			clear();				// clear the LCD
			print("BPM = 105-107");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 286;
			//delay_ms(250);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;					//reset counter
					
		}
		else if (test == 19)		// 19 = serial input 't' = 108 BPM
		{
			clear();				// clear the LCD
			print("BPM = 108-109");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 278;
			//delay_ms(440);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter

		}
		else if (test == 20)		// 20 = serial input 'u' = 110 BPM
		{

			clear();				// clear the LCD
			print("BPM = 110-111");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 273;
			//delay_ms(400);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
			
		}
		else if (test == 21)		// 21 = serial input 'v' = 112 BPM
		{
			clear();				// clear the LCD
			print("BPM = 112-114");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 268;
			//delay_ms(360);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter

			
		}
		else if (test == 22)		// 22 = serial input 'w' = 115 BPM
		{
			clear();				// clear the LCD
			print("BPM = 115-117");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 261;
			//delay_ms(345);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
			
		}
		else if (test == 23)		// 23 = serial input 'x' = 118 BPM
		{
			clear();				// clear the LCD
			print("BPM = 118-119");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 254;
			//delay_ms(335);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
			
		}
		else if (test == 24)		// 24 = serial input 'y' = 120 BPM
		{
			clear();				// clear the LCD
			print("BPM = 120");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			green_led(TOGGLE);
			pb_delay = 250;
			//delay_ms(310);
			servo_speed = 200;		// faster BPM needs faster servo speed
			byte_counter = 0;		//reset counter
			
		}
		else if (test == 25)		// 25 = serial input 'z' = PAUSED
		{
			clear();				// clear the LCD
			print("PAUSED");
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("mode: ");
			print_long(test);
			delay_ms(200);
			byte_counter = 0;		//reset counter
			flipper2 = 1;			// set flipper2 toggle value to 1 so
									// that arms stop drumming in this mode
		
		}
		//Default mode of 60 BPM
		else
		{
			green_led(TOGGLE);
			clear();	// clear the LCD
			print("Robot Drummer");
			lcd_goto_xy(0, 1);	// go to start of second LCD row
			print("Default mode");
			pb_delay = 500;
			//delay_ms(pb_delay);
			servo_speed = 200;		// faster BPM needs faster servo speed
			
		}
		
		delay_ms(pb_delay);		//moved delay out of 'else if' tests to here
		
		// If the user presses the middle button, send "Robots Rule!"
		// and wait until the user releases the button.
		if (button_is_pressed(MIDDLE_BUTTON))
		{
			wait_for_sending_to_finish();
			memcpy_P(send_buffer, PSTR("Robots Rule!\r\n"), 12);
			serial_send(USB_COMM, send_buffer, 12);
			send_buffer[12] = 0;	// terminate the string
			clear();				// clear the LCD
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("Delay (ms): ");
			print_long(pb_delay);
			
			delay_ms(1000);
			byte_counter = 0;		// reset detect cycle by pressing button

			// Wait for the user to release the button.  While the processor is
			// waiting, the OrangutanSerial library will not be able to receive
			// bytes from the USB_COMM port since this requires calls to the
			// serial_check() function, which could cause serial bytes to be
			// lost.  It will also not be able to send any bytes, so the bytes
			// bytes we just queued for transmission will not be sent until
			// after the following blocking function exits once the button is
			// released. 
			wait_for_button_release(MIDDLE_BUTTON);
		}
		// If the user presses the TOP button, increment BPM Mode by 1
		if (button_is_pressed(TOP_BUTTON))
		{
			wait_for_sending_to_finish();
			clear();				// clear the LCD
			print("BPM Mode Up");
			
			if (test <= 25)			// BPM Mode '10' is wait state
			{
				test = test + 1;
			}
		
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("To Mode ");
			print_long(test);
			delay_ms(1000);
			byte_counter = 0;		// reset detect cycle by pressing button
			wait_for_button_release(TOP_BUTTON);
		}
		// If the user presses the BOTTOM button, decrement delay by 10 ms
		if (button_is_pressed(BOTTOM_BUTTON))
		{
			wait_for_sending_to_finish();
			clear();				// clear the LCD
			print("BPM Mode Down");
					
			if (test >= 1)		//fastest speed, 
			{
				test = test - 1;
			}
			
			lcd_goto_xy(0, 1);		// go to start of second LCD row
			print("To Mode ");
			print_long(test);
			delay_ms(1000);
			byte_counter = 0;		// reset detect cycle by pressing button
			wait_for_button_release(BOTTOM_BUTTON);
		}
    }
}
