-module(guess).
-export([start/0, start/1, asker/1, guesser/3]).

asker(Number) ->
    io:format("ASKER: Guess my number!~n"),
    guesser ! {none},
    asker(Number, 1).
    
asker(Number, Tries) ->
    receive 
        give_up ->
            io:format("ASKER: OK, you give up, the number was ~w~n", [Number]);
        N ->
            if 
                N == Number -> 
                    io:format("ASKER: Congratulations! You have guessed a number ~w in ~w tries!~n", [Number, Tries]),
                    guesser ! win;
                N < Number ->
                    io:format("ASKER: Nope, my number is greater than ~w~n", [N]),
                    guesser ! {greater},
                    asker(Number, Tries+1);
                N > Number ->
                    io:format("ASKER: Nope, my number is lesser than ~w~n", [N]),
                    guesser ! {lesser},
                    asker(Number, Tries+1)
            end
    end.

guesser(N, Numbers, {H, M, S}) ->
    random:seed(H div 13, M div 13, S div 13),
    guesser(N, Numbers).
    
    
guesser(N, Numbers) ->
    receive
        win ->
            io:format("GUESSER: I win!~n", []);
        {Hint} ->
            if 
                N == 0 ->
                    io:format("GUESSER: I have no tries left, i give up~n", []),
                    asker ! give_up;
                true ->
                    Number = randomize(Numbers),
                    io:format("GUESSER: I've already tried: ~w, I have ~w tries left~n", [Numbers, N]),
                    case length(Numbers) of
                        0 -> empty;
                        _ -> io:format("GUESSER: I know your number is ~w than ~w~n", [Hint, lists:last(Numbers)] )
                    end,
                    io:format("GUESSER: Your number is ~w~n", [Number]),
                    asker ! Number,
                    guesser(N-1, Numbers ++ [Number])
            end
    end.


     
randomize(Numbers) ->
    N = random:uniform(10),
    case lists:member(N, Numbers) of
      true -> randomize(Numbers);
      false -> N
    end.

start() ->
  start(5).

start(Tries) ->
    {H, M, S} = erlang:now(),
    random:seed(H, M, S),
    Number = random:uniform(10),
    io:format("The number is ~w~n", [Number]),
    register(guesser, spawn(guess, guesser, [Tries, [], {H, M, S}]) ),
    register(asker, spawn(guess, asker, [Number]) ).
    