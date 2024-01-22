import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";


// SDPX-License-Identifier: MIT

pragma solidity ^0.8.7;





error RandomIpfsNft_RangeOutOfBounds();
error RandomIpfsNft__NeedMoreETHSent();
error RandomIpfsNft_TransferFailed();

contract RandomIpfsNft is VRFConsumerBaseV2,ERC721URIStorage, Ownable{


// Type Delclartion
enum Breed{
    PUG,
    SHIBA_INU,
    ST_BERNARD
}

 VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
 uint64 private immutable i_subscriptionId;
 bytes32 private immutable i_gasLane;
 uint32 private immutable i_callbackGasLimit;
 uint16 private constant REQUEST_CONFIRMATIONS = 3;
 uint32 private constant NUM_WORDS = 1;



// VRF Helpers
mapping(uint256 => address) public s_requestIdToSender;



//NFT Variables
uint256 public s_tokenCounter;
uint256 internal constant MAX_CHANCE_VALUE = 100;
string [] internal s_dogTokenUris;
uint256 internal i_mintFee;

// Events 
event NftRequested(uint256 indexed requestId, addres requester);
event NftMinted(Breed dogBreed, address minter);



constructor(
    address vrfCoordinatorV2, 
    uint64 subscriptionId, 
    bytes32 gasLane, 
    uint32 callbackGasLimit,
    string[3] memory s_dogTokenUris,
    uint256 mintFee
) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721 ("Random IPFS NFT", "RIN"){
    i_vrfCoordinator = VRFCoordinatorV2Interface (vrfCoordinatorV2);
    i_subscriptionId = subscriptionId;
    i_gasLane = gasLane;
    i_callbackGasLimit = callbackGasLimit;
    s_dogTokenUris = dogTokenUris;
    i_mintFee = mintFee;
}

function requestNft () public payable returns (uint256 requestId) {
    if (msg.value < i_mintFee){
        revert RandomIpfsNft__NeedMoreETHSent();
    }
    requestId = i_vrfCoordinator.requestRandomWords(
        i_gaslane,
        i_subscriptionId,
        REQUEST_CONFIRMATIONS,
        i_callbackGasLimit,
        NUM_WORDS   
    );
    s_requestIdToSender(requestId) = msg.sender;
    emit NftRequested(requestId, msg.sender);


}


function fulfillRandomWords (uint256 requestId, uint256[] memory randomWords)  internal override
 {
    address dogOwner = s_requestIdToSender[requestId];
    uint256 newTokenId = s_tokenCounter;
   
    
    uint256 moddedRng = randomWords[0] %MAX_CHANCE_VALUE;


    Breed dogBreed = getBreedFromModdedRng(moddedRng);
     _safeMint(dogOwner, newTokenId);
     _setTokenURI(newTokenID, s_dogTokenUris[uint256(dogBreed)]);
     emit NftMinted(dogBreed, dogOwner);
 
 }

 function withdraw() public onlyOwner{
    uint256 amount = address(this).balance;
    (bool succes,) = payable(msg.sender).call{value: amount}("");
    if(!success) {revert RandomIpfsNft_TransferFailed();
 }

 

 function getBreedFromModdedRng(uint256 moddedRng) public pure returns (Breed) {
    uint256 cumlativeSum = 0;
    uint256[3] memory chanceArray = getChanceArray();
    for(uint256 i =0; i< chanceRray.length; i++){
        if (moddedRng >= cumlativeSum && moddedRng < cumlativeSum + chanceArray[i]){
            return Breed(i);
        }
        cumlativeSum += chanceArray[i];
    }
    revert RandomIpfsNft__RangeOutOfBounds();

 }


function getChanceArray() public pure returns (uint256 [3] memory) {
    return [10,30, MAX_CHANCE_VALUE];
}


function getMintFee () public view returns (uint256){
    return i_mintFee;
}


function getDogTokenUris(uint256 index) public view returns (String memory) {
    return s_dogTokenUris[index];
}

function getTokenCounter() public view returns (uint256) {
    return s_tokenCounter;
}


}