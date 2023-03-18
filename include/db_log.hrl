
-define(TABLE,db_log).
-define(RECORD,?TABLE).
-record(?RECORD,{
		 timestamp,
		 date,
		 time,
		 module,
		 function,
		 line,
		 node,
		 severity,
		 key,
		 info
		}).
-define(SystemTimeUnit,microsecond).

%% sd:cast(log,log,create,?NoticeInfo(?MODULE,?FUNCTION_NAME,?LINE,
%%                                    "server start",[info_term]),

-define(NoticeInfo(Module,Function,Line,Key,Info),
	[os:system_time(?SystemTimeUnit),date(),time(),
	 Module,Function,Line,node(),
	 notice,Key,Info]).
-define(WarningInfo(Module,Function,Line,Key,Info),
	[os:system_time(?SystemTimeUnit),date(),time(),
	 Module,Function,Line,node(),
	 warning,Key,Info]).
-define(AlertInfo(Module,Function,Line,Key,Info),
	[os:system_time(?SystemTimeUnit),date(),time(),
	 Module,Function,Line,node(),
	 alert,Key,Info]).
-define(DebugInfo(Module,Function,Line,Key,Info),
	[os:system_time(?SystemTimeUnit),date(),time(),
	 Module,Function,Line,node(),
	 debug,Key,Info]).


-define(NoticeLogMsg(Module,Function,Line,Key,Info),
	sd:cast(log,db_log,create,[os:system_time(?SystemTimeUnit),
				date(),
				time(),
				Module,
				Function,
				Line,
				node(),
				notice,
				Key,
				Info])).

-define(WarningLogMsg(Module,Function,Line,Key,Info),
	sd:cast(log,db_log,create,[os:system_time(?SystemTimeUnit),
				date(),
				time(),
				Module,
				Function,
				Line,
				node(),
				warning,
				Key,
				Info])).

-define(AlertLogMsg(Module,Function,Line,Key,Info),
	sd:cast(log,db_log,create,[os:system_time(?SystemTimeUnit),
				date(),
				time(),
				Module,
				Function,
				Line,
				node(),
				alert,
				Key,
				Info])).

-define(DebugLogMsg(Module,Function,Line,Key,Info),
	sd:cast(log,db_log,create,[os:system_time(?SystemTimeUnit),
				date(),
				time(),
				Module,
				Function,
				Line,
				node(),
				debug,
				Key,
				Info])).
				
