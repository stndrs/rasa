import gleam/erlang/process
import rasa/counter
import rasa/monotonic

pub fn new_test() {
  let c = counter.new(fn() { 99 })

  let assert 99 = counter.next(c)
}

pub fn atomic_counter_test() {
  let c = counter.atomic()

  let assert 1 = counter.next(c)
}

pub fn atomic_multiple_test() {
  let c = counter.atomic()

  let assert 1 = counter.next(c)
  let assert 2 = counter.next(c)
  let assert 3 = counter.next(c)
}

pub fn independent_atomic_counter_test() {
  let c1 = counter.atomic()
  let c2 = counter.atomic()

  let assert 1 = counter.next(c1)
  let assert 2 = counter.next(c1)
  let assert 1 = counter.next(c2)
}

pub fn monotonic_counter_test() {
  let c = counter.monotonic(monotonic.Nanosecond)

  let t1 = counter.next(c)

  process.sleep(1)

  let t2 = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_millisecond_counter_test() {
  let c = counter.monotonic(monotonic.Millisecond)

  let t1 = counter.next(c)

  process.sleep(1)

  let t2 = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_microsecond_counter_test() {
  let c = counter.monotonic(monotonic.Microsecond)

  let t1 = counter.next(c)

  process.sleep(1)

  let t2 = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_second_counter_test() {
  let c = counter.monotonic(monotonic.Second)

  let _t1 = counter.next(c)
}

pub fn monotonic_native_counter_test() {
  let c = counter.monotonic(monotonic.Native)

  let _t1 = counter.next(c)
}
