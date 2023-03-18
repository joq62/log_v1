%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
-module(log).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("db_log.hrl").

-define(SERVER,log_server).
%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 notice/5,warning/5,alert/5,debug/5,
	 all_raw/0,all_raw/1,all_parsed/0,all_parsed/1,
	 ping/0

	]).


%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------
    
all_raw()->
    rpc:call(node(),db_log,all_raw,[],5000).
all_raw(Severity)->
    rpc:call(node(),db_log,all_raw,[Severity],5000).
all_parsed()->
    rpc:call(node(),db_log,all_parsed,[],5000).
all_parsed(Severity)->
    rpc:call(node(),db_log,all_parsed,[Severity],5000).

notice(Module,Function,Line,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,node(),
				   notice,Key,Info]).

warning(Module,Function,Line,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,node(),
				   warning,Key,Info]).

alert(Module,Function,Line,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,node(),
				   alert,Key,Info]).

debug(Module,Function,Line,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,node(),
				   debug,Key,Info]).



ping() ->
    gen_server:call(?SERVER, {ping}).





%% ====================================================================!
%% External functions
%% ====================================================================!


%% ====================================================================
%% Internal functions
%% ====================================================================
