pragma solidity ^0.4.18;
import "./interface/Hybrid-Token-Interface";
import "./implementation/basic-token.sol";
import "./implementation/mintable-token.sol";

//Todo Create a Hybrid TOken
/*
 * @title Basic token
 * @dev This ERC223 token is the most basic of them all ; the total amount of
    tokens are first created and stored in the contract's owner address.
 * @dev The total supply is created first ( it is capped ) and sent to different
    addresses during ICO
 */

 //TODO MAke sure burn and other are called through the parent.
contract token {
    HybridToken private _token;
    address private _owner;
    bool private _finalized = false;
    mapping(address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowance;
    function token(string symbol, string name, uint8 decimals, uint256 totalSupply)
    {
      _owner = msg.sender;
      if(totalSupply == 0)
      {
        _token= new mintable(symbol,name,decimals) ;
      }
      else if (totalSupply > 0)
      {
        _token= new basic(symbol,name,decimals,totalSupply);
      }
    }
    function get_address() returns (address)
    {
      return _token.get_address();
    }

    /*
     * @dev get balance of a tokens address
     * @params an address representing target wallet
     * @return A uint256 representing an address balance
     */
    function balanceOf(address addr) public view returns(uint256)
    {
      uint256 result = _token.balanceOf(addr);
      return result;
    }

    /*
     * @dev get total amount of tokens created
     * @return A uint256 representing the number oif tokens created.
     */
    function totalSupply() public view returns(uint256)
    {
      uint256 result = _token.totalSupply();
      return result;
    }

    /*
     * @dev get the tokens creator address
     * @return token creator's (owner) address
     */
    function getChildOwner() public returns(address)
    {
      address result = _token.getOwner();
      GetOwner(result);
      return result;
    }
    function getOwner() public returns(address)
    {
      return _owner;
    }
    /*
     * @dev transfer function that is called when user or a contract wants to transfer tokens.
     * @params to is the address tokens are being transferred to
     * @params amount is the amount of tokens being transfered
     * @params data is of type bytes that represents the message being sent
     * @return A uint8 representing token's decimals
     */
    function transfer(address sender, address receiver, uint256 amount, bytes data) public returns(bool)
    {
      bool result=_token.transfer(msg.sender,receiver,amount,data);
      if(result)
      {
        _balances[sender] = _balances[sender].sub(amount);

        //Add those tokens to reciever
        _balances[receiver] = _balances[receiver].add(amount);

        if (isContract(receiver)) {
            Receiver Receiverontract = Receiver(receiver);
            //Invoke the call back function on the reciever contract
            Receiverontract.tokenFallback(sender, amount, data);

        Transfer(msg.sender,receiver,amount ,data);
      }
      return result;
    }

    /*
     * @dev transfer function that is called when user or a contract wants to transfer tokens.
     * @dev it is identical to ERC20 Standard's transfer function
     * @params to is the address tokens are being transferred to
     * @params amount is the amount of tokens being transfered
     * @return A uint8 representing token's decimals
     */
    function transfer(address receiver, uint256 amount) public returns(bool)
    {
      bytes memory empty;
      bool result = _token.transfer(msg.sender,receiver,amount);
      if(result)
      {
        Transfer( msg.sender,receiver,amount,empty);
      }
      return result;
    }

   /*
    * @dev transfer function that is called when user or contract wants to transfer tokens in ERC20 implementation
    */

    function transferfrom(address sender, address receiver, uint amount) public returns (bool){
      bool result = _token.transferfrom(sender,receiver,amount);
      if (result)
      {
        Transferfrom(sender, receiver, amount);
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
      }
      return result;
    }

    function approve (address _spender, uint _value) public returns (bool){
      bool result = _token.approve(msg.sender, _spender, _value);
      if (result){
        _allowance[msg.sender][_spender].add(_value);
      }
      return result;


    }

  /* function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  } */

    function allowance (address _owner, address _spender) public constant returns (uint){
      uint result = _token.allowance(_owner, _spender);
      return result;

    }


    function mint(address receiver, uint256 amount) public returns(bool)
    {
      // only owner can mint
      if(msg.sender!=_owner)
      {
        revert();
      }
      else if(_finalized==true)
      {
        revert();
      }
      else
      {
        bool result = _token.mint(address(this),receiver,amount);
        if(result)
        {
          Mint(receiver, amount);
        }
        return result;
      }
    }



    /*
     * @dev this is the function that is called when tokens are being burnt
     * @params amount is of type uint 256 representingnumber of tokens being burnt
     * @return a boolean alue indication success or failure of the operation
     */
    function burn(uint256 amount) public onlyOwner returns(bool)
    {
      bool result = _token.burn(msg.sender,amount);
      if(result)
      {
        Burn(msg.sender, amount);
      }
      return result;
    }


    function finalize() public onlyOwner returns (bool)
    {
      if(msg.sender!=_owner)
      {
        revert();
      }
      else if(_finalized==true)
      {
        revert();
      }
      else
      {
        _finalized=true;
        uint256 remaining = _token.balanceOf(address(this));
        _token.burn(address(this),remaining);
        return true;
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



    //Events
    event TotalSupply(uint256 totalSupply);
    event BalanceOf(address addr, uint256 balance);
    event Burn(address indexed receiver, uint256 amount);
    event Transfer(address indexed sender, address indexed receiver, uint256 amount, bytes data);
    event GetOwner(address indexed owner);
    event Mint(address indexed receiver, uint256 amount);
    event Transferfrom(address from, address to, uint amount);
    event Approval (address _owner, address _spender, uint value);
    event Allowance (address _owner, address _spender);

}
