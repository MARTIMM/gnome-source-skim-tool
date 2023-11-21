Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Gnome::Glib::T-Main
===================

Class initialization
====================

new
---

Initialization of a type class is simple.

    method new ( )

Bitfields
=========

GMainContextFlags
-----------------

Flags to pass to `.context-new-with-flags()` which affect the behaviour of a GMainContext.

  * `G_MAIN_CONTEXT_FLAGS_NONE`; Default behaviour.

  * `G_MAIN_CONTEXT_FLAGS_OWNERLESS_POLLING`; Assume that polling for events will free the thread to process other jobs. That's useful if you're using `g_main_context_{prepare,query,check,dispatch}` to integrate GMainContext in other event loops.

Standalone Functions
====================

child-watch-add
---------------

Sets a function to be called when the child indicated by `$pid` exits, at a default priority, %G_PRIORITY_DEFAULT.

If you obtain `$pid` from g_spawn_async() or g_spawn_async_with_pipes() you will need to pass %G_SPAWN_DO_NOT_REAP_CHILD as flag to the spawn function for the child watching to work.

Note that on platforms where GPid must be explicitly closed (see g_spawn_close_pid()) `$pid` must not be closed while the source is still active. Typically, you will want to call g_spawn_close_pid() in the callback function for the source.

GLib supports only a single callback per process id. On POSIX platforms, the same restrictions mentioned for g_child_watch_source_new() apply to this function.

This internally creates a main loop source using g_child_watch_source_new() and attaches it to the main loop context using g_source_attach(). You can do these steps manually if you need greater control.

    method child-watch-add ( …, &function, gpointer $data --> UInt )

  * pid; process id to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).. Note that each argument must be specified as a type followed by its value!

  * &function; function to call. Tthe function must be specified with following signature; `:( $pid, gint $wait-status, gpointer $user-data )`.

  * $data; data to pass to `$function`.

Return value; the ID (greater than 0) of the event source.. 

child-watch-add-full
--------------------

Sets a function to be called when the child indicated by `$pid` exits, at the priority `$priority`.

If you obtain `$pid` from g_spawn_async() or g_spawn_async_with_pipes() you will need to pass %G_SPAWN_DO_NOT_REAP_CHILD as flag to the spawn function for the child watching to work.

In many programs, you will want to call g_spawn_check_wait_status() in the callback to determine whether or not the child exited successfully.

Also, note that on platforms where GPid must be explicitly closed (see g_spawn_close_pid()) `$pid` must not be closed while the source is still active. Typically, you should invoke g_spawn_close_pid() in the callback function for the source.

GLib supports only a single callback per process id. On POSIX platforms, the same restrictions mentioned for g_child_watch_source_new() apply to this function.

This internally creates a main loop source using g_child_watch_source_new() and attaches it to the main loop context using g_source_attach(). You can do these steps manually if you need greater control.

    method child-watch-add-full ( Int() $priority, …, &function, gpointer $data, &notify --> UInt )

  * $priority; the priority of the idle source. Typically this will be in the range between %G_PRIORITY_DEFAULT_IDLE and %G_PRIORITY_HIGH_IDLE..

  * pid; process to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).. Note that each argument must be specified as a type followed by its value!

  * &function; function to call. Tthe function must be specified with following signature; `:( $pid, gint $wait-status, gpointer $user-data )`.

  * $data; data to pass to `$function`.

  * &notify; function to call when the idle is removed, or `Nil`. Tthe function must be specified with following signature; `:( gpointer $data )`.

Return value; the ID (greater than 0) of the event source.. 

child-watch-source-new
----------------------

Creates a new child_watch source.

The source will not initially be associated with any GMainContext and must be added to one with g_source_attach() before it will be executed.

Note that child watch sources can only be used in conjunction with `g_spawn...` when the %G_SPAWN_DO_NOT_REAP_CHILD flag is used.

Note that on platforms where GPid must be explicitly closed (see g_spawn_close_pid()) `$pid` must not be closed while the source is still active. Typically, you will want to call g_spawn_close_pid() in the callback function for the source.

On POSIX platforms, the following restrictions apply to this API due to limitations in POSIX process interfaces:

* `$pid` must be a child of this process * `$pid` must be positive * the application must not call `waitpid` with a non-positive first argument, for instance in another thread * the application must not wait for `$pid` to exit by any other mechanism, including `waitpid(pid, ...)` or a second child-watch source for the same `$pid` * the application must not ignore `SIGCHLD`

If any of those conditions are not met, this and related APIs will not work correctly. This can often be diagnosed via a GLib warning stating that `ECHILD` was received by `waitpid`.

Calling `waitpid` for specific processes other than `$pid` remains a valid thing to do.

    method child-watch-source-new ( … --> CArray[N-Source]  )

  * pid; process to watch. On POSIX the positive pid of a child process. On Windows a handle for a process (which doesn't have to be a child).. Note that each argument must be specified as a type followed by its value!

Return value; the newly-created child watch source. 

clear-handle-id
---------------

Clears a numeric handler, such as a GSource ID. `$tag_ptr` must be a valid pointer to the variable holding the handler.

If the ID is zero then this function does nothing. Otherwise, clear_func() is called with the ID as a parameter, and the tag is set to zero.

A macro is also included that allows this function to be used without pointer casts.

    method clear-handle-id ( Array[Int] $tag-ptr, &clear-func )

  * $tag-ptr; a pointer to the handler ID.

  * &clear-func; the function to call to clear the handler. Tthe function must be specified with following signature; `:( guint $handle-id )`.

get-current-time
----------------

Equivalent to the UNIX gettimeofday() function, but portable.

You may find g_get_real_time() to be more convenient.

    method get-current-time ( CArray[N-TimeVal]  $result )

  * $result; GTimeVal structure in which to store current time..

get-monotonic-time
------------------

Queries the system monotonic time.

The monotonic clock will always increase and doesn't suffer discontinuities when the user (or NTP) changes the system time. It may or may not continue to tick during times where the machine is suspended.

We try to use the clock that corresponds as closely as possible to the passage of time as measured by system calls such as poll() but it may not always be possible to do this.

    method get-monotonic-time (--> Int )

Return value; the monotonic time, in microseconds. 

get-real-time
-------------

Queries the system wall-clock time.

This call is functionally equivalent to g_get_current_time() except that the return value is often more convenient than dealing with a GTimeVal.

You should only use this call if you are actually interested in the real wall-clock time. g_get_monotonic_time() is probably more useful for measuring intervals.

    method get-real-time (--> Int )

Return value; the number of microseconds since January 1, 1970 UTC.. 

idle-add
--------

Adds a function to be called whenever there are no higher priority events pending to the default main loop. The function is given the default idle priority, %G_PRIORITY_DEFAULT_IDLE. If the function returns `False` it is automatically removed from the list of event sources and will not be called again.

See memory management of sources for details on how to handle the return value and memory management of `$data`.

This internally creates a main loop source using g_idle_source_new() and attaches it to the global GMainContext using g_source_attach(), so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

    method idle-add ( &function, gpointer $data --> UInt )

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`..

Return value; the ID (greater than 0) of the event source.. 

idle-add-full
-------------

Adds a function to be called whenever there are no higher priority events pending.

If the function returns %G_SOURCE_REMOVE or `False` it is automatically removed from the list of event sources and will not be called again.

See memory management of sources for details on how to handle the return value and memory management of `$data`.

This internally creates a main loop source using g_idle_source_new() and attaches it to the global GMainContext using g_source_attach(), so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

    method idle-add-full ( Int() $priority, &function, gpointer $data, &notify --> UInt )

  * $priority; the priority of the idle source. Typically this will be in the range between %G_PRIORITY_DEFAULT_IDLE and %G_PRIORITY_HIGH_IDLE..

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`.

  * &notify; function to call when the idle is removed, or `Nil`. Tthe function must be specified with following signature; `:( gpointer $data )`.

Return value; the ID (greater than 0) of the event source.. 

idle-remove-by-data
-------------------

Removes the idle function with the given data.

    method idle-remove-by-data ( gpointer $data --> Bool )

  * $data; the data for the idle source's callback..

Return value; `True` if an idle source was found and removed.. 

idle-source-new
---------------

Creates a new idle source.

The source will not initially be associated with any GMainContext and must be added to one with g_source_attach() before it will be executed. Note that the default priority for idle sources is %G_PRIORITY_DEFAULT_IDLE, as compared to other sources which have a default priority of %G_PRIORITY_DEFAULT.

    method idle-source-new (--> CArray[N-Source]  )

Return value; the newly-created idle source. 

main-current-source
-------------------

Returns the currently firing source for this thread.

    method main-current-source (--> CArray[N-Source]  )

Return value; The currently firing source or `Nil`.. 

main-depth
----------

Returns the depth of the stack of calls to `.context-dispatch()` on any GMainContext in the current thread. That is, when called from the toplevel, it gives 0. When called from within a callback from `.context-iteration()` (or `.loop-run()`, etc.) it returns 1. When called from within a callback to a recursive call to `.context-iteration()`, it returns 2. And so forth.

This function is useful in a situation like the following: Imagine an extremely simple "garbage collected" system.

This works from an application, however, if you want to do the same thing from a library, it gets more difficult, since you no longer control the main loop. You might think you can simply use an idle function to make the call to free_allocated_memory(), but that doesn't work, since the idle function could be called from a recursive callback. This can be fixed by using `.depth()`

There is a temptation to use `.depth()` to solve problems with reentrancy. For instance, while waiting for data to be received from the network in response to a menu item, the menu item might be selected again. It might seem that one could make the menu item's callback return immediately and do nothing if `.depth()` returns a value greater than 1. However, this should be avoided since the user then sees selecting the menu item do nothing. Furthermore, you'll find yourself adding these checks all over your code, since there are doubtless many, many things that the user could do. Instead, you can use the following techniques:

1. Use gtk_widget_set_sensitive() or modal dialogs to prevent the user from interacting with elements while the main loop is recursing.

2. Avoid main loop recursion in situations where you can't handle arbitrary callbacks. Instead, structure your code so that you simply return to the main loop and then get called again when there is more work to do.

    method main-depth (--> Int )

Return value; The main loop recursion level in the current thread. 

timeout-add
-----------

Sets a function to be called at regular intervals, with the default priority, %G_PRIORITY_DEFAULT.

The given `$function` is called repeatedly until it returns %G_SOURCE_REMOVE or `False`, at which point the timeout is automatically destroyed and the function will not be called again. The first call to the function will be at the end of the first `$interval`.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).

See memory management of sources for details on how to handle the return value and memory management of `$data`.

If you want to have a timer in the "seconds" range and do not care about the exact time of the first call of the timer, use the g_timeout_add_seconds() function; this function allows for more optimizations and more efficient system power usage.

This internally creates a main loop source using g_timeout_source_new() and attaches it to the global GMainContext using g_source_attach(), so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

It is safe to call this function from any thread.

The interval given is in terms of monotonic time, not wall clock time. See g_get_monotonic_time().

    method timeout-add ( UInt() $interval, &function, gpointer $data --> UInt )

  * $interval; the time between calls to the function, in milliseconds (1/1000ths of a second).

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`.

Return value; the ID (greater than 0) of the event source.. 

timeout-add-full
----------------

Sets a function to be called at regular intervals, with the given priority. The function is called repeatedly until it returns `False`, at which point the timeout is automatically destroyed and the function will not be called again. The `$notify` function is called when the timeout is destroyed. The first call to the function will be at the end of the first `$interval`.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given interval (it does not try to 'catch up' time lost in delays).

See memory management of sources for details on how to handle the return value and memory management of `$data`.

This internally creates a main loop source using g_timeout_source_new() and attaches it to the global GMainContext using g_source_attach(), so the callback will be invoked in whichever thread is running that main context. You can do these steps manually if you need greater control or to use a custom main context.

The interval given is in terms of monotonic time, not wall clock time. See g_get_monotonic_time().

    method timeout-add-full ( Int() $priority, UInt() $interval, &function, gpointer $data, &notify --> UInt )

  * $priority; the priority of the timeout source. Typically this will be in the range between %G_PRIORITY_DEFAULT and %G_PRIORITY_HIGH..

  * $interval; the time between calls to the function, in milliseconds (1/1000ths of a second).

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`.

  * &notify; function to call when the timeout is removed, or `Nil`. Tthe function must be specified with following signature; `:( gpointer $data )`.

Return value; the ID (greater than 0) of the event source.. 

timeout-add-seconds
-------------------

Sets a function to be called at regular intervals with the default priority, %G_PRIORITY_DEFAULT.

The function is called repeatedly until it returns %G_SOURCE_REMOVE or `False`, at which point the timeout is automatically destroyed and the function will not be called again.

This internally creates a main loop source using g_timeout_source_new_seconds() and attaches it to the main loop context using g_source_attach(). You can do these steps manually if you need greater control. Also see g_timeout_add_seconds_full().

It is safe to call this function from any thread.

Note that the first call of the timer may not be precise for timeouts of one second. If you need finer precision and have such a timeout, you may want to use g_timeout_add() instead.

See memory management of sources for details on how to handle the return value and memory management of `$data`.

The interval given is in terms of monotonic time, not wall clock time. See g_get_monotonic_time().

    method timeout-add-seconds ( UInt() $interval, &function, gpointer $data --> UInt )

  * $interval; the time between calls to the function, in seconds.

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`.

Return value; the ID (greater than 0) of the event source.. 

timeout-add-seconds-full
------------------------

Sets a function to be called at regular intervals, with `$priority`.

The function is called repeatedly until it returns %G_SOURCE_REMOVE or `False`, at which point the timeout is automatically destroyed and the function will not be called again.

Unlike g_timeout_add(), this function operates at whole second granularity. The initial starting point of the timer is determined by the implementation and the implementation is expected to group multiple timers together so that they fire all at the same time. To allow this grouping, the `$interval` to the first timer is rounded and can deviate up to one second from the specified interval. Subsequent timer iterations will generally run at the specified interval.

Note that timeout functions may be delayed, due to the processing of other event sources. Thus they should not be relied on for precise timing. After each call to the timeout function, the time of the next timeout is recalculated based on the current time and the given `$interval`

See memory management of sources for details on how to handle the return value and memory management of `$data`.

If you want timing more precise than whole seconds, use g_timeout_add() instead.

The grouping of timers to fire at the same time results in a more power and CPU efficient behavior so if your timer is in multiples of seconds and you don't require the first timer exactly one second from now, the use of g_timeout_add_seconds() is preferred over g_timeout_add().

This internally creates a main loop source using g_timeout_source_new_seconds() and attaches it to the main loop context using g_source_attach(). You can do these steps manually if you need greater control.

It is safe to call this function from any thread.

The interval given is in terms of monotonic time, not wall clock time. See g_get_monotonic_time().

    method timeout-add-seconds-full ( Int() $priority, UInt() $interval, &function, gpointer $data, &notify --> UInt )

  * $priority; the priority of the timeout source. Typically this will be in the range between %G_PRIORITY_DEFAULT and %G_PRIORITY_HIGH..

  * $interval; the time between calls to the function, in seconds.

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`.

  * &notify; function to call when the timeout is removed, or `Nil`. Tthe function must be specified with following signature; `:( gpointer $data )`.

Return value; the ID (greater than 0) of the event source.. 

timeout-source-new
------------------

Creates a new timeout source.

The source will not initially be associated with any GMainContext and must be added to one with g_source_attach() before it will be executed.

The interval given is in terms of monotonic time, not wall clock time. See g_get_monotonic_time().

    method timeout-source-new ( UInt() $interval --> CArray[N-Source]  )

  * $interval; the timeout interval in milliseconds..

Return value; the newly-created timeout source. 

timeout-source-new-seconds
--------------------------

Creates a new timeout source.

The source will not initially be associated with any GMainContext and must be added to one with g_source_attach() before it will be executed.

The scheduling granularity/accuracy of this timeout source will be in seconds.

The interval given is in terms of monotonic time, not wall clock time. See g_get_monotonic_time().

    method timeout-source-new-seconds ( UInt() $interval --> CArray[N-Source]  )

  * $interval; the timeout interval in seconds.

Return value; the newly-created timeout source. 