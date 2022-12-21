import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

// Components
import Navigation from './components/Navigation';
import Search from './components/Search';
import Home from './components/Home';

// ABIs
import EnergyMarket from './abis/EnergyMarket.json'
import Escrow from './abis/Escrow.json'

// Config
import config from './config.json';

function App() {
  
  const [provider, setProvider] = useState(null)
  const [ListingPrice, setListingPrice] = useState(null)
  
  const [CapFee, setCapFee] = useState(null)
  const [account, setAccount] = useState(null)

  const [Offers, setOffers] = useState([])
  const [offer, setOffer] = useState({})

  const [Generators, setGenerators] = useState([])
  const [Generator, setGenerator] = useState({})
  
  const [Installers, setInstallers] = useState([])
  const [Installer, setInstaller] = useState({})

  const [Consumers, setConsumers] = useState([])
  const [Consumer, setConsumer] = useState({})
 
  const [NFTs, setNFTs] = useState([])
  const [NFT, setNFT] = useState({})
  
  
  const [toggle, setToggle] = useState(false);

  const loadBlockchainData = async () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    setProvider(provider)
    const network = await provider.getNetwork()

    const EnergyMarket = new ethers.Contract(config[network.chainId].EnergyMarket.address, EnergyMarket, provider)
    
    const totalGenerators = await EnergyMarket.totalGenerators()
    const totalInstallers = await EnergyMarket.totalInstallers()
    const totalOffers = await EnergyMarket.totalOffers()
    const totalConsumers = await EnergyMarket.totalConsumers()
    const totalNFTS = await EnergyMarket.totalNFTS()

    const Installers = []
    const Offers = []
    const Generators = []
    const Consumers = []
    const NFTs =[]

    for (var i = 1; i <= totalInstallers; i++) {
      const uri = await EnergyMarket.tokenURI(i)
      const response = await fetch(uri)
      const metadata = await response.json()
      Installers.push(metadata)
    }

    setInstallers(Installers)

    for (var i = 1; i <= totalOffers; i++) {
      const uri = await EnergyMarket.tokenURI(i)
      const response = await fetch(uri)
      const metadata = await response.json()
      Offers.push(metadata)
    }

    setOffers(Offers)

    for (var i = 1; i <= totalGenerators; i++) {
      const uri = await EnergyMarket.tokenURI(i)
      const response = await fetch(uri)
      const metadata = await response.json()
      Generators.push(metadata)
    }

    setGenerators(Generators)

    for (var i = 1; i <= totalConsumers; i++) {
      const uri = await EnergyMarket.tokenURI(i)
      const response = await fetch(uri)
      const metadata = await response.json()
      Consumers.push(metadata)
    }

    setGenerators(Consumers)

    for (var i = 1; i <= totalNFTS; i++) {
      const uri = await EnergyMarket.tokenURI(i)
      const response = await fetch(uri)
      const metadata = await response.json()
      NFTs.push(metadata)
    }

    setNFTs(Generators)

    //const escrow = new ethers.Contract(config[network.chainId].escrow.address, Escrow, provider)
    //setEscrow(escrow)

    window.ethereum.on('accountsChanged', async () => {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      const account = ethers.utils.getAddress(accounts[0])
      setAccount(account);
    })
  }

  useEffect(() => {
    loadBlockchainData()
  }, [])

  const OfferPop = (Offer) => {
    setOffer(Offer)
    toggle ? setToggle(false) : setToggle(true);
  }

  const InstallerPop = (Offer) => {
    setOffer(Offer)
    toggle ? setToggle(false) : setToggle(true);
  }

  const EPPop = (Offer) => {
    setOffer(Offer)
    toggle ? setToggle(false) : setToggle(true);
  }

  /*const OfferPop = (Offer) => {
    setOffer(Offer)
    toggle ? setToggle(false) : setToggle(true);
  }*/

  return (
    <div>
      <Navigation account={account} setAccount={setAccount} />
      <Search />

      <div className='cards__section'>

        <h3>Energy Deals For You </h3>

        <hr />

        <div className='cards_section'>
          {Offers.map((Offer, index) => ( 
            <div className='card' key={index} onClick={() => togglePop(home)}>
              <div className='card__image'>
                <img src={Offer.image} alt="Home" />
              </div>
              <div className='card__info'>
                <h4>{Offer.attributes[0].value} ETH</h4>
                <p>
                  <strong>{Offer.attributes[2].value}</strong> bds |
                  <strong>{Offer.attributes[3].value}</strong> ba |
                  <strong>{Offer.attributes[4].value}</strong> sqft
                </p>
                <p>{Offer.address}</p>
              </div>
            </div>
          ))}
        </div

      </div>

      {toggle && (
        <Home Offer={Offer} provider={provider} account={account} EnergyMarket={EnergyMarket} togglePop={OfferPop} />
      )}

    </div>
  );
}

export default App;
