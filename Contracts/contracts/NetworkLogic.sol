pragma solidity ^0.5;

import "./BusinessModels.sol";


contract NetworkLogic {
    BusinessModels.Company[] companies;
    BusinessModels.CmrDocument[] documents;
    BusinessModels.Employ[] employs;

    event companyRegistered(address companyAddress, bytes32 name, uint id);
    event companyRegistersNewEmploy(uint companyID, bytes32 name, bytes32 surname, uint employID);

    event newSpedition(
        address indexed sender,
        address indexed recipient,
        uint when,
        uint indexed speditionID
    );

    event speditionConfirmed(
        uint indexed speditionID
    );

    modifier documentExists(uint _id) {
        require(documents.length > _id, "DOcument with the given id does not exists");
        _;
    }

    modifier companyExists(uint _id) {
        require(companies.length > _id, "Company with the given id does not exists");
        _;
    }

    modifier onlySpecificCompany(uint _id) {
        require(companies[_id].companyAddress == msg.sender, "This method can ce called just by the company with the given id");
        _;
    }

    function registerNewCompany(address _address, bytes32 _name) public {
        BusinessModels.Company memory company = BusinessModels.Company({
            companyAddress: _address,
            companyName: _name,
            id: companies.length,
            transferDocuments: new uint[](0),
            employs: new BusinessModels.Employ[](0)
        });

        companies.push(company);
        emit companyRegistered(_address, _name, companies.length);
    }

    function registerNewEmploy(uint _companyID, bytes32 _name, bytes32 _surname) public 
    companyExists(_companyID)
    onlySpecificCompany(_companyID)
    {
        BusinessModels.Employ memory employ = BusinessModels.Employ({
            name: _name,
            surname: _surname,
            employerID: companies[_companyID].id,
            employID: companies[_companyID].employs.length,
            workingDocuments: new uint[](0),
            longitude: 0,
            latitude: 0
        });

        companies[_companyID].employs.push(employ);
        emit companyRegistersNewEmploy(_companyID, _name, _surname, employ.employID);
    }

    function registerNewSpedition(
        uint _speditorCompanyID,

        uint _senderCompanyID,

        uint _recipientCompanyID,

        uint _originLatitude,
        uint _originLongitude,
        
        uint _destinationLatitude,
        uint _destinationLongitude,
        bytes32  _transferedItem) public
            companyExists(_speditorCompanyID)
            companyExists(_senderCompanyID)
            companyExists(_recipientCompanyID)
            onlySpecificCompany(_speditorCompanyID)
    {
        documents.push(BusinessModels.CmrDocument(
            BusinessModels.SpeditionStatus.Pending,
            _senderCompanyID,
            _recipientCompanyID,
            _speditorCompanyID,
            BusinessModels.Place(_originLatitude, _originLongitude),
            BusinessModels.Place(_destinationLatitude, _destinationLongitude),
            new BusinessModels.TransferStep[](0),
            _transferedItem
        ));

        emit newSpedition(
            companies[_senderCompanyID].companyAddress,
            companies[_recipientCompanyID].companyAddress,
            now,
            documents.length - 1
        );
    }

    function confirmSpeditionDocument(uint _speditionDocumentID, uint _senderCompanyID) public 
    documentExists(_speditionDocumentID)
    companyExists(_senderCompanyID)
    onlySpecificCompany(_senderCompanyID)
    {
        documents[_speditionDocumentID].status = BusinessModels.SpeditionStatus.Confirmed;
        emit speditionConfirmed(_speditionDocumentID);
    }
} 