pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

/*
************ SafeMath ******************
*/
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/* 
************* Owner ********************* 
*/
contract Owner {
     modifier onlyOwner(address owner) {
        require(
            msg.sender == owner,
            "Permission denied"
        );
        _;    
    }
}

/* 
************ People ********************* 
*/
contract People is Owner {
    struct Person {
        address owner;
        string name;
        string homeAddr;
        uint32 phoneNumber;
        uint8 age;
        uint8 Type; // 1 is employer, 2 is buyer default is employer
    }
    
    mapping(address => Person) persons;
    
    
    function register(
        address _owner, 
        string _name, 
        string _homeAddr, 
        uint32 _phoneNumber,
        uint8 _age,
        uint8 _Type) 
        internal {
            require(persons[_owner].owner == 0);
            Person memory newPerson = Person(_owner, _name, _homeAddr, _phoneNumber, _age, _Type);
            persons[_owner] = newPerson;
    }
    
    function detailAccount(address _owner) public view onlyOwner(persons[msg.sender].owner) returns(Person) {
        return persons[_owner];
    } 
}

/*
********* Products *********
*/
contract Products is Owner {
    
    struct Product {
        uint64 id;
        uint64 MFG; // manufacturing date
        uint64 EXP; // expire date
        uint8 state; // default 100%
        string name;
    }    
    
    mapping(uint64 => Product) products;
    address private owner;
 
    Product[] products2;    
    constructor() {
        owner = msg.sender;
    }
    
    function createProduct(
        uint64 _id, 
        uint64 _MFG, 
        uint64 _EXP, 
        uint8 _state, 
        string _name) public onlyOwner(owner) {
        require(products[_id].id == 0);
        Product memory newProduct = Product(_id, _MFG, _EXP, _state, _name);
        products[_id] = newProduct;
        products2.push(newProduct);
    }
    
     function productsDetail(uint64 _id) public view returns(Product) {
        return products[_id];
    }
    
    function getAllProduct() public view returns(Product[]){
        return products2;
    }
}
/*
************** IERC20 *****************
*/
interface IBank {

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);
  
  function deposit(uint256 value) external returns(bool);
  
  function withDraw(uint256 value) external returns(bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );
}

/*
******************** Bank *******************
*/
contract Bank is Owner {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    struct Transaction {
        address root;
        address destination;
        uint balance;
        bool confirmed;
    }

    mapping(uint => Transaction) transaction;
    uint numberOfTransactions;

    modifier notConfirmed(uint _identifer) {
        Transaction storage _trans = transaction[_identifer];
        require(!_trans.confirmed);
        _;
    }

    modifier notExists(uint _identifer) {
        Transaction storage _trans = transaction[_identifer];
        require(_trans.balance == 0 && _trans.destination == 0x0);
        _;
    }

    modifier onlyHumanOfBenefit(uint _identifier) {
        Transaction storage _trans = transaction[_identifier];
        if(_trans.root != _trans.destination) {
            require(_trans.root == msg.sender);
        }
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    // Check balance of an account.
    function balanceOf(address addr) constant external returns (uint) {
        return balances[addr];
    }
    
    function balance() constant external returns (uint) {
        return balances[msg.sender];
    }
    
    // Deposit ethers to sender's account.
    function deposit() external payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
    
    function withDraw(address _warranty) external returns (bool){
        var benefit = Warranty(_warranty).getBenefit();
        require(msg.sender == benefit.receiver);
        submitTransaction(numberOfTransactions, benefit.sender, benefit.receiver, benefit.balance);
        return true;
    }

    function submitTransaction(uint _identifier, address _from, address _to, uint _value) notExists(_identifier) internal returns(bool) {
        Transaction memory _trans = Transaction(_from, _to, _value, false);
        transaction[_identifier] = _trans;
        numberOfTransactions = numberOfTransactions.add(1);
        return true;
    }

    function confirmTransaction(uint _identifier, bool _status) onlyHumanOfBenefit(_identifier) notConfirmed(_identifier) public returns (bool) {
        Transaction storage _trans = transaction[_identifier];
        _trans.confirmed = _status;

        if(_status && balances[_trans.root] >= _trans.balance) {
            balances[_trans.root] = balances[_trans.root].sub(_trans.balance);
            _trans.destination.transfer(_trans.balance);
        }

        if (!deleteTransaction(_identifier)) {
            return false;
        }

        return true;
    }

    function deleteTransaction(uint transactionId) internal returns (bool){
        delete transaction[transactionId];
        return true;
    }
    
    function() external payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
    
    function kill() onlyOwner(owner) public {
        selfdestruct(owner);
    }
}


/*
****************** Warranty *******************
*/
contract Warranty is People {
    
    struct Convention {
        uint64 expireTime;
        uint64 idProduct;
        uint compensation;
        address employer;
        address buyer;
        string signatureEmployer;
        string signatureBuyer;
    }
    
    Convention public convention;

    address bankAddr = 0x0;
    
    struct BenefitOfHuman {
        address sender;
        address receiver;
        uint balance;
    }
    
    BenefitOfHuman public benefit;
    
    bool private isSignaturePurchase = false;
    bool private isSignatureSell = false;

    modifier onlyFromOurBank() {
        require(msg.sender == bankAddr);
        _;
    }
    
    constructor(
        string _userName, 
        string _homeAddr,
        uint32 _phoneNumber,
        uint8 _age,
        uint8 _Type) public {
            register(msg.sender, _userName, _homeAddr, _phoneNumber, _age, _Type);
    }
    
    function initWarranty(
        uint64 _expireTime, 
        uint _compensation,
        uint64 _idProduct
        ) public onlyOwner(persons[msg.sender].owner) {
        require(!isSignaturePurchase && !isSignatureSell);
        convention = Convention(_expireTime, _idProduct, _compensation, msg.sender, 0x0, "", "");
    }
    
    function createParnter(
        address _buyer,
        string _userName, 
        string _homeAddr,
        uint32 _phoneNumber,
        uint8 _age,
        uint8 _Type) public onlyOwner(persons[msg.sender].owner) {
            require(!isSignaturePurchase && !isSignatureSell);
            register(_buyer, _userName, _homeAddr, _phoneNumber, _age, _Type);
            convention.buyer = _buyer;
    }
    
    function sell(
        string _signatureEmployer
        ) public onlyOwner(persons[msg.sender].owner) {
            require(!isSignaturePurchase || !isSignatureSell);
            require(persons[msg.sender].Type == 1);
            convention.signatureEmployer = _signatureEmployer;
            isSignatureSell = true;
    }
    
    function purchase(
        string _signatureBuyer
        ) public onlyOwner(persons[msg.sender].owner) {
            require(!isSignaturePurchase || !isSignatureSell);
            require(persons[msg.sender].Type == 2);
            convention.signatureBuyer = _signatureBuyer;
            isSignaturePurchase = true;
    }
    
    
    function courts(address _productsContract) public returns(string){
        //detail products
        var p = Products(_productsContract).productsDetail(convention.idProduct);
      
        if(p.state == 0 && now < convention.expireTime) {
            benefit = BenefitOfHuman(convention.employer , convention.buyer, convention.compensation);
            return "Buyer can with draw money from Employer";
        }
        
        if(now > convention.expireTime && p.state >= 90) {
            benefit = BenefitOfHuman(convention.employer, convention.employer, convention.compensation);
            return "Employer can with draw money from Contract";
        }
        return "Dont do something";
    }
    
    function verifyWarranty(
        address _owner, 
        bytes32 _hash, 
        bytes32 r, 
        bytes32 s,
        uint8 v) external pure returns(bool){
        require(_owner != address(0x0));
        bytes32 _recoverHash = prefixed(_hash);
        address _temp = ecrecover(_recoverHash, v, r, s);
        return _temp == _owner;
    }
    
    function prefixed(bytes32 _hash) internal pure returns (bytes32) {
        return keccak256("\x19Ethereum Signed Message:\n32", _hash);
    }
    
    function getBenefit() onlyFromOurBank() public view returns(BenefitOfHuman) {
        return benefit;
    }
}

/*
****************** Ledger *************************
*/
contract Ledger is Owner {
    address private owner;
    struct History {
        address Warranty;
    }
    
    mapping(address => History[]) private histories;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function saveHistory(address _warranty) public onlyOwner(owner) {
        History memory newData = History(_warranty);
        histories[msg.sender].push(newData);
    }
    
    function getHistory() public view onlyOwner(owner) returns(History[]) {
        return histories[msg.sender];
    }
}