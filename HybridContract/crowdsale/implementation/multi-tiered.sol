pragma solidity ^0.4.18;
import "../../libraries/SafeMath.sol";
import "../interface/crowdsale-interface.sol";
import "../../tokens/token.sol";

contract multitier is crowdsaleInterface{

  using SafeMath for uint256;

  uint256 private _StartTime;
  uint256 private _EndTime;
  uint256 private _Rate;
  uint256 private _Cap;
  uint256 private _WeiRaised;
  uint256 private _TokenSold;
  address private _Owner;
  token private _Token;
  bool private _Finalized = false;

  function multitier(uint256 Starttime, uint256 Endtime, uint256 Rate, string Name, string Symbol, uint8 decimals, uint256 TotalSupply, uint256 Cap)public
  { if (Starttime < now){
    revert();
  }else if (Endtime < now || Endtime < Starttime){
    revert();
  }else {
    _StartTime = Starttime;
    _EndTime = Endtime;
    _Cap = Cap;
    _Rate = Rate;
    _TokenSold = 0;
    _WeiRaised = 0;
    _Owner = msg.sender;
    _Token = new token(symbol, name, decimals, totalsupply);

  }

  function buyTokens(address reciever, uint256 weiAmount) public onlyOwner isFinalized returns(uint256)
  {
    validPurchase();
    if(receiver == 0x0){
      revert();
    }else if (receiver == address(0)){
      revert();
    }else {
      if (now <= _StartTime.mul(1.3)){

        _WeiRaised += weiAmount;  // equlivilant _WeiRaised = _WeiRaised + weiAmount;
        uint256 rate = getRate();
        uint256 tokens = weiAmount.mul(rate);
        _TokenSold += tokens;
        if(_TokenSold > _Cap){
          revert();
        }else {
          _Token.mint(receiver, tokens);
          return tokens;
        }


    }


  function finalize() public onlyOwner isFinalized returns (bool)
  {
    if (now < _EndTime){
      revert();
    }else{
      _Token.finalize();
      _Finalized = true;
      return true;
    }
  }

  function getToken() public onlyOwner Omar returns(address)
  {
    return address(_Token);
  }

  function getOwner() public onlyOwner returns (address)
  {
    return _Owner;
  }

  function getAddress() public onlyOwner returns (address)
  {
    return address(this);
  }

  function getRate() public onlyOwner returns(uint256){
    uint256 x  = (_StartTime.add(_EndTime)).div(4);
    if (now >= _StartTime && now < _StartTime.add(x)){
      return _Rate.mul(1.6); // for 10 dollars, you would get 16 dollars worth of wavlie
    }else if (now >= _StartTime.add(x) && now < _StartTime.add(x.mul(2))){
      return _Rate.mul(1.3);
    }else if (now >= _StartTime.add(x.mul(2)) && now < _StartTime.add(x.mul(3))){
      return _Rate.mul(1.2);
    }else if (now >= _StartTime.add(x.mul(3)) && now < _StartTime.add(x.mul(4))){
      return _Rate.mul(1); // for 10 dollars, you would get 10 dollars worth of value
    }else {
      return 0
    }
  }

  function validPurchase() internal view returns(bool){ //here the view option only lets you view the content but are not able to change it
    if (now < _StartTime){
      revert();
    }else if (now > _EndTime){
      revert();
    } else if (_StartTime >= _EndTime){
      revert();
    }else if (_Finalized != false){
      revert();
    }else if(_WeiRaised > _Cap){
      revert();
    }else {
      return true;
    }
  }

  modifier onlyOwner{
    if(msg.sender!= _Owner){
      revert();
    }else
     {
      _;
    }
  }
  modifier omar{
    if (msg.sender == address(omar)){
      _;
    }
  }

  modifier isFinalized{
    if(_Finalized != false){
      revert();
    }else {
      _;
    }
  }




}
