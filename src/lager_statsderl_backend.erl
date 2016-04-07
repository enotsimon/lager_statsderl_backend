-module(lager_statsderl_backend).
-behaviour(gen_event).
-include_lib("lager/include/lager.hrl").

-export([init/1, handle_call/2, handle_event/2, handle_info/2, terminate/2, code_change/3]).


init(Config) ->
	validate_config(Config),
	FixedLevel = case proplists:get_value(level, Config) of
		Value when is_integer(Value) -> Value;
		Value2 when is_atom(Value2) -> lager_util:level_to_num(Value2)
	end,
	Prefix = proplists:get_value(prefix, Config),
	FixedPrefix = string:strip(Prefix, both, $.) ++ ".",
	{ok, [{level, FixedLevel}, {prefix, FixedPrefix}]}.


terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

handle_call(get_loglevel, State) ->
	{ok, proplists:get_value(level, State), State};

handle_call({set_loglevel, LogLevel}, State) ->
	LevelNum = lager_util:level_to_num(LogLevel),
	case lists:member(LogLevel, lager_util:levels()) of
		true -> {ok, ok, lists:keyreplace(level, 1, State, {level, LevelNum})};
		_ -> {ok, {error, bad_log_level}, State}
	end;

handle_call(V, State) -> {stop, {unexpected_call, V}, State}.




handle_event({log, Message}, State) ->
	case lager_msg:severity_as_int(Message) =< proplists:get_value(level, State) of
		true -> sj_statsd:increment(proplists:get_value(prefix, State) ++ erlang:atom_to_list(lager_msg:severity(Message)));
		false -> void
	end,
	{ok, State};

handle_event(V, State) ->
	{stop, {unexpected_event, V}, State}.


handle_info(_V, State) -> {ok, State}.

%%
%%	PRIVATE
%%
validate_config(Config) when is_list(Config) ->
	Level = proplists:get_value(level, Config),
	Prefix = proplists:get_value(prefix, Config),
	if
		Level =:= undefined -> error("message level not set");
		Prefix =:= undefined -> error("prefix for graphite key not set");
		true -> ok
	end;
validate_config(_Config) ->
	error("config is not a list").
