pragma solidity ^0.5.0;

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function latestRound() external view returns (uint256);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
    event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

contract ChainlinkAggregatorCaller {
    // Event to declare a transfer with a reference
    event TransferWithReference(
        address tokenAddress,
        address to,
        uint256 amount,
        bytes indexed paymentReference,
        uint256 amountinCrypto
    );

    enum FiatEnum {USD, AUD, CHF, EUR, GBP, JPY}
    enum CryptoEnum {ETH, DAI, USDT, USDC, SUSD}

    // #################################################################################
    // #################################################################################
    // Mock up of Chainlink aggregators for private network
    function getChainlinkAggregatorCryptoToETH(CryptoEnum cryptoEnum)
        public
        pure
        returns (AggregatorInterface)
    {
        if (cryptoEnum == CryptoEnum.USDT) {
            // USDT/ETH
            return AggregatorInterface(0xBd2c938B9F6Bfc1A66368D08CB44dC3EB2aE27bE);
        }
        revert('crypto not supported for eth conversion');
    }

    function getChainlinkAggregatorCryptoToUsd(CryptoEnum cryptoEnum)
        public
        pure
        returns (AggregatorInterface)
    {
        if (cryptoEnum == CryptoEnum.DAI) {
            // DAI/USD
            return AggregatorInterface(0xB529f14AA8096f943177c09Ca294Ad66d2E08b1f);
        }
        if (cryptoEnum == CryptoEnum.ETH) {
            // ETH/USD
            return AggregatorInterface(0x3d49d1eF2adE060a33c6E6Aa213513A7EE9a6241);
        }
        revert('crypto not supported for usd conversion');
    }

    function getChainlinkAggregatorFiatToUsd(FiatEnum fiatEnum)
        public
        pure
        returns (AggregatorInterface)
    {
        if (fiatEnum == FiatEnum.EUR) {
            // EUR/USD
            return AggregatorInterface(0x2a504B5e7eC284ACa5b6f49716611237239F0b97);
        }
        revert('fiat not supported');
    }

    function getTokenAddress(CryptoEnum cryptoEnum) public pure returns (address) {
        if (cryptoEnum == CryptoEnum.USDT) {
            // Test erc20
            return 0x38cF23C52Bb4B13F051Aec09580a2dE845a7FA35;
        }
        if (cryptoEnum == CryptoEnum.DAI) {
            // Test erc20
            return 0x38cF23C52Bb4B13F051Aec09580a2dE845a7FA35;
        }
        revert('token not supported');
    }
}
