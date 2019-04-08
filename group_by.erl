%%%-------------------------------------------------------------------
%%% @author John Smith
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Апр. 2019 9:23
%%%-------------------------------------------------------------------
-module(group_by).
-author("John Smith").

%% API
-export([init/0, init3/0, init_fun/0, group_by_gender/1, group_by_some/2]).

init()->
  [
    {user, "Bob", 21, male},
    {user, "Bill", 23, male},
    {user, "Helen", 17, female},
    {user, "Kate", 25, female},
    {user, "John", 20, male}
  ].


% имеем список пользователей, надо создать словарь разбитый по полу, сначало
% второе задание - генерацие ключей, по которым будет происходить группировка стека
%%grouping

group_by_gender(Users)->
  F = fun({user, Name, Age, Gender}, AccM) ->
    GenderM=maps:get(Gender, AccM),
    maps:update(Gender, [{user, Name, Age, Gender}|GenderM], AccM) end,
  lists:foldl(F, #{male=>[], female=>[]}, Users).

%% Третий пример:
%% У нас есть распределенная система, кластер из нескольких узлов.
%% В этой системе есть клиентские соединения разных типов, подключенные к разным узлам:
init3()->
  [
    {session, type_a, node_1, socketId1},
    {session, type_b, node_1, socketId2},
    {session, type_a, node_2, socketId3},
    {session, type_b, node_2, socketId4}
  ].
%% Мы хотим сгруппировать эти сессии по узлу:
%%#{
%%node_1 => [{session, type_a, node_1, SocketId1}, {session, type_a, node_2, SocketId3}],
%%node_2 => [{session, type_a, node_2, SocketId3}, {session, type_b, node_2, SocketId4}]
%%}.
%% А потом мы хотим сгруппировать их по типу:
%%#{
%%type_a => [{session, type_a, node_1, SocketId1}, {session, type_a, node_2, SocketId3}],
%%type_b => [{session, type_b, node_1, SocketId2}, {session, type_b, node_2, SocketId4}]
%%}
%% И во всех случаях мы применяем одну и ту же функцию group_by,
%% передавая ей разные CriteriaFun и разные списки.

init_fun()->
%% Функции для CriteriaFun
  F1 = fun({user, _, Age,_})  when Age=<12 -> child;
    ({user, _, Age,_})when Age>12 andalso Age=< 18 -> teenager;
  ({user, _, Age,_})when Age>18 andalso Age=< 25 -> young;
  ({user, _, Age,_}) when Age>25 andalso Age=< 60 -> adult;
    ({user, _, Age,_})when Age>60 -> old end,
  F2 = fun ({session, type_a, _,_})-> type_a;({session, type_b, _,_})-> type_b end,
  F3 = fun ({session, _, node_1,_})-> node_1;({session, _, node_2,_})-> node_2 end,
  [F1, F2, F3].



group_by_some(List, CriteriaFun)->
  F = fun (El, Dict) ->
          Temp = CriteriaFun(El),
              case maps:find(Temp, Dict) of
                  {ok, List1} -> maps:update(Temp, [El|List1], Dict);
                  error-> maps:put(Temp, [El], Dict)
              end
      end,
  lists:foldl(F,#{}, List).
