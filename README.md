# Decentralized Music Library Smart Contract

## Description

This smart contract is designed to manage a decentralized music library system on the blockchain. It allows users to perform several operations such as adding songs, transferring ownership, updating song details, and removing songs. The system also manages user-specific permissions for accessing songs, ensuring controlled access and secure ownership transfer.

The contract guarantees that only the owner of a song can update or transfer ownership. Additionally, it enforces validation checks on song details (like title, artist, duration, genre, and metadata tags) and ensures proper access rights for users.

Key features:
- **Add songs**: Users can add new songs to the library.
- **Transfer ownership**: Ownership of songs can be transferred between users.
- **Update song details**: Owners can modify song details including title, artist, duration, genre, and metadata tags.
- **Remove songs**: Songs can be removed from the library.
- **Manage user permissions**: The contract allows managing access permissions on a per-user basis.

All song data is securely stored on the blockchain, ensuring transparency and immutability. This smart contract provides an efficient and secure way to manage music ownership and access in a decentralized environment.

## Features

- **Adding new songs**: Allows users to add songs with various attributes including title, artist, duration, genre, and metadata tags.
- **Transferring song ownership**: Enables the transfer of song ownership from one user to another.
- **Updating song details**: Allows the owner to update metadata such as title, artist, genre, and more.
- **Removing songs**: Users can remove songs they own from the library.
- **Access control**: Manage access permissions to songs for specific users.

## Smart Contract Operations

The smart contract includes the following primary functions:

- **add-song**: Adds a new song to the library, ensuring that the song's title, artist, duration, genre, and metadata tags are valid.
- **transfer-ownership**: Allows the transfer of song ownership from the current owner to a new owner.
- **update-song-details**: Updates the song's metadata (title, artist, genre, and tags) and validates the changes.
- **get-song-details**: Fetches the details of a song by its ID.
- **get-user-permission**: Checks if a user has access permission to a specific song.
- **get-total-song-count**: Retrieves the total number of songs in the library.
- **get-song-owner**: Fetches the owner of a particular song by its ID.
- **get-song-genre**: Retrieves the genre of a song by its ID.
- **get-song-metadata-tags**: Fetches the metadata tags of a song.
- **get-song-artist**: Retrieves the artist of a song by its ID.
- **get-song-title**: Fetches the title of a song.
- **get-song-duration-by-id**: Retrieves the duration of a song by its ID.

## Constants and Data Structures

### Constants

- **CONTRACT-OWNER**: Defines the contract owner as the sender of the transaction.
- **ERR-NOT-FOUND**: Error for when a song is not found.
- **ERR-DUPLICATE**: Error for duplicate song entries.
- **ERR-INVALID-TITLE**: Error for invalid song title.
- **ERR-INVALID-DURATION**: Error for invalid song duration.
- **ERR-UNAUTHORIZED**: Error for unauthorized access.
- **ERR-ACCESS-DENIED**: Error for denied access.
- **ERR-ADMIN-ONLY**: Error for admin-only operations.
- **ERR-RESTRICTED**: Error for restricted operations.

### Data Structures

- **song-library**: Maps song IDs to their details including title, artist, owner, duration, genre, and metadata tags.
- **user-permissions**: Maps user permissions for each song, determining whether a user is authorized to access a song.

## Validation Logic

The contract performs the following validations:
- **Song title length**: The title must be between 1 and 64 characters.
- **Song artist length**: The artist name must be between 1 and 32 characters.
- **Song duration**: Duration must be greater than 0 seconds and less than 10,000 seconds.
- **Genre length**: The genre must be between 1 and 32 characters.
- **Metadata tags**: Each tag must be between 1 and 24 characters, with no more than 8 tags.

## Requirements

- **Clarinet 2.0**: Ensure that you have Clarinet 2.0 set up to interact with this smart contract.
- **Blockchain Network**: This contract operates on a decentralized blockchain network, ensuring data transparency and security.

## Deployment and Interaction

1. **Deploy the contract** using Clarinet 2.0 on your desired blockchain network.
2. **Interact with the contract** through the available public functions to add songs, transfer ownership, update song details, and manage permissions.

For further instructions on interacting with the contract, refer to the Clarinet documentation.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

