// SPDX-License-Identifier: MIT
pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface ERC20 {
  function decimals() external view returns (uint8);
}

interface AggregatorInterface {
    
  function decimals() external view returns (uint8);
  
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);
}

contract PathReader {
  using SafeMath for uint256;
    
  // from => to => address(aggregators)
  mapping(address => mapping(address => address)) public allAggregators;

  // rate must have been updated before the last... 10min
  uint256 public maxTimestampDeltaAcceptable = 600;

  constructor() public {
    // allAggregators[0x0000000000000000000000000000000000000001][0x0000000000000000000000000000000000000002] = 0xff00000000000000000000000000000000000012;
    // allAggregators[0x0000000000000000000000000000000000000001][0x0000000000000000000000000000000000000003] = 0xFf00000000000000000000000000000000000013;
    // allAggregators[0x0000000000000000000000000000000000000002][0x0000000000000000000000000000000000000003] = 0xfF00000000000000000000000000000000000023;
    // allAggregators[0x0000000000000000000000000000000000000003][0x0000000000000000000000000000000000000004] = 0xfF00000000000000000000000000000000000034;
  }

  function addAggregator(address input, address output, address aggregator) external {
    allAggregators[input][output] = aggregator;
  }

  function getConversion(
    uint256 amountIn,
    address[] calldata path
  ) 
    external
    returns (uint256 conversion)
  {
    conversion = amountIn;
       
    for (uint i; i < path.length - 1; i++) {
        (address input, address output) = (path[i], path[i + 1]);
        
        AggregatorInterface aggregator = AggregatorInterface(allAggregators[input][output]);
        bool reverseAggregator = false;

        if(address(aggregator) == address(0x00)) {
          aggregator = AggregatorInterface(allAggregators[output][input]);
          reverseAggregator = true;
        }
        require(address(aggregator) != address(0x00), "aggregator not found");

        // by default we assume it is FIAT so 8 decimals
        uint256 decimalsInput = 8;
        // if address is 0, then it's ETH
        if(input == address(0x0)) {
          decimalsInput = 18;
        } else if(isContract(input)) {
          decimalsInput = ERC20(input).decimals();
        }
       
        // by default we assume it is FIAT so 8 decimals
        uint256 decimalsOutput = 8;
        // if address is 0, then it's ETH
        if(output == address(0x0)) {
          decimalsOutput = 18;
        } else if(isContract(output)) {
          decimalsOutput = ERC20(output).decimals();
        }
        
        
        // Check rate timestamp
        require(now.sub(aggregator.latestTimestamp()) <= maxTimestampDeltaAcceptable, "aggregator rate is outdated");
        
        uint256 rate = uint256(aggregator.latestAnswer());
        uint256 decimalsAggregator = uint256(aggregator.decimals());
        
        if(decimalsAggregator > decimalsInput) {
            conversion = conversion.mul(10**(decimalsAggregator-decimalsInput));
        }
        if(decimalsAggregator < decimalsInput) {
            conversion = conversion.div(10**(decimalsInput-decimalsAggregator));
        }

        if(reverseAggregator) {
          conversion = conversion.mul(10**decimalsAggregator).div(rate);
        } else {
          conversion = conversion.mul(rate).div(10**decimalsAggregator);
        }

        if(decimalsAggregator > decimalsOutput) {
            conversion = conversion.div(10**(decimalsAggregator-decimalsOutput));
        }
        if(decimalsAggregator < decimalsOutput) {
            conversion = conversion.mul(10**(decimalsOutput-decimalsAggregator));
        }
    }
  }

  function isContract(address _addr) private returns (bool isContract){
    uint32 size;
    assembly {
      size := extcodesize(_addr)
    }
    return (size > 0);
  }
}
