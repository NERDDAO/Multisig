const contracts = {
  31337: [
    {
      chainId: "31337",
      name: "localhost",
      contracts: {
        Delegate: {
          address: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
          abi: [
            {
              inputs: [
                {
                  internalType: "uint256",
                  name: "_quorum",
                  type: "uint256",
                },
                {
                  internalType: "uint256",
                  name: "govTokenSupply",
                  type: "uint256",
                },
              ],
              stateMutability: "nonpayable",
              type: "constructor",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "proposalId",
                  type: "uint256",
                },
                {
                  indexed: false,
                  internalType: "address",
                  name: "target",
                  type: "address",
                },
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "value",
                  type: "uint256",
                },
                {
                  indexed: false,
                  internalType: "bytes",
                  name: "_calldata",
                  type: "bytes",
                },
                {
                  indexed: false,
                  internalType: "bytes",
                  name: "returnVal",
                  type: "bytes",
                },
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "time",
                  type: "uint256",
                },
              ],
              name: "CallPerformed",
              type: "event",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: false,
                  internalType: "address",
                  name: "",
                  type: "address",
                },
              ],
              name: "ExecutorAdded",
              type: "event",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: false,
                  internalType: "address",
                  name: "",
                  type: "address",
                },
              ],
              name: "ExecutorRemoved",
              type: "event",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: true,
                  internalType: "uint256",
                  name: "id",
                  type: "uint256",
                },
                {
                  indexed: true,
                  internalType: "address",
                  name: "by",
                  type: "address",
                },
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "time",
                  type: "uint256",
                },
              ],
              name: "ProposalCancelled",
              type: "event",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "id",
                  type: "uint256",
                },
                {
                  indexed: false,
                  internalType: "address",
                  name: "by",
                  type: "address",
                },
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "createdAt",
                  type: "uint256",
                },
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "due",
                  type: "uint256",
                },
                {
                  indexed: false,
                  internalType: "address[]",
                  name: "targets",
                  type: "address[]",
                },
                {
                  indexed: false,
                  internalType: "uint256[]",
                  name: "values",
                  type: "uint256[]",
                },
                {
                  indexed: false,
                  internalType: "bytes[]",
                  name: "calldatas",
                  type: "bytes[]",
                },
                {
                  indexed: false,
                  internalType: "string",
                  name: "description",
                  type: "string",
                },
              ],
              name: "ProposalCreated",
              type: "event",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: true,
                  internalType: "uint256",
                  name: "id",
                  type: "uint256",
                },
                {
                  indexed: true,
                  internalType: "address",
                  name: "by",
                  type: "address",
                },
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "time",
                  type: "uint256",
                },
              ],
              name: "ProposalExecuted",
              type: "event",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "proposalId",
                  type: "uint256",
                },
                {
                  indexed: false,
                  internalType: "address",
                  name: "",
                  type: "address",
                },
              ],
              name: "VoteCancelled",
              type: "event",
            },
            {
              anonymous: false,
              inputs: [
                {
                  indexed: false,
                  internalType: "uint256",
                  name: "proposalId",
                  type: "uint256",
                },
                {
                  indexed: false,
                  internalType: "address",
                  name: "",
                  type: "address",
                },
              ],
              name: "VoteCast",
              type: "event",
            },
            {
              inputs: [
                {
                  internalType: "address",
                  name: "newExecutor",
                  type: "address",
                },
              ],
              name: "addExecutor",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "address[]",
                  name: "targets",
                  type: "address[]",
                },
                {
                  internalType: "uint256[]",
                  name: "values",
                  type: "uint256[]",
                },
                {
                  internalType: "bytes[]",
                  name: "calldatas",
                  type: "bytes[]",
                },
                {
                  internalType: "bytes32",
                  name: "descriptionHash",
                  type: "bytes32",
                },
              ],
              name: "cancelProposal",
              outputs: [
                {
                  internalType: "uint256",
                  name: "",
                  type: "uint256",
                },
              ],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "uint256",
                  name: "proposalId",
                  type: "uint256",
                },
              ],
              name: "cancelVote",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "uint256",
                  name: "proposalId",
                  type: "uint256",
                },
              ],
              name: "castVote",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "address[]",
                  name: "targets",
                  type: "address[]",
                },
                {
                  internalType: "uint256[]",
                  name: "values",
                  type: "uint256[]",
                },
                {
                  internalType: "bytes[]",
                  name: "calldatas",
                  type: "bytes[]",
                },
                {
                  internalType: "bytes32",
                  name: "descriptionHash",
                  type: "bytes32",
                },
              ],
              name: "execute",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [],
              name: "executorCount",
              outputs: [
                {
                  internalType: "uint256",
                  name: "",
                  type: "uint256",
                },
              ],
              stateMutability: "view",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "address",
                  name: "",
                  type: "address",
                },
              ],
              name: "executors",
              outputs: [
                {
                  internalType: "bool",
                  name: "",
                  type: "bool",
                },
              ],
              stateMutability: "view",
              type: "function",
            },
            {
              inputs: [],
              name: "govToken",
              outputs: [
                {
                  internalType: "contract GovToken",
                  name: "",
                  type: "address",
                },
              ],
              stateMutability: "view",
              type: "function",
            },
            {
              inputs: [],
              name: "host",
              outputs: [
                {
                  internalType: "address",
                  name: "",
                  type: "address",
                },
              ],
              stateMutability: "view",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "uint256",
                  name: "",
                  type: "uint256",
                },
              ],
              name: "proposals",
              outputs: [
                {
                  internalType: "uint256",
                  name: "id",
                  type: "uint256",
                },
                {
                  internalType: "address",
                  name: "by",
                  type: "address",
                },
                {
                  internalType: "uint256",
                  name: "createdAt",
                  type: "uint256",
                },
                {
                  internalType: "uint256",
                  name: "due",
                  type: "uint256",
                },
                {
                  internalType: "bytes32",
                  name: "descriptionHash",
                  type: "bytes32",
                },
                {
                  internalType: "bool",
                  name: "executed",
                  type: "bool",
                },
                {
                  internalType: "bool",
                  name: "cancelled",
                  type: "bool",
                },
              ],
              stateMutability: "view",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "address[]",
                  name: "targets",
                  type: "address[]",
                },
                {
                  internalType: "uint256[]",
                  name: "values",
                  type: "uint256[]",
                },
                {
                  internalType: "bytes[]",
                  name: "calldatas",
                  type: "bytes[]",
                },
                {
                  internalType: "string",
                  name: "description",
                  type: "string",
                },
              ],
              name: "propose",
              outputs: [
                {
                  internalType: "uint256",
                  name: "id",
                  type: "uint256",
                },
              ],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [],
              name: "quorum",
              outputs: [
                {
                  internalType: "uint256",
                  name: "",
                  type: "uint256",
                },
              ],
              stateMutability: "view",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "address",
                  name: "oldExecutor",
                  type: "address",
                },
              ],
              name: "removeExecutor",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "address",
                  name: "newHost",
                  type: "address",
                },
              ],
              name: "setHost",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "uint256",
                  name: "newQuorum",
                  type: "uint256",
                },
              ],
              name: "updateQuorum",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [
                {
                  internalType: "uint8",
                  name: "",
                  type: "uint8",
                },
              ],
              name: "vote",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
            {
              inputs: [],
              name: "votingDuration",
              outputs: [
                {
                  internalType: "uint256",
                  name: "",
                  type: "uint256",
                },
              ],
              stateMutability: "view",
              type: "function",
            },
            {
              stateMutability: "payable",
              type: "receive",
            },
          ],
        },
      },
    },
  ],
} as const;

export default contracts;
