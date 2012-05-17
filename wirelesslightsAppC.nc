/**
 * @file wirelesslightsAppC.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: configuration file
 */

/**
 * Application components architecture:
 * wirelesslightsAppC, SensorLight1C, SensorLight2C
 * assigned to 3 motes:
 * Control Panel (wirelesslightsAppC)
 * Light1 (wirelesslightsAppC + SensorLight1C)
 * Light2 (wirelesslightsAppC + SensorLight2C)
 * the assignment is unfortunately only 'logic'
 * i.e. every mote carries the same code but uses it based on TOS_NODE_ID
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
	components new TimerMilliC() as Timer2;

	/* Sensor components. */
	components new SensorLight1C();
	components new SensorLight2C();

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

	//Radio Control interface
	wirelesslightsC.AMControl-> ActiveMessageC;

	//Interfaces to access package fields
	wirelesslightsC.AMPacket -> AMSenderC;
	wirelesslightsC.Packet -> AMSenderC;
	wirelesslightsC.PacketAcknowledgements->ActiveMessageC;

	//Timers interface
	wirelesslightsC.Timer1 -> Timer1;
	wirelesslightsC.Timer2 -> Timer2;

	//Sensor interfaces
	wirelesslightsC.Sensor1 -> SensorLight1C;
	wirelesslightsC.Sensor2 -> SensorLight2C;

}

