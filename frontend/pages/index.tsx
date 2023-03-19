// pages/index.tsx
import { WagmiConfig, createClient } from 'wagmi';
import { ethers } from 'ethers';
import MyContract from '../../smart-contracts/out/Counter.sol/Counter.json';

const CONTRACT_ADDRESS = '<your deployed contract address>';

const client = createClient({
  autoConnect: true,
  provider: ethers.getDefaultProvider(),
});

async function repayOnBehalfOf(borrower: string, amount: ethers.BigNumber) {
  const tx = await myContract.repayOnBehalfOf(borrower, amount);
  console.log(tx);
}

const myContract = new ethers.Contract(CONTRACT_ADDRESS, MyContract.abi, ethers.getDefaultProvider());

async function handleClick() {
  const borrower = '<borrower address>';      
  const amount = ethers.utils.parseUnits('<amount in ether>', 'ether');
  repayOnBehalfOf(borrower, amount);
}

export default function Home() {
  return (
    <WagmiConfig client={client}>
      <div>
        <button onClick={handleClick}>Repay on behalf of borrower</button>
      </div>
    </WagmiConfig>
  );
}