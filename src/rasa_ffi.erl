-module(rasa_ffi).

-export([
  ets_new/2,
  ets_insert/3,
  ets_insert_new/3,
  ets_first_lookup/1,
  ets_last_lookup/1,
  ets_lookup/2,
  ets_to_list/1,
  ets_delete/1,
  ets_delete/2,
  ets_info/2,
  monotonic_unique_int/0,
  atomics_new/0,
  atomics_get/1,
  atomics_put/2,
  atomics_add/2,
  atomics_add_get/2,
  atomics_sub/2,
  atomics_sub_get/2,
  atomics_exchange/2,
  atomics_compare_exchange/3
]).

monotonic_unique_int() -> erlang:unique_integer([monotonic]).

%%% ETS %%%

ets_new(Kind, Access) ->
  Opts = [Kind, Access],
  ets:new(rasa_table, Opts).

ets_insert(Name, Key, Value) ->
  with_rescue(fun() ->
    ets:insert(Name, {Key, Value}),

    {ok, nil}
  end).

ets_insert_new(Name, Key, Value) ->
  with_rescue(fun() ->
    case ets:insert_new(Name, {Key, Value}) of
      true -> {ok, nil};
      false -> {error, nil}
    end
  end).

ets_first_lookup(Name) ->
  with_rescue(fun() ->
    case ets:first_lookup(Name) of
      '$end_of_table' -> {error, nil};
      {Key, [{_Key, Value}]} -> {ok, {Key, Value}}
    end
  end).

ets_last_lookup(Name) ->
  with_rescue(fun() ->
    case ets:last_lookup(Name) of
      '$end_of_table' -> {error, nil};
      {Key, [{_Key, Value}]} -> {ok, {Key, Value}}
    end
  end).

ets_lookup(Name, Key) ->
  with_rescue(fun() ->
    case ets:lookup(Name, Key) of
      [{_Key, Value}] -> {ok, Value};
      [] -> {error, nil}
    end
  end).

ets_to_list(Name) ->
  with_rescue(fun() ->
    List = ets:tab2list(Name),

    {ok, List}
  end).

ets_delete(Name) ->
  with_rescue(fun() ->
    ets:delete(Name),

    {ok, nil}
  end).

ets_delete(Name, Key) ->
  with_rescue(fun() ->
    ets:delete(Name, Key),

    {ok, nil}
  end).

ets_info(Name, Item) ->
  with_rescue(fun() ->
    case ets:info(Name, Item) of
      undefined -> {error, nil};
      Value -> {ok, Value}
    end
  end).

%%% Atomics %%%

atomics_new() ->
  atomics:new(1, [{signed, true}]).

atomics_get(Ref) ->
  atomics:get(Ref, 1).

atomics_put(Ref, Value) ->
  atomics:put(Ref, 1, Value), nil.

atomics_add(Ref, Value) ->
  atomics:add(Ref, 1, Value), nil.

atomics_add_get(Ref, Value) ->
  atomics:add_get(Ref, 1, Value).

atomics_sub(Ref, Value) ->
  atomics:sub(Ref, 1, Value), nil.

atomics_sub_get(Ref, Value) ->
  atomics:sub_get(Ref, 1, Value).

atomics_exchange(Ref, Value) ->
  atomics:exchange(Ref, 1, Value).

atomics_compare_exchange(Ref, Expected, Desired) ->
  case atomics:compare_exchange(Ref, 1, Expected, Desired) of
    ok -> {ok, nil};
    Actual -> {error, Actual}
  end.

%%% Helper functions %%%

with_rescue(Fun) ->
  try Fun()
  catch error:badarg -> {error, nil}
  end.
