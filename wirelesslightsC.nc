/**
 * @file wirelesslightsC.nc
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: module file
 */

#include "sendAck.h"
#include "Timer.h"

module wirelesslightsC {

}

implementation {

   message_t packet;

   event void Boot.booted() {
     call AMControl.start();
   }

   event void AMControl.startDone(error_t err) {
     if (err == SUCCESS) {
      

     }
     else {
      call AMControl.start();
     }
   }

}
