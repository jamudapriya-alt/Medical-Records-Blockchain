
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MedicalRecords {

    struct PatientRecord {
        string name;
        uint256 age;
        string uid;
        string medicalData;
        uint256 timestamp;
        bytes32 recordHash;
        bytes32 previousHash;
    }

    // Store records
    mapping(string => PatientRecord[]) private records;

    event RecordAdded(
        string uid,
        bytes32 recordHash,
        uint256 gasAtContractLevel
    );

    // Add record and calculate hash
    function addRecord(
        string memory name,
        uint256 age,
        string memory uid,
        string memory medicalData
    ) public {
        require(bytes(uid).length > 0, "UID cannot be empty");
        require(bytes(name).length > 0, "Name cannot be empty");

        bytes32 previousHash = bytes32(0);

        uint256 count = records[uid].length;

        if (count > 0) {
            previousHash = records[uid][count - 1].recordHash;
        }

        uint256 timeNow = block.timestamp;

        bytes32 newHash = sha256(
            abi.encode(
                name,
                age,
                uid,
                medicalData,
                timeNow,
                previousHash
            )
        );

        PatientRecord memory newRecord = PatientRecord({
            name: name,
            age: age,
            uid: uid,
            medicalData: medicalData,
            timestamp: timeNow,
            recordHash: newHash,
            previousHash: previousHash
        });

        records[uid].push(newRecord);

        emit RecordAdded(uid, newHash, gasleft());
    }

    // record count
    function getRecordCount(
        string memory uid
    ) public view returns (uint256) {
        return records[uid].length;
    }

  
    function getRecord(
        string memory uid,
        uint256 index
    ) public view returns (PatientRecord memory) {
        require(index < records[uid].length, "Record not found");

        return records[uid][index];
    }

   
    function getRecordHash(
        string memory uid,
        uint256 index
    ) public view returns (string memory) {
        require(index < records[uid].length, "Record not found");

        return toHexString(records[uid][index].recordHash);
    }

    
    function toHexString(
        bytes32 data
    ) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        bytes memory result = new bytes(66);

        result[0] = "0";
        result[1] = "x";

        for (uint256 i = 0; i < 32; i++) {
            result[2 + i * 2] =
                hexSymbols[uint8(data[i] >> 4)];

            result[3 + i * 2] =
                hexSymbols[uint8(data[i] & 0x0f)];
        }

        return string(result);
    }

    
    function verifyRecord(
        string memory uid,
        uint256 index
    ) public view returns (bool) {
        require(index < records[uid].length, "Record not found");

        PatientRecord storage r = records[uid][index];

        bytes32 calculatedHash = sha256(
            abi.encode(
                r.name,
                r.age,
                r.uid,
                r.medicalData,
                r.timestamp,
                r.previousHash
            )
        );

        return calculatedHash == r.recordHash;
    }
}
