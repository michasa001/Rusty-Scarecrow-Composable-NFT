import { useEffect, useState } from "react";
// import { NftExcludeFilters, Alchemy, Network } from "alchemy-sdk";
import Image from "next/image";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const AccessoryCard = ({
  id,
  name,
  description,
  image,
  accountAddr,
  scarecrowAddr,
  accessoryName,
  setTxLoading
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [scarecrowId, setScarecrowId] = useState();
  const [scarecrowIdBytes, setScarecrowIdBytes] = useState();

  const { writeAsync: Upgrade, isMining: UpgradeMining } = useScaffoldContractWrite({
    contractName: accessoryName === "Hat" ? "Hat" : "Scarf",
    functionName: "safeTransferFrom(address,address,uint256,bytes)",
    args: [accountAddr, scarecrowAddr, id, scarecrowIdBytes],
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  useEffect(() => {
    const IdBytes = "0x" + parseInt(scarecrowId).toString(16).padStart(64, "0");
    setScarecrowIdBytes(IdBytes)
  }, [scarecrowId])



  useEffect(() => {
    const handleEscapeKey = (event) => {
      if (event.key === 'Escape') {
        closePopup();
      }
    };


    const handleOverlayClick = (event) => {
      const isOverlayClicked = event.target.classList.contains('bg-gray-900');

      if (isOverlayClicked) {
        closePopup();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscapeKey);
      document.addEventListener('mousedown', handleOverlayClick);
    }


    return () => {
      document.removeEventListener('keydown', handleEscapeKey);
      document.removeEventListener('mousedown', handleOverlayClick);
    };
  }, [isOpen]);

  const openPopup = () => {
    setIsOpen(true);
  };

  const closePopup = () => {
    setIsOpen(false);
  };

  useEffect(() => {
    setTxLoading(UpgradeMining)
  }, [UpgradeMining])


  return (
    <div className="border-2 rounded-xl overflow-hidden border-black w-fit text-xs bg-base-200 h-full"
    >
      <Image src={image} alt="accessory" width={200} height={200} />
      <div className="mt-4 px-4 mb-2">
        <div> {name} </div>
        <div> {description} </div>
      </div>
      <button className=" w-full bg-orange-300 px-4 py-2 hover:bg-orange-500 mt-2" onClick={openPopup}>Add to scarecrow</button>
      {isOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-gray-900 bg-opacity-50">
          <div className=" absolute bg-base-200 p-8 rounded shadow">
            <button
              className="absolute right-0 top-0 m-4 text-gray-500 hover:text-gray-700"
              onClick={closePopup}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
            <h2 className="text-md mb-4">Enter Your Scarecrow Id</h2>
            <input
              className="input input-ghost focus:outline-none focus:bg-transparent focus:text-gray-400 h-[2.2rem] min-h-[2.2rem] px-4 border w-full font-medium placeholder:text-accent/50 text-gray-400 border border-black"
              placeholder={"Token Id"}
              // name={name}
              // value={value?.toString()}
              onChange={(event) => { setScarecrowId(event.target.value) }}
            // disabled={disabled}
            // autoComplete="off"
            />
            <button onClick={Upgrade} className="w-full bg-base-300 mt-2 rounded-full py-3 text-md">Upgrade</button>
          </div>
        </div>
      )}
    </div>
  );
}
