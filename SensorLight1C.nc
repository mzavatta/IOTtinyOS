/**
 * @file SensorLight1C.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: configuration file for Light1's sensor
 */
 
generic configuration SensorLight1C() {

	provides interface Read<uint16_t>;

} implementation {

	components MainC;
	components new SensorLight1P();
	components new TimerMilliC();
	
	//Read interface wiring
	Read = SensorLight1P;
	
	//Timer interface wiring	
	SensorLight1P.Timer -> TimerMilliC;

}
