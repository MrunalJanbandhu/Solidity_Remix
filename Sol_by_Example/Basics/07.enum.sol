// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Enum {
    // shipping status exmaple
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }

    // default value is the first element lsited in definitoin of the type, in this case "pending"
    Status public status;

    function get() public view returns (Status) {
        return status;
    }

    // Enumerated values
    // Peding - 0
    // Shipped - 1
    // Accepted - 2
    // Rejected - 3
    // Canceled - 4

    // update status by passing uint into inpiut
    function set(Status _status ) public {
        status = _status;
    }

    function cancel() public {
        status = Status.Canceled;
    }

    function reset() public {
        delete status;
    }


}