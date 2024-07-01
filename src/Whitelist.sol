// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Whitelist {
    uint256 private s_count;
    State private state;
    mapping(address => bool) s_supporters;
    uint256 ENTRANCE_FEE = 0.01 ether;
    uint256 immutable MAX_SUPPORTERS = 10;

    error WhiteList_Closed();
    error Value_Less_Than_Entrance_Fee();
    error User_Already_In_WhiteList();

    event NewSupporter(address indexed user);
    event MaxLimitOfWhiteListReached();

    enum State {
        OPEN,
        CLOSED
    }

    constructor() {
        s_count = 0;
        state = State.OPEN;
    }

    function support() external payable {
        if (state != State.OPEN) revert WhiteList_Closed();
        if (msg.value < ENTRANCE_FEE) revert Value_Less_Than_Entrance_Fee();
        if (s_supporters[msg.sender]) revert User_Already_In_WhiteList();

        s_supporters[msg.sender] = true;
        s_count++;
        emit NewSupporter(msg.sender);

        if (s_count == MAX_SUPPORTERS) {
            state = State.CLOSED;
            emit MaxLimitOfWhiteListReached();
        }
    }

    function isSupporter(address user) external view returns (bool) {
        return s_supporters[user];
    }

    function numSupporters() public view returns (uint256) {
        return s_count;
    }

    function maxSupporterLimit() public pure returns (uint256) {
        return MAX_SUPPORTERS;
    }
}
