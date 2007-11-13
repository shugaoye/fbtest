
/*
 *  Test012
 *
 *  (C) Copyright 2007 Geert Uytterhoeven
 *
 *  This file is subject to the terms and conditions of the GNU General Public
 *  License. See the file COPYING in the main directory of this archive for
 *  more details.
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

#include "types.h"
#include "fb.h"
#include "drawops.h"
#include "visual.h"
#include "test.h"
#include "util.h"


static u32 sizes[] = { 10, 20, 50, 100, 200, 500, 1000 };


static uint64_t get_ticks(void)
{
    struct timeval tv;

    gettimeofday(&tv, NULL);
    return (uint64_t)tv.tv_sec*1000000 + tv.tv_usec;
}

static void draw_squares(u32 xrange, u32 yrange, u32 size, pixel_t pixelmask,
			 unsigned long n)
{
    while (n--)
	fill_rect(lrand48() % xrange, lrand48() % yrange, size, size,
		  lrand48() & pixelmask);
}

static void benchmark_squares(u32 size)
{
    u32 xr, yr;
    pixel_t pm;
    uint64_t ticks;
    double rate;
    unsigned long n = 1;

    xr = fb_var.xres-size+1;
    yr = fb_var.yres-size+1;
    pm = (1ULL << fb_var.bits_per_pixel)-1;

    printf("Benchmarking... ");
    while (n <<= 1) {
	ticks = get_ticks();
	draw_squares(xr, yr, size, pm, n);
	ticks = get_ticks() - ticks;
	if (ticks >= 500000)
	    break;
    }
    if (!n) {
	printf("CPU too fast :-)\n");
	return;
    }

    rate = (double)n*size*size/ticks;

    printf("%ux%u squares: %f Mpixels/s\n", size, size, rate);
}

static enum test_res test012_func(void)
{
    unsigned int i;
    u32 size;

    for (i = 0; i < sizeof(sizes)/sizeof(*sizes); i++) {
	size = sizes[i];
	if (size >= fb_var.xres || size >= fb_var.yres)
	    break;
	benchmark_squares(size);
    }

    wait_for_key(10);
    return TEST_OK;
}

const struct test test012 = {
    .name =	"test012",
    .desc =	"Filling squares",
    .visual =	VISUAL_GENERIC,
    .func =	test012_func,
};

