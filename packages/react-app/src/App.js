import React, { useEffect, useState } from 'react';
import './styles/App.css';
import { ethers } from 'ethers';
import ElfakNFT from './utils/ElfakNFT.json';

const App = () => {
	const [currentAccount, setCurrentAccount] = useState('');
	const [statusMessage, setStatusMessage] = useState('');
	const [isButtonDisabled, setIsButtonDisabled] = useState(false);

	const checkIfWalletIsConnected = async () => {
		const { ethereum } = window;

		if (!ethereum) {
			console.log('Make sure you have metamask!');
			return;
		} else {
			console.log('We have the ethereum object', ethereum);
		}

		const accounts = await ethereum.request({ method: 'eth_accounts' });

		if (accounts.length !== 0) {
			const account = accounts[0];
			console.log('Found an authorized account:', account);
			setCurrentAccount(account);
		} else {
			console.log('No authorized account found');
		}
	};

	/*
	 * Implement your connectWallet method here
	 */
	const connectWallet = async () => {
		try {
			const { ethereum } = window;

			if (!ethereum) {
				alert('Get MetaMask!');
				return;
			}

			const accounts = await ethereum.request({
				method: 'eth_requestAccounts',
			});

			let chainId = await ethereum.request({ method: 'eth_chainId' });

			// console.log('Connected', accounts[0]);
			setCurrentAccount(accounts[0]);

			const rinkebyChainId = '0x4';
			if (chainId !== rinkebyChainId) {
				alert('You are not connected to the Rinkeby Test Network!');
			}
		} catch (error) {
			console.log(error);
		}
	};

	const renderNotConnectedContainer = () => (
		<button
			onClick={connectWallet}
			className='cta-button connect-wallet-button'>
			Connect to Wallet
		</button>
	);

	const askContractToMintNft = async () => {
		const CONTRACT_ADDRESS = '0xdD4cc64385D93B6330475564607cE665DB75A8a3';

		try {
			const { ethereum } = window;

			if (ethereum) {
				const provider = new ethers.providers.Web3Provider(ethereum);
				const signer = provider.getSigner();
				const connectedContract = new ethers.Contract(
					CONTRACT_ADDRESS,
					ElfakNFT.abi,
					signer
				);

				console.log('Going to pop wallet now to pay gas...');
				let nftTxn = await connectedContract.makeAnNFT();

				setStatusMessage('Mining...please wait.');
				setIsButtonDisabled(true);
				await nftTxn.wait();

				setStatusMessage(
					`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`
				);
				setIsButtonDisabled(false);
			} else {
				console.log("Ethereum object doesn't exist!");
			}
		} catch (error) {
			console.log(error);
		}
	};

	useEffect(() => {
		checkIfWalletIsConnected();
	}, []);

	/*
	 * Added a conditional render! We don't want to show Connect to Wallet if we're already conencted :).
	 */
	return (
		<div className='App'>
			<div className='container'>
				<div className='header-container'>
					<p className='header gradient-text'>Elektronski Fakultet NFT</p>
					<br />
					{currentAccount && (
						<p className='sub-text'>Connected: {currentAccount}</p>
					)}
					{statusMessage && <p className='sub-text'> {statusMessage}</p>}
					{currentAccount === '' ? (
						renderNotConnectedContainer()
					) : (
						<button
							disabled={isButtonDisabled}
							onClick={askContractToMintNft}
							className='cta-button connect-wallet-button'>
							Mint NFT
						</button>
					)}
				</div>
				<div className='footer-text'>
					<h3>Aleksa Djurovic 1321</h3>
					<h3>Andrej Rakic 1390</h3>
				</div>
			</div>
		</div>
	);
};

export default App;
