
-module(tcp_echo).  

-export([listen/0]).

-define(TCP_OPTIONS, [binary, {active, false}, {reuseaddr, true}]).
-define(PORT, 8080).


  %% Eshell V5.8.4  (abort with ^G)
  %% 1> c(tcp_echo).
  %% {ok,test}
  %% 2> tcp_echo:listen().
  %% <0.39.0>
  %% 3> {ok, Sock} = gen_tcp:connect("localhost", 8080, [binary, {packet, 0}]).
  %% Accept on socket #Port<0.2184>,
  %%  new socket #Port<0.2187>Bind sock #Port<0.2187> to process <0.43.0>{ok,#Port<0.2186>}
  %% Wait before process run
  %% Process ran,
  %%  set sock options 
  %% 4> gen_tcp:send(Sock, <<"Some Data">>).
  %% Message received: {tcp,#Port<0.2187>,<<"Some Data">>}
  %% ok
  %% 5> 


listen() ->
    {ok, LSocket} = gen_tcp:listen(?PORT, ?TCP_OPTIONS),
        spawn(fun() ->
                       tcpAcceptor(LSocket) end).


tcpAcceptor (ListeningSocket) ->
    case gen_tcp:accept (ListeningSocket) of
        {ok, Sock} ->
            io:format ("Accept on socket ~p, new socket ~p~n",   [ListeningSocket, Sock]),
            Pid = spawn (fun () ->
                                 receive permission ->
                                         io:format ("Process ran, set sock options ~n", []),
                                         inet:setopts (Sock, [
                                                              binary,
                                                              {active, true}])
                                 after 60000 -> timeout
                                 end,
                                 tcpReader()
                         end),
            io:format ("Bind sock ~p to process ~p~n", [Sock, Pid]),
            gen_tcp:controlling_process (Sock, Pid),
            io:format ("Wait before process run~n",   []),
            Pid ! permission,
            tcpAcceptor (ListeningSocket);
        {error, econnaborted} ->
            tcpAcceptor (ListeningSocket);
        {error, closed} -> finished;
        Msg ->
            error_logger:error_msg ("Acceptor died: ~p~n", [Msg]),
            gen_tcp:close (ListeningSocket)
    end.


tcpReader () ->
    receive
        Msg -> io:format ("Message received: ~p~n",   [Msg])
    after 50000 ->
            io:format ("Timeout~n",   [])
    end.



