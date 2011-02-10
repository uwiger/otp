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
     {check_definition, 4},  % (TypeAlias, Tab, Nodes, Properties)
     {create_table, 1},
     {delete_table, 1},
     {is_ram_only, 1},
     {load_table, 5},
     {table_info, 2},
     %% -- accessor callbacks: see corresponding functions in mnesia_lib.erl
     {db_chunk, 1},
     {db_erase, 2},
     {db_erase_tab, 1},
     {db_first, 1},
     {db_get, 2},
     {db_init_chunk, 2},
     {db_first, 1},
     {db_last, 1},
     {db_next_key, 2},
     {db_prev_key, 2},
     {db_put, 2},
     {db_slot, 2},
     {db_update_counter, 3},
     {match_erase, 2},
     {match_object, 2},
     {repair_continuation, 2},
     {safe_fixtable, 2},
     {select, 1},
     {select, 2},
     {select_init, 3}
    ].
