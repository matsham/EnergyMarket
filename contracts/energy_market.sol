//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "./nft.sol";


contract EnergyMarket{
    using Counters for Counters.Counter;

    Counters.Counter  private _OfferIds;                 //Counts offers
    Counters.Counter  private _InstallerIds;             //Counts Installers
    Counters.Counter  private _GeneratorIds;             // Counts Generators
    //Counters.Counter  private _GeneratorIds;           // Count
    //Counters.Counter  private _MNFTsMade;              //Counts the number of agreed MNFTs
    //Counters.Counter  private _MNFTsRunning;           //Counts the number of running MNFTs
    Counters.Counter  private _ConsumerIds;              //Counts the number of running MNFTs
    

    uint public listingPrice;
    address public Owner;
    
    mapping (uint => Offer) public Offers;                          //maps an unsigned integer to each offer 
    mapping (uint => installer) public installers;                  //maps an unsigned integer to each installer
    mapping (uint => EnergyProvider) public EnergyProviders;        //maps an unsigned integer to each installer
    mapping (uint => Consumer) public consumers;                    //maps an unsigned integer to each installer
    mapping (address => bool) public ConsumerVerification;          //maps an unsigned integer to each installer
    mapping (address => bool) public LicensedEP;          //maps an unsigned integer to each installer
    mapping (address => bool) public LicensedInstaller;          //maps an unsigned integer to each installer
      
    struct installer{
        address payable InstallerAddress;
        string name;                                     //name of the installer
        string location;                                 //location of installing agent
        string installation_type;                        //Type of installation either
        uint NOI;                                        // NOI are number of installations
        uint Fee;                                        //fee for installation                                   //Licensing Boolean
    }

    struct EnergyProvider {
        address payable EPAddress;
        string name;                                     //name of the installer
        string location;
         
        string Generation_Equipment;
        uint GenCap;
    }
    
     
    struct Offer {      
        string EPName;                                    //name of provider
        string ECPName;                                   //Name of Capacity Provider                               
        string location;                                  //Location
        address payable EP;                               //EP is the energy provider
        address payable ECP;                               // ECP is equipment provider                                 
        uint8  CapFee;                              //Capacity Fee
        uint8  price;                               
        uint   Units;

    } 

    struct Consumer {
        address payable ConsumerAddress;
        string  name;
        string  location;
    }

    constructor (address _NFTaddress) public {
        Owner = msg.sender;
        uint NFTAddress = _NFTaddress;
    }
    
    //Events
    event NewConsumerAdded (
        string ConsumerName,
        address _consumeraddress 
    );

    event NewInstallerAdded (
        string name,  
        string location,                               
        string installation_type, 
        uint NOI                                        
    );

    event Sale (
        uint PSAId,
        uint PPAId,
        string EnergyConsumer,
        string EP,
        string ECP

    );

    event offerCreated (
        string EPName,                                   
        string ECPName,                                                               
        string location,
        uint price,                                
        uint CapFee,
        uint Units
    );

    event GenerationLicense  (
        address _generator,
        string _name,
        string _location,
        string Generation_Equipment
    );
    
    event InstallationLicense (
        address _installer,
        string _name
    );

    event ConsumerVerified (
        string ConsumerName,
        address Verified_Consumer
    );

    event changedListingPrice (
        uint NewlistingPrice
    );

    event NewEnergyProviderLicense(
            uint index , 
            address EPAddress, 
            string name, 
            string location, 
            string GenCap
        );

    

    //MODIFIERS
    //Modifier for functions only the owner can call 
    modifier onlyOwner (uint _index) {
        require (msg.sender == Owner,  " Only the owner address can call this function");
        _;
    }
    
    // Modifier for functions only licensed installers can call
    modifier onlyLicensedInstaller (uint _index) {
        require (installers[_index].licensed);
        _;
    }
    
    // Modifier for functions only verified consumer can call
    modifier is_Verified_Consumer (uint _Cindex, address _ConsumertoVerify) {
        require (consumers[_Cindex].verified , "You can not call this transaction");
        require(ConsumerVerification[_ConsumertoVerify] , "You can not call this transaction");
        _;
    }

    // Modifier for functions only Licensed Energy Providers can call
    modifier onlyLicensedEP (uint _Eindex) {
        require(EnergyProviders[_Eindex].licensed, "You arent a Licensed Energy Provider");
        _;
    }

    //Check for existance of the object 
    modifier exists(uint _index , uint _NFTcode){
        require(_index < _NFTIds.current(), "Query of nonexistent Certificate");
        _;
    }

    modifier validInput(string calldata _input){
        require(bytes(_input).length > 0, "enter valid input");
        _;
    }

    //FUNCTIONS
    // function to set listing price
    function setListingPrice (uint _listprice) private onlyOwner{
        listingPrice = _listprice;
        emit changedListingPrice(_listprice);
    }

    function getListingPrice () public view returns (uint) {
        return listingPrice;
    }
    
    // function to license installers
    function Licenseinstaller(uint _index) validInput(_index) public onlyOwner  {
        installers[_index].licensed = true;
        emit InstallationLicense(installers[_index].name , installers[_index].InstallerAddress);
    }

    //Function to verify which consumers can call transactions
    function verifyConsumer (uint _index, address _ConsumertoVerify) public onlyOwner validInput(_index) validInput(_ConsumertoVerify) {
        require (!consumers[_index].verified);
        require(!ConsumerVerification[_ConsumertoVerify]);
        consumers[_index].verified = true;
        ConsumerVerification[_ConsumertoVerify] = true;

        emit ConsumerVerified (consumers[_index].name, consumers[_index].ConsumerAddress);
    } 

    // function to license EP
    function LicenseEP 
    (
        uint _index,
        string  CategoryName,
        string  Party1,
        string Party2,
        string  Location,
        string  description,
        string  tokenURI,
        uint8 Amount,
        uint8 CapFee,
        uint8 NFTId,
        uint8  CategoryId
    ) public onlyOwner {
        require(!LicensedEP(EnergyProviders[_index]), "This generator already licensed"); 
        EnergyProviders[_index].licensed = true;
        string _License = "License";
        
        createNFT(
            _License,
            _Party1,
            _Party2,
            _Location,
            _description,
            _tokenURI,
            _Amount,
            _CapFee,
            _NFTId,
            _CategoryId    
        );

        emit NewEnergyProviderLicense(
            _index , 
            EnergyProviders[_index].EPAddress, 
            EnergyProviders[_index].name, 
            EnergyProviders[_index].location, 
            EnergyProviders[_index].GenCap
        );   
    }

    // function to Add new consumer to the network 
    function AddConsumer (
        string calldata _consumername,
        string calldata _consumerlocation
        ) public validInput(_consumername) validInput(_consumerlocation){
        _ConsumerIds.increment() ; 
        consumers[_ConsumerIds] = Consumer (
            payable(msg.sender),
            _consumername,
            _consumerlocation
        );  

       ConsumerVerified[msg.sender];

        emit NewConsumerAdded (
            _consumername,
            msg.sender 
        );
    }

    //Function adding installers
    function addInstallationAgent (
        string calldata _name,
        string calldata _location,
        string calldata _installation_type,
        uint _NOI,
        uint _Fee
    ) public validInput(_name) validInput(_location) validInput(_installation_type){
        installers[_InstallerIds] = installer(
           payable(msg.sender), 
           _name,
           _location,
           _installation_type,
           _NOI,
           _Fee
         );

       LicensedInstaller[msg.sender] = false;

       emit NewInstallerAdded(
           _name,
           _location,                           //location of installing agent
           _installation_type, 
           _NOI                                 //name of the installer
         ); 
    }
    
    // function to create offers on the market place
    function CreateOffer   (
        string calldata _EPName,
        string calldata _ECPName,
        string calldata _description,
        string calldata _location,
        address payable _ECP,
        uint _price,
        uint _Capfee,
        uint _units

    ) public payable onlyLicensedEP(uint) 
    validInput(_EPName) validInput(_ECPName) 
    validInput(_description) validInput(_location) 
    validInput(_ECP) {
        require (_price != 0, "Price can not be zero");
        address(this).transfer(listingPrice);
        _OfferIds.increment();
        uint _OfferId = _OfferIds;
        
        
        Offers[_OfferId] = Offer(
            _EPName,
            _description,
            _location,
            payable(msg.sender),
            _ECP,
            _Capfee,
            _price,
            _units
        );

        emit offerCreated (
            _EPName,                                   //name of provider
            _ECPName,                                //Name of Capacity Provider                               
            _location,
            _price,                                //Location
            _Capfee
        );
    }
    

    function getCapFee (uint _id) public view returns (uint) {
        return Offers[_id].CapFee;
    }
    // Function for consumers to initiate a Power Purchase
    
    function CreateSale (
        uint _ConsumerId,
        uint _Amount,
        uint _offerId
    ) public exists(_offerId) is_Verified_Consumer 
    validInput(_Amount) validInput(_ConsumerId) validInput(_offerId) {
        require(ConsumerVerification[msg.sender], "You are not authorized to execute this transaction");
        require(consumers[_ConsumerId].verified, "You are not authorized to create a market sale");
        require(_Amount == (Offers[_offerId].price + Offers[_offerId].Capfee ) , "Money not enough");
        
        (bool PP, ) = payable(Offers[_offerId].EP).call{
            value: Offers[_offerId].price
        }("");
        
        
        (bool PCF, ) = payable(Offers[_offerId].ECP).call{
            value: Offers[_offerId].CapFee
        }("");


        if (PP && PCF) emit Sale (
            _PSAIds.current(),
            _PPAIds.current(),
            consumers[_ConsumerId].name,
            Offers[_offerId].EPName,
            Offers[_offerId].ECPName
        );
        string _PPA = "PPA";
        string _PSA = "PSA"; 
        
        createNFT (
            _ConsumerId,
            _PPA,
            _PPAIds,
            Offers[_offerId].EPName,
            Offers[_offerId].ECPName,
            Offers[_offerId].location,
            Offers[_offerId].price,
            Offers[_offerId].CapFee
        );

        createNFT(
            _ConsumerId,
            _PSA,
            _PSAIds,
            Offers[_offerId].EPName,
            Offers[_offerId].ECPName,
            Offers[_offerId].location,
            Offers[_offerId].price,
            Offers[_offerId].CapFee
        );

        /*require(
		IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
			Cars[_index].Dealer,1
			Cars[_index].price
		   ),
		  "Transfer failed."
		);
        require(
		  IERC20Token(cUsdTokenAddress).transferFrom(
			msg.sender,
			Cars[_index].Dealer,
			Cars[_index].price
		   ),
		  "Transfer failed."
		);*/
        
        //NFTs and PSA created in this function.
    }

        function getOffer(uint256 _OfferId)
        public
        view
        returns (
            string,
            string,
            string,
            string,
            address,
            uint,
            uint,
            uint
        )
    {
        Offers storage rOffers = Offers[_OfferId];
        return (
            rOffers.EPName,
            rOffers.ECPName,
            rOffers.description,
            rOffers.location,
            rOffers.ECP,
            rOffers.price,
            rOffers.Capfee,
            rOffers.units
        );
    }

    function getInstaller (uint256 _InstallerId)
    public
    view
    returns (
        address,
        bool,
        uint256,
        uint256,
        address[] memory
    )
    {
        installer storage rInstallers = installers[_InstallerId];

        return (
            installers[_InstallerId].name,
            installers[_InstallerId].location,
            installers[_InstallerId].installation_type,
            installers[_InstallerId].NOI,
            installers[_InstallerId].Fee
        );
    }

    function getNFT(uint256 _NFTId, uint _code)
    public
    view
    returns (
        string,
        string,
        uint256,
        uint256
    )
    {
        NFT storage rNFT = NFTs[_NFTId];
        return (
            rNFT.Consumer,
            rNFT.EP,
            rNFT.Amount,
            rNFT.CapFee
        );
    }

    function getConsumer(uint256 _ConsumerId)
    public
    view
    returns (
        address,
        string,
        string,
        bool
    )
    {
        Consumer storage rConsumer = consumers[_ConsumerId];
        return (
            rConsumer.ConsumerAddress,
            rConsumer.name,
            rConsumer.location,
            rConsumer.verifiedsold,
        );
    }

  /*  function getPSA (uint256 _PSAId)
    public
    view
    returns (
        address,
        string,
        string,
        bool
    )
    {
        PSA storage rPSA = PSAs[_PSAId];
        return (
            rPSA.Consumer,
            rPSA.EP,
            rPSA.Amount,
            rPSA.CapFee
        );
    }*/
    

    function totalOffers () public view returns (uint256) {
        return _OfferIds.current();
    }

    function totalInstallers () public view returns (uint256) {
        return _InstallerIds.current();
    }

    function totalConsumers () public view returns (uint256) {
        return _ConsumerIds.current();
    }
    function totalGenerators () public view returns (uint256) {
        return _GeneratorIds.current();
    }
}