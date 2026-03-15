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

pub fn monotonic_time_counter_test() {
  let c = counter.monotonic_time(monotonic.Nanosecond)

  let t1 = counter.next(c)

  process.sleep(1)

  let t2 = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_time_millisecond_counter_test() {
  let c = counter.monotonic_time(monotonic.Millisecond)

  let t1 = counter.next(c)

  process.sleep(1)

  let t2 = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_time_microsecond_counter_test() {
  let c = counter.monotonic_time(monotonic.Microsecond)

  let t1 = counter.next(c)

  process.sleep(1)

  let t2 = counter.next(c)

  assert t1 < t2
}

pub fn monotonic_time_second_counter_test() {
  let c = counter.monotonic_time(monotonic.Second)

  let _t1 = counter.next(c)
}

pub fn monotonic_time_native_counter_test() {
  let c = counter.monotonic_time(monotonic.Native)

  let _t1 = counter.next(c)
}

pub fn monotonic_counter_test() {
  let c = counter.monotonic()

  let t1 = counter.next(c)
  let t2 = counter.next(c)
  let t3 = counter.next(c)

  assert t1 < t2
  assert t2 < t3
}

pub fn independent_monotonic_counter_test() {
  let c1 = counter.monotonic()
  let c2 = counter.monotonic()

  let t1 = counter.next(c1)
  let t2 = counter.next(c2)
  let t3 = counter.next(c1)

  assert t1 < t2
  assert t2 < t3
}
