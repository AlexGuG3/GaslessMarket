// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../lib/OwnableUpgradeable.sol";
import "../erc4907/IERC4907.sol";
import "../erc4907/wrap/IWrapNFT.sol";
import "../erc4907/wrap/IWrapNFTUpgradeable.sol";

abstract contract W4907Factory is OwnableUpgradeable {
    event DeployW4907(
        address w4907,
        string name,
        string symbol,
        address originalAddress
    );

    address public w4907Impl;
    mapping(address => address) public oNFT_w4907;

    function _initW4907(address w4907Impl_) internal {
        require(w4907Impl == address(0));
        w4907Impl = w4907Impl_;
    }

    function setW4907Impl(address w4907Impl_) public onlyAdmin {
        w4907Impl = w4907Impl_;
    }

    function _deployW4907(
        string memory name,
        string memory symbol,
        address originalAddress
    ) internal returns (address w4907) {
        require(
            IERC165(originalAddress).supportsInterface(
                type(IERC721).interfaceId
            ),
            "not ERC721"
        );
        require(
            !IERC165(originalAddress).supportsInterface(
                type(IERC4907).interfaceId
            ),
            "the NFT is IERC4907 already"
        );
        w4907 = Clones.clone(w4907Impl);
        IWrapNFTUpgradeable(w4907).initialize(
            name,
            symbol,
            originalAddress,
            address(this)
        );
        emit DeployW4907(address(w4907), name, symbol, originalAddress);
    }

    function deployW4907(
        string memory name,
        string memory symbol,
        address oNFT
    ) public {
        require(oNFT_w4907[oNFT] == address(0), "w4907 is already exists");
        address w4907 = _deployW4907(name, symbol, oNFT);
        oNFT_w4907[oNFT] = w4907;
    }

    function registerW4907(
        address oNFT,
        address w4907
    ) public onlyAdmin {
        require(oNFT_w4907[oNFT] == address(0), "w4907 is already exists");
        require(
            IERC165(w4907).supportsInterface(type(IWrapNFT).interfaceId),
            "not wNFT"
        );
        require(
            IERC165(w4907).supportsInterface(type(IERC4907).interfaceId),
            "not ERC4907"
        );
        require(IWrapNFT(w4907).originalAddress() == oNFT, "invalid oNFT");
        oNFT_w4907[oNFT] = w4907;
    }

    function w4907Of(address oNFT) public view returns (address) {
        return oNFT_w4907[oNFT];
    }
}
