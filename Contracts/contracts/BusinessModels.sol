pragma solidity 0.5.0;

library BusinessModels {

    enum SpeditionStatus { Active, Completed, Frozen, InConflict, Confirmed, Pending }

    struct Company {
        address companyAddress;
        uint256 id;
        bytes32 companyName;
        uint[] transferDocuments;
        uint[] employees;
    }

    struct Employee {
        bytes32 name;
        bytes32 surname;
        uint employerID;
        uint companyEmployeeID;
        uint systemEmployeeID;
        uint[] workingDocuments;

        uint256 longitude;
        uint256 latitude;
    }

    struct CmrDocument {
        SpeditionStatus status;

        uint senderCompanyID;

        uint recipientCompanyID;

        uint speditorCompanyID;
    
        Place origin;
        Place destination;

        uint[] stepIDs;

        bytes32 transferedItem;
    }

    struct Place {
        uint256 latitude;
        uint256 longitude;
    }

    struct TransferStep {

        Place stepPlace;

        uint forwardedFromEmploy; // EmployeeID

        uint forwardedToEmploy; // EmployeeID

        string forwardReceiverComment;

        bytes32 transferingVehicleID;
    }
}