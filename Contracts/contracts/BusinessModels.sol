pragma solidity ^0.5;

library BusinessModels {

    enum SpeditionStatus { Active, Completed, Frozen, InConflict, Confirmed, Pending }

    struct Company {
        address companyAddress;
        uint256 id;
        bytes32 companyName;
        uint[] transferDocuments;
        Employ[] employs;
    }

    struct Employ {
        bytes32 name;
        bytes32 surname;
        uint employerID;
        uint employID;
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

        TransferStep[] steps;

        bytes32 transferedItem;
    }

    struct Place {
        uint256 latitude;
        uint256 longitude;
    }

    struct TransferStep {

        Place stepPlace;

        uint forwardedFromEmploy; // EmployID
        uint forwardedFromCompany; // Company ID

        uint forwardedToEmploy; // EmployID
        uint forwardedToCompany; // CompanyID

        string forwardReceiverComment;

        bytes32 transferingVehicleID;
    }
}