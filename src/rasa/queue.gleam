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
  |> rasa.ordered_set
  |> rasa.table
  |> Queue(counter)
}

/// Inserts a value into the queue. Returns the index assigned to the value.
pub fn push(queue: Queue(a), value: a) -> Result(Int, Nil) {
  use index <- result.try(counter.next(queue.counter))
  use _ <- result.map(rasa.insert(queue.store, index, value))

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

/// Returns the first item in the queue without removing it from the queue.
pub fn first(queue: Queue(a)) -> Result(a, Nil) {
  rasa.first(queue.store)
  |> result.map(fn(key_val) { key_val.1 })
}

/// Returns the last item in the queue without removing it from the queue.
pub fn last(queue: Queue(a)) -> Result(a, Nil) {
  rasa.last(queue.store)
  |> result.map(fn(key_val) { key_val.1 })
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
