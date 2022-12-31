// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    // getAddressSlot : return the pointer to storage 'r' located at 'slot' input.
    function getAddressSlot(bytes32 slot) internal pure returns(AddressSlot storage r){
        assembly {
            // get the storage pointer at the 'slot' from the input
            r.slot := slot
        }
    }

}

contract Proxy {

    // Implementation address variable commonly stored in eip1967.proxy.implementation to avoid clashes in storage usage
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(
        uint(keccak256("eip1967.proxy.implementation")) - 1
    );

    // Admin address variable commonly stored in eip1967.proxy.admin to avoid clashes in storage usage
    bytes32 private constant ADMIN_SLOT = bytes32(
        uint(keccak256("eip1967.proxy.admin")) - 1
    );

    // modifier ifAdmin to enforce caller is Proxy Admin contract. Protect Proxy functions & prevent function-clashing.
    modifier ifAdmin() {
        if(msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    constructor() {
        _setAdmin(msg.sender);
    }

    // Proxy contract function protected by admin-only & called by Proxy Admin contract
    function upgradeTo(address _implementationAddr) external ifAdmin {
        _setImplementation(_implementationAddr);
    }

    // Proxy contract function protected by admin-only & called by Proxy Admin contract
    function changeAdmin(address _newAdmin) external ifAdmin {
        _setAdmin(_newAdmin);
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    // Internal fallback() to call in both fallback() & receive()
    function _fallback() private {
        _delegate(_getImplementation());
    }

    // Internal _delegate to access return data from delegatecall
    function _delegate(address _impl) private {
        // copied from openzeppelin transparent upgradeable proxy docs
        assembly {
      
            let ptr := mload(0x40)

            // (1) copy incoming call data
            calldatacopy(ptr, 0, calldatasize())

            // (2) forward call to logic contract
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()

            // (3) retrieve return data
            returndatacopy(ptr, 0, size)

            // (4) forward return data back to caller
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        
        }
    }

    // Internal _setAdmin for setting/updating 'admin' variable in designated storage slot
    function _setAdmin(address _admin) private {
        require(_admin != address(0), "Zero addr");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    // Internal _setImplementation for setting/updating 'implementation' variable in designated storage slot
    function _setImplementation(address _impl) private {
        require(_impl.code.length > 0 , "Not contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _impl;
    }

    // Internal _getAdmin() for accessing storage slot of 'admin' variable
    function _getAdmin() private view returns(address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    // Internal _getImplementation() for accessing storage slot of 'implementation' variable
    function _getImplementation() private view returns(address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    // Proxy contract function protected by admin-only & called by Proxy Admin contract
    function admin() external ifAdmin returns(address) {
        return _getAdmin();
    }

    // Proxy contract function protected by admin-only & called by Proxy Admin contract
    function implementation() external ifAdmin returns(address) {
        return _getImplementation();
    }
}