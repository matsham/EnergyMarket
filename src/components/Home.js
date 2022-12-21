import { ethers } from 'ethers';
import { useEffect, useState } from 'react';

import close from '../assets/close.svg';

const Home = ({ Offer, provider, account, EnergyMarket, OfferPop }) => {
    //const [hasBought, setHasBought] = useState(false)
    //const [hasLended, setHasLended] = useState(false)

    const [hasLicensedEP, setHasLicensedEP] = useState(false)
    const [hasConsumerVerified, setHasConsumerVerified] = useState(false)
    const [hasLicensedInstaller, setHasLicensedInstaller] = useState(false)

    //const [hasSold, setHasSold] = useState(false) 
    
    const [installer,setInstaller] = useState(null)

    //0Bconst [installer,setInstaller] = useState(null)

    const [Consumer, setConsumer] = useState(null)
    const [lender, setLender] = useState(null)
    const [inspector, setInspector] = useState(null)
    const [seller, setSeller] = useState(null)

    const [owner, setOwner] = useState(null)

    const fetchDetails = async () => {
        // -- Buyer

       // const Consumer = await EnergyMarket.Consumer(Consumers.id)
       //setConsumer(Consumer)

        const hasLicensedEP = await EnergyMarket.LicensedEP()
        setHasLicensedEP(hasLicensedEP)

        // -- Seller

        const Installer = await EnergyMarket.getInstaller()
        setInstaller(Installer)

        const hasSold = await EnergyMarket.approval(home.id, seller)
        setHasSold(hasSold)

        // -- Lender

        const lender = await EnergyMarket.lender()
        setLender(lender)

        const hasLended = await EnergyMarket.approval(home.id, lender)
        setHasLended(hasLended)

        // -- Inspector

        const inspector = await EnergyMarket.inspector()
        setInspector(inspector)

        const hasInspected = await EnergyMarket.inspectionPassed(home.id)
        setHasInspected(hasInspected)
    }

    const fetchOwner = async () => {
        if (await EnergyMarket.isListed(NFT.id)) return

        const owner = await EnergyMarket.buyer(NFT.id)
        setOwner(owner)
    }

    const SaleHandler = async (_Offerid, _Consumerid, _Amount) => {
        const ListingPrice = await EnergyMarket.getListingPrice()
        const CapFee = await EnergyMarket.getCapFee(_Offerid)
        const signer = await provider.getSigner()

        // Buyer deposit earnest
        let transaction = await EnergyMarket.connect(signer).CreateSale(_Consumerid, _Offerid, _Amount)
        await transaction.wait()

        // Buyer approves...
        //transaction = await EnergyMarket.connect(signer).approveSale(home.id)
        //await transaction.wait()

        setHasLicensedEP(true)
    }

    const LicenseHandler = async () => {
        const signer = await provider.getSigner()

        // Inspector updates status
        const transaction = await EnergyMarket.connect(signer).LicenseEP(home.id, true)
        await transaction.wait()

        setHasInspected(true)
    }

    const VerificationHandler = async () => {
        const signer = await provider.getSigner()

        // Inspector updates status
        const transaction = await EnergyMarket.connect(signer).VerifyConsumer(home.id, true)
        await transaction.wait()

        setHasConsumerVerified(true)
    }

    const LicenseHandler2 = async () => {
        const signer = await provider.getSigner()

        // Inspector updates status
        const transaction = await EnergyMarket.connect(signer).LicenseInstaller()
        
        (home.id, true)
        await transaction.wait()

        setHasLicensedInstaller(true)
    }

    const lendHandler = async () => {
        const signer = await provider.getSigner()

        // Lender approves...
        const transaction = await EnergyMarket.connect(signer).approveSale(home.id)
        await transaction.wait()

        // Lender sends funds to contract...
        const lendAmount = (await EnergyMarket.purchasePrice(home.id) - await EnergyMarket.escrowAmount(home.id))
        await signer.sendTransaction({ to: EnergyMarket.address, value: lendAmount.toString(), gasLimit: 60000 })

        setHasLended(true)
    }

    const sellHandler = async () => {
        const signer = await provider.getSigner()

        // Seller approves...
        let transaction = await EnergyMarket.connect(signer).approveSale(home.id)
        await transaction.wait()

        // Seller finalize...
        transaction = await EnergyMarket.connect(signer).finalizeSale(home.id)
        await transaction.wait()

        setHasSold(true)
    }

    useEffect(() => {
        fetchDetails()
        fetchOwner()
    }, [hasSold])

    return (
        <div className="home">
            <div className='home__details'>
                <div className="home__image">
                    <img src={home.image} alt="Home" />
                </div>
                <div className="home__overview">
                    <h1>{home.name}</h1>
                    <p>
                       <strong>{home.attributes[2].value}</strong> bds |
                       <strong>{home.attributes[2].value}</strong> bds |
                       <strong>{home.attributes[2].value}</strong> bds |
                       <strong>{home.attributes[2].value}</strong> bds |
                       <strong>{home.attributes[2].value}</strong> bds |
                       <strong>{home.attributes[3].value}</strong> ba |
                       <strong>{home.attributes[4].value}</strong> sqft
                    </p>
                    <p>{home.address}</p>

                    <h2>{home.attributes[0].value} ETH</h2>

                    {owner ? (
                        <div className='home__owned'>
                            Owned by {owner.slice(0, 6) + '...' + owner.slice(38, 42)}
                        </div>
                    ) : (
                        <div>
                            {(account === inspector) ? (
                                <button className='home__buy' onClick={inspectHandler} disabled={hasInspected}>
                                    Approve Inspection
                                </button>
                            ) : (account === lender) ? (
                                <button className='home__buy' onClick={lendHandler} disabled={hasLended}>
                                    Approve & Lend
                                </button>
                            ) : (account === seller) ? (
                                <button className='home__buy' onClick={sellHandler} disabled={hasSold}>
                                    Approve & Sell
                                </button>
                            ) : (
                                <button className='home__buy' onClick={buyHandler} disabled={hasBought}>
                                    Buy
                                </button>
                            )}

                            <button className='home__contact'>
                                Contact agent
                            </button>
                        </div>
                    )}

                    <hr />

                    <h2>Overview</h2>

                    <p>
                        {home.description}
                    </p>

                    <hr />

                    <h2>Facts and features</h2>

                    <ul>
                        {home.attributes.map((attribute, index) => (
                            <li key={index}><strong>{attribute.trait_type}</strong> : {attribute.value}</li>
                        ))}
                    </ul>
                </div>


                <button onClick={togglePop} className="home__close">
                    <img src={close} alt="Close" />
                </button>
            </div>
        </div >
    );
}

export default Home;