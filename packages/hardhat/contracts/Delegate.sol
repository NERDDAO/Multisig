// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./GovToken.sol";

contract MultisigDelegate {
	using ECDSA for bytes32;

	uin256 public constant votingDuration = 3 days;

	struct Proposal {
		uint256 id;
		address by;
		//
		uint256 createdAt;
		uint256 due;
		//
		address[] targets;
		uint256[] values;
		bytes[] calldatas;
		bytes32 descriptionHash;
		//
		address[] positiveVoters;
		//
		bool executed;
		bool cancelled;
		//
		bytes[] results;
	}

	enum ProposalState {
		Unfulfilled,
		Fulfilled,
		Cancelled,
		Defeated,
		Executed
	}

	mapping(uint256 => Proposal) public proposals;
	event ProposalCreated(
		uint256 id,
		address by,
		uint256 createdAt,
		uint256 due,
		address[] targets,
		uint256[] values,
		bytes[] calldatas,
		string description
	);
	event ProposalCancelled(
		uint256 indexed id,
		address indexed by,
		uint256 time
	);
	event ProposalExecuted(
		uint256 indexed id,
		address indexed by,
		uint256 time
	);
	event CallPerformed(
		uint256 proposalId,
		address target,
		uint256 value,
		bytes _calldata,
		bytes returnVal,
		uint256 time
	);

	event ExecutorAdded(address);
	event ExecutorRemoved(address);

	uint256 public quorumPerMillion;
	uint256 public nonce;
	uint256 public chainId;

	mapping(address => bool) public executors;
	uint256 public executorCount = 1;

	GovToken public govToken;
	address public host;

	modifier onlyHost() {
		require(msg.sender == host, "Not Host");
		_;
	}

	modifier onlySelf() {
		require(msg.sender == address(this), "Not Self");
		_;
	}

	modifier onlyExecutors() {
		require(executors[msg.sender], "Not an executor");
		_;
	}

	receive() external payable {}

	constructor(uint256 _chainId, uint256 _quorumPerMillion) {
		require(
			_quorumPerMillion > 0,
			"constructor: must be non-zero sigs required"
		);
		quorumPerMillion = _quorumPerMillion;
		chainId = _chainId;
		govToken = new WalletGovToken(1000000, msg.sender);
		executors[msg.sender] = true;
		emit ExecutorAdded(msg.sender);
	}

	function vote(uint8) external {}

	////////////////// Public Functions

	function propose(
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas,
		string memory description
	) external onlyHost returns (uint256 id) {
		uint256 id = _hashProposal(
			targets,
			values,
			calldatas,
			keccak256(bytes(description))
		);

		uint256 N = targets.length;
		require(
			N > 0 && N == values.length && N == calldatas.length,
			"Inconsistent number of calls"
		);

		address[] memory positiveVoters = new address[];
		positiveVoters.push(msg.sender);
		proposals[id] = Proposal({
			id: id,
			by: msg.sender,
			createdAt: block.timestamp,
			due: block.timestamp + votingDuration,
			targets: targets,
			values: values,
			calldatas: calldatas,
			descriptionHash: descriptionHash,
			positiveVoters: positiveVoters,
			results: new bytes[N]
		});

		emit ProposalCreated(
			id,
			msg.sender,
			block.timestamp,
			block.timestamp + votingDuration,
			targets,
			values,
			calldatas,
			description
		);

		return id;
	}

	function cancel(
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas,
		bytes32 descriptionHash
	) external onlyHost returns (uint256) {
		uint256 id = hashProposal(targets, values, calldatas, descriptionHash);

		ProposalState currentState = state(id);
		if (
			currentState == ProposalState.Executed ||
			currentState == ProposalState.Defeated ||
			currentState == ProposalState.Cancelled
		) revert("Proposal not active");

		proposals[id].cancelled = true;

		emit ProposalCancelled(id, msg.sender, block.timestamp);

		return id;
	}

	function execute(
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas,
		bytes32 descriptionHash
	) external onlyExecutors returns (bytes memory) {
		uint256 id = _hashProposal(targets, values, calldatas, descriptionHash);

		if (state(id) != ProposalState.Fulfilled) revert("Not fulfilled");

		uint256 totalValue;
		for (uint256 i = 0; i < values.length; i++) totalValue += values[i];
		if (address(this).balance < totalValue)
			revert("Contract doesn't have enough funds");

		proposals[id].executed = true;

		emit ProposalExecuted(id, msg.sender, block.timestamp);

		_execute(id, targets, values, calldatas, descriptionHash);

		return id;
	}

	function state(uint256 proposalId) public view returns (ProposalState) {
		Proposal memory proposal = proposals[proposalId];

		if (proposal.executed) return ProposalState.Executed;
		if (proposal.cancelled) return ProposalState.Cancelled;

		if (_aggregateWeight(proposal.positiveVoters) >= quorumPerMillion)
			return ProposalState.Fulfilled;
		if (proposal.due >= block.timestamp) return ProposalState.Unfulfilled;

		return ProposalState.Defeated;
	}

	////////////////// Internal Functions

	function _execute(
		uint256 proposalId,
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas
	) internal view {
		for (uint256 i = 0; i < targets.length; ++i) {
			(bool success, bytes memory returndata) = targets[i].call{
				value: values[i]
			}(calldatas[i]);
			if (!success) revert("Call to target failed");
			proposals[proposalId].results[i] = returndata;
			emit CallPerformed(
				proposalId,
				targets[i],
				values[i],
				calldatas[i],
				returndata,
				block.timestamp
			);
		}
	}

	function _hashProposal(
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas,
		bytes32 descriptionHash
	) internal pure returns (uint256) {
		return
			uint256(
				keccak256(
					abi.encode(targets, values, calldatas, descriptionHash)
				)
			);
	}

	function _aggregateWeight(
		address[] positiveVoters
	) internal view returns (uint256 weight) {
		for (uint256 i = 0; i < positiveVoters.length; i++)
			weight += govToken.balanceOf(positiveVoters[i]);
		return weight;
	}

	////////////////// Self-Governed Functions

	function updateQuorumPerMillion(
		uint256 newQuorumPerMillion
	) external onlySelf {
		require(newQuorumPerMillion > 0, "Quorum cannot be zero");
		quorumPerMillion = newquorumPerMillion;
	}

	function addExecutor(address newExecutor) external onlySelf {
		executors[newExecutor] = true;
		executorCount++;
		emit ExecutorAdded(newExecutor);
	}

	function removeExecutor(address oldExecutor) external onlySelf {
		require(executorCount > 1, "Cannot remove the last executor.");
		executors[oldExecutor] = false;
		executorCount--;
		emit ExecutorRemoved(newExecutor);
	}

	function setHost(address newHost) external onlySelf {
		require(newHost != address(0), "Cannot set to zero address");
		require(newHost != address(this), "Cannot set to itself");
		require(newHost != host, "Already the host");
		host = newHost;
	}
}
