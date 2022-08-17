@@ -1,48 +1,39 @@

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.8.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Marketplace {

    uint internal passLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address public adminAddress;

    using SafeMath for uint;
    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address public owner;

    struct Product {
    struct Pass {
        address payable owner;
        string name;
        string image;
@@ -53,36 +44,66 @@ contract Marketplace {
        bool verified;
    }

    constructor(){
        adminAddress = msg.sender;
    constructor() {
        owner = msg.sender;
    }

    modifier exist(uint _index) {
        require(exists[_index], "Query of nonexistent pass");
        _;
    }
    modifier isVerified(uint _index) {
        require(pass[_index].verified == true, "this product is not verified");
        require(pass[_index].verified == true, "this pass is not verified");
        _;
    }

    modifier isAdmin() {
        require(msg.sender == adminAddress, "only callable by admin");
        require(admins[msg.sender], "only callable by admin");
        _;
    }

    mapping (uint => Product) public pass;
    /// @dev ensures that _address is valid
    modifier checkAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description,
        string memory _location,
    modifier onlyOwner() {
        require(
            owner == msg.sender,
            "Only the smart contract owner can do that"
        );
        _;
    }

    mapping(uint => Pass) public pass;
    mapping(uint => bool) public exists;
    mapping(address => bool) public admins;

    event NewAdmin(address admin);
    event RemovedAdmin(address admin);
    event PassBought(address seller, address user, uint index);
    event Verified(address admin, uint index);
    event UnVerified(address admin, uint index);

    /// @dev allows users to create a new pass
    function writePass(
        string calldata _name,
        string calldata _image,
        string calldata _description,
        string calldata _location,
        uint _price
    ) public {
    ) external {
        require(bytes(_image).length > 0, "Please enter a valid image URL");
        require(bytes(_description).length > 0, "Please enter a valid description");
        require(
            bytes(_description).length > 0,
            "Please enter a valid description"
        );
        require(bytes(_name).length > 0, "Please enter a valid name");
        require(_price > 0, "enter a valid price");
        uint _sold = 0;
        bool _verified = false;
        pass[passLength] = Product(
        pass[passLength] = Pass(
            payable(msg.sender),
            _name,
            _image,
@@ -92,35 +113,73 @@ contract Marketplace {
            _sold,
            _verified
        );
        passLength = passLength.add(1);
        exists[passLength] = true;
        passLength++;
    }

    function buyProduct(uint _index) public  payable isVerified(_index)  {
        require(pass[_index].owner != address(0), "enter a valid product index");
    /**
     *  @dev allows users to buy a pass from the marketplace
     *  @notice pass has to be verified first
     * */
    function buyPass(uint _index)
        external
        payable
        exist(_index)
        isVerified(_index)
    {
        Pass storage currentPass = pass[_index];
        require(currentPass.owner != address(0), "enter a valid pass index");
        require(currentPass.verified, "Pass hasn't been verified yet");
        require(currentPass.owner != msg.sender, "You can't buy your own pass");
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                pass[_index].owner,
                pass[_index].price
                currentPass.owner,
                currentPass.price
            ),
            "Transfer failed."
        );
        pass[_index].sold = pass[_index].sold.add(1);
        currentPass.sold++;
        emit PassBought(currentPass.owner, msg.sender, _index);
    }

    function getpassLength() public view returns (uint) {
        return (passLength);
    }


    //    admin can veridy a prodyct
    function verifyProduct(uint _index) public  isAdmin {
    /**
     * @dev allows the admin to verify a pass
     */
    function verifyPass(uint _index) public exist(_index) isAdmin {
        pass[_index].verified = true;
        emit Verified(msg.sender, _index);
    }

    /**
     * @dev allows the admin to unverify a pass in case of the pass being linked to malicious intent
     */
    function unVerifyPass(uint _index) public exist(_index) isAdmin {
        pass[_index].verified = false;
        emit UnVerified(msg.sender, _index);
    }

    /// @dev allows the owner to add an admin
    function addAdmin(address _admin) public checkAddress(_admin) onlyOwner {
        admins[_admin] = true;
        emit NewAdmin(msg.sender);
    }

    function revokeOwnership(address _address) public isAdmin {
        adminAddress = _address;
    /// @dev allows the owner to remove an admin
    function removeAdmin(address _admin) public checkAddress(_admin) onlyOwner {
        admins[_admin] = false;
        emit RemovedAdmin(msg.sender);
    }

    function revokeOwnership(address _address)
        public
        checkAddress(_address)
        onlyOwner
    {
        owner = _address;
    }
}
