:- module(todo_model, [
    todo_create/2,
    todo_update/3
]).

% Create a new todo
todo_create(Title, Todo) :-
    get_time(CreatedAtTimestamp),
    ID is round(CreatedAtTimestamp * 1000),
    dict_create(Todo, todo, [
        id(ID),
        title(Title),
        created_at(CreatedAtTimestamp),
        completed(false)
    ]).

% Update a todo
todo_update(OldTodo, TodoChange, OldTodo.put(TodoChange)) :-
    OldTodo.id =:= TodoChange.id.
