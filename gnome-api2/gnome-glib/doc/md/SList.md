Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/slist.png)

Description
===========

The GSList struct is used for each element in the singly-linked list.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

Functions
=========

alloc
-----

Allocates space for one GSList element. It is called by the g_slist_append(), g_slist_prepend(), g_slist_insert() and g_slist_insert_sorted() functions and so is rarely used on its own.

    method alloc (--> N-SList )

Return value; a pointer to the newly-allocated GSList element.. 

append
------

Adds a new element on to the end of the list.

The return value is the new start of the list, which may have changed, so make sure you store the new value.

Note that g_slist_append() has to traverse the entire list to find the end, which is inefficient when adding multiple elements. A common idiom to avoid the inefficiency is to prepend the elements and reverse the list when all elements have been added.

    method append ( N-SList() $list, gpointer $data --> N-SList )

  * $list; a GSList.

  * $data; the data for the new element.

Return value; the new start of the GSList. 

concat
------

Adds the second GSList onto the end of the first GSList. Note that the elements of the second GSList are not copied. They are used directly.

    method concat ( N-SList() $list1, N-SList() $list2 --> N-SList )

  * $list1; a GSList.

  * $list2; the GSList to add to the end of the first GSList.

Return value; the start of the new GSList. 

copy
----

Copies a GSList.

Note that this is a "shallow" copy. If the list elements consist of pointers to data, the pointers are copied but the actual data isn't. See g_slist_copy_deep() if you need to copy the data as well.

    method copy ( N-SList() $list --> N-SList )

  * $list; a GSList.

Return value; a copy of `$list`. 

copy-deep
---------

Makes a full (deep) copy of a GSList.

In contrast with g_slist_copy(), this function uses `$func` to make a copy of each list element, in addition to copying the list container itself. `$func`, as a GCopyFunc, takes two arguments, the data to be copied and a `$user_data` pointer. On common processor architectures, it's safe to pass `Nil` as `$user_data` if the copy function takes only one argument. You may get compiler warnings from this though if compiling with GCC’s `-Wcast-function-type` warning.

For instance, if `$list` holds a list of GObjects, you can do:

And, to entirely free the new list, you could do:

    method copy-deep (
      N-SList() $list, &func, gpointer $user-data --> N-SList
    )

  * $list; a GSList.

  * &func; a copy function used to copy every element in the list. Tthe function must be specified with following signature; `:( gpointer $src, gpointer $data --` gpointer )>.

  * $user-data; user data passed to the copy function `$func`, or #NULL.

Return value; a full copy of `$list`, use g_slist_free_full() to free it. 

delete-link
-----------

Removes the node link_ from the list and frees it. Compare this to g_slist_remove_link() which removes the node without freeing it.

Removing arbitrary nodes from a singly-linked list requires time that is proportional to the length of the list (ie. O(n)). If you find yourself using g_slist_delete_link() frequently, you should consider a different data structure, such as the doubly-linked GList.

    method delete-link (
      N-SList() $list, N-SList() $link --> N-SList
    )

  * $list; a GSList.

  * $link; node to delete.

Return value; the new head of `$list`. 

find
----

Finds the element in a GSList which contains the given data.

    method find ( N-SList() $list, gpointer $data --> N-SList )

  * $list; a GSList.

  * $data; the element data to find.

Return value; the found GSList element, or `Nil` if it is not found. 

find-custom
-----------

Finds an element in a GSList, using a supplied function to find the desired element. It iterates over the list, calling the given function which should return 0 when the desired element is found. The function takes two #gconstpointer arguments, the GSList element's data as the first argument and the given user data.

    method find-custom (
      N-SList() $list, gpointer $data, &func --> N-SList
    )

  * $list; a GSList.

  * $data; user data passed to the function.

  * &func; the function to call for each element. It should return 0 when the desired element is found. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b --` gint )>.

Return value; the found GSList element, or `Nil` if it is not found. 

foreach
-------

Calls a function for each element of a GSList.

It is safe for `$func` to remove the element from `$list`, but it must not modify any part of the list after that element.

    method foreach ( N-SList() $list, &func, gpointer $user-data )

  * $list; a GSList.

  * &func; the function to call with each element's data. Tthe function must be specified with following signature; `:( gpointer $data, gpointer $user-data )`.

  * $user-data; user data to pass to the function.

free
----

Frees all of the memory used by a GSList. The freed elements are returned to the slice allocator.

If list elements contain dynamically-allocated memory, you should either use g_slist_free_full() or free them manually first.

It can be combined with g_steal_pointer() to ensure the list head pointer is not left dangling:

    method free ( N-SList() $list )

  * $list; the first link of a GSList.

free-full
---------

Convenience method, which frees all the memory used by a GSList, and calls the specified destroy function on every element's data. `$free_func` must not modify the list (eg, by removing the freed element from it).

It can be combined with g_steal_pointer() to ensure the list head pointer is not left dangling ­— this also has the nice property that the head pointer is cleared before any of the list elements are freed, to prevent double frees from `$free_func`:

    method free-full ( N-SList() $list, &free-func )

  * $list; the first link of a GSList.

  * &free-func; the function to be called to free each element's data. Tthe function must be specified with following signature; `:( gpointer $data )`.

free-one
--------

Frees one GSList element. It is usually used after g_slist_remove_link().

    method free-one ( N-SList() $list )

  * $list; a GSList element.

index
-----

Gets the position of the element containing the given data (starting from 0).

    method index ( N-SList() $list, gpointer $data --> Int )

  * $list; a GSList.

  * $data; the data to find.

Return value; the index of the element containing the data, or -1 if the data is not found. 

insert
------

Inserts a new element into the list at the given position.

    method insert (
      N-SList() $list, gpointer $data, Int() $position --> N-SList
    )

  * $list; a GSList.

  * $data; the data for the new element.

  * $position; the position to insert the element. If this is negative, or is larger than the number of elements in the list, the new element is added on to the end of the list..

Return value; the new start of the GSList. 

insert-before
-------------

Inserts a node before `$sibling` containing `$data`.

    method insert-before (
      N-SList() $slist, N-SList() $sibling, gpointer $data
      --> N-SList
    )

  * $slist; a GSList.

  * $sibling; node to insert `$data` before.

  * $data; data to put in the newly-inserted node.

Return value; the new head of the list.. 

insert-sorted
-------------

Inserts a new element into the list, using the given comparison function to determine its position.

    method insert-sorted (
      N-SList() $list, gpointer $data, &func --> N-SList
    )

  * $list; a GSList.

  * $data; the data for the new element.

  * &func; the function to compare elements in the list. It should return a number > 0 if the first parameter comes after the second parameter in the sort order.. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b --` gint )>.

Return value; the new start of the GSList. 

insert-sorted-with-data
-----------------------

Inserts a new element into the list, using the given comparison function to determine its position.

    method insert-sorted-with-data (
      N-SList() $list, gpointer $data, &func,
      gpointer $user-data
      --> N-SList
    )

  * $list; a GSList.

  * $data; the data for the new element.

  * &func; the function to compare elements in the list. It should return a number > 0 if the first parameter comes after the second parameter in the sort order.. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b, gpointer $user-data --` gint )>.

  * $user-data; data to pass to comparison function.

Return value; the new start of the GSList. 

last
----

Gets the last element in a GSList.

This function iterates over the whole list.

    method last ( N-SList() $list --> N-SList )

  * $list; a GSList.

Return value; the last element in the GSList, or `Nil` if the GSList has no elements. 

length
------

Gets the number of elements in a GSList.

This function iterates over the whole list to count its elements. To check whether the list is non-empty, it is faster to check `$list` against `Nil`.

    method length ( N-SList() $list --> UInt )

  * $list; a GSList.

Return value; the number of elements in the GSList. 

nth
---

Gets the element at the given position in a GSList.

    method nth ( N-SList() $list, UInt() $n --> N-SList )

  * $list; a GSList.

  * $n; the position of the element, counting from 0.

Return value; the element, or `Nil` if the position is off the end of the GSList. 

nth-data
--------

Gets the data of the element at the given position.

    method nth-data ( N-SList() $list, UInt() $n --> gpointer )

  * $list; a GSList.

  * $n; the position of the element.

Return value; the element's data, or `Nil` if the position is off the end of the GSList. 

position
--------

Gets the position of the given element in the GSList (starting from 0).

    method position ( N-SList() $list, N-SList() $llink --> Int )

  * $list; a GSList.

  * $llink; an element in the GSList.

Return value; the position of the element in the GSList, or -1 if the element is not found. 

prepend
-------

Adds a new element on to the start of the list.

The return value is the new start of the list, which may have changed, so make sure you store the new value.

    method prepend ( N-SList() $list, gpointer $data --> N-SList )

  * $list; a GSList.

  * $data; the data for the new element.

Return value; the new start of the GSList. 

remove
------

Removes an element from a GSList. If two elements contain the same data, only the first is removed. If none of the elements contain the data, the GSList is unchanged.

    method remove ( N-SList() $list, gpointer $data --> N-SList )

  * $list; a GSList.

  * $data; the data of the element to remove.

Return value; the new start of the GSList. 

remove-all
----------

Removes all list nodes with data equal to `$data`. Returns the new head of the list. Contrast with g_slist_remove() which removes only the first node matching the given data.

    method remove-all (
      N-SList() $list, gpointer $data --> N-SList
    )

  * $list; a GSList.

  * $data; data to remove.

Return value; new head of `$list`. 

remove-link
-----------

Removes an element from a GSList, without freeing the element. The removed element's next link is set to `Nil`, so that it becomes a self-contained list with one element.

Removing arbitrary nodes from a singly-linked list requires time that is proportional to the length of the list (ie. O(n)). If you find yourself using g_slist_remove_link() frequently, you should consider a different data structure, such as the doubly-linked GList.

    method remove-link (
      N-SList() $list, N-SList() $link --> N-SList
    )

  * $list; a GSList.

  * $link; an element in the GSList.

Return value; the new start of the GSList, without the element. 

reverse
-------

Reverses a GSList.

    method reverse ( N-SList() $list --> N-SList )

  * $list; a GSList.

Return value; the start of the reversed GSList. 

sort
----

Sorts a GSList using the given comparison function. The algorithm used is a stable sort.

    method sort ( N-SList() $list, &compare-func --> N-SList )

  * $list; a GSList.

  * &compare-func; the comparison function used to sort the GSList. This function is passed the data from 2 elements of the GSList and should return 0 if they are equal, a negative value if the first element comes before the second, or a positive value if the first element comes after the second.. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b --` gint )>.

Return value; the start of the sorted GSList. 

sort-with-data
--------------

Like g_slist_sort(), but the sort function accepts a user data argument.

    method sort-with-data (
      N-SList() $list, &compare-func, gpointer $user-data
      --> N-SList
    )

  * $list; a GSList.

  * &compare-func; comparison function. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b, gpointer $user-data --` gint )>.

  * $user-data; data to pass to comparison function.

Return value; new head of the list. 

