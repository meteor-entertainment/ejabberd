%%%============================================================================
%%% @copyright (C) 2013, Meteor Entertianment
%%% @doc Module for serving static webpages using cowboys static handler
%%% @end
%%%============================================================================
-module(mod_webserver).
-behaviour(gen_mod).


%% gen_mod callbacks
-export([start/2,
		 stop/1]).

%% ejabberd_listener
-export([socket_type/0,
         start_listener/2]).

-export ([stop/0]).

-include("ejabberd.hrl").

-define(LISTENER, ?MODULE).		 


%%----------------------------------------------------------------------------
%% ejabberd_listener
%%----------------------------------------------------------------------------
-spec socket_type() -> independent.
socket_type() ->
	independent.
	
% -spec start_listener(list())
start_listener({Port, _IP, tcp}, Opts) ->
         Dispatch = get_dispatch(Opts),
         ?INFO_MSG("DISPATCH ~p~n",[Dispatch]),
	 NumAcceptors = gen_mod:get_opt(num_acceptors, Opts, 100),
	 start_webserver(NumAcceptors, Port, Dispatch).
	 
%%-----------------------------------------------------------------------------
%% gen_mod callbacks
%%-----------------------------------------------------------------------------
start(_Host,Opts)->
	NumAcceptors = gen_mod:get_opt(num_acceptors, Opts, 100),
	Port = gen_mod:get_opt(port, Opts, undefined),
	Dispatch = get_dispatch(Opts),
	{ok,_} = start_webserver(NumAcceptors, Port, Dispatch).
	
	
start_webserver(_,undefined,_)->
    {ok, not_started};
start_webserver(NumAcceptors, Port, Dispatch)->
    case cowboy:start_http(?LISTENER, NumAcceptors,
							[{port,Port}],
							[{env,[{dispatch, Dispatch}]}]) of
		{error, {already_started, Pid}} ->
			{ok,Pid};
		{ok,Pid} ->
			{ok, Pid};
		{error,Reason} ->
			{error, Reason}
	end.
	
stop() ->
	stop(any).
	
stop(_Host)->
	cowboy:stop_listener(?LISTENER),
	ok.
	
%%-----------------------------------------------------------------------------
%% Helpers
%%-----------------------------------------------------------------------------

get_dispatch(Opts)->
	Host = gen_mod:get_opt(host, Opts, '_'),
	Prefix = gen_mod:get_opt(prefix, Opts, "/[...]"),
	Appname = gen_mod:get_opt(appname, Opts, ejabberd),
        ?INFO_MSG("get dispatch Host:~p Prefix:~p Appname~p",[Host, Prefix,Appname]),
	cowboy_router:compile([{Host, [{Prefix, cowboy_static, [
										{directory, {priv_dir, Appname, []}},
										{mimetypes, {fun mimetypes:path_to_mimes/2, default}}
									]}
							]}
						]).
