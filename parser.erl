-module(parser).
-export([start/0,page_info/1,parse_keyword/3,parse_hypebeast/1,parse_highsnobiety/1,parse_time/1]).


% this fuction is just for unit test.
start() ->
  
  
 % io:format("~s~n",[Body]),
   % ItemIndex = string:str(Body,"<h2 class=") +18,
   % EndItemIndex = string:str(Body, "</h2>"),
   % Item = string:substr(Body, ItemIndex, EndItemIndex - ItemIndex),
   % io:format("~s~n",[Item]).
  Body = page_info("http://hypebeast.com/news"),
  parse_hypebeast(Body),
  Body1 = page_info("http://www.highsnobiety.com/category/fashion/"),
  parse_highsnobiety(Body1).
    

%access to the html page and the body.
page_info (URL) ->
    inets:start(),
    case httpc:request(URL) of
     {ok,{_,Headers,Body}} ->
         case lists:keysearch("content-encoding", 1, Headers) of
       {value, {_Key, Value}} when Value =:= "gzip" ->
		 binary:bin_to_list(zlib:gunzip(Body));
	   _ -> Body
          end;
     {error,Reason} -> 
            {error,Reason}
    end.


%Loop for extract the headline by specific keyword and create discovery time, then insert the data to database.
parse_hypebeast(Body)->
    Keyword = "<h2 class=\"title\">",
    KeywordEnd = "</h2>",
    {Title,Rest} = parse_keyword(Body,Keyword,KeywordEnd),
    if
    Title /= 0 ->
            {_Data,{HourInt,MinuteInt,_Second}} =  calendar:local_time(),
            Hour = integer_to_list(HourInt),
	    Minute = integer_to_list(MinuteInt),
            if
		MinuteInt < 10   ->  SystemTime = Hour ++ ":" ++"0"++Minute;
                MinuteInt >= 10  ->  SystemTime = Hour ++ ":"++Minute
            end,
	    database:insert_hypebeast(Title,SystemTime),
           % io:format("~s~n",[Title]),
	    parse_hypebeast(Rest);
    Title == 0  ->
   % io:format("~s~n",["Done"])
        []
        end.

%Loop for extract the headline and publish time by specific keyword, then insert the data to database. && It also implement the compare process after got the headline.
parse_highsnobiety(Body)->
     Keyword = "class=\"article-headline\">",
     KeywordEnd = "</a></h2>",
    {Title,Rest} = parse_keyword(Body,Keyword,KeywordEnd),    
    if
    Title /= 0 ->
            PublishTime = parse_time(Body),
            database:insert_highsnobiety(Title,PublishTime),
            List = database:select_all(hypebeast),
            analyzer:compare_headline(Title,List),            
	    parse_highsnobiety(Rest);
    Title == 0  ->
    io:format("~s~n",["Done"])
        end.

% not used, just for test. extract the word of headline.
analysis_title(Title) ->
    NewTitle = re:replace(Title,"&#8221;","",[{return,list}]),
    re:replace(NewTitle,"&#8220;","",[{return,list}]).
    

   


%extract the first headline from the body.
parse_keyword(Body,Keyword,KeywordEnd) ->
     TitleIndex = string:str(Body,Keyword) ,
     if 
     TitleIndex == 0 ->
     {0,Body};
     true  ->
     EndTitleIndex = string:str(Body,KeywordEnd),
     Title = string:substr(Body, TitleIndex+string:len(Keyword), EndTitleIndex - TitleIndex - string:len(Keyword)),
     Rest = string:substr(Body, EndTitleIndex+4),
     {Title,Rest}
     end.


parse_time(Body) ->
    Keyword = "<span class=\"human-time\">\n\t\t\t\t\t\t\t",
    TimeIndex =string:str(Body,Keyword),
    if
    TimeIndex ==0 ->
	    {0,Body};
      true	  ->
	    Time = string:substr(Body,TimeIndex + string:len(Keyword),7),
        Time
     end.


    
