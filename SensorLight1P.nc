/**
 * @file SensorLight1P.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: implementation file for Light1's sensor
 */
 
#include "wirelesslights.h"

generic module SensorLight1P() {

	provides interface Read<uint16_t>;
	uses interface Timer<TMilli> as Timer;

} implementation {

	//***************** Setup interface ********************//
	command error_t Read.read(){
		call Timer.startOneShot(SEC10);
		return SUCCESS;
	}

	//***************** Timer interface ********************//
	event void Timer.fired() {
		signal Read.readDone( SUCCESS, 0 );
	}
}
