/**
 * @file wirelesslights.h
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: header file
 */

typedef nx_struct my_msg_t {
	nx_uint8_t msg_type;
	nx_uint8_t msg_senderid;
	nx_uint8_t msg_value;
} my_msg_t;

#define CONTROL (1)
#define INFO 	(2)

#define	LON 	(1)
#define LOFF	(2)

#define ENTRY	(1)
#define EXIT	(2)

#define CPANEL	(1)
#define LIGHT1	(2)
#define LIGHT2	(3)

#define 5SEC	(5000)
#define 10SEC	(10000)
#define 30SEC	(30000)
#define 60SEC	(60000)
#define 90SEC	(90000)

enum{
AM_MY_MSG = 6,
};


/* How can I disambiguate between them at runtime? */
/* Need to cast to something fixed and then disambiguate based on some known field! */
/*
typedef nx_struct control_msg_t {
	nx_uint8_t status;
} control_msg_t;

typedef nx_struct info_msg_t {
	nx_uint8_t msg_type;
	nx_uint16_t msg_id;
	nx_uint16_t value;
} info_msg_t;
*/
