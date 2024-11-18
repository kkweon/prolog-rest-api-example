:- initialization(main, main).
:- use_module(library(http/http_dispatch), [
    http_dispatch/1
]).
:- use_module(library(http/http_json), [
    reply_json_dict/2,
    reply_json/1,
    http_read_json_dict/2,
    reply_json_dict/1
]).
:- use_module(library(http/thread_httpd), [
    http_server/2
]).
:- use_module(library(http/http_session), [
    http_session_retract/1
]).
:- use_module(todo_model, [
    todo_create/2,
    todo_update/3
]).
:- use_module(storage/session_store, [
    session_store_todo/1,
    session_replace_todo/1,
    session_find_todo/1,
    session_delete_todo/1,
    session_find_all_todos/1
]).

:- http_handler(root(api/todos/TodoID),
                todo_handler(Method, TodoID),
                [method(Method),
                 methods([get, delete, put])]).
:- http_handler(root(api/todos),
                todos_handler(Method),
                [method(Method),
                 methods([get, post])]).

%% todos_handler(+Method:atom, +Request:dict)
%
% GET /api/todos
todos_handler(get, _Request) :-
    session_find_all_todos(Todos),
    reply_json_dict(Todos).

%% todos_handler(+Method:atom, +Request:dict)
%
% POST /api/todos
todos_handler(post, Request) :-
    http_read_json_dict(Request, _{title: Title}),
    todo_create(Title, Todo),
    session_store_todo(Todo),
    reply_json_dict(Todo).

%% validate_todo_id(+TodoIDAtom:atom, -TodoID:number)
validate_todo_id(TodoIDAtom, TodoID) :-
    atom_number(TodoIDAtom, TodoID),
    !.
validate_todo_id(TodoIDAtom, _) :-
    format(atom(Msg), "Invalid todo ID format: ~w", [TodoIDAtom]),
    throw(http_reply(bad_request(Msg))).

%% find_todo_or_fail(+TodoID:number, -Todo:dict)
find_todo_or_fail(TodoID, Todo) :-
    session_find_todo(Todo),
    Todo.id =:= TodoID,
    !.
find_todo_or_fail(TodoID, _) :-
    format(atom(Msg), "/api/todos/~w", [TodoID]),
    throw(http_reply(not_found(Msg))).

%% read_json_or_fail(+Request, -JsonDict)
read_json_or_fail(Request, JsonDict) :-
    catch(
        http_read_json_dict(Request, JsonDict),
        _,
        throw(http_reply(bad_request("Invalid JSON in request body")))
    ).

%% todo_handler(+Method:atom, +TodoIDAtom:atom, +Request:dict)
%
% PUT /api/todos/TodoID
todo_handler(put, TodoIDAtom, Request) :-
    validate_todo_id(TodoIDAtom, TodoID),
    find_todo_or_fail(TodoID, OldTodo),
    read_json_or_fail(Request, NewTodo),
    TodoChange = NewTodo.put(id, TodoID),
    todo_update(OldTodo, TodoChange, UpdatedTodo),
    session_replace_todo(UpdatedTodo),
    reply_json_dict(UpdatedTodo).

%% todo_handler(+Method:atom, +TodoIDAtom:atom, +Request:dict)
%
% GET /api/todos/TodoID
todo_handler(get, TodoIDAtom, _) :-
    validate_todo_id(TodoIDAtom, TodoID),
    find_todo_or_fail(TodoID, Todo),
    reply_json_dict(Todo).

%% todo_handler(+Method:atom, +TodoIDAtom:atom, +Request:dict)
%
% DELETE /api/todos/TodoID
todo_handler(delete, TodoIDAtom, _) :-
    validate_todo_id(TodoIDAtom, TodoID),
    find_todo_or_fail(TodoID, Todo),
    session_delete_todo(TodoID),
    reply_json_dict(Todo).

main(Port) :-
    http_server(http_dispatch, [port(Port)]).
