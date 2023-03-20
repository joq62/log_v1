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
	 notice/6,warning/6,alert/6,debug/6,
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

notice(Module,Function,Line,Node,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,Node,
				   notice,Key,Info]).

warning(Module,Function,Line,Node,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,Node,
				   warning,Key,Info]).

alert(Module,Function,Line,Node,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,Node,
				   alert,Key,Info]).

debug(Module,Function,Line,Node,Key,Info)->
    rpc:cast(node(),db_log,create,[os:system_time(?SystemTimeUnit),
				   date(),time(),
				   Module,Function,Line,Node,
				   debug,Key,Info]).



ping() ->
    gen_server:call(?SERVER, {ping}).





%% ====================================================================!
%% External functions
%% ====================================================================!


%% ====================================================================
%% Internal functions
%% ====================================================================
