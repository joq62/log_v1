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
-module(parent_desired_state_test).      
 
-export([start/2]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start(Node,ClusterSpec)->
    io:format("Start ~p~n",[{Node,ClusterSpec,?MODULE,?FUNCTION_NAME}]),

    ok=setup(Node),
    ok=load_desired_state(Node,ClusterSpec),
    ok=read_specs_test(Node),
  
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),

    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
load_desired_state(Node,_ClusterSpec)->
    
    [
     {'c201_parent@c201',"c201_parent","c201","c201"," -pa c201 "," -pa c201/*/ebin"," "},
     {'cluster_test_parent@c200',"cluster_test_parent","cluster_test","c200",
      " -pa cluster_test "," -pa cluster_test/*/ebin"," "},
     {'cluster_test_parent@c201',"cluster_test_parent","cluster_test","c201",
      " -pa cluster_test "," -pa cluster_test/*/ebin"," "}
    ]=lists:sort(rpc:call(Node,db_parent_desired_state,read_all,[],5000)),

    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
read_specs_test(Node)->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    AllHosts=lists:sort(rpc:call(Node,db_host_spec,get_all_id,[],5000)),
    true=lists:member("c50",AllHosts),

   {"c50","c50","192.168.1.50",22,"joq62","festum01",[]}=rpc:call(Node,db_host_spec,read,["c50"],5000),
    
    {ok,"c50"}=rpc:call(Node,db_host_spec,read,[hostname,"c50"],5000),
    {ok,"192.168.1.50"}=rpc:call(Node,db_host_spec,read,[local_ip,"c50"],5000),
    {ok,22}=rpc:call(Node,db_host_spec,read,[ssh_port,"c50"],5000),
    {ok,"joq62"}=rpc:call(Node,db_host_spec,read,[uid,"c50"],5000),
    {ok,"festum01"}=rpc:call(Node,db_host_spec,read,[passwd,"c50"],5000),
    {ok,[]}=rpc:call(Node,db_host_spec,read,[application_config,"c50"],5000),
    


    {error,[eexist,"glurk",db_host_spec,_]}=rpc:call(Node,db_host_spec,read,[ssh_port,"glurk"],5000),
    {error,['Key eexists',glurk,"c50",db_host_spec,_]}=rpc:call(Node,db_host_spec,read,[glurk,"c50"],5000),
 
       ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup(Node)->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
       
    pong=rpc:call(Node,etcd,ping,[],5000),
   
    ok.