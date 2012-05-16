/**
 * @file wirelesslightsC.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: module file
 */

#include "sendAck.h"
#include "Timer.h"

module wirelesslightsC {

   uses {
	/* Need to simulate max two time-triggered events for each device. */ 
      	interface Timer<TMilli> as Timer1;
      	interface Timer<TMilli> as Timer2;

      	interface Leds;
      	interface Boot;
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

   event void Boot.booted() {

     	/* Light 1. */
	if (TOS_NODE_ID==LIGHT1) {
		//Turn off
	}

	/* Light 2. */
	if (TOS_NODE_ID==LIGHT2) {
		//Turn off
	}

	call AMControl.start();
   }

   //***************** AMControl interface ********************//
   event void AMControl.startDone(error_t err) {
     if (err == SUCCESS) {

	/* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
      		call Timer1.startPeriodic(5SEC);
		call Timer2.startPeriodic(90SEC);
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		call Timer1.startPeriodic(10SEC);
		call Timer2.startPeriodic(30SEC);
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		call Timer1.startPeriodic(60SEC);
	}
	
     }
     else {
      	call AMControl.start();
     }
   }

   event void SplitControl.stopDone(error_t err) {
   }

   //***************** Timer1 interface ********************//
   event void Timer1.fired() {

        /* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
      		post sendL1On();
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		post sendEntry();
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		post sendExit();
	}

   }

   //***************** Timer2 interface ********************//
   event void Timer2.fired() {

        /* Control panel. */
	if (TOS_NODE_ID==CPANEL) {
      		post sendL1Off();
		post sendL2Off();
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {
		post sendL2On();
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {
		
	}

   }      

   //********************* AMSend interface ****************//
   event void AMSend.sendDone(message_t* buf,error_t err) {

		/*
	    if(&packet == buf && err == SUCCESS ) {
		dbg("radio_send", "Packet sent...");

		if ( call PacketAcknowledgements.wasAcked( buf ) ) {
		  dbg_clear("radio_ack", "and ack received");
		  call MilliTimer.stop();
		} else {
		  dbg_clear("radio_ack", "but ack was not received");
		}
		dbg_clear("radio_send", " at time %s \n", sim_time_string());
	    }
	*/

   }

   //***************************** Receive interface *****************//
   event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {

	my_msg_t* mess=(my_msg_t*)payload;
	rec_id = mess->msg_id;

	/* Control panel. */
	if (TOS_NODE_ID==CPANEL) {

      		if (mess->msg_type == CONTROL) {
		}
		
		else if (mess->msg_type == INFO) {
			if (mess->msg_value == ENTRY)
				if (mess->msg_senderid == LIGHT1)
					dbg("Control panel","Person entered notice by Light1");
				else if (mess->msg_senderid == LIGHT2)
					dbg("Control panel","Person entered notice by Light2");
			else if (mess->msg_value == EXIT) {
				if (mess->msg_senderid == LIGHT1)
					dbg("Control panel","Person exited notice by Light1");
				else if (mess->msg_senderid == LIGHT2)
					dbg("Control panel","Person exited notice by Light2");
			}
		}
	
	}
	
	/* Light 1. */
	else if (TOS_NODE_ID==LIGHT1) {

		if (mess->msg_type == CONTROL) {
			if (mess->msg_value == LON) Leds.led0On();
			else if (mess->msg_value == LOFF) Leds.led00ff();
		}
		
		else if (mess->msg_type == INFO) {
		}
		
	}

	/* Light 2. */
	else if (TOS_NODE_ID==LIGHT2) {

		if (mess->msg_type == CONTROL) {
			if (mess->msg_value == LON) Leds.led0On();
			else if (mess->msg_value == LOFF) Leds.led00ff();
		}
		
		else if (mess->msg_type == INFO) {
		}
		
	}
	
	dbg("radio_pack",">>>Pack \n \t Payload length %hhu \n", call Packet.payloadLength( buf ) );

        return buf;

   }

   //***************** Tasks  ****************************************//

   task void sendL1On() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LON;
	dbg("radio_send", "Sending packet Light1 turned ON by %d", TOS_NODE_ID);
	if(call AMSend.send(LIGHT1, &packet, sizeof(my_msg_t)) == SUCCESS){
		
	}
   }

   task void sendL1Off() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LOFF;
	dbg("radio_send", "Sending packet Light1 turned OFF by %d", TOS_NODE_ID);
	if(call AMSend.send(LIGHT1, &packet, sizeof(my_msg_t)) == SUCCESS){
	}
   }
   
   task void sendL2On() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LON;
	dbg("radio_send", "Sending packet Light2 turned ON by %d", TOS_NODE_ID);
	if(call AMSend.send(LIGHT2, &packet, sizeof(my_msg_t)) == SUCCESS){
	}
   }

   task void sendL2Off() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = CONTROL;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = LOFF;
	dbg("radio_send", "Sending packet Light2 turned OFF by %d", TOS_NODE_ID);
	if(call AMSend.send(LIGHT2, &packet, sizeof(my_msg_t)) == SUCCESS){
	}
   }

   task void sendEntry() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = INFO;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = ENTRY;
	dbg("radio_send", "Sending packet Detected entrance by %d", TOS_NODE_ID);
	if(call AMSend.send(CPANEL, &packet, sizeof(my_msg_t)) == SUCCESS){
	}
   }

   task void sendExit() {
	my_msg_t* mess = (my_msg_t*)call Packet.getPayload(&packet,sizeof(my_msg_t));
	mess->msg_type = INFO;
	mess->msg_senderid = TOS_NODE_ID;
	mess->msg_value = EXIT;
	dbg("radio_send", "Sending packet Detected exit by %d", TOS_NODE_ID);
	if(call AMSend.send(CPANEL, &packet, sizeof(my_msg_t)) == SUCCESS){
	}
   }   

}
