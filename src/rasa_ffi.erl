-module(rasa_ffi).

-export([
  ets_new/2,
  ets_insert/3,
  ets_insert_new/3,
  ets_first_lookup/1,
  ets_delete_first/1,
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

ets_insert(TableRef, Key, Value) ->
  try
    ets:insert(TableRef, {Key, Value}),
    {ok, nil}
  catch error:badarg -> {error, nil}
  end.

ets_insert_new(TableRef, Key, Value) ->
  try
    case ets:insert_new(TableRef, {Key, Value}) of
      true -> {ok, nil};
      false -> {error, nil}
    end
  catch error:badarg -> {error, nil}
  end.

ets_first_lookup(TableRef) ->
  try
    case ets:first_lookup(TableRef) of
      '$end_of_table' -> {error, nil};
      {Key, [{_Key, Value}]} -> {ok, {Key, Value}}
    end
  catch error:badarg -> {error, nil}
  end.

ets_delete_first(TableRef) ->
  try
    case ets:first_lookup(TableRef) of
      '$end_of_table' -> {error, nil};
      {Key, [{_Key, _Value}]} ->
        case ets:take(TableRef, Key) of
          [{_Key2, Value2}] -> {ok, {Key, Value2}};
          [] -> ets_delete_first(TableRef)
        end
    end
  catch error:badarg -> {error, nil}
  end.

ets_last_lookup(TableRef) ->
  try
    case ets:last_lookup(TableRef) of
      '$end_of_table' -> {error, nil};
      {Key, [{_Key, Value}]} -> {ok, {Key, Value}}
    end
  catch error:badarg -> {error, nil}
  end.

ets_lookup(TableRef, Key) ->
  try
    case ets:lookup(TableRef, Key) of
      [{_Key, Value}] -> {ok, Value};
      [] -> {error, nil}
    end
  catch error:badarg -> {error, nil}
  end.

ets_to_list(TableRef) ->
  try
    {ok, ets:tab2list(TableRef)}
  catch error:badarg -> {error, nil}
  end.

ets_delete(TableRef) ->
  try
    ets:delete(TableRef),
    {ok, nil}
  catch error:badarg -> {error, nil}
  end.

ets_delete(TableRef, Key) ->
  try
    ets:delete(TableRef, Key),
    {ok, nil}
  catch error:badarg -> {error, nil}
  end.

ets_info(TableRef, Item) ->
  try
    case ets:info(TableRef, Item) of
      undefined -> {error, nil};
      Value -> {ok, Value}
    end
  catch error:badarg -> {error, nil}
  end.

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
