import { useEffect, useState } from "react";
import { useScaffoldContractRead, useDeployedContractInfo, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const NftCard = ({
  id,
  name,
  description,
  image, setTxLoading
}) => {

  const { data: svg } = useScaffoldContractRead({
    contractName: "Scarecrow",
    functionName: "renderTokenById",
    args: [id],
  });

  const { data: upgrageIds } = useScaffoldContractRead({
    contractName: "Scarecrow",
    functionName: "crowUpgrades",
    args: [id],
  });

  const { data: hatContractData, isLoading: hatContractLoading } = useDeployedContractInfo("Hat");
  const { data: scarfContractData, isLoading: scarfContractLoading } = useDeployedContractInfo("Scarf");
  const hatAddr = hatContractData?.address as string
  const scarfAddr = scarfContractData?.address as string

  const hatId = Number(upgrageIds?.hatId)
  const scarfId = Number(upgrageIds?.scarfId)

  const { writeAsync: removeHat, isMining: removeHatMining } = useScaffoldContractWrite({
    contractName: "Scarecrow",
    functionName: "removeNftFromCrow",
    args: [hatAddr, id],
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: removeScarf, isMining: removeScarfMining } = useScaffoldContractWrite({
    contractName: "Scarecrow",
    functionName: "removeNftFromCrow",
    args: [scarfAddr, id],
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });


  let svgImage = ` 
  <svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" width="100%"  version="1.1" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" image-rendering="optimizeQuality" fill-rule="evenodd" clip-rule="evenodd"
  viewBox="0 0 1084 1084"
   xmlns:xlink="http://www.w3.org/1999/xlink">
   <defs>
      <clipPath id="id0">
       <path d="M538 383l-3 4 -13 6 -11 4c-3,0 -2,0 -5,1 -2,0 -4,1 -6,1l-8 -1 -9 -2 -5 -2 -4 -6 -4 -5 -2 -7 1 -3 2 -7 3 -5 4 2c0,1 2,2 3,2l4 3 5 2 5 2 7 2 4 2 8 2 5 2 6 1 6 1 7 1z"/>
      </clipPath>
   </defs>` + svg?.toString() + `</svg>`


  useEffect(() => {
    setTxLoading(true)
    setTxLoading(false)
  }, [removeHatMining, removeScarfMining])


  return (
    <div className="h-full border-2 rounded-xl overflow-hidden border-black w-full text-xs"
    >

      <div style={{
        maxWidth: "100%",
        maxHeight: "100%",
        width: "auto",
        height: "auto",
        overflow: "hidden",
      }}
        dangerouslySetInnerHTML={{ __html: svgImage }} />
      {/* <Image src={svgImage} alt="My Image" width={200} height={200} /> */}
      <div className="mt-4 px-4 mb-2">
        <div> {name} </div>
        <div> {description} </div>
      </div>
      {hatId > 0 && <button onClick={removeHat} className="w-full bg-red-300 px-4 py-2  mt-2 hover:bg-red-500">Remove Hat</button>}
      {scarfId > 0 && <button onClick={removeScarf} className="w-full bg-red-300 px-4 py-2  mt-1 hover:bg-red-500">Remove Scarf</button>}

    </div>
  );
}
