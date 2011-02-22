%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 1996-2010. All Rights Reserved.
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
%% External filesystem storage backend for mnesia.
%% Usage: mnesia:create_table(Tab, [{external, [
%%                                   {mnesia_ext_filesystem, Nodes}]}, ...]).

-module(mnesia_ext_filesystem).
-behaviour(mnesia_backend_type).
-compile(export_all).

-export([register/0]).
%%
-export([check_definition/4,
	 create_table/3,
	 delete_table/2,
	 load_table/3,
	 info/3]).

-export([sender_init/4,
	 receiver_first_message/4,
	 receive_data/3,
	 receive_done/3
	]).

%% low-level accessor callbacks.
-export([
	 clear_table/2,
	 delete/3,
	 first/2,
	 fixtable/3,
	 insert/3,
	 last/2,
	 lookup/3,
	 match_delete/3,
	 match_object/3,
	 next/3,
	 prev/3,
	 slot/3,
	 update_counter/4,
	 repair_continuation/2,
	 select/1,
	 select/3,
	 select/4
	]).

%% record and key validation
-export([validate_key/6,
	 validate_record/6]).

%% table process start and callbacks
-export([start_proc/3,
	 init/1,
	 handle_call/3,
	 handle_info/2,
	 handle_cast/2,
	 terminate/2,
	 code_change/3]).

-include("mnesia.hrl").
-include_lib("kernel/include/file.hrl").
-record(info, {tab,
	       key,
	       fullname,
	       recname}).

-record(sel, {alias,
	      tab,
	      type,
	      recname,
	      mp,
	      keypat,
	      ms,
	      limit,
	      direction = forward}).

-record(st, {ets,
	     dets,
	     mp,
	     data_mp,
	     alias,
	     tab}).

register() ->
    mnesia_schema:schema_transaction(
      fun() ->
	      mnesia_schema:do_add_backend_type(fs_copies, ?MODULE),
	      mnesia_schema:do_add_backend_type(raw_fs_copies, ?MODULE)
      end).

sender_init(Alias, Tab, RemoteStorage, Pid) ->
    %% Need to send a message to the receiver. It will be handled in 
    %% receiver_first_message/4 below. There could be a volley of messages...
    {ext, Alias, ?MODULE} = RemoteStorage, % limitation for now
    Pid ! {self(), {first, info(Alias, Tab, size)}},
    MP = data_mountpoint(Tab),
    {fun() ->
	     {ok, Fs} = file:list_dir(MP),
	     FI = fetch_files(Fs, MP),
	     {[{[], FI}], {[F || {F,dir} <- FI], MP, MP,
			   fun() -> '$end_of_table' end}}
     end,
     fun(Cont) ->
	     fetch_more_files(Cont)
     end}.

fetch_files([F|Fs], Dir) ->
    Fn = filename:join(Dir, F),
    case file:read_file(Fn) of
	{error, eisdir} ->
	    [{F, dir}|fetch_files(Fs, Dir)];
	{ok, Bin} ->
	    [{F, Bin}|fetch_files(Fs, Dir)];
	{error, enoent} ->
	    %% ouch!
	    fetch_files(Fs, Dir)
    end;
fetch_files([], _) ->
    [].

fetch_more_files({[], _, _, C}) ->
    C();
fetch_more_files({[F|Fs], Dir, MP, C}) ->
    D = filename:join(Dir, F),
    case file:list_dir(D) of
	{error, enoent} ->
	    io:fwrite("Not found: ~s~n", [D]),
	    fetch_more_files({Fs, Dir, MP, C});
	{ok, Fs1} ->
	    Fs1i = fetch_files(Fs1, D),
	    {[{remove_top(MP, D), Fs1i}], {[Fx || {Fx,dir} <- Fs1i], D, MP,
			   fun() -> fetch_more_files({Fs, Dir, MP, C}) end}}
    end.
				    


receiver_first_message(_Pid, {first, Size}, _Alias, _Tab) ->
    {Size, []}.


receive_data(Data, Alias, Tab) ->
    MP = data_mountpoint(Tab),
    store_data(Data, Alias, Tab, MP).

receive_done(_Alias, _Tab, _Sender) ->
    ok.

store_data([], _, _, _) ->
    ok;
store_data([{Dir, Fs}|T], Alias, Tab, MP) ->
    Dirname = filename:join(MP, Dir),
    case file:list_dir(Dirname) of
	{error, enoent} ->
	    fill_empty(Dirname, Fs);
	{error, enotdir} ->
	    delete_file_or_dir(Dirname),
	    store_data([{Dir, Fs}|T], Alias, Tab, MP);
	{ok, MyFs} ->
	    diff_dirs(MyFs, Fs, Dirname)
    end,
    store_data(T, Alias, Tab, MP).

fill_empty(Dirname, Fs) ->
    file:make_dir(Dirname),
    lists:map(fun({F, dir}) ->
		      file:make_dir(filename:join(Dirname, F));
		 ({F, Bin}) when is_binary(Bin) ->
		      file:write_file(filename:join(Dirname, F), Bin)
	      end, Fs).

diff_dirs(MyFs, Fs, Dirname) ->
    lists:foreach(
      fun(F) ->
	      case lists:keymember(F, 1, Fs) of
		  false ->
		      delete_file_or_dir(filename:join(Dirname,F));
		  true ->
		      ok
	      end
      end, MyFs),
    lists:foreach(
      fun({F,dir}) ->
	      Fname = filename:join(Dirname, F),
	      case file:make_dir(Fname) of
		  {error, eexist} ->
		      case filelib:is_regular(Fname) of
			  true ->
			      file:delete(Fname),
			      file:make_dir(Fname);
			  false ->
			      ok
		      end;
		  ok ->
		      ok
	      end;
	 ({F,Bin}) when is_binary(Bin) ->
	      Fname = filename:join(Dirname, F),
	      case file:write_file(Fname, Bin) of
		  {error, eisdir} ->
		      delete_file_or_dir(Fname),
		      file:write_file(Fname, Bin);
		  ok ->
		      ok
	      end
      end, Fs).


delete_file_or_dir(F) ->
    case file:delete(F) of
	{error, eisdir} ->
	    {ok, Fs} = file:list_dir(F),
	    lists:foreach(fun(F1) ->
				  Fn = filename:join(F, F1),
				  delete_file_or_dir(Fn)
			  end, Fs),
	    ok = file:del_dir(F);
	ok ->
	    ok
    end.


validate_key(Alias, Tab, RecName, Arity, Type, Key) ->
    %% RecName, Arity and Type have already been validated
    try begin
	    _NewKey = do_validate_key(Alias, Tab, Key),
	    {RecName, Arity, Type}
	end
    catch
	error:_ -> mnesia:abort(bad_type, [Tab, Key])
    end.

validate_record(Alias, Tab, RecName, Arity, Type, Obj) ->
    %% RecName, Arity and Type have already been validated
    _Key = do_validate_key(Alias, Tab, element(2, Obj)),
    {RecName, Arity, Type}.

%% For 'fs_copies', we should really use a key encoding scheme that 
%% can handle any type of Erlang data type. The only one I can think of 
%% (which also supports ordered_set semantics) would be sext.erl, which
%% is currently an OSS contrib (http://github.com/esl/sext).
%% To make sext encodings filesystem compatible, some encoding on top would
%% be needed to eliminate illegal characters and '/' - possibly combined
%% with a scheme to break the key into pieces separated by '/'.
%%
do_validate_key(fs_copies, Tab, Key) ->
%%    split_key(sext_encode(Key));
    do_validate_key(raw_fs_copies, Tab, Key);
do_validate_key(raw_fs_copies, Tab, Key) ->
    if is_binary(Key) ->
	    Key;
       is_list(Key) ->
	    list_to_binary(Key);
       is_atom(Key) ->
	    list_to_binary(atom_to_list(Key));
       true ->
	    mnesia:abort({bad_type, [Tab, Key]})
    end.

decode_key(Key) ->
    sext_decode(unsplit_key(Key)).

sext_encode(K) ->
    mnesia_sext:encode_sb32(K).

sext_decode(K) ->
    mnesia_sext:decode_sb32(K).

split_key(<<A,B,C,T/binary>>) ->
    <<A,B,C,$/, (split_key(T))/binary>>;
split_key(Bin) ->
    Bin.

unsplit_key(Bin) ->
    << <<C>> || <<C>> <= Bin,
		C =/= $/ >>.


create_table(_Alias, Tab, _Props) ->
    create_mountpoint(Tab),
    Tab.

delete_table(_Alias, Tab) ->
    MP = get_mountpoint(Tab),
    assert_proper_mountpoint(Tab, MP),
    os:cmd("rm -r " ++ MP).

assert_proper_mountpoint(_Tab, _MP) ->
    %% not yet implemented. How to verify that the MP var points to the 
    %% directory we actually want deleted?
    ok.

prop(K,Props) ->
    proplists:get_value(K, Props).

check_definition(Alias, Tab, Nodes, Props)
  when Alias==fs_copies; Alias==raw_fs_copies->
    Id = {Alias, Nodes},
    [Rc, Dc, DOc] =
        [proplists:get_value(K,Props,[]) || K <- [ram_copies,
						  disc_copies,
						  disc_only_copies]],
    case {Rc,Dc,DOc} of
	{[],[],[]} ->
	    case prop(type, Props) of
                ordered_set -> ok;
		set -> ok;
                Type -> mnesia:abort({combine_error, Tab, [Id, {type, Type}]})
            end,
	    MP = get_mountpoint(Tab),
	    case dir_exists_or_creatable(MP) of
		true ->
		    ok;
		false ->
		    mnesia:abort({bad_mountpoint, Tab, [MP]})
	    end,
	    case {Alias, prop(attributes, Props)} of
		{raw_fs_copies, [_Key, _Value]} ->
		    ok;
		{fs_copies,  _} ->
		    ok;
		Attrs ->
		    mnesia:abort({invalid_attributes, Tab, Attrs})
	    end;
	_ ->
	    X = fun([], _) -> [];
		   ([_|_]=Ns, T) -> [{T, Ns}]
		end,
	    mnesia:abort({combine_error, Tab,
			  [Id |
			   X(ram_copies,Rc) ++ X(disc_copies,Dc) ++
			   X(disc_only_copies,DOc)]})
    end.

%%
info_mountpoint(Tab) ->
    Dir = mnesia_monitor:get_env(dir),
    filename:join(Dir, atom_to_list(Tab) ++ ".extfsi").

data_mountpoint(Tab) ->
    MP = get_mountpoint(Tab),
    filename:join(MP, "data").

%%
get_mountpoint(Tab) ->
    L = mnesia_monitor:get_env(filesystem_locations),
    case lists:keyfind(Tab, 1, L) of
	false ->
	    default_mountpoint(Tab);
	{_, Loc} ->
	    Loc
    end.

default_mountpoint(Tab) ->
    Dir = mnesia_monitor:get_env(dir),
    filename:join(Dir, atom_to_list(Tab) ++ ".extfs").

pos(A, Attrs) ->  pos(A, Attrs, 1).

pos(A, [A|_], P) ->  P;
pos(A, [_|T], P) ->  pos(A, T, P+1);
pos(_, [], _) ->     0.


my_file_info(F) ->
    case file:read_link_info(F) of
	{ok, #file_info{type = symlink}} ->
	    case file:read_link(F) of
		{ok, NewF} ->
		    my_file_info(NewF);
		Other ->
		    Other
	    end;
	Other ->
	    Other
    end.

parent_dir(F) ->
    case filename:split(F) of
	["."] ->
	    parent_dir(filename:absname(F));
	[_] ->
	    F;
	_ ->
	    filename:dirname(F)
    end.

is_writable(D) ->
    case my_file_info(D) of
	{ok, #file_info{type = directory, access = A}}
	  when A == write; A == read_write ->
	    true;
	_ ->
	    false
    end.

dir_exists_or_creatable(Dir) ->
    case my_file_info(Dir) of
	{ok, #file_info{type = directory}} ->
	    true;
	{error, enoent} ->
	    is_writable(parent_dir(Dir));
	_Other ->
	    false
    end.
	    
create_mountpoint(Tab) ->
    file:make_dir(get_mountpoint(Tab)),
    file:make_dir(data_mountpoint(Tab)),
    file:make_dir(info_mountpoint(Tab)).


load_table(Alias, Tab, _LoadReason) ->
    MP = get_mountpoint(Tab),
    create_mountpoint(Tab),
    {ok, _Pid} = 
	mnesia_ext_sup:start_proc(
	  Tab, ?MODULE, start_proc, [Alias, Tab, MP]),
    ok.


fullname(Tab, Key) ->
    MP = data_mountpoint(Tab),
    fullname(Tab, Key, MP).

fullname(_Tab, Key0, MP) ->
    Key = if is_binary(Key0) ->
		  binary_to_list(Key0);
	     is_list(Key0) ->
		  lists:flatten(Key0);
	     is_atom(Key0) ->
		  list_to_binary(atom_to_list(Key0))
	  end,
    filename:join([MP, Key]).


info(_Alias, Tab, Item) ->
    try ets:lookup(tab_name(icache, Tab), {info,Item}) of
	[{_, Value}] ->
	    Value;
	[] ->
	    undefined
    catch
	error:Reason ->
	    {error, Reason}
    end.
	

read_file_info(Tab, Key) ->
    Fname = fullname(Tab, Key),
    Info = #info{tab = Tab,
		 key = Key,
		 fullname = Fname,
		 recname = mnesia:table_info(Tab, record_name)},
    try read_file_info1(Fname, Info, 1)
    catch
	error:Reason ->
	    mnesia:abort({Reason, erlang:get_stacktrace()})
    end.

read_file_info1(Fname, Info, X) when X < 100 ->
    case file:read_link_info(Fname) of
	{ok, #file_info{type = symlink}} ->
	    case file:read_link(Fname) of
		{ok, NewLink} ->
		    read_file_info1(NewLink, X+1, Info);
		Error ->
		    mnesia:abort({Error, Info})
	    end;
	{ok, #file_info{} = FI} ->
	    Attrs = tl(tuple_to_list(FI)),
	    Read = fun() ->
			   {ok, Bin} = file:read_file(Fname),
			   Bin
		   end,
	    Tup = list_to_tuple([Fname, Info#info.key, data | Attrs]),
	    {_, Map} = mnesia:read_table_property(
			 Info#info.tab, rofs_attr_map),
	    Rec = list_to_tuple([Info#info.recname |
				 lists:map(
				   fun(3) ->
					   Read();  % fetch the data
				      (P) ->
					   element(P, Tup)
				   end, Map)]),
	    [Rec];	    
	{error, enoent} ->
	    []
    end.

lookup(Alias, Tab, Key0) ->
    Key = do_validate_key(fs_copies, Tab, Key0),
    lookup(Alias, Tab, Key0, fullname(Tab, Key)).

lookup(fs_copies, _Tab, Key, Fullname) ->
    case file:read_file(Fullname) of
	{ok, Bin} ->
	    [setelement(2, binary_to_term(Bin), Key)];
	{error, _} ->
	    []
    end;
lookup(raw_fs_copies, Tab, Key, Fullname) ->
    Tag = mnesia_lib:val({Tab, record_name}),
    case file:read_file(Fullname) of
	{ok, Bin} ->
	    [{Tag, Key, Bin}];
	{error, enoent} ->
	    []
    end.

insert(Alias, Tab, Obj) ->
    call(Alias, Tab, {insert, Obj}).

%% do_insert/4 -> boolean()
%% server-side end of insert/3.
%% Returns true: new object was added; false: existing object was updated
%%
do_insert(Alias, Tab, Obj, MP) ->
    Key = do_validate_key(Alias, Tab, element(2, Obj)),
    Fullname = fullname(Tab, Key, MP),
    ok = filelib:ensure_dir(Fullname),
    Added = case file:read_file_info(Fullname) of
		{error, enoent} ->
		    true;
		{ok, _} ->
		    false
	    end,
    ok = write_object(Alias, Fullname, Obj),
    Added.

write_object(fs_copies, Fullname, Obj) ->
    file:write_file(Fullname, term_to_binary(Obj, [compressed]));
write_object(raw_fs_copies, Fullname, {_, _K, V}) ->
    file:write_file(Fullname, iolist_to_binary([V])).

match_object(Alias, Tab, Pat) ->
    select(Alias, Tab, [{Pat,[],['$_']}]).

select(Alias, Tab, Ms) ->
    MP = data_mountpoint(Tab),
    {Res, Cont} = do_select(Alias, Tab, MP, Ms, infinity),
    '$end_of_table' = Cont(),
    Res.


select(Alias, Tab, Ms, Limit) when is_integer(Limit) ->
    MP = data_mountpoint(Tab),
    do_select(Alias, Tab, MP, Ms, Limit).

remove_first_slash("/" ++ Str) ->
    Str;
remove_first_slash(Str) ->
    Str.

keypat_to_match(Str) ->
    keypat_to_match(Str, [], []).

keypat_to_match("/" ++ Str, DirAcc, Dirs) ->
    keypat_to_match(Str, [], [lists:reverse(DirAcc)|Dirs]);
keypat_to_match("." ++ T, DirAcc, Dirs) ->
    keypat_to_match(T, ".\\" ++ DirAcc, Dirs);
keypat_to_match([H|T], DirAcc, Dirs) when is_integer(H) ->
    keypat_to_match(T, [H|DirAcc], Dirs);
keypat_to_match([H|T], DirAcc, Dirs) when is_atom(H) ->
    keypat_to_match(T, "." ++ DirAcc, Dirs);
keypat_to_match('_', DirAcc, Dirs) ->
    {open, lists:reverse(Dirs), lists:reverse("*." ++ DirAcc)};
keypat_to_match([], DirAcc, Dirs) ->
    {closed, lists:reverse(Dirs), lists:reverse(DirAcc)}.


repair_continuation(Cont, _Ms) ->
    Cont.

select(Cont) when is_function(Cont, 0) ->
    case erlang:fun_info(Cont, module_name) of
	?MODULE ->
	    Cont();
	_ ->
	    erlang:error(badarg)
    end.

fixtable(_Alias, _Tab, _Bool) ->
    true.


delete(Alias, Tab, Key) ->
    call(Alias, Tab, {delete, Key}).

do_delete(Alias, Tab, Key, MP) ->
    Fullname = fullname(Tab, do_validate_key(Alias, Tab, Key), MP),
    Deleted = case file:read_file_info(Fullname) of
		  {error, enoent} ->
		      false;
		  {ok, _} ->
		      true
	      end,
    ok = file:delete(Fullname),
    Deleted.

match_delete(_Alias, _Tab, _Pat) ->
    erlang:error({not_allowed, [{?MODULE,match_erase,[_Tab, _Pat]}]}).


first(_Alias, Tab) ->
    MP = data_mountpoint(Tab),
    Type = mnesia:table_info(Tab, type),
    case list_dir(MP, Type) of
	{ok, Fs} ->
	    case do_next1(Fs, MP, Type) of
		'$end_of_table' ->
		    '$end_of_table';
		F ->
		    remove_top(MP, F)
	    end;
	_ ->
	    '$end_of_table'
    end.

last(_Alias, Tab) ->
    MP = data_mountpoint(Tab),
    Type = mnesia:table_info(Tab, type),
    case list_dir(MP, Type) of
	{ok, Fs} ->
	    case do_prev1(lists:reverse(Fs), MP, Type) of
		'$end_of_table' ->
		    '$end_of_table';
		F ->
		    remove_top(MP, F)
	    end;
	_ ->
	    '$end_of_table'
    end.

prev(_Alias, Tab, Key) ->
    MP = data_mountpoint(Tab),
    Fullname = fullname(Tab, Key, MP),
    Type = mnesia:table_info(Tab, type),
    case do_prev(Fullname, Type) of
	'$end_of_table' ->
	    '$end_of_table';
	F ->
	    remove_top(MP, F)
    end.


next(_Alias, Tab, Key) ->
    MP = data_mountpoint(Tab),
    Fullname = fullname(Tab, Key, MP),
    Type = mnesia:table_info(Tab, type),
    case do_next(Fullname, Type) of
	'$end_of_table' ->
	    '$end_of_table';
	F ->
	    remove_top(MP, F)
    end.

do_prev(Fullname, Type) ->
    {Dir, Base} = get_parent(Fullname),
    case list_dir(Dir, Type) of
	{ok, Fs} ->
	    case my_lists_split(Base, Fs, rev_type(Type)) of
		{_, []} ->
		    '$end_of_table';
		{_, L} ->
		    do_prev1(L, Dir, Type)
	    end;
	_ ->
	    %% empty, or deleted
	    '$end_of_table'
    end.

do_next(Fullname, Type) ->
    {Dir, Base} = get_parent(Fullname),
    case list_dir(Dir, Type) of
	{ok, Fs} ->
	    case my_lists_split(Base, Fs, Type) of
		{_, []} ->
		    '$end_of_table';
		{_, L} ->
		    do_next1(L, Dir, Type)
	    end;
	_ ->
	    %% empty, or deleted
	    '$end_of_table'
    end.

do_next1([H|T], Dir, Type) ->
    File = filename:join(Dir, H),
    case list_dir(File, Type) of
	{ok, Fs} ->
	    case do_next1(Fs, File, Type) of
		'$end_of_table' ->
		    do_next1(T, Dir, Type);
		Found ->
		    Found
	    end;
	{error, enotdir} ->
	    File
    end;
do_next1([], _, _) ->
    '$end_of_table'.

do_prev1([H|T], Dir, Type) ->
    File = filename:join(Dir, H),
    case list_dir(File, Type) of
	{ok, Fs} ->
	    case do_prev1(lists:reverse(Fs), File, Type) of
		'$end_of_table' ->
		    do_prev1(T, Dir, Type);
		Found ->
		    Found
	    end;
	{error, enotdir} ->
	    File
    end;
do_prev1([], _, _) ->
    '$end_of_table'.

		    %% Either prev was the last in the list, or has been 
		    %% deleted
    %% F = fun(keypat, File) ->
    %% 		lists:prefix(File, Fullname) orelse File > Fullname;
    %% 	   (key, File) ->
    %% 		case File > Fullname of
    %% 		    true ->
    %% 			[File];
    %% 		    false ->
    %% 			[]
    %% 		end;
    %% 	   (data, Objs) ->
    %% 		Objs
    %% 	   end,
    %% do_select(Alias, Tab, MP, F, 2).

get_parent(F) ->
    Dir = filename:dirname(F),
    Base = filename:basename(F),
    {Dir, Base}.

rev_type(ordered_set) -> reverse_order;
rev_type(T)           -> T.

my_lists_split(X, L, ordered_set) ->
    ordered_split(X, L, []);
my_lists_split(X, L, reverse_order) ->
    rev_ordered_split(X, lists:reverse(L), []);
my_lists_split(X, L, _) ->
    unordered_split(X, L, []).

ordered_split(X, [H|T], Acc) when X >= H ->
    ordered_split(X, T, [H|Acc]);
ordered_split(_X, L, Acc) ->
    {Acc, L}.

rev_ordered_split(X, [H|T], Acc) when X =< H ->
    rev_ordered_split(X, T, [H|Acc]);
rev_ordered_split(_X, L, Acc) ->
    {Acc, L}.

unordered_split(X, [X|T], Acc) ->
    {Acc, T};
unordered_split(X, [H|T], Acc) ->
    unordered_split(X, T, [H|Acc]);
unordered_split(_X, [], Acc) ->
    {Acc, []}.

pick_with(F, [H|T]) ->
    case F(H) of
	true  -> {value, H};
	false -> pick_with(F, T)
    end;
pick_with(_, []) ->
    false.



slot(_Alias, _Tab, _Pos) ->
    ok.

update_counter(_Alias, _Tab, _C, _Val) ->
    ok.

clear_table(_Alias, _Tab) ->
    ok.

fold(Alias, Tab, Fun, Acc, N) ->
    fold(select(Alias, Tab, [{'_',[],['$_']}], N), Fun, Acc).

fold('$end_of_table', _, Acc) ->
    Acc;
fold({L, Cont}, Fun, Acc) ->
    fold(select(Cont), Fun, lists:foldl(Fun, Acc, L)).

is_key_prefix(File, Fun) when is_function(Fun) ->
    Fun(File);
is_key_prefix(File, Pat) ->
    is_key_prefix1(File, Pat).

is_key_prefix1([], _) ->
    true;
is_key_prefix1([H|T], [H|T1]) ->
    is_key_prefix1(T, T1);
is_key_prefix1([_|_], L) when is_list(L) ->
    false;
is_key_prefix1(_, '_') ->
    true;
is_key_prefix1(_, V) ->
    is_dollar_var(V).

is_dollar_var(P) when is_atom(P) ->
    case atom_to_list(P) of
	"\$" ++ T ->
	    try begin _ = list_to_integer(T),
		      true
		end
	    catch
		error:_ ->
		    false
	    end;
	_ ->
	    false
    end;
is_dollar_var(_) ->
    false.

keypat(_Dir, F) when is_function(F) ->
    fun(File) -> F(keypat, File) end;
keypat(Dir, [{HeadPat,_,_}|_]) when is_tuple(HeadPat) ->
    case element(2, HeadPat) of
	L when is_list(L) ->
	    Dir ++ [$/|L];
	_ ->
	    '_'
    end;
keypat(_, _) ->
    '_'.


do_select(Alias, Tab, Dir, MS, Limit) ->
    MP = remove_ending_slash(Dir),
    Type = mnesia:table_info(Tab, type),
    RecName = mnesia:table_info(Tab, record_name),
    Sel = #sel{alias = Alias,
	       tab = Tab,
	       type = Type,
	       mp = MP,
	       keypat = keypat(MP, MS),
	       recname = RecName,
	       ms = MS,
	       limit = Limit},
    do_fold_dir(Dir, Sel, [], Limit).

remove_ending_slash(D) ->
    case lists:reverse(D) of
	"/" ++ Dr ->
	    lists:reverse(Dr);
	_ ->
	    D
    end.

do_fold_dir(Dir, Sel, Acc, N) ->
    {ok,Fs} = list_dir(Dir, Sel#sel.type),
    do_fold(Fs, Dir, Sel, Acc, N,
	    fun(Acc1, _) ->
		    {lists:reverse(Acc1), fun() -> '$end_of_table' end}
	    end).

do_fold([], _, _, Acc, N, C) ->
    C(Acc, N);
do_fold(Fs, Dir, #sel{limit = Lim} = Sel, Acc, 0, C) ->
    {lists:reverse(Acc), fun() ->
		  io:fwrite("Continuation fires...~n", []),
	  do_fold(Fs, Dir, Sel, [], Lim, C)
	  end};
do_fold([F|Fs], Dir, #sel{keypat = KeyPat} = Sel, Acc, N, C) ->
    Filename = filename:join(Dir, F),
    case is_key_prefix(Filename, KeyPat) of
	true ->
	    follow_file(Filename, Fs, Dir, Sel, Acc, N, C);
	false ->
	    do_fold(Fs, Dir, Sel, Acc, N, C)
    end.

follow_file(Filename, Fs, Dir, Sel, Acc, N, C) ->
    case list_dir(Filename, Sel#sel.type) of
	{ok, Fs1} ->
	    C1 = fun(Acc1, N1) ->
			 io:fwrite("back from ~p~n", [Filename]),
			 do_fold(Fs, Filename, Sel, Acc1, N1, C)
		 end,
	    do_fold(Fs1, Filename, Sel, Acc, N, C1);
	{error, enotdir} ->
	    case match_file(Filename, Sel) of
		{match, Result} ->
		    do_fold(Fs, Dir, Sel, [Result|Acc], decr(N), C);
		nomatch ->
		    do_fold(Fs, Dir, Sel, Acc, N, C)
	    end
    end.

list_dir(Dir, Type) ->
    case {file:list_dir(Dir), Type} of
	{{ok, Fs}, ordered_set} ->
	    {ok, lists:sort(Fs)};
	{Other, _} ->
	    Other
    end.

match_file(Filename, #sel{ms = F, mp = MP, alias = Alias,
			 recname = RecName}) when is_function(F) ->
    case F(key, Filename) of
	[] ->
	    nomatch;
	[_] ->
	    RelFilename = remove_top(MP, Filename),
	    Read = read_obj(Alias, RecName, Filename, RelFilename),
	    case F(data, Read) of
		[] ->
		    nomatch;
		[Res] ->
		    {match, Res}
	    end
    end;
match_file(Filename, #sel{mp = MP, keypat = KeyPat, ms = MS,
			  alias = Alias, recname = RecName}) ->
    case match_spec_run([Filename], [{KeyPat,[],[true]}]) of
	[] ->
	    nomatch;
	[_] ->
	    RelFilename = remove_top(MP, Filename),
	    Read = read_obj(Alias, RecName, Filename, RelFilename),
	    case match_spec_run(Read, MS) of
		[] ->
		    nomatch;
		[Res] ->
		    {match, Res}
	    end
    end.

match_spec_run(L, MS) ->
    Compiled = ets:match_spec_compile(MS),
    ets:match_spec_run(L, Compiled).

remove_top([H|T],[H|T1]) ->
    remove_top(T, T1);
remove_top([], "/" ++ T) ->
    remove_top([], T);
remove_top([], T) ->
    T.

	    
read_obj(Alias, RecName, Filename, RelName) ->
    case file:read_file(Filename) of
	{ok, Binary} ->
	    case Alias of
		raw_fs_copies ->
		    [{RecName, RelName, Binary}];
		fs_copies ->
		    [binary_to_term(Binary)]
	    end;
	_ ->
	    []
    end.

decr(I) when is_integer(I), I > 0 ->
    I - 1;
decr(I) ->
    I.


%% ==============================================================
%% gen_server part
%% ==============================================================

start_proc(Alias, Tab, MP) ->
    gen_server:start_link({local, mk_proc_name(Alias, Tab)}, ?MODULE,
			  {Alias, Tab, MP}, []).

call(Alias, Tab, Req) ->
    case gen_server:call(proc_name(Alias, Tab), Req, infinity) of
	badarg ->
	    mnesia:abort(badarg);
	Reply ->
	    Reply
    end.

init({Alias, Tab, MP}) ->
    {ok, Dets} = open_dets(Alias, Tab, MP),
    mnesia_lib:set({Tab, mountpoint}, MP),
    Ets = ets:new(mk_tab_name(icache,Tab), [set, protected, named_table]),
    dets:to_ets(Dets, Ets),
    {ok, #st{ets = Ets,
	     dets = Dets,
	     mp = MP,
	     data_mp = filename:join(MP, "data"),
	     alias = Alias,
	     tab = Tab}}.

open_dets(_Alias, Tab, _MP) ->
    Dir = info_mountpoint(Tab),
    %% Name = list_to_atom("mnesia_ext_info_" ++ atom_to_list(Tab)),
    Name = mk_tab_name(info, Tab),
    Args = [{file, filename:join([Dir, "info.DAT"])},
	    {keypos, 1},
	    {repair, mnesia_monitor:get_env(auto_repair)},
	    {type, set}],
    mnesia_monitor:open_dets(Name, Args).

handle_call({info, Item}, _From, #st{ets = Ets} = St) ->
    Result = case ets:lookup(Ets, {info, Item}) of
		 [{_, Value}] ->
		     Value;
		 [] ->
		     default_info(Item)
	     end,
    {reply, Result, St};
handle_call({insert, Obj}, _From, #st{data_mp = MP,
				      alias = Alias, tab = Tab} = St) ->
    case do_insert(Alias, Tab, Obj, MP) of
	true ->
	    incr_size(St, 1);
	false ->
	    ignore
    end,
    {reply, ok, St};
handle_call({delete, Key}, _From, #st{data_mp = MP,
				      alias = Alias, tab = Tab} = St) ->
    case do_delete(Alias, Tab, Key, MP) of
	true ->
	    incr_size(St, -1);
	false ->
	    ignore
    end,
    {reply, ok, St}.

handle_cast(_, St) ->
    {noreply, St}.

handle_info(_, St) ->
    {noreply, St}.

code_change(_FromVsn, St, _Extra) ->
    {ok, St}.

terminate(_Reason, _St) ->
    ok.

default_info(size) -> 0;
default_info(_) -> undefined.
    

incr_size(#st{ets = Ets} = St, Incr) ->
    case ets:lookup(Ets, {info,size}) of
	[] ->
	    write_info(size, Incr, St);
	[{_, Val}] ->
	    write_info(size, Val + Incr, St)
    end.

write_info(Item, Value, #st{ets = Ets, dets = Dets}) ->
    % Order matters. First write to disk
    ok = dets:insert(Dets, {{info,Item}, Value}),
    ets:insert(Ets, {{info,Item}, Value}).

tab_name(icache, Tab) ->
    list_to_existing_atom("mnesia_ext_icache_" ++ atom_to_list(Tab));
tab_name(info, Tab) ->
    list_to_existing_atom("mnesia_ext_info_" ++ atom_to_list(Tab)).

mk_tab_name(icache, Tab) ->
    list_to_atom("mnesia_ext_icache_" ++ atom_to_list(Tab));
mk_tab_name(info, Tab) ->
    list_to_atom("mnesia_ext_info_" ++ atom_to_list(Tab)).

proc_name(_Alias, Tab) ->
    list_to_existing_atom("mnesia_ext_proc_" ++ atom_to_list(Tab)).

mk_proc_name(_Alias, Tab) ->
    list_to_atom("mnesia_ext_proc_" ++ atom_to_list(Tab)).

