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

;; Validates if a given tag has a valid length (between 1 and 24 characters)
(define-private (is-valid-tag (tag (string-ascii 24)))
    (and 
        (> (len tag) u0)  ;; Tag length must be greater than 0
        (< (len tag) u25)  ;; Tag length must be less than 25
    )
)

;; Validates a list of tags to ensure each tag is valid (between 1 and 24 characters) and the list has no more than 8 tags
(define-private (are-valid-tags (tags (list 8 (string-ascii 24))))
    (and
        (> (len tags) u0)  ;; Tags list cannot be empty
        (<= (len tags) u8)  ;; Tags list cannot have more than 8 tags
        (is-eq (len (filter is-valid-tag tags)) (len tags))  ;; All tags must be valid
    )
)

;; ---------------------------
;; Public Functions
;; ---------------------------

;; Adds a new song to the decentralized music library
(define-public (add-song 
        (title (string-ascii 64))     ;; Song title
        (artist (string-ascii 32))    ;; Artist name
        (duration uint)               ;; Duration of the song in seconds
        (genre (string-ascii 32))     ;; Genre of the song
        (tags (list 8 (string-ascii 24)))  ;; List of metadata tags
    )
    (let
        ((new-song-id (+ (var-get total-song-count) u1)))  ;; Generate a new song ID based on the total song count

        ;; Validation checks
        (asserts! (and (> (len title) u0) (< (len title) u65)) ERR-INVALID-TITLE)  ;; Validate title length
        (asserts! (and (> (len artist) u0) (< (len artist) u33)) ERR-INVALID-TITLE)  ;; Validate artist length
        (asserts! (and (> duration u0) (< duration u10000)) ERR-INVALID-DURATION)  ;; Validate duration
        (asserts! (and (> (len genre) u0) (< (len genre) u33)) ERR-INVALID-TITLE)  ;; Validate genre length
        (asserts! (are-valid-tags tags) ERR-INVALID-TITLE)  ;; Validate tags

        ;; Store the song data in the library
        (map-insert song-library
            {id: new-song-id}
            {
                title: title,
                artist: artist,
                owner: tx-sender,  ;; Owner is the sender of the transaction
                duration: duration,
                creation-block: block-height,  ;; Block height of the song creation
                genre: genre,
                metadata-tags: tags
            }
        )

        ;; Set permissions for the song owner
        (map-insert user-permissions
            {song-id: new-song-id, user: tx-sender}  ;; Permission granted to the song owner
            {is-authorized: true}
        )

        ;; Update total song count and return the new song ID
        (var-set total-song-count new-song-id)
        (ok new-song-id)
    )
)

;; Transfers ownership of a song to a new user
(define-public (transfer-ownership (song-id uint) (new-owner principal))
    (let
        ((song-data (unwrap! (map-get? song-library {id: song-id}) ERR-NOT-FOUND)))  ;; Fetch song data

        ;; Validation checks
        (asserts! (does-song-exist song-id) ERR-NOT-FOUND)  ;; Song must exist
        (asserts! (is-eq (get owner song-data) tx-sender) ERR-UNAUTHORIZED)  ;; Only the owner can transfer ownership

        ;; Update the song's owner to the new owner
        (map-set song-library
            {id: song-id}
            (merge song-data {owner: new-owner})  ;; Merge updated owner info
        )
        (ok true)
    )
)

;; Updates details of an existing song (title, duration, genre, and tags)
(define-public (update-song-details 
        (song-id uint) 
        (new-title (string-ascii 64)) 
        (new-duration uint) 
        (new-genre (string-ascii 32)) 
        (new-tags (list 8 (string-ascii 24)))
    )
    (let
        ((song-data (unwrap! (map-get? song-library {id: song-id}) ERR-NOT-FOUND)))  ;; Fetch song data

        ;; Validation checks
        (asserts! (does-song-exist song-id) ERR-NOT-FOUND)  ;; Song must exist
        (asserts! (is-eq (get owner song-data) tx-sender) ERR-UNAUTHORIZED)  ;; Only the owner can update
        (asserts! (and (> (len new-title) u0) (< (len new-title) u65)) ERR-INVALID-TITLE)  ;; Validate title length
        (asserts! (and (> new-duration u0) (< new-duration u10000)) ERR-INVALID-DURATION)  ;; Validate duration
        (asserts! (and (> (len new-genre) u0) (< (len new-genre) u33)) ERR-INVALID-TITLE)  ;; Validate genre length
        (asserts! (are-valid-tags new-tags) ERR-INVALID-TITLE)  ;; Validate tags

        ;; Update song details
        (map-set song-library
            {id: song-id}
            (merge song-data {
                title: new-title,
                duration: new-duration,
                genre: new-genre,
                metadata-tags: new-tags
            })
        )
        (ok true)
    )
)

;; Retrieves the details of a song by its ID
(define-public (get-song-details (song-id uint))
    (let
        ((song-data (unwrap! (map-get? song-library {id: song-id}) ERR-NOT-FOUND)))  ;; Fetch song data
        (ok song-data)  ;; Return the song data
    )
)

;; Retrieves whether a user has access permission for a song
(define-public (get-user-permission (song-id uint) (user principal))
    (let
        ((permission-data (unwrap! (map-get? user-permissions {song-id: song-id, user: user}) ERR-NOT-FOUND)))  ;; Fetch user permission
        (ok (get is-authorized permission-data))  ;; Return whether the user is authorized
    )
)

;; Retrieves the owner of a song by its ID
(define-public (get-song-owner (song-id uint))
    (let
        ((song-data (unwrap! (map-get? song-library {id: song-id}) ERR-NOT-FOUND)))  ;; Fetch song data
        (ok (get owner song-data))  ;; Return the owner of the song
    )
)

;; Retrieves the total number of songs in the library
(define-public (get-total-song-count)
    (ok (var-get total-song-count))  ;; Return the current total song count
)

;; Retrieves the genre of a song by its ID
(define-public (get-song-genre (song-id uint))
    (let
        ((song-data (unwrap! (map-get? song-library {id: song-id}) ERR-NOT-FOUND)))  ;; Fetch song data
        (ok (get genre song-data))  ;; Return the genre of the song
    )
)

;; Retrieves the metadata tags of a song by its ID
(define-public (get-song-metadata-tags (song-id uint))
    (let
        ((song-data (unwrap! (map-get? song-library {id: song-id}) ERR-NOT-FOUND)))  ;; Fetch song data
        (ok (get metadata-tags song-data))  ;; Return the metadata tags of the song
    )
)

;; Retrieves the artist of a song by its ID
(define-public (get-song-artist (song-id uint))
    (let
        ((song-data (unwrap! (map-get? song-library {id: song-id}) ERR-NOT-FOUND)))  ;; Fetch song data
        (ok (get artist song-data))  ;; Return the artist of the song
    )
)
