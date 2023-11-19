Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/maincontext.png)

Description
===========

The `GMainContext` struct is an opaque data type representing a set of sources to be handled in a main loop.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-maincontext
---------------

Creates a new GMainContext structure.

    method new-maincontext ( --> Gnome::Glib::MainContext)

new-with-flags
--------------

Creates a new GMainContext structure.

    method new-with-flags ( --> Gnome::Glib::MainContext)

Methods
=======

acquire
-------

Tries to become the owner of the specified context. If some other thread is the owner of the context, returns `False` immediately. Ownership is properly recursive: the owner can require ownership again and will release ownership when `.release()` is called as many times as `.acquire()`.

You must be the owner of a context before you can call `.prepare()`, `.query()`, `.check()`, `.dispatch()`.

    method acquire (--> Bool )

Return value; `True` if the operation succeeded, and this thread is now the owner of `$context`.. 

add-poll
--------

Adds a file descriptor to the set of file descriptors polled for this context. This will very seldom be used directly. Instead a typical event source will use g_source_add_unix_fd() instead.

    method add-poll ( CArray[N-PollFD]  $fd, Int() $priority )

  * $fd; a GPollFD structure holding information about a file descriptor to watch..

  * $priority; the priority for this file descriptor which should be the same as the priority used for g_source_attach() to ensure that the file descriptor is polled whenever the results may be needed..

check
-----

Passes the results of polling back to the main loop. You should be careful to pass `$fds` and its length `$n_fds` as received from `.query()`, as this functions relies on assumptions on how `$fds` is filled.

You must have successfully acquired the context with `.acquire()` before you may call this function.

    method check ( Int() $max-priority, CArray[N-PollFD]  $fds, Int() $n-fds --> Bool )

  * $max-priority; the maximum numerical priority of sources to check.

  * $fds; array of GPollFD's that was passed to the last call to `.query()`.

  * $n-fds; return value of `.query()`.

Return value; `True` if some sources are ready to be dispatched.. 

dispatch
--------

Dispatches all pending sources.

You must have successfully acquired the context with `.acquire()` before you may call this function.

    method dispatch ( )

find-source-by-funcs-user-data
------------------------------

Finds a source with the given source functions and user data. If multiple sources exist with the same source function and user data, the first one found will be returned.

    method find-source-by-funcs-user-data ( CArray[N-SourceFuncs]  $funcs, gpointer $user-data --> CArray[N-Source]  )

  * $funcs; the `$source_funcs` passed to g_source_new()..

  * $user-data; the user data from the callback..

Return value; the source, if one was found, otherwise `Nil`. 

find-source-by-id
-----------------

Finds a GSource given a pair of context and ID.

It is a programmer error to attempt to look up a non-existent source.

More specifically: source IDs can be reissued after a source has been destroyed and therefore it is never valid to use this function with a source ID which may have already been removed. An example is when scheduling an idle to run in another thread with g_idle_add(): the idle may already have run and been removed by the time this function is called on its (now invalid) source ID. This source ID may have been reissued, leading to the operation being performed against the wrong source.

    method find-source-by-id ( UInt() $source-id --> CArray[N-Source]  )

  * $source-id; the source ID, as returned by g_source_get_id()..

Return value; the GSource. 

find-source-by-user-data
------------------------

Finds a source with the given user data for the callback. If multiple sources exist with the same user data, the first one found will be returned.

    method find-source-by-user-data ( gpointer $user-data --> CArray[N-Source]  )

  * $user-data; the user_data for the callback..

Return value; the source, if one was found, otherwise `Nil`. 

get-poll-func
-------------

Gets the poll function set by `.set-poll-func()`.

    method get-poll-func (-->  )

Return value; the poll function. 

invoke
------

Invokes a function in such a way that `$context` is owned during the invocation of `$function`.

If `$context` is `Nil` then the global default main context — as returned by `.default()` — is used.

If `$context` is owned by the current thread, `$function` is called directly. Otherwise, if `$context` is the thread-default main context of the current thread and `.acquire()` succeeds, then `$function` is called and `.release()` is called afterwards.

In any other case, an idle source is created to call `$function` and that source is attached to `$context` (presumably to be run in another thread). The idle source is attached with %G_PRIORITY_DEFAULT priority. If you want a different priority, use `.invoke-full()`.

Note that, as with normal idle functions, `$function` should probably return `False`. If it returns `True`, it will be continuously run in a loop (and may prevent this call from returning).

    method invoke ( &function, gpointer $data )

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`.

invoke-full
-----------

Invokes a function in such a way that `$context` is owned during the invocation of `$function`.

This function is the same as `.invoke()` except that it lets you specify the priority in case `$function` ends up being scheduled as an idle and also lets you give a GDestroyNotify for `$data`. `$notify` should not assume that it is called from any particular thread or with any particular context acquired.

    method invoke-full ( Int() $priority, &function, gpointer $data, &notify )

  * $priority; the priority at which to run `$function`.

  * &function; function to call. Tthe function must be specified with following signature; `:( gpointer $user-data --` gboolean )>.

  * $data; data to pass to `$function`.

  * &notify; a function to call when `$data` is no longer in use, or `Nil`.. Tthe function must be specified with following signature; `:( gpointer $data )`.

is-owner
--------

Determines whether this thread holds the (recursive) ownership of this GMainContext. This is useful to know before waiting on another thread that may be blocking to get ownership of `$context`.

    method is-owner (--> Bool )

Return value; `True` if current thread is owner of `$context`.. 

iteration
---------

Runs a single iteration for the given main loop. This involves checking to see if any event sources are ready to be processed, then if no events sources are ready and `$may_block` is `True`, waiting for a source to become ready, then dispatching the highest priority events sources that are ready. Otherwise, if `$may_block` is `False` sources are not waited to become ready, only those highest priority events sources will be dispatched (if any), that are ready at this given moment without further waiting.

Note that even when `$may_block` is `True`, it is still possible for `.iteration()` to return `False`, since the wait may be interrupted for other reasons than an event source becoming ready.

    method iteration ( Bool() $may-block --> Bool )

  * $may-block; whether the call may block..

Return value; `True` if events were dispatched.. 

pending
-------

Checks if any sources have pending events for the given context.

    method pending (--> Bool )

Return value; `True` if events are pending.. 

pop-thread-default
------------------

Pops `$context` off the thread-default context stack (verifying that it was on the top of the stack).

    method pop-thread-default ( )

prepare
-------

Prepares to poll sources within a main loop. The resulting information for polling is determined by calling g_main_context_query ().

You must have successfully acquired the context with `.acquire()` before you may call this function.

    method prepare ( Array[Int] $priority --> Bool )

  * $priority; (transfer ownership: full) location to store priority of highest priority source already ready..

Return value; `True` if some source is ready to be dispatched prior to polling.. 

push-thread-default
-------------------

Acquires `$context` and sets it as the thread-default context for the current thread. This will cause certain asynchronous operations (such as most gio-based I/O) which are started in this thread to run under `$context` and deliver their results to its main loop, rather than running under the global default context in the main thread. Note that calling this function changes the context returned by `.get-thread-default()`, not the one returned by `.default()`, so it does not affect the context used by functions like g_idle_add().

Normally you would call this function shortly after creating a new thread, passing it a GMainContext which will be run by a GMainLoop in that thread, to set a new default context for all async operations in that thread. In this case you may not need to ever call `.pop-thread-default()`, assuming you want the new GMainContext to be the default for the whole lifecycle of the thread.

If you don't have control over how the new thread was created (e.g. in the new thread isn't newly created, or if the thread life cycle is managed by a GThreadPool), it is always suggested to wrap the logic that needs to use the new GMainContext inside a `.push-thread-default()` / `.pop-thread-default()` pair, otherwise threads that are re-used will end up never explicitly releasing the GMainContext reference they hold.

In some cases you may want to schedule a single operation in a non-default context, or temporarily use a non-default context in the main thread. In that case, you can wrap the call to the asynchronous operation inside a `.push-thread-default()` / `.pop-thread-default()` pair, but it is up to you to ensure that no other asynchronous operations accidentally get started while the non-default context is active.

Beware that libraries that predate this function may not correctly handle being used from a thread with a thread-default context. Eg, see g_file_supports_thread_contexts().

    method push-thread-default ( )

query
-----

Determines information necessary to poll this main loop. You should be careful to pass the resulting `$fds` array and its length `$n_fds` as is when calling `.check()`, as this function relies on assumptions made when the array is filled.

You must have successfully acquired the context with `.acquire()` before you may call this function.

    method query ( Int() $max-priority, Array[Int] $timeout, CArray[N-PollFD]  $fds, Int() $n-fds --> Int )

  * $max-priority; maximum priority source to check.

  * $timeout; (transfer ownership: full) location to store timeout to be used in polling.

  * $fds; location to store GPollFD records that need to be polled..

  * $n-fds; length of `$fds`..

Return value; the number of records actually stored in `$fds`, or, if more than `$n_fds` records need to be stored, the number of records that need to be stored.. 

ref
---

Increases the reference count on a GMainContext object by one.

    method ref (--> CArray[N-MainContext] )

Return value; the `$context` that was passed in (since 2.6). 

release
-------

Releases ownership of a context previously acquired by this thread with `.acquire()`. If the context was acquired multiple times, the ownership will be released only when `.release()` is called as many times as it was acquired.

    method release ( )

remove-poll
-----------

Removes file descriptor from the set of file descriptors to be polled for a particular context.

    method remove-poll ( CArray[N-PollFD]  $fd )

  * $fd; a GPollFD descriptor previously added with `.add-poll()`.

set-poll-func
-------------

Sets the function to use to handle polling of file descriptors. It will be used instead of the poll() system call (or GLib's replacement function, which is used where poll() isn't available).

This function could possibly be used to integrate the GLib event loop with an external event loop.

    method set-poll-func ( &func )

  * &func; the function to call to poll all file descriptors. Tthe function must be specified with following signature; `:( N-PollFD $ufds, guint $nfsd, gint $timeout --` gint ) >.

unref
-----

Decreases the reference count on a GMainContext object by one. If the result is zero, free the context and free all associated memory.

    method unref ( )

wakeup
------

If `$context` is currently blocking in `.iteration()` waiting for a source to become ready, cause it to stop blocking and return. Otherwise, cause the next invocation of `.iteration()` to return without blocking.

This API is useful for low-level control over GMainContext; for example, integrating it with main loop implementations such as GMainLoop.

Another related use for this function is when implementing a main loop with a termination condition, computed from multiple threads:

Then in a thread:

    method wakeup ( )

Functions
=========

default
-------

Returns the global default main context. This is the main context used for main loop functions when a main loop is not explicitly specified, and corresponds to the "main" main loop. See also `.get-thread-default()`.

    method default (--> CArray[N-MainContext] )

Return value; the global default main context.. 

get-thread-default
------------------

Gets the thread-default GMainContext for this thread. Asynchronous operations that want to be able to be run in contexts other than the default one should call this method or `.ref-thread-default()` to get a GMainContext to add their GSources to. (Note that even in single-threaded programs applications may sometimes want to temporarily push a non-default context, so it is not safe to assume that this will always return `Nil` if you are running in the default thread.)

If you need to hold a reference on the context, use `.ref-thread-default()` instead.

    method get-thread-default (--> CArray[N-MainContext] )

Return value; the thread-default GMainContext, or `Nil` if the thread-default context is the global default context.. 

ref-thread-default
------------------

Gets the thread-default GMainContext for this thread, as with `.get-thread-default()`, but also adds a reference to it with `.ref()`. In addition, unlike `.get-thread-default()`, if the thread-default context is the global default context, this will return that GMainContext (with a ref added to it) rather than returning `Nil`.

    method ref-thread-default (--> CArray[N-MainContext] )

Return value; the thread-default GMainContext. Unref with `.unref()` when you are done with it.. 
