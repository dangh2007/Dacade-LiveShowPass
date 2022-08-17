// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Marketplace {
    uint internal passLength = 0;
    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address public owner;

    struct Pass {
        address payable owner;
        string name;
        string image;
        string description;
        string location;
        uint price;
        uint sold;
        bool verified;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier exist(uint _index) {
        require(exists[_index], "Query of nonexistent pass");
        _;
    }
    modifier isVerified(uint _index) {
        require(pass[_index].verified == true, "this pass is not verified");
        _;
    }

    modifier isAdmin() {
        require(admins[msg.sender], "only callable by admin");
        _;
    }

    /// @dev ensures that _address is valid
    modifier checkAddress(address _address) {
        require(_address != address(0), "Invalid address");
        _;
    }

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
    ) external {
        require(bytes(_image).length > 0, "Please enter a valid image URL");
        require(
            bytes(_description).length > 0,
            "Please enter a valid description"
        );
        require(bytes(_name).length > 0, "Please enter a valid name");
        require(_price > 0, "enter a valid price");
        uint _sold = 0;
        bool _verified = false;
        pass[passLength] = Pass(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold,
            _verified
        );
        exists[passLength] = true;
        passLength++;
    }

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
                currentPass.owner,
                currentPass.price
            ),
            "Transfer failed."
        );
        currentPass.sold++;
        emit PassBought(currentPass.owner, msg.sender, _index);
    }

    function getpassLength() public view returns (uint) {
        return (passLength);
    }

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
