// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract is to lock up you eth
// for a specified amount of time
// The name "Casa" is in Eritrea's Tigrinya meaning "Jar used to save Money"
contract Casa {
    uint256 private totalUsers;

    struct Account {
        uint256 balance;
        // This is the timestamp to release the locked eth
        // Its stored in the format YYYYMMDD
        uint32 timestamp;
    }

    struct User{
        uint32 accountCount;
        mapping(uint => Account) accounts;
    }

    event NewAccount(
        address indexed ownerAddress,
        uint32 _account,
        uint256 _amount,
        uint32 _timestamp
    );

    event UpdateAccount(
        address indexed ownerAddress,
        uint32 _account,
        uint256 _amount
    );

    event CloseAccount(
        address indexed ownerAddress,
        uint32 _account
    );

    mapping(address => User) private lockedEthBalance;

    function viewUserAccountTime(uint32 account) external view returns(uint32){
        return lockedEthBalance[msg.sender].accounts[account].timestamp;
    }

    function viewUserAccountBalance(uint32 account) external view returns(uint256){
        return lockedEthBalance[msg.sender].accounts[account].balance;
    }

    function lockEth(uint32 timestamp) external payable {
        User storage userAccount = lockedEthBalance[msg.sender];
        if(userAccount.accountCount == 0){
            totalUsers += 1;
        }
        userAccount.accountCount += 1;
        userAccount.accounts[userAccount.accountCount] = Account(msg.value, timestamp);
        emit NewAccount(msg.sender, userAccount.accountCount, msg.value, timestamp); 
    }

    function updateLockedEth(uint32 account) external payable {
        User storage userAccount = lockedEthBalance[msg.sender];
        
        require(userAccount.accounts[account].timestamp != 0, "Account not found");

        userAccount.accounts[account].balance += msg.value;
        emit UpdateAccount(msg.sender, account, msg.value);
    }

    function unLockEth(uint32 account, uint32 timestamp) external {
        address payable receipient = payable(msg.sender);
        
        require(lockedEthBalance[receipient].accounts[account].timestamp <= timestamp, "Lock period has not elapsed.");

        receipient.transfer(lockedEthBalance[receipient].accounts[account].balance);
        lockedEthBalance[receipient].accounts[account].balance = 0;
        emit CloseAccount(msg.sender, account);
    }

    function contractBalance() external view returns(uint){
        return address(this).balance;
    }

    function getTotalUsers() external view returns(uint){
        return totalUsers;
    }
}