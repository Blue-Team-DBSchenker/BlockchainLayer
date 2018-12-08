pragma solidity 0.5.0;

import "./BusinessModels.sol";


contract NetworkLogic {
    BusinessModels.Company[] companies;
    BusinessModels.CmrDocument[] documents;
    BusinessModels.Employee[] employees;
    BusinessModels.TransferStep[] steps;

    address[] authorities;
    string[] comments;

    event companyRegistered(address companyAddress, bytes32 name, uint id);
    event companyRegistersNewEmployee(
        uint companyID,
        bytes32 login,
        bytes32 password,
        uint companyEmployeeID,
        uint systemEmployeeID
    );

    event newSpedition(
        address indexed sender,
        address indexed recipient,
        uint when,
        uint indexed speditionID
    );

    event speditionConfirmed(
        uint indexed speditionID
    );

    event newStepAppendedToDocument(
        uint indexed documentID,
        uint forwardedFromEmployeeID,
        uint forwardedToEmployeeID,
        uint when,
        uint stepLatitude,
        uint stepLongitude
    );

    event speditionCompleted(
        uint indexed documentID,
        uint when
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

    modifier employeeWorksInCompany(uint _companyID, uint _systemEmployeeID) {
        require(isEmployerWorkingInCompany(_companyID, _systemEmployeeID), "This employee doesn't work in the given company");
        _;
    }

    constructor(address[] memory _authorities) public {
        authorities = _authorities;
    }

    function isEmployerWorkingInCompany(uint _companyID, uint _systemEmployeeID) private view returns(bool) {
        for(uint i = 0; i < companies[_companyID].employees.length; i++) {
            if(companies[_companyID].employees[i] == _systemEmployeeID) {
                return true;
            } 
        }
        return false;
    }

    function registerNewCompany(address _address, bytes32 _name) public {
        BusinessModels.Company memory company = BusinessModels.Company({
            companyAddress: _address,
            companyName: _name,
            id: companies.length,
            transferDocuments: new uint[](0),
            employees: new uint[](0)
        });

        companies.push(company);
        emit companyRegistered(_address, _name, companies.length - 1);
    }

    function registerNewEmployee(uint _companyID, bytes32 _login, bytes32 _password) public 
    companyExists(_companyID)
    onlySpecificCompany(_companyID)
    {
        BusinessModels.Employee memory employee = BusinessModels.Employee({
            login: _login,
            password: _password,
            session: keccak256(abi.encode(_login, _password)),
            employerID: companies[_companyID].id,
            companyEmployeeID: companies[_companyID].employees.length,
            systemEmployeeID: employees.length - 1,
            workingDocuments: new uint[](0),
            longitude: 0,
            latitude: 0
        });

        uint employeeID = employees.push(employee) - 1;

        companies[_companyID].employees.push(employeeID);
        emit companyRegistersNewEmployee(_companyID, _login, _password, employee.companyEmployeeID, employeeID);
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
            new uint[](0),
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
        documents[_speditionDocumentID].status = BusinessModels.SpeditionStatus.Active;
        emit speditionConfirmed(_speditionDocumentID);
    }

    function appendStepToDocument(
        uint _speditionDocumentID,
        uint _speditorCompanyID,

        uint _forwardedFromEmployee,
        uint _forwardedToEmployee,

        uint _transferLatitude,
        uint _transferLongitude,

        string memory _comment
      ) public
    documentExists(_speditionDocumentID)
    companyExists(_speditorCompanyID)
    onlySpecificCompany(_speditorCompanyID)
    employeeWorksInCompany(_speditorCompanyID, _forwardedFromEmployee)
    employeeWorksInCompany(_speditorCompanyID, _forwardedToEmployee)
    {   
        uint _stepID = steps.push(BusinessModels.TransferStep(
            _forwardedFromEmployee,
            _forwardedToEmployee,
            comments.length
        ));
        comments.push(_comment);
        documents[_speditionDocumentID].stepIDs.push(_stepID);

        emit newStepAppendedToDocument(
            _speditionDocumentID,
            _forwardedFromEmployee,
            _forwardedToEmployee,
            now,
            _transferLatitude,
            _transferLongitude
        );
    }

    function markSpeditionAsCompleted(uint _speditionDocumentID, uint _recieverCompanyID, uint _recievingEmployeeID) public
    documentExists(_speditionDocumentID) 
    companyExists(_recieverCompanyID)
    employeeWorksInCompany(_recieverCompanyID, _recievingEmployeeID)
    {
        documents[_speditionDocumentID].status = BusinessModels.SpeditionStatus.Completed;
        emit speditionCompleted(_speditionDocumentID, now);
    }

    function getUserIDBySession(bytes32 _session) public view returns(uint) {
        for(uint i = 0; i < employees.length; i++) {
            if(employees[i].session == _session) {
                return employees[i].systemEmployeeID;
            }
        }
        return 2^256-1;
    }
} 