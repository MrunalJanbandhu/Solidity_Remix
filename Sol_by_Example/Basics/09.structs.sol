// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Todos {

    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function createTodo(string calldata _text) public {
        // calling it like function to store value
        todos.push(Todo(_text, false));

        // key value mapping
        todos.push( Todo({text: _text, completed: false}));

        Todo memory todo;
        todo.text = _text;
        // todo.completed = false;  // todo.completed is initialized to false

    }

    // get function is not required solidity auto. creates a getter for todos
    function get(uint _index) public view returns (string memory _text, bool _completed) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    function updateTodoText(uint index, string calldata _text) public {
        Todo storage todo = todos[index];
        todo.text = _text;
    }

    function updateTodoCompleted(uint index) public {
        Todo storage todo = todos[index];
        todo.completed = !todo.completed;
    }

}