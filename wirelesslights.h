/**
 * @file wirelesslights.h
 * @author Marco Zavatta
 * @date 17/05/2012
 * @brief IOT homework TinyOS: header file
 */

/* Conditional compilation to avoid multiple inclusion. */
#ifndef WIRELESSLIGHTS_H

	#define WIRELESSLIGHTS_H
	
	/* msg_type: CONTROL, INFO
	 * msg_senderid: sender's TOS_NODE_ID
	 * msg_value: LOFF, LON, ENTRY, EXIT
	 */
	typedef nx_struct my_msg {
		nx_uint8_t msg_type;
		nx_uint8_t msg_senderid;
		nx_uint8_t msg_value;
	} my_msg_t;

	/* Message types. */
	#define CONTROL (1)
	#define INFO 	(2)

	/* Message values. */
	#define	LON 	(1)
	#define LOFF	(2)

	#define ENTRY	(1)
	#define EXIT	(2)

	/* Node addresses. */
	#define CPANEL	(1)
	#define LIGHT1	(2)
	#define LIGHT2	(3)

	/* mSec delays. */
	#define SEC5	(5000)
	#define SEC10	(10000)
	#define SEC30	(30000)
	#define SEC60	(60000)
	#define SEC90	(90000)

	enum {
		AM_MY_MSG = 6,
	};

#endif
