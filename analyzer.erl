-module(analyzer).
-export([compare_headline/2]).


%compare two headline by counting the number of bytes.
compare_headline(Title,[])  ->
    %   io:format("no more matching headline found~n",[]);
        [];


compare_headline(Title,[Head|Tail])  ->
      Len  = string:len (Title -- Head),
      if Len =< 5 ->
              database:select_highsnobiety(Title),
	      database:select_hypebeast(Head),
              compare_headline(Title,Tail);
         Len  > 5 ->
	      compare_headline(Title,Tail)
			    end.
			

  

    
