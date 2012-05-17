/**
 * @file wirelesslightsC.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: module file
 */

#include "wirelesslights.h"
#include "Timer.h"

/**
 * The same component will be loaded on the three devices.
 * Their behavior is diversified based on TOS_NODE_ID.
 * Device		TOS_NODE_ID
 * Control Panel	1
 * Light1		2
 * Light2		3
 * Sensor events are signalled by one-shot timers expiry.
 */

module wirelesslightsC {

   uses {
	/* Need to simulate max two time-triggered events for each device. */ 
      	interface Timer<TMilli> as Timer1;
      	interface Timer<TMilli> as Timer2;

	interface Boot;
      	interface Leds;
      	interface AMPacket;
      	interface Packet;
      	interface PacketAcknowledgements;
      	interface AMSend;
      	interface SplitControl as AMControl;
      	interface Receive;
	interface Read<uint16_t> as Sensor1;
	interface Read<uint16_t> as Sensor2;
   }
}

implementation {

   /* Memory allocation for the packet structure. */
   message_t packet;
   
   /* Refer to Timer2.fired() for an explanation of p's role. */
   uint8_t p = 0;

   /* Tasks instantiations. */
   task void sendL1On();
   task void sendL1Off();
   task void sendL2On();
   task void sendL2Off();
   task void sendEntry();
   task void sendExit();

   /*
    * No events provided by Packet, PacketAknowledgements, AMPacket
    */

   //****************** Boot interface ************************//
   event void Boot.booted() {
	
     	/* Light 1. */
	if (TOS_NODE_ID==LIGHT1) {
		dbg("light1", "Light1 booted!\n");	
		call Leds.led0Off();
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		dbg("light2", "Light2 booted!\n");	
		call Leds.led0Off();
	}

	else dbg("cpanel", "Control Panel booted!\n");

	call AMControl.start();
   }

   //***************** AMControl interface ********************//
   event void AMControl.startDone(error_t err) {
     if (err == SUCCESS) {

	/* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
      		call Timer1.startOneShot(SEC5);
		call Timer2.startOneShot(SEC90);
		dbg("cpanel", "Control panel timeouts set\n");
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		//call Timer1.startOneShot(SEC10);
		call Sensor1.read();
		call Timer2.startOneShot(SEC30);
		dbg("light1", "Light1 timeouts set\n");
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		call Sensor2.read();
		dbg("light2", "Light2 timeouts set\n");
	}
	
     }
     else {
      	call AMControl.start();
     }
   }

   event void AMControl.stopDone(error_t err) {
   }

   //***************** Timer1 interface ********************//
   event void Timer1.fired() {

        /* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
		dbg("cpanel", "5 seconds\n");
      		post sendL1On();
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
	}

   }

   //***************** Timer2 interface ********************//
   event void Timer2.fired() {

        /* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
		dbg("cpanel", "90 seconds\n");
		
		/* Need to send two packets, though I cannot post the second task
		 * untill after AMSend.sendDone() of the first one has been called.
		 * The second task is therefore posted into AMSend.sendDone() and this
		 * fact is adverised by the p flag.
		 */
		p=2;

		post sendL1Off();    
		
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		dbg("light1", "30 seconds\n");
		post sendL2On();
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
	}

   }

   //************************* Sensor1 interface **********************//
   event void Sensor1.readDone(error_t result, uint16_t data) {
		dbg("light1", "10 seconds (from Sensor1)\n");
		post sendEntry();
   }

   //************************* Sensor2 interface **********************//
   event void Sensor2.readDone(error_t result, uint16_t data) {
		dbg("light2", "60 seconds (from Sensor2)\n");
		post sendExit();
   }

   //********************* AMSend interface ****************//
   event void AMSend.sendDone(message_t* buf,error_t err) {

	    if(&packet == buf && err == SUCCESS ) {
		if (TOS_NODE_ID==CPANEL) dbg("cpanel", "Packet sent by Control Panel\n");
		else if (TOS_NODE_ID==LIGHT1) dbg("light1", "Packet sent by Light1\n");
		else if (TOS_NODE_ID==LIGHT2) dbg("light2", "Packet sent by Light2\n");
	    }

	    /* Refer to Timer2.fired() for an explanation of this task post. */	
	    if(p == 2) {
		p=0;
		post sendL2Off();
	    }
   }

   //***************************** Receive interface *****************//
   event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

	my_msg_t* mess = (my_msg_t*)payload;

	/* Control panel. */
	if (TOS_NODE_ID==CPANEL) {

      		if (mess->msg_type == CONTROL) {
		}
		
		else if (mess->msg_type == INFO) {
			if (mess->msg_value == ENTRY) {
				if (mess->msg_senderid == LIGHT1)
					dbg("cpanel","Received person entered notice by Light1\n");
				else if (mess->msg_senderid == LIGHT2)
					dbg("cpanel","Received person entered notice by Light2\n");
				}
			else if (mess->msg_value == EXIT) {
				if (mess->msg_senderid == LIGHT1)
					dbg("cpanel","Received person exit notice by Light1\n");
				else if (mess->msg_senderid == LIGHT2)
					dbg("cpanel","Received person exit notice by Light2\n");
			}
		}
	
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {

		if (mess->msg_type == CONTROL) {
			if (mess->msg_value == LON) {
				call Leds.led0On();
				dbg("light1","Received Light1 turned ON by %d\n", mess->msg_senderid);
			}
			else if (mess->msg_value == LOFF) {
				call Leds.led0Off();
				dbg("light1","Received Light1 turned OFF by %d\n", mess->msg_senderid);
			}
		}
		
		else if (mess->msg_type == INFO) {
		}
		
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {

		if (mess->msg_type == CONTROL) {
			if (mess->msg_value == LON) {
				call Leds.led0On();
				dbg("light2","Received Light2 turned ON by %d\n", mess->msg_senderid);
			}
			else if (mess->msg_value == LOFF) {
				call Leds.led0Off();
				dbg("light2","Received Light2 turned OFF by %d\n", mess->msg_senderid);
			}
		}
		
		else if (mess->msg_type == INFO) {
		}
		
	}

        return buf;

   }

   //***************** Tasks  ****************************************//
   task void sendL1On() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LON;
	if(call AMSend.send(LIGHT1, &packet, sizeof(my_msg_t)) == SUCCESS) {
		if (TOS_NODE_ID==CPANEL) dbg("cpanel", "Sending packet from Control Panel to Light1: turn ON\n");
		else if (TOS_NODE_ID==LIGHT1) dbg("light1", "Sending packet from Light1 to Light1: turn ON\n");
		else if (TOS_NODE_ID==LIGHT2) dbg("light2", "Sending packet from Light2 to Light1: turn ON\n");
	}
   }

   task void sendL1Off() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LOFF;
	if(call AMSend.send(LIGHT1, &packet, sizeof(my_msg_t)) == SUCCESS) {
		if (TOS_NODE_ID==CPANEL) dbg("cpanel", "Sending packet from Control Panel to Light1: turn OFF\n");
		else if (TOS_NODE_ID==LIGHT1) dbg("light1", "Sending packet from Light1 to Light1: turn OFF\n");
		else if (TOS_NODE_ID==LIGHT2) dbg("light2", "Sending packet from Light2 to Light1: turn OFF\n");
	}
   }
   
   task void sendL2On() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LON;
	if(call AMSend.send(LIGHT2, &packet, sizeof(my_msg_t)) == SUCCESS) {
		if (TOS_NODE_ID==CPANEL) dbg("cpanel", "Sending packet from Control Panel to Light2: turn ON\n");
		else if (TOS_NODE_ID==LIGHT1) dbg("light1", "Sending packet from Light1 to Light2: turn ON\n");
		else if (TOS_NODE_ID==LIGHT2) dbg("light2", "Sending packet from Light2 to Light2: turn ON\n");
	}
   }

   task void sendL2Off() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LOFF;
	if(call AMSend.send(LIGHT2, &packet, sizeof(my_msg_t)) == SUCCESS) {
		if (TOS_NODE_ID==CPANEL) dbg("cpanel", "Sending packet from Control Panel to Light2: turn OFF\n");
		else if (TOS_NODE_ID==LIGHT1) dbg("light1", "Sending packet from Light1 to Light2: turn OFF\n");
		else if (TOS_NODE_ID==LIGHT2) dbg("light2", "Sending packet from Light2 to Light2: turn OFF\n");
	}
   }

   task void sendEntry() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = INFO;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = ENTRY;
	if(call AMSend.send(CPANEL, &packet, sizeof(my_msg_t)) == SUCCESS) {
		if (TOS_NODE_ID==CPANEL) dbg("cpanel", "Sending packet from Control Panel to Control Panel: detected entrance\n");
		else if (TOS_NODE_ID==LIGHT1) dbg("light1", "Sending packet from Light1 to Control Panel: detected entrance\n");
		else if (TOS_NODE_ID==LIGHT2) dbg("light2", "Sending packet from Light2 to Control Panel: detected entrance\n");
	}
   }

   task void sendExit() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = INFO;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = EXIT;
	if(call AMSend.send(CPANEL, &packet, sizeof(my_msg_t)) == SUCCESS) {
		if (TOS_NODE_ID==CPANEL) dbg("cpanel", "Sending packet from Control Panel to Control Panel: detected exit\n");
		else if (TOS_NODE_ID==LIGHT1) dbg("light1", "Sending packet from Light1 to Control Panel: detected exit\n");
		else if (TOS_NODE_ID==LIGHT2) dbg("light2", "Sending packet from Light2 to Control Panel: detected exit\n");
	}
   }   

}
