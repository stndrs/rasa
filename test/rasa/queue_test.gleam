import gleam/erlang/process
import rasa/counter
import rasa/monotonic
import rasa/queue
import rasa/table

pub fn push_test() {
  let queue = new_queue()

  let assert Ok(1) = queue.push(queue, 10)
}

pub fn push_error_test() {
  // Counter where subsequent calls return the same value
  let counter = counter.new(fn() { 99 })

  let queue = queue.new(counter, table.Private)

  let assert Ok(99) = queue.push(queue, 10)
  // Subsequent calls to `queue.push` fail due to attempting to
  // insert new value in the queue at an index already in use.
  let assert Error(Nil) = queue.push(queue, 20)
}

pub fn pop_test() {
  let queue = new_queue()

  let assert Ok(1) = queue.push(queue, 10)
  let assert Ok(10) = queue.pop(queue)
}

pub fn pop_error_test() {
  let queue = new_queue()

  let assert Error(Nil) = queue.pop(queue)
}

pub fn first_test() {
  let queue = new_queue()

  let assert Ok(1) = queue.push(queue, 10)
  let assert Ok(2) = queue.push(queue, 20)

  let assert Ok(#(1, 10)) = queue.first(queue)
}

pub fn first_empty_test() {
  let queue = new_queue()

  let assert Error(Nil) = queue.first(queue)
}

pub fn last_test() {
  let queue = new_queue()

  let assert Ok(1) = queue.push(queue, 10)
  let assert Ok(2) = queue.push(queue, 20)

  let assert Ok(#(2, 20)) = queue.last(queue)
}

pub fn last_empty_test() {
  let queue = new_queue()

  let assert Error(Nil) = queue.last(queue)
}

pub fn to_list_test() {
  let queue = new_queue()

  let assert Ok([]) = queue.to_list(queue)

  let assert Ok(1) = queue.push(queue, 10)

  let assert Ok([10]) = queue.to_list(queue)

  let assert Ok(2) = queue.push(queue, 20)

  let assert Ok([10, 20]) = queue.to_list(queue)
}

pub fn is_empty_test() {
  let queue = new_queue()

  let assert True = queue.is_empty(queue)

  let assert Ok(1) = queue.push(queue, 10)

  let assert False = queue.is_empty(queue)

  let assert Ok(10) = queue.pop(queue)

  let assert True = queue.is_empty(queue)
}

pub fn size_test() {
  let queue = new_queue()

  let assert Ok(0) = queue.size(queue)

  let assert Ok(1) = queue.push(queue, 10)

  let assert Ok(1) = queue.size(queue)

  let assert Ok(2) = queue.push(queue, 10)

  let assert Ok(2) = queue.size(queue)
}

pub fn at_test() {
  let queue = new_queue()

  let assert Error(Nil) = queue.at(queue, 1)

  let assert Ok(1) = queue.push(queue, 10)

  let assert Ok(10) = queue.at(queue, 1)

  let assert Error(Nil) = queue.at(queue, 2)
}

pub fn monotonic_push_test() {
  let queue = new_monotonic_queue()

  let assert Ok(t1) = queue.push(queue, 10)

  process.sleep(1)

  let assert Ok(t2) = queue.push(queue, 10)

  assert t1 < t2
}

pub fn monotonic_pop_test() {
  let queue = new_monotonic_queue()

  let assert Ok(_t1) = queue.push(queue, 10)
  let assert Ok(10) = queue.pop(queue)
}

pub fn monotonic_pop_error_test() {
  let queue = new_monotonic_queue()

  let assert Error(Nil) = queue.pop(queue)
}

pub fn monotonic_first_test() {
  let queue = new_monotonic_queue()

  let assert Ok(_t1) = queue.push(queue, 10)
  let assert Ok(_t2) = queue.push(queue, 20)

  let assert Ok(#(_, 10)) = queue.first(queue)
}

pub fn monotonic_first_empty_test() {
  let queue = new_monotonic_queue()

  let assert Error(Nil) = queue.first(queue)
}

pub fn monotonic_last_test() {
  let queue = new_monotonic_queue()

  let assert Ok(_t1) = queue.push(queue, 10)
  let assert Ok(_t2) = queue.push(queue, 20)

  let assert Ok(#(_, 20)) = queue.last(queue)
}

pub fn monotonic_last_empty_test() {
  let queue = new_monotonic_queue()

  let assert Error(Nil) = queue.last(queue)
}

pub fn monotonic_to_list_test() {
  let queue = new_monotonic_queue()

  let assert Ok([]) = queue.to_list(queue)

  let assert Ok(_t1) = queue.push(queue, 10)

  let assert Ok([10]) = queue.to_list(queue)

  let assert Ok(_t2) = queue.push(queue, 20)

  let assert Ok([10, 20]) = queue.to_list(queue)
}

pub fn monotonic_is_empty_test() {
  let queue = new_monotonic_queue()

  let assert True = queue.is_empty(queue)

  let assert Ok(_t1) = queue.push(queue, 10)

  let assert False = queue.is_empty(queue)

  let assert Ok(10) = queue.pop(queue)

  let assert True = queue.is_empty(queue)
}

pub fn monotonic_size_test() {
  let queue = new_monotonic_queue()

  let assert Ok(0) = queue.size(queue)

  let assert Ok(_t1) = queue.push(queue, 10)

  let assert Ok(1) = queue.size(queue)

  let assert Ok(_t2) = queue.push(queue, 10)

  let assert Ok(2) = queue.size(queue)
}

pub fn delete_test() {
  let queue = new_queue()

  let assert Ok(1) = queue.push(queue, 10)
  let assert Ok(2) = queue.push(queue, 20)

  let assert Ok(Nil) = queue.delete(queue, 1)

  let assert Error(Nil) = queue.at(queue, 1)
  let assert Ok(20) = queue.at(queue, 2)
  let assert Ok(1) = queue.size(queue)
}

pub fn delete_missing_test() {
  let queue = new_queue()

  let assert Ok(Nil) = queue.delete(queue, 999)
}

pub fn drop_test() {
  let queue = new_queue()

  let assert Ok(Nil) = queue.drop(queue)
}

pub fn drop_error_test() {
  let queue = new_queue()

  let assert Ok(Nil) = queue.drop(queue)
  let assert Error(Nil) = queue.drop(queue)
}

pub fn monotonic_at_test() {
  let queue = new_monotonic_queue()

  let assert Error(Nil) = queue.at(queue, 1)

  let assert Ok(t1) = queue.push(queue, 10)

  let assert Ok(10) = queue.at(queue, t1)

  let assert Error(Nil) = queue.at(queue, 2)
}

fn new_queue() {
  let counter = counter.atomic()

  queue.new(counter, table.Private)
}

fn new_monotonic_queue() {
  let counter = counter.monotonic(monotonic.Nanosecond)

  queue.new(counter, table.Private)
}
