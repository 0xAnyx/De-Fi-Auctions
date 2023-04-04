// SPDX-License-Identifier: None
pragma solidity ^0.8.12;

import { IERC721 } from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

contract EngAuction {

    uint public totalAuctionIds;

    event tokenListed(address _nft, uint _nftId, address seller, uint startingPrice);
    event successfullyBid(uint auctionId, address indexed bidder, uint bidAmount);
    event successfullyWithdrawn(uint auctionId, address indexed withdrawer, uint amount);
    event auctionEnded(uint auctionId, address buyer, uint sellingPrice);

    struct bidDetails {
        address seller;
        bool isListed;
        address highestBidder;
        uint highestBid;
        uint duration;
        address nftAddress;
        uint nftId;
    }

    mapping (uint => bidDetails) public auctionDetails;
    mapping (bytes => uint) public getAuctionId;
    mapping (address => mapping(uint => uint)) public bids;

    function listNFT(address _nft, uint _nftId, uint _startingPrice) external {
        require(_nft != address(0), 'Invalid Nft Address');
        require(_startingPrice != 0, 'Base Price cannot be zero');
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(_nftId) == msg.sender, 'Caller not owner');
        getAuctionId[convertNftDetailsToBytes(_nft,_nftId)] = totalAuctionIds + 1;
        auctionDetails[totalAuctionIds + 1] = bidDetails(msg.sender, true, address (0),
            _startingPrice, 1 days, _nft, _nftId);
        totalAuctionIds += 1;
        nft.transferFrom(msg.sender, address(this), _nftId);
        emit tokenListed(_nft, _nftId, msg.sender, _startingPrice);
    }

    // @notice Add the incremental bid on top of the highest bid and not the sum total
    function bid(uint _auctionId) external payable {
        bidDetails storage token = auctionDetails[_auctionId];
        require(token.isListed, 'Token not listed');
        require(msg.value != 0, 'Cannot be 0');
        require(msg.value > token.highestBid, 'Bid more than highest bid');
        require(block.timestamp <= block.timestamp + token.duration, 'Bidding time over');
        require(token.highestBidder != msg.sender, "Can't raise self bid");
        auctionDetails[_auctionId].highestBid += msg.value;
        auctionDetails[_auctionId].highestBidder = msg.sender;
        bids[msg.sender][_auctionId] += msg.value;
        emit successfullyBid(_auctionId, msg.sender, msg.value);
    }

    function withdrawBidOnGettingOutbidden(uint _auctionId) external {
        bidDetails storage token = auctionDetails[_auctionId];
        require(token.isListed, 'Token not listed');
        require(msg.sender != token.highestBidder, "Highest bidder can't withdraw bid");
        uint bidAmount = bids[msg.sender][_auctionId];
        bids[msg.sender][_auctionId] = 0;
        payable(msg.sender).transfer(bidAmount);
        emit successfullyWithdrawn(_auctionId, msg.sender, bidAmount);
    }

    function endAuction(uint _auctionId) external {
        bidDetails storage token = auctionDetails[_auctionId];
        require(token.isListed, 'Token not listed');
        require(block.timestamp > block.timestamp + token.duration, 'Auction in progress');
        address highestBidder = token.highestBidder;
        if(highestBidder != address (0)) {
            IERC721(token.nftAddress).transferFrom(address(this), highestBidder, token.nftId);
            payable(token.seller).transfer(token.highestBid);
        }
        else
            IERC721(token.nftAddress).transferFrom(address(this), token.seller, token.nftId);
        emit auctionEnded(_auctionId, highestBidder, token.highestBid);
    }

    function convertNftDetailsToBytes(address _nft, uint _nftId) private returns(bytes memory) {
        bytes memory converted = abi.encodePacked(_nft,_nftId);
        return converted;
    }

}