all:
	rm -rf  *~ */*~ src/*.beam tests/*.beam tests_ebin erl_cra*;
	rm -rf _build logs log log_dir  *.pod_dir;
	rm -rf _build tests_ebin ebin;
	rm -rf Mnesia.*;
	rm -rf *.dir;
	rm -f rebar.lock;
	rm -rf common;
	rm -rf sd;
	rm -rf nodelog;
	rm -rf db_lib;
#	tests 
	mkdir tests_ebin;
	erlc -I include -o tests_ebin tests/*.erl;
	rm -rf tests_ebin;
#  	dependencies
	mkdir ebin;
	rebar3 compile;	
	cp _build/default/lib/*/ebin/* ebin;
	rm -rf _build*;
	git add -f *;
	git commit -m $(m);
	git push;
	echo Ok there you go!make
build:
	rm -rf  *~ */*~ src/*.beam test/*.beam test_ebin erl_cra*;
	rm -rf _build logs log *.pod_dir;
	rm -rf deployments *_info_specs;
	rm -rf _build test_ebin ebin;
	rm -f  rebar.lock;
	rm -rf common;
	rm -rf sd;
	rm -rf nodelog;
	rm -rf db_lib;
	mkdir ebin;		
	rebar3 compile;	
	cp _build/default/lib/*/ebin/* ebin;
	rm -rf _build test_ebin logs log;


clean:
	rm -rf  *~ */*~ src/*.beam tests/*.beam
	rm -rf erl_cra*;
	rm -rf spec.*;
	rm -rf tests_ebin
	rm -rf ebin;
	rm -rf Mnesia.*;
	rm -rf *.dir;
	rm -rf common;
	rm -rf sd;
	rm -rf nodelog;
	rm -rf db_lib;

eunit:
	rm -rf  *~ */*~ src/*.beam tests/*.beam
	rm -rf erl_cra*;	
	rm -rf tests_ebin
	rm -rf ebin;
	rm -rf Mnesia.*;
	rm -rf *.dir;
	rm -f rebar.lock;
#	tests 
	mkdir tests_ebin;
#	cp tests/*.app tests_ebin;
	erlc -I include -D debug -o tests_ebin tests/*.erl;
#  	dependencies
	rm -rf common;
	git clone https://github.com/joq62/common.git;
	rm -rf sd;
	git clone https://github.com/joq62/sd.git;
	rm -rf db_lib;
	git clone https://github.com/joq62/db_lib.git;
#	Applications
	mkdir ebin;
	erlc -I include -D debug -o ebin sd/src/*.erl;
	erlc -I include -D debug -o ebin common/src/*.erl;
	erlc -I include -D debug -o ebin db_lib/src/*.erl;
	erlc -I include -D debug -o ebin src/*.erl;
	cp src/log.app.src ebin/log.app;
#	rebar3 compile;	
#	cp _build/default/lib/*/ebin/* ebin;
#	rm -rf _build*;
	erl -pa * -pa */ebin -pa ebin -pa tests_ebin -sname log_test -run $(m) start $(a) $(b) -setcookie test_cookie
