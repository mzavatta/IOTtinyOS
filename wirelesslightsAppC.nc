/**
 * @file wirelesslightsAppC.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: configuration file
 */

#include "wirelesslights.h"

configuration wirelesslightsAppC {
}

implementation {


	/******** Component Instantiations **************/

	/* Application component. */
	components wirelesslightsC;

	/* Main, leds and timer components. */
	components MainC, LedsC;
	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as TImer2;

	/* Message passing components. */
	components new AMSenderC(AM_MY_MSG);
	components new AMReceiverC(AM_MY_MSG);
	components ActiveMessageC;

	/******** Wirings *******************************/
	//Boot interface
	wirelesslightsC.Boot -> MainC.Boot;

	//Leds interface
	wirelesslightsC.Leds -> LedsC;

	//Send and Receive interfaces
	wirelesslightsC.Receive -> AMReceiverC;
	wirelesslightsC.AMSend -> AMSenderC;

	//Radio Control
	wirelesslightsC.AMControl-> ActiveMessageC;

	//Interfaces to access package fields
	wirelesslightsC.AMPacket -> AMSenderC;
	wirelesslightsC.Packet -> AMSenderC;
	wirelesslightsC.PacketAcknowledgements->ActiveMessageC;

	//Timers interface
	wirelesslightsC.Timer1 -> Timer1;
	wirelesslightsC.Timer2 -> Timer2;

}

