App = {
    contracts: {},
    init: async () => {
        console.log('Loaded');
        await App.loadEthereum();
        await App.loadAccount();
        await App.loadContracts();
        App.render();
        await App.renderTasks();
    },

    loadEthereum: async () => {
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            await window.ethereum.request({ method: 'eth_requestAccounts' })
            console.log('ethereum existe')
        } else if (window.web3) {
            web3 = new Web3(window.web3.currentProvider)
        } else {
            console.log('No ethereum browse is installed. Try it installing Metamask')
        }
    },

    loadAccount: async () => {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
        App.account = accounts[0]
    },

    loadContracts: async () => {
        const res = fetch("TasksContract.json");
        const TasksContractJSON = await (await res).json();
        console.log(TasksContractJSON)

        App.contracts.tasksConctract = TruffleContract(TasksContractJSON);
        App.contracts.tasksConctract.setProvider(App.web3Provider);
        App.tasksConctract = await App.contracts.tasksConctract.deployed();
    },

    render: () => {
        document.getElementById("account").innerText = App.account
    },

    renderTasks: async () => {
        const tasksCounter = await App.tasksConctract.taskCounter();
        const tasksCounterNumber = tasksCounter.toNumber();
        console.log(tasksCounterNumber)

        let html = '';

        for (let i = 1; i <= tasksCounterNumber; i++) {
            const task = await App.tasksConctract.tasks(i);
            const taskId = task[0];
            const taskTitle = task[1];
            const taskDescription = task[2];
            const taskDone = task[3];
            const taskCreated = task[4];
            console.log(task);

            let taskElement = `
                <div class="card bg-dark rounded-0 mb-2">
                    <div class="card-header d-flex justify-content-between align-item-center">
                        <span>${taskTitle}</span>
                        <div class="form-check form-switch">
                            <input class="form-check-input" data-id="${taskId}" type="checkbox" ${taskDone && 'checked'} onchange="App.toggleDone(this)" />
                        </div>
                    </div>
                    <div class="card-body"> 
                        <span>${taskDescription}</span>
                        <p class="text-muted"> Task was created: ${new Date(taskCreated * 1000).toLocaleString()} </p>
                    </div>
                </div>
            `
            html += taskElement;
        }

        document.querySelector("#tasksList").innerHTML = html;
    },

    createTask: async (title, description) => {
        const result = await App.tasksConctract.createTask(title, description, {
            from: App.account
        });
        console.log(result.logs[0].args);
    },

    toggleDone: async (element) => {
        const taskId = element.dataset.id;
        await App.tasksConctract.toggleDone(taskId, {
            from: App.account
        });

        window.location.reload();
    }
}