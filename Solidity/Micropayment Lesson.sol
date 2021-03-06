pragma solidity >=0.4.24 <0.7.0;

contract ReceiverPays {
    address owner = msg.sender;

    mapping(uint256 => bool) usedNonces;

    constructor() public payable{}

      function claimPayment(uint256 amount, uint256 nonc, bytes memory signature) public {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;

        //this recreates the message that was signed on the client
        byted32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nounce, this)));

        require(recoverSigner(message, signature) == owner);

        msg.sender.transfer(amount);
      }
      ///Destroy the contract and reclaim the leftover funds.
      function kill() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
      }

      ///Signature methods.
      function splitSignature(bytes memmory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)

        {
          require(sig.length == 65);

          assembly {
            //First 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            //Second 32 bytes.
            s := mload(add(sig,64))
            //final byte (First byte of the next 32 bytes)
            v := byte(0, mload(add(sig,96)))
          }
          return (v,r,s);

        }

        function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
        {
          (uint8 v, bytes32 r, bytes32 s) = splitsSignature(sig);

          return ecrecover(message, v, r, s);
        }
        /// builds a prefixed hash to mimic the behavior of eth_sign.
        function prefix(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abit.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
}
