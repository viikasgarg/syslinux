#ifndef ETHERBOOT_H
#define ETHERBOOT_H

/*
 * Standard includes that we always want
 *
 */

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <strings.h>
#include <console.h>
#include <gpxe/timer.h>
#include <gpxe/if_arp.h>
#include <gpxe/if_ether.h>

typedef unsigned long Address;

/*
 * IMPORTANT!!!!!!!!!!!!!!
 *
 * Everything below this point is cruft left over from older versions
 * of Etherboot.  Do not add *anything* below this point.  Things are
 * gradually being moved to individual header files.
 *
 */

/* Link configuration time in tenths of a second */
#ifndef VALID_LINK_TIMEOUT
#define VALID_LINK_TIMEOUT	100 /* 10.0 seconds */
#endif

/*
 * Local variables:
 *  c-basic-offset: 8
 * End:
 */

#endif /* ETHERBOOT_H */
