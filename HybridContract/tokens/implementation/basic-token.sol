pragma solidity ^ 0.4.18;
import "../../receiver/receiver.sol"; //where operations happen, child
import "../../libraries/SafeMath.sol";
import "./interface/Hybrid-Token-Interface";
import "./token.sol";

//TODO test to see if contract owner can change the amount of total supply
contract basic is HybridToken, token {
  using SafeMath for uint256;
  string internal _symbol;
  string internal _name;
  uint8 internal _decimals;
  uint256 internal _totalSupply;
  address internal _owner;

    function basic(string symbol, string name, uint8 decimals, uint256 totalSupply) public onlyOwner {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _owner = msg.sender;
        _balances[_owner] = totalSupply;
        _totalSupply = totalSupply;
    }
    function get_address() public onlyOwner returns (address) {
        return address(this);

    }
    function balanceOf(address addr) public view onlyOwner returns(uint256) {

        return _balances[addr];

    }
    function getOwner() public onlyOwner returns(address) {

        return _owner;

    }
    function totalSupply() public view onlyOwner returns(uint256) {

        return _totalSupply;

    }
    function transfer(address sender,address receiver, uint256 amount, bytes data) public onlyOwner returns(bool) {
     if(balanceOf(sender) < amount)
        {
            revert();
        }
       else if (receiver == 0x0)
        {
            revert();
        }
        else if(receiver==address(0))
        {
            revert();
        }
        else
        {
            //subtrack the amount of tokens from sender

            _balances[sender] = _balances[sender].sub(amount);

            //Add those tokens to reciever
            _balances[receiver] = _balances[receiver].add(amount);

            //If reciever is a contract ...
            if (isContract(receiver)) {
                Receiver Receiverontract = Receiver(receiver);
                //Invoke the call back function on the reciever contract
                Receiverontract.tokenFallback(sender, amount, data);
            }
            return true;
        }
    }




    function transfer(address sender,address receiver, uint256 amount) public onlyOwner returns(bool) {

          bytes memory empty;
          //use ERC223 transfer function
          bool gotTransfered = transfer(sender,receiver, amount, empty);
          if (gotTransfered)
          return true;
          else
          return false;

    }

    function transferfrom(address _from, address _to, uint _value) public onlyOwner returns (bool){
      if (_allowance[_from][msg.sender] > 0 && _value > 0 &&
          _allowance[_from][msg.sender] >= _value && _balances[_from] >= _value){
            _balances[_from] = _balances[_from].sub(_value);
            _balances[_to] = _balances[_to].add(_value);
            return true;
          }
          return false;
    }

    function approve (address from, address _spender, uint _value) public onlyOwner returns (bool){
      _allowance[msg.sender][_spender] = _value;
      return true;

    }

    /* function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    return true;

    } */

    /* function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    return true;
  } */




    function allowance (address _owner, address _spender) public constant onlyOwner returns (uint){
      return _allowance[_owner][_spender];

    }

    function mint(address tokenAddress,address receiver, uint256 amount) public onlyOwner returns(bool)
    {
        transfer(tokenAddress,receiver, amount);
    }

    function burn(address owner,uint256 amount) public onlyOwner returns(bool) {


        //Safty check : token owner cannot burn more than the amount currently exists in their address

        if(_balances[owner] < amount)
        {
            revert();
        }
        else
        {
            //burn operation :
            _balances[owner] = _balances[owner].sub(amount);
            _totalSupply = _totalSupply.sub(amount);
            return true;
        }
    }


    //private functions
    function isContract(address addr) private view returns(bool) {
        uint length;
        assembly {
            //retrieves the size of the code on target address
            length: = extcodesize(addr)
        }
        return (length > 0);
    }
    modifier onlyOwner
    {
      if(msg.sender!=_owner)
      {
        revert();
      }
      else
      {
        _;
      }
    }

}
