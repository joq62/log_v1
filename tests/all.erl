%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(all).      
    
-include("db_log.hrl").

-export([start/1

	]).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

start([_ClusterSpec,_HostSpec])->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    ok=setup(),
    ok=test_local(),
  
   
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    io:format(" init stop ~p~n",[init:stop()]),
    timer:sleep(2000),

    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
test_local()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=application:start(common),
    ok=application:start(sd),
    
    ok=application:start(log),
    pong=log:ping(),
    true=?NoticeLogMsg(?MODULE,?FUNCTION_NAME,?LINE,"server start",[atom,"string",{term,1,2,"string"}]),

    true=?NoticeLogMsg(?MODULE,?FUNCTION_NAME,?LINE,"event 1",[event_info1]),
    true=?NoticeLogMsg(?MODULE,?FUNCTION_NAME,?LINE,"event 2",[event_info2]),
    true=?WarningLogMsg(?MODULE,?FUNCTION_NAME,?LINE,"warning1",[warning_info1]),
    true=?AlertLogMsg(?MODULE,?FUNCTION_NAME,?LINE,"alert 1",[alert_info1]),
    true=?DebugLogMsg(?MODULE,?FUNCTION_NAME,?LINE,"debug 1",[debug_info1]),
    
    

  %  Text=lists:reverse(parse(db_log:read_all())),
    AllRaw=db_log:all_raw(),
    io:format("AllRaw ~p~n",[AllRaw]),
    AllParsed=db_log:all_parsed(),
    io:format("AllParsed ~p~n",[AllParsed]),

    AllParsedNoticed=db_log:all_parsed(notice),
    io:format("AllParsedNoticed ~p~n",[AllParsedNoticed]),

    AllParsedWarning=db_log:all_parsed(warning),
    io:format("AllParsedWarning ~p~n",[AllParsedWarning]),
    
    AllParsedAlert=db_log:all_parsed(alert),
    io:format("AllParsedAlert ~p~n",[AllParsedAlert]),

    AllParsedDebug=db_log:all_parsed(debug),
    io:format("AllParsedDebug ~p~n",[AllParsedDebug]),

    ok=application:stop(common),
    ok=application:stop(sd),

    ok.
   

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
test_1()->
  io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    AllNodes=test_nodes:get_nodes(),
    [N1,N2,N3,N4]=AllNodes,
    %% Init
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
      

    %% N1
    ok=rpc:call(N1,application,start,[log],5000),
    pong=rpc:call(N1,etcd,ping,[],5000),
    pong=rpc:call(N1,db,ping,[],5000),

    [N1]=lists:sort(rpc:call(N1,mnesia,system_info,[running_db_nodes],5000)),
    io:format("N1 dist OK! ~p~n",[{?MODULE,?LINE}]),
 %   yes=rpc:call(N1,mnesia,system_info,[],5000),
 
    %% N2
    ok=rpc:call(N2,application,start,[etcd],5000),
    pong=rpc:call(N2,etcd,ping,[],5000),
    pong=rpc:call(N2,db,ping,[],5000),
    [N1,N2]=lists:sort(rpc:call(N1,mnesia,system_info,[running_db_nodes],5000)),
    [N1,N2]=lists:sort(rpc:call(N2,mnesia,system_info,[running_db_nodes],5000)),
 %   yes=rpc:call(N2,mnesia,system_info,[],5000),
    io:format("N2 dist OK! ~p~n",[{?MODULE,?LINE}]),

  %% N3
    ok=rpc:call(N3,application,start,[etcd],5000),
    pong=rpc:call(N3,etcd,ping,[],5000),
    pong=rpc:call(N3,db,ping,[],5000),
  
    [N1,N2,N3]=lists:sort(rpc:call(N1,mnesia,system_info,[running_db_nodes],5000)),
    [N1,N2,N3]=lists:sort(rpc:call(N2,mnesia,system_info,[running_db_nodes],5000)),
    [N1,N2,N3]=lists:sort(rpc:call(N3,mnesia,system_info,[running_db_nodes],5000)),
 %   yes=rpc:call(N3,mnesia,system_info,[],5000),
    io:format("N3 dist OK! ~p~n",[{?MODULE,?LINE}]),
 %% N4
    ok=rpc:call(N4,application,start,[etcd],5000),
    pong=rpc:call(N4,etcd,ping,[],5000),
    pong=rpc:call(N4,db,ping,[],5000),
    [N1,N2,N3,N4]=lists:sort(rpc:call(N1,mnesia,system_info,[running_db_nodes],5000)),
    [N1,N2,N3,N4]=lists:sort(rpc:call(N2,mnesia,system_info,[running_db_nodes],5000)),
    [N1,N2,N3,N4]=lists:sort(rpc:call(N3,mnesia,system_info,[running_db_nodes],5000)),
    [N1,N2,N3,N4]=lists:sort(rpc:call(N4,mnesia,system_info,[running_db_nodes],5000)),
   
 %   yes=rpc:call(N4,mnesia,system_info,[],5000),
    io:format("N4 dist OK! ~p~n",[{?MODULE,?LINE}]),
    ok.

%% -------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    ok=test_nodes:start_nodes(),
    [rpc:call(N,code,add_patha,["ebin"],5000)||N<-test_nodes:get_nodes()],    
    [rpc:call(N,code,add_patha,["tests_ebin"],5000)||N<-test_nodes:get_nodes()],     
    [rpc:call(N,code,add_patha,["common/ebin"],5000)||N<-test_nodes:get_nodes()],     
    [rpc:call(N,application,start,[common],5000)||N<-test_nodes:get_nodes()], 
    [rpc:call(N,code,add_patha,["sd/ebin"],5000)||N<-test_nodes:get_nodes()],     
    [rpc:call(N,application,start,[sd],5000)||N<-test_nodes:get_nodes()], 
       
    ok.
