//// This module provides a `Queue` built using a `Table`. Queues created
//// by this module are built using `ordered_set` ETS tables. Ordered sets use
//// a binary search tree so insert and lookups are performed in logarithmic
//// time. These operations will take longer as the queue grows in size.
////
//// `Queue`s require a `Counter` to generate integer keys for the underlying
//// `Table`. You can use the `counter` module to define custom counters, or
//// use one of the counters defined in that module.
////
//// If using `counter.atomic`, each new integer value is 1 greater
//// than the previous. Atomic counters are backed by [erlang counters][1] and
//// are therefore guaranteed atomicity.
////
//// If using `counter.monotonic`, each new value is a strictly monotonically
//// increasing unique integer backed by erlang's [unique_integer/1][2].
//// Consecutive calls to `queue.push` are guaranteed to produce unique indices.
////
//// If using `counter.monotonic_time`, each new value comes from calling
//// [monotonic_time][3] with the specified time unit. Since `monotonic_time`
//// can produce the same result from consecutive calls, it is possible for
//// calls to `queue.push` to return an error if that index key was previously
//// inserted into the queue.
////
//// [1]: https://www.erlang.org/doc/apps/erts/counters.html
//// [2]: https://www.erlang.org/doc/apps/erts/erlang#unique_integer/1
//// [3]: https://www.erlang.org/doc/apps/erts/erlang#monotonic_time/1

import gleam/list
import gleam/result
import rasa/counter.{type Counter}
import rasa/table.{type Table}

/// A FIFO queue backed by an ordered ETS table. Values are indexed by a
/// `Counter`.
pub opaque type Queue(a) {
  Queue(store: Table(Int, a), counter: Counter)
}

/// Creates a new `Queue` with the given `Counter` and `Access` level. The
/// underlying table is always an `OrderedSet`.
pub fn new(counter: Counter, access: table.Access) -> Queue(a) {
  table.build()
  |> table.with_access(access)
  |> table.with_kind(table.OrderedSet)
  |> table.new
  |> Queue(counter)
}

/// Inserts a value into the queue. Returns the index assigned to the value.
/// For queues using a counter that doesn't guarantee new values on each
/// `next` call, `push` can return an error if a previously used index key
/// is reused.
pub fn push(queue: Queue(a), value: a) -> Result(Int, Nil) {
  let index = counter.next(queue.counter)
  use _ <- result.map(table.insert_new(queue.store, index, value))

  index
}

/// Removes and returns the queue's first value. Returns `Error(Nil)` if the
/// queue is empty.
pub fn pop(queue: Queue(a)) -> Result(a, Nil) {
  use #(_index, value) <- result.map(table.delete_first(queue.store))

  value
}

/// Returns the value stored in the queue at a given index.
pub fn at(queue: Queue(a), index: Int) -> Result(a, Nil) {
  table.lookup(queue.store, index)
}

/// Removes the item at the given index from the queue. Succeeds even if the
/// index does not exist in the queue.
pub fn delete(queue: Queue(a), index: Int) -> Result(Nil, Nil) {
  table.delete(queue.store, index)
}

/// Deletes the queue.
pub fn drop(queue: Queue(a)) -> Result(Nil, Nil) {
  table.drop(queue.store)
}

/// Returns the first item in the queue without removing it from the queue.
pub fn first(queue: Queue(a)) -> Result(#(Int, a), Nil) {
  table.first(queue.store)
}

/// Returns the last item in the queue without removing it from the queue.
pub fn last(queue: Queue(a)) -> Result(#(Int, a), Nil) {
  table.last(queue.store)
}

/// Returns the queue's values as a list in insertion order.
pub fn to_list(queue: Queue(a)) -> Result(List(a), Nil) {
  use key_vals <- result.map(table.to_list(queue.store))
  use #(_key, value) <- list.map(key_vals)

  value
}

/// Determines whether the queue is empty. Returns `True` if the underlying
/// table does not exist.
pub fn is_empty(queue: Queue(a)) -> Bool {
  first(queue)
  |> result.replace(False)
  |> result.unwrap(True)
}

/// Returns the number of items in the queue.
pub fn size(queue: Queue(a)) -> Result(Int, Nil) {
  table.size(queue.store)
}
