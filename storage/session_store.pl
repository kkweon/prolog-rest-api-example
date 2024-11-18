:- module(session_store, [
    session_store_todo/1,
    session_replace_todo/1,
    session_find_todo/1,
    session_delete_todo/1,
    session_find_all_todos/1
]).

:- use_module(library(http/http_session), [
    http_session_retract/1,
    http_session_data/1,
    http_session_assert/1
]).

% Store a todo in the session
session_store_todo(Todo) :-
    must_be(dict, Todo),
    http_session_assert(todo(Todo)).

% Replace an existing todo
session_replace_todo(Todo) :-
    session_delete_todo(Todo.id),
    session_store_todo(Todo).

% Find a single todo
session_find_todo(Todo) :-
    http_session_data(todo(Todo)).

session_delete_todo(TodoID) :-
    http_session_data(todo(OldTodo)),
    OldTodo.id =:= TodoID,
    http_session_retract(todo(OldTodo)).

% Find all todos
session_find_all_todos(Todos) :-
    findall(Todo, session_find_todo(Todo), Todos).
