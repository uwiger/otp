%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2002-2011. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%

%%
-module(old_ssl_active_once_SUITE).

-export([all/0, suite/0,groups/0,init_per_suite/1, end_per_suite/1, 
	 init_per_group/2,end_per_group/2,
	 init_per_testcase/2,
	 end_per_testcase/2,
	 server_accept_timeout/1,
	 cinit_return_chkclose/1,
	 sinit_return_chkclose/1,
	 cinit_big_return_chkclose/1,
	 sinit_big_return_chkclose/1,
	 cinit_big_echo_chkclose/1,
	 cinit_huge_echo_chkclose/1,
	 sinit_big_echo_chkclose/1,
	 cinit_few_echo_chkclose/1,
	 cinit_many_echo_chkclose/1,
	 cinit_cnocert/1
	]).

-import(ssl_test_MACHINE, [mk_ssl_cert_opts/1, test_one_listener/7,
			   test_server_only/6]).
-include_lib("test_server/include/test_server.hrl").
-include("ssl_test_MACHINE.hrl").

-define(MANYCONNS, ssl_test_MACHINE:many_conns()).

init_per_testcase(_Case, Config) ->
    WatchDog = ssl_test_lib:timetrap(?DEFAULT_TIMEOUT),
    [{watchdog, WatchDog}| Config].

end_per_testcase(_Case, Config) ->
    WatchDog = ?config(watchdog, Config),
    test_server:timetrap_cancel(WatchDog).

suite() -> [{ct_hooks,[ts_install_cth]}].

all() -> 
    [server_accept_timeout, cinit_return_chkclose,
     sinit_return_chkclose, cinit_big_return_chkclose,
     sinit_big_return_chkclose, cinit_big_echo_chkclose,
     cinit_huge_echo_chkclose, sinit_big_echo_chkclose,
     cinit_few_echo_chkclose, cinit_many_echo_chkclose,
     cinit_cnocert].

groups() -> 
    [].

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, Config) ->
    Config.


init_per_suite(doc) ->
    "Want to se what Config contains.";
init_per_suite(suite) ->
    [];
init_per_suite(Config) ->
    io:format("Config: ~p~n", [Config]),

    %% Check if SSL exists. If this case fails, all other cases are skipped
    case catch crypto:start() of
	ok ->
	    application:start(public_key),
	    case ssl:start() of
		ok -> ssl:stop();
		{error, {already_started, _}} -> ssl:stop();
		Error -> ?t:fail({failed_starting_ssl,Error})
	    end,
	    Config;
	_Else ->
	    {skip,"Could not start crypto"}
    end.

end_per_suite(doc) ->
    "This test case has no mission other than closing the conf case";
end_per_suite(suite) ->
    [];
end_per_suite(Config) ->
    crypto:stop(),
    Config.

server_accept_timeout(doc) ->
    "Server has one pending accept with timeout. Checks that return "
	"value is {error, timeout}.";
server_accept_timeout(suite) ->
    [];
server_accept_timeout(Config) when list(Config) ->
    process_flag(trap_exit, true),
    LPort = 3456,
    Timeout = 40000, NConns = 1,
    AccTimeout = 3000,

    ?line {ok, {_, SsslOpts}} = mk_ssl_cert_opts(Config),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, AccTimeout}, 
	     accept_timeout],
    ?line test_server_only(NConns, LCmds, ACmds, Timeout, ?MODULE,
			   Config).

cinit_return_chkclose(doc) ->
    "Client sends 1000 bytes to server, that receives them, sends them "
	"back, and closes. Client waits for close. Both have certs.";
cinit_return_chkclose(suite) ->
    [];
cinit_return_chkclose(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 1000, LPort = 3456,
    Timeout = 40000, NConns = 1,

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {recv, DataSize}, {send, DataSize}, 
	     close],
    CCmds = [{timeout, Timeout},
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

sinit_return_chkclose(doc) ->
    "Server sends 1000 bytes to client, that receives them, sends them "
	"back, and closes. Server waits for close. Both have certs.";
sinit_return_chkclose(suite) ->
    [];
sinit_return_chkclose(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 1000, LPort = 3456,
    Timeout = 40000, NConns = 1,

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {recv, DataSize}, {send, DataSize}, 
	     close],

    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

cinit_big_return_chkclose(doc) ->
    "Client sends 50000 bytes to server, that receives them, sends them "
	"back, and closes. Client waits for close. Both have certs.";
cinit_big_return_chkclose(suite) ->
    [];
cinit_big_return_chkclose(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 50000, LPort = 3456,
    Timeout = 40000, NConns = 1,

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    %% Set {active, false} so that accept is passive to begin with. 
    LCmds = [{sockopts, [{backlog, NConns}, {active, false}]},	
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {sockopts, [{active, once}]},	% {active, once} here.
	     {recv, DataSize}, {send, DataSize}, 
	     close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

sinit_big_return_chkclose(doc) ->
    "Server sends 50000 bytes to client, that receives them, sends them "
	"back, and closes. Server waits for close. Both have certs.";
sinit_big_return_chkclose(suite) ->
    [];
sinit_big_return_chkclose(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 50000, LPort = 3456,
    Timeout = 40000, NConns = 1,

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {recv, DataSize}, {send, DataSize}, 
	     close],

    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

cinit_big_echo_chkclose(doc) ->
    "Client sends 50000 bytes to server, that echoes them back "
	"and closes. Client waits for close. Both have certs.";
cinit_big_echo_chkclose(suite) ->
    [];
cinit_big_echo_chkclose(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 50000, LPort = 3456,
    Timeout = 40000, NConns = 1,

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {echo, DataSize},
	     close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

cinit_huge_echo_chkclose(doc) ->
    "Client sends 500000 bytes to server, that echoes them back "
	"and closes. Client waits for close. Both have certs.";
cinit_huge_echo_chkclose(suite) ->
    [];
cinit_huge_echo_chkclose(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 500000, LPort = 3456,
    Timeout = 40000, NConns = 1,

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {echo, DataSize},
	     close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

sinit_big_echo_chkclose(doc) ->
    "Server sends 50000 bytes to client, that echoes them back "
	"and closes. Server waits for close. Both have certs.";
sinit_big_echo_chkclose(suite) ->
    [];
sinit_big_echo_chkclose(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 50000, LPort = 3456,
    Timeout = 40000, NConns = 1,

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {echo, DataSize},
	     close],

    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

cinit_few_echo_chkclose(X) -> cinit_many_echo_chkclose(X, 7).

cinit_many_echo_chkclose(X) -> cinit_many_echo_chkclose(X, ?MANYCONNS).

cinit_many_echo_chkclose(doc, _NConns) ->
    "client send 10000 bytes to server, that echoes them back "
	"and closes. Clients wait for close. All have certs.";
cinit_many_echo_chkclose(suite, _NConns) ->
    [];
cinit_many_echo_chkclose(Config, NConns) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 10000, LPort = 3456,
    Timeout = 80000,

    io:format("~w connections", [NConns]),

    ?line {ok, {CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {echo, DataSize},
	     close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {sslopts, CsslOpts},
	     {connect, {Host, LPort}},
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).

cinit_cnocert(doc) ->
    "Client sends 1000 bytes to server, that receives them, sends them "
	"back, and closes. Client waits for close. Client has no cert, "
	"but server has.";
cinit_cnocert(suite) ->
    [];
cinit_cnocert(Config) when list(Config) ->
    process_flag(trap_exit, true),
    DataSize = 1000, LPort = 3457,
    Timeout = 40000, NConns = 1,

    ?line {ok, {_CsslOpts, SsslOpts}} = mk_ssl_cert_opts(Config),
    ?line {ok, Host} = inet:gethostname(),

    LCmds = [{sockopts, [{backlog, NConns}, {active, once}]},
	     {sslopts, SsslOpts},
	     {listen, LPort}, 
	     wait_sync,
	     lclose],
    ACmds = [{timeout, Timeout}, 
	     accept,
	     {recv, DataSize}, {send, DataSize}, 
	     close],
    CCmds = [{timeout, Timeout}, 
	     {sockopts, [{active, once}]},
	     {connect, {Host, LPort}},
	     {send, DataSize}, {recv, DataSize}, 
	     await_close],
    ?line test_one_listener(NConns, LCmds, ACmds, CCmds, Timeout, ?MODULE,
			    Config).


