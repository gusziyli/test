-module(client).
-export([run/0,start/0,loop/0]).




% compile this function to run the system, it will automaticly off in 24hrs.
run ()->
    database:init(),
    Pid = spawn(client,loop,[]),
    timer:send_interval(timer:minutes(1),Pid,tick),
    timer:exit_after(timer:hours(24),Pid,"Timeout").


% the process of the system.
start() ->

    Body = parser:page_info("http://hypebeast.com/style"),
    parser:parse_hypebeast(Body),
    Body1 = parser:page_info("http://www.highsnobiety.com/category/fashion/"),
    parser:parse_highsnobiety(Body1).
    

 
% loop for the the whole process.  
loop() ->
    receive
      _Msg ->
	%  From!{self(),Msg},
          start(),
          loop();
      shutdown ->
            true
    end.
