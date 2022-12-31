// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Proxy.sol";

// Proxy Admin contract: only contract allowed to call Proxy functions
// All User calls made to Proxy.sol directed to fallback()/receive() functions

contract ProxyAdmin is Ownable {

    // changeProxyAdmin : update the admin variable for the Proxy contract
    // we declare _proxy as 'payable' because the Proxy contract has fallback() & receive() functions
    function changeProxyAdmin(address _newAdmin, address payable _proxy) external onlyOwner {
        Proxy(_proxy).changeAdmin(_newAdmin);
    }

    // upgrade : update the Implementation variable for the Proxy contract
    function upgrade(address payable _proxy, address _impl) external onlyOwner {
        Proxy(_proxy).upgradeTo(_impl);
    }

    function getProxyAdmin(address _proxy) external view returns(address) {
        // staticcall is like call except it does not write anything into the blockchain.
        // The call to encode is "Proxy.admin" which takes zero input so we pass in empty parenthesis.
       (bool ok, bytes memory res) = _proxy.staticcall(abi.encodeCall(Proxy.admin, () ));
       require(ok, "Failed");
       return abi.decode(res, (address));
    }

    function getProxyImplementation(address _proxy) external view returns(address) {
        // staticcall is like call except it does not write anything into the blockchain.
        // The call to encode is "Proxy.implementation" which takes zero input so we pass in empty parenthesis.
       (bool ok, bytes memory res) = _proxy.staticcall(abi.encodeCall(Proxy.implementation, () ));
       require(ok, "Failed");
       return abi.decode(res, (address));
    }
}