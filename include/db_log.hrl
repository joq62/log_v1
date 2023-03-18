
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
				
