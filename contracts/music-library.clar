;; Description: 
;; This smart contract is designed to manage a decentralized music library system. 
;; It allows users to perform operations such as adding songs, transferring ownership, 
;; updating song details (e.g., title, artist, duration, genre, and metadata tags), 
;; and removing songs from the library. 
;; The contract ensures that only the owner of a song can update or transfer ownership, 
;; and it validates various inputs such as title length, duration, and tags.
;; Additionally, permissions for accessing songs can be managed per user, ensuring controlled access to the library.
;;
;; The contract supports:
;; - Adding new songs to the library
;; - Transferring ownership of songs
;; - Updating song details (title, artist, duration, genre, tags)
;; - Removing songs from the library
;; - Managing user-specific permissions for accessing songs
;;
;; The system relies on blockchain technology to securely store and manage song data 
;; with a transparent and immutable record of song ownership and access rights.

;; ---------------------------
;; Constants Definitions
;; ---------------------------
(define-constant CONTRACT-OWNER tx-sender)    ;; Defines the contract owner as the sender of the transaction
(define-constant ERR-NOT-FOUND (err u301))    ;; Error: Song not found
(define-constant ERR-DUPLICATE (err u302))    ;; Error: Duplicate entry
(define-constant ERR-INVALID-TITLE (err u303))    ;; Error: Invalid song title
(define-constant ERR-INVALID-DURATION (err u304))    ;; Error: Invalid song duration
(define-constant ERR-UNAUTHORIZED (err u305))    ;; Error: Unauthorized access
(define-constant ERR-ACCESS-DENIED (err u306))    ;; Error: Access denied
(define-constant ERR-ADMIN-ONLY (err u307))    ;; Error: Admin access only
(define-constant ERR-RESTRICTED (err u308))    ;; Error: Restricted operation

;; ---------------------------
;; Data Variables
;; ---------------------------
(define-data-var total-song-count uint u0)    ;; Keeps track of the total number of songs in the music library

;; ---------------------------
;; Data Maps
;; ---------------------------

;; Maps song IDs to their respective details like title, artist, duration, etc.
(define-map song-library
    {id: uint} ;; Key: Song ID
    {
        title: (string-ascii 64),      ;; Song title (max 64 chars)
        artist: (string-ascii 32),     ;; Artist name (max 32 chars)
        owner: principal,              ;; Song owner (principal address)
        duration: uint,                ;; Song duration in seconds
        creation-block: uint,          ;; Block height at the time of creation
        genre: (string-ascii 32),      ;; Genre of the song (max 32 chars)
        metadata-tags: (list 8 (string-ascii 24))  ;; Metadata tags (max 8 tags, each up to 24 chars)
    }
)

;; Maps user permissions for each song (whether a user is authorized to access the song)
(define-map user-permissions
    {song-id: uint, user: principal}  ;; Key: Song ID and User Principal
    {is-authorized: bool}  ;; Value: Whether the user is authorized to access the song
)

;; ---------------------------
;; Private Helper Functions
;; ---------------------------

;; Checks if a song exists in the library by its song ID
(define-private (does-song-exist (song-id uint))
    (is-some (map-get? song-library {id: song-id}))  ;; Returns true if song exists
)

;; Validates if the provided principal is the owner of the song
(define-private (is-song-owner (song-id uint) (user principal))
    (match (map-get? song-library {id: song-id})
        song-data (is-eq (get owner song-data) user)  ;; Returns true if the user is the song owner
        false  ;; Otherwise, returns false
    )
)

;; Retrieves the duration of a song based on its song ID
(define-private (get-song-duration (song-id uint))
    (default-to u0 
        (get duration 
            (map-get? song-library {id: song-id})  ;; Fetches song duration or defaults to 0 if not found
        )
    )
)

