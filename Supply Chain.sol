// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Supply Chain Transparency Tool
 * @dev Contract for tracking products through a supply chain with transparency
 */
contract SupplyChainTransparency {
    
    struct ProductDetails {
        string productName;
        address manufacturer;
        uint256 manufacturingTimestamp;
        string manufacturingLocation;
        address[] custodians;
        uint256[] timestamps;
        string[] locations;
        bool exists;
    }
    
    // Maps product IDs to their details
    mapping(bytes32 => ProductDetails) public products;
    
    // Events for logging actions
    event ProductCreated(bytes32 indexed productId, string productName, address indexed manufacturer);
    event CustodyTransferred(bytes32 indexed productId, address indexed previousCustodian, address indexed newCustodian, string location);
    
    /**
     * @dev Creates a new product in the supply chain
     * @param _productId Unique identifier for the product
     * @param _productName Name of the product
     * @param _manufacturingLocation Location where the product was manufactured
     */
    function createProduct(
        bytes32 _productId,
        string memory _productName,
        string memory _manufacturingLocation
    ) public {
        // Check that product doesn't already exist
        require(!products[_productId].exists, "Product already exists");
        
        // Initialize custodians and timestamps arrays
        address[] memory custodians = new address[](1);
        custodians[0] = msg.sender;
        
        uint256[] memory timestamps = new uint256[](1);
        timestamps[0] = block.timestamp;
        
        string[] memory locations = new string[](1);
        locations[0] = _manufacturingLocation;
        
        // Create the product
        products[_productId] = ProductDetails({
            productName: _productName,
            manufacturer: msg.sender,
            manufacturingTimestamp: block.timestamp,
            manufacturingLocation: _manufacturingLocation,
            custodians: custodians,
            timestamps: timestamps,
            locations: locations,
            exists: true
        });
        
        emit ProductCreated(_productId, _productName, msg.sender);
    }
    
    /**
     * @dev Transfers custody of a product to a new custodian in the supply chain
     * @param _productId Unique identifier for the product
     * @param _newCustodian Address of the new custodian
     * @param _location Current location of the product
     */
    function transferCustody(
        bytes32 _productId,
        address _newCustodian,
        string memory _location
    ) public {
        // Check that the product exists
        require(products[_productId].exists, "Product does not exist");
        
        // Check that the sender is the current custodian
        require(
            products[_productId].custodians[products[_productId].custodians.length - 1] == msg.sender,
            "Only current custodian can transfer custody"
        );
        
        // Add new custodian to the chain
        products[_productId].custodians.push(_newCustodian);
        products[_productId].timestamps.push(block.timestamp);
        products[_productId].locations.push(_location);
        
        emit CustodyTransferred(_productId, msg.sender, _newCustodian, _location);
    }
    
    /**
     * @dev Gets the full supply chain history for a product
     * @param _productId Unique identifier for the product
     * @return productName Name of the product
     * @return manufacturer Address of the manufacturer
     * @return manufacturingTimestamp When the product was manufactured
     * @return manufacturingLocation Where the product was manufactured
     * @return custodians Array of addresses that have had custody of the product
     * @return timestamps Array of timestamps for custody transfers
     * @return locations Array of locations for custody transfers
     */
    function getProductHistory(bytes32 _productId) public view returns (
        string memory productName,
        address manufacturer,
        uint256 manufacturingTimestamp,
        string memory manufacturingLocation,
        address[] memory custodians,
        uint256[] memory timestamps,
        string[] memory locations
    ) {
        // Check that the product exists
        require(products[_productId].exists, "Product does not exist");
        
        ProductDetails storage product = products[_productId];
        
        return (
            product.productName,
            product.manufacturer,
            product.manufacturingTimestamp,
            product.manufacturingLocation,
            product.custodians,
            product.timestamps,
            product.locations
        );
    }
}
