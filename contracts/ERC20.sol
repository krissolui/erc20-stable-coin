// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract ERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // function name() public view returns (string) {}
    string public name;
    // function symbol() public view returns (string) {}
    string public symbol;
    // function decimals() public view returns (uint8) {}
    uint8 public immutable decimals;
    // function totalSupply() public view returns (uint256) {}
    uint256 public totalSupply;

    // function balanceOf(address _owner) public view returns (uint256 balance) {}
    mapping(address => uint256) public balanceOf;
    // function allowance(address _owner, address _spender) public view returns (uint256 remaining) {}
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public virtual returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (_from != msg.sender) {
            require(
                allowance[_from][msg.sender] >= _value,
                "ERC20: Insufficient allowance."
            );
            allowance[_from][msg.sender] -= _value;
        }

        require(
            balanceOf[_from] >= _value,
            "ERC20: Insufficient sender balance."
        );

        emit Approval(_from, msg.sender, allowance[_from][msg.sender]);

        return _transfer(_from, _to, _value);
    }

    function approve(
        address _spender,
        uint256 _value
    ) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    // function mint(address _to, uint256 _value) external payable virtual {
    //     require(msg.value >= 1.5 ether, "ERC20: Insufficient mint price.");
    //     _mint(_to, _value);
    // }

    // function deposit() external payable {
    //     return _mint(msg.sender, msg.value);
    // }

    // function redeem(
    //     address _owner,
    //     uint256 _value
    // ) external payable returns (bool) {
    //     transferFrom(_owner, msg.sender, _value);
    //     (bool success, ) = address(msg.sender).call{value: _value}("");
    //     return success;
    // }

    /**
     * Helper functions
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool) {
        require(
            balanceOf[_from] >= _value,
            "ERC20: Insufficient sender balance."
        );

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function _mint(address _to, uint256 _value) internal {
        balanceOf[_to] += _value;
        totalSupply += _value;

        emit Transfer(address(0), _to, _value);
    }

    function _burn(address _from, uint256 _value) internal {
        balanceOf[_from] -= _value;
        totalSupply -= _value;

        emit Transfer(_from, address(0), _value);
    }
}
