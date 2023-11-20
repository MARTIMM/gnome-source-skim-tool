Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Description
===========

The N-List struct is used for each element in a doubly-linked list.

Example
-------

    my Gnome::Glib::List $list .= new;
    for ^10 -> $i {
      $N-List = $list.append( $N-List, Pointer[int].new($i));
    }

    note $list.length($N-List);                # 10

Please note that data needs to be kept alive in Raku across function calls to prevent cleaning up by the garbage collection process. That said, this List class is only useful for Raku developers when list data is returned from other objects. An example of that is the method `.get-windows()` defined in **Gnome::Gtk4::Application**.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-List :$native-object! )

Functions
=========

alloc
-----

Allocates space for one N-List element. It is called by `.append()`, `.prepend()`, `.insert()` and `.insert-sorted()` and so is rarely used on its own.

    method alloc ( --> N-List )

Return value; a pointer to the newly-allocated N-List element. 

append
------

Adds a new element on to the end of the list.

Note that the return value is the new start of the list, if `$list` was empty; make sure you store the new value.

`.append()` has to traverse the entire list to find the end, which is inefficient when adding multiple elements. A common idiom to avoid the inefficiency is to use `.prepend()` and reverse the list with `.reverse()` when all elements have been added.

    method append ( N-List() $list, gpointer $data --> N-List )

  * $list; a pointer to a N-List.

  * $data; the data for the new element.

Return value; either `$list` or the new start of the N-List if `$list` was `Nil`. 

concat
------

Adds the second N-List onto the end of the first N-List. Note that the elements of the second N-List are not copied. They are used directly.

This function is for example used to move an element in the list. The following example moves an element to the top of the list:

    method concat ( N-List() $list1, N-List() $list2 --> N-List )

  * $list1; a N-List, this must point to the top of the list.

  * $list2; the N-List to add to the end of the first N-List, this must point to the top of the list.

Return value; the start of the new N-List, which equals `$list1` if not `Nil`. 

copy
----

Copies a N-List.

Note that this is a "shallow" copy. If the list elements consist of pointers to data, the pointers are copied but the actual data is not. See `.copy-deep()` if you need to copy the data as well.

    method copy ( N-List() $list --> N-List )

  * $list; a N-List, this must point to the top of the list.

Return value; the start of the new list that holds the same data as `$list`. 

copy-deep
---------

Makes a full (deep) copy of a N-List.

In contrast with `.copy()`, this function uses `$func` to make a copy of each list element, in addition to copying the list container itself. `$func`, as a GCopyFunc, takes two arguments, the data to be copied and a `$user_data` pointer. On common processor architectures, it's safe to pass `Nil` as `$user_data` if the copy function takes only one argument. You may get compiler warnings from this though if compiling with GCC’s `-Wcast-function-type` warning.

    method copy-deep (
      N-List() $list, &func, gpointer $user-data --> N-List
    )

  * $list; a N-List, this must point to the top of the list.

  * &func; a copy function used to copy every element in the list. Tthe function must be specified with following signature; `:( gpointer $src, gpointer $data --` gpointer )>.

  * $user-data; user data passed to the copy function `$func`, or `Nil`.

Return value; the start of the new list that holds a full copy of `$list`, use `.free-full()` to free it. 

delete-link
-----------

Removes the node link_ from the list and frees it. Compare this to `.remove-link()` which removes the node without freeing it.

    method delete-link (
      N-List() $list, N-List() $link --> N-List
    )

  * $list; a N-List, this must point to the top of the list.

  * $link; node to delete from `$list`.

Return value; the (possibly changed) start of the N-List. 

find
----

Finds the element in a N-List which contains the given data.

    method find ( N-List() $list, gpointer $data --> N-List )

  * $list; a N-List, this must point to the top of the list.

  * $data; the element data to find.

Return value; the found N-List element, or `Nil` if it is not found. 

find-custom
-----------

Finds an element in a N-List, using a supplied function to find the desired element. It iterates over the list, calling the given function which should return 0 when the desired element is found. The function takes two #gconstpointer arguments, the N-List element's data as the first argument and the given user data.

    method find-custom (
      N-List() $list, gpointer $data, &func --> N-List
    )

  * $list; a N-List, this must point to the top of the list.

  * $data; user data passed to the function.

  * &func; the function to call for each element. It should return 0 when the desired element is found. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b --` gint )>.

Return value; the found N-List element, or `Nil` if it is not found. 

first
-----

Gets the first element in a N-List.

    method first ( N-List() $list --> N-List )

  * $list; any N-List element.

Return value; the first element in the N-List, or `Nil` if the N-List has no elements. 

foreach
-------

Calls a function for each element of a N-List.

It is safe for `$func` to remove the element from `$list`, but it must not modify any part of the list after that element.

    method foreach ( N-List() $list, &func, gpointer $user-data )

  * $list; a N-List, this must point to the top of the list.

  * &func; the function to call with each element's data. Tthe function must be specified with following signature; `:( gpointer $data, gpointer $user-data )`.

  * $user-data; user data to pass to the function.

free
----

Frees all of the memory used by a N-List. The freed elements are returned to the slice allocator.

If list elements contain dynamically-allocated memory, you should either use `.free-full()` or free them manually first.

It can be combined with g_steal_pointer() to ensure the list head pointer is not left dangling:

    method free ( N-List() $list )

  * $list; the first link of a N-List.

free-full
---------

Convenience method, which frees all the memory used by a N-List, and calls `$free_func` on every element's data. `$free_func` must not modify the list (eg, by removing the freed element from it).

It can be combined with g_steal_pointer() to ensure the list head pointer is not left dangling ­— this also has the nice property that the head pointer is cleared before any of the list elements are freed, to prevent double frees from `$free_func`:

    method free-full ( N-List() $list, &free-func )

  * $list; the first link of a N-List.

  * &free-func; the function to be called to free each element's data. Tthe function must be specified with following signature; `:( gpointer $data )`.

free-one
--------

Frees one N-List element, but does not update links from the next and previous elements in the list, so you should not call this function on an element that is currently part of a list.

It is usually used after `.remove-link()`.

    method free-one ( N-List() $list )

  * $list; a N-List element.

index
-----

Gets the position of the element containing the given data (starting from 0).

    method index ( N-List() $list, gpointer $data --> Int )

  * $list; a N-List, this must point to the top of the list.

  * $data; the data to find.

Return value; the index of the element containing the data, or -1 if the data is not found. 

insert
------

Inserts a new element into the list at the given position.

    method insert (
      N-List() $list, gpointer $data, Int() $position --> N-List
    )

  * $list; a pointer to a N-List, this must point to the top of the list.

  * $data; the data for the new element.

  * $position; the position to insert the element. If this is negative, or is larger than the number of elements in the list, the new element is added on to the end of the list..

Return value; the (possibly changed) start of the N-List. 

insert-before
-------------

Inserts a new element into the list before the given position.

    method insert-before (
      N-List() $list, N-List() $sibling, gpointer $data
      --> N-List
    )

  * $list; a pointer to a N-List, this must point to the top of the list.

  * $sibling; the list element before which the new element is inserted or `Nil` to insert at the end of the list.

  * $data; the data for the new element.

Return value; the (possibly changed) start of the N-List. 

insert-before-link
------------------

Inserts `$link_` into the list before the given position.

    method insert-before-link (
      N-List() $list, N-List() $sibling, N-List() $link
      --> N-List
    )

  * $list; a pointer to a N-List, this must point to the top of the list.

  * $sibling; the list element before which the new element is inserted or `Nil` to insert at the end of the list.

  * $link; the list element to be added, which must not be part of any other list.

Return value; the (possibly changed) start of the N-List. 

insert-sorted
-------------

Inserts a new element into the list, using the given comparison function to determine its position.

If you are adding many new elements to a list, and the number of new elements is much larger than the length of the list, use `.prepend()` to add the new items and sort the list afterwards with `.sort()`.

    method insert-sorted (
      N-List() $list, gpointer $data, &func --> N-List
    )

  * $list; a pointer to a N-List, this must point to the top of the already sorted list.

  * $data; the data for the new element.

  * &func; the function to compare elements in the list. It should return a number > 0 if the first parameter comes after the second parameter in the sort order. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b --` gint )>.

Return value; the (possibly changed) start of the N-List. 

insert-sorted-with-data
-----------------------

Inserts a new element into the list, using the given comparison function to determine its position.

If you are adding many new elements to a list, and the number of new elements is much larger than the length of the list, use `.prepend()` to add the new items and sort the list afterwards with `.sort()`.

    method insert-sorted-with-data (
      N-List() $list, gpointer $data, &func,
      gpointer $user-data
      --> N-List
    )

  * $list; a pointer to a N-List, this must point to the top of the already sorted list.

  * $data; the data for the new element.

  * &func; the function to compare elements in the list. It should return a number > 0 if the first parameter comes after the second parameter in the sort order.. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b, gpointer $user-data --` gint )>.

  * $user-data; user data to pass to comparison function.

Return value; the (possibly changed) start of the N-List. 

last
----

Gets the last element in a N-List.

    method last ( N-List() $list --> N-List )

  * $list; any N-List element.

Return value; the last element in the N-List, or `Nil` if the N-List has no elements. 

length
------

Gets the number of elements in a N-List.

This function iterates over the whole list to count its elements. Use a GQueue instead of a N-List if you regularly need the number of items. To check whether the list is non-empty, it is faster to check `$list` against `Nil`.

    method length ( N-List() $list --> UInt )

  * $list; a N-List, this must point to the top of the list.

Return value; the number of elements in the N-List. 

nth
---

Gets the element at the given position in a N-List.

This iterates over the list until it reaches the `$n`-th position. If you intend to iterate over every element, it is better to use a for-loop as described in the N-List introduction.

    method nth ( N-List() $list, UInt() $n --> N-List )

  * $list; a N-List, this must point to the top of the list.

  * $n; the position of the element, counting from 0.

Return value; the element, or `Nil` if the position is off the end of the N-List. 

nth-data
--------

Gets the data of the element at the given position.

This iterates over the list until it reaches the `$n`-th position. If you intend to iterate over every element, it is better to use a for-loop as described in the N-List introduction.

    method nth-data ( N-List() $list, UInt() $n --> gpointer )

  * $list; a N-List, this must point to the top of the list.

  * $n; the position of the element.

Return value; the element's data, or `Nil` if the position is off the end of the N-List. 

nth-prev
--------

Gets the element `$n` places before `$list`.

    method nth-prev ( N-List() $list, UInt() $n --> N-List )

  * $list; a N-List.

  * $n; the position of the element, counting from 0.

Return value; the element, or `Nil` if the position is off the end of the N-List. 

position
--------

Gets the position of the given element in the N-List (starting from 0).

    method position ( N-List() $list, N-List() $llink --> Int )

  * $list; a N-List, this must point to the top of the list.

  * $llink; an element in the N-List.

Return value; the position of the element in the N-List, or -1 if the element is not found. 

prepend
-------

Prepends a new element on to the start of the list.

Note that the return value is the new start of the list, which will have changed, so make sure you store the new value.

Do not use this function to prepend a new element to a different element than the start of the list. Use `.insert-before()` instead.

    method prepend ( N-List() $list, gpointer $data --> N-List )

  * $list; a pointer to a N-List, this must point to the top of the list.

  * $data; the data for the new element.

Return value; a pointer to the newly prepended element, which is the new start of the N-List. 

remove
------

Removes an element from a N-List. If two elements contain the same data, only the first is removed. If none of the elements contain the data, the N-List is unchanged.

    method remove ( N-List() $list, gpointer $data --> N-List )

  * $list; a N-List, this must point to the top of the list.

  * $data; the data of the element to remove.

Return value; the (possibly changed) start of the N-List. 

remove-all
----------

Removes all list nodes with data equal to `$data`. Returns the new head of the list. Contrast with `.remove()` which removes only the first node matching the given data.

    method remove-all (
      N-List() $list, gpointer $data --> N-List
    )

  * $list; a N-List, this must point to the top of the list.

  * $data; data to remove.

Return value; the (possibly changed) start of the N-List. 

remove-link
-----------

Removes an element from a N-List, without freeing the element. The removed element's prev and next links are set to `Nil`, so that it becomes a self-contained list with one element.

This function is for example used to move an element in the list.

    method remove-link (
      N-List() $list, N-List() $llink --> N-List
    )

  * $list; a N-List, this must point to the top of the list.

  * $llink; an element in the N-List.

Return value; the (possibly changed) start of the N-List. 

reverse
-------

Reverses a N-List. It simply switches the next and prev pointers of each element.

    method reverse ( N-List() $list --> N-List )

  * $list; a N-List, this must point to the top of the list.

Return value; the start of the reversed N-List. 

sort
----

Sorts a N-List using the given comparison function. The algorithm used is a stable sort.

    method sort ( N-List() $list, &compare-func --> N-List )

  * $list; a N-List, this must point to the top of the list.

  * &compare-func; the comparison function used to sort the N-List. This function is passed the data from 2 elements of the N-List and should return 0 if they are equal, a negative value if the first element comes before the second, or a positive value if the first element comes after the second.. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b --` gint )>.

Return value; the (possibly changed) start of the N-List. 

sort-with-data
--------------

Like `.sort()`, but the comparison function accepts a user data argument.

    method sort-with-data (
      N-List() $list, &compare-func, gpointer $user-data
      --> N-List 
    )

  * $list; a N-List, this must point to the top of the list.

  * &compare-func; comparison function. Tthe function must be specified with following signature; `:( gpointer $a, gpointer $b, gpointer $user-data --` gint )>.

  * $user-data; user data to pass to comparison function.

Return value; the (possibly changed) start of the N-List. 

