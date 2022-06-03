import { useMoralis, useWeb3Contract } from "react-moralis";
import { useState, useEffect } from "react";
import { abi } from "../constants/abi.json";

const CONTRACT_ADDRESS = "0xF6814D35bf6Cb498C3982230F8613c270555D074";

export default function LotteryEntrance() {
  const { isWeb3Enabled } = useMoralis();
  const [recentWinner, setRecentWinner] = useState("0");
  const [numPlayers, setNumPlayers] = useState("0");

  //enter Lottery
  const { runContractFunction: enterRaffle } = useWeb3Contract({
    abi: abi,
    contractAddress: CONTRACT_ADDRESS,
    functionName: "enterRaffle",
    msgValue: "100000000000000000", //0.1 ETH
    params: {},
  });

  //view Functions

  const { runContractFunction: getRecentWinner } = useWeb3Contract({
    abi: abi,
    contractAddress: CONTRACT_ADDRESS,
    functionName: "s_recentWinner",
    params: {},
  });

  //if web3 in enabled, update num players
  //run this function any time isWeb3Enabled changes
  useEffect(() => {
    async function updateUi() {
      const recentWinnerFromCall = await getRecentWinner();
      setRecentWinner(recentWinnerFromCall);
    }
    if (isWeb3Enabled) {
      updateUi();
    }
  }, [isWeb3Enabled]);

  return (
    <div>
      <button
        className="rounded ml-auto font-bold bg-blue-500"
        onClick={async () => {
          await enterRaffle();
        }}
      >
        Enter Lottery
      </button>
      <div>The Recent Winner is : {recentWinner}</div>
    </div>
  );
}
