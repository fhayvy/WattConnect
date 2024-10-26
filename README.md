# WattConnect: Decentralized Energy Trading Platform

## Overview

WattConnect is a peer-to-peer energy trading platform that enables homeowners with solar panels to sell excess energy directly to their neighbors. This decentralized system reduces reliance on centralized power companies and promotes renewable energy adoption.

## Features

- Peer-to-peer energy trading
- Smart contract-based transactions
- Real-time energy price updates
- User-friendly interface for buying and selling energy
- Blockchain-backed security and transparency

## Technical Stack

- Smart Contract: Clarity (Stacks blockchain)
- Frontend: React.js
- Backend: Node.js
- Blockchain: Stacks (built on Bitcoin)

## Smart Contract

The core of WattConnect is a Clarity smart contract that manages energy trading. Key functionalities include:

- Setting and retrieving the current energy price
- Adding energy for sale
- Purchasing energy
- Checking user balances (both energy and cryptocurrency)

## Getting Started

### Prerequisites

- [Stacks Blockchain API](https://github.com/blockstack/stacks-blockchain-api)
- [Clarity CLI](https://github.com/hirosystems/clarinet)
- Node.js and npm

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/WattConnect.git
   cd WattConnect
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Deploy the smart contract:
   ```
   clarinet contract:deploy energy-trading-contract
   ```

4. Start the development server:
   ```
   npm start
   ```

## Usage

1. Connect your Stacks wallet to the application.
2. If you have excess energy to sell:
   - Use the "Add Energy" function to make your energy available on the platform.
3. If you want to buy energy:
   - Check the current energy price.
   - Use the "Buy Energy" function to purchase available energy.
4. Monitor your energy and STX balances in real-time.

## Contributing

We welcome contributions to WattConnect! If you'd like to contribute, please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## Contact

Favour Chiamaka Eze - ezefavourchiamaka01@gmail.com

Project Link: [https://github.com/fhayvy/WattConnect](https://github.com/fhayvy/WattConnect)

## Acknowledgments

- Stacks community for their robust blockchain platform
- Renewable energy advocates and early adopters

Happy energy trading with WattConnect! Together, we can create a more sustainable and decentralized energy future.