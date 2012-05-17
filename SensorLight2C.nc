/**
 * @file SensorLight2C.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: configuration file for Light2's sensor
 */
 
generic configuration SensorLight2C() {

	provides interface Read<uint16_t>;

} implementation {

	components MainC, RandomC;
	components new SensorLight2P();
	components new TimerMilliC();
	
	//Read interface wiring
	Read = SensorLight2P;
	
	//Timer interface wiring
	SensorLight2P.Timer -> TimerMilliC;

}
