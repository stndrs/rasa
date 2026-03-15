import gleam/erlang/process
import rasa/monotonic

pub fn nanosecond_test() {
  let t1 = monotonic.time(monotonic.Nanosecond)
  process.sleep(1)
  let t2 = monotonic.time(monotonic.Nanosecond)
  assert t1 < t2
}

pub fn millisecond_test() {
  let t1 = monotonic.time(monotonic.Millisecond)
  process.sleep(1)
  let t2 = monotonic.time(monotonic.Millisecond)
  assert t1 < t2
}

pub fn microsecond_test() {
  let t1 = monotonic.time(monotonic.Microsecond)
  process.sleep(1)
  let t2 = monotonic.time(monotonic.Microsecond)
  assert t1 < t2
}

pub fn second_test() {
  let _t1 = monotonic.time(monotonic.Second)
}

pub fn native_test() {
  let _t1 = monotonic.time(monotonic.Native)
}

pub fn unique_test() {
  let t1 = monotonic.unique()
  let t2 = monotonic.unique()
  let t3 = monotonic.unique()
  assert t1 < t2
  assert t2 < t3
}
