-module(database).
-export([init/0,insert_hypebeast/2,select_hypebeast/1,delete_row/2,select_all/1,insert_highsnobiety/2,select_highsnobiety/1,clear_all/0]).

-record(hypebeast,{title, time}).
-record(highsnobiety,{title,time}).
-include_lib("stdlib/include/qlc.hrl").


%create and init the databases.
init()->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(hypebeast,[]),
    mnesia:create_table(highsnobiety,[]).
 %   mnesia:clear_table(hypebeast),
 %   mnesia:clear_table(highsnobiety).


%insert headline and discovery time to hypebeast table.
insert_hypebeast(Title,Time) ->
    Fun = fun() ->
		  mnesia:write(#hypebeast{title=Title,time=Time})
	  end,
    mnesia:transaction(Fun).

%insert headline and publish time to highsnobiety table.
insert_highsnobiety(Title,Time) ->
    Fun = fun() ->
		  mnesia:write(#highsnobiety{title=Title,time=Time})
	  end,
    mnesia:transaction(Fun).

%select headline and discovery time from hypebeast table.
select_hypebeast(Title) ->
    Fun = fun() ->
		  mnesia:read(hypebeast,Title)
	  end,
    {atomic, [Row]}=mnesia:transaction(Fun),
    io:format("Hypebeast Headline:~p~n",[Row#hypebeast.title]),
    io:format("Discovery Time:~p~n",[Row#hypebeast.time]).

%select headline and publish time from highsnobiety table.
select_highsnobiety(Title) ->
    Fun = fun() ->
		  mnesia:read(highsnobiety,Title)
	  end,
    {atomic, [Row]}=mnesia:transaction(Fun),
    io:format("Highsnobiety Headline:~p~n",[Row#highsnobiety.title]),
    io:format("Publish Time:~p~n",[Row#highsnobiety.time]).

%select all the headline from specific table.
select_all(Table) -> 
    Fun = fun()->
		  mnesia:all_keys(Table)
	  end,
    {atomic,List} =  mnesia:transaction(Fun),
    List.
%   io:format("~p~n",[List]).
    
%delect specific headline and time in the table.(Not used, just for test).    
delete_row(Table, Key)->
    Fun = fun()->
		  mnesia:delete({Table, Key})
	  end,
    mnesia:transaction(Fun).

%clear all the data in both table.
clear_all() ->
     mnesia:clear_table(hypebeast),
     mnesia:clear_table(highsnobiety).
