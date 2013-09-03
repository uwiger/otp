%% This module is used to test backend plugin extensions to the mnesia
%% backend. It also indirectly tests the mnesia backend plugin
%% extension machinery
%%
%% Usage: mnesia_ext_eleveldb_test:recompile(Extension).
%% Usage: mnesia_ext_eleveldb_test:recompile().
%% This command is executed in the release/tests/test_server directory
%% before running the normal tests. The command patches the test code,
%% via a parse_transform, to replace disc_only_copies with the Alias.

-module(mnesia_ext_eleveldb_test_helper).
-author("roland.karlsson@erlang-solutions.com").

%% EXPORTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Exporting API
-export([recompile/0, recompile/1]).

%% Exporting parse_transform callback
-export([parse_transform/2]).

%% Exporting replacement for mnesia:create_table/2
-export([create_table/1, create_table/2]).

%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Recompiling the test code, replacing disc_only_copies with
%% Extension.
recompile() ->
    [{Module,Alias}|_] = extensions(),
    recompile(Module, Alias).

recompile(MorA) ->
    case { lists:keyfind(MorA, 1, extensions()),
           lists:keyfind(MorA, 2, extensions())
         } of
        {{Module,Alias}, _} ->
            recompile(Module, Alias);
        {false, {Module,Alias}} ->
            recompile(Module, Alias);
        {false,false} ->
            {error, cannot_find_module_or_alias}
    end.

recompile(Module, Alias) ->
    io:format("recompile(~p,~p)~n",[Module, Alias]),
    put_ext(module, Module),
    put_ext(alias, Alias),
    Modules = [ begin {M,_} = lists:split(length(F)-4, F), list_to_atom(M) end ||
                  F <- begin {ok,L} = file:list_dir("."), L end,
                  lists:suffix(".erl", F),
                  F=/= atom_to_list(?MODULE) ++ ".erl" ],
    io:format("Modules = ~p~n",[Modules]),
    lists:foreach(fun(M) -> c:c(M, [{parse_transform, ?MODULE}]) end, Modules).

%% TEST REPLACEMENT CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% replacement for mnesia:create_table that ensures that
create_table(Name, Parameters) ->
    create_table([{name,Name} | Parameters]).

create_table(Parameters) ->
    case lists:keymember(leveldb_copies, 1, Parameters) of
        true ->
            case lists:member({type, bag}, Parameters) of
                true ->
                    ct:comment("ERROR: Contains leveldb table with bag"),
                    {aborted, {leveldb_does_not_support_bag, Parameters}};
                false ->
                    ct:comment("INFO: Contains leveldb table"),
                    io:format("INFO: create_table(~p)~n", [Parameters]),
                    mnesia:create_table(Parameters)
            end;
        false ->
            mnesia:create_table(Parameters)
    end.

%% PARSE_TRANSFORM CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% The callback for c:c(Module, [{parse_transform,?MODULE}])
parse_transform(Forms, _Options) ->
    plain_transform(fun do_transform/1, Forms).

do_transform({'attribute', _, module, Module}) ->
    io:format("~n~nMODULE: ~p~n", [Module]),
    continue;
do_transform({'atom', Line, disc_only_copies}) ->
    io:format(".", []),
    {'atom', Line, get_ext(alias)};
do_transform(Form = { call, L1,
		      { remote, L2,
			{atom, L3, mnesia},
			{atom, L4, create_table}},
		      Arguments}) ->
    NewForm = { call, L1,
		{ remote, L2,
		  {atom, L3, ?MODULE},
		  {atom, L4, create_table}},
		Arguments},
    io:format("~nConvert Form:~n~p~n~p~n", [Form, NewForm]),
    NewForm;
do_transform(Form = { call, L1,
		      { remote, L2,
			{atom, L3, mnesia},
			{atom, L4, create_schema}},
		      [Nodes]}) ->
    P = element(2, Nodes),
    NewForm = { call, L1,
		{ remote, L2,
		  {atom, L3, mnesia},
		  {atom, L4, create_schema}},
		[Nodes, erl_parse:abstract([{backend_types, backends()}], P)]},
    io:format("~nConvert Form:~n~p~n~p~n", [Form, NewForm]),
    NewForm;
do_transform(_Form) ->
    continue.

%% INTERNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% A trick for doing parse transforms easier

plain_transform(Fun, Forms) when is_function(Fun, 1), is_list(Forms) ->
    plain_transform1(Fun, Forms).

plain_transform1(_, []) ->
    [];
plain_transform1(Fun, [F|Fs]) when is_atom(element(1,F)) ->
    case Fun(F) of
	continue ->
	    [list_to_tuple(plain_transform1(Fun, tuple_to_list(F))) |
	     plain_transform1(Fun, Fs)];
	{done, NewF} ->
	    [NewF | Fs];
	{error, Reason} ->
	    io:format("Error: ~p (~p)~n", [F,Reason]);
	NewF when is_tuple(NewF) ->
	    [NewF | plain_transform1(Fun, Fs)]
    end;
plain_transform1(Fun, [L|Fs]) when is_list(L) ->
    [plain_transform1(Fun, L) | plain_transform1(Fun, Fs)];
plain_transform1(Fun, [F|Fs]) ->
    [F | plain_transform1(Fun, Fs)];
plain_transform1(_, F) ->
    F.

%% Existing extensions.
%% NOTE: The first is default.
extensions() ->
    [ {mnesia_ext_eleveldb, leveldb_copies},
      {mnesia_ext_filesystem, fs_copies},
      {mnesia_ext_filesystem, fstab_copies},
      {mnesia_ext_filesystem, raw_fs_copies}
    ].

backends() ->
    [{T,M} || {M,T} <- extensions()].

%% Process global storage

put_ext(Key, Value) ->
    case ets:info(global_storage) of
        undefined ->
            ets:new(global_storage, [public,named_table]);
        _ ->
            ok
    end,
    ets:insert(global_storage, {Key, Value}).

get_ext(Key) ->
    case catch ets:lookup(global_storage, Key) of
        [] ->
            io:format("Data for ~p not stored~n", [Key]),
            undefined;
        {'EXIT', Reason} ->
            io:format("Get value for ~p failed (~p)~n", [Key, Reason]),
            undefined;
        [{Key,Value}] ->
            Value
    end.
