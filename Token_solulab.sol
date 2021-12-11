pragma solidity ^0.4.18;

contract Sage {
    
    uint LIFETIME_DEPOSIT_AMOUNT;
    uint LIFETIME_WITHDRAWAL_AMOUNT;
    uint LIFETIME_TRANSFERRED_AMOUNT;
    uint TOTAL_DEPOSITS_COUNT;
    uint TOTAL_WITHDRAWALS_COUNT;
    uint TOTAL_TRANSFERS_COUNT;
    
    struct User{
        string userDetailsMetadata;
        uint usdBalance;
        uint cdiBalance;
    }
    
    mapping(address => User) users;
    mapping(address => mapping(address => bool)) isWhitelisted;
    mapping(address => bool) isAdded;
    
    event UserEvent(string _actionPerformed, address _userAddress, string _userDetailsMetadata, uint _usdBalance, uint _cdiBalance, uint256 _timestamp);
    event TransferEvent(string _actionPerformed, address _to, address _from, uint _amount, uint256 _timestamp);
    event DepositEvent(string _actionPerformed, address _userAddress, uint _amount, uint256 _timestamp);
    event WithdrawalEvent(string _actionPerformed, address _userAddress, uint _amount, uint256 _timestamp);
    event WhitelistDeWhitelistEvent(string _actionPerformed, address _userAddress, address _addressToWhitelist, uint256 _timestamp);

    function Sage(){
        LIFETIME_DEPOSIT_AMOUNT = 0;
        LIFETIME_WITHDRAWAL_AMOUNT = 0;
        LIFETIME_TRANSFERRED_AMOUNT = 0;
        TOTAL_DEPOSITS_COUNT = 0;
        TOTAL_WITHDRAWALS_COUNT = 0;
        TOTAL_TRANSFERS_COUNT = 0;
    }

    function addUser(address _userAddress, string _userDetailsMetadata){
        require(isAdded[_userAddress] == false);
        users[_userAddress].userDetailsMetadata = _userDetailsMetadata;
        users[_userAddress].usdBalance = 0;
        users[_userAddress].cdiBalance = 0;
        isAdded[_userAddress] = true;
        isWhitelisted[_userAddress][_userAddress] = true;
        
        UserEvent("USER ONBOARDED", _userAddress, _userDetailsMetadata, users[_userAddress].usdBalance, users[_userAddress].cdiBalance, now);
    }
    
    function updateUser(address _userAddress, string _userDetailsMetadata){
        require(isAdded[_userAddress] == true);
        users[_userAddress].userDetailsMetadata = _userDetailsMetadata;
        
        UserEvent("USER UPDATED", _userAddress, _userDetailsMetadata, users[_userAddress].usdBalance, users[_userAddress].cdiBalance, now);
    }
    
    function getUserDetails(address _userAddress, address _selfAddress) returns(string){
        require(isAdded[_userAddress] == true && isWhitelisted[_selfAddress][_userAddress] == true);
        return users[_userAddress].userDetailsMetadata;
    }
    
    function transferUsd(address _to, address _from, uint _amount){
        require(isAdded[_to] == true && isAdded[_from] == true && users[_from].usdBalance >= _amount && _amount>0);
        users[_from].usdBalance = users[_from].usdBalance - _amount;
        users[_to].usdBalance = users[_to].usdBalance + _amount;
        LIFETIME_TRANSFERRED_AMOUNT = LIFETIME_TRANSFERRED_AMOUNT + _amount;
        TOTAL_TRANSFERS_COUNT = TOTAL_TRANSFERS_COUNT + 1;
        
        TransferEvent("USD TRANSFERRED", _to, _from, _amount, now);
    }
    
    function depositUsd(address _userAddress, uint _amount){
        require(isAdded[_userAddress] == true && _amount >0);
        users[_userAddress].usdBalance = users[_userAddress].usdBalance + _amount;
        LIFETIME_DEPOSIT_AMOUNT = LIFETIME_DEPOSIT_AMOUNT + _amount;
        TOTAL_DEPOSITS_COUNT = TOTAL_DEPOSITS_COUNT + 1;
        
        DepositEvent("USD DEPOSITED", _userAddress, _amount, now);
    }
    
    function withdrawUsd(address _userAddress, uint _amount){
        require(isAdded[_userAddress] == true && users[_userAddress].usdBalance >= _amount && _amount>0);
        users[_userAddress].usdBalance = users[_userAddress].usdBalance - _amount;
        LIFETIME_WITHDRAWAL_AMOUNT = LIFETIME_WITHDRAWAL_AMOUNT + _amount;
        TOTAL_WITHDRAWALS_COUNT = TOTAL_WITHDRAWALS_COUNT + 1;
        
        WithdrawalEvent("USD WITHDRAWN", _userAddress, _amount, now);
    }
    
    function transferCdi(address _to, address _from, uint _amount){
        require(isAdded[_to] == true && isAdded[_from] == true && users[_from].cdiBalance >= _amount && _amount>0);
        users[_from].cdiBalance = users[_from].cdiBalance - _amount;
        users[_to].cdiBalance = users[_to].cdiBalance + _amount;
        LIFETIME_TRANSFERRED_AMOUNT = LIFETIME_TRANSFERRED_AMOUNT + _amount;
        TOTAL_TRANSFERS_COUNT = TOTAL_TRANSFERS_COUNT + 1;
        
        TransferEvent("CDI TRANSFERRED", _to, _from, _amount, now);
    }
    
    function depositCdi(address _userAddress, uint _amount){
        require(isAdded[_userAddress] == true && _amount >0);
        users[_userAddress].cdiBalance = users[_userAddress].cdiBalance + _amount;
        LIFETIME_DEPOSIT_AMOUNT = LIFETIME_DEPOSIT_AMOUNT + _amount;
        TOTAL_DEPOSITS_COUNT = TOTAL_DEPOSITS_COUNT + 1;
        
        DepositEvent("CDI DEPOSITED", _userAddress, _amount, now);
    }
    
    function withdrawCdi(address _userAddress, uint _amount){
        require(isAdded[_userAddress] == true && users[_userAddress].cdiBalance >= _amount && _amount>0);
        users[_userAddress].cdiBalance = users[_userAddress].cdiBalance - _amount;
        LIFETIME_WITHDRAWAL_AMOUNT = LIFETIME_WITHDRAWAL_AMOUNT + _amount;
        TOTAL_WITHDRAWALS_COUNT = TOTAL_WITHDRAWALS_COUNT + 1;
        
        WithdrawalEvent("CDI WITHDRAWN", _userAddress, _amount, now);
    }
    
    function getUserBalance(address _userAddress, address _selfAddress) returns(uint, uint){
        require(isAdded[_userAddress] == true && isWhitelisted[_selfAddress][_userAddress] == true);
        return (users[_userAddress].usdBalance, users[_userAddress].cdiBalance);
    }
    
    function getLifetimeDepositAmount() returns(uint){
        return LIFETIME_DEPOSIT_AMOUNT;
    }
    
    function getLifetimeWithdrawalAmount() returns(uint){
        return LIFETIME_WITHDRAWAL_AMOUNT;
    }
    
    function getLifetimeTransferredAmount() returns(uint){
        return LIFETIME_TRANSFERRED_AMOUNT;
    }
    
    function getTotalDepositsCount() returns(uint){
        return TOTAL_DEPOSITS_COUNT;
    }
    
    function getTotalWithdrawalsCount() returns(uint){
        return TOTAL_WITHDRAWALS_COUNT;
    }
    
    function getTotalTransfersCount() returns(uint){
        return TOTAL_TRANSFERS_COUNT;
    }
    
    function whitelist(address _userAddress, address _addressToWhitelist){
        require(isAdded[_userAddress] == true && isAdded[_addressToWhitelist] == true && isWhitelisted[_addressToWhitelist][_userAddress] == false);
        isWhitelisted[_addressToWhitelist][_userAddress] = true;
        
        WhitelistDeWhitelistEvent("ADDRESS WHITELISTED", _userAddress, _addressToWhitelist, now);
    }
    
    function deWhitelist(address _userAddress, address _addressToDeWhitelist){
        require(isAdded[_userAddress] == true && isAdded[_addressToDeWhitelist] == true && isWhitelisted[_addressToDeWhitelist][_userAddress] == true);
        isWhitelisted[_addressToDeWhitelist][_userAddress] = false;
        
        WhitelistDeWhitelistEvent("ADDRESS DEWHITELISTED", _userAddress, _addressToDeWhitelist, now);
    }
}