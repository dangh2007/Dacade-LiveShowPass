import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";
import marketplaceAbi from "../contract/marketplace.abi.json";
import erc20Abi from "../contract/erc20.abi.json";
import {
	cUSDContractAddress,
	MPContractAddress,
	ERC20_DECIMALS,
} from "./utils/constants";

let kit;
let contract;
let pass = [];
let adminAddress;

const connectCeloWallet = async function () {
	if (window.celo) {
		notification("⚠️ Please approve this DApp to use it.");
		try {
			await window.celo.enable();
			notificationOff();

			const web3 = new Web3(window.celo);
			kit = newKitFromWeb3(web3);

			const accounts = await kit.web3.eth.getAccounts();
			kit.defaultAccount = accounts[0];

			contract = new kit.web3.eth.Contract(
				marketplaceAbi,
				MPContractAddress
			);
		} catch (error) {
			notification(`⚠️ ${error}.`);
		}
	} else {
		notification("⚠️ Please install the CeloExtensionWallet.");
	}
};

const approve = async (price) => {
	const cUSDContract = new kit.web3.eth.Contract(
		erc20Abi,
		cUSDContractAddress
	); // Create a contract object using the cUSD contract

	const result = await cUSDContract.methods
		.approve(MPContractAddress, price)
		.send({ from: kit.defaultAccount });
	return result;
};

const getBalance = async function () {
	const totalBalance = await kit.getTotalBalance(kit.defaultAccount);
	const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);
	document.querySelector("#balance").textContent = cUSDBalance;
};

const getAdminAddress = async function () {
	adminAddress = await contract.methods.adminAddress().call();
};

const getpass = async function () {
	const _passLength = await contract.methods.getpassLength().call();
	const _pass = [];
	for (let i = 0; i < _passLength; i++) {
		let _pass = new Promise(async (resolve, reject) => {
			let p = await contract.methods.pass(i).call();
			resolve({
				index: i,
				owner: p[0],
				name: p[1],
				image: p[2],
				description: p[3],
				location: p[4],
				price: new BigNumber(p[5]),
				sold: p[6],
				verified: p[7],
			});
			reject((error) => {
				console.log(error);
			});
		});
		_pass.push(_pass);
	}
	pass = await Promise.all(_pass);
	renderpass();
};

function renderpass() {
	document.getElementById("marketplace").innerHTML = "";
	pass.forEach((_pass) => {
		const newDiv = document.createElement("div");
		newDiv.className = "col-md-4";
		newDiv.innerHTML = passTemplate(_pass);
		document.getElementById("marketplace").appendChild(newDiv);
	});
}

function passTemplate(_pass) {
	const passold = parseInt(_pass.sold);

	return `
  <div class="card border-secondary mb-4">
  <img class="card-img-top" src="${_pass.image}" alt="Card image">
  <div class="position-absolute top-0 end-0 bg-warning mt-4 px-2 py-1 rounded-start">
    ${passold} Sales  
  </div>
      <div class="card-body text-left p-4 position-relative">
        <div class="translate-middle-y position-absolute top-0">
<!--        ${identiconTemplate(_pass.owner)}-->
        </div>
        <h2 class="card-title fs-4 fw-bold mt-2">${_pass.name}</h2>
        <p class="card-text mb-4" style="min-height: 82px">
          ${_pass.description}             
        </p>
        <p class="card-text mt-4">
          <i class="bi bi-geo-alt-fill"></i>
          <span>${_pass.location}</span>
        </p>
        <div class="d-grid gap-2">
        
        
       ${payButtonTemplate(_pass)}
    </div>
      </div>
    </div>
  `;
}

function payButtonTemplate(_pass) {
	if (!_pass.verified) {
		if (kit.defaultAccount === adminAddress) {
			return `
   <a class="btn btn-lg verifyBtn fs-6 p-3  btn-outline-dark"  id=${_pass.index}>
            Verify This Pass
    </a>
  `;
		}
		return `
    <a class="btn btn-lg fs-6 p-3  btn-secondary disabled ">
            Not Yet Verified
    </a>`;
	} else {
		const passPrice = _pass.price / Math.pow(10, ERC20_DECIMALS).toFixed(2);
		return `
  <a class="btn btn-lg buyBtn fs-6 p-3  btn-outline-dark"
       id=${_pass.index}>
      Buy for ${passPrice} cUSD
     </a>
  `;
	}
}

function identiconTemplate(_address) {
	const icon = blockies
		.create({
			seed: _address,
			size: 8,
			scale: 16,
		})
		.toDataURL();

	return `
  <div class="rounded-circle overflow-hidden d-inline-block border border-white border-2 shadow-sm m-0">
    <a href="https://alfajores-blockscout.celo-testnet.org/address/${_address}/transactions"
        target="_blank">
        <img src="${icon}" width="20" alt="${_address}">
    </a>
  </div>
  `;
}

function notification(_text) {
	document.querySelector(".alert").style.display = "block";
	document.querySelector("#notification").textContent = _text;
}

function notificationOff() {
	document.querySelector(".alert").style.display = "none";
}

window.addEventListener("load", async () => {
	notification("⌛ Loading...");
	await connectCeloWallet();
	await getBalance();
	await getAdminAddress();
	await getpass();

	notificationOff();
});

document.querySelector("#newPassBtn").addEventListener("click", async () => {
	const name = document.getElementById("newPassName").value;
	const imageUrl = document.getElementById("newImgUrl").value;
	const description = document.getElementById("newPassDescription").value;
	const price = document.getElementById("newPrice").value;
	const location = document.getElementById("newLocation").value;

	if (!name || !imageUrl || !location || !description || !price) {
		notification("⚠️ Please fill in all fields in the form.");
		return;
	}

	const params = [
		name,
		imageUrl,
		location,
		description,
		// Create a bigNumber object so the contract can read it
		new BigNumber(price).shiftedBy(ERC20_DECIMALS).toString(),
	];
	notification(`⌛ Adding "${params[0]}"...`);
	contract.methods
		.writePass(...params)
		.send({ from: kit.defaultAccount })
		.then(async (res) => {
			console.log(res);
			notification(`🎉 You successfully added "${params[0]}".`);
			await getpass();
		})
		.catch((err) => {
			console.log(err);
			notification(`⚠️ ${error}.`);
		});
});

document.querySelector("#marketplace").addEventListener("click", async (e) => {
	if (e.target.className.includes("buyBtn")) {
		console.log("buyBtn Clicked");
		const index = e.target.id;
		notification("⌛ Waiting for payment approval...");
		try {
			await approve(pass[index].price);
		} catch (error) {
			notification(`⚠️ ${error}.`);
		}
		notification(`⌛ Awaiting payment for "${pass[index].name}"...`);
		try {
			contract.methods.buyPass(index).send({ from: kit.defaultAccount });
			notification(`🎉 You successfully bought "${pass[index].name}".`);
			getpass();
			getBalance();
			return;
		} catch (error) {
			notification(`⚠️ ${error}.`);
		}
	}

	if (e.target.className.includes("verifyBtn")) {
		console.log("verifyBtn Clicked");
		const index = e.target.id;
		console.log({
			e,
		});
		notification(`⌛Verifying "${pass[index].name}"...`);
		try {
			const result = await contract.methods
				.verifyPass(index)
				.send({ from: kit.defaultAccount });
			notification(`🎉 You successfully verified "${pass[index].name}".`);
			getpass();
			getBalance();
		} catch (error) {
			notification(`⚠️ ${error}.`);
		}
	}
});
