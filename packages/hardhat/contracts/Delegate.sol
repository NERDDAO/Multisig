// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./GovToken.sol";

contract MultisigDelegate {
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
		mapping(address => bool) positiveVoters_hasKey;
		//
		bool executed;
		bool cancelled;
		//
		bytes[] results;
	}

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
	event VoteCast(uint256 proposalId, address);
	event VoteCancelled(uint256 proposalId, address);
	event CallPerformed(
		uint256 proposalId,
		address target,
		uint256 value,
		bytes _calldata,
		bytes returnVal,
		uint256 time
	);
	event ProposalExecuted(
		uint256 indexed id,
		address indexed by,
		uint256 time
	);
	event ExecutorAdded(address);
	event ExecutorRemoved(address);

	uint256 public constant votingDuration = 3 days;
	mapping(uint256 => Proposal) public proposals;

	uint256 public quorum;
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

	constructor(uint256 _chainId, uint256 _quorum, uint256 govTokenSupply) {
		require(_quorum > 0, "Quorum cannot be zero");
		quorum = _quorum;
		chainId = _chainId;
		govToken = new GovToken(govTokenSupply, msg.sender);
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
		bytes32 descriptionHash = keccak256(bytes(description));
		uint256 id = _hashProposal(targets, values, calldatas, descriptionHash);

		uint256 N = targets.length;
		require(
			N > 0 && N == values.length && N == calldatas.length,
			"Inconsistent number of calls"
		);

		proposals[id].id = id;
		proposals[id].by = msg.sender;
		proposals[id].createdAt = block.timestamp;
		proposals[id].due = block.timestamp + votingDuration;
		proposals[id].targets = targets;
		proposals[id].values = values;
		proposals[id].calldatas = calldatas;
		proposals[id].descriptionHash = descriptionHash;
		proposals[id].positiveVoters.push(msg.sender);
		proposals[id].positiveVoters_hasKey[msg.sender] = true;

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

	function cancelProposal(
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas,
		bytes32 descriptionHash
	) external onlyHost returns (uint256) {
		uint256 id = _hashProposal(targets, values, calldatas, descriptionHash);

		Proposal storage proposal = proposals[id];
		if (
			proposal.executed ||
			proposal.cancelled ||
			proposal.due < block.timestamp
		) revert("Proposal not active");

		proposals[id].cancelled = true;

		emit ProposalCancelled(id, msg.sender, block.timestamp);

		return id;
	}

	function castVote(uint256 proposalId) external {
		Proposal storage proposal = proposals[proposalId];

		if (
			proposal.executed ||
			proposal.cancelled ||
			proposal.due < block.timestamp
		) revert("Proposal not active");

		if (proposal.positiveVoters_hasKey[msg.sender]) revert("Duplicate");

		proposal.positiveVoters.push(msg.sender);
		proposal.positiveVoters_hasKey[msg.sender] = true;

		emit VoteCast(proposalId, msg.sender);
	}

	function cancelVote(uint256 proposalId) external {
		Proposal storage proposal = proposals[proposalId];

		if (
			proposal.executed ||
			proposal.cancelled ||
			proposal.due < block.timestamp
		) revert("Proposal not active");

		if (!proposal.positiveVoters_hasKey[msg.sender])
			revert("You're not in the voters list anyway");

		proposal.positiveVoters.push(msg.sender);
		proposal.positiveVoters_hasKey[msg.sender] = true;

		emit VoteCancelled(proposalId, msg.sender);
	}

	function execute(
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas,
		bytes32 descriptionHash
	) external onlyExecutors {
		uint256 id = _hashProposal(targets, values, calldatas, descriptionHash);

		Proposal storage proposal = proposals[id];
		if (
			proposal.executed ||
			proposal.cancelled ||
			proposal.due < block.timestamp
		) revert("Proposal not active");

		if (_aggregateWeight(proposal.positiveVoters) < quorum)
			revert("Not fulfilled");

		uint256 totalValue;
		for (uint256 i = 0; i < values.length; i++) totalValue += values[i];
		if (address(this).balance < totalValue)
			revert("Contract doesn't have enough funds");

		proposals[id].executed = true;

		emit ProposalExecuted(id, msg.sender, block.timestamp);

		_execute(id, targets, values, calldatas);
	}

	////////////////// Internal Functions

	function _execute(
		uint256 proposalId,
		address[] memory targets,
		uint256[] memory values,
		bytes[] memory calldatas
	) internal {
		for (uint256 i = 0; i < targets.length; ++i) {
			(bool success, bytes memory returndata) = targets[i].call{
				value: values[i]
			}(calldatas[i]);
			if (!success) revert("Call to target failed");
			proposals[proposalId].results.push(returndata);
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
		address[] memory positiveVoters
	) internal view returns (uint256 weight) {
		for (uint256 i = 0; i < positiveVoters.length; i++)
			weight += govToken.balanceOf(positiveVoters[i]);
		return weight;
	}

	////////////////// Self-Governed Functions

	function updateQuorum(uint256 newQuorum) external onlySelf {
		require(newQuorum > 0, "Quorum cannot be zero");
		quorum = newQuorum;
	}

	function addExecutor(address newExecutor) external onlySelf {
		require(newExecutor != address(0), "Cannot set to zero address");
		require(newExecutor != address(this), "Cannot set to itself");

		executors[newExecutor] = true;
		executorCount++;

		emit ExecutorAdded(newExecutor);
	}

	function removeExecutor(address oldExecutor) external onlySelf {
		require(executorCount > 1, "Cannot remove the last executor.");

		executors[oldExecutor] = false;
		executorCount--;

		emit ExecutorRemoved(oldExecutor);
	}

	function setHost(address newHost) external onlySelf {
		require(newHost != address(0), "Cannot set to zero address");
		require(newHost != address(this), "Cannot set to itself");
		require(newHost != host, "Already the host");

		host = newHost;
	}
}
