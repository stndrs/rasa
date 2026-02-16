-module(rasa_ffi).

-export([
  counters_new/1,
  counters_add/3,
  counters_sub/3,
  counters_get/2,
  ets_new/3,
  ets_insert/3,
  ets_insert_new/3,
  ets_first_lookup/1,
  ets_last_lookup/1,
  ets_lookup/2,
  ets_to_list/1,
  ets_delete/1,
  ets_delete/2,
  ets_info/2,
  unique_int/0
]).

unique_int() -> erlang:unique_integer([positive]).

%%% ETS %%%

ets_new(Name, Kind, Access) ->
  Opts = [named_table, Kind, Access],
  ets:new(Name, Opts).

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

%%% Counters %%%

counters_new(Size) ->
  counters:new(Size, [atomics]).

counters_add(Counter, Ix, Incr) ->
  with_rescue(fun() ->
    counters:add(Counter, Ix, Incr),

    {ok, nil}
  end).

counters_sub(Counter, Ix, Incr) ->
  with_rescue(fun() ->
    counters:sub(Counter, Ix, Incr),

    {ok, nil}
  end).

counters_get(Counter, Ix) ->
  with_rescue(fun() ->
    Value = counters:get(Counter, Ix),

    {ok, Value}
  end).

%%% Helper functions %%%

with_rescue(Fun) ->
  try Fun()
  catch error:badarg -> {error, nil}
  end.
