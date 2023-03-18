%%% @author c50 <joq62@c50>
%%% @copyright (C) 2022, c50
%%% @doc
%%%
%%% @end
%%% Created : 21 Dec 2022 by c50 <joq62@c50>

-module(db_log).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("stdlib/include/qlc.hrl").
-include("db_log.hrl").

%% External exports
-export([create_table/0,create_table/2,add_node/2]).
-export([create/10,delete/1]).
-export([read_all/0,read/1,read/2,get_all_id/0]).
-export([do/1]).
-export([member/1]).
-export([all_raw/0,all_parsed/0,
	 all_raw/1,all_parsed/1]).

%% Special funtions


%% introduce read_clear (severity) 
%% new 
%% all, module/node node/host 
%% 

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
all_raw()->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    Z1=lists:reverse(Z),
    [{R#?RECORD.timestamp,R#?RECORD.date,R#?RECORD.time,
      R#?RECORD.module,R#?RECORD.function,R#?RECORD.line,R#?RECORD.node,
      R#?RECORD.severity,R#?RECORD.key,R#?RECORD.info}||R<-Z1].

all_parsed()->
    parse(all_raw()).


all_raw(Severity)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),		
		     X#?RECORD.severity==Severity])),
    Z1=lists:reverse(Z),
    [{R#?RECORD.timestamp,R#?RECORD.date,R#?RECORD.time,
      R#?RECORD.module,R#?RECORD.function,R#?RECORD.line,R#?RECORD.node,
      R#?RECORD.severity,R#?RECORD.key,R#?RECORD.info}||R<-Z1].

all_parsed(Severity)->
    parse(all_raw(Severity)).
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

create_table()->
    mnesia:create_table(?TABLE, [{attributes, record_info(fields, ?RECORD)},
				 {type,ordered_set}
				]),
    mnesia:wait_for_tables([?TABLE], 20000).

create_table(NodeList,StorageType)->
    mnesia:create_table(?TABLE, [{attributes, record_info(fields, ?RECORD)},
				 {type,ordered_set},
				 {StorageType,NodeList}]),
    mnesia:wait_for_tables([?TABLE], 20000).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

add_node(Node,StorageType)->
    Result=case mnesia:change_config(extra_db_nodes, [Node]) of
	       {ok,[Node]}->
		   mnesia:add_table_copy(schema, node(),StorageType),
		   mnesia:add_table_copy(?TABLE, node(), StorageType),
		   Tables=mnesia:system_info(tables),
		   mnesia:wait_for_tables(Tables,20*1000);
	       Reason ->
		   Reason
	   end,
    Result.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

create(TimeStamp,Date,Time,Module,Function,Line,Node,Severity,Key,Info)->
    Record=#?RECORD{
		    timestamp=TimeStamp,
		    date=Date,
		    time=Time,
		    module=Module,
		    function=Function,
		    line=Line,
		    node=Node,
		    severity=Severity,
		    key=Key,
		    info=Info	   
		   },
    F = fun() -> mnesia:write(Record) end,
    mnesia:transaction(F).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
delete(TimeStamp) ->
    F = fun() ->
                mnesia:delete({?TABLE,TimeStamp})
        end,
    mnesia:transaction(F).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

member(TimeStamp)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),		
		     X#?RECORD.timestamp==TimeStamp])),
    Member=case Z of
	       []->
		   false;
	       _->
		   true
	   end,
    Member.
   
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

read(Key,TimeStamp)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),		
		     X#?RECORD.timestamp==TimeStamp])),
    Result=case Z of
	       []->
		   {error,["TimeStamp doesnt exists",TimeStamp,?MODULE,?LINE]};
	      [Record]->
		   
    		   case  Key of
		       timestamp->
			   {ok,Record#?RECORD.timestamp};
		       date->
			   {ok,Record#?RECORD.date};
		       time->
			   {ok,Record#?RECORD.time};
		       module->
			   {ok,Record#?RECORD.module};
		       function->
			   {ok,Record#?RECORD.function};
		       line->
			   {ok,Record#?RECORD.line};
		       node->
			   {ok,Record#?RECORD.node};
		       severity->
			   {ok,Record#?RECORD.severity};
		       key->
			   {ok,Record#?RECORD.key};
		       info->
			   {ok,Record#?RECORD.info};
		       Err ->
			   {error,['Key eexists',Err,TimeStamp,?MODULE,?LINE]}
		   end
	   end,
    Result.


get_all_id()->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    Z1=lists:reverse(Z),
    [R#?RECORD.timestamp||R<-Z1].
    
read_all() ->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    Z1=lists:reverse(Z),
    [{R#?RECORD.timestamp,R#?RECORD.date,R#?RECORD.time,
      R#?RECORD.module,R#?RECORD.function,R#?RECORD.line,R#?RECORD.node,
      R#?RECORD.severity,R#?RECORD.key,R#?RECORD.info}||R<-Z1].

read(TimeStamp)->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),		
		     X#?RECORD.timestamp==TimeStamp])),
    Result=case Z of
	       []->
		  [];
	       [R]->
		   {R#?RECORD.timestamp,R#?RECORD.date,R#?RECORD.time,
		    R#?RECORD.module,R#?RECORD.function,R#?RECORD.line,R#?RECORD.node,
		    R#?RECORD.severity,R#?RECORD.key,R#?RECORD.info}
	   end,
    Result.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    Result=case mnesia:transaction(F) of
	       {atomic, Val} ->
		   Val;
	       {error,Reason}->
		   {error,Reason}
	   end,
    Result.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
parse(ListRaw)->
    [parse_item(Item)||Item<-ListRaw].

parse_item({_TimeStamp,Date,Time,Module,Function,Line,Node,Severity,Key,Info})->
     %  TimeUnit=microsecond,
  %  {{Y,M,D},{H,Mi,S}}=calendar:system_time_to_local_time(TimeStamp, TimeUnit),
    {Y,M,D}=Date,
    {H,Mi,S}=Time,
    Year=integer_to_list(Y),
    Month=integer_to_list(M),
    Day=integer_to_list(D),
    Hour=integer_to_list(H),
    Min=integer_to_list(Mi),
    Sec=integer_to_list(S),
    DateTime=Year++"-"++Month++"-"++Day++" | "++Hour++":"++Min++":"++Sec++" | ",

    ModuleStr=atom_to_list(Module),
    FunctionStr=atom_to_list(Function),
    LineStr=integer_to_list(Line),
    NodeStr=atom_to_list(Node),
    ModuleInfo=ModuleStr++":"++FunctionStr++"/"++LineStr++" at "++NodeStr++" | ",

    SeverityStr=atom_to_list(Severity),
    
    R= io_lib:format("~p",[Info]),
    InfoStr=lists:flatten(R),
    KeyInfo=Key++" | "++InfoStr,
   
    Text=DateTime++ModuleInfo++SeverityStr++" | "++KeyInfo,
    Text.
