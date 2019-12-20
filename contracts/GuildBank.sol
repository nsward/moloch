pragma solidity 0.5.3;

import "./oz/ERC20Wrapper.sol";

contract GuildBank  {
    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event Withdrawal(address indexed receiver, address indexed tokenAddress, uint256 amount);

    function withdraw(address receiver, uint256 shares, uint256 totalShares, address[] memory approvedTokens) public onlyOwner returns (bool) {
        for (uint256 i = 0; i < approvedTokens.length; i++) {
            uint256 amount = fairShare(ERC20Wrapper.balanceOf(approvedTokens[i], address(this)), shares, totalShares);
            emit Withdrawal(receiver, approvedTokens[i], amount);
            ERC20Wrapper.transfer(approvedTokens[i], receiver, amount);
        }
        return true;
    }

    function withdrawToken(address token, address receiver, uint256 amount) public onlyOwner returns (bool) {
        emit Withdrawal(receiver, token, amount);
        return ERC20Wrapper.transfer(token, receiver, amount);
    }

    function fairShare(uint256 balance, uint256 shares, uint256 totalShares) internal pure returns (uint256) {
        require(totalShares != 0);

        if (balance == 0) { return 0; }

        uint256 prod = balance * shares;

        if (prod / balance == shares) { // no overflow in multiplication above?
            return prod / totalShares;
        }

        return (balance / totalShares) * shares;
    }

}
