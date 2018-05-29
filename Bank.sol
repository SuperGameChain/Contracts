pragma solidity ^0.4.0;
//import "./ERC20.sol";
interface Itoken { function transfer(address _to, uint256 _value) external; 
                   function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);}
contract Bank{
    
    struct Payout{
        uint256 amount;
        uint256 depositedAt; //creation time
        uint256 lockedFor;   // time payment is locked for in minutes (while testing)
    }
    
    mapping (uint256=>Payout) payouts;
    mapping (address=>uint256[]) clientsIndices;
    address private bankOwner; //is allowed to add clients and payments
    address testToken = address(0xcc5a3e48dc55b9b7b699855d4910e83beb505bae);
    uint256 index = 0; 
    
    function Bank() public { 
        bankOwner = msg.sender;
    }
    
    function addPayout (
    address _client,
    uint256 _amount,
    uint256 _lockedFor) public{
        if(msg.sender == bankOwner) {
            Itoken token = Itoken(testToken);
            if(!token.transferFrom(msg.sender, address(this), _amount)) { throw; }
            else{
                var payout = Payout(_amount, now, _lockedFor);
                payouts[index] = payout;
                clientsIndices[_client].push(index);
                index++;
            }
        }
    }
    
    function withdraw(
        address _client,
        uint256 _amount,
        uint256 _lockedFor
        )public payable returns(bool){
            for(uint256 i = 0; i < clientsIndices[_client].length; i++){
                if( payouts[clientsIndices[_client][i]].amount == _amount && 
                    payouts[clientsIndices[_client][i]].lockedFor == _lockedFor &&
                    now >= payouts[clientsIndices[_client][i]].lockedFor * 1 minutes + payouts[clientsIndices[_client][i]].depositedAt){
                        Itoken token = Itoken(testToken);
                        token.transfer(_client, _amount);
                        return true; 
                    }
            }
        return false;
    }
}
