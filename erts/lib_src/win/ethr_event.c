/*
 * %CopyrightBegin%
 *
 * Copyright Ericsson AB 2009-2010. All Rights Reserved.
 *
 * The contents of this file are subject to the Erlang Public License,
 * Version 1.1, (the "License"); you may not use this file except in
 * compliance with the License. You should have received a copy of the
 * Erlang Public License along with this software. If not, it can be
 * retrieved online at http://www.erlang.org/.
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * %CopyrightEnd%
 */

/*
 * Author: Rickard Green
 */

#define ETHR_INLINE_FUNC_NAME_(X) X ## __
#define ETHR_EVENT_IMPL__

#include "ethread.h"

/* --- Windows implementation of thread events ------------------------------ */

#pragma intrinsic(_InterlockedExchangeAdd)
#pragma intrinsic(_InterlockedCompareExchange)

int
ethr_event_init(ethr_event *e)
{
    e->state = ETHR_EVENT_OFF__;
    e->handle = CreateEvent(NULL, FALSE, FALSE, NULL);
    if (e->handle == INVALID_HANDLE_VALUE)
	return ethr_win_get_errno__();
    return 0;
}

int
ethr_event_destroy(ethr_event *e)
{
    BOOL res = CloseHandle(e->handle);
    return res == 0 ? ethr_win_get_errno__() : 0;
}

void
ethr_event_set(ethr_event *e)
{
    ethr_event_set__(e);
}

void
ethr_event_reset(ethr_event *e)
{
    ethr_event_reset__(e);
}

static ETHR_INLINE int
wait(ethr_event *e, int spincount)
{
    LONG state;
    DWORD code;
    int sc, res, until_yield = ETHR_YIELD_AFTER_BUSY_LOOPS;

    if (spincount < 0)
	ETHR_FATAL_ERROR__(EINVAL);

    sc = spincount;

    while (1) {
	long on;
	while (1) {
#if ETHR_READ_AND_SET_WITHOUT_INTERLOCKED_OP__
	    state = e->state;
#else
	    state = _InterlockedExchangeAdd(&e->state, (LONG) 0);
#endif
	    if (state == ETHR_EVENT_ON__)
		return 0;
	    if (sc == 0)
		break;
	    sc--;
	    ETHR_SPIN_BODY;
	    if (--until_yield == 0) {
		until_yield = ETHR_YIELD_AFTER_BUSY_LOOPS;
		res = ETHR_YIELD();
		if (res != 0)
		    ETHR_FATAL_ERROR__(res);
	    }
	}

	if (state != ETHR_EVENT_OFF_WAITER__) {
	    state = _InterlockedCompareExchange(&e->state,
						ETHR_EVENT_OFF_WAITER__,
						ETHR_EVENT_OFF__);
	    if (state == ETHR_EVENT_ON__)
		return 0;
	    ETHR_ASSERT(state == ETHR_EVENT_OFF__);
	}

	code = WaitForSingleObject(e->handle, INFINITE);
	if (code != WAIT_OBJECT_0)
	    ETHR_FATAL_ERROR__(ethr_win_get_errno__());
    }

}

int
ethr_event_wait(ethr_event *e)
{
    return wait(e, 0);
}

int
ethr_event_swait(ethr_event *e, int spincount)
{
    return wait(e, spincount);
}
