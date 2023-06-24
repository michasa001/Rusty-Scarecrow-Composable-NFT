import Link from "next/link";
import { useState, useEffect } from "react";
import type { NextPage } from "next";
import { BugAntIcon, MagnifyingGlassIcon, SparklesIcon } from "@heroicons/react/24/outline";
import { MetaHeader } from "~~/components/MetaHeader";
import { Network, Alchemy } from "alchemy-sdk";
import { useDeployedContractInfo, useScaffoldContractWrite, useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { useAccount } from "wagmi";
import { NftCard } from "~~/components/scarecrow/NftCard";




const Home: NextPage = () => {
  const [nfts, setNfts] = useState<any[]>([])
  const settings = {
    apiKey: "oKxs-03sij-U_N0iOlrSsZFr29-IqbuF", // Replace with your Alchemy 
    network: Network.ETH_SEPOLIA,
  };
  const [nftLoading, setNftLoading] = useState(false)
  const [txLoading, setTxLoading] = useState(false)

  const account = useAccount();
  const alchemy = new Alchemy(settings);
  const { data: deployedContractData, isLoading: deployedContractLoading } = useDeployedContractInfo("Scarecrow");
  const accountAddr = account.address as string
  const contractAddr = deployedContractData?.address as string

  const getNfts = async () => {
    const nft = await alchemy.nft.getNftsForOwner(accountAddr, {
      contractAddresses: [contractAddr],
    })
    if (nft?.ownedNfts.length > 0) setNfts(nft?.ownedNfts)
    console.log(nft.ownedNfts)

  }

  const { writeAsync: mintNft, isMining } = useScaffoldContractWrite({
    contractName: "Scarecrow",
    functionName: "mintItem",
    args: [],
    value: "0.005",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { data: balance } = useScaffoldContractRead({
    contractName: "Scarecrow",
    functionName: "balanceOf",
    args: [accountAddr],
  });

  useEffect(() => {

    setNftLoading(true)

    if (accountAddr && contractAddr)
      getNfts()
    setNftLoading(false)
  }, [accountAddr, isMining, txLoading, balance])



  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5 flex flex-col items-center">
          <h1 className="text-center ">
            <span className="block text-3xl font-bold">Rusty Scarecrows</span>
          </h1>
          <h1 className="text-center"> Our uninvited guests, the mischievous rodent pests are nearby!</h1>
          <h1 className="text-center text-lg">
            Mint yourself a unique Scarecrow, add some accesories and protect your farm yard
          </h1>

          <button className="px-8 py-2 bg-base-300 rounded-full hover:bg-gray-500 transition ease-in-out delay-150 hover:-translate-y-0.5 hover:scale-105" onClick={mintNft}>Mint </button>
        </div>

        <div className={"flex-grow bg-base-300 w-full mt-16 md:px-24 px-8 py-12 "}>
          <div className="text-center mb-8">Your Scare Crows: {Number(balance)}</div>
          {nftLoading && nfts.length == 0 && <div className="animate-pulse"> <div className="w-full h-40 bg-base-200  text-center"></div></div>}
          {!nftLoading && nfts && <div className="grid md:grid-cols-5 grid-cols-4 h-full">
            {nfts.map((item) => {
              console.log(item);
              return <div className="mx-1" > <NftCard description={item?.rawMetadata.description} name={item?.rawMetadata.name} id={item?.tokenId} image={item?.rawMetadata.image} setTxLoading={setTxLoading} /></div>;
            })}
          </div>}
        </div>
      </div >
    </>
  );
};

export default Home;
