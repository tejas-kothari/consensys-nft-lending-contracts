// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {ERC721} from "solmate/src/tokens/ERC721.sol";

contract NftLending {
    /**
     * @dev Represents a loan request made by a borrower for a specific NFT.
     */
    struct LoanRequest {
        address borrower; // Address of the borrower
        address denomination; // Address of the ERC20 token to be borrowed
    }
    /**
     * @dev Stores the loan requests made by borrowers for specific NFTs.
     */
    mapping(address => mapping(uint256 => LoanRequest)) public loanRequests;

    /**
     * @dev Represents a loan offer made by a lender for a specific NFT and loan denomination.
     */
    struct LoanOffer {
        uint256 amount; // Amount of tokens to be loaned
        uint256 interest; // Amount of interest expected
        uint256 duration; // Duration of the loan in seconds
    }
    /**
     * @dev Stores the loan offers made by lenders for specific NFTs and loan denomination.
     */
    mapping(address => mapping(uint256 => mapping(address => mapping(address => LoanOffer))))
        public loanOffers;

    /**
     * @dev Represents an active loan for a specific NFT.
     */
    struct Loan {
        address borrower; // Address of the borrower
        address lender; // Address of the lender
        address denomination; // Address of the ERC20 token used for the loan
        uint256 amount; // Amount of tokens loaned
        uint256 interest; // Amount of interest expected
        uint256 end; // Timestamp indicating the end of the loan in seconds
    }
    /**
     * Stores the active loans for specific NFTs.
     */
    mapping(address => mapping(uint256 => Loan)) public loans;

    /**
     * @dev Allows a borrower to request a loan for a specific NFT.
     * @param nft Address of the NFT contract
     * @param tokenId ID of the NFT token
     * @param denomination Address of the ERC20 token to be borrowed
     */
    function requestLoan(
        address nft,
        uint256 tokenId,
        address denomination
    ) public {
        loanRequests[nft][tokenId] = LoanRequest(msg.sender, denomination);
        ERC721(nft).transferFrom(msg.sender, address(this), tokenId);
    }

    /**
     * @dev Allows a lender to offer a loan for a specific NFT.
     * @param nft Address of the NFT contract
     * @param tokenId ID of the NFT token
     * @param amount Amount of tokens to be loaned
     * @param interest Amount of interest expected
     * @param duration Duration of the loan in seconds
     */
    function offerLoan(
        address nft,
        uint256 tokenId,
        uint256 amount,
        uint256 interest,
        uint256 duration
    ) public {
        require(amount != 0 && interest != 0 && duration != 0, "Invalid offer");

        LoanRequest memory loanRequest = loanRequests[nft][tokenId];
        LoanOffer storage loanOffer = loanOffers[nft][tokenId][
            loanRequest.denomination
        ][msg.sender];

        require(
            loanOffer.amount == 0 &&
                loanOffer.interest == 0 &&
                loanOffer.duration == 0,
            "Already made loan offer"
        );

        loanOffer.amount = amount;
        loanOffer.interest = interest;
        loanOffer.duration = duration;

        ERC20(loanRequest.denomination).transferFrom(
            msg.sender,
            address(this),
            amount
        );
    }

    /**
     * @dev Allows a lender to cancel a loan offer for a specific NFT.
     * @param nft Address of the NFT contract
     * @param tokenId ID of the NFT token
     * @param denomination Address of the ERC20 token
     */
    function cancelLoanOffer(
        address nft,
        uint256 tokenId,
        address denomination
    ) public {
        LoanOffer memory loanOffer = loanOffers[nft][tokenId][denomination][
            msg.sender
        ];

        ERC20(denomination).transferFrom(
            address(this),
            msg.sender,
            loanOffer.amount
        );

        delete loanOffers[nft][tokenId][denomination][msg.sender];
    }

    /**
     * @dev Allows the borrower to accept a loan offer for a specific NFT.
     * @param nft Address of the NFT contract
     * @param tokenId ID of the NFT token
     * @param lender Address of the lender
     */
    function acceptLoanOffer(
        address nft,
        uint256 tokenId,
        address lender
    ) public {
        LoanRequest memory loanRequest = loanRequests[nft][tokenId];
        LoanOffer memory loanOffer = loanOffers[nft][tokenId][
            loanRequest.denomination
        ][lender];

        require(
            msg.sender == loanRequest.borrower,
            "Only borrower can accept loan offers"
        );

        loans[nft][tokenId] = Loan(
            loanRequest.borrower,
            lender,
            loanRequest.denomination,
            loanOffer.amount,
            loanOffer.interest,
            loanOffer.duration + block.timestamp
        );

        delete loanRequests[nft][tokenId];
        delete loanOffers[nft][tokenId][loanRequest.denomination][lender];
    }

    /**
     * @dev Allows the borrower to repay a loan for a specific NFT before it expires.
     * @param nft Address of the NFT contract
     * @param tokenId ID of the NFT token
     */
    function repayLoan(address nft, uint256 tokenId) public {
        Loan memory loan = loans[nft][tokenId];

        require(block.timestamp <= loan.end, "Loan has expired");

        ERC20(loan.denomination).transferFrom(
            msg.sender,
            loan.lender,
            loan.amount + loan.interest
        );
        ERC721(nft).transferFrom(address(this), loan.borrower, tokenId);

        delete loans[nft][tokenId];
    }

    /**
     * @dev Allows the lender to liquidate a loan for a specific NFT after it has expired.
     * @param nft Address of the NFT contract
     * @param tokenId ID of the NFT token
     */
    function liquidateLoan(address nft, uint256 tokenId) public {
        Loan memory loan = loans[nft][tokenId];

        require(block.timestamp > loan.end, "Loan has not yet expired");

        ERC721(nft).transferFrom(address(this), loan.lender, tokenId);

        delete loans[nft][tokenId];
    }
}
