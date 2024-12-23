pragma solidity ^0.8.2 <0.9.0;

contract StringMaker {
    string private storedString; 

 
    function storeString(string memory input) public {
        storedString = input; 
    }


    function getSlicedString(uint startIndex, uint endIndex) public view returns (string memory) {
        bytes memory strBytes = bytes(storedString);


        require(endIndex > startIndex, "End index must be greater than start index");
        require(endIndex <= strBytes.length, "End index exceeds string length");

        bytes memory result = new bytes(endIndex - startIndex);

        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }

        return string(result); 
    }
}

