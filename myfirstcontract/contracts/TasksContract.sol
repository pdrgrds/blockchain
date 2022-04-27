// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TasksContract {

    uint public taskCounter = 0;

    constructor () {
        createTask("Mi primera tarea de ejemplo", "tengo que hacer algo D:");
    }

    event TaskCreated(
        uint id,
        string title,
        string description,
        bool done,
        uint createdAt
    );

    event TaskToggleDonde(
        uint id,
        bool done
    );

    struct Task {
        uint id;
        string title;
        string description;
        bool done;
        uint256 createdAt;
        // uint no permite negativo && === uint256
    }

    mapping (uint256 => Task) public tasks;

    function createTask(string memory _title, string memory _description) public {
        taskCounter++;
        tasks[taskCounter] = Task(taskCounter, _title, _description, false, block.timestamp);
        emit TaskCreated(taskCounter, _title, _description, false, block.timestamp);
    }

    function toggleDone(uint _id) public {
        Task memory _task = tasks[_id];
        _task.done = !_task.done;
        tasks[_id] = _task;
        emit TaskToggleDonde(_id, _task.done);
    }
}