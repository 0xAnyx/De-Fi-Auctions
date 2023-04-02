// SPDX-License-Identifier: None
pragma solidity ^0.8.12;

import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

contract EngAuction {

    event tokenListed(address nft, uint nftId, address seller, uint startingPrice);
    event successfullyBid(address nft, uint nftId, address indexed bidder, uint bidAmount);
    event auctionEnded(address nft, uint nftId, address buyer, uint sellingPrice);

    struct itemDetails {
        address seller;
        bool isListed;
        address highestBidder;
        uint highestBid;
        uint duration;
    }

    mapping (address => mapping (uint => itemDetails)) public aucDetails;
//    mapping (address => mapping (uint => mapping (address => uint))) public bids;

    function listNFT(address _nft, uint _nftId, uint _startingPrice) external {
        require(_nft != address(0), 'Invalid Nft Address');
        require(_startingPrice != 0, 'Base Price cannot be zero');
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(_nftId) == msg.sender, 'Caller not owner');
        aucDetails[_nft][_nftId] = itemDetails(msg.sender, true, address(0), _startingPrice, 1 days);
        nft.transferFrom(msg.sender, address(this), _nftId);
        emit tokenListed(_nft, _nftId, msg.sender, _startingPrice);
    }

    function bid(address _nft, uint _nftId) external payable {
        require(_nft != address(0), 'Invalid Nft Address');
        itemDetails storage token = aucDetails[_nft][_nftId];
        require(token.isListed, 'Token not listed');
        require(msg.value > token.highestBid, 'Bid more than highest bid');
        require(block.timestamp <= token.duration, 'Bidding time over');
        require(token.highestBidder != msg.sender, "Can't raise self bid");
        uint currentBid = aucDetails[_nft][_nftId].highestBid;
        uint currentBidder = aucDetails[_nft][_nftId].highestBidder;
        aucDetails[_nft][_nftId].highestBid = msg.value;
        aucDetails[_nft][_nftId].highestBid = msg.sender;
//        bids[_nft][_nftId][msg.sender] += msg.value;
        if (currentBidder != address(0)) {
            (bool success, bytes memory data) = currentBidder.call{value: currentBid}("");
            require(success, 'Failed to transfer Ether');
        }
        emit successfullyBid(_nft, _nftId, msg.sender, msg.value);
    }

//    function withdrawOnGettingOutbidden(address _nft, uint _nftId) external {
//        require(_nft != address(0), 'Invalid Nft Address');
//        itemDetails storage token = aucDetails[_nft][_nftId];
//    }
    function endAuction(address _nft, uint _nftId) external {
        require(_nft != address(0), 'Invalid Nft Address');
        itemDetails storage token = aucDetails[_nft][_nftId];
        require(token.isListed, 'Token not listed');
        require(block.timestamp > token.duration, 'Auction in progress');

        address memory highestBidder = token.highestBidder;

        if(highestBidder != address (0)) {
            IERC721(_nft).transferFrom(address(this), highestBidder, _nftId);
            payable(token.seller).transfer(token.highestBid);
        }
        else
            IERC721(_nft).transferFrom(address(this), token.seller, _nftId);
        emit auctionEnded(_nft, _nftId, highestBidder, token.highestBid);
    }
    
}