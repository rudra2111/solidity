pragma solidity ^0.8.7;

// SPDX-License-Identifier: MIT 


/*
- The Administrator (owner) of the bookstore should be 
able to add a new book containing the following fields 
- id, name, author, year and quantity.



- The Administrator should not be able to add the 
same book twice, just the quantity.



- Buyers (clients) should be able to see all of the available books.



- Buyers (clients)should be able to buy a book by its `id`.



- Buyers (clients) should be able to return a book 
if they are not satisfied (within a certain period in blocktime: 
200 blocks).



- A buyer (client) can't buy the same book more than one time.



- The buyers (clients) should not be able to buy a 
book more times than the quantity in the store, 
unless a book is returned or added by the Administrator (owner).



- Everyone should be able to see the 
addresses of all buyers (clients) that have ever bought a given book.

*/


contract bookstore{
    struct book{
        uint id;
        string name;
        string author;
        uint year;
        uint quantity;
        address[] buyeraddress;
    }

    mapping(uint => book) public books;
    uint public bookCount;



    address public administrator;
    
    //adding modifiers to add permissions (administrators and buyers)
    modifier onlyAdministrator(){
        require(msg.sender == administrator, "Only the administrator can call this function,");
        _;
    }

    modifier onlyBuyer(){
        require(msg.sender != administrator, " Administratros cannot perform this action");
        _;
    }

    constructor(){
        administrator = msg.sender;
    }


    //Answer -> The Administrator (owner) of the bookstore should be able to add a new book containing the following fields - id, name, author, year and quantity.
    function addBook(uint _id, string memory _name, string memory _author, uint _year, uint _quantity) public onlyAdministrator{
        require(_id > 0, "Invalid BookID");
        require(_quantity > 0, "Invalid quantity of book");
        require(_year > 0, "Invalid year");
        

        //this is to check if a book with same name already exists or not 
        if (books[_id].id != _id){
            for(uint i = 0; i <= bookCount; i++){
                require(keccak256(bytes(books[i].name)) != keccak256(bytes(_name)),"A book with same name exists");
            }

            //creating a new book 
            book storage newBook = books[_id];
            newBook.id = _id;
            newBook.name = _name;
            newBook.author = _author;
            newBook.year = _year;
            newBook.quantity = _quantity;
        }
        else{
            //adding the quantity of the book if the book already exists 
            books[_id].quantity += _quantity;
        }

        //bookCount is used to keep a check on the number of books that are added by the administrator
        bookCount++;
    }

    mapping(uint => bool) public bookBought; //mapping used to check if the book is bought or not 
    uint blocknumber; 

    //Answer -> Buyers (clients)should be able to buy a book by its `id`.
    function buyBook(uint _id) public onlyBuyer {
        //require(msg.sender != administrator, "Administrators cannot buy the book");
        require(_id > 0, "Invalid ID");
        require(books[_id].quantity > 0,"The book that you want is out of stock");
        require(bookBought[_id] == false,"you have already bought the book");

        bookBought[_id] = true;
        books[_id].quantity--;
        books[_id].buyeraddress.push(msg.sender);  
        blocknumber = 200;      

    }

    // Answer -> function to return the book 
    function returnBook(uint _id) public {
        require(_id > 0, "Invalid ID");
        require(books[_id].id == _id,"The ID that you have entered is wrong");
        require(bookBought[_id] == true,"You have not bought this book yet ");
        require(block.number <= blocknumber,"The return period has expired");

        bookBought[_id] = false;
        books[_id].quantity++;

        
    }
    //Answer -> Buyers (clients) should be able to see all of the available books.
    function showBooks() public view returns (uint[] memory,string[] memory, string[] memory, uint[] memory, uint[] memory){

        //initialising arrays that store each value individually 
        uint[] memory ids = new uint[](bookCount);
        string[] memory namesBook = new string[](bookCount);
        string[] memory authorNames = new string[](bookCount);
        uint[] memory yearPub = new uint[](bookCount);
        uint[] memory noOfBooks = new uint[](bookCount);

        uint index = 0;

        //adding the values from mapping books to the arrays declared above
        for(uint i = 1; i <= bookCount; i++){
            if(books[i].quantity > 0){
                ids[index] = books[i].id;
                namesBook[index] = books[i].name;
                authorNames[index] = books[i].author;
                yearPub[index] = books[i].year;
                noOfBooks[index] = books[i].quantity;
                index++;
            }
        }
        return(ids,namesBook,authorNames,yearPub,noOfBooks);

    }

    //Answer -> Everyone should be able to see the addresses of all buyers (clients) that have ever bought a given book.
    function addressOfBuyers() public view returns (address[] memory) {
        uint buyersTotal = 0;
            for (uint i = 1; i <= bookCount; i++) {
                buyersTotal += books[i].buyeraddress.length;
            }

            // Initialize the dynamic array to store all buyer addresses
            address[] memory addressOfbuyers = new address[](buyersTotal);
            uint index = 0;

            // Iterate over each book and its buyeraddress from struct array to collect all buyer addresses
            for (uint i = 1; i <= bookCount; i++) {
                for (uint j = 0; j < books[i].buyeraddress.length; j++) {
                    addressOfbuyers[index] = books[i].buyeraddress[j];
                    index++;
                }
            }

            return addressOfbuyers;
    }

}

