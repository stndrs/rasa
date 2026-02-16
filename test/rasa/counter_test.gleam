import gleam/erlang/process
import rasa/counter

pub fn new_test() {
  let c = counter.new(fn() { Ok(99) })

  let assert Ok(99) = counter.next(c)
}

pub fn atomic_counter_test() {
  let c = counter.atomic()

  let assert Ok(1) = counter.next(c)
}

pub fn atomic_multiple_test() {
  let c = counter.atomic()

  let assert Ok(1) = counter.next(c)
  let assert Ok(2) = counter.next(c)
  let assert Ok(3) = counter.next(c)
}

pub fn independent_atomic_counter_test() {
  let c1 = counter.atomic()
  let c2 = counter.atomic()

  let assert Ok(1) = counter.next(c1)
  let assert Ok(2) = counter.next(c1)
  let assert Ok(1) = counter.next(c2)
}

pub fn monotonic_counter_test() {
  let c = counter.monotonic(counter.Nanosecond)

  let assert Ok(t1) = counter.next(c)

  process.sleep(1)

  let assert Ok(t2) = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_millisecond_counter_test() {
  let c = counter.monotonic(counter.Millisecond)

  let assert Ok(t1) = counter.next(c)

  process.sleep(1)

  let assert Ok(t2) = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_microsecond_counter_test() {
  let c = counter.monotonic(counter.Microsecond)

  let assert Ok(t1) = counter.next(c)

  process.sleep(1)

  let assert Ok(t2) = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_second_counter_test() {
  let c = counter.monotonic(counter.Native)

  let assert Ok(_t1) = counter.next(c)
}
