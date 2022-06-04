// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract VerifySig {
    function verify(
        address _signer,
        string memory message,
        bytes memory _sig
    ) external pure returns (bool) {
        bytes32 hash = getMessageHash(message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(hash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory message)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(message));
    }

    function getEthSignedMessageHash(bytes32 hash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function recover(bytes32 _ethHash, bytes memory _sig)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethHash, v, r, s);
    }

    function _split(bytes memory _sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        assert(_sig.length == 65);

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}
