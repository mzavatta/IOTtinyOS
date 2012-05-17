/**
 * @file wirelesslightsC.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: module file
 */

#include "wirelesslights.h"
#include "Timer.h"

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
   }
}

implementation {

   message_t packet;
   uint8_t rec_id;

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

	dbg("radio_send", "BOOTED!!\n");
	
     	/* Light 1. */
	if (TOS_NODE_ID==LIGHT1) {
		call Leds.led0Off();
	}

	/* Light 2. */
	if (TOS_NODE_ID==LIGHT2) {
		call Leds.led0Off();
	}

	call AMControl.start();
   }

   //***************** AMControl interface ********************//
   event void AMControl.startDone(error_t err) {
     if (err == SUCCESS) {

	/* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
      		call Timer1.startOneShot(SEC5);
		call Timer2.startOneShot(SEC90);
		dbg("radio_send", "Control panel timeouts set\n");
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		call Timer1.startOneShot(SEC10);
		call Timer2.startOneShot(SEC30);
		dbg("radio_send", "Light1 timeouts set\n");
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		call Timer1.startOneShot(SEC60);
		dbg("radio_send", "Light2 timeouts set\n");
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
		dbg("radio_send", "5 seconds\n");
      		post sendL1On();
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		dbg("radio_send", "10 seconds\n");
		post sendEntry();
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		dbg("radio_send", "60 seconds\n");
		post sendExit();
	}

   }

   //***************** Timer2 interface ********************//
   event void Timer2.fired() {

        /* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
		dbg("radio_send", "90 seconds\n");
      		post sendL1Off();
		post sendL2Off();
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		dbg("radio_send", "30 seconds\n");
		post sendL2On();
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		
	}

   }      

   //********************* AMSend interface ****************//
   event void AMSend.sendDone(message_t* buf,error_t err) {

	    if(&packet == buf && err == SUCCESS ) {
		dbg("radio_send", "Packet sent by %d\n", TOS_NODE_ID);
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
			if (mess->msg_value == ENTRY)
				if (mess->msg_senderid == LIGHT1)
					dbg("control_panel","Person entered notice by Light1\n");
				else if (mess->msg_senderid == LIGHT2)
					dbg("control_panel","Person entered notice by Light2\n");
			else if (mess->msg_value == EXIT) {
				if (mess->msg_senderid == LIGHT1)
					dbg("control_panel","Person exited notice by Light1\n");
				else if (mess->msg_senderid == LIGHT2)
					dbg("control_panel","Person exited notice by Light2\n");
			}
		}
	
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {

		if (mess->msg_type == CONTROL) {
			if (mess->msg_value == LON) {
				call Leds.led0On();
				dbg("control_panel","Light1 turned ON by %d\n", mess->msg_senderid);
			}
			else if (mess->msg_value == LOFF) {
				call Leds.led0Off();
				dbg("control_panel","Light1 turned OFF by %d\n", mess->msg_senderid);
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
				dbg("control_panel","Light2 turned ON by %d\n", mess->msg_senderid);
			}
			else if (mess->msg_value == LOFF) {
				call Leds.led0Off();
				dbg("control_panel","Light2 turned OFF by %d\n", mess->msg_senderid);
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
		dbg("radio_send", "Sending packet Light1 turned ON by %d\n", TOS_NODE_ID);
	}
   }

   task void sendL1Off() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LOFF;
	if(call AMSend.send(LIGHT1, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet Light1 turned OFF by %d\n", TOS_NODE_ID);
	}
   }
   
   task void sendL2On() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LON;
	if(call AMSend.send(LIGHT2, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet Light2 turned ON by %d\n", TOS_NODE_ID);
	}
   }

   task void sendL2Off() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LOFF;
	if(call AMSend.send(LIGHT2, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet Light2 turned OFF by %d\n", TOS_NODE_ID);
	}
   }

   task void sendEntry() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = INFO;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = ENTRY;
	if(call AMSend.send(CPANEL, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet Detected entrance by %d\n", TOS_NODE_ID);
	}
   }

   task void sendExit() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = INFO;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = EXIT;
	if(call AMSend.send(CPANEL, &packet, sizeof(my_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet Detected exit by %d\n", TOS_NODE_ID);
	}
   }   

}
