//// This module provides a `Queue` built using a `rasa.Table`. Queues created
//// by this module are built using `ordered_set` ETS tables. Ordered sets use
//// a binary search tree so insert and lookups are performed in logarithmic
//// time. These operations will take longer as the queue grows in size.
////
//// `Queue`s require a `Counter` that provide ever-increasing integer values
//// used as keys for the underlying `rasa.Table`. If using `counter.atomic`,
//// each new integer value is 1 greater than the previous. Atomic counters are
//// backed by [erlang counters][1] and are therefore guaranteed atomicity.
////
//// If using `counter.monotonic`, each new value comes from calling
//// [monotonic_time][2] with the specified time unit. Since `monotonic_time`
//// can produce the same result from consecutive calls, it is possible for
//// calls to `queue.push` to return an error if that index key was previously
//// inserted into the queue.
////
//// [1]: https://www.erlang.org/doc/apps/erts/counters.html
//// [2]: https://www.erlang.org/doc/apps/erts/erlang#monotonic_time/1

import gleam/list
import gleam/result
import rasa
import rasa/counter.{type Counter}

/// A FIFO queue backed by an ordered ETS table. Values are indexed by a
/// `Counter`.
pub opaque type Queue(a) {
  Queue(store: rasa.Table(Int, a), counter: Counter)
}

/// Creates a new Queue from a `Builder`. This function will update the builder
/// to specify an `OrderedSet` as Queues must be backed by `OrderedSet`s.
pub fn new(builder: rasa.Builder, counter: Counter) -> Queue(a) {
  builder
  |> rasa.with_kind(rasa.OrderedSet)
  |> rasa.table
  |> Queue(counter)
}

/// Inserts a value into the queue. Returns the index assigned to the value.
/// For queues using a counter that doesn't guarantee new values on each
/// `next` call, `push` can return an error if a previously used index key
/// is reused.
pub fn push(queue: Queue(a), value: a) -> Result(Int, Nil) {
  use index <- result.try(counter.next(queue.counter))
  use _ <- result.map(rasa.insert_new(queue.store, index, value))

  index
}

/// Removes and returns the queue's first value. Returns `Error(Nil)` if the
/// queue is empty.
pub fn pop(queue: Queue(a)) -> Result(a, Nil) {
  use #(index, value) <- result.try(rasa.first(queue.store))
  use _ <- result.map(rasa.delete(queue.store, index))

  value
}

/// Returns the value stored in the queue at a given index.
pub fn at(queue: Queue(a), index: Int) -> Result(a, Nil) {
  rasa.lookup(queue.store, index)
}

/// Removes the item at the given index from the queue.
pub fn delete(queue: Queue(a), index: Int) -> Result(Nil, Nil) {
  rasa.delete(queue.store, index)
}

/// Deletes the queue.
pub fn drop(queue: Queue(a)) -> Result(Nil, Nil) {
  rasa.drop(queue.store)
}

/// Returns the first item in the queue without removing it from the queue.
pub fn first(queue: Queue(a)) -> Result(#(Int, a), Nil) {
  rasa.first(queue.store)
}

/// Returns the last item in the queue without removing it from the queue.
pub fn last(queue: Queue(a)) -> Result(#(Int, a), Nil) {
  rasa.last(queue.store)
}

/// Returns the queue's values as a list in insertion order.
pub fn to_list(queue: Queue(a)) -> Result(List(a), Nil) {
  use key_vals <- result.map(rasa.to_list(queue.store))
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
  rasa.size(queue.store)
}
