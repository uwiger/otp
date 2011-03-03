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
%% Behaviour definition for mnesia backend types.
%%

-module(mnesia_backend_type).

-export([behaviour_info/1]).

%% Note that mnesia considers all callbacks mandatory!!
%%
behaviour_info(callbacks) ->
    [
     {check_definition, 4},    % (TypeAlias, Tab, Nodes, Properties)
     {clear_table, 2},         % (TypeAlias, Tab)
     {create_table, 3},        % (TypeAlias, Tab, Properties)
     {delete, 3},              % (TypeAlias, Tab, Key)
     {delete_table, 2},        % (TypeAlias, Tab)
     {first, 2},               % (TypeAlias, Tab)
     {fixtable, 3},            % (TypeAlias, Tab, Bool)
     {info, 3},                % (TypeAlias, Tab, Item)
     {insert, 3},              % (TypeAlias, Tab, Object)
     {last, 2},                % (TypeAlias, Tab)
     {load_table, 3},          % (TypeAlias, Tab, Reason)
     {lookup, 3},              % (TypeAlias, Tab, Key)
     {match_delete, 3},        % (TypeAlias, Tab, Pattern)
     {match_object, 3},        % (TypeAlias, Tab, Pattern)
     {next, 3},                % (TypeAlias, Tab, Key)
     {prev, 3},                % (TypeAlias, Tab, Key)
     {repair_continuation, 2}, % (Continuation, MatchSpec)
     {select, 1},              % (Continuation)
     {select, 3},              % (TypeAlias, Tab, Pattern)
     {select, 4},              % (TypeAlias, Tab, MatchSpec, Limit)
     {slot, 3},                % (TypeAlias, Tab, Pos)
     {update_counter, 4},      % (TypeAlias, Tab, Counter, Val)
     {validate_key, 6},        % (TypeAlias, Tab, RecName, Arity, Type, Key)
     {validate_record, 6}      % (TypeAlias, Tab, RecName, Arity, Type, Obj)
    ].
